需求原始内容：
XQGZ2025040300731

匹配客户经理CRM编码。因业务派单需客户经理11开头CRM编码，请协助匹配，清单见附件。

需求梳理：
通过需求方提供的号码级清单，匹配号码揽装人的揽装人编码，再通过揽装人编码匹配出揽装人工号信息。

要求：
1.需求方提供的号码级清单中有揽装人编码，但是以防万一揽装人有更新，所以重新匹配揽装人信息；
2.电信员工表dws_crm_cfguse.dws_staff中可能会有历史记录，匹配后要剔重取最新的一条记录。

输出字段：
接入号，服务标识，人员姓名，人员标识，人员工号

--根据需求方提供的附件号码级清单，通过号码匹配号码揽装人编码
drop table if exists tmp_yz_XQGZ2025040300731;
create table if not exists tmp_yz_XQGZ2025040300731 as 
select b.sales_code,b.serv_id,a.index1,a.index2,a.index3,a.index4,a.index5 acc_nbr,a.index6,a.index7,a.index8,a.index9
from zone_gz_yz_3466798313435136 a
left join dwm_yz_tb_comm_cm_all_final b
on a.index5 = b.acc_nbr and b.par_month_id = 202504;

--核查是否有拆机号码
select * from tmp_yz_XQGZ2025040300731 where serv_id is null
--核查是否有重复值
select count(*),count(distinct serv_id) from tmp_yz_XQGZ2025040300731

--根据揽装人编码在dws_crm_cfguse.dws_staff匹配11开头的工号编码staff_account
drop table if exists tmp_yz_XQGZ2025040300731_2;
create table if not exists tmp_yz_XQGZ2025040300731_2 as 
select a.*,b.staff_name,b.staff_id,b.staff_account,b.status_date
from tmp_yz_XQGZ2025040300731 a
left join dws_crm_cfguse.dws_staff b
on a.sales_code = b.staff_code and b.city_id = '200'
--where a.index6 <> '<null>'
;

--核查是否有重复值，发现有重复的记录，所以接下来要剔重
select count(*),count(distinct sales_code) from tmp_yz_XQGZ2025040300731_2

--根据状态更新时间status_date按照从新到旧排序得到序号字段rank
drop table if exists tmp_yz_XQGZ2025040300731_3;
create table if not exists tmp_yz_XQGZ2025040300731_3 as 
select *,row_number () over (partition by serv_id,index7 order by status_date ) as rank
from tmp_yz_XQGZ2025040300731_2 a
;

--rank = 1即为最新记录，筛选
drop table if exists ads_yz_XQGZ2025040300731;
create table if not exists ads_yz_XQGZ2025040300731 as 
select acc_nbr,serv_id,staff_name,staff_id,staff_account
from tmp_yz_XQGZ2025040300731_3 a
where rank = 1
;
