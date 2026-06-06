/*工单编号 XQGZ2026052101801 需求标题 关于提取快捷宽带7级地址ID的需求 需求关键词 提取快捷宽带7级地址ID 
提交人 吴岱颖 提交人电话 18922136068, 提交部门 广东公司/市分公司/广州分公司/荔湾分公司/销售部 
提交日期 2026-05-21 16:53:12 需求负责人 
需求描述 因分析快捷宽带分成需要，申请提取附件清单号码对应的7级地址ID，事先已沟通，请转业支数据室处理，谢谢 
需求目标 提取快捷宽带7级地址ID 
*/

需求梳理：提取附件清单号码对应的7级地址ID

输出字段：序号，7级地址ID

-- 从大宽表提取附件号码的地址id
drop table if exists  tmp_XQGZ2026052101801_01_new purge;
create table tmp_XQGZ2026052101801_01_new
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as select cast(b.index1 as int) xuhao,b.index2 as acc_nbr,a.serv_id,a.serv_addr_id 
from dwm_yz_tb_comm_cm_all_final a 
join zone_gz_yz_3542197512722432 b on a.acc_nbr = b.index2
where a.par_month_id = 202605
group by b.index1,b.index2,a.serv_id,a.serv_addr_id;

-- 检查数量是否与附件号码数量一致
select * from tmp_XQGZ2026052101801_01_new;
select count(1) from tmp_XQGZ2026052101801_01_new; -- 3348，一致

-- 匹配七级地址id
drop table if exists  ads_XQGZ2026052101801 purge;
create table ads_XQGZ2026052101801
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as select a.*,b.addr_id_7 as serv_addr_7 --7级地址id
        from tmp_XQGZ2026052101801_01_new a  
        left join (select distinct id,addr,addr_id_7 from zone_gz_yz.dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id
		order by a.xuhao;

-- 创建广州专区视图
create view view_ads_XQGZ2026052101801 as select xuhao,serv_addr_7 from zone_gz_yz.ads_XQGZ2026052101801 order by xuhao;

-- 检查数量是否与附件号码数量一致
select * from view_ads_XQGZ2026052101801;
select count(1) from view_ads_XQGZ2026052101801; -- 3348