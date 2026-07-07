---------------CDAP临时需求

--清单备份
drop table if exists zone_gz_yz.ads_yz_bd129_sdjd_list_bak purge;
create table zone_gz_yz.ads_yz_bd129_sdjd_list_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from zone_gz_yz.ads_yz_bd129_sdjd_list 
where par_month_id>=202307;

insert into table zone_gz_yz.ads_yz_bd129_sdjd_list_bak 
select * from zone_gz_yz.ads_yz_bd129_sdjd_list 
where par_month_id=202308 and data_date=20230828;

insert into table zone_gz_yz.ads_yz_bd129_sdjd_list_bak 
select * from zone_gz_yz.ads_yz_bd129_sdjd_list 
where par_month_id=202308 and data_date=20230829;

--产品维表
select distinct prod_id,prod_name from dws_crm_cfguse.dws_product


--工作助手 宽带发展
select count(case when  is_fee_user=1  then serv_id else null end ) v1,
count(case when  is_fee_user=1 and is_yx=1 then serv_id else null end )  v2,
count(case when  is_fee_user=1 and is_new_user=1 then serv_id else null end ) v3,
count(case when  is_fee_user=1 and is_new_user=1 and is_yx=1 then serv_id else null end ) v4,
count(case when  is_fee_user=1 and is_yx_new_user=1  then serv_id else null end ) v5
from summary_ods_month_city.TB_COMM_CM_DATA_MON 
where PAR_CORP_ID='200' and PAR_MONTH_ID='202306' 
and net_connect_type in (100101,100201,100102,100202,100300) and coalesce(mainstream_net_type,-1) in (10,11) 
and coalesce(is_school_market_user,-1)<>1

--工作助手  移动发展模块
select count(case when  is_fee_user=1  then serv_id else null end ) v1,--移动出账
count(case when  is_fee_user=1 and is_yx=1 then serv_id else null end )  v2,--移动有效出账
count(case when  is_fee_user=1 and is_new_user=1 then serv_id else null end ) v3,--移动入网
count(case when  is_fee_user=1 and is_new_user=1 and is_yx=1 then serv_id else null end ) v4 --移动有效入网 
from summary_ods_month_city.tb_comm_cm_cdma_mon 
where PAR_CORP_ID='200' and PAR_MONTH_ID='202509'


--20230831  吴啸  有效宽带
drop table if exists zone_gz_yz.tmp_yz_zhousi_1 purge;
create table zone_gz_yz.tmp_yz_zhousi_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*, case when b.is_yx=1 then '是' else '否' end as is_sheng_yx
from zone_gz_yz.ads_yz_jingfen_zkrw_list a 
left join summary_ods_month_city.TB_COMM_CM_DATA_MON  b on a.serv_id=b.serv_id and b.PAR_CORP_ID='200' and b.PAR_MONTH_ID='202304'
where a.par_month_id=202304;

drop table if exists zone_gz_yz.tmp_yz_zhousi_2 purge;
create table zone_gz_yz.tmp_yz_zhousi_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*, case when b.is_yx=1 then '是' else '否' end as is_sheng_yx
from zone_gz_yz.ads_yz_jingfen_zkrw_list a 
left join summary_ods_month_city.TB_COMM_CM_DATA_MON  b on a.serv_id=b.serv_id and b.PAR_CORP_ID='200' and b.PAR_MONTH_ID='202305'
where a.par_monthj_id=202305;

drop table if exists zone_gz_yz.tmp_yz_zhousi_11 purge;
create table zone_gz_yz.tmp_yz_zhousi_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct serv_id,prod_type3 from zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final
where par_month_id=202304 and prod_type=40 and is_new_user=1 and date_format(open_date,'yyyyMM')='202304';

drop table if exists zone_gz_yz.tmp_yz_zhousi_12 purge;
create table zone_gz_yz.tmp_yz_zhousi_12
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*, b.prod_type3 as dz_zk
from zone_gz_yz.tmp_yz_zhousi_1 a 
left join zone_gz_yz.tmp_yz_zhousi_11 b on a.serv_id=b.serv_id 
where a.par_month_id=202304;

drop table if exists zone_gz_yz.tmp_yz_zhousi_13;
create table zone_gz_yz.tmp_yz_zhousi_13 as 
select 
a.month_id,a.subst_name,a.region_type,a.dz_zk,a.is_sheng_yx,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
a.offer_name,
case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,
count(distinct serv_id) as kdrw_num
from zone_gz_yz.tmp_yz_zhousi_1 a 
where a.par_month_id=202304 and a.kd_desc='普通宽带'
group by a.month_id,a.subst_name,a.region_type,
a.dz_zk,a.is_sheng_yx,a.is_rh_ykj,a.offer_name,
a.rh_type_ykj;


drop table if exists zone_gz_yz.tmp_yz_zhouwu_1; 
create table zone_gz_yz.tmp_yz_zhouwu_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select t.serv_id,t.prod_offer_id,t.type as prod_type3
from (select a.serv_id,a.prod_offer_id,b.type,b.type_id,row_number() over(partition by a.serv_id order by b.type_id asc) type_row
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_mon_final a
join dwd_dim_dzkd_offer b
--join (select seq_value_id as prod_offer_id from zone_gz_yz.dwd_dim_all_config where seq_id=6) b
on a.prod_offer_id=b.prod_offer_id
where a.par_month_id=202307
AND date_format(a.create_date,'yyyyMMdd') <= '20230731'
and date_format(a.limit_date,'yyyyMMdd') > '20230731'
) t
where t.type_row=1


drop table if exists zone_gz_yz.tmp_yz_zhouwu_2;
create table zone_gz_yz.tmp_yz_zhouwu_2 as 
select a.*,case when a.prod_type3='副宽' then b.prod_offer_id else null end as fk_prod_offer_id
from zone_gz_yz.tmp_yz_zhousi_4 a 
left join zone_gz_yz.tmp_yz_zhouwu_1 b on a.serv_id=b.serv_id and b.prod_type3='副宽';

drop table if exists zone_gz_yz.tmp_yz_zhouwu_3;
create table zone_gz_yz.tmp_yz_zhouwu_3 as 
select 
a.region_type,a.is_sheng_yx,a.fk_prod_offer_id,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
a.offer_name,
case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,
count(distinct serv_id) as kdrw_num
from zone_gz_yz.tmp_yz_zhouwu_2 a 
where a.par_month_id=202307 and a.kd_desc='普通宽带' and a.prod_type3='副宽' 
group by a.region_type,a.is_sheng_yx,a.fk_prod_offer_id,a.is_rh_ykj,a.offer_name,
a.rh_type_ykj;

left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200) b on a.kd_prod_offer_id=b.offer_id

--20230906 张建新  有效宽带
drop table if exists zone_gz_yz.tmp_yz_zhousan_1;
create table zone_gz_yz.tmp_yz_zhousan_1 as 
select a.par_month_id,a.serv_id,a.kd_desc,a.is_zhuanxian,a.prod_type3,a.is_rh_ykj,a.is_sheng_yx,a.rh_type_ykj,
case when b.is_yx=1 then '是' else '否' end as is_yx_m8
from zone_gz_yz.ads_yz_jingfen_zkrw_list a 
left join (select distinct serv_id,is_yx from summary_ods_month_city.TB_COMM_CM_DATA_MON where PAR_CORP_ID='200' and PAR_MONTH_ID='202308') b on a.serv_id=b.serv_id;

select 
a.par_month_id,a.kd_desc,
a.is_zhuanxian,a.prod_type3,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
a.is_sheng_yx,
case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,a.is_yx_m8,

count(distinct serv_id) as kdrw_num
from zone_gz_yz.tmp_yz_zhousan_1 a 
group by a.par_month_id,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.is_rh_ykj,a.is_sheng_yx,a.rh_type_ykj,a.is_yx_m8;

--20230912  吴啸  一次性费用
drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct serv_id,prod_offer_id from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where 1=1 and par_month_id=202307 and par_corp_id='200'
and prod_offer_id in(500034130,500034131,500034132,500034133,500034134,500034135,500053110,
500043064,500052132,500051368,500051371,500051370,500051369,500054137,500072433,500072431,
500072047,500071032,500071031,500071030,500070372,500070040,500069131,500069130,500069059,
500069058,500068065,500068051,500067142,500067080,500068019,500067024,500069022,500069021,
500069024,500069094,500069095,500067025,500067123,500069265,500068064,500069075,500067093,
500068068,500069253,500069076,500071149,500061097,500067000,500051371,500056239,500049112,
100001412,500053121,500054136,500057149,500057199,500061098,500057150
) and date_format(limit_date,'yyyyMMdd') > '20230731';

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct serv_id,prod_offer_id from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where 1=1 and par_month_id=202307 and par_corp_id='200'
and prod_offer_id in(500069147,500069065,500069064,500068055,500068054,500067084,500067083,
500059060,500058352,500058351,500058187,500058186,500058185,500057533,500056353,500056339,
500056338,500056239,500056173,500054005,500054004,500052142,500052017,500052016,500052015,
500051376,500051375,500051374,500051373,500051372,500051322,500051321,500051320,500049113,
500049112,500048043,500048042,500048041,500048040,500048039
) and date_format(limit_date,'yyyyMMdd') > '20230731';

drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,row_number() over(partition by serv_id order by prod_offer_id) as pm 
from zone_gz_yz.tmp_yz_liq_1 a;

drop table if exists zone_gz_yz.tmp_yz_liq_4 purge;
create table zone_gz_yz.tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,row_number() over(partition by serv_id order by prod_offer_id) as pm 
from zone_gz_yz.tmp_yz_liq_2 a;

drop table if exists zone_gz_yz.tmp_yz_liq_5 purge;
create table zone_gz_yz.tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.prod_offer_id as prod_offer_id_guangmao,
c.prod_offer_id as prod_offer_id_tiaoce 
from zone_gz_yz.ads_yz_jingfen_zkrw_list a 
left join (select * from zone_gz_yz.tmp_yz_liq_3 where pm=1) b on a.serv_id=b.serv_id 
left join (select * from zone_gz_yz.tmp_yz_liq_4 where pm=1) c on a.serv_id=c.serv_id 
where a.par_month_id=202307;


select 
a.is_zhuanxian,a.prod_type3,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
a.is_sheng_yx,

case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,
prod_offer_id_guangmao,prod_offer_id_tiaoce,

count(distinct serv_id) as kdrw_num,
sum(rh_tc_value) taocan_jf

from zone_gz_yz.tmp_yz_liq_5 a 
where  kd_desc='普通宽带'
group by 
a.is_zhuanxian,a.prod_type3,a.is_rh_ykj,a.is_sheng_yx,
a.rh_type_ykj,prod_offer_id_guangmao,prod_offer_id_tiaoce;


--20230925 周厚彪 是否新宽新移
drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when b.rh_type_ykj='新宽带新移动' then '是' else '否' end is_xkxy,b.cust_nbr 
from zone_gz_yz_3351225714708480 a 
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_final b on a.index2=b.acc_nbr and b.par_month_id=202306
where a.index1='202306';

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when b.rh_type_ykj='新宽带新移动' then '是' else '否' end is_xkxy,b.cust_nbr 
from zone_gz_yz_3351225714708480 a 
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_final b on a.index2=b.acc_nbr and b.par_month_id=202307
where a.index1='202307';

drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when b.rh_type_ykj='新宽带新移动' then '是' else '否' end is_xkxy,b.cust_nbr 
from zone_gz_yz_3351225714708480 a 
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_final b on a.index2=b.acc_nbr and b.par_month_id=202308
where a.index1='202308';


--20230928 渠道室
锁定12月，融合套餐(分129和229 2个档次)量和收入，
按划小分机构，然后锁定套餐ID，去7月匹配仍然存在的套餐量和7月套餐下的号码收入

drop table if exists zone_gz_yz.tmp_yz_liq_5 purge;
create table zone_gz_yz.tmp_yz_liq_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select serv_id,rh_tc_id
from zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id=202212 and rh_tc_value>=129 
and is_rh_ykj>0;

drop table if exists zone_gz_yz.tmp_yz_liq_6 purge;
create table zone_gz_yz.tmp_yz_liq_6
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select serv_id,rh_tc_id
from zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id=202307 and is_rh_ykj>0;

--给 tmp_yz_liq_5  和  tmp_yz_liq_6 的serv_id 匹收入

drop table if exists zone_gz_yz.tmp_yz_liq_4 purge;
create table zone_gz_yz.tmp_yz_liq_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct rh_tc_value,rh_tc_id
from zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id=202212 and rh_tc_value>=129 
and is_rh_ykj>0;

drop table if exists zone_gz_yz.tmp_yz_liq_7 purge;
create table zone_gz_yz.tmp_yz_liq_7
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.subst_id,b.subst_name
from zone_gz_yz.tmp_yz_liq_4 a 
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final b on a.rh_tc_id=b.serv_id 
and b.par_month_id=202212 and b.is_rh_ykj>0;

drop table if exists zone_gz_yz.tmp_yz_liq_8 purge;
create table zone_gz_yz.tmp_yz_liq_8
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
case when b.rh_tc_id is not null then b.rh_tc_id else null end as tc_id_202307,
case when b.rh_tc_id is not null then b.rh_tc_value else 0 end as tc_value_202307
from zone_gz_yz.tmp_yz_liq_7 a 
left join (select distinct rh_tc_id,rh_tc_value from zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202307 and is_rh_ykj>0) b on a.rh_tc_id=b.rh_tc_id;



--zone_gz_yz.tmp_yz_zsf_rh_202212_202307_sr，
--22年12月与23年7月划小收入表已建好，
--month_id,serv_id,acc_nbr,prod_id,subst_id,branch_id,new_ccenter,a0,a0_sq,a0_sj

drop table if exists zone_gz_yz.tmp_yz_liq_9 purge;
create table zone_gz_yz.tmp_yz_liq_9
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when b.fee is not null then b.fee else 0 end fee_202212
from zone_gz_yz.tmp_yz_liq_5 a
left join (select serv_id,sum(a0) fee from zone_gz_yz.tmp_yz_zsf_rh_202212_202307_sr where month_id=202212 group by serv_id) b on a.serv_id=b.serv_id;


drop table if exists zone_gz_yz.tmp_yz_liq_10 purge;
create table zone_gz_yz.tmp_yz_liq_10
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when b.fee is not null then b.fee else 0 end fee_202307
from zone_gz_yz.tmp_yz_liq_6 a
left join (select serv_id,sum(a0) fee from zone_gz_yz.tmp_yz_zsf_rh_202212_202307_sr where month_id=202307 group by serv_id) b on a.serv_id=b.serv_id;

drop table if exists zone_gz_yz.tmp_yz_liq_11 purge;
create table zone_gz_yz.tmp_yz_liq_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.fee as fee_202212
from zone_gz_yz.tmp_yz_liq_8 a 
left join (select rh_tc_id,sum(fee_202212) fee from tmp_yz_liq_9 group by rh_tc_id) b on a.rh_tc_id=b.rh_tc_id;

drop table if exists zone_gz_yz.tmp_yz_liq_12 purge;
create table zone_gz_yz.tmp_yz_liq_12
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.fee as fee_202307
from zone_gz_yz.tmp_yz_liq_11 a 
left join (select rh_tc_id,sum(fee_202307) fee from tmp_yz_liq_10 group by rh_tc_id) b on a.rh_tc_id=b.rh_tc_id;


select subst_name,
count(distinct rh_tc_id) as rh_tc_202212,
sum(fee_202212) as tc_fee_202212,
count(distinct case when tc_id_202307 is not null then rh_tc_id else null end) as rh_tc_202307,
sum(case when tc_id_202307 is not null then fee_202307 else 0 end) as tc_fee_202307 
from tmp_yz_liq_12 where rh_tc_value>=129 group by subst_name

--20231008 主宽入网多维表新增实收率
本地口径：套餐价值积分/移动主套餐档次

-- 移动主套餐档次 CDAP
/* select b.reserve,a.acc_nbr,b.cdma_disc_type3_name
from  zone_gz_yz.dwm_yz_tb_comm_cm_all_final a,
metadata_ods_day.tb_dim_cdma_disc_type b
where a.par_month_id=202308
and a.is_cancel_user = 0 --非拆机（在网号码）
and a.acc_nbr='18922166838'
and a.cdma_disc_type=b.cdma_disc_type3 */

drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from zone_gz_yz.ads_yz_jingfen_zkrw_list 
where par_month_id=202309;

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.rh_tc_id
from tmp_yz_liq_1 a 
left join zone_gz_yz.dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and b.par_month_id=202309;

drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.cdma_disc_type
from tmp_yz_liq_2 a 
left join 
(select rh_tc_id,cdma_disc_type,row_number() over(partition by rh_tc_id order by cdma_disc_type) as paixu from zone_gz_yz.dwm_yz_tb_comm_cm_all_final where par_month_id=202309 and prod_type=30 and is_vice_card=0 and is_rh_ykj>0 and is_cancel_user=0) b 
on a.rh_tc_id=b.rh_tc_id and b.paixu=1;

drop table if exists zone_gz_yz.tmp_yz_liq_5 purge;
create table zone_gz_yz.tmp_yz_liq_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
b.reserve,--移动主套餐档次
case when COALESCE(b.reserve,0)<>0 then a.rh_tc_value/b.reserve else null end as shishou_lv --实收率
from tmp_yz_liq_3 a 
left join metadata_ods_day.tb_dim_cdma_disc_type b on a.cdma_disc_type=b.cdma_disc_type3;

drop table if exists zone_gz_yz.ads_yz_tmp_zkrw_dwb_linshi purge;
create table zone_gz_yz.ads_yz_tmp_zkrw_dwb_linshi
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from tmp_yz_liq_4 
union all 
select * from tmp_yz_liq_5;

drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 
a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
case when a.serv_grp_type='01' then '政企' when a.serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc,
a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,a.reserve,

case when coalesce(a.rh_tc_value,0)<59 then '[0,59)'  
when coalesce(a.rh_tc_value,0)>=59 and coalesce(a.rh_tc_value,0)<99 then '[59,99)' 
when coalesce(a.rh_tc_value,0)>=99 and coalesce(a.rh_tc_value,0)<129 then '[99,129)' 
when coalesce(a.rh_tc_value,0)>=129 and coalesce(a.rh_tc_value,0)<169 then '[129,169)' 
when coalesce(a.rh_tc_value,0)>=169 and coalesce(a.rh_tc_value,0)<199 then '[169,199)' 
when coalesce(a.rh_tc_value,0)>=199 and coalesce(a.rh_tc_value,0)<229 then '[199,229)' 
when coalesce(a.rh_tc_value,0)>=229 and coalesce(a.rh_tc_value,0)<299 then '[229,299)' 
when coalesce(a.rh_tc_value,0)>=299 and coalesce(a.rh_tc_value,0)<399 then '[299,399)' 
when coalesce(a.rh_tc_value,0)>=399 and coalesce(a.rh_tc_value,0)<699 then '[399,699)'  
when coalesce(a.rh_tc_value,0)>=699 then '699及以上' end jf_dangci,

case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,

count(distinct serv_id) as kdrw_num,
sum(rh_tc_value) taocan_jf
from zone_gz_yz.ads_yz_tmp_zkrw_dwb_linshi a 
where a.par_month_id=202308
group by a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
a.is_rh_ykj,a.serv_grp_type,a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,a.reserve,a.rh_tc_value,
a.rh_type_ykj;

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 
a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
case when a.serv_grp_type='01' then '政企' when a.serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc,
a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,a.reserve,

case when coalesce(a.rh_tc_value,0)<59 then '[0,59)'  
when coalesce(a.rh_tc_value,0)>=59 and coalesce(a.rh_tc_value,0)<99 then '[59,99)' 
when coalesce(a.rh_tc_value,0)>=99 and coalesce(a.rh_tc_value,0)<129 then '[99,129)' 
when coalesce(a.rh_tc_value,0)>=129 and coalesce(a.rh_tc_value,0)<169 then '[129,169)' 
when coalesce(a.rh_tc_value,0)>=169 and coalesce(a.rh_tc_value,0)<199 then '[169,199)' 
when coalesce(a.rh_tc_value,0)>=199 and coalesce(a.rh_tc_value,0)<229 then '[199,229)' 
when coalesce(a.rh_tc_value,0)>=229 and coalesce(a.rh_tc_value,0)<299 then '[229,299)' 
when coalesce(a.rh_tc_value,0)>=299 and coalesce(a.rh_tc_value,0)<399 then '[299,399)' 
when coalesce(a.rh_tc_value,0)>=399 and coalesce(a.rh_tc_value,0)<699 then '[399,699)'  
when coalesce(a.rh_tc_value,0)>=699 then '699及以上' end jf_dangci,

case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,

count(distinct serv_id) as kdrw_num,
sum(rh_tc_value) taocan_jf
from zone_gz_yz.ads_yz_tmp_zkrw_dwb_linshi a 
where a.par_month_id=202309
group by a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
a.is_rh_ykj,a.serv_grp_type,a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,a.reserve,a.rh_tc_value,
a.rh_type_ykj;

drop table if exists zone_gz_yz.ads_yz_tmp_zkrw_dwb_ls purge;
create table zone_gz_yz.ads_yz_tmp_zkrw_dwb_ls
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from tmp_yz_liq_1
union all 
select * from tmp_yz_liq_2;


--20231013  刘丽娜  129+9月净增凑数，因省积分9月调整金融合约积分配置
-- 套餐内取 create_date 最大的一条
/* drop table if exists zone_gz_yz.tmp_liq_jrhy_xsp purge;
create table zone_gz_yz.tmp_liq_jrhy_xsp
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.offer_id 
from zone_gz_yz_3351225714708480 a 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200) b on a.index2=b.prod_offer_code;
		
 */

drop table if exists zone_gz_yz.tmp_liq_1013_1 purge;
create table zone_gz_yz.tmp_liq_1013_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_bd129_sdjd_list where par_month_id in(202308,202309);

drop table if exists zone_gz_yz.tmp_liq_1013_2_1 purge;
create table zone_gz_yz.tmp_liq_1013_2_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.serv_id,a.create_date,a.prod_offer_id,
row_number() over(partition by serv_id order by prod_offer_id,create_date desc) as order_id,
row_number() over(partition by serv_id,prod_offer_id order by create_date desc) as order_id2,
b.index4 as jf_change
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_mon_final a 
join tmp_liq_jrhy_xsp b on a.prod_offer_id=b.offer_id 
where a.par_month_id=202309 
and date_format(a.limit_date,'yyyyMM') >='202310' and a.prod_id in(3204,3205);


drop table if exists zone_gz_yz.tmp_liq_1013_2 purge;
create table zone_gz_yz.tmp_liq_1013_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
case when b.serv_id is not null then 1 else 0 end is_hy,
case when b.serv_id is not null then b.create_date else null end hy_create_date,
case when b.serv_id is not null then b.prod_offer_id else null end hy_prod_offer_id
from tmp_liq_1013_1 a 
left join tmp_liq_1013_2_1 b on a.serv_id=b.serv_id and b.order_id=1
;


drop table if exists zone_gz_yz.tmp_liq_1013_3 purge;
create table zone_gz_yz.tmp_liq_1013_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
case when b.is_tc_hy>0 then 1 else 0 end is_hy_tc
from tmp_liq_1013_2 a 
left join (select par_month_id,rh_tc_id,sum(is_hy) is_tc_hy from tmp_liq_1013_2 group by par_month_id,rh_tc_id ) b 
on a.rh_tc_id=b.rh_tc_id and a.par_month_id=b.par_month_id;


drop table if exists zone_gz_yz.tmp_liq_1013_5 purge;
create table zone_gz_yz.tmp_liq_1013_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select rh_tc_id,hy_prod_offer_id,
row_number() over(partition by rh_tc_id order by hy_create_date desc) as paixu 
from tmp_liq_1013_3 where is_hy=1;

drop table if exists zone_gz_yz.tmp_liq_1013_6 purge;
create table zone_gz_yz.tmp_liq_1013_6
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.hy_prod_offer_id as prod_offer_id_hy
from tmp_liq_1013_3 a 
left join (select * from tmp_liq_1013_5 where paixu=1) b 
on a.rh_tc_id=b.rh_tc_id;



/* drop table if exists zone_gz_yz.tmp_liq_1013_8 purge;
create table zone_gz_yz.tmp_liq_1013_8
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.index4 as jf_change
from tmp_liq_1013_6 a 
left join tmp_liq_jrhy_xsp b on a.prod_offer_id_hy=b.offer_id 
; */

drop table if exists zone_gz_yz.tmp_liq_1013_8 purge;
create table zone_gz_yz.tmp_liq_1013_8
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.tzjf as jf_change
from tmp_liq_1013_6 a 
left join (select serv_id,sum(jf_change) tzjf from tmp_liq_1013_2_1 where order_id2=1 group by serv_id) b on a.serv_id=b.serv_id 
;

drop table if exists zone_gz_yz.tmp_liq_1013_9 purge;
create table zone_gz_yz.tmp_liq_1013_9
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.tzjf
from tmp_liq_1013_8 a 
left join (select par_month_id,rh_tc_id,sum(jf_change) tzjf from tmp_liq_1013_8 group by par_month_id,rh_tc_id) b 
on a.rh_tc_id=b.rh_tc_id  and a.par_month_id=b.par_month_id
;

drop table if exists zone_gz_yz.ads_yz_129rh_buda_jrhy_jf purge;
create table zone_gz_yz.ads_yz_129rh_buda_jrhy_jf
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select *
from tmp_liq_1013_9;

--剔除客户级松散融合
drop table if exists zone_gz_yz.tmp_liq_0204 purge;
create table zone_gz_yz.tmp_liq_0204
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.rh_rule from tmp_liq_1013_9 a 
left join dwd_yz_rpt_comm_cm_rh_list_mon_final b on a.serv_id=b.serv_id and b.par_month_id=202309;

drop table if exists zone_gz_yz.tmp_liq_1013_10 purge;
create table zone_gz_yz.tmp_liq_1013_10
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select rh_rule,rh_tc_id,tc_points,tc_points_sy,subst_name,branch_name,area_name,
(tc_points-tc_points_sy) tc_points_cy,is_hy_tc,tzjf,zc_type_yyyy,
(case when tc_points-tc_points_sy>20 then 0 else 1 end) is_gt_20,

case when tc_points>=129 and rh_type_ykj='新宽带新移动' then '纯新装'
when tc_points>=129 and is_yk_sy=1 and tc_points_sy<129 then '129-到129+' 
when tc_points>=129 and rh_type_ykj='老宽带新移动' and is_zw_dan_sy=2 then '单宽叠移进融' 
when tc_points>=129 and is_zw_dan_sy=0 and coalesce(rh_type_ykj,'-1')<>'新宽带新移动' and is_tcyd_dan_sy=1 then '单移叠宽进融' 
when tc_points>=129 and is_yk_sy=1 and tc_points_sy>=129 then '不升不降' 
else '其它'
end as sd_type

from zone_gz_yz.tmp_liq_0204 where par_month_id=202309 and is_rh_ykj>0 
and prod_type=40 and coalesce(itv_type,-1) not in (0,1) and coalesce(prod_type2,-1)<>80;


view_129_month9_bd: select * from zone_gz_yz.tmp_liq_1013_10 
--这个是补上合约那部分后的
select subst_name,--局向
count（distinct rh_tc_id） --129套餐数
from view_129_month9_bd
where tc_points+coalesce(tzjf,0)>=129 
and rh_rule in(10,20) --剔除客户级松散融合
group by subst_name order by subst_name

--字段
select rh_tc_id,--套餐ID
tc_points,--9月套餐积分
tc_points_sy,--8月套餐积分
subst_name,--局向
branch_name,--营服
area_name,--包区
tc_points_cy,--实际降档积分
is_hy_tc,--是否合约
tzjf,--积分扣减值
is_gt_20 --实际降档积分是否小于等于20，1是，0否

drop table if exists zone_gz_yz.tmp_liq_1013_11 purge;
create table zone_gz_yz.tmp_liq_1013_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select rh_tc_id,tc_points,tc_points_xy,subst_name,branch_name,area_name,
(tc_points-tc_points_xy) tc_points_cy,is_hy_tc,tzjf,zc_type_yyyy,
(case when tc_points-tc_points_xy>20 then 0 else 1 end) is_gt_20,

case when tc_points>=129 and is_yk_xy=1 and tc_points_xy<129 and is_4zhe_xy=0 then '129+到129-'
when tc_points>=129 and is_yk_xy=1 and tc_points_xy<129 and is_4zhe_xy=1 then '员工129+到129-'
when tc_points>=129 and is_zw_dan_xy=2  then '融合转单宽' 
when tc_points>=129 and is_tcyk_nzw_xy=1 then '融合拆机' 
when tc_points>=129 and is_zw_dan_xy=0 and is_tcyd_dan_xy=1 then '融合转单移' 
when tc_points>=129 and is_yk_xy=1 and tc_points_xy>=129 then '不升不降' 
else '其它'
end as xy_jd_type 

from zone_gz_yz.tmp_liq_1013_9 where par_month_id=202308 and is_rh_ykj>0 
and prod_type=40 and coalesce(itv_type,-1) not in (0,1) and coalesce(prod_type2,-1)<>80;

/* drop table if exists zone_gz_yz.tmp_liq_1013_11 purge;
create table zone_gz_yz.tmp_liq_1013_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
SELECT rh_tc_id,tc_points,tc_points_xy,subst_name,branch_name,area_name,
(tc_points-tc_points_xy) tc_points_cy,is_hy_tc,jf_change,
(case when tc_points-tc_points_xy>20 then 0 else 1 end) is_gt_20
FROM zone_gz_yz.tmp_liq_1013_9 WHERE 
tc_points>=129 and is_yk_xy=1 and tc_points_xy<129 and is_4zhe_xy=0
and par_month_id = '202308' and is_rh_ykj>0 
and prod_type=40 and coalesce(itv_type,-1) not in (0,1) and coalesce(prod_type2,-1)<>80 
and zc_type_yyyy='存量'; */


select subst_name,count(distinct rh_tc_id) as jd_num
from tmp_liq_1013_9 a where is_hy_tc=1 and is_gt_20=1
group by subst_name 


select count(distinct rh_tc_id) from tmp_liq_1013_10 where tc_points>=129
select count(distinct rh_tc_id) from tmp_liq_1013_10 where tc_points+coalesce(tzjf,0)>=129
1401506-1439754

--杨洋 


drop table tmp_yy;
create table tmp_yy as 
SELECT rh_tc_id,tc_points,tc_points_xy,
(tc_points-tc_points_xy) tc_points_cy,
(case when tc_points-tc_points_xy>20 then 0 else 1 end) is_gt_20
FROM zone_gz_yz.ads_yz_bd129_sdjd_list WHERE 
tc_points>=129 and is_yk_xy=1 and tc_points_xy<129 and is_4zhe_xy=0
and par_month_id = '202308' and is_rh_ykj>0 
and prod_type=40 and coalesce(itv_type,-1) not in (0,1) and coalesce(prod_type2,-1)<>80 
and zc_type_yyyy='存量';



drop table tmp_yy2;
create table tmp_yy2 as 
select a.serv_id,a.prod_offer_id,a.create_date,
b.index2 prod_offer_code,b.index1 prod_offer_name,cast(index4 as decimal(22,2)) tzdz,
row_number() over(partition by serv_id order by create_date desc) pm
from (select serv_id,prod_offer_id,create_date from iodata_ods_month_city.rpt_comm_cm_msdisc_mon
where par_corp_id=200 and par_month_id=202309 
and date_format(limit_date,'yyyyMM')>='202310' )a 
join tmp_liq_jrhy_xsp b
on a.prod_offer_id=b.offer_id;


drop table tmp_yy3;
create table tmp_yy3 as 
select a.rh_tc_id,a.serv_id,b.prod_offer_id,b.prod_offer_code,b.prod_offer_name,b.tzdz,b.create_date,
row_number() over(partition by rh_tc_id order by b.create_date desc) pm
from (select rh_tc_id,serv_id from dwm_yz_tb_comm_cm_all_final where par_month_id=202309 and rh_tc_id is not null) a
join (select * from tmp_yy2 where pm=1) b
on a.serv_id=b.serv_id;


drop table tmp_yy4;
create table tmp_yy4 as 
select a.*,
(case when b.rh_tc_id is not null then b.prod_offer_id else null end) hy_prod_offer_id,
(case when b.rh_tc_id is not null then b.prod_offer_code else null end) hy_prod_offer_code,
(case when b.rh_tc_id is not null then b.prod_offer_name else null end) hy_prod_offer_name,
(case when b.rh_tc_id is not null then b.tzdz else 0 end) tzdz,
(case when b.rh_tc_id is not null then 1 else 0 end) is_hy	
from tmp_yy a
left join (select *  from tmp_yy3 where pm=1) b
on a.rh_tc_id=b.rh_tc_id;


select b.subst_name,count(distinct a.rh_tc_id) as jd_num
from tmp_yy4 a 
left join (select distinct serv_id,subst_name from ads_yz_bd129_sdjd_list where par_month_id = '202308' 
and is_rh_ykj>0  and prod_type=40 and coalesce(itv_type,-1) not in (0,1)) b on a.rh_tc_id=b.serv_id
where a.is_hy=1 and a.is_gt_20=1
group by b.subst_name

--20231017 杨洋  129补丁第1版


drop table tmp_yy;
create table tmp_yy as 
SELECT rh_tc_id,tc_points,tc_points_xy,
(tc_points-tc_points_xy) tc_points_cy,
(case when tc_points-tc_points_xy>20 then 0 else 1 end) is_gt_20
FROM zone_gz_yz.ads_yz_bd129_sdjd_list WHERE 
tc_points>=129 and is_yk_xy=1 and tc_points_xy<129 and is_4zhe_xy=0
and par_month_id = '202308' and is_rh_ykj>0 
and prod_type=40 and coalesce(itv_type,-1) not in (0,1) and coalesce(prod_type2,-1)<>80 
and zc_type_yyyy='存量';



drop table tmp_yy2;
create table tmp_yy2 as 
select a.serv_id,a.prod_offer_id,a.create_date,
b.index2 prod_offer_code,b.index1 prod_offer_name,cast(index4 as decimal(22,2)) tzdz,
row_number() over(partition by serv_id order by create_date desc) pm
from (select serv_id,prod_offer_id,create_date from iodata_ods_month_city.rpt_comm_cm_msdisc_mon
where par_corp_id=200 and par_month_id=202309 
and date_format(limit_date,'yyyyMM')>='202310' )a 
join tmp_liq_jrhy_xsp b
on a.prod_offer_id=b.offer_id;


drop table tmp_yy3;
create table tmp_yy3 as 
select a.rh_tc_id,a.serv_id,b.prod_offer_id,b.prod_offer_code,b.prod_offer_name,b.tzdz,b.create_date,
row_number() over(partition by rh_tc_id order by b.create_date desc) pm
from (select rh_tc_id,serv_id from dwm_yz_tb_comm_cm_all_final where par_month_id=202309 and rh_tc_id is not null) a
join (select * from tmp_yy2 where pm=1) b
on a.serv_id=b.serv_id;


drop table tmp_yy4;
create table tmp_yy4 as 
select a.*,
(case when b.rh_tc_id is not null then b.prod_offer_id else null end) hy_prod_offer_id,
(case when b.rh_tc_id is not null then b.prod_offer_code else null end) hy_prod_offer_code,
(case when b.rh_tc_id is not null then b.prod_offer_name else null end) hy_prod_offer_name,
(case when b.rh_tc_id is not null then b.tzdz else 0 end) tzdz,
(case when b.rh_tc_id is not null then 1 else 0 end) is_hy	
from tmp_yy a
left join (select *  from tmp_yy3 where pm=1) b
on a.rh_tc_id=b.rh_tc_id;





#########################
--20231017 杨洋  129补丁第2版
20231017 




drop table tmp_yy2;
create table tmp_yy2 as 
select a.serv_id,a.prod_offer_id,a.prod_id,
b.index2 prod_offer_code,b.index1 prod_offer_name,cast(index4 as decimal(22,2)) tzdz
from (select distinct serv_id,prod_offer_id,prod_id from iodata_ods_month_city.rpt_comm_cm_msdisc_mon
where par_corp_id=200 and par_month_id=202309 
and date_format(limit_date,'yyyyMM')>='202310' )a 
join tmp_liq_jrhy_xsp b
on a.prod_offer_id=b.offer_id;

/*
select serv_Id,prod_offer_id,count(1) from tmp_yy2 
group by serv_Id,prod_offer_id having count(1)>1
--null
select prod_id,count(1) from tmp_yy2 group by prod_id
--3205 686010
select sum(tzdz) from tmp_yy2
--5419532.49
select sum(tzdz) from tmp_yy2 where serv_id in (select serv_id from tmp_yy1)
--4134637.81
*/


drop table tmp_yy3;
create table tmp_yy3 as
select serv_id,sum(tzdz) kjje
from tmp_yy2 group by serv_id;

--select sum(kjje) from tmp_yy3   5419532.49

drop table tmp_yy4;
create table tmp_yy4 as
select a.*,(case when b.serv_id is not null then b.kjje else 0 end) kjje_hm
from (select *  from zone_gz_yz.ads_yz_bd129_sdjd_list WHERE par_month_id = '202309'  and is_rh_ykj>0) a
left join tmp_yy3 b
on a.serv_id=b.serv_id;

--select prod_id,prod_type,sum(kjje_hm) from tmp_yy4 group by  prod_id,prod_type
--3205 30 4134637.81

drop table tmp_yy5;
create table tmp_yy5 as
select rh_tc_id,sum(kjje_hm) kjje_1
from tmp_yy4
group by rh_tc_id;
--select sum(kjje_1) from tmp_yy5
--4134637.81

drop table tmp_yy6;
create table tmp_yy6 as
select a.*,(case when b.rh_tc_id is not null then b.kjje_1 else 0 end) kjje_tc
from tmp_yy4 a
left join tmp_yy5 b
on a.rh_tc_id=b.rh_tc_id;

--select sum(kjje_tc) from (select distinct rh_tc_id,kjje_tc from tmp_yy6) a
--4134637.81


select count(distinct rh_tc_id) from tmp_yy6 where tc_points>=129
union all
select count(distinct rh_tc_id) from tmp_yy6 where (tc_points+kjje_tc）>=129
													
select 1401506-1439754		
-38248


select par_month_id,count(distinct rh_tc_id)  from zone_gz_yz.ads_yz_bd129_sdjd_list WHERE  tc_points>=129 and is_rh_ykj>0
group by par_month_id  order by par_month_id
par_month_id	_c1
202212	1395042
202301	1390527
202302	1390037
202303	1398585
202304	1404847
202305	1411462
202306	1421763
202307	1423409
202308	1432367

--20231031  蔡婷  融合新增销售品测算
八个销售品：
100089351
100089352
100089353
100089354
100095244
100096150
100096151
100096152

1、先在维表找八个销售品
2、如果没有的，在优惠资料表取所有宽带和移动主卡号码办了这八个销售品
3、msinfo_id关联宽带移动主卡

select * from zone_gz_yz.dwd_yz_xsb_wx_jmrh_disc where 
prod_offer_id in(100089351,100089352,100089353,100089354,100095244,100096150,100096151,100096152)
YD4G03-A133-2-2  畅享全融合_10元升级宽带200M优惠包  100096151
YD4G03-A133-2-3  畅享全融合_10元升级宽带500M优惠包  100096152

--没有
select * from zone_gz_yz.dwd_yz_xsb_ssrh_disc where  
yd_prod_offer_id in(100089351,100089352,100089353,100089354,100095244,100096150,100096151,100096152) or  
kd_prod_offer_id in(100089351,100089352,100089353,100089354,100095244,100096150,100096151,100096152)


drop table if exists tmp_yz_liq_1031_1;
create table if not exists tmp_yz_liq_1031_1 as 
select distinct a.serv_id,a.prod_offer_id,a.msinfo_id
from summary_ods_day_city.rpt_comm_cm_msdisc a
where 1=1 and a.par_corp_id='200'
and date_format(a.limit_date,'yyyyMMdd') > '20231030'
and prod_offer_id in(100089351,100089352,100089353,100089354,100095244,100096150,100096151,100096152);

drop table if exists tmp_yz_liq_1031_2;
create table if not exists tmp_yz_liq_1031_2 as 
select a.*,b.prod_type,b.is_vice_card,b.open_date
from tmp_yz_liq_1031_1 a left join dws_yz_rpt_comm_cm_rh_list02 b on a.serv_id=b.serv_id;


drop table if exists tmp_yz_liq_1031_3;
create table if not exists tmp_yz_liq_1031_3 as 
select a.serv_id_kd,a.prod_offer_id_kd,a.msinfo_id,a.open_date_kd,b.serv_id_yd,b.prod_offer_id_yd,b.open_date_yd 
from (select serv_id serv_id_kd,prod_offer_id prod_offer_id_kd,msinfo_id,open_date open_date_kd from tmp_yz_liq_1031_2 where prod_type=40) a
left join (select serv_id serv_id_yd,prod_offer_id prod_offer_id_yd,msinfo_id,open_date open_date_yd from tmp_yz_liq_1031_2 where prod_type=31) b
on a.msinfo_id=b.msinfo_id;

select prod_offer_id_kd,prod_offer_id_yd,count(distinct serv_id_kd) from tmp_yz_liq_1031_3 
group by prod_offer_id_kd,prod_offer_id_yd order by count(distinct serv_id_kd) desc

select distinct serv_id,acc_nbr,prod_offer_id,msinfo_id from 
summary_ods_day_city.rpt_comm_cm_msdisc a
where 1=1 and a.par_corp_id='200'
and date_format(a.limit_date,'yyyyMMdd') > '20231030'
and acc_nbr in(
'18122730017',
'13318868126',
'18922270095')


--20231102 cdap 套餐收入测算
/* select serv_id, 
sum(a0) as sh_qr,--税后确认收入
sum(a0_sq) as sh_sq,--税前确认收入
sum(fee_fm_new) as sh_jbm,--最终基本面收入（不用限制条件，已是全量：移动、宽带、固话、ITV 收入）
sum(a8) as sh_ycx, --一次性税后收入
sum(a9) as sh_jsfc,--结算分成（佣金结算）
sum(a11) as sh_liuliang --流量不清零(流量递延)
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id = 202309
group by serv_id */

--全量号码清单表
drop table if exists tmp_yz_liq_1101_1 purge;
create table if not exists tmp_yz_liq_1101_1  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select rh_tc_id,serv_id,prod_type,prod_id,is_vice_card,prod_type2,is_rh_ykj,is_cz,itv_type
from zone_gz_yz.dwm_yz_tb_comm_cm_all_final 
where par_month_id=202309 and is_cancel_user=0;

--宽带清单表（融合宽带+单宽，剔除ITV）
drop table if exists tmp_yz_liq_1101_2 purge;
create table if not exists tmp_yz_liq_1101_2  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select rh_tc_id,serv_id,prod_type,prod_id,is_vice_card,prod_type2,is_rh_ykj,is_cz,itv_type
from zone_gz_yz.tmp_yz_liq_1101_1 
where prod_type=40 and coalesce(itv_type,-1) not in(0,1);

--更新全量号码收入
drop table if exists tmp_yz_liq_1101_3 purge;
create table if not exists tmp_yz_liq_1101_3  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.sh_qr,b.sh_sq,b.sh_jbm,b.sh_ycx,b.sh_jsfc,b.sh_liuliang
from zone_gz_yz.tmp_yz_liq_1101_1 a  
left join (select serv_id, 
sum(a0) as sh_qr,--税后确认收入
sum(a0_sq) as sh_sq,--税前确认收入
sum(fee_fm_new) as sh_jbm,--最终基本面收入（不用限制条件，已是全量：移动、宽带、固话、ITV 收入）
sum(a8) as sh_ycx, --一次性税后收入
sum(a9) as sh_jsfc,--结算分成（佣金结算）
sum(a11) as sh_liuliang --流量不清零(流量递延)
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id = 202309
group by serv_id) b on a.serv_id=b.serv_id;

--更新宽带清单表 套餐收入
drop table if exists tmp_yz_liq_1101_4 purge;
create table if not exists tmp_yz_liq_1101_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.qr_sr,b.sq_sr,b.jbm_sr,b.ycx_sr,b.jsfc_sr,b.liuliang_sr
from zone_gz_yz.tmp_yz_liq_1101_2 a 
left join (select rh_tc_id,sum(sh_qr) as qr_sr,sum(sh_sq) as sq_sr,sum(sh_jbm) as jbm_sr,
sum(sh_ycx) as ycx_sr,sum(sh_jsfc) as jsfc_sr, sum(sh_liuliang) as liuliang_sr
from tmp_yz_liq_1101_3 group by rh_tc_id) b on a.rh_tc_id =b.rh_tc_id;

--更新单宽套餐收入
drop table if exists tmp_yz_liq_1101_5 purge;
create table if not exists tmp_yz_liq_1101_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
case when coalesce(a.is_rh_ykj,-1)<>1 then b.sh_qr else a.qr_sr end as all_qr_sr,
case when coalesce(a.is_rh_ykj,-1)<>1 then b.sh_sq else a.sq_sr end as all_sq_sr,
case when coalesce(a.is_rh_ykj,-1)<>1 then b.sh_jbm else a.jbm_sr end as all_jbm_sr,
case when coalesce(a.is_rh_ykj,-1)<>1 then b.sh_ycx else a.ycx_sr end as all_ycx_sr,
case when coalesce(a.is_rh_ykj,-1)<>1 then b.sh_jsfc else a.jsfc_sr end as all_jsfc_sr,
case when coalesce(a.is_rh_ykj,-1)<>1 then b.sh_liuliang else a.liuliang_sr end as all_liuliang_sr
from zone_gz_yz.tmp_yz_liq_1101_4 a 
left join tmp_yz_liq_1101_3 b on a.serv_id =b.serv_id and coalesce(b.is_rh_ykj,-1)<>1;

select is_rh_ykj,count(distinct rh_tc_id) tc,count(distinct serv_id) kd_dd,
sum(all_jbm_sr) jbm from tmp_yz_liq_1101_5
where is_cz=1 and prod_id in (950,47,56,999,10000,51,3881,1023,1052,1051,49,1022,
2340,2341,500001200,500001961,500001741,500002660) group by is_rh_ykj


select prod_id,sum(sh_jbm) sr_jbm from tmp_yz_liq_1101_3 
where is_rh_ykj=1 or (coalesce(is_rh_ykj,-1)<>1 and prod_type=40 and coalesce(itv_type,-1)not in(0,1) 
and prod_id in (950,47,56,999,10000,51,3881,1023,1052,1051,49,1022,
2340,2341,500001200,500001961,500001741,500002660))
group by prod_id


宽带到达套餐收入（基本面）：cdap比本地少了(18569949.68)，
	其中：移动少了：(16580350.46)，ITV少了(1823810.10)，固话少了(262413.53),宽带多了87844.74，其他可忽略不计
	1、融合宽带：cdap比本地少(24385040.98)
	2、单宽（剔除ITV）：cdap比本地多了5610813.61 

宽带到达号码量：融合宽带到达量比本地少299646，单宽比本地多299646

原因分析：本地是把所有有套餐关联关系的移动固话ITV（基本面产品）都纳入融合套餐统计总收入，
所以融合套内号码量比cdap新融合口径多，
cdap新融合口径是按销售部确认的紧密融合和松散融合销售品维表判定融合，
因此融合套餐收入少了，单宽收入多了。











--20231102 松散融合改成客户级口径
修改松散融合配置表：
create table zone_gz_yz.dwd_yz_xsb_ssrh_disc_bf_20231102 as select * from zone_gz_yz.dwd_yz_xsb_ssrh_disc;

drop table if exists tmp_dwd_yz_xsb_ssrh_disc;
create table if not exists tmp_dwd_yz_xsb_ssrh_disc as 
select cast(index1  as int) kd_prod_offer_id
,cast(index2  as string) kd_prod_offer_code
,cast(index3  as string) kd_prod_offer_name
,cast(index4  as int) yd_prod_offer_id
,cast(index5  as string) yd_prod_offer_code
,cast(index6  as string) yd_prod_offer_name
,cast(index7  as int) create_date
,cast(index8  as int) flag
from zone_gz_yz_3351225714708480;

insert overwrite table dwd_yz_xsb_ssrh_disc
select kd_prod_offer_id,kd_prod_offer_code,kd_prod_offer_name,yd_prod_offer_id,yd_prod_offer_code,yd_prod_offer_name,create_date,flag
from tmp_dwd_yz_xsb_ssrh_disc;

--修改紧密融合配置表
create table zone_gz_yz.dwd_yz_xsb_wx_jmrh_disc_bf_20231102 as select * from zone_gz_yz.dwd_yz_xsb_wx_jmrh_disc;

drop table tmp_dwd_yz_xsb_wx_jmrh_disc;
create table tmp_dwd_yz_xsb_wx_jmrh_disc as 
select distinct prod_offer_code,offer_name,offer_id from dws_crm_cfguse.dws_offer where city_id=200 
and prod_offer_code in(select distinct prod_offer_code from zone_gz_yz.dwd_yz_xsb_wx_jmrh_disc);

insert overwrite table dwd_yz_xsb_wx_jmrh_disc
select prod_offer_code,offer_name,offer_id
from tmp_dwd_yz_xsb_wx_jmrh_disc;

--20231106  吴啸要求202210主宽入网多维表用11月积分补打
drop table if exists tmp_yz_liq_1106_1;
create table if not exists tmp_yz_liq_1106_1 as 
select a.*,case when a.rh_tc_value in(0,-10,12) then b.rh_tc_value else a.rh_tc_value end as rh_tc_value_bda
from ads_yz_jingfen_zkrw_list a  
left join (select distinct serv_id,rh_tc_value from dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202211) b 
on a.serv_id=b.serv_id 
where a.par_month_id=202210;


alter table zone_gz_yz.ads_yz_jingfen_zkrw_dwb drop if exists partition(par_month_id=202210);
alter table zone_gz_yz.ads_yz_jingfen_zkrw_dwb add if not exists partition(par_month_id=202210);
insert into table zone_gz_yz.ads_yz_jingfen_zkrw_dwb partition(par_month_id=202210)
select 
a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
case when a.serv_grp_type='01' then '政企' when a.serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc,
a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,

case when coalesce(a.rh_tc_value_bda,0)<59 then '[0,59)'  
when coalesce(a.rh_tc_value_bda,0)>=59 and coalesce(a.rh_tc_value_bda,0)<99 then '[59,99)' 
when coalesce(a.rh_tc_value_bda,0)>=99 and coalesce(a.rh_tc_value_bda,0)<129 then '[99,129)' 
when coalesce(a.rh_tc_value_bda,0)>=129 and coalesce(a.rh_tc_value_bda,0)<169 then '[129,169)' 
when coalesce(a.rh_tc_value_bda,0)>=169 and coalesce(a.rh_tc_value_bda,0)<199 then '[169,199)' 
when coalesce(a.rh_tc_value_bda,0)>=199 and coalesce(a.rh_tc_value_bda,0)<229 then '[199,229)' 
when coalesce(a.rh_tc_value_bda,0)>=229 and coalesce(a.rh_tc_value_bda,0)<299 then '[229,299)' 
when coalesce(a.rh_tc_value_bda,0)>=299 and coalesce(a.rh_tc_value_bda,0)<399 then '[299,399)' 
when coalesce(a.rh_tc_value_bda,0)>=399 and coalesce(a.rh_tc_value_bda,0)<699 then '[399,699)'  
when coalesce(a.rh_tc_value_bda,0)>=699 then '699及以上' end jf_dangci,

case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,

count(distinct serv_id) as kdrw_num,
sum(rh_tc_value_bda) taocan_jf
from zone_gz_yz.tmp_yz_liq_1106_1 a 
where a.par_month_id=202210
group by a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
a.is_rh_ykj,a.serv_grp_type,a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,a.rh_tc_value_bda,
a.rh_type_ykj;

select sum(kdrw_num),sum(taocan_jf) from ads_yz_jingfen_zkrw_dwb where par_month_id=202210 
 and is_rh='是' and is_zhuanxian='其他' and kd_desc='普通宽带'
 

--20231107  刘丽娜  临时按主宽入网多维表出9.28-9.30的数
drop table if exists tmp_yz_liq_1107_1;
create table if not exists tmp_yz_liq_1107_1 as 
select a.*,b.open_date
from zone_gz_yz.ads_yz_jingfen_zkrw_list a  
left join (select distinct serv_id,open_date from dwm_yz_tb_comm_cm_all_final where par_month_id=202309) b 
on a.serv_id=b.serv_id 
where a.par_month_id=202309;

drop table if exists tmp_yz_jingfen_zkrw_dwb;
create table if not exists tmp_yz_jingfen_zkrw_dwb as 
select 
a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
case when a.is_rh_ykj=1 then '是' when a.is_rh_ykj=0 then '否' else null end is_rh,
case when a.serv_grp_type='01' then '政企' when a.serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc,
a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,

case when coalesce(a.rh_tc_value,0)<59 then '[0,59)'  
when coalesce(a.rh_tc_value,0)>=59 and coalesce(a.rh_tc_value,0)<99 then '[59,99)' 
when coalesce(a.rh_tc_value,0)>=99 and coalesce(a.rh_tc_value,0)<129 then '[99,129)' 
when coalesce(a.rh_tc_value,0)>=129 and coalesce(a.rh_tc_value,0)<169 then '[129,169)' 
when coalesce(a.rh_tc_value,0)>=169 and coalesce(a.rh_tc_value,0)<199 then '[169,199)' 
when coalesce(a.rh_tc_value,0)>=199 and coalesce(a.rh_tc_value,0)<229 then '[199,229)' 
when coalesce(a.rh_tc_value,0)>=229 and coalesce(a.rh_tc_value,0)<299 then '[229,299)' 
when coalesce(a.rh_tc_value,0)>=299 and coalesce(a.rh_tc_value,0)<399 then '[299,399)' 
when coalesce(a.rh_tc_value,0)>=399 and coalesce(a.rh_tc_value,0)<699 then '[399,699)'  
when coalesce(a.rh_tc_value,0)>=699 then '699及以上' end jf_dangci,

case when a.rh_type_ykj='新宽带新移动' then '是' else '否' end as is_xkxy,

count(distinct serv_id) as kdrw_num,
sum(rh_tc_value) taocan_jf
from zone_gz_yz.tmp_yz_liq_1107_1 a 
where a.par_month_id=202309 and date_format(a.open_date,'yyyyMMdd') between '20230928' and '20230930'
group by a.month_id,a.subst_name,a.branch_name,a.area_name,a.region_type,a.bg_type,a.kd_desc,
a.is_zhuanxian,a.prod_type3,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,
a.is_rh_ykj,a.serv_grp_type,a.offer_name,a.is_sheng_yx,a.is_zhuangwei,a.speed_value,a.rh_tc_value,
a.rh_type_ykj;

select subst_name,
sum(taocan_jf)
from zone_gz.tmp_yz_jingfen_zkrw_dwb
where kd_desc = '普通宽带' 
AND is_zhuanxian = '其他' 
AND is_rh = '是' 
AND coalesce(offer_name, '-1') NOT LIKE '%0时长%' 
AND is_sheng_yx = '是'
AND month_id = '202310'
group by subst_name

--20231129  经分数据导入统一经分多维表
alter table zone_gz_yz.ads_yz_xsb_jf_dwb drop if exists partition(par_month_id=202310,item_id=71127784);
alter table zone_gz_yz.ads_yz_xsb_jf_dwb add if not exists partition(par_month_id=202310,item_id=71127784);
insert into table zone_gz_yz.ads_yz_xsb_jf_dwb partition(par_month_id=202310,item_id=71127784) 
select '划小局向',
'划小营服',
'包区',
'五大网格',
'九大BG',
'宽带类型',
'是否专线',
'低值宽带类型',
'渠道大类',
'渠道小类',
'渠道日报小类',
'是否融合',
'服务分群',
'网点编码',
'网点名称',
'宽带主套餐',
'是否省有效',
'速率',
'套餐价值积分档次',
'是否新宽带新移动 ',
'宽带入网数',
'套餐价值积分',

null as value23,
null as value24,
null as value25,
null as value26,
null as value27,
null as value28,
null as value29,
null as value30,
null as value31,
null as value32,
null as value33,
null as value34,
null as value35,
null as value36,
null as value37,
null as value38,
null as value39,
null as value40,
null as value41,
null as value42,
null as value43,
null as value44,
null as value45,
null as value46,
null as value47,
null as value48,
null as value49,
null as value50,
null as value51,
null as value52,
null as value53,
null as value54,
null as value55,
null as value56,
null as value57,
null as value58,
null as value59,
null as value60,
null as value61,
null as value62,
null as value63,
null as value64,
null as value65,
null as value66,
null as value67,
null as value68,
null as value69,
null as value70,
null as value71,
null as value72,
null as value73,
null as value74,
null as value75,
null as value76,
null as value77,
null as value78,
null as value79,
null as value80,
null as value81,
null as value82,
null as value83,
null as value84,
null as value85,
null as value86,
null as value87,
null as value88,
null as value89,
null as value90,
null as value91,
null as value92,
null as value93,
null as value94,
null as value95,
null as value96,
null as value97,
null as value98,
null as value99,
null as value100,
null as value101,
null as value102,
null as value103,
null as value104,
null as value105,
null as value106,
null as value107,
null as value108,
null as value109,
null as value110,
null as value111,
null as value112,
null as value113,
null as value114,
null as value115,
null as value116,
null as value117,

'表头' as value118,
'宽带入网多维表' as value119,
'吴啸' as value120

union all 
select subst_name,
branch_name,
area_name,
region_type,
bg_type,
kd_desc,
is_zhuanxian,
prod_type3,
channel_type_2011,
channel_subtype_2011,
channel_subtype_flag,
is_rh,
serv_grp_type_desc,
channel_nbr,
channel_name,
kd_prod_offer_name,
is_sheng_yx,
cast(speed_value as string),
jf_dangci,
is_xkxy,
cast(kdrw_num as string),
cast(taocan_jf as string),

null as value23,
null as value24,
null as value25,
null as value26,
null as value27,
null as value28,
null as value29,
null as value30,
null as value31,
null as value32,
null as value33,
null as value34,
null as value35,
null as value36,
null as value37,
null as value38,
null as value39,
null as value40,
null as value41,
null as value42,
null as value43,
null as value44,
null as value45,
null as value46,
null as value47,
null as value48,
null as value49,
null as value50,
null as value51,
null as value52,
null as value53,
null as value54,
null as value55,
null as value56,
null as value57,
null as value58,
null as value59,
null as value60,
null as value61,
null as value62,
null as value63,
null as value64,
null as value65,
null as value66,
null as value67,
null as value68,
null as value69,
null as value70,
null as value71,
null as value72,
null as value73,
null as value74,
null as value75,
null as value76,
null as value77,
null as value78,
null as value79,
null as value80,
null as value81,
null as value82,
null as value83,
null as value84,
null as value85,
null as value86,
null as value87,
null as value88,
null as value89,
null as value90,
null as value91,
null as value92,
null as value93,
null as value94,
null as value95,
null as value96,
null as value97,
null as value98,
null as value99,
null as value100,
null as value101,
null as value102,
null as value103,
null as value104,
null as value105,
null as value106,
null as value107,
null as value108,
null as value109,
null as value110,
null as value111,
null as value112,
null as value113,
null as value114,
null as value115,
null as value116,
null as value117,

'数据' as value118,
'宽带入网多维表' as value119,
'吴啸' as value120
from ads_yz_jingfen_zkrw_dwb where par_month_id=202310;

--20231201  低值宽带类型配置表 修正门禁宽带销售品编码和名称
drop table if exists dwd_dim_dzkd_offer_bf_20231201;
create table dwd_dim_dzkd_offer_bf_20231201 as select * from dwd_dim_dzkd_offer;

drop table if exists tmp_dwd_dim_dzkd_offer_xz;
create table tmp_dwd_dim_dzkd_offer_xz as 
select cast(index1  as int) type_id
,cast(index2  as string) type
,cast(index3  as int) prod_offer_id
,cast(index4  as string) prod_offer_code
,cast(index5  as string) prod_offer_name

from zone_gz_yz_3351225714708480;

insert overwrite table dwd_dim_dzkd_offer
select type_id,type,prod_offer_id,prod_offer_code,prod_offer_name  
from tmp_dwd_dim_dzkd_offer_xz;


--20231204  陈浩南  当月商企在网套餐数
drop table if exists zone_gz_yz.xxx purge;
create table zone_gz_yz.xxx 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct cust_nbr,cust_id,msinfo_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
join zone_gz_yz.dwd_yz_dim_shangqi_dx b on a.prod_offer_id=b.offer_id  --商企套餐维表
where 1=1 ${v_par_month} and par_corp_id='200'
and date_format(limit_date,'yyyyMMdd') > ${stat_day};

--20231208  吴啸  副宽号码的销售品
--抽取副宽号码
drop table if exists tmp_wuxiao_1 purge;
create table tmp_wuxiao_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select acc_nbr, --接入号
serv_id,
prod_type2,
is_yx_kd,--是否省有效
is_cz  --是否到达
from view_ads_yz_tb_comm_cm_all_final 
where prod_type2=80 --副宽
and is_cancel_user=0 --号码在网
and par_month_id=202311;

--抽取副宽对应销售品
drop table if exists tmp_wuxiao_2 purge;
create table tmp_wuxiao_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.acc_nbr,--接入号
date_format(a.open_date,'yyyyMMdd') open_date,--生效时间
date_format(a.limit_date,'yyyyMMdd') limit_date,--到期时间
date_format(a.create_date,'yyyyMMdd') create_date,--开通时间
a.prod_offer_id,--销售品ID
a.prod_offer_code,--销售品编码
a.prod_offer_name, --销售品名称

b.is_yx_kd,--是否省有效
b.is_cz --是否到达
from view_ads_yz_rpt_comm_cm_msdisc_final a 
join tmp_wuxiao_1 b on a.serv_id=b.serv_id --限制副宽号码
where a.prod_offer_code in('DM0001-709-1-8','DM0001-709-1-9') 
and date_format(a.limit_date,'yyyyMMdd') > '20231130' --到期时间
and a.par_month_id=202311;

select * from tmp_wuxiao_2


--20231209  蔡婷  宽带活跃移动不活跃
drop table if exists zone_gz_yz.tmp_yz_ct_1 purge;
create table zone_gz_yz.tmp_yz_ct_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when b.is_active_user = 1 then '是' else '否' end as is_hy_kd
from zone_gz_yz.ads_yz_bd129_sdjd_list a  
left join summary_ods_month_city.TB_COMM_CM_DATA_MON  b on a.serv_id=b.serv_id and b.PAR_CORP_ID='200' and b.PAR_MONTH_ID='${sum_month}' 
where a.par_month_id=$sum_month;

--20230105  吕汶丽  有效宽带到达
drop table if exists tmp_liq_2023_kddd;
create table tmp_liq_2023_kddd as 
select a.par_month_id,a.subst_name,a.branch_name,a.area_name,a.bg_type,a.bu_type,a.region_type,a.six_market,a.serv_id,a.kd_desc,a.speed_value,b.is_yx
from dwm_yz_tb_comm_cm_all_mon_final a 
left join summary_ods_month_city.TB_COMM_CM_DATA_MON  b on a.serv_id=b.serv_id and b.PAR_CORP_ID='200' and a.PAR_MONTH_ID=b.PAR_MONTH_ID 
where a.par_month_id between 202212 and 202312
and a.prod_type=40 --宽带
and a.kd_desc in ('普通宽带','校园翼起来')
and a.is_cancel_user=0
and a.is_cz=1 --到达
;

drop table if exists tmp_liq_2023_kddd_2;
create table tmp_liq_2023_kddd_2 as
select a.par_month_id,subst_name,branch_name,area_name,bg_type,bu_type,region_type,six_market,
count(a.serv_id) v1,
count(case when kd_desc='普通宽带' then a.serv_id else null end) v2,
count(case when kd_desc='校园翼起来' then a.serv_id else null end) v3,
count(case when kd_desc='普通宽带' and speed_value>=1000 and b.serv_id is null then a.serv_id else null end) v4
from tmp_liq_2023_kddd a
left join (
  select serv_id,par_month_id,row_number() over(partition by serv_id,par_month_id order by limit_date desc) row_num
  from dwd_yz_rpt_comm_cm_msdisc_mon_final 
  where prod_offer_id in(100052461,100052460)
  and date_format(limit_date,'yyyyMM')>=par_month_id
  and par_month_id between 202212 and 202312) b on a.serv_id=b.serv_id and b.row_num=1 and a.par_month_id=b.par_month_id
  where a.is_yx=1
group by a.par_month_id,subst_name,branch_name,area_name,bg_type,bu_type,region_type,six_market;

--营服到达
select subst_name,branch_name
,sum(case when par_month_id=202212 then v1 else 0 end)
,sum(case when par_month_id=202212 then v2 else 0 end)
,sum(case when par_month_id=202212 then v3 else 0 end)
,sum(case when par_month_id=202212 then v4 else 0 end)
,sum(case when par_month_id=202301 then v1 else 0 end)
,sum(case when par_month_id=202301 then v2 else 0 end)
,sum(case when par_month_id=202301 then v3 else 0 end)
,sum(case when par_month_id=202301 then v4 else 0 end)
,sum(case when par_month_id=202302 then v1 else 0 end)
,sum(case when par_month_id=202302 then v2 else 0 end)
,sum(case when par_month_id=202302 then v3 else 0 end)
,sum(case when par_month_id=202302 then v4 else 0 end)
,sum(case when par_month_id=202303 then v1 else 0 end)
,sum(case when par_month_id=202303 then v2 else 0 end)
,sum(case when par_month_id=202303 then v3 else 0 end)
,sum(case when par_month_id=202303 then v4 else 0 end)
,sum(case when par_month_id=202304 then v1 else 0 end)
,sum(case when par_month_id=202304 then v2 else 0 end)
,sum(case when par_month_id=202304 then v3 else 0 end)
,sum(case when par_month_id=202304 then v4 else 0 end)
,sum(case when par_month_id=202305 then v1 else 0 end)
,sum(case when par_month_id=202305 then v2 else 0 end)
,sum(case when par_month_id=202305 then v3 else 0 end)
,sum(case when par_month_id=202305 then v4 else 0 end)
,sum(case when par_month_id=202306 then v1 else 0 end)
,sum(case when par_month_id=202306 then v2 else 0 end)
,sum(case when par_month_id=202306 then v3 else 0 end)
,sum(case when par_month_id=202306 then v4 else 0 end)
,sum(case when par_month_id=202307 then v1 else 0 end)
,sum(case when par_month_id=202307 then v2 else 0 end)
,sum(case when par_month_id=202307 then v3 else 0 end)
,sum(case when par_month_id=202307 then v4 else 0 end)
,sum(case when par_month_id=202308 then v1 else 0 end)
,sum(case when par_month_id=202308 then v2 else 0 end)
,sum(case when par_month_id=202308 then v3 else 0 end)
,sum(case when par_month_id=202308 then v4 else 0 end)
,sum(case when par_month_id=202309 then v1 else 0 end)
,sum(case when par_month_id=202309 then v2 else 0 end)
,sum(case when par_month_id=202309 then v3 else 0 end)
,sum(case when par_month_id=202309 then v4 else 0 end)
,sum(case when par_month_id=202310 then v1 else 0 end)
,sum(case when par_month_id=202310 then v2 else 0 end)
,sum(case when par_month_id=202310 then v3 else 0 end)
,sum(case when par_month_id=202310 then v4 else 0 end)
,sum(case when par_month_id=202311 then v1 else 0 end)
,sum(case when par_month_id=202311 then v2 else 0 end)
,sum(case when par_month_id=202311 then v3 else 0 end)
,sum(case when par_month_id=202311 then v4 else 0 end)
,sum(case when par_month_id=202312 then v1 else 0 end)
,sum(case when par_month_id=202312 then v2 else 0 end)
,sum(case when par_month_id=202312 then v3 else 0 end)
,sum(case when par_month_id=202312 then v4 else 0 end)
from tmp_liq_2023_kddd_2
group by subst_name,branch_name


select bg_type,bu_type
,sum(case when par_month_id=202212 then v1 else 0 end)
,sum(case when par_month_id=202212 then v2 else 0 end)
,sum(case when par_month_id=202212 then v3 else 0 end)
,sum(case when par_month_id=202212 then v4 else 0 end)
,sum(case when par_month_id=202301 then v1 else 0 end)
,sum(case when par_month_id=202301 then v2 else 0 end)
,sum(case when par_month_id=202301 then v3 else 0 end)
,sum(case when par_month_id=202301 then v4 else 0 end)
,sum(case when par_month_id=202302 then v1 else 0 end)
,sum(case when par_month_id=202302 then v2 else 0 end)
,sum(case when par_month_id=202302 then v3 else 0 end)
,sum(case when par_month_id=202302 then v4 else 0 end)
,sum(case when par_month_id=202303 then v1 else 0 end)
,sum(case when par_month_id=202303 then v2 else 0 end)
,sum(case when par_month_id=202303 then v3 else 0 end)
,sum(case when par_month_id=202303 then v4 else 0 end)
,sum(case when par_month_id=202304 then v1 else 0 end)
,sum(case when par_month_id=202304 then v2 else 0 end)
,sum(case when par_month_id=202304 then v3 else 0 end)
,sum(case when par_month_id=202304 then v4 else 0 end)
,sum(case when par_month_id=202305 then v1 else 0 end)
,sum(case when par_month_id=202305 then v2 else 0 end)
,sum(case when par_month_id=202305 then v3 else 0 end)
,sum(case when par_month_id=202305 then v4 else 0 end)
,sum(case when par_month_id=202306 then v1 else 0 end)
,sum(case when par_month_id=202306 then v2 else 0 end)
,sum(case when par_month_id=202306 then v3 else 0 end)
,sum(case when par_month_id=202306 then v4 else 0 end)
,sum(case when par_month_id=202307 then v1 else 0 end)
,sum(case when par_month_id=202307 then v2 else 0 end)
,sum(case when par_month_id=202307 then v3 else 0 end)
,sum(case when par_month_id=202307 then v4 else 0 end)
,sum(case when par_month_id=202308 then v1 else 0 end)
,sum(case when par_month_id=202308 then v2 else 0 end)
,sum(case when par_month_id=202308 then v3 else 0 end)
,sum(case when par_month_id=202308 then v4 else 0 end)
,sum(case when par_month_id=202309 then v1 else 0 end)
,sum(case when par_month_id=202309 then v2 else 0 end)
,sum(case when par_month_id=202309 then v3 else 0 end)
,sum(case when par_month_id=202309 then v4 else 0 end)
,sum(case when par_month_id=202310 then v1 else 0 end)
,sum(case when par_month_id=202310 then v2 else 0 end)
,sum(case when par_month_id=202310 then v3 else 0 end)
,sum(case when par_month_id=202310 then v4 else 0 end)
,sum(case when par_month_id=202311 then v1 else 0 end)
,sum(case when par_month_id=202311 then v2 else 0 end)
,sum(case when par_month_id=202311 then v3 else 0 end)
,sum(case when par_month_id=202311 then v4 else 0 end)
,sum(case when par_month_id=202312 then v1 else 0 end)
,sum(case when par_month_id=202312 then v2 else 0 end)
,sum(case when par_month_id=202312 then v3 else 0 end)
,sum(case when par_month_id=202312 then v4 else 0 end)
from tmp_liq_2023_kddd_2
group by bg_type,bu_type


--20240110  尤鸿贵  XQGZ2024010600234
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;   -- 关闭向量化查询
set hive.vectorized.execution.reduce.enabled=false; -- 关闭向量化查询
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;

drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select par_month_id  --收入账期
,rw_month  --入网月份
,serv_id  
,sum(a0) as sh_qr  --税后确认收入
,sum(a0_sq) as sq_qr  --税前确认收入
from dwm_srhx_serv_list_mon_final 
where par_month_id>=202201 and par_month_id<=202312 
group by par_month_id,rw_month,serv_id;

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case when prod_type=30 then '移动' when prod_type=40 then '宽带' when prod_type=10 then '固话' else '其他' end as prod_type_desc
,yd_prod_type1 
,kd_desc 
,prod_id 
,case when payment_id=1 then '后付费' else '预付费' end as payment_desc
,channel_type
,channel_subst_name
,case when prod_type=40 and is_rh_ykj>0 then '融合' when prod_type=40 and is_rh_ykj=0 then '单宽' else null end as kd_rh_lx
from tmp_yz_liq_1 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and a.rw_month=b.par_month_id and b.is_new_user=1;


drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.prod_name 
from tmp_yz_liq_2 a 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) b on a.prod_id=b.prod_id;

--20230109  刘丽娜  宽带留存
--新增字段只需要把以下脚本的“--,新增字段名”改成“,新增字段名”。如需要新增价值积分，则改成“,jz_points”

drop table if exists tmp_wuxiao_kdrw_liucun;
create table tmp_wuxiao_kdrw_liucun as 
SELECT 
par_month_id rw_month,
serv_id,
region_type, 
is_rh_ykj, 
prod_type3,
jz_points
,rh_tc_value
--,新增字段名
FROM zone_gz.view_ads_yz_kd_new_list 
WHERE par_month_id IN (202301,202302,202303,202304,202305,202306,202307,202308,202309,202310,202311,202312) -- 月份 
AND kd_desc = '普通宽带' 
AND coalesce(prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(kd_prod_offer_name, '-1') NOT LIKE '%0时长%';


drop table if exists tmp_wuxiao_kdrw_liucun2;
create table tmp_wuxiao_kdrw_liucun2 as 
select a.*,b.par_month_id tj_month,b.is_cz
from tmp_wuxiao_kdrw_liucun a
left join
(select par_month_id,is_cz,serv_id from view_ads_yz_tb_comm_cm_all_final) b 
on a.serv_id=b.serv_id and a.rw_month<=b.par_month_id;

drop table if exists tmp_wuxiao_kdrw_liucun3;
create table tmp_wuxiao_kdrw_liucun3 as 
select rw_month,--入网月份
tj_month,--统计月份
region_type,--五大网格（入网状态）
is_rh_ykj,--是否融合（入网状态）
prod_type3,--低值宽带类型（入网状态）
--,新增字段名
count(1) num,--入网量（主宽剔除专线、城域网和0时长）
count(case when is_cz=1 then serv_id else null end) num_cz  --留存量
,sum(case when is_cz=1 then jz_points else 0 end) jz_points_cz --留存月出账的价值积分总和（价值积分是入网时的积分）
,sum(case when is_cz=1 then rh_tc_value else 0 end) rh_tc_value_cz --留存月出账的套餐积分总和（套餐积分是入网时的积分）
from tmp_wuxiao_kdrw_liucun2 
group by rw_month,tj_month,region_type,is_rh_ykj,prod_type3
--,新增字段名
;


select 
rw_month,--入网月份
tj_month,--统计月份
region_type,--五大网格（入网状态）
is_rh_ykj,--是否融合（入网状态）
prod_type3,--低值宽带类型（入网状态）
--,新增字段名
num,--入网量（主宽剔除专线、城域网和0时长）
num_cz  --留存量 
,jz_points_cz --留存月出账的价值积分总和（价值积分是入网时的积分）
,rh_tc_value_cz --留存月出账的套餐积分总和（套餐积分是入网时的积分）
from tmp_wuxiao_kdrw_liucun3

--20240112 林正欣  宽带离网
--202312在网宽带
drop table if exists tmp_th_lzx_1 purge;
create table tmp_th_lzx_1 as 
select 
serv_id 
,is_rh_ykj  --是否融合（1为是）
,rh_tc_value --套餐价值积分
,jz_points  --号码价值积分

from view_ads_yz_tb_comm_cm_all_final a 
where a.par_month_id=202312 --统计月份
and a.is_cancel_user=0  --在网
and a.prod_type=40  --宽带
and a.subst_name='天河分公司'
;

--202401拆机宽带
drop table if exists tmp_th_lzx_2 purge;
create table tmp_th_lzx_2 as 
select a.branch_name --划小营服
,a.area_name  --包区
,a.cell_code --网格单元编码
,a.cell_name  --网格单元名称
,a.serv_id
,a.acc_nbr  --号码

,b.is_rh_ykj  --是否融合（1为是）
,b.rh_tc_value --套餐价值积分
,b.jz_points  --号码价值积分

from view_ads_yz_tb_comm_cm_all_final a 
left join tmp_th_lzx_1 b on a.serv_id=b.serv_id  
where a.par_month_id=202401 --统计月份
and a.is_cancel_user=1  --拆机
and a.prod_type=40  --宽带
and a.subst_name='天河分公司'
--and a.kd_desc='普通宽带'  --主流宽带
--and a.prod_type2 not in(50)  --剔除ITV
--and a.prod_type2 not in(60,70,71) --剔除专线
;

select 
a.branch_name --划小营服
,a.area_name  --包区
,a.cell_code --网格单元编码
,a.cell_name  --网格单元名称
,a.is_rh_ykj --上月是否融合
,count(distinct serv_id) --宽带拆机数
,sum(rh_tc_value) --拆机宽带套餐积分
,sum(jz_points) --拆机宽带号码价值积分
from tmp_th_lzx_2 a 
group by branch_name,area_name,cell_code,cell_name,is_rh_ykj


--20240112  尤鸿贵 销售品办理量和销售品积分
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false; -- 关闭向量化查询
set hive.auto.convert.join=false;
set hive.map.aggr=false;
	
drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.serv_id,a.prod_offer_id,b.prod_offer_code,date_format(a.subs_stat_date,'yyyyMMdd') as create_date,a.salestaff_channel_id,
row_number() over(partition by a.serv_id order by a.subs_stat_date desc) row_num  
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer where city_id='200') b on a.prod_offer_id=b.offer_id
where 1=1 and a.par_month_id between 202301 and 202312 and  a.subs_stat = '301200' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')
and date_format(a.subs_stat_date,'yyyy') = '2023'
and a.action_id in( 1292,6200 )
and a.prod_offer_id in(500067281,500067341,500067345,500068375,500068376,500069359,500067344,500067346,500068377,500070085) 
;

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.data_type,b.score_1
from tmp_yz_liq_1 a 
left join summary_jf_szx.ads_tb_score_disc_config_all b on a.prod_offer_id=b.prod_offer_id;

drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.channel_type 
from tmp_yz_liq_2 a 
left join zone_gz_yz.dwd_yz_sale_outlers_final b on a.salestaff_channel_id=b.channel_id;

drop table if exists zone_gz_yz.tmp_yz_liq_4 purge;
create table zone_gz_yz.tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.prod_offer_code,a.data_type,a.score_1,a.channel_type,cast(cast(a.create_date as int)/100 as int) as create_month,
count(distinct serv_id) num from tmp_yz_liq_3 a  
group by a.prod_offer_code,a.data_type,a.score_1,a.channel_type,cast(cast(a.create_date as int)/100 as int);

drop table if exists zone_gz_yz.tmp_yz_liq_5 purge;
create table zone_gz_yz.tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.prod_offer_code,a.data_type,a.score_1,a.channel_type,a.create_date,
count(distinct serv_id) from tmp_yz_liq_3 a  group by a.prod_offer_code,a.data_type,a.score_1,a.channel_type,a.create_date;

--20240115  陈海宁  12月的划小经营数据
 select subst_id,subst_name,branch_id,branch_name
 ,cast(sum(a0)/10000 as decimal(22,2)) v1
 ,cast(sum(fee_fm_new)/10000 as decimal(22,2)) v2  
 from dwm_srhx_serv_list_mon_final 
 where par_month_id=202311 and branch_id in 
 (940186488,500034,940289521,940286954,940289520,940185534,940185532,999214,3000023354,11605,
 11606,940289512,999204,940289505,999075,999183,11388,940289524,940286949,999072,940286973,11380,
 940289522,940286951,10048,940164424,940289502,940090842,940289517,3000043698,999071,3000052891,
 940289519,999045,100272416,999213,940289509,940162559,940289504,999207,10118,11608,999048,940289499,
 10126,11482,940289514,940289515,999069,10121,11386,940289501,999046,999217,940286950,940091733,
 940286952,940286961,100000173,940286959,11389,11545,940289503,940289518,11564,100000232,940090860,
 11390,940286977,1625007997,10120,1625010454,11604,940286974,100000357,999187,940128719,940289508,
 3000057436,999102,999068,11637,940186487,999073,3000043699,940286981,940289513,100000359,1625010461,
 940286954,10129,940289500,999047,1625010300,940185533,940048628,999212,940289510,100268401,11400,
 10124,999044,940190574,940289530,11392,6411,999188,940289507,940289506,999070,999101,999182,
 100000238,213,100000605,940286956,11655,100000236,940289511,10123,1625009110,940286982,940286960,
 100000609,940190573,3000057434,999206,100000239,11511,1625008706,100000234,999099,999208,940289528,
 999043,100000240,999215,1114930,1114931,940190575,940289526,11379,999203,999184,3000057437,940289527,
 3000057435,999074,999042,11612,12180,3000058363,940289497,940289525,3000057433,940185531,11573,11401,10125,940286194,
 940091546,940286972,11558,940289498,999205,940286955,940286979,100000607,100321965)
 group by subst_id,subst_name,branch_id,branch_name order by branch_id 
 
--20240116  XQGZ2024011101866  白云宽带当月拆机网格维度统计数
drop table if exists tmp_by_cell_kdcj_dwb_1 purge;
create table tmp_by_cell_kdcj_dwb_1 as 
select serv_id,kd_desc,
(case when six_market = 1 then '校园市场' 
when six_market = 2 then '农村市场' 
when six_market = 3 then '行客市场'
when six_market = 4 then '商客市场'
when six_market = 5 then '城市家庭' 
when six_market = 6 then '流动市场' end ) as six_market_desc,
serv_grp_type,
(case when wl_cancel_type in ('103') then '主动拆机'
when wl_cancel_type in ('116') then '欠费拆机' else '' end ) as wl_cancel_type_desc,
date_format(wl_cancel_subs_stat_date,'yyyyMMdd') as cj_date,
cell_id,cell_code,cell_name,region_type,is_dial_fiber,speed_value,branch_name
from view_by_ads_yz_tb_comm_cm_all_final  
where par_month_id in ('202312')
and date_format(wl_cancel_subs_stat_date,'yyyyMMdd') between '20231201' and '20231231'
and prod_type=40 --全部宽带
and is_wl_cancel_user=1 
and subst_name='白云分公司';


drop table if exists tmp_by_cell_kdcj_dwb_2 purge;
create table tmp_by_cell_kdcj_dwb_2 as 
select branch_name,cell_id,cell_code,cell_name,
count(distinct serv_id  ) as value1,--月拆机用户数
---市场细分维度
count(distinct case when kd_desc in ('普通宽带') then serv_id else null end  ) as value2,--主流宽带-月拆机用户数
--按速率
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 0 then serv_id else null end ) as value5,                         --铜线接入
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 1 and speed_value < 100 then serv_id else null end) as value6,    --100M以下
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 1 and speed_value = 100 then serv_id else null end) as value7,    --100M
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 1 and speed_value = 200 then serv_id else null end) as value8,    --200M
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 1 and speed_value = 300 then serv_id else null end) as value9,    --300M
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 1 and speed_value = 500 then serv_id else null end) as value10,   --500M
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 1 and speed_value >=1000 then serv_id else null end) as value11,  --1000M及以上
--5大网格
count(distinct case when kd_desc in ('普通宽带') and region_type = '城市家庭'  then SERV_ID end) as value12,
count(distinct case when kd_desc in ('普通宽带') and region_type = '城中村/农村' then SERV_ID end) as value13, 
count(distinct case when kd_desc in ('普通宽带') and region_type = '专业市场'  then SERV_ID end) as value14,
count(distinct case when kd_desc in ('普通宽带') and region_type = '商务楼宇'  then SERV_ID end) as value15,
count(distinct case when kd_desc in ('普通宽带') and region_type = '产业园区'  then SERV_ID end) as value16,
count(distinct case when kd_desc in ('普通宽带') and region_type = '其他'    then SERV_ID end) as value17,
count(distinct case when kd_desc in ('普通宽带') and serv_grp_type = '02' then SERV_ID end) as value18,  --公众
count(distinct case when kd_desc in ('普通宽带') and serv_grp_type = '01' then SERV_ID end) as value19  --政企
from tmp_by_cell_kdcj_dwb_1 
where 1=1 
--and six_market_desc='商客市场' --六大细分市场：校园市场/农村市场/行客市场/商客市场/城市家庭/流动市场
--and wl_cancel_type_desc='主动拆机'  --拆机类型：欠费拆机/主动拆机
group by branch_name,cell_id,cell_code,cell_name;

drop table if exists tmp_by_cell_kdcj_dwb_3 purge;
create table tmp_by_cell_kdcj_dwb_3 as 
select branch_name,cell_id,cell_code,cell_name, 
value1,value2,value5,value6,value7,value8,value9,value10, 
value11,value12,value13,value14,value15,value16,value17,value18,value19, 
row_number() over(order by cell_code ) as paixu 
from tmp_by_cell_kdcj_dwb_2;


SELECT * FROM tmp_by_cell_kdcj_dwb_3 WHERE paixu >= 1 AND paixu <= 600 LIMIT 1000;
SELECT * FROM tmp_by_cell_kdcj_dwb_3 WHERE paixu > 600 LIMIT 1000;

--20230115  手机城网点新增业务收入
--取全年有销售品订单的号码，取竣工时间最晚的一条
drop table if exists tmp_liq_1 purge;
create table tmp_liq_1 as 
select par_month_id,a.serv_id,a.salestaff_channel_id,
row_number() over(partition by a.serv_id order by a.subs_stat_date desc) row_num  
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where 1=1 and a.par_month_id between 202201 and 202212 and  a.subs_stat = '301200' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')
and date_format(a.subs_stat_date,'yyyy') = '2022'
and a.action_id in( 1292,6200 );

--取全年有订单的号码，取竣工时间最晚的一条
drop table if exists tmp_liq_2 purge;
create table tmp_liq_2 as
select par_month_id,a.serv_id,a.salestaff_channel_id,
row_number() over(partition by a.serv_id order by a.subs_stat_date desc) row_num  
from dwm_yz_rpt_comm_ba_subs_mon_final a 
where 1=1 and a.par_month_id between 202201 and 202212 and  a.subs_stat = '301200' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')
and date_format(a.subs_stat_date,'yyyy') = '2022' 
and serv_id not in(select distinct serv_id from tmp_liq_1 where row_num=1);

drop table if exists tmp_liq_3 purge;
create table tmp_liq_3 as
select par_month_id,serv_id,salestaff_channel_id from tmp_liq_1 where row_num=1 
union all 
select par_month_id,serv_id,salestaff_channel_id from tmp_liq_2 where row_num=1;

drop table if exists tmp_liq_4 purge;
create table tmp_liq_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select a.*,b.channel_nbr 
from tmp_liq_3 a 
left join zone_gz_yz.dwd_yz_sale_outlers_mon_final b on a.salestaff_channel_id=b.channel_id and a.par_month_id=b.par_month_id;

drop table if exists tmp_liq_5 purge;
create table tmp_liq_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select serv_id, 
sum(a0) as sh_qr --税后确认收入
--sum(a0_sq) as sh_sq,--税前确认收入
--sum(fee_fm_new) as sh_jbm,--最终基本面收入（不用限制条件，已是全量：移动、宽带、固话、ITV 收入）
--sum(a8) as sh_ycx --一次性税后收入
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id >= 202201 and par_month_id<=202212
group by serv_id;

drop table if exists tmp_liq_6 purge;
create table tmp_liq_6
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select a.*,b.sh_qr 
from tmp_liq_4 a left join tmp_liq_5 b on a.serv_id=b.serv_id 
;

drop table if exists tmp_liq_7 purge;
create table tmp_liq_7
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select serv_id, 
sum(a0) as sh_qr_all --税后确认收入
--sum(a0_sq) as sh_sq,--税前确认收入
--sum(fee_fm_new) as sh_jbm,--最终基本面收入（不用限制条件，已是全量：移动、宽带、固话、ITV 收入）
--sum(a8) as sh_ycx --一次性税后收入
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id >= 202201 and par_month_id<=202312
group by serv_id;

drop table if exists tmp_liq_8 purge;
create table tmp_liq_8
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select a.*,b.sh_qr_all 
from tmp_liq_6 a left join tmp_liq_7 b on a.serv_id=b.serv_id 
;

drop table if exists tmp_liq_2022 purge;
create table tmp_liq_2022
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select channel_nbr,sum(sh_qr) qr_sh_sr ,sum(sh_qr_all) qr_sh_sr_all
from tmp_liq_8
where channel_nbr in(
'4401151478923','4401061458575','4401111179723','4401121469154','4401121470432','4401111171827','4401141181534',
'4401051400099','4401111429087','4401001318580','4401151403570','4401051168703','4401831274778','4401131352276',
'4401151332112','4401001477538','4401151346655','4401111180985','4401001779083','4401151168431','4401151180189',
'4401151251693','4401061375749','4401141534519','4401001424015','4401121460251','4401111123958','4401111181648',
'4401111169266','4401111173850','4401111184155','4401111115362','4401111441082','4401001227260','4401111168423',
'4401111052749','4401001477546','4401111491250','4401121518148','4401031499634','4401111494845','4401131351869')
group by channel_nbr;

--20230116  XQGZ2024010300478  

202201-202312新增合约数量汇总表--ads_yz_sjc_sryj_rpt，分区字段year_id
202201-202312新增合约税后收入汇总表--ads_yz_sjc_sryj_sr_rpt，分区字段year_id

tmp_xyzuizhong 23年号码在23年的收入
tmp_xyzuizhong1 22年的号码在22年的收入
tmp_xyzuizhong3  22年的号码在22-23收入

drop table if exists tmp_liq_D purge;
create table tmp_liq_D as 
select * from zone_gz_yz_3351225714708480;

drop table if exists tmp_liq_G purge;
create table tmp_liq_G as 
select * from zone_gz_yz_3351225714708480;

drop table if exists tmp_liq_I purge;
create table tmp_liq_I as 
select * from zone_gz_yz_3351225714708480;

drop table if exists tmp_liq_L purge;
create table tmp_liq_L as 
select * from zone_gz_yz_3351225714708480;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_liq_sjc_sr_1 purge;
create table tmp_liq_sjc_sr_1 as 
select xsd_code as channel_nbr
,`_c2` as num_C,cast(0.00 as decimal(22,2)) as num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M 
from ads_yz_sjc_sryj_rpt 
where year_id=2022;

insert into table tmp_liq_sjc_sr_1 
select index1
,cast(0.00 as decimal(22,2)) num_C,index2 as num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M
from tmp_liq_D;

insert into table tmp_liq_sjc_sr_1 
select xsd_code
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,`_c2` as num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M
from ads_yz_sjc_sryj_sr_rpt 
where year_id=2022 ;

insert into table tmp_liq_sjc_sr_1 
select channel_nbr
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,`_c1` as num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M
from tmp_xyzuizhong1; 

insert into table tmp_liq_sjc_sr_1
select index1
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,index2 as num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M
from tmp_liq_G;

insert into table tmp_liq_sjc_sr_1
select xsd_code as channel_nbr
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,`_c2` as num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M 
from ads_yz_sjc_sryj_rpt 
where year_id=2023;

insert into table tmp_liq_sjc_sr_1
select index1
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,index2 as num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M
from tmp_liq_I;

insert into table tmp_liq_sjc_sr_1
select xsd_code
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,`_c2` as num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M
from ads_yz_sjc_sryj_sr_rpt 
where year_id=2023 ;

insert into table tmp_liq_sjc_sr_1
select channel_nbr
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,`_c1` as num_K,cast(0.00 as decimal(22,2)) num_L
,cast(0.00 as decimal(22,2)) num_M
from tmp_xyzuizhong ;

insert into table tmp_liq_sjc_sr_1
select index1
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,index2 as num_L
,cast(0.00 as decimal(22,2)) num_M
from tmp_liq_L ;

insert into table tmp_liq_sjc_sr_1
select channel_nbr
,cast(0.00 as decimal(22,2)) num_C,cast(0.00 as decimal(22,2)) num_D
,cast(0.00 as decimal(22,2)) num_E,cast(0.00 as decimal(22,2)) num_F
,cast(0.00 as decimal(22,2)) num_G,cast(0.00 as decimal(22,2)) num_H
,cast(0.00 as decimal(22,2)) num_I,cast(0.00 as decimal(22,2)) num_J
,cast(0.00 as decimal(22,2)) num_K,cast(0.00 as decimal(22,2)) num_L
,fee_3 as num_M
from tmp_xyzuizhong3;

drop table if exists tmp_liq_sjc_sr purge;
create table tmp_liq_sjc_sr as 
select channel_nbr
,sum(num_C),sum(num_D)
,sum(num_E),sum(num_F)
,sum(num_G),sum(num_H)
,sum(num_I),sum(num_J)
,sum(num_K),sum(num_L)
,sum(num_M) 
FROM tmp_liq_sjc_sr_1 group by channel_nbr order by channel_nbr;

--20240119  XQGZ2024011801413
提数口径：
1、上网时间>=60分钟；
2、省口径到达（出账）；
3、受理代收费用户标识（DM0002-A01，2012年二季度校园翼起来宽带代收费）。
需输出字段：
1、接入号；2、多媒体账号；3、分局；4、入网时间；5、当前状态；6、停机时间；7、是否受理销售品DM0002-A018；
8、当月上网时长(省口径)；9、是否省口径到达；10、域名

取数逻辑：
1）抽取dwm_yz_tb_comm_cm_all_mon_final的宽带数据
1、接入号；2、多媒体账号；3、分局；4、入网时间；5、当前状态；6、停机时间；
10、域名（多媒体账号@前面的字符串，set ym = substring(acc_nbr2,charindex('@',acc_nbr2)+1,length(acc_nbr2));）
prod_type=40 
--and coalesce(prod_type2) not in(50,60,70,71) --问一下需求方是否剔除itv（50），专线（60,70,71）
and par_month_id=202312
and is_cancel_user=0


2）9、是否省口径到达
--工作助手 宽带省口径到达
select serv_id 
--count(case when is_fee_user=1 then serv_id else null end ) v1 --省宽带到达
--,count(case when  is_fee_user=1 and is_yx=1 then serv_id else null end )  v2 --省宽带到达有效
--,count(case when  is_fee_user=1 and is_new_user=1 then serv_id else null end ) v3 --省宽带到达新装
--,count(case when  is_fee_user=1 and is_new_user=1 and is_yx=1 then serv_id else null end ) v4 --省宽带到达新装有效

from summary_ods_month_city.TB_COMM_CM_DATA_MON  --省业务资料表（工作助手省数据的底层月表）
where PAR_CORP_ID='200' and PAR_MONTH_ID='202312' 
and net_connect_type in (100101,100201,100102,100202,100300) --宽带号码口径
and is_fee_user=1  --出账用户
;

3）打标7、是否受理销售品DM0002-A018；


4）打标8、当月上网时长(省口径)：cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
dwm_yz_tb_comm_cm_all_mon_final视图的省标签打标逻辑：
,coalesce(case when a.prod_type=40 then b.is_yx_kd else 0 end,0) as is_yx_kd
,coalesce(case when a.prod_type=40 then b.is_hy_kd else 0 end,0) as is_hy_kd
,c.kd_ll,c.kd_sxll,c.kd_xxll,c.kd_sc
from (select * from dwm_yz_tb_comm_cm_all_mon_final where par_month_id=${month_id}) a
left join 
(select serv_id
,coalesce(is_yx,0) as is_yx_kd  --是否省有效宽带
,coalesce(is_active_user,0) as is_hy_kd  --是否省活跃宽带
from summary_ods_month_city.tb_comm_cm_data_mon where par_corp_id=200 and par_month_id=${month_id}) b
on a.serv_id=b.serv_id
left join 
(select serv_id,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll, --宽带流量 单位M
cast(SEND_FLUX/1048576 as decimal(22,2)) kd_sxll, --宽带上行流量 单位M
cast(RECV_FLUX/1048576 as decimal(22,2)) kd_xxll, --宽带下行流量 单位M
cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon where par_corp_id=200 and par_month_id=${month_id}) c
on a.serv_id=c.serv_id;


【20240112  XQGZ2024011200053  产权收入多维表】
还有一个单，杨总基本已经做好了，只需要匹一下客户收入（剔除一次性）就可以
取数逻辑是：
1、抽清单：抽取 dws_yz_tb_mo_custgrp_cust_final 的全量数据创建1表，只需抽取表格里标黄的字段，该表是产权信息维表，只有当前月最新数据

2、打标重点客户类型：用1表关联 select attr_id,attr_inner_value,attr_value_name,attr_value_sort  from  dws_crm_cfguse.dws_attr_value where city_id=200
and attr_id='400003971' ，匹attr_value_sort，关联条件vip_flag=attr_inner_value，得到2表

3、打标客户收入：分两步，
1）按客户id统计收入建3表：
--sum(a0_sq) as sh_sq,--税前确认收入
--sum(fee_fm_new) as sh_jbm,--最终基本面收入（不用限制条件，已是全量：移动、宽带、固话、ITV 收入）
select cust_id, 
sum(case when par_month_id>=202201 and par_month_id<=202212 then a0 else 0 end) as sh_qr_2022,--税后确认收入
sum(case when par_month_id>=202201 and par_month_id<=202212 then a8 else 0 end) as sh_ycx_2022, --一次性税后收入
sum(case when par_month_id>=202301 and par_month_id<=202312 then a0 else 0 end) as sh_qr_2023,--税后确认收入
sum(case when par_month_id>=202301 and par_month_id<=202312 then a8 else 0 end) as sh_ycx_2023, --一次性税后收入
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id >= 202201 and par_month_id >= 202312
group by cust_id
2）通过cust_id关联2和3表得到最终的多维表，打标剔除一次性的税后确认收入 sh_qr_2022-sh_ycx_2022 as sr_2022，sh_qr_2023-sh_ycx_2023 as sr_2023

最后输出这个多维表上数据服务专区就可以了


--20240116  XQGZ2024011101804
许茵，XQGZ2024011101804，这个单，我已经和需求方沟通好了，搞个流程每月定期跑，结果表重建两个视图（如果表1不用出就一个视图），视图不用再赋权的了，跑202312和202401月的数据就行，这个月底前完成就可以
取数逻辑：
1、抽数：表1是select * from summary_xq_month_city.tb_msy_005_pz_cust_user_list where par_corp_id=200 and sum_month=202212;--这个省表只有202212的数据，省没有再更新了，问问需求方是不是不用出了
表2：select * from summary_xq_month_city.tb_msy_005_cl_cust_user_list where par_month_id=202312 and par_corp_id=200;
这两个省表是省公司的存量客户清单表，表1是拍照客户清单，表2是存量追踪月清单

2、上面建的表1和表2关联zone_gz_yz.dwm_srhx_serv_final_mon where par_month_id=202312  --历史数据分区表，全量号码资料宽表（在网号码+近6个月拆机号码），供收入数据打标号码相关信息
关联条件a.serv_id=b.serv_id，匹字段：
(case when length(cust_name)<2 then cust_name
when length(cust_name)=2 then concat(SUBSTR(cust_name,1,1),'*')
when length(cust_name)>2 then concat(SUBSTR(cust_name,1,(length(cust_name)-2)),'**')
else null end) as  cust_name_tm（产权客户名）
  
subst_name（划小区县名称）、branch_name（划小营服名称）、area_name（划小片区名称）、
grid_name（责任田名称）、cust_nbr(产权客户编码)、cust_code（直销客户编码）、
、serv_grp_type（服务分群）、bg_type（BG）、
bu_type（BU）、is_gsm（是否公司名）、is_mdz（是否名单制）、
is_school_market_user（是否校园细分市场用户）、
is_zqb_guishang_zx（是否政企部规上企业直销客户清单）、
is_shangke_guishang_zx（是否商客规上企业直销客户清单）、
is_yuan_mingdanzhi_shangke_cq（是否商客名单制产权客户清单）、
is_region_top50_cq（是否商客片区top50 产权客户清单）。

3、生成清单表

4、在广州专区重建视图
drop view if exists view_tb_msy_005_pz_cust_user_list purge;
create view view_tb_msy_005_pz_cust_user_list as 
select * from 表1的结果清单表;--如果不用处理就不用重建这个视图

drop view if exists view_tb_msy_005_cl_cust_user_list purge;
create view view_tb_msy_005_cl_cust_user_list as 
select * from 表2的结果清单表;

--20240117 许茵
 经沟通，按以下方案出《城市家庭拆机多维表》到fineBI：
城市家庭拆机多维表：划小局向、划小营服、包区ID，包区名称，网点编码，网点名称，月份，套餐价值积分，套餐档次（套餐价值积分分档次：按附件的六个区间分档次）

业务口径：统计主流宽带每月主动拆机量，region type为城市家庭，回溯202301-202312月底数据
技术口径：region_type='城市家庭' 
and kd_desc='普通宽带' --主流宽带
and is_wl_cancel_user=1 and wl_cancel_type in ('103') --主动拆机
请许茵协助处理，谢谢。 

--20240119  许茵
周素帆流程：陈思平周报-业务发展
脚本逻辑：陈思平的一个直销客户维表，统计了各种业务量，云电脑入网/到达/上月到达，固话、移动、主宽和专线入网量和拆机量


--20240129  增城审计
drop table if exists zone_gz_yz.ads_yz_zc_sj_kdrw_list purge;
create table zone_gz_yz.ads_yz_zc_sj_kdrw_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select 200 as city_id,
subst_name,branch_name,area_name,
prod_name,serv_id,acc_nbr,payment_type,subs_stat_date,
cancel_date,cust_name_tm,cust_id,cust_code,serv_grp_type_desc,
kd_offer_code,kd_offer_name,'' as  null_column1,'' as  null_column2,
channel_name,sales_code,sales_name,'' as  null_column3,
channel_name as xsd_channel_name,own_operators_name,staff_code,
staff_channel_name,serv_addr_name,serv_addr_id,
speed_value,'' as  null_column4,'' as  null_column5,'' as  null_column6,'' as  null_column7,
state_desc,stop_date,stop_reason_desc,cancel_date as cancel_date2,'' as  null_column8,
'' as  null_column9,'' as  null_column10,add_fee2,add_shqr_sr,add_qf,'' as  null_column11,
'' as  null_column12,'' as  null_column13,fee_yj,'' as  null_column14,'' as  null_column15,'' as  null_column16
from ads_yz_sj_kdrw_sr_qf_yj_list 
where subst_name='增城分公司';

ads_yz_sj_kdrw_sr_qf_yj_list：审计宽带入网清单
ads_yz_sj_fyd_zw_list：审计非移动在网清单，差累计三年佣金和欠费
ads_yz_sj_fyd_zw_list_qf：审计非移动在网清单，差累计三年佣金
ads_yz_sj_fkdrw_list:审计非宽带入网清单，差佣金、欠费


drop table if exists ads_yz_zc_fyd_zw_list purge;
create table ads_yz_zc_fyd_zw_list as 
select distinct serv_id
from ads_yz_sj_fyd_zw_list;
欠费
需要匹配以下三个字段：时间范围：累计三年内，即202101-202312
cast(null as numeric(16,4)) as qf_fee,--普通欠费
cast(null as numeric(16,4)) as qf_qbl,--欠不列
cast(null as numeric(16,4)) as qf_hz  --坏账

佣金
需要匹配以下字段：时间范围：累计三年内，即202101-202312
cast(null as numeric(16,4)) as fee_yj 

drop table if exists zone_gz_yz.ads_yz_sj_fyd_zw_list_qf purge;
create table zone_gz_yz.ads_yz_sj_fyd_zw_list_qf 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.qf_fee,b.qf_qbl,b.qf_hz
,coalesce(b.qf_fee,0)+coalesce(b.qf_qbl,0)+coalesce(b.qf_hz,0) add_qf
from ads_yz_sj_fyd_zw_list a 
left join ads_yz_zc_fyd_zw_qf_list b on a.serv_id=b.serv_id;


--20240131  张晓明  副宽销售品
当月入网的号码有多少在当月办了这些销售品？
DM0001-709-1-9，高值融宽应用宽带包_40元/月
DM0001-944-1-4，融合套餐副宽优惠包1000M_60元/月
DM0001-944-1-2，融合套餐副宽优惠包300M_30元/月
DM0001-668-1-13，固网宽带单产品套餐300M_200元（商企免费副宽）
这4条标识，帮忙看下11、12、1月的入网量分别是多少~

--抽取近三个月的入网号码
drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select par_month_id,serv_id,prod_type,prod_type2,prod_type3 
from dwm_yz_tb_comm_cm_all_final where par_month_id>=202311 and is_new_user=1 
and date_format(open_date,'yyyyMM')>='202311';

--抽取近三个月的副宽销售品订单
drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where 1=1 and a.par_month_id between 202311 and 202312 --月份写历史月份
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202311' and date_format(a.subs_stat_date,'yyyyMM') <= '202312'  --竣工时间，月份写历史月份
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(500024010,500024011,500024012,500024013,500024014,500024015,
500057444,500057591,500058365,500058366,500059095,500059096,500067245,500067246,
500067247,500068024,500068238,500069254,500069255)

union all 
select distinct date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') = '202401' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(500024010,500024011,500024012,500024013,500024014,500024015,
500057444,500057591,500058365,500058366,500059095,500059096,500067245,500067246,
500067247,500068024,500068238,500069254,500069255);

drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.par_month_id,b.prod_offer_id,c.prod_offer_code,c.offer_name
,count(distinct a.serv_id) 
from tmp_yz_liq_1 a 
join tmp_yz_liq_2 b on a.serv_id=b.serv_id and sl_month='202311' 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer 
where city_id=200) c on b.prod_offer_id=c.offer_id
where par_month_id=202311 and prod_type=40 
group by a.par_month_id,b.prod_offer_id,c.prod_offer_code,c.offer_name

union all
select a.par_month_id,b.prod_offer_id,c.prod_offer_code,c.offer_name
,count(distinct a.serv_id) 
from tmp_yz_liq_1 a 
join tmp_yz_liq_2 b on a.serv_id=b.serv_id and sl_month='202312' 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer 
where city_id=200) c on b.prod_offer_id=c.offer_id
where par_month_id=202312 and prod_type=40 
group by a.par_month_id,b.prod_offer_id,c.prod_offer_code,c.offer_name

union all
select a.par_month_id,b.prod_offer_id,c.prod_offer_code,c.offer_name
,count(distinct a.serv_id) 
from tmp_yz_liq_1 a 
join tmp_yz_liq_2 b on a.serv_id=b.serv_id and sl_month='202401' 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer 
where city_id=200) c on b.prod_offer_id=c.offer_id
where par_month_id=202401 and prod_type=40 
group by a.par_month_id,b.prod_offer_id,c.prod_offer_code,c.offer_name;


--20240202  
drop table if exists zone_gz_yz.tmp_yz_liq_1;
create table zone_gz_yz.tmp_yz_liq_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select channel_id,channel_nbr,status_cd from dwd_yz_sale_outlers_mon_final where par_month_id=202309
and channel_nbr in(select index1 from zone_gz_yz_3351225714708480) 
;

select own_channel_id,sales_code,status_cd from dwd_yz_sales_man_mon_final where par_month_id=202309 
and own_channel_id in(select channel_id from tmp_yz_liq_1 where coalesce(status_cd,'-1')<>'S0X' ) 
limit 1000

drop table if exists zone_gz_yz.tmp_yz_liq_1;
create table zone_gz_yz.tmp_yz_liq_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select channel_nbr,serv_id,is_cancel_user from  dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202012 
and channel_nbr in(select index1 from zone_gz_yz_3351225714708480);

select channel_nbr,count(distinct serv_id) from tmp_yz_liq_1 where is_cancel_user=0 group by channel_nbr  limit 1000

--刘丽娜  剔除客户级松散融合  
drop table if exists zone_gz_yz.tmp_liq_0204_1 purge;
create table zone_gz_yz.tmp_liq_0204_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.* 
from dwm_yz_tb_comm_cm_all_mon_final a WHERE par_month_id in(202212,202309,202311,202312);

drop table if exists zone_gz_yz.tmp_liq_0204_2 purge;
create table zone_gz_yz.tmp_liq_0204_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.rh_rule 
from tmp_liq_0204_1 a 
left join dwd_yz_rpt_comm_cm_rh_list_mon_final b on a.serv_id=b.serv_id 
and a.par_month_id=b.par_month_id and b.par_month_id in(202212,202309,202311,202312);

SELECT par_month_id,rh_rule,count(distinct serv_id),count(distinct rh_tc_id)
FROM tmp_liq_0204_2  WHERE rh_tc_value>=129 
group by  par_month_id ,rh_rule order by par_month_id ,rh_rule

drop table if exists ads_yz_129_jm_tcss_list purge;
create table ads_yz_129_jm_tcss_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select * from zone_gz_yz.tmp_liq_0204_2 ;

drop view if exists view_129_jm_tcss_list;
create view view_129_jm_tcss_list as 
select * from zone_gz_yz.tmp_liq_0204_2 ;

SELECT par_month_id, subst_name , 
count(CASE WHEN kd_desc = '普通宽带' AND rh_tc_value >= 129 THEN a.serv_id ELSE NULL END) AS v2 
FROM view_129_jm_tcss_list a 
WHERE par_month_id IN (202212, 202309, 202312) 
AND prod_type = 40 -- 宽带 
AND kd_desc IN ('普通宽带') 
AND prod_type2 NOT IN (50) -- 剔除ITV 
AND prod_type2 NOT IN (60, 70, 71) -- 剔除专线 
and prod_id not in (select prod_id  from view_yz_dws_product where coalesce(prod_name, '-1') like '%城域网%')--剔除城域网
AND is_cancel_user = 0 -- 在网 
AND is_cz = 1 -- 到达 
and (is_rh_ykj<=0 or (is_rh_ykj>0 and rh_rule in(10,20) ))  --剔除客户级松散融合
GROUP BY par_month_id, subst_name

--20240205  张建新  宽带质态监控
drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.par_month_id,a.serv_id,a.subst_name,a.branch_name,a.area_name,is_rh_ykj,a.kd_desc,a.itv_type
from dwm_yz_tb_comm_cm_all_mon_final a where par_month_id in(202307,202310) 
and is_new_user=1 and date_format(open_date,'yyyyMM')=cast(par_month_id as string) 
and prod_type=40;

--打标有效
drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when b.is_yx=1 then '是' else '否' end as is_sheng_yx_202310
,case when c.is_yx=1 then '是' else '否' end as is_sheng_yx_202401
from zone_gz_yz.tmp_yz_liq_1 a  
left join summary_ods_month_city.TB_COMM_CM_DATA_MON b 
on a.serv_id=b.serv_id and b.PAR_CORP_ID='200' and b.PAR_MONTH_ID in(202310) 
left join summary_ods_month_city.TB_COMM_CM_DATA_MON c 
on a.serv_id=c.serv_id and c.PAR_CORP_ID='200' and c.PAR_MONTH_ID in(202401);

--打标欠费标签
drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.is_arrear_user as is_arrear_user_202310
,c.is_arrear_user as is_arrear_user_202401
from zone_gz_yz.tmp_yz_liq_2 a  
left join summary_tyks_month_city.TB_ZTJK_NEW_USER_MON b on a.serv_id=b.serv_id 
--and b.cal_id='2' --省宽带
and b.par_corp_id='200' and b.PAR_MONTH_ID in(202310) and b.is_cancel_user=0 and b.payment_id=1 

left join summary_tyks_month_city.TB_ZTJK_NEW_USER_MON c on a.serv_id=c.serv_id 
--and c.cal_id='2' --省宽带
and c.par_corp_id='200' and c.PAR_MONTH_ID in(202401) and c.is_cancel_user=0 and c.payment_id=1;


--打标出账拆机
drop table if exists zone_gz_yz.tmp_yz_liq_4 purge;
create table zone_gz_yz.tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when b.is_cz=1 then '是' else '否' end as is_cz_202310
,case when c.is_cz=1 then '是' else '否' end as is_cz_202401

,case when b.is_cancel_user=0 then '否' else '是' end as is_cancel_202310
,case when c.is_cancel_user=0 then '否' else '是' end as is_cancel_202401
from zone_gz_yz.tmp_yz_liq_3 a  
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.PAR_MONTH_ID in(202310) 
left join dwm_yz_tb_comm_cm_all_mon_final c on a.serv_id=c.serv_id and c.PAR_MONTH_ID in(202401);

--统计多维表
drop table if exists zone_gz_yz.tmp_yz_liq_5 purge;
create table zone_gz_yz.tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select PAR_MONTH_ID,subst_name,branch_name,area_name,kd_desc,
case when is_rh_ykj>0 then '融合' else '单宽' end rh_type
,is_sheng_yx_202310,is_cz_202310,is_sheng_yx_202401,is_cz_202401
,is_cancel_202310,is_cancel_202401,is_arrear_user_202310,is_arrear_user_202401
,count(distinct serv_id) kd_rw 
from tmp_yz_liq_4 
group by PAR_MONTH_ID,subst_name,branch_name,area_name,kd_desc,is_rh_ykj
,is_sheng_yx_202310,is_cz_202310,is_sheng_yx_202401,is_cz_202401
,is_cancel_202310,is_cancel_202401,is_arrear_user_202310,is_arrear_user_202401;

--统计多维表
drop table if exists zone_gz_yz.tmp_yz_liq_6 purge;
create table zone_gz_yz.tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select PAR_MONTH_ID,subst_name,branch_name,area_name,kd_desc,rh_type 
,sum( case when is_sheng_yx_202310='是' and is_cz_202310='是' then kd_rw else 0 end) as t_3_yxcz
,sum( case when is_sheng_yx_202401='是' and is_cz_202401='是' then kd_rw else 0 end) as t_6_yxcz
,sum( case when is_cancel_202310='是' then kd_rw else 0 end) as t_3_cancel
,sum( case when is_cancel_202401='是' then kd_rw else 0 end) as t_6_cancel
,sum( case when is_arrear_user_202310=1 then kd_rw else 0 end) as t_3_qf
,sum( case when is_arrear_user_202401=1 then kd_rw else 0 end) as t_6_qf
,sum( kd_rw) rw_num
from tmp_yz_liq_5 
where PAR_MONTH_ID=202307 
group by PAR_MONTH_ID,subst_name,branch_name,area_name,kd_desc,rh_type

union all 
select PAR_MONTH_ID,subst_name,branch_name,area_name,kd_desc,rh_type 
,sum( case when is_sheng_yx_202401='是' and is_cz_202401='是' then kd_rw else 0 end) as t_3_yxcz
,0 as t_6_yxcz
,sum( case when is_cancel_202401='是' then kd_rw else 0 end) as t_3_cancel
,0 as t_6_cancel
,sum( case when is_arrear_user_202401=1 then kd_rw else 0 end) as t_3_qf
,0 as t_6_qf
,sum( kd_rw) rw_num
from tmp_yz_liq_5 
where PAR_MONTH_ID=202310 
group by PAR_MONTH_ID,subst_name,branch_name,area_name,kd_desc,rh_type;

select par_month_id,subst_name,rh_type,
sum(t_3_yxcz) sumt_3_yxcz,
sum(t_6_yxcz) sumt_6_yxcz,
sum(t_3_cancel) sumt_3_cancel,
sum(t_6_cancel) sumt_6_cancel,
sum(t_3_qf) sumt_3_qf,
sum(t_6_qf) sumt_6_qf,
sum(rw_num) zk_rw
from tmp_yz_liq_6 
where kd_desc='普通宽带'
group by par_month_id,subst_name,rh_type


--吴啸  省公司业务质态雷达
select count(1) ,count(case when  IS_CANCEL_USER=1 then serv_id else null end) 
,cast(count(case when  IS_CANCEL_USER=1 then serv_id else null end)*100.00/ count(1) as decimal(22,2))
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where par_month_id=202204  and cast(OPEN_MONTH as int)=202201 and cal_id='2'
and par_corp_id='200'



drop table tmp_yy_cj3;
create table tmp_yy_cj3 as 
select '拆机t+3' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_CANCEL_USER=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200'
and par_month_id>=202204 and par_month_id= (case when cast(OPEN_MONTH as int)%100>=10
then cast(OPEN_MONTH as int)+91
else cast(OPEN_MONTH as int)+3 end);

drop table tmp_yy_cj6;
create table tmp_yy_cj6 as 
select '拆机t+6' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_CANCEL_USER=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200'
and par_month_id>=202207 and par_month_id= (case when cast(OPEN_MONTH as int)%100>=7
then cast(OPEN_MONTH as int)+94
else cast(OPEN_MONTH as int)+6 end);




select rm_month,count(1),count(case when is_fz=1 then serv_id else null end),
cast(count(case when is_fz=1 then serv_id else null end)*100.00/count(1) as decimal(22,2))
from tmp_yy_cj6 
group by rm_month order by rm_month

select rm_month,count(1),count(case when is_fz=1 then serv_id else null end),
cast(count(case when is_fz=1 then serv_id else null end)*100.00/count(1) as decimal(22,2))
from tmp_yy_cj3 
group by rm_month order by rm_month



drop table tmp_yy_dd3;
create table tmp_yy_dd3 as 
select '到达出账t+3' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_FEE_USER=1 and IS_YX=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200'
and par_month_id>=202204 
and is_cancel_user=0
and par_month_id= (case when cast(OPEN_MONTH as int)%100>=10 
then cast(OPEN_MONTH as int)+91
else cast(OPEN_MONTH as int)+3 end);

drop table tmp_yy_dd6;
create table tmp_yy_dd6 as 
select '到达出账t+6' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_FEE_USER=1 and IS_YX=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200' 
and par_month_id>=202207  and is_cancel_user=0
and par_month_id= (case when cast(OPEN_MONTH as int)%100>=7 
then cast(OPEN_MONTH as int)+94 
else cast(OPEN_MONTH as int)+6 end);


select rm_month,count(1),count(case when is_fz=1 then serv_id else null end),
cast(count(case when is_fz=1 then serv_id else null end)*100.00/count(1) as decimal(22,2))
from tmp_yy_dd6 
group by rm_month order by rm_month

select rm_month,count(1),count(case when is_fz=1 then serv_id else null end),
cast(count(case when is_fz=1 then serv_id else null end)*100.00/count(1) as decimal(22,2))
from tmp_yy_dd3 
group by rm_month order by rm_month




drop table tmp_yy_qf3;
create table tmp_yy_qf3 as 
select '欠费t+3' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_arrear_USER=1  then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200'
and par_month_id>=202204 
and is_cancel_user=0 and payment_id=1
and par_month_id= (case when cast(OPEN_MONTH as int)%100>=10 
then cast(OPEN_MONTH as int)+91
else cast(OPEN_MONTH as int)+3 end);

drop table tmp_yy_qf6;
create table tmp_yy_qf6 as 
select '欠费t+6' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_arrear_USER=1  then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200' 
and par_month_id>=202207  and is_cancel_user=0  and payment_id=1
and par_month_id= (case when cast(OPEN_MONTH as int)%100>=7 
then cast(OPEN_MONTH as int)+94 
else cast(OPEN_MONTH as int)+6 end);



select rm_month,count(1),count(case when is_fz=1 then serv_id else null end),
cast(count(case when is_fz=1 then serv_id else null end)*100.00/count(1) as decimal(22,2))
from tmp_yy_qf3 
group by rm_month order by rm_month

select rm_month,count(1),count(case when is_fz=1 then serv_id else null end),
cast(count(case when is_fz=1 then serv_id else null end)*100.00/count(1) as decimal(22,2))
from tmp_yy_qf6 
group by rm_month order by rm_month

create table ads_TB_ZTJK_NEW_USER_MON_all_list as 
select *  from (
select *  from tmp_yy_cj3
union all
select *  from tmp_yy_cj6
union all
select *  from tmp_yy_dd3
union all
select *  from tmp_yy_dd6
union all
select *  from tmp_yy_qf3
union all
select *  from tmp_yy_qf6) a;



select item_type,rm_month,count(1),count(case when is_fz=1 then serv_id else null end),
cast(count(case when is_fz=1 then serv_id else null end)*100.00/count(1) as decimal(22,2))
from view_ads_TB_ZTJK_NEW_USER_MON_all_list 
group by item_type,rm_month 
order by rm_month,item_type

create view view_ads_TB_ZTJK_NEW_USER_MON_all_list
as select * from zone_gz_yz.ads_TB_ZTJK_NEW_USER_MON_all_list;

view_ads_tb_ztjk_new_user_mon_all_list
view_ads_tb_ztjk_new_user_mon


######################
													
alter table ads_TB_ZTJK_NEW_USER_MON_all_list rename to ads_TB_ZTJK_NEW_USER_MON_all_list_bf;

alter table ads_tb_ztjk_new_user_mon rename to ads_tb_ztjk_new_user_mon_bf;


use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;

drop table tmp_yy_cj3;
create table tmp_yy_cj3 as 
select '拆机t+3' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_CANCEL_USER=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200'
and par_month_id>=202310 and par_month_id= (case when cast(OPEN_MONTH as int)%100>=10
then cast(OPEN_MONTH as int)+91
else cast(OPEN_MONTH as int)+3 end);

drop table tmp_yy_cj6;
create table tmp_yy_cj6 as 
select '拆机t+6' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_CANCEL_USER=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200'
and par_month_id>=202310 and par_month_id= (case when cast(OPEN_MONTH as int)%100>=7
then cast(OPEN_MONTH as int)+94
else cast(OPEN_MONTH as int)+6 end);


use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;

drop table tmp_yy_dd3;
create table tmp_yy_dd3 as 
select '到达出账t+3' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_FEE_USER=1 and IS_YX=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200'
and par_month_id>=202310 
and is_cancel_user=0
and par_month_id= (case when cast(OPEN_MONTH as int)%100>=10 
then cast(OPEN_MONTH as int)+91
else cast(OPEN_MONTH as int)+3 end);

drop table tmp_yy_dd6;
create table tmp_yy_dd6 as 
select '到达出账t+6' as item_type,cast(OPEN_MONTH as int) rm_month,par_month_id cj_month,serv_id,
(case when IS_FEE_USER=1 and IS_YX=1 then 1 else 0 end) is_fz
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON
where cal_id='2' and par_corp_id='200' 
and par_month_id>=202310  and is_cancel_user=0
and par_month_id= (case when cast(OPEN_MONTH as int)%100>=7 
then cast(OPEN_MONTH as int)+94 
else cast(OPEN_MONTH as int)+6 end);


alter table ads_TB_ZTJK_NEW_USER_MON_all_list rename to ads_TB_ZTJK_NEW_USER_MON_all_list_new;


1045527


insert overwrite table ads_TB_ZTJK_NEW_USER_MON_all_list
select * from 
(
select *  from ads_TB_ZTJK_NEW_USER_MON_all_list_new
union all
select * from ads_TB_ZTJK_NEW_USER_MON_all_list_bf
) a;

--20240219  增城审计佣金清单  东杏
create table dwd_yz_yj_zclrsj_list_bak as 
select a.*  from dwd_yz_yj_zclrsj_list a;

create table tmp_yz_yj_zclrsj_list as 
select a.*,200 as city_id from dwd_yz_yj_zclrsj_list a;

drop table if exists dwd_yz_yj_zclrsj_list purge;
create table dwd_yz_yj_zclrsj_list as 
select a.*  from tmp_yz_yj_zclrsj_list a;

--20240222  XQGZ2024020201547  黄俐
统计符合97万临街商铺地址，且 202301-202401 入网的主流宽带，统计这批宽带对应办理的所有销售品，字段：销售品编码、销售品名称

drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.par_month_id,a.serv_id ,a.serv_addr_id
from dwm_yz_tb_comm_cm_all_mon_final a 
where a.prod_type=40 and kd_desc='普通宽带' and a.is_new_user=1 
and a.par_month_id between 202301 and 202401
and date_format(open_date,'yyyyMM')>='202301' and date_format(open_date,'yyyyMM')<='202401';

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
case when b.serv_addr_id is not null then 1 else 0 end as is_ljsp
from zone_gz_yz.tmp_yz_liq_1 a  
left join zone_gz_yz.dwd_yz_dim_ljsp_addr b on cast(a.serv_addr_id as decimal(24,0))=cast(b.serv_addr_id as decimal(24,0)) 
;

drop table if exists zone_gz_yz.tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select distinct a.prod_offer_id,b.offer_name,b.prod_offer_code 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200) b on a.prod_offer_id=b.offer_id
where a.par_month_id=202401 and a.par_corp_id='200'
and a.serv_id in(select distinct serv_id from tmp_yz_liq_2 where is_ljsp=1);

--20240228  XQGZ2024020500711  周素帆
1）抽取优惠订单表2023年全年订单，限制三个销售品
select a.serv_id,a.subs_id,a.prod_offer_id
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where 1=1 and a.par_month_id between 202101 and 202312 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyy') = '2023'  --竣工时间
and a.action_id in( 1292,6200 );--销售品订购和更换

2）用subs_id关联from dws_crm_order.dws_ord_prod_res_inst_rel b  --设备订单表
on a.subs_id=b.order_item_id 取mkt_res_id--设备id
和property_type--设备来源id
再用历史表dws_crm_order.dws_ord_prod_res_inst_rel_his 补打历史订单

3）用 mkt_res_id 设备id关联设备信息表iodata_ods_day_szx.mkt_resource on a.mkt_res_id=b.mkt_res_id取mkt_res_name--设备名称

4）from  dws_crm_cfguse.dws_attr_value b on a.property_type = b.attr_inner_value and b.city_id='200' and b.attr_id =4000000208--设备购买方式
取attr_value_name as sheb_ly--设备来源

输出字段：销售品编码        销售品名称        设备名称        （设备来源）是否环保利用        订单竣工量

--20240227  XQGZ2024022601575  按圈定终端串号匹最后使用接入号、Serv_Id、入网时间、当前状态
按order by create_date desc,status_cd desc  排序，取时间最晚的那一条
select eqpt_sn --终端串号
,prod_inst_id serv_id
,mkt_res_id  --设备id
,create_date
from dws_crm_cust.dws_prod_res_inst_rel --终端资料表
where status_cd  <>1200 
and eqpt_sn in(select index1 from zone_gz_yz_3351225714708480)

union all 
select eqpt_sn
,prod_inst_id serv_id
,mkt_res_id  --设备id
,create_date
from dws_crm_cust.dws_prod_res_inst_rel_his --终端资料历史表
where status_cd  <>1200 
and eqpt_sn in(select index1 from zone_gz_yz_3351225714708480)

2）用 mkt_res_id 设备id关联设备信息表iodata_ods_day_szx.mkt_resource on a.mkt_res_id=b.mkt_res_id取mkt_res_name--设备名称
用dwm_yz_tb_comm_cm_all_mon_final最新数据匹配acc_nbr,state,open_date

3）用特性表打标state状态中文名称
select b.attr_value_name as state_desc
from 
left join dws_crm_cfguse.dws_attr_value b on a.state=b.attr_value and b.city_id='200' and b.attr_id='4000000201'

4)没打上的号码state状态为拆机


--20240305  张建新  工作助手T+6拆机率
1 抽数
select PAR_MONTH_ID,serv_id,subst_id,OPEN_MONTH,IS_CANCEL_USER
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON a 
where a.PAR_CORP_ID='200' 
and a.PAR_MONTH_ID>='202311' and a.PAR_MONTH_ID<='202401' 
and cal_id=2 -- 宽带

2 打标dwm_yz_tb_comm_cm_all_mon_final的is_rh_ykj,prod_type3,kd_desc
3 打标机构表的subst_name

4 输出多维表字段：
入网月份（202305-202307）、是否融合、低值宽带类型、宽带分类、划小分局、入网用户数、其中T+6拆机数
-- 宽带T+6拆机率
select OPEN_MONTH
,case when COALESCE(is_rh_ykj,-1)>0 then '是' else '否' end as is_rh
,prod_type3,kd_desc,subst_name,
count(case when OPEN_MONTH='202305' then serv_id else null end) -- 入网数
,count(case when OPEN_MONTH='202305' and IS_CANCEL_USER=1 then serv_id else null end) --其中T+6：拆机数
from 前面的清单表 a 
where a.PAR_MONTH_ID='202311' 
and OPEN_MONTH='202305' 

union all 
select OPEN_MONTH
,case when COALESCE(is_rh_ykj,-1)>0 then '是' else '否' end as is_rh
,prod_type3,kd_desc,subst_name,
count(case when OPEN_MONTH='202306' then serv_id else null end) -- 入网数
,count(case when OPEN_MONTH='202306' and IS_CANCEL_USER=1 then serv_id else null end) --其中T+6：拆机数
from 前面的清单表 a 
where a.PAR_MONTH_ID='202312' 
and OPEN_MONTH='202306' 

union all 
select OPEN_MONTH
,case when COALESCE(is_rh_ykj,-1)>0 then '是' else '否' end as is_rh
,prod_type3,kd_desc,subst_name,
count(case when OPEN_MONTH='202307' then serv_id else null end) -- 入网数
,count(case when OPEN_MONTH='202307' and IS_CANCEL_USER=1 then serv_id else null end) --其中T+6：拆机数
from 前面的清单表 a 
where a.PAR_MONTH_ID='202401' 
and OPEN_MONTH='202307' 



drop table if exists tmp_chaiji_1;
create table tmp_chaiji_1 as
select PAR_MONTH_ID,serv_id,subst_id,OPEN_MONTH,IS_CANCEL_USER
from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON a 
where a.PAR_CORP_ID='200' 
and a.PAR_MONTH_ID>='202311' and a.PAR_MONTH_ID<='202401' 
and cal_id=2;

drop table if exists tmp_chaiji_2;
create table tmp_chaiji_2 as
select a.*,b.is_rh_ykj,b.prod_type3,b.kd_desc,b.subst_name
from tmp_chaiji_1 a
left join dwm_yz_tb_comm_cm_all_final b
on a.serv_id=b.serv_id;

drop table if exists tmp_chaiji_3;
create table tmp_chaiji_3 as
select OPEN_MONTH
,case when COALESCE(is_rh_ykj,-1)>0 then '是' else '否' end as is_rh
,prod_type3,kd_desc,subst_name,
count(case when OPEN_MONTH='202305' then serv_id else null end)
,count(case when OPEN_MONTH='202305' and IS_CANCEL_USER=1 then serv_id else null end)
from tmp_chaiji_2
where PAR_MONTH_ID='202311' 
and OPEN_MONTH='202305' 
group by is_rh_ykj,prod_type3,kd_desc,subst_name,OPEN_MONTH
union all 
select OPEN_MONTH
,case when COALESCE(is_rh_ykj,-1)>0 then '是' else '否' end as is_rh
,prod_type3,kd_desc,subst_name,
count(case when OPEN_MONTH='202306' then serv_id else null end) -- 入网数
,count(case when OPEN_MONTH='202306' and IS_CANCEL_USER=1 then serv_id else null end) --其中T+6：拆机数
from tmp_chaiji_2
where PAR_MONTH_ID='202312' 
and OPEN_MONTH='202306'
group by is_rh_ykj,prod_type3,kd_desc,subst_name,OPEN_MONTH
union all 
select OPEN_MONTH
,case when COALESCE(is_rh_ykj,-1)>0 then '是' else '否' end as is_rh
,prod_type3,kd_desc,subst_name,
count(case when OPEN_MONTH='202307' then serv_id else null end) -- 入网数
,count(case when OPEN_MONTH='202307' and IS_CANCEL_USER=1 then serv_id else null end) --其中T+6：拆机数
from tmp_chaiji_2 
where PAR_MONTH_ID='202401' 
and OPEN_MONTH='202307'
group by is_rh_ykj,prod_type3,kd_desc,subst_name,OPEN_MONTH;

select * from tmp_chaiji_3;

--20240312  XQGZ2024030602016  提取微派本地业务出账的需求
账期月份	客户名称	产品名称	产品编码	接入号	状态	
订购时间	结算账号(特性取Z端号码，附属产品属性取移动号码本身)	

IT实收金额	广州电信本地列账金额	广州电信本地列账科目编码	广州电信本地列账科目
18998819167  23年科目编码 SR01330104010402	

划小分局	划小营服	划小营服id	BG类型	BU类型	揽装人姓名	揽装人工号
select attr_id,attr_name from dws_crm_cfguse.dws_attr_spec where attr_inner_cd in('PM_YDYDCP16SH3',
'PM_YDYBDQCP5SX2',
'PM_YDYDCP16SH2')
500036071  商客应用（代收费）
500037056   安全应用（代收费）
500037057   商客应用（代收费） 

use zone_gz_yz;
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=32;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.exec.parallel=true;

--抽取特性（产品规格属性）号码
drop table if exists  tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.par_month_id,a.serv_id
,a.attr_id --特性id（产品规格属性）
,a.attr_value1  --特性值
,a.create_date   --订购时间

,b.attr_inner_cd  --产品规格属性编码
from iodata_ods_month_city.tb_pre_cm_attr_all_mon a --特性资料表 
join (select attr_id,attr_inner_cd from dws_crm_cfguse.dws_attr_spec where attr_inner_cd in('PM_YDYDCP16SH3','PM_YDYDCP16SH2')) b 
on a.attr_id=b.attr_id 
where a.par_corp_id=200 and a.par_month_id>=202203  
;

--抽取附属产品属性号码
insert into table tmp_yz_liq_1 
select a.par_month_id,a.serv_id
,a.attr_id --特性id（附属产品属性ID）
,a.attr_value1  --特性值
,state_date  create_date --订购时间

,b.attr_inner_cd  --属性编码
from iodata_ods_month_city.rpt_comm_cm_subserv_mon a --附属产品资料表 月表
join (select attr_id,attr_inner_cd from dws_crm_cfguse.dws_attr_spec where attr_inner_cd in('PM_YDYBDQCP5SX2')) b 
on a.attr_id=b.attr_id 
where a.par_corp_id=200 and a.par_month_id>=202101 and a.sub_prod_id='500000621';

--打标特性值中文名称
drop table if exists  tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.prod_attr_name
from tmp_yz_liq_1 a 
left join (select distinct attr_id,attr_inner_value,attr_value_name as prod_attr_name from dws_crm_cfguse.dws_attr_value where city_id='200') b 
on a.attr_value1=b.attr_inner_value and a.attr_id = b.attr_id
;

--打标对应月份号码基础信息
drop table if exists  tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.cust_name,b.acc_nbr,b.state,b.subst_id,b.subst_name,b.branch_id,b.branch_name
,b.bg_type,b.bu_type,b.sales_id,b.sales_code,b.sales_name
from tmp_yz_liq_2 a 
left join dwm_yz_tb_comm_cm_all_mon_final b 
on a.serv_id=b.serv_id and a.par_month_id = b.par_month_id
;

--打标状态中文名称
drop table if exists  tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.attr_value_name as state_desc
from tmp_yz_liq_3 a 
left join dws_crm_cfguse.dws_attr_value b on a.state=b.attr_value and b.city_id='200' and b.attr_id='4000000201'
; 

--a端号码（只有当前数据，没有历史数据）
drop table if exists  tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.a_prod_inst_id 
from tmp_yz_liq_4 a 
left join dws_crm_cust.dws_prod_inst_rel_grp_a b on b.city_id=200 and cast(a.serv_id as string)=b.z_prod_inst_id
;

--结算账号
drop table if exists  tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when a.attr_inner_cd='PM_YDYBDQCP5SX2' then a.acc_nbr 
	when COALESCE(a.attr_inner_cd,'-1') not in('PM_YDYBDQCP5SX2') and b.acc_nbr is not null then b.acc_nbr else null end as js_acc_nbr
,case when a.attr_inner_cd='PM_YDYBDQCP5SX2' then a.serv_id 
	when COALESCE(a.attr_inner_cd,'-1') not in('PM_YDYBDQCP5SX2') and b.acc_nbr is not null then b.serv_id else null end as js_serv_id
from tmp_yz_liq_5 a 
left join dwm_yz_tb_comm_cm_all_final b on a.a_prod_inst_id=b.serv_id and b.par_month_id=202403
;

drop table if exists  tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.fee_sh,b.due_income_code 
from tmp_yz_liq_6 a 
left join (select par_month_id,acc_nbr,due_income_code,sum(fee_all) as fee_sh
		from zone_gz_yz.dwm_srhx_src_income_list_mon
		where  par_month_id>=202301 and  par_month_id<=202402
		and contract_flag=1 --划小收入
		and flag=1  --号码级收入（比如漫游是出在虚拟号码上的收入，会落到分局，但不是真实号码）
		and is_filter='0' --考核收入
		--and substr(a.due_income_code,1,8) not in ('SR014101','SR014102','SR014109','SR014201',
		     --'SR024101','SR024102','SR024109','SR024201','SR034101','SR034102','SR034109','SR034201' ) 剔除非主营收入（圈定一批科目是非主营科目）
		and due_income_code in('SR01330104010402','SR0137010222')  --限制科目（必须是子节点，该字段不存在父节点）
		group by par_month_id,acc_nbr,due_income_code) b 
on a.js_acc_nbr=b.acc_nbr and a.par_month_id=b.par_month_id;

drop table if exists  tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.subst_name as js_subst_name 
from tmp_yz_liq_7 a 
left join dwm_yz_tb_comm_cm_all_mon_final b 
on a.js_serv_id=b.serv_id and a.par_month_id = b.par_month_id;

drop table if exists  ads_yz_liq_XQGZ2024030602016 purge;
create table ads_yz_liq_XQGZ2024030602016 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select * from tmp_yz_liq_8;

drop table if exists  ads_yz_liq_XQGZ2024030602016_dwb purge;
create table ads_yz_liq_XQGZ2024030602016_dwb 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select distinct par_month_id,attr_inner_cd,js_subst_name,js_acc_nbr,fee_sh,due_income_code
,case when due_income_code='SR01330104010402' then '固网' else '其他' end as due_income_name
from tmp_yz_liq_8 where fee_sh is not null 
and ((attr_inner_cd in('PM_YDYDCP16SH3','PM_YDYBDQCP5SX2') and prod_attr_name like '%深圳通宝-智网无忧%')
or (attr_inner_cd in('PM_YDYDCP16SH2') and prod_attr_name like '%盈宏-网络监控运维%'));

select par_month_id,js_subst_name,attr_inner_cd,due_income_name,due_income_code 
,sum(fee_sh)
from ads_yz_liq_XQGZ2024030602016_dwb 
group by par_month_id,js_subst_name,attr_inner_cd,due_income_name,due_income_code limit 1000


drop table if exists  ads_yz_liq_XQGZ2024030602016 purge;
create table ads_yz_liq_XQGZ2024030602016 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select par_month_id
,(case when length(cust_name)<2 then cust_name
		when length(cust_name)=2 then concat(SUBSTR(cust_name,1,1),'*')
		when length(cust_name)>2 then concat(SUBSTR(cust_name,1,(length(cust_name)-2)),'**')
		else null end) as  cust_name_tm
,prod_attr_name,attr_inner_cd,acc_nbr,state_desc,create_date,js_acc_nbr,fee_sh
,due_income_code,case when due_income_code='SR01330104010402' then '固网' else '其他' end as due_income_name
,subst_name,branch_name,branch_id,bg_type,bu_type
,sales_name,sales_code,js_subst_name
from tmp_yz_liq_8 where fee_sh is not null;

--20240315  政企部 核查P码变动的客户收入
drop table tmp_yz_zqb_p_cust_20220825 purge; 
create table tmp_yz_zqb_p_cust_20220825 as 
select cast(index1  as string) cust_nbr
,cast(index2  as string) cust_id
,cast(index3  as string) p_nbr
,cast(index4  as string) p_name
,cast(index5  as string) cust_code
,cast(index6  as string) ccust_id

from zone_gz_yz_3351225714708480;

drop table tmp_yz_zqb_p_cust_20231010 purge; 
create table tmp_yz_zqb_p_cust_20231010 as 
select cast(index1  as string) cust_nbr
,cast(index2  as string) cust_id
,cast(index3  as string) p_nbr
,cast(index4  as string) p_name
,cast(index5  as string) cust_code
,cast(index6  as string) ccust_id

from zone_gz_yz_3351225714708480;

insert into table tmp_yz_zqb_p_cust_20220825 
select * from yz_zqb_p_cust_20220825_f1_new ;

insert into table tmp_yz_zqb_p_cust_20231010 
select * from yz_zqb_p_cust_20231010_f1_new;

drop table tmp_yz_zqb_p_cust_dim purge; 
create table tmp_yz_zqb_p_cust_dim as 
select cast(index1  as string) p_nbr
,cast(index2  as string) cust_name
,cast(index3  as string) subst_name
,cast(index4  as string) bg_type
,cast(index5  as string) bu_type

from zone_gz_yz_3351225714708480;


drop table if exists tmp_yz_zqb_p_cust_20220825_dim purge;
create table tmp_yz_zqb_p_cust_20220825_dim as 
select * from tmp_yz_zqb_p_cust_20220825 
where p_nbr in(select distinct p_nbr from tmp_yz_zqb_p_cust_dim ) ;

drop table if exists tmp_yz_zqb_p_cust_1_1 purge;
create table tmp_yz_zqb_p_cust_1_1 as 
select a.cust_id as cust_202212,a.serv_id,b.p_nbr as p_nbr_202212,a.prod_id as prod_id_202212
from dwm_yz_tb_comm_cm_all_mon_final a 
join tmp_yz_zqb_p_cust_20220825_dim b on cast(a.cust_id as string)=b.cust_id 
where par_month_id=202212 
;

drop table if exists tmp_yz_zqb_p_cust_1 purge;
create table tmp_yz_zqb_p_cust_1 as 
select a.*,b.prod_name as prod_name_202212 
from tmp_yz_zqb_p_cust_1_1 a 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) b on a.prod_id_202212=b.prod_id;

drop table if exists tmp_yz_zqb_p_cust_2 purge;
create table tmp_yz_zqb_p_cust_2 as 
select a.*,b.cust_id as cust_202312
from tmp_yz_zqb_p_cust_1 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=cast(b.serv_id as string) and b.par_month_id=202312 
;

drop table if exists tmp_yz_zqb_p_cust_3 purge;
create table tmp_yz_zqb_p_cust_3 as 
select a.*,b.p_nbr as p_nbr_202312
from tmp_yz_zqb_p_cust_2 a 
left join tmp_yz_zqb_p_cust_20231010 b on cast(a.cust_202312 as string)=b.cust_id 
;

drop table if exists tmp_yz_zqb_p_cust_4 purge;
create table tmp_yz_zqb_p_cust_4 as 
select a.*,b.fee_sh 
from tmp_yz_zqb_p_cust_3 a 
left join (select serv_id,sum(fee_new_tax) fee_sh 
	from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202301 and par_month_id<=202312 group by serv_id) b 
	on a.serv_id=cast(b.serv_id as string)
;

drop table if exists tmp_yz_zqb_p_cust_5 purge;
create table tmp_yz_zqb_p_cust_5 as 
select * from tmp_yz_zqb_p_cust_4 
where p_nbr_202212<>coalesce(p_nbr_202312,'-1');



drop table if exists tmp_yz_zqb_p_cust_6 purge;
create table tmp_yz_zqb_p_cust_6 as 
select p_nbr_202212,prod_name_202212,sum(fee_sh) change_p_fee 
from tmp_yz_zqb_p_cust_5 group by p_nbr_202212,prod_name_202212;

drop table if exists tmp_yz_zqb_p_cust_7 purge;
create table tmp_yz_zqb_p_cust_7 as 
select a.*,b.cust_name,b.subst_name,b.bg_type,b.bu_type,'是' as is_exist  
from tmp_yz_zqb_p_cust_6 a 
left join tmp_yz_zqb_p_cust_dim b on a.p_nbr_202212=b.p_nbr;

insert into table tmp_yz_zqb_p_cust_7 
select a.p_nbr
,cast(null as string) as prod_name_202212
,cast(null as decimal(32,2) ) as change_p_fee
,a.cust_name
,a.subst_name
,a.bg_type
,a.bu_type
,case when b.p_nbr is not null then '是' else '否' end as  is_exist
from tmp_yz_zqb_p_cust_dim a 
left join tmp_yz_zqb_p_cust_20220825_dim b on a.p_nbr=b.p_nbr
where a.p_nbr not in(select distinct p_nbr_202212 from tmp_yz_zqb_p_cust_6);

select p_nbr_202212,
cust_name,
subst_name,
bg_type,
bu_type,
prod_name_202212,
change_p_fee,
is_exist,
count(*) from tmp_yz_zqb_p_cust_7 group by p_nbr_202212,
cust_name,
subst_name,
bg_type,
bu_type,
prod_name_202212,
change_p_fee,
is_exist

--202401月数据
drop table if exists tmp_yz_zqb_p_cust_202404 purge; 
create table tmp_yz_zqb_p_cust_202404 as 
select 
cast(a.cust_id  as string) cust_id
,cast(b.party_nbr  as string) p_nbr

from (select distinct party_id,cust_id from dws_ecust.dws_party_zq_fcust_rel where city_id=200) a 
join (select distinct party_id,party_nbr from dws_ecust.dws_party_zq where city_id=200 ) b --P码省表
on a.party_id=b.party_id;

drop table if exists tmp_yz_zqb_p_cust_2 purge;
create table tmp_yz_zqb_p_cust_2 as 
select a.*,b.cust_id as cust_202401
from tmp_yz_zqb_p_cust_1 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=cast(b.serv_id as string) and b.par_month_id=202401 
;

drop table if exists tmp_yz_zqb_p_cust_3 purge;
create table tmp_yz_zqb_p_cust_3 as 
select a.*,b.p_nbr as p_nbr_202401
from tmp_yz_zqb_p_cust_2 a 
left join tmp_yz_zqb_p_cust_202404 b on cast(a.cust_202401 as string)=b.cust_id 
;

drop table if exists tmp_yz_zqb_p_cust_4 purge;
create table tmp_yz_zqb_p_cust_4 as 
select a.*,b.fee_sh 
from tmp_yz_zqb_p_cust_3 a 
left join (select serv_id,sum(fee_new_tax) fee_sh 
	from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202401 and par_month_id<=202401 group by serv_id) b 
	on a.serv_id=cast(b.serv_id as string)
;

drop table if exists tmp_yz_zqb_p_cust_5 purge;
create table tmp_yz_zqb_p_cust_5 as 
select * from tmp_yz_zqb_p_cust_4 
where p_nbr_202212<>coalesce(p_nbr_202401,'-1');



drop table if exists tmp_yz_zqb_p_cust_6 purge;
create table tmp_yz_zqb_p_cust_6 as 
select p_nbr_202212,prod_name_202212,sum(fee_sh) change_p_fee 
from tmp_yz_zqb_p_cust_5 group by p_nbr_202212,prod_name_202212;

drop table if exists tmp_yz_zqb_p_cust_202401 purge;
create table tmp_yz_zqb_p_cust_202401 as 
select a.*,b.cust_name,b.subst_name,b.bg_type,b.bu_type,'是' as is_exist  
from tmp_yz_zqb_p_cust_6 a 
left join tmp_yz_zqb_p_cust_dim b on a.p_nbr_202212=b.p_nbr;

insert into table tmp_yz_zqb_p_cust_202401 
select a.p_nbr
,cast(null as string) as prod_name_202212
,cast(null as decimal(32,2) ) as change_p_fee
,a.cust_name
,a.subst_name
,a.bg_type
,a.bu_type
,case when b.p_nbr is not null then '是' else '否' end as  is_exist
from tmp_yz_zqb_p_cust_dim a 
left join tmp_yz_zqb_p_cust_20220825_dim b on a.p_nbr=b.p_nbr
where a.p_nbr not in(select distinct p_nbr_202212 from tmp_yz_zqb_p_cust_6);

drop table if exists tmp_yz_zqb_p_cust_202401_dwb purge;
create table tmp_yz_zqb_p_cust_202401_dwb as 
select p_nbr_202212,
cust_name,
subst_name,
bg_type,
bu_type,
--prod_name_202212,
sum(change_p_fee) channge_fee,
is_exist
from tmp_yz_zqb_p_cust_202401 group by p_nbr_202212,
cust_name,
subst_name,
bg_type,
bu_type,
--prod_name_202212,
is_exist;

drop table if exists tmp_yz_zqb_p_cust_dwb purge;
create table tmp_yz_zqb_p_cust_dwb as 
select 202401 as par_month_id,a.* from tmp_yz_zqb_p_cust_202401 a;

insert into table tmp_yz_zqb_p_cust_dwb 
select 202402 as par_month_id,a.* from tmp_yz_zqb_p_cust_202402 a;

insert into table tmp_yz_zqb_p_cust_dwb 
select 202403 as par_month_id,a.* from tmp_yz_zqb_p_cust_202403 a;


select par_month_id  --月份
,p_nbr_202212  --P码
,prod_name_202212  --产品名称
,change_p_fee  --收入影响量
,cust_name  --客户名称
,subst_name  --局向
,bg_type  --BG类型
,bu_type  --BU
,is_exist  --是否在20220825维表中
from view_yz_zqb_p_cust_dwb where par_month_id=202401


--20240318  回溯后数据核查脚本  
select par_month_id,count(1) from ads_tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318  group by par_month_id order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwm_yz_tb_comm_cm_all_mon_final  group by par_month_id order by par_month_id LIMIT 1000
select par_month_id,count(1) from tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318  group by par_month_id order by par_month_id LIMIT 1000

select par_month_id,count(1) from ads_tmp_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_ndhs_20240318  group by par_month_id  order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwm_yz_rpt_comm_ba_subs_mon_final  group by par_month_id order by par_month_id LIMIT 1000

select par_month_id,count(1) from ads_tmp_huisu_dwm_yz_rpt_comm_ba_msdisc_mon_final_ndhs_20240318  group by par_month_id  order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwm_yz_rpt_comm_ba_msdisc_mon_final  group by par_month_id order by par_month_id LIMIT 1000

select par_month_id,count(1) from ads_tmp_dwd_yz_rpt_comm_cm_msdisc_mon_final_ndhs_20240318  group by par_month_id  order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwd_yz_rpt_comm_cm_msdisc_mon_final  group by par_month_id order by par_month_id LIMIT 1000

核对结果：数据量一致，核查通过

SELECT par_month_id,is_cancel_user, subst_name, count(1) 
FROM dwm_yz_tb_comm_cm_all_mon_final 
GROUP BY par_month_id,is_cancel_user, subst_name 
ORDER BY par_month_id,is_cancel_user, subst_name LIMIT 1000

SELECT par_month_id,is_cancel_user, subst_name, count(1) 
FROM ads_tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318 
GROUP BY par_month_id,is_cancel_user, subst_name 
ORDER BY par_month_id,is_cancel_user, subst_name LIMIT 1000

select par_month_id,count(1) from tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318 a 
join ads_yz_2024_ndhs_jz_list b on a.serv_id=b.serv_id and (
coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
or coalesce(a.grid_id,'-99')<>coalesce(b.grid_id,'-99')
or coalesce(a.grid_code,'-99')<>coalesce(b.grid_code,'-99')
or coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')

or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
or coalesce(a.cell_id,'-99')<>coalesce(b.cell_id,'-99')
or coalesce(a.cell_code,'-99')<>coalesce(b.cell_code,'-99')
or coalesce(a.ccenter,'-99')<>coalesce(b.ccenter,'-99')

or coalesce(a.subst_name,'-99')<>coalesce(b.subst_name,'-99')
or coalesce(a.branch_name,'-99')<>coalesce(b.branch_name,'-99')
or coalesce(a.grid_name,'-99')<>coalesce(b.grid_name,'-99')
or coalesce(a.region_type,'-99')<>coalesce(b.region_type,'-99')

or coalesce(a.is_mdz,'-99')<>coalesce(b.is_mdz,'-99')
or coalesce(a.bg_type,'-99')<>coalesce(b.bg_type,'-99')
or coalesce(a.bu_type,'-99')<>coalesce(b.bu_type,'-99')
or coalesce(a.cell_name,'-99')<>coalesce(b.cell_name,'-99')

or coalesce(a.std_subst_name,'-99')<>coalesce(b.std_subst_name,'-99')
or coalesce(a.std_branch_name,'-99')<>coalesce(b.std_branch_name,'-99')
or coalesce(a.area_name,'-99')<>coalesce(b.area_name,'-99')

or coalesce(a.cell_type,'-99')<>coalesce(b.cell_type,'-99')
or coalesce(a.cell_type_name,'-99')<>coalesce(b.cell_type_name,'-99')
)
group by par_month_id order by par_month_id
limit 1000



select par_month_id,count(1) from ads_tmp_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_ndhs_20240318 a
join ads_yz_2024_ndhs_jz_list b on a.serv_id=b.serv_id and (
coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
or coalesce(a.grid_id,'-99')<>coalesce(b.grid_id,'-99')
or coalesce(a.grid_code,'-99')<>coalesce(b.grid_code,'-99')
or coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')

or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
or coalesce(a.cell_id,'-99')<>coalesce(b.cell_id,'-99')
or coalesce(a.cell_code,'-99')<>coalesce(b.cell_code,'-99')
or coalesce(a.ccenter,'-99')<>coalesce(b.ccenter,'-99')

or coalesce(a.subst_name,'-99')<>coalesce(b.subst_name,'-99')
or coalesce(a.std_subst_name,'-99')<>coalesce(b.std_subst_name,'-99')
or coalesce(a.branch_name,'-99')<>coalesce(b.branch_name,'-99')
or coalesce(a.std_branch_name,'-99')<>coalesce(b.std_branch_name,'-99')
or coalesce(a.bg_type,'-99')<>coalesce(b.bg_type,'-99')
or coalesce(a.bu_type,'-99')<>coalesce(b.bu_type,'-99')
or coalesce(a.region_type,'-99')<>coalesce(b.region_type,'-99')
)
group by par_month_id order by par_month_id
limit 1000

select par_month_id,count(1) from ads_tmp_huisu_dwm_yz_rpt_comm_ba_msdisc_mon_final_ndhs_20240318 a
join ads_yz_2024_ndhs_jz_list b on a.serv_id=b.serv_id and (
coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
  or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
  or coalesce(a.cell_id,'-99')<>coalesce(b.cell_id,'-99')
or coalesce(a.cell_code,'-99')<>coalesce(b.cell_code,'-99')
or coalesce(a.grid_id,'-99')<>coalesce(b.grid_id,'-99')
or coalesce(a.grid_code,'-99')<>coalesce(b.grid_code,'-99')
or coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')
  or coalesce(a.bg_type,'-99')<>coalesce(b.bg_type,'-99')
  or coalesce(a.bu_type,'-99')<>coalesce(b.bu_type,'-99')
or coalesce(a.region_type,'-99')<>coalesce(b.region_type,'-99')
)
group by par_month_id order by par_month_id
limit 1000

select par_month_id,count(1) from ads_tmp_dwd_yz_rpt_comm_cm_msdisc_mon_final_ndhs_20240318 a
join ads_yz_2024_ndhs_jz_list b on a.serv_id=b.serv_id and (
coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')
or coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
)
group by par_month_id order by par_month_id
limit 1000

select par_month_id,count(1) from tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318 a
join tmp_huisu_final_dwm_yz_tb_comm_cm_all_sub13 b on a.cell_id=b.cell_id	
and (

 coalesce(a.cell_type,'-99')<>coalesce(b.cell_type,'-99')
or coalesce(a.cell_type_name,'-99')<>coalesce(b.cell_type_name,'-99')

)
group by par_month_id order by par_month_id
limit 1000

--差异很小才正常
select par_month_id,count(1),count(case when b.serv_id is not null then 1 else null end )
from ads_tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318 a
left join ads_yz_2024_ndhs_jz_list b
on a.serv_id=b.serv_id
--where a.grid_id<>-1
group by par_month_id order by par_month_id limit 1000

select par_month_id,count(1),count(case when b.cell_id is not null then 1 else null end )
from tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318 a
left join tmp_huisu_final_dwm_yz_tb_comm_cm_all_sub13 b
on a.cell_id=b.cell_id	
--where a.grid_id<>-1
group by par_month_id order by par_month_id limit 1000

select par_month_id,count(1),count(case when b.serv_id is not null then 1 else null end )
from ads_tmp_huisu_dwm_yz_rpt_comm_ba_msdisc_mon_final_ndhs_20240318 a
left join ads_yz_2024_ndhs_jz_list b
on a.serv_id=b.serv_id
--where a.grid_id<>-1
group by par_month_id order by par_month_id

select par_month_id,count(1),count(case when b.serv_id is not null then 1 else null end )
from ads_tmp_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_ndhs_20240318 a
left join ads_yz_2024_ndhs_jz_list b
on a.serv_id=b.serv_id
where a.grid_id<>-1
group by par_month_id order by par_month_id

select par_month_id,count(1),count(case when b.serv_id is not null then 1 else null end )
from ads_tmp_dwd_yz_rpt_comm_cm_msdisc_mon_final_ndhs_20240318 a
left join ads_yz_2024_ndhs_jz_list b
on a.serv_id=b.serv_id
--where a.grid_id<>-1
group by par_month_id order by par_month_id limit 1000

--核查在基准表没有的号码是否以前的责任田都是-1，是则正常
drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 as 
select a.par_month_id,a.action_id,a.serv_id,a.grid_id 
from ads_tmp_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_ndhs_20240318 a 
left join ads_yz_2024_ndhs_jz_list b on a.serv_id=b.serv_id 
where b.serv_id is null;

select par_month_id,action_id,count(1) c1,
sum(case when grid_id=-1 then 1 else 0 end) c2 
from tmp_yz_liq_1 group by par_month_id,action_id order by par_month_id,action_id limit 1000

--核查宽带有效活跃字段
回溯前
select a.par_month_id,
coalesce(b.is_yx_kd,0) is_yx,coalesce(b.is_hy_kd,0) is_hy
,count(distinct a.serv_id  ) as kd
from (select par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where  prod_type=40) a
left join 
(select par_month_id,serv_id
,coalesce(is_yx,0) as is_yx_kd  --是否省有效宽带
,coalesce(is_active_user,0) as is_hy_kd  --是否省活跃宽带
from summary_ods_month_city.tb_comm_cm_data_mon where par_corp_id=200 ) b
on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id 
group by a.par_month_id,coalesce(b.is_yx_kd,0) ,coalesce(b.is_hy_kd,0)  
order by a.par_month_id,coalesce(b.is_yx_kd,0) ,coalesce(b.is_hy_kd,0) 

回溯后
SELECT par_month_id,is_yx,is_hy,count(distinct serv_id)  num
FROM ads_tmp_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20240318 
where par_month_id>=202401 and prod_type=40
group by par_month_id ,is_yx,is_hy
order by par_month_id,is_yx,is_hy LIMIT 1000


--20240321  宽带日报穿透版 宽带净增  的 报表层 2月日数据局向回溯
宽带日报穿透版
select sum_date,count(1) from dwd_kd_rb_bao where sum_date>=20240218 group by sum_date  order by sum_date  limit 500
alter table zone_gz_yz.dwd_kd_rb_bao drop if exists partition(sum_date>=20240218,sum_date<=20240317);

--20240325  当月在网商企号码
select a.*
,case when b.serv_id is not null then '是' else '否' end as is_sq  --是否商企
from view_ads_yz_tb_comm_cm_all_final a 
left join (select distinct serv_id from view_ads_yz_rpt_comm_cm_msdisc_final 
where par_month_id=202403 
and prod_offer_id in(500067231,500068216,500068220,500069229,500069230,500069231,500069232,500069233,500069234,500069235,500070166,500071154) --商企套餐
and date_format(limit_date,'yyyyMMdd') > '20240324'  --商企套餐到期时间
) b
on a.serv_id=b.serv_id 
where a.par_month_id=202403 
and a.is_cancel_user=0  --在网
;


--20240327  快捷宽带子账号  XQGZ2024032601083
drop table if exists tmp_XQGZ2024032601083_01;
create table tmp_XQGZ2024032601083_01 as
select a.index6 acc_nbr,b.serv_id
from xxx a  --导入附件数据的表
left join dwm_yz_tb_comm_cm_all_final b
on b.par_month_id=202403 
and a.index6=b.acc_nbr;

--AZ关系
drop table if exists tmp_XQGZ2024032601083_02;
create table tmp_XQGZ2024032601083_02 as
select a.*,b.z_prod_inst_id
from tmp_XQGZ2024032601083_01 a
left join dws_crm_cust.dws_prod_inst_rel_a b on b.city_id='200' and b.a_prod_inst_id=a.serv_id;

--打标Z端信息
drop table if exists tmp_XQGZ2024032601083_03;
create table tmp_XQGZ2024032601083_03 as
select a.*
,b.acc_nbr acc_nbr_z
,b.is_rh_ykj
,b.rh_tc_value
,b.cell_code
,b.cell_name
,b.area_name
,b.open_date
,b.cust_nbr,
,b.serv_addr_id
(case when length(cust_name)<2 then cust_name when length(cust_name)=2 then concat(SUBSTR(cust_name,1,1),'*') when length(cust_name)>2 then concat(SUBSTR(cust_name,1,(length(cust_name)-2)),'**') else null end) as cust_name_tm
from tmp_XQGZ2024032601083_02 a
join dwm_yz_tb_comm_cm_all_final b
on b.par_month_id=202403
and a.z_prod_inst_id=b.serv_id
and b.prod_id=2340; --CZC子宽带

drop table if exists zone_gz_yz.tmp_XQGZ2024032601083_04 purge;
create table zone_gz_yz.tmp_XQGZ2024032601083_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select a.*,
(case when length(b.addr)<4 then b.addr
		when length(b.addr)=4 then concat(SUBSTR(b.addr,1,1),'*')
		when length(b.addr)>4 then concat(SUBSTR(b.addr,1,(length(b.addr)-4)),'****')
		else null end) as serv_addr_name
from zone_gz_yz.tmp_XQGZ2024032601083_03 a
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id;

create view view_XQGZ2024032601083 as
select acc_nbr_z  --子单接入号
,acc_nbr --主单接入号
,cell_name  --网格名称
,area_name  --包区名称
,case when is_rh_ykj=1 then '是' else '否' end is_rh_ykj, --是否融合
case when rh_tc_value>=129 then '是' else '否' end is_129, --是否129+
open_date  --入网时间
,cust_name_tm --客户名称(脱敏)
,cust_nbr  --客户编码
,serv_addr_name --地址名称
,serv_addr_id  --地址ID
from zone_gz_yz.tmp_XQGZ2024032601083_04;

子单接入号	主单接入号	网格名称	包区名称	客户名称	客户编码	地址名称	地址ID


--XQGZ2024031801899  闫亚莉  政法公安划小收入号码级清单
drop table if exists ads_yz_yal_zfga_srhx_list purge;
create table ads_yz_yal_zfga_srhx_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select 
month_id,serv_id,prod_id,subst_id,branch_id,area_id,grid_id,kh_subst_id
,a0,a0_sq,a0_sj,a0_fsg,a0_fsg_sq,a0_fsg_sj,a0_sg,a0_sg_sq,a0_sg_sj
,fee_nbr_sq,fee_nbr,fee_nonbr_sq,fee_nonbr,fee_cs_sq,fee_cs,a1_sq
,a1,a2_sq,a2,a3_sq,a3,a4_sq,a4,a5_sq,a5,a6_sq,a6,a7_sq,a7,a8_sq,a8
,a9_sq,a9,a10_sq,a10,a11_sq,a11,a12_sq,a12,a13_sq,a13,zq_charge_sq
,zq_charge,b1_sq,b1,b2_sq,b2,b3_sq,b3,b4_sq,b4,b5_sq,b5,b6_sq,b6
,fee_cs_sq_ycx,fee_cs_ycx,a0_ycx,a0_sq_ycx
,subst_name,kh_subst_name,branch_name,area_code,area_name,grid_code,grid_name,prod_name
,is_std_org,is_cancel_user,acc_nbr,acc_nbr2,std_subst_id,std_subst_name,std_branch_id
,std_branch_name,cell_id,cell_code,cell_name,cell_type,cell_type_name,region_type
,serv_grp_type,bg_type,bu_type,six_market,is_school_market_user,is_village_market_user
,prod_type,prod_type2,cust_id,cust_nbr

,(case when length(cust_name)<2 then cust_name
		when length(cust_name)=2 then concat(SUBSTR(cust_name,1,1),'*')
		when length(cust_name)>2 then concat(SUBSTR(cust_name,1,(length(cust_name)-2)),'**')
		else null end) as  cust_name_tm 
,cust_create_date,ccust_id,cust_code
,(case when length(ccust_name)<2 then ccust_name
		when length(ccust_name)=2 then concat(SUBSTR(ccust_name,1,1),'*')
		when length(ccust_name)>2 then concat(SUBSTR(ccust_name,1,(length(ccust_name)-2)),'**')
		else null end) as ccust_name_tm

,ccust_org,ccust_create_date,is_mdz,vpn_value,speed_value,open_date
,hist_create_date,sales_id,sales_code,sales_name,channel_id,channel_nbr,channel_name
,channel_subst_name,channel_branch_name,channel_type,serv_col2,serv_col2_code
,serv_col2_name,channel_type_2011,channel_subtype0_2011,channel_subtype_2011
,channel_subtype_flag,cdma_disc_type,cdma_disc_desc,kd_prod_offer_id,kd_prod_offer_name
,kd_desc,is_rh_ykj,rh_tc_id,rh_type_ykj,itv_type,is_vice_card,zk_serv_id,is_new_user
,state,star_level,is_cz,is_cz_last,is_yx,is_hy,is_contract,jz_points,tc_points,rh_tc_value
,zk_open_date,operators_nbr,operators_name,is_5g_disc,kd_serv_id,kd_acc_nbr,kd_subst_id
,kd_branch_id,kd_cell_code,kd_cell_name,kd_subst_name,kd_branch_name,yd_prod_type1
,yd_prod_type2,is_gsm,payment_id,payment_type,payment_method_desc,rw_month,new_flag
,prod_name_csp_crm,is_zqb_guishang_zx,is_shangke_guishang_zx,is_yuan_mingdanzhi_shangke_cq
,is_region_top50_cq,due_type,fee_fm,fee_fm_sq,load_date,fee_fm_tz,fee_fm_new,par_month_id 

from  dwm_srhx_serv_list_mon_final  where par_month_id>=202301 and bg_type='政法公安';

--20240401  天河温一恒临时需求
片区	月份	
当月新入网融合量	当月新入网融合其中主宽套餐价值积分
当月主宽拆机量	当月主宽拆机上月套餐价值积分	
当月主宽到达量	当月主宽到达套餐价值积分

--拆机
drop table if exists tmp_th_wyh_20240401_1 purge;
create table tmp_th_wyh_20240401_1 as 
select a.par_month_id,a.serv_id,a.subst_name,a.branch_name,a.area_name,a.kd_desc,
 (case when mod(a.par_month_id,100)<>1 then (a.par_month_id-1)
          else (a.par_month_id-89) end) last_month
from dwm_yz_tb_comm_cm_all_mon_final a where is_wl_cancel_user=1 
and prod_type=40 and kd_desc='普通宽带' 
and par_month_id>=202201 and par_month_id<=202312;

drop table if exists tmp_th_wyh_20240401 purge;
create table tmp_th_wyh_20240401 as 
select a.*,b.rh_tc_value,b.is_rh_ykj,b.rh_type_ykj
from tmp_th_wyh_20240401_1 a
left join dwm_yz_tb_comm_cm_all_mon_final b
on a.serv_id=b.serv_id and a.last_month=b.par_month_id;

drop table if exists tmp_th_wyh_20240401_dwb_1 purge;
create table tmp_th_wyh_20240401_dwb_1 as 
select area_name,par_month_id 
,0 as xkxy,0 as zk_xkxy_tc_value 
,count(distinct serv_id) zk_cj, --当月主宽拆机量
sum(rh_tc_value) zk_cj_tc_value --当月主宽拆机上月套餐价值积分	
,0 as zk_dd,0 as zk_dd_tc_value
from tmp_th_wyh_20240401 where subst_name='天河分公司' 
group by area_name,par_month_id ;

--新入网融合（新宽新移）
insert into table tmp_th_wyh_20240401_dwb_1 
select area_name,par_month_id,
count(distinct serv_id) xkxy,--当月新入网融合量
sum(case when kd_desc='普通宽带' then rh_tc_value else 0 end) zk_xkxy_tc_value --当月新入网融合其中主宽套餐价值积分
,0 as zk_cj,0 as zk_cj_tc_value 
,0 as zk_dd,0 as zk_dd_tc_value
from dwm_yz_tb_comm_cm_all_mon_final a where is_cancel_user=0  
and prod_type=40 and is_rh_ykj>0 and COALESCE(itv_type,-1) not in(0,1)
and rh_type_ykj='新宽带新移动'
and subst_name='天河分公司'
and par_month_id>=202201 and par_month_id<=202312 
group by area_name,par_month_id ;

--主宽到达
insert into table tmp_th_wyh_20240401_dwb_1 
select area_name,par_month_id 
,0 as xkxy,0 as zk_xkxy_tc_value 
,0 as zk_cj,0 as zk_cj_tc_value 
,count(distinct serv_id) zk_dd,  --当月主宽到达量
sum(rh_tc_value) zk_dd_tc_value --当月主宽到达套餐价值积分

from dwm_yz_tb_comm_cm_all_mon_final a 
where is_cancel_user=0 and is_cz=1
and prod_type=40 and kd_desc='普通宽带'
and subst_name='天河分公司'
and par_month_id>=202201 and par_month_id<=202312 
group by area_name,par_month_id ;

--汇总
drop table if exists tmp_th_wyh_20240401_dwb purge;
create table tmp_th_wyh_20240401_dwb as 
select area_name,par_month_id 
,sum(xkxy) as value1,sum(zk_xkxy_tc_value) as value2
,sum(zk_cj) as value3,sum(zk_cj_tc_value) as value4
,sum(zk_dd) as value5,sum(zk_dd_tc_value) as value6 
from tmp_th_wyh_20240401_dwb_1 
group by area_name,par_month_id 
order by par_month_id,area_name;

--创建视图
create view view_tmp_th_wyh_20240401_dwb as 
select * from zone_gz_yz.tmp_th_wyh_20240401_dwb;

select area_name --片区
,par_month_id  --月份
,value1  --当月新入网融合量	
,value2  --当月新入网融合其中主宽套餐价值积分
,value3  --当月主宽拆机量
,value4  --当月主宽拆机上月套餐价值积分
,value5  --当月主宽到达量
,value6  --当月主宽到达套餐价值积分
from view_tmp_th_wyh_20240401_dwb


--20240401  蔡婷 XQGZ2024032902168  用医保机构名称或地址匹是否有医保专线

--匹银行账户名称
--VPDN产品，限定域名@gzybw.v.gd
drop table if exists zone_gz_yz.tmp_yz_liq_1 purge;
create table zone_gz_yz.tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.serv_id,a.serv_addr_id,substring(a.acc_nbr2,instr(a.acc_nbr2,'@')+1,length(a.acc_nbr2)) as ym
,b.acct_id 
,c.addr
from dwm_yz_tb_comm_cm_all_final a
left join dws_crm_cust.dws_prod_inst_acct_rel_aap b on a.serv_id = b.prod_inst_id and b.city_id=200 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) c on cast(a.serv_addr_id as decimal(24,0))=c.id 
where a.par_month_id=202403 and a.is_cancel_user=0;

drop table if exists zone_gz_yz.tmp_yz_liq_2 purge;
create table zone_gz_yz.tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.* 
,c.pay_acct_name  --银行账户名称
from tmp_yz_liq_1 a 
left join dws_crm_cust.dws_payment_plan b on a.acct_id = b.acct_id and b.city_id=200 
left join dws_crm_cust.dws_ext_acct c on b.pay_acct_id = c.ext_acct_id and c.city_id=200 ;

--AZ关系
drop table if exists tmp_yz_liq_3 purge;
create table zone_gz_yz.tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.a_prod_inst_id
from tmp_yz_liq_2 a
left join dws_crm_cust.dws_prod_inst_rel_grp_a b on b.city_id=200  and cast(a.serv_id as string)=b.z_prod_inst_id;

--MPLS VPN产品，限定群号 grp_acc_nbr='GVPN2063605620'
drop table if exists tmp_yz_liq_4 purge;
create table zone_gz_yz.tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,b.acc_nbr as grp_acc_nbr 
from tmp_yz_liq_3 a 
left join dwm_yz_tb_comm_cm_all_final b on b.par_month_id=202403 and a.a_prod_inst_id=b.serv_id;

drop table if exists tmp_yz_liq_5 purge;
create table zone_gz_yz.tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,case when b.pay_acct_name is not null then 1 else 0 end as is_MPLS_VPN_1
,case when c.pay_acct_name is not null then 1 else 0 end as is_VPDN_1
from tmp_yz_cait_dim_yibao a --蔡婷提供的医保机构和地址
left join (select distinct pay_acct_name from tmp_yz_liq_4 where grp_acc_nbr='GVPN2063605620') b on a.index2=b.pay_acct_name
left join (select distinct pay_acct_name from tmp_yz_liq_4 where ym='gzybw.v.gd') c on a.index2=c.pay_acct_name
;

drop table if exists tmp_yz_liq_6 purge;
create table zone_gz_yz.tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,case when b.addr is not null then 1 else 0 end as is_MPLS_VPN_2
,case when c.addr is not null then 1 else 0 end as is_VPDN_2
from tmp_yz_liq_5 a 
left join (select distinct addr from tmp_yz_liq_4 where grp_acc_nbr='GVPN2063605620') b on a.index3=b.addr
left join (select distinct addr from tmp_yz_liq_4 where ym='gzybw.v.gd') c on a.index3=c.addr
;

--只有银行账户名称能匹出来，is_MPLS_VPN=是有89个，is_VPDN=是有35个
drop table if exists tmp_yz_liq_7 purge;
create table zone_gz_yz.tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when a.is_MPLS_VPN_1+a.is_MPLS_VPN_2>0 then '是' else '否' end as is_MPLS_VPN
,case when a.is_VPDN_1+a.is_VPDN_2>0 then '是' else '否' end as is_VPDN 
from tmp_yz_liq_6 a;

select  index1 --所在区
,index2  --机构名称
,index3  --单位地址
,is_mpls_vpn  --是否有MPLS VPN医保专线
,is_vpdn   --是否有VPDN医保专线
from tmp_yz_liq_7 where  is_mpls_vpn='是' or is_vpdn='是' limit 1000

zdw_XQGZ2024040701119_haoma--湛哥的号码清单
1、先用dwm_yz_tb_comm_cm_all_mon_final直接匹入网月份的地址ID serv_addr_id as rw_addr_id_1， cast(a.order_date as int)/100=b.par_month_id and a.acc_nbr=b.acc_nbr and b.is_new_user=1
2、用省入网订单补打历史入网号码
--新建入网订单表并排序
drop table xxx_1
create table 
select date_format(subs_stat_date,'yyyyMMdd') as rw_date,acc_nbr,serv_addr_id
,row_number() over(partition by acc_nbr order by subs_stat_date desc) as paixu 
from summary_ods_day_city.rpt_comm_ba_subs_hist_all a 
left join (select distinct acc_nbr,order_date from zdw_XQGZ2024040701119_haoma) b 
on a.acc_nbr=b.acc_nbr and date_format(a.subs_stat_date,'yyyyMMdd')=b.order_date
where subs_stat = '301200'
and subs_stat_reason not in( '1200','1300' )  --非撤单/非作废
and action_type = 'NEW' 
; 

--入网地址id
select a.*,case when a.rw_addr_id_1 is null then b.serv_addr_id else a.rw_addr_id_1 end as rw_addr_id
from zdw_XQGZ2024040701119_haoma a 
left join xxx_1 b on a.acc_nbr=b.acc_nbr and b.paixu=1;

3、用dwm_yz_tb_comm_cm_all_mon_final直接匹当前月份（202404月）的地址ID serv_addr_id， b.par_month_id=202404 and a.acc_nbr=b.acc_nbr 


--20240409  刘丽娜  主宽到达和融合到达数
月份（202303月，6月，9月，12月，202403月），划小分局，是否融合，六大网格，套餐档次，是否千兆,宽带到达数


drop table if exists tmp_yz_lln_zk_rh_dwb_1 purge;
create table zone_gz_yz.tmp_yz_lln_zk_rh_dwb_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,subst_name
,case when is_rh_ykj>0 then '是' else '否' end as is_rh
,region_type
,case when coalesce(a.rh_tc_value,0)<129 then '[0,129)'  
		when coalesce(a.rh_tc_value,0)>=129 and coalesce(a.rh_tc_value,0)<199 then '[129,199)' 
		when coalesce(a.rh_tc_value,0)>=199 and coalesce(a.rh_tc_value,0)<299 then '[199,299)'  
		when coalesce(a.rh_tc_value,0)>=299 then '299及以上' end jf_dangci 
,case when speed_value>=1000 then '是' else '否' end as is_qz 
,kd_desc
,serv_id
from dwm_yz_tb_comm_cm_all_mon_final a
where par_month_id=202404 and prod_type=40
AND coalesce(prod_type2,-1) NOT IN (50) -- 剔除ITV 
AND coalesce(prod_type2,-1) NOT IN (60, 70, 71) -- 剔除专线 
and prod_id not in (select prod_id  from dws_crm_cfguse.dws_product where coalesce(prod_name, '-1') like '%城域网%')--剔除城域网
AND is_cancel_user = 0 -- 在网 
;	

--drop table if exists tmp_yz_lln_zk_rh_dwb purge;
insert into table zone_gz_yz.tmp_yz_lln_zk_rh_dwb 		
select par_month_id,subst_name,is_rh,region_type,jf_dangci,is_qz
,count(distinct serv_id) num 
from tmp_yz_lln_zk_rh_dwb_1 where kd_desc='普通宽带'
group by par_month_id,subst_name,is_rh,region_type,jf_dangci,is_qz;

drop view if exists view_yz_lln_zk_rh_dwb purge;
create view view_yz_lln_zk_rh_dwb as 
select * from zone_gz_yz.tmp_yz_lln_zk_rh_dwb;

select par_month_id --月份
,subst_name  --划小分局
,is_rh  --是否融合
,region_type  --六大网格
,jf_dangci  --套餐档次
,is_qz  --是否千兆
,num  --主宽到达数
from view_yz_lln_zk_rh_dwb


--20240411  备份共用报表层数据表，压缩重建表
drop table if exists ads_yz_rpt_result_bak purge ;
create table zone_gz.ads_yz_rpt_result_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select * from zone_gz_yz.ads_yz_rpt_result;


drop table if exists zone_gz_yz.ads_yz_rpt_result_bak purge;
create table if not exists zone_gz_yz.ads_yz_rpt_result_bak
(
day_id decimal(22,0),
item_id decimal(22,0),
item_name string,
load_time string,
subst_id decimal(22,0),
branch_id decimal(22,0),
org_id decimal(22,0),
subst_name string,
branch_name string,
org_name string,
area_id decimal(22,0),
dim1 string,
dim2 string,
dim3 string,
dim4 string,
dim5 string,
dim6 string,
dim7 string,
dim8 string,
dim9 string,
dim10 string,
value1 decimal(22,4),
value2 decimal(22,4),
value3 decimal(22,4),
value4 decimal(22,4),
value5 decimal(22,4),
value6 decimal(22,4),
value7 decimal(22,4),
value8 decimal(22,4),
value9 decimal(22,4),
value10 decimal(22,4),
value11 decimal(22,4),
value12 decimal(22,4),
value13 decimal(22,4),
value14 decimal(22,4),
value15 decimal(22,4),
value16 decimal(22,4),
value17 decimal(22,4),
value18 decimal(22,4),
value19 decimal(22,4),
value20 decimal(22,4),
value21 decimal(22,4),
value22 decimal(22,4),
value23 decimal(22,4),
value24 decimal(22,4),
value25 decimal(22,4),
value26 decimal(22,4),
value27 decimal(22,4),
value28 decimal(22,4),
value29 decimal(22,4),
value30 decimal(22,4),
value31 decimal(22,4),
value32 decimal(22,4),
value33 decimal(22,4),
value34 decimal(22,4),
value35 decimal(22,4),
value36 decimal(22,4),
value37 decimal(22,4),
value38 decimal(22,4),
value39 decimal(22,4),
value40 decimal(22,4),
value41 decimal(22,4),
value42 decimal(22,4),
value43 decimal(22,4),
value44 decimal(22,4),
value45 decimal(22,4),
value46 decimal(22,4),
value47 decimal(22,4),
value48 decimal(22,4),
value49 decimal(22,4),
value50 decimal(22,4)
)comment '帆软公共报表层'
partitioned by
(
sum_date string comment '分区日期',
item_nbr string comment '分区报表编码'
)
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy');


insert overwrite table ads_yz_rpt_result_bak
select
day_id,item_id,item_name,load_time,subst_id,branch_id,org_id
,subst_name,branch_name,org_name,area_id
,dim1,dim2,dim3,dim4,dim5,dim6,dim7,dim8,dim9,dim10
,value1,value2,value3,value4,value5,value6,value7,value8,value9,value10
,value11,value12,value13,value14,value15,value16,value17,value18,value19,value20
,value21,value22,value23,value24,value25,value26,value27,value28,value29,value30
,value31,value32,value33,value34,value35,value36,value37,value38,value39,value40
,value41,value42,value43,value44,value45,value46,value47,value48,value49,value50
,sum_date,item_nbr
from ads_yz_rpt_result a;


--20240411 XQGZ2024032802407  
1、清单：全业务资料表 ads_yz_tb_comm_cm_all_final
2、条件：限定政企客户，客户名称关键词“酒店、公寓、民宿”，限定公司名客户、非校园、非拆机、非公免公纳

drop table if exists tmp_XQGZ2024032802407_1 purge;
create table tmp_XQGZ2024032802407_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,serv_id,subst_name,cast(date_format(open_date,'yyyyMM') as int) as open_month
from dwm_yz_tb_comm_cm_all_final 
where par_month_id=202404 
and prod_type=10 --固话
and is_gsm=1 --限定公司名客户
and serv_grp_type='01' --限定政企客户
and (cust_name like '%酒店%' or cust_name like '%公寓%' or cust_name like '%民宿%') --客户名称关键词“酒店、公寓、民宿”
and coalesce(kd_desc,'-1') not in('校园翼起来') --非校园
and is_cancel_user=0 --非拆机
and coalesce(fee_id,-1) not in (1,2)  --非公免公纳
;

drop table if exists tmp_XQGZ2024032802407_2 purge;
create table tmp_XQGZ2024032802407_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,(cast(cast(par_month_id as int)/100 as int)-cast(cast(open_month as int)/100 as int))*12
+(cast(substr(par_month_id,5,6) as int)-cast(substr(open_month,5,6) as int)) mm_diff --在网月份
from tmp_XQGZ2024032802407_1;

固话套餐月均出账：给上面的固话号码匹近六个月的总出账收入/6，如果入网至今不满6月，则入网至今的总出账收入/（当前月-入网月）
固话套餐月均收入：给上面的固话号码匹近六个月的总税后确认收入/6，如果入网至今不满6月，则入网至今的总税后确认收入/（当前月-入网月）
drop table if exists tmp_XQGZ2024032802407_3 purge;
create table tmp_XQGZ2024032802407_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select serv_id,sum(fee) as cz_sr --出账收入
,sum(fee_new_tax) as sh_sr --税后确认收入
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202310 and par_month_id<=202403 
and is_cancel_user=0 and prod_type=10 group by serv_id
;

drop table if exists tmp_XQGZ2024032802407_4 purge;
create table tmp_XQGZ2024032802407_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,case when a.mm_diff>=6 and b.cz_sr is not null then b.cz_sr/6 
	when a.mm_diff>0 and a.mm_diff<6 and b.cz_sr is not null then b.cz_sr/a.mm_diff else null end as yj_cz_sr --月均出账收入
,case when a.mm_diff>=6 and b.sh_sr is not null then b.sh_sr/6 
	when a.mm_diff>0 and a.mm_diff<6 and b.sh_sr is not null then b.sh_sr/a.mm_diff else null end as yj_sh_sr --月均税后确认收入
from tmp_XQGZ2024032802407_2 a 
left join tmp_XQGZ2024032802407_3 b on a.serv_id=b.serv_id;

灏鑫，这个单我已经和陈冠文聊过了，脚本也写好了，你最后出个多维表：划小县分/中心	、固话业务量、固话套餐月均出账、固话套餐月均收入
再问问这个是临时出的，还是要长期的，如果是长期的话赋权一个视图给她就行，行数肯定不超过500的，临时的就直接贴数给她

--20240416  张晓明  副宽对应销售品，再取对应移动主卡的融合套餐积分
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;  --  关闭向量化查询
set hive.vectorized.execution.reduce.enabled=false; --  关闭向量化查询

--抽取商企副宽入网号码
drop table if exists zone_gz_yz.tmp_yz_zxm_1 purge; 
create table zone_gz_yz.tmp_yz_zxm_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select
par_month_id,
is_sheng_yx,
is_hy,
serv_id

FROM zone_gz_yz.ads_yz_kd_new_list 
WHERE par_month_id between 202401 and 202403
AND kd_desc = '普通宽带' 
AND fk_lx = '商企'
AND coalesce(prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(kd_prod_offer_name, '-1') NOT LIKE '%0时长%' 
;

--抽取202401月副宽销售品涉及的号码
drop table if exists zone_gz_yz.tmp_yz_zxm_2 purge; 
create table zone_gz_yz.tmp_yz_zxm_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select t.par_month_id,t.serv_id,t.prod_id,t.msinfo_id
from 
(select a.par_month_id,a.serv_id,a.prod_id,a.msinfo_id
,row_number() over(partition by a.serv_id order by b.type_id asc) type_row
from dwd_yz_rpt_comm_cm_msdisc_mon_final a
join dwd_dim_dzkd_offer b
on a.prod_offer_id=b.prod_offer_id and b.type='副宽'
where a.par_month_id=202401
and date_format(a.create_date,'yyyyMMdd') <= '20240131'
and date_format(a.limit_date,'yyyyMMdd') > '20240131'
) t
where t.type_row=1
;

--抽取202402月副宽销售品涉及的号码
insert into table zone_gz_yz.tmp_yz_zxm_2
select t.par_month_id,t.serv_id,t.prod_id,t.msinfo_id
from 
(select a.par_month_id,a.serv_id,a.prod_id,a.msinfo_id
,row_number() over(partition by a.serv_id order by b.type_id asc) type_row
from dwd_yz_rpt_comm_cm_msdisc_mon_final a
join dwd_dim_dzkd_offer b
on a.prod_offer_id=b.prod_offer_id and b.type='副宽'
where a.par_month_id=202402
and date_format(a.create_date,'yyyyMMdd') <= '20240229'
and date_format(a.limit_date,'yyyyMMdd') > '20240229'
) t
where t.type_row=1
;
--抽取202403月副宽销售品涉及的号码
insert into table zone_gz_yz.tmp_yz_zxm_2
select t.par_month_id,t.serv_id,t.prod_id,t.msinfo_id
from 
(select a.par_month_id,a.serv_id,a.prod_id,a.msinfo_id
,row_number() over(partition by a.serv_id order by b.type_id asc) type_row
from dwd_yz_rpt_comm_cm_msdisc_mon_final a
join dwd_dim_dzkd_offer b
on a.prod_offer_id=b.prod_offer_id and b.type='副宽'
where a.par_month_id=202403
and date_format(a.create_date,'yyyyMMdd') <= '20240331'
and date_format(a.limit_date,'yyyyMMdd') > '20240331'
) t
where t.type_row=1
;

--打标副宽销售品号码的是否副卡、融合套餐积分和产品大类
drop table if exists zone_gz_yz.tmp_yz_zxm_3 purge; 
create table zone_gz_yz.tmp_yz_zxm_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,b.is_vice_card  --是否副卡
,b.rh_tc_value  --融合套餐积分
,b.prod_type   --产品大类
from tmp_yz_zxm_2 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.par_month_id=b.par_month_id and a.serv_id=b.serv_id 
;

drop table if exists zone_gz_yz.tmp_yz_zxm_4 purge; 
create table zone_gz_yz.tmp_yz_zxm_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,b.serv_id fk_serv_id --副宽销售品的移动主卡对应的副宽号码（即同个副宽销售品套餐内）
from tmp_yz_zxm_3 a 
left join (select distinct par_month_id,serv_id,msinfo_id from tmp_yz_zxm_3 where prod_type=40) b 
on a.msinfo_id=b.msinfo_id and a.par_month_id=b.par_month_id
where a.prod_id in(3204,3205) and a.is_vice_card=0;

--将移动主卡的融合套餐积分打回1表的副宽号码
drop table if exists zone_gz_yz.tmp_yz_zxm_5 purge; 
create table zone_gz_yz.tmp_yz_zxm_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.rh_tc_value 
from tmp_yz_zxm_1 a 
left join tmp_yz_zxm_4 b on a.serv_id=b.fk_serv_id and a.par_month_id=b.par_month_id
;

--输出
select
par_month_id,
is_sheng_yx,
is_hy,
count(distinct serv_id) as v1,
count(distinct case when rh_tc_value >= 239 and rh_tc_value < 399 then serv_id else null end) v2,
count(distinct case when rh_tc_value >= 399 and rh_tc_value < 699 then serv_id else null end) v3,
count(distinct case when rh_tc_value >= 699 and rh_tc_value <999 then serv_id else null end) v4,
count(distinct case when rh_tc_value >= 999 then serv_id else null end) v5
FROM zone_gz_yz.tmp_yz_zxm_5 

GROUP BY par_month_id,is_sheng_yx,is_hy

--20240416  尤鸿贵  快捷宽带
drop table if exists zone_gz_yz.tmp_yz_liq_3 purge; 
create table zone_gz_yz.tmp_yz_liq_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select serv_id,case when is_rh_ykj>0 then '是' else '否' end as is_rh 
from dwm_yz_tb_comm_cm_all_mon_final where (prod_type3='快捷宽带' or prod_id=2340) and par_month_id=202303 and is_new_user=1;


--t+n在网数
drop table if exists zone_gz_yz.tmp_yz_liq_4 purge; 
create table zone_gz_yz.tmp_yz_liq_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,case when b.serv_id is not null then 1 else 0 end as t_1_zw
,case when c.serv_id is not null then 1 else 0 end as t_2_zw
,case when d.serv_id is not null then 1 else 0 end as t_3_zw
from tmp_yz_liq_3 a 
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202304) b on a.serv_id=b.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202305) c on a.serv_id=c.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202306) d on a.serv_id=d.serv_id
;

drop table if exists zone_gz_yz.tmp_yz_liq_5 purge; 
create table zone_gz_yz.tmp_yz_liq_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,case when b.serv_id is not null then 1 else 0 end as t_4_zw
,case when c.serv_id is not null then 1 else 0 end as t_5_zw
,case when d.serv_id is not null then 1 else 0 end as t_6_zw
from tmp_yz_liq_4 a 
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202307) b on a.serv_id=b.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202308) c on a.serv_id=c.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202309) d on a.serv_id=d.serv_id
;

drop table if exists zone_gz_yz.tmp_yz_liq_6 purge; 
create table zone_gz_yz.tmp_yz_liq_6
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,case when b.serv_id is not null then 1 else 0 end as t_7_zw
,case when c.serv_id is not null then 1 else 0 end as t_8_zw
,case when d.serv_id is not null then 1 else 0 end as t_9_zw
from tmp_yz_liq_5 a 
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202310) b on a.serv_id=b.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202311) c on a.serv_id=c.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202312) d on a.serv_id=d.serv_id
;

drop table if exists zone_gz_yz.tmp_yz_liq_7 purge; 
create table zone_gz_yz.tmp_yz_liq_7
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,case when b.serv_id is not null then 1 else 0 end as t_10_zw
,case when c.serv_id is not null then 1 else 0 end as t_11_zw
,case when d.serv_id is not null then 1 else 0 end as t_12_zw
from tmp_yz_liq_6 a 
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202401) b on a.serv_id=b.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202402) c on a.serv_id=c.serv_id
left join (select distinct par_month_id,serv_id from dwm_yz_tb_comm_cm_all_mon_final where is_Cancel_user=0 and prod_type=40 and par_month_id=202403) d on a.serv_id=d.serv_id
;

select is_rh,count(distinct serv_id) rw_202303 
,sum(t_1_zw)as t_1_zwl, sum(t_2_zw)as t_2_zwl, sum(t_3_zw) as t_3_zwl, sum(t_4_zw)as t_4_zwl,
sum(t_5_zw)as t_5_zwl,
sum(t_6_zw)as t_6_zwl,sum(t_7_zw)as t_7_zwl,sum(t_8_zw)as t_8_zwl,
sum(t_9_zw) as t_9_zwl, sum(t_10_zw) as t_10_zwl, sum(t_11_zw) as t_11_zwl, sum(t_12_zw) as t_12_zwl 
from tmp_yz_liq_7 group by is_rh 

--20240417  南沙移机需求  移机宽表新增字段  XQGZ2024040900584
create view view_ns_yz_rpt_comm_ba_subs_move_final_junei as 
select * from zone_gz_yz.dwd_yz_rpt_comm_ba_subs_move_final 
where par_month_id>=202310 and subst_id=4174 and subst_id_last=4174 ;

揽装人、揽装编码、揽装所属局向、客户编码、网点名称、网点编码、套餐积分、套餐收入

alter table zone_gz_yz.dwd_yz_rpt_comm_ba_subs_move_final add columns() cascade;


--20240424  宽带新装清单用3月机构信息补打2月

--备份
drop table if exists ads_yz_kd_new_list_20240424 purge;
create table ads_yz_kd_new_list_20240424 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_kd_new_list;

--补打
--非-200和940201816的局向等字段不变
drop table if exists tmp_yz_kd_new_list_20240424 purge;
create table tmp_yz_kd_new_list_20240424 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_kd_new_list_20240424 where par_month_id=202402 and coalesce(subst_id,-1000) not in(-200,940201816);

--【-200和940201816】的局向等字段用大宽表的202403月补打
insert into table tmp_yz_kd_new_list_20240424 
select 
a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id,a.subs_code,a.subs_stat_date
,case when b.serv_id is not null then b.subst_id  else a.subst_id  end  subst_id
,case when b.serv_id is not null then b.subst_name  else a.subst_name end  subst_name
,case when b.serv_id is not null then b.branch_id else a.branch_id end  branch_id
,case when b.serv_id is not null then b.branch_name  else a.branch_name end  branch_name
,case when b.serv_id is not null then b.area_id   else a.area_id end  area_id
,case when b.serv_id is not null then b.area_name else a.area_name end area_name
,case when b.serv_id is not null then b.grid_id   else a.grid_id end  grid_id
,case when b.serv_id is not null then b.grid_code  else a.grid_code end  grid_code
,case when b.serv_id is not null then b.grid_name else a.grid_name end  grid_name
,case when b.serv_id is not null then b.region_type  else a.region_type end  region_type
,case when b.serv_id is not null then b.std_subst_id  else a.std_subst_id end  std_subst_id
,case when b.serv_id is not null then b.std_subst_name  else a.std_subst_name end  std_subst_name
,case when b.serv_id is not null then b.std_branch_id  else a.std_branch_id end  std_branch_id
,case when b.serv_id is not null then b.std_branch_name  else a.std_branch_name end  std_branch_name
,case when b.serv_id is not null then b.cell_id   else a.cell_id end  cell_id
,case when b.serv_id is not null then b.cell_code  else a.cell_code end  cell_code
,case when b.serv_id is not null then b.cell_name  else a.cell_name end  cell_name
,case when b.serv_id is not null then b.cell_type_name  else a.cell_type_name end  cell_type_name

,a.bg_type
,a.bu_type
,a.is_mdz
,a.six_market,a.serv_grp_type
,a.sales_code,a.sales_name,a.channel_id,a.channel_nbr,a.channel_name,a.channel_subst_name
,a.channel_branch_name,a.channel_area_name,a.channel_region_type,a.channel_type_2011
,a.channel_subtype_2011,a.channel_subtype0_2011,a.state,a.prod_id,a.is_zhuanxian,a.kd_desc
,a.prod_type3,a.prod_type2,a.itv_type,a.kd_prod_offer_id,a.speed_value,a.jz_points,a.is_rh_ykj
,a.rh_tc_value,a.acc_nbr2,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name,a.cust_code,a.ccust_name
,a.ccust_org,a.is_gsm,a.serv_addr_id,a.serv_addr_name,a.addr_id_7,a.open_date,a.is_sk_xjd,a.is_ljsp
,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name,a.six_market_desc
,a.serv_grp_type_desc,a.channel_subtype_flag,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd
,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1,a.xx_salestaff_code1,a.xx_salestaff_name1
,a.xx_salestaff_id2,a.xx_salestaff_code2,a.xx_salestaff_name2,a.ycx_offer_type
,a.own_operators_nbr,a.own_operators_name,a.is_zhuangwei,a.is_sheng_yx,a.cdma_disc_type3_name
,a.label_name,a.load_date,a.fk_lx,a.fk_value,a.kd_ll,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce
,a.is_region,a.is_channel,a.par_month_id,a.par_sum_date

from 
(select * from ads_yz_kd_new_list_20240424 where par_month_id=202402 and subst_id in(-200,940201816)) a

left join dwm_yz_tb_comm_cm_all_mon_final b
on a.serv_id=b.serv_id and b.par_month_id=202403; 

--插入补打后的202402月数据
alter table ads_yz_kd_new_list drop if exists partition(par_month_id=202402);
insert into table ads_yz_kd_new_list partition(par_month_id='202402',par_sum_date='20240229')
(sum_date,month_id,serv_id,acc_nbr,subs_id,subs_code,subs_stat_date,subst_id
,subst_name,branch_id,branch_name,area_id,area_name,grid_id,grid_code,grid_name
,region_type,std_subst_id,std_subst_name,std_branch_id,std_branch_name,cell_id
,cell_code,cell_name,cell_type_name,bg_type,bu_type,is_mdz,six_market,serv_grp_type
,sales_code,sales_name,channel_id,channel_nbr,channel_name,channel_subst_name
,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011
,channel_subtype_2011,channel_subtype0_2011,state,prod_id,is_zhuanxian,kd_desc
,prod_type3,prod_type2,itv_type,kd_prod_offer_id,speed_value,jz_points,is_rh_ykj
,rh_tc_value,acc_nbr2,fttx_type,cust_id,cust_nbr,cust_name,cust_code,ccust_name
,ccust_org,is_gsm,serv_addr_id,serv_addr_name,addr_id_7,open_date,is_sk_xjd,is_ljsp
,is_yqjq,prod_name,kd_prod_offer_code,kd_prod_offer_name,six_market_desc
,serv_grp_type_desc,channel_subtype_flag,grid_unit_area_id,mgr_area_id,is_xjd
,sales_id,rh_type_ykj,xx_salestaff_id1,xx_salestaff_code1,xx_salestaff_name1
,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,ycx_offer_type
,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,cdma_disc_type3_name
,label_name,load_date,fk_lx,fk_value,kd_ll,kd_sc,is_hy,fee_shebei,fee_tiaoce,is_region,is_channel)
select sum_date,month_id,serv_id,acc_nbr,subs_id,subs_code,subs_stat_date,subst_id,subst_name
,branch_id,branch_name,area_id,area_name,grid_id,grid_code,grid_name,region_type,std_subst_id
,std_subst_name,std_branch_id,std_branch_name,cell_id,cell_code,cell_name,cell_type_name
,bg_type,bu_type,is_mdz,six_market,serv_grp_type,sales_code,sales_name,channel_id,channel_nbr
,channel_name,channel_subst_name,channel_branch_name,channel_area_name,channel_region_type
,channel_type_2011,channel_subtype_2011,channel_subtype0_2011,state,prod_id,is_zhuanxian
,kd_desc,prod_type3,prod_type2,itv_type,kd_prod_offer_id,speed_value,jz_points,is_rh_ykj
,rh_tc_value,acc_nbr2,fttx_type,cust_id,cust_nbr,cust_name,cust_code,ccust_name,ccust_org
,is_gsm,serv_addr_id,serv_addr_name,addr_id_7,open_date,is_sk_xjd,is_ljsp,is_yqjq,prod_name
,kd_prod_offer_code,kd_prod_offer_name,six_market_desc,serv_grp_type_desc,channel_subtype_flag
,grid_unit_area_id,mgr_area_id,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1,xx_salestaff_code1
,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,ycx_offer_type
,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,cdma_disc_type3_name,label_name
,load_date,fk_lx,fk_value,kd_ll,kd_sc,is_hy,fee_shebei,fee_tiaoce,is_region,is_channel
from tmp_yz_kd_new_list_20240424;

--20240424  林彩虹  补打拆机机构
drop table if exists clzz_list_20240424_bak purge;
create table clzz_list_20240424_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select a.sum_month,
a.charge_year_2023,
a.prod_type,
a.cust_stock_type,
a.pz_user_type,
a.is_pz_cust,
a.is_cz_cust_2023,
a.is_cz_user_2023,
a.cust_type,
a.prod_inst_id,
case when b.serv_id is not null then b.subst_name else a.subst_name end subst_name,
case when b.serv_id is not null then b.branch_name else a.branch_name end branch_name,
case when b.serv_id is not null then b.area_name else a.area_name end area_name,
a.six_market,
case when b.serv_id is not null then b.region_type else a.region_type end region_type,
a.load_date,
a.six_market_desc,
a.is_new_user,
a.par_month_id
from 
(select * from clzz_list where subst_name is null) a	
left join ads_yz_2024_ndhs_jz_list b
on cast(a.prod_inst_id as decimal(22,0))=b.serv_id;


drop table if exists pzkh_list_20240424_bak purge;
create table pzkh_list_20240424_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as
select a.sum_month,
a.charge_year,
a.prod_type,
a.cust_stock_type,
a.pz_user_type,
a.is_pz_cust,
a.is_pz_user,
a.is_cj,
a.cust_type,
a.prod_inst_id,
case when b.serv_id is not null then b.subst_name else a.subst_name end subst_name,
case when b.serv_id is not null then b.branch_name else a.branch_name end branch_name,
case when b.serv_id is not null then b.area_name else a.area_name end area_name,
a.six_market,
case when b.serv_id is not null then b.region_type else a.region_type end region_type,
a.load_date,
a.six_market_desc,
a.par_month_id
from 
(select * from pzkh_list where subst_name is null) a	
left join ads_yz_2024_ndhs_jz_list b
on cast(a.prod_inst_id as decimal(22,0))=b.serv_id;

--20240425  叶彩媚  XQGZ2024041801888 需求标题 匹配一批场景化营销资料的需求 

drop table if exists tmp_yz_liq_1 purge; 
create table tmp_yz_liq_1 as 
select a.index1 cust_name,a.index2 cert_num,b.cust_id from zone_gz_yz_3351225714708480 a 
left join (select distinct cust_name,cust_id from dwm_yz_tb_comm_cm_all_final where par_month_id=202404 and is_cancel_user=0) b 
on a.index1=b.cust_name; 

drop table if exists tmp_yz_liq_2 purge; 
create table tmp_yz_liq_2 as 
select distinct a.party_id,a.cert_num,b.cust_id 
from dws_crm_cust.dws_party_cert_local a --证件表
join (select distinct party_id,cust_id from dws_crm_cust.dws_customer where city_id=200) b 
on a.party_id=b.party_id 
where a.cert_num in(select distinct index2 from zone_gz_yz_3351225714708480) 
and a.cert_type=49 --统一社会信用代码（税号） 
;

drop table if exists tmp_yz_liq_3 purge; 
create table tmp_yz_liq_3 as 
select a.cust_name,a.cert_num
,case when b.cert_num is not null then b.cust_id else a.cust_id end cust_id 
from tmp_yz_liq_1 a 
left join (select distinct cert_num,cust_id from tmp_yz_liq_2) b on a.cert_num=b.cert_num 
where a.cust_id is null;

insert into tmp_yz_liq_3 
select a.cust_name,a.cert_num,a.cust_id from tmp_yz_liq_1 a
where cust_id is not null;

--分局	营服	产权编码	网格名称	宽带线数	宽带细分市场属性	双线线数	双线细分市场属性	是否名单制
drop table if exists tmp_yz_liq_4 purge; 
create table tmp_yz_liq_4 as 
select 
b.cust_id,b.subst_name,b.branch_name,b.cust_nbr,b.cell_name,b.serv_id
,case when prod_type2 in(60,70,71) then '专线' 
when prod_type=40 and prod_type2 not in(60,70,71) then '宽带' 
else null end as prod_dl  --产品大类
,(case when six_market = 1 then '校园市场' 
when six_market = 2 then '农村市场' 
when six_market = 3 then '行客市场'
when six_market = 4 then '商客市场'
when six_market = 5 then '城市家庭' 
when six_market = 6 then '流动市场' end ) as six_market_desc
,case when is_mdz=1 then '是' else '否' end is_mdz_desc
from dwm_yz_tb_comm_cm_all_final b where b.par_month_id=202404 and b.is_cancel_user=0 
and b.cust_id in(select distinct cust_id from tmp_yz_liq_3);

drop table if exists tmp_yz_liq_5 purge; 
create table tmp_yz_liq_5 as 
select b.cust_name,b.cert_num
,a.* 
from tmp_yz_liq_4 a 
left join tmp_yz_liq_3 b on a.cust_id=b.cust_id;

--客户名称  税号  分局	营服	产权编码	网格名称	宽带线数	宽带细分市场属性	双线线数	双线细分市场属性	是否名单制
drop table if exists tmp_yz_liq_6 purge; 
create table tmp_yz_liq_6 as 
select cust_name,cert_num,subst_name,branch_name,cust_nbr,cell_name
,prod_dl,six_market_desc,is_mdz_desc
,count(distinct serv_id) xs
from tmp_yz_liq_5 where prod_dl is not null
group by cust_name,cert_num,subst_name,branch_name,cust_nbr,cell_name
,prod_dl,six_market_desc,is_mdz_desc;

/* insert into table tmp_yz_liq_6(cust_name,cert_num)
select index1,index2 
from zone_gz_yz_3351225714708480 
where index1 not in(select distinct cust_name from tmp_yz_liq_6) 
and index2 not in(select distinct cert_num from tmp_yz_liq_6); */

--20240426  吴啸
限定融合套餐，市桥社区营服
字段：包区、网格、宽带速率（最大速率，含提速）、融合套内卡数（1/2/3/4/5）
、融合套餐内卡数总流量（就前面N张卡合计流量，【0，10G）、【10G，20G）、【20G，30G）、【30G，60G）、【60G，100G）、100G及以上）
，融合套餐价值积分区间（【0，100）、【100，129）、【129，169）、【169，199），199及以上）
，宽带到达数

drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
as 
select area_name,cell_code,cell_name
,speed_value,rh_tc_id
,case when coalesce(a.rh_tc_value,0)<100 then '[0,100)'  
		when coalesce(a.rh_tc_value,0)>=100 and coalesce(a.rh_tc_value,0)<129 then '[100,129)' 
		when coalesce(a.rh_tc_value,0)>=129 and coalesce(a.rh_tc_value,0)<169 then '[129,169)' 
		when coalesce(a.rh_tc_value,0)>=169 and coalesce(a.rh_tc_value,0)<199 then '[169,199)'  
		when coalesce(a.rh_tc_value,0)>=199 then '199及以上' end jf_dangci
,serv_id,is_cz
from dwm_yz_tb_comm_cm_all_final a  
where par_month_id=202403 
and is_cancel_user=0 
and is_rh_ykj>0 
and prod_type=40 
and coalesce(itv_type,-1) not in (0,1) 
and branch_name='番禺市桥社区营销服务中心';

drop table if exists tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 as 
select  rh_tc_id,count(distinct serv_id) yd,sum(stm_data) yd_ll
from dwm_yz_tb_comm_cm_all_final  
where par_month_id=202403 
and is_cancel_user=0 
and is_rh_ykj>0 
and prod_type=30 
group by rh_tc_id
;

drop table if exists tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 as 
select a.*,b.yd
,case when b.yd_ll/1024<10 then '[0,10G)' 
when b.yd_ll/1024>=10 and b.yd_ll/1024<20 then '[10,20)'
when b.yd_ll/1024>=20 and b.yd_ll/1024<30 then '[20,30)'
when b.yd_ll/1024>=30 and b.yd_ll/1024<60 then '[30,60)'
when b.yd_ll/1024>=60 and b.yd_ll/1024<100 then '[60,100)'
when b.yd_ll/1024>=100 then '100G及以上' end yd_ll_qj
from tmp_yz_liq_1 a 
left join tmp_yz_liq_2 b on a.rh_tc_id=b.rh_tc_id;

drop table if exists tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 as 
select a.*,
b.speed_max 
from tmp_yz_liq_3 a 
left join (select cell_code,max(speed_value) speed_max from tmp_yz_liq_1 group by cell_code) b on a.cell_code=b.cell_code;

drop table if exists tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 as 
select area_name,cell_code,cell_name
,speed_max,yd,yd_ll_qj
,jf_dangci
,count(distinct serv_id) rh
from tmp_yz_liq_4 a where is_cz=1
group by area_name,cell_code,cell_name
,speed_max,yd,yd_ll_qj
,jf_dangci;

--20240426  法务团队
create table tmp_yz_XQGZ2024042300899_1 as 
select a.*  from 
(select distinct cust_id,party_id from dws_crm_cust.dws_customer where city_id=200) a
join (select distinct cust_id from dwm_yz_tb_comm_cm_all_final 
where social_id in() --身份证
and par_month_id=202404 and is_Cancel_user=0 
) b
on a.cust_id=b.cust_id;

create table tmp_yz_XQGZ2024042300899_2 as 
select a.*,b.contact_id  from 
tmp_yz_XQGZ2024042300899_1 a
join (select distinct cust_id,contact_id from dws_crm_cust.dws_cust_contact_info_rel where city_id=200) b
on a.cust_id=b.cust_id;

create table tmp_yz_XQGZ2024042300899_3 as 
select distinct PARTY_ID,contact_id,contact_name,home_phone,office_phone,mobile_phone,status_date 
from dws_crm_cust.dws_contacts_info where city_id=200;

create table tmp_jrhy_clyh_linke as 
select a.*
--,b.contact_name
,b.home_phone  --家庭电话
,b.office_phone  --办公室电话
,b.mobile_phone  --手机号码
--,b.status_date 
from tmp_yz_XQGZ2024042300899_2 a
join tmp_yz_XQGZ2024042300899_3 b
on a.PARTY_ID=b.PARTY_ID and a.contact_id=b.contact_id;


--20240528   XQGZ2024051601106
drop table if exists tmp_yz_liq_1 purge; 
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.acc_nbr,cast(SEND_FLUX/1048576/1024 as decimal(22,2)) kd_sxll, --宽带上行流量 单位G 
cast(RECV_FLUX/1048576/1024 as decimal(22,2)) kd_xxll --宽带下行流量 单位G 
from summary_ods_month_city.tb_comm_ywl_data_mon a 
where par_corp_id=200 and par_month_id>=202402 and par_month_id<=202404;

drop table if exists tmp_yz_liq_2 purge; 
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as 
select a.acc_nbr,sum(a.kd_sxll)/3 kd_sx_ll,sum(a.kd_xxll)/3 kd_xx_ll 
from tmp_yz_liq_1 a group by a.acc_nbr; 


drop table if exists tmp_yz_XQGZ2024051601106 purge; 
create table tmp_yz_XQGZ2024051601106 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as 
select a.index1 acc_nbr,b.kd_sx_ll,b.kd_xx_ll 
from zone_gz_yz_3351225714708480 a left join tmp_yz_liq_2 b on a.index1=b.acc_nbr; 

select count(1) from tmp_yz_XQGZ2024051601106



--20240530  融合清单用3月机构信息补打2月新宽新移+新宽老移

--备份
drop table if exists ads_yz_rpt_ztrh_list_cy_20240530 purge;
create table ads_yz_rpt_ztrh_list_cy_20240530 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rpt_ztrh_list_cy where par_month_id=202402;

--补打
--非-200和940201816的局向等字段不变
drop table if exists tmp_yz_rpt_ztrh_list_cy_20240530 purge;
create table tmp_yz_rpt_ztrh_list_cy_20240530 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rpt_ztrh_list_cy_20240530 
where par_month_id=202402 and coalesce(subst_id,-1000) not in(-200,940201816);

--200和940201816的局向，非新入网的号码不变
insert into tmp_yz_rpt_ztrh_list_cy_20240530
select * from ads_yz_rpt_ztrh_list_cy_20240530 
where par_month_id=202402 and subst_id in(-200,940201816) 
and serv_id in(select distinct serv_id from dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202402 and prod_type=40 and coalesce(is_new_user,-1)<>1);

--【-200和940201816】的局向且2月新入网号码,字段用大宽表的202403月补打
drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rpt_ztrh_list_cy_20240530 where par_month_id=202402 and subst_id in(-200,940201816) 
and serv_id in(select distinct serv_id from dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202402 and prod_type=40 and is_new_user=1);


insert into table tmp_yz_rpt_ztrh_list_cy_20240530 
select 
a.sum_date,a.month_id,a.rh_tc_id,a.serv_id,a.cust_id,a.acc_nbr
,a.rh_type_ykj,a.is_mktc,a.yd_cnt,a.yd_fk_cnt,a.yd_zk_cnt
,a.is_mktc_rule,a.total_yx_num,a.ydyx_points,a.is_ts,a.is_ts_tc
,a.ts_points,a.is_sq,a.cust_nbr

,case when b.serv_id is not null then b.subst_id  else a.subst_id  end  subst_id
,case when b.serv_id is not null then b.subst_name  else a.subst_name end  subst_name
,case when b.serv_id is not null then b.branch_id else a.branch_id end  branch_id
,case when b.serv_id is not null then b.branch_name  else a.branch_name end  branch_name
,case when b.serv_id is not null then b.area_id   else a.area_id end  area_id
,case when b.serv_id is not null then b.area_name else a.area_name end area_name

,a.sales_id,a.sales_code,a.sales_name,a.channel_nbr,a.channel_name
,a.prod_type2,a.prod_type3,a.prod_id,a.open_date,a.speed_value,a.bg_type

,case when b.serv_id is not null then b.region_type  else a.region_type end  region_type

,a.kd_desc,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,a.rh_tc_value,a.serv_grp_type_desc,a.six_market_desc

,case when b.serv_id is not null then b.grid_code  else a.grid_code end  grid_code
,case when b.serv_id is not null then b.grid_name else a.grid_name end  grid_name

,a.sales_subst_id,a.sales_subst_name,a.sales_branch_id,a.sales_branch_name
,a.slw_jk_fenzi,a.slw_ai_fenzi,a.slw_fenzi,a.cldx_mp_fenzi,a.qyyp_fenzi
,a.sq_ydn_fenzi,a.b_fttr_fenzi,a.sq_fttr_fenzi,a.ybf_aqdn_5g_fenzi
,a.xw_ict_fenzi,a.lzmx_fenzi,a.sq_fenzi,a.qw_wifi_fenzi,a.spcl_fenzi
,a.tykj_fenzi,a.itv_fenzi,a.fttr_fenzi,a.tyyp_fenzi,a.txzl_fenzi,a.wxzl_fenzi,a.gz_fenzi,a.sum_fenzi,a.par_month_id

from tmp_yz_liq_1 a
left join dwm_yz_tb_comm_cm_all_mon_final b
on a.serv_id=b.serv_id and b.par_month_id=202403; 

--核查
select count(1) from tmp_yz_rpt_ztrh_list_cy_20240530
select count(1) from ads_yz_rpt_ztrh_list_cy where par_month_id=202402 

select subst_name,count(1) from tmp_yz_rpt_ztrh_list_cy_20240530 group by subst_name order by subst_name
select subst_name,count(1) from ads_yz_rpt_ztrh_list_cy where par_month_id=202402  group by subst_name order by subst_name

--插入补打后的202402月数据
alter table ads_yz_rpt_ztrh_list_cy drop if exists partition(par_month_id=202402);
insert into table ads_yz_rpt_ztrh_list_cy partition(par_month_id=202402)
(sum_date,month_id,rh_tc_id,serv_id,cust_id,acc_nbr,rh_type_ykj,is_mktc,yd_cnt
,yd_fk_cnt,yd_zk_cnt,is_mktc_rule,total_yx_num,ydyx_points,is_ts,is_ts_tc
,ts_points,is_sq,cust_nbr,subst_id,subst_name,branch_id,branch_name,area_id
,area_name,sales_id,sales_code,sales_name,channel_nbr,channel_name,prod_type2
,prod_type3,prod_id,open_date,speed_value,bg_type,region_type,kd_desc
,channel_type_2011,channel_subtype_2011,channel_subtype_flag,rh_tc_value
,serv_grp_type_desc,six_market_desc,grid_code,grid_name,sales_subst_id
,sales_subst_name,sales_branch_id,sales_branch_name,slw_jk_fenzi,slw_ai_fenzi
,slw_fenzi,cldx_mp_fenzi,qyyp_fenzi,sq_ydn_fenzi,b_fttr_fenzi,sq_fttr_fenzi
,ybf_aqdn_5g_fenzi,xw_ict_fenzi,lzmx_fenzi,sq_fenzi,qw_wifi_fenzi,spcl_fenzi
,tykj_fenzi,itv_fenzi,fttr_fenzi,tyyp_fenzi,txzl_fenzi,wxzl_fenzi,gz_fenzi,sum_fenzi)

select sum_date,month_id,rh_tc_id,serv_id,cust_id,acc_nbr,rh_type_ykj,is_mktc,yd_cnt
,yd_fk_cnt,yd_zk_cnt,is_mktc_rule,total_yx_num,ydyx_points,is_ts,is_ts_tc
,ts_points,is_sq,cust_nbr,subst_id,subst_name,branch_id,branch_name,area_id
,area_name,sales_id,sales_code,sales_name,channel_nbr,channel_name,prod_type2
,prod_type3,prod_id,open_date,speed_value,bg_type,region_type,kd_desc
,channel_type_2011,channel_subtype_2011,channel_subtype_flag,rh_tc_value
,serv_grp_type_desc,six_market_desc,grid_code,grid_name,sales_subst_id
,sales_subst_name,sales_branch_id,sales_branch_name,slw_jk_fenzi,slw_ai_fenzi
,slw_fenzi,cldx_mp_fenzi,qyyp_fenzi,sq_ydn_fenzi,b_fttr_fenzi,sq_fttr_fenzi
,ybf_aqdn_5g_fenzi,xw_ict_fenzi,lzmx_fenzi,sq_fenzi,qw_wifi_fenzi,spcl_fenzi
,tykj_fenzi,itv_fenzi,fttr_fenzi,tyyp_fenzi,txzl_fenzi,wxzl_fenzi,gz_fenzi,sum_fenzi
from tmp_yz_rpt_ztrh_list_cy_20240530;



--20240531  融合质态清单T+0用3月机构信息补打2月新宽新移+新宽老移

--备份
drop table if exists ads_yz_rpt_ztrh_list_dy_20240530 purge;
create table ads_yz_rpt_ztrh_list_dy_20240530 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rpt_ztrh_list_dy where par_month_id=202402;

--补打
--非-200和940201816的局向等字段不变
drop table if exists tmp_yz_rpt_ztrh_list_dy_20240530 purge;
create table tmp_yz_rpt_ztrh_list_dy_20240530 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rpt_ztrh_list_dy_20240530 
where par_month_id=202402 and coalesce(subst_id,-1000) not in(-200,940201816);

--200和940201816的局向，非新入网的号码不变
insert into tmp_yz_rpt_ztrh_list_dy_20240530
select * from ads_yz_rpt_ztrh_list_dy_20240530 
where par_month_id=202402 and subst_id in(-200,940201816) 
and serv_id in(select distinct serv_id from dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202402 and prod_type=40 and coalesce(is_new_user,-1)<>1);

--【-200和940201816】的局向且2月新入网号码,字段用大宽表的202403月补打
drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rpt_ztrh_list_dy_20240530 where par_month_id=202402 and subst_id in(-200,940201816) 
and serv_id in(select distinct serv_id from dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202402 and prod_type=40 and is_new_user=1);


insert into table tmp_yz_rpt_ztrh_list_dy_20240530 
select 
a.sum_date,a.month_id,a.rh_tc_id,a.serv_id,a.cust_id,a.acc_nbr
,a.rh_type_ykj,a.is_mktc,a.yd_cnt,a.yd_fk_cnt,a.yd_zk_cnt
,a.is_mktc_rule,a.total_yx_num,a.ydyx_points,a.is_ts,a.is_ts_tc
,a.ts_points,a.is_sq,a.slw_jk_fenzi,a.slw_ai_fenzi,a.slw_fenzi
,a.cldx_mp_fenzi,a.qyyp_fenzi,a.sq_ydn_fenzi,a.b_fttr_fenzi
,a.sq_fttr_fenzi,a.ybf_aqdn_5g_fenzi,a.xw_ict_fenzi,a.lzmx_fenzi
,a.sq_fenzi,a.qw_wifi_fenzi,a.spcl_fenzi,a.tykj_fenzi,a.itv_fenzi
,a.fttr_fenzi,a.tyyp_fenzi,a.txzl_fenzi,a.wxzl_fenzi,a.gz_fenzi
,a.sum_fenzi,a.cust_nbr

,case when b.serv_id is not null then b.subst_id  else a.subst_id  end  subst_id
,case when b.serv_id is not null then b.subst_name  else a.subst_name end  subst_name
,case when b.serv_id is not null then b.branch_id else a.branch_id end  branch_id
,case when b.serv_id is not null then b.branch_name  else a.branch_name end  branch_name
,case when b.serv_id is not null then b.area_id   else a.area_id end  area_id
,case when b.serv_id is not null then b.area_name else a.area_name end area_name

,a.sales_id,a.sales_code,a.sales_name,a.channel_nbr,a.channel_name
,a.prod_type2,a.prod_type3,a.prod_id,a.open_date,a.speed_value,a.bg_type 

,case when b.serv_id is not null then b.region_type  else a.region_type end  region_type

,a.kd_desc,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype_flag,a.rh_tc_value,a.serv_grp_type_desc,a.six_market_desc

,case when b.serv_id is not null then b.grid_code  else a.grid_code end  grid_code
,case when b.serv_id is not null then b.grid_name else a.grid_name end  grid_name

,a.sales_subst_id,a.sales_subst_name,a.sales_branch_id,a.sales_branch_name,a.par_month_id 

from tmp_yz_liq_1 a
left join dwm_yz_tb_comm_cm_all_mon_final b
on a.serv_id=b.serv_id and b.par_month_id=202403; 

--核查
select count(1) from tmp_yz_rpt_ztrh_list_dy_20240530
select count(1) from ads_yz_rpt_ztrh_list_dy where par_month_id=202402 

select subst_name,count(1) from tmp_yz_rpt_ztrh_list_dy_20240530 group by subst_name order by subst_name
select subst_name,count(1) from ads_yz_rpt_ztrh_list_dy where par_month_id=202402  group by subst_name order by subst_name

--插入补打后的202402月数据
alter table ads_yz_rpt_ztrh_list_dy drop if exists partition(par_month_id=202402);
insert into table ads_yz_rpt_ztrh_list_dy partition(par_month_id=202402)
(sum_date,month_id,rh_tc_id,serv_id,cust_id,acc_nbr,rh_type_ykj,is_mktc,yd_cnt
,yd_fk_cnt,yd_zk_cnt,is_mktc_rule,total_yx_num,ydyx_points,is_ts,is_ts_tc
,ts_points,is_sq,slw_jk_fenzi,slw_ai_fenzi,slw_fenzi,cldx_mp_fenzi,qyyp_fenzi
,sq_ydn_fenzi,b_fttr_fenzi,sq_fttr_fenzi,ybf_aqdn_5g_fenzi,xw_ict_fenzi,lzmx_fenzi
,sq_fenzi,qw_wifi_fenzi,spcl_fenzi,tykj_fenzi,itv_fenzi,fttr_fenzi,tyyp_fenzi
,txzl_fenzi,wxzl_fenzi,gz_fenzi,sum_fenzi,cust_nbr,subst_id,subst_name,branch_id,branch_name,area_id
,area_name,sales_id,sales_code,sales_name,channel_nbr,channel_name,prod_type2
,prod_type3,prod_id,open_date,speed_value,bg_type,region_type,kd_desc
,channel_type_2011,channel_subtype_2011,channel_subtype_flag,rh_tc_value
,serv_grp_type_desc,six_market_desc,grid_code,grid_name,sales_subst_id
,sales_subst_name,sales_branch_id,sales_branch_name)

select sum_date,month_id,rh_tc_id,serv_id,cust_id,acc_nbr,rh_type_ykj,is_mktc,yd_cnt
,yd_fk_cnt,yd_zk_cnt,is_mktc_rule,total_yx_num,ydyx_points,is_ts,is_ts_tc
,ts_points,is_sq,slw_jk_fenzi,slw_ai_fenzi,slw_fenzi,cldx_mp_fenzi,qyyp_fenzi
,sq_ydn_fenzi,b_fttr_fenzi,sq_fttr_fenzi,ybf_aqdn_5g_fenzi,xw_ict_fenzi,lzmx_fenzi
,sq_fenzi,qw_wifi_fenzi,spcl_fenzi,tykj_fenzi,itv_fenzi,fttr_fenzi,tyyp_fenzi
,txzl_fenzi,wxzl_fenzi,gz_fenzi,sum_fenzi,cust_nbr,subst_id,subst_name,branch_id,branch_name,area_id
,area_name,sales_id,sales_code,sales_name,channel_nbr,channel_name,prod_type2
,prod_type3,prod_id,open_date,speed_value,bg_type,region_type,kd_desc
,channel_type_2011,channel_subtype_2011,channel_subtype_flag,rh_tc_value
,serv_grp_type_desc,six_market_desc,grid_code,grid_name,sales_subst_id
,sales_subst_name,sales_branch_id,sales_branch_name
from tmp_yz_rpt_ztrh_list_dy_20240530;


--20240531  质态要求新增字段：
--商务彩铃、来电名片、挂机短信、智能名片叠加量，
--翼备份、安全大脑、5G CPE叠加量
--重点业务总叠加量，重点业务商企叠加量，重点业务公众叠加量

--备份
drop table if exists ads_yz_rpt_ztrh_list_dy_bak purge;
create table ads_yz_rpt_ztrh_list_dy_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rpt_ztrh_list_dy;

drop table if exists ads_yz_rhzt_xkxy_dwb_bak purge;
create table ads_yz_rhzt_xkxy_dwb_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rhzt_xkxy_dwb;

drop table if exists ads_yz_rhzt_cl_dwb_bak purge;
create table ads_yz_rhzt_cl_dwb_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_rhzt_cl_dwb;


--20240604  XQGZ2024053000794 需求标题 关于番禺中小学匹配划小网格和营服的需求 

select a.*,b.addr_id_7,c.grid_unit_name
from zone_gz_yz_3351225714708480 a 
left join dwd_yz_addr_final b on a.index4=b.addr 
left join ads_yz_tyks_addr_7 c on b.addr_id_7=c.addr_id_7 and c.par_month_id=202406 limit 500


--20240606  XQGZ2024060301734 需求标题 广州跨越速运有限公司云总机业务数据梳理 
02031711380

select attr_id,attr_name from dws_crm_cfguse.dws_attr_spec where attr_inner_cd in('PM_TYYHYZJFJZF',
'PM_TYYHYZJLYZF',
'PM_ZDYZKL','PM_SFKYYW','PM_YZJBDLDHM')
200011184	自定义折扣率
200011503	是否跨域业务
500007003	分机(单机)资费
500008002	分机（单机）录音资费
500041233	云中继绑定落地号码

drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.index1 as acc_nbr,b.serv_id,b.state
from zone_gz_yz_3351225714708480 a 
left join (select distinct acc_nbr,serv_id,state from dwm_yz_tb_comm_cm_all_final where par_month_id=202406) b on a.index1=b.acc_nbr ;

drop table if exists tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.acc_nbr,a.serv_id
,c.attr_value_name as state_desc
from tmp_yz_liq_1 a 
left join dws_crm_cfguse.dws_attr_value c on a.state=c.attr_value and c.city_id='200' and c.attr_id='4000000201'
;

200011184	自定义折扣率
200011503	是否跨域业务
500007003	分机(单机)资费
500008002	分机（单机）录音资费
500041233	云中继绑定落地号码

drop table if exists tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,b.attr_value1  zdy_zkl  --自定义折扣率
from tmp_yz_liq_2 a 
left join summary_ods_day_city.tb_pre_cm_attr_all b --特性资料表 
on b.par_corp_id='200' and a.serv_id=b.serv_id and b.attr_id in(200011184)
;

drop table if exists tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,d.attr_value_name is_kuayu_yw --是否跨域业务
from tmp_yz_liq_3 a 
left join summary_ods_day_city.tb_pre_cm_attr_all b --特性资料表 
on b.par_corp_id='200' and a.serv_id=b.serv_id and b.attr_id in(200011503)
left join dws_crm_cfguse.dws_attr_value d on b.attr_value1=d.attr_inner_value and b.attr_id=d.attr_id and d.city_id='200'
;

drop table if exists tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,d.attr_value_name fenji_zf --分机(单机)资费
from tmp_yz_liq_4 a 
left join summary_ods_day_city.tb_pre_cm_attr_all b --特性资料表 
on b.par_corp_id='200' and a.serv_id=b.serv_id and b.attr_id in(500007003)
left join dws_crm_cfguse.dws_attr_value d on b.attr_value1=d.attr_inner_value and b.attr_id=d.attr_id and d.city_id='200'
;

drop table if exists tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,d.attr_value_name fenji_luyin_zf --分机（单机）录音资费
from tmp_yz_liq_5 a 
left join summary_ods_day_city.tb_pre_cm_attr_all b --特性资料表 
on b.par_corp_id='200' and a.serv_id=b.serv_id and b.attr_id in(500008002)
left join dws_crm_cfguse.dws_attr_value d on b.attr_value1=d.attr_inner_value and b.attr_id=d.attr_id and d.city_id='200'
;

drop table if exists tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,b.attr_value1 yzjbd_ld_acc --云中继绑定落地号码
from tmp_yz_liq_6 a 
left join summary_ods_day_city.tb_pre_cm_attr_all b --特性资料表 
on b.par_corp_id='200' and a.serv_id=b.serv_id and b.attr_id in(500041233)
;

drop table if exists tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,row_number() over(order by serv_id) paixu  from tmp_yz_liq_7 a;

--20240612  XQGZ2024061101600 需求标题 PCDN专项批量提取客户信息需求 
drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.index1,a.index2,a.index3,a.index4,a.index5
,a.index6,a.index7,a.index8,a.index9,a.index10
,a.index11,a.index12,a.index13,a.index14,a.index15
,a.index16,a.index17,a.index18,a.index19,a.index20
,a.index21,a.index22,a.index23,a.index24

,b.serv_id
from zone_gz_yz_3351225714708480 a 
left join (select distinct serv_id,acc_nbr from dwm_yz_tb_comm_cm_all_final where par_month_id=202406) b on a.index1=b.acc_nbr;

客户名、客户编码、揽装人、揽装人机构、揽装地址信息
drop table if exists tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*

,(case when length(b.cust_name)<2 then b.cust_name
		when length(b.cust_name)=2 then concat(SUBSTR(b.cust_name,1,1),'*')
		when length(b.cust_name)>2 then concat(SUBSTR(b.cust_name,1,(length(b.cust_name)-2)),'**')
		else null end) as  cust_name_tm
,b.cust_nbr
,b.sales_name
,b.channel_subst_name
,b.channel_branch_name
,(case when length(c.addr)<4 then c.addr
		when length(c.addr)=4 then concat(SUBSTR(c.addr,1,1),'*')
		when length(c.addr)>4 then concat(SUBSTR(c.addr,1,(length(c.addr)-4)),'****')
		else null end) as serv_addr_name
,b.serv_addr_id
from tmp_yz_liq_1 a 
left join dwm_yz_tb_comm_cm_all_final b on b.par_month_id=202406 and a.serv_id=b.serv_id 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final) c on cast(b.serv_addr_id as decimal(24,0))=c.id;
;

--XQGZ2024052900934 需求标题 关于CDAP业务资料表增加宽带速率字段的需求 
-- 135:PM_ADSLSL、671:PM_NEWADSLSL 
drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 as 
select distinct a.serv_id
,a.attr_id --特性id（产品规格属性）
,a.attr_value1  --特性值
,a.create_date   --订购时间
,b.attr_value_name
,row_number() over(partition by a.serv_id,a.attr_id order by a.create_date desc) paixu
from summary_ods_day_city.tb_pre_cm_attr_all a --特性资料表 
join (select attr_id,attr_inner_value,attr_value_name from dws_crm_cfguse.dws_attr_value where city_id='200' ) b on a.attr_value1=b.attr_inner_value and  a.attr_id=b.attr_id
where a.par_corp_id=200 and a.attr_id in(135,671);

select a.*
,b.attr_value_name as kd_ADSLSL
,c.attr_value_name as kd_NEWADSLSL 
from 
left join (select * from tmp_yz_liq_1 where paixu=1 and attr_id=135) b on a.serv_id=b.serv_id 
left join (select * from tmp_yz_liq_1 where paixu=1 and attr_id=671) c on a.serv_id=c.serv_id
;


--重建 全业务资料表视图 ads_yz_tb_comm_cm_all_final
--subst_id建表
drop view view_ads_yz_tb_comm_cm_all_final;
drop view view_py_ads_yz_tb_comm_cm_all_final; 
drop view view_hd_ads_yz_tb_comm_cm_all_final; 
drop view view_zc_ads_yz_tb_comm_cm_all_final; 
drop view view_ch_ads_yz_tb_comm_cm_all_final; 
drop view view_ds_ads_yz_tb_comm_cm_all_final; 
drop view view_yx_ads_yz_tb_comm_cm_all_final; 
drop view view_hz_ads_yz_tb_comm_cm_all_final; 
drop view view_lw_ads_yz_tb_comm_cm_all_final; 
drop view view_hp_ads_yz_tb_comm_cm_all_final; 
drop view view_by_ads_yz_tb_comm_cm_all_final; 
drop view view_th_ads_yz_tb_comm_cm_all_final; 
drop view view_ns_ads_yz_tb_comm_cm_all_final; 
drop view view_zqb_ads_yz_tb_comm_cm_all_final; 
drop view view_zq_ads_yz_tb_comm_cm_all_final; 
drop view view_xyzx_ads_yz_tb_comm_cm_all_final;




--subst_id建表
create view view_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final;
create view view_py_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=10002;
create view view_hd_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=10003;
create view view_zc_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=10004;
create view view_ch_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=10005;
create view view_ds_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id in (10061,10006);
create view view_yx_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id in (10061,10006);
create view view_hz_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=10307;
create view view_lw_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=10317;
create view view_hp_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=10922;
create view view_by_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=11149;
--create view view_th_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=4050;
create view view_ns_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where subst_id=4174;
create view view_zqb_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where serv_grp_type='01';
create view view_zq_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where serv_grp_type='01' or six_market in ('1','3','4');
create view view_xyzx_ads_yz_tb_comm_cm_all_final as select * from zone_gz_yz.ads_yz_tb_comm_cm_all_final where bg_type='教育';

drop view view_th_ads_yz_tb_comm_cm_all_final; 
create view view_th_ads_yz_tb_comm_cm_all_final as select a.*,b.addr_id_7 from zone_gz_yz.ads_yz_tb_comm_cm_all_final a 
left join (select distinct id,addr,addr_id_7 from zone_gz_yz.dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id 
where subst_id=4050;


--531  新装融合视图
select par_month_id,sum_date,serv_id,subst_name,branch_name,area_id,area_name,region_type,cell_code,
cell_name,channel_type_2011,channel_subtype_2011,subs_stat_date,channel_subst_name,channel_branch_name
,channel_nbr,channel_name,sales_code,sales_name,channel_area_name,rh_tc_value

FROM ads_yz_kd_new_list 
WHERE par_month_id IN (202405)    
AND kd_desc = '普通宽带' 
AND coalesce(prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(kd_prod_offer_name, '-1') NOT LIKE '%0时长%'  --剔除快捷宽带主线路
and is_rh_ykj>0  --限制融合
and rh_tc_value>=129
and rh_type_ykj in('新宽带新移动','新宽带老移动')
and channel_subtype_2011 like '%包区店%' 
and area_id in (select org_id  from dwd_yz_dim_org where region_type<>'其他' and region_type in ('农村','城中村','城市家庭')) --公众包区
;


select par_month_id,sum_date,serv_id,subst_name,branch_name,area_id,area_name,region_type,cell_code,
cell_name,channel_type_2011,channel_subtype_2011,subs_stat_date,channel_subst_name,channel_branch_name
,channel_nbr,channel_name,sales_code,sales_name,channel_area_name,rh_tc_value

FROM ads_yz_kd_new_list 
WHERE par_month_id IN (202405)    
AND kd_desc = '普通宽带' 
AND coalesce(prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(kd_prod_offer_name, '-1') NOT LIKE '%0时长%'  --剔除快捷宽带主线路
and is_rh_ykj>0  --限制融合
and rh_tc_value>=129
and rh_type_ykj in('新宽带新移动','新宽带老移动')
and channel_subtype_2011 like '%包区店%' 
and area_id in (select org_id from dwd_yz_dim_org where region_type<>'其他' and region_type in ('专业市场','产业园区','商务楼宇'));--商客包区



select par_month_id,sum_date,subst_name,branch_name,area_id,area_name,region_type,cell_code,
cell_name,six_market,channel_type_2011,channel_subtype_2011,subs_stat_date,salestaff_subst_name,salestaff_branch_name,channel_name,sales_code,sales_name,salestaff_org_name
from dwd_yz_cm_cdma_ydxz_list 
where 1=1
and par_month_id = '202405'
--and subs_stat_date >= '20240401' and subs_stat_date <= '20240430'
and prod_type1 in ('后付费单产品','预付费单产品')
and jz_points >= 129.00
and channel_subtype_2011 like '%包区店%'
and area_id in (select org_id  from dwd_yz_dim_org where region_type<>'其他' and region_type in ('农村','城中村','城市家庭'));--公众包区


select par_month_id,sum_date,subst_name,branch_name,area_id,area_name,region_type,cell_code,
cell_name,six_market,channel_type_2011,channel_subtype_2011,subs_stat_date,salestaff_subst_name,salestaff_branch_name,channel_name,sales_code,sales_name,salestaff_org_name
from dwd_yz_cm_cdma_ydxz_list 
where 1=1
and par_month_id = '202405'
--and subs_stat_date >= '20240401' and subs_stat_date <= '20240430'
and prod_type1 in ('后付费单产品','预付费单产品')
and jz_points >= 129.00
and channel_subtype_2011 like '%包区店%'
and area_id in (select org_id from dwd_yz_dim_org where region_type<>'其他' and region_type in ('专业市场','产业园区','商务楼宇'));--商客包区


--黄梓锋  销售品积分核查
drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
as 
select distinct serv_id
,rh_tc_id
,case when is_rh_ykj>0 then rh_tc_id else serv_id end rh_id
,is_rh_ykj,prod_type,rh_tc_value,jz_points ,prod_type2
from dwm_yz_tb_comm_cm_all_final where par_month_id=202406 and is_cancel_user=0; 

drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
as
select a.serv_id,a.prod_offer_id,b.prod_offer_code,b.jf_cy,b.lx
from dwd_yz_rpt_comm_cm_msdisc_final a 
join tmp_yy_jf_129_01 b on a.prod_offer_id=b.offer_id
where date_format(limit_date,'yyyyMMdd') > '20240624';

drop table tmp_yz_liq_10;
create table tmp_yz_liq_10 as 
select * from tmp_yz_liq_2 where prod_offer_id not in (500056050,500054181)
union all
select * from tmp_yz_liq_2 where prod_offer_id=500056050 and 
serv_id in (select serv_id from tmp_yy_jf_sl_4_list where flag=0)
union all
select * from tmp_yz_liq_2 where prod_offer_id=500054181 and 
serv_id in (select serv_id from tmp_yy_jf_sl_1_list);

drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
as 
select a.*
,case when b.serv_id is not null and coalesce(b.is_rh_ykj,-1)>0 then b.rh_tc_id else a.serv_id end as rh_id
from tmp_yz_liq_10 a 
left join tmp_yz_liq_1 b on a.serv_id=b.serv_id;

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
as 
select a.rh_id,a.prod_offer_id
,count(a.serv_id) as num 
from tmp_yz_liq_3 a group by a.rh_id,a.prod_offer_id;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
as 
select a.*
,b.jf_cy,b.lx
from tmp_yz_liq_4 a 
left join tmp_yy_jf_129_01 b on a.prod_offer_id=b.offer_id;

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
as 
select  a.*
,case when lx=1 then jf_cy when lx=2 then jf_cy*num when lx=3 then jf_cy*(num-1) else 0 end as jf_cy_sg
from tmp_yz_liq_5 a;

drop table tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
as 
select  a.rh_id
,sum(jf_cy_sg) as sum_jf_cy
from tmp_yz_liq_6 a group by a.rh_id;

drop table tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
as 
select a.*
,case when b.rh_id is not null then b.sum_jf_cy else 0 end as jf_cy
from tmp_yz_liq_1 a 
left join  tmp_yz_liq_7 b on a.rh_id=b.rh_id  
;

drop table tmp_yz_liq_9 purge;
create table tmp_yz_liq_9 
as 
select count(distinct case when prod_type=40 and is_rh_ykj=0 and coalesce(prod_type2,-1) not in (60,70,71,80) and rh_tc_value>=129 then serv_id else null end) as dk_129
,count(distinct case when prod_type=30 and is_rh_ykj=0 and rh_tc_value>=129 then serv_id else null end) as dy_129
,count(distinct case when is_rh_ykj=1 and rh_tc_value>=129 then rh_tc_id else null end) as rh_129


,count(distinct case when prod_type=40 and is_rh_ykj=0 and coalesce(prod_type2,-1) not in (60,70,71,80)  and rh_tc_value+coalesce(jf_cy,0)>=129 then serv_id else null end) as dk_129_bd
,count(distinct case when prod_type=30 and is_rh_ykj=0 and rh_tc_value+coalesce(jf_cy,0)>=129 then serv_id else null end) as dy_129_bd
,count(distinct case when is_rh_ykj=1 and rh_tc_value+coalesce(jf_cy,0)>=129 then rh_tc_id else null end) as rh_129_bd
from tmp_yz_liq_8;


--yy 
drop table tmp_yy_jf_129_01;
create table tmp_yy_jf_129_01 as 
select b.offer_id,index1 prod_offer_code,cast(index2 as decimal(22)) jf_cy,cast(index3 as int) lx
from zone_gz_yz_285 a
join (select offer_id,prod_OFFER_CODE FROM  dws_crm_cfguse.dws_offer where city_id=200) b
on a.index1=b.prod_OFFER_CODE;


drop table tmp_yy_jf_129_02;
create table tmp_yy_jf_129_02 as 
select serv_id,prod_offer_id,count(1) num
from summary_ods_day_city.rpt_comm_cm_msdisc
where prod_offer_id in (select offer_id from tmp_yy_jf_129_01)
and date_format(limit_date,'yyyyMMdd')>'20240624'
and par_corp_id=200
group by serv_id,prod_offer_id;




drop table tmp_yy_jf_129_03;
create table tmp_yy_jf_129_03 as 

select '融合' flag,rh_tc_id,serv_id,prod_type,is_vice_card,jz_points,rh_tc_value
from dwm_yz_tb_comm_cm_all_final 
where par_month_id=202406 and is_cancel_user=0 
and is_rh_ykj=1

union all
select '单宽' flag,cast(serv_id as string) rh_tc_id,serv_id,prod_type,is_vice_card,jz_points,rh_tc_value
from dwm_yz_tb_comm_cm_all_final 
where par_month_id=202406 and is_cancel_user=0 
and coalesce(is_rh_ykj,0)=0 and prod_type=40 and coalesce(prod_type2,0) not in (60,70,71,80) 

union all
select '单移' flag,cast(serv_id as string) rh_tc_id,serv_id,prod_type,is_vice_card,jz_points,rh_tc_value
from dwm_yz_tb_comm_cm_all_final 
where par_month_id=202406 and is_cancel_user=0 
and coalesce(is_rh_ykj,0)=0 and prod_type=30;



drop table tmp_yy_jf_129_04;
create table tmp_yy_jf_129_04 as 
select a.*,b.rh_tc_id,b.flag
from tmp_yy_jf_129_02 a
join tmp_yy_jf_129_03 b
on a.serv_id=b.serv_id;


drop table tmp_yy_jf_129_05;
create table tmp_yy_jf_129_05 as 
select flag,rh_tc_id,prod_offer_id,sum(num) num_n
from tmp_yy_jf_129_04
group by flag,rh_tc_id,prod_offer_id;

drop table tmp_yy_jf_129_06;
create table tmp_yy_jf_129_06 as 
select a.*,b.lx,b.jf_cy
from tmp_yy_jf_129_05 a
left join tmp_yy_jf_129_01 b
on a.prod_offer_id=b.offer_id;


drop table tmp_yy_jf_129_07;
create table tmp_yy_jf_129_07 as 
select a.*
,case when lx=1 then jf_cy
      when lx=2 then jf_cy*num_n
      when lx=3 then jf_cy*(num_n-1) end jy_cj_hz
from tmp_yy_jf_129_06 a;


drop table tmp_yy_jf_129_08;
create table tmp_yy_jf_129_08 as 
select a.*,case when b.rh_tc_id is not null then b.rh_tc_value_bd else 0 end rh_tc_value_bd
from 
(select flag,rh_tc_id,rh_tc_value from tmp_yy_jf_129_03  group by flag,rh_tc_id,rh_tc_value) a
left join 
(select rh_tc_id,sum(jy_cj_hz) rh_tc_value_bd from tmp_yy_jf_129_07 group by rh_tc_id) b
on a.rh_tc_id=b.rh_tc_id;


drop table ads_yy_jf_129_list;
create table ads_yy_jf_129_list as 
select a.*,(coalesce(rh_tc_value,0)+rh_tc_value_bd) rh_tc_value_n
from tmp_yy_jf_129_08 a;


select flag,count(1) from ads_yy_jf_129_list where rh_tc_value>=129 group by flag;
select flag,count(1) from ads_yy_jf_129_list where rh_tc_value_n>=129 group by flag;

--XQGZ2024062401890 需求标题 关于全渠中心618活动包年单宽业务发展情况分析的需求  

function exe_echo(){
#抛出异常
if [ $? -ne 0 ];then
    echo " ======================== $(date +'[%Y-%m-%d %T]') 抛出异常 $1 ========================"
	exit
else 
    echo " ======================== $1 执行成功 ========================"

fi
}



set_hive="
use zone_gz_yz;
set hive.exec.parallel=true;  -- 不同job可以并发执行
set hive.exec.parallel.thread.number=32;
set hive.vectorized.execution.enabled=false;  --  关闭向量化查询
set hive.vectorized.execution.reduce.enabled=false; --  关闭向量化查询

"

#融合字段回溯
function rh_huisu(){
echo "==================== 执行日期 $sum_date ===================="
#提取宽表数据
str_sql="
insert into table tmp_yz_liq_1 
select $sum_month par_month_id,a.serv_id,count(distinct a.prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where prod_offer_id in(100018113,5731962,100096993) --prod_offer_code in('YD0303-531-1-1','DM0001-233','DM0001-687-1-1')
and date_format(limit_date,'yyyyMMdd')>'$sum_date'
and par_month_id=$sum_month
group by a.serv_id
;
"
beeline -e "$set_hive $str_sql" 
exe_echo "提取宽表数据: $sum_month 月"

##更新融合
str_sql="
insert into table tmp_yz_liq_2 
select $sum_month par_month_id,a.serv_id,count(distinct a.prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where prod_offer_id in(500072204,100027003) --prod_offer_code in('DM0001-937-1-5','DM0001-487-1-1')
and date_format(limit_date,'yyyyMMdd')>'$sum_date'
and par_month_id=$sum_month
group by a.serv_id
;
"
beeline -e "$set_hive $str_sql" 
exe_echo "更新融合: $sum_month 月"

}






if [ ! ${in_start_month} ]; then
start_month=`date -d $yyyymmdd +%Y%m`  #执行开始月份
else
start_month=${in_start_month}
end_month=${in_end_month}
fi


if [ ! $end_month ]; then
end_month=$start_month
fi

if [ $start_month -gt $end_month ]; then
echo "参数错误: start_month 大于 in_end_month ,结束运行"
echo "参数 in_start_month 为循环开始月份,in_end_month 为循环结束月份, 其中开始月份要小于结束月份"
exit
fi

start_month=202301
end_month=202405

echo "start_month= $start_month"
echo "end_month= $end_month"
loop_id=1
l_month=$start_month
#小于结束月份时,执行循环
while [ $l_month -le $end_month ]
do
echo "==================== 当前循环月份为 $l_month ===================="
l_billing=$l_month'01'
var_a=`date -d "1 month $l_billing" +%Y%m%d`
sum_date=`date -d "-1 day $var_a" +%Y%m%d`	#月底日期
sum_month=$l_month							#统计月份
last_month=`date -d "-1 month $l_billing" +%Y%m` #上月

#融合字段回溯
rh_huisu

sleep 10s

l_month=`date -d "1 month $l_billing" +%Y%m`
loop_id=`expr $loop_id + 1`
done

echo "==================== 循环结束,一共循环 $[ $loop_id - 1 ] 次 ===================="



drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  202406 as par_month_id,a.serv_id,count(distinct a.prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_final a 
where prod_offer_id in(100018113,5731962,100096993) --prod_offer_code in('YD0303-531-1-1','DM0001-233','DM0001-687-1-1')
and date_format(limit_date,'yyyyMMdd')>'20240629' group by a.serv_id ;


drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  202406 as par_month_id,serv_id,count(distinct prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_final a 
where prod_offer_id in(500072204,100027003) --prod_offer_code in('DM0001-937-1-5','DM0001-487-1-1')
and date_format(limit_date,'yyyyMMdd')>'20240629' group by a.serv_id;

drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.cell_code 
from tmp_yz_liq_1 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id
where a.par_month_id<202406;

insert into table tmp_yz_liq_3 
select a.*,b.cell_code 
from tmp_yz_liq_1 a 
left join dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id
where a.par_month_id=202406;

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.cell_code 
from tmp_yz_liq_2 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id
where a.par_month_id<202406;

insert into table tmp_yz_liq_4
select a.*,b.cell_code 
from tmp_yz_liq_2 a 
left join dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id
where a.par_month_id=202406;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
SELECT a.par_month_id,a.std_subst_name,a.cell_name
,case when b.cell_code is not null then 1 else 0 end is_600_bn
,case when c.cell_code is not null then 1 else 0 end is_1200_bn
,a.cell_code,a.serv_id,a.rh_tc_value,a.serv_addr_id,a.is_rh_ykj
FROM ads_yz_kd_new_list a 
left join (select distinct par_month_id,cell_code from tmp_yz_liq_3 where num=3 ) b on a.cell_code=b.cell_code and a.par_month_id=b.par_month_id
left join (select distinct par_month_id,cell_code from tmp_yz_liq_4 where num=2 ) c on a.cell_code=c.cell_code and a.par_month_id=c.par_month_id
WHERE a.par_month_id>=202301
AND a.kd_desc = '普通宽带' 
AND coalesce(a.prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(a.prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(a.kd_prod_offer_name, '-1') NOT LIKE '%0时长%' 
;


drop table tmp_yz_liq_6_1 purge;
create table tmp_yz_liq_6_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.obj_id  --9级地址id
,a.label_id --地址标签
,a.create_date
,b.index3 as addr_9_label
from  (select distinct obj_id,label_id,create_date from dws_grid.dws_grid_label_setting_inst where city_id=200) a --地址打标标签
left join zone_gz_yz_3351225714708480 b on cast(a.label_id as string)=b.index2
;

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,row_number() over(partition by obj_id order by addr_9_label desc,create_date desc ) as paixu
from tmp_yz_liq_6_1 a;

drop table tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
b.parentid as serv_addr_9
,c.addr_9_label
from tmp_yz_liq_5 a  
left join (select distinct id,addr
,parentid --id的上一级
from dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id 
left join tmp_yz_liq_6 c on b.parentid=c.obj_id and c.paixu=1;


drop table tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 	'600元包年' as bn_lx,par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj
,count(DISTINCT  serv_id ) AS rw_num
,sum(rh_tc_value) AS rw_jf 
from tmp_yz_liq_7 where is_600_bn=1
group by par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj

union all 
select 	'1200元包年' as bn_lx,par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj
,count(DISTINCT  serv_id ) AS rw_num
,sum(rh_tc_value) AS rw_jf 
from tmp_yz_liq_7 where is_1200_bn=1
group by par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj ;

drop table ads_yz_XQGZ2024062401890_1 purge;
create table ads_yz_XQGZ2024062401890_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from tmp_yz_liq_8;

--到达
drop table tmp_yz_liq_dd_5 purge;
create table tmp_yz_liq_dd_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
SELECT a.par_month_id,a.std_subst_name,a.cell_name
,case when b.cell_code is not null then 1 else 0 end is_600_bn
,case when c.cell_code is not null then 1 else 0 end is_1200_bn
,a.cell_code,a.serv_id,a.rh_tc_value,a.serv_addr_id,is_rh_ykj
from dwm_yz_tb_comm_cm_all_mon_final a
left join (select distinct par_month_id,cell_code from tmp_yz_liq_3 where num=3 ) b on a.cell_code=b.cell_code and a.par_month_id=b.par_month_id
left join (select distinct par_month_id,cell_code from tmp_yz_liq_4 where num=2 ) c on a.cell_code=c.cell_code and a.par_month_id=c.par_month_id
where a.par_month_id=202405 and a.is_cancel_user=0 and a.prod_type=40 and a.kd_desc='普通宽带' 
and a.mainstream_net_type=10 and a.is_cz=1 and coalesce(a.kd_prod_offer_id,'-1') not like '%500046067%';


drop table tmp_yz_liq_dd_7 purge;
create table tmp_yz_liq_dd_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
b.parentid as serv_addr_9
,c.addr_9_label
from tmp_yz_liq_dd_5 a  
left join (select distinct id,addr
,parentid --id的上一级
from dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id 
left join tmp_yz_liq_6 c on b.parentid=c.obj_id and c.paixu=1;


drop table tmp_yz_liq_dd_8 purge;
create table tmp_yz_liq_dd_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 	'600元包年' as bn_lx,par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj
,count(DISTINCT  serv_id ) AS dd_num
,sum(rh_tc_value) AS dd_jf 
from tmp_yz_liq_dd_7 
where is_600_bn=1
group by par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj

union all 
select 	'1200元包年' as bn_lx,par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj
,count(DISTINCT  serv_id ) AS dd_num
,sum(rh_tc_value) AS dd_jf 
from tmp_yz_liq_dd_7 where is_1200_bn=1
group by par_month_id,std_subst_name,cell_name,cell_code,addr_9_label,is_rh_ykj ;


drop table ads_yz_XQGZ2024062401890_2 purge;
create table ads_yz_XQGZ2024062401890_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from tmp_yz_liq_dd_8;

drop table tmp_yz_XQGZ2024062401890_result_600_1 purge;
create table tmp_yz_XQGZ2024062401890_result_600_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  
std_subst_name  --落地分局
,cell_name  --落地网格名称
,cell_code  --网格编码
,addr_9_label  --落地9级地址标签
,sum(case when par_month_id>=202301 and par_month_id<=202405 then rw_num else 0 end) as rw  --202301-202405入网量
,sum(case when par_month_id>=202301 and par_month_id<=202405 then rw_jf else 0 end) as rw_kd_jf  --202301-202405入网积分
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=1 then rw_num else 0 end) as rh_rw_kd --202301-202405 融合入网量
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=1 then rw_jf else 0 end) as rh_rw_jf  --202301-202405 融合入网积分
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=0 then rw_num else 0 end) as rw_dk  --202301-202405 非融合入网量
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=0 then rw_jf else 0 end) as rw_dk_jf  --202301-202405 非融合入网积分

,sum(case when par_month_id=202406 then rw_num else 0 end) as rw_202406  --202406入网量
,sum(case when par_month_id=202406 then rw_jf else 0 end) as rw_kd_jf_202406  --202406入网积分
,sum(case when par_month_id=202406 and is_rh_ykj=1 then rw_num else 0 end) as rh_rw_202406 --202406 融合入网量
,sum(case when par_month_id=202406 and is_rh_ykj=1 then rw_jf else 0 end) as rh_rw_jf_202406  --202406 融合入网积分
,sum(case when par_month_id=202406 and is_rh_ykj=0 then rw_num else 0 end) as rw_dk_202406  --202406 非融合入网量
,sum(case when par_month_id=202406 and is_rh_ykj=0 then rw_jf else 0 end) as rw_dk_jf_202406  --202406 非融合入网积分

,0 as dd  --202405 主宽到达数
,0 as dd_kd_jf  --202405 主宽到达积分
,0 as rh_dd --202405 融合主宽到达数
,0 as rh_dd_jf  --202405 融合主宽到达积分
,0 as dd_dk  --202405 非融合主宽到达数
,0 as dd_dk_jf  --202405 非融合主宽到达积分
from ads_yz_XQGZ2024062401890_1 
where bn_lx='600元包年'  --包年类型：600元包年/1200元包年
group by std_subst_name
,cell_name
,cell_code
,addr_9_label

union all
select  
std_subst_name  --落地分局
,cell_name  --落地网格名称
,cell_code  --网格编码
,addr_9_label  --落地9级地址标签

,0 as rw  --202301-202405入网量
,0 as rw_kd_jf  --202301-202405入网积分
,0 as rh_rw_kd --202301-202405 融合入网量
,0 as rh_rw_jf  --202301-202405 融合入网积分
,0 as rw_dk  --202301-202405 非融合入网量
,0 as rw_dk_jf  --202301-202405 非融合入网积分

,0 as rw_202406  --202406入网量
,0 as rw_kd_jf_202406  --202406入网积分
,0 as rh_rw_202406 --202406 融合入网量
,0 as rh_rw_jf_202406  --202406 融合入网积分
,0 as rw_dk_202406  --202406 非融合入网量
,0 as rw_dk_jf_202406  --202406 非融合入网积分

,sum(dd_num) as dd  --202405 主宽到达数
,sum(dd_jf) as dd_kd_jf  --202405 主宽到达积分
,sum(case when is_rh_ykj=1 then dd_num else 0 end) as rh_dd --202405 融合主宽到达数
,sum(case when is_rh_ykj=1 then dd_jf else 0 end) as rh_dd_jf  --202405 融合主宽到达积分
,sum(case when is_rh_ykj=0 then dd_num else 0 end) as dd_dk  --202405 非融合主宽到达数
,sum(case when is_rh_ykj=0 then dd_jf else 0 end) as dd_dk_jf  --202405 非融合主宽到达积分
from ads_yz_XQGZ2024062401890_2 
where bn_lx='600元包年'  --包年类型：600元包年/1200元包年
group by std_subst_name
,cell_name
,cell_code
,addr_9_label;

drop table tmp_yz_XQGZ2024062401890_result_600_2 purge;
create table tmp_yz_XQGZ2024062401890_result_600_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select std_subst_name
,cell_name
,cell_code
,addr_9_label
,sum(rw) rw_2301_2405
,sum(rw_kd_jf) rw_jf_2301_2405
,sum(rh_rw_kd)  rh_rw_2301_2405
,sum(rh_rw_jf) rh_rw_jf_2301_2405
,sum(rw_dk) rw_dk_2301_2405
,sum(rw_dk_jf) rw_dk_jf_2301_2405
,sum(rw_202406) rw_2406
,sum(rw_kd_jf_202406)  rw_kd_jf_2406
,sum(rh_rw_202406) rh_rw_2406
,sum(rh_rw_jf_202406) rh_rw_jf_2406
,sum(rw_dk_202406) rw_dk_2406
,sum(rw_dk_jf_202406) rw_dk_jf_2406
,sum(dd) dd_2405
,sum(dd_kd_jf) dd_jf_2405
,sum(rh_dd) rh_dd_2405
,sum(rh_dd_jf) rh_dd_jf_2405
,sum(dd_dk) dd_dk_2405
,sum(dd_dk_jf) dd_dk_jf_2405
from tmp_yz_XQGZ2024062401890_result_600_1
group by std_subst_name
,cell_name
,cell_code
,addr_9_label;

drop table tmp_yz_XQGZ2024062401890_result_600 purge;
create table tmp_yz_XQGZ2024062401890_result_600
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select *,row_number() over(order by cell_code) as paixu 
from tmp_yz_XQGZ2024062401890_result_600_2;


drop table tmp_yz_XQGZ2024062401890_result_1200_1 purge;
create table tmp_yz_XQGZ2024062401890_result_1200_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  
std_subst_name  --落地分局
,cell_name  --落地网格名称
,cell_code  --网格编码
,addr_9_label  --落地9级地址标签
,sum(case when par_month_id>=202301 and par_month_id<=202405 then rw_num else 0 end) as rw  --202301-202405入网量
,sum(case when par_month_id>=202301 and par_month_id<=202405 then rw_jf else 0 end) as rw_kd_jf  --202301-202405入网积分
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=1 then rw_num else 0 end) as rh_rw_kd --202301-202405 融合入网量
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=1 then rw_jf else 0 end) as rh_rw_jf  --202301-202405 融合入网积分
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=0 then rw_num else 0 end) as rw_dk  --202301-202405 非融合入网量
,sum(case when par_month_id>=202301 and par_month_id<=202405 and is_rh_ykj=0 then rw_jf else 0 end) as rw_dk_jf  --202301-202405 非融合入网积分

,sum(case when par_month_id=202406 then rw_num else 0 end) as rw_202406  --202406入网量
,sum(case when par_month_id=202406 then rw_jf else 0 end) as rw_kd_jf_202406  --202406入网积分
,sum(case when par_month_id=202406 and is_rh_ykj=1 then rw_num else 0 end) as rh_rw_202406 --202406 融合入网量
,sum(case when par_month_id=202406 and is_rh_ykj=1 then rw_jf else 0 end) as rh_rw_jf_202406  --202406 融合入网积分
,sum(case when par_month_id=202406 and is_rh_ykj=0 then rw_num else 0 end) as rw_dk_202406  --202406 非融合入网量
,sum(case when par_month_id=202406 and is_rh_ykj=0 then rw_jf else 0 end) as rw_dk_jf_202406  --202406 非融合入网积分

,0 as dd  --202405 主宽到达数
,0 as dd_kd_jf  --202405 主宽到达积分
,0 as rh_dd --202405 融合主宽到达数
,0 as rh_dd_jf  --202405 融合主宽到达积分
,0 as dd_dk  --202405 非融合主宽到达数
,0 as dd_dk_jf  --202405 非融合主宽到达积分
from ads_yz_XQGZ2024062401890_1 
where bn_lx='1200元包年'  --包年类型：600元包年/1200元包年
group by std_subst_name
,cell_name
,cell_code
,addr_9_label

union all
select  
std_subst_name  --落地分局
,cell_name  --落地网格名称
,cell_code  --网格编码
,addr_9_label  --落地9级地址标签

,0 as rw  --202301-202405入网量
,0 as rw_kd_jf  --202301-202405入网积分
,0 as rh_rw_kd --202301-202405 融合入网量
,0 as rh_rw_jf  --202301-202405 融合入网积分
,0 as rw_dk  --202301-202405 非融合入网量
,0 as rw_dk_jf  --202301-202405 非融合入网积分

,0 as rw_202406  --202406入网量
,0 as rw_kd_jf_202406  --202406入网积分
,0 as rh_rw_202406 --202406 融合入网量
,0 as rh_rw_jf_202406  --202406 融合入网积分
,0 as rw_dk_202406  --202406 非融合入网量
,0 as rw_dk_jf_202406  --202406 非融合入网积分

,sum(dd_num) as dd  --202405 主宽到达数
,sum(dd_jf) as dd_kd_jf  --202405 主宽到达积分
,sum(case when is_rh_ykj=1 then dd_num else 0 end) as rh_dd --202405 融合主宽到达数
,sum(case when is_rh_ykj=1 then dd_jf else 0 end) as rh_dd_jf  --202405 融合主宽到达积分
,sum(case when is_rh_ykj=0 then dd_num else 0 end) as dd_dk  --202405 非融合主宽到达数
,sum(case when is_rh_ykj=0 then dd_jf else 0 end) as dd_dk_jf  --202405 非融合主宽到达积分
from ads_yz_XQGZ2024062401890_2 
where bn_lx='1200元包年'  --包年类型：600元包年/1200元包年
group by std_subst_name
,cell_name
,cell_code
,addr_9_label;

drop table tmp_yz_XQGZ2024062401890_result_1200_2 purge;
create table tmp_yz_XQGZ2024062401890_result_1200_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select std_subst_name
,cell_name
,cell_code
,addr_9_label
,sum(rw) rw_2301_2405
,sum(rw_kd_jf) rw_jf_2301_2405
,sum(rh_rw_kd)  rh_rw_2301_2405
,sum(rh_rw_jf) rh_rw_jf_2301_2405
,sum(rw_dk) rw_dk_2301_2405
,sum(rw_dk_jf) rw_dk_jf_2301_2405
,sum(rw_202406) rw_2406
,sum(rw_kd_jf_202406)  rw_kd_jf_2406
,sum(rh_rw_202406) rh_rw_2406
,sum(rh_rw_jf_202406) rh_rw_jf_2406
,sum(rw_dk_202406) rw_dk_2406
,sum(rw_dk_jf_202406) rw_dk_jf_2406
,sum(dd) dd_2405
,sum(dd_kd_jf) dd_jf_2405
,sum(rh_dd) rh_dd_2405
,sum(rh_dd_jf) rh_dd_jf_2405
,sum(dd_dk) dd_dk_2405
,sum(dd_dk_jf) dd_dk_jf_2405
from tmp_yz_XQGZ2024062401890_result_1200_1
group by std_subst_name
,cell_name
,cell_code
,addr_9_label;

drop table tmp_yz_XQGZ2024062401890_result_1200 purge;
create table tmp_yz_XQGZ2024062401890_result_1200
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select *,row_number() over(order by cell_code) as paixu 
from tmp_yz_XQGZ2024062401890_result_1200_2;

--统计组合包的受理量
drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  202406 as par_month_id,a.serv_id,count(distinct a.prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where prod_offer_id in(100018113,5731962,100096993) --prod_offer_code in('YD0303-531-1-1','DM0001-233','DM0001-687-1-1')
and date_format(limit_date,'yyyyMMdd')>'20240629' group by a.serv_id ;


drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  202406 as par_month_id,serv_id,count(distinct prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where prod_offer_id in(500072204,100027003) --prod_offer_code in('DM0001-937-1-5','DM0001-487-1-1')
and date_format(limit_date,'yyyyMMdd')>'20240629' group by a.serv_id;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
SELECT a.par_month_id,a.std_subst_name,a.cell_name
,case when b.serv_id is not null then 1 else 0 end is_600_bn
,case when c.serv_id is not null then 1 else 0 end is_1200_bn
,a.cell_code,a.serv_id,a.rh_tc_value,a.serv_addr_id,a.is_rh_ykj
FROM ads_yz_kd_new_list a 
left join (select distinct serv_id from tmp_yz_liq_1 where num=3 ) b on a.serv_id=b.serv_id 
left join (select distinct serv_id from tmp_yz_liq_2 where num=2 ) c on a.serv_id=c.serv_id 
WHERE a.par_month_id=202406
AND a.kd_desc = '普通宽带' 
AND coalesce(a.prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(a.prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(a.kd_prod_offer_name, '-1') NOT LIKE '%0时长%' 
;


drop table tmp_yz_liq_6_1 purge;
create table tmp_yz_liq_6_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.obj_id  --9级地址id
,a.label_id --地址标签
,a.create_date
,b.index3 as addr_9_label
from  (select distinct obj_id,label_id,create_date from dws_grid.dws_grid_label_setting_inst where city_id=200) a --地址打标标签
left join zone_gz_yz_3351225714708480 b on cast(a.label_id as string)=b.index2
;

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,row_number() over(partition by obj_id order by addr_9_label desc,create_date desc ) as paixu
from tmp_yz_liq_6_1 a;

drop table tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
b.parentid as serv_addr_9
,c.addr_9_label
from tmp_yz_liq_5 a  
left join (select distinct id,addr
,parentid --id的上一级
from dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id 
left join tmp_yz_liq_6 c on b.parentid=c.obj_id and c.paixu=1;

drop table tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 	'600元包年' as bn_lx,par_month_id,std_subst_name,cell_name,cell_code
,count(DISTINCT serv_id) AS rw_num
,count(DISTINCT case when addr_9_label='商企高价值（999及以上档）' then serv_id else null end) AS rw_sq_999
,count(DISTINCT case when addr_9_label='商企高价值（699及以上档）' then serv_id else null end) AS rw_sq_699
,count(DISTINCT case when addr_9_label='商企高价值（299及以上档）' then serv_id else null end) AS rw_sq_299
,count(DISTINCT case when addr_9_label='商企高价值（399及以上档）' then serv_id else null end) AS rw_sq_399
,count(DISTINCT case when addr_9_label='灰色房间策反（79及以上档）' then serv_id else null end) AS rw_hs_79
,count(DISTINCT case when addr_9_label='普通（229及以上档）' then serv_id else null end) AS rw_pt_229
,count(DISTINCT case when addr_9_label='城中村（129及以上档）' then serv_id else null end) AS rw_czc_129
,count(DISTINCT case when addr_9_label='高流失（129及以上档）' then serv_id else null end) AS rw_fls_129
,count(DISTINCT case when addr_9_label='高竞争（199及以上档）' then serv_id else null end) AS rw_fjz_199
,count(DISTINCT case when addr_9_label='疑似第三方收费地址（楼宇）' then serv_id else null end) AS rw_dsf_sf

from tmp_yz_liq_7 where is_600_bn=1
group by par_month_id,std_subst_name,cell_name,cell_code

union all 
select 	'1200元包年' as bn_lx,par_month_id,std_subst_name,cell_name,cell_code
,count(DISTINCT serv_id) AS rw_num
,count(DISTINCT case when addr_9_label='商企高价值（999及以上档）' then serv_id else null end) AS rw_sq_999
,count(DISTINCT case when addr_9_label='商企高价值（699及以上档）' then serv_id else null end) AS rw_sq_699
,count(DISTINCT case when addr_9_label='商企高价值（299及以上档）' then serv_id else null end) AS rw_sq_299
,count(DISTINCT case when addr_9_label='商企高价值（399及以上档）' then serv_id else null end) AS rw_sq_399
,count(DISTINCT case when addr_9_label='灰色房间策反（79及以上档）' then serv_id else null end) AS rw_hs_79
,count(DISTINCT case when addr_9_label='普通（229及以上档）' then serv_id else null end) AS rw_pt_229
,count(DISTINCT case when addr_9_label='城中村（129及以上档）' then serv_id else null end) AS rw_czc_129
,count(DISTINCT case when addr_9_label='高流失（129及以上档）' then serv_id else null end) AS rw_fls_129
,count(DISTINCT case when addr_9_label='高竞争（199及以上档）' then serv_id else null end) AS rw_fjz_199
,count(DISTINCT case when addr_9_label='疑似第三方收费地址（楼宇）' then serv_id else null end) AS rw_dsf_sf
from tmp_yz_liq_7 where is_1200_bn=1
group by par_month_id,std_subst_name,cell_name,cell_code;

---------------------------------------------------------------------------------------------
--20240802  张晓明  补充需求  202407月组合包入网量
select label_id from dws_bss3e_mgr_plus.dws_ss_label_setting where city_id=200 
and label_code='GZ20240704105721'  --1000000041135

--统计组合包的受理量
drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  202407 as par_month_id,a.serv_id,count(distinct a.prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where prod_offer_id in(100018113,5731962,100096993) --prod_offer_code in('YD0303-531-1-1','DM0001-233','DM0001-687-1-1')
and date_format(limit_date,'yyyyMMdd')>'20240731' group by a.serv_id ;


drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  202407 as par_month_id,serv_id,count(distinct prod_offer_id) num 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where prod_offer_id in(500072204,100027003) --prod_offer_code in('DM0001-937-1-5','DM0001-487-1-1')
and date_format(limit_date,'yyyyMMdd')>'20240731' group by a.serv_id;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
SELECT a.par_month_id,a.std_subst_name,a.cell_name
,case when b.serv_id is not null then 1 else 0 end is_600_bn
,case when c.serv_id is not null then 1 else 0 end is_1200_bn
,a.cell_code,a.serv_id,a.rh_tc_value,a.serv_addr_id,a.is_rh_ykj
FROM ads_yz_kd_new_list a 
left join (select distinct serv_id from tmp_yz_liq_1 where num=3 ) b on a.serv_id=b.serv_id 
left join (select distinct serv_id from tmp_yz_liq_2 where num=2 ) c on a.serv_id=c.serv_id 
WHERE a.par_month_id=202407
AND a.kd_desc = '普通宽带' 
AND coalesce(a.prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(a.prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(a.kd_prod_offer_name, '-1') NOT LIKE '%0时长%' 
;


drop table tmp_yz_liq_6_1 purge;
create table tmp_yz_liq_6_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.obj_id  --地址id
,a.label_id --地址标签
,a.create_date
,b.index3 as addr_9_label
from  (select distinct obj_id,label_id,create_date from dws_grid.dws_grid_label_setting_inst where city_id=200) a --地址打标标签
left join zone_gz_yz_3351225714708480 b on cast(a.label_id as string)=b.index2
;

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,row_number() over(partition by obj_id order by addr_9_label desc,create_date desc ) as paixu
from tmp_yz_liq_6_1 a;

drop table tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
b.parentid as serv_addr_9
,c.addr_9_label
from tmp_yz_liq_5 a  
left join (select distinct id,addr
,parentid --id的上一级
from dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id 
left join tmp_yz_liq_6 c on b.parentid=c.obj_id and c.paixu=1;

--打标新楼盘
drop table tmp_yz_liq_8_1 purge;
create table tmp_yz_liq_8_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.obj_id  --地址id
,a.label_id --地址标签
,a.create_date
,'新楼盘' addr_8_label
from  (select distinct obj_id,label_id,create_date from dws_grid.dws_grid_label_setting_inst where city_id=200) a --地址打标标签
where cast(a.label_id as string)='1000000041135'
;

drop table tmp_yz_liq_8_2 purge;
create table tmp_yz_liq_8_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
b.parentid as serv_addr_8
,case when c.obj_id is not null then 1 else 0 end is_xlp
from tmp_yz_liq_7 a  
left join (select distinct id,addr
,parentid --id的上一级
from dwd_yz_addr_final where grade=9) b on cast(a.serv_addr_9 as decimal(24,0))=b.id 
left join (select distinct obj_id from tmp_yz_liq_8_1) c on b.parentid=c.obj_id;

drop table tmp_yz_liq_8_3 purge;
create table tmp_yz_liq_8_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,case when b.cell_code is not null then '是' else '否' end is_xlp_wg
from tmp_yz_liq_8_2 a 
left join (select cell_code,sum(is_xlp) is_wg_xlp from tmp_yz_liq_8_2 group by cell_code) b on a.cell_code=b.cell_code and b.is_wg_xlp>0
;

drop table tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 	'600元包年' as bn_lx,par_month_id,std_subst_name,cell_name,is_xlp_wg,cell_code
,count(DISTINCT serv_id) AS rw_num
,count(DISTINCT case when addr_9_label='商企高价值（999及以上档）' then serv_id else null end) AS rw_sq_999
,count(DISTINCT case when addr_9_label='商企高价值（699及以上档）' then serv_id else null end) AS rw_sq_699
,count(DISTINCT case when addr_9_label='商企高价值（299及以上档）' then serv_id else null end) AS rw_sq_299
,count(DISTINCT case when addr_9_label='商企高价值（399及以上档）' then serv_id else null end) AS rw_sq_399
,count(DISTINCT case when addr_9_label='灰色房间策反（79及以上档）' then serv_id else null end) AS rw_hs_79
,count(DISTINCT case when addr_9_label='普通（229及以上档）' then serv_id else null end) AS rw_pt_229
,count(DISTINCT case when addr_9_label='城中村（129及以上档）' then serv_id else null end) AS rw_czc_129
,count(DISTINCT case when addr_9_label='高流失（129及以上档）' then serv_id else null end) AS rw_fls_129
,count(DISTINCT case when addr_9_label='高竞争（199及以上档）' then serv_id else null end) AS rw_fjz_199
,count(DISTINCT case when addr_9_label='疑似第三方收费地址（楼宇）' then serv_id else null end) AS rw_dsf_sf

from tmp_yz_liq_8_3 where is_600_bn=1
group by par_month_id,std_subst_name,cell_name,is_xlp_wg,cell_code
;

--XQGZ2024062600962 需求标题 关于岭南新世界对应分光器下挂的号码数量以及月收入查询的需求 
drop table tmp_yz_liq_11 purge;
create table tmp_yz_liq_11 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select '202406' as month_id,cast(prod_inst_id as decimal(22,0)) as serv_id  --号码
,case when BOX_CODE is not null and BOX_CODE <> '' then BOX_CODE else obd_code end as CROSS_CODE --分光器
,update_date
from dws_crm_cust.dws_cust_serv_res --当前月
where city_id='200' 
union all 
select date_format(his_create_date,'yyyyMM') as month_id,cast(prod_inst_id as decimal(22,0)) as serv_id  --号码
,case when BOX_CODE is not null and BOX_CODE <> '' then BOX_CODE else obd_code end as CROSS_CODE --分光器
,update_date
from dws_crm_cust.dws_cust_serv_res_his --历史月
where city_id='200' and date_format(his_create_date,'yyyyMM')>='202401';

drop table tmp_yz_liq_12 purge;
create table tmp_yz_liq_12 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select *,
row_number() over(partition by month_id,serv_id order by update_date desc) as paixu 
from tmp_yz_liq_11 where CROSS_CODE in('ABYLNXSJWE057/ODN001','ABYLNXSJWE058/ODN004','ABYLNXSJWE073/ODN003','ABYLNXSJWE073/ODN004','ABYLNXSJWE073/ODN005','ABYLNXSJWE073/ODN006','ABYLNXSJWE073/ODN007','ABYLNXSJWE083/ODN001','ABYLNXSJWE083/ODN002','ABYLNXSJWE083/ODN003','ABYLNXSJWE083/ODN004','ABYLNXSJWE083/ODN005','ABYLNXSJWE058/ODN005','ABYLNXSJWE083/ODN006','ABYLNXSJWE083/ODN007','ABYLNXSJWE083/ODN008','ABYLNXSJWE084/ODN001','ABYLNXSJWE084/ODN002','ABYLNXSJWE084/ODN003','ABYLNXSJWE084/ODN004','ABYLNXSJWE084/ODN005','ABYLNXSJWE084/ODN008','ABYLNXSJWE084/ODN007','ABYLNXSJWE058/ODN006','ABYLNXSJWE084/ODN006','ABYLNXSJWE085/ODN001','ABYLNXSJWE085/ODN002','ABYLNXSJWE085/ODN003','ABYLNXSJWE085/ODN004','ABYLNXSJWE085/ODN005','ABYLNXSJWE085/ODN006','ABYLNXSJWE085/ODN007','ABYLNXSJWE085/ODN008','ABYLNXSJWE086/ODN001','ABYLNXSJWE059/ODN001','ABYLNXSJWE086/ODN002','ABYLNXSJWE086/ODN003','ABYLNXSJWE086/ODN004','ABYLNXSJWE086/ODN005','ABYLNXSJWE086/ODN006','ABYLNXSJWE086/ODN007','ABYLNXSJWE087/ODN001','ABYLNXSJWE087/ODN002','ABYLNXSJWE087/ODN003','ABYLNXSJWE087/ODN004','ABYLNXSJWE059/ODN002','ABYLNXSJWE087/ODN005','ABYLNXSJWE087/ODN006','ABYLNXSJWE087/ODN007','ABYLNXSJWE087/ODN008','ABYLNXSJWE088/ODN001','ABYLNXSJWE088/ODN002','ABYLNXSJWE088/ODN003','ABYLNXSJWE088/ODN004','ABYLNXSJWE088/ODN005','ABYLNXSJWE088/ODN006','ABYLNXSJWE059/ODN003','ABYLNXSJWE088/ODN007','ABYLNXSJWE088/ODN008','ABYLNXSJWE089/ODN001','ABYLNXSJWE089/ODN002','ABYLNXSJWE089/ODN003','ABYLNXSJWE089/ODN004','ABYLNXSJWE089/ODN005','ABYLNXSJWE089/ODN006','ABYLNXSJWE089/ODN007','ABYLNXSJWE089/ODN008','ABYLNXSJWE059/ODN004','ABYLNXSJWE090/ODN001','ABYLNXSJWE090/ODN002','ABYLNXSJWE090/ODN003','ABYLNXSJWE090/ODN004','ABYLNXSJWE090/ODN005','ABYLNXSJWE090/ODN006','ABYLNXSJWE090/ODN007','ABYLNXSJWE091/ODN001','ABYLNXSJWE091/ODN002','ABYLNXSJWE091/ODN003','ABYLNXSJWE059/ODN005','ABYLNXSJWE091/ODN004','ABYLNXSJWE091/ODN005','ABYLNXSJWE091/ODN006','ABYLNXSJWE091/ODN007','ABYLNXSJWE091/ODN008','ABYLNXSJWE092/ODN001','ABYLNXSJWE092/ODN002','ABYLNXSJWE092/ODN003','ABYLNXSJWE092/ODN004','ABYLNXSJWE092/ODN005','ABYLNXSJWE059/ODN006','ABYLNXSJWE092/ODN006','ABYLNXSJWE092/ODN007','ABYLNXSJWE092/ODN008','ABYLNXSJWE093/ODN001','ABYLNXSJWE093/ODN002','ABYLNXSJWE093/ODN003','ABYLNXSJWE093/ODN004','ABYLNXSJWE093/ODN005','ABYLNXSJWE093/ODN006','ABYLNXSJWE093/ODN007','ABYLNXSJWE060/ODN001','ABYLNXSJWE093/ODN008','ABYLNXSJWE094/ODN001','ABYLNXSJWE094/ODN002','ABYLNXSJWE094/ODN003','ABYLNXSJWE094/ODN004','ABYLNXSJWE094/ODN005','ABYLNXSJWE094/ODN006','ABYLNXSJWE094/ODN007','ABYLNXSJWE095/ODN001','ABYLNXSJWE095/ODN002','ABYLNXSJWE057/ODN002','ABYLNXSJWE060/ODN002','ABYLNXSJWE095/ODN003','ABYLNXSJWE095/ODN004','ABYLNXSJWE095/ODN005','ABYLNXSJWE095/ODN006','ABYLNXSJWE095/ODN007','ABYLNXSJWE095/ODN008','ABYLNXSJWE096/ODN001','ABYLNXSJWE096/ODN002','ABYLNXSJWE096/ODN003','ABYLNXSJWE096/ODN004','ABYLNXSJWE060/ODN003','ABYLNXSJWE096/ODN005','ABYLNXSJWE096/ODN006','ABYLNXSJWE096/ODN007','ABYLNXSJWE096/ODN008','ABYLNXSJWE097/ODN001','ABYLNXSJWE097/ODN002','ABYLNXSJWE097/ODN003','ABYLNXSJWE097/ODN004','ABYLNXSJWE097/ODN005','ABYLNXSJWE097/ODN006','ABYLNXSJWE060/ODN004','ABYLNXSJWE097/ODN007','ABYLNXSJWE097/ODN008','ABYLNXSJWE098/ODN001','ABYLNXSJWE098/ODN002','ABYLNXSJWE098/ODN003','ABYLNXSJWE098/ODN004','ABYLNXSJWE098/ODN005','ABYLNXSJWE098/ODN006','ABYLNXSJWE098/ODN007','ABYLNXSJWE062/ODN001','ABYLNXSJWE062/ODN002','ABYLNXSJWE062/ODN003','ABYLNXSJWE062/ODN004','ABYLNXSJWE062/ODN005','ABYLNXSJWE062/ODN006','ABYLNXSJWE063/ODN001','ABYLNXSJWE057/ODN003','ABYLNXSJWE063/ODN003','ABYLNXSJWE063/ODN004','ABYLNXSJWE063/ODN006','ABYLNXSJWE064/ODN001','ABYLNXSJWE064/ODN002','ABYLNXSJWE064/ODN003','ABYLNXSJWE064/ODN004','ABYLNXSJWE064/ODN005','ABYLNXSJWE057/ODN004','ABYLNXSJWE064/ODN006','ABYLNXSJWE065/ODN001','ABYLNXSJWE065/ODN002','ABYLNXSJWE065/ODN003','ABYLNXSJWE065/ODN004','ABYLNXSJWE066/ODN001','ABYLNXSJWE066/ODN002','ABYLNXSJWE066/ODN003','ABYLNXSJWE066/ODN004','ABYLNXSJWE066/ODN005','ABYLNXSJWE066/ODN006','ABYLNXSJWE066/ODN007','ABYLNXSJWE066/ODN008','ABYLNXSJWE067/ODN001','ABYLNXSJWE067/ODN002','ABYLNXSJWE067/ODN003','ABYLNXSJWE067/ODN004','ABYLNXSJWE067/ODN005','ABYLNXSJWE067/ODN006','ABYLNXSJWE067/ODN007','ABYLNXSJWE057/ODN006','ABYLNXSJWE067/ODN008','ABYLNXSJWE068/ODN001','ABYLNXSJWE068/ODN002','ABYLNXSJWE068/ODN003','ABYLNXSJWE068/ODN004','ABYLNXSJWE068/ODN005','ABYLNXSJWE068/ODN006','ABYLNXSJWE068/ODN007','ABYLNXSJWE068/ODN008','ABYLNXSJWE069/ODN001','ABYLNXSJWE058/ODN001','ABYLNXSJWE069/ODN002','ABYLNXSJWE069/ODN003','ABYLNXSJWE069/ODN004','ABYLNXSJWE069/ODN005','ABYLNXSJWE070/ODN001','ABYLNXSJWE070/ODN002','ABYLNXSJWE070/ODN003','ABYLNXSJWE070/ODN004','ABYLNXSJWE070/ODN005','ABYLNXSJWE070/ODN006','ABYLNXSJWE058/ODN002','ABYLNXSJWE070/ODN007','ABYLNXSJWE070/ODN008','ABYLNXSJWE071/ODN001','ABYLNXSJWE071/ODN002','ABYLNXSJWE071/ODN003','ABYLNXSJWE071/ODN004','ABYLNXSJWE071/ODN005','ABYLNXSJWE071/ODN006','ABYLNXSJWE071/ODN007','ABYLNXSJWE071/ODN008','ABYLNXSJWE058/ODN003','ABYLNXSJWE072/ODN001','ABYLNXSJWE072/ODN002','ABYLNXSJWE072/ODN003','ABYLNXSJWE072/ODN004','ABYLNXSJWE072/ODN005','ABYLNXSJWE072/ODN006','ABYLNXSJWE072/ODN007','ABYLNXSJWE072/ODN008','ABYLNXSJWE073/ODN001','ABYLNXSJWE073/ODN002','ABYJXYUAU100/ODN002','ABYXSH00WE123/ODN001','ABYXSH00WE127/ODN002','ABYXSH00WE128/ODN001','ABYXSH00WE128/ODN002','ABYXSH00WE129/ODN001','ABYXSH00WE129/ODN002','ABYXSH00WE130/ODN001','ABYXSH00WE130/ODN002','ABYXSH00WE131/ODN001','ABYXSH00WE131/ODN002','ABYXSH00WE132/ODN001','ABYXSH00WE123/ODN002','ABYXSH00WE132/ODN002','ABYXSH00WE133/ODN001','ABYXSH00WE133/ODN002','ABYXSH00WE134/ODN001','ABYXSH00WE134/ODN002','ABYXSH00WE135/ODN001','ABYXSH00WE135/ODN002','ABYXSH00WE136/ODN001','ABYXSH00WE136/ODN002','ABYXSH00WE137/ODN001','ABYXSH00WE124/ODN001','ABYXSH00WE137/ODN002','ABYXSH00WE138/ODN001','ABYXSH00WE138/ODN002','ABYXSH00WE139/ODN001','ABYXSH00WE139/ODN002','ABYXSH00WE140/ODN001','ABYXSH00WE140/ODN002','ABYXSH00WE141/ODN001','ABYXSH00WE141/ODN002','ABYXSH00WE142/ODN001','ABYXSH00WE124/ODN002','ABYXSH00WE142/ODN002','ABYXSH00WE143/ODN001','ABYXSH00WE143/ODN002','ABYXSH00WE144/ODN001','ABYXSH00WE144/ODN002','ABYXSH00WE145/ODN001','ABYXSH00WE145/ODN002','ABYXSH00WE146/ODN001','ABYXSH00WE146/ODN002','ABYXSH00WE147/ODN001','ABYXSH00WE125/ODN001','ABYXSH00WE147/ODN002','ABYXSH00WE148/ODN001','ABYXSH00WE148/ODN002','ABYXSH00WE149/ODN001','ABYXSH00WE149/ODN002','ABYXSH00WE150/ODN001','ABYXSH00WE150/ODN002','ABYXSH00WE151/ODN001','ABYXSH00WE151/ODN002','ABYXSH00WE152/ODN001','ABYXSH00WE125/ODN002','ABYXSH00WE152/ODN002','ABYXSH00WE126/ODN001','ABYXSH00WE126/ODN002','ABYXSH00WE127/ODN001','ABYYTXCUWE004/ODN001','ABYYTXCUWE013/ODN001','ABYYTXCUWE014/ODN001','ABYYTXCUWE015/ODN001','ABYYTXCUWE016/ODN001','ABYYTXCUWE017/ODN001','ABYYTXCUWE018/ODN001','ABYYTXCUWE019/ODN001','ABYYTXCUWE020/ODN001','ABYYTXCUWE021/ODN001','ABYYTXCUWE022/ODN001','ABYYTXCUWE005/ODN001','ABYYTXCUWE023/ODN001','ABYYTXCUWE024/ODN001','ABYYTXCUWE025/ODN001','ABYYTXCUWE026/ODN001','ABYYTXCUWE027/ODN001','ABYYTXCUWE028/ODN001','ABYYTXCUWE006/ODN001','ABYYTXCUWE007/ODN001','ABYYTXCUWE008/ODN001','ABYYTXCUWE009/ODN001','ABYYTXCUWE010/ODN001','ABYYTXCUWE011/ODN001','ABYYTXCUWE012/ODN001','ABYYTXCUO029/ODN001','ABYLNXSJWE001/ODN001','ABYLNXSJWE024/ODN102','ABYLNXSJWE025/ODN104','ABYLNXSJWE026/ODN106','ABYLNXSJWE027/ODN109','ABYLNXSJWE028/ODN110','ABYLNXSJWE029/ODN113','ABYLNXSJWE030/ODN114','ABYLNXSJWE031/ODN116','ABYLNXSJWE032/ODN118','ABYLNXSJWE004/ODN013','ABYLNXSJWE004/ODN015','ABYLNXSJWE005/ODN017','ABYLNXSJWE006/ODN021','ABYLNXSJWE006/ODN022','ABYLNXSJWE007/ODN025','ABYLNXSJWE007/ODN027','ABYLNXSJWE008/ODN029','ABYLNXSJWE008/ODN031','ABYLNXSJWE008/ODN032','ABYLNXSJWE009/ODN033','ABYLNXSJWE010/ODN035','ABYLNXSJWE010/ODN036','ABYLNXSJWE011/ODN037','ABYLNXSJWE012/ODN039','ABYLNXSJWE040/ODN046','ABYLNXSJWE046/ODN063','ABYLNXSJWE047/ODN066','ABYLNXSJWE014/ODN069','ABYLNXSJWE014/ODN070','ABYLNXSJWE015/ODN073','ABYLNXSJWE015/ODN076','ABYLNXSJWE016/ODN077','ABYLNXSJWE016/ODN078','ABYLNXSJWE002/ODN008','ABYLNXSJWE017/ODN081','ABYLNXSJWE013/ODN085','ABYLNXSJWE013/ODN087','ABYLNXSJWE013/ODN088','ABYLNXSJWE048/ODN089','ABYLNXSJWE003/ODN009','ABYLNXSJWE019/ODN092','ABYLNXSJWE020/ODN095','ABYLNXSJWE021/ODN096','ABYXSH00O009/ODN002');

drop table tmp_yz_liq_13 purge;
create table tmp_yz_liq_13 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.fee_new_tax 
from tmp_yz_liq_12 a 
left join dwm_yz_tb_comm_cm_all_mon_final b 
on a.serv_id=b.serv_id and a.month_id=b.par_month_id
where a.paixu=1;

select month_id,CROSS_CODE,count(distinct serv_id) as NUM,sum(fee_new_tax) as sr 
from tmp_yz_liq_13 group by month_id,CROSS_CODE

--佣金吴湛取的驻地网网点号码（已经有对应的分光器）
--基于佣金数据，按省融合匹融合移动的宽带/固话
drop table tmp_yz_liq_11 purge;
create table tmp_yz_liq_11 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select serv_id,new_mix_type_relat_id,new_mix_type_prod
from iodata_ods_month_city.tb_lab_cm_new_mix_type_mon 
where par_month_id=202405 and par_corp_id=200 
and new_mix_type_prod in('移动+固话','移动+宽带+ITV+固话','移动+ITV+固话','移动+宽带+ITV','移动+宽带','移动+宽带+固话')
;

drop table tmp_yz_liq_12_1 purge;
create table tmp_yz_liq_12_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.prod_type,b.acc_nbr 
from tmp_yz_liq_11 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=202405;

drop table tmp_yz_liq_12 purge;
create table tmp_yz_liq_12 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,row_number() over(partition by new_mix_type_relat_id order by prod_type desc) as paixu
from tmp_yz_liq_12_1 a where prod_type in(40,10)
;

drop table tmp_yz_liq_13 purge;
create table tmp_yz_liq_13 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.new_mix_type_relat_id
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_liq_12_1 b 
on a.index2=b.acc_nbr;

drop table tmp_yz_liq_14 purge;
create table tmp_yz_liq_14 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,b.acc_nbr
from tmp_yz_liq_13 a 
left join tmp_yz_liq_12 b on a.new_mix_type_relat_id=b.new_mix_type_relat_id and b.paixu=1;

drop table tmp_yz_liq_15 purge;
create table tmp_yz_liq_15 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.index1,
a.index2,
a.index3,
a.index4,
a.index5,
a.index6,
a.index7,
a.index8,
a.index9,
a.index10,a.acc_nbr,row_number() over(order by index2) as paixu from tmp_yz_liq_14 a;

--XQGZ2024070802318 需求标题 关于历史绿名单欠费及使用状态查询 
业务号码	产权客编	"号码目前状态（是否拆机、停机、在用等）"	
如目前已拆机，拆机时间	
如目前已停机，停机时间	
号码目前用户名称与绿名单欠费账期的客户名称是否一致	
2024年1-7月是否有使用记录	
2024年1-7月通话分钟数	
2024年1-7月流量	
2024年1-7月短信数	
2024年1-7月彩信数

drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.acc_nbr
,a.cust_nbr 
,b.cust_nbr as cust_nbr_dq
,b.state
,case when b.serv_id is not null then 0 else 1 end is_cj
,b.stop_date
,b.prod_type
,b.prod_type2
from (select distinct acc_nbr,cust_nbr from ads_ysgl_green_qf) a 
left join dwm_yz_tb_comm_cm_all_final b on a.acc_nbr=b.acc_nbr and b.par_month_id=202407 and b.is_cancel_user=0;

drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.* 
,case when a.is_cj=1 then '拆机' else b.attr_value_name end as state_desc
from tmp_yz_liq_1 a 
left join dws_crm_cfguse.dws_attr_value b on a.state=b.attr_value and b.city_id='200' and b.attr_id='4000000201';

use zone_gz_yz;
set hive.exec.parallel=true; -- 不同job可以并发执行
set hive.exec.parallel.thread.number=32;
set hive.vectorized.execution.enabled=false;  --  关闭向量化查询
set hive.vectorized.execution.reduce.enabled=false; --  关闭向量化查询
set hive.groupby.skewindata=false;
drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct a.acc_nbr,a.hist_create_date 
from dwm_yz_tb_comm_cm_all_mon_final a
where is_cancel_user=1 
and acc_nbr in(select distinct acc_nbr from tmp_yz_liq_2 where is_cj=1) 
union all 
select distinct a.acc_nbr,a.hist_create_date 
from dwm_yz_tb_comm_cm_all_final a
where is_cancel_user=1 
and acc_nbr in(select distinct acc_nbr from tmp_yz_liq_2 where is_cj=1) 
and par_month_id=202407;

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.hist_create_date 
from tmp_yz_liq_2 a 
left join (select *,row_number() over(partition by acc_nbr order by hist_create_date desc) as paixu from tmp_yz_liq_3) b 
on a.acc_nbr=b.acc_nbr and b.paixu=1;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when coalesce(cust_nbr,'-1')<>coalesce(cust_nbr_dq,'-1') then '否' else '是' end as is_same_cust 
from tmp_yz_liq_4 a ; 

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select acc_nbr,sum(mou_call) mou_call_sum
,sum(stm_data) stm_data_sum
,sum(mgs_counts) mgs_counts_sum
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202401 and par_month_id<=202406 and is_cancel_user=0 
group by acc_nbr
union all 
select acc_nbr,sum(mou_call) mou_call_sum
,sum(stm_data) stm_data_sum
,sum(mgs_counts) mgs_counts_sum
from dwm_yz_tb_comm_cm_all_final where par_month_id=202407  and is_cancel_user=0 
group by acc_nbr;

drop table tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,b.mou_call
,b.stm_data
,b.mgs_counts 

,0 as kd_ll_sum
,0 as kd_sc_sum

,0 as gw_sc_sum 
from tmp_yz_liq_5 a 
left join (select acc_nbr,sum(mou_call_sum) mou_call,sum(stm_data_sum) stm_data,sum(mgs_counts_sum) mgs_counts from tmp_yz_liq_6 group by acc_nbr) b 
on a.acc_nbr=b.acc_nbr 
where a.prod_type=30;

drop table tmp_yz_liq_8_1 purge;
create table tmp_yz_liq_8_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select acc_nbr,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll, --宽带流量 单位M
cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon 
where par_corp_id=200 and par_month_id>=202401 and par_month_id<=202407;

drop table tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,0 as mou_call
,0 as stm_data
,0 as mgs_counts

,b.kd_ll_sum
,b.kd_sc_sum

,0 as gw_sc_sum 
from tmp_yz_liq_5 a 
left join (select acc_nbr,sum(kd_ll) kd_ll_sum,sum(kd_sc) kd_sc_sum from tmp_yz_liq_8_1 group by acc_nbr) b
on a.acc_nbr=b.acc_nbr 
where a.prod_type=40;

drop table tmp_yz_liq_9_1 purge;
create table tmp_yz_liq_9_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select acc_nbr,
cast(DUR/60 as decimal(22,2)) gw_sc  --固网通话时长 单位分
from summary_ods_month_city.TB_COMM_YWL_GW_mon where par_corp_id=200 and par_month_id>=202401 and par_month_id<=202407
;

drop table tmp_yz_liq_9 purge;
create table tmp_yz_liq_9
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,0 as mou_call
,0 as stm_data
,0 as mgs_counts

,0 as kd_ll_sum
,0 as kd_sc_sum

,b.gw_sc_sum 
from tmp_yz_liq_5 a 
left join (select acc_nbr,sum(gw_sc) gw_sc_sum from tmp_yz_liq_9_1 group by acc_nbr) b
on a.acc_nbr=b.acc_nbr 
where coalesce(a.prod_type,-1) not in(30,40);

drop table tmp_yz_liq_10 purge;
create table tmp_yz_liq_10
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select * from tmp_yz_liq_7 
union all 
select * from tmp_yz_liq_8 
union all
select * from tmp_yz_liq_9 ;

drop table tmp_yz_liq_11 purge;
create table tmp_yz_liq_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case when a.prod_type=30 then '移动' when prod_type=40 and coalesce(prod_type2,-1)<>50 then '宽带' 
when prod_type=10 then '固话' when prod_type2=50 then 'itv' else '其他' end as prod_type_desc 
from tmp_yz_liq_10;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_liq_12 purge;
create table tmp_yz_liq_12
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select acc_nbr,
sum( coalesce(cast(boot_times as decimal),0) ) login_times_m --本月开机次数
from zone_tygqmid.dws_login_list
where day>='20240101' and day<='20240715' and area_name='广州'
group by acc_nbr

union all 
select acc_nbr,
sum( coalesce(cast(boot_times as decimal),0) ) login_times_m --本月开机次数
from zone_gz_yz.dws_login_list_final 
where day>='20240101' and day<='20240715' and area_name='广州'
group by acc_nbr;

drop table tmp_yz_liq_13 purge;
create table tmp_yz_liq_13
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.* 
,case when b.acc_nbr is not null then 1 else 0 end as is_itv_hy 
from tmp_yz_liq_11 a 
left join (select distinct acc_nbr from tmp_yz_liq_12 where login_times_m>=1) b on a.acc_nbr=b.acc_nbr;

drop table tmp_yz_liq_14 purge;
create table tmp_yz_liq_14
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
case when prod_type_desc='移动' and coalesce(mou_call,0)+coalesce(stm_data,0)+coalesce(mgs_counts,0)>0 then '是' 
when prod_type_desc='宽带' and coalesce(kd_ll_sum,0)+coalesce(kd_sc_sum,0)>0 then '是' 
when prod_type_desc='固话' and coalesce(gw_sc_sum,0)>0 then '是' 
when prod_type_desc='itv' and is_itv_hy>0 then '是' 
else '否' end as is_shiyong
from tmp_yz_liq_13 a ;

--XQGZ2024071901176 需求标题 宽带报障修障感知调研清单字段匹配 
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select par_month_id,serv_id,acc_nbr,subst_name,branch_name,area_name,cust_name
,case when serv_grp_type='01' then '政企' when serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc
,is_cancel_user
--,is_rh_ykj,speed_value
,open_date
,case when star_level = '3100' then '一星'
    when star_level = '3200' then '二星'
    when star_level = '3300' then '三星'
    when star_level = '3400' then '四星'
    when star_level = '3500' then '五星'
    when star_level = '3600' then '六星'
    when star_level = '3700' then '七星' else '0星' end as star_level_desc
from dwm_yz_tb_comm_cm_all_mon_final where is_cancel_user=1 
and cust_name in(select distinct index3 from zone_gz_yz_3351225714708480)

union all 
select par_month_id,serv_id,acc_nbr,subst_name,branch_name,area_name,cust_name
,case when serv_grp_type='01' then '政企' when serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc
,is_cancel_user
--,is_rh_ykj,speed_value
,open_date
,case when star_level = '3100' then '一星'
    when star_level = '3200' then '二星'
    when star_level = '3300' then '三星'
    when star_level = '3400' then '四星'
    when star_level = '3500' then '五星'
    when star_level = '3600' then '六星'
    when star_level = '3700' then '七星' else '0星' end as star_level_desc
from dwm_yz_tb_comm_cm_all_final where is_cancel_user=1 and par_month_id=202408
and cust_name in(select distinct index3 from zone_gz_yz_3351225714708480);

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.is_rh_ykj,b.speed_value 
from tmp_yz_liq_1 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id 
and  (case when mod(a.par_month_id,100)<>1 then (a.par_month_id-1)
          else (a.par_month_id-89) end)=b.par_month_id;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.index1 as kd_acc_tm
,a.index2 as lx_acc_nbr
,a.index3 as cust_name

,b.acc_nbr
,b.subst_name,b.branch_name,b.area_name
,case when b.serv_grp_type='01' then '政企' when b.serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc
,b.is_cancel_user,b.is_rh_ykj,b.speed_value,b.open_date
,case when b.star_level = '3100' then '一星'
    when b.star_level = '3200' then '二星'
    when b.star_level = '3300' then '三星'
    when b.star_level = '3400' then '四星'
    when b.star_level = '3500' then '五星'
    when b.star_level = '3600' then '六星'
    when b.star_level = '3700' then '七星' else '0星' end as star_level_desc
from zone_gz_yz_3351225714708480 a 
left join dwm_yz_tb_comm_cm_all_final b on a.index3=b.cust_name 
and SUBSTR(a.index1,1,(length(a.index1)-4))=SUBSTR(b.acc_nbr,1,(length(b.acc_nbr)-5)) 
and b.par_month_id=202408 and b.is_cancel_user=0;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.kd_acc_tm
,a.lx_acc_nbr
,a.cust_name

,b.acc_nbr
,b.subst_name,b.branch_name,b.area_name
,b.serv_grp_type_desc
,b.is_cancel_user,b.is_rh_ykj,b.speed_value,b.open_date
,b.star_level_desc

from tmp_yz_liq_3 a 
left join tmp_yz_liq_2 b on a.cust_name=b.cust_name 
and SUBSTR(a.kd_acc_tm,1,(length(a.kd_acc_tm)-4))=SUBSTR(b.acc_nbr,1,(length(b.acc_nbr)-5)) 
where a.acc_nbr is null
;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from tmp_yz_liq_3 where acc_nbr is not null
union 
select * from tmp_yz_liq_4;

drop table tmp_yz_liq_XQGZ2024071901176 purge;
create table tmp_yz_liq_XQGZ2024071901176 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 200 as city_id, 
kd_acc_tm
,lx_acc_nbr
,cust_name
,acc_nbr
,subst_name
,branch_name
,area_name
,serv_grp_type_desc
,case when is_cancel_user=1 then '是' when is_cancel_user=0 then '否' else null end is_cj
,case when is_rh_ykj=1 then '是' when is_rh_ykj=0 then '否' else null end is_rh
,case when speed_value>=1000 then '是' else '否' end is_qz
,speed_value
,open_date
,star_level_desc
from tmp_yz_liq_5;

drop table tmp_yz_liq_XQGZ2024071901176_2 purge;
create table tmp_yz_liq_XQGZ2024071901176_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select city_id, 
kd_acc_tm
,lx_acc_nbr
--,cust_name
,acc_nbr
,subst_name
,branch_name
,area_name
,serv_grp_type_desc
,is_cj
,is_rh
,is_qz
,speed_value
,open_date
,star_level_desc
from tmp_yz_liq_XQGZ2024071901176;

drop table tmp_yz_liq_XQGZ2024071901176_3 purge;
create table tmp_yz_liq_XQGZ2024071901176_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from tmp_yz_liq_XQGZ2024071901176_2;

drop table tmp_yz_liq_XQGZ2024071901176_1766 purge;
create table tmp_yz_liq_XQGZ2024071901176_1766 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select 200 as city_id, 
kd_acc_tm
,lx_acc_nbr
,cust_name
,acc_nbr
,subst_name
,branch_name
,area_name
,serv_grp_type_desc
,case when is_cancel_user=1 then '是' when is_cancel_user=0 then '否' else null end is_cj
,case when is_rh_ykj=1 then '是' when is_rh_ykj=0 then '否' else null end is_rh
,case when speed_value>=1000 then '是' else '否' end is_qz
,speed_value
,open_date
,star_level_desc
from tmp_yz_liq_5;

drop table tmp_yz_liq_XQGZ2024071901176_2 purge;
create table tmp_yz_liq_XQGZ2024071901176_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select city_id, 
kd_acc_tm
,lx_acc_nbr
--,cust_name
,acc_nbr
,subst_name
,branch_name
,area_name
,serv_grp_type_desc
,is_cj
,is_rh
,is_qz
,speed_value
,open_date
,star_level_desc
from tmp_yz_liq_XQGZ2024071901176_1766;

--XQGZ2024072401274 需求标题 邮储银行广州分行导出固话号码清单 
按order by create_date desc,status_cd desc  排序，取时间最晚的那一条
drop table tmp_yz_XQGZ2024072401274_1 purge;
create table tmp_yz_XQGZ2024072401274_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.eqpt_sn  --机身号
,a.prod_inst_id serv_id
,a.mkt_res_id  --设备id
,a.create_date
,a.status_cd
,c.mkt_res_name  --设备名称
from dws_crm_cust.dws_prod_res_inst_rel a --终端资料表   
join dwm_yz_tb_comm_cm_all_final b
on a.prod_inst_id=cast(b.serv_id as string) and b.par_month_id=202407 and b.prod_type=10 and b.is_cancel_user=0 
and b.cust_name=''  --限制需求单的客户名称
left join iodata_ods_day_szx.mkt_resource c on a.mkt_res_id=cast(c.mkt_res_id as string)
where a.status_cd<>1200 
union all 
select a.eqpt_sn
,a.prod_inst_id serv_id
,a.mkt_res_id  --设备id
,a.create_date
,a.status_cd
,c.mkt_res_name  --设备名称
from dws_crm_cust.dws_prod_res_inst_rel_his a --终端资料历史表
join dwm_yz_tb_comm_cm_all_final b
on a.prod_inst_id=cast(b.serv_id as string) and b.par_month_id=202407 and b.prod_type=10 and b.is_cancel_user=0 
and b.cust_name=''  --限制需求单的客户名称
left join iodata_ods_day_szx.mkt_resource c on a.mkt_res_id=cast(c.mkt_res_id as string)
where a.status_cd<>1200 ;

--排序，取 paixu=1的号码
drop table tmp_yz_XQGZ2024072401274_2 purge;
create table tmp_yz_XQGZ2024072401274_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select *,row_number() over(partition by serv_id order by create_date desc,status_cd desc) paixu  
from tmp_yz_XQGZ2024072401274_1;

--固话业务接入号、生成日期、装机地址、关联设备
drop table tmp_yz_XQGZ2024072401274_3 purge;
create table tmp_yz_XQGZ2024072401274_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.acc_nbr,a.open_date,a.serv_addr_id 
,b.mkt_res_name --设备名称
,b.eqpt_sn  --机身号
from dwm_yz_tb_comm_cm_all_final a 
left join tmp_yz_XQGZ2024072401274_2 b on cast(a.serv_id as string)=b.serv_id and b.paixu=1
where a.par_month_id=202407 and a.prod_type=10 and a.is_cancel_user=0 
and a.cust_name=''  --限制需求单的客户名称
;

--打标装机地址
drop table tmp_yz_XQGZ2024072401274_4 purge;
create table tmp_yz_XQGZ2024072401274_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as

--XQGZ2024072900469 需求标题 关于商客战新客户匹配归属县分的请示 
量子密话的清单已经插入到表里面了，select * from ads_yz_XQGZ2024072900469_list where yw_lx='LZMH'
直连卫星已经插入到表里，select * from ads_yz_XQGZ2024072900469_list where yw_lx='zlwx';
select * from ads_yz_XQGZ2024072900469_list where yw_lx in ('YDN','ACDN','YZJ');
select * from ads_yz_XQGZ2024072900469_list where yw_lx in ('TYKJ','TYYY','ZWZX'); 已经插好了

drop table tmp_yz_XQGZ2024072900469 purge;
create table tmp_yz_XQGZ2024072900469 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct 200 as city_id,dim_id,cust_nbr,cust_first_hy,six_market
,six_market_202405,dim_subst_name,acount_nbr_lx,is_zw
,is_tj,is_qf,yw_staff_name,lz_channel_nbr,lz_channel_name
,channel_subst_name
,case when yw_lx='LZMH' then '量子密信' when yw_lx='zlwx' then '直连卫星' 
	when yw_lx in ('YDN') then '云电脑' when yw_lx in ('ACDN') then '安全大脑'
	when yw_lx in ('YZJ') then '云主机' when yw_lx in ('TYKJ') then '天翼看家'
	when yw_lx in ('TYYY') then '天翼云眼' when yw_lx in ('ZWZX') then '组网专线' 
	when yw_lx in ('HLWZX') then '互联网专线' else null end as yw_leixing 
from ads_yz_XQGZ2024072900469_list;

--XQGZ2024080201317 需求标题 关于新增视联网揽装入网清单日报需求 
揽装局向，天翼看家月新增，天翼云眼月新增，平安慧眼月新增，叠加AI月新增，其中看家AI月新增，其中云眼AI月新增，其中慧眼AI月新增

drop table tmp_yz_XQGZ2024080201317_list purge;
create table tmp_yz_XQGZ2024080201317_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.channel_subst_name,b.channel_branch_name from 
left join (select par_month_id,serv_id,channel_subst_name,channel_branch_name
	           from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202401) b
	           on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id;

drop table tmp_yz_XQGZ2024080201317_bao purge;
create table tmp_yz_XQGZ2024080201317_bao
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select par_month_id,channel_subst_name,channel_branch_name,
	count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and prod_id in (500005461,500005463,600019000) then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and attr_value like('%AI%') then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYKJ-AI-202211' then msinfo_id else null end) value1, --天翼看家日新增
	count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and prod_id in (500005461,500005463,600019000) then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and attr_value like('%AI%') then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYKJ-AI-202211' then msinfo_id else null end) value2, --天翼看家月新增 
	count(distinct case when action_type='tykj_dd' and prod_id in (500005461,500005463,600019000) then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and attr_value like('%AI%') then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and offer_label='TYKJ-AI-202211' then msinfo_id else null end) value3, --天翼看家到达
	count(distinct case when action_type='kd_new' and is_same_cust=1 then serv_id else null end) value4, --当月看家拉动新增宽带数
	count(distinct case when action_type='kd_new' and is_same_cust=1 and is_zlkd=1 then serv_id else null end) value5, --当月看家拉动新增主宽数
	count(distinct case when action_type='tyyy_dd' and offer_code not in ('ZH0003-432-1-2') and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} then msinfo_id else null end) 
	  - count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYYY-SPHJJM-202211' then msinfo_id else null end) value6, --天翼云眼日新增
	count(distinct case when action_type='tyyy_dd' and offer_code not in ('ZH0003-432-1-2') and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} then msinfo_id else null end) 
	  - count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYYY-SPHJJM-202211' then msinfo_id else null end) value7, --天翼云眼月新增
	count(distinct case when action_type='tyyy_dd' and offer_code not in ('ZH0003-432-1-2') then msinfo_id else null end) 
	  - count(distinct case when action_type='tyyy_dd' and offer_label='TYYY-SPHJJM-202211' then msinfo_id else null end) value8, --天翼云眼到达
	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} then msinfo_id else null end) value9, --平安慧眼日新增
	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} then msinfo_id else null end) value10, --平安慧眼月新增
	count(distinct case when action_type='pahy_dd' then msinfo_id else null end) value11, --平安慧眼到达
	count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and attr_value like('%AI%') then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYKJ-AI-202211' then msinfo_id else null end) value12, --天翼看家AI日新增
	count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYYY-AI-202211' then msinfo_id else null end) value13, --天翼云眼AI日新增
	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='PAHY-AI-202211' then msinfo_id else null end) value14, --平安慧眼AI日新增
	count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date}  and attr_value like('%AI%') then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYKJ-AI-202211' then msinfo_id else null end) value15, --天翼看家AI月新增
	count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYYY-AI-202211' then msinfo_id else null end) value16, --天翼云眼AI月新增
	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='PAHY-AI-202211' then msinfo_id else null end) value17, --平安慧眼AI月新增
	count(distinct case when action_type='tykj_dd' and attr_value like('%AI%') then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and offer_label='TYKJ-AI-202211' then msinfo_id else null end) value18, --天翼看家AI月到达
	count(distinct case when action_type='tyyy_dd' and offer_label='TYYY-AI-202211' then msinfo_id else null end) value19, --天翼云眼AI月到达
	count(distinct case when action_type='pahy_dd' and  offer_label='PAHY-AI-202211' then msinfo_id else null end) value20, --平安慧眼AI月到达
	count(distinct case when action_type='kd_new' and is_zlkd=1 then serv_id else null end) value21, --主宽入网数
	 + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYKJ-AI-202211' and is_ljsp='是' then msinfo_id else null end) value22, --临街商铺天翼看家日新增
	count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and prod_id in (500005461,500005463,600019000) and is_ljsp='是' then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and attr_value like('%AI%') and is_ljsp='是' then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYKJ-AI-202211' and is_ljsp='是' then msinfo_id else null end) value23, --临街商铺天翼看家月新增 
	count(distinct case when action_type='tykj_dd' and prod_id in (500005461,500005463,600019000) and is_ljsp='是' then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and attr_value like('%AI%') and is_ljsp='是' then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and offer_label='TYKJ-AI-202211' and is_ljsp='是' then msinfo_id else null end) value24, --临街商铺天翼看家到达
	  	count(distinct case when action_type='tyyy_dd' and offer_code not in ('ZH0003-432-1-2') and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and is_ljsp='是' then msinfo_id else null end) 
	  - count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYYY-SPHJJM-202211' and is_ljsp='是' then msinfo_id else null end) value25, --临街商铺天翼云眼日新增
	count(distinct case when action_type='tyyy_dd' and offer_code not in ('ZH0003-432-1-2') and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and is_ljsp='是' then msinfo_id else null end) 
	  - count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYYY-SPHJJM-202211' and is_ljsp='是' then msinfo_id else null end) value26, --临街商铺天翼云眼月新增
	count(distinct case when action_type='tyyy_dd' and offer_code not in ('ZH0003-432-1-2') and is_ljsp='是'  then msinfo_id else null end) 
	  - count(distinct case when action_type='tyyy_dd' and offer_label='TYYY-SPHJJM-202211' and is_ljsp='是' then msinfo_id else null end) value27, --临街商铺天翼云眼到达
	  	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and is_ljsp='是' then msinfo_id else null end) value28, --临街商铺平安慧眼日新增
	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and is_ljsp='是' then msinfo_id else null end) value29, --临街商铺平安慧眼月新增
	count(distinct case when action_type='pahy_dd' and is_ljsp='是' then msinfo_id else null end) value30, --临街商铺平安慧眼到达
	count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and attr_value like('%AI%') and is_ljsp='是' then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYKJ-AI-202211' and is_ljsp='是' then msinfo_id else null end) value31, --临街商铺天翼看家AI日新增
	count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='TYYY-AI-202211' and is_ljsp='是' then msinfo_id else null end) value32, --临街商铺天翼云眼AI日新增
	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd')=${stat_date} and offer_label='PAHY-AI-202211' and is_ljsp='是' then msinfo_id else null end) value33, --临街商铺平安慧眼AI日新增
	count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and attr_value like('%AI%') and is_ljsp='是' then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYKJ-AI-202211' and is_ljsp='是' then msinfo_id else null end) value34, --临街商铺天翼看家AI月新增
	count(distinct case when action_type='tyyy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='TYYY-AI-202211' and is_ljsp='是' then msinfo_id else null end) value35, --临街商铺天翼云眼AI月新增
	count(distinct case when action_type='pahy_dd' and date_format(subs_stat_date,'yyyyMMdd') between ${this_month_first_date} and ${stat_date} and offer_label='PAHY-AI-202211' and is_ljsp='是' then msinfo_id else null end) value36, --临街商铺平安慧眼AI月新增
	count(distinct case when action_type='tykj_dd' and attr_value like('%AI%') and is_ljsp='是' then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and offer_label='TYKJ-AI-202211' and is_ljsp='是' then msinfo_id else null end) value37, --临街商铺天翼看家AI到达月新增
	count(distinct case when action_type='tyyy_dd' and offer_label='TYYY-AI-202211' and is_ljsp='是' then msinfo_id else null end) value38, --临街商铺天翼云眼AI到达月新增
	count(distinct case when action_type='pahy_dd' and  offer_label='PAHY-AI-202211' and is_ljsp='是' then msinfo_id else null end) value39 --临街商铺平安慧眼AI到达月新增
	from tmp_yz_XQGZ2024080201317_list
	where par_month_id>=202401
	group by par_month_id,channel_subst_name,channel_branch_name;


drop table tmp_yz_XQGZ2024080201317_subst_bao purge;
create table tmp_yz_XQGZ2024080201317_subst_bao
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select  par_month_id,channel_subst_name
,sum(value2)  --天翼看家月新增  
,sum(value7)  --天翼云眼月新增
,sum(value10) --平安慧眼月新增
,sum(value15)+sum(value16) +sum(value17) --AI月新增
,sum(value15) --天翼看家AI月新增
,sum(value16) --天翼云眼AI月新增
,sum(value17) --平安慧眼AI月新增
from  tmp_yz_XQGZ2024080201317_bao 
group by par_month_id,channel_subst_name;

--20240809  电渠
--6月融合宽带入网（户）（主流宽带，包含新宽老移、新宽新移）
SELECT channel_nbr, channel_id
, count(DISTINCT serv_id) AS rw_nums 
FROM dwm_yz_tb_comm_cm_all_final 
WHERE prod_type = 40 
AND is_rh_ykj = 1 
AND kd_desc = '普通宽带' 
and coalesce(prod_type3,'-1')<>'副宽'
AND is_new_user = 1 
AND is_cancel_user = 0 
AND par_month_id = 202406 -- 修改月份 
AND channel_nbr IN ( '4401002055631', '4401122754553', '4401122191278', '4401002444075', '4401002321426'
, '4401002517790', '4401122097995', '4401002119840', '4401002995891', '4401002997903' ) 
GROUP BY channel_nbr, channel_id 
LIMIT 1000

--6月单宽入网（户）（主流宽带）
SELECT channel_nbr, channel_id
, count(DISTINCT serv_id) AS rw_nums 
FROM dwm_yz_tb_comm_cm_all_final 
WHERE prod_type = 40 
AND is_rh_ykj = 0 
AND kd_desc = '普通宽带' 
and coalesce(prod_type3,'-1')<>'副宽'
AND is_new_user = 1 
AND is_cancel_user = 0 
AND par_month_id = 202406 -- 修改月份 
AND channel_nbr IN ( '4401002055631', '4401122754553', '4401122191278', '4401002444075', '4401002321426'
, '4401002517790', '4401122097995', '4401002119840', '4401002995891', '4401002997903' ) 
GROUP BY channel_nbr, channel_id 
LIMIT 1000

--XQGZ2024071501268 需求标题 关于绿名单号码欠费的查询  
业务号码	产权客编	"号码目前状态（是否拆机、停机、在用等）"	
如目前已拆机，拆机时间	
如目前已停机，停机时间	
号码目前用户名称与绿名单欠费账期的客户名称是否一致	
2024年1-7月是否有使用记录	
2024年1-7月通话分钟数	
2024年1-7月流量	
2024年1-7月短信数	
2024年1-7月彩信数

drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.acc_nbr
,a.cust_nbr 
,b.cust_nbr as cust_nbr_dq
,b.state
,case when b.serv_id is not null then 0 else 1 end is_cj
,b.stop_date
,b.prod_type
,b.prod_type2
from (select distinct acc_nbr,cust_nbr from ads_XQGZ2024071501268) a --营收提取的欠费号码
left join dwm_yz_tb_comm_cm_all_final b on a.acc_nbr=b.acc_nbr and b.par_month_id=202408 and b.is_cancel_user=0;

drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.* 
,case when a.is_cj=1 then '拆机' else b.attr_value_name end as state_desc
from tmp_yz_liq_1 a 
left join dws_crm_cfguse.dws_attr_value b on a.state=b.attr_value and b.city_id='200' and b.attr_id='4000000201';

use zone_gz_yz;
set hive.exec.parallel=true; -- 不同job可以并发执行
set hive.exec.parallel.thread.number=32;
set hive.vectorized.execution.enabled=false;  --  关闭向量化查询
set hive.vectorized.execution.reduce.enabled=false; --  关闭向量化查询
set hive.groupby.skewindata=false;
drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select distinct a.acc_nbr,a.hist_create_date 
from dwm_yz_tb_comm_cm_all_mon_final a
where is_cancel_user=1 
and acc_nbr in(select distinct acc_nbr from tmp_yz_liq_2 where is_cj=1) 
union all 
select distinct a.acc_nbr,a.hist_create_date 
from dwm_yz_tb_comm_cm_all_final a
where is_cancel_user=1 
and acc_nbr in(select distinct acc_nbr from tmp_yz_liq_2 where is_cj=1) 
and par_month_id=202408;

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.hist_create_date 
from tmp_yz_liq_2 a 
left join (select *,row_number() over(partition by acc_nbr order by hist_create_date desc) as paixu from tmp_yz_liq_3) b 
on a.acc_nbr=b.acc_nbr and b.paixu=1;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,case when coalesce(cust_nbr,'-1')<>coalesce(cust_nbr_dq,'-1') then '否' else '是' end as is_same_cust 
from tmp_yz_liq_4 a ; 

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select acc_nbr,sum(mou_call) mou_call_sum
,sum(stm_data) stm_data_sum
,sum(mgs_counts) mgs_counts_sum
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202401 and par_month_id<=202407 and is_cancel_user=0 
group by acc_nbr
union all 
select acc_nbr,sum(mou_call) mou_call_sum
,sum(stm_data) stm_data_sum
,sum(mgs_counts) mgs_counts_sum
from dwm_yz_tb_comm_cm_all_final where par_month_id=202408  and is_cancel_user=0 
group by acc_nbr;

drop table tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,b.mou_call
,b.stm_data
,b.mgs_counts 

,0 as kd_ll_sum
,0 as kd_sc_sum

,0 as gw_sc_sum 
from tmp_yz_liq_5 a 
left join (select acc_nbr,sum(mou_call_sum) mou_call,sum(stm_data_sum) stm_data,sum(mgs_counts_sum) mgs_counts from tmp_yz_liq_6 group by acc_nbr) b 
on a.acc_nbr=b.acc_nbr 
where a.prod_type=30;

drop table tmp_yz_liq_8_1 purge;
create table tmp_yz_liq_8_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select acc_nbr,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll, --宽带流量 单位M
cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon 
where par_corp_id=200 and par_month_id>=202401 and par_month_id<=202408;

drop table tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,0 as mou_call
,0 as stm_data
,0 as mgs_counts

,b.kd_ll_sum
,b.kd_sc_sum

,0 as gw_sc_sum 
from tmp_yz_liq_5 a 
left join (select acc_nbr,sum(kd_ll) kd_ll_sum,sum(kd_sc) kd_sc_sum from tmp_yz_liq_8_1 group by acc_nbr) b
on a.acc_nbr=b.acc_nbr 
where a.prod_type=40;

drop table tmp_yz_liq_9_1 purge;
create table tmp_yz_liq_9_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select acc_nbr,
cast(DUR/60 as decimal(22,2)) gw_sc  --固网通话时长 单位分
from summary_ods_month_city.TB_COMM_YWL_GW_mon where par_corp_id=200 and par_month_id>=202401 and par_month_id<=202408
;

drop table tmp_yz_liq_9 purge;
create table tmp_yz_liq_9
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,0 as mou_call
,0 as stm_data
,0 as mgs_counts

,0 as kd_ll_sum
,0 as kd_sc_sum

,b.gw_sc_sum 
from tmp_yz_liq_5 a 
left join (select acc_nbr,sum(gw_sc) gw_sc_sum from tmp_yz_liq_9_1 group by acc_nbr) b
on a.acc_nbr=b.acc_nbr 
where coalesce(a.prod_type,-1) not in(30,40);

drop table tmp_yz_liq_10 purge;
create table tmp_yz_liq_10
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select * from tmp_yz_liq_7 
union all 
select * from tmp_yz_liq_8 
union all
select * from tmp_yz_liq_9 ;

drop table tmp_yz_liq_11 purge;
create table tmp_yz_liq_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case when a.prod_type=30 then '移动' when prod_type=40 and coalesce(prod_type2,-1)<>50 then '宽带' 
when prod_type=10 then '固话' when prod_type2=50 then 'itv' else '其他' end as prod_type_desc 
from tmp_yz_liq_10 a;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_liq_12 purge;
create table tmp_yz_liq_12
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select acc_nbr,
sum( coalesce(cast(boot_times as decimal),0) ) login_times_m --本月开机次数
from zone_tygqmid.dws_login_list
where day>='20240101' and day<='20240813' and area_name='广州'
group by acc_nbr

union all 
select acc_nbr,
sum( coalesce(cast(boot_times as decimal),0) ) login_times_m --本月开机次数
from zone_gz_yz.dws_login_list_final 
where day>='20240101' and day<='20240813' and area_name='广州'
group by acc_nbr;

drop table tmp_yz_liq_13 purge;
create table tmp_yz_liq_13
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.* 
,case when b.acc_nbr is not null then 1 else 0 end as is_itv_hy 
from tmp_yz_liq_11 a 
left join (select distinct acc_nbr from tmp_yz_liq_12 where login_times_m>=1) b on a.acc_nbr=b.acc_nbr;

drop table tmp_yz_liq_14 purge;
create table tmp_yz_liq_14
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
case when prod_type_desc='移动' and coalesce(mou_call,0)+coalesce(stm_data,0)+coalesce(mgs_counts,0)>0 then '是' 
when prod_type_desc='宽带' and coalesce(kd_ll_sum,0)+coalesce(kd_sc_sum,0)>0 then '是' 
when prod_type_desc='固话' and coalesce(gw_sc_sum,0)>0 then '是' 
when prod_type_desc='itv' and is_itv_hy>0 then '是' 
else '否' end as is_shiyong
from tmp_yz_liq_13 a ;


--20240822 张晓明  铜改光
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 0 then serv_id else null end ) as value5,   --铜线接入
count(distinct case when kd_desc in ('普通宽带') and is_dial_fiber = 1 then serv_id else null end) as value6,    --光纤接入

--宽带是否铜改光
select 
a.acc_nbr
,a.serv_id
,case when b.is_dial_fiber=0 then '是' when b.is_dial_fiber=1 then '否' else null end as is_tong_sy --上月是否铜线接入  
from view_ads_yz_tb_comm_cm_all_final a 
left join (select serv_id,is_dial_fiber from view_ads_yz_tb_comm_cm_all_final where par_month_id=202407 and prod_type=40) b on a.serv_id=b.serv_id 
where a.par_month_id=202408 
and a.is_cancel_user=0 
and a.prod_type=40 
and a.kd_desc='普通宽带' 
and a.is_dial_fiber=1 --光纤接入
and a.is_new_user=0  --非当月新装

--20240826  XQGZ2024081901759 需求标题 关于天河落地固网业务量级统计的需求申请  
1，落地天河网格的固话，宽带，ITV，天翼看家，极速专线，智能组网在网用户数。
2，落地天河网格的智能组网有出设备的数量
3，落地天河网格200电话卡固话数（以前本地清单光纤固话全量清单中，用户类型=200专用电话用户，
或月租类型=插卡式200电话(PSTN)、普通(PSTN)、校园卡、200专用电话(CENT)、校园卡、200专用电话(PSTN)）

drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 as 
select cell_code,cell_name
,serv_id,prod_id,prod_type,prod_type2,user_type,billing_type 
from dwm_yz_tb_comm_cm_all_final a 
where a.par_month_id=202409 and a.is_cancel_user=0 
and (a.prod_type in(10,40) or prod_type2 in(50) or prod_id in(48))
and a.std_subst_id=4050 
;

drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 as 
select a.* 
,b.attr_value_name as user_type_desc --用户类型
,c.attr_value_name as billing_type_name --租费类型 
from tmp_yz_liq_1 a 
left join dws_crm_cfguse.dws_attr_value b on a.user_type = b.attr_inner_value and b.city_id='200' and b.attr_id =94 
left join dws_crm_cfguse.dws_attr_value c on a.billing_type = c.attr_inner_value and c.city_id='200' and c.attr_id =95 
;

drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 as 
select cell_code,cell_name 
,count(case when prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end ) as kd 
,count(case when prod_type=10 then serv_id else null end ) as gh 
,count(case when prod_type2=50 then serv_id else null end ) as itv 
,count(case when prod_id=48 then serv_id else null end ) as js_zx 
,count(case when prod_type=10 and (user_type_desc='200专用电话用户' 
	or billing_type_name in('插卡式200电话(PSTN)','普通(PSTN)','校园卡、200专用电话(CENT)','校园卡、200专用电话(PSTN)') )
	then serv_id else null end ) as gh_200zy 
from tmp_yz_liq_2 
group by cell_code,cell_name;

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 as 
select cell_code,cell_name 
	,count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between '20240901' and '20240931' and prod_id in (500005461,500005463,600019000) then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between '20240901' and '20240931' and attr_value like('%AI%') then serv_id else null end)
	  + count(distinct case when action_type='tykj_dd' and date_format(subs_stat_date,'yyyyMMdd') between '20240901' and '20240931' and offer_label='TYKJ-AI-202211' then msinfo_id else null end) tykj  --天翼看家月新增 

from ads_yz_slw_136_list
	where par_month_id=202409 and std_subst_id=4050
	group by cell_code,cell_name;
	
drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 as 
select cell_code,cell_name 
,kd,gh,itv,js_zx,gh_200zy 
,0 as tykj 
from tmp_yz_liq_3 
union all 
select cell_code,cell_name 
,0 as kd,0 as gh,0 as itv,0 as js_zx,0 as gh_200zy 
,tykj 
from tmp_yz_liq_4 ;

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 as 
select cell_code,cell_name 
,sum(kd) as kd_num --宽带
,sum(gh) as gh_num --固话
,sum(itv) as itv_num --itv
,sum(js_zx) as js_zx_num --极速专线
,sum(gh_200zy) as gh_200zy_num --200电话卡固话数
,sum(tykj) as tykj_num --天翼看家
from tmp_yz_liq_5 
group by cell_code,cell_name ;

drop table tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 as 
select *,row_number() over(order by cell_code) as paixu from tmp_yz_liq_6;




--20240827  XQGZ2024081600109 需求标题 非名单制客户信息提取需求  
公司名	产权客户编码	产权客户名	产权建档时间	
--建档局向	
直销编码	直销客户名	直销建档时间	客户类型	局向	营服中心	
24年1-7月累计收入	落地业务最大收入局向	揽装业务收入最大局向
dws_crm_cust.dws_customer  打标产权信息
然后通过 dws_yz_tb_mo_custgrp_cust_final 去打标 ccust_id
直销信息 select ccust_id,ccust_code,ccust_name,create_date,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200

drop table tmp_yz_liq_XQGZ2024081600109_1 purge;
create table tmp_yz_liq_XQGZ2024081600109_1 as 
select cust_number,cust_name,create_date
,row_number() over(partition by cust_number,cust_name order by create_date desc) paixu 
from dws_crm_cust.dws_customer where city_id=200;

drop table tmp_yz_liq_XQGZ2024081600109_2 purge;
create table tmp_yz_liq_XQGZ2024081600109_2 as 
select a.index1 as gs_name 
,b.cust_number,b.cust_name,b.create_date 
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_liq_XQGZ2024081600109_1 b on a.index1=b.cust_name and b.paixu=1
;

drop table tmp_yz_liq_XQGZ2024081600109_3 purge;
create table tmp_yz_liq_XQGZ2024081600109_3 as 
select a.* 
,b.ccust_id
from tmp_yz_liq_XQGZ2024081600109_2 a 
left join (select distinct cust_nbr,ccust_id from dws_yz_tb_mo_custgrp_cust_final) b on a.cust_number=b.cust_nbr 
;

drop table tmp_yz_liq_XQGZ2024081600109_4 purge;
create table tmp_yz_liq_XQGZ2024081600109_4 as 
select a.* 
,b.ccust_code,b.ccust_name,b.create_date as ccust_create_date,b.vip_flag,b.branch_org,b.manage_org
from tmp_yz_liq_XQGZ2024081600109_3 a 
left join (select ccust_id,ccust_code,ccust_name,create_date,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;

drop table tmp_yz_liq_XQGZ2024081600109_5 purge;
create table tmp_yz_liq_XQGZ2024081600109_5 as 
select a.* 
,b.attr_value_name as cust_lx 
from tmp_yz_liq_XQGZ2024081600109_4 a 
left join (select attr_id,attr_inner_value,attr_value_name,attr_value_sort  from  dws_crm_cfguse.dws_attr_value where city_id=200
and attr_id='400003971') b on a.vip_flag=b.attr_inner_value
;

drop table tmp_yz_liq_XQGZ2024081600109_6 purge;
create table tmp_yz_liq_XQGZ2024081600109_6 as 
select a.* 
,b.org_name as ccust_subst_name 
,c.org_name as ccust_branch_name
from tmp_yz_liq_XQGZ2024081600109_5 a 
left join (select * from  dwd_yz_dim_org where levs='3') b
on a.branch_org=b.org_id
left join (select * from  dwd_yz_dim_org where levs='4') c
on a.manage_org=c.org_id;

--落地业务最大收入局向
drop table tmp_yz_liq_XQGZ2024081600109_7 purge;
create table tmp_yz_liq_XQGZ2024081600109_7 as 
select cust_nbr,std_subst_name  
,sum(fee_new_tax) as sr_sh 
from dwm_yz_tb_comm_cm_all_mon_final a 
where par_month_id>=202401 and par_month_id<=202407 
group by cust_nbr,std_subst_name;

--揽装业务收入最大局向
drop table tmp_yz_liq_XQGZ2024081600109_8 purge;
create table tmp_yz_liq_XQGZ2024081600109_8 as 
select cust_nbr,channel_subst_name 
,sum(fee_new_tax) as sr_sh 
from dwm_yz_tb_comm_cm_all_mon_final a 
where par_month_id>=202401 and par_month_id<=202407 
group by cust_nbr,channel_subst_name;

--落地业务最大收入局向
drop table tmp_yz_liq_XQGZ2024081600109_9 purge;
create table tmp_yz_liq_XQGZ2024081600109_9 as 
select a.* 
,row_number() over(partition by cust_nbr order by sr_sh desc) as paixu 
from tmp_yz_liq_XQGZ2024081600109_7 a;

--揽装业务收入最大局向
drop table tmp_yz_liq_XQGZ2024081600109_10 purge;
create table tmp_yz_liq_XQGZ2024081600109_10 as 
select a.* 
,row_number() over(partition by cust_nbr order by sr_sh desc) as paixu 
from tmp_yz_liq_XQGZ2024081600109_8 a;

--24年1-7月累计收入
drop table tmp_yz_liq_XQGZ2024081600109_11 purge;
create table tmp_yz_liq_XQGZ2024081600109_11 as 
select a.*,b.sr
from tmp_yz_liq_XQGZ2024081600109_6 a 
left join (select cust_nbr,sum(sr_sh) sr from tmp_yz_liq_XQGZ2024081600109_8 group by cust_nbr) b on a.cust_number=b.cust_nbr
;

--落地业务最大收入局向\揽装业务收入最大局向
drop table tmp_yz_liq_XQGZ2024081600109_12 purge;
create table tmp_yz_liq_XQGZ2024081600109_12 as 
select a.*,b.std_subst_name,c.channel_subst_name 
from tmp_yz_liq_XQGZ2024081600109_11 a 
left join (select * from tmp_yz_liq_XQGZ2024081600109_9 where paixu=1) b on a.cust_number=b.cust_nbr 
left join (select * from tmp_yz_liq_XQGZ2024081600109_10 where paixu=1) c on a.cust_number=c.cust_nbr
;

drop table tmp_yz_liq_XQGZ2024081600109_13 purge;
create table tmp_yz_liq_XQGZ2024081600109_13 as 
select *,row_number() over(order by gs_name) as xh_id
from tmp_yz_liq_XQGZ2024081600109_12 where cust_number is not null;


--20240829  张晓明  用宽带新装清单当月新入网的宽带当月办理了这两个销售品
DM0001-668-1-11，固网宽带100M单产品套餐（100元/月）
DM0001-751-1-2，宽带预存包期优惠_800元_12个月
500047226 DM0001-668-1-11
500050200 DM0001-751-1-2

select 
count(distinct a.serv_id) as kd_rw
from view_ads_yz_kd_new_list a 
join (select serv_id,count(distinct prod_offer_id) offer_num from view_ads_yz_rpt_comm_cm_msdisc_final 
	  where par_month_id=202408 and prod_offer_id in(500047226,500050200) group by serv_id) b 
on a.serv_id=b.serv_id and b.offer_num=2
where a.par_month_id=202408 


--20240909 刘丽娜  
23年8月宽带新装清单
，取融合套餐价值积分≥129的那部分号码
，匹配号码所做的合约档次
，合约手续费a，价值积分b
，然后增加一个字段：还原后的价值积分b-a
我就是要这个b-a，需要到县分和细分市场维度

--20231013  刘丽娜  129+9月净增凑数，因省积分9月调整金融合约积分配置
-- 套餐内取 create_date 最大的一条
/* drop table if exists zone_gz_yz.tmp_liq_jrhy_xsp purge;
create table zone_gz_yz.tmp_liq_jrhy_xsp
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.offer_id 
from zone_gz_yz_3351225714708480 a 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200) b on a.index2=b.prod_offer_code;
		
 */

drop table if exists zone_gz_yz.tmp_liq_1013_1 purge;
create table zone_gz_yz.tmp_liq_1013_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_bd129_sdjd_list where par_month_id in(202308);

drop table if exists zone_gz_yz.tmp_liq_1013_2_1 purge;
create table zone_gz_yz.tmp_liq_1013_2_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.serv_id,a.create_date,a.prod_offer_id,
row_number() over(partition by serv_id order by prod_offer_id,create_date desc) as order_id,
row_number() over(partition by serv_id,prod_offer_id order by create_date desc) as order_id2,
b.index4 as jf_change
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_mon_final a 
join tmp_liq_jrhy_xsp b on a.prod_offer_id=b.offer_id 
where a.par_month_id=202308 
and date_format(a.limit_date,'yyyyMM') >='202309' and a.prod_id in(3204,3205);


drop table if exists zone_gz_yz.tmp_liq_1013_2 purge;
create table zone_gz_yz.tmp_liq_1013_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
case when b.serv_id is not null then 1 else 0 end is_hy,
case when b.serv_id is not null then b.create_date else null end hy_create_date,
case when b.serv_id is not null then b.prod_offer_id else null end hy_prod_offer_id
from tmp_liq_1013_1 a 
left join tmp_liq_1013_2_1 b on a.serv_id=b.serv_id and b.order_id=1
;


drop table if exists zone_gz_yz.tmp_liq_1013_3 purge;
create table zone_gz_yz.tmp_liq_1013_3
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
case when b.is_tc_hy>0 then 1 else 0 end is_hy_tc
from tmp_liq_1013_2 a 
left join (select par_month_id,rh_tc_id,sum(is_hy) is_tc_hy from tmp_liq_1013_2 group by par_month_id,rh_tc_id ) b 
on a.rh_tc_id=b.rh_tc_id and a.par_month_id=b.par_month_id;


drop table if exists zone_gz_yz.tmp_liq_1013_5 purge;
create table zone_gz_yz.tmp_liq_1013_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select rh_tc_id,hy_prod_offer_id,
row_number() over(partition by rh_tc_id order by hy_create_date desc) as paixu 
from tmp_liq_1013_3 where is_hy=1;

drop table if exists zone_gz_yz.tmp_liq_1013_6 purge;
create table zone_gz_yz.tmp_liq_1013_6
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.hy_prod_offer_id as prod_offer_id_hy
from tmp_liq_1013_3 a 
left join (select * from tmp_liq_1013_5 where paixu=1) b 
on a.rh_tc_id=b.rh_tc_id;


drop table if exists zone_gz_yz.tmp_liq_1013_8 purge;
create table zone_gz_yz.tmp_liq_1013_8
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.tzjf as jf_change
from tmp_liq_1013_6 a 
left join (select serv_id,sum(jf_change) tzjf from tmp_liq_1013_2_1 where order_id2=1 group by serv_id) b on a.serv_id=b.serv_id 
;

drop table if exists zone_gz_yz.tmp_liq_1013_9 purge;
create table zone_gz_yz.tmp_liq_1013_9
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.tzjf
from tmp_liq_1013_8 a 
left join (select par_month_id,rh_tc_id,sum(jf_change) tzjf from tmp_liq_1013_8 group by par_month_id,rh_tc_id) b 
on a.rh_tc_id=b.rh_tc_id  and a.par_month_id=b.par_month_id
;

drop table if exists zone_gz_yz.tmp_yz_buda_jrhy_202308 purge;
create table zone_gz_yz.tmp_yz_buda_jrhy_202308
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.tzjf from ads_yz_kd_new_list a 
left join tmp_liq_1013_9 b on a.serv_id=b.serv_id 
where a.par_month_id=202308;




view_129_month9_bd: select * from zone_gz_yz.tmp_liq_1013_10 
--这个是补上合约那部分后的
select subst_name,--局向
count（distinct rh_tc_id） --129套餐数
from view_129_month9_bd
where tc_points+coalesce(tzjf,0)>=129 
and rh_rule in(10,20) --剔除客户级松散融合
group by subst_name order by subst_name

--字段
select rh_tc_id,--套餐ID
tc_points,--9月套餐积分
tc_points_sy,--8月套餐积分
subst_name,--局向
branch_name,--营服
area_name,--包区
tc_points_cy,--实际降档积分
is_hy_tc,--是否合约
tzjf,--积分扣减值
is_gt_20 --实际降档积分是否小于等于20，1是，0否

--XQGZ2024090601275  需求标题  关于岭南新世界对应分光器下挂的号码数量以及月收入查询的需求
drop table tmp_yz_liq_11 purge;
create table tmp_yz_liq_11 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select cast(prod_inst_id as decimal(22,0)) as serv_id  --号码
,obd_code as CROSS_CODE --分光器
,update_date
from dws_crm_cust.dws_cust_serv_res --当前月
where city_id='200' 
;

drop table tmp_yz_liq_12 purge;
create table tmp_yz_liq_12 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,
row_number() over(partition by a.serv_id order by a.update_date desc) as paixu 
from tmp_yz_liq_11 a 
join zone_gz_yz_3351225714708480 b on a.CROSS_CODE=b.index1;

drop table tmp_yz_liq_13 purge;
create table tmp_yz_liq_13 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.sh_qr 
from tmp_yz_liq_12 a 
left join (select serv_id,sum(a0) as sh_qr  --税后确认收入
from dwm_srhx_serv_list_mon_final where par_month_id = 202408 group by serv_id) b 
on a.serv_id=b.serv_id 
where a.paixu=1;

drop table tmp_yz_liq_14 purge;
create table tmp_yz_liq_14 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select CROSS_CODE,count(distinct serv_id) as NUM,sum(sh_qr) as sr 
from tmp_yz_liq_13 group by CROSS_CODE;


--20240910  备份宽带续约的备份表 ads_yz_kd_xy_list_new 
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table ads_yz_kd_xy_list_new_20240910 purge;
create table ads_yz_kd_xy_list_new_20240910 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select * from ads_yz_kd_xy_list_new;

alter table ads_yz_kd_xy_list_have_jk rename to ads_yz_kd_xy_list_have_jk_20240910;

alter table ads_yz_kd_xy_list_new rename to ads_yz_kd_xy_list_have_jk;


ads_yz_kd_xy_list_have_jk
ads_yz_kd_xy_list
ads_yz_kd_xy_list_new

--XQGZ2024091001882 需求标题 关于视联网已拆机需解绑客户清单提取的需求  陈冠文
select uid,city_code,phone_id 
from LDAPD_SMART_DEVICE_HOME_BIND   --字典表看CDAP-数据资产
where day_id="20240905" and  resourcePool =1 and phone_id !="-"

1）resourcePool =1，代表目标设备，视联公司9月5日通过该字段下发；
2）phone_id !="-"，代表当前在绑；
3）LDAPD_SMART_DEVICE_HOME_BIND 为天翼看家绑定摄像头的全量属性数据表，字段解释可通过字典查询
附：天翼看家、云眼入湖表字典表（最新）https://docs.qq.com/sheet/DWFViUmhlRkRaV0tH?tab=1vf132

--设备码、是否近6个月内在线、是否近3个月内在线、电信移动接入号、联系号码
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.accnum  --接入号
,a.kuandai  --宽带账号
,a.uid  --设备码
,a.city_code  --地市编码
,a.phone_id  --绑定手机号 
,case when cast(SUBSTR(b.newest_up_time,1,8) as decimal(10,0))>20240326 then '是' else '否' end is_zx_6 
,case when cast(SUBSTR(b.newest_up_time,1,8) as decimal(10,0))>20240626 then '是' else '否' end is_zx_3 
from dws_ctg.dws_ldapd_smart_device_home_bind  a 
left join dws_ctg.dws_ldapd_smart_21cn_device_info b on a.uid=b.dev_uid and b.yyyymmdd='20240926'
where a.yyyymmdd='20240926' 
and  a.resourcePool =1 
and a.phone_id !='-'
and a.city_code='84401'
and a.accnum='NULL';

drop table ads_yz_XQGZ2024091001882 purge;
create table ads_yz_XQGZ2024091001882 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as select * from tmp_yz_liq_1;

drop view view_yz_XQGZ2024091001882;
create view view_yz_XQGZ2024091001882 as 
select 200 as city_id,accnum,kuandai,uid,city_code,is_zx_6,is_zx_3 from ads_yz_XQGZ2024091001882;


--20240918  张晓明 
--抽取宽带新装清单号码
drop table if exists tmp_xsb_zxm_01 purge; 
create table tmp_xsb_zxm_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select par_month_id,serv_id,kd_desc 
,case when kd_desc = '普通宽带' 
AND coalesce(prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(kd_prod_offer_name, '-1') NOT LIKE '%0时长%' then '是' else '否' end is_zk 
,is_sheng_yx,case when is_rh_ykj=1 then '是' else '否' end is_rh 
from view_ads_yz_kd_new_list where par_month_id>=202401 
;


--t+n出账数
drop table if exists tmp_xsb_zxm_02 purge; 
create table tmp_xsb_zxm_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select distinct par_month_id,serv_id 
from view_ads_yz_tb_comm_cm_all_final 
where is_Cancel_user=0 and prod_type=40 and is_cz=1
and par_month_id>=202401;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_03 purge; 
create table tmp_xsb_zxm_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,case when b0.serv_id is not null then 1 else 0 end as t_0_cz
,case when b1.serv_id is not null then 1 else 0 end as t_1_cz
,case when b2.serv_id is not null then 1 else 0 end as t_2_cz
,case when b3.serv_id is not null then 1 else 0 end as t_3_cz
from tmp_xsb_zxm_01 a 
left join tmp_xsb_zxm_02 b0 on a.serv_id=b0.serv_id and a.par_month_id=b0.par_month_id 
left join tmp_xsb_zxm_02 b1 on a.serv_id=b1.serv_id and a.par_month_id+1=b1.par_month_id 
left join tmp_xsb_zxm_02 b2 on a.serv_id=b2.serv_id and a.par_month_id+2=b2.par_month_id 
left join tmp_xsb_zxm_02 b3 on a.serv_id=b3.serv_id and a.par_month_id+3=b3.par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_04 purge; 
create table tmp_xsb_zxm_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,case when b4.serv_id is not null then 1 else 0 end as t_4_cz
,case when b5.serv_id is not null then 1 else 0 end as t_5_cz
,case when b6.serv_id is not null then 1 else 0 end as t_6_cz
,case when b7.serv_id is not null then 1 else 0 end as t_7_cz
,case when b8.serv_id is not null then 1 else 0 end as t_8_cz
from tmp_xsb_zxm_03 a 
left join tmp_xsb_zxm_02 b4 on a.serv_id=b4.serv_id and a.par_month_id+4=b4.par_month_id 
left join tmp_xsb_zxm_02 b5 on a.serv_id=b5.serv_id and a.par_month_id+5=b5.par_month_id 
left join tmp_xsb_zxm_02 b6 on a.serv_id=b6.serv_id and a.par_month_id+6=b6.par_month_id 
left join tmp_xsb_zxm_02 b7 on a.serv_id=b7.serv_id and a.par_month_id+7=b7.par_month_id 
left join tmp_xsb_zxm_02 b8 on a.serv_id=b8.serv_id and a.par_month_id+8=b8.par_month_id 
;

drop table if exists tmp_xsb_zxm_dwb purge; 
create table tmp_xsb_zxm_dwb
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select par_month_id,kd_desc,is_zk,is_sheng_yx,is_rh
,count(distinct serv_id) rw 
,sum(t_0_cz) as t0_cz 
,sum(t_1_cz) as t1_cz 
,sum(t_2_cz) as t2_cz 
,sum(t_3_cz) as t3_cz 
,sum(t_4_cz) as t4_cz 
,sum(t_5_cz) as t5_cz 
,sum(t_6_cz) as t6_cz 
,sum(t_7_cz) as t7_cz 
,sum(t_8_cz) as t8_cz 

from tmp_xsb_zxm_04 
group by par_month_id,kd_desc,is_zk,is_sheng_yx,is_rh 
order by par_month_id,kd_desc,is_zk,is_sheng_yx,is_rh 
;

--20241016  张晓明  无需求单
--统计月份	包区类型	县分	宽带类型	是否融合	宽带使用时长  宽带到达  其中有效	其中无效
drop table if exists tmp_xsb_zxm_01 purge;
create table tmp_xsb_zxm_01 as 
select par_month_id,
region_type,
subst_name,
kd_desc,
case when is_rh_ykj=1 then '是' else '否' end as is_rh,
case when kd_sc<60 then '<60分钟' else '>=60分钟' end as kdsc_dangci,
count(distinct serv_id) as kd_dds,
count(distinct case when is_yx_kd=1 then serv_id else null end) as kd_dds_yx,
count(distinct case when coalesce(is_yx_kd,-1)<>1 then serv_id else null end) as kd_dds_wx
from view_ads_yz_tb_comm_cm_all_final
where par_month_id in (202409,202312)
and is_cancel_user = 0
and prod_type = 40
and is_cz = 1 
group by par_month_id,
region_type,
subst_name,
kd_desc,is_rh_ykj,kd_sc;

drop table if exists tmp_xsb_zxm_02 purge;
create table tmp_xsb_zxm_02 as 
select par_month_id,
region_type,
subst_name,
kd_desc,is_rh,kdsc_dangci,
sum(kd_dds) as value1,
sum(kd_dds_yx) as value2,
sum(kd_dds_wx) as value3 
from tmp_xsb_zxm_01 group by par_month_id,
region_type,
subst_name,
kd_desc,is_rh,kdsc_dangci order by par_month_id ;

drop table if exists tmp_xsb_zxm_03 purge;
create table tmp_xsb_zxm_03 as 
select *,ROW_NUMBER() over(order by par_month_id) as paixu 
from tmp_xsb_zxm_02;


--20241015 张晓明  宽带留存
drop table if exists tmp_xsb_zxm_01 purge; 
create table tmp_xsb_zxm_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select par_month_id,serv_id,kd_desc 
,case when kd_desc = '普通宽带' 
AND coalesce(prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(kd_prod_offer_name, '-1') NOT LIKE '%0时长%' then '是' else '否' end is_zk 
,is_sheng_yx,case when is_rh_ykj=1 then '是' else '否' end is_rh 
from view_ads_yz_kd_new_list where par_month_id>=202401 
;


--t+n出账数
drop table if exists tmp_xsb_zxm_02 purge; 
create table tmp_xsb_zxm_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select distinct par_month_id,serv_id 
from view_ads_yz_tb_comm_cm_all_final 
where is_Cancel_user=0 and prod_type=40 and is_cz=1
and par_month_id>=202401;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_03 purge; 
create table tmp_xsb_zxm_03
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*
,case when b0.serv_id is not null then 1 else 0 end as t_0_cz
,case when b1.serv_id is not null then 1 else 0 end as t_1_cz
,case when b2.serv_id is not null then 1 else 0 end as t_2_cz
,case when b3.serv_id is not null then 1 else 0 end as t_3_cz
from tmp_xsb_zxm_01 a 
left join tmp_xsb_zxm_02 b0 on a.serv_id=b0.serv_id and a.par_month_id=b0.par_month_id 
left join tmp_xsb_zxm_02 b1 on a.serv_id=b1.serv_id and a.par_month_id+1=b1.par_month_id 
left join tmp_xsb_zxm_02 b2 on a.serv_id=b2.serv_id and a.par_month_id+2=b2.par_month_id 
left join tmp_xsb_zxm_02 b3 on a.serv_id=b3.serv_id and a.par_month_id+3=b3.par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_04 purge; 
create table tmp_xsb_zxm_04
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*
,case when b4.serv_id is not null then 1 else 0 end as t_4_cz
,case when b5.serv_id is not null then 1 else 0 end as t_5_cz
,case when b6.serv_id is not null then 1 else 0 end as t_6_cz
,case when b7.serv_id is not null then 1 else 0 end as t_7_cz
,case when b8.serv_id is not null then 1 else 0 end as t_8_cz
from tmp_xsb_zxm_03 a 
left join tmp_xsb_zxm_02 b4 on a.serv_id=b4.serv_id and a.par_month_id+4=b4.par_month_id 
left join tmp_xsb_zxm_02 b5 on a.serv_id=b5.serv_id and a.par_month_id+5=b5.par_month_id 
left join tmp_xsb_zxm_02 b6 on a.serv_id=b6.serv_id and a.par_month_id+6=b6.par_month_id 
left join tmp_xsb_zxm_02 b7 on a.serv_id=b7.serv_id and a.par_month_id+7=b7.par_month_id 
left join tmp_xsb_zxm_02 b8 on a.serv_id=b8.serv_id and a.par_month_id+8=b8.par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_05 purge; 
create table tmp_xsb_zxm_05
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*
,case when b9.serv_id is not null then 1 else 0 end as t_9_cz
,case when b10.serv_id is not null then 1 else 0 end as t_10_cz
,case when b11.serv_id is not null then 1 else 0 end as t_11_cz
from tmp_xsb_zxm_04 a 
left join tmp_xsb_zxm_02 b9 on a.serv_id=b9.serv_id and a.par_month_id+9=b9.par_month_id 
left join tmp_xsb_zxm_02 b10 on a.serv_id=b10.serv_id and a.par_month_id+10=b10.par_month_id 
left join tmp_xsb_zxm_02 b11 on a.serv_id=b11.serv_id and a.par_month_id+11=b11.par_month_id 
;

--t+n有效数
drop table if exists tmp_xsb_zxm_06 purge; 
create table tmp_xsb_zxm_06
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select distinct par_month_id,serv_id 
from view_ads_yz_tb_comm_cm_all_final 
where is_Cancel_user=0 and prod_type=40 and is_yx_kd=1
and par_month_id>=202401;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_07 purge; 
create table tmp_xsb_zxm_07
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*
,case when b0.serv_id is not null then 1 else 0 end as t_0_yx
,case when b1.serv_id is not null then 1 else 0 end as t_1_yx
,case when b2.serv_id is not null then 1 else 0 end as t_2_yx
,case when b3.serv_id is not null then 1 else 0 end as t_3_yx
from tmp_xsb_zxm_05 a 
left join tmp_xsb_zxm_06 b0 on a.serv_id=b0.serv_id and a.par_month_id=b0.par_month_id 
left join tmp_xsb_zxm_06 b1 on a.serv_id=b1.serv_id and a.par_month_id+1=b1.par_month_id 
left join tmp_xsb_zxm_06 b2 on a.serv_id=b2.serv_id and a.par_month_id+2=b2.par_month_id 
left join tmp_xsb_zxm_06 b3 on a.serv_id=b3.serv_id and a.par_month_id+3=b3.par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_08 purge; 
create table tmp_xsb_zxm_08
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*
,case when b4.serv_id is not null then 1 else 0 end as t_4_yx
,case when b5.serv_id is not null then 1 else 0 end as t_5_yx
,case when b6.serv_id is not null then 1 else 0 end as t_6_yx
,case when b7.serv_id is not null then 1 else 0 end as t_7_yx
,case when b8.serv_id is not null then 1 else 0 end as t_8_yx
from tmp_xsb_zxm_07 a 
left join tmp_xsb_zxm_06 b4 on a.serv_id=b4.serv_id and a.par_month_id+4=b4.par_month_id 
left join tmp_xsb_zxm_06 b5 on a.serv_id=b5.serv_id and a.par_month_id+5=b5.par_month_id 
left join tmp_xsb_zxm_06 b6 on a.serv_id=b6.serv_id and a.par_month_id+6=b6.par_month_id 
left join tmp_xsb_zxm_06 b7 on a.serv_id=b7.serv_id and a.par_month_id+7=b7.par_month_id 
left join tmp_xsb_zxm_06 b8 on a.serv_id=b8.serv_id and a.par_month_id+8=b8.par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_xsb_zxm_09 purge; 
create table tmp_xsb_zxm_09
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select a.*
,case when b9.serv_id is not null then 1 else 0 end as t_9_yx
,case when b10.serv_id is not null then 1 else 0 end as t_10_yx
,case when b11.serv_id is not null then 1 else 0 end as t_11_yx
from tmp_xsb_zxm_08 a 
left join tmp_xsb_zxm_06 b9 on a.serv_id=b9.serv_id and a.par_month_id+9=b9.par_month_id 
left join tmp_xsb_zxm_06 b10 on a.serv_id=b10.serv_id and a.par_month_id+10=b10.par_month_id 
left join tmp_xsb_zxm_06 b11 on a.serv_id=b11.serv_id and a.par_month_id+11=b11.par_month_id 
;




drop table if exists tmp_xsb_zxm_dwb purge; 
create table tmp_xsb_zxm_dwb
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select par_month_id,kd_desc,is_zk,is_sheng_yx,is_rh
,count(distinct serv_id) rw 
,sum(t_0_cz) as t0_cz 
,sum(t_1_cz) as t1_cz 
,sum(t_2_cz) as t2_cz 
,sum(t_3_cz) as t3_cz 
,sum(t_4_cz) as t4_cz 
,sum(t_5_cz) as t5_cz 
,sum(t_6_cz) as t6_cz 
,sum(t_7_cz) as t7_cz 
,sum(t_8_cz) as t8_cz 
,sum(t_9_cz) as t9_cz 
,sum(t_10_cz) as t10_cz 
,sum(t_11_cz) as t11_cz 

,sum(t_0_yx) as t0_yx 
,sum(t_1_yx) as t1_yx 
,sum(t_2_yx) as t2_yx 
,sum(t_3_yx) as t3_yx 
,sum(t_4_yx) as t4_yx 
,sum(t_5_yx) as t5_yx 
,sum(t_6_yx) as t6_yx 
,sum(t_7_yx) as t7_yx 
,sum(t_8_yx) as t8_yx 
,sum(t_9_yx) as t9_yx 
,sum(t_10_yx) as t10_yx 
,sum(t_11_yx) as t11_yx 

from tmp_xsb_zxm_09 
group by par_month_id,kd_desc,is_zk,is_sheng_yx,is_rh 
order by par_month_id,kd_desc,is_zk,is_sheng_yx,is_rh 
;

--20241017  简单计算同环比
 月份，广州大数版：
 **需保证中间所有月份数据都存在，不能断开**
 
 
 with tmp1 as (select par_month_id,
 count(distinct serv_id) as tj_num from   
  view_ads_yz_kd_new_list
where par_month_id between 202212 and 202409 --根据环比同比需要圈定月份范围
and kd_desc = '普通宽带' 
and coalesce(prod_name, '-1') not like '%专线%' 
and coalesce(prod_name, '-1') not like '%城域网%' 
and coalesce(kd_prod_offer_name, '-1') not like '%0时长%'
and rh_tc_value >= 129
group by par_month_id ),

--CTE子句1 tmp1 生成你要统计的数据的各月份统计数

  tmp2 as (select par_month_id,tj_num,
		   lag(tj_num,1) over (order by par_month_id)   as hb_num, 
		   -- over()部分是开窗，省略partition by子句来在所有月份中间开窗，根据月份排序， lag(col,n)取窗口内n行之前的col字段，我们这里开窗，直接在所有月份数据里排序，故lag(tj_num,1)为环比数，同比则n=12
		   lag(tj_num,12) over (order by par_month_id)   as tb_num
		   from tmp1
  )
  
--最终根据CTE子句2 tmp2 生成的同环比数据直接计算同环比
  SELECT 
   par_month_id,tj_num,
   hb_num,tj_num/hb_num-1 as hb, --环比部分
   tb_num,tj_num/tb_num-1 as tb --同比部分
   from tmp2
   
   

**进一步可以扩展维度，区别是lag开窗的时候按添加的维度partition by(开窗)，保证窗口内排序的是region_type_desc里各取值的所有历史月份数据，正确排序就可以得到正确的环比同比数据
with tmp1 as (select par_month_id,
			  case when region_type in ('专业市场','商务楼宇','产业园区') then '商客' 
			  when region_type ='城市家庭' then '社区'
			  else region_type end as region_type_desc
			  ,count(distinct serv_id) as tj_num from   
  view_ads_yz_kd_new_list
where par_month_id between 202212 and 202409
and kd_desc = '普通宽带' 
and coalesce(prod_name, '-1') not like '%专线%' 
and coalesce(prod_name, '-1') not like '%城域网%' 
and coalesce(kd_prod_offer_name, '-1') not like '%0时长%'
and rh_tc_value >= 129
group by par_month_id,case when region_type in ('专业市场','商务楼宇','产业园区') then '商客' 
			  when region_type ='城市家庭' then '社区'
			  else region_type end ),

  tmp2 as (select par_month_id,region_type_desc,tj_num,
		   lag(tj_num,1) over (partition by region_type_desc order by par_month_id)   as hb_num,
		   lag(tj_num,12) over (partition by region_type_desc order by par_month_id)   as tb_num
		   from tmp1
  )
  SELECT 
   par_month_id,region_type_desc,tj_num,hb_num,tj_num/hb_num-1 as hb,tb_num,tj_num/tb_num-1 as tb

   from tmp2    order by par_month_id,region_type_desc limit 1000
   
--20241021  XQGZ2024101502009 需求标题 关于广州市番禺区人民政府钟村街道办事处欠费号码提取使用情况数据的需求 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 as 

select concat('m',par_month_id) as flag,acc_nbr,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll  --宽带流量 单位M
		--cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon a 
join zone_gz_yz_3351225714708480 b on a.acc_nbr=b.index1 
where par_corp_id=200 and par_month_id>=202210 and par_month_id<=202410
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 as 
select acc_nbr,
str_to_map(concat_ws(',',collect_set(concat_ws('=',flag,cast(kd_ll as string)))),',','=') map_col
from tmp_yz_liq_1    
group by acc_nbr
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 as 
select acc_nbr,
coalesce(cast(map_col[\"m202210\"] as decimal(22,2)),0) m202210,
coalesce(cast(map_col[\"m202211\"] as decimal(22,2)),0) m202211,
coalesce(cast(map_col[\"m202212\"] as decimal(22,2)),0) m202212,

coalesce(cast(map_col[\"m202301\"] as decimal(22,2)),0) m202301,
coalesce(cast(map_col[\"m202302\"] as decimal(22,2)),0) m202302,
coalesce(cast(map_col[\"m202303\"] as decimal(22,2)),0) m202303,
coalesce(cast(map_col[\"m202304\"] as decimal(22,2)),0) m202304,
coalesce(cast(map_col[\"m202305\"] as decimal(22,2)),0) m202305,
coalesce(cast(map_col[\"m202306\"] as decimal(22,2)),0) m202306,
coalesce(cast(map_col[\"m202307\"] as decimal(22,2)),0) m202307,
coalesce(cast(map_col[\"m202308\"] as decimal(22,2)),0) m202308,
coalesce(cast(map_col[\"m202309\"] as decimal(22,2)),0) m202309,
coalesce(cast(map_col[\"m202310\"] as decimal(22,2)),0) m202310,
coalesce(cast(map_col[\"m202311\"] as decimal(22,2)),0) m202311,
coalesce(cast(map_col[\"m202312\"] as decimal(22,2)),0) m202312,

coalesce(cast(map_col[\"m202401\"] as decimal(22,2)),0) m202401,
coalesce(cast(map_col[\"m202402\"] as decimal(22,2)),0) m202402,
coalesce(cast(map_col[\"m202403\"] as decimal(22,2)),0) m202403,
coalesce(cast(map_col[\"m202404\"] as decimal(22,2)),0) m202404,
coalesce(cast(map_col[\"m202405\"] as decimal(22,2)),0) m202405,
coalesce(cast(map_col[\"m202406\"] as decimal(22,2)),0) m202406,
coalesce(cast(map_col[\"m202407\"] as decimal(22,2)),0) m202407,
coalesce(cast(map_col[\"m202408\"] as decimal(22,2)),0) m202408,
coalesce(cast(map_col[\"m202409\"] as decimal(22,2)),0) m202409,
coalesce(cast(map_col[\"m202410\"] as decimal(22,2)),0) m202410
from tmp_yz_liq_2
;

drop table if exists tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 as 

select a.index1 as acc_nbr 
,b.m202210,b.m202211,b.m202212,b.m202301,b.m202302,b.m202303,b.m202304,b.m202305
,b.m202306,b.m202307,b.m202308,b.m202309,b.m202310,b.m202311,b.m202312 
,b.m202401,b.m202402,b.m202403,b.m202404,b.m202405
,b.m202406,b.m202407,b.m202408,b.m202409,b.m202410 
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_liq_3 b on a.index1=b.acc_nbr 
;


use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 as 

select concat('m',par_month_id) as flag,acc_nbr,stm_data
from dwm_yz_tb_comm_cm_all_mon_final a 
join zone_gz_yz_3351225714708480 b on a.acc_nbr=b.index1 and b.index1 not like 'ADSL%'
where par_month_id>=202210 and par_month_id<=202409 

union all 
select concat('m',par_month_id) as flag,acc_nbr,stm_data
from dwm_yz_tb_comm_cm_all_final a 
join zone_gz_yz_3351225714708480 b on a.acc_nbr=b.index1 and b.index1 not like 'ADSL%'
where par_month_id=202410
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 as 
select acc_nbr,
str_to_map(concat_ws(',',collect_set(concat_ws('=',flag,cast(stm_data as string)))),',','=') map_col
from tmp_yz_liq_5    
group by acc_nbr
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_7 purge;
create table tmp_yz_liq_7 as 
select acc_nbr,
coalesce(cast(map_col[\"m202210\"] as decimal(22,2)),0) m202210,
coalesce(cast(map_col[\"m202211\"] as decimal(22,2)),0) m202211,
coalesce(cast(map_col[\"m202212\"] as decimal(22,2)),0) m202212,

coalesce(cast(map_col[\"m202301\"] as decimal(22,2)),0) m202301,
coalesce(cast(map_col[\"m202302\"] as decimal(22,2)),0) m202302,
coalesce(cast(map_col[\"m202303\"] as decimal(22,2)),0) m202303,
coalesce(cast(map_col[\"m202304\"] as decimal(22,2)),0) m202304,
coalesce(cast(map_col[\"m202305\"] as decimal(22,2)),0) m202305,
coalesce(cast(map_col[\"m202306\"] as decimal(22,2)),0) m202306,
coalesce(cast(map_col[\"m202307\"] as decimal(22,2)),0) m202307,
coalesce(cast(map_col[\"m202308\"] as decimal(22,2)),0) m202308,
coalesce(cast(map_col[\"m202309\"] as decimal(22,2)),0) m202309,
coalesce(cast(map_col[\"m202310\"] as decimal(22,2)),0) m202310,
coalesce(cast(map_col[\"m202311\"] as decimal(22,2)),0) m202311,
coalesce(cast(map_col[\"m202312\"] as decimal(22,2)),0) m202312,

coalesce(cast(map_col[\"m202401\"] as decimal(22,2)),0) m202401,
coalesce(cast(map_col[\"m202402\"] as decimal(22,2)),0) m202402,
coalesce(cast(map_col[\"m202403\"] as decimal(22,2)),0) m202403,
coalesce(cast(map_col[\"m202404\"] as decimal(22,2)),0) m202404,
coalesce(cast(map_col[\"m202405\"] as decimal(22,2)),0) m202405,
coalesce(cast(map_col[\"m202406\"] as decimal(22,2)),0) m202406,
coalesce(cast(map_col[\"m202407\"] as decimal(22,2)),0) m202407,
coalesce(cast(map_col[\"m202408\"] as decimal(22,2)),0) m202408,
coalesce(cast(map_col[\"m202409\"] as decimal(22,2)),0) m202409,
coalesce(cast(map_col[\"m202410\"] as decimal(22,2)),0) m202410
from tmp_yz_liq_6
;

drop table if exists tmp_yz_liq_8 purge;
create table tmp_yz_liq_8 as 

select a.index1 as acc_nbr 
,b.m202210,b.m202211,b.m202212,b.m202301,b.m202302,b.m202303,b.m202304,b.m202305
,b.m202306,b.m202307,b.m202308,b.m202309,b.m202310,b.m202311,b.m202312 
,b.m202401,b.m202402,b.m202403,b.m202404,b.m202405
,b.m202406,b.m202407,b.m202408,b.m202409,b.m202410 
from zone_gz_yz_3351225714708480 a 
join tmp_yz_liq_7 b on a.index1=b.acc_nbr 
;

drop table if exists tmp_yz_liq_9 purge;
create table tmp_yz_liq_9 as 

select a.* from tmp_yz_liq_4 a where not exists (select acc_nbr from tmp_yz_liq_8 c where a.acc_nbr=c.acc_nbr  )
union all 
select * from tmp_yz_liq_8 
;

"

--20241022   XQGZ2024102200149 需求标题 关于全量宽带ARPU和使用时长分析的需求 
统计月份 是否有效	kd_desc	是否融合	prod_type3	县分	region_type	ARPU	使用时长  宽带到达数

drop table if exists tmp_xsb_zxm_01_1 purge;
create table tmp_xsb_zxm_01_1 as 
select par_month_id,
case when is_yx_kd=1 then '是' else '否' end as is_yx ,
kd_desc,
case when is_rh_ykj=1 then '是' else '否' end as is_rh,
prod_type3,
subst_name,
region_type,
case when kd_sc<60 then '<60分钟' else '>=60分钟' end as kdsc_dangci,
serv_id,prod_id 
from view_ads_yz_tb_comm_cm_all_final
where par_month_id in (202407,202408,202409)
and is_cancel_user = 0
and prod_type = 40
and is_cz = 1 
;

drop table if exists tmp_xsb_zxm_01_2 purge;
create table tmp_xsb_zxm_01_2 as 
select a.*,b.yx_arpu from tmp_xsb_zxm_01_1 a 
left join summary_ods_month_city.TB_COMM_CM_DATA_MON  b 
on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id and b.PAR_CORP_ID='200' and b.PAR_MONTH_ID in (202407,202408,202409) 
;

drop table if exists tmp_xsb_zxm_01 purge;
create table tmp_xsb_zxm_01 as 
select par_month_id,
is_yx ,
kd_desc,
is_rh,
prod_type3,
subst_name,
region_type,
case when yx_arpu<10 then '<10' else '>=10' end as yx_arpu_dangci,
kdsc_dangci,
count(distinct serv_id) as kd_dds 
from tmp_xsb_zxm_01_2  
group by par_month_id,
is_yx ,
kd_desc,
is_rh,
prod_type3,
subst_name,
region_type,yx_arpu,kdsc_dangci;

drop table if exists tmp_xsb_zxm_02 purge;
create table tmp_xsb_zxm_02 as 
select par_month_id,
is_yx ,
kd_desc,
is_rh,
prod_type3,
subst_name,
region_type,yx_arpu_dangci,kdsc_dangci,
sum(kd_dds) as value1 
from tmp_xsb_zxm_01 group by par_month_id,
is_yx ,
kd_desc,
is_rh,
prod_type3,
subst_name,
region_type,yx_arpu_dangci,kdsc_dangci order by par_month_id ;

drop table if exists tmp_xsb_zxm_03 purge;
create table tmp_xsb_zxm_03 as 
select *,ROW_NUMBER() over(order by par_month_id) as paixu 
from tmp_xsb_zxm_02;

drop table if exists tmp_xsb_zxm_XQGZ2024102200149 purge;
create table tmp_xsb_zxm_XQGZ2024102200149 as 
select 200 as city_id,* from tmp_xsb_zxm_02;




--20241030   XQGZ2024093001685  关于政企名单制梳理工作 
--产权ID	产权编码	产权客户名	产权客户建档时间
--抽取产权信息，经沟通锁定战略分群为政企的全量产权客户
drop table if exists tmp_yz_liq_XQGZ2024093001685_1 purge;
create table tmp_yz_liq_XQGZ2024093001685_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select cust_id,cust_number,cust_name,create_date 
,row_number() over(partition by cust_number,cust_name order by create_date desc) paixu 
from dws_crm_cust.dws_customer where city_id=200 
and cust_type='1000'  --战略分群为政企
;

--直销ID	直销编码	直销客户名	客户类型	是否重点客户	所属局向ID	所属局向	所属营服	所属营服ID
--有686个产权-直销 1对多：select  cust_nbr, count(distinct ccust_id) from dws_yz_tb_mo_custgrp_cust_final group by cust_nbr having count(distinct ccust_id)>1 limit 1000
--经政企部何炜斌确认随机取一个直销
drop table if exists tmp_yz_liq_XQGZ2024093001685_2 purge;
create table tmp_yz_liq_XQGZ2024093001685_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.ccust_id
from tmp_yz_liq_XQGZ2024093001685_1 a 
left join (select cust_nbr,ccust_id,row_number() over(partition by cust_nbr order by ccust_id) as paixu from dws_yz_tb_mo_custgrp_cust_final) b 
on a.cust_number=b.cust_nbr and b.paixu=1
;

drop table if exists tmp_yz_liq_XQGZ2024093001685_3 purge;
create table tmp_yz_liq_XQGZ2024093001685_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as
select a.* 
,b.ccust_code,b.ccust_name,b.vip_flag,b.branch_org,b.manage_org
from tmp_yz_liq_XQGZ2024093001685_2 a 
left join (select ccust_id,ccust_code,ccust_name,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;

drop table tmp_yz_liq_XQGZ2024093001685_4 purge;
create table tmp_yz_liq_XQGZ2024093001685_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.attr_value_name as is_vip_cust 
from tmp_yz_liq_XQGZ2024093001685_3 a 
left join (select attr_id,attr_inner_value,attr_value_name,attr_value_sort  from  dws_crm_cfguse.dws_attr_value where city_id=200
and attr_id='400003971') b on a.vip_flag=b.attr_inner_value
;

drop table tmp_yz_liq_XQGZ2024093001685_5 purge;
create table tmp_yz_liq_XQGZ2024093001685_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.org_name as ccust_subst_name 
,c.org_name as ccust_branch_name
from tmp_yz_liq_XQGZ2024093001685_4 a 
left join (select * from  dwd_yz_dim_org where levs='3') b
on a.branch_org=b.org_id
left join (select * from  dwd_yz_dim_org where levs='4') c
on a.manage_org=c.org_id;

--P码ID	P码（身份证编码）	P码客户名
--产权-P码 1对多,按更新时间最晚取唯一P码
drop table tmp_yz_liq_XQGZ2024093001685_6 purge;
create table tmp_yz_liq_XQGZ2024093001685_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.party_id,c.party_nbr,c.party_name 
from tmp_yz_liq_XQGZ2024093001685_5 a 
left join (select cust_id,party_id,row_number() over(partition by cust_id order by update_date desc) as paixu 
from dws_ecust.dws_party_zq_fcust_rel where city_id=200 ) b 
on a.cust_id=b.cust_id and b.paixu=1
left join dws_ecust.dws_party_zq c on b.party_id=c.party_id and c.city_id=200 
;

--直销客户类型， attr_id='4000094004' ，1 现实客户  2 -  4 潜在客户
drop table tmp_yz_liq_XQGZ2024093001685_7_1 purge;
create table tmp_yz_liq_XQGZ2024093001685_7_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.*
,case when b.cust_state=1 then '现实客户' 
	  when b.cust_state>=2 and b.cust_state<=4 then '潜在客户' else null end cust_lx 
from tmp_yz_liq_XQGZ2024093001685_6 a
left join 
(select ccust_id,cust_state from dws_ecust.dws_mo_ccust where city_id=200) b
on a.ccust_id=b.ccust_id;

--是否黑名单
drop table tmp_yz_liq_XQGZ2024093001685_7 purge;
create table tmp_yz_liq_XQGZ2024093001685_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,case when b.cust_id is not null then '是' else '否' end is_hmd 
from tmp_yz_liq_XQGZ2024093001685_7_1 a 
left join tmp_yz_sensit_cust_list_hmd_cust_cert b on a.cust_id=b.cust_id;

--按客户统计业务数
drop table tmp_yz_liq_XQGZ2024093001685_8 purge;
create table tmp_yz_liq_XQGZ2024093001685_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select cust_id,count(distinct serv_id) num 
from dwm_yz_tb_comm_cm_all_final a 
where a.state<>'140001' --剔除新申请
and a.par_month_id=202411 and a.is_cancel_user=0
group by cust_id; 

drop table tmp_yz_liq_XQGZ2024093001685_9 purge;
create table tmp_yz_liq_XQGZ2024093001685_9 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.*,b.num 
from tmp_yz_liq_XQGZ2024093001685_7 a 
left join tmp_yz_liq_XQGZ2024093001685_8 b 
on a.cust_id=b.cust_id;

drop table tmp_yz_liq_XQGZ2024093001685_10 purge;
create table tmp_yz_liq_XQGZ2024093001685_10 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select par_month_id,cust_id, 
subst_name,channel_subst_name,std_subst_name,
sum(a0) as sh_qr,--税后确认收入
sum(a0)-sum(a8) as sh_tc_ycx --剔除一次性税后收入
from dwm_srhx_serv_list_mon_final
where par_month_id >= 202301 and par_month_id<=202410 
group by par_month_id,cust_id,subst_name,channel_subst_name,std_subst_name; 

drop table tmp_yz_liq_XQGZ2024093001685_11 purge;
create table tmp_yz_liq_XQGZ2024093001685_11 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as  
select cust_id,
sum(case when par_month_id>=202301 and par_month_id<=202312 then sh_qr else 0 end) as sh_qr_2023, 
sum(case when par_month_id>=202401 and par_month_id<=202410 then sh_qr else 0 end) as sh_qr_202409, 

sum(case when par_month_id>=202301 and par_month_id<=202312 then sh_tc_ycx else 0 end) as sh_tc_ycx_2023, 
sum(case when par_month_id>=202401 and par_month_id<=202410 then sh_tc_ycx else 0 end) as sh_tc_ycx_202409 
from tmp_yz_liq_XQGZ2024093001685_10 group by cust_id;


drop table tmp_yz_liq_XQGZ2024093001685_12 purge;
create table tmp_yz_liq_XQGZ2024093001685_12 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as  
select a.* 
,b.sh_qr_2023,b.sh_qr_202409
,b.sh_tc_ycx_2023,b.sh_tc_ycx_202409 
from tmp_yz_liq_XQGZ2024093001685_9 a 
left join tmp_yz_liq_XQGZ2024093001685_11 b  on a.cust_id=b.cust_id; 

--############划小最大收入局向（24年1-9月）######################################
--划小最大收入局向（24年1-9月）
drop table tmp_yz_liq_XQGZ2024093001685_13_1 purge;
create table tmp_yz_liq_XQGZ2024093001685_13_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,subst_name  
,sum(sh_qr) as sr_sh 
,sum(sh_tc_ycx) as sr_sh_tc_ycx 
from tmp_yz_liq_XQGZ2024093001685_10 a 
where par_month_id>=202401 and par_month_id<=202410 
group by cust_id,subst_name;

--划小最大收入局向（24年1-9月）
drop table tmp_yz_liq_XQGZ2024093001685_13_2 purge;
create table tmp_yz_liq_XQGZ2024093001685_13_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by cust_id order by sr_sh desc) as paixu1 
,row_number() over(partition by cust_id order by sr_sh_tc_ycx desc) as paixu2
from tmp_yz_liq_XQGZ2024093001685_13_1 a;

--############揽装收入最大局向（24年1-9月）######################################
--揽装收入最大局向（24年1-9月）
drop table tmp_yz_liq_XQGZ2024093001685_14_1 purge;
create table tmp_yz_liq_XQGZ2024093001685_14_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,channel_subst_name  
,sum(sh_qr) as sr_sh 
,sum(sh_tc_ycx) as sr_sh_tc_ycx 
from tmp_yz_liq_XQGZ2024093001685_10 a 
where par_month_id>=202401 and par_month_id<=202410 
group by cust_id,channel_subst_name;

--揽装收入最大局向（24年1-9月）
drop table tmp_yz_liq_XQGZ2024093001685_14_2 purge;
create table tmp_yz_liq_XQGZ2024093001685_14_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by cust_id order by sr_sh desc) as paixu1 
,row_number() over(partition by cust_id order by sr_sh_tc_ycx desc) as paixu2
from tmp_yz_liq_XQGZ2024093001685_14_1 a;

--############落地收入最大局向（24年1-9月）######################################
--落地收入最大局向（24年1-9月）
drop table tmp_yz_liq_XQGZ2024093001685_15_1 purge;
create table tmp_yz_liq_XQGZ2024093001685_15_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select cust_id,std_subst_name  
,sum(sh_qr) as sr_sh 
,sum(sh_tc_ycx) as sr_sh_tc_ycx 
from tmp_yz_liq_XQGZ2024093001685_10 a 
where par_month_id>=202401 and par_month_id<=202410 
group by cust_id,std_subst_name;

--落地收入最大局向（24年1-9月）
drop table tmp_yz_liq_XQGZ2024093001685_15_2 purge;
create table tmp_yz_liq_XQGZ2024093001685_15_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by cust_id order by sr_sh desc) as paixu1 
,row_number() over(partition by cust_id order by sr_sh_tc_ycx desc) as paixu2
from tmp_yz_liq_XQGZ2024093001685_15_1 a;


--划小最大收入局向\揽装最大收入局向\落地最大收入局向
drop table tmp_yz_liq_XQGZ2024093001685_16 purge;
create table tmp_yz_liq_XQGZ2024093001685_16 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.subst_name as maxsr_subst,c.channel_subst_name as maxsr_channel_subst,d.std_subst_name as maxsr_std_subst 
from tmp_yz_liq_XQGZ2024093001685_12 a 
left join tmp_yz_liq_XQGZ2024093001685_13_2 b on a.cust_id=b.cust_id and b.paixu1=1 and b.cust_id is not null 
left join tmp_yz_liq_XQGZ2024093001685_14_2 c on a.cust_id=c.cust_id and c.paixu1=1 and c.cust_id is not null 
left join tmp_yz_liq_XQGZ2024093001685_15_2 d on a.cust_id=d.cust_id and d.paixu1=1 and d.cust_id is not null 
;

--划小最大收入局向\揽装最大收入局向\落地最大收入局向(剔除一次性)
drop table tmp_yz_liq_XQGZ2024093001685_17 purge;
create table tmp_yz_liq_XQGZ2024093001685_17 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.*,b.subst_name as maxsr_subst2,c.channel_subst_name as maxsr_channel_subst2,d.std_subst_name as maxsr_std_subst2 
from tmp_yz_liq_XQGZ2024093001685_16 a 
left join tmp_yz_liq_XQGZ2024093001685_13_2 b on a.cust_id=b.cust_id and b.paixu2=1 and b.cust_id is not null 
left join tmp_yz_liq_XQGZ2024093001685_14_2 c on a.cust_id=c.cust_id and c.paixu2=1 and c.cust_id is not null 
left join tmp_yz_liq_XQGZ2024093001685_15_2 d on a.cust_id=d.cust_id and d.paixu2=1 and d.cust_id is not null 
;

--划小各分局收入打横统计
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024093001685_13_3 purge;
create table tmp_yz_liq_XQGZ2024093001685_13_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select *,case when subst_name='天河分公司' then 'th' when subst_name='番禺分公司' then 'py' when subst_name='白云分公司' then 'baiy' 
		      when subst_name='越秀分公司' then 'yx' when subst_name='海珠分公司' then 'hz' when subst_name='荔湾分公司' then 'lw'  
			  when subst_name='黄埔分公司' then 'hp' when subst_name='增城分公司' then 'zc' when subst_name='花都分公司' then 'hd' 
			  when subst_name='南沙分公司' then 'ns' when subst_name='从化分公司' then 'ch' when subst_name='政企客户部' then 'zqkhb' 
		 end as subst_nbr 
from tmp_yz_liq_XQGZ2024093001685_13_1 a;

drop table if exists tmp_yz_liq_XQGZ2024093001685_13_4 purge;
create table tmp_yz_liq_XQGZ2024093001685_13_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
str_to_map(concat_ws(',',collect_set(concat_ws('=',subst_nbr,cast(sr_sh as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2024093001685_13_3    
group by cust_id
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024093001685_13 purge;
create table tmp_yz_liq_XQGZ2024093001685_13 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
coalesce(cast(map_col[\"th\"] as decimal(22,2)),0) th_subst_sr,
coalesce(cast(map_col[\"py\"] as decimal(22,2)),0) py_subst_sr,
coalesce(cast(map_col[\"baiy\"] as decimal(22,2)),0) baiy_subst_sr,
coalesce(cast(map_col[\"yx\"] as decimal(22,2)),0) yx_subst_sr,
coalesce(cast(map_col[\"hz\"] as decimal(22,2)),0) hz_subst_sr,
coalesce(cast(map_col[\"lw\"] as decimal(22,2)),0) lw_subst_sr,
coalesce(cast(map_col[\"hp\"] as decimal(22,2)),0) hp_subst_sr,
coalesce(cast(map_col[\"zc\"] as decimal(22,2)),0) zc_subst_sr,
coalesce(cast(map_col[\"hd\"] as decimal(22,2)),0) hd_subst_sr,
coalesce(cast(map_col[\"ns\"] as decimal(22,2)),0) ns_subst_sr,
coalesce(cast(map_col[\"ch\"] as decimal(22,2)),0) ch_subst_sr,
coalesce(cast(map_col[\"zqkhb\"] as decimal(22,2)),0) zqkhb_subst_sr
from tmp_yz_liq_XQGZ2024093001685_13_4
;

drop table if exists tmp_yz_liq_XQGZ2024093001685_18 purge;
create table tmp_yz_liq_XQGZ2024093001685_18 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*  
,b.th_subst_sr,b.py_subst_sr,b.baiy_subst_sr,b.yx_subst_sr,b.hz_subst_sr,b.lw_subst_sr,b.hp_subst_sr,b.zc_subst_sr
,b.hd_subst_sr,b.ns_subst_sr,b.ch_subst_sr,b.zqkhb_subst_sr 
from tmp_yz_liq_XQGZ2024093001685_17 a 
left join tmp_yz_liq_XQGZ2024093001685_13 b on a.cust_id=b.cust_id 
;


--揽装各分局收入打横统计
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024093001685_14_3 purge;
create table tmp_yz_liq_XQGZ2024093001685_14_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select *,case when channel_subst_name='天河分公司' then 'th' when channel_subst_name='番禺分公司' then 'py' when channel_subst_name='白云分公司' then 'baiy' 
		      when channel_subst_name='越秀分公司' then 'yx' when channel_subst_name='海珠分公司' then 'hz' when channel_subst_name='荔湾分公司' then 'lw'  
			  when channel_subst_name='黄埔分公司' then 'hp' when channel_subst_name='增城分公司' then 'zc' when channel_subst_name='花都分公司' then 'hd' 
			  when channel_subst_name='南沙分公司' then 'ns' when channel_subst_name='从化分公司' then 'ch' when channel_subst_name='政企客户部' then 'zqkhb' 
		 end as channel_subst_nbr  
from tmp_yz_liq_XQGZ2024093001685_14_1 a;

drop table if exists tmp_yz_liq_XQGZ2024093001685_14_4 purge;
create table tmp_yz_liq_XQGZ2024093001685_14_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
str_to_map(concat_ws(',',collect_set(concat_ws('=',channel_subst_nbr,cast(sr_sh as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2024093001685_14_3    
group by cust_id
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024093001685_14 purge;
create table tmp_yz_liq_XQGZ2024093001685_14 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
coalesce(cast(map_col[\"th\"] as decimal(22,2)),0) th_channel_subst_sr,
coalesce(cast(map_col[\"py\"] as decimal(22,2)),0) py_channel_subst_sr,
coalesce(cast(map_col[\"baiy\"] as decimal(22,2)),0) baiy_channel_subst_sr,
coalesce(cast(map_col[\"yx\"] as decimal(22,2)),0) yx_channel_subst_sr,
coalesce(cast(map_col[\"hz\"] as decimal(22,2)),0) hz_channel_subst_sr,
coalesce(cast(map_col[\"lw\"] as decimal(22,2)),0) lw_channel_subst_sr,
coalesce(cast(map_col[\"hp\"] as decimal(22,2)),0) hp_channel_subst_sr,
coalesce(cast(map_col[\"zc\"] as decimal(22,2)),0) zc_channel_subst_sr,
coalesce(cast(map_col[\"hd\"] as decimal(22,2)),0) hd_channel_subst_sr,
coalesce(cast(map_col[\"ns\"] as decimal(22,2)),0) ns_channel_subst_sr,
coalesce(cast(map_col[\"ch\"] as decimal(22,2)),0) ch_channel_subst_sr,
coalesce(cast(map_col[\"zqkhb\"] as decimal(22,2)),0) zqkhb_channel_subst_sr
from tmp_yz_liq_XQGZ2024093001685_14_4
;

drop table if exists tmp_yz_liq_XQGZ2024093001685_19 purge;
create table tmp_yz_liq_XQGZ2024093001685_19 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.*  
,b.th_channel_subst_sr,b.py_channel_subst_sr,b.baiy_channel_subst_sr,b.yx_channel_subst_sr
,b.hz_channel_subst_sr,b.lw_channel_subst_sr,b.hp_channel_subst_sr,b.zc_channel_subst_sr
,b.hd_channel_subst_sr,b.ns_channel_subst_sr,b.ch_channel_subst_sr,b.zqkhb_channel_subst_sr 
from tmp_yz_liq_XQGZ2024093001685_18 a 
left join tmp_yz_liq_XQGZ2024093001685_14 b on a.cust_id=b.cust_id 
;


--落地各分局收入打横统计
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024093001685_15_3 purge;
create table tmp_yz_liq_XQGZ2024093001685_15_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select *,case when std_subst_name='天河分公司' then 'th' when std_subst_name='番禺分公司' then 'py' when std_subst_name='白云分公司' then 'baiy' 
		      when std_subst_name='越秀分公司' then 'yx' when std_subst_name='海珠分公司' then 'hz' when std_subst_name='荔湾分公司' then 'lw'  
			  when std_subst_name='黄埔分公司' then 'hp' when std_subst_name='增城分公司' then 'zc' when std_subst_name='花都分公司' then 'hd' 
			  when std_subst_name='南沙分公司' then 'ns' when std_subst_name='从化分公司' then 'ch' when std_subst_name='政企客户部' then 'zqkhb' 
		 end as std_subst_nbr  
from tmp_yz_liq_XQGZ2024093001685_15_1 a;

drop table if exists tmp_yz_liq_XQGZ2024093001685_15_4 purge;
create table tmp_yz_liq_XQGZ2024093001685_15_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select cust_id,
str_to_map(concat_ws(',',collect_set(concat_ws('=',std_subst_nbr,cast(sr_sh as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2024093001685_15_3    
group by cust_id
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024093001685_15 purge;
create table tmp_yz_liq_XQGZ2024093001685_15 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
coalesce(cast(map_col[\"th\"] as decimal(22,2)),0) th_std_subst_sr,
coalesce(cast(map_col[\"py\"] as decimal(22,2)),0) py_std_subst_sr,
coalesce(cast(map_col[\"baiy\"] as decimal(22,2)),0) baiy_std_subst_sr,
coalesce(cast(map_col[\"yx\"] as decimal(22,2)),0) yx_std_subst_sr,
coalesce(cast(map_col[\"hz\"] as decimal(22,2)),0) hz_std_subst_sr,
coalesce(cast(map_col[\"lw\"] as decimal(22,2)),0) lw_std_subst_sr,
coalesce(cast(map_col[\"hp\"] as decimal(22,2)),0) hp_std_subst_sr,
coalesce(cast(map_col[\"zc\"] as decimal(22,2)),0) zc_std_subst_sr,
coalesce(cast(map_col[\"hd\"] as decimal(22,2)),0) hd_std_subst_sr,
coalesce(cast(map_col[\"ns\"] as decimal(22,2)),0) ns_std_subst_sr,
coalesce(cast(map_col[\"ch\"] as decimal(22,2)),0) ch_std_subst_sr,
coalesce(cast(map_col[\"zqkhb\"] as decimal(22,2)),0) zqkhb_std_subst_sr
from tmp_yz_liq_XQGZ2024093001685_15_4
;

drop table if exists tmp_yz_liq_XQGZ2024093001685_20 purge;
create table tmp_yz_liq_XQGZ2024093001685_20 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*  
,b.th_std_subst_sr,b.py_std_subst_sr,b.baiy_std_subst_sr,b.yx_std_subst_sr
,b.hz_std_subst_sr,b.lw_std_subst_sr,b.hp_std_subst_sr,b.zc_std_subst_sr
,b.hd_std_subst_sr,b.ns_std_subst_sr,b.ch_std_subst_sr,b.zqkhb_std_subst_sr 
from tmp_yz_liq_XQGZ2024093001685_19 a 
left join tmp_yz_liq_XQGZ2024093001685_15 b on a.cust_id=b.cust_id 
;

--插入结果表
insert into table ads_yz_liq_XQGZ2024093001685_list(
city_id,cust_id,cust_number,cust_name,create_date,party_id,party_nbr,party_name
,ccust_id,ccust_code,ccust_name,cust_lx,is_vip_cust,branch_org,ccust_subst_name,manage_org,ccust_branch_name,num,is_hmd
,sh_qr_2023,sh_tc_ycx_2023,sh_qr_202409,sh_tc_ycx_202409 

,sr_subst,sr_tc_ycx_subst,sr_th,sr_py,sr_by,sr_yx,sr_hz,sr_lw,sr_hp
,sr_zc,sr_hd,sr_ns,sr_ch,sr_zqkhb

,lz_sr_subst,lz_sr_tc_ycx_subst,lz_sr_th,lz_sr_py,lz_sr_by
,lz_sr_yx,lz_sr_hz,lz_sr_lw,lz_sr_hp,lz_sr_zc
,lz_sr_hd,lz_sr_ns,lz_sr_ch,lz_sr_zqkhb

,ld_sr_subst,ld_sr_tc_ycx_subst,ld_sr_th,ld_sr_py,ld_sr_by,ld_sr_yx
,ld_sr_hz,ld_sr_lw,ld_sr_hp,ld_sr_zc,ld_sr_hd,ld_sr_ns,ld_sr_ch,ld_sr_zqkhb) 

select 200 as city_id 
,cust_id,cust_number,cust_name,create_date,party_id,party_nbr,party_name 
,ccust_id,ccust_code,ccust_name,cust_lx,is_vip_cust,branch_org,ccust_subst_name,manage_org,ccust_branch_name,num,is_hmd 
,sh_qr_2023,sh_tc_ycx_2023,sh_qr_202409,sh_tc_ycx_202409 

,maxsr_subst,maxsr_subst2,th_subst_sr,py_subst_sr,baiy_subst_sr,yx_subst_sr,hz_subst_sr,lw_subst_sr,hp_subst_sr
,zc_subst_sr,hd_subst_sr,ns_subst_sr,ch_subst_sr,zqkhb_subst_sr 

,maxsr_channel_subst,maxsr_channel_subst2,th_channel_subst_sr,py_channel_subst_sr,baiy_channel_subst_sr
,yx_channel_subst_sr,hz_channel_subst_sr,lw_channel_subst_sr,hp_channel_subst_sr,zc_channel_subst_sr
,hd_channel_subst_sr,ns_channel_subst_sr,ch_channel_subst_sr,zqkhb_channel_subst_sr

,maxsr_std_subst,maxsr_std_subst2,th_std_subst_sr,py_std_subst_sr,baiy_std_subst_sr,yx_std_subst_sr
,hz_std_subst_sr,lw_std_subst_sr,hp_std_subst_sr,zc_std_subst_sr,hd_std_subst_sr,ns_std_subst_sr,ch_std_subst_sr,zqkhb_std_subst_sr 

from tmp_yz_liq_XQGZ2024093001685_20;

:<<EOF
--创建结果表
drop table if exists ads_yz_liq_XQGZ2024093001685_list purge;
create table ads_yz_liq_XQGZ2024093001685_list
(
city_id int,
cust_id string,
cust_number string,
cust_name string,
create_date string,
party_id string,
party_nbr string,
party_name string,
ccust_id string,
ccust_code string,
ccust_name string,
cust_lx string,
is_vip_cust string,
branch_org string,
ccust_subst_name string,
manage_org string,
ccust_branch_name string,
num decimal(22,0),
is_hmd string,
sh_qr_2023 decimal(22,4),
sh_tc_ycx_2023 decimal(22,4),
sh_qr_202409 decimal(22,4),
sh_tc_ycx_202409 decimal(22,4),
sr_subst string,
sr_tc_ycx_subst string,
sr_th decimal(22,4),
sr_py decimal(22,4),
sr_by decimal(22,4),
sr_yx decimal(22,4),
sr_hz decimal(22,4),
sr_lw decimal(22,4),
sr_hp decimal(22,4),
sr_zc decimal(22,4),
sr_hd decimal(22,4),
sr_ns decimal(22,4),
sr_ch decimal(22,4),
sr_zqkhb decimal(22,4),
lz_sr_subst string,
lz_sr_tc_ycx_subst string,
lz_sr_th decimal(22,4),
lz_sr_py decimal(22,4),
lz_sr_by decimal(22,4),
lz_sr_yx decimal(22,4),
lz_sr_hz decimal(22,4),
lz_sr_lw decimal(22,4),
lz_sr_hp decimal(22,4),
lz_sr_zc decimal(22,4),
lz_sr_hd decimal(22,4),
lz_sr_ns decimal(22,4),
lz_sr_ch decimal(22,4),
lz_sr_zqkhb decimal(22,4),
ld_sr_subst string,
ld_sr_tc_ycx_subst string,
ld_sr_th decimal(22,4),
ld_sr_py decimal(22,4),
ld_sr_by decimal(22,4),
ld_sr_yx decimal(22,4),
ld_sr_hz decimal(22,4),
ld_sr_lw decimal(22,4),
ld_sr_hp decimal(22,4),
ld_sr_zc decimal(22,4),
ld_sr_hd decimal(22,4),
ld_sr_ns decimal(22,4),
ld_sr_ch decimal(22,4),
ld_sr_zqkhb decimal(22,4)
)
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy');  

EOF


"


--20241121  杜文斗  直销局向、直销营服中 客户经理 总收入
drop table if exists tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1 as cust_name 
,b.ccust_id
from zone_gz_yz_3351225714708480 a 
left join (select cust_name,ccust_id,row_number() over(partition by cust_name order by ccust_id) as paixu from dws_yz_tb_mo_custgrp_cust_final) b 
on a.index1=b.cust_name and b.paixu=1;


drop table if exists tmp_yz_liq_02 purge;
create table tmp_yz_liq_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as
select a.* 
,b.ccust_code,b.ccust_name,b.branch_org,b.manage_org
from tmp_yz_liq_01 a 
left join (select ccust_id,ccust_code,ccust_name,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;


drop table tmp_yz_liq_03 purge;
create table tmp_yz_liq_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.org_name as ccust_subst_name 
,c.org_name as ccust_branch_name
from tmp_yz_liq_02 a 
left join (select * from  dwd_yz_dim_org where levs='3') b
on a.branch_org=b.org_id
left join (select * from  dwd_yz_dim_org where levs='4') c
on a.manage_org=c.org_id;


--直销客户经理
drop table tmp_yz_liq_04 purge;
create table tmp_yz_liq_04 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.*
,c.staff_name as owner_name --直销客户经理
from tmp_yz_liq_03 a
left join (select manager_id,ccust_id,
row_number() over(partition by ccust_id order by status_date desc) row_num
from dws_ecust.dws_mo_ccust_management
where city_id='200' and status_cd='1000' and manager_type='DUTY')b
on a.ccust_id = b.ccust_id and b.row_num=1
left join (select staff_id,staff_name,
row_number() over(partition by staff_id order by status_date desc) row_num
from dws_crm_cfguse.dws_staff where city_id=200 and status_cd='1000') c
on b.manager_id=c.staff_id and c.row_num=1;

drop table tmp_yz_liq_05 purge;
create table tmp_yz_liq_05 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select cust_name,sum(fee_new_tax) as sr from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202301 and  par_month_id<=202312
group by cust_name;

drop table tmp_yz_liq_06 purge;
create table tmp_yz_liq_06 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.*,b.sr from tmp_yz_liq_04 a left join tmp_yz_liq_05 b on a.cust_name=b.cust_name;

drop table tmp_yz_liq_07 purge;
create table tmp_yz_liq_07 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.*,row_number() over(order by cust_name) as paixu from tmp_yz_liq_06 a;

--20241122  张晓明  
--优惠资料表取202410到达
drop table if exists zone_gz_yz.tmp_kjkd_gl_dd_0;
create table zone_gz_yz.tmp_kjkd_gl_dd_0 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,cust_nbr,acc_nbr,serv_id,subst_id

from dwd_yz_rpt_comm_cm_msdisc_mon_final
where par_month_id =202410
and prod_offer_id='500046067'
and date_format(limit_date,'yyyyMMdd')>=20241031 ;

drop table if exists zone_gz_yz.tmp_kjkd_gl_dd_1;
create table zone_gz_yz.tmp_kjkd_gl_dd_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as select a.*,b.is_yx,b.subst_name,b.prod_type from 	tmp_kjkd_gl_dd_0 a left join 
(select serv_id,is_yx,par_month_id,subst_name,prod_type from dwm_yz_tb_comm_cm_all_mon_final where par_month_id =202410) b 
on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id;

drop table if exists zone_gz_yz.tmp_kjkd_gl_dd_2;
create table zone_gz_yz.tmp_kjkd_gl_dd_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select a.*,b.z_prod_inst_id 
from tmp_kjkd_gl_dd_1 a 
left join  (select a_prod_inst_id,z_prod_inst_id from  dws_crm_cust.dws_prod_inst_rel_a where city_id=200 ) b 
on a.serv_id=b.a_prod_inst_id;

drop table if exists zone_gz_yz.tmp_kjkd_gl_dd_3;
create table zone_gz_yz.tmp_kjkd_gl_dd_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as	select a.*,b.acc_nbr as z_acc_nbr,b.prod_id
,b.prod_type as z_prod_type,c.is_yx as z_is_yx 
from tmp_kjkd_gl_dd_2 a 
left join (select acc_nbr,serv_id,prod_id,par_month_id,prod_type,is_yx from dwm_yz_tb_comm_cm_all_final where par_month_id=202411) b 
on a.z_prod_inst_id=b.serv_id 
left join (select acc_nbr,serv_id,prod_id,par_month_id,prod_type,is_yx from dwm_yz_tb_comm_cm_all_final where par_month_id=202410) c 
on a.z_prod_inst_id=c.serv_id;

drop table if exists zone_gz_yz.tmp_kjkd_gl_dd_4;
create table zone_gz_yz.tmp_kjkd_gl_dd_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select subst_name,
count(distinct serv_id) as dd_num,
count(distinct case when is_yx=1 then serv_id else null end ) as yx_num,
count(distinct case when is_yx=0 then serv_id else null end ) as fyx_num,
count(distinct case when is_yx=0 and z_prod_inst_id is not null and z_prod_type=40 then serv_id else null end ) as fyx_ygl_num,
count(distinct case when is_yx=0 and z_prod_inst_id is not null and z_prod_type=40 and z_is_yx=1 then z_prod_inst_id else null end ) as fyx_gl_num
from tmp_kjkd_gl_dd_3 
group by subst_name;


--2410校园宽带到达	其中无效	无效部分使用时长≥60分钟数量
drop table if exists tmp_yz_liq_xykd_01 purge;
create table tmp_yz_liq_xykd_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id,is_yx,kd_sc,date_format(open_date,'yyyy') as open_year from view_ads_yz_tb_comm_cm_all_final 
where kd_desc='校园翼起来' and par_month_id=202410 and is_cancel_user=0 and is_cz=1;

drop table if exists tmp_yz_liq_xykd_02 purge;
create table tmp_yz_liq_xykd_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select open_year,count(serv_id) as xykd_dd 
,count(case when is_yx=0 then serv_id else null end) as wx_xykd_dd 
,count(case when is_yx=0 and kd_sc>=60 then serv_id else null end) as wx_xykd_ge60_dd 
from tmp_yz_liq_xykd_01 group by open_year order by open_year;


--20241122  张晓明  
城中村：
9级地址编码：GZ20200508220006，region_type = 城中村，按到达数排序前100的网格，地址打标是129
社区：
9级地址编码：GZ20200508220002，region_type = 城市家庭，按到达数排序前100的网格，地址打标是199
地址标签打了 GZ20230608101030，region_type in ('专业市场'、'商务楼宇'、'产业园区')

drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.obj_id  --9级地址id
,b.label_code  --地址编码
,a.create_date
from  (select distinct obj_id,obj_code,label_id,create_date from dws_grid.dws_grid_label_setting_inst where city_id=200 ) a --地址打标标签
join dws_bss3e_mgr.dws_ss_label_setting b on a.label_id = b.label_id and b.label_code in('GZ20200508220006','GZ20200508220002','GZ20230608101030')  --dws_grid.dws_ss_label_setting 地址打标维表
;

drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*
,row_number() over(partition by label_code,obj_id order by create_date desc ) as paixu
from tmp_yz_liq_1 a;

/*
drop table tmp_yz_liq_3_1 purge;
create table tmp_yz_liq_3_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select distinct b.addr_id,b.grid_unit_code,'GZ20200508220006' as label_code  
from ads_yz_addr_grid_unit_rule_list_final b 
where exists (select cast(c.obj_id as string) 
		from  tmp_yz_liq_2 c where  b.addr_id=cast(c.obj_id as string) and c.label_code='GZ20200508220006') ;
		
insert into table tmp_yz_liq_3_1 
select distinct b.addr_id,b.grid_unit_code,'GZ20200508220002' as label_code  
from ads_yz_addr_grid_unit_rule_list_final b 
where exists (select cast(c.obj_id as string) 
		from  tmp_yz_liq_2 c where  b.addr_id=cast(c.obj_id as string) and c.label_code='GZ20200508220002') ;
		
*/

--9找7
drop table tmp_yz_liq_2_1 purge;
create table tmp_yz_liq_2_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.addr_id_7 
from tmp_yz_liq_2 a 
left join (select distinct id,addr,addr_id_7 from zone_gz_yz.dwd_yz_addr_final where grade=9) b on cast(a.obj_id as decimal(24,0))=b.id; 
--7找网格
drop table tmp_yz_liq_2_2 purge;
create table tmp_yz_liq_2_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.grid_unit_id
from tmp_yz_liq_2_1 a 
left join ads_yz_tyks_addr_7 b on a.addr_id_7=b.addr_id_7 and b.par_month_id=202411;

drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.serv_id,a.cell_code,a.cell_name 
,'GZ20200508220006' as label_code 
from dwm_yz_tb_comm_cm_all_final a  
where a.par_month_id=202411 
and a.is_cancel_user = 0
and a.prod_type = 40
and a.kd_desc = '普通宽带'
and a.mainstream_net_type = 10
and a.is_cz = 1
and coalesce(a.kd_prod_offer_id,'-1') not like '%500046067%' 
and a.region_type='城中村' 
and exists (select distinct b.grid_unit_id from tmp_yz_liq_2_2 b where b.label_code='GZ20200508220006' and a.cell_id=b.grid_unit_id); 

insert into table tmp_yz_liq_3 
select a.serv_id,a.cell_code,a.cell_name 
,'GZ20200508220002' as label_code 
from dwm_yz_tb_comm_cm_all_final a  
where a.par_month_id=202411 
and a.is_cancel_user = 0
and a.prod_type = 40
and a.kd_desc = '普通宽带'
and a.mainstream_net_type = 10
and a.is_cz = 1
and coalesce(a.kd_prod_offer_id,'-1') not like '%500046067%' 
and a.region_type='城市家庭' 
and exists (select distinct b.grid_unit_id from tmp_yz_liq_2_2 b where b.label_code='GZ20200508220002' and a.cell_id=b.grid_unit_id);

insert into table tmp_yz_liq_3 
select a.serv_id,a.cell_code,a.cell_name 
,'GZ20230608101030' as label_code 
from dwm_yz_tb_comm_cm_all_final a  
where a.par_month_id=202411 
and a.is_cancel_user = 0
and a.prod_type = 40
and a.kd_desc = '普通宽带'
and a.mainstream_net_type = 10
and a.is_cz = 1
and coalesce(a.kd_prod_offer_id,'-1') not like '%500046067%' 
and a.region_type in('专业市场','商务楼宇','产业园区')
and exists (select distinct b.grid_unit_id from tmp_yz_liq_2_2 b where b.label_code='GZ20230608101030' and a.cell_id=b.grid_unit_id);

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.label_code,a.cell_code,a.cell_name,count(distinct serv_id) num 
from tmp_yz_liq_3 a where a.label_code='GZ20200508220006' 
group by a.label_code,a.cell_code,a.cell_name;


drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.label_code,a.cell_code,a.cell_name,count(distinct serv_id) num 
from tmp_yz_liq_3 a where a.label_code='GZ20200508220002' 
group by a.label_code,a.cell_code,a.cell_name;

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.label_code,a.cell_code,a.cell_name,count(distinct serv_id) num 
from tmp_yz_liq_3 a where a.label_code='GZ20230608101030' 
group by a.label_code,a.cell_code,a.cell_name;


--20241129  陈展鹏 
2023年累计一次性收入	2023年累计税后收入	
2024年1-10月累计一次性收入	2024年1-10月累计税后收入	
2024年8-10月累计一次性收入	2024年8-10月累计收入	
2024年10月一次性收入	2024年10月累计税后收入 
drop table tmp_yz_dim_XQGZ2024112702112_1 purge;
create table tmp_yz_dim_XQGZ2024112702112_1 as 
select index1 as data_id,index2 as cust_nbr,index3 as cust_name from zone_gz_yz_3351225714708480;

drop table tmp_yz_dim_XQGZ2024112702112_2 purge;
create table tmp_yz_dim_XQGZ2024112702112_2 as 
select index1 as data_id,index2 as ccust_code,index3 as ccust_name from zone_gz_yz_3351225714708480;

drop table tmp_yz_liq_XQGZ2024112702112_1 purge;
create table tmp_yz_liq_XQGZ2024112702112_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,cust_nbr,cust_code, 
sum(a0) as sh_qr,--税后确认收入
sum(a8) as sh_ycx --一次性税后收入
from dwm_srhx_serv_list_mon_final
where par_month_id >= 202301 and par_month_id<=202410
group by par_month_id,cust_nbr,cust_code;

drop table tmp_yz_liq_XQGZ2024112702112_2_1 purge;
create table tmp_yz_liq_XQGZ2024112702112_2_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 'ycxsr_2023' as flag,cust_nbr,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202301 and par_month_id<=202312 group by cust_nbr 
union all 
select 'sr_2023' as flag,cust_nbr,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202301 and par_month_id<=202312 group by cust_nbr 
union all 
select 'ycxsr_202401_202410' as flag,cust_nbr,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202401 and par_month_id<=202410 group by cust_nbr 
union all 
select 'sr_202401_202410' as flag,cust_nbr,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202401 and par_month_id<=202410 group by cust_nbr 
union all 
select 'ycxsr_202408_202410' as flag,cust_nbr,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202408 and par_month_id<=202410 group by cust_nbr 
union all 
select 'sr_202408_202410' as flag,cust_nbr,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202408 and par_month_id<=202410 group by cust_nbr 
union all 
select 'ycxsr_202410' as flag,cust_nbr,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id=202410 group by cust_nbr 
union all 
select 'sr_202410' as flag,cust_nbr,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id=202410 group by cust_nbr 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024112702112_2_2;
create table tmp_yz_liq_XQGZ2024112702112_2_2 as 
select cust_nbr,
str_to_map(concat_ws(',',collect_set(concat_ws('=',flag,cast(sr as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2024112702112_2_1    
group by cust_nbr
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024112702112_2;
create table tmp_yz_liq_XQGZ2024112702112_2 as 
select cust_nbr,
coalesce(cast(map_col[\"ycxsr_2023\"] as decimal(22,2)),0) ycxsr_2023,
coalesce(cast(map_col[\"sr_2023\"] as decimal(22,2)),0) sr_2023,
coalesce(cast(map_col[\"ycxsr_202401_202410\"] as decimal(22,2)),0) ycxsr_202401_202410,			
coalesce(cast(map_col[\"sr_202401_202410\"] as decimal(22,2)),0) sr_202401_202410,
coalesce(cast(map_col[\"ycxsr_202408_202410\"] as decimal(22,2)),0) ycxsr_202408_202410,
coalesce(cast(map_col[\"sr_202408_202410\"] as decimal(22,2)),0) sr_202408_202410,
coalesce(cast(map_col[\"ycxsr_202410\"] as decimal(22,2)),0) ycxsr_202410,
coalesce(cast(map_col[\"sr_202410\"] as decimal(22,2)),0) sr_202410,
current_timestamp() load_date
from tmp_yz_liq_XQGZ2024112702112_2_2
;


drop table tmp_yz_liq_XQGZ2024112702112_3_1 purge;
create table tmp_yz_liq_XQGZ2024112702112_3_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 'ycxsr_2023' as flag,cust_code,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202301 and par_month_id<=202312 group by cust_code 
union all 
select 'sr_2023' as flag,cust_code,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202301 and par_month_id<=202312 group by cust_code 
union all 
select 'ycxsr_202401_202410' as flag,cust_code,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202401 and par_month_id<=202410 group by cust_code 
union all 
select 'sr_202401_202410' as flag,cust_code,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202401 and par_month_id<=202410 group by cust_code 
union all 
select 'ycxsr_202408_202410' as flag,cust_code,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202408 and par_month_id<=202410 group by cust_code 
union all 
select 'sr_202408_202410' as flag,cust_code,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id>=202408 and par_month_id<=202410 group by cust_code 
union all 
select 'ycxsr_202410' as flag,cust_code,sum(sh_ycx) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id=202410 group by cust_code 
union all 
select 'sr_202410' as flag,cust_code,sum(sh_qr) as sr from tmp_yz_liq_XQGZ2024112702112_1 
where par_month_id=202410 group by cust_code 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024112702112_3_2;
create table tmp_yz_liq_XQGZ2024112702112_3_2 as 
select cust_code,
str_to_map(concat_ws(',',collect_set(concat_ws('=',flag,cast(sr as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2024112702112_3_1    
group by cust_code
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2024112702112_3;
create table tmp_yz_liq_XQGZ2024112702112_3 as 
select cust_code,
coalesce(cast(map_col[\"ycxsr_2023\"] as decimal(22,2)),0) ycxsr_2023,
coalesce(cast(map_col[\"sr_2023\"] as decimal(22,2)),0) sr_2023,
coalesce(cast(map_col[\"ycxsr_202401_202410\"] as decimal(22,2)),0) ycxsr_202401_202410,			
coalesce(cast(map_col[\"sr_202401_202410\"] as decimal(22,2)),0) sr_202401_202410,
coalesce(cast(map_col[\"ycxsr_202408_202410\"] as decimal(22,2)),0) ycxsr_202408_202410,
coalesce(cast(map_col[\"sr_202408_202410\"] as decimal(22,2)),0) sr_202408_202410,
coalesce(cast(map_col[\"ycxsr_202410\"] as decimal(22,2)),0) ycxsr_202410,
coalesce(cast(map_col[\"sr_202410\"] as decimal(22,2)),0) sr_202410,
current_timestamp() load_date
from tmp_yz_liq_XQGZ2024112702112_3_2
;

drop table tmp_yz_dim_XQGZ2024112702112_dwb_1 purge;
create table tmp_yz_dim_XQGZ2024112702112_dwb_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.ycxsr_2023,b.sr_2023,b.ycxsr_202401_202410,b.sr_202401_202410 
,b.ycxsr_202408_202410,b.sr_202408_202410,b.ycxsr_202410,b.sr_202410 
from tmp_yz_dim_XQGZ2024112702112_1 a 
left join tmp_yz_liq_XQGZ2024112702112_2 b on a.cust_nbr=b.cust_nbr; 

drop table tmp_yz_dim_XQGZ2024112702112_dwb_2 purge;
create table tmp_yz_dim_XQGZ2024112702112_dwb_2
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.ycxsr_2023,b.sr_2023,b.ycxsr_202401_202410,b.sr_202401_202410 
,b.ycxsr_202408_202410,b.sr_202408_202410,b.ycxsr_202410,b.sr_202410 
from tmp_yz_dim_XQGZ2024112702112_2 a 
left join tmp_yz_liq_XQGZ2024112702112_3 b on a.ccust_code=b.cust_code; 

"

--XQGZ2024093001685  何纬斌  行业标签
/* 
select cust_id,cust_number,cust_name,create_date,
aa.party_id 省内P码ID,
party_nbr P码,
party_name P码名称,
(select ccust_id from mo_ccust m,mo_ccust_part mc where m.ccust_id=mc.ccust_id and rela_objtype='20' 
and mc.moobj_id=p.cust_id) 直销客户ID,
(select ccust_code from mo_ccust m,mo_ccust_part mc where m.ccust_id=mc.ccust_id and rela_objtype='20' 
and mc.moobj_id=p.cust_id) 直销编码,
(select ccust_name from mo_ccust m,mo_ccust_part mc where m.ccust_id=mc.ccust_id and rela_objtype='20' 
and mc.moobj_id=p.cust_id) 直销客户名,
(select CUST_STATE from mo_ccust m,mo_ccust_part mc where m.ccust_id=mc.ccust_id and rela_objtype='20' 
and mc.moobj_id=p.cust_id) 客户类型,
(select vip_flag from mo_ccust m,mo_ccust_part mc where m.ccust_id=mc.ccust_id and rela_objtype='20' 
and mc.moobj_id=p.cust_id) 是否重点客户,
(select branch_org from mo_ccust m,mo_ccust_part mc where m.ccust_id=mc.ccust_id and rela_objtype='20' 
and mc.moobj_id=p.cust_id) 所属局向ID,
(select manage_org from mo_ccust m,mo_ccust_part mc where m.ccust_id=mc.ccust_id and rela_objtype='20' 
and mc.moobj_id=p.cust_id) 所属营服ID,
(select count(1) from prod_inst pt where pt.owner_cust_id=p.cust_id) 业务数量,
( SELECT industry_type_name FROM `industry_type` where industry_type_id=INDUSTRY_TYPE_ID)  集团行业小类,
(SELECT attr_value_name FROM attr_value WHERE attr_id=500048116 AND city_id=200 AND attr_value=CONTROL_DEP
) 集团管控部门,
( SELECT industry_type_name FROM `industry_type` where industry_type_id=PROV_INDUSTRY_SUB)  省行业小类,
(SELECT attr_value_name FROM attr_value WHERE attr_id=500048116 AND city_id=200 AND attr_value=PROV_CONTROL_DEP
)   省管控部门,
( SELECT industry_type_name FROM `industry_type` where industry_type_id=CITY_INDUSTRY_ID)  市行业小类,
(SELECT attr_value_name FROM attr_value WHERE attr_id=500048116 AND city_id=200 AND attr_value=CITY_CONTROL_DEP
) 市管控部门
 from  customber p , party_zq_fcust_rel aa,party_zq bb,party_org_zq cc where p.cust_id=aa.cust_id 
 aa.party_id=bb.party_id and aa.party_id=cc.party_id
 and p.city_Id=200
*/


产权编码、P码、P码名称、省行业管控部门、集团行业小类、省行业小类
drop table tmp_yz_liq_XQGZ2024093001685_hybq_1 purge;
create table tmp_yz_liq_XQGZ2024093001685_hybq_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.cust_id,a.cust_number,a.party_id,a.party_nbr,a.party_name 
,b.PROV_CONTROL_DEP --省管控部门
--,b.CONTROL_DEP --(SELECT attr_value_name FROM dws_crm_cfguse.dws_attr_value WHERE attr_id=500048116 AND city_id=200 AND attr_value=CONTROL_DEP) 集团管控部门,
--,b.CITY_CONTROL_DEP  --市管控部门
--,b.CITY_INDUSTRY_ID  --市行业小类(全部为空，取不到数据) 
,b.PROV_INDUSTRY_SUB   --省行业小类
,b.INDUSTRY_TYPE_ID,c.industry_type_name  --集团行业小类
from ads_yz_liq_XQGZ2024093001685_list a 
left join (select *,row_number() over(partition by party_id order by update_date desc) as paixu 
			from dws_ecust.dws_party_org_zq ) b on a.party_id=b.party_id and b.paixu=1 
left join dws_crm_cfguse.dws_industry_type c on cast(b.INDUSTRY_TYPE_ID  as string)=c.industry_type_id;

drop table tmp_yz_liq_XQGZ2024093001685_hybq purge;
create table tmp_yz_liq_XQGZ2024093001685_hybq
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 200 as city_id,cust_number,party_nbr,party_name 
,PROV_CONTROL_DEP,industry_type_name,PROV_INDUSTRY_SUB from tmp_yz_liq_XQGZ2024093001685_hybq_1;

--20241217  补充一二三级行业标签
drop table tmp_yz_liq_XQGZ2024093001685_hybq_2 purge;
create table tmp_yz_liq_XQGZ2024093001685_hybq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select id3,code3,lev3,grade3,id2,code2,lev2,grade2,id1,code1,lev1,grade1
from 
(select industry_type_id id3,industry_type_code code3,industry_type_name lev3,industry_type_grade grade3,par_industry_type_id from dws_crm_cfguse.dws_industry_type 
where  industry_type_grade=3 and status_cd='1000') a
left join 
(select industry_type_id id2,industry_type_code code2,industry_type_name lev2,industry_type_grade grade2,par_industry_type_id from dws_crm_cfguse.dws_industry_type 
where  industry_type_grade=2 and status_cd='1000') b
on a.par_industry_type_id=b.id2
left join 
(select industry_type_id id1,industry_type_code code1,industry_type_name lev1,industry_type_grade grade1,par_industry_type_id from dws_crm_cfguse.dws_industry_type 
where  industry_type_grade=1 and status_cd='1000') c
on b.par_industry_type_id=c.id1;

drop table tmp_yz_liq_XQGZ2024093001685_hybq_3 purge;
create table tmp_yz_liq_XQGZ2024093001685_hybq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.cust_id,a.cust_number,a.party_id,a.party_nbr,a.party_name 
,b.PROV_CONTROL_DEP --省管控部门
,b.CONTROL_DEP  --集团管控部门,
--,b.CITY_CONTROL_DEP  --市管控部门
--,b.CITY_INDUSTRY_ID  --市行业小类(全部为空，取不到数据) 
,b.PROV_INDUSTRY_SUB   --省行业小类
,b.INDUSTRY_TYPE_ID,c.industry_type_name  --集团行业小类
from ads_yz_liq_XQGZ2024093001685_list a 
left join (select *,row_number() over(partition by party_id order by update_date desc) as paixu 
			from dws_ecust.dws_party_org_zq ) b on a.party_id=b.party_id and b.paixu=1 
left join dws_crm_cfguse.dws_industry_type c on cast(b.INDUSTRY_TYPE_ID  as string)=c.industry_type_id;

drop table tmp_yz_liq_XQGZ2024093001685_hybq_4 purge;
create table tmp_yz_liq_XQGZ2024093001685_hybq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.attr_value_name as jt_gk_bm  --集团管控部门
from tmp_yz_liq_XQGZ2024093001685_hybq_3 a 
left join (SELECT attr_value,attr_value_name FROM dws_crm_cfguse.dws_attr_value WHERE attr_id=500048116 AND city_id=200 ) b 
on a.CONTROL_DEP=b.attr_value 
;

drop table tmp_yz_liq_XQGZ2024093001685_hybq_5 purge;
create table tmp_yz_liq_XQGZ2024093001685_hybq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.lev3 --三级行业标签
,b.lev2 --二级行业标签
,b.lev1 --一级行业标签
from tmp_yz_liq_XQGZ2024093001685_hybq_4 a 
left join tmp_yz_liq_XQGZ2024093001685_hybq_2 b on a.INDUSTRY_TYPE_ID=b.id3 ;

drop table tmp_yz_liq_XQGZ2024093001685_hybq purge;
create table tmp_yz_liq_XQGZ2024093001685_hybq
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 200 as city_id,cust_number,party_nbr,lev1 as party_name  
,lev2 as PROV_CONTROL_DEP,lev3 as industry_type_name,jt_gk_bm as PROV_INDUSTRY_SUB 
from tmp_yz_liq_XQGZ2024093001685_hybq_5;


--左婷   XQGZ2024110400763 需求标题 关于提取商业行业政企客户收入清单的申请  
--抽取产权信息
drop table if exists tmp_yz_liq_XQGZ2024110400763_1 purge;
create table tmp_yz_liq_XQGZ2024110400763_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select cust_id,cust_number,cust_name,create_date 
,row_number() over(partition by cust_number,cust_name order by create_date desc) paixu 
from dws_crm_cust.dws_customer where city_id=200 
;

--直销ID	直销编码	直销客户名	客户类型	是否重点客户	所属局向ID	所属局向	所属营服	所属营服ID
drop table if exists tmp_yz_liq_XQGZ2024110400763_2 purge;
create table tmp_yz_liq_XQGZ2024110400763_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.ccust_id
from tmp_yz_liq_XQGZ2024110400763_1 a 
left join (select cust_nbr,ccust_id,row_number() over(partition by cust_nbr order by ccust_id) as paixu from dws_yz_tb_mo_custgrp_cust_final) b 
on a.cust_number=b.cust_nbr and b.paixu=1
;

drop table if exists tmp_yz_liq_XQGZ2024110400763_3 purge;
create table tmp_yz_liq_XQGZ2024110400763_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as
select a.* 
,b.ccust_code,b.ccust_name,b.vip_flag,b.branch_org,b.manage_org
from tmp_yz_liq_XQGZ2024110400763_2 a 
left join (select ccust_id,ccust_code,ccust_name,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;

drop table tmp_yz_liq_XQGZ2024110400763_4 purge;
create table tmp_yz_liq_XQGZ2024110400763_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.attr_value_name as is_vip_cust 
from tmp_yz_liq_XQGZ2024110400763_3 a 
left join (select attr_id,attr_inner_value,attr_value_name,attr_value_sort  from  dws_crm_cfguse.dws_attr_value where city_id=200
and attr_id='400003971') b on a.vip_flag=b.attr_inner_value
;

drop table tmp_yz_liq_XQGZ2024110400763_5 purge;
create table tmp_yz_liq_XQGZ2024110400763_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.org_name as ccust_subst_name 
,c.org_name as ccust_branch_name
from tmp_yz_liq_XQGZ2024110400763_4 a 
left join (select * from  dwd_yz_dim_org where levs='3') b
on a.branch_org=b.org_id
left join (select * from  dwd_yz_dim_org where levs='4') c
on a.manage_org=c.org_id;

--P码ID	P码（身份证编码）	P码客户名
--产权-P码 1对多,按更新时间最晚取唯一P码
drop table tmp_yz_liq_XQGZ2024110400763_6 purge;
create table tmp_yz_liq_XQGZ2024110400763_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.party_id,c.party_nbr,c.party_name 
from tmp_yz_liq_XQGZ2024110400763_5 a 
left join (select cust_id,party_id,row_number() over(partition by cust_id order by update_date desc) as paixu 
from dws_ecust.dws_party_zq_fcust_rel where city_id=200 ) b 
on a.cust_id=b.cust_id and b.paixu=1
left join dws_ecust.dws_party_zq c on b.party_id=c.party_id and c.city_id=200 
;

drop table tmp_yz_liq_XQGZ2024110400763_7 purge;
create table tmp_yz_liq_XQGZ2024110400763_7
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.PROV_CONTROL_DEP --省管控部门
,b.CONTROL_DEP --集团管控部门,
--,b.CITY_CONTROL_DEP  --市管控部门
--,b.CITY_INDUSTRY_ID  --市行业小类(全部为空，取不到数据) 
,b.PROV_INDUSTRY_SUB   --省行业小类
,b.INDUSTRY_TYPE_ID,c.industry_type_name  --集团行业小类
from tmp_yz_liq_XQGZ2024110400763_6 a 
left join (select *,row_number() over(partition by party_id order by update_date desc) as paixu 
			from dws_ecust.dws_party_org_zq ) b on a.party_id=b.party_id and b.paixu=1 
left join dws_crm_cfguse.dws_industry_type c on cast(b.INDUSTRY_TYPE_ID  as string)=c.industry_type_id;

drop table tmp_yz_liq_XQGZ2024110400763_8 purge;
create table tmp_yz_liq_XQGZ2024110400763_8
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* ,b.attr_value_name as jt_gk_org 
from tmp_yz_liq_XQGZ2024110400763_7 a 
left join (SELECT distinct attr_value,attr_value_name 
				FROM dws_crm_cfguse.dws_attr_value WHERE attr_id=500048116 AND city_id=200) b 
on a.CONTROL_DEP=b.attr_value;

drop table tmp_yz_liq_XQGZ2024110400763_9 purge;
create table tmp_yz_liq_XQGZ2024110400763_9
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select distinct cust_number,ccust_subst_name 
from tmp_yz_liq_XQGZ2024110400763_8 a 
where jt_gk_org='商业客户拓展部' 
and industry_type_name in('快餐服务','培训机构','旅游景区','其他住宿业','石油天然气开采加工','旅游饭店'
,'批发业','其他商务服务','房地产','零售其他','咨询与调查','汽车、摩托车、燃料及零配件专门零售','广告业'
,'医药及医疗器材专门零售','房产中介','修理业','工程技术','燃气及水生产供应','媒体宣传','娱乐其他','租赁业'
,'会议与展览服务','百货零售','便利店零售','电力热力生产供应','理发及美容服务','旅行社','软件业','信息处理'
,'其他制造','文化体育','互联网零售','装修业','其他餐饮业','健康服务','互联网信息服务','正餐服务','商业客户'
,'超级市场零售','网吧','旅游文化') and is_vip_cust='普通商客' ;


--月份	产权客户编码	客户局向	税后确认收入	基本面	双线收入	产数收入	ICT收入	云收入
drop table tmp_yz_liq_XQGZ2024110400763_10 purge;
create table tmp_yz_liq_XQGZ2024110400763_10
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.par_month_id,a.cust_nbr,b.ccust_subst_name,a.a0,a.fee_fm,prod_type_crm_zqb_csp 
from dwm_srhx_serv_list_mon_final_v2_mon a 
join tmp_yz_liq_XQGZ2024110400763_9 b on a.cust_nbr=b.cust_number 
where a.par_month_id>=202301 and a.par_month_id<=202410;

drop table tmp_yz_liq_XQGZ2024110400763_dwb purge;
create table tmp_yz_liq_XQGZ2024110400763_dwb
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 200 as city_id,a.par_month_id,a.cust_nbr,a.ccust_subst_name 
,sum(a0) as sh
,sum(fee_fm) as jbm 
,sum(case when prod_type_crm_zqb_csp in('专线','数字电路','MPLS VPN') then a0 else 0 end) as sx_sh 
,sum(case when prod_type_crm_zqb_csp in('呼叫中心','物联网','智视频','IDC','ICT','光纤出租','数字电路','MPLS VPN','天翼云','中继','政务云') then a0 else 0 end) as cs_sh 
,sum(case when prod_type_crm_zqb_csp in('ICT') then a0 else 0 end) as ict_sh 
,sum(case when prod_type_crm_zqb_csp in('天翼云','政务云') then a0 else 0 end) as yun_sh 
from tmp_yz_liq_XQGZ2024110400763_10 a group by a.par_month_id,a.cust_nbr,a.ccust_subst_name ;

--XQGZ2024121201568 需求标题 申请提取广州人工公话未拆机客户信息用于押金退费 
--先按客户名称匹当前在网的号码，如果取不到，再按号码匹客户名称取号码，如果还取不到就标注，取完之后，把清单给营收匹退款金额
--按客户名称匹当前在网的号码
drop table tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as 
select index1 as id,index2 as acc_nbr,index3 as data_cust_name 
,index4, index5,index6,index7 from zone_gz_yz_285;

drop table tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select '按客户名称匹当前在网的号码' as flag,b.data_cust_name,a.acc_nbr,a.serv_id,a.cust_id  
from dwm_yz_tb_comm_cm_all_final a 
join (select data_cust_name from tmp_yz_liq_1 group by data_cust_name) b 
on a.cust_name=b.data_cust_name and b.data_cust_name<>'' and b.data_cust_name is not null 
where a.par_month_id=202412 and a.is_cancel_user=0 
;

--按号码匹客户名称取号码
drop table tmp_yz_liq_3 purge;
create table tmp_yz_liq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.acc_nbr 
from tmp_yz_liq_1 a 
where not exists (select data_cust_name from tmp_yz_liq_2 b where a.data_cust_name=b.data_cust_name) 
and a.acc_nbr<>'' and a.acc_nbr is not null group by a.acc_nbr;

drop table tmp_yz_liq_4 purge;
create table tmp_yz_liq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.acc_nbr,a.cust_name 
from dwm_yz_tb_comm_cm_all_final a 
join tmp_yz_liq_3 b on a.acc_nbr=b.acc_nbr 
where a.par_month_id=202412 and a.is_cancel_user=0 ;

drop table tmp_yz_liq_5 purge;
create table tmp_yz_liq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select '按号码匹客户名称取号码' as flag,b.acc_nbr as data_acc_nbr,a.cust_name,a.acc_nbr,a.serv_id,a.cust_id  
from dwm_yz_tb_comm_cm_all_final a 
join (select acc_nbr,cust_name from tmp_yz_liq_4 group by acc_nbr,cust_name) b on a.cust_name=b.cust_name 
where a.par_month_id=202412 and a.is_cancel_user=0 ;

drop table tmp_yz_liq_6 purge;
create table tmp_yz_liq_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.* 
from tmp_yz_liq_1 a 
where not exists (select data_cust_name from tmp_yz_liq_2 b where a.data_cust_name=b.data_cust_name) 
and not exists (select data_acc_nbr from tmp_yz_liq_5 c where a.acc_nbr=c.data_acc_nbr);

drop table tmp_yz_XQGZ2024121201568_name purge;
create table tmp_yz_XQGZ2024121201568_name 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select * from tmp_yz_liq_2;

drop table tmp_yz_XQGZ2024121201568_nbr purge;
create table tmp_yz_XQGZ2024121201568_nbr 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select * from tmp_yz_liq_5;

drop table tmp_yz_XQGZ2024121201568 purge;
create table tmp_yz_XQGZ2024121201568  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select '取不到的原表数据' as flag, id,acc_nbr as data_acc_nbr,data_cust_name 
,null as cust_name,null as acc_nbr,null as serv_id,null as cust_id
from tmp_yz_liq_6 

union all 
select flag,null as id,null as data_acc_nbr,data_cust_name,null as cust_name,acc_nbr,serv_id,cust_id 
from tmp_yz_XQGZ2024121201568_name 

union all 
select flag,null as id,data_acc_nbr,null as data_cust_name,cust_name,acc_nbr,serv_id,cust_id 
from tmp_yz_XQGZ2024121201568_nbr;

--20250113  XQGZ2025010700548 需求标题 申请为附件中客户名称匹配对应的BG和BU 
select cust_number,cust_name from dws_crm_cust.dws_customer where city_id=200 
select cust_nbr,bu,bg from dwd_dim_cust_bg_type_2023

--20250115  工单编号 XQGZ2025011500501  张晓明  副宽优惠号码状态
口径：
1、圈定22-14年新入网，且新入网当月办理了“DM0001-944-1-4、DM0001-944-1-8、DM0001-944-1-3、DM0001-944-1-2、DM0001-944-1-1”的接入号；即入网月有办理这4个任意一个的号码
2、在当前最新的状态下，上述销售品已经退订了（即当前月没有这4个销售品），但是接入号未拆机，统计该批号码的数量
3、局向取号码在当前状态的划小局向
select distinct offer_id,prod_offer_code from dws_crm_cfguse.dws_offer 
where city_id=200 
and prod_offer_code in('DM0001-944-1-4','DM0001-944-1-8','DM0001-944-1-3','DM0001-944-1-2','DM0001-944-1-1')
offer_id	prod_offer_code
500070663	DM0001-944-1-3
500072718	DM0001-944-1-4
500070662	DM0001-944-1-2
500072717	DM0001-944-1-1
500076136	DM0001-944-1-8


drop table tmp_yz_liq_XQGZ2025011500501_01 purge;
create table tmp_yz_liq_XQGZ2025011500501_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select serv_id,par_month_id from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202212 and par_month_id<=202412 and is_new_user=1 and is_cancel_user=0;

drop table tmp_yz_liq_XQGZ2025011500501_02 purge;
create table tmp_yz_liq_XQGZ2025011500501_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select par_month_id,serv_id 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where par_month_id>=202212 and par_month_id<=202412 
and prod_offer_id in(500070663,500072718,500070662,500072717,500076136) 
group by par_month_id,serv_id; 

drop table tmp_yz_liq_XQGZ2025011500501_03 purge;
create table tmp_yz_liq_XQGZ2025011500501_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.* 
from tmp_yz_liq_XQGZ2025011500501_01 a 
join tmp_yz_liq_XQGZ2025011500501_02 b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id; 

drop table tmp_yz_liq_XQGZ2025011500501_04 purge;
create table tmp_yz_liq_XQGZ2025011500501_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select serv_id 
from dwd_yz_rpt_comm_cm_msdisc_final a 
where prod_offer_id in(500070663,500072718,500070662,500072717,500076136) 
and date_format(limit_date,'yyyyMMdd') > '20250114'
group by serv_id; 

drop table tmp_yz_liq_XQGZ2025011500501_05 purge;
create table tmp_yz_liq_XQGZ2025011500501_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.prod_type,a.subst_name,a.serv_id ,case when b.serv_id is not null then 1 else 0 end is_bl 
from dwm_yz_tb_comm_cm_all_final a 
left join tmp_yz_liq_XQGZ2025011500501_04 b on a.serv_id=b.serv_id  
where a.par_month_id=202501 and a.is_cancel_user=0 ;

drop table tmp_yz_liq_XQGZ2025011500501_06 purge;
create table tmp_yz_liq_XQGZ2025011500501_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.*  
from tmp_yz_liq_XQGZ2025011500501_05 a 
join (select serv_id from tmp_yz_liq_XQGZ2025011500501_03 group by serv_id) b on a.serv_id=b.serv_id 
where a.is_bl=0 ; 

drop table tmp_yz_liq_XQGZ2025011500501_07 purge;
create table tmp_yz_liq_XQGZ2025011500501_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.*  
from tmp_yz_liq_XQGZ2025011500501_05 a 
join (select serv_id from tmp_yz_liq_XQGZ2025011500501_03 group by serv_id) b on a.serv_id=b.serv_id 
; 

select subst_name,count(distinct serv_id) 
from tmp_yz_liq_XQGZ2025011500501_06 group by subst_name 

select is_bl,subst_name,count(distinct serv_id) 
from tmp_yz_liq_XQGZ2025011500501_07 group by is_bl,subst_name order by is_bl


--多维表2：
1、取主宽号码当前在用销售品 TY143 ，且还在有效期；
2、按销售品的 失效时间 -  生效时间 ，分档有效期是多少年？分为：有效期就≤1年、1年<有效期≤2年、2年<有效期≤3年、3年<有效期 四档
3、字段：有效期、号码数

drop table tmp_yz_liq_XQGZ2025011500501_2_01 purge;
create table tmp_yz_liq_XQGZ2025011500501_2_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select serv_id ,open_date,limit_date 
,cast(cast(Datediff(date_format(limit_date,'yyyy-MM-dd'),date_format(open_date,'yyyy-MM-dd')) as int)/365 as decimal(10,2)) as limit_year 
,row_number() over(partition by serv_id order by create_date desc) as paixu 
from dwd_yz_rpt_comm_cm_msdisc_final a 
where prod_offer_id in(15545) 
and date_format(limit_date,'yyyyMMdd') > '20250114'
; 

drop table tmp_yz_liq_XQGZ2025011500501_2_02 purge;
create table tmp_yz_liq_XQGZ2025011500501_2_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.serv_id 
,case when b.limit_year<=1 then '≤1年' 
      when limit_year>1 and limit_year<=2 then '(1年,2年]' 
	  when limit_year>2 and limit_year<=3 then '(2年,3年]' 
	  when limit_year>3 then '>3年'  else null end as limit_dangci 
from dwm_yz_tb_comm_cm_all_final a 
join tmp_yz_liq_XQGZ2025011500501_2_01 b on a.serv_id=b.serv_id and b.paixu=1  
where a.par_month_id=202501 and a.is_cancel_user=0 and a.kd_desc='普通宽带'; 

select limit_dangci,count(distinct serv_id)  
from tmp_yz_liq_XQGZ2025011500501_2_02 group by limit_dangci

--20250214  移动日报的 ads_yz_rpt_result 已迁移到 ads_yz_rpt_result_ydrb 
--删除以下移动日报编码的报表
--HIVE
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_008');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_009');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_011');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_012');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_016');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_017');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_024');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_025');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_027');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_045');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_060');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_061');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_062');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_063');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_073');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_076');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_087');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_088');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_089');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_090');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_091');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_092');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_093');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YD_D_094');


--pg
delete from ads_yz_rpt_result where  item_nbr in('YD_D_008','YD_D_009','YD_D_011',
'YD_D_012','YD_D_016','YD_D_017','YD_D_024',
'YD_D_025',
'YD_D_027',
'YD_D_045','YD_D_060','YD_D_061','YD_D_062',
'YD_D_063',
'YD_D_073',
'YD_D_076',
'YD_D_087',
'YD_D_088',
'YD_D_089',
'YD_D_090',
'YD_D_091',
'YD_D_092',
'YD_D_093',
'YD_D_094');
commit;

--20250214  宽带新装清单  202501月  清单补打白云部分揽装人的揽装信息
--XQGZ2025020800861 需求标题 关于重跑白云CDAP宽带新装、积分清单的申请 
drop table ads_yz_kd_new_list_202501_bak purge;
create table ads_yz_kd_new_list_202501_bak 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.* from ads_yz_kd_new_list a where par_month_id=202501;


drop table tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id,a.subs_code,a.subs_stat_date
,a.subst_id,a.subst_name,a.branch_id,a.branch_name,a.area_id,a.area_name,a.grid_id,a.grid_code
,a.grid_name,a.region_type,a.std_subst_id,a.std_subst_name,a.std_branch_id,a.std_branch_name
,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type,a.is_mdz,a.six_market
,a.serv_grp_type

,case when b.staff_id is not null then b.sales_code else a.sales_code end as sales_code 
,case when b.staff_id is not null then b.sales_man_name else a.sales_name end as sales_name 
,case when b.staff_id is not null then b.channel_id else a.channel_id end as channel_id
,case when b.staff_id is not null then b.channel_nbr else a.channel_nbr end as channel_nbr
,case when b.staff_id is not null then b.channel_name else a.channel_name end as channel_name
,case when b.staff_id is not null then b.subst_name else a.channel_subst_name end as channel_subst_name
,case when b.staff_id is not null then b.branch_name else a.channel_branch_name end as channel_branch_name

,a.channel_area_name,a.channel_region_type

,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype0_2011,a.state,a.prod_id
,a.is_zhuanxian,a.kd_desc,a.prod_type3,a.prod_type2,a.itv_type,a.kd_prod_offer_id,a.speed_value
,a.jz_points,a.is_rh_ykj,a.rh_tc_value,a.acc_nbr2,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name
,a.cust_code,a.ccust_name,a.ccust_org,a.is_gsm,a.serv_addr_id,a.serv_addr_name,a.addr_id_7
,a.open_date,a.is_sk_xjd,a.is_ljsp,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name
,a.six_market_desc,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx,a.kuayv_offer_name
,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.ycx_offer_type,a.own_operators_nbr,a.own_operators_name
,a.is_zhuangwei,a.is_sheng_yx,a.cdma_disc_type3_name,a.label_name,a.load_date,a.fk_lx
,a.fk_value,a.kd_ll,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce,a.seq_id,a.main_prod_offer_name
,a.is_zxyb,a.is_lb_hy,a.addr_name_7,a.par_month_id,a.par_sum_date 

from ads_yz_kd_new_list a 
left join (select staff_id,sales_code,sales_man_name,channel_id,channel_nbr,channel_name,channel_type,subst_name,branch_name 
           from dwd_yz_sales_man_outlers_final where staff_id in('1150141469','1130101325','1150141368','1150141365'
		   ,'1150141370','1150141485','1150141536','1150141426','1150141544')) b
on a.sales_id=b.staff_id 
where a.par_month_id=202501;

drop table tmp_yz_liq_02 purge;
create table tmp_yz_liq_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') as 
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id,a.subs_code,a.subs_stat_date
,a.subst_id,a.subst_name,a.branch_id,a.branch_name,a.area_id,a.area_name,a.grid_id,a.grid_code
,a.grid_name,a.region_type,a.std_subst_id,a.std_subst_name,a.std_branch_id,a.std_branch_name
,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type,a.is_mdz,a.six_market
,a.serv_grp_type

,a.sales_code 
,a.sales_name 
,a.channel_id
,a.channel_nbr
,a.channel_name
,a.channel_subst_name
,a.channel_branch_name

,case when b.channel_id is not null and  a.sales_id in('1150141469','1130101325','1150141368','1150141365'
		   ,'1150141370','1150141485','1150141536','1150141426','1150141544') then b.area_name else a.channel_area_name end channel_area_name 
,case when b.channel_id is not null and a.sales_id in('1150141469','1130101325','1150141368','1150141365'
		   ,'1150141370','1150141485','1150141536','1150141426','1150141544') then b.own_org_region_type else a.channel_region_type end channel_region_type

,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype0_2011,a.state,a.prod_id
,a.is_zhuanxian,a.kd_desc,a.prod_type3,a.prod_type2,a.itv_type,a.kd_prod_offer_id,a.speed_value
,a.jz_points,a.is_rh_ykj,a.rh_tc_value,a.acc_nbr2,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name
,a.cust_code,a.ccust_name,a.ccust_org,a.is_gsm,a.serv_addr_id,a.serv_addr_name,a.addr_id_7
,a.open_date,a.is_sk_xjd,a.is_ljsp,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name
,a.six_market_desc,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx,a.kuayv_offer_name
,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.ycx_offer_type,a.own_operators_nbr,a.own_operators_name
,a.is_zhuangwei,a.is_sheng_yx,a.cdma_disc_type3_name,a.label_name,a.load_date,a.fk_lx
,a.fk_value,a.kd_ll,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce,a.seq_id,a.main_prod_offer_name
,a.is_zxyb,a.is_lb_hy,a.addr_name_7,a.par_month_id,a.par_sum_date 

from tmp_yz_liq_01 a 
left join dwd_yz_sale_outlers_mon_final b 
on cast(a.channel_id as decimal(22,0))=b.channel_id and b.par_month_id=202501 
;


set hive.vectorized.execution.enabled=false; 
alter table zone_gz_yz.ads_yz_kd_new_list drop partition(par_month_id='202501');
alter table zone_gz_yz.ads_yz_kd_new_list add partition(par_month_id='202501',par_sum_date='20250131');
insert into table zone_gz_yz.ads_yz_kd_new_list partition(par_month_id='202501',par_sum_date='20250131')
(sum_date,month_id,serv_id,acc_nbr,subs_id,
subs_code,subs_stat_date,subst_id,subst_name,branch_id,
branch_name,area_id,area_name,grid_id,grid_code,
grid_name,region_type,std_subst_id,std_subst_name,std_branch_id,
std_branch_name,cell_id,cell_code,cell_name,cell_type_name,
bg_type,bu_type,is_mdz,six_market,serv_grp_type,
sales_code,sales_name,channel_id,channel_nbr,channel_name,
channel_subst_name,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011,
channel_subtype_2011,channel_subtype0_2011,state,prod_id,is_zhuanxian,
kd_desc,prod_type3,prod_type2,itv_type,kd_prod_offer_id,
speed_value,jz_points,is_rh_ykj,rh_tc_value,acc_nbr2,
fttx_type,cust_id,cust_nbr,cust_name,cust_code,
ccust_name,ccust_org,is_gsm,serv_addr_id,serv_addr_name,
addr_id_7,open_date,is_sk_xjd,is_ljsp,is_yqjq,
prod_name,kd_prod_offer_code,kd_prod_offer_name,six_market_desc,serv_grp_type_desc,
channel_subtype_flag,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1,
xx_salestaff_code1,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,
ycx_offer_type,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,
cdma_disc_type3_name,label_name,fk_lx,fk_value,kd_ll,
kd_sc,is_hy,fee_shebei,fee_tiaoce,grid_unit_area_id,
mgr_area_id,is_shangqi_dx,kuayv_offer_name,load_date,
seq_id,main_prod_offer_name,is_zxyb,is_lb_hy,addr_name_7
)
select sum_date,month_id,serv_id,acc_nbr,subs_id,subs_code,subs_stat_date,subst_id,subst_name,branch_id,branch_name,area_id,area_name,grid_id,grid_code,grid_name,region_type,
std_subst_id,std_subst_name,std_branch_id,std_branch_name,cell_id,cell_code,cell_name,cell_type_name,bg_type,bu_type,is_mdz,six_market,serv_grp_type,sales_code,sales_name,
channel_id,channel_nbr,channel_name,channel_subst_name,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011,channel_subtype_2011,channel_subtype0_2011,
state,prod_id,is_zhuanxian,kd_desc,prod_type3,prod_type2,itv_type,kd_prod_offer_id,speed_value,jz_points,is_rh_ykj,rh_tc_value,acc_nbr2,fttx_type,cust_id,cust_nbr,cust_name,
cust_code,ccust_name,ccust_org,is_gsm,serv_addr_id,serv_addr_name,addr_id_7,open_date,is_sk_xjd,is_ljsp,is_yqjq,prod_name,kd_prod_offer_code,kd_prod_offer_name,six_market_desc,
serv_grp_type_desc,channel_subtype_flag,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1,xx_salestaff_code1,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,
ycx_offer_type,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,cdma_disc_type3_name,label_name,fk_lx,fk_value,kd_ll,kd_sc,is_hy,fee_shebei,fee_tiaoce,grid_unit_area_id,
mgr_area_id,is_shangqi_dx,kuayv_offer_name,current_timestamp() load_date,
seq_id,main_prod_offer_name,is_zxyb,is_lb_hy,addr_name_7
from tmp_yz_liq_02 a;

--20250218  宽带日报的 ads_yz_rpt_result 已迁移新表
--删除以下宽带日报编码的数据
--HIVE
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false; 

alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_011');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_030');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_031');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_069');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_029');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='YK_D_004');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_020');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_W_027');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_032');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_W_028');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_081');
alter table ads_yz_rpt_result drop if exists partition(item_nbr='KD_D_009');



--pg
delete from ads_yz_rpt_result where  item_nbr in('KD_D_011',
'KD_D_030',
'KD_D_031',
'KD_D_069',
'KD_D_029',
'YK_D_004',
'KD_D_020',
'KD_W_027',
'KD_D_032',
'KD_W_028',
'KD_D_081',
'KD_D_009');
commit;


--20250228  回溯后数据核查脚本  
select par_month_id,count(1) from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250227  group by par_month_id order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwm_yz_tb_comm_cm_all_mon_final  group by par_month_id order by par_month_id LIMIT 1000
核对结果：数据量一致，核查通过

drop table tmp_yz_liq_02 purge;
create table tmp_yz_liq_02 as 
SELECT par_month_id,is_cancel_user, subst_name, count(1) 
,row_number() over(order by count(1)) as paixu 
FROM dwm_yz_tb_comm_cm_all_mon_final 
GROUP BY par_month_id,is_cancel_user, subst_name 
ORDER BY par_month_id,is_cancel_user, subst_name;

drop table tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 as 
SELECT par_month_id,is_cancel_user, subst_name, count(1) 
,row_number() over(order by count(1)) as paixu
FROM ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250227 
GROUP BY par_month_id,is_cancel_user, subst_name 
ORDER BY par_month_id,is_cancel_user, subst_name ;
核对结果：局向的增减总和为0，核查通过

--【销售部】的回溯前后差异最大，核查回溯前哪里的号码切割进了销售部
drop table tmp_yz_liq_03 purge;
create table tmp_yz_liq_03 as 
SELECT a.par_month_id,b.subst_name, count(1) v1,count(distinct a.serv_id) v2 
FROM ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250227 a 
join dwm_yz_tb_comm_cm_all_mon_final b 
on a.serv_id=b.serv_id 
and a.par_month_id=b.par_month_id 
and a.subst_name='销售部' and coalesce(b.subst_name,'-1')<>'销售部'
GROUP BY a.par_month_id,b.subst_name 
ORDER BY a.par_month_id,b.subst_name ;
大部分是【市公司本部】的号码回溯后落入销售部，属于正常情况

--核查回溯表和基准表的号码标签是否一致
select par_month_id,count(1) from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250227 a 
join ads_yz_2025_ndhs_jz_list b on a.serv_id=b.serv_id and (
coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
or coalesce(a.grid_id,'-99')<>coalesce(b.grid_id,'-99')
or coalesce(a.grid_code,'-99')<>coalesce(b.grid_code,'-99')
or coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')

or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
or coalesce(a.cell_id,'-99')<>coalesce(b.cell_id,'-99')
or coalesce(a.cell_code,'-99')<>coalesce(b.cell_code,'-99')
or coalesce(a.ccenter,'-99')<>coalesce(b.ccenter,'-99')

or coalesce(a.subst_name,'-99')<>coalesce(b.subst_name,'-99')
or coalesce(a.branch_name,'-99')<>coalesce(b.branch_name,'-99')
or coalesce(a.grid_name,'-99')<>coalesce(b.grid_name,'-99')
or coalesce(a.region_type,'-99')<>coalesce(b.region_type,'-99')

or coalesce(a.is_mdz,'-99')<>coalesce(b.is_mdz,'-99')
or coalesce(a.bg_type,'-99')<>coalesce(b.bg_type,'-99')
or coalesce(a.bu_type,'-99')<>coalesce(b.bu_type,'-99')
or coalesce(a.cell_name,'-99')<>coalesce(b.cell_name,'-99')

or coalesce(a.std_subst_name,'-99')<>coalesce(b.std_subst_name,'-99')
or coalesce(a.std_branch_name,'-99')<>coalesce(b.std_branch_name,'-99')
or coalesce(a.area_name,'-99')<>coalesce(b.area_name,'-99')

--or coalesce(a.cell_type,'-99')<>coalesce(b.cell_type,'-99')
--or coalesce(a.cell_type_name,'-99')<>coalesce(b.cell_type_name,'-99')
)
group by par_month_id order by par_month_id
limit 1000
202112月之后的号码标签信息一致，核查通过


--核查不在基准表的号码量，差异很小才正常
select par_month_id,count(1),count(case when b.serv_id is not null then 1 else null end )
from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250227 a
left join ads_yz_2025_ndhs_jz_list b
on a.serv_id=b.serv_id
--where a.grid_id<>-1
group by par_month_id order by par_month_id limit 1000
核查通过

--核查在基准表没有的号码是否以前的责任田都是-1，是则正常
--2025年这部分有异常，可能是一开始的基准表有误删号码，已无法查究，忽略
drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 as 
select a.par_month_id,a.serv_id,a.grid_id 
from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250227 a 
left join ads_yz_2025_ndhs_jz_list b on a.serv_id=b.serv_id 
where b.serv_id is null;

select par_month_id,count(1) c1,
sum(case when grid_id=-1 then 1 else 0 end) c2 
from tmp_yz_liq_1 group by par_month_id,action_id order by par_month_id,action_id limit 1000

--cell_type、cell_type_name漏回溯，新回溯表：ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250228_v2
--查看局向分布是否和 ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250227 一致 
drop table tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 as 
SELECT par_month_id,is_cancel_user, subst_name, count(1) 
,row_number() over(order by count(1)) as paixu
FROM ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250228_v2  
GROUP BY par_month_id,is_cancel_user, subst_name 
ORDER BY par_month_id,is_cancel_user, subst_name ;

--核查cell_type、cell_type_name是否和 tmp_huisu_final_dwm_yz_tb_comm_cm_all_sub13 一致 
select par_month_id,count(1) from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20250228_v2 a
join tmp_huisu_final_dwm_yz_tb_comm_cm_all_sub13 b on a.cell_id=b.cell_id	
and (

 coalesce(a.cell_type,'-99')<>coalesce(b.cell_type,'-99')
or coalesce(a.cell_type_name,'-99')<>coalesce(b.cell_type_name,'-99')

)
group by par_month_id order by par_month_id
limit 1000

select par_month_id,count(distinct a.cell_id),count(distinct case when b.cell_id is not null then a.cell_id  else null end )
from dwm_yz_tb_comm_cm_all_mon_final a
left join tmp_huisu_final_dwm_yz_tb_comm_cm_all_sub13 b
on a.cell_id=b.cell_id	
group by par_month_id order by par_month_id limit 1000
差异很小，核查通过

--20250301  订单表和优惠订单表回溯核查
select par_month_id,count(1) from ads_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_20250228  group by par_month_id  order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwm_yz_rpt_comm_ba_subs_mon_final  group by par_month_id order by par_month_id LIMIT 1000

select par_month_id,count(1) from ads_huisu_dwm_yz_rpt_comm_ba_msdisc_mon_final_20250228  group by par_month_id  order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwm_yz_rpt_comm_ba_msdisc_mon_final  group by par_month_id order by par_month_id LIMIT 1000
核查通过

select par_month_id,count(1) from ads_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_20250228 a
join ads_yz_2025_ndhs_jz_list b on a.serv_id=b.serv_id and (
coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
or coalesce(a.grid_id,'-99')<>coalesce(b.grid_id,'-99')
or coalesce(a.grid_code,'-99')<>coalesce(b.grid_code,'-99')
or coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')

or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
or coalesce(a.cell_id,'-99')<>coalesce(b.cell_id,'-99')
or coalesce(a.cell_code,'-99')<>coalesce(b.cell_code,'-99')
or coalesce(a.ccenter,'-99')<>coalesce(b.ccenter,'-99')

or coalesce(a.subst_name,'-99')<>coalesce(b.subst_name,'-99')
or coalesce(a.std_subst_name,'-99')<>coalesce(b.std_subst_name,'-99')
or coalesce(a.branch_name,'-99')<>coalesce(b.branch_name,'-99')
or coalesce(a.std_branch_name,'-99')<>coalesce(b.std_branch_name,'-99')
or coalesce(a.bg_type,'-99')<>coalesce(b.bg_type,'-99')
or coalesce(a.bu_type,'-99')<>coalesce(b.bu_type,'-99')
or coalesce(a.region_type,'-99')<>coalesce(b.region_type,'-99')
)
group by par_month_id order by par_month_id
limit 1000

select par_month_id,count(1) from ads_huisu_dwm_yz_rpt_comm_ba_msdisc_mon_final_20250228 a
join ads_yz_2025_ndhs_jz_list b on a.serv_id=b.serv_id and (
coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
  or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
  or coalesce(a.cell_id,'-99')<>coalesce(b.cell_id,'-99')
or coalesce(a.cell_code,'-99')<>coalesce(b.cell_code,'-99')
or coalesce(a.grid_id,'-99')<>coalesce(b.grid_id,'-99')
or coalesce(a.grid_code,'-99')<>coalesce(b.grid_code,'-99')
or coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')
  or coalesce(a.bg_type,'-99')<>coalesce(b.bg_type,'-99')
  or coalesce(a.bu_type,'-99')<>coalesce(b.bu_type,'-99')
or coalesce(a.region_type,'-99')<>coalesce(b.region_type,'-99')
)
group by par_month_id order by par_month_id
limit 1000
核查通过

select par_month_id,count(distinct a.serv_id),count(distinct case when b.serv_id is not null then a.serv_id else null end )
from ads_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_20250228 a
left join ads_yz_2025_ndhs_jz_list b
on a.serv_id=b.serv_id
group by par_month_id order by par_month_id

select par_month_id,count(distinct a.serv_id),count(distinct case when b.serv_id is not null then a.serv_id else null end )
from ads_huisu_dwm_yz_rpt_comm_ba_msdisc_mon_final_20250228 a
left join ads_yz_2025_ndhs_jz_list b
on a.serv_id=b.serv_id
group by par_month_id order by par_month_id limit 1000

--核查在基准表没有的号码是否以前的责任田都是-1，是则正常
drop table if exists tmp_yz_liq_1 purge;
create table tmp_yz_liq_1 as 
select a.par_month_id,a.action_id,a.serv_id,a.grid_id 
from ads_huisu_dwm_yz_rpt_comm_ba_subs_mon_final_20250228 a 
left join ads_yz_2025_ndhs_jz_list b on a.serv_id=b.serv_id 
where b.serv_id is null;

select par_month_id,count(1) c1,
sum(case when grid_id=-1 then 1 else 0 end) c2 
from tmp_yz_liq_1 where par_month_id>=202112 group by par_month_id order by par_month_id limit 1000

select par_month_id,action_id,count(1) c1,
sum(case when grid_id=-1 then 1 else 0 end) c2 
from tmp_yz_liq_1 where par_month_id>=202112 
group by par_month_id,action_id order by par_month_id,action_id limit 1000


drop table if exists tmp_yz_liq_2 purge;
create table tmp_yz_liq_2 as 
select a.par_month_id,a.action_id,a.serv_id,a.grid_id 
from ads_huisu_dwm_yz_rpt_comm_ba_msdisc_mon_final_20250228 a 
left join ads_yz_2025_ndhs_jz_list b on a.serv_id=b.serv_id 
where b.serv_id is null;

select par_month_id,action_id,count(1) c1,
sum(case when grid_id=-1 then 1 else 0 end) c2 
from tmp_yz_liq_2 where par_month_id>=202112 
group by par_month_id,action_id order by par_month_id,action_id limit 1000


--20250305 张晓明  24年全年做了这条销售品 DM0002-A01，而且到24年12月还没拆机的数
drop table if exists tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select  serv_id 

from dwd_yz_rpt_comm_cm_msdisc_mon_final
where par_month_id >=202401 and par_month_id<=202412 
and prod_offer_id='5734536'
and date_format(create_date,'yyyy')>='2024' 
group by serv_id;

drop table if exists tmp_yz_liq_02 purge;
create table tmp_yz_liq_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,case when b.serv_id is not null then 1 else 0 end is_yx 
from tmp_yz_liq_01 a 
left join (select serv_id from dwd_yz_rpt_comm_cm_msdisc_mon_final where par_month_id=202412 
and prod_offer_id='5734536'
and date_format(limit_date,'yyyyMMdd')>'20241231'  group by serv_id) b 
on a.serv_id=b.serv_id ;

--20250307  宽带续约清单回溯  
--回溯前备份
drop table if exists ads_yz_kd_xy_list_20250307_bak purge; 
create table ads_yz_kd_xy_list_20250307_bak  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select * from ads_yz_kd_xy_list;


--20250311 XQGZ2025021201047 需求标题 天河宽带净增分析  
drop table if exists tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
SELECT subst_name,branch_name,area_name,count(serv_id) 
from dwm_yz_tb_comm_cm_all_final a 
where par_month_id=202502 
and is_cz=1 and is_cancel_user=0 
and prod_type = 40 and kd_desc='普通宽带' AND coalesce(kd_prod_offer_id,'-1') not like '%500046067%' 
group by subst_name,branch_name,area_name 
; 

drop table if exists tmp_yz_liq_02 purge;
create table tmp_yz_liq_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
SELECT subst_name,branch_name,area_name,count(serv_id) 
from dwm_yz_tb_comm_cm_all_mon_final a 
where par_month_id=202412  
and is_cz=1 and is_cancel_user=0 
and prod_type = 40 and kd_desc='普通宽带' AND coalesce(kd_prod_offer_id,'-1') not like '%500046067%' 
group by subst_name,branch_name,area_name  
;

--20250311 XQGZ2025030700592 需求标题 关于从数据湖获取CRM系统有关字段的需求  
select acc_nbr  --接入号
,case when state='100000' then '在用'
when state='110000' then '拆机'
when state='110009' then '预拆机'
when state='120000' then '停机'
when state='120009' then '停机(预开户)'
when state='130000' then '未竣工'
when state='140000' then '未激活(预开通)'
when state='140001' then '预开通'
when state='140002' then '未激活'
when state='150000' then '撤销'
when state='150009' then '作废'
when state='140003' then '预开通返档激活' else '拆机' end as state_desc --状态 
,speed_value  --速率 
from zone_gz_yz.dwm_yz_tb_comm_cm_all_final --已赋权CDAP客资专区
where par_month_id=202503 
and is_cancel_user=0 
and (acc_nbr like 'ADSLS%' or acc_nbr like 'IPCYW%' or acc_nbr like 'VPN%' ) 

--20250312  白云  核查移动是否办了  prod_offer_id in (500058209,500056186,500056182)
500058209 YD4G02-567-1-3
500056186 YD4G02-567-1-2
500056182 YD4G02-567-1-1

--抽取当前办了9.9销售品的号码
drop table if exists tmp_by_01 purge;
create table tmp_by_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select serv_id,prod_offer_id from view_by_ads_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200' and a.prod_offer_id in (500058209,500056186,500056182) 
and date_format(limit_date,'yyyyMMdd') > '20250311' --当前未失效,limit_date：有效期
group by serv_id,prod_offer_id;

--打标需要核查的号码是否有办理9.9销售品
drop table if exists tmp_by_02 purge;
create table tmp_by_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select a.*
,case when b.serv_id is not null then b.prod_offer_id else null end as is_bl_offer 
from 导入的数据表名 a 
left join tmp_by_01 b on cast(a.serv_id as decimal(22,0))=b.serv_id ;  --a.serv_id: 需要按导入数据表的字段名修改

--输出核查结果，有销售品ID和销售品编码的就是有办理9.9销售品 
drop table if exists tmp_by_03 purge;
create table tmp_by_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select a.index1,index2,index3,index4,index5,index6,index7,index8,index9,index10,is_bl_offer 
,case when is_bl_offer=500058209 then 'YD4G02-567-1-3' 
when is_bl_offer=500056186 then 'YD4G02-567-1-2' 
when is_bl_offer=500056182 then 'YD4G02-567-1-1' 
else null end as offer_9_9 
from tmp_by_02 a;

select * from tmp_by_03 

--20250319  XQGZ2025031800358 需求标题 关于提取24年至今各单位视联网业务收入及业务清单的申请  
--25年新科目
--新提供的科目编码清单
drop table if exists tmp_yz_XQGZ2025031800358_list_1 purge;
create table tmp_yz_XQGZ2025031800358_list_1  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as select 200 as city_id,par_month_id,is_filter,contract_flag
,subst_name,branch_name,bg_type,bu_type
,region_type,due_income_code,due_income_name,acc_nbr,sales_name,cust_nbr,
case when is_mdz = 1 then '是' else '否' end as is_mdz_type,
case when SIX_MARKET = 1 then '校园市场' 
                when SIX_MARKET = 2 then '农村市场'  
                when SIX_MARKET = 3 then '行客市场' 
                when SIX_MARKET = 4 then '商客市场' 
                when SIX_MARKET = 5 then '城市家庭' 
                when SIX_MARKET = 6 then '流动市场' end as SIX_MARKET_desc,
case when region_type in ('城市家庭','城中村','农村') then '公众包区' 
     when region_type in ('商客') then '商客包区'
	 else '其他'
	 end as baoqu_type,
(case when length(a.cust_name)<2 then a.cust_name
              when length(a.cust_name)=2 then concat(SUBSTR(a.cust_name,1,1),'*')
              when length(a.cust_name)>2 then concat(SUBSTR(a.cust_name,1,(length(a.cust_name)-2)),'**')
              else null end) as  cust_name_tm,
prod_name,channel_type_2011,channel_subtype_2011, 
sum(fee_all) as sh
from dwm_srhx_src_income_list_mon a
where par_month_id >= 202401 and par_month_id<=202412 
and (due_income_code like '%SR01230601%' 
or due_income_code like '%SR0123060201%' 
or due_income_code like '%SR0123060202%' 
or due_income_code like '%SR0123060301%' 
or due_income_code like '%SR0123060302%' 
or due_income_code like '%SR01230604%' 
or due_income_code like '%SR0137020101%' 
or due_income_code like '%SR013702010201%' 
or due_income_code like '%SR013702010202%' 
or due_income_code like '%SR013702010203%' 
or due_income_code like '%SR013702010204%' 
or due_income_code like '%SR013702010301%' 
or due_income_code like '%SR013702010302%' 
or due_income_code like '%SR0137020104%' 
or due_income_code like '%SR013702010501%' 
or due_income_code like '%SR013702010502%' 
or due_income_code like '%SR013702010503%' 
or due_income_code like '%SR013702010504%' 
or due_income_code like '%SR013702010505%' 
or due_income_code like '%SR013702010506%' 
or due_income_code like '%SR013702010507%' 
or due_income_code like '%SR013702010508%' 
or due_income_code like '%SR0137020106%' 
or due_income_code like '%SR0137020107%' 
or due_income_code like '%SR013702020201%' 
or due_income_code like '%SR02230601%' 
or due_income_code like '%SR0223060201%' 
or due_income_code like '%SR0223060202%' 
or due_income_code like '%SR0223060301%' 
or due_income_code like '%SR0223060302%' 
or due_income_code like '%SR02230604%' 
or due_income_code like '%SR0237020101%' 
or due_income_code like '%SR023702010201%' 
or due_income_code like '%SR023702010202%' 
or due_income_code like '%SR023702010203%' 
or due_income_code like '%SR023702010204%' 
or due_income_code like '%SR023702010301%' 
or due_income_code like '%SR023702010302%' 
or due_income_code like '%SR0237020104%' 
or due_income_code like '%SR023702010501%' 
or due_income_code like '%SR023702010502%' 
or due_income_code like '%SR023702010503%' 
or due_income_code like '%SR023702010504%' 
or due_income_code like '%SR023702010505%' 
or due_income_code like '%SR023702010506%' 
or due_income_code like '%SR023702010507%' 
or due_income_code like '%SR023702010508%' 
or due_income_code like '%SR0237020106%' 
or due_income_code like '%SR0237020107%' 
or due_income_code like '%SR023702020201%' 
or due_income_code like '%SR03230601%' 
or due_income_code like '%SR0323060201%' 
or due_income_code like '%SR0323060202%' 
or due_income_code like '%SR0323060301%' 
or due_income_code like '%SR0323060302%' 
or due_income_code like '%SR03230604%' 
or due_income_code like '%SR0337020101%' 
or due_income_code like '%SR033702010201%' 
or due_income_code like '%SR033702010202%' 
or due_income_code like '%SR033702010203%' 
or due_income_code like '%SR033702010204%' 
or due_income_code like '%SR033702010301%' 
or due_income_code like '%SR033702010302%' 
or due_income_code like '%SR0337020104%' 
or due_income_code like '%SR033702010501%' 
or due_income_code like '%SR033702010502%' 
or due_income_code like '%SR033702010503%' 
or due_income_code like '%SR033702010504%' 
or due_income_code like '%SR033702010505%' 
or due_income_code like '%SR033702010506%' 
or due_income_code like '%SR033702010507%' 
or due_income_code like '%SR033702010508%' 
or due_income_code like '%SR0337020106%' 
or due_income_code like '%SR0337020107%' 
or due_income_code like '%SR033702020201%' )
group by par_month_id,is_filter,contract_flag,subst_name,branch_name,bg_type,bu_type,region_type,due_income_code,due_income_name,acc_nbr,sales_name,cust_nbr,
case when is_mdz = 1 then '是' else '否' end ,
case when SIX_MARKET = 1 then '校园市场' 
                when SIX_MARKET = 2 then '农村市场'  
                when SIX_MARKET = 3 then '行客市场' 
                when SIX_MARKET = 4 then '商客市场' 
                when SIX_MARKET = 5 then '城市家庭' 
                when SIX_MARKET = 6 then '流动市场' end ,
case when region_type in ('城市家庭','城中村','农村') then '公众包区' 
     when region_type in ('商客') then '商客包区'
	 else '其他'
	 end ,
(case when length(a.cust_name)<2 then a.cust_name
              when length(a.cust_name)=2 then concat(SUBSTR(a.cust_name,1,1),'*')
              when length(a.cust_name)>2 then concat(SUBSTR(a.cust_name,1,(length(a.cust_name)-2)),'**')
              else null end),
prod_name,channel_type_2011,channel_subtype_2011 

union all 
select 200 as city_id,par_month_id,is_filter,contract_flag
,subst_name,branch_name,bg_type,bu_type
,region_type,due_income_code,due_income_name,acc_nbr,sales_name,cust_nbr,
case when is_mdz = 1 then '是' else '否' end as is_mdz_type,
case when SIX_MARKET = 1 then '校园市场' 
                when SIX_MARKET = 2 then '农村市场'  
                when SIX_MARKET = 3 then '行客市场' 
                when SIX_MARKET = 4 then '商客市场' 
                when SIX_MARKET = 5 then '城市家庭' 
                when SIX_MARKET = 6 then '流动市场' end as SIX_MARKET_desc,
case when region_type in ('城市家庭','城中村','农村') then '公众包区' 
     when region_type in ('商客') then '商客包区'
	 else '其他'
	 end as baoqu_type,
(case when length(a.cust_name)<2 then a.cust_name
              when length(a.cust_name)=2 then concat(SUBSTR(a.cust_name,1,1),'*')
              when length(a.cust_name)>2 then concat(SUBSTR(a.cust_name,1,(length(a.cust_name)-2)),'**')
              else null end) as  cust_name_tm,
prod_name,channel_type_2011,channel_subtype_2011, 
sum(fee_all) as sh
from dwm_srhx_src_income_list_mon a
where par_month_id >= 202501 and par_month_id<=202512 
and (due_income_code like '%SR01230601%' 
or due_income_code like '%SR0123060201%' 
or due_income_code like '%SR0123060202%' 
or due_income_code like '%SR0123060301%' 
or due_income_code like '%SR0123060302%' 
or due_income_code like '%SR01230604%' 
or due_income_code like '%SR02230601%' 
or due_income_code like '%SR0223060201%' 
or due_income_code like '%SR0223060202%' 
or due_income_code like '%SR0223060301%' 
or due_income_code like '%SR0223060302%' 
or due_income_code like '%SR02230604%' 
or due_income_code like '%SR03230601%' 
or due_income_code like '%SR0323060201%' 
or due_income_code like '%SR0323060202%' 
or due_income_code like '%SR0323060301%' 
or due_income_code like '%SR0323060302%' 
or due_income_code like '%SR03230604%' 
or due_income_code like '%SR0132060101%' 
or due_income_code like '%SR013206010201%' 
or due_income_code like '%SR013206010202%' 
or due_income_code like '%SR013206010203%' 
or due_income_code like '%SR013206010204%' 
or due_income_code like '%SR013206010301%' 
or due_income_code like '%SR013206010302%' 
or due_income_code like '%SR0132060104%' 
or due_income_code like '%SR013206010501%' 
or due_income_code like '%SR013206010502%' 
or due_income_code like '%SR013206010503%' 
or due_income_code like '%SR013206010504%' 
or due_income_code like '%SR013206010505%' 
or due_income_code like '%SR013206010506%' 
or due_income_code like '%SR013206010507%' 
or due_income_code like '%SR013206010508%' 
or due_income_code like '%SR0132060106%' 
or due_income_code like '%SR0132060107%' 
or due_income_code like '%SR0232060101%' 
or due_income_code like '%SR023206010201%' 
or due_income_code like '%SR023206010202%' 
or due_income_code like '%SR023206010203%' 
or due_income_code like '%SR023206010204%' 
or due_income_code like '%SR023206010301%' 
or due_income_code like '%SR023206010302%' 
or due_income_code like '%SR0232060104%' 
or due_income_code like '%SR023206010501%' 
or due_income_code like '%SR023206010502%' 
or due_income_code like '%SR023206010503%' 
or due_income_code like '%SR023206010504%' 
or due_income_code like '%SR023206010505%' 
or due_income_code like '%SR023206010506%' 
or due_income_code like '%SR023206010507%' 
or due_income_code like '%SR023206010508%' 
or due_income_code like '%SR0232060106%' 
or due_income_code like '%SR0232060107%' 
or due_income_code like '%SR0332060101%' 
or due_income_code like '%SR033206010201%' 
or due_income_code like '%SR033206010202%' 
or due_income_code like '%SR033206010203%' 
or due_income_code like '%SR033206010204%' 
or due_income_code like '%SR033206010301%' 
or due_income_code like '%SR033206010302%' 
or due_income_code like '%SR0332060104%' 
or due_income_code like '%SR033206010501%' 
or due_income_code like '%SR033206010502%' 
or due_income_code like '%SR033206010503%' 
or due_income_code like '%SR033206010504%' 
or due_income_code like '%SR033206010505%' 
or due_income_code like '%SR033206010506%' 
or due_income_code like '%SR033206010507%' 
or due_income_code like '%SR033206010508%' 
or due_income_code like '%SR0332060106%' 
or due_income_code like '%SR0332060107%' 
or due_income_code like '%SR013206020201%' 
or due_income_code like '%SR023206020201%' 
or due_income_code like '%SR033206020201%' )
group by par_month_id,is_filter,contract_flag,subst_name,branch_name,bg_type,bu_type,region_type,due_income_code,due_income_name,acc_nbr,sales_name,cust_nbr,
case when is_mdz = 1 then '是' else '否' end ,
case when SIX_MARKET = 1 then '校园市场' 
                when SIX_MARKET = 2 then '农村市场'  
                when SIX_MARKET = 3 then '行客市场' 
                when SIX_MARKET = 4 then '商客市场' 
                when SIX_MARKET = 5 then '城市家庭' 
                when SIX_MARKET = 6 then '流动市场' end ,
case when region_type in ('城市家庭','城中村','农村') then '公众包区' 
     when region_type in ('商客') then '商客包区'
	 else '其他'
	 end ,
(case when length(a.cust_name)<2 then a.cust_name
              when length(a.cust_name)=2 then concat(SUBSTR(a.cust_name,1,1),'*')
              when length(a.cust_name)>2 then concat(SUBSTR(a.cust_name,1,(length(a.cust_name)-2)),'**')
              else null end),
prod_name,channel_type_2011,channel_subtype_2011;

drop table tmp_yz_XQGZ2025031800358_dwb purge; 
create table tmp_yz_XQGZ2025031800358_dwb as 
select par_month_id,subst_name,bg_type,sum(sh) as sh_sr 
,row_number() over(order by par_month_id,subst_name,bg_type) as paixu 
from tmp_yz_XQGZ2025031800358_list_1 group by par_month_id,subst_name,bg_type;

drop table tmp_yz_XQGZ2025031800358_list purge;
create table tmp_yz_XQGZ2025031800358_list  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select city_id,par_month_id,is_filter,contract_flag,subst_name,branch_name,bg_type,bu_type
,region_type,due_income_code,due_income_name
,(case when length(acc_nbr)<2 then '*'
when length(acc_nbr)=2 then concat(SUBSTR(acc_nbr,1,1),'*')
when length(acc_nbr)<8 then concat(SUBSTR(acc_nbr,1,(length(acc_nbr)-2)),'**')
when length(acc_nbr)>=8 then concat(SUBSTR(acc_nbr,1,length(acc_nbr)-8),'****',SUBSTR(acc_nbr,length(acc_nbr)-3,length(acc_nbr)))
else '*' end) as  acc_nbr 
,sales_name,cust_nbr,is_mdz_type,six_market_desc,baoqu_type,cust_name_tm,prod_name,channel_type_2011,channel_subtype_2011,sh 
from tmp_yz_XQGZ2025031800358_list_1;

drop table tmp_yz_XQGZ2025031800358_list_2 purge;
create table tmp_yz_XQGZ2025031800358_list_2  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select a.* 
,case when cast(cast(a.par_month_id as int)/100 as int)=2024 and a.due_income_code in('SR013702020201','SR023702020201','SR033702020201') then '平安慧眼'  
	  when cast(cast(a.par_month_id as int)/100 as int)=2024 and a.due_income_code in('SR01230601','SR0123060201','SR0123060202','SR0123060301','SR0123060302'
	  ,'SR01230604','SR02230601','SR0223060201','SR0223060202','SR0223060301','SR0223060302','SR02230604'
	  ,'SR03230601','SR0323060201','SR0323060202','SR0323060301','SR0323060302','SR03230604') then '天翼看家'   
	  when cast(cast(a.par_month_id as int)/100 as int)=2024 and a.due_income_code in('SR0137020101','SR013702010201','SR013702010202','SR013702010203','SR013702010204'
	  ,'SR013702010301','SR013702010302','SR0137020104','SR013702010501','SR013702010502','SR013702010503'
	  ,'SR013702010504','SR013702010505','SR013702010506','SR013702010507','SR013702010508','SR0137020106'
	  ,'SR0137020107','SR0237020101','SR023702010201','SR023702010202','SR023702010203','SR023702010204'
	  ,'SR023702010301','SR023702010302','SR0237020104','SR023702010501','SR023702010502','SR023702010503'
	  ,'SR023702010504','SR023702010505','SR023702010506','SR023702010507','SR023702010508','SR0237020106'
	  ,'SR0237020107','SR0337020101','SR033702010201','SR033702010202','SR033702010203','SR033702010204'
	  ,'SR033702010301','SR033702010302','SR0337020104','SR033702010501','SR033702010502','SR033702010503'
	  ,'SR033702010504','SR033702010505','SR033702010506','SR033702010507','SR033702010508','SR0337020106','SR0337020107') then '天翼云眼'  
	  
	  when cast(cast(a.par_month_id as int)/100 as int)=2025 and a.due_income_code in('SR013206020201','SR023206020201','SR033206020201') then '平安慧眼'  
	  when cast(cast(a.par_month_id as int)/100 as int)=2025 and a.due_income_code in('SR01230601','SR0123060201','SR0123060202','SR0123060301','SR0123060302','SR01230604','SR02230601','SR0223060201','SR0223060202','SR0223060301','SR0223060302','SR02230604','SR03230601'
	  ,'SR0323060201','SR0323060202','SR0323060301','SR0323060302','SR03230604') then '天翼看家'   
	  when cast(cast(a.par_month_id as int)/100 as int)=2025 and a.due_income_code in('SR0132060101','SR013206010201','SR013206010202','SR013206010203','SR013206010204','SR013206010301','SR013206010302','SR0132060104','SR013206010501','SR013206010502','SR013206010503','SR013206010504','SR013206010505','SR013206010506','SR013206010507','SR013206010508','SR0132060106','SR0132060107','SR0232060101','SR023206010201','SR023206010202','SR023206010203','SR023206010204','SR023206010301','SR023206010302','SR0232060104','SR023206010501','SR023206010502','SR023206010503','SR023206010504','SR023206010505','SR023206010506','SR023206010507','SR023206010508','SR0232060106','SR0232060107','SR0332060101','SR033206010201','SR033206010202','SR033206010203','SR033206010204','SR033206010301','SR033206010302','SR0332060104','SR033206010501','SR033206010502','SR033206010503','SR033206010504','SR033206010505','SR033206010506','SR033206010507'
	  ,'SR033206010508','SR0332060106','SR0332060107') then '天翼云眼' 
	  else null end as km_type 
from tmp_yz_XQGZ2025031800358_list a ;

drop table tmp_yz_XQGZ2025040902271_dwb_1 purge; 
create table tmp_yz_XQGZ2025040902271_dwb_1  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select par_month_id,subst_name,km_type,sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 group by par_month_id,subst_name,km_type 
union all 

select par_month_id,subst_name,'分局小计',sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 group by par_month_id,subst_name 

union all
select par_month_id,bg_type,km_type,sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 group by par_month_id,bg_type,km_type 

union all  
select par_month_id,bg_type,'分局小计',sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 group by par_month_id,bg_type  

union all  
select par_month_id,'校园中心' bg_type,km_type,sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 where subst_name='政企客户部' and bg_type='教育' group by par_month_id,km_type 

union all  
select par_month_id,'校园中心' bg_type,'分局小计',sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 where subst_name='政企客户部' and bg_type='教育' group by par_month_id  

union all  
select par_month_id,'广州合计' subst_name,km_type,sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 group by par_month_id,km_type 

union all  
select par_month_id,'广州合计' subst_name,'合计',sum(sh) as sh_sr 
from tmp_yz_XQGZ2025031800358_list_2 group by par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_XQGZ2025040902271_dwb_2 purge; 
create table tmp_yz_XQGZ2025040902271_dwb_2  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subst_name,km_type,
str_to_map(concat_ws(',',collect_set(concat_ws('=',par_month_id,cast(sh_sr as string)))),',','=') map_col
from tmp_yz_XQGZ2025040902271_dwb_1    
group by subst_name,km_type 
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_XQGZ2025040902271_dwb_3 purge; 
create table tmp_yz_XQGZ2025040902271_dwb_3  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subst_name,km_type,
coalesce(cast(map_col[\"202401\"] as decimal(30,4)),0) month_202401,
coalesce(cast(map_col[\"202402\"] as decimal(30,4)),0) month_202402,
coalesce(cast(map_col[\"202403\"] as decimal(30,4)),0) month_202403,
coalesce(cast(map_col[\"202404\"] as decimal(30,4)),0) month_202404,
coalesce(cast(map_col[\"202405\"] as decimal(30,4)),0) month_202405,
coalesce(cast(map_col[\"202406\"] as decimal(30,4)),0) month_202406,
coalesce(cast(map_col[\"202407\"] as decimal(30,4)),0) month_202407,
coalesce(cast(map_col[\"202408\"] as decimal(30,4)),0) month_202408,
coalesce(cast(map_col[\"202409\"] as decimal(30,4)),0) month_202409,
coalesce(cast(map_col[\"202410\"] as decimal(30,4)),0) month_202410,
coalesce(cast(map_col[\"202411\"] as decimal(30,4)),0) month_202411,
coalesce(cast(map_col[\"202412\"] as decimal(30,4)),0) month_202412,
coalesce(cast(map_col[\"202501\"] as decimal(30,4)),0) month_202501,
coalesce(cast(map_col[\"202502\"] as decimal(30,4)),0) month_202502,
coalesce(cast(map_col[\"202503\"] as decimal(30,4)),0) month_202503,
coalesce(cast(map_col[\"202504\"] as decimal(30,4)),0) month_202504,
coalesce(cast(map_col[\"202505\"] as decimal(30,4)),0) month_202505,
coalesce(cast(map_col[\"202506\"] as decimal(30,4)),0) month_202506,
coalesce(cast(map_col[\"202507\"] as decimal(30,4)),0) month_202507,
coalesce(cast(map_col[\"202508\"] as decimal(30,4)),0) month_202508,
coalesce(cast(map_col[\"202509\"] as decimal(30,4)),0) month_202509,
coalesce(cast(map_col[\"202510\"] as decimal(30,4)),0) month_202510,
coalesce(cast(map_col[\"202511\"] as decimal(30,4)),0) month_202511,
coalesce(cast(map_col[\"202512\"] as decimal(30,4)),0) month_202512,

current_timestamp() load_date
from tmp_yz_XQGZ2025040902271_dwb_2 
;

drop table tmp_yz_XQGZ2025040902271_dwb_4 purge; 
create table tmp_yz_XQGZ2025040902271_dwb_4  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select case when subst_name='天河分公司' then 1 
when subst_name='番禺分公司' then 2 
when subst_name='白云分公司' then 3 
when subst_name='越秀分公司' then 4  
when subst_name='海珠分公司' then 5 
when subst_name='荔湾分公司' then 6 
when subst_name='黄埔分公司' then 7 
when subst_name='增城分公司' then 8 
when subst_name='花都分公司' then 9 
when subst_name='南沙分公司' then 10 
when subst_name='从化分公司' then 11 

when subst_name='数字政府' then 12 
when subst_name='政法公安' then 13     
when subst_name='文旅综合' then 14     
when subst_name='智慧城市' then 15  
when subst_name='卫健' then 16     
when subst_name='工业制造' then 17   
when subst_name='交通物流' then 18 
when subst_name='金融' then 19   
when subst_name='互联网' then 20    

when subst_name='校园中心' then 21 
when subst_name='广州合计' then 22 
else 23 end as subst_order 

,case when km_type='天翼看家' then 1 
when km_type='天翼云眼' then 2  
when km_type='平安慧眼' then 3 
when km_type='分局小计' then 4 
when km_type='合计' then 5 else 6 end as km_order 
,a.* 
from tmp_yz_XQGZ2025040902271_dwb_3 a;

drop table ads_yz_XQGZ2025040902271_dwb purge; 
create table ads_yz_XQGZ2025040902271_dwb   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subst_name,km_type
,month_202401,month_202402,month_202403,month_202404,month_202405,month_202406
,month_202407,month_202408,month_202409,month_202410,month_202411,month_202412
,month_202501,month_202502,month_202503,month_202504,month_202505,month_202506
,month_202507,month_202508,month_202509,month_202510,month_202511,month_202512
,load_date from tmp_yz_XQGZ2025040902271_dwb_4 
where subst_order<23 order by subst_order,km_order ;


"

--20250320 
XQGZ2025030601558
根据广州分公司地市联系单2025[96]号《关于开展双线存量业务开通未起租清理的通知 》，需对双线业务已受理，在过收费、用户确认工单进行稽核，督办客户经理加快确认起租。特申请业支配合开发数据，具体需求如下：
1、存量：对附件2个excel数据，补充揽装局向，营服/团队、揽装人
2、新增：生成CDAP视图，输入双线未竣工接入号，可自动匹配揽装局向，营服/团队、揽装人字段，用于后续稽核。 

--1、存量：对附件2个excel数据，补充揽装局向，营服/团队、揽装人
drop table tmp_yz_XQGZ2025030601558_01 purge;
create table tmp_yz_XQGZ2025030601558_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subs_id,subs_code, salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
from dwm_yz_rpt_comm_ba_subs_final a 
join zone_gz_yz_3351225714708480 b 
on a.subs_id=cast(b.index4 as decimal(22,0)) and a.acc_nbr=b.index23 
group by subs_id,subs_code, salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id ;

drop table tmp_yz_XQGZ2025030601558_02 purge;
create table tmp_yz_XQGZ2025030601558_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select index1,index2,index3,index4,index5,index6,index7
,index8,index9,index10,index11,index12,index13,index14
,index15,index16,index17,index18,index19,index20,index21
,index22,index23,index24,index25,index26 
,b.salestaff_id,b.sales_code,b.sales_man_name,b.salestaff_subst_id,b.salestaff_branch_id 
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_XQGZ2025030601558_01 b on cast(a.index4 as decimal(22,0))=b.subs_id 
;

drop table tmp_yz_XQGZ2025030601558_03 purge;
create table tmp_yz_XQGZ2025030601558_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select '卡在CRM收费环节和卡在CRM退款环节的清单' flag,a.*,b.org_name as  salestaff_subst_name,c.org_name as  salestaff_branch_name 
from tmp_yz_XQGZ2025030601558_02 a 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) b on a.salestaff_subst_id=b.org_id 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) c on a.salestaff_branch_id=c.org_id 
; 

drop table tmp_yz_XQGZ2025030601558_04 purge;
create table tmp_yz_XQGZ2025030601558_04   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subs_id,subs_code, salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
from dwm_yz_rpt_comm_ba_subs_final a 
join zone_gz_yz_3351225714708480 b 
on a.subs_id=cast(b.index4 as decimal(22,0)) and a.acc_nbr=b.index23 
group by subs_id,subs_code, salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id ;

drop table tmp_yz_XQGZ2025030601558_05 purge;
create table tmp_yz_XQGZ2025030601558_05   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select index1,index2,index3,index4,index5,index6,index7
,index8,index9,index10,index11,index12,index13,index14
,index15,index16,index17,index18,index19,index20,index21
,index22,index23,index24,index25,index26 
,b.salestaff_id,b.sales_code,b.sales_man_name,b.salestaff_subst_id,b.salestaff_branch_id 
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_XQGZ2025030601558_04 b on cast(a.index4 as decimal(22,0))=b.subs_id 
;

drop table tmp_yz_XQGZ2025030601558_06 purge;
create table tmp_yz_XQGZ2025030601558_06   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select '全量在途单的用户确认环节' flag,a.*,b.org_name as  salestaff_subst_name,c.org_name as  salestaff_branch_name 
from tmp_yz_XQGZ2025030601558_05 a 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) b on a.salestaff_subst_id=b.org_id 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) c on a.salestaff_branch_id=c.org_id 
; 

drop table ads_yz_XQGZ2025030601558_list purge;
create table ads_yz_XQGZ2025030601558_list   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as  
select a.* from tmp_yz_XQGZ2025030601558_03 a  
union all 
select a.* from tmp_yz_XQGZ2025030601558_06 a;

--2、新增：生成CDAP视图，输入双线未竣工接入号，可自动匹配揽装局向，营服/团队、揽装人字段，用于后续稽核。 
drop view view_ads_yz_XQGZ2025030601558_xz_sxsl;
create view view_ads_yz_XQGZ2025030601558_xz_sxsl as 
select subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end action_type_desc 
,subs_stat_date ,act_date,a.action_id,b.action_name  
,c.org_name as  salestaff_subst_name,d.org_name as  salestaff_branch_name 
from view_dwm_yz_rpt_comm_ba_subs_final a 
left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
on a.action_id=b.action_id 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) c on a.salestaff_subst_id=c.org_id 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) d on a.salestaff_branch_id=d.org_id 
where a.prod_id in (48,52,57,600039000,54,600032006,219,600031025,600031024,600019010,600032007,500002440,600017007,600018006,500005480,600016002,
		80,218,600030013,600030012,600016001,600031026,600031023,600017005,600030009,600029022,768,769) 
and a.subs_stat not in( '301200','499999')
and a.subs_stat_reason not in( '1200','1300' )  --非撤单/非作废 
group by subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end  
,subs_stat_date ,act_date,a.action_id,b.action_name,c.org_name,d.org_name ;


--XQGZ2025031901988  关于越秀每月导出划小收入清单用于经营分析 
drop view zone_gz_yz.view_yx_ads_srhx_serv_list_mon;
create view zone_gz_yz.view_yx_ads_srhx_serv_list_mon as 
select 200 as city_id, month_id, serv_id, prod_id, subst_id, branch_id, area_id
, grid_id, kh_subst_id, a0, a0_sq, a0_sj, a0_fsg, a0_fsg_sq, a0_fsg_sj, a0_sg
, a0_sg_sq, a0_sg_sj, fee_nbr_sq, fee_nbr, fee_nonbr_sq, fee_nonbr, fee_cs_sq
, fee_cs, a1_sq, a1, a2_sq, a2, a3_sq, a3, a4_sq, a4, a5_sq, a5, a6_sq, a6, a7_sq
, a7, a8_sq, a8, a9_sq, a9, a10_sq, a10, a11_sq, a11, a12_sq, a12, a13_sq, a13
, zq_charge_sq, zq_charge, b1_sq, b1, b2_sq, b2, b3_sq, b3, b4_sq, b4, b5_sq
, b5, b6_sq, b6, fee_cs_sq_ycx, fee_cs_ycx, a0_ycx, a0_sq_ycx, subst_name
, kh_subst_name, branch_name, area_code, area_name, grid_code, grid_name
, prod_name, is_std_org, is_cancel_user, acc_nbr, acc_nbr2, std_subst_id
, std_subst_name, std_branch_id, std_branch_name, cell_id, cell_code, cell_name
, cell_type, cell_type_name, region_type, serv_grp_type, bg_type, bu_type, six_market
, is_school_market_user, is_village_market_user, prod_type, prod_type2, cust_id, cust_nbr 
, --cust_name 
,cust_create_date, ccust_id, cust_code
, --ccust_name 
,ccust_org, ccust_create_date, is_mdz, vpn_value, speed_value, open_date
, hist_create_date, sales_id, sales_code, sales_name, channel_id, channel_nbr
, channel_name, channel_subst_name, channel_branch_name, channel_type, serv_col2
, serv_col2_code, serv_col2_name, channel_type_2011, channel_subtype0_2011
, channel_subtype_2011, channel_subtype_flag, cdma_disc_type, cdma_disc_desc
, kd_prod_offer_id, kd_prod_offer_name, kd_desc, is_rh_ykj, rh_tc_id, rh_type_ykj
, itv_type, is_vice_card, zk_serv_id, is_new_user, state, star_level, is_cz, is_cz_last
, is_yx, is_hy, is_contract, jz_points, tc_points, rh_tc_value, zk_open_date, operators_nbr
, operators_name, is_5g_disc, kd_serv_id, kd_acc_nbr, kd_subst_id, kd_branch_id, kd_cell_code
, kd_cell_name, kd_subst_name, kd_branch_name, yd_prod_type1, yd_prod_type2, is_gsm, payment_id
, payment_type, payment_method_desc, rw_month, new_flag, prod_name_csp_crm, is_zqb_guishang_zx
, is_shangke_guishang_zx, is_yuan_mingdanzhi_shangke_cq, is_region_top50_cq, due_type
, fee_fm, fee_fm_sq, load_date, fee_fm_tz, fee_fm_new 
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where subst_id in (10061,10006) 
and par_month_id=date_format(add_months(from_unixtime(unix_timestamp(current_timestamp(),'yyyyMMdd'),'yyyy-MM-dd'), -1),'YYYYMM') 
;

--2021-2024年电信用户指标
SELECT par_month_id,
  subst_name,
  count(
    CASE
      WHEN prod_type = 10 THEN serv_id
      ELSE NULL
    END
  ) AS gh,
  count(
    CASE
      WHEN prod_type = 30 THEN serv_id
      ELSE NULL
    END
  ) AS yd,
  count(
    CASE
      WHEN prod_type = 40 THEN serv_id
      ELSE NULL
    END
  ) AS kd
FROM
  dwm_yz_tb_comm_cm_all_mon_final
WHERE
  par_month_id in(202112,202212,202312, 202412)
  AND is_cancel_user = 0
  AND is_cz = 1
GROUP BY
  par_month_id,subst_name
LIMIT
  1000
  
--20250416  XQGZ2025041402502 需求标题 提取24年和25年各县分和BG视联网业务收入（分科目）的申请 

drop table tmp_yz_XQGZ2025041402502_list_2 purge;
create table tmp_yz_XQGZ2025041402502_list_2  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select a.* 
,case when cast(cast(a.par_month_id as int)/100 as int)=2024 and a.due_income_code in('SR01230604','SR02230604','SR03230604') then 'AI公众服务收入'  
	  when cast(cast(a.par_month_id as int)/100 as int)=2024 and a.due_income_code in('SR013702010201','SR023702010201','SR033702010201') then '基础功能服务收入'   
	  when cast(cast(a.par_month_id as int)/100 as int)=2024 and a.due_income_code in('SR013702010302','SR023702010302','SR033702010302') then '月付型礼包云回看服务收入' 
	  when cast(cast(a.par_month_id as int)/100 as int)=2024 and a.due_income_code in('SR013702010502','SR023702010502','SR033702010502') then '明厨亮灶' 
	  
	  when cast(cast(a.par_month_id as int)/100 as int)=2025 and a.due_income_code in('SR01230604','SR02230604','SR03230604') then 'AI公众服务收入'  
	  when cast(cast(a.par_month_id as int)/100 as int)=2025 and a.due_income_code in('SR013206010201','SR023206010201','SR033206010201') then '基础功能服务收入'   
	  when cast(cast(a.par_month_id as int)/100 as int)=2025 and a.due_income_code in('SR013206010502','SR023206010502','SR033206010502') then '明厨亮灶' 
	  else null end as km_type 
from tmp_yz_XQGZ2025031800358_list a ;

drop table tmp_yz_XQGZ2025041402502_dwb_1 purge; 
create table tmp_yz_XQGZ2025041402502_dwb_1  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select par_month_id,subst_name,km_type,sum(sh) as sh_sr 
from tmp_yz_XQGZ2025041402502_list_2 group by par_month_id,subst_name,km_type 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_XQGZ2025041402502_dwb_2 purge; 
create table tmp_yz_XQGZ2025041402502_dwb_2  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subst_name,km_type,
str_to_map(concat_ws(',',collect_set(concat_ws('=',par_month_id,cast(sh_sr as string)))),',','=') map_col
from tmp_yz_XQGZ2025041402502_dwb_1    
group by subst_name,km_type 
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_XQGZ2025041402502_dwb_3 purge; 
create table tmp_yz_XQGZ2025041402502_dwb_3  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subst_name,km_type,
coalesce(cast(map_col[\"202401\"] as decimal(30,4)),0) month_202401,
coalesce(cast(map_col[\"202402\"] as decimal(30,4)),0) month_202402,
coalesce(cast(map_col[\"202403\"] as decimal(30,4)),0) month_202403,
coalesce(cast(map_col[\"202404\"] as decimal(30,4)),0) month_202404,
coalesce(cast(map_col[\"202405\"] as decimal(30,4)),0) month_202405,
coalesce(cast(map_col[\"202406\"] as decimal(30,4)),0) month_202406,
coalesce(cast(map_col[\"202407\"] as decimal(30,4)),0) month_202407,
coalesce(cast(map_col[\"202408\"] as decimal(30,4)),0) month_202408,
coalesce(cast(map_col[\"202409\"] as decimal(30,4)),0) month_202409,
coalesce(cast(map_col[\"202410\"] as decimal(30,4)),0) month_202410,
coalesce(cast(map_col[\"202411\"] as decimal(30,4)),0) month_202411,
coalesce(cast(map_col[\"202412\"] as decimal(30,4)),0) month_202412,
coalesce(cast(map_col[\"202501\"] as decimal(30,4)),0) month_202501,
coalesce(cast(map_col[\"202502\"] as decimal(30,4)),0) month_202502,
coalesce(cast(map_col[\"202503\"] as decimal(30,4)),0) month_202503,
coalesce(cast(map_col[\"202504\"] as decimal(30,4)),0) month_202504,
coalesce(cast(map_col[\"202505\"] as decimal(30,4)),0) month_202505,
coalesce(cast(map_col[\"202506\"] as decimal(30,4)),0) month_202506,
coalesce(cast(map_col[\"202507\"] as decimal(30,4)),0) month_202507,
coalesce(cast(map_col[\"202508\"] as decimal(30,4)),0) month_202508,
coalesce(cast(map_col[\"202509\"] as decimal(30,4)),0) month_202509,
coalesce(cast(map_col[\"202510\"] as decimal(30,4)),0) month_202510,
coalesce(cast(map_col[\"202511\"] as decimal(30,4)),0) month_202511,
coalesce(cast(map_col[\"202512\"] as decimal(30,4)),0) month_202512,

current_timestamp() load_date
from tmp_yz_XQGZ2025041402502_dwb_2 
;

drop table tmp_yz_XQGZ2025041402502_dwb_4 purge; 
create table tmp_yz_XQGZ2025041402502_dwb_4  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select case when subst_name='天河分公司' then 1 
when subst_name='番禺分公司' then 2 
when subst_name='白云分公司' then 3 
when subst_name='越秀分公司' then 4  
when subst_name='海珠分公司' then 5 
when subst_name='荔湾分公司' then 6 
when subst_name='黄埔分公司' then 7 
when subst_name='增城分公司' then 8 
when subst_name='花都分公司' then 9 
when subst_name='南沙分公司' then 10 
when subst_name='从化分公司' then 11 

else 12 end as subst_order 

,case when km_type='AI公众服务收入' then 1 
when km_type='基础功能服务收入' then 2  
when km_type='月付型礼包云回看服务收入' then 3 
when km_type='明厨亮灶' then 4 
else 5 end as km_order 
,a.* 
from tmp_yz_XQGZ2025041402502_dwb_3 a;

drop table ads_yz_XQGZ2025041402502_dwb purge; 
create table ads_yz_XQGZ2025041402502_dwb   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select subst_name,km_type
,month_202401,month_202402,month_202403,month_202404,month_202405,month_202406
,month_202407,month_202408,month_202409,month_202410,month_202411,month_202412
,month_202501,month_202502,month_202503,month_202504,month_202505,month_202506
,month_202507,month_202508,month_202509,month_202510,month_202511,month_202512
,load_date from tmp_yz_XQGZ2025041402502_dwb_4 
where subst_order<12 order by subst_order,km_order ;



"


--20250421  XQGZ2025032101251 需求标题 CDAP清单字段申请  
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_tb_cljy_kd_qffj_list_01 purge;
create table tmp_yz_tb_cljy_kd_qffj_list_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* from yz_label.tb_cljy_kd_qffj_list a 
where cast(par_day_id as int)>=20240131 and par_corp_id=200 
and (substr(par_day_id,5,8) in ('0131','0228','0229','0331','0430','0531','0630','0731','0831','0930','1031','1130','1231') 
		or par_day_id=${yyyymmdd} or cast(par_day_id as int)=cast(${yyyymmdd} as int)-1)
;

set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_tb_cljy_kd_qffj_list_02 purge;
create table tmp_yz_tb_cljy_kd_qffj_list_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id,par_month_id,open_date,rh_tc_value,is_gsm 
from zone_gz_yz.dwm_yz_tb_comm_cm_all_final 
where par_month_id>=(case when mod(cast(${yyyymm} as int),100)<>1 then (cast(${yyyymm} as int)-1) else (cast(${yyyymm} as int)-89) end);

set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table ads_yz_tb_cljy_kd_qffj_list purge;
create table ads_yz_tb_cljy_kd_qffj_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* ,b.open_date ,c.rh_tc_value,case when b.is_gsm=1 then '公司名' else '个人名' end is_gsm_desc  
from tmp_yz_tb_cljy_kd_qffj_list_01 a
left join tmp_yz_tb_cljy_kd_qffj_list_02 b
on a.serv_id=b.serv_id and cast(cast(a.par_day_id as int)/100 as int)=cast(b.par_month_id as int) 
left join tmp_yz_tb_cljy_kd_qffj_list_02 c
on a.serv_id=c.serv_id and cast(c.par_month_id as int)=(case when mod(cast(cast(a.par_day_id as int)/100 as int),100)<>1 then (cast(cast(a.par_day_id as int)/100 as int)-1)
		else (cast(cast(a.par_day_id as int)/100 as int)-89) end) 
;

drop view view_tb_cljy_kd_qffj_list;
create view view_tb_cljy_kd_qffj_list as 
select a.* from ads_yz_tb_cljy_kd_qffj_list a;


--XQGZ2025042501409 林秀云
drop table tmp_yz_XQGZ2025042501409_01 purge;
create table tmp_yz_XQGZ2025042501409_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select '移出城中村' as flag,a.par_month_id,a.area_id_last as area_id,a.serv_id,b.prod_type 
from dwd_yz_rpt_comm_ba_subs_move_final a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=202503  
where a.par_month_id=202504 
and a.area_id not in (940287846,940287848,940287850,940287777,940287853,940287867,940287868,940287861,940287860,3000083514,940287854,3000115370,3000115372,3000115374,3000115376,3000115378,3000115380,3000115409,3000115411,3000115413,3000115415,3000115392,3000115393,3000115395,3000115397,3000115399,3000115401,3000115403,3000115405,3000115407,3000115417,3000115419,3000115421,3000115382,3000115384,3000115386,3000115388,3000115390,3000115279,3000115280,3000115281,3000115283,3000115284,3000115318,3000115320,3000115322,3000115296,3000115298,3000115297,3000115300,3000115295,3000115294,3000115309,3000115313,3000115311,3000115303,3000115302,3000115288,3000115290,3000115286,3000115287,3000115289,3000115292,3000115293,3000115291,3000115285,3000115305,3000115304,3000115308,3000115307,940288898,940288899,940288919,940288907,940288741,940288743,940288777,940288840,940288902,940288837,940291675,940291679,940286592,940286584,940286588,940286580,3000083515,940287541,3000083526,940287665,940281961,940281960,940281932,940287528,940281930,3000115455,940286518,940286517,940286506,3000085183,940286521,940286523,3000083447,940286487,940286526,940286525,940286552,940286555,940287446,940287420,940287449,940287444,940287450,940287451,940287480,940287441,940287434,940287432,3000083450,3000083451,940287294,940287297,940287298,940287308,940287311) 
and a.area_id_last in(940287846,940287848,940287850,940287777,940287853,940287867,940287868,940287861,940287860,3000083514,940287854,3000115370,3000115372,3000115374,3000115376,3000115378,3000115380,3000115409,3000115411,3000115413,3000115415,3000115392,3000115393,3000115395,3000115397,3000115399,3000115401,3000115403,3000115405,3000115407,3000115417,3000115419,3000115421,3000115382,3000115384,3000115386,3000115388,3000115390,3000115279,3000115280,3000115281,3000115283,3000115284,3000115318,3000115320,3000115322,3000115296,3000115298,3000115297,3000115300,3000115295,3000115294,3000115309,3000115313,3000115311,3000115303,3000115302,3000115288,3000115290,3000115286,3000115287,3000115289,3000115292,3000115293,3000115291,3000115285,3000115305,3000115304,3000115308,3000115307,940288898,940288899,940288919,940288907,940288741,940288743,940288777,940288840,940288902,940288837,940291675,940291679,940286592,940286584,940286588,940286580,3000083515,940287541,3000083526,940287665,940281961,940281960,940281932,940287528,940281930,3000115455,940286518,940286517,940286506,3000085183,940286521,940286523,3000083447,940286487,940286526,940286525,940286552,940286555,940287446,940287420,940287449,940287444,940287450,940287451,940287480,940287441,940287434,940287432,3000083450,3000083451,940287294,940287297,940287298,940287308,940287311) 

union all 
select '移入城中村' as flag,a.par_month_id,a.area_id,a.serv_id,b.prod_type 
from dwd_yz_rpt_comm_ba_subs_move_final a 
left join dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and b.par_month_id=202504   
where a.par_month_id=202504 
and a.area_id in (940287846,940287848,940287850,940287777,940287853,940287867,940287868,940287861,940287860,3000083514,940287854,3000115370,3000115372,3000115374,3000115376,3000115378,3000115380,3000115409,3000115411,3000115413,3000115415,3000115392,3000115393,3000115395,3000115397,3000115399,3000115401,3000115403,3000115405,3000115407,3000115417,3000115419,3000115421,3000115382,3000115384,3000115386,3000115388,3000115390,3000115279,3000115280,3000115281,3000115283,3000115284,3000115318,3000115320,3000115322,3000115296,3000115298,3000115297,3000115300,3000115295,3000115294,3000115309,3000115313,3000115311,3000115303,3000115302,3000115288,3000115290,3000115286,3000115287,3000115289,3000115292,3000115293,3000115291,3000115285,3000115305,3000115304,3000115308,3000115307,940288898,940288899,940288919,940288907,940288741,940288743,940288777,940288840,940288902,940288837,940291675,940291679,940286592,940286584,940286588,940286580,3000083515,940287541,3000083526,940287665,940281961,940281960,940281932,940287528,940281930,3000115455,940286518,940286517,940286506,3000085183,940286521,940286523,3000083447,940286487,940286526,940286525,940286552,940286555,940287446,940287420,940287449,940287444,940287450,940287451,940287480,940287441,940287434,940287432,3000083450,3000083451,940287294,940287297,940287298,940287308,940287311) 
and a.area_id_last not in(940287846,940287848,940287850,940287777,940287853,940287867,940287868,940287861,940287860,3000083514,940287854,3000115370,3000115372,3000115374,3000115376,3000115378,3000115380,3000115409,3000115411,3000115413,3000115415,3000115392,3000115393,3000115395,3000115397,3000115399,3000115401,3000115403,3000115405,3000115407,3000115417,3000115419,3000115421,3000115382,3000115384,3000115386,3000115388,3000115390,3000115279,3000115280,3000115281,3000115283,3000115284,3000115318,3000115320,3000115322,3000115296,3000115298,3000115297,3000115300,3000115295,3000115294,3000115309,3000115313,3000115311,3000115303,3000115302,3000115288,3000115290,3000115286,3000115287,3000115289,3000115292,3000115293,3000115291,3000115285,3000115305,3000115304,3000115308,3000115307,940288898,940288899,940288919,940288907,940288741,940288743,940288777,940288840,940288902,940288837,940291675,940291679,940286592,940286584,940286588,940286580,3000083515,940287541,3000083526,940287665,940281961,940281960,940281932,940287528,940281930,3000115455,940286518,940286517,940286506,3000085183,940286521,940286523,3000083447,940286487,940286526,940286525,940286552,940286555,940287446,940287420,940287449,940287444,940287450,940287451,940287480,940287441,940287434,940287432,3000083450,3000083451,940287294,940287297,940287298,940287308,940287311) 
; 

drop table tmp_yz_XQGZ2025042501409_dwb purge;
create table tmp_yz_XQGZ2025042501409_dwb   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.par_month_id,a.area_id
,count(distinct case when flag='移出城中村' then a.serv_id else null end) as yc_kd_num 
,count(distinct case when flag='移入城中村' then a.serv_id else null end) as yr_kd_num 
from tmp_yz_XQGZ2025042501409_01 a where prod_type=40 group by a.par_month_id,a.area_id ;


--XQGZ2025042102235 需求标题 关于万联证券双线收入号码清单提取的问题 
drop table tmp_yz_XQGZ2025042102235_01 purge;
create table tmp_yz_XQGZ2025042102235_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
SELECT month_id,cust_nbr,serv_id,(case when length(acc_nbr)<2 then '*'
              when length(acc_nbr)=2 then concat(SUBSTR(acc_nbr,1,1),'*')
              when length(acc_nbr)<8 then concat(SUBSTR(acc_nbr,1,(length(acc_nbr)-2)),'**')
              when length(acc_nbr)>=8 then concat(SUBSTR(acc_nbr,1,length(acc_nbr)-8),'****',SUBSTR(acc_nbr,length(acc_nbr)-3,length(acc_nbr)))
              else '*' end) as  acc_nbr_tm,prod_id 
, sum(a0) AS sx_sr  
FROM zone_gz_yz.dwm_srhx_serv_list_mon_final_v2_mon 
WHERE month_id>=202409 and month_id<=202412 
AND coalesce(a0, 0) <> 0 
AND ((bg_type <> '其他' AND bg_type IS NOT NULL) OR subst_id = 500730 OR vpn_value = '009326523667') 
AND cust_nbr in('3020019855360000','2020335162450000','2930216337790000') 
and prod_id in(57,218,54,48,600019010,600016002,500002440,56,36
,500005480,34,2508,35,105,37,1057,52,810,33,80,2509,1100,44
,43,600018006,40,104,219,2507,628,600031025,600030013,600031024
,600030012,600032007,600031026,600031023,600032006,600016001,600017007,600017005,600039000,600030009) 
group by month_id,cust_nbr,serv_id,(case when length(acc_nbr)<2 then '*'
              when length(acc_nbr)=2 then concat(SUBSTR(acc_nbr,1,1),'*')
              when length(acc_nbr)<8 then concat(SUBSTR(acc_nbr,1,(length(acc_nbr)-2)),'**')
              when length(acc_nbr)>=8 then concat(SUBSTR(acc_nbr,1,length(acc_nbr)-8),'****',SUBSTR(acc_nbr,length(acc_nbr)-3,length(acc_nbr)))
              else '*' end),prod_id 
;

SELECT month_id,cust_nbr,serv_id,(case when length(acc_nbr)<2 then '*'
              when length(acc_nbr)=2 then concat(SUBSTR(acc_nbr,1,1),'*')
              when length(acc_nbr)<8 then concat(SUBSTR(acc_nbr,1,(length(acc_nbr)-2)),'**')
              when length(acc_nbr)>=8 then concat(SUBSTR(acc_nbr,1,length(acc_nbr)-8),'****',SUBSTR(acc_nbr,length(acc_nbr)-3,length(acc_nbr)))
              else '*' end) as  acc_nbr_tm,prod_id,prod_type_crm_zqb_csp 
, sum(a0) AS sx_sr 
FROM zone_gz_yz.dwm_srhx_serv_list_mon_final_v2_mon 
WHERE month_id>=202409 and month_id<=202412 
AND coalesce(a0, 0) <> 0 
AND ((bg_type <> '其他' AND bg_type IS NOT NULL) OR subst_id = 500730 OR vpn_value = '009326523667') 
AND cust_nbr in('3020019855360000','2020335162450000','2930216337790000') 
and prod_type_crm_zqb_csp in('数字电路','MPLS VPN','基础网','专线')
group by month_id,cust_nbr,serv_id,(case when length(acc_nbr)<2 then '*'
              when length(acc_nbr)=2 then concat(SUBSTR(acc_nbr,1,1),'*')
              when length(acc_nbr)<8 then concat(SUBSTR(acc_nbr,1,(length(acc_nbr)-2)),'**')
              when length(acc_nbr)>=8 then concat(SUBSTR(acc_nbr,1,length(acc_nbr)-8),'****',SUBSTR(acc_nbr,length(acc_nbr)-3,length(acc_nbr)))
              else '*' end),prod_id,prod_type_crm_zqb_csp 
;

--黄鸿基  临街商铺地址渗透率
drop table tmp_yz_XQGZ2025043002176_01 purge;
create table tmp_yz_XQGZ2025043002176_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.grid_unit_code 
from zone_gz_yz.dwd_yz_dim_ljsp_addr a 
left join ads_yz_addr_belong_list_final b on cast(a.serv_addr_id as decimal(24,0))=cast(b.id as decimal(24,0)) 
;

drop table tmp_yz_XQGZ2025043002176_02 purge;
create table tmp_yz_XQGZ2025043002176_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.serv_addr_id is not null then 1 else 0 end as is_exists_kd 
from tmp_yz_XQGZ2025043002176_01 a 
left join (select serv_addr_id from dwm_yz_tb_comm_cm_all_final 
			where par_month_id=202505 and is_cancel_user=0 and prod_type=40 group by serv_addr_id) b on a.serv_addr_id=b.serv_addr_id 
;

drop table tmp_yz_XQGZ2025043002176_03 purge;
create table tmp_yz_XQGZ2025043002176_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select grid_unit_code 
,count(distinct serv_addr_id) as value_01
,count(distinct case when is_exists_kd=1 then serv_addr_id else null end) as value_02 
,count(distinct case when is_exists_kd=1 then serv_addr_id else null end)/count(distinct serv_addr_id) as shentou_lv 
from tmp_yz_XQGZ2025043002176_02 a group by grid_unit_code;

drop table tmp_yz_XQGZ2025043002176_04 purge;
create table tmp_yz_XQGZ2025043002176_04   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 200 as city_id,a.index1,a.index2,a.index3,a.index4,a.index5,a.index6,a.index7,a.index8 
,b.value_01,b.value_02,b.shentou_lv 
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_XQGZ2025043002176_03 b on a.index2=b.grid_unit_code 
;

--20250508  抽取 ads_yz_rpt_result 月底数据和202503月之后的日数据新建报表
## PG库操作python版本
from zone_python import *

connect_pg_gd(database_pg="yz_sjjy_gz",user_pg="app_sjjy_gz",password_pg="ZlhKKicldyDxRXhWdPlmhw__",host_pg="132.122.112.113",port_pg="18923")

sql_str= f"""
delete from ads_yz_rpt_result_20250508_bf where cast(substr(SUM_DATE,1,6) as int)<=202502 and length(SUM_DATE)<>8 ;commit;
"""
exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str) 

sql_str= f"""
insert into ads_yz_rpt_result_20250508_bf 
select * from ads_yz_rpt_result 
where cast(substr(SUM_DATE,1,6) as int)<=202502 
and length(SUM_DATE)<>8;commit;
"""
exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str) 

sql_str= f"""
delete from ads_yz_rpt_result_20250508_bf where cast(substr(SUM_DATE,1,6) as int)<=202502 
and substr(SUM_DATE,5,8) in (
'0101','0201','0301','0401','0501','0601','0701','0801','0901','1001','1101','1201',
'0131','0228','0229','0331','0430','0531','0630','0731','0831','0930','1031','1130','1231') 
and length(SUM_DATE)=8;commit;
"""
exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str) 


sql_str= f"""
insert into ads_yz_rpt_result_20250508_bf 
select * from ads_yz_rpt_result 
where cast(substr(SUM_DATE,1,6) as int)<=202502 
and substr(SUM_DATE,5,8) in (
'0101','0201','0301','0401','0501','0601','0701','0801','0901','1001','1101','1201',
'0131','0228','0229','0331','0430','0531','0630','0731','0831','0930','1031','1130','1231') 
and length(SUM_DATE)=8;commit;
"""
exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str) 

sql_str= f"""
delete from ads_yz_rpt_result_20250508_bf where cast(substr(SUM_DATE,1,6) as int)>202502;commit;
"""
exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str) 

sql_str= f"""
insert into ads_yz_rpt_result_20250508_bf 
select * from ads_yz_rpt_result 
where cast(substr(SUM_DATE,1,6) as int)>202502 ;commit;
"""
exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str)  


--XQGZ2025050802114 需求标题 请协助导出由客服部工单团队受理的注销清单 
请协助导出由客服部工单团队受理的注销清单。

一、订单状态为“开通中”“完工”，
二、受理日期：2025年3月和4月；
三、受理岗位：“客服中数通固网工单台高级岗”“客服越级处理组高级岗”“客服中数通固网工单台普通岗”“广州客服VIP要客受理岗”“客服越级处理组普通岗”
四、业务名称： 广东IPTV申请注销 、天翼宽带拨号(原ADSL拨号)申请注销、全屋WiFi/智能组网注销、天翼看家（家庭云版）云存储注销

drop table tmp_yz_XQGZ2025050802114_01 purge;
create table tmp_yz_XQGZ2025050802114_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end action_type_desc 
,subs_stat_date ,act_date,a.action_id,b.action_name  
--,c.org_name as  salestaff_subst_name,d.org_name as  salestaff_branch_name 
from dwm_yz_rpt_comm_ba_subs_final a 
left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
on a.action_id=b.action_id 
left join dws_crm_order.dws_order_item e on a.subs_id=e.order_item_id 
and e.create_post in('2006217503','2006218465','2006218723','2006218741','2000000111658')
--left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) c on a.salestaff_subst_id=c.org_id 
--left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) d on a.salestaff_branch_id=d.org_id 
where b.action_name in('广东IPTV申请注销','天翼宽带拨号(原ADSL拨号)申请注销','全屋WiFi/智能组网注销','天翼看家（家庭云版）云存储注销') 
and a.subs_stat not in( '201300','301200')  --订单状态为“开通中”“完工”
and date_format(act_date,'yyyyMM') in('202503','202504')  --受理日期：2025年3月和4月 
and e.order_item_id is not null 
group by subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end  
,subs_stat_date ,act_date,a.action_id,b.action_name--,c.org_name,d.org_name 
;

查询订单状态
b.attr_inner_name 
left join (select *  from dws_crm_cfguse.dws_attr_value  where attr_id ='4000000059') b
on a.subs_stat=b.attr_inner_value  --201300 开通中、301200	完工

查询受理岗位
--sys_post_id in('2006217503','2006218465','2006218723','2006218741','2000000111658')
select sys_post_id,sys_post_name from  dws_crm_cfguse.dws_system_post 
where sys_post_name in('客服中数通固网工单台高级岗','客服越级处理组高级岗','客服中数通固网工单台普通岗','广州客服VIP要客受理岗','客服越级处理组普通岗') 

select a.* from dwm_yz_rpt_comm_ba_subs_final a 
left join dws_crm_order.dws_order_item b 
on a.subs_id=b.order_item_id 
and b.create_post in('2006217503','2006218465','2006218723','2006218741','2000000111658') --sys_post_id=create_post

--20250519 张晓明 
24年全年，分融合和非融合  服务分群
广州、社区、城中村、农村、商客累计新入网主宽XX，这些用户在24年12月在网XX，在网且有效XX
drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.par_month_id
,case when a.is_rh_ykj>0 then '是' else '否' end as is_rh 
,case when a.serv_grp_type='01' then '政企' when a.serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc  
,case when coalesce(a.prod_name, '-1') LIKE '%专线%' then '是' else '否' end is_zx 
,case when coalesce(a.prod_name, '-1') LIKE '%城域网%' then '是' else '否' end is_cyw 
,case when coalesce(a.kd_prod_offer_name, '-1') LIKE '%0时长%' then '是' else '否' end is_0_sc 
,a.region_type ,a.serv_id 
,case when b.serv_id is not null then 1 else 0 end is_zw 
,case when b.serv_id is not null and b.is_yx>0 then 1 else 0 end is_zw_yx 
from ads_yz_kd_new_list a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=202412 and b.is_cancel_user=0 
WHERE a.par_month_id>=202401 and a.par_month_id<=202412 
AND a.kd_desc = '普通宽带' 
;

select '广州' item_name,is_rh,serv_grp_type_desc,is_zx,is_cyw,is_0_sc 
,count(serv_id) rw_nums 
,count(case when is_zw=1 then serv_id else null end) zw_nums 
,count(case when is_zw_yx=1 then serv_id else null end) zw_yx_nums  
from tmp_yz_liq_zxm_01 group by is_rh,serv_grp_type_desc,is_zx,is_cyw,is_0_sc 

union all 
select region_type,is_rh,serv_grp_type_desc,is_zx,is_cyw,is_0_sc 
,count(serv_id) rw_nums 
,count(case when is_zw=1 then serv_id else null end) zw_nums 
,count(case when is_zw_yx=1 then serv_id else null end) zw_yx_nums  
from tmp_yz_liq_zxm_01 group by region_type,is_rh,serv_grp_type_desc,is_zx,is_cyw,is_0_sc 
limit 1000 

--20250530  张晓明
DM0001-668-1-11，固网宽带100M单产品套餐（100元/月）
DM0001-751-1-2，宽带预存包期优惠_800元_12个月
DM0001-687-1-1，宽带优惠提速至200M_12个月
倩总，帮忙看看全广州1-5月同时做了这3条销售品的有多少？分开月份，只给个大数就行

drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202501' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(100096993,500047226,500050200)  

union all 
select date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where par_month_id>=202501 and par_month_id<=202504 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202501' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(100096993,500047226,500050200); 

drop table tmp_yz_liq_zxm_02 purge;
create table tmp_yz_liq_zxm_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,prod_offer_id,a.serv_id from 
tmp_yz_liq_zxm_01 a 
group by sl_month,prod_offer_id,a.serv_id ;

drop table tmp_yz_liq_zxm_03 purge;
create table tmp_yz_liq_zxm_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,serv_id,count(distinct prod_offer_id ) nums 
from tmp_yz_liq_zxm_02 group by sl_month,serv_id ;

select sl_month,count(serv_id) value1 from tmp_yz_liq_zxm_03 where nums>=3 group by sl_month 


--20250605  修复宽带日报-宽带净增 
发现报表202403-202501月数据膨胀，经核查，因年度回溯只能回溯月底数据，报表数据导入涉及日净增，导致月底数据与月底前一天数据口径不一致
修复操作：删除报表层 ads_yz_kdrb_kdjz_bao 的 202501月前除月底外的日数据

create table if not exists ads_yz_kdrb_kdjz_bao_bak_20250605 like ads_yz_kdrb_kdjz_bao 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy');

insert overwrite table ads_yz_kdrb_kdjz_bao_bak_20250605 
select * from ads_yz_kdrb_kdjz_bao 
where sum_date>=20250202 or sum_date in(20230228,20240229,20250131) or 
(sum_date<=20241231 and substr(SUM_DATE,5,8) in ('0131','0331','0430','0531','0630','0731','0831','0930','1031','1130','1231'))  
; 

alter table ads_yz_kdrb_kdjz_bao rename to ads_yz_kdrb_kdjz_bao_bak;
alter table ads_yz_kdrb_kdjz_bao_bak_20250605 rename to ads_yz_kdrb_kdjz_bao;

--XQGZ2025061302229 需求标题 关于批量导出疑似PCDN多session账号清单号码信息的需求
客户名称	客户直销编码	接入号	速率	
入网时间	联系电话	划小县分	划小营服	
包区	政企分群(01 政企 02 公众)	
serv_addr_id（装机地址编码）	装机地址	揽装人编码	揽装人	揽装局向
  
drop table tmp_yz_XQGZ2025061302229_01 purge;
create table tmp_yz_XQGZ2025061302229_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1 as paixu,a.index3 as acc_nbr2 from zone_gz_yz_3351225714708480 a;

drop table tmp_yz_XQGZ2025061302229_02 purge;
create table tmp_yz_XQGZ2025061302229_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.cust_name,b.cust_nbr,b.cust_id,b.cust_code,b.ccust_id,b.acc_nbr,b.serv_id,b.speed_value 
,b.open_date,b.subst_name,b.branch_name,b.area_name 
,case when serv_grp_type='01' then '政企' when serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc 
,b.serv_addr_id,b.sales_code,b.sales_name,b.channel_subst_name 
from  tmp_yz_XQGZ2025061302229_01 a 
left join dwm_yz_tb_comm_cm_all_final b on a.acc_nbr2=b.acc_nbr2 and b.par_month_id=202506; 

drop table tmp_yz_XQGZ2025061302229_03 purge;
create table tmp_yz_XQGZ2025061302229_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.addr 
from tmp_yz_XQGZ2025061302229_02 a 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id  
;

drop table tmp_yz_XQGZ2025061302229_04 purge;
create table tmp_yz_XQGZ2025061302229_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.ccust_name 
from tmp_yz_XQGZ2025061302229_03 a 
left join (select ccust_id,ccust_code,ccust_name,create_date,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;

drop table tmp_yz_XQGZ2025061302229_05 purge;
create table tmp_yz_XQGZ2025061302229_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.party_id 
from tmp_yz_XQGZ2025061302229_04 a 
left join (select cust_id,party_id from dws_crm_cust.dws_customer where city_id=200 group by cust_id,party_id) b 
on a.cust_id=b.cust_id;

drop table tmp_yz_XQGZ2025061302229_06 purge;
create table tmp_yz_XQGZ2025061302229_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.contact_id 
from tmp_yz_XQGZ2025061302229_05 a 
left join (select cust_id,contact_id from dws_crm_cust.dws_cust_contact_info_rel where city_id=200 group by cust_id,contact_id) b 
on a.cust_id=b.cust_id;

drop table tmp_yz_XQGZ2025061302229_07 purge;
create table tmp_yz_XQGZ2025061302229_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select distinct PARTY_ID,contact_id,contact_name,home_phone,office_phone,mobile_phone,status_date 
from dws_crm_cust.dws_contacts_info where city_id=200;

drop table tmp_yz_XQGZ2025061302229_08 purge;
create table tmp_yz_XQGZ2025061302229_08  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.contact_name,b.home_phone,b.office_phone,b.mobile_phone,b.status_date 
from tmp_yz_XQGZ2025061302229_06 a
left join tmp_yz_XQGZ2025061302229_07 b
on a.PARTY_ID=b.PARTY_ID and a.contact_id=b.contact_id;

drop table ads_yz_XQGZ2025061302229_list purge;
create table ads_yz_XQGZ2025061302229_list  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select paixu,cust_nbr,cust_code,speed_value,open_date 
,subst_name,branch_name,area_name,serv_grp_type_desc,serv_addr_id 
,sales_code,sales_name,channel_subst_name 
from tmp_yz_XQGZ2025061302229_08 ;

--谢钊铭 
宽带接入号	多媒体账号	session值	
宽带速率	客户名称	客户直销编码	
宽带入网时间	联系电话（同一套餐下/同一客编下的主卡号码）	
服务分群(01 政企 02 公众)	划小分局	划小营服	划小片区	网格单元名称	
落地分局	落地营服	serv_addr_id（装机地址id）	装机地址	
揽装局向	揽装人编码	揽装人

drop table tmp_yz_XQGZ2025061602349_01 purge;
create table tmp_yz_XQGZ2025061602349_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.prod_inst_id,b.serv_id,b.acc_nbr 
,b.acc_nbr2,a.attr_value,b.speed_value 
,b.cust_name,b.cust_nbr,b.cust_id,b.cust_code,b.ccust_id  
,b.open_date,b.subst_name,b.branch_name,b.area_name,b.grid_name 
,b.std_subst_name,b.std_branch_name,b.cell_name 
,case when serv_grp_type='01' then '政企' when serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc 
,b.serv_addr_id,b.sales_code,b.sales_name,b.channel_subst_name 
,b.prod_type 
from dws_crm_cust.dws_prod_inst_attr a 
left join dwm_yz_tb_comm_cm_all_final b on a.prod_inst_id=cast(b.serv_id as string) and b.par_month_id=202506 
where a.attr_id = '9845' and a.city_id = '200' and a.attr_value > 2 
group by a.prod_inst_id,b.serv_id,b.acc_nbr 
,b.acc_nbr2,a.attr_value,b.speed_value 
,b.cust_name,b.cust_nbr,b.cust_id,b.cust_code,b.ccust_id  
,b.open_date,b.subst_name,b.branch_name,b.area_name,b.grid_name 
,b.std_subst_name,b.std_branch_name,b.cell_name 
,case when serv_grp_type='01' then '政企' when serv_grp_type='02' then '公众' else '其他' end 
,b.serv_addr_id,b.sales_code,b.sales_name,b.channel_subst_name,b.prod_type  
;

drop table tmp_yz_XQGZ2025061602349_03 purge;
create table tmp_yz_XQGZ2025061602349_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.addr 
from tmp_yz_XQGZ2025061602349_01 a 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id  
;

drop table tmp_yz_XQGZ2025061602349_04 purge;
create table tmp_yz_XQGZ2025061602349_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.ccust_name 
from tmp_yz_XQGZ2025061602349_03 a 
left join (select ccust_id,ccust_code,ccust_name,create_date,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;

drop table tmp_yz_XQGZ2025061602349_05 purge;
create table tmp_yz_XQGZ2025061602349_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.party_id 
from tmp_yz_XQGZ2025061602349_04 a 
left join (select cust_id,party_id from dws_crm_cust.dws_customer where city_id=200 group by cust_id,party_id) b 
on a.cust_id=b.cust_id;

drop table tmp_yz_XQGZ2025061602349_06 purge;
create table tmp_yz_XQGZ2025061602349_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.contact_id 
from tmp_yz_XQGZ2025061602349_05 a 
left join (select cust_id,contact_id from dws_crm_cust.dws_cust_contact_info_rel where city_id=200 group by cust_id,contact_id) b 
on a.cust_id=b.cust_id;

drop table tmp_yz_XQGZ2025061602349_07 purge;
create table tmp_yz_XQGZ2025061602349_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select distinct PARTY_ID,contact_id,contact_name,home_phone,office_phone,mobile_phone,status_date 
from dws_crm_cust.dws_contacts_info where city_id=200;

drop table tmp_yz_XQGZ2025061602349_08 purge;
create table tmp_yz_XQGZ2025061602349_08  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.contact_name,b.home_phone,b.office_phone,b.mobile_phone,b.status_date 
from tmp_yz_XQGZ2025061602349_06 a
left join tmp_yz_XQGZ2025061602349_07 b
on a.PARTY_ID=b.PARTY_ID and a.contact_id=b.contact_id;

drop table ads_yz_XQGZ2025061302229_list purge;
create table ads_yz_XQGZ2025061302229_list  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*  
from tmp_yz_XQGZ2025061602349_08 a;

宽带接入号	多媒体账号	session值	宽带速率	产权客户编码	直销客户编码	
宽带入网时间  服务分群 	划小分局	划小营服	划小片区	网格责任田名称（划小）	
落地分局	落地营服	网格单元名称（落地）  serv_addr_id（装机地址id） 
揽装局向	揽装人编码	揽装人
drop view view_ads_yz_XQGZ2025061302229_list;
create view view_ads_yz_XQGZ2025061302229_list as 
select acc_nbr,acc_nbr2,attr_value,speed_value,cust_nbr,cust_code 
,open_date,serv_grp_type_desc,subst_name,branch_name,area_name,grid_name 
,std_subst_name,std_branch_name,cell_name,serv_addr_id 
,channel_subst_name,sales_code,sales_name 
from zone_gz_yz.ads_yz_XQGZ2025061302229_list where prod_type=40;

--20250618  宽带新装清单回溯部分新增字段 
--按原表表结构且带分区新建一样的新表
create table if not exists ads_yz_kd_new_list_bak_20250618 like ads_yz_kd_new_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy');

--回溯新增字段
drop table if exists tmp_yz_kd_new_list_20250618_huisu_01 purge;
create table tmp_yz_kd_new_list_20250618_huisu_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id,a.subs_code,a.subs_stat_date
,a.subst_id,a.subst_name,a.branch_id,a.branch_name,a.area_id,a.area_name,a.grid_id
,a.grid_code,a.grid_name,a.region_type,a.std_subst_id,a.std_subst_name,a.std_branch_id
,a.std_branch_name,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type
,a.is_mdz,a.six_market,a.serv_grp_type,a.sales_code,a.sales_name,a.channel_id,a.channel_nbr
,a.channel_name,a.channel_subst_name,a.channel_branch_name,a.channel_area_name
,a.channel_region_type,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype0_2011
,a.state,a.prod_id,a.is_zhuanxian,a.kd_desc,a.prod_type3,a.prod_type2,a.itv_type
,a.kd_prod_offer_id,a.speed_value,a.jz_points,a.is_rh_ykj,a.rh_tc_value,a.acc_nbr2
,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name,a.cust_code,a.ccust_name,a.ccust_org
,a.is_gsm,a.serv_addr_id,a.serv_addr_name,a.addr_id_7,a.open_date,a.is_sk_xjd,a.is_ljsp
,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name,a.six_market_desc
,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx,a.kuayv_offer_name
,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.ycx_offer_type,a.own_operators_nbr,a.own_operators_name
,a.is_zhuangwei,a.is_sheng_yx,a.cdma_disc_type3_name,a.label_name,a.load_date
,a.fk_lx,a.fk_value,a.kd_ll,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce,a.seq_id
,a.main_prod_offer_name,a.is_zxyb,a.is_lb_hy,a.addr_name_7,a.cntrt_type_cbxl_name
,a.kq_type,a.act_date 
,a.par_month_id,a.par_sum_date 

,b.subst_name as salestaff_subst_name,b.branch_name as salestaff_branch_name
from ads_yz_kd_new_list a
left join ads_yz_dim_op_final as b
on a.sales_id = b.staff_id and a.par_month_id=b.par_month_id 
;

--数据插入新表
insert overwrite table ads_yz_kd_new_list_bak_20250618  
select sum_date,month_id,serv_id,acc_nbr,subs_id,subs_code,subs_stat_date
,subst_id,subst_name,branch_id,branch_name,area_id,area_name,grid_id,grid_code
,grid_name,region_type,std_subst_id,std_subst_name,std_branch_id,std_branch_name
,cell_id,cell_code,cell_name,cell_type_name,bg_type,bu_type,is_mdz,six_market
,serv_grp_type,sales_code,sales_name,channel_id,channel_nbr,channel_name,channel_subst_name
,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011
,channel_subtype_2011,channel_subtype0_2011,state,prod_id,is_zhuanxian,kd_desc
,prod_type3,prod_type2,itv_type,kd_prod_offer_id,speed_value,jz_points,is_rh_ykj
,rh_tc_value,acc_nbr2,fttx_type,cust_id,cust_nbr,cust_name,cust_code,ccust_name
,ccust_org,is_gsm,serv_addr_id,serv_addr_name,addr_id_7,open_date,is_sk_xjd
,is_ljsp,is_yqjq,prod_name,kd_prod_offer_code,kd_prod_offer_name,six_market_desc
,serv_grp_type_desc,channel_subtype_flag,is_shangqi_dx,kuayv_offer_name
,grid_unit_area_id,mgr_area_id,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1
,xx_salestaff_code1,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2
,xx_salestaff_name2,ycx_offer_type,own_operators_nbr,own_operators_name
,is_zhuangwei,is_sheng_yx,cdma_disc_type3_name,label_name,load_date,fk_lx
,fk_value,kd_ll,kd_sc,is_hy,fee_shebei,fee_tiaoce,seq_id,main_prod_offer_name
,is_zxyb,is_lb_hy,addr_name_7,cntrt_type_cbxl_name,kq_type,act_date,salestaff_subst_name
,salestaff_branch_name,par_month_id,par_sum_date 
from tmp_yz_kd_new_list_20250618_huisu_01 
; 

--先备份原表数据！！！
alter table ads_yz_kd_new_list rename to ads_yz_kd_new_list_bak;
--新表替换原表
alter table ads_yz_kd_new_list_bak_20250618 rename to ads_yz_kd_new_list;

--20250624  张晓明
YD5G02-211-1-7，极致融合包100M（特惠版）
YD4G03-575-1-12，合约促销-60GB/月流量体验(24个月)_0元
帮忙看看这个月这两条销售品同时做了的有多少量？按划小局向来分就好
500057159 YD5G02-211-1-7
500072122 YD4G03-575-1-12

drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') = '202506' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(500057159,500072122)  
; 

drop table tmp_yz_liq_zxm_02 purge;
create table tmp_yz_liq_zxm_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,prod_offer_id,a.serv_id from 
tmp_yz_liq_zxm_01 a 
group by sl_month,prod_offer_id,a.serv_id ;

drop table tmp_yz_liq_zxm_03 purge;
create table tmp_yz_liq_zxm_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,serv_id,count(distinct prod_offer_id ) nums 
from tmp_yz_liq_zxm_02 group by sl_month,serv_id ;

select sl_month,count(serv_id) value1 from tmp_yz_liq_zxm_03 where nums>=2 group by sl_month 

--20250625  
修改小业务宽表配置表：
drop table dwd_dim_all_config_bf_20240520 purge;
create table dwd_dim_all_config_bf_20250625 as select * from dwd_dim_all_config;--771

--select distinct offer_id,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200 and prod_offer_code in()
H-FTTR
YD4G02-659-1-32 智企云包2.0促销优惠2年合约（混搭型）_70元
YD4G02-658-1-1 智享云包FTTR促销优惠3年合约（1+1混搭型）_40元
YD4G02-660-1-18 智享云包FTTR云盘调测版2年合约（FTTR1+1）_60元

商企小业务-合约
YD4G03-826-1-4
YD4G03-735-1-3
YD4G03-826-1-6
YD4G03-826-1-8
YD4G03-735-1-5
YD4G03-826-1-10


drop table tmp_dwd_dim_all_config_xz;--64
create table tmp_dwd_dim_all_config_xz as 
select cast(index1  as int) seq_id
,cast(index2  as string) seq_name
,cast(index3  as int) seq_value_id
,cast(index4  as string) seq_value_code
,cast(index5  as string) create_date
,cast(index6  as string) create_man
,cast(index7  as string) state_desc
,cast(index8  as string) reamark
,cast(index9  as string) reamark_bc
,cast(index10  as string) seq_type
from zone_gz_yz_3351225714708480;

insert overwrite table dwd_dim_all_config
select seq_id,seq_name,seq_value_id,seq_value_code,create_date,create_man,state_desc,reamark,reamark_bc,seq_type from (
select seq_id,seq_name,seq_value_id,seq_value_code,create_date,create_man,state_desc,reamark,reamark_bc,seq_type  
from dwd_dim_all_config_bf_20250625 where COALESCE(seq_id,-1) not in(13)
union all
select seq_id,seq_name,seq_value_id,seq_value_code,create_date,create_man,state_desc,reamark,reamark_bc,seq_type 
from tmp_dwd_dim_all_config_xz ) a;

--20250630  XQGZ2025062600676 刘丽娜
drop table tmp_yz_XQGZ2025062600676_01 purge;
create table tmp_yz_XQGZ2025062600676_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.open_date,'yyyyMM') rw_month,a.subst_name,a.region_type
,CASE WHEN a.speed_value>= 1000 then '是' else '否' end as is_qz 
,a.serv_id,a.rh_tc_id 
,case when b.serv_id is not null then '是' else '否' end as is_fttr 
from dwm_yz_tb_comm_cm_all_final a 
left join dwm_fttr_list b on a.serv_id=b.serv_id and b.par_month_id=202505 and b.create_date>='20250501' 
where a.prod_type=40 and a.is_rh_ykj=1 and a.rh_type_ykj='新宽带新移动' 
and a.par_month_id=202505 and coalesce(a.prod_type2,-1) not in(50); 

drop table tmp_yz_XQGZ2025062600676_02 purge;
create table tmp_yz_XQGZ2025062600676_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.rh_tc_id,a.serv_id,a.is_contract,a.is_vice_card,a.is_hy 
,case when a.stm_data+a.mou_call+a.mgs_counts>=30 then 1 else 0 end as is_yd_hy 
,case when b.serv_id is not null then 1 else 0 end is_ai 
from dwm_yz_tb_comm_cm_all_final a 
left join ads_hdk_2025033002_ai b on a.serv_id=b.serv_id and b.par_month_id = 202505 
and (b.is_aiznp=1 or b.is_aikj=1 or b.is_aiyl=1 or b.is_scb=1 or b.is_czcb=1) 
where a.prod_type=30 and a.is_rh_ykj=1 and a.par_month_id=202505; 

drop table tmp_yz_XQGZ2025062600676_03 purge;
create table tmp_yz_XQGZ2025062600676_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select rh_tc_id 
,count(case when is_contract=1 and is_vice_card=0 then serv_id else null end) as hy_nums 
,count(case when is_ai=1 then serv_id else null end) as ai_nums 
,count(case when is_yd_hy=1 then serv_id else null end) as huoy_yd_nums 
from tmp_yz_XQGZ2025062600676_02 a 
group by rh_tc_id;

drop table tmp_yz_XQGZ2025062600676_04 purge;
create table tmp_yz_XQGZ2025062600676_04   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*
,case when b.hy_nums>0 then '是' else '否' end as is_hy 
,case when b.ai_nums>0 then '是' else '否' end as is_ai 
,case when b.huoy_yd_nums>=2 then '是' else '否' end as is_huoyue 
from tmp_yz_XQGZ2025062600676_01 a 
left join tmp_yz_XQGZ2025062600676_03 b on a.rh_tc_id=b.rh_tc_id ; 

drop table ads_yz_XQGZ2025062600676_dwb purge;
create table ads_yz_XQGZ2025062600676_dwb   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select rw_month,subst_name,region_type,is_qz,is_hy,is_ai,is_huoyue,is_fttr  
,count(serv_id) xkxy_nums 
from tmp_yz_XQGZ2025062600676_04 a 
group by rw_month,subst_name,region_type,is_qz,is_hy,is_ai,is_huoyue,is_fttr; 

--20250704  赖宇鑫  XQGZ2025070202574 需求标题 关于美团明厨亮灶目标清单匹配存量宽带的需求 
drop table tmp_yz_XQGZ2025070202574_01 purge;
create table tmp_yz_XQGZ2025070202574_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select  a.party_id,a.cert_num,b.cust_id,b.cust_name  
from dws_crm_cust.dws_party_cert_local a --证件表
join (select  party_id,cust_id,cust_name from dws_crm_cust.dws_customer where city_id='200' group by party_id,cust_id,cust_name) b 
on a.party_id=b.party_id 
where a.cert_num in(select  index20 from zone_gz_yz_3351225714708480 group by index20 ) 
--and a.cert_type=49 --统一社会信用代码（税号） 
and a.city_id='200' group by a.party_id,a.cert_num,b.cust_id,b.cust_name;


drop table tmp_yz_XQGZ2025070202574_02 purge;
create table tmp_yz_XQGZ2025070202574_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id,a.acc_nbr,a.subst_name,a.prod_id,a.serv_addr_id,b.* 
from dwm_yz_tb_comm_cm_all_final a  
join tmp_yz_XQGZ2025070202574_01 b on a.cust_id=b.cust_id  
where a.par_month_id=202507 and a.prod_type=40 and a.is_cancel_user=0; 

drop table tmp_yz_XQGZ2025070202574_03_1 purge;
create table tmp_yz_XQGZ2025070202574_03_1   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.addr as serv_addr_name,b.addr_id_7 serv_addr_7,c.prod_name 
from tmp_yz_XQGZ2025070202574_02 a 
left join (select distinct id,addr,addr_id_7 from zone_gz_yz.dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) c on a.prod_id=c.prod_id;

drop table tmp_yz_XQGZ2025070202574_03 purge;
create table tmp_yz_XQGZ2025070202574_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.addr as addr_name_7  
from tmp_yz_XQGZ2025070202574_03_1 a 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=7) b on cast(a.serv_addr_7 as decimal(24,0))=b.id 
;

drop table tmp_yz_XQGZ2025070202574_04 purge;
create table tmp_yz_XQGZ2025070202574_04   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.index1,a.index2,a.index3,a.index4,a.index5,a.index6,a.index7 
,a.index8,a.index9,a.index10,a.index11,a.index12,a.index13,a.index14 
,a.index15,a.index16,a.index17,a.index18,a.index19,a.index20,a.index21  
,b.* 
from zone_gz_yz_3351225714708480 a 
join tmp_yz_XQGZ2025070202574_03 b on a.index20=b.cert_num;

drop table tmp_yz_XQGZ2025070202574_05 purge;
create table tmp_yz_XQGZ2025070202574_05   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id,a.acc_nbr,a.subst_name,a.prod_id,a.serv_addr_id,a.cust_id,a.cust_name  
,b.addr as serv_addr_name,b.addr_id_7 serv_addr_7 
from dwm_yz_tb_comm_cm_all_final a  
left join (select distinct id,addr,addr_id_7 from zone_gz_yz.dwd_yz_addr_final where grade=10) b on cast(a.serv_addr_id as decimal(24,0))=b.id 
where a.par_month_id=202507 and a.prod_type=40 and a.is_cancel_user=0; 

drop table tmp_yz_XQGZ2025070202574_06 purge;
create table tmp_yz_XQGZ2025070202574_06   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.addr as addr_name_7,c.prod_name 
from tmp_yz_XQGZ2025070202574_05 a 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=7) b on cast(a.serv_addr_7 as decimal(24,0))=b.id 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) c on a.prod_id=c.prod_id;

drop table tmp_yz_XQGZ2025070202574_07 purge;
create table tmp_yz_XQGZ2025070202574_07   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.index1,a.index2,a.index3,a.index4,a.index5,a.index6,a.index7 
,a.index8,a.index9,a.index10,a.index11,a.index12,a.index13,a.index14 
,a.index15,a.index16,a.index17,a.index18,a.index19,a.index20,a.index21  
,b.* 
from zone_gz_yz_3351225714708480 a 
join tmp_yz_XQGZ2025070202574_06 b on a.index16=b.addr_name_7  
;

drop table tmp_yz_XQGZ2025070202574_08 purge;
create table tmp_yz_XQGZ2025070202574_08   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select '按执照编号匹配' flag,a.index1,a.index2,a.index3,a.index4,a.index5,a.index6,a.index7,a.index8,a.index9 
,a.index10,a.index11,a.index12,a.index13,a.index14,a.index15,a.index16,a.index17,a.index18,a.index19,a.index20 
,a.index21,a.serv_id,a.acc_nbr,a.subst_name,a.prod_id,a.serv_addr_id,a.party_id,a.cert_num,a.cust_id,a.cust_name 
,a.serv_addr_name,a.serv_addr_7,a.prod_name,a.addr_name_7 
from tmp_yz_XQGZ2025070202574_04 a 

union all 
select '按七级地址匹配' flag,a.index1,a.index2,a.index3,a.index4,a.index5,a.index6,a.index7,a.index8,a.index9 
,a.index10,a.index11,a.index12,a.index13,a.index14,a.index15,a.index16,a.index17,a.index18,a.index19,a.index20 
,a.index21,a.serv_id,a.acc_nbr,a.subst_name,a.prod_id,a.serv_addr_id 
,cast(null as string) party_id,cast(null as string) cert_num,cast(a.cust_id as string),a.cust_name 
,a.serv_addr_name,a.serv_addr_7,a.prod_name,a.addr_name_7 
from tmp_yz_XQGZ2025070202574_07 a 

union all 
select '匹配不到' flag,a.index1,a.index2,a.index3,a.index4,a.index5,a.index6,a.index7,a.index8,a.index9 
,a.index10,a.index11,a.index12,a.index13,a.index14,a.index15,a.index16,a.index17,a.index18,a.index19,a.index20 
,a.index21
,cast(null as decimal(22,0)) serv_id
,cast(null as varchar(96)) acc_nbr
,cast(null as varchar(100)) subst_name
,cast(null as decimal(22,0)) prod_id
,cast(null as varchar(64)) serv_addr_id
,cast(null as string) party_id
,cast(null as string) cert_num
,cast(null as string) cust_id
,cast(null as string) cust_name
,cast(null as string) serv_addr_name
,cast(null as decimal(24,0)) serv_addr_7
,cast(null as string) prod_name
,cast(null as string) addr_name_7 
from zone_gz_yz_3351225714708480 a 
left join (select index1 from tmp_yz_XQGZ2025070202574_04 group by index1) b on a.index1=b.index1 
left join (select index1 from tmp_yz_XQGZ2025070202574_07 group by index1) c on a.index1=c.index1 
where b.index1 is null and c.index1 is null 
; 

--融合主套餐（礼包）main_prod_offer_name	是否智享云包(礼包)is_zxyb
drop table ads_yz_XQGZ2025070202574_list purge;
create table ads_yz_XQGZ2025070202574_list   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 200 as city_id,a.*,b.main_prod_offer_name,b.is_zxyb 
from tmp_yz_XQGZ2025070202574_08 a 
left join ads_yz_kd_new_list b on a.serv_id=b.serv_id and b.par_month_id=202507 
; 

drop table ads_yz_XQGZ2025070202574_fwzq purge;
create table ads_yz_XQGZ2025070202574_fwzq   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select city_id,flag
,index1,index2,index3,index4,index5,index6,index7,index8,index9,index10
,index11,index12,index13,index14,index15 
,(case when length(index16)<4 then index16
		when length(index16)=4 then concat(SUBSTR(index16,1,1),'*')
		when length(index16)>4 then concat(SUBSTR(index16,1,(length(index16)-4)),'****')
		else null end) as sj_addr  
,index17,index18,index19,index20,index21
,acc_nbr,subst_name
,(case when length(a.cust_name)<2 then a.cust_name 
when length(a.cust_name)=2 then concat(SUBSTR(a.cust_name,1,1),'*') 
when length(a.cust_name)>2 then concat(SUBSTR(a.cust_name,1,(length(a.cust_name)-2)),'**') else null end) as cust_name_tm 
,cast(null as string) as party_nbr 
,(case when length(serv_addr_name)<4 then serv_addr_name
		when length(serv_addr_name)=4 then concat(SUBSTR(serv_addr_name,1,1),'*') 
		when length(serv_addr_name)>4 then concat(SUBSTR(serv_addr_name,1,(length(serv_addr_name)-4)),'****')
		else null end) as addr_name_tm,main_prod_offer_name,is_zxyb,concat(addr_name_7,'****') addr_name7_tm 
from ads_yz_XQGZ2025070202574_list a;		

--张建新   审计 
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_dim_01 purge;
create table tmp_yz_shenji_zjx_dim_01    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select index3,index4,index5,index6,index7,index8,index9,index10,index11
,index12,index13,index14,index15,index16,index17,index18,index19,index20
,index21,index22,index23,index24 
from zone_gz_yz_3351225714708480 ;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_dim_02 purge;
create table tmp_yz_shenji_zjx_dim_02    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select index3,index4,index5,index6,index7,index8,index9,index10,index11
,index12,index13,index14,index15,index16,index17,index18,index19,index20
,index21,index22,index23,index24 
from zone_gz_yz_3351225714708480 ;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_dim_03 purge;
create table tmp_yz_shenji_zjx_dim_03    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select index3,index4,index5,index6,index7,index8,index9,index10,index11
,index12,index13,index14,index15,index16,index17,index18,index19,index20
,index21,index22,index23,index24 
from zone_gz_yz_3351225714708480 ;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_dim_list purge;
create table tmp_yz_shenji_zjx_dim_list    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* from tmp_yz_shenji_zjx_dim_01 a 
union all 
select a.* from tmp_yz_shenji_zjx_dim_02 a 
union all 
select a.* from tmp_yz_shenji_zjx_dim_03 a ;

第四次 修改时间范围！！！！！！！
审计期202106-202409的数据 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--宽带流量
drop table tmp_yz_shenji_zjx_01 purge;
create table tmp_yz_shenji_zjx_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll 
from summary_ods_month_city.tb_comm_ywl_data_mon 
where par_corp_id=200 and par_month_id>=202106 and par_month_id<=202409  
group by par_month_id,serv_id,cast(NET_FLUX/1048576 as decimal(22,2)); 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--移动流量
drop table tmp_yz_shenji_zjx_02 purge;
create table tmp_yz_shenji_zjx_02     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id 
,cast(innet_flux/(1024.0*1024.0) as decimal(22,2)) as stm_data 
from summary_ods_month_city.tb_comm_cm_cdma_mon
where par_corp_id=200
and par_month_id>=202106 and par_month_id<=202409  
group by par_month_id,serv_id,
cast(innet_flux/(1024.0*1024.0) as decimal(22,2));

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--出账金额
drop table tmp_yz_shenji_zjx_03 purge;
create table tmp_yz_shenji_zjx_03     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.par_month_id,a.serv_id,cast(a.fee as decimal(22,2))
from dwm_yz_tb_comm_cm_all_mon_final a 
where par_month_id>=202106 and par_month_id<=202409  
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_04 purge;
create table tmp_yz_shenji_zjx_04     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index3 bendi_wang,a.index4 prod_inst_id,b.rh_tc_id,b.prod_type3 from tmp_yz_shenji_zjx_dim_list a 
left join dwm_yz_tb_comm_cm_all_final b on cast(index4 as decimal(22,0))=b.serv_id and b.par_month_id=202507 ;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--融合套内号码
drop table tmp_yz_shenji_zjx_05_1 purge;
create table tmp_yz_shenji_zjx_05_1     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id,a.rh_tc_id 
from dwm_yz_tb_comm_cm_all_final a 
join (select rh_tc_id from tmp_yz_shenji_zjx_04 group by rh_tc_id) b on a.rh_tc_id=b.rh_tc_id 
where a.prod_type in(30,40) and a.par_month_id=202507 group by a.serv_id,a.rh_tc_id;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--融合套内号码流量
drop table tmp_yz_shenji_zjx_05_2 purge;
create table tmp_yz_shenji_zjx_05_2     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.par_month_id,b.kd_ll as liuliang  
from tmp_yz_shenji_zjx_05_1 a 
join tmp_yz_shenji_zjx_01 b on a.serv_id=b.serv_id 

union all 
select a.*,b.par_month_id,b.stm_data as liuliang  
from tmp_yz_shenji_zjx_05_1 a 
join tmp_yz_shenji_zjx_02 b on a.serv_id=b.serv_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--融合流量
drop table tmp_yz_shenji_zjx_05 purge;
create table tmp_yz_shenji_zjx_05     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.par_month_id,a.rh_tc_id,sum(liuliang) as rh_ll 
from tmp_yz_shenji_zjx_05_2 a group by a.par_month_id,a.rh_tc_id 
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--融合套内号码出账
drop table tmp_yz_shenji_zjx_06_1 purge;
create table tmp_yz_shenji_zjx_06_1     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.par_month_id,b.fee   
from tmp_yz_shenji_zjx_05_1 a 
join tmp_yz_shenji_zjx_03 b on a.serv_id=b.serv_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--融合出账
drop table tmp_yz_shenji_zjx_06 purge;
create table tmp_yz_shenji_zjx_06     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.par_month_id,a.rh_tc_id,sum(fee) as rh_fee  
from tmp_yz_shenji_zjx_06_1 a group by a.par_month_id,a.rh_tc_id 
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_07 purge;
create table tmp_yz_shenji_zjx_07     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.max_ll_month 
from tmp_yz_shenji_zjx_04 a 
left join (select serv_id,max(par_month_id) max_ll_month from tmp_yz_shenji_zjx_01 where coalesce(kd_ll,0)<>0 group by serv_id) b 
on cast(a.prod_inst_id as decimal(22,0))=b.serv_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_08 purge;
create table tmp_yz_shenji_zjx_08     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.max_fee_month 
from tmp_yz_shenji_zjx_07 a 
left join (select serv_id,max(par_month_id) max_fee_month from tmp_yz_shenji_zjx_03 where coalesce(fee,0)<>0 group by serv_id) b 
on cast(a.prod_inst_id as decimal(22,0))=b.serv_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_09 purge;
create table tmp_yz_shenji_zjx_09     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.max_rhll_month 
from tmp_yz_shenji_zjx_08 a 
left join (select rh_tc_id,max(par_month_id) max_rhll_month from tmp_yz_shenji_zjx_05 where coalesce(rh_ll,0)<>0 group by rh_tc_id) b 
on a.rh_tc_id=b.rh_tc_id  
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table tmp_yz_shenji_zjx_10 purge;
create table tmp_yz_shenji_zjx_10     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.max_rhfee_month 
from tmp_yz_shenji_zjx_09 a 
left join (select rh_tc_id,max(par_month_id) max_rhfee_month from tmp_yz_shenji_zjx_06 where coalesce(rh_fee,0)<>0 group by rh_tc_id) b 
on a.rh_tc_id=b.rh_tc_id  
;

drop table tmp_yz_shenji_zjx_11 purge;
create table tmp_yz_shenji_zjx_11     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id from dwd_yz_rpt_comm_cm_msdisc_final a 
where  par_corp_id='200'
and prod_offer_id in(500046067,500057260,500058226) 
and date_format(limit_date,'yyyyMMdd') > '20250707'  
group by serv_id;

drop table tmp_yz_shenji_zjx_12 purge;
create table tmp_yz_shenji_zjx_12     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,case when b.serv_id is not null then '是' else '否' end is_kjkd_zxl 
from tmp_yz_shenji_zjx_10 a 
left join tmp_yz_shenji_zjx_11 b on a.prod_inst_id=cast(b.serv_id as string)
; 

drop table tmp_yz_shenji_zjx_13 purge;
create table tmp_yz_shenji_zjx_13     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*
,case when b.is_rh_ykj=1 then '是' else '否' end is_rh 
,b.kd_desc,b.fk_lx from tmp_yz_shenji_zjx_12 a 
left join dwm_yz_tb_comm_cm_all_final b on a.prod_inst_id=cast(b.serv_id as string) and b.par_month_id=202507 ;	

第三次加字段！！！！
入网时间、在网状态、预付费还是后付费、是否协议减免（有办 TY143 TY825 TY931 的都是）
offer_id	prod_offer_code
100018654	TY825
100069786	TY931
15545	TY143
	
drop table tmp_yz_shenji_zjx_16 purge;
create table tmp_yz_shenji_zjx_16     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id from dwd_yz_rpt_comm_cm_msdisc_final a 
where  par_corp_id='200'
and prod_offer_id in(100018654,100069786,15545) 
and date_format(limit_date,'yyyyMMdd') > '20250714'  
group by serv_id;

drop table tmp_yz_shenji_zjx_17 purge;
create table tmp_yz_shenji_zjx_17     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,case when b.serv_id is not null then '是' else '否' end is_xyjm 
from tmp_yz_shenji_zjx_13 a 
left join tmp_yz_shenji_zjx_16 b on a.prod_inst_id=cast(b.serv_id as string); 

drop table tmp_yz_shenji_zjx_18 purge;
create table tmp_yz_shenji_zjx_18     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.open_date
,case when b.serv_id is not null then b.state else '拆机' end state_desc 
,case when b.payment_id=1 then '后付费' else '预付费' end as payment_desc 
from tmp_yz_shenji_zjx_17 a 
left join dwm_yz_tb_comm_cm_all_final b on a.prod_inst_id=cast(b.serv_id as string) and b.par_month_id=202507 
;

drop table tmp_yz_shenji_zjx_19 purge;
create table tmp_yz_shenji_zjx_19     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.attr_value is not null then b.attr_value_name else a.state_desc end as state 
from tmp_yz_shenji_zjx_18 a 
left join dws_crm_cfguse.dws_attr_value b on a.state_desc=b.attr_value and b.city_id='200' and b.attr_id='4000000201' 
;

drop table tmp_yz_shenji_zjx_20 purge;
create table tmp_yz_shenji_zjx_20 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as 
select bendi_wang,prod_inst_id 
,case when max_ll_month is null and max_fee_month is null then '否' else '是' end not_0ll_0cz 
,max_ll_month,max_fee_month,prod_type3 
,case when max_rhll_month is null and max_rhfee_month is null and rh_tc_id is not null then '否' 
	when max_ll_month is null and max_fee_month is null and rh_tc_id is null then '否' 
	else '是' end not_0rhll_0rhcz 
,case when rh_tc_id is null and max_ll_month is not null then max_ll_month else max_rhll_month end rhll_month 
,case when rh_tc_id is null and max_fee_month is not null then max_fee_month else max_rhfee_month end rhfee_month 
,is_kjkd_zxl  --是否快捷宽带主线路
,is_rh  --是否融合
,kd_desc  --宽带类型
,fk_lx  --副宽类型
,is_xyjm  --是否协议减免
,open_date  --入网时间
,state_desc 
,payment_desc  --预付费还是后付费
,state  --在网状态
from tmp_yz_shenji_zjx_19; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table ads_yz_shenji_zjx_list purge;
create table ads_yz_shenji_zjx_list     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 200 as city_id,a.* from tmp_yz_shenji_zjx_20 a;	 

select 
bendi_wang --本地网
,prod_inst_id 
,not_0ll_0cz --是否非0流量0出账
,max_ll_month --有流量月份（取流量最大的月份）
,max_fee_month --有出账月份（取出账最大的月份）
,prod_type3 
,not_0rhll_0rhcz --融合套餐级是否非0流量0出账
,rhll_month --有流量月份（取流量最大的月份）
,rhfee_month  --有出账月份（取出账最大的月份）
,is_kjkd_zxl  --是否快捷宽带主线路
,is_rh  --是否融合
,kd_desc  --宽带类型
,fk_lx  --副宽类型
,is_xyjm  --是否协议减免
,open_date  --入网时间
,payment_desc  --预付费还是后付费
,state  --在网状态
from zone_gz.view_ads_yz_shenji_zjx_list 



--20250714 XQGZ2025071001377 需求标题 关于提取客户全量号码涉及的订单编码和订单类别的申请  
drop table tmp_yz_XQGZ2025071001377_01 purge;
create table tmp_yz_XQGZ2025071001377_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select index1 as prod_name, 
index2 as acc_nbr, 
index3 as open_date, 
index4 as cancel_date, 
index5 as state_desc 
from zone_gz_yz_3351225714708480 ; 

drop table tmp_yz_XQGZ2025071001377_02 purge;
create table tmp_yz_XQGZ2025071001377_02     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end action_type_desc 
,subs_stat_date ,act_date,a.action_id,subs_stat_reason  
from dwm_yz_rpt_comm_ba_subs_mon_final a 
where a.par_month_id between 202012 and 202506 and a.subs_stat = '301200' 
and acc_nbr in(select acc_nbr from tmp_yz_XQGZ2025071001377_01)
--and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')
group by par_month_id,subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end  
,subs_stat_date ,act_date,a.action_id,subs_stat_reason 
;

insert into table tmp_yz_XQGZ2025071001377_02 
select '202507' par_month_id,subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end action_type_desc 
,subs_stat_date ,act_date,a.action_id ,subs_stat_reason 
from dwm_yz_rpt_comm_ba_subs_final a 
where a.subs_stat = '301200' 
and acc_nbr in(select acc_nbr from tmp_yz_XQGZ2025071001377_01) 
--and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300') 
group by subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end  
,subs_stat_date ,act_date,a.action_id ,subs_stat_reason 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table tmp_yz_XQGZ2025071001377_03 purge;
create table tmp_yz_XQGZ2025071001377_03     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* from tmp_yz_XQGZ2025071001377_02 a 
join tmp_yz_XQGZ2025071001377_01 b on a.acc_nbr=b.acc_nbr 
;

drop table tmp_yz_XQGZ2025071001377_04 purge;
create table tmp_yz_XQGZ2025071001377_04     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.action_name,c.attr_value_name as subs_stat_reason_desc 
--,c.org_name as  salestaff_subst_name,d.org_name as  salestaff_branch_name 
from tmp_yz_XQGZ2025071001377_03 a 
left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
on a.action_id=b.action_id 
left join dws_crm_cfguse.dws_attr_value c on a.subs_stat_reason = c.attr_inner_value and c.city_id='200' and c.attr_id ='4000000065'   

--left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) c on a.salestaff_subst_id=c.org_id 
--left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) d on a.salestaff_branch_id=d.org_id  
;

drop table tmp_yz_XQGZ2025071001377_05 purge;
create table tmp_yz_XQGZ2025071001377_05     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select b.prod_name,b.open_date,b.cancel_date,b.state_desc,a.* 
from tmp_yz_XQGZ2025071001377_04 a 
left join tmp_yz_XQGZ2025071001377_01 b on a.acc_nbr=b.acc_nbr ;

drop table tmp_yz_XQGZ2025071001377_06 purge;
create table tmp_yz_XQGZ2025071001377_06     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from tmp_yz_XQGZ2025071001377_05 

union all 
select a.prod_name,
a.open_date,
a.cancel_date,
a.state_desc,
cast(null as string),
cast(null as decimal(22,0)),
cast(null as varchar(64)),
a.acc_nbr,
cast(null as decimal(22,0)),
cast(null as varchar(100)),
cast(null as string),
cast(null as string),
cast(null as decimal(22,0)),
cast(null as decimal(22,0)),
cast(null as string),
cast(null as timestamp),
cast(null as timestamp),
cast(null as decimal(22,0)),
cast(null as varchar(64)),
cast(null as string),
cast(null as string) 
from tmp_yz_XQGZ2025071001377_01 a 
left join (select acc_nbr from tmp_yz_XQGZ2025071001377_05 group by acc_nbr) b on a.acc_nbr=b.acc_nbr 
where b.acc_nbr is null 
;
alter table tmp_yz_XQGZ2025071001377_06 rename to ads_yz_XQGZ2025071001377_list;

--新增订单备注 
alter table ads_yz_XQGZ2025071001377_list rename to tmp_yz_XQGZ2025071001377_06;
drop table tmp_yz_XQGZ2025071001377_07 purge;
create table tmp_yz_XQGZ2025071001377_07     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.order_item_id,a.remark,a.create_date from dws_crm_order.dws_order_item a 
union all 
select a.order_item_id,a.remark,a.create_date from dws_crm_order.dws_order_item_his a 
;

drop table tmp_yz_XQGZ2025071001377_08 purge;
create table tmp_yz_XQGZ2025071001377_08     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,row_number() over(partition by order_item_id order by create_date desc) as paixu 
from tmp_yz_XQGZ2025071001377_07 a;

drop table tmp_yz_XQGZ2025071001377_09 purge;
create table tmp_yz_XQGZ2025071001377_09     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.remark 
from tmp_yz_XQGZ2025071001377_06 a 
left join (select * from tmp_yz_XQGZ2025071001377_08 where paixu=1) b on a.subs_id=b.order_item_id 
;
alter table tmp_yz_XQGZ2025071001377_09 rename to ads_yz_XQGZ2025071001377_list;

--名称	接入号	入网日期	拆机日期	号码状态，订单编码，订单id，
--订单类型（新装/拆机/移机等），业务名称，竣工时间，受理时间，订单状态原因,订单备注
drop view view_ads_yz_XQGZ2025071001377_list;
create view view_ads_yz_XQGZ2025071001377_list as 
select prod_name,acc_nbr,open_date,cancel_date,state_desc,subs_code,subs_id
,action_type_desc,action_name,subs_stat_date,act_date,subs_stat_reason_desc,remark 
from zone_gz_yz.ads_yz_XQGZ2025071001377_list;


--20250714 XQGZ2025071101264 需求标题 出租物业合同承租方使用中国电信业务产品统计 
drop table tmp_yz_XQGZ2025071101264_01 purge;
create table tmp_yz_XQGZ2025071101264_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select index1 as xuhao, 
index2 as acc_nbr, 
index3 as subst_name, 
index4 as hetong_nbr, 
index5 as czf_name  
from zone_gz_yz_3351225714708480 ; 

drop table tmp_yz_XQGZ2025071101264_02 purge;
create table tmp_yz_XQGZ2025071101264_02     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.cust_id,b.cust_name 
from tmp_yz_XQGZ2025071101264_01 a 
left join dwm_yz_tb_comm_cm_all_final b on a.acc_nbr=b.acc_nbr and b.par_month_id=202507 
;

drop table tmp_yz_XQGZ2025071101264_03 purge;
create table tmp_yz_XQGZ2025071101264_03     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.serv_id,b.prod_id 
,case when a.cust_id is null then '附件提供接入号已拆机' else null end is_cj  
from tmp_yz_XQGZ2025071101264_02 a 
left join dwm_yz_tb_comm_cm_all_final b on a.cust_id=b.cust_id and b.par_month_id=202507 and b.is_cancel_user=0 
;

drop table tmp_yz_XQGZ2025071101264_04 purge;
create table tmp_yz_XQGZ2025071101264_04     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,c.prod_name,b.sh_sq,b.sh_qr 
from tmp_yz_XQGZ2025071101264_03 a 
left join (select serv_id, 
sum(a0) as sh_qr,--税后确认收入
sum(a0_sq) as sh_sq --税前确认收入
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id >= 202501 and par_month_id<=202506 
group by serv_id) b on a.serv_id=b.serv_id 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) c on a.prod_id=c.prod_id
;

drop table tmp_yz_XQGZ2025071101264_05 purge;
create table tmp_yz_XQGZ2025071101264_05     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.month6_fee as fee  
from tmp_yz_XQGZ2025071101264_04 a 
left join (select serv_id,sum(fee) month6_fee 
			from dwm_yz_tb_comm_cm_all_mon_final 
			where par_month_id>=202501 and par_month_id<=202506 
			group by serv_id) b on a.serv_id=b.serv_id  
; 

drop table tmp_yz_XQGZ2025071101264_06 purge;
create table tmp_yz_XQGZ2025071101264_06     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select xuhao,acc_nbr,subst_name,hetong_nbr,czf_name,is_cj 
,prod_id,prod_name
,cast(sum(fee) as decimal(22,4)) as cz_sr
,cast(sum(sh_sq) as decimal(22,4)) sq
,cast(sum(sh_qr) as decimal(22,4)) sh 
from tmp_yz_XQGZ2025071101264_05 group by 
xuhao,acc_nbr,subst_name,hetong_nbr,czf_name,is_cj 
,prod_id,prod_name;

select xuhao,subst_name,hetong_nbr,is_cj,prod_id,prod_name,cz_sr,sq,sh  
from tmp_yz_XQGZ2025071101264_06 where xuhao<150 --761

select xuhao,subst_name,hetong_nbr,is_cj,prod_id,prod_name,cz_sr,sq,sh  
from tmp_yz_XQGZ2025071101264_06 where xuhao>=150 and xuhao<300 --703 

select xuhao,subst_name,hetong_nbr,is_cj,prod_id,prod_name,cz_sr,sq,sh  
from tmp_yz_XQGZ2025071101264_06 where xuhao>=300 --538


--531新装高套
drop table tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 'gaotao' flag
,cast(a.par_month_id as int) month_id
,cast(a.serv_id as string) serv_id_gt
,cast(a.region_type as string) region_type_gt 
,case when a.rh_tc_value>=129 then 1 else 0 end is_gt  
,case when a.rh_tc_value<59 then 0
when a.rh_tc_value>=59 and a.rh_tc_value<79 then 0.3
when a.rh_tc_value>=79 and a.rh_tc_value<129 then 0.5
when a.rh_tc_value>=129 and a.rh_tc_value<199 then 1
when a.rh_tc_value>=199 and a.rh_tc_value<299 then 1.5
when a.rh_tc_value>=299 and a.rh_tc_value<399 then 2
when a.rh_tc_value>=399 then 2+cast((a.rh_tc_value-299)/100 as int)*0.5
else 0 end acc_nbr_zs  
from dwm_yz_tb_comm_cm_all_mon_final a 
left join (select prod_id,prod_name from dws_crm_cfguse.dws_product) b
on a.prod_id=b.prod_id
left join (select offer_id,offer_name from dws_crm_cfguse.dws_offer where city_id=200) c
on a.kd_prod_offer_id=c.offer_id 
where a.par_month_id>=202401 and a.par_month_id<=202506 
and date_format(a.open_date,'yyyyMM')=a.par_month_id 
and a.is_rh_ykj>0 and a.prod_type=40 and a.kd_desc = '普通宽带' 
and a.rh_type_ykj ='新宽带新移动' and a.rh_tc_value>=59 
and coalesce(b.prod_name, '-1') NOT LIKE '%专线%' 
and coalesce(b.prod_name, '-1') NOT LIKE '%城域网%' 
and coalesce(c.offer_name, '-1') NOT LIKE '%0时长%' 

union all 
select 'hydy' flag 
,cast(a.par_month_id as int) month_id
,cast(a.serv_id as string) serv_id_gt
,cast(a.region_type as string) region_type_gt 
,case when a.jz_points>=129 then 1 else 0 end is_gt  
,case when a.jz_points<59 then 0
when a.jz_points>=59 and a.jz_points<79 then 0.3
when a.jz_points>=79 and a.jz_points<129 then 0.5
when a.jz_points>=129 and a.jz_points<199 then 1
when a.jz_points>=199 and a.jz_points<299 then 1.5
when a.jz_points>=299 and a.jz_points<399 then 2
when a.jz_points>=399 then 2+cast((a.jz_points-299)/100 as int)*0.5
else 0 end acc_nbr_zs  
from dwm_yz_cm_cdma_hy_final a 
where par_month_id>=202401 and par_month_id<=202506 
and data_type='合约'
and is_new_user=1 
and prod_type1='后付费单产品' 
and is_jd='否' 
and cast(cast(sum_date as int)/100 as int)=cast(par_month_id as int)  

union all 
select 'hlwzx' flag 
,cast(a.par_month_id as int) month_id
,cast(a.serv_id as string) serv_id_gt
,cast(a.region_type as string) region_type_gt 
,1 is_gt  
,case when yz_cs>=299 and yz_cs<399 then 2 
when yz_cs>=399 and yz_cs<=5000 then ROUND(yz_cs/200) 
when yz_cs>5000 then 25 else 0 end acc_nbr_zs
from ads_yz_sx_qlyz_list a 
where par_month_id>=202401 and par_month_id<=202506 
and date_format(open_date,'yyyyMM')=par_month_id  
and bh_type='新入网' and prod_id in (48,57) and yz_cs>=59
;

--XQGZ2025070901736 需求标题 商客中心需求新增cdap公众营服商业网格公司名入网报表  陈展鹏 
-- drop table ads_yz_dim_XQGZ2025070901736_gzyf purge;  --公众营服维表
-- create table ads_yz_dim_XQGZ2025070901736_gzyf 
-- row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
-- as 
-- select index1 as xuhao 
-- ,index2 as subat_name 
-- ,index3 as branch_changjing 
-- ,index4 as six_market_1 
-- ,index5 as branch_name_hr 
-- ,index6 as branch_name_yz 
-- ,index7 as branch_name_op 
-- ,index8 as branch_type 
-- ,index9 as addr_name 
-- ,index10 as branch_staff_name 
-- ,index11 as phone_nbr 
-- ,index12 as six_market_2 
-- from zone_gz_3351225714708480;

-- drop table if exists ads_yz_XQGZ2025070901736_list purge;
-- create table if not exists ads_yz_XQGZ2025070901736_list 
-- ( 
-- sum_date string, 
-- cust_id decimal(22,0), 
-- cust_nbr varchar(30), 
-- serv_id decimal(22,0), 
-- subst_id decimal(22,0), 
-- subst_name varchar(100), 
-- branch_id decimal(22,0), 
-- branch_name varchar(100), 
-- area_id decimal(22,0), 
-- area_name varchar(100), 
-- region_type varchar(100), 
-- cell_id decimal(22,0), 
-- cell_code varchar(20), 
-- cell_name string, 
-- cell_type_name string, 
-- sales_code varchar(100), 
-- sales_name string,  
-- is_gsm decimal(20,0), 
-- open_date timestamp, 
-- branch_name_45 string, 
-- is_xz_sq string, 
-- is_xz_xwict string, 
-- is_xz_fttr string, 
-- is_xz_ydn string 
-- ) 
-- partitioned by ( par_month_id int ) 
-- row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy');

--是否叠加小微ICT、是否叠加FTTR、是否叠加云电脑
drop table tmp_yz_XQGZ2025070901736_01 purge;
create table tmp_yz_XQGZ2025070901736_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select date_format(a.open_date,'yyyyMM') month_id,a.serv_id,a.cust_id,b.prod_offer_id,b.prod_offer_code,b.prod_offer_name,b.prod_offer_type
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a
join zone_gz_yz.dwd_yz_dim_sk_ict_offer b on a.prod_offer_id = b.prod_offer_id
where date_format(a.open_date,'yyyyMMdd') between cast(${yyyymmdd}/100 as int)*100+1 and ${yyyymmdd}; 

--是否新增商企用户
drop table tmp_yz_XQGZ2025070901736_02 purge;
create table tmp_yz_XQGZ2025070901736_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,cust_id 
from zone_gz_yz.ads_yz_shangqi_rw_list 
where cast(par_month_id as int)=cast(${yyyymmdd}/100 as int) 
group by par_month_id,cust_id 
;

--抽取宽带新装清单
--划小区县分公司、划小营服、划小营服id、网格名称、网格编码、网格属性、产权客户编码、产品大类、产品小类、
--宽带揽装工号、当月新装业务价值积分、是否公司名
drop table tmp_yz_XQGZ2025070901736_03 purge;
create table tmp_yz_XQGZ2025070901736_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.sum_date,a.par_month_id,a.serv_id,a.acc_nbr,a.subst_id,a.subst_name,a.branch_id,a.branch_name 
,a.area_id,a.area_name,a.region_type,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.sales_code,a.sales_name 
,a.jz_points,a.rh_tc_value,a.cust_id,a.cust_nbr,a.is_gsm,a.open_date,a.kd_desc,a.prod_type3,a.prod_type2 
,case when b.branch_name is not null and c.area_name is not null then c.branch_name_45
when b.branch_name is not null then a.branch_name
when b.branch_name is null then a.branch_name
else '' end branch_name_45 
from zone_gz_yz.ads_yz_kd_new_list a 
LEFT JOIN (select branch_name from zone_gz_yz.ads_yz_45_dim_branch group by branch_name) b
on a.branch_name=b.branch_name
LEFT JOIN zone_gz_yz.ads_yz_45_dim_branch c
on a.branch_name=c.branch_name and a.area_name=c.area_name 
where cast(a.par_month_id as int)=cast(${yyyymmdd}/100 as int) 
and a.cell_type_name in ('商业楼宇','产业园区','专业市场') 
;

drop table tmp_yz_XQGZ2025070901736_04 purge;
create table tmp_yz_XQGZ2025070901736_04 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.cust_id is not null then '是' else '否' end is_xz_sq 
,case when c.cust_id is not null then '是' else '否' end is_xz_xwict 
,case when d.cust_id is not null then '是' else '否' end is_xz_fttr 
,case when e.cust_id is not null then '是' else '否' end is_xz_ydn 
from tmp_yz_XQGZ2025070901736_03 a 
left join tmp_yz_XQGZ2025070901736_02 b on a.cust_id=b.cust_id 
left join (select cust_id from tmp_yz_XQGZ2025070901736_01 where prod_offer_type='小微ICT' group by cust_id ) c on a.cust_id=c.cust_id 
left join (select cust_id from tmp_yz_XQGZ2025070901736_01 where prod_offer_type='FTTR' group by cust_id ) d on a.cust_id=d.cust_id 
left join (select cust_id from tmp_yz_XQGZ2025070901736_01 where prod_offer_type='云电脑' group by cust_id ) e on a.cust_id=e.cust_id 
;

drop table tmp_yz_XQGZ2025070901736_05 purge;
create table tmp_yz_XQGZ2025070901736_05 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
from tmp_yz_XQGZ2025070901736_04 a 
left join ads_yz_dim_XQGZ2025070901736_gzyf b on a.branch_name_45=b.branch_name_op 
where b.branch_name_op is not null 
; 

drop table tmp_yz_XQGZ2025070901736_06 purge;
create table tmp_yz_XQGZ2025070901736_06 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,row_number() over(partition by cust_nbr order by open_date) as paixu 
from tmp_yz_XQGZ2025070901736_05 a 
; 

alter table ads_yz_XQGZ2025070901736_list drop if exists partition(par_month_id=${yyyymm});
insert into table ads_yz_XQGZ2025070901736_list(sum_date,cust_id,cust_nbr,serv_id,subst_id
,subst_name,branch_id,branch_name,area_id,area_name,region_type,cell_id,cell_code
,cell_name,cell_type_name,sales_code,sales_name 
,is_gsm,open_date,branch_name_45,is_xz_sq,is_xz_xwict,is_xz_fttr,is_xz_ydn,par_month_id) 
select sum_date,cust_id,cust_nbr,serv_id,subst_id
,subst_name,branch_id,branch_name,area_id,area_name,region_type,cell_id,cell_code
,cell_name,cell_type_name,sales_code,sales_name 
,is_gsm,open_date,branch_name_45,is_xz_sq,is_xz_xwict,is_xz_fttr,is_xz_ydn
,cast(par_month_id as int) from tmp_yz_XQGZ2025070901736_06 a where paixu=1;


--20250718  邱智乐
移动用户升级融合特惠_300M宽带YD4G02-567-1-3
移动用户升级融合特惠_200M宽带YD4G02-567-1-2
移动用户升级融合特惠_100M宽带YD4G02-567-1-1
2501-2506月订购了这几个销售品之一的宽带数，然后按宽带号码出25年总收入

drop table tmp_yz_liq_01 purge;
create table tmp_yz_liq_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subst_id,c.org_name subst_name,a.serv_id,a.prod_offer_id,b.prod_offer_code,date_format(a.subs_stat_date,'yyyyMM') xz_month 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
left join (select distinct offer_id,offer_name,prod_offer_code from dws_crm_cfguse.dws_offer where city_id='200') b 
on a.prod_offer_id=b.offer_id 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) c on a.subst_id=c.org_id 
where 1=1 and a.par_month_id between 202501 and 202506 and  a.subs_stat = '301200' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')
and date_format(a.subs_stat_date,'yyyyMM') >= '202501' 
and date_format(a.subs_stat_date,'yyyyMM') <= '202506'
and a.action_id in( 1292,6200 )
and b.prod_offer_code in('YD4G02-567-1-3','YD4G02-567-1-2','YD4G02-567-1-1') 
; 

drop table tmp_yz_liq_02 purge;
create table tmp_yz_liq_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subst_name,a.serv_id from tmp_yz_liq_01 a group by a.subst_name,a.serv_id; 

drop table tmp_yz_liq_03 purge;
create table tmp_yz_liq_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.sh_qr  
from tmp_yz_liq_02 a 
left join (select serv_id, 
		sum(a0) as sh_qr --税后确认收入  
		from zone_gz_yz.dwm_srhx_serv_list_mon_final
		where par_month_id >= 202501 and par_month_id<=202506 
		group by serv_id) b on a.serv_id=b.serv_id 
;

select subst_name,count(serv_id) nums ,sum(sh_qr) fee from tmp_yz_liq_03 group by subst_name 

--20250718 赖宇鑫  XQGZ2025071600822 需求标题 关于美团明厨亮灶新清单（南沙、从化区域）网格和营服信息匹配的需求  
drop table tmp_yz_XQGZ2025071600822_01 purge;
create table tmp_yz_XQGZ2025071600822_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select index1 as second_city_name 
,index2 as xuhao 
,index3 as third_city_name 
,index4 as primary_first_tag_name  
,index5 as wm_poi_name 
,index6 as poi_address 
,index7 as addr_id_7  
,index8 as serv_addr_7  
,index9 as zqd  
from zone_gz_yz_3351225714708480 ; 

drop table tmp_yz_XQGZ2025071600822_02 purge;
create table tmp_yz_XQGZ2025071600822_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select addr_id_7,grid_unit_name,subst_name,branch_name 
from ads_yz_tyks_addr_7 where par_month_id=202507 
group by addr_id_7,grid_unit_name,subst_name,branch_name 
; 

drop table tmp_yz_XQGZ2025071600822_03 purge;
create table tmp_yz_XQGZ2025071600822_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.subst_name,b.branch_name,b.grid_unit_name 
from tmp_yz_XQGZ2025071600822_01 a 
left join tmp_yz_XQGZ2025071600822_02 b on cast(a.addr_id_7 as decimal(24,0))=b.addr_id_7 
;

alter table tmp_yz_XQGZ2025071600822_03 rename to ads_yz_XQGZ2025071600822_list;

drop view view_ads_yz_XQGZ2025071600822_list;
create view view_ads_yz_XQGZ2025071600822_list as 
select second_city_name,xuhao,third_city_name,primary_first_tag_name 
,addr_id_7,zqd,subst_name,branch_name,grid_unit_name
from zone_gz_yz.ads_yz_XQGZ2025071600822_list ; 

--20250728  张晓明
统计线上代理商近6个月的业务量，用channel_subtype_flag这个字段统计“分销代理（网上卖场）+新型跨界”
1、统计800元包年近6个月的业务量（按月展示），相关销售品为：【DM0001-668-1-11，固网宽带100M单产品套餐（100元/月）】+【DM0001-751-1-2，宽带预存包期优惠_800元_12个月】当月同时办理
2、统计1400元包年近6个月的业务量（按月展示），相关销售品为：【DM0001-668-1-13，固网宽带单产品套餐300M_200元/月】+【DM0001-481-1-1，宽带预存7个月套餐费包年优惠】当月同时办理
3、统计新装融合近6个月的业务量（按月展示）
500047226 DM0001-668-1-11
500050200 DM0001-751-1-2

100016850 DM0001-481-1-1
500050149 DM0001-668-1-13


drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id,channel_subtype_flag  
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202501' 
and date_format(a.subs_stat_date,'yyyyMM') <= '202506' 
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(500047226,500050200)  

union all 
select date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id,channel_subtype_flag  
from dwm_yz_rpt_comm_ba_msdisc_final a 
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') = '202507' 
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(500047226,500050200)  
; 

drop table tmp_yz_liq_zxm_02 purge;
create table tmp_yz_liq_zxm_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id,channel_subtype_flag 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202501' 
and date_format(a.subs_stat_date,'yyyyMM') <= '202506' 
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(100016850,500050149)  

union all 
select date_format(a.subs_stat_date,'yyyyMM') sl_month,prod_offer_id,a.serv_id,channel_subtype_flag 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') = '202507' 
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(100016850,500050149)  
; 

drop table tmp_yz_liq_zxm_03 purge;
create table tmp_yz_liq_zxm_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,prod_offer_id,a.serv_id from 
tmp_yz_liq_zxm_01 a 
group by sl_month,prod_offer_id,a.serv_id ; 

drop table tmp_yz_liq_zxm_04 purge;
create table tmp_yz_liq_zxm_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,prod_offer_id,a.serv_id from 
tmp_yz_liq_zxm_02 a 
group by sl_month,prod_offer_id,a.serv_id ;

drop table tmp_yz_liq_zxm_05 purge;
create table tmp_yz_liq_zxm_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,serv_id,count(distinct prod_offer_id ) nums 
from tmp_yz_liq_zxm_03 group by sl_month,serv_id ;

drop table tmp_yz_liq_zxm_06 purge;
create table tmp_yz_liq_zxm_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,serv_id,count(distinct prod_offer_id ) nums 
from tmp_yz_liq_zxm_04 group by sl_month,serv_id ;

drop table tmp_yz_liq_zxm_07 purge;
create table tmp_yz_liq_zxm_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.nums from tmp_yz_liq_zxm_01 a 
left join tmp_yz_liq_zxm_05 b on a.sl_month=b.sl_month and a.serv_id=b.serv_id 
;

drop table tmp_yz_liq_zxm_08 purge;
create table tmp_yz_liq_zxm_08  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.nums from tmp_yz_liq_zxm_02 a 
left join tmp_yz_liq_zxm_06 b on a.sl_month=b.sl_month and a.serv_id=b.serv_id 
;

drop table tmp_yz_liq_zxm_09 purge;
create table tmp_yz_liq_zxm_09  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select '800元包年' flag,sl_month,channel_subtype_flag,count(distinct serv_id) value1 
from tmp_yz_liq_zxm_07 where nums>=2 
group by sl_month,channel_subtype_flag  

union all 
select '1400元包年' flag,sl_month,channel_subtype_flag,count(distinct serv_id) value1 
from tmp_yz_liq_zxm_08 where nums>=2 
group by sl_month,channel_subtype_flag 
;

drop table tmp_yz_liq_zxm_10 purge;
create table tmp_yz_liq_zxm_10  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,channel_subtype_flag,count(serv_id) xzrh 
from dwm_yz_tb_comm_cm_all_mon_final a 
where par_month_id>=202501 and par_month_id<=202506 
and prod_type=40 and is_rh_ykj=1 and rh_type_ykj in('新宽带新移动','新宽带老移动') 
and coalesce(prod_type2,-1)<>50 
group by par_month_id,channel_subtype_flag 

union all 
select par_month_id,channel_subtype_flag,count(serv_id) xzrh  
from dwm_yz_tb_comm_cm_all_final a 
where par_month_id=202507 
and prod_type=40 and is_rh_ykj=1 and rh_type_ykj in('新宽带新移动','新宽带老移动') 
and coalesce(prod_type2,-1)<>50 
group by par_month_id,channel_subtype_flag 
;

--20250731 531周参数
if [[ stat_date -ge 20250801 ]] && [[ stat_date -le 20250804 ]];then
      this_month_first_date=20250801
      last_month_first_date=20250701
      monday=20250801
      sunday=20250810 
      stat_day_last_week=`date -d "$stat_day -4day" +%Y%m%d`               
      stat_day_last_monday=20250728
      stat_day_last_sunday=20250731
fi 

if [[ stat_date -ge 20250805 ]] && [[ stat_date -le 20250810 ]];then
      this_month_first_date=20250801
      last_month_first_date=20250701
      monday=20250801
      sunday=20250810 
      stat_day_last_week=20250731                
      stat_day_last_monday=20250728
      stat_day_last_sunday=20250731
fi 

if [[ stat_date -ge 20250811 ]] && [[ stat_date -le 20250817 ]];then
      this_month_first_date=20250801
      last_month_first_date=20250701
      monday=20250811
      sunday=20250817 
      stat_day_last_week=`date -d "$stat_day -7day" +%Y%m%d`                          
      stat_day_last_monday=20250801
      stat_day_last_sunday=20250810
fi 

if [[ stat_date -ge 20250818 ]] && [[ stat_date -le 20250824 ]];then
      this_month_first_date=20250801
      last_month_first_date=20250701
      monday=20250818
      sunday=20250824 
      stat_day_last_week=`date -d "$stat_day -7day" +%Y%m%d`                      
      stat_day_last_monday=20250811
      stat_day_last_sunday=20250817
fi 

if [[ stat_date -ge 20250825 ]] && [[ stat_date -le 20250831 ]];then
      this_month_first_date=20250801
      last_month_first_date=20250701
      monday=20250825
      sunday=20250831 
      stat_day_last_week=`date -d "$stat_day -7day" +%Y%m%d`                      
      stat_day_last_monday=20250818
      stat_day_last_sunday=20250824
fi 

--20250807  宽带续约清单备份
drop table ads_yz_kd_xy_list_have_jk_bf_20250807 purge;
create table ads_yz_kd_xy_list_have_jk_bf_20250807 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as select * from ads_yz_kd_xy_list_have_jk;

drop table ads_yz_kd_xy_list_bf_20250807 purge;
create table ads_yz_kd_xy_list_bf_20250807 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as select * from ads_yz_kd_xy_list;

create table tmp_huisu_ads_yz_kd_xy_pz_20250811 
like ads_yz_kd_xy_pz
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy');

--循环回溯 ads_yz_kd_xy_pz 
流程：李倩-测试-宽带续约拍照表回溯
alter table ads_yz_kd_xy_pz rename to ads_bf_ads_yz_kd_xy_pz_20250811;
alter table tmp_huisu_ads_yz_kd_xy_pz_20250811 rename to ads_yz_kd_xy_pz;


--20250807  宽带新装清单 年中回溯
create table tmp_huisu_ads_yz_kd_new_list_20250807 
like ads_yz_kd_new_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy'); 

循环回溯
流程：李倩-测试-宽带新装 裂变回溯

alter table tmp_huisu_ads_yz_kd_new_list_20250807 drop partition(par_month_id='202508');
alter table tmp_huisu_ads_yz_kd_new_list_20250807 add partition(par_month_id='202508',par_sum_date='20250807');
insert into table tmp_huisu_ads_yz_kd_new_list_20250807 partition(par_month_id='202508',par_sum_date='20250807')
(sum_date,month_id,serv_id,acc_nbr,subs_id,subs_code,subs_stat_date,subst_id,subst_name,branch_id
,branch_name,area_id,area_name,grid_id,grid_code,grid_name,region_type,std_subst_id,std_subst_name
,std_branch_id,std_branch_name,cell_id,cell_code,cell_name,cell_type_name,bg_type,bu_type,is_mdz
,six_market,serv_grp_type,sales_code,sales_name,channel_id,channel_nbr,channel_name,channel_subst_name
,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011,channel_subtype_2011
,channel_subtype0_2011,state,prod_id,is_zhuanxian,kd_desc,prod_type3,prod_type2,itv_type
,kd_prod_offer_id,speed_value,jz_points,is_rh_ykj,rh_tc_value,acc_nbr2,fttx_type,cust_id
,cust_nbr,cust_name,cust_code,ccust_name,ccust_org,is_gsm,serv_addr_id,serv_addr_name
,addr_id_7,open_date,is_sk_xjd,is_ljsp,is_yqjq,prod_name,kd_prod_offer_code,kd_prod_offer_name
,six_market_desc,serv_grp_type_desc,channel_subtype_flag,is_shangqi_dx,kuayv_offer_name
,grid_unit_area_id,mgr_area_id,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1,xx_salestaff_code1
,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,ycx_offer_type
,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,cdma_disc_type3_name
,label_name,load_date,fk_lx,fk_value,kd_ll,kd_sc,is_hy,fee_shebei,fee_tiaoce,seq_id
,main_prod_offer_name,is_zxyb,is_lb_hy,addr_name_7,cntrt_type_cbxl_name,kq_type,act_date
,salestaff_subst_name,salestaff_branch_name 
)
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id,a.subs_code,a.subs_stat_date,a.subst_id,a.subst_name
,a.branch_id 

,a.branch_name 

,a.area_id,a.area_name,a.grid_id,a.grid_code,a.grid_name,a.region_type,a.std_subst_id,a.std_subst_name
,a.std_branch_id 

,a.std_branch_name

,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type,a.is_mdz
,a.six_market,a.serv_grp_type,a.sales_code,a.sales_name,a.channel_id,a.channel_nbr,a.channel_name,a.channel_subst_name
,a.channel_branch_name,a.channel_area_name,a.channel_region_type,a.channel_type_2011,a.channel_subtype_2011
,a.channel_subtype0_2011,a.state,a.prod_id,a.is_zhuanxian,a.kd_desc,a.prod_type3,a.prod_type2,a.itv_type
,a.kd_prod_offer_id,a.speed_value,a.jz_points,a.is_rh_ykj,a.rh_tc_value,a.acc_nbr2,a.fttx_type,a.cust_id
,a.cust_nbr,a.cust_name,a.cust_code,a.ccust_name,a.ccust_org,a.is_gsm,a.serv_addr_id,a.serv_addr_name
,a.addr_id_7,a.open_date,a.is_sk_xjd,a.is_ljsp,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name
,a.six_market_desc,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx,a.kuayv_offer_name
,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1,a.xx_salestaff_code1
,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2,a.xx_salestaff_name2,a.ycx_offer_type
,a.own_operators_nbr,a.own_operators_name,a.is_zhuangwei,a.is_sheng_yx,a.cdma_disc_type3_name
,a.label_name,a.load_date,a.fk_lx,a.fk_value,a.kd_ll,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce,a.seq_id
,a.main_prod_offer_name,a.is_zxyb,a.is_lb_hy,a.addr_name_7,a.cntrt_type_cbxl_name,a.kq_type,a.act_date
,a.salestaff_subst_name,a.salestaff_branch_name 
from ads_yz_kd_new_list a 
where a.par_month_id=202508  
; 

alter table ads_yz_kd_new_list rename to ads_bf_ads_yz_kd_new_list_20250808;
alter table tmp_huisu_ads_yz_kd_new_list_20250807 rename to ads_yz_kd_new_list;

--XQGZ2025081101191 需求标题 关于查询87601531D2019年网速的需求单 
drop table tmp_yz_XQGZ2025081101191_01 purge;
create table tmp_yz_XQGZ2025081101191_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end action_type_desc 
,subs_stat_date ,act_date,a.action_id,b.action_name  
,c.org_name as  salestaff_subst_name,d.org_name as  salestaff_branch_name 
from dwm_yz_rpt_comm_ba_subs_mon_final a 
left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
on a.action_id=b.action_id 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) c on a.salestaff_subst_id=c.org_id 
left join (select distinct org_id,org_name from zone_gz_yz.dwd_yz_dim_org) d on a.salestaff_branch_id=d.org_id 
where a.par_month_id>='202012' and a.par_month_id<='202212' 
and date_format(act_date,'yyyyMM')>='202012' 
and date_format(act_date,'yyyyMM')<='202212' 
and a.acc_nbr='87601531D' 
and a.subs_stat='301200' 
and a.subs_stat_reason not in( '1200','1300' )  --非撤单/非作废 
group by subs_id,subs_code
, acc_nbr,prod_id 
,salestaff_id,sales_code
,sales_man_name,salestaff_subst_id,salestaff_branch_id 
,case when action_type='NEW' then '新装' when action_type='CANCEL' then '拆机' when action_type='MOVE' then '移机'  else action_type end  
,subs_stat_date ,act_date,a.action_id,b.action_name,c.org_name,d.org_name ;

drop table tmp_yz_XQGZ2025081101191_02 purge;
create table tmp_yz_XQGZ2025081101191_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.acc_nbr,a.serv_id,a.par_month_id,a.speed_value 
,c.attr_value_name speed_value_ty 
from dwm_yz_tb_comm_cm_all_mon_final a 
left join iodata_ods_month_city.tb_pre_cm_attr_all_mon b 
on b.par_corp_id='200' and b.attr_id='671' and a.par_month_id=b.par_month_id and a.serv_id=b.serv_id 
left join dws_crm_cfguse.dws_attr_value c on b.attr_value1=c.attr_inner_value and c.city_id='200' and b.attr_id=c.attr_id 
where a.par_month_id>=202012 and a.par_month_id<=202212 
and a.acc_nbr='87601531D' ; 

--20250821  
修改小业务宽表配置表：
drop table dwd_dim_all_config_bf_20250625 purge;
create table dwd_dim_all_config_bf_20250821 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from dwd_dim_all_config;--780

--select distinct offer_id,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200 and prod_offer_code in()

drop table tmp_dwd_dim_all_config_xz;--80
create table tmp_dwd_dim_all_config_xz as 
select cast(index1  as int) seq_id
,cast(index2  as string) seq_name
,cast(index3  as int) seq_value_id
,cast(index4  as string) seq_value_code
,cast(index5  as string) create_date
,cast(index6  as string) create_man
,cast(index7  as string) state_desc
,cast(index8  as string) reamark
,cast(index9  as string) reamark_bc
,cast(index10  as string) seq_type
from zone_gz_yz_3351225714708480;

insert overwrite table dwd_dim_all_config
select seq_id,seq_name,seq_value_id,seq_value_code,create_date,create_man,state_desc,reamark,reamark_bc,seq_type from (
select seq_id,seq_name,seq_value_id,seq_value_code,create_date,create_man,state_desc,reamark,reamark_bc,seq_type  
from dwd_dim_all_config_bf_20250821 where COALESCE(seq_id,-1) not in(13)
union all
select seq_id,seq_name,seq_value_id,seq_value_code,create_date,create_man,state_desc,reamark,reamark_bc,seq_type 
from tmp_dwd_dim_all_config_xz ) a;

--20250827  谢钊铭 XQGZ2025082602493 
drop table tmp_yz_XQGZ2025082602493_01 purge;
create table tmp_yz_XQGZ2025082602493_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select index1 as create_date 
,index2 as acc_nbr2 
,index3 as acc_nbr 
,index4 as gsw_sx 
,index5 as ATTRIBUTE_417 
,index6 as ATTRIBUTE_418 
,index7 as last_time_create 
,index8 as city_name 
from zone_gz_yz_3351225714708480 a; 

drop table tmp_yz_XQGZ2025082602493_02 purge;
create table tmp_yz_XQGZ2025082602493_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select acc_nbr,b.open_date,b.subst_name,b.branch_name,b.area_name,b.cust_nbr
,case when b.is_gsm=1 then '企业名' else '个人名' end gsm_flag 
,b.cust_code
,case when b.serv_grp_type='01' then '政企' when b.serv_grp_type='02' then '公众' else '其他' end as serv_grp_type_desc 
,b.serv_addr_id,b.sales_code,b.sales_name,b.bg_type 
,row_number() over(partition by acc_nbr order by open_date desc ) paixu 
from dwm_yz_tb_comm_cm_all_final b 
where b.par_month_id=202508 ;

drop table tmp_yz_XQGZ2025082602493_03 purge;
create table tmp_yz_XQGZ2025082602493_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.acc_nbr is not null then 1 else 0 end as is_acc_nbr 
,b.open_date,b.subst_name,b.branch_name,b.area_name,b.cust_nbr
,b.gsm_flag,b.cust_code,b.serv_grp_type_desc,b.serv_addr_id,b.sales_code,b.sales_name,b.bg_type  
from tmp_yz_XQGZ2025082602493_01 a 
left join tmp_yz_XQGZ2025082602493_02 b on a.acc_nbr=b.acc_nbr and b.paixu=1; 

drop table tmp_yz_XQGZ2025082602493_04 purge;
create table tmp_yz_XQGZ2025082602493_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_nbr 
,count(distinct case when acc_nbr is not null and acc_nbr<>'' then acc_nbr else null end ) nums 
from tmp_yz_XQGZ2025082602493_03 a group by cust_nbr; 

drop table tmp_yz_XQGZ2025082602493_05 purge;
create table tmp_yz_XQGZ2025082602493_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,case when b.nums>3 then 1 else 0 end is_same_cust 
from tmp_yz_XQGZ2025082602493_03 a 
left join tmp_yz_XQGZ2025082602493_04 b 
on a.cust_nbr=b.cust_nbr and b.cust_nbr is not null and b.cust_nbr<>''; 

drop table tmp_yz_XQGZ2025082602493_06 purge;
create table tmp_yz_XQGZ2025082602493_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_addr_id
,count(distinct case when acc_nbr is not null and acc_nbr<>'' then acc_nbr else null end ) nums 
from tmp_yz_XQGZ2025082602493_03 a group by serv_addr_id; 

drop table tmp_yz_XQGZ2025082602493_07 purge;
create table tmp_yz_XQGZ2025082602493_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,case when b.nums>3 then 1 else 0 end is_same_addr  
from tmp_yz_XQGZ2025082602493_05 a 
left join tmp_yz_XQGZ2025082602493_06 b 
on a.serv_addr_id=b.serv_addr_id and b.serv_addr_id is not null and b.serv_addr_id<>''; 

drop table tmp_yz_XQGZ2025082602493_08 purge;
create table tmp_yz_XQGZ2025082602493_08  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 0 susbt_order,'广州' subst_name 
,count(distinct acc_nbr) value1 
,count(distinct case when gsm_flag='个人名' then acc_nbr else null end ) value2 
,count(distinct case when gsm_flag='企业名' then acc_nbr else null end ) value3 

,count(distinct case when is_same_cust=1 then cust_nbr else null end ) value4 
,count(distinct case when is_same_cust=1 and gsm_flag='个人名' then cust_nbr else null end ) value5 
,count(distinct case when is_same_cust=1 and gsm_flag='企业名' then cust_nbr else null end ) value6 

,count(distinct case when is_same_cust=1 then acc_nbr else null end ) value7
,count(distinct case when is_same_cust=1 and gsm_flag='个人名' then acc_nbr else null end ) value8 
,count(distinct case when is_same_cust=1 and gsm_flag='企业名' then acc_nbr else null end ) value9

,count(distinct case when is_same_addr=1 then cust_nbr else null end ) value10
,count(distinct case when is_same_addr=1 and gsm_flag='个人名' then cust_nbr else null end ) value11
,count(distinct case when is_same_addr=1 and gsm_flag='企业名' then cust_nbr else null end ) value12 

,count(distinct case when is_same_addr=1 then acc_nbr else null end ) value13
,count(distinct case when is_same_addr=1 and gsm_flag='个人名' then acc_nbr else null end ) value14
,count(distinct case when is_same_addr=1 and gsm_flag='企业名' then acc_nbr else null end ) value15

,count(distinct case when is_same_cust=1 and is_same_addr=1 then cust_nbr else null end ) value16
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='个人名' then cust_nbr else null end ) value17
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='企业名' then cust_nbr else null end ) value18 

,count(distinct case when is_same_cust=1 and is_same_addr=1 then acc_nbr else null end ) value19
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='个人名' then acc_nbr else null end ) value20
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='企业名' then acc_nbr else null end ) value21
from tmp_yz_XQGZ2025082602493_07 a 
where acc_nbr is not null and acc_nbr<>'' and acc_nbr<>'0'; 

insert into table tmp_yz_XQGZ2025082602493_08 
select case when subst_name='天河分公司' then 1 
when subst_name='番禺分公司' then 2 
when subst_name='白云分公司' then 3 
when subst_name='越秀分公司' then 4  
when subst_name='海珠分公司' then 5 
when subst_name='荔湾分公司' then 6 
when subst_name='黄埔分公司' then 7 
when subst_name='增城分公司' then 8 
when subst_name='花都分公司' then 9 
when subst_name='南沙分公司' then 10 
when subst_name='从化分公司' then 11 else 22 end susbt_order,subst_name  
,count(distinct acc_nbr) value1 
,count(distinct case when gsm_flag='个人名' then acc_nbr else null end ) value2 
,count(distinct case when gsm_flag='企业名' then acc_nbr else null end ) value3 

,count(distinct case when is_same_cust=1 then cust_nbr else null end ) value4 
,count(distinct case when is_same_cust=1 and gsm_flag='个人名' then cust_nbr else null end ) value5 
,count(distinct case when is_same_cust=1 and gsm_flag='企业名' then cust_nbr else null end ) value6 

,count(distinct case when is_same_cust=1 then acc_nbr else null end ) value7
,count(distinct case when is_same_cust=1 and gsm_flag='个人名' then acc_nbr else null end ) value8 
,count(distinct case when is_same_cust=1 and gsm_flag='企业名' then acc_nbr else null end ) value9

,count(distinct case when is_same_addr=1 then cust_nbr else null end ) value10
,count(distinct case when is_same_addr=1 and gsm_flag='个人名' then cust_nbr else null end ) value11
,count(distinct case when is_same_addr=1 and gsm_flag='企业名' then cust_nbr else null end ) value12 

,count(distinct case when is_same_addr=1 then acc_nbr else null end ) value13
,count(distinct case when is_same_addr=1 and gsm_flag='个人名' then acc_nbr else null end ) value14
,count(distinct case when is_same_addr=1 and gsm_flag='企业名' then acc_nbr else null end ) value15

,count(distinct case when is_same_cust=1 and is_same_addr=1 then cust_nbr else null end ) value16
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='个人名' then cust_nbr else null end ) value17
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='企业名' then cust_nbr else null end ) value18 

,count(distinct case when is_same_cust=1 and is_same_addr=1 then acc_nbr else null end ) value19
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='个人名' then acc_nbr else null end ) value20
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='企业名' then acc_nbr else null end ) value21
from tmp_yz_XQGZ2025082602493_07 a 
where acc_nbr is not null and acc_nbr<>'' and acc_nbr<>'0'
group by case when subst_name='天河分公司' then 1 
when subst_name='番禺分公司' then 2 
when subst_name='白云分公司' then 3 
when subst_name='越秀分公司' then 4  
when subst_name='海珠分公司' then 5 
when subst_name='荔湾分公司' then 6 
when subst_name='黄埔分公司' then 7 
when subst_name='增城分公司' then 8 
when subst_name='花都分公司' then 9 
when subst_name='南沙分公司' then 10 
when subst_name='从化分公司' then 11 else 22 end,subst_name; 

insert into table tmp_yz_XQGZ2025082602493_08 
select case when bg_type='数字政府' then 12 
when bg_type='政法公安' then 13     
when bg_type='文旅综合' then 14     
when bg_type='智慧城市' then 15  
when bg_type='卫健' then 16     
when bg_type='工业制造' then 17   
when bg_type='交通物流' then 18 
when bg_type='金融' then 19   
when bg_type='互联网' then 20 
when bg_type='教育' then 21  else 23 end susbt_order,bg_type  
,count(distinct acc_nbr) value1 
,count(distinct case when gsm_flag='个人名' then acc_nbr else null end ) value2 
,count(distinct case when gsm_flag='企业名' then acc_nbr else null end ) value3 

,count(distinct case when is_same_cust=1 then cust_nbr else null end ) value4 
,count(distinct case when is_same_cust=1 and gsm_flag='个人名' then cust_nbr else null end ) value5 
,count(distinct case when is_same_cust=1 and gsm_flag='企业名' then cust_nbr else null end ) value6 

,count(distinct case when is_same_cust=1 then acc_nbr else null end ) value7
,count(distinct case when is_same_cust=1 and gsm_flag='个人名' then acc_nbr else null end ) value8 
,count(distinct case when is_same_cust=1 and gsm_flag='企业名' then acc_nbr else null end ) value9

,count(distinct case when is_same_addr=1 then cust_nbr else null end ) value10
,count(distinct case when is_same_addr=1 and gsm_flag='个人名' then cust_nbr else null end ) value11
,count(distinct case when is_same_addr=1 and gsm_flag='企业名' then cust_nbr else null end ) value12 

,count(distinct case when is_same_addr=1 then acc_nbr else null end ) value13
,count(distinct case when is_same_addr=1 and gsm_flag='个人名' then acc_nbr else null end ) value14
,count(distinct case when is_same_addr=1 and gsm_flag='企业名' then acc_nbr else null end ) value15

,count(distinct case when is_same_cust=1 and is_same_addr=1 then cust_nbr else null end ) value16
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='个人名' then cust_nbr else null end ) value17
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='企业名' then cust_nbr else null end ) value18 

,count(distinct case when is_same_cust=1 and is_same_addr=1 then acc_nbr else null end ) value19
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='个人名' then acc_nbr else null end ) value20
,count(distinct case when is_same_cust=1 and is_same_addr=1 and gsm_flag='企业名' then acc_nbr else null end ) value21
from tmp_yz_XQGZ2025082602493_07 a 
where acc_nbr is not null and acc_nbr<>'' and acc_nbr<>'0' 
group by case when bg_type='数字政府' then 12 
when bg_type='政法公安' then 13     
when bg_type='文旅综合' then 14     
when bg_type='智慧城市' then 15  
when bg_type='卫健' then 16     
when bg_type='工业制造' then 17   
when bg_type='交通物流' then 18 
when bg_type='金融' then 19   
when bg_type='互联网' then 20 
when bg_type='教育' then 21  else 23 end,bg_type ; 

drop table ads_yz_XQGZ2025082602493_list purge;
create table ads_yz_XQGZ2025082602493_list  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* from tmp_yz_XQGZ2025082602493_07 a ;

--20250902  XQGZ2025081800530 需求标题 关于匹配企业云盘对应宽带号码的申请  
drop table tmp_yz_XQGZ2025081800530_01 purge;
create table tmp_yz_XQGZ2025081800530_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 202507 par_month_id,
index1 as paixu, 
index2 as sheng_id, 
index3 as city_id, 
index4 as acc_nbr, 
index5 as item_name  
from zone_gz_yz_3351225714708480 a;

insert into table tmp_yz_XQGZ2025081800530_01  
select 202508 par_month_id,
index1 as paixu, 
index2 as sheng_id, 
index3 as city_id, 
index4 as acc_nbr, 
index5 as item_name  
from zone_gz_yz_3351225714708480 a;

drop table tmp_yz_XQGZ2025081800530_02 purge;
create table tmp_yz_XQGZ2025081800530_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 202508 par_month_id,a.serv_id,a.acc_nbr,a.msinfo_id,a.create_date,a.prod_id,a.prod_offer_id,b.prod_offer_code,b.offer_name   
,row_number() over(partition by a.acc_nbr order by a.create_date desc) as paixu 
from dwd_yz_rpt_comm_cm_msdisc_final a 
join dwd_yz_dim_shangqi_dx b on a.prod_offer_id=b.offer_id 
where a.par_corp_id='200'
--and date_format(a.limit_date,'yyyyMMdd') > ${stat_date} 

union all 
select 202507 par_month_id,a.serv_id,a.acc_nbr,a.msinfo_id,a.create_date,a.prod_id,a.prod_offer_id,b.prod_offer_code,b.offer_name   
,row_number() over(partition by a.acc_nbr order by a.create_date desc) as paixu 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
join dwd_yz_dim_shangqi_dx b on a.prod_offer_id=b.offer_id 
where a.par_corp_id='200' and a.par_month_id=202507 
--and date_format(a.limit_date,'yyyyMMdd') > ${stat_date} 
;

drop table tmp_yz_XQGZ2025081800530_03 purge;
create table tmp_yz_XQGZ2025081800530_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.prod_type,b.subst_name,b.branch_name,b.area_name 
,b.std_subst_name,b.std_branch_name,b.cell_code,b.cell_name 
,b.cust_nbr,b.cust_name,b.serv_addr_id,b.is_vice_card 
,case when b.prod_type2=0 then 1 
	  when b.prod_type2=80 then 2 
	  when b.prod_type2=50 then 3 
	  when b.prod_type2=60 then 4 
	  else 5 end kd_paixu 
,case when upper(a.acc_nbr) like 'ADSLD%' then 1 else 0 end is_adsld 
,case when b.stm_data+b.mou_call+b.mgs_counts>=30 then 1 else 0 end as is_yd_hy 
from tmp_yz_XQGZ2025081800530_02 a 
left join dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and a.par_month_id=cast(b.par_month_id as int) 
;

drop table tmp_yz_XQGZ2025081800530_04 purge;
create table tmp_yz_XQGZ2025081800530_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.acc_nbr is not null then 1 else 0 end is_sq 
,b.msinfo_id,b.prod_offer_id,b.prod_offer_code,b.offer_name   
from tmp_yz_XQGZ2025081800530_01 a 
left join tmp_yz_XQGZ2025081800530_03 b on a.acc_nbr=b.acc_nbr and a.par_month_id=b.par_month_id and b.paixu=1 
; 

drop table tmp_yz_XQGZ2025081800530_05 purge;
create table tmp_yz_XQGZ2025081800530_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by a.par_month_id,a.msinfo_id order by a.is_vice_card asc, a.create_date desc) as paixu2 
from tmp_yz_XQGZ2025081800530_03 a 
where prod_type=30 ;

drop table tmp_yz_XQGZ2025081800530_06 purge;
create table tmp_yz_XQGZ2025081800530_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.acc_nbr as yd_acc_nbr,case when b.is_yd_hy=1 then '是' else '否' end is_hy  
from tmp_yz_XQGZ2025081800530_04 a 
left join tmp_yz_XQGZ2025081800530_05 b on a.msinfo_id=b.msinfo_id and a.par_month_id=b.par_month_id and b.paixu2=1 
;

drop table tmp_yz_XQGZ2025081800530_07 purge;
create table tmp_yz_XQGZ2025081800530_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by a.par_month_id,a.msinfo_id order by is_adsld desc,kd_paixu asc,a.create_date desc) as paixu2 
from tmp_yz_XQGZ2025081800530_03 a 
where prod_type=40 ;

drop table tmp_yz_XQGZ2025081800530_08 purge;
create table tmp_yz_XQGZ2025081800530_08  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.acc_nbr as kd_acc_nbr 
,b.subst_name,b.branch_name,b.area_name 
,b.std_subst_name,b.std_branch_name,b.cell_code,b.cell_name 
,b.cust_nbr,b.cust_name,b.serv_addr_id 
from tmp_yz_XQGZ2025081800530_06 a 
left join tmp_yz_XQGZ2025081800530_07 b on a.msinfo_id=b.msinfo_id and a.par_month_id=b.par_month_id and b.paixu2=1 
;

drop table ads_yz_XQGZ2025081800530_list purge;
create table ads_yz_XQGZ2025081800530_list  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from tmp_yz_XQGZ2025081800530_08;

--20250904 林正欣  业务id 业务名称 产品标识 拆机数量
drop table tmp_yz_liq_01 purge;
create table tmp_yz_liq_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select date_format(a.subs_stat_date,'yyyyMM') sl_month 
,a.action_id,b.action_name,a.prod_id,c.prod_name  
,count(distinct a.serv_id) nums 
from dwm_yz_rpt_comm_ba_subs_final a 
left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
on a.action_id=b.action_id 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) c on a.prod_id=c.prod_id 
where a.subs_stat in( '301200')  
and a.action_type='CANCEL' 
and date_format(a.subs_stat_date,'yyyyMM')='202509' 
group by date_format(a.subs_stat_date,'yyyyMM')  
,a.action_id,b.action_name,a.prod_id,c.prod_name  

union all 
select date_format(a.subs_stat_date,'yyyyMM') sl_month 
,a.action_id,b.action_name,a.prod_id,c.prod_name  
,count(distinct a.serv_id) nums 
from dwm_yz_rpt_comm_ba_subs_mon_final a 
left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
on a.action_id=b.action_id 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) c on a.prod_id=c.prod_id 
where a.par_month_id between 202507 and 202508 
and date_format(a.subs_stat_date,'yyyyMM')>='202507' 
and a.subs_stat in( '301200')  
and a.action_type='CANCEL' 
group by date_format(a.subs_stat_date,'yyyyMM')  
,a.action_id,b.action_name,a.prod_id,c.prod_name  
;

drop table tmp_yz_liq_02 purge;
create table tmp_yz_liq_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.prod_type 
from tmp_yz_liq_01 a 
left join (select prod_id,prod_type from dwm_yz_tb_comm_cm_all_final 
	where prod_type=40 and par_month_id>=202507 group by prod_id,prod_type) b 
on a.prod_id=b.prod_id ;

--20250909  XQGZ2025090801143 需求标题 批量下载广州市内全部“LSG”及“DSG”客户的业务信息  
drop table ads_yz_XQGZ2025090801143_list purge;
create table ads_yz_XQGZ2025090801143_list as 
select cust_name
,acc_nbr
,case when prod_type=40 then '宽带' when prod_type=30 then '移动' when prod_type=10 then '固话' else '其他' end prod_dl 
,a.prod_id 
,b.prod_name 
from dwm_yz_tb_comm_cm_all_final a 
left join (select distinct prod_id,prod_name from dws_crm_cfguse.dws_product) b on a.prod_id=b.prod_id 
where (a.cust_name like '%领事馆%' or a.cust_name like '%大使馆%') 
and a.par_month_id=202509 
;

--20250916  林秀云  XQGZ2025091600604 
drop table tmp_yz_XQGZ2025091600604_01 purge;
create table tmp_yz_XQGZ2025091600604_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select par_month_id,cast(cast(par_month_id as int)-1 as string) last_month,serv_id 
,subst_name,branch_name,area_name,region_type 
from dwm_yz_tb_comm_cm_all_mon_final a 
where par_month_id>=202503 and par_month_id<=202508 
and is_cancel_user = 0
and prod_type=40 
; 

drop table tmp_yz_XQGZ2025091600604_02 purge;
create table tmp_yz_XQGZ2025091600604_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.* 
,b.subst_name subst_name_last
,b.branch_name branch_name_last
,b.area_name area_name_last  
,b.region_type as region_type_last 
from tmp_yz_XQGZ2025091600604_01 a 
left join tmp_yz_XQGZ2025091600604_01 b on a.serv_id=b.serv_id and a.last_month=b.par_month_id 
;

drop table tmp_yz_XQGZ2025091600604_03 purge;
create table tmp_yz_XQGZ2025091600604_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.subst_name_last,a.branch_name_last,a.area_name_last 
,count(case when par_month_id=202504 then serv_id else null end ) as yc_202504 
,0 as yr_202504 
,count(case when par_month_id=202505 then serv_id else null end ) as yc_202505 
,0 as yr_202505 
,count(case when par_month_id=202506 then serv_id else null end ) as yc_202506 
,0 as yr_202506 
,count(case when par_month_id=202507 then serv_id else null end ) as yc_202507 
,0 as yr_202507 
,count(case when par_month_id=202508 then serv_id else null end ) as yc_202508 
,0 as yr_202508 
from tmp_yz_XQGZ2025091600604_02  a 
where coalesce(a.region_type,'-1')<>'城中村' and a.region_type_last='城中村' 
group by a.subst_name_last,a.branch_name_last,a.area_name_last  

union all 
select a.subst_name,a.branch_name,a.area_name 
,0 as yc_202504 
,count(case when par_month_id=202504 then serv_id else null end ) as yr_202504 
,0 as yc_202505 
,count(case when par_month_id=202505 then serv_id else null end ) as yr_202505 
,0 as yc_202506 
,count(case when par_month_id=202506 then serv_id else null end ) as yr_202506 
,0 as yc_202507 
,count(case when par_month_id=202507 then serv_id else null end ) as yr_202507 
,0 as yc_202508 
,count(case when par_month_id=202508 then serv_id else null end ) as yr_202508 
from tmp_yz_XQGZ2025091600604_02  a 
where coalesce(a.region_type_last,'-1')<>'城中村' and a.region_type='城中村' 
and a.region_type_last<>'' and a.region_type_last is not null 
group by a.subst_name,a.branch_name,a.area_name ;

SELECT a.subst_name_last, a.branch_name_last, a.area_name_last
, sum(yc_202504) AS v1 , sum(yr_202504) AS v2
, sum(yc_202505) AS v3 , sum(yr_202505) AS v4
, sum(yc_202506) AS v5 , sum(yr_202506) AS v6
, sum(yc_202507) AS v7 , sum(yr_202507) AS v8
, sum(yc_202508) AS v9 , sum(yr_202508) AS v10 
FROM tmp_yz_XQGZ2025091600604_03 a 
GROUP BY a.subst_name_last, a.branch_name_last, a.area_name_last LIMIT 1000

--20250916  张晓明
drop table if exists zone_gz_yz.tmp_kd_new_ycx_fee_null_list;
create table zone_gz_yz.tmp_kd_new_ycx_fee_null_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as 
select a.*,b.prod_offer_code,b.offer_name 
from dwd_yz_rpt_comm_cm_msdisc_mon_final a 
join ads_yz_kd_new_list c on a.serv_id=c.serv_id 
and c.par_month_id=202508 
AND c.kd_desc = '普通宽带' 
AND coalesce(c.prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(c.prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(c.kd_prod_offer_name, '-1') NOT LIKE '%0时长%' 
and c.fee_tiaoce is null 
left join dws_crm_cfguse.dws_offer b on a.prod_offer_id=b.offer_id and b.city_id=200 
where a.par_month_id=202508 
and date_format(a.open_date,'yyyyMM')<=202508 
; 

drop table tmp_kd_new_ycx_fee_null_dwb purge;
create table tmp_kd_new_ycx_fee_null_dwb as 
select par_month_id,prod_offer_id,prod_offer_code,offer_name,count(1) nums 
from tmp_kd_new_ycx_fee_null_list 
group by par_month_id,prod_offer_id,prod_offer_code,offer_name 
order by par_month_id,prod_offer_id,prod_offer_code,offer_name;

--20250917 张晓明
DM0001-695-1-1+YD5G01-021-1-1 --城中村59
DM0001-695-1-1+YD5G01-021-1-2 --城中村79
DM0001-695-1-1+YD5G01-018-1-1 --城中村99
DM0001-695-1-1+YD5G01-013-1-1 --城中村129
倩总 帮忙看看这4个档次近3个月的入网量有多少 口径按【这两个销售品同一个月竣工+已有DM0001-695-1-1销售品然后叠加受理后面那4条标】的求和
500049165	YD5G01-013-1-1
500046067	DM0001-695-1-1
500062213	YD5G01-018-1-1
500071624	YD5G01-021-1-1
500072704	YD5G01-021-1-2

drop table tmp_yz_liq_zxm_01_1 purge;
create table tmp_yz_liq_zxm_01_1  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cast(202509 as string) par_month_id,serv_id,acc_nbr,cust_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200'
and date_format(limit_date,'yyyyMM')>='202509' 
and prod_offer_id in(500046067) 
group by serv_id,acc_nbr,cust_id    

union all 
select par_month_id,serv_id,acc_nbr,cust_id     
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where par_month_id>=202506 and par_month_id<=202508 and par_corp_id='200'
and date_format(limit_date,'yyyyMM')>=par_month_id 
and prod_offer_id in(500046067)  
group by par_month_id,serv_id,acc_nbr,cust_id  ;

drop table tmp_yz_liq_zxm_01_2 purge;
create table tmp_yz_liq_zxm_01_2  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.*,b.prod_type,b.kd_desc 
from tmp_yz_liq_zxm_01_1 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id 
where a.par_month_id<'202509' 

union all 
select a.*,b.prod_type,b.kd_desc 
from tmp_yz_liq_zxm_01_1 a 
left join dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id 
where a.par_month_id='202509'
;

drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.subs_stat_date,'yyyyMM') sl_month,a.prod_offer_id,a.serv_id,msinfo_id  
from dwm_yz_rpt_comm_ba_msdisc_final a 
left join (select par_month_id,cust_id from tmp_yz_liq_zxm_01_2 where kd_desc='普通宽带' group by par_month_id,cust_id) b 
on a.cust_id=b.cust_id and b.par_month_id='202509' 
where a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202506' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(500049165,500062213,500071624,500072704)  
and b.cust_id is not null 

union all 
select date_format(a.subs_stat_date,'yyyyMM') sl_month,a.prod_offer_id,a.serv_id,msinfo_id   
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
left join (select par_month_id,cust_id from tmp_yz_liq_zxm_01_2 where kd_desc='普通宽带' group by par_month_id,cust_id) b 
on a.cust_id=b.cust_id and b.par_month_id=a.par_month_id 
where a.par_month_id>=202506 and a.par_month_id<=202508 
and a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202506' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(500049165,500062213,500071624,500072704) 
and b.cust_id is not null  
; 

drop table tmp_yz_liq_zxm_02 purge;
create table tmp_yz_liq_zxm_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select sl_month
,case when prod_offer_id=500049165 then '城中村129' when prod_offer_id=500062213 then '城中村99' 
	  when prod_offer_id=500071624 then '城中村59'  when prod_offer_id=500072704 then '城中村79' 
	  else null end dangci 
,count(distinct msinfo_id) nums 
from tmp_yz_liq_zxm_01 a 
group by sl_month
,case when prod_offer_id=500049165 then '城中村129' when prod_offer_id=500062213 then '城中村99' 
	  when prod_offer_id=500071624 then '城中村59'  when prod_offer_id=500072704 then '城中村79' 
	  else null end ; 


YD5G01-021-1-2+DM0001-834-1-1 --89融合
YD5G01-018-1-1+DM0001-834-1-1 --119融合
还有帮忙看看这2个档次近3个月的入网量有多少 口径是同一个融合套餐里面这两个销售品同时受理且同一个月竣工
500058267	DM0001-834-1-1
500062213	YD5G01-018-1-1
500072704	YD5G01-021-1-2

drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.subs_stat_date,'yyyyMM') sl_month,a.prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202506' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(500072704,500062213,500058267)  

union all 
select date_format(a.subs_stat_date,'yyyyMM') sl_month,a.prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202506' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(500072704,500062213,500058267) 
; 

drop table tmp_yz_liq_zxm_02 purge;
create table tmp_yz_liq_zxm_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,prod_offer_id,a.serv_id from 
tmp_yz_liq_zxm_01 a 
group by sl_month,prod_offer_id,a.serv_id ;

drop table tmp_yz_liq_zxm_03 purge;
create table tmp_yz_liq_zxm_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.*,b.prod_type,b.kd_desc,b.rh_tc_id,b.is_rh_ykj  
from tmp_yz_liq_zxm_02 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and a.sl_month=b.par_month_id 
where a.sl_month<'202509' 

union all 
select a.*,b.prod_type,b.kd_desc,b.rh_tc_id,b.is_rh_ykj   
from tmp_yz_liq_zxm_02 a 
left join dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and a.sl_month=b.par_month_id 
where a.sl_month='202509' 
; 

drop table tmp_yz_liq_zxm_04 purge;
create table tmp_yz_liq_zxm_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.* 
from tmp_yz_liq_zxm_03 a 
where is_rh_ykj=1 and prod_type=30 and prod_offer_id in(500072704,500062213) 
;

drop table tmp_yz_liq_zxm_05 purge;
create table tmp_yz_liq_zxm_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.*,case when b.rh_tc_id is not null then 1 else 0 end is_834 
from tmp_yz_liq_zxm_04 a 
left join (select rh_tc_id from tmp_yz_liq_zxm_03 
			where is_rh_ykj=1 and prod_type=40 and prod_offer_id in(500058267) group by rh_tc_id) b 
on a.rh_tc_id=b.rh_tc_id 
;

drop table tmp_yz_liq_zxm_06 purge;
create table tmp_yz_liq_zxm_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select sl_month,prod_offer_id
,case when prod_offer_id=500072704 then '89融合' when prod_offer_id=500062213 then '119融合' else null end as dangci 
,count(distinct rh_tc_id ) nums 
from tmp_yz_liq_zxm_05 where is_834=1 group by sl_month,prod_offer_id 
,case when prod_offer_id=500072704 then '89融合' when prod_offer_id=500062213 then '119融合' else null end;

YD5G01-021-1-2
还有帮忙看看近3个月的新宽新移做了这个销售品的有多少量
select a.par_month_id,count(distinct a.rh_tc_id) nums 
from dwm_yz_tb_comm_cm_all_mon_final a 
left join (select sl_month,serv_id from tmp_yz_liq_zxm_01 where prod_offer_id=500072704 group by sl_month,serv_id) b 
on a.par_month_id=b.sl_month and a.serv_id=b.serv_id 
where b.serv_id is not null and a.par_month_id>=202506 and a.par_month_id<=202508 
and a.rh_type_ykj='新宽带新移动'
group by a.par_month_id 

union all 
select a.par_month_id,count(distinct a.rh_tc_id) nums 
from dwm_yz_tb_comm_cm_all_final a 
left join (select sl_month,serv_id from tmp_yz_liq_zxm_01 where prod_offer_id=500072704 group by sl_month,serv_id) b 
on a.par_month_id=b.sl_month and a.serv_id=b.serv_id 
where b.serv_id is not null and a.par_month_id=202509 
and a.rh_type_ykj='新宽带新移动'
group by a.par_month_id

--20250917  技术团队营服月报
select 200 as city_id,a.par_month_id,a.subst_name,a.branch_name,a.area_name,a.grid_name
, sum(a.value15) kdjz_nums
, sum(a.value3) rw_nums
, sum(a.value4) cj_nums
, sum(a.value13)+sum(a.value14) as yr_nums
, sum(a.value9)+sum(a.value10) as qc_nums
, sum(a.value5) as jzf_nums
, sum(a.value18) as zkdd_nums
, sum(a.value19) as zkjz_nums
, sum(a.value16) as rhdd_nums
, sum(a.value17) as rhjz_nums
, sum(a.value20) as jz_jf
,0 as dk_jr 
FROM zone_gz_yz.ads_yz_kdjz_fenxi_dwb a
where a.par_month_id=(case when mod(cast(date_format(current_timestamp(),'yyyyMM') as int),100)<>1
else (cast(date_format(current_timestamp(),'yyyyMM') as int)-89) end)
group by a.par_month_id,a.subst_name,a.branch_name,a.area_name,a.grid_name 
;

--20250922  新增副宽6个销售品 需求单：XQGZ2025091100737
drop table if exists dwd_dim_dzkd_offer_20240719 purge;
create table dwd_dim_dzkd_offer_20250922 as select * from dwd_dim_dzkd_offer;--82

drop table if exists tmp_dim_dzkd_offer_xz purge;
create table tmp_dim_dzkd_offer_xz as 
select 6 as type_id,'副宽' type,
offer_id,prod_offer_code,offer_name,'商企' as fk_lx,'30' as fk_value
from dws_crm_cfguse.dws_offer where city_id=200 
and prod_offer_code in('DM0001-944-1-8') 

union all 
select 11 as type_id,'副宽' type,
offer_id,prod_offer_code,offer_name,'商企' as fk_lx,'0' as fk_value
from dws_crm_cfguse.dws_offer where city_id=200 
and prod_offer_code in('DM0001-944-1-6','DM0001-944-1-7','DM0001-944-1-1','DM0001-944-1-5','DM0001-944-1-3'); 

insert into table dwd_dim_dzkd_offer 
select * from tmp_dim_dzkd_offer_xz;

--20250929 XQGZ2025091900287 需求标题 关于协助提取小微结算标识的申请 
1.时间范围：202201-202412 账期；
2.属于天河分公司的小微项目接入号（取数口径：acc_nbr like 'XSJ%'）；
3.在上述2个条件的号码中，匹配【产品规格属性 like 'PM_ZSPGN%' 或者 产品规格属性 like 'PM_ZQMF%'】，没有该属性，则为空。

接入号	入网时间	揽装人	产品规格属性（产品规格属性 like   'PM_ZSPGN%'  或者  产品规格属性 like 'PM_ZQMF%'）
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists  tmp_yz_XQGZ2025091900287_01 purge;
create table tmp_yz_XQGZ2025091900287_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select attr_id,attr_inner_cd from dws_crm_cfguse.dws_attr_spec 
where attr_inner_cd like 'PM_ZSPGN%' or attr_inner_cd like 'PM_ZQMF%';

drop table if exists  tmp_yz_XQGZ2025091900287_02 purge;
create table tmp_yz_XQGZ2025091900287_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.par_month_id,a.serv_id
,a.attr_id --特性id（产品规格属性）
,a.attr_value1  --特性值
,a.create_date   --订购时间

,b.attr_inner_cd  --产品规格属性编码
,row_number() over(partition by a.par_month_id,a.serv_id order by a.create_date desc) as paixu 
from iodata_ods_month_city.tb_pre_cm_attr_all_mon a --特性资料表 
join tmp_yz_XQGZ2025091900287_01 b 
on a.attr_id=b.attr_id 
where a.par_corp_id=200 and a.par_month_id>=202201  
and a.par_month_id<=202412 
;

drop table ads_yz_XQGZ2025091900287_list purge;
create table ads_yz_XQGZ2025091900287_list as 
select a.subst_name,a.par_month_id,a.serv_id,a.acc_nbr,a.open_date,a.sales_name 
,b.attr_inner_cd,b.attr_value1 
from dwm_yz_tb_comm_cm_all_mon_final a 
left join tmp_yz_XQGZ2025091900287_02 b on a.par_month_id=b.par_month_id and a.serv_id=b.serv_id and b.paixu=1 
where a.acc_nbr like 'XSJ%' and a.par_month_id>=202201  
and a.par_month_id<=202412 and a.subst_name='天河分公司';

--20250930  XQGZ2025092601298 需求标题 提取广州跨越速运公司关联使用人变动的清单 
1、取202312月广州跨越速运公司（产权编码：2020397288540000，2020268032910000）下的移动号码，关联使用人，身份证，入网时间
2、取202507月广州跨越速运公司（产权编码：2020397288540000，2020268032910000）下的移动号码，关联使用人，身份证，入网时间
3、判断同一身份证号码不一致的部分


--XQGZ2025092600422 何纬斌 需求标题 关于广州2026年名单制客户梳理的需求  
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--#########生产黑名单清单
--客户级
drop table if exists tmp_dwd_yz_sensit_cust_list_hmd_cust;
create table tmp_dwd_yz_sensit_cust_list_hmd_cust as 
select obj_id,sub_special_type,create_date,create_staff,(row_number() over(partition by obj_id order by create_date desc)) pm    
from dws_crm_party.dws_special_list_black 
where special_type='1200'  and obj_type='1100' and status_cd='1000' and city_id=200
and obj_id>0 and obj_id is not null;

--证件级
drop table if exists tmp_dwd_yz_sensit_cust_list_hmd_cert1;
create table tmp_dwd_yz_sensit_cust_list_hmd_cert1 as
select cert_nbr,sub_special_type,create_date,create_staff,(row_number() over(partition by cert_nbr order by create_date desc)) pm    
from dws_crm_party.dws_special_list_black 
where special_type='1200'  and obj_type='1500' and status_cd='1000'  and city_id=200
and cert_nbr is not null;


drop table if exists tmp_dwd_yz_sensit_cust_list_hmd_cert2;
create table tmp_dwd_yz_sensit_cust_list_hmd_cert2 as    
select party_id,cert_num
from dws_crm_cust.dws_party_cert_local where cert_type='1' 
group by party_id,cert_num;

drop table if exists tmp_dwd_yz_sensit_cust_list_hmd_cert3;
create table tmp_dwd_yz_sensit_cust_list_hmd_cert3 as
select a.party_id,b.sub_special_type,b.cert_nbr,b.create_date,b.create_staff
from (select party_id,cert_num from tmp_dwd_yz_sensit_cust_list_hmd_cert2) a 
join (select cert_nbr,sub_special_type,create_date,create_staff from tmp_dwd_yz_sensit_cust_list_hmd_cert1 where pm=1) b
on a.cert_num=b.cert_nbr;

drop table if exists tmp_dwd_yz_sensit_cust_list_hmd_cert;
create table tmp_dwd_yz_sensit_cust_list_hmd_cert as
select a.cust_id,b.party_id,b.sub_special_type,b.cert_nbr,b.create_date,b.create_staff
from (select cust_id,party_id from dws_crm_cust.dws_customer where city_id=200) a
join (select * from tmp_dwd_yz_sensit_cust_list_hmd_cert3) b  
on a.party_id=b.party_id;

--客户级+证件级合并剔重
drop table if exists tmp_yz_sensit_cust_list_hmd_cert_1;
create table tmp_yz_sensit_cust_list_hmd_cert_1 as
select cust_id,sub_special_type,create_date,create_staff,(row_number() over(partition by cust_id order by create_date desc)) pm 
from tmp_dwd_yz_sensit_cust_list_hmd_cert;

drop table if exists tmp_yz_sensit_cust_list_hmd_cust_cert_1;
create table tmp_yz_sensit_cust_list_hmd_cust_cert_1 as
select obj_id as cust_id,sub_special_type,create_date,create_staff 
from tmp_dwd_yz_sensit_cust_list_hmd_cust where pm=1 
union all 
select cust_id,sub_special_type,create_date,create_staff 
from tmp_yz_sensit_cust_list_hmd_cert_1 where pm=1;

drop table if exists tmp_yz_sensit_cust_list_hmd_cust_cert_2;
create table tmp_yz_sensit_cust_list_hmd_cust_cert_2 as 
select *,(row_number() over(partition by cust_id order by create_date desc)) pm  
from tmp_yz_sensit_cust_list_hmd_cust_cert_1;

drop table if exists tmp_yz_sensit_cust_list_hmd_cust_cert;
create table tmp_yz_sensit_cust_list_hmd_cust_cert as 
select * from tmp_yz_sensit_cust_list_hmd_cust_cert_2 where pm=1;
--#################################################

--产权ID	产权编码	产权客户名	产权客户建档时间
--抽取产权信息，经沟通锁定战略分群为政企的全量产权客户
drop table if exists tmp_yz_liq_XQGZ2025092600422_1 purge;
create table tmp_yz_liq_XQGZ2025092600422_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select cust_id,cust_number,cust_name,create_date 
,row_number() over(partition by cust_number,cust_name order by create_date desc) paixu 
from dws_crm_cust.dws_customer where city_id=200 
and cust_type='1000'  --战略分群为政企
;

--直销ID	直销编码	直销客户名	直销建档时间  客户类型	是否重点客户	所属局向ID	所属局向	所属营服	所属营服ID
drop table if exists tmp_yz_liq_XQGZ2025092600422_2 purge;
create table tmp_yz_liq_XQGZ2025092600422_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.ccust_id
from tmp_yz_liq_XQGZ2025092600422_1 a 
left join (select cust_nbr,ccust_id,row_number() over(partition by cust_nbr order by ccust_id) as paixu from dws_yz_tb_mo_custgrp_cust_final) b 
on a.cust_number=b.cust_nbr and b.paixu=1
;

drop table if exists tmp_yz_liq_XQGZ2025092600422_3 purge;
create table tmp_yz_liq_XQGZ2025092600422_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as
select a.* 
,b.ccust_code,b.ccust_name,b.create_date ccust_create_date,b.vip_flag,b.branch_org,b.manage_org
from tmp_yz_liq_XQGZ2025092600422_2 a 
left join (select ccust_id,ccust_code,ccust_name,create_date,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;

drop table tmp_yz_liq_XQGZ2025092600422_4 purge;
create table tmp_yz_liq_XQGZ2025092600422_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.attr_value_name as is_vip_cust 
from tmp_yz_liq_XQGZ2025092600422_3 a 
left join (select attr_id,attr_inner_value,attr_value_name,attr_value_sort  from  dws_crm_cfguse.dws_attr_value where city_id=200
and attr_id='400003971') b on a.vip_flag=b.attr_inner_value
;

drop table tmp_yz_liq_XQGZ2025092600422_5 purge;
create table tmp_yz_liq_XQGZ2025092600422_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.org_name as ccust_subst_name 
,c.org_name as ccust_branch_name
from tmp_yz_liq_XQGZ2025092600422_4 a 
left join (select * from  dwd_yz_dim_org where levs='3') b
on a.branch_org=b.org_id
left join (select * from  dwd_yz_dim_org where levs='4') c
on a.manage_org=c.org_id;

--P码ID	P码（身份证编码）	P码客户名
--产权-P码 1对多,按更新时间最晚取唯一P码
drop table tmp_yz_liq_XQGZ2025092600422_6 purge;
create table tmp_yz_liq_XQGZ2025092600422_6 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,b.party_id,c.party_nbr,c.party_name 
from tmp_yz_liq_XQGZ2025092600422_5 a 
left join (select cust_id,party_id,row_number() over(partition by cust_id order by update_date desc) as paixu 
from dws_ecust.dws_party_zq_fcust_rel where city_id=200 ) b 
on a.cust_id=b.cust_id and b.paixu=1
left join dws_ecust.dws_party_zq c on b.party_id=c.party_id and c.city_id=200 
;

--直销客户类型， attr_id='4000094004' ，1 现实客户  2 -  4 潜在客户
drop table tmp_yz_liq_XQGZ2025092600422_7_1 purge;
create table tmp_yz_liq_XQGZ2025092600422_7_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.*
,case when b.cust_state=1 then '现实客户' 
	  when b.cust_state>=2 and b.cust_state<=4 then '潜在客户' else null end cust_lx 
from tmp_yz_liq_XQGZ2025092600422_6 a
left join 
(select ccust_id,cust_state from dws_ecust.dws_mo_ccust where city_id=200) b
on a.ccust_id=b.ccust_id;

--是否黑名单
drop table tmp_yz_liq_XQGZ2025092600422_7 purge;
create table tmp_yz_liq_XQGZ2025092600422_7 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.* 
,case when b.cust_id is not null then '是' else '否' end is_hmd 
from tmp_yz_liq_XQGZ2025092600422_7_1 a 
left join tmp_yz_sensit_cust_list_hmd_cust_cert b on a.cust_id=b.cust_id;

--按客户统计业务数
drop table tmp_yz_liq_XQGZ2025092600422_8 purge;
create table tmp_yz_liq_XQGZ2025092600422_8 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select cust_id,count(distinct serv_id) num 
from dwm_yz_tb_comm_cm_all_final a 
where a.state<>'140001' --剔除新申请
and a.par_month_id=202510 and a.is_cancel_user=0
group by cust_id; 

drop table tmp_yz_liq_XQGZ2025092600422_9 purge;
create table tmp_yz_liq_XQGZ2025092600422_9 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select a.*,b.num 
from tmp_yz_liq_XQGZ2025092600422_7 a 
left join tmp_yz_liq_XQGZ2025092600422_8 b 
on a.cust_id=b.cust_id;

drop table tmp_yz_liq_XQGZ2025092600422_10 purge;
create table tmp_yz_liq_XQGZ2025092600422_10 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select par_month_id,cust_id  
,case when subst_name='政企客户部' and coalesce(bg_type,'-1')<>'教育' then '行客中心' when subst_name='政企客户部' and bg_type='教育' then '校园中心' else subst_name end subst_name 
,case when channel_subst_name='政企客户部' and coalesce(bg_type,'-1')<>'教育' then '行客中心' when channel_subst_name='政企客户部' and bg_type='教育' then '校园中心' else channel_subst_name end channel_subst_name 
,case when std_subst_name='政企客户部' and coalesce(bg_type,'-1')<>'教育' then '行客中心' when std_subst_name='政企客户部' and bg_type='教育' then '校园中心' else std_subst_name end std_subst_name 
,bg_type, 
sum(a0) as sh_qr,--税后确认收入
sum(a0)-sum(a8) as sh_tc_ycx --剔除一次性税后收入
from dwm_srhx_serv_list_mon_final
where par_month_id >= 202401 and par_month_id<=202509 
group by par_month_id,cust_id,subst_name,channel_subst_name,std_subst_name,bg_type; 

drop table tmp_yz_liq_XQGZ2025092600422_11 purge;
create table tmp_yz_liq_XQGZ2025092600422_11 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as  
select cust_id,
sum(case when par_month_id>=202401 and par_month_id<=202412 then sh_qr else 0 end) as sh_qr_2024, 
sum(case when par_month_id>=202501 and par_month_id<=202509 then sh_qr else 0 end) as sh_qr_202509, 

sum(case when par_month_id>=202401 and par_month_id<=202412 then sh_tc_ycx else 0 end) as sh_tc_ycx_2024, 
sum(case when par_month_id>=202501 and par_month_id<=202509 then sh_tc_ycx else 0 end) as sh_tc_ycx_202509 
from tmp_yz_liq_XQGZ2025092600422_10 group by cust_id;


drop table tmp_yz_liq_XQGZ2025092600422_12 purge;
create table tmp_yz_liq_XQGZ2025092600422_12 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as  
select a.* 
,b.sh_qr_2024,b.sh_qr_202509
,b.sh_tc_ycx_2024,b.sh_tc_ycx_202509 
from tmp_yz_liq_XQGZ2025092600422_9 a 
left join tmp_yz_liq_XQGZ2025092600422_11 b  on a.cust_id=b.cust_id; 

--############划小最大收入局向（25年1-9月）######################################
--划小最大收入局向（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_13_1 purge;
create table tmp_yz_liq_XQGZ2025092600422_13_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,subst_name  
,sum(sh_qr) as sr_sh 
,sum(sh_tc_ycx) as sr_sh_tc_ycx 
from tmp_yz_liq_XQGZ2025092600422_10 a 
where par_month_id>=202501 and par_month_id<=202509  
group by cust_id,subst_name;

--划小最大收入局向（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_13_2 purge;
create table tmp_yz_liq_XQGZ2025092600422_13_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by cust_id order by sr_sh desc) as paixu1 
,row_number() over(partition by cust_id order by sr_sh_tc_ycx desc) as paixu2
from tmp_yz_liq_XQGZ2025092600422_13_1 a;

--############揽装收入最大局向（25年1-9月）######################################
--揽装收入最大局向（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_14_1 purge;
create table tmp_yz_liq_XQGZ2025092600422_14_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,channel_subst_name  
,sum(sh_qr) as sr_sh 
,sum(sh_tc_ycx) as sr_sh_tc_ycx 
from tmp_yz_liq_XQGZ2025092600422_10 a 
where par_month_id>=202501 and par_month_id<=202509  
group by cust_id,channel_subst_name;

--揽装收入最大局向（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_14_2 purge;
create table tmp_yz_liq_XQGZ2025092600422_14_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by cust_id order by sr_sh desc) as paixu1 
,row_number() over(partition by cust_id order by sr_sh_tc_ycx desc) as paixu2
from tmp_yz_liq_XQGZ2025092600422_14_1 a;

--############落地收入最大局向（25年1-9月）######################################
--落地收入最大局向（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_15_1 purge;
create table tmp_yz_liq_XQGZ2025092600422_15_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select cust_id,std_subst_name  
,sum(sh_qr) as sr_sh 
,sum(sh_tc_ycx) as sr_sh_tc_ycx 
from tmp_yz_liq_XQGZ2025092600422_10 a 
where par_month_id>=202501 and par_month_id<=202509  
group by cust_id,std_subst_name;

--落地收入最大局向（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_15_2 purge;
create table tmp_yz_liq_XQGZ2025092600422_15_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by cust_id order by sr_sh desc) as paixu1 
,row_number() over(partition by cust_id order by sr_sh_tc_ycx desc) as paixu2
from tmp_yz_liq_XQGZ2025092600422_15_1 a;


--划小最大收入局向\揽装最大收入局向\落地最大收入局向
drop table tmp_yz_liq_XQGZ2025092600422_16 purge;
create table tmp_yz_liq_XQGZ2025092600422_16 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.subst_name as maxsr_subst,c.channel_subst_name as maxsr_channel_subst,d.std_subst_name as maxsr_std_subst 
from tmp_yz_liq_XQGZ2025092600422_12 a 
left join tmp_yz_liq_XQGZ2025092600422_13_2 b on a.cust_id=b.cust_id and b.paixu1=1 and b.cust_id is not null 
left join tmp_yz_liq_XQGZ2025092600422_14_2 c on a.cust_id=c.cust_id and c.paixu1=1 and c.cust_id is not null 
left join tmp_yz_liq_XQGZ2025092600422_15_2 d on a.cust_id=d.cust_id and d.paixu1=1 and d.cust_id is not null 
;

--划小最大收入局向\揽装最大收入局向\落地最大收入局向(剔除一次性)
drop table tmp_yz_liq_XQGZ2025092600422_17 purge;
create table tmp_yz_liq_XQGZ2025092600422_17 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.*,b.subst_name as maxsr_subst2,c.channel_subst_name as maxsr_channel_subst2,d.std_subst_name as maxsr_std_subst2 
from tmp_yz_liq_XQGZ2025092600422_16 a 
left join tmp_yz_liq_XQGZ2025092600422_13_2 b on a.cust_id=b.cust_id and b.paixu2=1 and b.cust_id is not null 
left join tmp_yz_liq_XQGZ2025092600422_14_2 c on a.cust_id=c.cust_id and c.paixu2=1 and c.cust_id is not null 
left join tmp_yz_liq_XQGZ2025092600422_15_2 d on a.cust_id=d.cust_id and d.paixu2=1 and d.cust_id is not null 
;

--划小各分局收入打横统计
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2025092600422_13_3 purge;
create table tmp_yz_liq_XQGZ2025092600422_13_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select *,case when subst_name='天河分公司' then 'th' when subst_name='番禺分公司' then 'py' when subst_name='白云分公司' then 'baiy' 
		      when subst_name='越秀分公司' then 'yx' when subst_name='海珠分公司' then 'hz' when subst_name='荔湾分公司' then 'lw'  
			  when subst_name='黄埔分公司' then 'hp' when subst_name='增城分公司' then 'zc' when subst_name='花都分公司' then 'hd' 
			  when subst_name='南沙分公司' then 'ns' when subst_name='从化分公司' then 'ch' 
			  when subst_name='行客中心' then 'hkzx' when subst_name='校园中心' then 'xyzx' 
		 end as subst_nbr 
from tmp_yz_liq_XQGZ2025092600422_13_1 a;

drop table if exists tmp_yz_liq_XQGZ2025092600422_13_4 purge;
create table tmp_yz_liq_XQGZ2025092600422_13_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
str_to_map(concat_ws(',',collect_set(concat_ws('=',subst_nbr,cast(sr_sh as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2025092600422_13_3    
group by cust_id
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2025092600422_13 purge;
create table tmp_yz_liq_XQGZ2025092600422_13 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
coalesce(cast(map_col[\"th\"] as decimal(22,2)),0) th_subst_sr,
coalesce(cast(map_col[\"py\"] as decimal(22,2)),0) py_subst_sr,
coalesce(cast(map_col[\"baiy\"] as decimal(22,2)),0) baiy_subst_sr,
coalesce(cast(map_col[\"yx\"] as decimal(22,2)),0) yx_subst_sr,
coalesce(cast(map_col[\"hz\"] as decimal(22,2)),0) hz_subst_sr,
coalesce(cast(map_col[\"lw\"] as decimal(22,2)),0) lw_subst_sr,
coalesce(cast(map_col[\"hp\"] as decimal(22,2)),0) hp_subst_sr,
coalesce(cast(map_col[\"zc\"] as decimal(22,2)),0) zc_subst_sr,
coalesce(cast(map_col[\"hd\"] as decimal(22,2)),0) hd_subst_sr,
coalesce(cast(map_col[\"ns\"] as decimal(22,2)),0) ns_subst_sr,
coalesce(cast(map_col[\"ch\"] as decimal(22,2)),0) ch_subst_sr,
coalesce(cast(map_col[\"hkzx\"] as decimal(22,2)),0) hkzx_subst_sr,
coalesce(cast(map_col[\"xyzx\"] as decimal(22,2)),0) xyzx_subst_sr
from tmp_yz_liq_XQGZ2025092600422_13_4
;

drop table if exists tmp_yz_liq_XQGZ2025092600422_18 purge;
create table tmp_yz_liq_XQGZ2025092600422_18 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*  
,b.th_subst_sr,b.py_subst_sr,b.baiy_subst_sr,b.yx_subst_sr,b.hz_subst_sr,b.lw_subst_sr,b.hp_subst_sr,b.zc_subst_sr
,b.hd_subst_sr,b.ns_subst_sr,b.ch_subst_sr,b.hkzx_subst_sr,b.xyzx_subst_sr  
from tmp_yz_liq_XQGZ2025092600422_17 a 
left join tmp_yz_liq_XQGZ2025092600422_13 b on a.cust_id=b.cust_id 
;


--揽装各分局收入打横统计
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2025092600422_14_3 purge;
create table tmp_yz_liq_XQGZ2025092600422_14_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select *,case when channel_subst_name='天河分公司' then 'th' when channel_subst_name='番禺分公司' then 'py' when channel_subst_name='白云分公司' then 'baiy' 
		      when channel_subst_name='越秀分公司' then 'yx' when channel_subst_name='海珠分公司' then 'hz' when channel_subst_name='荔湾分公司' then 'lw'  
			  when channel_subst_name='黄埔分公司' then 'hp' when channel_subst_name='增城分公司' then 'zc' when channel_subst_name='花都分公司' then 'hd' 
			  when channel_subst_name='南沙分公司' then 'ns' when channel_subst_name='从化分公司' then 'ch' 
			  when channel_subst_name='行客中心' then 'hkzx' when channel_subst_name='校园中心' then 'xyzx' 
		 end as channel_subst_nbr  
from tmp_yz_liq_XQGZ2025092600422_14_1 a;

drop table if exists tmp_yz_liq_XQGZ2025092600422_14_4 purge;
create table tmp_yz_liq_XQGZ2025092600422_14_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
str_to_map(concat_ws(',',collect_set(concat_ws('=',channel_subst_nbr,cast(sr_sh as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2025092600422_14_3    
group by cust_id
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2025092600422_14 purge;
create table tmp_yz_liq_XQGZ2025092600422_14 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
coalesce(cast(map_col[\"th\"] as decimal(22,2)),0) th_channel_subst_sr,
coalesce(cast(map_col[\"py\"] as decimal(22,2)),0) py_channel_subst_sr,
coalesce(cast(map_col[\"baiy\"] as decimal(22,2)),0) baiy_channel_subst_sr,
coalesce(cast(map_col[\"yx\"] as decimal(22,2)),0) yx_channel_subst_sr,
coalesce(cast(map_col[\"hz\"] as decimal(22,2)),0) hz_channel_subst_sr,
coalesce(cast(map_col[\"lw\"] as decimal(22,2)),0) lw_channel_subst_sr,
coalesce(cast(map_col[\"hp\"] as decimal(22,2)),0) hp_channel_subst_sr,
coalesce(cast(map_col[\"zc\"] as decimal(22,2)),0) zc_channel_subst_sr,
coalesce(cast(map_col[\"hd\"] as decimal(22,2)),0) hd_channel_subst_sr,
coalesce(cast(map_col[\"ns\"] as decimal(22,2)),0) ns_channel_subst_sr,
coalesce(cast(map_col[\"ch\"] as decimal(22,2)),0) ch_channel_subst_sr,
coalesce(cast(map_col[\"hkzx\"] as decimal(22,2)),0) hkzx_channel_subst_sr, 
coalesce(cast(map_col[\"xyzx\"] as decimal(22,2)),0) xyzx_channel_subst_sr
from tmp_yz_liq_XQGZ2025092600422_14_4
;

drop table if exists tmp_yz_liq_XQGZ2025092600422_19 purge;
create table tmp_yz_liq_XQGZ2025092600422_19 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.*  
,b.th_channel_subst_sr,b.py_channel_subst_sr,b.baiy_channel_subst_sr,b.yx_channel_subst_sr
,b.hz_channel_subst_sr,b.lw_channel_subst_sr,b.hp_channel_subst_sr,b.zc_channel_subst_sr
,b.hd_channel_subst_sr,b.ns_channel_subst_sr,b.ch_channel_subst_sr,b.hkzx_channel_subst_sr,b.xyzx_channel_subst_sr 
from tmp_yz_liq_XQGZ2025092600422_18 a 
left join tmp_yz_liq_XQGZ2025092600422_14 b on a.cust_id=b.cust_id 
;


--落地各分局收入打横统计
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2025092600422_15_3 purge;
create table tmp_yz_liq_XQGZ2025092600422_15_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select *,case when std_subst_name='天河分公司' then 'th' when std_subst_name='番禺分公司' then 'py' when std_subst_name='白云分公司' then 'baiy' 
		      when std_subst_name='越秀分公司' then 'yx' when std_subst_name='海珠分公司' then 'hz' when std_subst_name='荔湾分公司' then 'lw'  
			  when std_subst_name='黄埔分公司' then 'hp' when std_subst_name='增城分公司' then 'zc' when std_subst_name='花都分公司' then 'hd' 
			  when std_subst_name='南沙分公司' then 'ns' when std_subst_name='从化分公司' then 'ch' 
			  when std_subst_name='行客中心' then 'hkzx' when std_subst_name='校园中心' then 'xyzx' 
		 end as std_subst_nbr  
from tmp_yz_liq_XQGZ2025092600422_15_1 a;

drop table if exists tmp_yz_liq_XQGZ2025092600422_15_4 purge;
create table tmp_yz_liq_XQGZ2025092600422_15_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select cust_id,
str_to_map(concat_ws(',',collect_set(concat_ws('=',std_subst_nbr,cast(sr_sh as string)))),',','=') map_col
from tmp_yz_liq_XQGZ2025092600422_15_3    
group by cust_id
; 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_liq_XQGZ2025092600422_15 purge;
create table tmp_yz_liq_XQGZ2025092600422_15 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_id,
coalesce(cast(map_col[\"th\"] as decimal(22,2)),0) th_std_subst_sr,
coalesce(cast(map_col[\"py\"] as decimal(22,2)),0) py_std_subst_sr,
coalesce(cast(map_col[\"baiy\"] as decimal(22,2)),0) baiy_std_subst_sr,
coalesce(cast(map_col[\"yx\"] as decimal(22,2)),0) yx_std_subst_sr,
coalesce(cast(map_col[\"hz\"] as decimal(22,2)),0) hz_std_subst_sr,
coalesce(cast(map_col[\"lw\"] as decimal(22,2)),0) lw_std_subst_sr,
coalesce(cast(map_col[\"hp\"] as decimal(22,2)),0) hp_std_subst_sr,
coalesce(cast(map_col[\"zc\"] as decimal(22,2)),0) zc_std_subst_sr,
coalesce(cast(map_col[\"hd\"] as decimal(22,2)),0) hd_std_subst_sr,
coalesce(cast(map_col[\"ns\"] as decimal(22,2)),0) ns_std_subst_sr,
coalesce(cast(map_col[\"ch\"] as decimal(22,2)),0) ch_std_subst_sr,
coalesce(cast(map_col[\"hkzx\"] as decimal(22,2)),0) hkzx_std_subst_sr, 
coalesce(cast(map_col[\"xyzx\"] as decimal(22,2)),0) xyzx_std_subst_sr 
from tmp_yz_liq_XQGZ2025092600422_15_4
;

drop table if exists tmp_yz_liq_XQGZ2025092600422_20 purge;
create table tmp_yz_liq_XQGZ2025092600422_20 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*  
,b.th_std_subst_sr,b.py_std_subst_sr,b.baiy_std_subst_sr,b.yx_std_subst_sr
,b.hz_std_subst_sr,b.lw_std_subst_sr,b.hp_std_subst_sr,b.zc_std_subst_sr
,b.hd_std_subst_sr,b.ns_std_subst_sr,b.ch_std_subst_sr,b.hkzx_std_subst_sr,b.xyzx_std_subst_sr 
from tmp_yz_liq_XQGZ2025092600422_19 a 
left join tmp_yz_liq_XQGZ2025092600422_15 b on a.cust_id=b.cust_id 
;

--############落地收入最大网格（25年1-9月）######################################
--落地收入最大网格（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_21 purge;
create table tmp_yz_liq_XQGZ2025092600422_21 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')  
as 
select par_month_id,cust_id  
,cell_code,cell_name, 
sum(a0) as sh_qr,--税后确认收入
sum(a0)-sum(a8) as sh_tc_ycx --剔除一次性税后收入
from dwm_srhx_serv_list_mon_final
where par_month_id >= 202401 and par_month_id<=202509 
group by par_month_id,cust_id,cell_code,cell_name; 


drop table tmp_yz_liq_XQGZ2025092600422_22 purge;
create table tmp_yz_liq_XQGZ2025092600422_22 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select cust_id,cell_code,cell_name   
,sum(sh_qr) as sr_sh 
,sum(sh_tc_ycx) as sr_sh_tc_ycx 
from tmp_yz_liq_XQGZ2025092600422_21 a 
where par_month_id>=202501 and par_month_id<=202509  
group by cust_id,cell_code,cell_name;

--落地收入最大网格（25年1-9月）
drop table tmp_yz_liq_XQGZ2025092600422_23 purge;
create table tmp_yz_liq_XQGZ2025092600422_23 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,row_number() over(partition by cust_id order by sr_sh desc) as paixu1 
,row_number() over(partition by cust_id order by sr_sh_tc_ycx desc) as paixu2
from tmp_yz_liq_XQGZ2025092600422_22 a;


--落地最大收入网格
drop table tmp_yz_liq_XQGZ2025092600422_24 purge;
create table tmp_yz_liq_XQGZ2025092600422_24 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,d.cell_code as maxsr_cell_code, d.cell_name as maxsr_cell_name 
from tmp_yz_liq_XQGZ2025092600422_20 a 
left join tmp_yz_liq_XQGZ2025092600422_23 d on a.cust_id=d.cust_id and d.paixu1=1 and d.cust_id is not null 
;


--插入结果表
insert into table ads_yz_liq_XQGZ2025092600422_list(
city_id,cust_id,cust_number,cust_name,create_date,party_id,party_nbr,party_name
,ccust_id,ccust_code,ccust_name,ccust_create_date,cust_lx,is_vip_cust 
,branch_org,ccust_subst_name,manage_org,ccust_branch_name,num,is_hmd
,sh_qr_2024,sh_tc_ycx_2024,sh_qr_202509,sh_tc_ycx_202509 

,sr_subst,sr_tc_ycx_subst,sr_th,sr_py,sr_by,sr_yx,sr_hz,sr_lw,sr_hp
,sr_zc,sr_hd,sr_ns,sr_ch,sr_hkzx,sr_xyzx 

,lz_sr_subst,lz_sr_tc_ycx_subst,lz_sr_th,lz_sr_py,lz_sr_by
,lz_sr_yx,lz_sr_hz,lz_sr_lw,lz_sr_hp,lz_sr_zc
,lz_sr_hd,lz_sr_ns,lz_sr_ch,lz_sr_hkzx,lz_sr_xyzx 

,ld_sr_subst,ld_sr_tc_ycx_subst,maxsr_cell_code,maxsr_cell_name 
,ld_sr_th,ld_sr_py,ld_sr_by,ld_sr_yx
,ld_sr_hz,ld_sr_lw,ld_sr_hp,ld_sr_zc,ld_sr_hd,ld_sr_ns,ld_sr_ch,ld_sr_hkzx,ld_sr_xyzx) 

select 200 as city_id 
,cust_id,cust_number,cust_name,create_date,party_id,party_nbr,party_name 
,ccust_id,ccust_code,ccust_name,ccust_create_date,cust_lx,is_vip_cust 
,branch_org,ccust_subst_name,manage_org,ccust_branch_name,num,is_hmd 
,sh_qr_2024,sh_tc_ycx_2024,sh_qr_202509,sh_tc_ycx_202509 

,maxsr_subst,maxsr_subst2,th_subst_sr,py_subst_sr,baiy_subst_sr,yx_subst_sr,hz_subst_sr,lw_subst_sr,hp_subst_sr
,zc_subst_sr,hd_subst_sr,ns_subst_sr,ch_subst_sr,hkzx_subst_sr,xyzx_subst_sr  

,maxsr_channel_subst,maxsr_channel_subst2,th_channel_subst_sr,py_channel_subst_sr,baiy_channel_subst_sr
,yx_channel_subst_sr,hz_channel_subst_sr,lw_channel_subst_sr,hp_channel_subst_sr,zc_channel_subst_sr
,hd_channel_subst_sr,ns_channel_subst_sr,ch_channel_subst_sr,hkzx_channel_subst_sr,xyzx_channel_subst_sr 

,maxsr_std_subst,maxsr_std_subst2,maxsr_cell_code,maxsr_cell_name 
,th_std_subst_sr,py_std_subst_sr,baiy_std_subst_sr,yx_std_subst_sr
,hz_std_subst_sr,lw_std_subst_sr,hp_std_subst_sr,zc_std_subst_sr,hd_std_subst_sr,ns_std_subst_sr,ch_std_subst_sr,hkzx_std_subst_sr,xyzx_std_subst_sr  

from tmp_yz_liq_XQGZ2025092600422_20;

:<<EOF
--创建结果表
drop table if exists ads_yz_liq_XQGZ2025092600422_list purge;
create table ads_yz_liq_XQGZ2025092600422_list
(
city_id int,
cust_id string,
cust_number string,
cust_name string,
create_date string,
party_id string,
party_nbr string,
party_name string,
ccust_id string,
ccust_code string,
ccust_name string,
ccust_create_date string,
cust_lx string,
is_vip_cust string,
branch_org string,
ccust_subst_name string,
manage_org string,
ccust_branch_name string,
num decimal(22,0),
is_hmd string,
sh_qr_2024 decimal(22,4),
sh_tc_ycx_2024 decimal(22,4),
sh_qr_202509 decimal(22,4),
sh_tc_ycx_202509 decimal(22,4),
sr_subst string,
sr_tc_ycx_subst string,
sr_th decimal(22,4),
sr_py decimal(22,4),
sr_by decimal(22,4),
sr_yx decimal(22,4),
sr_hz decimal(22,4),
sr_lw decimal(22,4),
sr_hp decimal(22,4),
sr_zc decimal(22,4),
sr_hd decimal(22,4),
sr_ns decimal(22,4),
sr_ch decimal(22,4),
sr_hkzx decimal(22,4),
sr_xyzx decimal(22,4),
lz_sr_subst string,
lz_sr_tc_ycx_subst string,
lz_sr_th decimal(22,4),
lz_sr_py decimal(22,4),
lz_sr_by decimal(22,4),
lz_sr_yx decimal(22,4),
lz_sr_hz decimal(22,4),
lz_sr_lw decimal(22,4),
lz_sr_hp decimal(22,4),
lz_sr_zc decimal(22,4),
lz_sr_hd decimal(22,4),
lz_sr_ns decimal(22,4),
lz_sr_ch decimal(22,4),
lz_sr_hkzx decimal(22,4),
lz_sr_xyzx decimal(22,4),
ld_sr_subst string,
ld_sr_tc_ycx_subst string,
maxsr_cell_code varchar(20), 
maxsr_cell_name string,
ld_sr_th decimal(22,4),
ld_sr_py decimal(22,4),
ld_sr_by decimal(22,4),
ld_sr_yx decimal(22,4),
ld_sr_hz decimal(22,4),
ld_sr_lw decimal(22,4),
ld_sr_hp decimal(22,4),
ld_sr_zc decimal(22,4),
ld_sr_hd decimal(22,4),
ld_sr_ns decimal(22,4),
ld_sr_ch decimal(22,4),
ld_sr_hkzx decimal(22,4), 
ld_sr_xyzx decimal(22,4) 

)
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy');  

EOF


"

--20251022  张晓明 
10月份受理了“DM0001-404-01-37”这个销售品的宽带号码，多维表需要有“subst_name，is_rh_ykj，prod_type3”这三个字段

drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as   
select b.attr_value_name as state_desc 
,date_format(a.act_date,'yyyyMMdd') act_day 
,date_format(a.subs_stat_date,'yyyyMMdd') jg_date,a.serv_id   
from dwm_yz_rpt_comm_ba_msdisc_final a 
left join dws_crm_cfguse.dws_attr_value b on a.subs_stat=b.attr_value and b.city_id='200' and b.attr_id='4000000059'
where 1=1 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and (date_format(a.subs_stat_date,'yyyyMM') = '202510' or date_format(a.act_date,'yyyyMM') = '202510')
and a.action_id in( 1292,6200 ) --销售品订购和更换
and prod_offer_id in(500034130)  
; 

drop table tmp_yz_liq_zxm_02 purge;
create table tmp_yz_liq_zxm_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.* 
,b.prod_type,b.subst_name,b.is_rh_ykj,b.prod_type3 
from tmp_yz_liq_zxm_01 a 
left join dwm_yz_tb_comm_cm_all_final b on a.serv_id=b.serv_id and b.par_month_id=202510 
; 

drop table tmp_yz_liq_zxm_03 purge;
create table tmp_yz_liq_zxm_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select state_desc,subst_name,is_rh_ykj,prod_type3 
,count(distinct serv_id) nums 
from tmp_yz_liq_zxm_02 a where prod_type=40 
group by state_desc,subst_name,is_rh_ykj,prod_type3;

--XQGZ2025102800070 
1、在网号码资料：统计月份、接入号、受理时间、竣工时间、直销客户编码，产权客户编码、状态，号码揽装人编码、当月价值积分
2、销售品订单：订单编码、订单状态、订单开通日期、订单竣工日期、订单揽装人工号，业务类型

drop view view_yz_XQGZ2025102800070_comm_cm_all;
create view view_yz_XQGZ2025102800070_comm_cm_all as 
select par_month_id,acc_nbr,act_date,open_date,cust_code,cust_nbr,state,sales_code,jz_points 
from zone_gz_yz.dwm_yz_tb_comm_cm_all_final 
where par_month_id=date_format(current_timestamp(),'yyyyMM') ;

drop view view_yz_XQGZ2025102800070_ba_msdisc;
create view view_yz_XQGZ2025102800070_ba_msdisc as 
select subs_code,subs_stat,act_date,subs_stat_date,sales_code,action_type
from zone_gz_yz.dwm_yz_rpt_comm_ba_msdisc_final;

--20251031  张晓明
宽带到达	主宽到达	0时长线路到达	其中无子账号	子账号为单宽	子账号为融合
截至9月全量宽带口径	截至9月广州主宽口径	统计销售品“DM0001-695-1-1”的到达数	其中D列里面没有子账号的数量		

drop table tmp_yz_liq_zxm_01 purge;
create table tmp_yz_liq_zxm_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select b.subst_order,a.subst_name,serv_id,prod_type,kd_desc,is_cz,is_cancel_user,prod_id,is_rh_ykj 
from zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final a 
LEFT JOIN zone_gz_yz.dwd_yz_dim_subst b ON a.subst_id = b.subst_id 
where a.par_month_id=202509 and prod_type=40 ; 

drop table tmp_yz_liq_zxm_02 purge;
create table tmp_yz_liq_zxm_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id,acc_nbr  
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_mon_final a 
where par_month_id=202509 and par_corp_id='200'
and date_format(limit_date,'yyyyMMdd')>'20250930' 
and prod_offer_id in(500046067) 
group by par_month_id,serv_id,acc_nbr 
;

drop table tmp_yz_liq_zxm_03 purge;
create table tmp_yz_liq_zxm_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.serv_id is not null then 1 else 0 end is_0sc 
from tmp_yz_liq_zxm_01 a 
left join tmp_yz_liq_zxm_02 b on a.serv_id=b.serv_id 
; 

drop table tmp_yz_liq_zxm_04 purge;
create table tmp_yz_liq_zxm_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.a_prod_inst_id,a.z_prod_inst_id,b.prod_id,b.is_rh_ykj  
from dws_crm_cust.dws_prod_inst_rel_a a 
left join dwm_yz_tb_comm_cm_all_final b on b.par_month_id=202510 and a.z_prod_inst_id=cast(b.serv_id as string) 
where a.city_id='200' and b.prod_id=2340 
;

drop table tmp_yz_liq_zxm_05 purge;
create table tmp_yz_liq_zxm_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,case when b.a_prod_inst_id is not null then 1 else 0 end as is_2340  
from tmp_yz_liq_zxm_03 a
left join (select a_prod_inst_id from tmp_yz_liq_zxm_04 group by a_prod_inst_id) b 
on b.a_prod_inst_id=cast(a.serv_id as string);

select 0 subst_order,'广州' subst_name 
,count(case when is_cz=1 then serv_id else null end) as kd_dd 
,count(case when is_cz=1 and kd_desc='普通宽带' then serv_id else null end) as zk_dd 
,count(case when is_cz=1 and is_0sc=1 then serv_id else null end) as kd_dd_0sc  
,count(case when is_cz=1 and is_0sc=1 and is_2340=0 then serv_id else null end) as kd_dd_0zzh  
from tmp_yz_liq_zxm_05 

union all 
select subst_order,subst_name 
,count(case when is_cz=1 then serv_id else null end) as kd_dd 
,count(case when is_cz=1 and kd_desc='普通宽带' then serv_id else null end) as zk_dd 
,count(case when is_cz=1 and is_0sc=1 then serv_id else null end) as kd_dd_0sc  
,count(case when is_cz=1 and is_0sc=1 and is_2340=0 then serv_id else null end) as kd_dd_0zzh  
from tmp_yz_liq_zxm_05 
where subst_order <=11 
group by subst_order,subst_name order by subst_order,subst_name 


--XQGZ2025092600492 需求标题 关于广州2026年清单客户集团行业的需求 
drop table tmp_yz_liq_XQGZ2025092600492_hybq_1 purge;
create table tmp_yz_liq_XQGZ2025092600492_hybq_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.cust_id,a.cust_number,a.party_id,a.party_nbr,a.party_name 
,b.PROV_CONTROL_DEP --省管控部门
--,b.CONTROL_DEP --(SELECT attr_value_name FROM dws_crm_cfguse.dws_attr_value WHERE attr_id=500048116 AND city_id=200 AND attr_value=CONTROL_DEP) 集团管控部门,
--,b.CITY_CONTROL_DEP  --市管控部门
--,b.CITY_INDUSTRY_ID  --市行业小类(全部为空，取不到数据) 
,b.PROV_INDUSTRY_SUB   --省行业小类
,b.INDUSTRY_TYPE_ID,c.industry_type_name  --集团行业小类
from ads_yz_liq_XQGZ2025092600422_list a 
left join (select *,row_number() over(partition by party_id order by update_date desc) as paixu 
			from dws_ecust.dws_party_org_zq ) b on a.party_id=b.party_id and b.paixu=1 
left join dws_crm_cfguse.dws_industry_type c on cast(b.INDUSTRY_TYPE_ID  as string)=c.industry_type_id;

drop table tmp_yz_liq_XQGZ2025092600492_hybq purge;
create table tmp_yz_liq_XQGZ2025092600492_hybq
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 200 as city_id,cust_number,party_nbr,party_name 
,PROV_CONTROL_DEP,industry_type_name,PROV_INDUSTRY_SUB from tmp_yz_liq_XQGZ2025092600492_hybq_1;

--20241217  补充一二三级行业标签
drop table tmp_yz_liq_XQGZ2025092600492_hybq_2 purge;
create table tmp_yz_liq_XQGZ2025092600492_hybq_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select id3,code3,lev3,grade3,id2,code2,lev2,grade2,id1,code1,lev1,grade1
from 
(select industry_type_id id3,industry_type_code code3,industry_type_name lev3,industry_type_grade grade3,par_industry_type_id from dws_crm_cfguse.dws_industry_type 
where  industry_type_grade=3 and status_cd='1000') a
left join 
(select industry_type_id id2,industry_type_code code2,industry_type_name lev2,industry_type_grade grade2,par_industry_type_id from dws_crm_cfguse.dws_industry_type 
where  industry_type_grade=2 and status_cd='1000') b
on a.par_industry_type_id=b.id2
left join 
(select industry_type_id id1,industry_type_code code1,industry_type_name lev1,industry_type_grade grade1,par_industry_type_id from dws_crm_cfguse.dws_industry_type 
where  industry_type_grade=1 and status_cd='1000') c
on b.par_industry_type_id=c.id1;

drop table tmp_yz_liq_XQGZ2025092600492_hybq_3 purge;
create table tmp_yz_liq_XQGZ2025092600492_hybq_3 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.cust_id,a.cust_number,a.party_id,a.party_nbr,a.party_name 
,b.PROV_CONTROL_DEP --省管控部门
,b.CONTROL_DEP  --集团管控部门,
--,b.CITY_CONTROL_DEP  --市管控部门
--,b.CITY_INDUSTRY_ID  --市行业小类(全部为空，取不到数据) 
,b.PROV_INDUSTRY_SUB   --省行业小类
,b.INDUSTRY_TYPE_ID,c.industry_type_name  --集团行业小类
from ads_yz_liq_XQGZ2025092600422_list a 
left join (select *,row_number() over(partition by party_id order by update_date desc) as paixu 
			from dws_ecust.dws_party_org_zq ) b on a.party_id=b.party_id and b.paixu=1 
left join dws_crm_cfguse.dws_industry_type c on cast(b.INDUSTRY_TYPE_ID  as string)=c.industry_type_id;

drop table tmp_yz_liq_XQGZ2025092600492_hybq_4 purge;
create table tmp_yz_liq_XQGZ2025092600492_hybq_4 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,
b.attr_value_name as jt_gk_bm  --集团管控部门
from tmp_yz_liq_XQGZ2025092600492_hybq_3 a 
left join (SELECT attr_value,attr_value_name FROM dws_crm_cfguse.dws_attr_value WHERE attr_id=500048116 AND city_id=200 ) b 
on a.CONTROL_DEP=b.attr_value 
;

drop table tmp_yz_liq_XQGZ2025092600492_hybq_5 purge;
create table tmp_yz_liq_XQGZ2025092600492_hybq_5 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.lev3 --三级行业标签
,b.lev2 --二级行业标签
,b.lev1 --一级行业标签
from tmp_yz_liq_XQGZ2025092600492_hybq_4 a 
left join tmp_yz_liq_XQGZ2025092600492_hybq_2 b on a.INDUSTRY_TYPE_ID=b.id3 ;

--地市	产权编码	P码	集团1级行业	集团2级行业	集团3级行业	集团管控部门	省管控部门
drop table tmp_yz_liq_XQGZ2025092600492_hybq purge;
create table tmp_yz_liq_XQGZ2025092600492_hybq
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 200 as city_id,cust_number,party_nbr,lev1,lev2,lev3,jt_gk_bm,PROV_CONTROL_DEP
from tmp_yz_liq_XQGZ2025092600492_hybq_5;

--XQGZ2025110301891 关于宽带新装清单增加受理工号字段的需求
(1)打标 staff_id、staff_code、sales_man_name、org_id、org_name
select a.* 
,b.staff_id,c.sales_code staff_code,c.sales_man_name  --入网受理人
,b.org_id,d.org_name --入网受理机构
from xxx a 
left join ${v_table_name_comm_serv} b on a.serv_id=b.serv_id and b.par_month_id=${month_id}  
left join ${v_table_name_sales_man_outlers} c on b.staff_id=c.staff_id and 1=1 ${v_par_month_c}
left join dwd_yz_dim_org d on b.org_id=d.org_id 

(2)打标 sys_post_name  --入网受理岗位
drop table if exists tmp_yz_dws_order_item_01 purge;
create table tmp_yz_dws_order_item_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.order_item_id,a.create_post,a.create_date 
from dws_crm_order.dws_order_item a 
union all 
select a.order_item_id,a.create_post,a.create_date 
from dws_crm_order.dws_order_item_his a 
;

drop table if exists tmp_yz_dws_order_item_02 purge;
create table tmp_yz_dws_order_item_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,row_number() over(partition by order_item_id order by create_date desc) as paixu 
from tmp_yz_dws_order_item_01 a;

select a.* 
,c.sys_post_name  --入网受理岗位 
from xxx a 
left join tmp_yz_dws_order_item_02 b on cast(a.subs_id as string)=b.order_item_id and b.paixu=1 
left join dws_crm_cfguse.dws_system_post c on b.create_post=c.sys_post_id 
;

--修改短信接收人
【流程】dwm_ds
修改正式短信接收人,新增单个
create table ads_dim_iap_oc_sms_result_dx_zs_list as 
select * from ads_dim_iap_oc_sms_result_dx_zs
union all 
select '18922189363','黄先葵','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0';

alter table ads_dim_iap_oc_sms_result_dx_zs rename to ads_dim_iap_oc_sms_result_dx_zs_bf_20251105;
alter table ads_dim_iap_oc_sms_result_dx_zs_list rename to ads_dim_iap_oc_sms_result_dx_zs;

修改正式短信接收人,覆盖更新
insert overwrite TABLE zone_gz_yz.ads_dim_iap_oc_sms_result_dx_zs
select index1,index2,index3,index4 from zone_gz_yz_339;

--黃友健
--抽取校园宽带号码数据
drop table tmp_yz_hyj_20251105_01 purge;
create table tmp_yz_hyj_20251105_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id
,substring(acc_nbr2,instr(acc_nbr2,'@')+1,length(acc_nbr2)) ym --域名
,is_new_user,is_cz,is_yx,kd_sc
from zone_gz_yz.ads_yz_tb_comm_cm_all_final --改成自己权限下的全业务资料表名
where prod_type=40 
--and bg_type='教育'  
and kd_desc='校园翼起来' and is_cancel_user=0 
and par_month_id>=202312 and par_month_id<=202510 
;

--抽取当前有代收费标识的号码
drop table tmp_yz_hyj_20251105_02 purge;
create table tmp_yz_hyj_20251105_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a --改成自己权限下的优惠资料表名
where a.prod_offer_id=5734536 group by a.serv_id 
; 

--打标是否代收费
drop table tmp_yz_hyj_20251105_03 purge;
create table tmp_yz_hyj_20251105_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.serv_id is not null then 1 else 0 end is_DM0002_A01 
from tmp_yz_hyj_20251105_01 a 
left join tmp_yz_hyj_20251105_02 b on a.serv_id=b.serv_id 
;

--统计到达用户数
drop table tmp_yz_hyj_20251105_04 purge;
create table tmp_yz_hyj_20251105_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id 
,count(case when is_cz=1 then serv_id else null end) as v1 
,count(case when is_cz=1 and is_DM0002_A01=1 then serv_id else null end) as v2 
,count(case when is_cz=1 and is_DM0002_A01=1 and is_yx=1 then serv_id else null end) as v2_1  
,count(case when is_cz=1 and is_DM0002_A01=1 and kd_sc>60 then serv_id else null end) as v3 
,count(case when is_cz=1 and is_DM0002_A01=0 then serv_id else null end) as v4 
,count(case when is_cz=1 and is_DM0002_A01=0 and is_yx=1 then serv_id else null end) as v5 
from tmp_yz_hyj_20251105_03 
where par_month_id in(202312,202401,202410,202412,202501,202510) 
group by par_month_id order by par_month_id ;

--统计域名维度
drop table tmp_yz_hyj_20251105_05 purge;
create table tmp_yz_hyj_20251105_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select ym 
,count(case when par_month_id>=202507 and par_month_id<=202510 and is_new_user=1 and is_DM0002_A01=1 then serv_id else null end) as v1 
,count(case when par_month_id=202410 and is_cz=1 and is_DM0002_A01=1 then serv_id else null end) as v2 
,count(case when par_month_id=202412 and is_cz=1 and is_DM0002_A01=1 then serv_id else null end) as v3 
,count(case when par_month_id=202510 and is_cz=1 and is_DM0002_A01=1 then serv_id else null end) as v4 

,count(case when par_month_id=202410 and is_cz=1 and is_DM0002_A01=1 and kd_sc>60 then serv_id else null end) as v5 
,count(case when par_month_id=202412 and is_cz=1 and is_DM0002_A01=1 and kd_sc>60 then serv_id else null end) as v6 
,count(case when par_month_id=202510 and is_cz=1 and is_DM0002_A01=1 and kd_sc>60 then serv_id else null end) as v7 
from tmp_yz_hyj_20251105_03 a 
left join (select index2 from zone_gz.school_ym_list group by index2) b on a.ym=b.index2 
where b.index2 is not null
group by ym 
order by ym ;

-- 1元宽带标识
-- SJ0912-A08-1-2        校园天翼宽带高竞争院校融合套餐(首月收费)（1元）_4M_2013年三季度_粤
-- drop table tmp_yz_hyj_20251105_04 purge;
-- create table tmp_yz_hyj_20251105_04  
-- row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
-- as 
-- select a.serv_id 
-- from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
-- where a.prod_offer_id=100001108 group by a.serv_id 
-- ; 


--陈冠文
drop table tmp_yz_cgw_20251107_01 purge;
create table tmp_yz_cgw_20251107_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id,is_rh_ykj  
from ads_yz_kd_new_list
where  kd_desc = '普通宽带'
AND coalesce(prod_name, '-1') NOT LIKE '%专线%' 
AND coalesce(prod_name, '-1') NOT LIKE '%城域网%' 
AND coalesce(kd_prod_offer_name, '-1') NOT LIKE '%0时长%' 
and par_month_id>=202407 and par_month_id<=202511 
; 

drop table if exists tmp_yz_cgw_20251107_02 purge;
create table tmp_yz_cgw_20251107_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.serv_id 
,date_format(a.subs_stat_date,'yyyyMM') as month_id 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where 1=1 and a.par_month_id between 202407 and 202510 and  a.subs_stat = '301200' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300') 
and a.action_id in( 1292,6200 )
and a.prod_offer_id in(100055994) 
group by a.serv_id 
,date_format(a.subs_stat_date,'yyyyMM') 

union all 
select a.serv_id 
,date_format(a.subs_stat_date,'yyyyMM') as month_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where a.subs_stat = '301200' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300') 
and a.action_id in( 1292,6200 )
and a.prod_offer_id in(100055994) 
group by a.serv_id 
,date_format(a.subs_stat_date,'yyyyMM') 
;

drop table if exists tmp_yz_cgw_20251107_03 purge;
create table tmp_yz_cgw_20251107_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case when b.serv_id is not null then 1 else 0 end is_DM0001_660_1_4 
from tmp_yz_cgw_20251107_01 a 
left join (select serv_id,month_id from tmp_yz_cgw_20251107_02 group by serv_id,month_id) b 
on a.serv_id=b.serv_id and a.par_month_id=b.month_id 
; 

drop table if exists tmp_yz_cgw_20251107_04 purge;
create table tmp_yz_cgw_20251107_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select serv_id,par_month_id 
from dwm_yz_tb_comm_cm_all_mon_final 
where prod_type=40 and kd_desc='普通宽带' and is_cancel_user=0 
and par_month_id>=202501 and par_month_id<=202510 
and coalesce(state,'-1')<>'140001'


union all 
select serv_id,par_month_id 
from dwm_yz_tb_comm_cm_all_final 
where prod_type=40 and kd_desc='普通宽带' and is_cancel_user=0 
and par_month_id=202511 
and coalesce(state,'-1')<>'140001'
; 

drop table if exists tmp_yz_cgw_20251107_05 purge;
create table tmp_yz_cgw_20251107_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case when b1.serv_id is not null then 1 else 0 end is_zw_202501 
,case when b2.serv_id is not null then 1 else 0 end is_zw_202502 
,case when b3.serv_id is not null then 1 else 0 end is_zw_202503 
,case when b4.serv_id is not null then 1 else 0 end is_zw_202504 
,case when b5.serv_id is not null then 1 else 0 end is_zw_202505 
from tmp_yz_cgw_20251107_03 a 
left join tmp_yz_cgw_20251107_04 b1 on a.serv_id=b1.serv_id and b1.par_month_id=202501 
left join tmp_yz_cgw_20251107_04 b2 on a.serv_id=b2.serv_id and b2.par_month_id=202502 
left join tmp_yz_cgw_20251107_04 b3 on a.serv_id=b3.serv_id and b3.par_month_id=202503 
left join tmp_yz_cgw_20251107_04 b4 on a.serv_id=b4.serv_id and b4.par_month_id=202504 
left join tmp_yz_cgw_20251107_04 b5 on a.serv_id=b5.serv_id and b5.par_month_id=202505  
;

drop table if exists tmp_yz_cgw_20251107_06 purge;
create table tmp_yz_cgw_20251107_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case when b6.serv_id is not null then 1 else 0 end is_zw_202506 
,case when b7.serv_id is not null then 1 else 0 end is_zw_202507 
,case when b8.serv_id is not null then 1 else 0 end is_zw_202508 
,case when b9.serv_id is not null then 1 else 0 end is_zw_202509 
,case when b10.serv_id is not null then 1 else 0 end is_zw_202510 
,case when b11.serv_id is not null then 1 else 0 end is_zw_202511 
from tmp_yz_cgw_20251107_05 a 
left join tmp_yz_cgw_20251107_04 b6 on a.serv_id=b6.serv_id and b6.par_month_id=202506 
left join tmp_yz_cgw_20251107_04 b7 on a.serv_id=b7.serv_id and b7.par_month_id=202507 
left join tmp_yz_cgw_20251107_04 b8 on a.serv_id=b8.serv_id and b8.par_month_id=202508 
left join tmp_yz_cgw_20251107_04 b9 on a.serv_id=b9.serv_id and b9.par_month_id=202509 
left join tmp_yz_cgw_20251107_04 b10 on a.serv_id=b10.serv_id and b10.par_month_id=202510 
left join tmp_yz_cgw_20251107_04 b11 on a.serv_id=b11.serv_id and b11.par_month_id=202511 
;

drop table if exists tmp_yz_cgw_20251107_07 purge;
create table tmp_yz_cgw_20251107_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id 
,count(case when is_DM0001_660_1_4=1 then serv_id else null end) v1 
,count(case when is_DM0001_660_1_4=1 and is_zw_202501=1 then serv_id else null end) v2 
,count(case when is_DM0001_660_1_4=1 and is_zw_202502=1 then serv_id else null end) v3 
,count(case when is_DM0001_660_1_4=1 and is_zw_202503=1 then serv_id else null end) v4 
,count(case when is_DM0001_660_1_4=1 and is_zw_202504=1 then serv_id else null end) v5 
,count(case when is_DM0001_660_1_4=1 and is_zw_202505=1 then serv_id else null end) v6 
,count(case when is_DM0001_660_1_4=1 and is_zw_202506=1 then serv_id else null end) v7 
,count(case when is_DM0001_660_1_4=1 and is_zw_202507=1 then serv_id else null end) v8 
,count(case when is_DM0001_660_1_4=1 and is_zw_202508=1 then serv_id else null end) v9 
,count(case when is_DM0001_660_1_4=1 and is_zw_202509=1 then serv_id else null end) v10 
,count(case when is_DM0001_660_1_4=1 and is_zw_202510=1 then serv_id else null end) v11 
,count(case when is_DM0001_660_1_4=1 and is_zw_202511=1 then serv_id else null end) v12 
from tmp_yz_cgw_20251107_06 
group by par_month_id order by par_month_id ;

drop table if exists tmp_yz_cgw_20251107_08 purge;
create table tmp_yz_cgw_20251107_08  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id 
,count(case when is_DM0001_660_1_4=1 then serv_id else null end) v1 
,count(case when is_DM0001_660_1_4=1 and is_zw_202501=1 then serv_id else null end) v2 
,count(case when is_DM0001_660_1_4=1 and is_zw_202502=1 then serv_id else null end) v3 
,count(case when is_DM0001_660_1_4=1 and is_zw_202503=1 then serv_id else null end) v4 
,count(case when is_DM0001_660_1_4=1 and is_zw_202504=1 then serv_id else null end) v5 
,count(case when is_DM0001_660_1_4=1 and is_zw_202505=1 then serv_id else null end) v6 
,count(case when is_DM0001_660_1_4=1 and is_zw_202506=1 then serv_id else null end) v7 
,count(case when is_DM0001_660_1_4=1 and is_zw_202507=1 then serv_id else null end) v8 
,count(case when is_DM0001_660_1_4=1 and is_zw_202508=1 then serv_id else null end) v9 
,count(case when is_DM0001_660_1_4=1 and is_zw_202509=1 then serv_id else null end) v10 
,count(case when is_DM0001_660_1_4=1 and is_zw_202510=1 then serv_id else null end) v11 
,count(case when is_DM0001_660_1_4=1 and is_zw_202511=1 then serv_id else null end) v12 
from tmp_yz_cgw_20251107_06 where is_rh_ykj=1 
group by par_month_id order by par_month_id ;

--20251110  XQGZ2025111002167  刘丽娜
drop table tmp_yz_XQGZ2025111002167_01 purge;
create table tmp_yz_XQGZ2025111002167_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.open_date,'yyyyMM') rw_month,a.subst_name,a.region_type
,CASE WHEN a.speed_value>= 1000 then '是' else '否' end as is_qz 
,a.serv_id,a.rh_tc_id 
,case when b.serv_id is not null then '是' else '否' end as is_fttr 
from dwm_yz_tb_comm_cm_all_mon_final a 
left join dwm_fttr_list b on a.serv_id=b.serv_id and b.par_month_id=${month_id} and b.create_date>='${this_month_first_date}' 
where a.prod_type=40 and a.is_rh_ykj=1 and a.rh_type_ykj='新宽带新移动' 
and a.par_month_id=${month_id} and coalesce(a.prod_type2,-1) not in(50); 

drop table tmp_yz_XQGZ2025111002167_02 purge;
create table tmp_yz_XQGZ2025111002167_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.rh_tc_id,a.serv_id,a.is_contract,a.is_vice_card,a.is_hy 
,case when a.stm_data+a.mou_call+a.mgs_counts>=30 then 1 else 0 end as is_yd_hy 
,case when b.serv_id is not null then 1 else 0 end is_ai 
from dwm_yz_tb_comm_cm_all_mon_final a 
left join ads_hdk_2025033002_ai b on a.serv_id=b.serv_id and b.par_month_id = ${month_id} 
and (b.is_aiznp=1 or b.is_aikj=1 or b.is_aiyl=1 or b.is_scb=1 or b.is_czcb=1) 
where a.prod_type=30 and a.is_rh_ykj=1 and a.par_month_id=${month_id}; 

drop table tmp_yz_XQGZ2025111002167_03 purge;
create table tmp_yz_XQGZ2025111002167_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select rh_tc_id 
,count(case when is_contract=1 and is_vice_card=0 then serv_id else null end) as hy_nums 
,count(case when is_ai=1 then serv_id else null end) as ai_nums 
,count(case when is_yd_hy=1 then serv_id else null end) as huoy_yd_nums 
from tmp_yz_XQGZ2025111002167_02 a 
group by rh_tc_id;

drop table tmp_yz_XQGZ2025111002167_04 purge;
create table tmp_yz_XQGZ2025111002167_04   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*
,case when b.hy_nums>0 then '是' else '否' end as is_hy 
,case when b.ai_nums>0 then '是' else '否' end as is_ai 
,case when b.huoy_yd_nums>=2 then '是' else '否' end as is_huoyue 
from tmp_yz_XQGZ2025111002167_01 a 
left join tmp_yz_XQGZ2025111002167_03 b on a.rh_tc_id=b.rh_tc_id ; 

drop table tmp_yz_XQGZ2025111002167_dwb purge;
create table tmp_yz_XQGZ2025111002167_dwb   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select rw_month,subst_name,region_type,is_qz,is_hy,is_fttr,is_ai,is_huoyue
,count(serv_id) xkxy_nums 
from tmp_yz_XQGZ2025111002167_04 a 
group by rw_month,subst_name,region_type,is_qz,is_hy,is_fttr,is_ai,is_huoyue; 

alter table ads_yz_XQGZ2025062600676_dwb drop if exists partition(par_month_id='${month_id}');
insert into table ads_yz_XQGZ2025062600676_dwb(subst_name,region_type,is_qz,is_hy,is_fttr,is_ai,is_huoyue,xkxy_nums 
,par_month_id)
select subst_name,region_type,is_qz,is_hy,is_fttr,is_ai,is_huoyue,xkxy_nums 
,rw_month from tmp_yz_XQGZ2025111002167_dwb;

--20251113  吴伟宁
drop table tmp_yz_wwn_20251113_1 purge;
create table tmp_yz_wwn_20251113_1 as 
select cust_id,cust_number,cust_name,create_date
,row_number() over(partition by cust_number,cust_name order by create_date desc) paixu 
from dws_crm_cust.dws_customer where city_id=200;

drop table tmp_yz_wwn_20251113_2 purge;
create table tmp_yz_wwn_20251113_2 as 
select a.index1 as gs_name,a.index2 cust_type 
,b.cust_id,b.cust_number,b.cust_name,b.create_date 
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_wwn_20251113_1 b on a.index1=b.cust_name and b.paixu=1
;

drop table tmp_yz_wwn_20251113_3 purge;
create table tmp_yz_wwn_20251113_3 as 
select a.* 
,b.ccust_id
from tmp_yz_wwn_20251113_2 a 
left join (select distinct cust_nbr,ccust_id from dws_yz_tb_mo_custgrp_cust_final) b on a.cust_number=b.cust_nbr 
;

drop table tmp_yz_wwn_20251113_4 purge;
create table tmp_yz_wwn_20251113_4 as 
select a.* 
,case when b.ccust_id is not null then '是' else '否' end is_mdz 
,b.subst_name cust_subst_name,b.branch_name cust_branch_name
from tmp_yz_wwn_20251113_3 a 
left join ads_yz_mo_ccust_mdz_final b 
on a.ccust_id=b.ccust_id 
;

--划小业务最大收入局向
drop table tmp_yz_wwn_20251113_5 purge;
create table tmp_yz_wwn_20251113_5 as 
select cust_nbr,subst_name,branch_name, 
sum(a0) as sh_qr,--税后确认收入
sum(fee_cs) as cs_sr  --产数收入
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id >= 202501 and par_month_id<=202510 
group by cust_nbr,subst_name,branch_name;

--划小业务最大收入局向
drop table tmp_yz_wwn_20251113_6 purge;
create table tmp_yz_wwn_20251113_6 as 
select a.* 
,row_number() over(partition by cust_nbr order by sh_qr desc) as paixu 
from tmp_yz_wwn_20251113_5 a;

--落地业务最大收入局向\揽装业务收入最大局向
drop table tmp_yz_wwn_20251113_8 purge;
create table tmp_yz_wwn_20251113_8 as 
select a.*,b.subst_name max_subst_name ,b.branch_name max_branch_name
from tmp_yz_wwn_20251113_4 a 
left join (select * from tmp_yz_wwn_20251113_6 where paixu=1) b on a.cust_number=b.cust_nbr 
;

drop table tmp_yz_wwn_20251113_9 purge;
create table tmp_yz_wwn_20251113_9 as 
select cust_nbr, 
sum(a0) as sh_qr,--税后确认收入
sum(fee_cs) as cs_sr  --产数收入 
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id >= 202401 and par_month_id<=202410 
group by cust_nbr;

drop table tmp_yz_wwn_20251113_10 purge;
create table tmp_yz_wwn_20251113_10 as 
select a.*,b.sh_qr as sr_2024 ,b.cs_sr cs_sr_2024 
from tmp_yz_wwn_20251113_8 a 
left join tmp_yz_wwn_20251113_9 b on a.cust_number=b.cust_nbr
;

drop table tmp_yz_wwn_20251113_11 purge;
create table tmp_yz_wwn_20251113_11 as 
select cust_nbr  
,count(case when par_month_id=202410 and prod_type=30 then serv_id else null end) as yd_2024  
,count(case when par_month_id=202410 and prod_type=40 then serv_id else null end) as kd_2024 
,count(case when par_month_id=202410 and prod_type2 in(60) then serv_id else null end) as hlw_zx_2024  
,count(case when par_month_id=202410 and prod_type2 in(70,71) then serv_id else null end) as zw_zx_2024  

,count(case when par_month_id=202510 and prod_type=30 then serv_id else null end) as yd_2025  
,count(case when par_month_id=202510 and prod_type=40 then serv_id else null end) as kd_2025 
,count(case when par_month_id=202510 and prod_type2 in(60) then serv_id else null end) as hlw_zx_2025  
,count(case when par_month_id=202510 and prod_type2 in(70,71) then serv_id else null end) as zw_zx_2025  
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id in(202410,202510) and is_cz=1 
group by cust_nbr;

drop table tmp_yz_wwn_20251113_12 purge;
create table tmp_yz_wwn_20251113_12 as 
select a.*
,b.yd_2025 ,b.kd_2025 ,b.hlw_zx_2025 ,b.zw_zx_2025 
,b.yd_2024 ,b.kd_2024 ,b.hlw_zx_2024 ,b.zw_zx_2024 
from tmp_yz_wwn_20251113_10 a 
left join tmp_yz_wwn_20251113_11 b on a.cust_number=b.cust_nbr
; 

drop table tmp_yz_wwn_20251113_13 purge;
create table tmp_yz_wwn_20251113_13 as 
select cust_nbr, 
sum(a0) as sh_qr,--税后确认收入
sum(fee_cs) as cs_sr  --产数收入 
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id >= 202501 and par_month_id<=202510 
group by cust_nbr;

drop table tmp_yz_wwn_20251113_14 purge;
create table tmp_yz_wwn_20251113_14 as 
select a.*,b.sh_qr as sr_2025 ,b.cs_sr cs_sr_2025 
from tmp_yz_wwn_20251113_12 a 
left join tmp_yz_wwn_20251113_13 b on a.cust_number=b.cust_nbr
;

drop table tmp_yz_wwn_20251113_15 purge;
create table tmp_yz_wwn_20251113_15 as 
select a.*,row_number() over(order by gs_name,cust_type,cust_number asc) as paixu 
from tmp_yz_wwn_20251113_14 a;

select gs_name,cust_type,cust_number,is_mdz,cust_subst_name,cust_branch_name 
,max_subst_name,max_branch_name,sr_2025 ,sr_2024 
,yd_2025,kd_2025,hlw_zx_2025,zw_zx_2025,cs_sr_2025 
,yd_2024,kd_2024,hlw_zx_2024,zw_zx_2024,cs_sr_2024
from tmp_yz_wwn_20251113_15 where paixu>=1 and paixu<=1000 


--20251119  XQGZ2025111702119 需求标题 关于省公司稽核小微号码匹配CRM字段的需求 
--订单备注 
drop table tmp_yz_XQGZ2025111702119_01 purge;
create table tmp_yz_XQGZ2025111702119_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.order_item_id,a.remark,a.create_date from dws_crm_order.dws_order_item a 
union all 
select a.order_item_id,a.remark,a.create_date from dws_crm_order.dws_order_item_his a 
;

drop table tmp_yz_XQGZ2025111702119_02 purge;
create table tmp_yz_XQGZ2025111702119_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,row_number() over(partition by order_item_id order by create_date desc) as paixu 
from tmp_yz_XQGZ2025111702119_01 a;

drop table tmp_yz_XQGZ2025111702119_03 purge;
create table tmp_yz_XQGZ2025111702119_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1,a.index2,a.index3,a.index4,b.remark 
from zone_gz_yz_3351225714708480 a 
left join (select * from tmp_yz_XQGZ2025111702119_02 where paixu=1) b on a.index3=b.order_item_id 
;

drop table tmp_yz_XQGZ2025111702119_04 purge;
create table tmp_yz_XQGZ2025111702119_04   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 200 as city_id,a.index1,a.index3,a.index4,a.remark from tmp_yz_XQGZ2025111702119_03 a order by cast(index1 as int);

--20251121  覃朗然 
select  a.prod_flag,a.sum_date,a.serv_id,b.cell_name,b.cell_code
,case when jf_value>=129 then 1 else 0 end is_gt
,gtqz_zs_value
from 
(select prod_flag,sum_date,serv_id,jf_value,gtqz_zs_value from dwd_yz_531gt_new_finish_sum_list where month_id=202511 and prod_flag in ('合约单移','高套')) a
left join (select *  from dwm_yz_tb_comm_cm_all_final where par_month_id=202511) b
on a.serv_id=b.serv_Id

select  a.prod_flag  --合约单移/高套，高套：新装宽带
,b.cell_name  --网格名称
,b.cell_code  --网格编码
,count(a.serv_id) as xz_gt --新装高套数
,sum(gtqz_zs_value) as gt_zs --折算值
from 
(select prod_flag,sum_date,serv_id,jf_value,gtqz_zs_value from dwd_yz_531gt_new_finish_sum_list 
where month_id=202511 and sum_date>='20251113' and sum_date<='20251119'   --修改月份和时间
and prod_flag in ('合约单移','高套') and jf_value>=129) a
left join (select *  from dwm_yz_tb_comm_cm_all_final where par_month_id=202511 --修改月份
) b on a.serv_id=b.serv_Id 
group by a.prod_flag,b.cell_name,b.cell_code 
limit 1000 

--20251127  张建新
drop table tmp_yz_zjx_20251127_01 purge;
create table tmp_yz_zjx_20251127_01    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cell_code 
,count(case when par_month_id=202510 and is_cz=1 then serv_id else null end) v1 
,count(case when par_month_id=202510 and is_cz=1 and rh_tc_value>=129 then serv_id else null end) v2 
,count(case when par_month_id=202506 and is_new_user=1 then serv_id else null end) v3 
,count(case when par_month_id=202507 and is_new_user=1 then serv_id else null end) v4 
,count(case when par_month_id=202508 and is_new_user=1 then serv_id else null end) v5 
,count(case when par_month_id=202509 and is_new_user=1 then serv_id else null end) v6 
,count(case when par_month_id=202510 and is_new_user=1 then serv_id else null end) v7 

,count(case when par_month_id=202506 and is_cancel_user=1 then serv_id else null end) v8 
,count(case when par_month_id=202507 and is_cancel_user=1 then serv_id else null end) v9 
,count(case when par_month_id=202508 and is_cancel_user=1 then serv_id else null end) v10 
,count(case when par_month_id=202509 and is_cancel_user=1 then serv_id else null end) v11 
,count(case when par_month_id=202510 and is_cancel_user=1 then serv_id else null end) v12 

,count(case when par_month_id=202510 and is_cz=1 and rh_tc_value>=199 then serv_id else null end) v13 
from dwm_yz_tb_comm_cm_all_mon_final 
where prod_type=40 and par_month_id>=202506 and par_month_id<=202510 
and cell_code in ('200031315690792',
'20003230012918',
'20003230007745',
'20003230007352',
'200031557636',
'200031315690791',
'200031557650',
'200031143363021',
'2009121100091620411',
'2009121100132047328',
'200031558062',
'200031558079',
'20003230008273',
'200031315690790',
'200031317968289',
'200031557336',
'200031558080',
'20003230008515',
'200031328858703',
'200031328858704',
'2009121100091607158',
'2009121100091607159') group by cell_code ;

--20251127  XQGZ2025111400930
drop table tmp_yz_XQGZ2025111400930_01 purge;
create table tmp_yz_XQGZ2025111400930_01    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1,a.index2,a.index3 
,b.v1 stm_data_202508 
,b.v2 mou_call_202508 
,b.v3 mgs_counts_202508   
from zone_gz_yz_3351225714708480 a 
join (select acc_nbr,sum(stm_data) v1 ,sum(mou_call) v2 ,sum(mgs_counts) v3 
	from dwm_yz_tb_comm_cm_all_mon_final 
	where prod_type=30 and par_month_id=202508 group by acc_nbr ) b  
on a.index1=b.acc_nbr 
order by cast(a.index3 as int) asc; 

drop table tmp_yz_XQGZ2025111400930_02 purge;
create table tmp_yz_XQGZ2025111400930_02    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*  
,b.v1 stm_data_202509 
,b.v2 mou_call_202509 
,b.v3 mgs_counts_202509   
from tmp_yz_XQGZ2025111400930_01 a 
join (select acc_nbr,sum(stm_data) v1 ,sum(mou_call) v2 ,sum(mgs_counts) v3 
	from dwm_yz_tb_comm_cm_all_mon_final 
	where prod_type=30 and par_month_id=202509 group by acc_nbr ) b  
on a.index1=b.acc_nbr 
order by cast(a.index3 as int) asc; 

drop table tmp_yz_XQGZ2025111400930_03 purge;
create table tmp_yz_XQGZ2025111400930_03    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*  
,b.v1 stm_data_202510 
,b.v2 mou_call_202510 
,b.v3 mgs_counts_202510   
from tmp_yz_XQGZ2025111400930_02 a 
join (select acc_nbr,sum(stm_data) v1 ,sum(mou_call) v2 ,sum(mgs_counts) v3 
	from dwm_yz_tb_comm_cm_all_mon_final 
	where prod_type=30 and par_month_id=202510 group by acc_nbr ) b  
on a.index1=b.acc_nbr 
order by cast(a.index3 as int) asc; 

--20251203  陈思平
--号码竣工日期、合同编码、揽装人、划小营服
drop table tmp_yz_csp_20251203_01 purge;
create table tmp_yz_csp_20251203_01    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1,a.index2,a.index3,a.index4 
,b.serv_id,b.open_date,b.sales_name,b.branch_name 
from zone_gz_yz_3351225714708480 a 
left join dwm_yz_tb_comm_cm_all_final b on a.index2=b.acc_nbr and b.par_month_id=202512 
;

drop table tmp_yz_csp_20251203_02 purge;
create table tmp_yz_csp_20251203_02    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id
,attr_id --特性id（产品规格属性）
,attr_value1  --特性值
,create_date   --订购时间
from summary_ods_day_city.tb_pre_cm_attr_all  --特性资料表 
where par_corp_id='200' and attr_id=200009325
union all 
select serv_id
,attr_id --特性id（产品规格属性）
,attr_value1  --特性值
,create_date   --订购时间
from iodata_ods_month_city.tb_pre_cm_attr_all_mon   --特性资料表 
where par_corp_id='200' and attr_id=200009325;

drop table tmp_yz_csp_20251203_03 purge;
create table tmp_yz_csp_20251203_03    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select *,row_number() over(partition by serv_id order by create_date desc) as paixu 
from tmp_yz_csp_20251203_02;

drop table tmp_yz_csp_20251203_04 purge;
create table tmp_yz_csp_20251203_04    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.attr_value1 
from tmp_yz_csp_20251203_01 a 
left join tmp_yz_csp_20251203_03 b on a.serv_id=b.serv_id and b.paixu=1 
;

--20251208 尚庆磊
set hivevar:v_table_name_comm_all = $([ "${yyyymmdd:0:6}" = "$(date +%Y%m)" ] && printf "dwm_yz_tb_comm_cm_all_final" || printf "dwm_yz_tb_comm_cm_all_mon_final") ;
set hivevar:v_table_name_comm_disc = $([ "${yyyymmdd:0:6}" = "$(date +%Y%m)" ] && printf "dwd_yz_rpt_comm_cm_msdisc_final" || printf "dwd_yz_rpt_comm_cm_msdisc_mon_final");

set hivevar:month_id=`date -d "${yyyymmdd}" +%Y%m`;                  -- 统计日期所属月（YYYYMM）
set hivevar:this_month_last_date=`date -d "$(date -d "${yyyymmdd}" +%Y%m01) +1month -1day" +%Y%m%d`;  -- 统计日期当月最后一天

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;

drop table tmp_yz_dkjk_01 purge;
create table tmp_yz_dkjk_01    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id,subst_id,subst_name,branch_id,branch_name 
,std_subst_id,std_subst_name,std_branch_id,std_branch_name 
,cust_name,serv_addr_id,open_date,is_cancel_user
,case when state in('120000','120009') then 1 else 0 end is_tingji 
from \${v_table_name_comm_all}  
where par_month_id=\${month_id} and date_format(open_date,'yyyyMM')='\${month_id}' 
and region_type = '城中村'
and is_gsm=1 and prod_type=40 
and prod_type3 in('WiFi宽带','快捷宽带') and is_rh_ykj=0 
;

drop table tmp_yz_dkjk_02 purge;
create table tmp_yz_dkjk_02    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id 
from  zone_gz_yz.ads_ys_lst_qf_pushdata_daily_bss 
where stat_date_id=\${this_month_last_date} 
and qf_fee>0--每次取欠费用时点值 stat_date_id，qf_fee就是欠费金额 
group by serv_id 
;

drop table tmp_yz_dkjk_03 purge;
create table tmp_yz_dkjk_03    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id
,coalesce(is_yx,0) as is_yx_kd  --是否省有效宽带
from summary_ods_month_city.tb_comm_cm_data_mon 
where par_corp_id=200 and par_month_id=\${month_id} 
; 

drop table tmp_yz_dkjk_04 purge;
create table tmp_yz_dkjk_04    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_addr_id,open_date
,row_number() over(partition by serv_addr_id order by open_date asc) as paixu 
from tmp_yz_dkjk_01 ;

drop table tmp_yz_dkjk_05 purge;
create table tmp_yz_dkjk_05    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_addr_id,a.rh_tc_id  
from \${v_table_name_comm_all} a 
join tmp_yz_dkjk_04 b on a.serv_addr_id=b.serv_addr_id and b.paixu=1 
and date_format(a.open_date,'yyyyMMdd')>=date_format(b.open_date,'yyyyMMdd')
where a.par_month_id=\${month_id} and prod_type=40 and coalesce(prod_type2,-1)<>50 
and is_rh_ykj=1 and rh_type_ykj in('新宽带新移动','新宽带老移动','老宽带新移动') 

union all 
select a.serv_addr_id,a.rh_tc_id  
from \${v_table_name_comm_all} a 
join tmp_yz_dkjk_04 b on a.serv_addr_id=b.serv_addr_id and b.paixu=1 
and date_format(a.open_date,'yyyyMMdd')>=date_format(b.open_date,'yyyyMMdd')
where a.par_month_id=\${month_id} and prod_type=30 
and is_rh_ykj=1 and rh_type_ykj in('新宽带新移动','新宽带老移动','老宽带新移动') 
;

drop table tmp_yz_dkjk_06 purge;
create table tmp_yz_dkjk_06    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_addr_id,count(distinct rh_tc_id) rh_rw 
from tmp_yz_dkjk_05 group by serv_addr_id; 

drop table tmp_yz_dkjk_07 purge;
create table tmp_yz_dkjk_07    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b1.serv_id is not null then 1 else 0 end is_qf 
,b2.is_yx_kd,b3.rh_rw 
from tmp_yz_dkjk_01 a 
left join tmp_yz_dkjk_02 b1 on a.serv_id=b1.serv_id 
left join tmp_yz_dkjk_03 b2 on a.serv_id=b2.serv_id 
left join tmp_yz_dkjk_06 b3 on a.serv_addr_id=b3.serv_addr_id 
;

drop table tmp_yz_dkjk_08 purge;
create table tmp_yz_dkjk_08    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select subst_id,subst_name,branch_id,branch_name 
,std_subst_id,std_subst_name,std_branch_id,std_branch_name 
,cust_name 
,count(serv_id) v1 --名下单宽数
,count(distinct serv_addr_id) v2 --十级地址数 
,count(case when is_cancel_user=0 then serv_id else null end) v3 --在网数
,count(case when is_qf=1 then serv_id else null end) v4 --欠费数
,count(case when is_tingji=1 then serv_id else null end) v5 --宽带停机数 
,count(case when is_yx_kd=1 then serv_id else null end) v6 --宽带有效数 
,sum(rh_rw) v7 
from tmp_yz_dkjk_07 
group by subst_id,subst_name,branch_id,branch_name 
,std_subst_id,std_subst_name,std_branch_id,std_branch_name 
,cust_name ;

drop table tmp_yz_dkjk_09 purge;
create table tmp_yz_dkjk_09    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id,subst_id,subst_name,branch_id,branch_name 
,std_subst_id,std_subst_name,std_branch_id,std_branch_name 
,serv_addr_id,open_date,is_cancel_user,a.rh_tc_id 
,case when state in('120000','120009') then 1 else 0 end is_tingji 
from \${v_table_name_comm_all} a 
join  (select rh_tc_id from tmp_yz_dkjk_05 group by rh_tc_id) b on a.rh_tc_id=b.rh_tc_id 
where par_month_id=\${month_id} 
and prod_type=40 and coalesce(prod_type2,-1)<>50 
;

drop table tmp_yz_dkjk_10 purge;
create table tmp_yz_dkjk_10    
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.rh_tc_id,sum(a.is_yx) yx_nums 
from \${v_table_name_comm_all} a 
join  (select rh_tc_id from tmp_yz_dkjk_05 group by rh_tc_id) b on a.rh_tc_id=b.rh_tc_id 
where par_month_id=\${month_id} 
and prod_type=30 and is_rh_ykj=1 
group by a.rh_tc_id 
;

drop table tmp_yz_dkjk_11 purge;
create table tmp_yz_dkjk_11     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b1.serv_id is not null then 1 else 0 end is_qf 
,b2.is_yx_kd,case when b3.yx_nums>0 then 1 else 0 end is_tcyd_yx  
from tmp_yz_dkjk_09 a 
left join tmp_yz_dkjk_02 b1 on a.serv_id=b1.serv_id 
left join tmp_yz_dkjk_03 b2 on a.serv_id=b2.serv_id 
left join tmp_yz_dkjk_10 b3 on a.rh_tc_id=b3.rh_tc_id 
;

drop table tmp_yz_dkjk_12 purge;
create table tmp_yz_dkjk_12     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select subst_id,subst_name,branch_id,branch_name 
,std_subst_id,std_subst_name,std_branch_id,std_branch_name 
,count(distinct serv_addr_id) v1 --十级地址数 
,count(distinct rh_tc_id) v2 --新装融合数 
,count(case when is_cancel_user=0 then serv_id else null end) v3 --在网数 
,count(case when is_qf=1 then serv_id else null end) v4 --欠费数 
,count(case when is_tingji=1 then serv_id else null end) v5 --宽带停机数 
,count(case when is_yx_kd=1 then serv_id else null end) v6 --宽带有效数 
,count(case when is_tcyd_yx=1 then serv_id else null end) v7 --套餐级移动活跃数 
from tmp_yz_dkjk_11 
group by subst_id,subst_name,branch_id,branch_name 
,std_subst_id,std_subst_name,std_branch_id,std_branch_name 
;

--20251210 XQGZ2025120801641 需求标题 广州松下空调器有限公司宽带使用记录查询的需求 
drop table tmp_yz_XQGZ2025120801641_01 purge;
create table tmp_yz_XQGZ2025120801641_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select index1 as xuhao,index2 as acc_nbr,c.kd_ll,c.kd_sc
from zone_gz_yz_3351225714708480 a 
left join 
(select acc_nbr,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll, --宽带流量 单位M
cast(SEND_FLUX/1048576 as decimal(22,2)) kd_sxll, --宽带上行流量 单位M
cast(RECV_FLUX/1048576 as decimal(22,2)) kd_xxll, --宽带下行流量 单位M
cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon where par_corp_id=200 and par_month_id=202511) c
on a.index2=c.acc_nbr 
;

--20251210  XQGZ2025120301012 需求标题 关于欠费快捷宽带批量提取无使用记录的需求 
drop table tmp_yz_XQGZ2025120301012_01 purge;
create table tmp_yz_XQGZ2025120301012_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select acc_nbr,par_month_id,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll, --宽带流量 单位M
cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon where par_corp_id=200 
and par_month_id>=202407 and par_month_id<=202409 
and acc_nbr in('CZCZKD2597914708',
'CZCZKD2597916429',
'CZCZKD2597917472',
'CZCZKD2597919222',
'CZCZKD2597923890',
'CZCZKD2597923891',
'CZCZKD2597915780',
'CZCZKD2597916428',
'CZCZKD2597917471',
'CZCZKD2597917526',
'CZCZKD2597918229',
'CZCZKD2597922911',
'CZCZKD2597922917',
'CZCZKD2597923892',
'CZCZKD2597923893')
;

drop table tmp_yz_XQGZ2025120301012_02 purge;
create table tmp_yz_XQGZ2025120301012_02     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select b.index1 as xuhao,a.acc_nbr,a.par_month_id,a.kd_ll,a.kd_sc
from (select acc_nbr,par_month_id,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll, --宽带流量 单位M
cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon 
where par_corp_id=200 and par_month_id>=202305 and par_month_id<=202510) a 
join zone_gz_yz_3351225714708480 b on a.acc_nbr=b.index3  
;

--20251210  XQGZ2025120500989 需求标题 关于白云新市城中村长账龄欠费业务的批量虚增欠费核查申请 
drop table tmp_yz_XQGZ2025120500989_01 purge;
create table tmp_yz_XQGZ2025120500989_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select b.index1 as xuhao,a.acc_nbr,b.index3 as cust_name,a.par_month_id,a.kd_ll,a.kd_sc
from (select acc_nbr,par_month_id,cast(NET_FLUX/1048576 as decimal(22,2)) kd_ll, --宽带流量 单位M
cast(NET_INNET_DUR/60 as decimal(22,2)) kd_sc  --宽带上网时长 单位分
from summary_ods_month_city.tb_comm_ywl_data_mon 
where par_corp_id=200 and par_month_id>=202308 and par_month_id<=202409) a 
join zone_gz_yz_3351225714708480 b on a.acc_nbr=b.index2  
;

--20251210  张晓明
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;

drop table tmp_yz_zxm_20251210_01 purge;
create table tmp_yz_zxm_20251210_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select channel_subtype_2011,serv_id,par_month_id,subs_stat_date 
from dwm_yz_rpt_comm_ba_subs_mon_final a 
where a.subs_stat <> '499999' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300') 
and action_type = 'NEW' 
and date_format(subs_stat_date,'yyyyMM') >= '202510' 
and date_format(subs_stat_date,'yyyyMM') <= '202512' 
and par_month_id>=202510 and par_month_id<=202511 
and coalesce(prod_id,-1) not in(3204,3205)

union all 
select channel_subtype_2011,serv_id,'202512' par_month_id,subs_stat_date 
from dwm_yz_rpt_comm_ba_subs_final a 
where a.subs_stat <> '499999' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300') 
and action_type = 'NEW' 
and date_format(subs_stat_date,'yyyyMM') >= '202510' 
and date_format(subs_stat_date,'yyyyMM') <= '202512' 
and coalesce(prod_id,-1) not in(3204,3205) 
;

drop table tmp_yz_zxm_20251210_02 purge;
create table tmp_yz_zxm_20251210_02     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.subst_name,b.channel_subst_name,b.prod_type,b.kd_desc 
from tmp_yz_zxm_20251210_01 a 
left join dwm_yz_tb_comm_cm_all_final b on a.par_month_id=b.par_month_id and a.serv_id=b.serv_id 
;

drop table tmp_yz_zxm_20251210_03 purge;
create table tmp_yz_zxm_20251210_03     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select *,row_number() over(partition by par_month_id,serv_id order by subs_stat_date desc) as paixu 
from  tmp_yz_zxm_20251210_02 ;

drop table tmp_yz_zxm_20251210_04 purge;
create table tmp_yz_zxm_20251210_04     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select channel_subtype_2011 
,count(case when par_month_id=202510 and channel_subst_name='海珠分公司' then serv_id else null end) v1 
,count(case when par_month_id=202510 and coalesce(channel_subst_name,'-1')<>'海珠分公司' then serv_id else null end) v2  
,count(case when par_month_id=202511 and channel_subst_name='海珠分公司' then serv_id else null end) v3 
,count(case when par_month_id=202511 and coalesce(channel_subst_name,'-1')<>'海珠分公司' then serv_id else null end) v4 
,count(case when par_month_id=202512 and channel_subst_name='海珠分公司' then serv_id else null end) v5 
,count(case when par_month_id=202512 and coalesce(channel_subst_name,'-1')<>'海珠分公司' then serv_id else null end) v6 
from tmp_yz_zxm_20251210_03 where subst_name='海珠分公司' and paixu=1 and kd_desc='普通宽带' 
group by channel_subtype_2011 ;

--20251211 核查202510-202511开机天数数据
--打标活跃,三维(主叫，短信，流量)
drop table if exists  zone_gz_yz.tmp_final_dwd_yz_cm_yx_hy1; 
create table zone_gz_yz.tmp_final_dwd_yz_cm_yx_hy1 as
select 
acc_nbr	
,calling_dur_m mou_call 
,total_float_amt_m stm_data
,sms_num_m mgs_counts
,case when (calling_dur_m+total_float_amt_m+sms_num_m) >= 30 then 1 else 0 end is_hy
from cdr.twevt_mobile_act_day
where etl_cycle_id='$sum_date'
;

--开机天数 打标 
DROP TABLE if exists  zone_gz_yz.tmp_final_dwd_yz_cm_yx_hy2; 
CREATE TABLE zone_gz_yz.tmp_final_dwd_yz_cm_yx_hy2 as
select 
serv_id,
(
 is_open_type_01+is_open_type_02+is_open_type_03+is_open_type_04+is_open_type_05
+is_open_type_06+is_open_type_07+is_open_type_08+is_open_type_09+is_open_type_10
+is_open_type_11+is_open_type_12+is_open_type_13+is_open_type_14+is_open_type_15
+is_open_type_16+is_open_type_17+is_open_type_18+is_open_type_19+is_open_type_20
+is_open_type_21+is_open_type_22+is_open_type_23+is_open_type_24+is_open_type_25
+is_open_type_26+is_open_type_27+is_open_type_28+is_open_type_29+is_open_type_30
+is_open_type_31
) kj_num
from summary_ods_tyks_city.tb_tyks_open_list_inc_d_mon 
where par_month_id='${sum_month}' 
and par_corp_id='200' 
and sum_date='${yyyymmdd}'
;

drop table tmp_yz_zjx_kjts_01 purge;
create table tmp_yz_zjx_kjts_01     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,yd_prod_type1,yd_prod_type2 
,count(case when kj_num>0 then serv_id else null end) kj 
,count(case when coalesce(kj_num,0)<=0 then serv_id else null end) non_kj 
from dwm_yz_tb_comm_cm_all_mon_final where is_new_user=1 and prod_type=30 
group by par_month_id,yd_prod_type1,yd_prod_type2 order by par_month_id,yd_prod_type1,yd_prod_type2 
;

drop table tmp_yz_zjx_kjts_02 purge;
create table tmp_yz_zjx_kjts_02     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,kj_num,serv_id,mou_call,channel_type_2011 
from dwm_yz_tb_comm_cm_all_mon_final a 
where is_new_user=1 and par_month_id>=202510 and par_month_id<=202511 and prod_type=30 
and yd_prod_type2='星卡' 
;

drop table tmp_yz_zjx_kjts_03 purge;
create table tmp_yz_zjx_kjts_03     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id 
from summary_ods_month_city.rpt_terminal_type_mon   --summary_ods_day_city.rpt_terminal_type/summary_ods_month_city.rpt_terminal_type_mon 终端注册信息表
where par_corp_id='200' and terminal_type is not null and terminal_type<>'' 
and par_month_id>=202510 and par_month_id<=202511 
group by par_month_id,serv_id 
;

drop table tmp_yz_zjx_kjts_04 purge;
create table tmp_yz_zjx_kjts_04     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.serv_id is not null then 1 else 0 end is_zd 
from tmp_yz_zjx_kjts_02 a 
left join tmp_yz_zjx_kjts_03 b 
on a.par_month_id=b.par_month_id and a.serv_id=b.serv_id 
;

--20251211 修复202511月全业务资料表开机数据
--备份
drop table dwm_yz_tb_comm_cm_all_mon_final_20251211_bf purge;
create table dwm_yz_tb_comm_cm_all_mon_final_20251211_bf     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from dwm_yz_tb_comm_cm_all_mon_final where par_month_id=202511;

--20251211 129+数据核查
select t.PAR_CORP_ID ,t.DAY_ID ,t.SUM_DATE ,t.CORP_ID 
,t.serv_id ,t.acc_nbr ,t.cust_id ,t.open_date 
,t.is_vice_card ,t.prod_id ,t.prod_type 
,t.divide_market_6 ,t.divide_market_6_dl_name 
,t.IS_ZQ ,t.IS_GZ ,t.subst_id ,t.branch_id 
,t.area_id ,t.new_mix_type_relat_id_old 
,t.new_mix_type_prod_old ,t.total_score_old 
,t.disc_total_score_old ,t.is_rh_129_old 
,t.rh_type_old ,t.disc_num_old ,t.disc_num_129_rh_old 
,t.disc_num_rh_old ,t.disc_num_dk_old ,t.disc_num_other_old 
,t.disc_kd_num ,t.disc_kd_cancel_num ,t.new_mix_type_relat_id 
,t.new_mix_type_prod ,t.total_score ,t.disc_total_score 
,t.is_rh_129 ,t.rh_type ,t.disc_num ,t.disc_num_129_rh 
,t.disc_num_rh ,t.disc_num_dk ,t.disc_num_other 
,t.disc_route_type ,t.disc_route_type_new 
,t.disc_route_subtype ,t.disc_cal_score_old_rn 
,t.disc_cal_score_rn 
from summary_jf_day_city.TB_TYKS_129RH_JZ_LIST_D t 
where t.PAR_CORP_ID='200' and t.DAY_ID='20251210'


select count(distinct case when disc_route_subtype = '升档' then new_mix_type_relat_id_old end) v1 
,sum(case when  dim_flag='D01' then ind_str_map['TYKSM20301457'] else 0 end) v2  
from summary_jf_day_city.TB_TYKS_M20301_LXX_D_NEW 
where sum_date = '20251210' and CORP_ID = '200' 

select sum_date,count(distinct case when disc_route_subtype = '升档' then new_mix_type_relat_id_old end) v1 
from summary_jf_day_city.TB_TYKS_129RH_JZ_LIST_D t 
where t.PAR_CORP_ID='200' and t.DAY_ID>='20251209' 
group by sum_date order by sum_date 

--20251216  南沙个性化更新202412月的region_tye，按网格打标
宽带新装清单 ads_yz_kd_new_list
1.备份202412,region_type
2.回溯202412月，关联

drop table ads_yz_kd_new_list_bak_20251216 purge;
create table ads_yz_kd_new_list_bak_20251216     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_new_list where par_month_id=202412;

drop table tmp_yz_kd_new_list_20251216 purge;
create table tmp_yz_kd_new_list_20251216     
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id,a.subs_code
,a.subs_stat_date,a.subst_id,a.subst_name,a.branch_id,a.branch_name
,a.area_id,a.area_name,a.grid_id,a.grid_code,a.grid_name
,case when b.flag=1 and c.index1 is null then b.region_type else a.region_type end region_type
,a.std_subst_id,a.std_subst_name,a.std_branch_id,a.std_branch_name
,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type
,a.is_mdz,a.six_market,a.serv_grp_type,a.sales_code,a.sales_name,a.channel_id
,a.channel_nbr,a.channel_name,a.channel_subst_name,a.channel_branch_name
,a.channel_area_name,a.channel_region_type,a.channel_type_2011
,a.channel_subtype_2011,a.channel_subtype0_2011,a.state,a.prod_id
,a.is_zhuanxian,a.kd_desc,a.prod_type3,a.prod_type2,a.itv_type
,a.kd_prod_offer_id,a.speed_value,a.jz_points,a.is_rh_ykj,a.rh_tc_value
,a.acc_nbr2,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name,a.cust_code
,a.ccust_name,a.ccust_org,a.is_gsm,a.serv_addr_id,a.serv_addr_name
,a.addr_id_7,a.open_date,a.is_sk_xjd,a.is_ljsp,a.is_yqjq,a.prod_name
,a.kd_prod_offer_code,a.kd_prod_offer_name,a.six_market_desc
,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx
,a.kuayv_offer_name,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd
,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1,a.xx_salestaff_code1
,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.ycx_offer_type,a.own_operators_nbr
,a.own_operators_name,a.is_zhuangwei,a.is_sheng_yx,a.cdma_disc_type3_name,a.label_name
,a.load_date,a.fk_lx,a.fk_value,a.kd_ll,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce
,a.seq_id,a.main_prod_offer_name,a.is_zxyb,a.is_lb_hy,a.addr_name_7
,a.cntrt_type_cbxl_name,a.kq_type,a.act_date,a.salestaff_subst_name
,a.salestaff_branch_name,a.fukuan_yd_acc,a.staff_id,a.staff_code
,a.sales_man_name,a.org_id,a.org_name,a.sys_post_name,a.rh_tc_value_bd
,a.par_month_id,a.par_sum_date 
from ads_yz_kd_new_list_bak_20251216 a
left join (select 1 flag,* from ads_yz_dim_ns_cell_ts) b 
on a.subst_id=b.subst_id and a.cell_code=b.cell_code 
left join zone_gz_yz_3351225714708480 c on a.cust_code=c.index1 
where a.par_month_id=202412
;

set hive.vectorized.execution.enabled=false;
alter table zone_gz_yz.ads_yz_kd_new_list drop partition(par_month_id='202412');
alter table zone_gz_yz.ads_yz_kd_new_list add partition(par_month_id='202412',par_sum_date='20241231');
insert into table zone_gz_yz.ads_yz_kd_new_list partition(par_month_id='202412',par_sum_date='20241231')
(sum_date,month_id,serv_id,acc_nbr,subs_id,
subs_code,subs_stat_date,subst_id,subst_name,branch_id,
branch_name,area_id,area_name,grid_id,grid_code,
grid_name,region_type,std_subst_id,std_subst_name,std_branch_id,
std_branch_name,cell_id,cell_code,cell_name,cell_type_name,
bg_type,bu_type,is_mdz,six_market,serv_grp_type,
sales_code,sales_name,channel_id,channel_nbr,channel_name,
channel_subst_name,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011,
channel_subtype_2011,channel_subtype0_2011,state,prod_id,is_zhuanxian,
kd_desc,prod_type3,prod_type2,itv_type,kd_prod_offer_id,
speed_value,jz_points,is_rh_ykj,rh_tc_value,acc_nbr2,
fttx_type,cust_id,cust_nbr,cust_name,cust_code,
ccust_name,ccust_org,is_gsm,serv_addr_id,serv_addr_name,
addr_id_7,open_date,is_sk_xjd,is_ljsp,is_yqjq,
prod_name,kd_prod_offer_code,kd_prod_offer_name,six_market_desc,serv_grp_type_desc,
channel_subtype_flag,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1,
xx_salestaff_code1,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,
ycx_offer_type,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,
cdma_disc_type3_name,label_name,fk_lx,fk_value,kd_ll,
kd_sc,is_hy,fee_shebei,fee_tiaoce,grid_unit_area_id,
mgr_area_id,is_shangqi_dx,kuayv_offer_name,load_date,seq_id,
main_prod_offer_name,is_zxyb,is_lb_hy,addr_name_7,cntrt_type_cbxl_name,
salestaff_subst_name,salestaff_branch_name,kq_type,act_date,fukuan_yd_acc,
staff_id,staff_code,sales_man_name,org_id,org_name,
sys_post_name,rh_tc_value_bd
)
select sum_date,month_id,serv_id,acc_nbr,subs_id,subs_code,subs_stat_date,subst_id,subst_name,branch_id,branch_name,area_id,area_name,grid_id,grid_code,grid_name,region_type,
std_subst_id,std_subst_name,std_branch_id,std_branch_name,cell_id,cell_code,cell_name,cell_type_name,bg_type,bu_type,is_mdz,six_market,serv_grp_type,sales_code,sales_name,
channel_id,channel_nbr,channel_name,channel_subst_name,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011,channel_subtype_2011,channel_subtype0_2011,
state,prod_id,is_zhuanxian,kd_desc,prod_type3,prod_type2,itv_type,kd_prod_offer_id,speed_value,jz_points,is_rh_ykj,rh_tc_value,acc_nbr2,fttx_type,cust_id,cust_nbr,cust_name,
cust_code,ccust_name,ccust_org,is_gsm,serv_addr_id,serv_addr_name,addr_id_7,open_date,is_sk_xjd,is_ljsp,is_yqjq,prod_name,kd_prod_offer_code,kd_prod_offer_name,six_market_desc,
serv_grp_type_desc,channel_subtype_flag,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1,xx_salestaff_code1,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,
ycx_offer_type,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,cdma_disc_type3_name,label_name,fk_lx,fk_value,kd_ll,kd_sc,is_hy,fee_shebei,fee_tiaoce,grid_unit_area_id,
mgr_area_id,is_shangqi_dx,kuayv_offer_name,current_timestamp() load_date,
seq_id,main_prod_offer_name,is_zxyb,is_lb_hy,addr_name_7,cntrt_type_cbxl_name,salestaff_subst_name,salestaff_branch_name
,kq_type,act_date,fukuan_yd_acc,staff_id,staff_code,sales_man_name,org_id,org_name,
sys_post_name,rh_tc_value_bd
from zone_gz_yz.tmp_yz_kd_new_list_20251216 a;


--20251230  XQGZ2025120500306 
--备份
drop table if exists  ads_yz_kd_new_list_bak_20251230 purge;
create table ads_yz_kd_new_list_bak_20251230  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select * from ads_yz_kd_new_list;

drop table if exists  ads_yz_XQGZ2025120500306_01 purge;
create table ads_yz_XQGZ2025120500306_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id,a.subs_code,a.subs_stat_date
,a.subst_id,a.subst_name,a.branch_id,a.branch_name,a.area_id,a.area_name,a.grid_id,a.grid_code
,a.grid_name,a.region_type,a.std_subst_id,a.std_subst_name,a.std_branch_id,a.std_branch_name
,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type,a.is_mdz,a.six_market
,a.serv_grp_type,a.sales_code,a.sales_name,a.channel_id,a.channel_nbr,a.channel_name,a.channel_subst_name
,a.channel_branch_name,a.channel_area_name,a.channel_region_type,a.channel_type_2011
,a.channel_subtype_2011,a.channel_subtype0_2011,a.state,a.prod_id,a.is_zhuanxian,a.kd_desc
,a.prod_type3,a.prod_type2,a.itv_type,a.kd_prod_offer_id,a.speed_value,a.jz_points,a.is_rh_ykj
,a.rh_tc_value,a.acc_nbr2,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name,a.cust_code,a.ccust_name
,a.ccust_org,a.is_gsm,a.serv_addr_id,a.serv_addr_name,a.addr_id_7,a.open_date,a.is_sk_xjd,a.is_ljsp
,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name,a.six_market_desc
,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx,a.kuayv_offer_name
,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.ycx_offer_type,a.own_operators_nbr,a.own_operators_name
,a.is_zhuangwei,a.is_sheng_yx,a.cdma_disc_type3_name,a.label_name,a.load_date,a.fk_lx
,a.fk_value,a.kd_ll,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce,a.seq_id,a.main_prod_offer_name
,a.is_zxyb,a.is_lb_hy,a.addr_name_7,a.cntrt_type_cbxl_name,a.kq_type,a.act_date
,a.salestaff_subst_name,a.salestaff_branch_name,a.fukuan_yd_acc,a.staff_id,a.staff_code
,a.sales_man_name,a.org_id,a.org_name,a.sys_post_name,a.rh_tc_value_bd,a.is_fttr,a.is_heyue
,a.is_ai,a.is_huoyue,a.acc_cly_zs,a.par_month_id,a.par_sum_date 

,b.is_yd_2_new_act,b.is_yd_last_hydy 
from ads_yz_kd_new_list a 
left join ads_yz_XQGZ2025120500306 b on a.par_month_id=b.par_month_id and a.serv_id=b.serv_id 
;

insert overwrite table ads_yz_kd_new_list 
select 
sum_date,month_id,serv_id,acc_nbr,subs_id,subs_code,subs_stat_date,subst_id,subst_name,branch_id
,branch_name,area_id,area_name,grid_id,grid_code,grid_name,region_type,std_subst_id,std_subst_name
,std_branch_id,std_branch_name,cell_id,cell_code,cell_name,cell_type_name,bg_type,bu_type,is_mdz
,six_market,serv_grp_type,sales_code,sales_name,channel_id,channel_nbr,channel_name,channel_subst_name
,channel_branch_name,channel_area_name,channel_region_type,channel_type_2011,channel_subtype_2011
,channel_subtype0_2011,state,prod_id,is_zhuanxian,kd_desc,prod_type3,prod_type2,itv_type
,kd_prod_offer_id,speed_value,jz_points,is_rh_ykj,rh_tc_value,acc_nbr2,fttx_type,cust_id
,cust_nbr,cust_name,cust_code,ccust_name,ccust_org,is_gsm,serv_addr_id,serv_addr_name
,addr_id_7,open_date,is_sk_xjd,is_ljsp,is_yqjq,prod_name,kd_prod_offer_code,kd_prod_offer_name
,six_market_desc,serv_grp_type_desc,channel_subtype_flag,is_shangqi_dx,kuayv_offer_name
,grid_unit_area_id,mgr_area_id,is_xjd,sales_id,rh_type_ykj,xx_salestaff_id1,xx_salestaff_code1
,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2,ycx_offer_type
,own_operators_nbr,own_operators_name,is_zhuangwei,is_sheng_yx,cdma_disc_type3_name
,label_name,load_date,fk_lx,fk_value,kd_ll,kd_sc,is_hy,fee_shebei,fee_tiaoce,seq_id
,main_prod_offer_name,is_zxyb,is_lb_hy,addr_name_7,cntrt_type_cbxl_name,kq_type,act_date
,salestaff_subst_name,salestaff_branch_name,fukuan_yd_acc,staff_id,staff_code,sales_man_name
,org_id,org_name,sys_post_name,rh_tc_value_bd,is_fttr,is_heyue,is_ai,is_huoyue,acc_cly_zs
,is_yd_2_new_act,is_yd_last_hydy
,cast(null as decimal(22,2)) rh_tc_value_bd_1
,par_month_id,par_sum_date 
from ads_yz_XQGZ2025120500306_01;

--修改短信接收人
【流程】dwm_ds
新增值班短信接收人,新增单个
ads_dim_iap_oc_sms_result_dx_cs
ads_dim_iap_oc_sms_result_dx_zs
--正式短信
create table ads_dim_iap_oc_sms_result_dx_zs_list as 
select * from ads_dim_iap_oc_sms_result_dx_zs
union all 
select '17728067753','陈义翔','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0'
union all 
select '19002025068	','陆婧','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0'
union all 
select '19002025026','林玄昊','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0';

alter table ads_dim_iap_oc_sms_result_dx_zs rename to ads_dim_iap_oc_sms_result_dx_zs_bf_20260105;
alter table ads_dim_iap_oc_sms_result_dx_zs_list rename to ads_dim_iap_oc_sms_result_dx_zs;

--测试短信
create table ads_dim_iap_oc_sms_result_dx_cs_list as 
select * from ads_dim_iap_oc_sms_result_dx_cs
union all 
select '17728067753','陈义翔','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0'
union all 
select '19002025068	','陆婧','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0'
union all 
select '19002025026','林玄昊','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0';

alter table ads_dim_iap_oc_sms_result_dx_cs rename to ads_dim_iap_oc_sms_result_dx_cs_bf_20260105;
alter table ads_dim_iap_oc_sms_result_dx_cs_list rename to ads_dim_iap_oc_sms_result_dx_cs;

--20260113  XQGZ2025112602246   陈冠文  关于提取IPTV入网、保有数据的需求 
drop table if exists  tmp_yz_XQGZ2025112602246_01 purge;
create table tmp_yz_XQGZ2025112602246_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select cast(cast(open_date as int)/100 as int) month_id,serv_id 
from summary_ods_tyks_city.tb_tyks_ywl_list_inc_day
where open_date>='20230101'
and open_date<='20251231'
and prod_type=50 and par_corp_id='200'; 

drop table if exists  tmp_yz_XQGZ2025112602246_02 purge;
create table tmp_yz_XQGZ2025112602246_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,serv_id,rh_tc_id 
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202301 and par_month_id<=202512 
and prod_type2=50 and is_rh_ykj=1 and rh_type_ykj='新宽带新移动' 
;

--是否新宽新移
drop table if exists  tmp_yz_XQGZ2025112602246_03 purge;
create table tmp_yz_XQGZ2025112602246_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when b.serv_id is not null then 1 else 0 end is_xkxy 
from tmp_yz_XQGZ2025112602246_01 a 
left join tmp_yz_XQGZ2025112602246_02 b on a.serv_id=b.serv_id and a.month_id=cast(b.par_month_id as int) 
;

--政企团购
-- offer_id	prod_offer_code
-- 9178	TY350
-- 100054915	DM0001-660-1-2

--酒宽
-- offer_id	prod_offer_code
-- 500016157	DM0001-536-1-7
-- 500045005	YD0001-B59-1-4
-- 500057178	YD0001-B59-1-5
-- 500058180	YD0001-B59-1-6
-- 100055925	DM0001-303-1-2
-- 100055994	DM0001-660-1-4
-- 100087486	DM0001-526-1-7
-- 500016156	DM0001-536-1-6
-- 500016155	DM0001-536-1-5
-- 500016151	DM0001-536-1-1
-- 500058381	DM0001-848-1-1
-- 100055924	DM0001-303-1-1
-- 500045003	YD0001-B59-1-2
-- 500069046	DM0001-848-1-2

drop table if exists  tmp_yz_XQGZ2025112602246_04 purge;
create table tmp_yz_XQGZ2025112602246_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.serv_id,a.prod_offer_id,date_format(a.subs_stat_date,'yyyyMM') as month_id  
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where a.par_month_id between 202301 and 202512 and  a.subs_stat = '301200' 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')
and date_format(a.subs_stat_date,'yyyyMM') >= '202301' 
and date_format(a.subs_stat_date,'yyyyMM') <= '202512'
and a.action_id in( 1292,6200 )
and a.prod_offer_id in(9178,100054915,

500016157,500045005,500057178,500058180,100055925,100055994,100087486,500016156,500016155
,500016151,500058381,100055924,500045003,500069046) 
;

drop table if exists  tmp_yz_XQGZ2025112602246_05 purge;
create table tmp_yz_XQGZ2025112602246_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when b.serv_id is not null then 1 else 0 end is_zqtg 
from tmp_yz_XQGZ2025112602246_03 a 
left join (select serv_id,month_id from tmp_yz_XQGZ2025112602246_04 where prod_offer_id in(9178,100054915) group by serv_id,month_id) b 
on a.month_id=cast(b.month_id as int) and a.serv_id=b.serv_id 
;

drop table if exists  tmp_yz_XQGZ2025112602246_06 purge;
create table tmp_yz_XQGZ2025112602246_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when b.serv_id is not null then 1 else 0 end is_jdkd  
from tmp_yz_XQGZ2025112602246_05 a 
left join (select serv_id,month_id from tmp_yz_XQGZ2025112602246_04 where prod_offer_id in(500016157,500045005,500057178,500058180,100055925,100055994,100087486,500016156,500016155
,500016151,500058381,100055924,500045003,500069046) group by serv_id,month_id) b 
on a.month_id=cast(b.month_id as int) and a.serv_id=b.serv_id 
;

select month_id 
,count( serv_id) v1 
,count( case when is_xkxy=1 then serv_id else null end) v2 
,count( case when is_zqtg=1 then serv_id else null end) v3 
,count( case when is_jdkd=1 then serv_id else null end) v4 
from tmp_yz_XQGZ2025112602246_06 group by month_id order by month_id 

--20260120  张香宁  
select distinct offer_id,prod_offer_code 
from dws_crm_cfguse.dws_offer 
where city_id=200 
and offer_id in(500051335,500058418,500062182,500046076,500046079,500052184)

select acc_nbr,prod_offer_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200'
and prod_offer_id in(500051335) 
and date_format(limit_date,'yyyyMMdd') > '20260119' limit 1 
union all 
select acc_nbr,prod_offer_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200'
and prod_offer_id in(500058418) 
and date_format(limit_date,'yyyyMMdd') > '20260119' limit 1 
union all 
select acc_nbr,prod_offer_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200'
and prod_offer_id in(500062182) 
and date_format(limit_date,'yyyyMMdd') > '20260119' limit 1 
union all 
select acc_nbr,prod_offer_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200'
and prod_offer_id in(500046076) 
and date_format(limit_date,'yyyyMMdd') > '20260119' limit 1 
union all 
select acc_nbr,prod_offer_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200'
and prod_offer_id in(500046079) 
and date_format(limit_date,'yyyyMMdd') > '20260119' limit 1 
union all 
select acc_nbr,prod_offer_id 
from zone_gz_yz.dwd_yz_rpt_comm_cm_msdisc_final a 
where par_corp_id='200'
and prod_offer_id in(500052184) 
and date_format(limit_date,'yyyyMMdd') > '20260119' limit 1 

--20260123  董永建  XQGZ2026012301618
drop table if exists  tmp_yz_XQGZ2026012301618_01 purge;
create table tmp_yz_XQGZ2026012301618_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.index1 suhao,a.index2 acc_nbr 
,case when b.stop_date is not null then b.stop_date else null end as state_date 
,case when b.serv_id is not null then c.attr_value_name else '拆机' end as state_desc
from zone_gz_yz_3351225714708480 a 
left join dwm_yz_tb_comm_cm_all_final b on a.index2=b.acc_nbr and b.par_month_id=202601 and b.is_cancel_user=0 
left join dws_crm_cfguse.dws_attr_value c on b.state=c.attr_value and c.city_id='200' and c.attr_id='4000000201' 
;

drop table if exists  tmp_yz_XQGZ2026012301618_02 purge;
create table tmp_yz_XQGZ2026012301618_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.acc_nbr,a.wl_cancel_subs_stat_date 
,row_number() over(partition by acc_nbr order by wl_cancel_subs_stat_date desc) paixu  
from dwm_yz_tb_comm_cm_all_mon_final a 
where is_cancel_user=1 ;

drop table if exists  tmp_yz_XQGZ2026012301618_03 purge;
create table tmp_yz_XQGZ2026012301618_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.suhao,a.acc_nbr,a.state_desc
,case when b.acc_nbr is not null and a.state_date is null then b.wl_cancel_subs_stat_date else a.state_date end state_date 
from tmp_yz_XQGZ2026012301618_01 a 
left join tmp_yz_XQGZ2026012301618_02 b on a.acc_nbr=b.acc_nbr and b.paixu=1 
;

drop table if exists  tmp_yz_XQGZ2026012301618_04 purge;
create table tmp_yz_XQGZ2026012301618_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.par_month_id 
,b.sh_qr  
from tmp_yz_XQGZ2026012301618_03 a 
left join (select par_month_id,acc_nbr, 
		sum(a0) as sh_qr --税后确认收入
		from dwm_srhx_serv_list_mon_final
		where par_month_id>=202501 and par_month_id<=202512 
		group by par_month_id,acc_nbr) b 
on a.acc_nbr=b.acc_nbr 
;

--20260203  张晓明
drop table if exists  tmp_yz_zxm_data_01 purge;
create table tmp_yz_zxm_data_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select branch_name,par_month_id,cell_code,cell_name,serv_id,kd_desc,is_cancel_user 
,is_new_user,is_rh_ykj,channel_branch_name,prod_type,prod_type2 
,rh_type_ykj,rh_tc_value,is_wl_cancel_user,is_cz,is_cz_last  
from dwm_yz_tb_comm_cm_all_mon_final a 
where a.par_month_id>=202401 and par_month_id<=202512 
and branch_name='白云永平社区营销服务中心' ;

drop table if exists  tmp_yz_zxm_data_03 purge;
create table tmp_yz_zxm_data_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select branch_name,cell_name,cell_code,par_month_id 
,count(case when is_new_user=1 and kd_desc='普通宽带' then serv_id else null end) as v1 
,count(case when is_new_user=1 and channel_branch_name='白云永平社区营销服务中心' and kd_desc='普通宽带' then serv_id else null end) as v2 

,count(case when is_new_user=1 and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v3
,count(case when is_new_user=1 and channel_branch_name='白云永平社区营销服务中心' and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v4

,count(case when is_new_user=1 and rh_type_ykj='新宽带新移动' and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v5
,count(case when is_new_user=1 and channel_branch_name='白云永平社区营销服务中心' and rh_type_ykj='新宽带新移动' and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v6 

,count(case when is_new_user=1 and rh_tc_value>=129 and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v7
,count(case when is_new_user=1 and channel_branch_name='白云永平社区营销服务中心' and rh_tc_value>=129 and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v8

,count(case when is_new_user=1 and rh_tc_value>=199 and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v9
,count(case when is_new_user=1 and channel_branch_name='白云永平社区营销服务中心' and rh_tc_value>=199 and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v10

,count(case when is_new_user=1 and rh_tc_value>=299 and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v11
,count(case when is_new_user=1 and channel_branch_name='白云永平社区营销服务中心' and rh_tc_value>=299 and is_rh_ykj=1 and prod_type=40 and coalesce(prod_type2,-1)<>50 then serv_id else null end) as v12 

--销户=wlcj+fzj+jzf （fzj是负数）
,sum(case when is_cz_last=1 and is_wl_cancel_user=1 then 1 else 0 end) v14 --物理拆机
,sum(case when is_cz_last=1 and is_cancel_user=0 and is_cz=0 then 1 else 0 end) v15 --计转非
,sum(case when is_cz_last=0 and is_cancel_user=0 and is_new_user=0 and is_cz=1 then -1 else 0 end) v16 --非转计

,count(case when prod_type=40 and is_cz=1 then serv_id else null end) as v17 
from tmp_yz_zxm_data_01 where kd_desc='普通宽带' 
group by branch_name,cell_name,cell_code,par_month_id;

--20260206  XQGZ2026020502124	需求标题	申请提取提供清单的客户名对应的产权编码和直销编码
drop table if exists  tmp_yz_XQGZ2026020502124_01 purge;
create table tmp_yz_XQGZ2026020502124_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select cust_number,cust_name,create_date
,row_number() over(partition by cust_number,cust_name order by create_date desc) paixu 
from dws_crm_cust.dws_customer where city_id=200;

drop table if exists  tmp_yz_XQGZ2026020502124_02 purge;
create table tmp_yz_XQGZ2026020502124_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select index1 as cust_name,index2 as xhao,b.cust_number  
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_XQGZ2026020502124_01 b on a.index1=b.cust_name and b.paixu=1 
;

drop table if exists  tmp_yz_XQGZ2026020502124_03 purge;
create table tmp_yz_XQGZ2026020502124_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.ccust_code 
from tmp_yz_XQGZ2026020502124_02 a 
left join (select distinct cust_nbr,ccust_code from dws_yz_tb_mo_custgrp_cust_final) b on a.cust_number=b.cust_nbr 
;

drop table if exists  tmp_yz_XQGZ2026020502124_fwzq purge;
create table tmp_yz_XQGZ2026020502124_fwzq   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 200 city_id,a.xhao,a.cust_number,a.ccust_code 
from tmp_yz_XQGZ2026020502124_03 a ;


--修改短信接收人
【流程】dwm_ds
修改正式短信接收人,新增单个
create table ads_dim_iap_oc_sms_result_dx_zs_list as 
select * from ads_dim_iap_oc_sms_result_dx_zs where coalesce(name,'-1') not in('沈波','陈国栋','吴远珉') 
union all 
select '18922166503','陈鸿斌','zone_gz_yz_3djj82s75ucc','zone_gz_yz_3dkohhu756o0';

alter table ads_dim_iap_oc_sms_result_dx_zs rename to ads_dim_iap_oc_sms_result_dx_zs_bf_20260210;
alter table ads_dim_iap_oc_sms_result_dx_zs_list rename to ads_dim_iap_oc_sms_result_dx_zs;


create table ads_dim_iap_oc_sms_result_dx_cs_list as 
select * from ads_dim_iap_oc_sms_result_dx_cs where coalesce(name,'-1') not in('吴远珉') 
;

alter table ads_dim_iap_oc_sms_result_dx_cs rename to ads_dim_iap_oc_sms_result_dx_cs_bf_20260210;
alter table ads_dim_iap_oc_sms_result_dx_cs_list rename to ads_dim_iap_oc_sms_result_dx_cs;

--20260302  XQGZ2026013001803 需求标题 广州祈信金属制品有限公司864个号码打标高套申请 
--酒宽高套  手工数配置
--1) 酒宽(分局)
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
drop table tmp_dwd_yz_531prod_new_sum_m_yy purge;
create table tmp_dwd_yz_531prod_new_sum_m_yy as 
select month_id,tc_flag,flag_desc,prod_flag,channel_type,branch_type 
,subst_name,branch_name,area_name,area_type,salestaff_code,salestaff_name 
,serv_cn,serv_cn_last,jf_cn,jf_cn_last,serv_zs_cn,serv_zs_cn_last,load_date 
,serv_cn_last2,jf_cn_last2,serv_zs_cn_last2,max_stat_time,sum_date,prod_flag_id 
from dwd_yz_531prod_new_sum 
where prod_flag_id='jdkd' and sum_date=20260131 and coalesce(subst_name,'-1')<>'南沙分公司' 
union all 
select cast(index1 as string) month_id,
cast(index2 as string) tc_flag,
cast(index3 as string) flag_desc,
cast(index4 as string) prod_flag,
cast(null as string) channel_type,
cast(null as string) branch_type,
cast(index7 as string) subst_name,
cast(null as string) branch_name,
cast(null as string) area_name,
cast(null as string) area_type,
cast(null as string) salestaff_code,
cast(null as string) salestaff_name,
cast(index13 as int) serv_cn,
cast(index14 as int) serv_cn_last,
cast(index15 as decimal(24,2)) jf_cn,
cast(index16 as decimal(24,2)) jf_cn_last,
cast(index17 as decimal(24,4)) serv_zs_cn,
cast(index18 as decimal(24,4)) serv_zs_cn_last,
current_timestamp() load_date,
cast(null as int) serv_cn_last2,
cast(null as decimal(24,2)) jf_cn_last2,
cast(null as decimal(24,4)) serv_zs_cn_last2,
cast(null as string) max_stat_time,
cast(index24 as string) sum_date,
cast(index25 as string) prod_flag_id 
from zone_gz_yz_3351225714708480 where index4='酒店宽带(分局)';


alter table dwd_yz_531prod_new_sum drop if exists partition(prod_flag_id='jdkd',sum_date=20260131);
insert into table dwd_yz_531prod_new_sum partition(prod_flag_id='jdkd',sum_date=20260131)
(prod_flag,month_id,tc_flag,flag_desc,channel_type,subst_name,branch_name,area_name,area_type,serv_cn,serv_cn_last,jf_cn,jf_cn_last
,serv_zs_cn,serv_zs_cn_last,load_date,salestaff_code,salestaff_name,branch_type)
select 
prod_flag,month_id,tc_flag,flag_desc,channel_type,subst_name,branch_name,area_name,area_type,serv_cn,serv_cn_last,jf_cn,jf_cn_last
,serv_zs_cn,serv_zs_cn_last,load_date,salestaff_code,salestaff_name,branch_type 
from  tmp_dwd_yz_531prod_new_sum_m_yy where prod_flag in('酒店宽带(分局)') 
; 

--2) 酒宽(营服)
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
drop table tmp_dwd_yz_531prod_new_sum_m_branch purge;
create table tmp_dwd_yz_531prod_new_sum_m_branch as 
select month_id,tc_flag,flag_desc,prod_flag,channel_type,branch_type 
,subst_name,branch_name,area_name,area_type,salestaff_code,salestaff_name 
,serv_cn,serv_cn_last,jf_cn,jf_cn_last,serv_zs_cn,serv_zs_cn_last,load_date 
,serv_cn_last2,jf_cn_last2,serv_zs_cn_last2,max_stat_time,sum_date,prod_flag_id 
from dwd_yz_531prod_new_sum 
where prod_flag_id='jdkd_branch' and sum_date=20260131 
and coalesce(branch_name,'-1')<>'南沙东涌政商营销服务中心'
union all 
select cast(index1 as string) month_id,
cast(index2 as string) tc_flag,
cast(index3 as string) flag_desc,
cast(index4 as string) prod_flag,
cast(null as string) channel_type,
cast(index6 as string) branch_type,
cast(index7 as string) subst_name,
cast(index8 as string) branch_name,
cast(null as string) area_name,
cast(null as string) area_type,
cast(null as string) salestaff_code,
cast(null as string) salestaff_name,
cast(index13 as int) serv_cn,
cast(index14 as int) serv_cn_last,
cast(index15 as decimal(24,2)) jf_cn,
cast(index16 as decimal(24,2)) jf_cn_last,
cast(index17 as decimal(24,4)) serv_zs_cn,
cast(index18 as decimal(24,4)) serv_zs_cn_last,
current_timestamp() load_date,
cast(null as int) serv_cn_last2,
cast(null as decimal(24,2)) jf_cn_last2,
cast(null as decimal(24,4)) serv_zs_cn_last2,
cast(null as string) max_stat_time,
cast(index24 as string) sum_date,
cast(index25 as string) prod_flag_id 
from zone_gz_yz_3351225714708480 where index4='酒店宽带(营服)';

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
alter table dwd_yz_531prod_new_sum drop if exists partition(prod_flag_id='jdkd_branch',sum_date=20260131);
insert into table dwd_yz_531prod_new_sum partition(prod_flag_id='jdkd_branch',sum_date=20260131)
(prod_flag,month_id,tc_flag,flag_desc,channel_type,subst_name,branch_name,area_name,area_type,serv_cn,serv_cn_last,jf_cn,jf_cn_last
,serv_zs_cn,serv_zs_cn_last,load_date,salestaff_code,salestaff_name,branch_type)
select 
prod_flag,month_id,tc_flag,flag_desc,channel_type,subst_name,branch_name,area_name,area_type,serv_cn,serv_cn_last,jf_cn,jf_cn_last
,serv_zs_cn,serv_zs_cn_last,load_date,salestaff_code,salestaff_name,branch_type 
from  tmp_dwd_yz_531prod_new_sum_m_branch where prod_flag in('酒店宽带(营服)') 
; 

--3) 酒宽(周更新)
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
drop table tmp_dwd_yz_531prod_new_sum_w purge;
create table tmp_dwd_yz_531prod_new_sum_w as 
select month_id,tc_flag,flag_desc,prod_flag,channel_type,branch_type 
,subst_name,branch_name,area_name,area_type,salestaff_code,salestaff_name 
,serv_cn,serv_cn_last,jf_cn,jf_cn_last,serv_zs_cn,serv_zs_cn_last,load_date 
,serv_cn_last2,jf_cn_last2,serv_zs_cn_last2,max_stat_time,sum_date,prod_flag_id 
from dwd_yz_531prod_new_sum 
where prod_flag_id='jdkd_w' and sum_date=20260131 
and coalesce(subst_name,'-1')<>'南沙分公司' 
union all 
select cast(index1 as string) month_id,
cast(index2 as string) tc_flag,
cast(index3 as string) flag_desc,
cast(index4 as string) prod_flag,
cast(null as string) channel_type,
cast(null as string) branch_type,
cast(index7 as string) subst_name,
cast(null as string) branch_name,
cast(null as string) area_name,
cast(null as string) area_type,
cast(null as string) salestaff_code,
cast(null as string) salestaff_name,
cast(index13 as int) serv_cn,
cast(index14 as int) serv_cn_last,
cast(index15 as decimal(24,2)) jf_cn,
cast(index16 as decimal(24,2)) jf_cn_last,
cast(index17 as decimal(24,4)) serv_zs_cn,
cast(index18 as decimal(24,4)) serv_zs_cn_last,
current_timestamp() load_date,
cast(null as int) serv_cn_last2,
cast(null as decimal(24,2)) jf_cn_last2,
cast(null as decimal(24,4)) serv_zs_cn_last2,
cast(null as string) max_stat_time,
cast(index24 as string) sum_date,
cast(index25 as string) prod_flag_id 
from zone_gz_yz_3351225714708480 where index4='酒宽(周更新)';

alter table dwd_yz_531prod_new_sum drop if exists partition(prod_flag_id='jdkd_w',sum_date=20260131);
insert into table dwd_yz_531prod_new_sum partition(prod_flag_id='jdkd_w',sum_date=20260131)

(prod_flag,month_id,tc_flag,flag_desc,channel_type,subst_name,branch_name,area_name,area_type,serv_cn,serv_cn_last,jf_cn,jf_cn_last
,serv_zs_cn,serv_zs_cn_last,load_date,salestaff_code,salestaff_name,branch_type)

select 
prod_flag,month_id,tc_flag,flag_desc,channel_type,subst_name,branch_name,area_name,area_type,serv_cn,serv_cn_last,jf_cn,jf_cn_last
,serv_zs_cn,serv_zs_cn_last,load_date,salestaff_code,salestaff_name,branch_type
from  tmp_dwd_yz_531prod_new_sum_w where prod_flag in('酒宽(周更新)')
;

--20260311 2025年电信用户指标
SELECT par_month_id,
  subst_name,
  count(
    CASE
      WHEN prod_type = 10 THEN serv_id
      ELSE NULL
    END
  ) AS gh,
  count(
    CASE
      WHEN prod_type = 30 THEN serv_id
      ELSE NULL
    END
  ) AS yd_zw,
    count(
    CASE
      WHEN prod_type = 30 and is_cz=1 THEN serv_id
      ELSE NULL
    END
  ) AS yd_cz,
  count(
    CASE
      WHEN prod_type = 40 THEN serv_id
      ELSE NULL
    END
  ) AS kd
FROM
  dwm_yz_tb_comm_cm_all_mon_final
WHERE
  par_month_id in(202512)
  AND is_cancel_user = 0
GROUP BY
  par_month_id,subst_name
LIMIT
  1000
  
--20260311  XQGZ2026030600571 需求标题 关于名单制产权编码提取收入的需求  
5A：25年累计收入≥300万以上
4A：25年累计收入＜300万，≥100万
3A：25年累计收入＜100万，≥50万
2A：25年累计收入＜50万，≥12万
1A：25年累计收入＜12万，≥3.6万
5B：25年累计收入＜3.6万，≥1万
4B：25年累计收入＜1万
drop table if exists tmp_yz_XQGZ2026030600571_01;
create table tmp_yz_XQGZ2026030600571_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_nbr,ccust_code
from dws_yz_tb_mo_custgrp_cust_final a 
left join zone_gz_yz_3351225714708480 b on a.ccust_code=b.index1 
where b.index1 is not null 
group by cust_nbr,ccust_code
;

drop table if exists tmp_yz_XQGZ2026030600571_02;
create table tmp_yz_XQGZ2026030600571_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cust_nbr, 
sum(a0) as sh_qr --税后确认收入
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id>=202501 and par_month_id<=202512 
group by cust_nbr
;

drop table if exists tmp_yz_XQGZ2026030600571_03;
create table tmp_yz_XQGZ2026030600571_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.sh_qr 
from tmp_yz_XQGZ2026030600571_01 a 
left join tmp_yz_XQGZ2026030600571_02 b on a.cust_nbr=b.cust_nbr 
;

drop table if exists tmp_yz_XQGZ2026030600571_04;
create table tmp_yz_XQGZ2026030600571_04 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select ccust_code,coalesce(sum(sh_qr),0) sr_2025 from tmp_yz_XQGZ2026030600571_03 group by ccust_code;

-- 5A：25年累计收入≥300万以上
-- 4A：25年累计收入＜300万，≥100万
-- 3A：25年累计收入＜100万，≥50万
-- 2A：25年累计收入＜50万，≥12万
-- 1A：25年累计收入＜12万，≥3.6万
-- 5B：25年累计收入＜3.6万，≥1万
-- 4B：25年累计收入＜1万
drop table if exists tmp_yz_XQGZ2026030600571_05;
create table tmp_yz_XQGZ2026030600571_05 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when cast(sr_2025/10000 as decimal(22,4))>=300 then '5A' 
	  when cast(sr_2025/10000 as decimal(22,4))>=100 and cast(sr_2025/10000 as decimal(22,4))<300 then '4A' 
	  when cast(sr_2025/10000 as decimal(22,4))>=50 and cast(sr_2025/10000 as decimal(22,4))<100 then '3A' 
	  when cast(sr_2025/10000 as decimal(22,4))>=12 and cast(sr_2025/10000 as decimal(22,4))<50 then '2A' 
	  when cast(sr_2025/10000 as decimal(22,4))>=3.6 and cast(sr_2025/10000 as decimal(22,4))<12 then '1A' 
	  when cast(sr_2025/10000 as decimal(22,4))>=1 and cast(sr_2025/10000 as decimal(22,4))<3.6 then '5B' 
	  when cast(sr_2025/10000 as decimal(22,4))<1 then '4B' else null end flag_5a5b 
from tmp_yz_XQGZ2026030600571_04 a 
;

drop table if exists ads_yz_XQGZ2026030600571_list;
create table ads_yz_XQGZ2026030600571_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1 cust_code,case when b.ccust_code is not null then b.flag_5a5b else '4B' end item_5a5b 
from zone_gz_yz_3351225714708480 a 
left join tmp_yz_XQGZ2026030600571_05 b on a.index1=b.ccust_code 
;

--20260326 
create table ads_yz_jzjf_sms_bao_bak_20260326 as select * from ads_yz_jzjf_sms_bao;
create table ads_yz_jzjf_sms_bao_bak_20260326 as select * from ads_yz_jzjf_sms_bao;
create table ads_yz_jzjf_sms_content_bak_20260326 as select * from ads_yz_jzjf_sms_content;
create table ads_yz_sms_bao_bak_20260326 as select * from ads_yz_sms_bao;
create table ads_yz_sms_content_bak_20260326 as select * from ads_yz_sms_content;
create table ads_yz_sms_2_bao_bak_20260326 as select * from ads_yz_sms_2_bao;
create table ads_yz_sms_2_content_bak_20260326 as select * from ads_yz_sms_2_content;
create table ads_yz_sms_fttr_content_N_bak_20260326 as select * from ads_yz_sms_fttr_content_N;
create table ads_yz_sms_yzm_dd_content_union_bak_20260326 as select * from ads_yz_sms_yzm_dd_content_union;

--20260330  全业务资料表回溯数据核查
select par_month_id,count(1) from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20260326  group by par_month_id order by par_month_id LIMIT 1000
SELECT par_month_id,count(1) FROM dwm_yz_tb_comm_cm_all_mon_final  group by par_month_id order by par_month_id LIMIT 1000
核对结果：数据量一致，核查通过

drop table tmp_yz_liq_02 purge;
create table tmp_yz_liq_02 as 
SELECT par_month_id,is_cancel_user, subst_name, count(1) 
,row_number() over(order by count(1)) as paixu 
FROM dwm_yz_tb_comm_cm_all_mon_final 
GROUP BY par_month_id,is_cancel_user, subst_name 
ORDER BY par_month_id,is_cancel_user, subst_name;

drop table tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 as 
SELECT par_month_id,is_cancel_user, subst_name, count(1) 
,row_number() over(order by count(1)) as paixu
FROM ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20260326 
GROUP BY par_month_id,is_cancel_user, subst_name 
ORDER BY par_month_id,is_cancel_user, subst_name ;
核对结果：局向的增减总和为0，核查通过

--核查回溯表和基准表的号码标签是否一致
drop table tmp_yz_liq_03 purge;
create table tmp_yz_liq_03 as 
select a.par_month_id,count(1) from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20260326 a 
join ads_yz_ndhs_all_202603_jz_list_final b on a.serv_id=b.serv_id and (
coalesce(a.subst_id,'-99')<>coalesce(b.subst_id,'-99')
or coalesce(a.branch_id,'-99')<>coalesce(b.branch_id,'-99')
or coalesce(a.grid_id,'-99')<>coalesce(b.grid_id,'-99')
or coalesce(a.grid_code,'-99')<>coalesce(b.grid_code,'-99')
or coalesce(a.area_id,'-99')<>coalesce(b.area_id,'-99')

or coalesce(a.std_subst_id,'-99')<>coalesce(b.std_subst_id,'-99')
or coalesce(a.std_branch_id,'-99')<>coalesce(b.std_branch_id,'-99')
or coalesce(a.cell_id,'-99')<>coalesce(b.cell_id,'-99')
or coalesce(a.cell_code,'-99')<>coalesce(b.cell_code,'-99')
or coalesce(a.ccenter,'-99')<>coalesce(b.ccenter,'-99')

or coalesce(a.subst_name,'-99')<>coalesce(b.subst_name,'-99')
or coalesce(a.branch_name,'-99')<>coalesce(b.branch_name,'-99')
or coalesce(a.grid_name,'-99')<>coalesce(b.grid_name,'-99')
or coalesce(a.region_type,'-99')<>coalesce(b.region_type,'-99')

or coalesce(a.is_mdz,'-99')<>coalesce(b.is_mdz,'-99')
or coalesce(a.bg_type,'-99')<>coalesce(b.bg_type,'-99')
or coalesce(a.bu_type,'-99')<>coalesce(b.bu_type,'-99')
or coalesce(a.cell_name,'-99')<>coalesce(b.cell_name,'-99')

or coalesce(a.std_subst_name,'-99')<>coalesce(b.std_subst_name,'-99')
or coalesce(a.std_branch_name,'-99')<>coalesce(b.std_branch_name,'-99')
or coalesce(a.area_name,'-99')<>coalesce(b.area_name,'-99')

or coalesce(a.cell_type,'-99')<>coalesce(b.cell_type,'-99')
or coalesce(a.cell_type_name,'-99')<>coalesce(b.cell_type_name,'-99')

or coalesce(a.null_column12,'-99')<>coalesce(b.hk_flag,'-99')
--null_column11、null_column12
)
group by a.par_month_id order by a.par_month_id;
202501月之后的号码标签信息一致，核查通过


--核查不在基准表的号码量，差异很小才正常
drop table tmp_yz_liq_04 purge;
create table tmp_yz_liq_04 as 
select a.par_month_id,count(1),count(case when b.serv_id is not null then 1 else null end )
from ads_huisu_dwm_yz_tb_comm_cm_all_mon_final_ndhs_20260326 a
left join ads_yz_ndhs_all_202603_jz_list_final b
on a.serv_id=b.serv_id
--where a.grid_id<>-1
group by a.par_month_id order by a.par_month_id;
核查通过

--20260402  年度回溯备份
宽带续约
create table ads_yz_kd_xy_pz_ndhs_bf_202603 as select * from ads_yz_kd_xy_pz;
create table ads_yz_kd_xy_list_have_jk_ndhs_bf_202603 as select * from ads_yz_kd_xy_list_have_jk;
create table ads_yz_kd_xy_list_ndhs_bf_202603 as select * from ads_yz_kd_xy_list;
create table ads_yz_kd_xy_list_pz_ndhs_bf_202603 as select * from ads_yz_kd_xy_list_pz;
宽带新装
alter table ads_yz_kd_new_list rename to ads_yz_kd_new_list_ndhs_bf_202603;
alter table ads_yz_kd_new_list_huisu_20260401 rename to ads_yz_kd_new_list;

--20260417  李宜倍
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
SELECT a.serv_id,b.payment_id,a.par_month_id, a.flag,a.fee_all   
FROM dwm_srhx_src_income_list_mon a 
join dwm_bu_dy_pz_2022 b on a.serv_id=b.serv_id 
WHERE a.par_month_id >= 202601 and a.par_month_id <= 202603 AND a.contract_flag = '1' AND a.is_filter = '0' -- and a.flag in (1,2,3,4) 
AND a.data_src_type = 600 AND a.col_income_name = '银行质押' 
;

drop table if exists tmp_yz_liq_02 purge;
create table tmp_yz_liq_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.channel_type_2011,b.channel_subtype_2011,date_format(open_date,'yyyy') rw_year  
from tmp_yz_liq_01 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and a.par_month_id=b.par_month_id 
;

drop table if exists tmp_yz_liq_03 purge;
create table tmp_yz_liq_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
SELECT a.channel_type_2011,a.channel_subtype_2011,a.rw_year
,a.payment_id,a.par_month_id, a.flag, CAST(sum(fee_all) AS decimal(22, 2)) sr  
FROM tmp_yz_liq_02 a 
GROUP BY a.channel_type_2011,a.channel_subtype_2011,a.rw_year,a.payment_id,a.par_month_id, a.flag 
;


--20260424  李宜倍
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
SELECT a.subst_name,b.payment_id,a.par_month_id, a.flag, CAST(sum(a.fee_all) AS decimal(22, 2)) sr  
FROM dwm_srhx_src_income_list_mon a 
join dwm_bu_dy_pz_2022 b on a.serv_id=b.serv_id 
WHERE a.par_month_id >= 202601 and a.par_month_id <= 202603 AND a.contract_flag = '1' AND a.is_filter = '0' -- and a.flag in (1,2,3,4) 
AND a.data_src_type = 600 AND a.col_income_name = '银行质押' 
group by a.subst_name,b.payment_id,a.par_month_id, a.flag
;


--20260420  XQGZ2026041600312
--合同编码
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026041600312_01 purge;
create table tmp_yz_XQGZ2026041600312_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id,attr_id,attr_value1
,row_number() over(partition by par_month_id,serv_id,attr_id order by modi_date desc) pm
from iodata_ods_month_city.rpt_comm_cm_prod_attr_mon 
where par_corp_id = '200' and par_month_id>=202301 and par_month_id<=202604 
and attr_id in (200009325  --合同正式编码
,200009323  --合同子编码
,200009326  --ICT合同名称
,200009324)  --ICT合同子项目名称 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026041600312_02 purge;
create table tmp_yz_XQGZ2026041600312_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b1.attr_value1 ht_nbr,b2.attr_value1 ht_name,b3.attr_value1 zht_nbr,b4.attr_value1 zht_name 
from ads_XQGZ2026041600312_a_r_list a 
left join tmp_yz_XQGZ2026041600312_01 b1 
on date_format(a.act_date,'yyyyMM')=b1.par_month_id and a.serv_id=b1.serv_id and b1.attr_id=200009325 and b1.pm=1 
left join tmp_yz_XQGZ2026041600312_01 b2 
on date_format(a.act_date,'yyyyMM')=b2.par_month_id and a.serv_id=b2.serv_id and b2.attr_id=200009326 and b2.pm=1
left join tmp_yz_XQGZ2026041600312_01 b3 
on date_format(a.act_date,'yyyyMM')=b3.par_month_id and a.serv_id=b3.serv_id and b3.attr_id=200009323 and b3.pm=1 
left join tmp_yz_XQGZ2026041600312_01 b4 
on date_format(a.act_date,'yyyyMM')=b4.par_month_id and a.serv_id=b4.serv_id and b4.attr_id=200009324 and b4.pm=1 
;


--打标合同生效失效时间
drop table if exists tmp_yz_XQGZ2026041600312_03 purge;
create table tmp_yz_XQGZ2026041600312_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select contract_id,contract_code,contract_name
,cast(sign_date as timestamp) sign_date,cast(end_date as timestamp) end_date
,applyusername,mod_date,
row_number() over(partition by contract_code order by mod_date desc) row_num
from iodata_ods_day_szx.ctg_ict_bictcontract;


--20260421  张雯  员工优惠巡察数据新增产权客户名称和是否公司名
drop table if exists tmp_yz_liq_xc_ygyh_01 purge;
create table tmp_yz_liq_xc_ygyh_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1 acc_nbr from zone_gz_yz_3351225714708480 a;

drop table if exists tmp_yz_liq_xc_ygyh_02 purge;
create table tmp_yz_liq_xc_ygyh_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.cust_name,case when b.is_gsm=1 then '是' when is_gsm=0 then '否' else null end is_gsmc 
from tmp_yz_liq_xc_ygyh_01 a 
left join dwm_yz_tb_comm_cm_all_final b on a.acc_nbr=b.acc_nbr and b.par_month_id=202604 
;

drop table if exists ads_yz_liq_xc_ygyh_list purge;
create table ads_yz_liq_xc_ygyh_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,row_number() over(order by acc_nbr) paixu from tmp_yz_liq_xc_ygyh_02 a;

drop table if exists tmp_yz_liq_xc_ygyh_03 purge;
create table tmp_yz_liq_xc_ygyh_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,case when b.is_rh_ykj=1 then '是' when is_rh_ykj=0 then '否' else null end is_rh 
from ads_yz_liq_xc_ygyh_list a 
left join dwm_yz_tb_comm_cm_all_final b on a.acc_nbr=b.acc_nbr and b.par_month_id=202604 
;

--20260427  员工优惠  张雯  总机服务标识累计已优惠金额
drop table if exists tmp_yz_liq_xc_ygyh_01 purge;
create table tmp_yz_liq_xc_ygyh_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select index1,index2,index3,index4,index5,index6,index7,index8
,date_format(index9,'yyyy-MM-01') open_date,index10,index11,index12
,cast(index13 as decimal(30,4)) yh_fee_m,index14 
from zone_gz_yz_3351225714708480;

drop table if exists tmp_yz_liq_xc_ygyh_02 purge;
create table tmp_yz_liq_xc_ygyh_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,months_between('2026-04-01', open_date) diff_month 
from tmp_yz_liq_xc_ygyh_01 a 
;

drop table if exists tmp_yz_liq_xc_ygyh_03 purge;
create table tmp_yz_liq_xc_ygyh_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,cast(cast(diff_month as int)*yh_fee_m as decimal(30,4)) sum_yh_fee 
from tmp_yz_liq_xc_ygyh_02 a ;

--20260511  XQGZ2026042702655 关于申请包年宽带续约清单  宽带续约回溯需求，先备份
drop table if exists ads_yz_kd_xy_pz_ndhs_bf_202603_v1 purge;
create table ads_yz_kd_xy_pz_ndhs_bf_202603_v1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_xy_pz_ndhs_bf_202603 ;
drop table if exists ads_yz_kd_xy_pz_ndhs_bf_202603 purge;
alter table ads_yz_kd_xy_pz_ndhs_bf_202603_v1 rename to ads_yz_kd_xy_pz_ndhs_bf_202603;

drop table if exists ads_yz_kd_xy_list_have_jk_ndhs_bf_202603_v1 purge;
create table ads_yz_kd_xy_list_have_jk_ndhs_bf_202603_v1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_xy_list_have_jk_ndhs_bf_202603 ;
drop table if exists ads_yz_kd_xy_list_have_jk_ndhs_bf_202603 purge;
alter table ads_yz_kd_xy_list_have_jk_ndhs_bf_202603_v1 rename to ads_yz_kd_xy_list_have_jk_ndhs_bf_202603;

drop table if exists ads_yz_kd_xy_list_ndhs_bf_202603_v1 purge;
create table ads_yz_kd_xy_list_ndhs_bf_202603_v1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_xy_list_ndhs_bf_202603 ;
drop table if exists ads_yz_kd_xy_list_ndhs_bf_202603 purge;
alter table ads_yz_kd_xy_list_ndhs_bf_202603_v1 rename to ads_yz_kd_xy_list_ndhs_bf_202603;

drop table if exists ads_yz_kd_xy_list_pz_ndhs_bf_202603_v1 purge;
create table ads_yz_kd_xy_list_pz_ndhs_bf_202603_v1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_xy_list_pz_ndhs_bf_202603 ;
drop table if exists ads_yz_kd_xy_list_pz_ndhs_bf_202603 purge;
alter table ads_yz_kd_xy_list_pz_ndhs_bf_202603_v1 rename to ads_yz_kd_xy_list_pz_ndhs_bf_202603;

--备份最新数据
create table ads_yz_kd_xy_pz_bf_20260511 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select * from ads_yz_kd_xy_pz;

create table ads_yz_kd_xy_list_have_jk_bf_20260511 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_xy_list_have_jk;

create table ads_yz_kd_xy_list_bf_20260511 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_xy_list;

create table ads_yz_kd_xy_list_pz_bf_20260511 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from ads_yz_kd_xy_list_pz;

--20260513  宽带新装 补打 是否临街商铺
--备份
drop table if exists ads_yz_kd_new_list_20260513 purge;
create table ads_yz_kd_new_list_20260513 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from ads_yz_kd_new_list;

drop table if exists tmp_yz_kd_new_list_20260513 purge;
create table tmp_yz_kd_new_list_20260513 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id
,a.subs_code,a.subs_stat_date,a.subst_id,a.subst_name,a.branch_id
,a.branch_name,a.area_id,a.area_name,a.grid_id,a.grid_code,a.grid_name
,a.region_type,a.std_subst_id,a.std_subst_name,a.std_branch_id,a.std_branch_name
,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type,a.is_mdz
,a.six_market,a.serv_grp_type,a.sales_code,a.sales_name,a.channel_id,a.channel_nbr
,a.channel_name,a.channel_subst_name,a.channel_branch_name,a.channel_area_name
,a.channel_region_type,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype0_2011
,a.state,a.prod_id,a.is_zhuanxian,a.kd_desc,a.prod_type3,a.prod_type2,a.itv_type
,a.kd_prod_offer_id,a.speed_value,a.jz_points,a.is_rh_ykj,a.rh_tc_value,a.acc_nbr2
,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name,a.cust_code,a.ccust_name,a.ccust_org
,a.is_gsm,a.serv_addr_id,a.serv_addr_name,a.addr_id_7,a.open_date,a.is_sk_xjd

,case when c.serv_addr_id>0 then 1 else 0 end as is_ljsp

,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name,a.six_market_desc
,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx,a.kuayv_offer_name
,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.ycx_offer_type,a.own_operators_nbr,a.own_operators_name,a.is_zhuangwei
,a.is_sheng_yx,a.cdma_disc_type3_name,a.label_name,a.load_date,a.fk_lx,a.fk_value,a.kd_ll
,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce,a.seq_id,a.main_prod_offer_name,a.is_zxyb,a.is_lb_hy
,a.addr_name_7,a.cntrt_type_cbxl_name,a.kq_type,a.act_date,a.salestaff_subst_name
,a.salestaff_branch_name,a.fukuan_yd_acc,a.staff_id,a.staff_code,a.sales_man_name,a.org_id
,a.org_name,a.sys_post_name,a.rh_tc_value_bd,a.is_fttr,a.is_heyue,a.is_ai,a.is_huoyue
,a.acc_cly_zs,a.is_yd_2_new_act,a.is_yd_last_hydy,a.rh_tc_value_bd_1,a.is_bnkd
,a.par_month_id,a.par_sum_date 
from ads_yz_kd_new_list a
left join zone_gz_yz.dwd_yz_dim_ljsp_addr c on cast(a.serv_addr_id as decimal(24,0))=c.serv_addr_id;

insert overwrite table ads_yz_kd_new_list 
select a.sum_date,a.month_id,a.serv_id,a.acc_nbr,a.subs_id
,a.subs_code,a.subs_stat_date,a.subst_id,a.subst_name,a.branch_id
,a.branch_name,a.area_id,a.area_name,a.grid_id,a.grid_code,a.grid_name
,a.region_type,a.std_subst_id,a.std_subst_name,a.std_branch_id,a.std_branch_name
,a.cell_id,a.cell_code,a.cell_name,a.cell_type_name,a.bg_type,a.bu_type,a.is_mdz
,a.six_market,a.serv_grp_type,a.sales_code,a.sales_name,a.channel_id,a.channel_nbr
,a.channel_name,a.channel_subst_name,a.channel_branch_name,a.channel_area_name
,a.channel_region_type,a.channel_type_2011,a.channel_subtype_2011,a.channel_subtype0_2011
,a.state,a.prod_id,a.is_zhuanxian,a.kd_desc,a.prod_type3,a.prod_type2,a.itv_type
,a.kd_prod_offer_id,a.speed_value,a.jz_points,a.is_rh_ykj,a.rh_tc_value,a.acc_nbr2
,a.fttx_type,a.cust_id,a.cust_nbr,a.cust_name,a.cust_code,a.ccust_name,a.ccust_org
,a.is_gsm,a.serv_addr_id,a.serv_addr_name,a.addr_id_7,a.open_date,a.is_sk_xjd
,a.is_ljsp
,a.is_yqjq,a.prod_name,a.kd_prod_offer_code,a.kd_prod_offer_name,a.six_market_desc
,a.serv_grp_type_desc,a.channel_subtype_flag,a.is_shangqi_dx,a.kuayv_offer_name
,a.grid_unit_area_id,a.mgr_area_id,a.is_xjd,a.sales_id,a.rh_type_ykj,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.ycx_offer_type,a.own_operators_nbr,a.own_operators_name,a.is_zhuangwei
,a.is_sheng_yx,a.cdma_disc_type3_name,a.label_name,a.load_date,a.fk_lx,a.fk_value,a.kd_ll
,a.kd_sc,a.is_hy,a.fee_shebei,a.fee_tiaoce,a.seq_id,a.main_prod_offer_name,a.is_zxyb,a.is_lb_hy
,a.addr_name_7,a.cntrt_type_cbxl_name,a.kq_type,a.act_date,a.salestaff_subst_name
,a.salestaff_branch_name,a.fukuan_yd_acc,a.staff_id,a.staff_code,a.sales_man_name,a.org_id
,a.org_name,a.sys_post_name,a.rh_tc_value_bd,a.is_fttr,a.is_heyue,a.is_ai,a.is_huoyue
,a.acc_cly_zs,a.is_yd_2_new_act,a.is_yd_last_hydy,a.rh_tc_value_bd_1,a.is_bnkd
,a.par_month_id,a.par_sum_date 
from tmp_yz_kd_new_list_20260513 a 
;

--20260512  更新21天打卡人员维表
drop table if exists tmp_yz_liq_01 purge;
create table tmp_yz_liq_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
as 
select index1 subst_name,index2 branch_name ,index3 branch_type,index4 salestaff_name,index5 salestaff_code  
from zone_gz_yz_3351225714708480; 
drop table dwm_yz_sales_21_list purge;
alter table tmp_yz_liq_01 rename to dwm_yz_sales_21_list;

--20260518  巡察-新增及存量积分与激励统计
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_xc_xz_data_dwb_01 purge;
create table tmp_yz_xc_xz_data_dwb_01
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,serv_id,prod_type,is_new_user,jz_points,fee_new_tax,kd_desc,cust_id,cust_nbr 
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202201 and par_month_id<=202512 
and is_new_user=1 and prod_type in(30) 
union all 
select par_month_id,serv_id,prod_type,is_new_user,jz_points,fee_new_tax,kd_desc,cust_id,cust_nbr 
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202201 and par_month_id<=202512 
and is_new_user=1 and prod_type=40 and kd_desc='普通宽带';

--收入
drop table tmp_yz_xc_xz_data_dwb_01_1 purge;
create table tmp_yz_xc_xz_data_dwb_01_1   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cast(par_month_id/100 as int) year_id,serv_id, 
sum(a0) as sh_qr --税后确认收入
from zone_gz_yz.dwm_srhx_serv_list_mon_final
where par_month_id>=202201 and par_month_id<=202512 
group by cast(par_month_id/100 as int),serv_id 
;

--价值积分
drop table tmp_yz_xc_xz_data_dwb_01_2 purge;
create table tmp_yz_xc_xz_data_dwb_01_2   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cast(par_month_id/100 as int) year_id,serv_id, 
sum(jz_points) as jz_jf  
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202201 and par_month_id<=202512 
group by cast(par_month_id/100 as int),serv_id 
;

drop table tmp_yz_xc_xz_data_dwb_07_1 purge;
create table tmp_yz_xc_xz_data_dwb_07_1   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.sh_qr 
from tmp_yz_xc_xz_data_dwb_01 a 
left join tmp_yz_xc_xz_data_dwb_01_1 b on a.serv_id=b.serv_id and cast(a.par_month_id/100 as int)=b.year_id 
;

drop table tmp_yz_xc_xz_data_dwb_07_2 purge;
create table tmp_yz_xc_xz_data_dwb_07_2   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.* 
,b.jz_jf 
from tmp_yz_xc_xz_data_dwb_07_1 a 
left join tmp_yz_xc_xz_data_dwb_01_2 b on a.serv_id=b.serv_id and cast(a.par_month_id/100 as int)=b.year_id 
;

drop table tmp_yz_xc_xz_data_dwb_07 purge;
create table tmp_yz_xc_xz_data_dwb_07   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
--当年新增移宽积分
select 'jzjf' flag,sum(case when par_month_id>=202201 and par_month_id<=202212 then jz_jf else 0 end) v1 
,sum(case when par_month_id>=202301 and par_month_id<=202312 then jz_jf else 0 end) v2 
,sum(case when par_month_id>=202401 and par_month_id<=202412 then jz_jf else 0 end) v3 
,sum(case when par_month_id>=202501 and par_month_id<=202512 then jz_jf else 0 end) v4 
from tmp_yz_xc_xz_data_dwb_07_2 
union all 
--当年新增移宽累计收入
select 'sr' flag,sum(case when par_month_id>=202201 and par_month_id<=202212 then sh_qr else 0 end) v1 
,sum(case when par_month_id>=202301 and par_month_id<=202312 then sh_qr else 0 end) v2 
,sum(case when par_month_id>=202401 and par_month_id<=202412 then sh_qr else 0 end) v3 
,sum(case when par_month_id>=202501 and par_month_id<=202512 then sh_qr else 0 end) v4 
from tmp_yz_xc_xz_data_dwb_07_2 

;

--新增客户三年累计价值贡献
drop table tmp_yz_xc_xz_data_dwb_08 purge;
create table tmp_yz_xc_xz_data_dwb_08   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select 2022 year_id,cust_id,sum(jz_points) jz_value 
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202201 and par_month_id<=202412 
group by cust_id 
union all 
select 2023 year_id,cust_id,sum(jz_points) jz_value 
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202301 and par_month_id<=202512 
group by cust_id 
union all 
select 2024 year_id,cust_id,sum(jz_points) jz_value 
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202401 and par_month_id<=202512 
group by cust_id 
union all 
select 2025 year_id,cust_id,sum(jz_points) jz_value 
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202501 and par_month_id<=202512 
group by cust_id 
;

--新增客户三年累计价值贡献
drop table tmp_yz_xc_xz_data_dwb_09 purge;
create table tmp_yz_xc_xz_data_dwb_09   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select a.* from tmp_yz_xc_xz_data_dwb_08 a 
join (select cust_id from tmp_yz_xc_xz_data_dwb_01 where par_month_id>=202201 and par_month_id<=202212 group by cust_id) b 
on a.cust_id=b.cust_id where a.year_id=2022 
union all 
select a.* from tmp_yz_xc_xz_data_dwb_08 a 
join (select cust_id from tmp_yz_xc_xz_data_dwb_01 where par_month_id>=202301 and par_month_id<=202312 group by cust_id) b 
on a.cust_id=b.cust_id where a.year_id=2023 
union all 
select a.* from tmp_yz_xc_xz_data_dwb_08 a 
join (select cust_id from tmp_yz_xc_xz_data_dwb_01 where par_month_id>=202401 and par_month_id<=202412 group by cust_id) b 
on a.cust_id=b.cust_id where a.year_id=2024 
union all 
select a.* from tmp_yz_xc_xz_data_dwb_08 a 
join (select cust_id from tmp_yz_xc_xz_data_dwb_01 where par_month_id>=202501 and par_month_id<=202512 group by cust_id) b 
on a.cust_id=b.cust_id where a.year_id=2025 
;

--新增客户三年累计价值贡献
--select year_id,sum(jz_value) jz_points from tmp_yz_xc_xz_data_dwb_09 group by year_id 

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_xc_xz_data_dwb_02 purge;
create table tmp_yz_xc_xz_data_dwb_02
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,serv_id,prod_type,is_wl_cancel_user,jz_points,fee_new_tax,kd_desc,cust_id,cust_nbr 
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202201 and par_month_id<=202512 
and is_wl_cancel_user=1 and prod_type in(30,40);

drop table if exists tmp_yz_xc_xz_data_dwb_02_1 purge;
create table tmp_yz_xc_xz_data_dwb_02_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,coalesce(b.is_contract,0) is_heyue 
from tmp_yz_xc_xz_data_dwb_02 a 
left join dwm_yz_tb_comm_cm_all_mon_final b 
on a.serv_id=b.serv_id and (case when mod(a.par_month_id,100)<>1 then (a.par_month_id-1)
          else (a.par_month_id-89) end)=b.par_month_id; 

drop table tmp_yz_xc_xz_data_dwb_03 purge;
create table tmp_yz_xc_xz_data_dwb_03   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,rh_tc_id 
,count(case when is_contract=1 then serv_id else null end) as hy_nums 
from dwm_yz_tb_comm_cm_all_mon_final a where par_month_id>=202201 and par_month_id<=202512 
group by par_month_id,rh_tc_id;

drop table tmp_yz_xc_xz_data_dwb_04 purge;
create table tmp_yz_xc_xz_data_dwb_04   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,case when a.prod_type=40 and b.rh_tc_id is not null then 1 else a.is_heyue end is_contract 
from tmp_yz_xc_xz_data_dwb_02_1 a 
left join (select par_month_id,rh_tc_id from tmp_yz_xc_xz_data_dwb_03 where hy_nums>0 group by par_month_id,rh_tc_id) b 
on a.serv_id=b.rh_tc_id and (case when mod(a.par_month_id,100)<>1 then (a.par_month_id-1)
          else (a.par_month_id-89) end)=b.par_month_id 
;

drop table tmp_yz_xc_xz_data_dwb_05 purge;
create table tmp_yz_xc_xz_data_dwb_05   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.jz_points jz_points_last
from tmp_yz_xc_xz_data_dwb_04 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and (case when mod(a.par_month_id,100)<>1 then (a.par_month_id-1)
          else (a.par_month_id-89) end)=b.par_month_id;

--当年移宽无约客户离网销户积分
drop table tmp_yz_xc_xz_data_dwb_06 purge;
create table tmp_yz_xc_xz_data_dwb_06   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select sum(case when par_month_id>=202201 and par_month_id<=202212 and is_contract=0 then jz_points_last else 0 end) v1 
,sum(case when par_month_id>=202301 and par_month_id<=202312 and is_contract=0 then jz_points_last else 0 end) v2 
,sum(case when par_month_id>=202401 and par_month_id<=202412 and is_contract=0 then jz_points_last else 0 end) v3 
,sum(case when par_month_id>=202501 and par_month_id<=202512 and is_contract=0 then jz_points_last else 0 end) v4 
from tmp_yz_xc_xz_data_dwb_05 ;

--离网客户三年累计价值损失
drop table tmp_yz_xc_xz_data_dwb_10 purge;
create table tmp_yz_xc_xz_data_dwb_10   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select cast(par_month_id/100 as int) year_id,cust_id 
from tmp_yz_xc_xz_data_dwb_05 where is_contract=0 
group by cast(par_month_id/100 as int),cust_id ;

drop table tmp_yz_xc_xz_data_dwb_11 purge;
create table tmp_yz_xc_xz_data_dwb_11   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select cast(par_month_id/100 as int) year_id,cust_id,sum(jz_points) jz_jf 
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id in(202112,202212,202312,202412)
group by cast(par_month_id/100 as int),cust_id 
;

drop table tmp_yz_xc_xz_data_dwb_12 purge;
create table tmp_yz_xc_xz_data_dwb_12   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select a.*,b.jz_jf from tmp_yz_xc_xz_data_dwb_10 a left join tmp_yz_xc_xz_data_dwb_11 b 
on a.cust_id=b.cust_id and (a.year_id-1)=b.year_id;
		  

select year_id,sum(jz_jf)*36 from tmp_yz_xc_xz_data_dwb_12 group by year_id order by year_id 

--20260519  XQGZ2026051802375 
-- create table tmp_py_ycpybbsr202511 as 
-- select * from view_py_ads_srhx_serv_list_mon a
 -- left join (select * from dwd_py_dim_sr_cpfl2024 where srlx in('云产品','云标品') ) b2  on a.prod_name=b2.cp
-- where a.par_month_id between 202510 and 202511

drop table tmp_yz_XQGZ2026051802375_01 purge;
create table tmp_yz_XQGZ2026051802375_01   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select par_month_id,subst_name,branch_name,prod_name
,(case when length(a.ccust_name)<2 then a.ccust_name 
when length(a.ccust_name)=2 then concat(SUBSTR(a.ccust_name,1,1),'*') 
when length(a.ccust_name)>2 then concat(SUBSTR(a.ccust_name,1,(length(a.ccust_name)-2)),'**') else null end) ccust_name_tm 
,sales_name,
sum(a0) sh_qr 
from dwm_srhx_serv_list_mon_final a 
where a.subst_id=10002 and a.prod_name in('云主机（标准）','云堤','云堤安全产品'
,'云带宽加装','云桌面','云桌面-服务','云电脑数据盘','云硬盘加装','云视频会议（广东）'
,'天翼云甄选商城','天翼云眼','天翼云网账号群子','对象存储（试用、商用、低频）','微建站'
,'微派（单产品）','手机看店','手机看店预付费','海外节点云主机','省内云主机（个性化）'
,'省内云主机（标准）','省内云产品（安全类）','省内云产品（定制）','省内云产品（数据库类）'
,'省内云产品（网络类）','省内云产品（计算类）','翼教云','集团云产品','CDN','CDN加速'
,'云专网3.0','云录音（集约版）','云桌面-计算单元','云电脑','云计算群','云迁移','云间高速'
,'企业云盘','天翼专属云','天翼云会议','天翼云呼','属地行业云','平安客','手机看店（连锁版）'
,'数据库','物理机','电视会议','行业云产品群','视频直播') 
and par_month_id>=202301 and par_month_id<=202512 
group by par_month_id,subst_name,branch_name,prod_name,(case when length(a.ccust_name)<2 then a.ccust_name 
when length(a.ccust_name)=2 then concat(SUBSTR(a.ccust_name,1,1),'*') 
when length(a.ccust_name)>2 then concat(SUBSTR(a.ccust_name,1,(length(a.ccust_name)-2)),'**') else null end),sales_name;

drop table tmp_yz_XQGZ2026051802375_02 purge;
create table tmp_yz_XQGZ2026051802375_02   
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 	
select * from tmp_yz_XQGZ2026051802375_01 where par_month_id>=202301 and par_month_id<=202512 ;

--巡察  张雯  202101-202512酒宽销售品发展数据
--select distinct offer_id,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200 
--and prod_offer_code in('DM0001-848-1-1',
'DM0001-848-1-2',
'DM0001-536-1-7',
'DM0001-536-1-2',
'DM0001-536-1-1',
'DM0001-536-1-3',
'DM0001-526-1-1',
'DM0001-526-1-4',
'DM0001-526-1-7',
'DM0001-526-1-12',
'DM0001-521-1-2',
'DM0001-521-1-3',
'DM0001-521-1-4',
'DM0001-521-1-5',
'DM0001-521-1-6',
'DM0001-521-1-8',
'YD0001-B59-1-5',
'YD0001-B59-1-6',
'DM0001-545-1-02',
'DM0001-545-1-04',
'DM0001-545-1-06',
'DM0001-545-1-01',
'DM0001-545-1-03',
'DM0001-545-1-05',
'DM0001-543-1-1',
'DM0001-543-1-3',
'DM0001-543-1-4',
'DM0001-543-1-5',
'TY931')

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_zqb_xc_jdkd_rw_01 purge;
create table tmp_yz_zqb_xc_jdkd_rw_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.msinfo_id,a.start_date,a.end_date,a.subs_stat
,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date,a.open_date
,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_subst_id
,a.salestaff_branch_id,a.salestaff_channel_id,a.staff_org_id,a.staff_subst_id,a.staff_branch_id
,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id,a.std_subst_id,a.std_branch_id
,a.cell_id,a.cell_code,a.grid_id,a.grid_code,a.area_id,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where a.par_month_id>=202101 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202101'  
and date_format(a.subs_stat_date,'yyyyMM') <= '202512'  
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(100054285,100054286,100069786,100087483,100087653,500016151
,500016153,500016157,500057178,500058180,500058381,500070462,500078127,100054283
,100054284,100054287,100054289,100087480,100087486,500016152,500069046,500070461
,500072497,500072498,500076142,500077132,500078125,500078126,500078128) 
union all 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.msinfo_id,a.start_date,a.end_date,a.subs_stat
,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date,a.open_date
,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_subst_id
,a.salestaff_branch_id,a.salestaff_channel_id,a.staff_org_id,a.staff_subst_id,a.staff_branch_id
,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id,a.std_subst_id,a.std_branch_id
,a.cell_id,a.cell_code,a.grid_id,a.grid_code,a.area_id,a.bg_type,a.bu_type,a.region_type,'202605' par_month_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202101'  
and date_format(a.subs_stat_date,'yyyyMM') <= '202512'  
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(100054285,100054286,100069786,100087483,100087653,500016151
,500016153,500016157,500057178,500058180,500058381,500070462,500078127,100054283
,100054284,100054287,100054289,100087480,100087486,500016152,500069046,500070461
,500072497,500072498,500076142,500077132,500078125,500078126,500078128);

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;

drop table if exists tmp_yz_zqb_xc_jdkd_rw_02 purge;
create table tmp_yz_zqb_xc_jdkd_rw_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id
,e.offer_name prod_offer_name
,a.msinfo_id,a.start_date,a.end_date,a.subs_stat
,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date,a.open_date
,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_subst_id
,c.org_name salestaff_subst_name 
,a.salestaff_branch_id,a.salestaff_channel_id,a.staff_org_id,a.staff_subst_id,a.staff_branch_id
,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,b.org_name subst_name
,a.std_subst_id,a.std_branch_id
,a.cell_id,a.cell_code,a.grid_id,a.grid_code,a.area_id,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
from tmp_yz_zqb_xc_jdkd_rw_01 a 
left join (select * from  dwd_yz_dim_org) b on a.subst_id=b.org_id 
left join (select * from  dwd_yz_dim_org) c on a.salestaff_subst_id=c.org_id 
left join dws_crm_cfguse.dws_offer e on e.city_id=200 and a.prod_offer_id=e.offer_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_03 purge;
create table tmp_yz_zqb_xc_jdkd_rw_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id
,a.prod_offer_name
,a.msinfo_id,a.start_date,a.end_date,a.subs_stat
,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date,a.open_date
,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,e.org_name salestaff_org_name,a.salestaff_subst_id
,a.salestaff_subst_name 
,a.salestaff_branch_id,c.org_name salestaff_branch_name 
,a.salestaff_channel_id,a.staff_org_id,a.staff_subst_id,a.staff_branch_id
,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,b.org_name branch_name
,a.std_subst_id,a.std_branch_id
,a.cell_id,a.cell_code,a.grid_id,a.grid_code,a.area_id,d.org_name area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
from tmp_yz_zqb_xc_jdkd_rw_02 a 
left join (select * from  dwd_yz_dim_org) b on a.branch_id=b.org_id 
left join (select * from  dwd_yz_dim_org) c on a.salestaff_branch_id=c.org_id 
left join (select * from  dwd_yz_dim_org) d on a.area_id=d.org_id 
left join (select * from  dwd_yz_dim_org) e on a.salestaff_org_id=e.org_id 
;

--揽装网点名称
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_04 purge;
create table tmp_yz_zqb_xc_jdkd_rw_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id
,a.prod_offer_name
,a.msinfo_id,a.start_date,a.end_date,a.subs_stat
,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date,a.open_date
,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name,a.salestaff_subst_id
,a.salestaff_subst_name 
,a.salestaff_branch_id,a.salestaff_branch_name 
,a.salestaff_channel_id,b.channel_nbr,b.channel_name,a.staff_org_id,a.staff_subst_id,a.staff_branch_id
,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name
,a.std_subst_id,a.std_branch_id
,a.cell_id,a.cell_code,a.grid_id,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
from tmp_yz_zqb_xc_jdkd_rw_03 a 
left join zone_gz_yz.dwd_yz_sale_outlers_mon_final b on a.salestaff_channel_id=b.channel_id and a.par_month_id=b.par_month_id;

--经营主体和地址名称
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_05 purge;
create table tmp_yz_zqb_xc_jdkd_rw_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 

,b.own_operators_id,b.own_operators_nbr,b.own_operators_name,c.addr serv_addr_name
from tmp_yz_zqb_xc_jdkd_rw_04 a  
left join dwd_yz_sale_outlers_mon_final b on a.salestaff_channel_id=b.channel_id and a.par_month_id=b.par_month_id
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) c on cast(a.serv_addr_id as decimal(24,0))=c.id;

--当前状态
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_06 purge;
create table tmp_yz_zqb_xc_jdkd_rw_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
,a.own_operators_id,a.own_operators_nbr,a.own_operators_name,a.serv_addr_name 
,case when b.serv_id is not null then c.attr_value_name else '拆机' end as state_desc
from tmp_yz_zqb_xc_jdkd_rw_05 a 
left join (select serv_id,state from dwm_yz_tb_comm_cm_all_final where par_month_id=202605 and is_cancel_user=0 group by serv_id,state) b 
on a.serv_id=b.serv_id 
left join dws_crm_cfguse.dws_attr_value c on b.state=c.attr_value and c.city_id='200' and c.attr_id='4000000201' 
;

--拆机
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_07 purge;
create table tmp_yz_zqb_xc_jdkd_rw_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.par_month_id,a.serv_id,a.is_wl_cancel_user,a.wl_cancel_subs_stat_date,a.hist_create_date,
date_format(a.hist_create_date,'yyyyMMdd') as cancel_date
from dwm_yz_tb_comm_cm_all_mon_final a  
where a.par_month_id>=202101 and a.par_month_id<=202604 and a.is_cancel_user=1 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
insert into table tmp_yz_zqb_xc_jdkd_rw_07  
select a.par_month_id,a.serv_id,a.is_wl_cancel_user,a.wl_cancel_subs_stat_date,a.hist_create_date,
date_format(a.hist_create_date,'yyyyMMdd') as cancel_date
from dwm_yz_tb_comm_cm_all_final a  
where a.par_month_id=202605 and a.is_cancel_user=1 
;

--停机
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_08 purge;
create table tmp_yz_zqb_xc_jdkd_rw_08  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.par_month_id,a.serv_id,a.stop_date,a.stop_reason_id,b.attr_name
from dwm_yz_tb_comm_cm_all_mon_final a  
left join dws_crm_cfguse.dws_attr_spec b on a.stop_reason_id=b.attr_id 
where a.par_month_id>=202101 and a.par_month_id<=202604 and a.stop_date is not null 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
insert into table tmp_yz_zqb_xc_jdkd_rw_08 
select a.par_month_id,a.serv_id,a.stop_date,a.stop_reason_id,b.attr_name
from dwm_yz_tb_comm_cm_all_final a  
left join dws_crm_cfguse.dws_attr_spec b on a.stop_reason_id=b.attr_id 
where a.par_month_id=202605 and a.stop_date is not null 
;

--移机
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_09 purge;
create table tmp_yz_zqb_xc_jdkd_rw_09  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id,subs_stat_date,serv_addr_id_last,serv_addr_id 
from dwd_yz_rpt_comm_ba_subs_move_final;

--2021年移机
drop table if exists tmp_yz_zqb_xc_jdkd_rw_10;
create table tmp_yz_zqb_xc_jdkd_rw_10
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select *
,row_number() over(partition by a.subs_id order by a.subs_stat_date desc) pm  
from (
select date_format(subs_stat_date,'yyyyMM') month_id,subs_id,subs_code,req_id,req_code,serv_id,acc_nbr,cust_id,subs_stat_date,
act_date,hist_create_date,action_id,action_type,action_ex_type,salestaff_id,staff_id
from dwm_yz_rpt_comm_ba_subs_mon_final 
where par_month_id>=202101 and par_month_id<=202112 and subs_stat='301200' and subs_stat_reason<>'1200' and action_type='MOVE' 
and date_format(subs_stat_date,'yyyyMM')>='202101'		
and date_format(subs_stat_date,'yyyyMM')<='202112'
) a;

drop table if exists tmp_yz_zqb_xc_jdkd_rw_11;
create table tmp_yz_zqb_xc_jdkd_rw_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 
a.month_id,a.subs_id,a.subs_code,a.req_id,a.req_code,a.serv_id,a.acc_nbr,a.cust_id,a.subs_stat_date,
a.act_date,a.hist_create_date,a.action_id,a.action_type,a.action_ex_type,a.salestaff_id,a.staff_id,
b.serv_addr_id,
c.serv_addr_id serv_addr_id_last
from (select *  from tmp_yz_zqb_xc_jdkd_rw_10 where pm=1) a
left join (select par_month_id,serv_id,serv_addr_id
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202101 and par_month_id<=202112) b
on a.serv_id=b.serv_id  and a.par_month_id=b.par_month_id                 
left join (select par_month_id,serv_id,serv_addr_id
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202012 and par_month_id<=202112) c
on a.serv_id=c.serv_id and (case when mod(a.par_month_id,100)<>1 then (a.par_month_id-1)
else (a.par_month_id-89) end)=c.par_month_id;   

--移机合并
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
insert into table tmp_yz_zqb_xc_jdkd_rw_09  
select month_id par_month_id,serv_id,subs_stat_date,serv_addr_id_last,serv_addr_id 
from tmp_yz_zqb_xc_jdkd_rw_11;

--打标最近一次停机时间
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_12;
create table tmp_yz_zqb_xc_jdkd_rw_12
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
,a.own_operators_id,a.own_operators_nbr,a.own_operators_name,a.serv_addr_name,a.state_desc
,b.stop_date 
from tmp_yz_zqb_xc_jdkd_rw_06 a 
left join (select serv_id,stop_date,row_number() over(partition by serv_id order by stop_date desc ) pm from tmp_yz_zqb_xc_jdkd_rw_08 ) b 
on a.serv_id=b.serv_id and b.pm=1 
;

--打标拆机时间
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_13;
create table tmp_yz_zqb_xc_jdkd_rw_13
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
,a.own_operators_id,a.own_operators_nbr,a.own_operators_name,a.serv_addr_name,a.state_desc,a.stop_date 
,b.hist_create_date 
from tmp_yz_zqb_xc_jdkd_rw_12 a 
left join (select serv_id,hist_create_date,row_number() over(partition by serv_id order by hist_create_date desc ) pm 
			from tmp_yz_zqb_xc_jdkd_rw_07 ) b 
on a.serv_id=b.serv_id and b.pm=1 
;

--打标移机时间
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_14;
create table tmp_yz_zqb_xc_jdkd_rw_14
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
,a.own_operators_id,a.own_operators_nbr,a.own_operators_name,a.serv_addr_name,a.state_desc,a.stop_date 
,a.hist_create_date,case when b.serv_id is not null then '是' else '否' end is_yj 
,b.subs_stat_date move_date,b.serv_addr_id_last,b.serv_addr_id yjh_addr_id
from tmp_yz_zqb_xc_jdkd_rw_13 a 
left join (select serv_id,subs_stat_date,serv_addr_id_last,serv_addr_id 
			,row_number() over(partition by serv_id order by subs_stat_date desc ) pm 
			from tmp_yz_zqb_xc_jdkd_rw_09 ) b 
on a.serv_id=b.serv_id and b.pm=1 
;

--打标移机后地址名称
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_15;
create table tmp_yz_zqb_xc_jdkd_rw_15
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
,a.own_operators_id,a.own_operators_nbr,a.own_operators_name,a.serv_addr_name,a.state_desc,a.stop_date 
,a.hist_create_date,a.is_yj ,a.move_date,a.serv_addr_id_last,a.yjh_addr_id 
,c.addr yjh_addr_name 
from tmp_yz_zqb_xc_jdkd_rw_14 a 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) c on cast(a.yjh_addr_id as decimal(24,0))=c.id;
--635800

--直销客户(一个产权出现多个直销)
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_16;
create table tmp_yz_zqb_xc_jdkd_rw_16
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
,a.own_operators_id,a.own_operators_nbr,a.own_operators_name,a.serv_addr_name,a.state_desc,a.stop_date 
,a.hist_create_date,a.is_yj ,a.move_date,a.serv_addr_id_last,a.yjh_addr_id 
,a.yjh_addr_name,b.ccust_id
from tmp_yz_zqb_xc_jdkd_rw_15 a 
left join (select distinct cust_nbr,ccust_id from dws_yz_tb_mo_custgrp_cust_final) b on a.cust_nbr=b.cust_nbr 
;
--636106

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_17;
create table tmp_yz_zqb_xc_jdkd_rw_17
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.subs_id,a.subs_code,a.serv_id,a.acc_nbr,a.cust_id,a.cust_nbr,a.cust_name
,a.prod_id,a.org_id,a.prod_offer_id,a.prod_offer_name,a.msinfo_id,a.start_date,a.end_date
,a.subs_stat,a.subs_stat_reason,a.subs_stat_date,a.action_id,a.action_type,a.act_date
,a.open_date,a.staff_id,a.serv_addr_id,a.salestaff_id,a.serv_grp_type,a.xx_salestaff_id1
,a.xx_salestaff_code1,a.xx_salestaff_name1,a.xx_salestaff_id2,a.xx_salestaff_code2
,a.xx_salestaff_name2,a.sales_code,a.sales_man_name,a.salestaff_org_id,a.salestaff_org_name
,a.salestaff_subst_id,a.salestaff_subst_name,a.salestaff_branch_id,a.salestaff_branch_name
,a.salestaff_channel_id,a.channel_nbr,a.channel_name,a.staff_org_id,a.staff_subst_id
,a.staff_branch_id,a.channel_type_2011,a.channel_subtype_2011,a.subst_id,a.branch_id
,a.subst_name,a.branch_name,a.std_subst_id,a.std_branch_id,a.cell_id,a.cell_code,a.grid_id
,a.grid_code,a.area_id,a.area_name,a.bg_type,a.bu_type,a.region_type,a.par_month_id 
,a.own_operators_id,a.own_operators_nbr,a.own_operators_name,a.serv_addr_name,a.state_desc,a.stop_date 
,a.hist_create_date,a.is_yj ,a.move_date,a.serv_addr_id_last,a.yjh_addr_id 
,a.yjh_addr_name,a.ccust_id,b.ccust_code,b.ccust_name
from tmp_yz_zqb_xc_jdkd_rw_16 a 
left join (select ccust_id,ccust_code,ccust_name,create_date,vip_flag,branch_org,manage_org  from dws_ecust.dws_mo_ccust where city_id=200) b 
on a.ccust_id=b.ccust_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_18;
create table tmp_yz_zqb_xc_jdkd_rw_18
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case 
when a.hist_create_date is not null then 
	MONTHS_BETWEEN(date_format(a.hist_create_date,'yyyy-MM-dd'),date_format(a.subs_stat_date,'yyyy-MM-dd'))  
when coalesce(a.state_desc,'-1') not in('拆机') then 
	MONTHS_BETWEEN(date_format(current_timestamp(),'yyyy-MM-dd'),date_format(a.subs_stat_date,'yyyy-MM-dd'))
else null end zw_month 
,case when coalesce(cust_name,'-1')<>coalesce(own_operators_name,'-2') 
	and coalesce(ccust_name,'-1')<>coalesce(own_operators_name,'-2') then '否' else '是' end is_same_name 
from tmp_yz_zqb_xc_jdkd_rw_17 a ;
--636106

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_19;
create table tmp_yz_zqb_xc_jdkd_rw_19
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,'' real_amount 
from tmp_yz_zqb_xc_jdkd_rw_18 a 
--left join dws_crm_order.dws_one_item_result b  on a.serv_id = cast(b.prod_inst_id as decimal(22,0)) 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_20;
create table tmp_yz_zqb_xc_jdkd_rw_20
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,case when b.index1 is not null then 1 else 0 end is_cq 
,case when c.index1 is not null then 1 else 0 end is_zx  
from tmp_yz_zqb_xc_jdkd_rw_19 a 
left join zone_gz_yz_3351225714708480 b on a.cust_name=b.index1 
left join zone_gz_yz_3351225714708480 c on a.ccust_name=c.index1 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_21;
create table tmp_yz_zqb_xc_jdkd_rw_21
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* from tmp_yz_zqb_xc_jdkd_rw_20 a 
where is_cq=1 or is_zx=1 
;

alter table tmp_yz_zqb_xc_jdkd_rw_21 rename to ads_yz_zqb_xc_jdkd_rw_list;

drop view view_ads_yz_zqb_xc_jdkd_rw_list ;
create view view_ads_yz_zqb_xc_jdkd_rw_list as 
select 
ccust_code,ccust_name,cust_nbr,cust_name,acc_nbr,subs_stat_date,state_desc,stop_date,hist_create_date,zw_month,
is_yj,move_date,serv_addr_name,yjh_addr_name,real_amount,subst_name,branch_name,area_name,sales_man_name,sales_code,
salestaff_org_name,salestaff_branch_name,salestaff_subst_name,channel_name,own_operators_name,is_same_name 
from ads_yz_zqb_xc_jdkd_rw_list 
;

--20260521  张雯  限制供应商的酒宽移机订单数据
限定供应商的AD接入号，在21年-25年的移机订单，移机是否收费，
是否收费的派单用移机单受理的当月是否受理收费单（收费单的状态是竣工。因为发现部分会撤单）
具体的字段需求，宽带接入号，移动订单，订单揽装人，揽装人所属分局，移机时间，移机前地址，移机后地址，
是否收费（移机受理当月同步受理收费订单并竣工）

--移机
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_09 purge;
create table tmp_yz_zqb_xc_jdkd_rw_yj_09  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,acc_nbr,serv_id,subs_id,subs_code,subs_stat_date,act_date,serv_addr_id_last,serv_addr_id 
,sales_code,sales_man_name,lz_subst_id,lz_subst_name,action_ex_type,action_id
from dwd_yz_rpt_comm_ba_subs_move_final;

--2021年移机
drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_10;
create table tmp_yz_zqb_xc_jdkd_rw_yj_10
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select *
,row_number() over(partition by a.subs_id order by a.subs_stat_date desc) pm  
from (
select date_format(subs_stat_date,'yyyyMM') par_month_id,subs_id,subs_code,req_id,req_code,serv_id,acc_nbr,cust_id,subs_stat_date,
act_date,hist_create_date,action_id,action_type,action_ex_type,salestaff_id,staff_id
from dwm_yz_rpt_comm_ba_subs_mon_final 
where par_month_id>=202101 and subs_stat='301200' and subs_stat_reason<>'1200' and action_type='MOVE' 
and date_format(subs_stat_date,'yyyyMM')>='202101'		
and date_format(subs_stat_date,'yyyyMM')<='202112'
) a;

drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_11;
create table tmp_yz_zqb_xc_jdkd_rw_yj_11
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select 
a.par_month_id,a.subs_id,a.subs_code,a.req_id,a.req_code,a.serv_id,a.acc_nbr,a.cust_id,a.subs_stat_date,
a.act_date,a.hist_create_date,a.action_id,a.action_type,a.action_ex_type,a.salestaff_id,a.staff_id,
b.serv_addr_id,
c.serv_addr_id serv_addr_id_last
from (select *  from tmp_yz_zqb_xc_jdkd_rw_yj_10 where pm=1) a
left join (select par_month_id,serv_id,serv_addr_id
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202101 and par_month_id<=202112) b
on a.serv_id=b.serv_id  and a.par_month_id=b.par_month_id                 
left join (select par_month_id,serv_id,serv_addr_id
from dwm_yz_tb_comm_cm_all_mon_final where par_month_id>=202012 and par_month_id<=202112) c
on a.serv_id=c.serv_id and (case when mod(a.par_month_id,100)<>1 then (a.par_month_id-1)
else (a.par_month_id-89) end)=c.par_month_id;   

drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_12;
create table tmp_yz_zqb_xc_jdkd_rw_yj_12
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*
,b.sales_man_name,b.sales_code,
b.subst_id as lz_subst_id,b.subst_name as lz_subst_name
from tmp_yz_zqb_xc_jdkd_rw_yj_11 a  
left join zone_gz_yz.dwd_yz_sales_man_outlers_final b on a.salestaff_id=b.staff_id ;

--移机合并
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
insert into table tmp_yz_zqb_xc_jdkd_rw_yj_09  
select par_month_id,acc_nbr,serv_id,subs_id,subs_code,subs_stat_date,act_date,serv_addr_id_last,serv_addr_id 
,sales_code,sales_man_name,lz_subst_id,lz_subst_name,action_ex_type,action_id  
from tmp_yz_zqb_xc_jdkd_rw_yj_12;

--限制供应商的酒宽号码
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_13;
create table tmp_yz_zqb_xc_jdkd_rw_yj_13
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
from tmp_yz_zqb_xc_jdkd_rw_yj_09 a 
join (select acc_nbr from ads_yz_zqb_xc_jdkd_rw_all_list_final_part_hmlz_1 group by acc_nbr) b on a.acc_nbr=b.acc_nbr 
where a.action_id=655 
;

--打标地址名称
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_14;
create table tmp_yz_zqb_xc_jdkd_rw_yj_14
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.addr serv_addr_name_last,c.addr serv_addr_name 
from tmp_yz_zqb_xc_jdkd_rw_yj_13 a 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) b 
on cast(a.serv_addr_id_last as decimal(24,0))=b.id 
left join (select distinct id,addr from zone_gz_yz.dwd_yz_addr_final where grade=10) c 
on cast(a.serv_addr_id as decimal(24,0))=c.id;

--打标移机收费单
-- offer_id	prod_offer_code
-- 100001409	DM0002-006-1-1
-- 500062182	DM0003-056-1-1
-- 100001338	DM0002-002-1-1
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_15 purge;
create table tmp_yz_zqb_xc_jdkd_rw_yj_15  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select date_format(a.subs_stat_date,'yyyyMM') rw_month,serv_id 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where a.par_month_id>=202101 
and  a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202101'  
and date_format(a.subs_stat_date,'yyyyMM') <= '202512'  
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(100001409,500062182,100001338) 
union all 
select date_format(a.subs_stat_date,'yyyyMM') rw_month,serv_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') >= '202101'  
and date_format(a.subs_stat_date,'yyyyMM') <= '202512'  
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(100001409,500062182,100001338);


use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_16;
create table tmp_yz_zqb_xc_jdkd_rw_yj_16
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,case when b.serv_id is not null then '是' else '否' end is_sf
from tmp_yz_zqb_xc_jdkd_rw_yj_14 a 
left join (select rw_month,serv_id from tmp_yz_zqb_xc_jdkd_rw_yj_15 group by rw_month,serv_id ) b 
on a.par_month_id=b.rw_month and a.serv_id=b.serv_id 
;


alter table tmp_yz_zqb_xc_jdkd_rw_yj_16 rename to ads_yz_zqb_xc_jdkd_rw_yj_list;
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_zqb_xc_jdkd_rw_yj_17;
create table tmp_yz_zqb_xc_jdkd_rw_yj_17
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,acc_nbr,subs_id,subs_code,subs_stat_date,sales_code,sales_man_name,lz_subst_id,lz_subst_name 
,serv_addr_name_last,serv_addr_name,is_sf 
from ads_yz_zqb_xc_jdkd_rw_yj_list;

--20260521  XQGZ2026051902289 
--合同编码
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026051902289_01_1 purge;
create table tmp_yz_XQGZ2026051902289_01_1  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select par_month_id,serv_id,attr_id,attr_value1,modi_date 
from iodata_ods_month_city.rpt_comm_cm_prod_attr_mon 
where par_corp_id = '200' and par_month_id>=202301 and par_month_id<=202604 
and attr_id in (200009325  --合同正式编码
,200009323  --合同子编码
,200009326  --ICT合同名称
,200009324)  --ICT合同子项目名称 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026051902289_01 purge;
create table tmp_yz_XQGZ2026051902289_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,row_number() over(partition by par_month_id,serv_id,attr_id order by modi_date desc) pm 
from tmp_yz_XQGZ2026051902289_01_1 a ;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists ads_yz_XQGZ2026051902289_a_v_ht purge;
create table ads_yz_XQGZ2026051902289_a_v_ht 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b1.attr_value1 ht_nbr,b2.attr_value1 ht_name,b3.attr_value1 zht_nbr,b4.attr_value1 zht_name 
from ads_XQGZ2026051902289_a_v_list a 
left join tmp_yz_XQGZ2026051902289_01 b1 
on date_format(a.act_date,'yyyyMM')=b1.par_month_id and a.serv_id=b1.serv_id and b1.attr_id=200009325 and b1.pm=1 
left join tmp_yz_XQGZ2026051902289_01 b2 
on date_format(a.act_date,'yyyyMM')=b2.par_month_id and a.serv_id=b2.serv_id and b2.attr_id=200009326 and b2.pm=1
left join tmp_yz_XQGZ2026051902289_01 b3 
on date_format(a.act_date,'yyyyMM')=b3.par_month_id and a.serv_id=b3.serv_id and b3.attr_id=200009323 and b3.pm=1 
left join tmp_yz_XQGZ2026051902289_01 b4 
on date_format(a.act_date,'yyyyMM')=b4.par_month_id and a.serv_id=b4.serv_id and b4.attr_id=200009324 and b4.pm=1 
;

--20260526  张雯  拆机酒宽匹入网时间
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_liq_jk_01 purge;
create table tmp_yz_liq_jk_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.index1 xuhao ,a.index2 acc_nbr,b.open_date 
from zone_gz_yz_3351225714708480 a 
left join dwm_yz_tb_comm_cm_all_mon_final b on a.index2=b.acc_nbr and b.par_month_id=202312 
;

--20260527  XQGZ2026052602850 需求标题 关于黄埔提取特定快捷宽带信息的需求 
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026052602850_01 purge;
create table tmp_yz_XQGZ2026052602850_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id,acc_nbr 
from dwd_yz_rpt_comm_cm_msdisc_final a 
where  par_corp_id='200'
and prod_offer_id=500046067 group by serv_id,acc_nbr;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026052602850_02 purge;
create table tmp_yz_XQGZ2026052602850_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.z_prod_inst_id kjkd_z 
from tmp_yz_XQGZ2026052602850_01 a 
left join dws_crm_cust.dws_prod_inst_rel_a b on b.city_id='200' and cast(a.serv_id as string)=b.a_prod_inst_id;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026052602850_03 purge;
create table tmp_yz_XQGZ2026052602850_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.z_prod_inst_id kjkd_z_grp 
from tmp_yz_XQGZ2026052602850_02 a 
left join dws_crm_cust.dws_prod_inst_rel_grp_a b on b.city_id=200 and cast(a.serv_id as string)=b.a_prod_inst_id
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026052602850_03 purge;
create table tmp_yz_XQGZ2026052602850_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select acc_nbr,count(distinct kjkd_z) z_nums from tmp_yz_XQGZ2026052602850_02  
group by acc_nbr having count(distinct kjkd_z)=0 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_XQGZ2026052602850_04 purge;
create table tmp_yz_XQGZ2026052602850_04 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.subst_name,b.cust_nbr 
,b.sales_name
,b.sales_code
,b.channel_name from tmp_yz_XQGZ2026052602850_03 a 
left join dwm_yz_tb_comm_cm_all_final b on b.par_month_id=202605 and a.acc_nbr=b.acc_nbr 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists ads_yz_XQGZ2026052602850_list purge;
create table ads_yz_XQGZ2026052602850_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select acc_nbr,cust_nbr,sales_name,sales_code,channel_name from tmp_yz_XQGZ2026052602850_04 where subst_name='黄埔分公司' 
group by acc_nbr,cust_nbr,sales_name,sales_code,channel_name ;

--20260601  省高套通报数据核查，单移合约高套骤降是因为拆机还是转融合但融合积分不达高套



,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=4 and PROD_TYPE_GT=3 
		and OPEN_DATE= '20260529' then DISC_SCORE_RATIO else 0 end) d4 --新入网高套(移动)
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=4 and PROD_TYPE_GT=3 then DISC_SCORE_RATIO else 0 end) m4 --新入网高套(移动)
from tmp_sgs_531_list where day_id=20260529

select *  from summary_ods_tyks_city.TB_TYKS_GT_NEW_LIST_D where par_corp_id=200 and day_id=20260315





高套模型的这个融合ID有做过特殊处理
select SERV_ID
,case when MSINFO_ID is null then NEW_MIX_TYPE_RELAT_ID else NEW_MIX_TYPE_RELAT_ID||MSINFO_ID end as NEW_MIX_TYPE_RELAT_ID
from summary_ods_day_city.TB_LAB_CM_NEW_MIX_TYPE
where PAR_CORP_ID='#corp_id'

建议通过高套的serv_id到
summary_ods_day_city.tb_lab_cm_new_mix_type
这张表找到NEW_MIX_TYPE_RELAT_ID，然后在跟进NEW_MIX_TYPE_RELAT_ID找到相应的融合套餐所有号码。
select * from  summary_ods_day_city.tb_lab_cm_new_mix_type 
where NEW_MIX_TYPE_RELAT_ID in (select NEW_MIX_TYPE_RELAT_ID from  summary_ods_day_city.tb_lab_cm_new_mix_type where serv_id =123434; )
################################################################

drop table if exists tmp_yz_sheng_dyhy_hc_01 purge;
create table tmp_yz_sheng_dyhy_hc_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select SERV_ID
,case when MSINFO_ID is null then NEW_MIX_TYPE_RELAT_ID else NEW_MIX_TYPE_RELAT_ID||MSINFO_ID end as NEW_MIX_TYPE_RELAT_ID
from summary_ods_day_city.TB_LAB_CM_NEW_MIX_TYPE
where PAR_CORP_ID='200';

drop table if exists tmp_yz_sheng_dyhy_hc_02 purge;
create table tmp_yz_sheng_dyhy_hc_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select a.*,b.NEW_MIX_TYPE_RELAT_ID NEW_MIX_TYPE_RELAT_ID_v2
from summary_ods_tyks_city.TB_TYKS_GT_NEW_LIST_D a 
left join tmp_yz_sheng_dyhy_hc_01 b on a.serv_id=b.serv_id 
where a.par_corp_id=200 and a.day_id>=20260501 and a.day_id<=20260529 
;

drop table if exists tmp_yz_sheng_dyhy_hc_03 purge;
create table tmp_yz_sheng_dyhy_hc_03  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as
select * from tmp_yz_sheng_dyhy_hc_03_20260501 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260502 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260503 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260504 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260505 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260506 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260507 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260508 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260509 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260510 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260511 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260512 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260513 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260514 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260515 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260516 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260517 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260518 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260519 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260520 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260521 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260522 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260523 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260524 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260525 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260526 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260527 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260528 
 union all 
select * from tmp_yz_sheng_dyhy_hc_03_20260529 
;

--29号数据
drop table if exists tmp_yz_sheng_dyhy_hc_04_1 purge;
create table tmp_yz_sheng_dyhy_hc_04_1  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select *
,case when DISC_ROW_NUM=1 and NEW_GT_TYPE=1 and PROD_TYPE_GT=1 then '融合高套'
      when DISC_ROW_NUM=1 and NEW_GT_TYPE=4 and PROD_TYPE_GT=3 then '单移高套'
          else '' end gt_type
from tmp_yz_sheng_dyhy_hc_03 where day_id=20260529
;

--20260501-20260529新入网单移合约高套
drop table if exists tmp_yz_sheng_dyhy_hc_04 purge;
create table tmp_yz_sheng_dyhy_hc_04  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select * from tmp_yz_sheng_dyhy_hc_03 
where DISC_ROW_NUM=1 and NEW_GT_TYPE=4 and PROD_TYPE_GT=3 
and OPEN_DATE=sum_Date  
;


--打标5月单移合约在20260529的融合积分
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_yz_sheng_dyhy_hc_05 purge;
create table tmp_yz_sheng_dyhy_hc_05  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as 
select a.* 
,case when b.serv_id is not null then 1 
        when c.NEW_MIX_TYPE_RELAT_ID_v2 is not null then 2 else 0 end is_dy_rh_29  --29号是单移/融合/拆机 
,case when b.serv_id is not null then b.DISC_NEW_SCORE 
        when c.NEW_MIX_TYPE_RELAT_ID_v2 is not null then c.DISC_NEW_SCORE else 0 end DISC_NEW_SCORE_29  --积分 
,case when b.serv_id is not null then b.DISC_SCORE_RATIO 
        when c.NEW_MIX_TYPE_RELAT_ID_v2 is not null then c.DISC_SCORE_RATIO else 0 end DISC_SCORE_RATIO_29  --折算 
from tmp_yz_sheng_dyhy_hc_04 a 
left join (select *  from tmp_yz_sheng_dyhy_hc_04_1 where day_id=20260529 and gt_type in ('融合高套','单移高套')) b on a.serv_id=b.serv_id 
left join (select *  from tmp_yz_sheng_dyhy_hc_04_1 where day_id=20260529 and gt_type in ('融合高套','单移高套')) c on a.NEW_MIX_TYPE_RELAT_ID_v2=c.NEW_MIX_TYPE_RELAT_ID
;


drop table if exists tmp_yz_sheng_dyhy_hc_06 purge;
create table tmp_yz_sheng_dyhy_hc_06  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select is_dy_rh_29,acc_nbr,serv_id,DISC_NEW_SCORE,DISC_NEW_SCORE_29,DISC_SCORE_RATIO,DISC_SCORE_RATIO_29 
from tmp_yz_sheng_dyhy_hc_05 where is_dy_rh_29<>1 ;

drop table if exists tmp_yz_sheng_dyhy_hc_07 purge;
create table tmp_yz_sheng_dyhy_hc_07  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select is_dy_rh_29,acc_nbr,serv_id,DISC_NEW_SCORE,DISC_NEW_SCORE_29,DISC_SCORE_RATIO,DISC_SCORE_RATIO_29 
,row_number() over(order by serv_id) paixu  
from tmp_yz_sheng_dyhy_hc_06 ;

-- use zone_gz_yz;
-- set hive.vectorized.execution.enabled=false;
-- set hive.vectorized.execution.reduce.enabled=false;
-- set hive.auto.convert.join=false;
-- set hive.map.aggr=false;
-- drop table if exists tmp_yz_sheng_dyhy_hc_03_20260501;
-- create table tmp_yz_sheng_dyhy_hc_03_20260501 as 
-- select a.*
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.PROD_TYPE_GT order by a.OPEN_DATE desc,a.RHZX_ZK_OPEN_DATE desc,a.XSP_CREATE_DATE desc) as DISC_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID order by a.XSP_CREATE_DATE desc) as slw_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.ZQTG_PROD_TYPE order by a.OPEN_DATE desc) as ZQTG_ROW_NUM 
-- from 
-- (
 -- select *
-- ,case when PROD_TYPE=40 and PROD_ID<> 600039000 then 1 
 -- when (PROD_TYPE in (60,70) or PROD_ID in (600039000,600041009)) then 2 when PROD_TYPE=30 then 3 
 -- else -1 end as PROD_TYPE_GT 
 -- from tmp_yz_sheng_dyhy_hc_02 
-- where par_corp_id=200 and day_id=20260501) a
-- ;

-- use zone_gz_yz;
-- set hive.vectorized.execution.enabled=false;
-- set hive.vectorized.execution.reduce.enabled=false;
-- set hive.auto.convert.join=false;
-- set hive.map.aggr=false;
-- drop table if exists tmp_yz_sheng_dyhy_hc_03_20260502;
-- create table tmp_yz_sheng_dyhy_hc_03_20260502 as 
-- select a.*
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.PROD_TYPE_GT order by a.OPEN_DATE desc,a.RHZX_ZK_OPEN_DATE desc,a.XSP_CREATE_DATE desc) as DISC_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID order by a.XSP_CREATE_DATE desc) as slw_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.ZQTG_PROD_TYPE order by a.OPEN_DATE desc) as ZQTG_ROW_NUM 
-- from 
-- (
 -- select *
-- ,case when PROD_TYPE=40 and PROD_ID<> 600039000 then 1 
 -- when (PROD_TYPE in (60,70) or PROD_ID in (600039000,600041009)) then 2 when PROD_TYPE=30 then 3 
 -- else -1 end as PROD_TYPE_GT 
 -- from tmp_yz_sheng_dyhy_hc_02 
-- where par_corp_id=200 and day_id=20260502) a
-- ;

-- use zone_gz_yz;
-- set hive.vectorized.execution.enabled=false;
-- set hive.vectorized.execution.reduce.enabled=false;
-- set hive.auto.convert.join=false;
-- set hive.map.aggr=false;
-- drop table if exists tmp_yz_sheng_dyhy_hc_03_20260503;
-- create table tmp_yz_sheng_dyhy_hc_03_20260503 as 
-- select a.*
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.PROD_TYPE_GT order by a.OPEN_DATE desc,a.RHZX_ZK_OPEN_DATE desc,a.XSP_CREATE_DATE desc) as DISC_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID order by a.XSP_CREATE_DATE desc) as slw_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.ZQTG_PROD_TYPE order by a.OPEN_DATE desc) as ZQTG_ROW_NUM 
-- from 
-- (
 -- select *
-- ,case when PROD_TYPE=40 and PROD_ID<> 600039000 then 1 
 -- when (PROD_TYPE in (60,70) or PROD_ID in (600039000,600041009)) then 2 when PROD_TYPE=30 then 3 
 -- else -1 end as PROD_TYPE_GT 
 -- from tmp_yz_sheng_dyhy_hc_02 
-- where par_corp_id=200 and day_id=20260503) a
-- ;

-- use zone_gz_yz;
-- set hive.vectorized.execution.enabled=false;
-- set hive.vectorized.execution.reduce.enabled=false;
-- set hive.auto.convert.join=false;
-- set hive.map.aggr=false;
-- drop table if exists tmp_yz_sheng_dyhy_hc_03_20260504;
-- create table tmp_yz_sheng_dyhy_hc_03_20260504 as 
-- select a.*
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.PROD_TYPE_GT order by a.OPEN_DATE desc,a.RHZX_ZK_OPEN_DATE desc,a.XSP_CREATE_DATE desc) as DISC_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID order by a.XSP_CREATE_DATE desc) as slw_ROW_NUM
-- ,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.ZQTG_PROD_TYPE order by a.OPEN_DATE desc) as ZQTG_ROW_NUM 
-- from 
-- (
 -- select *
-- ,case when PROD_TYPE=40 and PROD_ID<> 600039000 then 1 
 -- when (PROD_TYPE in (60,70) or PROD_ID in (600039000,600041009)) then 2 when PROD_TYPE=30 then 3 
 -- else -1 end as PROD_TYPE_GT 
 -- from tmp_yz_sheng_dyhy_hc_02 
-- where par_corp_id=200 and day_id=20260504) a
-- ;

--20260603  省高套通报数据-政企团购（政企折算）
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists tmp_sgs_531_list;
create table tmp_sgs_531_list as 
select a.*
,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.PROD_TYPE_GT order by a.OPEN_DATE desc,a.RHZX_ZK_OPEN_DATE desc,a.XSP_CREATE_DATE desc) as DISC_ROW_NUM
,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID order by a.XSP_CREATE_DATE desc) as slw_ROW_NUM
,row_number() over(partition by a.NEW_MIX_TYPE_RELAT_ID,a.ZQTG_PROD_TYPE order by a.OPEN_DATE desc) as ZQTG_ROW_NUM 
from 
(
 select *
,case when PROD_TYPE=40 and PROD_ID<> 600039000 then 1 
 when (PROD_TYPE in (60,70) or PROD_ID in (600039000,600041009)) then 2 when PROD_TYPE=30 then 3 
 else -1 end as PROD_TYPE_GT 
 from  summary_ods_tyks_city.TB_TYKS_GT_NEW_LIST_D
where par_corp_id=200 and day_id=20260531) a
;


select 
 (d1+d2+d3+d4+d5+d6) d0 --日新入网高套
,d1,d2,d3,d4,d5,d6
,(m1+m2+m3+m4+m5+m6) m0 --月新入网高套
,m1,m2,m3,m4,m5,m6
from(
select 
--日
 SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=1 and PROD_TYPE_GT=1 and OPEN_DATE= '20260531' then DISC_SCORE_RATIO else 0 end) d1 --新入网高套(宽带)
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=2 and PROD_TYPE_GT=2 and OPEN_DATE= '20260531' then DISC_SCORE_RATIO else 0 end) d2 --新入网高套(融合专线) 
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=3 and PROD_TYPE_GT=2 and OPEN_DATE= '20260531' then DISC_SCORE_RATIO else 0 end) d3 --新入网高套(单品专线)
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=4 and PROD_TYPE_GT=3 and OPEN_DATE= '20260531' then DISC_SCORE_RATIO else 0 end) d4 --新入网高套(移动)
,SUM(case when SLW_ROW_NUM=1 and NEW_GT_TYPE=5 and  XSP_CREATE_DATE= '20260531' and DISC_NEW_SCORE>=10 then DISC_SCORE_RATIO else 0 end) d5 --新入网高套(智家)
,SUM(case when ZQTG_ROW_NUM=1 and NEW_GT_TYPE=6 and DISC_SCORE_RATIO>0 and OPEN_DATE= '20260531' then DISC_SCORE_RATIO else 0 end) d6 --新入网高套(政企折算)
--月
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=1 and PROD_TYPE_GT=1 then DISC_SCORE_RATIO else 0 end) m1 --新入网高套(宽带)
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=2 and PROD_TYPE_GT=2 then DISC_SCORE_RATIO else 0 end) m2 --新入网高套(融合专线) 
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=3 and PROD_TYPE_GT=2 then DISC_SCORE_RATIO else 0 end) m3 --新入网高套(单品专线)
,SUM(case when DISC_ROW_NUM=1 and NEW_GT_TYPE=4 and PROD_TYPE_GT=3 then DISC_SCORE_RATIO else 0 end) m4 --新入网高套(移动)
,SUM(case when SLW_ROW_NUM=1 and NEW_GT_TYPE=5 and  XSP_CREATE_DATE>='20260501' and XSP_CREATE_DATE<='20260531' and DISC_NEW_SCORE>=10 then DISC_SCORE_RATIO else 0 end) m5 --新入网高套(智家)
,SUM(case when ZQTG_ROW_NUM=1 and NEW_GT_TYPE=6 and DISC_SCORE_RATIO>0 then DISC_SCORE_RATIO else 0 end) m6 --新入网高套(政企折算)
from tmp_sgs_531_list where day_id=20260531
) a
;

--20260603  谢蕴秀  取5月的融合宽带（新宽新移和新宽老移），
--然后给这些宽带打标是否办了这些销售品，输出有叠加670的宽带数和宽带套餐价值加分
DM0001-670-1-3宽带套餐合约折扣特惠_3个月
DM0001-670-1-2宽带套餐合约折扣特惠_2个月
DM0001-670-1-1宽带套餐合约折扣特惠_1个月
DM0001-670-1-4宽带套餐合约折扣特惠_6个月
DM0001-670-1-5宽带套餐合约折扣特惠_9个月

select distinct offer_id,prod_offer_code 
from dws_crm_cfguse.dws_offer where city_id=200 
and prod_offer_code in('DM0001-670-1-3','DM0001-670-1-2','DM0001-670-1-1','DM0001-670-1-4','DM0001-670-1-5')

offer_id	prod_offer_code
100087861	DM0001-670-1-3
100087819	DM0001-670-1-1
100087860	DM0001-670-1-2
500038014	DM0001-670-1-4
500038015	DM0001-670-1-5

drop table tmp_yz_liq_xyx_01 purge;
create table tmp_yz_liq_xyx_01  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select date_format(a.subs_stat_date,'yyyyMM') sl_month,a.prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_final a 
where a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') = '202605' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(100087861,100087819,100087860,500038014,500038015)  

union all 
select date_format(a.subs_stat_date,'yyyyMM') sl_month,a.prod_offer_id,a.serv_id 
from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
where a.subs_stat = '301200'  --已竣工
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300')  --非撤单、非作废
and date_format(a.subs_stat_date,'yyyyMM') = '202605' --写当前月
and a.action_id in( 1292,6200 ) --销售品订购和更换
and a.prod_offer_id in(100087861,100087819,100087860,500038014,50优惠资料表中包含了当月已使用的套餐。也就是说，无论是否归档，只要用户已经入网并开始使用，就会记录在内。这是因为需求是提取5月份已经办理的销售产品。0038015) 
; 

drop table tmp_yz_liq_xyx_02 purge;
create table tmp_yz_liq_xyx_02  
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as  
select a.par_month_id,rh_tc_id,rh_tc_value  
from dwm_yz_tb_comm_cm_all_mon_final a 
left join (select sl_month,serv_id from tmp_yz_liq_xyx_01  group by sl_month,serv_id) b 
on a.par_month_id=b.sl_month and a.serv_id=b.serv_id 
where b.serv_id is not null and a.par_month_id=202605 
and a.rh_type_ykj in('新宽带新移动','新宽带老移动')
group by a.par_month_id,rh_tc_id,rh_tc_value 
;

select par_month_id,count(distinct rh_tc_id) rh_1,count(rh_tc_id) rh_2,sum(rh_tc_value) jf 
from tmp_yz_liq_xyx_02 group by par_month_id order by par_month_id 





--20260604  XQGZ2026052701809 梁俊杰
-- 提取口径：
-- 产品名：企智通
-- 产品CRM编码：SWDCP
-- 附属产品CRM编码：SWLH067

create table tmp_yz_wplg_all_dim 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 
 index1 zh_type
,cast(index2 as int) zh_px
,index3 prod_sys_nbr
,b1.prod_id 
,b1.prod_name 
,index4 sub_prod_sys_nbr
,b2.prod_id  sub_prod_id
,b2.prod_name sub_prod_name
,index5 attr_inner_cd
,index6
,b3.attr_id
,b3.attr_name
,b4.attr_inner_value
,b4.attr_value_name
,index7

,case when b2.prod_id is not null and b4.attr_inner_value is not null then 11
      when b2.prod_id is not null and b3.attr_id is not null then 12
      when b2.prod_id is not null then 13
      when b4.attr_inner_value is not null then 21
      when b3.attr_id is not null then 22
      else 0 end zh_lx
      
from zone_gz_yz_3351225714708480 a
left join dws_crm_cfguse.dws_product b1
on a.index3=b1.prod_sys_nbr
left join dws_crm_cfguse.dws_product b2
on a.index4=b2.prod_sys_nbr
left join dws_crm_cfguse.dws_attr_spec b3
on a.index5=b3.attr_inner_cd
left join (select * from dws_crm_cfguse.dws_attr_value where city_id='200') b4
on a.index7=(b4.attr_inner_value||'='||b4.attr_value_name) and b3.attr_id=b4.attr_id
;

--主流程
use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--抽取附属产品
drop table if exists tmp_dwd_yz_wplg_subserv;
create table tmp_dwd_yz_wplg_subserv 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select cast(a.par_month_id as string) par_month_id,a.serv_id,a.prod_id,a.sub_prod_id,a.attr_id,a.attr_value1
,state_date create_date --订购时间
from iodata_ods_month_city.rpt_comm_cm_subserv_mon a --附属产品资料表 月表
where a.par_corp_id=200 and a.par_month_id>=202301 and a.par_month_id<=202604 
and prod_id=803 and sub_prod_id=8066 

union all 
select cast(202605 as string) par_month_id,a.serv_id,a.prod_id,a.sub_prod_id,a.attr_id,a.attr_value1
,state_date create_date --订购时间
from summary_ods_day_city.rpt_comm_cm_subserv a --附属产品资料表 日表
where a.par_corp_id=200  
and prod_id=803 and sub_prod_id=8066 
;


drop table if exists tmp_dwd_yz_wplg_0_13;
create table tmp_dwd_yz_wplg_0_13 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id,a.par_month_id,a.create_date,b.*
from tmp_dwd_yz_wplg_subserv a
join tmp_yz_wplg_all_dim b
on a.prod_id=b.prod_id and a.sub_prod_id=b.sub_prod_id
where b.zh_lx=13
;


--汇总(移动保密通讯：tmp_dwd_yz_wplg_0)
drop table if exists tmp_dwd_yz_wplg_all_0;
create table tmp_dwd_yz_wplg_all_0 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select * from tmp_dwd_yz_wplg_0_13
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--打标号码标签
drop table if exists tmp_yz_wplg_all_final;
create table tmp_yz_wplg_all_final 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,b.cust_nbr,b.cust_name,b.acc_nbr,b.state,b.subst_id,b.subst_name,b.branch_id,b.branch_name
,b.bg_type,b.bu_type,b.sales_id,b.sales_code,b.sales_name,b.staff_id  
from tmp_dwd_yz_wplg_all_0 a
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=a.par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--打标号码标签
drop table if exists tmp_yz_wplg_all_XQGZ2026052701809;
create table tmp_yz_wplg_all_XQGZ2026052701809 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,d.own_org_name sales_org_name,c.sales_code staff_man_nbr
,c.sales_man_name staff_man_name,c.own_org_name staff_org_name  
from tmp_yz_wplg_all_final a 
left join dwd_yz_sales_man_outlers_mon_final c on a.staff_id=c.staff_id and a.par_month_id=c.par_month_id
left join dwd_yz_sales_man_outlers_mon_final d on a.sales_id=d.staff_id and a.par_month_id=d.par_month_id
;

--打标状态中文名称
drop table if exists  tmp_yz_XQGZ2025122201391_01 purge;
create table tmp_yz_XQGZ2025122201391_01 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,b.attr_value_name as state_desc
from tmp_yz_wplg_all_XQGZ2026052701809 a 
left join dws_crm_cfguse.dws_attr_value b on a.state=b.attr_value and b.city_id='200' and b.attr_id='4000000201'
; 

--a端号码（只有当前数据，没有历史数据）
drop table if exists  tmp_yz_XQGZ2025122201391_02 purge;
create table tmp_yz_XQGZ2025122201391_02 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.a_prod_inst_id 
from tmp_yz_XQGZ2025122201391_01 a 
left join dws_crm_cust.dws_prod_inst_rel_grp_a b on b.city_id=200 and cast(a.serv_id as string)=b.z_prod_inst_id 
where COALESCE(a.prod_sys_nbr,'-1') in('YDYDCP16')  
union all 
select a.*,cast(null as string) a_prod_inst_id 
from tmp_yz_XQGZ2025122201391_01 a  
where COALESCE(a.prod_sys_nbr,'-1') not in('YDYDCP16') 
;

--结算账号
drop table if exists  tmp_yz_XQGZ2025122201391_03 purge;
create table tmp_yz_XQGZ2025122201391_03 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,case when COALESCE(a.prod_sys_nbr,'-1') not in('YDYDCP16') then a.acc_nbr 
	when COALESCE(a.prod_sys_nbr,'-1') in('YDYDCP16') and b.acc_nbr is not null then b.acc_nbr else null end as js_acc_nbr
,case when COALESCE(a.prod_sys_nbr,'-1') not in('YDYDCP16') then a.serv_id 
	when COALESCE(a.prod_sys_nbr,'-1') in('YDYDCP16') and b.acc_nbr is not null then b.serv_id else null end as js_serv_id
from tmp_yz_XQGZ2025122201391_02 a 
left join dwm_yz_tb_comm_cm_all_final b on a.a_prod_inst_id=b.serv_id and b.par_month_id=202605
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists  tmp_yz_XQGZ2025122201391_05 purge;
create table tmp_yz_XQGZ2025122201391_05 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.subst_name as js_subst_name 
from tmp_yz_XQGZ2025122201391_03 a 
left join dwm_yz_tb_comm_cm_all_mon_final b 
on a.js_serv_id=b.serv_id and a.par_month_id = b.par_month_id;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists  tmp_yz_XQGZ2025122201391_06_1 purge;
create table tmp_yz_XQGZ2025122201391_06_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select serv_id,par_month_id,hist_create_date cancel_date 
from dwm_yz_tb_comm_cm_all_mon_final 
where par_month_id>=202201 and par_month_id<=202604 and is_cancel_user=1 
union all 
select serv_id,par_month_id,hist_create_date cancel_date 
from dwm_yz_tb_comm_cm_all_final 
where par_month_id=202605 and is_cancel_user=1 ;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists  tmp_yz_XQGZ2025122201391_06 purge;
create table tmp_yz_XQGZ2025122201391_06 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,row_number() over(partition by serv_id order by par_month_id desc) paixu from tmp_yz_XQGZ2025122201391_06_1 a;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists  tmp_yz_XQGZ2025122201391_07 purge;
create table tmp_yz_XQGZ2025122201391_07 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.cancel_date
,case 
when b.cancel_date is not null then 
	cast(Datediff(date_format(a.create_date,'yyyy-MM-dd'),date_format(b.cancel_date,'yyyy-MM-dd')) as int) 
when c.serv_id is not null then 
	cast(Datediff(date_format(a.create_date,'yyyy-MM-dd'),date_format(current_timestamp(),'yyyy-MM-dd')) as int) 
else null end zw_days  
from tmp_yz_XQGZ2025122201391_05 a 
left join tmp_yz_XQGZ2025122201391_06 b on a.serv_id=b.serv_id and b.paixu=1 
left join dwm_yz_tb_comm_cm_all_final c on a.serv_id=c.serv_id and c.par_month_id=202605 and c.is_cancel_user=0 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--出账收入
drop table if exists tmp_yz_XQGZ2025122201391_08;
create table tmp_yz_XQGZ2025122201391_08 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.*,fee 
from tmp_yz_XQGZ2025122201391_07 a
left join dwm_yz_tb_comm_cm_all_mon_final b on a.serv_id=b.serv_id and b.par_month_id=a.par_month_id 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--欠费
drop table if exists tmp_yz_XQGZ2025122201391_09;
create table tmp_yz_XQGZ2025122201391_09 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select 
serv_id
,sum(qf_fee) qf -- 欠费金额，单位：元
from  zone_gz_yz.ads_ys_lst_qf_pushdata_daily_bss 
where stat_date_id=20260527 --统计时点 
group by serv_id 
;

drop table if exists  tmp_yz_XQGZ2026052701809_all_list purge;
create table tmp_yz_XQGZ2026052701809_all_list 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as  
select a.*,case when b.qf>0 then '是' else '否' end is_qf,b.qf 
from tmp_yz_XQGZ2025122201391_08 a left join tmp_yz_XQGZ2025122201391_09 b on a.serv_id=b.serv_id;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists  tmp_yz_XQGZ2025122201391_04_1 purge;
create table tmp_yz_XQGZ2025122201391_04_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,serv_id,due_income_code,due_income_name,fee_all
from zone_gz_yz.dwm_srhx_src_income_list_mon
where  par_month_id>=202201 and  par_month_id<=202604
and contract_flag=1 --划小收入
and flag=1  --号码级收入（比如漫游是出在虚拟号码上的收入，会落到分局，但不是真实号码）
and is_filter='0' --考核收入 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists  tmp_yz_XQGZ2025122201391_04 purge;
create table tmp_yz_XQGZ2025122201391_04 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select par_month_id,serv_id,due_income_code,due_income_name,sum(fee_all) as fee_sh
from tmp_yz_XQGZ2025122201391_04_1 
group by par_month_id,serv_id,due_income_code,due_income_name ;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
drop table if exists  tmp_yz_XQGZ2025122201391_11 purge;
create table tmp_yz_XQGZ2025122201391_11 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.fee_sh,b.due_income_code,b.due_income_name  
from tmp_yz_XQGZ2026052701809_all_list a 
left join tmp_yz_XQGZ2025122201391_04 b 
on a.js_serv_id=b.serv_id and a.par_month_id=b.par_month_id;

--20260311  补打非YDDH产品的揽装人，按微派号码揽装人
--a端号码（只有当前数据，没有历史数据）
drop table if exists  tmp_yz_XQGZ2025122201391_12_1 purge;
create table tmp_yz_XQGZ2025122201391_12_1 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.a_prod_inst_id,a.z_prod_inst_id,a.create_date
from dws_crm_cust.dws_prod_inst_rel_grp_a a 
left join dwm_yz_tb_comm_cm_all_final b on a.a_prod_inst_id=cast(b.serv_id as string) and b.par_month_id=202605
where a.city_id=200 and b.prod_id in(2375) 
;

drop table if exists  tmp_yz_XQGZ2025122201391_12_2 purge;
create table tmp_yz_XQGZ2025122201391_12_2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.* 
,row_number() over(partition by z_prod_inst_id order by create_date desc ) paixu 
from tmp_yz_XQGZ2025122201391_12_1 a ;

drop table if exists  tmp_yz_XQGZ2025122201391_12 purge;
create table tmp_yz_XQGZ2025122201391_12 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.*,b.a_prod_inst_id as wp_serv_id 
from tmp_yz_XQGZ2025122201391_11 a 
left join tmp_yz_XQGZ2025122201391_12_2 b on cast(a.serv_id as string)=b.z_prod_inst_id and b.paixu=1 
where COALESCE(a.prod_sys_nbr,'-1') not in('YDYDCP16')  
;

--微派号码揽装人
drop table if exists  tmp_yz_XQGZ2025122201391_13 purge;
create table tmp_yz_XQGZ2025122201391_13 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
as 
select a.serv_id,a.par_month_id,a.create_date,a.zh_type,a.zh_px,a.prod_sys_nbr,a.prod_id
,a.prod_name,a.sub_prod_sys_nbr,a.sub_prod_id,a.sub_prod_name,a.attr_inner_cd,a.index6
,a.attr_id,a.attr_name,a.attr_inner_value,a.attr_value_name,a.index7,a.zh_lx,a.cust_nbr
,a.cust_name,a.acc_nbr,a.state,a.subst_id,a.subst_name,a.branch_id,a.branch_name,a.bg_type,a.bu_type
,case when a.wp_serv_id is not null then b.sales_id else a.sales_id end sales_id 
,case when a.wp_serv_id is not null then b.sales_code else a.sales_code end sales_code 
,case when a.wp_serv_id is not null then b.sales_name else a.sales_name end sales_name 
,a.staff_id,a.sales_org_name,a.staff_man_nbr
,a.staff_man_name,a.staff_org_name,a.state_desc,a.a_prod_inst_id,a.js_acc_nbr,a.js_serv_id
,a.js_subst_name,a.cancel_date,a.zw_days,a.fee,a.is_qf,a.qf,a.fee_sh,a.due_income_code
,a.due_income_name,a.wp_serv_id  
from tmp_yz_XQGZ2025122201391_12 a 
left join dwm_yz_tb_comm_cm_all_final b on a.wp_serv_id=cast(b.serv_id as string) and b.par_month_id=202605
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--微派号码揽装人机构
drop table if exists tmp_yz_XQGZ2025122201391_14;
create table tmp_yz_XQGZ2025122201391_14 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id,a.par_month_id,a.create_date,a.zh_type,a.zh_px,a.prod_sys_nbr
,a.prod_id,a.prod_name,a.sub_prod_sys_nbr,a.sub_prod_id,a.sub_prod_name
,a.attr_inner_cd,a.index6,a.attr_id,a.attr_name,a.attr_inner_value,a.attr_value_name
,a.index7,a.zh_lx,a.cust_nbr,a.cust_name,a.acc_nbr,a.state,a.subst_id,a.subst_name,a.branch_id
,a.branch_name,a.bg_type,a.bu_type,a.sales_id,a.sales_code,a.sales_name,a.staff_id
,case when a.wp_serv_id is not null then d.own_org_name else a.sales_org_name end sales_org_name 
,a.staff_man_nbr,a.staff_man_name,a.staff_org_name,a.state_desc,a.a_prod_inst_id,a.js_acc_nbr
,a.js_serv_id,a.js_subst_name,a.cancel_date,a.zw_days,a.fee,a.is_qf,a.qf,a.fee_sh,a.due_income_code
,a.due_income_name,a.wp_serv_id 
from tmp_yz_XQGZ2025122201391_13 a 
left join dwd_yz_sales_man_outlers_mon_final d on a.sales_id=d.staff_id and a.par_month_id=d.par_month_id
;

--微派订单
drop table if exists tmp_yz_XQGZ2025122201391_15;
create table tmp_yz_XQGZ2025122201391_15 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.par_month_id,a.subs_id,a.serv_id 
,a.salestaff_id,a.sales_code
,a.sales_man_name,a.action_type,a.subs_stat_date,b.action_name
,row_number() over(partition by a.par_month_id,a.serv_id order by a.subs_stat_date desc) paixu 
from dwm_yz_rpt_comm_ba_subs_mon_final a 
left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
on a.action_id=b.action_id 
where b.action_name like '中国电信移动电话变更(加入微派%'  
and a.subs_stat in('301200') 
and COALESCE(a.subs_stat_reason,'-1') not in('1200','1300') 
;

--按微派订单补打揽装
drop table if exists tmp_yz_XQGZ2025122201391_16;
create table tmp_yz_XQGZ2025122201391_16 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id,a.par_month_id,a.create_date,a.zh_type,a.zh_px,a.prod_sys_nbr,a.prod_id
,a.prod_name,a.sub_prod_sys_nbr,a.sub_prod_id,a.sub_prod_name,a.attr_inner_cd,a.index6
,a.attr_id,a.attr_name,a.attr_inner_value,a.attr_value_name,a.index7,a.zh_lx,a.cust_nbr
,a.cust_name,a.acc_nbr,a.state,a.subst_id,a.subst_name,a.branch_id,a.branch_name,a.bg_type,a.bu_type
,case when b.serv_id is not null then b.salestaff_id else a.sales_id end sales_id 
,case when b.serv_id is not null then b.sales_code else a.sales_code end sales_code 
,case when b.serv_id is not null then b.sales_man_name else a.sales_name end sales_name 
,a.staff_id,a.sales_org_name,a.staff_man_nbr
,a.staff_man_name,a.staff_org_name,a.state_desc,a.a_prod_inst_id,a.js_acc_nbr,a.js_serv_id
,a.js_subst_name,a.cancel_date,a.zw_days,a.fee,a.is_qf,a.qf,a.fee_sh,a.due_income_code
,a.due_income_name,a.wp_serv_id,b.subs_id  
from tmp_yz_XQGZ2025122201391_14 a 
left join tmp_yz_XQGZ2025122201391_15 b on date_format(a.create_date,'yyyyMM')=b.par_month_id and a.serv_id=b.serv_id and b.paixu=1 
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--微派号码揽装人机构
drop table if exists tmp_yz_XQGZ2025122201391_17;
create table tmp_yz_XQGZ2025122201391_17 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select a.serv_id,a.par_month_id,a.create_date,a.zh_type,a.zh_px,a.prod_sys_nbr
,a.prod_id,a.prod_name,a.sub_prod_sys_nbr,a.sub_prod_id,a.sub_prod_name
,a.attr_inner_cd,a.index6,a.attr_id,a.attr_name,a.attr_inner_value,a.attr_value_name
,a.index7,a.zh_lx,a.cust_nbr,a.cust_name,a.acc_nbr,a.state,a.subst_id,a.subst_name,a.branch_id
,a.branch_name,a.bg_type,a.bu_type,a.sales_id,a.sales_code,a.sales_name,a.staff_id
,case when a.subs_id is not null then d.own_org_name else a.sales_org_name end sales_org_name 
,a.staff_man_nbr,a.staff_man_name,a.staff_org_name,a.state_desc,a.a_prod_inst_id,a.js_acc_nbr
,a.js_serv_id,a.js_subst_name,a.cancel_date,a.zw_days,a.fee,a.is_qf,a.qf,a.fee_sh,a.due_income_code
,a.due_income_name,a.wp_serv_id 
from tmp_yz_XQGZ2025122201391_16 a 
left join dwd_yz_sales_man_outlers_mon_final d on a.sales_id=d.staff_id and a.par_month_id=d.par_month_id
;

use zone_gz_yz;
set hive.vectorized.execution.enabled=false;
set hive.vectorized.execution.reduce.enabled=false;
set hive.auto.convert.join=false;
set hive.map.aggr=false;
--合并清单
drop table if exists tmp_yz_XQGZ2025122201391_11_v2;
create table tmp_yz_XQGZ2025122201391_11_v2 
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
as 
select serv_id,par_month_id,create_date,zh_type,zh_px,prod_sys_nbr,prod_id,prod_name
,sub_prod_sys_nbr,sub_prod_id,sub_prod_name,attr_inner_cd,index6,attr_id,attr_name
,attr_inner_value,attr_value_name,index7,zh_lx,cust_nbr,cust_name,acc_nbr,state,subst_id
,subst_name,branch_id,branch_name,bg_type,bu_type,sales_id,sales_code,sales_name,staff_id
,sales_org_name,staff_man_nbr,staff_man_name,staff_org_name,state_desc,a_prod_inst_id
,js_acc_nbr,js_serv_id,js_subst_name,cancel_date,zw_days,fee,is_qf,qf,fee_sh,due_income_code
,due_income_name,wp_serv_id 
from tmp_yz_XQGZ2025122201391_17 
union all 
select serv_id,par_month_id,create_date,zh_type,zh_px,prod_sys_nbr,prod_id,prod_name
,sub_prod_sys_nbr,sub_prod_id,sub_prod_name,attr_inner_cd,index6,attr_id,attr_name
,attr_inner_value,attr_value_name,index7,zh_lx,cust_nbr,cust_name,acc_nbr,state,subst_id
,subst_name,branch_id,branch_name,bg_type,bu_type,sales_id,sales_code,sales_name,staff_id
,sales_org_name,staff_man_nbr,staff_man_name,staff_org_name,state_desc,a_prod_inst_id
,js_acc_nbr,js_serv_id,js_subst_name,cancel_date,zw_days,fee,is_qf,qf,fee_sh,due_income_code
,due_income_name,cast(null as string) wp_serv_id 
from tmp_yz_XQGZ2025122201391_11 
where prod_sys_nbr='YDYDCP16' 
; 

alter table tmp_yz_XQGZ2025122201391_11_v2 rename to ads_yz_XQGZ2026052701809_list;