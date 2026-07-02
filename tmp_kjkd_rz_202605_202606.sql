-- ============================================================
-- 快捷宽带入网量 & 套餐价值积分（2026年5月-6月）
-- 维度：月份 + 划小分局 + 划小营服 + 7级地址
-- 主表：069 全业务资料表（日表 dwm_yz_tb_comm_cm_all_final）
-- 补表：079 地址维表（zone_gz_yz.dwd_yz_addr_final）
-- 口径：M-BASIC-BB-008 快捷宽带入网数（prod_type3='快捷宽带'、is_new_user=1、open_date）
-- 积分：套餐价值积分 jz_points（分摊后）
-- 时间：按竣工 open_date 过滤 202605-202606
-- ============================================================

drop table if exists tmp_kjkd_rz_202605_202606 purge;
create table tmp_kjkd_rz_202605_202606
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    a.par_month_id,
    a.subst_name,
    a.branch_name,
    cast(addr_dim.addr_id_7 as string) as addr_7_id,
    addr7.addr as addr_7_name,
    count(a.serv_id) as cnt,
    sum(a.jz_points) as total_jz_points
from dwm_yz_tb_comm_cm_all_final a
left join zone_gz_yz.dwd_yz_addr_final addr_dim
    on a.serv_addr_id = cast(addr_dim.id as string)
left join zone_gz_yz.dwd_yz_addr_final addr7
    on cast(addr_dim.addr_id_7 as string) = cast(addr7.id as string)
   and addr7.grade = 7
where a.par_month_id in (202605, 202606)
  and date_format(a.open_date, 'yyyyMM') in ('202605', '202606')
  and a.prod_type3 = '快捷宽带'
  and a.is_new_user = 1
group by
    a.par_month_id,
    a.subst_name,
    a.branch_name,
    cast(addr_dim.addr_id_7 as string),
    addr7.addr
;