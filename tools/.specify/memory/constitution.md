<!--
SYNC IMPACT REPORT
==================
Version change:    [CONSTITUTION_VERSION] (blank template) → 1.0.0 (initial ratification)
Bump rationale:    Initial population of constitution from blank template. No prior version existed;
                   this constitutes the first adoption — v1.0.0.

Modified principles:
  [PRINCIPLE_1_NAME] → I. Code Quality
  [PRINCIPLE_2_NAME] → II. Testing Standards
  [PRINCIPLE_3_NAME] → III. User Experience Consistency
  [PRINCIPLE_4_NAME] → IV. Performance Requirements
  [PRINCIPLE_5_NAME] → (removed — user requested exactly 4 principles)

Added sections:
  - Core Principles (4 principles, Rust-focused)
  - Quality Gates (Section 2)
  - Development Workflow (Section 3)
  - Governance

Removed sections:
  - Fifth principle slot (template had 5; user specified 4)

Templates requiring updates:
  ✅ .specify/memory/constitution.md — this file (updated)
  ✅ .specify/templates/plan-template.md — Constitution Check gates align with new principles
                                           (no structural change needed; gates are dynamically
                                           derived from constitution content by the plan command)
  ✅ .specify/templates/spec-template.md — no changes required; spec structure is principle-agnostic
  ✅ .specify/templates/tasks-template.md — no changes required; task phases cover quality/test/perf
                                            tasks in Phase N (Polish) and Foundational already

Follow-up TODOs:
  - TODO(RATIFICATION_DATE): Date set to 2026-03-17 (today, first authoring). Confirm with team
    if a prior informal ratification date should be backfilled.
-->

# CDE Tools Constitution

## Core Principles

### I. Code Quality

All Rust code in this repository MUST be idiomatic, warning-free, and consistently formatted.
Specifically:

- Code MUST compile with zero warnings under `cargo build` and `cargo clippy -- --deny warnings`.
- Code MUST be formatted with `rustfmt` before every commit; unformatted code MUST NOT be merged.
- `unsafe` blocks are PROHIBITED unless the feature is inherently unsafe (e.g., FFI, SIMD).
  Every `unsafe` block MUST carry a `// SAFETY:` comment explaining the invariant upheld.
- Public APIs MUST carry `///` doc-comments; crate-level `//!` documentation is REQUIRED.
- Dependencies MUST be justified: prefer standard library solutions; every `[dependencies]`
  entry in `Cargo.toml` MUST have a comment explaining why it is necessary.

**Rationale**: Rust's type system and toolchain enforce correctness at compile time. Letting
warnings accumulate or skipping `rustfmt` erodes the guarantee that the compiler provides and
creates noise that masks real issues.

### II. Testing Standards

All non-trivial logic MUST be covered by automated tests. The following rules are non-negotiable:

- Unit tests MUST be colocated with source code using the `#[cfg(test)]` module pattern.
- Integration tests MUST reside in the `tests/` directory at the crate root.
- `cargo test` MUST pass with zero failures before any PR is merged.
- Test names MUST be descriptive and follow the pattern `<unit>_<scenario>_<expected_outcome>`
  (e.g., `download_with_invalid_token_returns_auth_error`).
- Property-based testing with `proptest` or `quickcheck` SHOULD be applied to functions
  with non-trivial input domains (parsers, serializers, algorithms).
- Tests MUST NOT depend on external network calls or live services unless explicitly tagged
  `#[ignore]` and documented as requiring external setup.
- Minimum line coverage target is 80%; coverage checks MUST be enforced in CI via `cargo llvm-cov`.

**Rationale**: Tests are the specification in executable form. Colocating unit tests and enforcing
naming standards makes intent discoverable and refactoring safe.

### III. User Experience Consistency

All tools in this repository that expose a user-facing interface MUST behave consistently:

- CLI tools MUST follow the POSIX convention: exit code `0` on success, non-zero on failure.
- Errors MUST be written to `stderr`; normal output MUST be written to `stdout`.
- Structured output (when supported) MUST use JSON and be opt-in via a `--json` flag.
- Human-readable output MUST be concise, actionable, and free of internal implementation
  details (no stack traces or raw Rust `Debug` output exposed to end users).
