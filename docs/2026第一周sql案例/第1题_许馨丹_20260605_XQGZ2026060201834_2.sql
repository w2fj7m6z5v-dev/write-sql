工单编号	XQGZ2026060201834	需求标题	需求通过快捷宽带的子账号反查该批号码的7级地址的需求	需求关键词	查询7级地址
提交人	潘宇新	提交人电话	18998387739,	提交部门	广东公司/市分公司/广州分公司/天河分公司/临-外部组织/临-天河沙太城中村营销服务中心
提交日期	2026-06-02 16:14:13	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	产品支撑类需求(B类)-宽带多媒体类	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2026-06-03 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	因代理商对名下宽带业务不清晰，要求沙太营服协助查询以下清单内的所有宽带业务的7级地址，请协助查询，谢谢
需求目标	查询7级地址
测试案例要求	

需求梳理：
根据附件清单的宽带号码提取对应的标准装机地址，再关联对应的7级地址

输出字段：接入号、7级地址id、7级地址名称

--导入需求附件的接入号并匹配号码标准装机地址
drop table tmp_XQGZ2026060201834;
create table tmp_XQGZ2026060201834
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select index2 acc_nbr,b.serv_id,b.serv_addr_id
from zone_gz_yz_3392082398668800 a
left join (select serv_id,serv_addr_id,acc_nbr from dwm_yz_tb_comm_cm_all_final where par_month_id=202606) b on a.index2=b.acc_nbr
;

--关联7级地址id
drop table tmp_XQGZ2026060201834_2;
create table tmp_XQGZ2026060201834_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,b.addr_id_7
from tmp_XQGZ2026060201834 a
left join dwd_yz_addr_final b on cast(a.serv_addr_id as decimal(24,0))=cast(b.id as decimal(24,0))
;

--翻译7级地址中文名称
drop table tmp_XQGZ2026060201834_3;
create table tmp_XQGZ2026060201834_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,addr addr_id_7_name
from tmp_XQGZ2026060201834_2 a
left join dwd_yz_addr_final b on cast(a.addr_id_7 as decimal(24,0))=cast(b.id as decimal(24,0))
;

--输出
drop table ads_XQGZ2026060201834;
create table ads_XQGZ2026060201834
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select acc_nbr,addr_id_7,addr_id_7_name
from tmp_XQGZ2026060201834_3
;