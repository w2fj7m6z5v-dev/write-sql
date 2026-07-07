
工单编号 XQGZ2025041701485 需求标题 关于2023年线上电渠放号的在网和收入核查需求 需求关键词 线上电渠放号的在网和收入核查 
提交人 江鑫鹏 提交人电话 13534505044, 提交部门 广东公司/市分公司/广州分公司/白云分公司/临-外部组织/临-销售部/临-渠道运营团队 
提交日期 2025-04-17 15:43:33 需求负责人  
  

需求内容   


涉及范围 分公司个性需求 是否影响客户感知 不影响 IT前向嵌入人员  
需求分类 套餐与营销活动支撑类需求(A类)-移动电话类 要求独立测试报告 否 
首要系统 业务支持系统(BSS)-新一代 CRM3.0 工作总量 0 
相关系统  系统模块  
期望完成时间 2025-04-18 00:00:00  计划完成时间  需求重要程度 低 
实现方式  实施紧急程度 一般 
退回原因  满意度  是否专项需求  
系统模块  影响用户数  影响单量  
业务风险  同类/历史工单单号  是否灰度验证测试  
系统类型  业务分类  
需求描述 一、背景：白云有一批号码，因为是23年上半年的电渠放号，按照电渠的规则，当时县分的放号，23年和24年收入都算原县分，25年才集约回全渠
二、需求：
1、这批放号都是2023年入网的，取2023年当年产生的基本面和划小收入，2024年产生的基本面和划小收入（限定收入归属白云）
2、这批放号在2023年12月的在网情况，在2024年12月的在网情况
三、问题：归集后白云目前无法查询有关历史数据 
需求目标 线上电渠放号的在网和收入核查 


需求梳理：根据附件提供的接入号，匹配号码23、24年的税后确认收入以及基本面收入，以及23、24年底在网情况
要求：
1、因为号码划小收入可能不属于白云分公司，在取收入的时候不能限定susbt_name='白云分公司'
2、号码仅看2312和2412是否拆机，号码在当月不存在或者是is_cancel_user=1即认为是不在网
输出字段：
接入号，23年基本面收入，23年税后确认收入，24年基本面收入，24年税后确认收入，2312是否拆机，2412是否拆机

--导入附件号码清单
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select index1  as acc_nbr
from zone_gz_yz_3542196629293056;  --17704

--统计号码23、24年基本面还有税后确认收入
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_02 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select acc_nbr
,sum(case when par_month_id>=202301 and par_month_id<=202312 then fee_fm_new else 0 end) as jbm23
,sum(case when par_month_id>=202301 and par_month_id<=202312 then a0 else 0 end) as hx23
,sum(case when par_month_id>=202401 and par_month_id<=202412 then fee_fm_new else 0 end) as jbm24
,sum(case when par_month_id>=202401 and par_month_id<=202412 then a0 else 0 end) as hx24
from dwm_srhx_serv_list_mon_final
where par_month_id>=202301 and par_month_id<=202412
group by acc_nbr;


--打标收入回号码清单
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_03 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.acc_nbr,b.jbm23,b.hx23,b.jbm24,b.hx24
from tmp_yz_xy_XQGZ2025041701485_01 a
left join tmp_yz_xy_XQGZ2025041701485_02 b on cast(a.acc_nbr as string)=cast(b.acc_nbr as string); 



--号码关联全业务资料表2312还有2412数据（限制当月不拆机is_cancel_user=0）判断号码2312还有2412是否拆机
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_04 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025041701485_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.*
,case when b.is_cancel_user is null then 1 else b.is_cancel_user end  as is_cj2312
,case when c.is_cancel_user is null then 1 else c.is_cancel_user end  as is_cj2412
from tmp_yz_xy_XQGZ2025041701485_03 a
left join (select par_month_id,acc_nbr,is_cancel_user from dwm_yz_tb_comm_cm_all_mon_final where par_month_id =202312 and is_cancel_user=0) b on a.acc_nbr=b.acc_nbr
left join (select par_month_id,acc_nbr,is_cancel_user from dwm_yz_tb_comm_cm_all_mon_final where par_month_id =202412 and is_cancel_user=0) c on a.acc_nbr=c.acc_nbr;


--结果表推送数据服务专区
drop table if exists zone_gz_yz.ads_yz_xy_XQGZ2025041701485 purge;
create table zone_gz_yz.ads_yz_xy_XQGZ2025041701485
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select 200 as city_id,a.*
from tmp_yz_xy_XQGZ2025041701485_04 a;




drop view if exists zone_gz.view_ads_yz_xy_XQGZ2025041701485;
create view if not exists zone_gz.view_ads_yz_xy_XQGZ2025041701485
(
acc_nbr            comment '提供的号码'
,jbm23             comment '23年基本面收入'
,hx23                  comment '23年划小收入'
,jbm24                  comment '24年基本面收入'
,hx24               comment '24年划小收入'
,is_cj2312                  comment '202312是否拆机 1：拆机 0：未拆机'
,is_cj2412                comment '202412是否拆机 1：拆机 0：未拆机'

)
as
select
acc_nbr            
,jbm23             
,hx23                  
,jbm24                  
,hx24               
,is_cj2312                  
,is_cj2412                
from zone_gz_yz.ads_yz_xy_XQGZ2025041701485;




