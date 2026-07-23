# 検証

## Local Gate

release 前に同じ checks を実行します。

```sh
moon update
moon build --target all
moon check --target all --frozen
moon test --frozen
moon test --target js --frozen
moon test --target native --frozen
moon info
git diff --exit-code -- 'src/pkg.generated.mbti'
moon fmt --check
```

`moon info` は public-interface snapshot を生成します。続く diff check は追跡されている
`pkg.generated.mbti` が source API と一致することを要求します。

## Tests が確立する内容

checked tests は certification failure の分類、public construction、inspection path を対象に
します。detail が `ArithmeticError::certification_failure` 後も保持されること、
precision/refinement input が正規化されること、既存 error predicates が
`is_certification_failure` と別であることを確立します。

contextual tests は、正確な `Int` 埋め込みと丸めを伴う埋め込み、符号付きゼロの方向、
NaN 伝播、停止する infinity、有限値から infinity への step、固定 IEEE `Float`/`Double`
形式での最小 subnormal からゼロへの step を対象にします。test package 内の実装は
contextual hyperbolic outcome と定数の certification-failure 伝播も検証します。

tests は `Float` または `Double` が certified arithmetic を実行するとは主張しません。共有の
capability vocabulary、固定形式の adjacent semantics、通常の error-model behavior を
検証します。

## Release Gate

`publish-package` GitHub workflow は明示的な release version を受け取り、それが `moon.mod`
と一致することを要求します。その後 registry を更新し、全 target を build/check し、
default/JavaScript/native tests を実行し、`LUNA_MOONCAKE` で publish して対応する GitHub
release を作成します。

CI は pull request と `main` への push で動作し、all-target build/check、
default/JavaScript/native tests、interface snapshot verification、formatting を繰り返します。
CI の成功は repository evidence であり、具体 backend の numerical conformance claim ではありません。
