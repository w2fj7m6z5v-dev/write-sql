需求原始内容：
销售部要求统计去年末拍照的政企服务分群存量单移及其中VPN用户，在2026年6月的拆机用户数、拆机价值积分、离网率及环比

需求梳理：
ads_yz_zq_yd_pz_analyse_list是做给政企部的拍照用户清单，清单里有去年末拍照的政企分群号码，每日更新号码的状态state_new以及拆机时间cj_date

输出字段：
分类,局向,当月拆机用户数,当月拆机用户积分,上月拆机用户数,上月拆机用户积分,拍照用户数


drop table if exists tmp_jm_zq_pz_lw_list;
create table tmp_jm_zq_pz_lw_list
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')     
as
select 1 as order_id,'单移' as data_type,'政企服务分群' as subst_name,
count(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then serv_id end) as cj_cnt,  --当月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then jz_points end) as cj_jz_points,  --当月拆机用户积分
count(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then serv_id end) as cj_cnt_last,  --上月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then jz_points end) as cj_jz_points_last,  --上月拆机用户积分
count(serv_id) as pz_cnt  --拍照用户数
from ads_yz_zq_yd_pz_analyse_list
where par_month_id in ('202606')  --统计月份
and data_type='存量'  --限制存量号码
and serv_grp_type='01'   --限制服务分群
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))  --限制单移
union all
select 2 as order_id,'单移' as data_type,subst_name,
count(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then serv_id end) as cj_cnt,  --当月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then jz_points end) as cj_jz_points,  --当月拆机用户积分
count(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then serv_id end) as cj_cnt_last,  --上月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then jz_points end) as cj_jz_points_last,  --上月拆机用户积分
count(serv_id) as pz_cnt  --拍照用户数
from ads_yz_zq_yd_pz_analyse_list
where par_month_id in ('202606')  --统计月份
and data_type='存量'  --限制存量号码
and serv_grp_type='01'   --限制服务分群
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))  --限制单移
group by subst_name
union all
select 3 as order_id,'单移_VPN' as data_type,'政企服务分群' as subst_name,
count(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then serv_id end) as cj_cnt,  --当月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then jz_points end) as cj_jz_points,  --当月拆机用户积分
count(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then serv_id end) as cj_cnt_last,  --上月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then jz_points end) as cj_jz_points_last,  --上月拆机用户积分
count(serv_id) as pz_cnt  --拍照用户数
from ads_yz_zq_yd_pz_analyse_list
where par_month_id in ('202606')  --统计月份
and data_type='存量'  --限制存量号码
and serv_grp_type='01'   --限制服务分群
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))  --限制单移
and vpn_value is not null  --限制VPN用户
union all
select 4 as order_id,'单移_VPN' as data_type,subst_name,
count(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then serv_id end) as cj_cnt,  --当月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-06-01' and cj_date<='2026-06-25' then jz_points end) as cj_jz_points,  --当月拆机用户积分
count(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then serv_id end) as cj_cnt_last,  --上月拆机用户数
sum(case when state_new='已拆机' and cj_date>='2026-05-01' and cj_date<='2026-05-25' then jz_points end) as cj_jz_points_last,  --上月拆机用户积分
count(serv_id) as pz_cnt  --拍照用户数
from ads_yz_zq_yd_pz_analyse_list
where par_month_id in ('202606')  --统计月份
and data_type='存量'  --限制存量号码
and serv_grp_type='01'   --限制服务分群
and (yd_prod_type1 in ('预付费单产品','后付费单产品') or yd_prod_type2 in ('单产品副卡'))  --限制单移
and vpn_value is not null  --限制VPN用户
group by subst_name
order by order_id;


--输出结果
select data_type,subst_name,cj_cnt,cj_jz_points,cj_cnt_last,cj_jz_points_last,pz_cnt
from tmp_jm_zq_pz_lw_list;
