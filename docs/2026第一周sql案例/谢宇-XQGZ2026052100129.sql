工单编号	XQGZ2026052100129	需求标题	关于中国共产党广州市委员会党校(广州行政学院)固话使用情况提取	需求关键词	固话使用情况提取
提交人	潘楚琴	提交人电话	17702040280,	提交部门	广东公司/市分公司/广州分公司/政企客户部/临-外部组织/临-经营分析团队
提交日期	2026-05-21 09:23:56	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	业务数据处理类需求(E类)-业务批处理	要求独立测试报告	否
首要系统	业务支持系统(BSS)-计费账务系统-新一代CBS3.0	工作总量	0
相关系统		系统模块	
期望完成时间	2026-05-31 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	客户中国共产党广州市委员会党校(广州行政学院)，产权编码：3020032188530000；因客户业务调整需求，申请提取党校近半年出账情况，当前套餐名称，是否有增值业务，增值业务内容及月租。详细号码清单及提取字段见附件，请协助处理，谢谢。

需求梳理： 
根据附件号码清单，提前出账收入和在用销售品
输出字段：接入号、在用销售品名称、202511月-202604月收入，每个月用一个字段

--号码清单
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select distinct index1 as seq,index2 as acc_nbr from zone_gz_yz_3542196629293056; --248


--打标2511-2604出账金额
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_01c purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_01c
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.*,b.par_month_id,b.serv_id,b.fee 
from tmp_yz_xy_XQGZ2026052100129_01 a
left join dwm_yz_tb_comm_cm_all_mon_final b on a.acc_nbr=b.acc_nbr and b.par_month_id>=202511 and b.par_month_id<=202604; --1488

--出账金额打横
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_01cc purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_01cc
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select seq,acc_nbr,serv_id
,sum(case when par_month_id=202511 then fee else 0 end) as fee_202511
,sum(case when par_month_id=202512 then fee else 0 end) as fee_202512
,sum(case when par_month_id=202601 then fee else 0 end) as fee_202601
,sum(case when par_month_id=202602 then fee else 0 end) as fee_202502
,sum(case when par_month_id=202603 then fee else 0 end) as fee_202603
,sum(case when par_month_id=202604 then fee else 0 end) as fee_202604
from tmp_yz_xy_XQGZ2026052100129_01c
group by seq,acc_nbr,serv_id; --248




--打标目前在用销售品
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_02 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.*,b.prod_offer_code
from tmp_yz_xy_XQGZ2026052100129_01cc a
left join ads_yz_rpt_comm_cm_msdisc_final b on a.serv_id=b.serv_id and b.par_month_id=202605; --432


--打标销售品名称
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_03 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2026052100129_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.*,b.offer_name
from tmp_yz_xy_XQGZ2026052100129_02 a
left join dws_crm_cfguse.dws_offer b on a.prod_offer_code=b.prod_offer_code and b.city_id = '200'; --432


--结果表
drop table if exists zone_gz_yz.ads_yz_xy_XQGZ2026052100129 purge;
create table zone_gz_yz.ads_yz_xy_XQGZ2026052100129
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select distinct seq,acc_nbr,offer_name,fee_202511,fee_202512,fee_202601,fee_202502 as fee_202602,fee_202603,fee_202604
from tmp_yz_xy_XQGZ2026052100129_03 
order by cast(seq as int) asc;




