需求原始内容：
工单编号	XQGZ2026042002711	需求标题	关于电销团队新增电销团队收入报表需求	需求关键词	新增电销团队收入报表
提交人	李静瑜	提交人电话	18902381810,02034297553	提交部门	广东公司/市分公司/广州分公司/全渠道及数字化运营中心（大数据运营中心/订单支撑中心）/ 临-外部组织/临-电话营销团队
提交日期	2026-04-20 18:54:20	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	套餐与营销活动支撑类需求(A类)-宽带多媒体类	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2026-04-25 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	为更清晰了解电销团队业务收入情况，现申请增加电销月度收入报表，具体请见附件，如有疑问，请联系李静瑜18902381810，谢谢！
需求目标	新增电销团队收入报表

需求梳理：按照需求方附件提供的网点，提取网点对应各账期的税后确认收入

输出字段：网点id，网点编码，网点名称，当月收入，当年累计收入

--导入
drop table if exists ads_yz_qq_ljy_dianxiaotuandui_sales_code_list purge;
create table ads_yz_qq_ljy_dianxiaotuandui_sales_code_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select 
a.index1 as team,
a.index2 as sales_name,
a.index3 as sales_code
from zone_gz_yz_3461990841409536 a;



--按揽装人编码统计收入
drop table if exists tmp_ads_yz_qq_ljy_sr_sales_1 purge;
create table tmp_ads_yz_qq_ljy_sr_sales_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select sales_id,sales_code,sales_name,
sum(case when par_month_id = 202501 then a0 else 0 end) newsh2501,
sum(case when par_month_id >= 202501 and par_month_id <= 202501 then a0 else 0 end) sh2501,
sum(case when par_month_id = 202502 then a0 else 0 end) newsh2502,
sum(case when par_month_id >= 202501 and par_month_id <= 202502 then a0 else 0 end) sh2502,
sum(case when par_month_id = 202503 then a0 else 0 end) newsh2503,
sum(case when par_month_id >= 202501 and par_month_id <= 202503 then a0 else 0 end) sh2503,
sum(case when par_month_id = 202504 then a0 else 0 end) newsh2504,
sum(case when par_month_id >= 202501 and par_month_id <= 202504 then a0 else 0 end) sh2504,
sum(case when par_month_id = 202505 then a0 else 0 end) newsh2505,
sum(case when par_month_id >= 202501 and par_month_id <= 202505 then a0 else 0 end) sh2505,
sum(case when par_month_id = 202506 then a0 else 0 end) newsh2506,
sum(case when par_month_id >= 202501 and par_month_id <= 202506 then a0 else 0 end) sh2506,
sum(case when par_month_id = 202507 then a0 else 0 end) newsh2507,
sum(case when par_month_id >= 202501 and par_month_id <= 202507 then a0 else 0 end) sh2507,
sum(case when par_month_id = 202508 then a0 else 0 end) newsh2508,
sum(case when par_month_id >= 202501 and par_month_id <= 202508 then a0 else 0 end) sh2508,
sum(case when par_month_id = 202509 then a0 else 0 end) newsh2509,
sum(case when par_month_id >= 202501 and par_month_id <= 202509 then a0 else 0 end) sh2509,
sum(case when par_month_id = 202510 then a0 else 0 end) newsh2510,
sum(case when par_month_id >= 202501 and par_month_id <= 202510 then a0 else 0 end) sh2510,
sum(case when par_month_id = 202511 then a0 else 0 end) newsh2511,
sum(case when par_month_id >= 202501 and par_month_id <= 202511 then a0 else 0 end) sh2511,
sum(case when par_month_id = 202512 then a0 else 0 end) newsh2512,
sum(case when par_month_id >= 202501 and par_month_id <= 202512 then a0 else 0 end) sh2512,
sum(case when par_month_id = 202601 then a0 else 0 end) newsh2601,
sum(case when par_month_id >= 202601 and par_month_id <= 202601 then a0 else 0 end) sh2601,
sum(case when par_month_id = 202602 then a0 else 0 end) newsh2602,
sum(case when par_month_id >= 202601 and par_month_id <= 202602 then a0 else 0 end) sh2602,
sum(case when par_month_id = 202603 then a0 else 0 end) newsh2603,
sum(case when par_month_id >= 202601 and par_month_id <= 202603 then a0 else 0 end) sh2603,
sum(case when par_month_id = 202604 then a0 else 0 end) newsh2604,
sum(case when par_month_id >= 202601 and par_month_id <= 202604 then a0 else 0 end) sh2604
from dwm_srhx_serv_list_mon_final
where par_month_id >= 202501
group by sales_id,sales_code,sales_name;

--锁定sales_code
drop table if exists tmp_ads_yz_qq_ljy_sr_sales_2 purge;
create table tmp_ads_yz_qq_ljy_sr_sales_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select a.*
from tmp_ads_yz_qq_ljy_sr_sales_1 a
join ads_yz_qq_ljy_dianxiaotuandui_sales_code_list b
on a.sales_code = b.sales_code;

