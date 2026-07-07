【工单详情】
工单编号	XQGZ2026020501916	
需求标题	“翼教云教师套餐优惠_2013年二季度、YD0303-341”用户清单提取
提交人	高文欣	提交人电话	18925158671,	提交部门	广东公司/市分公司/广州分公司/教育行业及校园运营中心/校园运营团队
提交日期	2026-02-05 16:51:22
需求描述	翼教云教师套餐优惠_2013年二季度，产品编码：YD0303-341 上述产品有效期为一年，大多数集中在每年的2月到期，若不及时续约容易爆发集体投诉；因此需要提取套餐内容有该条产品标识的用户，确认需要续约的用户清单，避免用户投诉

【取数口径】
提取移动用户当前已办理销售品编码为YD0303-341（含已过期但优惠标识仍在）的实例清单，并更新该用户使用状态、客户姓名、划小局向、入网时间、揽装人、vpn群号等信息

【输出字段】
'序号','服务标识','接入号','号码划小局向','号码使用状态','移动主套餐名称','号码入网时间','号码揽装人','YD0303-341失效时间','YD0303-341每月赠送金额','客户姓名（脱敏）','VPN群号','VPN群名','服务分群','是否黑名单','202511月出账费用','202512月出账费用','202601月出账费用'


--##插入 当前已办理销售品编码为YD0303-341（含已过期但优惠标识仍在）的实例清单	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916 as
select distinct
a.serv_id,
a.acc_nbr,
a.prod_offer_id,
b.prod_offer_code,
b.offer_name as prod_offer_name,
a.msobjgrp_id,
to_date(a.limit_date) as limit_date
from summary_ods_day_city.rpt_comm_cm_msdisc a
left join dws_crm_cfguse.dws_offer b on a.prod_offer_id=b.offer_id and b.city_id=200
where a.prod_id in (3204,3205) 
and b.prod_offer_code='YD0303-341'
;

--##更新 最新时点 使用状态、客户姓名、划小局向、入网时间、揽装人、vpn群号	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_1 as
select
a.*,
b.state,
c.attr_value_name as state_desc,   --使用状态
b.cust_name,
b.subst_name,
to_date(b.open_date) as open_date,
b.sales_name,
b.vpn_value,
b.vpn_price,
b.serv_grp_type,
case when b.serv_grp_type = '01' then '政企' else '公众' end as serv_grp_type_desc,  --服务分群中文
b.is_hy,
case when b.is_hy = 1 then '是' else '否' end as is_hy_desc,  --是否活跃中文
b.cdma_disc_type,
d.cdma_disc_desc    --移动主套餐名称
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916 a
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and b.par_month_id=${month_id} and b.is_cancel_user=0
left join dws_crm_cfguse.dws_attr_value c on b.state=c.attr_value and c.city_id='200' and c.attr_id = '4000000201'  --更新使用状态
left join metadata_ods_day.md_ft_cdma_disc_config d on b.cdma_disc_type=d.cdma_disc_id   --更新移动主套餐名称 
where 1=1
;

--##生成 最新时点 是否黑名单 打标清单	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_1 as
select distinct
a.serv_id,
1 as is_hmd
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916 a
inner join zone_gz_yz.dwd_yz_sensit_cust_list_final b on a.serv_id=b.serv_id and b.cust_type='黑名单'
where 1=1
;

--##生成 最新时点 YD0303-341每月赠送通信费（单位：元）参数值 打标清单	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_2;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_2 as
select distinct
a.serv_id,
a.msobjgrp_id,
b.param_value
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916 a
join summary_ods_day_city.rpt_comm_cm_msparam b on a.serv_id=b.serv_id and a.msobjgrp_id=b.msobjgrp_id
join dws_crm_cfguse.dws_attr_spec_offer c on b.param_code=c.attr_inner_cd and c.attr_name = '每月赠送通信费（单位：元）'
where 1=1
;

--##生成 最新时点 vpn群名称 打标清单	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_3;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_3 as
select distinct	
a.serv_id,
b.ivpn_name
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_1 a
left join (select acc_nbr,ivpn_name,ccust_id,branch_org,manage_org,
           row_number() over(partition by acc_nbr order by create_date desc) as order_id
           from dws_ecust.dws_mo_ivpn
           where city_id in ('93','200')
           ) as b on a.vpn_value=b.acc_nbr and b.order_id=1
