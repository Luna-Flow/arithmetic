# arithmetic

This manual documents `arithmetic` **0.5.0**. Earlier release history lives in
[CHANGELOG.md](../../CHANGELOG.md).

## Release focus

- `IntegralContextual` embeds MoonBit `Int` values and returns diagnostics.
- `AdjacentContextual` exposes next-plus, next-minus, and next-toward.
- `ConstantsContextual` and `HyperbolicContextual` define context-faithful
  capability boundaries for richer numeric backends.
- Certification failures remain explicit through `ArithmeticError`.

## Capability layers

- Unchecked elementary traits expose direct backend behavior.
- Checked traits expose structured domain and division failures.
- Contextual traits return a value plus diagnostics under an explicit
  `ArithmeticContext`.
- Enclosure traits model containment and definite or possible relations.

## Context contract

- Precision is clamped to at least `1`.
- `e_min` must not exceed `e_max` when both are supplied.
- Decimal presets define precision, exponent range, and clamping together.
- Diagnostics combine with logical OR and remain ordinary immutable values.

## Built-in instance limits

The built-in `Float` and `Double` contextual operations preserve native scalar
behavior. They do not apply arbitrary decimal precision, directed rounding,
exponent clamping, or general status-flag detection. `Float` integer embedding
reports detectable conversion loss; adjacent operations use the fixed IEEE
binary format and return empty diagnostics because neighbor selection is exact.
Contextual division and square root reuse the checked validation paths. Native
`Float` and `Double` do not implement contextual constants or hyperbolic
functions.

## Core documents

- [Getting started](./getting_started.md)
- [Architecture](./architecture.md)
- [Verification](./verification.md)
- [API reference](./api/core.md)
- [Tutorial](./tutorial/core.md)
- [Design](./design/core.md)
- [Repository conventions](./conventions.md)
