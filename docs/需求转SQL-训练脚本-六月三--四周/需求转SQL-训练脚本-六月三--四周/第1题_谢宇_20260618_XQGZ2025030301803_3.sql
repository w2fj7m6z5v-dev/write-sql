
工单编号 XQGZ2025030301803 需求标题 【第3期技能人才星级评定】政企客户经理责任名单制客户收入增量和增长率取数需求 需求关键词 【第3期技能人才星级评定】政企客户经理责任名单制客户收入增量和增长率取数需求 
提交人 刘晚军 提交人电话 18922168895, 提交部门 广东公司/市分公司/广州分公司/政企客户部/经营分析团队 
提交日期 2025-03-03 16:08:29 需求负责人  
  

需求内容   


涉及范围 分公司个性需求 是否影响客户感知 不影响 IT前向嵌入人员  
需求分类 业务数据统计分析类需求(F类)-现有报表修正 要求独立测试报告 否 
首要系统 业务支持系统(BSS)-新一代 CRM3.0 工作总量 0 
相关系统  系统模块  
期望完成时间 2025-03-04 00:00:00  计划完成时间  需求重要程度 高 
实现方式  实施紧急程度 一般 
退回原因  满意度  是否专项需求  
系统模块  影响用户数  影响单量  
业务风险 其他 同类/历史工单单号  是否灰度验证测试  
系统类型  业务分类  
业务风险内容 无风险 
需求描述 为配合分公司人力部第3期技能人才星级评定工作，现需提取政企客户经理责任名单制客户24年收入增量和增长率数据和对应收入清单（具体口径和字段见附件），为方便各单位核对申诉，请同时将客户收入清单按客户局向拆分推送至各单位负责人（名单见附件），谢谢！ 
需求目标 【第3期技能人才星级评定】政企客户经理责任名单制客户收入增量和增长率数据

需求梳理：
1、统计附件客户经理（包含客户经理编码，客户经理名称）对应的直销客户23、24年的收入，其中客户经理对应的直销客户范围为附件的客户名单（包含直销客户名称，直销客户编码，客户局向，是否vip，对应的客户经理编码，客户经理名称）
2、统计附件客户名单23、24年收入

要求：
1、统计附件直销客户23、24年的税后确认收入，对于同一直销客户存在改名字的情况，仅按照直销客户编码汇总
2、按照客户经理汇总其对应直销客户23、24年收入

输出字段：
1、直销客户编码，划小局向，划小营服，是否vip，对应的客户经理，对应的客户经理编码，23年税后确认收入，24年税后确认收入，收入增量
2、客户经理编码，客户经理名称，23年税后确认收入，24年税后确认收入，收入增量



--客户清单
drop table if exists zone_gz_yz.tmp_yz_XQGZ2025030301803_cust purge;
create table zone_gz_yz.tmp_yz_XQGZ2025030301803_cust
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select index1 as ccust_code,index2 as ccust_name,index3 as subst_name,index4 as branch_name,index5 as vip_flag_name, index6 as staff_name,index7 as staff_code
from zone_gz_yz_3542196629293056;
--43645

--客户经理清单
drop table if exists zone_gz_yz.tmp_yz_XQGZ2025030301803_staff purge;
create table zone_gz_yz.tmp_yz_XQGZ2025030301803_staff
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select index1 as staff_code,index2 as staff_name
from zone_gz_yz_3542196629293056;
--520




--取23、24年收入
drop table if exists zone_gz_yz.tmp_yz_XQGZ2025030301803_01_1 purge;
create table zone_gz_yz.tmp_yz_XQGZ2025030301803_01_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select cust_code
,sum(case when par_month_id>=202301 and par_month_id<=202312 then a0 else 0 end) as sr2023
,sum(case when par_month_id>=202401 and par_month_id<=202412 then a0 else 0 end) as sr2024
from dwm_srhx_serv_list_mon_final
where par_month_id>=202301 and par_month_id<=202412
group by cust_code;

drop table if exists zone_gz_yz.tmp_yz_XQGZ2025030301803_01 purge;
create table zone_gz_yz.tmp_yz_XQGZ2025030301803_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*,b.sr2023,b.sr2024
from tmp_yz_XQGZ2025030301803_cust a
left join tmp_yz_XQGZ2025030301803_01_1 b on a.ccust_code=b.cust_code;

select * from tmp_yz_XQGZ2025030301803_01;
select count(*) from tmp_yz_XQGZ2025030301803_01; --43645

select count(*) from tmp_yz_XQGZ2025030301803_01 where sr2023 is null and sr2024 is null; --7615
select count(*) from tmp_yz_XQGZ2025030301803_01 where sr2023 is not null and sr2024 is not null;--36030
select count(*) from tmp_yz_XQGZ2025030301803_01 where sr2023 is null and sr2024 is not null; --0
select count(*) from tmp_yz_XQGZ2025030301803_01 where sr2023 is not null and sr2024 is null; --0



drop table if exists zone_gz_yz.ads_yz_XQGZ2025030301803_cust purge;
create table zone_gz_yz.ads_yz_XQGZ2025030301803_cust
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select 200 as city_id,ccust_code,subst_name,branch_name,vip_flag_name,staff_name,staff_code,sr2023,sr2024,(sr2024-sr2023) as zl
from tmp_yz_XQGZ2025030301803_01;
select * from ads_yz_XQGZ2025030301803_cust;
select count(*) from ads_yz_XQGZ2025030301803_cust;--43645

--匹配客户经理
drop table if exists zone_gz_yz.tmp_yz_XQGZ2025030301803_02 purge;
create table zone_gz_yz.tmp_yz_XQGZ2025030301803_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*,b.sr2023,b.sr2024
from tmp_yz_XQGZ2025030301803_staff a
left join 
(select staff_code,sum(sr2023) as sr2023,sum(sr2024) as sr2024
from ads_yz_XQGZ2025030301803_cust
group by staff_code) b
on a.staff_code=b.staff_code;
select * from tmp_yz_XQGZ2025030301803_02;
select count(*) from tmp_yz_XQGZ2025030301803_02;--520


drop table if exists zone_gz_yz.ads_yz_XQGZ2025030301803_staff purge;
create table zone_gz_yz.ads_yz_XQGZ2025030301803_staff
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select 200 as city_id,staff_code,staff_name,sr2023,sr2024,(sr2024-sr2023) as zl
,case when sr2023<>0 and sr2023 is not null and sr2024 is not null then ((sr2024-sr2023)/sr2023) else null end as zzl
from tmp_yz_XQGZ2025030301803_02; --520