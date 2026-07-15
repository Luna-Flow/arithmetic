# Verification

## Local Gate

Run the same checks required before a release:

```sh
moon update
moon build --target all
moon check --target all --frozen
moon test --frozen
moon test --target js --frozen
moon test --target native --frozen
moon info
git diff --exit-code -- 'src/pkg.generated.mbti'
moon fmt --check
```

`moon info` regenerates public-interface snapshots. The following diff check
requires the tracked `pkg.generated.mbti` file to agree with the source API.

## What the Tests Establish

The checked tests cover error classification and the public construction and
inspection paths for certification failures. In particular, they establish that
the detail survives `ArithmeticError::certification_failure`, that precision and
refinement inputs are normalized, and that existing error predicates remain
disjoint from `is_certification_failure`.

The tests do not claim that `Float` or `Double` perform certified arithmetic.
They only verify the shared capability vocabulary and its ordinary error-model
behavior.

## Release Gate

The `publish-package` GitHub workflow accepts an explicit release version and
requires it to equal the version in `moon.mod`. It then updates the registry,
builds and checks all targets, runs default, JavaScript, and native tests,
publishes with the `LUNA_MOONCAKE` secret, and creates the corresponding GitHub
release.

CI runs on pull requests and pushes to `main`. It repeats all-target builds and
checks, default/JavaScript/native tests, interface snapshot validation, and
formatting. A passing CI run is repository evidence, not a numerical
conformance claim for any concrete backend.