;

--##生成 202511月 公允后号码出账费用 打标清单---------------"	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_6;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_6 as
select
a.serv_id,
b.fee as fee_202511
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_1 a
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=202511
where 1=1
group by
a.serv_id,
b.fee
;

--##生成 202512月 公允后号码出账费用 打标清单---------------"	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_7;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_7 as
select
a.serv_id,
b.fee as fee_202512
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_1 a
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=202512
where 1=1
group by
a.serv_id,
b.fee
;

--##生成 202601月 公允后号码出账费用、主叫时长、上网流量 打标清单---------------"	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_8;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_8 as
select
a.serv_id,
b.fee as fee_202601,
b.mou_call as mou_call_202601,
b.stm_data as stm_data_202601
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_1 a
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=202601
where 1=1
group by
a.serv_id,
b.fee,
b.mou_call,
b.stm_data
;

--##整合更新 全部标签字段
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_2;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_2 as
select
a.*,
(case when b1.is_hmd=1 then '是' else '否' end) as is_hmd,
b2.param_value,
b3.ivpn_name,
b6.fee_202511,
b7.fee_202512,
b8.fee_202601,
b8.mou_call_202601,
b8.stm_data_202601,
(case when length(a.cust_name)<2 then a.cust_name
      when length(a.cust_name)=2 then concat(SUBSTR(a.cust_name,1,1),'*')
      when length(a.cust_name)>2 then concat(SUBSTR(a.cust_name,1,(length(a.cust_name)-2)),'**')
      else null end) as cust_name_tm
from (select x.*,x.serv_id as serv_id1
      from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_1 as x) a
left join zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_1 b1 on a.serv_id=b1.serv_id
left join zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_2 b2 on a.serv_id1=b2.serv_id and a.msobjgrp_id=b2.msobjgrp_id
left join zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_3 b3 on a.serv_id=b3.serv_id
left join zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_6 b6 on a.serv_id1=b6.serv_id
left join zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_7 b7 on a.serv_id=b7.serv_id
left join zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_lbl_8 b8 on a.serv_id1=b8.serv_id
where 1=1
;


--##【生成结果清单】
drop table if exists zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026020501916;
create table zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026020501916 as
select 
row_number() over (order by serv_id) as order_id
,serv_id
,acc_nbr
,subst_name
,state_desc
,cdma_disc_desc
,open_date
,sales_name
,limit_date
,param_value
,cust_name_tm
,vpn_value
,ivpn_name
,serv_grp_type_desc
,is_hmd
,is_hy_desc
,fee_202511
,fee_202512
,fee_202601
,mou_call_202601
,stm_data_202601
from zone_gz_yz.tmp_yz_cqh_XQGZ2026020501916_2
;

--#####【创建视图】
drop view if exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2026020501916;
create view if not exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2026020501916 
(
order_id                    comment '序号'
,serv_id                    comment '服务标识'
,acc_nbr                    comment '接入号'
,subst_name                 comment '号码划小局向'
,state_desc                 comment '号码使用状态'
,cdma_disc_desc             comment '移动主套餐名称'
,open_date                  comment '号码入网时间'
,sales_name                 comment '号码揽装人'
,limit_date                 comment 'YD0303-341失效时间'
,param_value                comment 'YD0303-341每月赠送金额'
,cust_name_tm               comment '客户姓名（脱敏）'
,vpn_value                  comment 'VPN群号'
,ivpn_name                  comment 'VPN群名'
,serv_grp_type_desc         comment '服务分群'
,is_hmd                     comment '是否黑名单'
,fee_202511                 comment '202511月出账费用'
,fee_202512                 comment '202512月出账费用'
,fee_202601                 comment '202601月出账费用'
)                                                                         
as
select
order_id
,serv_id
,acc_nbr
,subst_name
,state_desc
,cdma_disc_desc
,open_date
,sales_name
,limit_date
,param_value
,cust_name_tm
,vpn_value
,ivpn_name
,serv_grp_type_desc
,is_hmd
,fee_202511
,fee_202512
,fee_202601
from zone_gz_yz.ads_yz_cqh_tmp_XQGZ2026020501916
;

