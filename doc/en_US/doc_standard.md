# Documentation Standard

The documentation in this repository describes the **current implementation on
the branch**. As of `2026-07-12`, the active documentation baseline is
**`0.3.0`**.

## Document Types and Organization

### Main Document Types

1. **API reference (`api.md`)**: specifications for public interfaces and
   observable behavior
2. **Tutorial (`tutorial.md`)**: user-oriented examples and selection guidance
3. **Design document (`design.md`)**: capability boundaries, responsibilities,
   and implementation tradeoffs

`README.md` is the current-baseline document. It explains the active release,
package positioning, entry points, and reader guidance. `CHANGELOG.md` owns the
historical release timeline and older release notes.

## Organization Principles

- Organize subsystem documents under the real package or capability boundary.
- Keep `api.md`, `tutorial.md`, and `design.md` distinct in purpose.
- Document only APIs and behavior present in the current branch.
- Keep the Markdown file set aligned across `en_US`, `zh_CN`, and `ja_JP`.
- Keep top-level and second-level section order aligned across languages unless
  a code fact requires a structural difference.
- Treat English as the structural source of truth, then localize the same facts
  naturally into Chinese and Japanese.
- Keep `README.md` focused on the active baseline and move older release
  summaries into `CHANGELOG.md`.

## Writing Requirements

- Do not translate identifiers, type names, trait names, package names, paths,
  commands, or version strings.
- Separate API guarantees from implementation strategy and known limitations.
- State when a capability is only an interface boundary and a shipped instance
  does not implement every possible semantic behavior.
- Prefer short, direct technical sentences over promotional release prose.
- Use explicit Luna Flow aliases in MoonBit examples: `@lf_alg` for
  `Luna-Flow/luna-generic` and `@lf_arith` for `Luna-Flow/arithmetic`.
- Chinese should read as natural written technical Chinese. Japanese should use
  natural technical Japanese rather than literal translation.
