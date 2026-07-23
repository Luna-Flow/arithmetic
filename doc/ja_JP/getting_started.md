# はじめに

`arithmetic` は解析演算のための小さな capability traits と、checked error の共通語彙を
提供します。汎用の数値型は定義しません。

## インストールと Import

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

## 必要な Capability だけを要求する

```moonbit
using @lf_alg { trait Add, trait Mul }
using @lf_arith { trait Sqrt }

fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}
```

具体的な backend の直接的な意味論を受け入れられる場合だけ unchecked trait を使います。
呼び出し側が拒否された操作を扱う必要がある場合は checked trait を使います。

## Checked と Certification の失敗を処理する

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

`CertificationFailureDetail` が存在するのは error が
`ArithmeticErrorKind::CertificationFailure` のときだけです。演算、証明段階、理由、
target precision、working precision、refinement 回数を記録します。これにより
proof-backed backend は、結論が出ない評価を domain error や format error と取り違えずに
報告できます。

## 次に読むもの

- [Core チュートリアル](./core/tutorial.md)：context と diagnostics。
- [Core API](./core/api.md)：公開名と意味論の注意点。
- [アーキテクチャ](./architecture.md)：effect と error の境界。
- [検証](./verification.md)：リポジトリ gate と release check。
