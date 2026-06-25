# FTTR / 合约新宽新移 T+n 留存

## 适用

- 用户要求统计 FTTR 入网号码、合约入网号码在 T+1 到 T+n 的留存、在网数或打横宽表。
- 入网当月必须校验为“新宽带新移动”或其它 069 融合类型。
- 需要从 FTTR/合约专项清单圈服务，再回 069 月表跟踪后续月份状态。

## 不适用

- 普通宽带、移动入网量或到达量：走 069 标准入网/到达口径。
- 标准移动/宽带 T+n 有效率、停机率、欠费率、拆机率：走 `METRIC_INDEX.md` 的对应指标文件。
- 只查 FTTR/合约明细，不做 T+n 留存：直接按 `ROUTING.md` 选 002 或 004，再按需补 069 字段。

## 主路径

1. **圈入网对象**
   - FTTR：002 `dwm_fttr_list`，按 `par_month_id` 限定 FTTR 入网月；FTTR 入网月通常用 `substr(create_date,1,6)=par_month_id` 校验。
   - 合约：004 `dwm_yz_cm_cdma_hy_final`，按 `par_month_id` 限定合约入网月；合约/协议类型按 `data_type` 判断，用户未要求协议时默认保留合约口径并写明。
2. **回 069 校验融合类型**
   - 用 `专项清单.serv_id = 069.serv_id AND 专项清单.par_month_id = 069.par_month_id`。
   - 新宽新移默认过滤 `069.rh_type_ykj='新宽带新移动'`；其它融合类型按用户输入替换。
3. **拉取后续观察月份**
   - 用 069 月表 `dwm_yz_tb_comm_cm_all_mon_final`，按 `serv_id` 取观察窗口内的月快照。
   - 若用户要求剔除未竣工记录，可按已确认状态码过滤；本案例使用 `state=100000`，写 SQL 前需确认该码值在本环境稳定表示已竣工/有效服务状态。
4. **计算 T+n**
   - `T` 是专项清单入网月，不一定等于 069 号码入网月；FTTR 中存在非宽带号码时尤其不能用 069 `open_date` 替代 FTTR 入网月。
   - 推荐显式计算目标月：`add_months(concat(substr(T,1,4),'-',substr(T,5,2),'-01'), n)`，再转 `yyyyMM` 与 069 观察月比较。
   - 留存按“目标月仍有符合状态的 069 月快照”或“最大观察月覆盖目标月”判断，二者必须在方案确认时写清。
5. **打横输出**
   - 先产出服务级留存标记，再按 `type + T入网月` 汇总。
   - 打横字段用 `count(distinct case when t_n=1 then serv_id end)`；不要在明细和汇总同一步混用导致重复。

## 关键口径

- FTTR 入网月是 FTTR 设备/专项清单入网月；不能默认等同号码 069 入网月。
- 合约入网月是 004 合约清单账期；如需按竣工时间、合约生效时间或协议类型细分，必须先确认。
- “新宽新移”在 069 用 `rh_type_ykj='新宽带新移动'` 判断。
- 数据截止月需要单独处理：当 T+n 目标月大于最大可观测月时，分子应置空、剔除该 T+n，或按用户确认的截断规则处理；不要把没有未来数据误判为不留存。
- 若用户用“最大月份默认为拆机月份”表达留存，必须确认最大月是按 069 月表最大快照月、拆机月标签，还是目标月存在记录；三者结果可能不同。

## SQL 编排

正式交付使用多步 CTAS：

1. `tmp_*_fttr_base`：FTTR 入网对象。
2. `tmp_*_contract_base`：合约入网对象。
3. `tmp_*_base_union`：统一 `type, rw_month, acc_nbr, serv_id`。
4. `tmp_*_rh_checked`：同月回 069 校验 `rh_type_ykj` 和必要状态。
5. `tmp_*_observe_month`：069 月表观察窗口。
6. `tmp_*_tn_flag`：服务级 T+1 到 T+n 留存标记。
7. `ads_*_tn_retention`：按 `type, rw_month` 汇总打横。

过程表命名必须参数化，不沉淀一次性项目缩写或固定月份。

## 风险审计

- 检查 FTTR 入网月和号码 069 入网月是否混用；FTTR 场景以专项清单入网月为 T。
- 检查 069 月表观察窗口是否覆盖 `start_month` 到 `end_month + n`；不足时要标记截断，不直接算成流失。
- 检查同一 `serv_id` 在 FTTR 和合约两类中是否重复；若重复，默认分别在各自 `type` 下统计，跨类型去重需用户确认。
- 检查 `state=100000` 等状态码是否来自用户确认或字典，不要把一次案例码值无条件套到所有留存场景。
- 检查是否只用 `count(*)` 代表在网月数；若 069 在 T 之前已有记录，单纯计数会高估 T+n 留存，应按目标月或最大观察月与 T+n 月份比较。
- 检查截止月边界：截止月本身是否可按 `>=` 判断，未来月是否剔除或置空，必须与用户方案一致。

## 自检

```sql
-- 分母与去重
select type, rw_month, count(*) as rows_cnt, count(distinct serv_id) as serv_cnt
from {tmp_rh_checked}
group by type, rw_month;

-- FTTR/合约同服务重复
select serv_id, count(distinct type) as type_cnt
from {tmp_rh_checked}
group by serv_id
having count(distinct type) > 1
limit 20;

-- 观察月覆盖
select min(par_month_id) as min_month, max(par_month_id) as max_month, count(distinct par_month_id) as month_cnt
from {tmp_observe_month};

-- T+n 截断检查
select rw_month, tn, count(distinct serv_id) as denominator_cnt
from {tmp_tn_flag}
where target_month > ${max_observe_month}
group by rw_month, tn;
```
