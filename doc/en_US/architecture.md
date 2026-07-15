# Architecture

## Boundary Model

`luna-generic` owns algebraic structure. `arithmetic` adds analytic,
checked, contextual, and enclosure capabilities without introducing a bundled
scalar abstraction. Algorithms compose the smallest traits that state their
requirements.

| Boundary | Result | Meaning |
| --- | --- | --- |
| Unchecked trait | `Self` | Direct concrete-backend behavior |
| Checked trait | `Result[T, ArithmeticError]` | Rejected operation is explicit |
| Contextual trait | `Result[ArithmeticOutcome[T], ArithmeticError]` | Explicit context plus successful diagnostics |
| Enclosure relation | `Bool` | Containment or definite/possible relation |

## Errors, Diagnostics, and Certification

Errors represent operations that do not yield an accepted result. Diagnostics
describe successful results with notable conditions and combine using logical
OR. They are deliberately separate: a flag must not hide an error, and an error
must not be invented merely to transport a flag.

`CertificationFailure` is a third, precise distinction within errors. A
proof-backed implementation uses it when it cannot establish that its candidate
result satisfies the requested target. Its detail separates the failed stage
(`RangeReduction`, `SeriesEvaluation`, `EnclosurePropagation`, or
`TargetRounding`) from the reason. No retry policy is imposed by this package;
callers and concrete backends choose resource or precision escalation.

## Context and State

`ArithmeticContext`, `ArithmeticDiagnostics`, `ArithmeticOutcome`, and
`CertificationFailureDetail` are immutable ordinary values. Context passes as
an argument, diagnostics combine explicitly, and certification evidence stays
on the returned error. The package requires no global rounding mode, hidden
status register, or mutable proof state.

## Shipped Adapter Limits

`Float` and `Double` make the general boundary usable today. Their contextual
operations preserve native scalar semantics; they do not implement arbitrary
decimal precision, directed rounding, exponent clamping, IEEE flag detection,
or proof-backed certification. A concrete certified backend may expose the
same traits and produce structured certification failures.
