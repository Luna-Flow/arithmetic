# Arithmetic ドキュメント

ここは `arithmetic` **0.5.0** の日本語ドキュメント入口です。過去のリリースノートと履歴は
[CHANGELOG.md](../../CHANGELOG.md) を参照してください。

## このリリースの要点

- `IntegralContextual` は MoonBit `Int` を埋め込み diagnostics を返します。
- `AdjacentContextual` は next-plus、next-minus、next-toward を提供します。
- `ConstantsContextual` と `HyperbolicContextual` は、より豊かな数値 backend のために
  context に忠実な capability 境界を定義します。
- certification failure は引き続き `ArithmeticError` で明示されます。

## Capability レイヤー

- unchecked elementary traits は後端の直接的な挙動を公開します。
- checked traits は定義域エラーや除算エラーを明示します。
- contextual traits は `ArithmeticContext` を受け取り、値と diagnostics を返します。
- enclosure traits は包含、確定関係、可能関係を表します。

## Context の契約

- precision は最低 `1` に補正されます。
- `e_min` と `e_max` を両方指定する場合、`e_min` は `e_max` 以下である必要があります。
- decimal プリセットは precision、指数範囲、clamp をまとめて定義します。
- diagnostics は論理 OR で合成され、通常の不変値として扱われます。

## 組み込みインスタンスの制約

組み込みの `Float` と `Double` の contextual 演算はネイティブ scalar の挙動を
維持します。任意の decimal 精度、方向付き丸め、指数 clamp、一般的な状態フラグ検出は
行いません。`Float` の整数埋め込みは検出可能な変換損失を報告します。隣接値演算は固定の
IEEE バイナリ形式を使い、その表現集合での隣接選択は正確な操作なので空の diagnostics を
返します。contextual 除算と平方根は checked 経路で検証します。ネイティブ `Float` と
`Double` は contextual 定数または双曲線関数を実装しません。

## Core ドキュメント

- [はじめに](./getting_started.md)
- [アーキテクチャ](./architecture.md)
- [検証](./verification.md)
- [API リファレンス](./core/api.md)
- [チュートリアル](./core/tutorial.md)
- [設計](./core/design.md)
- [ドキュメント標準](./doc_standard.md)
