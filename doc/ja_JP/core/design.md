# Core 設計

## 設計目標

`arithmetic` は Luna Flow を代数構造から解析 capability と context 依存の数値能力へ
拡張しつつ、後端ごとの意味論を明示したまま扱います。

## Capability 境界

- unchecked traits は context を持たない直接的な後端演算を表します。
- checked traits は、成功値を診断レコードへ変えずに定義域や算術エラーを明示します。
- contextual traits は `ArithmeticContext` を受け取り `ArithmeticOutcome[T]` を返し、
  丸めや例外条件のフラグを報告できるようにします。
- enclosure 関係は scalar 比較から分離します。

アルゴリズムは、要件を表す最小の既存 trait 構成に依存すべきです。広すぎるローカルな
“number” や “real” trait は、数値領域ごとの重要な違いを隠してしまいます。

## データと効果

`ArithmeticContext`、`ArithmeticDiagnostics`、`ArithmeticOutcome` は通常の値です。
context は明示的に渡し、diagnostics は純粋な `combine` で集約します。パッケージ全体の
算術状態は必要ありません。

エラーは `Result[..., ArithmeticError]` で明示します。診断フラグは成功した計算に伴う
注目すべき条件を表し、実装が拒否した操作のエラーを置き換えるものではありません。

## 組み込み Adapter 戦略

`Float` と `Double` は contextual 境界を既存のネイティブ演算と checked 演算へ
接続します。除算と平方根は checked 検証を再利用し、整数埋め込みはネイティブ
`Float` の変換損失を検出します。隣接値演算は IEEE のビット表現を移動し、固定形式の
隣接選択を正確な capability 操作として空の diagnostics で返します。

これらはインターフェースを利用可能にする adapter であり、software decimal engine
ではありません。任意精度、方向付き丸め、指数 clamp、完全な IEEE フラグ生成を
実装したようには扱いません。
これらは意図的に `ConstantsContextual` と `HyperbolicContextual` を実装しません。
証明ベースの数値パッケージはこれらの capability を実装し、認証失敗の詳細を
`ArithmeticError` で保持できます。

## 境界

- このパッケージはベクトル、行列、複素数、記号オブジェクト、任意精度 decimal
  ストレージを定義しません。
- branch cut や特殊値を 1 つの広い抽象へ押し込みません。
- contextual rounding、指数処理、diagnostics 生成は具体的な数値後端が担当します。
