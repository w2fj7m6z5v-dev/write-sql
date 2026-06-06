需求梳理：
需求方提供产权客户编码和产权客户名称信息,有客编的匹配对应直销以及直销对应的分局营服,没有客编的用客户名匹配客编

输出字段1：
产权客户编码,集团客编,产权客户名称,直销客户编码,直销客户名称,直销客户对应分局,直销客户对应营服

输出字段2：
产权客户编码,集团客编,产权客户名称

--导入客户编码和客户名称信息
create table tmp_yh_cust
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select row_number() over() as row_num,index1 as cust_nbr,index2 as cust_nbr_jt,index3 as cust_name
from zone_gz_yz_343;


--有客编的匹配对应直销以及直销对应的分局营服
drop table tmp_yh_cust1;
create table tmp_yh_cust1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select distinct a.row_num,a.cust_nbr,a.cust_nbr_jt,a.cust_name,b.ccust_code,b.ccust_name,
b.branch_org as subst_id,c.org_name as subst_name,
b.manage_org as branch_id,d.org_name as branch_name
from tmp_yh_cust a
left join zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final b
on a.cust_nbr=b.cust_nbr
left join zone_gz_yz.dwd_yz_dim_org c
on b.branch_org=c.org_id
left join zone_gz_yz.dwd_yz_dim_org d
on b.manage_org=d.org_id
where a.cust_nbr<>''
order by a.row_num;


--没有客编的用客户名匹配客编信息
drop table tmp_yh_cust2;
create table tmp_yh_cust2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select distinct a.row_num,a.cust_nbr,a.cust_nbr_jt,a.cust_name,b.cust_number
from tmp_yh_cust a
left join dws_crm_cust.dws_customer b
on a.cust_name=b.cust_name
where cust_nbr=''
order by a.row_num;


--输出结果1
select row_num,cust_nbr,cust_nbr_jt,cust_name,ccust_code,ccust_name,subst_name,branch_name
from tmp_yh_cust1
--输出结果2
select row_num,cust_nbr,cust_nbr_jt,cust_name,cust_number
from tmp_yh_cust2