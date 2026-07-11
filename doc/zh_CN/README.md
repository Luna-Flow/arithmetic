# Arithmetic 文档

这里是 `arithmetic` **0.3.0** 的简体中文文档入口。更早的版本说明和仓库历史请参见
[CHANGELOG.md](../../CHANGELOG.md)。

## 本版重点

- `ArithmeticContext` 新增指数上下限、钳制选项，以及 decimal32、decimal64、
  decimal128 三组预设。
- `ArithmeticOutcome[T]` 把结果值与不可变的 `ArithmeticDiagnostics` 标志放在一起。
- contextual traits 覆盖基础算术、部分解析操作和数值格式信息。
- `Float` 与 `Double` 已实现新接口，但不会因此声称支持任意精度或由 context 控制的舍入。

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

内置 `Float` 与 `Double` contextual 操作目前保留原生标量语义，不执行任意 decimal
精度、定向舍入、指数钳制或状态标志探测。因此，成功操作会返回 exact diagnostics；
contextual 除法和平方根会复用 checked 路径完成验证。

## 核心文档

- [API 参考](./core/api.md)
- [教程](./core/tutorial.md)
- [设计](./core/design.md)
- [文档规范](./doc_standard.md)
