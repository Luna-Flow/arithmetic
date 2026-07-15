# アーキテクチャ

## 境界モデル

`luna-generic` は代数構造を担当します。`arithmetic` は解析、checked、contextual、
enclosure capability を加えますが、一体化した scalar abstraction は導入しません。
algorithm は要件を表す最小の trait 集合を合成します。

| 境界 | 戻り値 | 意味 |
| --- | --- | --- |
| Unchecked trait | `Self` | 具体 backend の直接的な挙動 |
| Checked trait | `Result[T, ArithmeticError]` | 拒否された操作を明示 |
| Contextual trait | `Result[ArithmeticOutcome[T], ArithmeticError]` | 明示的 context と成功 diagnostics |
| Enclosure relation | `Bool` | 包含、確定関係、可能関係 |

## Errors、Diagnostics、Certification

error は受理できる結果を返せない操作を表します。diagnostics は注目すべき条件を伴う成功結果を
表し、logical OR で合成します。両者は分けます。flag が error を隠したり、flag を運ぶために
error を作ったりしてはいけません。

`CertificationFailure` は error 内でのより精密な区別です。proof-backed implementation が
candidate result が target を満たすと確立できない場合に使います。detail は失敗した stage
（`RangeReduction`、`SeriesEvaluation`、`EnclosurePropagation`、`TargetRounding`）と
reason を分けます。この package は retry policy を定めません。caller と concrete backend が
resource や precision を増やすかを決めます。

## Context と State

`ArithmeticContext`、`ArithmeticDiagnostics`、`ArithmeticOutcome`、
`CertificationFailureDetail` はすべて不変な通常の値です。context は引数で渡し、diagnostics は
明示的に合成し、certification evidence は返された error に保持します。global rounding mode、
hidden status register、mutable proof state は必要ありません。

## 同梱 Adapter の制約

`Float` と `Double` は現在この共通境界を利用可能にします。contextual operation は native
scalar semantics を保ち、任意 decimal precision、directional rounding、exponent clamp、IEEE
flag detection、proof-backed certification は実装しません。concrete certified backend は同じ traits
を実装し、構造化された certification failure を返せます。
