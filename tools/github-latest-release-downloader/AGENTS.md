# Agent Guidelines

## After Every Code Modification

Run the following commands after every code change to ensure correctness:

### Tests

```sh
cargo test
```

### Lint

```sh
cargo clippy --all-targets --all-features -- --deny warnings
```

### Formatting

```sh
cargo fmt --all --check
```

If `cargo fmt --all --check` fails, run `cargo fmt --all` to apply formatting, then verify with `--check` again.
