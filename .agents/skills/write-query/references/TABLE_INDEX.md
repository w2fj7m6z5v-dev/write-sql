# CDAP 表索引（运行时）

> 机器友好的表目录。**路由决策看 `ROUTING.md`，本文件只做表名/Hive 名/文档路径查找。** 落 SQL 前仍需打开 `tables/*.md` 核对 frontmatter、字段、粒度、分区和常用条件。

## 使用规则

- 优先按 `table_name`、`hive_name`、`prod_hive_name`、业务事实共同定位，不只看序号。
- `prod_hive_name` 非空时，落 SQL 优先使用生产现网名，并在输出中让用户校对。
- 字段、粒度、分区、适用范围和避用条件以 `file_path` 指向的表文档或 `ROUTING.md` 为准。
- 本文件只回答“可能是哪张表”和 `file_path`；主表路由决策见 `ROUTING.md`，不要在本文件重复路由。
- 如果用户已经明确主表或生产表名，不要用本文件改写用户选择；只用来核对表文档路径和生产表名。

## 快速定位

本文件只做表名 / Hive 名 / `file_path` 查找。**主表路由决策见 `ROUTING.md`**；标准指标见 `METRIC_INDEX.md`；复杂专项见 `scenarios/INDEX.md`。本文件不维护粒度、分区或 `use_when` / `avoid_when` 规则。

| 查什么 | 去哪里 |
|---|---|
| 业务需求 → 主表怎么选 | `ROUTING.md` |
| 标准指标 → 技术口径 SQL | `METRIC_INDEX.md` + `metrics/` |
| 生产表名 / Hive 名 / 表文档路径 | 下方完整索引表 |
| 附件驱动 / 跨表编排专项 | `scenarios/INDEX.md` |

## 选表输出要求

输出“主表确认”时，至少带出：

- `table_id`、`table_name`、`prod_hive_name`。
- `file_path`，方便下一步打开表文档做字段映射。
- 选表理由：一句话说明业务事实为什么在这张表。
- 排除项：列出 1-3 张容易误选的表及原因。

