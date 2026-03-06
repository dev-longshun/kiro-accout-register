# 批量同步指南

本文档是给 AI 助手阅读的操作指令。当用户要求将本模板的开发协议批量同步到某个工作目录下的所有项目时，请严格按照以下步骤执行。

## 前置要求

1. 用户指定目标工作目录路径
2. 扫描该目录下的所有一级子目录，识别项目（包含 `.git` 目录的文件夹视为项目）
3. 自动跳过以下目录：
   - 模板自身（`_project-template`）
   - worktree 目录（目录名包含 `--` 的文件夹）
   - 以 `.` 或 `_` 开头的隐藏/特殊目录
4. 列出所有识别到的项目，向用户确认同步范围后再执行

## 项目分类

对每个项目进行分类：

- **全新项目**：不存在 `.claude/skills/protocol-dev/` 目录 → 执行完整移植
- **已有项目**：已存在 `.claude/skills/protocol-dev/` 目录 → 执行增量同步

## 全新项目：完整移植

严格按照 `SETUP.md` 的移植步骤执行，包括：

1. 复制所有协议文件（`.claude/`、`.codex/`、`.kiro/`、`.cursor/`、`CLAUDE.md`、`AGENTS.md`）
2. 分析项目技术栈，适配占位符
3. 平台特定补充（如适用）

每个项目移植前需向用户确认技术栈分析结果。

## 已有项目：增量同步

### 第一步：对比文件差异

逐一对比模板与目标项目中以下文件的内容：

- `.claude/skills/protocol-dev/SKILL.md`
- `.claude/skills/protocol-dev/references/` 下所有文件
- `.codex/skills/protocol-dev/SKILL.md`
- `.codex/skills/protocol-dev/references/` 下所有文件
- `.cursor/skills/protocol-dev/SKILL.md`
- `.cursor/skills/protocol-dev/references/` 下所有文件
- `.kiro/steering/` 下所有文件
- `.claude/settings.json`
- `CLAUDE.md`
- `AGENTS.md`

### 第二步：分类处理差异

根据对比结果，按以下规则处理：

- **模板中新增的文件**（目标项目不存在）：直接复制到目标项目，如果文件含占位符则根据项目特征适配
- **模板中修改的文件**（目标项目已存在但内容不同）：
  - `references/` 下的参考文档：以模板为准覆盖更新（这些是通用规范）
  - `SKILL.md`：以模板为准更新通用部分，保留目标项目已有的平台特定内容（如自定义的 references 条目、项目专属占位符值）
  - `CLAUDE.md`：更新关键约束部分（以模板为准），保留项目基础信息和项目结构部分不变
  - `AGENTS.md`：以模板为准覆盖更新（该文件是 Codex 的项目级入口指令）
  - `.claude/settings.json`：合并权限配置，模板中新增的权限追加到目标项目，目标项目已有的权限保留
- **目标项目独有的文件**（模板中不存在）：保留不动，不删除

### 第三步：验证同步结果

对每个项目，检查同步后的文件完整性：

- 所有模板中的文件在目标项目中都存在
- `settings.json` 的 JSON 格式合法
- 占位符已被正确替换（不应残留 `[项目名称]` 等未替换的占位符）

## 禁止事项

- 禁止删除目标项目中任何已有文件
- 禁止覆盖目标项目的 `settings.json`，只能合并
- 禁止修改目标项目 `CLAUDE.md` 中的项目基础信息和项目结构
- 禁止在未经用户确认的情况下执行同步

## 同步完成后

向用户输出汇总报告，格式如下：

```
同步完成，共处理 N 个项目：

[全新移植]
- project-a：已完成完整移植（技术栈：Swift/iOS）
- project-b：已完成完整移植（技术栈：TypeScript/React）

[增量同步]
- project-c：更新 3 个文件，新增 1 个文件
- project-d：无变更，已是最新

[跳过]
- _project-template：模板自身
- project-c--feat-auth：worktree 目录
```
