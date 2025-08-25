**公共查询类表.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-05 17:48:23
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--码值非分区表  cd_val_dscr
select *
from edw.dwd_code_library   --注意表名和字段都是大写
where
fld_nm = upper('act_typ_cd')   --字段名
--and tbl_nm = UPPER('DWD_BUS_ACT_GL_SRL_DTL_DI')
cd_nm like '%担保人%'
cd_val_dscr like '%一般户%'
;




select * from edw.dwd_code_library where cd_nm like '%限额%' and cd_val in ('K04');
select * from edw.dwd_code_library b where b.fld_nm like upper('city');

select * from edw.dwd_code_library_dd where dt = '@@{yyyyMMdd}' and fld_nm like upper('SUM_ORG_LVL');

select *  from edw.finc_tbdict where dt = '20211008' and key_name like 'pos_enc';


-- 查看表是否入模
select *
from edw.DIM_BUS_COM_TBL_DEP_INF
where src_guid like lower('%CORE_KDPB_XDCKDJ%')  --源表名，不加项目名
and (dst_guid like '%dim%' or dst_guid like '%dwd%' or dst_guid like '%dws%')
;





select *
from edw.dwd_code_library_dd
where dt = '20210701'
--and tbl_nm = upper('core_kdpb_dngjdj')
and tbl_nm = upper('edw.core_kdpa_zhxinx_p')
;




select lgp_id as 法人编号
      ,prm_id as 主键id
      ,cd_eng_cls as 字典种类
      ,cd as 代码
      ,cd_nm as 代码名称
      ,cd_cls_cmt as 字典种类说明
from edw.dim_bus_com_ipcr_code_dic_dd  --个人人行征信报告码值信息
where dt = '20210704'
;

select userid,min(addtime) as min_addtm
from edw.tlsc_sunyardmall_prize_log
where dt >= '20210901' and dt <= '20210930'
group by userid
**客群研究_代码学习.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-20 11:01:50
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

--普惠担保人客群基础信息表
create table if not exists lab_risk_dev.puhui_grnt_cst_info as
select '实验组'         as sample_type
      ,t.客户号    as cst_id
      ,t.客户姓名  as cst_xm
      ,t1.age                           -- '年龄'
      ,case when t1.GDR_CD='1' then '男'
            when t1.GDR_CD='2' then '女'
       else '未知' end as GENDER        -- '性别（1：男，2：女）'
      ,t1.opn_dt                        -- '开户日期'
      ,t1.TL_YEAR                       -- '行龄'
      ,t1.FM_IND                        -- '农户标志'
      ,t1.TOT_IDT_CD                    -- '行业大类代码'
      ,t1.TOT_IDT_NM                    -- '行业大类'
      ,t1.IDT_CD                        -- '行业细类代码'
      ,t1.IDT_NM                        -- '行业细类'
      ,t1.CST_TYPE                      -- '客户分类'
      ,t1.prm_org_id                    -- '管户机构'
      ,t1.fh_org_id                     -- '分行机构号'
      ,t1.fh_org_nm                     -- '分行名称'
      ,t1.zh_org_id                     -- '支行机构号'
      ,t1.zh_org_nm                     -- '支行名称'
      ,t1.td_org_id                     -- '团队机构号'
      ,t1.td_org_nm                     -- '团队名称'
      ,t1.prm_mgr_id                    -- 主管户客户经理工号
      ,t1.empe_nm                       -- 主管户客户经理姓名
      ,t1.empe_sts_cd                   -- 用工状态代码（4）
      ,t1.is_loan                       -- 是否发上过信贷关系
      ,t1.last_apnt_start_dt            -- 最近一笔贷款办理时间
      ,t1.is_mobile                     -- 是否开通手机银行
      ,t1.is_wangyin                    -- 是否开通个人网银
      ,case when t2.客户号 is not null then '1' else '0' end as is_waihu_ok  -- 客服外呼明确同意
  from tlab_dev.tmp_empe_cst t
 inner join ioam_dev.grnt_cst t1 on t.客户号=t1.cst_id
  left join tlab_dev.tmp_grnt_waihu_feedback t2 on t.客户号=t2.客户号 and t2.客户是否同意登记信息='明确同意'

union all
select '对照组'          as sample_type
      ,t.cst_id
      ,t.cst_chn_nm as cst_xm
      ,t1.AGE                           -- '年龄'
      ,case when t1.GDR_CD='1' then '男'
            when t1.GDR_CD='2' then '女'
       else '未知' end as GENDER        -- '性别（1：男，2：女）'
      ,t1.OPN_DT                        -- '开户日期'
      ,t1.TL_YEAR                       -- '行龄'
      ,t1.FM_IND                        -- '农户标志'
      ,t1.TOT_IDT_CD                    -- '行业大类代码'
      ,t1.TOT_IDT_NM                    -- '行业大类'
      ,t1.IDT_CD                        -- '行业细类代码'
      ,t1.IDT_NM                        -- '行业细类'
      ,t1.CST_TYPE                      -- '客户分类'
      ,t1.prm_org_id                    -- '管户机构'
      ,t1.fh_org_id                     -- '分行机构号'
      ,t1.fh_org_nm                     -- '分行名称'
      ,t1.zh_org_id                     -- '支行机构号'
      ,t1.zh_org_nm                     -- '支行名称'
      ,t1.td_org_id                     -- '团队机构号'
      ,t1.td_org_nm                     -- '团队名称'
      ,t1.prm_mgr_id                    -- 主管户客户经理工号
      ,t1.empe_nm                       -- 主管户客户经理姓名
      ,t1.empe_sts_cd                   -- 用工状态代码（4）
      ,t1.is_loan                       -- 是否发上过信贷关系
      ,t1.last_apnt_start_dt            -- 最近一笔贷款办理时间
      ,t1.is_mobile                     -- 是否开通手机银行
      ,t1.is_wangyin                    -- 是否开通个人网银
      ,'0' as is_waihu_ok               -- 客服外呼明确同意
  from tlab_dev.cst_list_1_20210118 t
 inner join ioam_dev.grnt_cst t1 on t.cst_id=t1.cst_id
 where t1.zh_org_nm not in ('上海奉贤支行','温岭大溪支行','温州乐清虹桥小微企业专营支行')
   and t1.zh_org_nm in ('上海闵行支行','温岭箬横支行','温州苍南钱库小微企业专营支行')
 order by rand() limit 1000
 ;


--客户转化明细表
drop table if exists lab_risk_dev.puhui_grnt_cst_trans_list;

create table if not exists lab_risk_dev.puhui_grnt_cst_trans_list
(
   sample_type         string  comment  '样本类型'
  ,cst_id              string  comment  '客户号'
  ,cst_xm              string  comment  '客户姓名'
  ,is_waihu_ok         string  comment  '客服外呼明确同意'
  ,apl_id              string  comment  '申请流水号'
  ,pd_id               string  comment  '产品代码'
  ,pd_nm               string  comment  '产品名称'
  ,apl_hpn_dt          string  comment  '申请发生日期'
  ,apl_mtu_dt          string  comment  '申请到期日期'
  ,busi_ctr_id         string  comment  '合同编号'
  ,ctr_hpn_dt          string  comment  '合同发生日期'
  ,ctr_apnt_start_dt   string  comment  '合同约定开始日期'
  ,ctr_apnt_mtu_dt     string  comment  '合同约定到期日期'
  ,ctr_amt             decimal comment  '合同金额'
  ,ctr_bal             decimal comment  '合同余额'
  ,ctr_intr_rat        decimal comment  '利率'
  ,dbil_id             string  comment  '借据编号'
  ,dbil_dtrb_dt        string  comment  '借据发放日期'
  ,dbil_apnt_mtu_day   string  comment  '借据约定到期日'
  ,dbil_amt            decimal comment  '借据发放金额'
  ,dbil_prcp_bal       decimal comment  '借据本金余额'
  ,dbil_exe_intr_rat   decimal comment  '借据执行利率'
)
comment '客户转化明细表'
;

insert into lab_risk_dev.puhui_grnt_cst_trans_list
select t.sample_type
      ,t.cst_id
      ,t.cst_xm
      ,t.is_waihu_ok
      ,t1.apl_id
      ,t1.pd_id
      ,t4.pd_nm
      ,t1.hpn_dt           as apl_hpn_dt         --申请发生日期
      ,t1.mtu_dt           as apl_mtu_dt         --申请到期日期
      ,t2.busi_ctr_id                            --合同编号
      ,t2.hpn_dt           as ctr_hpn_dt         --合同发生日期
      ,t2.apnt_start_dt    as ctr_apnt_start_dt  --合同约定开始日期
      ,t2.apnt_mtu_dt      as ctr_apnt_mtu_dt    --合同约定到期日期
      ,t2.ctr_amt                                --合同金额
      ,t2.ctr_bal                                --合同余额
      ,t2.intr_rat         as ctr_intr_rat       --利率
      ,t3.dbil_id                                --借据编号
      ,t3.dtrb_dt          as dbil_dtrb_dt       --借据发放日期
      ,t3.apnt_mtu_day     as dbil_apnt_mtu_day  --借据约定到期日
      ,t3.amt              as dbil_amt           --借据发放金额
      ,t3.prcp_bal         as dbil_prcp_bal      --借据本金余额
      ,t3.exe_intr_rat     as dbil_exe_intr_rat  --借据执行利率
  from lab_risk_dev.puhui_grnt_cst_info t
  left join edw.dwd_bus_loan_apl_inf_dd t1 on t.cst_id=t1.cst_id and t1.dt='@@{yyyyMMdd}' and t1.hpn_dt>='20210120'  --信贷业务申请信息表 ，20210120名单下发日期
  left join edw.dim_bus_loan_ctr_inf_dd t2 on t.cst_id=t2.cst_id and t1.apl_id=t2.busi_apl_id and t2.dt='@@{yyyyMMdd}' and t2.hpn_dt>='20210120'  --信贷合同信息表
  left join edw.dws_bus_loan_dbil_inf_dd t3 on t.cst_id=t3.cst_id and t2.busi_ctr_id=t3.bus_ctr_id and t3.dt='@@{yyyyMMdd}' and t3.dtrb_dt>='20210120'  --贷款借据信息汇总
  left join edw.dim_bus_loan_pd_inf_dd t4 on t1.pd_id=t4.pd_cd and t4.dt='@@{yyyyMMdd}'
 ;


--客户转化汇总表
drop table if exists lab_risk_dev.puhui_grnt_cst_tot;

create table if not exists lab_risk_dev.puhui_grnt_cst_tot
(
  sample_type   string  comment  '样本类型'
 ,cst_id        string  comment  '客户号'
 ,cst_xm        string  comment  '客户姓名'
 ,fh_org_nm     string  comment  '分行名称'
 ,zh_org_nm     string  comment  '支行名称'
 ,prm_mgr_id    string  comment  '主管户客户经理工号'
 ,empe_nm       string  comment  '主管户客户经理姓名'
 ,is_waihu_ok   string  comment  '客服外呼明确同意'
 ,is_apl        string  comment  '是否发生申请'
 ,is_ctr        string  comment  '是否发生合同'
 ,is_dbil       string  comment  '是否发生借据'
 ,apl_hpn_dt    string  comment  '申请发生日期'
 ,ctr_hpn_dt    string  comment  '合同发生日期'
 ,dbil_dtrb_dt  string  comment  '借据发生日期'
 ,ctr_amt       decimal comment  '合同金额'
 ,ctr_bal       decimal comment  '合同余额'
)
comment '客户转化汇总表'
;

insert into lab_risk_dev.puhui_grnt_cst_tot
select t.sample_type   --'样本类型'
      ,t.cst_id        --'客户号'
      ,t.cst_xm        --'客户姓名'
      ,t1.fh_org_nm    --分行名称
      ,t1.zh_org_nm    --支行名称
      ,t1.prm_mgr_id   --主管户客户经理工号
      ,t1.empe_nm      --主管户客户经理姓名
      ,t.is_waihu_ok   --'客服外呼明确同意'
      ,case when min(t.apl_hpn_dt) is not null then '1' else '0' end as is_apl     --是否发生申请
      ,case when min(t.ctr_hpn_dt) is not null then '1' else '0' end as is_ctr     --是否发生合同
      ,case when min(t.dbil_dtrb_dt) is not null then '1' else '0' end as is_dbil  --是否发生借据
      ,min(t.apl_hpn_dt)   apl_hpn_dt    --申请发生日期
      ,min(t.ctr_hpn_dt)   ctr_hpn_dt    --合同发生日期
      ,min(t.dbil_dtrb_dt) dbil_dtrb_dt  --借据发生日期
      ,sum(ctr_amt)        ctr_amt       --合同金额
      ,sum(ctr_bal)        ctr_bal       --合同余额
  from lab_risk_dev.puhui_grnt_cst_trans_list t   --客户转化明细
 inner join lab_risk_dev.puhui_grnt_cst_info t1 on t.cst_id=t1.cst_id   --普惠担保人客群基础信息
 group by t.sample_type   --'样本类型'
         ,t.cst_id        --'客户号'
         ,t.cst_xm        --'客户姓名'
         ,t1.fh_org_nm    --分行名称
         ,t1.zh_org_nm    --支行名称
         ,t1.prm_mgr_id   --主管户客户经理工号
         ,t1.empe_nm      --主管户客户经理姓名
         ,t.is_waihu_ok   --'客服外呼明确同意'
;


--汇总表（不分区）
drop table if exists lab_risk_dev.puhui_grnt_smy_nodt;

create table if not exists lab_risk_dev.puhui_grnt_smy_nodt
(
  sample_type  string  comment  '样本类型'
 ,fh_org_nm    string  comment  '分行名称'
 ,zh_org_nm    string  comment  '支行名称'
 ,prm_mgr_id   string  comment  '管户客户经理工号'
 ,empe_nm      string  comment  '管户客户经理名称'
 ,tot_cst_cnt  bigint  comment  '客户数'
 ,apl_cst_cnt  bigint  comment  '申请客户数'
 ,ctr_cst_cnt  bigint  comment  '合同客户数'
 ,dbil_cst_cnt bigint  comment  '借据客户数'
 ,ctr_amt_sum  decimal comment  '合同金额'
 ,ctr_bal_sum  decimal comment  '合同余额'
)
comment '客户转化汇总表(不分区)'
;

insert into lab_risk_dev.puhui_grnt_smy_nodt
select t.sample_type
      ,t.fh_org_nm
      ,t.zh_org_nm
      ,t.prm_mgr_id
      ,t.empe_nm
      ,count(1) tot_cst_cnt
      ,sum(case when t.is_apl='1' then 1 else 0 end)  as apl_cst_cnt
      ,sum(case when t.is_ctr='1' then 1 else 0 end)  as ctr_cst_cnt
      ,sum(case when t.is_dbil='1' then 1 else 0 end) as dbil_cst_cnt
      ,sum(ctr_amt)                                   as ctr_amt_sum
      ,sum(ctr_bal)                                   as ctr_bal_sum
  from lab_risk_dev.puhui_grnt_cst_tot t
 group by t.sample_type
         ,t.fh_org_nm
         ,t.zh_org_nm
         ,t.prm_mgr_id
         ,t.empe_nm
 ;


--汇总分区表
create table if not exists lab_risk_dev.puhui_grnt_smy
(
  sample_type  string  comment  '样本类型'
 ,fh_org_nm    string  comment  '分行名称'
 ,zh_org_nm    string  comment  '支行名称'
 ,prm_mgr_id   string  comment  '管户客户经理工号'
 ,empe_nm      string  comment  '管户客户经理名称'
 ,tot_cst_cnt  bigint  comment  '客户数'
 ,apl_cst_cnt  bigint  comment  '申请客户数'
 ,ctr_cst_cnt  bigint  comment  '合同客户数'
 ,dbil_cst_cnt bigint  comment  '借据客户数'
 ,ctr_amt_sum  decimal comment  '合同金额'
 ,ctr_bal_sum  decimal comment  '合同余额'
)
comment '普惠担保人客群转化汇总表'
partitioned by
(
dt string comment '日期分区'
)
;

--重跑机制
alter table lab_risk_dev.puhui_grnt_smy drop if exists partition (dt='@@{yyyyMMdd}');

insert into lab_risk_dev.puhui_grnt_smy partition (dt='@@{yyyyMMdd}')
select t.sample_type
      ,t.fh_org_nm
      ,t.zh_org_nm
      ,t.prm_mgr_id
      ,t.empe_nm
      ,count(1) tot_cst_cnt
      ,sum(case when t.is_apl='1' then 1 else 0 end)  as apl_cst_cnt
      ,sum(case when t.is_ctr='1' then 1 else 0 end)  as ctr_cst_cnt
      ,sum(case when t.is_dbil='1' then 1 else 0 end) as dbil_cst_cnt
      ,sum(ctr_amt)                                   as ctr_amt_sum
      ,sum(ctr_bal)                                   as ctr_bal_sum
  from lab_risk_dev.puhui_grnt_cst_tot t
 group by t.sample_type
         ,t.fh_org_nm
         ,t.zh_org_nm
         ,t.prm_mgr_id
         ,t.empe_nm
 ;


--每天转化情况
drop table if exists lab_risk_dev.puhui_grnt_initdate_info;

create table if not exists lab_risk_dev.puhui_grnt_initdate_info
(
  init_date    string  comment  '日期'
 ,sample_type  string  comment  '样本类型'
 ,fh_org_nm    string  comment  '分行名称'
 ,zh_org_nm    string  comment  '支行名称'
 ,prm_mgr_id   string  comment  '管户客户经理工号'
 ,empe_nm      string  comment  '管户客户经理名称'
 ,tot_cst_cnt  bigint  comment  '客户数'
 ,apl_cst_cnt  bigint  comment  '申请客户数'
 ,ctr_cst_cnt  bigint  comment  '合同客户数'
 ,dbil_cst_cnt bigint  comment  '借据客户数'
 ,ctr_amt_sum  decimal comment  '合同金额'
 ,ctr_bal_sum  decimal comment  '合同余额'
)
comment '普惠担保人客群每日转化情况'
;

insert into lab_risk_dev.puhui_grnt_initdate_info
select dt            as init_date
      ,sample_type
      ,fh_org_nm
      ,zh_org_nm
      ,prm_mgr_id
      ,empe_nm
      ,tot_cst_cnt
      ,apl_cst_cnt
      ,ctr_cst_cnt
      ,dbil_cst_cnt
      ,ctr_amt_sum
      ,ctr_bal_sum
  from lab_risk_dev.puhui_grnt_smy
 where dt <= '@@{yyyyMMdd}'

union all
select dt            as init_date
      ,sample_type
      ,'合计'
      ,'合计'
      ,'合计'
      ,'合计'
      ,sum(tot_cst_cnt)   tot_cst_cnt
      ,sum(apl_cst_cnt)   apl_cst_cnt
      ,sum(ctr_cst_cnt)   ctr_cst_cnt
      ,sum(dbil_cst_cnt)  dbil_cst_cnt
      ,sum(ctr_amt_sum)   ctr_amt_sum
      ,sum(ctr_bal_sum)   ctr_bal_sum
  from lab_risk_dev.puhui_grnt_smy
 where dt <= '@@{yyyyMMdd}'
 group by dt
         ,sample_type
;

----关联日期维度表，获取每日转化情况
drop table if exists lab_risk_dev.puhui_grnt_tran_info;

create table if not exists lab_risk_dev.puhui_grnt_tran_info
(
  init_date    string  comment  '日期'
 ,sample_type  string  comment  '样本类型'
 ,fh_org_nm    string  comment  '分行名称'
 ,zh_org_nm    string  comment  '支行名称'
 ,prm_mgr_id   string  comment  '管户客户经理工号'
 ,empe_nm      string  comment  '管户客户经理名称'
 ,tot_cst_cnt  bigint  comment  '客户数'
 ,apl_cst_cnt  bigint  comment  '申请客户数'
 ,ctr_cst_cnt  bigint  comment  '合同客户数'
 ,dbil_cst_cnt bigint  comment  '借据客户数'
 ,ctr_amt_sum  decimal comment  '合同金额'
 ,ctr_bal_sum  decimal comment  '合同余额'
)
;

insert into lab_risk_dev.puhui_grnt_tran_info
select t.init_date
      ,t1.sample_type
      ,t1.fh_org_nm
      ,t1.zh_org_nm
      ,t1.prm_mgr_id
      ,t1.empe_nm
      ,count(distinct t1.cst_id) as tot_cst_cnt
      ,count(distinct case when t1.apl_hpn_dt<=t.init_date then t1.cst_id end)   as apl_cst_cnt
      ,count(distinct case when t1.ctr_hpn_dt<=t.init_date then t1.cst_id end)   as ctr_cst_cnt
      ,count(distinct case when t1.dbil_dtrb_dt<=t.init_date then t1.cst_id end) as dbil_cst_cnt
      ,sum(distinct case when t1.ctr_hpn_dt<=t.init_date then t1.ctr_amt end)    as ctr_amt_sum
      ,sum(distinct case when t1.ctr_hpn_dt<=t.init_date then t1.ctr_bal end)    as ctr_bal_sum
  from (select dt  as init_date
              ,'1' as key_clo
          from edw.dim_bus_com_date_st
         where dt>='20210120'
           and dt<='@@{yyyyMMdd}'
       ) t
  left join (select *
                   ,'1' as key_clo
               from lab_risk_dev.puhui_grnt_cst_tot
            ) t1 on t.key_clo=t1.key_clo
 group by t.init_date
         ,t1.sample_type
         ,t1.fh_org_nm
         ,t1.zh_org_nm
         ,t1.prm_mgr_id
         ,t1.empe_nm
 ;
**客群研究_存款客群口径.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-21 11:04:38
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
----------------------------  20220221 --------------------------------------
select dep_act_id,cst_act_id,cst_id,act_ctg_cd_1
from edw.dim_bus_dep_act_inf_dd a
where dt = '20220220'
and cst_id = '0000001458'
;


----------------------------  20220217 --------------------------------------
select a.cst_act_id  --客户账号
      ,a.cst_id
      ,a.act_ctg_cd_1
      ,row_number()over(partition by a.cst_id order by a.cst_act_id,a.act_ctg_cd_1) as rn
from edw.dim_bus_dep_act_inf_dd a
left join EDW.DWS_BUS_DEP_ACT_INF_DD b on a.dep_act_id = b.dep_act_id and b.dt = a.dt
where a.dt = '20220216'
and b.CST_TP = '2' --对公
;




-- 存款客户来源
lancreny --揽存人员
select *
from edw.core_kdpb_jlzhgl
where dt = '@@{yyyyMMdd}'
;

SELECT distinct txt_code,smr_dscr FROM edw.dwd_bus_dep_bal_chg_dtl_di WHERE DT >= '@@{yyyyMMdd - 365d}' AND DT <= '@@{yyyyMMdd}';




-- 对公客户类型
SELECT DISTINCT T1.CST_ID      --客户号
      ,T2.ORG_ORG_TYP_CD   --组织机构类型代码
      ,CODE1.CD_VAL_DSCR ORG_ORG_TYP  --组织机构类型
FROM EDW.DWS_BUS_DEP_ACT_INF_DD  T1 --存款账户信息汇总
LEFT JOIN EDW.DIM_CST_ENTP_BAS_INF_DD T2 ON T1.CST_ID = T2.CST_ID AND T2.DT = T1.DT
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE1 ON T2.ORG_ORG_TYP_CD = CODE1.CD_VAL AND CODE1.FLD_NM = 'ORG_ORG_TYP_CD'
WHERE T1.DT = '@@{yyyyMMdd}'
AND T1.CST_TP = '2'   --1对私，2对公
;

SELECT
      T2.ORG_ORG_TYP_CD   --组织机构类型代码
      ,CODE1.CD_VAL_DSCR ORG_ORG_TYP  --组织机构类型
FROM EDW.DWS_BUS_DEP_ACT_INF_DD  T1 --存款账户信息汇总
LEFT JOIN EDW.DIM_CST_ENTP_BAS_INF_DD T2 ON T1.CST_ID = T2.CST_ID AND T2.DT = T1.DT
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE1 ON T2.ORG_ORG_TYP_CD = CODE1.CD_VAL AND CODE1.FLD_NM = 'ORG_ORG_TYP_CD'
WHERE T1.DT = '@@{yyyyMMdd}'
AND T1.CST_TP = '2'   --1对私，2对公
GROUP BY T2.ORG_ORG_TYP_CD,CODE1.CD_VAL_DSCR
;



------------------------------  20220216 -------------------------------------
-- 1.当月定期待续存客户
-- 如何判断账户是定期账户？
SELECT LBL_PROD_TYP_CD
FROM edw.dws_bus_dep_act_inf_dd
WHERE DT = '@@{yyyyMMdd}'
GROUP BY LBL_PROD_TYP_CD
;

SELECT A.dep_cls_cd,B.cd_val_dscr
FROM edw.dws_bus_dep_act_inf_dd a
LEFT JOIN edw.dwd_code_library B ON A.dep_cls_cd = B.cd_val AND B.cd_nm = '存款种类' AND B.fld_nm = upper('dep_cls_cd')
WHERE A.DT = '@@{yyyyMMdd}'
AND A.LBL_PROD_TYP_CD = '1'  --定期
GROUP BY A.dep_cls_cd,B.cd_val_dscr
;


SELECT
FROM edw.dim_bus_dep_act_inf_dd
WHERE DT = '@@{yyyyMMdd}'
WHERE

-- 2.当月定期到期金额（含自动转存/不含自动转存）
edw.dwd_bus_dep_mtu_auto_rdps_reg_dd --定期到期自动转存登记簿


-- 3.是否质押、质押金额
-- 是否需要添加条件：质押到期日>统计日
select *
from (
SELECT a.cst_act_id
      ,a.cst_id
      ,case when b.cst_act_id is null then 0 else 1 end as is_impn  --账户是否质押
      ,case when b.cst_act_id is null then 0 else b.impn_amt end as impn_amt  --质押金额
      ,case when b.cst_act_id is null then '18991231' else b.impn_mtu_dt end as impn_mtu_dt --质押到期日
from EDW.DWS_BUS_DEP_ACT_INF_DD a
left join edw.dwd_bus_grnt_act_impn_dtl_dd b on a.cst_act_id = b.cst_act_id and b.dt = a.dt and b.impn_act_typ_cd = '1'  --1定期账户,2理财账户
where a.dt = '@@{yyyyMMdd}'
) aa
where aa.is_impn = 1
;


-- 4.进账/出账交易次数
-- 当月进账次数
--
select dep_act_id  --存款账号
      ,cst_act_id
      ,crd_and_dbt_ind  --借贷标志:C获得，D使用
      ,trx_amt --交易金额
      ,txt_code --摘要代码
      ,smr_dscr --摘要描述
      ,rvs_ind  --冲正标志
      ,rvsd_ind --被冲正标志
      ,cmt      --备注
from edw.dws_bus_dep_bal_chg_dtl_di
where  dt >= concat(substr(to_char(to_date('@@{yyyyMMdd}','yyyyMMdd'),'yyyyMMdd'),1,6),'01') and dt <= '@@{yyyyMMdd}'  --取当年日期
and
order by dep_act_id,dt
;


select dep_act_id  --存款账号
      ,cst_act_id
      ,crd_and_dbt_ind  --借贷标志:C获得，D使用
      ,trx_amt --交易金额
      ,txt_code --摘要代码
      ,smr_dscr --摘要描述
      ,rvs_ind  --冲正标志
      ,rvsd_ind --被冲正标志
      ,cmt      --备注
from edw.dws_bus_dep_bal_chg_dtl_di
where  dt >= concat(substr(to_char(to_date('@@{yyyyMMdd}','yyyyMMdd'),'yyyyMMdd'),1,6),'01') and dt <= '@@{yyyyMMdd}'  --取当年日期
and cst_act_id = '6221410000900890'
order by dep_act_id,dt
;

-- 看看入息、付 息、结息是什么
select dep_act_id  --存款账号
      ,cst_act_id
      ,crd_and_dbt_ind  --借贷标志:C获得，D使用
      ,trx_amt --交易金额
      ,txt_code --摘要代码
      ,smr_dscr --摘要描述
      ,rvs_ind  --冲正标志
      ,rvsd_ind --被冲正标志
      ,cmt      --备注
      ,dt
from edw.dws_bus_dep_bal_chg_dtl_di
where  dt >= '20200101' and dt <= '20220201'
--and cst_act_id in ('31010020204000023404','31010020201000022089','31010020201000019416')
and (smr_dscr = '入息' or smr_dscr = '付息' or smr_dscr = '结息')
order by cst_act_id,dep_act_id,dt
;
2988101201020010365 既有结息也有付息，





select crd_and_dbt_ind,txt_code,smr_dscr
from edw.dws_bus_dep_bal_chg_dtl_di
where dt >= concat(substr(to_char(to_date('@@{yyyyMMdd}','yyyyMMdd'),'yyyyMMdd'),1,6),'01') and dt <= '@@{yyyyMMdd}'
group by crd_and_dbt_ind,txt_code,smr_dscr
;



------------------------------  20220214 -------------------------------------
-- 1.实际同一主体客户、同一风险控制号下客户
-- 关联关系类型
SELECT A.REL_TYP_CD
      ,B.CD_VAL_DSCR
FROM EDW.DIM_CST_REL_INF_DD A
LEFT JOIN EDW.DWD_CODE_LIBRARY B ON A.REL_TYP_CD = B.CD_VAL AND B.CD_NM LIKE '%关联关系%' AND B.TBL_NM = 'DIM_CST_REL_INF_DD'
WHERE A.DT = '@@{yyyyMMdd}'
GROUP BY A.REL_TYP_CD,B.CD_VAL_DSCR
;

-- 客户关联关系类型
SELECT DISTINCT A.REL_TYP_CD,A.REL_TYP
FROM (
SELECT T1.CST_ID
      ,T2.REL_CST_ID    --关联客户号
      ,T1.CST_ACT_ID    --客户账号
      ,T2.REL_TYP_CD   --关联关系代码
      ,CODE1.CD_VAL_DSCR REL_TYP --关联关系
      ,T1.ACT_STS_CD     --账户状态代码
      ,CODE2.CD_VAL_DSCR ACT_STS --账户状态
FROM EDW.DIM_BUS_DEP_ACT_INF_DD T1
LEFT JOIN EDW.DIM_CST_REL_INF_DD T2 ON T2.CST_ID = T1.CST_ID AND T2.DT = T1.DT
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE1 ON T2.REL_TYP_CD = CODE1.CD_VAL AND CODE1.CD_NM LIKE '%关联关系%' AND CODE1.TBL_NM = 'DIM_CST_REL_INF_DD'
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE2 ON T1.ACT_STS_CD = CODE2.CD_VAL AND CODE2.CD_NM LIKE '%账户状态%' AND CODE2.TBL_NM = 'DIM_BUS_DEP_ACT_INF_DD'
WHERE T1.DT = '@@{yyyyMMdd}'
) A
;



-- 同一风险控制号客户
SELECT A.CST_ID
      ,A.sam_rsk_ctrl_id  --同一风险控制号
      ,B.CST_ID AS SAM_RSK_CST_ID
FROM edw.dws_cst_bas_inf_dd A
LEFT JOIN edw.dws_cst_bas_inf_dd B ON A.sam_rsk_ctrl_id = B.sam_rsk_ctrl_id AND A.CST_ID <> B.CST_ID AND B.DT = A.DT
WHERE A.DT = '@@{yyyyMMdd}'
;



SELECT LENGTH(CST_ID),LENGTH(REL_CST_ID) --10，20
FROM EDW.DIM_CST_REL_INF_DD
WHERE DT = '@@{yyyyMMdd}'
GROUP BY LENGTH(CST_ID),LENGTH(REL_CST_ID)
;

-- 存款账户信息表中，客户号的长度有5,6,7,10四种，这四种各是什么？
-- 客户关联关系形象表中，客户号的长度只有10,20，各是什么？存款账户信息表中客户号长度为5,6,7时，就肯定没有关联客户吗？
SELECT LENGTH(CST_ID)  -- 5，6，7，10
FROM EDW.DIM_BUS_DEP_ACT_INF_DD
WHERE DT = '@@{yyyyMMdd}'
GROUP BY LENGTH(CST_ID)
;



-- 基础指标
SELECT DISTINCT T1.DEP_ACT_ID  --存款账号
      ,T1.CST_ACT_ID  --客户账号
      ,T1.CST_ID      --客户账号
      ,T1.DEP_TRM     --存期
      ,T1.OPN_DT      --开户日期
      ,DATEDIFF(TO_DATE('@@{yyyyMMdd}','yyyyMMdd'),TO_DATE(T1.OPN_DT,'yyyyMMdd'),'DD') AS OPN_DAYS  --开户时长
      ,T1.GL_BAL      --账户总账余额
      ,T1.PROD_ID     --存款产品代码
      ,CODE1.CD_VAL_DSCR PROD  --存款款产品
      ,T1.LBL_PROD_TYP_CD      --存款产品类型代码   --码值表没有
      ,T1.DEP_CLS_CD           --存款种类
      ,CODE2.CD_VAL_DSCR DEP_CLS  --存款种类
      ,T1.ACT_STS_CD              --存款账户状态代码
      ,CODE3.CD_VAL_DSCR ACT_STS  --存款账户状态
      ,T1.OPN_CHNL_CD             --开户渠道
      ,CODE4.CD_VAL_DSCR OPN_CHNL --开户渠道
      ,T1.OPN_AMT                 --开户金额
      ,CASE WHEN T2.ZHANGHAO IS NULL THEN '0' ELSE '1' END AS IS_PAY_WAGES  --是否代发工资客户：1是0否
FROM EDW.DWS_BUS_DEP_ACT_INF_DD  T1 --存款账户信息汇总
LEFT JOIN EDW.CORE_KDPL_ZHMINX T2 ON T1.DEP_ACT_ID = T2.ZHANGHAO AND T1.CST_ACT_ID = T2.KEHUZHAO AND T2.DT >= '@@{yyyyMMdd - 365d}' AND T2.DT <= '@@{yyyyMMdd}' AND T2.ZHAIYODM = 'IB0047'  --摘要代码
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE1 ON T1.PROD_ID = CODE1.CD_VAL AND CODE1.CD_NM LIKE '%产品编号%'
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE2 ON T1.DEP_CLS_CD = CODE2.CD_VAL AND CODE2.CD_NM LIKE '存款种类代码'
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE3 ON T1.ACT_STS_CD = CODE3.CD_VAL AND CODE3.CD_NM LIKE '%存款账户%'
LEFT JOIN EDW.DWD_CODE_LIBRARY CODE4 ON T1.OPN_CHNL_CD = CODE4.CD_VAL AND CODE4.FLD_NM = 'OPN_CHNL_CD'
WHERE T1.DT = '@@{yyyyMMdd}'
;





-- 交易渠道、交易日期
-- 冲正标志、被冲正标志是否需要筛选
-- 被冲正标志中0,1分别代表什么意思
-- 付息交易是否删掉
SELECT A.DEP_ACT_ID  --存款账号
      ,A.CST_ACT_ID  --客户账号
      ,A.TRX_DT
      ,A.TRX_TM
      ,CONCAT(TRX_DT,TRX_TM) TRX_TIME
      ,A.CRD_AND_DBT_IND  --借贷标志
      ,A.TRX_CHNL_CD      --交易渠道代码
      ,B.CD_VAL_DSCR TRX_CHNL --交易渠道
      ,A.TRX_AMT   --交易金额
      ,A.txt_code  --摘要代码  --DP1000是付息
      ,A.smr_dscr  --摘要描述
FROM EDW.DWS_BUS_DEP_BAL_CHG_DTL_DI A
LEFT JOIN EDW.DWD_CODE_LIBRARY B ON B.CD_VAL = A.TRX_CHNL_CD AND B.FLD_NM = 'TRX_CHNL_CD' AND B.CD_NM = '交易渠道代码' AND B.TBL_NM = UPPER('dwd_bus_act_gl_srl_dtl_di')
WHERE A.DT <= '@@{yyyyMMdd}' AND A.DT >= '@@{yyyyMMdd - 10d}'
AND A.RVS_IND = '0'  --0正常，1冲正，2撤销    --RVSD_IND没有码值
;







-- 代发工资客户
SELECT T2.CST_ID
FROM EDW.CORE_KDPL_ZHMINX T1
INNER JOIN EDW.DWS_BUS_DEP_ACT_INF_DD T2 ON T2.DEP_ACT_ID = T1.ZHANGHAO AND T2.CST_ACT_ID = T1.KEHUZHAO AND T2.DT = '@@{yyyyMMdd}'
WHERE T1.DT >= '@@{yyyyMMdd - 365d}' AND T1.DT <= '@@{yyyyMMdd}'
AND T1.ZHAIYODM = 'IB0047'  --摘要代码
;


SELECT distinct zhaiyodm,zhaiyoms FROM EDW.CORE_KDPL_ZHMINX WHERE DT >= '@@{yyyyMMdd - 365d}' AND DT <= '@@{yyyyMMdd}' --AND (zhaiyoms LIKE '%代扣%' or zhaiyoms LIKE '%代缴%' or zhaiyoms LIKE '%代收%') ;
SELECT distinct zhaiyodm,zhaiyoms FROM EDW.CORE_KDPL_ZHMINX WHERE DT >= '@@{yyyyMMdd - 365d}' AND DT <= '@@{yyyyMMdd}' AND zhaiyoms LIKE '%代%';



-- 对公客户类型
SELECT idt_cd
FROM edw.dim_cst_bas_inf_dd
WHERE DT = '20220214'
GROUP BY idt_cd
;

SELECT geb_industryconame
--geb_enttype
FROM edw.outd_gs_entinfo_basic
WHERE DT = '20220214'
GROUP BY
--geb_enttype
geb_industryconame
;



-- 存款余额/月日均
SELECT dep_act_id  --存款账号
      ,gl_bal      --存款余额
      ,mon_acm_gl_bal_acml  --月累计总账余额积数
      ,mon_acm_gl_bal_acml / int(substr(dt,7,2))  --存款月日均
FROM edw.dws_bus_dep_act_acm_inf_dd
WHERE DT = '@@{yyyyMMdd}'
;


-- 存款FTP
ADM_PUB.ADM_CSM_CBUS_FTP_INF_DD --此表中有FTP利润

SELECT CIF_KEY CST_ID
      ,ftp_int_year_ajust  --本年FTP利息累计（调整后
      ,ftp_int_quar_ajust  --本季FTP利息累计（调整后）
      ,ftp_int_month_ajust --本月FTP利息累计（调整后）
FROM app_iftp.iftp_tpdm_rst_ftp
WHERE DT = '@@{yyyyMMdd}'
AND SUBSTR(CORE_PRODUCT_ID, 1, 4) = '8201'  --筛选存款
GROUP BY CIF_KEY
;



-------------------------------- 20220209 -----------------------------------------
-- 1. 存款产品有多少种
SELECT A.prod_id
      ,B.cd_val_dscr
FROM edw.dim_bus_dep_act_inf_dd A
LEFT JOIN edw.dwd_code_library B
ON B.cd_val = A.prod_id AND B.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
WHERE A.DT = '20220208'
GROUP BY A.prod_id,B.cd_val_dscr
;

/*
--定期存款产品码
     '00201020100' --个人定期
     ,'00202020100' --单位定期
     ,'00201020105' --新成长乐

*/

-- 2. 余额科目编号
-- 关联不上，没有码值
SELECT A.bal_itm_id
      ,B.cd_val_dscr
FROM edw.dim_bus_dep_act_inf_dd A
LEFT JOIN edw.dwd_code_library B
ON B.cd_val = A.bal_itm_id AND B.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
WHERE A.DT = '20220208'
GROUP BY A.bal_itm_id,B.cd_val_dscr
;


-- 3. 存款客户管户与客户主管户信息表中的主管客户经理工号是否一致
-- 存款客户管户
SELECT A.cst_act_id
      ,B.cst_id
      ,A.mgr_id	 --管护人编号
      ,ROW_NUMBER()OVER(PARTITION BY B.cst_id ORDER BY A.mgr_id) AS ROW_NO
FROM edw.dwd_bus_dep_cst_act_mgr_inf_dd  A --客户存款账户管护信息
LEFT JOIN edw.dim_bus_dep_cst_act_inf_dd B ON A.cst_act_id = B.cst_act_id AND B.DT = A.DT
WHERE A.DT = '20220208'
AND A.frs_ctc_ind = '1'
;

-- 客户主管户信息
SELECT cst_id
      ,prm_mgr_id
FROM edw.dws_cst_mng_prm_inf_dd  --客户主管护信息
WHERE DT = '20220208'
;


-- 代发工资户
-- 筛选出202006近半年内在我行有代发工资的客户
CREATE TABLE ioam_dev.TMP_DAIFA_20201231 AS
SELECT DISTINCT T2.CST_ID
  FROM EDW.CORE_KDPL_ZHMINX T1
 INNER JOIN EDW.DWS_BUS_DEP_ACT_INF_DD T2 ON  T2.DEP_ACT_ID = T1.ZHANGHAO     AND T2.CST_ACT_ID = T1.KEHUZHAO AND T2.DT = '20201130'
 WHERE T1.DT >= '20200601'
      AND T1.DT <= '20201231'
      AND T1.ZHAIYODM = 'IB0047'
;




---------------------------------20220121 -------------------------------------
-- 同一账户不同管户问题
DROP TABLE IF EXISTS lab_bigdata_dev.xt_024618_act_01;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.xt_024618_act_01 AS
SELECT
      a.dep_act_id    --AS 存款账号
      ,a.cst_act_id    --AS 客户账号
      ,a.cst_id        --AS 客户号
      ,a.act_afl_org  --AS 账户所属机构
      ,a.mgr_id        --AS 管护人编号
      ,d.brc_org_id    --AS 分行层级机构编号
      ,d.brc_org_nm    --AS 分行层级机构名称
      ,d.sbr_org_id    --AS 支行层级机构编号
      ,d.sbr_org_nm    --AS 支行层级机构名称
      ,d.tem_org_id    --AS 团队层级机构编号
      ,d.tem_org_nm    --AS 团队层级机构名称
      ,a.mgr_rto       --AS 管护比例
      --,a.gl_bal AS 总账余额
      ,CASE WHEN a.ccy_cd = '156' THEN a.gl_bal ELSE a.gl_bal*code2.avg_prc END AS amt
      --,a.ccy_cd AS 货币代码
FROM edw.dws_bus_dep_act_mgr_inf_dd a
LEFT JOIN edw.dim_bus_dep_act_inf_dd b ON b.dep_act_id = a.dep_act_id AND b.dt = a.dt
LEFT JOIN edw.dws_hr_empe_inf_dd c ON c.empe_id = a.mgr_id AND c.dt = a.dt
LEFT JOIN edw.dim_hr_org_mng_org_tree_dd d ON d.org_id = c.org_id AND d.dt = a.dt
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = b.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
LEFT JOIN edw.dim_bus_com_exr_inf_dd code2 ON a.ccy_cd = code2.ccy_cd AND code2.dt = a.dt
WHERE a.dt = '@@{yyyyMMdd}'
AND code1.cd_val_dscr = '正常'  --筛选账户状态为正常
AND a.mgr_id NOT LIKE 'X%'
UNION ALL
SELECT
      a.dep_act_id    --AS 存款账号
      ,a.cst_act_id    --AS 客户账号
      ,a.cst_id        --AS 客户号
      ,a.act_afl_org  --AS 账户所属机构
      ,a.mgr_id        --AS 管护人编号
      ,d.brc_org_id    --AS 分行层级机构编号
      ,d.brc_org_nm    --AS 分行层级机构名称
      ,d.sbr_org_id    --AS 支行层级机构编号
      ,d.sbr_org_nm    --AS 支行层级机构名称
      ,d.tem_org_id    --AS 团队层级机构编号
      ,d.tem_org_nm    --AS 团队层级机构名称
      ,a.mgr_rto       --AS 管护比例
      --,a.gl_bal AS 总账余额
      ,CASE WHEN a.ccy_cd = '156' THEN a.gl_bal ELSE a.gl_bal*code2.avg_prc END AS amt
      --,a.ccy_cd AS 货币代码
FROM edw.dws_bus_dep_act_mgr_inf_dd a
LEFT JOIN edw.dim_bus_dep_act_inf_dd b ON b.dep_act_id = a.dep_act_id AND b.dt = a.dt
LEFT JOIN edw.dws_hr_empe_inf_dd c ON c.empe_id = a.mgr_id AND c.dt = a.dt
LEFT JOIN edw.dim_hr_org_mng_org_tree_dd d ON d.org_id = SUBSTR(a.mgr_id,2,9) AND d.dt = a.dt
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = b.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
LEFT JOIN edw.dim_bus_com_exr_inf_dd code2 ON a.ccy_cd = code2.ccy_cd AND code2.dt = a.dt
WHERE a.dt = '@@{yyyyMMdd}'
AND code1.cd_val_dscr = '正常'  --筛选账户状态为正常
AND a.mgr_id LIKE 'X%'
;


drop table if exists lab_bigdata_dev.xt_024618_act_02;
create table if not exists lab_bigdata_dev.xt_024618_act_02 as
select cst_act_id --客户账号
      ,act_afl_org --账户所属机构
      ,brc_org_id    --AS 分行层级机构编号
      ,brc_org_nm    --AS 分行层级机构名称
      ,sbr_org_id    --AS 支行层级机构编号
      ,sbr_org_nm    --AS 支行层级机构名称
      ,tem_org_id    --AS 团队层级机构编号
      ,tem_org_nm    --AS 团队层级机构名称
      ,mgr_rto       --AS 管护比例
      ,dense_rank()over(partition by cst_act_id order by brc_org_id) as rn1  --同账号不同分行
      ,dense_rank()over(partition by cst_act_id order by sbr_org_id) as rn2  --同账号不同支行
      ,dense_rank()over(partition by cst_act_id order by tem_org_id) as rn3  --同账号不同团队
from lab_bigdata_dev.xt_024618_act_01
where mgr_rto <> 1
;
-- 账户所属机构是什么层级的：支行层级
select distinct act_afl_org from lab_bigdata_dev.xt_024618_act_01;
-- 管户比例小于1时，账户所属机构是不是不唯一：不唯一
select *
from lab_bigdata_dev.xt_024618_act_01
where cst_act_id in (
select cst_act_id   --管户比例小于1时，账户所属机构不唯一的账号
from (
select cst_act_id
      ,act_afl_org
      ,dense_rank()over(partition by cst_act_id order by act_afl_org) as rn
from lab_bigdata_dev.xt_024618_act_01
where mgr_rto <> 1
) a
where a.rn > 1
)
order by dep_act_id,cst_act_id
;





-- 管户比例=1时，账户所属机构是否唯一：
select *
from lab_bigdata_dev.xt_024618_act_01
where cst_act_id in (
select cst_act_id   --管户比例=1时，账户所属机构不唯一的账号
from (
select cst_act_id
      ,act_afl_org
      ,dense_rank()over(partition by cst_act_id order by act_afl_org) as rn
from lab_bigdata_dev.xt_024618_act_01
where mgr_rto = 1
) a
where a.rn > 1
)
order by dep_act_id,cst_act_id
;


select cst_act_id,act_afl_org, mgr_rto from lab_bigdata_dev.xt_024618_act_01 order by cst_act_id;


select cst_act_id
      ,mgr_id
      ,mgr_rto
      ,dense_rank()over(partition by cst_act_id order by mgr_id)
from edw.dwd_bus_dep_cst_act_mgr_inf_dd  --客户存款账户管护信息
where dt = '20220120'
order by cst_act_id
;
**客群研究_存款生命周期指标开发.sql
-- 加工各个存款产品类型
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CST_LIFE_CYC_DEP_BAS_INF;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.CST_LIFE_CYC_DEP_BAS_INF AS
SELECT T1.DEP_ACT_ID
      ,T1.CST_ACT_ID
      ,T1.CST_ID
      ,T1.DEP_TRM     --存期
      ,T1.OPN_DT      --开户日期
      ,DATEDIFF(TO_DATE('@@{yyyyMMdd}','yyyyMMdd'),TO_DATE(T1.OPN_DT,'yyyyMMdd'),'DD') AS OPN_DAYS  --开户时长
      ,T1.GL_BAL      --账户总账余额
      ,T1.PROD_ID     --存款产品代码
      ,T1.LBL_PROD_TYP_CD      --存款产品类型代码   --码值表没有
      ,T1.DEP_CLS_CD           --存款种类
      ,T1.OPN_CHNL_CD             --开户渠道
      ,T1.OPN_AMT                 --开户金额
      ,CASE WHEN T2.CST_ACT_ID IS NOT NULL THEN '1' ELSE '0' END AS IS_RES_DEP  --是否资源性存款账号：1是0否
      ,CASE WHEN T2.CST_ACT_ID IS NULL AND T3.DEP_ACT_ID IS NOT NULL THEN '1' ELSE '0' END AS IS_AGREE_DEP  --是否协定存款账号：1是0否
      ,CASE WHEN T2.CST_ACT_ID IS NULL AND T3.DEP_ACT_ID IS NULL AND SUBSTR(T1.BAL_ITM_ID,1,4) IN ('2001','2003','2007') THEN '1' ELSE '0' END AS IS_CURRENT_DEP  --是否活期存款账户：1是0否
      ,CASE WHEN T2.CST_ACT_ID IS NULL AND T1.PROD_ID IN ('00201030600','00202030100') THEN '1' ELSE '0' END AS IS_CALL_DEP  --是否通知存款账户：1是0否
      ,CASE WHEN T2.CST_ACT_ID IS NULL AND T1.PROD_ID IN ( '00201030304' --泰隆一本通
                                                           ,'00201030303' --新泰隆一本通
                                                           ,'00201030401' --财富宝
                                                           ,'00201030402' --嘉年华
                                                           ,'00201030502' --成长乐
                                                           ,'00201030501' --长寿乐
                                                           ,'00202030200' --泰隆一户通
                                                           ,'00201030305' --聚财一本通
                                                           ,'00201030306' --零活通
                                                           ,'00201030307' --零活通
                                                           ) THEN '1' ELSE '0' END AS IS_STAY_DEP  --是否靠档类账户：1是0否
      ,CASE WHEN T2.CST_ACT_ID IS NULL AND T1.PROD_ID IN ('00201020100','00202020100','00201020105') THEN '1' ELSE '0' END AS IS_TMIE_DEP  --是否定期存款账户：1是0否
      ,CASE WHEN T2.CST_ACT_ID IS NULL AND T1.PROD_ID IN ('00203010100','00203010200') AND T1.BAL_GL_IND = '1' AND T1.ACT_STS_CD <> 'C' THEN '1' ELSE '0' END AS IS_GRNT_DEP  --是否保证金存款账户：1是0否
      ,CASE WHEN T2.CST_ACT_ID IS NULL AND T1.PROD_ID IN ('00201040100','00202040100','00201040001') THEN '1' ELSE '0' END AS IS_ISSUE_DEP --是否发行类存款账户：1是0否
      ,CASE WHEN T4.DEP_ACT_ID IS NULL THEN '0' ELSE '1' END AS IS_PAY_WAGES  --是否代发工资客户：1是0否
FROM EDW.DIM_BUS_DEP_ACT_INF_DD  T1
LEFT JOIN  EDW.DWD_BUS_DEP_CST_ACT_MGR_INF_DD  T2  --客户存款账户管户信息
ON T2.CST_ACT_ID = T1.CST_ACT_ID AND T2.DT = T1.DT AND T2.ACT_REL_CHR_CD = '6'  --资源性存款账号
LEFT JOIN EDW.DWD_BUS_DEP_AGR_CTR_INF_DD T3 -- 协定存款签约信息
ON T3.DEP_ACT_ID = T1.DEP_ACT_ID AND T3.DT = T1.DT AND T3.AGR_DEP_IND = '1' --协定存款账号
LEFT JOIN EDW.DWD_BUS_DEP_BAL_CHG_DTL_DI T4 ON T1.DEP_ACT_ID = T4.DEP_ACT_ID AND T1.CST_ACT_ID = T4.CST_ACT_ID AND T4.DT >= '@@{yyyyMMdd - 365d}' AND T4.DT <= '@@{yyyyMMdd}' AND T4.TXT_CODE = 'IB0047'  --摘要代码 --当是否代扣代缴客户口径确定之后可以补充到一起
WHERE T1.DT = '@@{yyyyMMdd}'
;


-- 各类账户首个开立日期、开立时长、规模余额、规模月日均
**客群研究_贷记卡v1核对.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-14 16:24:54
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
1. 账级 --RFM(要存续卡) 中&ldquo;过去90天整体交易的次数&rdquo;处，DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A1.RCD_DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90， CD_DT不在A1表中

SELECT  CR_CRD_CARD_NBR
        ,OLD_ACQ_MCH_ENC
        ,OLD_TRX_DT
        ,SUM(BACK_AMT) BACK_AMT
FROM (
        SELECT  CR_CRD_CARD_NBR
                ,SRL_NBR
                ,TRX_AMT AS BACK_AMT  --退货金额
                ,DATEADD(TO_DATE('19570101','YYYYMMDD'),SUBSTR(ACQ_MCH_ENC,1,5),'DD') AS OLD_TRX_DT  --原交易日期
                ,SUBSTR(ACQ_MCH_ENC,6,6) AS OLD_ACQ_MCH_ENC
       --FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_TRX    --信用卡客户交易流水
	   FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
       WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
       AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
       AND TRX_TYP_CD  >= 6000 AND TRX_TYP_CD <= 6999
       AND TRX_TYP_CD <> 6050
       AND TRX_TYP_CD <> 6052
       --AND (TRX_DSCR_1 LIKE '支付宝%' OR  TRX_DSCR_1 LIKE '财付通%' OR (TRX_TYP_CD >= '6000' AND TRX_TYP_CD <= '6999' AND TRX_TYP_CD NOT IN ('6050','6052'))  此条件有问题，去掉???
       )P
GROUP BY  CR_CRD_CARD_NBR,OLD_ACQ_MCH_ENC,OLD_TRX_DT;



DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CST_KA_01;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.CST_KA_01 AS
SELECT CR_CRD_ACT_ID
       ,CR_CRD_CARD_NBR
       ,SRL_NBR    --流水号
       ,TRX_TYP_CD    --交易类型代码
       ,TRX_AMT     --交易金额
       ,TRX_DT     --交易日期
       ,TRX_TM     --交易时间
       ,WDW_RVS_IND  --撤销冲正标志
       ,MCH_TYP       --商户类型
       ,RTN_GDS_TRX_ID  --退货交易标识
       ,ACQ_MCH_ENC   --收单商户编码
       ,TRX_DSCR_1   --交易描述1
       ,TRX_TLR      --交易柜员
       ,DT
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DT <= '@@{yyyyMMdd}'



DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CST_KA_01;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.CST_KA_01 AS
SELECT  CR_CRD_CARD_NBR
                ,SRL_NBR
                ,TRX_AMT AS BACK_AMT  --退货金额
                ,ACQ_MCH_ENC
                ,LENGTH(ACQ_MCH_ENC) AS ACQ_MCH_ENC_LEN
                ,DATEADD(TO_DATE('19570101','YYYYMMDD'),SUBSTR(ACQ_MCH_ENC,1,5),'DD') AS OLD_TRX_DT  --原交易日期
                ,SUBSTR(ACQ_MCH_ENC,6,6) AS OLD_ACQ_MCH_ENC
                ,DT
       FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI   --信用卡客户交易流水
       WHERE DT <= '@@{yyyyMMdd}'
       AND DT >= '@@{yyyyMMdd - 90d}'
       --AND DT <= '@@{yyyyMMdd}' AND DT >= DATEADD(TO_DATE('@@{yyyyMMdd}','yyyyMMdd'),-90,'DD')
       --AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
       AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
       AND TRX_TYP_CD  >= 6000 AND TRX_TYP_CD <= 6999
       AND TRX_TYP_CD <> 6050
       AND TRX_TYP_CD <> 6052
       AND TRX_DSCR_1 LIKE '支付宝%' OR  TRX_DSCR_1 LIKE '财付通%'
;

-- 查看筛选条件之后
SELECT DISTINCT ACQ_MCH_ENC_LEN FROM LAB_BIGDATA_DEV.CST_KA_01;
SELECT CR_CRD_CARD_NBR
      ,ACQ_MCH_ENC
      ,LENGTH(ACQ_MCH_ENC) AS ACQ_MCH_ENC_LEN
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DT <= '@@{yyyyMMdd}'
AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
AND TRX_TYP_CD  >= 6000 AND TRX_TYP_CD <= 6999
AND TRX_TYP_CD <> 6050
AND TRX_TYP_CD <> 6052  AND TRX_DSCR_1 LIKE '支付宝%' OR  TRX_DSCR_1 LIKE '财付通%'
;


------------------------------------------------------验证过程 -------------------------------------------
----------------------20220114 --------------
--厂商代码
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CARD_TRX;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CARD_TRX AS
SELECT CR_CRD_ACT_ID
       ,CR_CRD_CARD_NBR
       ,SRL_NBR    --流水号
       ,TRX_TYP_CD    --交易类型代码
       ,TRX_AMT     --交易金额
       ,TRX_DT     --交易日期
       ,TRX_TM     --交易时间
       ,WDW_RVS_IND  --撤销冲正标志
       ,MCH_TYP       --商户类型
       ,RTN_GDS_TRX_ID  --退货交易标识
       ,ACQ_MCH_ENC   --收单商户编码
       ,TRX_DSCR_1   --交易描述1
       ,TRX_TLR      --交易柜员
       ,DT
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DT <= '@@{yyyyMMdd}'
;

--获取还款日、宽限期
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_10;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_10 AS
SELECT T1.CR_CRD_ACT_ID
      ,T2.DT   SNG_DAY        --近12个月账单日
      ,COALESCE(ROUND(T2.END_TM_BAL,2),0) BIL_AMT  --期末余额（账单金额）
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), 1, 'DD'), 'YYYYMMDD')  LST_SNG_DAY_2  ----近12个月账单日次日
      ,T3.STMT_DAYS    --账单宽限期
      ,T3.PROC_DAYS      --还款宽限期
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), STMT_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_STMT_DAYS --还款日
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), PROC_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_PROC_DAYS --加了宽限期的还款日
      ,T4.TRX_TYP_CD
      ,T4.TRX_AMT
      ,T4.WDW_RVS_IND
      ,T4.TRX_DSCR_1
      ,T4.TRX_DT
      ,T4.TRX_TM
FROM EDW.DIM_BUS_CRD_CR_CRD_ACT_INF_DD T1        --信用卡账户信息
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_BIL_INF_DI T2    --信用卡账单信息
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(T2.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 365
LEFT JOIN EDW.NCRD_PRMCN T3
ON T1.ACT_CTG = T3.CATEGORY AND T1.DT =T3.DT   --此表未入模(修改表名)
LEFT JOIN  LAB_BIGDATA_DEV.CUS_CARD_TRX T4
ON T1.CR_CRD_ACT_ID = T4.CR_CRD_ACT_ID
AND T4.DT >= TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), 1, 'DD'), 'YYYYMMDD')  --大于等于账单日次日
-- AND T4.DT <= CASE  WHEN SUBSTR(T4.DT,5,2) = '02' THEN TO_CHAR(LASTDAY(TO_DATE(T4.DT,'yyyyMMdd')),'yyyyMMdd') --若为2月 则为2月最后一天
--             WHEN SUBSTR(T4.DT,5,2) <>'02' AND SUBSTR(T4.DT,7,2) <= T1.bin_sng_day THEN CONCAT(SUBSTR(T4.DT,1,6),T1.bin_sng_day)     --
--             WHEN SUBSTR(T4.DT,5,2) <>'02' AND SUBSTR(T4.DT,7,2) > T1.bin_sng_day THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T4.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),T1.bin_sng_day)
--              END  --小于等于下一个账单日
AND  ((TRX_TYP_CD >=7000 AND TRX_TYP_CD<=7099 ) OR TRX_TYP_CD IN(7400,1050) OR (TRX_TYP_CD >= 1000 AND TRX_TYP_CD <= 2999) )
WHERE T1.DT = '@@{yyyyMMdd}'
AND T2.DT IS NOT NULL
;

--------------------------------
1. 验证dt是否都是账单日：是的
SELECT DT
FROM EDW.DWD_BUS_CRD_CR_CRD_BIL_INF_DI
WHERE DT >= '20210101' AND DT <= '20220101'
GROUP BY DT
ORDER BY DT
;

2. 验证T4>=账单日次日 AND T4<=下一个账单日逻辑是否对
  限制交易日期在两个账单日之间的逻辑，只有大于号起作用了，小于号未起作用。
SELECT * FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_10 ORDER BY CR_CRD_ACT_ID,SNG_DAY,TRX_DT;
-- 交易流水表中dt与trx_dt是否都是一样：一样
SELECT DT,TRX_DT FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI WHERE DT >= '20211201' AND DT <= '20220101' AND DT <> TRX_DT;

已修改，在贷记卡客群口径中。

select *
from (
select
      a.cst_id
      ,count(case when card_actv_dt <> '18991231' then '1' end) as jihuo_num
      ,count(case when main_crd_ind = '1' and card_actv_dt <> '18991231' then '1'  end) as jihuo_num_main
from edw.dim_bus_crd_cr_crd_inf_dd a
where a.dt = '20220101'
group by a.cst_id
) a
where a.jihuo_num <> a.jihuo_num_main


--------------------------------------------------------------------

--支付宝财付通消费交易情况
--退货情况
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01 AS
SELECT  CR_CRD_CARD_NBR
        ,OLD_ACQ_MCH_ENC
        ,OLD_TRX_DT
        ,SUM(BACK_AMT) BACK_AMT
FROM (
        SELECT  CR_CRD_CARD_NBR
                ,SRL_NBR
                ,TRX_AMT AS BACK_AMT  --退货金额
                ,DATEADD(TO_DATE('19570101','YYYYMMDD'),SUBSTR(ACQ_MCH_ENC,1,5),'DD') AS OLD_TRX_DT  --原交易日期
                ,SUBSTR(ACQ_MCH_ENC,6,6) AS OLD_ACQ_MCH_ENC
       --FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_TRX    --信用卡客户交易流水
	   FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
       WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
       AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
       AND TRX_TYP_CD  >= 6000 AND TRX_TYP_CD <= 6999
       AND TRX_TYP_CD <> 6050
       AND TRX_TYP_CD <> 6052
       --AND (TRX_DSCR_1 LIKE '支付宝%' OR  TRX_DSCR_1 LIKE '财付通%' OR (TRX_TYP_CD >= '6000' AND TRX_TYP_CD <= '6999' AND TRX_TYP_CD NOT IN ('6050','6052'))  此条件有问题，去掉???  --xt
       )P
GROUP BY  CR_CRD_CARD_NBR,OLD_ACQ_MCH_ENC,OLD_TRX_DT;


--交易情况
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 AS
SELECT  A.CR_CRD_ACT_ID       --信用卡账号
        ,A.CR_CRD_CARD_NBR      --信用卡卡号
        ,A.SRL_NBR              --流水号
        ,A.TRX_TYP_CD           --交易类型代码
        ,A.TRX_AMT              --交易金额
        ,A.TRX_DT               --交易日期
        ,A.ACQ_MCH_ENC          --收单商户编码
        ,COALESCE(B.BACK_AMT,0)  BACK_AMT  --退货金额
        ,A.TRX_DSCR_1
        ,A.DT
        ,A.MCH_TYP  --商户类型
--FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_TRX   A   --xt
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI A
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01  B
ON B.OLD_ACQ_MCH_ENC = A.SRL_NBR
AND B.OLD_TRX_DT = TO_DATE(A.TRX_DT,'YYYYMMDD')
AND A.CR_CRD_CARD_NBR = B.CR_CRD_CARD_NBR
WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
AND A.WDW_RVS_IND <> '1'  --撤销冲正标志<>1
AND A.TRX_TYP_CD  >= 1000 AND A.TRX_TYP_CD <= 1999
AND A.TRX_TYP_CD <> 1050     --筛选交易类型为消费
AND A.RTN_GDS_TRX_ID <> '全额退货'
;

--汇总到卡级
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03 AS
SELECT N1.CST_ID
       ,N1.CR_CRD_ACT_ID
       ,N1.CR_CRD_CARD_NBR
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' THEN (TRX_AMT + BACK_AMT) END )AS ZFB_AMT_90  --近90天支付宝消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) ZFB_NBR_90     --近90天支付宝消费笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%' THEN (TRX_AMT + BACK_AMT) END )AS CFT_AMT_90  --近90天财付通消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) CFT_NBR_90                 --近90天财付通消费笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT)END
            )AS ZFB_AMT_30                     --近30天支付宝消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) ZFB_NBR_30                      --近30天支付宝消费笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT) END
            )AS CFT_AMT_30                      --近30天财付通消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) CFT_NBR_30                      --近30天财付通消费笔数
       ,SUM(CASE
                WHEN MCH_TYP IN ('5812','5813','5814')
                THEN TRX_AMT ELSE 0 END
            ) AS  INB_CREDITCARD_REPAST_CONSUME_AMT_90               --近90天餐饮交易金额
        ,SUM(CASE
               WHEN MCH_TYP IN ('5812','5813','5814')
               THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_90                 --近90天餐饮交易笔数
       ,SUM(CASE
                MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
                OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
                THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_90                   --近90天航旅交易金额
            ,SUM(CASE
               WHEN (MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
               OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
               THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_90                  --近90天航旅交易笔数
       ,SUM(CASE
                WHEN TRX_TYP_CD='1184'
                THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_90                  --近90天境外交易金额
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184' THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_90                   --近90天境外交易笔数
      ,SUM(CASE
                WHEN DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND MCH_TYP IN ('5812','5813','5814') THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_AMT_30                    --近30天餐饮交易金额
      ,SUM(CASE
              WHEN DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND MCH_TYP IN ('5812','5813','5814')
              THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_30                    --近30天餐饮交易笔数
      ,SUM(CASE
              WHEN (MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_30                      --近30天航旅交易金额
      ,SUM(CASE
              WHEN (MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               THEN 1 ELSE 0 END
             ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_30                       --近30天航旅交易笔数
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               THEN TRX_AMT ELSE 0 END
               ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_30                     --近30天境外交易金额
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_30                        --近30天境外交易笔数
FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 N2
ON N1.CR_CRD_CARD_NBR = N2.CR_CRD_CARD_NBR
GROUP BY N1.CST_ID,N1.CR_CRD_ACT_ID,N1.CR_CRD_CARD_NBR
;

-----------------------------------------------------20220119 账级 ---------------------------------
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_01;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_01 AS
SELECT  CR_CRD_ACT_ID     --信用卡账户
        ,CR_CRD_CARD_NBR     --信用卡卡号
        ,TRX_DT               --交易日期
        ,TRX_TYP_CD          --交易类型代码
        ,TRX_TLR             --交易柜员
        ,TRX_DSCR_1          --交易描述1
        ,CASE WHEN TRX_DSCR_1 LIKE '支付宝%' THEN '第三方渠道-支付宝'
              WHEN TRX_DSCR_1 LIKE '财付通%' THEN '第三方渠道-财付通'
              WHEN TRX_TYP_CD = 7028 THEN '第三方渠道-银联在线'
              WHEN TRX_TYP_CD IN (7000,7012,7020,7030,7036,7050,7054,7056,7062,7086,7092,7094,7096,7400) THEN '柜面'
              WHEN TRX_TYP_CD IN (7010,7040,7060,7080,7082,7084) THEN 'ATM'
              WHEN (TRX_TLR LIKE '%SJG%' OR TRX_TLR LIKE '%SJGY%') THEN '手机银行'
              WHEN (TRX_TLR LIKE '%WYGY%' OR TRX_TLR LIKE '%WYG%') THEN '网上银行'
            ELSE '' END AS CHANN_REPAY  --还款渠道
        ,CASE WHEN (TRX_TYP_CD >= 7000 AND TRX_TYP_CD <= 7099 AND TRX_TYP_CD NOT IN (7002,7056) OR TRX_TYP_CD = 7400) THEN '自扣还款'
              WHEN (TRX_TYP_CD > 7099 AND TRX_TYP_CD <> 7400 OR TRX_TYP_CD IN (7002,7056)) AND
                  ((TRX_TYP_CD = 7000 AND TRX_TLR NOT LIKE '%XYGY%') OR  TRX_TYP_CD IN (7002,7010,7012,7024,7036,7040,7050,7054,7056,7060,7062,7070,7400)) THEN '非自扣本行渠道'
              WHEN (TRX_TYP_CD > 7099 AND TRX_TYP_CD <> 7400 OR TRX_TYP_CD IN (7002,7056)) AND
                 ((TRX_TYP_CD = 7000 AND TRX_TLR LIKE '%XYGY%') OR  TRX_TYP_CD IN (7020,7028,7030,7032,7076,7080,7082,7084,7092,7094,7096)) THEN '非本行渠道还款'
            ELSE '' END AS METHOD_REPAY  --还款方式
--FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_TRX
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 365   --12个月内
AND TRX_TYP_CD >= 7000 AND TRX_TYP_CD <= 7999  --筛选：还款
AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
;



--------------------------------------------------------------------------

-- 账单日
-- 近12个月的账单日与下一个账单日
-- 获取还款日、宽限期
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_10;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_10 AS
SELECT T1.CR_CRD_ACT_ID
      ,T2.DT   SNG_DAY        --近12个月账单日
      ,CASE WHEN SUBSTR(T2.DT,5,2) = '01' AND SUBSTR(T2.DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(T2.DT,1,6),BIN_SNG_DAY)  --若为1月30之前，则下一个账单日在0130
            WHEN SUBSTR(T2.DT,5,2) = '01' AND SUBSTR(T2.DT,7,2) >= BIN_SNG_DAY THEN TO_CHAR(LASTDAY(DATEADD(TO_DATE(CONCAT(SUBSTR(T2.DT,1,6),'01'),'yyyyMMdd'),1,'MM')),'yyyyMMdd')  --若为0130,0131，则为2月最后一天
            WHEN SUBSTR(T2.DT,5,2) = '02' AND T2.DT < TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') THEN TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') --若为2月最后一天之前，则为2月最后一天
            WHEN SUBSTR(T2.DT,5,2) = '02' AND T2.DT = TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY) --若为2月最后一天，则为3月30
            WHEN SUBSTR(T2.DT,5,2) NOT IN ('01','02') AND SUBSTR(T2.DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(T2.DT,1,6),BIN_SNG_DAY)
            WHEN SUBSTR(T2.DT,5,2) NOT IN ('01','02') AND SUBSTR(T2.DT,7,2) >= BIN_SNG_DAY THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)
      END AS NEXT_SNG_DAY  --下一个账单日
      ,COALESCE(ROUND(T2.END_TM_BAL,2),0) BIL_AMT  --期末余额（账单金额）
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), 1, 'DD'), 'YYYYMMDD')  LST_SNG_DAY_2  ----近12个月账单日次日
      ,T3.STMT_DAYS    --账单宽限期
      ,T3.PROC_DAYS      --还款宽限期
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), STMT_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_STMT_DAYS --还款日
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), PROC_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_PROC_DAYS --加了宽限期的还款日
from EDW.DIM_BUS_CRD_CR_CRD_ACT_INF_DD T1  --信用卡账户信息
left join EDW.DWD_BUS_CRD_CR_CRD_BIL_INF_DI T2  --信用卡账单信息
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(T2.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 365
LEFT JOIN EDW.NCRD_PRMCN T3 ON T1.ACT_CTG = T3.CATEGORY AND T1.DT =T3.DT  --产品参数表
WHERE T1.DT = '@@{yyyyMMdd}'
AND T2.DT IS NOT NULL
;


-- 每个当期账单期间的交易
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_11;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_11 AS
select T1.*
      ,T2.TRX_TYP_CD
      ,T2.TRX_AMT
      ,T2.WDW_RVS_IND
      ,T2.TRX_DSCR_1
      ,T2.TRX_DT
      ,T2.TRX_TM
FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_10 T1
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI T2 ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID AND T2.DT >= T1.LST_SNG_DAY_2
AND T2.DT <= T1.NEXT_SNG_DAY AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(T2.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 365
AND  ((TRX_TYP_CD >='7000' AND TRX_TYP_CD<='7099' ) OR TRX_TYP_CD IN('7400','1050') OR (TRX_TYP_CD >= '1000' AND TRX_TYP_CD <= '2999') )
;

SELECT * FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_11 ORDER BY CR_CRD_ACT_ID,SNG_DAY,TRX_DT;

--计算还款类型
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_PRAY_TYPE;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_PRAY_TYPE AS
SELECT  CR_CRD_ACT_ID --？需确认：金额大小的比较
        ,SNG_DAY --账单日
        ,CASE WHEN  BIL_AMT <=0 THEN '无还款'
              WHEN BIL_AMT>0 AND INSTL_RPAY_F = 1  THEN '分期还款'
              WHEN BIL_AMT>0 AND ACTIVE_RPAY_TRX_AMT >=BIL_AMT THEN '提前还款-全额还款'
              WHEN BIL_AMT>0 AND ACTIVE_RPAY_TRX_AMT < BIL_AMT AND GRC_ACTIVE_RPAY_TRX_AMT >=BIL_AMT  AND (RPAY_NUM = 1 OR (RPAY_NUM>1 AND CSM_CSH_NUM = 0)) THEN  '一次性还款-全额还款'
              WHEN BIL_AMT>0 AND GRC_ACTIVE_RPAY_TRX_AMT >0 AND GRC_ACTIVE_RPAY_TRX_AMT < BIL_AMT AND (RPAY_NUM = 1 OR (RPAY_NUM>1 AND CSM_CSH_NUM = 0))  THEN '一次性还款-未全额还款'
              WHEN BIL_AMT>0 AND ACTIVE_RPAY_TRX_AMT >0 AND ACTIVE_RPAY_TRX_AMT < BIL_AMT AND GRC_ACTIVE_RPAY_TRX_AMT >=BIL_AMT AND (RPAY_NUM = 1 OR (RPAY_NUM>1 AND CSM_CSH_NUM > 0))  THEN '循环还款-全额还款'
              WHEN BIL_AMT>0 AND GRC_ACTIVE_RPAY_TRX_AMT >0 AND GRC_ACTIVE_RPAY_TRX_AMT < BIL_AMT  AND (RPAY_NUM = 1 OR (RPAY_NUM>1 AND CSM_CSH_NUM > 0))  THEN '循环还款-未全额还款'
              WHEN  RPAY_NUM > 0 THEN '其它还款类型' END AS RPAY_TYPE --还款类型
FROM  (
        SELECT  T1.CR_CRD_ACT_ID
                ,T1.SNG_DAY --账单日
                ,MAX(BIL_AMT)  BIL_AMT                                         --帐单金额
                ,MAX(CASE WHEN BIL_AMT >0
                          AND  TRX_TYP_CD  ='1050'
                          AND  TRX_DSCR_1 LIKE '%账单分期%'  THEN 1 END )  INSTL_RPAY_F    --是否有分期交易
                ,SUM(CASE WHEN TRX_DT >=LST_SNG_DAY_2
                       AND TRX_DT <=BIL_STMT_DAYS     --还款日前
                       AND ((TRX_TYP_CD >='7000' AND TRX_TYP_CD<='7099' ) AND (TRX_TYP_CD NOT IN ('7002','7056')) OR TRX_TYP_CD = '7400')  --主动还款交易
                       AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
                       THEN ABS(TRX_AMT)  END ) AS  ACTIVE_RPAY_TRX_AMT                   --本月还款日前主动还款金额
                ,SUM(CASE WHEN TRX_DT >=LST_SNG_DAY_2
                       AND TRX_DT <=BIL_PROC_DAYS   --还款宽限日前
                       AND ((TRX_TYP_CD >='7000' AND TRX_TYP_CD<='7099' ) AND (TRX_TYP_CD NOT IN ('7002','7056') ) OR TRX_TYP_CD = '7400')  --主动还款交易
                       AND WDW_RVS_IND <> '1'     --撤销冲正标志<>1
                       THEN ABS(TRX_AMT)  END )  AS  GRC_ACTIVE_RPAY_TRX_AMT              --本月还款宽限日前主动还款金额
                ,SUM(CASE WHEN TRX_TYP_CD >='7000'
                          AND TRX_TYP_CD<='7099'  THEN 1 ELSE 0 END )AS RPAY_NUM            --还款次数
                ,SUM(CASE WHEN TRX_TYP_CD >= '1000'
                          AND TRX_TYP_CD <= '2999'
                          AND TRX_TYP_CD <> '1050'
                          AND CONCAT(TRX_DT,TRX_TM) >=T2.MIN_TRX_TM
                          AND  CONCAT(TRX_DT,TRX_TM) <= T2.MAX_TRX_TM  THEN 1  ELSE 0  END) AS CSM_CSH_NUM --还款中消费取现次数（计算在还款时间内有取现消费）
       FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_11 T1
       LEFT JOIN (
                   SELECT CR_CRD_ACT_ID
                          ,SNG_DAY --账单日
                          ,MIN(CONCAT(TRX_DT,TRX_TM)) MIN_TRX_TM  --最早还款日期
                          ,MAX(CONCAT(TRX_DT,TRX_TM)) MAX_TRX_TM   --最晚还款日期
                   FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_11
                   WHERE TRX_TYP_CD >='7000' AND TRX_TYP_CD<='7099'  --AND TRX_TYP_CD <> '1050'
                   GROUP BY  CR_CRD_ACT_ID ,SNG_DAY
                  )T2
      ON  T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
      AND T1.SNG_DAY = T2.SNG_DAY
      GROUP BY T1.CR_CRD_ACT_ID,T1.SNG_DAY
) P
;
SELECT * FROM  LAB_BIGDATA_DEV.CUS_CRD_ACT_PRAY_TYPE ORDER BY CR_CRD_ACT_ID,SNG_DAY;
SELECT rpay_type,COUNT(1) FROM  LAB_BIGDATA_DEV.CUS_CRD_ACT_PRAY_TYPE GROUP BY rpay_type;


DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.XT_024618_TMP_01;
CREATE  TABLE  LAB_BIGDATA_DEV.XT_024618_TMP_01 AS
SELECT P1.CST_ID  CST_ID   --客户号
      ,P1.CR_CRD_ACT_ID --信用卡账户
      ,P8.MOST_RPAY_TYPE   --最高频还款类型
      ,P9.LAST_RPAY_TYPE    --最近一次还款类型
      ,COALESCE(P8.MOST_RPAY_TYPE,'无还款') AS MOST_RPAY_TYPE_1  --最高频还款类型
      ,COALESCE(P9.LAST_RPAY_TYPE,'无还款') AS LAST_RPAY_TYPE_1   --最近一次还款类型
FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD P1
LEFT JOIN (
            SELECT  CR_CRD_ACT_ID
                    ,RPAY_TYPE  MOST_RPAY_TYPE --最高频还款类型
            FROM  (
                    SELECT CR_CRD_ACT_ID
                           ,RPAY_TYPE
                           ,ROW_NUMBER() OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY NUM DESC) ROW_NO
                    FROM (
                           SELECT CR_CRD_ACT_ID
                                  ,RPAY_TYPE
                                  ,COUNT(1) NUM
                            FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_PRAY_TYPE
                            WHERE RPAY_TYPE IS NOT NULL AND RPAY_TYPE <> '无还款'
                            GROUP BY  CR_CRD_ACT_ID,RPAY_TYPE
                         )N1
                   )N2
            WHERE  ROW_NO = 1
        )P8
ON P1.CR_CRD_ACT_ID =  P8.CR_CRD_ACT_ID
LEFT JOIN (
            SELECT  CR_CRD_ACT_ID
                    ,RPAY_TYPE  LAST_RPAY_TYPE   --最近一次还款类型
            FROM (
                   SELECT  CR_CRD_ACT_ID
                           ,RPAY_TYPE
                           ,ROW_NUMBER() OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY SNG_DAY DESC) ROW_NO
                   FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_PRAY_TYPE
                   WHERE RPAY_TYPE IS NOT NULL AND RPAY_TYPE <> '无还款'
                 )N1
            WHERE ROW_NO = 1
           )P9
ON P1.CR_CRD_ACT_ID =  P9.CR_CRD_ACT_ID
WHERE P1.DT =  '@@{yyyyMMdd}'
;

SELECT * FROM LAB_BIGDATA_DEV.XT_024618_TMP_01 ORDER BY CST_ID,CR_CRD_ACT_ID;



-------------------------------------------------------------- 20220120 -------------------------------------------------------------------------
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_TRX_02;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_TRX_02 AS
SELECT  T1.CST_ID
        ,T1.CR_CRD_ACT_ID
        ,T2.CR_CRD_CARD_NBR
        ,T2.TRX_DT
        ,T2.TRX_TYP_CD
        ,T2.TRX_AMT
FROM   EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
LEFT JOIN  EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI  T2
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
AND T2.DT <= '@@{yyyyMMdd}'
WHERE T1.DT = '@@{yyyyMMdd}'
AND  T2.TRX_TYP_CD IN (
 --消费
 '1000','1010','1016','1020','1020','1030','1040','1110','1112','1120','1122','1123','1180','1184'
 --取现/转出
 ,'2000','2010','2012','2040','2042','2046','2048','2050','2060','2070','2072','2090','2092','2094'
 ,'2098','2100','2104','2106','2110','2122','2123','2140','2142','2144','2150','2154','2160','2170'
 ,'2172','2174','2180','2182','2184','2300','2310','2312','2340','2342','2346','2350','2360','2370'
 ,'2372','2398','2400','2404','2406','2410','2422','2423','2440','2442','2444','2450','2460','2470'
 ,'2472','2474','2480','2482','2484'
 --分期
 , '8130' , '8950' , '8952' , '8954' , '8956' , '8958'
  --取现人工
 , '8110' , '8112' , '8114' , '8116'
  --消费人工
 , '8100' , '8104')
AND T2.WDW_RVS_IND <> '1'
;

----------------------------------------------
-- 退出类型：3.账户下卡片序号最大的一张不为2-过期未续或Q-销户申请，卡片到期日期＜统计日期
-- 下面这样查询出来，卡片的卡片状态日期>到期日期
select cr_crd_act_id
      ,substr(cr_crd_card_nbr,1,6) as card1
      ,substr(cr_crd_card_nbr,7,length(cr_crd_card_nbr)) as card2
      ,card_sts_cd
      ,main_crd_ind
      ,card_sts_dt
      ,TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') as MTU_DAY
      ,row_number()over(partition by cr_crd_act_id order by cr_crd_card_nbr desc) as rn
from edw.dim_bus_crd_cr_crd_inf_dd
where dt = '20220119'
and card_sts_cd = ''
and TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') < '20220119' --已到期
order by cr_crd_act_id,cr_crd_card_nbr
;

-- 账户是否核销的判断逻辑？
-- 账户状态为V-核销时，账户下的卡的状态是什么：没有正常的
SELECT  T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.CR_CRD_ACT_ID --信用卡账户
        ,T1.CST_ID CST_ID --客户号
        ,T.CR_CRD_PD_ID --信用卡产品编号
        ,T.MAIN_CRD_IND --主附卡标志（1-主卡）
        ,T.CARD_STS_CD --卡片状态代码
        ,T.CARD_STS_DT --卡片状态日期
FROM    EDW.DIM_BUS_CRD_CR_CRD_INF_DD T --信用卡卡片信息
LEFT JOIN    EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
ON      T.CR_CRD_ACT_ID = T1.CR_CRD_ACT_ID
AND     T1.DT = '@@{yyyyMMdd}'
WHERE   T.DT = '@@{yyyyMMdd}'
 AND T1.ACT_STS_CD = 'V'
ORDER BY T.CR_CRD_ACT_ID,T.CR_CRD_CARD_NBR
;




---------------------------------/* 客户级校验 20220120  */--------------------------
-- 信用卡交易流水表中是否有交易日期=18991231的情况：无
SELECT CR_CRD_CARD_NBR,TRX_DT
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI T1
WHERE DT <= '@@{yyyyMMdd}'
AND TRX_DT = '18991231'
;

-- 卡片到期情况
-- 是不是所有的卡都有到期日期:是的
SELECT CR_CRD_CARD_NBR
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01
WHERE MTU_DAY = '18991231'
;


-- 信用卡客户级额度
-- 厂商代码中使用主卡号关联，
-- 查看是否与客户号关联一致
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_LMT;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_LMT AS
SELECT  T1.CST_ID
        ,MAX(CASE WHEN T1.CUNXU_FLAG = '1' THEN  T2.CRD_LMT ELSE 0 END ) CRD_LMT--信用卡客户级额度
        ,SUM(T2.CRD_LMT)  SUM_CRD_LMT--信用卡总额度
        ,SUM(T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL) CRD_USED_AMT--信用卡用信金额
        ,SUM(CASE WHEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) <0 THEN 0 ELSE (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) END )  CRD_UNUSED_AMT--信用卡未使用金额
        ,MAX(CASE WHEN T1.CRD_CTG_CD = 1 AND T1.CUNXU_FLAG = '1' THEN T2.CRD_LMT ELSE 0 END ) DBT_CRD_LMT --贷记卡客户级额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.CRD_LMT ELSE 0 END )  SUM_DBT_CRD_LMT --贷记卡总额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL END ) DBT_CRD_USED_AMT--贷记卡用信金额
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  AND  (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) > 0 THEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) ELSE 0 END  ) DBT_CRD_UNUSED_AMT --贷记卡未使用金额
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.MAIN_CARD_CARD_NBR = T2.LATE_MAIN_CARD_CARD_NBR
WHERE T2.DT  = '@@{yyyyMMdd}'
GROUP BY  T1.CST_ID
;



SELECT T1.CST_ID
      ,T1.CR_CRD_ACT_ID
      ,SUBSTR(T1.MAIN_CARD_CARD_NBR,1,6) AS MAIN_CARD_CARD_NBR1
      ,SUBSTR(T1.MAIN_CARD_CARD_NBR,7,LENGTH(T1.MAIN_CARD_CARD_NBR)) AS MAIN_CARD_CARD_NBR2
      ,SUBSTR(T2.LATE_MAIN_CARD_CARD_NBR,1,6) AS LATE_MAIN_CARD_CARD_NBR1
      ,SUBSTR(T2.LATE_MAIN_CARD_CARD_NBR,7,LENGTH(T2.LATE_MAIN_CARD_CARD_NBR)) AS LATE_MAIN_CARD_CARD_NBR2
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
AND T2.DT = '@@{yyyyMMdd}'
WHERE T1.MAIN_CARD_CARD_NBR <> T2.LATE_MAIN_CARD_CARD_NBR
AND T1.CST_ID <> ''
ORDER BY T1.CST_ID,T1.CR_CRD_ACT_ID
;



SELECT T1.CST_ID
      ,SUBSTR(T1.MAIN_CARD_CARD_NBR,1,6) AS MAIN_CARD_CARD_NBR1
      ,SUBSTR(T1.MAIN_CARD_CARD_NBR,7,LENGTH(T1.MAIN_CARD_CARD_NBR)) AS MAIN_CARD_CARD_NBR2
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
WHERE CST_ID = '1000000021'
;



SELECT CST_ID
      ,SUBSTR(LATE_MAIN_CARD_CARD_NBR,1,6) AS LATE_MAIN_CARD_CARD_NBR1
      ,SUBSTR(LATE_MAIN_CARD_CARD_NBR,7,LENGTH(LATE_MAIN_CARD_CARD_NBR)) AS LATE_MAIN_CARD_CARD_NBR2
FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD
WHERE DT = '@@{yyyyMMdd}'
AND CST_ID = '1000000021'



DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_LMT;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_LMT AS
SELECT  T1.CST_ID
        ,MAX(CASE WHEN T1.CUNXU_FLAG = '1' THEN  T2.CRD_LMT ELSE 0 END ) CRD_LMT--信用卡客户级额度
        ,SUM(T2.CRD_LMT)  SUM_CRD_LMT--信用卡总额度
        ,SUM(T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL) CRD_USED_AMT--信用卡用信金额
        ,SUM(CASE WHEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) <0 THEN 0 ELSE (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) END )  CRD_UNUSED_AMT--信用卡未使用金额
        ,MAX(CASE WHEN T1.CRD_CTG_CD = 1 AND T1.CUNXU_FLAG = '1' THEN T2.CRD_LMT ELSE 0 END ) DBT_CRD_LMT --贷记卡客户级额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.CRD_LMT ELSE 0 END )  SUM_DBT_CRD_LMT --贷记卡总额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL END ) DBT_CRD_USED_AMT--贷记卡用信金额
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  AND  (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) > 0 THEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) ELSE 0 END  ) DBT_CRD_UNUSED_AMT --贷记卡未使用金额
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.MAIN_CARD_CARD_NBR = T2.LATE_MAIN_CARD_CARD_NBR
WHERE T2.DT  = '@@{yyyyMMdd}'
--AND CUNXU_FLAG = '1'
GROUP BY  T1.CST_ID
;


DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_LMT1;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_LMT1 AS
SELECT  T1.CST_ID
        ,MAX(CASE WHEN T1.CUNXU_FLAG = '1' THEN  T2.CRD_LMT ELSE 0 END ) CRD_LMT--信用卡客户级额度
        ,SUM(T2.CRD_LMT)  SUM_CRD_LMT--信用卡总额度
        ,SUM(T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL) CRD_USED_AMT--信用卡用信金额
        ,SUM(CASE WHEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) <0 THEN 0 ELSE (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) END )  CRD_UNUSED_AMT--信用卡未使用金额
        ,MAX(CASE WHEN T1.CRD_CTG_CD = 1 AND T1.CUNXU_FLAG = '1' THEN T2.CRD_LMT ELSE 0 END ) DBT_CRD_LMT --贷记卡客户级额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.CRD_LMT ELSE 0 END )  SUM_DBT_CRD_LMT --贷记卡总额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL END ) DBT_CRD_USED_AMT--贷记卡用信金额
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  AND  (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) > 0 THEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) ELSE 0 END  ) DBT_CRD_UNUSED_AMT --贷记卡未使用金额
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.MAIN_CARD_CARD_NBR = T2.LATE_MAIN_CARD_CARD_NBR
WHERE T2.DT  = '@@{yyyyMMdd}'
AND CUNXU_FLAG = '1'
GROUP BY  T1.CST_ID
;


SELECT T1.*,T2.*
FROM LAB_BIGDATA_DEV.CUS_CRD_LMT T1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CRD_LMT1 T2 ON T1.CST_ID = T2.CST_ID
WHERE (T1.CRD_USED_AMT <> T2.CRD_USED_AMT OR T1.CRD_UNUSED_AMT <> T2.CRD_UNUSED_AMT)
;


-- T2中的是不是都是存续卡
SELECT T1.CST_ID
      ,T1.CR_CRD_ACT_ID
      ,T1.CR_CRD_CARD_NBR
      ,T1.CUNXU_FLAG
      ,T2.CRD_LMT  --授信额度
      ,T2.OVDR_BAL --用信额度
      ,T2.INSTL_RMN_NOT_PAID_PRCP_BAL
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.MAIN_CARD_CARD_NBR = T2.LATE_MAIN_CARD_CARD_NBR
AND T2.DT  = '@@{yyyyMMdd}'
WHERE T1.CUNXU_FLAG <> '1' AND T2.CRD_LMT IS NOT NULL  --是否存在不是存续卡但是统计了授信额度/用信额度的
;



-- 他行授信情况
select cst_id
      ,ctr_amt
      ,ctr_bal
from edw.dim_cst_ccrc_idv_loan_inf_dd
where dt = '20220120'
and cst_id <> ''
and act_typ_cd = 'R2'




DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_LMT;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_LMT AS
SELECT  T1.CST_ID
        ,MAX(CASE WHEN T1.CUNXU_FLAG = '1' THEN  T2.CRD_LMT ELSE 0 END ) CRD_LMT--信用卡客户级额度
        ,SUM(T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL) CRD_USED_AMT--信用卡用信金额
        --,SUM(CASE WHEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) <0 THEN 0 ELSE (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) END )  CRD_UNUSED_AMT--信用卡未使用金额
        ,MAX(CASE WHEN T1.CRD_CTG_CD = 1 AND T1.CUNXU_FLAG = '1' THEN T2.CRD_LMT ELSE 0 END ) DBT_CRD_LMT --贷记卡客户级额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL END ) DBT_CRD_USED_AMT--贷记卡用信金额
        --,SUM(CASE WHEN T1.CRD_CTG_CD = 1  AND  (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) > 0 THEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) ELSE 0 END  ) DBT_CRD_UNUSED_AMT --贷记卡未使用金额
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.MAIN_CARD_CARD_NBR = T2.LATE_MAIN_CARD_CARD_NBR
WHERE T2.DT  = '@@{yyyyMMdd}'
GROUP BY  T1.CST_ID
;

SELECT CST_ID
      ,DBT_CRD_LMT
      ,DBT_CRD_USED_AMT
      ,CASE WHEN (DBT_CRD_LMT - DBT_CRD_USED_AMT) < 0 THEN 0 ELSE DBT_CRD_LMT - DBT_CRD_USED_AMT END
      ,CASE WHEN DBT_CRD_LMT > 0 THEN COALESCE(DBT_CRD_USED_AMT,0)/DBT_CRD_LMT ELSE 0 END CRD_USED_RATE
FROM LAB_BIGDATA_DEV.CUS_CRD_LMT
;
**客群研究_贷记卡客群口径.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-17 08:30:37
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

-- ************************************************************  贷记卡生命周期问题  *************************************
-- ---------------------------------------------------------20211217-----------------
1、进件渠道 来源表和字段
只找到edw.dwd_bus_crd_cr_crd_apl_inf_dd信用卡申请信息表中的
申请件来源代码  不是渠道
参考代码：
SELECT a.late_main_card_card_nbr  AS main_card_card_nbr --主卡卡号
      ,COALESCE(T1.CHANNEL, '')  AS chnl_cd_s
      ,CASE
        WHEN T1.DATA_FLG = '3' THEN COALESCE(T2.PRODUCT_NAME, '')
        WHEN T1.DATA_FLG = '2' THEN COALESCE(T1.CHANNELIN, '')
        ELSE COALESCE(T1.CHANNEL, '')
      END AS CHANNELIN  -- 进件渠道
FROM  edw.dws_bus_crd_cr_crd_act_inf_dd a --信用卡账户信息表  全量表
LEFT JOIN  edw.dim_bus_crd_cr_crd_inf_dd f ON a.cst_id = f.cst_id AND a.cr_crd_act_id = f.cr_crd_act_id AND f.dt = '20210731'     --信用卡卡片信息表
LEFT JOIN  app_rpt.FCT_CRD_CARD_APL_INFO T1 ON f.busi_apl_id = T1.SERIALNO AND T1.dt = '20210731'     --信用卡申请表
LEFT JOIN    (
                 SELECT  APPLY_SEQ_NO
                         ,PRODUCT_NAME
                         ,ROW_NUMBER() OVER ( PARTITION BY APPLY_SEQ_NO ) AS RN
                 FROM    edw.SFPS_TB_JD_BUINESS_INFO -- 金融云申请渠道
                 WHERE   DT = '20210731'
             ) T2
ON  T2.APPLY_SEQ_NO = T1.SERIALNO AND T2.RN = 1
WHERE a.dt = '20210731'
;


3、是否绑定支付宝 对应的来源表
找到的表app_ado.cr_crd_epcc_cr_ar_inf	信用卡绑定信息汇总表
不能访问 有没有其他的表

暂时还未找到其他表


4、是否绑定第三方
给的代码中lab_bigdata_dev.sample_20211024 不能访问
是否有其他的表
参考代码：
是否绑定第三方是卡级的指标，&quot;客户号&quot;字段不需要，可以不关联t1表
select
   distinct
   t.idno                               --签约人证件号
   ,t.sgnacctid                         --签约人卡号
   ,t.instgacct                         --签约人支付账户号
   ,t.instgid                           --支付机构标识
   ,t.agrmtsts                          --协议状态
   ,t.sgndt                             --签约时间
   --,t1.cst_id                           --客户号
   ,t2.instgshornm                      --绑定渠道
from edw.epcc_epcc_payagrmt t            --第三方支付表
--inner join (select distinct cst_id,doc_nbr  from lab_bigdata_dev.sample_20211024) T1
   --on t.idno=t1.doc_nbr
left join (select distinct instgid,instgshornm from edw.epcc_epcc_instgidinf where dt<='20211024') t2  --第三方支付明细表
   on t.instgid = t2.instgid
where t.dt='20211024'
and t.agrmtsts='1' --有效
;


5、信用卡待激活类型中的 二卡待激活
客户信用卡主卡激活记录数&ge;1  这个怎么取
参考代码：
二卡待激活的其他条件，与下列关联
select cr_crd_card_nbr  --激活记录数>=1的主卡卡号
      ,card_actv_dt
from edw.dim_bus_crd_cr_crd_inf_dd
where dt = '20211206'
and main_crd_ind = '1'   --筛选主卡
and card_actv_dt <> '18991231'   --激活日期为'18991231'表示未激活
;


8、首刷的字段
9、是否开通备用金
参考代码：
select cr_crd_card_nbr
      ,case when b.serialno is null then '未开通' else '已开通' end as 是否开通备用金
      ,case when c.serialno is null then '截至昨天未用款' else c.inputdate as 首刷时间
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.loan_business_contract b on b.accountno = a.cr_crd_card_nbr and b.dt = a.dt
left join edw.loan_business_duebill c on c.relativeserialno2 = b.serialno and c.dt = a.dt
where a.dt = '20211216'
;

edw.loan_business_contract：
授信额度和授信利率：按照通用标签里面的逻辑
渠道：channel
备用金申请日期：edw.dwd_bus_loan_apl_inf_dd
借据发放日期：edw.dim_bus_loan_dbil_inf_dd   dtrb_dt










---------------------------------------------------------20211220-----------
2、是否绑定微信  是指是否绑定微信银行还是微信公众号
分成两个标签：是否绑定泰隆银行微信、是否绑定信用卡微信
是否绑定信用卡微信：
select cr_crd_card_nbr
      ,bind_sts  --当前绑定状态
      ,frs_bind_dt  --首次绑定日期
from edw.dwd_bus_crd_wx_ofc_act_bind_sts_inf_dd
where dt = '20211219'
;

是否绑定泰隆银行微信：
edw.dwd_bus_chnl_elec_wechat_bind_inf_dd


6、是否激活 是否要状态为A和激活日期为 &lsquo;18991231&rsquo; 同时满足，
我看到有一些数据是 激活日期为18991231 但是状态为Q
未激活：激活日期='18991231'


7、消费笔数、金额  境外航旅餐饮线上分别对应的交易类型
参考代码：
select cr_crd_card_nbr
      -- 餐饮
      ,sum(CASE WHEN substr(trx_typ_cd,1,1)='1' AND mch_typ IN ('5812','5813','5814') AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_repast_consume_amt   --交易金额
      ,sum(CASE WHEN substr(trx_typ_cd,1,1)='1' AND mch_typ IN ('5812','5813','5814') AND wdw_rvs_ind = 0  THEN 1 ELSE 0 END ) AS inb_creditcard_repast_consume_cnt  --交易笔数
      -- 航旅
      ,sum(CASE WHEN (substr(trx_typ_cd,1,1)='1' AND mch_typ IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012') OR substr(mch_typ,1,2) IN ('30','31','32','35','37')) AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_plane_consume_amt
      ,sum(CASE WHEN (substr(trx_typ_cd,1,1)='1' AND mch_typ IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012') OR substr(mch_typ,1,2) IN ('30','31','32','35','37')) AND wdw_rvs_ind = 0 THEN 1 ELSE 0 END ) AS inb_creditcard_plane_consume_cnt
      -- 境外
      ,sum(CASE WHEN trx_typ_cd='1184' AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_abroad_consume_amt
      ,sum(CASE WHEN trx_typ_cd='1184' AND wdw_rvs_ind = 0 THEN 1 ELSE 0 END ) AS inb_creditcard_abroad_consume_cnt
      --线上：暂时未明确
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt


-------------------------------------------
信用卡持有标识
--只要有过信用卡就算申请通过
--有一笔拒绝就算申请被拒绝
--有过申请但不在前两种就算申请未完结
--剩余为从未申请过
select cr_crd_apl_srl_nbr  --信用卡申请流水号
      ,cst_id              --客户号
      ,isu_rsl_cd          --发卡结果代码
      ,case
          when isu_rsl_cd = '00' then '0'  --申请通过
          when isu_rsl_cd = 'XX' then '2'  --申请未完结
          else '1'  --申请失败
      end as isu_rsl
from edw.dwd_bus_crd_cr_crd_apl_inf_dd
where dt = '20211216'
;



------------------------------------------------20211222-----------------------
贷记卡卡级目前未明确的字段
1、进件渠道、进件渠道汇总渠道
 app_rpt.FCT_CRD_CARD_APL_INFO  --信用卡申请表
edw.SFPS_TB_JD_BUINESS_INFO
对应的模型层的表edw.dwd_bus_crd_cr_crd_apl_inf_dd 信用卡申请信息
没有 CHANNEL 、CHANNELIN等字段

2、是否绑定支付宝、是否历史绑定支付宝
  是否绑定第三方、是否历史绑定第三方
第三方的表也不能访问

3、首笔交易的字段
edw.dim_bus_loan_dbil_inf_dd -首刷
表中哪个字段可以和卡号关联 ，因为备用金的表不能用

5、是否开通备用金

以上4个均属于贴源层表未入仓或未完全入仓问题，待换成有权限的账号再落标


4、线上消费笔数 线上消费金额
&quot;线上消费笔数、金额&quot;先不落
添加&quot;支付宝消费笔数、金额&quot;、&quot;财付通消费笔数、金额&quot;  --卡级/账户级/客户级
参考代码：
/*
相同账号下：收单商户编号acptor_id，前5位为原交易时间（是距离19570101的天数，dateadd(day,inp_day,'19570101')），后面为原交易流水号；
与原交易的inp_day交易日期+xtranno流水号进行关联；
全额退货：退货交易的金额=原交易的金额；
部分退货：0<退货交易的金额<原交易的金额；
未退货：非退货交易未关联到相应的退货交易流水。
*/
select a.cr_crd_card_nbr
      ,sum(a.real_amt)
      ,sum(case when a.real_amt > 0 then 1 else 0 end) as trx_num
from (  ) a
group by a.cr_crd_card_nbr
;


select a.cr_crd_card_nbr
      ,(a.trx_amt + coalesce(b.back_amt,0)) as real_amt
      ,a.srl_nbr
from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt >= '20211101' and dt <= '20211220'  --换成自己的日期
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and trx_dscr_1 like '支付宝%'
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,trx_amt as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt >= '20211101' and dt <= '20211220'  --换成自己的日期
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and trx_dscr_1 like '支付宝%'
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd') and a.cr_crd_card_nbr = b.cr_crd_card_nbr
;


按照卡号count流水号，sum金额


--&quot;财付通&quot;：将上述&quot;支付宝&quot;替换成&quot;财付通&quot;即可。



----------------------------------------------20211224  还款----------------------------------
1. 还款方式：自扣还款、非自扣本行渠道还款、非本行渠道还款
select * from edw.ncrd_tran where dt = '20211224' order by rand() limit 20;

2. 还款渠道：手机银行、柜面、网上银行、第三方渠道-支付宝、第三方渠道-微信、第三方渠道-云闪付
select a.account
      ,a.channal
      ,b.cd_val_dscr as channal_desc
      ,a.amount
      ,a.tran_time
      ,a.chan_ser
      ,c.pltnum
      ,gwchnnltp
from edw.frzh_cupd_jrnl a   --银联数据交易大前置流水表，只包含本行渠道
left join (
      select cd_val,cd_val_dscr
      from
      (
      select cd_val,cd_val_dscr,row_number()over(partition by cd_val order by tbl_nm) as rn
      from edw.dwd_code_library
      where cd_nm like '%渠道%'
      and cd_val in ('A01','B02','B05','B18','C01','C03','C10','E09','H12','N08','K04')
      ) p1
      where p1.rn = 1
) b on trim(a.channal) = trim(b.cd_val)
left join edw.epcc_epcc_paysrl c on a.chan_ser = c.pltnum and c.dt = a.dt
where a.dt >= '20211201' and a.dt <= '20211224'
and a.into_flag = 'T' --入账标志 T成功
and a.rvs_flag = 'N'  --冲正标志 N未冲正
and  a.procode in ('470000','47000B','210000','21000B')  --（李佳轩）筛选：还款
;


select * from edw.clpf_f3sv3_saps_serial where functionid in ('970701','970711') and dt >= '20211201' and dt <= '20211224'
jyqd
select jyqd from edw.clpf_f3sv3_saps_serial where functionid in ('970701','970711') and  dt <= '20211224' group by jyqd;

/*
--联网 郭安倩
select trxid,corebknum,oritrxid,oridbtrbankid
from edw.epcc_epcc_paysrl
where dt >= '20211201' and dt <= '20211224'
;

SELECT a.instgid,b.instgnm
from edw.epcc_epcc_paysrl a
left join edw.epcc_epcc_instgidinf b on b.instgid = a.instgid and b.dt = a.dt
where a.dt >= '20201201' and a.dt <= '20211224'
and (b.instgnm like '%支付宝%' or b.instgnm like '%微信%')
group by a.instgid,b.instgnm
;
*/
select des_line1 from edw.ncrd_tran where dt >= '20201201' and dt <= '20211224' and des_line1 like '%还款%' and des_line1 not like '银联%' group by des_line1;

3. 还款类型: 一次性还款-未全额还款、一次性还款-全额还款、循环还款-未全额还款、循环还款-全额还款、提前还款-全额还款、分期还款



----------------------------------------------20211228 还款口径-------------
1. 还款方式：自扣还款、非自扣本行渠道还款、非本行渠道还款
edw.dwd_bus_crd_cr_crd_trx_dtl_di 自扣还款有交易类型的7050    结合下面还款渠道
2. 还款渠道：手机银行、柜面、网上银行、第三方渠道-支付宝、第三方渠道-微信、第三方渠道-云闪付
select card_nbr
      ,inp_date
      ,desc_print
      ,trans_type
      ,des_line1
from edw.ncrd_tran
where dt >= '20211201' and dt <= '20211227'
and rev_ind <> '1'
and trans_type like '7%'  --筛选还款
;

select CR_CRD_CARD_NBR
      ,TRX_DT
      ,TRX_TYP_DSCR
      ,TRX_TYP_CD
      ,TRX_DSCR_1
      ,case
         when TRX_DSCR_1 like '%支付宝%' then '第三方渠道-支付宝'
         when TRX_DSCR_1 like '%柜面%' then '柜面'
         when TRX_DSCR_1 like '%ATM%' then 'ATM'
         when TRX_DSCR_1 like '%网银%' then '网上银行'
         when (TRX_DSCR_1 like '%手机银行%' or TRX_TYP_DSCR like '%手机银行%') then '手机银行'
         else '其他' end as qudao
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt >= '20211201' and dt <= '20211225'
and WDW_RVS_IND <> '1'
and TRX_TYP_CD like '7%'
and TRX_DSCR_1 like '%支付宝%'
;

3. 还款类型: 一次性还款-未全额还款、一次性还款-全额还款、循环还款-未全额还款、循环还款-全额还款、提前还款-全额还款、分期还款

-- 1. 还款方式
-- 待业务确认如何判断 自扣
select * from edw.ncrd_tran where dt >= '20211201' and dt <= '20211227' and rev_ind <> '1' and trans_type like '7%';
-- 2. 还款渠道
-- 待业务确认是否不要微信、云闪付，其他如何归类
select card_nbr
      ,inp_date
      ,desc_print
      ,trans_type
      ,des_line1
from edw.ncrd_tran
where dt >= '20211201' and dt <= '20211227'
and rev_ind <> '1'
and trans_type like '7%'  --筛选还款
;
-- 3. 还款类型
-- 结合：还款金额和账单金额来做
select cr_crd_act_id
      ,rpay_amt
      ,bil_day
      ,pmt_day  --付款日
from edw.dwd_bus_crd_cr_crd_bil_inf_di
where dt >= '20210101' and dt <= '20211227'  --还款金额
;

----------------------------------------------20211229 还款口径-------------
1. 还款方式：自扣还款、非自扣本行渠道还款、非本行渠道还款
2. 还款渠道：手机银行、柜面、网上银行、第三方渠道-支付宝、第三方渠道-微信、第三方渠道-云闪付
3. 还款类型: 一次性还款-未全额还款、一次性还款-全额还款、循环还款-未全额还款、循环还款-全额还款、提前还款-全额还款、分期还款

1. 还款方式：自扣还款、非自扣本行渠道还款、非本行渠道还款
2. 还款渠道：手机银行、柜面、网上银行、第三方渠道-支付宝、第三方渠道-银联在线、第三方渠道-财付通
drop table if exists lab_bigdata_dev.xt_024618_tmp_repay_1230;
create table if not exists lab_bigdata_dev.xt_024618_tmp_repay_1230 as
select cr_crd_card_nbr
      ,cr_crd_act_id
      ,trx_dt
      ,trx_typ_cd
      ,trx_tlr
      ,trx_dscr_1
      ,case when trx_dscr_1 like '支付宝%' then '第三方渠道-支付宝'
            when trx_dscr_1 like '财付通%' then '第三方渠道-财付通'
            when trx_typ_cd = 7028 then '第三方渠道-银联在线'
            when trx_typ_cd in (7000,7012,7020,7030,7036,7050,7054,7056,7062,7086,7092,7094,7096,7400) then '柜面'
            when trx_typ_cd in (7010,7040,7060,7080,7082,7084) then 'ATM'
            when (trx_tlr like '%SJG%' or trx_tlr like '%SJGY%') then '手机银行'
            when (trx_tlr like '%WYGY%' or trx_tlr like '%WYG%') then '网上银行'
            else '' end as chann_repay
      ,case when (trx_typ_cd >= 7000 and trx_typ_cd <= 7099 and trx_typ_cd not in (7002,7056) or trx_typ_cd = 7400) then '自扣还款'
            when (trx_typ_cd > 7099 and trx_typ_cd <> 7400 or trx_typ_cd in (7002,7056)) and
                  ((trx_typ_cd = 7000 and trx_tlr not like '%XYGY%') or  trx_typ_cd in (7002,7010,7012,7024,7036,7040,7050,7054,7056,7060,7062,7070,7400)) then '非自扣本行渠道'
            when (trx_typ_cd > 7099 and trx_typ_cd <> 7400 or trx_typ_cd in (7002,7056)) and
                 ((trx_typ_cd = 7000 and trx_tlr like '%XYGY%') or  trx_typ_cd in (7020,7028,7030,7032,7076,7080,7082,7084,7092,7094,7096)) then '非本行渠道还款'
            else '' end as method_repay
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt >= '20201201' and dt <= '20211228' --改成自己日期
and trx_dt >= '20201201' and trx_dt <= '20211228'   --改成自己日期
and trx_typ_cd >= 7000 and trx_typ_cd <= 7999  --筛选：还款
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
;

select * from lab_bigdata_dev.xt_024618_tmp_repay_1230 where trx_typ_cd = 7000 and trx_tlr not like '%XYGY%'; --应该是&ldquo;柜面&rdquo;、&ldquo;非自扣本行渠道&rdquo;
select trx_typ_cd,chann_repay,method_repay from lab_bigdata_dev.xt_024618_tmp_repay_1230 group by trx_typ_cd,chann_repay,method_repay;
select * from lab_bigdata_dev.xt_024618_tmp_repay_1230 order by rand() limit 1000;
select * from edw.dwd_bus_crd_cr_crd_trx_dtl_di where dt >= '20180101' and dt <= '20211228' and trx_typ_cd = 7400;

3. 还款类型: 一次性还款-未全额还款、一次性还款-全额还款、循环还款-未全额还款、循环还款-全额还款、提前还款-全额还款、分期还款



-------------------------------------------------- 20211231 下午 tran表中交易-是否全额退货 -------------------
-- tran表中是银联的原始字段，有问题。下面是开发的逻辑（阚庆 W50792）
-- DROP TABLE IF EXISTS ${odps_adm_pub}.TMP_ADM_IND_CST_RTN_GDS_TRX ;
-- CREATE TABLE IF NOT EXISTS ${odps_adm_pub}.TMP_ADM_IND_CST_RTN_GDS_TRX
--           (
--                    CST_ID            STRING  COMMENT '客户号'
--                   ,CR_CRD_ACT_ID     STRING  COMMENT '信用卡账号'
--                   ,DAY_ID            STRING  COMMENT '交易日期'
--                   ,SRL_NBR           STRING COMMENT '交易流水'
--                   ,ACQ_MCH_ENC       STRING  COMMENT '收单商户编号'
--                   ,TRX_AMT           DECIMAL COMMENT '交易金额'
--                  -- ,DT                STRING  COMMENT '日期范围参数'
--           )
--           COMMENT  '信用卡所有客户退货交易临时表';

-- INSERT INTO ${odps_adm_pub}.TMP_ADM_IND_CST_RTN_GDS_TRX
drop table if exists lab_bigdata_dev.xt_tmp_024618_daijika_trx_kaifa;
create table if not exists lab_bigdata_dev.xt_tmp_024618_daijika_trx_kaifa
        SELECT A.CST_ID
              ,B.CR_CRD_ACT_ID
              ,TO_CHAR(TO_DATE(SUBSTR(DATEADD(TO_DATE('19570101','YYYYMMDD'),CAST(REGEXP_REPLACE( SUBSTR(B.ACQ_MCH_ENC,1,5), '[a-z]|[A-Z]','0')  AS INT),'DD'),1,10) ,'YYYY-MM-DD'),'YYYYMMDD') AS DAY_ID
              ,SUBSTR(B.ACQ_MCH_ENC,6) AS SRL_NBR
              ,B.ACQ_MCH_ENC
              ,SUM(ABS(B.TRX_AMT)) AS TRX_AMT
              --,B.DT
        FROM
        edw.DWS_BUS_CRD_CR_CRD_ACT_INF_DD A  --信用卡账户信息汇总
        INNER JOIN
        edw.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI B  --信用卡客户交易流水
          ON  B.CR_CRD_ACT_ID  = A.CR_CRD_ACT_ID
        AND B.TRX_TYP_CD LIKE '6%'
        AND B.TRX_TYP_CD      NOT IN  ('6050','6052')
        AND B.WDW_RVS_IND <> '1'
        AND COALESCE(TRIM(B.ACQ_MCH_ENC),'0') <> '0' --收单商户编码不为空
        AND B.DT <= '@@{yyyyMMdd}'
        AND B.DT >= '@@{yyyyMMdd -179d}'
   WHERE A.DT = '@@{yyyyMMdd}'
   GROUP BY  A.CST_ID,B.CR_CRD_ACT_ID
              ,TO_CHAR(TO_DATE(SUBSTR(DATEADD(TO_DATE('19570101','YYYYMMDD'),CAST(REGEXP_REPLACE( SUBSTR(B.ACQ_MCH_ENC,1,5), '[a-z]|[A-Z]','0')  AS INT),'DD'),1,10) ,'YYYY-MM-DD'),'YYYYMMDD')
              ,SUBSTR(B.ACQ_MCH_ENC,6) ,B.ACQ_MCH_ENC  ;



-- 核对一下开发的口径与我们的口径有无区别
drop table if exists lab_bigdata_dev.xt_tmp_024618_daijika_trx;
create table if not exists lab_bigdata_dev.xt_tmp_024618_daijika_trx as
select a.cr_crd_card_nbr
      ,(a.trx_amt + coalesce(b.back_amt,0)) as real_amt
      ,a.trx_amt
      ,b.back_amt
      ,a.srl_nbr
from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt >= '20211101' and dt <= '20211220'  --换成自己的日期
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and trx_dscr_1 like '支付宝%'
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,sum(trx_amt) as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt >= '20211101' and dt <= '20211220'  --换成自己的日期
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and trx_dscr_1 like '支付宝%'
      group by cr_crd_card_nbr,srl_nbr,trx_dt,acq_mch_enc
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd') and a.cr_crd_card_nbr = b.cr_crd_card_nbr
;

select * from lab_bigdata_dev.xt_tmp_024618_daijika_trx;


---------------------------------20220105 还款类型 -------------------------
还款类型: 一次性还款-未全额还款、一次性还款-全额还款、循环还款-未全额还款、循环还款-全额还款、提前还款-全额还款、分期还款
select
from edw.dwd_bus_crd_cr_crd_trx_dtl_di a --信用卡客户交易流水
left join edw.dwd_bus_crd_cr_crd_bil_inf_di b on b.cr_crd_act_id = a.cr_crd_act_id and b.dt = a.dt --信用卡账单信息


select dt,count(*),bil_mon,bil_day
from edw.dwd_bus_crd_cr_crd_bil_inf_di
where dt >= '20210904' and dt <= '20211204'
group by dt,bil_mon,bil_day
;


-- 取上一账单日账单金额
-- 每月只有一天有数据
select cr_crd_act_id  --信用卡账号
      ,bil_mon        --账单月数
      ,rpay_amt       --还款金额
      ,lag(rpay_amt,1,0)over(partition by cr_crd_act_id order by bil_mon) as rpay_amt_lag1
      ,dt
from edw.dwd_bus_crd_cr_crd_bil_inf_di
where dt >= '20201231' and dt <= '20211231'
order by cr_crd_act_id,bil_mon;

-- 账户在
select bank	银行号
,category 账户类别
,stmt_days 账单宽限期
,proc_days 还款宽限期
,pc_no_int 本币不计息欠款金额
,cate_desc 账户类别描述
from edw.ncrd_prmcn
where dt = '20220104'


ncrd_stmt

---------------------------------20220106 还款类型 -------------------------
-- 1.验证账单表里哪个字段是账单金额：期末余额
select a.cr_crd_act_id
      ,a.last_rpay_dt  --上次还款日期
      ,a.bin_sng_day   --帐单日
      ,a.late_bil_amt  --最近一期帐单金额
      ,b.pmt_day  --付款日
      ,b.end_tm_bal  --期末余额
      ,b.non_dlv_bil_adj_entr_amt
      ,b.ovr_bil_rtn_gds_amt
      ,b.dt
from edw.dim_bus_crd_cr_crd_act_inf_dd a
left join edw.dwd_bus_crd_cr_crd_bil_inf_di b on a.cr_crd_act_id = b.cr_crd_act_id and b.dt >= '20210101' and b.dt <= '20211231'
where a.dt = '20211231'
and a.cr_crd_act_id in ('0000100141','0000100018','0000100271','0000100302')
order by a.cr_crd_act_id,b.dt
;


TO_CHAR(DATEADD(DATEADD(TO_DATE(concat('20', A.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD')

-- 2.根据最近一次还款日期推算出最近一次的上一个账单日、账单金额
-- 存在 上一次还款日期=18991231
select t1.cr_crd_act_id
      ,t1.last_rpay_dt --上次还款日期
      ,t1.late_bil_amt  --最近一期帐单金额
      ,t1.上一账单日
      ,t2.dt  --上一账单日
      ,t2.end_tm_bal  --期末余额
from (
select a.cr_crd_act_id
      ,a.last_rpay_dt  --上次还款日期
      ,a.late_bil_amt  --最近一期帐单金额
      ,case when substr(a.last_rpay_dt,5,2)<> '03' then dateadd(to_date(concat(substr(a.last_rpay_dt,1,6),'30'),'yyyyMMdd'),-1,'mm')
            else dateadd(to_date(concat(substr(a.last_rpay_dt,1,6),'28'),'yyyyMMdd'),-1,'mm')
      end as 上一账单日
from edw.dim_bus_crd_cr_crd_act_inf_dd a  --信用卡账户信息
where a.dt = '20220105'
) t1
left join edw.dwd_bus_crd_cr_crd_bil_inf_di t2 on t1.cr_crd_act_id = t2.cr_crd_act_id and t1.上一账单日 = to_date(t2.dt,'yyyyMMdd') and t2.dt <= '20220105'
;

select *
from edw.dwd_bus_crd_cr_crd_bil_inf_di
where dt <= '20220105'
and cr_crd_act_id in ('0000100480','0001100723') --前一个账号最近还款日期为20210207，后一个账号为18991231，都没有匹配上账单表

select dt
from edw.dwd_bus_crd_cr_crd_bil_inf_di
where dt >= '20210101' and dt <= '20211231'
group by dt
;


-- 1.验证是否每个账号上一个账单日是否一致：不一致
select cr_crd_act_id
      ,max(dt) as last_crd_dt --上一个账单日
from edw.dwd_bus_crd_cr_crd_bil_inf_di --账单表
where dt <= '20220105'
group by cr_crd_act_id
order by cr_crd_act_id
;

-- 2.加工出每一个账号上一个账单日的账单金额
select a.cr_crd_act_id
      ,a.last_crd_dt  --上一个账单日
      ,b.end_tm_bal   --上一个账单金额：0和负值
from
(
      select cr_crd_act_id
            ,max(dt) as last_crd_dt --上一个账单日
      from edw.dwd_bus_crd_cr_crd_bil_inf_di --账单表
      where dt <= '20220105'
      group by cr_crd_act_id
) a
left join edw.dwd_bus_crd_cr_crd_bil_inf_di b on b.cr_crd_act_id = a.cr_crd_act_id and b.dt = a.last_crd_dt and b.dt <= '20220105'
order by a.cr_crd_act_id
;

-- 3.关联上流水表
select a.cr_crd_act_id
      ,a.last_crd_dt  --上一个账单日
      ,b.end_tm_bal   --上一个账单金额：0和负值
from
(
      select cr_crd_act_id  --信用卡账号
            ,max(dt) as last_crd_dt --上一个账单日
      from edw.dwd_bus_crd_cr_crd_bil_inf_di --账单表
      where dt <= '20220105'
      group by cr_crd_act_id
) a
left join edw.dwd_bus_crd_cr_crd_bil_inf_di b on b.cr_crd_act_id = a.cr_crd_act_id and b.dt = a.last_crd_dt and b.dt <= '20220105'


select distinct dt,bil_day from edw.dwd_bus_crd_cr_crd_bil_inf_di where dt >= '20210101' and dt <= '20220106';
select * from edw.ncrd_prmcn where dt = '20220106'; --
select bin_sng_day from edw.dim_bus_crd_cr_crd_act_inf_dd where dt = '20220106';


------------------------------------------------------------------------------ 20220107下午------------------------------
-- 还款类型：上一账单账单日
select a.cr_crd_act_id
      ,a.late_bil_amt --最近一期帐单金额
      ,a.lst_sng_day  --上一个账单日
      ,b.stmt_days    --账单宽限期
      ,b.proc_days      --还款宽限期
      ,a.lst_sng_day + b.stmt_days as 还款日
      ,a.lst_sng_day + b.proc_days as 加了宽限期的还款日
from (
select cr_crd_act_id
      ,act_ctg
      ,dt
      ,late_bil_amt   --最近一期帐单金额
      -- ,to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'yyyyMMdd') --取当月最后一天
      -- ,to_char(lastday(dateadd(to_date(a.dt,'yyyyMMdd'),-1,'mm')),'yyyyMMdd') --取上个月最后一天
      -- ,substr(to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'YYYYMMDD'),7,2)  --取当月最后一天日期
      ,case when substr(a.dt,7,2) = bin_sng_day then a.dt    --当正好是账单日那天
            when substr(a.dt,7,2) > bin_sng_day then  concat(substr(a.dt,1,6),bin_sng_day)
            when substr(a.dt,7,2) < bin_sng_day
                 then case when substr(a.dt,5,2) = '02' and a.dt = to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'yyyyMMdd') then to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'yyyyMMdd')  --当dt为2月最后一天时，账单日就是当天
                           when substr(a.dt,5,2) = '02' and a.dt <> to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'yyyyMMdd') then concat(substr(to_char(dateadd(to_date(a.dt,'yyyyMMdd'),-1,'mm'),'yyyymmdd'),1,6),bin_sng_day)
                           when substr(a.dt,5,2) = '03' then to_char(lastday(dateadd(to_date(a.dt,'yyyyMMdd'),-1,'mm')),'yyyyMMdd')
                           else concat(substr(to_char(dateadd(to_date(a.dt,'yyyyMMdd'),-1,'mm'),'yyyymmdd'),1,6),bin_sng_day)
                  end
            end as lst_sng_day  --最近一个账单日
from edw.dim_bus_crd_cr_crd_act_inf_dd a
where dt >= '20210101' and dt <= '20220106'
and cr_crd_act_id = '0000100018'
) a left join edw.ncrd_prmcn b on a.act_ctg = b.category and b.dt =a.dt   --此表未入模
order by a.dt
;

select cr_crd_act_id from edw.dim_bus_crd_cr_crd_act_inf_dd where dt = '20220101'

--------------------------------------------- 20220107 贷记卡RFM值 ----------------------
添加：
1. 参照&ldquo;支付宝消费笔数/金额&rdquo;,剔除消费中的全额退货
2. 筛选为：贷记卡
信用卡交易R值参考代码
select t1.cst_id
      ,t1.cr_crd_act_id
	,CASE WHEN min(CASE WHEN  a.trx_dt IS NOT NULL
						THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END) IS NOT NULL
		  THEN min(CASE WHEN a.trx_dt IS NOT NULL
					   THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END)
		  ELSE '无交易' END AS  cst_cc_recent_to_now --12.客户信用卡交易近度

	,CASE WHEN min(CASE WHEN a.TRX_TYP_CD >= '1000' AND a.TRX_TYP_CD <= '1999' AND a.TRX_TYP_CD <> '1050' AND a.trx_dt IS NOT NULL
						THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END) IS NOT NULL
		  THEN min(CASE WHEN a.TRX_TYP_CD >= '1000' AND a.TRX_TYP_CD <= '1999' AND a.TRX_TYP_CD <> '1050' AND a.trx_dt IS NOT NULL
					   THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END)
		  ELSE '无交易' END AS  cst_cc_csm_recent_to_now  --13.客户信用卡消费交易近度

	,CASE WHEN min(CASE WHEN a.TRX_TYP_CD >= '2000' AND a.TRX_TYP_CD <= '2999' AND a.trx_dt IS NOT NULL
						THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END) IS NOT NULL
		 THEN min(CASE WHEN a.TRX_TYP_CD >= '2000' AND a.TRX_TYP_CD <= '2999' AND a.trx_dt IS NOT NULL
					   THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END)
		  ELSE '无交易' END AS  cst_cc_csh_recent_to_now  --14.客户信用卡取现/转出交易近度

	,CASE WHEN min(CASE WHEN a.TRX_TYP_CD in ('8130' , '8130' , '8950' , '8952' , '8952' , '8954' , '8954' , '8956' , '8958' , '8958') AND a.trx_dt IS NOT NULL
						THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END) IS NOT NULL
		  THEN min(CASE WHEN a.TRX_TYP_CD in ('8130' , '8130' , '8950' , '8952' , '8952' , '8954' , '8954' , '8956' , '8958' , '8958') AND a.trx_dt IS NOT NULL
					   THEN DATEDIFF(TO_DATE('20220106', 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd') + 1 ELSE NULL END)
		  ELSE '无交易' END AS  cst_cc_instl_recent_to_now --15.客户信用卡分期交易近度
from edw.dws_bus_crd_cr_crd_act_inf_dd t1
left join  edw.dwd_bus_crd_cr_crd_trx_dtl_di a --信用卡账户信息汇总
on a.cr_crd_act_id =t1.cr_crd_act_id
and a.dt <= '20220106'
where t1.dt = '20220106'
and a.trx_dt<='20220106'
and a.wdw_rvs_ind <> '1'
and a.TRX_TYP_CD IN (
 --消费
 '1000' , '1000' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1016' , '1016' , '1020' , '1020'
 ,'1030' , '1040' , '1110' , '1110' , '1112' , '1120' , '1120' , '1122' , '1123' , '1123' , '1180' , '1180' , '1184' , '1184'
 --消费人工
 , '8100' , '8104'
 --取现/转出
 ,'2000' , '2000' , '2000' , '2010' , '2010' , '2010'
 , '2010' , '2010' , '2010' , '2012' , '2012' , '2040' , '2042' , '2046' , '2046' , '2046' , '2048' , '2050' , '2050' , '2060' , '2060' , '2070' , '2070' , '2072' , '2072'
 , '2090' , '2092' , '2092' , '2094' , '2094' , '2098' , '2098' , '2100' , '2100' , '2104' , '2106' , '2106' , '2110' , '2110' , '2122' , '2123' , '2123' , '2140' , '2140'
 , '2142' , '2142' , '2144' , '2144' , '2150' , '2150' , '2154' , '2154' , '2160' , '2160' , '2170' , '2170' , '2172' , '2172' , '2174' , '2174' , '2180' , '2182' , '2182'
 , '2184' , '2300' , '2310' , '2312' , '2340' , '2342' , '2346' , '2350' , '2360' , '2370' , '2372' , '2398' , '2400' , '2404' , '2406' , '2410' , '2422' , '2423' , '2440'
 , '2442' , '2444' , '2450' , '2460' , '2470' , '2472' , '2474' , '2480' , '2482' , '2484'
 --取现人工
 , '8110' , '8112' , '8114' , '8116'
 --分期
 , '8130' , '8130' , '8950'
 , '8952' , '8952' , '8954' , '8954' , '8956' , '8958' , '8958' ) --消费 分期 取现 转出
group by t1.cst_id,t1.cr_crd_act_id;



SELECT  A.date_now
        ,A.cr_crd_act_id
        ,min(a.trx_dt) AS act_fir_trx_dt --1.信用卡账户首笔支付交易日期
        ,max(a.trx_dt) AS act_recent_trx_dt --4.信用卡账户最近一笔支付交易的交易日期
		,case when min(CASE WHEN a.trx_dt IS NOT NULL THEN DATEDIFF(TO_DATE(a.date_now, 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd')+1 ELSE null END) is not null
			  then min(CASE WHEN a.trx_dt IS NOT NULL THEN DATEDIFF(TO_DATE(a.date_now, 'yyyymmdd'), TO_DATE(a.trx_dt, 'yyyymmdd'), 'dd')+1 ELSE null END)
			  else '无交易' end AS act_recent_to_now --10.信用卡账户交易近度
        ,a.cst_id
FROM    lab_risk_dev.cr_crd_trx_dtl_act_di_20210331 a --账户级别样本
WHERE   a.trx_dt <= a.date_now
AND     a.TRX_TYP_CD IN ( '1000' , '1000' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1010' , '1016' , '1016' , '1020' , '1020' , '1030' , '1040' , '1110' , '1110' , '1112' , '1120' , '1120' , '1122' , '1123' , '1123' , '1180' , '1180' , '1184' , '1184' , '2000' , '2000' , '2000' , '2010' , '2010' , '2010' , '2010' , '2010' , '2010' , '2012' , '2012' , '2040' , '2042' , '2046' , '2046' , '2046' , '2048' , '2050' , '2050' , '2060' , '2060' , '2070' , '2070' , '2072' , '2072' , '2090' , '2092' , '2092' , '2094' , '2094' , '2098' , '2098' , '2100' , '2100' , '2104' , '2106' , '2106' , '2110' , '2110' , '2122' , '2123' , '2123' , '2140' , '2140' , '2142' , '2142' , '2144' , '2144' , '2150' , '2150' , '2154' , '2154' , '2160' , '2160' , '2170' , '2170' , '2172' , '2172' , '2174' , '2174' , '2180' , '2182' , '2182' , '2184' , '2300' , '2310' , '2312' , '2340' , '2342' , '2346' , '2350' , '2360' , '2370' , '2372' , '2398' , '2400' , '2404' , '2406' , '2410' , '2422' , '2423' , '2440' , '2442' , '2444' , '2450' , '2460' , '2470' , '2472' , '2474' , '2480' , '2482' , '2484' , '8100' , '8104' , '8110' , '8112' , '8114' , '8116' , '8130' , '8130' , '8950' , '8952' , '8952' , '8954' , '8954' , '8956' , '8958' , '8958' ) --消费 分期 取现 转出
GROUP BY A.date_now , A.cr_crd_act_id , a.cst_id;




SELECT   A.CR_CRD_CARD_NBR
        ,B.CST_ID
        ,A.RCD_DT  -----分期交易发生日期
        ,COUNT(1) CC_STAGE_CNT  ----信用卡分期笔数,
        ,SUM(A.TOT_PD_AMT) CC_STAGE_AMT ----信用卡分期发生额,
FROM    edw.dwd_bus_crd_cr_crd_instl_dtl_dd A
LEFT JOIN    EDW.DIM_BUS_CRD_CR_CRD_INF_DD B
ON      B.CR_CRD_CARD_NBR = A.CR_CRD_CARD_NBR
AND     B.DT = '20220107'
WHERE   A.DT = '20220107'
GROUP BY A.CR_CRD_CARD_NBR,B.CST_ID , A.RCD_DT;


--------------------------------------------------------------20220113 信用卡还款类型 --------------------------------------
1.  0＜客户在上一账单日次日至本月宽限期日未撤销、未冲正的主动还款交易金额＜账单金额
主动还款交易金额 在交易表里全是负值
信用卡账户信息表edw.dim_bus_crd_cr_crd_act_inf_dd中最近一期账单金额有=0，>0，<0的

2.  本账单期 具体是什么期，账单日次日至本月还款日前，还是账单日次日至本月宽限期日前

SELECT cr_crd_card_nbr
      ,trx_amt
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt >= '20211001' and dt <= '20220101'
and wdw_rvs_ind <> '1'
and (trx_typ_cd >= 7000 and trx_typ_cd <= 7099 and trx_typ_cd not in (7002,7056) or trx_typ_cd = 7400)  --筛选主动还款
and trx_amt > 0
;

select a.cr_crd_act_id
      ,a.late_bil_amt --最近一期帐单金额
      ,a.lst_sng_day  --上一个账单日
      ,b.stmt_days    --账单宽限期
      ,b.proc_days      --还款宽限期
      ,a.lst_sng_day + b.stmt_days as 还款日
      ,a.lst_sng_day + b.proc_days as 加了宽限期的还款日
from (
select cr_crd_act_id
      ,act_ctg
      ,dt
      ,late_bil_amt   --最近一期帐单金额
      ,case when substr(a.dt,7,2) = bin_sng_day then a.dt    --当正好是账单日那天
            when substr(a.dt,7,2) > bin_sng_day then  concat(substr(a.dt,1,6),bin_sng_day)
            when substr(a.dt,7,2) < bin_sng_day
                 then case when substr(a.dt,5,2) = '02' and a.dt = to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'yyyyMMdd') then to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'yyyyMMdd')  --当dt为2月最后一天时，账单日就是当天
                           when substr(a.dt,5,2) = '02' and a.dt <> to_char(LASTDAY(to_date(a.dt,'yyyyMMdd')),'yyyyMMdd') then concat(substr(to_char(dateadd(to_date(a.dt,'yyyyMMdd'),-1,'mm'),'yyyymmdd'),1,6),bin_sng_day)
                           when substr(a.dt,5,2) = '03' then to_char(lastday(dateadd(to_date(a.dt,'yyyyMMdd'),-1,'mm')),'yyyyMMdd')
                           else concat(substr(to_char(dateadd(to_date(a.dt,'yyyyMMdd'),-1,'mm'),'yyyymmdd'),1,6),bin_sng_day)
                  end
            end as lst_sng_day  --最近一个账单日
from edw.dim_bus_crd_cr_crd_act_inf_dd a
where dt = '20220106'
) a left join edw.ncrd_prmcn b on a.act_ctg = b.category and b.dt =a.dt   --此表未入模



select cr_crd_act_id
      ,late_bil_amt
from edw.dim_bus_crd_cr_crd_act_inf_dd
where dt = '20220110'
and late_bil_amt > 0
;

-----------------------------------------------20220113 申请日期为18991231-------------------
-- 过滤掉申请日期为18991231的数据，再计算最早一笔申请日期；
SELECT  T1.CST_ID
        ,T1.cr_crd_pd_id
        ,T1.apl_dt
      --   ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
FROM    edw.dwd_bus_crd_cr_crd_apl_inf_dd T1
-- LEFT JOIN    WB_BIGDATA_MANAGER_DEV.DIM_CR_CRD_PD_LJQ T2 --信用卡产品信息   --表名需要修改
-- ON      T1.CR_CRD_PD_ID = T2.PD_CD
WHERE   T1.DT = '20211205'
ORDER BY CST_ID

select *
from edw.dwd_bus_crd_cr_crd_apl_inf_dd
where dt = '20220110'
and cst_id = '1009347538'
and apl_dt = '18991231'

select * from edw.loan_creditcard_apply where dt = '20220110' and customerid  = '1009347538';


-----------------------------------------------------------20220114 重新加工上一个账单日、下一个账单日
上一个账单日次日至下一个账单日即为本账单期
SELECT T1.CR_CRD_ACT_ID --账户账号
      ,T1.ACT_CTG       --账户类别
      ,T1.DT            --DT
      ,T1.LATE_BIL_DEAL_DAY   --最近一期帐单处理日
      ,T1.LST_SNG_DAY         --上一个账单日
      ,T1.NEXT_SNG_DAY        --下一个账单日
      ,CASE WHEN LATE_BIL_DEAL_DAY < LST_SNG_DAY THEN 0 ELSE LATE_BIL_AMT END AS LATE_BIL_AMT --上一个账单金额：有正有负
      ,T2.STMT_DAYS  --账单宽限期
      ,T2.PROC_DAYS  ----还款宽限期
      ,TO_CHAR(DATEADD(TO_DATE(T1.LST_SNG_DAY,'yyyyMMdd'),T2.STMT_DAYS,'dd'),'yyyyMMdd') AS 还款日
      ,TO_CHAR(DATEADD(TO_DATE(T1.LST_SNG_DAY,'yyyyMMdd'),T2.PROC_DAYS,'dd'),'yyyyMMdd') AS 加了宽限期的还款日
FROM (
SELECT CR_CRD_ACT_ID  --账户账号
      ,ACT_CTG        --账户类别
      ,DT
      ,LATE_BIL_DEAL_DAY  --最近一期帐单处理日
      ,LATE_BIL_AMT       --最近一期帐单金额
      ,CASE WHEN SUBSTR(DT,7,2) >= BIN_SNG_DAY THEN CONCAT(SUBSTR(DT,1,6),BIN_SNG_DAY)  --若为账单日之后，则为本月账单日
            WHEN SUBSTR(DT,7,2) < BIN_SNG_DAY  THEN
                  CASE WHEN SUBSTR(DT,5,2) = '02' AND DT = TO_CHAR(LASTDAY(TO_DATE(DT,'yyyyMMdd')),'yyyyMMdd') THEN TO_CHAR(LASTDAY(TO_DATE(DT,'yyyyMMdd')),'yyyyMMdd')
                       WHEN SUBSTR(DT,5,2) = '02' AND DT < TO_CHAR(LASTDAY(TO_DATE(DT,'yyyyMMdd')),'yyyyMMdd') THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(DT,'yyyyMMdd'),-1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)
                       WHEN SUBSTR(DT,5,2) = '03' THEN TO_CHAR(LASTDAY(DATEADD(TO_DATE(DT,'yyyyMMdd'),-1,'MM')),'yyyyMMdd')  --若为0301-0329，则为2月最后一天
                       WHEN SUBSTR(DT,5,2) <> '03' THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(DT,'yyyyMMdd'),-1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)  --
                  END
      END AS LST_SNG_DAY  --上一个账单日
      ,CASE WHEN SUBSTR(DT,5,2) = '01' AND SUBSTR(DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(DT,1,6),BIN_SNG_DAY)  --若为1月30之前，则下一个账单日在0130
            WHEN SUBSTR(DT,5,2) = '01' AND SUBSTR(DT,7,2) >= BIN_SNG_DAY THEN TO_CHAR(LASTDAY(DATEADD(TO_DATE(CONCAT(SUBSTR(DT,1,6),'01'),'yyyyMMdd'),1,'MM')),'yyyyMMdd')  --若为0130,0131，则为2月最后一天
            WHEN SUBSTR(DT,5,2) = '02' AND DT < TO_CHAR(LASTDAY(TO_DATE(DT,'yyyyMMdd')),'yyyyMMdd') THEN TO_CHAR(LASTDAY(TO_DATE(DT,'yyyyMMdd')),'yyyyMMdd') --若为2月最后一天之前，则为2月最后一天
            WHEN SUBSTR(DT,5,2) = '02' AND DT = TO_CHAR(LASTDAY(TO_DATE(DT,'yyyyMMdd')),'yyyyMMdd') THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY) --若为2月最后一天，则为3月30
            WHEN SUBSTR(DT,5,2) NOT IN ('01','02') AND SUBSTR(DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(DT,1,6),BIN_SNG_DAY)
            WHEN SUBSTR(DT,5,2) NOT IN ('01','02') AND SUBSTR(DT,7,2) >= BIN_SNG_DAY THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)
      END AS NEXT_SNG_DAY  --下一个账单日
FROM EDW.DIM_BUS_CRD_CR_CRD_ACT_INF_DD
WHERE DT = '20220112'
) T1
LEFT JOIN EDW.NCRD_PRMCN T2 ON T1.ACT_CTG = T2.CATEGORY AND T2.DT = T1.DT
;

-------------------------------------------------------------- 20220117 近12个月还款类型 已调整完毕------------------------------------------------------------------------
-- 近12个月的账单日与下一个账单日
--获取还款日、宽限期
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_10;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_10 AS
SELECT T1.CR_CRD_ACT_ID
      ,T2.DT   SNG_DAY        --近12个月账单日
      ,CASE WHEN SUBSTR(T2.DT,5,2) = '01' AND SUBSTR(T2.DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(T2.DT,1,6),BIN_SNG_DAY)  --若为1月30之前，则下一个账单日在0130
            WHEN SUBSTR(T2.DT,5,2) = '01' AND SUBSTR(T2.DT,7,2) >= BIN_SNG_DAY THEN TO_CHAR(LASTDAY(DATEADD(TO_DATE(CONCAT(SUBSTR(T2.DT,1,6),'01'),'yyyyMMdd'),1,'MM')),'yyyyMMdd')  --若为0130,0131，则为2月最后一天
            WHEN SUBSTR(T2.DT,5,2) = '02' AND T2.DT < TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') THEN TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') --若为2月最后一天之前，则为2月最后一天
            WHEN SUBSTR(T2.DT,5,2) = '02' AND T2.DT = TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY) --若为2月最后一天，则为3月30
            WHEN SUBSTR(T2.DT,5,2) NOT IN ('01','02') AND SUBSTR(T2.DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(T2.DT,1,6),BIN_SNG_DAY)
            WHEN SUBSTR(T2.DT,5,2) NOT IN ('01','02') AND SUBSTR(T2.DT,7,2) >= BIN_SNG_DAY THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)
      END AS NEXT_SNG_DAY  --下一个账单日
      ,COALESCE(ROUND(T2.END_TM_BAL,2),0) BIL_AMT  --期末余额（账单金额）
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), 1, 'DD'), 'YYYYMMDD')  LST_SNG_DAY_2  ----近12个月账单日次日
      ,T3.STMT_DAYS    --账单宽限期
      ,T3.PROC_DAYS      --还款宽限期
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), STMT_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_STMT_DAYS --还款日
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), PROC_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_PROC_DAYS --加了宽限期的还款日
from EDW.DIM_BUS_CRD_CR_CRD_ACT_INF_DD t1  --信用卡账户信息
left join EDW.DWD_BUS_CRD_CR_CRD_BIL_INF_DI t2  --信用卡账单信息
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(T2.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 365
LEFT JOIN EDW_NCRD_PRMCN T3 ON T1.ACT_CTG = T3.CATEGORY AND T1.DT =T3.DT  --产品参数表
WHERE T1.DT = '@@{yyyyMMdd}'
AND T2.DT IS NOT NULL
AND  ((TRX_TYP_CD >=7000 AND TRX_TYP_CD<=7099 ) OR TRX_TYP_CD IN(7400,1050) OR (TRX_TYP_CD >= 1000 AND TRX_TYP_CD <= 2999) )
order by CR_CRD_ACT_ID,SNG_DAY
;
select * from lab_bigdata_dev.xt_cst_024618_01;
select * from lab_bigdata_dev.xt_cst_024618_02;


-- 每个当期账单期间的交易
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_11;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_11 AS
select T1.*
      ,T2.TRX_TYP_CD
      ,T2.TRX_AMT
      ,T2.WDW_RVS_IND
      ,T2.TRX_DSCR_1
      ,T2.TRX_DT
      ,T2.TRX_TM
FROM WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_10 T1
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI T2 ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID AND T2.DT >= T1.LST_SNG_DAY_2
AND T2.DT <= T1.NEXT_SNG_DAY AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(T2.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 365
;

select * from lab_bigdata_dev.xt_cst_024618_02 order by CR_CRD_ACT_ID,SNG_DAY,TRX_DT;
select cr_crd_act_id,trx_dt from edw.dwd_bus_crd_cr_crd_trx_dtl_di where  dt >= '20210110' and dt <= '20220116' and cr_crd_act_id = '0000100003';
select * from lab_bigdata_dev.xt_cst_024618_02 where cr_crd_act_id = '0000100003' order by CR_CRD_ACT_ID,SNG_DAY,TRX_DT;
select * from lab_bigdata_dev.xt_cst_024618_02 where cr_crd_act_id = '0000100006' order by CR_CRD_ACT_ID,SNG_DAY,TRX_DT;


-- 计算还款类型
drop table if exists lab_bigdata_dev.xt_cst_024618_03;
create table if not exists lab_bigdata_dev.xt_cst_024618_03 as
select p.CR_CRD_ACT_ID
      ,p.SNG_DAY
      ,p.NEXT_SNG_DAY
      ,case when BIL_AMT <= 0 then '无还款'
            when BIL_AMT > 0 and INSTL_RPAY_F = 1 then '分期还款'
            when BIL_AMT > 0 and ACTIVE_RPAY_TRX_AMT >= BIL_AMT then '提前还款-全额还款'
            when BIL_AMT > 0 and ACTIVE_RPAY_TRX_AMT < BIL_AMT and GRC_ACTIVE_RPAY_TRX_AMT >= BIL_AMT then '一次性还款-全额还款'
            when BIL_AMT > 0 and GRC_ACTIVE_RPAY_TRX_AMT > 0 and GRC_ACTIVE_RPAY_TRX_AMT < BIL_AMT and (RPAY_NUM = 1 or (RPAY_NUM>1 and CSM_CSH_NUM = 0))then '一次性还款-未全额还款'
            when BIL_AMT > 0 and ACTIVE_RPAY_TRX_AMT > 0 and ACTIVE_RPAY_TRX_AMT < BIL_AMT and GRC_ACTIVE_RPAY_TRX_AMT >= BIL_AMT and (RPAY_NUM = 1 or (RPAY_NUM>1 and CSM_CSH_NUM > 0)) then '循环还款-全额还款'
            when BIL_AMT > 0 and GRC_ACTIVE_RPAY_TRX_AMT >0 and GRC_ACTIVE_RPAY_TRX_AMT < bil_amt and (RPAY_NUM = 1 or (RPAY_NUM>1 and CSM_CSH_NUM > 0)) then '循环还款-未全额还款'
            else '其他还款类型' end as RPAY_TYPE
from (
select T1.CR_CRD_ACT_ID
      ,T1.SNG_DAY --上一账单日
      ,T1.NEXT_SNG_DAY --下一账单日
      ,MAX(T1.BIL_AMT)  BIL_AMT
      ,MAX(CASE WHEN BIL_AMT > 0 AND TRX_TYP_CD = '1050' AND TRX_DSCR_1 LIKE '%账单分期%' THEN 1 ELSE 0 END) AS INSTL_RPAY_F --是否有分期交易
      ,SUM(CASE WHEN TRX_DT >= LST_SNG_DAY_2) AND TRX_DT <= BIL_STMT_DAYS
            AND (TRX_)
              and (trx_typ_cd >= 7000 and trx_typ_cd <= 7099 and trx_typ_cd not in (7002,7056))
              and WDW_RVS_IND <> '1'
              then abs(trx_amt) else 0 end) as ACTIVE_RPAY_TRX_AMT --还款日前主动还款交易金额
      ,sum(case when  trx_dt >= LST_SNG_DAY_2 and trx_dt <= BIL_PROC_DAYS
               and (trx_typ_cd >= 7000 and trx_typ_cd <= 7099 and trx_typ_cd not in (7002,7056))
               and WDW_RVS_IND <> '1'
               then abs(trx_amt) else 0 end) as GRC_ACTIVE_RPAY_TRX_AMT --本月还款宽限期日前主动还款交易金额
      ,sum(case when trx_typ_cd >= 7000 and trx_typ_cd <= 7999 then 1 else 0 end) as RPAY_NUM --交易类型为还款的次数
      ,sum(case when trx_typ_cd >= 2000 and trx_typ_cd <= 2999 and trx_typ_cd <> 1050 and concat(trx_dt,trx_tm)> min_trx_tm and concat(trx_dt,trx_tm) < max_trx_tm then 1 else 0 end) as CSM_CSH_NUM --还款期间取现或消费交易的次数
from lab_bigdata_dev.xt_cst_024618_02 t1
left join (
      select CR_CRD_ACT_ID
            ,SNG_DAY
            ,min(concat(trx_dt,trx_tm)) as min_trx_tm --本账单期内，还款交易最早的时间
            ,max(concat(trx_dt,trx_tm)) as max_trx_tm --本账单期内，还款交易最迟的时间
      from lab_bigdata_dev.xt_cst_024618_02
      where trx_typ_cd >= 7000 and trx_typ_cd <= 7999  --还款交易
      group by CR_CRD_ACT_ID,SNG_DAY
)t2 on t1.CR_CRD_ACT_ID = t2.CR_CRD_ACT_ID and t1.SNG_DAY = t2.SNG_DAY
group by t1.CR_CRD_ACT_ID,t1.SNG_DAY,t1.NEXT_SNG_DAY
) p
;

select * from lab_bigdata_dev.xt_cst_024618_03;

-- 加工最高频还款类型、最近一次还款类型
当最近12个月都无还款，则最高频还款类型为：无还款，否则为最高频的还款类型
当最近12个月都无还款，则最近一次还款类型为：为还款，否则为最近一次的还款类型。
select
from lab_bigdata_dev.xt_cst_024618_03 t1
left join (
select CR_CRD_ACT_ID
      ,RPAY_TYPE
      ,num
      ,row_number()over(partition by CR_CRD_ACT_ID order by num desc) as rn
from (
select CR_CRD_ACT_ID
      ,RPAY_TYPE
      ,count(1) as num
from lab_bigdata_dev.xt_cst_024618_03
where RPAY_TYPE <> '无还款'
group by CR_CRD_ACT_ID,RPAY_TYPE
) a ) t2 on t1.cr_crd_act_id = t2.


------------------------------------------------------------ 20220117 RFM（存续卡）-------------------------------------------------
-- 基础表
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CARD_Z01;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CARD_Z01 AS
SELECT
        T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.CR_CRD_ACT_ID --信用卡账户
        ,T1.CST_ID  CST_ID   --客户号
        ,T.CR_CRD_PD_ID --信用卡产品编号
        ,T.MAIN_CRD_IND --主附卡标志（1-主卡）
        ,T.CARD_STS_CD --卡片状态代码
        ,T.CARD_STS_DT --卡片状态日期
        ,T.MAIN_CARD_CARD_NBR --主卡卡号
        ,T.MTU_DAY --卡片到期日
        ,T.ISU_RSN_CD --发卡原因代码
        ,T.ISU_DT    --发卡日期
        ,T.CARD_ACTV_DT  --卡片激活日期
        ,T.CHG_CARD_TMS    --换卡次数
        ,T1.ACT_STS_CD  --信用卡账户状态
        ,T1.ACT_STS_DT --信用卡账户状态日期
        ,T1.CRD_LMT   --信用额度
        ,T1.INI_ACT_DT   --信用卡账户的初始激活日期
        ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
        ,T2.CRD_LVL         --卡片等级
        ,T2.CRD_LVL_NM      --卡片等级名称
        ,CASE WHEN T.CARD_STS_CD = 'A' THEN '0' ELSE '1' END AS  JIHUO_F  --当前是否已激活
        ,CASE
           WHEN T.CARD_STS_CD NOT IN ( 'Q' , '2' ) AND T1.ACT_STS_CD <> 'V' AND T1.CRD_LMT > 0 AND TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', T.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') > '@@{YYYYMMDD}' THEN '1'
           ELSE '0'
         END CUNXU_FLAG --是否存续卡
        ,CASE
           WHEN T3.ACT_ID IS NOT NULL THEN '1'
           ELSE '0'
         END AS MB_HANG_FLAG --手机银行下挂标识
FROM   EDW.DIM_BUS_CRD_CR_CRD_INF_DD  T --信用卡卡片信息
LEFT JOIN    EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
ON      T.CR_CRD_ACT_ID = T1.CR_CRD_ACT_ID
AND     T1.DT = '@@{yyyyMMdd}'
LEFT JOIN    APP_RPT.DIM_CR_CRD_PD T2 --信用卡产品信息
ON      T.CR_CRD_PD_ID = T2.PD_CD
LEFT JOIN    EDW.DIM_BUS_CHNL_ELEC_NB_IDV_CST_ACT_INF_DD T3 --网银个人客户账户信息
ON      T.CR_CRD_CARD_NBR = T3.ACT_ID
AND     T.CST_ID = T3.NB_CST_ID
AND     T3.ACT_ID_TYP = 'C' --信用卡
AND     T3.CHNL = '1' --手机
AND     T3.DT = '@@{yyyyMMdd}'
WHERE   T.DT = '@@{yyyyMMdd}'
;

-- 交易表底表
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_TRX_02;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_TRX_02 AS
SELECT  T1.CST_ID
        ,T1.CR_CRD_ACT_ID
        ,T2.CR_CRD_CARD_NBR
        ,T2.TRX_DT
        ,T2.TRX_TYP_CD
        ,T2.TRX_AMT
FROM   EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
LEFT JOIN  EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI   T2
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
AND T2.DT <= '@@{yyyyMMdd}'
WHERE T1.DT = '@@{yyyyMMdd}'
AND  T2.TRX_TYP_CD IN (
 --消费
 '1000','1010','1016','1020','1020','1030','1040','1110','1112','1120','1122','1123','1180','1184'
 --取现/转出
 ,'2000','2010','2012','2040','2042','2046','2048','2050','2060','2070','2072','2090','2092','2094'
 ,'2098','2100','2104','2106','2110','2122','2123','2140','2142','2144','2150','2154','2160','2170'
 ,'2172','2174','2180','2182','2184','2300','2310','2312','2340','2342','2346','2350','2360','2370'
 ,'2372','2398','2400','2404','2406','2410','2422','2423','2440','2442','2444','2450','2460','2470'
 ,'2472','2474','2480','2482','2484'
 --分期
 , '8130' , '8950' , '8952' , '8954' , '8956' , '8958'
  --取现人工
 , '8110' , '8112' , '8114' , '8116'
  --消费人工
 , '8100' , '8104')
AND T2.WDW_RVS_IND <> '1'
;


SELECT T1.CST_ID
      ,T1.CR_CRD_ACT_ID
      ,T2.CST_CC_RECENT_TO_NOW --12.客户信用卡交易近度
      ,T2.CST_CC_CSM_RECENT_TO_NOW --13.客户信用卡消费交易近度
      ,T2.CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
      ,T2.CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
      ,T3.CST_CC_INSTL_NBR    --近90天分期交易次数
      ,T3.CST_CC_INSTL_AMT   --近90天分期交易金额

FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1
LEFT JOIN (
SELECT A1.CST_ID
      ,A1.CR_CRD_ACT_ID
      ,COALESCE(MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1) ,'无交易') CST_CC_RECENT_TO_NOW --12.客户信用卡交易近度
      ,COALESCE(MIN(CASE WHEN TRX_TYP_CD >= '1000' AND TRX_TYP_CD <= '1999'
                         THEN DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1 ELSE NULL END) ,'无交易') CST_CC_CSM_RECENT_TO_NOW --13.客户信用卡消费交易近度
      ,COALESCE(MIN(CASE WHEN TRX_TYP_CD >= '2000' AND TRX_TYP_CD <= '2999'
                         THEN DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1 ELSE NULL END) , '无交易')  CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
      ,COALESCE(MIN(CASE WHEN TRX_TYP_CD IN ('8130' , '8950' , '8952' , '8954' , '8956' , '8958')
                         THEN DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1 ELSE NULL END) ,'无交易' ) CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_TRX_02 A1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_Z01 A2 ON A1.CR_CRD_CARD_NBR = A2.CR_CRD_CARD_NBR
WHERE A2.CUNXU_FLAG = 1  --存续卡
GROUP BY A1.CST_ID,A1.CR_CRD_ACT_ID
) T2 ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
LEFT JOIN (
            SELECT A1.CR_CRD_ACT_ID
                   ,COUNT(1)    CST_CC_INSTL_NBR    --近90天分期交易次数
                   ,SUM(TOT_PD_AMT)  CST_CC_INSTL_AMT   --近90天分期交易金额
            FROM EDW.DWD_BUS_CRD_CR_CRD_INSTL_DTL_DD  A1
            LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 A2
            ON A1.CR_CRD_CARD_NBR = A2.CR_CRD_CARD_NBR
            WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A1.RCD_DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
            AND A2.CUNXU_FLAG = 1
            GROUP BY  A1.CR_CRD_ACT_ID
) T3 ON T1.CR_CRD_ACT_ID = T3.CR_CRD_ACT_ID










--------------------------------------------------------------- 20220117 近180天交易次数>0的存续客户近90天的RFM值 -------------------------------------------
-- 当前存续客户、近180天交易次数大于0的客户
-- 近90天的RFM值
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.XT_CUSTOMER_01; --当前存续卡
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.XT_CUSTOMER_01 AS
SELECT G.cr_crd_card_nbr --卡号
      ,A.late_main_card_card_nbr --主卡卡号
      ,A.cr_crd_act_id  --账户号
      ,G.cst_id  --客户号
      ,CASE WHEN A.LATE_MAIN_CARD_STS_CD NOT IN ( 'Q' , '2' ) AND A.ACT_STS_CD <> 'V' AND A.CRD_LMT > 0 AND TO_CHAR(DATEADD(DATEADD(TO_DATE(concat('20', G.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') > '20220130' THEN 1
       ELSE 0
       END CUNXU_FLAG   --是否存续卡
FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD A
LEFT JOIN EDW.DIM_BUS_CRD_CR_CRD_INF_DD G
ON G.CR_CRD_CARD_NBR = A.LATE_MAIN_CARD_CARD_NBR
AND G.DT = '@@{yyyyMMdd}'
WHERE A.DT = '@@{yyyyMMdd}';

-- 当前存续客户号
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.XT_CUSTOMER_02; --当前存续客户
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.XT_CUSTOMER_02 AS
SELECT CST_ID  --存续客户号
FROM (
SELECT CST_ID
      ,CASE WHEN SUM(CUNXU_FLAG) > 0 THEN 1 ELSE 0 END AS CUNXU_CUS_FLAG
FROM  LAB_BIGDATA_DEV.XT_CUSTOMER_01
GROUP BY CST_ID
) A WHERE A.CUNXU_CUS_FLAG = 1;


-- 近180天交易次数>0
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.XT_CUSTOMER_03; --交易底表
CREATE  TABLE  LAB_BIGDATA_DEV.XT_CUSTOMER_03 AS
SELECT CR_CRD_ACT_ID
       ,CR_CRD_CARD_NBR
       ,SRL_NBR    --流水号
       ,TRX_TYP_CD    --交易类型代码
       ,TRX_AMT     --交易金额
       ,TRX_DT     --交易日期
       ,TRX_TM     --交易时间
       ,WDW_RVS_IND  --撤销冲正标志
       ,MCH_TYP       --商户类型
       ,RTN_GDS_TRX_ID  --退货交易标识
       ,ACQ_MCH_ENC   --收单商户编码
       ,TRX_DSCR_1   --交易描述1
       ,TRX_TLR      --交易柜员
       ,DT
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DT <= '@@{yyyyMMdd}'
;

DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.XT_CUSTOMER_04;
CREATE  TABLE  LAB_BIGDATA_DEV.XT_CUSTOMER_04 AS
SELECT  T1.CST_ID
        ,T1.CR_CRD_ACT_ID
        ,T2.CR_CRD_CARD_NBR
        ,T2.TRX_DT
        ,T2.TRX_TYP_CD
        ,T2.TRX_AMT
FROM   EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
LEFT JOIN  LAB_BIGDATA_DEV.XT_CUSTOMER_03 T2
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
WHERE T1.DT = '@@{yyyyMMdd}'
AND  T2.TRX_TYP_CD IN (
 --消费
 '1000','1010','1016','1020','1020','1030','1040','1110','1112','1120','1122','1123','1180','1184'
 --取现/转出
 ,'2000','2010','2012','2040','2042','2046','2048','2050','2060','2070','2072','2090','2092','2094'
 ,'2098','2100','2104','2106','2110','2122','2123','2140','2142','2144','2150','2154','2160','2170'
 ,'2172','2174','2180','2182','2184','2300','2310','2312','2340','2342','2346','2350','2360','2370'
 ,'2372','2398','2400','2404','2406','2410','2422','2423','2440','2442','2444','2450','2460','2470'
 ,'2472','2474','2480','2482','2484'
 --分期
 , '8130' , '8950' , '8952' , '8954' , '8956' , '8958'
  --取现人工
 , '8110' , '8112' , '8114' , '8116'
  --消费人工
 , '8100' , '8104')
AND T2.WDW_RVS_IND <> '1'
;


-- 近180天整体交易次数>0的客户
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.XT_CUSTOMER_05;   --当前存续客户最近180天交易次数
CREATE  TABLE  LAB_BIGDATA_DEV.XT_CUSTOMER_05 AS
SELECT A1.CST_ID
      ,A1.CR_CRD_ACT_ID
      ,COUNT(1)  TRX_NBR   --过去180天整体交易的次数
      ,SUM(CASE WHEN DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A1.TRX_DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90  AND TRX_TYP_CD >= '2000' AND TRX_TYP_CD <= '2999' THEN 1 ELSE 0 END) CST_CC_CSH_NBR --近90天取现/转出次数
      ,SUM(TRX_AMT)  TRX_AMT   --过去180天整体交易的金额
      ,SUM(CASE WHEN DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A1.TRX_DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90  AND TRX_TYP_CD >= '2000' AND TRX_TYP_CD <= '2999' THEN TRX_AMT ELSE 0 END) CST_CC_CSH_AMT --近90天取现/转出金额
FROM  LAB_BIGDATA_DEV.XT_CUSTOMER_04 A1
inner JOIN LAB_BIGDATA_DEV.XT_CUSTOMER_02 A2
ON A1.CST_ID = A2.CST_ID
WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A1.TRX_DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 180
GROUP BY A1.CST_ID,A1.CR_CRD_ACT_ID
;


-- 近180天交易次数>0的存续客户最近90天交易的RFM值
SELECT T1.CST_ID
       ,T1.CR_CRD_ACT_ID
       ,T2.CST_CC_RECENT_TO_NOW --12.客户信用卡整体交易近度
       ,T2.CST_CC_CSM_RECENT_TO_NOW--13.客户信用卡消费交易近度
       ,T2.CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
       ,T2.CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
       ,T3.CST_CC_INSTL_NBR    --近90天分期交易次数
       ,T3.CST_CC_INSTL_AMT    --近90天分期交易金额
       ,T4.CST_CC_CSM_AMT      --近90天信用卡消费交易金额
       ,T4.CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
       ,T5.TRX_NBR            --过去90天整体交易的次数
       ,T5.CST_CC_CSH_NBR     --近90天取现/转出次数
       ,T5.TRX_AMT            --过去90天整体交易的金额
       ,T5.CST_CC_CSH_AMT    --近90天取现/转出金额
FROM LAB_BIGDATA_DEV.XT_CUSTOMER_05 T1
LEFT JOIN (
            SELECT A1.CST_ID
                  ,A1.CR_CRD_ACT_ID
                  ,COALESCE(MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1) ,'无交易') CST_CC_RECENT_TO_NOW --12.客户信用卡交易近度
                  ,COALESCE(MIN(CASE WHEN TRX_TYP_CD >= '1000' AND TRX_TYP_CD <= '1999'
                                     THEN DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1 ELSE NULL END) ,'无交易') CST_CC_CSM_RECENT_TO_NOW--13.客户信用卡消费交易近度
                  ,COALESCE(MIN(CASE WHEN TRX_TYP_CD >= '2000' AND TRX_TYP_CD <= '2999'
                                      THEN DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1 ELSE NULL END) , '无交易')  CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
                   ,COALESCE(MIN(CASE WHEN TRX_TYP_CD IN ('8130' , '8950' , '8952' , '8954' , '8956' , '8958')
                                      THEN DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(TRX_DT, 'YYYYMMDD'), 'DD') + 1 ELSE NULL END) ,'无交易' ) CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
            FROM WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_TRX_02   A1
            -- LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 A2
            -- ON A1.CR_CRD_CARD_NBR = A2.CR_CRD_CARD_NBR
            -- WHERE A2.CUNXU_FLAG = 1    --存续标识
            GROUP BY A1.CST_ID,A1.CR_CRD_ACT_ID
           )T2
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
LEFT JOIN (
            SELECT A1.CR_CRD_ACT_ID
                   ,COUNT(1)    CST_CC_INSTL_NBR    --近90天分期交易次数
                   ,SUM(TOT_PD_AMT)  CST_CC_INSTL_AMT   --近90天分期交易金额
            FROM EDW.DWD_BUS_CRD_CR_CRD_INSTL_DTL_DD  A1
            -- LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 A2
            -- ON A1.CR_CRD_CARD_NBR = A2.CR_CRD_CARD_NBR
            WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A1.RCD_DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
            -- AND A2.CUNXU_FLAG = 1
            GROUP BY  A1.CR_CRD_ACT_ID
   )T3
ON T1.CR_CRD_ACT_ID = T3.CR_CRD_ACT_ID
LEFT JOIN (
            SELECT N1.CST_ID
                   ,N1.CR_CRD_ACT_ID
                   ,SUM(CASE WHEN  TRX_TYP_CD >= '1000' AND TRX_TYP_CD <= '1999' AND TRX_TYP_CD <> '1050' THEN (TRX_AMT + BACK_AMT) END )AS CST_CC_CSM_AMT --近90天信用卡消费交易金额
                   ,SUM(CASE WHEN  TRX_TYP_CD >= '1000' AND TRX_TYP_CD <= '1999' AND TRX_TYP_CD <> '1050' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
            FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
            -- LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 N2
            -- ON N1.CR_CRD_CARD_NBR = N2.CR_CRD_CARD_NBR
            -- WHERE N1.CUNXU_FLAG = 1
            GROUP BY N1.CST_ID,N1.CR_CRD_ACT_ID
   )T4
ON T1.CR_CRD_ACT_ID = T4.CR_CRD_ACT_ID
LEFT JOIN (
            SELECT A1.CST_ID
                   ,A1.CR_CRD_ACT_ID
                   ,COUNT(1)  TRX_NBR   --过去90天整体交易的次数
                   ,SUM(CASE WHEN TRX_TYP_CD >= '2000' AND TRX_TYP_CD <= '2999' THEN 1 ELSE 0 END) CST_CC_CSH_NBR --近90天取现/转出次数
                   ,SUM(TRX_AMT)  TRX_AMT   --过去90天整体交易的金额
                   ,SUM(CASE WHEN TRX_TYP_CD >= '2000' AND TRX_TYP_CD <= '2999' THEN TRX_AMT ELSE 0 END) CST_CC_CSH_AMT --近90天取现/转出金额
            FROM  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_TRX_02 A1
            -- LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 A2
            -- ON A1.CR_CRD_CARD_NBR = A2.CR_CRD_CARD_NBR
            WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A1.RCD_DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
            -- AND A2.CUNXU_FLAG = 1
            GROUP BY A1.CST_ID,A1.CR_CRD_ACT_ID
   )T5
ON T1.CR_CRD_ACT_ID = T5.CR_CRD_ACT_ID
WHERE T1.DT = '@@{yyyyMMdd}'
;





---------------------------------------------- 20220119 备用金 ------------------------------------
select cr_crd_card_nbr
      ,case when b.serialno is null then '未开通' else '已开通' end as 是否开通备用金
      -- ,case when c.serialno is null then '截至昨天未用款' else c.inputdate as 首刷时间
      ,t2.putoutdate as 申请日期
      ,t2.channel as 申请渠道
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.loan_business_contract b on b.accountno = a.cr_crd_card_nbr and b.dt = a.dt  --业务合同表
-- left join edw.loan_business_apply t1 on t1.serialno = b.serialno and t1.dt = a.dt
left join edw.dws_bus_loan_dbil_inf_dd t1 on t1.bus_ctr_id = b.artificialno and t1.dt = a.dt  --借据表
left join edw.loan_business_apply t2 on t2.serialno = t1.bus_apl_id and t2.dt = a.dt  --申请表
-- left join edw.loan_business_duebill c on c.relativeserialno2 = b.serialno and c.dt = a.dt  --换成表：edw.dim_bus_loan_dbil_inf_dd
where a.dt = '20211216'
and b.serialno is not null
;

select serialno,relativeserialno from edw.loan_business_contract where dt = '20220118';
select serialno,relativeserialno from edw.loan_business_apply where dt = '20220118';


select cr_crd_card_nbr
      ,case when b.serialno is null then '未开通' else '已开通' end as 是否开通备用金
      ,t2.putoutdate as 申请日期
      ,t2.channel as 申请渠道
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.loan_business_contract b on b.accountno = a.cr_crd_card_nbr and b.dt = a.dt  --业务合同表
left join edw.dws_bus_loan_dbil_inf_dd t1 on t1.bus_ctr_id = b.SERIALNO and t1.dt = a.dt  --借据表
left join edw.loan_business_apply t2 on t2.serialno = t1.bus_apl_id and t2.dt = a.dt  --申请表
-- left join edw.loan_business_apply t1 on t1.serialno = b.relativeserialno and t1.dt = a.dt
where a.dt = '20211216'
and b.serialno is not null
;



select
from edw.dim_bus_crd_cr_crd_inf_dd a
left join


------------------------------------------------------------------------------- 20220119 还款方式 -------------
1. 还款方式：自扣还款、非自扣本行渠道还款、非本行渠道还款
2. 还款渠道：手机银行、柜面、网上银行、第三方渠道-支付宝、第三方渠道-银联在线、第三方渠道-财付通
drop table if exists lab_bigdata_dev.xt_024618_tmp_repay_1230;
create table if not exists lab_bigdata_dev.xt_024618_tmp_repay_1230 as
select cr_crd_card_nbr
      ,cr_crd_act_id
      ,trx_dt
      ,trx_typ_cd
      ,trx_tlr
      ,trx_dscr_1
      ,case when trx_dscr_1 like '支付宝%' then '第三方渠道-支付宝'
            when trx_dscr_1 like '财付通%' then '第三方渠道-财付通'
            when trx_typ_cd = '7028' then '第三方渠道-银联在线'
            when trx_typ_cd in ('7000','7012','7020','7030','7036','7050','7054','7056','7062','7086','7092','7094','7096','7400') then '柜面'
            when trx_typ_cd in ('7010','7040','7060','7080','7082','7084') then 'ATM'
            when (trx_tlr like '%SJG%' or trx_tlr like '%SJGY%') then '手机银行'
            when (trx_tlr like '%WYGY%' or trx_tlr like '%WYG%') then '网上银行'
            else '' end as chann_repay
      ,case when trx_typ_cd = '7050' then '自扣还款'
            when trx_typ_cd <> '7050' and
                  ((trx_typ_cd = '7000' and trx_tlr not like '%XYGY%') or  trx_typ_cd in ('7002','7010','7012','7024','7036','7040','7050','7054','7056','7060','7062','7070','7400')) then '非自扣本行渠道'
            when trx_typ_cd <> '7050' and
                 ((trx_typ_cd = '7000' and trx_tlr like '%XYGY%') or  trx_typ_cd in ('7020','7028','7030','7032','7076','7080','7082','7084','7086','7092','7094','7096')) then '非本行渠道还款'
            else '' end as method_repay
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt >= '20201201' and dt <= '20211228' --改成自己日期
and trx_dt >= '20201201' and trx_dt <= '20211228'   --改成自己日期
and trx_typ_cd >= '7000' and trx_typ_cd <= '7999'  --筛选：还款
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
;

-----------------------------------------一个信用卡账户下面 可能会有多个主卡吗 -----------------------
-- 同一个账号下存在多张不同卡号的主卡
select *
from (
select cr_crd_act_id
      ,substr(cr_crd_card_nbr,1,6) as card1
      ,substr(cr_crd_card_nbr,7,length(cr_crd_card_nbr)) as card2
      ,card_sts_cd
      ,main_crd_ind
      ,row_number()over(partition by cr_crd_act_id,main_crd_ind order by cr_crd_card_nbr) as rn
from edw.dim_bus_crd_cr_crd_inf_dd
where dt = '20220119'
) a
where a.rn > 1
;


select cr_crd_act_id
      ,substr(cr_crd_card_nbr,1,6) as card1
      ,substr(cr_crd_card_nbr,7,length(cr_crd_card_nbr)) as card2
      ,card_sts_cd
      ,main_crd_ind
from edw.dim_bus_crd_cr_crd_inf_dd
where dt = '20220119'
and cr_crd_act_id in (
      select cr_crd_act_id
from (
select cr_crd_act_id
      ,substr(cr_crd_card_nbr,1,6) as card1
      ,substr(cr_crd_card_nbr,7,length(cr_crd_card_nbr)) as card2
      ,card_sts_cd
      ,main_crd_ind
      ,row_number()over(partition by cr_crd_act_id,main_crd_ind order by cr_crd_card_nbr) as rn
from edw.dim_bus_crd_cr_crd_inf_dd
where dt = '20220119'
) a
where a.rn > 1
)
;


select cr_crd_act_id
      ,substr(cr_crd_card_nbr,1,6) as card1
      ,substr(cr_crd_card_nbr,7,length(cr_crd_card_nbr)) as card2
      ,card_sts_cd
      ,main_crd_ind
from edw.dim_bus_crd_cr_crd_inf_dd
where dt = '20220119'
and card_sts_cd = '-'
;



---------------------------------------- 20220120 账户退出类型 --------------------------------
--退出类型、退出时间(用到卡级中的 WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01表)
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05 AS
SELECT  CR_CRD_ACT_ID --信用卡账户
        ,CST_ID       --客户号
        ,TYPE         --退出类型
        ,TYPE_DATE    --退出时间
        ,CR_CRD_CARD_NBR
        ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID  ORDER BY CR_CRD_CARD_NBR DESC ) ROW_NO_1 --按卡号排序
FROM  (
        SELECT CR_CRD_CARD_NBR --信用卡卡号
               ,CR_CRD_ACT_ID --信用卡账户
               ,CST_ID        --客户号
               ,TYPE
               ,TYPE_DATE
               ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID,CR_CRD_CARD_NBR ORDER BY TYPE_DATE) ROW_NO
        FROM  (
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'销卡时间'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                WHERE  CARD_STS_CD = 'V'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'过期未续时间'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                WHERE   CARD_STS_CD = '2'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'核销时间'  AS TYPE
                        ,ACT_STS_DT  AS TYPE_DATE
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                WHERE ACT_STS_CD = 'V'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'卡片过期时间'  AS TYPE
                        ,TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD')   TYPE_DATE
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                WHERE TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') <='@@{yyyyMMdd}'  --增加条件卡片已到期                )T
               )T
      )T1
WHERE  ROW_NO = 1
;

-----------------------------------------------------------/*  账单日逻辑修改 20220120 */-----------------------------
-- 账单日
-- 近12个月的账单日与下一个账单日
-- 获取还款日、宽限期
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_10;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_10 AS
SELECT T1.CR_CRD_ACT_ID
      ,T2.DT   SNG_DAY        --近12个月账单日
      ,CASE WHEN BIN_SNG_DAY <= '28' THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)
            WHEN BIN_SNG_DAY > '28' AND SUBSTR(T2.DT,5,2) = '01' THEN TO_CHAR(LASTDAY(DATEADD(TO_DATE(CONCAT(SUBSTR(T2.DT,1,6),'01'),'yyyyMMdd'),1,'MM')),'yyyyMMdd')
            WHEN BIN_SNG_DAY > '28' AND SUBSTR(T2.DT,5,2) <> '01' THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)
      END AS NEXT_SNG_DAY_1  --下一个账单日
      ,CASE WHEN SUBSTR(T2.DT,5,2) = '01' AND SUBSTR(T2.DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(T2.DT,1,6),BIN_SNG_DAY)  --若为1月30之前，则下一个账单日在0130
            WHEN SUBSTR(T2.DT,5,2) = '01' AND SUBSTR(T2.DT,7,2) >= BIN_SNG_DAY THEN TO_CHAR(LASTDAY(DATEADD(TO_DATE(CONCAT(SUBSTR(T2.DT,1,6),'01'),'yyyyMMdd'),1,'MM')),'yyyyMMdd')  --若为0130,0131，则为2月最后一天
            WHEN SUBSTR(T2.DT,5,2) = '02' AND T2.DT < TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') THEN TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') --若为2月最后一天之前，则为2月最后一天
            WHEN SUBSTR(T2.DT,5,2) = '02' AND T2.DT = TO_CHAR(LASTDAY(TO_DATE(T2.DT,'yyyyMMdd')),'yyyyMMdd') THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY) --若为2月最后一天，则为3月30
            WHEN SUBSTR(T2.DT,5,2) NOT IN ('01','02') AND SUBSTR(T2.DT,7,2) < BIN_SNG_DAY THEN CONCAT(SUBSTR(T2.DT,1,6),BIN_SNG_DAY)
            WHEN SUBSTR(T2.DT,5,2) NOT IN ('01','02') AND SUBSTR(T2.DT,7,2) >= BIN_SNG_DAY THEN CONCAT(SUBSTR(TO_CHAR(DATEADD(TO_DATE(T2.DT,'yyyyMMdd'),1,'MM'),'yyyyMMdd'),1,6),BIN_SNG_DAY)
      END AS NEXT_SNG_DAY  --下一个账单日
      ,COALESCE(ROUND(T2.END_TM_BAL,2),0) BIL_AMT  --期末余额（账单金额）
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), 1, 'DD'), 'YYYYMMDD')  LST_SNG_DAY_2  ----近12个月账单日次日
      ,T3.STMT_DAYS    --账单宽限期
      ,T3.PROC_DAYS      --还款宽限期
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), STMT_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_STMT_DAYS --还款日
      ,TO_CHAR(DATEADD(TO_DATE(T2.DT, 'YYYYMMDD'), PROC_DAYS, 'DD'), 'YYYYMMDD')  AS BIL_PROC_DAYS --加了宽限期的还款日
from EDW.DIM_BUS_CRD_CR_CRD_ACT_INF_DD T1  --信用卡账户信息
left join EDW.DWD_BUS_CRD_CR_CRD_BIL_INF_DI T2  --信用卡账单信息
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(T2.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 365
LEFT JOIN EDW.NCRD_PRMCN T3 ON T1.ACT_CTG = T3.CATEGORY AND T1.DT =T3.DT  --产品参数表
WHERE T1.DT = '@@{yyyyMMdd}'
AND T2.DT IS NOT NULL
;
SELECT SNG_DAY,NEXT_SNG_DAY_1,NEXT_SNG_DAY
FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_10
WHERE NEXT_SNG_DAY_1 <> NEXT_SNG_DAY
GROUP BY SNG_DAY,NEXT_SNG_DAY_1,NEXT_SNG_DAY
ORDER BY SNG_DAY,NEXT_SNG_DAY_1,NEXT_SNG_DAY
;

-----------------------------------------------------------/*   账户退出类型/时间 20220120   */------------------
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.XT_024618_TMP_OUTTIME;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.XT_024618_TMP_OUTTIME AS
SELECT CR_CRD_ACT_ID  --账号
      ,CST_ID         --客户号
      ,'核销' AS TYPE
      ,'1' AS ORDER_CD
      ,ACT_STS_DT  AS TYPE_DATE
--FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01
WHERE ACT_STS_CD = 'V'
UNION ALL

SELECT CR_CRD_ACT_ID
      ,CST_ID
      ,'提前销户' AS TYPE
      ,'2' AS ORDER_CD
      ,CARD_STS_DT AS TYPE_DATE
FROM (
SELECT CR_CRD_ACT_ID   --账号
      ,CR_CRD_CARD_NBR --卡号
      ,CST_ID
      ,CARD_STS_CD  --卡片状态
      ,CARD_STS_DT  --卡片状态日期
      ,MTU_DAY    --卡片到期时间
      ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY CR_CRD_CARD_NBR DESC) AS ROW_NUM
--FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01
WHERE MAIN_CRD_IND = '1'  --主卡
) A
WHERE A.ROW_NUM = 1
 AND A.CARD_STS_CD = 'Q'  --卡片状态为Q-销户申请
 AND CARD_STS_DT < TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', A.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD')  --卡片状态日<到期日
UNION ALL

SELECT CR_CRD_ACT_ID
      ,CST_ID
      ,'过期未续' AS TYPE
      ,'3' AS ORDER_CD
      ,MTU_DAY AS TYPE_DATE
FROM (
SELECT CR_CRD_ACT_ID   --账号
      ,CR_CRD_CARD_NBR --卡号
      ,CST_ID
      ,CARD_STS_CD  --卡片状态
      ,CARD_STS_DT  --卡片状态日期
      ,TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') AS MTU_DAY
      ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY CR_CRD_CARD_NBR DESC) AS ROW_NUM
--FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01
WHERE MAIN_CRD_IND = '1'  --主卡
) A
WHERE ROW_NUM = 1
 AND (A.CARD_STS_CD = '2' OR (A.CARD_STS_CD = 'Q' AND CARD_STS_DT >= MTU_DAY) OR (CARD_STS_CD NOT IN ('2','Q') AND MTU_DAY < '@@{yyyyMMdd}'))
;

-- 账户退出类型，优先级：核销>提前销户>过期未续
SELECT *
FROM(
SELECT CR_CRD_ACT_ID
      ,CST_ID
      ,TYPE
      ,TYPE_DATE
      ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY ORDER_CD) AS ROW_NUM
FROM LAB_BIGDATA_DEV.XT_024618_TMP_OUTTIME
)A
WHERE A.ROW_NUM = 1

-- 账户退出时间：最早的时间
SELECT CR_CRD_ACT_ID
      ,MIN(TYPE_DATE) AS TYPE_DATE
FROM LAB_BIGDATA_DEV.XT_024618_TMP_OUTTIME
GROUP BY CR_CRD_ACT_ID
;

SELECT CR_CRD_ACT_ID,TYPE,TYPE_DATE,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY TYPE_DATE)
FROM LAB_BIGDATA_DEV.XT_024618_TMP_OUTTIME


SELECT * FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01 WHERE CR_CRD_ACT_ID = '0010100086'

-------------------------------------------- RFM 20220121 ----------------------------------------------------

-- 实际消费金额、笔数
--退货情况
-- DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01;
-- CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01 AS
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CARD_P01;
CREATE TABLE   LAB_BIGDATA_DEV.CUS_CARD_P01 AS
SELECT  CR_CRD_CARD_NBR
        ,OLD_ACQ_MCH_ENC
        ,OLD_TRX_DT
        ,SUM(BACK_AMT) BACK_AMT
FROM (
        SELECT  CR_CRD_CARD_NBR
                ,SRL_NBR
                ,TRX_AMT AS BACK_AMT  --退货金额
                ,DATEADD(TO_DATE('19570101','YYYYMMDD'),SUBSTR(ACQ_MCH_ENC,1,5),'DD') AS OLD_TRX_DT  --原交易日期
                ,SUBSTR(ACQ_MCH_ENC,6,6) AS OLD_ACQ_MCH_ENC
       --FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_TRX    --信用卡客户交易流水
	   FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
       --WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
       WHERE DT <= '@@{yyyyMMdd}'
       AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
       AND TRX_TYP_CD  >= '6000' AND TRX_TYP_CD <= '6999'
       AND TRX_TYP_CD <> '6050'
       AND TRX_TYP_CD <> '6052'
       --AND (TRX_DSCR_1 LIKE '支付宝%' OR  TRX_DSCR_1 LIKE '财付通%' OR (TRX_TYP_CD >= '6000' AND TRX_TYP_CD <= '6999' AND TRX_TYP_CD NOT IN ('6050','6052'))  此条件有问题，去掉???  --xt
       )P
GROUP BY  CR_CRD_CARD_NBR,OLD_ACQ_MCH_ENC,OLD_TRX_DT;







--交易情况
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CARD_P02;
CREATE TABLE   LAB_BIGDATA_DEV.CUS_CARD_P02 AS
SELECT  A.CR_CRD_ACT_ID       --信用卡账号
        ,A.CR_CRD_CARD_NBR      --信用卡卡号
        ,A.SRL_NBR              --流水号
        ,A.TRX_TYP_CD           --交易类型代码
        ,A.TRX_AMT              --交易金额
        ,A.TRX_DT               --交易日期
        ,A.ACQ_MCH_ENC          --收单商户编码
        ,COALESCE(B.BACK_AMT,0)  BACK_AMT  --退货金额
        ,A.TRX_DSCR_1
        ,A.DT
        ,A.MCH_TYP  --商户类型
--FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_TRX   A   --xt
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI A
--LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01  B
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_P01  B
ON B.OLD_ACQ_MCH_ENC = A.SRL_NBR
AND B.OLD_TRX_DT = TO_DATE(A.TRX_DT,'YYYYMMDD')
AND A.CR_CRD_CARD_NBR = B.CR_CRD_CARD_NBR
--WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(A.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
WHERE A.DT <= '@@{yyyyMMdd}'
AND A.WDW_RVS_IND <> '1'  --撤销冲正标志<>1
AND A.TRX_TYP_CD  >= '1000' AND A.TRX_TYP_CD <= '1999'
AND A.TRX_TYP_CD <> '1050'     --筛选交易类型为消费
AND A.RTN_GDS_TRX_ID <> '全额退货'
;



--汇总到卡级
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CARD_P03;
CREATE TABLE   LAB_BIGDATA_DEV.CUS_CARD_P03 AS
SELECT N1.CST_ID
       ,N1.CR_CRD_ACT_ID
       ,N1.CR_CRD_CARD_NBR
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' THEN (TRX_AMT + BACK_AMT) END )AS ZFB_AMT_90  --近90天支付宝消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) ZFB_NBR_90     --近90天支付宝消费笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '%财付通%' THEN (TRX_AMT + BACK_AMT) END )AS CFT_AMT_90  --近90天财付通消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '%财付通%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) CFT_NBR_90                 --近90天财付通消费笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT)END
            )AS ZFB_AMT_30                     --近30天支付宝消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) ZFB_NBR_30                      --近30天支付宝消费笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '%财付通%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT) END
            )AS CFT_AMT_30                      --近30天财付通消费金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '%财付通%'
                 AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) CFT_NBR_30                      --近30天财付通消费笔数
       ,SUM(CASE
                WHEN MCH_TYP IN ('5812','5813','5814')
                THEN (TRX_AMT + BACK_AMT) ELSE 0 END
            ) AS  INB_CREDITCARD_REPAST_CONSUME_AMT_90               --近90天餐饮交易金额
        ,SUM(CASE
               WHEN MCH_TYP IN ('5812','5813','5814')
			   AND (TRX_AMT + BACK_AMT) > 0
               THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_90                 --近90天餐饮交易笔数
       ,SUM(CASE
                WHEN (MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
                OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
                THEN (TRX_AMT + BACK_AMT) ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_90                   --近90天航旅交易金额
            ,SUM(CASE
               WHEN (MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
               OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
			   AND (TRX_AMT + BACK_AMT) > 0
               THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_90                  --近90天航旅交易笔数
       ,SUM(CASE
                WHEN TRX_TYP_CD='1184'
                THEN (TRX_AMT + BACK_AMT) ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_90                  --近90天境外交易金额
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
			   AND (TRX_AMT + BACK_AMT) > 0
			   THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_90                   --近90天境外交易笔数
      ,SUM(CASE
               WHEN DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND MCH_TYP IN ('5812','5813','5814')
			   THEN (TRX_AMT + BACK_AMT) ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_AMT_30                    --近30天餐饮交易金额
      ,SUM(CASE
              WHEN DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND MCH_TYP IN ('5812','5813','5814')
			  AND (TRX_AMT + BACK_AMT) > 0
              THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_30                    --近30天餐饮交易笔数
      ,SUM(CASE
              WHEN (MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              THEN (TRX_AMT + BACK_AMT) ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_30                      --近30天航旅交易金额
      ,SUM(CASE
              WHEN (MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
			  AND (TRX_AMT + BACK_AMT) > 0
              THEN 1 ELSE 0 END
             ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_30                       --近30天航旅交易笔数
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               THEN (TRX_AMT + BACK_AMT) ELSE 0 END
               ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_30                     --近30天境外交易金额
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
			   AND (TRX_AMT + BACK_AMT) > 0
               THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_30                        --近30天境外交易笔数
FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01 N1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_P02 N2
ON N1.CR_CRD_CARD_NBR = N2.CR_CRD_CARD_NBR
AND DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(N2.DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
GROUP BY N1.CST_ID,N1.CR_CRD_ACT_ID,N1.CR_CRD_CARD_NBR
;

-- 上面三段已跑完
SELECT * FROM LAB_BIGDATA_DEV.CUS_CARD_P03 WHERE zfb_amt_90 IS NOT NULL ORDER BY CR_CRD_CARD_NBR ;


------------------------------------------------------------ 账级的RFM 20220124 ------------------------------------
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_RFM;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_RFM AS
SELECT T1.CST_ID
      ,T1.CR_CRD_ACT_ID
      ,COUNT(CASE WHEN T3.RCD_DT >= '@@{yyyyMMdd - 90d}' AND T3.RCD_DT <= '@@{yyyyMMdd}' THEN T3.TOT_PD_AMT END)    CST_CC_INSTL_NBR      --近90天分期交易次数
      ,SUM(CASE WHEN T3.RCD_DT >= '@@{yyyyMMdd - 90d}' AND T3.RCD_DT <= '@@{yyyyMMdd}' THEN T3.TOT_PD_AMT ELSE 0 END)  CST_CC_INSTL_AMT   --近90天分期交易金额
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T3.RCD_DT, 'YYYYMMDD'), 'DD') + 1) CST_CC_INSTL_RECENT_TO_NOW            --15.客户信用卡分期交易近度
      ,SUM(CASE WHEN T4.DT>= '@@{yyyyMMdd - 90d}' AND T4.DT <= '@@{yyyyMMdd}' THEN (T4.TRX_AMT + T4.BACK_AMT) END ) AS CST_CC_CSM_AMT     --近90天信用卡消费交易金额
      ,SUM(CASE WHEN T4.DT>= '@@{yyyyMMdd - 90d}' AND T4.DT <= '@@{yyyyMMdd}' AND (T4.TRX_AMT + T4.BACK_AMT) > 0 THEN 1 ELSE 0 END ) CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T4.TRX_DT, 'YYYYMMDD'), 'DD') + 1) CST_CC_CSM_RECENT_TO_NOW              --13.客户信用卡消费交易近度
      ,SUM(CASE WHEN T5.DT >= '@@{yyyyMMdd - 90d}' AND T5.DT <= '@@{yyyyMMdd}' THEN 1 ELSE 0 END) CST_CC_CSH_NBR                          --近90天取现/转出次数
      ,SUM(CASE WHEN T5.DT >= '@@{yyyyMMdd - 90d}' AND T5.DT <= '@@{yyyyMMdd}' THEN T5.TRX_AMT ELSE 0 END) CST_CC_CSH_AMT                 --近90天取现/转出金额
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T5.TRX_DT, 'YYYYMMDD'), 'DD') + 1)  CST_CC_CSH_RECENT_TO_NOW             --14.客户信用卡取现/转出交易近度
FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1  --信用卡账户信息汇总
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_Z01 T2 ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID --卡级主表
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_INSTL_DTL_DD T3 ON T1.CR_CRD_ACT_ID = T3.CR_CRD_ACT_ID AND T1.DT = T3.DT AND T3.INSTL_PMT_STS NOT IN ('E','F')  --信用卡分期明细
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_P02  T4 ON T1.CR_CRD_ACT_ID = T4.CR_CRD_ACT_ID --消费交易剔除退货
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI T5 ON T1.CR_CRD_ACT_ID = T5.CR_CRD_ACT_ID AND T5.DT <= '@@{yyyyMMdd}' AND T5.TRX_TYP_CD >= '2000' AND T5.TRX_TYP_CD <= '2999' AND T5.WDW_RVS_IND <> '1'  --信用卡交易流水表
WHERE T1.DT = '@@{yyyyMMdd}'
AND T2.CUNXU_FLAG = '1'  --存续标志
GROUP BY T1.CST_ID, T1.CR_CRD_ACT_ID
;


select MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T5.TRX_DT, 'YYYYMMDD'), 'DD') + 1)
from EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
where dt <= '20220125'
and TRX_TYP_CD >= '2000' and TRX_TYP_CD <= '2999'
and cr_crd_act_id = '0021107573'

-- 汇总到账级
SELECT P1.CST_ID  CST_ID   --客户号
       ,P1.CR_CRD_ACT_ID --信用卡账户
       --,P10.CST_CC_RECENT_TO_NOW --12.客户信用卡整体交易近度
       ,P10.CST_CC_CSM_RECENT_TO_NOW--13.客户信用卡消费交易近度
       ,P10.CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
       ,P10.CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
       ,P10.CST_CC_INSTL_NBR    --近90天分期交易次数
       ,P10.CST_CC_INSTL_AMT   --近90天分期交易金额
       ,P10.CST_CC_CSM_AMT      --近90天信用卡消费交易金额
       ,P10.CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
       --,P10.TRX_NBR            --过去90天整体交易的次数
       ,P10.CST_CC_CSH_NBR     --近90天取现/转出次数
       --,P10.TRX_AMT            --过去90天整体交易的金额
       ,P10.CST_CC_CSH_AMT    --近90天取现/转出金额
       ,CASE WHEN P10.CST_CC_CSM_RECENT_TO_NOW IS NULL AND P10.CST_CC_CSH_RECENT_TO_NOW IS NULL AND P10.CST_CC_INSTL_RECENT_TO_NOW IS NULL THEN NULL
             ELSE LEAST(COALESCE(P10.CST_CC_CSM_RECENT_TO_NOW,99999),COALESCE(P10.CST_CC_CSH_RECENT_TO_NOW,99999),COALESCE(P10.CST_CC_INSTL_RECENT_TO_NOW,99999))
        END CST_CC_RECENT_TO_NOW --12.客户信用卡整体交易近度
	 ,COALESCE(P10.CST_CC_INSTL_NBR,0)+COALESCE(P10.CST_CC_CSM_NBR,0)+COALESCE(P10.CST_CC_CSH_NBR,0) TRX_NBR            --过去90天整体交易的次数
	 ,COALESCE(P10.CST_CC_INSTL_AMT,0)+COALESCE(P10.CST_CC_CSM_AMT,0)+COALESCE(P10.CST_CC_CSH_AMT,0) TRX_AMT            --过去90天整体交易的金额
FROM  EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD  P1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CRD_ACT_RFM P10
ON P1.CR_CRD_ACT_ID =  P10.CR_CRD_ACT_ID
WHERE P1.DT =  '@@{yyyyMMdd}'
and p1.cr_crd_act_id = '0023310654'
;



--------------------------------------------------- 客户级RFM -----------------------------------------
-- DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_RFM_02;
-- CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_RFM_02 AS
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_RFM_02;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_RFM_02 AS
SELECT T1.CST_ID
       ,SUM(T1.CST_CC_INSTL_NBR) CST_CC_INSTL_NBR   --近90天分期交易次数
       ,SUM(T1.CST_CC_INSTL_AMT) CST_CC_INSTL_AMT   --近90天分期交易金额
       ,MIN(T1.CST_CC_INSTL_RECENT_TO_NOW)  CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
       ,SUM(T1.CST_CC_CSM_NBR)   CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
       ,SUM(T1.CST_CC_CSM_AMT)   CST_CC_CSM_AMT     --近90天信用卡消费交易金额
       ,MIN(T1.CST_CC_CSM_RECENT_TO_NOW) CST_CC_CSM_RECENT_TO_NOW--13.客户信用卡消费交易近度
       ,SUM(T1.CST_CC_CSH_NBR)   CST_CC_CSH_NBR     --近90天取现/转出次数
       ,SUM(T1.CST_CC_CSH_AMT)   CST_CC_CSH_AMT     --近90天取现/转出金额
       ,MIN(T1.CST_CC_CSH_RECENT_TO_NOW) CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
       --,SUM(T1.TRX_NBR)          TRX_NBR            --过去90天整体交易的次数
       --,SUM(T1.TRX_AMT)          TRX_AMT            --过去90天整体交易的金额
FROM  LAB_BIGDATA_DEV.CUS_CRD_ACT_RFM T1
GROUP BY T1.CST_ID
;

SELECT * FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_RFM WHERE CST_ID = '1608083241';
SELECT * FROM LAB_BIGDATA_DEV.CUS_CRD_RFM_02 WHERE CST_ID = '1608083241';

-- 汇总到客户级
SELECT  T1.CST_ID
       ,T6_2.CST_CC_INSTL_NBR --近90天分期交易次数
       ,T6_2.CST_CC_INSTL_AMT   --近90天分期交易金额
       ,T6_2.CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
       ,T6_2.CST_CC_CSM_AMT     --近90天信用卡消费交易金额
       ,T6_2.CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
       ,T6_2.CST_CC_CSM_RECENT_TO_NOW--13.客户信用卡消费交易近度
       ,T6_2.CST_CC_CSH_NBR     --近90天取现/转出次数
       ,T6_2.CST_CC_CSH_AMT     --近90天取现/转出金额
       ,T6_2.CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
       ,COALESCE(T6_2.CST_CC_INSTL_NBR,0)+COALESCE(T6_2.CST_CC_CSM_NBR,0)+COALESCE(T6_2.CST_CC_CSH_NBR) TRX_NBR  --过去90天整体交易的次数
       ,COALESCE(T6_2.CST_CC_INSTL_AMT,0)+COALESCE(T6_2.CST_CC_CSM_AMT,0)+COALESCE(T6_2.CST_CC_CSH_AMT) TRX_AMT  --过去90天整体交易的金额
       ,CASE WHEN T6_2.CST_CC_CSM_RECENT_TO_NOW IS NULL AND T6_2.CST_CC_CSH_RECENT_TO_NOW IS NULL AND T6_2.CST_CC_INSTL_RECENT_TO_NOW IS NULL THEN NULL
             ELSE LEAST(COALESCE(T6_2.CST_CC_CSM_RECENT_TO_NOW,99999),COALESCE(T6_2.CST_CC_CSH_RECENT_TO_NOW,99999),COALESCE(T6_2.CST_CC_INSTL_RECENT_TO_NOW,99999))
        END CST_CC_RECENT_TO_NOW --12.客户信用卡整体交易近度
FROM  (
        SELECT  CST_ID
                ,MAX(MB_HANG_FLAG) MB_HANG_FLAG --手机银行下挂标识
        FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01
        WHERE CST_ID IS NOT NULL
        GROUP BY CST_ID
        )T1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CRD_RFM_02 T6_2
ON T1.CST_ID = T6_2.CST_ID
WHERE  T1.CST_ID = '1608083241'
;

返回输入参数中最小的一个 LEAST()
返回输入参数中最大的一个 GREATEST()





------------------------------------------ 客户级最早/最近交易情况 20220124----------------------------
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_TRX_DT_01;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_TRX_DT_01 AS
SELECT T1.CR_CRD_CARD_NBR
      ,T1.CST_ID
      ,T1.CRD_CTG_CD  --卡种
      ,T2.MIN_CSH_TRSF_DATE --卡最早一笔取现/转账交易日期
      ,T2.MAX_CSH_TRSF_DATE --卡最近一笔取现/转账交易日期
      ,T3.MIN_CSM_DATE --卡最早一笔消费交易日期
      ,T3.MAX_CSM_DATE --卡最近一笔消费交易日期
      ,T4.MIN_RCD_DT   --卡最早一笔分期交易日期
      ,T4.MAX_RCD_DT   --卡最近一笔分期交易日期
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01 T1
LEFT JOIN (
      SELECT CR_CRD_CARD_NBR
            ,MIN(TRX_DT) MIN_CSH_TRSF_DATE --卡最早一笔取现/转账交易日期
            ,MAX(TRX_DT) MAX_CSH_TRSF_DATE --卡最近一笔取现/转账交易日期
      FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
      WHERE DT <= '@@{yyyyMMdd}'
      AND TRX_TYP_CD >= '2000' AND TRX_TYP_CD <= '2999'
      GROUP BY CR_CRD_CARD_NBR
) T2
ON T1.CR_CRD_CARD_NBR = T2.CR_CRD_CARD_NBR
LEFT JOIN (
      SELECT CR_CRD_CARD_NBR
            ,MIN(CASE WHEN (TRX_AMT+BACK_AMT) > 0 THEN TRX_DT END) MIN_CSM_DATE --卡最早一笔消费交易日期
            ,MAX(CASE WHEN (TRX_AMT+BACK_AMT) > 0 THEN TRX_DT END) MAX_CSM_DATE --卡最近一笔消费交易日期
      FROM LAB_BIGDATA_DEV.CUS_CARD_P02
      GROUP BY CR_CRD_CARD_NBR
) T3
ON T1.CR_CRD_CARD_NBR = T3.CR_CRD_CARD_NBR
LEFT JOIN (
      SELECT CR_CRD_CARD_NBR
            ,MIN(RCD_DT)  MIN_RCD_DT   --卡最早一笔分期交易日期
            ,MAX(RCD_DT)  MAX_RCD_DT   --卡最近一笔分期交易日期
      FROM EDW.DWD_BUS_CRD_CR_CRD_INSTL_DTL_DD  A1
	WHERE DT = '@@{yyyyMMdd}'
      AND INSTL_PMT_STS NOT IN ('E','F')    -- xt
      GROUP BY  CR_CRD_CARD_NBR
) T4
ON T1.CR_CRD_CARD_NBR = T4.CR_CRD_CARD_NBR
;


--客户交易情况合并
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_TRX_DT;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_TRX_DT AS
SELECT CST_ID
      ,MIN(MIN_CSH_TRSF_DATE) MIN_CSH_TRSF_DATE --客户信用卡最早一笔取现/转账交易日期
      ,MAX(MAX_CSH_TRSF_DATE) MAX_CSH_TRSF_DATE --客户信用卡最近一笔取现/转账交易日期
      ,MIN(MIN_CSM_DATE) MIN_CSM_DATE           --客户信用卡最早一笔消费交易日期
      ,MAX(MAX_CSM_DATE) MAX_CSM_DATE           --客户信用卡最近一笔消费交易日期
      ,MIN(MIN_RCD_DT) MIN_RCD_DT   --客户信用卡最早一笔分期交易日期
      ,MAX(MAX_RCD_DT) MAX_RCD_DT   --客户信用卡最近一笔分期交易日期
      ,MIN(CASE WHEN CRD_CTG_CD = 1 THEN MIN_CSH_TRSF_DATE END) DBT_MIN_CSH_TRSF_DATE  --客户贷记卡最早一笔取现/转账交易日期
      ,MAX(CASE WHEN CRD_CTG_CD = 1 THEN MAX_CSH_TRSF_DATE END) DBT_MAX_CSH_TRSF_DATE  --客户贷记卡最近一笔取现/转账交易日期
      ,MIN(CASE WHEN CRD_CTG_CD = 1 THEN MIN_CSM_DATE END) DBT_MIN_CSM_DATE        --客户贷记卡最早一笔消费交易日期
      ,MAX(CASE WHEN CRD_CTG_CD = 1 THEN MAX_CSM_DATE END) DBT_MAX_CSM_DATE         --客户贷记卡最近一笔消费交易日期
      ,MIN(CASE WHEN CRD_CTG_CD = 1 THEN MIN_RCD_DT END) DBT_MIN_RCD_DT   --贷记卡最早一笔分期交易日期
      ,MAX(CASE WHEN CRD_CTG_CD = 1 THEN MAX_RCD_DT END) DBT_MAX_RCD_DT   --贷记卡最近一笔分期交易日期
FROM LAB_BIGDATA_DEV.CUS_TRX_DT_01
GROUP BY CST_ID
;

SELECT * FROM LAB_BIGDATA_DEV.CUS_CRD_TRX_DT ORDER BY CST_ID;

-- 汇总
SELECT T1.CST_ID
      ,T3.MIN_CSH_TRSF_DATE --客户信用卡最早一笔取现/转账交易日期
      ,T3.MAX_CSH_TRSF_DATE --客户信用卡最近一笔取现/转账交易日期
      ,T3.MIN_CSM_DATE           --客户信用卡最早一笔消费交易日期
      ,T3.MAX_CSM_DATE           --客户信用卡最近一笔消费交易日期
      ,T3.MIN_RCD_DT   --客户信用卡最早一笔分期交易日期
      ,T3.MAX_RCD_DT   --客户信用卡最近一笔分期交易日期
      ,T3.DBT_MIN_CSH_TRSF_DATE  --客户贷记卡最早一笔取现/转账交易日期
      ,T3.DBT_MAX_CSH_TRSF_DATE  --客户贷记卡最近一笔取现/转账交易日期
      ,T3.DBT_MIN_CSM_DATE        --客户贷记卡最早一笔消费交易日期
      ,T3.DBT_MAX_CSM_DATE         --客户贷记卡最近一笔消费交易日期
      ,T3.DBT_MIN_RCD_DT   --贷记卡最早一笔分期交易日期
      ,T3.DBT_MAX_RCD_DT   --贷记卡最近一笔分期交易日期
      ,CASE WHEN T3.MIN_CSH_TRSF_DATE IS NULL AND T3.MIN_CSM_DATE  IS NULL AND T3.MIN_RCD_DT  IS NULL THEN ''
            ELSE LEAST(COALESCE(T3.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(T3.MIN_CSM_DATE,'29991231'),COALESCE(T3.MIN_RCD_DT,'29991231'))
       END MIN_TRX_DATE           --卡最早一笔交易日期
      ,CASE WHEN T3.MAX_CSH_TRSF_DATE IS NULL AND T3.MAX_CSM_DATE IS NULL AND T3.MAX_RCD_DT IS NULL THEN ''
            ELSE GREATEST(COALESCE(T3.MAX_CSH_TRSF_DATE,'18991231'),COALESCE(T3.MAX_CSM_DATE,'18991231'),COALESCE(T3.MAX_RCD_DT,'18991231'))
       END MAX_TRX_DATE           --卡最近一笔交易日期
      ,CASE WHEN T3.DBT_MIN_CSH_TRSF_DATE IS NULL AND T3.DBT_MIN_CSM_DATE IS NULL AND T3.DBT_MIN_RCD_DT IS NULL THEN ''
            ELSE LEAST(COALESCE(T3.DBT_MIN_CSH_TRSF_DATE,'29991231'),COALESCE(T3.DBT_MIN_CSM_DATE,'29991231'),COALESCE(T3.DBT_MIN_RCD_DT,'29991231'))
       END DBT_MIN_TRX_DATE       --贷记卡最早一笔交易日期
      ,CASE WHEN T3.DBT_MAX_CSH_TRSF_DATE IS NULL AND T3.DBT_MAX_CSM_DATE IS NULL AND T3.DBT_MAX_RCD_DT IS NULL THEN ''
            ELSE GREATEST(COALESCE(T3.DBT_MAX_CSH_TRSF_DATE,'18991231'),COALESCE(T3.DBT_MAX_CSM_DATE,'18991231'),COALESCE(T3.DBT_MAX_RCD_DT,'18991231'))
       END DBT_MAX_TRX_DATE       --贷记卡最近一笔交易日期
      ,CASE WHEN T3.MAX_CSH_TRSF_DATE IS NULL AND T3.MAX_CSM_DATE IS NULL AND T3.MAX_RCD_DT IS NULL THEN '1'
            ELSE CASE WHEN GREATEST(COALESCE(T3.MAX_CSH_TRSF_DATE,'18991231'),COALESCE(T3.MAX_CSM_DATE,'18991231'),COALESCE(T3.MAX_RCD_DT,'18991231')) < '@@{yyyyMMdd - 90d}' THEN '1'
                      ELSE '0' END
       END SLEEP_F   --睡眠户
      ,CASE WHEN T3.MAX_CSH_TRSF_DATE IS NULL AND T3.MAX_CSM_DATE IS NULL AND T3.MAX_RCD_DT IS NULL THEN '1'
            ELSE CASE WHEN GREATEST(COALESCE(T3.MAX_CSH_TRSF_DATE,'18991231'),COALESCE(T3.MAX_CSM_DATE,'18991231'),COALESCE(T3.MAX_RCD_DT,'18991231')) < '@@{yyyyMMdd - 180d}' THEN '1'
                      ELSE '0' END
       END LOSS_F    --流失户
FROM  (
        SELECT  CST_ID
                ,MAX(MB_HANG_FLAG) MB_HANG_FLAG --手机银行下挂标识
        FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01
        WHERE CST_ID IS NOT NULL
        GROUP BY CST_ID
        )T1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CRD_TRX_DT T3
ON T1.CST_ID = T3.CST_ID
--WHERE T1.CST_ID = '1000000485'
;

--------------------------------------------- 到期日期情况 20220125 ----------------------------------
--改
SELECT
SELECT CST_ID
       ,MAX(CASE WHEN MTU_DAY<='@@{yyyyMMdd}' THEN MTU_DAY END ) LATE_DQ_MTU_DATE  --客户信用卡已到期最近日期
       ,MIN(CASE WHEN MTU_DAY>'@@{yyyyMMdd}'  THEN MTU_DAY END ) LATE_MTU_DATE    --客户信用卡即将到期最近日期
       ,MAX(CASE WHEN CRD_CTG_CD = 1 AND MTU_DAY <='@@{yyyyMMdd}'THEN MTU_DAY END ) LATE_DBT_DQ_MTU_DATE   --客户贷记卡已到期最近日期
       ,MIN(CASE WHEN CRD_CTG_CD = 1 AND MTU_DAY >'@@{yyyyMMdd}' THEN MTU_DAY END ) LATE_DBT_MTU_DATE       --客户贷记卡即将到期最近日期
FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
GROUP BY CST_ID
;
----------------- 他行贷记卡情况
--改：
-- 取1年内最近一笔征信报告
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_OTHER_LAST_ZX_REPORT_1;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.CUS_CRD_OTHER_LAST_ZX_REPORT_1 AS
SELECT  CST_ID
        ,REPORT_NO
        ,REPORT_DT
FROM    (
            SELECT  T.CST_ID
                    ,T.REPORT_NO
                    ,T.REPORT_DT
                    ,ROW_NUMBER() OVER ( PARTITION BY T.CST_ID ORDER BY T.REPORT_DT DESC ) ROW_NO
            FROM    EDW.DWS_CST_CCRC_IDV_IND_INF_DI T
            WHERE   T.DT <= '@@{yyyyMMdd}'
            AND     DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'yyyymmdd'), TO_DATE(SUBSTR(REPLACE(T.REPORT_DT, '-', ''), 1, 8), 'yyyymmdd'), 'dd') BETWEEN 0 AND 365 --取最近一年的征信报告
        ) A
WHERE   ROW_NO = 1;


--他行贷记卡情况
--！假设某个客户在同一家银行有多张信用卡，那可以直接相加吗？
-- DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_OTHER_LMT;
-- CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_OTHER_LMT AS
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_OTHER_LMT;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_OTHER_LMT AS
SELECT P.CST_ID
      ,SUM(P.ACT_CRD_LMT) OTH_BNK_ACT_CRD_LMT  --他行贷记卡授信额度
      ,SUM(P.USE_LMT) OTH_BNK_USE_LMT          --他行贷记卡用信额度
      ,CASE WHEN SUM(P.ACT_CRD_LMT) >0 THEN SUM(P.USE_LMT)/SUM(P.ACT_CRD_LMT) ELSE  0 END AS  OTH_BNK_USE_RATE  --他行贷记卡用信率
FROM (
SELECT T.CST_ID
      ,T.REPORT_NO
      ,T1.DTRB_ORG
      ,MAX(COALESCE(T1.ACT_CRD_LMT,0))  AS ACT_CRD_LMT --每个客户在每家银行授信额度
      ,SUM(COALESCE(T1.USE_LMT,0))     AS USE_LMT     --已用额度
FROM    LAB_BIGDATA_DEV.CUS_CRD_OTHER_LAST_ZX_REPORT_1 T
LEFT JOIN    EDW.DIM_CST_CCRC_IDV_LOAN_INF_DD T1
ON      T.REPORT_NO = T1.REPORT_ID
AND     T1.DT = '@@{yyyyMMdd}'
AND     T1.DTRB_ORG NOT LIKE '%ZJTLCB%'
AND     T1.ACT_TYP_CD IN ( 'R2' ) --筛选出贷记卡和准贷记卡账户,R2贷记卡R3准贷记卡
GROUP BY T.CST_ID,T.REPORT_NO,T1.DTRB_ORG
) P
GROUP BY P.CST_ID
;


------------------------------------------ 20220125 账户/客户级退出类型 --------------------------
-- 账户是否退出
-- 退出类型
-- 退出时间
WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05_1
SELECT CR_CRD_ACT_ID
      ,CST_ID
      ,CASE WHEN CUNXU_FLAG = 0 THEN '0' ELSE '1' END CUNXU_FLAG --账户是否存续0否1是
FROM (
SELECT CR_CRD_ACT_ID
      ,CST_ID
      ,SUM(CASE WHEN CUNXU_FLAG = '0' THEN 0 WHEN CUNXU_FLAG = '1' THEN 1 END) CUNXU_FLAG
FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
GROUP BY CR_CRD_ACT_ID
) T1

-- 退出类型
WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05_2
-- 退出时间
WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05_3


SELECT T1.CR_CRD_ACT_ID
      ,T1.CST_ID
      ,CASE WHEN T2.CUNXU_FLAG = '0' THEN T3.TYPE ELSE '' END TYPE  --账户级退出类型
      ,CASE WHEN T2.CUNXU_FLAG = '0' THEN T4.TYPE_DATE ELSE '' END TYPE_DATE  --账户级退出时间
FROM (
SELECT CR_CRD_ACT_ID,CST_ID --全量的账户号、客户号
FROM WB_BIGDATA_MANAGER_DEV.LIFE_PRD_CUS_CARD_SMY --卡级汇总表
GROUP BY CR_CRD_ACT_ID,CST_ID
) T1
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05_1 T2 ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
LEFT JOIN (
      SELECT CR_CRD_ACT_ID
            ,TYPE
      FROM (
      SELECT CR_CRD_ACT_ID
            ,TYPE
            ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY ORDER_CD) AS ROW_NO
      FROM WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05_2
      ) A
      WHERE A.ROW_NO = 1
)T3
ON T1.CR_CRD_ACT_ID = T3.CR_CRD_ACT_ID
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05_3 T4 ON T1.CR_CRD_ACT_ID = T4.CR_CRD_ACT_ID AND T4.ROW_NO_1 = 1

-----------------------------------------------------
-- 客户级退出类型/时间
-- 客户是否退出
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_QUIT_1;
CREATE TABLE LAB_BIGDATA_DEV.CUS_CRD_QUIT_1 AS
SELECT CST_ID
      ,CASE WHEN CUNXU_FLAG = 0 THEN '0' ELSE 1 END CUNXU_FLAG   --客户是否退出0否1是
FROM (
SELECT CST_ID
      ,SUM(CASE WHEN CUNXU_FLAG = '0' THEN 0 WHEN CUNXU_FLAG = '1' THEN 1 END) CUNXU_FLAG
FROM WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05_1
GROUP BY CST_ID
) T1
;

-- 客户退出类型/时间
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_QUIT;
CREATE TABLE LAB_BIGDATA_DEV.CUS_CRD_QUIT AS
SELECT T1.CST_ID
      ,CASE WHEN T2.CUNXU_FLAG = '0' THEN TYPE ELSE '' END TYPE
      ,CASE WHEN T2.CUNXU_FLAG = '0' THEN TYPE_DATE ELSE '' END TYPE_DATE
      ,TYPE_DATE
FROM    (
            SELECT  CST_ID --全量的账户号、客户号
            FROM    WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
            GROUP BY CST_ID
        ) T1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CRD_QUIT_1 T2 ON T1.CST_ID = T2.CST_ID
LEFT JOIN (
      SELECT CST_ID
            ,TYPE
            ,TYPE_DATE
      FROM (
      SELECT CST_ID
            ,TYPE
            ,TYPE_DATE
            ,ROW_NUMBER()OVER(PARTITION BY CST_ID ORDER BY TYPE_DATE DESC) AS ROW_NO
      FROM WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05
      ) A
      WHERE A.ROW_NO = 1
) T3
;


-- **************************************************** /*      账/客户级 退出类型/时间  20220125       */  ******************
---------整理之后的账户级退出类型/时间
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_ACT_05_1;
CREATE TABLE LAB_BIGDATA_DEV.CUS_CRD_ACT_05_1 AS
SELECT  CR_CRD_ACT_ID
        ,CST_ID
        ,CASE WHEN CUNXU_FLAG = 0 THEN '0' ELSE '1' END CUNXU_FLAG --账户是否存续0否1是
FROM    (
            SELECT  CR_CRD_ACT_ID
                    ,CST_ID
                    ,SUM(CASE WHEN CUNXU_FLAG = '0' THEN 0 WHEN CUNXU_FLAG = '1' THEN 1 END) CUNXU_FLAG
            FROM    LAB_BIGDATA_DEV.CUS_CARD_Z01
            GROUP BY CR_CRD_ACT_ID,CST_ID
        ) T1
;

-- 退出类型
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_05_2;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_05_2 AS
SELECT  CR_CRD_ACT_ID --账号
        ,CST_ID --客户号
        ,'核销'     AS TYPE
        ,'1'        AS ORDER_CD  --优先级标志
FROM    LAB_BIGDATA_DEV.CUS_CARD_Z01
WHERE   ACT_STS_CD = 'V'
UNION ALL
SELECT  CR_CRD_ACT_ID
        ,CST_ID
        ,'提前销户'  AS TYPE
        ,'2'         AS ORDER_CD
FROM    (
            SELECT  CR_CRD_ACT_ID --账号
                    ,CR_CRD_CARD_NBR --卡号
                    ,CST_ID
                    ,CARD_STS_CD --卡片状态
                    ,CARD_STS_DT --卡片状态日期
                    ,MTU_DAY --卡片到期时间
                    ,ROW_NUMBER() OVER ( PARTITION BY CR_CRD_ACT_ID ORDER BY CR_CRD_CARD_NBR DESC ) AS ROW_NUM
            FROM    LAB_BIGDATA_DEV.CUS_CARD_Z01
            WHERE   MAIN_CRD_IND = '1' --主卡
        ) A
WHERE   A.ROW_NUM = 1
AND     A.CARD_STS_CD = 'Q' --卡片状态为Q-销户申请
AND     A.CARD_STS_DT < A.MTU_DAY --卡片状态日<到期日
UNION ALL
SELECT  CR_CRD_ACT_ID
        ,CST_ID
        ,'过期未续'  AS TYPE
        ,'3'     AS ORDER_CD
FROM    (
            SELECT  CR_CRD_ACT_ID --账号
                    ,CR_CRD_CARD_NBR --卡号
                    ,CST_ID
                    ,CARD_STS_CD --卡片状态
                    ,CARD_STS_DT --卡片状态日期
                    ,MTU_DAY
                    ,ROW_NUMBER() OVER ( PARTITION BY CR_CRD_ACT_ID ORDER BY CR_CRD_CARD_NBR DESC ) AS ROW_NUM
            FROM    LAB_BIGDATA_DEV.CUS_CARD_Z01
            WHERE   MAIN_CRD_IND = '1' --主卡
        ) A
WHERE   ROW_NUM = 1
AND( A.CARD_STS_CD = '2'
    OR ( A.CARD_STS_CD = 'Q' AND     CARD_STS_DT >= MTU_DAY )
    OR ( CARD_STS_CD NOT IN ( '2' , 'Q' ) AND MTU_DAY < '@@{yyyyMMdd}' ) )
;


-- 退出时间
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_05_3;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_05_3 AS
SELECT  CR_CRD_ACT_ID --信用卡账户
        ,CST_ID       --客户号
        ,TYPE_DATE    --退出时间
        ,CR_CRD_CARD_NBR
        ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID  ORDER BY CR_CRD_CARD_NBR DESC ) ROW_NO_1 --按卡号排序
FROM  (
        SELECT CR_CRD_CARD_NBR --信用卡卡号
               ,CR_CRD_ACT_ID --信用卡账户
               ,CST_ID        --客户号
               ,TYPE
               ,TYPE_DATE
               ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID,CR_CRD_CARD_NBR ORDER BY TYPE_DATE) ROW_NO
        FROM  (
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'销户申请'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                WHERE  CARD_STS_CD = 'Q'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'过期未续时间'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                WHERE   CARD_STS_CD = '2'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'核销时间'  AS TYPE
                        ,ACT_STS_DT  AS TYPE_DATE
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                WHERE ACT_STS_CD = 'V'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'卡片过期时间'  AS TYPE
                        ,MTU_DAY AS TYPE_DATE
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                WHERE MTU_DAY <='@@{yyyyMMdd}'  --增加条件卡片已到期
               )T
      )T1
WHERE  ROW_NO = 1
;
SELECT *  FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_05_3 WHERE CR_CRD_ACT_ID = '0021104058';
SELECT *  FROM LAB_BIGDATA_DEV.CUS_CARD_Z01  WHERE CR_CRD_ACT_ID = '0021104058';


-- 账户级退出类型/时间汇总
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_ACT_05;
CREATE TABLE LAB_BIGDATA_DEV.CUS_CRD_ACT_05 AS
SELECT  T1.CR_CRD_ACT_ID
        ,T1.CST_ID
        ,CASE WHEN T2.CUNXU_FLAG = '0' THEN T3.TYPE ELSE '' END TYPE --账户级退出类型
        ,CASE WHEN T2.CUNXU_FLAG = '0' THEN T4.TYPE_DATE ELSE '' END TYPE_DATE --账户级退出时间
FROM    (
            SELECT  CR_CRD_ACT_ID
                    ,CST_ID --全量的账户号、客户号
            FROM    LAB_BIGDATA_DEV.CUS_CARD_Z01--卡级汇总表
            GROUP BY CR_CRD_ACT_ID , CST_ID
        ) T1
LEFT JOIN    LAB_BIGDATA_DEV.CUS_CRD_ACT_05_1 T2
ON      T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
LEFT JOIN    (
                 SELECT  CR_CRD_ACT_ID
                         ,TYPE
                 FROM    (
                             SELECT  CR_CRD_ACT_ID
                                     ,TYPE
                                     ,ROW_NUMBER() OVER ( PARTITION BY CR_CRD_ACT_ID ORDER BY ORDER_CD ) AS ROW_NO
                             FROM    LAB_BIGDATA_DEV.CUS_CRD_ACT_05_2
                         ) A
                 WHERE   A.ROW_NO = 1
             ) T3
ON      T1.CR_CRD_ACT_ID = T3.CR_CRD_ACT_ID
LEFT JOIN    LAB_BIGDATA_DEV.CUS_CRD_ACT_05_3 T4
ON      T1.CR_CRD_ACT_ID = T4.CR_CRD_ACT_ID
AND     T4.ROW_NO_1 = 1
;

SELECT * FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_05 WHERE TYPE = '核销' ORDER BY CR_CRD_ACT_ID ;

----------------------------------------------
--------------------整理后的客户退出类型/时间
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_QUIT_1;
CREATE TABLE LAB_BIGDATA_DEV.CUS_CRD_QUIT_1 AS
SELECT  CST_ID
        ,CASE
           WHEN CUNXU_FLAG = 0 THEN '0'
           ELSE 1
         END CUNXU_FLAG --客户是否退出0否1是
FROM    (
            SELECT  CST_ID
                    ,SUM(CASE WHEN CUNXU_FLAG = '0' THEN 0 WHEN CUNXU_FLAG = '1' THEN 1 END) CUNXU_FLAG
            FROM    LAB_BIGDATA_DEV.CUS_CRD_ACT_05_1
            GROUP BY CST_ID
        ) T1;



-- 客户退出类型/时间
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_QUIT;
CREATE TABLE LAB_BIGDATA_DEV.CUS_CRD_QUIT AS
SELECT T1.CST_ID
      ,CASE WHEN T2.CUNXU_FLAG = '0' THEN TYPE ELSE '' END TYPE
      ,CASE WHEN T2.CUNXU_FLAG = '0' THEN TYPE_DATE ELSE '' END TYPE_DATE
FROM    (
            SELECT  CST_ID --全量的账户号、客户号
            FROM    LAB_BIGDATA_DEV.CUS_CARD_Z01
            GROUP BY CST_ID
        ) T1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CRD_QUIT_1 T2 ON T1.CST_ID = T2.CST_ID
LEFT JOIN (
      SELECT CST_ID
            ,TYPE
            ,TYPE_DATE
      FROM (
      SELECT CST_ID
            ,TYPE
            ,TYPE_DATE
            ,ROW_NUMBER()OVER(PARTITION BY CST_ID ORDER BY TYPE_DATE DESC) AS ROW_NO
      FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_05
      ) A
      WHERE A.ROW_NO = 1
) T3
ON T1.CST_ID = T3.CST_ID
;

-----------------------------------------------------20220125 备用金--------------------------------
--备用金基础信息
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT ;
CREATE  TABLE  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT AS
SELECT   T1.CR_CRD_CARD_NBR --信用卡卡号
         ,T1.CR_CRD_ACT_ID --信用卡账户
         ,T1.CST_ID  CST_ID   --客户号
         ,T2.SERIALNO --流水号
  ,T2.RELATIVESERIALNO  --相关批准流水号
         ,COALESCE(T2.BUSINESSSUM,0) BUSINESSSUM  --金额
         ,COALESCE(T2.BUSINESSRATE,0)  BUSINESSRATE  --利率
         ,T2.CHANNEL     --备用金申请渠道
         ,T2.OCCURDATE  --发生日期
         ,T2.MATURITY   --约定到期日期
         ,T2.FINISHDATE   --终结日期
         ,CASE WHEN   REPLACE(T2.OCCURDATE, '/', '') <= T2.DT
                AND REPLACE(T2.MATURITY, '/', '')>= T2.DT
                AND T2.FINISHDATE  IS NULL THEN  '1' ELSE '0' END  AS END_STATUS  --('1' 未结清 )
FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01  T1
LEFT JOIN EDW.LOAN_BUSINESS_CONTRACT T2
ON T1.CR_CRD_CARD_NBR = T2.ACCOUNTNO  AND T2.DT = '@@{yyyyMMdd}'
;



-- ******************************* 20220126 汇总 *****************************
--到期日期情况
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_MTU_DAY;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_MTU_DAY AS
SELECT  CST_ID
        ,LATE_DQ_MTU_DATE     --客户信用卡已到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_DQ_MTU_DATE, 'YYYYMMDD'), 'DD') LATE_DQ_MTU_DAYS   --客户信用卡已到期最近天数
        ,LATE_MTU_DATE    --客户信用卡即将到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_MTU_DATE, 'YYYYMMDD'), 'DD') LATE_MTU_DAYS      --客户信用卡即将到期最近天数
        ,LATE_DBT_DQ_MTU_DATE --客户贷记卡已到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_DBT_DQ_MTU_DATE, 'YYYYMMDD'), 'DD') LATE_DBT_DQ_MTU_DAYS --客户贷记卡已到期最近天数
        ,LATE_DBT_MTU_DATE  --客户信用卡即将到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_DBT_MTU_DATE, 'YYYYMMDD'), 'DD')  LATE_DBT_MTU_DAYS  --客户信用卡即将到期最近天数
FROM (
       SELECT CST_ID
              ,MAX(CASE WHEN MTU_DAY<='@@{yyyyMMdd}' THEN MTU_DAY END ) LATE_DQ_MTU_DATE  --客户信用卡已到期最近日期
              ,MIN(CASE WHEN MTU_DAY>'@@{yyyyMMdd}'  THEN MTU_DAY END ) LATE_MTU_DATE    --客户信用卡即将到期最近日期
              ,MAX(CASE WHEN CRD_CTG_CD = 1 AND MTU_DAY <='@@{yyyyMMdd}'THEN MTU_DAY END ) LATE_DBT_DQ_MTU_DATE   --客户贷记卡已到期最近日期
              ,MIN(CASE WHEN CRD_CTG_CD = 1 AND MTU_DAY >'@@{yyyyMMdd}' THEN MTU_DAY END ) LATE_DBT_MTU_DATE       --客户贷记卡即将到期最近日期
       FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01)T1
       GROUP BY CST_ID
)T1
;


--信用卡客户级额度
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_LMT;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_LMT AS
SELECT  T1.CST_ID
        ,MAX(CASE WHEN T1.CUNXU_FLAG = '1' THEN  T2.CRD_LMT ELSE 0 END ) CRD_LMT --信用卡客户级额度
        ,SUM(T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL) CRD_USED_AMT --信用卡用信金额
        ,MAX(CASE WHEN T1.CRD_CTG_CD = '1' AND T1.CUNXU_FLAG = '1' THEN T2.CRD_LMT ELSE 0 END ) DBT_CRD_LMT --贷记卡客户级额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = '1'  THEN T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL END ) DBT_CRD_USED_AMT--贷记卡用信金额
FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.MAIN_CARD_CARD_NBR = T2.LATE_MAIN_CARD_CARD_NBR
WHERE T2.DT  = '@@{yyyyMMdd}'
GROUP BY  T1.CST_ID
;


-- 消费情况
--支付宝、财付通交易笔数、金额
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_TRX_ZFB;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_TRX_ZFB AS
SELECT CST_ID
       ,SUM(ZFB_AMT_90) ZFB_AMT_90    --近90天支付宝交易金额
       ,SUM(ZFB_NBR_90) ZFB_NBR_90    --近90天支付宝交易笔数
       ,SUM(CFT_AMT_90) CFT_AMT_90    --近90天财付通交易金额
       ,SUM(CFT_NBR_90) CFT_NBR_90    --近90天财付通交易笔数
       ,SUM(ZFB_AMT_30) ZFB_AMT_30    --近30天支付宝交易金额
       ,SUM(ZFB_NBR_30) ZFB_NBR_30    --近30天支付宝交易笔数
       ,SUM(CFT_AMT_30) CFT_AMT_30    --近30天财付通交易金额
       ,SUM(CFT_NBR_30) CFT_NBR_30    --近30天财付通交易笔数
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_AMT_90) INB_CREDITCARD_REPAST_CONSUME_AMT_90       --近90天餐饮交易金额
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_CNT_90) INB_CREDITCARD_REPAST_CONSUME_CNT_90       --近90天餐饮交易笔数
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_AMT_90)  INB_CREDITCARD_PLANE_CONSUME_AMT_90        --近90天航旅交易金额
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_CNT_90)  INB_CREDITCARD_PLANE_CONSUME_CNT_90        --近90天航旅交易笔数
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_AMT_90)  INB_CREDITCARD_ABROAD_CONSUME_AMT_90      --近90天境外交易金额
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_CNT_90)  INB_CREDITCARD_ABROAD_CONSUME_CNT_90      --近90天境外交易笔数
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_AMT_30) INB_CREDITCARD_REPAST_CONSUME_AMT_30       --近30天餐饮交易金额
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_CNT_30) INB_CREDITCARD_REPAST_CONSUME_CNT_30       --近30天餐饮交易笔数
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_AMT_30)  INB_CREDITCARD_PLANE_CONSUME_AMT_30        --近30天航旅交易金额
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_CNT_30)  INB_CREDITCARD_PLANE_CONSUME_CNT_30        --近30天航旅交易笔数
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_AMT_30)  INB_CREDITCARD_ABROAD_CONSUME_AMT_30      --近30天境外交易金额
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_CNT_30)  INB_CREDITCARD_ABROAD_CONSUME_CNT_30      --近30天境外交易笔数
FROM   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03  --可直接换成卡级汇总表
GROUP BY CST_ID
;


--RFM(要存续卡)
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_RFM;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_RFM AS
SELECT T1.CST_ID
      ,T1.CR_CRD_ACT_ID
      ,COUNT(CASE WHEN T3.RCD_DT >= '@@{yyyyMMdd - 90d}' AND T3.RCD_DT <= '@@{yyyyMMdd}' THEN T3.TOT_PD_AMT END)    CST_CC_INSTL_NBR      --近90天分期交易次数
      ,SUM(CASE WHEN T3.RCD_DT >= '@@{yyyyMMdd - 90d}' AND T3.RCD_DT <= '@@{yyyyMMdd}' THEN T3.TOT_PD_AMT ELSE 0 END)  CST_CC_INSTL_AMT   --近90天分期交易金额
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T3.RCD_DT, 'YYYYMMDD'), 'DD') + 1) CST_CC_INSTL_RECENT_TO_NOW            --15.客户信用卡分期交易近度
      ,SUM(CASE WHEN T4.DT>= '@@{yyyyMMdd - 90d}' AND T4.DT <= '@@{yyyyMMdd}' THEN (T4.TRX_AMT + T4.BACK_AMT) END ) AS CST_CC_CSM_AMT     --近90天信用卡消费交易金额
      ,SUM(CASE WHEN T4.DT>= '@@{yyyyMMdd - 90d}' AND T4.DT <= '@@{yyyyMMdd}' AND (T4.TRX_AMT + T4.BACK_AMT) > 0 THEN 1 ELSE 0 END ) CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T4.TRX_DT, 'YYYYMMDD'), 'DD') + 1) CST_CC_CSM_RECENT_TO_NOW              --13.客户信用卡消费交易近度
      ,SUM(CASE WHEN T5.DT >= '@@{yyyyMMdd - 90d}' AND T5.DT <= '@@{yyyyMMdd}' THEN 1 ELSE 0 END) CST_CC_CSH_NBR                          --近90天取现/转出次数
      ,SUM(CASE WHEN T5.DT >= '@@{yyyyMMdd - 90d}' AND T5.DT <= '@@{yyyyMMdd}' THEN T5.TRX_AMT ELSE 0 END) CST_CC_CSH_AMT                 --近90天取现/转出金额
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T5.TRX_DT, 'YYYYMMDD'), 'DD') + 1)  CST_CC_CSH_RECENT_TO_NOW             --14.客户信用卡取现/转出交易近度
FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1  --信用卡账户信息汇总
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 T2 ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID --卡级主表
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_INSTL_DTL_DD T3 ON T1.CR_CRD_ACT_ID = T3.CR_CRD_ACT_ID AND T1.DT = T3.DT AND T3.INSTL_PMT_STS NOT IN ('E','F')  --信用卡分期明细:分期付款状态<>E/F (错误终止/退货终止)
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 T4 ON T1.CR_CRD_ACT_ID = T4.CR_CRD_ACT_ID  --消费:剔除退货
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI T5 ON T1.CR_CRD_ACT_ID = T5.CR_CRD_ACT_ID AND T5.DT <= '@@{yyyyMMdd}' AND T5.TRX_TYP_CD >= '2000' AND T5.TRX_TYP_CD <= '2999' AND T5.WDW_RVS_IND <> '1'   --取现/转账:信用卡交易流水表
WHERE T1.DT = '@@{yyyyMMdd}'
AND T2.CUNXU_FLAG = '1'  --存续标志
GROUP BY T1.CST_ID, T1.CR_CRD_ACT_ID
;
--RFM 02
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_RFM_02;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_RFM_02 AS
SELECT T1.CST_ID
       ,SUM(T1.CST_CC_INSTL_NBR) CST_CC_INSTL_NBR   --近90天分期交易次数
       ,SUM(T1.CST_CC_INSTL_AMT) CST_CC_INSTL_AMT   --近90天分期交易金额
       ,MIN(T1.CST_CC_INSTL_RECENT_TO_NOW)  CST_CC_INSTL_RECENT_TO_NOW --15.客户信用卡分期交易近度
       ,SUM(T1.CST_CC_CSM_NBR)   CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
       ,SUM(T1.CST_CC_CSM_AMT)   CST_CC_CSM_AMT     --近90天信用卡消费交易金额
       ,MIN(T1.CST_CC_CSM_RECENT_TO_NOW) CST_CC_CSM_RECENT_TO_NOW--13.客户信用卡消费交易近度
       ,SUM(T1.CST_CC_CSH_NBR)   CST_CC_CSH_NBR     --近90天取现/转出次数
       ,SUM(T1.CST_CC_CSH_AMT)   CST_CC_CSH_AMT     --近90天取现/转出金额
       ,MIN(T1.CST_CC_CSH_RECENT_TO_NOW) CST_CC_CSH_RECENT_TO_NOW  --14.客户信用卡取现/转出交易近度
FROM  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_RFM T1
GROUP BY T1.CST_ID
;



--还款次数
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_RPAY_NUM;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_RPAY_NUM AS
SELECT  T2.CST_ID
        ,SUM(AUTO_DDCT_RPAY_NUM)     AUTO_DDCT_RPAY_NUM      --近12个月自扣还款次数
        ,SUM(NOT_AUTO_DDCT_RPAY_NUM) NOT_AUTO_DDCT_RPAY_NUM  --近12个月非自扣本行渠道次数
        ,SUM(NOT_OWNBANK_CHNL_NUM)   NOT_OWNBANK_CHNL_NUM    --近12个月非本行渠道还款次数
FROM WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_02  T1
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 T2
ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID
GROUP BY  T2.CST_ID
;



--最近一次还款方式、最近一次还款渠道、最近一次还款交易日期
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_LAST_PRAY;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_LAST_PRAY AS
SELECT  CST_ID
        ,METHOD_REPAY LAST_METHOD_REPAY      --最近一次还款方式
        ,CHANN_REPAY  LAST_CHANN_REPAY       --最近一次还款渠道
        ,TRX_DT       LAST_TRX_DT            --最近一次还款交易日期
FROM  (
        SELECT  T2.CST_ID
                ,T1.METHOD_REPAY      --还款方式
                ,T1.CHANN_REPAY       --还款渠道
                ,T1.TRX_DT            --交易日期
                ,ROW_NUMBER() OVER ( PARTITION BY T2.CST_ID ORDER BY T1.TRX_DT DESC ) AS ROW_NO
       FROM WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_01 T1
       LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 T2
       ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID )T
WHERE T.ROW_NO = 1
;

---------------------------------------- ODS字段 ----------------------
SELECT  CARD_NBR
                    ,CASE WHEN THD_PTY_BIND  = '绑定'   THEN  '1' ELSE 0 END AS THD_PTY_BIND
                    ,CASE WHEN ZFB_BIND      = '绑定'   THEN  '1' ELSE 0 END AS ZFB_BIND
                    ,CASE WHEN FRS_THDPTY_BIND_DT <> '' THEN  '1' ELSE 0 END AS HIS_THD_PTY_BIND
                    ,CASE WHEN FRS_ZFB_BIND_DT <> '' THEN  '1' ELSE 0 END AS HIS_ZFB_BIND
             FROM   APP_ADO.CR_CRD_EPCC_CR_AR_INF
             WHERE DT  ='@@{yyyyMMdd}'

-- 0，8
SELECT LENGTH(FRS_THDPTY_BIND_DT)
      ,LENGTH(FRS_ZFB_BIND_DT)
FROM   APP_ADO.CR_CRD_EPCC_CR_AR_INF
WHERE DT  ='@@{yyyyMMdd}'
GROUP BY LENGTH(FRS_THDPTY_BIND_DT),LENGTH(FRS_ZFB_BIND_DT)

-- 进件渠道
SELECT AAA
FROM (
SELECT CASE WHEN  CHANNELIN IN ('小鱼bank渠道','客服App端','e卖通','Mini泰e贷','小鱼泡泡','外包外呼') THEN  CHANNELIN  ELSE '' END AAA
FROM (
       SELECT A.CR_CRD_CARD_NBR   --信用卡卡号
              ,A.CR_CRD_ACT_ID --信用卡账户
              ,A.CST_ID  CST_ID   --客户号
              --,A.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
              ,CASE  WHEN T1.DATA_FLG = '3' THEN COALESCE(T2.PRODUCT_NAME, '')
                     WHEN T1.DATA_FLG = '2' THEN COALESCE(T1.CHANNELIN, '')
                     ELSE COALESCE(T1.CHANNEL, '')
                END AS CHANNELIN  -- 进件渠道
              ,T1.RECVALUE   --推荐用户值(送信贷值)
              ,T1.APPLYDATE    --申请日期
       FROM  EDW.DIM_BUS_CRD_CR_CRD_INF_DD   A --信用卡卡片信息表
       LEFT JOIN  APP_RPT.FCT_CRD_CARD_APL_INFO T1
       ON A.BUSI_APL_ID = T1.SERIALNO AND T1.DT = '@@{yyyyMMdd}'     --信用卡申请表
       LEFT JOIN (
                   SELECT  APPLY_SEQ_NO
                           ,PRODUCT_NAME
                           ,ROW_NUMBER() OVER ( PARTITION BY APPLY_SEQ_NO ) AS RN
                   FROM    EDW.SFPS_TB_JD_BUINESS_INFO -- 金融云申请渠道
                   WHERE   DT = '@@{yyyyMMdd}'
                  ) T2
       ON  T2.APPLY_SEQ_NO = T1.SERIALNO AND T2.RN = 1
       WHERE A.DT = '@@{yyyyMMdd}'
) T1
) T2
WHERE T2.AAA <> ''

--  续卡发卡日期
SELECT *
FROM (
SELECT SUBSTR(T.CR_CRD_CARD_NBR,1,6) A1
      ,SUBSTR(T.CR_CRD_CARD_NBR,7,LENGTH(T.CR_CRD_CARD_NBR)) A2
      ,T.ISU_DT
      ,T7.CARDNO
      ,T7.REISSUEDATE
      ,ROW_NUMBER()OVER(PARTITION BY T.CR_CRD_CARD_NBR ORDER BY ISU_DT) AS RN
      ,CASE WHEN T7.CARDNO IS NOT NULL THEN CONCAT(SUBSTR(T7.REISSUEDATE,1,4),SUBSTR(T7.REISSUEDATE,6,2),SUBSTR(T7.REISSUEDATE,9,2)) ELSE T.ISU_DT END ISU_DT1 --发卡日期（已更改续卡发卡日期）
FROM   EDW.DIM_BUS_CRD_CR_CRD_INF_DD  T --信用卡卡片信息
LEFT JOIN EDW.LOAN_CREDITCARD_INFO T7
ON T.CR_CRD_CARD_NBR = T7.CARDNO  AND T7.DT = '@@{yyyyMMdd}' AND T7.ISSUEREAS = 'X'
WHERE T.DT = '@@{yyyyMMdd}'
ORDER BY T.CR_CRD_CARD_NBR
) AA
WHERE AA.RN > 1
;


SELECT CR_CRD_CARD_NBR
       ,CASE WHEN CARD_ACTV_DT = '18991231'  THEN  DATEDIFF(TO_DATE('@@{yyyyMMdd}}','YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '已激活' END AS UNACTV_DAYS  --未激活天数
       ,CASE WHEN CARD_ACTV_DT <> '18991231' THEN  DATEDIFF(TO_DATE(CARD_ACTV_DT,'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '未激活' END AS  ISU_ACTV_DAYS  --发卡与激活间隔天数
       ,INPUT_F   --是否完成首刷
       ,INPUTDATE --首刷时间
       ,CASE WHEN INPUTDATE ='截至昨天未用款' THEN INPUTDATE
             ELSE DATEDIFF(TO_DATE(REPLACE(INPUTDATE, '/', ''),'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
             END AS  ISU_INP_DAYS  --发卡与首刷间隔天数
       ,STB_AMT_F  --是否开通备用金
FROM  (
SELECT   T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.ISU_DT     --发卡日期
        ,T.CARD_ACTV_DT   --卡片激活日期
        ,CASE WHEN B.SERIALNO IS NULL THEN '0' ELSE '1' END AS STB_AMT_F  --是否开通备用金
        ,CASE WHEN C.SERIALNO IS NULL THEN '截至昨天未用款' ELSE C.INPUTDATE  END  AS INPUTDATE --首刷时间
        ,CASE WHEN C.SERIALNO IS NULL THEN '0' ELSE '1'  END  AS INPUT_F --是否完成首刷
--FROM   WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01  T
FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01  T
LEFT JOIN EDW.LOAN_BUSINESS_CONTRACT B
ON B.ACCOUNTNO = T.CR_CRD_CARD_NBR AND B.DT = '@@{yyyyMMdd}'
LEFT JOIN EDW.LOAN_BUSINESS_DUEBILL C
ON C.RELATIVESERIALNO2 = B.SERIALNO AND C.DT = '@@{yyyyMMdd}'
)P
;

--------------------- 将是否开通备用金、首刷分开
-- 备用金
SELECT CR_CRD_CARD_NBR
       ,CASE WHEN CARD_ACTV_DT = '18991231'  THEN  DATEDIFF(TO_DATE('@@{yyyyMMdd}}','YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '已激活' END AS UNACTV_DAYS  --未激活天数
       ,CASE WHEN CARD_ACTV_DT <> '18991231' THEN  DATEDIFF(TO_DATE(CARD_ACTV_DT,'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '未激活' END AS  ISU_ACTV_DAYS  --发卡与激活间隔天数
       ,INPUT_F   --是否完成首刷
       ,INPUTDATE --首刷时间
       ,CASE WHEN INPUTDATE ='未首刷' THEN INPUTDATE
             ELSE DATEDIFF(TO_DATE(INPUTDATE,'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
             END AS  ISU_INP_DAYS  --发卡与首刷间隔天数
       ,STB_AMT_F  --是否开通备用金
FROM  (
SELECT   T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.ISU_DT     --发卡日期
        ,T.CARD_ACTV_DT   --卡片激活日期
        ,CASE WHEN B.SERIALNO IS NULL THEN '0' ELSE '1' END AS STB_AMT_F  --是否开通备用金
        ,CASE WHEN C.MIN_TRX_DATE = '' THEN '未首刷' ELSE C.MIN_TRX_DATE END AS INPUTDATE --首刷时间
        ,CASE WHEN C.MIN_TRX_DATE = '' THEN '0' ELSE '1' END AS INPUT_F --是否完成首刷
--FROM   WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01  T
FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01  T
LEFT JOIN EDW.LOAN_BUSINESS_CONTRACT B
ON B.ACCOUNTNO = T.CR_CRD_CARD_NBR AND B.DT = '@@{yyyyMMdd}'
LEFT JOIN (
      SELECT CR_CRD_CARD_NBR
      ,CASE WHEN MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL THEN ''
            ELSE LEAST(COALESCE(MIN_CSH_TRSF_DATE,'29991231'),COALESCE(MIN_CSM_DATE,'29991231'),COALESCE(MIN_RCD_DT,'29991231'))
      END MIN_TRX_DATE           --卡最早一笔交易日期
      --FROM WB_BIGDATA_MANAGER_DEV.CUS_TRX_DT_01
      FROM LAB_BIGDATA_DEV.CUS_TRX_DT_01
) C ON T.CR_CRD_CARD_NBR = C.CR_CRD_CARD_NBR
)P
;

MIN_CSH_TRSF_DATE



-- 信用卡最早一笔交易日期：首刷日期
SELECT CR_CRD_CARD_NBR
      ,CASE WHEN T3.MIN_CSH_TRSF_DATE IS NULL AND T3.MIN_CSM_DATE  IS NULL AND T3.MIN_RCD_DT  IS NULL THEN ''
            ELSE LEAST(COALESCE(T3.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(T3.MIN_CSM_DATE,'29991231'),COALESCE(T3.MIN_RCD_DT,'29991231'))
      END MIN_TRX_DATE           --卡最早一笔交易日期
FROM WB_BIGDATA_MANAGER_DEV.CUS_TRX_DT_01


-- 客户级备用金
--备用金基础信息
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_xt ;
CREATE  TABLE  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_xt AS
SELECT   T1.CR_CRD_CARD_NBR --信用卡卡号
         ,T1.CR_CRD_ACT_ID --信用卡账户
         ,T1.CST_ID  CST_ID   --客户号
         ,T2.SERIALNO --流水号
  ,T2.RELATIVESERIALNO  --相关批准流水号
         ,COALESCE(T2.BUSINESSSUM,0) BUSINESSSUM  --额度
         ,COALESCE(T2.BUSINESSRATE,0)  BUSINESSRATE --利率
         ,T2.CHANNEL     --备用金申请渠道
         ,T3.LIMIT_STATUS  --授信状态：U 未激活、N正常、V授信到期、M逾期临时止付、F逾期永久止付、T风险止付、S授信终止，计算金额和利率时剔除&ldquo;到期和终止&rdquo;
         ,CASE WHEN T3.LIMIT_STATUS IN ('V','S') THEN '0' ELSE '1' END AS IS_VALID --备用金合同是否有效
      --    ,T2.OCCURDATE  --发生日期
      --    ,T2.MATURITY   --约定到期日期
      --    ,T2.FINISHDATE   --终结日期
      --    ,CASE WHEN   REPLACE(T2.OCCURDATE, '/', '') <= T2.DT
      --           AND REPLACE(T2.MATURITY, '/', '')>= T2.DT
      --           AND T2.FINISHDATE  IS NULL THEN  '1' ELSE '0' END  AS END_STATUS  --('1' 未结清 ) --合同是否有效
FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01  T1
LEFT JOIN EDW.LOAN_BUSINESS_CONTRACT T2
ON T1.CR_CRD_CARD_NBR = T2.ACCOUNTNO  AND T2.DT = '@@{yyyyMMdd}'
LEFT JOIN (
      SELECT B.CARD_NO       --信用卡卡号
            ,A.LIMIT_STATUS  --授信状态
      FROM EDW.NCRD_ACCTINFO A
      INNER JOIN    EDW.NCRD_CONTRACTINFO B
      ON      A.CONTR_NO = B.CONTR_NO
      AND B.DT = '@@{yyyyMMdd}'
      WHERE A.DT = '@@{yyyyMMdd}'
) T3
ON T1.CR_CRD_CARD_NBR = T3.CARD_NO
;


-- 备用金额度/利率、最早/最近一笔申请日期、最早/最近一笔借据发生日期
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_INF ;
CREATE  TABLE  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_INF AS
SELECT T1.CST_ID
      ,SUM(CASE WHEN IS_VALID = '1' THEN BUSINESSSUM ELSE 0 END) BUSINESSSUM --授信额度
      ,CASE WHEN SUM(CASE WHEN IS_VALID = '1' THEN BUSINESSSUM ELSE 0 END) = 0 THEN 0
            ELSE SUM(CASE WHEN IS_VALID = '1' THEN BUSINESSSUM * BUSINESSRATE ELSE 0 END)/SUM(CASE WHEN IS_VALID = '1' THEN BUSINESSSUM ELSE 0 END)
       END WT_BUSINESSRATE --备用金授信加权平均利率
      ,MIN(CASE WHEN T2.APL_DT IS NOT NULL THEN T2.APL_DT END) EAR_APL_DT   --备用金最早一笔申请日期
      ,MAX(CASE WHEN T2.APL_DT IS NOT NULL THEN T2.APL_DT END) LST_APL_DT   --备用金最近一笔申请日期
      ,MIN(CASE WHEN T3.DTRB_DT IS NOT NULL THEN T3.DTRB_DT END) EAR_DTRB_DT   --备用金最早一笔借据发生日期
      ,MAX(CASE WHEN T3.DTRB_DT IS NOT NULL THEN T3.DTRB_DT END) LST_DTRB_DT   --备用金最近一笔借据发生日期
FROM LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_xt T1
LEFT JOIN EDW.DWD_BUS_LOAN_APL_INF_DD T2 ON T1.RELATIVESERIALNO  = T2.APL_ID  AND T2.DT  = '@@{yyyyMMdd}'
LEFT JOIN  EDW.DIM_BUS_LOAN_DBIL_INF_DD T3 ON T1.SERIALNO = T3.BUS_CTR_ID AND T3.DT  =  '@@{yyyyMMdd}'
GROUP BY T1.CST_ID
;

SELECT *
FROM LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_INF
WHERE BUSINESSSUM IS NOT NULL AND EAR_APL_DT IS NOT NULL AND EAR_DTRB_DT IS NOT NULL
;

SELECT *
FROM LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_INF
WHERE EAR_APL_DT <> LST_APL_DT

SELECT T1.CST_ID
      ,T1.RELATIVESERIALNO
      ,T2.APL_ID
      ,T2.APL_DT
FROM LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_xt T1
LEFT JOIN EDW.DWD_BUS_LOAN_APL_INF_DD T2 ON T1.RELATIVESERIALNO  = T2.APL_ID  AND T2.DT  = '@@{yyyyMMdd}'
WHERE
 T1.CST_ID = '1000063302'


--备用金额度、利率
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_2 ;
CREATE  TABLE  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_2 AS
SELECT  CST_ID
       ,SUM(CASE
               WHEN IS_VALID = '1' THEN BUSINESSSUM
               ELSE 0
             END)           AS BUSINESSSUM  --授信额度     --待确认是不是只统计未结清状态
         ,CASE
           WHEN SUM(CASE
                      WHEN IS_VALID = '1' THEN BUSINESSSUM
                      ELSE 0
                    END) = 0 THEN 0
           ELSE SUM(CASE
                      WHEN IS_VALID = '1' THEN BUSINESSSUM * BUSINESSRATE
                      ELSE 0
                    END) / SUM(CASE
                                 WHEN IS_VALID = '1' THEN BUSINESSSUM
                                 ELSE 0
                               END)
         END                AS WT_BUSINESSRATE --我行贷款授信加权平均利率
FROM  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT
GROUP BY CST_ID
;


DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_CHN;
CREATE  TABLE  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_CHN AS
SELECT  CST_ID,CHANNEL STB_APY_CHN ----备用金申请渠道偏好
FROM (
       SELECT CST_ID
              ,CHANNEL
              ,ROW_NUMBER() OVER(PARTITION BY CST_ID ORDER BY NUM DESC) ROW_NO
       FROM  (
               SELECT CST_ID,CHANNEL,COUNT(1) NUM
               FROM  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT
               GROUP BY  CST_ID,CHANNEL
              )
    ) WHERE ROW_NO = 1
;

SELECT DT FROM EDW.NCRD_ACCTINFO WHERE DT = '20220124';










SELECT *
FROM  (
        SELECT  CST_ID
                ,MAX(MB_HANG_FLAG) MB_HANG_FLAG --手机银行下挂标识
				,MAX(CRD_LVL)  CRD_LVL_HIS --历史卡的等级最高
                ,MAX(CASE WHEN CUNXU_FLAG = 1 THEN CRD_LVL  END   ) CRD_LVL_NOW  --客户信用卡当前最高等级
        FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01
        WHERE CST_ID IS NOT NULL
        GROUP BY CST_ID
        )T1
LEFT JOIN (
    SELECT CST_ID , CHANNEL STB_APY_CHN ----备用金申请渠道偏好
    FROM (
        SELECT CST_ID
              , CHANNEL
              , ROW_NUMBER ( ) OVER ( PARTITION BY CST_ID ORDER BY NUM DESC ) ROW_NO
        FROM (
            SELECT CST_ID
                 , CHANNEL
                 , COUNT ( 1 ) NUM
            FROM LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_xt
            GROUP BY CST_ID , CHANNEL
            )
        )
        WHERE ROW_NO = 1
) T13 ON T1 . CST_ID = T13 . CST_ID



--------------------------------------------------------------------------------
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CARD_ACT_DAYS;
CREATE TABLE   LAB_BIGDATA_DEV.CUS_CARD_ACT_DAYS AS
SELECT CR_CRD_CARD_NBR
       ,CASE WHEN CARD_ACTV_DT = '18991231'  THEN  DATEDIFF(TO_DATE('@@{yyyyMMdd}}','YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '已激活' END AS UNACTV_DAYS  --未激活天数
       ,CASE WHEN CARD_ACTV_DT <> '18991231' THEN  DATEDIFF(TO_DATE(CARD_ACTV_DT,'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '未激活' END AS  ISU_ACTV_DAYS  --发卡与激活间隔天数
       ,INPUT_F   --是否完成首刷
       ,INPUTDATE --首刷时间
       ,CASE WHEN INPUTDATE ='未首刷' THEN INPUTDATE
             ELSE DATEDIFF(TO_DATE(INPUTDATE,'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
             END AS  ISU_INP_DAYS  --发卡与首刷间隔天数
       ,STB_AMT_F  --是否开通备用金
FROM  (
SELECT   T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.ISU_DT     --发卡日期
        ,T.CARD_ACTV_DT   --卡片激活日期
        ,CASE WHEN B.SERIALNO IS NULL THEN '0' ELSE '1' END AS STB_AMT_F  --是否开通备用金
        ,CASE WHEN C.MIN_TRX_DATE = '' THEN '未首刷' ELSE C.MIN_TRX_DATE END AS INPUTDATE --首刷时间
        ,CASE WHEN C.MIN_TRX_DATE = '' THEN '0' ELSE '1' END AS INPUT_F --是否完成首刷
FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01  T
LEFT JOIN EDW.LOAN_BUSINESS_CONTRACT B
ON B.ACCOUNTNO = T.CR_CRD_CARD_NBR AND B.DT = '@@{yyyyMMdd}'   -- 模型层的表edw.dim_bus_loan_ctr_inf_dd中无字段ACCOUNTNO，没法使用
LEFT JOIN (
      SELECT CR_CRD_CARD_NBR
      ,CASE WHEN MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL THEN ''
            ELSE LEAST(COALESCE(MIN_CSH_TRSF_DATE,'29991231'),COALESCE(MIN_CSM_DATE,'29991231'),COALESCE(MIN_RCD_DT,'29991231'))
      END MIN_TRX_DATE           --卡最早一笔交易日期
      FROM LAB_BIGDATA_DEV.CUS_TRX_DT_01
) C ON T.CR_CRD_CARD_NBR = C.CR_CRD_CARD_NBR
)P
;

SELECT * FROM (SELECT *,ROW_NUMBER()OVER(PARTITION BY CR_CRD_CARD_NBR ORDER BY INPUTDATE) AS RN FROM LAB_BIGDATA_DEV.CUS_CARD_ACT_DAYS ORDER BY CR_CRD_CARD_NBR) A WHERE A.RN > 1;



DROP TABLE IF EXISTS LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_ACT_DAYS1;
CREATE TABLE   LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_ACT_DAYS1 AS
SELECT   T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.ISU_DT     --发卡日期
        ,T.CARD_ACTV_DT   --卡片激活日期
        ,CASE WHEN CARD_ACTV_DT = '18991231'  THEN  DATEDIFF(TO_DATE('@@{yyyyMMdd}}','YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '已激活' END AS UNACTV_DAYS  --未激活天数
        ,CASE WHEN CARD_ACTV_DT <> '18991231' THEN  DATEDIFF(TO_DATE(CARD_ACTV_DT,'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '未激活' END AS  ISU_ACTV_DAYS  --发卡与激活间隔天数
        ,CASE WHEN B.ACCOUNTNO IS NULL THEN '0' ELSE '1' END AS STB_AMT_F  --是否开通备用金
        ,CASE WHEN (MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL) THEN '18991231'
              ELSE LEAST(COALESCE(C.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(C.MIN_CSM_DATE,'29991231'),COALESCE(C.MIN_RCD_DT,'29991231'))
              END AS INPUTDATE --首刷时间
        ,CASE WHEN (MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL) THEN '0'
              ELSE '1'
              END AS INPUT_F --是否完成首刷
        ,CASE WHEN (MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL) THEN '-9999'
              ELSE DATEDIFF(TO_DATE(LEAST(COALESCE(C.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(C.MIN_CSM_DATE,'29991231'),COALESCE(C.MIN_RCD_DT,'29991231')) ,'yyyyMMdd'),TO_DATE(T.ISU_DT,'yyyyMMdd'),'DD')
              END AS ISU_INP_DAYS  --发卡与首刷间隔天数
FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01  T
LEFT JOIN (
      SELECT ACCOUNTNO
      FROM EDW.LOAN_BUSINESS_CONTRACT  -- 模型层的表edw.dim_bus_loan_ctr_inf_dd中无字段ACCOUNTNO，没法使用
      WHERE DT = '@@{yyyyMMdd}'
      GROUP BY ACCOUNTNO
) B
ON  B.ACCOUNTNO = T.CR_CRD_CARD_NBR
LEFT JOIN LAB_BIGDATA_DEV.CUS_TRX_DT_01 C ON T.CR_CRD_CARD_NBR = C.CR_CRD_CARD_NBR
;
SELECT * FROM LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_ACT_DAYS1;
-----------------------------------------------------------------------
--------------------------首刷时间小于续卡发卡日期情况
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_ACT_DAYS1;
CREATE TABLE   LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_ACT_DAYS1 AS
SELECT   T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.ISU_DT     --发卡日期
        ,T.CARD_ACTV_DT   --卡片激活日期
        ,CASE WHEN CARD_ACTV_DT = '18991231'  THEN  DATEDIFF(TO_DATE('@@{yyyyMMdd}}','YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '已激活' END AS UNACTV_DAYS  --未激活天数
        ,CASE WHEN CARD_ACTV_DT <> '18991231' THEN  DATEDIFF(TO_DATE(CARD_ACTV_DT,'YYYYMMDD'),TO_DATE(ISU_DT,'YYYYMMDD'),'DD')
          ELSE '未激活' END AS  ISU_ACTV_DAYS  --发卡与激活间隔天数
        ,CASE WHEN B.ACCOUNTNO IS NULL THEN '0' ELSE '1' END AS STB_AMT_F  --是否开通备用金
        ,CASE WHEN (MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL) THEN '0'
              WHEN LEAST(COALESCE(C.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(C.MIN_CSM_DATE,'29991231'),COALESCE(C.MIN_RCD_DT,'29991231'))  < T.ISU_DT THEN '0'
              ELSE '1' END AS INPUT_F --是否完成首刷
        ,CASE WHEN (MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL) OR LEAST(COALESCE(C.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(C.MIN_CSM_DATE,'29991231'),COALESCE(C.MIN_RCD_DT,'29991231'))  < T.ISU_DT THEN '18991231'
              ELSE LEAST(COALESCE(C.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(C.MIN_CSM_DATE,'29991231'),COALESCE(C.MIN_RCD_DT,'29991231'))
              END AS INPUTDATE --首刷时间
        ,CASE WHEN (MIN_CSH_TRSF_DATE IS NULL AND MIN_CSM_DATE  IS NULL AND MIN_RCD_DT  IS NULL) OR LEAST(COALESCE(C.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(C.MIN_CSM_DATE,'29991231'),COALESCE(C.MIN_RCD_DT,'29991231'))  < T.ISU_DT THEN '-9999'
              ELSE DATEDIFF(TO_DATE(LEAST(COALESCE(C.MIN_CSH_TRSF_DATE,'29991231'),COALESCE(C.MIN_CSM_DATE,'29991231'),COALESCE(C.MIN_RCD_DT,'29991231')) ,'yyyyMMdd'),TO_DATE(T.ISU_DT,'yyyyMMdd'),'DD')
              END AS ISU_INP_DAYS  --发卡与首刷间隔天数
FROM   LAB_BIGDATA_DEV.CUS_CARD_Z01  T
LEFT JOIN (
      SELECT ACCOUNTNO
      FROM EDW.LOAN_BUSINESS_CONTRACT  -- 模型层的表edw.dim_bus_loan_ctr_inf_dd中无字段ACCOUNTNO，没法使用
      WHERE DT = '@@{yyyyMMdd}'
      GROUP BY ACCOUNTNO
) B
ON  B.ACCOUNTNO = T.CR_CRD_CARD_NBR
LEFT JOIN LAB_BIGDATA_DEV.CUS_TRX_DT_01 C ON T.CR_CRD_CARD_NBR = C.CR_CRD_CARD_NBR
;



------------------- 贷记卡申请相关
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_APPLY;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_APPLY AS
SELECT  CST_ID
        ,MIN(CASE WHEN   CRD_CTG_CD = '1' THEN APL_DT  END  ) MIN_DBT_CRD_APL_DATE   --客户贷记卡最早一笔申请日期
        ,MAX(CASE WHEN   CRD_CTG_CD = '1' THEN APL_DT  END  ) LATE_DBT_CRD_APL_DATE  --客户贷记卡最近一笔申请日期
        ,MIN(APL_DT) MIN_CR_CRD_APL_DATE   --客户信用卡最早一笔申请日期
        ,MAX(APL_DT) LATE_CR_CRD_APL_DATE  --客户信用卡最近一笔申请日期
        ,CASE WHEN CRD_CTG_CD = '1' THEN
FROM   (
         SELECT  T1.CST_ID
                 ,T1.CR_CRD_PD_ID
                 ,T1.APL_DT
                 ,T1.APL_DOC_SRC_CD  --申请件来源代码
                 ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
                 ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_PD_ID ORDER BY )
         FROM EDW.DWD_BUS_CRD_CR_CRD_APL_INF_DD T1
         LEFT JOIN APP_RPT.DIM_CR_CRD_PD T2    --xt
         ON T1.CR_CRD_PD_ID = T2.PD_CD
         WHERE T1.DT  = '@@{yyyyMMdd}'
         AND T1.APL_DT <> '18991231'
        )P
GROUP BY  CST_ID
;

DWD_BUS_LOAN_APL_INF_DD
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CARD_APPLY_CHN_2;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CARD_APPLY_CHN_2 AS
SELECT  P1.CST_ID
        ,P1.APL_DOC_SRC_CD  EAR_CHANNELIN   --贷记卡最早一次申请渠道
        ,P2.APL_DOC_SRC_CD  LAST_CHANNELIN  --贷记卡最近一次申请渠道
FROM  (
         SELECT  T1.CST_ID
                 ,T1.CR_CRD_PD_ID
                 ,T1.APL_DT
                 ,T1.APL_DOC_SRC_CD  --申请件来源代码
                 ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_PD_ID ORDER BY APL_DT) AS ROW_NO_1   --最早一次申请
         FROM EDW.DWD_BUS_CRD_CR_CRD_APL_INF_DD T1
         LEFT JOIN APP_RPT.DIM_CR_CRD_PD T2    --xt
         ON T1.CR_CRD_PD_ID = T2.PD_CD
         WHERE T1.DT  = '@@{yyyyMMdd}'
         AND T1.APL_DT <> '18991231'
         AND T2.CRD_CTG_CD = '1'  --贷记卡
      )P1
LEFT JOIN (
         SELECT  T1.CST_ID
                 ,T1.CR_CRD_PD_ID
                 ,T1.APL_DT
                 ,T1.APL_DOC_SRC_CD  --申请件来源代码
                 ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_PD_ID ORDER BY APL_DT DESC) AS ROW_NO_2   --最早一次申请
         FROM EDW.DWD_BUS_CRD_CR_CRD_APL_INF_DD T1
         LEFT JOIN APP_RPT.DIM_CR_CRD_PD T2    --xt
         ON T1.CR_CRD_PD_ID = T2.PD_CD
         WHERE T1.DT  = '@@{yyyyMMdd}'
         AND T1.APL_DT <> '18991231'
         AND T2.CRD_CTG_CD = '1'  --贷记卡
            )P2
ON P1.CST_ID = P2.CST_ID  AND P2.ROW_NO_2 = 1
WHERE  ROW_NO_1 = 1
;

------------------------- 客户级备用金字段
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CARD_STB_AMT ;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CARD_STB_AMT AS
SELECT  T.CST_ID
        ,T.BUSI_CTR_ID  --业务合同编号
        ,T.BUSI_APL_ID  --业务申请编号
        ,T.HPN_DT       --发生日期
        ,T.APNT_START_DT --约定开始日期
        ,T.APNT_MTU_DT   --约定到期日期
        ,T.END_DT   --终结日期
        --,T.TRM_MON  --期限月
        --,T.PD_CD    --产品代码
        ,T.CTR_AMT  --合同金额
        ,T.CTR_BAL  --合同余额
        ,CASE WHEN T1.BUS_CTR_ID IS NOT NULL THEN T1.EXE_MON_INTR_RAT ELSE T.INTR_RAT END AS INTR_RAT -- 执行利率
        ,CASE WHEN ( T.HPN_DT <= T.DT AND T.APNT_MTU_DT >= T.DT AND T.END_DT = '18991231' ) THEN '1' ELSE '0' END AS END_STATUS --结清状态
        --,CASE WHEN T.PD_CD IN ( '20105010104035301' , '20105010201015001' ) THEN '1' ELSE '0' END AS LOAN_STB_FLAG --是否备用金贷款
FROM    EDW.DIM_BUS_LOAN_CTR_INF_DD T --信贷合同信息表
LEFT JOIN    (
                 SELECT  BUS_CTR_ID
                         ,MIN(EXE_MON_INTR_RAT) AS EXE_MON_INTR_RAT
                 FROM    EDW.DIM_BUS_LOAN_CRC_CTR_INF_DD --循环贷款合同信息
                 WHERE   DT = '@@{yyyyMMdd}'
                 AND     INTR_RAT_MTH = '020'
                 GROUP BY BUS_CTR_ID
             ) T1
ON      T.BUSI_CTR_ID = T1.BUS_CTR_ID
WHERE   T.DT = '@@{yyyyMMdd}'
AND T.PD_CD IN ( '20105010104035301' , '20105010201015001' )
;

DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CARD_STB_CHANL ;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CARD_STB_CHANL AS
SELECT CST_ID
      ,CST_CHNL_CD AS CHANNEL  --备用金申请渠道
FROM (
SELECT CST_ID
      ,CST_CHNL_CD
      ,NUM
      ,ROW_NUMBER()OVER(PARTITION BY CST_ID ORDER BY NUM DESC) AS ROW_NO
FROM (
      SELECT CST_ID
            ,CST_CHNL_CD --获客渠道代码
            ,COUNT(1) AS NUM  --各个渠道次数
      FROM EDW.DWD_BUS_LOAN_APL_INF_DD
      WHERE DT = '@@{yyyyMMdd}'
      GROUP BY CST_ID,CST_CHNL_CD
) P1
) P2
WHERE P2.ROW_NO = 1




-- 备用金额度/利率、最早/最近一笔申请日期、最早/最近一笔借据发生日期
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_INF ;
CREATE  TABLE  LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT_INF AS
SELECT
FROM (
SELECT T1.CST_ID
      ,SUM(CASE WHEN END_STATUS = '1' THEN BUSINESSSUM ELSE 0 END) BUSINESSSUM --授信额度
      ,CASE WHEN SUM(CASE WHEN END_STATUS = '1' THEN BUSINESSSUM ELSE 0 END) = 0 THEN 0
            ELSE SUM(CASE WHEN END_STATUS = '1' THEN BUSINESSSUM * BUSINESSRATE ELSE 0 END)/SUM(CASE WHEN IS_VALID = '1' THEN BUSINESSSUM ELSE 0 END)
       END WT_BUSINESSRATE --备用金授信加权平均利率
      ,MIN(CASE WHEN T2.APL_DT IS NOT NULL THEN T2.APL_DT END) EAR_APL_DT   --备用金最早一笔申请日期
      ,MAX(CASE WHEN T2.APL_DT IS NOT NULL THEN T2.APL_DT END) LST_APL_DT   --备用金最近一笔申请日期
      ,MIN(CASE WHEN T3.DTRB_DT IS NOT NULL THEN T3.DTRB_DT END) EAR_DTRB_DT   --备用金最早一笔借据发生日期
      ,MAX(CASE WHEN T3.DTRB_DT IS NOT NULL THEN T3.DTRB_DT END) LST_DTRB_DT   --备用金最近一笔借据发生日期
FROM LAB_BIGDATA_DEV.LIFE_PRD_CUS_CARD_STB_AMT T1
LEFT JOIN EDW.DWD_BUS_LOAN_APL_INF_DD T2 ON T1.RELATIVESERIALNO  = T2.APL_ID  AND T2.DT  = '@@{yyyyMMdd}'
LEFT JOIN  EDW.DIM_BUS_LOAN_DBIL_INF_DD T3 ON T1.SERIALNO = T3.BUS_CTR_ID AND T3.DT  =  '@@{yyyyMMdd}'
GROUP BY T1.CST_ID
) P1
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_STB_CHANL P2
ON P1.CST_ID = P2.CST_ID
;



---------------------------------
SELECT P1.CST_ID
      ,P1.CST_CHNL_CD AS
      ,P2.CST_CHNL_CD AS
FROM (
      SELECT APL_ID  --申请流水号
            ,CST_ID
            ,APL_DT  --申请日期
            ,CST_CHNL_CD --获客渠道代码
            ,ROW_NUMBER()OVER(PARTITION BY CST_ID ORDER BY APL_DT) AS ROW_NO_1
      FROM EDW.DWD_BUS_LOAN_APL_INF_DD
      WHERE DT = '@@{yyyyMMdd}'
) P1
LEFT JOIN (
      SELECT APL_ID  --申请流水号
            ,CST_ID
            ,APL_DT  --申请日期
            ,CST_CHNL_CD --获客渠道代码
            ,ROW_NUMBER()OVER(PARTITION BY CST_ID ORDER BY APL_DT DESC) AS ROW_NO_2
      FROM EDW.DWD_BUS_LOAN_APL_INF_DD
      WHERE DT = '@@{yyyyMMdd}'
) P2
ON P1.CST_ID = P2.CST_ID AND P2.ROW_NO_2 = 1
WHERE  ROW_NO_1 = 1
;



-- 备用金：额度/利率、最早/最近申请日期、最早/最近借据发生日期
SELECT T1.CST_ID
      ,SUM(CASE WHEN END_STATUS = '1' THEN BUSINESSSUM ELSE 0 END) BUSINESSSUM --授信额度
      ,CASE WHEN SUM(CASE WHEN END_STATUS = '1' THEN BUSINESSSUM ELSE 0 END) = 0 THEN 0
            ELSE SUM(CASE WHEN END_STATUS = '1' THEN BUSINESSSUM * BUSINESSRATE ELSE 0 END)/SUM(CASE WHEN IS_VALID = '1' THEN BUSINESSSUM ELSE 0 END)
       END WT_BUSINESSRATE --备用金授信加权平均利率
      ,
FROM LAB_BIGDATA_DEV.CUS_CARD_STB_AMT T1
LEFT JOIN (
      SELECT APL_ID
            ,CST_ID
            ,APL_DT  --申请日期
            ,CST_CHNL_CD --获客渠道代码
            ,ROW_NUMBER()OVER(PARTITION BY CST_ID ORDER BY APL_DT) AS ROW_NO_1
      FROM EDW.DWD_BUS_LOAN_APL_INF_DD
      WHERE DT = '@@{yyyyMMdd}'

)




---





-- ************************************************************  通用指标问题汇总  *************************************
---------------------------------------------------- 20211207上午--------------
1、区域（信贷新客户地址）
--①优先取信用卡账单地址；
--②当取不到信用卡账单地址时，edw.dim_cst_bas_phy_adr_inf_dd 客户物理地址信息，有&ldquo;县级编号代码&rdquo;cnr_lvl_id_cd，可以作为该地址的行政区划代码，从而找到区域：
--个人客户取&ldquo;050200-家庭地址&rdquo;对应的&ldquo;县级编号代码&rdquo;cnr_lvl_id_cd，当家庭地址对应的县级编号代码为空时，取&ldquo;050100-户籍地址&rdquo;对应的县级编号代码，当户籍地址对应的县级编号代码为空时，取主管户分行所在地。
--企业客户取&ldquo;050800-注册地址&rdquo;对应的&ldquo;县级编号代码&rdquo;cnr_lvl_id_cd，当注册地址对应的县级编号代码为空时，取&ldquo;050900-经营所在地地址&rdquo;对应的县级编号代码，当经营所在地地址对应的县级编号代码为空时，取主管户分行所在地。

--客户物理地址信息
DROP TABLE if exists lab_bigdata_dev.cst_address_01;
create table lab_bigdata_dev.cst_address_01 as
select a.CST_ID
      ,a.PHY_ADR_TYP_CD  --物理地址类型代码
      ,a.cnr_lvl_id_cd   --县级编号代码
  from (select T.CST_ID
              ,T.PHY_ADR_TYP_CD  --物理地址类型代码
              ,T.cnr_lvl_id_cd   --县级编号代码
              ,ROW_NUMBER() OVER ( PARTITION BY T.CST_ID , T.PHY_ADR_TYP_CD ORDER BY T.cnr_lvl_id_cd DESC ) AS ROW_NO
          from edw.dim_cst_bas_phy_adr_inf_dd t
         where dt='@@{yyyymMMdd}'
       ) a
 where a.row_no=1
;

DROP TABLE if exists lab_bigdata_dev.cst_address_02;
create table lab_bigdata_dev.cst_address_02 as
select a.CST_ID
      ,a.cst_typ_cd  --客户类型
      ,a.address_id
      ,concat(b.cd_val_dscr,c.cd_val_dscr,d.cd_val_dscr) as address  --所在区域
  from (select t.CST_ID
              ,t1.cst_typ_cd  --客户类型
              ,t1.prm_org_id  --主管户机构号
              ,t1.prm_org_nm	--主管户机构名称
              ,t6.cnr_cd      --机构所在县区
              ,case when t1.cst_typ_cd='1' then coalesce(t2.cnr_lvl_id_cd,t3.cnr_lvl_id_cd,t6.cnr_cd)
                    when t1.cst_typ_cd='2' then coalesce(t4.cnr_lvl_id_cd,t5.cnr_lvl_id_cd,t6.cnr_cd)
                end as address_id
          from lab_bigdata_dev.cst_list t --！替换成自己的客户表
         inner join edw.dws_cst_bas_inf_dd t1 on t.cst_id=t1.cst_id and t1.dt='@@{yyyymMMdd}'
          left join lab_bigdata_dev.cst_address_01 t2 on t.cst_id=t2.cst_id and t2.PHY_ADR_TYP_CD='050200'  --家庭地址
          left join lab_bigdata_dev.cst_address_01 t3 on t.cst_id=t3.cst_id and t3.PHY_ADR_TYP_CD='050100'  --户籍地址
          left join lab_bigdata_dev.cst_address_01 t4 on t.cst_id=t4.cst_id and t4.PHY_ADR_TYP_CD='050800'  --注册地址
          left join lab_bigdata_dev.cst_address_01 t5 on t.cst_id=t5.cst_id and t5.PHY_ADR_TYP_CD='050900'  --经营所在地地址
          left join edw.dim_hr_org_bas_inf_dd t6 on t1.prm_org_id=t6.org_id and t6.dt='@@{yyyymMMdd}'
       ) a
  left join edw.dwd_code_library b on concat(substr(a.address_id,1,2),'0000')=b.cd_val and b.cd_id = 'CD20160181'
  left join edw.dwd_code_library c on concat(substr(a.address_id,1,4),'00')=c.cd_val and c.cd_id = 'CD20160181'
  left join edw.dwd_code_library d on a.address_id=d.cd_val and d.cd_id = 'CD20160181'
;

2、客户交接次数是否计算历史的次数
--是
   存款交接次数的定义
--舍弃（具体见下面的第一个问题）

3、客户地址信息中物理地址类型代码码值
select *
  from edw.dwd_code_library
 where tbl_nm='DIM_CST_BAS_PHY_ADR_INF_DD'
   and fld_nm='PHY_ADR_TYP_CD'
;

4、循环贷款利率的计算方式
select t.cst_id
      ,t.busi_ctr_id
      ,t.busi_apl_id
      ,t.hpn_dt
      ,t.apnt_start_dt
      ,t.apnt_mtu_dt
      ,t.pd_cd
      ,t.ctr_amt
      ,t.ctr_bal
      --,t.intr_rat
      ,CASE WHEN T1.bus_ctr_id IS NOT NULL THEN T1.exe_mon_intr_rat ELSE T.INTR_RAT END AS INTR_RAT -- 执行利率
      ,t.loan_usg_cd
      ,t.dt
  from edw.dim_bus_loan_ctr_inf_dd t   --信贷合同信息表
  left join (SELECT bus_ctr_id
                   ,MIN(exe_mon_intr_rat) as exe_mon_intr_rat
               FROM edw.dim_bus_loan_crc_ctr_inf_dd  --循环贷款合同信息
              WHERE DT='@@{yyyyMMdd}'
                AND intr_rat_mth='020'
              GROUP BY bus_ctr_id
            ) T1 ON T.BUSI_CTR_ID=T1.bus_ctr_id AND t1.exe_mon_intr_rat<>0
 where t.dt='@@{yyyyMMdd}'
 ;

5、他行贷记卡的标识
--取1年内最近一笔征信报告
SELECT *
from
(select  s.cst_id
        ,rpt.report_id
        ,rpt.report_dt
        ,ROW_NUMBER() OVER ( PARTITION BY s.cst_id ORDER BY rpt.report_dt DESC ) AS row_no
FROM
    lab_bigdata_dev.tmp_jinhua_20211110_02 s   ----！替换成自己的表名
LEFT JOIN edw.dws_cst_ccrc_idv_ind_inf_di rpt
       on s.cst_id = rpt.cst_id
      and rpt.report_dt<'@@{yyyyMMdd}'
      and rpt.dt<='@@{yyyyMMdd}'
      and datediff(to_date('@@{yyyyMMdd}','yyyymmdd'),to_date(rpt.report_dt,'yyyymmdd'),'dd') between 0 and 365
) a
WHERE  a.row_no = 1
;
--&ldquo;他行贷记卡当前持有标识&rdquo;更改为&ldquo;他行信用卡当前持有标识&rdquo;，用&ldquo;现有信用卡授信银行数&rdquo;curr_cred_bank_num来加工。



----------------------------------------------------------20211207下午------------------
1、信贷客户交接次数 针对objecttype中以下几种
Loan                 贷款交接
CreditCardCustomer   信用卡客户交接
CreditCard           信用卡交接
SDTCard              随贷通卡交接
是否不包括 Customer 客户交接?
--客户交接次数更改为信贷客户交接次数，是包括历史的次数。目前CRM正在梳理客户交接的逻辑，还未执行，所以现在只考虑信贷客户交接。
--客户交接次数-->信贷客户交接次数，取objecttype='Customer'
--信贷交接次数-->舍弃
--存款交接次数-->舍弃

2、信用卡当前持有标识
信用卡卡片信息表
码表中card_sts_cd卡片状态代码为&lsquo;-&rsquo; 是正常
但是该表中查询没有&lsquo;-&rsquo;的状态
--咨询了业务，按照信用卡存续的口径
--信用卡存续口径：
--是：卡状态不为Q销户申请/2过期未续且账户状态不为V核销、卡片到期年月的最后一天＞统计日的信用卡；
--否：不符合上述条件的信用卡
select cst_id
      ,max(CUNXU_FLAG)  as CUNXU_FLAG    --是否有存续卡
  from (SELECT a.cst_id                  --客户号
              ,a.cr_crd_act_id           --信用卡账户
              ,a.late_main_card_card_nbr --信用卡卡号（主卡）
              ,CASE WHEN A.LATE_MAIN_CARD_STS_CD NOT IN ( 'Q' , '2' ) AND A.ACT_STS_CD <> 'V' AND A.CRD_LMT > 0
                         AND TO_CHAR(DATEADD(DATEADD(TO_DATE(concat('20', G.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') > '20211130' THEN '1'
                    ELSE '0'
                END CUNXU_FLAG   --是否存续卡
          FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD A
          LEFT JOIN EDW.DIM_BUS_CRD_CR_CRD_INF_DD G
                 ON G.CR_CRD_CARD_NBR = A.LATE_MAIN_CARD_CARD_NBR
                AND G.DT = '@@{yyyyMMdd}'
         WHERE A.DT = '@@{yyyyMMdd}'
       ) t
 group by cst_id
;

3、信用卡申请标识
拒绝的定义
信用卡申请信息中有个字段isu_rsl_cd，发卡结果代码 未找到对应的码值
--（！待确认）

4、贷记卡
adm_ind.dim_cr_crd_pd_omrs 信用卡产品信息，pd_cd 产品代码
crd_ctg_cd 大卡种分类:1-贷记卡,2-准贷记卡,3-随贷通
信用卡产品信息表改为edw.dim_bus_crd_cr_crd_pd_inf_dd 之后，没有对应的产品代码和大卡种分类
--app_rpt.dim_cr_crd_pd
--DIM_CR_CRD_PD.CRD_CTG_CD='1'--贷记卡
--DIM_CR_CRD_PD.CRD_CTG_CD='2'--准贷记卡
--DIM_CR_CRD_PD.CRD_CTG_CD='3'--随贷通
--目前先采用自建同名表的方式解决。

5、他行房贷历史持有标识
征信中没有历史相关的字段
--house_loan_num	历史房贷笔数




-----------------------------------------------------20211208------------------------------
1、信用卡申请标识
  拒绝的定义
--（！待确认）

2、贷记卡
--app_rpt.dim_cr_crd_pd
--DIM_CR_CRD_PD.CRD_CTG_CD='1'--贷记卡
--DIM_CR_CRD_PD.CRD_CTG_CD='2'--准贷记卡
--DIM_CR_CRD_PD.CRD_CTG_CD='3'--随贷通
app_rpt.dim_cr_crd_pd该表也不能访问
--目前先采用自建同名表的方式解决。

3、当前贷款持有标识
按当前贷款余额>0标记？
-- dt>=hpt_dt and dt<=a.apnt_mtu_dt and end_dt='18991231'

历史贷款持有标识
按有过贷款合同的记录？
--是的

我行贷款最近一笔结清日期
取信贷合同信息 里面的终结日期 并且贷款余额= 0？
--是的


4、我行贷款授信加权平均利率
很多数据中的授信额度为0
--应该不会，这个字段比较常用，可以记录下来哪些合同
我行贷款用信加权平均利率
用信指的是贷款余额吗？
--是的

5、他行贷款当前持有标识（除房贷）
他行贷款余额 （除房贷）
他行贷款余额能否用  贷款总余额-当前未结清住房贷款余额 计算
标识用他行贷款余额>0判断 ？
--暂时用这个字段来判断，有变动我再告知。

6、他行的字段都要取近一年的征信报告里的数据吗？
--是的


------------------------------------------------------ 20211217  信用卡持有标识----------------------
信用卡申请标识：从未申请过、申请未完结、申请被拒绝、申请通过
--判断优先级：只要有过信用卡就算申请通过--有一笔拒绝就算申请被拒绝--有过申请但不在前两种就算申请未完结--剩余为从未申请过。
第一步：只要有过信用卡就算申请通过（不仅仅是当前持有，历史持有也算申请通过）
第二步：剩下的客户中，只要有一笔拒绝就算申请被拒绝
elect cr_crd_apl_srl_nbr --信用卡申请流水号
,cst_id --客户号
,isu_rsl_cd --发卡结果代码
,case
when isu_rsl_cd = '00' then '0' --申请通过
when isu_rsl_cd = 'XX' then '2' --申请未完结
else '1' --申请被拒绝
end as isu_rsl
from edw.dwd_bus_crd_cr_crd_apl_inf_dd
where dt = '20211216'
;
第三步：排除掉前两种的客户，只要出现在申请表里的就算是申请未完结。
第四步：从没出现在申请表里的，就是从未申请过。
**客群研究_贷记卡核对_卡级.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-27 09:41:05
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 楼佳倩大数据部外包
-- 创建日期: 2021-12-15 09:44:25
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
DROP TABLE IF EXISTS  lab_bigdata_dev.xt_024618_tmp_CUS_CARD_C;
CREATE  TABLE IF NOT EXISTS lab_bigdata_dev.xt_024618_tmp_CUS_CARD_C AS
select  A1.cst_id        --客户号
    ,A1.cr_crd_act_id    --信用卡账号
    ,A1.cr_crd_card_nbr    --信用卡卡号
    ,A1.cr_crd_pd_id      --信用卡产品编号
    ,A2.crd_ctg_cd         --大卡种
    ,A2.crd_lvl         --卡片等级
    ,A2.crd_lvl_nm      --卡片等级名称
    ,A3.crd_lvl_HIS     --客户信用卡历史最高等级
    ,A4.crd_lvl_NOW     --客户信用卡当前最高等级
    ,NVL(A5.WX_CARD_NOW_F,0) WX_CARD_NOW_F   --当前是否绑定信用卡微信公众号
    ,NVL(A5.WX_CARD_HIS_F,0)  WX_CARD_HIS_F    --是否历史绑定信用卡微信公众号
    ,CASE WHEN bind_cst_act_id IS NOT NULL THEN '1' ELSE 0 END AS WX_BANK_NOW_F  --是否绑定泰隆银行微信
    ,NVL(T1.XIAGUA_SJ,0) XIAGUA_SJ  --是否下挂手机银行
    ,A1.card_actv_dt  --激活日期
    ,A1.isu_dt   --发卡日期
    ,A1.card_sts_cd  --卡片状态
    ,CASE WHEN A1.card_actv_dt = '18991231' THEN '0' ELSE '1' END AS  JIHUO_F  --是否激活
--未激活天数  统计日期-发卡日期（续卡日期）
    ,CASE WHEN A1.isu_rsn_cd = 'X' THEN 	isu_dt END AS xu_ISU_DT --续卡开卡日期
    ,CASE WHEN  A1.isu_rsn_cd = 'X' AND  A1.card_sts_cd  = 'A'   THEN
    DATEDIFF(TO_DATE('20211205','YYYYMMDD'),TO_DATE(CONCAT(SUBSTR(A1.rsnd_dt,1,4),SUBSTR(A1.rsnd_dt,6,2),SUBSTR(A1.rsnd_dt,9,2)),'YYYYMMDD'),'DD')
    WHEN  A1.card_sts_cd  = 'A'   THEN  DATEDIFF(TO_DATE('20211205','YYYYMMDD'),TO_DATE(A1.isu_dt,'YYYYMMDD'),'DD')
    ELSE '' END  AS WEIJIHUO_DAYS   --未激活天数
   ,CASE WHEN H2.SUM_JIHUO_F = 0 AND A1.card_sts_cd = 'A' THEN '新卡待激活'
    WHEN A1.isu_rsn_cd = 'X' AND  A1.card_sts_cd = 'A' THEN  '续卡待激活'
    WHEN A1.chg_card_tms <> 0 AND A1.card_sts_cd = 'A' AND H4.ini_act_dt <> '' THEN '换卡待激活'
    WHEN A1.card_sts_cd = 'A' AND  A1.card_actv_dt = '18991231'  AND  H4.ini_act_dt = '' AND  H3.NUM >=1 THEN  '二卡待激活'
    ELSE '' END AS JIHUO_TYPE   --待激活类型
    ,CASE WHEN  A1.card_sts_cd  = 'A' OR A1.card_actv_dt = '18991231'  THEN ''
        ELSE  DATEDIFF(TO_DATE(A1.card_actv_dt,'YYYYMMDD'),TO_DATE(A1.isu_dt,'YYYYMMDD'),'DD')  END AS DAYS_DIFF--发卡与激活间隔天数
    ,NVL(T2.inb_creditcard_repast_consume_amt,0) inb_creditcard_repast_consume_amt_90       --近90天餐饮交易金额
    ,NVL(T2.inb_creditcard_repast_consume_cnt,0) inb_creditcard_repast_consume_cnt_90       --近90天餐饮交易笔数
    ,NVL(T2.inb_creditcard_plane_consume_amt,0)  inb_creditcard_plane_consume_amt_90        --近90天航旅交易金额
    ,NVL(T2.inb_creditcard_plane_consume_cnt,0)  inb_creditcard_plane_consume_cnt_90       --近90天航旅交易笔数
    ,NVL(T2.inb_creditcard_abroad_consume_amt,0)  inb_creditcard_abroad_consume_amt_90      --近90天境外交易金额
    ,NVL(T2.inb_creditcard_abroad_consume_cnt,0)  inb_creditcard_abroad_consume_cnt_90      --近90天境外交易笔数
    ,NVL(T3.ZFB_AMT,0) ZFB_AMT_90                     --近90天支付宝交易金额
    ,NVL(T3.ZFB_NBR,0) ZFB_NBR_90                    --近90天支付宝交易笔数
    ,NVL(T4.CFT_AMT,0) CFT_AMT_90    --近90天财付通交易金额
    ,NVL(T4.CFT_NBR,0) CFT_NBR_90    --近90天财付通交易笔数
    ,NVL(T5.inb_creditcard_repast_consume_amt,0) inb_creditcard_repast_consume_amt_30       --近30天餐饮交易金额
    ,NVL(T5.inb_creditcard_repast_consume_cnt,0) inb_creditcard_repast_consume_cnt_30       --近30天餐饮交易笔数
    ,NVL(T5.inb_creditcard_plane_consume_amt,0)  inb_creditcard_plane_consume_amt_30        --近30天航旅交易金额
    ,NVL(T5.inb_creditcard_plane_consume_cnt,0)  inb_creditcard_plane_consume_cnt_30       --近30天航旅交易笔数
    ,NVL(T5.inb_creditcard_abroad_consume_amt,0)  inb_creditcard_abroad_consume_amt_30      --近30天境外交易金额
    ,NVL(T5.inb_creditcard_abroad_consume_cnt,0)  inb_creditcard_abroad_consume_cnt_30      --近30天境外交易笔数
    ,NVL(T6.ZFB_AMT,0) ZFB_AMT_30                     --近30天支付宝交易金额
    ,NVL(T6.ZFB_NBR,0) ZFB_NBR_30                    --近30天支付宝交易笔数
    ,NVL(T7.CFT_AMT,0) CFT_AMT_30    --近30天财付通交易金额
    ,NVL(T7.CFT_NBR,0) CFT_NBR_30    --近30天财付通交易笔数
FROM  edw.DIM_BUS_CRD_CR_CRD_INF_DD A1                      --表：信用卡卡片信息
left join app_rpt.dim_cr_crd_pd A2
--LEFT JOIN wb_bigdata_manager_dev.dim_cr_crd_pd_ljq A2       --表：信用卡产品信息
ON A1.cr_crd_pd_id = A2.PD_CD

/*
select crd_lvl,crd_lvl_nm   --查询卡片等级代码
from app_rpt.dim_cr_crd_pd
group by crd_lvl,crd_lvl_nm
*/
--客户信用卡历史最高等级（所有卡）
LEFT JOIN  (
SELECT   A1.cst_id
        ,MAX(A2.crd_lvl)  crd_lvl_HIS --等级最高？历史 当前卡的等级最高    --4：钻石卡
FROM  edw.DIM_BUS_CRD_CR_CRD_INF_DD A1
left join app_rpt.dim_cr_crd_pd A2
--LEFT JOIN wb_bigdata_manager_dev.dim_cr_crd_pd_ljq A2
ON A1.cr_crd_pd_id = A2.PD_CD
WHERE A1.DT = '20211205'
--AND A2.DT = '20211205'
GROUP BY  CST_ID)A3
ON A1.CST_ID = A3.CST_ID
--客户信用卡当前最高等级(存续卡)
/*
select cr_crd_card_nbr
      ,mtu_day  --到期日
      ,DATEADD(TO_DATE(concat('20',N1.MTU_DAY),'YYYYMM'),1,'MM') as mtu_day_1
      ,DATEADD(DATEADD(TO_DATE(concat('20',N1.MTU_DAY),'YYYYMM'),1,'MM'),-1,'DD') as mtu_day_2
      ,TO_CHAR(DATEADD(DATEADD(TO_DATE(concat('20',N1.MTU_DAY),'YYYYMM'),1,'MM'),-1,'DD'),'YYYYMMDD') as mtu_day_3
      ,TO_CHAR(DATEADD(DATEADD(TO_DATE(concat('20',N1.MTU_DAY),'YYYYMM'),1,'MM'),-1,'DD'),'YYYYMMDD')> '20211205' as is_true
from edw.DIM_BUS_CRD_CR_CRD_INF_DD N1
where dt = '20211205'
*/
LEFT JOIN (
    SELECT  N1.CST_ID
        ,MAX(N2.crd_lvl)  crd_lvl_NOW
    FROM edw.DIM_BUS_CRD_CR_CRD_INF_DD N1
    --LEFT JOIN  wb_bigdata_manager_dev.dim_cr_crd_pd_ljq N2
    left join app_rpt.dim_cr_crd_pd N2
    ON N1.cr_crd_pd_id = N2.PD_CD
    LEFT JOIN edw.dws_bus_crd_cr_crd_act_inf_dd N3
    ON N1.CR_CRD_CARD_NBR = N3.LATE_MAIN_CARD_CARD_NBR
    WHERE N1.DT  ='20211205'
    --AND N2.DT ='20211205'
    AND N3.DT ='20211205'
    AND N3.LATE_MAIN_CARD_STS_CD NOT IN ( 'Q' , '2' )
    AND N3.ACT_STS_CD <> 'V'
    AND N3.CRD_LMT > 0
    AND TO_CHAR(DATEADD(DATEADD(TO_DATE(concat('20',N1.MTU_DAY),'YYYYMM'),1,'MM'),-1,'DD'),'YYYYMMDD')> '20211205'
    GROUP BY  N1.CST_ID)A4
ON A1.CST_ID = A4.CST_ID
--当前是否绑定信用卡微信公众号、是否历史绑定信用卡微信公众号
LEFT JOIN (
    SELECT cr_crd_card_nbr
        ,bind_sts WX_CARD_NOW_F --当前绑定状态
        ,CASE WHEN late_bind_dt  <>'18991231'  THEN  '1'  ELSE  '0' END AS WX_CARD_HIS_F --最近绑定日期
    FROM  edw.dwd_bus_crd_wx_ofc_act_bind_sts_inf_dd
    WHERE  dt = '20211205')A5
ON A1.cr_crd_card_nbr = A5.cr_crd_card_nbr
--是否绑定泰隆银行微信
LEFT JOIN (
    SELECT   DISTINCT   CST_ID,bind_cst_act_id    --############加工的是客户级，而非卡级
    FROM  edw.dwd_bus_chnl_elec_wechat_bind_inf_dd
    WHERE  dt = '20211205'
)A6
ON A1.cst_id = A6.CST_ID
AND A1.cr_crd_card_nbr = A6.bind_cst_act_id
--是否手机银行下挂
/*
select act_id
      ,chnl
from edw.dim_bus_chnl_elec_nb_idv_cst_act_inf_dd
where dt = '20211205'
order by act_id
;

select cr_crd_card_nbr,cst_id from edw.DIM_BUS_CRD_CR_CRD_INF_DD where dt = '20211205' and cr_crd_card_nbr = '3101010109800001543';

select cr_crd_card_nbr,cst_id from edw.DIM_BUS_CRD_CR_CRD_INF_DD where dt = '20211205' order by rand() limit 10;

select * from pb_accinf pa where dt = '20211205' and pa.aif_channel = '1' and pa.aif_accno = '';
*/
LEFT JOIN (
    SELECT   act_id
    ,MAX(CASE WHEN chnl = '1' THEN '1' ELSE '0' END ) AS XIAGUA_SJ
    FROM  edw.dim_bus_chnl_elec_nb_idv_cst_act_inf_dd
    WHERE DT = '20211205'
    GROUP BY  act_id )T1
ON A1.cr_crd_card_nbr = T1.act_id
--待激活类型
LEFT JOIN (
    SELECT CST_ID
        ,CASE WHEN SUM_JIHUO_F =  0 THEN 0 ELSE 1 END AS SUM_JIHUO_F  --全部未激活为0 有激活为1
    FROM (
        select  cst_id
            ,SUM(CASE WHEN ini_act_dt ='' THEN 0  ELSE 1 END ) SUM_JIHUO_F
        FROM  edw.dws_bus_crd_cr_crd_act_inf_dd
        WHERE DT = '20211205'
        GROUP  BY  CST_ID)P  )H2
ON A1.CST_ID = H2.CST_ID
LEFT JOIN  (
    SELECT   	cst_id  --激活记录数>=1的主卡卡号
      ,COUNT(1) num
    FROM edw.dim_bus_crd_cr_crd_inf_dd
    WHERE dt = '20211205'
    AND  main_crd_ind = '1'   --筛选主卡
    AND card_actv_dt <> '18991231'   --激活日期为'18991231'表示未激活
    GROUP BY  cst_id)H3
ON A1.CST_ID = H3.CST_ID
LEFT JOIN  (
    SELECT  cr_crd_act_id,ini_act_dt     --信用卡账户的初始激活日期
    FROM  edw.dws_bus_crd_cr_crd_act_inf_dd
    WHERE DT = '20211205')H4
ON A1.cr_crd_act_id = H4.cr_crd_act_id

--近90天消费金额、笔数
LEFT JOIN (
select cr_crd_card_nbr
      ,sum(CASE WHEN substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('5812','5813','5814')
           AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_repast_consume_amt   --餐饮交易金额
      ,sum(CASE WHEN substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('5812','5813','5814')
           AND wdw_rvs_ind = 0  THEN 1 ELSE 0 END ) AS inb_creditcard_repast_consume_cnt       --餐饮交易笔数
      ,sum(CASE WHEN (substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
           OR substr(mch_typ,1,2) IN ('30','31','32','35','37'))
           AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_plane_consume_amt   --航旅交易金额
      ,sum(CASE WHEN (substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
           OR substr(mch_typ,1,2) IN ('30','31','32','35','37'))
           AND wdw_rvs_ind = 0 THEN 1 ELSE 0 END ) AS inb_creditcard_plane_consume_cnt         --航旅交易笔数
      ,sum(CASE WHEN trx_typ_cd='1184'
           AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_abroad_consume_amt  --境外交易金额
      ,sum(CASE WHEN trx_typ_cd='1184'
           AND wdw_rvs_ind = 0 THEN 1 ELSE 0 END ) AS inb_creditcard_abroad_consume_cnt        --境外交易笔数
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt <= '20211205'  --换成自己的日期
and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 90
group by  cr_crd_card_nbr)T2
ON A1.cr_crd_card_nbr = T2.cr_crd_card_nbr

---近90天支付宝交易金额、笔数
LEFT JOIN (
select a.cr_crd_card_nbr
      ,SUM((a.trx_amt + coalesce(b.back_amt,0)))as ZFB_AMT  --支付宝交易金额
      ,COUNT(a.srl_nbr) ZFB_NBR    --支付宝交易笔数
from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt <= '20211205'  --换成自己的日期
and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 90
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and trx_dscr_1 like '支付宝%'
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,trx_amt as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt <= '20211205'  --换成自己的日期
      and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 90
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and trx_dscr_1 like '支付宝%'
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd')
GROUP BY  a.cr_crd_card_nbr)T3
ON A1.cr_crd_card_nbr = T3.cr_crd_card_nbr

---近90天财付通交易金额、笔数
LEFT JOIN (
select a.cr_crd_card_nbr
      ,SUM((a.trx_amt + coalesce(b.back_amt,0)))as CFT_AMT  --财付通交易金额
      ,COUNT(a.srl_nbr) CFT_NBR    --财付通交易笔数
from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt <= '20211205'  --换成自己的日期
and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 90
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and trx_dscr_1 like '财付通%'
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,trx_amt as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt <= '20211205'  --换成自己的日期
      and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 90
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and trx_dscr_1 like '财付通%'
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd')
GROUP BY  a.cr_crd_card_nbr)T4
ON A1.cr_crd_card_nbr = T4.cr_crd_card_nbr


--近30天消费金额、笔数
LEFT JOIN (
select cr_crd_card_nbr
      ,sum(CASE WHEN substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('5812','5813','5814')
           AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_repast_consume_amt   --餐饮交易金额
      ,sum(CASE WHEN substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('5812','5813','5814')
           AND wdw_rvs_ind = 0  THEN 1 ELSE 0 END ) AS inb_creditcard_repast_consume_cnt       --餐饮交易笔数
      ,sum(CASE WHEN (substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
           OR substr(mch_typ,1,2) IN ('30','31','32','35','37'))
           AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_plane_consume_amt   --航旅交易金额
      ,sum(CASE WHEN (substr(trx_typ_cd,1,1)='1'
           AND mch_typ IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
           OR substr(mch_typ,1,2) IN ('30','31','32','35','37'))
           AND wdw_rvs_ind = 0 THEN 1 ELSE 0 END ) AS inb_creditcard_plane_consume_cnt         --航旅交易笔数
      ,sum(CASE WHEN trx_typ_cd='1184'
           AND wdw_rvs_ind = 0 THEN trx_amt ELSE 0 END ) AS inb_creditcard_abroad_consume_amt  --境外交易金额
      ,sum(CASE WHEN trx_typ_cd='1184'
           AND wdw_rvs_ind = 0 THEN 1 ELSE 0 END ) AS inb_creditcard_abroad_consume_cnt        --境外交易笔数
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt <= '20211205'  --换成自己的日期
and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 30
group by  cr_crd_card_nbr)T5
ON A1.cr_crd_card_nbr = T5.cr_crd_card_nbr


---近30天支付宝交易金额、笔数
LEFT JOIN (
select a.cr_crd_card_nbr
      ,SUM((a.trx_amt + coalesce(b.back_amt,0)))as ZFB_AMT  --支付宝交易金额
      ,COUNT(a.srl_nbr) ZFB_NBR    --支付宝交易笔数
from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt <= '20211205'  --换成自己的日期
and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 30
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and trx_dscr_1 like '支付宝%'
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,trx_amt as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt <= '20211205'  --换成自己的日期
      and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 30
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and trx_dscr_1 like '支付宝%'
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd')
GROUP BY  a.cr_crd_card_nbr)T6
ON A1.cr_crd_card_nbr = T6.cr_crd_card_nbr

---近30天财付通交易金额、笔数
LEFT JOIN (
select a.cr_crd_card_nbr
      ,SUM((a.trx_amt + coalesce(b.back_amt,0)))as CFT_AMT  --财付通交易金额
      ,COUNT(a.srl_nbr) CFT_NBR    --财付通交易笔数
from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt <= '20211205'  --换成自己的日期
and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 30
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and trx_dscr_1 like '财付通%'
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,trx_amt as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt <= '20211205'  --换成自己的日期
      and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 30
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and trx_dscr_1 like '财付通%'
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd')
GROUP BY  a.cr_crd_card_nbr)T7
ON A1.cr_crd_card_nbr = T7.cr_crd_card_nbr

WHERE A1.DT = '20211205'
--AND A2.DT = '20211205'
AND A2.crd_ctg_cd = '1'


------------------
;


------------------------------------------------------------------------  20211228 卡级标签核验------------------------
select card_sts_cd,card_actv_dt,jihuo_type from lab_bigdata_dev.xt_024618_tmp_CUS_CARD_C where cst_id <> ''and jihuo_f = '0' group by card_sts_cd,card_actv_dt,jihuo_type;

select cst_id,cr_crd_act_id,cr_crd_card_nbr,card_sts_cd,card_actv_dt,jihuo_type,weijihuo_days from lab_bigdata_dev.xt_024618_tmp_CUS_CARD_C where cst_id <> ''and jihuo_f = '0';

--查看【未激活天数】的两个条件是否是包含关系
select cst_id,cr_crd_act_id,cr_crd_card_nbr,card_sts_cd,card_actv_dt from lab_bigdata_dev.xt_024618_tmp_CUS_CARD_C where card_sts_cd = 'A' and card_actv_dt <> '18991231';

--查看两张表里的续卡开卡日期是否一致：不一致
select a.cr_crd_card_nbr
      ,a.isu_dt
      ,a.isu_rsn_cd
      ,b.reissuedate
      ,b.issuedate
      ,b.issuereas
from edw.DIM_BUS_CRD_CR_CRD_INF_DD a
left join edw.loan_creditcard_info b on b.cardno = a.cr_crd_card_nbr and b.dt = a.dt
where a.dt = '20211224'
and a.isu_rsn_cd = 'X'
;

-- 近30天、90天支付宝、财付通 有交易的笔数、金额
select a.cr_crd_card_nbr
      ,case when trx_dscr_1 like '支付宝' then (a.trx_amt + coalesce(b.back_amt,0)) else 0 end as zfb_real_amt
      ,case when trx_dscr_1 like '财付通' then (a.trx_amt + coalesce(b.back_amt,0)) else 0 end as cft_real_amt
      ,sum(srl_nbr_zfbtype) as zfb_nbr
      ,sum(srl_nbr_cfttype) as cft_nbr --财付通交易笔数
from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
      ,trx_dscr_1
      ,case when trx_dscr_1 like '支付宝' then 1 else 0 end as srl_nbr_zfbtype
      ,case when trx_dscr_1 like '财付通' then 1 else 0 end as srl_nbr_cfttype
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt >= '20211210' and dt <= '20211220'  --换成自己的日期
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and (trx_dscr_1 like '支付宝%' or trx_dscr_1 like '%财付通%')
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,trx_amt as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt >= '20211210' and dt <= '20211220'  --换成自己的日期
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and (trx_dscr_1 like '支付宝%' or trx_dscr_1 like '%财付通%')
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd')
;




--------------------------------
-- 近30天/近90天：支付宝交易金额、支付宝交易笔数
select cr_crd_card_nbr

from
(
select cr_crd_card_nbr
      ,srl_nbr
      ,(trx_amt+back_amt) as real_amt
      ,case
          when trx_dscr_1 like '支付宝%' and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 30 then '1'
          when trx_dscr_1 like '支付宝%' and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 90 then '2'
          when trx_dscr_1 like '财付通%' and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 30 then '3'
          when trx_dscr_1 like '财付通%' and datediff(to_date('20211205','yyyymmdd'),to_date(dt,'yyyymmdd'),'dd') BETWEEN 0 AND 90 then '4'
          else '0' end as biaozhi
from(
select cr_crd_card_nbr
      ,srl_nbr
      ,trx_amt
      ,trx_dt
      ,acq_mch_enc
      ,trx_dscr_1
from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
where dt <= '20211205'  --换成自己的日期
and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
and trx_typ_cd  >= 1000 and trx_typ_cd <= 1999
and trx_typ_cd <> 1050     --筛选交易类型为消费
and (trx_dscr_1 like '支付宝%' or trx_dscr_1 like '%财付通%')
and rtn_gds_trx_id <> '全额退货') a
left join (
      select cr_crd_card_nbr
            ,srl_nbr
            ,trx_amt as back_amt  --退货金额
            ,trx_dt
            ,dateadd(to_date('19570101','yyyyMMdd'),substr(acq_mch_enc,1,5),'dd') as old_trx_dt  --原交易日期
            ,substr(acq_mch_enc,6,6) as old_acq_mch_enc
      from edw.dwd_bus_crd_cr_crd_trx_dtl_di   --信用卡客户交易流水
      where dt <= '20211205'  --换成自己的日期
      and wdw_rvs_ind <> '1'  --撤销冲正标志<>1
      and trx_typ_cd  >= 6000 and trx_typ_cd <= 6999
      and trx_typ_cd <> 6050
      and trx_typ_cd <> 6052
      and (trx_dscr_1 like '支付宝%' or trx_dscr_1 like '%财付通%')
) b on b.old_acq_mch_enc = a.srl_nbr and b.old_trx_dt = to_date(a.trx_dt,'yyyymmdd')
) group by cr_crd_card_nbr,biaozhi




-----------------
-- 共计627852个， 已开通2618个，未开通625234个
select count(distinct cst_id) as cst_id_num_m
from
(
select cr_crd_card_nbr
      ,cst_id
      ,case when b.serialno is null then '未开通' else '已开通' end as 是否开通备用金
      --,case when c.serialno is null then '截至昨天未用款' else c.inputdate as 首刷时间
      ,row_number()over(partition by cst_id order by cr_crd_card_nbr) as rn
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.loan_business_contract b on b.accountno = a.cr_crd_card_nbr and b.dt = a.dt
--left join edw.loan_business_duebill c on c.relativeserialno2 = b.serialno and c.dt = a.dt
where a.dt = '20211216'
) aa where aa.rn = 1
and 是否开通备用金 = '已开通'
;
-- 按照开发给的逻辑
-- 共计627852个， 已开通2618个，未开通625234个
-- 可以到卡级


-- 按照逻辑：PD_CD IN ('20105010104035301','20105010201015001')
-- 共计627852个客户，已开通2919个，未开通624933个
-- 无法到卡级，只能到客户级
-- 问题：如果一个客户开通了备用金，他一定是通过信用卡开通的吗？
select count(distinct cst_id) as cst_id_num_m
from
(
select a.cr_crd_card_nbr
      ,a.cst_id
      ,b.pd_cd
      ,case when b.pd_cd is null then '0' else '1' end as 是否开通备用金
      ,row_number()over(partition by a.cst_id order by a.cr_crd_card_nbr desc) as rn
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.dim_bus_loan_ctr_inf_dd b on a.cst_id = b.cst_id and b.dt = a.dt  and b.PD_CD IN ('20105010104035301','20105010201015001')
where a.dt = '20211216'
 --筛选备用金贷款
) aa where aa.rn = 1
and 是否开通备用金 = '已开通'
;


-- 查找不一致的客户号
select cst_id
from
(
select a.cr_crd_card_nbr
      ,a.cst_id
      ,b.pd_cd
      ,case when b.pd_cd is null then '未开通' else '已开通' end as 是否开通备用金
      ,row_number()over(partition by a.cst_id order by a.cr_crd_card_nbr) as rn
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.dim_bus_loan_ctr_inf_dd b on a.cst_id = b.cst_id and b.dt = a.dt  and b.PD_CD IN ('20105010104035301','20105010201015001')
where a.dt = '20211216'
 --筛选备用金贷款
) aa
where aa.rn = 1
and 是否开通备用金 = '已开通'
and cst_id not in (
     select cst_id
from
(
select a.cr_crd_card_nbr
      ,a.cst_id
      ,b.pd_cd
      ,case when b.pd_cd is null then '0' else '1' end as 是否开通备用金
      ,row_number()over(partition by a.cst_id order by a.cr_crd_card_nbr desc) as rn
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.dim_bus_loan_ctr_inf_dd b on a.cst_id = b.cst_id and b.dt = a.dt  and b.PD_CD IN ('20105010104035301','20105010201015001')
where a.dt = '20211216'
 --筛选备用金贷款
) aa where aa.rn = 1
and 是否开通备用金 = '1'
)
;


----------------------------------------------------------------------------2022.01.04 厂商修改代码（贷记卡卡级20211231.txt）
-发之前要改（表名、日期、贷记卡码表）
--信用卡主表信息
--信用卡卡片信息里的账号非空，客户号有空的 ，通过账户信息汇总表的账户进行关联得到客户号
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 AS
SELECT
        T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.CR_CRD_ACT_ID --信用卡账户
        ,T1.CST_ID  CST_ID   --客户号
        ,T.CR_CRD_PD_ID --信用卡产品编号
        ,T.MAIN_CRD_IND --主附卡标志（1-主卡）
        ,T.CARD_STS_CD --卡片状态代码
        ,T.MAIN_CARD_CARD_NBR --主卡卡号
        ,T.MTU_DAY --卡片到期日
        ,T.ISU_RSN_CD --发卡原因代码
        ,T.ISU_DT    --发卡日期
        ,T.CARD_ACTV_DT  --卡片激活日期
        ,T.CHG_CARD_TMS    --换卡次数
        ,T1.ACT_STS_CD --信用卡账户状态
        ,T1.CRD_LMT   --信用额度
        ,T1.INI_ACT_DT   --信用卡账户的初始激活日期
        ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
        ,T2.CRD_LVL         --卡片等级
        ,T2.CRD_LVL_NM      --卡片等级名称
        ,CASE WHEN T.CARD_STS_CD = 'A' THEN '0' ELSE '1' END AS  JIHUO_F  --当前是否已激活
        ,CASE
           WHEN T.CARD_STS_CD NOT IN ( 'Q' , '2' ) AND T1.ACT_STS_CD <> 'V' AND T1.CRD_LMT > 0 AND TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', T.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') > '@@{YYYYMMDD}' THEN '1'
           ELSE '0'
         END CUNXU_FLAG --是否存续卡
        ,CASE
           WHEN T3.ACT_ID IS NOT NULL THEN '1'
           ELSE '0'
         END AS MB_HANG_FLAG --手机银行下挂标识
FROM   EDW.DIM_BUS_CRD_CR_CRD_INF_DD  T --信用卡卡片信息
LEFT JOIN    EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
ON      T.CR_CRD_ACT_ID = T1.CR_CRD_ACT_ID
AND     T1.DT = '@@{YYYYMMDD}'
LEFT JOIN    APP_RPT.DIM_CR_CRD_PD T2 --信用卡产品信息
ON      T.CR_CRD_PD_ID = T2.PD_CD
LEFT JOIN    EDW.DIM_BUS_CHNL_ELEC_NB_IDV_CST_ACT_INF_DD T3 --网银个人客户账户信息
ON      T.CR_CRD_CARD_NBR = T3.ACT_ID
AND     T.CST_ID = T3.NB_CST_ID
AND     T3.ACT_ID_TYP = 'C' --信用卡
AND     T3.CHNL = '1' --手机
AND     T3.DT = '@@{YYYYMMDD}'
WHERE   T.DT = '@@{YYYYMMDD}'
;
--信用卡绑定情况
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z02;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z02 AS
SELECT  N1.CST_ID        --客户号
        ,N1.CR_CRD_ACT_ID   --信用卡账号
        ,N1.CR_CRD_CARD_NBR  --信用卡卡号
        ,COALESCE(N2.WX_CARD_NOW_F,0) WX_CARD_NOW_F   --当前是否绑定信用卡微信公众号
        ,COALESCE(N2.WX_CARD_HIS_F,0)  WX_CARD_HIS_F    --是否历史绑定信用卡微信公众号
        ,CASE WHEN N3.BIND_CST_ACT_ID IS NOT NULL THEN '1' ELSE 0 END AS WX_BANK_NOW_F  --是否绑定泰隆银行微信
FROM    WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
LEFT JOIN (
            SELECT CR_CRD_CARD_NBR
                   ,BIND_STS WX_CARD_NOW_F --当前绑定状态
                   ,CASE WHEN LATE_BIND_DT  <>'18991231'  THEN  '1'  ELSE  '0' END AS WX_CARD_HIS_F --最近绑定日期
            FROM  EDW.DWD_BUS_CRD_WX_OFC_ACT_BIND_STS_INF_DD
            WHERE  DT = '@@{YYYYMMDD}'
            )N2
ON N1.CR_CRD_CARD_NBR = N2.CR_CRD_CARD_NBR
LEFT JOIN (
            SELECT   DISTINCT   CST_ID,BIND_CST_ACT_ID
            FROM  EDW.DWD_BUS_CHNL_ELEC_WECHAT_BIND_INF_DD
            WHERE  DT = '@@{YYYYMMDD}'
          )N3
ON N1.CST_ID = N3.CST_ID
AND N1.CR_CRD_CARD_NBR = N3.BIND_CST_ACT_ID

--信用卡消费金额、笔数(近90天、近30天)
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03 AS
SELECT CR_CRD_CARD_NBR
       ,SUM(CASE
                WHEN SUBSTR(TRX_TYP_CD,1,1)='1' AND MCH_TYP IN ('5812','5813','5814')
                AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS  INB_CREDITCARD_REPAST_CONSUME_AMT_90               --近90天餐饮交易金额
       ,SUM(CASE
               WHEN SUBSTR(TRX_TYP_CD,1,1)='1' AND MCH_TYP IN ('5812','5813','5814')
               AND WDW_RVS_IND = 0  THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_90                 --近90天餐饮交易笔数
       ,SUM(CASE
                WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
                AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
                OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
                AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_90                   --近90天航旅交易金额
       ,SUM(CASE
               WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
               AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
               OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
               AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_90                  --近90天航旅交易笔数
       ,SUM(CASE
                WHEN TRX_TYP_CD='1184'
                AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_90                  --近90天境外交易金额
       ,SUM(CASE
               WHEN TRX_TYP_CD='1184' AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_90                   --近90天境外交易笔数
       ,SUM(CASE
                WHEN SUBSTR(TRX_TYP_CD,1,1)='1'
                AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND MCH_TYP IN ('5812','5813','5814') AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_AMT_30                    --近30天餐饮交易金额
      ,SUM(CASE
              WHEN SUBSTR(TRX_TYP_CD,1,1)='1'
              AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND MCH_TYP IN ('5812','5813','5814')
              AND WDW_RVS_IND = 0  THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_30                    --近30天餐饮交易笔数
      ,SUM(CASE
              WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
              AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_30                      --近30天航旅交易金额
      ,SUM(CASE
              WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
              AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
             ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_30                       --近30天航旅交易笔数
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
               ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_30                     --近30天境外交易金额
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_30                        --近30天境外交易笔数
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DT <= '@@{YYYYMMDD}'  --换成自己的日期
AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
GROUP BY  CR_CRD_CARD_NBR

--支付宝财付通交易情况
--退货情况
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01 AS
SELECT  CR_CRD_CARD_NBR
        ,OLD_ACQ_MCH_ENC
        ,OLD_TRX_DT
        ,SUM(BACK_AMT) BACK_AMT
FROM (
        SELECT  CR_CRD_CARD_NBR
                ,SRL_NBR
                ,TRX_AMT AS BACK_AMT  --退货金额
                ,DATEADD(TO_DATE('19570101','YYYYMMDD'),SUBSTR(ACQ_MCH_ENC,1,5),'DD') AS OLD_TRX_DT  --原交易日期
                ,SUBSTR(ACQ_MCH_ENC,6,6) AS OLD_ACQ_MCH_ENC
       FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI   --信用卡客户交易流水
       WHERE DT <= '@@{YYYYMMDD}'  --换成自己的日期
       AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
       AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
       AND TRX_TYP_CD  >= 6000 AND TRX_TYP_CD <= 6999
       AND TRX_TYP_CD <> 6050
       AND TRX_TYP_CD <> 6052
       AND (TRX_DSCR_1 LIKE '支付宝%' OR  TRX_DSCR_1 LIKE '财付通%'))P
GROUP BY  CR_CRD_CARD_NBR,OLD_ACQ_MCH_ENC,OLD_TRX_DT;

--交易情况
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 AS
SELECT  A.CR_CRD_ACT_ID       --信用卡账号
        ,A.CR_CRD_CARD_NBR      --信用卡卡号
        ,A.SRL_NBR              --流水号
        ,A.TRX_AMT              --交易金额
        ,A.TRX_DT               --交易日期
        ,A.ACQ_MCH_ENC          --收单商户编码
        ,COALESCE(B.BACK_AMT,0)  BACK_AMT  --退货金额
        ,A.TRX_DSCR_1
        ,A.DT
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI  A
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01  B
ON B.OLD_ACQ_MCH_ENC = A.SRL_NBR
AND B.OLD_TRX_DT = TO_DATE(A.TRX_DT,'YYYYMMDD')
AND A.CR_CRD_CARD_NBR = B.CR_CRD_CARD_NBR
WHERE A.DT <= '@@{YYYYMMDD}'  --换成自己的日期
AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
AND A.WDW_RVS_IND <> '1'  --撤销冲正标志<>1
AND A.TRX_TYP_CD  >= 1000 AND A.TRX_TYP_CD <= 1999
AND A.TRX_TYP_CD <> 1050     --筛选交易类型为消费
AND (A.TRX_DSCR_1 LIKE '支付宝%' OR  A.TRX_DSCR_1 LIKE '财付通%')
AND A.RTN_GDS_TRX_ID <> '全额退货'
;
--汇总到卡级
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03 AS
SELECT N1.CST_ID
       ,N1.CR_CRD_ACT_ID
       ,N1.CR_CRD_CARD_NBR
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' THEN (TRX_AMT + BACK_AMT) END )AS ZFB_AMT_90  --近90天支付宝交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) ZFB_NBR_90     --近90天支付宝交易笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%' THEN (TRX_AMT + BACK_AMT) END )AS CFT_AMT_90  --近90天财付通交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) CFT_NBR_90                 --近90天财付通交易笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT)END
            )AS ZFB_AMT_30                     --近30天支付宝交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) ZFB_NBR_30                      --近30天支付宝交易笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT) END
            )AS CFT_AMT_30                      --近30天财付通交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) CFT_NBR_30                      --近30天财付通交易笔数
FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 N2
ON N1.CR_CRD_CARD_NBR = N2.CR_CRD_CARD_NBR
GROUP BY N1.CST_ID,N1.CR_CRD_ACT_ID,N1.CR_CRD_CARD_NBR
;

SELECT  N1.CST_ID        --客户号
        ,N1.CR_CRD_ACT_ID    --信用卡账号
        ,N1.CR_CRD_CARD_NBR    --信用卡卡号
        ,N1.CR_CRD_PD_ID      --信用卡产品编号
        ,N1.CRD_CTG_CD         --大卡种
        ,N1.CRD_LVL         --卡片等级
        ,N1.CRD_LVL_NM      --卡片等级名称
        ,N2.CRD_LVL_HIS     --客户信用卡历史最高等级
        ,N2.CRD_LVL_NOW     --客户信用卡当前最高等级
        ,N3.WX_CARD_NOW_F   --当前是否绑定信用卡微信公众号
        ,N3.WX_CARD_HIS_F    --是否历史绑定信用卡微信公众号
        ,N3.WX_BANK_NOW_F  --是否绑定泰隆银行微信
        ,N1.MB_HANG_FLAG  --是否下挂手机银行
        ,N1.CARD_ACTV_DT  --激活日期
        ,N1.ISU_DT   --发卡日期
        ,N1.CARD_STS_CD  --卡片状态
        ,N1.JIHUO_F  --是否激活
        ,CASE WHEN N2.JIHUO_NUM = 0 AND N1.CARD_STS_CD = 'A'                                                            THEN '新卡待激活'
              WHEN N1.ISU_RSN_CD = 'X' AND  N1.CARD_STS_CD = 'A'                                                          THEN '续卡待激活'
              WHEN N1.CHG_CARD_TMS <> 0 AND N1.CARD_STS_CD = 'A' AND N1.INI_ACT_DT <> ''                                  THEN '换卡待激活'
              WHEN N1.CARD_STS_CD = 'A' AND  N1.CARD_ACTV_DT = '18991231'  AND  N1.INI_ACT_DT = '' AND  N2.JIHUO_NUM >=1  THEN  '二卡待激活'
              ELSE '' END AS JIHUO_TYPE   --待激活类型
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_AMT_90,0) INB_CREDITCARD_REPAST_CONSUME_AMT_90       --近90天餐饮交易金额
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_CNT_90,0) INB_CREDITCARD_REPAST_CONSUME_CNT_90       --近90天餐饮交易笔数
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_AMT_90,0)  INB_CREDITCARD_PLANE_CONSUME_AMT_90        --近90天航旅交易金额
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_CNT_90,0)  INB_CREDITCARD_PLANE_CONSUME_CNT_90        --近90天航旅交易笔数
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_AMT_90,0)  INB_CREDITCARD_ABROAD_CONSUME_AMT_90      --近90天境外交易金额
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_CNT_90,0)  INB_CREDITCARD_ABROAD_CONSUME_CNT_90      --近90天境外交易笔数
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_AMT_30,0) INB_CREDITCARD_REPAST_CONSUME_AMT_30       --近30天餐饮交易金额
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_CNT_30,0) INB_CREDITCARD_REPAST_CONSUME_CNT_30       --近30天餐饮交易笔数
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_AMT_30,0)  INB_CREDITCARD_PLANE_CONSUME_AMT_30        --近30天航旅交易金额
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_CNT_30,0)  INB_CREDITCARD_PLANE_CONSUME_CNT_30        --近30天航旅交易笔数
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_AMT_30,0)  INB_CREDITCARD_ABROAD_CONSUME_AMT_30      --近30天境外交易金额
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_CNT_30,0)  INB_CREDITCARD_ABROAD_CONSUME_CNT_30      --近30天境外交易笔数
        ,COALESCE(N5.ZFB_AMT_90,0) ZFB_AMT_90    --近90天支付宝交易金额
        ,COALESCE(N5.ZFB_NBR_90,0) ZFB_NBR_90    --近90天支付宝交易笔数
        ,COALESCE(N5.CFT_AMT_90,0) CFT_AMT_90    --近90天财付通交易金额
        ,COALESCE(N5.CFT_NBR_90,0) CFT_NBR_90    --近90天财付通交易笔数
        ,COALESCE(N5.ZFB_AMT_30,0) ZFB_AMT_30    --近30天支付宝交易金额
        ,COALESCE(N5.ZFB_NBR_30,0) ZFB_NBR_30    --近30天支付宝交易笔数
        ,COALESCE(N5.CFT_AMT_30,0) CFT_AMT_30    --近30天财付通交易金额
        ,COALESCE(N5.CFT_NBR_30,0) CFT_NBR_30    --近30天财付通交易笔数
FROM    WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
LEFT JOIN  (
            SELECT   CST_ID
                     ,MAX(CRD_LVL)  CRD_LVL_HIS --历史卡的等级最高
                     ,MAX(CASE WHEN CUNXU_FLAG = 1 THEN CRD_LVL  END   ) CRD_LVL_NOW  --客户信用卡当前最高等级
                     ,COUNT(CASE WHEN  MAIN_CRD_IND = '1'  AND CARD_ACTV_DT <> '18991231'   THEN '1' END)   AS JIHUO_NUM  --客户信用卡主卡激活记录数
            FROM    WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
            GROUP BY  CST_ID
            )N2
ON N1.CST_ID  = N2.CST_ID
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z02 N3     --信用卡绑定情况
ON N1.CR_CRD_CARD_NBR = N3.CR_CRD_CARD_NBR
LEFT JOIN   WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03 N4    --信用卡消费金额、笔数(近90天、近30天)
ON N1.CR_CRD_CARD_NBR = N4.CR_CRD_CARD_NBR
LEFT JOIN   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03 N5    --支付宝财付通交易情况
ON N1.CR_CRD_CARD_NBR = N5.CR_CRD_CARD_NBR
**客群研究_贷记卡核对_卡级20220106.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-06 10:00:27
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--发之前要改（表名、日期、贷记卡码表）
--信用卡主表信息
--信用卡卡片信息里的账号非空，客户号有空的 ，通过账户信息汇总表的账户进行关联得到客户号
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 AS
SELECT
        T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.CR_CRD_ACT_ID --信用卡账户
        ,T1.CST_ID  CST_ID   --客户号
        ,T.CR_CRD_PD_ID --信用卡产品编号
        ,T.MAIN_CRD_IND --主附卡标志（1-主卡）
        ,T.CARD_STS_CD --卡片状态代码
        ,T.MAIN_CARD_CARD_NBR --主卡卡号
        ,T.MTU_DAY --卡片到期日
        ,T.ISU_RSN_CD --发卡原因代码
        ,T.ISU_DT    --发卡日期
        ,T.CARD_ACTV_DT  --卡片激活日期
        ,T.CHG_CARD_TMS    --换卡次数
        ,T1.ACT_STS_CD --信用卡账户状态
        ,T1.CRD_LMT   --信用额度
        ,T1.INI_ACT_DT   --信用卡账户的初始激活日期
        ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
        ,T2.CRD_LVL         --卡片等级
        ,T2.CRD_LVL_NM      --卡片等级名称
        ,CASE WHEN T.CARD_STS_CD = 'A' THEN '0' ELSE '1' END AS  JIHUO_F  --当前是否已激活
        ,CASE
           WHEN T.CARD_STS_CD NOT IN ( 'Q' , '2' ) AND T1.ACT_STS_CD <> 'V' AND T1.CRD_LMT > 0 AND TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', T.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') > '@@{YYYYMMDD}' THEN '1'
           ELSE '0'
         END CUNXU_FLAG --是否存续卡
        ,CASE
           WHEN T3.ACT_ID IS NOT NULL THEN '1'
           ELSE '0'
         END AS MB_HANG_FLAG --手机银行下挂标识
FROM   EDW.DIM_BUS_CRD_CR_CRD_INF_DD  T --信用卡卡片信息
LEFT JOIN    EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
ON      T.CR_CRD_ACT_ID = T1.CR_CRD_ACT_ID
AND     T1.DT = '@@{YYYYMMDD}'
LEFT JOIN    APP_RPT.DIM_CR_CRD_PD T2 --信用卡产品信息
ON      T.CR_CRD_PD_ID = T2.PD_CD
LEFT JOIN    EDW.DIM_BUS_CHNL_ELEC_NB_IDV_CST_ACT_INF_DD T3 --网银个人客户账户信息
ON      T.CR_CRD_CARD_NBR = T3.ACT_ID
AND     T.CST_ID = T3.NB_CST_ID
AND     T3.ACT_ID_TYP = 'C' --信用卡
AND     T3.CHNL = '1' --手机
AND     T3.DT = '@@{YYYYMMDD}'
WHERE   T.DT = '@@{YYYYMMDD}'
;

--  1.卡片为续卡的发卡日期核对：不一致
select t1.cr_crd_card_nbr
      ,t1.card_sts_cd
      ,t1.isu_dt
      ,t2.reissuedate
      ,t2.issuereas
from EDW.DIM_BUS_CRD_CR_CRD_INF_DD t1
left join edw.loan_creditcard_info t2 on t2.cardno = t1.cr_crd_card_nbr and t2.dt =t1.dt
where t1.dt = '20211231'
;
--  2.验证T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)：是否代码结果有码值为3的情况
--已验证，无



--信用卡绑定情况
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z02;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z02 AS
SELECT  N1.CST_ID        --客户号
        ,N1.CR_CRD_ACT_ID   --信用卡账号
        ,N1.CR_CRD_CARD_NBR  --信用卡卡号
        ,COALESCE(N2.WX_CARD_NOW_F,0) WX_CARD_NOW_F   --当前是否绑定信用卡微信公众号
        ,COALESCE(N2.WX_CARD_HIS_F,0)  WX_CARD_HIS_F    --是否历史绑定信用卡微信公众号
        ,CASE WHEN N3.BIND_CST_ACT_ID IS NOT NULL THEN '1' ELSE 0 END AS WX_BANK_NOW_F  --是否绑定泰隆银行微信
FROM    WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
LEFT JOIN (
            SELECT CR_CRD_CARD_NBR
                   ,BIND_STS WX_CARD_NOW_F --当前绑定状态
                   ,CASE WHEN LATE_BIND_DT  <>'18991231'  THEN  '1'  ELSE  '0' END AS WX_CARD_HIS_F --最近绑定日期
            FROM  EDW.DWD_BUS_CRD_WX_OFC_ACT_BIND_STS_INF_DD
            WHERE  DT = '@@{YYYYMMDD}'
            )N2
ON N1.CR_CRD_CARD_NBR = N2.CR_CRD_CARD_NBR
LEFT JOIN (
            SELECT   DISTINCT   CST_ID,BIND_CST_ACT_ID
            FROM  EDW.DWD_BUS_CHNL_ELEC_WECHAT_BIND_INF_DD
            WHERE  DT = '@@{YYYYMMDD}'
          )N3
ON N1.CST_ID = N3.CST_ID
AND N1.CR_CRD_CARD_NBR = N3.BIND_CST_ACT_ID
;


--信用卡消费金额、笔数(近90天、近30天)
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03 AS
SELECT CR_CRD_CARD_NBR
       ,SUM(CASE
                WHEN SUBSTR(TRX_TYP_CD,1,1)='1' AND MCH_TYP IN ('5812','5813','5814')
                AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS  INB_CREDITCARD_REPAST_CONSUME_AMT_90               --近90天餐饮交易金额
       ,SUM(CASE
               WHEN SUBSTR(TRX_TYP_CD,1,1)='1' AND MCH_TYP IN ('5812','5813','5814')
               AND WDW_RVS_IND = 0  THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_90                 --近90天餐饮交易笔数
       ,SUM(CASE
                WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
                AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
                OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
                AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_90                   --近90天航旅交易金额
       ,SUM(CASE
               WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
               AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
               OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
               AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_90                  --近90天航旅交易笔数
       ,SUM(CASE
                WHEN TRX_TYP_CD='1184'
                AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_90                  --近90天境外交易金额
       ,SUM(CASE
               WHEN TRX_TYP_CD='1184' AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_90                   --近90天境外交易笔数
       ,SUM(CASE
                WHEN SUBSTR(TRX_TYP_CD,1,1)='1'
                AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND MCH_TYP IN ('5812','5813','5814') AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_AMT_30                    --近30天餐饮交易金额
      ,SUM(CASE
              WHEN SUBSTR(TRX_TYP_CD,1,1)='1'
              AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND MCH_TYP IN ('5812','5813','5814')
              AND WDW_RVS_IND = 0  THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_REPAST_CONSUME_CNT_30                    --近30天餐饮交易笔数
      ,SUM(CASE
              WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
              AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
            ) AS INB_CREDITCARD_PLANE_CONSUME_AMT_30                      --近30天航旅交易金额
      ,SUM(CASE
              WHEN (SUBSTR(TRX_TYP_CD,1,1)='1'
              AND MCH_TYP IN ('4112','4111','4121','4411','4511','4582','4722','4733','5962','7011','7012')
              OR SUBSTR(MCH_TYP,1,2) IN ('30','31','32','35','37'))
              AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
              AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
             ) AS INB_CREDITCARD_PLANE_CONSUME_CNT_30                       --近30天航旅交易笔数
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND WDW_RVS_IND = 0 THEN TRX_AMT ELSE 0 END
               ) AS INB_CREDITCARD_ABROAD_CONSUME_AMT_30                     --近30天境外交易金额
      ,SUM(CASE
               WHEN TRX_TYP_CD='1184'
               AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
               AND WDW_RVS_IND = 0 THEN 1 ELSE 0 END
            ) AS INB_CREDITCARD_ABROAD_CONSUME_CNT_30                        --近30天境外交易笔数
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DT <= '@@{YYYYMMDD}'  --换成自己的日期
AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
GROUP BY  CR_CRD_CARD_NBR
;


--支付宝财付通交易情况
--退货情况
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01 AS
SELECT  CR_CRD_CARD_NBR
        ,OLD_ACQ_MCH_ENC
        ,OLD_TRX_DT
        ,SUM(BACK_AMT) BACK_AMT
FROM (
        SELECT  CR_CRD_CARD_NBR
                ,SRL_NBR
                ,TRX_AMT AS BACK_AMT  --退货金额
                ,DATEADD(TO_DATE('19570101','YYYYMMDD'),SUBSTR(ACQ_MCH_ENC,1,5),'DD') AS OLD_TRX_DT  --原交易日期
                ,SUBSTR(ACQ_MCH_ENC,6,6) AS OLD_ACQ_MCH_ENC
       FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI   --信用卡客户交易流水
       WHERE DT <= '@@{YYYYMMDD}'  --换成自己的日期
       AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
       AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
       AND TRX_TYP_CD  >= 6000 AND TRX_TYP_CD <= 6999
       AND TRX_TYP_CD <> 6050
       AND TRX_TYP_CD <> 6052
       AND (TRX_DSCR_1 LIKE '支付宝%' OR  TRX_DSCR_1 LIKE '财付通%'))P
GROUP BY  CR_CRD_CARD_NBR,OLD_ACQ_MCH_ENC,OLD_TRX_DT;

--交易情况
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 AS
SELECT  A.CR_CRD_ACT_ID       --信用卡账号
        ,A.CR_CRD_CARD_NBR      --信用卡卡号
        ,A.SRL_NBR              --流水号
        ,A.TRX_AMT              --交易金额
        ,A.TRX_DT               --交易日期
        ,A.ACQ_MCH_ENC          --收单商户编码
        ,COALESCE(B.BACK_AMT,0)  BACK_AMT  --退货金额
        ,A.TRX_DSCR_1
        ,A.DT
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI  A
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P01  B
ON B.OLD_ACQ_MCH_ENC = A.SRL_NBR
AND B.OLD_TRX_DT = TO_DATE(A.TRX_DT,'YYYYMMDD')
AND A.CR_CRD_CARD_NBR = B.CR_CRD_CARD_NBR
WHERE A.DT <= '@@{YYYYMMDD}'  --换成自己的日期
AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 90
AND A.WDW_RVS_IND <> '1'  --撤销冲正标志<>1
AND A.TRX_TYP_CD  >= 1000 AND A.TRX_TYP_CD <= 1999
AND A.TRX_TYP_CD <> 1050     --筛选交易类型为消费
AND (A.TRX_DSCR_1 LIKE '支付宝%' OR  A.TRX_DSCR_1 LIKE '财付通%')
AND A.RTN_GDS_TRX_ID <> '全额退货'
;

--汇总到卡级
DROP TABLE IF EXISTS WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03;
CREATE TABLE   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03 AS
SELECT N1.CST_ID
       ,N1.CR_CRD_ACT_ID
       ,N1.CR_CRD_CARD_NBR
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' THEN (TRX_AMT + BACK_AMT) END )AS ZFB_AMT_90  --近90天支付宝交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) ZFB_NBR_90     --近90天支付宝交易笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%' THEN (TRX_AMT + BACK_AMT) END )AS CFT_AMT_90  --近90天财付通交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%' AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END ) CFT_NBR_90                 --近90天财付通交易笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT)END
            )AS ZFB_AMT_30                     --近30天支付宝交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '支付宝%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) ZFB_NBR_30                      --近30天支付宝交易笔数
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 THEN (TRX_AMT + BACK_AMT) END
            )AS CFT_AMT_30                      --近30天财付通交易金额
       ,SUM(CASE WHEN TRX_DSCR_1 LIKE '财付通%'
                 AND DATEDIFF(TO_DATE('@@{YYYYMMDD}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30
                 AND (TRX_AMT + BACK_AMT) > 0 THEN 1 ELSE 0 END
              ) CFT_NBR_30                      --近30天财付通交易笔数
FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
LEFT JOIN WB_BIGDATA_MANAGER_DEV.CUS_CARD_P02 N2
ON N1.CR_CRD_CARD_NBR = N2.CR_CRD_CARD_NBR
GROUP BY N1.CST_ID,N1.CR_CRD_ACT_ID,N1.CR_CRD_CARD_NBR
;


SELECT  N1.CST_ID        --客户号
        ,N1.CR_CRD_ACT_ID    --信用卡账号
        ,N1.CR_CRD_CARD_NBR    --信用卡卡号
        ,N1.CR_CRD_PD_ID      --信用卡产品编号
        ,N1.CRD_CTG_CD         --大卡种
        ,N1.CRD_LVL         --卡片等级
        ,N1.CRD_LVL_NM      --卡片等级名称
        ,N2.CRD_LVL_HIS     --客户信用卡历史最高等级
        ,N2.CRD_LVL_NOW     --客户信用卡当前最高等级
        ,N3.WX_CARD_NOW_F   --当前是否绑定信用卡微信公众号
        ,N3.WX_CARD_HIS_F    --是否历史绑定信用卡微信公众号
        ,N3.WX_BANK_NOW_F  --是否绑定泰隆银行微信
        ,N1.MB_HANG_FLAG  --是否下挂手机银行
        ,N1.CARD_ACTV_DT  --激活日期
        ,N1.ISU_DT   --发卡日期
        ,N1.CARD_STS_CD  --卡片状态
        ,N1.JIHUO_F  --是否激活
        ,CASE WHEN N2.JIHUO_NUM = 0 AND N1.CARD_STS_CD = 'A'                                                            THEN '新卡待激活'
              WHEN N1.ISU_RSN_CD = 'X' AND  N1.CARD_STS_CD = 'A'                                                          THEN '续卡待激活'
              WHEN N1.CHG_CARD_TMS <> 0 AND N1.CARD_STS_CD = 'A' AND N1.INI_ACT_DT <> ''                                  THEN '换卡待激活'
              WHEN N1.CARD_STS_CD = 'A' AND  N1.CARD_ACTV_DT = '18991231'  AND  N1.INI_ACT_DT = '' AND  N2.JIHUO_NUM >=1  THEN  '二卡待激活'
              ELSE '' END AS JIHUO_TYPE   --待激活类型
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_AMT_90,0) INB_CREDITCARD_REPAST_CONSUME_AMT_90       --近90天餐饮交易金额
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_CNT_90,0) INB_CREDITCARD_REPAST_CONSUME_CNT_90       --近90天餐饮交易笔数
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_AMT_90,0)  INB_CREDITCARD_PLANE_CONSUME_AMT_90        --近90天航旅交易金额
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_CNT_90,0)  INB_CREDITCARD_PLANE_CONSUME_CNT_90        --近90天航旅交易笔数
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_AMT_90,0)  INB_CREDITCARD_ABROAD_CONSUME_AMT_90      --近90天境外交易金额
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_CNT_90,0)  INB_CREDITCARD_ABROAD_CONSUME_CNT_90      --近90天境外交易笔数
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_AMT_30,0) INB_CREDITCARD_REPAST_CONSUME_AMT_30       --近30天餐饮交易金额
        ,COALESCE(N4.INB_CREDITCARD_REPAST_CONSUME_CNT_30,0) INB_CREDITCARD_REPAST_CONSUME_CNT_30       --近30天餐饮交易笔数
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_AMT_30,0)  INB_CREDITCARD_PLANE_CONSUME_AMT_30        --近30天航旅交易金额
        ,COALESCE(N4.INB_CREDITCARD_PLANE_CONSUME_CNT_30,0)  INB_CREDITCARD_PLANE_CONSUME_CNT_30        --近30天航旅交易笔数
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_AMT_30,0)  INB_CREDITCARD_ABROAD_CONSUME_AMT_30      --近30天境外交易金额
        ,COALESCE(N4.INB_CREDITCARD_ABROAD_CONSUME_CNT_30,0)  INB_CREDITCARD_ABROAD_CONSUME_CNT_30      --近30天境外交易笔数
        ,COALESCE(N5.ZFB_AMT_90,0) ZFB_AMT_90    --近90天支付宝交易金额
        ,COALESCE(N5.ZFB_NBR_90,0) ZFB_NBR_90    --近90天支付宝交易笔数
        ,COALESCE(N5.CFT_AMT_90,0) CFT_AMT_90    --近90天财付通交易金额
        ,COALESCE(N5.CFT_NBR_90,0) CFT_NBR_90    --近90天财付通交易笔数
        ,COALESCE(N5.ZFB_AMT_30,0) ZFB_AMT_30    --近30天支付宝交易金额
        ,COALESCE(N5.ZFB_NBR_30,0) ZFB_NBR_30    --近30天支付宝交易笔数
        ,COALESCE(N5.CFT_AMT_30,0) CFT_AMT_30    --近30天财付通交易金额
        ,COALESCE(N5.CFT_NBR_30,0) CFT_NBR_30    --近30天财付通交易笔数
FROM    WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01 N1
LEFT JOIN  (
            SELECT   CST_ID
                     ,MAX(CRD_LVL)  CRD_LVL_HIS --历史卡的等级最高
                     ,MAX(CASE WHEN CUNXU_FLAG = 1 THEN CRD_LVL  END   ) CRD_LVL_NOW  --客户信用卡当前最高等级
                     ,COUNT(CASE WHEN  MAIN_CRD_IND = '1'  AND CARD_ACTV_DT <> '18991231'   THEN '1' END)   AS JIHUO_NUM  --客户信用卡主卡激活记录数
            FROM    WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
            GROUP BY  CST_ID
            )N2
ON N1.CST_ID  = N2.CST_ID
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z02 N3     --信用卡绑定情况
ON N1.CR_CRD_CARD_NBR = N3.CR_CRD_CARD_NBR
LEFT JOIN   WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03 N4    --信用卡消费金额、笔数(近90天、近30天)
ON N1.CR_CRD_CARD_NBR = N4.CR_CRD_CARD_NBR
LEFT JOIN   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03 N5    --支付宝财付通交易情况
ON N1.CR_CRD_CARD_NBR = N5.CR_CRD_CARD_NBR


-- 3.验证JIHUO_NUM的逻辑是否正确：可以
select *
from (
SELECT
        T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.CR_CRD_ACT_ID --信用卡账户
        ,T1.CST_ID  CST_ID   --客户号
        ,T.CARD_ACTV_DT  --卡片激活日期
        ,T.MAIN_CRD_IND --主附卡标志（1-主卡）
        ,T1.ACT_STS_CD --信用卡账户状态
        ,T1.CRD_LMT   --信用额度
        ,T1.INI_ACT_DT   --信用卡账户的初始激活日期
        ,CASE WHEN  T.MAIN_CRD_IND = '1'  AND T.CARD_ACTV_DT <> '18991231'   THEN '1' END as aaaaa
        ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
        ,T2.CRD_LVL         --卡片等级
        ,T2.CRD_LVL_NM      --卡片等级名称
        ,CASE WHEN T.CARD_STS_CD = 'A' THEN '0' ELSE '1' END AS  JIHUO_F  --当前是否已激活
        ,CASE
           WHEN T.CARD_STS_CD NOT IN ( 'Q' , '2' ) AND T1.ACT_STS_CD <> 'V' AND T1.CRD_LMT > 0 AND TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', T.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') > '@@{YYYYMMDD}' THEN '1'
           ELSE '0'
         END CUNXU_FLAG --是否存续卡
FROM   EDW.DIM_BUS_CRD_CR_CRD_INF_DD  T --信用卡卡片信息
LEFT JOIN    EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
ON      T.CR_CRD_ACT_ID = T1.CR_CRD_ACT_ID
AND     T1.DT = '@@{YYYYMMDD}'
LEFT JOIN    APP_RPT.DIM_CR_CRD_PD T2 --信用卡产品信息
ON      T.CR_CRD_PD_ID = T2.PD_CD
WHERE   T.DT = '@@{YYYYMMDD}'
order by t.cst_id,t.CR_CRD_ACT_ID,t.CR_CRD_CARD_NBR
) aa
where aa.cst_id in ('1000000015','1000000021','1000000029','1000000039','1000000157','1000000159')
order by aa.cst_id
**客群研究_贷记卡核对_客户级.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-18 09:39:20
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
----------------------------------------------------------  账号问题未开发字段及逻辑汇总 20220118 ------------------------------
进件渠道、是否绑定支付宝、是否绑定第三方、是否历史绑定支付宝、是否历史绑定第三方、备用金、首刷、续卡发卡日期及其相关的未激活天数、发卡与激活间隔天数
1. 进件渠道
参考代码：
SELECT a.late_main_card_card_nbr  AS main_card_card_nbr --主卡卡号
      ,COALESCE(T1.CHANNEL, '')  AS chnl_cd_s
      ,CASE
        WHEN T1.DATA_FLG = '3' THEN COALESCE(T2.PRODUCT_NAME, '')
        WHEN T1.DATA_FLG = '2' THEN COALESCE(T1.CHANNELIN, '')
        ELSE COALESCE(T1.CHANNEL, '')
      END AS CHANNELIN  -- 进件渠道
FROM  edw.dws_bus_crd_cr_crd_act_inf_dd a --信用卡账户信息表  全量表
LEFT JOIN  edw.dim_bus_crd_cr_crd_inf_dd f ON a.cst_id = f.cst_id AND a.cr_crd_act_id = f.cr_crd_act_id AND f.dt = '20210731'     --信用卡卡片信息表
LEFT JOIN  app_rpt.FCT_CRD_CARD_APL_INFO T1 ON f.busi_apl_id = T1.SERIALNO AND T1.dt = '20210731'     --信用卡申请表
LEFT JOIN    (
                 SELECT  APPLY_SEQ_NO
                         ,PRODUCT_NAME
                         ,ROW_NUMBER() OVER ( PARTITION BY APPLY_SEQ_NO ) AS RN
                 FROM    edw.SFPS_TB_JD_BUINESS_INFO -- 金融云申请渠道
                 WHERE   DT = '20210731'
             ) T2
ON  T2.APPLY_SEQ_NO = T1.SERIALNO AND T2.RN = 1
WHERE a.dt = '20210731'
;

2. 是否绑定支付宝、是否历史绑定支付宝
表app_ado.cr_crd_epcc_cr_ar_inf	信用卡绑定信息汇总表

3. 是否绑定第三方、是否历史绑定第三方
select
   distinct
   t.idno                               --签约人证件号
   ,t.sgnacctid                         --签约人卡号
   ,t.instgacct                         --签约人支付账户号
   ,t.instgid                           --支付机构标识
   ,t.agrmtsts                          --协议状态
   ,t.sgndt                             --签约时间
   --,t1.cst_id                           --客户号
   ,t2.instgshornm                      --绑定渠道
from edw.epcc_epcc_payagrmt t            --第三方支付表
--inner join (select distinct cst_id,doc_nbr  from lab_bigdata_dev.sample_20211024) T1
   --on t.idno=t1.doc_nbr
left join (select distinct instgid,instgshornm from edw.epcc_epcc_instgidinf where dt<='20211024') t2  --第三方支付明细表
   on t.instgid = t2.instgid
where t.dt='20211024'
and t.agrmtsts='1' --有效
;


4. 首刷的字段 、是否开通备用金
参考代码：
select cr_crd_card_nbr
      ,case when b.serialno is null then '未开通' else '已开通' end as 是否开通备用金
      ,case when c.serialno is null then '截至昨天未用款' else c.inputdate as 首刷时间
from edw.dim_bus_crd_cr_crd_inf_dd a
left join edw.loan_business_contract b on b.accountno = a.cr_crd_card_nbr and b.dt = a.dt
left join edw.loan_business_duebill c on c.relativeserialno2 = b.serialno and c.dt = a.dt  --换成表：edw.dim_bus_loan_dbil_inf_dd
where a.dt = '20211216'
;

5. 续卡发卡日期及其相关的未激活天数、发卡与激活间隔天数
select cardno,reissuedate from edw.loan_creditcard_info where issuereas = 'X' and dt = '@@{yyyyMMdd}';




-- ******************************************************  核对情况汇总  ****************
1. 最早交易情况01,02合并，可直接用edw.dwd_bus_crd_cr_crd_trx_dtl_di，取现/转账添加条件：wdw_rvs_ind<>1
最早/最近一笔消费交易消费 未剔除全额退款部分，应该与卡级保持一致。添加条件：wdw_rvs_ind<>1 and rtn_gds_trx_id <> '全额退货'

2. 分期交易情况：添加一个分期付款状态 INSTL_PMT_STS not in ('E','F') --分期状态不为：E错误终止/F退货终止

--------------------------------------------------------------------------------- 核验过程 ---------------------------
----贷记卡客户
--申请日期 （剔除申请日期为18991231）
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_APPLY;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_APPLY AS
SELECT  CST_ID
        ,MIN(CASE WHEN   CRD_CTG_CD = '1' THEN APL_DT  END  ) MIN_DBT_CRD_APL_DATE   --客户贷记卡最早一笔申请日期
        ,MAX(CASE WHEN   CRD_CTG_CD = '1' THEN APL_DT  END  ) LATE_DBT_CRD_APL_DATE  --客户贷记卡最近一笔申请日期
        ,MIN(APL_DT) MIN_CR_CRD_APL_DATE   --客户信用卡最早一笔申请日期
        ,MAX(APL_DT) LATE_CR_CRD_APL_DATE  --客户信用卡最近一笔申请日期
FROM   (
         SELECT  T1.CST_ID
                 ,T1.CR_CRD_PD_ID
                 ,T1.APL_DT
                 ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
         FROM EDW.DWD_BUS_CRD_CR_CRD_APL_INF_DD T1
         LEFT JOIN APP_RPT.DIM_CR_CRD_PD  T2 --信用卡产品信息   --表名需要修改
         ON T1.CR_CRD_PD_ID = T2.PD_CD
         WHERE T1.DT  = '@@{yyyyMMdd}'
         AND T1.APL_DT <> '18991231'
        )P
WHERE CST_ID IN ('1003974411','1016670326','1016289151')
GROUP BY  CST_ID
;



-- 交易
SELECT CR_CRD_CARD_NBR
      ,wdw_rvs_ind
      ,MIN(TRX_DT) MIN_TRX_DATE --卡最早一笔交易日期
      ,MAX(TRX_DT) MAX_TRX_DATE --卡最近一笔交易日期
      ,MIN(CASE WHEN TRX_TYP_CD >= 2000 AND TRX_TYP_CD <= 2999 THEN TRX_DT END) MIN_CSH_TRSF_DATE --卡最早一笔取现/转账交易日期
      ,MAX(CASE WHEN TRX_TYP_CD >= 2000 AND TRX_TYP_CD <= 2999 THEN TRX_DT END) MAX_CSH_TRSF_DATE --卡最近一笔取现/转账交易日期
      ,MIN(CASE WHEN TRX_TYP_CD >= 1000 AND TRX_TYP_CD <= 1999 AND TRX_TYP_CD <> 1050 THEN TRX_DT END) MIN_CSM_DATE --卡最早一笔消费交易日期
      ,MAX(CASE WHEN TRX_TYP_CD >= 1000 AND TRX_TYP_CD <= 1999 AND TRX_TYP_CD <> 1050 THEN TRX_DT END) MAX_CSM_DATE --卡最近一笔消费交易日期
FROM edw.dwd_bus_crd_cr_crd_trx_dtl_di
WHERE DT <= '@@{yyyyMMdd}'
GROUP BY CR_CRD_CARD_NBR,wdw_rvs_ind
;



--到期日期情况
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_MTU_DAY;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_MTU_DAY AS
SELECT  CST_ID
        ,LATE_DQ_MTU_DATE     --客户信用卡已到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_DQ_MTU_DATE, 'YYYYMMDD'), 'DD') LATE_DQ_MTU_DAYS   --客户信用卡已到期最近天数
        ,LATE_MTU_DATE    --客户信用卡即将到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_MTU_DATE, 'YYYYMMDD'), 'DD') LATE_MTU_DAYS      --客户信用卡即将到期最近天数
        ,LATE_DBT_DQ_MTU_DATE --客户贷记卡已到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_DBT_DQ_MTU_DATE, 'YYYYMMDD'), 'DD') LATE_DBT_DQ_MTU_DAYS--客户贷记卡已到期最近天数
        ,LATE_DBT_MTU_DATE  --客户信用卡即将到期最近日期
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(LATE_DBT_MTU_DATE, 'YYYYMMDD'), 'DD')  LATE_DBT_MTU_DAYS  --客户信用卡即将到期最近天数
FROM (
       SELECT CST_ID
              ,MAX(CASE WHEN MTU_DAY<='@@{yyyyMMdd}' THEN MTU_DAY END ) LATE_DQ_MTU_DATE  --客户信用卡已到期最近日期
              ,MIN(CASE WHEN MTU_DAY>'@@{yyyyMMdd}'  THEN MTU_DAY END ) LATE_MTU_DATE    --客户信用卡即将到期最近日期
              ,MAX(CASE WHEN CRD_CTG_CD = 1 AND MTU_DAY <='@@{yyyyMMdd}'THEN MTU_DAY END ) LATE_DBT_DQ_MTU_DATE   --客户贷记卡已到期最近日期
              ,MIN(CASE WHEN CRD_CTG_CD = 1 AND MTU_DAY >'@@{yyyyMMdd}' THEN MTU_DAY END ) LATE_DBT_MTU_DATE       --客户贷记卡即将到期最近日期
       FROM (
              SELECT   CR_CRD_CARD_NBR --信用卡卡号
                      ,CR_CRD_ACT_ID --信用卡账户
                      ,CST_ID  CST_ID   --客户号
                      ,TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') MTU_DAY--卡片到期日
                      ,CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
                      ,CUNXU_FLAG --是否存续卡
              FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01)T1
       GROUP BY CST_ID
)T2
;


--信用卡客户级额度
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_LMT;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_LMT AS
SELECT  T1.CST_ID
        ,MAX(CASE WHEN T1.CUNXU_FLAG = '1' THEN  T2.CRD_LMT ELSE 0 END ) CRD_LMT--信用卡客户级额度
        ,SUM(T2.CRD_LMT)  SUM_CRD_LMT--信用卡总额度
        ,SUM(T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL) CRD_USED_AMT--信用卡用信金额
        ,SUM(CASE WHEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) <0 THEN 0 ELSE (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) END )  CRD_UNUSED_AMT--信用卡未使用金额
        ,MAX(CASE WHEN T1.CRD_CTG_CD = 1 AND T1.CUNXU_FLAG = '1' THEN T2.CRD_LMT ELSE 0 END ) DBT_CRD_LMT --贷记卡客户级额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.CRD_LMT ELSE 0 END )  SUM_DBT_CRD_LMT --贷记卡总额度
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  THEN T2.OVDR_BAL+T2.INSTL_RMN_NOT_PAID_PRCP_BAL END ) DBT_CRD_USED_AMT--贷记卡用信金额
        ,SUM(CASE WHEN T1.CRD_CTG_CD = 1  AND  (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) > 0 THEN (T2.CRD_LMT - T2.OVDR_BAL - T2.INSTL_RMN_NOT_PAID_PRCP_BAL) ELSE 0 END  ) DBT_CRD_UNUSED_AMT --贷记卡未使用金额
FROM LAB_BIGDATA_DEV.CUS_CARD_Z01   T1
LEFT JOIN EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T2
ON T1.MAIN_CARD_CARD_NBR = T2.LATE_MAIN_CARD_CARD_NBR
WHERE T2.DT  = '@@{yyyyMMdd}'
GROUP BY  T1.CST_ID
;

--他行贷记卡授信额度
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_OTHER_LMT;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_OTHER_LMT AS
SELECT  CST_ID
        ,OTH_BNK_ACT_CRD_LMT --他行贷记卡授信额度
        ,OTH_BNK_USE_LMT    --他行贷记卡用信额度
        ,CASE WHEN OTH_BNK_ACT_CRD_LMT >0 THEN COALESCE(OTH_BNK_USE_LMT,0)/OTH_BNK_ACT_CRD_LMT ELSE  0 END AS  OTH_BNK_USE_RATE  --他行贷记卡用信率
FROM (
       SELECT  CST_ID
               ,SUM(ACT_CRD_LMT) OTH_BNK_ACT_CRD_LMT --账户授信额度
               ,SUM(USE_LMT)     OTH_BNK_USE_LMT    --已用额度
        FROM  EDW.DIM_CST_CCRC_IDV_LOAN_INF_DD  --个人征信客户贷款信息
        WHERE  DT = '@@{yyyyMMdd}'
        AND ACT_TYP_CD = 'R2'  --贷记卡
        AND DTRB_ORG NOT LIKE '%ZJTLCB%'
        AND CST_ID != ''
        GROUP BY CST_ID
)P
;
**客群研究_贷记卡核对_账级20220110.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-10 13:51:53
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

-----------------------------------------------------------------账级厂商代码校验问题汇总 20220114 -------------------------------------
1. &quot;交易表&quot; 12个月内：时间有问题，应该是BETWEEN 0 AND 365
2. &quot;交易表&quot;添加&quot;交易时间&quot;字段，判断最近一笔时更准确
3. 退出类型和退出时间出需要修改一下，原来的逻辑有问题，代码也不够简洁
-- 退出类型、退出时间
SELECT CR_CRD_CARD_NBR  --信用卡卡号
      ,CR_CRD_ACT_ID    --信用卡账号
      ,CST_ID           --客户号
      ,TYPE             --退出类型
      ,TYPE_DATE        --退出时间
      ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY CR_CRD_CARD_NBR DESC) AS ROW_NO_1  --按卡号排序
FROM (
SELECT CR_CRD_CARD_NBR
      ,CR_CRD_ACT_ID
      ,CST_ID
      ,TYPE
      ,TYPE_DATE
      ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID,CR_CRD_CARD_NBR ORDER BY TYPE_DATE) ROW_NO  --按退出时间升序
FROM (
SELECT  CR_CRD_CARD_NBR  --退出的卡片
       ,CR_CRD_ACT_ID
       ,CST_ID
       ,CASE WHEN CARD_STS_CD = 'V' THEN '销卡'
             WHEN CARD_STS_CD = '2' THEN '过期未续'
			 WHEN ACT_STS_CD = 'V'  THEN '核销'
			 WHEN TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') < '@@{yyyyMMdd}' THEN '卡片到期'
			 ELSE ''  END AS TYPE
       ,CASE WHEN CARD_STS_CD IN ('V','2') THEN CARD_STS_DT
	     WHEN ACT_STS_CD = 'V' THEN ACT_STS_DT
	     WHEN TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') < '@@{yyyyMMdd}' THEN TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD')
	     ELSE '' END AS TYPE_DATE
FROM WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
WHERE CARD_STS_CD IN ('V','2') OR ACT_STS_CD = 'V' OR TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') < '@@{yyyyMMdd}'
) T ) T1
WHERE ROW_NO = 1
;

-----------------------------------------------------------------------------------------校验过程----------------------------------------------
--交易表
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_01;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_01 AS
SELECT  CR_CRD_ACT_ID     --信用卡账户
        ,CR_CRD_CARD_NBR     --信用卡卡号
        ,TRX_DT               --交易日期
        ,TRX_TM
        ,TRX_TYP_CD          --交易类型代码
        ,TRX_TLR             --交易柜员
        ,TRX_DSCR_1          --交易描述1
        ,CASE WHEN TRX_DSCR_1 LIKE '支付宝%' THEN '第三方渠道-支付宝'
              WHEN TRX_DSCR_1 LIKE '财付通%' THEN '第三方渠道-财付通'
              WHEN TRX_TYP_CD = 7028 THEN '第三方渠道-银联在线'
              WHEN TRX_TYP_CD IN (7000,7012,7020,7030,7036,7050,7054,7056,7062,7086,7092,7094,7096,7400) THEN '柜面'
              WHEN TRX_TYP_CD IN (7010,7040,7060,7080,7082,7084) THEN 'ATM'
              WHEN (TRX_TLR LIKE '%SJG%' OR TRX_TLR LIKE '%SJGY%') THEN '手机银行'
              WHEN (TRX_TLR LIKE '%WYGY%' OR TRX_TLR LIKE '%WYG%') THEN '网上银行'
            ELSE '' END AS CHANN_REPAY
        ,CASE WHEN (TRX_TYP_CD >= 7000 AND TRX_TYP_CD <= 7099 AND TRX_TYP_CD NOT IN (7002,7056) OR TRX_TYP_CD = 7400) THEN '自扣还款'
              WHEN (TRX_TYP_CD > 7099 AND TRX_TYP_CD <> 7400 OR TRX_TYP_CD IN (7002,7056)) AND
                  ((TRX_TYP_CD = 7000 AND TRX_TLR NOT LIKE '%XYGY%') OR  TRX_TYP_CD IN (7002,7010,7012,7024,7036,7040,7050,7054,7056,7060,7062,7070,7400)) THEN '非自扣本行渠道'
              WHEN (TRX_TYP_CD > 7099 AND TRX_TYP_CD <> 7400 OR TRX_TYP_CD IN (7002,7056)) AND
                 ((TRX_TYP_CD = 7000 AND TRX_TLR LIKE '%XYGY%') OR  TRX_TYP_CD IN (7020,7028,7030,7032,7076,7080,7082,7084,7092,7094,7096)) THEN '非本行渠道还款'
            ELSE '' END AS METHOD_REPAY
FROM EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI
WHERE DATEDIFF(TO_DATE('@@{yyyyMMdd}','YYYYMMDD'),TO_DATE(DT,'YYYYMMDD'),'DD') BETWEEN 0 AND 30   --改为12个月内
AND DT <= '@@{yyyyMMdd}' --改成自己日期
AND TRX_TYP_CD >= 7000 AND TRX_TYP_CD <= 7999  --筛选：还款
AND WDW_RVS_IND <> '1'  --撤销冲正标志<>1
;

SELECT * FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_01 WHERE METHOD_REPAY = '非本行渠道还款';

--还款次数
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_02;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_02 AS
SELECT  CR_CRD_ACT_ID
         ,SUM(CASE WHEN METHOD_REPAY = '自扣还款'      THEN 1 ELSE 0 END)  AS AUTO_DDCT_RPAY_NUM      --近12个月自扣还款次数
         ,SUM(CASE WHEN METHOD_REPAY = '非自扣本行渠道' THEN 1 ELSE 0 END)  AS NOT_AUTO_DDCT_RPAY_NUM  --近12个月非自扣本行渠道次数
         ,SUM(CASE WHEN METHOD_REPAY = '非本行渠道还款' THEN 1 ELSE 0 END)  AS NOT_OWNBANK_CHNL_NUM    --近12个月非本行渠道还款次数
FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_01
GROUP BY  CR_CRD_ACT_ID




--最近一次还款方式、最近一次还款渠道、最近一次还款交易日期
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_03;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_03 AS
SELECT  CR_CRD_ACT_ID
        ,METHOD_REPAY LAST_METHOD_REPAY      --最近一次还款方式
        ,CHANN_REPAY  LAST_CHANN_REPAY       --最近一次还款渠道
        ,TRX_DT       LAST_TRX_DT            --最近一次还款交易日期
FROM  (
        SELECT  CR_CRD_ACT_ID
                ,METHOD_REPAY      --还款方式
                ,CHANN_REPAY       --还款渠道
                ,TRX_DT            --交易日期
                ,ROW_NUMBER() OVER ( PARTITION BY CR_CRD_ACT_ID ORDER BY TRX_DT DESC ) AS ROW_NO
       FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_01)T
WHERE T.ROW_NO = 1



--还款频率最高渠道
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_04;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_04 AS
SELECT CR_CRD_ACT_ID             --信用卡账号
       ,CHANN_REPAY  MOST_CHANN_REPAY              --还款频率最高渠道
FROM (
       SELECT CR_CRD_ACT_ID       --信用卡账号
              ,CHANN_REPAY          --还款渠道
              ,CHANN_REPAY_NUM      --还款渠道次数
              ,ROW_NUMBER() OVER ( PARTITION BY CR_CRD_ACT_ID ORDER BY CHANN_REPAY_NUM DESC ) AS ROW_NO  --排序
       FROM (
              SELECT  CR_CRD_ACT_ID              --信用卡账号
                      ,CHANN_REPAY                 --还款渠道
                      ,COUNT(1)  CHANN_REPAY_NUM   --还款渠道次数
              FROM  LAB_BIGDATA_DEV.CUS_CRD_ACT_01
              GROUP BY  CR_CRD_ACT_ID,CHANN_REPAY
              )T1
      )T2
WHERE ROW_NO  = 1

--------------------------------------------- 20220110 逻辑核对 ----------------------------------
1. &quot;交易表&quot; 12个月内：时间有问题，应该是BETWEEN 0 AND 360
2. &quot;交易表&quot;添加&quot;交易时间&quot;字段，判断最近一笔时更加精准

SELECT T1.CR_CRD_ACT_ID
      ,T1.CHANN_REPAY   --最近一次还款渠道
	  ,T1.METHOD_REPAY  --最近一次还款方式
	  ,T1.RN2           --每个账号每个渠道还款次数
	  ,T1.RN3           --每个账号每个方式还款次数
FROM (
SELECT CR_CRD_ACT_ID
      ,CHANN_REPAY
	  ,METHOD_REPAY
	  ,ROW_NUMBER()OVER(PARTITION BY CR_CRD_ACT_ID ORDER BY TRX_DT DESC,TRX_TM DESC) AS RN1           --计数
	  ,COUNT(TRX_DT)OVER(PARTITION BY CR_CRD_ACT_ID,CHANN_REPAY ORDER BY TRX_DT,TRX_TM) AS RN2   --每个账号每个渠道次数
	  ,COUNT(TRX_DT)OVER(PARTITION BY CR_CRD_ACT_ID,METHOD_REPAY ORDER BY TRX_DT,TRX_TM) AS RN3  --每个账号每个方式次数
FROM LAB_BIGDATA_DEV.CUS_CRD_ACT_01
) T1
WHERE T1.RN1 = 1
;

select * from LAB_BIGDATA_DEV.CUS_CRD_ACT_01 where cr_crd_act_id in ('0000100038','0000100303','0000100045')


--------------------------------------------------------------------------------------------------
--退出类型、退出时间(用到卡级中的 WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01表)
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05 AS
SELECT  CR_CRD_ACT_ID --信用卡账户
        ,CST_ID       --客户号
        ,TYPE         --退出类型
        ,TYPE_DATE    --退出时间
        ,CR_CRD_CARD_NBR
        ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID  ORDER BY CR_CRD_CARD_NBR DESC ) ROW_NO_1 --按卡号排序
FROM  (
        SELECT CR_CRD_CARD_NBR --信用卡卡号
               ,CR_CRD_ACT_ID --信用卡账户
               ,CST_ID        --客户号
               ,TYPE
               ,TYPE_DATE
               ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID,CR_CRD_CARD_NBR ORDER BY TYPE_DATE) ROW_NO
        FROM  (
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'销卡时间'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                WHERE  CARD_STS_CD = 'V'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'过期未续时间'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE     --卡片状态
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                WHERE   CARD_STS_CD = '2'   --过期未续卡片
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'核销时间'  AS TYPE
                        ,ACT_STS_DT  AS TYPE_DATE
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                WHERE ACT_STS_CD = 'V'     --核销
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'卡片过期时间'  AS TYPE
                        ,TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD')   TYPE_DATE
                FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01
                )T
      )T1
WHERE  ROW_NO = 1



--汇总字段(用到卡级中的 WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01表)
SELECT P1.CST_ID  CST_ID   --客户号
       ,P1.CR_CRD_ACT_ID --信用卡账户
       ,P2.AUTO_DDCT_RPAY_NUM      --近12个月自扣还款次数
       ,P2.NOT_AUTO_DDCT_RPAY_NUM  --近12个月非自扣本行渠道次数
       ,P2.NOT_OWNBANK_CHNL_NUM    --近12个月非本行渠道还款次数
       ,P3.LAST_METHOD_REPAY      --最近一次还款方式
       ,P3.LAST_CHANN_REPAY       --最近一次还款渠道
       ,P3.LAST_TRX_DT            --最近一次还款交易日期
       ,P4.MOST_CHANN_REPAY         --还款频率最高渠道
       ,P5.TYPE                   --退出类型
       ,P5.TYPE_DATE            --退出时间
       ,COALESCE(P6.INB_CREDITCARD_REPAST_CONSUME_AMT_90,0) INB_CREDITCARD_REPAST_CONSUME_AMT_90       --近90天餐饮交易金额
       ,COALESCE(P6.INB_CREDITCARD_REPAST_CONSUME_CNT_90,0) INB_CREDITCARD_REPAST_CONSUME_CNT_90       --近90天餐饮交易笔数
       ,COALESCE(P6.INB_CREDITCARD_PLANE_CONSUME_AMT_90,0)  INB_CREDITCARD_PLANE_CONSUME_AMT_90        --近90天航旅交易金额
       ,COALESCE(P6.INB_CREDITCARD_PLANE_CONSUME_CNT_90,0)  INB_CREDITCARD_PLANE_CONSUME_CNT_90        --近90天航旅交易笔数
       ,COALESCE(P6.INB_CREDITCARD_ABROAD_CONSUME_AMT_90,0)  INB_CREDITCARD_ABROAD_CONSUME_AMT_90      --近90天境外交易金额
       ,COALESCE(P6.INB_CREDITCARD_ABROAD_CONSUME_CNT_90,0)  INB_CREDITCARD_ABROAD_CONSUME_CNT_90      --近90天境外交易笔数
       ,COALESCE(P6.INB_CREDITCARD_REPAST_CONSUME_AMT_30,0) INB_CREDITCARD_REPAST_CONSUME_AMT_30       --近30天餐饮交易金额
       ,COALESCE(P6.INB_CREDITCARD_REPAST_CONSUME_CNT_30,0) INB_CREDITCARD_REPAST_CONSUME_CNT_30       --近30天餐饮交易笔数
       ,COALESCE(P6.INB_CREDITCARD_PLANE_CONSUME_AMT_30,0)  INB_CREDITCARD_PLANE_CONSUME_AMT_30        --近30天航旅交易金额
       ,COALESCE(P6.INB_CREDITCARD_PLANE_CONSUME_CNT_30,0)  INB_CREDITCARD_PLANE_CONSUME_CNT_30        --近30天航旅交易笔数
       ,COALESCE(P6.INB_CREDITCARD_ABROAD_CONSUME_AMT_30,0)  INB_CREDITCARD_ABROAD_CONSUME_AMT_30      --近30天境外交易金额
       ,COALESCE(P6.INB_CREDITCARD_ABROAD_CONSUME_CNT_30,0)  INB_CREDITCARD_ABROAD_CONSUME_CNT_30      --近30天境外交易笔数
       ,COALESCE(P7.ZFB_AMT_90,0) ZFB_AMT_90    --近90天支付宝交易金额
       ,COALESCE(P7.ZFB_NBR_90,0) ZFB_NBR_90    --近90天支付宝交易笔数
       ,COALESCE(P7.CFT_AMT_90,0) CFT_AMT_90    --近90天财付通交易金额
       ,COALESCE(P7.CFT_NBR_90,0) CFT_NBR_90    --近90天财付通交易笔数
       ,COALESCE(P7.ZFB_AMT_30,0) ZFB_AMT_30    --近30天支付宝交易金额
       ,COALESCE(P7.ZFB_NBR_30,0) ZFB_NBR_30    --近30天支付宝交易笔数
       ,COALESCE(P7.CFT_AMT_30,0) CFT_AMT_30    --近30天财付通交易金额
       ,COALESCE(P7.CFT_NBR_30,0) CFT_NBR_30    --近30天财付通交易笔数
FROM  WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z01  P1
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_02 P2
ON P1.CR_CRD_ACT_ID =  P2.CR_CRD_ACT_ID
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_03 P3
ON P1.CR_CRD_ACT_ID =  P3.CR_CRD_ACT_ID
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_04 P4
ON P1.CR_CRD_ACT_ID =  P4.CR_CRD_ACT_ID
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_05 P5
ON P1.CR_CRD_ACT_ID =  P5.CR_CRD_ACT_ID
AND P5.ROW_NO_1 = 1
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_06 P6
ON P1.CR_CRD_ACT_ID =  P6.CR_CRD_ACT_ID
LEFT JOIN  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_07 P7
ON P1.CR_CRD_ACT_ID =  P7.CR_CRD_ACT_ID







-----------------------------------20220113 查看两张表的状态是否一致
-- 问题：
-- 1.卡片过期时间
-- 两张表的状态是否一致：一致
select a.cr_crd_act_id 信用卡账户
      ,a.late_main_card_card_nbr 最新主卡卡号
      ,a.late_main_card_sts_cd 最新主卡状态代码
      ,a.act_sts_cd 信用卡账户状态
      ,b.card_sts_cd 卡片状态代码
from edw.dws_bus_crd_cr_crd_act_inf_dd a  --雨洁
left join edw.dim_bus_crd_cr_crd_inf_dd b on a.late_main_card_card_nbr = b.cr_crd_card_nbr and b.main_crd_ind = '1' and b.dt = a.dt
where a.dt = '20220112'
;
select cr_crd_card_nbr,main_crd_ind from edw.dim_bus_crd_cr_crd_inf_dd where dt = '20220112' order by cr_crd_card_nbr;

-- 卡片过期时间
SELECT CR_CRD_CARD_NBR
      ,MTU_DAY
      ,DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM')
      ,TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') AS MTU_DAY_1
FROM EDW.DIM_BUS_CRD_CR_CRD_INF_DD
WHERE DT = '20220112'
;

-------------------------------------------------------- 核对退出时间、类型 ------------------------------------------------
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CARD_Z01;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CARD_Z01 AS
SELECT
        T.CR_CRD_CARD_NBR --信用卡卡号
        ,T.CR_CRD_ACT_ID --信用卡账户
        ,T1.CST_ID  CST_ID   --客户号
        ,T.CR_CRD_PD_ID --信用卡产品编号
        ,T.MAIN_CRD_IND --主附卡标志（1-主卡）
        ,T.CARD_STS_CD --卡片状态代码
        ,t.CARD_STS_DT --卡片状态时间
        ,T.MAIN_CARD_CARD_NBR --主卡卡号
        ,T.MTU_DAY --卡片到期日
        ,T.ISU_RSN_CD --发卡原因代码
        ,T.ISU_DT    --发卡日期
        ,T.CARD_ACTV_DT  --卡片激活日期
        ,T.CHG_CARD_TMS    --换卡次数
        ,T1.ACT_STS_CD --信用卡账户状态
        ,T1.ACT_STS_DT --信用卡账户状态日期
        ,T1.CRD_LMT   --信用额度
        ,T1.INI_ACT_DT   --信用卡账户的初始激活日期
        ,T2.CRD_CTG_CD --大卡种分类(1-贷记卡,2-准贷记卡,3-随贷通)
        ,T2.CRD_LVL         --卡片等级
        ,T2.CRD_LVL_NM      --卡片等级名称
        ,CASE WHEN T.CARD_STS_CD = 'A' THEN '0' ELSE '1' END AS  JIHUO_F  --当前是否已激活
        ,CASE
           WHEN T.CARD_STS_CD NOT IN ( 'Q' , '2' ) AND T1.ACT_STS_CD <> 'V' AND T1.CRD_LMT > 0 AND TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', T.MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') > '@@{YYYYMMDD}' THEN '1'
           ELSE '0'
         END CUNXU_FLAG --是否存续卡
        ,CASE
           WHEN T3.ACT_ID IS NOT NULL THEN '1'
           ELSE '0'
         END AS MB_HANG_FLAG --手机银行下挂标识
FROM   EDW.DIM_BUS_CRD_CR_CRD_INF_DD  T --信用卡卡片信息
LEFT JOIN    EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1 --信用卡账户信息汇总
ON      T.CR_CRD_ACT_ID = T1.CR_CRD_ACT_ID
AND     T1.DT = '@@{YYYYMMDD}'
LEFT JOIN    APP_RPT.DIM_CR_CRD_PD T2 --信用卡产品信息
ON      T.CR_CRD_PD_ID = T2.PD_CD
LEFT JOIN    EDW.DIM_BUS_CHNL_ELEC_NB_IDV_CST_ACT_INF_DD T3 --网银个人客户账户信息
ON      T.CR_CRD_CARD_NBR = T3.ACT_ID
AND     T.CST_ID = T3.NB_CST_ID
AND     T3.ACT_ID_TYP = 'C' --信用卡
AND     T3.CHNL = '1' --手机
AND     T3.DT = '@@{YYYYMMDD}'
WHERE   T.DT = '@@{YYYYMMDD}'
;

select length(CR_CRD_CARD_NBR) from LAB_BIGDATA_DEV.CUS_CARD_Z01;
--------------------------------------------------------- 修改后 -----------------
SELECT  SUBSTR(CR_CRD_CARD_NBR,1,8) --信用卡卡号
        ,substr(trim(CR_CRD_CARD_NBR),9,16)
        ,CR_CRD_ACT_ID --信用卡账号
        ,CST_ID --客户号
        ,TYPE --退出类型
        ,TYPE_DATE --退出时间
        ,ROW_NUMBER() OVER ( PARTITION BY CR_CRD_ACT_ID ORDER BY CR_CRD_CARD_NBR DESC ) AS ROW_NO_1 --按卡号排序
FROM    (
            SELECT  CR_CRD_CARD_NBR
                    ,CR_CRD_ACT_ID
                    ,CST_ID
                    ,TYPE
                    ,TYPE_DATE
                    ,ROW_NUMBER() OVER ( PARTITION BY CR_CRD_ACT_ID , CR_CRD_CARD_NBR ORDER BY TYPE_DATE ) ROW_NO --按退出时间升序
            FROM    (
                        SELECT  CR_CRD_CARD_NBR --退出的卡片
                                ,CR_CRD_ACT_ID
                                ,CST_ID
                                ,CASE
                                   WHEN CARD_STS_CD = 'V'                                                                                                    THEN '销卡'
                                   WHEN CARD_STS_CD = '2'                                                                                                    THEN '过期未续'
                                   WHEN ACT_STS_CD = 'V'                                                                                                     THEN '核销'
                                   WHEN TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') < '@@{yyyyMMdd}' THEN '卡片到期'
                                   ELSE ''
                                 END AS TYPE
                                ,CASE
                                   WHEN CARD_STS_CD IN ( 'V' , '2' )                                                                                         THEN CARD_STS_DT
                                   WHEN ACT_STS_CD = 'V'                                                                                                     THEN ACT_STS_DT
                                   WHEN TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') < '@@{yyyyMMdd}' THEN TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD')
                                   ELSE ''
                                 END AS TYPE_DATE
                        FROM    LAB_BIGDATA_DEV.CUS_CARD_Z01
                        WHERE   CARD_STS_CD IN ( 'V' , '2' )
                            OR ACT_STS_CD = 'V'
                            OR TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD') < '@@{yyyyMMdd}'
                    ) T
        ) T1
WHERE   ROW_NO = 1;


----------------------------------------------厂商代码 ---------------------------------------
SELECT  CR_CRD_ACT_ID --信用卡账户
        ,CST_ID       --客户号
        ,TYPE         --退出类型
        ,TYPE_DATE    --退出时间
        ,CR_CRD_CARD_NBR
        ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID  ORDER BY CR_CRD_CARD_NBR DESC ) ROW_NO_1 --按卡号排序
FROM  (
        SELECT CR_CRD_CARD_NBR --信用卡卡号
               ,CR_CRD_ACT_ID --信用卡账户
               ,CST_ID        --客户号
               ,TYPE
               ,TYPE_DATE
               ,ROW_NUMBER()OVER (PARTITION BY CR_CRD_ACT_ID,CR_CRD_CARD_NBR ORDER BY TYPE_DATE) ROW_NO
        FROM  (
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'销卡时间'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                WHERE  CARD_STS_CD = 'V'
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'过期未续时间'  AS TYPE
                        ,CARD_STS_DT  AS TYPE_DATE     --卡片状态
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                WHERE   CARD_STS_CD = '2'   --过期未续卡片
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'核销时间'  AS TYPE
                        ,ACT_STS_DT  AS TYPE_DATE
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                WHERE ACT_STS_CD = 'V'     --核销
                UNION ALL
                SELECT  CR_CRD_CARD_NBR --信用卡卡号
                        ,CR_CRD_ACT_ID  --信用卡账户
                        ,CST_ID         --客户号
                        ,'卡片过期时间'  AS TYPE
                        ,TO_CHAR(DATEADD(DATEADD(TO_DATE(CONCAT('20', MTU_DAY), 'YYYYMM'), 1, 'MM'), - 1, 'DD'), 'YYYYMMDD')   TYPE_DATE
                FROM  LAB_BIGDATA_DEV.CUS_CARD_Z01
                )T
      )T1
WHERE  ROW_NO = 1


--交易金额、笔数(用到卡级中的WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03表)
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_06;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_06 AS
SELECT CR_CRD_ACT_ID
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_AMT_90) INB_CREDITCARD_REPAST_CONSUME_AMT_90       --近90天餐饮交易金额
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_CNT_90) INB_CREDITCARD_REPAST_CONSUME_CNT_90       --近90天餐饮交易笔数
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_AMT_90)  INB_CREDITCARD_PLANE_CONSUME_AMT_90        --近90天航旅交易金额
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_CNT_90)  INB_CREDITCARD_PLANE_CONSUME_CNT_90        --近90天航旅交易笔数
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_AMT_90)  INB_CREDITCARD_ABROAD_CONSUME_AMT_90      --近90天境外交易金额
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_CNT_90)  INB_CREDITCARD_ABROAD_CONSUME_CNT_90      --近90天境外交易笔数
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_AMT_30) INB_CREDITCARD_REPAST_CONSUME_AMT_30       --近30天餐饮交易金额
       ,SUM(INB_CREDITCARD_REPAST_CONSUME_CNT_30) INB_CREDITCARD_REPAST_CONSUME_CNT_30       --近30天餐饮交易笔数
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_AMT_30)  INB_CREDITCARD_PLANE_CONSUME_AMT_30        --近30天航旅交易金额
       ,SUM(INB_CREDITCARD_PLANE_CONSUME_CNT_30)  INB_CREDITCARD_PLANE_CONSUME_CNT_30        --近30天航旅交易笔数
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_AMT_30)  INB_CREDITCARD_ABROAD_CONSUME_AMT_30      --近30天境外交易金额
       ,SUM(INB_CREDITCARD_ABROAD_CONSUME_CNT_30)  INB_CREDITCARD_ABROAD_CONSUME_CNT_30      --近30天境外交易笔数
FROM   WB_BIGDATA_MANAGER_DEV.CUS_CARD_Z03
GROUP BY CR_CRD_ACT_ID
;

--支付宝、财付通交易笔数、金额(用到卡级中的WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03表)
DROP TABLE IF EXISTS  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_07;
CREATE  TABLE  WB_BIGDATA_MANAGER_DEV.CUS_CRD_ACT_07 AS
SELECT CR_CRD_ACT_ID
       ,SUM(ZFB_AMT_90) ZFB_AMT_90    --近90天支付宝交易金额
       ,SUM(ZFB_NBR_90) ZFB_NBR_90    --近90天支付宝交易笔数
       ,SUM(CFT_AMT_90) CFT_AMT_90    --近90天财付通交易金额
       ,SUM(CFT_NBR_90) CFT_NBR_90    --近90天财付通交易笔数
       ,SUM(ZFB_AMT_30) ZFB_AMT_30    --近30天支付宝交易金额
       ,SUM(ZFB_NBR_30) ZFB_NBR_30    --近30天支付宝交易笔数
       ,SUM(CFT_AMT_30) CFT_AMT_30    --近30天财付通交易金额
       ,SUM(CFT_NBR_30) CFT_NBR_30    --近30天财付通交易笔数
FROM   WB_BIGDATA_MANAGER_DEV.CUS_CARD_P03
GROUP BY CR_CRD_ACT_ID
;
**客群研究_贷记卡生命周期标签0127.sql
--RFM(要存续卡)
DROP TABLE IF EXISTS  LAB_BIGDATA_DEV.CUS_CRD_ACT_RFM;
CREATE  TABLE  LAB_BIGDATA_DEV.CUS_CRD_ACT_RFM AS
SELECT T1.CST_ID
      ,T1.CR_CRD_ACT_ID
      ,COUNT(CASE WHEN T3.RCD_DT >= '@@{yyyyMMdd - 90d}' AND T3.RCD_DT <= '@@{yyyyMMdd}' THEN T3.TOT_PD_AMT END)    CST_CC_INSTL_NBR      --近90天分期交易次数
      ,SUM(CASE WHEN T3.RCD_DT >= '@@{yyyyMMdd - 90d}' AND T3.RCD_DT <= '@@{yyyyMMdd}' THEN T3.TOT_PD_AMT ELSE 0 END)  CST_CC_INSTL_AMT   --近90天分期交易金额
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T3.RCD_DT, 'YYYYMMDD'), 'DD') + 1) CST_CC_INSTL_RECENT_TO_NOW            --15.客户信用卡分期交易近度
      ,SUM(CASE WHEN T4.DT>= '@@{yyyyMMdd - 90d}' AND T4.DT <= '@@{yyyyMMdd}' THEN (T4.TRX_AMT + T4.BACK_AMT) END ) AS CST_CC_CSM_AMT     --近90天信用卡消费交易金额
      ,SUM(CASE WHEN T4.DT>= '@@{yyyyMMdd - 90d}' AND T4.DT <= '@@{yyyyMMdd}' AND (T4.TRX_AMT + T4.BACK_AMT) > 0 THEN 1 ELSE 0 END ) CST_CC_CSM_NBR     --近90天信用卡消费交易笔数
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T4.TRX_DT, 'YYYYMMDD'), 'DD') + 1) CST_CC_CSM_RECENT_TO_NOW              --13.客户信用卡消费交易近度
      ,SUM(CASE WHEN T5.DT >= '@@{yyyyMMdd - 90d}' AND T5.DT <= '@@{yyyyMMdd}' THEN 1 ELSE 0 END) CST_CC_CSH_NBR                          --近90天取现/转出次数
      ,SUM(CASE WHEN T5.DT >= '@@{yyyyMMdd - 90d}' AND T5.DT <= '@@{yyyyMMdd}' THEN T5.TRX_AMT ELSE 0 END) CST_CC_CSH_AMT                 --近90天取现/转出金额
      ,MIN(DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'YYYYMMDD'), TO_DATE(T5.TRX_DT, 'YYYYMMDD'), 'DD') + 1)  CST_CC_CSH_RECENT_TO_NOW             --14.客户信用卡取现/转出交易近度
FROM EDW.DWS_BUS_CRD_CR_CRD_ACT_INF_DD T1  --信用卡账户信息汇总
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_Z01 T2 ON T1.CR_CRD_ACT_ID = T2.CR_CRD_ACT_ID --卡级主表
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_INSTL_DTL_DD T3 ON T1.CR_CRD_ACT_ID = T3.CR_CRD_ACT_ID AND T1.DT = T3.DT AND T3.INSTL_PMT_STS NOT IN ('E','F')  --信用卡分期明细:分期付款状态<>E/F (错误终止/退货终止)
LEFT JOIN LAB_BIGDATA_DEV.CUS_CARD_P02 T4 ON T1.CR_CRD_ACT_ID = T4.CR_CRD_ACT_ID  --消费:剔除退货
LEFT JOIN EDW.DWD_BUS_CRD_CR_CRD_TRX_DTL_DI T5 ON T1.CR_CRD_ACT_ID = T5.CR_CRD_ACT_ID AND T5.DT <= '@@{yyyyMMdd}' AND T5.TRX_TYP_CD >= '2000' AND T5.TRX_TYP_CD <= '2999' AND T5.WDW_RVS_IND <> '1'   --取现/转账:信用卡交易流水表
WHERE T1.DT = '@@{yyyyMMdd}'
AND T2.CUNXU_FLAG = '1'  --存续标志
GROUP BY T1.CST_ID, T1.CR_CRD_ACT_ID
;
**客群研究_跑批尝试.sql
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_OTHER_LAST_ZX_REPORT_001;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.CUS_CRD_OTHER_LAST_ZX_REPORT_001 AS
SELECT  CST_ID
        ,REPORT_NO
        ,REPORT_DT
FROM    (
            SELECT  T.CST_ID
                    ,T.REPORT_NO
                    ,T.REPORT_DT
                    ,ROW_NUMBER() OVER ( PARTITION BY T.CST_ID ORDER BY T.REPORT_DT DESC ) ROW_NO
            FROM    EDW.DWS_CST_CCRC_IDV_IND_INF_DI T
            WHERE   T.DT <= '@@{yyyyMMdd}'
            AND     DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'yyyymmdd'), TO_DATE(SUBSTR(REPLACE(T.REPORT_DT, '-', ''), 1, 8), 'yyyymmdd'), 'dd') BETWEEN 0 AND 365 --取最近一年的征信报告
        ) A
WHERE   ROW_NO = 1;


--6.2 他行贷记卡授信额度
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.CUS_CRD_OTHER_LMT;
CREATE TABLE LAB_BIGDATA_DEV.CUS_CRD_OTHER_LMT AS
SELECT  P.CST_ID
        ,SUM(P.ACT_CRD_LMT) OTH_BNK_ACT_CRD_LMT --他行贷记卡授信额度
        ,SUM(P.USE_LMT) OTH_BNK_USE_LMT --他行贷记卡用信额度
        ,CASE
           WHEN SUM(P.ACT_CRD_LMT) = 0 THEN 0
           ELSE SUM(P.USE_LMT)/SUM(P.ACT_CRD_LMT)
         END AS OTH_BNK_USE_RATE --他行贷记卡用信率
FROM    (
            SELECT  T.CST_ID
                    ,T.REPORT_NO
                    ,T1.DTRB_ORG
                    ,MAX(COALESCE(T1.ACT_CRD_LMT, 0)) AS ACT_CRD_LMT --每个客户在每家银行授信额度
                    ,SUM(COALESCE(T1.USE_LMT, 0))     AS USE_LMT --已用额度
            FROM    LAB_BIGDATA_DEV.CUS_CRD_OTHER_LAST_ZX_REPORT_001 T
            LEFT JOIN    EDW.DIM_CST_CCRC_IDV_LOAN_INF_DD T1
            ON      T.REPORT_NO = T1.REPORT_ID
            AND     T1.DT = '@@{yyyyMMdd}'
            AND     T1.DTRB_ORG NOT LIKE '%ZJTLCB%'
            AND     T1.ACT_TYP_CD IN ( 'R2' ) --筛选出贷记卡和准贷记卡账户,R2贷记卡R3准贷记卡
            GROUP BY T.CST_ID , T.REPORT_NO , T1.DTRB_ORG
        ) P
GROUP BY P.CST_ID
;
**数据实验室_数据实验室入模需求.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-08 09:14:14
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

select *
from edw.DIM_BUS_COM_TBL_DEP_INF
where src_guid like lower('%loan_loan_post_task %')  --源表名，不加项目名
and (dst_guid like '%dim%' or dst_guid like '%dwd%' or dst_guid like '%dws%')
;
reissuedate


--ODS表权限
select *
from outd_YBJ_REFORM_BADRECORD

-- 查询表是否入模
SELECT  *
FROM    edw.DIM_BUS_COM_TBL_DEP_INF
WHERE   src_guid LIKE '%edw.loan_business_contract%'  -- 帖源层表名 注意用小写
AND     ( dst_guid LIKE '%dim%'
    OR dst_guid LIKE '%dwd%'
    OR dst_guid LIKE '%dws%' )
;

-- 20211103 苏任远 线上化项目组
edw.loan_entryform_relative     -- 已入模：odps.edw.dwd_bus_loan_apl_rel_dd
edw.loan_accumlationfund_info   -- 未入模，申请ODS    敏感：证件号码、姓名
edw.loan_business_apply         -- 已入模：odps.edw.dwd_bus_loan_apl_inf_dd
edw.loan_business_entryform     -- 已入模：odps.edw.dwd_bus_loan_entr_form_dd
edw.loan_preevaluate_relative   -- 未入模  无敏感
edw.edw_old_cips_zx_p_loan_info -- 未入模  证件号
edw.CIPS_ZX_P_C_L_SUM_INFO      -- 未入模  无敏感
edw.CIPS_ZX_P_CRED_CARD_INFO    -- 未入模  无敏感
edw.cips_zx_p_enqu_records      -- 未入模  查询人
edw.outd_GY_GJJ_MAIN            -- 未入模  被查询人证件号码、被查询人姓名、
edw.outd_GY_GJJ_BRIEF           -- 未入模  身份证、姓名、住址/地址、手机号码/联系电话、电子邮箱、
edw.outd_GY_GJJ_BRIEFDETAIL     -- 未入模  无敏感
edw.outd_GY_GJJ_COMPANYDATA     -- 未入模  无敏感
edw.outd_GY_GJJ_LOAN            -- 未入模  姓名、身份证、联系地址、手机号码/联系电话
edw.outd_GY_GJJ_LOANDETAIL      -- 未入模  无敏感
Edw.outd_gy_gjj_norm            -- 未入模  无敏感
**数据实验室_数据实验室日志.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-11 18:25:58
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 大数据部批量授权，应用层最新表清单
SELECT table_guid
      ,project_name as 项目名
      ,table_name as 表名
      ,table_comment as 中文名
      ,owner_name  as 技术负责人
FROM dmeta.adm_meta_dict_table_dd
WHERE DT = '20211212'
and owner_id like '%021041%'
;


select owner_id
from dmeta.adm_meta_dict_table_dd
WHERE DT = '20210101'
and

select *
FROM dmeta.adm_meta_dict_table_dd
WHERE DT = '20211123'
and domain_id is not null
and node_ids is not null
and project_name not like '%dev'
and project_name not like '%test'
and table_name not like 'dws%'
and table_name not like 'dwd%'
and table_name not like 'dim%'
;



--1.日志表
dmeta.dwd_meta_ops_task_odps_di;odps运行日志，每日增量明细数据


--2.元数据-数据字典-表信息
select *
from DMETA.adm_meta_dict_table_dd
where dt='20211123'



--3.数据实验室有主题域的表（20210928新增）
SELECT table_guid,table_comment,last_modify_time,owner_name
FROM dmeta.adm_meta_dict_table_dd
WHERE DT = '20210927'
and domain_id is not null
and node_ids is not null
and project_name not like '%dev'
and project_name not like '%test'




drop table if exists lab_bigdata_dev.xt_024618_zijianbiao_20211115;
create table if not exists lab_bigdata_dev.xt_024618_zijianbiao_20211115 as
select project_name
      ,table_name
      ,owner_name
      ,last_modify_time
      ,round(pangu_file_size/1024/1024/1024,2) as 文件大小GB
from dmeta.adm_meta_dict_table_dd
where dt='20211116'
and project_name in ('lab_risk_dev','lab_bigdata_dev','lab_sharedata_dev')
order by 文件大小GB desc
;


select empe_id,empe_nm,org_nm
from edw.dws_hr_empe_team_mng_dd
where dt = '20211114'
and org_nm like '%大数据%'


select a.empe_id,a.empe_nm,org_nm
from edw.dws_hr_empe_inf_dd a
left join edw.dim_hr_org_mng_org_tree_dd b on a.org_id= b.org_id and b.dt = a.dt
where
a.dt = '20211114'
and a.empe_nm
in
(
'sjkfzx'
,'付小勇'
,'何岸'
,'凌小芳'
,'刘圣源'
,'刘洋'
,'刘飞'
,'卫少洁'
,'吕全喜'
,'周蔷'
,'周蔷_生产查询'
,'唐杰君'
,'商小芳'
,'孙萌'
,'孟小会'
,'巫龙杰'
,'张全伟'
,'张海伦'
,'徐婷'
,'施黄强'
,'朱昱霏'
,'朱雪兰'
,'李丹'
,'李文博'
,'李昭贤'
,'李砚君'
,'杜威林'
,'杨帆'
,'江岚'
,'洪蓝飞'
,'王立葳'
,'王茜茜'
,'王雪艳'
,'盛王萍'
,'章锦程'
,'线上化共享实验室发布账号'
,'胡昌良'
,'苏任远'
,'荆灵'
,'谢乐冰'
,'谢慧丽'
,'谢立英'
,'赵剑飞'
,'邹宇玮'
,'金皑'
,'陈义斌'
,'陈敏敏'
,'陈灵球'
,'陈谋超'
,'龙彬彬'
)
;



select owner_name
      ,count(table_name) as 自建表数量
      ,round(sum(pangu_file_size/1024/1024/1024),2) as 自建表大小_sum
from dmeta.adm_meta_dict_table_dd
where dt='20211116'
and project_name in ('lab_risk_dev','lab_bigdata_dev','lab_sharedata_dev')
group by owner_name
order by 自建表大小_sum desc
;
**数据实验室_数据实验室监控.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-05 11:52:50
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
1.驾驶舱访问日志表
app_ado.IMP_T_VISIT_DSB_LOG_NEW;

2.泰隆数据app访问日志表
app_ado.imp_t_app_log_new

3.数据分析平台日志
app_ado.CAP_CAP_USER;  --数据分析平台-用户信息表
app_ado.DASBI_SHARE_INFO;  --数据分析平台-分享日志信息
app_ado.DASBI_AUDIT_LOG; --数据分析平台-操作日志
app_ado.DASBI_WORKBOOK_INFO; --数据分析平台-工作薄信息表

4.数据实验室日志
DMETA.adm_meta_dict_table_dd; --元数据-数据字典-表信息
dmeta.dwd_meta_ops_task_odps_di; --odps运行日志，每日增量明细数据
dmeta.ods_cap_user;
meta.m_security_user_table_map; --权限日志表&mdash;&mdash;分区字段为ds


5.自助取数平台日志
app_ado.DIM_T_SFD_JOB_LOG

6.报表管理平台日志
app_ado.FCT_RPT_LIST_LOG
*/
--dmeta.dws_meta_ast_table_access_nd   -------------------------------------------------------------

/*
1.公共表：中间层+应用层
监测内容：（1）表数量
         （2）表更新情况：识别超过6个月数据未更新的表
         （3）表使用频率：
              识别近6个月未使用或使用频率较低的表
              关注近6个月新上线的表使用情况
*/
drop table if exists lab_bigdata_dev.xt_024618_DGtable_pro;
create table if not exists lab_bigdata_dev.xt_024618_DGtable_pro as
select owner_id as 工号
      ,owner_name as 姓名
      ,table_name as 表名
      ,project_name as project名称
      ,ROUND(pangu_file_size/1024/1024/1024,2) as 盘古文件物理大小GB
      ,create_time as 表创建时间
      ,last_use_time as 最近一次访问时间
      ,last_modify_time as 最近一次修改时间
      ,datediff(getdate(),create_time,'dd') as 表创建距今天数
      ,datediff(getdate(),last_modify_time,'dd') as 数据未更新天数
      ,datediff(getdate(),last_use_time,'dd') as 最近一次访问距今天数
      ,use_cnt_30d as 最近30天访问次数
      ,dt as 日期
from DMETA.adm_meta_dict_table_dd
where dt = '@@{yyyyMMdd}'
and domain_id is not null  --剔除无主题域的表
and node_ids is not null  --产出nodeid不为空
and project_name not like '%dev'
and project_name not like '%test'
;
-----------------------------------------------------------------

-- 最近30天访问次数最多的一张表的情况
drop table if exists lab_bigdata_dev.xt_024618_DGtable_30day;
create table if not exists lab_bigdata_dev.xt_024618_DGtable_30day as
select *,ROUND(最近30天访问次数,0) as 最近30天访问次数_1
from lab_bigdata_dev.xt_024618_DGtable_pro
order by 最近30天访问次数 desc
limit 1;

-- 占用空间最大的一张表的建表和使用情况
drop table if exists lab_bigdata_dev.xt_024618_DGtable_maxgb;
create table if not exists lab_bigdata_dev.xt_024618_DGtable_maxgb as
select *
from lab_bigdata_dev.xt_024618_DGtable_pro
order by 盘古文件物理大小GB desc
limit 1;

-- 最近一次访问距今天数最大的一张表的情况
drop table if exists lab_bigdata_dev.xt_024618_DGtable_maxday;
create table if not exists lab_bigdata_dev.xt_024618_DGtable_maxday as
select *
from lab_bigdata_dev.xt_024618_DGtable_pro
order by 最近一次访问距今天数 desc
limit 1;




----------------------------
-- 1.表数量
drop table if exists lab_bigdata_dev.xt_024618_table_pro;
create table if not exists lab_bigdata_dev.xt_024618_table_pro as
select project_name
      ,owner_id
      ,owner_name
      ,table_name
      ,count(*)over(partition by project_name) as tableNum_project
      ,count(*)over(partition by owner_id) as tableNum_owner
      ,dt
from DMETA.adm_meta_dict_table_dd
where dt = '@@{yyyyMMdd}'
and domain_id is not null  --剔除无主题域的表
and node_ids is not null  --产出nodeid不为空
and project_name not like '%dev'
and project_name not like '%test'
;

/*
     -- 1.2 每个工号下表数量
drop table if exists lab_bigdata_dev.xt_024618_table_of_owner;
create table if not exists lab_bigdata_dev.xt_024618_table_of_owner as
select owner_id as 工号
      ,owner_name as 姓名
      ,count(distinct table_name) as 表数量
from DMETA.adm_meta_dict_table_dd
where dt = '@@{yyyyMMdd}'
and domain_id is not null  --剔除无主题域的表
and node_ids is not null  --产出nodeid不为空
and project_name not like '%dev'
and project_name not like '%test'
group by owner_id,owner_name
order by 表数量 desc
;
*/

-- 2.表更新情况：超过6个月数据未更新的表
drop table if exists lab_bigdata_dev.xt_024618_DGtable_pro;
create table if not exists lab_bigdata_dev.xt_024618_DGtable_pro as
select owner_id as 工号
      ,owner_name as 姓名
      ,table_name as 表名
      ,project_name as project名称
      ,ROUND(pangu_file_size/1024/1024/1024,2) as 盘古文件物理大小GB
      ,create_time as 表创建时间
      ,last_use_time as 最近一次访问时间
      ,last_modify_time as 最近一次修改时间
      ,datediff(getdate(),last_modify_time,'dd') as 数据未更新天数
      ,datediff(getdate(),last_use_time,'dd') as 最近一次访问距今天数
      ,dt as 日期
from DMETA.adm_meta_dict_table_dd
where dt = '@@{yyyyMMdd}'
and domain_id is not null  --剔除无主题域的表
and node_ids is not null  --产出nodeid不为空
and project_name not like '%dev'
and project_name not like '%test'
;

select * from lab_bigdata_dev.xt_024618_DGtable_pro;
-- 3.表使用频率
    -- 3.1 近6个月未使用
select table_name as 表名称
      ,project_name as project名称
      ,owner_id as 表所属owner工号
      ,owner_name as owner名称
      ,owner_department as 部门
      ,ROUND(pangu_file_size/1024/1024/1024,2) as 盘古文件物理大小GB
      ,create_time as 表创建时间
      ,last_use_time as 最近一次访问时间
      ,datediff(getdate(),last_use_time,'mm') as 最近一次访问距今时长_月
from DMETA.adm_meta_dict_table_dd
where dt = '@@{yyyyMMdd}'
--and datediff(getdate(),last_use_time,'mm') < 6
and domain_id is not null  --剔除无主题域的表
and node_ids is not null  --产出nodeid不为空
and project_name not like '%dev'
and project_name not like '%test'
order by 表创建时间 desc,最近一次访问时间
;

    -- 3.2 近30使用频次    是否应该限定创建时间，若是近期创建的表，使用频次低也合理
select table_name as 表名称
      ,project_name as project名称
      ,owner_id as 表所属owner工号
      ,owner_name as owner名称
      ,owner_department as 部门
      ,ROUND(pangu_file_size/1024/1024/1024,2) as 盘古文件物理大小GB
      ,create_time as 表创建时间
      ,last_use_time as 最近一次访问时间
      ,use_cnt_30d as 最近30天访问次数
      ,datediff(getdate(),last_use_time,'dd') as 最近一次访问距今时长_天
from DMETA.adm_meta_dict_table_dd
where dt = '@@{yyyyMMdd}'
and domain_id is not null  --剔除无主题域的表
and node_ids is not null  --产出nodeid不为空
and project_name not like '%dev'
and project_name not like '%test'
order by 最近30天访问次数,最近一次访问距今时长_天 desc
;

------------------------------------------------------




---------------------------------------------------------------------------------------
/*
2.用户表权限
监测内容：（1）各角色已授权表情况   哪个字段可以区分角色？
         （2）个人用户已授权表情况  user_name直接就是用户吗？是否需要从中拆解出特定字段？
         （3）已授权超过6个月未使用情况   此表没有日期数据，是否需要关联其他表？
*/
-- 分为两种情况
drop table if exists lab_bigdata_dev.xt_024618_DGprivileges;
create table if not exists lab_bigdata_dev.xt_024618_DGprivileges as
select substr(b.user_name,1,6) as empe_id
      ,b.true_name as empe_nm
      ,a.project_name
      ,a.table_name
      ,a.privileges
      --,count(a.table_name)over(partition by substr(b.user_name,1,6),privileges) as tbl_num
from
(
select user_name
      ,substr(user_name,28,10) as user_id
      ,table_name
      ,project_name
      ,privileges
from meta.m_security_user_table_map
where ds = '@@{yyyyMMdd}'
and length(user_name) = 48
) a
left join dmeta.ods_cap_user b on b.user_id = a.user_id and b.dt = '@@{yyyyMMdd}' and b.is_delete = '0'
where a.project_name  like 'lab%'
union all
select a.empe_id
      ,b.empe_nm
      ,a.project_name
      ,a.table_name
      ,a.privileges
      --,count(table_name)over(partition by a.empe_id,a.privileges) as tbl_num
from
(
select user_name
      ,substr(user_name,28,6) as empe_id
      ,table_name
      ,project_name
      ,privileges
from meta.m_security_user_table_map
where ds = '@@{yyyyMMdd}'
and length(user_name) = 42
) a
left join edw.dim_hr_empe_bas_inf_dd b on a.empe_id = b.empe_id and b.dt = '@@{yyyyMMdd}'
where a.project_name  like 'lab%'   --筛选出数据实验室
;
-------------------------------------------------------

drop table if exists lab_bigdata_dev.xt_024618_DGprivileges_of_owner;
create table if not exists lab_bigdata_dev.xt_024618_DGprivileges_of_owner as
select empe_id
      ,empe_nm
      ,privileges
      ,count(table_name) as table_num
from lab_bigdata_dev.xt_024618_DGprivileges
group by empe_id,empe_nm,privileges
;

select * from lab_bigdata_dev.xt_024618_DGprivileges_of_owner where empe_nm = '李文博';
**数据需求_20211008_上海分行个人银行结算账户开户清单.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-08 15:30:13
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--上线之前，月度需要，在原代码修改时间即可
drop table if exists lab_bigdata_dev.shanghai_xt_024618_20211102;
create table lab_bigdata_dev.shanghai_xt_024618_20211102 as
SELECT

    a.cst_id 客户号,
    c.doc_nbr 证件号码,
    c.mbl_nbr 手机号,
    c.fml_tel_nbr 家庭电话,
    c.cmp_tel_nbr 公司电话,
    a.cst_act_id 客户账号,
    c.cst_chn_nm 客户名称,
    a.act_nm 账户名称,
    a.opn_org 开户机构号,
    d.org_nm 开户机构名称,
    a.act_opn_tlr 开户柜员,
    a.opn_dt 开户日期
from edw.dim_bus_dep_act_inf_dd a ----存款账户信息
join edw.dws_bus_dep_act_inf_dd b --存款账户信息汇总
    on a.dep_act_id=b.dep_act_id
    and b.dt='20211031'
    and b.cst_tp='1' --对私
    and b.lbl_prod_typ_cd='0' --活期
left join edw.dws_cst_bas_inf_dd c --客户基础信息汇总表
    on a.cst_id=c.cst_id
    and c.dt='20211031'
left join edw.dim_hr_org_mng_org_tree_dd d  --机构树_考核维度
    on a.opn_org = d.org_id
    and d.dt = '20211031'
where a.dt='20211031'
and substr(a.opn_org,1,4)='3101' --上海分行
and a.opn_dt>='20211001'
and a.opn_dt<='20211031'
and a.stl_act_ind ='1' --结算标志为1
order by a.cst_id asc
;




-----------------------
select 客户号,证件号码,手机号,家庭电话,公司电话,客户账号,客户名称,账户名称,开户机构号,开户机构名称,开户柜员,开户日期 from lab_bigdata_dev.shanghai_xt_024618_20211102;
**数据需求_20211008_梁世鹏_10月随贷通全行电话催收.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-08 11:24:26
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--数据内容：	9月随贷通数据
--数据日期：20210930-20210930
--   1.自建表：导入合同编号（堡垒机）
create table xt_suidaitong_20211008
(
    合同编号 STRING COMMENT '合同编号'
)
;

select * from xt_suidaitong_20211008;




--   2.找出各个字段
drop table if exists xt_suidaitong_20211008_1;

CREATE TABLE IF NOT EXISTS xt_suidaitong_20211008_1
as
select DISTINCT a.*
from
(select aa.合同编号 as 合同编号
      ,ln.CST_id 客户号
      ,ln.cst_nm as 客户名称
      ,guaranty.OWNERID 担保人编号
      ,cst1.cst_chn_nm 担保人名称
      ,cst1.mbl_nbr  担保人电话
      ,row_number() over (partition by aa.合同编号 order by guaranty.OWNERID) as rn
from xt_suidaitong_20211008 aa
left join edw.loan_guaranty_relative rel on aa.合同编号 = rel.OBJECTNO and rel.OBJECTTYPE='BusinessContract' and rel.dt = '20211001'
left join edw.loan_guaranty_info guaranty  on rel.GUARANTYID=guaranty.GUARANTYID and guaranty.dt = '20211001'
left join edw.dws_cst_bas_inf_dd cst1 on guaranty.OWNERID = cst1.cst_id and cst1.dt = '20211001'
left join edw.dim_bus_loan_ctr_inf_dd ln on rel.OBJECTNO = ln.busi_ctr_id and ln.dt = '20211001'
) a;
-----------------------------------------
select * from xt_suidaitong_20211008_1;


--   3.字段整理
drop table if exists xt_suidaitong_20211008_2;

CREATE TABLE IF NOT EXISTS xt_suidaitong_20211008_2 AS
SELECT  a.合同编号
        ,a.客户号
        ,a.客户名称
        ,a.担保人编号 担保人编号1
        ,a.担保人名称 担保人名称1
        ,a.担保人电话 担保人电话1
        ,b.担保人编号 担保人编号2
        ,b.担保人名称 担保人名称2
        ,b.担保人电话 担保人电话2
        ,c.担保人编号 担保人编号3
        ,c.担保人名称 担保人名称3
        ,c.担保人电话 担保人电话3
        ,d.担保人编号 担保人编号4
        ,d.担保人名称 担保人名称4
        ,d.担保人电话 担保人电话4
        ,e.担保人编号 担保人编号5
        ,e.担保人名称 担保人名称5
        ,e.担保人电话 担保人电话5
        ,f.担保人编号 担保人编号6
        ,f.担保人名称 担保人名称6
        ,f.担保人电话 担保人电话6
        ,cc.LINKMANNAME1 联系人1
        ,LINKMANTEL1 联系人1电话
        ,LINKMANMOBTEL1 联系人1手机
        ,LINKMANNAME2 联系人2
        ,LINKMANTEL2 联系人2电话
        ,LINKMANMOBTEL2 联系人2手机
FROM    xt_suidaitong_20211008_1 a
LEFT JOIN    xt_suidaitong_20211008_1 b
ON      a.合同编号 = b.合同编号
AND     b.rn = 2
LEFT JOIN    xt_suidaitong_20211008_1 c
ON      a.合同编号 = c.合同编号
AND     c.rn = 3
LEFT JOIN    xt_suidaitong_20211008_1 d
ON      a.合同编号 = d.合同编号
AND     d.rn = 4
LEFT JOIN   xt_suidaitong_20211008_1 e
ON      a.合同编号 = e.合同编号
AND     e.rn = 5
LEFT JOIN   xt_suidaitong_20211008_1 f
ON      a.合同编号 = f.合同编号
AND     f.rn = 6
LEFT JOIN    edw.loan_creditcard_customer cc
ON      a.客户号 = cc.CUSTOMERID
AND     cc.dt = '20211001'
WHERE   a.rn = 1
;

select * from xt_suidaitong_20211008_2;
select count(合同编号) from xt_suidaitong_20211008_2;

select 合同编号,客户号,客户名称,担保人编号1,担保人名称1,担保人电话1,担保人编号2,担保人名称2,担保人电话2,担保人编号3,担保人名称3,担保人电话3,担保人编号4,担保人名称4,担保人电话4,担保人编号5,担保人名称5,
担保人电话5,担保人编号6,担保人名称6,担保人电话6,联系人1,联系人1电话,联系人1手机,联系人2,联系人2电话,联系人2手机 from xt_suidaitong_20211008_2;





select CUSTOMERID,LINKMANNAME1,LINKMANNAME2,LINKMANMOBTEL2
from edw.loan_creditcard_customer
where dt = '20211001'
and CUSTOMERID = '1032893150';
**数据需求_20211009_个人手机银行劳动竞赛激励.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-09 10:22:47
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

--取值时间：2021年9月11日至2021年9月30日
--客户号、客户姓名、开户日期、开通网点、主管户机构号、主管户机构名称、推荐人工号、推荐人姓名、岗位（如服务经理、营业经理）
--个人手机银行开通时间、手机银行首次登陆时间、首次个人手机银行转账时间、首次个人手机银行转账金额、首次手机号支付绑定时间、
--积分商城首次注册（登陆）时间、积分商城首次签到领积分时间、首次收货地址填写时间
-------------------------------------------------------------
drop table if exists sjyhjs_xt_20211008;

create table if not exists sjyhjs_xt_20211008
as
select a.pcc_cstno as 网银客户号
      ,f.cst_chn_nm as 客户姓名
      ,a.pcc_branchid as 开通网点
      ,e.min_opn_dt as 开户日期
      ,a.pcc_custleaderno as 推荐人工号
      ,d.pos_nm as 推荐人岗位
      ,a.pcc_custleadername as 推荐人姓名
      ,f.prm_org_id as 主管户机构号
      ,f.prm_org_nm as 主管户机构名称
      ,a.pcc_createtime as 渠道开通时间
      ,b.min_opr_tm as 首次登陆时间
      ,c.mtf_subtime as 首次转账时间
      ,c.mtf_tranamt as 首次转账金额
      ,h.min_sysdt as 首次手机号支付绑定时间
      ,g.addtime as 积分商城首次注册时间
from edw.ebnk_pb_cstinf_channel a --个人渠道信息表（新增）
left join
(
    SELECT
    nb_cst_id
    ,min(opr_tm) as min_opr_tm --首次登录日期 --TO_DATE(substr(min(opr_tm),1,8),'yyyymmdd') as min_opr_tm  --首次登录日期
    FROM edw.dwd_bus_chnl_elec_all_opr_aud_inf_di
    WHERE dt >= '20210911'
    and dt <= '20211231'
    and chnl_typ_cd = '01'    --01 手机银行,02 个人网银,03 企业网银,04 企业手机银行
    AND OPR_TYP_CD = '13'       --操作类型为登录
    AND err_cd = ''             --登录成功（无登录报错信息）
    AND LENGTH(nb_cst_id) = 10  --非游客（游客客户号为0+手机号，长度为12）
    GROUP BY nb_cst_id
) b
on a.pcc_cstno = b.nb_cst_id
left join
(
   select aa.*
   from (
     select  mtf_cstno,mtf_subtime,mtf_tranamt,row_number()over(partition by mtf_cstno order by mtf_subtime) as rn
     from edw.ebnk_mb_tranflow --手机银行交易流水
     where dt >= '20210911' and dt <= '20211231'
   )aa
   where aa.rn = 1
)c  on a.pcc_cstno = c.mtf_cstno
left join
(
    select t1.empe_id,t1.pos_enc,t2.pos_nm  --取岗位名称
    from edw.dws_hr_empe_inf_dd t1
    left join edw.dim_hr_org_job_inf_dd t2 on t1.pos_enc=t2.pos_id and t2.dt='20211231'
    where t1.dt = '20211231'
)d on a.pcc_custleaderno = d.empe_id
left join
(
    select cst_id,min(opn_dt) as min_opn_dt  --取开户时间
    from edw.dws_bus_dep_act_inf_dd
    where dt = '20211231'
    and opn_dt >='20210911' and opn_dt <= '20211231'
    group by cst_id
) e on a.pcc_cstno = e.cst_id
left join edw.dws_cst_bas_inf_dd f on a.pcc_cstno = f.cst_id and f.dt = '20211231'
left join
(
    select openid,addtime  --addtime 即为积分商城首次注册时间
    from edw.tlsc_sunyardmall_user  --用户表
    where dt = '20211231'
) g on a.pcc_cstno = g.openid
left join
(
    select idno,max(sysdt) as min_sysdt  --每个身份证号取最早的时间即为客户手机号绑定时间
    from edw.wyhl_ibps_acct_telauth_reg  --手机号码认证注册变更表
    where dt = '20211231'
    and sysdt >= '20210911' and sysdt <= '20211231'
    group by idno
) h on f.doc_nbr = h.idno --手机号码认证注册变更表中没有客户号，使用身份证号进行关联
where a.pcc_channel = '2'
and a.dt = '20211231'
and a.pcc_createtime >= '20210911' and a.pcc_createtime <= '20211231'
;




select *
from lab_bigdata_dev.sjyhjs_xt_20211008
;
**数据需求_20211012_台州分行科技部查账号流水.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-12 17:13:11
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************


select dtl_seq_nbr as 明细序号
      ,dep_act_id as 存款账号
      ,cst_act_id as 客户账号
      ,trx_tm as 交易时间
      ,trx_bus_org as 交易营业机构
      ,opr_tlr as 操作柜员
      ,chk_tlr as 复核柜员
      ,aut_tlr as 授权柜员
from edw.dwd_bus_dep_bal_chg_dtl_di  --存款账户余额发生明细
where dt >= '20201101' and dt <= '20201130'
and cnt_pty_cst_act_id = '623039999101079118'
;


SELECT * FROM edw.dim_bus_dep_act_inf_dd WHERE cst_id='1025137968' AND DT='20211011';


SELECT * FROM edw.dim_cst_bas_inf_dd WHERE prm_doc_nbr='331002198405044359' AND DT='20211011';


select * from edw.dwd_bus_dep_opn_dstr_act_reg_dd where pmt_act_id = '623039991010791198' and dt = '20211011';
**数据需求_20211018_英德村行随贷通资金流向.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-18 10:22:43
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--广东英德村行现有余额在用的随贷通卡资金流向查询
--20190101-20211014
--交易对手、交易资金、交易时间

--英德村行的机构号
SELECT org_id,org_nm
from edw.dim_hr_org_mng_org_tree_dd
where dt = '20211017' and org_nm like '%英德%'
;

-----------------------------------------------------
drop table if exists xt_suidaitong_20211018;
create table if not exists xt_suidaitong_20211018
as
select aa.zhanghao as 负债账号
      ,aa.zhhuzwmc as 账户名称
      ,aa.kehuzhao as 客户账号
      ,aa.jiedaibz as 借贷标志
      ,aa.jiaoyije as 交易金额
      ,aa.jiaoyirq as 交易日期
      ,aa.zhanghye as 账户余额
      ,aa.duifkhzh as 对方客户账号
      ,aa.duifminc as 对方户名
      ,aa.kaihjigo as 开户机构
      --,bb.kaxingzh as 卡种性质
from edw.core_kdpl_zhminx aa  --账户余额发生明细
where aa.dt >= '20190101' and aa.dt <= '20211014'
and aa.kehuzhao in
(
      select kahaoooo
      from edw.core_kcda_pzjcxx
      where dt >= '20190101' and dt <= '20211014'
      and kaxingzh = '5'
)
and aa.kaihjigo like '4461%'  --筛选出机构为英德村行
and aa.zhanghye <> 0
and aa.jiedaibz = 'D' --D表示使用
;

select 负债账号,账户名称,客户账号,交易金额,交易日期,账户余额,对方户名 from xt_suidaitong_20211018
;



select dt,count(*)
from edw.core_kcda_pzjcxx
where dt >= '20210101' and dt <= '20211014'
group by dt
**数据需求_20211019_衢州分行非格式合同检查.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-19 18:09:00
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

select a.requestid,
       z.requestname     流程标题,
       a2.lastname       经办人,
       a.workcode        经办人工号,
       a5.subcompanyname 经办人分部,
       a3.departmentname 经办人部门,
       a.applydate       申请日期,
       k4.selectname     印章分类,
       a4.mingcheng      使用印章,
       a1.usenumber      使用个数,
       k5.selectname     是否为法律性文件,
       a.fowardperson    送达对象,
       a.shortcontent    内容简述,
       a.contractname    合同名称,
       a.contractmoney   合同金额,
       a.contractlessor  合同相对方,
       re.nodename       当前节点
  from ecology.formtable_main_496 a
  left join ecology.formtable_main_496_dt1 a1
    on a1.mainid = a.id ---关联明细表
  left join ecology.hrmresource a2
    on a2.id = a.username ---关联人员信息
  left join ecology.hrmdepartment a3                          -- 可以
    on a3.id = a.dept ---关联部门信息
  left join ecology.workflow_selectitem k4                    --可以
    on k4.selectvalue = a.stamptype
   and k4.fieldid = '138265' ---关联选择框数据
  left join ecology.workflow_selectitem k5                     --可以
    on k5.selectvalue = a.isaboutlaw
   and k5.fieldid = '138282' --关联选择框数据是否法律文件138282
  left join ecology.uf_carved a4                               --可以
    on a4.id = a1.usestamp2 ---关联印章库
  left join ecology.hrmsubcompany a5                           --没有
    on a5.id = a2.subcompanyid1 ---关联分行信息
  left join (select v.requestid, v1.nodename
               from ecology.workflow_requestbase v --通过requestbase中的nodeid 关联nodebase的当前节点名称
               left join ecology.workflow_nodebase v1
                 on v1.id = v.currentnodeid) re
    on re.requestid = a.requestid
  left join ecology.workflow_requestbase z
    on z.requestid = a.requestid
 where a.applydate >= '2021-01-01'
   and a.applydate <= '2021-06-30'
   and a5.id = '43'



--衢州分行全辖20210101-20210930法律性文件的用印记录
--是否为法律性文件、经办人、经办人工号、分部、经办人部门、申请日期、印章分类、送达对象
--内容简述、使用个数、使用印章2、当前节点

--主表未入仓，转给开发部
**数据需求_20211021_台州分行_兴业柜面通流水.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-21 15:52:36
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

--某特定账号的经办机构、经办柜员、流水号
DROP TABLE IF EXISTS lab_bigdata_dev.xt_tmp_xingyetong_20211021;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.xt_tmp_xingyetong_20211021
AS
SELECT a.prm_act_id AS 主帐号
      ,a.trx_cd AS 交易代码
      ,a.trx_amt AS 交易金额
      ,CASE
        WHEN trx_entr_act_ind = '0' THEN '预计'
        WHEN trx_entr_act_ind = '1' THEN '成功'
        WHEN trx_entr_act_ind = '2' THEN '失败'
        WHEN trx_entr_act_ind = '3' THEN '确认'
        ELSE ''
       END AS 交易入账标志
      ,a.mid_bus_srl_nbr AS 中间业务流水号
      ,a.hst_srl_nbr AS 主机流水号
      ,a.dt AS 日期
      ,a.trx_trsm_tm AS 交易传输时间
      ,a.brh_id AS 网点号
      ,a.opr_id AS 操作员工号
      ,b.empe_nm AS 操作员姓名
      ,a.act_id_1 AS 入账账号
      ,a.act_id_1_nm AS 入账账号户名
      ,a.act_id_2 AS 出账账号
      ,a.act_id_2_nm AS 出账账号户名
      ,thd_pty_srl_nbr AS 第三方流水号
      ,a.srl_nbr AS 流水号
FROM edw.dwd_bus_chnl_fr_cib_trx_srl_di a
LEFT JOIN edw.dws_hr_empe_inf_dd b on a.opr_id = b.empe_id AND b.dt = '20211020'
WHERE a.dt = '20140129'
AND a.prm_act_id = '6210880100002391920'
;

SELECT * FROM lab_bigdata_dev.xt_tmp_xingyetong_20211021;
**数据需求_20211025_存量客户留存手机号一致的客户.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-25 13:59:26
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--需求机构：衢州分行
--用于客户数据准确性排查，对误录错录数据进行整改
--需求字段：客户号 客户名称 客户电话号码  管护支行 管护人
--数据日期：20100121-20211021
DROP TABLE IF EXISTS lab_bigdata_dev.xt_tmp_quzhou_20211025;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.xt_tmp_quzhou_20211025
AS
SELECT a.cst_id AS 客户号
      ,a.cst_chn_nm AS 客户姓名
      ,a.mbl_nbr AS 手机号码
      ,a.prm_org_id AS 主管户机构
      ,d.sbr_org_nm 主管户支行层级名称
      ,a.prm_org_nm AS 主管户机构名称
      ,b.prm_mgr_id AS 主管客户经理工号
      ,c.empe_nm AS 主管户客户经理姓名
FROM edw.dws_cst_bas_inf_dd a
LEFT JOIN edw.dws_cst_mng_prm_inf_dd b ON a.cst_id = b.cst_id AND b.dt = '20211024'
LEFT JOIN edw.dws_hr_empe_inf_dd c ON b.prm_mgr_id = c.empe_id AND c.dt = '20211024'
LEFT JOIN edw.dim_hr_org_mng_org_tree_dd d ON a.prm_org_id = d.org_id AND d.dt = '20211024'
WHERE a.dt = '20211024'
AND d.org_nm LIKE '%衢州%'
;
**数据需求_20211025_我行存量客户绑定第三方快捷支付.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-25 08:45:31
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

--我行存量客户

SELECT cst_id AS 客户号
      ,opn_chnl_cd AS 开通渠道
      ,chnl_sts AS 渠道状态
      ,chnl_opn_tm AS 渠道开通时间
      ,chnl_mdf_tm AS 渠道修改时间
      ,chnl_actv_tm AS 渠道激活时间
FROM edw.dim_bus_chnl_elec_idv_inf_dd  --电子银行个人客户渠道信息表
WHERE dt = '20211001'
GROUP BY cst_id,opn_chnl_cd,chnl_sts,chnl_opn_tm,chnl_mdf_tm,chnl_actv_tm
ORDER BY RAND() LIMIT 20
;


SELECT *
FROM edw.epcc_epcc_payagrmt a
WHERE a.dt = '20211024'
;



--取当月新办卡客户名单（以前从未在我行开过卡）2021.06、2021.07、2021.08、2021.09
**数据需求_20211027_台州分行客户永源集团有限公司交易流水.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-27 15:18:05
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

-- 查询客户永源集团有限公司，
-- 账号：9010202012021989，于20030201-20030228办理的转给台州市永源房地产开发有限公司2500万的交易记录，
-- 查询交易时间（可能发生在20030213）、交易机构、交易流水号、交易柜员号。

-- 一代 只能查到记账柜员和记账日期，其他信息没有
SELECT pan AS 帐号
      ,acdate AS 记帐日期
      ,amount AS 发生额
      ,rmkmsg AS 摘要信息
      ,voucherno AS 凭证号码
      ,destsub AS 对方科目
      ,acopr AS 记帐柜员
      ,chkopr AS 复核柜员
FROM edw.accfulllist
WHERE pan = '9010202012021989'
AND amount = 25000000.0
;

-- 一代和二代映射   6320201201090000257
SELECT *
FROM edw.yypfb0
WHERE yyb0old = '9010202012021989'
;
**数据需求_20211027_合规部犯罪客户信息.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-27 16:51:32
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
DROP TABLE IF EXISTS xt_024618_hegui_20211027;
CREATE TABLE IF NOT EXISTS xt_024618_hegui_20211027 AS
SELECT a.cort_rpt_id AS 法院报告编号A
      ,b.fqz_reportid AS 法院报告编号B
      ,a.cst_id AS 客户号
      ,a.cst_nm AS 客户姓名
      ,b.fqz_casetopic AS 违法事由
      ,b.fqz_hostsendtime AS 交易发送主机时间
      ,b.fqz_sslong AS 处理时间
FROM edw.dwd_cst_out_cort_qry_srl_inf_dd a
INNER JOIN edw.outd_fy_query_zuifan b ON a.cort_rpt_id = fqz_reportid AND b.dt = a.dt
WHERE a.dt = '20211026'
;

select 客户号,客户姓名,违法事由 from lab_bigdata_dev.xt_024618_hegui_20211027;
**数据需求_20211028_合规部年度存量非居民涉税信息排查.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-28 10:16:04
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
提取存量新增个人高净值客户的客户账户、存量新增机构大额客户账户、存量新增机构高净值的客户账户清单
对应需求文档：存量客户涉税非居民排查方案数据提取需求20211027.docx
*/

--        1. 2020年增量对私100万美元以上清单   对私
DROP TABLE IF EXISTS xt_024618_tmp_hegui_hsy_1_20211028;
CREATE TABLE IF NOT EXISTS xt_024618_tmp_hegui_hsy_1_20211028 AS
SELECT
	   A.CST_ID 客户号
     , A.cst_chn_nm 客户名
     , A.doc_typ_cd 证件类型
	 , F.ACT_STS_CD	 存款账户状态代码
     , A.doc_nbr 证件号
     , E.GDR_CD 性别
     , E.OCP_CD 职业
     , E.NTN_CD 国籍
     , A.fml_adr  家庭住址
	 , A.reg_adr 注册地址
     , B.DEP_BAL 账户余额
     , C.FNC_BAL 理财余额
     , wrk_adr 工作地址
     , E.JOB_UNT_NM   	工作单位名称
     , COALESCE(mbl_nbr,fml_tel_nbr,cmp_tel_nbr) 联系方式
     , F.CST_ACT_ID 客户账号
     , F.DEP_ACT_ID 负债账号
     , F.CCY_CD 币种
     , F.OPN_DT 开户日期
	 , F.BAL_LATE_UPD_DT 上次动户日期
	 , F.ACT_CTG_CD_2	 账户类型
     , F.BAL_ITM_ID 科目编号
     , G.opn_agn_doc_nbr  	开户代理证件号码
     , G.opn_agn_ctc_tel  	开户代理人电话
     , G.opn_agn_nm   	开户代理人名称
     , H.ACS_ORG_ID	 管护机构
     , SUBSTR(H.ACS_ORG_ID,1,7) 支行
     , SUBSTR(H.ACS_ORG_ID,1,4) 分行
     , H.MGR_ID	  考核客户经理
     , I.empe_nm	  客户经理
     , CASE WHEN J.CST_ID IS NULL THEN '否' ELSE '是' END
	 , F.OPN_ORG	 开户机构编号
	 , Y.ORG_NM  开户机构
FROM
    EDW.DWS_CST_BAS_INF_DD A
LEFT JOIN (SELECT CST_ID,SUM(GL_BAL) DEP_BAL  FROM EDW.DIM_BUS_DEP_ACT_INF_DD WHERE  DT='20201231' GROUP BY CST_ID) B ON A.CST_ID=B.CST_ID       -- 总账余额
LEFT JOIN (SELECT CST_ID,SUM(cur_lot) FNC_BAL FROM EDW.dws_bus_chm_act_acm_inf_dd WHERE  DT='20201231' GROUP BY CST_ID) C ON A.CST_ID=C.CST_ID   -- 当前份额
LEFT JOIN EDW.DIM_CST_IDV_BAS_INF_DD E ON A.CST_ID=E.CST_ID AND E.DT='20211027'
LEFT JOIN EDW.DIM_BUS_DEP_ACT_INF_DD F ON A.CST_ID=F.CST_ID AND F.DT='20211027'
LEFT JOIN EDW.DIM_HR_ORG_BAS_INF_DD Y ON F.OPN_ORG=Y.ORG_ID AND Y.DT='20211027'
LEFT JOIN EDW.DWD_BUS_DEP_ADT_INF_DD G ON F.DEP_ACT_ID=G.DEP_ACT_ID AND G.DT='20211027'
LEFT JOIN EDW.DWD_BUS_DEP_CST_ACT_MGR_INF_DD H ON F.CST_ACT_ID=H.CST_ACT_ID AND H.FRS_CTC_IND='1' AND H.DT='20211027'                            -- 第一联系人标志=1
LEFT JOIN EDW.DIM_HR_EMPE_BAS_INF_DD I ON I.empe_id=H.MGR_ID AND I.DT='20211027'
LEFT JOIN (SELECT DISTINCT CST_ID FROM edw.dws_bus_crd_cr_crd_act_inf_dd WHERE DT='20211027') J ON J.CST_ID=A.CST_ID
WHERE a.cst_typ_cd ='1'  AND NVL(B.DEP_BAL,0)+NVL(C.FNC_BAL,0)>=1000000*6.4 AND A.DT='20211027'                                                       -- 剔除客户余额<=100美元的客户




--       2020年增量（剔除2017年之前的25万以上清单）对公25万美元以上的清单   对公
DROP TABLE IF EXISTS xt_024618_tmp_hegui_hsy_2_20211028;
CREATE TABLE IF NOT EXISTS xt_024618_tmp_hegui_hsy_2_20211028 AS
SELECT
    A.CST_ID 客户号
     , A.cst_chn_nm 客户名
     , A.doc_typ_cd 证件类型
	 , F.ACT_STS_CD	 存款账户状态代码
     , A.doc_nbr 证件号
     , A.wrk_adr   公司地址
	 , A.reg_adr 注册地址
     , B.DEP_BAL 账户余额
     , C.FNC_BAL 理财余额
----     , A.wrk_adr 工作地址
     , COALESCE(mbl_nbr,fml_tel_nbr,cmp_tel_nbr) 联系方式
     , F.CST_ACT_ID 客户账号
     , F.DEP_ACT_ID 负债账号
     , F.CCY_CD 币种
     , F.OPN_DT 开户日期
	 , F.BAL_LATE_UPD_DT 上次动户日期
	 , F.ACT_CTG_CD_1	 账户类型
     , F.BAL_ITM_ID 科目编号
     , G.opn_agn_doc_nbr  	开户代理证件号码
     , G.opn_agn_ctc_tel  	开户代理人电话
     , G.opn_agn_nm   	开户代理人名称
     , H.ACS_ORG_ID 管护机构
     , SUBSTR(H.ACS_ORG_ID,1,7) 支行
     , SUBSTR(H.ACS_ORG_ID,1,4) 分行
     , H.MGR_ID  考核客户经理
     , I.empe_nm  客户经理
	 , F.OPN_ORG	 开户机构编号
	 , Y.ORG_NM  开户机构
	 ----, E.OPT_SCP 经营范围
FROM
    EDW.DWS_CST_BAS_INF_DD A
LEFT JOIN (SELECT CST_ID,SUM(GL_BAL) DEP_BAL  FROM EDW.DIM_BUS_DEP_ACT_INF_DD WHERE  DT='20201231' GROUP BY CST_ID) B ON A.CST_ID=B.CST_ID
LEFT JOIN (SELECT CST_ID,SUM(cur_lot) FNC_BAL FROM EDW.dws_bus_chm_act_acm_inf_dd WHERE  DT='20201231' GROUP BY CST_ID) C ON A.CST_ID=C.CST_ID
----LEFT JOIN EDW.dim_cst_entp_bas_inf_dd E ON A.CST_ID=E.CST_ID AND E.DT='20201011'
LEFT JOIN EDW.DIM_BUS_DEP_ACT_INF_DD F ON A.CST_ID=F.CST_ID AND F.DT='20211027'
LEFT JOIN EDW.DIM_HR_ORG_BAS_INF_DD Y ON F.OPN_ORG=Y.ORG_ID AND Y.DT='20211027'
LEFT JOIN EDW.DWD_BUS_DEP_ADT_INF_DD G ON F.DEP_ACT_ID=G.DEP_ACT_ID AND G.DT='20211027'
LEFT JOIN EDW.DWD_BUS_DEP_CST_ACT_MGR_INF_DD H ON F.CST_ACT_ID=H.CST_ACT_ID AND H.FRS_CTC_IND='1' AND H.DT='20211027'
LEFT JOIN EDW.DIM_HR_EMPE_BAS_INF_DD I ON I.empe_id=H.MGR_ID AND I.DT='20211027'
LEFT JOIN (SELECT DISTINCT CST_ID FROM edw.dws_bus_crd_cr_crd_act_inf_dd WHERE DT='20211027') J ON J.CST_ID=A.CST_ID
WHERE a.cst_typ_cd ='2' AND NVL(B.DEP_BAL,0)+NVL(C.FNC_BAL,0)>=250000*6.40
AND A.DT='20211027'




--       3. 2020年增量对公100万美元以上清单  对公
DROP TABLE IF EXISTS xt_024618_tmp_hegui_hsy_3_20211028;
CREATE TABLE IF NOT EXISTS xt_024618_tmp_hegui_hsy_3_20211028 AS
SELECT
    A.CST_ID 客户号
     , A.cst_chn_nm 客户名
     , A.doc_typ_cd 证件类型
	 , F.ACT_STS_CD	 存款账户状态代码
     , A.doc_nbr 证件号
     , A.wrk_adr   公司地址
	 , A.reg_adr 注册地址
     , B.DEP_BAL 账户余额
     , C.FNC_BAL 理财余额
----     , A.wrk_adr 工作地址
     , COALESCE(mbl_nbr,fml_tel_nbr,cmp_tel_nbr) 联系方式
     , F.CST_ACT_ID 客户账号
     , F.DEP_ACT_ID 负债账号
     , F.CCY_CD 币种
     , F.OPN_DT 开户日期
	 , F.BAL_LATE_UPD_DT 上次动户日期
	 , F.ACT_CTG_CD_1	 账户类型
     , F.BAL_ITM_ID 科目编号
     , G.opn_agn_doc_nbr  	开户代理证件号码
     , G.opn_agn_ctc_tel  	开户代理人电话
     , G.opn_agn_nm   	开户代理人名称
     , H.ACS_ORG_ID 管护机构
     , SUBSTR(H.ACS_ORG_ID,1,7) 支行
     , SUBSTR(H.ACS_ORG_ID,1,4) 分行
     , H.MGR_ID  考核客户经理
     , I.empe_nm  客户经理
	 , F.OPN_ORG	 开户机构编号
	 , Y.ORG_NM  开户机构
	 --, E.OPT_SCP 经营范围
FROM
    EDW.DWS_CST_BAS_INF_DD A
LEFT JOIN (SELECT CST_ID,SUM(GL_BAL) DEP_BAL  FROM EDW.DIM_BUS_DEP_ACT_INF_DD WHERE  DT='20201231' GROUP BY CST_ID) B ON A.CST_ID=B.CST_ID
LEFT JOIN (SELECT CST_ID,SUM(cur_lot) FNC_BAL FROM EDW.dws_bus_chm_act_acm_inf_dd WHERE  DT='20201231' GROUP BY CST_ID) C ON A.CST_ID=C.CST_ID
----LEFT JOIN EDW.dim_cst_entp_bas_inf_dd E ON A.CST_ID=E.CST_ID AND E.DT='20201011'
LEFT JOIN EDW.DIM_BUS_DEP_ACT_INF_DD F ON A.CST_ID=F.CST_ID AND F.DT='20211027'
LEFT JOIN EDW.DIM_HR_ORG_BAS_INF_DD Y ON F.OPN_ORG=Y.ORG_ID AND Y.DT='20211027'
LEFT JOIN EDW.DWD_BUS_DEP_ADT_INF_DD G ON F.DEP_ACT_ID=G.DEP_ACT_ID AND G.DT='20211027'
LEFT JOIN EDW.DWD_BUS_DEP_CST_ACT_MGR_INF_DD H ON F.CST_ACT_ID=H.CST_ACT_ID AND H.FRS_CTC_IND='1' AND H.DT='20211027'
LEFT JOIN EDW.DIM_HR_EMPE_BAS_INF_DD I ON I.empe_id=H.MGR_ID AND I.DT='20211027'
LEFT JOIN (SELECT DISTINCT CST_ID FROM edw.dws_bus_crd_cr_crd_act_inf_dd WHERE DT='20211027') J ON J.CST_ID=A.CST_ID
WHERE a.cst_typ_cd ='2' AND NVL(B.DEP_BAL,0)+NVL(C.FNC_BAL,0)>=1000000*6.40
AND A.DT='20211027'


SELECT 客户号,客户名,证件类型,存款账户状态代码,证件号,公司地址,注册地址,账户余额,理财余额,联系方式,客户账号,负债账号,币种,开户日期,上次动户日期
,账户类型,科目编号,开户代理证件号码,开户代理人电话,开户代理人名称
,管护机构,支行,分行,考核客户经理,客户经理,开户机构编号,开户机构 FROM lab_bigdata_dev.xt_024618_tmp_hegui_hsy_3_20211028;
**数据需求_20211029_计财部泰惠收账户明细.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-29 09:21:49
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
drop table if exists xt_024618_tmp_jicai_20211029;
create table if not exists xt_024618_tmp_jicai_20211029 as
SELECT farendma AS 法人代码
      ,jiaoyirq AS 交易日期
      ,guiylius AS 交易流水
      ,ruzhtaoh AS 套号
      ,cpzunexh AS 记账凭证序号
      ,yuefangx AS 余额方向
      ,xitongbs AS 系统标识号
      ,hesuanjg AS 核算机构
      ,huobdaih AS 货币代号
      ,jiedaibz AS 借贷标志
      ,kemuhaoo AS 科目号
      ,hesuanfl AS 核算分类
      ,qdaoleix AS 交易渠道
      ,jiaoyigy AS 交易柜员号
      ,jiaoyijg AS 交易机构号
      ,shouqngy AS 授权柜员号
      ,jiaoyima AS 交易码
      ,zhyngyjg AS 账户营业机构号
      ,zhhubumn AS 账户部门号
      ,mokuaiii AS 模块
      ,chanpmch AS 产品名称
      ,chanphao AS 产品代码
      ,gschpndm AS 归属产品代码
      ,yewusx01 AS 业务属性1
      ,yewusx02 AS 业务属性2
      ,yewusx03 AS 业务属性3
      ,yewusx04 AS 业务属性4
      ,yewusx05 AS 业务属性5
      ,yewusx06 AS 业务属性6
      ,yewusx07 AS 业务属性7
      ,yewusx08 AS 业务属性8
      ,yewusx09 AS 业务属性9
      ,yewusx10 AS 业务属性10
      ,yewubima AS 业务编码
      ,yeshuxin AS 余额属性
      ,ywshijfs AS 业务事件方式
      ,zhanghxh AS 账号序号
      ,kehuhaoo AS 客户号
      ,kehumnch AS 客户名称
      ,kehuzhao AS 客户账号
      ,zhanghao AS 账号
      ,zhanghmc AS 账户名称
      ,jizhngzh AS 记账账号
      ,jizhngje AS 记账金额
      ,zhesfshi AS 折算方式
      ,zhebjine AS 折本金额
      ,zhemjine AS 折美金额
      ,bnbwbioz AS 表内表外标志
      ,zhaiyodm AS 摘要代码
      ,zhaiyoms AS 摘要描述
      ,zhjiriqi AS 主机日期
      ,jiaoyisj AS 交易时间
      ,waiblius AS 外部流水
      ,xianzhbz AS 现转标志
      ,xinjxmdm AS 现金项目代码
      ,zhssxtbs AS 账户所属系统
      ,zhwuclbz AS 账务处理标志
      ,yuancwrq AS 原错账日期
      ,yuanczls AS 原错账流水
      ,chaohubz AS 钞汇标志
      ,ruzngzbz AS 入总账标志
      ,kaixhubz AS 开销户标志
      ,beizhuxx AS 备注信息
      ,shujgxbz AS 数据更新标志
      ,byzfzd01 AS 备用字段01
      ,byzfzd02 AS 备用字段02
      ,byzfzd03 AS 备用字段03
      ,byzfzd04 AS 备用字段04
      ,byzfzd05 as 备用字段05
      ,byzfzd06
      ,byzfzd07
      ,byzfzd08
      ,byzfzd09
      ,byzfzd10
      ,jiyizdbh as 交易终端编号
      ,zpinzhzl AS 主凭证种类
      ,zpzhhaom AS 主凭证号码
      ,dfyewubm AS 对方业务编码
      ,dfjrjglx AS 对方金融机构类型
      ,dfkemuha AS 对方科目号
      ,dfkehulx AS 对方客户类型
      ,hstujing AS 核算途径
      ,dfzhangh AS 对方账号
      ,dfzhnghm AS 对方账户名称
      ,duifhngh AS 对方行号
      ,duifjgmc AS 对方机构名称
      ,chbmbzhi AS 冲补抹标志
      ,jiejuhao AS 借据号
      ,hetongbh AS 合同编号
      ,yingshfy AS 应收费用
      ,ywckhaoo AS 业务参考号
      ,lilvvvvv AS 利率
      ,lrzhongx AS 利润中心
      ,kehujinl AS 客户经理
      ,quytiaox AS 区域条线
      ,waibchlm AS 外部处理码
      ,fenhbios AS 分行标识
      ,weihguiy AS 维护柜员
      ,weihjigo AS 维护机构
      ,weihriqi AS 维护日期
      ,weihshij AS 维护时间
      ,shijchuo AS 时间戳
      ,jiluztai AS 记录状态
FROM edw.core_kfab_lszzcp
WHERE dt='20211027'
;


select * from lab_bigdata_dev.xt_024618_tmp_jicai_20211029;



select *
from edw.core_kfab_lszzcp
where dt = '20211027'
and zhanghao = '356400015626421060100002'
;
**数据需求_20211029_调查资质年审客户经理经办清单.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-29 11:21:25
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
与业务核对以后，分为以下几种产品类型，口径如下：
1.剔除
2.贷款：合同金额
3.票据：合同金额-保证金
4.贴现：贴现发生额
5.国际业务非保证金类：合同金额
6.国际业务保证金类：合同金额-保证金
7.随贷通：授信金额
*/
-- 1.将产品代码与产品类别的映射关系建表
create table lab_bigdata_dev.xt_024618_prodect_20211110
(
    产品编号  STRING COMMENT '产品编号',
    产品名称  STRING COMMENT '产品名称',
    类别      STRING COMMENT '类别'
)
;
select *
from lab_bigdata_dev.xt_024618_prodect_20211110
order by rand() limit 10;


-- 2.建立第一个中间表
drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029;
CREATE TABLE if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029 AS
select a.apnt_start_dt dt
      ,a.busi_ctr_id  --业务合同编号
      ,a.cst_id --客户编号
      ,case
         when d.类别 = '剔除' then 0    --不计算在内
         when (d.类别 = '贷款' or d.类别 = '国际业务非保证金类' or d.类别 = '随贷通' or d.类别 = '贴现') and a.ccy_cd <> '156'  then a.ctr_amt*t7.avg_prc   --取合同金额
         when (d.类别 = '贷款' or d.类别 = '国际业务非保证金类' or d.类别 = '随贷通' or d.类别 = '贴现') and a.ccy_cd = '156'  then a.ctr_amt
         when (d.类别 = '票据' or d.类别 = '国际业务保证金类') and a.ccy_cd <> '156' then (a.ctr_amt - e.bailsum) * t7.avg_prc
         when d.类别 = '票据' or d.类别 = '国际业务保证金类' then a.ctr_amt - e.bailsum
      end as amt  --金额
      ,c.inputuserid opr_id --经办人编号
      ,a.apnt_start_dt dtrb_dt  --发放日期
      ,case when a.crc_ind = '1' then a.apnt_start_dt else nvl(replace(c.principalsettledate,'/',''),b.exe_mtu_day) end  exe_mtu_day  --执行到期日
from edw.dim_bus_loan_dbil_inf_dd b  --信贷借据信息
left join edw.dim_bus_loan_ctr_inf_dd a on a.busi_ctr_id = b.bus_ctr_id and a.dt = '20211028'   --信贷合同信息
left join edw.loan_business_contract c on a.busi_ctr_id = c.serialno and c.dt = '20211028'
left join edw.dim_bus_com_exr_inf_dd t7 on a.ccy_cd = t7.ccy_cd and t7.dt = '20211028'
left join lab_bigdata_dev.xt_024618_prodect_20211110 d on a.pd_cd = d.产品编号   --产品类别表
left join edw.loan_business_contract e on e.artificialno = a.busi_ctr_id and e.dt = b.dt  --业务合同表 取保证金金额
where b.dt = '20211028'
AND a.pd_cd not like '1010%' and a.pd_cd not like '2010502%' -- and a.pd_cd not like '2010503%'  --是否剔除随贷通卡
and a.pd_cd not in ('201050101040319','201050101040332','201050101040354')
AND     case when a.crc_ind = '1' then a.apnt_start_dt else b.dtrb_dt end >= '20201028' --循环贷款标志=1 then 约定开始日期 else 发放日期   > 20201028
AND     case when a.crc_ind = '1' then a.apnt_start_dt else b.dtrb_dt end <= '20211028' --循环贷款标志、约定开始日期、发放日期
AND     case when a.pd_cd like '2010503%' then a.apnt_start_dt else b.dtrb_dt end >= '20201028' --发放日期
AND     case when a.pd_cd like '2010503%' then a.apnt_start_dt else b.dtrb_dt end <= '20211028' --发放日期
;


-- 3.
drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_2_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_2_20211029 as
SELECT  a.dt AS data_date
       ,a.cst_id --客户编号
       ,a.opr_id
       ,sum(amt) ctr_amt --发放金额
FROM    lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029 a
WHERE   a.dtrb_dt <= a.dt
AND     a.exe_mtu_day >= a.dt
-- and a.opr_id = '000355'
--and a.cst_id = '1004158021'
GROUP BY a.dt,a.cst_id , a.opr_id
;
select * from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_2_20211029;

-- 每个经办人的每个客户的发放额
drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_3_20211029;
CREATE TABLE if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_3_20211029 AS
SELECT  cst_id,opr_id
       ,max(ctr_amt) ctr_amt
FROM    lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_2_20211029
--where opr_id = '000355'
GROUP BY cst_id,opr_id
;

--4 明细
drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 as
select distinct b.opr_id 经办人编号
      ,c.empe_nm 经办人姓名
      ,a.ctr_amt 近1年累计经办单户金额
      ,a.cst_id 客户号
from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_3_20211029 a
left join lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029 b on a.cst_id = b.cst_id and a.opr_id = b.opr_id
left join edw.dim_hr_empe_bas_inf_dd c on b.opr_id = c.empe_id and c.dt = '20211028';
--where b.opr_id = '019826'


-- =========================== 结果表=========================
-- 80万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_3_80w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_3_80w_20211029 as
select  a.经办人编号
       ,a.经办人姓名
    -- ,a.ctr_amt 近1年累计经办单户金额
       ,count(客户号) as count
from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
where a.近1年累计经办单户金额 >= 800000
group by a.经办人编号
        ,a.经办人姓名
;

-- 150万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_4_150w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_4_150w_20211029 as
select  a.经办人编号
       ,a.经办人姓名
    -- ,a.ctr_amt 近1年累计经办单户金额
       ,count(客户号) as count
from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
where a.近1年累计经办单户金额 >= 1500000
group by a.经办人编号
        ,a.经办人姓名
;


-- 300万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_5_300w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_5_300w_20211029 as
select  a.经办人编号
       ,a.经办人姓名
    -- ,a.ctr_amt 近1年累计经办单户金额
       ,count(客户号) as count
from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
where a.近1年累计经办单户金额 >= 3000000
group by a.经办人编号
        ,a.经办人姓名
;


-- 500万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_6_500w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_6_500w_20211029 as
select  a.经办人编号
       ,a.经办人姓名
    -- ,a.ctr_amt 近1年累计经办单户金额
       ,count(客户号) as count
from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
where a.近1年累计经办单户金额 >= 5000000
group by a.经办人编号
        ,a.经办人姓名
;


-- 1000万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_7_1000w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_7_1000w_20211029 as
select  a.经办人编号
       ,a.经办人姓名
    -- ,a.ctr_amt 近1年累计经办单户金额
       ,count(客户号) as count
from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
where a.近1年累计经办单户金额 >= 10000000
group by a.经办人编号
      ,a.经办人姓名
;














-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------20211029版----------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
--1
drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029;
CREATE TABLE if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029 AS
  SELECT distinct a.apnt_start_dt dt,
                  a.busi_ctr_id  --业务合同编号
  ,a.cst_id --客户编号
  ,a.ctr_amt --合同金额
  ,c.inputuserid opr_id --经办人编号
  ,a.apnt_start_dt dtrb_dt  --发放日期
  ,case when a.crc_ind = '1' then a.apnt_start_dt else nvl(replace(c.principalsettledate,'/',''),b.exe_mtu_day) end  exe_mtu_day  --执行到期日
  FROM    edw.dim_bus_loan_dbil_inf_dd b    --信贷借据信息
    LEFT JOIN    edw.dim_bus_loan_ctr_inf_dd a --信贷合同信息
      ON      a.busi_ctr_id = b.bus_ctr_id
    AND     a.dt = '20211028'
    left join edw.loan_business_contract c  --业务合同表
      on a.busi_ctr_id = c.serialno
    and c.dt = '20211028'
    LEFT JOIN    edw.dim_bus_com_exr_inf_dd t7 --汇率表
      ON      a.ccy_cd = t7.ccy_cd
    AND     t7.dt = '20211028'
  WHERE   b.dt = '20211028'
  --AND     ( a.wthr_wfdk <> '1'
  --OR a.wthr_wfdk IS NULL )
  AND a.pd_cd not like '1010%' and a.pd_cd not like '2010502%' -- and a.pd_cd not like '2010503%'  --是否剔除随贷通卡
  and a.pd_cd not in ('201050101040319','201050101040332','201050101040354')
  AND     case when a.crc_ind = '1' then a.apnt_start_dt else b.dtrb_dt end >= '20201028' --循环贷款标志=1 then 约定开始日期 else 发放日期   > 20201028
  AND     case when a.crc_ind = '1' then a.apnt_start_dt else b.dtrb_dt end <= '20211028' --循环贷款标志、约定开始日期、发放日期
  AND     case when a.pd_cd like '2010503%' then a.apnt_start_dt else b.dtrb_dt end >= '20201028' --发放日期
  AND     case when a.pd_cd like '2010503%' then a.apnt_start_dt else b.dtrb_dt end <= '20211028' --发放日期
;

--2
drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_2_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_2_20211029 as
  SELECT  a.dt AS data_date
  ,a.cst_id --客户编号
  ,a.opr_id
  ,sum(ctr_amt) ctr_amt --发放金额
  FROM    lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029 a
  WHERE   a.dtrb_dt <= a.dt
  AND     a.exe_mtu_day >= a.dt
  -- and a.opr_id = '000355'
  --and a.cst_id = '1004158021'
  GROUP BY a.dt,a.cst_id , a.opr_id;



--3 每个经办人的每个客户的发放额

drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_3_20211029;

CREATE TABLE if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_3_20211029 AS
  SELECT  cst_id,opr_id
  ,max(ctr_amt) ctr_amt
  FROM    lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_2_20211029
  --where opr_id = '000355'
  GROUP BY cst_id,opr_id;


--4 明细
drop table if exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 as
  select distinct b.opr_id 经办人编号
  ,c.empe_nm 经办人姓名
  ,a.ctr_amt 近1年累计经办单户金额
  ,a.cst_id 客户号
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_3_20211029 a
    left join lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_1_20211029 b
      on a.cst_id = b.cst_id
    and a.opr_id = b.opr_id
    left join edw.dim_hr_empe_bas_inf_dd c
      on b.opr_id = c.empe_id
    and c.dt = '20211028';
--where b.opr_id = '019826'

-- ============================================================ 结果表=======================================================
--5 50万以上
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_1_50w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_1_50w_20211029 as

  select  a.经办人编号
  ,a.经办人姓名
  -- ,a.ctr_amt 近1年累计经办单户金额
  ,count(客户号) as count
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
  where a.近1年累计经办单户金额 >= 500000
  group by a.经办人编号
  ,a.经办人姓名;


--6  100万以上
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_2_100w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_2_100w_20211029 as

  select  a.经办人编号
  ,a.经办人姓名
  -- ,a.ctr_amt 近1年累计经办单户金额
  ,count(客户号) as count
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
  where a.近1年累计经办单户金额 >= 1000000
  group by a.经办人编号
  ,a.经办人姓名;

--7 80万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_3_80w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_3_80w_20211029 as

  select  a.经办人编号
  ,a.经办人姓名
  -- ,a.ctr_amt 近1年累计经办单户金额
  ,count(客户号) as count
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
  where a.近1年累计经办单户金额 >= 800000
  group by a.经办人编号
  ,a.经办人姓名;

--8 150万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_4_150w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_4_150w_20211029 as

  select  a.经办人编号
  ,a.经办人姓名
  -- ,a.ctr_amt 近1年累计经办单户金额
  ,count(客户号) as count
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
  where a.近1年累计经办单户金额 >= 1500000
  group by a.经办人编号
  ,a.经办人姓名;


--9 300万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_5_300w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_5_300w_20211029 as
  select  a.经办人编号
  ,a.经办人姓名
  -- ,a.ctr_amt 近1年累计经办单户金额
  ,count(客户号) as count
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
  where a.近1年累计经办单户金额 >= 3000000
  group by a.经办人编号
  ,a.经办人姓名;



--9 500万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_6_500w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_6_500w_20211029 as
  select  a.经办人编号
  ,a.经办人姓名
  -- ,a.ctr_amt 近1年累计经办单户金额
  ,count(客户号) as count
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
  where a.近1年累计经办单户金额 >= 5000000
  group by a.经办人编号
  ,a.经办人姓名;


--10 1000万
drop table if exists lab_bigdata_dev.xt_024618_zzdc_result_7_1000w_20211029;
create table if not exists lab_bigdata_dev.xt_024618_zzdc_result_7_1000w_20211029 as
  select  a.经办人编号
  ,a.经办人姓名
  -- ,a.ctr_amt 近1年累计经办单户金额
  ,count(客户号) as count
  from lab_bigdata_dev.xt_024618_zzdc_zhongjianbiao_4_20211029 a
  where a.近1年累计经办单户金额 >= 10000000
  group by a.经办人编号
  ,a.经办人姓名;
**数据需求_20211101_CRM项目组外部接入企业信息.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-01 10:57:55
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 小微金融地图中已落地社区的杭州大市范围企业清单及台州大市范围企业清单
-- 为进一步丰富社区画像，拟先以杭州及台州试点，从企业经营、人口、资产、纳税评级等维度对两个试点区的社区进行丰富。因此，需我行提供杭州、台州两地企业清单，与省金综平台企业信息匹配分析。
-- 需求字段：企业名称、统一社会信用代码、注册地址

drop table if exists lab_bigdata_dev.xt_024618_tmp_crmentinf_20211101;
create table if not exists lab_bigdata_dev.xt_024618_tmp_crmentinf_20211101 as
select distinct geb_entname as 企业名称
      ,geb_creditcode as 统一信用代码
      ,geb_dom as 住址
      ,geb_regorgcode as 注册地址行政编号
      ,geb_regorgcity as 所在城市
from edw.outd_gs_entinfo_basic
where dt <= '20211031'
and (geb_regorgcity like '%杭州市%' or geb_regorgcity like '%台州市%')
;


select * from lab_bigdata_dev.xt_024618_tmp_crmentinf_20211101 where 统一信用代码 = '913301835930863638';
select * from edw.outd_gs_entinfo_basic where dt <= '20211031' and geb_creditcode IN ('92331003MA28HWXN6Q','92331003MA2ANJ6F8Q','92331003MA2DYAWGXK','92331003MA2G9BMQ7C');

--  存在两条统一社会信用代码重复的数据，发送主机时间不一致
select *
from edw.outd_gs_entinfo_basic
where dt = '20211027'
and (geb_regorgcity like '%杭州市%' or geb_regorgcity like '%台州市%')
and geb_creditcode in
(
select a.geb_creditcode
from
(
select *,row_number()over(partition by geb_creditcode order by geb_entname) as rn
from edw.outd_gs_entinfo_basic
where dt = '20211027'
and (geb_regorgcity like '%杭州市%' or geb_regorgcity like '%台州市%')
) a
where a.rn = 2
)
;
**数据需求_20211102_福建政和村行涉诈人员名单匹配.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-02 16:43:32
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 20211127-20211102
-- 账号    户名    证件号    管护机构    管护客户经理
--
select 存款账号,账户名称,客户账号,主管户客户经理,主管户客户经理名称,主管户机构,主管户机构名称,证件号码
from lab_bigdata_dev.xt_024618_tmp_fujianzhenghe_20211103;


drop table if exists lab_bigdata_dev.xt_024618_tmp_fujianzhenghe_20211103;
create table if not exists lab_bigdata_dev.xt_024618_tmp_fujianzhenghe_20211103 as
select a.dep_act_id as 存款账号
      ,a.act_nm as 账户名称
      ,a.cst_act_id as 客户账号
      ,b.prm_mgr_id as 主管户客户经理
      ,b.prm_mgr_nm as 主管户客户经理名称
      ,b.prm_org_id as 主管户机构
      ,b.prm_org_nm as 主管户机构名称
      ,b.doc_nbr as 证件号码
from edw.dim_bus_dep_act_inf_dd a
left join edw.dws_cst_bas_inf_dd b on a.cst_id = b.cst_id and b.dt = a.dt
left join edw.dim_hr_org_mng_org_tree_dd c on b.prm_org_id = c.org_id and c.dt = b.dt
where a.dt = '20211101'
and c.org_nm like '%福建政和%'
and b.doc_nbr in
(
    '352123196311084010'
,'350725199702142019'
,'350723197711021719'
,'431024199505243626'
,'350722200303144216'
,'332525197001145514'
,'350783200109028513'
,'350702200112158433'
,'350783200206142510'
,'350784200306080018'
,'35078419860510151X'
,'352123197609225511'
,'350784198306061837'
,'350783199209221518'
,'350702200208171317'
,'350702200406181823'
,'362502199909245814'
,'440582200203085914'
,'352123197609225511'
,'350725199402084013'
,'350784198306061837'
,'352123197008075538'
,'35072419831024252X'
,'350781198508241618'
,'350723198301111310'
,'350783199003055032'
,'350784199809162810'
,'350725198104281014'
,'350783198909285075'
,'362202199402085317'
,'352129196503233031'
,'352101197212076513'
,'350781199410280429'
,'352122196506211036'
,'350783199408165010'
,'352102194903054447'
,'350783200206142510'
,'350782199302263513'
,'350725199505031520'
,'350702200505256819'
,'350783198001028511'
,'350722200303144216'
,'352101197607115513'
,'35078319930227151X'
,'350784200305130079'
,'35070219840301232X'
,'350784199603254218'
,'350784198703280013'
,'352122197007041030'
,'350783200202215022'
,'350702199402123719'
,'450924198906114742'
,'350784199904221014'
,'352121197604140049'
,'350784198911013737'
,'35072419970820101X'
,'350421196710265013'
,'352124197407091638'
,'350725198810050571'
,'350702199304086133'
,'350723199604150012'
,'350702199705196114'
,'350781199905133236'
,'35072419970820101X'
,'350725200009032052'
,'350784199706012414'
,'350782200308051517'
,'350784198102152817'
,'350722199502022910'
,'36233019961027827X'
,'533022197210190022'
,'350427196007084016'
,'350784199807132431'
,'350721199910041313'
,'350702199812073013'
,'350784199005151024'
,'350782200308051517'
,'350784200309291013'
,'352129197710120528'
,'35078419980302461X'
,'350702200203218913'
,'350722198101254230'
,'35078119880516281X'
,'350781198910172040'
,'350781200306023217'
,'350702199812073013'
,'51160220030526377X'
,'350784200205312086'
,'350783199111224032'
,'350784199508123711'
,'352102197710121651'
,'352229197005115016'
,'350724199005163539'
,'533524199303033033'
,'350783198802225531'
,'350784199005151024'
,'350784197408101014'
,'350783199602117012'
,'350702199711307810'
,'350725200209294030'
,'350784199808064813'
,'350783199712088558'
,'350782200112053510'
,'352122197407102015'
,'350784200004212011'
,'350722198111261215'
,'352229199509136514'
,'350725197912101515'
,'35078319921002751X'
,'350784199608173716'
,'352122197105031039'
,'350784198006170521'
,'352122196506211036'
,'352123197005171532'
,'352123196510220521'
,'350782199809233532'
,'350725199011180526'
,'350784198611274636'
,'352124197107300434'
,'35078119880516281X'
,'350782199105053023'
,'350784199808064813'
,'350723199905010638'
,'350403198102230024'
,'33032619790927423X'
,'352123197607137518'
,'533524199310143011'
,'350783196703062512'
,'500243199410087250'
,'350722199606244219'
,'350781198804034816'
,'430682200003134439'
,'350725198502264033'
,'352123197203287544'
,'350781199802031632'
,'350722199004273928'
,'350781199802031632'
,'350723199101020611'
,'350784199709184211'
,'51160220030526377X'
,'350781199008026828'
,'350725200108033018'
,'350521199205037019'
,'350722199405034215'
,'352122197704023727'
,'350781198910164817'
,'350724199104083534'
,'352124197207121214'
,'350783198802280258'
,'352229199509136514'
,'350782198609153517'
,'352123197407045010'
,'350784199711063734'
,'350784200305130095'
,'352103196908282014'
,'350784199708024830'
,'350722200303310616'
,'350783199708251228'
,'350724198206263013'
,'350782200212102535'
,'352229199412226513'
,'350783196703062512'
,'350781199810235619'
,'352123197407045010'
,'350781199410280429'
,'350722198502092615'
,'350784199201202415'
,'352228199711060510'
,'350722200301114216'
,'350725199401131017'
,'350784199807132431'
,'350702198912274715'
,'35072219850627351X'
,'352123197602257019'
,'350781198808156810'
,'350783199110212515'
,'35058319990117741X'
,'350782198609153517'
,'350784199602073757'
,'35078220021027005X'
,'352102197502107222'
,'350783199610260716'
,'341225200203020217'
,'350721197708294510'
,'350702200607126118'
,'350783199806077526'
,'350783200206142510'
,'350702199101277810'
,'350783199811268036'
,'350722199401283513'
,'350783199407194514'
,'352123197311214537'
,'350702199301251316'
,'350725200112234031'
,'350781198508241618'
,'350783200210055022'
,'350722198804020641'
,'350784198909082813'
,'352127197206202521'
,'533521198912031531'
,'350182198402052214'
,'350702200208223017'
,'350784199909104220'
,'350784198903132816'
,'350722200109044617'
,'342529198610021228'
,'350784200604222096'
,'352127195706090619'
,'350403198102230024'
,'350781198711016416'
,'350702200205156517'
,'350783198901027012'
,'35212219620502101X'
,'350702199711080812'
,'35078419851219282X'
,'35078319900309551X'
,'350781199802031632'
,'35078319891027121X'
,'350783199012240213'
,'350783199207094017'
,'350784199706012414'
,'350784199801104819'
,'35078119880516281X'
,'352122197407251010'
,'350783199401310916'
,'350781200104145216'
,'350725199405233037'
,'350784199806252415'
,'350784199610201018'
,'350784199201202415'
,'350783199504098516'
,'350782198210060036'
,'350783198510128043'
,'350784199706012414'
,'35078419851219282X'
,'350783199708082532'
,'350722199907164212'
,'350725198503200015'
,'350783198308232533'
,'350702198812047451'
,'352123197203287544'
,'350702200411218619'
,'362324198706063917'
,'452322198006091545'
,'350725199105221018'
,'350781198802201692'
,'350781198802201692'
,'350784198910074212'
,'350781200104145216'
,'350784198606164213'
,'350784199812301017'
,'350724198509144011'
,'350783200302084517'
,'352123196109280501'
,'350783200005214012'
,'350783199309044037'
,'350783199409227519'
,'350783198902288038'
,'350724198610011010'
,'350722200004223539'
,'350725197912101515'
,'350783199309044037'
,'350725199105221018'
,'350783199012240213'
,'350784199002064216'
,'350784198312310078'
,'350783200210260712'
,'350724198610011010'
,'350784199907213319'
,'350722199605160611'
,'350426199110283010'
,'350725198702054532'
,'35210119741127781X'
,'533022197210190022'
,'350702199909291818'
,'350725200002171519'
,'350783198907144017'
,'350783199511245019'
,'350783199610260716'
,'350781199901072413'
,'350783200210260712'
,'350783200112298514'
,'350784200301200025'
,'350783199412184513'
,'350782199608181019'
,'350783199201197517'
,'350725198504032017'
,'352601197709137032'
,'350783200303111513'
,'350784197903174237'
,'350784198910074212'
,'350782199001224043'
,'35212319761017853X'
,'350784200212280115'
,'350784198910074212'
,'350702200501061352'
,'350725198810132518'
,'35072519910509205X'
,'350781199901072413'
,'35078120001217321X'
,'352229199506194516'
,'350783198509182536'
,'350783199304193519'
,'350783198509182536'
,'350723198911150624'
,'350702199901038914'
,'350783199407194514'
,'35078120001217321X'
,'350783199005137517'
,'350783198509182536'
,'350725197912101515'
,'352121197909221819'
,'352123197303305519'
,'350702199901038914'
,'350725199804231012'
,'35078419930811241X'
,'350725199804231012'
,'350781198208211636'
,'350781198910164817'
,'352225198109102550'
,'350725199112151038'
,'350784198211291816'
,'352123197303305519'
,'350783200210260712'
,'352122197509184840'
,'352122197509184840'
,'350783199202012545'
,'350721198401194536'
,'352229200202286513'
,'350722198509114215'
,'350725198503200015'
,'352104197606185017'
,'350725199209112035'
,'350781199003203215'
,'350725198504032017'
,'350722198808163922'
,'350783200201211222'
,'352129197802281513'
,'350783199209182512'
,'350784198904263316'
,'35212219671105376X'
,'352129197802281513'
,'350782199712014042'
,'350724199209121031'
,'352230199504031516'
,'350725198611201568'
,'450803199311056675'
,'350702200209173410'
,'350783200201177511'
,'35072119971203493X'
,'35212219570908102X'
,'350783199609173519'
,'350725199805312519'
,'350702200506296812'
,'350783199302283035'
,'350781198508241618'
,'350722198509114215'
,'350722198609154222'
,'352101197207146118'
,'350784198405064814'
,'350702200410156815'
,'350725198907213015'
,'350783198802108511'
,'35078320030911503X'
,'35212319701010705X'
,'350783199706308518'
,'350784199610052016'
,'350783198808108512'
,'350783198808108512'
,'350722200303093535'
,'350721197809284530'
,'510921200104205236'
,'350782198309074024'
,'350782199707082016'
,'350781200108064448'
,'352229198907205533'
,'320721199201173633'
,'350722199703073925'
,'35072519880807251X'
,'350722198005284237'
,'350725198811012059'
,'352101197811118615'
,'35078319900616703X'
,'350725199403104514'
,'350725198611201568'
,'510921200104205236'
,'350722198005284237'
,'350783198501064535'
,'350725198709143036'
,'350784198212070011'
,'350781198910164817'
,'350783198706263511'
,'352123197401237513'
,'350781198910164817'
,'350725199112151038'
,'350783200105131214'
,'352124197405022911'
,'35212719681227132X'
,'352124195903034254'
,'350783198509205021'
,'350702199611231812'
,'350784199201202415'
,'350783199202141216'
,'35078419960814371X'
,'350725199311101025'
,'350783198906057587'
,'350784199201064817'
,'350783198708035512'
,'350783198906057587'
,'332525199404190917'
,'350783200107294017'
,'350783197907130251'
,'362202199506207622'
,'350784198806082415'
,'350783200205305031'
,'350784198712121516'
,'35078319870217153X'
,'350721199205033625'
,'350721198504162924'
,'35052519860323051X'
,'332525197001145514'
,'352127196802290615'
,'350723197701132124'
,'350784198903072825'
,'352122197007041030'
,'522427199204156629'
,'350783199706308518'
,'352102197804101619'
,'35012519960901516X'
,'350722200403164214'
,'350121199901287239'
,'350784199209094818'
,'350783199910147512'
,'35078319900309551X'
,'350783199003055032'
,'352122196201173315'
,'350784198703241014'
,'350783198312160712'
,'350702200304138410'
,'352123197602262539'
,'350725198203150511'
,'350784197408101014'
,'350702198009106133'
,'533001200308205416'
,'350702200304056837'
,'350721199107103933'
,'350783199201165013'
,'352124196707010022'
,'522425200311280038'
,'350784199204242439'
,'350702200405071817'
,'350784199104191056'
,'352229199506194516'
,'350783199111277513'
,'350721199706020814'
,'350784198911074628'
,'350783200101180211'
,'350721199512021317'
,'350782199305255519'
,'35070220040214681X'
,'352124197105264214'
,'350783198201168017'
,'35212119650412491X'
,'352123197601260160'
,'350781198208211636'
,'35078219960827301X'
,'352102197710121651'
,'350182198402052214'
,'350722198211273918'
,'350782199302263513'
,'352123197107154012'
,'352101197405266110'
,'350723199106081317'
,'350783200205305031'
,'350722199809280519'
,'35072219940110321X'
,'350784198108113720'
,'350722199312133214'
,'350723198702080631'
,'350783197908012513'
,'350723199209301319'
,'35212119760930003X'
,'350783198501075525'
,'350721198109102112'
,'350725198911014510'
,'350781198911151639'
,'352228199205223524'
,'350702199602188218'
,'350723199601051326'
,'350723199303161711'
,'350702199006237116'
,'352102197109184459'
,'350724199009274017'
,'350702199503277127'
,'350783199905077038'
,'350781198608243629'
,'352122197602043727'
,'350783198705282518'
,'35212319701010705X'
,'350784199011162010'
,'352122196706063744'
,'350783199709258018'
,'35210119741127781X'
,'352123197407265515'
,'352227198901161311'
,'430221199907050019'
,'352122197601063718'
,'352102197107137210'
,'350783199411073010'
,'350725199105221018'
,'350702200205156517'
,'510904200203171573'
,'350702200110076119'
,'352124197210222657'
,'350781198308131617'
,'350721199308262615'
,'350781199911251618'
,'352122197705162833'
,'350783199907184515'
,'35078319900524251X'
,'350725199411230529'
,'35072519980624102X'
,'350783199110212515'
,'352124197407091638'
,'350725198809264513'
,'350781199706201224'
,'352123197005171532'
,'352123197401108025'
,'350784199610201018'
,'350722198103164220'
,'352123197005171532'
,'350783199610260716'
,'352123195902118011'
,'350784198201062032'
,'350784198411064634'
,'33252519970815291X'
,'350784199709184211'
,'35078419890108243X'
,'350783198312160712'
,'350702200003081334'
,'350783199309218017'
,'352229199412226513'
,'350784200004212011'
,'35012519960901516X'
,'350725199006154024'
,'352123197407045010'
,'350783199503294013'
,'350722199904101216'
,'35078119950720481X'
,'350702199103071314'
,'350723197711021719'
,'352102197710121651'
,'350725198203150511'
,'350784199611222419'
,'35212319681114151X'
,'320102198111033833'
,'350784199706012414'
,'350721198408044514'
,'350784198610274626'
,'352101196503153764'
,'350783199401310916'
,'350781199506016817'
,'352121196907051313'
,'352123196612054018'
,'350784199009074644'
,'352123196309015534'
,'350783200211038013'
,'350783199308187538'
,'350121199109091769'
,'352230197703172144'
,'350783198710114017'
,'350721199706020814'
,'350721200009062918'
,'350783199111224032'
,'350724198909231018'
,'350125200012313311'
,'350721199107103933'
,'350783197907130251'
,'350722200303144216'
,'350723198006221015'
,'35072119921010001X'
,'361024200112101210'
,'35212119760930003X'
,'350783199108264033'
,'352123197008075538'
,'350781199707315215'
,'350722199808314246'
,'350783199202141216'
,'350702200302222344'
,'352122197007041030'
,'350702198704163711'
,'35072219800910423X'
,'350784198404184611'
,'350725198510200515'
,'350725199011180526'
,'350722198908083938'
,'350427197810302515'
,'352228197402113544'
,'510524199404194630'
,'350783200202220251'
,'361024200112101210'
,'350725198107061025'
,'350784199909303713'
,'350725199608270532'
,'352101196405111835'
,'352123196612054018'
,'350725198807113551'
,'350721197703184515'
,'35078319870217153X'
,'43312719851115244X'
,'352102196809057229'
,'350781196611265213'
,'350784199601263516'
,'35072219831010161X'
,'350722199904085017'
,'35078419820102487X'
,'350781199609046410'
,'350721199910062616'
,'35078419820102487X'
,'350722198204243550'
,'350784199109054229'
,'350725200206302015'
,'350322197312111030'
,'352124197107300434'
,'350784199111280030'
,'350783197907130251'
,'350783199801017014'
,'350721199302284514'
,'510227197105101936'
,'352122197804231013'
,'350784198601263511'
,'350784199911102419'
,'350783199203137534'
,'350784200306080018'
,'350723199601120619'
,'350784198707112033'
,'350784198308052432'
,'352128197106211013'
,'350784199510133716'
,'350723199906091337'
,'350723199604150012'
,'350783198603295019'
,'350724199007073510'
,'352229199601225018'
,'352122196704300523'
,'352123195904128029'
,'350722198504223519'
,'350725198803021510'
,'352123197103114021'
,'350784199410102816'
,'350784197408101014'
,'352103197505284036'
,'352102197710121651'
,'352103197505284036'
,'500222199712227819'
,'35072219831010161X'
,'350783199110212515'
,'350427197810302515'
,'350784200306080018'
,'350784198112142014'
,'350783198608037537'
,'352123197404117517'
,'350784198711054817'
,'350784200108312017'
,'350782198905161036'
,'352122196704300523'
,'35078319870217153X'
,'330821199912052077'
,'350783198112031211'
,'350783198608037537'
,'350784200306080018'
,'350781198202212822'
,'352122196304262417'
,'350722200302080011'
,'350783199603305541'
,'350722199912284630'
,'350722199904085017'
,'350784200306080018'
,'42280220010109218X'
,'350781199910216810'
,'352121197203053219'
,'350702198208262315'
,'350723199905261736'
,'350725200308260514'
,'35072219831010161X'
,'350783199810144015'
,'350784199610032410'
,'350724199005163539'
,'350722200202080612'
,'350784200010284214'
,'350725199104172517'
,'350725199108061021'
,'350702199304151310'
,'350722200011110911'
,'350722200004104636'
,'350783199012240213'
,'350784197110284612'
,'350702199706016138'
,'350702199504241329'
,'35078119921016161X'
,'350723199209301319'
,'350781198802071621'
,'352124196207194240'
,'350782199004180031'
,'350784199608294614'
,'350784200006203733'
,'350781198202212822'
,'362202199401305314'
,'352123197512077516'
,'350721197703184515'
,'350783199208097519'
,'350784199507093311'
,'352122197208074234'
,'350782198210060036'
,'350724199104024016'
,'350784198912122417'
,'350702199509303437'
,'350702200103211327'
,'350783198903114013'
,'350725198305101032'
,'350721198906212111'
,'350725198107061025'
,'35222919740308610X'
,'500223198405281438'
,'452701200212222729'
,'350784199809162810'
,'352101196405111835'
,'352123196311084010'
,'350702200503311829'
,'350783197808067517'
,'352202199208033917'
,'350782199712123513'
,'350783198708081586'
,'52212419820409363X'
,'350722198102245053'
,'350783198804166512'
,'350783199008245521'
,'350781198611206829'
,'350784200010072051'
,'350702199712187128'
,'350784199604152416'
,'352122196506211036'
,'352101196407250337'
,'350781198202212822'
,'350783199101171248'
,'51253119740915735X'
,'352124197809183914'
,'350722199108103915'
,'352122197708142432'
,'350702200108280823'
,'350721199802094522'
,'35078319880126095X'
,'350783199705025014'
,'350784198812072053'
,'350428197807055513'
,'35070220020613183X'
,'350784198409074817'
,'350725198803200041'
,'350784199201304817'
,'350782199712173510'
,'350722198906163918'
,'350702200411054714'
,'352127196502081328'
,'352123197607137518'
,'350781199606080015'
,'350783199007144518'
,'350784199306161517'
,'350784199908202013'
,'350725199411230529'
,'350784198806082415'
,'350784198911013737'
,'352122196707281524'
,'350725199210054522'
,'350784199610032410'
,'350784199608173716'
,'352127196502081328'
,'352601197709137032'
,'350725198303181024'
,'352122197106233310'
,'350724198209073514'
,'35078319950208652X'
,'350782199011092523'
,'350783198102287053'
,'350783197908012513'
,'350722200411303536'
,'350783198309173037'
,'350725199003224517'
,'35012419900315285X'
,'350723198108131010'
,'350784198605031515'
,'350784199808223511'
,'350784198203181019'
,'350724199004063034'
,'350783198102287053'
,'360681199406073925'
,'350702200411054714'
,'352127196502081328'
,'35078219981201201X'
,'350902200002170088'
,'350784200303280057'
,'350722200006140518'
,'350784198809264628'
,'350783198607053017'
,'350725197511163010'
,'350783199507087011'
,'350724199606242515'
,'350784200302030013'
,'350783199910057517'
,'352104197804260516'
,'350725200202042017'
,'352122196811051518'
,'350722198201264612'
,'350725200205022011'
,'350784199604152416'
,'350783198406287036'
,'350721198507254226'
,'350725200205022011'
,'352121196907051313'
,'350783199101116513'
,'352123196611037056'
,'350725200206244513'
,'350784200303300011'
,'350784198108113720'
,'35078119940514561X'
,'350725200207142017'
,'350784200303280057'
,'352123197208227559'
,'352122197911023711'
,'350783199501204010'
,'350783199603256516'
,'350783198406195019'
,'362430198408282612'
,'35072319851010044X'
,'352227198203150535'
,'350784197110284612'
,'350784198106064216'
,'350725198509153010'
,'350784198109082014'
,'350722199801044618'
,'350702198211301311'
,'350182198402052214'
,'350784198802241511'
,'350784198310041820'
,'350784200010232019'
,'350722198103220018'
,'350783198404203046'
,'350784199002204813'
,'350725198802144017'
,'352122196808162460'
,'350725198808293515'
,'350783198306105020'
,'350125199003070033'
,'352102197112284434'
,'350783198404203046'
,'350784198802241511'
,'350781199306301621'
,'35078419960814371X'
,'35210419790302253X'
,'350783199806151212'
,'350783199806151212'
,'350783198308267015'
,'352104195901082521'
,'350702198809028217'
,'350721199707074910'
,'350123198903155617'
,'500241199403101015'
)
;
**数据需求_20211103_戴娴_杭州分行个人结算账户排查.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-03 13:33:58
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

-- 1.开户至20211031交易流水中断两个月（含）以上名单
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门,无交易天数_max
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_1_20211103;

-- 2. 20210801-1031未发生交易流水的名单
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_2_20211103;

-- 3. 20210901-1031未发生交易流水的名单
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_3_20211103;

-- 4.开户至今无交易流水的名单
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_4_20211103;


SELECT *
from edw.dwd_bus_dep_bal_chg_dtl_di
where dt <= '20211031'
and dep_act_id = 33020041000000114496
;


/*  -------2----
数据区间：2019年1月1日-2021年10月31日
账户类型：个人结算账户
字段：1.区分户籍地浙江与非浙江省
    2.2021年8月1日-10月31日未发生交易流水
姓名 身份证 户籍/工作地址 账号 客户号 开户日期 部门 客户经理 账户状态
*/
drop table if exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_2_20211103;
create table if not exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_2_20211103 as
select a.dep_act_id as 存款账号
      ,a.cst_act_id as 客户账号
      ,a.cst_id as 客户号
      ,c.cst_chn_nm 客户名称
      ,a.opn_org 开户机构号
      ,d.org_nm 开户机构名称
      ,c.prm_org_id as 主管户机构号
      ,c.prm_org_nm as 主管户机构名
      ,c.doc_nbr as 证件号码
      ,c.reg_adr as 户籍地址
      ,case when c.reg_adr like '%浙江%' or c.reg_adr like '%杭州%' or c.reg_adr like '%宁波%' or c.reg_adr like '%温州%' or c.reg_adr like '%湖州%' or c.reg_adr like '%嘉兴%' or c.reg_adr like '%绍兴%' or c.reg_adr like '%金华%' or c.reg_adr like '%衢州%' or c.reg_adr like '%舟山%' or c.reg_adr like '%台州%' or c.reg_adr like '%丽水%' then '浙江省'
            when c.reg_adr is null then ''
            else '其他省份'
        end as 户籍地区域
      ,code1.cd_val_dscr as 账户状态
      ,a.opn_dt as 开户日期
      ,c.prm_mgr_id as 客户经理
      ,c.prm_mgr_nm as 主管户客户经理名称
      ,c.prm_org_nm as 客户经理部门
from edw.dim_bus_dep_act_inf_dd a  --存款账户信息
join edw.dws_bus_dep_act_inf_dd b --存款账户信息汇总
    on a.dep_act_id=b.dep_act_id
    and b.dt='20211031'
    and b.cst_tp='1' --对私
    and b.lbl_prod_typ_cd='0' --活期
left join edw.dws_cst_bas_inf_dd c --客户基础信息汇总表
    on a.cst_id=c.cst_id
    and c.dt='20211031'
left join edw.dim_hr_org_mng_org_tree_dd d  --机构树_考核维度
    on a.opn_org = d.org_id
    and d.dt = '20211031'
left join edw.dwd_code_library code1 on code1.cd_val = a.act_sts_cd and code1.cd_nm like '%账户状态%' and code1.tbl_nm = upper('dim_bus_dep_act_inf_dd')
where a.dt='20211031'
and substr(c.prm_org_id,1,7)='3302004' --
and a.opn_dt>='20190101'
and a.opn_dt<='20211031'
and a.stl_act_ind ='1' --结算标志为1
and a.dep_act_id not in
(
select dep_act_id
from edw.dwd_bus_dep_bal_chg_dtl_di
where dt >= '20210801' and dt <= '20211031'
);
-------------
-- 2. 20210801-1031未发生交易流水的名单
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_2_20211103;


/* -------3----
数据区间：2019年1月1日-2021年10月31日
账户类型：个人结算账户
字段：1.区分户籍地浙江与非浙江省
    2.2021年9月1日-10月31日未发生交易流水
姓名 身份证 户籍/工作地址 账号 客户号 开户日期 部门 客户经理 账户状态
*/
drop table if exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_3_20211103;
create table if not exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_3_20211103 as
select a.dep_act_id as 存款账号
      ,a.cst_act_id as 客户账号
      ,a.cst_id as 客户号
      ,c.cst_chn_nm 客户名称
      ,a.opn_org 开户机构号
      ,d.org_nm 开户机构名称
      ,c.prm_org_id as 主管户机构号
      ,c.prm_org_nm as 主管户机构名
      ,c.doc_nbr as 证件号码
      ,c.reg_adr as 户籍地址
      ,case when c.reg_adr like '%浙江%' or c.reg_adr like '%杭州%' or c.reg_adr like '%宁波%' or c.reg_adr like '%温州%' or c.reg_adr like '%湖州%' or c.reg_adr like '%嘉兴%' or c.reg_adr like '%绍兴%' or c.reg_adr like '%金华%' or c.reg_adr like '%衢州%' or c.reg_adr like '%舟山%' or c.reg_adr like '%台州%' or c.reg_adr like '%丽水%' then '浙江省'
            when c.reg_adr is null then ''
            else '其他省份'
        end as 户籍地区域
      ,code1.cd_val_dscr as 账户状态
      ,a.opn_dt as 开户日期
      ,c.prm_mgr_id as 客户经理
      ,c.prm_mgr_nm as 主管户客户经理名称
      ,c.prm_org_nm as 客户经理部门
from edw.dim_bus_dep_act_inf_dd a  --存款账户信息
join edw.dws_bus_dep_act_inf_dd b --存款账户信息汇总
    on a.dep_act_id=b.dep_act_id
    and b.dt='20211031'
    and b.cst_tp='1' --对私
    and b.lbl_prod_typ_cd='0' --活期
left join edw.dws_cst_bas_inf_dd c --客户基础信息汇总表
    on a.cst_id=c.cst_id
    and c.dt='20211031'
left join edw.dim_hr_org_mng_org_tree_dd d  --机构树_考核维度
    on a.opn_org = d.org_id
    and d.dt = '20211031'
left join edw.dwd_code_library code1 on code1.cd_val = a.act_sts_cd and code1.cd_nm like '%账户状态%' and code1.tbl_nm = upper('dim_bus_dep_act_inf_dd')
where a.dt='20211031'
and substr(c.prm_org_id,1,7)='3302004' --管户行：杭州分行萧山支行
and a.opn_dt>='20190101'
and a.opn_dt<='20211031'
and a.stl_act_ind ='1' --结算标志为1
and a.dep_act_id not in
(
select dep_act_id
from edw.dwd_bus_dep_bal_chg_dtl_di
where dt >= '20210901' and dt <= '20211031'
);
-------------------
-- 3. 20210901-1031未发生交易流水的名单
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_3_20211103;



--         -------------------------------------------------------------------------------------------
/*  --------1-----
数据区间：2019年1月1日-2021年10月31日
账户类型：个人结算账户
字段：1.区分户籍地浙江与非浙江省
      2.开户日至2021年10月31日区间 发生的账户交易流水中间中断两个月（含）以上
姓名 身份证 户籍/工作地址 账号 客户号 开户日期 部门 客户经理 账户状态
*/


/*  ------4----
数据区间：2019年1月1日-2021年10月31日
账户类型：个人结算账户
字段：1.区分户籍地浙江与非浙江省
    2.开户日至2021年10月31日未发生交易流水
姓名 身份证 户籍/工作地址 账号 客户号 开户日期 部门 客户经理 账户状态
*/
drop table if exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_14tot_20211103;
create table if not exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_14tot_20211103 as
select a.dep_act_id as 存款账号
      ,a.cst_act_id as 客户账号
      ,a.cst_id as 客户号
      ,c.cst_chn_nm 客户名称
      ,a.opn_org 开户机构号
      ,d.org_nm 开户机构名称
      ,c.prm_org_id as 主管户机构号
      ,c.prm_org_nm as 主管户机构名
      ,c.doc_nbr as 证件号码
      ,c.reg_adr as 户籍地址
      ,case when c.reg_adr like '%浙江%' or c.reg_adr like '%杭州%' or c.reg_adr like '%宁波%' or c.reg_adr like '%温州%' or c.reg_adr like '%湖州%' or c.reg_adr like '%嘉兴%' or c.reg_adr like '%绍兴%' or c.reg_adr like '%金华%' or c.reg_adr like '%衢州%' or c.reg_adr like '%舟山%' or c.reg_adr like '%台州%' or c.reg_adr like '%丽水%' then '浙江省'
            when c.reg_adr is null then ''
            else '其他省份'
        end as 户籍地区域
      ,code1.cd_val_dscr as 账户状态
      ,a.opn_dt as 开户日期
      ,c.prm_mgr_id as 客户经理
      ,c.prm_mgr_nm as 主管户客户经理名称
      ,c.prm_org_nm as 客户经理部门
      ,e.trx_dt as 交易日期
from edw.dim_bus_dep_act_inf_dd a  --存款账户信息
join edw.dws_bus_dep_act_inf_dd b --存款账户信息汇总
    on a.dep_act_id=b.dep_act_id
    and b.dt='20211031'
    and b.cst_tp='1' --对私
    and b.lbl_prod_typ_cd='0' --活期
left join edw.dws_cst_bas_inf_dd c --客户基础信息汇总表
    on a.cst_id=c.cst_id
    and c.dt='20211031'
left join edw.dim_hr_org_mng_org_tree_dd d  --机构树_考核维度
    on a.opn_org = d.org_id
    and d.dt = '20211031'
left join edw.dwd_bus_dep_bal_chg_dtl_di e on a.dep_act_id = e.dep_act_id and e.dt <= '20211031'
left join edw.dwd_code_library code1 on code1.cd_val = a.act_sts_cd and code1.cd_nm like '%账户状态%' and code1.tbl_nm = upper('dim_bus_dep_act_inf_dd')
where a.dt='20211031'
and substr(c.prm_org_id,1,7)='3302004' --萧山支行
and a.opn_dt>='20190101'
and a.opn_dt<='20211031'
and a.stl_act_ind ='1' --结算标志为1
;
---------------------
select *
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_14tot_20211103
where 存款账号 = '33020041000000367540'
order by 交易日期
;
select count(*) from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_14tot_20211103; -- 1463969
select *,row_number()over(partition by 存款账号 order by 交易日期) from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_14tot_20211103;

--   ----------------------------------4. 开户至今未发生交易  结果表
drop table if exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_4_20211103;
create table if not exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_4_20211103 as
select *
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_14tot_20211103 a -- 7252
where 交易日期 is null
order by 存款账号
;
-- 4.开户至今无交易流水的账号
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_4_20211103;


---   ---------------------------------1. 交易流水中断2个月以上 结果表
drop table if exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_1_20211103;
create table if not exists lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_1_20211103 as
select c.存款账号
      ,c.客户账号
      ,c.客户号
      ,c.客户名称
      ,c.开户机构号
      ,c.开户机构名称
      ,c.主管户机构号
      ,c.主管户机构名
      ,c.证件号码
      ,c.户籍地址
      ,c.户籍地区域
      ,c.账户状态
      ,c.开户日期
      ,c.客户经理
      ,c.主管户客户经理名称
      ,c.客户经理部门
      ,c.无交易天数_max
from
(
select b.*
      ,row_number()over(partition by 存款账号 order by 无交易天数 desc) as rn
      ,max(无交易天数)over(partition by 存款账号) as 无交易天数_max
from
(
   select a.*,DATEDIFF(to_date(lag_1,'yyyymmdd'),to_date(交易日期,'yyyymmdd'),'dd') as 无交易天数
   from
   (
      select *
            ,lag(交易日期,1,0)over(partition by 存款账号 order by 交易日期 desc) as lag_1
      from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_14tot_20211103
   ) a
) b
) c
where c.rn = 1
and 无交易天数_max >= 60
;
----------------
-- 1.开户至20211031交易流水中断两个月（含）以上名单
select 存款账号,客户账号,客户号,客户名称,证件号码,户籍地址,户籍地区域,账户状态,开户机构名称,开户日期,客户经理,主管户客户经理名称,客户经理部门,无交易天数_max
from lab_bigdata_dev.xt_024618_tmp_xiaoshanliushui_1_20211103
;
**数据需求_20211105_钱晓莉_丽水分行2020年12月份免税清单.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-05 14:51:03
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select * from lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105 where dt = '20201226'
;

drop table if exists lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_result;
create table if not exists lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_result as   --贷款销项税计提明细结果表
select *
from lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105
where dt >= '20201201' AND dt <= '20201231'
AND Acct_Org_Cd like '3306%'
;
select data_dt,acct_org_cd,cust_no,cust_nm,con_no,con_start_dt,con_matu_dt,start_dt,con_amt,ex_cur_bal,
ex_open_bal,dbill_no,is_con_end,off_sheet_flg,is_trans_flg,ln_tp,agriculture_flg,cust_faml_addr,cust_faml_addr_age,
cust_size_gb,industry_type,busi_inc,emp_num,asset_scale,is_priv_ent_owned,is_priv_ind_owned,is_priv_ind_owned_head,
dbill_amt,ex_dbill_amt,ccy_cd,conv_rmb_rate,credit_total_limit,vat_free_flg,base_term_flg,busi_acct_cd,busi_acct_nm,lpr_rate,
lpr_term,term,nor_rate,year_mon_nor_rate_flg,odue_rate,year_mon_odue_rate_flg,tax_rate_per,acct_intst_amt,acct_pen_intst_amt,
acct_dis_intst_amt,opt_tax_intst_amt,non_tax_intst_inc,tax_intst_inc,dt from lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_result
;


------------------------------------------------------------------------------------------------
drop table if exists lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_result_1231;
create table if not exists lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_result_1231 as
select *
from lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_2
where dt = '20201231'
AND Acct_Org_Cd like '3306%'
;
select data_dt,acct_org_cd,cust_no,cust_nm,con_no,con_start_dt,con_matu_dt,start_dt,con_amt,ex_cur_bal,
ex_open_bal,dbill_no,is_con_end,off_sheet_flg,is_trans_flg,ln_tp,agriculture_flg,cust_faml_addr,cust_faml_addr_age,
cust_size_gb,industry_type,busi_inc,emp_num,asset_scale,is_priv_ent_owned,is_priv_ind_owned,is_priv_ind_owned_head,
dbill_amt,ex_dbill_amt,ccy_cd,conv_rmb_rate,credit_total_limit,vat_free_flg,base_term_flg,busi_acct_cd,busi_acct_nm,lpr_rate,
lpr_term,term,nor_rate,year_mon_nor_rate_flg,odue_rate,year_mon_odue_rate_flg,tax_rate_per,acct_intst_amt,acct_pen_intst_amt,
acct_dis_intst_amt,opt_tax_intst_amt,non_tax_intst_inc,tax_intst_inc,dt from lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_result_1231
;

select * from lab_bigdata_dev.VAT_ITG_LOAN_TAX_TMP_xt;

--获取贷款客户的单户授信总额
DROP TABLE IF EXISTS lab_bigdata_dev.VAT_ITG_LOAN_TAX_TMP_xt;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.VAT_ITG_LOAN_TAX_TMP_xt
(
Cust_No                   STRING   COMMENT '客户号',
Dbill_Amt                 DECIMAL  COMMENT '授信总额'
);

INSERT INTO lab_bigdata_dev.VAT_ITG_LOAN_TAX_TMP_xt
   SELECT
          BC.CustomerId                          AS Cust_No, --客户号
          SUM(BD.BusinessSum * NVL(EXR.Avg_Prc,100) / 100) AS Dbill_Amt --授信总额
   FROM    edw.LOAN_BUSINESS_CONTRACT BC   --合同信息表
   INNER JOIN edw.LOAN_BUSINESS_DUEBILL BD  --借据信息表
   ON BC.SerialNo = BD.RelativeSerialNo2
   AND BD.Balance > 0    --贷款余额大于0
   AND BD.AgreementType <> '3'  --剔除证券化，非转让贷款
   AND ( bc.SPECIALFUNDSOURCE IS NULL OR bc.SPECIALFUNDSOURCE <> '09' )  --剔除信托贷款
   AND (bc.FreezeFlag <> '4' or bc.FreezeFlag is NULL or BC.finishdate IS NULL) --剔除终止失效，合同未终结
   --AND BC.finishdate IS NULL
   AND bd.dt = '20201231'
   AND bc.dt = '20201231'
   INNER JOIN edw.LOAN_BUSINESS_TYPE BT  --业务品种表
   ON BC.BusinessType = BT.typeno
   AND Bt.OffsheetFlag = '1'  -- 是否表内贷款
   AND Bt.TypeNo NOT LIKE '20104020%'  --剔除信用卡和贴现业务
   AND bt.dt = '20201231'
   LEFT JOIN  edw.DIM_BUS_COM_EXR_INF_DD exr --汇率表
   ON bd.businesscurrency = exr.ccy_cd
   AND exr.dt = '20201231'
   GROUP BY BC.CustomerId;


--处理贷款税务计提明细数据
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_2
(
Data_Dt                 STRING   COMMENT  '数据日期                   ',
Acct_Org_Cd             STRING   COMMENT  '核算机构代码               ',
Cust_No                 STRING   COMMENT  '客户号                     ',
Cust_Nm                 STRING   COMMENT  '客户名称                   ',
Con_No                  STRING   COMMENT  '合同编号                   ',
Con_Start_Dt            STRING   COMMENT  '合同起始日                 ',
Con_Matu_Dt             STRING   COMMENT  '合同到期日                 ',
Start_Dt                STRING   COMMENT  '起息日期                   ',
Con_Amt                 DECIMAL  COMMENT  '合同金额                   ',
Ex_Cur_Bal              DECIMAL  COMMENT  '贷款余额（折人民币）        ',
Ex_Open_Bal             DECIMAL  COMMENT  '放款金额（折人民币）        ',
Dbill_No                STRING   COMMENT  '借据编号                   ',
Is_Con_End              STRING   COMMENT  '合同是否终结               ',
Off_Sheet_Flg           STRING   COMMENT  '表内外标识                 ',
Is_Trans_Flg            STRING   COMMENT  '是否转让标识               ',
Ln_Tp                   STRING   COMMENT  '贷款类型                   ',
Agriculture_Flg         STRING   COMMENT  '涉农标志                   ',
Cust_Faml_Addr          STRING   COMMENT  '居住地址                   ',
Cust_Faml_Addr_Age      DECIMAL  COMMENT  '居住年限                   ',
Cust_Size_Gb            STRING   COMMENT  '企业规模                   ',--客户规模（国标）
Industry_Type           STRING   COMMENT  '行业类型                   ',--企业行业类型
Busi_Inc                DECIMAL  COMMENT  '企业营业收入               ',
Emp_Num                 DECIMAL  COMMENT  '企业员工人数               ',
Asset_Scale             DECIMAL  COMMENT  '企业资产总额               ',--企业资产规模
Is_Priv_Ent_Owned       STRING   COMMENT  '对公个体工商户             ',
Is_Priv_Ind_Owned       STRING   COMMENT  '个体工商户关系人           ',--是否个体工商户
Is_Priv_Ind_Owned_Head  STRING   COMMENT  '是否个体工商户主           ',
Dbill_Amt               DECIMAL  COMMENT  '借据金额（原币）           ',
Ex_Dbill_Amt            DECIMAL  COMMENT  '借据金额（折人民币）       ',
Ccy_Cd                  STRING   COMMENT  '币种代码                  ',
Conv_Rmb_Rate           DECIMAL  COMMENT  '折人民币汇率              ',
Credit_Total_Limit      DECIMAL  COMMENT  '单户税务授信金额           ',--授信总额度
Vat_Free_Flg            STRING   COMMENT  '免税标识                  ',--增值税免税标志
Base_Term_Flg           STRING   COMMENT  '基准期限标识              ',
Busi_Acct_Cd            STRING   COMMENT  '核算码（会计类别）         ',
Busi_Acct_Nm            STRING   COMMENT  '核算码名称（会计类别）     ',
Lpr_Rate                DECIMAL  COMMENT  'LPR利率                  ',
Lpr_Term                STRING   COMMENT  'LPR期限                  ',
Term                    DECIMAL  COMMENT  '贷款期限月数              ',--期限
--Exec_Rate               DECIMAL  COMMENT  '实际利率                  ',--执行利率(%)
--Year_Mon_Rate_Flg       STRING   COMMENT  '实际年月利率标志              ',
Nor_Rate                DECIMAL  COMMENT  '正常利率                  ',--正常利率(%)
Year_Mon_Nor_Rate_Flg   STRING   COMMENT  '正常年月利率标志              ',
Odue_Rate               DECIMAL  COMMENT  '逾期利率                  ',--逾期利率(%)
Year_Mon_Odue_Rate_Flg  STRING   COMMENT  '逾期年月利率标志              ',
Tax_Rate_Per            DECIMAL  COMMENT  '税率比例                  ',
Acct_Intst_Amt          DECIMAL  COMMENT  '应收应计利息发生额         ',
Acct_Pen_Intst_Amt      DECIMAL  COMMENT  '应收应计罚息发生额         ',
Acct_Dis_Intst_Amt      DECIMAL  COMMENT  '应计贴息发生额             ',
Opt_Tax_Intst_Amt       DECIMAL  COMMENT  '应收应计销项税发生额       ',
Non_Tax_Intst_Inc       DECIMAL  COMMENT  '免税利息收入（计提口径）   ',
Tax_Intst_Inc           DECIMAL  COMMENT  '应税利息收入（计提口径）   '
)
COMMENT
'贷款销项税计提明细结果表'
PARTITIONED BY
(
    DT STRING COMMENT '日期分区'
)
LIFECYCLE 3000
;
ALTER TABLE lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_2 DROP IF EXISTS PARTITION ( DT = '@@{yyyyMMdd}' )
;


INSERT
  INTO lab_bigdata_dev.VAT_ITG_LOAN_TAX_RST_xt_024618_20211105_2 PARTITION ( DT = '20201231' )
  (Data_Dt                 ,
Acct_Org_Cd             ,
Cust_No                 ,
Cust_Nm                 ,
Con_No                  ,
Con_Start_Dt            ,
Con_Matu_Dt             ,
Start_Dt                ,
Con_Amt                 ,
Ex_Cur_Bal              ,
Ex_Open_Bal             ,
Dbill_No                ,
Is_Con_End              ,
Off_Sheet_Flg           ,
Is_Trans_Flg            ,
Ln_Tp                   ,
Agriculture_Flg         ,
Cust_Faml_Addr          ,
Cust_Faml_Addr_Age      ,
Cust_Size_Gb            ,
Industry_Type           ,
Busi_Inc                ,
Emp_Num                 ,
Asset_Scale             ,
Is_Priv_Ent_Owned       ,
Is_Priv_Ind_Owned       ,
Is_Priv_Ind_Owned_Head  ,
Dbill_Amt               ,
Ex_Dbill_Amt            ,
Ccy_Cd                  ,
Conv_Rmb_Rate           ,
Credit_Total_Limit      ,
Vat_Free_Flg            ,
Base_Term_Flg           ,
Busi_Acct_Cd            ,
Busi_Acct_Nm            ,
Lpr_Rate                ,
Lpr_Term                ,
Term                    ,
--Exec_Rate               ,
--Year_Mon_Rate_Flg       ,
Nor_Rate                ,
Year_Mon_Nor_Rate_Flg   ,
Odue_Rate               ,
Year_Mon_Odue_Rate_Flg  ,
Tax_Rate_Per            ,
Acct_Intst_Amt          ,
Acct_Pen_Intst_Amt      ,
Acct_Dis_Intst_Amt      ,
Opt_Tax_Intst_Amt       ,
Non_Tax_Intst_Inc       ,
Tax_Intst_Inc
)
    SELECT
    '20201231' AS Data_Dt                 , -- '数据日期                   '
    T.act_org_id AS Acct_Org_Cd             , -- '核算机构代码               '
    T.cst_id AS Cust_No                 , -- '客户号                     '
    T.cst_nm AS Cust_Nm                 , -- '客户名称                   '
    T.bus_ctr_id AS Con_No                  , -- '合同编号                   '
    T1.APNT_START_DT AS Con_Start_Dt            , -- '合同起始日                 '
    T1.APNT_MTU_DT AS Con_Matu_Dt             , -- '合同到期日                 '
    T.dtrb_dt AS Start_Dt                , -- '起息日期                   '
    T1.CTR_AMT AS Con_Amt                 , -- '合同金额                   '
    T.prcp_bal * NVL(T6.avg_prc,100)/100 AS Ex_Cur_Bal              , -- '贷款余额（折人民币）        '
    T.amt * NVL(T6.avg_prc,100)/100 AS Ex_Open_Bal             , -- '放款金额（折人民币）        '
    T.dbil_id AS Dbill_No                , -- '借据编号                   '
    T1.FRZ_STS_CD AS Is_Con_End              , -- '合同是否终结,4代表终止失效               '
    T2.OffsheetFlag AS Off_Sheet_Flg           , -- '表内外标识,1代表表内贷款                 '
    T.AGR_TYP_CD AS Is_Trans_Flg            , -- '是否转让标识 3代表资产证券化-转让               '
    T.PD_CD AS Ln_Tp                   , -- '贷款类型, 20104020%-信用卡和贴现业务                  '
    T3.FARMER AS Agriculture_Flg         , -- '涉农标志 1代表农户                  '
    T3.familyadd AS Cust_Faml_Addr          , -- '居住地址                   '
    T3.resideyear AS Cust_Faml_Addr_Age      , -- '居住年限                   '
    T4.SCOPE AS Cust_Size_Gb            , -- '企业规模,2-大 3-中 4-小 5-微 9-其他                   '--客户规模（国标）
    T4.industrytype AS Industry_Type           , -- '行业类型                   '--企业行业类型
    T4.lastyearsale AS Busi_Inc                , -- '企业营业收入               '
    T4.employeenumber AS Emp_Num                 , -- '企业员工人数               '
    T4.capitalamount AS Asset_Scale             , -- '企业资产总额               '--企业资产规模
    CASE WHEN T5.loan_cst_typ_cd = '0103' THEN '是' ELSE '否' END AS Is_Priv_Ent_Owned       , -- '对公个体工商户             '
    CASE WHEN T5.loan_cst_typ_cd = '0702' THEN '是' ELSE '否' END AS Is_Priv_Ind_Owned       , -- '个体工商户关系人           '--是否个体工商户
    T3.isindindustry AS Is_Priv_Ind_Owned_Head  , -- '是否个体工商户主,1-是 2-否           '
    T.amt AS Dbill_Amt               , -- '借据金额（原币）           '
    T.amt * NVL(T6.avg_prc,100)/100 AS Ex_Dbill_Amt            , -- '借据金额（折人民币）       '
    T.CCY_CD AS Ccy_Cd                  , -- '币种代码                  '
    T6.avg_prc AS Conv_Rmb_Rate           , -- '折人民币汇率              '
    T7.Dbill_Amt AS Credit_Total_Limit      , -- '单户税务授信金额           '--授信总额度
    t8.jsflbzhi AS Vat_Free_Flg            , -- '免税标识,1-免税                  '--增值税免税标志 T.WTHR_FRE_TAX
    T8.jzqixian AS Base_Term_Flg           , -- '基准期限标识 11全额计税              '
    T.act_act_no AS Busi_Acct_Cd            , -- '核算码（会计类别）         '
    T9.ywbimasm AS Busi_Acct_Nm            , -- '核算码名称（会计类别）     '
    --大于这个日期20201019的,是以开户日期的LPR利率为准,小于等于20201019的,参考的不是LPR利率,参考的是信贷基准利率
    CASE WHEN T.dtrb_dt <= 20201019 THEN
          CASE WHEN T8.jzqixian IN ('6M','1Y') THEN 4.35
               WHEN T8.jzqixian IN ('3Y','5Y') THEN 4.75
               WHEN T8.jzqixian = 'YY'         THEN 4.9
          END
         WHEN T.dtrb_dt > 20201019 THEN
          CASE WHEN MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) >=0 AND MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) <= 12 THEN 3.85
          ELSE 4.65
          END
    END AS Lpr_Rate                , -- 'LPR利率                  '
    CASE WHEN T.dtrb_dt > 20201019 THEN
          CASE WHEN MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) >=0 AND MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) <= 12 THEN '1Y'
          ELSE '5Y'
          END
    END AS Lpr_Term                , -- 'LPR期限                  '
    ROUND(MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')),2) AS Term                    , -- '贷款期限月数              '--期限
    --T10.SHIJLILV AS Exec_Rate               , -- '实际利率                  '--执行利率(%)
    --T10.SJNYLILV AS Year_Mon_Rate_Flg       , -- '年月利率标志              '
    T10.zhchlilv AS Nor_Rate                , --'正常利率                  '
    T10.NYUELILV AS Year_Mon_Nor_Rate_Flg   ,  --'正常年月利率标志              '
    T10.yuqililv AS Odue_Rate               , --'逾期利率                  '
    T10.YUQINYLL AS Year_Mon_Odue_Rate_Flg  ,-- '逾期年月利率标志              '
    T8.shlvbili AS Tax_Rate_Per            , -- '税率比例                  '
    T10.YSYJLXFS AS Acct_Intst_Amt          , -- '应收应计利息发生额         '
    T10.YSYJFXFS AS Acct_Pen_Intst_Amt      , -- '应收应计罚息发生额         '
    T10.YJITXIFS AS Acct_Dis_Intst_Amt      , -- '应计贴息发生额             '
    T10.YSYJXXFS AS Opt_Tax_Intst_Amt       , -- '应收应计销项税发生额       '
    CASE WHEN T8.jzqixian = '11' THEN 0
         WHEN T8.shlvbili = 0 THEN T10.YSYJLXFS + T10.YJITXIFS + T10.YSYJFXFS
    ELSE T10.YSYJLXFS + T10.YJITXIFS + T10.YSYJFXFS -
      (CASE WHEN T10.YSYJLXFS + T10.YJITXIFS <> 0 THEN
      ROUND(GREATEST((T10.zhchlilv * DECODE(T10.NYUELILV,'M',12,'Y',10)/10 -
            CASE WHEN T.dtrb_dt <= 20201019 THEN
                  CASE WHEN T8.jzqixian IN ('6M','1Y') THEN 4.35
                      WHEN T8.jzqixian IN ('3Y','5Y') THEN 4.75
                      WHEN T8.jzqixian = 'YY'         THEN 4.9
                  END
                WHEN T.dtrb_dt > 20201019 THEN
                  CASE WHEN MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) >=0 AND MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) <= 12 THEN 3.85
                  ELSE 4.65
                  END
            END * 1.5),0) / (T10.zhchlilv * DECODE(T10.NYUELILV,'M',12,'Y',10)/10) * (T10.YSYJLXFS + T10.YJITXIFS)
          ,8)
      ELSE 0
      END +
      CASE WHEN T10.YSYJFXFS <> 0 THEN
      ROUND(GREATEST((T10.yuqililv * DECODE(T10.YUQINYLL,'M',12,'Y',10)/10 -
            CASE WHEN T.dtrb_dt <= 20201019 THEN
                  CASE WHEN T8.jzqixian IN ('6M','1Y') THEN 4.35
                      WHEN T8.jzqixian IN ('3Y','5Y') THEN 4.75
                      WHEN T8.jzqixian = 'YY'         THEN 4.9
                  END
                WHEN T.dtrb_dt > 20201019 THEN
                  CASE WHEN MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) >=0 AND MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) <= 12 THEN 3.85
                  ELSE 4.65
                  END
            END * 1.5),0) / (T10.yuqililv * DECODE(T10.YUQINYLL,'M',12,'Y',10)/10) * T10.YSYJFXFS
          ,8)
      ELSE 0
      END)
    END AS Non_Tax_Intst_Inc       , -- '免税利息收入（计提口径）   '
    CASE WHEN T8.jzqixian = '11' THEN  T10.YSYJLXFS + T10.YJITXIFS + T10.YSYJFXFS
         WHEN T8.shlvbili = 0 THEN 0
    ELSE (CASE WHEN T10.YSYJLXFS + T10.YJITXIFS <> 0 THEN
      ROUND(GREATEST((T10.zhchlilv * DECODE(T10.NYUELILV,'M',12,'Y',10)/10 -
            CASE WHEN T.dtrb_dt <= 20201019 THEN
                  CASE WHEN T8.jzqixian IN ('6M','1Y') THEN 4.35
                      WHEN T8.jzqixian IN ('3Y','5Y') THEN 4.75
                      WHEN T8.jzqixian = 'YY'         THEN 4.9
                  END
                WHEN T.dtrb_dt > 20201019 THEN
                  CASE WHEN MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) >=0 AND MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) <= 12 THEN 3.85
                  ELSE 4.65
                  END
            END * 1.5),0) / (T10.zhchlilv * DECODE(T10.NYUELILV,'M',12,'Y',10)/10) * (T10.YSYJLXFS + T10.YJITXIFS)
          ,8)
      ELSE 0
      END +
      CASE WHEN T10.YSYJFXFS <> 0 THEN
      ROUND(GREATEST((T10.yuqililv * DECODE(T10.YUQINYLL,'M',12,'Y',10)/10 -
            CASE WHEN T.dtrb_dt <= 20201019 THEN
                  CASE WHEN T8.jzqixian IN ('6M','1Y') THEN 4.35
                      WHEN T8.jzqixian IN ('3Y','5Y') THEN 4.75
                      WHEN T8.jzqixian = 'YY'         THEN 4.9
                  END
                WHEN T.dtrb_dt > 20201019 THEN
                  CASE WHEN MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) >=0 AND MONTHS_BETWEEN(TO_DATE(T.APNT_MTU_DAY,'yyyyMMdd'),TO_DATE(T.DTRB_DT,'yyyyMMdd')) <= 12 THEN 3.85
                  ELSE 4.65
                  END
            END * 1.5),0) / (T10.yuqililv * DECODE(T10.YUQINYLL,'M',12,'Y',10)/10) * T10.YSYJFXFS
          ,8)
      ELSE 0
      END)
    END AS Tax_Intst_Inc            -- '应税利息收入（计提口径）
    FROM edw.DIM_BUS_LOAN_DBIL_INF_DD T       --贷款借据信息加工表
    INNER JOIN edw.DIM_BUS_LOAN_CTR_INF_DD T1  --合同信息加工表
    ON T.bus_ctr_id = T1.BUSI_CTR_ID
    AND T.LGP_ID = T1.LGP_ID
    AND T1.DT = '20201231'
    LEFT JOIN edw.LOAN_BUSINESS_TYPE T2  --业务品种表
    ON T.PD_CD = T2.typeno
    AND T2.dt = '20201231'
    LEFT JOIN edw.LOAN_IND_INFO T3   --个人客户基本信息表
    ON T.cst_id = T3.customerid
    AND T3.dt = '20201231'
    LEFT JOIN edw.LOAN_ENT_INFO T4  --对公客户基本信息表
    ON T.cst_id = T4.customerid
    AND T4.dt = '20201231'
    LEFT JOIN edw.DIM_CST_BAS_INF_DD T5 --客户基本信息表
    ON T.cst_id = T5.cst_id
    AND T5.dt = '20201231'
    LEFT JOIN edw.DIM_BUS_COM_EXR_INF_DD T6 --汇率加工表
    ON T.CCY_CD = T6.ccy_cd
    AND T6.dt = '20201231'
    LEFT JOIN lab_bigdata_dev.VAT_ITG_LOAN_TAX_TMP_xt T7 --单户授信总额表
    ON T.cst_id = T7.Cust_No
    LEFT JOIN edw.CORE_KLNB_DKJXSX T8 --贷款账户计息表
    ON T.dbil_id = T8.DKJIEJUH
    AND T8.dt = '20201231'
    LEFT JOIN edw.CORE_KFAP_YESHUX T9 --余额属性表
    ON CONCAT('LN',T.act_act_no) = T9.yewubima
    AND T9.mokuaiii = 'LN'
    AND T9.dt = '20201231'
    LEFT JOIN edw.CORE_KLNL_DKJXMX T10 --贷款计息明细表
    ON T.dbil_id = T10.DKJIEJUH
    AND T10.JIXIRIQI = '20201231'
    AND T10.dt = '20201231'
    WHERE T.DT = '20201231'
    AND (T2.OffsheetFlag = '1' OR T2.OffsheetFlag IS NULL)  -- 是否表内贷款
    AND T2.TypeNo NOT LIKE '20104020%'  --剔除信用卡和贴现业务
    AND (T1.FRZ_STS_CD <> '4' OR T1.FRZ_STS_CD IS NULL) --合同非终结
    AND (T.AGR_TYP_CD <> '3' OR T.AGR_TYP_CD IS NULL) --非转让
    AND T.prcp_bal > 0
    ;
**数据需求_20211108_王雪艳_小微地图错挂清单.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-08 15:49:30
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

SELECT
a.acg_dt as 数据日期
,a.sum_org_id as 分行机构号
,a.sum_org_nm as 分行名称
,a.brc_org_id as 支行机构号
,a.brc_org_nm as 支行名称
,a.manager_org_no as 部门机构号
,a.manager_org_nm as 部门名称
,a.cust_no as 客户号
,a.cust_name as 客户名称
,a.manager_no as 管户客户经理工号
,a.manager_name as 管户客户经理
,a.main_add_flag as 主地址类型
,a.main_add as 主地址地址
,cm1.com_code as 现挂靠子社区编号
,a.curr_com_name as 现挂靠子社区名称
,cm2.com_code as 系统匹配子社区编号
,a.sys_com_name as 系统匹配子社区名称
,a.sys_com_brc_name as 系统匹配子社区对应的支行名称
,a.sys_com_team_name as 系统匹配子社区对应的团队名称
,a.com_type as 挂靠类型
,a.put_up_date as 建档日期
,a.late_com_manager_no as 最近一次挂靠客户的客户经理工号
,a.late_com_time as 最近一次客户挂靠时间
from app_xwdt.XW_CUST_COM_ERROR_LIST  a
INNER JOIN  edw.XWDT_XW_COMMUNITY CM1 --普惠子社区挂卡-现挂靠(原挂靠无挂靠子社区名称非疑似错卦客户)
ON      a.curr_com_code = CM1.ID
AND     CM1.DT = '20211031'
INNER JOIN   edw.XWDT_XW_COMMUNITY CM2 --普惠子社区挂卡-系统
ON      a.sys_com_code = CM2.ID
AND     CM2.DT = '20211031'
where a.dt >= '20211001'
and a.dt <= '20211031'
;
**数据需求_20211108_陈灵球_我行手机号与对私客户号一对多情况.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-08 10:47:38
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 截止2021_10_31，我行手机号与对私客户号一对多情况：
-- 字段为，1_手机号与对私客户号一对多的个数，2_同手机号且同姓名情况下，存在多个对私客户号的个数


/*
T03_NOR_CUST_PHONE_INFO里面的PHONE_ID对应T02_NOR_CUST_CONTACT_REL的CONTACTS_ID   私
T03_ORG_CUST_PHONE_INFO里面的PHONE_ID对应T02_ORG_CUST_CONTACT_REL的CONTACTS_ID   公

T02_NOR_CUST_CONTACT_REL和T02_NOR_CUST_CONTACT_REL里面有PARTY_ID通过T00_NOR_CUST_NO_REC表转换成客户号
*/

drop table if exists lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_20211109;
create table if not exists lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_20211109 as
select a.phone_id as 电话ID
      ,a.phone as 电话号码
      ,b.cont_id as 联系ID
      ,c.cust_no as 客户号
      ,d.cst_id as 客户号1
      ,d.cst_chn_nm as 客户姓名
      ,b.cont_type as 联系类型
from edw.ecif_t03_nor_cust_phone_info a --对私客户联系电话信息表
left join edw.ecif_t02_nor_cust_contact_rel b on b.cont_id = a.phone_id and b.dt = a.dt   --对私参与人和联系信息的关系表
left join edw.ecif_t00_nor_cust_no_rec c on c.party_id = b.party_id and c.dt = b.dt    --对私客户号识别信息表
left join edw.dws_cst_bas_inf_dd d on d.cst_id = c.cust_no and d.dt = c.dt     --客户基础信息汇总表
where a.dt = '20211031'
and b.cont_way = '1' and b.cont_type = '010000'  -- cont_way = 1表示电话，cont_type=010000 表示手机号
;

select * from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_20211109;

-- 汇总有多少客户号
select count(*)  --7626927
from
(
select distinct 客户号,客户姓名,电话号码
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_20211109
)a
;

-- 筛选掉电话号码长度小于11的数据
select count(distinct 客户号)  -- 130721
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_20211109
where length(电话号码) < 11
;

-- 处理手机号码中的 +86-，+86，-86+ , &quot; 情况
drop table if exists lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109;
create table if not exists lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109 as
select distinct
      客户号
      ,客户姓名
      ,电话号码
      ,case
        when substr(电话号码,1,4) = '+86-' or substr(电话号码,1,3) = '+86' or substr(电话号码,1,4) = '-86+' or substr(电话号码,1,2) = '&quot;' then substr(电话号码,-1,11)
        else 电话号码 end 电话号码1
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_20211109
where length(电话号码) = 11
;

-- 汇总
select count(distinct 客户号)
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109;

select count(*)  -- 7593797
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109;

-- 手机号与对私客户号一对多的情况
select count(客户号)   --278915
from
(
select 客户号
      ,客户姓名
      ,电话号码
      ,电话号码1
      ,row_number()over(partition by 电话号码1 order by 客户号) as rn
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109
) a
where a.rn = 2
;

-- 手机号相同且同姓名的情况下，存在多个对私客户号的个数
select count(*)  -6021
from
(
select 客户号
      ,客户姓名
      ,电话号码1
      ,row_number()over(partition by 电话号码1,客户姓名 order by 客户号) as rn
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109
--order by 客户姓名 desc,电话号码1
) a
where a.rn = 2
;

-- 手机号码与对私客户号正常一对一的数量
select count(distinct 客户号)  --7046380
from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109
where 电话号码1 not in
(
      select 电话号码1
      from
      (
            select 客户号
                  ,客户姓名
                  ,电话号码
                  ,电话号码1
                  ,row_number()over(partition by 电话号码1 order by 客户号) as rn
            from lab_bigdata_dev.xt_024618_mobil_clq_zhongjianbiao_1_20211109
      ) a
      where a.rn = 2
)
;



-----------------------------------------------20211108------------------------------------------------------------------------
select a.cst_id AS 客户号
      ,a.cst_chn_nm AS 客户中文名称
      ,b.mbl_nbr as 手机号
      ,b.fml_tel_nbr as 家庭电话
      ,b.cmp_tel_nbr as 公司电话
from edw.dim_cst_idv_bas_inf_dd a  --个人客户基本信息
left join edw.dws_cst_bas_inf_dd b on a.cst_id = b.cst_id and b.dt = a.dt  --客户基础信息汇总表
where a.dt = '20211031'
and b.mbl_nbr = ''
;
-- 0.手机号为空的对私客户数
SELECT *  --COUNT(DISTINCT cst_id)
FROM edw.dws_cst_bas_inf_dd
WHERE DT = '20211031'
AND cst_typ_cd = '1'
AND mbl_nbr = ''
;
-- 1.手机号与对私客户号一对多的个数
SELECT a.*
FROM
(
SELECT cst_id AS 客户号
      ,cst_chn_nm AS 客户姓名
      ,mbl_nbr AS 手机
      ,fml_tel_nbr AS 家庭电话
      ,cmp_tel_nbr AS 公司电话
      ,ROW_NUMBER()OVER(PARTITION BY mbl_nbr ORDER BY cst_id) AS rn
FROM edw.dws_cst_bas_inf_dd
WHERE DT = '20211031'
AND cst_typ_cd = '1'
AND mbl_nbr <> ''
) a
WHERE a.rn = 2
;
-- 2.同手机号且同姓名情况下，存在多个对私客户号的个数

select a.cst_id AS 客户号
      ,a.cst_chn_nm AS 客户姓名
      ,a.mbl_nbr AS 手机
      ,a.fml_tel_nbr AS 家庭电话
      ,a.cmp_tel_nbr AS 公司电话
from edw.dws_cst_bas_inf_dd a
inner join edw.dws_cst_bas_inf_dd b on a.dt = b.dt and a.mbl_nbr = b.mbl_nbr and a.cst_chn_nm = b.cst_chn_nm
where a.dt = '20211031'
and a.cst_typ_cd = '1' --对私客户
and a.mbl_nbr <> ''
;
select cst_id AS 客户号
      ,cst_chn_nm AS 客户姓名
      ,mbl_nbr AS 手机
      ,fml_tel_nbr AS 家庭电话
      ,cmp_tel_nbr AS 公司电话
from edw.dws_cst_bas_inf_dd
where dt = '20211031'
and cst_id in ('1000000003','1000000004','1000000010')
;
**数据需求_20211117_陈敏敏_存款账户业绩分配相关的统计数据.sql
/*
需求人 ：陈敏敏
需求日期：20211117
提取存款账户业绩分配相关的统计数据
具体需求字段：
               客户数  账户笔数  账户合计金额  客户经理数
合计
同支行跨团队
同分行跨支行
跨分行
同一团队
以上分别统计单账户分润、多账户分润两种口径
筛选条件：账户状态：正常
*/
--------------------------------- STEP1 提取明细
DROP TABLE IF EXISTS lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117 AS
SELECT
      a.dep_act_id    --AS 存款账号
      ,a.cst_act_id    --AS 客户账号
      ,a.cst_id        --AS 客户号
      ,a.mgr_id        --AS 管护人编号
      ,d.brc_org_id    --AS 分行层级机构编号
      ,d.brc_org_nm    --AS 分行层级机构名称
      ,d.sbr_org_id    --AS 支行层级机构编号
      ,d.sbr_org_nm    --AS 支行层级机构名称
      ,d.tem_org_id    --AS 团队层级机构编号
      ,d.tem_org_nm    --AS 团队层级机构名称
      ,a.mgr_rto       --AS 管护比例
      --,a.gl_bal AS 总账余额
      ,CASE WHEN a.ccy_cd = '156' THEN a.gl_bal ELSE a.gl_bal*code2.avg_prc END AS amt
      --,a.ccy_cd AS 货币代码
FROM edw.dws_bus_dep_act_mgr_inf_dd a
LEFT JOIN edw.dim_bus_dep_act_inf_dd b ON b.dep_act_id = a.dep_act_id AND b.dt = a.dt
LEFT JOIN edw.dws_hr_empe_inf_dd c ON c.empe_id = a.mgr_id AND c.dt = a.dt
LEFT JOIN edw.dim_hr_org_mng_org_tree_dd d ON d.org_id = c.org_id AND d.dt = a.dt
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = b.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
LEFT JOIN edw.dim_bus_com_exr_inf_dd code2 ON a.ccy_cd = code2.ccy_cd AND code2.dt = a.dt
WHERE a.dt = '20211116'
AND code1.cd_val_dscr = '正常'  --筛选账户状态为正常
AND a.mgr_id NOT LIKE 'X%'
UNION ALL
SELECT
      a.dep_act_id    --AS 存款账号
      ,a.cst_act_id    --AS 客户账号
      ,a.cst_id        --AS 客户号
      ,a.mgr_id        --AS 管护人编号
      ,d.brc_org_id    --AS 分行层级机构编号
      ,d.brc_org_nm    --AS 分行层级机构名称
      ,d.sbr_org_id    --AS 支行层级机构编号
      ,d.sbr_org_nm    --AS 支行层级机构名称
      ,d.tem_org_id    --AS 团队层级机构编号
      ,d.tem_org_nm    --AS 团队层级机构名称
      ,a.mgr_rto       --AS 管护比例
      --,a.gl_bal AS 总账余额
      ,CASE WHEN a.ccy_cd = '156' THEN a.gl_bal ELSE a.gl_bal*code2.avg_prc END AS amt
      --,a.ccy_cd AS 货币代码
FROM edw.dws_bus_dep_act_mgr_inf_dd a
LEFT JOIN edw.dim_bus_dep_act_inf_dd b ON b.dep_act_id = a.dep_act_id AND b.dt = a.dt
LEFT JOIN edw.dws_hr_empe_inf_dd c ON c.empe_id = a.mgr_id AND c.dt = a.dt
LEFT JOIN edw.dim_hr_org_mng_org_tree_dd d ON d.org_id = SUBSTR(a.mgr_id,2,9) AND d.dt = a.dt
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = b.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
LEFT JOIN edw.dim_bus_com_exr_inf_dd code2 ON a.ccy_cd = code2.ccy_cd AND code2.dt = a.dt
WHERE a.dt = '20211116'
AND code1.cd_val_dscr = '正常'  --筛选账户状态为正常
AND a.mgr_id LIKE 'X%'
;

SELECT * FROM lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117;

--------------------------------- STEP2 加工数据
-- 1 单账户分润
-- 客户号 去重：同一客户号下，有多个账户存在分润情况，只统计为1
-- 账户号 不去重：
--金额：账户总额，不要重复计算
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------     单账户分润    ---------------------------------------------------------------------------
--    -------------------------------1. 跨分行------
SELECT '跨分行' as category
      ,COUNT(distinct cst_id) as cst_num
      ,count(distinct cst_dep_id) as cst_dep_num
      ,count(distinct mgr_id) as mgr_num
FROM lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
WHERE cst_act_id
IN (
SELECT cst_act_id
FROM
(
SELECT *
      ,DENSE_RANK()OVER(PARTITION BY cst_act_id ORDER BY brc_org_id) as brc_rn
FROM lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
WHERE mgr_rto < 1
)a
WHERE a.brc_rn = 2
)
;

SELECT '跨分行' as category
      ,sum(amt) as amt_sum
FROM
(
SELECT *,ROW_NUMBER()OVER(PARTITION BY cst_act_id ORDER BY mgr_id) as rn
FROM lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
WHERE cst_act_id
IN (
SELECT cst_act_id
FROM
(
SELECT *
      ,DENSE_RANK()OVER(PARTITION BY cst_act_id ORDER BY brc_org_id) as brc_rn
FROM lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
WHERE mgr_rto < 1
)a
WHERE a.brc_rn = 2
)
) b
WHERE b.rn = 1
;

--     --------------------- 2. 同分行跨支行---------------
select '同分行跨支行' as category
      ,count(distinct cst_id) as cst_num
      ,count(distinct cst_act_id) as cst_cat_num
      ,count(distinct mgr_id) as mgr_num
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_act_id in
(
select cst_act_id  --同分行跨支行账号
from
(
SELECT *
      ,dense_rank()OVER(PARTITION BY cst_act_id,brc_org_id ORDER BY sbr_org_id) as sbr_rn
FROM lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
WHERE mgr_rto < 1
)a
where a.sbr_rn = 2
)
;
-----
select '同分行跨支行' as category
      ,sum(amt) as amt_sum
from
(
select *,row_number()over(partition by cst_act_id order by mgr_id) as rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_act_id in
(
select cst_act_id  --同分行跨支行账号
from
(
SELECT *
      ,dense_rank()OVER(PARTITION BY cst_act_id,brc_org_id ORDER BY sbr_org_id) as sbr_rn
FROM lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
WHERE mgr_rto < 1
)a
where a.sbr_rn = 2
)
) b
where b.rn = 1
;

--  ----------------------  3. 同支行跨团队 ---------
select '同支行跨团队' as category
      ,count(distinct cst_id) as cst_num
      ,count(distinct cst_act_id) as cst_act_num
      ,count(distinct mgr_id) as mgr_num
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_act_id in
(
select cst_act_id   --同支行跨团队账号
from
(
select *,dense_rank()over(partition by cst_act_id,sbr_org_id order by tem_org_id) as tem_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto < 1
) a
where a.tem_rn = 2
)
;


select '同支行跨团队' as category
      ,sum(amt) as amt_sum
from
(
select *,row_number()over(partition by cst_act_id order by mgr_id) as rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_act_id in(
select cst_act_id   --同支行跨团队账号
from
(
select *,dense_rank()over(partition by cst_act_id,sbr_org_id order by tem_org_id) as tem_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto < 1
) a
where a.tem_rn = 2
)
) b
where rn = 1
;


--  ----------------------   4. 同团队  --------------
select '同团队' as category
      ,count(distinct cst_id) as cst_num
      ,count(distinct cst_act_id) as cst_act_num
      ,count(distinct mgr_id) as mgr_num
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_act_id in (
select cst_act_id
from
(
select *,dense_rank()over(partition by cst_act_id,tem_org_id order by mgr_id) as mgr_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto < 1
) a
where a.mgr_rn = 2
)
;


select '同团队' as category
      ,sum(amt) as amt_sum
from
(
select *,row_number()over(partition by cst_act_id order by mgr_id) as rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_act_id in (
select cst_act_id
from
(
select *,dense_rank()over(partition by cst_act_id,tem_org_id order by mgr_id) as mgr_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto < 1
) a
where a.mgr_rn = 2
)
) b
where b.rn = 1
;




----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------多账户------------------------------------------------------------
-- ------------1. 跨分行 ---------------------
/*
同一个客户号，如果名下的客户账号存在客户经理所属分行不一致，则计入
*/
select '跨分行' as category
      ,count(distinct cst_id) as cst_num
      ,count(distinct cst_act_id) as cst_act_num
      ,count(distinct mgr_id) as mgr_num
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id in (
SELECT cst_id    --客户经理跨分行的客户号
from
(
select *,dense_rank()over(partition by cst_id order by brc_org_id) as brc_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.brc_rn = 2
)
;


select '跨分行' as category
      ,sum(amt) as amt_sum
from
(
select *,row_number()over(partition by cst_act_id order by mgr_id) as rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id in (
SELECT cst_id    --客户经理跨分行的客户号
from
(
select *,dense_rank()over(partition by cst_id order by brc_org_id) as brc_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.brc_rn = 2
)
) b
where b.rn = 1
;


--  ------------ 2. 同分行跨支行  -------------------
select '同分行跨支行' as category
      ,count(distinct cst_id) as cst_num
      ,count(distinct cst_act_id) as cst_act_num
      ,count(distinct mgr_id) as mgr_num
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id IN (
select cst_id  --名下客户账号的客户经理同分行跨支行的客户号
from (
select *,dense_rank()over(partition by cst_id,brc_org_id order by sbr_org_id) as sbr_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.sbr_rn = 2
)
;


select '同分行跨支行' as category
      ,sum(amt) as amt_sum
from
(
select *,row_number()over(partition by cst_act_id order by mgr_id) as rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id IN (
select cst_id  --名下客户账号的客户经理同分行跨支行的客户号
from (
select *,dense_rank()over(partition by cst_id,brc_org_id order by sbr_org_id) as sbr_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.sbr_rn = 2
)
) b
where b.rn = 1
;



--  ------------------------ 3.同支行跨团队 --------------------------
select '同支行跨团队' as category
      ,count(distinct cst_id) as cst_num
      ,count(distinct cst_act_id) as cst_act_num
      ,count(distinct mgr_id) as mgr_num
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id in
(
select cst_id   --同支行跨团队账号
from
(
select *,dense_rank()over(partition by cst_id,sbr_org_id order by tem_org_id) as tem_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.tem_rn = 2
)
;


select '同支行跨团队' as category
      ,sum(amt) as amt_sum
from
(
select *,row_number()over(partition by cst_act_id order by mgr_id) as rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id in(
select cst_id   --同支行跨团队账号
from
(
select *,dense_rank()over(partition by cst_id,sbr_org_id order by tem_org_id) as tem_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.tem_rn = 2
)
) b
where rn = 1
;


--  ---------------------- 4. 同团队 -----------------
select '同团队' as category
      ,count(distinct cst_id) as cst_num
      ,count(distinct cst_act_id) as cst_act_num
      ,count(distinct mgr_id) as mgr_num
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id in (
select cst_id
from
(
select *,dense_rank()over(partition by cst_id,tem_org_id order by mgr_id) as mgr_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.mgr_rn = 2
)
;


select '同团队' as category
      ,sum(amt) as amt_sum
from
(
select *,row_number()over(partition by cst_act_id order by mgr_id) as rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where cst_id in (
select cst_id
from
(
select *,dense_rank()over(partition by cst_id,tem_org_id order by mgr_id) as mgr_rn
from lab_bigdata_dev.xt_024618_tmp_cmm_1_20211117
where mgr_rto = 1
) a
where a.mgr_rn = 2
)
) b
where b.rn = 1
;
**数据需求_20211118_刘昕博_是否存在异地客户借道结汇情况.sql
-- ODPS SQL 临时查询
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-03 13:36:52
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select trf_cstno,trf_product,交易流水最后更新时间,用户提交时间 from lab_bigdata_dev.xt_024618_tmp_lxb_20211119;

drop table if exists lab_bigdata_dev.xt_024618_tmp_lxb_20211119;
create table if not exists lab_bigdata_dev.xt_024618_tmp_lxb_20211119 as
select a.trf_cstno
      ,a.trf_product
      ,a.trf_lastupdatetime as 交易流水最后更新时间
      ,a.trf_subtime as 用户提交时间
from edw.ebnk_pb_tranflow a
--left join edw.outd_lm_ip_info b on
where a.dt >= '20210501' and a.dt <= '20211031'
and trf_cstno in
(
    '1644356902'
,'1644378069'
,'1644385970'
,'1644454282'
,'1644485649'
,'1644499210'
,'1644501622'
,'1644524248'
,'1644559157'
,'1644624637'
,'1644720206'
,'1644730775'
,'1644763810'
,'1644824874'
,'1644866251'
,'1644887545'
,'1644938131'
,'1644972321'
,'1644991328'
,'1645086935'
,'1645092007'
,'1645092508'
,'1645148711'
,'1645157231'
,'1645157833'
,'1645188945'
,'1645235893'
,'1645240601'
,'1645248778'
,'1645270483'
,'1645276237'
,'1645404257'
,'1645445947'
,'1645457491'
,'1645493557'
,'1645509772'
,'1645537891'
,'1645575279'
,'1645584901'
,'1645586324'
,'1645637606'
,'1645641785'
,'1645647108'
,'1645667013'
,'1645719819'
,'1645722806'
,'1645829041'
,'1645851916'
,'1645863732'
,'1645934156'
,'1645937170'
,'1645960926'
,'1645987601'
,'1645990938'
,'1646016904'
,'1646023161'
,'1646107096'
,'1646148301'
,'1646318132'
,'1646341404'
,'1646374185'
,'1646402872'
,'1646408629'
,'1646413022'
,'1646415266'
,'1646437670'
,'1646535637'
,'1646579631'
,'1646658141'
,'1646739849'
,'1646750811'
,'1646755701'
,'1646768977'
,'1646836687'
,'1646858344'
,'1646860924'
,'1646862670'
,'1646878360'
,'1647023134'
,'1647028633'
,'1647087914'
,'1647098096'
,'1647193816'
,'1647282669'
,'1647304195'
,'1647314248'
,'1647330060'
,'1647436779'
,'1647441232'
,'1647481805'
,'1647809396'
,'1647974528'
,'1648014366'
,'1648018298'
,'1648018762'
,'1648032024'
,'1648033568'
,'1648037456'
,'1648044815'
,'1648085133'
,'1648090027'
,'1648177595'
,'1648190383'
,'1648200032'
,'1648214855'
,'1648513449'
,'1648717752'
,'1648740288'
,'1648792152'
,'1648881792'
,'1648883843'
,'1648969641'
,'1649003300'
,'1649005335'
,'1649021648'
,'1649038395'
,'1649042128'
,'1649395456'
,'1649414032'
,'1649439231'
,'1649445871'
,'1649469691'
,'1649485748'
,'1649487968'
,'1649667902'
,'1649698910'
,'1649781510'
,'1649863088'
,'1649910987'
,'1649927907'
,'1650018910'
,'1650053423'
,'1650072565'
,'1650085409'
,'1650088965'
,'1650278879'
,'1650307626'
,'1650314208'
,'1650316062'
,'1650336593'
,'1650343427'
,'1650348392'
,'1650379241'
,'1650487009'
,'1650500406'
,'1650542648'
,'1650559751'
,'1650567881'
,'1650586127'
,'1650657480'
,'1650665670'
,'1650669941'
,'1650707753'
,'1650711154'
,'1650814519'
,'1650938574'
,'1650947443'
,'1650951379'
,'1650963043'
,'1650964422'
,'1650967533'
,'1650983439'
,'1650983752'
,'1651031958'
,'1651046162'
,'1651110596'
,'1651112230'
,'1651199034'
,'1651284954'
,'1651310550'
,'1651322282'
,'1651402725'
,'1651429555'
,'1651436904'
,'1651489893'
,'1651505505'
,'1651522545'
,'1651526900'
,'1651601125'
,'1651639778'
,'1651645086'
,'1651648187'
,'1651722866'
,'1651740110'
,'1651741382'
,'1651749592'
,'1651750537'
,'1651791356'
,'1651816972'
,'1651830523'
,'1651850876'
,'1651857605'
,'1651875069'
,'1651892855'
,'1651903944'
,'1651904300'
,'1651919304'
,'1651923086'
,'1651935379'
,'1652022318'
,'1652096678'
,'1652105826'
,'1652138489'
,'1652149373'
,'1652171273'
,'1652173314'
,'1652188106'
,'1652194982'
,'1652208580'
,'1652310278'
,'1652380995'
,'1652398124'
,'1652473018'
,'1652497575'
,'1652500020'
,'1652508681'
,'1652519346'
,'1652530860'
,'1652556341'
,'1652589817'
,'1652593575'
,'1652604096'
,'1652614515'
,'1652614956'
,'1652778127'
,'1652828795'
,'1652877760'
,'1652907704'
,'1652911563'
,'1653109392'
,'1653275362'
,'1653294412'
,'1653301721'
,'1653312360'
,'1653416115'
,'1653446437'
,'1653474616'
,'1653581002'
,'1653608501'
,'1653671191'
,'1653702881'
,'1653744393'
,'1653787424'
,'1653793115'
,'1653857761'
,'1653919231'
,'1653986050'
,'1654024118'
,'1654040411'
,'1654048961'
,'1654182019'
,'1654191071'
,'1654211910'
,'1654237358'
,'1654238111'
,'1654290945'
,'1654359320'
,'1654418484'
,'1654451210'
,'1654451906'
,'1654532754'
,'1654561492'
,'1654585897'
,'1654660612'
,'1654846390'
,'1654879230'
,'1654902922'
,'1655023157'
,'1655041697'
,'1655147917'
,'1655158445'
,'1655177883'
,'1655205685'
,'1655218890'
,'1655253793'
,'1655292493'
,'1655326436'
,'1655338777'
,'1655367618'
,'1655377443'
,'1655474536'
,'1655592382'
,'1655594500'
,'1655634922'
,'1655647831'
,'1655685953'
,'1655763192'
,'1655775256'
,'1655824722'
,'1655909901'
,'1655993820'
,'1656154275'
,'1656221715'
,'1656224460'
,'1656226145'
,'1656293421'
,'1656351791'
,'1656368335'
,'1656385570'
,'1656388115'
,'1656462609'
,'1656507511'
,'1656543517'
,'1656552986'
,'1656553561'
,'1656615176'
,'1656645168'
,'1656674679'
,'1656684198'
,'1656685240'
,'1656829602'
,'1656893539'
,'1656896886'
,'1656900384'
,'1657047082'
,'1657068073'
,'1657086309'
,'1657092277'
,'1657094345'
,'1657103595'
,'1657145167'
,'1657146997'
,'1657147457'
,'1657187587'
,'1668621490'
,'1668623958'
,'1668628424'
,'1668633766'
,'1668654542'
,'1668666869'
,'1668684409'
,'1668727889'
,'1668746515'
,'1668812268'
,'1668828745'
,'1668876894'
,'1668885686'
,'1668887051'
,'1668899835'
,'1668923016'
,'1668928811'
,'1668946971'
,'1668948834'
,'1668966630'
,'1668980653'
,'1668989441'
,'1668993333'
,'1669025761'
,'1669108747'
,'1669111021'
,'1669167756'
,'1669175677'
,'1669205611'
,'1669212123'
,'1669218429'
,'1669227228'
,'1669231722'
,'1669308695'
,'1669327456'
,'1669335602'
,'1669381050'
,'1669464120'
,'1669519052'
,'1669541894'
,'1669548166'
,'1669551567'
,'1669587862'
,'1669613504'
,'1669623895'
,'1669718757'
,'1669726015'
,'1670230626'
,'1670242035'
,'1670280988'
,'1670291135'
,'1670297865'
,'1670347688'
,'1670410907'
,'1670473249'
,'1670582904'
,'1670602056'
,'1670613956'
,'1670622156'
,'1670622536'
,'1670707776'
,'1670751010'
,'1670775526'
,'1670831495'
,'1670842981'
,'1670921450'
,'1670941304'
,'1670941880'
,'1670985181'
,'1670998793'
,'1671162261'
,'1671188893'
,'1671267769'
,'1671348896'
,'1671421789'
,'1671624339'
,'1671645862'
,'1671849233'
,'1672023374'
,'1672047786'
,'1672115072'
,'1672115159'
,'1672177363'
,'1672187780'
,'1672207704'
,'1672213624'
,'1672269037'
,'1672271184'
,'1672284799'
,'1672290759'
,'1672292895'
,'1672362208'
,'1672704161'
,'1672772718'
,'1672774353'
,'1672852829'
,'1672852923'
,'1672858540'
,'1672862909'
,'1673028786'
,'1673123100'
,'1673133077'
);
**数据需求_20211122_绍兴诸暨小微支行_存量个人银行结算账户风险排查及管控数据.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-22 09:44:56
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
诸暨区域（330700900+330700500）存量个人银行结算账户风险排查及管控数据需求
泰隆诸暨区域（机构号为330700900+330700500）存量个人银行结算账户风险排查及管控情况表，具体需要数据需求前提为开户在诸暨区域330700900和330700500名下的账户：
    1存量账户 12 个月未发生资金收付，管控措施（限制非柜面、只收不付、不收不付等）的账户户数.
    2.存量账户 24 个月未发生资金收付,管控措施（限制非柜面、只收不付、不收不付等）的账户户数。
    3.存量账户 36 个月未发生资金收付，管控措施（限制非柜面、只收不付、不收不付等）的账户户数。
以上数据请再提拱数据源清单。
*/
--   -------------- 1存量账户 12 个月未发生资金收付，管控措施（限制非柜面、只收不付、不收不付等）的账户户数.
drop table if exists lab_bigdata_dev.xt_024618_tmp_sxzj_12mon_1_21211122;
create table if not exists lab_bigdata_dev.xt_024618_tmp_sxzj_12mon_1_21211122 as
select a.cst_id as 客户号
      ,a.cst_act_id as 客户账号
      ,code1.cd_val_dscr as 账户状态
      ,a.opn_org as 开户机构
      ,case
         when b.cst_act_id is not null then '是'
         else '否'
      end 是否暂停非柜面
      --,c.zhjedjbz as 账户金额冻结标志
      --,c.zhfbdjbz as 账户封闭冻结标志
      --,c.zhzsbfbz as 账户只收不付标志
      --,c.zhzfbsbz as 账户只付不收标志
      ,case when c.zhjedjbz = '1' then '是' when c.zhjedjbz = '0' then '否' else c.zhjedjbz end 是否账户金额冻结
      ,case when c.zhfbdjbz = '1' then '是' when c.zhfbdjbz = '0' then '否' else c.zhfbdjbz end 是否账户封闭冻结
      ,case when c.zhzsbfbz = '1' then '是' when c.zhzsbfbz = '0' then '否' else c.zhzsbfbz end 是否账户只收不付
      ,case when c.zhzfbsbz = '1' then '是' when c.zhzfbsbz = '0' then '否' else c.zhzfbsbz end 是否账户只付不收
from edw.dws_bus_dep_act_inf_dd a  --存款账户信息汇总
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = a.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
left join
(
    SELECT CST_ACT_ID
          ,MIN(LMT_EFT_DT) AS LMT_EFT_DT  --额度生效日期
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20211116'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
) b on b.CST_ACT_ID = a.cst_act_id
left join edw.core_kdpa_kehuzh c on c.kehuzhao = a.cst_act_id and c.dt = a.dt
where a.dt = '20211116'
and a.stl_act_ind ='1' --结算标志为1
and a.opn_org in ('330700900','330700500')  --机构号选取绍兴诸暨
and a.act_sts_cd NOT IN ( 'C' ) --排除销户
and a.cst_tp='1' --对私
and a.cst_act_id NOT IN (
                                 SELECT  DISTINCT cst_act_id
                                 FROM    edw.dwd_bus_dep_bal_chg_dtl_di
                                 WHERE   smr_dscr NOT LIKE '%付息%'
                                 AND     smr_dscr NOT LIKE '%结息%'
                                 AND     txt_code NOT IN ( 'DP1000' , 'DP0210' )
                                 AND     trx_amt > 0
                                 AND     dt >= '20201116'
                                 AND     dt <= '20211116'
                                 AND     trx_dt >= '20201116'
                                 AND     trx_dt <= '20211116'
                             )   -- 最近12个月未发生收付业务
;


select sum(标志)
FROM
(
select 客户账号,case when 是否暂停非柜面='是' or 是否账户金额冻结='是' or 是否账户封闭冻结 = '是' or 是否账户只收不付 = '是' or 是否账户只付不收 = '是' then 1 else 0 end as 标志
from lab_bigdata_dev.xt_024618_tmp_sxzj_12mon_1_21211122
) a;




--   -------------- 2存量账户 24个月未发生资金收付，管控措施（限制非柜面、只收不付、不收不付等）的账户户数.
drop table if exists lab_bigdata_dev.xt_024618_tmp_sxzj_24mon_2_21211122;
create table if not exists lab_bigdata_dev.xt_024618_tmp_sxzj_24mon_2_21211122 as
select a.cst_id as 客户号
      ,a.cst_act_id as 客户账号
      ,code1.cd_val_dscr as 账户状态
      ,a.opn_org as 开户机构
      ,case
         when b.cst_act_id is not null then '是'
         else '否'
      end 是否暂停非柜面
      --,c.zhjedjbz as 账户金额冻结标志
      --,c.zhfbdjbz as 账户封闭冻结标志
      --,c.zhzsbfbz as 账户只收不付标志
      --,c.zhzfbsbz as 账户只付不收标志
      ,case when c.zhjedjbz = '1' then '是' when c.zhjedjbz = '0' then '否' else c.zhjedjbz end 是否账户金额冻结
      ,case when c.zhfbdjbz = '1' then '是' when c.zhfbdjbz = '0' then '否' else c.zhfbdjbz end 是否账户封闭冻结
      ,case when c.zhzsbfbz = '1' then '是' when c.zhzsbfbz = '0' then '否' else c.zhzsbfbz end 是否账户只收不付
      ,case when c.zhzfbsbz = '1' then '是' when c.zhzfbsbz = '0' then '否' else c.zhzfbsbz end 是否账户只付不收
from edw.dws_bus_dep_act_inf_dd a
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = a.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
left join
(
    SELECT CST_ACT_ID
          ,MIN(LMT_EFT_DT) AS LMT_EFT_DT  --额度生效日期
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20211116'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
) b on b.CST_ACT_ID = a.cst_act_id
left join edw.core_kdpa_kehuzh c on c.kehuzhao = a.cst_act_id and c.dt = a.dt
where a.dt = '20211116'
and a.stl_act_ind ='1' --结算标志为1
and a.opn_org in ('330700900','330700500')  --机构号选取绍兴诸暨
and a.act_sts_cd NOT IN ( 'C' ) --排除销户
and a.cst_tp='1' --对私
and a.cst_act_id NOT IN (
                                 SELECT  DISTINCT cst_act_id
                                 FROM    edw.dwd_bus_dep_bal_chg_dtl_di
                                 WHERE   smr_dscr NOT LIKE '%付息%'
                                 AND     smr_dscr NOT LIKE '%结息%'
                                 AND     txt_code NOT IN ( 'DP1000' , 'DP0210' )
                                 AND     trx_amt > 0
                                 AND     dt >= '20191116'
                                 AND     dt <= '20211116'
                                 AND     trx_dt >= '20191116'
                                 AND     trx_dt <= '20211116'
                             )   -- 最近24个月未发生收付业务
;

----------
select sum(标志)
FROM
(
select 客户账号,case when 是否暂停非柜面='是' or 是否账户金额冻结='是' or 是否账户封闭冻结 = '是' or 是否账户只收不付 = '是' or 是否账户只付不收 = '是' then 1 else 0 end as 标志
from lab_bigdata_dev.xt_024618_tmp_sxzj_24mon_2_21211122
) a;





--   -------------- 3存量账户 36个月未发生资金收付，管控措施（限制非柜面、只收不付、不收不付等）的账户户数.
drop table if exists lab_bigdata_dev.xt_024618_tmp_sxzj_36mon_3_21211122;
create table if not exists lab_bigdata_dev.xt_024618_tmp_sxzj_36mon_3_21211122 as
select a.cst_id as 客户号
      ,a.cst_act_id as 客户账号
      ,code1.cd_val_dscr as 账户状态
      ,a.opn_org as 开户机构
      ,case
         when b.cst_act_id is not null then '是'
         else '否'
      end 是否暂停非柜面
      --,c.zhjedjbz as 账户金额冻结标志
      --,c.zhfbdjbz as 账户封闭冻结标志
      --,c.zhzsbfbz as 账户只收不付标志
      --,c.zhzfbsbz as 账户只付不收标志
      ,case when c.zhjedjbz = '1' then '是' when c.zhjedjbz = '0' then '否' else c.zhjedjbz end 是否账户金额冻结
      ,case when c.zhfbdjbz = '1' then '是' when c.zhfbdjbz = '0' then '否' else c.zhfbdjbz end 是否账户封闭冻结
      ,case when c.zhzsbfbz = '1' then '是' when c.zhzsbfbz = '0' then '否' else c.zhzsbfbz end 是否账户只收不付
      ,case when c.zhzfbsbz = '1' then '是' when c.zhzfbsbz = '0' then '否' else c.zhzfbsbz end 是否账户只付不收
from edw.dws_bus_dep_act_inf_dd a
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = a.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
left join
(
    SELECT CST_ACT_ID
          ,MIN(LMT_EFT_DT) AS LMT_EFT_DT  --额度生效日期
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20211116'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
) b on b.CST_ACT_ID = a.cst_act_id
left join edw.core_kdpa_kehuzh c on c.kehuzhao = a.cst_act_id and c.dt = a.dt
where a.dt = '20211116'
and a.stl_act_ind ='1' --结算标志为1
and a.opn_org in ('330700900','330700500')  --机构号选取绍兴诸暨
and a.act_sts_cd NOT IN ( 'C' ) --排除销户
and a.cst_tp='1' --对私
and a.cst_act_id NOT IN (
                                 SELECT  DISTINCT cst_act_id
                                 FROM    edw.dwd_bus_dep_bal_chg_dtl_di
                                 WHERE   smr_dscr NOT LIKE '%付息%'
                                 AND     smr_dscr NOT LIKE '%结息%'
                                 AND     txt_code NOT IN ( 'DP1000' , 'DP0210' )
                                 AND     trx_amt > 0
                                 AND     dt >= '20181116'
                                 AND     dt <= '20211116'
                                 AND     trx_dt >= '20181116'
                                 AND     trx_dt <= '20211116'
                             )   -- 最近36个月未发生收付业务
;

--------------
select sum(标志)
FROM
(
select 客户账号,case when 是否暂停非柜面='是' or 是否账户金额冻结='是' or 是否账户封闭冻结 = '是' or 是否账户只收不付 = '是' or 是否账户只付不收 = '是' then 1 else 0 end as 标志
from lab_bigdata_dev.xt_024618_tmp_sxzj_36mon_3_21211122
) a;
**数据需求_20211123_钱雪颖_日计表每日科目金额.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-23 15:33:44
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
20211123 钱雪莉 总行资金营运中心票据业务部
用于票据业务分析
数据仓库，以下科目每日余额
以上科目分总行和资金营运中心机构口径分别取
*/
drop table if exists lab_bigdata_dev.xt_024618_tmp_piaoju_3_20211124;
create table if not exists lab_bigdata_dev.xt_024618_tmp_piaoju_3_20211124 as
select ACG_DT  会计日期
    ,ACG_ITM_ID  会计科目编号
    --,ACG_ITM_NM   会计科目名称
    --,ACG_ITM_LVL  会计科目级别
    ,sum(CUR_CR_BAL) 本期贷方余额
    ,sum(CUR_DB_BAL) 本期借方余额
from app_rpt.fct_fct_acg_itm_bal
where dt <= '20211123' and dt >= '20210101'
and CCY_CD = '156' --筛选为人民币
and DATA_PRD_CD = '1' --筛选为日记账
and ORG_ID = '999999998'
and ACG_ITM_ID in
(
    '111101'
,'11110102'
,'11110199'
,'1305'
,'130501'
,'13050101'
,'13050102'
,'13050104'
,'13050105'
,'13050106'
,'130502'
,'13050201'
,'13050202'
,'13050204'
,'13050205'
,'13050206'
,'130503'
,'13050301'
,'13050302'
,'13050304'
,'13050305'
,'13050306'
,'2022'
,'202201'
,'20220102'
,'20220103'
,'2023'
,'202301'
,'20230101'
,'211101'
,'21110102'
,'21110199'
,'601102'
,'60110201'
,'60120501'
,'601206'
,'60120601'
,'601207'
,'60120701'
,'641202'
,'64120201'
,'641203'
,'64120301'
,'64120701'
,'64120801'
)
group by ACG_DT,ACG_ITM_ID
;





drop table if exists lab_bigdata_dev.xt_024618_tmp_piaoju_2_20211124;
create table if not exists lab_bigdata_dev.xt_024618_tmp_piaoju_2_20211124 as
select '浙江泰隆商业银行总行清算中心' as 口径
      ,交易日期
      ,科目号
      ,sum(本期借方余额) 借方余额
      ,sum(本期贷方余额) 贷方余额
from lab_bigdata_dev.xt_024618_tmp_piaoju_1_20211124
where 报表机构号 = '999999999'
group by 交易日期,科目号
union
select '资金营运中心' as 口径
      ,交易日期
      ,科目号
      ,sum(本期借方余额) 借方余额
      ,sum(本期贷方余额) 贷方余额
from lab_bigdata_dev.xt_024618_tmp_piaoju_1_20211124
where 机构名称 like '%资金营运%'
group by 交易日期,科目号
;

select 口径,交易日期,科目号,借方余额,贷方余额 from lab_bigdata_dev.xt_024618_tmp_piaoju_2_20211124;

-- 取票据号为1305
drop table if exists lab_bigdata_dev.xt_024618_tmp_piaoju_1305_20211124;
create table if not exists lab_bigdata_dev.xt_024618_tmp_piaoju_1305_20211124 as
select *
from lab_bigdata_dev.xt_024618_tmp_piaoju_1_20211124
where 科目号 = '1305'
;


drop table if exists lab_bigdata_dev.xt_024618_tmp_piaoju_1_20211124;
create table if not exists lab_bigdata_dev.xt_024618_tmp_piaoju_1_20211124 as
select a.baobleix as 报表类型
      ,a.jiaoyirq as 交易日期
      ,a.bbjigouh as 报表机构号
      ,a.zongzquj as 总账区间
      ,b.org_nm   as 机构名称
      ,a.baobbizh as 报表币种
      ,a.kemuhaoo as 科目号
      ,a.bqijfyue as 本期借方余额
      ,a.bqidfyue as 本期贷方余额
from edw.core_kglb_zongzh a
left join edw.dim_hr_org_mng_org_tree_dd b on b.org_id = a.bbjigouh and b.dt = a.dt
where a.dt >= '20210101' and a.dt <= '20211123'
and a.jiaoyirq >= '20210101' and a.jiaoyirq <= '20211123'
--and b.org_nm like '%资金营运%'
and a.zongzquj = '0'  --取总账区间为日总账
and a.baobbizh = '156' --取报表币种为 156
and a.kemuhaoo in
(
    '111101'
,'11110102'
,'11110199'
,'1305'
,'130501'
,'13050101'
,'13050102'
,'13050104'
,'13050105'
,'13050106'
,'130502'
,'13050201'
,'13050202'
,'13050204'
,'13050205'
,'13050206'
,'130503'
,'13050301'
,'13050302'
,'13050304'
,'13050305'
,'13050306'
,'2022'
,'202201'
,'20220102'
,'20220103'
,'2023'
,'202301'
,'20230101'
,'211101'
,'21110102'
,'21110199'
,'601102'
,'60110201'
,'60120501'
,'601206'
,'60120601'
,'601207'
,'60120701'
,'641202'
,'64120201'
,'641203'
,'64120301'
,'64120701'
,'64120801'
)
;
**数据需求_20211124_景斐斐_信贷系统与卡系统证件有效期不一致统计.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-24 16:30:11
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
20211124 景斐斐 线上化项目组网申卡小组
信贷系统与卡系统客户证件有效期不一致的客户名单
1.在进行批量提额是发现信贷系统与卡系统两个系统存在客户证件有效期不一致的情况，导致有部分客户批量提额失败，需要批量去更新卡系统的证件有效期;共计130个客户。该部分因为要做提额，所以比较急
2.同时需要全面排查目前信贷系统和卡系统中有多少客户证件有效期不一致，需要导出所有不一致的数据
字段详见附件130个客户的字段需求
*/

select c.customerid,c.certtype,c.certid,certenddate
      ,case when substr(c.certenddate,5,1) = '/' then concat(substr(c.certenddate,1,4),substr(c.certenddate,6,2),substr(c.certenddate,9,2)) else c.certenddate end as 信贷证件到期日
from edw.loan_ind_info c
where dt = '20211124'
and certid = '330802198503021620'
;

select c.customerid,c.certtype,c.certid,certenddate
,concat(substr(c.certenddate,1,4),substr(c.certenddate,6,2),substr(c.certenddate,9,2)) as 信贷证件到期日
--,concat(substr(to_str(c.certenddate),1,4),substr(str(c.certenddate),6,2),substr(str(c.certenddate),9,2)) as 信贷证件到期日1
from edw.loan_ind_info c
where dt = '20211123'
and length(c.certenddate) = 11


-- 加工底表
drop table if exists lab_bigdata_dev.xt_024618_tmp_jff_nbr_20211124;
create table if not exists lab_bigdata_dev.xt_024618_tmp_jff_nbr_20211124 as
select a.cst_id
      ,c.certtype      as 信贷证件类型
      ,c.certid        as 信贷证件号码
      ,c.certenddate
      ,case when substr(c.certenddate,5,1) = '/' then concat(substr(c.certenddate,1,4),substr(c.certenddate,6,2),substr(c.certenddate,9,2)) else c.certenddate end as 信贷证件到期日
      ,case when substr(c.certstartdate,5,1) = '/' then concat(substr(c.certstartdate,1,4),substr(c.certstartdate,6,2),substr(c.certstartdate,9,2)) else c.certstartdate end as 信贷证件起始日
      ,b.race_code as 卡系统证件类型
      ,b.custr_nbr as 卡系统证件号码
      ,b.id_dte  as 卡系统身份证件有效期
      ,b.idlt_yn as 卡系统证件长期有效标识
from edw.dim_cst_bas_doc_inf_dd a
left join edw.ncrd_custr b on b.custr_nbr = a.doc_nbr and b.dt = a.dt
left join edw.loan_ind_info c on c.customerid = a.cst_id and c.dt = a.dt
where a.dt = '20211124'
;
select * from lab_bigdata_dev.xt_024618_tmp_jff_nbr_20211124 where 信贷证件号码 = '330802198503021620';


-- 证件有效期不一致的全量客户，不包括任一系统证件有效期缺失的数据
drop table if exists lab_bigdata_dev.xt_024618_tmp_jff_nbr_1_20211124;
create table if not exists lab_bigdata_dev.xt_024618_tmp_jff_nbr_1_20211124 as
select a.*
from
(
select * ,case when 信贷证件到期日=卡系统身份证件有效期 then '0' else '1' end as biaozhi
from lab_bigdata_dev.xt_024618_tmp_jff_nbr_20211124
) a
where a.biaozhi = '1'
and not (a.信贷证件到期日 is null or a.卡系统身份证件有效期 is null)
;

select * from lab_bigdata_dev.xt_024618_tmp_jff_nbr_1_20211124;


-- 名单内客户
drop table if exists lab_bigdata_dev.xt_024618_tmp_jff_nbr_2_20211124;
create table if not exists lab_bigdata_dev.xt_024618_tmp_jff_nbr_2_20211124 as
select * from lab_bigdata_dev.xt_024618_tmp_jff_nbr_20211124 where cst_id in
(
 '1024284434','1626340043','1607540473','1041166348','1027879970','1040558087','1018982467','1631677682','1623262986','1012377557','1000032599','1607322315'
,'1613457888','1628098292','1027366274','1615643871','1027623610','1606077096','1623587441','1003033594','1029500722','1627752534','1612997171','1032017574'
,'1605993197','1013461433','1616128229','1604445454','1638063920','1620703379','1014219022','1612662780','1029825270','1023217394','1036766058','1040963151'
,'1609361756','1041229225','1611917419','1022660407','1609370565','1633047111','1011608951','1031323830','1617700354','1616354610','1044467576','1624154575'
,'1023474201','1615058266','1023964850','1637955492','1000161987','1613727876','1605085924','1628776832','1035642296','1626299685','1029146638','1601823936'
,'1604042458','1615422899','1616170287','1626875431','1041719393','1610241257','1612799917','1608527574','1039037223','1016465258','1616666113','1613372080'
,'1044822311','1624644714','1035408861','1615658518','1635029931','1616351957','1012685771','1622154537','1615598784','1035442478','1019138485','1600748429'
,'1628387855','1613534009','1622993938','1014638841','1632333194','1615491015','1043452931','1604580900','1623888211','1045759070','1044263675','1604492489'
,'1615488890','1632976205','1019343849','1025742355','1616054093','1611324042','1606062492','1018437587','1626773922','1628632025','1635176531','1018379155'
,'1026417690','1040985627','1619271874','1616548903','1612200873','1611829566','1613601464','1013906811','1009407867','1620975950','1611866265','1629717134'
,'1622639927','1618888731','1010336862','1611306579','1623337358','1613925418','1043742779','1614446940','1608306655','1610645813')
;

select * from lab_bigdata_dev.xt_024618_tmp_jff_nbr_2_20211124;
**数据需求_20211125_杨璐璐_计财部_网银单笔额度单日累计额度.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-25 15:21:09
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
全行网银单笔额度500万以上、单日累计额度5000万以上客户清单
（日常、月末、季末时点，包括20221.9.30、2021.10.31、2021.11.1、2021.11.2、2021.11.23、2021.11.24的每日客户清单，单独列）
需求字段：日期、客户编码、客户名称、所在机构、管户人、单笔限额、单日累计限额
*/
-- 加工客户是否销户
drop table if exists lab_bigdata_dev.xt_024618_tmp_1_outlimit_20211125;
create table if not exists lab_bigdata_dev.xt_024618_tmp_1_outlimit_20211125 as
select bb.网银客户号
      ,bb.客户类型
      ,case when bb.是否销户 = '1' then '未销户' else '已销户' end as 是否是销户客户
from
(
select *,row_number()over(partition by 网银客户号 order by 是否销户 desc) as rn
from
(
select a.pcc_cstno as 网银客户号
      ,'个人' as 客户类型
      ,c.kehuzhao  as 客户账号
      ,c.zhhuztai  as 状态代码
      ,case when c.zhhuztai = 'C' then '0' else '1' end as 是否销户 --0销户，1未销户
from edw.ebnk_pb_cstinf_channel a
left join edw.core_kdpa_kehuzh c on c.kehuhaoo = a.pcc_cstno and c.dt = a.dt
where a.dt in ('20181231','20191231','20201231','20210930','20211031','20211101','20211102','20211123','20211124')
union all
select a.cci_cstno as 网银客户号
      ,'企业' as 客户类型
      ,c.kehuzhao  as 客户账号
      ,c.zhhuztai  as 状态代码
      ,case when c.zhhuztai = 'C' then '0' else '1' end as 是否销户 --0销户，1未销户
from edw.ebnk_cb_cst_channel_inf a
left join edw.core_kdpa_kehuzh c on c.kehuhaoo = a.cci_cstno and c.dt = a.dt
where a.dt in ('20181231','20191231','20201231','20210930','20211031','20211101','20211102','20211123','20211124')
) aa
) bb
where bb.rn = 1
;

select * from lab_bigdata_dev.xt_024618_tmp_1_outlimit_20211125;

/*
select dt, count(*)
from edw.ebnk_cb_cst_channel_inf
where dt <= '20201231'
group by dt
order by dt;


select * from edw.ebnk_pb_cstinf_channel where dt = '20181231' and pcc_outdaylimit >= 50000000;
select * from edw.ebnk_cb_cst_channel_inf where dt = '20181231'
select * from edw.core_kdpa_kehuzh where dt = '20211129' and kehuhaoo = '2002483896'
select * from lab_bigdata_dev.xt_024618_tmp_1_outlimit_20211125 where 网银客户号 = '2602497920'
select a.cci_cstno as 网银客户号
      ,'企业' as 客户类型
      ,c.kehuzhao  as 客户账号
      ,c.zhhuztai  as 状态代码
      ,case when c.zhhuztai = 'C' then '0' else '1' end as 是否销户 --0销户，1未销户
from edw.ebnk_cb_cst_channel_inf a
left join edw.core_kdpa_kehuzh c on c.kehuhaoo = a.cci_cstno and c.dt = a.dt
where a.dt in ('20181231','20191231','20201231','20210930','20211031','20211101','20211102','20211123','20211124')
and a.cci_cstno = '2602497920'
;
select * from edw.ebnk_cb_cst_channel_inf where dt = '20201231' and cci_cstno = '2602497920';
*/


drop table if exists lab_bigdata_dev.xt_024618_tmp_outlimit_20211125;
create table if not exists lab_bigdata_dev.xt_024618_tmp_outlimit_20211125 as
select a.dt as 日期
      ,'个人' as 客户类型
      ,a.pcc_cstno as 网银客户号
      ,b.cst_chn_nm as 客户姓名
      ,b.prm_org_id as 主管户机构
      ,b.prm_org_nm as 主管户机构名称
      ,b.prm_mgr_id as 主管户客户经理
      ,b.prm_mgr_nm as 主管户客户经理名称
      ,a.pcc_outsiglelimit as 对外单笔限额
      ,a.pcc_outdaylimit as 对外日累计限额
      ,c.是否是销户客户
      ,a.pcc_channel as 渠道
      ,a.pcc_channelstt as 渠道状态
from edw.ebnk_pb_cstinf_channel a
left join edw.dws_cst_bas_inf_dd b on b.cst_id = a.pcc_cstno and b.dt = a.dt
left join lab_bigdata_dev.xt_024618_tmp_1_outlimit_20211125 c on c.网银客户号 = a.pcc_cstno --and c.客户类型='个人'
where a.dt in ('20181231','20191231','20201231','20210930','20211031','20211101','20211102','20211123','20211124')
and a.pcc_outdaylimit >= 50000000
order by 日期
union all
select a.dt as 日期
      ,'企业' as 客户类型
      ,a.cci_cstno as 网银客户号
      ,b.cst_chn_nm as 客户姓名
      ,b.prm_org_id as 主管户机构
      ,b.prm_org_nm as 主管户机构名称
      ,b.prm_mgr_id as 主管户客户经理
      ,b.prm_mgr_nm as 主管户客户经理名称
      ,a.cci_limitsinglemoney as 对外单笔限额
      ,a.cci_limitmoney as 对外日累计限额
      ,c.是否是销户客户
      ,a.cci_channel as 渠道
      ,a.cci_channelstt as 渠道状态
from edw.ebnk_cb_cst_channel_inf a
left join edw.dws_cst_bas_inf_dd b on b.cst_id = a.cci_cstno and b.dt = a.dt
left join lab_bigdata_dev.xt_024618_tmp_1_outlimit_20211125 c on c.网银客户号 = a.cci_cstno --and c.客户类型='企业'
where a.dt in ('20181231','20191231','20201231','20210930','20211031','20211101','20211102','20211123','20211124')
and a.cci_limitmoney >= 50000000
order by 日期
;

select * from lab_bigdata_dev.xt_024618_tmp_outlimit_20211125 where 网银客户号 = '2002483896';

select * from edw.dws_cst_bas_inf_dd where dt = '20211124' and cst_id = '2002483896';




/*
      ,case
           when  c.zhhuztai = 'A' then '正常'
           when  c.zhhuztai = 'C' then '销户'
           when  c.zhhuztai = 'F' then '金额冻结'
           when  c.zhhuztai = 'G' then '未启用'
           WHEN  c.zhhuztai = 'H' then '待启用'
           WHEN  c.zhhuztai = 'B' then '不动户'
           WHEN  c.zhhuztai = 'Y' then '预销户'
           WHEN  c.zhhuztai = 'E' then '封闭冻结'
           WHEN  c.zhhuztai = 'D' then '久悬户'
           else '转营业外收入'
      end as zhhuztai_dscr
*/
**数据需求_20211126_上海松江支行客户2013年1月流水查询.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-26 09:51:41
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

--客户郑明近，卡号6221410004715042，2013年1月流水信息
drop table if exists lab_bigdata_dev.xt_024618_tmp_zhaohaooselect_20211129;
create table if not exists lab_bigdata_dev.xt_024618_tmp_zhaohaooselect_20211129 as
select *
from edw.core_kdpl_zhminx --账户余额发生明细
where dt >= '20130101' and dt <= '20130131'
and kehuzhao = '6221410004715042'
;
**数据需求_20211126_湖州南浔小微企业专营老账号交易流水.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-26 10:34:47
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 只能查到一个账号的信息
SELECT pan	 帐号
,pageseq 页号
,iopseq 页内序号
,acdate 记帐日期
,ctflag 现转标志
,dcflag 借贷标志
,rvflag 冲正标志
,amount 发生额
,dbbal 借方余额
,crbal	贷方余额
,rmkmsg 摘要信息
,voucherno 凭证号码
,destsub 对方科目
,prnflag 登折标志
,fullflag 满页标志
,acopr 记帐柜员
,chkopr 复核柜员
from edw.accfulllist
where pan in ('9010802011120543','9010802011183168')
order by 帐号,记帐日期
;


-- 无字段描述
select *
from edw.accmain  --一代核心 账户信息表
where pan = '9010802011183168'
;







select *
from edw.yypfb0
where yyb0oldaid = '9010802011183168'
**数据需求_20211129_贺丽佳_台州路桥城西支行对客查询.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-29 09:55:43
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

-- 马振华，321102197607120435，该客户需我行提供其在1997年1月至1999年12月的全部账户交易明细

select *
from edw.core_kdpl_zhminx
where dt <= '19970101' and dt >= '19991231'
and zhhuzwmc = '马振华'
;




-- 存款账号dep_act_id：3301010101301409453、3301160101300040424、3301070101300567512
-- 客户账号cst_act_id： 3301010108900210588、6221410003423865、6214808801006393157
-- 开户日期分别在20170904、20101014、20170903
select a.*,b.*,c.*
from edw.dws_cst_bas_inf_dd a
left join edw.dws_bus_dep_act_inf_dd b on b.cst_id = a.cst_id and b.dt = a.dt
left join edw.dws_bus_dep_bal_chg_dtl_di c on c.dep_act_id = b.dep_act_id and c.dt >= '19970101' and c.dt <= '19991231'
where a.dt = '20211128'
and a.doc_nbr = '321102197607120435'
;



select *
from edw.core_kdpa_zhxinx  --三代核心 负债账户信息表
where dt = '20211128'
and kehuhaoo = '1006954522'
;



select *
from edw.dws_bus_dep_bal_chg_dtl_di
where dt >= '19970101' and dt <= '19971231'
and
**数据需求_20211129_陈敏敏_信贷_存款_国结_财富_泰惠收业务客户管户与小微地图系统客户主管户不一致.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-29 16:45:56
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 在梳理客户交接问题，申请提取信贷、存款、国结、财富、泰惠收业务客户管户与小微地图系统客户主管户不一致的客户数
edw.loan_ind_info --信贷系统
edw.dwd_bus_loan_ctr_mgr_inf_dd --信贷合同管户信息 合同级别


edw.xwdt_xw_customer --小微地图客户信息
select cust_no
      ,manager_org_no
      ,manager_no
from edw.xwdt_xw_customer
where dt = '20211128'
;

-- 信贷系统
-- 国结系统
-- 财富：绩效系统
-- 泰惠收系统
-- 存款
edw.dwd_bus_dep_cst_act_mgr_inf_dd


select aa.*,row_number()over(partition by cst_act_id,mgr_id order by gl_bal desc) as rn
from
(
select a.dep_act_id
      ,a.cst_act_id
      ,a.cst_id
      ,a.mgr_id
      ,a.mgr_rto
      --,a.gl_bal
      ,a.mgr_rto * a.gl_bal as gl_bal
from edw.dws_bus_dep_act_mgr_inf_dd a
--left join
where a.dt = '20211128'
and a.mgr_rto < 1
)aa
;
**数据需求_20211130_普惠部卡号匹配.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-11-30 14:34:04
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
create table lab_bigdata_dev.xt_024618_tmp_kahaomatch_20211130
(
    mon  STRING COMMENT '客户账号'
    ,kahao STRING COMMENT '卡号'
)
;

select * from lab_bigdata_dev.xt_024618_tmp_kahaomatch_20211130;


drop table if exists lab_bigdata_dev.xt_024618_tmp_kahao_20211130;
create table if not exists lab_bigdata_dev.xt_024618_tmp_kahao_20211130 as
select aa.mon
      ,aa.kahao
      ,a.mgr_id as 管户经理工号
      ,c.empe_nm as 管户经理姓名
      ,d.brc_org_id as 分行机构号
      ,d.brc_org_nm as 分行
      ,d.sbr_org_id as 支行机构号
      ,d.sbr_org_nm as 支行
from lab_bigdata_dev.xt_024618_tmp_kahaomatch_20211130  aa
left join edw.dws_bus_dep_act_mgr_inf_dd a on aa.kahao = a.cst_act_id and a.dt = '20211129'
LEFT JOIN edw.dws_hr_empe_inf_dd c ON c.empe_id = a.mgr_id AND c.dt = a.dt and c.dt = '20211129'
LEFT JOIN edw.dim_hr_org_mng_org_tree_dd d ON d.org_id = c.org_id AND d.dt = a.dt and d.dt = '20211129'
where aa.kahao not like '622287%'
union all

select aa.mon
      ,aa.kahao
      ,a.manageuserid as 管户经理工号
      ,c.empe_nm as 管户经理姓名
      ,d.brc_org_id as 分行机构号
      ,d.brc_org_nm as 分行
      ,d.sbr_org_id as 支行机构号
      ,d.sbr_org_nm as 支行
from lab_bigdata_dev.xt_024618_tmp_kahaomatch_20211130  aa
left join edw.loan_creditcard_info a on aa.kahao = a.cardno and a.dt = '20211129'
LEFT JOIN edw.dws_hr_empe_inf_dd c ON c.empe_id = a.manageuserid AND c.dt = a.dt and c.dt = '20211129'
LEFT JOIN edw.dim_hr_org_mng_org_tree_dd d ON d.org_id = c.org_id AND d.dt = a.dt and d.dt = '20211129'
where aa.kahao like '622287%'
;




select * from xt_024618_tmp_kahao_20211130 where kahao not like '622287%'
**数据需求_20211201_风险部_中台特殊业务审批表对应的信贷客户信息.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-01 15:48:24
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
中台特殊业务审批表对应的信贷客户及业务
20210901-20211014
申请日期、办理事项、申请人工号、申请人姓名、最后审批人、客户名称、客户证件号、业务流水号、补充内容、申请人机构号、机构名称
*/
formtable_main_569 未入仓，已移交开发处理
**数据需求_20211202_互联网金融部_年日均活期存款.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-02 14:02:32
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

select
      a.mcht_id 商户编号
      ,a.setl_acct_no 结算账户
      ,a.setl_acct_name 结算账户户名
      ,a.start_date 合同开始日期
      ,case
        when a.dt = '20191231' and substr(a.start_date,1,4) = '2019' then b.act_year_acm_bal / (datediff(to_date('20191231','yyyyMMdd'),to_date(a.start_date,'yyyyMMdd'),'dd') + 1)
        when a.dt = '20191231' and substr(a.start_date,1,4) <> '2019' then '' end as 2019存款年日均
      ,case
        when a.dt = '20201231' and substr(a.start_date,1,4) = '2019' then b.act_year_acm_bal / (datediff(to_date('20201231','yyyyMMdd'),to_date('20200101','yyyyMMdd'),'dd')+1)
        when a.dt = '20201231' and substr(a.start_date,1,4) = '2020' then b.act_year_acm_bal / (datediff(to_date('20201231','yyyyMMdd'),to_date(a.start_date,'yyyyMMdd'),'dd')+1)
        when a.dt = '20201231' and substr(a.start_date,1,4) = '2021' then '' end as 2020存款年日均
      ,case
        when a.dt = '20211202' and substr(a.start_date,1,4) = '2019' then b.act_year_acm_bal / (datediff(to_date('20211202','yyyyMMdd'),to_date('20210101','yyyyMMdd'),'dd')+1)
        when a.dt = '20211202' and substr(a.start_date,1,4) = '2020' then b.act_year_acm_bal / (datediff(to_date('20211202','yyyyMMdd'),to_date('20210101','yyyyMMdd'),'dd')+1)
        when a.dt = '20211202' and substr(a.start_date,1,4) = '2021' then b.act_year_acm_bal / (datediff(to_date('20211202','yyyyMMdd'),to_date(a.start_date,'yyyyMMdd'),'dd')+1)
     end as 2021存款年日均
from edw.dpss_pbs_mcht_contract_info a
left join edw.dws_bus_dep_act_inf_dd b on b.cst_act_id = a.setl_acct_no and b.dt = a.dt
where a.dt in ('20191231','20201231','20211202')
and b.lbl_prod_typ_cd='0' --活期
and a.mcht_id in (
    '8202104130186287'
,'8202104130186274'
,'8202104070185406'
,'8202102260180428'
,'8202012100168507'
,'8202011250164273'
,'8202011110160059'
,'8202009290151654'
,'8202009290151605'
,'8202009290151469'
,'8202009150148499'
,'8202005250127642'
,'8202005210127234'
,'8202005180126223'
,'8202005060123162'
,'8202004210119935'
,'8202004010115470'
,'8201910290088740'
)
order by a.mcht_id,a.start_date
;
**数据需求_20211202_资产保全部_11月30日随贷通数据.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-02 08:45:17
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
create table lab_bigdata_dev.xt_024618_tmp_suidaitong_1_20211202
(
    会计日期  STRING COMMENT '会计日期'
    ,客户账号 STRING COMMENT '客户账号'
    ,客户号 STRING COMMENT '客户号'
    ,合同编号 STRING COMMENT '合同编号'
    ,客户名称 STRING COMMENT '客户名称'
)
;

select * from lab_bigdata_dev.xt_024618_tmp_suidaitong_1_20211202;



drop table if exists lab_bigdata_dev.xt_024618_tmp_suidaitong_2_20211202;
create table if not exists lab_bigdata_dev.xt_024618_tmp_suidaitong_2_20211202
as
select DISTINCT a.*
from
(select aa.合同编号 as 合同编号
      --,ln.CST_id 客户号
      --,ln.cst_nm as 客户名称
      ,aa.会计日期
      ,aa.客户账号
      ,aa.客户号
      ,aa.客户名称
      ,guaranty.OWNERID 担保人编号
      ,cst1.cst_chn_nm 担保人名称
      ,cst1.mbl_nbr  担保人电话
      ,row_number() over (partition by aa.合同编号 order by guaranty.OWNERID) as rn
from lab_bigdata_dev.xt_024618_tmp_suidaitong_1_20211202 aa
left join edw.loan_guaranty_relative rel on aa.合同编号 = rel.OBJECTNO and rel.OBJECTTYPE='BusinessContract' and rel.dt = '20211201'   --业务合同、担保合同与担保物关联表
left join edw.loan_guaranty_info guaranty  on rel.GUARANTYID=guaranty.GUARANTYID and guaranty.dt = '20211201'    --担保物信息表
left join edw.dws_cst_bas_inf_dd cst1 on guaranty.OWNERID = cst1.cst_id and cst1.dt = '20211201'    --客户基础信息汇总表
--left join edw.dim_bus_loan_ctr_inf_dd ln on rel.OBJECTNO = ln.busi_ctr_id and ln.dt = '202110201'
) a;


drop table if exists lab_bigdata_dev.xt_024618_tmp_suidaitong_3_20211202;
create table if not exists lab_bigdata_dev.xt_024618_tmp_suidaitong_3_20211202
as
SELECT  a.会计日期
        ,a.合同编号
        ,a.客户账号
        ,a.客户号
        ,a.客户名称
        ,a.担保人编号 担保人编号1
        ,a.担保人名称 担保人名称1
        ,a.担保人电话 担保人电话1
        ,b.担保人编号 担保人编号2
        ,b.担保人名称 担保人名称2
        ,b.担保人电话 担保人电话2
        ,c.担保人编号 担保人编号3
        ,c.担保人名称 担保人名称3
        ,c.担保人电话 担保人电话3
        ,d.担保人编号 担保人编号4
        ,d.担保人名称 担保人名称4
        ,d.担保人电话 担保人电话4
        ,e.担保人编号 担保人编号5
        ,e.担保人名称 担保人名称5
        ,e.担保人电话 担保人电话5
        ,f.担保人编号 担保人编号6
        ,f.担保人名称 担保人名称6
        ,f.担保人电话 担保人电话6
        ,cc.LINKMANNAME1 联系人1
        ,cc.LINKMANTEL1 联系人1电话
        ,cc.LINKMANMOBTEL1 联系人1手机
        ,cc.LINKMANNAME2 联系人2
        ,cc.LINKMANTEL2 联系人2电话
        ,cc.LINKMANMOBTEL2 联系人2手机
FROM    xt_024618_tmp_suidaitong_2_20211202 a
LEFT JOIN    xt_024618_tmp_suidaitong_2_20211202 b
ON      a.合同编号 = b.合同编号
AND     b.rn = 2
LEFT JOIN    xt_024618_tmp_suidaitong_2_20211202 c
ON      a.合同编号 = c.合同编号
AND     c.rn = 3
LEFT JOIN    xt_024618_tmp_suidaitong_2_20211202 d
ON      a.合同编号 = d.合同编号
AND     d.rn = 4
LEFT JOIN   xt_024618_tmp_suidaitong_2_20211202 e
ON      a.合同编号 = e.合同编号
AND     e.rn = 5
LEFT JOIN   xt_024618_tmp_suidaitong_2_20211202 f
ON      a.合同编号 = f.合同编号
AND     f.rn = 6
LEFT JOIN    edw.loan_creditcard_customer cc
ON      a.客户号 = cc.CUSTOMERID
AND     cc.dt = '20211201'
WHERE   a.rn = 1
;


select 会计日期,合同编号,客户账号,客户号,客户名称,担保人编号1,担保人名称1,担保人电话1,担保人编号2,担保人名称2,担保人电话2,担保人编号3,担保人名称3,担保人电话3,担保人编号4,担保人名称4,担保人电话4,担保人编号5,担保人名称5
        ,担保人电话5,担保人编号6,担保人名称6,担保人电话6,联系人1,联系人1电话,联系人1手机,联系人2,联系人2电话,联系人2手机 from lab_bigdata_dev.xt_024618_tmp_suidaitong_3_20211202;
**数据需求_20211203_宁波分行对私对公客户信息清单.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-03 15:46:08
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
时间：20080101-20211130
根据人行客户信息治理工作要求，需对分行存量账户进行分析整改统计。
需求字段：客户号、账号、账户类型、名称、证件有效期、手机号码等，请详见附件
1.自然人信息：核心客户号	客户名称 	性别	证件类型 	证件类型名称 	证件号 	证件有效期 	出生日期 	年龄周岁 	国籍名称 	住所地（如住所地与经常居住地不一致，填写经常居住地）	职业	工作单位地址	联系方式	开户机构	开户日期
2.非自然人客户信息：核心客户号	客户名称	所属行业	经营范围	开户证件类型	开户证件类型名称	开户证件号	开户证件有效期限	国籍名称	通讯地址	注册地址	公司电话	法定代表人	法人证件类型	法人证件类型名称	法人证件号	法人证件到期日	受益所有人	受益所有人身份证件种类	受益所有人身份证件种类名称	受益所有人身份证件号	受益所有人身份证件结束时间	受益所有人居住地址	开户机构	开户日期	管户机构	管户客户经理
3.客户数+账户数（剔除已销户）：统计截止日期	对公存量客户数	对公存量账户数	对私存量客户数	对私存量账户数
4.账户维度：核心客户号	客户名称 	证件类型名称 	证件号 	证件有效期 	账号	账户类型	账户状态
*/

-----------------------------------1 自然人客户信息清单
DROP TABLE if exists lab_bigdata_dev.xt_024618_tmp_01_20211203;
CREATE TABLE if not exists lab_bigdata_dev.xt_024618_tmp_01_20211203 AS
select 客户号,客户名称,证件类型,证件号码,证件有效期,出生日期,联系方式,性别,
       replace(replace(replace(工作单位地址,&quot;\t&quot;,&quot;_&quot;),&quot;\n&quot;,&quot;_&quot;),&quot;,&quot;,&quot;_&quot;) as 工作单位地址
       ,replace(replace(replace(地址,&quot;\t&quot;,&quot;_&quot;),&quot;\n&quot;,&quot;_&quot;),&quot;,&quot;,&quot;_&quot;) as 地址
       ,replace(replace(replace(国籍,&quot;\t&quot;,&quot;_&quot;),&quot;\n&quot;,&quot;_&quot;),&quot;,&quot;,&quot;_&quot;) as 国籍
       ,replace(replace(replace(职业,&quot;\t&quot;,&quot;_&quot;),&quot;\n&quot;,&quot;_&quot;),&quot;,&quot;,&quot;_&quot;) as 职业
       ,开户机构,开户机构名称,开户日期,未止付未销户账户标志1有0无
from
(
SELECT
  A.CST_ID          客户号
  ,A.CST_CHN_NM     客户名称
  ,A.DOC_TYP_CD     证件类型
  ,A.DOC_NBR        证件号码
  ,CASE WHEN A.DOC_MTU_DT='18991231' THEN '' ELSE A.DOC_MTU_DT END     证件有效期
  ,case when A.DOC_TYP_CD = 'B0101' then substr(A.DOC_NBR,7,8) else '' end as 出生日期
  ,CASE WHEN COALESCE(A.MBL_NBR,'')='' THEN CASE WHEN COALESCE(A.FML_TEL_NBR,'')='' THEN A.CMP_TEL_NBR ELSE A.FML_TEL_NBR END ELSE A.MBL_NBR END 联系方式
  ,B.GDR_CD         性别
  ,A.wrk_adr        工作单位地址
  ,CASE WHEN COALESCE(A.cmn_adr,'')='' THEN CASE WHEN COALESCE(A.fml_adr,'')=''
  THEN CASE WHEN COALESCE(A.reg_adr,'')=''
  THEN A.wrk_adr ELSE A.reg_adr END ELSE A.fml_adr END ELSE A.cmn_adr END    地址
  ,B.NTN_CD         国籍
  ,B.OCP_CD         职业
  ,C1.kaihjigo     开户机构
  ,d.org_nm        开户机构名称
  ,C1.kaihriqi     开户日期
  ,CASE WHEN ACT_FLAG=0 OR CST_ACT_FLAG=0 THEN '0' ELSE '1' END 未止付未销户账户标志1有0无
FROM EDW.DWS_CST_BAS_INF_DD A  --客户基础信息汇总表
left JOIN EDW.DIM_CST_IDV_BAS_INF_DD B ON A.CST_ID=B.CST_ID AND B.DT='20211130'  -- 个人客户基本信息
INNER JOIN  (SELECT T.KEHUHAOO,MIN(ZHUJIGOH) ZHUJIGOH,min(T.kaihjigo) kaihjigo,min(T.kaihriqi) kaihriqi
                   ,SUM(CASE WHEN T.zhhuztai='A' AND T.zhfbdjbz='0' AND T.zhzsbfbz='0' THEN 1 ELSE 0 END) ACT_FLAG
                   ,SUM(CASE WHEN T1.zhhuztai='A' AND T1.zhfbdjbz='0' AND T1.zhzsbfbz='0' THEN 1 ELSE 0 END) CST_ACT_FLAG
             FROM EDW.CORE_KDPA_ZHXINX T  --负债账户信息表
             LEFT JOIN EDW.CORE_KDPA_KEHUZH T1 ON T.KEHUZHAO=T1.KEHUZHAO AND T1.DT='20211130'
             WHERE T.DT='20211130'
               AND ZHUJIGOH LIKE '3303%'   --筛选账户所属机构
             GROUP BY T.KEHUHAOO ) C1
ON A.CST_ID=C1.KEHUHAOO
left join edw.dim_hr_org_mng_org_tree_dd d on C1.kaihjigo = d.org_id and d.dt = a.dt
WHERE A.DT='20211130'
  AND A.CST_TYP_CD='1'
) AA
;
select count(distinct 客户号) from lab_bigdata_dev.xt_024618_tmp_01_20211203;



-----------------------------------------------------------------------
DROP TABLE if exists lab_bigdata_dev.xt_024618_tmp_02_20211203;
CREATE TABLE if not exists lab_bigdata_dev.xt_024618_tmp_02_20211203 AS
SELECT
  A.CST_ID          客户号
  ,CASE WHEN A.CST_TYP_CD='1' THEN '对私' ELSE '对公' end as 客户类型
  ,A.CST_CHN_NM     客户名称
  ,A.DOC_TYP_CD     证件类型
  ,A.DOC_NBR        证件号码
  ,CASE WHEN A.DOC_MTU_DT='18991231' THEN '' ELSE A.DOC_MTU_DT END     证件有效期
  ,B.dep_act_id    存款账号
  ,B.cst_act_id    客户账号
  ,B.act_ctg_cd_1  账户分类代码
  ,code2.cd_val_dscr 账户分类
  ,B.act_sts_cd   账户状态代码
  ,code1.cd_val_dscr 账户状态
  ,c.zhfbdjbz 账户不收不付标志1是0否
  ,c.zhzsbfbz 账户只收不付标志1是0否
  ,c.zhzfbsbz 账户只付不收标志1是0否
  ,case
         when d.cst_act_id is not null then '是'
         else '否'
      end 是否暂停非柜面
  --,CASE WHEN ACT_FLAG=0 OR CST_ACT_FLAG=0 THEN '0' ELSE '1' END 未止付未销户账户标志1有0无
FROM EDW.DWS_CST_BAS_INF_DD A  --客户基础信息汇总表
left join edw.dim_bus_dep_act_inf_dd B on A.CST_ID = B.cst_id and B.dt = A.dt
left join edw.core_kdpa_kehuzh c on c.kehuzhao = B.cst_act_id and c.dt = '20211130'
left join
(
    SELECT CST_ACT_ID
          ,MIN(LMT_EFT_DT) AS LMT_EFT_DT  --额度生效日期
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20211130'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
) d on d.CST_ACT_ID = b.cst_act_id
LEFT JOIN edw.dwd_code_library code1 ON code1.cd_val = B.act_sts_cd AND code1.cd_nm LIKE '%账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
left join edw.dwd_code_library code2 ON code2.cd_val = B.act_sts_cd AND code1.cd_nm LIKE '%账户分类%' AND code2.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
WHERE A.DT='20211130'
and B.act_afl_org LIKE '3303%'  --筛选宁波分行
  --AND A.CST_TYP_CD='1'
;

select * from lab_bigdata_dev.xt_024618_tmp_02_20211203;










------------------------------------------------------------------------------
drop table if exists lab_bigdata_dev.TMP03_ORG_20210104;
CREATE TABLE if not exists lab_bigdata_dev.TMP03_ORG_20210104 AS
  SELECT * FROM (
    SELECT A1.CST_ID,A1.REL_TYP_CD,A1.REL_CST_ID,COALESCE(CST_CHN_NM,'') CST_CHN_NM,
    COALESCE(B.PRM_DOC_TYP_CD,'') PRM_DOC_TYP_CD,COALESCE(PRM_DOC_NBR,'') PRM_DOC_NBR,COALESCE(PRM_DOC_MTU_DT,'') PRM_DOC_MTU_DT
    ,COALESCE(OCP_CD,'') OCP_CD,COALESCE(cmn_adr,'') cmn_adr
    ,ROW_NUMBER() OVER(PARTITION BY A1.CST_ID,CASE WHEN A1.REL_TYP_CD LIKE '09%' THEN '09%' ELSE A1.REL_TYP_CD END ORDER BY A1.REL_CST_ID) RNUM
    FROM EDW.DIM_CST_REL_INF_DD A1
      LEFT JOIN (SELECT A.CST_ID,A.CST_CHN_NM,A.DOC_TYP_CD PRM_DOC_TYP_CD,A.DOC_NBR PRM_DOC_NBR,A.DOC_MTU_DT PRM_DOC_MTU_DT,B.OCP_CD
      ,CASE WHEN COALESCE(A.cmn_adr,'')='' THEN CASE WHEN COALESCE(A.fml_adr,'')=''
      THEN CASE WHEN COALESCE(A.reg_adr,'')=''
      THEN A.wrk_adr ELSE A.reg_adr END ELSE A.fml_adr END ELSE A.cmn_adr END cmn_adr
FROM EDW.DWS_CST_BAS_INF_DD A
  , EDW.DIM_CST_IDV_BAS_INF_DD B WHERE A.DT='20211202' AND B.DT='20211202' AND A.CST_ID=B.CST_ID
UNION ALL
SELECT REL_CST_ID CST_ID,REL_NM CST_CHN_NM,DOC_TYP_CD PRM_DOC_TYP_CD,DOC_NBR PRM_DOC_NBR,DOC_MTU_DT PRM_DOC_MTU_DT,'' OCP_CD,ctc_adr AS cmn_adr
FROM EDW.DIM_CST_REL_IDV_INF_DD WHERE DT='20211202') B
  ON A1.REL_CST_ID=B.CST_ID
      WHERE (A1.REL_TYP_CD IN ('0101','0109','0801') OR A1.REL_TYP_CD LIKE '09%')
      AND A1.DT='20211202'
) A WHERE RNUM=1
;

select * from lab_bigdata_dev.TMP03_ORG_20210104;



--------------------------------------------3 非自然人信息清单
DROP TABLE if exists lab_bigdata_dev.xt_024618_tmp_03_20211203;
CREATE TABLE if not exists lab_bigdata_dev.xt_024618_tmp_03_20211203 AS
select 客户号
      ,客户名称
      ,行业代码
      ,主管户机构号
      ,主管户机构名称
      ,主管户客户经理
      ,主管户客户经理名称
      ,replace(replace(replace(住所,&quot;\t&quot;,&quot;_&quot;),&quot;\n&quot;,&quot;_&quot;),&quot;,&quot;,&quot;_&quot;) as 住所
      ,replace(replace(replace(经营范围,&quot;\t&quot;,&quot;_&quot;),&quot;\n&quot;,&quot;_&quot;),&quot;,&quot;,&quot;_&quot;) as 经营范围
      ,证件类型
      ,证件号码
      ,证件有效期
      ,法定代表人
      ,法定代表人证件类型,法定代表人证件号码,法定代表人证件到期日,授权办理业务人,授权办理业务人证件类型,授权办理业务人证件号码,实际控制人
      ,授权经办人员证件有效期全部为空,实际控制人证件类型,实际控制人证件号码,实际控制人证件到期日,受益所有人名称,受益所有人证件类型,受益所有人证件号码
      ,受益所有人证件到期日,受益所有人地址,开户机构号,开户机构名,开户日期,未止付未销户账户标志1有0无
from
(
SELECT  A.CST_ID 客户号
  ,A.CST_CHN_NM 客户名称
  ,A.idt_cd  行业代码
  ,A.prm_org_id 主管户机构号
  ,aa.org_nm 主管户机构名称
  ,A.prm_mgr_id 主管户客户经理
  ,A.prm_mgr_nm 主管户客户经理名称
  ,CASE WHEN COALESCE(A.cmn_adr,'')='' THEN CASE WHEN COALESCE(A.fml_adr,'')=''
  THEN CASE WHEN COALESCE(A.reg_adr,'')=''
  THEN A.wrk_adr ELSE A.reg_adr END ELSE A.fml_adr END ELSE A.cmn_adr END    住所
  ,COALESCE(REPLACE(REPLACE(REPLACE(C2.MAN_RANG,CHR(9),''),CHR(10),''),CHR(13),''),'') 经营范围
  ,A.DOC_TYP_CD 证件类型
  ,A.DOC_NBR 证件号码
  ,CASE WHEN A.DOC_MTU_DT='18991231' THEN '' ELSE A.DOC_MTU_DT END               证件有效期
  ,COALESCE(D1.CST_CHN_NM,'')   法定代表人
  ,COALESCE(D1.PRM_DOC_TYP_CD,'')  法定代表人证件类型
  ,COALESCE(D1.PRM_DOC_NBR,'')   法定代表人证件号码
  ,COALESCE(D1.PRM_DOC_MTU_DT,'') 法定代表人证件到期日
  ,COALESCE(D3.DLIRMINC,'')   授权办理业务人
  ,COALESCE(D3.DLIRZHJN,'')  授权办理业务人证件类型
  ,COALESCE(D3.DLIRZHJH,'')   授权办理业务人证件号码
  ,COALESCE(D2.CST_CHN_NM,'')   实际控制人
  ,'' 授权经办人员证件有效期全部为空
  ,COALESCE(D2.PRM_DOC_TYP_CD,'')  实际控制人证件类型
  ,COALESCE(D2.PRM_DOC_NBR,'')   实际控制人证件号码
  ,COALESCE(D2.PRM_DOC_MTU_DT,'') 实际控制人证件到期日
  ,COALESCE(D4.CST_CHN_NM,'')   受益所有人名称
  ,COALESCE(D4.PRM_DOC_TYP_CD,'')  受益所有人证件类型
  ,COALESCE(D4.PRM_DOC_NBR,'')   受益所有人证件号码
  ,COALESCE(D4.PRM_DOC_MTU_DT,'') 受益所有人证件到期日
  ,COALESCE(D4.cmn_adr,'') 受益所有人地址
  ,D3.kaihjigo 开户机构号
  ,bb.org_nm 开户机构名
  ,D3.kaihriqi 开户日期
  ,CASE WHEN ACT_FLAG=0 OR CST_ACT_FLAG=0 THEN '0' ELSE '1' END 未止付未销户账户标志1有0无
FROM    EDW.DWS_CST_BAS_INF_DD A
left join edw.dim_hr_org_mng_org_tree_dd aa on aa.org_id = A.prm_org_id and aa.dt = A.dt
--INNER JOIN    EDW.DIM_CST_ENTP_BAS_INF_DD B ON      A.CST_ID = B.CST_ID AND     B.DT = '20211130'
LEFT JOIN    EDW.ECIF_T00_ORG_CUST_NO_REC C1 ON      A.CST_ID = C1.CUST_NO AND     C1.DT = '20211130'
LEFT JOIN    EDW.ECIF_T01_ORG_CUST_INFO C2 ON      C1.PARTY_ID = C2.PARTY_ID AND     C2.DT = '20211130'
left join TMP03_ORG_20210104 d1 on A.CST_ID=d1.CST_ID and d1.REL_TYP_CD='0101'
left join TMP03_ORG_20210104 d2 on A.CST_ID=d2.CST_ID and d2.REL_TYP_CD='0109'
inner JOIN  (SELECT A1.KEHUHAOO,MIN(A1.ZHUJIGOH),MIN(COALESCE(B1.dailremc,'')) DLIRMINC,min(A1.kaihjigo) kaihjigo,MIN(A1.kaihriqi) kaihriqi
                   ,MIN(COALESCE(B1.dailzjlx,'')) DLIRZHJN
                   ,MIN(COALESCE(B1.dailzjho,'')) DLIRZHJH
                   ,MIN(COALESCE(B1.DLIRDHUA,'')) DLIRDHUA
                   ,SUM(CASE WHEN A1.zhhuztai='A' AND A1.zhfbdjbz='0' AND A1.zhzsbfbz='0' THEN 1 ELSE 0 END) ACT_FLAG
                   ,SUM(CASE WHEN T1.zhhuztai='A' AND T1.zhfbdjbz='0' AND T1.zhzsbfbz='0' THEN 1 ELSE 0 END) CST_ACT_FLAG
             FROM EDW.CORE_KDPA_ZHXINX A1
             LEFT JOIN EDW.CORE_KDPA_KEHUZH T1 ON A1.KEHUZHAO=T1.KEHUZHAO AND T1.DT='20211130'
             LEFT JOIN EDW.core_kdpb_dlrdjb B1 ON A1.ZHANGHAO=B1.ZHANGHAO AND B1.DT='20211130' AND COALESCE(B1.dailremc,'')<>''
             WHERE A1.DT='20211130'
               AND ZHUJIGOH LIKE '3303%'
             GROUP BY A1.KEHUHAOO ) D3
ON A.CST_ID=D3.KEHUHAOO
left join edw.dim_hr_org_mng_org_tree_dd bb on D3.kaihjigo = bb.org_id and bb.dt = A.dt
left join TMP03_ORG_20210104 d4 on A.CST_ID=d4.CST_ID and d4.REL_TYP_CD LIKE '09%'
WHERE   A.DT = '20211130'
  AND     A.CST_TYP_CD = '2'
) AA
;

select count(distinct 客户号) from lab_bigdata_dev.xt_024618_tmp_03_20211203;


------------------------------------------------------------------------------------------
------------------------------------------------------代码整理------------------------------------
drop table if exists lab_bigdata_dev.TMP03_ORG_20211202;
CREATE TABLE if not exists lab_bigdata_dev.TMP03_ORG_20211202 AS
SELECT *
FROM (
    SELECT A1.CST_ID   --
          ,A1.REL_TYP_CD  --关联类型代码
          ,A1.REL_CST_ID  --关联客户编号
          ,COALESCE(CST_CHN_NM,'') CST_CHN_NM
          ,COALESCE(B.PRM_DOC_TYP_CD,'') PRM_DOC_TYP_CD  --证件类型代码
          ,COALESCE(PRM_DOC_NBR,'') PRM_DOC_NBR          --证件号码
          ,COALESCE(PRM_DOC_MTU_DT,'') PRM_DOC_MTU_DT    --证件到期日期
          ,COALESCE(OCP_CD,'') OCP_CD     --职业代码
          ,COALESCE(cmn_adr,'') cmn_adr   --联系地址
          ,ROW_NUMBER() OVER(PARTITION BY A1.CST_ID,CASE WHEN A1.REL_TYP_CD LIKE '09%' THEN '09%' ELSE A1.REL_TYP_CD END ORDER BY A1.REL_CST_ID) RNUM
    FROM EDW.DIM_CST_REL_INF_DD A1  --客户关联关系信息
    LEFT JOIN (SELECT A.CST_ID
                     ,A.CST_CHN_NM
                     ,A.DOC_TYP_CD PRM_DOC_TYP_CD  --证件类型代码
                     ,A.DOC_NBR PRM_DOC_NBR        --证件号码
                     ,A.DOC_MTU_DT PRM_DOC_MTU_DT  --证件到期日期
                     ,B.OCP_CD                     --职业代码
                     ,CASE WHEN COALESCE(A.cmn_adr,'')='' THEN CASE WHEN COALESCE(A.fml_adr,'')='' THEN CASE WHEN COALESCE(A.reg_adr,'')='' THEN A.wrk_adr ELSE A.reg_adr END ELSE A.fml_adr END ELSE A.cmn_adr END cmn_adr
              FROM EDW.DWS_CST_BAS_INF_DD A, EDW.DIM_CST_IDV_BAS_INF_DD B WHERE A.DT='20211202' AND B.DT='20211202' AND A.CST_ID=B.CST_ID  --客户基础信息汇总表、个人客户基本信息
              UNION ALL
              SELECT REL_CST_ID CST_ID
                    ,REL_NM CST_CHN_NM
                    ,DOC_TYP_CD PRM_DOC_TYP_CD
                    ,DOC_NBR PRM_DOC_NBR
                    ,DOC_MTU_DT PRM_DOC_MTU_DT
                    ,'' OCP_CD
                    ,ctc_adr AS cmn_adr
              FROM EDW.DIM_CST_REL_IDV_INF_DD  --客户行外个人关系人信息
              WHERE DT='20211202') B ON A1.REL_CST_ID=B.CST_ID
      WHERE (A1.REL_TYP_CD IN ('0101','0109','0801') OR A1.REL_TYP_CD LIKE '09%')
      AND A1.DT='20211202'
) A WHERE RNUM=1
;



DROP TABLE if exists lab_bigdata_dev.xt_024618_tmp_03_20211203;
CREATE TABLE if not exists lab_bigdata_dev.xt_024618_tmp_03_20211203 AS
SELECT  A.CST_ID 客户号
       ,A.CST_CHN_NM 客户名称
       ,A.idt_cd  行业代码
       ,A.prm_org_id 主管户机构号
       ,aa.org_nm 主管户机构名称
       ,A.prm_mgr_id 主管户客户经理
       ,A.prm_mgr_nm 主管户客户经理名称
       ,CASE WHEN COALESCE(A.cmn_adr,'')='' THEN CASE WHEN COALESCE(A.fml_adr,'')='' THEN CASE WHEN COALESCE(A.reg_adr,'')='' THEN A.wrk_adr ELSE A.reg_adr END ELSE A.fml_adr END ELSE A.cmn_adr END    住所
      ,COALESCE(REPLACE(REPLACE(REPLACE(C2.MAN_RANG,CHR(9),''),CHR(10),''),CHR(13),''),'') 经营范围
      ,A.DOC_TYP_CD 证件类型
      ,A.DOC_NBR 证件号码
      ,CASE WHEN A.DOC_MTU_DT='18991231' THEN '' ELSE A.DOC_MTU_DT END 证件有效期
      ,COALESCE(D1.CST_CHN_NM,'')   法定代表人
      ,COALESCE(D1.PRM_DOC_TYP_CD,'')  法定代表人证件类型
      ,COALESCE(D1.PRM_DOC_NBR,'')   法定代表人证件号码
      ,COALESCE(D1.PRM_DOC_MTU_DT,'') 法定代表人证件到期日
      ,COALESCE(D3.DLIRMINC,'')   授权办理业务人
      ,COALESCE(D3.DLIRZHJN,'')  授权办理业务人证件类型
      ,COALESCE(D3.DLIRZHJH,'')   授权办理业务人证件号码
      ,COALESCE(D2.CST_CHN_NM,'')   实际控制人
      ,'' 授权经办人员证件有效期全部为空
      ,COALESCE(D2.PRM_DOC_TYP_CD,'')  实际控制人证件类型
      ,COALESCE(D2.PRM_DOC_NBR,'')   实际控制人证件号码
      ,COALESCE(D2.PRM_DOC_MTU_DT,'') 实际控制人证件到期日
      ,COALESCE(D4.CST_CHN_NM,'')   受益所有人名称
      ,COALESCE(D4.PRM_DOC_TYP_CD,'')  受益所有人证件类型
      ,COALESCE(D4.PRM_DOC_NBR,'')   受益所有人证件号码
      ,COALESCE(D4.PRM_DOC_MTU_DT,'') 受益所有人证件到期日
      ,COALESCE(D4.cmn_adr,'') 受益所有人地址
      ,D3.kaihjigo 开户机构号
      ,bb.org_nm 开户机构名
      ,D3.kaihriqi 开户日期
      ,CASE WHEN ACT_FLAG=0 OR CST_ACT_FLAG=0 THEN '0' ELSE '1' END 未止付未销户账户标志1有0无
FROM    EDW.DWS_CST_BAS_INF_DD A
left join edw.dim_hr_org_mng_org_tree_dd aa on aa.org_id = A.prm_org_id and aa.dt = A.dt
--INNER JOIN   EDW.DIM_CST_ENTP_BAS_INF_DD  B  ON  A.CST_ID = B.CST_ID       AND  B.DT = '20211130' --企业客户基本信息
LEFT JOIN    EDW.ECIF_T00_ORG_CUST_NO_REC C1 ON  B.CST_ID = C1.CUST_NO     AND  C1.DT = '20211130'
LEFT JOIN    EDW.ECIF_T01_ORG_CUST_INFO   C2 ON  C1.PARTY_ID = C2.PARTY_ID AND  C2.DT = '20211130'
left join TMP03_ORG_20211202 d1 on A.CST_ID=d1.CST_ID and d1.REL_TYP_CD='0101'  --筛选关系类型为法定代表人
left join TMP03_ORG_20211202 d2 on A.CST_ID=d2.CST_ID and d2.REL_TYP_CD='0109'  --筛选关系类型为实际控制人
INNER JOIN  (SELECT A1.KEHUHAOO
                   ,MIN(A1.ZHUJIGOH)  --账户所属机构
                   ,MIN(COALESCE(B1.dailremc,'')) DLIRMINC
                   ,min(A1.kaihjigo) kaihjigo  --开户机构
                   ,MIN(A1.kaihriqi) kaihriqi  --开户日期
                   ,MIN(COALESCE(B1.dailzjlx,'')) DLIRZHJN
                   ,MIN(COALESCE(B1.dailzjho,'')) DLIRZHJH
                   ,MIN(COALESCE(B1.DLIRDHUA,'')) DLIRDHUA
                   ,SUM(CASE WHEN A1.zhhuztai='A' AND A1.zhfbdjbz='0' AND A1.zhzsbfbz='0' THEN 1 ELSE 0 END) ACT_FLAG    --账户状态=A：正常，账户封闭冻结标志，账户只收不付标志
                   ,SUM(CASE WHEN T1.zhhuztai='A' AND T1.zhfbdjbz='0' AND T1.zhzsbfbz='0' THEN 1 ELSE 0 END) CST_ACT_FLAG
             FROM EDW.CORE_KDPA_ZHXINX A1  --负债账户信息表
             LEFT JOIN EDW.CORE_KDPA_KEHUZH T1 ON A1.KEHUZHAO=T1.KEHUZHAO AND T1.DT='20211130'   --客户账号表
             LEFT JOIN EDW.core_kdpb_dlrdjb B1 ON A1.ZHANGHAO=B1.ZHANGHAO AND B1.DT='20211130' AND COALESCE(B1.dailremc,'')<>''  --代理人信息登记簿
             WHERE A1.DT='20211130'
               AND ZHUJIGOH LIKE '3303%'
             GROUP BY A1.KEHUHAOO ) D3 ON A.CST_ID=D3.KEHUHAOO
left join edw.dim_hr_org_mng_org_tree_dd bb on D3.kaihjigo = bb.org_id and bb.dt = A.dt
left join TMP03_ORG_20211202 d4 on A.CST_ID=d4.CST_ID and d4.REL_TYP_CD LIKE '09%'
WHERE A.DT = '20211130'
  AND A.CST_TYP_CD = '2'  --筛选客户类型
  /*
  AND (A.CST_CHN_NM='' OR A.DOC_TYP_CD='' OR A.DOC_NBR=''
   OR A.DOC_MTU_DT IN ('','18991231') OR COALESCE(D1.CST_CHN_NM,'')=''
OR COALESCE(D1.PRM_DOC_TYP_CD,'')=''
OR COALESCE(D1.PRM_DOC_NBR,'')=''
OR COALESCE(D1.PRM_DOC_MTU_DT,'') IN ('','18991231')
OR COALESCE(D3.DLIRMINC,'')=''
OR COALESCE(D3.DLIRZHJN,'')=''
OR COALESCE(D3.DLIRZHJH,'')=''
OR COALESCE(D2.CST_CHN_NM,'')=''
OR COALESCE(D2.PRM_DOC_TYP_CD,'')=''
OR COALESCE(D2.PRM_DOC_NBR,'')=''
OR COALESCE(D2.PRM_DOC_MTU_DT,'') IN ('','18991231')
OR COALESCE(D4.CST_CHN_NM,'')=''
OR COALESCE(D4.PRM_DOC_TYP_CD,'')=''
OR COALESCE(D4.PRM_DOC_NBR,'')=''
OR COALESCE(D4.PRM_DOC_MTU_DT,'') IN ('','18991231')
OR COALESCE(D4.cmn_adr,'')=''
   OR (A.cmn_adr='' AND A.fml_adr='' AND A.reg_adr='' AND A.wrk_adr='' ))
   */
;
**数据需求_20211206_卡权益调整_财富.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-14 14:49:09
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 1. 存款（个人）
select aaa.gl_bal_avg_interval
      ,count(aaa.cst_id) as cst_id_count
      ,sum(aaa.gl_bal_avg) as gl_bal_avg_sum
from
(
select aa.cst_id
      ,sum(aa.gl_bal)/30 as gl_bal_avg
      ,case
         when sum(aa.gl_bal)/30 < 1000 then '(0,1000)'
         when sum(aa.gl_bal)/30 >= 1000 and sum(aa.gl_bal)/30 < 2000 then '[1000,2000)'
         when sum(aa.gl_bal)/30 >= 2000 and sum(aa.gl_bal)/30 < 3000 then '[2000,3000)'
         when sum(aa.gl_bal)/30 >= 3000 and sum(aa.gl_bal)/30 < 5000 then '[3000,5000)'
         when sum(aa.gl_bal)/30 >= 5000 and sum(aa.gl_bal)/30 < 8000 then '[5000,8000)'
         when sum(aa.gl_bal)/30 >= 8000 and sum(aa.gl_bal)/30 < 10000 then '[8000,10000)'
         when sum(aa.gl_bal)/30 >= 10000 and sum(aa.gl_bal)/30 < 15000 then '[10000,15000)'
         when sum(aa.gl_bal)/30 >= 15000 and sum(aa.gl_bal)/30 < 20000 then '[15000,20000)'
         when sum(aa.gl_bal)/30 >= 20000 and sum(aa.gl_bal)/30 < 30000 then '[20000,30000)'
         when sum(aa.gl_bal)/30 >= 30000 and sum(aa.gl_bal)/30 < 50000 then '[30000,50000)'
         when sum(aa.gl_bal)/30 >= 50000 and sum(aa.gl_bal)/30 < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as gl_bal_avg_interval
from
(
select a.dep_act_id
      ,a.cst_act_id
      ,a.cst_id
      ,a.gl_bal
from edw.dws_bus_dep_act_inf_dd a
left join edw.dim_bus_dep_cst_act_inf_dd b on a.cst_act_id = b.cst_act_id and b.dt = a.dt
where a.dt = '20211001'
and b.cst_act_typ_cd = '1'   --筛选:个人客户
and b.act_sts_cd <> 'C'   --剔除:销户
) aa
group by aa.cst_id
order by aa.cst_id
) aaa
group by aaa.gl_bal_avg_interval
order by aaa.gl_bal_avg_interval
;


-- 2.理财（个人）
select a.cur_lot_sum_avg_interval
      ,count(a.cst_id) as cst_id_count
      ,sum(a.cur_lot_sum_avg) as cur_lot_sum_avg_sum
from
(
select cst_id
      --,chm_cst_id
      ,sum(cur_lot)/30 as cur_lot_sum_avg   --每个客户当前份额
      ,case
         when sum(cur_lot)/30 < 1000 then '(0,1000)'
         when sum(cur_lot)/30 >= 1000 and sum(cur_lot)/30 < 2000 then '[1000,2000)'
         when sum(cur_lot)/30 >= 2000 and sum(cur_lot)/30 < 3000 then '[2000,3000)'
         when sum(cur_lot)/30 >= 3000 and sum(cur_lot)/30 < 5000 then '[3000,5000)'
         when sum(cur_lot)/30 >= 5000 and sum(cur_lot)/30 < 8000 then '[5000,8000)'
         when sum(cur_lot)/30 >= 8000 and sum(cur_lot)/30 < 10000 then '[8000,10000)'
         when sum(cur_lot)/30 >= 10000 and sum(cur_lot)/30 < 15000 then '[10000,15000)'
         when sum(cur_lot)/30 >= 15000 and sum(cur_lot)/30 < 20000 then '[15000,20000)'
         when sum(cur_lot)/30 >= 20000 and sum(cur_lot)/30 < 30000 then '[20000,30000)'
         when sum(cur_lot)/30 >= 30000 and sum(cur_lot)/30 < 50000 then '[30000,50000)'
         when sum(cur_lot)/30 >= 50000 and sum(cur_lot)/30 < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as cur_lot_sum_avg_interval
from edw.dws_bus_chm_act_acm_inf_dd  --理财账户份额汇总信息
where dt = '20211001'
group by cst_id
) a
group by cur_lot_sum_avg_interval
order by cur_lot_sum_avg_interval
;













------------------------------------------雨洁------------------------
SELECT  A.cst_id
        ,B.gl_bal  AS ck_gl_bal --'存款金额'
        ,C.cur_lot AS lc_cur_lot --'理财金额'
        ,F.FTP_YEAR AS FTP_YEAR_ALL --'本年ftp综合'
FROM    LAB_BIGDATA_DEV.crd_semi_024547_sample_lbb_full_cst A --去除准贷记卡的cst
LEFT JOIN    (
                 SELECT  cst_id
                         ,sum(gl_bal) AS gl_bal
                 FROM    edw.dws_bus_dep_act_inf_dd
                 WHERE   dt = '20210630'
                 GROUP BY cst_id
             ) B --存款
ON      A.cst_id = B.cst_id
LEFT JOIN    (
                 SELECT  cst_id
                         ,sum(cur_lot) AS cur_lot
                 FROM    edw.dws_bus_chm_act_acm_inf_dd
                 WHERE   dt = '20210630'
                 GROUP BY cst_id
             ) C --理财
**数据需求_20211206_卡权益调整_贷款.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-13 15:12:51
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 贷款余额区间、人数、总贷款余额、人均贷款余额、在贷天数（限个人客户）
select aa.ctr_bal_sum_interval
      ,count(aa.cst_id) as cst_id_count
      ,sum(aa.ctr_bal_sum) as ctr_bal_sum_2
from
(
select a.cst_id
      ,count(a.busi_ctr_id) as busi_ctr_count
      ,sum(a.ctr_bal) as ctr_bal_sum
      ,case
         when sum(a.ctr_bal) < 1000 then '(0,1000)'
         when sum(a.ctr_bal) >= 1000 and sum(a.ctr_bal) < 2000 then '[1000,2000)'
         when sum(a.ctr_bal) >= 2000 and sum(a.ctr_bal) < 3000 then '[2000,3000)'
         when sum(a.ctr_bal) >= 3000 and sum(a.ctr_bal) < 5000 then '[3000,5000)'
         when sum(a.ctr_bal) >= 5000 and sum(a.ctr_bal)< 8000 then '[5000,8000)'
         when sum(a.ctr_bal) >= 8000 and sum(a.ctr_bal) < 10000 then '[8000,10000)'
         when sum(a.ctr_bal) >= 10000 and sum(a.ctr_bal) < 15000 then '[10000,15000)'
         when sum(a.ctr_bal) >= 15000 and sum(a.ctr_bal) < 20000 then '[15000,20000)'
         when sum(a.ctr_bal) >= 20000 and sum(a.ctr_bal) < 30000 then '[20000,30000)'
         when sum(a.ctr_bal) >= 30000 and sum(a.ctr_bal) < 50000 then '[30000,50000)'
         when sum(a.ctr_bal) >= 50000 and sum(a.ctr_bal) < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as ctr_bal_sum_interval
from
(
select p1.busi_ctr_id
      ,p1.cst_id
      ,p1.ctr_bal
from edw.dim_bus_loan_ctr_inf_dd p1
inner join edw.dws_cst_idv_bas_inf_dd p2 on p1.cst_id = p2.cst_id and p2.dt = p1.dt   --筛选出个人客户
where p1.dt = '20211001'
) a
group by a.cst_id
) aa
group by aa.ctr_bal_sum_interval
order by aa.ctr_bal_sum_interval
;




--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
贷款余额区间    人数    总贷款余额    人均贷款余额     10月触发的贷款，未来30天内的在贷天数
------------------------------------借据层级20211220
-- 提取每个借据余额=0的min(date)
drop table if exists lab_bigdata_dev.xt_024618_tmp_loan_30d_20211220;
create table if not exists lab_bigdata_dev.xt_024618_tmp_loan_30d_20211220 as
select aa.*
      ,bb.dt as dt_0bal
      ,bb.rn
from
(
select a.dbil_id
      ,a.bus_ctr_id
      ,a.cst_id
      ,a.dtrb_dt   --发生日期
      ,dateadd(to_date(a.dtrb_dt,'yyyyMMdd'),30,'dd') as dtrb_dt_30d
      ,a.amt       --发放金额
      ,a.prcp_bal  --本金余额
from edw.dws_bus_loan_dbil_inf_dd a   --贷款借据信息汇总
--left join edw.dim_bus_loan_ctr_inf_dd b on a.bus_ctr_id = b.busi_ctr_id and b.dt = a.dt
where a.dt = '20211001'
and a.dtrb_dt >= '20210901' and a.dtrb_dt <= '20210930'   --借据发放日期在2021年9月
) aa
left join (
      select dbil_id
            ,bus_ctr_id
            ,cst_id
            ,dtrb_dt
            ,prcp_bal
            ,dt
            ,row_number()over(partition by dbil_id order by dt) as rn
      from edw.dws_bus_loan_dbil_inf_dd
      where dt >= '20210901' and dt <= '20211101'   --30天内在贷的最大区间值
      and prcp_bal = 0
) bb on bb.dbil_id = aa.dbil_id  --没有匹配上的就是在这个dt区间内，余额<>0，即在贷天数肯定大于30天

select * from lab_bigdata_dev.xt_024618_tmp_loan_30d_20211220;


-- 加工出未来30天内贷款天数
drop table if exists lab_bigdata_dev.xt_024618_tmp_loan_zaidai_20211220;
create table if not exists lab_bigdata_dev.xt_024618_tmp_loan_zaidai_20211220 as
select aa.dbil_id
      ,aa.bus_ctr_id
      ,aa.cst_id
      ,aa.prcp_bal --余额
      ,aa.dtrb_dt  --发放日期
      ,aa.dt_0bal  --余额=0的最早日期
      ,case when dtrb_dt_0bal_dt >= 30 then 30 else dtrb_dt_0bal_dt end as dtrb_dt_0bal_dt  --借据层级的在贷天数
from
(
select *
      ,30 as dtrb_dt_0bal_dt
from lab_bigdata_dev.xt_024618_tmp_loan_30d_20211220
where dt_0bal is null  --底表中未关联上的就是在贷天数>30天的
union all
select *
      ,datediff(to_date(dt_0bal,'yyyyMMdd'),to_date(dtrb_dt,'yyyyMMdd'),'dd') as dtrb_dt_0bal_dt
from lab_bigdata_dev.xt_024618_tmp_loan_30d_20211220
where rn = 1
) aa



-- 加工出最终的表
select a.prcp_bal_cst_interval
      ,count(a.cst_id) as cst_id_count  --客户数
      ,sum(a.prcp_bal_cst) as prcp_bal_cst_sum  --总贷款余额
      ,sum(a.dtrb_dt_0bal_dt_cst) as dtrb_dt_0bal_dt_cst_sum   --在贷天数
from
(
select cst_id
      ,sum(prcp_bal) as prcp_bal_cst
      ,sum(dtrb_dt_0bal_dt) as dtrb_dt_0bal_dt_cst
      ,case
         when sum(prcp_bal) < 1000 then '(0,1000)'
         when sum(prcp_bal) >= 1000 and sum(prcp_bal) < 2000 then '[1000,2000)'
         when sum(prcp_bal) >= 2000 and sum(prcp_bal) < 3000 then '[2000,3000)'
         when sum(prcp_bal) >= 3000 and sum(prcp_bal) < 5000 then '[3000,5000)'
         when sum(prcp_bal) >= 5000 and sum(prcp_bal) < 8000 then '[5000,8000)'
         when sum(prcp_bal) >= 8000 and sum(prcp_bal) < 10000 then '[8000,10000)'
         when sum(prcp_bal) >= 10000 and sum(prcp_bal) < 15000 then '[10000,15000)'
         when sum(prcp_bal) >= 15000 and sum(prcp_bal) < 20000 then '[15000,20000)'
         when sum(prcp_bal) >= 20000 and sum(prcp_bal) < 30000 then '[20000,30000)'
         when sum(prcp_bal) >= 30000 and sum(prcp_bal) < 50000 then '[30000,50000)'
         when sum(prcp_bal) >= 50000 and sum(prcp_bal) < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as prcp_bal_cst_interval
from lab_bigdata_dev.xt_024618_tmp_loan_zaidai_20211220
where cst_id in (
      select cst_id
      from edw.dws_cst_idv_bas_inf_dd  --筛选出个人客户
      where dt = '20211219'
)
group by cst_id
) a
group by a.prcp_bal_cst_interval
;


--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-------------------------在贷天数（合同层级加工）20211221(以此为准)
-- 加工出余额=0时的min(date)
drop table if exists lab_bigdata_dev.xt_024618_tmp_bal30d_20211221;
create table if not exists lab_bigdata_dev.xt_024618_tmp_bal30d_20211221 as
select aa.busi_ctr_id
      ,aa.cst_id
      ,aa.ctr_bal
      ,bb.dt as bal_0dt
      ,bb.rn
from
(
select p1.busi_ctr_id
      ,p1.cst_id
      ,p1.ctr_bal
from edw.dim_bus_loan_ctr_inf_dd p1
inner join edw.dws_cst_idv_bas_inf_dd p2 on p1.cst_id = p2.cst_id and p2.dt = p1.dt   --筛选出个人客户
where p1.dt = '20211001'
and p1.ctr_bal <> 0
) aa
left join (
      select busi_ctr_id
            ,cst_id
            ,ctr_bal
            ,dt
            ,row_number()over(partition by busi_ctr_id order by dt) as rn
      from edw.dim_bus_loan_ctr_inf_dd
      where dt >= '20210901' and dt <= '20211101'   --在贷天数最大区间
      and ctr_bal = 0
) bb on aa.busi_ctr_id = bb.busi_ctr_id  --没有匹配上就表示此合同号在这个区间余额<>0，在贷天数>30
;

select * from lab_bigdata_dev.xt_024618_tmp_bal30d_20211221;


-- 加工出余额为0的日期
drop table if exists lab_bigdata_dev.xt_024618_tmp_bal30d_20211221;
create table if not exists lab_bigdata_dev.xt_024618_tmp_bal30d_20211221 as
select a.*
      ,b.bal_0dt
      ,row_number()over(partition by a.busi_ctr_id order by bal_0dt) as rn
from
(
select p1.busi_ctr_id
      ,p1.cst_id
      ,p1.ctr_bal
      ,p1.dt   --余额<>0的日期
from edw.dim_bus_loan_ctr_inf_dd p1
inner join edw.dws_cst_idv_bas_inf_dd p2 on p1.cst_id = p2.cst_id and p2.dt = p1.dt   --筛选出个人客户
where p1.dt >= '20210901' and p1.dt <= '20211001'
and p1.ctr_bal <> 0
) a
left join
(
      select busi_ctr_id
            ,cst_id
            ,ctr_bal
            ,dt as bal_0dt   --余额=0的dt
      from edw.dim_bus_loan_ctr_inf_dd
      where dt >= '20210901' and dt <= '20211101'
        and ctr_bal = 0
) b on a.busi_ctr_id = b.busi_ctr_id and a.dt <= b.bal_0dt
;

select * from lab_bigdata_dev.xt_024618_tmp_bal30d_20211221 where busi_ctr_id = '20110328000083';


-- 加工出在贷天数
drop table if exists lab_bigdata_dev.xt_024618_tmp_bal30d_1_20211221;
create table if not exists lab_bigdata_dev.xt_024618_tmp_bal30d_1_20211221 as
select distinct a.busi_ctr_id --合同号
      ,a.cst_id      --客户号
      ,a.ctr_bal     --合同余额
      --,a.dt          --开始日期
      --,a.bal_0dt     --结束日期
      ,case when dt_bal0dt_interval_d >= 30 then 30 else dt_bal0dt_interval_d end as dt_bal0dt_interval_30d
from
(
select *
      ,datediff(to_date(bal_0dt,'yyyyMMdd'),to_date(dt,'yyyyMMdd'),'dd') as dt_bal0dt_interval_d
from lab_bigdata_dev.xt_024618_tmp_bal30d_20211221
where rn = 1
and bal_0dt is not null
union all
select distinct busi_ctr_id,cst_id,ctr_bal,dt,bal_0dt,rn,30 as dt_bal0dt_interval_d
from lab_bigdata_dev.xt_024618_tmp_bal30d_20211221
where bal_0dt is null
) a
;

select * from lab_bigdata_dev.xt_024618_tmp_bal30d_1_20211221;

-- 加工出最终的数据
select a.ctr_bal_cst_interval
      ,count(a.cst_id) as cst_id_count
      ,sum(a.ctr_bal_sum) as ctr_bal_sum_2
      ,sum(dt_bal0dt_interval_30d_avg) as dt_bal0dt_interval_30d_avg_sum
from
(
select cst_id
      ,count(busi_ctr_id) as busi_ctr_id_count  --每个客户有多少笔合同
      ,sum(ctr_bal) as ctr_bal_sum
      ,sum(dt_bal0dt_interval_30d) as dt_bal0dt_interval_30d_sum
      ,sum(dt_bal0dt_interval_30d) / count(busi_ctr_id) as dt_bal0dt_interval_30d_avg  --每个客户平均在贷天数
      ,case
         when sum(ctr_bal) < 1000 then '(0,1000)'
         when sum(ctr_bal) >= 1000 and sum(ctr_bal) < 2000 then '[1000,2000)'
         when sum(ctr_bal) >= 2000 and sum(ctr_bal) < 3000 then '[2000,3000)'
         when sum(ctr_bal) >= 3000 and sum(ctr_bal) < 5000 then '[3000,5000)'
         when sum(ctr_bal) >= 5000 and sum(ctr_bal) < 8000 then '[5000,8000)'
         when sum(ctr_bal) >= 8000 and sum(ctr_bal) < 10000 then '[8000,10000)'
         when sum(ctr_bal) >= 10000 and sum(ctr_bal) < 15000 then '[10000,15000)'
         when sum(ctr_bal) >= 15000 and sum(ctr_bal) < 20000 then '[15000,20000)'
         when sum(ctr_bal) >= 20000 and sum(ctr_bal) < 30000 then '[20000,30000)'
         when sum(ctr_bal) >= 30000 and sum(ctr_bal) < 50000 then '[30000,50000)'
         when sum(ctr_bal) >= 50000 and sum(ctr_bal) < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as ctr_bal_cst_interval
from lab_bigdata_dev.xt_024618_tmp_bal30d_1_20211221
group by cst_id
) a
group by a.ctr_bal_cst_interval
;


-------------------------贷记卡客户的贷款行为20211221
select a.ctr_bal_cst_interval
      ,count(a.cst_id) as cst_id_count
      ,sum(a.ctr_bal_sum) as ctr_bal_sum_2
      ,sum(dt_bal0dt_interval_30d_avg) as dt_bal0dt_interval_30d_avg_sum
from
(
select cst_id
      ,count(busi_ctr_id) as busi_ctr_id_count  --每个客户有多少笔合同
      ,sum(ctr_bal) as ctr_bal_sum
      ,sum(dt_bal0dt_interval_30d) as dt_bal0dt_interval_30d_sum
      ,sum(dt_bal0dt_interval_30d) / count(busi_ctr_id) as dt_bal0dt_interval_30d_avg  --每个客户平均在贷天数
      ,case
         when sum(ctr_bal) < 1000 then '(0,1000)'
         when sum(ctr_bal) >= 1000 and sum(ctr_bal) < 2000 then '[1000,2000)'
         when sum(ctr_bal) >= 2000 and sum(ctr_bal) < 3000 then '[2000,3000)'
         when sum(ctr_bal) >= 3000 and sum(ctr_bal) < 5000 then '[3000,5000)'
         when sum(ctr_bal) >= 5000 and sum(ctr_bal) < 8000 then '[5000,8000)'
         when sum(ctr_bal) >= 8000 and sum(ctr_bal) < 10000 then '[8000,10000)'
         when sum(ctr_bal) >= 10000 and sum(ctr_bal) < 15000 then '[10000,15000)'
         when sum(ctr_bal) >= 15000 and sum(ctr_bal) < 20000 then '[15000,20000)'
         when sum(ctr_bal) >= 20000 and sum(ctr_bal) < 30000 then '[20000,30000)'
         when sum(ctr_bal) >= 30000 and sum(ctr_bal) < 50000 then '[30000,50000)'
         when sum(ctr_bal) >= 50000 and sum(ctr_bal) < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as ctr_bal_cst_interval
from lab_bigdata_dev.xt_024618_tmp_bal30d_1_20211221
where cst_id in (
      select distinct cst_id   --贷记卡客户号，只要有贷记卡账户就计入
      from edw.dws_bus_crd_cr_crd_act_inf_dd
      where dt = '20211001'
      and cr_crd_act_id in (
            select cr_crd_act_id  --贷记卡账户
            from edw.dws_bus_crd_cr_crd_act_inf_dd a
            left join app_rpt.dim_cr_crd_pd b on a.late_main_card_pd_cls_cd = b.pd_cd
            where a.dt = '20211001'
            and a.late_main_card_sts_cd not in ('Q' , '2')  --此两个条件筛选出存续卡
            and a.act_sts_cd <> 'V'
            and b.crd_ctg_cd = '1'
      )
)
group by cst_id
) a
group by a.ctr_bal_cst_interval
;



--筛选出贷记卡客户，即剔除只有准贷记卡的客户
select distinct cst_id
from edw.dws_bus_crd_cr_crd_act_inf_dd
where dt = '20211001'
and cr_crd_act_id in
(
select cr_crd_act_id  --贷记卡账户
from edw.dws_bus_crd_cr_crd_act_inf_dd a
left join app_rpt.dim_cr_crd_pd b on a.late_main_card_pd_cls_cd = b.pd_cd
where a.dt = '20211001'
and a.late_main_card_sts_cd not in ('Q' , '2')  --此两个条件筛选出存续卡
and a.act_sts_cd <> 'V'
and b.crd_ctg_cd = '1'
)
;

LASTDAY()

select dt
from edw.dws_bus_crd_cr_crd_act_inf_dd
where dt = '@@{yyyyMM - 2m}01'
**数据需求_20211206_卡权益调整_贷记卡_新.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-16 14:22:17
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 此代码为信用卡账户级别
-- 1. 信用卡分期
--按金额统计
select aa.orig_purch_interval
      ,count(distinct aa.cr_crd_act_id) as card_act_count
      ,sum(aa.orig_purch) as orig_sum
      --,sum(aa.mon_acm_rbt_inc) as mon_acm_rbt_inc_sum
from
(
select p1.cr_crd_act_id
      ,p1.orig_purch
      ,p1.orig_purch_interval
      ,p2.mon_acm_rbt_inc
from
(
select b.cr_crd_act_id
      ,sum(a.orig_purch) as orig_purch
      ,case
        when sum(a.orig_purch) < 1000 then '(0,1000)'
         when sum(a.orig_purch) >= 1000 and sum(a.orig_purch) < 2000 then '[1000,2000)'
         when sum(a.orig_purch) >= 2000 and sum(a.orig_purch) < 3000 then '[2000,3000)'
         when sum(a.orig_purch) >= 3000 and sum(a.orig_purch) < 5000 then '[3000,5000)'
         when sum(a.orig_purch) >= 5000 and sum(a.orig_purch) < 8000 then '[5000,8000)'
         when sum(a.orig_purch) >= 8000 and sum(a.orig_purch) < 10000 then '[8000,10000)'
         when sum(a.orig_purch) >= 10000 and sum(a.orig_purch) < 15000 then '[10000,15000)'
         when sum(a.orig_purch) >= 15000 and sum(a.orig_purch) < 20000 then '[15000,20000)'
         when sum(a.orig_purch) >= 20000 and sum(a.orig_purch) < 30000 then '[20000,30000)'
         when sum(a.orig_purch) >= 30000 and sum(a.orig_purch) < 50000 then '[30000,50000)'
         when sum(a.orig_purch) >= 50000 and sum(a.orig_purch) < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as orig_purch_interval
from edw.ncrd_mpur a
left join edw.dim_bus_crd_cr_crd_inf_dd b on b.cr_crd_card_nbr = a.card_nbr and b.dt = '20210930'
where a.dt = '20211001'
and a.xstatus not in ('E','F') --分期状态不为：E错误终止/F退货终止
and a.inp_day >= '20210901' and a.inp_day <= '20210930' --筛选分期交易发生日期为2021年9月
group by b.cr_crd_act_id
) p1
left join(
      select cr_crd_act_id
            ,sum(tday_acm_rbt_inc) as mon_acm_rbt_inc
      from edw.dws_bus_crd_cr_crd_act_acm_inf_dd
      where dt >= '20210901' and dt <= '20210930'
      group by cr_crd_act_id
)p2 on p2.cr_crd_act_id = p1.cr_crd_act_id
) aa
group by aa.orig_purch_interval
order by aa.orig_purch_interval
;

--按期数统计
select a.nbr_mths
      ,count(distinct b.cr_crd_act_id) as cr_crd_act_id_sum
      ,sum(a.orig_purch) as orig_purch_sum
from edw.ncrd_mpur a
left join edw.dim_bus_crd_cr_crd_inf_dd b on b.cr_crd_card_nbr = a.card_nbr and b.dt = '20210930'
where a.dt = '20211001'
and a.xstatus not in ('E','F') --分期状态不为：E错误终止/F退货终止
and a.inp_day >= '20210901' and a.inp_day <= '20210930' --筛选分期交易发生日期为2021年9月
group by a.nbr_mths
order by a.nbr_mths
;




-- 2.信用卡取现
select aa.bill_amt_sum_interval
      ,count(distinct aa.cr_crd_act_id) as cr_crd_act_id_count
      ,sum(aa.bill_amt_sum) as bill_amt_sum_2
from (
select b.cr_crd_act_id
      ,sum(a.bill_amt) as bill_amt_sum
      ,case
         when sum(a.bill_amt) < 1000 then '(0,1000)'
         when sum(a.bill_amt) >= 1000 and sum(a.bill_amt) < 2000 then '[1000,2000)'
         when sum(a.bill_amt) >= 2000 and sum(a.bill_amt) < 3000 then '[2000,3000)'
         when sum(a.bill_amt) >= 3000 and sum(a.bill_amt) < 5000 then '[3000,5000)'
         when sum(a.bill_amt) >= 5000 and sum(a.bill_amt) < 8000 then '[5000,8000)'
         when sum(a.bill_amt) >= 8000 and sum(a.bill_amt) < 10000 then '[8000,10000)'
         when sum(a.bill_amt) >= 10000 and sum(a.bill_amt) < 15000 then '[10000,15000)'
         when sum(a.bill_amt) >= 15000 and sum(a.bill_amt) < 20000 then '[15000,20000)'
         when sum(a.bill_amt) >= 20000 and sum(a.bill_amt) < 30000 then '[20000,30000)'
         when sum(a.bill_amt) >= 30000 and sum(a.bill_amt) < 50000 then '[30000,50000)'
         when sum(a.bill_amt) >= 50000 and sum(a.bill_amt) < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as bill_amt_sum_interval
from edw.ncrd_tran a --信用卡交易流水
left join edw.dim_bus_crd_cr_crd_inf_dd b on b.cr_crd_card_nbr = a.card_nbr and b.dt = '20210930'
where a.dt >= '20210901' and a.dt <= '20210930'
and a.inp_date >= '20210901' and a.inp_date <= '20210930' --交易日期在2021.09
and a.trans_type >= 2000 and a.trans_type <= 2999  --交易类型：2000-2999
and a.rev_ind <> '1'   --撤销冲正标志<>1
group by b.cr_crd_act_id
) aa
group by bill_amt_sum_interval
order by bill_amt_sum_interval
;



-- 3.信用卡消费
--金额区间
/*
相同账号下：收单商户编号acptor_id，前5位为原交易时间（是距离19570101的天数，dateadd(day,inp_day,'19570101')），后面为原交易流水号；
与原交易的inp_day交易日期+xtranno流水号进行关联；
全额退货：退货交易的金额=原交易的金额；
部分退货：0<退货交易的金额<原交易的金额；
未退货：非退货交易未关联到相应的退货交易流水。
*/
select aa.real_amt_sum_interval
      ,count(distinct aa.cr_crd_act_id) as cr_crd_act_count
      ,sum(aa.real_amt_sum) as real_amt_sum_2
      ,sum(aa.mon_acm_rbt_inc) as mon_acm_rbt_inc_sum
from
(
select c.cr_crd_act_id
      ,sum(a.bill_amt - coalesce(b.bank_amt,0)) as real_amt_sum  --实际消费金额    应该改为加号，因为原始表中已经是负值了
      ,case
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) < 1000 then '(0,1000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 1000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 2000 then '[1000,2000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 2000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 3000 then '[2000,3000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 3000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 5000 then '[3000,5000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 5000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 8000 then '[5000,8000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 8000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 10000 then '[8000,10000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 10000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 15000 then '[10000,15000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 15000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 20000 then '[15000,20000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 20000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 30000 then '[20000,30000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 30000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 50000 then '[30000,50000)'
         when sum(a.bill_amt - coalesce(b.bank_amt,0)) >= 50000 and sum(a.bill_amt - coalesce(b.bank_amt,0)) < 100000 then '[50000,100000)'
         else '[100000,无穷)'
      end as real_amt_sum_interval
      ,sum(d.mon_acm_rbt_inc) as mon_acm_rbt_inc  --回佣
from
(
select card_nbr
      ,xtranno   --流水号
      ,bill_amt  --交易金额
      ,inp_date  --交易日期
      ,acptor_id    --收单商户编码
from edw.ncrd_tran  --信用卡交易流水
where dt >= '20210901' and dt <= '20210930'
and inp_date >= '20210901' and inp_date <= '20210930' --交易日期在2021.09
and trans_type >= 1000 and trans_type <= 1999
and trans_type <> 1050
and rev_ind <> '1'   --撤销冲正标志<>1
and bankacct <> '全额退货'
) a
left join (
select card_nbr   -- 加工退货交易金额
      ,xtranno    --流水号
      ,inp_date   --交易日期
      ,bill_amt as bank_amt   --退货金额
      ,acptor_id     --收单商户编码
      ,dateadd(to_date('19570101','yyyyMMdd'),substr(acptor_id,1,5),'dd') as old_inp_date   --原交易日期
      ,substr(acptor_id,6,6) as old_acptor_id
from edw.ncrd_tran  --信用卡交易流水
where dt >= '20210901' and dt <= '20210930'
and inp_date >= '20210901' and inp_date <= '20210930'   --交易日期在2021.09
and trans_type >= 6000 and trans_type <= 6999
and trans_type <> 6050
and trans_type <> 6052
and rev_ind <> '1'    --撤销冲正标志<>1
) b on b.old_acptor_id = a.xtranno and b.old_inp_date = to_date(a.inp_date,'yyyymmdd')
left join edw.dim_bus_crd_cr_crd_inf_dd c on c.cr_crd_card_nbr = a.card_nbr and c.dt = '20210930'
left join(
      select cr_crd_act_id
            ,sum(tday_acm_rbt_inc) as mon_acm_rbt_inc
      from edw.dws_bus_crd_cr_crd_act_acm_inf_dd
      where dt >= '20210901' and dt <= '20210930'
      group by cr_crd_act_id
) d on c.cr_crd_act_id = d.cr_crd_act_id
group by c.cr_crd_act_id
) aa
group by aa.real_amt_sum_interval
order by aa.real_amt_sum_interval
;

-- 笔数区间
select aa.xtranno_count_interval
      ,count(distinct aa.cr_crd_act_id) as cr_crd_act_count
      ,sum(aa.real_amt_sum) as real_amt_sum_2
      ,sum(aa.mon_acm_rbt_inc) as mon_acm_rbt_inc_sum
from
(
select c.cr_crd_act_id
      ,count(a.xtranno) as xtranno_count
      ,sum(a.bill_amt - coalesce(b.bank_amt,0)) as real_amt_sum  --实际消费金额
      ,sum(d.mon_acm_rbt_inc) as mon_acm_rbt_inc  --回佣
      ,case
          when count(a.xtranno) > 0 and count(a.xtranno) <= 1 then '(0,1]'
          when count(a.xtranno) > 1 and count(a.xtranno) <= 4 then '(1,4]'
          when count(a.xtranno) > 4 and count(a.xtranno) <= 8 then '(4,8]'
          when count(a.xtranno) > 8 and count(a.xtranno) <= 12 then '(8,12]'
          when count(a.xtranno) > 12 and count(a.xtranno) <= 20 then '(12,20]'
          when count(a.xtranno) > 20 and count(a.xtranno) <= 28 then '(20,28]'
          when count(a.xtranno) > 28 and count(a.xtranno) <= 40 then '(28,40]'
          when count(a.xtranno) > 40 and count(a.xtranno) <= 60 then '(40,60]'
          when count(a.xtranno) > 60 and count(a.xtranno) <= 80 then '(60,80]'
          when count(a.xtranno) > 80 and count(a.xtranno) <= 100 then '(80,100]'
          when count(a.xtranno) > 100 and count(a.xtranno) <= 120 then '(100,120]'
          when count(a.xtranno) > 120 then '(120,无穷)'
      end as xtranno_count_interval
from
(
select card_nbr
      ,xtranno   --流水号
      ,bill_amt  --交易金额
      ,inp_date  --交易日期
      ,acptor_id    --收单商户编码
from edw.ncrd_tran  --信用卡交易流水
where dt >= '20210901' and dt <= '20210930'
and inp_date >= '20210901' and inp_date <= '20210930' --交易日期在2021.09
and trans_type >= 1000 and trans_type <= 1999
and trans_type <> 1050
and rev_ind <> '1'   --撤销冲正标志<>1
and bankacct <> '全额退货'
) a
left join (
select card_nbr   -- 加工退货交易金额
      ,xtranno    --流水号
      ,inp_date   --交易日期
      ,bill_amt as bank_amt   --退货金额
      ,acptor_id     --收单商户编码
      ,dateadd(to_date('19570101','yyyyMMdd'),substr(acptor_id,1,5),'dd') as old_inp_date   --原交易日期
      ,substr(acptor_id,6,6) as old_acptor_id
from edw.ncrd_tran  --信用卡交易流水
where dt >= '20210901' and dt <= '20210930'
and inp_date >= '20210901' and inp_date <= '20210930'   --交易日期在2021.09
and trans_type >= 6000 and trans_type <= 6999
and trans_type <> 6050
and trans_type <> 6052
and rev_ind <> '1'    --撤销冲正标志<>1
) b on b.old_acptor_id = a.xtranno and b.old_inp_date = to_date(a.inp_date,'yyyymmdd')
left join edw.dim_bus_crd_cr_crd_inf_dd c on c.cr_crd_card_nbr = a.card_nbr and c.dt = '20210930'
left join(
      select cr_crd_act_id
            ,sum(tday_acm_rbt_inc) as mon_acm_rbt_inc
      from edw.dws_bus_crd_cr_crd_act_acm_inf_dd
      where dt >= '20210901' and dt <= '20210930'
      group by cr_crd_act_id
) d on c.cr_crd_act_id = d.cr_crd_act_id
group by c.cr_crd_act_id
) aa
group by aa.xtranno_count_interval
order by aa.xtranno_count_interval
;
**数据需求_20211206_计财部_客户号对应客户经营地址.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-06 10:03:35
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select customerid,city,cd_val_dscr from lab_bigdata_dev.xt_024618_tmp_worddir_21211206;


drop table if exists lab_bigdata_dev.xt_024618_tmp_worddir_21211206;
create table if not exists lab_bigdata_dev.xt_024618_tmp_worddir_21211206 as
select a.customerid
      ,a.city
      ,b.cd_val_dscr
from edw.loan_customer_address  a
left join edw.dwd_code_library b on b.cd_val = a.city and b.fld_nm like upper('city')
where a.dt = '@@{yyyyMMdd}'
and a.addtype='40'
and a.customerid in
('2001615474'
,'2001406115'
,'2605879754'
,'2605859671'
,'2602023656'
,'2000553249'
,'2000553249'
,'2600368383'
,'2604872580'
,'2000924681'
,'2603857625'
,'2002053374'
,'2001079931'
,'2000763761'
,'2001369700'
,'2000913452'
,'2603810826'
,'2605897651'
,'2000913452'
,'2002790561'
,'2600814697'
,'2001321399'
,'2002257136'
,'2000438254'
,'2601932700'
,'2602039608'
,'2603826422'
,'2000420231'
,'2603515716'
,'2602969217'
,'2000388302'
,'2603546633'
,'2000439448'
,'2603515716'
,'2000392475'
,'2602461040'
,'2001644344'
,'2605774629'
,'2000577023'
,'2603684034'
,'2002767424'
,'2605814295'
,'2600077498'
,'2001655667'
,'2000388496'
,'2003043578'
,'2605679561'
,'2605466991'
,'2002796510'
,'2002765673'
,'2000381727'
,'2000623676'
,'2601796669'
,'2605754435'
,'2002053374'
,'2602579161'
,'2600075557'
,'2602041721'
,'2000552930'
,'2605771831'
,'2604501143'
,'2605925231'
,'2601167871'
,'2605971714'
,'2001213241'
,'2001762095'
,'2000576288'
,'2600900159'
,'2001288726'
,'2603575616'
,'2000390631'
,'2001655667'
,'2603349081'
,'2603349081'
,'2604367163'
,'2000743457'
,'2000743457'
,'2001888995'
,'2000924681'
,'2600632973'
,'2602509436'
,'2605774629'
,'2602023656'
,'2602363008'
,'2001305618'
,'2600389186'
,'2001406115'
,'2001406115'
,'2001406115'
,'2601227495'
,'2002790561'
,'2603606153'
,'2600814697'
,'2601932700'
,'2605563694'
);
**数据需求_20211207_青田区域5家支行外币账户报送.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-07 14:54:50
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
报送青田外汇管理局，青田区域5家支行的个人外币账户
（包括青田支行330600100+温溪支行330600900+油竹支行330601600+鹤城支行330602000+船寮支行330602400），
账户包括外汇账户、外币定期、外币子户
*/
drop table if exists lab_bigdata_dev.xt_024618_tmp_outmoney_20211207;
create table if not exists lab_bigdata_dev.xt_024618_tmp_outmoney_20211207 as
select distinct b.dep_act_id 账号
      ,b.cst_id 客户号
      ,b.act_nm 账户名称
      ,b.act_cr_ind 钞汇标志
      ,case when b.act_cr_ind = '0' then '现钞' when b.act_cr_ind = '1' then '现汇' when b.act_cr_ind = '2' then '无' else b.act_cr_ind end as 钞汇
      ,b.opn_dt 开户日期
      ,b.opn_org 开户机构号
      ,c.org_nm 开户机构名称
      ,b.ccy_cd 币种代码
      ,code1.cd_val_dscr 币种
      ,d.prm_org_id 管户机构号
from edw.dws_bus_dep_act_inf_dd b   --存款账户信息汇总
left join edw.dim_hr_org_mng_org_tree_dd c on c.org_id = b.opn_org and c.dt = b.dt   --机构树_考核维度
left join edw.dws_cst_mng_prm_inf_dd d on d.cst_id = b.cst_id and d.dt = b.dt        --客户主管护信息
left join edw.dwd_code_library code1 on code1.cd_val = b.ccy_cd and code1.cd_nm = '币种'
where b.dt = '20211206'
and b.ccy_cd <> '156'
and (d.prm_org_id like '3306001%' or d.prm_org_id like '3306009%' or d.prm_org_id like '3306016%' or d.prm_org_id like '3306020%' or d.prm_org_id like '3306024%') --筛选主管户为青田区域机构
;

select 账号,客户号,账户名称,钞汇标志,钞汇,开户日期,开户机构号,开户机构名称,币种代码,币种,管户机构号 from lab_bigdata_dev.xt_024618_tmp_outmoney_20211207;


select * from lab_bigdata_dev.xt_024618_tmp_outmoney_20211207 where 账号 = '33060011000000205353';

select * from edw.dws_bus_dep_act_inf_dd where dt = '20211206' and dep_act_id = '33060011000000205353';
--------------------------------------------------------
SELECT a.cst_id
      ,a.dep_act_id
      ,a.act_nm
      ,a.opn_dt
      ,a.opn_org
      ,b.org_nm
      ,a.act_sts_cd
      ,a.ccy_cd  --币种
      ,a.act_cr_ind  --钞汇标志
from edw.dim_bus_dep_act_inf_dd a
left join edw.dim_hr_org_mng_org_tree_dd b on b.org_id = a.opn_org
where a.dt = '20211206'
;
**数据需求_20211209_台州分行某公司下挂子账户信息.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-09 17:33:30
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select
from
**数据需求_20211209_普惠部随贷通延期还本业务自查.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-09 08:41:33
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--drop table if exists lab_bigdata_dev.xt_024618_tmp_puhuisuidaitong_20211209;
create table lab_bigdata_dev.xt_024618_tmp_puhuisuidaitong_20211209
(
     借据编号     STRING COMMENT '借据编号'
    ,信贷合同编号 STRING COMMENT '信贷合同编号'
    ,客户编号    STRING COMMENT '客户编号'
)
;

select * from lab_bigdata_dev.xt_024618_tmp_puhuisuidaitong1_20211209;


drop table if exists lab_bigdata_dev.xt_024618_tmp_puhuisuidaitong1_20211209;
create table if not exists lab_bigdata_dev.xt_024618_tmp_puhuisuidaitong1_20211209 as
select a.借据编号
      ,a.信贷合同编号
      ,a.客户编号
      ,b.end_dt as 借据终结日期
      ,d.loan_cst_typ_cd as 信贷客户类型代码
      ,code1.cd_val_dscr as 信贷客户类型
      ,c.ind_bus_ind as 个体工商户标志1是0否
      ,c.mic_entp_own_ind as 小微企业主标志1是0否
from lab_bigdata_dev.xt_024618_tmp_puhuisuidaitong_20211209 a
left join edw.dws_bus_loan_dbil_inf_dd b on b.dbil_id = a.借据编号 and b.dt = '20211208'
left join edw.dim_cst_idv_bas_inf_dd c on c.cst_id = a.客户编号 and c.dt = '20211208'
left join edw.dws_cst_bas_inf_dd d on d.cst_id = a.客户编号 and d.dt = '20211208'
left join edw.dwd_code_library code1 on code1.cd_val = d.loan_cst_typ_cd and code1.fld_nm like upper('loan_cst_typ_cd')
;
**数据需求_20211209_计财部客户号匹配联系人和手机号.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-09 09:21:50
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select * from lab_bigdata_dev.xt_024618_tmp_cstreladr1_20211209;
drop table if exists lab_bigdata_dev.xt_024618_tmp_cstreladr1_20211209;
create table if not exists lab_bigdata_dev.xt_024618_tmp_cstreladr1_20211209 as
select distinct a.cst_id as 客户号
       ,case when a.cst_chn_nm <> '' then a.cst_chn_nm else b.cst_chn_nm end as 客户名
       ,case when a.mbl_nbr <> '' then a.mbl_nbr else b.mbl_nbr end as 手机号
from lab_bigdata_dev.xt_024618_tmp_cstreladr_20211209 a
left join edw.dws_cst_bas_inf_dd b on a.cst_id = b.cst_id and b.dt = '20211208'
;




drop table if exists lab_bigdata_dev.xt_024618_tmp_cstreladr_20211209;
create table if not exists lab_bigdata_dev.xt_024618_tmp_cstreladr_20211209 as
SELECT distinct cccc.cst_id
       ,cccc.cst_chn_nm
       ,cccc.mbl_nbr
FROM
(
select a.cst_id
      ,a.cst_chn_nm
      ,a.mbl_nbr
from edw.dws_cst_idv_bas_inf_dd a
where a.dt = '20211208'
union all
select a.cst_id
      ,AAA.CST_CHN_NM
      ,AAA.mbl_nbr
from edw.dim_cst_rel_inf_dd a
left join (
  SELECT *
  FROM (
    SELECT A1.cst_id   --
          ,A1.rel_typ_cd  --关联类型代码
          ,A1.rel_cst_id  --关联客户编号
          ,COALESCE(CST_CHN_NM,'') CST_CHN_NM
          ,mbl_nbr
          ,ROW_NUMBER() OVER(PARTITION BY A1.CST_ID,CASE WHEN A1.REL_TYP_CD LIKE '09%' THEN '09%' ELSE A1.REL_TYP_CD END ORDER BY A1.REL_CST_ID) RNUM
    FROM EDW.DIM_CST_REL_INF_DD A1  --客户关联关系信息
    LEFT JOIN (SELECT A.cst_id
                     ,A.cst_chn_nm
                     ,A.mbl_nbr
              FROM EDW.DWS_CST_BAS_INF_DD A
              left join EDW.DIM_CST_IDV_BAS_INF_DD B on A.CST_ID=B.CST_ID and B.DT='20211208'
              WHERE A.DT='20211208' --客户基础信息汇总表、个人客户基本信息
              UNION ALL
              SELECT rel_cst_id CST_ID
                    ,rel_nm CST_CHN_NM
                    ,ctc_mth mbl_nbr
              FROM EDW.DIM_CST_REL_IDV_INF_DD  --客户行外个人关系人信息
              WHERE DT='20211208') B
    ON A1.REL_CST_ID=B.CST_ID
    WHERE A1.REL_TYP_CD = '0101'
      AND A1.DT='20211208'
) A WHERE RNUM=1
) AAA ON AAA.CST_ID = a.cst_id
where a.dt = '20211208'
) cccc
where cccc.cst_id in
(
    '2001481875'
,'1607836894'
,'2000699446'
,'2605289989'
,'1672094447'
,'1006519318'
,'2606123003'
,'1610121555'
,'1043959117'
,'2601610542'
,'2001690590'
,'2601311652'
,'2602667438'
,'2605787006'
,'2602556865'
,'2602985874'
,'2602545752'
,'2000965361'
,'2604015631'
,'1017463420'
,'2003239463'
,'2600058830'
,'2602616590'
,'2002941484'
,'2002944195'
,'1009824323'
,'2001168875'
,'2002699280'
,'1602958377'
,'2000463320'
,'1605529513'
,'2001454530'
,'1007153263'
,'2606273942'
,'2601582182'
,'2001448553'
,'2605516110'
,'1003643948'
,'1003549189'
,'2602083496'
,'1003031729'
,'2602355350'
,'2603979181'
,'1000077806'
,'2601163831'
,'2601799854'
,'2606242084'
,'1039692514'
,'2606090600'
,'1641686500'
,'2604173939'
,'2603190837'
,'1005346881'
,'1032956905'
,'1004053782'
,'1003243371'
,'2600914214'
,'2003156450'
,'2602172916'
,'2604068697'
,'1008836033'
,'2001668089'
,'1000083148'
,'1021126896'
,'1004458671'
,'2600102482'
,'1017836783'
,'2606221257'
,'1004166361'
,'1672925109'
,'2601610542'
,'2606156325'
,'1671860928'
,'2606253943'
,'1013310203'
,'2606269744'
,'1016211174'
,'1019273289'
,'2600836260'
,'1002945186'
,'2003177592'
,'2604131671'
,'2606139794'
,'2600074141'
,'2602606317'
,'1005681319'
,'2604075397'
,'1026937877'
,'2600674107'
,'1030474612'
,'2001751400'
,'2002237707'
,'1610071460'
,'2600106982'
,'2603971946'
,'1641875920'
,'1040786310'
,'1672141099'
,'1672806312'
,'2600961525'
,'2602134700'
,'2601983505'
,'1003557878'
,'2606014101'
,'1004902862'
,'1045651208'
,'2604036596'
,'1009354095'
,'2003194203'
,'1632282617'
,'1613937301'
,'2606293252'
,'2002175418'
,'1621816219'
,'2606273381'
,'2604849926'
,'2606181895'
,'1025201872'
,'1015118074'
,'2601773501'
,'2003157101'
,'2001207226'
,'2002284589'
,'1000192997'
,'1006492952'
,'1016807566'
,'2002009311'
,'2002541420'
,'2603818266'
,'2603144761'
,'1045105019'
,'1604517597'
,'1016025948'
,'1016570929'
,'1012175940'
,'1011953169'
,'2600263689'
,'2601430261'
,'1006882971'
,'2603201893'
,'2606189734'
,'2001710179'
,'1640198069'
,'1013790511'
,'2604224354'
,'1027526652'
,'2605947797'
,'1003082824'
,'2601895635'
,'2601026141'
,'1020701478'
,'2604052364'
,'1004394810'
,'1015728428'
,'1004653728'
,'1036777232'
,'1014092214'
,'1019149652'
,'1600930053'
,'2002671107'
,'2601112172'
,'2606292905'
,'2604018063'
,'1007177636'
,'2601061256'
,'2606170139'
,'2001751400'
,'2602205726'
,'1014843306'
,'1000029557'
,'2002722793'
,'2604629751'
,'2603233876'
,'1006763649'
,'2001793932'
,'2603267995'
,'2000405629'
,'1032449359'
,'2600310979'
,'2605204449'
,'2601714069'
,'2602550061'
,'2601026141'
,'2600023201'
,'1640123562'
,'1031092475'
,'2002569457'
,'1010213503'
,'2603685968'
,'2001796047'
,'1006233573'
,'2605285404'
,'1670231127'
,'1009258043'
,'2001742200'
,'1616159449'
,'1012179434'
,'1006242564'
,'1005124403'
,'1672201943'
,'1010369550'
,'2601059352'
,'2002358796'
,'1038716145'
,'1641862198'
,'1672059517'
,'2606224001'
,'1672179609'
,'1604999341'
,'2601444475'
,'1045149518'
,'2002625216'
,'2606186226'
,'2606360134'
,'1630061998'
,'1003530871'
,'1000171327'
,'1000051841'
,'2000699446'
,'2605505411'
,'1614714025'
,'2600083976'
,'2602327060'
,'1007558897'
,'1004541845'
,'2003009125'
,'2600890714'
,'1009881683'
,'1021335388'
,'1020353316'
,'2001123377'
,'1023477664'
,'2604323997'
,'1007252320'
,'2602192354'
,'1034496665'
,'2600006848'
,'1010647324'
,'2602023061'
,'1013035328'
,'1020162495'
,'1007189352'
,'1000011975'
,'1023615730'
,'2002294447'
,'2001864919'
,'2601338193'
,'1010173526'
,'1012979421'
,'2601082668'
,'1007193881'
,'2606262073'
,'1672069759'
,'1672615766'
,'1008723012'
,'1013035328'
,'1670937487'
,'1005189246'
,'2602527400'
,'1004783791'
,'1035820670'
,'1034584447'
,'1008668005'
,'2600310979'
,'2604144132'
,'2604058034'
,'2602810988'
,'1026823819'
,'2003159851'
,'2605032365'
,'2000881063'
,'2602070264'
,'2600102482'
,'2600102482'
,'2001026472'
,'2606070662'
,'2604032213'
,'1006242564'
,'1016337238'
,'2603953074'
,'2606070494'
,'2606180818'
,'2601444475'
,'2601273809'
,'2603033182'
,'1639476072'
,'1007487199'
,'2601048774'
,'2606185877'
,'2603979181'
,'2601082668'
,'2600794365'
,'1600237080'
,'2601043053'
,'1620173971'
,'2600926952'
,'2606142629'
,'1013139411'
,'2604145208'
,'2605891728'
,'2605281533'
,'1042685486'
,'1016868411'
,'2600085442'
,'1027593111'
,'1010661494'
,'2003009125'
,'1034079990'
,'1040497641'
,'2001560611'
,'1608363962'
,'1007621315'
,'1027037521'
,'2003104123'
,'1035478776'
,'1005211666'
,'2602506604'
,'2602175890'
,'1007736675'
,'2600983361'
,'1671005910'
,'1668904628'
,'1000053184'
,'2000701754'
,'2603818266'
,'1009573320'
,'1600489137'
,'1605288542'
,'1643976145'
,'1013713512'
,'1009363428'
,'1009370846'
,'1006048447'
,'1600860705'
,'1011319826'
,'2606297964'
,'1008108356'
,'1000001066'
,'1603904740'
,'1016558129'
,'1606862533'
,'1672176058'
,'2606230530'
,'1668653603'
,'2604288499'
,'1002922293'
,'1025906986'
,'1601206187'
,'2605954214'
,'1005590198'
,'1608752508'
,'1641061109'
,'1004042692'
,'1000010039'
,'1607968344'
,'1028520222'
,'2000431446'
,'1044509412'
,'2001474666'
,'2606178349'
,'2002918107'
,'1600889304'
,'1673061876'
,'1002995934'
,'1014092214'
,'1035399675'
,'1640586666'
,'1034283038'
,'1000046679'
,'1615421509'
,'1673379070'
,'1036725183'
,'2601335431'
,'1003237419'
,'1035458664'
,'1043238904'
,'1624625522'
,'1000279564'
,'2600073939'
,'2606343908'
,'1024264997'
,'1609268638'
,'1006415427'
,'1640806316'
,'2001537156'
,'2606269489'
,'1009039895'
,'1003660705'
,'1010369550'
,'1012975355'
,'1005698559'
,'1641543261'
,'2604004138'
,'1616613529'
,'1032825128'
,'1614785392'
,'2600911628'
,'1673527173'
,'1037136003'
,'1033573295'
,'2606185850'
,'1010765417'
,'1004046117'
,'1621703759'
,'1635695307'
,'1044615043'
,'2606327569'
,'1036918413'
,'1671197533'
,'2605150328'
,'1624653786'
,'1018875231'
,'2002546696'
,'1010371942'
,'2602187503'
,'1639662316'
,'1033583069'
,'1672799451'
,'1037923863'
,'1007853714'
,'1616830822'
,'2603773260'
,'1626206275'
,'1026126459'
,'2603162607'
,'1640546194'
,'1609368603'
,'1017513048'
,'1613219213'
,'1012791302'
,'1036953649'
,'1041477831'
,'2604071566'
,'1604839197'
,'1610351656'
,'1603688308'
,'1023279565'
,'1044737187'
,'1632684285'
,'1029645379'
,'1038081977'
,'1670477840'
,'1044686173'
,'1022865004'
,'1673451905'
,'1029645379'
,'1035934049'
,'2001811791'
,'2601163340'
,'2600911628'
,'1020550252'
,'1008519525'
,'1616613529'
,'1644467779'
,'1003116280'
,'1006601297'
,'1044833805'
,'1610172697'
,'1024433405'
,'1638391938'
,'2002927655'
,'2600843111'
,'1004882492'
,'2003047149'
,'1031840027'
,'2003177390'
,'1009450751'
,'1042579660'
,'1640344874'
,'1003241777'
,'1649402869'
,'1622238108'
,'1640529917'
,'1016854968'
,'1005055448'
,'1640553671'
,'1003215361'
,'2600010938'
,'1042401217'
,'1654837930'
,'1023908520'
,'1006716951'
,'1641301539'
,'1009573320'
,'1004165191'
,'1612248946'
,'1672772910'
,'1640450648'
,'1000171769'
,'1009787949'
,'1020309360'
,'1026082229'
,'2603984000'
,'1009612632'
,'1032874768'
,'1638488257'
,'1021704791'
,'1019845688'
,'1004739985'
,'1025282257'
,'1608495022'
,'1016719126'
,'1009787949'
,'1015724383'
,'1639326946'
,'1043458517'
,'1007047959'
,'1600889331'
,'1012178978'
,'2606368912'
,'1639510826'
,'1010972949'
,'1017911408'
,'1011088764'
,'1012357003'
,'2603952684'
,'1602814559'
,'1622125325'
,'1031236141'
,'2603963164'
,'1031300411'
,'1019846360'
,'1012706760'
,'1004278857'
,'1036669247'
,'1043795632'
,'1019463877'
,'1640495210'
,'1004521980'
,'1028783669'
,'1016470678'
,'1023924294'
,'1008744154'
,'1021731492'
,'1640833080'
,'1627031487'
,'1639601583'
,'1022286674'
,'1010157643'
,'1017012215'
,'1672340514'
)
;
**数据需求_20211210_互联网金融部_泰惠收商户对应的客户的社区管户信息.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-10 16:50:26
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
drop table if exists lab_bigdata_dev.xt_024618_tmp_hujintaihuishou_20211213;
create table if not exists lab_bigdata_dev.xt_024618_tmp_hujintaihuishou_20211213 as
select a.mch_id as 商户编号
      ,a.mch_nm as 商户名称
      ,a.mch_sts_cd as 商户状态代码
      ,a.mch_area_cd as 商户所属地区代码
      ,a.cst_id as 客户号
      ,b.cprh_cmnt_id as 综合社区编号
      ,b.sub_cmnt_id as 子社区编号
      --,d.cmnt_nm as 社区名称
      --,d.crt_id as 创建人编号
      --,d.crt_nm as 创建人名称
      ,e.empe_id as 主维护人编号
      ,a1.empe_nm as 主维护人
      --,T22.EMPE_ID as 定人编号
      --,a2.empe_nm as 定人
      --,c.cmnt_main_mnt_id as 社区主维护人
      --,c.cmnt_prs as 社区定人
      --,c.mngr_id as 客户经理工号
from edw.dim_bus_chnl_ths_mch_inf_dd a  --泰惠收商户基本信息
left join edw.dwd_cst_mng_cmnt_rel_dd b on b.cst_id = a.cst_id and b.dt = a.dt  --客户社区信息
--left join edw.dim_cst_mng_cmnt_inf_dd d on b.sub_cmnt_id = d.cmnt_enc and b.DPD_TYP_CD = '1' and d.dt = a.dt
--left join app_rpt.FCT_SMALB_CMNT_DTL_TBL c on c.comm_cmnt_cd = d.afl_cmnt_id and c.dt = a.dt  --社区客户信息表 关联：子社区代码
LEFT JOIN EDW.DWD_HR_EMPE_ICSV_CMNT_EMP_REL_INF_DD e ON e.CMNT_ID = b.SUB_CMNT_ID AND e.REL_TYP_CD = '1' AND e.dt = a.dt  -- 普惠社区员工关联信息\社区编号\主维护人
left join edw.dim_hr_empe_bas_inf_dd a1 on a1.empe_id = e.empe_id and a1.dt = a.dt
where a.dt = '20211209'
;

/*
LEFT    JOIN (
            SELECT  A.CMNT_ID
                    ,WM_CONCAT('，',A.EMPE_ID) AS EMPE_ID
            FROM    EDW.DWD_HR_EMPE_ICSV_CMNT_EMP_REL_INF_DD A                      -- 普惠社区员工关联信息
            WHERE   A.REL_TYP_CD = '2'                                              -- 定人
            AND     A.DT = '20211209'
            GROUP   BY A.CMNT_ID
        ) T22
ON      T22.CMNT_ID = b.SUB_CMNT_ID
left join edw.dim_hr_empe_bas_inf_dd a1 on a1.empe_id = e.empe_id and a1.dt = a.dt
left join edw.dim_hr_empe_bas_inf_dd a2 on a1.empe_id = T22.EMPE_ID and a1.dt = a.dt
*/

--and a.cst_id <> ''
;



select 商户编号,客户号,综合社区编号,子社区编号,主维护人编号,主维护人 from lab_bigdata_dev.xt_024618_tmp_hujintaihuishou_20211213 where 客户号 <> '';



-- -----------------------------------------------------全喜的逻辑------------------------------------------------------
LEFT    JOIN EDW.DWD_CST_MNG_CMNT_REL_DD T5                                         -- 社区客户挂靠信息表
ON      T1.CST_ID = T5.CST_ID                                                       -- 客户编号
AND     T5.DPD_TYP_CD = '1'                                                         -- 挂靠在普惠社区
AND     T5.DT = '@@{yyyyMMdd}'
LEFT    JOIN    EDW.DIM_CST_MNG_CMNT_INF_DD T6                                      -- 社区信息
ON      T5.SUB_CMNT_ID = T6.CMNT_ENC                                                -- 子社区编号
AND     T6.DT = '@@{yyyyMMdd}'

DPD_TYP_CD 等于 '1'是普惠社区，等于2是小企业社区

社区有主维护人和定人，应该是没有管护人的，一般客户去管护人

LEFT    JOIN EDW.DWD_HR_EMPE_ICSV_CMNT_EMP_REL_INF_DD T21                           -- 普惠社区员工关联信息
ON      T21.CMNT_ID = T5.SUB_CMNT_ID                                                -- 社区编号
AND     T21.REL_TYP_CD = '1'                                                        -- 主维护人
AND     T21.DT = '@@{yyyyMMdd}'

LEFT    JOIN (
            SELECT  A.CMNT_ID
                    ,WM_CONCAT('，',A.EMPE_ID) AS EMPE_ID
            FROM    EDW.DWD_HR_EMPE_ICSV_CMNT_EMP_REL_INF_DD A                      -- 普惠社区员工关联信息
            WHERE   A.REL_TYP_CD = '2'                                              -- 定人
            AND     A.DT = '@@{yyyyMMdd}'
            GROUP   BY A.CMNT_ID
        ) T22
ON      T22.CMNT_ID = T5.SUB_CMNT_ID
**数据需求_20211210_台州分行VISA卡交易明细.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-10 08:46:07
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
客户吕东朔，卡号为 4202030100000582的VISA附属卡在2021.5.16-2021.12.09之间的交易账单
客户吕东朔办理有一张VISA附属卡，卡号为 4202030100000582，客户需要查询该卡号在
2021.5.16-2021.12.09之间的交易账单，目前在数据中心交易报表查询到的账单交易包含了所有的主卡交易，但客户仅想查询该张附属卡的明细，申请后台区分导出。
字段：交易日期、时间、类型描述、描述、金额、币种、撤销冲正标志、入账日期
*/
drop table if exists lab_bigdata_dev.xt_024618_tmp_visatrxdtl_20211210;
create table if not exists lab_bigdata_dev.xt_024618_tmp_visatrxdtl_20211210 as
select cr_crd_act_id as 信用卡账号
      ,cr_crd_card_nbr as 信用卡卡号
      ,trx_typ_cd as 交易类型代码
      ,trx_typ_dscr as 交易类型描述
      ,trx_ccy_cd  as 交易币种代码
      ,trx_amt as 交易金额
      ,trx_dt as 交易日期
      ,trx_tm as 交易时间
      ,act_dt as 入帐日期
      ,wdw_rvs_ind as 撤销冲正标志
      ,trx_dscr_1 as 交易描述1
      ,trx_dscr_2 as 交易描述2
from edw.dwd_bus_crd_cr_crd_trx_dtl_di
where dt >= '20210516' and dt <= '20211213'
and cr_crd_card_nbr = '4202030100000582'
;
**数据需求_20211210_某驾校账号子账户学员名称和余额.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-10 08:39:52
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
查询所属系统：台州驾校培训费托管系统
因驾校培训费托管系统变化，导致学员学费存入汽校托管账户后无法显示学员名称。
现需导出台州市隆翔驾驶员培训有限公司3301050120100023789下面挂靠的子账户学员名称和余额，用于金额对账。
需求字段：子账户学员名称和余额
*/

-- 20211217:台州市奋达汽车驾驶培训有限公司3301050120100023688，截止2021年10月8日
drop table if exists lab_bigdata_dev.xt_024618_tmp_zihu_20211213;
create table if not exists lab_bigdata_dev.xt_024618_tmp_zihu_20211213 as
select a.kehuzhao as 客户账号
      ,a.zhanghao as 负债账号
      ,b.act_nm as 账户名称
      ,b.gl_bal as 账户总账余额
from edw.core_kdpa_zhuzgx a  --主子账户关系表
left join edw.dws_bus_dep_act_inf_dd b on b.dep_act_id = a.zhanghao and b.dt = a.dt
where a.dt = '20211209'
and a.sjzhangh = '3301050120100023688'
;

select 客户账号,负债账号,账户名称,账户总账余额 from lab_bigdata_dev.xt_024618_tmp_zihu_20211213;








select dep_act_id
      ,cst_act_id
      ,act_nm
      ,gl_bal
from edw.dws_bus_dep_act_inf_dd --存款账户信息汇总
where dt = '20211216'
and cst_act_id = '3301050120100023688'
;


select *
--distinct cst_act_id,dt
from  edw.dwd_bus_dep_cst_act_mgr_inf_dd
where dt in ('20211208')
 and act_rel_chr_cd='6'  --6     资源性存款29671个账号
 and cst_act_id = '3301050120100023789'
;
**数据需求_20211210_计财部FTP应收冲减影响分析.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-10 08:41:20
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 贷款
SELECT
     R.CUST_NO AS '客户号',
     R.CUST_NM AS '客户名称',
     R.CONT_NO AS '合同号',
     BC.START_DATE AS '合同起始日',
     BC.END_DATE AS '合同到期日',
     BC.CONT_AMT AS '合同金额',
     BC.CONT_BAL AS '合同余额',
     BC.NORMAL_INT AS '利息',
     BC.DEF_INT AS '罚息',
     BC.CMP_INT AS '复息',
     R.REPORT_DATE AS '上报日期',
     R.INPUT_USER_NO AS '上报人工号',
     AU.USER_NAME AS '上报人名称',
     R.INPUT_ORG_NO AS '上报机构号',
     AO.ORG_NAME AS '上报机构名称'
FROM RISK_LOAN_REPORT R
LEFT JOIN XD_BUSINESS_CONTRACT BC ON R.CONT_NO = BC.CONT_NO
LEFT JOIN ADMIN_SM_USER AU ON R.INPUT_USER_NO = AU.USER_ID
LEFT JOIN ADMIN_SM_ORG AO ON R.INPUT_ORG_NO = AO.ORG_ID
WHERE REPORT_STAT='01';

-- 信用卡
SELECT
     R.CUST_NO AS '客户号',
     R.CUST_NM AS '客户名称',
     R.CARD_NO AS '合同号',
     BC.ACCT_OPN_DATE AS '开户日期',
     BC.END_DATE AS '到期日',
     BC.CRDT_AMT AS '信用额度',
     BC.OVDR_PRIN_AMT AS '透支本金',
     BC.INT_RECE_AMT AS '利息',
     BC.OVERDUE_FINE AS '应收滞纳金',
     BC.OTHER_FEE AS '应收其他费用',
     R.REPORT_DATE AS '上报日期',
     R.INPUT_USER_NO AS '上报人工号',
     AU.USER_NAME AS '上报人名称',
     R.INPUT_ORG_NO AS '上报机构号',
     AO.ORG_NAME AS '上报机构名称'
FROM RISK_CARD_REPORT R
LEFT JOIN XD_CREDITCARD_INFO BC ON R.CARD_NO = BC.CARD_NO
LEFT JOIN ADMIN_SM_USER AU ON R.INPUT_USER_NO = AU.USER_ID
LEFT JOIN ADMIN_SM_ORG AO ON R.INPUT_ORG_NO = AO.ORG_ID
WHERE REPORT_STAT='01';
**数据需求_20211214_上海分行银行卡部_泰惠收付款人ID.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-14 13:48:02
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select distinct 商户编号 from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215_org;
select  商户编号,一级商户名,交易金额,内部交易日期,内部交易时间,清算日期,入账日期,通道内部流水号,渠道流水号,营销活动银行出资金额,营销活动商户出资金额,微信app用户标识,买家支付宝用户号,支付账户号,通道类型编号
from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215_org;


select count(通道内部流水号)
from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215_org --客户反映为1.7亿
where 微信app用户标识 <> '' or 买家支付宝用户号 <> '' or 支付账户号 <> ''
;


drop table if exists lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215_0rg;
create table if not exists lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215_org as
select a.mch_id as 商户编号
      ,b.mer_id as 一级商户号
      ,b.mer_name as 一级商户名
      ,a.trx_amt as 交易金额
      ,a.clr_dt as 清算日期
      ,a.entr_act_dt as 入账日期
      ,b.txn_dt as 内部交易日期
      ,b.txn_tm as 内部交易时间
      ,a.chnl_int_srl_nbr as 通道内部流水号
      ,a.cmpn_actv_own_ctrb_amt as 营销活动银行出资金额
      ,a.cmpn_actv_mch_ctrb_amt as 营销活动商户出资金额
      ,a.chnl_trx_srl_nbr as 渠道流水号
      ,a.pay_bnk_id as 支付银行id
      ,a.pay_bnk_nm as 支付银行名
      ,a.wx_usr_id as 微信app用户标识
      ,a.zfb_pmt_usr_id as 买家支付宝用户号
      ,a.pay_acc_id as 支付账户号
      ,a.chnl_typ_id as 通道类型编号
from edw.dwd_bus_chnl_ths_entr_act_di a
left join edw.dpss_pbs_order_info b on a.chnl_trx_srl_nbr = b.txn_seq_id  and b.dt >= '20210101' and b.dt <= '20211209'
where a.dt >= '20210101' and a.dt <= '20211209'
and a.mch_id in ('8201905080027328'
,'8201905080027333'
,'8201905080027336'
,'8201905080027342'
,'8201905080027348'
,'8201905080027352'
,'8201905080027355'
,'8201905080027357'
,'8201905080027362'
,'8201905080027366'
,'8201905080027369'
,'8201905080027372'
,'8201905080027373'
,'8201905080027375'
,'8201905080027377'
,'8201905080027378'
,'8201907310051871'
,'8201907310051902'
,'8201907310051919'
,'8201907310051933'
,'8201907310051942'
,'8201909020068254'
,'8201909020068267'
,'8201912240104287'
,'8201912240104486'
,'8202007310139328'
,'8202008130141612'
,'8202008130141683'
,'8202008290144794'
,'8202011230163756'
,'8202102050178795'
,'8202102050178802'
,'8202102050178805'
,'8202102050178809'
,'8202106110194171'
,'8202106110194174'
,'8202106110194178'
,'8202106160194545'
,'8202107050197044'
,'8202107050197069'
,'8202107050197072'
,'8202107050197081'
,'8202107050197087'
,'8202107050197093'
,'8202107060197257'
,'8202107060197264'
,'8202107070197350'
,'8202107080197503'
,'8202107270199609'
,'8202108020200417'
,'8202108300203959'
,'8202108300203962'
,'8202111020211967'
,'8202111040212251'
,'8202111150213516'
,'8201912240104344'
,'8201912240104347'
,'8201912240104352'
,'8201912240104358'
,'8201912240104360'
,'8202001070107336'
,'8202001070107331'
,'8202011130161031'
,'8202011130161038'
,'8202011130161070'
,'8202012150169476'
,'8202012150169482'
,'8202103240183566'
,'8202103240183583'
,'8202104060185281'
,'8202104060185284'
,'8202104060185307'
,'8202104060185312'
,'8202104060185321'
,'8202104060185329'
,'8202104060185332'
,'8202104060185334'
,'8202104060185335'
,'8202104060185336'
,'8202104060185338'
,'8202104060185341'
,'8202104070185432'
,'8201912240104388'
,'8201912240104394'
,'8201912240104401'
,'8201912240104417'
,'8201912240104422'
,'8201912240104428'
,'8201912240104437'
,'8201912240104442'
,'8201912240104447'
,'8201912240104463'
,'8201912240104469'
,'8201912240104472'
,'8201912240104476'
,'8201912240104480'
,'8202001070107321'
,'8201905080027308'
,'8201905080027320'
,'8202111020211977'
,'8202111020211985'
,'8202111020211988'
,'8201905080027383'
,'8201905080027384'
,'8201905080027385'
,'8201905080027386'
,'8201905080027388'
,'8201905080027391'
,'8201905080027393'
,'8201905080027394'
,'8201905080027395'
,'8201905080027396'
,'8201905080027397'
,'8201905080027398'
,'8201905080027399'
,'8201905080027400'
,'8201905080027401'
,'8201907310051808'
,'8201907310051823'
,'8201907310051835'
,'8201907310051846'
,'8201907310051852'
,'8201909020068234'
,'8201911210095970'
,'8201911210095973'
,'8202001070107175'
,'8202001070107182'
,'8202001070107194'
,'8202001070107198'
,'8202001070107200'
,'8202001070107203'
,'8202001070107206'
,'8202001070107211'
,'8202001070107217'
,'8202001070107223'
,'8202001070107230'
,'8202001070107236'
,'8202001070107237'
,'8202001070107242'
,'8202001070107243'
,'8202001070107250'
,'8202001070107252'
,'8202001070107301'
,'8202003300115003'
,'8202005080123835'
,'8202007030134586'
,'8202104220187697'
,'8202104300188932'
,'8202104300188934'
,'8202105120190126'
,'8202105180190952'
,'8202109290207887'
,'8202110220210392'
,'8202111040212247'
,'8202111040212282'
,'8202111040212351'
,'8202111040212360'
,'8202111040212368'
,'8202111050212480'
,'8202111080212740'
,'8202111090212806'
,'8202111180213999'
,'8202112030216022'
,'8202112030216035'
,'8202112030216045'
,'8202112030216053'
,'8202112030216064'
,'8202112130217218'
,'8201904100023408'
,'8201905080027294'
,'8201905080027302'
,'8201912240104314'
,'8201912240104336'
,'8201912240104375'
);








--------------------------------
select * from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211222;


drop table if exists lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211222;
create table if not exists lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211222 as
select a.mer_id as 商户号
      ,a.mer_name as 商户号名
      ,a.txn_amt/100 as 交易金额
      ,a.txn_dt as 内部交易日期
      ,a.txn_tm as 内部交易时间
      ,b.entr_act_dt as 入账日期
      ,b.chnl_int_srl_nbr as 通道内部流水号
      ,b.cmpn_actv_own_ctrb_amt as 营销活动银行出资金额
      ,b.cmpn_actv_mch_ctrb_amt as 营销活动商户出资金额
      ,b.chnl_trx_srl_nbr as 渠道流水号
      ,b.pay_bnk_id as 支付银行id
      ,b.pay_bnk_nm as 支付银行名
      ,b.wx_usr_id as 微信app用户标识
      ,b.zfb_pmt_usr_id as 买家支付宝用户号
      ,b.pay_acc_id as 支付账户号
      ,b.chnl_typ_id as 通道类型编号
from edw.dpss_pbs_order_info a
left join edw.dwd_bus_chnl_ths_entr_act_di b on b.chnl_trx_srl_nbr = a.txn_seq_id  and b.dt >= '20210101' and b.dt <= '20211209'
where a.dt >= '20210101' and a.dt <= '20201209'
and a.mer_id in  (
    '8202111150213516'
,'8202111040212251'
,'8202111020211988'
,'8202111020211985'
,'8202111020211977'
,'8202111020211967'
,'8202108300203962'
,'8202108300203959'
,'8202108020200417'
,'8202107270199609'
,'8202107080197503'
,'8202107070197350'
,'8202107060197264'
,'8202107060197257'
,'8202107050197093'
,'8202107050197087'
,'8202107050197081'
,'8202107050197072'
,'8202107050197069'
,'8202107050197044'
,'8202106160194545'
,'8202106110194179'
,'8202106110194178'
,'8202106110194174'
,'8202106110194171'
,'8202102050178809'
,'8202102050178805'
,'8202102050178802'
,'8202102050178795'
,'8202011230163756'
,'8202008290144794'
,'8202008130141683'
,'8202008130141612'
,'8202007310139328'
,'8201912240104486'
,'8201912240104287'
,'8201909020068267'
,'8201909020068254'
,'8201907310051942'
,'8201907310051933'
,'8201907310051919'
,'8201907310051902'
,'8201907310051871'
,'8201905080027378'
,'8201905080027377'
,'8201905080027375'
,'8201905080027373'
,'8201905080027372'
,'8201905080027369'
,'8201905080027366'
,'8201905080027362'
,'8201905080027357'
,'8201905080027355'
,'8201905080027352'
,'8201905080027348'
,'8201905080027342'
,'8201905080027336'
,'8201905080027333'
,'8201905080027328'
,'8201905080027320'
,'8201905080027308'
,'8201905080027302'
,'8201905080027296'
,'8201905080027294'
);
**数据需求_20211215_龙海村行_24个月未动账且余额小于100.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-15 17:07:55
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--	村行开业至今24个月未动账且余额小于100的账户数
select --a.dep_act_id
      --,a.cst_act_id
      --,a.cst_id
      --,a.gl_bal
      --,a.bal_late_upd_dt
      --,b.org_nm
      --,datediff(getdate(),to_date(a.bal_late_upd_dt,'yyyymmdd'),'mm') as interval_month
      --,row_number()over(partition by cst_id order by cst_act_id) as rn
      count(distinct cst_act_id) as cst_act_id_num
      ,count(distinct cst_id) as cst_id_num
from edw.dws_bus_dep_act_inf_dd a
left join edw.dim_hr_org_mng_org_tree_dd b on b.org_id = a.opn_org and b.dt = a.dt
where a.dt = '20211214'
and a.act_sts_cd <> 'C'  --剔除销户
and a.lbl_prod_typ_cd='0' --活期
and b.org_nm like '%龙海%'
and a.gl_bal < 100  --余额小于100
and datediff(getdate(),to_date(a.bal_late_upd_dt,'yyyymmdd'),'mm') > 24  --最近24个月未发生动账
order by cst_id,cst_act_id
;
**数据需求_20211222_上海分行泰惠收付款人ID.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-22 10:31:54
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select min(dt)
from edw.dpss_bth_mer_in_acc_dtl
where dt <= '20211201' and dt >= '20210831'
and (tpam_open_id is not null or tpam_buyer_user_id is not null or pay_bank_id is not null)
;

select count(通道内部流水号)   --付款人ID为空的数量
from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215 --客户反映为1.7亿
where 微信app用户标识 <> '' or 买家支付宝用户号 <> '' or 支付账户号 <> ''
;

select * from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215;


SELECT sum(交易金额)
from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215;  --

select dt from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215 group by dt order by dt;

select 商户编号,商户名,交易金额,内部交易日期,内部交易时间,清算日期,入账日期,通道内部流水号,营销活动银行出资金额,营销活动商户出资金额,渠道流水号,微信app用户标识,买家支付宝用户号,支付账户号,通道类型编号 from lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215;

drop table if exists lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215;
create table if not exists lab_bigdata_dev.xt_024618_tmp_suidaitongID_20211215 as
select a.chl_mer_id as 商户编号
      --,b.mer_id as 一级商户号
      ,b.mer_name as 商户名
      ,a.txn_amt as 交易金额
      ,b.txn_dt as 内部交易日期
      ,b.txn_tm as 内部交易时间
      ,a.stlm_date as 清算日期
      ,a.in_acct_date as 入账日期
      ,a.txn_seq_id as 通道内部流水号
      ,a.market_out_amt as 营销活动银行出资金额
      ,a.market_merout_amt as 营销活动商户出资金额
      ,a.chl_txn_ssn as 渠道流水号
      --,a.pay_bank_id as 支付银行id
      --,a.pay_bank_na as 支付银行名
      ,a.tpam_open_id as 微信app用户标识
      ,a.tpam_buyer_user_id as 买家支付宝用户号
      ,a.pay_txn_acc_no as 支付账户号
      ,a.pagy_no as 通道类型编号
      ,a.dt
from edw.dpss_bth_mer_in_acc_dtl a
left join edw.dpss_pbs_order_info b on a.chl_txn_ssn = b.txn_seq_id  and b.dt = a.dt
where (a.dt >= '20210925' and a.dt <= '20211209' or a.dt = '20210923')
and a.chl_mer_id in ('8201905080027328'
,'8201905080027333'
,'8201905080027336'
,'8201905080027342'
,'8201905080027348'
,'8201905080027352'
,'8201905080027355'
,'8201905080027357'
,'8201905080027362'
,'8201905080027366'
,'8201905080027369'
,'8201905080027372'
,'8201905080027373'
,'8201905080027375'
,'8201905080027377'
,'8201905080027378'
,'8201907310051871'
,'8201907310051902'
,'8201907310051919'
,'8201907310051933'
,'8201907310051942'
,'8201909020068254'
,'8201909020068267'
,'8201912240104287'
,'8201912240104486'
,'8202007310139328'
,'8202008130141612'
,'8202008130141683'
,'8202008290144794'
,'8202011230163756'
,'8202102050178795'
,'8202102050178802'
,'8202102050178805'
,'8202102050178809'
,'8202106110194171'
,'8202106110194174'
,'8202106110194178'
,'8202106160194545'
,'8202107050197044'
,'8202107050197069'
,'8202107050197072'
,'8202107050197081'
,'8202107050197087'
,'8202107050197093'
,'8202107060197257'
,'8202107060197264'
,'8202107070197350'
,'8202107080197503'
,'8202107270199609'
,'8202108020200417'
,'8202108300203959'
,'8202108300203962'
,'8202111020211967'
,'8202111040212251'
,'8202111150213516'
,'8201912240104344'
,'8201912240104347'
,'8201912240104352'
,'8201912240104358'
,'8201912240104360'
,'8202001070107336'
,'8202001070107331'
,'8202011130161031'
,'8202011130161038'
,'8202011130161070'
,'8202012150169476'
,'8202012150169482'
,'8202103240183566'
,'8202103240183583'
,'8202104060185281'
,'8202104060185284'
,'8202104060185307'
,'8202104060185312'
,'8202104060185321'
,'8202104060185329'
,'8202104060185332'
,'8202104060185334'
,'8202104060185335'
,'8202104060185336'
,'8202104060185338'
,'8202104060185341'
,'8202104070185432'
,'8201912240104388'
,'8201912240104394'
,'8201912240104401'
,'8201912240104417'
,'8201912240104422'
,'8201912240104428'
,'8201912240104437'
,'8201912240104442'
,'8201912240104447'
,'8201912240104463'
,'8201912240104469'
,'8201912240104472'
,'8201912240104476'
,'8201912240104480'
,'8202001070107321'
,'8201905080027308'
,'8201905080027320'
,'8202111020211977'
,'8202111020211985'
,'8202111020211988'
,'8201905080027383'
,'8201905080027384'
,'8201905080027385'
,'8201905080027386'
,'8201905080027388'
,'8201905080027391'
,'8201905080027393'
,'8201905080027394'
,'8201905080027395'
,'8201905080027396'
,'8201905080027397'
,'8201905080027398'
,'8201905080027399'
,'8201905080027400'
,'8201905080027401'
,'8201907310051808'
,'8201907310051823'
,'8201907310051835'
,'8201907310051846'
,'8201907310051852'
,'8201909020068234'
,'8201911210095970'
,'8201911210095973'
,'8202001070107175'
,'8202001070107182'
,'8202001070107194'
,'8202001070107198'
,'8202001070107200'
,'8202001070107203'
,'8202001070107206'
,'8202001070107211'
,'8202001070107217'
,'8202001070107223'
,'8202001070107230'
,'8202001070107236'
,'8202001070107237'
,'8202001070107242'
,'8202001070107243'
,'8202001070107250'
,'8202001070107252'
,'8202001070107301'
,'8202003300115003'
,'8202005080123835'
,'8202007030134586'
,'8202104220187697'
,'8202104300188932'
,'8202104300188934'
,'8202105120190126'
,'8202105180190952'
,'8202109290207887'
,'8202110220210392'
,'8202111040212247'
,'8202111040212282'
,'8202111040212351'
,'8202111040212360'
,'8202111040212368'
,'8202111050212480'
,'8202111080212740'
,'8202111090212806'
,'8202111180213999'
,'8202112030216022'
,'8202112030216035'
,'8202112030216045'
,'8202112030216053'
,'8202112030216064'
,'8202112130217218'
,'8201904100023408'
,'8201905080027294'
,'8201905080027302'
,'8201912240104314'
,'8201912240104336'
,'8201912240104375'
);
**数据需求_20211229_科企部信贷客户征信查询记录.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-29 18:57:34
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
截止2021年11月30日，我部辖内的所有有余额的信贷客户，
2021全年信贷系统内被查询人行征信的的记录。（包括总的查询次数，以及具体日期、查询人的明细）
*/
--1. 查询人的明细具体是哪些字段？
--2. 信贷客户包括哪些客户：贷款？
--3. 有余额的信贷客户是否就是信贷合同表中2021年11月30日合同余额<>0的客户？
--4. 统计的是我行查询的，还是包括其他机构的查询？
-----------------------------------------------------------20220105 -----------------------------------
select * from cpq_resultinfo cp where cp.cert_no='' and status='1' AND cp.SOURCE = '2'; --对私，通过证件号查询
select * from ceq_resultinfo ce where ce.customer_id='' and status='1' AND ce.SOURCE = '2'; --对公，通过客户号查询
select dt ,count(dt) from edw.ncip_cpq_resultinfo where dt >= '20211101' and dt <= '20211201' group by dt;

select 客户号,count(查询时间) from lab_bigdata_dev.xt_tmp_024618_zhengxinjilu_20211230 group by 客户号;

select 客户号,客户姓名,查询人姓名,查询机构,查询机构名称,接口发起用户,查询时间 from lab_bigdata_dev.xt_tmp_024618_zhengxinjilu_20211230 where 客户号 = '2604166890';
-- 接口发起用户大部分是行内员工工号，少部分是：JRYGY,jzdh,KBPL01,kdh,kdhold
--JRY是金融云那边发起的，2、3、4、5是批量，2.精准贷后； 3-卡批量；4-卡贷后；5-卡贷后-老

drop table if exists lab_bigdata_dev.xt_tmp_024618_zhengxinjilu_20211230;
create table if not exists lab_bigdata_dev.xt_tmp_024618_zhengxinjilu_20211230 as
select a.*
      ,b.empe_nm as 查询人姓名
      ,c.org_nm as 查询机构名称
from (
--对私
select a.cst_id as 客户号
      ,a.cst_chn_nm as 客户姓名
      ,b.ext2 as 查询机构
      ,b.call_sys_user as 接口发起用户
      ,b.query_time as 查询时间
from edw.dws_cst_bas_inf_dd a
left join edw.ncip_cpq_resultinfo b on a.doc_nbr = b.cert_no and b.dt >= '20210101' and b.dt <= '20211231'
where a.dt = '20220101'
and a.cst_typ_cd = '1' --对私客户
and b.status = '1'
union all
--对公
select a.cst_id as 客户号
      ,a.cst_chn_nm as 客户姓名
      ,b.ext2 as 查询机构
      ,b.call_sys_user as 接口发起用户
      ,query_time as 查询时间
from edw.dws_cst_bas_inf_dd a
left join edw.ncip_ceq_resultinfo b on b.customer_id = a.cst_id and b.dt >= '20210101' and b.dt <= '20211231'
where a.dt = '20220101'
and a.cst_typ_cd = '2' --对公客户
and b.status = '1'
) a
left join edw.dws_hr_empe_inf_dd b on b.empe_id = a.接口发起用户 and b.dt = '20220101'
left join edw.dim_hr_org_mng_org_tree_dd c on c.org_id = a.查询机构 and c.dt = '20220101'
where a.客户号 in(
      '2602065635'
,'2601526536'
,'2601986943'
,'2603948428'
,'1670944177'
,'2600682509'
,'2601911100'
,'2601592881'
,'2605827919'
,'2601914127'
,'2002791825'
,'2604037645'
,'2600545004'
,'2603619529'
,'2002917603'
,'1670097840'
,'2600984134'
,'1603008783'
,'2603808313'
,'1603008742'
,'2605623876'
,'2600703481'
,'2600270049'
,'2605563085'
,'2602006149'
,'2002965530'
,'2600433695'
,'2605235262'
,'2600141784'
,'2604450796'
,'2601538634'
,'2600776612'
,'2601259377'
,'1656861395'
,'2605282455'
,'2002588159'
,'2600079650'
,'2604861373'
,'2605868396'
,'2605671112'
,'2603610929'
,'2003229435'
,'1043434113'
,'2600007534'
,'2605673053'
,'2603750432'
,'1637721789'
,'2003217764'
,'2604057822'
,'2605750571'
,'2605359488'
,'2602475627'
,'1614022368'
,'2602465251'
,'2603500857'
,'2601408566'
,'2603497776'
,'2604009358'
,'1653810121'
,'1607021817'
,'2603527761'
,'2605395881'
,'1654516104'
,'2000878564'
,'2600892679'
,'2603024036'
,'2605748306'
,'2605572960'
,'2600522150'
,'2600117539'
,'2602846946'
,'1619704841'
,'2605655011'
,'2603009825'
,'2602085944'
,'2003086883'
,'1635460740'
,'2601496652'
,'2600807549'
,'2601916788'
,'2002363394'
,'2604909480'
,'2003065378'
,'2600843841'
,'2602483114'
,'1011134898'
,'1655012374'
,'2600589591'
,'1654115995'
,'2605439457'
,'2600972426'
,'2602064364'
,'2602025782'
,'2604767475'
,'2605421335'
,'2602533327'
,'2600394087'
,'2604792943'
,'2601434313'
,'2603093354'
,'2605406980'
,'2604930024'
,'2604178735'
,'2003001332'
,'2605205361'
,'1610719150'
,'2605312077'
,'2605185490'
,'1614127257'
,'2600281973'
,'2601277428'
,'1652204301'
,'2602115744'
,'1622032413'
,'2605283498'
,'2605088016'
,'2602028553'
,'2602226418'
,'2600973902'
,'2602784409'
,'2602806840'
,'2601876982'
,'2600835617'
,'1608439155'
,'2601027564'
,'2600791476'
,'2603124399'
,'2601639827'
,'2602022782'
,'2601765930'
,'2604304313'
,'2000443852'
,'2601208743'
,'2601865946'
,'2603050113'
,'2601357055'
,'2601919202'
,'2601914568'
,'2601678679'
,'2601917921'
,'1651874077'
,'2605253734'
,'2600216173'
,'2604629929'
,'2603976191'
,'2601846475'
,'2600162936'
,'2604944265'
,'2605121725'
,'2602929381'
,'2601731811'
,'2603864214'
,'2002991612'
,'2600955861'
,'1620888786'
,'2601753428'
,'1632309420'
,'2003153600'
,'2600412952'
,'2600052693'
,'2605072199'
,'2602844693'
,'2603840226'
,'2600346995'
,'2604352619'
,'1613086771'
,'2601468237'
,'2001295199'
,'2603114506'
,'1649429874'
,'2602743405'
,'2602818945'
,'2601450953'
,'1650052320'
,'2602936885'
,'2600042403'
,'2604934999'
,'1648094638'
,'2601461423'
,'2604900581'
,'2600051407'
,'1649447186'
,'2601215874'
,'1647817323'
,'2600490900'
,'2003072260'
,'2601513560'
,'2602732333'
,'2601323384'
,'2600891636'
,'1044324509'
,'2601666133'
,'2604572758'
,'2002910693'
,'2601278461'
,'2604166890'
,'2602677398'
,'2603632382'
,'2601202141'
,'2602220089'
,'1601614002'
,'2600131290'
,'2002816524'
,'2600675833'
,'2600970597'
,'2602495828'
,'2604753497'
,'1608017361'
,'2604571718'
,'2601182609'
,'2604671004'
,'2600608728'
,'2600052753'
,'2601661956'
,'2602508343'
,'2604723387'
,'2601092832'
,'2600725861'
,'2600614460'
,'2601097383'
,'2604297654'
,'2001867341'
,'2602518312'
,'2604628843'
,'1605264484'
,'2600461221'
,'1603208199'
,'2601518746'
,'2600196689'
,'2601855671'
,'1641811971'
,'2602670086'
,'2600714086'
,'2600625775'
,'2604403576'
,'2603001733'
,'1608709550'
,'1606900402'
,'2604469815'
,'2602498320'
,'2602626078'
,'2601122420'
,'1636629612'
,'2604169890'
,'2604124133'
,'2602087326'
,'2600163044'
,'2604329284'
,'2602290362'
,'2603227949'
,'2002493165'
,'1010521873'
,'2601927722'
,'2604160654'
,'2604299621'
,'1639614468'
,'2600438467'
,'2601927756'
,'2602610980'
,'2601025818'
,'2601720308'
,'2600880295'
,'2600976341'
,'2600967795'
,'2601259353'
,'2602656450'
,'2603301104'
,'2602075941'
,'2601570181'
,'2602065618'
,'2601276867'
,'2603919926'
,'2600791102'
,'2602084514'
,'2602260999'
,'2002950406'
,'2600749079'
,'2600973300'
,'2600610817'
,'2600892426'
,'2600079691'
,'2602515067'
,'1044001446'
,'1042863815'
,'1611453757'
,'1043426417'
,'1632320080'
,'1631848764'
,'1629799499'
,'1604667230'
)
;
**数据需求_20211230_嘉兴分行小企业部授信科_信保信息基金查询.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-12-30 15:56:46
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
嘉兴市小微企业信保基金融资担保有限公司为我行担保客户明细。
涉及所需要字段如下：客户编号，客户名称，管户支行名称，业务品种（为承兑还是流动资金贷款等），借款金额，借款余额，借款合同号，借款起始日，借款到期日，贷款年利率，信保的保函号码
时间：20210101-20211231
*/
select bus_ctr_id
      ,grnt_ctr_id
      ,wrnt_cst_id
      ,wrnt_cst_nm
from edw.dws_bus_grnt_prsn_inf_dd
where dt = '20211229'
and wrnt_cst_nm like '%嘉兴市小微企业信保基金融资担保有限公司%'

select ownerid from edw.loan_guaranty_info where dt = '20211229';
select guarantydescribe,guarantyregno,insurecertno,otherassumpsit,loanrelation,guarantydesire,guarantyeffect from edw.loan_guaranty_info where dt = '20211229';



select ln_ctr_ar_id from edw.dim_old_gnte_ctr_ar_i where dt <= '20211230';
select * from edw.dwd_bus_ibiz_dms_grnt_opn_prm_dd where dt = '20211229';

select count(信贷合同编号) from lab_bigdata_dev.xt_024618_tmp_baohan_20211231;
select 信贷合同编号,客户号,客户名,产品代码,产品名称,主业务品种分类,约定开始日期,约定到期日期,合同金额,合同余额,利率,主管户机构号,管户支行名,保证人担保能力评价 from lab_bigdata_dev.xt_024618_tmp_baohan_20211231;

drop table if exists lab_bigdata_dev.xt_024618_tmp_baohan_20211231;
create table if not exists lab_bigdata_dev.xt_024618_tmp_baohan_20211231 as
select a.busi_ctr_id 信贷合同编号
      ,a.cst_id 客户号
      ,a.cst_nm 客户名
      ,a.pd_cd  产品代码
      ,e.pd_nm 产品名称
      ,e.prm_bus_bred_ctg 主业务品种分类
      ,a.apnt_start_dt 约定开始日期
      ,a.apnt_mtu_dt 约定到期日期
      ,a.ctr_amt 合同金额
      ,a.ctr_bal 合同余额
      ,a.intr_rat 利率
      ,c.prm_org_id 主管户机构号
      ,d.sbr_org_nm 管户支行名
      ,replace(replace(replace(f.guarantydescribe,&quot;\t&quot;,&quot;_&quot;),&quot;\n&quot;,&quot;_&quot;),&quot;,&quot;,&quot;_&quot;) as 保证人担保能力评价
      --,f.guarantydescribe 保证人担保能力评价
      --,substr(f.guarantydescribe,10,12)
      --,case when f.guarantydescribe like '最高额担保函 编号%' then substr(f.guarantydescribe,10,12)
            --when f.guarantydescribe like '最高额担保函编号%'  then substr(f.guarantydescribe,9,12)
            --else f.guarantydescribe
      --end as 最高额担保编号
from edw.dim_bus_loan_ctr_inf_dd a
left join edw.dws_bus_grnt_prsn_inf_dd b on b.bus_ctr_id = a.busi_ctr_id and b.dt = a.dt
left join edw.dws_cst_mng_prm_inf_dd c on c.cst_id = a.cst_id and c.dt = a.dt
left join edw.dim_hr_org_mng_org_tree_dd d on d.org_id = c.prm_org_id and d.dt = a.dt
left join edw.dim_bus_loan_pd_inf_dd e on e.pd_cd = a.pd_cd and e.dt = a.dt
left join edw.loan_guaranty_info f on f.ownerid = b.wrnt_cst_id and f.dt = a.dt
where a.dt = '20211230'
and b.wrnt_cst_nm like '%嘉兴市小微企业信保基金融资担保有限公司%'
;
**数据需求_20220104_宁波分行人行报送重点地区人员个人结算账户信息.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-04 08:42:00
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
根据人行宁波市中心支行《关于报送重点地区人员个人银行结算账户信息的通知》，
根据截至2021年12月31日的存量个人银行结算账户数据，提取重点地区人员（详见附件1）的个人银行结算账户信息，
所需字段详见&ldquo;重点地区个人银行结算账户信息统计表&rdquo;（附件2）
*/
drop table if exists lab_bigdata_dev.xt_tmp_024618_xuqiu_ningbo_renhang_20220104;
create table if not exists lab_bigdata_dev.xt_tmp_024618_xuqiu_ningbo_renhang_20220104
(
    身份证前4位信息 STRING COMMENT '身份证前4位信息'
   ,户籍省 STRING COMMENT '户籍省'
   ,户籍市 STRING COMMENT '户籍市'
);
select * from lab_bigdata_dev.xt_tmp_024618_xuqiu_ningbo_renhang_20220104;

select act_ctg_cd_2 from edw.dim_bus_dep_act_inf_dd where dt = '20220101' group by act_ctg_cd_2;
select * from edw.dim_hr_org_mng_org_tree_dd where dt = '20211231' and brc_org_nm like '%宁波%';
select  cst_act_id,act_thrs_typ,lmt_cmt,lmt_eft_dt from edw.dwd_bus_dep_act_lmt_inf_dd where dt = '20211231' order by cst_act_id,act_thrs_typ;
select distinct act_thrs_typ from edw.dwd_bus_dep_act_lmt_inf_dd where dt = '20211231';
select distinct donjzhgl from edw.core_kdpb_dngjdj where dt <= '20211231' and dt >= '20211201'

select zhanghao,donjlaiy,donjzhgl,djqsriqi,djzzriqi from edw.core_kdpb_dngjdj where dt <= '20211231' and dt >= '20211201' and donjlaiy='2' and donjzhgl in ('10','12','23','11')

--加工出负债账户管控日期
select zhanghao
      --,donjlaiy
      --,donjzhgl
      ,djqsriqi
      ,djzzriqi
      ,case when donjzhgl = '10' then '不收不付控制'
            when donjzhgl in ('12','34') then '只收不付'
            when donjzhgl = '23' then '只付不收控制'
            when donjzhgl = '11' then '金额冻结'
            else ''
      end as 管控类型
from edw.core_kdpb_dngjdj
where dt ='20220101' and donjlaiy='2' and donjzhgl in ('10','12','23','11','34')
and djqsriqi < '20211231'
and djzzriqi > '20211231'
order by zhanghao
;


select dt ,count(*) from edw.core_kdpl_donjmx
where dt <= '20211231' and dt >= '20211201'
group by dt;


select a.zhanghao
      ,a.djzlyuan
      ,a.xzhileix
      ,case when a.xzhileix = '1' then '只收不付'
            when a.xzhileix = '2' then '封闭冻结'
            when a.xzhileix = '3' then '金额冻结'
            when a.xzhileix = '4' then '只付不收'
            else ''
      end as 管控类型
      ,a.djqsriqi
      ,a.djzzriqi
from edw.core_kdpl_donjmx a
left join edw.core_kdpb_dngjdj  b on a.dongjbho = b.dongjbho and b.dt = a.dt
where a.dt = '20220101' and a.djqsriqi<'20211231' and a.djzzriqi> '20211231'
and b.donjlaiy =  '2'
order by a.zhanghao;


select 客户号,客户姓名,客户账号,存款账号,账户状态,证件类型,证件号码,户籍省,户籍市,账户类型,开户行别,开户网点,开户日期,销户日期,开户渠道,手机号,家庭电话,是否暂停非柜面,暂停非柜时间,管控类型,管控开始时间,管控结束时间,最后一笔支出交易日期 from lab_bigdata_dev.xt_tmp_024618_ningborenhang_0104;
-----------------------------------
drop table if exists lab_bigdata_dev.xt_tmp_024618_ningborenhang_0104;
create table if not exists lab_bigdata_dev.xt_tmp_024618_ningborenhang_0104 as
select a.cst_id as 客户号
      ,a.cst_act_id as 客户账号
      ,a.dep_act_id as 存款账号
      ,a.act_sts_cd as 账户状态代码
      ,code1.cd_val_dscr as 账户状态
      ,c.cst_chn_nm as 客户姓名
      ,c.doc_typ_cd as 证件类型代码
      ,code3.cd_val_dscr as 证件类型
      ,c.doc_nbr as 证件号码
      ,d.户籍省
      ,d.户籍市
      ,case when a.act_ctg_cd_2 = '301' then '一类户' when a.act_ctg_cd_2 = '302' then '二类户' when a.act_ctg_cd_2 = '303' then '三类户' else '' end as 账户类型
      ,e.cpy_org_nm as 开户行别
      ,e.sbs_org_nm as 区域合计本级机构名称
      ,e.sbr_org_nm as 开户网点
      ,a.opn_dt as 开户日期
      ,a.act_dstr_act_dt as 销户日期
      ,code4.cd_val_dscr as 开户渠道
      ,c.mbl_nbr as 手机号
      ,c.fml_tel_nbr as 家庭电话
      ,case when h.cst_act_id is not null then '是' else '否'  end 是否暂停非柜面
      ,h.LMT_EFT_DT 暂停非柜时间
      ,i.管控类型
      ,i.djqsriqi as 管控开始时间
      ,i.djzzriqi as 管控结束时间
      -- ,i.管控类型
      -- ,i.djqsriqi as 管控开始日期
      -- ,i.djzzriqi as 管控结束日期
      -- ,case when f.zhjedjbz = '1' then '是' when f.zhjedjbz = '0' then '否' else f.zhjedjbz end 是否账户金额冻结
      -- ,case when f.zhfbdjbz = '1' then '是' when f.zhfbdjbz = '0' then '否' else f.zhfbdjbz end 是否账户封闭冻结
      -- ,case when f.zhzsbfbz = '1' then '是' when f.zhzsbfbz = '0' then '否' else f.zhzsbfbz end 是否账户只收不付
      -- ,case when f.zhzfbsbz = '1' then '是' when f.zhzfbsbz = '0' then '否' else f.zhzfbsbz end 是否账户只付不收
      ,g.trx_dt as 最后一笔支出交易日期
from edw.dim_bus_dep_act_inf_dd a --存款账户信息
join edw.dws_bus_dep_act_inf_dd b on a.dep_act_id=b.dep_act_id and b.dt=a.dt
left join edw.dws_cst_bas_inf_dd c on c.cst_id = a.cst_id and c.dt = a.dt
left join edw.dim_hr_org_mng_org_tree_dd e on e.org_id = a.opn_org and e.dt = a.dt
-- left join edw.core_kdpa_kehuzh f on f.kehuzhao = a.cst_act_id and f.dt = a.dt  --客户账号
left join edw.dwd_code_library code2 on code2.cd_val = a.opn_chnl_cd AND code2.cd_nm LIKE '%渠道%' AND code2.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
left join edw.dwd_code_library code1 on code1.cd_val = a.act_sts_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('dim_bus_dep_act_inf_dd')
left join edw.dwd_code_library code3 on code3.cd_val = c.doc_typ_cd AND code3.cd_nm LIKE '%证件类型%' AND code3.tbl_nm = UPPER('DIM_CST_BAS_DOC_INF_DD')
left join edw.dwd_code_library code4 on code4.cd_val = a.opn_chnl_cd AND code4.cd_nm LIKE '%渠道类型%' AND code4.tbl_nm = UPPER('DIM_BUS_DEP_ACT_INF_DD')
-- left join (
--   select zhanghao
--       --,donjlaiy
--       --,donjzhgl
--       ,djqsriqi
--       ,djzzriqi
--       ,case when donjzhgl = '10' then '不收不付控制'
--             when donjzhgl in ('12','34') then '只收不付'
--             when donjzhgl = '23' then '只付不收控制'
--             when donjzhgl = '11' then '金额冻结'
--             else ''
--       end as 管控类型
--   from edw.core_kdpb_dngjdj
--   where dt ='20220101' and donjlaiy='2' and donjzhgl in ('10','12','23','11','34')
--     and djqsriqi < '20211231'
--     and djzzriqi > '20211231'
-- ) i on i.zhanghao = a.dep_act_id
left join (
  select a.zhanghao
      ,a.djzlyuan
      ,a.xzhileix
      ,case when a.xzhileix = '1' then '只收不付'
            when a.xzhileix = '2' then '封闭冻结'
            when a.xzhileix = '3' then '金额冻结'
            when a.xzhileix = '4' then '只付不收'
            else ''
      end as 管控类型
      ,a.djqsriqi
      ,a.djzzriqi
  from edw.core_kdpl_donjmx a
  left join edw.core_kdpb_dngjdj  b on a.dongjbho = b.dongjbho and b.dt = a.dt
  where a.dt = '20220101' and a.djqsriqi<'20211231' and a.djzzriqi> '20211231'
   and b.donjlaiy =  '2' --2:控制，1:法院冻结
) i on i.zhanghao = a.dep_act_id
left join(
    SELECT CST_ACT_ID
          ,max(LMT_EFT_DT) AS LMT_EFT_DT  --额度生效日期
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20220101'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
) h on h.CST_ACT_ID = a.cst_act_id
left join (
    select dep_act_id
         ,max(trx_dt) as trx_dt
    from edw.dwd_bus_dep_bal_chg_dtl_di
    where dt <= '20220101'
      and crd_and_dbt_ind = 'D' --借贷标志：使用
    group by dep_act_id
) g on g.dep_act_id = a.dep_act_id
inner join lab_bigdata_dev.xt_tmp_024618_xuqiu_ningbo_renhang_20220104 d on substr(trim(c.doc_nbr),1,4)=d.身份证前4位信息  --重点地区
where a.dt = '20220101'
  and b.cst_tp='1' --对私
  and b.lbl_prod_typ_cd='0' --活期
  and a.stl_act_ind ='1' --结算标志为1  --个人结算账户
  and e.brc_org_nm like '宁波分行'      --筛选宁波分行
  and a.ccy_cd = '156'  --筛选人民币
;


select * from lab_bigdata_dev.xt_tmp_024618_ningborenhang_0104;
**数据需求_20220105_线上化_服务经理劳动竞赛.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-05 08:38:36
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
drop table if exists lab_bigdata_dev.xt_tmp_024618_xianshanghua_0105;
create table if not exists lab_bigdata_dev.xt_tmp_024618_xianshanghua_0105 as
SELECT t.id,
	 t.store_name as 商铺名称,
     t.order_id as 订单编号,
     t.user_name as 买家名称,
     t.mail_type as 邮寄方式,
     t.addtime as 下单时间,
     t.paytime as 付款时间,
     t.goods_amount as 商品总价,
     t.totalprice as 订单总额,
     t.payment_name as 支付方式,
     t.channel as 渠道,
     t.order_status as 订单状态,
     t.act_name as 订单活动,
     t.settle_total_price as 商户结算价,
     t.sale_total_price as 商户销售价,
     t.integral_price as 积分价,
	   t.goods_info,
    --  json_extract(t.goods_info,'$.integral_price') as 现金价,
    --  json_extract(t.goods_info,'$.goods_name') as 商品名称,
    --  json_extract(t.goods_info,'$.goods_gsp_val') as 商品规格,
    --  json_extract(t.goods_info,'$.goods_count') as 购买数量,
     t.return_goods_info as 商品退款状态,
     t.msg as 备注
     --,
    --  t2.customer_manager_no &quot;推荐人工号&quot;,
	-- 	 t2.customer_manager_name &quot;推荐人姓名&quot;,
    --  t2.customer_manager_zbranch_name &quot;支行名称&quot;
FROM
     edw.tlsc_sunyardmall_orderform t
-- left join  sunyardmall_orderform_customer_manager t2 on t.id=t2.of_id
WHERE t.dt <= '20211231' and
     t.tenant_code='tlcard' and
     t.addTime between '2021-09-01 00:00:00' and '2021-12-31 23:59:59';

--select dt,count(*) from edw.tlsc_sunyardmall_orderform where dt >= '20211201' and dt <= '20211231' group by dt;
**数据需求_20220110_小企业部_纳税信息_省局大数据用例推广.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-01-10 11:16:12
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
需求字段：客户号、纳税等级、企业本行经营性贷款1年内最高额度、借据号1、法人个人本行经营性贷款1年内最高额度、借据号2、法人个人本行经营性贷款1年内最高月利率、借据号3
、法人个人本行经营性贷款1年内最低月利率、借据号4、管护机构（支行）、客户经理
时间范围：2021年1月1日，截止日期为12月31日
-- 导入客户号
drop table if exists lab_bigdata_dev.xt_tmp_024618_nashui_20220110;
create table if not exists lab_bigdata_dev.xt_tmp_024618_nashui_20220110
(
    cst_type string comment 'cst_type'
   ,cst_id string comment 'cst_id'
);
select * from lab_bigdata_dev.xt_tmp_024618_nashui_20220110;


-- 找到企业客户的法人身份证号
drop table if exists lab_bigdata_dev.xt_tmp_024618_nashui_1_20220110;
create table if not exists lab_bigdata_dev.xt_tmp_024618_nashui_1_20220110 as
select a.cst_type
      ,a.cst_id
      -- ,COALESCE(b.CST_CHN_NM,'')   法定代表人
      -- ,COALESCE(b.PRM_DOC_TYP_CD,'')  法定代表人证件类型
      ,COALESCE(b.PRM_DOC_NBR,'')   法定代表人证件号码
      ,c.cst_id as 法人客户号
from lab_bigdata_dev.xt_tmp_024618_nashui_20220110 a
left join lab_bigdata_dev.TMP03_ORG_20210104 b on a.cst_id = b.CST_ID and b.REL_TYP_CD = '0101'
left join edw.dws_cst_bas_inf_dd c on c.doc_nbr = b.PRM_DOC_NBR and c.cst_typ_cd = '1' and c.dt = '20220101'  --法人客户号
;



-- 加工利率和额度
drop table if exists lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110;
create table if not exists lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 as
select
      b.cst_id
      ,b.dbil_id as 借据号
      ,b.exe_intr_rat/12 as 执行利率月
      ,b.ctr_amt as 合同金额
      ,row_number()over(partition by b.cst_id order by b.exe_intr_rat) as rn1 --最低月利率
      ,row_number()over(partition by b.cst_id order by b.exe_intr_rat desc) as rn2  --最高月利率
      ,row_number()over(partition by b.cst_id order by b.ctr_amt desc) as rn3  --最高额度
from edw.dws_bus_loan_dbil_inf_dd b
where b.dt = '20220101'
and b.loan_usg_cd like '01%'  --经营性贷款
and b.exe_intr_rat is not null
and b.ctr_amt is not null
;

select * from lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 where cst_id = '2605315696';
select * from  edw.dws_bus_loan_dbil_inf_dd where dt = '20220101' and cst_id = '2605315696';


-- 提取最后的数据
drop table if exists lab_bigdata_dev.xt_tmp_024618_nashui_result_20220110;
create table if not exists lab_bigdata_dev.xt_tmp_024618_nashui_result_20220110 as
select a.cst_type
      ,a.cst_id
      ,a.法人客户号
      ,b.prm_mgr_id as 管户经理工号
      ,b.prm_org_id as 管户机构号
      ,c.sbr_org_nm as 管户机构名称支行
      ,t1.合同金额 as 企业本行经营性贷款1年内最高额度
      ,t1.借据号 as 企业最高额度借据号
      ,t2.执行利率月 as 法人本行经营性贷款1年内最低月利率
      ,t2.借据号 as 法人最低月利率借据号
      ,t3.执行利率月 as 法人本行经营性贷款1年内最高月利率
      ,t3.借据号 as 法人最高月利率借据号
      ,t4.合同金额 as 法人本行经营性贷款1年内最高额度
      ,t4.借据号 as 法人最高额度借据号
from lab_bigdata_dev.xt_tmp_024618_nashui_1_20220110 a
left join edw.dws_cst_mng_prm_inf_dd b on a.cst_id=b.cst_id and b.dt = '20220101'  --客户主管护信息
left join edw.dim_hr_org_mng_org_tree_dd c on c.org_id = b.prm_org_id and c.dt = b.dt  --机构树-考核维度
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t1 on t1.cst_id = a.cst_id and t1.rn3 = 1   --企业一年内最高额度
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t2 on t2.cst_id = a.法人客户号 and t2.rn1 = 1  --法人一年内经营性最低月利率
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t3 on t3.cst_id = a.法人客户号 and t3.rn2 = 1  --法人一年内经营性最高月利率
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t4 on t4.cst_id = a.法人客户号 and t4.rn3 = 1  --法人一年内经营性最高额度
;


select * from lab_bigdata_dev.xt_tmp_024618_nashui_result_20220110 order by cst_id;

select * from lab_bigdata_dev.xt_tmp_024618_nashui_result_20220110 where cst_id = '2000592527';







------------------------------------------------------------ 20220110 --------------------------------------------------
-- 提取纳税等级
op table if exists lab_bigdata_dev.xt_tmp_024618_nashui_jibie_120220110;
create table if not exists lab_bigdata_dev.xt_tmp_024618_nashui_jibie_120220110 as
SELECT a.cst_type as 客户类型
      ,a.cst_id as 客户号
      ,b.midcertno as 统一信用代码
      ,c.社会信用代码
      ,c.纳税信用级别
from lab_bigdata_dev.xt_tmp_024618_nashui_120220110 a
left join edw.loan_ent_info b on a.cst_id = b.customerid and b.dt = '20220101'
left join LAB_BIGDATA_DEV.shuiwushuju c on b.midcertno = c.社会信用代码
;


-- 提取额度、利率
drop table if exists lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110;
create table if not exists lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 as
select e.dbil_id as 借据号
      ,a.cst_id as 客户号
      ,e.exe_intr_rat/12 as 执行利率月
      ,e.ctr_amt as 合同金额
      ,row_number()over(partition by e.cst_id order by e.exe_intr_rat) as rn1 --最低月利率
      ,row_number()over(partition by e.cst_id order by e.exe_intr_rat desc) as rn2  --最高月利率
      ,row_number()over(partition by e.cst_id order by e.ctr_amt desc) as rn3  --最高额度
from lab_bigdata_dev.xt_tmp_024618_nashui_20220110 a
left join edw.dws_bus_loan_dbil_inf_dd e on a.cst_id = e.cst_id and e.dt = '20220101'
left join edw.dim_bus_loan_ctr_inf_dd f on e.bus_ctr_id = f.busi_ctr_id and f.dt = e.dt
where e.dtrb_dt >= '20210101' and e.dtrb_dt <= '20211231' --发放日期：近一年
and f.loan_usg_cd like '01%'  --经营性贷款
;

select * from lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 order by 客户号;


select 纳税信用级别
from LAB_BIGDATA_DEV.shuiwushuju;

select * from edw.dim_cst_out_tax_bas_inf_dd where dt = '20220101';

select ptr_clientid,ptr_rating from edw.outd_pub_tax_rating where dt = '20201107' and ptr_rating is not null;


-- 提取需要的数据
drop table if exists lab_bigdata_dev.xt_tmp_024618_nashui_result_20220110;
create table if not exists lab_bigdata_dev.xt_tmp_024618_nashui_result_20220110 as
select a.cst_type
      ,a.cst_id
      -- ,i.ptr_clientid
      ,d.cst_id as cst_id_1
      ,b.prm_mgr_id as 管户经理工号
      ,b.prm_org_id as 管户机构号
      ,c.sbr_org_nm as 管户机构名称支行
      ,d.lgl_psn_doc_id as 法人身份证号码
      ,h.cst_id as 法人客户号
      -- ,i.ptr_rating as 纳税等级
      -- ,j.纳税信用级别
      ,t1.合同金额 as 企业本行经营性贷款1年内最高额度
      ,t1.借据号 as 企业最高额度借据号
      ,t2.执行利率月 as 法人本行经营性贷款1年内最低月利率
      ,t2.借据号 as 法人最低月利率借据号
      ,t3.执行利率月 as 法人本行经营性贷款1年内最高月利率
      ,t3.借据号 as 法人最高月利率借据号
      ,t4.合同金额 as 法人本行经营性贷款1年内最高额度
      ,t4.借据号 as 法人最高额度借据号
from lab_bigdata_dev.xt_tmp_024618_nashui_20220110 a
left join edw.dws_cst_mng_prm_inf_dd b on a.cst_id=b.cst_id and b.dt = '20220101'  --客户主管护信息
left join edw.dim_hr_org_mng_org_tree_dd c on c.org_id = b.prm_org_id and c.dt = b.dt  --机构树-考核维度
left join edw.dim_cst_out_tax_bas_inf_dd d on d.cst_id = a.cst_id and d.dt = b.dt  --纳税人基础信息
left join edw.dim_cst_bas_inf_dd h on d.lgl_psn_doc_id = h.prm_doc_nbr and h.dt = b.dt --客户基本信息：根据身份证号得到法人客户号
-- left join edw.outd_pub_tax_rating i on i.ptr_clientid = a.cst_id and i.dt = '20201107'  --纳税等级信息表
-- left join LAB_BIGDATA_DEV.shuiwushuju j on j.社会信用代码 = d.cnr_crd_cd
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t1 on t1.客户号 = a.cst_id and t1.rn3 = 1   --企业一年内最高额度
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t2 on t2.客户号 = h.cst_id and t2.rn1 = 1  --法人一年内经营性最低月利率
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t3 on t3.客户号 = h.cst_id and t3.rn2 = 1  --法人一年内经营性最高月利率
left join lab_bigdata_dev.xt_tmp_024618_nashui_rate_20220110 t4 on t4.客户号 = h.cst_id and t4.rn3 = 1  --法人一年内经营性最高额度
;


select
from edw.dim_cst_out_tax_bas_inf_dd
where dt = '20211231'
and




-------------------------------------- 20220110晚 ---------------------------------------
select c.dbil_id
      ,b.busi_ctr_id
      ,a.cst_id
      ,c.exe_intr_rat/12 as 执行利率月
      ,c.ctr_amt
      ,d.prm_mgr_id
      ,d.prm_org_id
from lab_bigdata_dev.xt_tmp_024618_nashui_20220110 a
left join edw.dim_bus_loan_ctr_inf_dd b on b.cst_id = a.cst_id and b.dt = '20220101'
left join edw.dws_bus_loan_dbil_inf_dd c on c.bus_ctr_id = b.busi_ctr_id and c.dt = a.dt
left join edw.dws_cst_bas_inf_dd d on d.cst_id = a.cst_id and d.dt = '20220101'
where b.ctr_bal > 0  --有余额


select a.cst_id
      ,t1.lgl_psn_doc_id
from lab_bigdata_dev.xt_tmp_024618_nashui_20220110 a
left join edw.dim_cst_out_tax_bas_inf_dd t1 on a.cst_id = t1.cst_id and t1.dt = '20220101'
**数据需求_20220210_丽水分行信贷客户_添加字段.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2022-02-22 16:44:36
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
create table lab_bigdata_dev.xt_tmp_024618_lishui_0210_1
(
    会计日期  STRING COMMENT '会计日期'
    ,客户号 STRING COMMENT '客户号'
    ,客户名称 STRING COMMENT '客户名称'
    ,信贷归属客户经理 STRING COMMENT '信贷归属客户经理'
    ,信贷归属机构 STRING COMMENT '信贷归属机构'
    ,主管户客户经理 STRING COMMENT '主管户客户经理'
    ,主管户机构 STRING COMMENT '主管户机构'
    ,有效贷款户标识 STRING COMMENT '有效贷款户标识'
    ,本行资产类总额 STRING COMMENT '本行资产类总额'
)
;


select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_1 ;

select 会计日期,客户号,客户名称,信贷归属客户经理,信贷归属机构,主管户客户经理,主管户机构,有效贷款户标识,本行资产类总额,授信金额,用信金额,利率,他行贷款发放机构代码,业务产品种类代码,贷款开始日期,贷款结束日期 from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;





drop table if exists lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;
create table if not exists lab_bigdata_dev.xt_tmp_024618_lishui_0210_2 as
--对公
SELECT t.*
      ,A.loan_start_dt  as 贷款开始日期
      ,A.loan_mtu_dt   as 贷款结束日期
      ,A.loan_amt     as 授信金额
      ,A.loan_bal     as 用信金额
      ,A.dtrb_org_cd as 他行贷款发放机构代码
      ,A.bus_pd_cls_cd AS 业务产品种类代码
      ,code1.cd_val_dscr as 业务产品种类
      ,'' as 利率
	  ,A.report_id
      ,A.id
     ,row_number()over(partition by t.客户号 order by t.本行资产类总额) as rn
FROM lab_bigdata_dev.xt_tmp_024618_lishui_0210_1 t
left join edw.dim_cst_ccrc_entp_loan_inf_dd A   --企业征信客户贷款信息
on t.客户号 = a.cst_id
left join edw.dwd_code_library code1 on code1.cd_val = a.bus_pd_cls_cd and code1.fld_nm = upper('pd_cd') and code1.tbl_nm = 'DIM_BUS_LOAN_CTR_INF_DD'
WHERE A.DT = '20220109'
AND A.dtrb_org_cd NOT LIKE '%ZJTLCB%'  --去掉我行
AND A.act_typ NOT IN ( 'R2' , 'R3' , 'C1' ) --过滤掉贷记卡、准贷记卡、催收账户
AND A.bus_pd_cls_cd not in ('11','12','13')     --过滤掉住房按揭贷款
and a.loan_mtu_dt>= '20211231'
and A.loan_bal>0 --用信金额大于0
union all
-- 对私
SELECT t.*
      ,A.start_dt  as 贷款开始日期
      ,A.mtu_dt    as 贷款结束日期
      ,A.ctr_amt   as 授信金额
      ,A.ctr_bal   as 用信金额
      ,A.dtrb_org  as 他行贷款发放机构代码
      ,A.pd_cd  as 业务产品种类代码
      ,code1.cd_val_dscr as 业务产品种类
    --   ,B.rate      as 利率
	  ,A.report_id
      ,A.id
      ,row_number()over(partition by t.客户号 order by t.本行资产类总额) as rn
FROM lab_bigdata_dev.xt_tmp_024618_lishui_0210_1  t
left join edw.dim_cst_ccrc_idv_loan_inf_dd A  on t.客户号 = a.cst_id
left join edw.dwd_code_library code1 on code1.cd_val = a.pd_cd AND code1.cd_nm LIKE '%存款账户状态%' AND code1.tbl_nm = UPPER('DIM_BUS_LOAN_CTR_INF_DD')
'DIM_BUS_LOAN_CTR_INF_DD'
-- inner JOIN EDW.NCIP_CPQ_ACCOUNT_CALCULATE B
-- ON A.report_id = B.report_id
-- AND A.id = B.id
-- AND B.DT <='20220121'  --需要修改时间为20210101
WHERE A.DT = '20220121' --需要修改时间为20210101
AND A.DTRB_ORG NOT LIKE '%ZJTLCB%'  --去掉我行
AND A.ACT_TYP_CD NOT IN ( 'R2' , 'R3','C1'  ) --过滤掉贷记卡、准贷记卡、催收账户
AND A.pd_cd not in ('11','12','13')     --过滤掉住房按揭贷款
and a.mtu_dt>= '20211231'
and A.ctr_bal>0 --用信金额大于0
;

select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;
select rn from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2 group by rn;

select dt,count(1) from EDW.NCIP_CPQ_ACCOUNT_CALCULATE where dt = '20220201' group by dt;
select dt,count(1) from edw.dim_cst_ccrc_idv_loan_inf_dd where dt >= '20220101' and dt <= '20220111'  group by dt;


select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2  where rn = 120
;

select *
from edw.dim_cst_ccrc_idv_loan_inf_dd
where cst_id = '1042573750'
and dt = '20220109'
;


select 客户号,授信金额,用信金额,利率 from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2  where 授信金额<>用信金额;
select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2 order by 客户号;

select count(distinct 客户号) from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;

select *
from edw.dim_cst_ccrc_idv_loan_inf_dd
where DT = '20220109'
and cst_id in ('1003118668','1003199081','1003007760','1010281155','1003155380','1003170428')
order by cst_id;



AND A.DTRB_ORG NOT LIKE '%ZJTLCB%'  --去掉我行
AND A.ACT_TYP_CD NOT IN ( 'R2' , 'R3','C1'  ) --过滤掉贷记卡、准贷记卡、催收账户
AND A.pd_cd not in ('11','12','13')     --过滤掉住房按揭贷款
and a.mtu_dt>= '20211231'
and A.ctr_bal>0 --用信金额大于0
**数据需求_20220210_丽水分行信贷客户他行贷款.sql
create table lab_bigdata_dev.xt_tmp_024618_lishui_0210_1
(
    会计日期  STRING COMMENT '会计日期'
    ,客户号 STRING COMMENT '客户号'
    ,客户名称 STRING COMMENT '客户名称'
    ,信贷归属客户经理 STRING COMMENT '信贷归属客户经理'
    ,信贷归属机构 STRING COMMENT '信贷归属机构'
    ,主管户客户经理 STRING COMMENT '主管户客户经理'
    ,主管户机构 STRING COMMENT '主管户机构'
    ,有效贷款户标识 STRING COMMENT '有效贷款户标识'
    ,本行资产类总额 STRING COMMENT '本行资产类总额'
)
;


select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_1 ;

select 会计日期,客户号,客户名称,信贷归属客户经理,信贷归属机构,主管户客户经理,主管户机构,有效贷款户标识,本行资产类总额,授信金额,用信金额,利率 from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;





drop table if exists lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;
create table if not exists lab_bigdata_dev.xt_tmp_024618_lishui_0210_2 as
--对公
SELECT t.*
      ,A.loan_start_dt  as 贷款开始日期
      ,A.loan_mtu_dt   as 贷款结束日期
      ,A.loan_amt     as 授信金额
      ,A.loan_bal     as 用信金额
      ,'' as 利率
	  ,A.report_id
      ,A.id
     ,row_number()over(partition by t.客户号 order by t.本行资产类总额) as rn
FROM lab_bigdata_dev.xt_tmp_024618_lishui_0210_1 t
left join edw.dim_cst_ccrc_entp_loan_inf_dd A   --企业征信客户贷款信息
on t.客户号 = a.cst_id
WHERE A.DT = '20220109'
AND A.dtrb_org_cd NOT LIKE '%ZJTLCB%'  --去掉我行
AND A.act_typ NOT IN ( 'R2' , 'R3' , 'C1' ) --过滤掉贷记卡、准贷记卡、催收账户
AND A.bus_pd_cls_cd not in ('11','12','13')     --过滤掉住房按揭贷款
and a.loan_mtu_dt>= '20211231'
and A.loan_bal>0 --用信金额大于0
union all
-- 对私
SELECT t.*
      ,A.start_dt  as 贷款开始日期
      ,A.mtu_dt    as 贷款结束日期
      ,A.ctr_amt   as 授信金额
      ,A.ctr_bal   as 用信金额
      ,B.rate      as 利率
	  ,A.report_id
      ,A.id
      ,row_number()over(partition by t.客户号 order by t.本行资产类总额) as rn
FROM lab_bigdata_dev.xt_tmp_024618_lishui_0210_1  t
left join edw.dim_cst_ccrc_idv_loan_inf_dd A  on t.客户号 = a.cst_id
inner JOIN EDW.NCIP_CPQ_ACCOUNT_CALCULATE B
ON A.report_id = B.report_id
AND A.id = B.id
AND B.DT <='20220109'  --需要修改时间为20210101
WHERE A.DT = '20220109' --需要修改时间为20210101
AND A.DTRB_ORG NOT LIKE '%ZJTLCB%'  --去掉我行
AND A.ACT_TYP_CD NOT IN ( 'R2' , 'R3','C1'  ) --过滤掉贷记卡、准贷记卡、催收账户
AND A.pd_cd not in ('11','12','13')     --过滤掉住房按揭贷款
and a.mtu_dt>= '20211231'
and A.ctr_bal>0 --用信金额大于0
;

select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;
select rn from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2 group by rn;

select dt,count(1) from EDW.NCIP_CPQ_ACCOUNT_CALCULATE where dt = '20220201' group by dt;
select dt,count(1) from edw.dim_cst_ccrc_idv_loan_inf_dd where dt = '20220201' group by dt;


select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2  where rn = 120
;

select *
from edw.dim_cst_ccrc_idv_loan_inf_dd
where cst_id = '1042573750'
and dt = '20220109'
;


select 客户号,授信金额,用信金额,利率 from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2  where 授信金额<>用信金额;
select * from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2 order by 客户号;

select count(distinct 客户号) from lab_bigdata_dev.xt_tmp_024618_lishui_0210_2;

select *
from edw.dim_cst_ccrc_idv_loan_inf_dd
where DT = '20220109'
and cst_id in ('1003118668','1003199081','1003007760','1010281155','1003155380','1003170428')
order by cst_id;



AND A.DTRB_ORG NOT LIKE '%ZJTLCB%'  --去掉我行
AND A.ACT_TYP_CD NOT IN ( 'R2' , 'R3','C1'  ) --过滤掉贷记卡、准贷记卡、催收账户
AND A.pd_cd not in ('11','12','13')     --过滤掉住房按揭贷款
and a.mtu_dt>= '20211231'
and A.ctr_bal>0 --用信金额大于0
**数据需求_sss.sql
-- ODPS SQL 临时查询
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 徐婷
-- 创建日期: 2021-06-18 09:53:29
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

内部数据分析；
1、字段描述：工号，姓名，机构号，机构名称，岗位编码，岗位名称
2、2021-06-17


select p1.empe_id as 员工号
      ,p1.empe_nm as 员工姓名
      ,p1.empe_actv_sts_cd as 在职状态代码
      ,p1.org_id as 机构号
      ,p2.org_id as 机构号p2
      ,p2.org_nm as 机构名称
      ,p1.pos_enc as 职位编号
      ,p3.pos_id as 职位编号p3
      ,p3.pos_nm as 职位名称
from edw.dws_hr_empe_inf_dd p1  --员工汇总信息
left join edw.dim_hr_org_bas_inf_dd p2  --机构信息表
on p1.org_id = p2.org_id
and p2.dt = '20210617'
left join edw.dim_hr_org_job_inf_dd p3 --职位信息
on p1.pos_enc = p3.pos_id
and p3.dt = '20210617'
where p1.dt = '20210617'
;

陕西泾阳泰隆村镇银行财务运营部
内部分析：资源性存款对我行负债业务及综合成本的影响水平
1、字段描述：余额，日均，账户状态，定活标志，付息率，利息支出，管护机构
2、数据日期：2021-01-01至2021-05-31

select dep_act_id as 存款账户
      ,cst_act_id as 客户账户
      ,cst_id as 客户号
      ,gl_bal as 账户总账余额
      ,act_sts_cd as 状态代码
      ,last_day_prvs_intr as 当日应计利息
      ,prvs_intr as 应计利息
      ,lbl_prod_typ_cd as 存款产品类型代码
from edw.dws_bus_dep_act_inf_dd  --存款账户信息汇总表
where dt = '20210531'

需求：
2021年存款波动较大的客户及存款相关信息清单
1、字段描述：客户号，客户名称，管户人，机构，存款余额，存款日均等，见附件。
2、数据日期：2021-01-01至2021-06-15

沟通记录：
分析近一年来存款余额波动比较大的客户的行为
已经挑选出了30天（附件中）
如果结果数据量比较大，拆分成2-3个表
活期存款分为两种，其中科目号为2001（单位）、2003（个人）
定期存款分为两种，其中科目号为2002（单位）、2004（个人）
通知存款只有一种：2005
保证金存款只有一种：2006
select dep_act_id as 存款账户
      ,cst_act_id as 客户账户
      ,cst_id as 客户号
      ,bal_itm_id as 余额科目编号
      ,case when substr(bal_itm_id,1,4) in ('2001','2003') then cur_act_bal else 0 end as dr_hq_amt  --&quot;当日活期存款余额&quot;
      ,case when substr(bal_itm_id,1,4) in ('2001','2003') then last_day_act_bal else 0 end as sr_hq_amt  --&quot;上一日活期存款余额&quot;
      ,case when substr(bal_itm_id,1,4) in ('2002','2004') then cur_act_bal else 0 end as dr_dq_amt  --&quot;当日定期存款余额&quot;
      ,case when substr(bal_itm_id,1,4) in ('2002','2004') then last_day_act_bal else 0 end as sr_dq_amt  -- &quot;上一日定期存款余额&quot;
      ,case when substr(bal_itm_id,1,4) in ('2005') then cur_act_bal else 0 end as dr_tz_amt  --&quot;当日通知存款余额&quot;
      ,case when substr(bal_itm_id,1,4) in ('2005') then last_day_act_bal else 0 end as sr_tz_amt  --&quot;上一日通知存款余额&quot;
      ,case when substr(bal_itm_id,1,4) in ('2006') then cur_act_bal else 0 end as dr_baz_amt  --&quot;当日保证金存款余额&quot;
      ,case when substr(bal_itm_id,1,4) in ('2006') then last_day_act_bal else 0 end as sr_baz_amt  --&quot;上一日保证金存款余额&quot;
      ,cur_act_bal as 当前账户余额
      ,last_day_act_bal as 上日账户余额
from  edw.dim_bus_dep_act_inf_dd  --存款账户信息
where dt = '20210531'
;

select cst_act_id as 客户账户
      ,mgr_id as 管户人编号
      ,acs_org_id as 考核机构编号
from edw.dwd_bus_dep_cst_act_mgr_inf_dd  --客户存款账户管户信息
where dt = '20210531'

to do list:
1. 缺乏客户名、管户人名
2. 筛选波动大于30万元的客户


select cnt_pty_cst_act_id
from edw.dwd_bus_dep_bal_chg_dtl_di
where dt >= '2020103' and dt <= '20201118'
and cst_act_id = '6214808801011341332'
;



select farendma as 法人代码
      ,zhaiyodm as 摘要代码
      ,zhaiyoms as 摘要描述
      ,kehuzhao as 客户账户
      ,jyyyjigo as 交易营业机构
      ,jiaoyije as 交易金额
      ,dt
from edw.core_kdpl_zhminx_p
where dt >= '20210623'
and zhaiyodm in ('DP2137','DP2140','DP2141','DP2142','DP2143')
order by kehuzhao,dt
;

select lgp_id as 法人编号
      ,quo_unt as 牌价单位
      ,avg_prc as 中间价
from edw.dim_bus_com_exr_inf_dd
where dt = '20210623'
;

select p1.jyyyjigo as 交易营业机构
      ,'156' as 交易币种
      ,count(case when p1.zhaiyodm = 'DP2137' then '1' else null end) as qk_trx_cnt --刷脸取款交易笔数
      ,sum(case when p1.zhiyodm = 'DP2137' then abs(p1.jiaoyije * p2.avg_prc / p2.quo_unt) else 0 end) as qk_trx_amt  --刷脸取款交易金额
      ,count(case when p1.zhaiyodm = 'DP2143' then '1' else null end) as hn_trx_cnt --刷脸行内转账交易笔数
      ,sum(case when p1.zhiyodm = 'DP2143' then abs(p1.jiaoyije * p2.avg_prc / p2.quo_unt) else 0 end) as hn_trx_amt  --刷脸行内转账交易金额
from edw.core_kdpl_zhminx_p p1 --账户余额发生明细
inner join edw.dim_bus_com_exr_inf_dd p2  --汇率信息
on p1.jiaoybiz = p2.ccy_cd  --币种
and p2.dt = p1.dt
where p1.dt = '20210623'
and p1.zhaiyodm in ('DP2137','DP2140','DP2141','DP2142','DP2143')
group by p1.jyyyjigo
;



取数字段: 客户姓名，客户号，借据号，管户部门，管户客户经理，贷款还款金额，还款时间（精确至分钟），贷款还款渠道（电子渠道，柜台还是日终批处理等）
select p1.cst_id as 客户编号
      --,p1.cst_nm as 客户名称
      ,p1.dbil_id as 借据号
      ,p1.end_dt as 终结日期
      ,p1.norm_bal as 正常余额
      ,p1.rpay_mth_cd as 还款方式代码
      ,p2.prm_org_id as 主管户机构
      ,p3.cst_mngr_id as 主管户客户经理编号
      ,p3.cst_mngr_nm as 主管户客户经理名称
from edw.dim_bus_loan_dbil_inf_dd p1  --信贷借据信息
left join edw.dws_cst_mng_prm_inf_dd p2  --客户主管户信息
on p1.cst_id = p2.cst_id
and p2.dt = p1.dt
left join edw.dws_bus_loan_dbil_inf_dd p3  --贷款借据信息汇总
on p1.dbil_id = p3.dbil_id
and p3.dt = p1.dt
where p1.dt = '20210625'
and p2.prm_org_id = '320200400'  --张家港支行机构号
and p1.norm_bal = 0
;




select *
from edw.DIM_BUS_COM_TBL_DEP_INF  --数仓表级血缘依赖
where src_guid like '%edw.jcsj_dx2_output%'  --源表guid
and (dst_guid like '%dim%' or dst_guid like '%dwd%' or dst_guid like '%dws%')  --目标表guid
;

select cst_act_id as 客户账户
      ,cst_id as 客户编号
      ,act_rcv_oly_ind as 只收不付标志
      ,act_pay_oly_ind as 只付不收标志
      ,act_amt_frz_ind as 账户金额冻结标志
from edw.dim_bus_dep_cst_act_inf_dd  --客户存款账户信息
where dt = '20210615'
;
**数据需求_上海市支付清算跨行支付系统业务量20210713.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-13 08:42:58
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容

-- 003129-孙晨-用于向上海银行业协会反馈我分行电子支付业务数据
-- 网上支付跨行清算系统业务量	往账口径	笔数（笔）
--		                                  金额（万元）
--	                           来账口径	   笔数（笔）
--		                                  金额（万元）
--口径：2021年2季度，以支付往账与来账口径分别统计，已清算的网上支付跨行清算系统业务的总笔数和总金额。该指标所称网上支付跨行清算系统处理规定金额以下的网上支付业务和账户信息查询业务。网上支付跨行清算系统处理的支付业务包括：网银贷记业务、网银借记业务、第三方贷记业务和中国人民银行规定的其他支付业务。
--银行卡跨行支付系统（银联渠道）业务量	发卡方口径	笔数（笔）
--                                                金额（万元）
--	                                  收单方口径  笔数（笔）
--		                                          金额（万元）
--口径：2021年2季度，以发卡方与收单方口径分别统计，通过银行卡跨行支付系统（银联渠道）成功处理的银行卡交易的总笔数和总金额，包括ATM、POS以及基于银行卡的通过互联网、电话等渠道成功进行的跨行交易，包括存现、取现、消费、转账等业务。
-- **
-- **********************************************************************

SELECT  sum(CASE
              WHEN W.SRFLAG = '0' THEN 1
              ELSE 0
            END)
        ,sum(CASE
               WHEN W.SRFLAG = '0' THEN W.AMT
               ELSE 0
             END)
        ,sum(CASE
               WHEN W.SRFLAG = '1' THEN 1
               ELSE 0
             END)
        ,sum(CASE
               WHEN W.SRFLAG = '1' THEN W.AMT
               ELSE 0
             END)
FROM    edw.wyhl_ibps_pay_trans_reg W  --网银互联支付业务主流水表
INNER JOIN    edw.dim_bus_dep_cst_act_inf_dd B  --客户存款账户信息
ON      W.PAYERACCTNO = B.cst_act_id
AND     B.opn_org_id LIKE '3101%'
AND     B.DT = '20210630'
WHERE   W.DT <= '20210630'
AND     W.TXSTS = 'PR04'
AND     W.WKDT >= '2021-04-01'
AND     W.WKDT <= '2021-06-30'
;

-----上下两端的结果相加
SELECT  sum(CASE
              WHEN W.SRFLAG = '0' THEN 1
              ELSE 0
            END)
        ,sum(CASE
               WHEN W.SRFLAG = '0' THEN W.AMT
               ELSE 0
             END)
        ,sum(CASE
               WHEN W.SRFLAG = '1' THEN 1
               ELSE 0
             END)
        ,sum(CASE
               WHEN W.SRFLAG = '1' THEN W.AMT
               ELSE 0
             END)
FROM    edw.wyhl_ibps_pay_trans_reg W
INNER JOIN    edw.dim_bus_dep_cst_act_inf_dd B
ON      W.RCVERACCTNO = B.cst_act_id
AND     B.opn_org_id LIKE '3101%'
AND     B.DT = '20191231'
WHERE   W.DT <= '20191231'
AND     W.TXSTS = 'PR04'
AND     W.WKDT >= '2019-10-01'
;


-----------------------------------------------------来往账
--发卡方口径
SELECT  COUNT(1) as 发卡方笔数
        ,SUM(AMOUNT) as 发卡方金额
FROM    Edw.frhd_cups_jrnl
WHERE   TELLER = 'SHYLGY'  --操作员
AND     HOST_DATE >= '20210401'
AND     HOST_DATE <= '20210630'
AND     INTO_FLAG = 'T'  --入账标志
AND     RVS_FLAG = 'N'  --冲正标志
AND     MSG_TYPE = '0200'  --消息类型标识
AND     CLEAR_UNIT = '04732900'
AND     DT <= '20210630'
;



--收单方口径
SELECT  COUNT(1) as 收单方笔数
        ,SUM(AMOUNT) as 收单方金额
FROM    Edw.frhd_cups_jrnl
WHERE   TELLER <> 'SHYLGY'
AND     HOST_DATE >= '20210401'
AND     HOST_DATE <= '20210630'
AND     INTO_FLAG = 'T'
AND     RVS_FLAG = 'N'
AND     MSG_TYPE = '0200'
AND     CLEAR_UNIT = '04732900'
AND     DT <= '20210630'
;
**数据需求_两类轮岗岗位内部异动履历20210716.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-16 09:52:24
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************


SELECT empe_id as 员工号
      ,empe_lqd_typ_cd as 员工流动类型代码
      ,lqd_start_dt as 流动开始日期
      ,lqd_end_dt as 流动结束日期
      ,lqd_bfr_org_id as 流动前机构编号
      ,lqd_bfr_org_nm as 流动前机构名称
      ,lqd_aft_org_id as 流动后机构编号
      ,lqd_aft_org_nm as 流动后机构名称
      ,lqd_bfr_pos_id as 流动前职位编号
      ,lqd_bfr_pos_nm as 流动前职位名
      ,lqd_aft_pos_id as 流动后职位编号
      ,lqd_aft_pos_nm as 流动后职位名称
from edw.dwd_hr_empe_lqd_inf_dd
where dt = '20210715'
and lqd_start_dt >= '20160101' and lqd_start_dt <= '20161231'
order by lqd_start_dt
;
**数据需求_半年以上未主动交易20210706.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-06 19:28:40
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select cst_id as 客户编号
      ,cst_nm as 客户名称
      ,
from edw_dev.DIM_BUS_CRD_CR_CRD_INF_DD



select zhanghao as 负债账号
      ,zhhuzwmc as 账户名称
      ,zhhuztai as 账户状态
      ,CASE
           WHEN .ZHUFLDM2 = '301' THEN '10'
           WHEN .ZHUFLDM2 = '302' THEN '11'
           WHEN .ZHUFLDM2 = '303' THEN '12'
           ELSE '19'
         END  AS ACC_TYPE -- 账户类型
      ,kaihriqi as 开户日期
from edw.core_kdpa_zhxinx



select act_org_id as 核算机构编号
      ,act_sts_cd as 账户状态代码

from edw_dev.DIM_BUS_CRD_CR_CRD_ACT_INF_DD


select kehuhaoo as 客户号
      ,SUBSTR(REGEXP_REPLACE(LIANXIDH, &quot;([^0-9]+)&quot;, &quot;&quot;), 1, 15) AS BIND_MOB
from edw_dev.CORE_KCFB_CFDSDL


select cr_crd_act_id as 信用卡账号
       ,SUBSTR(BIL_ADR, 1, 100) AS ADDRESS -- 联系地址
from edw.dim_bus_crd_cr_crd_act_inf_dd





-----------------------------------------------------------------------
select p1.acc_no as 账户账号
      ,p1.open_code as 开户银行金融机构代码
      ,p1.org_id as 开户机构
      ,p2.org_nm as 机构名称
      ,p1.cst_code as 客户编号
      ,p1.acc_name as 账户名称
      ,p1.acc_type as 账户类型
      ,p1.open_date as 开户日期
      ,p1.id_type as 证件种类
      ,p1.id_no as 身份证件号码
      ,p1.address as 联系地址
      ,p1.bind_mob as 绑定的手机号码
      ,p1.id_name2 as 代理人姓名
      ,p1.id_type2 as 代理人证件种类
      ,p1.id_no2 as 代理人证件号码
      ,p3.last_bus_dt as 最近一次交易日期
      ,p3.cur_act_bal as 账户余额
from app_rpt.fct_idv_setl_act_info p1
left join edw.dim_hr_org_bas_inf_dd p2  --机构树_考核维度
on p1.org_id = p2.org_id
and p2.dt = '20210630'
left join edw.dim_bus_dep_act_inf_dd p3
on p1.acc_no = p3.dep_act_id
and p3.dt = '20210630'
where p1.dt = '20210630'
;







---------------------------------------------------------------------------------------------------------
select distinct p1.acc_no as 账户账号
      ,p1.open_code as 开户银行金融机构代码
      ,p1.org_id as 开户机构
      ,p2.org_nm as 机构名称
      ,p1.cst_code as 客户编号
      ,p1.acc_name as 账户名称
      ,p1.acc_type as 账户类型
      ,p1.open_date as 开户日期
      ,p1.id_type as 证件种类
      ,p1.id_no as 身份证件号码
      ,p1.address as 联系地址
      ,p1.bind_mob as 绑定的手机号码
      ,p1.id_name2 as 代理人姓名
      ,p1.id_type2 as 代理人证件种类
      ,p1.id_no2 as 代理人证件号码
      ,p3.last_bus_dt as 最近一次交易日期
      ,p3.cur_act_bal as 账户余额
from app_rpt.fct_idv_setl_act_info p1
left join edw.dim_hr_org_bas_inf_dd p2  --机构树_考核维度
on p1.org_id = p2.org_id
and p2.dt = '20210630'
left join edw.dim_bus_dep_act_inf_dd p3
on p1.acc_no = p3.dep_act_id
and p3.dt = '20210630'
left join EDW.CORE_KDPL_ZHMINX p4
on p1.acc_no = p4.ZHANGHAO
and p4.dt <= '20210630'
left join (
            SELECT  A.ZHANGHAO
                   ,MAX(A.JIAOYIRQ) JIAOYIRQ
            FROM    EDW.CORE_KDPL_ZHMINX A
            WHERE   A.DT <= '20210630'
            AND     JIAOYIRQ >= '20180101'
            AND     JIAOYIRQ <= '20210630'
            AND     zhaiyoms NOT LIKE '%付息%' --排除付息
            GROUP BY A.ZHANGHAO
          ) AA
on p1.acc_no = AA.ZHANGHAO
where p1.dt = '20210630'
and p1.acc_type = '10'
and DATEDIFF(TO_DATE('2021-06-30', 'yyyy-MM-dd'), to_date(AA.JIAOYIRQ, 'yyyyMMdd'), 'MM') >= 6
and p4.zhaiyoms NOT LIKE '%付息%'
AND p4.JIAOYIRQ >= '20180101'
;






------------------------------------------------下午修改-------------------------------------------------
select distinct p1.acc_no as 账户账号
      ,p1.open_code as 开户银行金融机构代码网点
      ,p1.org_code as 开户银行金融机构代码法人
      ,p1.org_id as 开户机构
      ,p2.org_nm as 机构名称
      ,p3.cst_act_id as 客户账号
      ,p1.cst_code as 客户编号
      ,p1.acc_name as 账户名称
      ,p1.acc_type as 账户类型
      ,p1.open_date as 开户日期
      ,p1.id_type as 证件种类
      ,p1.id_no as 身份证件号码
      ,p1.address as 联系地址
      ,p1.bind_mob as 绑定的手机号码
      ,p1.id_name2 as 代理人姓名
      ,p1.id_type2 as 代理人证件种类
      ,p1.id_no2 as 代理人证件号码
      ,p3.last_bus_dt as 最近一次交易日期
      ,p3.cur_act_bal as 账户余额
from app_rpt.fct_idv_setl_act_info p1
left join edw.dim_hr_org_bas_inf_dd p2  --机构树_考核维度
on p1.org_id = p2.org_id
and p2.dt = '20210630'
left join edw.dim_bus_dep_act_inf_dd p3
on p1.acc_no = p3.dep_act_id
and p3.dt = '20210630'
left join EDW.CORE_KDPL_ZHMINX p4
on p1.acc_no = p4.ZHANGHAO
and p4.dt <= '20210630'
left join (
            SELECT  A.ZHANGHAO
                   ,MAX(A.JIAOYIRQ) JIAOYIRQ
            FROM    EDW.CORE_KDPL_ZHMINX A
            WHERE   A.DT <= '20210630'
            AND     JIAOYIRQ >= '20180101'
            AND     JIAOYIRQ <= '20210630'
            AND     zhaiyoms NOT LIKE '%付息%' --排除付息
            GROUP BY A.ZHANGHAO
          ) AA
on p1.acc_no = AA.ZHANGHAO
where p1.dt = '20210630'
and p1.acc_type = '10'
and DATEDIFF(TO_DATE('2021-06-30', 'yyyy-MM-dd'), to_date(AA.JIAOYIRQ, 'yyyyMMdd'), 'MM') >= 6
and p4.zhaiyoms NOT LIKE '%付息%'
AND p4.JIAOYIRQ >= '20180101'
;






---------------------------------------------------------------------------------------------------------
select distinct p1.acc_no as 账户账号
      ,p1.open_code as 开户银行金融机构代码网点
      ,p1.org_code as 开户银行金融机构代码法人
      ,p1.org_id as 开户机构
      ,p2.org_nm as 机构名称
      ,p3.cst_act_id as 客户账号
      ,p1.cst_code as 客户编号
      ,p1.acc_name as 账户名称
      ,p1.acc_type as 账户类型
      ,p1.open_date as 开户日期
      ,p1.id_type as 证件种类
      ,p1.id_no as 身份证件号码
      ,p1.address as 联系地址
      ,p1.bind_mob as 绑定的手机号码
      ,p1.id_name2 as 代理人姓名
      ,p1.id_type2 as 代理人证件种类
      ,p1.id_no2 as 代理人证件号码
      ,p3.last_bus_dt as 最近一次交易日期
      ,p3.cur_act_bal as 账户余额
      ,TT.act_cls_frz_ind AS 账户封闭冻结标志
      ,TT.act_rcv_oly_ind AS 账户只收不付标志
      ,TT.act_amt_frz_ind AS 账户金额冻结标志
      ,TT.act_pay_oly_ind AS 账户只付不收标志
      ,TT.ZFSJ as 止付时间
      ,TT. DJ AS 是否暂停非柜
      ,TT.DJSJ AS 暂停非柜时间
from app_rpt.fct_idv_setl_act_info p1
left join edw.dim_hr_org_bas_inf_dd p2  --机构树_考核维度
on p1.org_id = p2.org_id
and p2.dt = '20210701'
left join edw.dim_bus_dep_act_inf_dd p3
on p1.acc_no = p3.dep_act_id
and p3.dt = '20210701'
left join EDW.CORE_KDPL_ZHMINX p4
on p1.acc_no = p4.ZHANGHAO
and p4.dt <= '20210701'
----------------------
left join
    (SELECT  T1.CST_ACT_ID --客户账号
            ,T1.dep_act_id --存款帐号
            ,T7.act_cls_frz_ind --账户封闭冻结标志
            ,T7.act_rcv_oly_ind --账户只收不付标志
            ,T7.act_amt_frz_ind --账户金额冻结标志
            ,T7.act_pay_oly_ind --账户只付不收标志
        ,CASE
           WHEN T6.CST_ACT_ID IS NOT NULL THEN T6.LMT_EFT_DT
           ELSE ''
         END  ZFSJ--止付时间
        ,CASE
           WHEN T4.CST_ACT_ID IS NOT NULL THEN '是'
           ELSE '否'
         END  DJ--是否暂停非柜
        ,CASE
           WHEN T4.CST_ACT_ID IS NOT NULL THEN T4.LMT_EFT_DT
           ELSE ''
         END DJSJ--暂停非柜时间
            FROM    edw.dim_bus_dep_act_inf_dd T1
            LEFT JOIN    (
                            SELECT  CST_ACT_ID
                                    ,MIN(LMT_EFT_DT) AS LMT_EFT_DT
                            FROM    edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
                            WHERE   DT = '20210701'
                            AND     ACT_THRS_TYP = '2' --暂停非柜面
                            GROUP BY CST_ACT_ID
                        ) T4
            ON      T1.CST_ACT_ID = T4.CST_ACT_ID
            LEFT JOIN    (
                            SELECT  CST_ACT_ID
                                    ,MIN(FRZ_DT) AS LMT_EFT_DT
                            FROM    edw.dwd_bus_dep_frz_inf_dd --账户冻结登记
                            WHERE   DT = '20210701'
                            AND     FRZ_SRC_CD IN ( '1' , '2' ) --冻结来源 1冻结 2控制
                            AND     NFRZ_IND = '0'
                            GROUP BY CST_ACT_ID
                        --未解冻
                        ) T6
            ON      T1.CST_ACT_ID = T6.CST_ACT_ID
            left join edw.dim_bus_dep_cst_act_inf_dd T7
            ON T7.DT='20210701'
            AND T1.cst_act_id=T7.cst_act_id
            WHERE   T1.DT = '20210701'
                ) TT
on p1.ACC_NO=TT.dep_act_id
----------------------
left join (
            SELECT  A.ZHANGHAO
                   ,MAX(A.JIAOYIRQ) JIAOYIRQ
            FROM    EDW.CORE_KDPL_ZHMINX A
            WHERE   A.DT <= '20210630'
            AND     JIAOYIRQ >= '20180101'
            AND     JIAOYIRQ <= '20210630'
            AND     zhaiyoms NOT LIKE '%付息%' --排除付息
            GROUP BY A.ZHANGHAO
          ) AA
on p1.acc_no = AA.ZHANGHAO
where p1.dt = '20210701'
and p1.acc_type = '10'
and DATEDIFF(TO_DATE('2021-06-30', 'yyyy-MM-dd'), to_date(AA.JIAOYIRQ, 'yyyyMMdd'), 'MM') >= 6
and p4.zhaiyoms NOT LIKE '%付息%'
AND p4.JIAOYIRQ >= '20180101'
;




--------------------------------------------------------------------------20210707下午修改
select distinct p1.acc_no as 账户账号
      ,p1.org_id as 开户机构
      ,p5.brc_org_nm as 分行层级机构名称
      ,p5.sbr_org_nm as 支行层级机构名称
      ,p3.cst_act_id as 客户账号
      ,p1.cst_code as 客户编号
      ,p1.acc_name as 账户名称
      ,p1.acc_type as 账户类型
      ,p1.open_date as 开户日期
      ,p1.id_type as 证件种类
      ,p1.id_no as 身份证件号码
      ,p1.address as 联系地址
      ,p1.bind_mob as 绑定的手机号码
      ,p1.id_name2 as 代理人姓名
      ,p1.id_type2 as 代理人证件种类
      ,p1.id_no2 as 代理人证件号码
      ,p3.last_bus_dt as 最近一次交易日期
      ,p3.cur_act_bal as 账户余额
      --,p6.TRSF_SNG_THRS 客户转账单笔限额
      --,p6.TRSF_DAY_THRS 客户转账日累计限额
      ,TT.act_cls_frz_ind AS 账户封闭冻结标志
      ,TT.act_rcv_oly_ind AS 账户只收不付标志
      ,TT.act_amt_frz_ind AS 账户金额冻结标志
      ,TT.act_pay_oly_ind AS 账户只付不收标志
      ,TT.ZFSJ as 止付时间
      ,TT. DJ AS 是否暂停非柜
      ,TT.DJSJ AS 暂停非柜时间
from app_rpt.fct_idv_setl_act_info p1

left join edw.dim_bus_dep_act_inf_dd p3
on p1.acc_no = p3.dep_act_id
and p3.dt = '20210701'
left join EDW.CORE_KDPL_ZHMINX p4
on p1.acc_no = p4.ZHANGHAO
and p4.dt <= '20210701'

left join edw.dim_hr_org_mng_org_tree_dd p5
on p1.org_id = p5.org_id
and p5.dt = '20210701'
--left join app_ado.adm_ebnk_cst_inf p6  --客户基本信息表
--on p1.cst_code=p6.cst_id
--and p6.dt='20210701'

left join
    (SELECT  T1.CST_ACT_ID --客户账号
            ,T1.dep_act_id --存款帐号
            ,T7.act_cls_frz_ind --账户封闭冻结标志
            ,T7.act_rcv_oly_ind --账户只收不付标志
            ,T7.act_amt_frz_ind --账户金额冻结标志
            ,T7.act_pay_oly_ind --账户只付不收标志
        ,CASE
           WHEN T6.CST_ACT_ID IS NOT NULL THEN T6.LMT_EFT_DT
           ELSE ''
         END  ZFSJ--止付时间
        ,CASE
           WHEN T4.CST_ACT_ID IS NOT NULL THEN '是'
           ELSE '否'
         END  DJ--是否暂停非柜
        ,CASE
           WHEN T4.CST_ACT_ID IS NOT NULL THEN T4.LMT_EFT_DT
           ELSE ''
         END DJSJ--暂停非柜时间
            FROM    edw.dim_bus_dep_act_inf_dd T1
            LEFT JOIN    (
                            SELECT  CST_ACT_ID
                                    ,MIN(LMT_EFT_DT) AS LMT_EFT_DT
                            FROM    edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
                            WHERE   DT = '20210701'
                            AND     ACT_THRS_TYP = '2' --暂停非柜面
                            GROUP BY CST_ACT_ID
                        ) T4
            ON      T1.CST_ACT_ID = T4.CST_ACT_ID
            LEFT JOIN    (
                            SELECT  CST_ACT_ID
                                    ,MIN(FRZ_DT) AS LMT_EFT_DT
                            FROM    edw.dwd_bus_dep_frz_inf_dd --账户冻结登记
                            WHERE   DT = '20210701'
                            AND     FRZ_SRC_CD IN ( '1' , '2' ) --冻结来源 1冻结 2控制
                            AND     NFRZ_IND = '0'
                            GROUP BY CST_ACT_ID
                        --未解冻
                        ) T6
            ON      T1.CST_ACT_ID = T6.CST_ACT_ID
            left join edw.dim_bus_dep_cst_act_inf_dd T7
            ON T7.DT='20210701'
            AND T1.cst_act_id=T7.cst_act_id
            WHERE   T1.DT = '20210701'
                ) TT
on p1.ACC_NO=TT.dep_act_id

left join (
            SELECT  A.ZHANGHAO
                   ,MAX(A.JIAOYIRQ) JIAOYIRQ
            FROM    EDW.CORE_KDPL_ZHMINX A
            WHERE   A.DT <= '20210630'
            AND     JIAOYIRQ >= '20180101'
            AND     JIAOYIRQ <= '20210630'
            AND     zhaiyoms NOT LIKE '%付息%' --排除付息
            GROUP BY A.ZHANGHAO
          ) AA
on p1.acc_no = AA.ZHANGHAO
where p1.dt = '20210701'
and p1.acc_type = '10'
and DATEDIFF(TO_DATE('2021-06-30', 'yyyy-MM-dd'), to_date(AA.JIAOYIRQ, 'yyyyMMdd'), 'MM') >= 6
and p4.zhaiyoms NOT LIKE '%付息%'
AND p4.JIAOYIRQ >= '20180101'
;
**数据需求_对公受益人.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-05 14:03:21
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

20210702 温州永嘉上塘小微企业人人行报送 对公受益人信息
------------------------行内---------------------------------------------------------------------------------------
select&nbsp;a.kaihjigo&nbsp;as&nbsp;开户机构
,b.*
,row_number()over(partition&nbsp;by&nbsp;b.客户号&nbsp;order&nbsp;by&nbsp;关联客户编号)&nbsp;as&nbsp;rn
from&nbsp;&nbsp;edw.core_kdpa_kehuzh&nbsp;a&nbsp;&nbsp;--客户账号表
inner&nbsp;join&nbsp;
(
select&nbsp;p1.cst_id&nbsp;as&nbsp;客户号
,p4.opn_dt&nbsp;as&nbsp;创建日期
,p5.cst_chn_nm&nbsp;as&nbsp;客户名
,p1.rel_cst_id&nbsp;as&nbsp;关联客户编号
,p6.cst_chn_nm&nbsp;as&nbsp;关联客户名
,p2.doc_typ_cd&nbsp;as&nbsp;证件类型代码&nbsp;
,p2.doc_nbr&nbsp;as&nbsp;证件号码
,p2.doc_mtu_dt&nbsp;as&nbsp;证件到期日期
,p3.ful_adr&nbsp;as&nbsp;完整地址
,p4.act_rcv_oly_ind&nbsp;as&nbsp;账户只收不付标志
,p4.act_pay_oly_ind&nbsp;as&nbsp;账户只付不收标志
from&nbsp;edw.dim_cst_rel_inf_dd&nbsp;p1&nbsp;&nbsp;--&nbsp;客户关联关系信息
left&nbsp;join&nbsp;edw.dim_cst_bas_doc_inf_dd&nbsp;p2&nbsp;--客户证件信息
on&nbsp;p1.rel_cst_id&nbsp;=&nbsp;p2.cst_id
and&nbsp;p2.dt&nbsp;=&nbsp;p1.dt
and&nbsp;p2.prm_doc_ind&nbsp;=&nbsp;'1'
left&nbsp;join&nbsp;edw.dim_cst_bas_phy_adr_inf_dd&nbsp;p3&nbsp;--客户物理地址信息
on&nbsp;p2.cst_id&nbsp;=&nbsp;p3.cst_id
and&nbsp;p3.dt&nbsp;=&nbsp;p1.dt
left&nbsp;join&nbsp;
(select&nbsp;ppp.*
from&nbsp;(
select&nbsp;cst_id,opn_dt,act_rcv_oly_ind,act_pay_oly_ind,row_number()over(partition&nbsp;by&nbsp;cst_id&nbsp;order&nbsp;by&nbsp;opn_dt)&nbsp;as&nbsp;rn
from&nbsp;edw.dim_bus_dep_cst_act_inf_dd
where&nbsp;dt&nbsp;=&nbsp;'20210701'
and&nbsp;opn_dt&nbsp;>=&nbsp;'20200101'
)ppp&nbsp;&nbsp;where&nbsp;rn&nbsp;=&nbsp;1
)&nbsp;p4&nbsp;on&nbsp;p4.cst_id&nbsp;=&nbsp;p1.cst_id
left&nbsp;join&nbsp;edw.dim_cst_bas_inf_dd&nbsp;p5&nbsp;&nbsp;--客户基本信息
on&nbsp;p1.cst_id&nbsp;=&nbsp;p5.cst_id
and&nbsp;p5.dt&nbsp;=&nbsp;p1.dt
left&nbsp;join&nbsp;edw.dim_cst_bas_inf_dd&nbsp;p6&nbsp;
on&nbsp;p6.cst_id&nbsp;=&nbsp;p1.rel_cst_id
and&nbsp;p6.dt&nbsp;=&nbsp;p1.dt
where&nbsp;p1.dt&nbsp;=&nbsp;'20210701'
and&nbsp;length(p1.rel_cst_id)&nbsp;=&nbsp;'10'
and&nbsp;p1.rel_typ_cd&nbsp;like&nbsp;'09%'
)&nbsp;b
on&nbsp;a.kehuhaoo&nbsp;=&nbsp;b.客户号
where&nbsp;a.dt&nbsp;=&nbsp;'20210701'
and&nbsp;a.kaihjigo&nbsp;in&nbsp;('330500800','330500600')

------------------------------------------------------------------
union&nbsp;all
---------------行外-----------------------------------------------
select&nbsp;a.kaihjigo&nbsp;as&nbsp;开户机构
,b.*
,row_number()over(partition&nbsp;by&nbsp;b.客户号&nbsp;order&nbsp;by&nbsp;关联客户编号)&nbsp;as&nbsp;rn
from&nbsp;&nbsp;edw.core_kdpa_kehuzh&nbsp;a&nbsp;&nbsp;--客户账号表
inner&nbsp;join&nbsp;
(
select&nbsp;p1.cst_id&nbsp;as&nbsp;客户号
,p4.opn_dt&nbsp;as&nbsp;创建日期
,p5.cst_chn_nm&nbsp;as&nbsp;客户名
,p1.rel_cst_id&nbsp;as&nbsp;关联客户编号
,p6.cst_chn_nm&nbsp;as&nbsp;关联客户名
,p2.doc_typ_cd&nbsp;as&nbsp;证件类型代码&nbsp;
,p2.doc_nbr&nbsp;as&nbsp;证件号码
,p2.doc_mtu_dt&nbsp;as&nbsp;证件到期日期
,p2.ctc_adr&nbsp;as&nbsp;完整地址
,p4.act_rcv_oly_ind&nbsp;as&nbsp;账户只收不付标志
,p4.act_pay_oly_ind&nbsp;as&nbsp;账户只付不收标志
from&nbsp;edw.dim_cst_rel_inf_dd&nbsp;p1&nbsp;&nbsp;--&nbsp;客户关联关系信息
left&nbsp;join&nbsp;edw.dim_cst_rel_idv_inf_dd&nbsp;p2&nbsp;--客户行外个人关系人信息
on&nbsp;p1.rel_cst_id&nbsp;=&nbsp;p2.rel_cst_id
and&nbsp;p2.dt&nbsp;=&nbsp;p1.dt
left&nbsp;join&nbsp;
(select&nbsp;ppp.*
from&nbsp;(
select&nbsp;cst_id,opn_dt,act_rcv_oly_ind,act_pay_oly_ind,row_number()over(partition&nbsp;by&nbsp;cst_id&nbsp;order&nbsp;by&nbsp;opn_dt)&nbsp;as&nbsp;rn
from&nbsp;edw.dim_bus_dep_cst_act_inf_dd
where&nbsp;dt&nbsp;=&nbsp;'20210701'
and&nbsp;opn_dt&nbsp;>=&nbsp;'20200101'
)ppp&nbsp;&nbsp;where&nbsp;rn&nbsp;=&nbsp;1
)&nbsp;p4&nbsp;on&nbsp;p4.cst_id&nbsp;=&nbsp;p1.cst_id
left&nbsp;join&nbsp;edw.dim_cst_bas_inf_dd&nbsp;p5&nbsp;&nbsp;--客户基本信息
on&nbsp;p1.cst_id&nbsp;=&nbsp;p5.cst_id
and&nbsp;p5.dt&nbsp;=&nbsp;p1.dt
left&nbsp;join&nbsp;edw.dim_cst_bas_inf_dd&nbsp;p6&nbsp;
on&nbsp;p6.cst_id&nbsp;=&nbsp;p1.rel_cst_id
and&nbsp;p6.dt&nbsp;=&nbsp;p1.dt
where&nbsp;p1.dt&nbsp;=&nbsp;'20210701'
and&nbsp;length(p1.rel_cst_id)&nbsp;=&nbsp;'20'
and&nbsp;p1.rel_typ_cd&nbsp;like&nbsp;'09%'
)&nbsp;b
on&nbsp;a.kehuhaoo&nbsp;=&nbsp;b.客户号
where&nbsp;a.dt&nbsp;=&nbsp;'20210701'
and&nbsp;a.kaihjigo&nbsp;in&nbsp;('330500800','330500600')

--------------------------------------------------------------------------------------------------------------------------------
**数据需求_我行员工申请泰惠收商户的数据20210721.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-21 14:03:37
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--泰惠收：未注销商户中，法人/店长证件号与行内人力系统员工证件号相匹配的商户信息。

select a.mch_id as 商户编号
     ,a.mch_sht_nm as 商户简称
     ,a.mch_nm as 商户名称
     ,a.con_nm as 联系人姓名
     ,a.con_tel_nbr as 联系电话
     ,a.lgp_nm as 法人姓名
     ,a.lgp_doc_typ_cd as 法人证件类型代码
     ,a.lgp_doc_nbr as 法人证件号码
     ,a.lgp_tel_nbr as 法人联系电话
     ,a.reg_dt as 注册日期
     ,a.mch_sts_cd as 商户状态代码
     ,b.empe_id as 员工号
     ,b.empe_nm as 员工姓名
from edw.dws_bus_chnl_ths_mch_inf_dd a
inner join edw.dws_hr_empe_inf_dd b
on a.lgp_doc_nbr = b.doc_nbr
and b.dt = a.dt
where dt = '20210717'
;


select
from edw.dws_hr_empe_inf_dd
where dt = '20210717'
**数据需求_手机银行限额20万_20210708.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-08 16:39:23
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
edw.ebnk_cb_cst_channel_inf 企业客户渠道信息表
edw.ebnk_pb_cstinf_channel  个人渠道信息表（新增）


select * --count(客户号)
from
(



--互联网金融部手机银行限额20万
select
      distinct
      p1.cip_cstno as 客户号
      ,case when p2.pcc_bankid = '020200' then '母行' ELSE '村行' end as 母行或村行
      ,p1.cip_limitsinglemobile as 手机客户约定单笔限额
      ,p1.cip_limitmobile as 手机客户约定日累计限额
      ,p2.pcc_outsiglelimit as 个人手机银行自定义对外资金单笔限额
      ,p2.pcc_outdaylimit as 个人手机银行自定义对外资金日累计限额
      ,p2.pcc_branchid 开通机构
      ,p3.sbr_org_nm 开通机构名称
      ,p2.pcc_createtime as 开通时间
          ,(case
            when p2.pcc_opentype = '0' then '手机自主注册'
            when p2.pcc_opentype = '2' then '网银自主注册'
            when p2.pcc_opentype = '1' then '柜面注册'
            when p2.pcc_opentype = '3' then '自助平台'
            else '-'
          end) as 开通方式
      ,p2.pcc_tellerid as 开通操作员
          ,(case
            when p2.pcc_defaulttype = '00' then '无认证方式'
            when p2.pcc_defaulttype = '01' then '弱认证方式'
            when p2.pcc_defaulttype = '10' then '证书'
            when p2.pcc_defaulttype = '11' then '令牌'
            when p2.pcc_defaulttype = '12' then '短信'
            else 'TYPE'
          end) as 认证方式
from edw.ebnk_pb_cstinf_main p1  --个人客户信息表
inner join edw.ebnk_pb_cstinf_channel p2  --个人渠道信息表（新增）
    on p1.cip_cstno = p2.pcc_cstno
    and p2.dt = '20210712'
    and p2.pcc_channel = '2'
left join edw.dim_hr_org_mng_org_tree_dd p3
  on p2.pcc_branchid=p3.sbr_org_id
  and p3.dt='20210712'
where p1.dt = '20210712'
and
(p1.cip_limitsinglemobile=200000
or
p1.cip_limitmobile=200000)




) ppp
where ppp.客户号 = '1006003552'
;
**数据需求_活期结算账户是否已被关闭非柜面业务权限20210714.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-14 14:13:33
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

--财富管理部运营管理中心  杨菲  008827
--4个excel清单中的客户活期结算账户是否已经关闭非柜面业务权限
--数据日期：20210515-20210708
--stl_act_ind = '1'  --结算账户标志
--lbl_prod_typ_cd = '0' --存款产品类型代码（0：活期；1：定期）



create table xt_guimian_024618_20210714_1  --16周岁以下
(
    客户账号  STRING COMMENT '客户账号'
)
;
-----
create table xt_guimian_024618_20210714_2  --睡眠户
(
    客户账号  STRING COMMENT '客户账号'
)
;
-----
create table xt_guimian_024618_20210714_3  --一人多卡
(
    客户账号  STRING COMMENT '客户账号'
)
;
-----
create table xt_guimian_024618_20210714_4  --一号多人
(
    客户号  STRING COMMENT '客户号'
)
;

------------------------------------------------------------------------------
---------------------1   16周岁以下
select p1.cst_act_id as 客户账号
      ,p1.cst_id as 客户号
      ,p1.opn_dt as 开户日期
      ,case
        when p2.CST_ACT_ID is not null then '是'
        else '否'
      end 是否暂停非柜
      ,case
        when p2.CST_ACT_ID is not null then p2.LMT_EFT_DT
        else ''
       end 暂停非柜时间
from edw.dws_bus_dep_act_inf_dd p1 --存款账户信息汇总
left join (
    SELECT  CST_ACT_ID
        ,MIN(LMT_EFT_DT) AS LMT_EFT_DT
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20210713'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
    ) p2
on p1.cst_act_id = p2.CST_ACT_ID
where p1.dt = '20210713'
and p1.stl_act_ind = '1'  --结算账户标志
and p1.lbl_prod_typ_cd = '0' --存款产品类型代码（0：活期；1：定期）
and p1.cst_act_id in
    (
    select 客户账号 from lab_bigdata_dev.xt_guimian_024618_20210714_1
    )
;

-----------------2   睡眠户
select p1.cst_act_id as 客户账号
      ,p1.cst_id as 客户号
      ,p1.opn_dt as 开户日期
      ,case
        when p2.CST_ACT_ID is not null then '是'
        else '否'
      end 是否暂停非柜 --是否暂停非柜
      ,case
        when p2.CST_ACT_ID is not null then p2.LMT_EFT_DT
        else ''
       end 暂停非柜时间
from edw.dws_bus_dep_act_inf_dd p1 --存款账户信息汇总
left join (
    SELECT  CST_ACT_ID
        ,MIN(LMT_EFT_DT) AS LMT_EFT_DT
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20210713'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
    ) p2
on p1.cst_act_id = p2.CST_ACT_ID
where p1.dt = '20210713'
and p1.stl_act_ind = '1'  --结算账户标志
and p1.lbl_prod_typ_cd = '0' --存款产品类型代码（0：活期；1：定期）
and p1.cst_act_id in
    (
    select 客户账号 from lab_bigdata_dev.xt_guimian_024618_20210714_2
    )
;


----------------3   一人多卡
select p1.cst_act_id as 客户账号
      ,p1.cst_id as 客户号
      ,p1.opn_dt as 开户日期
      ,case
        when p2.CST_ACT_ID is not null then '是'
        else '否'
      end 是否暂停非柜 --是否暂停非柜
      ,case
        when p2.CST_ACT_ID is not null then p2.LMT_EFT_DT
        else ''
       end 暂停非柜时间 --暂停非柜时间
from edw.dws_bus_dep_act_inf_dd p1 --存款账户信息汇总
left join (
    SELECT  CST_ACT_ID
        ,MIN(LMT_EFT_DT) AS LMT_EFT_DT
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20210713'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
    ) p2
on p1.cst_act_id = p2.CST_ACT_ID
where p1.dt = '20210713'
and p1.stl_act_ind = '1'  --结算账户标志
and p1.lbl_prod_typ_cd = '0' --存款产品类型代码（0：活期；1：定期）
and p1.cst_act_id in
    (
    select 客户账号 from lab_bigdata_dev.xt_guimian_024618_20210714_3
    )
;


------------------4  一号多人
select p1.cst_act_id as 客户账号
      ,p1.cst_id as 客户号
      ,p1.opn_dt as 开户日期
      ,case
        when p2.CST_ACT_ID is not null then '是'
        else '否'
      end 是否暂停非柜 --是否暂停非柜
      ,case
        when p2.CST_ACT_ID is not null then p2.LMT_EFT_DT
        else ''
       end 暂停非柜时间 --暂停非柜时间
from edw.dws_bus_dep_act_inf_dd p1 --存款账户信息汇总
left join (
    SELECT  CST_ACT_ID
        ,MIN(LMT_EFT_DT) AS LMT_EFT_DT
    FROM edw.dwd_bus_dep_act_lmt_inf_dd --账户额度控制
    WHERE DT = '20210713'
    AND ACT_THRS_TYP = '2' --暂停非柜面
    GROUP BY CST_ACT_ID
    ) p2
on p1.cst_act_id = p2.CST_ACT_ID
where p1.dt = '20210713'
and p1.stl_act_ind = '1'  --结算账户标志
and p1.lbl_prod_typ_cd = '0' --存款产品类型代码（0：活期；1：定期）
and p1.cst_id in
    (
    select 客户号 from lab_bigdata_dev.xt_guimian_024618_20210714_4
    )
;
**数据需求_湖北大冶诊断式检查.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-12 11:02:15
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************


--  1 &quot;冻结登记簿&quot;
select distinct
    A.DONGJBHO AS 冻结编号,
    F.kaihjigo AS 开户机构,
    F.zhhuzwmc AS 账户名称,
    A.KEHUZHAO AS 客户账号,
    substr(A.KEHUZHAO,1,4) as 客户账号1,
    substr(A.KEHUZHAO,5,length(A.KEHUZHAO)) as 客户账号2,
    '' AS 子账户序号,
    CASE
        WHEN A.JIEDONBZ = '1' THEN '1-已解冻'
        ELSE '0-已解冻'
    END AS 冻结标志,
    code1.cd_val_dscr as 冻结种类,
    '' AS 冻结类型,
    code2.cd_val_dscr as 冻结范围,
    A.XUDONJJE AS 需冻金额,
    A.XNDONJJE AS 现冻金额,
    A.LJDONJJE AS 累计解冻金额,
    A.DONJSHIJ AS 冻结时间,
    A.DJQSRIQI AS 冻结开始日期,
    A.DJZZRIQI AS 冻结到期日期,
    A.donjlaiy as 冻结来源   --未找到

from edw.core_kdpb_dngjdj A    --负债账户冻结登记簿
left join edw.core_kdpa_zhxinx F    --负债账户信息表
ON A.KEHUZHAO = F.KEHUZHAO
and F.dt = '20210701'
left join edw.dwd_code_library code1 on code1.cd_val = A.donjzhgl and code1.fld_nm like upper('donjzhgl')
left join edw.dwd_code_library code2 on code2.cd_val = A.donjfanw and code2.fld_nm like upper('donjfanw')
WHERE A.DT = '20210701'
AND F.KAIHJIGO like '4261%'
AND A.djqsriqi >= '20190101'
AND A.djqsriqi <= '20210630'
;
-----------------------------------------------------------------------------------







-- 2 挂失登记簿
select
distinct
A.GUASHIRQ AS 挂失日期,
A.GUASCLBH AS 挂失处理编号,
F.CST_CHN_NM AS 客户名称,
A.KEHUZHAO AS 客户账号,
substr(A.KEHUZHAO,1,6) as 客户账号1,
substr(A.KEHUZHAO,7,length(A.KEHUZHAO)) as 客户账号2,
code1.cd_val_dscr as 挂失解挂标志,
A.KEHUHAOO AS 客户号,
A.PINGZHZL AS 凭证类型,
A.PNGZPHAO AS 凭证批号,
A.QISHIPZH AS 起始凭证号,
A.ZZPZHHAO AS 终止凭证号,
A.gsrzjzle AS 挂失人证件种类,
A.GUASRZJH AS 挂失人证件号码,
A.DAILREMC AS 挂失代理人名称,
A.dlzjzlei AS 代理人证件种类,
A.DAILRZJH AS 代理人证件号码,
A.JIAOYIGY AS 挂失柜员,
A.GUASJYLS AS 挂失流水号,
A.SHOQGUIY AS 授权柜员,
A.JIAGUARQ AS 解挂日期,
A.JIAOYIGY AS 解挂柜员,
A.JIEGGYLS AS 解挂流水号,
A.SHOQGUIY AS 解挂授权柜员,
A.JGDLIRMC AS 解挂代理人名称,
A.jgdlzjzl AS 解挂代理人证件类型,
A.JGDLRZJH AS 解挂代理人证件号码,
A.DSPZSYZT AS 凭证状态,
A.QUDAOOOO AS 渠道号,
A.JYYYJIGO AS 机构号,
CASE
    WHEN A.SHIFOUBZ = '0' THEN '0-只进不出'
    ELSE ''
END AS 挂失封闭标志
FROM EDW.CORE_KCEB_GSDJII A
left join edw.dwd_code_library code1 on code1.cd_val = A.gsjgbzhi and code1.fld_nm like upper('gsjgbzhi')
LEFT JOIN edw.DIM_CST_BAS_INF_DD F
ON A.KEHUHAOO = F.CST_ID
AND F.DT = '20210711'
WHERE A.DT = '20210711'
AND A.GUASHIRQ BETWEEN '20190101' AND '20210630'
AND A.JYYYJIGO like '4261%'
;
------------------------------------------------------



-- 3 扣划登记簿
select
    a.kouhabho as 扣划编号,
    a.dongjbho as 冻结编号,
    b.zhhuzwmc as 账户名称,
    a.kehuzhao 客户账号,
    e.ZHHAOXUH as 子账户序号,
    '' 扣划种类,
    case
        when a.KOUHUAFS = '1' then '1-直接扣划'
        when a.KOUHUAFS = '0' then '0-冻结扣划'
        else ''
    end 扣划方式,
    a.KOUHUAJE as 扣划金额,
    a.DXZHXHAO as 待销账序号,
    a.JIAOYIJG as 扣划办理机构,
    a.JINBGUIY as 经办人,
    a.FUHEGUIY as 复核人,
    a.JIAOYISJ as 扣划时间,
    a.JIAOYIRQ as 扣划日期,
    a.KHWSHAOO as 扣划文书号,
    a.ZFBMLEIX as 执法部门名称,
    a.khryzle1 as 执法人员1证件类型,
    a.KHRYZJH1 as 执法人员1证件号码,
    a.KHRYXMM1 as 执法人员1姓名,
    a.khryzle2 as 执法人员2证件类型,
    a.KHRYZJH2 as 执法人员2证件号码,
    a.KHRYXMM2 as 执法人员2姓名
from edw.core_kdpb_kouhua a    --负债账户扣划登记簿
left join edw.core_kdpa_zhxinx b   --负债账户信息表
on a.zhanghao = b.zhanghao
and b.dt = a.dt
left join edw.core_kdpa_zhbcxx  e     --账户信息补充表
on a.zhanghao = e.zhanghao
and e.dt = a.dt
where a.dt = '20210701'
and a.JIAOYIRQ >= '20190101' AND a.JIAOYIRQ <='20210630'
and a.JIAOYIJG like '4261%'
;
-----------------------------------------------------------------





-- 4 柜面有权机关信息登记表
select
a.yqjgleixing as 有权机关类型,
a.YQJGMINGCHENG  as 有权机关名称,
a.KHZHANGHAO as 客户账号,
a.KHMINGCHENG as 客户名称,
a.khzjleixing as 客户证件类型,
a.KHZJHAOMA as 客户证件号码,
a.ZFRYAMINGCHENG as 执法人员姓名1,
a.zfryazjleixing as 执法人员证件类型1,
a.ZFRYAZJHAOMA as 执法人员证件号码1,
a.ZFRYBMINGCHENG as 执法人员姓名2,
a.zfrybzjleixing as 执法人员证件类型2,
a.ZFRYBZJHAOMA as 执法人员证件号码2,
'' as 执行案号,
a.FLWSMINGCHENG as 法律文书名称,
a.FLWSBIANHAO as 法律文书编号,
a.REMARK1 as 备注,
a.JBJIGOU as 经办机构名称,
a.JBRIQI as 经办日期,
a.JBSHIJIAN as 经办时间,
a.JBGUIYUAN as  经办柜员,
a.FHGUIYUAN as 复核柜员,
a.CXQUDAO as 渠道名称,
case
    when a.SFXIUGAI = '1' then '1-是'
    when a.SFXIUGAI = '0' then '0-否'
end 修改标志,
a.XGJBGUIYUAN as 修改经办柜员,
a.XGFHGUIYUAN as 修改复核柜员,
a.XGJIGOU as 修改机构,
a.XGRIQI as 修改日期,
a.XGSHIJIAN as 修改时间,
a.XGNEIRONG as 修改原因,
a.YXPCH as 影像批次号
from  edw.afas_afa_yqjg_register a    --柜面有权机关信息登记表
where a.dt = '20210701'
and a.JBRIQI BETWEEN '2019-01-01' AND '2021-06-30'
and a.JBJIGOU  like '4261%'
;
-----------------------------------------------------------------






-- 5 企业账户核心开销户清单
select distinct
      a.kehuzhao as 客户账号
      ,a.zhhuzwmc as 账户名称
      ,a.zhujigoh as 账户所属机构
      ,b.cst_act_id as 客户号
      ,code1.cd_val_dscr as 账户状态
      ,code2.cd_val_dscr as 账户性质
      ,a1.opn_org as 开户机构
      ,a1.opn_dt as 开户日期
      ,a1.act_opn_tlr as 账户开户柜员
      ,a1.act_dstr_act_org as 账户销户机构
      ,a1.act_dstr_act_dt as 账户销户日期
      ,a1.act_dstr_act_tlr as 账户销户柜员
      ,a2.yxxjzqbz as 允许现金支取标志
      ,case
        when a2.yxxjzqbz = '1' then '是'
        when a2.yxxjzqbz = '0' then '否'
        else ''
      end as 是否允许现金支取
      ,c.mbl_nbr as 手机号
      ,a4.open_permit_no as 开户许可证
from edw.core_kdpb_kxhudj a  --开销户登记簿
left join edw.dim_bus_dep_act_inf_dd a1
on a.kehuzhao = a1.cst_act_id
and a1.dt = a.dt
left join edw.core_kdpa_zhxinx a2
on a.kehuzhao = a2.zhanghao
and a2.dt = a.dt
left join edw.dwd_code_library code1 on code1.cd_val = a1.act_sts_cd and code1.fld_nm like upper('act_sts_cd')
left join edw.dwd_code_library code2 on code2.cd_val = a1.act_ctg_cd_1 and code2.fld_nm like upper('act_ctg_cd_1')
left join edw.dws_bus_dep_act_inf_dd b
on a.kehuzhao = b.cst_act_id
and b.dt = '20210701'
left join edw.ecif_t00_org_cust_no_rec a3
on b.cst_act_id = a3.cust_no
and a3.dt = a.dt
left join edw.ecif_t01_org_cust_extend_info a4
on a4.party_id = a3.party_id
and a4.dt = a.dt
left join edw.dws_cst_bas_inf_dd c
on b.cst_id = c.cst_id
and c.dt = '20210701'
where a.dt = '20210701'
and a.jiaoyirq between '2019-01-01' AND '2021-06-30'
and a.kehuzhlx = '0' --对公的
and a.jiaoyijg like '4261%'
;
-------------------------------------------------------------------------



 SELECT  CUST_NO
                         ,OPEN_PERMIT_NO
                 FROM    EDW.ECIF_T01_ORG_CUST_EXTEND_INFO A
                 INNER JOIN    EDW.ECIF_T00_ORG_CUST_NO_REC B
                 ON      A.PARTY_ID = B.PARTY_ID
                 AND     b.dt = '@@{yyyyMMdd}'
                 WHERE   a.DT = '@@{yyyyMMdd}'
                 GROUP BY CUST_NO , OPEN_PERMIT_NO









-- 6 核心业务系统印鉴卡变更清单
select a.jigouhao as 机构号
      ,a.pngzphao as 凭证批号
      ,a.pngzxhao as 凭证序号
      ,code1.cd_val_dscr as 印鉴状态
      ,a.kehuzhao as 客户账号
      ,a.zhanghmc as 账户名称
      ,code2.cd_val_dscr as 印鉴卡操作标志
      ,a.weihriqi as 维护日期
      ,a.guiydaih as 柜员代码
from edw.core_kceb_gyyjia a --柜员印鉴库存表
left join edw.dwd_code_library code1 on code1.cd_val = a.yinjztai and code1.fld_nm like upper('yinjztai')
left join edw.dwd_code_library code2 on code2.cd_val = a.yjkczbzh and code2.fld_nm like upper('yjkczbzh')
where a.dt = '20210701'
and a.weihriqi between '2019-01-01' AND '2021-06-30'
and a.jigouhao like '4261%'
;
**数据需求_福建政和泰隆报送人行20210701.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-01 10:29:18
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
报送当地人行数据
福建政和泰隆村镇银行营业部服务中心
大小额支付的笔数，金额（按支行分开统计）
日期：20210401-20210630
项宇博 012116
*/


福建政和泰隆村镇银行需求
取出大额、小额交易明细
取数逻辑：edw.dwd_bus_chnl_spmt_lrg_amt_pay_inf_di 和 edw.spmt_t_beps_paymentbook 中分别取出大额和小额的 平台交易流水号、往来标志、业务借贷标志、客户所属开户网点
筛选条件：日期范围20210401-20210630、福建政和泰隆村镇银行
需求人自行筛选往来标志和借贷标志，分别按照大小额 汇总平台流水号、加总交易金额即可

create table if not exists tmp_zhenghe_0702_024618
as
select a.*
from
(
--大额交易信息明细
select plf_srl_nbr as 平台交易流水号
      ,'大额' as 大小额
      ,ctc_id as 往来标志   --  1-往账；2-来账
      ,bus_crd_and_dbt_id as 业务借贷标志   -- 1-贷；2-借
      ,cst_afl_opn_brn as 客户所属开户网点
      ,trx_amt as 交易金额
from edw.dwd_bus_chnl_spmt_lrg_amt_pay_inf_di  --大额单笔支付信息
where dt >= '20210401' and dt <= '20210630'
and acc_sub_brn = '356100000'
union all
--小额交易信息明细
select agentserialno as 平台交易流水号
      ,'小额' as 大小额
      ,mbflag as 往来标志  --  1-往账；2-来账
      ,payflag as 借贷标志  -- 1-贷；2-借
      ,accbrno as 客户所属开户网点
      ,amount as 交易金额
from edw.spmt_t_beps_paymentbook  --小额单笔支付信息
where dt >= '20210401' and dt <= '20210630'
and zhno = '356100000'
) a




--                    =========================以下为草稿=================================




select agentserialno as 平台流水号
      ,mbflag as 往来标志
      ,payflag as 借贷标志
      ,zoneno as 受理分行
      ,zhno as 受理支行
      ,brno as 受理网点
      ,accbrno as 客户所属开户网点
      ,amount as 交易金额
      ,realamount as 实际交易金额
from edw.spmt_t_beps_paymentbook  --小额单笔支付信息
where --dt = '20210630'
dt >= '20210401' and dt <= '20210630'
and zhno = '356100000'
and zhno in ('356100500',
'356100700',
'356100000',
'356100100',
'356100400',
'356100300',
'356100600',
'356100200'
)
order by accbrno desc
;

福建政和泰隆村镇银行需求
分别取出大额、小额交易明细
取数逻辑：edw.dwd_bus_chnl_spmt_lrg_amt_pay_inf_di 和 edw.spmt_t_beps_paymentbook 中分别取出大额和小额的 平台交易流水号、往来标志、业务借贷标志、客户所属开户网点
筛选条件：日期范围20210401-20210630、福建政和泰隆村镇银行
需求人自行筛选往来标志和借贷标志，分别按照大小额 汇总平台流水号、加总交易金额即可

--大额交易信息明细
select plf_srl_nbr as 大额平台交易流水号
      ,ctc_id as 大额往来标志   --  1-往账；2-来账
      ,bus_crd_and_dbt_id as 大额业务借贷标志   -- 1-贷；2-借
      ,cst_afl_opn_brn as 大额客户所属开户网点
      ,trx_amt as 大额交易金额
from edw.dwd_bus_chnl_spmt_lrg_amt_pay_inf_di  --大额单笔支付信息
where dt >= '20210401' and dt <= '20210630'
and acc_sub_brn = '356100000'

--小额交易信息明细
select agentserialno as 小额平台流水号
      ,mbflag as 小额往来标志  --  1-往账；2-来账
      ,payflag as 小额借贷标志  -- 1-贷；2-借
      ,accbrno as 小额客户所属开户网点
      ,amount as 小额交易金额
from edw.spmt_t_beps_paymentbook  --小额单笔支付信息
where dt >= '20210401' and dt <= '20210630'
and zhno = '356100000'




select 大小额
,count(平台交易流水号)
from tmp_zhenghe_0702_024618
group by 大小额




select cst_afl_opn_brn as 客户所属开户网点
      ,count(plf_srl_nbr) as 大额笔数
      ,sum(trx_amt) as 大额金额
from edw.dwd_bus_chnl_spmt_lrg_amt_pay_inf_di
where dt >= '20210401' and dt <= '20210630'
and acc_sub_brn = '356100000'
and ctc_id = '1'
group by cst_afl_opn_brn
order by cst_afl_opn_brn

select accbrno as 客户所属开户网点
      ,count(agentserialno) as 小额笔数
      ,sum(amount) as 小额金额
from edw.spmt_t_beps_paymentbook
where dt >= '20210401' and dt <= '20210630'
and zhno = '356100000'
group by accbrno
order by accbrno
;






需求字段：机构号、大额笔数、大额金额、小额笔数、小额金额
取数逻辑：
从大额单笔支付信息表中筛选出356100000（福建政和泰隆村镇银行），提取客户所属开户网点作为机构号；count平台交易流水号作为大额笔数；sum交易金额作为大额金额
从小额单笔支付信息表中筛选出356100000（福建政和泰隆村镇银行），提取客户所属开户网点作为机构号；count平台交易流水号作为大额笔数；sum交易金额作为大额金额
select *
from
(


select cst_afl_opn_brn as 客户所属开户网点
      ,'大额' as 大小额
      ,count(plf_srl_nbr) as 大额笔数
      ,sum(trx_amt) as 大额金额
from edw.dwd_bus_chnl_spmt_lrg_amt_pay_inf_di
where dt >= '20210401' and dt <= '20210630'
and acc_sub_brn = '356100000'
group by cst_afl_opn_brn
order by cst_afl_opn_brn
union all
select accbrno as 客户所属开户网点
      ,'小额' as 大小额
      ,count(agentserialno) as 小额笔数
      ,sum(amount) as 小额金额
from edw.spmt_t_beps_paymentbook
where dt >= '20210401' and dt <= '20210630'
and zhno = '356100000'
group by accbrno
order by accbrno


) p2
on p1.客户所属开户网点 = p2.客户所属开户网点
order by p1.客户所属开户网点
;


select
from edw.dwd_bus_chnl_spmt_lrg_amt_pay_inf_di  --大额单笔支付信息表
where dt >= '20210401' and dt <= '20210630'
and acc_sub_brn = '356100000'
**数据需求_苏州分行全量对公账户法人手机号码20210713.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-13 11:09:51
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
select *
from app_rpt.dim_hr_org_mng_org_tree_dd
where dt = '20210712'
and brc_org_nm like '苏州%'
;


--	苏州分行全量对公账户法人手机号码
select p1.cst_id as 客户号
      ,p1.lgp_tel as 对公客户法人手机号
      ,p2.prm_org_id as 主管户机构
      ,p2.prm_org_nm as 主管户机构名称
from edw.dim_cst_entp_lgp_inf_dd p1  --对公客户法人信息表
left join edw.dws_cst_bas_inf_dd p2
on p1.cst_id = p2.cst_id
and p2.dt = '20210712'
where p1.dt = '20210712'
and p2.prm_org_id like '3202%'  --筛选苏州分行
**数据需求_计划财务部客户建档开户日期.sql
-- ODPS SQL 临时查询
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-01 08:55:58
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 一个客户号对应多个开户日期，取最早的开户日期
select *
from tmp_cst_opn_file_024618


create table if not exists tmp_cst_opn_file_024618
as
select p1.cst_id as 客户号
      ,min(p1.opn_dt) as 开户日期
      ,min(p2.file_dt) as 建档日期
from edw.dim_bus_dep_cst_act_inf_dd p1
left join edw.dws_cst_bas_inf_dd p2
on p1.cst_id = p2.cst_id
and p2.dt = p1.dt
where p1.dt = '20210625'
and p1.cst_id in ('0000004392',
'0000007399',
'0600076044',
'0600102023',
'0600278002',
'0600298008',
'1000000607',
'1000001280',
'1000003364',
'1000003729',
'1000005093',
'1000005190',
'1000005964',
'1000006058',
'1000007131',
'1000007455',
'1000009443',
'1000010168',
'1000013796',
'1000014941',
'1000018214',
'1000019235',
'1000021419',
'1000023404',
'1000023685',
'1000025253',
'1000025323',
'1000025359',
'1000025973',
'1000026082',
'1000026159',
'1000026163',
'1000026206',
'1000026213',
'1000026907',
'1000026975',
'1000028095',
'1000028865',
'1000030054',
'1000030229',
'1000031977',
'1000032340',
'1000033884',
'1000034491',
'1000036025',
'1000036038',
'1000036064',
'1000037112',
'1000037445',
'1000043763',
'1000045698',
'1000046638',
'1000046719',
'1000046789',
'1000047308',
'1000048242',
'1000048246',
'1000049162',
'1000050026',
'1000051156',
'1000051566',
'1000051834',
'1000053274',
'1000053554',
'1000054837',
'1000055249',
'1000056469',
'1000058083',
'1000058199',
'1000059760',
'1000060756',
'1000061641',
'1000062941',
'1000064422',
'1000067947',
'1000073369',
'1000073879',
'1000074053',
'1000077693',
'1000078128',
'1000085138',
'1000086282',
'1000086287',
'1000086971',
'1000088293',
'1000088359',
'1000088753',
'1000089320',
'1000089927',
'1000090687',
'1000090925',
'1000093171',
'1000093192',
'1000093690',
'1000094770',
'1000097746',
'1000097771',
'1000103350',
'1000104811',
'1000106949',
'1000111036',
'1000111680',
'1000118362',
'1000120249',
'1000120939',
'1000121768',
'1000122183',
'1000123694',
'1000125882',
'1000125936',
'1000126090',
'1000128083',
'1000131489',
'1000132233',
'1000133051',
'1000134488',
'1000134695',
'1000134862',
'1000136803',
'1000138139',
'1000139242',
'1000139742',
'1000139903',
'1000143088',
'1000149625',
'1000151982',
'1000156561',
'1000163407',
'1000168658',
'1000171324',
'1000172768',
'1000180829',
'1000181604',
'1000182475',
'1000182695',
'1000183534',
'1000185221',
'1000185427',
'1000196113',
'1000199227',
'1000199311',
'1000200132',
'1000200650',
'1000200768',
'1000201248',
'1000203972',
'1000205063',
'1000205344',
'1000205966',
'1000206502',
'1000209252',
'1000211749',
'1000212027',
'1000212154',
'1000212732',
'1000217780',
'1000218666',
'1000224184',
'1000224568',
'1000226198',
'1000226816',
'1000236963',
'1000240024',
'1000242366',
'1000246027',
'1000260042',
'1000260445',
'1000270009',
'1000271850',
'1000272378',
'1000273110',
'1000275256',
'1000281503',
'1000283051',
'1000289726',
'1002910894',
'1002913404',
'1002931912',
'1002946015',
'1002952580',
'1002958755',
'1002970858',
'1002977642',
'1003003120',
'1003003315',
'1003010896',
'1003018603',
'1003025603',
'1003074801',
'1003088284',
'1003091396',
'1003092605',
'1003094052',
'1003097903',
'1003116538',
'1003134743',
'1003137733',
'1003154110',
'1003172495',
'1003178095',
'1003184515',
'1003190251',
'1003193917',
'1003198378',
'1003212953',
'1003255282',
'1003264653',
'1003269317',
'1003275628',
'1003332479',
'1003352550',
'1003357315',
'1003374158',
'1003386494',
'1003392419',
'1003395360',
'1003408134',
'1003410588',
'1003416443',
'1003435075',
'1003441867',
'1003454676',
'1003460196',
'1003462877',
'1003493341',
'1003506898',
'1003514277',
'1003521556',
'1003556963',
'1003557289',
'1003564304',
'1003575829',
'1003579243',
'1003580030',
'1003584524',
'1003587367',
'1003603919',
'1003617169',
'1003624897',
'1003673305',
'1003674195',
'1003712530',
'1003719526',
'1003749022',
'1003749231',
'1003781453',
'1003813222',
'1003829278',
'1003831259',
'1003834441',
'1003840055',
'1003851563',
'1003868664',
'1003885212',
'1003893088',
'1003894669',
'1003899657',
'1003919832',
'1003922696',
'1003960898',
'1003965280',
'1003966878',
'1003992152',
'1004005475',
'1004022922',
'1004029235',
'1004047596',
'1004063873',
'1004085534',
'1004089321',
'1004104455',
'1004124682',
'1004128013',
'1004145731',
'1004147715',
'1004157767',
'1004185304',
'1004186884',
'1004187054',
'1004206418',
'1004211768',
'1004219544',
'1004236154',
'1004240056',
'1004240830',
'1004243659',
'1004259612',
'1004290633',
'1004301120',
'1004302415',
'1004306170',
'1004328932',
'1004353262',
'1004367753',
'1004369364',
'1004374025',
'1004378317',
'1004386316',
'1004397033',
'1004397817',
'1004401356',
'1004402425',
'1004403772',
'1004404106',
'1004457564',
'1004459687',
'1004481028',
'1004481299',
'1004488223',
'1004513323',
'1004517420',
'1004519992',
'1004529557',
'1004535046',
'1004559332',
'1004559952',
'1004561267',
'1004584561',
'1004585755',
'1004596876',
'1004596946',
'1004637612',
'1004640452',
'1004641514',
'1004641785',
'1004642443',
'1004643745',
'1004655012',
'1004660829',
'1004671546',
'1004677658',
'1004691526',
'1004692176',
'1004693137',
'1004698295',
'1004699302',
'1004700729',
'1004730131',
'1004741719',
'1004749362',
'1004758423',
'1004759059',
'1004770223',
'1004777714',
'1004780648',
'1004781609',
'1004783809',
'1004785117',
'1004811331',
'1004820733',
'1004824032',
'1004832093',
'1004839793',
'1004843291',
'1004884522',
'1004902273',
'1004929535',
'1004934520',
'1004935543',
'1004938610',
'1004947238',
'1004956678',
'1004962523',
'1004963229',
'1004963801',
'1004987306',
'1004998410',
'1005025478',
'1005060426',
'1005074900',
'1005077091',
'1005082048',
'1005096933',
'1005101750',
'1005103549',
'1005129965',
'1005130613',
'1005140780',
'1005146164',
'1005215686',
'1005232993',
'1005242534',
'1005289148',
'1005289845',
'1005293259',
'1005296270',
'1005309640',
'1005316020',
'1005327709',
'1005392873',
'1005393593',
'1005424301',
'1005432603',
'1005445258',
'1005452690',
'1005453466',
'1005455217',
'1005464950',
'1005467971',
'1005484024',
'1005498870',
'1005513269',
'1005516862',
'1005517025',
'1005518396',
'1005528874',
'1005541798',
'1005543703',
'1005550695',
'1005571612',
'1005649274',
'1005650852',
'1005657350',
'1005661151',
'1005681047',
'1005718727',
'1005722883',
'1005742623',
'1005782777',
'1005784922',
'1005812942',
'1005816025',
'1005832953',
'1005836377',
'1005848125',
'1005848613',
'1005869539',
'1005879884',
'1005895837',
'1005907765',
'1005909251',
'1005919784',
'1005927226',
'1006010956',
'1006018446',
'1006018600',
'1006047912',
'1006049198',
'1006049756',
'1006052301',
'1006060843',
'1006069907',
'1006071058',
'1006074682',
'1006076983',
'1006078246',
'1006126671',
'1006134081',
'1006137312',
'1006163627',
'1006221523',
'1006230305',
'1006259083',
'1006267020',
'1006274169',
'1006290143',
'1006327861',
'1006338641',
'1006338906',
'1006339121',
'1006348282',
'1006349128',
'1006350559',
'1006366909',
'1006392500',
'1006395583',
'1006400362',
'1006408357',
'1006409844',
'1006423705',
'1006446403',
'1006457269',
'1006463859',
'1006463897',
'1006465477',
'1006467475',
'1006474949',
'1006486261',
'1006513756',
'1006528828',
'1006551352',
'1006552166',
'1006562808',
'1006563302',
'1006564262',
'1006597424',
'1006600344',
'1006625019',
'1006631382',
'1006651324',
'1006679964',
'1006685888',
'1006742350',
'1006742677',
'1006742963',
'1006771523',
'1006772483',
'1006773172',
'1006773901',
'1006794687',
'1006803260',
'1006813058',
'1006817559',
'1006822847',
'1006851685',
'1006865121',
'1006868180',
'1006907548',
'1006909445',
'1006914795',
'1006917622',
'1006922174',
'1006939011',
'1006941218',
'1006957909',
'1007000561',
'1007030182',
'1007046291',
'1007057158',
'1007077152',
'1007081737',
'1007114581',
'1007119029',
'1007127244',
'1007154938',
'1007165600',
'1007170710',
'1007203780',
'1007205346',
'1007210153',
'1007214003',
'1007221508',
'1007222583',
'1007230652',
'1007235260',
'1007251701',
'1007259936',
'1007260691',
'1007265045',
'1007268965',
'1007287629',
'1007297772',
'1007334954',
'1007344502',
'1007351780',
'1007354282',
'1007380023',
'1007397232',
'1007420954',
'1007436227',
'1007449353',
'1007454735',
'1007466949',
'1007558929',
'1007568591',
'1007573579',
'1007587750',
'1007603009',
'1007620657',
'1007624468',
'1007653352',
'1007656599',
'1007658535',
'1007670289',
'1007673527',
'1007690308',
'1007742955',
'1007761309',
'1007781404',
'1007811174',
'1007813196',
'1007821715',
'1007865726',
'1007870557',
'1007895518',
'1007906485',
'1007935805',
'1007967727',
'1007973146',
'1007977762',
'1007995117',
'1008006425',
'1008039719',
'1008046935',
'1008048027',
'1008048089',
'1008087716',
'1008138535',
'1008148183',
'1008155082',
'1008208823',
'1008214312',
'1008240317',
'1008249154',
'1008254860',
'1008255326',
'1008259865',
'1008263440',
'1008294907',
'1008320842',
'1008328983',
'1008331848',
'1008375943',
'1008383935',
'1008401460',
'1008414729',
'1008422261',
'1008438185',
'1008441521',
'1008445781',
'1008453076',
'1008466063',
'1008467358',
'1008483077',
'1008486353',
'1008509319',
'1008543919',
'1008546341',
'1008607833',
'1008633249',
'1008686063',
'1008711233',
'1008721139',
'1008753316',
'1008759598',
'1008773000',
'1008782248',
'1008789746',
'1008814264',
'1008815131',
'1008839287',
'1008890529',
'1008893209',
'1008894664',
'1008897159',
'1008905137',
'1008919301',
'1008930551',
'1008934393',
'1008942936',
'1008946189',
'1008957635',
'1008972610',
'1008974904',
'1009035697',
'1009049931',
'1009061887',
'1009064916',
'1009066743',
'1009068455',
'1009088101',
'1009088860',
'1009187763',
'1009233626',
'1009263564',
'1009309949',
'1009319775',
'1009325860',
'1009346926',
'1009347590',
'1009364270',
'1009411435',
'1009452191',
'1009475673',
'1009488095',
'1009490627',
'1009520188',
'1009536583',
'1009556215',
'1009568140',
'1009599195',
'1009619604',
'1009623195',
'1009642640',
'1009666741',
'1009702359',
'1009738354',
'1009742124',
'1009766023',
'1009783479',
'1009790037',
'1009797629',
'1009837240',
'1009859987',
'1009864732',
'1009885951',
'1009903169',
'1009908582',
'1009924148',
'1009951584',
'1009998561',
'1010029229',
'1010051189',
'1010059864',
'1010065269',
'1010078869',
'1010079813',
'1010083986',
'1010094153',
'1010113771',
'1010117070',
'1010126179',
'1010134387',
'1010139212',
'1010143842',
'1010180735',
'1010186265',
'1010206868',
'1010225940',
'1010306506',
'1010330185',
'1010380818',
'1010392402',
'1010443283',
'1010447119',
'1010461025',
'1010466563',
'1010471938',
'1010486651',
'1010495712',
'1010535131',
'1010548197',
'1010566085',
'1010580294',
'1010588979',
'1010615147',
'1010650227',
'1010665298',
'1010666336',
'1010669650',
'1010677440',
'1010681746',
'1010686981',
'1010714158',
'1010779155',
'1010822307',
'1010822888',
'1010859673',
'1010872030',
'1010898999',
'1010953627',
'1011003927',
'1011018703',
'1011042630',
'1011086487',
'1011128169',
'1011145995',
'1011157875',
'1011159037',
'1011167632',
'1011187922',
'1011213425',
'1011225684',
'1011264722',
'1011272358',
'1011344000',
'1011344170',
'1011344512',
'1011347139',
'1011352270',
'1011377743',
'1011407141',
'1011434912',
'1011453979',
'1011460544',
'1011502620',
'1011558061',
'1011574449',
'1011625749',
'1011634824',
'1011639780',
'1011649585',
'1011687112',
'1011706747',
'1011707436',
'1011764741',
'1011771183',
'1011771905',
'1011776405',
'1011941049',
'1011952139',
'1011955864',
'1011993314',
'1012008750',
'1012022293',
'1012037529',
'1012053053',
'1012087175',
'1012106553',
'1012150763',
'1012153405',
'1012185930',
'1012254229',
'1012260655',
'1012271149',
'1012279653',
'1012314767',
'1012376558',
'1012400248',
'1012441687',
'1012449247',
'1012453745',
'1012468141',
'1012504177',
'1012534185',
'1012558659',
'1012584577',
'1012597773',
'1012646811',
'1012677929',
'1012707822',
'1012708629',
'1012735490',
'1012770828',
'1012780205',
'1012797591',
'1012877800',
'1012888743',
'1012909244',
'1012932057',
'1012950705',
'1012976145',
'1012992484',
'1013016006',
'1013035599',
'1013054974',
'1013062656',
'1013081512',
'1013107900',
'1013131921',
'1013143616',
'1013163153',
'1013169119',
'1013186154',
'1013272091',
'1013291508',
'1013336047',
'1013349717',
'1013363337',
'1013364709',
'1013374162',
'1013403592',
'1013420164',
'1013553273',
'1013585847',
'1013592412',
'1013593442',
'1013629983',
'1013631630',
'1013696598',
'1013698851',
'1013733035',
'1013756966',
'1013757662',
'1013785658',
'1013786246',
'1013812237',
'1013837483',
'1013865570',
'1013868281',
'1013873346',
'1013941030',
'1013983182',
'1013997921',
'1014067232',
'1014096924',
'1014112242',
'1014124021',
'1014140290',
'1014163671',
'1014171586',
'1014216784',
'1014257813',
'1014260444',
'1014268888',
'1014269988',
'1014271534',
'1014313470',
'1014322315',
'1014432827',
'1014473716',
'1014474063',
'1014501262',
'1014505547',
'1014519146',
'1014530442',
'1014552451',
'1014563008',
'1014579636',
'1014626187',
'1014753401',
'1014769680',
'1014770206',
'1014775434',
'1014826796',
'1014853529',
'1014865764',
'1014895859',
'1014909127',
'1014931830',
'1014946041',
'1014953034',
'1015014626',
'1015017933',
'1015053625',
'1015086180',
'1015116014',
'1015125928',
'1015133701',
'1015137327',
'1015172887',
'1015183124',
'1015196616',
'1015208645',
'1015241493',
'1015241501',
'1015270471',
'1015273308',
'1015297858',
'1015301638',
'1015364790',
'1015367540',
'1015399905',
'1015400081',
'1015414589',
'1015416936',
'1015422704',
'1015446759',
'1015460689',
'1015486098',
'1015513165',
'1015516698',
'1015526501',
'1015533309',
'1015562952',
'1015579914',
'1015585751',
'1015645749',
'1015671193',
'1015685040',
'1015707780',
'1015792586',
'1015810934',
'1015831742',
'1015845985',
'1015929649',
'1015975105',
'1015988130',
'1016026226',
'1016048064',
'1016071891',
'1016087272',
'1016096124',
'1016151410',
'1016158716',
'1016214900',
'1016266941',
'1016356055',
'1016394574',
'1016409733',
'1016423182',
'1016440312',
'1016466062',
'1016519214',
'1016539511',
'1016557409',
'1016625249',
'1016675516',
'1016681670',
'1016799425',
'1016807566',
'1016812412',
'1016850140',
'1016858849',
'1016874955',
'1016910727',
'1016980137',
'1017060724',
'1017135428',
'1017145829',
'1017218594',
'1017222991',
'1017248317',
'1017250189',
'1017276877',
'1017313794',
'1017342950',
'1017348853',
'1017396418',
'1017456211',
'1017485732',
'1017499540',
'1017589692',
'1017615429',
'1017629439',
'1017630031',
'1017698592',
'1017709717',
'1017754159',
'1017779576',
'1017812048',
'1017813528',
'1017822038',
'1017844472',
'1017931875',
'1017949975',
'1018000860',
'1018031480',
'1018110194',
'1018116422',
'1018119830',
'1018120069',
'1018131940',
'1018138082',
'1018165808',
'1018213389',
'1018252434',
'1018265065',
'1018276232',
'1018299776',
'1018328346',
'1018367530',
'1018390684',
'1018438959',
'1018547291',
'1018549042',
'1018549662',
'1018578082',
'1018604299',
'1018612003',
'1018640501',
'1018694069',
'1018739320',
'1018741868',
'1018754521',
'1018831749',
'1018852759',
'1018864886',
'1018874542',
'1018925486',
'1018993209',
'1018998608',
'1019005679',
'1019026850',
'1019028702',
'1019055193',
'1019074439',
'1019139220',
'1019145694',
'1019149652',
'1019180318',
'1019245433',
'1019257779',
'1019306297',
'1019313761',
'1019316605',
'1019336104',
'1019339783',
'1019374685',
'1019375266',
'1019378256',
'1019389517',
'1019470240',
'1019484399',
'1019552526',
'1019552773',
'1019562648',
'1019572412',
'1019581179',
'1019595646',
'1019602252',
'1019617526',
'1019642779',
'1019663316',
'1019672648',
'1019704121',
'1019806874',
'1019854484',
'1019922729',
'1019931392',
'1019992540',
'1020023051',
'1020067512',
'1020117642',
'1020166129',
'1020170696',
'1020209831',
'1020220423',
'1020225233',
'1020248652',
'1020249093',
'1020270428',
'1020336814',
'1020359574',
'1020365715',
'1020366358',
'1020481026',
'1020511804',
'1020519510',
'1020583173',
'1020621835',
'1020638006',
'1020639555',
'1020661547',
'1020667200',
'1020680681',
'1020686731',
'1020721162',
'1020729760',
'1020738054',
'1020747773',
'1020747944',
'1020781885',
'1020795554',
'1020806274',
'1020846955',
'1020883622',
'1020899243',
'1020911318',
'1020999532',
'1021066372',
'1021109402',
'1021166584',
'1021170905',
'1021192844',
'1021205788',
'1021225148',
'1021322625',
'1021510981',
'1021561093',
'1021590709',
'1021610427',
'1021672371',
'1021716284',
'1021784069',
'1021843089',
'1021861085',
'1021928463',
'1021957869',
'1021987062',
'1022014929',
'1022089613',
'1022205167',
'1022257007',
'1022267275',
'1022269343',
'1022276963',
'1022277791',
'1022302567',
'1022307726',
'1022343230',
'1022352555',
'1022461772',
'1022498389',
'1022593952',
'1022614150',
'1022666829',
'1022789063',
'1022847642',
'1022950168',
'1022969553',
'1022999833',
'1023003883',
'1023046996',
'1023051727',
'1023122627',
'1023202758',
'1023245791',
'1023299444',
'1023385040',
'1023386049',
'1023419514',
'1023505280',
'1023536730',
'1023536754',
'1023584636',
'1023599816',
'1023608374',
'1023619705',
'1023677305',
'1023694410',
'1023741086',
'1023765295',
'1023818447',
'1023833725',
'1023862758',
'1023885658',
'1023904377',
'1023949015',
'1023952576',
'1024004401',
'1024010116',
'1024022692',
'1024044757',
'1024121386',
'1024160695',
'1024272422',
'1024294657',
'1024299993',
'1024361816',
'1024382491',
'1024382941',
'1024415764',
'1024478888',
'1024488948',
'1024624225',
'1024664519',
'1024669800',
'1024704534',
'1024708004',
'1024736944',
'1024844629',
'1024861114',
'1024883813',
'1024884588',
'1024904826',
'1024958966',
'1024972144',
'1025010603',
'1025019659',
'1025080549',
'1025081175',
'1025144672',
'1025148971',
'1025196909',
'1025230696',
'1025380151',
'1025411743',
'1025526438',
'1025531726',
'1025577324',
'1025615961',
'1025727332',
'1025732327',
'1025776174',
'1026073911',
'1026110744',
'1026132436',
'1026155235',
'1026159596',
'1026159659',
'1026170140',
'1026196720',
'1026209455',
'1026269851',
'1026349177',
'1026442090',
'1026456118',
'1026498037',
'1026537952',
'1026540141',
'1026644621',
'1026778481',
'1026791817',
'1026826203',
'1026848553',
'1026890330',
'1026904646',
'1026925524',
'1027085294',
'1027153104',
'1027177003',
'1027201700',
'1027237851',
'1027262174',
'1027454645',
'1027614698',
'1027629892',
'1027708450',
'1027719425',
'1027787820',
'1027810597',
'1027857769',
'1027891376',
'1027975605',
'1027991665',
'1028064067',
'1028152546',
'1028209826',
'1028257892',
'1028266092',
'1028342437',
'1028473245',
'1028528851',
'1028554229',
'1028556777',
'1028596092',
'1028667257',
'1028715264',
'1028798825',
'1028823228',
'1028863961',
'1028895991',
'1028959745',
'1029013822',
'1029146607',
'1029225708',
'1029278849',
'1029306838',
'1029461155',
'1029500599',
'1029533092',
'1029612698',
'1029727066',
'1029731843',
'1029787316',
'1029792349',
'1029814135',
'1029852034',
'1029913456',
'1030016313',
'1030045834',
'1030088125',
'1030112637',
'1030231659',
'1030240152',
'1030259028',
'1030273718',
'1030297181',
'1030378646',
'1030459853',
'1030666532',
'1030683995',
'1030727860',
'1030735131',
'1030832517',
'1031149351',
'1031158722',
'1031166396',
'1031249431',
'1031261293',
'1031496714',
'1031591781',
'1031699724',
'1031790959',
'1031864313',
'1031866878',
'1031967320',
'1032037198',
'1032064673',
'1032083058',
'1032092126',
'1032093613',
'1032095192',
'1032103310',
'1032115050',
'1032343136',
'1032501701',
'1032686596',
'1033076576',
'1033246920',
'1033276798',
'1033302020',
'1033389911',
'1033401024',
'1033552634',
'1033569595',
'1033580529',
'1033655076',
'1033732131',
'1033842364',
'1033902585',
'1034059972',
'1034069568',
'1034262592',
'1034368823',
'1034433899',
'1034441797',
'1034514703',
'1034562630',
'1034578143',
'1034655493',
'1034687733',
'1034720166',
'1035137756',
'1035200508',
'1035244540',
'1035247910',
'1035340167',
'1035378083',
'1035397071',
'1035469475',
'1035598090',
'1035803736',
'1035885040',
'1035920611',
'1035947942',
'1036021915',
'1036070377',
'1036103448',
'1036104764',
'1036184025',
'1036368706',
'1036386120',
'1036491550',
'1036502218',
'1036640343',
'1036673783',
'1036713001',
'1036878311',
'1037025275',
'1037029930',
'1037047518',
'1037049198',
'1037085594',
'1037180220',
'1037186262',
'1037509342',
'1037536012',
'1037586466',
'1037594434',
'1037658839',
'1037682278',
'1037718656',
'1037724772',
'1037760217',
'1037768620',
'1037793905',
'1037826836',
'1037891575',
'1037936348',
'1037948026',
'1037955691',
'1038011909',
'1038107606',
'1038300476',
'1038357258',
'1038548263',
'1038567439',
'1038590677',
'1038785385',
'1038809054',
'1038831015',
'1038887658',
'1038984414',
'1038986878',
'1039076657',
'1039210378',
'1039276994',
'1039279706',
'1039311471',
'1039333543',
'1039454323',
'1039490039',
'1039506754',
'1039518355',
'1039527409',
'1039563780',
'1039745393',
'1039747733',
'1039880337',
'1040103580',
'1040177787',
'1040178407',
'1040306590',
'1040404968',
'1040432860',
'1040527412',
'1040529403',
'1040584943',
'1040605646',
'1040612026',
'1040631052',
'1040697515',
'1040813773',
'1040826809',
'1040830701',
'1040870406',
'1040875874',
'1040907991',
'1040964857',
'1040972856',
'1040981335',
'1041034966',
'1041156668',
'1041180610',
'1041339225',
'1041356804',
'1041375119',
'1041394842',
'1041511713',
'1041547237',
'1041570141',
'1041693121',
'1041761853',
'1042045473',
'1042385780',
'1042445444',
'1042506316',
'1042514113',
'1042633940',
'1042702400',
'1042802528',
'1042893481',
'1043052155',
'1043067474',
'1043222631',
'1043313270',
'1043429731',
'1043563389',
'1043670717',
'1043823450',
'1043827526',
'1043844446',
'1043846211',
'1043858704',
'1043872108',
'1043888130',
'1043953036',
'1044002135',
'1044178542',
'1044190816',
'1044250222',
'1044323632',
'1044361120',
'1044407226',
'1044466469',
'1044561373',
'1044607772',
'1044743979',
'1044784938',
'1044790124',
'1044843701',
'1044871348',
'1044885288',
'1044966286',
'1044971776',
'1045048097',
'1045056452',
'1045149710',
'1045162209',
'1045261885',
'1045351494',
'1045354105',
'1045366232',
'1045492711',
'1045629432',
'1045754501',
'1600008435',
'1600032326',
'1600040261',
'1600071491',
'1600084359',
'1600135672',
'1600271118',
'1600374296',
'1600431663',
'1600479370',
'1600557372',
'1600578023',
'1600630046',
'1600653203',
'1600665510',
'1600749970',
'1600787856',
'1600839468',
'1600870396',
'1600904043',
'1600946005',
'1600970445',
'1601012842',
'1601231036',
'1601276090',
'1601447478',
'1601463044',
'1601513146',
'1601548163',
'1601788643',
'1601820404',
'1601933286',
'1602113147',
'1602135457',
'1602205753',
'1602298036',
'1602309997',
'1602348730',
'1602413450',
'1602433634',
'1602475385',
'1602492848',
'1602495458',
'1602527851',
'1602597364',
'1602598245',
'1602655767',
'1602667431',
'1602683946',
'1602747078',
'1602810153',
'1602890661',
'1603037473',
'1603040638',
'1603120113',
'1603144417',
'1603181530',
'1603242129',
'1603273289',
'1603282495',
'1603311702',
'1603324198',
'1603553858',
'1603571627',
'1603592726',
'1603600893',
'1603627120',
'1603637207',
'1603650053',
'1603662810',
'1603690710',
'1603697760',
'1603736039',
'1603753105',
'1603912793',
'1603924009',
'1603924363',
'1603942183',
'1603983358',
'1603992523',
'1604029068',
'1604068784',
'1604086469',
'1604120527',
'1604171339',
'1604350857',
'1604372279',
'1604382460',
'1604388255',
'1604506840',
'1604539960',
'1604594563',
'1604691302',
'1604721473',
'1604854948',
'1604865469',
'1604906695',
'1604935028',
'1605027178',
'1605100602',
'1605107813',
'1605149826',
'1605195953',
'1605225861',
'1605301643',
'1605315561',
'1605338923',
'1605368104',
'1605388134',
'1605436982',
'1605440012',
'1605477911',
'1605583026',
'1605648597',
'1605680244',
'1605700075',
'1605703313',
'1605728428',
'1605734704',
'1605745639',
'1605756954',
'1605857888',
'1605929724',
'1605972249',
'1605997468',
'1606035153',
'1606043495',
'1606159217',
'1606203565',
'1606274648',
'1606276622',
'1606293433',
'1606468245',
'1606482516',
'1606536675',
'1606539116',
'1606556734',
'1606583023',
'1606583420',
'1606621649',
'1606639768',
'1606644002',
'1606670002',
'1606707124',
'1606729215',
'1606807725',
'1606833090',
'1606877975',
'1606916880',
'1606953071',
'1606981792',
'1607031719',
'1607121867',
'1607142747',
'1607187608',
'1607189664',
'1607205310',
'1607245050',
'1607266236',
'1607279501',
'1607308632',
'1607369777',
'1607386790',
'1607499058',
'1607510430',
'1607546008',
'1607546913',
'1607568328',
'1607588341',
'1607611573',
'1607634740',
'1607674288',
'1607708604',
'1607711760',
'1607752747',
'1607777804',
'1607888721',
'1607939919',
'1608100327',
'1608342600',
'1608384156',
'1608393718',
'1608445395',
'1608478702',
'1608491673',
'1608499801',
'1608520635',
'1608550584',
'1608636264',
'1608694233',
'1608744920',
'1608848437',
'1608852524',
'1608880458',
'1608889179',
'1608948056',
'1608990080',
'1609050196',
'1609050569',
'1609060615',
'1609107915',
'1609169951',
'1609175854',
'1609186695',
'1609197901',
'1609205577',
'1609291927',
'1609366586',
'1609417976',
'1609423236',
'1609474987',
'1609536823',
'1609544452',
'1609586075',
'1609596586',
'1609628064',
'1609641121',
'1609679868',
'1609686507',
'1609696198',
'1609762061',
'1609789338',
'1609847038',
'1609872937',
'1609891053',
'1609961094',
'1610013891',
'1610101075',
'1610121511',
'1610238226',
'1610283378',
'1610383420',
'1610388395',
'1610411424',
'1610425154',
'1610491593',
'1610517329',
'1610605987',
'1610710184',
'1610736691',
'1610745846',
'1610748203',
'1610860903',
'1610862507',
'1611022596',
'1611033285',
'1611036513',
'1611059368',
'1611075129',
'1611078661',
'1611188461',
'1611232216',
'1611240296',
'1611281781',
'1611310753',
'1611352561',
'1611353435',
'1611385173',
'1611642100',
'1611715538',
'1611729516',
'1611761097',
'1611776201',
'1611823862',
'1611824380',
'1611848489',
'1611855932',
'1611900212',
'1611931866',
'1611943947',
'1612036826',
'1612045904',
'1612069825',
'1612141397',
'1612149623',
'1612184856',
'1612283654',
'1612370700',
'1612456710',
'1612492290',
'1612499063',
'1612553907',
'1612607406',
'1612627133',
'1612772987',
'1612788398',
'1612851745',
'1612903619',
'1612926208',
'1612948003',
'1613021345',
'1613025421',
'1613041539',
'1613283449',
'1613313441',
'1613338448',
'1613365440',
'1613407059',
'1613503032',
'1613511485',
'1613576783',
'1613592934',
'1613658208',
'1613724657',
'1613729318',
'1613736718',
'1613772859',
'1613827757',
'1613834420',
'1613840273',
'1613864244',
'1613972299',
'1613978891',
'1614050829',
'1614069032',
'1614133516',
'1614187439',
'1614203988',
'1614224612',
'1614247094',
'1614269972',
'1614272111',
'1614296160',
'1614354115',
'1614354953',
'1614409064',
'1614465278',
'1614508020',
'1614541975',
'1614574093',
'1614580123',
'1614586106',
'1614592346',
'1614610576',
'1614684868',
'1614779855',
'1614825491',
'1614895420',
'1614908910',
'1614910804',
'1615037049',
'1615082607',
'1615090949',
'1615116286',
'1615164521',
'1615219685',
'1615225433',
'1615319912',
'1615505323',
'1615728703',
'1615817801',
'1615879100',
'1615880409',
'1615934221',
'1615934891',
'1616058788',
'1616401204',
'1616470448',
'1616477329',
'1617166324',
'1617193451',
'1617417053',
'1617459463',
'1617476190',
'1617932015',
'1618263956',
'1619007115',
'1619121992',
'1619384859',
'1619397674',
'1619447285',
'1619591574',
'1619697216',
'1619756077',
'1619785409',
'1619793700',
'1620390460',
'1620796620',
'1620811816',
'1620882422',
'1621074301',
'1621412491',
'1621581938',
'1621776221',
'1621980071',
'1622248949',
'1622513421',
'1622946090',
'1623439543',
'1623931991',
'1624221921',
'1624433678',
'1624543259',
'1624548994',
'1624663856',
'1624733295',
'1624764289',
'1624839101',
'1624847484',
'1625176942',
'1625387030',
'1625448527',
'1625507385',
'1626202054',
'1626292907',
'1626317406',
'1626405919',
'1626447176',
'1626685258',
'1626957018',
'1627116803',
'1627257756',
'1627259374',
'1627266131',
'1627323710',
'1627366487',
'1627446802',
'1627449080',
'1627532221',
'1627587603',
'1627588535',
'1627802713',
'1627832322',
'1627852974',
'1627938247',
'1628078006',
'1628203077',
'1628580601',
'1628756073',
'1628879071',
'1628979103',
'1629340215',
'1629750783',
'1629783233',
'1629903268',
'1630012965',
'1630144480',
'1630165649',
'1630174694',
'1630293319',
'1630302232',
'1630340169',
'1630410963',
'1630418699',
'1630445970',
'1630482561',
'1630692928',
'1631142072',
'1631165391',
'1631181781',
'1631265198',
'1631315680',
'1631433391',
'1631464620',
'1631477606',
'1631489913',
'1631510697',
'1631639880',
'1631751567',
'1631763450',
'1631803482',
'1632072190',
'1632079649',
'1632125022',
'1632172548',
'1632238905',
'1632286303',
'1632464076',
'1632472384',
'1632582793',
'1632671315',
'1632854274',
'1632865820',
'1632930894',
'1633131871',
'1633204218',
'1633217813',
'1633219347',
'1633385274',
'1633479484',
'1633684604',
'1633770871',
'1633787603',
'1633805595',
'1633826239',
'1633940964',
'1634150670',
'1634201095',
'1634323423',
'1634341058',
'1634358450',
'1634393531',
'1634617174',
'1634690740',
'1634766377',
'1634880042',
'1634960435',
'1634964205',
'1635031428',
'1635108196',
'1635152372',
'1635298722',
'1635498391',
'1635539196',
'1635573675',
'1635657041',
'1635804566',
'1635852287',
'1635860238',
'1635916593',
'1636105980',
'1636140045',
'1636147706',
'1636154750',
'1636197890',
'1636273224',
'1636320615',
'1636334338',
'1636456606',
'1636464753',
'1636530407',
'1636541103',
'1636572037',
'1636679324',
'1636833896',
'1636905843',
'1636944288',
'1636964347',
'1637047536',
'1637112653',
'1637150378',
'1637189353',
'1637324130',
'1637375763',
'1637629899',
'1637632445',
'1637688816',
'1637886985',
'1637893150',
'1637904586',
'1637980613',
'1638042905',
'1638167784',
'1638437139',
'1638482960',
'1638789441',
'1638877668',
'1638889534',
'1638893113',
'1638897351',
'1639030605',
'1639045717',
'1639099317',
'1639134502',
'1639260817',
'1639312571',
'1639316479',
'1639410875',
'1639514536',
'1639557151',
'1639628345',
'1639661688',
'1639774521',
'1639871833',
'1639879504',
'1639905837',
'1639915705',
'1639952751',
'1640061187',
'1640074563',
'1640122411',
'1640126283',
'1640156234',
'1640167202',
'1640177868',
'1640178258',
'1640198069',
'1640212424',
'1640428240',
'1640447543',
'1640486563',
'1640513652',
'1640543849',
'1640552012',
'1640552927',
'1640622419',
'1640647999',
'1640736608',
'1640788749',
'1640921781',
'1640957366',
'1640964735',
'1640966989',
'1641027858',
'1641054147',
'1641098117',
'1641099439',
'1641164886',
'1641169174',
'1641205341',
'1641291237',
'1641294574',
'1641337622',
'1641368455',
'1641408992',
'1641434393',
'1641502926',
'1641533655',
'1641540923',
'1641572600',
'1641608249',
'1641624626',
'1641651611',
'1641713912',
'1641725591',
'1641750137',
'1641812505',
'1641860385',
'1641911089',
'1641921499',
'1641952432',
'1642049284',
'1642054120',
'1642115446',
'1642157160',
'1642157637',
'1642187138',
'1642210114',
'1642212902',
'1642220033',
'1642232969',
'1642295385',
'1642315013',
'1642344885',
'1642412335',
'1642448284',
'1642498130',
'1642511157',
'1642544886',
'1642571750',
'1642599504',
'1642613934',
'1642649462',
'1642713334',
'1642833349',
'1642896054',
'1642903575',
'1642930974',
'1642950108',
'1643007509',
'1643017502',
'1643063757',
'1643073387',
'1643088872',
'2000000949',
'2000000993',
'2000002267',
'2000004377',
'2000006369',
'2000007487',
'2000011615',
'2000013777',
'2000020919',
'2000021824',
'2000022553',
'2000024323',
'2000026125',
'2000380571',
'2000381114',
'2000381190',
'2000381330',
'2000381417',
'2000381657',
'2000382377',
'2000383206',
'2000383453',
'2000384128',
'2000386582',
'2000387682',
'2000388441',
'2000388580',
'2000389976',
'2000395092',
'2000395681',
'2000396743',
'2000397920',
'2000401762',
'2000402204',
'2000402367',
'2000402545',
'2000407449',
'2000408424',
'2000408943',
'2000409757',
'2000411550',
'2000414937',
'2000416043',
'2000416315',
'2000417198',
'2000418166',
'2000424631',
'2000425159',
'2000425685',
'2000426639',
'2000427380',
'2000427474',
'2000428125',
'2000428459',
'2000429078',
'2000429744',
'2000432661',
'2000433879',
'2000434652',
'2000435505',
'2000437060',
'2000437589',
'2000443340',
'2000444091',
'2000444402',
'2000445425',
'2000449368',
'2000449678',
'2000455958',
'2000458049',
'2000460330',
'2000461687',
'2000462693',
'2000464615',
'2000466101',
'2000467270',
'2000467287',
'2000468659',
'2000469184',
'2000470034',
'2000471172',
'2000472481',
'2000472652',
'2000472777',
'2000473062',
'2000474922',
'2000475844',
'2000476913',
'2000479376',
'2000480947',
'2000481117',
'2000484309',
'2000487678',
'2000490603',
'2000495064',
'2000497620',
'2000498434',
'2000504616',
'2000504748',
'2000505189',
'2000507978',
'2000509154',
'2000510004',
'2000517704',
'2000517999',
'2000518208',
'2000518664',
'2000519050',
'2000520924',
'2000524999',
'2000526074',
'2000526896',
'2000528940',
'2000529259',
'2000531014',
'2000532912',
'2000534174',
'2000534244',
'2000541554',
'2000541732',
'2000542041',
'2000542281',
'2000542382',
'2000544063',
'2000544289',
'2000546605',
'2000547541',
'2000550709',
'2000552132',
'2000556121',
'2000558136',
'2000558244',
'2000561945',
'2000563501',
'2000566375',
'2000567583',
'2000567684',
'2000569271',
'2000571120',
'2000571409',
'2000571461',
'2000571810',
'2000573320',
'2000573870',
'2000575568',
'2000576163',
'2000577605',
'2000584162',
'2000585192',
'2000585332',
'2000586913',
'2000587152',
'2000587392',
'2000587811',
'2000589080',
'2000589244',
'2000589763',
'2000590295',
'2000590389',
'2000590512',
'2000591186',
'2000593487',
'2000595339',
'2000595360',
'2000598297',
'2000598639',
'2000598918',
'2000599614',
'2000602781',
'2000603122',
'2000603278',
'2000603285',
'2000606338',
'2000610045',
'2000610425',
'2000616234',
'2000616258',
'2000616467',
'2000616722',
'2000622538',
'2000622709',
'2000622778',
'2000623614',
'2000626914',
'2000630405',
'2000633231',
'2000637718',
'2000637826',
'2000638964',
'2000639608',
'2000646800',
'2000647335',
'2000647436',
'2000647739',
'2000648505',
'2000651554',
'2000651864',
'2000654962',
'2000657868',
'2000658230',
'2000663852',
'2000666734',
'2000667120',
'2000670294',
'2000675206',
'2000680044',
'2000680866',
'2000681810',
'2000682415',
'2000687542',
'2000689432',
'2000691437',
'2000692830',
'2000693310',
'2000693853',
'2000694472',
'2000697431',
'2000699686',
'2000699903',
'2000701242',
'2000701622',
'2000701709',
'2000702506',
'2000702986',
'2000703442',
'2000704357',
'2000707075',
'2000708702',
'2000709307',
'2000709787',
'2000715120',
'2000716097',
'2000718956',
'2000721107',
'2000727202',
'2000736433',
'2000738525',
'2000742340',
'2000742991',
'2000746214',
'2000750130',
'2000752361',
'2000753416',
'2000753795',
'2000754206',
'2000755236',
'2000761819',
'2000765606',
'2000770141',
'2000771607',
'2000772682',
'2000772752',
'2000772923',
'2000774116',
'2000777360',
'2000779700',
'2000782386',
'2000785794',
'2000788056',
'2000791106',
'2000791120',
'2000792547',
'2000794141',
'2000794211',
'2000795203',
'2000795450',
'2000795467',
'2000797744',
'2000798293',
'2000798774',
'2000799191',
'2000802516',
'2000803483',
'2000803647',
'2000803957',
'2000804848',
'2000805467',
'2000806613',
'2000807698',
'2000808611',
'2000811622',
'2000812366',
'2000814496',
'2000818524',
'2000821458',
'2000821782',
'2000821876',
'2000822039',
'2000822356',
'2000823906',
'2000824912',
'2000825586',
'2000828033',
'2000828266',
'2000833679',
'2000834267',
'2000836359',
'2000840028',
'2000843070',
'2000844512',
'2000844637',
'2000845009',
'2000845465',
'2000847773',
'2000848330',
'2000854540',
'2000854627',
'2000859297',
'2000863625',
'2000864686',
'2000866893',
'2000868365',
'2000875048',
'2000879493',
'2000879950',
'2000880848',
'2000882411',
'2000885898',
'2000889560',
'2000891558',
'2000893772',
'2000893859',
'2000897002',
'2000900528',
'2000902401',
'2000902881',
'2000903570',
'2000905073',
'2000906351',
'2000915380',
'2000915931',
'2000916334',
'2000917799',
'2000917807',
'2000918882',
'2000919083',
'2000919874',
'2000920003',
'2000921451',
'2000923606',
'2000935579',
'2000935810',
'2000937469',
'2000939962',
'2000940052',
'2000941239',
'2000945824',
'2000946760',
'2000951320',
'2000952127',
'2000953380',
'2000957153',
'2000957386',
'2000960258',
'2000960481',
'2000961745',
'2000965570',
'2000966409',
'2000967059',
'2000970875',
'2000971759',
'2000971898',
'2000979030',
'2000979737',
'2000980050',
'2000982964',
'2000984335',
'2000986489',
'2000996640',
'2000998174',
'2000999368',
'2001000537',
'2001002991',
'2001011634',
'2001012671',
'2001013447',
'2001013911',
'2001015111',
'2001016468',
'2001017854',
'2001020360',
'2001021408',
'2001022089',
'2001025310',
'2001025714',
'2001026124',
'2001031265',
'2001033085',
'2001038631',
'2001042627',
'2001043068',
'2001045112',
'2001045718',
'2001049783',
'2001050501',
'2001055575',
'2001056613',
'2001058286',
'2001059160',
'2001060476',
'2001061949',
'2001063428',
'2001063435',
'2001067277',
'2001070884',
'2001073230',
'2001073300',
'2001075430',
'2001075935',
'2001077717',
'2001080401',
'2001080951',
'2001081734',
'2001082269',
'2001084863',
'2001084919',
'2001085862',
'2001086568',
'2001090941',
'2001091630',
'2001092970',
'2001093753',
'2001095667',
'2001096046',
'2001097146',
'2001100390',
'2001108006',
'2001110164',
'2001111404',
'2001115169',
'2001117097',
'2001119583',
'2001124314',
'2001125995',
'2001126639',
'2001129667',
'2001130269',
'2001132104',
'2001132933',
'2001139082',
'2001139518',
'2001139796',
'2001141133',
'2001143751',
'2001146943',
'2001150720',
'2001155073',
'2001163940',
'2001166473',
'2001168255',
'2001169627',
'2001171266',
'2001172708',
'2001178252',
'2001178702',
'2001178889',
'2001186352',
'2001189195',
'2001189955',
'2001190278',
'2001198720',
'2001199659',
'2001200223',
'2001200425',
'2001202694',
'2001203617',
'2001204700',
'2001206924',
'2001207024',
'2001208782',
'2001212026',
'2001212552',
'2001212785',
'2001213056',
'2001213638',
'2001222876',
'2001225330',
'2001226858',
'2001228003',
'2001228414',
'2001230604',
'2001235692',
'2001236002',
'2001240733',
'2001241826',
'2001242971',
'2001243576',
'2001246371',
'2001247976',
'2001248247',
'2001253559',
'2001254248',
'2001254541',
'2001256013',
'2001256316',
'2001260434',
'2001267088',
'2001267590',
'2001267949',
'2001269365',
'2001272927',
'2001278231',
'2001278767',
'2001280476',
'2001283815',
'2001284559',
'2001287835',
'2001290752',
'2001290839',
'2001291148',
'2001291681',
'2001293052',
'2001293742',
'2001296693',
'2001297281',
'2001297490',
'2001300682',
'2001302642',
'2001303223',
'2001306648',
'2001307229',
'2001308127',
'2001308374',
'2001309823',
'2001312269',
'2001313787',
'2001320871',
'2001322026',
'2001322507',
'2001324783',
'2001325395',
'2001325883',
'2001325960',
'2001326510',
'2001329106',
'2001330265',
'2001330760',
'2001334805',
'2001338281',
'2001340325',
'2001340628',
'2001341742',
'2001347063',
'2001349807',
'2001350199',
'2001351477',
'2001352135',
'2001353312',
'2001353684',
'2001354986',
'2001357015',
'2001357440',
'2001358021',
'2001360514',
'2001362877',
'2001363179',
'2001364527',
'2001365805',
'2001371680',
'2001372292',
'2001373602',
'2001374649',
'2001375857',
'2001376351',
'2001376508',
'2001376919',
'2001378210',
'2001379512',
'2001381719',
'2001382066',
'2001382617',
'2001383274',
'2001384886',
'2001386303',
'2001389393',
'2001391538',
'2001392638',
'2001394117',
'2001394333',
'2001394845',
'2001396874',
'2001397789',
'2001397842',
'2001398384',
'2001399439',
'2001399491',
'2001400438',
'2001405781',
'2001406494',
'2001407316',
'2001407479',
'2001408771',
'2001413021',
'2001415500',
'2001417065',
'2001419614',
'2001422694',
'2001422757',
'2001424313',
'2001425196',
'2001426520',
'2001427079',
'2001428667',
'2001429217',
'2001430585',
'2001432646',
'2001432893',
'2001439632',
'2001441024',
'2001443440',
'2001444379',
'2001446029',
'2001449141',
'2001453290',
'2001455724',
'2001456343',
'2001457188',
'2001457405',
'2001457777',
'2001458473',
'2001459403',
'2001460740',
'2001463723',
'2001463918',
'2001464380',
'2001464809',
'2001465303',
'2001465769',
'2001466319',
'2001467116',
'2001467426',
'2001467945',
'2001468913',
'2001469190',
'2001470095',
'2001473472',
'2001474990',
'2001476239',
'2001478989',
'2001484764',
'2001484959',
'2001486041',
'2001486375',
'2001487451',
'2001489093',
'2001490710',
'2001491865',
'2001494831',
'2001499261',
'2001506303',
'2001506497',
'2001507782',
'2001510700',
'2001511831',
'2001513682',
'2001513877',
'2001515572',
'2001522255',
'2001522565',
'2001532120',
'2001533794',
'2001536018',
'2001537822',
'2001539147',
'2001540073',
'2001540220',
'2001540547',
'2001541717',
'2001548020',
'2001553813',
'2001554045',
'2001556865',
'2001558717',
'2001561418',
'2001563067',
'2001566848',
'2001568529',
'2001570966',
'2001575769',
'2001577123',
'2001578728',
'2001590674',
'2001591363',
'2001592836',
'2001594548',
'2001596274',
'2001600713',
'2001601642',
'2001603859',
'2001606034',
'2001606236',
'2001607381',
'2001609992',
'2001610417',
'2001610587',
'2001611113',
'2001611360',
'2001612941',
'2001613793',
'2001615582',
'2001620375',
'2001621622',
'2001622481',
'2001622948',
'2001623574',
'2001627277',
'2001628269',
'2001628788',
'2001629080',
'2001629167',
'2001633045',
'2001637399',
'2001640735',
'2001641347',
'2001641400',
'2001643864',
'2001648263',
'2001648713',
'2001648984',
'2001651577',
'2001654404',
'2001658633',
'2001660683',
'2001665044',
'2001665107',
'2001665664',
'2001665688',
'2001665835',
'2001667408',
'2001669343',
'2001671944',
'2001676514',
'2001677429',
'2001678264',
'2001679319',
'2001681275',
'2001685163',
'2001685187',
'2001685480',
'2001685543',
'2001685637',
'2001685783',
'2001685891',
'2001686535',
'2001686674',
'2001692529',
'2001693201',
'2001693580',
'2001694008',
'2001695083',
'2001696950',
'2001702341',
'2001703302',
'2001703340',
'2001703845',
'2001704983',
'2001712216',
'2001712533',
'2001713378',
'2001714687',
'2001715282',
'2001716407',
'2001717204',
'2001718405',
'2001718892',
'2001722756',
'2001722763',
'2001723236',
'2001724329',
'2001724343',
'2001725241',
'2001726226',
'2001736014',
'2001736122',
'2001739422',
'2001739554',
'2001741009',
'2001741155',
'2001741319',
'2001744138',
'2001744493',
'2001746989',
'2001747351',
'2001749133',
'2001749861',
'2001749900',
'2001757574',
'2001759116',
'2001761041',
'2001761452',
'2001761661',
'2001763607',
'2001763885',
'2001766440',
'2001776409',
'2001777530',
'2001784275',
'2001784516',
'2001787715',
'2001788992',
'2001790029',
'2001790904',
'2001792421',
'2001792452',
'2001792700',
'2001794568',
'2001795031',
'2001797806',
'2001800106',
'2001800276',
'2001802786',
'2001806302',
'2001808944',
'2001810785',
'2001811164',
'2001813939',
'2001814471',
'2001814611',
'2001819351',
'2001821488',
'2001822867',
'2001823640',
'2001828412',
'2001828708',
'2001831702',
'2001831810',
'2001832756',
'2001834172',
'2001834189',
'2001836288',
'2001836909',
'2001837960',
'2001838154',
'2001840685',
'2001844294',
'2001844775',
'2001845192',
'2001845705',
'2001845938',
'2001847006',
'2001852046',
'2001855834',
'2001860696',
'2001861549',
'2001862137',
'2001862346',
'2001863097',
'2001866272',
'2001867567',
'2001871832',
'2001875528',
'2001876224',
'2001876604',
'2001876837',
'2001877526',
'2001878190',
'2001882371',
'2001883255',
'2001884975',
'2001886841',
'2001888926',
'2001892424',
'2001892796',
'2001894439',
'2001894787',
'2001899319',
'2001900224',
'2001904802',
'2001905306',
'2001905894',
'2001906615',
'2001907405',
'2001910339',
'2001911941',
'2001916869',
'2001917736',
'2001918843',
'2001919727',
'2001919912',
'2001922389',
'2001923333',
'2001928554',
'2001929964',
'2001932038',
'2001934168',
'2001939783',
'2001940183',
'2001943490',
'2001947984',
'2001950894',
'2001954915',
'2001955077',
'2001956906',
'2001956920',
'2001958959',
'2001959136',
'2001959251',
'2001960930',
'2001961225',
'2001962084',
'2001965377',
'2001966105',
'2001966307',
'2001966686',
'2001968211',
'2001968235',
'2001968761',
'2001969102',
'2001969683',
'2001970519',
'2001971703',
'2001972308',
'2001976195',
'2001976784',
'2001981553',
'2001985542',
'2001986589',
'2001986666',
'2001986875',
'2001988323',
'2001991093',
'2001991947',
'2001992319',
'2001992573',
'2002001681',
'2002001821',
'2002002628',
'2002003362',
'2002011176',
'2002011859',
'2002013624',
'2002013871',
'2002016450',
'2002017341',
'2002022901',
'2002023683',
'2002025302',
'2002025629',
'2002027595',
'2002027672',
'2002028462',
'2002031341',
'2002031567',
'2002034672',
'2002034843',
'2002035082',
'2002036074',
'2002036625',
'2002040635',
'2002042455',
'2002046521',
'2002046615',
'2002050252',
'2002050492',
'2002052762',
'2002057130',
'2002062574',
'2002065014',
'2002066657',
'2002066765',
'2002066967',
'2002067137',
'2002067391',
'2002067423',
'2002068338',
'2002069609',
'2002071736',
'2002074081',
'2002075840',
'2002078924',
'2002079101',
'2002079118',
'2002079839',
'2002083731',
'2002085739',
'2002086480',
'2002090546',
'2002090731',
'2002091110',
'2002092412',
'2002093752',
'2002095729',
'2002097316',
'2002098656',
'2002098928',
'2002099066',
'2002101514',
'2002102342',
'2002104472',
'2002109600',
'2002113502',
'2002116756',
'2002120913',
'2002121169',
'2002122182',
'2002123066',
'2002123174',
'2002124142',
'2002126258',
'2002127815',
'2002127978',
'2002130756',
'2002132590',
'2002134891',
'2002135078',
'2002135427',
'2002136743',
'2002141226',
'2002141651',
'2002141909',
'2002143488',
'2002144379',
'2002144634',
'2002147756',
'2002148089',
'2002149228',
'2002154150',
'2002156639',
'2002158536',
'2002159953',
'2002160322',
'2002161011',
'2002164102',
'2002164195',
'2002166319',
'2002166612',
'2002170994',
'2002172668',
'2002176208',
'2002180047',
'2002180193',
'2002181293',
'2002184308',
'2002187064',
'2002187413',
'2002189598',
'2002194761',
'2002195094',
'2002199874',
'2002201207',
'2002202965',
'2002205986',
'2002209487',
'2002210003',
'2002210104',
'2002210368',
'2002215325',
'2002215705',
'2002216108',
'2002217417',
'2002219484',
'2002225500',
'2002227717',
'2002228374',
'2002229227',
'2002229537',
'2002232687',
'2002233066',
'2002242329',
'2002242987',
'2002248082',
'2002253091',
'2002259590',
'2002261108',
'2002264686',
'2002266552',
'2002269319',
'2002273590',
'2002274412',
'2002275411',
'2002277039',
'2002278090',
'2002282149',
'2002283946',
'2002288871',
'2002294980',
'2002295833',
'2002296003',
'2002298513',
'2002301185',
'2002303176',
'2002306010',
'2002306762',
'2002308520',
'2002308830',
'2002314622',
'2002317535',
'2002317984',
'2002318248',
'2002321141',
'2002321893',
'2002321901',
'2002323651',
'2002324807',
'2002325008',
'2002328029',
'2002330536',
'2002338893',
'2002340735',
'2002342175',
'2002342423',
'2002343059',
'2002343509',
'2002348977',
'2002350167',
'2002353474',
'2002356301',
'2002358417',
'2002359872',
'2002361202',
'2002362117',
'2002362441',
'2002362977',
'2002365796',
'2002378334',
'2002379371',
'2002380447',
'2002380517',
'2002380865',
'2002381888',
'2002382173',
'2002383374',
'2002388711',
'2002388850',
'2002391948',
'2002393085',
'2002393302',
'2002395153',
'2002395278',
'2002396880',
'2002402738',
'2002403629',
'2002406075',
'2002407719',
'2002409584',
'2002414663',
'2002419505',
'2002421322',
'2002421531',
'2002423940',
'2002432506',
'2002435185',
'2002436153',
'2002436160',
'2002436829',
'2002440132',
'2002441357',
'2002441908',
'2002445036',
'2002445555',
'2002445579',
'2002448691',
'2002448730',
'2002449405',
'2002451309',
'2002451873',
'2002452740',
'2002453446',
'2002460352',
'2002462406',
'2002462956',
'2002463607',
'2002464264',
'2002464327',
'2002466060',
'2002468239',
'2002468347',
'2002474603',
'2002477066',
'2002478863',
'2002478926',
'2002480844',
'2002481519',
'2002486451',
'2002487032',
'2002487739',
'2002489218',
'2002490478',
'2002492337',
'2002492577',
'2002493608',
'2002494582',
'2002496775',
'2002499239',
'2002501066',
'2002502236',
'2002502313',
'2002502320',
'2002507161',
'2002507697',
'2002509246',
'2002509633',
'2002514781',
'2002517896',
'2002519159',
'2002519414',
'2002526445',
'2002538116',
'2002542070',
'2002545572',
'2002545705',
'2002545806',
'2002551605',
'2002552286',
'2002552628',
'2002556345',
'2002558134',
'2002558499',
'2002558538',
'2002564010',
'2002565057',
'2002566498',
'2002567372',
'2002569293',
'2002572280',
'2002573195',
'2002573753',
'2002576248',
'2002578330',
'2002581480',
'2002583705',
'2002585563',
'2002586625',
'2002588229',
'2002588344',
'2002590604',
'2002591658',
'2002592664',
'2002593524',
'2002595382',
'2002595717',
'2002595786',
'2002598048',
'2002599131',
'2002600488',
'2002601139',
'2002606507',
'2002607830',
'2002608682',
'2002609193',
'2002610012',
'2002610548',
'2002614032',
'2002616403',
'2002618610',
'2002619455',
'2002620792',
'2002622877',
'2002625216',
'2002625829',
'2002626044',
'2002628662',
'2002628756',
'2002631541',
'2002632083',
'2002637280',
'2002651956',
'2002652311',
'2002663898',
'2002664138',
'2002664291',
'2002665865',
'2002675172',
'2002677473',
'2002678131',
'2002678869',
'2002681870',
'2002683049',
'2002685915',
'2002687704',
'2002687759',
'2002688525',
'2002690450',
'2002691682',
'2002694463',
'2002696269',
'2002696447',
'2002697732',
'2002698128',
'2002699590',
'2002700498',
'2002702496',
'2002704261',
'2002704355',
'2002708591',
'2002708870',
'2002711773',
'2002714408',
'2002715111',
'2002715894',
'2002720810',
'2002722793',
'2002722849',
'2002724753',
'2002725334',
'2002725822',
'2002726162',
'2002728906',
'2002729323',
'2002730204',
'2002732550',
'2002732947',
'2002734882',
'2002735355',
'2002737478',
'2002737500',
'2002737764',
'2002738105',
'2002738857',
'2002742139',
'2002743594',
'2002744106',
'2002745763',
'2002745770',
'2002746630',
'2002747646',
'2002748931',
'2002751702',
'2002752732',
'2002753849',
'2002754646',
'2002757775',
'2002757960',
'2002759951',
'2002759968',
'2002762032',
'2002762537',
'2002762861',
'2002765200',
'2002767532',
'2002768315',
'2002769802',
'2002769840',
'2002771814',
'2002775290',
'2002776958',
'2002778305',
'2002781594',
'2002785071',
'2002787815',
'2002791034',
'2002793900',
'2002798099',
'2002799036',
'2002799548',
'2002800220',
'2002800662',
'2002804947',
'2002807526',
'2002807975',
'2002808835',
'2002813781',
'2002815316',
'2002815556',
'2002817833',
'2002818863',
'2002818902',
'2002821108',
'2002821432',
'2002822330',
'2002824453',
'2002827188',
'2002828288',
'2002830283',
'2002831770',
'2002832584',
'2002832870',
'2002833754',
'2002834506',
'2002836148',
'2002836403',
'2002840413',
'2002840583',
'2002841018',
'2002841070',
'2002841607',
'2002842101',
'2002846424',
'2002847531',
'2002847889',
'2002848516',
'2002849476',
'2002850333',
'2002851224',
'2002851419',
'2002852665',
'2002853190',
'2002854524',
'2002855826',
'2002859264',
'2002861601',
'2002861764',
'2002862927',
'2002863793',
'2002863801',
'2002864350',
'2002864932',
'2002866372',
'2002866651',
'2002867814',
'2002867908',
'2002870180',
'2002870591',
'2002870724',
'2002871848',
'2002873389',
'2002873776',
'2002873891',
'2002874162',
'2002875255',
'2002875750',
'2002877145',
'2002877518',
'2002879941',
'2002880459',
'2002881915',
'2002883557',
'2002883937',
'2002884309',
'2002887229',
'2002887748',
'2002888684',
'2002889397',
'2002889412',
'2002891190',
'2002891354',
'2002894801',
'2002898030',
'2002898960',
'2002899729',
'2002900045',
'2002900348',
'2002902719',
'2002903871',
'2002903927',
'2002903934',
'2002903941',
'2002905901',
'2002906436',
'2002911438',
'2002911724',
'2002919005',
'2002919029',
'2002921404',
'2002921822',
'2002923154',
'2002928887',
'2002929204',
'2002929932',
'2002930255',
'2002931780',
'2002931812',
'2002932842',
'2002933384',
'2002933500',
'2002933555',
'2002938411',
'2002940308',
'2002942111',
'2002942407',
'2002943747',
'2002945947',
'2002947109',
'2002950406',
'2002950646',
'2002953131',
'2002953193',
'2002955300',
'2002956828',
'2002958206',
'2002962696',
'2002965477',
'2002966870',
'2002967127',
'2002968296',
'2002969396',
'2002969459',
'2002971517',
'2002974064',
'2002976721',
'2002976790',
'2002977100',
'2002978293',
'2002979519',
'2002980041',
'2002980762',
'2002981026',
'2002982265',
'2002982791',
'2002983411',
'2002983581',
'2002984566',
'2002985596',
'2002985882',
'2002987330',
'2002987347',
'2002989066',
'2002990017',
'2002990978',
'2002993595',
'2002996035',
'2002996321',
'2002996732',
'2002999443',
'2003001503',
'2003001673',
'2003004771',
'2003008070',
'2003009187',
'2003009536',
'2003011771',
'2003013313',
'2003013957',
'2003014134',
'2003015296',
'2003016271',
'2003016404',
'2003016529',
'2003019658',
'2003021879',
'2003022568',
'2003025510',
'2003026317',
'2003026463',
'2003032116',
'2003033603',
'2003036237',
'2003041330',
'2003041905',
'2003044111',
'2003044229',
'2003045622',
'2003046854',
'2003046986',
'2003047271',
'2003050129',
'2003050910',
'2003051096',
'2003052297',
'2003053373',
'2003053753',
'2003054536',
'2003055100',
'2003055573',
'2003056572',
'2003057906',
'2003059322',
'2003060948',
'2003061411',
'2003063527',
'2003064526',
'2003066959',
'2003068407',
'2003072208',
'2003076552',
'2003076747',
'2003076963',
'2003079117',
'2003080050',
'2003081383',
'2003082003',
'2003085086',
'2003089943',
'2003090158',
'2003091018',
'2003094774',
'2003095540',
'2003097012',
'2003097276',
'2003099274',
'2003102459',
'2003105742',
'2003108794',
'2003108840',
'2003110232',
'2003117266',
'2003118265',
'2003121670',
'2003121973',
'2003122749',
'2003124204',
'2003125210',
'2003126954',
'2003126978',
'2003127148',
'2003128130',
'2003129982',
'2003131312',
'2003131406',
'2003131451',
'2003132467',
'2003137688',
'2003138339',
'2003141340',
'2003146617',
'2003146958',
'2003147243',
'2003148677',
'2003149025',
'2003151169',
'2003151222',
'2003151532',
'2003152492',
'2003152834',
'2003153422',
'2003155374',
'2003157219',
'2003158047',
'2003158148',
'2003158434',
'2003158744',
'2003161010',
'2003162608',
'2003162684',
'2003164086',
'2003165263',
'2003169182',
'2003171048',
'2003178243',
'2003179475',
'2003179723',
'2003180349',
'2003181526',
'2003182448',
'2003183012',
'2003183865',
'2003186583',
'2003186639',
'2003187544',
'2003189782',
'2003190353',
'2003191422',
'2003195125',
'2003199556',
'2003200207',
'2003202445',
'2003202724',
'2003202849',
'2003207837',
'2003209626',
'2003210406',
'2003210420',
'2003210514',
'2003210886',
'2003210994',
'2003211188',
'2003211467',
'2003211791',
'2003215449',
'2003217942',
'2003220085',
'2003223277',
'2003224911',
'2003227660',
'2003228241',
'2003230260',
'2003235823',
'2003236264',
'2003238680',
'2003239913',
'2003240142',
'2003240957',
'2003243769',
'2003243992',
'2003246836',
'2003249073',
'2003249453',
'2003249554',
'2600002832',
'2600003145',
'2600004568',
'2600004611',
'2600005815',
'2600010690',
'2600011376',
'2600013548',
'2600013800',
'2600014631',
'2600014742',
'2600016232',
'2600016427',
'2600019064',
'2600019107',
'2600022058',
'2600022101',
'2600022532',
'2600026693',
'2600027184',
'2600027456',
'2600027692',
'2600028202',
'2600031772',
'2600031890',
'2600032680',
'2600034493',
'2600042521',
'2600043116',
'2600047785',
'2600048047',
'2600049234',
'2600051092',
'2600056008',
'2600056018',
'2600056483',
'2600056695',
'2600056796',
'2600057465',
'2600058558',
'2600059981',
'2600061054',
'2600064088',
'2600065106',
'2600065850',
'2600067596',
'2600069146',
'2600070361',
'2600072191',
'2600076236',
'2600077182',
'2600078860',
'2600082170',
'2600083482',
'2600084881',
'2600086270',
'2600088815',
'2600088839',
'2600089424',
'2600091342',
'2600091446',
'2600091954',
'2600095385',
'2600096538',
'2600097470',
'2600097699',
'2600098681',
'2600100043',
'2600101923',
'2600102051',
'2600103578',
'2600105092',
'2600106255',
'2600107815',
'2600110275',
'2600110520',
'2600113607',
'2600113759',
'2600114378',
'2600114597',
'2600114758',
'2600117539',
'2600118596',
'2600119198',
'2600120076',
'2600120227',
'2600121236',
'2600121619',
'2600124609',
'2600124838',
'2600125702',
'2600128228',
'2600130647',
'2600130661',
'2600130808',
'2600131061',
'2600133714',
'2600133967',
'2600136883',
'2600137306',
'2600140633',
'2600140946',
'2600145675',
'2600146681',
'2600146970',
'2600147605',
'2600151380',
'2600152981',
'2600153179',
'2600154185',
'2600154228',
'2600155042',
'2600156795',
'2600156956',
'2600158644',
'2600158856',
'2600160952',
'2600161181',
'2600161874',
'2600165587',
'2600165919',
'2600168129',
'2600168502',
'2600169374',
'2600170743',
'2600173827',
'2600176599',
'2600176921',
'2600177692',
'2600179996',
'2600181738',
'2600181856',
'2600182492',
'2600188559',
'2600190554',
'2600190672',
'2600191021',
'2600194341',
'2600194758',
'2600197664',
'2600198259',
'2600198461',
'2600198646',
'2600200271',
'2600200550',
'2600200584',
'2600200603',
'2600201653',
'2600205541',
'2600207111',
'2600208736',
'2600210284',
'2600210327',
'2600211649',
'2600213257',
'2600213445',
'2600214098',
'2600214945',
'2600215790',
'2600216724',
'2600217165',
'2600217892',
'2600218308',
'2600219994',
'2600220862',
'2600221175',
'2600221999',
'2600226734',
'2600227269',
'2600228802',
'2600232977',
'2600233400',
'2600233636',
'2600235603',
'2600235721',
'2600236653',
'2600238476',
'2600242616',
'2600244819',
'2600245606',
'2600245674',
'2600248209',
'2600249817',
'2600250746',
'2600250999',
'2600251449',
'2600252034',
'2600252118',
'2600257600',
'2600257846',
'2600258407',
'2600258590',
'2600263850',
'2600266419',
'2600267247',
'2600267298',
'2600267873',
'2600269373',
'2600269696',
'2600270947',
'2600271395',
'2600274869',
'2600275666',
'2600276675',
'2600280018',
'2600280348',
'2600287441',
'2600287475',
'2600287703',
'2600289136',
'2600291259',
'2600291690',
'2600293876',
'2600297037',
'2600297326',
'2600298063',
'2600302288',
'2600303795',
'2600308839',
'2600309075',
'2600311207',
'2600313901',
'2600314910',
'2600316037',
'2600316088',
'2600317029',
'2600318428',
'2600318866',
'2600319834',
'2600320252',
'2600324685',
'2600326719',
'2600327244',
'2600327497',
'2600339662',
'2600342504',
'2600343123',
'2600343910',
'2600343978',
'2600345885',
'2600356523',
'2600357905',
'2600358192',
'2600359675',
'2600363493',
'2600363570',
'2600368484',
'2600371938',
'2600373082',
'2600375783',
'2600375853',
'2600377057',
'2600380754',
'2600384161',
'2600384211',
'2600390071',
'2600393538',
'2600394154',
'2600395893',
'2600397662',
'2600398392',
'2600399478',
'2600399562',
'2600399663',
'2600401509',
'2600402855',
'2600403151',
'2600406702',
'2600406854',
'2600408932',
'2600412208',
'2600414698',
'2600416181',
'2600417392',
'2600421522',
'2600422743',
'2600423362',
'2600424886',
'2600425615',
'2600429412',
'2600434788',
'2600435898',
'2600439076',
'2600440512',
'2600443539',
'2600443902',
'2600443970',
'2600444064',
'2600447377',
'2600451948',
'2600453508',
'2600457999',
'2600463222',
'2600463807',
'2600465331',
'2600468926',
'2600469703',
'2600470437',
'2600470861',
'2600472539',
'2600473777',
'2600476182',
'2600477742',
'2600478445',
'2600479242',
'2600479343',
'2600480746',
'2600481042',
'2600486642',
'2600488804',
'2600490477',
'2600491163',
'2600491883',
'2600493503',
'2600495882',
'2600503008',
'2600504515',
'2600506210',
'2600506600',
'2600514088',
'2600517215',
'2600517239',
'2600518588',
'2600522658',
'2600522920',
'2600524851',
'2600524945',
'2600526792',
'2600527844',
'2600529395',
'2600531578',
'2600532348',
'2600535086',
'2600535796',
'2600541783',
'2600543309',
'2600547198',
'2600547299',
'2600551133',
'2600551177',
'2600551846',
'2600553363',
'2600553524',
'2600555912',
'2600556175',
'2600558236',
'2600558590',
'2600560823',
'2600565434',
'2600570157',
'2600570174',
'2600572394',
'2600574462',
'2600578596',
'2600579598',
'2600579665',
'2600581915',
'2600582074',
'2600582262',
'2600582864',
'2600584371',
'2600586897',
'2600589362',
'2600589405',
'2600589839',
'2600590799',
'2600590815',
'2600591280',
'2600593086',
'2600593180',
'2600593442',
'2600595036',
'2600598416',
'2600598450',
'2600600609',
'2600601803',
'2600602237',
'2600611554',
'2600614739',
'2600614749',
'2600615062',
'2600618610',
'2600621675',
'2600621998',
'2600622573',
'2600625512',
'2600626387',
'2600627090',
'2600627836',
'2600630628',
'2600631076',
'2600633016',
'2600635193',
'2600636736',
'2600638703',
'2600639820',
'2600640282',
'2600641953',
'2600643036',
'2600643571',
'2600644062',
'2600647654',
'2600651939',
'2600652387',
'2600655006',
'2600655599',
'2600655615',
'2600656005',
'2600660762',
'2600660926',
'2600663264',
'2600666415',
'2600667186',
'2600669102',
'2600670775',
'2600671377',
'2600671817',
'2600673021',
'2600673623',
'2600675335',
'2600678665',
'2600682540',
'2600685897',
'2600687329',
'2600689193',
'2600692661',
'2600693280',
'2600695223',
'2600696720',
'2600697147',
'2600698469',
'2600701846',
'2600706353',
'2600708243',
'2600709269',
'2600709837',
'2600710154',
'2600711052',
'2600711704',
'2600712078',
'2600713891',
'2600714799',
'2600716780',
'2600717257',
'2600717714',
'2600718138',
'2600719356',
'2600720402',
'2600721724',
'2600722242',
'2600723894',
'2600724159',
'2600724173',
'2600724267',
'2600724997',
'2600725437',
'2600728377',
'2600730755',
'2600732067',
'2600732652',
'2600734559',
'2600734966',
'2600735406',
'2600735813',
'2600736540',
'2600736981',
'2600742376',
'2600744249',
'2600746919',
'2600747444',
'2600748087',
'2600748477',
'2600749721',
'2600751420',
'2600751558',
'2600751820',
'2600751955',
'2600753727',
'2600753845',
'2600754945',
'2600755903',
'2600757803',
'2600759277',
'2600762432',
'2600764635',
'2600764907',
'2600767534',
'2600770377',
'2600770495',
'2600771157',
'2600772613',
'2600773013',
'2600773461',
'2600776309',
'2600776495',
'2600780168',
'2600780702',
'2600783464',
'2600783592',
'2600783618',
'2600786286',
'2600788785',
'2600790255',
'2600790272',
'2600795010',
'2600800126',
'2600801024',
'2600802895',
'2600804414',
'2600805100',
'2600807778',
'2600813069',
'2600815171',
'2600817104',
'2600819042',
'2600822850',
'2600826240',
'2600831797',
'2600832288',
'2600833990',
'2600834575',
'2600843189',
'2600843774',
'2600848570',
'2600851292',
'2600853719',
'2600854345',
'2600855226',
'2600855580',
'2600855845',
'2600857412',
'2600861594',
'2600862017',
'2600865041',
'2600868966',
'2600870113',
'2600870217',
'2600873275',
'2600875054',
'2600881973',
'2600882447',
'2600882810',
'2600883668',
'2600885353',
'2600888387',
'2600890940',
'2600893519',
'2600893856',
'2600894942',
'2600897417',
'2600908692',
'2600911491',
'2600912654',
'2600914907',
'2600919932',
'2600919990',
'2600920649',
'2600920878',
'2600925011',
'2600928062',
'2600928775',
'2600929605',
'2600932041',
'2600932287',
'2600932609',
'2600933397',
'2600934957',
'2600938821',
'2600939895',
'2600940019',
'2600942205',
'2600942340',
'2600945155',
'2600945935',
'2600949968',
'2600953735',
'2600953920',
'2600958071',
'2600958131',
'2600960086',
'2600960399',
'2600960543',
'2600971646',
'2600971791',
'2600971969',
'2600977222',
'2600977986',
'2600980499',
'2600981625',
'2600983361',
'2600983734',
'2600984454',
'2600984524',
'2600986792',
'2600992873',
'2600993246',
'2600993807',
'2600994551',
'2600994645',
'2600994857',
'2600995271',
'2601000270',
'2601001888',
'2601003068',
'2601004770',
'2601005345',
'2601009515',
'2601012129',
'2601013629',
'2601014390',
'2601020131',
'2601020225',
'2601022132',
'2601022284',
'2601023064',
'2601025691',
'2601026608',
'2601029199',
'2601032075',
'2601034822',
'2601037695',
'2601039440',
'2601043383',
'2601043494',
'2601045189',
'2601047984',
'2601048511',
'2601048639',
'2601048774',
'2601049265',
'2601050032',
'2601052565',
'2601053439',
'2601054303',
'2601055134',
'2601060425',
'2601062366',
'2601065756',
'2601067492',
'2601067586',
'2601068474',
'2601072157',
'2601075884',
'2601078520',
'2601078783',
'2601078867',
'2601081235',
'2601082678',
'2601082745',
'2601086650',
'2601089811',
'2601092772',
'2601093196',
'2601095873',
'2601096636',
'2601097840',
'2601099128',
'2601101974',
'2601106683',
'2601106794',
'2601110477',
'2601115391',
'2601115663',
'2601117594',
'2601117721',
'2601120352',
'2601120802',
'2601124573',
'2601132753',
'2601133408',
'2601135464',
'2601136695',
'2601137862',
'2601139304',
'2601139711',
'2601144774',
'2601146028',
'2601147384',
'2601147485',
'2601148749',
'2601150684',
'2601152523',
'2601152793',
'2601155607',
'2601155682',
'2601158675',
'2601160899',
'2601163027',
'2601163754',
'2601164366',
'2601167339',
'2601177080',
'2601177157',
'2601178281',
'2601179451',
'2601179942',
'2601180999',
'2601183016',
'2601185202',
'2601185489',
'2601188354',
'2601189558',
'2601190739',
'2601191341',
'2601191832',
'2601192367',
'2601195848',
'2601197805',
'2601199077',
'2601200533',
'2601202904',
'2601204684',
'2601205632',
'2601205999',
'2601206480',
'2601206591',
'2601206735',
'2601206836',
'2601209887',
'2601212510',
'2601213425',
'2601213536',
'2601216620',
'2601217754',
'2601219153',
'2601220226',
'2601220284',
'2601223344',
'2601225665',
'2601227030',
'2601238762',
'2601239455',
'2601239559',
'2601241426',
'2601242062',
'2601243925',
'2601244188',
'2601248129',
'2601249273',
'2601249646',
'2601251456',
'2601252768',
'2601257227',
'2601257396',
'2601258004',
'2601259098',
'2601259192',
'2601261399',
'2601261603',
'2601264298',
'2601264415',
'2601265253',
'2601266679',
'2601267789',
'2601268202',
'2601268357',
'2601268795',
'2601270012',
'2601271011',
'2601271994',
'2601272781',
'2601275697',
'2601278138',
'2601278730',
'2601281118',
'2601285803',
'2601293671',
'2601295739',
'2601299940',
'2601300347',
'2601303169',
'2601308456',
'2601310875',
'2601311248',
'2601311773',
'2601312916',
'2601313061',
'2601314332',
'2601318856',
'2601322378',
'2601325462',
'2601326148',
'2601327106',
'2601327318',
'2601327443',
'2601329952',
'2601330854',
'2601333635',
'2601333686',
'2601334863',
'2601335609',
'2601335889',
'2601336693',
'2601337278',
'2601339760',
'2601339972',
'2601340978',
'2601341197',
'2601345316',
'2601345969',
'2601347765',
'2601350039',
'2601354606',
'2601355302',
'2601356402',
'2601359335',
'2601366957',
'2601374114',
'2601375648',
'2601376418',
'2601377222',
'2601379714',
'2601380583',
'2601382109',
'2601385701',
'2601385802',
'2601391645',
'2601393646',
'2601397423',
'2601398264',
'2601399542',
'2601400040',
'2601400067',
'2601400117',
'2601402142',
'2601407735',
'2601407836',
'2601408007',
'2601408388',
'2601409353',
'2601410305',
'2601411509',
'2601412270',
'2601412831',
'2601417170',
'2601419050',
'2601422488',
'2601422878',
'2601424529',
'2601433184',
'2601444771',
'2601445900',
'2601446018',
'2601447807',
'2601447908',
'2601448026',
'2601450580',
'2601450606',
'2601452725',
'2601452937',
'2601455412',
'2601455487',
'2601455836',
'2601458292',
'2601458793',
'2601459876',
'2601462856',
'2601465981',
'2601469559',
'2601469862',
'2601470088',
'2601470901',
'2601473249',
'2601474638',
'2601475317',
'2601475334',
'2601475977',
'2601480430',
'2601481379',
'2601481769',
'2601482320',
'2601482404',
'2601485862',
'2601487386',
'2601489353',
'2601489810',
'2601493527',
'2601494220',
'2601495720',
'2601496669',
'2601502192',
'2601504243',
'2601505023',
'2601506090',
'2601506470',
'2601512578',
'2601513129',
'2601526724',
'2601526953',
'2601527010',
'2601539939',
'2601550514',
'2601553901',
'2601556979',
'2601557665',
'2601559868',
'2601559892',
'2601560252',
'2601561338',
'2601565465',
'2601571748',
'2601572774',
'2601573705',
'2601580701',
'2601584580',
'2601586184',
'2601588683',
'2601591280',
'2601591908',
'2601593432',
'2601594297',
'2601594990',
'2601598211',
'2601607013',
'2601609267',
'2601610465',
'2601623121',
'2601623706',
'2601623791',
'2601626868',
'2601630006',
'2601630837',
'2601632845',
'2601634150',
'2601634234',
'2601636481',
'2601637083',
'2601637268',
'2601638395',
'2601641298',
'2601641459',
'2601643409',
'2601644909',
'2601649255',
'2601654223',
'2601658767',
'2601661246',
'2601663422',
'2601674104',
'2601674111',
'2601674757',
'2601680496',
'2601680549',
'2601683411',
'2601684218',
'2601684353',
'2601688393',
'2601691084',
'2601693703',
'2601700394',
'2601706259',
'2601706471',
'2601711422',
'2601716693',
'2601717042',
'2601720063',
'2601721223',
'2601724096',
'2601728266',
'2601734674',
'2601743772',
'2601744720',
'2601748262',
'2601750505',
'2601752708',
'2601753216',
'2601756327',
'2601756580',
'2601760186',
'2601760407',
'2601767803',
'2601769684',
'2601773807',
'2601776162',
'2601776807',
'2601780192',
'2601782818',
'2601784877',
'2601786410',
'2601788724',
'2601794119',
'2601795034',
'2601795472',
'2601795915',
'2601796238',
'2601798007',
'2601799592',
'2601802471',
'2601804108',
'2601808343',
'2601809850',
'2601810473',
'2601815168',
'2601819184',
'2601822561',
'2601823832',
'2601825503',
'2601828756',
'2601842688',
'2601843381',
'2601846865',
'2601848194',
'2601848916',
'2601849246',
'2601852004',
'2601857665',
'2601870975',
'2601871688',
'2601872212',
'2601878942',
'2601879797',
'2601881445',
'2601881496',
'2601885979',
'2601886039',
'2601888020',
'2601888054',
'2601888945',
'2601889978',
'2601890685',
'2601890711',
'2601897007',
'2601897694',
'2601901293',
'2601902022',
'2601904538',
'2601906132',
'2601906792',
'2601912584',
'2601913398',
'2601913458',
'2601913542',
'2601914084',
'2601920562',
'2601921850',
'2601923468',
'2601924231',
'2601933030',
'2601933895',
'2601938691',
'2601941890',
'2601943975',
'2601944143',
'2601944288',
'2601953070',
'2601955340',
'2601955461',
'2601957011',
'2601959181',
'2601962067',
'2601969439',
'2601970493',
'2601975450',
'2601979069',
'2601979399',
'2601980115',
'2601980401',
'2601986045',
'2601986943',
'2601987639',
'2601988614',
'2601991541',
'2601991931',
'2601994753',
'2601998920',
'2602002786',
'2602003115',
'2602003303',
'2602009751',
'2602011739',
'2602012288',
'2602016034',
'2602018143',
'2602020817',
'2602021097',
'2602023545',
'2602023774',
'2602024689',
'2602025122',
'2602028893',
'2602029976',
'2602030702',
'2602031779',
'2602031802',
'2602033760',
'2602038219',
'2602039548',
'2602046204',
'2602051936',
'2602056325',
'2602056833',
'2602057166',
'2602065178',
'2602065380',
'2602067092',
'2602067404',
'2602068286',
'2602072739',
'2602073418',
'2602074730',
'2602075655',
'2602076129',
'2602076610',
'2602078874',
'2602081938',
'2602082251',
'2602085285',
'2602088268',
'2602094914',
'2602102267',
'2602103514',
'2602103521',
'2602103904',
'2602104853',
'2602104995',
'2602108209',
'2602108250',
'2602109750',
'2602109986',
'2602110975',
'2602112330',
'2602113568',
'2602113999',
'2602115448',
'2602118650',
'2602119370',
'2602120655',
'2602120884',
'2602123571',
'2602127146',
'2602129833',
'2602130913',
'2602131303',
'2602132023',
'2602133887',
'2602135201',
'2602136675',
'2602138081',
'2602138225',
'2602138514',
'2602139607',
'2602140519',
'2602140695',
'2602145188',
'2602146254',
'2602149001',
'2602149119',
'2602149170',
'2602158063',
'2602158383',
'2602158766',
'2602161702',
'2602162295',
'2602164471',
'2602164498',
'2602165083',
'2602167091',
'2602167810',
'2602171002',
'2602176814',
'2602178348',
'2602180979',
'2602181241',
'2602183709',
'2602187920',
'2602188055',
'2602189454',
'2602190026',
'2602190430',
'2602192354',
'2602192532',
'2602192990',
'2602194490',
'2602195737',
'2602195905',
'2602201987',
'2602202726',
'2602202784',
'2602206181',
'2602212746',
'2602214320',
'2602214821',
'2602215652',
'2602215693',
'2602216701',
'2602219870',
'2602221706',
'2602225171',
'2602226832',
'2602227088',
'2602228867',
'2602231514',
'2602234276',
'2602237878',
'2602239700',
'2602241585',
'2602250003',
'2602250208',
'2602250596',
'2602250892',
'2602261090',
'2602266904',
'2602267140',
'2602267887',
'2602275908',
'2602280285',
'2602284724',
'2602285733',
'2602287378',
'2602288878',
'2602293745',
'2602295948',
'2602299812',
'2602309717',
'2602316626',
'2602319320',
'2602324315',
'2602324874',
'2602328341',
'2602329391',
'2602329831',
'2602331241',
'2602331285',
'2602331352',
'2602333286',
'2602340211',
'2602350419',
'2602350460',
'2602353241',
'2602378917',
'2602389647',
'2602408411',
'2602424206',
'2602424365',
'2602436039',
'2602440194',
'2602440755',
'2602445693',
'2602449210',
'2602450375',
'2602451646',
'2602454706',
'2602460048',
'2602463768',
'2602464895',
'2602467370',
'2602468335',
'2602468429',
'2602471527',
'2602476196',
'2602482115',
'2602487595',
'2602501869',
'2602507445',
'2602507987',
'2602510701',
'2602512726',
'2602513032',
'2602517922',
'2602520967',
'2602522349',
'2602524078',
'2602524424',
'2602529018',
'2602531726',
'2602531945',
'2602534827',
'2602538386',
'2602539869',
'2602542076',
'2602542610',
'2602543085',
'2602543142',
'2602544185',
'2602549186',
'2602550528',
'2602550757',
'2602551715',
'2602553172',
'2602556104',
'2602560182',
'2602561439',
'2602565351',
'2602566030',
'2602570780',
'2602573289',
'2602573534',
'2602577187',
'2602578838',
'2602580978',
'2602582020',
'2602582511',
'2602591226',
'2602591347',
'2602591371',
'2602591508',
'2602593311',
'2602594395',
'2602594677',
'2602604249',
'2602612143',
'2602623145',
'2602625950',
'2602631487',
'2602633596',
'2602634494',
'2602646178',
'2602659019',
'2602661633',
'2602663910',
'2602664031',
'2602664741',
'2602666090',
'2602668165',
'2602673974',
'2602680038',
'2602700377',
'2602705401',
'2602711641',
'2602715684',
'2602723204',
'2602724187',
'2602726137',
'2602727560',
'2602731570',
'2602732064',
'2602735394',
'2602738622',
'2602744398',
'2602748753',
'2602748837',
'2602751162',
'2602751384',
'2602751663',
'2602753096',
'2602755867',
'2602756671',
'2602756873',
'2602757179',
'2602759671',
'2602761283',
'2602763724',
'2602764175',
'2602764269',
'2602770398',
'2602770956',
'2602771481',
'2602773424',
'2602773754',
'2602774464',
'2602774676',
'2602777312',
'2602781638',
'2602782859',
'2602782926',
'2602784951',
'2602788476',
'2602788707',
'2602791268',
'2602804213',
'2602805266',
'2602807476',
'2602809255',
'2602813133',
'2602816056',
'2602816860',
'2602818107',
'2602825423',
'2602829600',
'2602836173',
'2602841252',
'2602841406',
'2602845015',
'2602846159',
'2602847175',
'2602848227',
'2602848846',
'2602852307',
'2602855738',
'2602859619',
'2602865122',
'2602867164',
'2602883689',
'2602883891',
'2602894395',
'2602926956',
'2602929619',
'2602930690',
'2602931053',
'2602931308',
'2602932300',
'2602935654',
'2602936885',
'2602936918',
'2602937934',
'2602937951',
'2602938654',
'2602939495',
'2602947887',
'2602952720',
'2602955687',
'2602957584',
'2602970032',
'2602970701',
'2602971118',
'2602973678',
'2602976422',
'2602976796',
'2602977700',
'2602977939',
'2602981384',
'2602986213',
'2602989307',
'2602989748',
'2602997394',
'2603001928',
'2603003206',
'2603004716',
'2603015769',
'2603017955',
'2603021551',
'2603022984',
'2603023263',
'2603027211',
'2603030081',
'2603033165',
'2603037648',
'2603037833',
'2603039403',
'2603041177',
'2603041415',
'2603048532',
'2603058000',
'2603059103',
'2603063564',
'2603068800',
'2603072296',
'2603072898',
'2603073533',
'2603081545',
'2603084121',
'2603084673',
'2603085487',
'2603087730',
'2603088315',
'2603093024',
'2603097403',
'2603103037',
'2603106309',
'2603107130',
'2603114735',
'2603118159',
'2603118219',
'2603127194',
'2603132478',
'2603132885',
'2603135290',
'2603136174',
'2603140846',
'2603142592',
'2603142625',
'2603145524',
'2603145592',
'2603147448',
'2603149446',
'2603149998',
'2603150519',
'2603150731',
'2603154249',
'2603156375',
'2603156594',
'2603158366',
'2603171185',
'2603178880',
'2603178923',
'2603181214',
'2603183656',
'2603184460',
'2603191056',
'2603192125',
'2603196293',
'2603197405',
'2603197843',
'2603200749',
'2603211684',
'2603212201',
'2603218904',
'2603221051',
'2603221694',
'2603227347',
'2603227482',
'2603228009',
'2603235376',
'2603235460',
'2603238833',
'2603241794',
'2603244430',
'2603245567',
'2603247618',
'2603252644',
'2603260057',
'2603262014',
'2603265378',
'2603266158',
'2603275499',
'2603281435',
'2603289484',
'2603289537',
'2603290540',
'2603290701',
'2603292192',
'2603294462',
'2603299607',
'2603302070',
'2603307189',
'2603314413',
'2603315439',
'2603320263',
'2603324043',
'2603327635',
'2603329761',
'2603331241',
'2603334944',
'2603338758',
'2603345075',
'2603345489',
'2603347793',
'2603352263',
'2603355653',
'2603358085',
'2603359578',
'2603368172',
'2603381323',
'2603381492',
'2603386281',
'2603386890',
'2603389765',
'2603402748',
'2603406518',
'2603406908',
'2603410242',
'2603412792',
'2603419444',
'2603420144',
'2603422431',
'2603429921',
'2603430383',
'2603431173',
'2603449617',
'2603451807',
'2603453146',
'2603458363',
'2603459119',
'2603467199',
'2603468891',
'2603469062',
'2603474192',
'2603480485',
'2603496538',
'2603497039',
'2603499384',
'2603502646',
'2603502653',
'2603506221',
'2603507909',
'2603512360',
'2603513497',
'2603524270',
'2603525760',
'2603527330',
'2603527804',
'2603529355',
'2603529600',
'2603537249',
'2603537798',
'2603543573',
'2603549361',
'2603557702',
'2603557982',
'2603558025',
'2603559983',
'2603563061',
'2603563333',
'2603563485',
'2603566673',
'2603572448',
'2603575566',
'2603575650',
'2603586645',
'2603591563',
'2603595461',
'2603609815',
'2603609950',
'2603612080',
'2603619919',
'2603624474',
'2603625805',
'2603630986',
'2603631308',
'2603631917',
'2603636935',
'2603638197',
'2603639586',
'2603647268',
'2603652754',
'2603659481',
'2603659693',
'2603669588',
'2603670362',
'2603670836',
'2603679668',
'2603681111',
'2603681899',
'2603683001',
'2603689603',
'2603694319',
'2603695554',
'2603704739',
'2603707770',
'2603712960',
'2603713013',
'2603725404',
'2603725431',
'2603727906',
'2603733773',
'2603738128',
'2603738586',
'2603739840',
'2603740937',
'2603742165',
'2603745276',
'2603746631',
'2603749658',
'2603750543',
'2603750974',
'2603751583',
'2603753634',
'2603768638',
'2603770674',
'2603771948',
'2603773404',
'2603773421',
'2603774548',
'2603775066',
'2603777057',
'2603778641',
'2603778718',
'2603807321',
'2603817960',
'2603824041',
'2603825464',
'2603829405',
'2603829473',
'2603830933',
'2603831501',
'2603832137',
'2603832900',
'2603839560',
'2603844555',
'2603851753',
'2603855237',
'2603855516',
'2603855846',
'2603857803',
'2603874843',
'2603882246',
'2603884220',
'2603894671',
'2603900584',
'2603902050',
'2603907364',
'2603909991',
'2603910479',
'2603914054',
'2603918120',
'2603918494',
'2603922947',
'2603935711',
'2603965892',
'2603967866',
'2603972565',
'2603973379',
'2603977963',
'2603983584',
'2603985601',
'2603992157',
'2603992756',
'2603992773',
'2603993893',
'2603996146',
'2603996748',
'2603999529',
'2604007492',
'2604010378',
'2604011158',
'2604011488',
'2604015877',
'2604018436',
'2604019045',
'2604022059',
'2604023889',
'2604028251',
'2604036670',
'2604038298',
'2604043989',
'2604044386',
'2604045055',
'2604048428',
'2604050245',
'2604051991',
'2604054042',
'2604067731',
'2604068713',
'2604070389',
'2604074566',
'2604074700',
'2604078608',
'2604081576',
'2604082255',
'2604089254',
'2604089695',
'2604091488',
'2604091716',
'2604092106',
'2604092809',
'2604092978',
'2604098063',
'2604101332',
'2604113495',
'2604114376',
'2604115011',
'2604126965',
'2604148572',
'2604148656',
'2604149412',
'2604157297',
'2604159210',
'2604161199',
'2604162809',
'2604164952',
'2604168604',
'2604182069',
'2604183078',
'2604183713',
'2604184797',
'2604198079',
'2604203467',
'2604205959',
'2604206467',
'2604207957',
'2604210224',
'2604212249',
'2604214741',
'2604214835',
'2604224431',
'2604224879',
'2604225016',
'2604252490',
'2604253609',
'2604254286',
'2604257794',
'2604258617',
'2604262392',
'2604263781',
'2604269892',
'2604272294',
'2604272640',
'2604278785',
'2604285135',
'2604292918',
'2604296443',
'2604303271',
'2604319230',
'2604319765',
'2604326320',
'2604342004',
'2604350286',
'2604351008',
'2604357049',
'2604365976',
'2604367890',
'2604371021',
'2604372117',
'2604379860',
'2604382736',
'2604384128',
'2604402473',
'2604405271',
'2604410367',
'2604411265',
'2604413326',
'2604422590',
'2604430204',
'2604430638',
'2604431832',
'2604440487',
'2604443631',
'2604444166',
'2604461095',
'2604465756',
'2604470633',
'2604470734',
'2604477504',
'2604494419',
'2604500770',
'2604504136',
'2604504449',
'2604507897',
'7005184056',
'7005219808',
'7005233125',
'7005369976',
'7005417039',
'7005514617',
'7005559951',
'7005689335',
'7005711368',
'7005775195',
'7005882390',
'7006044559',
'7006198243',
'7006253933',
'7006323663',
'7006351488',
'7612066743',
'7612706011',
'7613333105',
'7613649681',
'7615439626',
'7615630786',
'7615656004',
'7634321579',
'7635363514',
'7636648894',
'7636945308',
'7637099900',
'7637399881',
'7638817921',
'7639151419',
'7639426408',
'7640649332',
'7640859131',
'7640872774',
'7642193534',
'7642377865',
'7642597505',
'7642904104',
'8000575164',
'8000577458',
'8601186644',
'8601506973',
'8601847300',
'8602092249',
'8602209287',
'8602569940',
'8603196930',
'8603459545',
'8603580291',
'8604049839',
'8604069835',
'8604074019',
'8604082539',
'8604244109',
'8604428100',
'8604495615',
'8604504959'
)
group by p1.cst_id
order by p1.cst_id
;
**数据需求_运管部服务经理理财需求.sql
-- ODPS SQL 临时查询
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-07 16:23:34
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

select p2.empe_id as 员工号
      ,p2.empe_nm as 员工姓名
      --,p1.lgp_id as 法人编号
      ,p1.pos_nm as 职位名称
      ,p2.org_id as 机构编号
      ,p3.brc_org_nm as 分行层级机构名称
      ,p3.sbr_org_nm as 支行层级机构名称
      ,p2.lbr_tp_sts as 用工状态代码
from edw.dim_hr_org_job_inf_dd p1
left join edw.dws_hr_empe_inf_dd p2
on p1.pos_id = p2.pos_enc
and p1.dt = '20210701'
left join edw.dim_hr_org_mng_org_tree_dd p3
on p3.org_id = p2.org_id
and p3.dt = '20210701'
--left join edw.dim_hr_org_bas_inf_dd p3
--on p3.org_id = p2.org_id
--and p3.dt = '20210701'
where p2.dt = '20210701'
and p1.pos_nm = '服务经理'
;

--------------------------------------------------------------4月数据----------------------------------------------------------------------------
--2.获取理财销售客户经理、存款管护经理
DROP TABLE IF EXISTS TMP_DATA_HCL_024618_20210707_202101_02;

CREATE TABLE IF NOT EXISTS TMP_DATA_HCL_024618_20210707_202101_02
(
    FNC_AR_ID        STRING
    ,BNK_AC_ID       STRING
    ,CST_ID          STRING
    --,CST_NM                         STRING
    ,PD_CD           STRING
    ,PD_NM           STRING
    ,TA_CD           STRING
    ,CTL_IND         STRING
    ,PD_TP_CD        STRING
    ,PD_IVST_TP_CD   STRING
    ,TRX_MTH_CD      STRING
    ,FNC_AMT         DECIMAL
    ,PD_NET_VAL      DECIMAL
    ,FNC_BAL         DECIMAL
    ,INVST_MAT_DT    STRING
    ,ORG_UNT_ID      STRING
    ,FNC_CST_MNGR_ID STRING
    ,DEP_CST_MNGR_ID STRING
    ,DEP_CST_ORG_ID  STRING
    ,DEP_CST_ORG_NM  STRING
    ,ACS_RTO         DECIMAL
);

INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_02
SELECT  A.CHM_CST_ID
        ,A.BNK_ACT_ID
        ,A.CST_ID
        --,F.CST_CHN_NM
        ,C.PD_CD
        ,C.PD_NM
        ,C.TA_CD
        ,SUBSTR(C.CTRL_IND, 53, 1)
        ,C.PD_CTG_CD
        ,C.CHM_INV_TYP_CD
        ,C.TRX_MTH_CD
        ,A.CUR_LOT
        ,C.PD_NAV
        ,A.CUR_LOT * C.PD_NAV
        ,CONCAT(SUBSTR(A.INVST_MAT_DT, 1, 4), '-', SUBSTR(A.INVST_MAT_DT, 5, 2), '-', SUBSTR(A.INVST_MAT_DT, 7, 2))
        ,A.LOT_AFL_ORG_ID
        ,COALESCE(B.MGR_ID, '')     AS FNC_CST_MNGR_ID
        ,COALESCE(D.MGR_ID, '')     AS DEP_CST_MNGR_ID --考核客户经理编号
        ,COALESCE(D.ACS_ORG_ID, '') AS DEP_CST_ORG_ID
        ,COALESCE(G.ORG_NM, '')     AS DEP_CST_ORG_NM
        ,COALESCE(D.MGR_RTO, 0)     AS ACS_RTO
FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A --理财账户份额汇总信息
LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
ON      A.CHM_CST_ID = B.CHM_CST_ID
AND     A.TA_CD = B.TA_CD
AND     B.DT = '20210430'
INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C --SOR.FNC_PD
ON      A.PD_CD = C.PD_CD
AND     C.DT = '20210430'
LEFT JOIN    edw.DWD_BUS_DEP_CST_ACT_MGR_INF_DD D --客户存款账户管护信息
ON      A.BNK_ACT_ID = D.CST_ACT_ID
AND     D.DT = '20210430'
INNER JOIN    edw.DWS_CST_BAS_INF_DD F
ON      A.CST_ID = F.CST_ID
AND     F.DT = '20210430'
LEFT JOIN    edw.DIM_HR_ORG_BAS_INF_DD G --机构基本信息
ON      D.ACS_ORG_ID = G.ORG_ID
AND     G.DT = '20210430'
WHERE   A.DT = '20210430';



DROP TABLE IF EXISTS TMP_DATA_HCL_024618_20210707_202101_03;

CREATE TABLE IF NOT EXISTS TMP_DATA_HCL_024618_20210707_202101_03
(
    MNG_ID           STRING
    ,DEP_FBB_FNC_BAL DECIMAL
    ,DEP_FBS_FNC_BAL DECIMAL
    ,DEP_KFS_FNC_BAL DECIMAL
    ,DEP_FNC_BAL     DECIMAL
);


--存款管护关系-理财余额
INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_03
SELECT  A.dep_cst_mngr_id
        ,ROUND(SUM(CASE
                     WHEN A.PD_TP_CD IN ( '1' , '2' ) AND A.CTL_IND = '2' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 非保本理财保有量
        ,ROUND(SUM(CASE
                     WHEN A.TRX_MTH_CD = '2' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 封闭式理财保有量
        ,ROUND(SUM(CASE
                     WHEN A.TRX_MTH_CD = '0' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 开放式理财保有量
        ,ROUND(SUM(A.FNC_BAL * A.ACS_RTO), 2) AS 理财产品余额
FROM    TMP_DATA_HCL_024618_20210707_202101_02 A
WHERE   A.PD_TP_CD = '1' --理财
GROUP BY A.dep_cst_mngr_id;





DROP TABLE IF EXISTS TMP_DATA_HCL_024618_20210707_202101_04;

CREATE TABLE IF NOT EXISTS TMP_DATA_HCL_024618_20210707_202101_04
(
    MNG_ID           STRING
    ,FNC_FBB_FNC_BAL DECIMAL
    ,FNC_FBS_FNC_BAL DECIMAL
    ,FNC_KFS_FNC_BAL DECIMAL
    ,FNC_FNC_BAL     DECIMAL
);

--销售管护关系-理财余额
INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_04
SELECT  COALESCE(B.MGR_ID, '')
        ,ROUND(SUM(CASE
                     WHEN C.PD_CTG_CD IN ( '1' , '2' ) AND SUBSTR(C.CTRL_IND, 53, 1) = '2' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 非保本理财保有量
        ,ROUND(SUM(CASE
                     WHEN C.TRX_MTH_CD = '2' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 封闭式理财保有量
        ,ROUND(SUM(CASE
                     WHEN C.TRX_MTH_CD = '0' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 开放式理财保有量
        ,ROUND(SUM(A.CUR_LOT * C.PD_NAV), 2) AS 理财产品余额
FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A --理财账户份额汇总信息
LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
ON      A.CHM_CST_ID = B.CHM_CST_ID
AND     A.TA_CD = B.TA_CD
AND     B.DT = '20210430'
INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C --SOR.FNC_PD
ON      A.PD_CD = C.PD_CD
AND     C.DT = '20210430'
WHERE   A.DT = '20210430'
AND     C.pd_ctg_cd = '1' --理财
GROUP BY COALESCE(B.MGR_ID, '');




DROP TABLE IF EXISTS DATA_HCL_024618_20210707_202101;

CREATE TABLE IF NOT EXISTS DATA_HCL_024618_20210707_202101 AS
SELECT  A . *
        ,B.DEP_FBB_FNC_BAL  AS 管户关系_非保本理财保有量
        ,B.DEP_FBS_FNC_BAL  AS 管户关系_封闭式理财保有量
        ,B.DEP_KFS_FNC_BAL  AS 管户关系_开放式理财保有量
        ,B.DEP_FNC_BAL      AS 管户关系_理财产品余额
        ,B1.DEP_FNC_BAL_AVG AS 管户关系_理财产品月日均
        ,C.FNC_FBB_FNC_BAL  AS 销售关系_非保本理财保有量
        ,C.FNC_FBS_FNC_BAL  AS 销售关系_封闭式理财保有量
        ,C.FNC_KFS_FNC_BAL  AS 销售关系_开放式理财保有量
        ,C.FNC_FNC_BAL      AS 销售关系_理财产品余额
        ,C1.FNC_BAL_AVG     AS 销售关系_理财产品月日均
--from EDW.DIM_HR_EMPE_BAS_INF_DD A
--FROM    TMP_DATA_HCL_024618_20210707_01 A
from (
  select p2.empe_id --as 员工号
      ,p2.empe_nm as 员工姓名
      --,p1.lgp_id as 法人编号
      ,p1.pos_nm as 职位名称
      ,p2.org_id as 机构编号
      ,p3.brc_org_nm as 分行层级机构名称
      ,p3.sbr_org_nm as 支行层级机构名称
      ,p2.lbr_tp_sts as 用工状态代码
from edw.dim_hr_org_job_inf_dd p1
left join edw.dws_hr_empe_inf_dd p2
on p1.pos_id = p2.pos_enc
and p1.dt = '20210701'
left join edw.dim_hr_org_mng_org_tree_dd p3
on p3.org_id = p2.org_id
and p3.dt = '20210701'
--left join edw.dim_hr_org_bas_inf_dd p3
--on p3.org_id = p2.org_id
--and p3.dt = '20210701'
where p2.dt = '20210701'
and p1.pos_nm = '服务经理'
) A
LEFT JOIN    TMP_DATA_HCL_024618_20210707_202101_03 B
ON      B.MNG_ID = A.EMPE_ID
--考核-月日均
LEFT JOIN    (
                 SELECT  COALESCE(A.mgr_id, '')                             AS MNG_ID
                         ,ROUND(sum(a.mon_acm_lot_acml * C.pd_nav) / 31, 2) AS DEP_FNC_BAL_AVG
                 FROM    edw.DWS_BUS_CHM_ACT_MGR_INF_DD A
                 INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C
                 ON      A.PD_CD = C.PD_CD
                 AND     C.DT = '20210430'
                 WHERE   a.dt = '20210430'
                 AND     c.pd_ctg_cd = '1'
                 GROUP BY COALESCE(A.mgr_id, '')
             ) B1
ON      B1.MNG_ID = A.EMPE_ID
LEFT JOIN    TMP_DATA_HCL_024618_20210707_202101_04 C
ON      C.MNG_ID = A.EMPE_ID
--销售-月日均
LEFT JOIN    (
                 SELECT  COALESCE(B.mgr_id, '')                             AS MNG_ID
                         ,ROUND(sum(a.mon_acm_lot_acml * C.pd_nav) / 31, 2) AS FNC_BAL_AVG
                 FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A
                 LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
                 ON      A.CHM_CST_ID = B.CHM_CST_ID
                 AND     A.TA_CD = B.TA_CD
                 AND     B.DT = '20210430'
                 INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C
                 ON      A.PD_CD = C.PD_CD
                 AND     C.DT = '20210430'
                 WHERE   a.dt = '20210430'
                 AND     c.pd_ctg_cd = '1'
                 GROUP BY COALESCE(B.mgr_id, '')
             ) C1
ON      C1.MNG_ID = A.EMPE_ID;
---------------------------------------------------------

select *
from DATA_HCL_024618_20210707_202101

-----------------------------------------------------------5月数据---------------------------------------------------------------------------------------------

INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_02
SELECT  A.CHM_CST_ID
        ,A.BNK_ACT_ID
        ,A.CST_ID
        --,F.CST_CHN_NM
        ,C.PD_CD
        ,C.PD_NM
        ,C.TA_CD
        ,SUBSTR(C.CTRL_IND, 53, 1)
        ,C.PD_CTG_CD
        ,C.CHM_INV_TYP_CD
        ,C.TRX_MTH_CD
        ,A.CUR_LOT
        ,C.PD_NAV
        ,A.CUR_LOT * C.PD_NAV
        ,CONCAT(SUBSTR(A.INVST_MAT_DT, 1, 4), '-', SUBSTR(A.INVST_MAT_DT, 5, 2), '-', SUBSTR(A.INVST_MAT_DT, 7, 2))
        ,A.LOT_AFL_ORG_ID
        ,COALESCE(B.MGR_ID, '')     AS FNC_CST_MNGR_ID
        ,COALESCE(D.MGR_ID, '')     AS DEP_CST_MNGR_ID --考核客户经理编号
        ,COALESCE(D.ACS_ORG_ID, '') AS DEP_CST_ORG_ID
        ,COALESCE(G.ORG_NM, '')     AS DEP_CST_ORG_NM
        ,COALESCE(D.MGR_RTO, 0)     AS ACS_RTO
FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A --理财账户份额汇总信息
LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
ON      A.CHM_CST_ID = B.CHM_CST_ID
AND     A.TA_CD = B.TA_CD
AND     B.DT = '20210531'
INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C --SOR.FNC_PD
ON      A.PD_CD = C.PD_CD
AND     C.DT = '20210531'
LEFT JOIN    edw.DWD_BUS_DEP_CST_ACT_MGR_INF_DD D --客户存款账户管护信息
ON      A.BNK_ACT_ID = D.CST_ACT_ID
AND     D.DT = '20210531'
INNER JOIN    edw.DWS_CST_BAS_INF_DD F
ON      A.CST_ID = F.CST_ID
AND     F.DT = '20210531'
LEFT JOIN    edw.DIM_HR_ORG_BAS_INF_DD G --机构基本信息
ON      D.ACS_ORG_ID = G.ORG_ID
AND     G.DT = '20210531'
WHERE   A.DT = '20210531';


--存款管护关系-理财余额
INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_03
SELECT  A.dep_cst_mngr_id
        ,ROUND(SUM(CASE
                     WHEN A.PD_TP_CD IN ( '1' , '2' ) AND A.CTL_IND = '2' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 非保本理财保有量
        ,ROUND(SUM(CASE
                     WHEN A.TRX_MTH_CD = '2' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 封闭式理财保有量
        ,ROUND(SUM(CASE
                     WHEN A.TRX_MTH_CD = '0' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 开放式理财保有量
        ,ROUND(SUM(A.FNC_BAL * A.ACS_RTO), 2) AS 理财产品余额
FROM    TMP_DATA_HCL_024618_20210707_202101_02 A
WHERE   A.PD_TP_CD = '1' --理财
GROUP BY A.dep_cst_mngr_id;



--销售管护关系-理财余额
INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_04
SELECT  COALESCE(B.MGR_ID, '')
        ,ROUND(SUM(CASE
                     WHEN C.PD_CTG_CD IN ( '1' , '2' ) AND SUBSTR(C.CTRL_IND, 53, 1) = '2' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 非保本理财保有量
        ,ROUND(SUM(CASE
                     WHEN C.TRX_MTH_CD = '2' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 封闭式理财保有量
        ,ROUND(SUM(CASE
                     WHEN C.TRX_MTH_CD = '0' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 开放式理财保有量
        ,ROUND(SUM(A.CUR_LOT * C.PD_NAV), 2) AS 理财产品余额
FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A --理财账户份额汇总信息
LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
ON      A.CHM_CST_ID = B.CHM_CST_ID
AND     A.TA_CD = B.TA_CD
AND     B.DT = '20210531'
INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C --SOR.FNC_PD
ON      A.PD_CD = C.PD_CD
AND     C.DT = '20210531'
WHERE   A.DT = '20210531'
AND     C.pd_ctg_cd = '1' --理财
GROUP BY COALESCE(B.MGR_ID, '')
;

DROP TABLE IF EXISTS DATA_HCL_024618_20210707_202102;
CREATE TABLE IF NOT EXISTS DATA_HCL_024618_20210707_202102 AS
SELECT  A . *
        ,B.DEP_FBB_FNC_BAL  AS 管户关系_非保本理财保有量
        ,B.DEP_FBS_FNC_BAL  AS 管户关系_封闭式理财保有量
        ,B.DEP_KFS_FNC_BAL  AS 管户关系_开放式理财保有量
        ,B.DEP_FNC_BAL      AS 管户关系_理财产品余额
        ,B1.DEP_FNC_BAL_AVG AS 管户关系_理财产品月日均
        ,C.FNC_FBB_FNC_BAL  AS 销售关系_非保本理财保有量
        ,C.FNC_FBS_FNC_BAL  AS 销售关系_封闭式理财保有量
        ,C.FNC_KFS_FNC_BAL  AS 销售关系_开放式理财保有量
        ,C.FNC_FNC_BAL      AS 销售关系_理财产品余额
        ,C1.FNC_BAL_AVG     AS 销售关系_理财产品月日均
--FROM    TMP_DATA_HCL_024618_20210707_01 A
from (
  select p2.empe_id --as 员工号
      ,p2.empe_nm as 员工姓名
      --,p1.lgp_id as 法人编号
      ,p1.pos_nm as 职位名称
      ,p2.org_id as 机构编号
      ,p3.brc_org_nm as 分行层级机构名称
      ,p3.sbr_org_nm as 支行层级机构名称
      ,p2.lbr_tp_sts as 用工状态代码
from edw.dim_hr_org_job_inf_dd p1
left join edw.dws_hr_empe_inf_dd p2
on p1.pos_id = p2.pos_enc
and p1.dt = '20210701'
left join edw.dim_hr_org_mng_org_tree_dd p3
on p3.org_id = p2.org_id
and p3.dt = '20210701'
--left join edw.dim_hr_org_bas_inf_dd p3
--on p3.org_id = p2.org_id
--and p3.dt = '20210701'
where p2.dt = '20210701'
and p1.pos_nm = '服务经理'
) A
LEFT JOIN    TMP_DATA_HCL_024618_20210707_202101_03 B
ON      B.MNG_ID = A.EMPE_ID
--考核-月日均
LEFT JOIN    (
                 SELECT  COALESCE(A.mgr_id, '')                             AS MNG_ID
                         ,ROUND(sum(a.mon_acm_lot_acml * C.pd_nav) / 31, 2) AS DEP_FNC_BAL_AVG
                 FROM    edw.DWS_BUS_CHM_ACT_MGR_INF_DD A
                 INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C
                 ON      A.PD_CD = C.PD_CD
                 AND     C.DT = '20210531'
                 WHERE   a.dt = '20210531'
                 AND     c.pd_ctg_cd = '1'
                 GROUP BY COALESCE(A.mgr_id, '')
             ) B1
ON      B1.MNG_ID = A.EMPE_ID
LEFT JOIN    TMP_DATA_HCL_024618_20210707_202101_04 C
ON      C.MNG_ID = A.EMPE_ID
--销售-月日均
LEFT JOIN    (
                 SELECT  COALESCE(B.mgr_id, '')                             AS MNG_ID
                         ,ROUND(sum(a.mon_acm_lot_acml * C.pd_nav) / 31, 2) AS FNC_BAL_AVG
                 FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A
                 LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
                 ON      A.CHM_CST_ID = B.CHM_CST_ID
                 AND     A.TA_CD = B.TA_CD
                 AND     B.DT = '20210531'
                 INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C
                 ON      A.PD_CD = C.PD_CD
                 AND     C.DT = '20210531'
                 WHERE   a.dt = '20210531'
                 AND     c.pd_ctg_cd = '1'
                 GROUP BY COALESCE(B.mgr_id, '')
             ) C1
ON      C1.MNG_ID = A.EMPE_ID;
------------------------------------------------------



-----------------------------------------------------------6月数据---------------------------------------------------------------------------------------------

INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_02
SELECT  A.CHM_CST_ID
        ,A.BNK_ACT_ID
        ,A.CST_ID
        --,F.CST_CHN_NM
        ,C.PD_CD
        ,C.PD_NM
        ,C.TA_CD
        ,SUBSTR(C.CTRL_IND, 53, 1)
        ,C.PD_CTG_CD
        ,C.CHM_INV_TYP_CD
        ,C.TRX_MTH_CD
        ,A.CUR_LOT
        ,C.PD_NAV
        ,A.CUR_LOT * C.PD_NAV
        ,CONCAT(SUBSTR(A.INVST_MAT_DT, 1, 4), '-', SUBSTR(A.INVST_MAT_DT, 5, 2), '-', SUBSTR(A.INVST_MAT_DT, 7, 2))
        ,A.LOT_AFL_ORG_ID
        ,COALESCE(B.MGR_ID, '')     AS FNC_CST_MNGR_ID
        ,COALESCE(D.MGR_ID, '')     AS DEP_CST_MNGR_ID --考核客户经理编号
        ,COALESCE(D.ACS_ORG_ID, '') AS DEP_CST_ORG_ID
        ,COALESCE(G.ORG_NM, '')     AS DEP_CST_ORG_NM
        ,COALESCE(D.MGR_RTO, 0)     AS ACS_RTO
FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A --理财账户份额汇总信息
LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
ON      A.CHM_CST_ID = B.CHM_CST_ID
AND     A.TA_CD = B.TA_CD
AND     B.DT = '20210630'
INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C --SOR.FNC_PD
ON      A.PD_CD = C.PD_CD
AND     C.DT = '20210630'
LEFT JOIN    edw.DWD_BUS_DEP_CST_ACT_MGR_INF_DD D --客户存款账户管护信息
ON      A.BNK_ACT_ID = D.CST_ACT_ID
AND     D.DT = '20210630'
INNER JOIN    edw.DWS_CST_BAS_INF_DD F
ON      A.CST_ID = F.CST_ID
AND     F.DT = '20210630'
LEFT JOIN    edw.DIM_HR_ORG_BAS_INF_DD G --机构基本信息
ON      D.ACS_ORG_ID = G.ORG_ID
AND     G.DT = '20210630'
WHERE   A.DT = '20210630';



--存款管护关系-理财余额
INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_03
SELECT  A.dep_cst_mngr_id
        ,ROUND(SUM(CASE
                     WHEN A.PD_TP_CD IN ( '1' , '2' ) AND A.CTL_IND = '2' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 非保本理财保有量
        ,ROUND(SUM(CASE
                     WHEN A.TRX_MTH_CD = '2' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 封闭式理财保有量
        ,ROUND(SUM(CASE
                     WHEN A.TRX_MTH_CD = '0' THEN A.FNC_BAL * A.ACS_RTO
                     ELSE 0
                   END), 2)                   AS 开放式理财保有量
        ,ROUND(SUM(A.FNC_BAL * A.ACS_RTO), 2) AS 理财产品余额
FROM    TMP_DATA_HCL_024618_20210707_202101_02 A
WHERE   A.PD_TP_CD = '1' --理财
GROUP BY A.dep_cst_mngr_id;



--销售管护关系-理财余额
INSERT OVERWRITE TABLE TMP_DATA_HCL_024618_20210707_202101_04
SELECT  COALESCE(B.MGR_ID, '')
        ,ROUND(SUM(CASE
                     WHEN C.PD_CTG_CD IN ( '1' , '2' ) AND SUBSTR(C.CTRL_IND, 53, 1) = '2' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 非保本理财保有量
        ,ROUND(SUM(CASE
                     WHEN C.TRX_MTH_CD = '2' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 封闭式理财保有量
        ,ROUND(SUM(CASE
                     WHEN C.TRX_MTH_CD = '0' THEN A.CUR_LOT * C.PD_NAV
                     ELSE 0
                   END), 2)                  AS 开放式理财保有量
        ,ROUND(SUM(A.CUR_LOT * C.PD_NAV), 2) AS 理财产品余额
FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A --理财账户份额汇总信息
LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
ON      A.CHM_CST_ID = B.CHM_CST_ID
AND     A.TA_CD = B.TA_CD
AND     B.DT = '20210630'
INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C --SOR.FNC_PD
ON      A.PD_CD = C.PD_CD
AND     C.DT = '20210630'
WHERE   A.DT = '20210630'
AND     C.pd_ctg_cd = '1' --理财
GROUP BY COALESCE(B.MGR_ID, '')
;

DROP TABLE IF EXISTS DATA_HCL_024618_20210707_202103;
CREATE TABLE IF NOT EXISTS DATA_HCL_024618_20210707_202103 AS
SELECT  A . *
        ,B.DEP_FBB_FNC_BAL  AS 管户关系_非保本理财保有量
        ,B.DEP_FBS_FNC_BAL  AS 管户关系_封闭式理财保有量
        ,B.DEP_KFS_FNC_BAL  AS 管户关系_开放式理财保有量
        ,B.DEP_FNC_BAL      AS 管户关系_理财产品余额
        ,B1.DEP_FNC_BAL_AVG AS 管户关系_理财产品月日均
        ,C.FNC_FBB_FNC_BAL  AS 销售关系_非保本理财保有量
        ,C.FNC_FBS_FNC_BAL  AS 销售关系_封闭式理财保有量
        ,C.FNC_KFS_FNC_BAL  AS 销售关系_开放式理财保有量
        ,C.FNC_FNC_BAL      AS 销售关系_理财产品余额
        ,C1.FNC_BAL_AVG     AS 销售关系_理财产品月日均
--FROM    TMP_DATA_HCL_024618_20210707_01 A
from (
  select p2.empe_id --as 员工号
      ,p2.empe_nm as 员工姓名
      --,p1.lgp_id as 法人编号
      ,p1.pos_nm as 职位名称
      ,p2.org_id as 机构编号
      ,p3.brc_org_nm as 分行层级机构名称
      ,p3.sbr_org_nm as 支行层级机构名称
      ,p2.lbr_tp_sts as 用工状态代码
from edw.dim_hr_org_job_inf_dd p1
left join edw.dws_hr_empe_inf_dd p2
on p1.pos_id = p2.pos_enc
and p1.dt = '20210701'
left join edw.dim_hr_org_mng_org_tree_dd p3
on p3.org_id = p2.org_id
and p3.dt = '20210701'
--left join edw.dim_hr_org_bas_inf_dd p3
--on p3.org_id = p2.org_id
--and p3.dt = '20210701'
where p2.dt = '20210701'
and p1.pos_nm = '服务经理'
) A
LEFT JOIN    TMP_DATA_HCL_024618_20210707_202101_03 B
ON      B.MNG_ID = A.EMPE_ID
--考核-月日均
LEFT JOIN    (
                 SELECT  COALESCE(A.mgr_id, '')                             AS MNG_ID
                         ,ROUND(sum(a.mon_acm_lot_acml * C.pd_nav) / 31, 2) AS DEP_FNC_BAL_AVG
                 FROM    edw.DWS_BUS_CHM_ACT_MGR_INF_DD A
                 INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C
                 ON      A.PD_CD = C.PD_CD
                 AND     C.DT = '20210630'
                 WHERE   a.dt = '20210630'
                 AND     c.pd_ctg_cd = '1'
                 GROUP BY COALESCE(A.mgr_id, '')
             ) B1
ON      B1.MNG_ID = A.EMPE_ID
LEFT JOIN    TMP_DATA_HCL_024618_20210707_202101_04 C
ON      C.MNG_ID = A.EMPE_ID
--销售-月日均
LEFT JOIN    (
                 SELECT  COALESCE(B.mgr_id, '')                             AS MNG_ID
                         ,ROUND(sum(a.mon_acm_lot_acml * C.pd_nav) / 31, 2) AS FNC_BAL_AVG
                 FROM    edw.DWS_BUS_CHM_ACT_ACM_INF_DD A
                 LEFT JOIN    edw.DIM_BUS_CHM_ACT_INF_DD B --理财账户信息 获取账户的客户经理
                 ON      A.CHM_CST_ID = B.CHM_CST_ID
                 AND     A.TA_CD = B.TA_CD
                 AND     B.DT = '20210630'
                 INNER JOIN    edw.DIM_BUS_CHM_PD_INF_DD C
                 ON      A.PD_CD = C.PD_CD
                 AND     C.DT = '20210630'
                 WHERE   a.dt = '20210630'
                 AND     c.pd_ctg_cd = '1'
                 GROUP BY COALESCE(B.mgr_id, '')
             ) C1
ON      C1.MNG_ID = A.EMPE_ID;

------------------------------------------------------





--最终结果
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS DATA_HCL_024618_20210707;

CREATE TABLE IF NOT EXISTS DATA_HCL_024618_20210707 AS
SELECT  A . *
        ,B.管户关系_理财产品余额  AS 管户关系_理财产品余额_4月
        ,C.管户关系_理财产品余额  AS 管户关系_理财产品余额_5月
        ,D.管户关系_理财产品余额  AS 管户关系_理财产品余额_6月
        ,B.管户关系_理财产品月日均 AS 管户关系_理财产品月日均_4月
        ,C.管户关系_理财产品月日均 AS 管户关系_理财产品月日均_5月
        ,D.管户关系_理财产品月日均 AS 管户关系_理财产品月日均_6月
        ,B.销售关系_理财产品余额  AS 销售关系_理财产品余额_4月
        ,C.销售关系_理财产品余额  AS 销售关系_理财产品余额_5月
        ,D.销售关系_理财产品余额  AS 销售关系_理财产品余额_6月
        ,B.销售关系_理财产品月日均 AS 销售关系_理财产品月日均_4月
        ,C.销售关系_理财产品月日均 AS 销售关系_理财产品月日均_5月
        ,D.销售关系_理财产品月日均 AS 销售关系_理财产品月日均_6月
--FROM    TMP_DATA_HCL_024618_20210707_01 A
from (
  select p2.empe_id --as 员工号
      ,p2.empe_nm as 员工姓名
      --,p1.lgp_id as 法人编号
      ,p1.pos_nm as 职位名称
      ,p2.org_id as 机构编号
      ,p3.brc_org_nm as 分行层级机构名称
      ,p3.sbr_org_nm as 支行层级机构名称
      ,p2.lbr_tp_sts as 用工状态代码
from edw.dim_hr_org_job_inf_dd p1
left join edw.dws_hr_empe_inf_dd p2
on p1.pos_id = p2.pos_enc
and p1.dt = '20210701'
left join edw.dim_hr_org_mng_org_tree_dd p3
on p3.org_id = p2.org_id
and p3.dt = '20210701'
--left join edw.dim_hr_org_bas_inf_dd p3
--on p3.org_id = p2.org_id
--and p3.dt = '20210701'
where p2.dt = '20210701'
and p1.pos_nm = '服务经理'
) A
LEFT JOIN    DATA_HCL_024618_20210707_202101 B
ON      B.EMPE_ID = A.EMPE_ID
LEFT JOIN    DATA_HCL_024618_20210707_202102 C
ON      C.EMPE_ID = A.EMPE_ID
LEFT JOIN    DATA_HCL_024618_20210707_202103 D
ON      D.EMPE_ID = A.EMPE_ID
;

select *
from DATA_HCL_024618_20210707
;
**数据需求_金华分行人行数据监管.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-07-05 14:06:55
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************

需求字段：日期、网点名称、账号、姓名、身份证号、公安机关采取措施时间
数据层级：支行

select workdate as 平台日期
      ,qqdbs as 请求单标志
      ,zzlxdm as 证件类型代码
      --,zzhm as 证件号码
      ,zh as 账卡号
from edw.afas_afa_tfq_taskserialno  --查控任务流水表
where dt = '20210704'





select *
from app_rpt.INTER_ENQUIRY_REG  -- 查冻扣信息簿
where dt = '20210704'
and organ_type = '05'

select *
from edw.outd_ga_personscreen_main
where dt = '20210704'

select lgp_id as 法人代码
      ,qry_srl_nbr as 公安查询流水号
      ,qry_tm as 查询时间
      ,cst_id as 客户号
      ,qry_chnl as 查询渠道
      ,qry_org as 查询机构
      ,qry_usr as 查询用户
      --,doc_nbr as 被查询人证件号码
      --,cst_nm as 被查询人姓名
      ,val as 分值
      ,qry_rsl_dscr as 查询结果描述
from edw.dwd_cst_out_ps_qry_inf_dd
where dt = '20210704'


select ente_type
      ,qry_date
      ,dt
from app_rpt.inter_point_asset_resp  --点对点资产查询请求
where dt >= '20210624'


select lgp_id as 法人编号
      ,ddct_id as 扣划编号
      ,dep_act_id as 存款账号
      ,ddct_mth_cd as 扣划方式代码
      ,frz_id as 冻结编号
      ,cst_act_id as 客户账号
      ,ddct_amt as 扣划金额
      ,tlr_srl_nbr as 柜员流水号
      ,trx_org_id as 交易机构编号
      ,trx_dt as 交易日期
      --,ddct_dept_nm as 扣划部门名称
      ,ddct_doc_id as 扣划文书号
from edw.dwd_bus_dep_ddct_inf_dd
where dt = '20210704'
**资源_滚动率学习.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-25 17:23:58
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*样本分析*/
-- 2019年开始申请的随贷通全量样本
SELECT COUNT(*), COUNT(DISTINCT(BUSI_CTR_ID)) FROM SC_20210930_SDT_CSR_SAMPLE3;

-- 2019年开始申请的随贷通全量样本剔除没有用信的
SELECT COUNT(*), COUNT(DISTINCT(BUSI_CTR_ID)) FROM SC_20210930_SDT_CSR_SAMPLE3 WHERE USED_DT IS NOT NULL;

-- 2019年开始申请的随贷通全量样本剔除没有用信的、没有还款行为的
SELECT COUNT(*), COUNT(DISTINCT(BUSI_CTR_ID)) FROM SC_20210930_SDT_CSR_SAMPLE3 WHERE USED_DT IS NOT NULL AND 是否有还款行为=1;

-- 2019年开始申请的随贷通全量样本剔除没有用信的、没有还款行为的、被重组合同
SELECT COUNT(*), COUNT(DISTINCT(BUSI_CTR_ID)) FROM SC_20210930_SDT_CSR_SAMPLE3 WHERE USED_DT IS NOT NULL AND 是否有还款行为=1 AND 是否是被重组合同=0;

-- 2019年开始申请的随贷通全量样本剔除没有用信的、没有还款行为的、被重组合同、重组合同
SELECT COUNT(*), COUNT(DISTINCT(BUSI_CTR_ID)) FROM SC_20210930_SDT_CSR_SAMPLE3 WHERE USED_DT IS NOT NULL AND 是否有还款行为=1 AND 是否是被重组合同=0 AND 是否是重组合同=0;

SELECT * FROM SC_20210930_SDT_CSR_SAMPLE4 LIMIT 10;

-- 客群
SELECT CSR_TYPE, COUNT(DISTINCT(CST_ID)) FROM SC_20210930_SDT_CSR_SAMPLE4 GROUP BY CSR_TYPE;

--客群&amp;是否续贷
SELECT CSR_TYPE, 是否续贷, COUNT(DISTINCT(BUSI_CTR_ID)) FROM SC_20210930_SDT_CSR_SAMPLE4 GROUP BY CSR_TYPE, 是否续贷;



--==============================================0000000000000000000==============================================
-- 2019年申请随贷通的工薪户的经营性贷款占比
SELECT COUNT(aa.cst_id) AS 工薪客户数
      ,SUM(CASE THEN aa.是否有他行经营性贷款=1 AND aa.是否有我行经营性贷款=1 THEN 1 ELSE 0 END) 同时有两个经营性贷款的工薪客户数
      ,SUM(CASE THEN aa.是否有他行经营性贷款=1 AND aa.是否有我行经营性贷款=0 THEN 1 ELSE 0 END) 只有他行经营性贷款的工薪客户数
      ,SUM(CASE THEN aa.是否有他行经营性贷款=0 AND aa.是否有我行经营性贷款=1 THEN 1 ELSE 0 END) 只有我行经营性贷款的工薪客户数
      ,SUM(CASE THEN aa.是否有他行经营性贷款=0 AND aa.是否有我行经营性贷款=0 THEN 1 ELSE 0 END) 无经营性贷款的客户数
FROM
(
  SELECT cst_id
        ,CASE WHEN SUM(a.是否是他行经营性贷款)>0 THEN 1 ELSE 0 END AS 是否有他行经营性贷款
        ,CASE WHEN SUM(a.是否是我行经营性贷款)>0 THEN 1 ELSE 0 END AS 是否有我行经营性贷款
  FROM
  (
    SELECT a.cst_id
          ,b.pd_cd
          ,CASE WHEN c.othe_bank_cred_max_amt >0 THEN 1 ELSE 0 END AS 是否是他行经营性贷款
          ,CASE WHEN b.pd_cd LIKE '2010501020%' THEN 1 ELSE 0 END AS 是否是我行经营性贷款
    FROM LAB_BIGDATA_DEV.sc_20210930_sdt_csr_sample4 a   -- 是增量表还是全量表
    LEFT JOIN edw.dim_bus_loan_ctr_inf_dd b ON a.cst_id = b.cst_id AND b.dt = '20210930'
    LEFT JOIN edw.dws_cst_ccrc_idv_ind_inf_di c ON a.cst_id = c.cst_id AND a.report_no = c.report_no AND c.dt >= '20180101' AND c.dt <= '20210930'
    WHERE a.csr_type = 2    --码值是什么意思 工薪户
  ) a
  GROUP BY a.cst_id
) aa
--===============================================00000000000000000000000000=============================================




-- 2019年申请随贷通的工薪户的经营性贷款占比
select
count(*) as 工薪客户数,
sum(case when a.是否有他行经营性贷款=0 and a.是否有我行经营性贷款=1 then 1 else 0 end) as 仅我行经营性贷款的工薪客户数,
sum(case when a.是否有他行经营性贷款=1 and a.是否有我行经营性贷款=0 then 1 else 0 end) as 仅他行经营性贷款的工薪客户数,
sum(case when a.是否有他行经营性贷款=1 and a.是否有我行经营性贷款=1 then 1 else 0 end) as 同时有两行经营性贷款的工薪客户数,
sum(case when a.是否有他行经营性贷款=0 and a.是否有我行经营性贷款=0 then 1 else 0 end) as 无经营性贷款的工薪客户数
from
  (select
  t.cst_id,
  case when sum(t.是否是他行经营性贷款)>0 then 1 else 0 end 是否有他行经营性贷款,
  case when sum(t.是否是我行经营性贷款)>0 then 1 else 0 end 是否有我行经营性贷款
  from
    (
        select
        t1.cst_id,
        case when t3.o_bank_jyx_loan_max_amt>0                         --他行经营性贷款最高额度
            then 1
            else 0
        end 是否是他行经营性贷款,
        t2.pd_cd,                                                      --产品代码
        case when t2.pd_cd like '2010501020%'
            then 1
            else 0
        end 是否是我行经营性贷款
    from
    lab_bigdata_dev.SC_20210930_SDT_CSR_SAMPLE4 t1
    left join edw.dim_bus_loan_ctr_inf_dd t2                           --信贷合同信息
    on t1.cst_id=t2.cst_id AND t2.dt='20210930'
    left join edw.dws_cst_ccrc_idv_ind_inf_di t3                       --个人征信指标信息表
    on t1.cst_id = t3.cst_id and t1.report_no=t3.report_no and t3.dt>20180101 and t3.dt<=20210930     --报告编号
    where t1.csr_type=2
    ) t
  group by t.cst_id
  )a;

-- 是否续贷
SELECT
T1.是否续贷,
COUNT(DISTINCT(T1.BUSI_CTR_ID))
FROM
LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4 T1
GROUP BY T1.是否续贷;


-- 是否续贷&amp;逾期30+                                      T1与T2的最大逾期天数有什么区别
SELECT
T1.是否续贷,
SUM(CASE WHEN T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T1.MX_OVD_DAYS <=30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY <=30 THEN 1 ELSE 0 END )
FROM
LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4 T1
left join
(select bus_ctr_id, max(max_ovd_day) as mx_ovd_day from edw.dim_bus_loan_dbil_inf_dd where dt='20210930' group by bus_ctr_id)t2
on t1.busi_ctr_id=t2.bus_ctr_id
GROUP BY T1.是否续贷;

--是否续贷&amp;还款方式
SELECT
是否续贷,
还款方式,
COUNT(DISTINCT(BUSI_CTR_ID))
FROM
LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4
GROUP BY
是否续贷,
还款方式
ORDER BY
是否续贷,
还款方式
;


-- 不同类型的续贷标记
--DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20210930_SDT_SAMPLE4_TMP;

--CREATE TABLE LAB_BIGDATA_DEV.SC_20210930_SDT_SAMPLE4_TMP AS
SELECT  T1 . *
        ,T2.借据结清日期      AS 上一笔合同的借据结清日期
        ,T2.APNT_MTU_DT AS 上一笔合同到期日期
        ,T2.END_DT      AS 上一笔合同结清日期
        ,T2.USED_DT     AS 上一笔合同首次用信时间
        ,CASE
           WHEN T2.USED_DT IS NOT NULL AND T2.END_DT LIKE '1899%'                           THEN 1   -- 1899是什么  未结清
           WHEN T2.USED_DT IS NOT NULL AND T2.END_DT NOT LIKE '1899%' AND T2.借据结清日期 NOT LIKE '9999%' AND T2.借据结清日期 <= T1.END_DT THEN 2
           WHEN T2.USED_DT IS NOT NULL AND T2.END_DT NOT LIKE '1899%' AND T2.借据结清日期 NOT LIKE '9999%' AND T2.借据结清日期 > T1.END_DT THEN 3
           WHEN T2.USED_DT IS NOT NULL AND T2.END_DT NOT LIKE '1899%' AND T2.借据结清日期 LIKE '9999%' THEN 4
           ELSE 5
         END            AS TAG
FROM    LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4 T1
LEFT JOIN    LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4 T2
ON      T1.CST_ID = T2.CST_ID
AND     T1.RANK1 = T2.RANK1 + 1

-- BC2019091700001497
SELECT  是否续贷
        ,COUNT(*)
        ,SUM(CASE
               WHEN TAG = 1 THEN 1
               ELSE 0
             END) AS TAG1
        ,SUM(CASE
               WHEN TAG = 2 THEN 1
               ELSE 0
             END) AS TAG2
        ,SUM(CASE
               WHEN TAG = 3 THEN 1
               ELSE 0
             END) AS TAG3
        ,SUM(CASE
               WHEN TAG = 4 THEN 1
               ELSE 0
             END) AS TAG4
        ,SUM(CASE
               WHEN TAG = 5 AND RANK1 > 1 THEN 1
               ELSE 0
             END) AS TAG5
        ,SUM(CASE
               WHEN TAG = 5 AND RANK1 = 1 THEN 1
               ELSE 0
             END) AS TAG6
FROM    LAB_BIGDATA_DEV.SC_20210930_SDT_SAMPLE4_TMP
GROUP BY 是否续贷;

-- 是否续贷&amp;逾期30+(20190101-20201231)
SELECT
T1.是否续贷,
SUM(CASE WHEN T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T1.MX_OVD_DAYS <=30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY <=30 THEN 1 ELSE 0 END )
FROM
LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4 T1
left join
(select bus_ctr_id, max(max_ovd_day) as mx_ovd_day from edw.dim_bus_loan_dbil_inf_dd where dt='20210930' group by bus_ctr_id)t2
on t1.busi_ctr_id=t2.bus_ctr_id
WHERE T1.apply_dt>='20190101' AND T1.apply_dt<='20201231'
GROUP BY T1.是否续贷;
**资源_随贷通学习.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 卫少洁
-- 创建日期: 2021-10-28 08:59:42
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*重组、续贷代码梳理*/
select
*
from edw.loan_apply_relative
where objecttype in ('CZ', 'CZ_BD', 'CZ_Card') and dt='20210930';


select
serialno,
relativeserialno,
artificialno,
businessflag
from EDW.LOAN_BUSINESS_CONTRACT
where dt='20210930';

select * from edw.dwd_code_library_dd where dt='20210930' and fld_nm='BUSINESSFLAG';


-- 同一客户上一笔合同还没结清就发生下一笔合同的共有2630条
select count(*) from lab_bigdata_dev.zyj01_sdt_csr_sample_2 where 上一期日期 like '1899%';

-- 没有结清的合同共有423328笔
select count(busi_ctr_id) from lab_bigdata_dev.zyj01_sdt_csr_sample_2 where 结清日期 like '1899%';

-- 上一笔还没结清就发生下一笔合同的所有记录
select * from lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_3 where 上一期日期 like '1899%' and mx_ovd_days is null order by cst_id;

--
select * from lab_bigdata_dev.zyj01_sdt_csr_sample_2 where cst_id='1000016958' order by 申请日期;

-- 客户'1029113522'的合同'BC2018013000000852'下有121笔借据，从第112笔借据开始就没有结清，然后有了新的合同
-- 新合同与上一笔合同相比，期限从1年变为6个月，利率也增加了
-- 两笔合同都有未结清的借据，未结清的原因可能与离约定到期日还比较远有关，
select * from lab_bigdata_dev.zyj01_sdt_csr_sample_2 where cst_id='1029113522' order by 申请日期;

select
cst_id,
bus_apl_id,
bus_ctr_id,
pd_cd,
dbil_id,
dtrb_dt,      --发放日期
apnt_mtu_day, --约定到期日
end_dt        --终结日期
from
edw.dws_bus_loan_dbil_inf_dd
where dt='@@{yyyyMMdd}' and cst_id='1029113522' and pd_cd like '2010503%' and bus_ctr_id='BC2020122400002471'
order by dtrb_dt;


-- 客户号'1028816918'下无合同'BC2021081800002033'的相关借据信息（dws_bus_loan_dbil_inf_dd，dim_bus_loan_dbil_inf_dd），这笔合同下面没有发生过借据行为？
select * from lab_bigdata_dev.zyj01_sdt_csr_sample_2 where cst_id='1028816918' order by 申请日期;

select
cst_id,
--bus_apl_id,
bus_ctr_id,
pd_cd,
dbil_id,
dtrb_dt,
apnt_mtu_day,
end_dt
from
edw.dim_bus_loan_dbil_inf_dd
where dt='@@{yyyyMMdd}' and cst_id='1028816918' and pd_cd like '2010503%'
order by dtrb_dt;

-- 在最大逾期天数测算中，无合同'BC2021081800002033'的记录，没有发生借据行为
select * from lab_bigdata_dev.zyj01_sdt_csr_overdue_detail  where bus_ctr_id='BC2021081800002033';
select * from lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_2  where bus_ctr_id='BC2021081800002033';

-- 合同'BC2021081800002033'的到期日查询（无借据）
select
t1.busi_ctr_id,
t1.busi_apl_id,
t2.apl_dt 申请日期,
t2.aprv_mtu_dt 批准到期日期,
t2.hdl_dt 经办日期,
t2.hpn_dt 发生日期,
t2.mtu_dt 到期日期,
t2.reg_dt 登记日期
from
edw.dim_bus_loan_ctr_inf_dd t1
join edw.dwd_bus_loan_apl_inf_dd t2
on t1.busi_apl_id=t2.apl_id and t1.cst_id=t2.cst_id
where t1.dt='@@{yyyyMMdd}' and t2.dt='@@{yyyyMMdd}' and t1.cst_id='1028816918';


-- zyj01_sdt_csr_sample表中有合同号'BC2021081800002033',但用建表的代码重新运行找不到这个代码了
select * from lab_bigdata_dev.zyj01_sdt_csr_sample where busi_ctr_id='BC2021081800002033';

select * from edw.dwd_bus_loan_ctr_mgr_inf_dd where dt='@@{yyyyMMdd}' and busi_ctr_id='BC2021081800002033';

select
       a.cst_id,
       a.busi_ctr_id,
        case when b.apl_id like 'BA%' then substr(b.apl_id,3,8)
               when b.apl_id like '2%' then substr(b.apl_id,1,8)
               else b.hpn_dt end 申请日期,
       a.end_dt 结清日期,
       a.pd_cd,
        c.pd_nm,
        a.ctr_amt 合同金额,
        datediff(to_date(a.apnt_start_dt,'yyyymmdd'),to_date(a.apnt_mtu_dt,'yyyymmdd'),'mm') 期限,
        a.intr_rat 利率,
        a.loan_usg_cd,
        case when a.loan_usg_cd like '01%' then 1
            else 2 end as csr_type
from edw.dim_bus_loan_ctr_inf_dd a
join edw.dwd_bus_loan_apl_inf_dd b on b.apl_id=a.busi_apl_id and b.dt='@@{yyyyMMdd}'
join edw.dim_bus_loan_pd_inf_dd c on a.pd_cd=c.pd_cd and c.dt='@@{yyyyMMdd}'
join edw.dim_bus_loan_ctr_inf_dd d on a.busi_ctr_id=d.busi_ctr_id and d.dt='@@{yyyyMMdd}'
where a.pd_cd like '2010503%'
and a.dt='@@{yyyyMMdd}' and a.busi_ctr_id='BC2021081800002033';



-- 合同'BC2018013000000852'的到期日查询，该笔合同下每笔借据的到期日查询
-- 合同到期日为'20201231'，该合同下最晚到期的那笔借据的到期日为'20211231'，下一笔合同的申请日期为'20201217'，与合同到期日之间间隔-14天，与借据到期日之间间隔-351天
select
t1.busi_ctr_id,
t1.busi_apl_id,
t1.apnt_start_dt 合同约定开始日期,
t1.apnt_mtu_dt 合同约定到期日期,
t1.end_dt 合同终结日期,
t1.inp_dt 合同输入日期,
t1.hdl_dt 合同经办日期,
t1.hpn_dt 合同发生日期,
t2.dbil_id,
t2.apnt_mtu_day 借据约定到期日,
t2.dtrb_dt 借据发放日期,
t2.end_dt 借据终结日期,
t2.exe_mtu_day 借据执行到期日期
from
edw.dim_bus_loan_ctr_inf_dd t1
left join
edw.dim_bus_loan_dbil_inf_dd t2
on t1.busi_ctr_id=t2.bus_ctr_id
where t1.dt='@@{yyyyMMdd}' and t2.dt='@@{yyyyMMdd}' and t1.busi_ctr_id='BC2018013000000852' order by t2.dtrb_dt;

-- 无借据的合同不存在
select
t.*
from
(select
t1.busi_ctr_id,
t1.apnt_start_dt,
t1.apnt_mtu_dt,
t2.dbil_id
from
edw.dim_bus_loan_ctr_inf_dd t1
left join
edw.dim_bus_loan_dbil_inf_dd t2
on t1.busi_ctr_id=t2.bus_ctr_id
where t1.dt='@@{yyyyMMdd}' and t2.dt='@@{yyyyMMdd}')t
where t.dbil_id is null;



/*样本筛选*/
--随贷通样本数据
-- DROP table IF EXISTS lab_bigdata_dev.zyj01_sdt_csr_sample;
-- CREATE TABLE IF NOT EXISTS lab_bigdata_dev.zyj01_sdt_csr_sample
AS
select
       a.cst_id,
       a.busi_ctr_id,
        case when b.apl_id like 'BA%' then substr(b.apl_id,3,8)
               when b.apl_id like '2%' then substr(b.apl_id,1,8)
               else b.hpn_dt end 申请日期,
       a.end_dt 结清日期,
       a.pd_cd,
        c.pd_nm,
        a.ctr_amt 合同金额,
        datediff(to_date(a.apnt_start_dt,'yyyymmdd'),to_date(a.apnt_mtu_dt,'yyyymmdd'),'mm') 期限,
        a.intr_rat 利率,
        a.loan_usg_cd,
        case when a.loan_usg_cd like '01%' then 1
            else 2 end as csr_type
from edw.dim_bus_loan_ctr_inf_dd a
join edw.dwd_bus_loan_apl_inf_dd b on b.apl_id=a.busi_apl_id and b.dt='@@{yyyyMMdd}'
join edw.dim_bus_loan_pd_inf_dd c on a.pd_cd=c.pd_cd and c.dt='@@{yyyyMMdd}'
join edw.dim_bus_loan_ctr_inf_dd d on a.busi_ctr_id=d.busi_ctr_id and d.dt='@@{yyyyMMdd}'
where a.pd_cd like '2010503%'
and a.dt='@@{yyyyMMdd}'
;




--样本标签
/*逾期天数*/   --- 2017年11月前的逾期天数数据在表 tmp_ovd_before20171101_result (数据准确性不足)
-- drop table if exists lab_bigdata_dev.zyj01_sdt_csr_overdue_detail;
-- create table lab_bigdata_dev.zyj01_sdt_csr_overdue_detail as
select bus_ctr_id,
       dbil_id,
    (case when ovd_amt + idle_bal + bad_bal>0  then 1 else 0 end) as prcp_ovd_status,
    (case when ibs_ovd_intr_bal+obs_ovd_intr_bal+prcp_intr_pnty+intr_intr_pnty>0 then 1 else 0 end) as rate_ovd_status,
    (case when wrt_off_amt+wrt_off_intr>0 then 1 else 0 end) as  wrt_off_status,
    (case when ((wrt_off_amt+wrt_off_intr)
                +(ibs_ovd_intr_bal+obs_ovd_intr_bal+prcp_intr_pnty+intr_intr_pnty)
                +(ovd_amt + idle_bal + bad_bal))>0 then 1 else 0 end) as All_ovd_status,
    (case when ovd_amt + idle_bal + bad_bal>0  then ovd_amt + idle_bal + bad_bal else 0 end) as prcp_ovd_amt,
    (case when ibs_ovd_intr_bal+obs_ovd_intr_bal+prcp_intr_pnty+intr_intr_pnty>0 then ovd_amt + idle_bal + bad_bal else 0 end) as rate_ovd_amt,
    (case when wrt_off_amt>0 then wrt_off_amt else 0 end) as wrt_off_amt,
    (case when wrt_off_intr>0 then wrt_off_intr else 0 end) as wrtrate_off_amt,
    dt,
     amt,
     prcp_bal,
     norm_bal,
     ovd_amt,
     idle_bal,
     bad_bal
from edw.dim_bus_loan_dbil_inf_dd a
where a.dt<='20210930'
and exists (select 1 from lab_bigdata_dev.zyj01_sdt_csr_sample b where b.busi_ctr_id=a.bus_ctr_id)
;



--获取每个合同每天的逾期天数
-- drop table if exists lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_1;
-- create table lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_1 as
select
t3.*,
ROW_NUMBER()over(partition by t3.dbil_id,t3.gap_rank order by t3.dt)-1 as ovd_days
from
(
    select t2.*, t2.rank1 - t2.rank2 as gap_rank from
    (
        select
        t1.*,
        row_number() over(partition by t1.dbil_id order by t1.dt) as rank1,
        sum(t1.All_ovd_status) over(partition by t1.dbil_id order by t1.dt) as rank2
        from lab_bigdata_dev.zyj01_sdt_csr_overdue_detail t1
    ) t2
) t3
;

select * from lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_1 limit 10;


--获取合同名下最大逾期天数
-- DROP TABLE IF EXISTS lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_2;


-- CREATE TABLE lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_2 AS
SELECT  t.bus_ctr_id
        ,max(t.ovd_days) AS mx_ovd_days
FROM    zyj01_sdt_csr_overdue_detail_1 t
GROUP BY t.bus_ctr_id
;
--------------------------------------------------------------------------------------------------------------------------------------
/*随贷通样本筛选*/
-- drop table if exists lab_bigdata_dev.sc_sdt_csr_sample;
-- create table if not exists lab_bigdata_dev.sc_sdt_csr_sample
as
select
t1.cst_id,
t1.busi_ctr_id,
case when t2.apl_id like 'BA%' then substr(t2.apl_id,3,8)
               when t2.apl_id like '2%' then substr(t2.apl_id,1,8)
               else t2.hpn_dt end as apply_dt,                        -- 合同申请日期
t5.used_dt,                                                           -- 合同首次用信日期
t1.apnt_mtu_dt,                                                       -- 信贷合同信息表中的合同约定到期日
t1.end_dt,                                                            -- 信贷合同信息表中的合同结清日
t5.借据结清日期,
case when t5.used_dt is not null and t5.借据结清日期<=t1.apnt_mtu_dt and t1.end_dt not like '1899%' then t1.end_dt
     when t5.used_dt is not null and t5.借据结清日期<=t1.apnt_mtu_dt and t1.end_dt like '1899%' then t1.apnt_mtu_dt
     when t5.used_dt is not null and t5.借据结清日期>t1.apnt_mtu_dt and t5.借据结清日期 like '9999%' then t1.apnt_mtu_dt
     when t5.used_dt is not null and t5.借据结清日期>t1.apnt_mtu_dt and t5.借据结清日期 not like '9999%' then t5.借据结清日期
     else t1.apnt_mtu_dt end as settle_dt,                            -- 重新定义的合同结清日期
t1.pd_cd,
t3.pd_nm,
t1.ctr_amt 合同金额,
datediff(to_date(t1.apnt_mtu_dt,'yyyymmdd'),to_date(t1.apnt_start_dt,'yyyymmdd'),'mm') 期限,
t1.intr_rat 利率,
t1.loan_usg_cd,
case when t1.loan_usg_cd like '01%' then 1 else 2 end as csr_type    -- 客户标签
from edw.dim_bus_loan_ctr_inf_dd t1
join edw.dwd_bus_loan_apl_inf_dd t2 on t2.apl_id=t1.busi_apl_id and t2.dt='@@{yyyyMMdd}'
join edw.dim_bus_loan_pd_inf_dd t3 on t1.pd_cd=t3.pd_cd and t3.dt='@@{yyyyMMdd}'
join edw.dim_bus_loan_ctr_inf_dd t4 on t1.busi_ctr_id=t4.busi_ctr_id and t4.dt='@@{yyyyMMdd}'
left join
(
    select
    b.bus_ctr_id,
    min(b.dtrb_dt) as used_dt,     -- 首次用信时间
    max(b.end_dt) as 借据结清日期
    from
    (
        select a.bus_ctr_id,
        a.dtrb_dt,
        case when a.end_dt like '18991231' then '99999999' else a.end_dt end as end_dt      -- 借据结清日期
        from edw.dim_bus_loan_dbil_inf_dd a
        where a.dt ='@@{yyyyMMdd}'
    )b
    group by b.bus_ctr_id
)t5
on t1.busi_ctr_id=t5.bus_ctr_id
where t1.pd_cd like '2010503%'
and t1.dt='@@{yyyyMMdd}'
;



/*首贷、续贷标签*/
-- drop table if exists lab_bigdata_dev.sc_sdt_csr_sample1;
-- create table if not exists lab_bigdata_dev.sc_sdt_csr_sample1 as
select
t1.*,
t2.settle_dt as last_settle_dt,
datediff(to_date(t1.apply_dt, 'yyyymmdd'), to_date(t2.settle_dt, 'yyyymmdd'), 'dd') as 续贷间隔天数,
case when datediff(to_date(t1.apply_dt, 'yyyymmdd'), to_date(t2.settle_dt, 'yyyymmdd'), 'dd')<=60 then 1
    else 0 end as 是否续贷
from
(
    select t.*,
    row_number() over ( partition by t.cst_id order by t.apply_dt ) as rank1
    from
    lab_bigdata_dev.sc_sdt_csr_sample t
)t1
left join
(
    select t.*,
    row_number() over ( partition by t.cst_id order by t.apply_dt ) as rank1
    from
    lab_bigdata_dev.sc_sdt_csr_sample t
)t2
on t1.cst_id=t2.cst_id
and t1.rank1=t2.rank1 + 1;




/*匹配最大逾期天数，打重组标签，匹配征信号*/
-- drop table if exists lab_bigdata_dev.sc_sdt_csr_sample2;
-- create table lab_bigdata_dev.sc_sdt_csr_sample2 as
select
t1.*,
t2.mx_ovd_days,
case when t3.BCZ_BCNO is NOT null then 1 else 0 end 是否被重组,
t4.report_no
from
lab_bigdata_dev.sc_sdt_csr_sample1 t1
-- 最大逾期天数
left join
lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_2 t2
on t1.busi_ctr_id = t2.bus_ctr_id
-- 是否被重组
left join
    (select
    t1.BCZ_BCNO ,
    min(cz_date) cz_date
    from CYF_CZ_TEMP1 t1
    GROUP BY t1.BCZ_BCNO
    )t3
on t1.busi_ctr_id=t3.BCZ_BCNO
-- 征信号
left join
    (select
    t.*
    from
        (select
        a.*,
        b.report_no,
        b.report_dt,
        datediff(to_date(a.apply_dt,'yyyymmdd'), b.report_dt,'dd') as diff_day,
        row_number() over(partition by a.cst_id, a.busi_ctr_id order by b.report_dt desc) as ranknum
        from lab_bigdata_dev.sc_sdt_csr_sample1 a
        left join edw.dws_cst_ccrc_idv_ind_inf_di b
            on a.cst_id = b.cst_id and b.dt>20130630 and b.dt<=20210930           --个人征信指标信息表是增量表，注意dt区间
        where datediff(to_date(a.apply_dt,'yyyymmdd'), b.report_dt, 'dd')>=0
        and datediff(to_date(a.apply_dt,'yyyymmdd'), b.report_dt, 'dd')<=30
        )t       --取申请日前30天内的征信报告
    where t.ranknum=1
    )t4
on t1.cst_id=t4.cst_id and t1.busi_ctr_id=t4.busi_ctr_id
;
--------------------------------------------------------------------------------------------------------------------------------------

select * from lab_bigdata_dev.sc_sdt_csr_sample2 limit 100;


/*19年开始申请的合同统计数据*/
select
count(*) as 总合同数量,
sum(case when report_no is null then 1 else 0 end) as 缺征信报告的合同数量,
sum(是否续贷) as 续贷合同数量,
sum(是否被重组) as 被重组合同数量
from lab_bigdata_dev.sc_sdt_csr_sample2
where apply_dt>='20190101' and used_dt is not null;


select
count(*) as 总合同数量,
sum(case when 客群='经营' and 是否续贷=1 then 1 else 0 end) as 经营续贷客户数,
sum(case when 客群='经营' and 是否续贷=0 then 1 else 0 end) as 经营首贷客户数,
sum(case when 客群='工薪' and 是否续贷=1 then 1 else 0 end) as 工薪续贷客户数,
sum(case when 客群='工薪' and 是否续贷=0 then 1 else 0 end) as 工薪首贷客户数,
sum(是否续贷) as 续贷合同数量
from CYF_CZ_TEMP_20210926
where 申请日期>='20190101' and 首次用信时间 is not null;



select
sum(case when 是否续贷=1 and report_no is not null and 是否被重组=1 then 1 else 0 end) as sum1,
sum(case when 是否续贷=1 and report_no is not null and 是否被重组=0 then 1 else 0 end) as sum2,
sum(case when 是否续贷=1 and report_no is null and 是否被重组=1 then 1 else 0 end) as sum3,
sum(case when 是否续贷=1 and report_no is null and 是否被重组=0 then 1 else 0 end) as sum4,
sum(case when 是否续贷=0 and report_no is not null and 是否被重组=1 then 1 else 0 end) as sum5,
sum(case when 是否续贷=0 and report_no is not null and 是否被重组=0 then 1 else 0 end) as sum6,
sum(case when 是否续贷=0 and report_no is null and 是否被重组=1 then 1 else 0 end) as sum7,
sum(case when 是否续贷=0 and report_no is null and 是否被重组=0 then 1 else 0 end) as sum8
from lab_bigdata_dev.sc_sdt_csr_sample2
where apply_dt>='20190101' and used_dt is not null;



/*是否有还款行为标签探索*/
select
t1.cst_id,
t1.busi_ctr_id,
t2.dbil_id,
t3.huankzht,
t3.jiaoyils,
t3.jiaoyisj,
t3.shjshuom
from
lab_bigdata_dev.sc_sdt_csr_sample1 t1
left join
(
    select
    distinct(bus_ctr_id),
    dbil_id
    from
    edw.dim_bus_loan_dbil_inf_dd
    where dt='20210930'
)t2
on t1.busi_ctr_id=t2.bus_ctr_id
left join
edw.core_klnl_dkqgmx t3
on t2.dbil_id=t3.dkjiejuh and t3.dt='20210930'
where t1.cst_id='1017757808';



select cst_id, count(*) from  lab_bigdata_dev.sc_sdt_csr_sample1 group by cst_id order by count(*) desc;






select
count(*),
sum(case when end_dt not like '1899%' and end_dt<=apnt_mtu_dt then 1 else 0 end),
sum(case when end_dt not like '1899%' and end_dt>apnt_mtu_dt then 1 else 0 end)
from
lab_bigdata_dev.sc_20211014_sdt_csr_sample



select
count(*),
sum(case when t1.apnt_mtu_dt=t2.hpn_dt then 1 else 0 end),
sum(case when t1.apnt_mtu_dt>t2.hpn_dt then 1 else 0 end),
sum(case when t1.apnt_mtu_dt<t2.hpn_dt then 1 else 0 end)
from
lab_bigdata_dev.sc_20211014_sdt_csr_sample t1
left join
edw.dim_bus_loan_ctr_inf_dd t2
on t1.busi_ctr_id=t2.busi_ctr_id and t2.dt='20210930';




SELECT
T1.bus_ctr_id,
T1.dbil_id,
T2.jiaoyils,
T2.jiaoyisj,
T2.shjshuom
FROM
edw.dim_bus_loan_dbil_inf_dd T1
LEFT JOIN
edw.core_klnl_dkqgmx T2
ON T1.dbil_id=T2.dkjiejuh
WHERE
 T2.dt='20210930' AND T1.dt='20210930';



SELECT
A.*,
CASE WHEN B.shjshuom IN ('提前还款', '正常还款', '逾期标准还款') THEN 1 ELSE 0 END AS 是否有还款行为
from
lab_bigdata_dev.sc_sdt_csr_sample2 A
LEFT JOIN
(
select
T1.busi_ctr_id,
T2.dbil_id,
T3.shjshuom
from
lab_bigdata_dev.sc_sdt_csr_sample2 T1
left join
edw.dim_bus_loan_dbil_inf_dd T2
ON T1.busi_ctr_id=T2.bus_ctr_id
LEFT JOIN
edw.core_klnl_dkqgmx T3
ON T2.dbil_id=T3.dkjiejuh
WHERE T2.dt='@@{yyyyMMdd}' AND T3.dt='@@{yyyyMMdd}'
)B
ON A.busi_ctr_id=B.busi_ctr_id;







select
csr_type,
是否续贷,
count(*)
from
LAB_BIGDATA_DEV.SC_20211014_SDT_SAMPLE2_TMP
where apply_dt>='20190101' and used_dt is not null
group by csr_type, 是否续贷;






/*还款行为探索*/

--cst_id	busi_ctr_sum
--1600359102	4
--1602909452	4
--1606960151	4
--1017757808	4
--1608740488	3
--1031388053	3
--1044031036	3
--1612456710	3

-- 找出有历史用信的客户
SELECT
CST_ID,
BUSI_CTR_ID,
APPLY_DT,
USED_DT,
SETTLE_DT,
LAST_SETTLE_DT
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE2
WHERE CST_ID='1600359102';


-- 找出有历史借据的合同
-- BC2019010100000143
SELECT
A.BUS_CTR_ID,
CASE WHEN SUM(CASE WHEN B.shjshuom IN ('提前还款', '正常还款', '逾期标准还款') THEN 1 ELSE 0 END ) > 0 THEN 1 ELSE 0 END AS 是否有还款行为
FROM
edw.dim_bus_loan_dbil_inf_dd A
LEFT JOIN
edw.core_klnl_dkqgmx B
ON A.dbil_id=B.dkjiejuh AND B.DT<='@@{yyyyMMdd}' AND B.DT>='20190101'
WHERE A.DT='@@{yyyyMMdd}' AND A.BUS_CTR_ID='BC2019010100000143'
GROUP BY A.BUS_CTR_ID;





/*匹配还款行为*/
-- DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3;

-- CREATE TABLE LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3 AS
SELECT
T1.*,
T2.是否有还款行为
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE2 T1
LEFT JOIN
(
    SELECT
    A.BUS_CTR_ID,
    CASE WHEN SUM(CASE WHEN B.shjshuom IN ('提前还款', '正常还款', '逾期标准还款') THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 是否有还款行为
    FROM
    edw.dim_bus_loan_dbil_inf_dd A
    LEFT JOIN
    edw.core_klnl_dkqgmx B
    ON A.dbil_id=B.dkjiejuh AND B.DT<='@@{yyyyMMdd}' AND B.DT>='20190101'
    WHERE A.DT='@@{yyyyMMdd}'
    GROUP BY A.BUS_CTR_ID
)T2
ON T1.BUSI_CTR_ID=T2.BUS_CTR_ID
WHERE T1.apply_dt>='20190101';






--
SELECT
CSR_TYPE,
是否续贷,
是否有还款行为,
COUNT(*)
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3
WHERE APPLY_DT>='20190101' AND USED_DT IS NOT NULL
GROUP BY
CSR_TYPE,
是否续贷,
是否有还款行为;




SELECT
是否续贷,
是否有还款行为,
COUNT(*)
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3
WHERE APPLY_DT>='20190101' AND USED_DT IS NOT NULL
GROUP BY 是否续贷, 是否有还款行为;



select
csr_type,
count(distinct(cst_id))
from
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3
where used_dt is not null and 是否有还款行为=1 and 是否被重组=0
group by csr_type
;


select
是否续贷,
还款方式,
count(*),
count(distinct(busi_ctr_id))
from
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3
where used_dt is not null and 是否有还款行为=1 and 是否被重组=0
group by 是否续贷
, 还款方式;



/*2019年申请随贷通的工薪户的经营性贷款占比*/
-- DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211015_SDT_GONGXIN_TMP;

-- CREATE TABLE LAB_BIGDATA_DEV.SC_20211015_SDT_GONGXIN_TMP AS
select
    t1.cst_id,
    case when t3.o_bank_jyx_loan_max_amt>0
        then 1
        else 0
        end 是否是他行经营性贷款,
    t2.pd_cd,
    case when t2.pd_cd like '2010501020%'
        then 1
        else 0
        end 是否是我行经营性贷款
    from
    lab_bigdata_dev.SC_20211014_SDT_CSR_SAMPLE3 t1
    left join edw.dim_bus_loan_ctr_inf_dd t2
    on t1.cst_id=t2.cst_id AND t2.dt='20210930'
    left join edw.dws_cst_ccrc_idv_ind_inf_di t3
    on t1.cst_id = t3.cst_id and t1.report_no=t3.report_no and t3.dt>20180101 and t3.dt<=20211018
    where t1.csr_type=2
        and t1.used_dt is not null and t1.是否有还款行为=1 and t1.是否被重组=0


select
count(*) as 工薪客户数,
sum(case when a.是否有他行经营性贷款=0 and a.是否有我行经营性贷款=1 then 1 else 0 end) as 仅我行经营性贷款的工薪客户数,
sum(case when a.是否有他行经营性贷款=1 and a.是否有我行经营性贷款=0 then 1 else 0 end) as 仅他行经营性贷款的工薪客户数,
sum(case when a.是否有他行经营性贷款=1 and a.是否有我行经营性贷款=1 then 1 else 0 end) as 同时有两行经营性贷款的工薪客户数,
sum(case when a.是否有他行经营性贷款=0 and a.是否有我行经营性贷款=0 then 1 else 0 end) as 无经营性贷款的工薪客户数
from
  (select
  t.cst_id,
  case when sum(t.是否是他行经营性贷款)>0 then 1 else 0 end 是否有他行经营性贷款,
  case when sum(t.是否是我行经营性贷款)>0 then 1 else 0 end 是否有我行经营性贷款
  from
    LAB_BIGDATA_DEV.SC_20211015_SDT_GONGXIN_TMP t
    group by t.cst_id
    )a;

/*2019年逾期30+占比*/
SELECT
是否续贷,
SUM(CASE WHEN T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T1.MX_OVD_DAYS <=30 THEN 1 ELSE 0 END )
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3 T1
where t1.used_dt is not null and t1.是否有还款行为=1 and t1.是否被重组=0
GROUP BY T1.是否续贷;


SELECT SUM(CASE WHEN MX_OVD_DAYS >30 THEN 1 ELSE 0 END),COUNT(*) FROM lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_2;

SELECT * FROM lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_3;

SELECT * FROM lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_1 LIMIT 10;

SELECT
T1.是否续贷,
SUM(CASE WHEN T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T1.MX_OVD_DAYS <=30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY <=30 THEN 1 ELSE 0 END )
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3 T1
left join
(select bus_ctr_id, max(max_ovd_day) as mx_ovd_day from edw.dim_bus_loan_dbil_inf_dd where dt='20210930' group by bus_ctr_id)t2
on t1.busi_ctr_id=t2.bus_ctr_id
where t1.used_dt is not null and t1.是否有还款行为=1 and t1.是否被重组=0
AND T1.apply_dt<='20201231'
GROUP BY T1.是否续贷;

SELECT
COUNT(*),
COUNT(DISTINCT(BUSI_CTR_ID))
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3 T1
where t1.used_dt is not null and t1.是否有还款行为=1 and t1.是否被重组=0 AND T1.MX_OVD_DAYS >30;





-- /*roll_rate*/
-- DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211015_SDT_XUDAI_ROLL;

-- CREATE TABLE LAB_BIGDATA_DEV.SC_20211015_SDT_XUDAI_ROLL AS
-- SELECT
-- BUS_CTR_ID,
-- DT,
-- ROW_NUMBER () OVER (PARTITION BY BUS_CTR_ID ORDER BY DT) AS RANK1,
-- CASE WHEN MAX(ovd_days)=0 THEN 'C'
--     WHEN MAX(ovd_days)>0 AND MAX(ovd_days)<=30 THEN 'M1'
--     WHEN MAX(ovd_days)>30 AND MAX(ovd_days)<=60 THEN 'M2'
--     WHEN MAX(ovd_days)>60 AND MAX(ovd_days)<=90 THEN 'M3'
--     WHEN MAX(ovd_days)>90 AND MAX(ovd_days)<=120 THEN 'M4'
--     ELSE 'M4+'
-- END AS STAGE
-- FROM
-- lab_bigdata_dev.zyj01_sdt_csr_overdue_detail_1
-- WHERE BUS_CTR_ID IN
--     (SELECT BUSI_CTR_ID FROM LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3 WHERE USED_DT IS NOT NULL AND 是否续贷=1 AND 是否有还款行为=1) -- 有用信且有还款行为的续贷合同
-- GROUP BY BUS_CTR_ID, DT
-- ;




SELECT
SUM(CASE WHEN T1.apply_dt>='20190101' AND T1.apply_dt<'20190201' THEN 1 ELSE 0 END ) AS SUM_1,
SUM(CASE WHEN T1.apply_dt>='20190101' AND T1.apply_dt<'20190201' AND T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ) AS OVD_1,
SUM(CASE WHEN T1.apply_dt>='20190201' AND T1.apply_dt<'20190301' THEN 1 ELSE 0 END ) AS SUM_1,
SUM(CASE WHEN T1.apply_dt>='20190201' AND T1.apply_dt<'20190301' AND T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ) AS OVD_1,
SUM(CASE WHEN T1.apply_dt>='20190301' AND T1.apply_dt<'20190401' THEN 1 ELSE 0 END ) AS SUM_1,
SUM(CASE WHEN T1.apply_dt>='20190301' AND T1.apply_dt<'20190401' AND T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ) AS OVD_1,
SUM(CASE WHEN T1.apply_dt>='20190101' AND T1.apply_dt<'20190201' THEN 1 ELSE 0 END ) AS SUM_1,
SUM(CASE WHEN T1.apply_dt>='20190101' AND T1.apply_dt<'20190201' AND T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ) AS OVD_1,
SUM(CASE WHEN T1.apply_dt>='20190101' AND T1.apply_dt<'20190201' THEN 1 ELSE 0 END ) AS SUM_1,
SUM(CASE WHEN T1.apply_dt>='20190101' AND T1.apply_dt<'20190201' AND T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ) AS OVD_1,
FROM
LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3 T1
where t1.used_dt is not null and t1.是否有还款行为=1 and t1.是否被重组=0
;


select count(*), count(distinct(busi_ctr_id)) from LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE2 where report_no is null;


DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE;
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE1;
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE2;
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE3;
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20211014_SDT_CSR_SAMPLE4;







-- 是否续贷
SELECT
T1.是否续贷,
COUNT(DISTINCT(T1.BUSI_CTR_ID))
FROM
LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4 T1
GROUP BY T1.是否续贷;


-- 是否续贷&amp;逾期30+
SELECT
T1.是否续贷,
SUM(CASE WHEN T1.MX_OVD_DAYS >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T1.MX_OVD_DAYS <=30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY >30 THEN 1 ELSE 0 END ),
SUM(CASE WHEN T2.MX_OVD_DAY <=30 THEN 1 ELSE 0 END )
FROM
LAB_BIGDATA_DEV.SC_20210930_SDT_CSR_SAMPLE4 T1
left join
(select bus_ctr_id, max(max_ovd_day) as mx_ovd_day from edw.dim_bus_loan_dbil_inf_dd where dt='20210930' group by bus_ctr_id)t2
on t1.busi_ctr_id=t2.bus_ctr_id
GROUP BY T1.是否续贷;





/*续贷季度_vintage*/
-- DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20210930_SDT_SAMPLE4_XUDAI_VINTAGE_QUARTER;

-- CREATE TABLE LAB_BIGDATA_DEV.SC_20210930_SDT_SAMPLE4_XUDAI_VINTAGE_QUARTER AS
SELECT
T2.*,
ROW_NUMBER() OVER(PARTITION BY T2.BUSI_CTR_ID ORDER BY QUARTER_VIEW_DT) - 1 AS QOB
FROM
(
    SELECT
    T1.*,
    MIN(T1.YEAR_QUARTER) OVER(PARTITION BY T1.BUSI_CTR_ID) AS LOAN_QUARTER,             -- 合同的放款季度
    MAX(T1.VIEW_DT) OVER(PARTITION BY T1.BUSI_CTR_ID, YEAR_QUARTER) AS QUARTER_VIEW_DT   -- 改观察日期为每季度最后一天
    FROM
    (
        SELECT
        A.*,
        CASE WHEN YEAR_MONTH IN ('2019-01', '2019-02', '2019-03') THEN '19-1'
            WHEN YEAR_MONTH IN ('2019-04', '2019-05', '2019-06') THEN '19-2'
            WHEN YEAR_MONTH IN ('2019-07', '2019-08', '2019-09') THEN '19-3'
            WHEN YEAR_MONTH IN ('2019-10', '2019-11', '2019-12') THEN '19-4'
            WHEN YEAR_MONTH IN ('2020-01', '2020-02', '2020-03') THEN '20-1'
            WHEN YEAR_MONTH IN ('2020-04', '2020-05', '2020-06') THEN '20-2'
            WHEN YEAR_MONTH IN ('2020-07', '2020-08', '2020-09') THEN '20-3'
            WHEN YEAR_MONTH IN ('2020-10', '2020-11', '2020-12') THEN '20-4'
            WHEN YEAR_MONTH IN ('2021-01', '2021-02', '2021-03') THEN '21-1'
            WHEN YEAR_MONTH IN ('2021-04', '2021-05', '2021-06') THEN '21-2'
            WHEN YEAR_MONTH IN ('2021-07', '2021-08', '2021-09') THEN '21-3'
        ELSE 'ERROR'
        END AS YEAR_QUARTER,
        MAX(A.OVD_DAYS) OVER(PARTITION BY A.BUSI_CTR_ID ORDER BY A.DT) AS MAX_OVD_DAYS  -- 每个合同至当天为止的最大逾期天数
        FROM
        LAB_BIGDATA_DEV.SC_20210930_SDT_SAMPLE4_VINTAGE A
        WHERE A.是否续贷=1
    )T1
)T2
WHERE T2.DT = T2.QUARTER_VIEW_DT
;

SELECT * FROM SC_20210930_SDT_SAMPLE4_XUDAI_VINTAGE_QUARTER LIMIT 10;



SELECT
T.LOAN_QUARTER,
T.QOB,
SUM(FLAG),
COUNT(DISTINCT(T.BUSI_CTR_ID))
FROM
(
    SELECT
    T1.*
    ,CASE
        WHEN T1.MAX_OVD_DAYS > 30 THEN 1
        ELSE 0
    END FLAG
    FROM
    LAB_BIGDATA_DEV.SC_20210930_SDT_SAMPLE4_XUDAI_VINTAGE_QUARTER T1
)T
GROUP BY
T.LOAN_QUARTER,
T.QOB;


/*借据期限end_dt-hpn_dt*/
-- DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SC_20210930_BS_DBIL_DATE_TMP1;

-- CREATE TABLE LAB_BIGDATA_DEV.SC_20210930_BS_DBIL_DATE_TMP1 AS
SELECT
T1.BUSI_CTR_ID,
T1.HPN_DT AS BC_HPN_DT,
T1.END_DT AS BC_END_DT,
T1.APNT_START_DT AS BC_START_DT,
T1.APNT_MTU_DT AS BC_MTU_DT,
DATEDIFF(TO_DATE(T1.END_DT, 'yyyymmdd'), TO_DATE(T1.HPN_DT, 'yyyymmdd'), 'MM') AS BC_DIFF1,              -- 合同结清日期-开始日期
DATEDIFF(TO_DATE(T1.APNT_MTU_DT, 'yyyymmdd'), TO_DATE(T1.APNT_START_DT, 'yyyymmdd'), 'MM') AS BC_DIFF2,  -- 合同约定到期日期-约定开始日期
MIN(T2.DTRB_DT) OVER(PARTITION BY T1.BUSI_CTR_ID) AS BC_USED_DT, -- 合同首次用信日期
MAX(T2.END_DT) OVER(PARTITION BY T1.BUSI_CTR_ID) AS BC_DBIL_END_DT, -- 合同借据结清日期
T2.DBIL_ID,
T2.DTRB_DT AS DBIL_DTRB_DT,
T2.END_DT AS DBIL_END_DT,
T2.APNT_MTU_DAY AS DBIL_MTU_DT,
DATEDIFF(TO_DATE(T2.END_DT, 'yyyymmdd'), TO_DATE(T2.DTRB_DT, 'yyyymmdd'), 'MM') AS DBIL_DIFF1,       -- 借据结清日期-发放日期
DATEDIFF(TO_DATE(T2.APNT_MTU_DAY, 'yyyymmdd'), TO_DATE(T2.DTRB_DT, 'yyyymmdd'), 'MM') AS DBIL_DIFF2  -- 借据约定到期日期-发放日期
FROM
edw.dim_bus_loan_ctr_inf_dd T1
LEFT JOIN
edw.dim_bus_loan_dbil_inf_dd T2
ON T1.BUSI_CTR_ID = T2.BUS_CTR_ID
WHERE T1.DT='20210930' AND T2.DT='20210930'
;


/*期限*/
SELECT * FROM SC_20210930_BS_DBIL_DATE_TMP1 WHERE BC_HPN_DT>='20190101' ORDER BY BUSI_CTR_ID, DBIL_ID ;

SELECT
T.BC_DIFF,
COUNT(*)
FROM
(
SELECT
DISTINCT(T1.BUSI_CTR_ID),
DATEDIFF(TO_DATE(T1.BC_USED_DT, 'yyyymmdd'), TO_DATE(T1.BC_DBIL_END_DT, 'yyyymmdd'), 'MM') AS BC_DIFF
FROM
SC_20210930_BS_DBIL_DATE_TMP1 T1
WHERE T1.BUSI_CTR_ID IN (SELECT BUSI_CTR_ID FROM SC_20210930_SDT_CSR_SAMPLE4)
)T
GROUP BY
T.BC_DIFF;



SELECT
A.APPLY_MONTH,
AVG(A.DIFF_MON),
MAX(A.DIFF_MON),
MIN(A.DIFF_MON)
FROM
(
SELECT
T.*,
DATEDIFF(TO_DATE(T.SETTLE_DT, 'yyyymmdd'), TO_DATE(T.APPLY_DT, 'yyyymmdd'), 'MM') AS DIFF_MON
FROM
    (
    SELECT
    T1.BUSI_CTR_ID,
    T1.APPLY_DT,
    TO_CHAR(TO_DATE(T1.APPLY_DT,'yyyymmdd'),'yyyy-mm') APPLY_MONTH,
    T2.BC_END_DT AS SETTLE_DT
    FROM
    SC_20210930_SDT_CSR_SAMPLE4 T1
    LEFT JOIN
    SC_20210930_BS_DBIL_DATE_TMP1 T2
    ON T1.BUSI_CTR_ID = T2.BUSI_CTR_ID
    )T
)A
GROUP BY A.APPLY_MONTH;