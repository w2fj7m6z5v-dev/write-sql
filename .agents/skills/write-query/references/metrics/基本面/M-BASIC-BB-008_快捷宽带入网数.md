---
metric_id: "M-BASIC-BB-008"
metric_name: "快捷宽带入网数"
domain: "基本面"
category: "宽带"
period: "日/月/年"
cdap_flow: "日生产"
owners:
  business: "谢蕴秀"
  technical: "陈浩南"
source_file: "宽带.md"
---

# [M-BASIC-BB-008] 快捷宽带入网数

## 指标属性

| 字段 | 值 |
|------|-----|
| 业务板块 | 基本面 |
| 业务分类 | 宽带 |
| 统计周期 | 日/月/年 |
| 业务口径责任人 | 谢蕴秀 |
| 技术口径责任人 | 陈浩南 |
| CDAP生产流程 | 日生产 |

## 业务口径

(未填写)

## 技术口径（SQL）

```sql
SELECT
count(serv_id)  
FROM view_ads_yz_kd_new_list 
WHERE par_month_id =202603 -- 月份  
AND date_format(open_date, 'yyyyMMdd') >= 20260301
AND date_format(open_date, 'yyyyMMdd') <= 20260331
and prod_type3='快捷宽带'
;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。

## 快捷宽带入网积分

快捷宽带入网积分与入网数同主表（069 全业务资料表）、同过滤条件（`prod_type3='快捷宽带'`、`is_new_user=1`、`open_date`），度量为 `SUM(jz_points)`（套餐价值积分，分摊后）。与主宽入网数/入网积分（M-BASIC-BB-001/002）的模式一致。

## 依赖说明

- 相关表请通过 `../../METRIC_INDEX.md` 定位 A 层表文档；技术口径仍以本文件 SQL 为准。
