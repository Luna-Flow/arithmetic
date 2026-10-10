# core API

## Purpose

`Luna-Flow/arithmetic` (the package at `src/`, documented as `core`) is the
capability layer between algebraic structure and concrete numbers. It does
not implement numeric algorithms by itself: it defines which analytic
operations a number type offers and how they fail, and ships baseline
instances for the native `Float`, `Double` and integer types.

This page lists every public item of the package. The items fall into four
capability tiers and the shared values they use.

| Tier | Typical signature | Failure channel | Defined in |
| --- | --- | --- | --- |
| Unchecked | `fn sqrt(Self) -> Self` | none: the backend decides (NaN, abort, wrap) | [`elementary.mbt`](../../../src/elementary.mbt) |
| Checked | `fn sqrt_checked(Self, ArithmeticContext) -> Result[Self, ArithmeticError]` | `Err(ArithmeticError)` | [`checked.mbt`](../../../src/checked.mbt) |
| Contextual | `fn sqrt_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]` | `Err` for rejection, diagnostics for notable success | [`contextual.mbt`](../../../src/contextual.mbt) |
| Enclosure relation | `fn definitely_lt(Self, Self) -> Bool` | none: a relation, not an order | [`checked.mbt`](../../../src/checked.mbt) |

The [core design](../design/core.md) explains why the tiers are separate and
derives the mathematics behind them. The [core tutorial](../tutorial/core.md)
uses them on worked tasks.

## Importing

Add the package to your `moon.pkg`:

```moonbit nocheck
import {
  "Luna-Flow/arithmetic" @lf_arith,
}
```

The examples on this page call every item through the alias, as
`@lf_arith.Sqrt::sqrt(x)`. Call trait methods through the trait rather than
with dot syntax: since MoonBit 0.10 an implementation no longer makes the
trait's methods callable as `x.sqrt()`, and on `Double` that form reaches
core's own method instead.

## Shared vocabulary

### `FpClass`

`FpClass` classifies a floating-point value into one of three disjoint
classes.

```mbti
pub(all) enum FpClass {
  Finite
  Infinity
  NaN
} derive(Eq, @debug.Debug)
```

`Finite` covers zeros, subnormal and normal numbers; `Infinity` covers both
signed infinities; `NaN` covers every not-a-number encoding. The classes form a
partition, so exactly one applies to every value. Obtain the class of a value
with `NumericFormatContextual::classify_contextual`.

```moonbit
test "classify a few doubles" {
  let inf = 1.0 / 0.0
  debug_inspect(
    @lf_arith.NumericFormatContextual::classify_contextual(inf),
    content="Infinity",
  )
  debug_inspect(
    @lf_arith.NumericFormatContextual::classify_contextual(0.0 / 0.0),
    content="NaN",
  )
  debug_inspect(
    @lf_arith.NumericFormatContextual::classify_contextual(-0.0),
    content="Finite",
  )
}
```

### `RoundingMode`

`RoundingMode` names the rounding direction a context requests.

```mbti
pub(all) enum RoundingMode {
  ToNearestEven
  TowardZero
  TowardPositive
  TowardNegative
  AwayFromZero
} derive(Eq)
```

For a real $x$ between two adjacent representable values $a < x < b$:

| Mode | Result |
| --- | --- |
| `ToNearestEven` | the nearer of $a, b$; on a tie, the one with an even last digit |
| `TowardZero` | the one with smaller magnitude (truncation) |
| `TowardPositive` | $b$ (ceiling) |
| `TowardNegative` | $a$ (floor) |
| `AwayFromZero` | the one with larger magnitude |

`AwayFromZero` is directed rounding away from zero (`ROUND_UP` in the General
Decimal Arithmetic specification), not round-to-nearest with ties away. The
mode is a request: the package stores it in `ArithmeticContext`, and each
backend decides whether it honours it. The built-in `Float` and `Double`
instances ignore it.

## Arithmetic context

### `ArithmeticContext`

`ArithmeticContext` is an immutable record of the working precision, rounding
mode and exponent range that a checked or contextual operation runs under.

```mbti
pub struct ArithmeticContext {
  precision : Int
  rounding : RoundingMode
  e_min : Int?
  e_max : Int?
  clamp : Bool
} derive(Eq)
```

- `precision` is the number of significand digits in the backend's radix
  (decimal digits for a decimal backend, bits for a binary one). It is always
  at least `1`.
- `rounding` is the requested `RoundingMode`.
- `e_min` and `e_max` bound the adjusted exponent of normal results; `None`
  means unbounded. When both are present, `e_min <= e_max`.
- `clamp` asks the backend to clamp exponents into the format, as the decimal
  interchange formats do.

The fields are read-only outside the package; build values with
`ArithmeticContext::new` or a preset. The context is passed as an ordinary
argument: there is no global or thread-local context.

### `ArithmeticContext::new`

`ArithmeticContext::new` builds a context from a precision and optional
settings.

```mbti
pub fn ArithmeticContext::new(Int, rounding? : RoundingMode, e_min? : Int, e_max? : Int, clamp? : Bool) -> ArithmeticContext
```

`rounding` defaults to `ToNearestEven`, `clamp` to `false`, and both exponent
limits to `None`. A precision below `1` is raised to `1`. The function aborts
with `ArithmeticContext::new: e_min must not exceed e_max` when both limits are
given and `e_min > e_max`.

```moonbit
test "build a context" {
  let ctx = @lf_arith.ArithmeticContext::new(
    24,
    rounding=@lf_arith.RoundingMode::TowardNegative,
    e_min=-126,
    e_max=127,
  )
  inspect(ctx.precision, content="24")
  inspect(ctx.clamp, content="false")
  inspect(@lf_arith.ArithmeticContext::new(0).precision, content="1")
}
```

### `ArithmeticContext::decimal32`, `ArithmeticContext::decimal64`, `ArithmeticContext::decimal128`

These presets return the contexts of the IEEE 754 decimal interchange formats.

```mbti
pub fn ArithmeticContext::decimal32() -> ArithmeticContext
pub fn ArithmeticContext::decimal64() -> ArithmeticContext
pub fn ArithmeticContext::decimal128() -> ArithmeticContext
```

| Preset | `precision` | `e_min` | `e_max` | `rounding` | `clamp` |
| --- | --- | --- | --- | --- | --- |
| `decimal32` | `7` | `-95` | `96` | `ToNearestEven` | `true` |
| `decimal64` | `16` | `-383` | `384` | `ToNearestEven` | `true` |
| `decimal128` | `34` | `-6143` | `6144` | `ToNearestEven` | `true` |

