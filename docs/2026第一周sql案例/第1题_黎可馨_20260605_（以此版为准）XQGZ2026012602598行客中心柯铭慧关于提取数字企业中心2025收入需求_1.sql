需求原始内容：
工单编号	XQGZ2026012602598	需求标题	关于提取数字企业中心2025收入需求	需求关键词	关于提取数字企业中心2025收入需求
提交人	柯铭慧	提交人电话	17302006576,	提交部门	广东公司/市分公司/广州分公司/政企客户部/行业客户中心
提交日期	2026-01-26 18:27:09	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	业务数据处理类需求(E类)-业务批处理	要求独立测试报告	否
首要系统	数据架构平台(EDA)-企业全融合数字化平台-MSS报表平台	工作总量	0
相关系统		系统模块	
期望完成时间	2026-01-27 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
是否涉及清单数据	否	本地系统名称		本地系统ip地址	
本地系统负责人邮箱		采集账号		文件名或表名	
目标系统名称		目标系统ip地址	
应用场景	
需求描述	关于提取数字企业中心主建客户的2025年总收入（详见附件），分基本面、产数。请协助处理谢谢

需求梳理：按照需求方附件提供的名单制客户信息，按照产权客户编码提取客户对应账期的基本面收入和产数收入

输出字段：客户类型，产权客户编码，p码，直销客户编码，26年局向，营服，客户类型，bg类型，bu类型，各账期基本面收入，各账期产数收入


--导入名单制客户list
drop table if exists ads_yz_hkzx_kmh_mdzhk purge;
create table ads_yz_hkzx_kmh_mdzhk
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select index1 as type,
index2 as cust_nbr,
index3 as cust_name,
index4 as p_nbr,
index5 as p_name,
index6 as cust_code,
index7 as ccust_name,
index8 as subst_name26,
index9 as branch_name,
index10 as staff_name,
index11 as hk_flag,
index12 as bg_type,
index13 as bu_type
from zone_gz_yz_3461990841409536;
select count(*) from ads_yz_hkzx_kmh_mdzhk;--17501


--取收入
drop table if exists tmp_20260129_check_mdzhk_cust_nbr_sr purge;
create table tmp_20260129_check_mdzhk_cust_nbr_sr
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select 
sum(case when par_month_id = 202501 then fee_fm_new else 0 end) as jbm01,
sum(case when par_month_id = 202502 then fee_fm_new else 0 end) as jbm02,
sum(case when par_month_id = 202503 then fee_fm_new else 0 end) as jbm03,
sum(case when par_month_id = 202504 then fee_fm_new else 0 end) as jbm04,
sum(case when par_month_id = 202505 then fee_fm_new else 0 end) as jbm05,
sum(case when par_month_id = 202506 then fee_fm_new else 0 end) as jbm06,
sum(case when par_month_id = 202507 then fee_fm_new else 0 end) as jbm07,
sum(case when par_month_id = 202508 then fee_fm_new else 0 end) as jbm08,
sum(case when par_month_id = 202509 then fee_fm_new else 0 end) as jbm09,
sum(case when par_month_id = 202510 then fee_fm_new else 0 end) as jbm10,
sum(case when par_month_id = 202511 then fee_fm_new else 0 end) as jbm11,
sum(case when par_month_id = 202512 then fee_fm_new else 0 end) as jbm12,

sum(case when par_month_id = 202501 then fee_cs else 0 end) as cs01,
sum(case when par_month_id = 202502 then fee_cs else 0 end) as cs02,
sum(case when par_month_id = 202503 then fee_cs else 0 end) as cs03,
sum(case when par_month_id = 202504 then fee_cs else 0 end) as cs04,
sum(case when par_month_id = 202505 then fee_cs else 0 end) as cs05,
sum(case when par_month_id = 202506 then fee_cs else 0 end) as cs06,
sum(case when par_month_id = 202507 then fee_cs else 0 end) as cs07,
sum(case when par_month_id = 202508 then fee_cs else 0 end) as cs08,
sum(case when par_month_id = 202509 then fee_cs else 0 end) as cs09,
sum(case when par_month_id = 202510 then fee_cs else 0 end) as cs10,
sum(case when par_month_id = 202511 then fee_cs else 0 end) as cs11,
sum(case when par_month_id = 202512 then fee_cs else 0 end) as cs12,

a.cust_nbr
from dwm_srhx_serv_list_mon_final a
join ads_yz_hkzx_kmh_mdzhk b
on a.cust_nbr = b.cust_nbr
where a.par_month_id >= 202501
group by 
a.cust_nbr;
select * from tmp_20260129_check_mdzhk_cust_nbr_sr;
select count(*) from tmp_20260129_check_mdzhk_cust_nbr_sr;



--收入匹配
drop table if exists ads_yz_hkzx_kmh_mdzhk_sr_list purge;
create table ads_yz_hkzx_kmh_mdzhk_sr_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select 
200 as city_id,
a.type,
a.cust_nbr,
a.p_nbr,
a.cust_code,
a.subst_name26,
a.branch_name,
a.hk_flag,
a.bg_type,
a.bu_type,
b.jbm01,
b.jbm02,
b.jbm03,
b.jbm04,
b.jbm05,
b.jbm06,
b.jbm07,
b.jbm08,
b.jbm09,
b.jbm10,
b.jbm11,
b.jbm12,
b.cs01,
b.cs02,
b.cs03,
b.cs04,
b.cs05,
b.cs06,
b.cs07,
b.cs08,
b.cs09,
b.cs10,
b.cs11,
b.cs12
from ads_yz_hkzx_kmh_mdzhk a
left join tmp_20260129_check_mdzhk_cust_nbr_sr b
on a.cust_nbr = b.cust_nbr;
select * from ads_yz_hkzx_kmh_mdzhk_sr_list;
select count(*) from ads_yz_hkzx_kmh_mdzhk_sr_list;