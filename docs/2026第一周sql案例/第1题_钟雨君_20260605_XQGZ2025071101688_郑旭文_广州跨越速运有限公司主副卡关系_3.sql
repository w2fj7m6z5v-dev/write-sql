/*工单编号 XQGZ2025071101688 需求标题 广州跨越速运有限公司主副卡关系 需求关键词 主副卡关系 
提交人 郑旭文 提交人电话 13318803992, 提交部门 广东公司/市分公司/广州分公司/黄埔分公司/黄埔互联网BU营销服务中心 
提交日期 2025-07-11 16:40:54 需求负责人 
需求描述 为梳理业务信息，需要整理主副卡关系，现提供附件，内容为副卡号码，需要梳理对应的主卡信息。请协助处理，谢谢！ 
需求目标 主副卡关系 
*/

需求梳理：已知副卡号码，需要匹配主卡号码

输出字段：序号，副卡号码，主卡号码

-- 从大宽表直接提取附件号码对应的主卡号码
drop table if exists ads_XQGZ2025071101688;
create table ads_XQGZ2025071101688 as 
select cast(a.index1 as int) xuhao,a.index2 as fk_acc_nbr,b.zk_acc_nbr
from zone_gz_yz_3542197512722432 a 
left join dwm_yz_tb_comm_cm_all_final b on cast(a.index2 as varchar(96)) = b.acc_nbr and b.par_month_id = 202507 and b.prod_type = 30
order by xuhao;

-- 检查数量是否与附件号码数量一致
select * from ads_XQGZ2025071101688 limit 1000;
select count(1) from ads_XQGZ2025071101688; -- 2143，一致