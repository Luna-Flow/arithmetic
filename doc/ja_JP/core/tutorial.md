# Core チュートリアル

## 汎用解析 Helper

```moonbit
fn hypot2[T : Add + Mul + Sqrt](x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}
```

このシグネチャは、アルゴリズムが実際に使う capability だけを要求します。

## Arithmetic Context の構築

```moonbit
let custom = ArithmeticContext::new(
  24,
  rounding=RoundingMode::TowardNegative,
  e_min=-100,
  e_max=100,
  clamp=true,
)
let standard = ArithmeticContext::decimal64()
```

後端の契約が decimal 形式と一致する場合はプリセットを使います。異なる working
context を持つ後端では `new` を使います。

## Contextual 除算

```moonbit
let outcome = DivContextual::div_contextual(
  10.0,
  4.0,
  ArithmeticContext::decimal64(),
).unwrap()

inspect(outcome.value, content="2.5")
inspect(outcome.diagnostics.inexact, content="false")
```

組み込みの `Double` インスタンスは `DivChecked` で除算を検証し、成功結果を exact
diagnostics で包みます。decimal 後端は同じ trait を実装し、丸めや clamp のフラグを
返すことができます。

## Diagnostics の合成

```moonbit
let diagnostics = first.diagnostics.combine(second.diagnostics)
let result = ArithmeticOutcome::with_diagnostics(second.value, diagnostics)
```

diagnostics の合成は明示的な値変換です。入力やパッケージ全体の状態は変更しません。

## Checked 比較

```moonbit
fn ordering_or_error[T : CompareChecked](
  lhs : T,
  rhs : T,
) -> Result[Int, ArithmeticError] {
  CompareChecked::compare_checked(lhs, rhs)
}
```

NaN のような非順序値を全順序へ暗黙変換してはいけない場合に checked 経路を使います。

## 実践ガイド

- 後端の直接的な意味論で十分な場合は unchecked traits を使います。
- 失敗を明示し、diagnostics が不要な場合は checked traits を使います。
- working context と診断フラグを保持する必要がある場合は contextual traits を使います。
- 組み込みの `Float` と `Double` が decimal precision や方向付き丸めを模倣すると
  仮定してはいけません。
- 代数構造は `luna-generic`、解析と contextual capability は `arithmetic` に置きます。
