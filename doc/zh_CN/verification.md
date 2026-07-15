# 验证

## 本地门禁

发布前运行同一组检查：

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

`moon info` 会生成 public-interface snapshot；随后 diff 检查保证已跟踪的
`pkg.generated.mbti` 与源 API 一致。

## 测试所能证明的内容

checked tests 覆盖 certification failure 的分类、公开构造和检查路径：detail 经过
`ArithmeticError::certification_failure` 后仍被保留，precision/refinement 输入会规范化，且已有
error predicates 与 `is_certification_failure` 保持互斥。

测试不声称 `Float` 或 `Double` 执行 certified arithmetic；它们只验证共享 capability vocabulary
及其普通 error-model 行为。

## 发布门禁

`publish-package` GitHub workflow 接受显式 release version，并要求它与 `moon.mod` 相等。之后
它更新 registry，构建并检查所有 target，运行 default/JavaScript/native tests，使用
`LUNA_MOONCAKE` 发布，最后创建对应 GitHub release。

CI 会在 pull request 和 push 到 `main` 时运行，并重复 all-target build/check、
default/JavaScript/native tests、interface snapshot 验证和 formatting。通过 CI 是仓库证据，
并不构成任何具体后端的数值 conformance 声明。
