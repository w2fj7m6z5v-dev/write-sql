工单编号	XQGZ2025080702209	需求标题	申请提取长兴营服收编商的主宽数清单明细	需求关键词	提取清单明细
提交人	杨毅	提交人电话	18928878051,	提交部门	广东公司/市分公司/广州分公司/天河分公司/天河长兴城中村营销服务中心
提交日期	2025-08-07 17:15:10	需求负责人	
需求内容
涉及范围	分公司个性需求	是否影响客户感知	不影响	IT前向嵌入人员	
需求分类	套餐与营销活动支撑类需求(A类)-宽带多媒体类	要求独立测试报告	否
首要系统	业务支持系统(BSS)-客户关系管理系统-CRM门户	工作总量	0
相关系统		系统模块	
期望完成时间	2025-08-08 00:00:00	计划完成时间		需求重要程度	低
实现方式		实施紧急程度	一般
退回原因		满意度		是否专项需求	
系统模块		影响用户数		影响单量	
业务风险		同类/历史工单单号		是否灰度验证测试	
系统类型		业务分类	
需求描述	网格编码：200031013436285，网格名称：凌塘村
网格编码：200031013436287，网格名称：沐陂村
合同编码：GDGZA2501730CGN00

因凌塘村和沐陂村签订共用一份收编商合同，年底需拆分开2条村重新上合同，现申请提取具体到网格的出账主宽数及金额，需提取内容为：各个网格对应账期的出账主宽数、出账金额、202501-202506账期数据。请业支协助处理，谢谢

1、出账金额 是指 税后确认收入 还是 出账收入公允后？
2、出账金额 是指 整个网格的收入还是只要出账主宽这部分的收入？
3、出账主宽数--这个是只要出账就可以了是么 不是统计到达？

1.税后
2.出账主宽
3.出账主宽

需求梳理：根据提供的网格编码（'200031013436285','200031013436287'）统计网格的主宽到达跟收入数据
要求：
1、经沟通，收入是取税后确认收入不是出账收入
2、收入范围不是整个网格的，而是只有出账主宽的号码收入
3、出账主宽指的是主宽号码出账即可，不是到达口径
输出字段：统计月份，网格编码，出账主宽数，出账主宽税后确认收入

--从全业务资料表限制网格编码取网格2501-2506的所有宽带号码清单及其拆机，出账，出账收入，税后确认收入数据
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025080702209_01 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025080702209_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select par_month_id,serv_id,acc_nbr,cell_code,cell_name,is_cancel_user,is_cz,fee,fee_new_tax,kd_desc
from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id>=202501 and par_month_id<=202506
and prod_type=40
and  cell_code in ('200031013436285','200031013436287'); --29902


--按照月份，网格纬度汇总出账主宽号码数，出账主宽的税后确认收入
drop table if exists zone_gz_yz.tmp_yz_xy_XQGZ2025080702209_02 purge;
create table zone_gz_yz.tmp_yz_xy_XQGZ2025080702209_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select par_month_id,cell_code,cell_name
,count(case when kd_desc='普通宽带' and is_cz=1 then serv_id else null end) as cz_zk_nums
,sum(case when kd_desc='普通宽带' and is_cz=1 then  fee_new_tax else 0 end) as cz_zk_sr
from tmp_yz_xy_XQGZ2025080702209_01
group by par_month_id,cell_code,cell_name;