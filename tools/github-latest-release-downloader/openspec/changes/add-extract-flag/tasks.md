## 1. Dependencies

- [ ] 1.1 Add `flate2` and `tar` crates to `Cargo.toml`

## 2. CLI Flag

- [ ] 2.1 Add `--extract` flag to the `Cli` struct with `conflicts_with = "output"`

## 3. Format Validation

- [ ] 3.1 Add a function to detect whether an asset name is a supported archive format (`.tar.gz` / `.tgz`)
- [ ] 3.2 In `main`, after asset selection and before downloading, check format when `--extract` is set and exit with error if unsupported

## 4. Extraction

- [ ] 4.1 Add an `extract_asset` function that accepts an HTTP response reader and a destination directory, streams it through `GzDecoder` into `tar::Archive`, and calls `unpack(dest)`
- [ ] 4.2 In `main`, call `extract_asset` instead of `download_asset` when `--extract` is set

## 5. Success Output

- [ ] 5.1 Update the success message in `main`: print `Extracted to: <dir>` when `--extract` is set, keep `Downloaded: <path>` otherwise

## 6. Tests

- [ ] 6.1 Unit test: format detection returns true for `.tar.gz` and `.tgz`, false for `.zip`, `.tar.bz2`, plain binary names
- [ ] 6.2 Unit test: `--extract` and `--output` together is rejected by clap
- [ ] 6.3 Integration test: `extract_asset` unpacks a minimal in-memory `.tar.gz` to a temp directory and produces the expected file(s)
