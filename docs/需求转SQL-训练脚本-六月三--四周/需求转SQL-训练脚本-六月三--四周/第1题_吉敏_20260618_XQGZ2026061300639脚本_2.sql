需求原始内容：XQGZ2026061300639
广州地铁集团有限公司，VPN群 010200152352 内公司名称及个人名称移动号码提取；因为客户经理无法了解每个移动号码套餐优惠到期时间，无法提前1-2个月为客户及时处理优惠续约，经常会有续约不成功优惠导致客户投诉，客户经理要单独再申请优惠并处理退费。客户感知差，客户经理工作量繁多。
为了有效避免以上事件频繁发生，申请导出VPN群 010200152352 内公司名称及个人名称移动号码，并提取对应的优惠标识到期时间。
请领导审批，谢谢。

需求梳理：
先根据VPN群号010200152352提取群内号码信息，再关联匹配优惠品到期信息

输出字段：
服务标识,号码,VPN群号,是否公司名,销售品编码,销售品名称,销售品生效时间,销售品失效时间


--根据VPN群号010200152352提取群内号码信息
drop table if exists tmp_yz_XQGZ2026061300639_list;
create table tmp_yz_XQGZ2026061300639_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select serv_id,acc_nbr,vpn_value,is_gsm
from dwm_yz_tb_comm_cm_all_final
where par_month_id=202606
and prod_type=30
and vpn_value='010200152352';


--通过serv_id关联匹配优惠品到期信息
drop table if exists ads_yz_XQGZ2026061300639_list;
create table ads_yz_XQGZ2026061300639_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select a.serv_id,a.acc_nbr,a.vpn_value,a.is_gsm,b.prod_offer_code,b.prod_offer_name,b.open_date,b.limit_date
from tmp_yz_XQGZ2026061300639_list a
left join
(
select serv_id,acc_nbr,prod_offer_code,prod_offer_name,create_date,open_date,limit_date
from ads_yz_rpt_comm_cm_msdisc_final
where par_month_id=202606
) b
on a.serv_id=b.serv_id
order by a.serv_id,b.prod_offer_code;



--输出结果
select serv_id,acc_nbr,vpn_value,is_gsm,prod_offer_code,prod_offer_name,open_date,limit_date
from ads_yz_XQGZ2026061300639_list