# arithmetic

`Luna-Flow/arithmetic` defines the analytic capabilities of Luna Flow numeric
types: elementary functions, checked operations that return structured errors,
contextual operations that report how a result was rounded under an explicit
precision and rounding mode, and relations between enclosures such as
intervals. It ships default instances for `Float`, `Double` and the integer
types, and leaves context-faithful and certified arithmetic to backends that
implement the same traits.

This manual describes version `0.5.0` together with the unreleased MoonBit 0.10
migration listed in [CHANGELOG.md](../../CHANGELOG.md).

## Where it sits

[`luna-generic`](https://lunaflow.cn/en/luna-generic/) says what a type is
(`Ring`, `Field`, ...). `arithmetic` says which analytic operations it
supports and how they fail. Backends such as
[`floating`](https://lunaflow.cn/en/floating/) implement the traits for
decimal, binary and ball arithmetic, and higher packages such as
`linear-algebra`, `luna-complex` and `calculus-numerical` depend on the traits
instead of on concrete number types.

| Tier | Example | Returns | Use it when |
| --- | --- | --- | --- |
| Unchecked | `Sqrt::sqrt` | `Self` | the type's own special-value behaviour is acceptable |
| Checked | `SqrtChecked::sqrt_checked` | `Result[Self, ArithmeticError]` | invalid input must become a handled error |
| Contextual | `SqrtContextual::sqrt_contextual` | `Result[ArithmeticOutcome[Self], ArithmeticError]` | precision and rounding are explicit and diagnostics matter |
| Enclosure relation | `DefinitelyLt::definitely_lt` | `Bool` | values are intervals or balls, not points |

## Packages

The module has one package, at the source root `src/`, documented as `core`.

| Package | Import path | Contents | Pages |
| --- | --- | --- | --- |
| `core` | `Luna-Flow/arithmetic` | capability traits, `ArithmeticContext`, diagnostics, errors and certification details, `Float`/`Double`/integer instances | [API](api/core.md), [tutorial](tutorial/core.md), [design](design/core.md) |

The blackbox tests (`src/*_test.mbt`) and the whitebox test
(`src/certification_error_wbtest.mbt`) belong to the same package; the
[verification guide](verification.md) lists what they establish.

## Reading paths

- **New to the package:** read [getting started](getting_started.md), then the
  [core tutorial](tutorial/core.md).
- **Using it in a library:** keep the [core API](api/core.md) at hand; its
  tables say what each shipped instance actually does at the edges (NaN, zero,
  infinities, overflow).
- **Implementing a backend or contributing:** read the
  [core design](design/core.md) for the contracts and their mathematics,
  [architecture](architecture.md) for the layout, and
  [verification](verification.md) and [conventions](conventions.md) before
  opening a pull request.

## Install

```sh
moon add Luna-Flow/arithmetic@0.5.0
```

```moonbit nocheck
import {
  "Luna-Flow/arithmetic" @lf_arith,
}
```

The package depends on `Kaida-Amethyst/math` for the `Float` and `Double`
elementary functions. Its tests also use `Luna-Flow/luna-generic`.

## Toolchain

The code targets MoonBit `moonc` 0.10 or later with the `moon.mod` and
`moon.pkg` manifests, and is checked on the `wasm-gc`, `wasm`, `js` and
`native` backends.

## Guides

- [Getting started](getting_started.md): install, first generic function,
  first checked and contextual calls.
- [Architecture](architecture.md): source layout, tiers, errors and state.
- [Verification](verification.md): the local gate, CI and what the tests
  establish.
- [Repository conventions](conventions.md): rules for this manual on top of
  the Luna Flow standard.
