工单编号	XQGZ2026060100338	需求标题	关于提取金祥大厦A区3年内收入的需求	需求关键词	2023-2025 3年收入
提交人	吴剑清	提交人电话	18988927216,02083343157	提交部门	广东公司/市分公司/广州分公司/越秀分公司/流花政商营销服务中心
提交日期	2026-06-01 10:03:22	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	套餐与营销活动支撑类需求(A类)-品牌套餐类	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2026-06-02 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号	XQGZ2026031100323	是否灰度验证测试	
系统类型		业务分类	
需求描述	由于目前越秀区流花营服金祥大厦、2009002100005200000，A区面临移动竞争，竞争态势严峻，需为该网格申请驻地网网分成20%，需在请示中附金祥大厦A区3年（23年、24年、25年）各业务收入，请协助按年总收入、固话收入、宽带收入、专线收入提供，详见附件示例图，请领导审批，谢谢。
需求目标	2023、2024、2025年楼宇各业务收入

需求梳理：根据网格编码2009002100005200000 取网格下的年收入（23年、24年、25年）以及固话收入、宽带收入、专线收入
输出字段： 年份 年收入 固话收入、宽带收入、专线收入 


网格编码 200031556809

--提取该网格202301-202512总收入 固话收入 宽带收入 高值业务收入
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026060100338_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026060100338_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select par_month_id,cell_code
,sum(a0_sq) as sr_sq
,sum(case when prod_type=10 then a0_sq else 0 end) as sr_gh
,sum(case when prod_type=40 then a0_sq else 0 end) as sr_kd
,sum(case when acc_nbr like 'ADSLS%' or acc_nbr like 'IPCYW%' then a0_sq else 0 end) as sr_gzyw
from dwm_srhx_serv_list_mon_final 
where par_month_id>=202301 and par_month_id<=202512
and cell_code='200031556809'
group by par_month_id,cell_code;


--按照年份汇总收入数据
drop table if exists zone_gz_yz.ads_yz_xy_XQGZ2026060100338 purge;
create table zone_gz_yz.ads_yz_xy_XQGZ2026060100338
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select substr(par_month_id,1,4) as sum_year
,sum(sr_sq) as sr_sq
,sum(sr_gh) as sr_gh
,sum(sr_kd) as sr_kd
,sum(sr_gzyw) as sr_gzyw
from tmp_yz_xy_XQGZ2026060100338_01
group by substr(par_month_id,1,4);