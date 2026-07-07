需求原始内容： XQGZ2026061701535
客户广州今仙电机有限公司是我司政企大客户，月均消费1.3万。客户目前在用28户，手机号码需要进行续约。
客户公司领导要求提供该批次号码在2025年1月-2026年5月份时间段来每个号码平均使用的流量和通话分钟数据，来判定是否进行续约。因数据量比较大，请后台帮忙按照附件提供的模式提供下数据支撑。


输出字段：
序号,号码,202501-202604每个月平均流量（G）,202501-202604每个月平均通话时长,近1年（202505-202604）的总流量（G）,近1年（202505-202604）的总通话时长（分）


--根据号码匹配serv_id和open_date，并根据open_date算出月份数
drop table if exists tmp_yz_XQGZ2026061701535_list;
create table tmp_yz_XQGZ2026061701535_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select cast(a.index1 as int) as row_num,a.index2 as acc_nbr,b.serv_id,b.open_date,
case when date_format(b.open_date,'yyyyMM')<'202501' then 16
else floor(months_between('2026-05-01',date_format(b.open_date,'yyyy-MM-01')))  end as tj_mon
from zone_gz_yz_343 a
left join
(select par_month_id,serv_id,acc_nbr,open_date
from dwm_yz_tb_comm_cm_all_final
where par_month_id=202606
and prod_type=30
) b
on a.index2=b.acc_nbr;


--通过serv_id关联匹配202501-202604月的平均流量和通话时长和202505-202604月的总流量和总通话时长
drop table if exists tmp_yz_XQGZ2026061701535_list1;
create table tmp_yz_XQGZ2026061701535_list1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select a.*,
cast(b.mou_call_sum as decimal(12,4)) as mou_call_sum,
cast(b.mou_call_sum/a.tj_mon as decimal(12,4)) as mou_call_avg,
cast(b.stm_data_sum as decimal(12,4)) as stm_data_sum,
cast(b.stm_data_sum/a.tj_mon as decimal(12,4)) as stm_data_avg,
cast(c.mou_call_year as decimal(12,4)) as mou_call_year,
cast(c.stm_data_year as decimal(12,4)) as stm_data_year
from tmp_yz_XQGZ2026061701535_list a
left join
(select serv_id,
sum(mou_call) as mou_call_sum,
sum(stm_data)/1024 as stm_data_sum
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id>=202501
and par_month_id<=202604
and prod_type=30
and serv_id in (select serv_id from tmp_yz_XQGZ2026061701535_list)
 group by serv_id
) b
on a.serv_id=b.serv_id
left join
(select serv_id,
sum(mou_call) as mou_call_year,
sum(stm_data)/1024 as stm_data_year
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id>=202505
and par_month_id<=202604
and prod_type=30
and serv_id in (select serv_id from tmp_yz_XQGZ2026061701535_list)
 group by serv_id
) c
on a.serv_id=c.serv_id
order by a.row_num;



--输出结果
select row_num,acc_nbr,mou_call_avg,stm_data_avg,mou_call_year,stm_data_year
from tmp_yz_XQGZ2026061701535_list1
