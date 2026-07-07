【工单详情】
工单编号	XQGZ2026011300428	
需求标题	关于提取本田技研科技（中国）有限公司移动号码 优惠信息的需求
提交人	胡冠华	提交人电话	18922169169,	提交部门	广东公司/市分公司/广州分公司/政企客户部/汽车行业团队
提交日期	2026-01-13 10:16:31
需求描述	本田技研科技（中国）有限公司现存量移动号码有633个，目前移动号码各个移动优惠套餐标识到期时间以及赠金受理时间不同及信息缺失，导致移动未续约虚出账引起客户反感及投诉，现烦请业支提取存量号码对应移动打折单的到期时间以及赠金优惠信息，详见附件，请审批协助处理，谢谢

【取数口径】
1、整体取数口径：根据需求方提供的移动号码，提取这批号码已办理在移动续约销售品维表范围内的销售品，不需要限定到期时间。
2、需求字段为：设备号码(需求方提供)，移动主套餐名称，到期套餐id，到期套餐编码，到期套餐名称，套餐到期时间，到期套餐优惠大类，到期套餐优惠小类，政企移动团购优惠包优惠赠金金额YD0203-0822
3、其中“政企移动团购优惠包优惠赠金金额YD0203-0822” 这个字段的口径是：到期销售品为YD0203-0822的优惠参数名称为'减免套餐费（元）'的优惠参数值。

【回单意见】
'序号','统计日期','服务标识','接入号(需求方提供)','号码使用状态','移动主套餐名称','已办理销售品id','已办理销售品编码','已办理销售品名称','已办理销售品到期时间','已办理销售品优惠大类','已办理销售品优惠小类','YD0203-0822的赠金金额'


--##导入 需求附件中的号码清单		
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_0;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_0 as
select 
current_date() as run_date,
index1 as acc_nbr
from zone_gz_yz.zone_gz_yz_342
;

--##更新 最新时点 目标号码基础信息(从业务资料表)		
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_1 as
select 
20260114 as data_date,
a.*,
b.par_month_id as month_id,
b.serv_id,
b.cust_id,
b.cust_nbr,
b.cust_name,
b.ccust_id,
b.cust_code,
to_date(b.open_date) as open_date_acc,
b.state,
c.attr_value_name as state_desc,     --使用状态
b.cdma_disc_type,
d.cdma_disc_desc     --移动主套餐名称
from zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_0 a
left join (select *
           from zone_gz_yz.dwm_yz_tb_comm_cm_all_final
           where par_month_id=202601
           and is_cancel_user=0) b on a.acc_nbr=b.acc_nbr
left join dws_crm_cfguse.dws_attr_value c on b.state=c.attr_value and c.city_id='200' and c.attr_id = '4000000201'  --更新使用状态 
left join metadata_ods_day.md_ft_cdma_disc_config d on b.cdma_disc_type=d.cdma_disc_id   --更新移动主套餐名称
where 1=1
;

--##插入 最新时点 目标号码办理所有销售品实例清单(从优惠资料表)		
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_2;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_2 as
select 
a.*
,b.prod_offer_id
,b.prod_offer_code
,b.offer_name as prod_offer_name
,b.msobjgrp_id
,to_date(b.open_date) as open_date
,to_date(b.limit_date) as limit_date
,date_format(b.limit_date,'yyyyMM') as limit_month
,b.disc_type_dl
,b.disc_type_xl
from zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_1 a
left join (select t1.*,t2.disc_type_dl,t2.disc_type_xl
           from (select x.serv_id,x.acc_nbr,x.msobjgrp_id,x.open_date,x.limit_date,x.prod_offer_id,y.prod_offer_code,y.offer_name
                 from summary_ods_day_city.rpt_comm_cm_msdisc x
                 join dws_crm_cfguse.dws_offer y on x.prod_offer_id=y.offer_id and y.city_id=200
                 --where date_format(x.limit_date,'yyyyMMdd') > 20260114
                 ) t1
           join zone_gz_yz.ads_dim_yz_yd_ydxy_disc_new t2 on t1.prod_offer_id=t2.prod_offer_id and t2.is_target_disc=1
           ) b on a.serv_id=b.serv_id
where 1=1
;

--##生成 最新时点 YD0203-0822的优惠参数名称为'减免套餐费（元）'的优惠参数值 打标清单	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_lbl_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_lbl_1 as
select distinct
a.serv_id,
a.msobjgrp_id,
b.param_value
from zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_2 a
join summary_ods_day_city.rpt_comm_cm_msparam b on a.serv_id=b.serv_id and a.msobjgrp_id=b.msobjgrp_id
join dws_crm_cfguse.dws_attr_spec_offer c on b.param_code=c.attr_inner_cd and c.attr_name = '减免套餐费（元）'
where a.prod_offer_code='YD0203-0822'
;

--##更新 YD0203-0822的优惠参数名称为'减免套餐费（元）'的优惠参数值	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_3;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_3 as
select
a.*,
b.param_value
from zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_2 a
left join zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_lbl_1 b on a.serv_id=b.serv_id and a.msobjgrp_id=b.msobjgrp_id
where 1=1
;

--##生成结果清单		
drop table if exists zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026011300428;
create table zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026011300428 as
select 
row_number() over (order by serv_id) as order_id  --序号
,'200' as city_id
,a.*
from zone_gz_yz.tmp_yz_cqh_XQGZ2026011300428_3 a
where 1=1
;

--##创建视图		
drop view if exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2026011300428;
create view if not exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2026011300428 
(
order_id          comment '序号'
,data_date        comment '统计日期'
,serv_id          comment '服务标识'
,acc_nbr          comment '接入号(需求方提供)'
,state_desc       comment '号码使用状态'
,cdma_disc_desc   comment '移动主套餐名称'
,prod_offer_id    comment '已办理销售品id'
,prod_offer_code  comment '已办理销售品编码'
,prod_offer_name  comment '已办理销售品名称'
,limit_date       comment '已办理销售品到期时间'
,disc_type_dl     comment '已办理销售品优惠大类'
,disc_type_xl     comment '已办理销售品优惠小类'
,param_value      comment 'YD0203-0822的赠金金额'
)
as
select
order_id
,data_date
,serv_id
,acc_nbr
,case when state_desc is null then '已拆机' else state_desc end as state_desc
,cdma_disc_desc
,prod_offer_id
,prod_offer_code
,prod_offer_name
,limit_date
,disc_type_dl
,disc_type_xl
,param_value
from zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026011300428
;
