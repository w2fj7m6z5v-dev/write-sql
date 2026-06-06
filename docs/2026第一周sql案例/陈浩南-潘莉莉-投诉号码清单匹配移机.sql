需求原始内容：
XQGZ2026031601457

由于需对客户移机类投诉中，移机订单成功竣工的情况进行统计，现提供2025年5月-2026年1月客户移机类投诉清单（请详见附件），请根据“客户投诉号码”匹配其“投诉归档日期”前后各30天内是否存在移机订单以及相关字段，包括：移机成功的订单编码、移机订单竣工时间、移机前后对应的局向/营服/网格单元（附件E列-M列），谢谢！
备注：1、如存在大于1条的移机订单信息，请按最接近“投诉归档日期”的移机成功的订单信息进行统计；2、如投诉号码为移动号码，请查找同一客户名下/客户编码下是否有移机工单。

需求梳理：
根据附件的2025年5月-2026年1月的移机投诉清单（包含投诉工单编号，接入号，投诉归档日期，投诉月份），匹配清单接入号在投诉归档日期前后30天内是否有移机订单。
要求：
1.投诉清单的接入号包含宽带号码和移动号码（移动号码等），移动号码本身不移机，取移动号码对应的融合套内宽带号码是否有移机订单
2.同个号码可能匹配到多个移机订单，记录全部保留

输出字段：
投诉工单编号，接入号，投诉归档日期，投诉月份，移机订单编码，移机订单竣工时间，移机前所属落地分局，移机前所属落地营服，移机前所属网格单元，移机后所属落地分局，移机后所属落地营服，移机后所属网格单元


--导入需求附件数据 
drop table if exists zone_gz_yz.tmp_yz_XQGZ2026031601457_0 purge;
create table zone_gz_yz.tmp_yz_XQGZ2026031601457_0
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as select index1 as ts_nbr,index2 as acc_nbr,index3 as gd_date,index4 as ts_month 
from zone_gz_yz_3461990702940160 
;

--取接入号在对应月份的融合套餐标识及产品类型
drop table if exists zone_gz_yz.tmp_yz_XQGZ2026031601457_1 purge;
create table zone_gz_yz.tmp_yz_XQGZ2026031601457_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as select a.*,b.rh_tc_id,b.prod_type
from tmp_yz_XQGZ2026031601457_0 a left join (select rh_tc_id,acc_nbr,par_month_id,prod_type from dwm_yz_tb_comm_cm_all_mon_final where par_month_id between 202505 and 202601 ) b 
on a.acc_nbr=b.acc_nbr and a.ts_month=b.par_month_id 

;

--取号码对应的融合套内宽带号码
drop table if exists zone_gz_yz.tmp_yz_XQGZ2026031601457_2 purge;
create table zone_gz_yz.tmp_yz_XQGZ2026031601457_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as select a.*,b.acc_nbr as rhkd_acc_nbr
from tmp_yz_XQGZ2026031601457_1 a left join (select rh_tc_id,acc_nbr,par_month_id from dwm_yz_tb_comm_cm_all_mon_final where par_month_id between 202505 and 202601 and prod_type=40 and is_rh_ykj=1 and COALESCE(prod_type2,0) <>50 ) b 
on a.rh_tc_id=b.rh_tc_id and a.ts_month=b.par_month_id 
;

--移机表抽取月份范围内的移机订单
drop table if exists zone_gz_yz.tmp_yz_XQGZ2026031601457_3 purge;
create table zone_gz_yz.tmp_yz_XQGZ2026031601457_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as select  par_month_id,serv_id,acc_nbr,subs_code,subs_stat_date,date_format(subs_stat_date,'yyyyMMdd') as yj_date,std_subst_name_last,std_branch_name_last,cell_name_last,std_subst_name,std_branch_name,cell_name
from dwd_yz_rpt_comm_ba_subs_move_final  
where par_month_id between 202504 and 202602 
;

