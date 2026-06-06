需求原始内容：
XQGZ2026051401500
为进一步推动电子渠道宽带规模增长，落实“电信到家”专项政策要求，鼓励合作商加大“电信到家”商机投放，前期已通过需求单
（XQGZ2026040100202）实现佣金配置，现申请对电子渠道合作商2026年4月电信到家佣金提数，以便导入台账，
后续5-12月出账以此需求单为依据出数。




需求梳理：
限制附件提供网点，提取电信到家专项业务价值积分，激励积分数据。经过与需求方沟通，需要输出字段
号码，网点，积分类型4，价值积分，价值积分描述，激励积分，激励积分描述。

输出字段：
号码，网点，积分类型4，价值积分，价值积分描述，激励积分，激励积分描述。




--  从积分清单提取 电信到家 业务，限制附件提供的 网点
  drop table if exists tmp_yz_XQGZ2026051401500_list1;
 create table tmp_yz_XQGZ2026051401500_list1 as
 select par_month_id,serv_id,acc_nbr,channel_nbr, channel_id, channel_name, prod_name4, jl_points,jl_points_desc from
 ads_yz_score_all_list where par_month_id=202602 and prod_name4='电信到家' and channel_nbr 
 in 
 (
'4401002055631','4401002321426','4401002517790','4401122097995','4401002119840','4401002995891','4401002997903',
'4401002444075','4401122754553','4401122191278','4401002351759','4401002355789','4401002352283','4401002736182',
'4401002295287','4401002733255','4401002356015','4401002446822','4401002728970','4401002760069','4401002759693',
'4401002759691','4401122949492','4401002790695','4401002703658','4401002779452','4401002788539','4401002797329',
'4401002715836','4401002714358','4401002711352','4401002715919','4401002702829')
 ;
 
 

 -- 从融合礼包积分表匹配号码价值积分
 drop table if exists tmp_yz_XQGZ2026051401500_list2;
 create table tmp_yz_XQGZ2026051401500_list2 as 
 select a.*, b.jz_points from tmp_yz_XQGZ2026051401500_list1 a 
 left join (select yd_acc_nbr,jz_points,jz_points_desc,jl_points,jl_points_desc 
			from ads_yz_score_rhlb_list where par_month_id = 202602 and yd_acc_nbr in 
 ( select acc_nbr from tmp_yz_XQGZ2026051401500_list1 ) and jz_points<>0 ) b 
 on a.acc_nbr = b.yd_acc_nbr; -- 使用移动号码关联
 



-- 生成结果表
  alter table ads_yz_XQGZ2025111700706_jf_list 
 drop if exists partition(par_month_id = '202602');
 insert into table ads_yz_XQGZ2025111700706_jf_list partition(par_month_id = '202602')
 (serv_id, acc_nbr,channel_nbr,channel_id,channel_name,prod_name4,jz_points,jl_points,jl_points_desc)
 select serv_id, acc_nbr,channel_nbr,channel_id,channel_name,prod_name4,jz_points,jl_points,jl_points_desc 
 from tmp_yz_XQGZ2026051401500_list2;



-- 输出字段
select serv_id, acc_nbr,channel_nbr,channel_id,channel_name,prod_name4,jz_points,jl_points,jl_points_desc
from ads_yz_XQGZ2025111700706_jf_list where par_month_id = '月份'


