## 1. Project Setup

- [ ] 1.1 Add `clap` dependency to `Cargo.toml` with derive feature

## 2. CLI Argument Parsing

- [ ] 2.1 Define CLI struct in `src/main.rs` using `clap` derive macros with a single positional `url` argument

## 3. URL Conversion Logic

- [ ] 3.1 Implement a function `to_api_url(url: &str) -> Result<String, String>` that parses and converts the GitHub repo URL
- [ ] 3.2 Handle trailing slashes by trimming before parsing
- [ ] 3.3 Validate that the host is `github.com`
- [ ] 3.4 Validate that the path contains both owner and repo segments (at least two non-empty path segments)
- [ ] 3.5 Return the constructed `https://api.github.com/repos/<owner>/<repo>/releases/latest` string on success

## 4. Main Entry Point

- [ ] 4.1 Wire CLI parsing to `to_api_url` in `main`, print result to stdout on success
- [ ] 4.2 On error, print error message to stderr and exit with non-zero code

## 5. Tests

- [ ] 5.1 Add unit tests for `to_api_url` covering: standard URL, trailing slash URL, non-GitHub domain, missing repo segment
