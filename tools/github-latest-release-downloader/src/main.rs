use std::fs::{self, File};
use std::io;
use std::path::{Path, PathBuf};

use clap::Parser;
use regex::Regex;
use serde::Deserialize;
use url::Url;

/// Download a release asset from a GitHub repository.
///
/// Fetches the latest release from the given GitHub repository and downloads
/// the single asset whose name matches PATTERN (a regular expression).
///
/// Authentication: set the GITHUB_TOKEN environment variable to use an
/// authenticated request and avoid the 60 req/hr unauthenticated rate limit.
#[derive(Parser)]
#[command(author, version, about)]
struct Cli {
    /// GitHub repository URL (e.g., https://github.com/owner/repo)
    url: Url,

    /// Regex pattern to match against asset names (must match exactly one asset)
    pattern: Regex,

    /// Directory in which to save the downloaded asset (original filename is preserved).
    /// Parent directories are created automatically if they do not exist.
    /// Mutually exclusive with --output.
    #[arg(short = 'D', long, conflicts_with = "output")]
    dir: Option<PathBuf>,

    /// Exact file path at which to save the downloaded asset (enables renaming).
    /// If the path already exists as a file it will be overwritten.
    /// Must not point to an existing directory.
    /// Parent directories are created automatically if they do not exist.
    /// Mutually exclusive with --dir.
    #[arg(short = 'O', long, conflicts_with = "dir")]
    output: Option<PathBuf>,
}

#[derive(Debug, Deserialize)]
struct Asset {
    name: String,
    browser_download_url: String,
}

#[derive(Deserialize)]
struct Release {
    assets: Vec<Asset>,
}

fn to_api_url(url: &Url) -> Result<Url, String> {
    if url.host_str() != Some("github.com") {
        return Err(format!(
            "Invalid URL: host must be github.com, got {}",
            url.host_str().unwrap_or("<none>")
        ));
    }

    let segments: Vec<&str> = url
        .path_segments()
        .map(|s| s.filter(|seg| !seg.is_empty()).collect())
        .unwrap_or_default();

    if segments.len() < 2 {
        return Err(format!(
            "Invalid URL: expected owner/repo path segments, got {}",
            url.path()
        ));
    }

    let owner = segments[0];
    let repo = segments[1];

    Url::parse(&format!(
        "https://api.github.com/repos/{}/{}/releases/latest",
        owner, repo
    ))
    .map_err(|e| e.to_string())
}

fn fetch_release(api_url: &Url) -> Result<Release, String> {
    let mut req = ureq::get(api_url.as_str())
        .header("User-Agent", "github-latest-release-downloader")
        .header("Accept", "application/vnd.github+json");

    if let Ok(token) = std::env::var("GITHUB_TOKEN") {
        req = req.header("Authorization", &format!("Bearer {}", token));
    }

    let mut response = req
        .call()
        .map_err(|e| format!("API request failed: {}", e))?;

    response
        .body_mut()
        .read_json::<Release>()
        .map_err(|e| format!("Failed to parse release JSON: {}", e))
}

fn select_asset<'a>(assets: &'a [Asset], pattern: &Regex) -> Result<&'a Asset, String> {
    let matches: Vec<&Asset> = assets
        .iter()
        .filter(|a| pattern.is_match(&a.name))
        .collect();

    match matches.len() {
        0 => {
            let available: Vec<&str> = assets.iter().map(|a| a.name.as_str()).collect();
            Err(format!(
                "No assets matched pattern '{}'. Available assets:\n  {}",
                pattern,
                available.join("\n  ")
            ))
        }
        1 => Ok(matches[0]),
        _ => {
            let matched: Vec<&str> = matches.iter().map(|a| a.name.as_str()).collect();
            Err(format!(
                "Pattern '{}' matched multiple assets — refine your pattern:\n  {}",
                pattern,
                matched.join("\n  ")
            ))
        }
    }
}

fn resolve_output_path(
    asset_name: &str,
    dir: Option<&Path>,
    output: Option<&Path>,
) -> Result<PathBuf, String> {
    if let Some(output) = output {
        if output.is_dir() {
            return Err(format!(
                "--output path '{}' is an existing directory; use --dir to save into a directory",
                output.display()
            ));
        }
        return Ok(output.to_path_buf());
    }

    let base = dir.unwrap_or_else(|| Path::new("."));
    Ok(base.join(asset_name))
}

fn download_asset(asset: &Asset, dest: &Path) -> Result<(), String> {
    let mut response = ureq::get(&asset.browser_download_url)
        .header("User-Agent", "github-latest-release-downloader")
        .call()
        .map_err(|e| format!("Download request failed: {}", e))?;

    if let Some(parent) = dest.parent()
        && !parent.as_os_str().is_empty()
    {
        fs::create_dir_all(parent)
            .map_err(|e| format!("Failed to create directory '{}': {}", parent.display(), e))?;
    }

    let mut file = File::create(dest)
        .map_err(|e| format!("Failed to create file '{}': {}", dest.display(), e))?;

    let mut reader = response.body_mut().as_reader();
    io::copy(&mut reader, &mut file)
        .map_err(|e| format!("Failed to write '{}': {}", dest.display(), e))?;

    Ok(())
}

