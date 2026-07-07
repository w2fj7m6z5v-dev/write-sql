需求原始内容：
销售部要求统计202501至202606月，存量移动号码的在网用户数


输出字段：
统计年份,统计月份,存量移动在网用户数


drop table if exists tmp_jm_list;
create table tmp_jm_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select '2025' as year,par_month_id,count(serv_id) as yd_zw_cnt
from ads_yz_tb_comm_cm_all_final
where par_month_id>=202501
and par_month_id<=202512  --限制统计月份
and is_phs_tk='0'  --限制已激活号码
and state<>'140001'  --限制非未竣工号码
and is_cancel_user=0  --限制非拆机号码
and date_format(open_date,'yyyyMM')<'202501'  --限制存量
and prod_type=30  --限制移动
group by par_month_id
union all
select '2026' as year,par_month_id,count(serv_id) as yd_zw_cnt
from ads_yz_tb_comm_cm_all_final
where par_month_id>=202601
and par_month_id<=202606  --限制统计月份
and is_phs_tk='0'  --限制已激活号码
and state<>'140001'  --限制非未竣工号码
and is_cancel_user=0  --限制非拆机号码
and date_format(open_date,'yyyyMM')<'202601'  --限制存量
and prod_type=30  --限制移动
group by par_month_id
order by par_month_id



--输出结果
select year,par_month_id,yd_zw_cnt
from tmp_jm_list;