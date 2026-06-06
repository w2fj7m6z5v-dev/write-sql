/*工单编号 XQGZ2026032501406 需求标题 关于广州市越秀区人民政府黄花岗街道办事处核查固话使用记录 需求关键词 核查固话使用记录 
提交人 刘颖妍 提交人电话 18928911968, 提交部门 广东公司/市分公司/广州分公司/越秀分公司/临-外部组织/临-越秀数字政务BU营销服务中心 
提交日期 2026-03-25 15:12:24 需求负责人 
需求描述 客户：广州市越秀区人民政府黄花岗街道办事处 为我司名单制客户，因客户内部稽查需对没有使用的固话进行清理，申请核查清单内的固话号码在2025年12月-2026年3月25日的使用记录，烦请协助处理，谢谢。 
需求目标 核查固话使用记录 
*/

需求梳理：提取清单内的固话号码在2025年12月-2026年3月25日的使用时长

输出字段：序号，统计月份，号码，使用时长


-- 从固话清单抽取圈定月份的号码和使用记录
drop table if exists tmp_yz_zyj_0409;
create table tmp_yz_zyj_0409 as 
select par_month_id,serv_id,acc_nbr,dur
from summary_ods_month_city.tb_comm_ywl_gw_mon where par_corp_id='200' and par_month_id between 202512 and 202603;

-- 匹配附件号码的使用记录
drop table tmp_XQGZ2026032501406_gh;
create table tmp_XQGZ2026032501406_gh row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select par_month_id,serv_id,acc_nbr,dur/60 dur
from tmp_yz_zyj_0409 a
where exists(select index2 from zone_gz_yz_3542197512722432 b where 
cast(a.acc_nbr as varchar(96))=cast(b.index2 as varchar(96)))
;

-- 检查
select * from tmp_XQGZ2026032501406_gh; -- 14>0，能查到有使用记录的号码


-- 导入号码,贴结果
drop table if exists ads_XQGZ2026032501406;
create table ads_XQGZ2026032501406 row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression' = 'snappy')
as
select cast(a.index1 as int) xuhao,c.par_month_id,
(case when length(a.index2)<2 then '*'
when length(a.index2)=2 then concat(SUBSTR(a.index2,1,1),'*')
when length(a.index2)<8 then concat(SUBSTR(a.index2,1,(length(a.index2)-2)),'**')
when length(a.index2)>=8 then concat(SUBSTR(a.index2,1,length(a.index2)-8),'****',SUBSTR(a.index2,length(a.index2)-3,length(a.index2)))
else '*' end) as  acc_nbr,c.dur
from zone_gz_yz_3542197512722432 a 
left join tmp_XQGZ2026032501406_gh c on cast(a.index2 as varchar(96))=cast(c.acc_nbr as varchar(96)) and c.acc_nbr is not null 
order by xuhao,c.par_month_id;

-- 检查
select * from ads_XQGZ2026032501406 limit 1000 -- 583