# Core API

## 作用

`arithmetic` 在 `luna-generic` 的基础上补充解析能力、checked 操作、contextual
结果和 enclosure 关系。公开 traits 保持小而专一，让算法只声明真正需要的能力。

## Unchecked 能力 Traits

- `Sqrt`、`Cbrt`、`Radical`
- `Exponential`、`Logarithmic`、`Power`
- `Trigonometric`、`InverseTrigonometric`
- `Hyperbolic`、`InverseHyperbolic`
- `Constants`

这些 traits 定义在 `src/elementary.mbt`，直接返回后端值。

## Checked 表面

### 共享类型

- `FpClass`
- `RoundingMode`
- `ArithmeticContext`
- `CertificationStage`
- `CertificationFailureReason`
- `CertificationFailureDetail`
- `ArithmeticErrorKind`
- `ArithmeticError`

### Context 构造

`ArithmeticContext::new` 接收 precision、rounding mode、可选的 `e_min`、`e_max`
和 `clamp`。precision 最低会被调整为 `1`。如果同时提供两个指数边界且 `e_min`
大于 `e_max`，构造会 abort。

包内还提供以下预设：

- `ArithmeticContext::decimal32`：precision `7`，指数范围 `-95...96`
- `ArithmeticContext::decimal64`：precision `16`，指数范围 `-383...384`
- `ArithmeticContext::decimal128`：precision `34`，指数范围 `-6143...6144`

三组预设均使用 `ToNearestEven` 并启用钳制。

### Checked Traits

- `SqrtChecked`
- `DivChecked`
- `CompareChecked`
- `PowNatChecked`
- `PowIntChecked`
- `ParseChecked`

这些 traits 返回 `Result[..., ArithmeticError]`。需要算术上下文的操作会显式接收
`ArithmeticContext`。

## Contextual Outcome 表面

### 结果类型

`ArithmeticDiagnostics` 包含 `inexact`、`rounded`、`overflow`、`underflow`、
`subnormal` 和 `clamped` 标志。`empty` 与 `new` 用于构造诊断值；`combine`
对每个标志执行逻辑 OR。

`ArithmeticOutcome[T]` 保存 `value : T` 与对应 diagnostics。`exact` 创建空诊断结果，
`with_diagnostics` 保留调用方提供的标志。

### Contextual Traits

- `AddContextual`、`SubContextual`、`MulContextual`、`DivContextual`
- `AbsContextual`、`SqrtContextual`、`ExpContextual`
- `NumericFormatContextual`

`NumericFormatContextual` 提供 contextual zero、one、epsilon、最小正规值、最大有限值，
并把数值分类为 `Finite`、`Infinity` 或 `NaN`。

## Enclosure 关系

- `Contains`
- `Overlaps`
- `DefinitelyLt`
- `DefinitelyLe`
- `MaybeEq`

这些接口表达关系，不伪装成标量总序。

## 内置实例

- `Float` 与 `Double` 通过 `Kaida-Amethyst/math` 实现较完整的 elementary 表面。
- `Float` 与 `Double` 实现 checked 平方根、除法、比较和整数幂能力。
- `Float` 与 `Double` 实现 `0.3.0` 新增的全部 contextual traits。
- `BigInt` 与整数族只实现能够在具体类型上保持闭合的精确子集。

## 语义说明

- unchecked traits 的定义域和 branch 语义由具体实例决定。
- 内置 checked 平方根遇到负实数输入时返回 `DomainError`。
- 内置 checked 除法把 `0 / 0` 和 infinity 除以 infinity 归为 `DomainError`；
  非零数除以零仍归为 `DivisionByZero`。
- 内置 contextual 除法与平方根委托给 checked 操作，并把成功值包装为 exact diagnostics。
- 其他内置 `Float` 与 `Double` contextual 操作保留原生行为，也返回 exact diagnostics。
- 内置实现不会执行 context 控制的 precision、rounding、指数钳制或状态标志探测。
- 有符号整数与 `BigInt` 的 `Power` 要求指数非负；负指数会 abort。
- `PowNatChecked` 把 `x^0` 视为乘法单位元，包括 `0^0`。
