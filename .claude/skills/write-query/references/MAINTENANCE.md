---
title: "知识库维护准则"
runtime: false
---

# 知识库维护准则

> **运行时禁读**。供维护 write-query 技能时查阅，避免知识库继续臃肿或漂移。日常取数流程以 `SKILL.md` 为准。

## 防臃肿铁律

1. **单一事实源**：同一规则只在一个文件写完整版，其它位置只留指针。
2. **第 3 次复用升 SC**：同一复杂链路在 3 个不同工单复用后，从 ROUTING / FIELD_BACKFILL / RULES 升级为 `scenarios/SC-*.md`。
3. **SC 与 VC 分工**：`SC-*.md` = 可复用专项规则 + 自检；`VC-*.md` = 已验证具体 SQL 实例。可并存互引。
4. **附件表抽象化**：一次性 `zone_gz_yz_*` 工单表名不进索引，写作「用户附件种子表」。
5. **禁止回填 `_archive/`**：`D_experience/_archive/` 仅历史溯源。

## 新增内容写哪里

| 新增内容类型 | 写入位置 | 不应写入 | 判断标准 |
|---|---|---|---|
| 新业务术语 / 口语映射 | `ROUTING.md` 术语映射、术语→字段反查 | `SKILL.md`、`TABLE_INDEX` 路由语义 | 用户怎么说 → CDAP 概念 / 字段 |
| 主表路由经验 | `ROUTING.md` 主表路由表 | `TABLE_INDEX` 快速定位、`FIELD_BACKFILL` | 需求 → 主表 + 不要误选 |
| 标准指标口径 | `metrics/{域}/M-*.md` + `METRIC_INDEX.md` 一行 | `ROUTING` 长 SQL、`RULES` | 有稳定 `metric_name` 和技术口径 SQL |
| 通用字段补表规则 | `FIELD_BACKFILL.md` 补表规则表 | `ROUTING` 补表细节 | ≤1 表 JOIN；主表缺字段 → 补哪张表 |
| 多步补表链路（如 069→014→107） | `FIELD_BACKFILL.md` 独立小节（单一事实源） | `ROUTING` 三步展开 | 固定多表顺序 + JOIN 键 |
| SQL 硬规则 / 反模式 | `RULES.md` | `SKILL.md`、专项 SC | 跨场景通用、与具体工单无关 |
| 复杂专项取数场景 | `scenarios/SC-*.md` + `scenarios/INDEX.md` | `ROUTING`/`RULES`/`FIELD_BACKFILL` 长流程 | 附件驱动、CTAS、跨表编排、专项自检 |
| 已验证完整案例 | `verified-cases/VC-*.md` + `INDEX.md` | 通用规则文件 | 具体 SQL 实例；不定义新口径 |
| 码值字典 | `D_experience/dictionaries/{field}.md` | `RULES` 长列表 | 字段码值 → 含义 |
| 复盘 / 踩坑日志 | `lessons_learned.md` | 运行时 ROUTING/RULES | 只记录过程；经验须反向更新到上表对应文件 |
| 表字段 / 分区 / 粒度 | `tables/{序号}_{表名}.md` | `ROUTING` | 单表元数据 |
| 新表登记 | `TABLE_INDEX.md` 一行 | 业务路由长说明 | id / hive / file_path；适用范围写入 `ROUTING.md` 或表文档 |

## 表文档最小元数据规范

表文档逐步迁移到 Markdown frontmatter。最小字段如下，值必须来自表文档、索引或已验证 SQL；无法确认时写 `"unknown"`，不得凭经验猜测：

```yaml
---
table_id: "069"
title: "全业务资料表"
hive_name: "..."
grain: "..."
partition_keys: ["par_month_id"]
---
```

- `table_id`：对应 `TABLE_INDEX.md` 的表编号。
- `title`：表文档标题；历史文档缺失时迁移补齐。
- `hive_name`：文档主 Hive 名；生产名用 `hive_name_production` 或 `prod_hive_name` 表达，不覆盖原始事实。
- `grain`：已确认的数据粒度；不确定时标记 `"unknown"`。
- `partition_keys`：分区字段列表；确认无分区时写 `[]`，未知时写 `["unknown"]`。

迁移分批进行：默认 lint 只报告覆盖率，不把 90 份旧格式文档直接判失败；完成一批后使用 `--strict` 验证该批次或最终全量质量门。

## 不应写进核心文件的内容

| 文件 | 禁止承载 |
|---|---|
| `SKILL.md` | 业务口径、表名、码值、SQL 片段、专项补表步骤 |
| `TABLE_INDEX.md` | 业务路由决策树、粒度/分区、补表 JOIN、指标公式 |
| `ROUTING.md` | 专项完整流程、补表三步链、收入公式（指针即可） |
| `RULES.md` | 专项场景长规则（指针到 SC）、成熟 CTAS 全文 |
| `FIELD_BACKFILL.md` | 完整 CTAS 专项（应下沉 SC） |
| `verified-cases/` | 通用规则、新标准口径定义 |

## 专项场景指针约定

- `scenarios/INDEX.md` 是 `SC-001`~`SC-*` 带完整文件路径和适用范围的**唯一**目录。
- `ROUTING.md` 的术语映射 / 主表路由表只写主表 + `见 scenarios/INDEX.md（SC-00x）`；不得在其中复制专项目录。
- 新增或重命名 `SC-*.md` 时，先更新 `scenarios/INDEX.md`，再检查 `ROUTING.md` / `FIELD_BACKFILL.md` 是否只保留指针。
- 补表类单一事实源示例：`FIELD_BACKFILL.md` **§销售品参数值（107）**。

## 提交前检查

```bash
# 双入口一致（Windows / PowerShell）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_skills.ps1 check

# 指标索引校验（可选）
python .claude/skills/write-query/scripts/lint_metric_index.py

# 表文档元数据覆盖率（迁移完成后可加 --strict）
python .claude/skills/write-query/scripts/lint_table_metadata.py
```

Git Bash 正常可用时也可运行 `bash scripts/sync_skills.sh check`；Windows 若出现 `Win32 error 5`，以 PowerShell 版脚本为准。

## 版本与归档

- 老 D 层经验已并入 `ROUTING` / `FIELD_BACKFILL` / `RULES`；勿再编辑 `_archive/`。
- 修改 ROUTING / FIELD_BACKFILL / RULES 时，检查是否与其它文件重复；重复则删副本、留指针。
- **已废弃 table_id**：`013` 全业务资料表已合并入 `069`；`021` 揽装所属表已合并入 `113`；勿再新建对应旧文档或在索引中登记。

## 表文档合并原则

- 同 Hive 表只保留一个 `table_id` 与一份 A 层表文档（字段最全、含 frontmatter 者优先）。
- 合并后：删重复表文档、删 `TABLE_INDEX` 重复行、全库引用统一指向保留的 `table_id`。
