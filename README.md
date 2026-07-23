# Arithmetic

Arithmetic capability traits and checked or contextual numeric boundaries for
Luna Flow projects.

## v0.5.0 - Contextual Capability Expansion

This release expands the contextual capability boundary built in `0.3.0` and
the certification-failure vocabulary added in `0.4.0`. The new traits cover
integer embedding, adjacent representable values, context-dependent constants,
and context-dependent hyperbolic functions without bundling unrelated numeric
requirements.

For earlier release notes and repository history, see
[CHANGELOG.md](./CHANGELOG.md).

### Release Notes

- `IntegralContextual` embeds a MoonBit `Int` under an explicit context and
  returns conversion diagnostics.
- `AdjacentContextual` exposes next-plus, next-minus, and next-toward
  operations while preserving signed-zero and infinity boundaries.
- `ConstantsContextual` and `HyperbolicContextual` define context-faithful
  outcome surfaces for numeric backends that can report meaningful diagnostics.
- Proof-backed constant implementations can preserve target-rounding failures
  through `ArithmeticErrorKind::CertificationFailure`.

## Package Positioning

- `luna-generic` expresses algebraic structure such as `Ring`, `Field`, and
  `Num`.
- `arithmetic` expresses analytic functions, checked operations, contextual
  outcomes, and enclosure-style relations.
- The package describes small capabilities rather than declaring a bundled
  “real number” abstraction.
- Concrete numeric packages should implement only the traits whose semantics
  they can support faithfully.

## Capability Layers

### Unchecked Elementary Traits

- `Sqrt`, `Cbrt`, `Radical`
- `Exponential`, `Logarithmic`, `Power`
- `Trigonometric`, `InverseTrigonometric`
- `Hyperbolic`, `InverseHyperbolic`
- `Constants`

These traits preserve direct backend behavior and return `Self`.

### Checked Traits

- `SqrtChecked`, `DivChecked`, `CompareChecked`
- `PowNatChecked`, `PowIntChecked`, `ParseChecked`

Checked traits return `Result[..., ArithmeticError]` and use
`ArithmeticContext` where the operation needs an explicit context.
`ArithmeticError` can also carry a `CertificationFailureDetail` when a
proof-backed backend cannot certify a result at the requested target.

### Contextual Outcome Traits

- `AddContextual`, `SubContextual`, `MulContextual`, `DivContextual`
- `AbsContextual`, `SqrtContextual`, `ExpContextual`
- `IntegralContextual`, `AdjacentContextual`
- `ConstantsContextual`, `HyperbolicContextual`
- `NumericFormatContextual`

Contextual operations return `ArithmeticOutcome[Self]` inside `Result`, keeping
the computed value and diagnostic flags together as immutable data.

### Enclosure Relations

- `Contains`, `Overlaps`
- `DefinitelyLt`, `DefinitelyLe`, `MaybeEq`

These traits model containment and definite or possible relations without
pretending enclosure values form a scalar total order.

## Context Contract

- `ArithmeticContext::new` clamps precision to at least `1`.
- If both exponent limits are present, `e_min` must not exceed `e_max`.
- The decimal presets use precisions `7`, `16`, and `34` with their matching
  exponent ranges and clamping enabled.
- `ArithmeticDiagnostics::combine` merges flags with logical OR, so callers can
  aggregate a sequence of outcomes explicitly.

The built-in `Float` and `Double` contextual implementations do **not** emulate
arbitrary decimal precision, directed rounding, exponent clamping, or general
IEEE status-flag detection. Contextual division and square root delegate
validation to their checked counterparts. Integer embedding reports
`inexact`/`rounded` when conversion to `Float` loses information. Adjacent
operations use the fixed IEEE binary format and treat selecting the neighboring
value as exact. `Float` and `Double` intentionally do not implement
`ConstantsContextual` or `HyperbolicContextual`, because their native functions
cannot honor arbitrary contexts or report complete diagnostics.

## Installation

```bash
moon add Luna-Flow/arithmetic@0.5.0
moon add Luna-Flow/luna-generic@0.3.1
```

Use explicit Luna Flow aliases in `moon.pkg`:

```moonbit nocheck
import {
  "Luna-Flow/luna-generic" @lf_alg,
  "Luna-Flow/arithmetic" @lf_arith,
}
```

## Quick Start

```moonbit
using @lf_alg { trait Add, trait Mul }
using @lf_arith { trait Sqrt }

fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}

let context = @lf_arith.ArithmeticContext::decimal64()
let outcome = @lf_arith.DivContextual::div_contextual(10.0, 4.0, context).unwrap()
inspect(outcome.value, content="2.5")
inspect(outcome.diagnostics.inexact, content="false")
```

## Documentation

- English: [doc/en_US/README.md](./doc/en_US/README.md)
- Simplified Chinese: [doc/zh_CN/README.md](./doc/zh_CN/README.md)
- Japanese: [doc/ja_JP/README.md](./doc/ja_JP/README.md)
- Getting started: [doc/en_US/getting_started.md](./doc/en_US/getting_started.md)
- Architecture: [doc/en_US/architecture.md](./doc/en_US/architecture.md)
- Verification: [doc/en_US/verification.md](./doc/en_US/verification.md)
- Documentation standard: [doc/en_US/doc_standard.md](./doc/en_US/doc_standard.md)

## Changelog

Historical release notes live in [CHANGELOG.md](./CHANGELOG.md). This README
stays focused on the current package baseline and entry points.

## Development

Useful local commands:

```bash
moon fmt
moon info
moon check --target all
moon test
```

## Release Checklist

1. Bump `moon.mod` to the intended release version.
2. Update `README.md`, all three localized documentation trees, and
   `CHANGELOG.md`.
3. Run `moon fmt --check`, `moon info`, `moon build --target all`,
   `moon check --target all --frozen`, and the default, JavaScript, and native
   test suites.
4. Trigger `publish-package` with the exact `moon.mod` version. The workflow
   repeats the checks, publishes to mooncakes, and creates the matching GitHub
   release.

The workflow publishes the version declared in `moon.mod` to mooncakes; it does
not accept a mismatched release version.
