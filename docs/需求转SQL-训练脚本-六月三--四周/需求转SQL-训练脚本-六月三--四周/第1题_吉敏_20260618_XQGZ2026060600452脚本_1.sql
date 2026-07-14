需求原始内容：XQGZ2026060600452
基于省市公司信安反诈形势严峻，天河分公司申请对2025及2026年入网的政企移动团单号码进行自查，重点关注新媒体账号注册运营类客户，需要判断号码是否关闭语音功能、是否后续恢复了已关闭的语音功能。进一步进行风险核查，请协助。有疑问请联系天河政企部王硕千。
需要的字段有：号码目前状态（在用、停机、拆机等）、号码语音功能状态（开启/关闭）（202606到达情况）、关闭语音功能的受理日期、是否有受理过恢复语音功能、开通语音功能受理日期，详见清单。


输出字段：
序号,统计时间,入网日期,揽装中心,揽装人,渠道大类,渠道小类,接入号,产品类型,价值积分,套餐内容,客编,客户名,是否公司名,服务标识,序号,
号码当前状态,当前是否办理“全限制（不给通话）”附属产品,办理“全限制（不给通话）”附属产品的时间,是否有取消办理“全限制（不给通话）”附属产品,取消“全限制（不给通话）”附属产品的时间



--导入号码信息并匹配号码当前状态
drop table zone_gz_yz.tmp_yz_XQGZ2026060600452_list;
create table zone_gz_yz.tmp_yz_XQGZ2026060600452_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select index1 as open_date,index2 as sales_branch_name,index3 as sales_man,index4 as channel_type_2011,index5 as channel_subtype_2011,index6 as acc_nbr,
index7 as yd_pord_type,index8 as jz_points,index9 as cdma_disc_desc,index10 as cust_nbr,index11 as cust_name,index12 as is_gsm,index13 as serv_id,
case when b.serv_id is null then '已拆机' 
     else c.attr_value_name end as state_desc
from zone_gz_yz.zone_gz_yz_343 a
left join
(select serv_id,state,open_date
from dwm_yz_tb_comm_cm_all_final
where par_month_id=202606
and is_cancel_user=0
) as b
on a.index13=b.serv_id
left join 
(select attr_value,attr_value_name
from dws_crm_cfguse.dws_attr_value
where city_id='200' 
and attr_id='4000000201'
) as c 
on b.state=c.attr_value;


--匹配号码当前是否有“全限制（不给通话）”附属产品（附属产品ID=600031007）
drop table zone_gz_yz.tmp_yz_XQGZ2026060600452_list1;
create table zone_gz_yz.tmp_yz_XQGZ2026060600452_list1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select a.*,case when b.serv_id is not null then '是' else '否' end as is_xzth
from zone_gz_yz.tmp_yz_XQGZ2026060600452_list a
left join
(select distinct serv_id
from summary_ods_day_city.rpt_comm_cm_subserv
where sub_prod_id=600031007
and prod_id in (3204,3205)
) b
on a.serv_id=b.serv_id;


--生成2025年以来所有办理及取消“全限制（不给通话）”附属产品的订单信息（附属产品ID=600031007）
drop table zone_gz_yz.tmp_yz_XQGZ2026060600452_ba_subs_prod;
create table zone_gz_yz.tmp_yz_XQGZ2026060600452_ba_subs_prod
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select 'ba_sub_prod_hist' as type,serv_id,acc_nbr,oper_type,subs_code,subs_stat_date
from summary_ods_day_city.rpt_comm_ba_sub_prod_hist
where sub_prod_id = 600031007
and prod_id in (3204,3205)
and subs_stat = '301200'
and subs_stat_reason not in( '1200','1300' ) 
and oper_type in ( '1000','1100' ) 
and date_format(subs_stat_date,'yyyyMMdd') >='20250101'
union all
select 'ba_sub_prod' as type,serv_id,acc_nbr,oper_type,subs_code,subs_stat_date
from summary_ods_day_city.rpt_comm_ba_sub_prod
where sub_prod_id = 600031007
and prod_id in (3204,3205)
and subs_stat = '301200'
and subs_stat_reason not in( '1200','1300' ) 
and oper_type in( '1000','1100' ) 
and date_format(subs_stat_date,'yyyyMMdd') >='20250101'
union all
select 'ba_sub_prod_hist_mon' as type,serv_id,acc_nbr,oper_type,subs_code,subs_stat_date
from iodata_ods_month_city.rpt_comm_ba_sub_prod_hist_mon
where sub_prod_id = 600031007
and prod_id in (3204,3205)
and subs_stat = '301200'
and subs_stat_reason not in( '1200','1300' ) 
and oper_type in ( '1000','1100' ) 
and date_format(subs_stat_date,'yyyyMMdd') >='20250101'
and par_month_id>=202501
and par_month_id<=202605
union all
select 'ba_sub_prod_mon' as type,serv_id,acc_nbr,oper_type,subs_code,subs_stat_date
from iodata_ods_month_city.rpt_comm_ba_sub_prod_mon
where sub_prod_id = 600031007
and prod_id in (3204,3205)
and subs_stat = '301200'
and subs_stat_reason not in( '1200','1300' ) 
and oper_type in ( '1000','1100' ) 
and date_format(subs_stat_date,'yyyyMMdd') >='20250101'
and par_month_id>=202501
and par_month_id<=202605;



--匹配号码是否有办理和取消“全限制（不给通话）”附属产品，以及办理和取消的时间
drop table zone_gz_yz.tmp_yz_XQGZ2026060600452_list2;
create table zone_gz_yz.tmp_yz_XQGZ2026060600452_list2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select a.*,
case when b.serv_id is not null then '是' else '否' end as is_bl_xzth,b.subs_stat_date as bl_date,
case when c.serv_id is not null then '是' else '否' end as is_qxbl_xzth,c.subs_stat_date as qxbl_date
from zone_gz_yz.tmp_yz_XQGZ2026060600452_list1 a
left join
(select serv_id,subs_stat_date,
row_number() over(partition by serv_id order by subs_stat_date desc) as order_id
from tmp_yz_XQGZ2026060600452_ba_subs_prod
where oper_type in ( '1000' ) 
) b
on a.serv_id=b.serv_id and b.order_id=1
left join
(select serv_id,subs_stat_date,
row_number() over(partition by serv_id order by subs_stat_date desc) as order_id
from tmp_yz_XQGZ2026060600452_ba_subs_prod
where oper_type in ( '1100' ) 
) c
on a.serv_id=c.serv_id and c.order_id=1
order by a.row_num;
    
    
--输出结果
select 
open_date,
sales_branch_name,
sales_man,
channel_type_2011,
channel_subtype_2011,
acc_nbr,
yd_pord_type,
jz_points,
cdma_disc_desc,
cust_nbr,
cust_name,
is_gsm,
serv_id,
state_desc,
is_xzth,
bl_date,
is_qxbl_xzth,
qxbl_date
from zone_gz_yz.tmp_yz_XQGZ2026060600452_list2;