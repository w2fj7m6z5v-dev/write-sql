		------------------------------lemon笔记---------------------------------------
		产权备份表：iodata_ods_month_city.rpt_comm_cm_cust_mon
		--------------------------------------------------------------------------------------- 
		
		订单揽装crm原表：dws_crm_order.dws_ord_dev_staff_info_his
		CRM-订单揽装：销售品订单和产品订单有两个订单项，
		1）销售品订单：订单项、销售品实例（订单信息的揽装类型是订单项和销售品实例两种）
			，在202310月之前订单表优先看订单项揽装，优惠订单表只看销售品实例的揽装
			，所以有些销售品订单在crm看有订单项揽装人，但是优惠订单表为空，在订单表有揽装人
		2）产品订单：订单项、产品实例（订单信息的揽装类型是订单项和产品实例两种）
		--------------------------------------------------------------------------------------- 
		
		echo "=== 表大小对比 ==="
		echo ""
		echo "表名                                  | 实际使用空间 | 逻辑文件大小"
		echo "--------------------------------------|--------------|--------------"
		hadoop fs -du -s -h /apps/zone_gz_yz/hive/zone_gz_yz/dwd_yz_yj_check_template_diff_bak 2>/dev/null | awk '{printf "%-40s | %-12s | %-12s\n", "dwd_yz_yj_check_template_diff_bak", $1 " " $2, $3 " " $4}'
		hadoop fs -du -s -h /apps/zone_gz_yz/hive/zone_gz_yz/ads_yz_rpt_result_hd 2>/dev/null | awk '{printf "%-40s | %-12s | %-12s\n", "ads_yz_rpt_result_hd", $1 " " $2, $3 " " $4}'
		hadoop fs -du -s -h /apps/zone_gz_yz/hive/zone_gz_yz/ads_ys_lst_qf_pushdata_daily_bss 2>/dev/null | awk '{printf "%-40s | %-12s | %-12s\n", "ads_ys_lst_qf_pushdata_daily_bss", $1 " " $2, $3 " " $4}'
		--------------------------------------------------------------------------------------- 
		
		1.如果已经是压缩表
		ALTER TABLE ads_yz_zq_mdz_six_market_sr PARTITION (par_month_id='202202') CONCATENATE;
		这样就行

		2.如果不是压缩表，那只能建一个压缩表，把数据迁过去了
		--------------------------------------------------------------------------------------- 
		
		创建表和插入数据到清单表时加上这些参数，避免生成过多小文件
		-- 1.开启Map端输出小文件合并（写入时合并，最重要）
		set hive.merge.mapfiles=true;
		-- 2.开启MapReduce结束后分区内合并小文件
		set hive.merge.mapredfiles=true;
		-- 3.合并后单个文件大小256M（对齐HDFS块大小，Hive标准值）
		set hive.merge.size.per.task=268435456;
		-- 4.分区平均文件小于128M就触发合并
		set hive.merge.smallfiles.avgsize=134217728;
		-- 5.控制Reduce数量，避免输出过多小文件
		set hive.exec.reducers.bytes.per.reducer=67108864;

		--------------------------------------------------------------------------------------- 
		
		1. 看全部文件数
		hadoop fs -count -v /apps/zone_gz_yz/hive/zone_gz_yz/表名

		2.看每个分区的文件数

		hdfs dfs -ls hdfs://b5/apps/zone_gz_yz/hive/zone_gz_yz/表名 | \
		grep "^d" | \
		awk '{print $NF}' | \
		while read partition_dir; do
		file_count=$(hdfs dfs -count "$partition_dir" 2>/dev/null | awk '{print $2}')
		echo "$(basename $partition_dir) : $file_count files"
		done
		--------------------------------------------------------------------------------------- 
		
		身份证取年龄
		,case when length(a.social_id) = 18 
		and a.social_id_type = '1' then 
		cast(from_unixtime(unix_timestamp(),'yyyy') as integer)-cast(substr(a.social_id,7,4) as integer) 
		when length(a.social_id) = 15 and a.social_id_type = '1' then 
		cast(from_unixtime(unix_timestamp(),'yyyy') as integer)-cast('19' || substr(a.social_id,7,2) as integer) 
		else null end as age
		--------------------------------------------------------------------------------------- 
		
		excel下载数据转字符
		=IF(OR(B2="string",ISNUMBER(SEARCH("varchar",B2))),"replace("&A2&",',','，')",A2)
		--------------------------------------------------------------------------------------- 
		
		select prod_inst_id
		,owner_cust_id  --号码产权客户id
		,use_cust_id --关联使用人的客户id
		from dws_crm_cust.dws_prod_inst
		where city_id=200

		不过全业务资料表已经加过这个字段
		set hive.fetch.task.conversion = none;
		select use_cust_id
		from dwm_yz_tb_comm_cm_all_final where acc_nbr='13392602149' and par_month_id=202602;

		set hive.fetch.task.conversion = none;
		select cust_name,cust_number
		from dws_crm_cust.dws_customer 
		where cust_id='89003005303494';
		--------------------------------------------------------------------------------------- 
		
		销户口径：销户=wlcj+fzj+jzf （fzj是负数）
		sum(case when is_cz_last=0 and is_cancel_user=0 and is_new_user=0 and is_cz=1 then -1 else 0 end) fzj,--非转计
		sum(case when is_cz_last=1 and is_cancel_user=0  and is_cz=0 then 1  else 0 end) jzf,--计转非
		sum(case when is_cz_last=1 and is_wl_cancel_user=1  then 1  else 0 end) wlcj,--物理拆机
		--------------------------------------------------------------------------------------- 
		
		--同个申请编码下的订单
		select a.par_month_id,a.subs_id
		,a.req_id --申请编码
		from dwm_yz_rpt_comm_ba_msdisc_mon_final
		
		select a.par_month_id,a.subs_id,a.req_id,b.action_name 
		from dwm_yz_rpt_comm_ba_subs_mon_final a 
		join dwm_yz_rpt_comm_ba_msdisc_mon_final b on a.par_month_id=b.par_month_id and a.req_id=b.req_id 
		left join (select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200) b  
		on a.action_id=b.action_id 
		--------------------------------------------------------------------------------------- 
		--主群关系(不同类型订单关系，销售品订单和产品订单）
		select order_item_id  --主订单
		,in_order_item_id  --子订单
		from dws_crm_order.dws_ord_prod_inst_rel_grp --dws_crm_order.dws_ord_prod_inst_rel_grp_his

		--主从关系(同类型订单关系，产品订单和产品订单，销售品订单和销售品订单）
		select order_item_id  --主订单
		,z_order_item_id  --子订单
		from dws_crm_order.dws_order_item_rel  --dws_crm_order.dws_order_item_rel_his
		--------------------------------------------------------------------------------------- 
		
		--最新时点累计欠费
		select 
		serv_id
		,acc_nbr
		,billing_cycle_id -- 欠费账期
		,cust_name
		,data_type -- 欠费类型，区分普通欠费、欠不列这些
		,sum(qf_fee) -- 欠费金额，单位：元
		from  zone_gz_yz.ads_ys_lst_qf_pushdata_daily_bss 
		where stat_date_id=20251215 --统计时点
		and acc_nbr='XXX'
		having sum(qf_fee)>0  -- 大于0就是有欠费
		order by acc_nbr asc 
		limit 1000
		
		data_type
		不考核坏账欠不列
		不考核坏账欠费
		欠交未列
		普通欠费

		--某个账期范围内的欠费数据
		select a.acc_nbr  --可换成serv_id
		,sum(fee) as qf_fee 
		from ads_ys_km_hz_list_monthly a   
		where a.s_month_id=202303 
		and item_type in('当月应收','历史欠费','提前批扣','预销账','欠不列') 
		and billing_cycle_id>= '20230301' and a.billing_cycle_id<= '20230331' 
		and acc_nbr='WLWHFW2582287791'
		group by acc_nbr 
		--------------------------------------------------------------------------------------- 
		
		一、移动计费
		1、统计期末用户在网或统计月当月拆机 
		2、剔除后付费欠费3个月及以上用户 
		3、预付费余额状态为正常或者在保留期一个月内（即在上个月1日后进入余额保留状态）--说明：与预付费在网条件有点重复，比在网条件更严 
		4、出账收入＞0（回现的收入：srhx_fee=脱机收入+调账+赠金冲减+计不列>0） 
		5、剔除“20170401以来入网的沉默副卡”，沉默：主叫时长call_dur+被叫时长called_dur+上网流量innet_flux+点对点短信p2p_sms_num=0
		二、宽带计费（跟集团保持一致）
		1、宽带用户（统计为宽带的存量ITV用户 + prod_id in（950,48,47,56,52,57,999,10000,51,1100,3881,1023,1052,1051,49,1022,2340,2341,500001200,500001961,500001741,500002660） 
		2、统计时点在用，即状态为正常、停机、预拆机，剔除拆机、未竣工、未激活用户 
		3、剔除停机1个月及以上的预付费用户
		4、剔除欠费3个月及以上的后付费用户和准实时预付费用户。需特别注意的是，这里的“欠费”包含已列坏账记录。

		三、ITV计费
		1、ITV中属于宽带的用户：与宽带计费口径一致
		2、ITV中不属于宽带的用户：
		宽口径：
		（1）状态为正常/停机/预拆机
		（2）欠交月份（AREAR_MONTHR）小于等于3个月
		严口径：
		（3）2018年1月1日以后入网用户，已激活（激活清单取至互联网事业部ITV平台）

		四、其他固网产品：
		（1）状态为正常/停机/预拆机
		（2）欠交月份（ARREAR_MONTH）小于等于3个月

		--------------------------------------------------------------------------------------- 	
		--匹欠费停机时间
		select a.*,b.create_date 
		(select serv_id,create_date
		,row_number() over(partition by serv_id order by create_date asc) paixu 
		from summary_ods_day_city.tb_pre_cm_attr_all --月表 iodata_ods_month_city.tb_pre_cm_attr_all_mon
		where char_class='04' and attr_id in(98) --欠费停机 
		) b on b.paixu=1 and a.serv_id=b.serv_id 

		where cast(Datediff(date_format(create_date,'yyyy-MM-dd'),date_format(当前时间,'yyyy-MM-dd')) as int)>90 

		--------------------------------------------------------------------------------------- 	
		drop table if exists xxx1 purge;
		create table xxx1
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
		as
		select a.*,b.cdma_disc_type
		from tmp_yz_liq_2 a 
		left join 
		(select rh_tc_id,cdma_disc_type,row_number() over(partition by rh_tc_id order by cdma_disc_type) as paixu from zone_gz_yz.dwm_yz_tb_comm_cm_all_final where par_month_id=202309 and prod_type=30 and is_vice_card=0 and is_rh_ykj>0 and is_cancel_user=0) b 
		on a.rh_tc_id=b.rh_tc_id and b.paixu=1;

		drop table if exists xxx2 purge;
		create table xxx2
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
		as
		select a.*,
		b.reserve,--移动主套餐档次
		case when COALESCE(b.reserve,0)<>0 then a.rh_tc_value/b.reserve else null end as shishou_lv --实收率
		from tmp_yz_liq_3 a 
		left join metadata_ods_day.tb_dim_cdma_disc_type b on a.cdma_disc_type=b.cdma_disc_type3;
		--------------------------------------------------------------------------------------- 	
		
		--PG库result表建表语句
		drop table if exists ads_yz_rpt_result;
		create table ads_yz_rpt_result(
		day_id decimal(22,0),
		item_id decimal(22,0),
		item_name varchar(300),
		load_time varchar(300),
		subst_id decimal(22,0),
		branch_id decimal(22,0),
		org_id decimal(22,0),
		subst_name varchar(300),
		branch_name varchar(300),
		org_NAME varchar(300),
		area_id decimal(22,0),
		dim1 varchar(300),
		dim2 varchar(300),
		dim3 varchar(300),
		dim4 varchar(300),
		dim5 varchar(300),
		dim6 varchar(300),
		dim7 varchar(300),
		dim8 varchar(300),
		dim9 varchar(300),
		dim10 varchar(300),
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
		value50 decimal(22,4),
		sum_date varchar(300),
		item_nbr varchar(300)
		);
		commit;
		--------------------------------------------------------------------------------------- 	
		
		数据量很大的表跑不出来数 可加下面两条参数
		set hive.tez.container.size=4096;
		set tez.queue.name=zone_gz;
		--------------------------------------------------------------------------------------- 	
		
		优惠订单表的 msinfo_id 是没有二次加工的crm原始数据
		，优惠资料表的 msinfo_id 是做了二次加工的（主要是主从关系，会用主实例覆盖从销售品的实例）
		，优惠资料表的 msobjgrp_id 是原始未加工的 msinfo_id 
		select a.*,b.* from dwm_yz_rpt_comm_ba_msdisc_mon_final a 
		left join dwd_yz_rpt_comm_cm_msdisc_mon_final b on a.msinfo_id=b.msobjgrp_id 
		--------------------------------------------------------------------------------------- 		
		ctrl+q/k 注释代码
		--------------------------------------------------------------------------------------- 
		佣金业务分类
		select a.busi_type,b.busi_name 
		from dws_tpss_jszx.dws_settle_item_detail a 
		left join dws_tpss_jszx.dws_ps_settle_busi b on a.busi_type=b.busi_code 
		where billing_cycle_id between 20240101 and 20250501  
		and shard=200  and cost_flag=0
		and (busi_type like 'Y%' or busi_type like 'CFZ%')
		group by a.busi_type,b.busi_name limit 1000 	
		--------------------------------------------------------------------------------------- 
		
		--联系电话
		create table tmp_jrhy_clyh_cust as 
		select a.*  from 
		(select distinct cust_id,party_id from dws_crm_cust.dws_customer where city_id=200) a
		join (select distinct cust_id from ads_yz_jrhy_clyh_202307 where cust_id is not null) b
		on a.cust_id=b.cust_id;

		create table tmp_jrhy_clyh_info_rel as 
		select a.*,b.contact_id  from 
		tmp_jrhy_clyh_cust a
		join (select distinct cust_id,contact_id from dws_crm_cust.dws_cust_contact_info_rel where city_id=200) b
		on a.cust_id=b.cust_id;

		create table tmp_jrhy_clyh_info as 
		select distinct PARTY_ID,contact_id,contact_name,home_phone,office_phone,mobile_phone,status_date 
		from dws_crm_cust.dws_contacts_info where city_id=200;

		create table tmp_jrhy_clyh_linke as 
		select a.*,b.contact_name,b.home_phone,b.office_phone,b.mobile_phone,b.status_date 
		from tmp_jrhy_clyh_info_rel a
		join tmp_jrhy_clyh_info b
		on a.PARTY_ID=b.PARTY_ID and a.contact_id=b.contact_id;

		--------------------------------------------------------------------------------------- 	
		drop table if exists ads_yz_rpt_result_20250508_bf;
		create table ads_yz_rpt_result_20250508_bf(
		day_id decimal(22,0),
		item_id decimal(22,0),
		item_name varchar(300),
		load_time varchar(300),
		subst_id decimal(22,0),
		branch_id decimal(22,0),
		org_id decimal(22,0),
		subst_name varchar(300),
		branch_name varchar(300),
		org_NAME varchar(300),
		area_id decimal(22,0),
		dim1 varchar(300),
		dim2 varchar(300),
		dim3 varchar(300),
		dim4 varchar(300),
		dim5 varchar(300),
		dim6 varchar(300),
		dim7 varchar(300),
		dim8 varchar(300),
		dim9 varchar(300),
		dim10 varchar(300),
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
		value50 decimal(22,4),
		sum_date varchar(300),
		item_nbr varchar(300)
		);
		commit;	

		--PG库建索引才能刷报表数据
		commit;
		CREATE INDEX idx_ads_yz_rpt_result_20250508_bf_item_nbr
		ON app_sjjy_gz.ads_yz_rpt_result_20250508_bf (item_nbr);
		commit;
		CREATE INDEX idx_ads_yz_rpt_result_20250508_bf_sum_date
		ON app_sjjy_gz.ads_yz_rpt_result_20250508_bf (sum_date);
		commit;

		insert into ads_yz_rpt_result_20250508_bf 
		select * from ads_yz_rpt_result 
		where cast(substr(SUM_DATE,1,6) as int)>202502 ;commit;

		insert into ads_yz_rpt_result_20250508_bf 
		select * from ads_yz_rpt_result 
		where cast(substr(SUM_DATE,1,6) as int)<=202502 
		and length(SUM_DATE)<>8;commit;

		insert into ads_yz_rpt_result_20250508_bf 
		select * from ads_yz_rpt_result 
		where cast(substr(SUM_DATE,1,6) as int)<=202502 
		and substr(SUM_DATE,5,8) in (
		'0101','0201','0301','0401','0501','0601','0701','0801','0901','1001','1101','1201',
		'0131','0228','0229','0331','0430','0531','0630','0731','0831','0930','1031','1130','1231') 
		and length(SUM_DATE)=8;commit;
		
		--------------------------------------------------------------------------------------- 	
		--PG库操作python版本
		from zone_python import *


		connect_pg_gd(database_pg="yz_sjjy_gz",user_pg="app_sjjy_gz",password_pg="ZlhKKicldyDxRXhWdPlmhw__",host_pg="132.122.112.113",port_pg="18923")

		sql_str= f"""
		drop table if exists tmp_yy;
		create table tmp_yy as  select item_nbr,SUM_DATE,count(1) nums from ads_yz_rpt_result where cast(substr(SUM_DATE,1,6) as int)<=202502 and substr(SUM_DATE,5,8) not in ('0131','0228','0229','0331','0430','0531','0630','0731','0831','0930','1031','1130','1231') and length(SUM_DATE)>=8 group by item_nbr,SUM_DATE order by SUM_DATE,item_nbr;
		commit;
		"""
		exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str)	
		--------------------------------------------------------------------------------------- 		
		
		LDC02002544A 在202412月份有CRM出帐3万多，但是收入表dwm_srhx_serv_list_mon_final_v2_mon只是8千多
		LDC12739900A 这个号码出帐也是3万多，但是收入表只是5千多 

		--核查科目收入
		select * from dwm_srhx_src_income_list_mon where par_month_id=202412  and acc_nbr like '%LDC12739900%'
		select * from dwm_srhx_src_income_list_mon where par_month_id=202412  and acc_nbr like '%LDC02002544%'
		--调退表
		select *  from ads_ys_tt_daily where acc_nbr  in ('LDC12739900A','LDC02002544A')
		--------------------------------------------------------------------------------------- 		

		--PYTHON PG库跑数调用脚本
		from zone_python import *

		item_nbr= 'KD_D_038'

		connect_pg_gd(database_pg="yz_sjjy_gz",user_pg="app_sjjy_gz",password_pg="ZlhKKicldyDxRXhWdPlmhw__",host_pg="132.122.112.113",port_pg="18923")

		sql_str= f"""
		drop table if exists tmp_yy;
		create table tmp_yy as select * from  ads_yz_rpt_result where item_nbr='{item_nbr}' AND SUM_DATE='{yyyymmdd}';
		commit;
		"""
		exec_multi_sql_pg("yz_sjjy_gz","app_sjjy_gz",sql_str)
		--------------------------------------------------------------------------------------- 

		202502年度回溯前的收入备份表
		dwm_srhx_serv_final_mon   dwm_srhx_serv_final_mon_bf_202502
		dwm_srhx_serv_list_mon   dwm_srhx_serv_list_mon_bf_202502
		dwm_srhx_serv_list_mon_final   dwm_srhx_serv_list_mon_final_bf_202502
		dwm_srhx_serv_list_mon_final_v2_mon   dwm_srhx_serv_list_mon_final_v2_mon_bf_202502
		dwm_srhx_jbm_src_income_list_mon dwm_srhx_jbm_src_income_list_mon_202502		
		--------------------------------------------------------------------------------------- 
		
		--1.通过人力编码找人员标识
		select staff_hr_nbr,staff_id  from ads_yz_dim_op_final where par_month_id=202504 and staff_hr_nbr=''
		--2.通过人员标识找网点
		select staff_id,sales_code,channel_id,channel_name,channel_nbr from dwd_yz_sales_man_outlers_final where staff_id='300000795798'
		--3.通过网点ID找合同
		供应商名称        供应商编码        经营主体编码        经营主体名称        网点编码        网点名称        合同编号        合同名称        
		甲方名称        乙方名称        丙方名称        生效时间        失效时间        结算终止时间
		select sap_suppname,sap_suppcode,c.operators_nbr,c.operators_name,b.channel_nbr,b.channel_name,
		document_no,agree_name,j_corp_name,y_corp_name,b_corp_name,effect_date,expire_date,settlement_enddate,a.state,a.channel_id
		from 
		(select channel_id,sap_suppname,sap_suppcode,
		document_no,agree_name,j_corp_name,y_corp_name,b_corp_name,effect_date,expire_date,settlement_enddate,state
		from dws_tpss_jszx.dws_channel_contract  where contract_object_type='CHANNEL'
		and channel_id in ('xxx')) a
		left join (select channel_id,channel_nbr,channel_name,own_operators_id from dws_crm_chn_dms.dws_sale_outlers where city_id=200) b
		on a.channel_id=b.channel_id
		left join dws_crm_cfguse.dws_operators c
		on b.own_operators_id=c.operators_id;
		--------------------------------------------------------------------------------------- 	
		
		徐晓聪 4/8 11:38:36
		根据销售部要求，新增【客群分类】字段，已在资料表、收入表增加并回溯至202301月：
		
		标签“客群分类”  ：
		1、细分市场=商客 or 名单制客户类型=名单制商客，打标为【商客分群】
		2、服务分群=政企 且 非【商客分群】，打标为【政企（不含商客）】
		3、服务分群=公众 且 非【商客分群】，打标为【公众（不含商客）】

		1、资料表：
		dwm_yz_tb_comm_cm_all_mon_final,
		dwm_yz_tb_comm_cm_all_final 
		新增字段：null_column11

		2、收入表：
		dwm_srhx_serv_final_mon,
		dwm_srhx_serv_list_mon_final,
		dwm_srhx_serv_list_mon_final_v2_mon,
		dwm_srhx_src_income_list_mon
		新增字段：kq_type

		【客群分类的字段内容为：商客分群、公众（不含商客）、政企（不含商客）】

		后续有多份清单会提需求增加该字段，请大家留意提及到“客群分类”的需求，谢谢。

		@所有人  

		徐晓聪 4/8 11:40:38
		在各类业务清单新增这个字段的时候，统一字段名为：kq_type（客群分类）吧，资料表那个是没办法才用预留字段名称。
		--------------------------------------------------------------------------------------- 
		
		按市销售部渠道室要求改了渠道规则，从25年开始切换，24年及之前的历史月份不变
		--------------------------------------------------------------------------------------- 
		
		复制带分区的表结构
		create table xxxx like xxxx2;
		--------------------------------------------------------------------------------------- 
		
		20250226  
		dwd_dim_cust_bg_type_2023年度名单制表已经更新
		去年的数据拍照在dwd_dim_cust_bg_type_2023_bf_2025
		--------------------------------------------------------------------------------------- 
		
		--批量单行注释：ctrl+K
		--批量取消单行注释：ctrl+Q
		
		--PG库建索引才能刷报表数据
		commit;
		CREATE INDEX idx_ads_yz_rpt_result_item_nbr
		ON app_sjjy_gz.ads_yz_rpt_result (item_nbr);
		commit;
		CREATE INDEX idx_ads_yz_rpt_result_sum_date
		ON app_sjjy_gz.ads_yz_rpt_result (sum_date);
		commit;
		--------------------------------------------------------------------------------------- 
		
		ads_yz_wyt_zw_list 
		--装维成本：201910-202401
		--涉及字段：acc_nbr,month_id,fee_zw（装维成本）
		ads_yz_zd_wyt_list 
		--终端成本：202201-202312
		--涉及字段：acc_nbr,month_id,fee_zd（终端成本）
		这个就是吴云涛之前发给可馨的原始数据
		--------------------------------------------------------------------------------------- 
		
		select serv_id,
		cast(DUR/60 as decimal(22,2)) gw_sc  --固网通话时长 单位分
		from summary_ods_month_city.TB_COMM_YWL_GW_mon where par_corp_id=200 and par_month_id=202402 
		--------------------------------------------------------------------------------------- 
		
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
		
		--------------------------------------------------------------------------------------- 
		
		--客户联系人和联系方式
		create table tmp_jrhy_clyh_cust as 
		select a.*  from 
		(select distinct cust_id,party_id from dws_crm_cust.dws_customer where city_id=200) a
		join (select distinct cust_id from ads_yz_jrhy_clyh_202307 where cust_id is not null) b
		on a.cust_id=b.cust_id;

		create table tmp_jrhy_clyh_info_rel as 
		select a.*,b.contact_id  from 
		tmp_jrhy_clyh_cust a
		join (select distinct cust_id,contact_id from dws_crm_cust.dws_cust_contact_info_rel where city_id=200) b
		on a.cust_id=b.cust_id;

		create table tmp_jrhy_clyh_info as 
		select distinct PARTY_ID,contact_id,contact_name,home_phone,office_phone,mobile_phone,status_date 
		from dws_crm_cust.dws_contacts_info where city_id=200;

		create table tmp_jrhy_clyh_linke as 
		select a.*,b.contact_name,b.home_phone,b.office_phone,b.mobile_phone,b.status_date 
		from tmp_jrhy_clyh_info_rel a
		join tmp_jrhy_clyh_info b
		on a.PARTY_ID=b.PARTY_ID and a.contact_id=b.contact_id;
		--------------------------------------------------------------------------------------- 
		
		select 
		cast(prod_inst_id as decimai(22,0)) as serv_id,
		acc_num as acc_nbr,
		address_desc  --报装地址
		from dws_crm_cust.dws_prod_inst where city_id=200
		--------------------------------------------------------------------------------------- 
		
		省融合表：日 summary_ods_day_city.tb_lab_cm_new_mix_type
		月 iodata_ods_month_city.tb_lab_cm_new_mix_type_mon
		2023年4月纳入部分智家产品，算成ITV，产品维表： select * from summary_ods_day_city.rpt_sum_class_item where sum_class_id=62153

		如何区分：套餐级/账户级/同客户，new_mix_type字段，1开头为套餐级，2开头为账户级，3开头为同客户
		--------------------------------------------------------------------------------------- 
		
		宽带有效（is_yx）口径调整为：不含itv用户，非LAN和专线产品，当月套餐ARPU值≥10元且上网时长≥60分钟；LAN和专线产品，当月套餐ARPU值≥10元；
		其中套餐ARPU值收入口径根据“新融合类型new_mix_type 取 套餐级下所有产品收入、客户（账户）级下所有产品收入 和 非融合（单产品） 收入”，即yx_arpu字段
		
		--------------------------------------------------------------------------------------- 
		--铺排网点
		drop table if exists zone_gz_yz.tmp_final_dwm_yz_tb_comm_cm_all_sub4_mboss; 
		create table zone_gz_yz.tmp_final_dwm_yz_tb_comm_cm_all_sub4_mboss
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
		as
		select a.serv_id,a.org_id,b.channel_nbr,b.channel_name,b.channel_type,b.subst_name,b.branch_name,
		row_number() over(partition by a.serv_id order by a.create_date desc) pm
		from (select serv_id,org_id,create_date from dwd_yz_f_mboss_raqinfo_final) a
		left join (select channel_id,channel_nbr,channel_name,channel_type,subst_name,branch_name from dwd_yz_sale_outlers_final) b
		on a.org_id=b.channel_id;
		--------------------------------------------------------------------------------------- 
		
		'
		--将,转成ASCII44，=转成ASCII90，再映射成字典
		select 'a12' flag_type,serv_id3 serv_id
		,replace(replace(cast(grid_name as string),',','ASCII44'),'=','ASCII90') value  from tmp_final_dwm_yz_tb_comm_cm_all_sub3

		--映射字典转置行字段再转换回来
		replace(replace(map_col[\"a12\"],'ASCII44',','),'ASCII90','=')  a12,
		
		'
		--------------------------------------------------------------------------------------- 
		
		资源不足的系统参数设置
		use zone_gz_yz;
		set hive.vectorized.execution.enabled=false;
		set hive.vectorized.execution.reduce.enabled=false;
		set hive.auto.convert.join=false;
		set hive.map.aggr=false;
		--------------------------------------------------------------------------------------- 
		
		数据挖掘专区连接PG数据库
		驱动类型：PostgreSQL
		驱动程序：org.postgresql.Driver
		URL:    jdbc:postgresql://132.122.112.113:18923/yz_sjjy_gz
		SCHEMA:app_sjjy_gz
		用户名：app_sjjy_gz
		密码：ZlhKKicldyDxRXhWdPlmhw__
		
		--------------------------------------------------------------------------------------- 		
		
		【涉及服务专区下载需求的清单模板】
		目的：为加快推进广州云网吧业务发展，增强网吧行业客户粘性，政企部互联网BG前期已梳理广州未入云网吧客户清单（如附件清单），现申请匹配对应客户在我司线路（尊享专线、极速专线、宽带）业务资费情况，
		频次：一次性项目
		数据量规模：下载清单中所有能匹配到客户名称的线路资费等信息
		需批量下载的原因：因因需要通过统计分析客户在用资费情况，制订对应的产品资费策略，需通过清单方式发送
		数据销毁：由经办人林友钢操作、刘国胜监督方式，进行双人模式监督销毁，确保不留存（数据销毁为我方人员，原则上为经办人及其直线经理）

		--------------------------------------------------------------------------------------- 		
		
		select cast(a.prod_inst_id as int) as serv_id
		,a.property_type  --设备来源id
		,b.attr_value_name as sheb_ly --设备购买方式
		from dws_crm_cust.dws_prod_res_inst_rel a
		left join dws_crm_cfguse.dws_attr_value b on a.property_type = b.attr_inner_value and b.city_id='200' and b.attr_id =4000000208--设备购买方式
		where city_id='200';
		
		dws_crm_cust.dws_prod_res_inst_rel_his  --历史表
		--------------------------------------------------------------------------------------- 
		--分光器
		select cast(prod_inst_id as int) as serv_id
		,dp_code  --DP编码
		,onu_code  --onu编码
		,obd_code  --OBD编码
		from dws_crm_cust.dws_cust_serv_res where city_id='200'
		--------------------------------------------------------------------------------------- 
		
		--省融合
		iodata_ods_month_city.tb_lab_cm_new_mix_type_mon  月表
		summary_ods_day_city.tb_lab_cm_new_mix_type   日表，只有当前月数据

		select serv_id  --融合号码
		,new_mix_type_relat_id  --融合标识
		,new_mix_type_prod  --融合产品类型
		from summary_ods_day_city.tb_lab_cm_new_mix_type
		where 1=1 
		--and par_month_id=202403  月表限制月份
		and par_corp_id=200;
		--------------------------------------------------------------------------------------- 
		
		
		申请CDAP相关表权限：参考需求单 XQGZ2024031400555
		--------------------------------------------------------------------------------------- 
		
		--订单协销表：dwd_yz_ba_obj_xx_final 
		select b.dev_staff_id,b.staff_name,b.sales_code  --第一协销人（第二发展人）
		,c.dev_staff_id,c.staff_name,c.sales_code  --第二协销人（第三发展人）
		left join (select *  from dwd_yz_ba_obj_xx_final where dev_staff_type='2000' and par_month_id='$sum_month') b
		on a.subs_id=b.order_item_id
		left join (select *  from dwd_yz_ba_obj_xx_final where dev_staff_type='3000' and par_month_id='$sum_month') c
		on a.subs_id=c.order_item_id;
		
		--号码协销表
		v_table_name_obj_xx="zone_gz_yz.dwd_yz_cm_obj_xx_mon_final"
		else 
		v_table_name_obj_xx="zone_gz_yz.dwd_yz_cm_obj_xx_final"

		select a.*,xx_salestaff_id1,xx_salestaff_code1,xx_salestaff_name1  第一协销人
		,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2  第二协销人
		from zone_gz_yz.tmp_ads_yz_kd_new_list_08 a
		left join "${v_table_name_obj_xx}" b 
		on a.serv_id=b.serv_id "${v_par_month_b}";
		
		--------------------------------------------------------------------------------------- 
		--一次性备份分区表
		create table tbl_test_bak like  tbl_test; 
		insert overwrite table tbl_test_bak
		select
		data_date
		,a.prod_id2
		,a.prod_name2
		,a.disc_class
		,a.prod_type2
		,a.prod_type4
		,a.subst_id
		,a.subst_name
		,b.subst_order
		,a.value1
		,a.value2
		,a.value3
		,a.value4
		,a.value5
		,a.value6
		,a.value7
		,a.value8
		,a.value9
		,a.value10
		,a.par_data_date
		from tbl_test a
		--------------------------------------------------------------------------------------- 
		
		大宽表取号码的address_id
		select  b.contact_name  --联系人
		b.mobile_phone  --联系人电话
		from   dws_crm_cust.dws_contacts_info as b
		on cast(a.address_id as string) = b.contact_id
		and b.city_id = '200';
		--------------------------------------------------------------------------------------- 
		
		【年度回溯通知20240320】
		目前第一版年度局向回溯已经完成，中间层涉及历史表已经回溯

		一、局向回溯
		回溯基准表：ads_yz_2024_ndhs_jz_list
		涉及号码范围：在网+拆机（202101-202403）

		1、涉及表：
		dwm_yz_tb_comm_cm_all_final          账期202312-202402
		dwm_yz_tb_comm_cm_all_mon_final      账期202012-202402
		涉及字段：
		subst_id,branch_id,area_id,grid_id,grid_code,
		std_subst_id,std_branch_id,ccenter,cell_id,cell_code,
		subst_name,branch_name,area_name,grid_name,
		std_subst_name,std_branch_name,cell_name,
		region_type,is_mdz,bg_type,bu_type

		2、涉及表：
		dwm_yz_rpt_comm_ba_msdisc_mon_final  账期202012-202402    
		涉及字段：
		subst_id,branch_id,area_id,grid_id,grid_code,
		std_subst_id,std_branch_id,cell_id,cell_code,
		region_type,bg_type,bu_type

		3、涉及表：
		dwm_yz_rpt_comm_ba_subs_mon_final   账期202012-202402    
		涉及字段：
		subst_id,branch_id,area_id,grid_id,grid_code,
		std_subst_id,std_branch_id,ccenter,cell_id,cell_code,
		subst_name,branch_name,
		std_subst_name,std_branch_name,
		region_type,bg_type,bu_type

		4、涉及表：
		dwd_yz_rpt_comm_cm_msdisc_mon_final  账期202212-202402    
		涉及字段：
		subst_id,branch_id,area_id,
		std_subst_id,std_branch_id

		二、切换is_5g口径并回溯
		涉及表：
		dwm_yz_tb_comm_cm_all_final          账期202312-202402
		dwm_yz_tb_comm_cm_all_mon_final      账期202012-202402   
		另当前表口径也已经修改

		三、副宽回溯：prod_type3,fk_lx,fk_value
		涉及表：
		dwm_yz_tb_comm_cm_all_final          账期202312-202402
		dwm_yz_tb_comm_cm_all_mon_final      账期202012-202402      

		四、is_hy,is_yx口径调整，原先口径仅有移动号码prod_type=30有判断活跃、有效，修改后宽带产品prod_type=40也纳入
		移动产品，日月均有判断
		宽带产品，仅有月判断

		口径来源省月数据：
		select is_yx '有效',is_active_user '活跃' from summary_ods_month_city.tb_comm_cm_data_mon where par_corp_id=200

		涉及表：
		dwm_yz_tb_comm_cm_all_final          账期202312-202402
		dwm_yz_tb_comm_cm_all_mon_final      账期202012-202402  

		五、21年细分市场修正，涉及字段six_market,is_school_market_user
		涉及表：
		dwm_yz_tb_comm_cm_all_mon_final      账期202101-202112   


		回溯前备份表,注意在zone_gz下
		zone_gz.dwm_yz_tb_comm_cm_all_mon_final_2023ndhs_bf
		zone_gzdwm_yz_rpt_comm_ba_msdisc_mon_final_2023ndhs_bf
		zone_gzdwm_yz_rpt_comm_ba_subs_mon_final_2023ndhs_bf
		zone_gzdwd_yz_rpt_comm_cm_msdisc_mon_final_2023ndhs_bf     


		请阅知，如有问题请及时反馈沟通，谢谢！     
		
		【中间层口径调整】
		1.region_type,按24年最新697个综合网格包区打标，另外将城中村/农村，拆分城中村，农村2个类型，共计6大网格
		另新增region_type初始化其他
		2.bg_type,bu_type,is_mdz，按照24年最新名单制拍照表打标，BG类型由23年9个改成24年10个
		24年名单制拍照表仍存放在dwd_dim_cust_bg_type_2023
		23年名单制拍照表，备份至dwd_dim_cust_bg_type_2023_bf
		
			case 
			when cntrt_type_cbxl in ('101001') then '城市家庭'
			when cntrt_type_cbxl in ('102001') then '农村'
			when cntrt_type_cbxl in ('101002') then '城中村'
			when cntrt_type_cbxl in ('202002') then '专业市场'
			when cntrt_type_cbxl in ('202003') then '商务楼宇'
			when cntrt_type_cbxl in ('202004') then '产业园区' 
			else '其他' end as region_type
			
		【中间层口径调整】
		已经按最新11个县分版本机构排序更新：
		1.dwd_yz_dim_subst
		2.dwd_yz_dim_org表里的subst_order，short_subst_name
		请留意，谢谢！
		
		【中间层口径调整通知20240320--渠道】
		根据销售部需求，调整渠道口径
		1、将城中村/农村包区店，拆分成城中村包区店和农村包区店
		2、修改网上卖场和新型跨界（数营中心）口径，将原先网上卖场规则中电子-分销二级代理网点子类型调整至新型跨界（数营中心）

		计划明天生效，只影响3月及之后数据，不回溯历史。

		同步修改维表：
		dwd_dim_channel_subtype_pg
		dwd_dim_channel_subtype_rb
		并推送至PG库

		请阅知，谢谢！
		另请大家留意，报表中如写死region_type,bg_type,bu_type,渠道，因年度调整，需要调整报表格式
		
		【年度回溯通知20240321】一线全业务资料表回溯完成，（view_县分_ads_yz_tb_comm_cm_all_final）
		回溯账期202012-202402
		1.年度局向回溯
		涉及字段：subst_id,branch_id,area_id,grid_id,grid_code,
		std_subst_id,std_branch_id,cell_id,cell_code,
		subst_name,branch_name,area_name,grid_name,
		std_subst_name,std_branch_name,cell_name,
		region_type,is_mdz,bg_type,bu_type
		2.is_5g口径切换并回溯
		3.产品小类prod_type3，副宽类型fk_lx,副宽价值fk_value按新口径回溯
		4.is_hy,is_yx口径调整，原先口径仅有移动号码prod_type=30有判断活跃、有效，修改后宽带产品prod_type=40也纳入
		移动产品，日月均有判断
		宽带产品，仅有月判断
		另之前的is_hy_kd,is_yx_kd现与is_hy,is_yx一致（限制prod_type=40），暂仍保留
		5. 21年细分市场修正，涉及字段six_market,is_school_market_user
		6. 前期新增字段terminal_type等均回溯历史月份
		，请阅知，谢谢！
		
		【中间层口径调整通知20240321--渠道】
		根据需求XQGZ2024022300302，修改渠道口径网上卖场和新型跨界（数营中心）口径，将原先网上卖场规则中电子-分销二级代理网点子类型调整至新型跨界（数营中心）
		特殊对2月新入网的拍照号码进行调整，从网上卖场改成新型跨界（数营中心），涉及号码不回溯，只是从3月开始生效，目前已修改拍照表，涉及号码量1159个，也存放一份ads_yy_XQGZ2024022300302_final可供核查，请留意，谢谢！

		
		--------------------------------------------------------------------------------------- 
		
		,`_c2` as num_C  --开头下划线的字段名重命名
		---------------------------------------------------------------------------------------
		
		a、z端对应关系表：crm-基础销售品-层级上面是a端号码，属于a端号码下的号码是z端号码
		select a_prod_inst_id,z_prod_inst_id from dws_crm_cust.dws_prod_inst_rel_a --产品关联口径
		select a_prod_inst_id,z_prod_inst_id from dws_crm_cust.dws_prod_inst_rel_grp_a --业务关联口径
		
		---------------------------------------------------------------------------------------
		
		select sub_prod_id  --附属产品ID
		,attr_id  --附属产品属性ID（附属产品的特性）
		,state_date  create_date --订购时间
		,a.attr_value1  --特性值
		from iodata_ods_month_city.rpt_comm_cm_subserv_mon a --附属产品资料表 月表
		summary_ods_day_city.rpt_comm_cm_subserv  a --附属产品资料表 当前日表
		
		drop table if exists  xxx;
		create table xxx 
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
		as 
		select b.reamark xyw_lx,b.seq_name xyw_name,b.seq_value_id,b.seq_value_code,b.seq_type
		,a.cust_id,a.serv_id,a.state_date as create_date,
		a.attr_id,a.attr_value1 as attr_value,a.prod_id,a.acc_nbr 
		from (select * from summary_ods_day_city.rpt_comm_cm_subserv where par_corp_id=200) a
		join (select *  from dwd_dim_all_config where seq_id=12 and seq_type='sub_prod_id' and  seq_name='天翼看家') b
		on a.sub_prod_id=b.seq_value_id;
		---------------------------------------------------------------------------------------
		select serv_id
		,attr_id --特性id（产品规格属性）
		,attr_value1  --特性值
		,create_date   --订购时间
		from summary_ods_day_city.tb_pre_cm_attr_all  --特性资料表 
		where par_corp_id='200'
		iodata_ods_month_city.tb_pre_cm_attr_all_mon 
		
		特性维表：select attr_name from dws_crm_cfguse.dws_attr_spec where attr_id='500037171'，打标停机原因中文名称
		根据附属产品编码查特性id：select attr_id,attr_name from dws_crm_cfguse.dws_attr_spec where attr_inner_cd in('PM_YDYDCP16SH3',
		'PM_YDYBDQCP5SX2',
		'PM_YDYDCP16SH2')
		特性值维表：select attr_id,attr_inner_value,attr_value_name 
					from xxxxx a
					left join dws_crm_cfguse.dws_attr_value b on a.attr_value1=b.attr_inner_value and b.city_id='200' and a.attr_id=b.attr_id，打标特性值中文名称
		
		---------------------------------------------------------------------------------------
		select distinct par_month_id
		,open_month
		,cast(cast(par_month_id as int)/100 as int) sum_yy
		,cast(cast(open_month as int)/100 as int) create_yy

		,substr(par_month_id,5,6) sum_mm
		,substr(open_month,5,6) create_mm
		,(cast(cast(par_month_id as int)/100 as int)-cast(cast(open_month as int)/100 as int))*12
			+(cast(substr(par_month_id,5,6) as int)-cast(substr(open_month,5,6) as int)) mm_diff  --T+N标识的N
		from summary_tyks_month_city.TB_ZTJK_NEW_USER_MON -- 省口径质态统计清单
		where par_month_id='202401' limit 10
		---------------------------------------------------------------------------------------
	
		IQ数据库202112-202212后付费实收数据：DWS_IQ_dwd_yz_if_real_src_sum_new_iq_2022
		
		实收数据表只有23年的数据，没有22年的历史数据
		select par_month_id, serv_id, 
		sum(case when flag = 'HF' then amount-amount_tc else 0 end)+sum(case when flag = 'OT' then amount else 0 end) as amount
		from zone_gz_yz.dwd_yz_if_real_src_sum_new_final
		where par_month_id>=202201 and par_month_id <= 202312 
		group  by par_month_id, serv_id
		
		---------------------------------------------------------------------------------------
		--统计网格单元的七级地址数量
		create table tmp_yz_liq_1 as 
		select src_cond_1 --地址 
		,obj_id--网格单元id 
		,obj_type --网格单元类型 
		,c.attr_value_name --网格单元类型 中文名称 
		,a.update_date 
		,row_number() over(partition by a.src_cond_1 order by a.update_date desc) as paixu 
		from dws_grid.dws_grid_unit_claim_rel a --网格单元维表
		left join dws_crm_cfguse.dws_attr_value c 
		on a.obj_type=c.attr_inner_value and c.city_id='200' and c.attr_id='4000092011' 
		where a.city_id='200' 
		and a.src_cond_3='7' --七级地址
		and a.status_cd='1000'  --有效
		
		select obj_id,attr_value_name,count(distinct src_cond_1) num from tmp_yz_liq_1 where paixu=1
		
		---------------------------------------------------------------------------------------
		
		域名：substring(acc_nbr2,instr(acc_nbr2,'@')+1,length(acc_nbr2))
		---------------------------------------------------------------------------------------
		
		--更新低值宽带类型
		select t.serv_id serv_id5,t.type as prod_type3
		from (select a.serv_id,b.type,b.type_id,row_number() over(partition by a.serv_id order by b.type_id asc) type_row
		from dwd_yz_rpt_comm_cm_msdisc_final a
		join dwd_dim_dzkd_offer b
		--join (select seq_value_id as prod_offer_id from zone_gz_yz.dwd_dim_all_config where seq_id=6) b
		on a.prod_offer_id=b.prod_offer_id
		where date_format(a.create_date,'yyyyMMdd') <= '$yyyymmdd'
		and date_format(a.limit_date,'yyyyMMdd') > '$yyyymmdd'
		) t
		where t.type_row=1
		;
		---------------------------------------------------------------------------------------
		
		--更新年龄
		case when length(social_id) = 18 and social_id_type = '1' 
			then cast(from_unixtime(unix_timestamp(),'yyyy') as integer)-
			cast(substr(social_id,7,4) as integer) 
		when length(social_id) = 15 and social_id_type = '1' 
			then cast(from_unixtime(unix_timestamp(),'yyyy') as integer)-
			cast('19' || substr(social_id,7,2) as integer) else null end as age
			
		---------------------------------------------------------------------------------------
		
		--科目收入
		select par_month_id, subst_name,branch_name,area_name,sum(fee_all) as fee_sh
		from zone_gz_yz.dwm_srhx_src_income_list_mon
		where  month_id=202401 
		--and contract_flag=1 --划小收入
		--flag=1  号码级收入（比如漫游是出在虚拟号码上的收入，会落到分局，但不是真实号码）
		--and is_filter='0' 考核收入
		--and substr(a.due_income_code,1,8) not in ('SR014101','SR014102','SR014109','SR014201',
		     --'SR024101','SR024102','SR024109','SR024201','SR034101','SR034102','SR034109','SR034201' ) 剔除非主营收入（圈定一批科目是非主营科目）
		and due_income_code in
		('SR03240103',
		'SR0335020201',
		'SR0335020202',
		'SR03240101',
		'SR0335020101')  --限制科目（必须是子节点，该字段不存在父节点）
		group by par_month_id, subst_name,branch_name,area_name
		
		--查询是否子节点（is_node=1是子节点）
		select  is_node,count(1) from  dwd_yz_dim_due_income --科目结构维表
		where par_month_id=202401 
		and due_income_code in
		('SR03240103','SR0335020201','SR0335020202') group by is_node

		---------------------------------------------------------------------------------------
		
		--按网点取FTTR的揽装量
		select count(distinct eqpt_sn) from dwm_fttr_list where salestaff_channel_nbr in () and par_month_id= and create_date>
		
		---------------------------------------------------------------------------------------
		
		一般加这个
		use zone_gz_yz;
		set hive.vectorized.execution.enabled=false;
		set hive.vectorized.execution.reduce.enabled=false;

		还是资源不足改成这个
		use zone_gz_yz;
		set hive.vectorized.execution.enabled=false;
		set hive.vectorized.execution.reduce.enabled=false;
		set hive.auto.convert.join=false;
		set hive.map.aggr=false;
		
		---------------------------------------------------------------------------------------

		drop table if exists zone_gz_yz.xxx_2 purge;
		create table zone_gz_yz.xxx_2 
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
		as
		select a.*,b.acct_id 
		from xxx_1 a
		left join dws_crm_cust.dws_prod_inst_acct_rel_aap b on a.serv_id = b.prod_inst_id and b.city_id=200 ;
		
		drop table if exists zone_gz_yz.xxx_3 purge;
		create table zone_gz_yz.xxx_3 
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
		as
		select a.* 
		,(case when length(c.pay_acct_name)<4 then c.pay_acct_name
		when length(c.pay_acct_name)=4 then concat(SUBSTR(c.pay_acct_name,1,2),'**')
		when length(c.pay_acct_name)>4 then concat(SUBSTR(c.pay_acct_name,1,(length(c.pay_acct_name)-4)),'****')
		else null end) as  c.pay_acct_name_tm  --银行账户名称
		,c.acct_owner_org_branch  --开户组织分支机构，银行id
		from xxx_2 a 
		left join dws_crm_cust.dws_payment_plan b on a.acct_id = b.acct_id and b.city_id=200 
		left join dws_crm_cust.dws_ext_acct c on b.pay_acct_id = c.ext_acct_id and c.city_id=200 ;
		
		drop table if exists zone_gz_yz.xxx_4 purge;
		create table zone_gz_yz.xxx_4 
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
		as
		select a.* 
		,b.bank_name
		from xxx_3 a 
		left join dws_crm_cfguse.dws_tb_cm_bank b on 
		
		---------------------------------------------------------------------------------------
		
		
		公允后出账收入统一用大宽表的 fee
		公允前出账收入： 
		select serv_id,sum(charge)/100 as fee
		from summary_ods_month_city.tb_comm_serv_fee_mon
		where par_corp_id=200
		and par_month_id=$sum_month
		and ACCT_SOURCE=1  --公允前
		group by serv_id

		
		
		
		匹action_id的名称：select prod_service_rel_id as action_id,action_name from dws_crm_cfguse.dws_prod_service_offer_rel where city_id=200
		---------------------------------------------------------------------------------------
		何纬斌直销客户维表：当前表：view_yz_xqgzXQGZ2025012300554/ 月表ads_yz_mo_ccust_mdz_mon_final
		直销客户维表：select * from dws_ecust.dws_mo_ccust limit 10
		产权对应的直销客户维表：dws_yz_tb_mo_custgrp_cust_final 
			select attr_id,attr_inner_value
			,attr_value_name --重点客户类型
			,attr_value_sort  from  dws_crm_cfguse.dws_attr_value where city_id=200
			and attr_id='400003971'  关联条件 vip_flag=attr_inner_value
			
		P码维表：select party_id,party_nbr from dws_ecust.dws_party_zq where city_id=200 
		P码对应的产权维表：select party_id,cust_id from dws_ecust.dws_party_zq_fcust_rel where city_id=200 
		
		--20240203新增，直销客户类型， attr_id='4000094004' ，1 现实客户  2 -  4 潜在客户
		drop table tmp_ndhs_2023_20240203_ccust_rule_list_new;
		create table tmp_ndhs_2023_20240203_ccust_rule_list_new
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')        
		as

		select a.*,b. cust_state
		from tmp_ndhs_2023_20240203_ccust_rule_list a
		left join 
		(select ccust_id,cust_state from dws_ecust.dws_mo_ccust where city_id=200) b
		on a.ccust_id=b.ccust_id;
		---------------------------------------------------------------------------------------
		
		大宽表视图的省标签打标逻辑：
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
		
		---------------------------------------------------------------------------------------
	
		select 字段1,字段2，collect_list(itv_nbr) from xxx group by 字段1,字段2
		将itv号码作为一个列表存在一个字段下
		---------------------------------------------------------------------------------------
		
		省表优惠资料表：月表 iodata_ods_month_city.rpt_comm_cm_msdisc_mon
		日表 summary_ods_day_city.rpt_comm_cm_msdisc
		
		---------------------------------------------------------------------------------------
		
		查询创建视图的语句：desc formatted 视图名;
		
		收入清单：
		【CDAP收入月生产 20231206】
		202311
		最终版划小收入清单（IDC号码特殊处理、以及 部分月份基本面数据特殊处理）
		zone_gz_yz.dwm_srhx_serv_list_mon_final --历史数据分区表

		全量科目级收入清单；
		zone_gz_yz.dwm_srhx_src_income_list_mon --历史数据分区表

		全量号码资料宽表（在网号码+近6个月拆机号码），供收入数据打标号码相关信息
		zone_gz_yz.dwm_srhx_serv_final_mon--历史数据分区表

		基本面号码级收入原始表（注：无号码标签信息）
		zone_gz_yz.dwm_srkh_fmincome_list_mon

		基本面科目级收入原始表（注：无号码标签信息）
		zone_gz_yz.dwm_srhx_jbm_src_income_list_mon

		已具备，请阅知，谢谢。
		
		---------------------------------------------------------------------------------------
		cdap教程文档：
		https://b.cloud.189.cn/s/fYbA7vjM3Mvi
		32J8
		---------------------------------------------------------------------------------------
		
		hql节点参数
		--上月：date_format(add_months(from_unixtime(unix_timestamp(concat(a.par_month_id,'01'),'yyyyMMdd'),'yyyy-MM-dd'), -1),'YYYYMM')
		--当月底：date_format(last_day(from_unixtime(unix_timestamp(Concat('${yyyymm}','01'),'yyyyMMdd'),'yyyy-MM-dd')),'yyyyMMdd')
		
		---------------------------------------------------------------------------------------
		select acc_nbr,
		cast(NET_FLUX/1048576 as numeric(22,2)),--流量(M)  
		--cast(NET_innet_DUR/60 as numeric(22,2)),--时长  
		cast(NET_DURATION/60 as numeric(22,2)) --上网时长
		IS_ACTIVE_USER,is_fee_user,is_cancel_user
		from summary_ods_month_city.tb_comm_ywl_data_mon where month_id=202212 and acc_nbr in
		---------------------------------------------------------------------------------------
		
		实收表 dwd_yz_if_real_src_sum_new_final 已具备，字段同IQ表if_real_src_sum_new
		根据省数据源具备情况已回溯至202301
		另202308数据源缺失，待省处理后修复，请阅知，谢谢！
		---------------------------------------------------------------------------------------
		
		v_table_name_obj_xx="zone_gz_yz.dwd_yz_cm_obj_xx_mon_final" --号码协销人模型
		select a.*,xx_salestaff_id1,xx_salestaff_code1,xx_salestaff_name1,xx_salestaff_id2,xx_salestaff_code2,xx_salestaff_name2
		from zone_gz_yz.tmp_ads_yz_kd_new_list_08 a
		left join "${v_table_name_obj_xx}" b 
					  on a.serv_id=b.serv_id "${v_par_month_b}"
		
		---------------------------------------------------------------------------------------
		

		有需要跑月出帐版清单的话，只需要在自己的流程里新增一个触发器，比如每月7号上午9点调出账版，新增触发器设置为：

		生成方式：T+7（按调起的时间设置，比如每月8号，则改成T+8）
		调度日期：日
		触发类型：定时
		定时调度：每月 日9 点0 分0
		---------------------------------------------------------------------------------------
		
		新上线移机宽表，dwd_yz_rpt_comm_ba_subs_move_final 已回溯至202201，可以先测试使用，有要调整的及时反馈，后续就正式挂队列运行。
		---------------------------------------------------------------------------------------
		
		202309账期开始，6份酬金相关报表下发地市的访问路径有变（由summary_jf_month_city.ads_...，改为，summary_cj_month_szx/city.tb...），请各分公司自行进权限申请；
		1) 包区-结算网点表:        summary_jf_month_city.ads_tb_mgr_area_channel_mon -> summary_cj_month_szx.tb_mgr_area_channel_mon，分区：par_month_id='#SUM_MONTH'
		2) 包区-网点-揽装人表:     summary_jf_month_city.ads_tb_mgr_area_channel_staff_mon -> summary_cj_month_szx.tb_mgr_area_channel_staff_mon，分区：par_month_id='#SUM_MONTH'
		3) 包区-网点-装维经理维表: summary_jf_month_city.ads_tb_mgr_area_channel_staff_zw_mon -> summary_cj_month_szx.tb_mgr_area_channel_staff_zw_mon，分区：par_month_id='#SUM_MONTH'
		4) 包区月因子清单宽表:     summary_jf_month_city.ads_tb_bq_cell_list_mon -> summary_cj_month_city.tb_bq_cell_list_mon，分区：par_month_id='#SUM_MONTH'，par_corp_id = '#SUM_CORP_ID'
		5) 包区酬金指标结果宽表:      summary_jf_month_city.ads_tb_bq_m_yj_mon -> summary_cj_month_city.tb_bq_m_yj_mon，分区：par_month_id='#SUM_MONTH'，par_corp_id = '#SUM_CORP_ID'
		6) 包区酬金指标结果宽表-清单级:      summary_jf_month_city.ads_tb_bq_m_yj_dtl_mon -> summary_cj_month_city.tb_bq_m_yj_dtl_mon，分区：par_month_id='#SUM_MONTH'，par_corp_id = '#SUM_CORP_ID'

		---------------------------------------------------------------------------------------
		
		3、公允前出账：sum(a1+a5+a12) 公允前,sum(a1+a4+a5+a12) 公允后
		a0-确认收入税前 a1-后付费出账                a2-调账                a3-退费
		a4-公允摊分                a5-预付费出账                a6-记不列                a7-记补列                a8-一次性收入
		a9-结算分成                a10-上网后赠金                a11-流量不清零（流量递延)                a12-终端递延减收
		a13-翼支付红包金减收  tax_charge-税金  b1-积分计提  b2-积分计提递延  b3-积分兑换
		b4-移动数据漫游结算支出  b5-行业短信结算支出  b6-IDC带宽包区调整
		
		select serv_id, 
		sum(a0) as sh_qr,--税后确认收入
		sum(a0_sq) as sh_sq,--税前确认收入
		sum(fee_fm_new) as sh_jbm,--最终基本面收入（不用限制条件，已是全量：移动、宽带、固话、ITV 收入）
		sum(a8) as sh_ycx --一次性税后收入
		from zone_gz_yz.dwm_srhx_serv_list_mon_final
		where par_month_id = 202309
		group by serv_id

		,sum(charge-tax_charge)/100 as a0
		,sum(charge)/100 as a0_sq
		,sum(tax_charge)/100 as a0_sj

		--非手工总收入
		,sum(case when flag in (1,2,3) then charge-tax_charge else 0 end )/100 as a0_fsg
		,sum(case when flag in (1,2,3) then charge else 0 end )/100 as a0_fsg_sq
		,sum(case when flag in (1,2,3) then tax_charge else 0 end )/100 as a0_fsg_sj

		--手工总收入
		,sum(case when flag in (4) then charge-tax_charge else 0 end )/100 as a0_sg
		,sum(case when flag in (4) then charge else 0 end )/100 as a0_sg_sq
		,sum(case when flag in (4) then tax_charge else 0 end )/100 as a0_sg_sj

		--号码级收入
		,sum(case when flag=1 then charge else 0 end )/100 as fee_nbr_sq 
		,sum(case when flag=1 then charge-tax_charge else 0 end )/100 as fee_nbr 
		--非号码级收入
		,sum(case when flag in (2,3) then charge else 0 end )/100 as fee_nonbr_sq 
		,sum(case when flag in (2,3) then charge-tax_charge else 0 end )/100 as fee_nonbr 

		--产数收入
		,sum(case when substr(a.due_income_code,1,5) in ('SR013','SR023','SR033')  then charge else 0 end)/100 as fee_cs_sq
		,sum(case when substr(a.due_income_code,1,5) in ('SR013','SR023','SR033')  then charge-tax_charge else 0 end)/100 as fee_cs


		--后付费出账
		,sum(case when flag=1 and data_src_type = 101 then charge else 0 end)/100 as a1_sq 
		,sum(case when flag=1 and data_src_type = 101 then charge-tax_charge else 0 end)/100 as a1 
		--调账
		,sum(case when flag=1 and data_src_type = 102 then charge else 0 end)/100 as a2_sq
		,sum(case when flag=1 and data_src_type = 102 then charge-tax_charge else 0 end)/100 as a2 
		--退费
		,sum(case when flag=1 and data_src_type = 103 then charge else 0 end)/100 as a3_sq 
		,sum(case when flag=1 and data_src_type = 103 then charge-tax_charge else 0 end)/100 as a3 
		--公允摊分
		,sum(case when flag=1 and data_src_type = 104 then charge else 0 end)/100 as a4_sq 
		,sum(case when flag=1 and data_src_type = 104 then charge-tax_charge else 0 end)/100 as a4 
		--预付费出账
		,sum(case when flag=1 and (col_income_code in ('GW_N001','NO_N001','NO_N004') or data_src_type=1012) then charge else 0 end)/100 as a5_sq 
		,sum(case when flag=1 and (col_income_code in ('GW_N001','NO_N001','NO_N004') or data_src_type=1012) then charge-tax_charge else 0 end)/100 as a5
		--计不列
		,sum(case when flag=1 and data_src_type = 120 then charge else 0 end)/100 as a6_sq 
		,sum(case when flag=1 and data_src_type = 120 then charge-tax_charge else 0 end)/100 as a6 
		--计补列
		,sum(case when flag=1 and data_src_type in( 1341,1342 ) then charge else 0 end)/100 as a7_sq
		,sum(case when flag=1 and data_src_type in( 1341,1342 ) then charge-tax_charge else 0 end)/100 as a7
		--一次性收入
		,sum(case when flag=1 and data_src_type = 109 then charge else 0 end)/100 as a8_sq
		,sum(case when flag=1 and data_src_type = 109 then charge-tax_charge else 0 end)/100 as a8
		--结算分成
		,sum(case when flag=1 and data_src_type = 600 then charge else 0 end)/100 as a9_sq
		,sum(case when flag=1 and data_src_type = 600 then charge-tax_charge else 0 end)/100 as a9
		--上网后赠金
		,sum(case when flag=1 and data_src_type = 111 then charge else 0 end)/100 as a10_sq
		,sum(case when flag=1 and data_src_type = 111 then charge-tax_charge else 0 end)/100 as a10
		--流量不清零
		,sum(case when flag=1 and col_income_code in ( 'N011_B0105_CBSDY','N011_B0105_CBSSY','N011_B0105_OCSDY','N011_B0105_OCSSY' ) then charge else 0 end)/100 as a11_sq 
		,sum(case when flag=1 and col_income_code in ( 'N011_B0105_CBSDY','N011_B0105_CBSSY','N011_B0105_OCSDY','N011_B0105_OCSSY' ) then charge-tax_charge else 0 end)/100 as a11 
		--终端递延减收
		,sum(case when flag=1 and col_income_code in ( 'N012_B0106','N013_B0106','N014_B0106' ) then charge else 0 end)/100 as a12_sq
		,sum(case when flag=1 and col_income_code in ( 'N012_B0106','N013_B0106','N014_B0106' ) then charge-tax_charge else 0 end)/100 as a12
		--翼支付红包金减收
		,sum(case when flag=1 and data_src_type = 128 then charge else 0 end)/100 as a13_sq
		,sum(case when flag=1 and data_src_type = 128 then charge-tax_charge else 0 end)/100 as a13

		--政企科目税后收入
		,sum(case when a.flag in (1,2,3) and substr(a.due_income_code,4,1)='1' then charge else 0 end)/100 as zq_charge_sq
		,sum(case when a.flag in (1,2,3) and substr(a.due_income_code,4,1)='1' then charge-tax_charge else 0 end)/100 as zq_charge	


		--积分计提
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =10535  then charge else 0 end)/100 as b1_sq
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =10535  then charge-tax_charge else 0 end)/100 as b1
		--积分计提递延
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =105351 then charge else 0 end)/100 as b2_sq
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =105351 then charge-tax_charge else 0 end)/100 as b2
		--积分兑换
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =10545 then charge else 0 end)/100 as b3_sq
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =10545 then charge-tax_charge else 0 end)/100 as b3
		--移动数据漫游结算支出
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =999440 then charge else 0 end)/100 as b4_sq
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =999440 then charge-tax_charge else 0 end)/100 as b4
		--行业短信结算支出
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =99970061 then charge else 0 end)/100 as b5_sq
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =99970061 then charge-tax_charge else 0 end)/100 as b5
		--IDC带宽包区调整
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =999933 then charge else 0 end)/100 as b6_sq
		,sum(case when flag in (2,3) and data_src_type = 300 and data_src_detail_type =999933 then charge-tax_charge else 0 end)/100 as b6

		--产数收入不含一次性费用
		,sum(case when substr(a.due_income_code,1,5) in ('SR013','SR023','SR033') and data_src_type not in (109) then charge else 0 end)/100 as fee_cs_sq_ycx
		,sum(case when substr(a.due_income_code,1,5) in ('SR013','SR023','SR033') and data_src_type not in (109) then charge-tax_charge else 0 end)/100 as fee_cs_ycx

		--总收入不含一次性费用
		,sum(case when data_src_type not in (109) then charge-tax_charge else 0 end )/100 as a0_ycx
		,sum(case when data_src_type not in (109) then charge else 0 end )/100 as a0_sq_ycx

		
		---------------------------------------------------------------------------------------
		固话业务省表：summary_ods_month_city.tb_comm_ywl_gw_mon
		------------------------------------------------------------------------------------
		
		拆机月份：抽所有拆机号码的小表，赋权出去让县分关联
		
		------------------------------------------------------------------------------------
		--客户名称脱敏:
		(case when length(cust_name)<2 then cust_name
		when length(cust_name)=2 then concat(SUBSTR(cust_name,1,1),'*')
		when length(cust_name)>2 then concat(SUBSTR(cust_name,1,(length(cust_name)-2)),'**')
		else null end) as  cust_name_tm
		
		(case when length(acc_nbr)<2 then '*'
              when length(acc_nbr)=2 then concat(SUBSTR(acc_nbr,1,1),'*')
              when length(acc_nbr)<8 then concat(SUBSTR(acc_nbr,1,(length(acc_nbr)-2)),'**')
              when length(acc_nbr)>=8 then concat(SUBSTR(acc_nbr,1,length(acc_nbr)-8),'****',SUBSTR(acc_nbr,length(acc_nbr)-3,length(acc_nbr)))
              else '*' end) as  acc_nbr_tm  --脱敏号码
		
		
		--核查套餐积分
		1.先用号码找这2个月rh_tc_id，然后用套餐ID看每个号码的积分变化，一般提值会体现在移动上，看有没有
		2.如果是降值，看看是哪个号码降
		3.select * from summary_jf_day_city.ads_tb_score_d_all_disc_mon
		where par_month_id>=202308 and par_corp_id=200 and serv_id in (89003627785910,320000052639471)
		可以看降值号码的原因
		4.如果上面这个看不出来，可以再看
		select 
		*
		from summary_jf_month_city.ads_tb_score_all_list_cz_mon b where b.city_mark='GZ' and b.yyyymm='$sum_month'
		这里的情况
		------------------------------------------------------------------------------------------------------------------------

		## 判断ITV是否活跃
		drop table if exists zone_gz_yz.temp_dwd_tygq_kjcs_list_01;
		create table if not exists zone_gz_yz.temp_dwd_tygq_kjcs_list_01 as 
		select user_id,
		sum(case when yyyymmdd between '$this_month_first_date' and '$stat_date' then coalesce(cast(login_times as decimal),0) else 0 end) login_times_m,                --本月开机次数
		sum(case when yyyymmdd between '${last_month_first_date}' and '${last_month_last_date}' then coalesce(cast(login_times as decimal),0) else 0 end) login_times_m_last,                --上月开机次数
		sum(case when yyyymmdd between '${last_2month_first_date}' and '${last_2month_last_date}' then coalesce(cast(login_times as decimal),0) else 0 end) login_times_m_last2,                --前两月月开机次数
		sum(case when yyyymmdd between '${last_3month_first_date}' and '${last_3month_last_date}' then coalesce(cast(login_times as decimal),0) else 0 end) login_times_m_last3,                --前3月开机次数
		sum(case when yyyymmdd between '$this_year_first_day' and '$stat_date' then coalesce(cast(login_times as decimal),0) else 0 end) login_times_y1,        --今年开机次数
		sum(case when yyyymmdd between '$last_yar_first_day' and '$last_year_last_date' then coalesce(cast(login_times as decimal),0) else 0 end) login_times_y2                --去年开机次数
		from dws_znyypt.dws_login_list 
		where yyyymmdd between '$last_yar_first_day' and '$stat_date' and areaname='广州'
		group by user_id;
		
		select a.*,(case when b.login_times_m>=1 then 1 else 0 end ) as is_hy_m,---当月开机次数>=1
		(case when b.login_times_m_last>=1 then 1 else 0 end ) as is_hy_m_last,---上月开机次数>=1
		(case when b.login_times_m_last2>=1 then 1 else 0 end ) as is_hy_m_last2,---前2月开机次数>=1
		(case when b.login_times_m_last3>=1 then 1 else 0 end ) as is_hy_m_last3,---前3月开机次数>=1
		(case when b.login_times_y1>=1 then 1 else 0 end ) as is_hy_y1,---当年开机次数>=1
		(case when b.login_times_y2>=1 then 1 else 0 end ) as is_hy_y2  --去年开机次数>=1
		from   zone_gz_yz.dwd_yz_tygq_yy_list_03 as a 
		left  join temp_dwd_tygq_kjcs_list_01  as b 
		on a.acc_nbr=b.user_id;
		------------------------------------------------------------------------------------------------------------------------
		
		--手机合约
		终端合约：
		dwd_yz_cdma_hy_list
		where  data_type='合约' 
		手机合约口径：
		dwd_yz_cdma_hy_list
		where  data_type='合约' and is_sjhy=1
		------------------------------------------------------------------------------------------------------------------------
		
		中间层资料表常用字段：
		sales_id --揽装人id
		sales_code  --揽装人工号
		sales_name  --揽装人名称
		channel_nbr --网点编码
		channel_name  --网点名称
		grid_id  --营销网格id
		grid_code  --营销网格编码
		grid_name  --营销网格名称
		cell_id  --网格id
		cell_code  --网格编码
		cell_name  --网格名称
		serv_addr_id  --地址id
		is_new_user  --是否新入网
		staff_id  --受理人id
		prod_type2 --产品小类
		prod_type3  --低值宽带类型
		is_cz,  --是否出账
		is_cz_last  --是否上月出账
		is_mdz  --是否名单制
		bu_type  --BU
		jz_points  --号码价值积分
		channel_subst_name  --揽装分局
		channel_branch_name  --揽装营服
		channel_type  --网点类型
		is_gsm  --是否公司名

		
		-------------------------------------------------------------------------------
		
		修改小业务宽表配置表：
		drop table dwd_dim_all_config_bf_20240307 purge;
		create table dwd_dim_all_config_bf_20240520 as select * from dwd_dim_all_config;--695
		
		--select distinct offer_id,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200 and prod_offer_code in()
		
		drop table tmp_dwd_dim_all_config_xz;--344
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
		from dwd_dim_all_config_bf_20240520 where COALESCE(seq_id,-1) not in(12)
		union all
		select seq_id,seq_name,seq_value_id,seq_value_code,create_date,create_man,state_desc,reamark,reamark_bc,seq_type 
		from tmp_dwd_dim_all_config_xz ) a;
		

		新增附属产品：
		use zone_gz_yz;
		set hive.exec.parallel=true;
		set hive.exec.parallel.thread.number=32;
		set hive.vectorized.execution.enabled=false;
		set hive.vectorized.execution.reduce.enabled=false;
		set hive.exec.parallel=true;

		drop table if exists  tmp_dwd_yz_xyw_final_sub_prod_id_tyyp;
		create table tmp_dwd_yz_xyw_final_sub_prod_id_tyyp 
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
		as 
		select b.reamark xyw_lx,b.seq_name xyw_name,b.seq_value_id,b.seq_value_code,b.seq_type,a.cust_id,a.serv_id,a.state_date as create_date,
		cast(null as timestamp) open_date,cast(null as timestamp) as limit_date,a.attr_id,a.attr_value1 as attr_value,a.prod_id,a.acc_nbr,cast(null as decimal(22,0)) as msinfo_id
		from (select * from summary_ods_day_city.rpt_comm_cm_subserv where par_corp_id=200) a
		join (select *  from dwd_dim_all_config where seq_id=12 and seq_type='sub_prod_id' and  seq_name='天翼云盘') b
		on a.sub_prod_id=b.seq_value_id;

		use zone_gz_yz;
		set hive.exec.parallel=true;
		set hive.exec.parallel.thread.number=32;
		set hive.vectorized.execution.enabled=false;
		set hive.vectorized.execution.reduce.enabled=false;
		set hive.exec.parallel=true;

		drop table if exists  tmp_dwd_yz_xyw_final_sub_prod_id_txzl;
		create table tmp_dwd_yz_xyw_final_sub_prod_id_txzl 
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')	
		as 
		select b.reamark xyw_lx,b.seq_name xyw_name,b.seq_value_id,b.seq_value_code,b.seq_type,a.cust_id,a.serv_id,a.state_date as create_date,
		cast(null as timestamp) open_date,cast(null as timestamp) as limit_date,a.attr_id,a.attr_value1 as attr_value,a.prod_id,a.acc_nbr,cast(null as decimal(22,0)) as msinfo_id
		from (select * from summary_ods_day_city.rpt_comm_cm_subserv where par_corp_id=200) a
		join (select *  from dwd_dim_all_config where seq_id=12 and seq_type='sub_prod_id' and  seq_name='通信助理') b
		on a.sub_prod_id=b.seq_value_id;
		
		
	insert into table tmp_dwd_yz_xyw_final
    select *  from 
    (select *  from tmp_dwd_yz_xyw_final_sub_prod_id_tyyp 
    union all
    select *  from tmp_dwd_yz_xyw_final_sub_prod_id_txzl) a;
		
		-------------------------------------------------------------------------------
		
		修改低值宽带类型配置表：
		drop table if exists dwd_dim_dzkd_offer_20240301 purge;
		create table dwd_dim_dzkd_offer_20240301 as select * from dwd_dim_dzkd_offer;--76
		
		--select distinct offer_id,prod_offer_code from dws_crm_cfguse.dws_offer where city_id=200 and prod_offer_code in()
		
		drop table if exists tmp_dwd_dim_dzkd_offer_xz;--78
		create table tmp_dwd_dim_dzkd_offer_xz as 
		select cast(index1  as int) type_id
		,cast(index2  as string) type
		,cast(index3  as int) prod_offer_id
		,cast(index4  as string) prod_offer_code
		,cast(index5  as string) prod_offer_name
		,cast(index6  as string) fk_lx
		,cast(index7  as string) fk_value

		from zone_gz_yz_3351225714708480;
		
		drop table if exists dwd_dim_dzkd_offer purge;
		create table dwd_dim_dzkd_offer 
		row format delimited fields terminated by '\u0001' stored as orc tblproperties('orc.compression'='snappy')
		as
		select * from tmp_dwd_dim_dzkd_offer_xz;
		
		insert overwrite table dwd_dim_dzkd_offer
		select type_id,type,prod_offer_id,prod_offer_code,prod_offer_name,fk_lx,fk_value from (
		select type_id,type,prod_offer_id,prod_offer_code,prod_offer_name,fk_lx,fk_value 
		from tmp_dwd_dim_dzkd_offer_xz);
		
		--20240718  新增酒宽6个销售品 需求单：XQGZ2024070501630
		--B59改成新增 YD0001-B59-1-5 和 YD0001-B59-1-6，核查发现已在原表，无需新增
		drop table if exists dwd_dim_dzkd_offer_20240301 purge;
		create table dwd_dim_dzkd_offer_20240719 as select * from dwd_dim_dzkd_offer;--78
		
		insert into table dwd_dim_dzkd_offer 
		select 26 as type_id,'酒店宽带' type,
		offer_id,prod_offer_code,offer_name,'' as fk_lx,'' as fk_value
		from dws_crm_cfguse.dws_offer where city_id=200 
		and prod_offer_code in(--'YD0001-B59-1-1','YD0001-B59-1-3','YD0001-B59-1-2','YD0001-B59-1-4'
		--'YD0001-B59-1-5','YD0001-B59-1-6',
		'DM0001-543-1-1','DM0001-543-1-3','DM0001-543-1-4','DM0001-543-1-5');

		------------------------------------------------------------------------------
		--号码客户经理
		select a.serv_id,a.owner_id,b.staff_name from dws_grid.dws_grid_serv_staff a 
		left join (select staff_id,staff_name,
		row_number() over(partition by staff_id order by status_date desc) row_num
		from dws_crm_cfguse.dws_staff where city_id=200 ) b
		on a.owner_id=b.staff_id and b.row_num=1;
		where a.appart_type = '1000'
		and a.owner_type = 'STAFF'
		
		
		--直销客户经理
		select a.serv_id serv_id4
		,c.staff_name as owner_name --直销客户经理
		,c.staff_id  --直销客户经理揽装工号ID
		from xxx a
		left join (select manager_id,ccust_id,
		row_number() over(partition by ccust_id order by status_date desc) row_num
				 from dws_ecust.dws_mo_ccust_management
				 where city_id='200' and status_cd='1000' and manager_type='DUTY')b
		on a.ccust_id = b.ccust_id and b.row_num=1
		left join (select staff_id,staff_name,
		row_number() over(partition by staff_id order by status_date desc) row_num
		from dws_crm_cfguse.dws_staff where city_id=200 and status_cd='1000') c
		on b.manager_id=c.staff_id and c.row_num=1;
		
		----直销客户经理揽装工号
		table_name3="dwd_yz_sales_man_outlers_mon_final"
		select a.*,b.sales_code
		left join (select staff_id,sales_code,sales_man_name,channel_id,channel_nbr,channel_name,
		subst_id,branch_id,area_id 
		from ${table_name3} where 1=1 ${v_par_month}) b
		on a.staff_id=b.staff_id;
  
	---------------------------------------------------------------------------------
		
		使用 summary_ods_day_city.rpt_comm_cm_serv_hist 表时，
		需要加分区条件，分区day_id跟拆机时间hist_create_date是对应的
		------------------------------------------------------------------------------
		cdap订单表必须日表 zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final  
		union 月表 zone_gz_yz.dwm_yz_rpt_comm_ba_subs_mon_final，
		不限月份，限act_date才能统计受理量，因此受理量指标废弃
		-------------------------------------------------------------------------------
		
		帆软渠道维表：select * from app_sjjy_gz.dwd_dim_channel_subtype_pg order  by  dim_order
		------------------------------------------------------------------------
		cdap 大宽表入网时间 open_date is_new_user=1
		优惠资料表 open_date 套餐生效时间  limit_date  套餐到期时间  create_date  套餐竣工时间 
		优惠订单表 open_date:号码入网时间，受理时间 act_date 竣工时间 subs_stat_date ，没有生效和失效时间
		订单表 受理时间 act_date 竣工时间 subs_stat_date 
		
		原来旧的口径
		一、sales_man、staff_id 形成 dwd_yz_sales_man_final 表
		sales_man 和 staff_id 关联，找到 sales_code 对应的唯一最晚修改且状态正常的 staff_id

		二.sale_outlers 形成 dwd_yz_sale_outlers_final 表
		1.只保留 sale_outlers 本来的字段

		三.dwd_yz_sales_man_outlers_final
		sales_man 和 sales_man_outlers 关联


		计划新的口径
		一.sales_man 形成 dwd_yz_sales_man_final 表
		1.只保留 sales_man 本来的字段，用于存放渠道统一视图的字段
		2.不再设置 crm_staff_id 用于和 salesataff_id/sales_id 关联

		二.sale_outlers 形成 dwd_yz_sale_outlers_final 表
		1.只保留 sale_outlers 本来的字段

		三.dwd_yz_sales_man_outlers_final
		改变取数逻辑
		1.首先提取 staff 表里的，sales_ocde 不为空或大于0的,staff_id
		2.通过 staff_id 表里的 sales_code 打标 sales_man 里面的字段 （筛选）
		3.通过 sales_man 里的 own_channel_id 打标 sale_outlers 里面的字段 （筛选）
		
		dwd_yz_sales_man_final、dwd_yz_sale_outlers_final、dwd_yz_sales_man_outlers_final、staff 这4个都有月表
		
		揽装人 zone_gz_yz.dwd_yz_sales_man_final 数据唯一
		网点 zone_gz_yz.dwd_yz_sale_outlers_final 数据唯一
		揽装所属 zone_gz_yz.dwd_yz_sales_man_outlers_final sales_code 不唯一，staff_id 和 sales_code 是1对多，只能用 staff_id 关联
		
		
		核查无号码收入的网点：
		select * from dwd_yz_sales_man_outlers_mon_final where par_month_id=202312
		and channel_nbr in(SELECT index2 FROM tmp_20240117_yytsr_qdbm) 
		limit 1000
		dwd_yz_sales_man_outlers_mon_final 这个是揽装网点对应表，只有有效网点+有效揽装人才会在这个表里

		dwd_yz_sales_man_final：这是揽装人维表（日表/月表_mon_），可以看一下揽装人是否有效(status_cd=S0X就是无效)，网点ID own_channel_id

		dwd_yz_sale_outlers_final：这是网点维表（日表/月表_mon_），可以看一下网点是否有效(status_cd=S0X就是无效) 网点ID channel_id

		通过这三个表查一下没收入和号码的网点，哪些是因为网点无效，哪些是因为网点没有揽装人，哪些网点有揽装人但是揽装人无效

		无效网点，有效网点但无揽装人，有效网点但揽装人无效，这些都不会发展号码和收入，因为网点是通过有效揽装人打标的
		
		-------------------------------------------------------------------------------------------------
		
		7级地址的维表:select *  from ads_yz_tyks_addr_7
		------------------------------------------------------------------------------------------------
		
		杨洋 9-13 15:30:59
		如果要取网点扩展信息,可以 
		select *  from channel_attribute where channel_obj_id=70071068
		select *  from attr_spec where attr_id in (110036,110037)
		----------------------------------------------------------------------
		
		如果发现宽带的历史数据量与本地不一样，
		可以留意下是否是prod_id=2340，
		省公司月表会特殊为集团做个处理，
		会把部分宽带号码的net_connect_type置为空，
		所以会出现有号码mainstream_net_type有值，net_connect_type没值的情况
		
		rptdev.rpt_comm_cm_prod_attr_union  --产品规格属性资料表当前表+产品规格属性资料表年表
		CDAP是 summary_ods_day_city.tb_pre_cm_attr_all where par_corp_id=200 --产品规格属性资料表日表
		iodata_ods_month_city.tb_pre_cm_attr_all_mon where par_corp_id=200 and par_month_id=202203 --产品规格属性资料表月表
		
		
		--余额口径
		drop table tmp_yy;
		create table tmp_yy as select a.acc_num,a.cur_amount,a.acct_balance_id
		from (select acc_num,acct_balance_id,cur_amount from dws_acct.dws_balance_source where city_id=200 and status_cd='1') a  
		join (select distinct acct_balance_id from dws_acct.dws_acct_balance where city_id=200 and status_cd='1'  
		and balance_type_id in (select balance_type_id from dws_conf_center.dws_balance_type where city_id=200 and if_principal = 1 and status_cd='1')) b 
		on a.acct_balance_id=b.acct_balance_id;
		--a表看号码余额，b/c表关联锁定为本金(if_principal = 1)的余额账本
		select acc_num,sum(coalesce(cur_amount,0))/100   from tmp_yy group by acc_num
		----------------------------------------------------------------------------------------------------
		
		six_market
		stm_data
		mou_call
		mgs_counts
		is_hy
		is_yx
		is_cz
		xh_type_desc
		fee
		fee_nbr
		fee_new_tax
		jz_points
		rh_tc_value
		kj_num
		tc_points
		disc_yx_points
		is_disc_yx
		--目前是这些字段会更新出账版
		
		cdap 条件为not in 或者<>，会剔除为空的部分，所以一定要用coalesce(prod_id,-1) not in(3204,3205)做替换
		
		
		物理拆机 is_wl_cancel_user=1
		主动拆机+欠费拆机 is_wl_cancel_user=1 and wl_cancel_type in  ('103','116')
		领导看板 徐海涵定的口径是主动拆机+计转非-非转计
		主动拆机 is_wl_cancel_user=1 and wl_cancel_type in  ('103')
		计转非 is_cz_last=1 and is_cz=0 and is_wl_cancel_user=0
		非转计 is_cz_last=0 and is_cz=1 and state_last<>'140001'--剔除上月新装
		
		cdap清单表和中间层宽表在建表结构先预留30个空字段 null_column1 - null_column30，后续如要新增字段，不用重建表，直接修改空字段名就可以
		alter table xxxx change null_column1 新字段名;commit;
		
		
		通用报表规范：
		1、表头通用命名：县分、营服、包区
		2、三级穿透sheet通用命名：sheet1 机构维度，sheet2 其他维度
		3、机构维度表头列宽：县分22，营服44，包区66（居中）
		4、其他维度渠道列宽：大中小类分别为：22,35,35 （居中）
		渠道通用展示规范：
		dwd_dim_channel_subtype_rb --日报渠道维表
		dwd_dim_channel_subtype_pg --pg报表表头排序用渠道维表
		可参考案例报表：移动日报_月净增     JY_2_200_SC_D_7386
		
		
		杨洋 7-25 10:45:50
		公免公纳，统一用 fee_id in (1,2)
		省中间层的标签，1公免2公纳3普通电话
		
		杨洋 7-21 16:46:49
		查询高存储大表：hadoop fs -du -h /apps/zone_gz_yz/hive/* |egrep -v '^0' |sed 's/\([0-9.]\)\( \)\(.*\)/\1\3/g'  |sort -hrk1  |head -200
		*/
		
		低值宽带维表（酒宽、门禁、快捷、副宽、wifi、物联）——张建新定的维表 
		select type,prod_offer_id,prod_offer_code,prod_offer_name from dim_dzkd_offer
		
		--省cdap中间层表
		zone_gz_yz.dws_yz_tb_comm_cm_all_final,当月在网+当月拆机的号码，每天跑前一天的数，只保留一天的数据
		zone_gz_yz.dwm_yz_tb_comm_cm_all_mon_final，月表，par_month_id = 202212 ，就是20221231拍照在网的号码+20221201~1231拆机的号码
		
		(
		summary_ods_day_city.rpt_comm_ba_subs
		summary_ods_day_city.rpt_comm_ba_subs_hist
		summary_ods_day_city.rpt_comm_ba_subs_hist_all
		iodata_ods_month_city.rpt_comm_ba_subs_mon
		iodata_ods_month_city.rpt_comm_ba_subs_hist_mon
		ba_subs+ba_subs_hist：最近35天订单，如果只是统计当月订单的日报，可以使用
		ba_subs+ba_subs_hist_all：所有订单，需要统计一长段时间的订单时可以使用，数据量较大
		ba_subs_mon+ba_subs_hist_mon：按月分区的订单，统计历史订单时可以使用，理论上相当于当月之前的ba_subs+ba_subs_hist_all（即不包含当月1号至今的数据），不同月份分区par_month_id可能会有重复记录

		注意ba_subs和ba_subs_hist一定要结合在一起使用，才是全的订单，不能只用一张表
		销售品disc（summary_ods_day_city.rpt_comm_ba_msdisc
		summary_ods_day_city.rpt_comm_ba_msdisc_hist
		summary_ods_day_city.rpt_comm_ba_msdisc_hist_all
		iodata_ods_month_city.rpt_comm_ba_msdisc_mon
		iodata_ods_month_city.rpt_comm_ba_msdisc_hist_mon）表也是类似
		)
		
		
		cdap中间层大宽表产品分类
		DROP TABLE zone_gz_yz.tmp_final_dws_yz_tb_comm_cm_all_sub8; 
		CREATE TABLE zone_gz_yz.tmp_final_dws_yz_tb_comm_cm_all_sub8 as
		select 
		serv_id
		,case when TERMINAL_ID = 10 then 10 --固话
		when TERMINAL_ID = 30 then 30  --移动
		when net_connect_type in (100101,100201,100102,100202,100300) then 40 --宽带
		else TERMINAL_ID end prod_type
		
		,case when ITV_TYPE  in (0,1) then 50  --ITV
		when payment_id=1 and TERMINAL_ID = 30  then 35  --后付费移动
		when payment_id=2  and TERMINAL_ID = 30 then 34  --预付费移动
		when prod_id in (48,52,57,1100,600039000) and fee_id not in (1,2) then 60  --互联网专线
		when prod_id in (54,500002440,500005480,600019010,600018006,600017007,600031023,600032006,600032007,600031026,600031024,600030012,600031025,600030013) and fee_id not in (1,2) then 70  --组网专线
		when prod_id=218 and substr(acc_nbr,length(acc_nbr),1)='A' and fee_id not in (1,2) then 70  --组网专线
		when serv_id in(select serv_id from tmp_final_dws_yz_tb_comm_cm_all_fh) then 80
		end prod_type2
		
		,case when mainstream_net_type in (10,11)        and net_connect_type in (100101,100201,100102,100202,100300) then '普通宽带'
		when mainstream_net_type = 21              and net_connect_type in (100101,100201,100102,100202,100300) then '校园翼起来'
		when mainstream_net_type not in(21,10,11)  and net_connect_type in (100101,100201,100102,100202,100300) then '其他' 
		end kd_desc
		from zone_gz_yz.tmp_final_dws_yz_tb_comm_cm_all a
		
		
		
		
		字典表 bssdev.attr_spec 和 bssdev.attr_value ，特性表bssdev.attr_spec，特性值表bssdev.attr_value
		先用稀奇古怪的值在特性值表中找出她的特性id、特性值和名称
		select attr_id,attr_inner_value,attr_value_name  from bssdev.attr_value where attr_inner_value='9108'
		select attr_id,attr_inner_value,attr_value_name   from bssdev.attr_value where  attr_inner_value='1000'
		再在特性表找出这个特性ID下的特性名称确定是要找的特性
		select attr_id,attr_name from bssdev.attr_spec where attr_id=4000092011 
		最后在特性值表找
		select attr_id,attr_inner_value,attr_value_name   from bssdev.attr_value where  attr_id=4000092011 
		
		
		网格单元子类型是按落地划分的
		五大网格是按划小片区划分的
		
		
		
		20230330
		-- cust_name_type --公司名/个人名
		select cust_name_type,*
		from bssdev.rpt_comm_cm_serv
		select cust_name_type,*
		from bssdev.customer
		—— 各位，系统组已经在资料表、客户表打标了 公司名/个人名 标签（政企部陈美平定的口径），如果有需求方用到公司名/个人名 的判断，请大家统一用这个，谢谢[抱拳]@所有人  
		如果不是从资料表抽数的话，那就用cust_id去客户表判断就行。
		
		
		一、移动计费
		是否网上用户
		统计口径
		后付费网上用户数：统计期末在CRM系统拥有使用信息，用户申请主动停机未超过六个月、欠费停机时间未超过3个月（未超过双停2个月）的移动电话用户。
		预付费网上用户数：统计期末在CRM系统拥有使用信息，余额状态为正常或保留期在2个月内的用户。

		是否出帐用户（判断是否到达）
		1.首先满足“网上用户”的条件
		2.移动后付费出帐口径：回现收入（脱机收入+调账+赠金冲减+计不列）>0，在网或者当月拆机，非欠费用户；
		移动预付费出帐口径：回现收入（脱机收入+调账+赠金冲减+计不列）>0，且余额状态为正常或者在保留期一个月内（即在上个月1日后进入余额保留状态） 或者 号码不在余额表内
		3.剔除集团下发一卡双号用户，2017年4月1日之后入网的副卡用户，如果当月（主叫时长call_dur+被叫时长called_dur+上网流量innet_flux+点对点短信p2p_sms_num=0），在当月不统计为出账用户


		二、宽带计费（跟集团保持一致）
		1、宽带用户（统计为宽带的存量ITV用户 + prod_id in（950,48,47,56,52,57,999,10000,51,1100,3881,1023,1052,1051,49,1022,2340,2341,500001200,500001961,500001741,500002660） 
		2、统计时点在用，即状态为正常、停机、预拆机，剔除拆机、未竣工、未激活用户 
		3、剔除停机1个月及以上的预付费用户
		4、剔除欠费3个月及以上的后付费用户和准实时预付费用户。需特别注意的是，这里的“欠费”包含已列坏账记录。

		三、ITV计费
		1、ITV中属于宽带的用户：与宽带计费口径一致
		2、ITV中不属于宽带的用户：
		宽口径：
		（1）状态为正常/停机/预拆机
		（2）欠交月份（ARREAR_MONTH）小于等于3个月
		严口径：
		（3）2018年1月1日以后入网用户，已激活（激活清单取至互联网事业部ITV平台）

		四、其他固网产品：
		（1）状态为正常/停机/预拆机
		（2）欠交月份（ARREAR_MONTH）小于等于3个月
		
		
		cust_id 是产权，ccust_id是直销 
		产权对应表是 customer
		直销对应表是 ecust_gz_mo_ccust
		
		
		坏表
		找毓敏哥查询坏表的哪个字段索引坏了，然后重建该坏表
		dba账号下，不是dba账号查不了
		hxm(黄毓敏) 09-02 11:04:17
		sp_iqcheckdb 'check table bssdev.rpt_comm_ba_msdisc' --检查坏表
		
		--排查哪个字段怀表
		select 字段1,字段2,字段3。。。。,字段100 
		into RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO_2 from RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO where data_date=20221130;commit;

		--重建表
		commit;
		select * into rptdev.RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO_2
		from RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO where 1=2;
		commit;
		--迁移数据（去除坏表字段）
		insert into RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO_2 (data_date,subst_id,subst_name,cust_grp_desc,sf_xy_zd,value1,index1,value2,index2,value3,index3,value4,index4,value5,index5,value6,index6,value7,index7,value8,index8,value9,
		index9,value10,index10,value11,index11,value12,index12,value13,index13,value14,index14,value15,index15,value16,index16,value17,index17,value18,value19,index19,value20,
		index20,value21,index21,value22,index22,value23,index23,value24,index24,seq_id,channel_subtype_2011,channel_type_2011,xy_salestaff_id,branch_name,value25,index25,value26,index26,
		value27,index27,value28,index28,value29,index29,value30,index30,value31,index31,value32,index32,value33,index33,value34,index34,value35,index35,value36,index36,value37,index37,value38,
		index38,value39,index39,value40,index40,item_id)
		select data_date,subst_id,subst_name,cust_grp_desc,sf_xy_zd,value1,index1,value2,index2,value3,index3,value4,index4,value5,index5,value6,index6,value7,index7,value8,index8,value9,
		index9,value10,index10,value11,index11,value12,index12,value13,index13,value14,index14,value15,index15,value16,index16,value17,index17,value18,value19,index19,value20,
		index20,value21,index21,value22,index22,value23,index23,value24,index24,seq_id,channel_subtype_2011,channel_type_2011,xy_salestaff_id,branch_name,value25,index25,value26,index26,
		value27,index27,value28,index28,value29,index29,value30,index30,value31,index31,value32,index32,value33,index33,value34,index34,value35,index35,value36,index36,value37,index37,value38,
		index38,value39,index39,value40,index40,item_id from RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO;
		
		--重命名坏表和重建表
		alter table RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO rename RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO_BADTABLE;
		alter table RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO_2 rename RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO;
		
		--查看授权并按授权信息将新表赋权
		commit;
		SELECT * FROM bssdev.REX_TABLEPERM
		where upper(table_name) = upper('rpt_comm_cm_serv')
		
		commit;
		select DATEFORMAT(CAST(data_date AS VARCHAR(32)),'yyyymm') AS YEAR ,SUM(LENGTH(index18)) from RPT_XY_NIUX_DDXY_ZBBB_LIST_BAO_BADTABLE
		WHERE YEAR ='201906'
		GROUP BY YEAR
		
		
		
		
		
		
		值班每日工作：
		1、看队列日志，保证队列正常生产，宽带Q44report_adsl_sh(A队列)和Q44report_adsl_xy(B队列)
		移动Q79report_A和Q79report_B
		2、日生产完成后，刷新BI宽带日报，先自己核查一遍数据，若没问题再下载给各个模块负责人查看数据，
		都确认没问题发到对对碰群给杨洋核对，没问题后发送邮件
		宽带日报：移宽发展日报+移宽日报的宽带部分和融合及宽带业务日报
		
		挂在日报队列的存储赋权: 
		grant execute on SP_RPT_TOP50_LIST to zwfxdev;commit;

		
		
		
		
		
		
		
		所有产品的价值积分：
		select serv_id,jz_points from tb_ws_score_yd_list_bak  --移动
		select serv_id,jz_points from tb_ws_score_kd_list_bak   --宽带
		select serv_id,jz_points from tb_ws_score_itv_list_bak   --ITV
		select serv_id,jz_points from tb_ws_score_zx_list_bak   --专线
		select serv_id,jz_points from tb_ws_score_prod_list_bak   --组网等
		select serv_id,jz_points from tb_ws_score_3c_list_bak  --云产品  （没有当前月份,当前月份表 tb_ws_score_3c_list_m）
		select distinct prod_id from tb_ws_score_zzyw_list_bak  --增值产品（没有当前月份,当前月份表 tb_ws_score_zzyw_list_m）
		
		
		
		
		
		收入核查
		drop table if exists tmp_liq_lv_heshu;commit;
		select serv_id,prod_id,sum(isnull(fee_new_tax,0)) a1,sum(isnull(fee_fm,0)) a2 into tmp_liq_lv_heshu from temp_xlf_adsl_msdisc_list1 
		group by serv_id,prod_id having a1<a2
		
		select month_id ,a.data_src_type,b.data_src_name,sum(charge-tax_charge)/100 v1
		from bssdev.gz_sure_kh_output a, zwfxdev.dim_data_src_type  b
		where a.data_src_type*= b.data_src_type
		and  serv_id in (select distinct serv_id from tmp_liq_lv_heshu) and month_id=202012 
		and contract_flag=1 and is_filter='0' group by month_id,a.data_src_type,b.data_src_name  --号码的收入来源
		
		
		bssdev.dim_cust_bg_type_origin 
		包含在上面维表里面的就是清单制客户

		
		
		推送FTP网址：http://132.97.54.32/origin/dashboard
		FTP账号：liq17
		密码：jS*6h2$u
		推送FTP：1.新增清单，按网页提示填写所有带*内容，包括视图名，清单层表名，推送设置等
		日清单：本月统计时点，月清单：上月底
		2、新增FTP，推送12分局要call存储，然后在网页上点维护FTP-同步刷新，不需要推送到12分局则按网页填写需求单号，ftp目录等

		--IQ数据库账号
		数据库账户：rptdev   密码：ywzc@018
		数据库账户：zwfxdev   密码：dev$$$  
		数据库账户：zwfxdev_mid   密码：ywzc123!@#
		数据库账户：bssdev   密码 dev$$$
		
		--宽带周报所有存储：PRC_WEEKLY_SCB_KD_ALL
		
		--搜清单推送目录的账号和目录
		----查看推送FTP目录
		select *   -- account,dir,aliases,is_home_dir
		from rptdev.ftp_account_detail_new
		where account = 'v-heting'    --看is_home_dir如果是1表示这个路径是这个账户本人的，如果是0，表示对应的路径是他人的，只是这个账户有权限查看。
		select account,dir,aliases,is_home_dir
		from rptdev.ftp_account_detail_new
		where account = 'wuhuim'
		and is_home_dir = 1
		
		--新建清单和新建ftp执行语句
		CALL zwfxdev_mid.SP_LIST_Q65_CONFIG_VIEW
		CALL zwfxdev_mid.SP_LIST_Q65_CONFIG_FTP
		
		
		CALL zwfxdev_mid.SP_LIST_Q65_CONFIG_FTP(
		'NEW',
		'vbtb_ws_score_all_new_list_m',
		999999,
		'数字化营销中心',
		'132.97.172.153',
		'root',
		'',
		'/ftp/kd_wbzz_001',
		'v-liudant',
		'/',
		20231231,
		'',
		'',
		'李倩'
		);

		
		
		推送清单到12个分局，需要call存储，网页版不能推送到12个分局
		CALL zwfxdev_mid.SP_LIST_Q65_CONFIG_FTP(
		'NEW',
		'vb_cl_tuoshou_lq_list',   --改视图名，其他不用改
		0,
		'12分局',
		'132.97.172.153',
		'root',
		'',
		'临时清单',   --推到12分局的临时清单目录
		'',
		'/',
		20230615,   --推送有效期
		'',
		'',
		'李倩'    --改推送人
		);
		commit;
		--若有些分局暂时不推送，则找杨铭跑update改不推送
		update zwfxdev_mid.TB_Q65_LIST_FTP as a 
		set is_push_flag =0 
		where a.view_name='vb_tb_th_ts_lq_list' 
		and subst_id not in (4050);
		commit;
		
		--推送某个分局
		update zwfxdev_mid.TB_Q65_LIST_FTP as a 
		set is_push_flag =1,
        valid_date=20221231 
		where a.view_name='vb_tb_th_ts_lq_list' 
		and subst_id in (10061);
		commit;
		
		--通过表找存储
		select creator 帐户ID,proc_name 存储过程名称,proc_defn 存储过程主体
		from sys.sysprocedure where creator= user_id('rptdev')
		and upper(proc_defn) like '%tb_xsb_xmy_qwfz_bao%' and upper(proc_defn) like '%218%'
		
		--手动停止推送某些分局
		--改视图名，落地局向ID，落地局向
		CALL zwfxdev_mid.SP_LIST_Q65_CONFIG_FTP('STOP','vb_tb_th_ts_lq_list',10307,'海珠','132.97.172.153');commit;
		
		--查询ftp视图  
		select * from zwfxdev_mid.TB_Q65_LIST_VIEW where handle_name like '%李倩%'
        --查询ftp推送清单设置		
		commit;  select * from zwfxdev_mid.TB_Q65_LIST_FTP where view_name = 'vbTB_SCB_ZTRH_ZS'
		
