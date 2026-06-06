需求原始内容：
XQGZ2026050700989

结合一线常态化需求，现在531增加类似智家达人“我的揽装”模块，界面功能详见截图，
其中积分数据来源于揽装积分多维表的清单，上月的取月清单，当月的取日清单。
请业支对接做好数据授权，
需求字段：积分类型3、接入号码、网格名称、客户编码、客户名称、激励积分描述、价值积分描述、竣工时间、激励积分、价值积分
请全渠协助界面展示开发，争取5月内完成，谢谢！



需求梳理：
数据来源于揽装积分多维表清单，同揽装积分多维表同口径，需要每日更新数据。
揽装积分多维表口径：剔除部分降档（存量提值，专线提值，智能家居 负分）

输出字段：
积分类型3、接入号码、网格名称、客户编码、客户名称、激励积分描述、价值积分描述、竣工时间、激励积分、价值积分。


--按揽装积分多维表口径统计
drop table if exists zone_gz_yz.tmp_yzXQGZ2026050700989_1 purge;
create table zone_gz_yz.tmp_yzXQGZ2026050700989_1
row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy') 
    select  create_date,
    acc_nbr,
    serv_id,
    par_month_id,
    data_date,
    sales_nbr,
    sales_name,
    sales_code,
    xx_salestaff_code2,
    xx_salestaff_name2,
    channel_type,
    channel_nbr,
    channel_name,
    area_id,
    area_name,
    jz_points,
    jl_points,
    jl_points_desc,
    jz_points_desc,prod_name1,prod_name3,prod_name2,prod_name4,prod_id,
    channel_subst_id,
    channel_subst_name ,
    channel_branch_id ,
    channel_branch_name,
    subst_id,
    subst_name,cell_code, cell_name,
    cust_nbr,cust_id, cust_name
    from ads_yz_score_all_list --全业务发展存量积分清单
    where  
        par_month_id="$this_month" and 
     (prod_name2 not in ('存量提值','专线提值')  or ( prod_name2 in ('存量提值','专线提值')  and jz_points>=0 and jl_points>=0) or prod_name2 is null)
    and  (prod_name3<>'智能家居'  or ( prod_name3='智能家居' and jz_points>=0) or prod_name3 is null )
;

--将需要的字段插入结果表

 alter table
    tmp_yzXQGZ2026050700989_1_list drop if exists partition(sum_date = '$stat_day');
  insert into
    table tmp_yzXQGZ2026050700989_1_list partition(sum_date = '$stat_day')(
month_id 
,load_date
,channel_subst_name
,serv_id
,acc_nbr
,prod_name3
,create_date
,sales_code
,sales_name
,cell_code
,cell_name
,cust_nbr
,cust_id
,cust_name
,jz_points_desc
,jl_points_desc
,jz_points
,jl_points
		)
	  select 
"$this_month",
current_timestamp()
,channel_subst_name
,serv_id
,acc_nbr
,prod_name3
,create_date
,sales_code
,sales_name
,cell_code
,cell_name
,cust_nbr
,cust_id
,cust_name
,jz_points_desc
,jl_points_desc
,jz_points
,jl_points
	  from tmp_yzXQGZ2026050700989_1;

;

--输出最终字段
select 
prod_name3 --积分类型3、
,acc_nbr --接入号码、
,cell_name --网格名称、
,cust_nbr -- 客户编码、
,cust_name --客户名称、
,jl_points_desc -- 激励积分描述、
,jz_points_desc --价值积分描述、
,create_date --竣工时间、
,jl_points -- 激励积分、
,jz_points --价值积分。
 from tmp_yzXQGZ2026050700989_1_list where sum_date = '统计日';
