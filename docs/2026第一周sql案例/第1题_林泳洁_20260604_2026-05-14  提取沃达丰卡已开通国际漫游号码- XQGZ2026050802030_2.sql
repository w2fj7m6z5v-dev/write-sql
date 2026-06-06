/*
需求单号：XQGZ2026050802030
需求描述：广州飞机维修工程有限公司是我司移动业务重点客户 ，该公司的飞机维修项目遍布全球，现因该公司部分号码部分卡为沃达丰卡，导致国际漫游功能关闭，造成该公司员工在国外出差不能使用漫游功能，为了避免引起该公司的强烈投诉，现申请提取广州飞机维修工程有限公司名下沃达丰卡号码、已开通国际漫游的号码，附件为其名下的号码清单，请审批，谢谢！

需求拆解：
1、dws_ctg.dws_mktag_download_share_guoman_label 这个表中的号码就是已开通国际漫游的号码，非在用沃达丰卡的号码
2、提取客户名为‘广州飞机维修工程有限公司’名下沃达丰卡号码、已开通国际漫游但不是在用沃达丰卡的号码，一共两份清单
*/





----第一份清单：提取沃达丰用户清单
drop table if exists ads_yz_XQGZ2026050802030_wdf;
create table ads_yz_XQGZ2026050802030_wdf as
select distinct
    b.serv_id,
    b.acc_nbr,
    b.cust_name,
    a.84410A02001001003024 as is_wdf
from dwm_yz_tb_comm_cm_all_final b
join blms.vw_mid_yd_serv_label_local a
  on b.serv_id = a.serv_id
where b.par_month_id = '202605'
  and b.cust_name = '广州飞机维修工程有限公司'
  and a.city_id = '200'
  and a.84410A02001001003024 = 1
;

----第二份清单：已开通国际漫游的号码，非在用沃达丰卡的号码
drop table if exists ads_yz_XQGZ2026050802030_gm_open_not_wdf;
create table ads_yz_XQGZ2026050802030_gm_open_not_wdf as
select distinct
    b.serv_id,
    b.acc_nbr,
    b.cust_name,
	c.reserv2,--开通国漫时间
    c.yyyymmdd as stat_day--统计时间
from dwm_yz_tb_comm_cm_all_final b
join dws_ctg.dws_mktag_download_share_guoman_label c
  on b.acc_nbr = c.msisdn
where b.par_month_id = '202605'
  and b.cust_name = '广州飞机维修工程有限公司'
  and c.yyyymmdd = '20260513'
;

