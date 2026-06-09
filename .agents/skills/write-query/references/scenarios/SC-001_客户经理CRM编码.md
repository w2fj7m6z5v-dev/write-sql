# 客户经理 CRM 编码

## 适用

- 用户给号码清单，要求补客户经理 CRM 编码、11 开头工号、员工账号、员工姓名或员工标识。
- 需要以某账期号码当前揽装人为准，而不是信附件中自带的揽装人编码。

## 不适用

- 只查主表已有的揽装人姓名或工号：先看主表字段。
- 查市场化合同下有效揽装人或实际工号数量：用 `SC-007_市场化合同有效揽装人.md`。
- 查受理人、协销人：先回到 `ROUTING.md` 和 `FIELD_BACKFILL.md` 判断订单/协销事实。

## 主表与补表

| 角色 | 表 | 用途 |
|---|---|---|
| 驱动表 | 用户附件号码清单 | 保留原始序号和号码 |
| 主表 | 069 全业务资料表 `dwm_yz_tb_comm_cm_all_final` / 月表 | 按 `acc_nbr + par_month_id` 取当前 `serv_id`、`sales_code` |
| 补表 | 115 员工信息表 `dws_crm_cfguse.dws_staff` | 用 `staff_code` 补 `staff_account/staff_name/staff_id` |

## 关键规则

- 必须先按用户指定账期锁 069 快照；未给账期时先确认。
- `069.sales_code = staff.staff_code`，员工表固定 `city_id='200'`、`staff_account like '11%'`。
- 115 可能有历史多版本，先用 `row_number() over(partition by staff_code order by status_date desc, update_ts desc)` 取最新。
- 附件已有揽装人编码时，默认只作为核查字段；除非用户明确要求按附件编码匹配。
- 附件驱动要保留原序号，最终核对输入行数、069 命中行数、员工表命中行数、输出行数。

## 输出字段建议

| 需求字段 | 来源 |
|---|---|
| 原始号码 / 序号 | 用户附件 |
| 服务标识 | 069 `serv_id` |
| 当前揽装人工号 | 069 `sales_code` |
| CRM 编码 / 11 开头工号 | 115 `staff_account` |
| 员工姓名 | 115 `staff_name` |
| 员工标识 | 115 `staff_id` |

## 风险审计

- 未命中 069：可能是账期不在网、拆机、号码不一致或号码类型不匹配。
- 员工表未去重：可能一号多行放大附件清单。
- `status_date` 正序取数会取到最旧记录，必须倒序。

