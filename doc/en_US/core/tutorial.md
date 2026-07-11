# Core Tutorial

## Generic Analytic Helper

```moonbit
fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}
```

This signature requests only the capabilities the algorithm uses.

## Construct an Arithmetic Context

```moonbit
let custom = ArithmeticContext::new(
  24,
  rounding=RoundingMode::TowardNegative,
  e_min=-100,
  e_max=100,
  clamp=true,
)
let standard = ArithmeticContext::decimal64()
```

Use a preset when its decimal format matches the backend contract. Use `new`
when a concrete backend supports a different working context.

## Contextual Division

```moonbit
let outcome = DivContextual::div_contextual(
  10.0,
  4.0,
  ArithmeticContext::decimal64(),
).unwrap()

inspect(outcome.value, content="2.5")
inspect(outcome.diagnostics.inexact, content="false")
```

The built-in `Double` instance validates division through `DivChecked` and
wraps a successful result with exact diagnostics. A decimal backend may use the
same trait while producing rounding or clamping flags.

## Combine Diagnostics

```moonbit
let diagnostics = first.diagnostics.combine(second.diagnostics)
let result = ArithmeticOutcome::with_diagnostics(second.value, diagnostics)
```

Combining diagnostics is an explicit value transformation. It does not mutate
either input or package-global state.

## Checked Comparison

```moonbit
fn ordering_or_error[T : CompareChecked](
  lhs : T,
  rhs : T,
) -> Result[Int, ArithmeticError] {
  CompareChecked::compare_checked(lhs, rhs)
}
```

Use the checked path when unordered values such as NaN must not be silently
coerced into a total order.

## Practical Guidance

- Use unchecked traits when direct backend semantics are acceptable.
- Use checked traits when failure must be explicit but diagnostics are not
  needed.
- Use contextual traits when an algorithm must pass working context and retain
  diagnostic flags.
- Do not assume the built-in `Float` or `Double` contextual instances emulate
  decimal precision or directed rounding.
- Keep algebraic structure in `luna-generic`; use `arithmetic` for analytic and
  contextual capabilities.
