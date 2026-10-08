# Repository conventions

These rules apply to the `arithmetic` manual in addition to the Luna Flow
documentation standard.

## Baseline and history

The manual describes the code on the current branch: release `0.5.0` plus the
changes listed under `Unreleased` in [CHANGELOG.md](../../CHANGELOG.md).
[CHANGELOG.md](../../CHANGELOG.md) owns the release timeline, so the
[overview](index.md) and the repository README describe only the current
baseline.

## Pages

- The single package at `src/` is documented as `core`: `api/core.md`,
  `tutorial/core.md` and `design/core.md`.
- Separate what a trait promises from what a shipped instance does. When an
  instance does less than the trait allows (for example, ignores the context),
  say so on the API page where the trait is described.
- State the semantics of special values (NaN, signed zeros, infinities,
  overflow) for every shipped instance; generic users rely on them.
- Mathematics that the code does not implement may appear only as the
  contract of a trait or as an explicitly labelled illustration.

## Examples

- Use the aliases `@lf_arith` for `Luna-Flow/arithmetic` and `@lf_alg` for
  `Luna-Flow/luna-generic`, and call trait methods through the trait
  (`@lf_arith.Sqrt::sqrt(x)`).
- Every `moonbit` block not marked `nocheck` must compile and pass as a test,
  as described in [verification](verification.md). Show results with
  `inspect` or `debug_inspect`.
- Prefer short, direct technical sentences over release prose.

## Translation

- Do not translate identifiers, type names, trait names, package names, paths,
  commands or version strings.
- Chinese should read as natural written technical Chinese, and Japanese as
  natural technical Japanese rather than a literal translation.
