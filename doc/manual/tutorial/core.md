# core tutorial

This tutorial gets you from installing `arithmetic` to writing numeric code
that states exactly what it needs: generic functions over analytic
capabilities, checked operations that turn invalid input into values you can
handle, contextual operations that report how a result was rounded, and your
own types plugged into the same traits. Every example is a test that you can
paste into a `_test.mbt` file and run with `moon test`; the expected output is
written in the `inspect` calls.

## Quick start

Add the package to your module:

```sh
moon add Luna-Flow/arithmetic@0.5.0
```

Import it in the `moon.pkg` of the package that uses it. Luna Flow code uses
the alias `@lf_arith`:

```moonbit nocheck
import {
  "Luna-Flow/arithmetic" @lf_arith,
}
```

The smallest useful program asks for one capability and uses it on two
number types:

```moonbit
fn[T : Add + Mul + @lf_arith.Sqrt] hypot(x : T, y : T) -> T {
  @lf_arith.Sqrt::sqrt(x * x + y * y)
}

test "quick start" {
  inspect(hypot(3.0, 4.0), content="5")
  inspect(hypot((6.0 : Float), (8.0 : Float)), content="10")
}
```

`hypot` works for any type with `+`, `*` and a square root, and for nothing
else. That is the idea of the whole package: an algorithm names the smallest
set of capabilities it uses.

## Everyday tasks

### Call an elementary function generically

The unchecked traits (`Sqrt`, `Exponential`, `Logarithmic`, `Trigonometric`,
...) return `Self` and leave special cases to the type. Call them through the
trait, `@lf_arith.Trigonometric::sin(x)`, so the code stays generic:

```moonbit
fn[T : Add + Mul + @lf_arith.Trigonometric] sin_plus_cos_squared(x : T) -> T {
  let s = @lf_arith.Trigonometric::sin(x)
  let c = @lf_arith.Trigonometric::cos(x)
  s * s + c * c
}

test "pythagorean identity" {
  let v = sin_plus_cos_squared(0.7)
  inspect((v - 1.0).abs() < 1.0e-15, content="true")
  let pi : Double = @lf_arith.Constants::pi()
  inspect(@lf_arith.Logarithmic::ln(@lf_arith.Exponential::exp(pi)) == pi, content="true")
}
```

Constants have no argument, so annotate the type you want, as with `pi`
above.

### Turn invalid input into an error value

A checked trait returns `Result[_, ArithmeticError]`. Use it when a negative
square root or a zero divisor is a case your caller must handle rather than a
NaN to discover later. This quadratic solver uses the cancellation-free form
$q = -\tfrac12\bigl(b + \operatorname{sign}(b)\sqrt{b^2 - 4ac}\bigr)$,
$x_1 = q/a$, $x_2 = c/q$:

```moonbit
fn real_roots(
  a : Double,
  b : Double,
  c : Double,
) -> Result[(Double, Double), @lf_arith.ArithmeticError] {
  let ctx = @lf_arith.ArithmeticContext::new(53)
  let s = match @lf_arith.SqrtChecked::sqrt_checked(b * b - 4.0 * a * c, ctx) {
    Ok(s) => s
    Err(e) => return Err(e)
  }
  let q = if b >= 0.0 { -0.5 * (b + s) } else { -0.5 * (b - s) }
  let x1 = match @lf_arith.DivChecked::div_checked(q, a, ctx) {
    Ok(x) => x
    Err(e) => return Err(e)
  }
  @lf_arith.DivChecked::div_checked(c, q, ctx).map(x2 => (x1, x2))
}

test "real roots" {
  guard real_roots(1.0, -3.0, 2.0) is Ok((x1, x2)) else { fail("no roots") }
  inspect(x1, content="2")
  inspect(x2, content="1")
  guard real_roots(1.0, 0.0, 1.0) is Err(e) else { fail("expected an error") }
  inspect(e.is_domain_error(), content="true")
  guard real_roots(0.0, 2.0, -4.0) is Err(e) else { fail("expected an error") }
  inspect(e.is_division_by_zero(), content="true")
}
```

