-- ==============================================
-- 融合用户入网及留存分析
-- 需求：2024年1月~2026年5月新宽新移融合用户
--      分类：新宽新移并办理FTTR / 新宽新移并办理合约（不互斥、重复计数）
--      按入网月份输出入网量及T+1~T+24留存率
-- 口径：融合=069.is_rh_ykj=1 AND rh_type_ykj='新宽带新移动'
--      留存=T+N月时宽带is_cancel_user=0 AND is_cz=1
-- 粒度：按宽带serv_id（kd_serv_id）
-- ==============================================

-- ----------------------------------------------------
-- 步骤1：cohort + 打标（FTTR / 合约，不互斥）
-- 输出：tmp_rh_cohort_tagged
-- ----------------------------------------------------
drop table if exists tmp_rh_cohort_tagged purge;
create table tmp_rh_cohort_tagged
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    t.kd_serv_id,
    t.kd_acc_nbr,
    t.mv_serv_id,
    t.mv_acc_nbr,
    t.rh_tc_id,
    t.cust_id,
    t.cust_nbr,
    substr(cast(t.open_date as string), 1, 6) as open_month,
    -- 1 = 命中；0 = 未命中；不互斥
    case when f.serv_id is not null then 1 else 0 end as has_fttr,
    case when h.serv_id is not null then 1 else 0 end as has_contract
from (
    -- 新宽新移融合用户（cohort：宽带当月新入网，剔除专线/快捷）
    select
        a.serv_id as kd_serv_id,
        a.acc_nbr as kd_acc_nbr,
        a.cust_id,
        a.cust_nbr,
        a.rh_tc_id,
        a.open_date,
        b.serv_id as mv_serv_id,
        b.acc_nbr as mv_acc_nbr
    from dwm_yz_tb_comm_cm_all_mon_final a
    inner join dwm_yz_tb_comm_cm_all_mon_final b
        on a.rh_tc_id = b.rh_tc_id
        and a.par_month_id = b.par_month_id
        and a.prod_type = 40          -- 宽带
        and b.prod_type = 30          -- 移动
        and b.is_cancel_user = 0      -- 移动在网
    where a.par_month_id between '202401' and '202605'
        and a.is_new_user = 1
        and substr(cast(a.open_date as string), 1, 6) between '202401' and '202605'
        and a.kd_desc = '普通宽带'
        and a.is_rh_ykj = 1
        and a.rh_type_ykj = '新宽带新移动'
        and coalesce(a.prod_name, '-1') not like '%专线%'
        and coalesce(a.prod_name, '-1') not like '%城域网%'
        and coalesce(a.kd_prod_offer_name, '-1') not like '%0时长%'
) t
-- FTTR：宽带serv_id 或 移动serv_id 命中 FTTR 清单
left join (
    select distinct serv_id
    from dwm_fttr_list
    where par_month_id between '202401' and '202605'
        and is_fttr = 1
) f
    on t.kd_serv_id = f.serv_id or t.mv_serv_id = f.serv_id
-- 合约：宽带serv_id 或 移动serv_id 命中 合约清单（仅'合约'，排除降档）
left join (
    select distinct serv_id
    from dwm_yz_cm_cdma_hy_final
    where par_month_id between '202401' and '202605'
        and data_type = '合约'
        and is_jd = '否'
) h
    on t.kd_serv_id = h.serv_id or t.mv_serv_id = h.serv_id
;

-- 验收1
-- select count(*) as total, count(distinct kd_serv_id) as distinct_kd, sum(has_fttr) as fttr_cnt, sum(has_contract) as contract_cnt
-- from tmp_rh_cohort_tagged;

-- ----------------------------------------------------
-- 步骤2：月度宽表（cohort × 202401~202605，每个cohort每月一条在网状态）
-- 输出：tmp_rh_cohort_month_status
-- ----------------------------------------------------
drop table if exists tmp_rh_cohort_month_status purge;
create table tmp_rh_cohort_month_status
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    c.kd_serv_id,
    c.open_month,
    c.has_fttr,
    c.has_contract,
    m.month_id as check_month,
    -- 与入网月的月份差（自然月）
    (cast(substr(m.month_id, 1, 4) as int) - cast(substr(c.open_month, 1, 4) as int)) * 12
        + (cast(substr(m.month_id, 5, 2) as int) - cast(substr(c.open_month, 5, 2) as int)) as months_since_open,
    -- 留存标记：宽带当月是否在网（在网=未拆机且出账）
    case
        when k.is_cancel_user = 0 and k.is_cz = 1 then 1
        else 0
    end as kd_active
from tmp_rh_cohort_tagged c
cross join (
    -- 29个月份序列：202401~202605（覆盖所有cohort从入网月到202605的T+N观察窗口）
    select '202401' as month_id union all select '202402' union all select '202403' union all
    select '202404' union all select '202405' union all select '202406' union all
    select '202407' union all select '202408' union all select '202409' union all
    select '202410' union all select '202411' union all select '202412' union all
    select '202501' union all select '202502' union all select '202503' union all
    select '202504' union all select '202505' union all select '202506' union all
    select '202507' union all select '202508' union all select '202509' union all
    select '202510' union all select '202511' union all select '202512' union all
    select '202601' union all select '202602' union all select '202603' union all
    select '202604' union all select '202605'
) m
left join dwm_yz_tb_comm_cm_all_mon_final k
    on c.kd_serv_id = k.serv_id
    and k.par_month_id = m.month_id
    and k.prod_type = 40
    and k.kd_desc = '普通宽带'
where m.month_id >= c.open_month
    and m.month_id <= '202605'
;

