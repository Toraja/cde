# Feature Specification: GitHub Repo URL to API URL Converter

**Feature Branch**: `001-github-release-url-builder`  
**Created**: 2026-04-07  
**Status**: Draft  
**Input**: User description: "CLI takes only one argument: a GitHub repository URL (with or without protocol) and converts it to the GitHub API latest release URL, outputting the result to stdout."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Convert Full GitHub URL to API URL (Priority: P1)

A user runs the CLI with a full GitHub repository URL (including `https://` protocol) and receives the corresponding GitHub API latest-release URL on stdout.

**Why this priority**: This is the primary and most common input form. Getting this right is the core value of the tool.

**Independent Test**: Can be fully tested by running the CLI with `https://github.com/foo/bar` and verifying the output is exactly `https://api.github.com/repos/foo/bar/releases/latest`.

**Acceptance Scenarios**:

1. **Given** the CLI is run with `https://github.com/foo/bar`, **When** the command executes successfully, **Then** stdout contains exactly `https://api.github.com/repos/foo/bar/releases/latest`
2. **Given** the CLI is run with `https://github.com/My-Org/My-Repo`, **When** the command executes successfully, **Then** stdout contains `https://api.github.com/repos/My-Org/My-Repo/releases/latest` (case and hyphens preserved)

---

### User Story 2 - Convert Protocol-less GitHub URL to API URL (Priority: P2)

A user runs the CLI with a GitHub repository URL that omits the protocol prefix (e.g., `github.com/foo/bar`) and still receives the correct API URL on stdout.

**Why this priority**: Users commonly copy URLs from terminals or tools that strip the protocol. Supporting this input form reduces friction.

**Independent Test**: Can be fully tested by running the CLI with `github.com/foo/bar` and verifying the output matches the expected API URL.

**Acceptance Scenarios**:

1. **Given** the CLI is run with `github.com/foo/bar`, **When** the command executes successfully, **Then** stdout contains exactly `https://api.github.com/repos/foo/bar/releases/latest`
2. **Given** the CLI is run with `github.com/My-Org/My-Repo`, **When** the command executes, **Then** stdout contains `https://api.github.com/repos/My-Org/My-Repo/releases/latest`

---

### Edge Cases

- What happens when no argument is provided? The tool exits with a non-zero status code and prints a usage message to stderr.
- What happens when the URL does not contain a recognizable `github.com/{user}/{repo}` path? The tool exits with a non-zero status code and prints an error message to stderr explaining the expected format.
- What happens when the URL has a trailing slash (e.g., `https://github.com/foo/bar/`)? The trailing slash is ignored and the output is the same as without it.
- What happens when extra path segments are present (e.g., `https://github.com/foo/bar/tree/main`)? Only the first two path segments (user and repo) are used; the rest are ignored.
- What happens when more than one argument is provided? The tool exits with a non-zero status code and prints an error message to stderr.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The CLI MUST accept exactly one positional argument: a GitHub repository URL.
- **FR-002**: The CLI MUST support URLs both with and without a protocol prefix (e.g., `https://github.com/foo/bar` and `github.com/foo/bar` are both valid inputs).
- **FR-003**: The CLI MUST extract the GitHub username and repository name from the provided URL.
- **FR-004**: The CLI MUST construct and output the URL `https://api.github.com/repos/{user}/{repo}/releases/latest` to stdout, using the extracted username and repository name.
- **FR-005**: The CLI MUST exit with a non-zero status code and print a human-readable error message to stderr when no argument is provided.
- **FR-006**: The CLI MUST exit with a non-zero status code and print a human-readable error message to stderr when more than one argument is provided.
- **FR-007**: The CLI MUST exit with a non-zero status code and print a human-readable error message to stderr when the argument cannot be parsed as a `github.com/{user}/{repo}` URL.
- **FR-008**: The output MUST be the URL string only, terminated by a single newline, with no additional labels or formatting.
- **FR-009**: Trailing slashes in the input URL MUST be stripped before processing.
- **FR-010**: Extra path segments beyond `/{user}/{repo}` (e.g., `/tree/main`) MUST be ignored.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Given any valid GitHub repository URL (with or without protocol), the CLI produces the correct API URL on stdout with 100% accuracy.
- **SC-002**: The CLI completes and outputs the result in under 1 second on any standard modern computer.
- **SC-003**: When called with no argument, more than one argument, or an unrecognisable URL, 100% of such invocations result in a non-zero exit code and a human-readable error message on stderr.
- **SC-004**: The CLI can be used correctly without reading documentation — the error/usage message alone is sufficient to understand the expected input format.

## Assumptions

- Only `github.com` URLs are in scope; other Git hosting platforms (GitLab, Bitbucket, etc.) are not supported in this iteration.
- The `http://` protocol variant is treated the same as `https://` (protocol prefix is stripped and not validated).
- No network requests are made; this is a pure URL transformation tool.
- The username and repository name are not validated for existence on GitHub.
- Extra arguments beyond the first are treated as an error.
- URL encoding of the user or repository name is not performed in this iteration.
