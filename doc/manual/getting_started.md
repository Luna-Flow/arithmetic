# Getting started

This guide takes you from an empty MoonBit module to code that uses each
`arithmetic` tier once. The [core tutorial](tutorial/core.md) continues from
here with complete tasks.

## Install and import

Add the package to `moon.mod`:

```sh
moon add Luna-Flow/arithmetic@0.5.0
```

Import it in the `moon.pkg` of every package that uses it, with the alias Luna
Flow code uses:

```moonbit nocheck
import {
  "Luna-Flow/arithmetic" @lf_arith,
}
```

If you also need algebraic traits such as `Ring` or `Field`, add
`Luna-Flow/luna-generic` with the alias `@lf_alg`.

## Ask for capabilities, not types

Write a function against the traits it uses. `Add` and `Mul` are MoonBit's
operator traits; `Sqrt` comes from this package:

```moonbit
fn[T : Add + Mul + @lf_arith.Sqrt] norm2(x : T, y : T) -> T {
  @lf_arith.Sqrt::sqrt(x * x + y * y)
}

test "norm" {
  inspect(norm2(3.0, 4.0), content="5")
}
```

`norm2` accepts `Float`, `Double` and any type of yours that implements the
three traits.

## Make failures explicit

A checked trait returns a `Result`. Pass an `ArithmeticContext`; the native
instances do not read it, but a decimal backend would:

```moonbit
test "checked division" {
  let ctx = @lf_arith.ArithmeticContext::decimal64()
  inspect(@lf_arith.DivChecked::div_checked(1.0, 8.0, ctx).unwrap(), content="0.125")
  match @lf_arith.DivChecked::div_checked(1.0, 0.0, ctx) {
    Ok(_) => fail("unexpected quotient")
    Err(e) => inspect(e.message, content="division by zero")
  }
}
```

## Read the diagnostics

A contextual trait also returns diagnostics. Converting $2^{24} + 1$ to
`Float` loses the last bit, and the outcome says so:

```moonbit
test "contextual conversion" {
  let ctx = @lf_arith.ArithmeticContext::new(24)
  let out : @lf_arith.ArithmeticOutcome[Float] = @lf_arith.IntegralContextual::from_int_contextual(
    16_777_217, ctx,
  ).unwrap()
  inspect(out.value, content="16777216")
  inspect(out.diagnostics.inexact, content="true")
}
```

Most `Float` and `Double` contextual operations do not detect rounding; the
[API page](api/core.md#contextual-capability-traits) says which do.

## Continue reading

- [Core tutorial](tutorial/core.md): worked tasks, your own instances,
  enclosures.
- [Core API](api/core.md): every public item.
- [Core design](design/core.md): why the tiers exist, and the mathematics.
- [Architecture](architecture.md) and [verification](verification.md) for
  contributors.
