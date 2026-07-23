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
- `IntegralContextual`、`AdjacentContextual`
- `ConstantsContextual`、`HyperbolicContextual`
- `NumericFormatContextual`

`IntegralContextual::from_int_contextual` 在目标 context 下嵌入 MoonBit `Int` 并返回
转换 diagnostics；更宽的整数来源使用独立 capability。`AdjacentContextual` 提供
`next_plus_contextual`、
`next_minus_contextual` 和 `next_toward_contextual`。`ConstantsContextual`
按 context 生成 `pi`、`tau` 与 `e`；采用证明式计算的实现无法认证目标舍入时，可以返回
kind 为 `ArithmeticErrorKind::CertificationFailure` 的 `ArithmeticError`。

`HyperbolicContextual` 提供 contextual `sinh`、`cosh` 与 `tanh`，每项都在
`Result` 中返回 `ArithmeticOutcome`。

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
- `Float` 与 `Double` 实现原有 contextual 表面以及 `IntegralContextual`、
  `AdjacentContextual`。
- `Float` 与 `Double` 有意不实现 `ConstantsContextual` 或
  `HyperbolicContextual`；忠实于 context 的数值后端负责提供这些能力。
- `BigInt` 与整数族只实现能够在具体类型上保持闭合的精确子集。

## 语义说明

- unchecked traits 的定义域和 branch 语义由具体实例决定。
- 内置 checked 平方根遇到负实数输入时返回 `DomainError`。
- 内置 checked 除法把 `0 / 0` 和 infinity 除以 infinity 归为 `DomainError`；
  非零数除以零仍归为 `DivisionByZero`。
- 内置 contextual 除法与平方根委托给 checked 操作，并把成功值包装为 exact diagnostics。
- 内置 `Float` 整数嵌入在源整数无法精确表示时设置 `inexact` 与 `rounded`；`Double`
  可以精确嵌入所有 MoonBit `Int`。
- 内置相邻值操作遵循固定 IEEE 二进制表示，包括带符号零和 infinity 边界；邻接选择在
  固定表示集合中是精确操作，因此返回空 diagnostics。
- 内置实现不会执行 context 控制的 precision、rounding、指数钳制或状态标志探测。
- 有符号整数与 `BigInt` 的 `Power` 要求指数非负；负指数会 abort。
- `PowNatChecked` 把 `x^0` 视为乘法单位元，包括 `0^0`。