- Flags and subcommands MUST be documented in `--help` output; undocumented flags are PROHIBITED.
- Breaking changes to CLI contracts (flag names, output schema) constitute a MAJOR version bump
  and MUST be announced in the changelog before release.

**Rationale**: Predictable, consistent interfaces reduce the cognitive load of operators and
scripts that depend on these tools. A tool that silently changes its output format is as
harmful as a library that silently changes its API.

### IV. Performance Requirements

Performance characteristics MUST be established and maintained with data, not assumptions:

- Every tool MUST document its expected performance profile in `README.md` or inline doc
  (e.g., "processes N items in O(N) time, ~X MB peak memory").
- Benchmarks MUST be written using `criterion` for any operation that is latency-sensitive or
  operates on data sets larger than 1,000 items; benchmarks live in `benches/`.
- Profiling MUST precede optimization: no performance-motivated refactor is permitted without
  a profiling report (flamegraph or `perf` output) identifying the bottleneck.
- Regression thresholds MUST be set in CI: a PR that degrades a benchmark by more than 10%
  without documented justification MUST NOT be merged.
- Memory allocations in hot paths MUST be minimized; prefer stack allocation and zero-copy
  patterns where safe and idiomatic.

**Rationale**: Premature optimization is waste; uninformed optimization is risk. Benchmarks and
profiling data ensure that performance work targets real bottlenecks and preserves gains over time.

## Quality Gates

Every pull request MUST pass all of the following gates before merge. These gates are directly
derived from the Core Principles above and are non-negotiable:

| Gate | Command | Failure Action |
|------|---------|---------------|
| Format check | `cargo fmt --check` | Run `cargo fmt` and recommit |
| Lint | `cargo clippy -- --deny warnings` | Fix all clippy findings |
| Tests | `cargo test` | Fix failing tests before merge |
| Coverage | `cargo llvm-cov --fail-under-lines 80` | Add missing tests |
| Benchmark regression | `cargo bench` (CI delta check) | Justify or fix regression |
| Doc build | `cargo doc --no-deps` | Fix broken doc comments |

CI MUST enforce all gates automatically. Manual overrides require sign-off from a maintainer
and MUST be accompanied by a follow-up issue to restore compliance.

## Development Workflow

The following workflow applies to all contributions:

1. **Branch**: Create a feature branch from `main` following the pattern `###-short-description`.
2. **Spec-first**: Non-trivial features MUST have a spec in `specs/` before implementation begins.
3. **Test-first for logic**: Unit and integration tests MUST be written and confirmed failing
   before the implementation that makes them pass (Red → Green → Refactor).
4. **Constitution Check**: Every plan.md MUST include a Constitution Check section verifying
   compliance with all four Core Principles before Phase 0 research begins.
5. **Benchmark before optimizing**: Any performance-motivated change MUST include benchmark
   results in the PR description.
6. **Changelog**: Every PR MUST update `CHANGELOG.md` under the `[Unreleased]` section.
7. **Review**: All PRs require at least one approving review; self-merge is PROHIBITED on `main`.

## Governance

This constitution supersedes all other development practices documented in this repository.
Where conflicts exist between this constitution and any other document, the constitution takes
precedence.

**Amendment procedure**:
1. Propose the amendment as a PR modifying this file.
2. State the version bump type (MAJOR/MINOR/PATCH) and rationale in the PR description.
3. Update `LAST_AMENDED_DATE` and `CONSTITUTION_VERSION` in the version line below.
4. Obtain at least one maintainer approval before merging.
5. Propagate changes to all dependent templates per the Consistency Propagation checklist
   in `.opencode/command/speckit.constitution.md`.

**Versioning policy** (semantic):
- MAJOR: Removal or backward-incompatible redefinition of an existing principle.
- MINOR: Addition of a new principle, section, or materially expanded guidance.
- PATCH: Clarifications, wording improvements, typo fixes.

**Compliance review**: All PRs and code reviews MUST verify adherence to the Core Principles.
Any observed violation MUST be raised as a review comment and MUST NOT be approved until
resolved or explicitly deferred with a tracked follow-up issue.

**Version**: 1.0.0 | **Ratified**: 2026-03-17 | **Last Amended**: 2026-03-17
