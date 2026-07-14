# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## 项目概述

本仓库是 CDAP（电信业务数据分析平台）的 SQL 编写技能集，核心功能：

1. **write-query 技能** — 根据自然语言描述编写优化的 Hive SQL 查询

## 技能架构

本仓库同时兼容 Codex 和 Claude Code：

- `.agents/skills/` 是 Codex 入口。
- `.claude/skills/` 是 Claude Code 入口。
- 两边都进 Git，作为双入口维护；提交前必须保持内容一致。
- Windows / PowerShell 环境优先使用 `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_skills.ps1 check` 检查一致性；需要同步时显式指定方向，例如 `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_skills.ps1 -Mode Sync -From agents -Force`。
- Git Bash 正常可用时，也可使用 `bash scripts/sync_skills.sh check`；若遇到 `Win32 error 5`，改用 PowerShell 版脚本。

```
.agents/skills/
└── write-query/
    ├── SKILL.md
    ├── scripts/
    │   ├── audit_sql.py
    │   └── lint_metric_index.py
    └── references/
        ├── TABLE_INDEX.md      # 运行时表索引 / schema linking
        ├── METRIC_INDEX.md     # 指标 → 技术口径 → 表文档统一索引
        ├── ROUTING.md          # 业务术语与主表路由
        ├── FIELD_BACKFILL.md   # 字段缺口补表规则
        ├── RULES.md            # SQL 生成后审计规则
        ├── tables/             # 各表字段、分区、粒度
        ├── metrics/            # 单指标技术口径文件
        └── verified-cases/     # 已验证案例与模板
```

## 常用命令

### 查看可用表
参考 `Codex/skills/write-query/references/TABLE_INDEX.md`，按业务主题（核心事实表、收入表、积分表、维表）查找目标表。

### Git 提交
- 提交信息使用中文，格式优先为“动作 + 范围 + 结果”，简短说明一次逻辑变更。
- 常用动作：`新增`、`修复`、`完善`、`重构`、`整理`、`沉淀`、`更新`；避免使用“修改代码”“更新文件”等无法说明目的的描述。
- 一个提交只包含一个逻辑主题；不要把无关的 SQL、文档、依赖或临时文件混入同一提交。
- 提交前先检查 `git diff --cached --check` 和 `git diff --cached --stat`，确认暂存区只包含本次工作；已有用户改动必须保持未暂存。
- 修改 `.agents/skills/` 或 `.claude/skills/` 时，提交前必须执行 `bash scripts/sync_skills.sh check`；macOS 的 `.DS_Store` 噪声应单独识别，不能用同步命令覆盖或清理用户文件。
- 规则或行为变更涉及多个文件时，提交正文可补充“变更原因 / 主要内容 / 验证结果”；简单修复只保留标题即可。
- 示例：`修复 write-query 同表异轴多指标编排规则`、`完善字段补表与 SQL 占位规则`、`沉淀专线月租表口径`、`重构指标索引校验逻辑`。

## 工作流程

### 编写 Hive SQL
1. 以 `write-query/SKILL.md` 为唯一运行时流程权威。
2. 主表选择 → `TABLE_INDEX.md` + `ROUTING.md`；标准指标 → `METRIC_INDEX.md` + 命中单指标文件。
3. 字段映射 → `references/tables/{序号}_{表名}.md`；缺字段补表 → `FIELD_BACKFILL.md`。
4. SQL 生成后用 `RULES.md` 和相关字典审计，输出中注明口径来源。

## 表索引分类

`TABLE_INDEX.md` 按业务主题将 104 张表分为：

| 分类 | 说明 |
|------|------|
| 核心事实表 | 全业务资料表、订单表、新装清单等核心业务表 |
| 收入表 | 基本面月清单、科目级收入、台阶收入等 |
| 续约表 | 移动/宽带/双线续约相关 |
| 积分表 | 净增积分、存量积分、揽装积分 |
| 降档表 | 降档原始清单、129+套餐升降档路径 |
| 维表 | 产品、机构、字典、销售品等维度表 |
| 补充表 | 优惠、欠费、滞纳金等补充数据 |
| 客户类 | 商客、企微粉丝、满卡等客户表 |
| 成本/佣金类 | 佣金、终端装维成本 |
| 其他清单 | 反诈、拆机挽留、实名制等 |

## 表查找规则

优先查找专项表：
- 台阶收入 → `台阶收入清单`(101)
- 科目收入 → `全量科目级收入`(048)
- 号码订单 → `全业务号码订单表`(040)
- 套餐订单 → `宽带到达套餐收入清单`(050)

## 注意事项

- `TABLE_INDEX.md` 中 Hive 表名已补充完成（2026-04-13）
- 口径案例仅当原 Excel 包含案例指标时才会输出
