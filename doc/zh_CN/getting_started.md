# 快速上手

`arithmetic` 提供解析运算的小型 capability traits，以及共享的 checked error 词汇；它不定义
通用的数值类型。

## 安装与导入

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

## 只声明所需能力

```moonbit
using @lf_alg { trait Add, trait Mul }
using @lf_arith { trait Sqrt }

fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}
```

只有在可接受具体后端的直接语义时才使用 unchecked trait；调用方需要处理被拒绝的操作时，
使用 checked trait。

## 处理 Checked 与 Certification 失败

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

仅当 error 为 `ArithmeticErrorKind::CertificationFailure` 时，才会有
`CertificationFailureDetail`。它记录操作、证明阶段、原因、目标精度、工作精度和
refinement 次数，使支持证明的后端能报告无法确定的求值，而不把它误报为定义域或格式错误。

## 后续阅读

- [核心教程](./core/tutorial.md)：context 与 diagnostics。
- [核心 API](./core/api.md)：公开名称与语义说明。
- [架构](./architecture.md)：effect 和 error 边界。
- [验证](./verification.md)：仓库门禁与发布检查。
