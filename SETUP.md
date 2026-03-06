# 移植指南

本文档是给 AI 助手阅读的操作指令。当用户要求将本模板的开发协议移植到一个已有项目时，请严格按照以下步骤执行。

## 前置要求

1. 确认目标项目路径
2. 分析目标项目的技术栈、平台、最低支持版本等基本信息
3. 向用户确认分析结果，获得授权后再执行移植

## 移植步骤

### 第一步：复制协议文件

将以下目录和文件**原样复制**到目标项目根目录：

- `.claude/settings.json`
- `.claude/skills/protocol-dev/SKILL.md`
- `.claude/skills/protocol-dev/references/`（整个目录）
- `.codex/skills/protocol-dev/SKILL.md`
- `.codex/skills/protocol-dev/references/`（整个目录）
- `.kiro/steering/`（整个目录）
- `.cursor/skills/protocol-dev/SKILL.md`
- `.cursor/skills/protocol-dev/references/`（整个目录）
- `CLAUDE.md`
- `AGENTS.md`

如果目标项目已有 `.claude/settings.json`，需要合并而非覆盖，保留目标项目已有的权限配置。

### 第二步：适配占位符

只修改以下占位符，其余内容**禁止改动**：

- `[项目名称]` → 实际项目名称
- `[技术栈]` → 实际技术栈描述
- `[最低支持版本]` → 实际最低支持版本（如 iOS 15.5、macOS 15、Node 18 等）
- `[项目结构]` → 实际项目目录结构简述
- `[根据项目平台填写编译规范，例如：禁止通过命令行编译项目，提醒用户手动编译验证]` → 实际编译规范

适配范围仅限 `SKILL.md`（四份）、`protocol-dev.md`（.kiro 版）、`CLAUDE.md` 和 `AGENTS.md`。

### 第三步：平台特定补充（可选）

根据项目平台，可以新增平台专属的参考文档，例如：

- iOS 项目：新增 `references/ios-version-guide.md`，记录 API 兼容性规则
- macOS 项目：新增 `references/macos-version-guide.md`
- Electron 项目：新增 `references/electron-guide.md`

新增文档后，在 SKILL.md 的"参考文档索引"章节中补充对应条目。

## 禁止改动的核心规则

以下内容是所有项目通用的，移植时**绝对不能修改**：

- commit 提交协议（先审核再提交 + 禁止辅助编程标识）
- commit 格式规范（Angular + Gitmoji + 单代码块输出）
- 核心限制（STOP Rule）和授权指令识别
- 调试工作流（DEBUG-FIRST Rule）
- 文件删除规范（trash 不 rm）
- 分支合并工作流
- 格式规范（禁止 Markdown 表格）

## 移植完成后

1. 向用户输出新增/修改的文件清单
2. 提醒用户检查 `.gitignore` 是否排除了 `.claude/`、`.codex/`、`.kiro/`、`.cursor/` 目录（这些目录应该被 git 跟踪）
