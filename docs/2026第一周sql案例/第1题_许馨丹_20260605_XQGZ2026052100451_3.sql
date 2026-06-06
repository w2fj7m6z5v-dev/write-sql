工单编号	XQGZ2026052100451	需求标题	盘点临街商铺地址入网的需求	需求关键词	临街商铺地址入网
提交人	陈展鹏	提交人电话	18102806093,	提交部门	广州分公司/商业客户拓展中心/楼宇园区团队
提交日期	2026-05-21 10:31:59	需求负责人		归档时间	
需求内容
涉及范围	分公司个性需求	需求分类	业务数据处理类需求(E类)-业务数据修正	需求重要程度	低
首要系统	数据架构平台(EDA)-企业全融合数字化平台-企业全融合数字化平台(CDAP)	相关系统		实施紧急程度	一般
IT前向嵌入人员		要求独立测试报告	否	工作总量	
期望完成时间	2026-05-22	计划完成时间		是否影响客户感知	不影响
实现方式		满意度		满意度评价	
退回原因		是否专项需求		所属项目	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	因业务分析需要，需统计5级地址下对应的落地分局和落地营服的临街商铺主宽入网，剔除酒宽，时间节点：25年1月-26年4月，入网数据每月分开
前期与业支许馨丹沟通，请将工单转派许馨丹处理
需求目标	临街商铺地址入网

需求梳理：
1.提取25年1月-26年4月主流宽带（剔除酒宽）标准装机地址在临街商铺地址的新入网号码，临街商铺地址使用维表dwd_yz_dim_ljsp_addr
2.地址表可以直接取到10级地址id对应的6级地址id，再通过6级地址id取上级id即为5级
3.落地局向、落地营服直接取号码信息

--从宽带新装清单提取202501-202604临街商铺新入网号码，剔除酒宽
drop table tmp_XQGZ2026052100451;
create table tmp_XQGZ2026052100451
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select par_month_id,serv_id,acc_nbr,std_subst_name,std_branch_name,a.serv_addr_id
from ads_yz_kd_new_list a
join dwd_yz_dim_ljsp_addr b on cast(a.serv_addr_id as decimal(24,0))=cast(b.serv_addr_id as decimal(24,0))
where a.par_month_id between 202501 and 202604
and kd_desc='普通宽带'
and prod_type3<>'酒店宽带'
;

--取装机地址对应6级地址id及6级地址id的上级id（5级）
drop table tmp_XQGZ2026052100451_1;
create table tmp_XQGZ2026052100451_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,b.addr_id_6,c.parentid,c.grade
from tmp_XQGZ2026052100451 a
left join dwd_yz_addr_final b on cast(a.serv_addr_id as decimal(24,0))=cast(b.id as decimal(24,0))
left join dwd_yz_addr_final c on cast(b.addr_id_6 as decimal(24,0))=cast(c.id as decimal(24,0))
;

--翻译5级地址
drop table tmp_XQGZ2026052100451_2;
create table tmp_XQGZ2026052100451_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select a.*,b.addr
from tmp_XQGZ2026052100451_1 a
left join dwd_yz_addr_final b on cast(a.parentid as decimal(24,0))=cast(b.id as decimal(24,0))
;

--统计5级地址、落地局向、落地营服下各个月的宽带入网量
drop table tmp_XQGZ2026052100451_3;
create table tmp_XQGZ2026052100451_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select parentid addr_id_5,addr addr_id_5_name,std_subst_name,std_branch_name,par_month_id,count(distinct serv_id) cnt
from tmp_XQGZ2026052100451_2
group by parentid,addr,std_subst_name,std_branch_name,par_month_id
;

--将每月入网数据打横展示
drop table tmp_XQGZ2026052100451_4;
create table tmp_XQGZ2026052100451_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select addr_id_5,addr_id_5_name,std_subst_name,std_branch_name,
str_to_map(concat_ws(',',collect_set(concat_ws('=',cast(par_month_id as string),cast(cnt as string)))),',','=') map_col
from tmp_XQGZ2026052100451_3    
group by addr_id_5,addr_id_5_name,std_subst_name,std_branch_name
;

drop table tmp_XQGZ2026052100451_5;
create table tmp_XQGZ2026052100451_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select addr_id_5,addr_id_5_name,std_subst_name,std_branch_name,
coalesce(map_col[\"202501\"],0) rw_202501,
coalesce(map_col[\"202502\"],0) rw_202502,
coalesce(map_col[\"202503\"],0) rw_202503,
coalesce(map_col[\"202504\"],0) rw_202504,
coalesce(map_col[\"202505\"],0) rw_202505,
coalesce(map_col[\"202506\"],0) rw_202506,
coalesce(map_col[\"202507\"],0) rw_202507,
coalesce(map_col[\"202508\"],0) rw_202508,
coalesce(map_col[\"202509\"],0) rw_202509,
coalesce(map_col[\"202510\"],0) rw_202510,
coalesce(map_col[\"202511\"],0) rw_202511,
coalesce(map_col[\"202512\"],0) rw_202512,
coalesce(map_col[\"202601\"],0) rw_202601,
coalesce(map_col[\"202602\"],0) rw_202602,
coalesce(map_col[\"202603\"],0) rw_202603,
coalesce(map_col[\"202604\"],0) rw_202604
from tmp_XQGZ2026052100451_4
;

--输出
drop table ads_yz_XQGZ2026052100451;
create table ads_yz_XQGZ2026052100451
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select * from tmp_XQGZ2026052100451_5
;