In every preset $e_{\min} = 1 - e_{\max}$, as IEEE 754 requires.

```moonbit
test "decimal presets" {
  let d64 = @lf_arith.ArithmeticContext::decimal64()
  inspect(d64.precision, content="16")
  inspect(d64.e_min == Some(-383), content="true")
  inspect(d64 == @lf_arith.ArithmeticContext::new(16, e_min=-383, e_max=384, clamp=true), content="true")
}
```

## Errors

### `ArithmeticErrorKind`

`ArithmeticErrorKind` is the category of an `ArithmeticError`.

```mbti
pub enum ArithmeticErrorKind {
  DivisionByZero
  ParseError
  DomainError
  FormatError
  UnsupportedOperation
  UnorderedComparison
  CertificationFailure(CertificationFailureDetail)
} derive(Eq)
```

| Kind | Meaning |
| --- | --- |
| `DivisionByZero` | a non-zero or NaN value divided by zero, or a reciprocal of zero |
| `ParseError` | text that does not denote a value |
| `DomainError` | an argument outside the operation's mathematical domain, including indeterminate forms such as $0/0$ |
| `FormatError` | a value that the target format cannot hold or render |
| `UnsupportedOperation` | an operation or context the backend does not implement |
| `UnorderedComparison` | a comparison involving an unordered value such as NaN |
| `CertificationFailure` | a proof-backed backend could not certify its result; carries the details |

The enum is `pub`, not `pub(all)`: you can match on it, but you build errors
through the `ArithmeticError` constructors below.

### `ArithmeticError`

`ArithmeticError` is the structured error that every checked and contextual
trait returns.

```mbti
pub struct ArithmeticError {
  kind : ArithmeticErrorKind
  message : String
} derive(Eq)
```

`kind` is the machine-readable category and `message` a human-readable
explanation. Two errors are equal when both fields are equal.

`ArithmeticError` derives only `Eq`: it implements neither `Show` nor
`Debug`, so print `err.message` or match on `err.kind` instead of passing the
error to `inspect` or `debug_inspect`. The same holds for
`ArithmeticErrorKind`, `CertificationFailureDetail`, `CertificationStage`,
`CertificationFailureReason`, `ArithmeticContext` and `RoundingMode`; only
`FpClass`, `ArithmeticDiagnostics` and `ArithmeticOutcome` derive `Debug`.

### Error constructors

`ArithmeticError::division_by_zero`, `ArithmeticError::parse_error`,
`ArithmeticError::domain_error`, `ArithmeticError::format_error`,
`ArithmeticError::unsupported` and `ArithmeticError::unordered_comparison`
build an error of the matching kind with the given message.

```mbti
pub fn ArithmeticError::division_by_zero(String) -> ArithmeticError
pub fn ArithmeticError::parse_error(String) -> ArithmeticError
pub fn ArithmeticError::domain_error(String) -> ArithmeticError
pub fn ArithmeticError::format_error(String) -> ArithmeticError
pub fn ArithmeticError::unsupported(String) -> ArithmeticError
pub fn ArithmeticError::unordered_comparison(String) -> ArithmeticError
```

`unsupported` produces the kind `UnsupportedOperation`.

### Error predicates

`ArithmeticError::is_division_by_zero`, `is_parse_error`, `is_domain_error`,
`is_format_error`, `is_unsupported`, `is_unordered_comparison` and
`is_certification_failure` test the kind of an error.

```mbti
pub fn ArithmeticError::is_division_by_zero(ArithmeticError) -> Bool
pub fn ArithmeticError::is_parse_error(ArithmeticError) -> Bool
pub fn ArithmeticError::is_domain_error(ArithmeticError) -> Bool
pub fn ArithmeticError::is_format_error(ArithmeticError) -> Bool
pub fn ArithmeticError::is_unsupported(ArithmeticError) -> Bool
pub fn ArithmeticError::is_unordered_comparison(ArithmeticError) -> Bool
pub fn ArithmeticError::is_certification_failure(ArithmeticError) -> Bool
```

Exactly one predicate is true for every error.

```moonbit
test "build and classify errors" {
  let err = @lf_arith.ArithmeticError::domain_error("log of a negative number")
  inspect(err.is_domain_error(), content="true")
  inspect(err.is_division_by_zero(), content="false")
  inspect(err.message, content="log of a negative number")
  inspect(
    @lf_arith.ArithmeticError::unsupported("no decimal backend").is_unsupported(),
    content="true",
  )
}
```

### `ArithmeticError::certification_failure`

`ArithmeticError::certification_failure` wraps a `CertificationFailureDetail`
into an error of kind `CertificationFailure`.

```mbti
pub fn ArithmeticError::certification_failure(CertificationFailureDetail) -> ArithmeticError
```

The message is `certified evaluation failed for <operation>`, where
`<operation>` comes from the detail.

### `ArithmeticError::certification_failure_detail`

`ArithmeticError::certification_failure_detail` returns the detail of a
certification failure and `None` for every other kind.

```mbti
pub fn ArithmeticError::certification_failure_detail(ArithmeticError) -> CertificationFailureDetail?
```

## Certification failures

