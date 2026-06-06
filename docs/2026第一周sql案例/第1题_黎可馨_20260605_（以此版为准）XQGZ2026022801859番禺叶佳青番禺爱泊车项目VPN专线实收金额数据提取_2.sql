需求原始内容：
工单编号	XQGZ2026022801859	需求标题	番禺爱泊车项目VPN专线实收金额数据提取	需求关键词	实收金额
提交人	叶佳青	提交人电话	18988934445,	提交部门	广东公司/市分公司/广州分公司/番禺分公司/政企客户部
提交日期	2026-02-28 17:22:01	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	业务数据处理类需求(E类)-业务批处理	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2026-03-01 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	番禺爱泊车项目，因项目清算以及线路市场分析需要，申请批量提取项目VPN专线对应的2024年1月到2025年12月的实收金额 ，清单见附件， 请业支协助

需求梳理：按照需求方附件提供的接入号，提取号码对应各账期的实收金额

输出字段：号码标识，接入号，每月实收金额


--实收金额
drop table if exists tmp_ads_yz_py_apc_ssje_list_1 purge;
create table tmp_ads_yz_py_apc_ssje_list_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy') as
select par_month_id, serv_id, acc_nbr,
sum(case when flag = 'HF' then amount-amount_tc else 0 end)+sum(case when flag = 'OT' then amount else 0 end) as amount
from zone_gz_yz.dwd_yz_if_real_src_sum_new_final
where par_month_id>=202401 and par_month_id <= 202512 
group  by par_month_id, serv_id, acc_nbr;

--按月份打横
drop table if exists tmp_ads_yz_py_apc_ssje_list_2 purge;
create table tmp_ads_yz_py_apc_ssje_list_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy') as
select 
serv_id, 
acc_nbr,
sum(case when par_month_id = 202401 then amount else 0 end) as sh2401,
sum(case when par_month_id = 202402 then amount else 0 end) as sh2402,
sum(case when par_month_id = 202403 then amount else 0 end) as sh2403,
sum(case when par_month_id = 202404 then amount else 0 end) as sh2404,
sum(case when par_month_id = 202405 then amount else 0 end) as sh2405,
sum(case when par_month_id = 202406 then amount else 0 end) as sh2406,
sum(case when par_month_id = 202407 then amount else 0 end) as sh2407,
sum(case when par_month_id = 202408 then amount else 0 end) as sh2408,
sum(case when par_month_id = 202409 then amount else 0 end) as sh2409,
sum(case when par_month_id = 202410 then amount else 0 end) as sh2410,
sum(case when par_month_id = 202411 then amount else 0 end) as sh2411,
sum(case when par_month_id = 202412 then amount else 0 end) as sh2412,
sum(case when par_month_id = 202501 then amount else 0 end) as sh2501,
sum(case when par_month_id = 202502 then amount else 0 end) as sh2502,
sum(case when par_month_id = 202503 then amount else 0 end) as sh2503,
sum(case when par_month_id = 202504 then amount else 0 end) as sh2504,
sum(case when par_month_id = 202505 then amount else 0 end) as sh2505,
sum(case when par_month_id = 202506 then amount else 0 end) as sh2506,
sum(case when par_month_id = 202507 then amount else 0 end) as sh2507,
sum(case when par_month_id = 202508 then amount else 0 end) as sh2508,
sum(case when par_month_id = 202509 then amount else 0 end) as sh2509,
sum(case when par_month_id = 202510 then amount else 0 end) as sh2510,
sum(case when par_month_id = 202511 then amount else 0 end) as sh2511,
sum(case when par_month_id = 202512 then amount else 0 end) as sh2512
from tmp_ads_yz_py_apc_ssje_list_1
group by serv_id, 
acc_nbr;

--导入需求方附件号码
drop table if exists tmp_ads_yz_py_apc_ssje_list_3 purge;
create table tmp_ads_yz_py_apc_ssje_list_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy') as
select * from zone_gz_yz_3461990841409536;

--取附件号码实收金额
drop table if exists tmp_ads_yz_py_apc_ssje_list_4 purge;
create table tmp_ads_yz_py_apc_ssje_list_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy') as
select a.* from tmp_ads_yz_py_apc_ssje_list_2 a
join tmp_ads_yz_py_apc_ssje_list_3 b
on a.acc_nbr = b.index1;

select * from tmp_ads_yz_py_apc_ssje_list_4 limit 1000;