--打标收入
drop table if exists tmp_ads_yz_qq_ljy_sr_sales_3 purge;
create table tmp_ads_yz_qq_ljy_sr_sales_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select a.*,
b.newsh2501,
b.sh2501,
b.newsh2502,
b.sh2502,
b.newsh2503,
b.sh2503,
b.newsh2504,
b.sh2504,
b.newsh2505,
b.sh2505,
b.newsh2506,
b.sh2506,
b.newsh2507,
b.sh2507,
b.newsh2508,
b.sh2508,
b.newsh2509,
b.sh2509,
b.newsh2510,
b.sh2510,
b.newsh2511,
b.sh2511,
b.newsh2512,
b.sh2512,
b.newsh2601,
b.sh2601,
b.newsh2602,
b.sh2602,
b.newsh2603,
b.sh2603,
b.newsh2604,
b.sh2604
from ads_yz_qq_ljy_dianxiaotuandui_sales_code_list a
left join tmp_ads_yz_qq_ljy_sr_sales_2 b
on a.sales_code = b.sales_code;

--按网点编码统计收入
drop table if exists tmp_ads_yz_qq_ljy_sr_channel_1 purge;
create table tmp_ads_yz_qq_ljy_sr_channel_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select channel_id,channel_nbr,channel_name,
sum(case when par_month_id = 202501 then a0 else 0 end) newsh2501,
sum(case when par_month_id >= 202501 and par_month_id <= 202501 then a0 else 0 end) sh2501,
sum(case when par_month_id = 202502 then a0 else 0 end) newsh2502,
sum(case when par_month_id >= 202501 and par_month_id <= 202502 then a0 else 0 end) sh2502,
sum(case when par_month_id = 202503 then a0 else 0 end) newsh2503,
sum(case when par_month_id >= 202501 and par_month_id <= 202503 then a0 else 0 end) sh2503,
sum(case when par_month_id = 202504 then a0 else 0 end) newsh2504,
sum(case when par_month_id >= 202501 and par_month_id <= 202504 then a0 else 0 end) sh2504,
sum(case when par_month_id = 202505 then a0 else 0 end) newsh2505,
sum(case when par_month_id >= 202501 and par_month_id <= 202505 then a0 else 0 end) sh2505,
sum(case when par_month_id = 202506 then a0 else 0 end) newsh2506,
sum(case when par_month_id >= 202501 and par_month_id <= 202506 then a0 else 0 end) sh2506,
sum(case when par_month_id = 202507 then a0 else 0 end) newsh2507,
sum(case when par_month_id >= 202501 and par_month_id <= 202507 then a0 else 0 end) sh2507,
sum(case when par_month_id = 202508 then a0 else 0 end) newsh2508,
sum(case when par_month_id >= 202501 and par_month_id <= 202508 then a0 else 0 end) sh2508,
sum(case when par_month_id = 202509 then a0 else 0 end) newsh2509,
sum(case when par_month_id >= 202501 and par_month_id <= 202509 then a0 else 0 end) sh2509,
sum(case when par_month_id = 202510 then a0 else 0 end) newsh2510,
sum(case when par_month_id >= 202501 and par_month_id <= 202510 then a0 else 0 end) sh2510,
sum(case when par_month_id = 202511 then a0 else 0 end) newsh2511,
sum(case when par_month_id >= 202501 and par_month_id <= 202511 then a0 else 0 end) sh2511,
sum(case when par_month_id = 202512 then a0 else 0 end) newsh2512,
sum(case when par_month_id >= 202501 and par_month_id <= 202512 then a0 else 0 end) sh2512,
sum(case when par_month_id = 202601 then a0 else 0 end) newsh2601,
sum(case when par_month_id >= 202601 and par_month_id <= 202601 then a0 else 0 end) sh2601,
sum(case when par_month_id = 202602 then a0 else 0 end) newsh2602,
sum(case when par_month_id >= 202601 and par_month_id <= 202602 then a0 else 0 end) sh2602,
sum(case when par_month_id = 202603 then a0 else 0 end) newsh2603,
sum(case when par_month_id >= 202601 and par_month_id <= 202603 then a0 else 0 end) sh2603,
sum(case when par_month_id = 202604 then a0 else 0 end) newsh2604,
sum(case when par_month_id >= 202601 and par_month_id <= 202604 then a0 else 0 end) sh2604
from dwm_srhx_serv_list_mon_final
where par_month_id >= 202501
group by channel_id,channel_nbr,channel_name;

--锁定网点编码
drop table if exists tmp_ads_yz_qq_ljy_sr_channel_2 purge;
create table tmp_ads_yz_qq_ljy_sr_channel_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  as 
select * from tmp_ads_yz_qq_ljy_sr_channel_1
where channel_nbr IN (
'4401002246207',
'4401002220735',
'4401002366600',
'4401002088089',
'4401002449336',
'4401002144329',
'4401002321306',
'4401002378873',
'4401002327560',
'4401002255779');

