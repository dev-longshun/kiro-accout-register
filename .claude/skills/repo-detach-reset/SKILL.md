---
name: repo-detach-reset
description: 克隆仓库去关联与历史重置协议。用于将克隆或 Fork 的仓库转换为独立 DIY 仓库：检查许可约束、切断与原仓库连接、重建 git 历史、隔离工作流与部署入口。涉及破坏性操作时必须先给方案并等待用户明确授权。
user-invocable: false
---

# 仓库去关联重置 Skill

## 适用场景

当用户提出以下需求时启用本 skill：
- 抹除克隆仓库信息
- 删除历史提交记录并重新初始化 git
- 切断与原仓库/Fork/upstream 的连接
- 清理 README、作者信息、原仓库痕迹
- 禁止工作流误触发到原仓库或原作者环境

## 核心限制 (强制)

**禁止未授权直接执行破坏性操作**：必须先给方案并等待用户明确授权（如"执行""开始处理"）。

**必须先做许可检查**：
- 若仓库包含 `LICENSE`、`COPYING`、`NOTICE`，先识别许可证类型再决定是否可删除。
- GPL/AGPL/LGPL/MPL 等有传染或保留义务的许可证，默认不删除许可证与版权声明。
- 许可证判断不清晰时，必须先提示风险并等待用户确认。

**必须先做可回滚备份**：
- 至少备份 `.git` 目录。
- 推荐同时备份整个项目目录到同级安全路径（带时间戳）。

**禁止使用 `rm` 删除文件**：必须使用 `trash`。

## 标准工作流

### 1. 预检查（只读）

1. 检查 git 状态与当前分支：
   - `git rev-parse --is-inside-work-tree`
   - `git branch --show-current`
   - `git status --short`
2. 检查远程连接与 Fork 线索：
   - `git remote -v`
   - `git config --get remote.origin.url`
3. 检查许可证与仓库说明文件：
   - `rg --files | rg '^(LICENSE|COPYING|NOTICE|README(\\..+)?)$'`
4. 检查工作流与部署入口：
   - `rg --files .github/workflows`
   - `rg -n 'docker|deploy|release|workflow_dispatch|repository_dispatch' .github/workflows || true`

### 2. 方案输出（必须）

向用户明确说明：
- 将执行的破坏性动作（删除历史、移除 remote、清理 README、处理工作流）
- 许可证处理策略（保留或删除，及原因）
- 回滚点（备份路径）
- 验证标准（新历史是否只有初始化提交、remote 是否仅保留新 origin）

### 3. 授权后执行

#### 3.1 备份

- 备份 `.git`：
  - `ts=$(date +%Y%m%d-%H%M%S); cp -R .git ../.git-backup-$ts`
- 需要高安全时，备份整个目录（同级新目录）。

#### 3.2 切断与原仓库连接

- 删除 `upstream`（若存在）：
  - `git remote remove upstream`
- 删除旧 `origin`（若存在）：
  - `git remote remove origin`

#### 3.3 重建 git 历史

- 将旧 `.git` 放入废纸篓：
  - `trash .git`
- 重新初始化：
  - `git init`
- 恢复忽略规则后执行首提：
  - `git add -A`
  - `git commit -m "chore: initialize independent repository"`

#### 3.4 清理仓库身份信息

- README 清理按用户要求处理：
  - 删除：`trash README.md`（或对应语言版本）
  - 重写：创建新的项目说明，避免保留原作者/原仓库链接
- 清理明显的原仓库标识：
  - `rg -n 'github.com/.+/.+|upstream|fork'`

#### 3.5 工作流与部署隔离

- 默认禁用原工作流（避免误触发）：
  - `mkdir -p .github/workflows.disabled`
  - `mv .github/workflows/*.yml .github/workflows.disabled/ 2>/dev/null || true`
  - `mv .github/workflows/*.yaml .github/workflows.disabled/ 2>/dev/null || true`
- 若用户需要保留工作流，必须改造后再启用：
  - 改为仅使用当前仓库 secrets
  - 删除对原仓库 owner/repo 的硬编码
  - 重新评估 Docker 发布目标与镜像命名空间

#### 3.6 绑定新仓库

- 添加新 `origin`（用户提供 URL）：
  - `git remote add origin <NEW_REPO_URL>`

### 4. 执行后验证

必须验证并汇报：
1. `git log --oneline -n 5` 仅包含新的初始化提交（或用户新提交）。
2. `git remote -v` 不再包含原仓库地址。
3. `.github/workflows` 不存在可自动触发的旧发布流程，或已完成重写并指向新仓库。
4. README/项目元信息不再引用原仓库（除许可证要求保留部分）。

## 回滚策略

若用户要求回滚：
1. 将当前 `.git` 先 `trash`。
2. 用备份 `.git` 恢复：
   - `cp -R ../.git-backup-<timestamp> ./.git`
3. 重新检查 `git log` 与 `git remote -v`。

## 输出规范

完成后必须输出：
1. 预检查结论
2. 执行动作清单
3. 验证结果清单
4. 许可证处理结论
5. 新增文件清单与修改文件清单
