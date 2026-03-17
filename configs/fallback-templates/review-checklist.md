# L3 兜底: 代码审查清单（当 reviewer Agent 降级失败时使用）

> 当 L1(sonnet) 和 L2(haiku) reviewer 均失败时，按以下清单人工审查。

## 必查项（每个文件）

### 安全性
- [ ] 无硬编码密钥/密码/token
- [ ] 用户输入已验证和转义
- [ ] 文件路径无目录遍历风险
- [ ] SQL 查询使用参数化（非字符串拼接）
- [ ] 无 `eval()` 或动态代码执行

### 正确性
- [ ] 空值/undefined 已处理
- [ ] 异步操作有错误处理（try/catch 或 .catch）
- [ ] 循环有退出条件（无无限循环风险）
- [ ] 边界条件已考虑（空数组、零值、超大输入）

### 风格
- [ ] 命名符合项目约定（camelCase/PascalCase/kebab-case）
- [ ] 无 `as any` 或 `@ts-ignore`
- [ ] 函数长度合理（<50 行）
- [ ] 无重复代码块（>10 行重复需提取）

## 自动化验证（替代 LLM 审查）
```bash
# 运行 lint
npx eslint --quiet <changed-files>    # 或项目配置的 lint 命令

# 运行类型检查
npx tsc --noEmit

# 运行测试
npm test                               # 或项目配置的测试命令

# 检查敏感信息
grep -rn 'sk-\|token=\|secret=\|password=' <changed-files>
```

## 通过标准
- lint 0 errors（warnings 可接受）
- 类型检查 0 errors
- 测试全部通过
- 无敏感信息泄露