A proof-backed backend evaluates a function by a pipeline of stages and
certifies that its result meets the target. When it cannot, it reports where
the pipeline stopped and why. The [design page](../design/core.md#certification-stages)
describes the pipeline.

### `CertificationStage`

`CertificationStage` names the stage at which certified evaluation failed.

```mbti
pub(all) enum CertificationStage {
  RangeReduction
  SeriesEvaluation
  EnclosurePropagation
  TargetRounding
} derive(Eq)
```

| Stage | Work done in the stage |
| --- | --- |
| `RangeReduction` | reducing the argument to a small primary interval |
| `SeriesEvaluation` | evaluating a truncated series or approximation with a remainder bound |
| `EnclosurePropagation` | carrying error enclosures through the remaining operations |
| `TargetRounding` | rounding the final enclosure to the target precision |

### `CertificationFailureReason`

`CertificationFailureReason` says why a stage could not be certified.

```mbti
pub(all) enum CertificationFailureReason {
  RangeNotCertified
  SeriesDidNotConverge
  InvalidEnclosure
  ResourceLimit
  RefinementBudgetExhausted
} derive(Eq)
```

| Reason | Meaning |
| --- | --- |
| `RangeNotCertified` | the reduced argument could not be shown to lie in the primary range |
| `SeriesDidNotConverge` | the remainder bound did not fall below the required tolerance |
| `InvalidEnclosure` | an intermediate enclosure was empty, unbounded or otherwise unusable |
| `ResourceLimit` | a precision or size limit was reached |
| `RefinementBudgetExhausted` | repeated precision increases did not decide the rounding |

### `CertificationFailureDetail`

`CertificationFailureDetail` records the evidence of a certification failure.

```mbti
pub struct CertificationFailureDetail {
  operation : String
  stage : CertificationStage
  reason : CertificationFailureReason
  target_precision : Int
  work_precision : Int
  refinements : Int
} derive(Eq)
```

`operation` names the operation (for example `"exp"`), `target_precision` is
the precision the result was requested at, `work_precision` the last internal
precision tried, and `refinements` the number of precision increases made.

### `CertificationFailureDetail::new`

`CertificationFailureDetail::new` builds a detail and normalises its counters.

```mbti
pub fn CertificationFailureDetail::new(String, CertificationStage, CertificationFailureReason, Int, Int, Int) -> CertificationFailureDetail
```

The arguments are, in order, the operation, stage, reason, target precision,
working precision and refinement count. Both precisions are raised to at least
`1` and the refinement count to at least `0`.

### Detail accessors

`CertificationFailureDetail::operation`, `stage`, `reason`,
`target_precision`, `work_precision` and `refinements` return the field of the
same name.

```mbti
pub fn CertificationFailureDetail::operation(CertificationFailureDetail) -> String
pub fn CertificationFailureDetail::stage(CertificationFailureDetail) -> CertificationStage
pub fn CertificationFailureDetail::reason(CertificationFailureDetail) -> CertificationFailureReason
pub fn CertificationFailureDetail::target_precision(CertificationFailureDetail) -> Int
pub fn CertificationFailureDetail::work_precision(CertificationFailureDetail) -> Int
pub fn CertificationFailureDetail::refinements(CertificationFailureDetail) -> Int
```

```moonbit
test "certification failure round trip" {
  let detail = @lf_arith.CertificationFailureDetail::new(
    "exp",
    @lf_arith.CertificationStage::TargetRounding,
    @lf_arith.CertificationFailureReason::RefinementBudgetExhausted,
    53,
    384,
    -2,
  )
  let err = @lf_arith.ArithmeticError::certification_failure(detail)
  inspect(err.message, content="certified evaluation failed for exp")
  inspect(err.is_certification_failure(), content="true")
  guard err.certification_failure_detail() is Some(d) else { fail("no detail") }
  inspect(d.work_precision(), content="384")
  inspect(d.refinements(), content="0")
  inspect(d.stage() == @lf_arith.CertificationStage::TargetRounding, content="true")
}
```

## Diagnostics and outcomes

### `ArithmeticDiagnostics`

`ArithmeticDiagnostics` is a set of six condition flags that a successful
contextual operation may raise.

```mbti
pub struct ArithmeticDiagnostics {
  inexact : Bool
  rounded : Bool
  overflow : Bool
  underflow : Bool
  subnormal : Bool
  clamped : Bool
} derive(Eq, @debug.Debug)
```

| Flag | Raised when |
| --- | --- |
| `inexact` | the returned value differs from the exact result |
| `rounded` | the result was rounded to the context precision (possibly without loss) |
| `overflow` | the exact result exceeded the largest finite magnitude |
| `underflow` | the result is tiny (below the normal range) and inexact |
| `subnormal` | the result is below the normal range |
| `clamped` | the exponent was altered to fit the format |

The meanings follow IEEE 754 and the General Decimal Arithmetic conditions; a
backend raises only the flags it can detect.

### `ArithmeticDiagnostics::empty`

`ArithmeticDiagnostics::empty` returns the value with every flag `false`.

```mbti
pub fn ArithmeticDiagnostics::empty() -> ArithmeticDiagnostics
```

### `ArithmeticDiagnostics::new`

`ArithmeticDiagnostics::new` builds diagnostics from labelled flags, each
defaulting to `false`.

```mbti
pub fn ArithmeticDiagnostics::new(inexact? : Bool, rounded? : Bool, overflow? : Bool, underflow? : Bool, subnormal? : Bool, clamped? : Bool) -> ArithmeticDiagnostics
```

### `ArithmeticDiagnostics::combine`

`ArithmeticDiagnostics::combine` merges two diagnostics with a logical OR on
every flag.

```mbti
pub fn ArithmeticDiagnostics::combine(ArithmeticDiagnostics, ArithmeticDiagnostics) -> ArithmeticDiagnostics
```

`combine` is associative, commutative and idempotent, and `empty()` is its
identity, so folding the diagnostics of a computation gives the same result in
any order.

```moonbit
test "combine diagnostics" {
  let a = @lf_arith.ArithmeticDiagnostics::new(inexact=true, rounded=true)
  let b = @lf_arith.ArithmeticDiagnostics::new(underflow=true)
  let both = a.combine(b)
  inspect(both.inexact && both.underflow, content="true")
  inspect(both.overflow, content="false")
  inspect(a.combine(@lf_arith.ArithmeticDiagnostics::empty()) == a, content="true")
  inspect(a.combine(b) == b.combine(a), content="true")
}
```

### `ArithmeticOutcome`

`ArithmeticOutcome[T]` pairs the value of a successful contextual operation
with its diagnostics.

```mbti
pub struct ArithmeticOutcome[T] {
  value : T
  diagnostics : ArithmeticDiagnostics
} derive(Eq, @debug.Debug)
```

### `ArithmeticOutcome::exact`

`ArithmeticOutcome::exact` wraps a value with empty diagnostics.

```mbti
pub fn[T] ArithmeticOutcome::exact(T) -> ArithmeticOutcome[T]
```

### `ArithmeticOutcome::with_diagnostics`

`ArithmeticOutcome::with_diagnostics` wraps a value with the given
diagnostics.

```mbti
pub fn[T] ArithmeticOutcome::with_diagnostics(T, ArithmeticDiagnostics) -> ArithmeticOutcome[T]
```

```moonbit
test "build outcomes" {
  let exact = @lf_arith.ArithmeticOutcome::exact(2.5)
  inspect(exact.value, content="2.5")
  inspect(exact.diagnostics == @lf_arith.ArithmeticDiagnostics::empty(), content="true")
  let rounded = @lf_arith.ArithmeticOutcome::with_diagnostics(
    0.1,
    @lf_arith.ArithmeticDiagnostics::new(inexact=true, rounded=true),
  )
  inspect(rounded.diagnostics.inexact, content="true")
}
```

## Equality

`FpClass::equal`, `RoundingMode::equal`, `ArithmeticContext::equal`,
`ArithmeticDiagnostics::equal`, `ArithmeticOutcome::equal`,
`ArithmeticError::equal`, `ArithmeticErrorKind::equal`,
`CertificationStage::equal`, `CertificationFailureReason::equal` and
`CertificationFailureDetail::equal` are the derived `Eq` instances, promoted to
methods.

```mbti
pub fn FpClass::equal(FpClass, FpClass) -> Bool
pub fn RoundingMode::equal(RoundingMode, RoundingMode) -> Bool
pub fn ArithmeticContext::equal(ArithmeticContext, ArithmeticContext) -> Bool
pub fn ArithmeticDiagnostics::equal(ArithmeticDiagnostics, ArithmeticDiagnostics) -> Bool
pub fn[T : Eq] ArithmeticOutcome::equal(ArithmeticOutcome[T], ArithmeticOutcome[T]) -> Bool
pub fn ArithmeticError::equal(ArithmeticError, ArithmeticError) -> Bool
pub fn ArithmeticErrorKind::equal(ArithmeticErrorKind, ArithmeticErrorKind) -> Bool
pub fn CertificationStage::equal(CertificationStage, CertificationStage) -> Bool
pub fn CertificationFailureReason::equal(CertificationFailureReason, CertificationFailureReason) -> Bool
pub fn CertificationFailureDetail::equal(CertificationFailureDetail, CertificationFailureDetail) -> Bool
```

Equality is structural, field by field. Prefer the operators `==` and `!=`;
the method form exists for code that passes `equal` as a function.
`ArithmeticOutcome::equal` compares values with `T`'s `Eq`, so for `Double`
two NaN values make two outcomes unequal.

## Unchecked capability traits

Each unchecked trait is one capability with methods that return `Self`. The
trait states no domain: what happens outside the domain (NaN, infinity, abort
or wrap-around) is decided by the instance. All are `pub(open)`, so you can
implement them for your own types.

### `Sqrt`

`Sqrt` provides the square root.

```mbti
pub(open) trait Sqrt {
  fn sqrt(Self) -> Self
}
```

For `Float` and `Double`, `sqrt` follows IEEE 754: it returns NaN for negative
input, and $\sqrt{-0} = -0$.

```moonbit
fn[T : Add + Mul + @lf_arith.Sqrt] hypot_naive(x : T, y : T) -> T {
  @lf_arith.Sqrt::sqrt(x * x + y * y)
}

test "generic hypotenuse" {
  inspect(hypot_naive(3.0, 4.0), content="5")
  inspect(hypot_naive((5.0 : Float), (12.0 : Float)), content="13")
}
```

### `Cbrt`

`Cbrt` provides the real cube root.

```mbti
pub(open) trait Cbrt {
  fn cbrt(Self) -> Self
}
```

For `Float` and `Double` the cube root is real-valued on the whole line, so
$\sqrt[3]{-8} = -2$.

### `Radical`

`Radical` is the conjunction `Sqrt + Cbrt`; it has no methods of its own.

```mbti
pub(open) trait Radical : Sqrt + Cbrt {
}
```

```moonbit
fn[T : @lf_arith.Radical] roots(x : T) -> (T, T) {
  (@lf_arith.Sqrt::sqrt(x), @lf_arith.Cbrt::cbrt(x))
}

test "radical" {
  let (s, c) = roots(64.0)
  inspect(s, content="8")
  inspect(c, content="4")
  inspect(@lf_arith.Cbrt::cbrt(-8.0), content="-2")
}
```

### `Exponential`

`Exponential` provides $e^x$ (`exp`) and $2^x$ (`exp2`).

```mbti
pub(open) trait Exponential {
  fn exp(Self) -> Self
  fn exp2(Self) -> Self
}
```

### `Logarithmic`

`Logarithmic` provides the natural (`ln`), binary (`log2`) and decimal
(`log10`) logarithms.

```mbti
pub(open) trait Logarithmic {
  fn ln(Self) -> Self
  fn log2(Self) -> Self
  fn log10(Self) -> Self
}
```

For `Float` and `Double`, a negative argument gives NaN and zero gives
$-\infty$.

```moonbit
test "exponentials and logarithms" {
  inspect(@lf_arith.Exponential::exp(0.0), content="1")
  inspect(@lf_arith.Exponential::exp2(10.0), content="1024")
  inspect(@lf_arith.Logarithmic::log2(1024.0), content="10")
  inspect(@lf_arith.Logarithmic::log10(1000.0), content="3")
  inspect(@lf_arith.Logarithmic::ln(1.0), content="0")
}
```

### `Power`

`Power` raises a base to an exponent of the same type.

```mbti
pub(open) trait Power {
  fn pow(Self, Self) -> Self
}
```

| Instance | Semantics |
| --- | --- |
| `Float`, `Double` | the C `pow` function: real power, NaN for a negative base with a non-integer exponent |
| `Int`, `Int16`, `Int64` | exact power in $\mathbb{Z}/2^k$ (wraps on overflow); **aborts** on a negative exponent |
| `UInt`, `UInt16`, `UInt64` | exact power in $\mathbb{Z}/2^k$ (wraps on overflow) |
| `BigInt` | exact power; **aborts** on a negative exponent |

The integer instances use binary exponentiation, $O(\log n)$ multiplications.
$x^0 = 1$ for every base, including $0^0$.

For the integer instances `pow` is the action of the exponent, read as a
natural number, on the multiplicative monoid of `Self`:
$x^{m+n} = x^m x^n$ and $x^{mn} = (x^m)^n$ hold whenever $m + n$ and $mn$
are computed without wrapping. The exponent is itself a value of `Self`, so a
wrapped exponent sum breaks the first law: for `UInt`,
`pow(2U, 0xFFFFFFFFU) * pow(2U, 1U)` is `0`, while the wrapped sum `0U` gives
`pow(2U, 0U) == 1U`. The [design page](../design/core.md#laws-of-power)
derives which laws hold.

```moonbit
test "power" {
  inspect(@lf_arith.Power::pow(2, 10), content="1024")
  inspect(@lf_arith.Power::pow(0, 0), content="1")
  inspect(@lf_arith.Power::pow(2U, 32U), content="0")
  inspect(@lf_arith.Power::pow(2.0, 0.5), content="1.4142135623730951")
  inspect(@lf_arith.Power::pow(10N, 20N), content="100000000000000000000")
  // the exponent sum 0xFFFFFFFF + 1 wraps to 0, but 2^0 is 1
  inspect(@lf_arith.Power::pow(2U, 0xFFFFFFFFU) * @lf_arith.Power::pow(2U, 1U), content="0")
}
```

### `Trigonometric`

`Trigonometric` provides `sin`, `cos` and `tan` of an angle in radians (for
the shipped instances).

```mbti
pub(open) trait Trigonometric {
  fn sin(Self) -> Self
  fn cos(Self) -> Self
  fn tan(Self) -> Self
}
```

### `InverseTrigonometric`

`InverseTrigonometric` provides the principal branches `asin`, `acos`, `atan`
and the two-argument `atan2(y, x)`.

```mbti
pub(open) trait InverseTrigonometric {
  fn asin(Self) -> Self
  fn acos(Self) -> Self
  fn atan(Self) -> Self
  fn atan2(Self, Self) -> Self
}
```

For `Float` and `Double` the ranges are $[-\pi/2, \pi/2]$ for `asin` and
`atan`, $[0, \pi]$ for `acos`, and $[-\pi, \pi]$ for `atan2`, which returns
the angle of the point $(x, y)$; on the negative $x$ axis the sign of a zero
$y$ selects $\pi$ or $-\pi$.

```moonbit
test "trigonometry" {
  inspect(@lf_arith.Trigonometric::sin(0.0), content="0")
  inspect(@lf_arith.Trigonometric::cos(0.0), content="1")
  let pi : Double = @lf_arith.Constants::pi()
  inspect(@lf_arith.InverseTrigonometric::atan2(0.0, -1.0) == pi, content="true")
  inspect(@lf_arith.InverseTrigonometric::acos(1.0), content="0")
}
```

### `Hyperbolic`

`Hyperbolic` provides `sinh`, `cosh` and `tanh`.

```mbti
pub(open) trait Hyperbolic {
  fn sinh(Self) -> Self
  fn cosh(Self) -> Self
  fn tanh(Self) -> Self
}
```

### `InverseHyperbolic`

`InverseHyperbolic` provides `asinh`, `acosh` and `atanh`.

```mbti
pub(open) trait InverseHyperbolic {
  fn asinh(Self) -> Self
  fn acosh(Self) -> Self
  fn atanh(Self) -> Self
}
```

For `Float` and `Double`, `acosh` is defined on $[1, \infty)$ and `atanh` on
$[-1, 1]$; outside them the result is NaN, and $\operatorname{atanh}(\pm 1) = \pm\infty$.

```moonbit
test "hyperbolic" {
  inspect(@lf_arith.Hyperbolic::cosh(0.0), content="1")
  inspect(@lf_arith.Hyperbolic::tanh(0.0), content="0")
  inspect(@lf_arith.InverseHyperbolic::acosh(1.0), content="0")
  inspect(@lf_arith.InverseHyperbolic::atanh(2.0).is_nan(), content="true")
}
```

### `Constants`

`Constants` provides $\pi$, $\tau = 2\pi$ and $e$ in `Self`.

```mbti
pub(open) trait Constants {
  fn pi() -> Self
  fn tau() -> Self
  fn e() -> Self
}
```

The methods take no argument, so call them with the target type known.
For `Double`, `pi` is `@math.PI`, `tau` is `2.0 * @math.PI` (exact, since
doubling only changes the exponent) and `e` is `exp(1.0)`. For `Float`, `pi`
and `tau` are the `Double` values rounded to `Float`, and `e` is the `Float`
exponential of `1`; all three are the `Float` nearest to the constant.

```moonbit
test "constants" {
  let pi : Double = @lf_arith.Constants::pi()
  let tau : Double = @lf_arith.Constants::tau()
  let e : Float = @lf_arith.Constants::e()
  inspect(tau == 2.0 * pi, content="true")
  inspect(pi, content="3.141592653589793")
  inspect(e > (2.71 : Float), content="true")
}
```

## Checked capability traits

A checked trait returns `Result[_, ArithmeticError]`, so a rejected operation
is a value the caller must handle. Methods that may depend on precision take an
`ArithmeticContext`; the built-in `Float` and `Double` instances accept it but
do not read it.

### `SqrtChecked`

`SqrtChecked` computes a square root or reports a domain error.

```mbti
pub(open) trait SqrtChecked {
  fn sqrt_checked(Self, ArithmeticContext) -> Result[Self, ArithmeticError]
}
```

The domain is defined by each instance; the trait does not assume an order.
For `Float` and `Double`, an argument $x < 0$ (including $-\infty$) gives
`DomainError`; $-0$, $+\infty$ and NaN pass through to `Sqrt::sqrt`. A NaN
therefore returns as `Ok(NaN)`.

```moonbit
test "checked square root" {
  let ctx = @lf_arith.ArithmeticContext::decimal64()
  inspect(@lf_arith.SqrtChecked::sqrt_checked(2.25, ctx).unwrap(), content="1.5")
  guard @lf_arith.SqrtChecked::sqrt_checked(-1.0, ctx) is Err(err) else {
    fail("expected a domain error")
  }
  inspect(err.is_domain_error(), content="true")
  inspect(err.message, content="square root is undefined for negative real inputs")
}
```

### `DivChecked`

`DivChecked` divides or reports why the quotient is undefined.

```mbti
pub(open) trait DivChecked {
  fn div_checked(Self, Self, ArithmeticContext) -> Result[Self, ArithmeticError]
}
```

For `Float` and `Double`, NaN operands propagate as `Ok(NaN)` before the
division checks. The remaining cases are:

| Case | Result |
| --- | --- |
| $\pm 0 / \pm 0$ | `DomainError` (`zero divided by zero is undefined`) |
| $\pm\infty / \pm\infty$ | `DomainError` (`infinity divided by infinity is undefined`) |
| finite non-zero $x / \pm 0$ | `DivisionByZero` (`division by zero`) |
| $\pm\infty / \pm 0$ | `Ok(\pm\infty)` with the quotient's sign |
| otherwise | `Ok(x / y)`, with IEEE NaN propagation |

```moonbit
test "checked division" {
  let ctx = @lf_arith.ArithmeticContext::decimal64()
  inspect(@lf_arith.DivChecked::div_checked(10.0, 4.0, ctx).unwrap(), content="2.5")
  let zero_by_zero = @lf_arith.DivChecked::div_checked(0.0, 0.0, ctx)
  inspect(zero_by_zero is Err(e) && e.is_domain_error(), content="true")
  let one_by_zero = @lf_arith.DivChecked::div_checked(1.0, -0.0, ctx)
  inspect(one_by_zero is Err(e) && e.is_division_by_zero(), content="true")
}
```

### `CompareChecked`

`CompareChecked` compares two values or reports that they are unordered.

```mbti
pub(open) trait CompareChecked {
  fn compare_checked(Self, Self) -> Result[Int, ArithmeticError]
}
```

On ordered inputs the result is `-1`, `0` or `1`. For `Float` and `Double`, a
NaN operand gives `UnorderedComparison`, and $-0$ and $+0$ compare equal.

```moonbit
test "checked comparison" {
  inspect(@lf_arith.CompareChecked::compare_checked(1.0, 2.0).unwrap(), content="-1")
  inspect(@lf_arith.CompareChecked::compare_checked(-0.0, 0.0).unwrap(), content="0")
  let nan = 0.0 / 0.0
  let r = @lf_arith.CompareChecked::compare_checked(nan, 1.0)
  inspect(r is Err(e) && e.is_unordered_comparison(), content="true")
}
```

### `PowNatChecked`

`PowNatChecked` raises a value to a non-negative integer power.

```mbti
pub(open) trait PowNatChecked {
  fn pow_nat_checked(Self, UInt, ArithmeticContext) -> Result[Self, ArithmeticError]
}
```

$x^0$ is the multiplicative identity for non-NaN inputs, including $0^0$. For
`Float` and `Double`, a NaN base returns `Ok(NaN)` even when the exponent is
zero. The instances never return an error: overflow returns the signed infinity
in `Ok`, and underflow follows IEEE arithmetic. They use binary exponentiation
with at most $2\lfloor\log_2 n\rfloor$ rounded multiplications. The [design
page](../design/core.md#error-bound-of-binary-powering) bounds the rounding
error.

### `PowIntChecked`

`PowIntChecked` raises a value to a signed integer power.

```mbti
pub(open) trait PowIntChecked {
  fn pow_int_checked(Self, Int, ArithmeticContext) -> Result[Self, ArithmeticError]
}
```

A negative exponent means a reciprocal. For `Float` and `Double`, a NaN base
returns `Ok(NaN)`, including when the exponent is zero. Overflow during the
positive power calculation returns the signed infinity in `Ok`. A zero base
with a negative exponent returns `DivisionByZero` for `Float` and `Double`; an
enclosure implementation may return a documented enclosure instead.

- $x^0 = 1$ for a non-NaN base;
- $x^n$ for $n > 0$ is `pow_nat_checked(x, n)`;
- $x^{-n}$ is `DivisionByZero` when $x = \pm 0$, and otherwise
  `div_checked(1, x^n)`. The most negative `Int` exponent is handled
  without negation overflow.

> [!NOTE]
> Because the reciprocal is taken after the power, a tiny base whose power
> underflows to zero, such as `pow_int_checked(1.0e-200, -2, ctx)`, returns a
> `DivisionByZero` error even though the exact result $10^{400}$ only
> overflows.

```moonbit
test "checked integer powers" {
  let ctx = @lf_arith.ArithmeticContext::decimal64()
  inspect(@lf_arith.PowNatChecked::pow_nat_checked(3.0, 4U, ctx).unwrap(), content="81")
  inspect(@lf_arith.PowNatChecked::pow_nat_checked(0.0, 0U, ctx).unwrap(), content="1")
  inspect(@lf_arith.PowIntChecked::pow_int_checked(2.0, -3, ctx).unwrap(), content="0.125")
  let r = @lf_arith.PowIntChecked::pow_int_checked(0.0, -1, ctx)
  inspect(r is Err(e) && e.is_division_by_zero(), content="true")
}
```

### `ParseChecked`

`ParseChecked` parses text into `Self` under a context.

```mbti
pub(open) trait ParseChecked {
  fn parse_checked(String, ArithmeticContext) -> Result[Self, ArithmeticError]
}
```

The context lets a decimal backend round the parsed value to its precision.
Failures use `ParseError`, or `FormatError` when the text is well formed but
the format cannot hold it. This package ships no instance; parsing belongs to
backends with a textual format, such as decimal types.

## Contextual capability traits

A contextual trait returns `Result[ArithmeticOutcome[Self], ArithmeticError]`.
`Err` means the operation was rejected; `Ok` carries the value and the
diagnostics a backend detected while producing it.

> [!IMPORTANT]
> The built-in `Float` and `Double` instances ignore the context and do not
> detect rounding, overflow or underflow. Except for `Float`'s
> `IntegralContextual`, they return `ArithmeticOutcome::exact`, so their empty
> diagnostics mean "nothing detected", not "the result is exact": `0.1 + 0.2`
> returns `0.30000000000000004` with empty diagnostics.

### `AddContextual`, `SubContextual`, `MulContextual`, `DivContextual`

These four traits are the contextual forms of `+`, `-`, `*` and `/`.

```mbti
pub(open) trait AddContextual {
  fn add_contextual(Self, Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
pub(open) trait SubContextual {
  fn sub_contextual(Self, Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
pub(open) trait MulContextual {
  fn mul_contextual(Self, Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
pub(open) trait DivContextual {
  fn div_contextual(Self, Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

A context-faithful backend returns $\operatorname{fl}(x \circ y)$, the exact
result rounded under the context, and sets the diagnostics that the rounding
caused. For `Float` and `Double`, add, sub and mul never fail; `div_contextual`
fails exactly when `DivChecked::div_checked` does.

```moonbit
test "contextual arithmetic" {
  let ctx = @lf_arith.ArithmeticContext::decimal64()
  let q = @lf_arith.DivContextual::div_contextual(10.0, 4.0, ctx).unwrap()
  inspect(q.value, content="2.5")
  let s = @lf_arith.AddContextual::add_contextual(0.1, 0.2, ctx).unwrap()
  inspect(s.value, content="0.30000000000000004")
  inspect(s.diagnostics.inexact, content="false")
  inspect(@lf_arith.DivContextual::div_contextual(1.0, 0.0, ctx) is Err(_), content="true")
}
```

### `AbsContextual`

`AbsContextual` is the contextual absolute value.

```mbti
pub(open) trait AbsContextual {
  fn abs_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

A backend may round when the context precision is below the operand's. For
`Float` and `Double` it is the exact IEEE `abs`.

### `SqrtContextual`

`SqrtContextual` is the contextual square root.

```mbti
pub(open) trait SqrtContextual {
  fn sqrt_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

For `Float` and `Double` it fails exactly when `SqrtChecked::sqrt_checked`
does.

### `ExpContextual`

`ExpContextual` is the contextual natural exponential.

```mbti
pub(open) trait ExpContextual {
  fn exp_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

For `Float` and `Double` it is `Exponential::exp` wrapped in an exact outcome.

```moonbit
test "contextual sqrt, abs and exp" {
  let ctx = @lf_arith.ArithmeticContext::decimal64()
  inspect(@lf_arith.SqrtContextual::sqrt_contextual(9.0, ctx).unwrap().value, content="3")
  inspect(@lf_arith.SqrtContextual::sqrt_contextual(-9.0, ctx) is Err(_), content="true")
  inspect(@lf_arith.AbsContextual::abs_contextual(-2.0, ctx).unwrap().value, content="2")
  inspect(@lf_arith.ExpContextual::exp_contextual(0.0, ctx).unwrap().value, content="1")
}
```

### `IntegralContextual`

`IntegralContextual` embeds a MoonBit `Int` into `Self` under a context.

```mbti
pub(open) trait IntegralContextual {
  fn from_int_contextual(Int, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

The source is always `Int`; wider or arbitrary-precision sources need separate
capabilities. A backend may reject a context it does not support. For `Double`
every `Int` is exact. For `Float`, an integer with $|n| > 2^{24}$ that is not a
multiple of the spacing at its magnitude is rounded, and the outcome then has
`inexact` and `rounded` set.

```moonbit
test "embed integers" {
  let ctx = @lf_arith.ArithmeticContext::new(24)
  let exact : @lf_arith.ArithmeticOutcome[Float] = @lf_arith.IntegralContextual::from_int_contextual(
    16_777_216, ctx,
  ).unwrap()
  inspect(exact.diagnostics.inexact, content="false")
  let rounded : @lf_arith.ArithmeticOutcome[Float] = @lf_arith.IntegralContextual::from_int_contextual(
    16_777_217, ctx,
  ).unwrap()
  inspect(rounded.value, content="16777216")
  inspect(rounded.diagnostics.inexact && rounded.diagnostics.rounded, content="true")
}
```

### `AdjacentContextual`

`AdjacentContextual` steps to the neighbouring representable value.

```mbti
pub(open) trait AdjacentContextual {
  fn next_plus_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
  fn next_minus_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
  fn next_toward_contextual(Self, Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

`next_plus_contextual(x)` is the least representable value greater than $x$
and `next_minus_contextual(x)` the greatest one less than $x$.
`next_toward_contextual(x, t)` steps from $x$ toward $t$; when $x = t$ it
returns $t$, so `next_toward(0.0, -0.0)` is $-0$. A backend whose
representable set depends on the context reports range conditions in the
diagnostics.

For `Float` and `Double` the representable set is the fixed IEEE binary format
and the result is always exact:

| Input | `next_plus` | `next_minus` |
| --- | --- | --- |
| $\pm 0$ | smallest positive subnormal | smallest negative subnormal |
| largest finite | $+\infty$ | predecessor |
| $+\infty$ | $+\infty$ | largest finite |
| $-\infty$ | $-(\text{largest finite})$ | $-\infty$ |
| NaN | NaN | NaN |

`next_toward` returns NaN if either operand is NaN.

```moonbit
test "adjacent doubles" {
  let ctx = @lf_arith.ArithmeticContext::new(53)
  let up = @lf_arith.AdjacentContextual::next_plus_contextual(1.0, ctx).unwrap()
  inspect(up.value - 1.0, content="2.220446049250313e-16")
  let tiny = @lf_arith.AdjacentContextual::next_plus_contextual(0.0, ctx).unwrap()
  inspect(tiny.value.reinterpret_as_uint64(), content="1")
  let down = @lf_arith.AdjacentContextual::next_toward_contextual(1.0, 0.0, ctx).unwrap()
  inspect(1.0 - down.value, content="1.1102230246251565e-16")
}
```

### `ConstantsContextual`

`ConstantsContextual` produces $\pi$, $\tau$ and $e$ under a context.

```mbti
pub(open) trait ConstantsContextual {
  fn pi_contextual(ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
  fn tau_contextual(ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
  fn e_contextual(ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

Implement it only when the constants honour the context and the diagnostics
are meaningful. A proof-backed backend returns a `CertificationFailure` error
when it cannot certify the target rounding. `Float` and `Double` do not
implement it; see the [design page](../design/core.md#native-scalars-implement-only-what-they-can-honour).

### `HyperbolicContextual`

`HyperbolicContextual` provides `sinh`, `cosh` and `tanh` under a context.

```mbti
pub(open) trait HyperbolicContextual {
  fn sinh_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
  fn cosh_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
  fn tanh_contextual(Self, ArithmeticContext) -> Result[ArithmeticOutcome[Self], ArithmeticError]
}
```

The same rule as for `ConstantsContextual` applies, and `Float` and `Double`
do not implement it either.

### `NumericFormatContextual`

`NumericFormatContextual` describes the numeric format of `Self` under a
context: its distinguished values and the class of a value.

```mbti
pub(open) trait NumericFormatContextual {
  fn zero_contextual(ArithmeticContext) -> Self
  fn one_contextual(ArithmeticContext) -> Self
  fn epsilon_contextual(ArithmeticContext) -> Self
  fn min_normal_contextual(ArithmeticContext) -> Self
  fn max_finite_contextual(ArithmeticContext) -> Self
  fn classify_contextual(Self) -> FpClass
}
```

`epsilon_contextual` is the machine epsilon $\varepsilon = \beta^{1-p}$, the
distance from $1$ to the next larger representable value; the unit roundoff of
round-to-nearest is $u = \varepsilon / 2$. These methods do not fail. For the
fixed formats the context is ignored:

| Method | `Float` (binary32) | `Double` (binary64) |
| --- | --- | --- |
| `epsilon_contextual` | $2^{-23} \approx 1.19 \times 10^{-7}$ | $2^{-52} \approx 2.22 \times 10^{-16}$ |
| `min_normal_contextual` | $2^{-126} \approx 1.18 \times 10^{-38}$ | $2^{-1022} \approx 2.23 \times 10^{-308}$ |
| `max_finite_contextual` | $(2 - 2^{-23})\,2^{127} \approx 3.40 \times 10^{38}$ | $(2 - 2^{-52})\,2^{1023} \approx 1.80 \times 10^{308}$ |

```moonbit
test "format constants" {
  let ctx = @lf_arith.ArithmeticContext::new(53)
  let eps : Double = @lf_arith.NumericFormatContextual::epsilon_contextual(ctx)
  inspect(eps, content="2.220446049250313e-16")
  let one : Double = @lf_arith.NumericFormatContextual::one_contextual(ctx)
  inspect(one + eps > one, content="true")
  inspect(one + eps / 2.0 == one, content="true")
}
```

## Enclosure relations

An enclosure is a value that stands for an unknown real number known to lie in
a set, such as an interval or a ball. These five traits relate two enclosures
$X$ and $Y$. They are relations, not an order: for overlapping enclosures both
`definitely_lt(X, Y)` and `definitely_lt(Y, X)` are false. Read them as
statements about every pair of points $x \in X$, $y \in Y$. This package ships
no instance; interval and ball backends implement them.
The [design page](../design/core.md#enclosures-and-three-valued-comparison)
derives the interval formulas below.

| Trait | Holds when | For intervals $X = [a, b]$, $Y = [c, d]$ |
| --- | --- | --- |
| `Contains` | $Y \subseteq X$ | $a \le c$ and $d \le b$ |
| `Overlaps` | $X \cap Y \ne \emptyset$ | $a \le d$ and $c \le b$ |
| `DefinitelyLt` | $x < y$ for all $x \in X$, $y \in Y$ | $b < c$ |
| `DefinitelyLe` | $x \le y$ for all $x \in X$, $y \in Y$ | $b \le c$ |
| `MaybeEq` | $x = y$ for some $x \in X$, $y \in Y$ | $a \le d$ and $c \le b$ |

### `Contains`

`Contains` tests whether the first enclosure contains the second.

```mbti
pub(open) trait Contains {
  fn contains(Self, Self) -> Bool
}
```

### `Overlaps`

`Overlaps` tests whether two enclosures share a point.

```mbti
pub(open) trait Overlaps {
  fn overlaps(Self, Self) -> Bool
}
```

### `DefinitelyLt`

`DefinitelyLt` tests whether every point of the first enclosure is less than
every point of the second.

```mbti
pub(open) trait DefinitelyLt {
  fn definitely_lt(Self, Self) -> Bool
}
```

### `DefinitelyLe`

`DefinitelyLe` tests whether every point of the first enclosure is at most
every point of the second.

```mbti
pub(open) trait DefinitelyLe {
  fn definitely_le(Self, Self) -> Bool
}
```

### `MaybeEq`

`MaybeEq` tests whether the two enclosures may denote the same number.

```mbti
pub(open) trait MaybeEq {
  fn maybe_eq(Self, Self) -> Bool
}
```

For real enclosures `maybe_eq` coincides with `overlaps`; the trait exists so
that generic code can ask the question it means.

```moonbit
struct Iv {
  lo : Double
  hi : Double
}

impl @lf_arith.Contains for Iv with contains(x, y) { x.lo <= y.lo && y.hi <= x.hi }

impl @lf_arith.DefinitelyLt for Iv with definitely_lt(x, y) { x.hi < y.lo }

impl @lf_arith.DefinitelyLe for Iv with definitely_le(x, y) { x.hi <= y.lo }

impl @lf_arith.MaybeEq for Iv with maybe_eq(x, y) { x.lo <= y.hi && y.lo <= x.hi }

test "interval relations" {
  let x = Iv::{ lo: 1.0, hi: 2.0 }
  let y = Iv::{ lo: 1.5, hi: 3.0 }
  let z = Iv::{ lo: 2.5, hi: 3.0 }
  inspect(@lf_arith.DefinitelyLt::definitely_lt(x, z), content="true")
  inspect(@lf_arith.DefinitelyLt::definitely_lt(x, y), content="false")
  inspect(@lf_arith.DefinitelyLt::definitely_lt(y, x), content="false")
  inspect(@lf_arith.MaybeEq::maybe_eq(x, y), content="true")
  inspect(@lf_arith.Contains::contains(y, z), content="true")
  inspect(@lf_arith.DefinitelyLe::definitely_le(x, Iv::{ lo: 2.0, hi: 4.0 }), content="true")
}
```

## Shipped instances

| Trait | `Float`, `Double` | integers and `BigInt` |
| --- | --- | --- |
| `Sqrt`, `Cbrt`, `Radical`, `Exponential`, `Logarithmic`, `Trigonometric`, `InverseTrigonometric`, `Hyperbolic`, `InverseHyperbolic`, `Constants` | yes | no |
| `Power` | yes | `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `BigInt` |
| `SqrtChecked`, `DivChecked`, `CompareChecked`, `PowNatChecked`, `PowIntChecked` | yes | no |
| `ParseChecked` | no | no |
| `AddContextual`, `SubContextual`, `MulContextual`, `DivContextual`, `AbsContextual`, `SqrtContextual`, `ExpContextual`, `IntegralContextual`, `AdjacentContextual`, `NumericFormatContextual` | yes | no |
| `ConstantsContextual`, `HyperbolicContextual` | no | no |
| `Contains`, `Overlaps`, `DefinitelyLt`, `DefinitelyLe`, `MaybeEq` | no | no |

The `Float` and `Double` elementary functions come from
[`Kaida-Amethyst/math`](https://mooncakes.io/docs/Kaida-Amethyst/math), which
does not promise correct rounding.

## Deprecated

Before MoonBit 0.10, implementing a trait for a type silently made its methods
callable with dot syntax. These implicit method forms are still callable on the
package's public types, but are deprecated and hidden from the interface file:

| Deprecated form | Types | Replacement |
| --- | --- | --- |
| `x.not_equal(y)` | every type listed under [Equality](#equality) | `x != y` |
| `x.to_repr()` | `FpClass`, `ArithmeticDiagnostics`, `ArithmeticOutcome` | `Repr(x)` or `@debug.to_string(x)` |
