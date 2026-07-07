工单编号	XQGZ2026060902350	需求标题	关于提取广东京邦达供应链科技有限公司名下全部尊享专线的相关字段信息的申请	需求关键词	尊享专线
提交人	王坚涛	提交人电话	19195584885,	提交部门	广东公司/市分公司/广州分公司/白云分公司/临-外部组织/临-白云交通物流BU营销服务中心
提交日期	2026-06-09 18:42:04	需求负责人	
需求内容
涉及范围	全网（集团）性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	产品支撑类需求(B类)-数据专线类	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2026-06-10 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	我司中标了广东京邦达供应链科技有限公司的全省专线项目，省内其他地市的尊享专线也是通过广州下单受理的。为了应对京邦达专线新装和专线降价的需求，查明客户的降档的专线和续约后专线情况，避免遗漏缴费情况，特申请提取该客户名下的所有尊享专线的信息。
客户名称：广东京邦达供应链科技有限公司
所需字段：接入号，装机地址所属地市，地址，速率，实际月租，开通日期，专线到期日期，广州列收收入。表格字段见附件。
请领导审批，谢谢。
需求目标	尊享专线

需求梳理：
1.从全业务资料表取cust_name='广东京邦达供应链科技有限公司'的尊享专线（prod_id=57），接入号、速率、开通日期
2.由于标准装机地址serv_addr_id只有广州本地地址，取不到其他地市，所以取报装地址信息，前三个字作为装机地址所属地市。地址为敏感信息，与需求方沟通后不提供完整地址字段。
3.专线月租表ads_yz_sx_yz，取yz_cs_old
4.列收收入取划小收入表的税后确认收入a0
5.专线到期日期取双线全量清单的销售品到期时间prod_offer_limit_date。由于部分HLWZX不订购销售品，与需求方沟通后用合同到期时间end_date补打

--取尊享专线基础信息
drop table tmp_XQGZ2026060902350;
create table tmp_XQGZ2026060902350
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select serv_id,acc_nbr,speed_value,open_date
from dwm_yz_tb_comm_cm_all_final
where par_month_id=202606
and is_cancel_user=0
and prod_id=57
and cust_name='广东京邦达供应链科技有限公司'
;

--从dws_crm_cust.dws_prod_inst，取报装地址信息address_desc，用prod_inst_id和serv_id关联
drop table tmp_XQGZ2026060902350_01;
create table tmp_XQGZ2026060902350_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,b.address_desc
from tmp_XQGZ2026060902350 a
left join (select prod_inst_id,address_desc from dws_crm_cust.dws_prod_inst where city_id=200) b on a.serv_id=b.prod_inst_id
;

--取地址前三个字为地市
drop table tmp_XQGZ2026060902350_02;
create table tmp_XQGZ2026060902350_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,substr(address_desc,0,3) city_name
from tmp_XQGZ2026060902350_01 a
;

--取6月月租
drop table tmp_XQGZ2026060902350_03;
create table tmp_XQGZ2026060902350_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,yz_cs_old yz_cs
from tmp_XQGZ2026060902350_02 a
left join ads_yz_sx_yz b on a.serv_id=b.serv_id and b.par_month_id=202606
;

--取5月确认收入
drop table tmp_XQGZ2026060902350_04;
create table tmp_XQGZ2026060902350_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,b.a0
from tmp_XQGZ2026060902350_03 a
left join (select serv_id,a0 from dwm_srhx_serv_list_mon_final where par_month_id=202605) b on a.serv_id=b.serv_id
;

--取协议到期时间prod_offer_limit_date，用合同到期时间end_date补打
drop table tmp_XQGZ2026060902350_05;
create table tmp_XQGZ2026060902350_05
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,coalesce(prod_offer_limit_date,end_date) prod_offer_limit_date
from tmp_XQGZ2026060902350_04 a
left join ads_yz_sx_qlyz_list_all b on a.serv_id=b.serv_id and b.par_month_id=202606
;