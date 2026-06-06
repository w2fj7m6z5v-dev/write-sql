---
layer: D
title: "subs_stat 订单状态 字典"
field_name: "subs_stat"
applicable_tables: ["dwm_yz_rpt_comm_ba_msdisc_final", "dwm_yz_rpt_comm_ba_subs_final"]
dict_attr_id: "4000000059"
---

# subs_stat 订单状态 字典

> **字段含义**：订单当前状态。
>
> **字段类型**：字符串/数字（按表存储）。
>
> **字典来源**：维表 `dws_crm_cfguse.dws_attr_value`，`attr_id = '4000000059'`。
> 业务表 `subs_stat` 关联字典的 `attr_inner_value`（**不是** `attr_value`），取 `attr_value_name` 作为中文含义。

## 字典查询

```sql
SELECT attr_id, attr_value, attr_inner_value, attr_value_name
FROM dws_crm_cfguse.dws_attr_value
WHERE attr_id = '4000000059'
  AND city_id = '200';
```

## 已知码值

> 下表 `码值` 列为字典 `attr_value`（业务表 `subs_stat` 实际关联的是 `attr_inner_value`，多数场景与 `attr_value` 一致；如不一致以上方查询的 `attr_inner_value` 为准）。

| 码值 | 含义 | 备注 |
|------|------|------|
| `100000` | 受理录入 | |
| `101100` | 待审核 | |
| `101200` | 待收费 | |
| `101300` | 待确认 | |
| `101400` | 客户需求确认 | |
| `200000` | 等待调度 | |
| `201100` | 营业质检 | |
| `201200` | 缓装 | |
| `201300` | 开通中 | |
| `201400` | 已开通 | |
| `201500` | 待确认起租 | |
| `201600` | 已确认起租 | |
| `201700` | 待发送 | |
| `201800` | 实名制认证中 | |
| `201801` | 实名制认证中 | |
| `201802` | 实名制认证未通过 | |
| `299998` | 预算费 | |
| `299999` | 预受理 | |
| `300000` | 竣工 | 竣工大类入口状态 |
| `301100` | 竣工中 | |
| `301200` | 完工 | 销售品订单的"成功完成"终态；常作为 `is_jg = CASE WHEN subs_stat='301200' THEN 1 ELSE 0 END` 的判定 |
| `301300` | 补换卡竣工 | |
| `400000` | 异常 | |
| `401100` | 前端错误 | |
| `401200` | 后端错误 | |
| `401300` | 撤销 | |
| `401400` | 已退单 | |
| `401500` | 确认开装中 | |
| `401600` | 确认开装中 | |
| `401700` | 待装中 | |
| `499999` | 无效 | |
| `500000` | 出库/发货 | |
| `503100` | 申请单审核通过 | |
| `503200` | 申请单审核未通过 | |
| `503300` | 实物审核通过 | |
| `503400` | 实物审核未通过 | |
| `503600` | 已出库/待发货 | |
| `503700` | 已发货 | |
| `503800` | 已签收 | |
| `503900` | 客户拒收 | |
| `504000` | 退换货结束客户已确认 | |
| `504300` | 预订终端订货 | |
| `504400` | 用户确认交易完成 | |
| `504500` | 用户确认激活新卡 | |
| `504600` | 卡号已回填 | |
| `999999` | 修改中 | |

## 使用模板

```sql
-- 标记是否竣工（推荐：标记列，不进 WHERE）
SELECT CASE WHEN subs_stat = '301200' THEN 1 ELSE 0 END AS is_jg, ...
```

```sql
-- 仅当用户明确"只看竣工"时才进 WHERE
WHERE subs_stat = '301200'
```

```sql
-- 关联字典维表取中文含义（subs_stat ↔ attr_inner_value）
SELECT t.subs_stat, d.attr_value_name AS subs_stat_name
FROM <业务表> t
LEFT JOIN dws_crm_cfguse.dws_attr_value d
  ON d.attr_id = '4000000059'
 AND d.city_id = '200'
 AND t.subs_stat = d.attr_inner_value;
```

## 参考

- 通常配合 [`subs_stat_reason`](subs_stat_reason.md) 一起使用：`subs_stat_reason` 给出"为什么是这个状态"
- 未收录码值 → 查 `dws_crm_cfguse.dws_attr_value`（`attr_id='4000000059'`）字典维表，或问用户