The error kind tells the caller what went wrong: no real roots is a
`DomainError`, a degenerate equation with $a = 0$ is a `DivisionByZero`.

### Compare values that may be NaN

`<` on `Double` returns `false` whenever NaN is involved, so a sort or a
maximum silently goes wrong. `CompareChecked` makes the unordered case an
error:

```moonbit
fn checked_max(xs : Array[Double]) -> Result[Double, @lf_arith.ArithmeticError] {
  let mut best = xs[0]
  for x in xs {
    match @lf_arith.CompareChecked::compare_checked(x, best) {
      Ok(1) => best = x
      Ok(_) => ()
      Err(e) => return Err(e)
    }
  }
  Ok(best)
}

test "checked maximum" {
  inspect(checked_max([3.0, 7.5, -1.0]).unwrap(), content="7.5")
  let r = checked_max([3.0, 0.0 / 0.0, 7.5])
  inspect(r is Err(e) && e.is_unordered_comparison(), content="true")
}
```

### Collect diagnostics across several steps

A contextual operation returns an `ArithmeticOutcome`: the value plus the
diagnostics raised while computing it. To chain steps, pass the value on and
`combine` the diagnostics. A small helper does this for any contextual
operation:

```moonbit
fn[A, B] and_then(
  r : Result[@lf_arith.ArithmeticOutcome[A], @lf_arith.ArithmeticError],
  next : (A) -> Result[@lf_arith.ArithmeticOutcome[B], @lf_arith.ArithmeticError],
) -> Result[@lf_arith.ArithmeticOutcome[B], @lf_arith.ArithmeticError] {
  match r {
    Err(e) => Err(e)
    Ok(first) =>
      next(first.value).map(second => @lf_arith.ArithmeticOutcome::with_diagnostics(
        second.value,
        first.diagnostics.combine(second.diagnostics),
      ))
  }
}

test "diagnostics survive a chain" {
  let ctx = @lf_arith.ArithmeticContext::new(24)
  let embedded : Result[@lf_arith.ArithmeticOutcome[Float], _] = @lf_arith.IntegralContextual::from_int_contextual(
    16_777_217, ctx,
  )
  let root = and_then(embedded, x => @lf_arith.SqrtContextual::sqrt_contextual(x, ctx)).unwrap()
  inspect(root.value, content="4096")
  inspect(root.diagnostics.inexact, content="true")
}
```

$2^{24} + 1$ does not fit in a `Float`, so the embedding rounds it to $2^{24}$
and raises `inexact`. The square root of $2^{24}$ is exact, but the combined
diagnostics still remember the earlier rounding: flags only accumulate.

### Walk the representable numbers

`AdjacentContextual` returns the neighbouring representable value. The gap
between a number and its successor is one *unit in the last place* (ulp),
which tells you how fine the format is at that magnitude:

```moonbit
fn ulp(x : Double) -> Double {
  let ctx = @lf_arith.ArithmeticContext::new(53)
  @lf_arith.AdjacentContextual::next_plus_contextual(x, ctx).unwrap().value - x
}

test "ulp grows with magnitude" {
  inspect(ulp(1.0), content="2.220446049250313e-16")
  inspect(ulp(1024.0), content="2.2737367544323206e-13")
  inspect(ulp(9007199254740992.0), content="2")
}
```

At $2^{53}$ consecutive doubles are $2$ apart, so integers above it are no
longer all representable.

### Report a certification failure

A proof-backed backend reports that it could not certify a result with a
`CertificationFailure` error. Handle it separately from domain errors: the
input was valid, and a larger budget may succeed.

```moonbit
fn describe(err : @lf_arith.ArithmeticError) -> String {
  match err.certification_failure_detail() {
    Some(d) =>
      "\{d.operation()}: gave up after \{d.refinements()} refinements at \{d.work_precision()} bits"
    None => err.message
  }
}

test "describe errors" {
  let detail = @lf_arith.CertificationFailureDetail::new(
    "sinh",
    @lf_arith.CertificationStage::TargetRounding,
    @lf_arith.CertificationFailureReason::RefinementBudgetExhausted,
    53,
    1024,
    5,
  )
  inspect(
    describe(@lf_arith.ArithmeticError::certification_failure(detail)),
    content="sinh: gave up after 5 refinements at 1024 bits",
  )
  inspect(
    describe(@lf_arith.ArithmeticError::domain_error("negative input")),
    content="negative input",
  )
}
```

