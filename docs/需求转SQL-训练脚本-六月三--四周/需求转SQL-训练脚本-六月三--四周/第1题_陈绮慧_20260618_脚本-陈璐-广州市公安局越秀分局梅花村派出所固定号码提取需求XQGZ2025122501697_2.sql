【工单详情】
工单编号	XQGZ2025122501697	
需求标题	广州市公安局越秀分局梅花村派出所固定号码提取需求
提交人	陈璐	提交人电话	13392132802,02082388807	提交部门	广东公司/市分公司/广州分公司/越秀分公司/越秀数字政务BU营销服务中心
提交日期	2025-12-25 15:49:41
需求描述	广州市公安局越秀分局梅花村派出所为精准向辖区内居民逐户进行防诈宣传，需我司提供梅花村派出所辖区内装有固定电话的用户信息。现申请2025年12月26日至2026年6月30日期间，提供相关个人客户信息，具体字段见附件。
需求字段：固定电话	用户姓名	联系方式	装机地址

【取数口径】
取数口径：根据需求方提供的关键字符串对固话装机地址进行模糊匹配提取清单，即当前在网的固话装机地址中有包含指定关键字符串的则提取。其中固话是指普通电话。
联系方式为固话所属产权客户的联系手机号码。

【输出字段】
'序号','服务标识','固话接入号','机主名','装机地址','标准地址级别','联系手机号码'


--##导入 地址关键字符串列表	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_0;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_0 as
select 
current_date() as run_date
,index1 as addr_order_id
,index2 as addr_name
from zone_gz_yz.zone_gz_yz_342
;

--##模糊匹配包含关键字符串的地址并 插入临时表	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_1 as
select a.*
from zone_gz_yz.dwd_yz_addr_final a
join zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_0 b on a.addr like concat('%', b.addr_name, '%')
;

--##锁定装机地址取数插入清单		
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_2;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_2 as
select distinct 
a.par_month_id as month_id
,a.serv_id
,a.acc_nbr
,to_date(a.open_date) as open_date
,a.prod_id
,a.cust_id
,a.cust_nbr
,a.cust_code
,a.cust_name
,a.party_id
,a.subst_id
,a.subst_name
,a.branch_id
,a.branch_name
,a.area_id
,a.area_name
,a.grid_id
,a.grid_code
,a.grid_name
,a.state
,a.serv_addr_id
,b.addr
,b.grade as addr_grade
from zone_gz_yz.dwm_yz_tb_comm_cm_all_final a
join zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_1 b on cast(a.serv_addr_id as decimal(24,0))=b.id
where a.par_month_id=date_format(current_date(),'yyyyMM')  --当前月份
and a.is_cancel_user=0
and a.prod_id=1
;

--##生成 联系方式 打标清单	
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_lbl_1;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_lbl_1 as
select 
a.serv_id
,a.cust_id
,a.party_id
,b.contact_id
,c.home_phone  --家庭电话
,c.office_phone  --办公室电话
,c.mobile_phone  --手机号码
from zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_2 a
join (select distinct cust_id,contact_id 
      from dws_crm_cust.dws_cust_contact_info_rel
      where city_id=200) b on a.cust_id=b.cust_id
join (select distinct party_id,contact_id,contact_name,home_phone,office_phone,mobile_phone,status_date 
      from dws_crm_cust.dws_contacts_info 
      where city_id=200) c on a.party_id=c.party_id and b.contact_id=c.contact_id
where 1=1
;

--##更新 联系方式		
drop table if exists zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_3;
create table zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_3 as
select
a.*
,b.home_phone  --家庭电话
,b.office_phone  --办公室电话
,b.mobile_phone  --手机号码
from zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_2 a
left join zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_lbl_1 b on a.serv_id=b.serv_id
;

--##【生成结果清单】
drop table if exists zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025122501697;
create table zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025122501697 as
select 
row_number() over (order by serv_id) as order_id  --序号
,a.*
from zone_gz_yz.tmp_yz_cqh_XQGZ2025122501697_3 a
;


--##【创建视图】
drop view if exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2025122501697;
create view if not exists zone_gz.view_ads_yz_cqh_tmp_XQGZ2025122501697 
(
order_id            comment '序号'
,serv_id            comment '服务标识'
,acc_nbr            comment '固话接入号'
,cust_name          comment '机主名'
,addr               comment '装机地址'
,addr_grade         comment '标准地址级别'
,mobile_phone       comment '联系手机号码'
)
as
select
order_id
,serv_id
,acc_nbr
,cust_name
,addr
,addr_grade
,mobile_phone
from zone_gz_yz.ads_yz_cqh_tmp_XQGZ2025122501697
;
