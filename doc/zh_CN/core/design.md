# Core 设计

## 设计目标

`arithmetic` 让 Luna Flow 从代数结构扩展到解析能力和上下文相关的数值能力，同时保持
后端语义清晰可见。

## 能力边界

- unchecked traits 描述直接、无 context 的后端操作。
- checked traits 显式增加定义域或算术失败，但不会把成功值改成诊断记录。
- contextual traits 接收 `ArithmeticContext` 并返回 `ArithmeticOutcome[T]`，
  让实现可以报告舍入和异常条件标志。
- enclosure 关系与标量比较保持分离。

算法应组合最小的现有 traits 来表达需求。宽泛的本地 “number” 或 “real” trait
会掩盖不同数值域之间的重要差异。

## 数据与效果

`ArithmeticContext`、`ArithmeticDiagnostics` 和 `ArithmeticOutcome` 都是普通值。
context 显式传入，diagnostics 通过纯函数式的 `combine` 累积，不需要包级全局算术状态。

错误继续通过 `Result[..., ArithmeticError]` 显式返回。诊断标志表示一次成功计算中值得
关注的条件，不能替代实现明确拒绝某项操作时返回的错误。

## 内置适配策略

`Float` 与 `Double` 把新的 contextual 边界适配到现有原生和 checked 操作上。除法与
平方根复用 checked 验证，其余操作保留原生标量行为。

这些适配器只保证接口可用，并不是软件 decimal 引擎。它们不会假装支持任意精度、
定向舍入、指数钳制或完整 IEEE 状态标志生成。

## 边界

- 本包不定义向量、矩阵、复数、符号对象或任意精度 decimal 存储。
- 本包不会把 branch cut 或特殊值压平到一个宽泛抽象中。
- contextual rounding、指数处理和 diagnostics 生成语义由具体数值后端负责。
