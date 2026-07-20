# 专区权限表名映射

本文件由 `docs/专区权限隔离/专区表权限梳理.xlsx`（工作表 1，2026-07-20 基线）整理，是 `write-query` 的权限域物理表名权威。

## 使用规则

- `业支 Hive 原表` 是逻辑表匹配键；库名前缀存在差异时，可按末段表名匹配，但多条命中视为未登记。
- `分局视图模板` 中的 `th` 是天河示例占位；仅替换视图标识中的独立 `th` 为本地 `subst-code`。没有 `th` 的值是共享固定视图，直接使用。
- `无` 或空值表示该权限域没有登记视图，调用方回退业支原表并标注原因。
- 本文件不记录分类标题行，不以表名猜测未登记的视图。

| 中文名称 | 业支 Hive 原表 | 分局视图模板 | 销售部/政企部表 |
|---|---|---|---|
| 全业务资料表 | dwm_yz_tb_comm_cm_all_final | zone_gz.view_th_dwm_yz_tb_comm_cm_all_final | view_ads_yz_tb_comm_cm_all_final |
| 全业务号码订单表 | zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final | zone_gz.view_th_dwm_yz_rpt_comm_ba_subs_final | view_dwm_yz_rpt_comm_ba_subs_final |
| 优惠订单表 | zone_gz_yz.dwm_yz_rpt_comm_ba_msdisc_final | zone_gz.view_th_dwm_yz_rpt_comm_ba_msdisc_final | view_dwm_yz_rpt_comm_ba_msdisc_final |
| 移动新装清单 | dwd_yz_cm_cdma_ydxz_list | zone_gz.view_th_dwd_yz_cm_cdma_ydxz_list | view_dwd_yz_cm_cdma_ydxz_list |
| 宽带新装清单 | ads_yz_kd_new_list | zone_gz.view_th_ads_yz_kd_new_list | view_ads_yz_kd_new_list |
| 专业营服全业务清单（改革） | ads_yz_tb_comm_cm_all_zyyf_final | view_ads_yz_th_tb_comm_cm_all_zyyf_final | 无 |
| 基本面月清单 | ads_ys_jbm | zone_gz.view_th_ads_ys_jbm | view_ads_ys_jbm |
| 全量科目级收入 | dwm_srhx_src_income_list_mon | zone_gz.view_th_ads_srhx_src_income_list_mon | view_zqb_dwm_srhx_src_income_list_mon |
| 最终版划小收入 | dwm_srhx_serv_list_mon | zone_gz.view_th_ads_srhx_serv_list_mon | view_zqb_dwm_srhx_serv_list_mon |
| 台阶收入清单 | ads_yz_xsb_tjsr_skj_list_db | view_th_ads_yz_xsb_tjsr_skj_list_db | view_ads_yz_xsb_tjsr_skj_list_db |
| 片区收入多维表 | ads_srhx_xxb_wyh_region_list_mon | zone_gz.view_ads_srhx_xxb_wyh_region_list_mon | view_ads_srhx_xxb_wyh_region_list_mon |
| 财务部收入多维表 | ads_yz_cwb_sr_list | zone_gz.view_ads_yz_cwb_sr_list | view_ads_yz_cwb_sr_list |
| 小微收入清单 | zone_gz_yz.ads_yz_ict2024_all_sr_LIST_ex_list | zone_gz.view_th_ads_yz_ict2024_all_sr_LIST_ex_list | view_ads_yz_ict2024_all_sr_list_ex_list |
| 小业务收入多维表 | zone_gz_yz.ads_yz_ict_all_ydxyw_sr_LIST | zone_gz.view_th_ads_yz_ict_all_ydxyw_sr_LIST | view_ads_yz_ict_all_ydxyw_sr_list |
| 宽带到达套餐收入清单 | zone_gz_yz.ads_yz_kddd_tcsr_list | zone_gz.view_th_ads_yz_kddd_tcsr_list | view_ads_yz_kddd_tcsr_list |
| 小微ict场景化收入数据 | zone_gz_yz.ads_yz_scb_ict_fee_list | zone_gz.view_th_ads_yz_scb_ict_fee_list | view_ads_yz_scb_ict_fee_list |
| 移动续约清单 | ads_yz_ydxy_daily_list | zone_gz.view_th_ads_yz_ydxy_daily_list | view_ads_yz_ydxy_daily_list |
| 移动续约多维表 | ads_yz_ydxy_group | zone_gz.view_th_ads_yz_ydxy_group | view_ads_yz_ydxy_group |
| 宽带续约清单 | ads_yz_kd_xy_list | zone_gz.view_th_ads_yz_kd_xy_list | view_ads_yz_kd_xy_list |
| 双线续约清单 | zone_gz_yz.ads_yz_sx_xy_list | zone_gz.view_th_ads_yz_sx_xy_list | view_ads_yz_sx_xy_list |
| 酒宽续约清单 | ads_yz_jdkd_xy_list | zone_gz.view_th_ads_yz_jdkd_xy_list | view_ads_yz_jdkd_xy_list |
| 净增积分清单 | ads_yz_tb_tyks_score_inc_mtd | zone_gz.view_th | view_ads_yz_tb_tyks_score_inc_mtd |
| 发展存量积分清单 | ads_yz_score_all_list | zone_gz.view_th | view_ads_yz_score_all_list |
| 揽装积分清单 | ads_yz_lyf_lz | zone_gz.view_th_ads_yz_lyf_lz | view_ads_yz_lyf_lz |
| 双线净增积分清单 | ads_yz_tb_tyks_score_inc_zx_mtd | zone_gz.view_th_ads_yz_tb_tyks_score_inc_zx_mtd | view_ads_yz_tb_tyks_score_inc_zx_mtd |
| 财务部积分多维表 | ads_yz_finance_jf_list | zone_gz.view_ads_yz_finance_jf_list | view_ads_yz_finance_jf_list |
| 129+套餐升降档路径清单 | ads_yz_bd129_sdjd_list | zone_gz.view_th | view_ads_yz_bd129_sdjd_list |
| 129+套餐升降档路径多维表 | ads_yz_bd129_sdjd_dwb | zone_gz.view_th | 无 |
| 降档原始清单 | ads_yz_sunshou_acc_list | zone_gz.view_th | view_ads_yz_sunshou_acc_list |
| 降档动作订单清单 | ads_yz_sunshou_qudao | zone_gz.view_th | view_ads_yz_sunshou_qudao |
| 降档清单 | ads_yz_jd_list | view_th_ads_yz_jd_list | view_ads_yz_jd_list |
| 字典表视图 | dws_crm_cfguse.dws_attr_value | view_yz_dws_attr_value | view_yz_dws_attr_value |
| 字典维表视图 | dws_crm_cfguse.dws_attr_spec | view_yz_dws_attr_SPEC | view_yz_dws_attr_SPEC |
| 产品维表视图 | dws_crm_cfguse.dws_product | view_yz_dws_product | view_yz_dws_product |
| 机构维表视图 | zone_gz_yz.dwd_yz_dim_org | view_th_yz_dwd_yz_dim_org | view_yz_dwd_yz_dim_org |
| 移动主套餐维表视图 | metadata_ods_day.md_ft_cdma_disc_config | 无 | 无 |
| 销售品维表视图 | dws_crm_cfguse.dws_offer | view_yz_dws_offer | view_yz_dws_offer |
| 揽装人维表 | zone_gz_yz.dwd_yz_sales_man_final | 无 | view_dwd_yz_sales_man_final |
| 网点维表 | zone_gz_yz.dwd_yz_sale_outlers_final | 无 | view_dwd_yz_sale_outlers_final |
| 揽装所属表 | zone_gz_yz.dwd_yz_sales_man_outlers_final | view_yz_dwd_yz_sales_man_outlers_final | view_yz_dwd_yz_sales_man_outlers_final |
| 地址维表 | zone_gz_yz.dwd_yz_addr_final | 无 | 无 |
| 员工信息表 | dws_crm_cfguse.dws_staff | 无 | view_gdmdp_cfg_dws_staff |
| OP人员信息表 | ads_yz.ads_yz_dim_op_final | 无 | 无 |
| 优惠资料表 | ads_yz_rpt_comm_cm_msdisc_final | view_th_ads_yz_rpt_comm_cm_msdisc_final | view_ads_yz_rpt_comm_cm_msdisc_final |
| 欠不列预警清单 | zone_gz_yz.ads_ys_qblyj_daily | zone_gz.view_th_ads_ys_qblyj_daily | view_xsb_ads_ys_qblyj_daily |
| 欠费日清单 | ads_ys_lst_qf_pushdata_daily_bss | view_th_ads_ys_lst_qf_pushdata_daily_bss | view_ads_ys_lst_qf_pushdata_daily_bss |
| 调退清单 | zone_gz_yz.ads_ys_tt_daily | zone_gz.view_th_ads_ys_tt_daily | zone_gz.view_xsb_ads_ys_tt_daily |
| 滞纳金清单 | dwm_tb_zhinajin_baobiao_list_ys_site_mon | view_th_dwm_tb_zhinajin_baobiao_list_ys_site_mon | 无 |
| 历史欠不列月清单 | ads_ys_lst_qbl_mon |  | view_ads_ys_lst_qbl_mon_xsb |
| 欠补列日清单 | zone_gz_yz.ads_ys_qbl_real | view_th_ads_ys_qbl_real | zone_gz.view_ads_ys_qbl_real |
| 预付费日清单 | zone_gz_yz.ads_ys_lst_balance_monitor | zone_gz.view_th_ads_ys_lst_balance_monitor | view_ads_ys_lst_balance_monitor |
| 网点保证金 | ads_ys_deposit | zone_gz_yz.view_th_ads_ys_deposit | view_ads_ys_deposit |
| 商企入网清单 | zone_gz_yz.ads_yz_shangqi_rw_list | zone_gz.view_th_ads_yz_shangqi_rw_list | view_ads_yz_shangqi_rw_list |
| 满卡报表清单 | zone_gz_yz.ads_yz_mk_list | zone_gz.view_th_ads_yz_mk_list | view_ads_yz_shangqi_rw_list |
| 企微粉丝清单报表 | zone_gz_yz.dwd_yz_qywx_daily_list_end | zone_gz.view_th_dwd_yz_qywx_daily_list_end | view_dwd_yz_qywx_daily_list_end |
| 商客新建档客户清单 | zone_gz_yz.ads_yz_xjd_kh_list | zone_gz.view_th_ads_yz_xjd_kh_list | view_ads_yz_xjd_kh_list |
| 产权客户全量表 | dws_crm_cust.dws_customer | 无 | 无 |
| 直销客户表 | zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final | 无 | 无 |
| 名单制管控清单 | ads_yz_mo_ccust_mdz_final | 无 | 无 |
| 财务部佣金多维表 | ads_yz_yj_list | zone_gz.view_ads_yz_yj_list | view_ads_yz_yj_list |
| 财务部终端装维成本 | ads_yz_zwzd_cost_all_list | zone_gz.view_ads_yz_zwzd_cost_all_list | 无 |
| fttr清单 | dwm_fttr_list | zone_gz.view_th | view_dwm_fttr_list |
| 小微ICT竣工清单 | ads_yz_xwict_all_list | zone_gz.view_th | view_ads_yz_xwict_all_list |
| 合约清单 | dwm_yz_cm_cdma_hy_final | zone_gz.view_th | view_dwm_yz_cm_cdma_hy_final |
| 移动划小清单 | ads_yz_cdma_hx_list | zone_gz.view_th | view_ads_yz_cdma_hx_list |
| 双线全量清单 | ads_yz_sx_qlyz_list | zone_gz.view_th_ads_yz_sx_qlyz_list | view_ads_yz_sx_qlyz_list |
| 主宽拆机挽留清单 | ads_yz_kd_cjwl_list | zone_gz.view_th_ads_yz_kd_cjwl_list | view_ads_yz_kd_cjwl_list |
| 反诈资料宽表 | dwm_yz_fz_rpt_comm_cm_serv_d_final | view_dwm_yz_fz_rpt_comm_cm_serv_d_final | view_dwm_yz_fz_rpt_comm_cm_serv_d_final |
| 政企移动入网清单报表 | dwd_yz_zhengqi_yd_new_daily_list_end | view_dwd_yz_zhengqi_yd_new_daily_list_end | view_dwd_yz_zhengqi_yd_new_daily_list_end |
| 号码协销表 | zone_gz_yz.dwd_yz_cm_obj_xx_final | view_dwd_yz_cm_obj_xx_final | 无 |
| 订单协销表 | zone_gz_yz.dwd_yz_ba_obj_xx_final | view_dwd_yz_ba_obj_xx_final | 无 |
| 宽带到达监控多维表 | zone_gz_yz.ads_yz_lch_kd_list_mid | zone_gz.view_th_ads_yz_lch_kd_list_mid | view_ads_yz_lch_kd_list_mid |
| 网络维护服务实缴清单 | zone_gz_yz.ads_yz_scb_kd_wlwhfw_ss_list | zone_gz.view_ads_yz_scb_kd_wlwhfw_ss_list | 无 |
| 视联网发展规模清单 | zone_gz_yz.ads_yz_slw_136_list | zone_gz.view_th_ads_yz_slw_136_list | view_ads_yz_slw_136_list |
| 客服投诉抱怨清单 | zone_gz_yz.ads_yz_kfb_tousu_bendi_month_list_end | zone_gz.view_ads_yz_kfb_tousu_bendi_month_list_end | 无 |
| 转化率 | zone_gz_yz.ads_yz_zhl_list | zone_gz.view_th_ads_yz_zhl_list | view_ads_yz_zhl_list |
| 移动固话叠加小业务清单 | zone_gz_yz.ads_yz_yd_gh_xyw_list | zone_gz.view_ads_yz_yd_gh_xyw_list | view_ads_yz_yd_gh_xyw_list |
| 公安举报涉诈数据清单 | zone_gz_yz.ads_yz_gajbsznbr_list | zone_gz_yz.view_th_ads_yz_gajbsznbr_list | view_ads_yz_gajbsznbr_list |
| 固话延伸核查清单 | zone_gz_yz.ads_yz_fz_ghyshc_list_final | zone_gz_yz.view_th_ads_yz_fz_ghyshc_list_final | view_ads_yz_fz_ghyshc_list_final |
| 移动小业务退订清单 | zone_gz_yz.ads_yz_all_ydxyw_TD_LIST | zone_gz.view_ads_yz_all_ydxyw_TD_LIST | view_ads_yz_all_ydxyw_td_list |
| 实名装维清单 | zone_gz_yz.ads_yz_smzw_list | zone_gz.view_ads_yz_smzw_list | view_ads_yz_smzw_list |
| 燃气卫士到达清单 | zone_gz_yz.ads_yz_rqws_list | zone_gz.view_th_ads_yz_rqws_list | view_ads_yz_rqws_list |
| 新入网辅导报表 | zone_gz_yz.dwd_yz_new_fudao_daily_list_bao | view_th_dwd_yz_new_fudao_daily_list_bao | 无 |
| 小微清单2024 | zone_gz_yz.ads_yz_ict_all2024_LIST | zone_gz.view_th_ads_yz_ict_all2024_LIST | view_ads_yz_ict_all2024_list |
| 小微场景化手工计列清单 | zone_gz_yz.ads_yz_ict_all_cjhbb2024_sr_LIST | zone_gz.view_th_ads_yz_ict_all_cjhbb2024_sr_LIST | view_ads_yz_ict_all_cjhbb2024_sr_list |
| 存量未托收清单 | zone_gz_yz.ads_yz_clts_change_list_mon | zone_gz.view_th_ads_yz_clts_change_list_mon | view_ads_yz_clts_change_list_mon |
| 安全产品清单 | zone_gz_yz.ADS_YZ_ACCP_NEW_LIST | zone_gz.view_th_ADS_YZ_ACCP_NEW_LIST | view_ads_yz_accp_new_list |
| 家庭地址客户入网价值清单 | zone_gz_yz.ads_yz_yzn_addr_label_setting_list | zone_gz.view_th_ads_yz_yzn_addr_label_setting_list | view_ads_yz_yzn_addr_label_setting_list |
| 大额榜单账单级清单 | zone_gz_yz.ads_ys_bd_bill | zone_gz.view_th_ads_ys_bd_bill | view_ads_ys_bd_bill |
| 拆机登记清单（新） | ads_yz_tb_zsh_cjdj_list | zone_gz.view_th_tb_zsh_cjdj_list | 无 |
| 移动宽带质态监控多维表 | ads_zt_kdx_list | zone_gz_yz.view_th_ads_zt_kdx_list | view_ads_zt_kdx_list |
| 医保竣工清单 | ads_wjbg_list | view_ads_wjbg_list | view_ads_wjbg_list |
| 医保未竣工清单 | ads_yb_wjg_list | view_yb_wjg_list | view_yb_wjg_list |
| 存量专线提（降）值清单 | ads_yz_sx_cltz_gt | view_th_ads_yz_sx_cltz_gt | view_ads_yz_sx_cltz_gt |
| 专线月租表 | ads_yz_sx_yz | 无 | 无 |
| 小翼发展清单 | zone_gz_yz.ads_yz_zqb_xyqg | view_th_ads_yz_zqb_xyqg | view_ads_yz_zqb_xyqg |
| 高阶网关发展清单 | zone_gz_yz.ads_yz_wyh_gjwg_new_list | view_th_ads_yz_wyh_gjwg_new_list | view_ads_yz_wyh_gjwg_new_list |
| 营业厅月度订单受理量清单 | zone_gz_yz.ads_yz_yyt_sl_list | zone_gz.view_th_ads_yz_yyt_sl_list | view_ads_yz_yyt_sl_list |
| 基础业务托收清单 | zone_gz_yz.ads_yz_tb_cl_tuoshou_list | zone_gz.view_th_ads_yz_tb_cl_tuoshou_list | view_ads_yz_tb_cl_tuoshou_list |
| 商客新建档客户清单 | zone_gz_yz.ads_yz_xjd_kh_list | zone_gz.view_th_ads_yz_xjd_kh_list | view_ads_yz_xjd_kh_list |
| 国际漫游数据表 | dws_ctg.dws_mktag_download_share_guoman_label | 无 | 无 |
| 结算账单表 | dws_tpss_jszx.dws_settle_bill | 无 | 无 |
| 移机订单表 | dwd_yz_rpt_comm_ba_subs_move_final | 无 | view_dwd_yz_rpt_comm_ba_subs_move_final |
| 设备资源关系表 | ads_yz_prod_res_inst_rel_final | 无 | 无 |
| 产品关联关系表 | dws_crm_cust.dws_prod_inst_rel_a | 无 | 无 |
| 业务关联关系表 | dws_crm_cust.dws_prod_inst_rel_grp_a | 无 | 无 |
| 终端自注册清单 | summary_ods_day_szx.rpt_terminal_type_new | 无 | 无 |
| 揽装人认领规则表 | ads_yz_sales_grid_rule_list | view_th_ads_yz_sales_grid_rule_list_final | view_ads_yz_sales_grid_rule_list_final |
| 服务当前划小规则表 | dwd_yz_jyfx_serv_grid_final | 无 | 无 |
| 客户联系人关系表 | dws_crm_cust.dws_cust_contact_info_rel | 无 | 无 |
| 联系人信息表 | dws_crm_cust.dws_contacts_info | 无 | 无 |
| 产品实例当前表 | dws_crm_cust.dws_prod_inst | 无 | 无 |
| 服务资源表 | dws_crm_cust.dws_cust_serv_res | 无 | 无 |
| 附属产品配置表 | dwd_dim_all_config | 无 | 无 |
| 产品实例账户关系表 | dws_crm_cust.dws_prod_inst_acct_rel_aap | 无 | 无 |
| 支付方案表 | dws_crm_cust.dws_payment_plan | 无 | 无 |
| 外部账户表 | dws_crm_cust.dws_ext_acct | 无 | 无 |
| 银行表 | dws_crm_cfguse.dws_tb_cm_bank | 无 | 无 |
| 敏感客户黑名单表 | dws_crm_party.dws_special_list_black | 无 | 无 |
| 证件本地表 | dws_crm_cust.dws_party_cert_local | 无 | 无 |
| 附属产品资料表 | summary_ods_day_city.rpt_comm_cm_subserv | 无 | 无 |
| 销售品参数表 | summary_ods_day_city.rpt_comm_cm_msparam | 无 | 无 |
| 特性资料表 | summary_ods_day_city.tb_pre_cm_attr_all | 无 | 无 |
| 附属产品订单表族 | summary_ods_day_city.rpt_comm_ba_sub_prod | 无 | 无 |
| 非费用账目表 | dws_acct.dws_unacct_item | 无 | 无 |
| CRM设备订单关系表 | dws_crm_order.dws_ord_prod_res_inst_rel | 无 | 无 |
| 实收来源汇总表 | zone_gz_yz.dwd_yz_if_real_src_sum_new_final | 无 | 无 |
| 固话通话月表 | summary_ods_month_city.TB_COMM_YWL_GW_mon | 无 | 无 |
| 固话使用记录月表 | summary_ods_month_city.tb_comm_ywl_gw_mon | 无 | 无 |