| table_id | table_name | hive_name | prod_hive_name | file_path |
|---|---|---|---|---|
|000|账务信息关系表|||tables/000_账务信息关系表.md|
| 001 | 移动新装清单 | dwd_yz_cm_cdma_ydxz_list | dwd_yz_cm_cdma_ydxz_list | tables/001_移动新装清单.md |
|002|fttr清单|dwm_fttr_list|dwm_fttr_list|tables/002_fttr清单.md|
|003|小微ICT竣工清单|ads_yz_xwict_all_list|ads_yz_xwict_all_list|tables/003_小微ICT竣工清单.md|
|004|合约清单|dwm_yz_cm_cdma_hy_final|dwm_yz_cm_cdma_hy_final|tables/004_合约清单.md|
|005|移动划小清单|ads_yz_cdma_hx_list|ads_yz_cdma_hx_list|tables/005_移动划小清单.md|
| 006 | 宽带新装清单 | ads_yz_kd_new_list | ads_yz_kd_new_list | tables/006_宽带新装清单.md |
|007|净增积分清单|ads_yz_tb_tyks_score_inc_mtd|ads_yz_tb_tyks_score_inc_mtd|tables/007_净增积分清单.md|
|008|129+套餐升降档路径清单|ads_yz_bd129_sdjd_list|ads_yz_bd129_sdjd_list|tables/008_129+套餐升降档路径清单.md|
|009|129+套餐升降档路径多维表|ads_yz_bd129_sdjd_dwb|ads_yz_bd129_sdjd_dwb|tables/009_129+套餐升降档路径多维表.md|
|010|降档原始清单|ads_yz_sunshou_acc_list|ads_yz_sunshou_acc_list|tables/010_降档原始清单.md|
|011|降档动作订单清单|ads_yz_sunshou_qudao|ads_yz_sunshou_qudao|tables/011_降档动作订单清单.md|
| 012 | 发展存量积分清单 | ads_yz_score_all_list | ads_yz_score_all_list | tables/012_发展存量积分清单.md |
| 014 | 优惠资料表 | ads_yz_rpt_comm_cm_msdisc_final | ads_yz_rpt_comm_cm_msdisc_final；dwd_yz_rpt_comm_cm_msdisc_mon_final（月表/历史快照） | tables/014_优惠资料表.md |
|015|字典表视图|dws_crm_cfguse.dws_attr_value|dws_crm_cfguse.dws_attr_value|tables/015_字典表视图.md|
| 016 | 字典维表视图 / 特性规格维表 | dws_crm_cfguse.dws_attr_spec | dws_crm_cfguse.dws_attr_spec | tables/016_字典维表视图.md |
|017|产品维表视图|dws_crm_cfguse.dws_product|dws_crm_cfguse.dws_product|tables/017_产品维表视图.md|
|018|机构维表视图|zone_gz_yz.dwd_yz_dim_org|zone_gz_yz.dwd_yz_dim_org|tables/018_机构维表视图.md|
| 019 | 移动主套餐维表视图 | metadata_ods_day.md_ft_cdma_disc_config | metadata_ods_day.md_ft_cdma_disc_config | tables/019_移动主套餐维表视图.md |
|020|销售品维表视图|dws_crm_cfguse.dws_offer|dws_crm_cfguse.dws_offer|tables/020_销售品维表视图.md|
| 079 | 地址维表 | zone_gz_yz.dwd_yz_addr_final | zone_gz_yz.dwd_yz_addr_final | tables/079_地址维表.md |
|022|商企入网清单|zone_gz_yz.ads_yz_shangqi_rw_list|zone_gz_yz.ads_yz_shangqi_rw_list|tables/022_商企入网清单.md|
|023|基础业务托收清单|zone_gz_yz.ads_yz_tb_cl_tuoshou_list|zone_gz_yz.ads_yz_tb_cl_tuoshou_list|tables/023_基础业务托收清单.md|
|024|营业厅月度订单受理量清单|zone_gz_yz.ads_yz_yyt_sl_list|zone_gz_yz.ads_yz_yyt_sl_list|tables/024_营业厅月度订单受理量清单.md|
|025|专业营服全业务清单（改革）|ads_yz_tb_comm_cm_all_zyyf_final|ads_yz_tb_comm_cm_all_zyyf_final|tables/025_专业营服全业务清单（改革）.md|
|026|小微ict场景化收入数据|zone_gz_yz.ads_yz_scb_ict_fee_list|zone_gz_yz.ads_yz_scb_ict_fee_list|tables/026_小微ict场景化收入数据.md|
|027|满卡报表清单|zone_gz_yz.ads_yz_mk_list|zone_gz_yz.ads_yz_mk_list|tables/027_满卡报表清单.md|
|029|企微粉丝清单报表|zone_gz_yz.dwd_yz_qywx_daily_list_end|zone_gz_yz.dwd_yz_qywx_daily_list_end|tables/029_企微粉丝清单报表.md|
|071|小微清单2024|zone_gz_yz.ads_yz_ict_all2024_LIST|zone_gz_yz.ads_yz_ict_all2024_LIST|tables/071_小微清单2024.md|
|030|移动续约清单|ads_yz_ydxy_daily_list|ads_yz_ydxy_daily_list|tables/030_移动续约清单.md|
|031|移动续约多维表|ads_yz_ydxy_group|ads_yz_ydxy_group|tables/031_移动续约多维表.md|
|032|宽带续约清单|ads_yz_kd_xy_list|ads_yz_kd_xy_list|tables/032_宽带续约清单.md|
|033|双线全量清单|ads_yz_sx_qlyz_list|ads_yz_sx_qlyz_list|tables/033_双线全量清单.md|
|034|主宽拆机挽留清单|ads_yz_kd_cjwl_list|ads_yz_kd_cjwl_list|tables/034_主宽拆机挽留清单.md|
|035|反诈资料宽表|dwm_yz_fz_rpt_comm_cm_serv_d_final|dwm_yz_fz_rpt_comm_cm_serv_d_final|tables/035_反诈资料宽表.md|
|036|政企移动入网清单报表|dwd_yz_zhengqi_yd_new_daily_list_end|dwd_yz_zhengqi_yd_new_daily_list_end|tables/036_政企移动入网清单报表.md|
|039|欠不列预警清单|zone_gz_yz.ads_ys_qblyj_daily|zone_gz_yz.ads_ys_qblyj_daily|tables/039_欠不列预警清单.md|
| 040 | 全业务号码订单表 | zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final | zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final；zone_gz_yz.dwm_yz_rpt_comm_ba_subs_mon_final（月表/历史归档） | tables/040_全业务号码订单表.md |
| 041 | 优惠订单表 | zone_gz_yz.dwm_yz_rpt_comm_ba_msdisc_final | dwm_yz_rpt_comm_ba_msdisc_final；dwm_yz_rpt_comm_ba_msdisc_mon_final（月表/历史归档） | tables/041_优惠订单表.md |
| 042 | 号码协销表 | zone_gz_yz.dwd_yz_cm_obj_xx_final | zone_gz_yz.dwd_yz_cm_obj_xx_final；zone_gz_yz.dwd_yz_cm_obj_xx_mon_final（月表） | tables/042_号码协销表.md |
| 043 | 订单协销表 | zone_gz_yz.dwd_yz_ba_obj_xx_final | zone_gz_yz.dwd_yz_ba_obj_xx_final | tables/043_订单协销表.md |
| 047 | 最终版划小收入 | dwm_srhx_serv_list_mon | dwm_srhx_serv_list_mon_final | tables/047_最终版划小收入.md |
| 048 | 全量科目级收入 | dwm_srhx_src_income_list_mon | dwm_srhx_src_income_list_mon | tables/048_全量科目级收入.md |
|049|欠费日清单|ads_ys_lst_qf_pushdata_daily_bss|ads_ys_lst_qf_pushdata_daily_bss|tables/049_欠费日清单.md|
|050|宽带到达套餐收入清单|zone_gz_yz.ads_yz_kddd_tcsr_list|zone_gz_yz.ads_yz_kddd_tcsr_list|tables/050_宽带到达套餐收入清单.md|
|051|小业务收入多维表|zone_gz_yz.ads_yz_ict_all_ydxyw_sr_LIST|zone_gz_yz.ads_yz_ict_all_ydxyw_sr_LIST|tables/051_小业务收入多维表.md|
|052|调退清单|zone_gz_yz.ads_ys_tt_daily|zone_gz_yz.ads_ys_tt_daily|tables/052_调退清单.md|
|053|宽带到达监控多维表|zone_gz_yz.ads_yz_lch_kd_list_mid|zone_gz_yz.ads_yz_lch_kd_list_mid|tables/053_宽带到达监控多维表.md|
|054|新入网辅导报表|zone_gz_yz.dwd_yz_new_fudao_daily_list_bao|zone_gz_yz.dwd_yz_new_fudao_daily_list_bao|tables/054_新入网辅导报表.md|
|055|滞纳金清单|dwm_tb_zhinajin_baobiao_list_ys_site_mon|dwm_tb_zhinajin_baobiao_list_ys_site_mon|tables/055_滞纳金清单.md|
|056|网络维护服务实缴清单|zone_gz_yz.ads_yz_scb_kd_wlwhfw_ss_list|zone_gz_yz.ads_yz_scb_kd_wlwhfw_ss_list|tables/056_网络维护服务实缴清单.md|
|057|视联网发展规模清单|zone_gz_yz.ads_yz_slw_136_list|zone_gz_yz.ads_yz_slw_136_list|tables/057_视联网发展规模清单.md|
|058|商客新建档客户清单|zone_gz_yz.ads_yz_xjd_kh_list|zone_gz_yz.ads_yz_xjd_kh_list|tables/058_商客新建档客户清单.md|
|059|客服投诉抱怨清单|zone_gz_yz.ads_yz_kfb_tousu_bendi_month_list_end|zone_gz_yz.ads_yz_kfb_tousu_bendi_month_list_end|tables/059_客服投诉抱怨清单.md|
|060|转化率|zone_gz_yz.ads_yz_zhl_list|zone_gz_yz.ads_yz_zhl_list|tables/060_转化率.md|
|061|移动固话叠加小业务清单|zone_gz_yz.ads_yz_yd_gh_xyw_list|zone_gz_yz.ads_yz_yd_gh_xyw_list|tables/061_移动固话叠加小业务清单.md|
|062|预付费日清单|zone_gz_yz.ads_ys_lst_balance_monitor|zone_gz_yz.ads_ys_lst_balance_monitor|tables/062_预付费日清单.md|
|063|公安举报涉诈数据清单|zone_gz_yz.ads_yz_gajbsznbr_list|zone_gz_yz.ads_yz_gajbsznbr_list|tables/063_公安举报涉诈数据清单.md|
|064|固话延伸核查清单|zone_gz_yz.ads_yz_fz_ghyshc_list_final|zone_gz_yz.ads_yz_fz_ghyshc_list_final|tables/064_固话延伸核查清单.md|
|065|双线续约清单|zone_gz_yz.ads_yz_sx_xy_list|zone_gz_yz.ads_yz_sx_xy_list|tables/065_双线续约清单.md|
|066|移动小业务退订清单|zone_gz_yz.ads_yz_all_ydxyw_TD_LIST|zone_gz_yz.ads_yz_all_ydxyw_TD_LIST|tables/066_移动小业务退订清单.md|
|067|实名装维清单|zone_gz_yz.ads_yz_smzw_list|zone_gz_yz.ads_yz_smzw_list|tables/067_实名装维清单.md|
|068|燃气卫士到达清单|zone_gz_yz.ads_yz_rqws_list|zone_gz_yz.ads_yz_rqws_list|tables/068_燃气卫士到达清单.md|
| 069 | 全业务资料表 | ads_yz_tb_comm_cm_all_final | dwm_yz_tb_comm_cm_all_final；dwm_yz_tb_comm_cm_all_mon_final | tables/069_全业务资料表.md |
|070|小微场景化手工计列清单|zone_gz_yz.ads_yz_ict_all_cjhbb2024_sr_LIST|zone_gz_yz.ads_yz_ict_all_cjhbb2024_sr_LIST|tables/070_小微场景化手工计列清单.md|
|073|存量未托收清单|zone_gz_yz.ads_yz_clts_change_list_mon|zone_gz_yz.ads_yz_clts_change_list_mon|tables/073_存量未托收清单.md|
|074|安全产品清单|zone_gz_yz.ADS_YZ_ACCP_NEW_LIST|zone_gz_yz.ADS_YZ_ACCP_NEW_LIST|tables/074_安全产品清单.md|
|075|小微收入清单|zone_gz_yz.ads_yz_ict2024_all_sr_LIST_ex_list|zone_gz_yz.ads_yz_ict2024_all_sr_LIST_ex_list|tables/075_小微收入清单.md|
|077|家庭地址客户入网价值清单|zone_gz_yz.ads_yz_yzn_addr_label_setting_list|zone_gz_yz.ads_yz_yzn_addr_label_setting_list|tables/077_家庭地址客户入网价值清单.md|
|080|大额榜单账单级清单|zone_gz_yz.ads_ys_bd_bill|zone_gz_yz.ads_ys_bd_bill|tables/080_大额榜单账单级清单.md|
| 081 | 揽装积分清单 | ads_yz_lyf_lz | ads_yz_lyf_lz | tables/081_揽装积分清单.md |
|082|双线净增积分清单|ads_yz_tb_tyks_score_inc_zx_mtd|ads_yz_tb_tyks_score_inc_zx_mtd|tables/082_双线净增积分清单.md|
|083|拆机登记清单（新）|ads_yz_tb_zsh_cjdj_list|ads_yz_tb_zsh_cjdj_list|tables/083_拆机登记清单（新）.md|
|087|片区收入多维表|ads_srhx_xxb_wyh_region_list_mon|ads_srhx_xxb_wyh_region_list_mon|tables/087_片区收入多维表.md|
|088|财务部收入多维表|ads_yz_cwb_sr_list|ads_yz_cwb_sr_list|tables/088_财务部收入多维表.md|
|089|财务部佣金多维表|ads_yz_yj_list|ads_yz_yj_list|tables/089_财务部佣金多维表.md|
|090|财务部终端装维成本|ads_yz_zwzd_cost_all_list|ads_yz_zwzd_cost_all_list|tables/090_财务部终端装维成本.md|
|091|财务部积分多维表|ads_yz_finance_jf_list|ads_yz_finance_jf_list|tables/091_财务部积分多维表.md|
|092|网点保证金|ads_ys_deposit|ads_ys_deposit|tables/092_网点保证金.md|
|093|移动宽带质态监控多维表-宽带清单|ads_zt_kdx_list|ads_zt_kdx_list|tables/093_移动宽带质态监控多维表-宽带清单.md|
|095|历史欠不列月清单|ads_ys_lst_qbl_mon|ads_ys_lst_qbl_mon|tables/095_历史欠不列月清单.md|
|096|酒宽续约清单|ads_yz_jdkd_xy_list|ads_yz_jdkd_xy_list|tables/096_酒宽续约清单.md|
| 097 | 基本面月清单 | ads_ys_jbm | ads_ys_jbm | tables/097_基本面月清单.md |
|098|医保竣工清单|ads_wjbg_list|ads_wjbg_list|tables/098_医保竣工清单.md|
|099|医保未竣工清单|ads_yb_wjg_list|ads_yb_wjg_list|tables/099_医保未竣工清单.md|
|100|欠补列日清单|zone_gz_yz.ads_ys_qbl_real|zone_gz_yz.ads_ys_qbl_real|tables/100_欠补列日清单.md|
|101|台阶收入清单|ads_yz_xsb_tjsr_skj_list_db|ads_yz_xsb_tjsr_skj_list_db|tables/101_台阶收入清单.md|
|103|存量专线提（降）值清单|ads_yz_sx_cltz_gt|ads_yz_sx_cltz_gt|tables/103_存量专线提（降）值清单.md|
|104|降档清单|ads_yz_jd_list|ads_yz_jd_list|tables/104_降档清单.md|
| 105 | 特性资料表 | summary_ods_day_city.tb_pre_cm_attr_all | summary_ods_day_city.tb_pre_cm_attr_all（日表）；iodata_ods_month_city.tb_pre_cm_attr_all_mon（月表） | tables/105_特性资料表.md |
| 106 | 附属产品资料表 | summary_ods_day_city.rpt_comm_cm_subserv | summary_ods_day_city.rpt_comm_cm_subserv（日表）；iodata_ods_month_city.rpt_comm_cm_subserv_mon（月表） | tables/106_附属产品资料表.md |
| 107 | 销售品参数表 | summary_ods_day_city.rpt_comm_cm_msparam | summary_ods_day_city.rpt_comm_cm_msparam | tables/107_销售品参数表.md |
| 108 | 产权客户全量表 | dws_crm_cust.dws_customer | dws_crm_cust.dws_customer | tables/108_产权客户全量表.md |
| 109 | 直销客户表 | zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final | zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final | tables/109_直销客户表.md |
| 110 | 结算账单表 | dws_tpss_jszx.dws_settle_bill | dws_tpss_jszx.dws_settle_bill | tables/110_结算账单表.md |
| 111 | 揽装人维表 | zone_gz_yz.dwd_yz_sales_man_final | zone_gz_yz.dwd_yz_sales_man_final；zone_gz_yz.dwd_yz_sales_man_mon_final | tables/111_揽装人维表.md |
| 112 | 网点维表 | zone_gz_yz.dwd_yz_sale_outlers_final | zone_gz_yz.dwd_yz_sale_outlers_final；zone_gz_yz.dwd_yz_sale_outlers_mon_final | tables/112_网点维表.md |
| 113 | 揽装所属表 | zone_gz_yz.dwd_yz_sales_man_outlers_final | zone_gz_yz.dwd_yz_sales_man_outlers_final；zone_gz_yz.dwd_yz_sales_man_outlers_mon_final | tables/113_揽装所属表.md |
| 114 | 国际漫游数据表 | dws_ctg.dws_mktag_download_share_guoman_label | dws_ctg.dws_mktag_download_share_guoman_label | tables/114_国际漫游数据表.md |
| 115 | 员工信息表 | dws_crm_cfguse.dws_staff | dws_crm_cfguse.dws_staff | tables/115_员工信息表.md |
| 116 | 固话使用记录月表 | summary_ods_month_city.tb_comm_ywl_gw_mon | summary_ods_month_city.tb_comm_ywl_gw_mon | tables/116_固话使用记录月表.md |
| 117 | 实收来源汇总表 | zone_gz_yz.dwd_yz_if_real_src_sum_new_final | zone_gz_yz.dwd_yz_if_real_src_sum_new_final | tables/117_实收来源汇总表.md |
| 118 | 移机订单表 | dwd_yz_rpt_comm_ba_subs_move_final | dwd_yz_rpt_comm_ba_subs_move_final | tables/118_移机订单表.md |
| 119 | 设备资源关系表 | ads_yz_prod_res_inst_rel_final | ads_yz_prod_res_inst_rel_final；dws_crm_cust.dws_prod_res_inst_rel（当前原始表）；dws_crm_cust.dws_prod_res_inst_rel_his（历史原始表） | tables/119_设备资源关系表.md |
| 120 | 产品关联关系表 | dws_crm_cust.dws_prod_inst_rel_a | dws_crm_cust.dws_prod_inst_rel_a | tables/120_产品关联关系表.md |
| 121 | 业务关联关系表 | dws_crm_cust.dws_prod_inst_rel_grp_a | dws_crm_cust.dws_prod_inst_rel_grp_a | tables/121_业务关联关系表.md |
| 122 | 名单制管控清单 | ads_yz_mo_ccust_mdz_final | ads_yz_mo_ccust_mdz_final | tables/122_名单制管控清单.md |
| 123 | 终端自注册清单 | summary_ods_day_szx.rpt_terminal_type_new | summary_ods_day_szx.rpt_terminal_type_new | tables/123_终端自注册清单.md |
| 124 | 揽装人认领规则表 | ads_yz_sales_grid_rule_list | ads_yz_sales_grid_rule_list；ads_yz_sales_grid_rule_list_cl | tables/124_揽装人认领规则表.md |
| 125 | 服务当前划小规则表 | dwd_yz_jyfx_serv_grid_final | dwd_yz_jyfx_serv_grid_final | tables/125_服务当前划小规则表.md |
| 126 | 客户联系人关系表 | dws_crm_cust.dws_cust_contact_info_rel | dws_crm_cust.dws_cust_contact_info_rel | tables/126_客户联系人关系表.md |
| 127 | 联系人信息表 | dws_crm_cust.dws_contacts_info | dws_crm_cust.dws_contacts_info | tables/127_联系人信息表.md |
| 128 | 产品实例当前表 | dws_crm_cust.dws_prod_inst | dws_crm_cust.dws_prod_inst | tables/128_产品实例当前表.md |
| 129 | 服务资源表 | dws_crm_cust.dws_cust_serv_res | dws_crm_cust.dws_cust_serv_res；dws_crm_cust.dws_cust_serv_res_his（历史表） | tables/129_服务资源表.md |
| 130 | 附属产品配置表 | dwd_dim_all_config | dwd_dim_all_config | tables/130_附属产品配置表.md |
| 131 | 产品实例账户关系表 | dws_crm_cust.dws_prod_inst_acct_rel_aap | dws_crm_cust.dws_prod_inst_acct_rel_aap | tables/131_产品实例账户关系表.md |
| 132 | 支付方案表 | dws_crm_cust.dws_payment_plan | dws_crm_cust.dws_payment_plan | tables/132_支付方案表.md |
| 133 | 外部账户表 | dws_crm_cust.dws_ext_acct | dws_crm_cust.dws_ext_acct | tables/133_外部账户表.md |
| 134 | 银行表 | dws_crm_cfguse.dws_tb_cm_bank | dws_crm_cfguse.dws_tb_cm_bank | tables/134_银行表.md |
| 135 | 敏感客户黑名单表 | dws_crm_party.dws_special_list_black | dws_crm_party.dws_special_list_black | tables/135_敏感客户黑名单表.md |
| 136 | 证件本地表 | dws_crm_cust.dws_party_cert_local | dws_crm_cust.dws_party_cert_local | tables/136_证件本地表.md |
| 137 | 小翼发展清单 | zone_gz_yz.ads_yz_zqb_xyqg | zone_gz_yz.ads_yz_zqb_xyqg | tables/137_小翼发展清单.md |
| 138 | 高阶网关发展清单 | zone_gz_yz.ads_yz_wyh_gjwg_new_list | zone_gz_yz.ads_yz_wyh_gjwg_new_list | tables/138_高阶网关发展清单.md |
| 139 | 固话通话月表 | summary_ods_month_city.TB_COMM_YWL_GW_mon | summary_ods_month_city.TB_COMM_YWL_GW_mon | tables/139_固话通话月表.md |
| 140 | OP人员信息表 | ads_yz.ads_yz_dim_op_final | ads_yz.ads_yz_dim_op_final | tables/140_OP人员信息表.md |
| 141 | 附属产品订单表族 | summary_ods_day_city.rpt_comm_ba_sub_prod | summary_ods_day_city.rpt_comm_ba_sub_prod（日-当前）；summary_ods_day_city.rpt_comm_ba_sub_prod_hist（日-历史）；iodata_ods_month_city.rpt_comm_ba_sub_prod_mon（月-当前）；iodata_ods_month_city.rpt_comm_ba_sub_prod_hist_mon（月-历史） | tables/141_附属产品订单表族.md |
| 142 | 专线月租表 | ads_yz_sx_yz | ads_yz_sx_yz | tables/142_专线月租表.md |
| 143 | 非费用账目表 | dws_acct.dws_unacct_item | dws_acct.dws_unacct_item | tables/143_非费用账目表.md |
