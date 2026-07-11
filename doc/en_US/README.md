# Arithmetic Documentation

This directory contains the English documentation baseline for `arithmetic`
**0.3.0**. Earlier release history lives in
[CHANGELOG.md](../../CHANGELOG.md).

## Release Focus

- `ArithmeticContext` now includes exponent limits, clamping, and decimal32,
  decimal64, and decimal128 presets.
- `ArithmeticOutcome[T]` carries a result value and immutable
  `ArithmeticDiagnostics` flags.
- Contextual traits cover core arithmetic, selected analytic operations, and
  numeric-format facts.
- `Float` and `Double` implement the new surface without claiming arbitrary
  precision or context-controlled rounding.

## Capability Layers

- Unchecked elementary traits expose direct backend behavior.
- Checked traits expose structured domain and division failures.
- Contextual traits return a value plus diagnostics under an explicit
  `ArithmeticContext`.
- Enclosure traits model containment and definite or possible relations.

## Context Contract

- Precision is clamped to at least `1`.
- `e_min` must not exceed `e_max` when both are supplied.
- Decimal presets define precision, exponent range, and clamping together.
- Diagnostics combine with logical OR and remain ordinary immutable values.

## Built-in Instance Limits

The built-in `Float` and `Double` contextual operations currently preserve
native scalar behavior. They do not apply arbitrary decimal precision,
directed rounding, exponent clamping, or status-flag detection. Successful
operations therefore return exact diagnostics, while contextual division and
square root reuse the checked validation paths.

## Core Documents

- [API reference](./core/api.md)
- [Tutorial](./core/tutorial.md)
- [Design](./core/design.md)
- [Documentation standard](./doc_standard.md)