fn main() {
    let cli = Cli::parse();

    let api_url = match to_api_url(&cli.url) {
        Ok(u) => u,
        Err(e) => {
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    };

    let release = match fetch_release(&api_url) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    };

    let asset = match select_asset(&release.assets, &cli.pattern) {
        Ok(a) => a,
        Err(e) => {
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    };

    let dest = match resolve_output_path(
        &asset.name,
        cli.dir.as_deref(),
        cli.output.as_deref(),
    ) {
        Ok(p) => p,
        Err(e) => {
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    };

    if let Err(e) = download_asset(asset, &dest) {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }

    println!("Downloaded: {}", dest.display());
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_asset(name: &str) -> Asset {
        Asset {
            name: name.to_string(),
            browser_download_url: format!("https://example.com/{}", name),
        }
    }

    #[test]
    #[allow(clippy::invalid_regex)]
    fn test_invalid_regex() {
        assert!(Regex::new("[invalid").is_err());
    }

    #[test]
    fn test_no_matching_assets() {
        let assets = vec![
            make_asset("gh_2.40.1_linux_amd64.tar.gz"),
            make_asset("gh_2.40.1_darwin_amd64.tar.gz"),
        ];
        let pattern = Regex::new("windows").unwrap();
        let err = select_asset(&assets, &pattern).unwrap_err();
        assert!(err.contains("No assets matched"));
        assert!(err.contains("gh_2.40.1_linux_amd64.tar.gz"));
        assert!(err.contains("gh_2.40.1_darwin_amd64.tar.gz"));
    }

    #[test]
    fn test_multiple_matching_assets() {
        let assets = vec![
            make_asset("gh_2.40.1_linux_amd64.tar.gz"),
            make_asset("gh_2.40.1_linux_arm64.tar.gz"),
            make_asset("gh_2.40.1_darwin_amd64.tar.gz"),
        ];
        let pattern = Regex::new("linux").unwrap();
        let err = select_asset(&assets, &pattern).unwrap_err();
        assert!(err.contains("matched multiple assets"));
        assert!(err.contains("gh_2.40.1_linux_amd64.tar.gz"));
        assert!(err.contains("gh_2.40.1_linux_arm64.tar.gz"));
        assert!(!err.contains("darwin"));
    }

    #[test]
    fn test_single_matching_asset() {
        let assets = vec![
            make_asset("gh_2.40.1_linux_amd64.tar.gz"),
            make_asset("gh_2.40.1_darwin_amd64.tar.gz"),
        ];
        let pattern = Regex::new(r"linux_amd64").unwrap();
        let asset = select_asset(&assets, &pattern).unwrap();
        assert_eq!(asset.name, "gh_2.40.1_linux_amd64.tar.gz");
    }

    #[test]
    fn test_standard_url() {
        let url = Url::parse("https://github.com/owner/repo").unwrap();
        assert_eq!(
            to_api_url(&url),
            Ok(Url::parse("https://api.github.com/repos/owner/repo/releases/latest").unwrap())
        );
    }

    #[test]
    fn test_trailing_slash_url() {
        let url = Url::parse("https://github.com/owner/repo/").unwrap();
        assert_eq!(
            to_api_url(&url),
            Ok(Url::parse("https://api.github.com/repos/owner/repo/releases/latest").unwrap())
        );
    }

    #[test]
    fn test_non_github_domain() {
        let url = Url::parse("https://gitlab.com/owner/repo").unwrap();
        assert!(to_api_url(&url).is_err());
    }

    #[test]
    fn test_missing_repo_segment() {
        let url = Url::parse("https://github.com/owner").unwrap();
        assert!(to_api_url(&url).is_err());
    }

    // --- resolve_output_path tests ---

    #[test]
    fn test_resolve_no_flags_uses_current_dir() {
        let path = resolve_output_path("asset.tar.gz", None, None).unwrap();
        assert_eq!(path, Path::new(".").join("asset.tar.gz"));
    }

    #[test]
    fn test_resolve_dir_existing_appends_filename() {
        let tmp = tempfile::tempdir().unwrap();
        let path = resolve_output_path("asset.tar.gz", Some(tmp.path()), None).unwrap();
        assert_eq!(path, tmp.path().join("asset.tar.gz"));
    }

    #[test]
    fn test_resolve_dir_non_existing_appends_filename() {
        let tmp = tempfile::tempdir().unwrap();
        let non_existing = tmp.path().join("subdir");
        let path = resolve_output_path("asset.tar.gz", Some(&non_existing), None).unwrap();
        assert_eq!(path, non_existing.join("asset.tar.gz"));
    }

    #[test]
    fn test_resolve_output_non_existing_path_used_as_is() {
        let path =
            resolve_output_path("asset.tar.gz", None, Some(Path::new("/tmp/renamed.bin"))).unwrap();
        assert_eq!(path, Path::new("/tmp/renamed.bin"));
    }

    #[test]
    fn test_resolve_output_existing_file_used_as_is() {
        let tmp = tempfile::tempdir().unwrap();
        let file_path = tmp.path().join("existing.bin");
        File::create(&file_path).unwrap();
        let path = resolve_output_path("asset.tar.gz", None, Some(&file_path)).unwrap();
        assert_eq!(path, file_path);
    }

    #[test]
    fn test_resolve_output_existing_directory_returns_error() {
        let tmp = tempfile::tempdir().unwrap();
        let err = resolve_output_path("asset.tar.gz", None, Some(tmp.path())).unwrap_err();
        assert!(err.contains("existing directory"));
    }

    #[test]
    fn test_dir_and_output_mutually_exclusive() {
        let result = Cli::try_parse_from([
            "prog",
            "https://github.com/owner/repo",
            "pattern",
            "--dir",
            "/tmp",
            "--output",
            "/tmp/file.bin",
        ]);
        assert!(result.is_err());
    }
}
