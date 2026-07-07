【工单详情】
工单编号	XQGZ2025021301768	
需求标题	关于越秀2025年各月份终补到期用户量统计的需求
提交人	陈慧仪	提交人电话	18922169692,02038851865	提交部门	广州分公司/越秀分公司/销售部
提交日期	2025-02-13 18:05:16
需求描述	为做好2025年全年越秀终补到期用户统计分析，申请全年各月份到期用户量数据。需求口径及字段参照需求XQGZ2024102100852，微调提取字段为：销售品编码、销售品名称、销售品到期月份、移动号码中类（融合/后付费单产品）、移动号码是否低渗高补、个人名/公司名、移动号码数，并锁定号码划小局向为越秀。麻烦业支陈琦慧协助处理，十分感谢！
        
【取数口径】
提取划小局向为越秀，且已办理了终端补贴销售品，且销售品到期时间为2025年的移动号码统计数

【输出字段】
'序号','销售品编码','销售品名称','销售品到期月份','移动产品中类','移动号码是否低渗高补','个人名/公司名','移动号码数'
  
--###插入 办理了终端补贴销售品，且销售品到期时间为2025年的清单(从优惠资料表)
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025021301768;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025021301768 as
select distinct 
serv_id,
acc_nbr,
prod_id,
prod_offer_id,
msobjgrp_id,
to_date(limit_date) as limit_date,
date_format(limit_date,'yyyyMM') as limit_month
from summary_ods_day_city.rpt_comm_cm_msdisc
where prod_id in (3204,3205) 
and prod_offer_id in (select prod_offer_id from zone_gz_yz.ads_dim_yz_yd_ydxy_disc_new where is_target_disc=1 and disc_type_dl='终端补贴')
and date_format(limit_date,'yyyy') = 2025
;

--###更新 最新时点 销售品编码/名称、移动号码是否低渗高补、移动产品中类、个人名/公司名
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025021301768_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025021301768_1 as
select 
a.*,
b.prod_offer_code,
b.offer_name as prod_offer_name,
case when c.is_dsgb=1 then '是' else '否' end as is_dsgb_desc,
d.yd_prod_type1,
case when d.is_gsm=1 then '公司名' else '个人名' end as serv_type,  --个人名/公司名
d.subst_id
from zone_gz_yz.tmp_yz_cqh_XQGZ2025021301768 a
left join dws_crm_cfguse.dws_offer b on a.prod_offer_id=b.offer_id and b.city_id=200
left join (select distinct acc_nbr,1 as is_dsgb
           from zone_gz_sy.dwd_sy_bhy_yhya_tb_yhya_fzzk_bl_list_mon
           where par_month_id=date_format(current_date(),'yyyyMM')  --当前月份
           ) c on a.acc_nbr=c.acc_nbr
left join (select distinct serv_id,yd_prod_type1,is_gsm,subst_id
           from zone_gz_yz.dwm_yz_tb_comm_cm_all_final
           where par_month_id=date_format(current_date(),'yyyyMM')  --当前月份
           ) d on a.serv_id=d.serv_id
;

--###生成 统计结果表（锁定划小局向为越秀）
drop table if exists zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025021301768;
create table zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025021301768 as
select 
row_number() over (order by prod_offer_code) as order_id  --序号
,prod_offer_code
,prod_offer_name
,limit_month
,yd_prod_type1
,is_dsgb_desc
,serv_type
,count(distinct serv_id) as cnt_dq_acc
from tmp_yz_cqh_XQGZ2025021301768_1
where subst_id=10061    --锁定划小局向为越秀
group by 
prod_offer_code
,prod_offer_name
,limit_month
,yd_prod_type1
,is_dsgb_desc
,serv_type
order by limit_month
;


####################################################################################################
--#####【创建视图语句】
drop view if exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2025021301768;
create view if not exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2025021301768
(
order_id                    comment '序号'
,prod_offer_code            comment '销售品编码'
,prod_offer_name            comment '销售品名称'
,limit_month                comment '销售品到期月份'
,yd_prod_type1              comment '移动产品中类'
,is_dsgb_desc               comment '移动号码是否低渗高补'
,serv_type                  comment '个人名/公司名'
,cnt_dq_acc                 comment '移动号码数'
)
as
select
order_id
,prod_offer_code
,prod_offer_name
,limit_month
,yd_prod_type1
,is_dsgb_desc
,serv_type
,cnt_dq_acc
from zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025021301768
;

