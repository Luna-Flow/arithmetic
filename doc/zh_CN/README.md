# Arithmetic 文档

这里是 `arithmetic` **0.5.0** 的简体中文文档入口。更早的版本说明和仓库历史请参见
[CHANGELOG.md](../../CHANGELOG.md)。

## 本版重点

- `IntegralContextual` 嵌入 MoonBit `Int` 并返回 diagnostics。
- `AdjacentContextual` 提供 next-plus、next-minus 和 next-toward。
- `ConstantsContextual` 与 `HyperbolicContextual` 为更丰富的数值后端定义忠实于
  context 的能力边界。
- certification failure 继续通过 `ArithmeticError` 显式返回。

## 能力分层

- unchecked elementary traits 直接保留后端行为。
- checked traits 显式返回定义域错误和除法错误。
- contextual traits 接收 `ArithmeticContext`，返回结果值及诊断信息。
- enclosure traits 表达包含、确定关系和可能关系。

## Context 契约

- precision 下限为 `1`。
- 同时提供 `e_min` 与 `e_max` 时，`e_min` 不能大于 `e_max`。
- decimal 预设会一起确定 precision、指数范围与钳制开关。
- 诊断标志通过逻辑 OR 合并，始终作为普通不可变值传递。

## 内置实例限制

内置 `Float` 与 `Double` contextual 操作保留原生标量语义，不执行任意 decimal
精度、定向舍入、指数钳制或通用状态标志探测。`Float` 的整数嵌入会报告可检测的转换
损失；相邻值操作使用固定 IEEE 二进制格式，并因邻接选择在该表示集合中是精确操作而
返回空 diagnostics。contextual 除法和平方根会复用 checked 路径完成验证。原生
`Float` 与 `Double` 不实现 contextual 常量或双曲函数。

## 核心文档

- [快速上手](./getting_started.md)
- [架构](./architecture.md)
- [验证](./verification.md)
- [API 参考](./core/api.md)
- [教程](./core/tutorial.md)
- [设计](./core/design.md)
- [文档规范](./doc_standard.md)
