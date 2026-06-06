相关需求：
XQGZ2026060201738
/*
李俊华5：
WITH latest_order AS (
    SELECT *,
        row_number() OVER(PARTITION BY oa_code ORDER BY sa_at DESC) AS rn
    FROM dws_sy_znpt_cdsj_order_result
    WHERE oai_source IN ('电信到家', '存量工单', '场景化', '政企OAO')
                  AND oai_county_division <> '全渠中心'
        AND sa_at >= '2026-05-01'
)
SELECT
    oai_source,
                --工单来源
    oai_county_division,
                --县分
    COUNT(*) AS order_sum,
                --工单总数
    SUM(CASE WHEN oac_staff_type IS NOT NULL AND TRIM(oac_staff_type) <> '' THEN 1 ELSE 0 END) AS gdzhl,
                --转化量
    ROUND(
        SUM(CASE WHEN oac_staff_type IS NOT NULL AND TRIM(oac_staff_type) <> '' THEN 1 ELSE 0 END) 
        / COUNT(*), 4
    ) AS zhl,
                --转化率
    CONCAT_WS(',', 
        COLLECT_SET(
            CASE WHEN oac_staff_type IS NOT NULL AND TRIM(oac_staff_type) <> '' 
                 THEN oa_existing_access_number END
        )
    ) AS obj_code
                --对应接入号
FROM latest_order
WHERE rn = 1
GROUP BY oai_source, oai_county_division
参考"

李俊华5 6/3 16:03:43
取最新sa_at的那一条

张云娇 6/5 12:42:00
FROM zone_gz_sy.dws_sy_znpt_cdsj_order_result as b
WHERE oai_source IN ('电信到家', '存量工单', '场景化', '政企OAO')
  and oai_county_division <> '全渠中心'
  and date_format(sa_at,'yyyyMM')>=202601
   and b.oac_staff_type IS NOT NULL
  and TRIM(b.oac_staff_type) <> ''
  and b.oa_existing_access_number IS NOT NULL
  and TRIM(b.oa_existing_access_number) <> ''
这些条件统计，没有202601~202602，最早是202603

李俊华5 6/5 14:52:22
电信到家、政企OAO是新流程以后，才有oac_staff_type
旧流程（20260226）以前，都是使用oac_sj_staff_type
存量工单、场景化都是新流程的线索工单
所以这几个组合，使用oac_staff_type条件判断的话，最早是20260301开始有转化


*/

需求：
根据如上数据源，统计表中号码的价值积分、出账费用、佣金三个信息。
统计口径：
1、价值积分：统计入湖当月
2、出账费用：统计入湖当月至统计月的累计
3、佣金：统计入湖当月至统计月的累计

重复号码的取最新sa_at的那一条
=====================================================================
经沟通和核实，数据源不具备服务标识，只能用号码关联获取，忽略重放号等因素的影响问题。
202604为统计月为例取数如下：	
=====================================================================

--从 zone_gz_sy 授权表取来源订单打标取数序号标识
drop table if exists zone_gz_yz.tmp_XQGZ2026060201738_001 purge;
create table if not exists zone_gz_yz.tmp_XQGZ2026060201738_001
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select '202604' as stat_month--统计月份
    ,date_format(sa_at,'yyyyMM') as rh_month
    ,oa_code
    ,oai_source--工单来源
    ,oai_county_division--县分
    ,oa_existing_access_number--接入号
    ,TRIM(oa_existing_access_number) as access_code
    ,oac_staff_type
    ,oac_sj_staff_type--后面补
    ,sa_at--入湖时间
    ,row_number() OVER(PARTITION BY TRIM(oa_existing_access_number) ORDER BY sa_at DESC) as rn--由于接入号有重复。取sa_at最新一条对应的号码，原oa_code调整为oa_existing_access_number
FROM zone_gz_sy.dws_sy_znpt_cdsj_order_result--来源订单（zone_gz_sy 授权表）
WHERE oai_source IN ('电信到家', '存量工单', '场景化', '政企OAO')
  and oai_county_division <> '全渠中心'
  and date_format(sa_at,'yyyyMM')>='202601'--当年一月
  and date_format(sa_at,'yyyyMM')<='202604'--统计月份
  
  and ((oac_staff_type IS NOT NULL and TRIM(oac_staff_type) <> '')  
     or (oac_sj_staff_type is not null and trim(oac_sj_staff_type)<>''))--旧流程（20260226）以前，都是使用oac_sj_staff_type
  and oa_existing_access_number IS NOT NULL
  and TRIM(oa_existing_access_number) <> ''

;


--接入号明细
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_003 PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_003
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
SELECT distinct 
     b.stat_month
    ,b.rh_month
    ,b.oai_source--工单来源
    ,b.oai_county_division--县分
    ,b.access_code
FROM zone_gz_yz.tmp_XQGZ2026060201738_001 as b
WHERE b.stat_month='202604'
  and b.rn = 1
;


