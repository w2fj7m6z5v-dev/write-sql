需求原始内容：
统计不同客群2026年存量单移离网量及月均离网率

需求梳理：
用去年12月拍照到达-当月到达，得出离网量，再用离网量/月份数/去年12月拍照到达得到月均离网率
客群统计口径：
行客：客群为政企（不含商客）且细分市场不等于校园
商客：客群为商客分群
校园：细分市场为校园
公众：客群为公众（不含商客）

输出字段：
统计月份,客群,去年12月拍照到达,当月到达,离网量,月均离网率


drop table if exists tmp_yz_dy_lw;
create table tmp_yz_dy_lw
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select 202605 as month_id,'广州' as kq_name,
count(case when par_month_id=202512 then serv_id end) as dd_202512,
count(case when par_month_id=202605 then serv_id end) as dd_202605,
count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end) as lw_202605,
(count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end))/cast(202605%100 as int)/count(case when par_month_id=202512 then serv_id end) as lw_rate_202605
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id in (202605,202512)
and prod_type=30
and is_cz=1
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))--单移
and date_format(open_date,'yyyyMM')<'202601' --存量
union all
select 202605 as month_id,'行客客群' as kq_name,
count(case when par_month_id=202512 then serv_id end) as dd_202512,
count(case when par_month_id=202605 then serv_id end) as dd_202605,
count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end) as lw_202605,
(count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end))/cast(202605%100 as int)/count(case when par_month_id=202512 then serv_id end) as lw_rate_202605
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id in (202605,202512)
and prod_type=30
and is_cz=1
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))--单移
and date_format(open_date,'yyyyMM')<'202601' --存量
and null_column11='政企（不含商客）'  --行客客群
and (six_market<>1 or six_market is null) --剔除校园市场
union all
select 202605 as month_id,'商客客群' as kq_name,
count(case when par_month_id=202512 then serv_id end) as dd_202512,
count(case when par_month_id=202605 then serv_id end) as dd_202605,
count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end) as lw_202605,
(count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end))/cast(202605%100 as int)/count(case when par_month_id=202512 then serv_id end) as lw_rate_202605
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id in (202605,202512)
and prod_type=30
and is_cz=1
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))--单移
and date_format(open_date,'yyyyMM')<'202601' --存量
and null_column11='商客分群' --商客客群
union all
select 202605 as month_id,'校园市场' as kq_name,
count(case when par_month_id=202512 then serv_id end) as dd_202512,
count(case when par_month_id=202605 then serv_id end) as dd_202605,
count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end) as lw_202605,
(count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end))/cast(202605%100 as int)/count(case when par_month_id=202512 then serv_id end) as lw_rate_202605
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id in (202605,202512)
and prod_type=30
and is_cz=1
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))--单移
and date_format(open_date,'yyyyMM')<'202601' --存量
and six_market=1 --校园市场
union all
select 202605 as month_id,'公众客群' as kq_name,
count(case when par_month_id=202512 then serv_id end) as dd_202512,
count(case when par_month_id=202605 then serv_id end) as dd_202605,
count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end) as lw_202605,
(count(case when par_month_id=202512 then serv_id end)-count(case when par_month_id=202605 then serv_id end))/cast(202605%100 as int)/count(case when par_month_id=202512 then serv_id end) as lw_rate_202605
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id in (202605,202512)
and prod_type=30
and is_cz=1
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))--单移
and date_format(open_date,'yyyyMM')<'202601' --存量
and null_column11='公众（不含商客）' --公众客群
;


--输出结果
select month_id,kq_name,dd_202512,dd_202605,lw_202605,lw_rate_202605
from tmp_yz_dy_lw