-- 验收2
-- select count(*) as total, count(distinct kd_serv_id) as distinct_kd,
--        sum(case when kd_active=1 then 1 else 0 end) as active_cnt
-- from tmp_rh_cohort_month_status;

-- ----------------------------------------------------
-- 步骤3：按 入网月 × 用户类型 汇总 入网量 + T+1~T+24 留存率
-- 输出：ads_rh_kd_new_retention
-- 用户类型：不互斥，拆为两行（FTTR / 合约）
-- ----------------------------------------------------
drop table if exists ads_rh_kd_new_retention purge;
create table ads_rh_kd_new_retention
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    t.open_month,
    t.user_type,
    count(distinct t.kd_serv_id) as entry_cnt,
    round(sum(case when s.months_since_open = 1  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t1,
    round(sum(case when s.months_since_open = 2  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t2,
    round(sum(case when s.months_since_open = 3  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t3,
    round(sum(case when s.months_since_open = 4  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t4,
    round(sum(case when s.months_since_open = 5  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t5,
    round(sum(case when s.months_since_open = 6  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t6,
    round(sum(case when s.months_since_open = 7  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t7,
    round(sum(case when s.months_since_open = 8  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t8,
    round(sum(case when s.months_since_open = 9  and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t9,
    round(sum(case when s.months_since_open = 10 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t10,
    round(sum(case when s.months_since_open = 11 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t11,
    round(sum(case when s.months_since_open = 12 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t12,
    round(sum(case when s.months_since_open = 13 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t13,
    round(sum(case when s.months_since_open = 14 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t14,
    round(sum(case when s.months_since_open = 15 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t15,
    round(sum(case when s.months_since_open = 16 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t16,
    round(sum(case when s.months_since_open = 17 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t17,
    round(sum(case when s.months_since_open = 18 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t18,
    round(sum(case when s.months_since_open = 19 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t19,
    round(sum(case when s.months_since_open = 20 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t20,
    round(sum(case when s.months_since_open = 21 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t21,
    round(sum(case when s.months_since_open = 22 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t22,
    round(sum(case when s.months_since_open = 23 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t23,
    round(sum(case when s.months_since_open = 24 and s.kd_active = 1 then 1 else 0 end) * 1.0 / nullif(count(distinct t.kd_serv_id), 0), 4) as retention_t24
from (
    -- 把"用户分类"打横成两行：FTTR类 / 合约类（不互斥）
    select kd_serv_id, open_month, '新宽新移并办理FTTR' as user_type
    from tmp_rh_cohort_month_status
    where has_fttr = 1
    group by kd_serv_id, open_month
    union all
    select kd_serv_id, open_month, '新宽新移并办理合约' as user_type
    from tmp_rh_cohort_month_status
    where has_contract = 1
    group by kd_serv_id, open_month
) t
left join tmp_rh_cohort_month_status s
    on t.kd_serv_id = s.kd_serv_id
    and t.open_month = s.open_month
group by t.open_month, t.user_type
;

-- ==============================================
-- 过程表血缘
-- ==============================================
/*
| 步骤 | 表名 | 用途 | 上游 | 关键过滤 | 验收 SQL |
|------|------|------|------|----------|----------|
| 1 | tmp_rh_cohort_tagged | cohort + FTTR/合约打标 | 069月表 + FTTR清单 + 合约清单 | is_new_user=1, rh_type_ykj='新宽带新移动', is_fttr=1, data_type='合约' is_jd='否' | select count(*), count(distinct kd_serv_id), sum(has_fttr), sum(has_contract) from tmp_rh_cohort_tagged; |
| 2 | tmp_rh_cohort_month_status | cohort × 月份的在网宽表 | 步骤1 + 069月表 | month_id 202401~202605 | select count(*), count(distinct kd_serv_id), sum(case when kd_active=1 then 1 end) from tmp_rh_cohort_month_status; |
| 3 | ads_rh_kd_new_retention | 入网量 + T+1~T+24留存率 | 步骤2 | user_type FTTR/合约 | select * from ads_rh_kd_new_retention order by open_month, user_type limit 10; |
*/

-- ==============================================
-- 自检 SQL
-- ==============================================
-- 1. 样例：最终结果
-- select * from ads_rh_kd_new_retention order by open_month, user_type limit 20;
-- 2. 量级：FTTR / 合约 总入网量
-- select user_type, sum(entry_cnt) from ads_rh_kd_new_retention group by user_type;
-- 3. T+1 留存合理性（应在 0.5~0.95 区间）
-- select open_month, user_type, retention_t1 from ads_rh_kd_new_retention where retention_t1 is not null order by open_month;
-- 4. 空分区：202605 月表是否有数据
-- select count(*) from dwm_yz_tb_comm_cm_all_mon_final where par_month_id = '202605';

-- ==============================================
-- 风险 / 待确认
-- ==============================================
/*
- 截止月边界：cohort=202401 时 T+24 = 202501（可观测），cohort=202501 时 T+24 = 202701（超出202605不可观测，留存率为 NULL）；cohort=202505 时 T+24 = 202805 不可观测。
  业务上"留存率"通常在 cohort + 24 <= 截止月 时才有意义，请确认 T+24 是否要求强制有值（当前实现：超出截止月时留存为 NULL）。
- 069 月表覆盖：本 SQL 假设 dwm_yz_tb_comm_cm_all_mon_final 已包含 202401~202605 全量月；如月表缺最新月，需补充日表 UNION ALL。
- 留存定义：当前为"宽带在网（未拆机且出账）"，不含移动在网判断；如需"宽带+移动双在网"口径，调整步骤2中 kd_active 判定。
*/
