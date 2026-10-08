# arithmetic

Analytic capability traits for Luna Flow numeric types. `arithmetic` lets an
algorithm state exactly which operations it needs (a square root, an
exponential, a checked division, a correctly reported rounding) and how
failures must surface, without assuming a universal "real number" type. It
ships default instances for `Float`, `Double` and the integer types; numeric
backends implement the same traits with context-faithful and certified
arithmetic.

## Capability tiers

| Tier | Traits | Returns |
| --- | --- | --- |
| Unchecked | `Sqrt`, `Cbrt`, `Radical`, `Exponential`, `Logarithmic`, `Power`, `Trigonometric`, `InverseTrigonometric`, `Hyperbolic`, `InverseHyperbolic`, `Constants` | `Self` |
| Checked | `SqrtChecked`, `DivChecked`, `CompareChecked`, `PowNatChecked`, `PowIntChecked`, `ParseChecked` | `Result[Self, ArithmeticError]` |
| Contextual | `AddContextual`, `SubContextual`, `MulContextual`, `DivContextual`, `AbsContextual`, `SqrtContextual`, `ExpContextual`, `IntegralContextual`, `AdjacentContextual`, `ConstantsContextual`, `HyperbolicContextual`, `NumericFormatContextual` | `Result[ArithmeticOutcome[Self], ArithmeticError]` |
| Enclosure relations | `Contains`, `Overlaps`, `DefinitelyLt`, `DefinitelyLe`, `MaybeEq` | `Bool` |

Checked and contextual operations take an explicit, immutable
`ArithmeticContext` (precision, rounding mode, exponent range); there is no
global numeric state. Contextual results carry `ArithmeticDiagnostics` flags,
and proof-backed backends report inconclusive evaluations as structured
certification failures.

The built-in `Float` and `Double` contextual instances keep native IEEE
behaviour: they ignore the context and, except for the `Float` integer
embedding, do not detect rounding.

## Install

```sh
moon add Luna-Flow/arithmetic@0.5.0
```

```moonbit nocheck
import {
  "Luna-Flow/arithmetic" @lf_arith,
}
```

## Example

```moonbit
fn[T : Add + Mul + @lf_arith.Sqrt] hypot(x : T, y : T) -> T {
  @lf_arith.Sqrt::sqrt(x * x + y * y)
}

test "readme" {
  inspect(hypot(3.0, 4.0), content="5")
  let ctx = @lf_arith.ArithmeticContext::decimal64()
  let q = @lf_arith.DivContextual::div_contextual(10.0, 4.0, ctx).unwrap()
  inspect(q.value, content="2.5")
  inspect(@lf_arith.DivChecked::div_checked(1.0, 0.0, ctx) is Err(_), content="true")
}
```

## Packages

| Package | Import path | Documentation |
| --- | --- | --- |
| `core` (`src/`) | `Luna-Flow/arithmetic` | [API](doc/manual/api/core.md), [tutorial](doc/manual/tutorial/core.md), [design](doc/manual/design/core.md) |

## Requirements

MoonBit `moonc` 0.10 or later with `moon.mod`/`moon.pkg` manifests. All
backends (`wasm-gc`, `wasm`, `js`, `native`) are supported. The `Float` and
`Double` elementary functions come from `Kaida-Amethyst/math`.

## Documentation

The manual is published at
[lunaflow.cn/en/arithmetic](https://lunaflow.cn/en/arithmetic/) with Simplified
Chinese and Japanese translations. Its English source is
[doc/manual/index.md](doc/manual/index.md); translations are gettext catalogs
in `doc/locale`.

## Contributing

Run the gate in [doc/manual/verification.md](doc/manual/verification.md)
(`moon fmt`, `moon info`, `moon check --target all`, `moon test` on the
default, JavaScript and native targets) and follow
[doc/manual/conventions.md](doc/manual/conventions.md) for documentation.
Commits follow Conventional Commits. Release history is in
[CHANGELOG.md](CHANGELOG.md).

## License

Apache-2.0. See [LICENSE](LICENSE).
