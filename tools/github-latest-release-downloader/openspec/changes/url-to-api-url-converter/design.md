## Context

This is a new Rust CLI tool (`github-latest-release-downloader`) with no existing implementation. The first iteration focuses solely on URL conversion: given a GitHub repository URL, produce the corresponding GitHub API latest release URL. No network calls are made.

## Goals / Non-Goals

**Goals:**
- Accept a GitHub repo URL (e.g., `https://github.com/owner/repo`) as a CLI argument
- Output the GitHub API latest release URL (e.g., `https://api.github.com/repos/owner/repo/releases/latest`) to stdout
- Validate that the input URL is a recognizable GitHub repo URL

**Non-Goals:**
- Making any HTTP requests
- Downloading assets
- Parsing release metadata
- Supporting GitHub Enterprise or non-standard URLs in this iteration

## Decisions

**Argument parsing: `clap`**
- `clap` is the de facto standard for Rust CLI argument parsing; provides help text and error messages for free.
- Alternative: `std::env::args()` directly - rejected as too manual for a CLI that will grow.

**URL parsing: `url` crate or manual string parsing**
- The GitHub repo URL has a predictable structure (`https://github.com/<owner>/<repo>`). Manual parsing with `split('/')` is sufficient and avoids an extra dependency for this iteration.
- The `url` crate can be added later if URL handling grows more complex.

**Output: stdout only**
- The converted URL is printed to stdout, making the tool composable in shell pipelines.

## Risks / Trade-offs

- [Fragile URL parsing] Manual string splitting may fail on trailing slashes or extra path segments → Mitigation: trim trailing slashes and validate that exactly owner+repo segments are present after the host.
- [No validation of owner/repo characters] GitHub allows alphanumeric, hyphens, dots, underscores → Mitigation: accept any non-empty segments for now; stricter validation can be added later.
