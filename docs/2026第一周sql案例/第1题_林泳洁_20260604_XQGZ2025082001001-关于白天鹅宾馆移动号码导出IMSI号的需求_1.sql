需求单号：XQGZ2025082001001

需求内容：客户白天鹅宾馆移动号码对应的IMSI号申请在系统里导出来，用来配置天翼对讲功能，请领导审批！


需求梳理：根据附件提供的移动号码清单，匹配号码对应的IMSI号（号码属性值中对应属性id为 200000103）
输出字段：序号，号码，IMSI号


drop table if exists tmp_yz_XQGZ2025082001001;
create table tmp_yz_XQGZ2025082001001 as 
select a.index1 as rn,a.index2 as acc_nbr,b.attr_value 
from zone_gz_yz_3410850391529472 a --附件提供的号码清单
left join dwm_yz_tb_comm_cm_all_final c on a.index2=b.acc_nbr and par_month_id='202508' --匹配当月在网号码
left join dws_crm_cust.dws_prod_inst_attr b on c.serv_id=b. prod_inst_id --在号码属性表里面匹配号码属性值
where b.attr_id='200000103' --IMSI号对应的属性值
;
