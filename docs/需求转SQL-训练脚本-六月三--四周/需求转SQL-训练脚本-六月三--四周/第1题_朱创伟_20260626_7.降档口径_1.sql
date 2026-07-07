需求原始内容：
条件：上个月为单移，本月纳入拆挽场景中的，
责任渠道为营业厅和客服的，营业厅修改为客户主动降档场景，
客服修改为投诉场景.


需求梳理：
经与需求方沟通，
修改降档拆挽口径，对上月为单移号码，本月统计为拆挽场景的，
对责任渠道为营业厅的 修改为用户主动降档
对责任渠道为客服的，修改为投诉场景；

其中单移口径：prod_type = 30 
 AND b.is_rh_ykj=0 then '单移' 


输出字段：
新的降档场景；





-- 打标上月 单移 last_disc_type_dl
set hive.fetch.task.conversion=none;
drop table if exists tmp_yz_xxx_0531f;
create table tmp_yz_xxx_0531f as
select a.*,
case when b.prod_type = 30 AND b.is_rh_ykj=0 then '单移'
	 when b.prod_type = 40 AND b.is_rh_ykj=0 then '单宽'
	 when b.is_rh_ykj=1 then '融合'
	 else '其他' end  as last_disc_type_dl
from ads_yz_jd_list a 
left join 
dwm_yz_tb_comm_cm_all_mon_final b
on a.serv_id = b.serv_id and b.par_month_id='$last_month_id' 
where a.par_month_id = '$month_id' ;


-- 限制上月单移 ，渠道，降档场景，修改为新的降档场景
DROP TABLE IF EXISTS tmp_yz_xxx_0531g;
CREATE TABLE tmp_yz_xxx_0531g AS
SELECT
    a.*,
    CASE
        WHEN a.last_disc_type_dl = '单移'
             AND a.jd_scene_new = '拆挽场景'
             AND a.jd_zr_channel_type = '营业厅'
        THEN '用户主动降档'

        WHEN a.last_disc_type_dl = '单移'
             AND a.jd_scene_new = '拆挽场景'
             AND a.jd_zr_channel_type = '客服'
        THEN '投诉场景'
        ELSE a.jd_scene_new
    END AS jd_scene_new1
FROM tmp_yz_xxx_0531f a;
