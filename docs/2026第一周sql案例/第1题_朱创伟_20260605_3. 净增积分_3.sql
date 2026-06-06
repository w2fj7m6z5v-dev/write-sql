需求原始内容：
XQGZ2026041302626
因需要提取商客净增积分，在以下两个报表中，申请赋权“ kq_type ”字段给县分，谢谢！
报表1：view_ns_ads_yz_tb_tyks_score_inc_mtd
报表2：view_ns_ads_yz_sx_qlyz_list


需求梳理：
对净增积分请单增加字段 kq_type。

输出字段：kq_type。






-- 对净增积分表清单5月数据增加字段
drop table if exists tmp_yz_XQGZ2026041302626_list1;
create table tmp_yz_XQGZ2026041302626_list1 as
select
a.*, b.kq_type
from 
ads_yz_tb_tyks_score_inc_mtd
left join 
select * from dwm_yz_tb_comm_cm_all_mon_final
where par_month_id =202605) b
on a.serv_id = b.serv_id 
where par_data_date=202605；