## Going further

### Implement a contextual trait for your own type

Implement a capability only when you can honour it. This fixed-point type
stores hundredths; multiplying two values produces ten-thousandths, which must
be rounded back. The implementation follows the context's rounding mode,
reports the rounding in the diagnostics, and rejects modes it does not
support instead of ignoring them:

```moonbit
struct Cents(Int) derive(Eq, Debug)

impl @lf_arith.MulContextual for Cents with mul_contextual(x, y, ctx) {
  let raw = x.0 * y.0
  let q = raw / 100
  let r = raw % 100
  if r == 0 {
    return Ok(@lf_arith.ArithmeticOutcome::exact(Cents(q)))
  }
  let away = if raw < 0 { q - 1 } else { q + 1 }
  let rounded = match ctx.rounding {
    TowardZero => q
    AwayFromZero => away
    ToNearestEven => {
      let twice = r.abs() * 2
      if twice > 100 || (twice == 100 && q % 2 != 0) { away } else { q }
    }
    _ =>
      return Err(
        @lf_arith.ArithmeticError::unsupported("Cents rounds only toward or away from zero, or to nearest"),
      )
  }
  let flags = @lf_arith.ArithmeticDiagnostics::new(inexact=true, rounded=true)
  Ok(@lf_arith.ArithmeticOutcome::with_diagnostics(Cents(rounded), flags))
}

test "fixed-point multiplication" {
  let nearest = @lf_arith.ArithmeticContext::new(2)
  let exact = @lf_arith.MulContextual::mul_contextual(Cents(150), Cents(150), nearest).unwrap()
  debug_inspect(exact.value, content="Cents(225)")
  inspect(exact.diagnostics.inexact, content="false")
  let tie_down = @lf_arith.MulContextual::mul_contextual(Cents(5), Cents(10), nearest).unwrap()
  debug_inspect(tie_down.value, content="Cents(0)")
  let tie_up = @lf_arith.MulContextual::mul_contextual(Cents(15), Cents(10), nearest).unwrap()
  debug_inspect(tie_up.value, content="Cents(2)")
  inspect(tie_up.diagnostics.rounded, content="true")
  let floor = @lf_arith.ArithmeticContext::new(2, rounding=@lf_arith.RoundingMode::TowardNegative)
  inspect(@lf_arith.MulContextual::mul_contextual(Cents(5), Cents(10), floor) is Err(_), content="true")
}
```

$0.05 \times 0.10 = 0.005$ and $0.15 \times 0.10 = 0.015$ are both exact ties;
round-to-nearest-even sends them to $0.00$ and $0.02$, the neighbours with an
even last digit.

### Compare enclosures with three outcomes

For an interval or ball type, "is $x < y$?" has three answers: yes for every
admissible value, no for every one, or unknown. The two relation traits are
enough to compute it:

```moonbit
struct Interval {
  lo : Double
  hi : Double
}

impl @lf_arith.DefinitelyLt for Interval with definitely_lt(x, y) { x.hi < y.lo }

impl @lf_arith.DefinitelyLe for Interval with definitely_le(x, y) { x.hi <= y.lo }

enum Truth {
  Yes
  No
  Unknown
} derive(Debug)

fn[X : @lf_arith.DefinitelyLt + @lf_arith.DefinitelyLe] less(x : X, y : X) -> Truth {
  if @lf_arith.DefinitelyLt::definitely_lt(x, y) {
    Yes
  } else if @lf_arith.DefinitelyLe::definitely_le(y, x) {
    No
  } else {
    Unknown
  }
}

test "three-valued comparison" {
  let x = Interval::{ lo: 1.0, hi: 2.0 }
  debug_inspect(less(x, Interval::{ lo: 3.0, hi: 4.0 }), content="Yes")
  debug_inspect(less(x, Interval::{ lo: 0.0, hi: 1.0 }), content="No")
  debug_inspect(less(x, Interval::{ lo: 1.5, hi: 2.5 }), content="Unknown")
}
```

