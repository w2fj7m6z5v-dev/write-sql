需求原始内容：
XQGZ2026051801366
根据审计要求，核查天翼云群子账号客户级折扣率，烦请提供2026年4月入网ACMB开头（云业务接入号）群子账号客户级折扣率及揽装人。揽装局向信息，谢谢。

需求梳理：
1.根据接入号开头ACMB提取新入网号码清单
2.客户级折扣率为号码属性，属性id：500049004

输出字段：
服务标识、接入号、揽装工号、揽装人、揽装局向、折扣率

--入网ACMB开头（云业务接入号）群子账号、揽装人、揽装局向信息

drop table tmp_XQGZ2026051801366_01;
create table tmp_XQGZ2026051801366_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as
select serv_id,acc_nbr,sales_code,sales_name,channel_subst_name
from dwm_yz_tb_comm_cm_all_final
where par_month_id=202604
and date_format(open_date,'yyyyMM')=202604
and is_new_user=1
and acc_nbr like('ACMB%');

--客户级折扣率
drop table tmp_XQGZ2026051801366_02;
create table tmp_XQGZ2026051801366_02 as
select a.*,b.attr_value1
from tmp_XQGZ2026051801366_01 a
left join (select serv_id,attr_value1 from iodata_ods_month_city.tb_pre_cm_attr_all_mon
			where par_month_id=202604
			and attr_id=500049004
			and par_corp_id='200') b on a.serv_id=b.serv_id;
			
--直接输出
select * from tmp_XQGZ2026051801366_02;