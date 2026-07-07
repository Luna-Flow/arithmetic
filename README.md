# Arithmetic

Arithmetic capability traits for Luna projects.

## v0.2.2 - Instance-Specific Checked Domain Semantics

This documentation tracks the current `v0.2.2` package baseline.

### Package Positioning

- `luna-generic` expresses algebraic structure such as `Ring`, `Field`, and `Num`.
- `arithmetic` expresses analytic and elementary-function capabilities such as `sqrt`, `exp`, `log`, and trigonometric functions.
- The package intentionally describes capabilities rather than declaring “real number” abstractions.
- Packages such as `floating` and future packages such as `computable-real` should implement these traits where the semantics make sense, rather than inheriting a premature bundled `Real` notion from this package.
- The floating-point instances directly call `Kaida-Amethyst/math`.

### Public Surface

- Atomic traits:
  - `Sqrt`
  - `Cbrt`
  - `Radical`
  - `Exponential`
  - `Logarithmic`
  - `Power`
  - `Trigonometric`
  - `InverseTrigonometric`
  - `Hyperbolic`
  - `InverseHyperbolic`
  - `Constants`
- Checked/contextual shared types:
  - `FpClass`
  - `RoundingMode`
  - `ArithmeticContext`
  - `ArithmeticErrorKind`
  - `ArithmeticError`
- Checked/contextual traits:
  - `SqrtChecked`
  - `DivChecked`
  - `CompareChecked`
  - `PowNatChecked`
  - `PowIntChecked`
  - `ParseChecked`
- Enclosure traits:
  - `Contains`
  - `Overlaps`
  - `DefinitelyLt`
  - `DefinitelyLe`
  - `MaybeEq`
- Default instances in the root package:
  - `Float`
  - `Double`
  - `BigInt`
  - `Int`
  - `Int16`
  - `Int64`
  - `UInt`
  - `UInt16`
  - `UInt64`

### Semantic Contract

- The package documents callable capabilities, not a unified semantic model for all numeric domains.
- Each trait preserves the concrete `Self` type instead of introducing widening or wrapper return types.
- Domain validity remains part of the caller contract unless a specific instance documents stronger guarantees.
- Unchecked floating-point instances inherit special-value behavior, branch choices, and principal-value conventions from `Kaida-Amethyst/math`.
- Checked `Float` and `Double` instances use the same backend for ordinary values but may report structured errors for documented real-valued domain failures, such as negative real inputs to checked square root or indeterminate checked division forms.
- The current built-in `Float` and `Double` checked operations do not implement arbitrary precision or rounding control from `ArithmeticContext`; the context is shared boundary data for contextual implementations.
- Integer-family instances are intentionally narrower: this package only implements capabilities that stay meaningfully closed on those concrete types.
- Unchecked/context-free elementary traits remain available for native scalars and other backends where direct IEEE-style behavior is acceptable.
- Checked/contextual traits use `Result[Self, ArithmeticError]` plus `ArithmeticContext` to express validated, precision-aware, or error-aware arithmetic boundaries.
- Enclosure traits describe containment/overlap style relations without pretending enclosure values are totally ordered scalars.

### Official Base-Type Wrapping

- `src/impl_float.mbt` and `src/impl_double.mbt` directly bind the trait surface to `Kaida-Amethyst/math`.
- `src/impl_bigint.mbt`, `src/impl_signed_ints.mbt`, and `src/impl_unsigned_ints.mbt` provide exact integer-family impls only for the capabilities that stay closed on those types.
- Algebraic structure still lives in `luna-generic`; this package only binds function capabilities to concrete numeric backends.
- `Constants` only states that the given `Self` exposes the standard scalar constants used by the package.

### Instance-Specific Preconditions

- `Power::pow` uses one shared signature across floating and integer families.
- For `Float` and `Double`, `pow` follows the backend floating-point semantics from `Kaida-Amethyst/math`.
- For `BigInt`, `Int`, `Int16`, and `Int64`, the exponent must be non-negative.
- Supplying a negative exponent to those signed integer-family instances aborts at runtime, because the result would not remain closed in the same integer type.
- `UInt`, `UInt16`, and `UInt64` are already non-negative by construction, so their `pow` surface has no extra signed-exponent check.
- This package exposes the capability surface and its preconditions; selecting arguments that satisfy the mathematical domain is still partly the caller's responsibility.
- `PowNatChecked` and `PowIntChecked` split integer-exponent power from general unchecked `pow(Self, Self)`.
- In this first checked-power layer, `x^0` returns one, including `0^0`.
- `PowIntChecked` requires reciprocal/division semantics for negative exponents and must not silently accept zero base with a negative exponent.

### API Guidance

- Use the narrowest trait that matches an algorithm.
- Prefer direct capability constraints such as `Sqrt`, `Trigonometric`, or `Logarithmic` instead of semantic bundle traits.
- `Power` remains intentionally undivided in this release, even though integer and floating use cases may be split more carefully later.
- This package does not define “realness”; it defines callable capability surfaces.
- When an algorithm may produce out-of-domain arguments, validate them at the application layer before calling the trait method.
- For high-precision, validated, or context-sensitive numeric types, prefer the checked/contextual traits over the unchecked elementary traits.
- `arithmetic` is a capability-boundary package; it does not add calculus, matrices, complex numbers, symbolic algebra, or special-function layers.
- Packages such as `floating` implement these capability boundaries for concrete numeric representations.
- `floating` now targets the published checked capability boundary from this package rather than carrying its own ecosystem-level arithmetic error/context types.

### Quick Start

```moonbit
using @lg { trait Add, trait Mul }

fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}

fn polar_x[T : Mul + Trigonometric](r : T, theta : T) -> T {
  r * Trigonometric::cos(theta)
}

inspect(hypot2(3.0, 4.0), content="5")
inspect(
  polar_x(2.0, Constants::pi() / 3.0),
  content="1.0000000000000002",
)
```

### Documentation

We provide README-level documentation in multiple languages:

- English: [doc/en_US/README.md](./doc/en_US/README.md)
- Simplified Chinese: [doc/zh_CN/README.md](./doc/zh_CN/README.md)
- Japanese: [doc/ja_JP/README.md](./doc/ja_JP/README.md)

## Development

Useful local commands:

```bash
moon check
moon test
```
