use clap::Parser;
use url::Url;

/// Convert a GitHub repository URL to the GitHub API latest release URL.
#[derive(Parser)]
#[command(author, version, about)]
struct Cli {
    /// GitHub repository URL (e.g., https://github.com/owner/repo)
    url: Url,
}

fn to_api_url(url: &Url) -> Result<String, String> {
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

    Ok(format!(
        "https://api.github.com/repos/{}/{}/releases/latest",
        owner, repo
    ))
}

fn main() {
    let cli = Cli::parse();

    match to_api_url(&cli.url) {
        Ok(api_url) => println!("{}", api_url),
        Err(e) => {
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_standard_url() {
        let url = Url::parse("https://github.com/owner/repo").unwrap();
        assert_eq!(
            to_api_url(&url),
            Ok("https://api.github.com/repos/owner/repo/releases/latest".to_string())
        );
    }

    #[test]
    fn test_trailing_slash_url() {
        let url = Url::parse("https://github.com/owner/repo/").unwrap();
        assert_eq!(
            to_api_url(&url),
            Ok("https://api.github.com/repos/owner/repo/releases/latest".to_string())
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
}
