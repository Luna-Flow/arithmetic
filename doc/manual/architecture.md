# Architecture

This guide describes how the repository is organised and how its pieces fit
together. The reasons behind the decisions are in the
[core design](design/core.md).

## Source layout

The module `Luna-Flow/arithmetic` has a single package at `src/`.

| File | Contents |
| --- | --- |
| [`elementary.mbt`](../../src/elementary.mbt) | unchecked traits: `Sqrt`, `Cbrt`, `Radical`, `Exponential`, `Logarithmic`, `Power`, `Trigonometric`, `InverseTrigonometric`, `Hyperbolic`, `InverseHyperbolic`, `Constants` |
| [`checked.mbt`](../../src/checked.mbt) | `FpClass`, `RoundingMode`, `ArithmeticContext`, the error and certification types, the checked traits and the enclosure relation traits |
| [`contextual.mbt`](../../src/contextual.mbt) | `ArithmeticDiagnostics`, `ArithmeticOutcome` and the contextual traits |
| [`impl_double.mbt`](../../src/impl_double.mbt), [`impl_float.mbt`](../../src/impl_float.mbt) | unchecked and checked instances for `Double` and `Float` |
| [`impl_contextual.mbt`](../../src/impl_contextual.mbt) | contextual instances for `Double` and `Float` |
| [`impl_signed_ints.mbt`](../../src/impl_signed_ints.mbt), [`impl_unsigned_ints.mbt`](../../src/impl_unsigned_ints.mbt), [`impl_bigint.mbt`](../../src/impl_bigint.mbt) | `Power` for the integer types |
| [`extends.mbt`](../../src/extends.mbt) | explicit method promotions (`pub extend ... with Eq::{equal}`) and the deprecated implicit forms |
| `pkg.generated.mbti` | the generated public interface, the authority for what is public |

Tests sit next to the sources: `trait_test.mbt` and `contextual_test.mbt` are
blackbox tests that call the package as `@arithmetic`, and
`certification_error_wbtest.mbt` is a whitebox test.

## Dependencies

| Dependency | Used for |
| --- | --- |
| `Kaida-Amethyst/math` (`@km`) | `Float` and `Double` elementary functions |
| `moonbitlang/core/math` | `@math.PI` |
| `moonbitlang/core/debug` | the deprecated `Debug::to_repr` promotions |
| `Luna-Flow/luna-generic` (`@lf_alg`, tests only) | checking that the instances work with the algebraic traits |

The public API does not mention `luna-generic`: the two packages can be
combined in bounds, but neither depends on the other at run time.

## Boundary model

| Boundary | Result | Meaning |
| --- | --- | --- |
| Unchecked trait | `Self` | the backend's own behaviour, including NaN, wrap-around or abort |
| Checked trait | `Result[T, ArithmeticError]` | a rejected operation is an error value |
| Contextual trait | `Result[ArithmeticOutcome[T], ArithmeticError]` | explicit context; diagnostics on success |
| Enclosure relation | `Bool` | containment or a definite or possible relation |

The tiers are independent traits with no supertrait links, so a type
implements any subset of them.

## Errors, diagnostics and certification

An error means the operation produced no accepted result. Diagnostics describe
a successful result with notable conditions (rounding, overflow, underflow,
clamping) and combine with logical OR. A certification failure is an error
whose detail records the stage, reason, target and working precision and the
number of refinements of a proof-backed evaluation; the package imposes no
retry policy.

## Context and state

`ArithmeticContext`, `ArithmeticDiagnostics`, `ArithmeticOutcome` and
`CertificationFailureDetail` are immutable values with read-only fields.
Context is an argument, diagnostics are part of the return value, and
certification evidence travels on the error. There is no global rounding mode,
status register or mutable proof state, so the same call gives the same result
on every target.

## Shipped instances

`Float` and `Double` implement every unchecked trait, the checked square root,
division, comparison and integer powers, and the contextual arithmetic,
absolute value, square root, exponential, integer embedding, adjacent values
and format queries. Their contextual instances ignore the context; only the
`Float` integer embedding reports rounding. They do not implement
`ConstantsContextual`, `HyperbolicContextual`, `ParseChecked` or the enclosure
relations. The integer types and `BigInt` implement `Power` only. The
[API page](api/core.md#shipped-instances) has the full table.

## Public surface and promotions

Since MoonBit 0.10 a trait implementation no longer turns the trait's methods
into methods of the type. `extends.mbt` states which ones are promoted:
`equal` for every public type, so `x.equal(y)` and `T::equal` keep working.
The former implicit `not_equal` and `to_repr` methods are kept as deprecated,
hidden promotions for compatibility. `moon info` regenerates
`pkg.generated.mbti`; review its diff for every change to the public surface.
