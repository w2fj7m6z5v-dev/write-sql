工单编号	XQGZ2026032601188	需求标题	因业务发展需要，请协助匹配目标客户相关信息	需求关键词	因业务发展需要，请协助匹配目标客户相关信息
提交人	周思佳	提交人电话	18922168005,02083623917	提交部门	广东公司/市分公司/广州分公司/政企客户部/渠道与合作团队
提交日期	2026-03-26 14:21:50	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	业务数据处理类需求(E类)-业务批处理	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2026-03-27 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	否
系统类型		业务分类	
需求描述	因业务发展需要，请协助匹配目标客户相关信息，详细字段见附件。
需求目标	因业务发展需要，请协助匹配目标客户相关信息
测试案例要求	
备注	
要求规格说明	

需求梳理：1.根据需求方提供的客户名称，从dws_ecust.dws_mo_ccust匹配直销客户编码、局向、营服
2.dws_ecust.dws_mo_ccust_management，manager_type='DUTY'匹配客户经理
3.从本地ads_yz_mo_ccust_mdz_final匹配名单制信息，表中均为名单制客户

--导入客户名称
drop table tmp_XQGZ2026032601188_01;
create table tmp_XQGZ2026032601188_01 as
select cast(index1 as int) px,index2 ccust_name
from zone_gz_yz_3392082398668800
where index2<>''
;

--从省直销客户表匹配直销客户编码及局向、营服
drop table tmp_XQGZ2026032601188_02;
create table tmp_XQGZ2026032601188_02 as
select a.*,ccust_id,ccust_code,branch_org,manage_org
from tmp_XQGZ2026032601188_01 a
left join (select ccust_id,ccust_code,ccust_name,branch_org,manage_org from dws_ecust.dws_mo_ccust where city_id=200 and status_cd='S0A') b on a.ccust_name=b.ccust_name
;

--翻译局向营服名称，branch_org为局向id，manage_org为营服id
drop table tmp_XQGZ2026032601188_03;
create table tmp_XQGZ2026032601188_03 as
select a.*,b.org_name subst_name,c.org_name branch_name
from tmp_XQGZ2026032601188_02 a
left join dwd_yz_dim_org b on a.branch_org=b.org_id
left join dwd_yz_dim_org c on a.manage_org=c.org_id
;

--匹配客户经理信息
drop table tmp_XQGZ2026032601188_04;
create table tmp_XQGZ2026032601188_04 as
select a.*,manager_id
from tmp_XQGZ2026032601188_02 a
left join (select manager_id,ccust_id,
		  row_number() over(partition by ccust_id order by status_date desc) row_num
		 from dws_ecust.dws_mo_ccust_management
		 where city_id='200' and status_cd='1000' and manager_type='DUTY') b on a.ccust_id=b.ccust_id
;

--翻译客户经理名称
drop table tmp_XQGZ2026032601188_05;
create table tmp_XQGZ2026032601188_05 as
select a.*,b.staff_name manager_name
from tmp_XQGZ2026032601188_04 a
left join (select staff_id,staff_name,status_date,staff_account,staff_code,staff_hr_nbr,mobile_phone from dws_gesa.dws_staff where yyyymmdd=20260409 and city_id=200) b
on cast(a.manager_id as string)=b.staff_id
;

--匹配名单制信息
drop table tmp_XQGZ2026032601188_06;
create table tmp_XQGZ2026032601188_06 as
select a.*,b.bg,bu,staff_name,hk_flag
from tmp_XQGZ2026032601188_05 a
left join ads_yz_mo_ccust_mdz_final b on a.ccust_id=b.ccust_id
;