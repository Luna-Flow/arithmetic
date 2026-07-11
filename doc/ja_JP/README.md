# Arithmetic ドキュメント

ここは `arithmetic` **0.3.0** の日本語ドキュメント入口です。過去のリリースノートと
履歴は [CHANGELOG.md](../../CHANGELOG.md) を参照してください。

## このリリースの要点

- `ArithmeticContext` に指数の上下限、clamp 設定、decimal32・decimal64・
  decimal128 のプリセットを追加しました。
- `ArithmeticOutcome[T]` は計算値と不変な `ArithmeticDiagnostics` フラグを保持します。
- contextual traits は基本算術、一部の解析演算、数値形式の情報を扱います。
- `Float` と `Double` は新しい surface を実装しますが、任意精度や context による
  丸めまで実装したものではありません。

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

組み込みの `Float` と `Double` の contextual 演算は、現時点ではネイティブ scalar の
挙動を維持します。任意の decimal 精度、方向付き丸め、指数 clamp、状態フラグ検出は
行いません。そのため成功時は exact diagnostics を返し、contextual 除算と平方根は
checked 経路で検証します。

## Core ドキュメント

- [API リファレンス](./core/api.md)
- [チュートリアル](./core/tutorial.md)
- [設計](./core/design.md)
- [ドキュメント標準](./doc_standard.md)
