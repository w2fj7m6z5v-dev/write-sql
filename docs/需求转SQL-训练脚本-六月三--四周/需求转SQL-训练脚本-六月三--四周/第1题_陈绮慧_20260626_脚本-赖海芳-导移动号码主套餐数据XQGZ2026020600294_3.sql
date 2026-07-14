【工单详情】
工单编号	XQGZ2026020600294	
需求标题	导移动号码主套餐数据
提交人	赖海芳	提交人电话	18922720892,	提交部门	广东公司/市分公司/广州分公司/增城分公司/临-外部组织/临-增城交通物流BU营销服务中心
提交日期	2026-02-06 09:55:09
需求描述	广州奥昆食品有限公司，37户移动号码；续约号码
广东立高食品营销有限公司，206户移动号码；续约号码
需求导出号码主套餐，

【取数口径】
针对需求方提供的移动号码清单提取号码对应的移动主套餐

【输出字段】
'序号','客户名称(需求方提供)' ,'客户编码(需求方提供)','接入号(需求方提供)','服务标识','移动主套餐名称'  



--###导入清单
set hive.fetch.task.conversion=none;
set hive.auto.convert.join=false;
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020600294_0;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020600294_0 as
select 
current_date() as run_date,
index1 as order_id,
index2 as cust_name,
index3 as cust_nbr,
index4 as acc_nbr
from zone_gz_yz.zone_gz_yz_342
;

--###生成结果清单
set hive.fetch.task.conversion=none;
set hive.auto.convert.join=false;
drop table if exists zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026020600294;
create table zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026020600294 as
select
a.*
,b.serv_id
,b.cust_nbr as cust_nbr_dwm
,b.state
,b.open_date
,b.cdma_disc_type
,b.cdma_disc_desc     --移动主套餐名称
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020600294_0 a
left join (select x.serv_id,x.acc_nbr,x.cust_nbr,x.state,x.open_date,x.cdma_disc_type,y.cdma_disc_desc
           from zone_gz_yz.dwm_yz_tb_comm_cm_all_final x
           left join metadata_ods_day.md_ft_cdma_disc_config y on x.cdma_disc_type=y.cdma_disc_id   --更新移动主套餐名称
           where x.par_month_id=date_format(current_date(),'yyyyMM')  --当前月份
           and x.is_cancel_user=0
           ) b on a.acc_nbr=b.acc_nbr
;

--#####【创建视图】
drop view if exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2026020600294;
create view if not exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2026020600294 
(
order_id                    comment '序号'
,cust_name                  comment '客户名称(需求方提供)'   
,cust_nbr                   comment '客户编码(需求方提供)'
,acc_nbr                    comment '接入号(需求方提供)'
,serv_id                    comment '服务标识'
,cdma_disc_desc             comment '移动主套餐名称'   
)
as
select
order_id
,cust_name
,cust_nbr
,acc_nbr
,serv_id
,cdma_disc_desc
from zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026020600294
;

