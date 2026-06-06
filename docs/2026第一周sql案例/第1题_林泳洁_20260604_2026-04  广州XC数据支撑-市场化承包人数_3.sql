/*
需求单号：XQGZ2026041001883
需求描述：因XC资料提取要求，现需按附件清单提取对应合同在指定月份的实际工号数量，请业支协助处理，谢谢

需求拆解：
1、根据附件提供的2021年12月-2025年11月的网点，匹配网点下销售人员信息
2、只统计目前状态为‘有效’的销售人员

输出字段：合同编码、合同名字、账期、网点编码、网点名称、销售人员名字、销售编码、揽装编号、销售员岗、销售员身份证号（脱敏）
*/



---1.取合同和网点
drop table if exists tmp_yz_xc_schcbr_channel_list_20260414;
create table tmp_yz_xc_schcbr_channel_list_20260414 as 
select distinct 
contractno --合同编码
,contract_name--合同名字
,billing_cycle_id --账期
,channel_id -- 网点ID
,channel_code -- 网点编码
from dws_tpss_jszx.dws_settle_bill 
where shard=200  
and  billing_cycle_id>=20211201  and billing_cycle_id<=20251101;


--2.取销售人员信息
drop table if exists tmp_yz_xc_schcbr_salesman_list_20260414;
create table tmp_yz_xc_schcbr_salesman_list_20260414 as 
select 
a.contractno --合同编码
,a.contract_name
,a.billing_cycle_id --账期
,b.channel_nbr --网点编码
,b.channel_name
,c.sales_man_name
,c.sales_code--揽装人编码
,c.sales_man_nbr--销售员编码
,c.sales_man_post_desc--销售员岗位
,CONCAT(SUBSTR(c.cert_no, 1, 6), REPEAT('*', LENGTH(c.cert_no) - 10), SUBSTR(c.cert_no, LENGTH(c.cert_no) - 3, 4)) as cert_no_tm--身份证
from tmp_yz_xc_schcbr_channel_list_20260414 a
left join dwd_yz_sale_outlers_mon_final b on a.channel_id=b.channel_id and substr(a.billing_cycle_id,1,6)=b.par_month_id
left join dwd_yz_sales_man_mon_final c on b.channel_id=c.own_channel_id and b.par_month_id=c.par_month_id and c.status_cd='S0A'
where a.contractno in (select index1 from zone_gz_yz_3410850391529472);

--3.输出最终结果，做中英文逗号的转换
drop table if exists ads_yz_xc_schcbr_salesman_list_20260414;
create table ads_yz_xc_schcbr_salesman_list_20260414 as 
select 
replace(contractno,',','，') contractno,
replace(contract_name,',','，') contract_name,
replace(billing_cycle_id,',','，') billing_cycle_id,
replace(channel_nbr,',','，') channel_nbr,
replace(channel_name,',','，') channel_name,
replace(sales_man_name,',','，') sales_man_name,
replace(sales_code,',','，') sales_code,
replace(sales_man_nbr,',','，') sales_man_nbr,
replace(sales_man_post_desc,',','，') sales_man_post_desc,
replace(cert_no_tm,',','，') cert_no_tm
from tmp_yz_xc_schcbr_salesman_list_20260414;




