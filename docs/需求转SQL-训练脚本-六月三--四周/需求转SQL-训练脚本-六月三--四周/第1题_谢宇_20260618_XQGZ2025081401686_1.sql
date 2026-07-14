工单编号	XQGZ2025081401686	需求标题	关于目标7级地址内已有宽带接入号提取的需求	需求关键词	目标7级地址内已有宽带接入号提取
提交人	罗梓峰	提交人电话	18144884620,	提交部门	广东公司/市分公司/广州分公司/黄埔分公司/临-外部组织/临-销售部
提交日期	2025-08-14 16:23:11	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	业务数据统计分析类需求(F类)-新增数据统计（生产运营）	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2025-08-15 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
数据分类	用户基本资料	数据有效期	2025-08-31 00:00:00	是否涉及二级非脱敏用户	否
需求描述	近期东圃城中村针对前进村部分共享楼栋进行摸查，经摸查此批楼栋有共享楼栋51栋，现申请对附件内51栋共享楼栋对应7级地址下的接入号、客户姓名进行提取，麻烦业支帮忙提取生产，谢谢。
需求目标	完成清单提取


需求梳理：
根据提供的附件（包含七级地址，七级地址id）匹配地址下的所有接入号及客户名称

要求：
1、全业务资料表的地址id为为10级地址id，没有办法根据7级地址id直接查找，先匹配7级地址的所有10级地址id
2、不在地址库的地址打标不上10级地址id

输出字段：
七级地址id，七级地址，接入号，十级地址id，客户名称

--导入7级地址
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select index1 as addr7,index2 as addr_id_7
from zone_gz_yz_3542196629293056;  --51

--地址库找七级地址下的十级地址
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_02 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select a.id,a.grade,a.addr_id_7
from dwd_yz_addr_final a
left semi join tmp_yz_xy_XQGZ2025081401686_01 b on cast(b.addr_id_7 as string)=cast(a.addr_id_7 as string); --825

--剔重10级地址id
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_03 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select * from tmp_yz_xy_XQGZ2025081401686_02
where grade=10; --456


--匹配10姐地址id找号码 客户名称
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_04 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select a.acc_nbr,a.serv_id,a.cust_name,a.serv_addr_id,a.is_gsm
from dwm_yz_tb_comm_cm_all_final a
left semi join tmp_yz_xy_XQGZ2025081401686_03 b on cast(a.serv_addr_id as string)=cast(b.id as string)
where a.par_month_id=202508; --268

--打回原7级地址清单
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_05 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025081401686_05
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select b.addr_id_7,c.addr7,a.acc_nbr,a.serv_addr_id,a.cust_name
from tmp_yz_xy_XQGZ2025081401686_04 a
left join tmp_yz_xy_XQGZ2025081401686_03 b on cast(a.serv_addr_id as string)=cast(b.id as string)
left join tmp_yz_xy_XQGZ2025081401686_01 c on cast(b.addr_id_7 as string)=cast(c.addr_id_7 as string); --268

--结果表
drop table if exists zone_gz_yz.ads_yz_xy_XQGZ2025081401686 purge;
create table zone_gz_yz.ads_yz_xy_XQGZ2025081401686
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select * from tmp_yz_xy_XQGZ2025081401686_05;