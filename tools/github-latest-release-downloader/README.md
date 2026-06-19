# github-latest-release-downloader

A CLI tool that downloads assets from the latest release of any GitHub repository.
Given a repository URL and a regex pattern, it fetches the release metadata, matches assets by name, and either saves the file to disk or streams and extracts a `.tar.gz` archive in-place.

## Features

- Downloads the latest release asset matching a regex pattern
- Streams and extracts `.tar.gz`/`.tgz` archives without writing the archive to disk
- Supports authenticated requests via `GITHUB_TOKEN` to avoid rate limiting
- Flexible output path control with `--dir` and `--output` flags

## Installation

```sh
cargo install --path .
```

## Usage

```
github-latest-release-downloader <URL> <PATTERN> [OPTIONS]
```

See `github-latest-release-downloader --help` for more details.