/*
李俊华5 6/5 14:52:22
电信到家、政企OAO是新流程以后，才有oac_staff_type
旧流程（20260226）以前，都是使用oac_sj_staff_type
存量工单、场景化都是新流程的线索工单
所以这几个组合，使用oac_staff_type条件判断的话，最早是20260301开始有转化
*/
;


--接入号唯一：由于之前口径提取的清单存在号码不唯一，先去重再获取各账期费用
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
SELECT access_code,max(rh_month) as max_rh_month
from zone_gz_yz.tmp_XQGZ2026060201738_003
where stat_month='202604'
group by access_code
;

/*
李俊华5 6/3 16:03:43
取最新sa_at的那一条
*/


--生产各月价值积分和出账费用到打标临时表
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_004 PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_004
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
SELECT '202604' as stat_month,a.serv_id,a.acc_nbr,a.par_month_id,a.jz_points,a.fee--价值积分\出账费用
FROM zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final as a
join zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only as b on a.acc_nbr=b.access_code
WHERE a.par_month_id>=b.max_rh_month
  and a.par_month_id<='202604'
;

--生产各月佣金到打标临时表
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_005 PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_005
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
select '202604' as stat_month,a.serv_id,a.acc_nbr
,cast(substr(a.billing_cycle_id,1,6 ) as int) as month_id
,sum(a.amount/100) as sum_amount -- 累计佣金金额（元）
from dws_tpss_jszx.dws_settle_item_detail as a
join zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only as b on a.acc_nbr=b.access_code
where a.shard=200
  and cast(substr(a.billing_cycle_id,1,6 ) as int)>=b.max_rh_month
  and cast(substr(a.billing_cycle_id,1,6 ) as int)<='202604'
group by a.serv_id,a.acc_nbr,cast(substr(a.billing_cycle_id,1,6 ) as int)
; 


--统计号码价值积分累计出账费用到临时表
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_004_cz PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_004_cz
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
SELECT '202604' as stat_month,a.max_rh_month,a.access_code
,sum(case when a.max_rh_month=b.par_month_id then coalesce(b.jz_points,0) else 0 end) as rh_jz_points--入湖当月价值积分
,sum(case when b.par_month_id>=a.max_rh_month and b.par_month_id<='202604' then coalesce(b.fee,0) else 0 end) as total_czfee--入湖月至统计月累计出账费用
FROM zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only as a
left join zone_gz_yz.tmp_XQGZ2026060201738_004 as b on a.access_code=b.acc_nbr
GROUP BY a.max_rh_month,a.access_code
;

--统计号码累计佣金到临时表
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_005_yj PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_005_yj
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
SELECT '202604' as stat_month,a.max_rh_month,a.access_code
,sum(case when c.month_id>=a.max_rh_month and c.month_id<='202604' then coalesce(c.sum_amount,0) else 0 end) as total_amount--入湖月至统计月累计佣金元
FROM zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only as a
left join zone_gz_yz.tmp_XQGZ2026060201738_005 as c on a.access_code=c.acc_nbr
GROUP BY a.max_rh_month,a.access_code
;

--打标价值积分累计出账费用和累计佣金
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_006 PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_006
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
SELECT '202604' as stat_month,a.max_rh_month,a.access_code
,b.rh_jz_points--入湖当月价值积分
,b.total_czfee--入湖月至统计月累计出账费用
,c.total_amount--入湖月至统计月累计佣金元
FROM zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only as a
left join zone_gz_yz.tmp_XQGZ2026060201738_004_cz as b on a.access_code=b.access_code
left join zone_gz_yz.tmp_XQGZ2026060201738_005_yj as c on a.access_code=c.access_code
; 
 
 
--生产结果表
DROP TABLE IF EXISTS zone_gz_yz.tmp_XQGZ2026060201738_007 PURGE;
CREATE TABLE zone_gz_yz.tmp_XQGZ2026060201738_007
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
as
SELECT d.stat_month--统计月份
    ,d.rh_month--入湖月份
    ,d.oai_source--工单来源
    ,d.oai_county_division--县分
    ,d.access_code--接入号
    ,COALESCE(m.rh_jz_points,0) as rh_month_points
    ,COALESCE(m.total_czfee,0) as rh_total_czfee
    ,COALESCE(m.total_amount,0) as rh_total_amount
FROM zone_gz_yz.tmp_XQGZ2026060201738_003 as d
LEFT JOIN zone_gz_yz.ads_znpt_0405_points_cz_yj_list as m ON d.access_code = m.access_code
where d.stat_month='202604'
;


--相关核查：
select count(1) from zone_gz_yz.tmp_XQGZ2026060201738_001 ;
select count(1) from zone_gz_yz.tmp_XQGZ2026060201738_002;
select count(1) from zone_gz_yz.tmp_XQGZ2026060201738_003;
select count(1) from zone_gz_yz.tmp_XQGZ2026060201738_003_acc_only;

--核查接入号重复情况
select 
from zone_gz_yz.tmp_XQGZ2026060201738_003 
group by 
having cnt>1
order by cnt desc
--原口径有13个号码重复，调整为取sa_at最新一条对应的号码后无重复

