
一、XQGZ2026052900555	
客户名称：广东威力铭科技有限公司，接入号：ACMB8440100005628028，2026年4月受理了55894.77云业务，
账单已缴费，应补发当月出账金额55894.77元/12*导向系数3=13973.5激励。
CRM缴费截图附件已附，备注:该业务为4月办理，请核查补发，谢谢。

1、查询积分结果表 
select * from ads_yz_score_all_list 
where par_month_id>='202511'
and acc_nbr='ACMB8440100005628028'
order by par_month_id

jz_points_desc字段显示,202605月份存在出账收入为55894.77的积分记录

2、回复 
经查询，该号码在202605月份已经出了出账收入为55894.77的积分,无需再补发。

二、XQGZ2026052900256	
客户：广州市番禺区南粤医院（有限合伙），接入号：ADSLS2594932737、ADSLS2597345720，
本次极速专线续约为三年协议期，但实际发放按照两年协议期执行，申请将一年的协议期差价进行补发，
请相关部门协助处理，谢谢！

1、查询积分结果表
select * from ads_yz_score_all_list 
where par_month_id>='202604'
and acc_nbr in ('ADSLS2594932737','ADSLS2597345720')
order by par_month_id

jl_points字段显示两个号码都有激励积分，且按照2年系数发放，需求方申诉应按照3年 

2、查询优惠资料表

select par_month_id,acc_nbr,open_date,limit_date,create_date,prod_offer_id,msobjgrp_id
from dwd_yz_rpt_comm_cm_msdisc_mon_final
where par_month_id>='202601'
and  acc_nbr='ADSLS2594932737'
order by par_month_id;

号码ADSLS2594932737在202604月续约，202603月limit_date为2026-05-01，202604月limit_date为2029-04-01，
续约合同年限计算公式为最新协议到期时间-上一期协议到期时间=2029-04-01-2026-05-01<36个月，因此系统按照2年系数计算积分。

select par_month_id,acc_nbr,open_date,limit_date,create_date,prod_offer_id,msobjgrp_id
from dwd_yz_rpt_comm_cm_msdisc_mon_final
where par_month_id>='202601'
and  acc_nbr='ADSLS2597345720'
order by par_month_id;

号码ADSLS2597345720在202604月续约，prod_offer_id=100054700,202603月limit_date为2026-08-01，202604月limit_date为2029-04-01，
续约合同年限计算公式为最新协议到期时间-上一期协议到期时间=2029-04-01-2026-08-01<36个月，因此系统按照2年系数计算积分。

3、回复 
经查询,号码ADSLS2594932737和ADSLS2597345720的旧协议到期时间分别为2026-05-01和2026-08-01，202604月提前续约的销售品 
到期时间为2029-04-01，根据积分规则，续约合同年限计算公式=最新协议到期时间-上一期协议到期时间，系统计算得两个号码的 
续约时长均小于36个月，因此按照2年系数计算积分，请转销售部审批是否按照3年系数补发激励积分，谢谢！


三、XQGZ2026060501519	
接入号：ADSLS2614995974，客户名称：广州新世纪国际旅行社有限公司
受理及竣工时间：2026年4月，月租：400元，协议期：36个月
按市公司激励积分规则，极速专线：400元及以上按2倍价值激励（T+1、T+3各放50%），T+1发放激励（400*2*0.5=400），4月账期清单内没有显示该激励，
请领导与业支部门协助核查并按发文规则补发T+1激励400元，谢谢！
揽装人：陈杰中，揽装工号：05060024，揽装人编码：Y44010466900
附件已附上CRM截图。

1、找到专线号码对应的移动宽带号码,查询积分结果表
select * from ads_yz_score_all_list 
where par_month_id>='202604'
and acc_nbr in ('ADSLS2614995974','18924173976','ADSLD2144396878')
order by par_month_id

宽带号码存在prod_name3='依案提值'的记录

2、查询表zone_gz_sy.dwd_sy_bhy_yhya_XQGZ2025102702269_list

select * from 
zone_gz_sy.dwd_sy_bhy_yhya_XQGZ2025102702269_list
where par_ya_month='202604'
and acc_nbr='ADSLS2614995974'

表中zone_gz_sy.dwd_sy_bhy_yhya_XQGZ2025102702269_list有专线号码，说明专线号码积分包含在宽带号码的已案提值积分中，不再单独出积分。

3、回复 
经查询，该专线所属融合为依案提值，专线积分包含在宽带号码（ADSLD2144396878）的提值积分中，不再单独出积分。






