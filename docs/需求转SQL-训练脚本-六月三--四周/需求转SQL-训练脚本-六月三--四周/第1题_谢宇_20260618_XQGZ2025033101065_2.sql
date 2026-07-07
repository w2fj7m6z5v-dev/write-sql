
工单编号 XQGZ2025033101065 需求标题 根据附件清单，提供接入号对应：入网信息、装机信息 需求关键词 提供接入号对应：入网信息、装机信息 
提交人 王枫莹 提交人电话 15322268608, 提交部门 广东公司/市分公司/广州分公司/增城分公司/临-外部组织/临-销售部 
提交日期 2025-03-31 11:36:05 需求负责人  
  

需求内容   


涉及范围 分公司个性需求 是否影响客户感知 不影响 IT前向嵌入人员  
需求分类 套餐与营销活动支撑类需求(A类)-宽带多媒体类 要求独立测试报告 否 
首要系统 业务支持系统(BSS)-新一代 CRM3.0 工作总量 0 
相关系统 省网运系统-综合调度系统 系统模块  
期望完成时间 2025-04-01 00:00:00  计划完成时间  需求重要程度 低 
实现方式  实施紧急程度 一般 
退回原因  满意度  是否专项需求  
系统模块  影响用户数  影响单量  
业务风险  同类/历史工单单号  是否灰度验证测试  
系统类型  业务分类  
需求描述 根据附件已提供A列接入号清单，烦请提供接入号对应：入网揽装人、入网揽装机构、所属营服、装机师傅、所属部门（B-F列），详见附件清单字段，并按附件格式反馈相关信息，谢谢。 
需求目标 根据附件清单，提供接入号对应：入网信息、装机信息 


需求梳理：
按照附件提供的接入号，匹配号码当前信息

要求：
1、号码信息按照当前最新状态202504数据打标
2、对于已经拆机号码，号码信息按照号码拆机当月打标信息
3、号码存在多次拆机，多次复用的号码，按照号码最新一次拆机打标
4、号码是否移机以号码是否存在过移机订单为准，有历史移机订单即认为号码移机

输出字段：
接入号、揽装人编码、揽装人、归属销售点名称、网点所属营服、是否拆机、是否移机


--导入附件号码清单
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select index1 as acc_nbr
from zone_gz_yz_3542196629293056;


--按照当前最新妆台202504按照接入号打标当前未拆机号码的揽装人 入网揽装人归属销售点名称 入网揽装人所属营服
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.*
,b.serv_id,b.sales_code,b.sales_name,b.channel_name,b.channel_branch_name
from tmp_yz_xy_XQGZ2025033101065_01 a
left join (select acc_nbr,serv_id,sales_code,sales_name,channel_name,channel_branch_name from dwm_yz_tb_comm_cm_all_final where par_month_id=202504) b
on a.acc_nbr=b.acc_nbr; --5305

--筛选当前已经拆机的号码
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_1 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select acc_nbr
from  tmp_yz_xy_XQGZ2025033101065_02 where serv_id is null; --66

--从大宽表历史月找这些拆机号码拆机月份
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_2 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.acc_nbr,a.par_month_id 
from dwm_yz_tb_comm_cm_all_mon_final a 
left semi join tmp_yz_xy_XQGZ2025033101065_02_1 b
on a.acc_nbr=b.acc_nbr
where is_cancel_user=0;


--打标号码的最大拆机月份
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_3 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select acc_nbr,max(par_month_id) as zw_mon_max
from tmp_yz_xy_XQGZ2025033101065_02_2 
group by acc_nbr;


--关联拆机号码最大拆机月份打标号码信息
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_4 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.acc_nbr,b.serv_id,b.sales_code,b.sales_name,b.channel_name,b.channel_branch_name
from tmp_yz_xy_XQGZ2025033101065_02_3 a
left join (select acc_nbr,serv_id,sales_code,sales_name,channel_name,channel_branch_name,par_month_id from dwm_yz_tb_comm_cm_all_final) b
on a.acc_nbr=b.acc_nbr and a.zw_mon_max=b.par_month_id;


--当前未拆机号码打标拆机字段
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_final1 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_final1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select *, 0 as is_cj
from tmp_yz_xy_XQGZ2025033101065_02
where serv_id is not null; --5239


--拆机号码打标拆机字段
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_final2 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_final2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select *, 1 as is_cj
from tmp_yz_xy_XQGZ2025033101065_02_4; --66



--汇总拆机号码还有未拆机号码
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_final purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_02_final
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select * from tmp_yz_xy_XQGZ2025033101065_02_final1
union all 
select * from tmp_yz_xy_XQGZ2025033101065_02_final2;


--取有移机订单的号码
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_03 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select a.*,b.par_month_id,b.serv_id as serv_id2
from tmp_yz_xy_XQGZ2025033101065_02_final a
left join dwd_yz_rpt_comm_ba_subs_move_final b on a.serv_id=b.serv_id; --5355

--打标号码是否移机
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_04 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select *,
case when serv_id2 is null then 0 else 1 end as is_yj
from tmp_yz_xy_XQGZ2025033101065_03; --5355

--按照号码汇总是否移机
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_05 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_05
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select acc_nbr,serv_id,sales_code,sales_name,channel_name,channel_branch_name
,sum(is_yj) as is_yj
from tmp_yz_xy_XQGZ2025033101065_04
group by acc_nbr,serv_id,sales_code,sales_name,channel_name,channel_branch_name; --5305


--打标号码是否移机
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_06 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025033101065_06
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select acc_nbr,serv_id,sales_code,sales_name,channel_name,channel_branch_name
,case when is_yj >0 then '是' else '否' end as is_yj
from tmp_yz_xy_XQGZ2025033101065_05;


drop table if exists zone_gz_yz.ads_yz_xy_XQGZ2025033101065 purge;
create table zone_gz_yz.ads_yz_xy_XQGZ2025033101065
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as
select * from tmp_yz_xy_XQGZ2025033101065_06;



drop view if exists zone_gz.view_ads_yz_xy_XQGZ2025033101065;
create view if not exists zone_gz.view_ads_yz_xy_XQGZ2025033101065
(
acc_nbr               comment '接入号'
,sales_code             comment '揽装人编码'
,sales_name                  comment '揽装人'
,channel_name                  comment '归属销售点名称'
,channel_branch_name              comment '网点所属营服'
,is_cj                  comment '是否拆机'
,is_yj                comment '是否移机'

)
as
select
acc_nbr              
,sales_code             
,sales_name                  
,channel_name                  
,channel_branch_name              
,is_cj                  
,is_yj                
from zone_gz_yz.ads_yz_xy_XQGZ2025033101065;



