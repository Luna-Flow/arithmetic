# Core API

## 役割

`arithmetic` は `luna-generic` の上に解析 capability、checked 演算、contextual
結果、enclosure 関係を追加します。公開 traits は小さく保ち、アルゴリズムが必要な
能力だけを要求できるようにします。

## Unchecked Capability Traits

- `Sqrt`、`Cbrt`、`Radical`
- `Exponential`、`Logarithmic`、`Power`
- `Trigonometric`、`InverseTrigonometric`
- `Hyperbolic`、`InverseHyperbolic`
- `Constants`

これらは `src/elementary.mbt` で定義され、後端の値を直接返します。

## Checked Surface

### 共有型

- `FpClass`
- `RoundingMode`
- `ArithmeticContext`
- `CertificationStage`
- `CertificationFailureReason`
- `CertificationFailureDetail`
- `ArithmeticErrorKind`
- `ArithmeticError`

### Context の構築

`ArithmeticContext::new` は precision、rounding mode、省略可能な `e_min`、
`e_max`、`clamp` を受け取ります。precision は最低 `1` に補正されます。両方の
指数境界を指定し、`e_min` が `e_max` を上回る場合は abort します。

次のプリセットも提供します。

- `ArithmeticContext::decimal32`：precision `7`、指数範囲 `-95...96`
- `ArithmeticContext::decimal64`：precision `16`、指数範囲 `-383...384`
- `ArithmeticContext::decimal128`：precision `34`、指数範囲 `-6143...6144`

3 つのプリセットはすべて `ToNearestEven` を使い、clamp を有効にします。

### Checked Traits

- `SqrtChecked`
- `DivChecked`
- `CompareChecked`
- `PowNatChecked`
- `PowIntChecked`
- `ParseChecked`

これらは `Result[..., ArithmeticError]` を返します。算術 context が必要な演算は
`ArithmeticContext` を明示的に受け取ります。

## Contextual Outcome Surface

### 結果型

`ArithmeticDiagnostics` は `inexact`、`rounded`、`overflow`、`underflow`、
`subnormal`、`clamped` を保持します。`empty` と `new` で診断値を作り、`combine`
は各フラグを論理 OR で合成します。

`ArithmeticOutcome[T]` は `value : T` と diagnostics を保持します。`exact` は空の
diagnostics を持つ結果を作り、`with_diagnostics` は指定されたフラグを保持します。

### Contextual Traits

- `AddContextual`、`SubContextual`、`MulContextual`、`DivContextual`
- `AbsContextual`、`SqrtContextual`、`ExpContextual`
- `NumericFormatContextual`

`NumericFormatContextual` は contextual zero、one、epsilon、最小正規値、最大有限値を
提供し、値を `Finite`、`Infinity`、`NaN` に分類します。

## Enclosure 関係

- `Contains`
- `Overlaps`
- `DefinitelyLt`
- `DefinitelyLe`
- `MaybeEq`

これらは関係を表すもので、scalar の全順序ではありません。

## 同梱インスタンス

- `Float` と `Double` は `Kaida-Amethyst/math` を通じて広い elementary surface を実装します。
- `Float` と `Double` は checked 平方根、除算、比較、整数冪を実装します。
- `Float` と `Double` は `0.3.0` で追加された contextual traits をすべて実装します。
- `BigInt` と整数族は、それぞれの型で閉じた正確な部分集合だけを実装します。

## 意味論メモ

- unchecked traits の定義域と branch は具体インスタンスに依存します。
- 組み込み checked 平方根は負の実数入力に `DomainError` を返します。
- 組み込み checked 除算は `0 / 0` と infinity 同士の除算を `DomainError` とし、
  非ゼロ値のゼロ除算は `DivisionByZero` とします。
- 組み込み contextual 除算と平方根は checked 演算へ委譲し、成功値を exact
  diagnostics で包みます。
- その他の `Float` と `Double` の contextual 演算もネイティブ挙動を維持し、exact
  diagnostics を返します。
- 組み込み実装は context による precision、rounding、指数 clamp、状態フラグ検出を
  行いません。
- 符号付き整数と `BigInt` の `Power` は非負指数を要求し、負指数では abort します。
- `PowNatChecked` は `0^0` を含め、`x^0` を乗法単位元として扱います。
