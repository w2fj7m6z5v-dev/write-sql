需求原始内容：
XQGZ2025111201472

为保障项目顺利完成续约，现申请调取达能骑士卡项目收入及流量使用情况。
yd_prod_type2='快递行业骑士卡'，客户名含“达能”号码。
需要包含以下字段列数据：接入号，客户编码，客户名，划小收入（税后），出账收入，网间语音结算金额，是否超套餐使用流量，超套餐使用流量数，超套餐使用流量费用。

需求梳理：
“网间语音结算金额，是否超套餐使用流量，超套餐使用流量数，超套餐使用流量费用”无法提取。
经与需求方沟通，提取号码出账收入大于10元或者税后出账收入大于30元的账目项信息

输出字段：
统计月份，服务标识，SR科目名称，SR科目路径，收入来源名称，计费收入科目名称，账目项名称，税后收入


--导入客户名称有“达能”的'快递行业骑士卡'号码清单
drop table tmp_XQGZ2025111201472_list;
create table tmp_XQGZ2025111201472_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select par_month_id,serv_id,acc_nbr
from dwm_yz_tb_comm_cm_all_final
where par_month_id=202510
and subst_id=4050
and prod_type=30
and yd_prod_type2='快递行业骑士卡'
and cust_name like '%达能%';


--更新出账收入大于10元或者税后出账收入大于30元的账目项信息
drop table tmp_XQGZ2025111201472_list1;
create table tmp_XQGZ2025111201472_list1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select 
month_id,serv_id,due_income_name,due_type,data_src_name,col_income_name,acct_item_type_name,fee_all
from dwm_srhx_src_income_list 
where month_id=202510
and serv_id in (select serv_id from tmp_XQGZ2025111201472_list where fee>10 or fee_new_tax>30)
order by serv_id;


--输出结果
select month_id,serv_id,due_income_name,due_type,data_src_name,col_income_name,acct_item_type_name,fee_all
from tmp_XQGZ2025111201472_list1
