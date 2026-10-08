# arithmetic

This manual documents release `0.5.0` of `Luna-Flow/arithmetic` together with
the unreleased MoonBit 0.10 migration listed in
[CHANGELOG.md](../../CHANGELOG.md).

## Overview

`Luna-Flow/arithmetic` defines the analytic capabilities of Luna Flow numeric
types: elementary functions, checked operations that return structured errors,
contextual operations that report how a result was rounded under an explicit
precision and rounding mode, and relations between enclosures such as
intervals. It ships default instances for `Float`, `Double` and the integer
types, and leaves context-faithful and certified arithmetic to backends that
implement the same traits.

[`luna-generic`](https://lunaflow.cn/en/luna-generic/) says what a type is
(`Ring`, `Field`, ...). `arithmetic` says which analytic operations it
supports and how they fail. Numeric backends implement the traits, and
algorithms depend on the traits instead of on concrete number types.

| Tier | Example | Returns | Use it when |
| --- | --- | --- | --- |
| Unchecked | `Sqrt::sqrt` | `Self` | the type's own special-value behaviour is acceptable |
| Checked | `SqrtChecked::sqrt_checked` | `Result[Self, ArithmeticError]` | invalid input must become a handled error |
| Contextual | `SqrtContextual::sqrt_contextual` | `Result[ArithmeticOutcome[Self], ArithmeticError]` | precision and rounding are explicit and diagnostics matter |
| Enclosure relation | `DefinitelyLt::definitely_lt` | `Bool` | values are intervals or balls, not points |

## Install

```sh
moon add Luna-Flow/arithmetic@0.5.0
```

Then import `"Luna-Flow/arithmetic"` in your `moon.pkg`. Luna Flow code uses
the alias `@lf_arith`:

```moonbit nocheck
import {
  "Luna-Flow/arithmetic" @lf_arith,
}
```

The package needs the MoonBit toolchain 0.10 or later (`moonc` ≥ 0.10) with
the `moon.mod` and `moon.pkg` manifests, and is checked on the `wasm-gc`,
`wasm`, `js` and `native` backends. It depends on `Kaida-Amethyst/math` for
the `Float` and `Double` elementary functions; its tests also use
`Luna-Flow/luna-generic`.

## Pages

The module has one package, at the source root `src/`, documented as `core`.

| Part | Tutorial | API | Design |
| --- | --- | --- | --- |
| `core`: capability traits, context, diagnostics, errors, instances | [tutorial](tutorial/core.md) | [API](api/core.md) | [design](design/core.md) |

Guides that span the package:

| Guide | Contents |
| --- | --- |
| [Getting started](getting_started.md) | install, first generic function, first checked and contextual calls |
| [Architecture](architecture.md) | source layout, tiers, errors and state |
| [Verification](verification.md) | the local gate, CI and what the tests establish |
| [Repository conventions](conventions.md) | rules for this manual on top of the Luna Flow standard |

The blackbox tests (`src/*_test.mbt`) and the whitebox test
(`src/certification_error_wbtest.mbt`) belong to the same package; the
[verification guide](verification.md) lists what they establish.

## Exported traits

- Unchecked: `Sqrt`, `Cbrt`, `Radical`, `Exponential`, `Logarithmic`,
  `Power`, `Trigonometric`, `InverseTrigonometric`, `Hyperbolic`,
  `InverseHyperbolic`, `Constants`
- Checked: `SqrtChecked`, `DivChecked`, `CompareChecked`, `PowNatChecked`,
  `PowIntChecked`, `ParseChecked`
- Contextual: `AddContextual`, `SubContextual`, `MulContextual`,
  `DivContextual`, `AbsContextual`, `SqrtContextual`, `ExpContextual`,
  `IntegralContextual`, `AdjacentContextual`, `ConstantsContextual`,
  `HyperbolicContextual`, `NumericFormatContextual`
- Enclosure relations: `Contains`, `Overlaps`, `DefinitelyLt`,
  `DefinitelyLe`, `MaybeEq`

## Exported types

- Context: `ArithmeticContext` with the presets `decimal32`, `decimal64` and
  `decimal128`, and `RoundingMode`
- Results: `ArithmeticOutcome[T]` and `ArithmeticDiagnostics`
- Errors: `ArithmeticError`, `ArithmeticErrorKind`, and the certification
  evidence `CertificationFailureDetail`, `CertificationStage` and
  `CertificationFailureReason`
- Classification: `FpClass`

## Shipped instances

- `Float` and `Double`: every unchecked trait, every checked trait except
  `ParseChecked`, and the contextual arithmetic, absolute value, square root,
  exponential, integer embedding, adjacent values and format queries
- `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64` and `BigInt`: `Power`
  only
- No instance of `ParseChecked`, `ConstantsContextual`,
  `HyperbolicContextual` or the enclosure relations; backends provide them

## Where to read next

The [core tutorial](tutorial/core.md) works through tasks with every tier.
The [core API](api/core.md) lists every public item with what each shipped
instance does at the edges, and the [core design](design/core.md) derives the
rounding, enclosure and error-bound mathematics behind the contracts.

- New to the package: read [getting started](getting_started.md), then the
  [core tutorial](tutorial/core.md).
- Using it in a library: keep the [core API](api/core.md) at hand; its
  tables say what each shipped instance actually does at the edges (NaN, zero,
  infinities, overflow).
- Implementing a backend or contributing: read the
  [core design](design/core.md) for the contracts and their mathematics,
  [architecture](architecture.md) for the layout, and
  [verification](verification.md) and [conventions](conventions.md) before
  opening a pull request.

## Validation

Recommended release checks:

```bash
moon check --target all
moon test
moon test --target js
moon test --target native
```

The [verification guide](verification.md) has the full gate, including the
documentation checks.
