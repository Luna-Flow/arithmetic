# Core 教程

## 泛型解析辅助函数

```moonbit
fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}
```

这个签名只声明算法真正使用的能力。

## 构造 Arithmetic Context

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

当后端契约与某个 decimal 格式一致时使用预设；当具体后端支持不同工作上下文时使用
`new`。

## Contextual 除法

```moonbit
let outcome = DivContextual::div_contextual(
  10.0,
  4.0,
  ArithmeticContext::decimal64(),
).unwrap()

inspect(outcome.value, content="2.5")
inspect(outcome.diagnostics.inexact, content="false")
```

内置 `Double` 实例通过 `DivChecked` 验证除法，并用 exact diagnostics 包装成功结果。
decimal 后端可以实现相同 trait，同时返回舍入或钳制标志。

## 合并 Diagnostics

```moonbit
let diagnostics = first.diagnostics.combine(second.diagnostics)
let result = ArithmeticOutcome::with_diagnostics(second.value, diagnostics)
```

合并 diagnostics 是显式的值转换，不会修改输入，也不会修改包级全局状态。

## Checked 比较

```moonbit
fn ordering_or_error[T : CompareChecked](
  lhs : T,
  rhs : T,
) -> Result[Int, ArithmeticError] {
  CompareChecked::compare_checked(lhs, rhs)
}
```

当 NaN 等无序值不能被静默折叠成总序时，应使用 checked 路径。

## 实践建议

- 接受直接后端语义时使用 unchecked traits。
- 需要显式失败但不需要诊断标志时使用 checked traits。
- 算法需要传递工作 context 并保留诊断标志时使用 contextual traits。
- 不要假设内置 `Float` 或 `Double` contextual 实例会模拟 decimal precision 或定向舍入。
- 代数结构属于 `luna-generic`；解析和 contextual 能力属于 `arithmetic`。
