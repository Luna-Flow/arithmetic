# 架构

## 边界模型

`luna-generic` 负责代数结构；`arithmetic` 提供解析、checked、contextual 和 enclosure
能力，但不引入一个打包的 scalar 抽象。算法应组合能说明需求的最小 trait 集合。

| 边界 | 返回值 | 含义 |
| --- | --- | --- |
| Unchecked trait | `Self` | 具体后端的直接行为 |
| Checked trait | `Result[T, ArithmeticError]` | 被拒绝的操作显式可见 |
| Contextual trait | `Result[ArithmeticOutcome[T], ArithmeticError]` | 显式 context 加成功 diagnostics |
| Enclosure relation | `Bool` | 包含、确定关系或可能关系 |

## Errors、Diagnostics 与 Certification

error 表示不能产生可接受结果的操作；diagnostics 描述具有值得注意条件的成功结果，并以逻辑
OR 组合。两者必须分开：flag 不能隐藏 error，也不能为了传递 flag 而虚构 error。

`CertificationFailure` 在 error 内再做精确区分：支持证明的实现无法建立候选结果满足目标时
使用它。detail 将失败阶段（`RangeReduction`、`SeriesEvaluation`、
`EnclosurePropagation` 或 `TargetRounding`）与原因分开。本包不规定重试策略；调用方和
具体后端决定是否增加资源或精度。

## Context 与状态

`ArithmeticContext`、`ArithmeticDiagnostics`、`ArithmeticOutcome` 与
`CertificationFailureDetail` 都是不可变普通值。context 显式传入，diagnostics 显式组合，
certification evidence 保留在返回的 error 上；包不依赖全局 rounding mode、隐藏状态寄存器或
可变证明状态。

## 内置适配器的限制

`Float` 与 `Double` 使通用边界当前即可使用。它们的 contextual 操作保留原生 scalar 语义，
不实现任意 decimal 精度、定向舍入、指数钳制、IEEE flag 探测或证明式 certification。具体的
certified backend 可以使用相同 traits 并产生结构化 certification failures。
