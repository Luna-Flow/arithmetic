# Verification

This guide lists the checks a change must pass, what the tests establish, and
what they deliberately do not claim.

## Local gate

Run from the repository root before opening a pull request:

```sh
moon update
moon fmt
moon info
git diff -- src/pkg.generated.mbti
moon check --target all
moon test
moon test --target js
moon test --target native
```

`moon info` regenerates the interface file; its diff is the list of public API
changes and must be intended. `moon check --target all` must finish without
warnings in this package.

When `arithmetic` is developed together with an unreleased `luna-generic`,
run `moon check` and `moon test` from a workspace whose `moon.work` lists both
checkouts, so that the test dependency resolves to the local copy.

## Documentation gate

The manual is checked by `lunadoc`:

```sh
lunadoc update .
lunadoc check --compile .
lunadoc status --pages .
```

`update` regenerates `doc/locale/manual.pot` and merges it into the Chinese
and Japanese catalogs; `check` fails on broken relative links, catalogs that
do not match the English pages and Typst attachments that do not compile.
Every `moonbit` block that is not marked `nocheck` is a complete test or
definition: copy the blocks of a page into a `_test.mbt` file of a scratch
package that imports `Luna-Flow/arithmetic` as `@lf_arith` (and
`Luna-Flow/luna-generic` as `@lf_alg` for the tutorial) and run `moon test`.

## What the tests establish

`trait_test.mbt` checks that the unchecked traits compose in generic code
together with `luna-generic` bounds; representative values of every
elementary function for `Float` and `Double`; that `Constants` satisfy
$\tau = 2\pi$ and $\ln e = 1$ in both types; exact `Power` for every integer
type and `BigInt`; the checked square
root and division on valid input, negative input, $0/0$, $\infty/\infty$ and
zero divisors; NaN rejection by `CompareChecked`; and checked integer powers
with zero exponents, negative exponents, zero bases and the most negative `Int`.

`contextual_test.mbt` checks exact and rounded `Int` embedding into `Float`
and exact embedding into `Double`; the IEEE boundaries of the adjacent
operations (signed zeros, smallest subnormals, largest finite values,
infinities and NaN); and, through test-local types, that contextual
hyperbolic outcomes and certification failures of contextual constants pass
through the traits unchanged.

`certification_error_wbtest.mbt` checks that a `CertificationFailureDetail`
survives `ArithmeticError::certification_failure` with every field, and that
the error predicates stay disjoint.

## What the tests do not claim

The tests do not claim that `Float` or `Double` arithmetic is certified, that
their elementary functions are correctly rounded, or that their contextual
instances detect rounding. They verify the capability vocabulary, the
fixed-format adjacent semantics and the error classification.

## Continuous integration

CI runs on pull requests and on pushes to `main`: it builds and checks all
targets, runs the default, JavaScript and native test suites, verifies that
`pkg.generated.mbti` matches the source, and checks formatting. A separate
workflow runs the shared Luna Flow documentation check on changes under
`doc/`. The `publish-package` workflow accepts an explicit version, requires
it to equal the version in `moon.mod`, repeats the checks, publishes to
mooncakes and creates the GitHub release. A passing run is repository
evidence, not a numerical conformance claim for any backend.