An `Unknown` answer is not a failure: narrow the enclosures (compute with more
precision) and ask again. A `Yes` or `No` never changes when the enclosures
shrink; the [design page](../design/core.md#soundness-and-monotonicity-of-enclosure-relations)
proves why. Interval and ball backends implement the same traits, so `less`
works with them unchanged.

### Combine with algebraic structure

`arithmetic` does not define rings or fields; `luna-generic` does. Combine the
two in a bound when an algorithm needs both, for example a Newton iteration
for $\sqrt{a}$ that only needs field operations, cross-checked against
`Sqrt` to within one ulp:

```moonbit
fn[T : @lf_alg.Field] newton_sqrt(a : T, x0 : T, steps : Int) -> T {
  let one : T = @lf_alg.One::one()
  let two = one + one
  let mut x = x0
  for _ in 0..<steps {
    x = (x + a / x) / two
  }
  x
}

test "newton agrees with sqrt" {
  let a = 2.0
  let diff = newton_sqrt(a, 1.0, 6) - @lf_arith.Sqrt::sqrt(a)
  inspect(diff.abs() <= 2.220446049250313e-16, content="true")
}
```

Import `"Luna-Flow/luna-generic" @lf_alg` next to `@lf_arith` for this.

### Choose the tier for performance

Unchecked traits compile to a direct call with no allocation. Checked traits
wrap the result in a `Result`, and contextual ones also build an
`ArithmeticOutcome`. In an inner loop over native scalars, validate the
inputs once with a checked call and use the unchecked trait inside. Generic
code is specialised per type, so a trait bound costs nothing at run time.

## Common pitfalls

- **Empty diagnostics from `Float` and `Double` do not mean exact.** Their
  contextual arithmetic ignores the context and does not detect rounding:
  `add_contextual(0.1, 0.2, ctx)` returns `0.30000000000000004` with empty
  diagnostics. Only the `Float` integer embedding detects loss. Use a
  context-faithful backend when the flags matter.
- **The context is a request.** `ArithmeticContext::new(16)` does not make
  `Double` arithmetic decimal; it tells a backend what to do if it can.
  `ArithmeticContext::new(0)` silently becomes precision `1`, and `e_min`
  greater than `e_max` aborts.
- **Unchecked `Power` aborts on negative integer exponents.**
  `@lf_arith.Power::pow(2, -1)` aborts for `Int`, `Int16`, `Int64` and
  `BigInt`, and the fixed-width integer powers wrap on overflow. Use
  `PowIntChecked` on a floating type for reciprocals.
- **A tiny base with a negative exponent.** `pow_int_checked(1.0e-200, -2, ctx)`
  returns `DivisionByZero`, because $x^2$ underflows to zero before the
  reciprocal is taken.
- **`epsilon_contextual` is $\varepsilon$, not the unit roundoff.**
  Round-to-nearest errors are bounded by $u = \varepsilon/2$.
- **`definitely_lt` being false does not mean "greater or equal".** For
  overlapping enclosures both directions are false; ask the opposite question
  as well, as `less` does above.
- **`maybe_eq` is not equality.** It says the enclosures share a point. Two
  different values can have overlapping enclosures.
- **`x.sqrt()` on a `Double` is core's method, not the trait.** In generic
  code call the trait, `@lf_arith.Sqrt::sqrt(x)`; the results agree for
  `Double`, but only the trait call works for every `T : Sqrt`.

## Next steps

- The [core API](../api/core.md) lists every trait, type and instance with its
  exact semantics.
- The [core design](../design/core.md) explains the three tiers, the explicit
  context and the enclosure logic, with the rounding-error and correctness
  derivations.
- [`luna-generic`](https://lunaflow.cn/en/luna-generic/) provides the
  algebraic traits that combine with these capabilities.
