一、XQGZ2026061501763
易方达基金管理有限公司，接入号DOS-GD-YFDJJGL-260227-00280，该业务于2026年2月竣工，3月份有收到2月产数积分，
并发放奖励（邮件公示数据，客户经理841未看到），3月和4月5月份未发放产数积分，申请补发。

注：激励积分=当月出账金额30000.0/12*导向系数3，连续发放12个月。

1、查询积分结果表 
select * from ads_yz_score_all_list 
where par_month_id>='202602'
and acc_nbr='DOS-GD-YFDJJGL-260227-00280'
order by par_month_id

2、看jz_points,jz_points_desc,jl_points,jl_points_desc这几个字段，发现 
jl_points_desc已说明是由于号码欠停拆导致激励积分为0 

3、回复
经查询，号码在202603-202605月由于号码欠费导致激励积分为0，3个月内号码回复正常状态系统会 
自动补发积分。


二、XQGZ2026061101768
接入号：ADSLS2614615101，客户名称：广州喜马拉雅战略咨询有限公司
受理及竣工时间：2026年4月，月租：800元
接入号ADSLS2614615101在2026年4月办理新装极速专线融合套餐业务，月租为800元，按市公司激励积分规则，
T1激励系数应按月租乘3.2T+1发放50%（800*3.2/0.5=1280），而清单内没有显示该激励，请领导与业支部门协助核查并按发文规则补发合计1280的激励，谢谢！
附件已附上系统完工截图	

1、查询积分结果表 
select *
from ads_yz_score_all_list 
where par_month_id>='202604'
and acc_nbr='ADSLS2614615101'
order by par_month_id

2、没有积分，查询对应的宽带和移动号码积分情况

select *
from ads_yz_score_all_list 
where par_month_id>='202604'
and acc_nbr in ('ADSLS2614615101','18028526851','ADSLD2105512531')
order by par_month_id

3、发现宽带号码有一条prod_name2='依案提值'的积分记录，查询表zone_gz_sy.dwd_sy_bhy_yhya_XQGZ2025102702269_list
是否有记录，
set hive.fetch.task.conversion=none;
select * from zone_gz_sy.dwd_sy_bhy_yhya_XQGZ2025102702269_list
where par_ya_month='202604'
and acc_nbr='ADSLS2614615101'

有记录，说明专线号码的积分包含在宽带号码的依案提值积分中，不会单独再出新装积分。

4、回复需求单 
经查询，专线号码ADSLS2614615101的积分包含在宽带号码ADSLD2105512531的提值积分中，根据积分规则，不会再单独出新装积分。


XQGZ2026061200674	
1、接入号：18024041578
积分解释：非礼包129及以上，激励积分2倍套餐主体积分=2*169=338
实际情况：客户该号码为新装融合269，由于客户3月10日不愿交物业的上楼费，要求客户经理撤单，但手机号码已竣工，后
经过物业协调，客户交齐上楼费后，客户经理又申请开通宽带重新下单，宽带已当月内竣工，但导致手机号码跟宽带分别记奖励，
主卡奖励30，宽带部分奖励338元，现申请该号码套餐按照新装269奖励，且主卡活跃，按照269*3.5=941.5,应发941.5元，
现只发368元，需补603.5元（附件主卡T+3活跃截图）
2、接入号：19068596461
积分解释：非礼包129及以上，激励积分2倍套餐主体积分=2*229=458
实际情况：客户该号码为新装融合269，应按照3.5倍发奖励，应发269*3.5=941.5元
3、接入号：ADSLD12606710
积分解释：无该号码
实际情况：202604受理拆挽，未奖励，按照发文应发1倍奖励，199元

1、查询积分结果表（查询每个号码业务竣工时间后的积分情况）
select *
from ads_yz_score_all_list 
where par_month_id>='202603'
and acc_nbr='18024041578'
order by par_month_id

select *
from ads_yz_score_all_list 
where par_month_id>='202605'
and acc_nbr='19068596461'
order by par_month_id


select *
from ads_yz_score_all_list 
where par_month_id>='202604'
and acc_nbr in ('ADSLD12606710')
and prod_name2='拆机挽留'
order by par_month_id

2、查询后，发现号码18024041578和19068596461按照非礼包出了积分(prod_name2='融合',prod_name3='非重点产品',prod_name5='非礼包'),
号码ADSLD12606710在202604月清单已正常出了拆机挽留积分

3、回复需求单，转销售部是审批 
经查询，号码ADSLD12606710已在202604月正常出了拆机挽留积分，无需补发,
号码18024041578和19068596461按照非礼包出了积分，请转销售部审批是否按照269重点礼包规则(269*3.5)补发积分,谢谢！

