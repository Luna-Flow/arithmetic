# Changelog

All notable repository-release changes are tracked here. The main
[`README.md`](./README.md) stays focused on the current baseline and entry
points; older release history lives in this file.

## 0.3.0 - 2026-07-12

Current repository release.

### Added

- Added optional exponent limits and clamping to `ArithmeticContext`, together
  with decimal32, decimal64, and decimal128 context presets.
- Added `ArithmeticDiagnostics` for immutable `inexact`, `rounded`, `overflow`,
  `underflow`, `subnormal`, and `clamped` status flags, including explicit flag
  combination.
- Added `ArithmeticOutcome[T]` to keep successful values and diagnostic flags
  in one result.
- Added contextual capabilities for addition, subtraction, multiplication,
  division, absolute value, square root, exponential, and numeric-format facts.
- Added `Float` and `Double` implementations for the contextual capability
  surface.
- Added a repository changelog and aligned the English, Chinese, and Japanese
  documentation with the current API surface and documentation standard.

### Changed

- Expanded `ArithmeticContext::new` with optional `e_min`, `e_max`, and `clamp`
  arguments while retaining source compatibility for existing constructor
  calls.
- Regenerated the public package interface for the new context fields, result
  types, contextual traits, and built-in implementations.

### Current Limits

- Built-in `Float` and `Double` contextual operations preserve native scalar
  behavior and return exact diagnostics for successful operations.
- These built-in instances do not apply arbitrary decimal precision, directed
  rounding, exponent clamping, or full IEEE status-flag detection.
- Contextual division and square root reuse the existing checked validation
  paths before wrapping successful values.

## 0.2.2 - 2026-07-07

Previous repository release.

### Highlights

- Checked `Float` and `Double` square root began reporting `DomainError` for
  negative real inputs while preserving negative zero and NaN behavior.
- Checked division distinguished indeterminate `0 / 0` and infinity divided by
  infinity from ordinary non-zero division by zero.
- Checked signed powers handled the minimum `Int` exponent without directly
  negating it.
- Package source configuration moved to the current `source = "src"` syntax.

## 0.2.1 - 2026-06-07

Previous repository release.

### Highlights

- Refined the checked capability release boundary for downstream Luna Flow
  numeric packages.
- Documented that downstream floating implementations should reuse the shared
  arithmetic context and error types rather than defining ecosystem-local
  replacements.
- Aligned repository metadata with the Apache-2.0 license baseline.

## 0.2.0 - 2026-06-07

Previous repository release. This release established the checked arithmetic
capability boundary.

### Highlights

- Added `ArithmeticContext`, `ArithmeticError`, error categories, floating-point
  classification, and rounding-mode vocabulary.
- Added checked square root, division, comparison, integer-power, and parsing
  traits.
- Added enclosure-style containment and definite or possible relation traits.
- Added checked `Float` and `Double` implementations and expanded trait-level
  test coverage.

## 0.1.0 - 2026-06-06

Initial repository baseline.

### Highlights

- Added small elementary capability traits for radicals, exponentials,
  logarithms, powers, trigonometric functions, hyperbolic functions, and
  constants.
- Added default `Float` and `Double` implementations backed by
  `Kaida-Amethyst/math`.
- Added exact integer-family implementations for operations that remain closed
  on their concrete types.
