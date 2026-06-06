需求原始内容：
XQGZ2025071600439 

关于南沙区港湾街门禁宽带1045线地址匹配的需求。因项目统计需要，请求匹配存量清单地址，要求匹配出7级地址

需求梳理：
根据需求单附件提供的接入号，匹配接入号当前月份的7级地址ID及其地址名称。
要求：
1.先在CDAP导入需求方提供的接入号，表zone_gz_yz_3466798313435136是手动导入的需求单附件，通过附件接入号匹配出接入号的装机标准地址ID，再通过装机标准地址ID匹配出其上级7级地址ID，最后匹配出7级地址ID对应的名称；
2.大宽表dwm_yz_tb_comm_cm_all_final中的装机标准地址serv_addr_id数据类型是varchar(64)，而资源地址表dwd_yz_addr_final的地址字段id和addr_id_7数据类型都是decimal(24,0)，所以写匹配条件要转换一下格式on cast b.serv_addr_id = cast(c.id as varchar(64))，都转成字符格式。注意千万不能写成on cast(b.serv_addr_id as decimal(24,0)) = c.id，因为地址过长会导致HQL里字符格式转数值格式出错，以至于匹配漏数。

输出字段：
需求附件导入的接入号，接入号对应的服务标识，装机标准地址ID,装机标准地址ID对应的7级地址ID，7级地址名称

--通过附件接入号匹配出接入号的装机标准地址ID，再通过号码的装机标准地址ID匹配出其上级7级地址ID，最后匹配出7级地址ID对应的地址名称
drop table ads_yz_XQGZ2025071600439;
create table ads_yz_XQGZ2025071600439 as
select a.index1 acc_nbr,b.serv_id,b.serv_addr_id,c.addr_id_7,d.addr 
from zone_gz_yz_3466798313435136 a
left join dwm_yz_tb_comm_cm_all_final b
on a.index1 = b.acc_nbr and b.par_month_id = 202507
left join dwd_yz_addr_final c
on cast b.serv_addr_id = cast(c.id as varchar(64))
left join dwd_yz_addr_final d
on c.addr_id_7 = d.id and d.grade = 7
;
