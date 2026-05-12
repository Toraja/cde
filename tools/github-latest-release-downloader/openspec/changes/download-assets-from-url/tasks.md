## 1. Dependencies

- [ ] 1.1 Add `ureq` with `json` feature to `Cargo.toml`
- [ ] 1.2 Add `serde` with `derive` feature and `serde_json` to `Cargo.toml`
- [ ] 1.3 Add `regex` to `Cargo.toml`

## 2. CLI Arguments

- [ ] 2.1 Add a second positional argument `pattern` (regex string) to the `Cli` struct
- [ ] 2.2 Add help text mentioning `GITHUB_TOKEN` env var for authenticated requests

## 3. Regex Validation

- [ ] 3.1 Compile the user-provided pattern with `regex::Regex::new` before any HTTP request
- [ ] 3.2 Exit with a non-zero code and clear stderr message if the regex is invalid

## 4. GitHub API Fetch

- [ ] 4.1 Define `Asset` struct with `name` and `browser_download_url` fields, derived `Deserialize`
- [ ] 4.2 Define `Release` struct with an `assets: Vec<Asset>` field, derived `Deserialize`
- [ ] 4.3 Build the API request using `ureq`; include `Authorization: Bearer <token>` header if `GITHUB_TOKEN` is set
- [ ] 4.4 Handle HTTP/network errors and exit with a non-zero code and stderr message

## 5. Asset Matching

- [ ] 5.1 Filter `release.assets` to those whose `name` matches the compiled regex
- [ ] 5.2 If zero matches: exit non-zero, print error to stderr listing all available asset names
- [ ] 5.3 If more than one match: exit non-zero, print error to stderr listing all matching asset names
- [ ] 5.4 If exactly one match: proceed with download

## 6. Asset Download

- [ ] 6.1 Make an HTTP GET request to `browser_download_url`
- [ ] 6.2 Stream the response body into a file in the current working directory named after the asset
- [ ] 6.3 Handle download errors and exit with a non-zero code and stderr message

## 7. Remove Old Stdout Output

- [ ] 7.1 Remove the `println!` that previously printed the API URL to stdout

## 8. Tests

- [ ] 8.1 Add unit test: invalid regex exits before HTTP request
- [ ] 8.2 Add unit test: zero matching assets returns correct error
- [ ] 8.3 Add unit test: multiple matching assets returns correct error
- [ ] 8.4 Add unit test: exactly one matching asset is selected correctly
