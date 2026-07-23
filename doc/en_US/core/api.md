# Core API

## Purpose

`arithmetic` extends `luna-generic` with analytic capabilities, checked
operations, contextual outcomes, and enclosure relations. Public traits remain
small so algorithms can request only the capabilities they use.

## Unchecked Capability Traits

- `Sqrt`, `Cbrt`, `Radical`
- `Exponential`, `Logarithmic`, `Power`
- `Trigonometric`, `InverseTrigonometric`
- `Hyperbolic`, `InverseHyperbolic`
- `Constants`

These traits are defined in `src/elementary.mbt` and return direct backend
values.

## Checked Surface

### Shared Types

- `FpClass`
- `RoundingMode`
- `ArithmeticContext`
- `CertificationStage`
- `CertificationFailureReason`
- `CertificationFailureDetail`
- `ArithmeticErrorKind`
- `ArithmeticError`

### Context Construction

`ArithmeticContext::new` accepts precision, rounding mode, optional `e_min` and
`e_max`, and an optional `clamp` flag. Precision is clamped to at least `1`.
Construction aborts when both exponent limits are present and `e_min` exceeds
`e_max`.

The package also provides these presets:

- `ArithmeticContext::decimal32`: precision `7`, exponent range `-95...96`
- `ArithmeticContext::decimal64`: precision `16`, exponent range `-383...384`
- `ArithmeticContext::decimal128`: precision `34`, exponent range
  `-6143...6144`

All three presets use `ToNearestEven` and enable clamping.

### Checked Traits

- `SqrtChecked`
- `DivChecked`
- `CompareChecked`
- `PowNatChecked`
- `PowIntChecked`
- `ParseChecked`

These traits return `Result[..., ArithmeticError]`. Operations that require an
arithmetic context accept it explicitly.

## Contextual Outcome Surface

### Result Types

`ArithmeticDiagnostics` contains the flags `inexact`, `rounded`, `overflow`,
`underflow`, `subnormal`, and `clamped`. `empty` and `new` construct diagnostic
values; `combine` merges two values using logical OR for every flag.

`ArithmeticOutcome[T]` stores `value : T` and its diagnostics. `exact` creates
an outcome with empty diagnostics, while `with_diagnostics` preserves supplied
flags.

### Contextual Traits

- `AddContextual`, `SubContextual`, `MulContextual`, `DivContextual`
- `AbsContextual`, `SqrtContextual`, `ExpContextual`
- `IntegralContextual`, `AdjacentContextual`
- `ConstantsContextual`, `HyperbolicContextual`
- `NumericFormatContextual`

`IntegralContextual::from_int_contextual` embeds a MoonBit `Int` under the
target context and returns conversion diagnostics. Wider integer sources use
separate capabilities. `AdjacentContextual` exposes
`next_plus_contextual`, `next_minus_contextual`, and
`next_toward_contextual`. `ConstantsContextual` produces `pi`, `tau`, and `e`
under a context and may return an `ArithmeticError` whose kind is
`ArithmeticErrorKind::CertificationFailure` when a proof-backed implementation
cannot certify target rounding.

`HyperbolicContextual` exposes contextual `sinh`, `cosh`, and `tanh`, each as
an `ArithmeticOutcome` inside `Result`.

`NumericFormatContextual` provides contextual zero, one, epsilon, minimum
normal value, maximum finite value, and classification as `Finite`, `Infinity`,
or `NaN`.

## Enclosure Relations

- `Contains`
- `Overlaps`
- `DefinitelyLt`
- `DefinitelyLe`
- `MaybeEq`

These are relations rather than a scalar total-order abstraction.

## Shipped Instances

- `Float` and `Double` implement the broad elementary surface through
  `Kaida-Amethyst/math`.
- `Float` and `Double` implement the checked square-root, division, comparison,
  and integer-power surfaces.
- `Float` and `Double` implement the original contextual surface plus
  `IntegralContextual` and `AdjacentContextual`.
- `Float` and `Double` intentionally do not implement `ConstantsContextual` or
  `HyperbolicContextual`; context-faithful numeric backends provide those
  capabilities.
- `BigInt` and the integer family implement the narrower exact subset that
  remains closed on each concrete type.

## Semantic Notes

- Unchecked traits leave domain restrictions and branch semantics to the
  concrete instance.
- Built-in checked square root returns `DomainError` for negative real input.
- Built-in checked division classifies `0 / 0` and infinity divided by infinity
  as `DomainError`; non-zero division by zero remains `DivisionByZero`.
- Built-in contextual division and square root delegate to checked operations
  and wrap successful values with exact diagnostics.
- Built-in `Float` integer embedding sets `inexact` and `rounded` when the
  source integer is not exactly representable; `Double` exactly embeds every
  MoonBit `Int`.
- Built-in adjacent operations follow the fixed IEEE binary representation,
  including signed-zero and infinity boundaries. Selecting the adjacent value
  is exact in that fixed representable set and returns empty diagnostics.
- The built-in implementations do not apply context-controlled precision,
  rounding, exponent clamping, or status-flag detection.
- Signed integer and `BigInt` `Power` implementations require non-negative
  exponents; negative exponents abort.
- `PowNatChecked` treats `x^0` as the multiplicative identity, including `0^0`.
