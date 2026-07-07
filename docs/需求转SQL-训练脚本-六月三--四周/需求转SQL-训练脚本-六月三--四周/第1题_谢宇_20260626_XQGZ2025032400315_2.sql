
工单编号 XQGZ2025032400315 需求标题 提取25年2月网格单元宽带数 需求关键词 提取25年2月网格单元宽带数 
提交人 潘莉莉 提交人电话 18022876566, 提交部门 广州分公司/客户服务部/临-外部组织/临-服务质控团队 
提交日期 2025-03-24 09:55:25 需求负责人  归档时间  
     

需求内容   


涉及范围 分公司个性需求 需求分类 套餐与营销活动支撑类需求(A类)-宽带多媒体类 需求重要程度 低 
首要系统 业务支持系统(BSS)-新一代 CRM3.0 相关系统  实施紧急程度 一般 
IT前向嵌入人员  要求独立测试报告 否 工作总量  
期望完成时间 2025-03-25 计划完成时间  是否影响客户感知 不影响 
实现方式  满意度  满意度评价  
退回原因  是否专项需求  所属项目  
系统模块  影响用户数  影响单量  
业务风险  同类/历史工单单号 XQGZ2025022501097 是否灰度验证测试  
系统类型  业务分类  

需求描述 由于数据分析需要，现提需求提取2025年2月各网格单元网格编码（具体网格单元请详见附件）如下数据：
1、2025年2月各网格单元编码的宽带结算到达数
2、2025年2月各网格单元编码的新装入网的宽带数
3、2025年2月各网格单元编码的移机进入宽带数（指移机迁入对应网格单元的宽带数）
4、2025年2月各网格单元编码的拆机宽带数
【可参考历史需求：工单编号 XQGZ2025022501097】 
需求目标 提取25年2月网格单元宽带数 


需求梳理：按照附件提供的网格清单（网格编码，网格名称）匹配网格202502的宽到达数据，宽带新入网数据、宽带移入数据、宽带拆机数据
要求：
1、要求统计的是主宽数据，移机清单没有字段可以判断主宽，需要关联大宽表打标判断
2、移机数据只要移入数据，因此以本月网格编码cell_code来汇总数据
输出字段：网格编码，网格名称，202502宽带到达，202502宽带入网，202502宽带拆机，202502宽带移入

--网格清单关联全业务资料表统计网格宽带到达，入网，拆机数据
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025032400315_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025032400315_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.index1 as cell_code,a.index2 as cell_name,b.kd_dd,b.kd_rw,b.kd_cj
from zone_gz_yz_3542196629293056 a
left join (
select cell_code,
count(case when par_month_id=202502 and is_cancel_user=0 and is_cz=1 then serv_id else null end) as kd_dd,
count(case when par_month_id=202502 and is_new_user=1 then serv_id else null end) as kd_rw,
count(case when par_month_id=202502 and is_cancel_user=1 then serv_id else null end) as kd_cj
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id=202502
and prod_type=40
and kd_desc='普通宽带'
group by cell_code) b
on a.index1=b.cell_code; --14064


--移机订单表关联大宽表取主宽移机记录
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025032400315_02 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025032400315_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.par_month_id,a.acc_nbr,a.serv_id,a.cell_code,a.cell_code_last
from dwd_yz_rpt_comm_ba_subs_move_final a
join dwm_yz_tb_comm_cm_all_mon_final b
on a.par_month_id=b.par_month_id and a.serv_id=b.serv_id and b.prod_type=40 and b.kd_desc='普通宽带'
where a.par_month_id=202502;



--统计移入数据
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025032400315_03 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025032400315_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*,b.kd_yj
from tmp_yz_xy_XQGZ2025032400315_01 a
left join 
(select 
cell_code
,count(distinct case when par_month_id=202502 and cell_code<>cell_code_last then serv_id else null end ) as kd_yj
from tmp_yz_xy_XQGZ2025032400315_02
group by cell_code
) b
on a.cell_code=b.cell_code;--14064




drop table if exists zone_gz_yz.ads_yz_xy_XQGZ2025032400315 purge;
create table zone_gz_yz.ads_yz_xy_XQGZ2025032400315
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select * from tmp_yz_xy_XQGZ2025032400315_03;


----建立视图
drop view if exists zone_gz.view_ads_yz_xy_XQGZ2025032400315;
create view if not exists zone_gz.view_ads_yz_xy_XQGZ2025032400315
(
cell_code              comment '网格编码'
,cell_name             comment '网格'
,kd_dd                  comment '宽带到达'
,kd_rw                  comment '宽带入网'
,kd_cj               comment '宽带拆机'
,kd_yj              comment '宽带移机'


)
as
select
cell_code              
,cell_name             
,kd_dd                  
,kd_rw                  
,kd_cj
,kd_yj              
from zone_gz_yz.ads_yz_xy_XQGZ2025032400315;