/* 		drop view if exists rptdev.vb_scb_129_gz_list;commit;
		drop view if exists rptdev.vb_scb_129_subst_list;commit;
		drop view if exists rptdev.vb_scb_129_branch_list;commit;
		drop view if exists rptdev.vb_scb_129_region_list;commit;
		drop view if exists rptdev.vb_scb_129_area_list;commit;
 */		
		--手动推送清单脚本
		sh /home/yxzcdev/shell/User_Jobs_Queue/Q65_list_push.sh 'vb_TH_SQ_TCHM_SJQD_LIST' 0 20210630 0
		sh shell/User_Jobs_Queue/Q65_list_push.sh view_name（视图名） 1（0：视图层已有数据，不跑存储；1：跑存储出数） 20220330（统计日期） 0（默认为0）
		sh shell/User_Jobs_Queue/Q65_list_push.sh vbTB_SCB_ZTRH_ZS 0 20230930 0 
		--更新推送配置
		update zwfxdev_mid.TB_Q65_LIST_ftp a 
		set is_push_flag=1 
		where view_name = 'vbtb_zyzd_list';commit;
		update zwfxdev_mid.TB_Q65_LIST_view a 
		set is_monitor_flag = 0, a.list_type = 0,--改为不监控
		is_push_flag=1 
		where view_name = 'vbtb_zyzd_list';commit;


		
		在shell上跑存储，只需要改call SP_RPT_DAILY_KD_TS(20220412);commit;
		dbisqlc -c "uid=rptdev;pwd=ywzc@018;eng=iq_n2;dbn=iq_n2;links=tcpip{host=132.97.93.192;port=5000}" -q "call SP_RPT_DAILY_KD_TS(20220412);commit;"
		
		拿存储：sp_helptext SP_RPT_DAILY_KD_TS  （sp_helptext  存储名）
		优哒申请下载，IQ复制
		
		--1,3号停生产，2号生产月底的数  5号生产月报  大概6,7...会出经分和考核数

		--查看表结构：describe 表名

		一对多的数据提取要用插入，不能用update，update只会选取一条记录，如提取宽带绑定的移动、固话和itv号码

		注意：update语句只能在有数的情况下进行更新字段，没数时是要插入数据insert into
		删除列: alter table rptdev.tmp_liq_NDYS_211220_list drop msinfo_id
		
		 datepart(datepart,date)--取日期中的单独部分，如datepart(quarter,@sum_month || '01')是取第几季度
		 
		 
		 是否包区店口径（渠道统一视图版本）：select attr_value From channel_attribute a where a.attr_id=50000122;  10 是  20 否
		 
		 --提取号码的缴费编码，与CRM-计费账务管理-查询管理-服务信息查询的缴费编码一致
		select a.serv_id,a.acc_nbr,a.prod_id,a.cust_id,b.acct_id,c.acct_cd--合同编码
		from bssdev.rpt_comm_cm_serv as a,
		bssdev.prod_inst_acct_rel_aap as b,
		bssdev.account as c
		where a.serv_id = b.prod_inst_id
		--and a.cust_id = c.cust_id
		and b.acct_id = c.acct_id
		and a.acc_nbr in ('18922166838')


		--bssdev.offer: 套餐维表，常用字段offer_id,prod_offer_code(套餐编码),offer_name
		--只有offer表有prod_offer_code，用offer的offer_id与优惠订单表（rptdev.rpt_comm_cm_serv）的prod_offer_id匹配得到prod_offer_code
		--bssdev.offer.offer_id=rptdev.rpt_comm_cm_serv.prod_offer_id

		--销售品一般是指套餐
		
		--号码揽装人工号salestaff_id与sales_code关联时要先转换
		--套餐揽装人工号tc_salestaff_id不用转换

		--bssdev.dim_prod：产品表，常用字段stat_cat_id（产品大类）,prod_id,prod_code和prod_name只有产品表有

		--acc_nbr：接入号，是资料表的唯一标识
		--subs_code/subs_id: 订单表唯一标识

		--导入数据时字符串数据要先去空格和去换行

		--提取十级装机地址：
		十级装机地址是未脱敏地址，要先取地址标识 serv_addr_id，再把serv_addr_id清单授权给bssdev账户，请馥苑姐提取十级地址
		grant all on rptdev.tmp_liq_zjjd_211228_list to bssdev;commit;
		--install_addr：装机地址（脱敏）

		--资料表一般不用限定条件，其union视图表需要限定month_id=最新月份
		--最新月份的资料表包含所有在网号码

		--针对号码的订单表（_ba_subs）限定条件： subs_stat （= '301200'竣工等），subs_stat_reason not in( '1200','1300' )  --非撤单/非作废，action_type （= 'NEW'新装，CENCEL拆机等）
		--针对套餐的订单表（_ba_msdisc）限定条件：action_id in( 1292,6200 ) ，subs_stat_reason not in( '1200','1300' )  --非撤单/非作废，subs_stat <> '499999'

		--action_id in(select prod_service_rel_id,action_name from bssdev.PROD_SERVICE_OFFER_REL where action_name like '%移机%')
		
		--订单表的month_id与资料表的不是同个字段

		--subs_stat_date订单状态日期,act_date受理日期
		--subs_stat = '301200'是竣工

		--201002-201511的数据在zwfxdev.rpt_comm_cm_serv_backup中提取
		--201512-201810的数据在zwfxdev.rpt_comm_cm_serv_2010中提取
		--zwfxdev中的subs_stat_reason撤单是002，作废是004，subs_stat无效是SOC，与rptdev中不一样

		--套餐到期时间：资料表中是limit_date，订单表中是end_date

		--若出现acc_nbr为空，是上午生产数据，等更新完成才能提取数据

		--入网时间：移动是finish_date(竣工时间)，宽带是create_date

		--拆机时间：bssdev.rpt_comm_cm_serv_hist.HIST_CREATE_DATE

		--网龄：online_time

		--客户编码：cust_nbr

		--融合/单宽: is_rh，只对宽带产品打标

		--划小局向：grid_seq_id,grid_subst_id,grid_subst_name
		--落地局向：seq_id,subst_id,subst_name

		-- 宽带到达：arrear_month<=3 and state<>新装
		-- 宽带非到达：arrear_month>3
		-- 宽带到达数新增：比如统计月份是2019年11月，则宽带到达新增是month_id=201911 and create_date的年份是2019（create_date需要询问需求方是具体到年还是月）
		-- 宽带到达数存增量：比如统计月份是2019年11月，则宽带到达存增量是month_id=201911 and create_date的年份是2018（去年）
		-- 宽带到达数存存量：比如统计月份是2019年11月，则宽带到达新增是month_id=201911 and create_date的年份是<=2017
		-- 宽带净增：当月的净增量=当月用户数-上月用户数

		-- msrel_id是本地自己整理的套餐标识,msinfo_id是省公司模拟的套餐标识，都可用来关联移动、固话和ITV
		
		--BG: bg_type在资料表和订单表、日报资料表和订单表都有这个字段

		--更新宽带流量
		update xxx as a
		set a.stm_data=b.stm_data
		from (select acc_nbr,sum(acct_item_type_value)/104857600 as stm_data
		from zwfxdev.rpt_data_comm_charge_gz --历史表，bssdev.rpt_data_comm_charge_gz当前表
		where month_id = @month_id
		and acct_item_type_id in (100007,100008,200007,200008,700012,700013)
		group by acc_nbr) b
		where a.month_id = @month_id
		and a.acc_nbr = b.acc_nbr;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新宽带流量：' || @@ROWCOUNT || ' 条' type info to client;

		--套餐打标
		update rptdev.F_LIST_KD_NEW as a
		set a.disc_type_flag = b.disc_type_flag from
		rptdev.RPT_DISC_TYPE_FLAG_ADSL_union as b
		where b.month_id = @month_id
		and a.serv_id = b.serv_id;
		commit work;

		--是否副宽权益
		update rptdev.F_LIST_KD_NEW as a 
		set a.is_fkqx='否';commit;
		--（1）0元副宽：DM0001-709-1-7 高端融合用户副宽权益包300M_0元/月 DM0001-709-1-10   高端融合用户副宽权益包500M（商企版）_0元/月
		update rptdev.F_LIST_KD_NEW as a 
		set a.is_fkqx='0元副宽'
		from rptdev.rpt_comm_cm_msdisc_union as b
		where b.month_id=@this_month
		and a.serv_id=b.serv_id
		and b.prod_offer_id in(500057444,500057591);
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 宽带固话新装清单 -- 更新是否叠加副宽权限(0元) ' || @@ROWCOUNT || ' 条' type info to client;
		--（2）30元副宽 DM0001-709-1-8 高端融合用户副宽权益包300M_30元/月 DM0001-708-1-2 高端融合用户副宽权益包100M_30元/月(同址)
		update rptdev.F_LIST_KD_NEW as a 
		set a.is_fkqx='30元副宽'
		from rptdev.rpt_comm_cm_msdisc_union as b
		where b.month_id=@this_month
		and a.serv_id=b.serv_id
		and b.prod_offer_id in(500024011,500058365);
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 宽带固话新装清单 -- 更新是否叠加副宽权限(30元) ' || @@ROWCOUNT || ' 条' type info to client;
		--（3）40元副宽 DM0001-708-1-3 高端融合用户副宽权益包100M_40元/月(同址) DM0001-709-1-9 高端融合用户副宽权益包300M_40元/月
		update rptdev.F_LIST_KD_NEW as a 
		set a.is_fkqx='40元副宽'
		from rptdev.rpt_comm_cm_msdisc_union as b
		where b.month_id=@this_month
		and a.serv_id=b.serv_id
		and b.prod_offer_id in(500024012,500058366);
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 宽带固话新装清单 -- 更新是否叠加副宽权限(40元) ' || @@ROWCOUNT || ' 条' type info to client;
		
		
		按划小局向统计宽带入网量
		select grid_seq_id,grid_subst_id,grid_subst_name,count(distinct serv_id) 
		from rptdev.RPT_DAILY_KD_BA_LIST_UNION
		where month_id=202112
		and action_type='NEW'
		and item_type='竣工量' 
		and kd_desc = '普通宽带'  
		group by grid_seq_id,grid_subst_id,grid_subst_name

		按落地局向统计宽带入网量
		select seq_id,subst_id,subst_name,count(distinct serv_id) 
		from rptdev.RPT_DAILY_KD_BA_LIST_UNION
		where month_id=202112
		and action_type='NEW'
		and item_type='竣工量' 
		and kd_desc = '普通宽带'  
		group by seq_id,subst_id,subst_name

		统计宽带到达数（rptdev.RPT_DAILY_KD_CM_LIST：主宽和光宽剔除了门禁宽带,有seq_id,subst_id,subst_name，grid_seq_id,grid_subst_id,grid_subst_name
		rptdev.rpt_comm_cm_serv_kd_union：未剔除门禁宽带，只有subst_id，grid_subst_id）
		select seq_id,subst_id,subst_name,count(distinct serv_id)
		from rptdev.RPT_DAILY_KD_CM_LIST
		where month_id = 202112
		and stat_cat_id in (0,2,7,8,9) --全量宽带
		--and kd_desc = '普通宽带'  
		and create_date <= '20211217'
		and arrear_month <= 3
		--and state <> '140001' --剔除新装,rptdev.RPT_DAILY_KD_CM_LIST可不加此条件
		group by seq_id,subst_id,subst_name

		--_union和_bak_month的区别：bak_month是备份表，备份表是每个月末才会备份数据
				--假如3.现在是20210810号的话 那么备份表就只有 到7月的数据 没有8月的
		  --union是视图，假如现在是20210810号的话，视图就会有8月的数据
		  
		--渠道小类：channel_subtype_2011
		--渠道日报小类: channel_subtype_rb，日报通过关联rptdev.dim_channel_subtype_kd_rb的channel_subtype_2011
		--更新的channel_subtype_rb，是市场部在渠道小类的基础上进一步对渠道的分类进行细化和归类
		--提取渠道数据要需求方是要渠道小类还是渠道日报小类

		--普通宽带：arrear_month<=3是欠费月份<=3，超过3个月是非计费（停机），到达层需限定此条件

		--资料表都是广州的数据

		--rptdev.rpt_comm_cm_serv_cdma_union移动资料表

		----资料表中的所有号码通过is_zfk判断主副卡，is_zfk<>2表示主卡，=2表示副卡
		--副卡号码的 ZFK_RELA_SERV_ID =主卡的serv_id，以此关联主副卡

		--资料表一定要限制month_id，订单表要限制subs_stat_date或者act_date

		--bssdev.prod_inst_rel_grp_a号码之间有关联的关联表,z_prod_inst_id关联在a_prod_inst_id下面

		--宽带日报订单层和到达层、rpt_comm_cm_serv_kd_union、rpt_comm_ba_subs_all_kd只有（0,2,7,8,9,10），没有固话
		--宽带日报订单层和到达层是限制了arrear_month<=3的号码，不需要此限制条件需要用rpt_comm_cm_serv_kd_union、rpt_comm_ba_subs_all_kd
		--固话需要在所有产品的资料表和订单表取
		from rptdev.rpt_comm_ba_subs_union
        where subs_stat = '301200'
        and subs_stat_reason not in('1200','1300') 
        and dateformat(subs_stat_date,'yyyymmdd') >= dateformat(@this_month_first_day,'yyyymmdd')
        and dateformat(subs_stat_date,'yyyymmdd') < dateformat(@current_date,'yyyymmdd')
        and prod_id = any(select prod_id from bssdev.dim_prod where stat_cat_id =1)
        and action_type = 'NEW';
		
		--stat_cat_id：产品大类（宽带），（0,2,7,8,9）是全量宽带 
		--产品大类（宽带）
		stat_cat_id = 0 then '校园翼起来'
		stat_cat_id = 1 then '固话'
		stat_cat_id = 2 then 'ADSL'
		stat_cat_id = 7 then 'LAN'
		stat_cat_id = 8 then 'IP城域网'
		stat_cat_id = 9 then 'VPDN'
		stat_cat_id = 10 then 'ITV'
		
		从订单表查号码的状态（拆机，移机，新装等）
		select acc_nbr,action_type,subs_stat_date from rptdev.rpt_comm_ba_subs_UNION where subs_stat_date>='20220101' and acc_nbr in ('ADSLD2113881956'

		--分光器编码 cross_code
		
		--网格属性 own_org_region_type
		select own_org_region_type,count(1)  from bssdev.sale_outlers_2021
		group by own_org_region_type
		
		--宽带价值档次：disc_value，日报表有这个字段

		/*价值积分
		--宽带
		update xxx as a
		set a.jz_jf=isnull(b.jz_points,0)
		from rptdev.tb_ws_score_kd_list_union as b
		where a.serv_id = b.serv_id
		and b.month_id =@this_month;
		commit work;

		--固话
		update xxx as a
		set a.jz_jf=isnull(b.jz_points,0)
		from rptdev.tb_ws_score_prod_list_union as b
		where a.serv_id = b.serv_id
		and b.month_id =@this_month;
		commit work;

		--itv
		update xxx as a
		set a.jz_jf=isnull(b.jz_points,0)
		from rptdev.tb_ws_score_itv_list_union as b
		where a.serv_id = b.serv_id
		and b.month_id =@this_month;
		commit work;

		--专线
		update xxx as a
		set a.jz_jf=isnull(b.jz_points,0)
		from rptdev.tb_ws_score_zx_list_union as b
		where a.serv_id = b.serv_id
		and b.month_id =@this_month;
		commit work;

		--第三步：更新移动的价值积分
		update rptdev.xxx a
		set a.jz_jf=isnull(b.jz_points,0) from
		rptdev.tb_ws_score_yd_list_union as b
		where a.yd_serv_id = b.serv_id
		and a.sum_date = @sum_date
		and b.month_id =@this_month;
		commit work; 
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || '更新价值积分结束'||@@ROWCOUNT||' 条' type info to client;

		价值积分end*/
		
		--号码关联关系表 --业务关联关系表
		select a_prod_inst_id,z_prod_inst_id 
		from bssdev.prod_inst_rel_a --itv的关联关系表, 大多数情况下宽带与itv关联字段: a_prod_inst_id 为宽带标签,z_prod_inst_id 为itv标识
		select a_prod_inst_id,z_prod_inst_id 
		from bssdev.prod_inst_rel_grp_a --非itv的号码关联关系表 --这个表内有itv号码 , 但没有宽带与itv的关联数据

		--宽带主流融合清单：rptdev.RPT_DAILY_KD_SX_XRH_LIST，包含主宽号码和关联的移动号码等字段

		--跑月报存储前先确认月数据好了没，确认渠道：
		--1）问值班同事    2）值班同事会发出账版邮件如“宽带日报【20211130出账版】” （但新员工暂时没有配置收件人）
		--每月一发这个邮件就说明日报出账版（月度）数据具备了 
		--5号月度生产具备后 他们都会及时跑出账版（月度），所以一般6号以后都具备了
		
		--循环脚本
		begin
		declare @month_id int;
		set @month_id=201812; 

		while @month_id<=202112 loop 
		
		-- 执行脚本
		
		set @month_id = cast(dateformat(dateadd(month,1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer); 
		end loop ;
		end;
		commit;
		
		---------计转非、非转计只有宽带有---------------------------
		--非转计
		select a.prod_id,a.kd_desc,count(distinct a.serv_id) from 
		bssdev.rpt_comm_cm_serv_2022 a,bssdev.rpt_comm_cm_serv_2022 b 
		where a.month_id=202207 
		and b.month_id=202206 
		and b.state <> '140001' 
		and a.stat_cat_id in (0,2,7,8,9,10) 
		and a.arrear_month<=3 --计费用户
		and b.stat_cat_id in (0,2,7,8,9,10)  
		and b.arrear_month>3  --非计费用户
		and a.serv_id=b.serv_id 
		
		--插入计转非清单
		insert into rptdev.py_kdyw_list_01(month_id,serv_id,acc_nbr,seq_id,subst_id,subst_name,branch_id,branch_name,bevy_cust_code)
		select distinct month_id,serv_id,acc_nbr,seq_id,subst_id,subst_name,branch_id,branch_name,bevy_cust_code
		from rptdev.RPT_DAILY_KD_CM_LIST_bak_month
		where month_id >=@month_id
		and arrear_month_last <= 3 and state_last <> '140001' and arrear_month > 3
		and kd_desc='普通宽带'; 
		commit work; 
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 插入计转非部分结束：' || @@ROWCOUNT || ' 条' type info to client;

		--插入非转计结束
		insert into rptdev.py_kdyw_list_01(month_id,serv_id,acc_nbr,seq_id,subst_id,subst_name,branch_id,branch_name,bevy_cust_code)
		select distinct month_id,serv_id,acc_nbr,seq_id,subst_id,subst_name,branch_id,branch_name,bevy_cust_code
		from rptdev.RPT_DAILY_KD_CM_LIST_bak_month
		where month_id >=@month_id
		and arrear_month_last > 3 and state_last <> '140001' and arrear_month <= 3
		and kd_desc='普通宽带'; 
		commit work; 
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 插入非转计部分结束：' || @@ROWCOUNT || ' 条' type info to client;

		
		--------------------------省到达---------------------------
		省到达表bssdev.TB_COMM_CM_DATA
		select month_id,count(distinct serv_id) as '省到达',
		count(distinct case when is_yx=1 then serv_id else null end ) as '省有效到达' 
		from bssdev.TB_COMM_CM_DATA 
		where prod_id in(950,48,47,56,52,57,999,10000,51,1100,3881,1023,1052,1051,49,
		1022,2340,2341,500001200,500001961,500001741,500002660,500005501)
		and is_fee_user=1 and month_id in (201912,202012) group by month_id

		省宽带： net_connect_type in (100101,100201,100102,100202,100300)


		---------------收入----------------------------------------------
		出账：与CRM上一样的收入，包含收入来源（如月租、欠补列等），是确认收入其中一个小类，分为公允前（未摊分）和公允后（将出账收入摊分为话费、流量等）
		确认收入：最终能拿到手的收入，不包含代理商的佣金，分为税前和税后收入
		实收：客户交到电信的收入，包含代理商的佣金分成，一般实收会大于确认收入
		
		--收入来源
		select serv_id,
		sum(isnull(a0,0)) as '确认收入',
		sum(isnull(tax_charge,0)) as '税金',
		sum(isnull(a0,0))-sum(isnull(tax_charge,0)) as '税后确认收入',
		sum(fee_nbr) as '号码级收入', 
		sum(fee_nonbr) as '非号码级收入',
		sum(a1) as '后付费出账',
		sum(a2) as '调账',
		sum(a3) as '退费',
		sum(a4) as '公允摊分',
		sum(a5) as '预付费出账',
		sum(a6) as '计不列',
		sum(a7) as '计补列',
		sum(a8) as '一次性收入',
		sum(a9) as '结算分成',
		sum(a10) as '上网后赠金',
		sum(a11) as '流量不清零（流量递延）',
		sum(a12) as '终端递延减收',
		sum(a13) as '翼支付红包金减收',
		sum(b1) as '积分计提',
		sum(b2) as '积分计提递延',
		sum(b3) as '积分兑换',
		sum(b4) as '漫游支出（移动数据漫游结算支出）',
		sum(b5) as '行业短信结算支出',
		sum(b6) as 'IDC带宽包区调整',
		sum(a20) as '其他来源',
		sum(case when acc_nbr='手工调整' then isnull(a0,0) else 0 end) as '手工调整'
		from zwfxdev_mid.hx_hs_srqr_ts a
		where month_id = 202101
		group by serv_id
		
		
		--全部账目项
		select a.acc_nbr,a.acct_item_type_id,b.name ,sum(charge)/100 a1
		from zwfxdev.TB_COMM_SERV_FEE_UNION a, bssdev.dim_acct_item_type b
		where a.acc_nbr in (select acc_nbr from rptdev.acc_nbr) 
		and billing_cycle_id=20181101
		and a.acct_item_type_id=b.acct_item_type_id
		and a.acct_source = 1
		group by a.acc_nbr,a.acct_item_type_id,b.name

		--实收
		update xxx as a
		set a.fee= b.fee
		from (select serv_id,sum(amount-amount_tc) fee 
		from bssdev.if_real_src_sum_new 
		where flag='HF'  and month_id = 201908
		group by serv_id)  b
		where a.serv_id = b.serv_id
		and month_id=201908
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新实收收入：' || @@ROWCOUNT || ' 条' type info to client;

		--套餐费用
		update xxx as a
		set a.tc_fee= b.fee
		from (select serv_id,sum(charge)/100 fee
		from zwfxdev.tb_comm_serv_fee_union
		where billing_cycle_id = @month_id*100+1
		and acct_source = 1 --公允前（锁定此条件查询的出账费用与CRM系统查询一致）
		and acct_item_type_id=16150  --'套餐使用费'
		group by serv_id)  b
		where  a.serv_id = b.serv_id
		commit work;

		常用收入表：zwfxdev.rpt_hx_srqr_list，划小收入清单，包含号码、网格编码等资料表中常用字段，charge税前确认收入，tax_charge税金，税后确认收入=charge-tax_charge，月份是billing_cycle_id（每年每月的第一天）
		号码收入汇总表 zwfxdev.f_serv_income_stat2，包含号码、税前确认收入、税金和month_id，确认收入可在此表提取，需关联month_id和serv_id
		号码的资料表有fee（出账收入） fee_new(确认收入)   fee_new_tax(税后确认收入)
		
		--割接
        底层表中a.billing_cycle_id<=20181001为割接前,a.serv_id+89000000000000=b.serv_id
		18年10月进行了割接，在201810之前的serv_id需要serv_id+89000000000000

		-----------------------------宽带日报--------------------
		宽带日报订单层：rptdev.RPT_DAILY_KD_BA_LIST
		宽带日报到达层：rptdev.RPT_DAILY_KD_CM_LIST

		常用字段：
		1）局向名称ld_subst_name，用ld_subst_id关联bssdev.dim_subst表的subst_id
		--更新其它局向名称，将ld_seq_id为＞12或＜1或为空的，ld_subst_name = '其它',ld_subst_id = -1,ld_seq_id = 13

		2）营服名称ld_branch_name，用ld_branch_id关联bssdev.organization的org_id，ld_branch_name=bssdev.organization.org_name
		--更新其他营服名称，当ld_branch_name 为空或=‘ ’时，ld_branch_name='其它'

		3）片区名称region_name，用region_id关联bssdev.organization的org_id，region_name=org_name

		4）营销网格局向名称grid_subst_name=bssdev.dim_subst.aliasname

		5）营销网格营服grid_branch_name=bssdev.organization.org_name

		6）客户局向subst_name_kh，与bssdev.dim_subst_kh关联，subst_name_kh=校园本部/政企本部/省政企/其它

		7）更新套餐价值与对应套餐关联的移动号码，rptdev.rpt_daily_adsl_yuting_points_list_m是套餐积分表
		根据rptdev.rpt_daily_adsl_yuting_points_list_m更新当月套餐融合/单产品标识

		8）接入类型gxkd_type：铜线接入、光纤接入

		9）揽装人工号salestaff_id，关联zwfxdev.rpt_comm_ba_subs_union 和 rptdev.rpt_comm_ba_subs_union 更新，
		再关联bssdev.staff转换成sales_code

		10）揽装渠道日报小类channel_subtype_rb，关联渠道小类宽带日报维表rptdev.dim_channel_subtype_kd_rb，channel_subtype_2011

		11）渠道中心和移互中心channel_center，关联rptdev.dim_channel_type_ys，channel_type_2011

		12）揽装人机构salestaff_org_name，先关联bssdev.sales_man更新org_id，再关联bssdev.organization

		13）是否政企中心is_zqzx

		14）是否酒宽is_jdkd，关联rptdev.dim_jdkd_disc，kd_prod_offer_id=prod_offer_id，酒店宽带

		15）是否办理门禁宽带is_mjkd，关联套餐资料表，限定prod_offer_id和入网时间、套餐到期时间

		16）网格类型bevy_cust_type_desc，202005以后的数据关联bssdev.attr_value，bevy_cust_type=attr_inner_value，
		bevy_cust_type_desc=attr_value_name,202005以前的数据关联bssdev.f_dt_app_param，bevy_cust_type_desc=dscr

		17）网格区域类型（细分市场）qywg_type，根据bevy_cust_type_desc划分四个类型

		18）是否城中村网络is_czc，bevy_cust_type_desc in （“农村”，“城中村”）时，is_czc=1

		19）itv月累计开机次数kj_l_times，关联rptdev.GZITV_LOGIN_new_union

		20）价值积分jz_jf，宽带价值积分关联rptdev.tb_ws_score_kd_list_union，jz_jf=isnull(jz_points,0)
		融合价值积分关联rptdev.tb_ws_score_qrh_list_union，jz_jf=isnull(jz_points,0)

		21）细分市场是否校园字段is_school_market，关联bssdev.tlcs_divide_market_new，=is_school+market_user

		22）itv高清标识gqitv_type，itv_user_type=1则为高清，不等于1为标清

		23）政企（校园）分群维度subst_zq_kpi='政企(含校园)',需serv_grp_type_desc='政企'或prod_id in (10000,3881)，
		prod_id in (10000,3881)是指校园宽带

		24）客户群营服branch_type，is_zq=1，则是'政企营服'，is_zq=2，则是'校园营服'，else 为'其它'
		branch_name_zq=bssdev.dim_branch.aliasname

		25）上月欠缴月份arrear_month_last

		26）上月欠缴月份区间arrear_month_qj

		27）加装套餐jz_prod_offer_id，jz_msinfo_id







		------------------------修改BI报表------------------------------------------
		根据报表名找存储脚本：
		select creator 帐户ID,proc_name 存储过程名称,proc_defn 存储过程主体--,
		--substr(proc_defn,charindex('',proc_defn)) as 关键字区间
		from sys.sysprocedure where creator= user_id('rptdev')
		and lower(proc_defn) like '%RPT_DAILY_KD_QQB_XRH_LIST%'-- lower('%vv_rpt_daily_kd_zs%')


		1、在队列找存储
		2、根据存储名打开复制对应存储
		3、在自己电脑备份存储代码，再修改
		4、修改完成之后，在SYBASE跑存储,再call 存储名（日期）;commit;，队列的存储重连后会自动更新
		该存储只能跑前一天和月底的数据，因为rptdev.RPT_DISC_TYPE_FLAG_ADSL_UNION表只有前一天和月底的数据
		5、在sap报表网址备份日报，在自己私人报表文件复制粘贴日报，防止报表报错或需要用回就旧报表
		更新BI报表最新版日报，如要修改表结构，则在修改前先在【宽带组】群通知“修改宽带日报bi开始”，修改后在群里通知“修改宽带日报bi结束”
		6、下载报表给需求方

		例子：【蔡婷修改光宽提速日报】
		1、在队列找Q44_REPORT_ADSL_DAILY_SH存储（此存储包含了BI报表下方菜单栏的存储名，如光宽提速、宽带续约、光纤宽带等）
		2、找到光宽提速的存储
		#增加宽带提速日报
		#x=`expr $x + 1`
		#eval Flag_${x}="0"
		#eval Rpt_Name_${x}="宽带提速日报"
		#eval Prc_Name_${x}=rptdev.SP_RPT_DAILY_KD_TS
		#eval Parameter_${x}="${DataDate}"
		#eval Sql_File_${x}=${ordno}TEMP_${x}
		得到存储名rptdev.SP_RPT_DAILY_KD_TS
		3、

		需求：1、达量降速的关联b表改成union表，完成后更新报表看有无数据（除零错误问题）
		2、提速路径（3、12个月和低消）的prod_offer_id、套餐编码和名称搜集整理给需求方
		3、增加一列免提24个月


		新开发报表的存储完成后，加进宽带日报队列中自动运行，只需修改Rpt_Name报表名称和Prc_Name存储名
		#x=`expr $x + 1`
		#eval Flag_${x}="0"
		#eval Rpt_Name_${x}="宽带提速日报"
		#eval Prc_Name_${x}=rptdev.SP_RPT_DAILY_KD_TS
		#eval Parameter_${x}="${DataDate}"
		#eval Sql_File_${x}=${ordno}TEMP_${x}
		最后在IQ为zwfxdev用户授权该存储
		grant execute on sp_rpt_daily_cdma_sjcx_group_2022 to zwfxdev;commit;
		
		--查看队列运行情况
		select sum_date,run_id,remark,error_reason,rpt_name,prc_name,run_type,run_time,
		start_date,end_date,load_date 
		from prc_time_log_kd_A
		where sum_date=convert(int,dateformat(now()-1,'yyyymmdd'))
		--and line_type = 'A'
		order by run_id;
		
		
		commit;sp_iqcontext;	--查数据库进程

		commit;sp_iqconnection;		--TempTableSpaceKB --占用的临时空间

		commit;sp_iqwho;	--确定在用连接数

		commit;sp_iqlocks;   --查询锁表
		
		
		李倩日志建表语句：
		create table TB_LIST_LOG_LIQ_OTHER(
		sum_date integer,
		log_id integer,
		log_text varchar(1000),
		row_count integer,
		log_time date,
		proc_name varchar(300),
		log_time_desc varchar(50)
		);commit;
		
		李倩日志存储：
		--新存储要先create
		/* create PROCEDURE [rptdev].[SP_LIST_LOG_GB_OTHER]( in @proc_name varchar(300),
		in @log_id integer,
		in @log_text varchar(1000),
		in @row_count integer,
		in @sum_date integer default cast(dateformat(now()-1,'yyyymmdd') as integer),
		in @log_table_name varchar(100) default '' ) 
		on exception resume
		-- 此为专用日志存储, 请不要随意调用和删除, 如有疑问请联系数据室小波
		begin
		insert into rptdev.TB_LIST_LOG_GB_OTHER(sum_date,proc_name,log_id,log_text,row_count,log_time, log_time_desc)
		values( @sum_date,@proc_name, @log_id,@log_text, @row_count, now(), dateformat(now(), 'yyyy-mm-dd hh:mm:ss'));
		commit;
		end */
		
		ALTER PROCEDURE [rptdev].[SP_LIST_LOG_LIQ_OTHER]( in @proc_name varchar(300),
		in @log_id integer,
		in @log_text varchar(1000),
		in @row_count integer,
		in @sum_date integer default cast(dateformat(now()-1,'yyyymmdd') as integer),
		in @log_table_name varchar(100) default '' ) 
		on exception resume
		-- 此为专用日志存储, 请不要随意调用和删除, 如有疑问请联系数据室小波
		begin
		insert into rptdev.TB_LIST_LOG_LIQ_OTHER(sum_date,proc_name,log_id,log_text,row_count,log_time, log_time_desc)
		values( @sum_date,@proc_name, @log_id,@log_text, @row_count, now(), dateformat(now(), 'yyyy-mm-dd hh:mm:ss'));
		commit;
		end
		
		
		




		---------------------------------------------------------------------------------------------------------













		----------------------------------------笔记end------------------------------------------------------------------------------------------


		----------------------------------练习1：销售品的存量--------------------------------------------
		--需求描述：有套餐编码，提取销售品存量

		--先在offer表中查询offer_id
		select offer_id from bssdev.offer where prod_offer_code in ('套餐编码');

		--提取存量
		select count(acc_nbr) from rptdev.rpt_comm_cm_serv_union where prod_offer_id in ('上面查询到的offer_id') and month_id=202108


		------------------------------练习2：申请匹配翼起来宽带数据20210729
		--入网时间：资料表create_date
		--统计日期：202108
		--学校名称：rptdev.dim_xy_school.school，用域名ym匹配,rptdev.dim_xy_school是旧口径，需要新的学校表
		--接入方式：bssdev.attr_value.attr_value_name ,根据资料表fttx_type= bssdev.attr_value.attr_inner_value提取
		--速率：无说明一般是资料表speed_value
		--域名：多媒体账号acc_nbr2@后面的字符串
		--接入号对应的主套餐：bssdev.offer.offer_name,用offer的offer_id与优惠订单表kd_prod_offer_id = bssdev.offer.offer_id匹配
		--是否为单宽：rptdev.RPT_DAILY_KD_CM_LIST.is_rh,is_rh=1是融合，否则为单宽
		--接入号关联的移动号码：yd_acc_nbr=acc_nbr,宽带关联移动,b.msrel_id = c.msrel_id
		--接入号状态（正常/主动停机/欠费停机/其他）:state,主动停机/欠费停机用stop_reason_id更新停机状态
		--停机时间:rptdev.rpt_comm_cm_serv.stop_date
		--是否受理了“DM0002-A01 2012年校园翼起来宽带代收费_免宽带月租（代收费）”:优惠订单表bssdev.rpt_comm_cm_msdisc
		--是否受理了“SJ0912-A08-1-2  校园天翼宽带高竞争院校融合套餐(首月收费)（1元）_4M_2013年三季度_粤”:优惠订单表bssdev.rpt_comm_cm_msdisc
		--受理了销售品SJ0911-A05-1-1且在有效期内（是/否）:优惠订单表bssdev.rpt_comm_cm_msdisc
		--揽装人:bssdev.sales_man.sales_man_name,用rptdev.rpt_comm_cm_serv_union.salestaff_id = bssdev.sales_man.sales_code
		--揽装工号:rptdev.rpt_comm_cm_serv_union.salestaff_id，8位数
		--揽装工号所属分局:set a.lz_subst_id=c.subst_id,a.lz_subst_name=d.subst_name,a.lz_seq_id=d.seq_id，
		------bssdev.sales_man as b,bssdev.SALE_OUTLERS as c,bssdev.dim_subst as d
		--宽带账号最后一次登录时间：没有这个数据

		--删除临时表
		drop table if exists rptdev.tmp_liq_ppxykdsj_210817_list;commit work;

		--建立临时表,命名表名:rptdev.tmp_liq_需求简称_日期_list
		create table rptdev.tmp_liq_ppxykdsj_210817_list
		( 
		acc_nbr varchar(30),
		acc_nbr2 varchar(100)，
		rw_date date,
		sum_date VARCHAR(20),
		school_name VARCHAR(200),
		fttx_type_name VARCHAR(50),
		speed_value numeric(10,2),
		ym VARCHAR(50),
		kd_prod_offer_name VARCHAR(1000),
		is_dk VARCHAR(4),
		yd_acc_nbr varchar(30),
		acc_state VARCHAR(30),
		stop_time date,
		is_bltc1 VARCHAR(4),
		is_bltc2 VARCHAR(4),
		is_bltc_yxz VARCHAR(4),
		sales_man_name VARCHAR(100),
		sales_code VARCHAR(60),
		subst_name VARCHAR(60)
		);
		commit work;

		--导入数据
		load into table rptdev.tmp_liq_ppxykdsj_210817_list
		(
		acc_nbr  '$',    --分隔符为$
		acc_nbr2  '\x0a'   --分隔符为换行符
		)
		using client file 'D:\lemon\宽带组数据\师傅的小作业\申请匹配翼起来宽带数据\导入数据.txt'
		quotes off  --不用引号
		escapes off   --不用转义
		with checkpoint on;
		commit work;

		--去回车
		update rptdev.tmp_liq_ppxykdsj_210817_list              
		set acc_nbr=trim(replace(replace(acc_nbr,char(13),''),char(10),''));
		commit work;
		--去空格
		update rptdev.tmp_liq_ppxykdsj_210817_list               
		set acc_nbr=replace(acc_nbr,' ','');
		commit work;

		--去回车
		update rptdev.tmp_liq_ppxykdsj_210817_list             
		set acc_nbr2=trim(replace(replace(acc_nbr2,char(13),''),char(10),''));
		commit;
		--去空格
		update rptdev.tmp_liq_ppxykdsj_210817_list               
		set acc_nbr2=replace(acc_nbr2,' ','');
		commit work;

		--更新域名
		update rptdev.tmp_liq_ppxykdsj_210817_list
		set ym = substring(acc_nbr2,charindex('@',acc_nbr2)+1,length(acc_nbr2));
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新多媒体账号域名：' || @@ROWCOUNT || ' 条' type info to client;

		--更新统计日期
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.sum_date=b.sum_date 
		from rptdev.RPT_DAILY_KD_CM_LIST_union as b
		where a.acc_nbr=b.acc_nbr
		and b.month_id=202108;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新统计日期和多媒体账号域名：' || @@ROWCOUNT || ' 条' type info to client;

		--更新入网时间和速率
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.rw_date=b.create_date, a.speed_value=b.speed_value 
		from bssdev.rpt_comm_cm_serv as b 
		where a.acc_nbr=b.acc_nbr;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新入网时间和速率：' || @@ROWCOUNT || ' 条' type info to client;
		--为空表明已拆机，需在拆机表提取入网时间
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.rw_date=b.create_date  
		from bssdev.RPT_COMM_CM_SERV_HIST as b 
		where a.acc_nbr=b.acc_nbr and a.rw_date is null;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机入网时间：' || @@ROWCOUNT || ' 条' type info to client;
		--为空表明已拆机，有两种方法提取速率
		--1）在订单表匹配ACC_NBR
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.speed_value=b.speed_value 
		from rptdev.rpt_comm_ba_subs_union as b 
		where a.acc_nbr=b.acc_nbr and a.speed_value is null 
		and b.action_type = 'NEW'
		and b.subs_stat = '301200'
		and b.subs_stat_reason not in('1200','1300');
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机速率：' || @@ROWCOUNT || ' 条' type info to client;
		--2）循环根据拆机月份，取前一个月的资料表速率
		--先查看最小拆机时间和最大拆机时间
		select acc_nbr,HIST_CREATE_DATE from bssdev.rpt_comm_cm_serv_hist 
		where acc_nbr in (select acc_nbr from rptdev.tmp_liq_ppxykdsj_210817_list where speed_value is null);
		--循环
		begin
		declare @month_id int;
		set @month_id=202107;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机速率
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.speed_value=b.speed_value 
		from rptdev.RPT_COMM_cm_serv_union as b 
		where a.acc_nbr=b.acc_nbr and a.speed_value is null and b.month_id=@month_id;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机速率：' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit; 


		--更新学校名称（旧口径，需更新）
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.school_name = b.school from
		rptdev.dim_xy_school as b
		where a.ym = b.ym;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新学校：' || @@ROWCOUNT || ' 条' type info to client;
		--学校名称为空，rptdev.dim_xy_school表中没有该ym
		select * from rptdev.dim_xy_school where ym in (select ym from rptdev.tmp_liq_ppxykdsj_210817_list where school_name is null)

		--学校名称
		select distinct attr_id,attr_inner_cd,attr_name,attr_desc,crm2_dict_typeid
		from bssdev.attr_spec 
		where attr_inner_cd = 'PM_TYKDXXBM'
		select distinct attr_value,attr_inner_value,attr_value_name,crm2_dict_id 
		from bssdev.attr_value
		where attr_id = 5004 and attr_value_name = '广东文艺职业学院'

		--更新接入方式
		--接入方式一般在bssdev.attr_value表中取接入方式attr_value_name
		--1）在宽带清单表rptdev.RPT_DAILY_KD_CM_LIST_union取接入方式gxkd_type
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.gxkd_type=b.gxkd_type
		from rptdev.RPT_DAILY_KD_CM_LIST_union as b
		where a.acc_nbr=b.acc_nbr
		and b.month_id=202108;
		commit;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新接入方式 ' || @@ROWCOUNT || ' 条' type info to client;
		--2）在bssdev.attr_value表中取接入方式attr_value_name
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.fttx_type_name = b.attr_value_name 
		from bssdev.attr_value as b,
		bssdev.rpt_comm_cm_serv as c 
		where a.acc_nbr=c.ncc_nbr 
		and c.fttx_type = b.attr_inner_value;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新接入方式 ' || @@ROWCOUNT || ' 条' type info to client;
		--为空表明已拆机，需循环根据拆机月份，取前一个月的资料表fttx_type
		--先查看最小拆机时间和最大拆机时间
		select acc_nbr,HIST_CREATE_DATE from bssdev.rpt_comm_cm_serv_hist 
		where acc_nbr in (select acc_nbr from rptdev.tmp_liq_ppxykdsj_210817_list where fttx_type_name is null);
		--循环
		-----------------资料表中fttx_type为空的号码是数据库中没有数据，可能是因为没有录入--------------------------
		begin
		declare @month_id int;
		set @month_id=202107;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机接入方式
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.fttx_type_name = b.attr_value_name 
		from bssdev.attr_value as b,
		rptdev.rpt_comm_cm_serv_union as c 
		where a.acc_nbr=c.acc_nbr 
		and c.fttx_type = b.attr_inner_value
		and c.month_id=@month_id
		and a.fttx_type_name is null;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机接入方式 ' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit;

		--更新宽带主套餐
		--部分号码的kd_prod_offer_id为空可能是：
		--1）一般融合没有宽带主套餐,融合套餐是disc_type_flag
		--2）一些口径没有更新
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.kd_prod_offer_name=b.offer_name
		from bssdev.offer as b,
		bssdev.rpt_comm_cm_serv as c
		where c.kd_prod_offer_id = b.offer_id 
		and a.acc_nbr=c.acc_nbr;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新宽带主套餐：' || @@ROWCOUNT || ' 条' type info to client;
		--为空表明已拆机，提取拆机宽带主套餐
		--1）在订单表匹配ACC_NBR,部分号码的kd_prod_offer_id为空
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.kd_prod_offer_name=b.offer_name 
		from bssdev.offer as b,
		rptdev.rpt_comm_ba_subs_union as c	 
		where c.kd_prod_offer_id=b.offer_id 
		and a.acc_nbr=c.acc_nbr and a.kd_prod_offer_name is null 
		and c.action_type = 'NEW'
		and c.subs_stat = '301200'
		and c.subs_stat_reason not in('1200','1300');
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机宽带主套餐：' || @@ROWCOUNT || ' 条' type info to client;
		--2）循环根据拆机月份，取前一个月的资料表速率
		--先在表中增加拆机时间的字段
		alter table rptdev.tmp_liq_ppxykdsj_210817_list add(
		HIST_CREATE_DATE integer
		);commit;
		--初始化拆机时间
		update rptdev.tmp_liq_ppxykdsj_210817_list 
		set HIST_CREATE_DATE=0
		--更新拆机时间
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.HIST_CREATE_DATE=convert(integer,dateformat(b.HIST_CREATE_DATE ,'yyyymm')) 
		from bssdev.rpt_comm_cm_serv_hist as b 
		where b.acc_nbr=a.acc_nbr;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机时间：' || @@ROWCOUNT || ' 条' type info to client;
		--循环
		begin
		declare @month_id int;
		set @month_id=202108;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机主套餐
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.kd_prod_offer_name=b.offer_name
		from bssdev.offer as b,
		rptdev.rpt_comm_cm_serv_union as c
		where c.kd_prod_offer_id = b.offer_id 
		and a.acc_nbr=c.acc_nbr 
		and c.month_id=@month_id 
		and a.kd_prod_offer_name is null;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新宽带主套餐：' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit;

		--更新是否单宽
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.is_dk=if b.is_rh=1 then '否' else '是' endif 
		from rptdev.RPT_DAILY_KD_CM_LIST_UNION as b 
		where b.month_id = 202108
		and a.acc_nbr = b.acc_nbr;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新是否单宽：' || @@ROWCOUNT || ' 条' type info to client;
		--为空在历史资料表中提取
		--先查看最小拆机时间和最大拆机时间
		select acc_nbr,HIST_CREATE_DATE from bssdev.rpt_comm_cm_serv_hist 
		where acc_nbr in (select acc_nbr from rptdev.tmp_liq_ppxykdsj_210817_list where is_dk is null);
		--循环
		begin
		declare @month_id int;
		set @month_id=202108;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机是否单宽
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.is_dk=if b.is_rh=1 then '否' else '是' endif 
		from rptdev.RPT_DAILY_KD_CM_LIST_UNION as b 
		where a.acc_nbr = b.acc_nbr 
		and a.is_dk is null 
		and b.month_id = @month_id;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新宽带主套餐：' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit;

		--更新宽带关联移动号码
		--方法1）
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.yd_acc_nbr=c.acc_nbr
		from rptdev.rpt_comm_cm_msdisc_union b,rptdev.rpt_comm_cm_msdisc_union as c
		where a.acc_nbr=b.acc_nbr
		and b.month_id=202108
		and c.month_id=202108
		and b.msrel_id = c.msrel_id 
		and c.prod_id in( 3204,3205 );  --3204,3205表示移动
		commit;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新宽带关联移动号码：' || @@ROWCOUNT || ' 条' type info to client;
		--id_dk为否，但yd_acc_nbr为空在历史资料表中提取
		--先查看最小拆机时间和最大拆机时间
		select acc_nbr,HIST_CREATE_DATE from bssdev.rpt_comm_cm_serv_hist 
		where acc_nbr in (select acc_nbr from rptdev.tmp_liq_ppxykdsj_210817_list where is_dk ='否' and yd_acc_nbr is null);
		--循环
		begin
		declare @month_id int;
		set @month_id=202108;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机宽带关联移动号码
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.yd_acc_nbr=c.acc_nbr
		from rptdev.rpt_comm_cm_msdisc_union b,rptdev.rpt_comm_cm_msdisc_union as c
		where a.acc_nbr=b.acc_nbr
		and b.month_id=@month_id
		and c.month_id=@month_id
		and b.msrel_id = c.msrel_id 
		and a.yd_acc_nbr is null 
		and a.is_dk='否' 
		and c.prod_id in( 3204,3205 );
		commit;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新宽带关联移动号码：' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit;
		--方法2）
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.yd_acc_nbr=b.yd_acc_nbr
		from rptdev.RPT_DAILY_KD_CM_LIST_union as b
		where a.acc_nbr=b.acc_nbr
		and b.month_id=202108;
		commit;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新接入号关联移动号 ' || @@ROWCOUNT || ' 条' type info to client;

		--更新接入号状态
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.acc_state = b.attr_value_name
		from bssdev.attr_value as b,
		bssdev.attr_spec as c, 
		bssdev.rpt_comm_cm_serv as d 
		where a.acc_nbr=d.acc_nbr 
		and d.state = b.attr_value
		and b.city_id='200'--广州区域
		and b.attr_id = 4000000201  --状态分类，必须带的限定条件
		and b.attr_id = c.attr_id;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新号码状态 ' || @@ROWCOUNT || ' 条' type info to client;
		--为空,则在拆机表更新是否拆机
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.acc_state='拆机' 
		from bssdev.RPT_COMM_CM_SERV_HIST as b 
		where a.acc_nbr=b.acc_nbr 
		and a.acc_state is null; 
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新号码拆机状态 ' || @@ROWCOUNT || ' 条' type info to client;
		--更新停机原因（主动停机/欠费停机/其他）,若为空查看该号码在资料表的stop_reason_id，再去bssdev.attr_spec取attr_name
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.acc_state=c.attr_name
		from bssdev.prod_inst_attr b, bssdev.attr_spec c, 
		bssdev.rpt_comm_cm_serv as d 
		where a.acc_nbr = d.acc_nbr 
		and d.serv_id = b.prod_inst_id
		and a.acc_state = '停机'
		and b.char_class='04'  --分类，必须带的限定条件
		and b.attr_id=c.attr_id
		and d.stop_reason_id=b.attr_id;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || '更新停机原因'||@@ROWCOUNT||' 条' type info to client;

		--更新停机时间(停机时间是stop_date，停机时长是stop_time)，部分号码stop_date为空可能是因为没有录入数据
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.stop_time=convert(date,b.stop_date,'yyyymmdd hh:nn:ss')
		from bssdev.rpt_comm_cm_serv as b 
		where a.acc_nbr = b.acc_nbr 
		and a.acc_state not in ( '拆机','预拆机','在用');
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || '更新停机时间'||@@ROWCOUNT||' 条' type info to client;

		--是否受理了“DM0002-A01 2012年校园翼起来宽带代收费_免宽带月租（代收费）”
		--1）还在网的号码
		update rptdev.tmp_liq_ppxykdsj_210817_list 
		set is_bltc1='否';commit;
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.is_bltc1='是' from rptdev.rpt_comm_cm_msdisc_union as b, 
		bssdev.offer as c 
		where a.acc_nbr=b.acc_nbr 
		and b.prod_offer_id=c.offer_id 
		and c.prod_offer_code='DM0002-A01' 
		and b.month_id=202108;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || '更新是否办理套餐1'||@@ROWCOUNT||' 条' type info to client;
		--2）已拆机的号码
		--循环
		begin
		declare @month_id int;
		set @month_id=202108;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机号码是否办理套餐
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.is_bltc1='是' from rptdev.rpt_comm_cm_msdisc_union as b, 
		bssdev.offer as c 
		where a.acc_nbr=b.acc_nbr 
		and b.prod_offer_id=c.offer_id 
		and c.prod_offer_code='DM0002-A01' 
		and b.month_id=@month_id 
		and a.is_bltc1='否';
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机号码是否办理套餐1：' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit;

		--是否受理了“SJ0912-A08-1-2  校园天翼宽带高竞争院校融合套餐(首月收费)（1元）_4M_2013年三季度_粤”
		--1）还在网的号码
		update rptdev.tmp_liq_ppxykdsj_210817_list 
		set is_bltc2='否';commit;
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.is_bltc2='是' from rptdev.rpt_comm_cm_msdisc_union as b, 
		bssdev.offer as c 
		where a.acc_nbr=b.acc_nbr 
		and b.prod_offer_id=c.offer_id 
		and c.prod_offer_code='SJ0912-A08-1-2' 
		and b.month_id=202108;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || '更新是否办理套餐2'||@@ROWCOUNT||' 条' type info to client;
		--2）已拆机的号码
		--循环
		begin
		declare @month_id int;
		set @month_id=202108;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机号码是否办理套餐
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.is_bltc2='是' from rptdev.rpt_comm_cm_msdisc_union as b, 
		bssdev.offer as c 
		where a.acc_nbr=b.acc_nbr 
		and b.prod_offer_id=c.offer_id 
		and c.prod_offer_code='SJ0912-A08-1-2' 
		and b.month_id=@month_id 
		and a.is_bltc2='否';
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新拆机号码是否办理套餐2：' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit;

		--受理了销售品SJ0911-A05-1-1且在有效期内（是/否）
		--在网的号码
		update rptdev.tmp_liq_ppxykdsj_210817_list 
		set is_bltc_yxz='未受理';commit;
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.is_bltc_yxz=if b.limit_date>=now() then '是' else '否' endif
		from rptdev.rpt_comm_cm_msdisc_union as b, 
		bssdev.offer as c 
		where a.acc_nbr=b.acc_nbr 
		and b.prod_offer_id=c.offer_id 
		and c.prod_offer_code='SJ0911-A05-1-1' 
		and b.month_id=202108;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || '更新是否办理套餐3'||@@ROWCOUNT||' 条' type info to client;

		--更新揽装人工号
		--salestaff_id为-1的没有sales_code
		--1）在网号码
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.sales_code=b.staff_code from 
		bssdev.staff as b, 
		rptdev.rpt_comm_cm_serv_union as c 
		where a.acc_nbr=c.acc_nbr 
		and c.salestaff_id=convert(varchar,b.staff_id) 
		and c.month_id=202108;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新揽装人工号 ' || @@ROWCOUNT || ' 条' type info to client;
		--2)拆机号码
		--循环
		begin
		declare @month_id int;
		set @month_id=202108;   --最大拆机时间

		while @month_id>=202107 loop   --最小拆机时间
		set @month_id = cast(dateformat(dateadd(month,-1,convert(date,convert(varchar,@month_id)||'01')),'yyyymm') as integer);  --减去一个月，取上个月
		--更新拆机号码揽装工号
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.sales_code=b.staff_code from 
		bssdev.staff as b, 
		rptdev.rpt_comm_cm_serv_union as c 
		where a.acc_nbr=c.acc_nbr 
		and c.salestaff_id=convert(varchar,b.staff_id) 
		and a.sales_code is null 
		and c.month_id=@month_id;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新揽装人工号 ' || @@ROWCOUNT || ' 条' type info to client;
		end loop ;
		end;
		commit;


		--更新揽装人
		--有些sales_code在bssdev.sales_man表中没有数据
		update rptdev.tmp_liq_ppxykdsj_210817_list as a
		set a.sales_man_name = b.sales_man_name from
		bssdev.sales_man as b 
		where a.sales_code = b.sales_code;
		commit work;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新揽装人名 ' || @@ROWCOUNT || ' 条' type info to client;

		--更新揽装工号所属分局
		--有些channel_id在bssdev.SALE_OUTLERS表中subst_id为空
		update rptdev.tmp_liq_ppxykdsj_210817_list as a 
		set a.subst_name=c.subst_name  
		from bssdev.sales_man as b
		,bssdev.SALE_OUTLERS as c 
		where a.sales_code = b.sales_code
		and b.OWN_CHANNEL_ID = c.channel_id 
		and b.status_cd = 'S0A'  --SOA表示有效
		and c.status_cd = 'S0A';
		commit;
		message Dateformat(now(),'yyyymmdd hh:nn:ss') || ' 更新揽装人局向: ' || @@ROWCOUNT || ' 条' type info to client;




		--导出数据
		select '接入号','多媒体账号','入网时间','统计日期','学校名称','接入方式','速率','域名','接入号对应的主套餐','是否为单宽',
		'接入号关联的移动号码','接入号状态','停机时间','是否受理了DM0002-A01','是否受理了SJ0912-A08-1-2',
		'受理了销售品SJ0911-A05-1-1且在有效期内','揽装人','揽装工号','揽装工号所属分局'
		>#D:\lemon\宽带组数据\师傅的小作业\申请匹配翼起来宽带数据\输出\校园宽带数据.txt
		select acc_nbr,acc_nbr2,rw_date,sum_date,school_name,fttx_type_name,speed_value,ym,kd_prod_offer_name,is_dk,yd_acc_nbr,
		acc_state,stop_time,is_bltc1,is_bltc2,is_bltc_yxz,sales_man_name,sales_code,subst_name
		from rptdev.tmp_liq_ppxykdsj_210817_list
		>>#D:\lemon\宽带组数据\师傅的小作业\申请匹配翼起来宽带数据\输出\校园宽带数据.txt
		commit work;
		
		
月欠费 summary_ods_month_city.tb_comm_arrear_all_mon
日欠费 select prod_inst_id as serv_id,total_amount,yyyymmdd,substr(yyyymmdd,1,6)  as month_id
from  dws_cbs.dws_bigdatadun 
where billing_cycle_id = '${last_2month_first_date}' --上两个月的第一天
and city_id=200
and  substr(yyyymmdd,1,6) = cast('${month_id}' as string)
