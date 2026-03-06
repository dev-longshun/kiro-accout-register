# Kiro-auto-register AGENTS 指令

## Skills
Skill 是存放在 `SKILL.md` 中的一组本地指令。

### 可用 Skills
- `protocol-dev`：高级技术架构师开发协议，强制执行"先谋后动"工作流，覆盖代码修改、Bug 调试、Commit 信息生成、分支合并、版本发布等流程。 (file: `./.codex/skills/protocol-dev/SKILL.md`)
- `repo-detach-reset`：克隆/Fork 仓库去关联与历史重置协议，用于切断原仓库连接、重建 git 历史、清理 README 与工作流部署链路。 (file: `./.codex/skills/repo-detach-reset/SKILL.md`)

### Skills 使用规则
- 触发规则：当用户提出代码修改、Bug 调试、生成 Commit 信息、分支合并/同步、版本发布需求时，必须启用 `protocol-dev`。
- 触发规则：当用户提出抹除克隆仓库信息、删除历史提交、切断 upstream/origin、重建 git 仓库、清理 README、禁用或隔离原工作流/部署链路时，必须启用 `repo-detach-reset`。
- 显式触发：当用户明确提到 `protocol-dev`（`$protocol-dev` 或纯文本）时，必须启用该 skill。
- 显式触发：当用户明确提到 `repo-detach-reset`（`$repo-detach-reset` 或纯文本）时，必须启用该 skill。
- 作用范围：skill 默认只作用于当前轮对话，除非用户再次提及。
- 文件缺失：若 skill 文件不可读，先简要说明问题，再按最接近的流程继续执行。

### Skill 加载策略
- 仓库去关联类需求优先读取 `./.codex/skills/repo-detach-reset/SKILL.md`。
- 代码修改、调试、commit、发布类需求优先读取 `./.codex/skills/protocol-dev/SKILL.md`。
- 同时命中多个 skill 时，按任务主目标选择最小必要集合；若涉及破坏性仓库操作并伴随代码修改，先执行 `repo-detach-reset` 再执行 `protocol-dev`。
- `SKILL.md` 引用 `references/` 时，只按当前任务加载必要文件，不要一次性全量读取。
- 本文件只定义 Codex 入口规则；具体执行约束以 `SKILL.md` 为准，并与 `CLAUDE.md` 的关键约束保持一致。
