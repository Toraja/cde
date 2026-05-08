use clap::Parser;

/// Convert a GitHub repository URL to the GitHub API latest release URL.
#[derive(Parser)]
#[command(author, version, about)]
struct Cli {
    /// GitHub repository URL (e.g., https://github.com/owner/repo)
    url: String,
}

fn to_api_url(url: &str) -> Result<String, String> {
    let trimmed = url.trim_end_matches('/');

    let without_scheme = trimmed
        .strip_prefix("https://")
        .or_else(|| trimmed.strip_prefix("http://"))
        .ok_or_else(|| format!("Invalid URL: {}", url))?;

    let (host, path) = without_scheme
        .split_once('/')
        .ok_or_else(|| format!("Invalid URL: missing path in {}", url))?;

    if host != "github.com" {
        return Err(format!(
            "Invalid URL: host must be github.com, got {}",
            host
        ));
    }

    let segments: Vec<&str> = path.split('/').filter(|s| !s.is_empty()).collect();

    if segments.len() < 2 {
        return Err(format!(
            "Invalid URL: expected owner/repo path segments, got {}",
            path
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
        assert_eq!(
            to_api_url("https://github.com/owner/repo"),
            Ok("https://api.github.com/repos/owner/repo/releases/latest".to_string())
        );
    }

    #[test]
    fn test_trailing_slash_url() {
        assert_eq!(
            to_api_url("https://github.com/owner/repo/"),
            Ok("https://api.github.com/repos/owner/repo/releases/latest".to_string())
        );
    }

    #[test]
    fn test_non_github_domain() {
        assert!(to_api_url("https://gitlab.com/owner/repo").is_err());
    }

    #[test]
    fn test_missing_repo_segment() {
        assert!(to_api_url("https://github.com/owner").is_err());
    }
}
