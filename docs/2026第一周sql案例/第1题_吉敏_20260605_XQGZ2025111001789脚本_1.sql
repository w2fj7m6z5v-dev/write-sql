需求原始内容：
XQGZ2025111001789

客户要求对附件的清单匹配折扣\统付金额\针对H列折扣优惠到期日这3个数据进行匹配,详见附件,请协助处理,谢谢!

需求梳理：
根据附件号码匹配指定销售品的到期时间以及折扣/赠金参数信息

输出字段：
接入号,销售品编码,销售品名称,到期时间,是否办理‘YD0203-082’,是否办理‘YD0203-0822’,‘YD0203-082’赠金,‘YD0203-082’折扣,‘YD0203-0822’赠金,‘YD0203-0822’折扣


--导入号码并更新号码对应serv_id
drop table if exists tmp_XQGZ2025111301115_list;
create table tmp_XQGZ2025111301115_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select cast(a.index1 as int) as row_num,a.index2 as acc_nbr,b.serv_id
from zone_gz_yz_343 a
left join
(select serv_id,acc_nbr
from dwm_yz_tb_comm_cm_all_final
where par_month_id=202511
and prod_type=30
) b
on a.index2=b.acc_nbr
order by cast(a.index1 as int);


--取号码对应的套餐信息
drop table if exists tmp_XQGZ2025111301115_msdisc;
create table tmp_XQGZ2025111301115_msdisc
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select serv_id,prod_offer_id,prod_offer_code,prod_offer_name,limit_date
from ads_yz_rpt_comm_cm_msdisc_final
where par_month_id=202511
and serv_id in (select serv_id from tmp_XQGZ2025111301115_list)
and date_format(limit_date,'yyyyMMdd')>='20251130';

drop table if exists tmp_XQGZ2025111301115_list1;
create table tmp_XQGZ2025111301115_list1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select a.*
,b.prod_offer_code
,b.prod_offer_name
,b.limit_date
,case when c.serv_id is not null then '是' else '否' end as is_YD0203_082
,case when d.serv_id is not null then '是' else '否' end as is_YD0203_0822
from tmp_XQGZ2025111301115_list a
left join
(select serv_id,prod_offer_id,prod_offer_code,prod_offer_name,limit_date
,row_number() over(partition by serv_id order by limit_date desc) as order_id
from zone_gz_yz.tmp_XQGZ2025111301115_msdisc
where prod_offer_code in 
('YD0203-476-1-4','YD0203-476-1-3','YD0203-476-1-2','YD0203-476-1-1',
'YD4G03-482-1-4','YD4G03-482-1-1','YD4G03-482-1-2','YD4G03-482-1-3')
) b
on a.serv_id=b.serv_id and b.order_id=1
left join
(select distinct serv_id
from zone_gz_yz.tmp_XQGZ2025111301115_msdisc
where prod_offer_code in ('YD0203-082')
) c
on a.serv_id=c.serv_id
left join
(select distinct serv_id
from zone_gz_yz.tmp_XQGZ2025111301115_msdisc
where prod_offer_code in ('YD0203-0822')
) d
on a.serv_id=d.serv_id;


--取号码对应的套餐参数信息
drop table if exists tmp_XQGZ2025111301115_param;
create table tmp_XQGZ2025111301115_param
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select serv_id,prod_offer_id,param_code,param_value
from summary_ods_day_city.rpt_comm_cm_msparam 
where par_corp_id='200'
and serv_id in (select serv_id from tmp_XQGZ2025111301115_list)
and date_format(limit_date,'yyyyMMdd')>='20251130';

drop table if exists tmp_XQGZ2025111301115_list2;
create table tmp_XQGZ2025111301115_list2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select a.*
,b.param_value as zj_082
,c.param_value as dx_082
,d.param_value as zj_0822
,e.param_value as dx_0822
from tmp_XQGZ2025111301115_list1 a
left join
(select serv_id,prod_offer_id,param_code,param_value
from tmp_XQGZ2025111301115_param
where prod_offer_id=5730098
and param_code='991100000725'
) b
on a.serv_id=b.serv_id
left join
(select serv_id,prod_offer_id,param_code,param_value
from tmp_XQGZ2025111301115_param
where prod_offer_id=5730098
and param_code='991100000028'
) c
on a.serv_id=c.serv_id
left join
(select serv_id,prod_offer_id,param_code,param_value
from tmp_XQGZ2025111301115_param
where prod_offer_id=500072800
and param_code='JFYS00003'
) d
on a.serv_id=d.serv_id
left join
(select serv_id,prod_offer_id,param_code,param_value
from tmp_XQGZ2025111301115_param
where prod_offer_id=500072800
and param_code='JFYS00036'
) e
on a.serv_id=e.serv_id
order by a.row_num;


--核验，看是否有重复
select count(*),count(disitnct acc_nbr)
from tmp_XQGZ2025111301115_list2


--上面核验正常，直接输出
select acc_nbr,prod_offer_code,prod_offer_name,limit_date,is_YD0203_082,is_YD0203_0822,zj_082,dx_082,zj_0822,dx_0822
from tmp_XQGZ2025111301115_list2