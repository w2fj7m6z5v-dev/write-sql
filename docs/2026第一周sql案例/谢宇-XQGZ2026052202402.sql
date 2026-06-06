工单编号	XQGZ2026052202402	需求标题	筛选符合条件的天河普通商客	需求关键词	筛选符合条件的天河普通商客
提交人	何璐	提交人电话	18022866608,	提交部门	广东公司/市分公司/广州分公司/天河分公司/政企客户部
提交日期	2026-05-22 21:06:39	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	业务数据处理类需求(E类)-业务批处理	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2026-05-23 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	附件为天河落地普通商客，请业支筛选同时符合以下条件的客户：
1、25-26年只涉及天河划小收入的客户。
2、假如26年有新入网，只筛选天河分局揽装的客户。
需求目标	筛选符合条件的天河普通商客


需求梳理：根据附件的产权客户编码，判断25-26年收入是否全部划小分局是天河，并且26年是否有新入网号码，这些号码是否天河揽装
 输出字段：
产权客户编码，产权客户名称，25-26年收入是否全部划小分局都是天河分公司，26年是否有新入网号码，26年新入网号码是否有天河分公司揽装

--导入产权客户清单
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select distinct index1 as cust_nbr
from zone_gz_yz_3542196629293056;--1762


--根据产权客户编码取税后确认收入
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_02 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.cust_nbr,a.subst_name,sum(a.a0) as sr
from dwm_srhx_serv_list_mon_final a
left semi join tmp_yz_xy_XQGZ2026052202402_01 b on a.cust_nbr=b.cust_nbr
where a.par_month_id>=202501 and a.par_month_id<=202604
group by a.cust_nbr,a.subst_name; --2723


--打标划小局向是否天河分公司
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_03 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select cust_nbr,subst_name,
case when COALESCE(subst_name,'空')<>'天河分公司' and sr<>0 then 1 else 0 end as is_no_thsr
from tmp_yz_xy_XQGZ2026052202402_02; --2723


--按照客户汇总局向信息
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_04 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select cust_nbr,sum(is_no_thsr) as is_no_thsr
from tmp_yz_xy_XQGZ2026052202402_03 group by cust_nbr;--1762


--判断客户是否全部收入划小局向为天河分公司
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_05 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_05
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select cust_nbr,case when is_no_thsr>0 then '否' else '是' end as is_sr_th
from tmp_yz_xy_XQGZ2026052202402_04;  --1762


--找客户的新入网号码
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_06 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_06
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.par_month_id,a.acc_nbr,a.serv_id,a.channel_subst_name,a.cust_nbr
from dwm_yz_tb_comm_cm_all_mon_final a
left semi join tmp_yz_xy_XQGZ2026052202402_01 b on a.cust_nbr=b.cust_nbr
where a.par_month_id>=202601 and a.par_month_id<=202604
and a.is_new_user=1;

--打标是否有新入网号码
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_07 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_07
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.cust_nbr,a.is_sr_th
,case when b.cust_nbr is not null then '是' else '否' end is_new
from tmp_yz_xy_XQGZ2026052202402_05 a
left join (select distinct cust_nbr from tmp_yz_xy_XQGZ2026052202402_06) b on a.cust_nbr=b.cust_nbr; --1762


--打标是否有天河揽装的新入网号码
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_08 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052202402_08
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.*,
case when b.cust_nbr is not null then '是' else '否' end as is_new_th
from tmp_yz_xy_XQGZ2026052202402_07 a
left join (select distinct cust_nbr from tmp_yz_xy_XQGZ2026052202402_06 where channel_subst_name='天河分公司') b on a.cust_nbr=b.cust_nbr; --1762


--结果表
drop table if exists zone_gz_yz.ads_yz_xy_XQGZ2026052202402 purge;
create table zone_gz_yz.ads_yz_xy_XQGZ2026052202402
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select * from tmp_yz_xy_XQGZ2026052202402_08;



drop view if exists zone_gz.view_ads_yz_xy_XQGZ2026052202402;
create view if not exists zone_gz.view_ads_yz_xy_XQGZ2026052202402
(
cust_nbr               comment '产权客户编码'
,is_sr_th             comment '2501-2604是否全部划小收入都属于天河'
,is_new                  comment '2601-2604是否有新号码入网'
,is_new_th                  comment '2601-2604入网新号码是否有揽装局向为天河分公司'

)
as
select
cust_nbr               
,is_sr_th             
,is_new                  
,is_new_th                  
from zone_gz_yz.ads_yz_xy_XQGZ2026052202402;