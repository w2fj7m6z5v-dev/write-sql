需求原始内容：
XQGZ2025032501375

申请导出城域网业务所对应的客户类型为普通商客的客户信息。目前广州割接通知流程主要是通过割接线路匹配到对应客户的客户经理，由客户经理来通知客户，但是该流程运行过程中，存在一些普通商客类型的客户没有对应的客户经理，无法进行割接通知，为提高割接通知的覆盖率，最大程度确保割接通知达客户，决定对普通商客客户进行额外补通知。需要从客户经理门户中导出城域网业务所对应的客户类型为普通商客的客户信息，包括直销客户名称和直销客户编码、客户所属县分、客户所属营服、客户所属网格，之后会将这批客户信息发给商客中心匹配商客经理，从而对商客经理进行割接通知。因此，烦请从客户经理门户中导出城域网业务所对应的客户类型为普通商客的客户信息，包括直销客户名称和直销客户编码、客户所属县分、客户所属营服、客户所属网格。

需求梳理：
提取出所有城域网号码清单，再通过直销客户信息匹配直销客户表，判断是否为普通商客，最后进行筛选。

要求：
1.号码可能没有直销客户信息，这部分要剔除；
2.在dws_ecust.dws_mo_ccust和dws_yz_mo_ccust表中，nvl(vip_flag,'-1') <> 'TRUE'即为普通商客

输出字段：
服务标识，接入号，直销客户名称，直销客户编码，直销客户所属分局，直销客户所属营服，号码所属网格单元，号码所属网格单元编码，号码所属网格责任田，号码所属网格责任田编码，直销客户ID，直销客户所属分局ID，直销客户所属营服ID

--提取当月城域网产品的号码信息，最重要是划小信息和客户信息
drop table tmp_XQGZ2025032501375;
create table tmp_XQGZ2025032501375 as 
select a.serv_id, a.acc_nbr,a.sales_code, a.prod_id,a.cust_code,a.open_date,a.std_subst_name, a.std_branch_name, a.cell_name, 
a.cell_code, a.subst_name, a.branch_name, a.area_name, a.grid_name, a.grid_code, a.serv_addr_id, b.subst_rule,b.grid_rule
from dwm_yz_tb_comm_cm_all_final a 
left join dwd_yz_jyfx_serv_grid_final b 
on a.serv_id = b.serv_id 
where a.par_month_id = 202504
and  a.prod_id in (57,54)
;

--用客户信息匹配直销客户表，提取是否重点客户vip_flag
drop table tmp_XQGZ2025032501375_ccust;
create table tmp_XQGZ2025032501375_ccust as 
select a.*,c.ccust_name cust_name,b.subst_name subst_name_ccust,b.branch_name branch_name_ccust,b.ccust_id,b.branch_org,b.manage_org,b.vip_flag
from tmp_XQGZ2025032501375 a
left join dws_yz_mo_ccust b
on a.cust_code = b.ccust_code
left join dws_ecust.dws_mo_ccust c
on a.cust_code = c.ccust_code and c.city_id = '200'
;

--按需求筛选普客号码，给出需求字段
drop table ads_yz_XQGZ2025032501375;
create table ads_yz_XQGZ2025032501375 as 
select serv_id,acc_nbr,cust_name,cust_code,subst_name_ccust,branch_name_ccust,cell_name,cell_code,grid_name,grid_code,ccust_id,branch_org,manage_org
from tmp_XQGZ2025032501375_ccust
where nvl(vip_flag,'-1') <> 'TRUE' and cust_code is not null
and prod_id in (57,54)
;
