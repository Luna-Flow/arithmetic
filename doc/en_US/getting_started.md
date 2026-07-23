# Getting Started

`arithmetic` supplies small capability traits for analytic operations and a
shared checked-error vocabulary. It does not define a universal number type.

## Install and Import

```sh
moon add Luna-Flow/arithmetic@0.5.0
moon add Luna-Flow/luna-generic@0.3.1
```

```moonbit nocheck
import {
  "Luna-Flow/luna-generic" @lf_alg
  "Luna-Flow/arithmetic" @lf_arith
}
```

## Request Only Needed Capabilities

```moonbit
using @lf_alg { trait Add, trait Mul }
using @lf_arith { trait Sqrt }

fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}
```

Choose an unchecked trait only when the concrete backend's direct behavior is
acceptable. Use a checked trait when callers must handle a rejected operation.

## Handle Checked and Certified Failures

```moonbit nocheck
let context = @lf_arith.ArithmeticContext::decimal64()
match @lf_arith.DivChecked::div_checked(1.0, 0.0, context) {
  Ok(value) => value.to_string()
  Err(error) if error.is_certification_failure() => {
    let detail = error.certification_failure_detail().unwrap()
    detail.operation() + " was not certified"
  }
  Err(error) => error.message
}
```

`CertificationFailureDetail` is present only for
`ArithmeticErrorKind::CertificationFailure`. It identifies the operation,
proof stage, reason, target precision, working precision, and refinement count.
It lets a proof-backed backend report an inconclusive evaluation without
misclassifying it as a domain or format failure.

## Continue Reading

- [Core tutorial](./core/tutorial.md) for contexts and diagnostics.
- [Core API](./core/api.md) for public names and semantic notes.
- [Architecture](./architecture.md) for effect and error boundaries.
- [Verification](./verification.md) for the repository gate and release checks.
