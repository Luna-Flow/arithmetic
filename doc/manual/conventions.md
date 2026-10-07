# Repository conventions

These rules apply to the `arithmetic` manual in addition to the Luna-Flow documentation standard.

## Baseline and history

The manual describes the current release baseline, `0.5.0`. The [overview](index.md) explains the active release, the package positioning and the entry points. [CHANGELOG.md](../../CHANGELOG.md) owns the release timeline and older release notes, so the overview and the repository README stay focused on the active baseline.

## Writing requirements

- Separate API guarantees from implementation strategy and known limitations.
- State when a capability is only an interface boundary and a shipped instance
  does not implement every possible semantic behavior.
- Prefer short, direct technical sentences over promotional release prose.
- Use explicit Luna Flow aliases in MoonBit examples: `@lf_alg` for
  `Luna-Flow/luna-generic` and `@lf_arith` for `Luna-Flow/arithmetic`.

## Translation

- Do not translate identifiers, type names, trait names, package names, paths,
  commands, or version strings.
- Chinese should read as natural written technical Chinese. Japanese should use
  natural technical Japanese rather than literal translation.
