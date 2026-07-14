【工单详情】
工单编号	XQGZ2025020601655	
需求标题	调取清单制客户固话数据
提交人	苏瑜	提交人电话	18988927223,	提交部门	广东公司/市分公司/广州分公司/越秀分公司/政企客户部
提交日期	2025-02-06 17:11:34
需求描述	为组织固话营销及保存工作，请相关同事协助调取附件表格内固话通话数据。
1：号码级SHEET，请协助识别其中G列，是有有协议标识（XYCQS142、XYCQS047、XYCQS057、XYCQS181、XYCQS097、TY805、TY808、TY409、TY800、TY807、TY804、TY073）。
2：号码级SHEET其中I-N列，导出24年10月-12月固话通话分钟数（呼出及呼出）。

【取数口径】
锁定需求方提供的号码清单，匹配是否办理指定销售品，提取24年10月-12月固话通话分钟数（呼出及呼出）

【输出字段】
'序号','产权客户编码(需求方提供)','产权名称(需求方提供)','直销客编(需求方提供)','直销名称(需求方提供)','中心(需求方提供)','接入号(需求方提供)','服务标识','是否办理指定协议标识','202410月固话通话时长(分钟)','202411月固话通话时长(分钟)','202412月固话通话时长(分钟)'


--###导入清单
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655 as
select 
current_date() as run_date,
index1 as cust_nbr,
index2,
index3,
index4,
index5,
index6 as acc_nbr
from zone_gz_yz.zone_gz_yz_342
;

--###更新 最新时点 serv_id
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_1 as
select
a.*,
b.serv_id
from zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655 a
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_final b on a.acc_nbr=b.acc_nbr and a.cust_nbr=b.cust_nbr and b.par_month_id=date_format(current_date(),'yyyyMM') and b.is_cancel_user=0
;

--###生成 最新时点 是否办理指定销售品且未过期 打标清单
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_lbl_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_lbl_1 as
select distinct
a.serv_id,
1 as is_disc
from zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_1 a
join summary_ods_day_city.rpt_comm_cm_msdisc b on a.serv_id=b.serv_id
join dws_crm_cfguse.dws_offer c on b.prod_offer_id=c.offer_id and c.city_id=200
where to_date(b.limit_date)>=current_date()  --当前日期未过期
and c.prod_offer_code in ('XYCQS142',
'XYCQS047',
'XYCQS057',
'XYCQS181',
'XYCQS097',
'TY805',
'TY808',
'TY409',
'TY800',
'TY807',
'TY804',
'TY073')
;

--###更新 最新时点 是否办理指定销售品且未过期
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_2;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_2 as
select
a.*,
case when a.serv_id is null then null
     when b.is_disc=1 then '是' 
     else '否' end as is_disc
from zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_1 a
left join zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_lbl_1 b on a.serv_id=b.serv_id
where 1=1
; 

--###更新 202410~202412月 固话通话时长
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_3;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_3 as
select 
a.*,
b.gw_sc as gw_sc_202410,
c.gw_sc as gw_sc_202411,
d.gw_sc as gw_sc_202412
from zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_2 a
left join (select serv_id,cast(DUR/60 as decimal(22,2)) gw_sc  --固网通话时长 单位分
           from summary_ods_month_city.TB_COMM_YWL_GW_mon
           where par_corp_id=200 
           and par_month_id=202410) b on a.serv_id=b.serv_id 
left join (select serv_id,cast(DUR/60 as decimal(22,2)) gw_sc  --固网通话时长 单位分
           from summary_ods_month_city.TB_COMM_YWL_GW_mon
           where par_corp_id=200 
           and par_month_id=202411) c on a.serv_id=c.serv_id 
left join (select serv_id,cast(DUR/60 as decimal(22,2)) gw_sc  --固网通话时长 单位分
           from summary_ods_month_city.TB_COMM_YWL_GW_mon
           where par_corp_id=200 
           and par_month_id=202412) d on a.serv_id=d.serv_id
;

--#####【生成结果清单】
drop table if exists zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025020601655;
create table zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025020601655 as
select 
row_number() over (order by serv_id) as order_id,  --序号
a.*
from zone_gz_yz.tmp_yz_cqh_XQGZ2025020601655_3 a
;

--#####【创建视图】
drop view if exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2025020601655;
create view if not exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2025020601655 
(
order_id            comment '序号'
,cust_nbr           comment '产权客户编码(需求方提供)'
,index2             comment '产权名称(需求方提供)'
,index3             comment '直销客编(需求方提供)'
,index4             comment '直销名称(需求方提供)'
,index5             comment '中心(需求方提供)'    
,acc_nbr            comment '接入号(需求方提供)'
,serv_id            comment '服务标识'
,is_disc            comment '是否办理指定协议标识'
,gw_sc_202410       comment '202410月固话通话时长(分钟)'            
,gw_sc_202411       comment '202411月固话通话时长(分钟)'      
,gw_sc_202412       comment '202412月固话通话时长(分钟)' 
)
as
select
order_id
,cust_nbr
,index2
,index3
,index4
,index5
,acc_nbr
,serv_id
,is_disc
,gw_sc_202410
,gw_sc_202411
,gw_sc_202412
from zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025020601655
;