--打标字段，移动号码按套内宽带取，其余用号码本身，最终用gl_acc作为和移机订单关联的号码
drop table if exists zone_gz_yz.tmp_yz_XQGZ2026031601457_4 purge;
create table zone_gz_yz.tmp_yz_XQGZ2026031601457_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as select *,case when prod_type=30 then rhkd_acc_nbr else acc_nbr end as gl_acc
from tmp_yz_XQGZ2026031601457_2
;

--用gl_acc 关联前后30天的移机订单,取回要打标的落地分局等信息
drop table if exists zone_gz_yz.tmp_yz_XQGZ2026031601457_5 purge;
create table zone_gz_yz.tmp_yz_XQGZ2026031601457_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as select a.*,subs_code,subs_stat_date, yj_date,std_subst_name_last,std_branch_name_last,cell_name_last,std_subst_name,std_branch_name,cell_name
from tmp_yz_XQGZ2026031601457_4 a left join  tmp_yz_XQGZ2026031601457_3 b on 
a.gl_acc =b.acc_nbr and  gd_date >=date_sub(subs_stat_date,30) 
and gd_date <=date_add(subs_stat_date,30)
;

--没有重复膨胀
select count(*) from tmp_yz_XQGZ2026031601457_0;--15033
select count(*) from tmp_yz_XQGZ2026031601457_1;--15034
select count(*) from tmp_yz_XQGZ2026031601457_2;--15034
select count(*) from tmp_yz_XQGZ2026031601457_4;--15034
select count(*) from tmp_yz_XQGZ2026031601457_5--15167 多个订单记录带来的膨胀，需保留



--核验，根据接入号、关联的接入号、投诉工单排序，看是否有重复
drop table if exists tmp_chn_1120_1;
create table tmp_chn_1120_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select *,row_number () over (partition by gl_acc,acc_nbr,ts_nbr,subs_code  order by ts_month ) as rank
from tmp_yz_XQGZ2026031601457_5;
set hive.fetch.task.conversion = none;
select * from tmp_chn_1120_1 where gl_acc in (select   gl_acc from tmp_chn_1120_1 where  rank>1) --0条记录

 

 
--上面核验正常，所以直接输出，保留同个号码匹配多个移机订单的记录
drop table if exists zone_gz_yz.ads_yz_XQGZ2026031601457 purge;
create table zone_gz_yz.ads_yz_XQGZ2026031601457 row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select ts_nbr,(case when length(acc_nbr)<2 then '*' when length(acc_nbr)=2 then concat(SUBSTR(acc_nbr,1,1),'*') when length(acc_nbr)<8 then concat(SUBSTR(acc_nbr,1,(length(acc_nbr)-2)),'**') when length(acc_nbr)>=8 then concat(SUBSTR(acc_nbr,1,length(acc_nbr)-8),'****',SUBSTR(acc_nbr,length(acc_nbr)-3,length(acc_nbr))) else '*' end) as acc_nbr
,gd_date,ts_month,rh_tc_id,prod_type, (case when length(rhkd_acc_nbr)<2 then '*' when length(rhkd_acc_nbr)=2 then concat(SUBSTR(rhkd_acc_nbr,1,1),'*') when length(rhkd_acc_nbr)<8 then concat(SUBSTR(rhkd_acc_nbr,1,(length(rhkd_acc_nbr)-2)),'**') when length(rhkd_acc_nbr)>=8 then concat(SUBSTR(rhkd_acc_nbr,1,length(rhkd_acc_nbr)-8),'****',SUBSTR(rhkd_acc_nbr,length(rhkd_acc_nbr)-3,length(rhkd_acc_nbr))) else '*' end) as rhkd_acc_nbr
,subs_code,subs_stat_Date,yj_date,std_branch_name_last,cell_name_last,std_subst_name,std_branch_name,cell_name 
from tmp_yz_XQGZ2026031601457_5
;