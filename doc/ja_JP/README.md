# Arithmetic ドキュメント

ここは `arithmetic` **0.4.0** の日本語ドキュメント入口です。過去のリリースノートと
履歴は [CHANGELOG.md](../../CHANGELOG.md) を参照してください。

## このリリースの要点

- `CertificationStage` は結果を証明できなかった段階を示します。
- `CertificationFailureReason` は certification が停止した理由を示します。
- `CertificationFailureDetail` は演算、精度計画、refinement 回数を保持します。
- `ArithmeticError` は既存の checked/contextual error の挙動を維持したまま、構造化
  された certification-failure variant を提供します。

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

- [はじめに](./getting_started.md)
- [アーキテクチャ](./architecture.md)
- [検証](./verification.md)
- [API リファレンス](./core/api.md)
- [チュートリアル](./core/tutorial.md)
- [設計](./core/design.md)
- [ドキュメント標準](./doc_standard.md)
