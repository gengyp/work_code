**SJ2023102346-code.sql
-- 截止11.15日
-- 客户号	账户名称	分行	支行	管户客户经理	是否开卡（储蓄卡） 是否签约理财
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_01 AS
SELECT  T1.CST_ID					 	--客户号
	,T1.CST_NM                        	--账户名称
	,T3.BRC_ORG_NM                   	--分行
	,T1.MNG_ORG_NM,T3.SBR_ORG_NM      	--支行
	,T1.MNG_EMP_NM,T2.PRM_MGR_NM      	--管户客户经理
	,CASE WHEN T4.CST_ID IS NOT NULL
	THEN '是' ELSE '否' END IS_OPN_CRD	--是否开卡（储蓄卡）
	,T5.CHM_CTR_CST						--是否理财签约
	,CASE WHEN T7.DOC_NBR IS NOT NULL THEN '是' ELSE '否' END IS_OUR_BANK
FROM LAB_BIGDATA_DEV.QBI_XIAOYU_BANK_CST 			T1	--客群 quickBI导入
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T2 	--客户主管户信息
ON      T1.CST_ID = T2.CST_ID
AND     T2.DT = '20231115'
LEFT JOIN  EDW.DIM_HR_ORG_MNG_ORG_TREE_DD 			T3
ON      T2.PRM_ORG_ID=T3.ORG_ID
AND     T3.DT = '20231115'
LEFT JOIN (
	SELECT DISTINCT CST_ID
	FROM EDW.DIM_BUS_DEP_ACT_INF_DD	--存款账户信息 是否开卡
	WHERE DT='20231115'
)T4 ON T1.CST_ID=T4.CST_ID
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		T5	--正式客户财富业务信息表
ON 		T1.CST_ID=T5.CST_ID
AND 	T5.DT='20231115'
LEFT JOIN ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD		T6 	--客户信息表
ON 		T1.CST_ID=T6.CST_ID
AND 	T6.DT = '20231115'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD 					T7
ON 		T6.DOC_NBR = T7.DOC_NBR
AND 	T7.DT = '20231115'
AND 	T7.EMPE_STS_CD='2'					-- 员工状态正常1:未入职2:在职3:离职4:退休5:劳务派遣
WHERE 	T1.PT=MAX_PT('qbi_xiaoyu_bank_cst')
;


-- 财富资产较9月底增加金额	理财余额较9月底增加金额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_02 AS
SELECT T1.CST_ID
	,COALESCE(T2.WLTH_BAL,0) - COALESCE(T3.WLTH_BAL,0)			WLTH_AST_ADD
	,COALESCE(T2.FNC_AMT,0) - COALESCE(T3.FNC_AMT,0)			FNC_AST_ADD
	,CASE WHEN T4.TTB_CUR_AMT>0 THEN '是' ELSE '否' END 		IS_BUY_TTB
	,COALESCE(T4.TTB_CUR_AMT,0) 								TTB_CUR_AMT
	,COALESCE(T4.TTB_CUR_AMT,0) - COALESCE(T5.TTB_CUR_AMT,0) 	TTB_AMT_ADD
	,COALESCE(T6.WHTH_FEE_CUR_YEAR,0) - COALESCE(T7.WHTH_FEE_CUR_YEAR,0) WHTH_FEE_CUR_ADD
FROM LAB_BIGDATA_DEV.QBI_XIAOYU_BANK_CST 				T1
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_FIN_AST_INF_DD 		T2 		--客户金融资产表
ON 		T1.CST_ID=T2.CST_ID
AND 	T2.DT='20231115'
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_FIN_AST_INF_DD 		T3 		--客户金融资产表
ON 		T1.CST_ID=T3.CST_ID
AND 	T3.DT='20230930'
LEFT JOIN (
	-- 天添宝是否购买	天添宝购买金额 天添宝较9月底增加金额
	SELECT 	T1.CST_ID,SUM(T1.FNC_AMT) TTB_CUR_AMT
	FROM 	EDW.DWS_BUS_CHM_ACT_ACM_INF_DD  	T1 	--理财账户份额汇总信息 PD_TP_CD='1' 1理财 0基金 e结构性存款
	INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 		T2	--理财产品信息
	ON 		T1.PD_CD=T2.PD_CD
	AND 	T2.TA_CD='998' 							--天添宝
	AND 	T2.DT='20231115'
	WHERE	T1.DT='20231115'
	AND 	T1.FNC_AMT>0	--当前理财金额
	GROUP BY T1.CST_ID
)T4 ON T1.CST_ID=T4.CST_ID
LEFT JOIN (
	SELECT T1.CST_ID,SUM(T1.FNC_AMT) TTB_CUR_AMT
	FROM 	EDW.DWS_BUS_CHM_ACT_ACM_INF_DD  	T1 	--理财账户份额汇总信息 pd_tp_cd='1' 1理财 0基金 e结构性存款
	INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 		T2	--理财产品信息
	ON 		T1.PD_CD=T2.PD_CD
	AND 	T2.TA_CD='998' 							--天添宝
	AND 	T2.DT='20231115'
	WHERE 	T1.DT='20230930'
	AND 	T1.FNC_AMT>0	--当前理财金额
	GROUP BY T1.CST_ID
)T5 ON T1.CST_ID=T5.CST_ID
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_VAL_DER_IND_INF_DD T6	--客户集市-业务信息-客户价值信息-客户价值衍生指标信息
ON 		T1.CST_ID=T6.CST_ID
AND 	T6.DT='20231115'
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_VAL_DER_IND_INF_DD T7	--客户价值衍生指标信息
ON 		T1.CST_ID=T7.CST_ID
AND 	T7.DT='20230930'
WHERE 	T1.PT=MAX_PT('qbi_xiaoyu_bank_cst')
;


/*
EDW.DWS_BUS_CHM_ACT_ACM_INF_DD  	T1 	--理财账户份额汇总信息
,sum(CASE WHEN pd_cd IN ( '07010011' , '90612011' , '9B310045' , '9B310061'
	, '9B31021G' , '9B31022G' , '9B31023G' , '9B31024G'
	, '9B31025G' ) THEN fnc_amt ELSE '' END) ttb_fnc_amt --天添宝底层9个产品,购入会按照2000元依次分配(20230728口径)
	-- ttb_fnc_amt > 0 THEN '已持有'
*/


-- 结果表
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP AS
SELECT T1.CST_ID			AS		 	客户号
	,T1.CST_NM              AS          账户名称
	,T1.BRC_ORG_NM          AS         	分行
	,T1.SBR_ORG_NM      	AS			支行
	,T1.PRM_MGR_NM      	AS			管户客户经理
	,T1.IS_OPN_CRD			AS			是否开卡
	,case when T1.CHM_CTR_CST='1' then '是' else '否' end as 是否签约理财
	,T2.WLTH_AST_ADD		AS			财富资产较9月底增加金额
	,T2.FNC_AST_ADD			AS			理财余额较9月底增加金额
	,case when T2.IS_BUY_TTB='是' then '是' else '否' end AS 天添宝是否购买
	,T2.TTB_CUR_AMT 		AS 			天添宝购买金额
	,T2.TTB_AMT_ADD			AS 			天添宝较9月底增加金额
	,T1.IS_OUR_BANK			AS 			是否我行员工
	,T2.WHTH_FEE_CUR_ADD	AS 			财富手续费收入较9月底新增
FROM TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_01 		T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_02 	T2
ON T1.CST_ID=T2.CST_ID
;

SELECT COUNT(客户号) CNT,COUNT(DISTINCT 客户号)		--1405
FROM TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP
;



**SJ2023102346-code2.sql
-- 增加字段：财富资产较10月31日增加金额；理财余额较10月31日增加金额；
-- 截止日期：2023年11月20日

-- 截止11.20日
-- 客户号	账户名称	分行	支行	管户客户经理	是否开卡（储蓄卡） 是否签约理财
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_01 AS
SELECT  T1.CST_ID					 	--客户号
	,T1.CST_NM                        	--账户名称
	,T3.BRC_ORG_NM                   	--分行
	,T1.MNG_ORG_NM,T3.SBR_ORG_NM      	--支行
	,T1.MNG_EMP_NM,T2.PRM_MGR_NM      	--管户客户经理
	,CASE WHEN T4.CST_ID IS NOT NULL
	THEN '是' ELSE '否' END IS_OPN_CRD	--是否开卡（储蓄卡）
	,T5.CHM_CTR_CST						--是否理财签约
	,CASE WHEN T7.DOC_NBR IS NOT NULL THEN '是' ELSE '否' END IS_OUR_BANK
FROM LAB_BIGDATA_DEV.QBI_XIAOYU_BANK_CST 			T1	--客群 quickBI导入
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T2 	--客户主管户信息
ON      T1.CST_ID = T2.CST_ID
AND     T2.DT = '20231120'
LEFT JOIN  EDW.DIM_HR_ORG_MNG_ORG_TREE_DD 			T3
ON      T2.PRM_ORG_ID=T3.ORG_ID
AND     T3.DT = '20231120'
LEFT JOIN (
	SELECT DISTINCT CST_ID
	FROM EDW.DIM_BUS_DEP_ACT_INF_DD	--存款账户信息 是否开卡
	WHERE DT='20231120'
)T4 ON T1.CST_ID=T4.CST_ID
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		T5	--正式客户财富业务信息表
ON 		T1.CST_ID=T5.CST_ID
AND 	T5.DT='20231120'
LEFT JOIN ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD		T6 	--客户信息表
ON 		T1.CST_ID=T6.CST_ID
AND 	T6.DT = '20231120'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD 					T7
ON 		T6.DOC_NBR = T7.DOC_NBR
AND 	T7.DT = '20231120'
AND 	T7.EMPE_STS_CD='2'					-- 员工状态正常1:未入职2:在职3:离职4:退休5:劳务派遣
WHERE 	T1.PT=MAX_PT('qbi_xiaoyu_bank_cst')
;


-- 财富资产较9月底增加金额	理财余额较9月底增加金额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_02 AS
SELECT T1.CST_ID
	,COALESCE(T2.WLTH_BAL,0) - COALESCE(T3.WLTH_BAL,0)			WLTH_AST_ADD
	,COALESCE(T2.FNC_AMT,0)  - COALESCE(T3.FNC_AMT,0)			FNC_AST_ADD
	,COALESCE(T2.WLTH_BAL,0) - COALESCE(T8.WLTH_BAL,0)			WLTH_AST_ADD_10
	,COALESCE(T2.FNC_AMT,0)  - COALESCE(T8.FNC_AMT,0)			FNC_AST_ADD_10
	,CASE WHEN T4.TTB_CUR_AMT>0 THEN '是' ELSE '否' END 		IS_BUY_TTB
	,COALESCE(T4.TTB_CUR_AMT,0) 								TTB_CUR_AMT
	,COALESCE(T4.TTB_CUR_AMT,0) - COALESCE(T5.TTB_CUR_AMT,0) 	TTB_AMT_ADD
	,COALESCE(T6.WHTH_FEE_CUR_YEAR,0) - COALESCE(T7.WHTH_FEE_CUR_YEAR,0) WHTH_FEE_CUR_ADD
FROM LAB_BIGDATA_DEV.QBI_XIAOYU_BANK_CST 				T1
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_FIN_AST_INF_DD 		T2 		--客户金融资产表
ON 		T1.CST_ID=T2.CST_ID
AND 	T2.DT='20231120'
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_FIN_AST_INF_DD 		T3 		--客户金融资产表
ON 		T1.CST_ID=T3.CST_ID
AND 	T3.DT='20230930'
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_FIN_AST_INF_DD 		T8 		--客户金融资产表
ON 		T1.CST_ID=T8.CST_ID
AND 	T8.DT='20231031'
LEFT JOIN (
	-- 天添宝是否购买	天添宝购买金额 天添宝较9月底增加金额
	SELECT 	T1.CST_ID,SUM(T1.FNC_AMT) TTB_CUR_AMT
	FROM 	EDW.DWS_BUS_CHM_ACT_ACM_INF_DD  	T1 	--理财账户份额汇总信息 PD_TP_CD='1' 1理财 0基金 e结构性存款
	INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 		T2	--理财产品信息
	ON 		T1.PD_CD=T2.PD_CD
	AND 	T2.TA_CD='998' 							--天添宝
	AND 	T2.DT='20231120'
	WHERE	T1.DT='20231120'
	AND 	T1.FNC_AMT>0	--当前理财金额
	GROUP BY T1.CST_ID
)T4 ON T1.CST_ID=T4.CST_ID
LEFT JOIN (
	SELECT T1.CST_ID,SUM(T1.FNC_AMT) TTB_CUR_AMT
	FROM 	EDW.DWS_BUS_CHM_ACT_ACM_INF_DD  	T1 	--理财账户份额汇总信息 pd_tp_cd='1' 1理财 0基金 e结构性存款
	INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 		T2	--理财产品信息
	ON 		T1.PD_CD=T2.PD_CD
	AND 	T2.TA_CD='998' 							--天添宝
	AND 	T2.DT='20231120'
	WHERE 	T1.DT='20230930'
	AND 	T1.FNC_AMT>0	--当前理财金额
	GROUP BY T1.CST_ID
)T5 ON T1.CST_ID=T5.CST_ID
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_VAL_DER_IND_INF_DD T6	--客户集市-业务信息-客户价值信息-客户价值衍生指标信息
ON 		T1.CST_ID=T6.CST_ID
AND 	T6.DT='20231120'
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_VAL_DER_IND_INF_DD T7	--客户价值衍生指标信息
ON 		T1.CST_ID=T7.CST_ID
AND 	T7.DT='20230930'
WHERE 	T1.PT=MAX_PT('qbi_xiaoyu_bank_cst')
;


-- 结果表
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP AS
SELECT T1.CST_ID			AS		 	客户号
	,T1.CST_NM              AS          账户名称
	,T1.BRC_ORG_NM          AS         	分行
	,T1.SBR_ORG_NM      	AS			支行
	,T1.PRM_MGR_NM      	AS			管户客户经理
	,T1.IS_OPN_CRD			AS			是否开卡
	,CASE WHEN T1.CHM_CTR_CST='1' THEN '是' ELSE '否' END AS 是否签约理财
	,T2.WLTH_AST_ADD		AS			财富资产较9月底增加金额
	,t2.WLTH_AST_ADD_10 	as 			财富资产较10月底增加金额
	,T2.FNC_AST_ADD			AS			理财余额较9月底增加金额
	,T2.FNC_AST_ADD_10		AS			理财余额较10月底增加金额
	,CASE WHEN T2.IS_BUY_TTB='是' THEN '是' ELSE '否' END AS 天添宝是否购买
	,T2.TTB_CUR_AMT 		AS 			天添宝购买金额
	,T2.TTB_AMT_ADD			AS 			天添宝较9月底增加金额
	,T1.IS_OUR_BANK			AS 			是否我行员工
	,T2.WHTH_FEE_CUR_ADD	AS 			财富手续费收入较9月底新增
FROM TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_01 		T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP_02 	T2
ON T1.CST_ID=T2.CST_ID
;

SELECT COUNT(客户号) CNT,COUNT(DISTINCT 客户号)		--1405
FROM TLDATA_DEV.SJXQ_SJ2023102346_CST_ZYP
;



**SJ2023110701_code2.sql
-- odps sql
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 耿延鹏
-- 创建日期: 2023-11-14 14:20:30
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/*
&quot;取数需求：
1.非货基金月日均保有量：细分为债基、股基和全量（三个层面）
2.维度：支行、团队、个人。&quot;

字段：客户号	当前财富管户人姓名	当前财富管户人工号	当前财富管户人所在团队名称	当前财富管户人所在支行名称
&quot;股基月日均保有量（截止日期：9.30）&quot;	:包括股基、fof、qdii、混合型
&quot;债基月日均保有量（截止日期：9.30）&quot;    :&quot;债券型基金（包括短债、不包括同业存单）&quot;
&quot;非货基金月日均保有量（截止日期：9.30）&quot;

&quot;股基月日均保有量（截止日期：10.18）&quot;
&quot;债基月日均保有量（截止日期：10.18）&quot;
&quot;非货基金月日均保有量（截止日期：10.18）&quot;
show partitions edw.dim_bus_chm_fnd_cst_ctr_inf_dd

-- 存单、短债
select  *
from    lab_bigdata_dev.qbi_file_20231115_15_37_15
where   pt = max_pt('qbi_file_20231115_15_37_15')
*/

drop table  if exists tldata_dev.sjxq_sj2023110701_cst_zyp_01;
create  table if not exists tldata_dev.sjxq_sj2023110701_cst_zyp_01 as
select t.cst_id
    ,t2.empe_nm
    ,t.wlth_mng_mnl_id
    ,t.wlth_mng_org_id
    ,t3.tem_org_nm
	,t3.sbr_org_nm
    ,t3.brc_org_nm
from edw.dim_bus_chm_fnd_cst_ctr_inf_dd t
left join   edw.dws_hr_empe_inf_dd t2       --员工汇总信息
on      t.wlth_mng_mnl_id = t2.empe_id
and     t2.dt = '20231114'
left join    edw.dim_hr_org_mng_org_tree_dd t3
on      t3.org_id = t2.org_id
and     t3.dt = '20231114'
where t.dt='20231114'
and t3.brc_org_id='320299999'		-- 苏州分行
;

drop table  if exists tldata_dev.sjxq_sj2023110701_cst_zyp_02;
create  table if not exists tldata_dev.sjxq_sj2023110701_cst_zyp_02 as
select t.cust_no
    ,sum(t.cur_fund_value)/30       as cur_fund_mon_avg
    ,sum(t.bond_fund_value)/30      as bond_fund_mon_avg
    ,sum(t.hybrid_fund_value)/30    as hybrid_fund_mon_avg
    ,sum(t.equity_fund_value)/30    as equity_fund_mon_avg
    ,sum(t.fof_fund_value)/30       as fof_fund_mon_avg
    ,sum(t.other_fund_value)/30     as other_fund_mon_avg
    ,sum(t.total_market_value)/30   as total_market_mon_avg
    ,sum(case when t.prod_code in('012564','012563','015824','014910','014911','007791'
        ,'007790','007603','007823','007824','007604','006592','006591','005471','004667'
        ,'000792','000084','000085','110052','110053')                  -- 短债
        then t.total_market_value else 0 end)/30           as          short_bond_mon_avg
    ,sum(case when t.prod_code in('015822','015826','015643','014430')    -- 同业存单
        then t.total_market_value  else 0 end)/30 as ty_cd_mon_avg
from edw.cfin_fund_market_value_total t
where t.dt between '20230901' and '20230930'
group by t.cust_no
;

drop table  if exists tldata_dev.sjxq_sj2023110701_cst_zyp_03;
create  table if not exists tldata_dev.sjxq_sj2023110701_cst_zyp_03 as
select t.cust_no
    ,sum(t.cur_fund_value)/18       as cur_fund_mon_avg
    ,sum(t.bond_fund_value)/18      as bond_fund_mon_avg
    ,sum(t.hybrid_fund_value)/18    as hybrid_fund_mon_avg
    ,sum(t.equity_fund_value)/18    as equity_fund_mon_avg
    ,sum(t.fof_fund_value)/18       as fof_fund_mon_avg
    ,sum(t.other_fund_value)/18     as other_fund_mon_avg
    ,sum(t.total_market_value)/18   as total_market_mon_avg
    ,sum(case when t.prod_code in('012564','012563','015824','014910','014911','007791'
        ,'007790','007603','007823','007824','007604','006592','006591','005471','004667'
        ,'000792','000084','000085','110052','110053')                  -- 短债
        then t.total_market_value else 0 end)/18           as          short_bond_mon_avg
    ,sum(case when t.prod_code in('015822','015826','015643','014430')    -- 同业存单
        then t.total_market_value  else 0 end)/18 as ty_cd_mon_avg
from edw.cfin_fund_market_value_total t
where t.dt between '20231001' and '20231018'
group by t.cust_no
;
-- 字段：客户号	当前财富管户人姓名	当前财富管户人工号	当前财富管户人所在团队名称	当前财富管户人所在支行名称
drop table  if exists tldata_dev.sjxq_sj2023110701_cst_zyp;
create  table if not exists tldata_dev.sjxq_sj2023110701_cst_zyp as
select a.cst_id                 as 客户号
    ,a.empe_nm                  as 当前财富管户人姓名
    ,a.wlth_mng_mnl_id          as 当前财富管户人工号
    ,a.tem_org_nm               as 当前财富管户人所在团队
	,a.sbr_org_nm				as 当前财富管户人所在支行
    ,a.brc_org_nm               as 当前财富管户人所在分行
    ,b.cur_fund_mon_avg			as 货基月日均保有量0930
	,b.bond_fund_mon_avg		as 债基月日均保有量0930
	,b.hybrid_fund_mon_avg		as 混基月日均保有量0930
	,b.equity_fund_mon_avg		as 股基月日均保有量0930
	,b.fof_fund_mon_avg         as fof月日均保有量0930
	,b.other_fund_mon_avg       as 其他基金月日均保有量0930
	,b.total_market_mon_avg     as 基金月日均保有量0930
	,b.short_bond_mon_avg       as 短债月日均保有量0930
	,b.ty_cd_mon_avg			as 同业存单月日均保有量0930
    ,d.ncr_fnd_bal_mon_avg		as 非货基金月日均保有量0930

    ,c.cur_fund_mon_avg			as 货基月日均保有量1018
	,c.bond_fund_mon_avg		as 债基月日均保有量1018
	,c.hybrid_fund_mon_avg		as 混基月日均保有量1018
	,c.equity_fund_mon_avg		as 股基月日均保有量1018
	,c.fof_fund_mon_avg         as fof月日均保有量1018
	,c.other_fund_mon_avg       as 其他基金月日均保有量1018
	,c.total_market_mon_avg     as 基金月日均保有量1018
	,c.short_bond_mon_avg       as 短债月日均保有量1018
	,c.ty_cd_mon_avg			as 同业存单月日均保有量1018
    ,f.ncr_fnd_bal_mon_avg		as 非货基金月日均保有量1018
from tldata_dev.sjxq_sj2023110701_cst_zyp_01 a
left join tldata_dev.sjxq_sj2023110701_cst_zyp_02 b
on 	a.cst_id=b.cust_no
left join tldata_dev.sjxq_sj2023110701_cst_zyp_03 c
on 	a.cst_id=c.cust_no
left join adm_pub.adm_csm_cbus_fnd_bal_inf_dd d
on 	a.cst_id=d.cst_id
and d.dt='20230930'
left join adm_pub.adm_csm_cbus_fnd_bal_inf_dd f
on 	a.cst_id=f.cst_id
and f.dt='20231018'
;

select count(1) cnt,count(distinct 客户号) --14858
from  tldata_dev.sjxq_sj2023110701_cst_zyp
;
**SJ20231109121_code.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 耿延鹏
-- 创建日期: 2023-11-16 9:11:20
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
-- 新增定投客户明细表。新增定投客户指活动期间，基金（除货币基金、同业存单基金、短债基金外）定投累计扣款成功次数不低于3次，且累计扣款成功金额不低于1000元的客户（含员工自购）。
-- 按照客户维度进行统计，即一位客户定投多只产品仅计入一户。
-- 活动开始前（6月30日15：00前）已在我行存在定投扣款成功记录的客户不重复计入本次劳动竞赛。
-- 字段名称：客户姓名	客户号	当前财富管户人姓名	当前财富管户人工号	当前财富管户人所在团队名称	当前财富管户人所在分行名称
-- 基金类型	定投累计申请金额	定投累计申请次数	9月3日前累计定投申请金额 9月3日前累计定投申请次数	10月31日名下是否有有效定投协议

-- 10月31日
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_01 AS
SELECT  A.CST_ID,A.CST_NM,A.PD_CD,C.FUND_TYPE,A.TRX_DT,A.AIP_START_DT
	,A.MGR_ID,A.TRX_ORG_ID,A.AGR_ID
	,CASE A.AGR_STS_CD
           WHEN '0' THEN '正常'
           WHEN '1' THEN '暂停'
           WHEN '2' THEN '客户终止'
           WHEN '3' THEN '异常终止'
           WHEN '4' THEN '到期终止'
           ELSE A.AGR_STS_CD
         END AGR_STS
	,A.AIP_PRD_VAL,A.AIP_AMT
	,A.ACM_AIP_SUC_AMT,A.ACM_SUC_TMS
FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD A -- 基金定投协议信息
LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15 B
ON 	A.PD_CD=B.PRD_CD
AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
LEFT JOIN(
	SELECT  DISTINCT PROD_CODE,FUND_TYPE -- ,PROD_NAME
	FROM EDW.CFIN_FUND_SALE_STOCK A
	WHERE DT BETWEEN '20230701' AND '20231031'
	-- AND FUND_TYPE='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
)C ON A.PD_CD=C.PROD_CODE
LEFT JOIN (
	-- 活动开始前（6月30日15：00前）已在我行存在定投扣款成功记录的客户
	SELECT  DISTINCT CST_ID
	FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD -- 基金定投协议信息
	WHERE DT='20230630' AND ACM_SUC_TMS>0
)D ON A.CST_ID=D.CST_ID
WHERE DT='20231031'
AND ACM_SUC_TMS>=3
AND ACM_AIP_SUC_AMT>=1000
AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
-- AND C.PROD_CODE IS NULL 	-- 剔除 货基
AND D.CST_ID IS NULL 		-- 剔除 存量定投客户
;

-- 9月3日
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_02 AS
SELECT  A.CST_ID,A.CST_NM,A.PD_CD,C.FUND_TYPE,A.TRX_DT,A.AIP_START_DT
	,A.MGR_ID,A.TRX_ORG_ID,A.AGR_ID
	,CASE A.AGR_STS_CD
           WHEN '0' THEN '正常'
           WHEN '1' THEN '暂停'
           WHEN '2' THEN '客户终止'
           WHEN '3' THEN '异常终止'
           WHEN '4' THEN '到期终止'
           ELSE A.AGR_STS_CD
         END AGR_STS
	,A.AIP_PRD_VAL,A.AIP_AMT
	,A.ACM_AIP_SUC_AMT,A.ACM_SUC_TMS
FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD A -- 基金定投协议信息
LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15 B
ON 	A.PD_CD=B.PRD_CD
AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
LEFT JOIN(
	SELECT  DISTINCT PROD_CODE,FUND_TYPE -- ,PROD_NAME
	FROM EDW.CFIN_FUND_SALE_STOCK A
	WHERE DT BETWEEN '20230701' AND '20231031'
	-- AND FUND_TYPE='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
)C ON A.PD_CD=C.PROD_CODE
LEFT JOIN (
	-- 活动开始前（6月30日15：00前）已在我行存在定投扣款成功记录的客户
	SELECT  DISTINCT CST_ID
	FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD -- 基金定投协议信息
	WHERE DT='20230630' AND ACM_SUC_TMS>0
)D ON A.CST_ID=D.CST_ID
WHERE DT='20230903'
AND ACM_SUC_TMS>=3
AND ACM_AIP_SUC_AMT>=1000
AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
-- AND C.PROD_CODE IS NULL 	-- 剔除 货基
AND D.CST_ID IS NULL 		-- 剔除 存量定投客户
;

-- 字段名称：客户姓名	客户号	当前财富管户人姓名	当前财富管户人工号	当前财富管户人所在团队名称	当前财富管户人所在分行名称
-- 基金类型	定投累计申请金额	定投累计申请次数	9月3日前累计定投申请金额 9月3日前累计定投申请次数	10月31日名下是否有有效定投协议

DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP AS
SELECT A.CST_NM					as 	客户姓名
	,A.CST_ID 					as	客户号
	,T3.EMPE_NM                 as 	当前财富管户人姓名
	,T2.WLTH_MNG_MNL_ID         as 	当前财富管户人工号
	,T4.TEM_ORG_NM              as	当前财富管户人所在团队名称
	,T4.BRC_ORG_NM              as 	当前财富管户人所在分行名称
	,DECODE(FUND_TYPE, '01','股票型','02','债券型','03','混合型','04','货币型') 基金类型
	,COALESCE(A.ACM_AIP_SUC_AMT,0)  as 定投累计申请金额
	,COALESCE(A.ACM_SUC_TMS,0)      as 定投累计申请次数
	,COALESCE(B.ACM_AIP_SUC_AMT,0)  as 9月3日前累计定投申请金额
	,COALESCE(B.ACM_SUC_TMS,0)      as 9月3日前累计定投申请次数
	,A.IS_VALD_AGR 					as 10月31日名下是否有有效定投协议
FROM(
	SELECT A.CST_NM,A.CST_ID,MIN(FUND_TYPE) FUND_TYPE
		,SUM(ACM_AIP_SUC_AMT) ACM_AIP_SUC_AMT
        ,SUM(ACM_SUC_TMS) ACM_SUC_TMS
		,MAX(CASE WHEN AGR_STS='正常' THEN 1 ELSE 0 END) IS_VALD_AGR
	FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_01 A
    WHERE FUND_TYPE<>'04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
	GROUP BY A.CST_NM,A.CST_ID
)A LEFT JOIN(
	SELECT A.CST_ID
		,SUM(ACM_AIP_SUC_AMT) ACM_AIP_SUC_AMT
        ,SUM(ACM_SUC_TMS) ACM_SUC_TMS
	FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_02 A
    WHERE FUND_TYPE<>'04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
	GROUP BY A.CST_ID
)B ON A.CST_ID=B.CST_ID
LEFT JOIN EDW.DIM_BUS_CHM_FND_CST_CTR_INF_DD T2		-- 基金客户签约信息表
ON      A.CST_ID = T2.CST_ID
AND     T2.DT = '20231031'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD T3 				-- 员工汇总信息
ON      T2.WLTH_MNG_MNL_ID = T3.EMPE_ID
AND     T3.DT = '20231031'
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD T4
ON      T4.ORG_ID = T3.ORG_ID
AND     T4.DT = '20231031'
;

SELECT COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS -- 2215
FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP
;
**SJ20231109121_code2.sql

-- 新增定投客户明细表。
-- 新增定投客户指活动期间，基金（除货币基金、同业存单基金、短债基金外）定投累计扣款成功次数不低于3次，且累计扣款成功金额不低于1000元的客户（含员工自购）。
-- 按照客户维度进行统计，即一位客户定投多只产品仅计入一户。
-- 活动开始前（6月30日15：00前）已在我行存在定投扣款成功记录的客户不重复计入本次劳动竞赛。
-- 字段名称：客户姓名	客户号	当前财富管户人姓名	当前财富管户人工号	当前财富管户人所在团队名称	当前财富管户人所在分行名称
-- 基金类型	定投累计申请金额	定投累计申请次数	9月3日前累计定投申请金额 9月3日前累计定投申请次数	10月31日名下是否有有效定投协议

/*
定投累计申请金额	&quot;
1、6月30日15：00-10月31日15：00定投累计申请金额
2、定投累计申请金额&ge;1000元&quot;
定投累计申请次数	&quot;1、6月30日15：00-10月31日15：00定投累计申请次数
2、定投累计申请次数&ge;3次
3、与定投累计金额的条件为&ldquo;且&rdquo;的关系&quot;
9月3日前累计定投申请金额	6月30日15：00-9月3日15：00定投累计申请金额
9月3日前累计定投申请次数	6月30日15：00-9月3日15：00定投累计申请次数

10月31日名下是否有有效定投协议	&quot;1、客户维度统计，不要求和满足定投有效户的产品保持一致，只要名下至少一个符合竞赛要求的有效定投协议即可。
2、有效定投：定投协议状态为正常（综合财富平台中定投协议状态分为：&ldquo;正常&rdquo;、&ldquo;暂停&rdquo;、&ldquo;客户终止&rdquo;、&ldquo;异常终止&rdquo;、&ldquo;到期终止&rdquo;五种状态）&quot;

*/


-- 10月31日 的定投累计申请金额 - 6月30日定投累计申请金额（需要剔除 短债、货基）
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_01 AS
SELECT  A.CST_ID,min(A.AIP_START_DT) AIP_START_DT
    ,sum(a.ACM_AIP_SUC_AMT) ACM_AIP_SUC_AMT
    ,sum(a.ACM_SUC_TMS) ACM_SUC_TMS
FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD A -- 基金定投协议信息
LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15 B
ON 	A.PD_CD=B.PRD_CD
AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
LEFT JOIN(
	SELECT DISTINCT Pd_cd
	FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
	WHERE DT='20231031'
	AND fnd_typ_cd='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
)C ON A.PD_CD=C.Pd_cd
LEFT JOIN (
	-- 活动开始前（6月30日15：00前）已在我行存在定投扣款成功记录的客户
	SELECT  DISTINCT CST_ID
	FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD -- 基金定投协议信息
	WHERE DT='20230630' AND ACM_SUC_TMS>0    --6月30日前存在定投扣款成功客户
)D ON A.CST_ID=D.CST_ID
WHERE A.DT='20231031'
AND A.AIP_START_DT BETWEEN '20230701' AND '20231031'   --基金确认时间，之前定投需剔除
AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
AND C.Pd_cd IS NULL 	-- 剔除 货基
AND D.CST_ID IS NULL 		-- 剔除 存量定投客户
GROUP by  A.CST_ID
having sum(a.ACM_AIP_SUC_AMT)>=1000 and sum(a.ACM_SUC_TMS)>=3
;

--20230903
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_02 AS
SELECT  A.CST_ID,sum(a.ACM_AIP_SUC_AMT) ACM_AIP_SUC_AMT
    ,sum(a.ACM_SUC_TMS) ACM_SUC_TMS
FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD A -- 基金定投协议信息
LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15 B
ON 	A.PD_CD=B.PRD_CD
AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
LEFT JOIN(
	SELECT DISTINCT Pd_cd
	FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
	WHERE DT='20231031'
	AND fnd_typ_cd='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
)C ON A.PD_CD=C.Pd_cd
WHERE A.DT='20230903'
AND A.AIP_START_DT BETWEEN '20230701' AND '20231031'   --基金确认时间，之前定投需剔除
AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
AND C.Pd_cd IS NULL 	-- 剔除 货基
GROUP by  A.CST_ID
;

--当前基金状态
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_03;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_03 AS
select cst_ID,cst_nm,min(AGR_STS_CD) AGR_STS_CD,min(FUND_TYPE) FUND_TYPE
from EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD  a
LEFT JOIN(
	SELECT DISTINCT Pd_cd,fnd_typ_cd FUND_TYPE -- ,PROD_NAME
	FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
	WHERE DT='20231031'
)C ON A.PD_CD=C.Pd_cd
where a.dt='20231031'
group by a.cst_ID,a.cst_nm
;

-- 字段名称：客户姓名	客户号	当前财富管户人姓名	当前财富管户人工号	当前财富管户人所在团队名称	当前财富管户人所在分行名称
-- 基金类型	定投累计申请金额	定投累计申请次数	9月3日前累计定投申请金额 9月3日前累计定投申请次数	10月31日名下是否有有效定投协议

DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP AS
SELECT c.CST_NM					as 	客户姓名
	,A.CST_ID 					as	客户号
	,T3.EMPE_NM                 as 	当前财富管户人姓名
	,T2.WLTH_MNG_MNL_ID         as 	当前财富管户人工号
	,T4.TEM_ORG_NM              as	当前财富管户人所在团队名称
	,T4.BRC_ORG_NM              as 	当前财富管户人所在分行名称
	,DECODE(c.FUND_TYPE, '01','股票型','02','债券型','03','混合型','04','货币型') 基金类型
	,COALESCE(A.ACM_AIP_SUC_AMT,0)  as 定投累计申请金额
	,COALESCE(A.ACM_SUC_TMS,0)      as 定投累计申请次数
	,COALESCE(B.ACM_AIP_SUC_AMT,0)  as 9月3日前累计定投申请金额
	,COALESCE(B.ACM_SUC_TMS,0)      as 9月3日前累计定投申请次数
	,case when c.AGR_STS_CD='0' then '是' else '否' end as 10月31日名下是否有有效定投协议
FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_01 A
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_02 B
ON A.CST_ID=B.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_03 c
ON A.CST_ID=c.CST_ID
LEFT JOIN EDW.DIM_BUS_CHM_FND_CST_CTR_INF_DD T2		-- 基金客户签约信息表
ON      A.CST_ID = T2.CST_ID
AND     T2.DT = '20231031'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD T3 				-- 员工汇总信息
ON      T2.WLTH_MNG_MNL_ID = T3.EMPE_ID
AND     T3.DT = '20231031'
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD T4
ON      T4.ORG_ID = T3.ORG_ID
AND     T4.DT = '20231031'
;

SELECT '1' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS -- 3536
FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_01
union all
SELECT '2' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS -- 3536
FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_02
union all
SELECT '3' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS -- 3536
FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP_03
union all
SELECT 'res' ,COUNT(1) CNT,COUNT(DISTINCT 客户号) CUSTS -- 3536
FROM TLDATA_DEV.SJXQ_SJ20231109121_CST_ZYP
;

1	3510	3510
2	4149	4149
3	8709	8709
res	3510	3510

**SJ2023111056_code.sql
-- 截止10.31
-- 工号	姓名	年龄	入行年限	学历	分行	支行	团队	岗位	主管户客户数
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_01 AS
SELECT A.EMPE_ID,A.EMPE_NM,A.EMPE_AGE
	,ROUND(DATEDIFF(TO_DATE('20231031','YYYYMMDD'),TO_DATE(A.JOIN_CMP_DT,'YYYYMMDD'),'DD')/365,1) JOIN_AGE
	,A.HI_ACDM_DEG_CD				--最高学历
	,D.CD_VAL_DSCR	HI_ACDM_DEG
	,B.BRC_ORG_NM,B.SBR_ORG_NM,B.TEM_ORG_NM
	,C.POS_NM
FROM EDW.DWS_HR_EMPE_INF_DD A 					--员工汇总信息	27621
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD B 		--机构树_考核维度
ON      B.ORG_ID = A.ORG_ID
AND     B.DT = '20231031'
LEFT JOIN  EDW.DIM_HR_ORG_JOB_INF_DD C 			--职位信息
ON      A.POS_ENC = C.POS_ID
AND     C.DT = '20231031'
LEFT JOIN EDW.DWD_CODE_LIBRARY_DD 	D
ON 	A.HI_ACDM_DEG_CD=D.CD_VAL
AND D.TBL_NM='DWS_HR_EMPE_INF_DD'
AND D.FLD_NM='HI_ACDM_DEG_CD'
AND D.DT = '20231031'
WHERE   A.DT = '20231031'
;

--存款 是否存款客户 当前存款余额 存款年日均
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_02 AS
SELECT CST_ID
	,DEP_BAL				-- 存款余额
	,DEP_BAL_YEAR_AVG		-- 存款年日均
FROM ADM_PUB.ADM_CSM_CBUS_DEP_INF_DD 		-- 客户存款业务信息表 15640226
WHERE DT = '20231031'
;

--贷款 是否贷款客户 当前贷款余额 贷款年日均
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_03;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_03 AS
SELECT CST_ID
	,COM_LOAN_BAL			--一般贷款余额
	,COR_LOAN_BAL			--对公贷款余额
	,IDV_LOAN_BAL			--对私贷款余额
	,COR_COM_LOAN_BAL		--对公一般贷款余额
	,IDV_COM_LOAN_BAL		--对私一般贷款余额
	,LOAN_MON_AVG			--一般贷款余额月日均
	,LOAN_BAL_ACS			--贷款余额（K）
	,LOAN_BAL_ACS_YEAR_AVG	--贷款余额年日均（K）
FROM ADM_PUB.ADM_CSM_CBUS_LOAN_INF_DD	--客户贷款业务信息表 15640226
WHERE DT = '20231031'
;

--保险 是否保险客户 保险规模	保险件数	保险中收	44730
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_04;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_04 AS
SELECT T1.CST_ID
	,CASE WHEN T1.INSU_AMT>0 THEN '1' ELSE '0' END IS_INSU_CST
	,T1.INSU_NUM,T2.INSU_NUM2		--数据核验一致
	,T1.INSU_AMT,T2.INSU_AMT2
	,T1.INSU_MID_INC
	,T2.INSU_MID_INC2
	,COALESCE(T3.INSU_NUM_22,0)			INSU_NUM_22
	,COALESCE(T3.INSU_AMT_22,0)         INSU_AMT_22
	,COALESCE(T3.INSU_MID_INC_22,0)     INSU_MID_INC_22
FROM(
	SELECT CST_ID
		,COUNT(INSU_ID) 	INSU_NUM
		,SUM(MNG_INSU_FEE)	INSU_AMT		--管户折算保费(保险规模)
		,SUM(MNG_CMSN_FEE)	INSU_MID_INC	--管户折算手续费(保险中收)
	FROM ADM_PUB.ADM_PUB_INSU_CST_PD_LIST 	--保险代销客户产品清单-全量
	WHERE   DT = '20231031'
	AND     INSU_PLCY_STS_CD IN ( '0' , '1' , 'A' ) --0正常 1退保 2当日退单 3犹豫期退保 4已质押 5取消 6挂失 7登记，未核保 9其他 A满期退保 B失效 C终止理赔
	AND     MNG_TYP = '1' --管户类型：1考核 2销售
	--AND     TRX_DT >= '20230101'
	AND     TRX_DT <= '20231031'
	GROUP BY CST_ID
)T1 LEFT JOIN (
	SELECT CST_ID
		,SUM(MNG_CNV_INSU_FEE)	INSU_AMT2
		,SUM(NBR_NUM)			INSU_NUM2			--件数
		,SUM(MNG_CNV_CMSN_FEE)	INSU_MID_INC2
	FROM APP_RPT.FCT_INSU_AGN_BUS_ACS_DTL_TBL		--保险代销业务考核明细表
	WHERE DT='20231031'
	--AND TRX_DT >= '2023-01-01'
	AND TRX_DT <='2023-10-31'
	AND INSU_PLCY_STS IN('正常','退保','满期退保') --正常 ,当日撤单 ,犹豫期退保 ,失效 ,退保 ,取消 ,登记，未核保
	GROUP BY CST_ID
)T2 ON T1.CST_ID=T2.CST_ID
LEFT JOIN (
	SELECT CST_ID
		,COUNT(INSU_ID) 	INSU_NUM_22
		,SUM(MNG_INSU_FEE)	INSU_AMT_22		--管户折算保费(保险规模)
		,SUM(MNG_CMSN_FEE)	INSU_MID_INC_22	--管户折算手续费(保险中收)
	FROM ADM_PUB.ADM_PUB_INSU_CST_PD_LIST 	--保险代销客户产品清单-全量
	WHERE   DT = '20231031'
	AND     INSU_PLCY_STS_CD IN ( '0' , '1' , 'A' ) --0正常 1退保 2当日退单 3犹豫期退保 4已质押 5取消 6挂失 7登记，未核保 9其他 A满期退保 B失效 C终止理赔
	AND     MNG_TYP = '1' --管户类型：1考核 2销售
	--AND     TRX_DT >= '20220101'
	AND     TRX_DT <= '20221231'
	GROUP BY CST_ID
)T3 ON T1.CST_ID=T3.CST_ID
;

--财富业务信息6447746
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_05;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_05 AS
SELECT T1.CST_ID				--客户号
	,T1.EFE_CST_IND				--有效户标识
	,T1.EFE_DEP_CST_IND			--有效存款户标识
	,T1.EFE_LOAN_CST_IND		--有效信贷户标识
	,T1.EFE_CHM_CST_IND			--有效理财户标识 95466
	,T1.EFE_WLTH_CST_IND		--有效财富户标识
	,T1.EFE_INSU_CST_IND		--有效保险户标识
	,T1.EFE_NOB_MET_CST_IND		--有效贵金属户标识
	,T2.CST_SEG_FLG				--'1:企业主','2:个体工商户','3:企事业高管','4:非持牌个体户','5:工薪族','6:退休养老','7:持家女性'
	,T3.FNC_AMT					--理财金额
	,T3.FNC_YEAR_AVG_AMT		--理财金额年日均
	,T3.GOLD_AMT				--贵金属近一年金额
	,T3.GOLD_YEAR_AVG_AMT		--贵金属金额年日均
	,T3.INSU_AMT				--保险保费
	,T3.INSU_YEAR_AVG_AMT		--保险保费年日均
	,T3.WLTH_BAL				--财富资产余额
	,T3.AUM_BAL					--客户综合金融资产(AUM)
	,T3.GOLD_BUY_AMT			--贵金属购买金额
	,T3.WLTH_YEAR_AVG			--财富资产余额年日均
	,T3.AUM_YEAR_AVG			--客户综合金融资产(AUM)年日均
	,T7.CHM_MID_INC_CUR_YEAR	--理财本年中收
	,T7.AGN_INSU_FEE_INC_CUR_YEAR	--保险本年中收
	,T7.AGN_PRME_FEE_INC_CUR_YEAR	--贵金属本年中收
	,T7.DEP_BAL					--存款余额
	,T7.DEP_BAL_YEAR_AVG		--存款年日均
	,T7.LOAN_BAL_ACS			--贷款余额
	,CASE WHEN T4.CST_ID IS NOT NULL THEN '1' ELSE '0' END IS_32W
	,T5.PRM_MGR_ID				--主管户ID
	,T6.AUM_GRD					--财富等级
FROM ADM_PUB.ADM_CSM_CBAS_IND_INF_DD				T1
LEFT JOIN ADM_PUB.ADM_CSM_CLAB_CST_JC_INF_DD 		T2   -- 客户集市-客户标签信息-客户信息
ON 		T1.CST_ID=T2.CST_ID
AND		T2.DT='20231031'
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_CST_FIN_AST_INF_DD 	T3
ON 		T1.CST_ID=T3.CST_ID
AND		T3.DT='20231031'
LEFT JOIN TLDATA_DEV.TMP_QWJ_0818_MKX_KQ 			T4 	--32万企业主表 325315
ON 		T1.CST_ID=T4.CST_ID
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T5 	--客户主管户信息
ON      T1.CST_ID = T5.CST_ID
AND     T5.DT = '20231031'
LEFT JOIN ADM_PUB.ADM_CSM_CBAS_CST_GRD_INF_DD		T6 	-- 客户等级信息
ON 	T1.CST_ID=T6.CST_ID
AND T6.DT = '20231031'
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		T7	-- 正式客户财富业务信息表
ON 	T1.CST_ID=T7.CST_ID
AND T7.DT='20231031'
WHERE 	T1.DT='20231031'
;

-- 理财 是否理财客户 余额	理财余额较年初	理财年日均	理财年日均较年初 186486
-- 是否挂钩理财客户 挂钩理财余额	 挂钩理财年日均 挂钩理财中收
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_07;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_07 AS
SELECT T1.CST_ID
	,CASE WHEN T1.FNC_BAL>0 THEN '1' ELSE '0' END IS_FNC_CST
	,T1.FNC_BAL,T1.FNC_BAL_LSTY,T1.FNC_BAL_Y_AVG
	,T1.FNC_BAL_Y_AVG - T2.FNC_BAL_Y_AVG_22 FNC_BAL_Y_AVG_LSTY
	,T1.FNC_MID_INCM
	-- ,T3.FNC_MID_INCM2
	,CASE WHEN T1.GG_FNC_BAL>0 THEN '1' ELSE '0' END IS_GG_FNC_CST
	,T1.GG_FNC_BAL,T1.GG_FNC_BAL_Y_AVG,T1.GG_FNC_MID_INCM
FROM(
	SELECT CST_ID
		,SUM(BAL)			FNC_BAL				--当日余额
		,SUM(BAL_LSTY_DI)	FNC_BAL_LSTY		--余额较年初
		,SUM(AVG_Y)			FNC_BAL_Y_AVG		--年日均
		,SUM(YEAR_MID_AMT) 	FNC_MID_INCM		--本年中收(自营+代销)
		,SUM(CASE WHEN IS_HOOK_CHM='1' THEN BAL 	ELSE 0 END) 	 GG_FNC_BAL
		,SUM(CASE WHEN IS_HOOK_CHM='1' THEN AVG_Y 	ELSE 0 END) 	 GG_FNC_BAL_Y_AVG
		,SUM(CASE WHEN IS_HOOK_CHM='1' THEN YEAR_MID_AMT ELSE 0 END) GG_FNC_MID_INCM
	FROM APP_RPT.ADM_SUBL_BUS_CHM_MUL_DIM_STAT_DD  T1 --理财业务多维统计表
	WHERE DT='20231031'
	GROUP BY CST_ID
)T1 LEFT JOIN(
	SELECT CST_ID,SUM(AVG_Y) FNC_BAL_Y_AVG_22	--年日均
	FROM APP_RPT.ADM_SUBL_BUS_CHM_MUL_DIM_STAT_DD
	WHERE DT='20221231'
	GROUP BY CST_ID
)T2 ON T1.CST_ID=T2.CST_ID
/* LEFT JOIN(
	SELECT  CST_ID
		,SUM(COALESCE(MID_AMT, 0)) AS FNC_MID_INCM2 --理财中收
	FROM    EDW.DWS_BUS_CHM_ACT_MGR_INF_DD A --理财考核汇总信息表
	WHERE   MNG_TYP_CD = '1' --管户类型：1考核 2销售
	-- AND     AGN_IND = '1' --代销标志：0自营 1代销
	AND     PD_TP_CD = '1' --理财类型：0基金 1理财
	AND     DT BETWEEN '20230101' AND '20231031'
	GROUP BY CST_ID
)T3 ON T1.CST_ID=T3.CST_ID */
;

--贵金属 是否贵金属客户	件数 余额 中收 11896
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_08;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_08 AS
SELECT T1.CST_ID,T1.GOLD_NUM,T1.GOLD_BAL,T1.GOLD_INCM
	-- ,T2.GOLD_INCM2
FROM(
	SELECT CST_ID				--	客户号
		,SUM(QTY)				GOLD_NUM
		,SUM(CMDT_PAY_UNT_PRC) 	GOLD_BAL
		,SUM(MID_INC_TOT_AMT) 	GOLD_INCM
	FROM ADM_PUB.ADM_PUB_CST_NOB_MET_TRX_DTL_DI	--贵金属交易明细表
	WHERE DT BETWEEN '20230101' AND '20231031'
	GROUP BY CST_ID
)T1
/* LEFT JOIN(
	SELECT CST_ID
		,SUM(MID_INC_TOT_AMT) GOLD_INCM2		--贵金属中收
	FROM ADM_PUB.ADM_PUB_CST_NOB_MET_TRX_SUM_DI --贵金属交易整合表
	WHERE  DT BETWEEN '20230101' AND '20231031'
	AND CMDT_PAY_UNT_PRC<>0 			--存在未付钱且有中收，需剔除
	GROUP BY CST_ID
)T2 ON T1.CST_ID=T2.CST_ID */
;


--字段汇总表
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_10;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_10 AS
SELECT T1.PRM_MGR_ID,T1.CST_ID,T1.AUM_GRD,T1.IS_32W
	,T1.EFE_CST_IND						--有效户标识
	,T1.EFE_DEP_CST_IND			        --有效存款户标识
	,T1.EFE_LOAN_CST_IND		        --有效信贷户标识
	,T1.EFE_CHM_CST_IND			        --有效理财户标识 95466
	,T1.EFE_WLTH_CST_IND		        --有效财富户标识
	,T1.EFE_INSU_CST_IND		        --有效保险户标识
	,T1.EFE_NOB_MET_CST_IND		        --有效贵金属户标识
	,T1.CST_SEG_FLG				        --'1:企业主','2:个体工商户','3:
	,T1.FNC_AMT					        --理财金额
	,T1.FNC_YEAR_AVG_AMT		        --理财金额年日均
	,T1.GOLD_AMT				        --贵金属近一年金额
	,T1.GOLD_YEAR_AVG_AMT		        --贵金属金额年日均
	,T1.INSU_AMT INSU_AMT2				--保险保费 不相等
	,T1.INSU_YEAR_AVG_AMT		        --保险保费年日均
	,T1.WLTH_BAL				        --财富资产余额
	,T1.AUM_BAL					        --客户综合金融资产(AUM)
	,T1.GOLD_BUY_AMT			        --贵金属购买金额
	,T1.WLTH_YEAR_AVG			        --财富资产余额年日均
	,T1.AUM_YEAR_AVG			        --客户综合金融资产(AUM)年日均
	,T1.CHM_MID_INC_CUR_YEAR	        --理财本年中收
	,T1.AGN_INSU_FEE_INC_CUR_YEAR       --保险本年中收
	,T1.AGN_PRME_FEE_INC_CUR_YEAR       --贵金属本年中收
	,T1.DEP_BAL	DEP_BAL2	 			--存款余额 相等
	,T1.DEP_BAL_YEAR_AVG DEP_BAL_YEAR_AVG2	 --存款年日均
	,T1.LOAN_BAL_ACS LOAN_BAL_ACS2      --贷款余额 相等

	,T2.DEP_BAL,T2.DEP_BAL_YEAR_AVG
	,T3.LOAN_BAL_ACS,T3.LOAN_BAL_ACS_YEAR_AVG
	,T4.IS_INSU_CST,T4.INSU_NUM,T4.INSU_AMT,T4.INSU_MID_INC
	,T4.INSU_NUM_22,T4.INSU_AMT_22,T4.INSU_MID_INC_22
	,T7.IS_FNC_CST,T7.FNC_BAL,T7.FNC_BAL_LSTY,T7.FNC_BAL_Y_AVG
	,T7.FNC_BAL_Y_AVG_LSTY,T7.FNC_MID_INCM
	,T7.IS_GG_FNC_CST,T7.GG_FNC_BAL,T7.GG_FNC_BAL_Y_AVG,T7.GG_FNC_MID_INCM
	,T8.GOLD_NUM,T8.GOLD_BAL,T8.GOLD_INCM
FROM TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_05 		T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_02 	T2	ON T1.CST_ID=T2.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_03 	T3	ON T1.CST_ID=T3.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_04 	T4	ON T1.CST_ID=T4.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_07 	T7	ON T1.CST_ID=T7.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_08 	T8	ON T1.CST_ID=T8.CST_ID
;
/*
SELECT  'DEP_BAL_YEAR_AVG' fld_nm,count(1) bt_cnt --不同数
from TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_10
where DEP_BAL_YEAR_AVG<>DEP_BAL_YEAR_AVG2
union all
SELECT  'FNC_AMT' fld_nm,count(1) bt_cnt --不同数
from TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_10
where FNC_AMT<>FNC_BAL
union all
SELECT  'FNC_YEAR_AVG_AMT' fld_nm,count(1) bt_cnt --不同数
from TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_10
where FNC_YEAR_AVG_AMT<>FNC_BAL_Y_AVG
union all
SELECT  'GOLD_AMT' fld_nm,count(1) bt_cnt --不同数
from TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_10
where GOLD_AMT<>GOLD_BAL
; */

--管户聚合表281.814S
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_11;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_11 AS
SELECT PRM_MGR_ID
	,COUNT(CST_ID) 								MNG_CUSTS
	,COUNT(CASE WHEN DEP_BAL>0 THEN CST_ID END) DEP_CUSTS
	,SUM(DEP_BAL) 								DEP_BAL
	,SUM(DEP_BAL_YEAR_AVG) 						DEP_BAL_YEAR_AVG
	,COUNT(CASE WHEN LOAN_BAL_ACS>0 THEN CST_ID END) LOAN_CUSTS
	,SUM(LOAN_BAL_ACS) 							LOAN_BAL
	,SUM(LOAN_BAL_ACS_YEAR_AVG) 				LOAN_BAL_YEAR_AVG
	,COUNT(CASE WHEN IS_INSU_CST='1' THEN CST_ID END) INSU_CUSTS
	,SUM(INSU_AMT) 								INSU_AMT
	,SUM(INSU_NUM) 								INSU_NUM
	,SUM(INSU_MID_INC) 							INSU_MID_INC
	,COUNT(CASE WHEN IS_INSU_CST='1' AND LOAN_BAL_ACS>0 THEN CST_ID END) INSU_LOAN_CUSTS
	,SUM(CASE WHEN LOAN_BAL_ACS>0 THEN INSU_AMT ELSE 0 END) LOAN_INSU_AMT
	,COUNT(CASE WHEN INSU_AMT_22>0 THEN CST_ID END) INSU_CUSTS_22
	,SUM(INSU_AMT_22)							INSU_AMT_22
	,SUM(INSU_NUM_22) 							INSU_NUM_22
	,SUM(INSU_MID_INC_22) 						INSU_MID_INC_22
	,SUM(FNC_BAL) 								FNC_BAL
	,SUM(FNC_BAL_LSTY)		 					FNC_BAL_LSTY
	,SUM(FNC_BAL_Y_AVG)      					FNC_BAL_Y_AVG
	,SUM(FNC_BAL_Y_AVG_LSTY) 					FNC_BAL_Y_AVG_LSTY
	,COUNT(CASE WHEN IS_32W='1' AND DEP_BAL>0 THEN CST_ID END) 			DEP_CUSTS_32W
	,SUM(CASE WHEN IS_32W='1' THEN DEP_BAL_YEAR_AVG ELSE 0 END) 		DEP_BAL_YEAR_AVG_32W
	,COUNT(CASE WHEN IS_32W='1' AND LOAN_BAL_ACS>0 THEN CST_ID END) 	LOAN_CUSTS_32W
	,SUM(CASE WHEN IS_32W='1' THEN LOAN_BAL_ACS_YEAR_AVG ELSE 0 END) 	LOAN_BAL_YEAR_AVG_32W
	,COUNT(CASE WHEN IS_FNC_CST='1' THEN CST_ID END) 		FNC_CUSTS
	,SUM(FNC_MID_INCM) 										FNC_MID_INCM
	,COUNT(CASE WHEN IS_GG_FNC_CST='1' THEN CST_ID END) 	GG_FNC_CUSTS
	,SUM(GG_FNC_BAL_Y_AVG) 									GG_FNC_BAL_Y_AVG
	,SUM(GG_FNC_MID_INCM)  									GG_FNC_MID_INCM
	,COUNT(CASE WHEN IS_GG_FNC_CST='1' AND LOAN_BAL_ACS>0 THEN CST_ID END) GG_FNC_LOAN_CUSTS
	,SUM(CASE WHEN LOAN_BAL_ACS>0 THEN GG_FNC_BAL ELSE 0 END)  LOAN_GG_FNC_BAL
	,COUNT(CASE WHEN GOLD_BAL>0 THEN CST_ID END) 			GOLD_CUSTS
	,SUM(GOLD_BAL)											GOLD_BAL
	,SUM(GOLD_NUM)      									GOLD_NUM
	,SUM(GOLD_INCM)     									GOLD_INCM
	,COUNT(CASE WHEN GOLD_BAL>0 AND LOAN_BAL_ACS>0 THEN CST_ID END) LOAN_GOLD_CUSTS
	,SUM(CASE WHEN LOAN_BAL_ACS>0 THEN GOLD_BAL ELSE 0 END) LOAN_GOLD_BAL

	,COUNT(CASE WHEN AUM_GRD='1' THEN CST_ID END) GRD1_CUSTS
	,COUNT(CASE WHEN AUM_GRD='2' THEN CST_ID END) GRD2_CUSTS
	,COUNT(CASE WHEN AUM_GRD='3' THEN CST_ID END) GRD3_CUSTS
	,COUNT(CASE WHEN AUM_GRD='4' THEN CST_ID END) GRD4_CUSTS
	,COUNT(CASE WHEN AUM_GRD='5' THEN CST_ID END) GRD5_CUSTS
	,COUNT(CASE WHEN AUM_GRD='6' THEN CST_ID END) GRD6_CUSTS
	,SUM(CASE WHEN AUM_GRD='1' THEN AUM_YEAR_AVG ELSE 0 END) GRD1_AUM_Y_AVG
	,SUM(CASE WHEN AUM_GRD='2' THEN AUM_YEAR_AVG ELSE 0 END) GRD2_AUM_Y_AVG
	,SUM(CASE WHEN AUM_GRD='3' THEN AUM_YEAR_AVG ELSE 0 END) GRD3_AUM_Y_AVG
	,SUM(CASE WHEN AUM_GRD='4' THEN AUM_YEAR_AVG ELSE 0 END) GRD4_AUM_Y_AVG
	,SUM(CASE WHEN AUM_GRD='5' THEN AUM_YEAR_AVG ELSE 0 END) GRD5_AUM_Y_AVG
	,SUM(CASE WHEN AUM_GRD='6' THEN AUM_YEAR_AVG ELSE 0 END) GRD6_AUM_Y_AVG
	,SUM(CASE WHEN AUM_GRD='1' THEN WLTH_YEAR_AVG ELSE 0 END) GRD1_WLTH_Y_AVG
	,SUM(CASE WHEN AUM_GRD='2' THEN WLTH_YEAR_AVG ELSE 0 END) GRD2_WLTH_Y_AVG
	,SUM(CASE WHEN AUM_GRD='3' THEN WLTH_YEAR_AVG ELSE 0 END) GRD3_WLTH_Y_AVG
	,SUM(CASE WHEN AUM_GRD='4' THEN WLTH_YEAR_AVG ELSE 0 END) GRD4_WLTH_Y_AVG
	,SUM(CASE WHEN AUM_GRD='5' THEN WLTH_YEAR_AVG ELSE 0 END) GRD5_WLTH_Y_AVG
	,SUM(CASE WHEN AUM_GRD='6' THEN WLTH_YEAR_AVG ELSE 0 END) GRD6_WLTH_Y_AVG

	,COUNT(CASE WHEN IS_32W='1' AND AUM_GRD='1' THEN CST_ID END) GRD1_32W_CUSTS
	,COUNT(CASE WHEN IS_32W='1' AND AUM_GRD='2' THEN CST_ID END) GRD2_32W_CUSTS
	,COUNT(CASE WHEN IS_32W='1' AND AUM_GRD='3' THEN CST_ID END) GRD3_32W_CUSTS
	,COUNT(CASE WHEN IS_32W='1' AND AUM_GRD='4' THEN CST_ID END) GRD4_32W_CUSTS
	,COUNT(CASE WHEN IS_32W='1' AND AUM_GRD='5' THEN CST_ID END) GRD5_32W_CUSTS
	,COUNT(CASE WHEN IS_32W='1' AND AUM_GRD='6' THEN CST_ID END) GRD6_32W_CUSTS
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='1' THEN AUM_YEAR_AVG ELSE 0 END) GRD1_32W_AUM_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='2' THEN AUM_YEAR_AVG ELSE 0 END) GRD2_32W_AUM_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='3' THEN AUM_YEAR_AVG ELSE 0 END) GRD3_32W_AUM_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='4' THEN AUM_YEAR_AVG ELSE 0 END) GRD4_32W_AUM_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='5' THEN AUM_YEAR_AVG ELSE 0 END) GRD5_32W_AUM_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='6' THEN AUM_YEAR_AVG ELSE 0 END) GRD6_32W_AUM_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='1' THEN WLTH_YEAR_AVG ELSE 0 END) GRD1_32W_WLTH_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='2' THEN WLTH_YEAR_AVG ELSE 0 END) GRD2_32W_WLTH_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='3' THEN WLTH_YEAR_AVG ELSE 0 END) GRD3_32W_WLTH_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='4' THEN WLTH_YEAR_AVG ELSE 0 END) GRD4_32W_WLTH_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='5' THEN WLTH_YEAR_AVG ELSE 0 END) GRD5_32W_WLTH_Y_AVG
	,SUM(CASE WHEN IS_32W='1' AND AUM_GRD='6' THEN WLTH_YEAR_AVG ELSE 0 END) GRD6_32W_WLTH_Y_AVG

	,COUNT(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='1' THEN CST_ID END) GRD1_INSU_CUSTS
	,COUNT(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='2' THEN CST_ID END) GRD2_INSU_CUSTS
	,COUNT(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='3' THEN CST_ID END) GRD3_INSU_CUSTS
	,COUNT(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='4' THEN CST_ID END) GRD4_INSU_CUSTS
	,COUNT(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='5' THEN CST_ID END) GRD5_INSU_CUSTS
	,COUNT(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='6' THEN CST_ID END) GRD6_INSU_CUSTS
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='1' THEN AUM_YEAR_AVG ELSE 0 END) GRD1_INSU_AUM_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='2' THEN AUM_YEAR_AVG ELSE 0 END) GRD2_INSU_AUM_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='3' THEN AUM_YEAR_AVG ELSE 0 END) GRD3_INSU_AUM_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='4' THEN AUM_YEAR_AVG ELSE 0 END) GRD4_INSU_AUM_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='5' THEN AUM_YEAR_AVG ELSE 0 END) GRD5_INSU_AUM_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='6' THEN AUM_YEAR_AVG ELSE 0 END) GRD6_INSU_AUM_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='1' THEN WLTH_YEAR_AVG ELSE 0 END) GRD1_INSU_WLTH_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='2' THEN WLTH_YEAR_AVG ELSE 0 END) GRD2_INSU_WLTH_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='3' THEN WLTH_YEAR_AVG ELSE 0 END) GRD3_INSU_WLTH_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='4' THEN WLTH_YEAR_AVG ELSE 0 END) GRD4_INSU_WLTH_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='5' THEN WLTH_YEAR_AVG ELSE 0 END) GRD5_INSU_WLTH_Y_AVG
	,SUM(CASE WHEN IS_INSU_CST='1' AND AUM_GRD='6' THEN WLTH_YEAR_AVG ELSE 0 END) GRD6_INSU_WLTH_Y_AVG

	,COUNT(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='1' THEN CST_ID END) GRD1_FNC_CUSTS
	,COUNT(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='2' THEN CST_ID END) GRD2_FNC_CUSTS
	,COUNT(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='3' THEN CST_ID END) GRD3_FNC_CUSTS
	,COUNT(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='4' THEN CST_ID END) GRD4_FNC_CUSTS
	,COUNT(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='5' THEN CST_ID END) GRD5_FNC_CUSTS
	,COUNT(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='6' THEN CST_ID END) GRD6_FNC_CUSTS
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='1' THEN AUM_YEAR_AVG ELSE 0 END) GRD1_FNC_AUM_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='2' THEN AUM_YEAR_AVG ELSE 0 END) GRD2_FNC_AUM_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='3' THEN AUM_YEAR_AVG ELSE 0 END) GRD3_FNC_AUM_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='4' THEN AUM_YEAR_AVG ELSE 0 END) GRD4_FNC_AUM_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='5' THEN AUM_YEAR_AVG ELSE 0 END) GRD5_FNC_AUM_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='6' THEN AUM_YEAR_AVG ELSE 0 END) GRD6_FNC_AUM_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='1' THEN WLTH_YEAR_AVG ELSE 0 END) GRD1_FNC_WLTH_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='2' THEN WLTH_YEAR_AVG ELSE 0 END) GRD2_FNC_WLTH_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='3' THEN WLTH_YEAR_AVG ELSE 0 END) GRD3_FNC_WLTH_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='4' THEN WLTH_YEAR_AVG ELSE 0 END) GRD4_FNC_WLTH_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='5' THEN WLTH_YEAR_AVG ELSE 0 END) GRD5_FNC_WLTH_Y_AVG
	,SUM(CASE WHEN IS_FNC_CST='1' AND AUM_GRD='6' THEN WLTH_YEAR_AVG ELSE 0 END) GRD6_FNC_WLTH_Y_AVG

	,COUNT(CASE WHEN GOLD_BAL>0 AND AUM_GRD='1' THEN CST_ID END) GRD1_GOLD_CUSTS
	,COUNT(CASE WHEN GOLD_BAL>0 AND AUM_GRD='2' THEN CST_ID END) GRD2_GOLD_CUSTS
	,COUNT(CASE WHEN GOLD_BAL>0 AND AUM_GRD='3' THEN CST_ID END) GRD3_GOLD_CUSTS
	,COUNT(CASE WHEN GOLD_BAL>0 AND AUM_GRD='4' THEN CST_ID END) GRD4_GOLD_CUSTS
	,COUNT(CASE WHEN GOLD_BAL>0 AND AUM_GRD='5' THEN CST_ID END) GRD5_GOLD_CUSTS
	,COUNT(CASE WHEN GOLD_BAL>0 AND AUM_GRD='6' THEN CST_ID END) GRD6_GOLD_CUSTS
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='1' THEN AUM_YEAR_AVG ELSE 0 END) GRD1_GOLD_AUM_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='2' THEN AUM_YEAR_AVG ELSE 0 END) GRD2_GOLD_AUM_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='3' THEN AUM_YEAR_AVG ELSE 0 END) GRD3_GOLD_AUM_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='4' THEN AUM_YEAR_AVG ELSE 0 END) GRD4_GOLD_AUM_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='5' THEN AUM_YEAR_AVG ELSE 0 END) GRD5_GOLD_AUM_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='6' THEN AUM_YEAR_AVG ELSE 0 END) GRD6_GOLD_AUM_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='1' THEN WLTH_YEAR_AVG ELSE 0 END) GRD1_GOLD_WLTH_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='2' THEN WLTH_YEAR_AVG ELSE 0 END) GRD2_GOLD_WLTH_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='3' THEN WLTH_YEAR_AVG ELSE 0 END) GRD3_GOLD_WLTH_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='4' THEN WLTH_YEAR_AVG ELSE 0 END) GRD4_GOLD_WLTH_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='5' THEN WLTH_YEAR_AVG ELSE 0 END) GRD5_GOLD_WLTH_Y_AVG
	,SUM(CASE WHEN GOLD_BAL>0 AND AUM_GRD='6' THEN WLTH_YEAR_AVG ELSE 0 END) GRD6_GOLD_WLTH_Y_AVG

	,COUNT(CASE WHEN IS_32W='1' THEN CST_ID END) 		CUSTS_32W
	,COUNT(CASE WHEN CST_SEG_FLG='1' THEN CST_ID END) 	CUSTS_QYZ
	,COUNT(CASE WHEN CST_SEG_FLG='2' THEN CST_ID END) 	CUSTS_GTGSH
	,COUNT(CASE WHEN CST_SEG_FLG='3' THEN CST_ID END) 	CUSTS_QSYGG
	,COUNT(CASE WHEN CST_SEG_FLG='4' THEN CST_ID END) 	CUSTS_FCPGTH
	,COUNT(CASE WHEN CST_SEG_FLG='5' THEN CST_ID END) 	CUSTS_GXZ
	,COUNT(CASE WHEN CST_SEG_FLG='6' THEN CST_ID END) 	CUSTS_TXYL
	,COUNT(CASE WHEN CST_SEG_FLG='7' THEN CST_ID END) 	CUSTS_CJNX
	,SUM(CASE WHEN IS_32W='1' THEN AUM_YEAR_AVG ELSE 0 END) 	 AUM_Y_AVG_32W
	,SUM(CASE WHEN CST_SEG_FLG='1' THEN AUM_YEAR_AVG ELSE 0 END) AUM_Y_AVG_QYZ
	,SUM(CASE WHEN CST_SEG_FLG='2' THEN AUM_YEAR_AVG ELSE 0 END) AUM_Y_AVG_GTGSH
	,SUM(CASE WHEN CST_SEG_FLG='3' THEN AUM_YEAR_AVG ELSE 0 END) AUM_Y_AVG_QSYGG
	,SUM(CASE WHEN CST_SEG_FLG='4' THEN AUM_YEAR_AVG ELSE 0 END) AUM_Y_AVG_FCPGTH
	,SUM(CASE WHEN CST_SEG_FLG='5' THEN AUM_YEAR_AVG ELSE 0 END) AUM_Y_AVG_GXZ
	,SUM(CASE WHEN CST_SEG_FLG='6' THEN AUM_YEAR_AVG ELSE 0 END) AUM_Y_AVG_TXYL
	,SUM(CASE WHEN CST_SEG_FLG='7' THEN AUM_YEAR_AVG ELSE 0 END) AUM_Y_AVG_CJNX

	,COUNT(CASE WHEN IS_32W='1' 	 AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_32W
	,COUNT(CASE WHEN CST_SEG_FLG='1' AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_QYZ
	,COUNT(CASE WHEN CST_SEG_FLG='2' AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_GTGSH
	,COUNT(CASE WHEN CST_SEG_FLG='3' AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_QSYGG
	,COUNT(CASE WHEN CST_SEG_FLG='4' AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_FCPGTH
	,COUNT(CASE WHEN CST_SEG_FLG='5' AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_GXZ
	,COUNT(CASE WHEN CST_SEG_FLG='6' AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_TXYL
	,COUNT(CASE WHEN CST_SEG_FLG='7' AND WLTH_BAL>0 THEN CST_ID END) 	WLTH_CUSTS_CJNX
	,SUM(CASE WHEN IS_32W='1' 		THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_32W
	,SUM(CASE WHEN CST_SEG_FLG='1' 	THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_QYZ
	,SUM(CASE WHEN CST_SEG_FLG='2' 	THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_GTGSH
	,SUM(CASE WHEN CST_SEG_FLG='3' 	THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_QSYGG
	,SUM(CASE WHEN CST_SEG_FLG='4' 	THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_FCPGTH
	,SUM(CASE WHEN CST_SEG_FLG='5' 	THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_GXZ
	,SUM(CASE WHEN CST_SEG_FLG='6' 	THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_TXYL
	,SUM(CASE WHEN CST_SEG_FLG='7' 	THEN WLTH_YEAR_AVG ELSE 0 END) WLTH_Y_AVG_CJNX

	--,COUNT(CASE WHEN IS_32W='1' 	 AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_32W
	,COUNT(CASE WHEN CST_SEG_FLG='1' AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_QYZ
	,COUNT(CASE WHEN CST_SEG_FLG='2' AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_GTGSH
	,COUNT(CASE WHEN CST_SEG_FLG='3' AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_QSYGG
	,COUNT(CASE WHEN CST_SEG_FLG='4' AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_FCPGTH
	,COUNT(CASE WHEN CST_SEG_FLG='5' AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_GXZ
	,COUNT(CASE WHEN CST_SEG_FLG='6' AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_TXYL
	,COUNT(CASE WHEN CST_SEG_FLG='7' AND DEP_BAL>0 THEN CST_ID END) 	DEP_CUSTS_CJNX
	,SUM(CASE WHEN IS_32W='1' 		THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_32W
	,SUM(CASE WHEN CST_SEG_FLG='1' 	THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_QYZ
	,SUM(CASE WHEN CST_SEG_FLG='2' 	THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_GTGSH
	,SUM(CASE WHEN CST_SEG_FLG='3' 	THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_QSYGG
	,SUM(CASE WHEN CST_SEG_FLG='4' 	THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_FCPGTH
	,SUM(CASE WHEN CST_SEG_FLG='5' 	THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_GXZ
	,SUM(CASE WHEN CST_SEG_FLG='6' 	THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_TXYL
	,SUM(CASE WHEN CST_SEG_FLG='7' 	THEN DEP_BAL_YEAR_AVG ELSE 0 END) DEP_Y_AVG_CJNX

	,COUNT(CASE WHEN IS_32W='1' 	 AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_32W
	,COUNT(CASE WHEN CST_SEG_FLG='1' AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_QYZ
	,COUNT(CASE WHEN CST_SEG_FLG='2' AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_GTGSH
	,COUNT(CASE WHEN CST_SEG_FLG='3' AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_QSYGG
	,COUNT(CASE WHEN CST_SEG_FLG='4' AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_FCPGTH
	,COUNT(CASE WHEN CST_SEG_FLG='5' AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_GXZ
	,COUNT(CASE WHEN CST_SEG_FLG='6' AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_TXYL
	,COUNT(CASE WHEN CST_SEG_FLG='7' AND IS_INSU_CST='1' THEN CST_ID END) 	INSU_CUSTS_CJNX
	,SUM(CASE WHEN IS_32W='1' 		THEN INSU_AMT ELSE 0 END) INSU_AMT_32W
	,SUM(CASE WHEN CST_SEG_FLG='1' 	THEN INSU_AMT ELSE 0 END) INSU_AMT_QYZ
	,SUM(CASE WHEN CST_SEG_FLG='2' 	THEN INSU_AMT ELSE 0 END) INSU_AMT_GTGSH
	,SUM(CASE WHEN CST_SEG_FLG='3' 	THEN INSU_AMT ELSE 0 END) INSU_AMT_QSYGG
	,SUM(CASE WHEN CST_SEG_FLG='4' 	THEN INSU_AMT ELSE 0 END) INSU_AMT_FCPGTH
	,SUM(CASE WHEN CST_SEG_FLG='5' 	THEN INSU_AMT ELSE 0 END) INSU_AMT_GXZ
	,SUM(CASE WHEN CST_SEG_FLG='6' 	THEN INSU_AMT ELSE 0 END) INSU_AMT_TXYL
	,SUM(CASE WHEN CST_SEG_FLG='7' 	THEN INSU_AMT ELSE 0 END) INSU_AMT_CJNX

	,COUNT(CASE WHEN IS_32W='1' 	 AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_32W
	,COUNT(CASE WHEN CST_SEG_FLG='1' AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_QYZ
	,COUNT(CASE WHEN CST_SEG_FLG='2' AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_GTGSH
	,COUNT(CASE WHEN CST_SEG_FLG='3' AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_QSYGG
	,COUNT(CASE WHEN CST_SEG_FLG='4' AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_FCPGTH
	,COUNT(CASE WHEN CST_SEG_FLG='5' AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_GXZ
	,COUNT(CASE WHEN CST_SEG_FLG='6' AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_TXYL
	,COUNT(CASE WHEN CST_SEG_FLG='7' AND IS_FNC_CST='1' THEN CST_ID END) 	FNC_CUSTS_CJNX
	,SUM(CASE WHEN IS_32W='1' 		THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_32W
	,SUM(CASE WHEN CST_SEG_FLG='1' 	THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_QYZ
	,SUM(CASE WHEN CST_SEG_FLG='2' 	THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_GTGSH
	,SUM(CASE WHEN CST_SEG_FLG='3' 	THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_QSYGG
	,SUM(CASE WHEN CST_SEG_FLG='4' 	THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_FCPGTH
	,SUM(CASE WHEN CST_SEG_FLG='5' 	THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_GXZ
	,SUM(CASE WHEN CST_SEG_FLG='6' 	THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_TXYL
	,SUM(CASE WHEN CST_SEG_FLG='7' 	THEN FNC_BAL_Y_AVG ELSE 0 END) FNC_BAL_Y_AVG_CJNX

	,COUNT(CASE WHEN IS_32W='1' 	 AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_32W
	,COUNT(CASE WHEN CST_SEG_FLG='1' AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_QYZ
	,COUNT(CASE WHEN CST_SEG_FLG='2' AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_GTGSH
	,COUNT(CASE WHEN CST_SEG_FLG='3' AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_QSYGG
	,COUNT(CASE WHEN CST_SEG_FLG='4' AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_FCPGTH
	,COUNT(CASE WHEN CST_SEG_FLG='5' AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_GXZ
	,COUNT(CASE WHEN CST_SEG_FLG='6' AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_TXYL
	,COUNT(CASE WHEN CST_SEG_FLG='7' AND IS_GG_FNC_CST='1' THEN CST_ID END) GG_FNC_CUSTS_CJNX
	,SUM(CASE WHEN IS_32W='1' 		THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_32W
	,SUM(CASE WHEN CST_SEG_FLG='1' 	THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_QYZ
	,SUM(CASE WHEN CST_SEG_FLG='2' 	THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_GTGSH
	,SUM(CASE WHEN CST_SEG_FLG='3' 	THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_QSYGG
	,SUM(CASE WHEN CST_SEG_FLG='4' 	THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_FCPGTH
	,SUM(CASE WHEN CST_SEG_FLG='5' 	THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_GXZ
	,SUM(CASE WHEN CST_SEG_FLG='6' 	THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_TXYL
	,SUM(CASE WHEN CST_SEG_FLG='7' 	THEN GG_FNC_BAL_Y_AVG ELSE 0 END) GG_FNC_BAL_Y_AVG_CJNX

	,COUNT(CASE WHEN IS_32W='1' 	 AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_32W
	,COUNT(CASE WHEN CST_SEG_FLG='1' AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_QYZ
	,COUNT(CASE WHEN CST_SEG_FLG='2' AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_GTGSH
	,COUNT(CASE WHEN CST_SEG_FLG='3' AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_QSYGG
	,COUNT(CASE WHEN CST_SEG_FLG='4' AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_FCPGTH
	,COUNT(CASE WHEN CST_SEG_FLG='5' AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_GXZ
	,COUNT(CASE WHEN CST_SEG_FLG='6' AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_TXYL
	,COUNT(CASE WHEN CST_SEG_FLG='7' AND GOLD_BAL>0 THEN CST_ID END) GOLD_CUSTS_CJNX
	,SUM(CASE WHEN IS_32W='1' 		THEN GOLD_BAL ELSE 0 END) GOLD_BAL_32W
	,SUM(CASE WHEN CST_SEG_FLG='1' 	THEN GOLD_BAL ELSE 0 END) GOLD_BAL_QYZ
	,SUM(CASE WHEN CST_SEG_FLG='2' 	THEN GOLD_BAL ELSE 0 END) GOLD_BAL_GTGSH
	,SUM(CASE WHEN CST_SEG_FLG='3' 	THEN GOLD_BAL ELSE 0 END) GOLD_BAL_QSYGG
	,SUM(CASE WHEN CST_SEG_FLG='4' 	THEN GOLD_BAL ELSE 0 END) GOLD_BAL_FCPGTH
	,SUM(CASE WHEN CST_SEG_FLG='5' 	THEN GOLD_BAL ELSE 0 END) GOLD_BAL_GXZ
	,SUM(CASE WHEN CST_SEG_FLG='6' 	THEN GOLD_BAL ELSE 0 END) GOLD_BAL_TXYL
	,SUM(CASE WHEN CST_SEG_FLG='7' 	THEN GOLD_BAL ELSE 0 END) GOLD_BAL_CJNX

	,SUM(CASE WHEN LOAN_BAL_ACS>0 THEN INSU_MID_INC ELSE 0 END) LOAN_INSU_MID_INC
	,SUM(CASE WHEN LOAN_BAL_ACS>0 THEN GOLD_INCM ELSE 0 END) 	LOAN_GOLD_MID_INC
	,COUNT(CASE WHEN EFE_DEP_CST_IND='1' THEN CST_ID END) 		DEP_VLD_CUSTS
FROM TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_10
WHERE PRM_MGR_ID<>''	--剔除无管户客户
GROUP BY PRM_MGR_ID
;
--结果表
DROP TABLE  IF EXISTS 		TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_12;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_12 AS
SELECT T1.EMPE_ID         		工号
	,T1.EMPE_NM           		姓名
	,T1.EMPE_AGE          		年龄
	,T1.JOIN_AGE          		入行年限
	,T1.HI_ACDM_DEG       		学历
	,T1.BRC_ORG_NM        		分行
	,T1.SBR_ORG_NM        		支行
	,T1.TEM_ORG_NM        		团队
	,T1.POS_NM            		岗位
	,T2.MNG_CUSTS         		主管户客户数
	,T2.DEP_CUSTS				存款客户数
	,T2.DEP_BAL					存款户余额
	,T2.LOAN_CUSTS				贷款客户数
	,T2.LOAN_BAL				贷款户余额
	,T2.DEP_BAL_YEAR_AVG		存款年日均
	,T2.LOAN_BAL_YEAR_AVG		贷款年日均
	,T2.INSU_CUSTS				保险客户数
	,T2.INSU_AMT				保险规模
	,T2.INSU_NUM				保险件数
	,T2.INSU_MID_INC			保险中收
	,T2.INSU_LOAN_CUSTS			保险客户贷款户户数
	,T2.LOAN_INSU_AMT			贷款户保险规模
	,T2.INSU_CUSTS_22			保险客户数2022
	,T2.INSU_AMT_22				保险规模2022
	,T2.INSU_NUM_22				保险件数2022
	,T2.INSU_MID_INC_22			保险中收2022
	,T2.FNC_BAL					理财余额
	,T2.FNC_BAL_LSTY			理财余额较年初
	,T2.FNC_BAL_Y_AVG			理财年日均
	,T2.FNC_BAL_Y_AVG_LSTY		理财年日均较年初
	,T2.DEP_CUSTS_32W			32万小微企业主存款客户数
	,T2.DEP_BAL_YEAR_AVG_32W	32万小微企业主年日均存款1
	,T2.LOAN_CUSTS_32W			32万小微企业主贷款客户数
	,T2.LOAN_BAL_YEAR_AVG_32W	32万小微企业主年日均贷款
	,T2.FNC_CUSTS				理财客户数
	,T2.FNC_MID_INCM			理财中收
	,T2.GG_FNC_CUSTS			挂钩理财客户数
	,T2.GG_FNC_BAL_Y_AVG		挂钩理财年日均规模
	,T2.GG_FNC_MID_INCM			挂钩理财中收
	,T2.GG_FNC_LOAN_CUSTS		挂钩理财贷款户户数
	,T2.LOAN_GG_FNC_BAL			贷款户挂钩理财规模
	,T2.GOLD_CUSTS				贵金属客户数
	,T2.GOLD_BAL				贵金属规模
	,T2.GOLD_NUM				贵金属件数
	,T2.GOLD_INCM				贵金属中收
	,T2.LOAN_GOLD_CUSTS			贵金属贷款户户数
	,T2.LOAN_GOLD_BAL			贷款户贵金属规模
	,T2.GRD1_CUSTS				一星客户数
	,T2.GRD2_CUSTS				二星客户数
	,T2.GRD3_CUSTS				三星客户数
	,T2.GRD4_CUSTS				四星客户数
	,T2.GRD5_CUSTS				五星客户数
	,T2.GRD6_CUSTS				六星客户数
	,T2.GRD1_AUM_Y_AVG			一星客户AUM年日均
	,T2.GRD2_AUM_Y_AVG			二星客户AUM年日均
	,T2.GRD3_AUM_Y_AVG			三星客户AUM年日均
	,T2.GRD4_AUM_Y_AVG			四星客户AUM年日均
	,T2.GRD5_AUM_Y_AVG			五星客户AUM年日均
	,T2.GRD6_AUM_Y_AVG			六星客户AUM年日均
	,T2.GRD1_WLTH_Y_AVG			一星客户财富AUM年日均
	,T2.GRD2_WLTH_Y_AVG			二星客户财富AUM年日均
	,T2.GRD3_WLTH_Y_AVG			三星客户财富AUM年日均
	,T2.GRD4_WLTH_Y_AVG			四星客户财富AUM年日均
	,T2.GRD5_WLTH_Y_AVG			五星客户财富AUM年日均
	,T2.GRD6_WLTH_Y_AVG			六星客户财富AUM年日均
	,T2.GRD1_32W_CUSTS			一星32万小微企业主客户数
	,T2.GRD2_32W_CUSTS			二星32万小微企业主客户数
	,T2.GRD3_32W_CUSTS			三星32万小微企业主客户数
	,T2.GRD4_32W_CUSTS			四星32万小微企业主客户数
	,T2.GRD5_32W_CUSTS			五星32万小微企业主客户数
	,T2.GRD6_32W_CUSTS			六星32万小微企业主客户数
	,T2.GRD1_32W_AUM_Y_AVG		一星32万小微企业主客户AUM年日均
	,T2.GRD2_32W_AUM_Y_AVG		二星32万小微企业主客户AUM年日均
	,T2.GRD3_32W_AUM_Y_AVG		三星32万小微企业主客户AUM年日均
	,T2.GRD4_32W_AUM_Y_AVG		四星32万小微企业主客户AUM年日均
	,T2.GRD5_32W_AUM_Y_AVG		五星32万小微企业主客户AUM年日均
	,T2.GRD6_32W_AUM_Y_AVG		六星32万小微企业主客户AUM年日均
	,T2.GRD1_32W_WLTH_Y_AVG		一星32万小微企业主客户财富AUM年日均
	,T2.GRD2_32W_WLTH_Y_AVG		二星32万小微企业主客户财富AUM年日均
	,T2.GRD3_32W_WLTH_Y_AVG		三星32万小微企业主客户财富AUM年日均
	,T2.GRD4_32W_WLTH_Y_AVG		四星32万小微企业主客户财富AUM年日均
	,T2.GRD5_32W_WLTH_Y_AVG		五星32万小微企业主客户财富AUM年日均
	,T2.GRD6_32W_WLTH_Y_AVG		六星32万小微企业主客户财富AUM年日均
	,T2.GRD1_INSU_CUSTS			一星保险客户数
	,T2.GRD2_INSU_CUSTS			二星保险客户数
	,T2.GRD3_INSU_CUSTS			三星保险客户数
	,T2.GRD4_INSU_CUSTS			四星保险客户数
	,T2.GRD5_INSU_CUSTS			五星保险客户数
	,T2.GRD6_INSU_CUSTS			六星保险客户数
	,T2.GRD1_INSU_AUM_Y_AVG		一星保险客户AUM年日均
	,T2.GRD2_INSU_AUM_Y_AVG		二星保险客户AUM年日均
	,T2.GRD3_INSU_AUM_Y_AVG		三星保险客户AUM年日均
	,T2.GRD4_INSU_AUM_Y_AVG		四星保险客户AUM年日均
	,T2.GRD5_INSU_AUM_Y_AVG		五星保险客户AUM年日均
	,T2.GRD6_INSU_AUM_Y_AVG		六星保险客户AUM年日均
	,T2.GRD1_INSU_WLTH_Y_AVG	一星保险客户财富AUM年日均
	,T2.GRD2_INSU_WLTH_Y_AVG	二星保险客户财富AUM年日均
	,T2.GRD3_INSU_WLTH_Y_AVG	三星保险客户财富AUM年日均
	,T2.GRD4_INSU_WLTH_Y_AVG	四星保险客户财富AUM年日均
	,T2.GRD5_INSU_WLTH_Y_AVG	五星保险客户财富AUM年日均
	,T2.GRD6_INSU_WLTH_Y_AVG	六星保险客户财富AUM年日均
	,T2.GRD1_FNC_CUSTS			一星理财客户数
	,T2.GRD2_FNC_CUSTS			二星理财客户数
	,T2.GRD3_FNC_CUSTS			三星理财客户数
	,T2.GRD4_FNC_CUSTS			四星理财客户数
	,T2.GRD5_FNC_CUSTS			五星理财客户数
	,T2.GRD6_FNC_CUSTS			六星理财客户数
	,T2.GRD1_FNC_AUM_Y_AVG		一星理财客户AUM年日均
	,T2.GRD2_FNC_AUM_Y_AVG		二星理财客户AUM年日均
	,T2.GRD3_FNC_AUM_Y_AVG		三星理财客户AUM年日均
	,T2.GRD4_FNC_AUM_Y_AVG		四星理财客户AUM年日均
	,T2.GRD5_FNC_AUM_Y_AVG		五星理财客户AUM年日均
	,T2.GRD6_FNC_AUM_Y_AVG		六星理财客户AUM年日均
	,T2.GRD1_FNC_WLTH_Y_AVG		一星理财客户财富AUM年日均
	,T2.GRD2_FNC_WLTH_Y_AVG		二星理财客户财富AUM年日均
	,T2.GRD3_FNC_WLTH_Y_AVG		三星理财客户财富AUM年日均
	,T2.GRD4_FNC_WLTH_Y_AVG		四星理财客户财富AUM年日均
	,T2.GRD5_FNC_WLTH_Y_AVG		五星理财客户财富AUM年日均
	,T2.GRD6_FNC_WLTH_Y_AVG		六星理财客户财富AUM年日均
	,T2.GRD1_GOLD_CUSTS			一星贵金属客户数
	,T2.GRD2_GOLD_CUSTS			二星贵金属客户数
	,T2.GRD3_GOLD_CUSTS			三星贵金属客户数
	,T2.GRD4_GOLD_CUSTS			四星贵金属客户数
	,T2.GRD5_GOLD_CUSTS			五星贵金属客户数
	,T2.GRD6_GOLD_CUSTS			六星贵金属客户数
	,T2.GRD1_GOLD_AUM_Y_AVG		一星贵金属客户AUM年日均
	,T2.GRD2_GOLD_AUM_Y_AVG		二星贵金属客户AUM年日均
	,T2.GRD3_GOLD_AUM_Y_AVG		三星贵金属客户AUM年日均
	,T2.GRD4_GOLD_AUM_Y_AVG		四星贵金属客户AUM年日均
	,T2.GRD5_GOLD_AUM_Y_AVG		五星贵金属客户AUM年日均
	,T2.GRD6_GOLD_AUM_Y_AVG		六星贵金属客户AUM年日均
	,T2.GRD1_GOLD_WLTH_Y_AVG	一星贵金属客户财富AUM年日均
	,T2.GRD2_GOLD_WLTH_Y_AVG	二星贵金属客户财富AUM年日均
	,T2.GRD3_GOLD_WLTH_Y_AVG	三星贵金属客户财富AUM年日均
	,T2.GRD4_GOLD_WLTH_Y_AVG	四星贵金属客户财富AUM年日均
	,T2.GRD5_GOLD_WLTH_Y_AVG	五星贵金属客户财富AUM年日均
	,T2.GRD6_GOLD_WLTH_Y_AVG	六星贵金属客户财富AUM年日均
	,T2.CUSTS_32W				32万小微企业主客户数
	,T2.CUSTS_QYZ				企业主客户数
	,T2.CUSTS_GTGSH				个体工商户客户数
	,T2.CUSTS_QSYGG				企事业高管客户数
	,T2.CUSTS_FCPGTH			非持牌个体户客户数
	,T2.CUSTS_GXZ				工薪族客户数
	,T2.CUSTS_TXYL				退休养老客户数
	,T2.CUSTS_CJNX				持家女性客户数
	,T2.AUM_Y_AVG_32W			32万小微企业主客户AUM年日均
	,T2.AUM_Y_AVG_QYZ			企业主客户AUM年日均
	,T2.AUM_Y_AVG_GTGSH			个体工商户客户AUM年日均
	,T2.AUM_Y_AVG_QSYGG			企事业高管客户AUM年日均
	,T2.AUM_Y_AVG_FCPGTH		非持牌个体户客户AUM年日均
	,T2.AUM_Y_AVG_GXZ			工薪族客户AUM年日均
	,T2.AUM_Y_AVG_TXYL			退休养老客户AUM年日均
	,T2.AUM_Y_AVG_CJNX			持家女性客户AUM年日均
	,T2.WLTH_CUSTS_32W			32万小微企业主财富客户数
	,T2.WLTH_CUSTS_QYZ			企业主财富客户数
	,T2.WLTH_CUSTS_GTGSH		个体工商户财富客户数
	,T2.WLTH_CUSTS_QSYGG		企事业高管财富客户数
	,T2.WLTH_CUSTS_FCPGTH		非持牌个体户财富客户数
	,T2.WLTH_CUSTS_GXZ			工薪族财富客户数
	,T2.WLTH_CUSTS_TXYL			退休养老财富客户数
	,T2.WLTH_CUSTS_CJNX			持家女性财富客户数
	,T2.WLTH_Y_AVG_32W			32万小微企业主客户财富AUM年日均
	,T2.WLTH_Y_AVG_QYZ			企业主客户财富AUM年日均
	,T2.WLTH_Y_AVG_GTGSH		个体工商户客户财富AUM年日均
	,T2.WLTH_Y_AVG_QSYGG		企事业高管客户财富AUM年日均
	,T2.WLTH_Y_AVG_FCPGTH		非持牌个体户客户财富AUM年日均
	,T2.WLTH_Y_AVG_GXZ			工薪族客户财富AUM年日均
	,T2.WLTH_Y_AVG_TXYL			退休养老客户财富AUM年日均
	,T2.WLTH_Y_AVG_CJNX			持家女性客户财富AUM年日均
	,T2.DEP_CUSTS_QYZ			企业主存款客户数
	,T2.DEP_CUSTS_GTGSH			个体工商户存款客户数
	,T2.DEP_CUSTS_QSYGG			企事业高管存款客户数
	,T2.DEP_CUSTS_FCPGTH		非持牌个体户存款客户数
	,T2.DEP_CUSTS_GXZ			工薪族存款客户数
	,T2.DEP_CUSTS_TXYL			退休养老存款客户数
	,T2.DEP_CUSTS_CJNX			持家女性存款客户数
	,T2.DEP_Y_AVG_32W			32万小微企业主客户存款年日均
	,T2.DEP_Y_AVG_QYZ			企业主客户存款年日均
	,T2.DEP_Y_AVG_GTGSH			个体工商户客户存款年日均
	,T2.DEP_Y_AVG_QSYGG			企事业高管客户存款年日均
	,T2.DEP_Y_AVG_FCPGTH		非持牌个体户客户存款年日均
	,T2.DEP_Y_AVG_GXZ			工薪族客户存款年日均
	,T2.DEP_Y_AVG_TXYL			退休养老客户存款年日均
	,T2.DEP_Y_AVG_CJNX			持家女性客户存款年日均
	,T2.INSU_CUSTS_32W			32万小微企业主保险客户数
	,T2.INSU_CUSTS_QYZ			企业主保险客户数
	,T2.INSU_CUSTS_GTGSH		个体工商户保险客户数
	,T2.INSU_CUSTS_QSYGG		企事业高管保险客户数
	,T2.INSU_CUSTS_FCPGTH		非持牌个体户保险客户数
	,T2.INSU_CUSTS_GXZ			工薪族保险客户数
	,T2.INSU_CUSTS_TXYL			退休养老保险客户数
	,T2.INSU_CUSTS_CJNX			持家女性保险客户数
	,T2.INSU_AMT_32W			32万小微企业主客户保险规模
	,T2.INSU_AMT_QYZ			企业主客户保险规模
	,T2.INSU_AMT_GTGSH			个体工商户客户保险规模
	,T2.INSU_AMT_QSYGG			企事业高管客户保险规模
	,T2.INSU_AMT_FCPGTH			非持牌个体户客户保险规模
	,T2.INSU_AMT_GXZ			工薪族客户保险规模
	,T2.INSU_AMT_TXYL			退休养老客户保险规模
	,T2.INSU_AMT_CJNX			持家女性客户保险规模
	,T2.FNC_CUSTS_32W			32万小微企业主理财客户数
	,T2.FNC_CUSTS_QYZ			企业主理财客户数
	,T2.FNC_CUSTS_GTGSH			个体工商户理财客户数
	,T2.FNC_CUSTS_QSYGG			企事业高管理财客户数
	,T2.FNC_CUSTS_FCPGTH		非持牌个体户理财客户数
	,T2.FNC_CUSTS_GXZ			工薪族理财客户数
	,T2.FNC_CUSTS_TXYL			退休养老理财客户数
	,T2.FNC_CUSTS_CJNX			持家女性理财客户数
	,T2.FNC_BAL_Y_AVG_32W		32万小微企业主客户理财年日均
	,T2.FNC_BAL_Y_AVG_QYZ		企业主客户理财年日均
	,T2.FNC_BAL_Y_AVG_GTGSH		个体工商户客户理财年日均
	,T2.FNC_BAL_Y_AVG_QSYGG		企事业高管客户理财年日均
	,T2.FNC_BAL_Y_AVG_FCPGTH	非持牌个体户客户理财年日均
	,T2.FNC_BAL_Y_AVG_GXZ		工薪族客户理财年日均
	,T2.FNC_BAL_Y_AVG_TXYL		退休养老客户理财年日均
	,T2.FNC_BAL_Y_AVG_CJNX		持家女性客户理财年日均
	,T2.GG_FNC_CUSTS_32W		32万小微企业主挂钩理财客户数
	,T2.GG_FNC_CUSTS_QYZ		企业主挂钩理财客户数
	,T2.GG_FNC_CUSTS_GTGSH		个体工商户挂钩理财客户数
	,T2.GG_FNC_CUSTS_QSYGG		企事业高管挂钩理财客户数
	,T2.GG_FNC_CUSTS_FCPGTH		非持牌个体户挂钩理财客户数
	,T2.GG_FNC_CUSTS_GXZ		工薪族挂钩理财客户数
	,T2.GG_FNC_CUSTS_TXYL		退休养老挂钩理财客户数
	,T2.GG_FNC_CUSTS_CJNX		持家女性挂钩理财客户数
	,T2.GG_FNC_BAL_Y_AVG_32W	32万小微企业主客户挂钩理财年日均
	,T2.GG_FNC_BAL_Y_AVG_QYZ	企业主客户挂钩理财年日均
	,T2.GG_FNC_BAL_Y_AVG_GTGSH	个体工商户客户挂钩理财年日均
	,T2.GG_FNC_BAL_Y_AVG_QSYGG	企事业高管客户挂钩理财年日均
	,T2.GG_FNC_BAL_Y_AVG_FCPGTH	非持牌个体户客户挂钩理财年日均
	,T2.GG_FNC_BAL_Y_AVG_GXZ	工薪族客户挂钩理财年日均
	,T2.GG_FNC_BAL_Y_AVG_TXYL	退休养老客户挂钩理财年日均
	,T2.GG_FNC_BAL_Y_AVG_CJNX	持家女性客户挂钩理财年日均
	,T2.GOLD_CUSTS_32W			32万小微企业主贵金属客户数
	,T2.GOLD_CUSTS_QYZ			企业主贵金属客户数
	,T2.GOLD_CUSTS_GTGSH		个体工商户贵金属客户数
	,T2.GOLD_CUSTS_QSYGG		企事业高管贵金属客户数
	,T2.GOLD_CUSTS_FCPGTH		非持牌个体户贵金属客户数
	,T2.GOLD_CUSTS_GXZ			工薪族贵金属客户数
	,T2.GOLD_CUSTS_TXYL			退休养老贵金属客户数
	,T2.GOLD_CUSTS_CJNX			持家女性贵金属客户数
	,T2.GOLD_BAL_32W			32万小微企业主客户贵金属规模
	,T2.GOLD_BAL_QYZ			企业主客户贵金属规模
	,T2.GOLD_BAL_GTGSH			个体工商户客户贵金属规模
	,T2.GOLD_BAL_QSYGG			企事业高管客户贵金属规模
	,T2.GOLD_BAL_FCPGTH			非持牌个体户客户贵金属规模
	,T2.GOLD_BAL_GXZ			工薪族客户贵金属规模
	,T2.GOLD_BAL_TXYL			退休养老客户贵金属规模
	,T2.GOLD_BAL_CJNX			持家女性客户贵金属规模
	,T2.LOAN_INSU_MID_INC		贷款户保险中收
	,T2.LOAN_GOLD_MID_INC		贷款户贵金属中收
	,T2.DEP_VLD_CUSTS			存款有效户户数
FROM TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_01		T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_11 	T2
ON T1.EMPE_ID = T2.PRM_MGR_ID
;

--结果表：27621
SELECT  *
from TLDATA_DEV.SJXQ_SJ2023111056_CST_ZYP_12
;
**SJ2023111331_code.sql
-- odps sql
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 耿延鹏
-- 创建日期: 2023-11-14 14:20:30
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
/* 截止20231031 全行不含村行，有效客户清单
1. 年日均存款30万以上，有效财富户
2. 年日均活期存款5万以上，女性客户30-50岁
3. 年日均活期存款10万以上，男性经营客户30-60岁
*/
select count(1) cnt,count(distinct 客户号) custs -- 15886
from tldata_dev.sjxq_sj2023111331_qztzj_cst_zyp_01
;

select count(1) cnt,count(distinct 客户号) custs -- 30914
from tldata_dev.sjxq_sj2023111331_qzssj_cst_zyp_02
;

select count(1) cnt,count(distinct 客户号) custs -- 27010
from tldata_dev.sjxq_sj2023111331_qzgyj_cst_zyp_03
;


-- 需求1
-- 客户名字	客户号	联系电话	年龄	管护客户经理	工号	所在支行（到业务团队）	所在分行（中文）
drop  table  if exists tldata_dev.sjxq_sj2023111331_qztzj_cst_zyp_01;
create  table if not exists tldata_dev.sjxq_sj2023111331_qztzj_cst_zyp_01 as
select  t.cst_chn_nm    as 客户名字
    ,t.cst_id           as 客户号
    ,''                 as 联系电话
    ,t.age              as 年龄
    ,t2.prm_mgr_nm      as 管护客户经理
    ,t2.prm_mgr_id      as 工号
    ,t3.org_nm          as 所在支行
    ,t3.brc_org_nm      as 所在分行
from    adm_pub.adm_csm_cbas_idv_bas_inf_dd t --客户基础信息汇总表
inner join adm_pub.adm_csm_cbas_ind_inf_dd t1
on t.cst_id=t1.cst_id
and t1.dt='20231031'
and t1.efe_wlth_cst_ind='1' -- 有效财富户
left join   adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t2 --管户表
on      t.cst_id = t2.cst_id
and     t2.dt = '20231031'
left join   edw.dim_hr_org_mng_org_tree_dd t3
on      t3.org_id = t2.prm_org_id
and     t3.dt = '20231031'
inner join adm_pub.adm_csm_cbus_dep_inf_dd t4
on t.cst_id=t4.cst_id
and t4.dt='20231031'
and t4.dep_bal_year_avg>=300000 -- 年日均存款30万以上
where   t.dt = '20231031'
and     t3.cpy_org_id = '999999998' --法人机构：浙江泰隆商业银行股份有限公司(剔除村行)
;

-- 需求2
-- 客户名字	客户号	联系电话	年龄	管护客户经理	工号	所在支行（到业务团队）	所在分行（中文）
drop  table  if exists tldata_dev.sjxq_sj2023111331_qzssj_cst_zyp_02;
create  table if not exists tldata_dev.sjxq_sj2023111331_qzssj_cst_zyp_02 as
select  t.cst_chn_nm    as 客户名字
    ,t.cst_id           as 客户号
    ,''                 as 联系电话
    ,t.age              as 年龄
    ,t2.prm_mgr_nm      as 管护客户经理
    ,t2.prm_mgr_id      as 工号
    ,t3.org_nm          as 所在支行
    ,t3.brc_org_nm      as 所在分行
from    adm_pub.adm_csm_cbas_idv_bas_inf_dd t --客户基础信息汇总表
inner join adm_pub.adm_csm_cbas_ind_inf_dd t1
on t.cst_id=t1.cst_id
and t1.dt='20231031'
and t1.efe_cst_ind='1' -- 有效客户
left join    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t2 --管户表
on      t.cst_id = t2.cst_id
and     t2.dt = '20231031'
left join    edw.dim_hr_org_mng_org_tree_dd t3
on      t3.org_id = t2.prm_org_id
and     t3.dt = '20231031'
inner join adm_pub.adm_csm_cbus_dep_inf_dd t4
on t.cst_id=t4.cst_id
and t4.dt='20231031'
and t4.dmnd_dep_bal_year_avg>=50000 -- 年日均活期存款5万以上
where   t.dt = '20231031'
and t.gdr_cd='2' -- 女性
and t.age between 30 and 50
and     t3.cpy_org_id = '999999998' --法人机构：浙江泰隆商业银行股份有限公司(剔除村行)
;

-- 需求3
-- 客户名字	客户号	联系电话	年龄	管护客户经理	工号	所在支行（到业务团队）	所在分行（中文）
drop  table  if exists tldata_dev.sjxq_sj2023111331_qzgyj_cst_zyp_03;
create  table if not exists tldata_dev.sjxq_sj2023111331_qzgyj_cst_zyp_03 as
select  t.cst_chn_nm    as 客户名字
    ,t.cst_id           as 客户号
    ,''                 as 联系电话
    ,t.age              as 年龄
    ,t2.prm_mgr_nm      as 管护客户经理
    ,t2.prm_mgr_id      as 工号
    ,t3.org_nm          as 所在支行
    ,t3.brc_org_nm      as 所在分行
from    adm_pub.adm_csm_cbas_idv_bas_inf_dd t --客户基础信息汇总表
inner join adm_pub.adm_csm_cbas_ind_inf_dd t1
on t.cst_id=t1.cst_id
and t1.dt='20231031'
and t1.efe_cst_ind='1' -- 有效客户
left join  adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t2 --管户表
on      t.cst_id = t2.cst_id
and     t2.dt = '20231031'
left join    edw.dim_hr_org_mng_org_tree_dd t3
on      t3.org_id = t2.prm_org_id
and     t3.dt = '20231031'
inner join adm_pub.adm_csm_cbus_dep_inf_dd t4
on t.cst_id=t4.cst_id
and t4.dt='20231031'
and t4.dmnd_dep_bal_year_avg>=100000 -- 年日均活期存款10万以上
inner join    adm_pub.adm_csm_clab_cst_jc_inf_dd t6 		-- 客户集市-客户标签信息-客户信息
on      t.cst_id = t6.cst_id
and     t6.dt = '20231031'
and     t6.cst_seg_flg in('1','2','3','4') -- 经营客户 ,decode(t6.cst_seg_flg, '1', '企业主', '2', '个体工商户', '3', '企事业高管', '4', '非持牌个体户', '5', '工薪族', '6', '退休养老', '7', '持家女性', '未知')
where   t.dt = '20231031'
and t.gdr_cd='1' -- 男性
and t.age between 30 and 60
and     t3.cpy_org_id = '999999998' --法人机构：浙江泰隆商业银行股份有限公司(剔除村行)
;
**SJ2023111741_code2.sql
--存款交易维度：到期日期在2024
-- CST_ID 到期日期 定存期限 定存余额  --> CST_ID,存款3年以下余额 存款3年及以上余额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01 AS
SELECT CST_ID					--客户号
	,SUM(CASE WHEN DEP_TRM IN('12M','18M','1Y','24M','2Y','3M','6M')
		THEN CUR_ACT_BAL ELSE 0 END) REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN DEP_TRM IN('36M','3Y','5Y')
		THEN CUR_ACT_BAL ELSE 0 END) REGU_DEP_BAL_MORE_3
FROM EDW.DWS_BUS_DEP_ACT_INF_DD		-- 存款账户信息表
WHERE DT='20231031'
AND CUR_ACT_BAL>0
AND MTU_DT>='20240101'
AND MTU_DT<='20241231'
GROUP BY CST_ID
;


--理财交易维度：到期日期在2024
-- CST_ID 到期日期 理财期限 理财余额  --> CST_ID,理财6月及以上余额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02 AS
SELECT A.CST_ID					--客户号
	,SUM(CASE WHEN B.TRX_MTH_CD = '0' THEN A.FNC_AMT ELSE 0 END)  	AS OPN_FNC_BAL --开放式理财产品余额 活期理财
	,SUM(CASE WHEN DATEDIFF(TO_DATE(B.PD_END_DT, 'YYYYMMDD'),TO_DATE(B.PD_VAL_DT, 'YYYYMMDD'),'DD')>=180
					AND B.PD_END_DT>='20240101' AND B.PD_END_DT<='20241231'
		THEN A.FNC_AMT ELSE 0 END) 									AS MLONG_FNC_BAL
FROM EDW.DWS_BUS_CHM_ACT_ACM_INF_DD	 	A	--理财账户份额汇总信息
INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 	B	--理财产品信息
ON 	A.PD_CD=B.PD_CD
AND B.DT='20231031'
WHERE A.DT='20231031'
AND A.FNC_AMT>0
GROUP BY A.CST_ID
;

--字段：CST_ID,活期存款 年龄 活期存款年日均 有效存款户 是否32万小企业主 是否经营户	是否工薪
-- 财富等级 是否客户经理	是否服务经理
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03 AS
SELECT A.CST_ID
	,A.AGE
	,B.DMND_DEP_BAL							--活期存款余额
	,B.DMND_DEP_BAL_MON_AVG 				--活期存款月日均
	,CASE WHEN CST_SEG_FLG IN('1','2')
		THEN 1 ELSE 0 END IS_OPERATE		--经营户（1企业主+2个体工商户）
	,CASE WHEN CST_SEG_FLG='5' THEN 1 ELSE 0 END IS_SALARY
	,CASE WHEN D.CST_ID IS NOT NULL THEN 1 ELSE 0 END IS_32W
	,E.AUM_GRD	                			-- 财富等级
	,E.DEP_BAL_YEAR_AVG	                	-- 存款年日均
	,E.EFE_DEP_CST_IND	                	-- 有效存款户
	,E.EFE_CHM_CST_IND	                	-- 有效理财户
	,E.CHM_CST_IND	                		-- 是否理财客户
	,E.IS_HLD_CHM	                		-- 是否理财持有客户
	,CASE WHEN T4.POS_NM='客户经理'	THEN 1 ELSE 0 END IS_CST_MNG 	-- 客户经理
	,CASE WHEN T4.POS_NM='服务经理'	THEN 1 ELSE 0 END IS_SVC_MNG	-- 服务经理
FROM ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD 			A 	--客户信息表
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_DEP_INF_DD 			B	--客户存款业务信息表
ON 		A.CST_ID=B.CST_ID
AND 	B.DT='20231031'
LEFT JOIN ADM_PUB.ADM_CSM_CLAB_CST_JC_INF_DD		C	--客户标签信息
ON 		A.CST_ID=C.CST_ID
AND 	C.DT='20231031'
LEFT JOIN TLDATA_DEV.TMP_QWJ_0818_MKX_KQ 			D 	--32万企业主表
ON 		A.CST_ID=D.CST_ID
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		E	--正式客户财富业务信息表
ON 		A.CST_ID=E.CST_ID
AND 	E.DT='20231031'
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T2 	--客户主管户信息
ON      A.CST_ID = T2.CST_ID
AND     T2.DT = '20231031'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD					T3	--员工汇总信息
ON 		T2.PRM_MGR_ID = T3.EMPE_ID
AND 	T3.DT = '20231031'
LEFT JOIN EDW.DIM_HR_ORG_JOB_INF_DD					T4	--职位信息
ON 		T3.POS_ENC=T4.POS_ID
AND 	T4.DT = '20231031'
WHERE A.DT='20231031'
;

-- 字段汇总表
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04 AS
SELECT A.CST_ID
	,A.AGE
	,B.REGU_DEP_BAL_LESS_3
	,B.REGU_DEP_BAL_MORE_3
	,C.OPN_FNC_BAL
	,C.MLONG_FNC_BAL
	,A.DMND_DEP_BAL
	,A.DMND_DEP_BAL_MON_AVG
	,A.DEP_BAL_YEAR_AVG
	,A.IS_OPERATE
	,A.IS_SALARY
	,A.IS_32W
	,A.AUM_GRD
	,A.EFE_DEP_CST_IND
	,A.EFE_CHM_CST_IND
	,A.IS_CST_MNG				--是否客服经理
	,A.IS_SVC_MNG				--是否服务经理
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03 		A
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01 	B
ON A.CST_ID=B.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02 	C
ON A.CST_ID=C.CST_ID
;

--结果表
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP AS
SELECT '客户数' 	AS 		维度
	,SUM(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 								AS 24年到期定期存款小于3年
	,SUM(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 								AS 24年到期定期存款大于3年
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 					AS 活期存款
	,SUM(CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END)											AS 活期理财
	,SUM(CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)										AS 中长期理财
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					AS 32万小企业主24年到期定期存款小于3年
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					AS 32万小企业主24年到期定期存款大于3年
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 		AS 32万小企业主活期存款
	,SUM(CASE WHEN IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 32万小企业主活期理财
	,SUM(CASE WHEN IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 32万小企业主中长期理财
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				AS 经营户24年到期定期存款小于3年
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				AS 经营户24年到期定期存款大于3年
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	AS 经营户活期存款
	,SUM(CASE WHEN IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 经营户活期理财
	,SUM(CASE WHEN IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 经营户中长期理财
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				AS 工薪24年到期定期存款小于3年
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				AS 工薪24年到期定期存款大于3年
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	AS 工薪活期存款
	,SUM(CASE WHEN IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 工薪活期理财
	,SUM(CASE WHEN IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 工薪中长期理财
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT concat('客户数等级',AUM_GRD)
	,SUM(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 								MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 								MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 					CUR_DEP_CUSTS
	,SUM(CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END)											CUR_FNC_CUSTS
	,SUM(CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)										MLONG_FNC_CUSTS
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 		CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							MLONG_FNC_CUSTS_32W
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	OP_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_MLONG_FNC_CUSTS
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	SL_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							SL_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_MLONG_FNC_CUSTS
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
WHERE AUM_GRD IS NOT NULL 						-- 去除空等级客户
GROUP BY AUM_GRD
UNION ALL
SELECT '规模' TP
	,SUM(REGU_DEP_BAL_LESS_3) 												MUT_REGU_DEP_BAL_LESS_3
	,SUM(REGU_DEP_BAL_MORE_3) 												MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										CUR_DEP_BAL
	,SUM(OPN_FNC_BAL)														CUR_FNC_BAL
	,SUM(MLONG_FNC_BAL)														MLONG_FNC_BAL
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪

	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)					SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT concat('规模等级',AUM_GRD)
	,SUM(REGU_DEP_BAL_LESS_3) 												MUT_REGU_DEP_BAL_LESS_3
	,SUM(REGU_DEP_BAL_MORE_3) 												MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										CUR_DEP_BAL
	,SUM(OPN_FNC_BAL)														CUR_FNC_BAL
	,SUM(MLONG_FNC_BAL)														MLONG_FNC_BAL
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)					SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
WHERE AUM_GRD IS NOT NULL 						-- 去除空等级客户
GROUP BY AUM_GRD
UNION ALL
SELECT '客户经理-客户数' TP
	,SUM(CASE WHEN IS_CST_MNG=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN 1 ELSE 0 END) 														CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)			CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)			MLONG_FNC_CUSTS_32W
	-- 32万小企业主
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 		CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							MLONG_FNC_CUSTS_32W
	-- 经营户
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	OP_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_MLONG_FNC_CUSTS
	-- 工薪
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	SL_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_MLONG_FNC_CUSTS
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT '客户经理-规模' TP
	,SUM(CASE WHEN IS_CST_MNG=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 32万小企业主
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 										SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)					SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT '服务经理-客户数' TP
	,SUM(CASE WHEN IS_SVC_MNG=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN 1 ELSE 0 END) 														CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)			CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)			MLONG_FNC_CUSTS
	-- 32万小企业主
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 		CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							MLONG_FNC_CUSTS_32W
	-- 经营户
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	OP_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_MLONG_FNC_CUSTS
	-- 工薪
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END) 	SL_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_MLONG_FNC_CUSTS
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT '服务经理-规模' TP
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 						MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 						MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 														CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN OPN_FNC_BAL ELSE 0 END)								CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN MLONG_FNC_BAL ELSE 0 END)								MLONG_FNC_BAL_32W
	-- 32万小企业主
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 														CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 														OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <51
		THEN DMND_DEP_BAL ELSE 0 END) 														SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)				SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
;

--584025	170005	30895
SELECT  count(t1.cst_id)    定存到期客户数
,count(t2.cst_id)           理财到期客户数
,sum(case when t1.cst_id is not null and t2.cst_id is not null then 1 else 0 end)   两者均到期客户数
FROM  TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01 t1
FULL JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02 t2
on t1.cst_id=t2.cst_id
;

--重复数据去重
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05 AS
SELECT CST_ID
	,CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END 					AS IS_MUT_REGU_DEP_LESS3
	,CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END 					AS IS_MUT_REGU_DEP_MORE3
	,CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END 	AS IS_CUR_DEP
	,CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END 							AS IS_CUR_FNC
	,CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END						AS IS_MLONG_FNC

	,CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END +
		+CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END
		+CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <51 THEN 1 ELSE 0 END
		+CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END
		+CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END					AS HLD_LAB_NUM
	,IS_OPERATE
	,IS_SALARY
	,IS_32W
	,AUM_GRD
	,EFE_DEP_CST_IND
	,EFE_CHM_CST_IND
	,IS_CST_MNG				--是否客服经理
	,IS_SVC_MNG				--是否服务经理
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
;

--结果表2
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_06;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_06 AS
SELECT '客户数' 	AS 		24年保险客户大盘
	,COUNT(CASE WHEN HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
UNION ALL
SELECT CONCAT('客户数等级',AUM_GRD)
	,COUNT(CASE WHEN HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
WHERE AUM_GRD IS NOT NULL 						-- 去除空等级客户
GROUP BY AUM_GRD
UNION ALL
SELECT '客户经理-客户数' TP
	,COUNT(CASE WHEN IS_CST_MNG=1 AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
UNION ALL
SELECT '服务经理-客户数' TP
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
;

**SJ2023111741_code3.sql
-- 20231122 age<=65 and 剔除 统一风险控制号 客户
-- adm_pub.adm_csm_cbas_idv_bas_inf_dd	客户集市-客户基础-对私客户基础信息	mc_cst_id		统一风险控制号
-- app_rpt.adm_subl_cst_wlth_bus_inf_dd	正式客户财富业务信息表	efe_loan_cst_ind	string	有效贷款户

--存款交易维度：到期日期在2024
-- CST_ID 到期日期 定存期限 定存余额  --> CST_ID,存款3年以下余额 存款3年及以上余额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01 AS
SELECT CST_ID					--客户号
	,SUM(CASE WHEN DEP_TRM IN('12M','18M','1Y','24M','2Y','3M','6M')
		THEN CUR_ACT_BAL ELSE 0 END) REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN DEP_TRM IN('36M','3Y','5Y')
		THEN CUR_ACT_BAL ELSE 0 END) REGU_DEP_BAL_MORE_3
FROM EDW.DWS_BUS_DEP_ACT_INF_DD		-- 存款账户信息表
WHERE DT='20231031'
AND CUR_ACT_BAL>0
AND MTU_DT>='20240101'
AND MTU_DT<='20241231'
GROUP BY CST_ID
;


--理财交易维度：到期日期在2024
-- CST_ID 到期日期 理财期限 理财余额  --> CST_ID,理财6月及以上余额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02 AS
SELECT A.CST_ID					--客户号
	,SUM(CASE WHEN B.TRX_MTH_CD = '0' THEN A.FNC_AMT ELSE 0 END)  	AS OPN_FNC_BAL --开放式理财产品余额 活期理财
	,SUM(CASE WHEN DATEDIFF(TO_DATE(B.PD_END_DT, 'YYYYMMDD'),TO_DATE(B.PD_VAL_DT, 'YYYYMMDD'),'DD')>=180
					AND B.PD_END_DT>='20240101' AND B.PD_END_DT<='20241231'
		THEN A.FNC_AMT ELSE 0 END) 									AS MLONG_FNC_BAL
FROM EDW.DWS_BUS_CHM_ACT_ACM_INF_DD	 	A	--理财账户份额汇总信息
INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 	B	--理财产品信息
ON 	A.PD_CD=B.PD_CD
AND B.DT='20231031'
WHERE A.DT='20231031'
AND A.FNC_AMT>0
GROUP BY A.CST_ID
;

--字段：CST_ID,活期存款 年龄 活期存款年日均 有效存款户 是否32万小企业主 是否经营户	是否工薪
-- 财富等级 是否客户经理	是否服务经理
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03 AS
SELECT A.CST_ID
	,A.AGE
	,B.DMND_DEP_BAL							--活期存款余额
	,B.DMND_DEP_BAL_MON_AVG 				--活期存款月日均
	,CASE WHEN CST_SEG_FLG IN('1','2')
		THEN 1 ELSE 0 END IS_OPERATE		--经营户（1企业主+2个体工商户）
	,CASE WHEN CST_SEG_FLG='5' THEN 1 ELSE 0 END IS_SALARY
	,CASE WHEN D.CST_ID IS NOT NULL THEN 1 ELSE 0 END IS_32W
	,E.AUM_GRD	                			-- 财富等级
	,E.DEP_BAL_YEAR_AVG	                	-- 存款年日均
	,E.EFE_DEP_CST_IND	                	-- 有效存款户
	,E.EFE_CHM_CST_IND	                	-- 有效理财户
	,E.CHM_CST_IND	                		-- 是否理财客户
	,E.IS_HLD_CHM	                		-- 是否理财持有客户
	,CASE WHEN T4.POS_NM='客户经理'	THEN 1 ELSE 0 END IS_CST_MNG 	-- 客户经理
	,CASE WHEN T4.POS_NM='服务经理'	THEN 1 ELSE 0 END IS_SVC_MNG	-- 服务经理
FROM ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD 			A 	--客户信息表
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_DEP_INF_DD 			B	--客户存款业务信息表
ON 		A.CST_ID=B.CST_ID
AND 	B.DT='20231031'
LEFT JOIN ADM_PUB.ADM_CSM_CLAB_CST_JC_INF_DD		C	--客户标签信息
ON 		A.CST_ID=C.CST_ID
AND 	C.DT='20231031'
LEFT JOIN TLDATA_DEV.TMP_QWJ_0818_MKX_KQ 			D 	--32万企业主表	325315
ON 		A.CST_ID=D.CST_ID
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		E	--正式客户财富业务信息表
ON 		A.CST_ID=E.CST_ID
AND 	E.DT='20231031'
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T2 	--客户主管户信息
ON      A.CST_ID = T2.CST_ID
AND     T2.DT = '20231031'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD					T3	--员工汇总信息
ON 		T2.PRM_MGR_ID = T3.EMPE_ID
AND 	T3.DT = '20231031'
LEFT JOIN EDW.DIM_HR_ORG_JOB_INF_DD					T4	--职位信息
ON 		T3.POS_ENC=T4.POS_ID
AND 	T4.DT = '20231031'
WHERE A.DT='20231031'
;

DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 AS
SELECT 	T1.CST_ID,T1.MC_CST_ID
		,T2.efe_loan_cst_ind		-- 有效贷款户
FROM ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD 		T1
LEFT JOIN app_rpt.adm_subl_cst_wlth_bus_inf_dd 	T2
ON 	T1.CST_ID=T2.CST_ID
AND T2.DT='@@{yyyyMMdd}'
WHERE T1.DT='@@{yyyyMMdd}'
AND T1.MC_CST_ID<>'' 	-- 剔除 统一风险控制号 非空
;
/*
--运行不出来
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_08;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_08 AS
SELECT T1.CST_ID,T1.MC_CST_ID,MAX(T2.efe_loan_cst_ind) is_vld_loan
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 T2
ON T1.MC_CST_ID=T2.MC_CST_ID
GROUP BY T1.CST_ID,T1.MC_CST_ID
;
*/
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_09;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_09 AS
select t1.mc_cst_id,max(t2.efe_loan_cst_ind) is_vld_loan
from(
	select distinct MC_CST_ID
	from TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07
)t1 left join TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 t2
on t1.MC_CST_ID=t2.MC_CST_ID
group by t1.mc_cst_id
;

--统一风险控制客户
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_10;	--921864
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_10 AS
select t1.cst_id
from TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 		t1
left join TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_09 	t2
on t1.mc_cst_id=t2.mc_cst_id
where t2.is_vld_loan='1'
;


-- 字段汇总表
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04 AS
SELECT A.CST_ID
	,A.AGE
	,B.REGU_DEP_BAL_LESS_3
	,B.REGU_DEP_BAL_MORE_3
	,C.OPN_FNC_BAL
	,C.MLONG_FNC_BAL
	,A.DMND_DEP_BAL
	,A.DMND_DEP_BAL_MON_AVG
	,A.DEP_BAL_YEAR_AVG
	,A.IS_OPERATE
	,A.IS_SALARY
	,A.IS_32W
	,A.AUM_GRD
	,A.EFE_DEP_CST_IND
	,A.EFE_CHM_CST_IND
	,A.IS_CST_MNG				--是否客服经理
	,A.IS_SVC_MNG				--是否服务经理
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03 		A
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01 	B
ON A.CST_ID=B.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02 	C
ON A.CST_ID=C.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_10 	D
ON A.CST_ID=D.CST_ID
WHERE D.CST_ID IS NULL 		-- 剔除 同业风险控制下的信贷户
;

--结果表
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP AS
SELECT '客户数' 	AS 		维度
	,SUM(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 								AS 24年到期定期存款小于3年
	,SUM(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 								AS 24年到期定期存款大于3年
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 					AS 活期存款
	,SUM(CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END)											AS 活期理财
	,SUM(CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)										AS 中长期理财
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					AS 32万小企业主24年到期定期存款小于3年
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					AS 32万小企业主24年到期定期存款大于3年
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 		AS 32万小企业主活期存款
	,SUM(CASE WHEN IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 32万小企业主活期理财
	,SUM(CASE WHEN IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 32万小企业主中长期理财
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				AS 经营户24年到期定期存款小于3年
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				AS 经营户24年到期定期存款大于3年
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	AS 经营户活期存款
	,SUM(CASE WHEN IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 经营户活期理财
	,SUM(CASE WHEN IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 经营户中长期理财
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				AS 工薪24年到期定期存款小于3年
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				AS 工薪24年到期定期存款大于3年
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	AS 工薪活期存款
	,SUM(CASE WHEN IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 工薪活期理财
	,SUM(CASE WHEN IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 工薪中长期理财
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT concat('客户数等级',AUM_GRD)
	,SUM(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 								MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 								MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 					CUR_DEP_CUSTS
	,SUM(CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END)											CUR_FNC_CUSTS
	,SUM(CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)										MLONG_FNC_CUSTS
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 		CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							MLONG_FNC_CUSTS_32W
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	OP_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_MLONG_FNC_CUSTS
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	SL_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							SL_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_MLONG_FNC_CUSTS
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
WHERE AUM_GRD IS NOT NULL 						-- 去除空等级客户
GROUP BY AUM_GRD
UNION ALL
SELECT '规模' TP
	,SUM(REGU_DEP_BAL_LESS_3) 												MUT_REGU_DEP_BAL_LESS_3
	,SUM(REGU_DEP_BAL_MORE_3) 												MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										CUR_DEP_BAL
	,SUM(OPN_FNC_BAL)														CUR_FNC_BAL
	,SUM(MLONG_FNC_BAL)														MLONG_FNC_BAL
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪

	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)					SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT concat('规模等级',AUM_GRD)
	,SUM(REGU_DEP_BAL_LESS_3) 												MUT_REGU_DEP_BAL_LESS_3
	,SUM(REGU_DEP_BAL_MORE_3) 												MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										CUR_DEP_BAL
	,SUM(OPN_FNC_BAL)														CUR_FNC_BAL
	,SUM(MLONG_FNC_BAL)														MLONG_FNC_BAL
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)					SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
WHERE AUM_GRD IS NOT NULL 						-- 去除空等级客户
GROUP BY AUM_GRD
UNION ALL
SELECT '客户经理-客户数' TP
	,SUM(CASE WHEN IS_CST_MNG=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN 1 ELSE 0 END) 														CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)			CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)			MLONG_FNC_CUSTS_32W
	-- 32万小企业主
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 		CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							MLONG_FNC_CUSTS_32W
	-- 经营户
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	OP_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_MLONG_FNC_CUSTS
	-- 工薪
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	SL_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_MLONG_FNC_CUSTS
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT '客户经理-规模' TP
	,SUM(CASE WHEN IS_CST_MNG=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 32万小企业主
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 		CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)					SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT '服务经理-客户数' TP
	,SUM(CASE WHEN IS_SVC_MNG=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 	MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN 1 ELSE 0 END) 														CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)			CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)			MLONG_FNC_CUSTS
	-- 32万小企业主
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_LESS_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					MUT_REGU_DEP_CUSTS_MORE_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 		CUR_DEP_CUSTS_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							CUR_FNC_CUSTS_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							MLONG_FNC_CUSTS_32W
	-- 经营户
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				OP_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	OP_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						OP_MLONG_FNC_CUSTS
	-- 工薪
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				SL_MUT_REGU_DEP_CUSTS_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	SL_CUR_DEP_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_CUR_FNC_CUSTS
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						SL_MLONG_FNC_CUSTS
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
UNION ALL
SELECT '服务经理-规模' TP
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 						MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 						MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 														CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN OPN_FNC_BAL ELSE 0 END)								CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 THEN MLONG_FNC_BAL ELSE 0 END)								MLONG_FNC_BAL_32W
	-- 32万小企业主
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_LESS_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			MUT_REGU_DEP_BAL_MORE_3_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 														CUR_DEP_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					CUR_FNC_BAL_32W
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					MLONG_FNC_BAL_32W
	-- 经营户
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		OP_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 														OP_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				OP_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				OP_MLONG_FNC_BAL
	-- 工薪
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_LESS_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		SL_MUT_REGU_DEP_BAL_MORE_3
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 														SL_CUR_DEP_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)				SL_CUR_FNC_BAL
	,SUM(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				SL_MLONG_FNC_BAL
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
;

--5类客户数去重统计数据
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05 AS
SELECT CST_ID
	,CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END 					AS IS_MUT_REGU_DEP_LESS3
	,CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END 					AS IS_MUT_REGU_DEP_MORE3
	,CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END 	AS IS_CUR_DEP
	,CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END 							AS IS_CUR_FNC
	,CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END						AS IS_MLONG_FNC

	,CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END +
		+CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END
		+CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END
		+CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END
		+CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END					AS HLD_LAB_NUM
	,IS_OPERATE
	,IS_SALARY
	,IS_32W
	,AUM_GRD
	,EFE_DEP_CST_IND
	,EFE_CHM_CST_IND
	,IS_CST_MNG				--是否客服经理
	,IS_SVC_MNG				--是否服务经理
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
;

--结果表2
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_06;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_06 AS
SELECT '客户数' 	AS 		24年保险客户大盘
	,COUNT(CASE WHEN HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
UNION ALL
SELECT CONCAT('客户数等级',AUM_GRD)
	,COUNT(CASE WHEN HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
WHERE AUM_GRD IS NOT NULL 						-- 去除空等级客户
GROUP BY AUM_GRD
UNION ALL
SELECT '客户经理-客户数' TP
	,COUNT(CASE WHEN IS_CST_MNG=1 AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_CST_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
UNION ALL
SELECT '服务经理-客户数' TP
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 						AS 持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 						AS 持有该类客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 32W持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_32W=1 		AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 32W持有该类客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 经营户持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_OPERATE=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 经营户持有该类客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 	AS 工薪持有2小类及以上客户数
	,COUNT(CASE WHEN IS_SVC_MNG=1 AND IS_SALARY=1 	AND HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 	AS 工薪持有该类客户数
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05
;

-- 结果1
SELECT  *
from TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP
;
-- 结果2
SELECT  *
from TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_06
;
**SJ2023111741_code4.sql
-- 20231122 age<=65 and 剔除 统一风险控制号 客户
-- adm_pub.adm_csm_cbas_idv_bas_inf_dd	客户集市-客户基础-对私客户基础信息	mc_cst_id		统一风险控制号
-- app_rpt.adm_subl_cst_wlth_bus_inf_dd	正式客户财富业务信息表	efe_loan_cst_ind	string	有效贷款户

--存款交易维度：到期日期在2024
-- CST_ID 到期日期 定存期限 定存余额  --> CST_ID,存款3年以下余额 存款3年及以上余额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01 AS
SELECT CST_ID
	,SUM(CASE   WHEN (DEP_TRM IN('12M','18M','1Y','24M','2Y','3M','6M')
						OR (REGEXP_SUBSTR(DEP_TRM,'[0-9]+',1,1)<=1080 and SUBSTR(DEP_TRM,-1,1)='D')
				)
		THEN GL_BAL ELSE 0 END) REGU_DEP_BAL_LESS_3     --账户总账余额
	,SUM(CASE WHEN DEP_TRM IN('36M','3Y','5Y') OR REGEXP_SUBSTR(DEP_TRM,'[0-9]+',1,1)>1080
		THEN GL_BAL ELSE 0 END) REGU_DEP_BAL_MORE_3
FROM    EDW.DWS_BUS_DEP_ACT_INF_DD		--存款账户信息表
WHERE   DT='20231128'
AND     ACT_STS_CD <> 'C'
AND     ACT_CTG_CD_1 NOT IN ( '0501' , '0509' , '0601' )    --账户状态正常
AND     lbl_prod_typ_cd<>'0' --存款产品类型代码 0:活期 1:定期 非活期外的存款
AND     MTU_DT>='20240101' AND MTU_DT<='20241231'   --24年到期定存
GROUP BY CST_ID
;

--理财交易维度：到期日期在2024
-- CST_ID 到期日期 理财期限 理财余额  --> CST_ID,理财6月及以上余额
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02 AS
SELECT A.CST_ID					--客户号
	,SUM(CASE WHEN B.TRX_MTH_CD = '0' THEN A.FNC_AMT ELSE 0 END)  	AS OPN_FNC_BAL --开放式理财产品余额 活期理财
	,SUM(CASE WHEN DATEDIFF(TO_DATE(B.PD_END_DT, 'YYYYMMDD'),TO_DATE(B.PD_VAL_DT, 'YYYYMMDD'),'DD')>=180
					AND B.PD_END_DT>='20240101' AND B.PD_END_DT<='20241231'
		THEN A.FNC_AMT ELSE 0 END) 									AS MLONG_FNC_BAL
FROM EDW.DWS_BUS_CHM_ACT_ACM_INF_DD	 	A	--理财账户份额汇总信息
INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 	B	--理财产品信息
ON 	A.PD_CD=B.PD_CD
AND B.DT='20231128'
WHERE A.DT='20231128'
AND A.FNC_AMT>0
GROUP BY A.CST_ID
;

--字段：CST_ID,活期存款 年龄 活期存款年日均 有效存款户 是否32万小企业主 是否经营户	是否工薪
-- 财富等级 是否客户经理	是否服务经理
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03 AS
SELECT A.CST_ID
	,A.AGE
	,B.DMND_DEP_BAL							--活期存款余额
	,B.DMND_DEP_BAL_MON_AVG 				--活期存款月日均
	,CASE WHEN CST_SEG_FLG IN('1','2')
		THEN 1 ELSE 0 END IS_OPERATE		--经营户（1企业主+2个体工商户）
	,CASE WHEN CST_SEG_FLG='5' THEN 1 ELSE 0 END IS_SALARY
	,CASE WHEN D.CST_ID IS NOT NULL THEN 1 ELSE 0 END IS_32W
	,E.AUM_GRD	                			-- 财富等级
	,E.DEP_BAL_YEAR_AVG	                	-- 存款年日均
	,E.EFE_DEP_CST_IND	                	-- 有效存款户
	,E.EFE_CHM_CST_IND	                	-- 有效理财户
	,E.CHM_CST_IND	                		-- 是否理财客户
	,E.IS_HLD_CHM	                		-- 是否理财持有客户
	,CASE WHEN T4.POS_NM='客户经理'	THEN 1 ELSE 0 END IS_CST_MNG 	-- 客户经理
	,CASE WHEN T4.POS_NM='服务经理'	THEN 1 ELSE 0 END IS_SVC_MNG	-- 服务经理
	,T2.PRM_MGR_ID,T2.PRM_MGR_NM
	,T5.BRC_ORG_ID,T5.BRC_ORG_NM
	,T5.SBR_ORG_ID,T5.SBR_ORG_NM
FROM ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD 			A 	--客户信息表
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_DEP_INF_DD 			B	--客户存款业务信息表
ON 		A.CST_ID=B.CST_ID
AND 	B.DT='20231128'
LEFT JOIN ADM_PUB.ADM_CSM_CLAB_CST_JC_INF_DD		C	--客户标签信息
ON 		A.CST_ID=C.CST_ID
AND 	C.DT='20231128'
LEFT JOIN TLDATA_DEV.TMP_QWJ_0818_MKX_KQ 			D 	--32万企业主表	325315
ON 		A.CST_ID=D.CST_ID
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		E	--正式客户财富业务信息表
ON 		A.CST_ID=E.CST_ID
AND 	E.DT='20231128'
LEFT JOIN ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T2 	--客户主管户信息
ON      A.CST_ID = T2.CST_ID
AND     T2.DT = '20231128'
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD 			T5
ON      T5.ORG_ID = T2.PRM_ORG_ID
AND     T5.DT = '20231128'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD					T3	--员工汇总信息
ON 		T2.PRM_MGR_ID = T3.EMPE_ID
AND 	T3.DT = '20231128'
LEFT JOIN EDW.DIM_HR_ORG_JOB_INF_DD					T4	--职位信息
ON 		T3.POS_ENC=T4.POS_ID
AND 	T4.DT = '20231128'
WHERE A.DT='20231128'
;

DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 AS
SELECT 	T1.CST_ID,T1.MC_CST_ID
		,T2.efe_loan_cst_ind		-- 有效贷款户
FROM ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD 		T1
LEFT JOIN app_rpt.adm_subl_cst_wlth_bus_inf_dd 	T2
ON 	T1.CST_ID=T2.CST_ID
AND T2.DT='20231128'
WHERE T1.DT='20231128'
AND T1.MC_CST_ID<>'' 	-- 剔除 统一风险控制号 非空
;
/*
--运行不出来
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_08;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_08 AS
SELECT T1.CST_ID,T1.MC_CST_ID,MAX(T2.efe_loan_cst_ind) is_vld_loan
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 T2
ON T1.MC_CST_ID=T2.MC_CST_ID
GROUP BY T1.CST_ID,T1.MC_CST_ID
;
*/
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_09;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_09 AS
select t1.mc_cst_id,max(t2.efe_loan_cst_ind) is_vld_loan
from(
	select distinct MC_CST_ID
	from TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07
)t1 left join TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 t2
on t1.MC_CST_ID=t2.MC_CST_ID
group by t1.mc_cst_id
;

--统一风险控制客户
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_10;	--921864
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_10 AS
select t1.cst_id
from TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_07 		t1
left join TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_09 	t2
on t1.mc_cst_id=t2.mc_cst_id
where t2.is_vld_loan='1'
;


-- 字段汇总表
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04 AS
SELECT A.CST_ID
	,A.AGE
	,B.REGU_DEP_BAL_LESS_3
	,B.REGU_DEP_BAL_MORE_3
	,C.OPN_FNC_BAL
	,C.MLONG_FNC_BAL
	,A.DMND_DEP_BAL
	,A.DMND_DEP_BAL_MON_AVG
	,A.DEP_BAL_YEAR_AVG
	,A.IS_OPERATE
	,A.IS_SALARY
	,A.IS_32W
	,A.AUM_GRD
	,A.EFE_DEP_CST_IND
	,A.EFE_CHM_CST_IND
	,A.IS_CST_MNG				--是否客服经理
	,A.IS_SVC_MNG				--是否服务经理
	,A.PRM_MGR_ID,A.PRM_MGR_NM
	,A.BRC_ORG_ID,A.BRC_ORG_NM
	,A.SBR_ORG_ID,A.SBR_ORG_NM
	,CASE WHEN B.REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END 				AS IS_MUT_REGU_DEP_LESS3
	,CASE WHEN B.REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END 				AS IS_MUT_REGU_DEP_MORE3
	,CASE WHEN A.DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END 	AS IS_CUR_DEP
	,CASE WHEN C.OPN_FNC_BAL>0 THEN 1 ELSE 0 END 						AS IS_CUR_FNC
	,CASE WHEN C.MLONG_FNC_BAL>0 THEN 1 ELSE 0 END						AS IS_MLONG_FNC

	,CASE WHEN B.REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END +
		+CASE WHEN B.REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END
		+CASE WHEN A.DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END
		+CASE WHEN C.OPN_FNC_BAL>0 THEN 1 ELSE 0 END
		+CASE WHEN C.MLONG_FNC_BAL>0 THEN 1 ELSE 0 END					AS HLD_LAB_NUM
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_03 		A
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_01 	B
ON A.CST_ID=B.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_02 	C
ON A.CST_ID=C.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_10 	D
ON A.CST_ID=D.CST_ID
WHERE D.CST_ID IS NULL 		-- 剔除 统一风险控制下的信贷户
;

--客户归属分行、支行、管户人，根据管户人汇总
DROP TABLE  IF EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05;
CREATE  TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_05 AS
SELECT 	PRM_MGR_ID			管户经理ID
	,PRM_MGR_NM             管户经理名称
	,BRC_ORG_ID             分行ID
	,BRC_ORG_NM             分行名称
	,SBR_ORG_ID             支行ID
	,SBR_ORG_NM             支行名称
	,AUM_GRD                财富等级
	,IS_CST_MNG				是否客服经理
	,IS_SVC_MNG				是否服务经理
	,IS_OPERATE             是否经营户
	,IS_SALARY              是否工薪族
	,IS_32W                 是否32万小微企业主
	----客户数----
	,SUM(HLD_LAB_NUM) 																		AS 客户数
	,COUNT(CASE WHEN HLD_LAB_NUM>0 THEN CST_ID ELSE NULL END) 								AS 持有该类客户数
	,COUNT(CASE WHEN HLD_LAB_NUM>1 THEN CST_ID ELSE NULL END) 								AS 持有2小类及以上客户数_客户数
	,SUM(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 								AS 24年到期定期存款小于3年_客户数
	,SUM(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 								AS 24年到期定期存款大于3年_客户数
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 					AS 活期存款_客户数
	,SUM(CASE WHEN OPN_FNC_BAL>0 THEN 1 ELSE 0 END)											AS 活期理财_客户数
	,SUM(CASE WHEN MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)										AS 中长期理财_客户数
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 					AS 32万小企业主24年到期定期存款小于3年_客户数
	,SUM(CASE WHEN IS_32W=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 					AS 32万小企业主24年到期定期存款大于3年_客户数
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 		AS 32万小企业主活期存款_客户数
	,SUM(CASE WHEN IS_32W=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 32万小企业主活期理财_客户数
	,SUM(CASE WHEN IS_32W=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 32万小企业主中长期理财_客户数
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				AS 经营户24年到期定期存款小于3年_客户数
	,SUM(CASE WHEN IS_OPERATE=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				AS 经营户24年到期定期存款大于3年_客户数
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	AS 经营户活期存款_客户数
	,SUM(CASE WHEN IS_OPERATE=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 经营户活期理财_客户数
	,SUM(CASE WHEN IS_OPERATE=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 经营户中长期理财_客户数
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_LESS_3>0 THEN 1 ELSE 0 END) 				AS 工薪24年到期定期存款小于3年_客户数
	,SUM(CASE WHEN IS_SALARY=1 AND REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END) 				AS 工薪24年到期定期存款大于3年_客户数
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65 THEN 1 ELSE 0 END) 	AS 工薪活期存款_客户数
	,SUM(CASE WHEN IS_SALARY=1 AND OPN_FNC_BAL>0 THEN 1 ELSE 0 END)							AS 工薪活期理财_客户数
	,SUM(CASE WHEN IS_SALARY=1 AND MLONG_FNC_BAL>0 THEN 1 ELSE 0 END)						AS 工薪中长期理财_客户数

	----规模----
	,SUM(REGU_DEP_BAL_LESS_3) 												AS 24年到期定期存款小于3年_规模
	,SUM(REGU_DEP_BAL_MORE_3) 												AS 24年到期定期存款大于3年_规模
	,SUM(CASE WHEN DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										AS 活期存款_规模
	,SUM(OPN_FNC_BAL)														AS 活期理财_规模
	,SUM(MLONG_FNC_BAL)														AS 中长期理财_规模
	-- 32万小企业主
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 			AS 32万小企业主24年到期定期存款小于3年_规模
	,SUM(CASE WHEN IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 			AS 32万小企业主24年到期定期存款大于3年_规模
	,SUM(CASE WHEN IS_32W=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										AS 32万小企业主活期存款_规模
	,SUM(CASE WHEN IS_32W=1 THEN OPN_FNC_BAL ELSE 0 END)					AS 32万小企业主活期理财_规模
	,SUM(CASE WHEN IS_32W=1 THEN MLONG_FNC_BAL ELSE 0 END)					AS 32万小企业主中长期理财_规模
	-- 经营户
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		AS 经营户24年到期定期存款小于3年_规模
	,SUM(CASE WHEN IS_OPERATE=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		AS 经营户24年到期定期存款大于3年_规模
	,SUM(CASE WHEN IS_OPERATE=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										AS 经营户活期存款_规模
	,SUM(CASE WHEN IS_OPERATE=1 THEN OPN_FNC_BAL ELSE 0 END)				AS 经营户活期理财_规模
	,SUM(CASE WHEN IS_OPERATE=1 THEN MLONG_FNC_BAL ELSE 0 END)				AS 经营户中长期理财_规模
	-- 工薪
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_LESS_3 ELSE 0 END) 		AS 工薪24年到期定期存款小于3年_规模
	,SUM(CASE WHEN IS_SALARY=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END) 		AS 工薪24年到期定期存款大于3年_规模
	,SUM(CASE WHEN IS_SALARY=1 AND DEP_BAL_YEAR_AVG>50000 AND AGE <=65
		THEN DMND_DEP_BAL ELSE 0 END) 										AS 工薪活期存款_规模
	,SUM(CASE WHEN IS_SALARY=1 THEN OPN_FNC_BAL ELSE 0 END)					AS 工薪活期理财_规模
	,SUM(CASE WHEN IS_SALARY=1 THEN MLONG_FNC_BAL ELSE 0 END)				AS 工薪中长期理财_规模
FROM TLDATA_DEV.SJXQ_SJ2023111741_CST_ZYP_04
WHERE HLD_LAB_NUM>0
GROUP BY PRM_MGR_ID,PRM_MGR_NM ,BRC_ORG_ID,BRC_ORG_NM ,SBR_ORG_ID,SBR_ORG_NM ,AUM_GRD
		,IS_CST_MNG ,IS_SVC_MNG ,IS_OPERATE ,IS_SALARY ,IS_32W
**SJ2023112956_code2.sql
--信贷户	32万小企业主 经营户	非经营户-农民	非经营户-市民	企业主	工薪	个体户
--活期理财年日均(开放式理财)&ge;1万（1128）&quot;	&quot;活期存款 23年年日均>1万

--字段：CST_ID,活期存款 年龄 活期存款年日均 有效存款户 是否32万小企业主 是否经营户	是否工薪
-- 财富等级 是否客户经理	是否服务经理
-- 耗时227s 14209379
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_01;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_01 AS
SELECT T1.CST_ID
	,T1.AGE
	--1企业主,2个体工商户,3企事业高管,4非持牌个体户,5工薪族,6退休养老,7持家女性
	,CASE WHEN T2.CST_SEG_FLG IN('1','2','5') THEN T2.CST_SEG_FLG ELSE '' END  CST_SEG_FLG
	,CASE WHEN T3.CST_ID IS NOT NULL THEN 1 ELSE 0 END IS_32W
	,T4.AUM_GRD	                			--财富等级
	,T4.EFE_DEP_CST_IND
	,T4.EFE_LOAN_CST_IND 					--有效贷款户
	,T5.PRM_MGR_ID,T5.PRM_MGR_NM
	,T6.BRC_ORG_ID,T6.BRC_ORG_NM
	,T6.SBR_ORG_ID,T6.SBR_ORG_NM
	,CASE 	WHEN T8.POS_NM='客户经理'	THEN '客户经理'
			WHEN T8.POS_NM='服务经理'	THEN '服务经理' ELSE '' END MNG_TP	-- 经理类别
	,T8.POS_NM
    ,CASE   WHEN T9.CST_ID IS NOT NULL THEN  1
            ELSE 0 END   IS_BUS_CST
    ,CASE   WHEN T10.CST_TARGET='农户' THEN '农民'
            WHEN T10.CST_TARGET='市民' OR T10.CST_TARGET='新市民' THEN '市民'
            ELSE ''  END CST_TYPE
	,T11.DMND_DEP_BAL_YEAR_AVG				-- 年日均活期存款
FROM ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD 			T1 	--客户信息表
LEFT JOIN ADM_PUB.ADM_CSM_CLAB_CST_JC_INF_DD		T2	--客户标签信息
ON 		T1.CST_ID=T2.CST_ID
AND 	T2.DT='20231130'
LEFT JOIN TLDATA_DEV.TMP_QWJ_0818_MKX_KQ 			T3 	--32万企业主表	325315
ON 		T1.CST_ID=T3.CST_ID
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		T4	--正式客户财富业务信息表
ON 		T1.CST_ID=T4.CST_ID
AND 	T4.DT='20231130'
LEFT JOIN ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T5 	--客户主管户信息
ON      T1.CST_ID = T5.CST_ID
AND     T5.DT = '20231130'
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD 			T6
ON      T6.ORG_ID = T5.PRM_ORG_ID
AND     T6.DT = '20231130'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD					T7	--员工汇总信息
ON 		T5.PRM_MGR_ID = T7.EMPE_ID
AND 	T7.DT = '20231130'
LEFT JOIN EDW.DIM_HR_ORG_JOB_INF_DD					T8	--职位信息
ON 		T7.POS_ENC=T8.POS_ID
AND 	T8.DT = '20231130'
LEFT JOIN (
    --经营性客户： 201050102 开头；随贷通2010503开头,贷款用途01开头
    SELECT  DISTINCT T1.CST_ID
    FROM EDW.DWS_BUS_LOAN_DBIL_INF_DD T1
    WHERE T1.DT = '20231130'
    AND CST_ID <> ''
    AND (SUBSTR(T1.PD_CD,1,9)='201050102' --个人经营性贷款产品
        OR(SUBSTR(T1.PD_CD,1,7)='2010503' AND SUBSTR(T1.LOAN_USG_CD,1,2)='01')
    )
)T9  ON T1.CST_ID=T9.CST_ID
LEFT JOIN LAB_BIGDATA_DEV.CST_IDV_FARMER_TARGET_INF_DD 	T10 --市民、农民 临时表
ON  T1.CST_ID=T10.CST_ID
AND T10.DT='20231101'                --最新分区
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_DEP_INF_DD 				T11 --客户存款业务信息表
ON 	T1.CST_ID=T11.CST_ID
AND T11.DT='20231130'
WHERE T1.DT='20231130'
;


--存款到期 50s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_02;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_02 AS
SELECT CST_ID
	,SUM(CASE   WHEN (DEP_TRM IN('12M','18M','1Y','24M','2Y','3M','6M')
						OR (REGEXP_SUBSTR(DEP_TRM,'[0-9]+',1,1)<=1080 AND SUBSTR(DEP_TRM,-1,1)='D')
				)
		THEN GL_BAL ELSE 0 END) REGU_DEP_BAL_LESS_3     --账户总账余额
	,SUM(CASE WHEN DEP_TRM IN('36M','3Y','5Y') OR REGEXP_SUBSTR(DEP_TRM,'[0-9]+',1,1)>1080
		THEN GL_BAL ELSE 0 END) REGU_DEP_BAL_MORE_3
FROM    EDW.DWS_BUS_DEP_ACT_INF_DD		--存款账户信息表
WHERE   DT='20231130'
AND     ACT_STS_CD <> 'C'
AND     ACT_CTG_CD_1 NOT IN ( '0501' , '0509' , '0601' )    --账户状态正常
AND     LBL_PROD_TYP_CD<>'0' --存款产品类型代码 0:活期 1:定期 非活期外的存款
AND     MTU_DT>='20240101' AND MTU_DT<='20241231'   --24年到期定存
GROUP BY CST_ID
;

--活期理财年日均 140s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_03;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_03 AS
SELECT CST_ID,AVG(OPN_FNC_BAL) OPN_FNC_BAL_Y_AVG 		--活期理财年日均
	,avg(case when a.dt>='20231101' then OPN_FNC_BAL else null end) OPN_FNC_BAL_M_AVG
	,count(dt) cnt
FROM (
	SELECT A.CST_ID					--客户号
		,A.DT
		,SUM(CASE WHEN B.TRX_MTH_CD = '0' THEN A.FNC_AMT ELSE 0 END)  	AS OPN_FNC_BAL
	FROM EDW.DWS_BUS_CHM_ACT_ACM_INF_DD	 	A	--理财账户份额汇总信息
	INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 	B	--理财产品信息
	ON 	A.PD_CD=B.PD_CD
	AND B.DT='20231130'
	WHERE A.DT BETWEEN '20230101' AND '20231130'
	AND A.FNC_AMT>0
	GROUP BY A.CST_ID,A.DT
)A GROUP BY A.CST_ID
;

--理财到期 80s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04 AS
SELECT A.CST_ID					--客户号
	,SUM(CASE WHEN B.TRX_MTH_CD = '0' THEN A.FNC_AMT ELSE 0 END)  	AS OPN_FNC_BAL --开放式理财产品余额 活期理财
	,SUM(CASE WHEN DATEDIFF(TO_DATE(B.PD_END_DT, 'YYYYMMDD'),TO_DATE(B.PD_VAL_DT, 'YYYYMMDD'),'DD')>=180 	--6个月以上理财为中长期
					AND B.PD_END_DT>='20240101' AND B.PD_END_DT<='20241231'
		THEN A.FNC_AMT ELSE 0 END) 									AS MLONG_FNC_BAL
FROM EDW.DWS_BUS_CHM_ACT_ACM_INF_DD	 	A	--理财账户份额汇总信息
INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 	B	--理财产品信息
ON 	A.PD_CD=B.PD_CD
AND B.DT='20231130'
WHERE A.DT='20231130'
AND A.FNC_AMT>0
GROUP BY A.CST_ID
;

--20231206新增 统一风险控制下的信贷户
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04_1;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04_1 AS
SELECT 	T1.CST_ID,T1.SAM_RSK_CTRL_ID,T2.efe_loan_cst_ind		-- 有效贷款户
FROM    EDW.DWS_CST_BAS_INF_DD 		            T1
LEFT JOIN app_rpt.adm_subl_cst_wlth_bus_inf_dd 	T2
ON 	    T1.CST_ID=T2.CST_ID
AND     T2.DT='20231130'
WHERE   T1.DT='20231130'
AND     TRIM(T1.SAM_RSK_CTRL_ID) <> '' 	--统一风险控制号 非空
;

DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04_2;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04_2 AS
SELECT T1.CST_ID,T1.SAM_RSK_CTRL_ID
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04_1 T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04_1 T2
ON T1.SAM_RSK_CTRL_ID=T2.SAM_RSK_CTRL_ID
GROUP BY T1.CST_ID,T1.SAM_RSK_CTRL_ID
having MAX(T2.efe_loan_cst_ind)='1'     --统一风险控制下的信贷户
;

-- 字段汇总表 80s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_05;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_05 AS
SELECT T1.CST_ID
	,T1.AGE
	,T1.CST_SEG_FLG
	,T1.IS_32W
	,T1.AUM_GRD,T1.EFE_DEP_CST_IND
	,T1.EFE_LOAN_CST_IND
	,T1.MNG_TP,T1.POS_NM
	,T1.PRM_MGR_ID,T1.PRM_MGR_NM
	,T1.BRC_ORG_ID,T1.BRC_ORG_NM
	,T1.SBR_ORG_ID,T1.SBR_ORG_NM
	,CASE 	WHEN IS_BUS_CST=1 THEN '经营户'
			WHEN IS_BUS_CST=0 AND CST_TYPE='农民' THEN '非经营户-农民'
			WHEN IS_BUS_CST=0 AND CST_TYPE='市民' THEN '非经营户-市民'
			ELSE '' END BUS_TYPE
	,COALESCE(T1.DMND_DEP_BAL_YEAR_AVG,0)	DMND_DEP_BAL_YEAR_AVG
	,COALESCE(T2.REGU_DEP_BAL_LESS_3,0)		REGU_DEP_BAL_LESS_3
	,COALESCE(T2.REGU_DEP_BAL_MORE_3,0)		REGU_DEP_BAL_MORE_3
	,COALESCE(T3.OPN_FNC_BAL_Y_AVG,0) 		OPN_FNC_BAL_Y_AVG
	,COALESCE(T4.MLONG_FNC_BAL,0)			MLONG_FNC_BAL
	,CASE WHEN T3.OPN_FNC_BAL_Y_AVG>=10000 OR
		(T1.DMND_DEP_BAL_YEAR_AVG>=10000 AND T1.AGE<=65) THEN 1 ELSE 0 END IS_FINA_SJ
	,CASE WHEN T2.REGU_DEP_BAL_LESS_3>0 OR T4.MLONG_FNC_BAL>0 THEN 1 ELSE 0 END IS_MLONG_SJ
	,CASE WHEN T2.REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END IS_LONG_SJ
	,CASE WHEN T3.OPN_FNC_BAL_Y_AVG>=10000 OR
		(T1.DMND_DEP_BAL_YEAR_AVG>=10000 AND T1.AGE<=65)
		OR T2.REGU_DEP_BAL_LESS_3>0 OR T4.MLONG_FNC_BAL>0
		OR T2.REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END IS_SJ
    ,case when t5.cst_ID is not null then 1 else 0 end is_sam_rsk_ctrl_cst
FROM 	  TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_01 	T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_02 	T2
ON T1.CST_ID=T2.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_03 	T3
ON T1.CST_ID=T3.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04 	T4
ON T1.CST_ID=T4.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04_2 t5
on t1.cst_ID=t5.cst_ID
WHERE T1.EFE_DEP_CST_IND='1'	--存款有效户
;

--全行、分行
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_06;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_06 AS
SELECT '全行' TP
	,COUNT(1) 																		客户数去重_大盘
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)	资金汇总_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                  企业主客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                  工薪客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                  个体户客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
    ,COUNT(CASE WHEN IS_FINA_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN CST_ID END)            统一风险控制信贷户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND IS_32W=1 THEN CST_ID END)                         小企业32万客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                 企业主客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                 工薪客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                 个体户客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
    ,COUNT(CASE WHEN IS_MLONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN CST_ID END)            统一风险控制信贷户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND IS_32W=1 THEN CST_ID END)                        小企业32万客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                  企业主客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                  工薪客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                  个体户客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
    ,COUNT(CASE WHEN IS_LONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN CST_ID END)            统一风险控制信贷户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND IS_32W=1 THEN CST_ID END)                         小企业32万客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            企业主_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='5' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            工薪_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='2' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            个体户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
    ,SUM(CASE WHEN IS_FINA_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)      统一风险控制信贷户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND IS_32W=1 THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                   小企业32万_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                      活期存款规模
	--中长期储蓄商机规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               企业主_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='5' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               工薪_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='2' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               个体户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
    ,SUM(CASE WHEN IS_MLONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)         统一风险控制信贷户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND IS_32W=1 THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)                      小企业32万_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                企业主_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='5' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                工薪_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='2' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                个体户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
    ,SUM(CASE WHEN IS_LONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                          统一风险控制信贷户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                       小企业32万_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)	                                                                                        定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_05
WHERE IS_SJ=1
union all
SELECT BRC_ORG_NM
	,COUNT(1) 																		客户数去重_大盘
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)	资金汇总_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                  企业主客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                  工薪客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                  个体户客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
    ,COUNT(CASE WHEN IS_FINA_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN CST_ID END)            统一风险控制信贷户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND IS_32W=1 THEN CST_ID END)                         小企业32万客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                 企业主客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                 工薪客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                 个体户客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
    ,COUNT(CASE WHEN IS_MLONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN CST_ID END)            统一风险控制信贷户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND IS_32W=1 THEN CST_ID END)                        小企业32万客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                  企业主客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                  工薪客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                  个体户客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
    ,COUNT(CASE WHEN IS_LONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN CST_ID END)            统一风险控制信贷户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND IS_32W=1 THEN CST_ID END)                         小企业32万客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            企业主_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='5' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            工薪_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='2' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            个体户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
    ,SUM(CASE WHEN IS_FINA_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)      统一风险控制信贷户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND IS_32W=1 THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                   小企业32万_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                      活期存款规模
	--中长期储蓄商机规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               企业主_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='5' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               工薪_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='2' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               个体户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
    ,SUM(CASE WHEN IS_MLONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)         统一风险控制信贷户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND IS_32W=1 THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)                      小企业32万_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                企业主_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='5' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                工薪_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='2' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                个体户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
    ,SUM(CASE WHEN IS_LONG_SJ=1 AND is_sam_rsk_ctrl_cst=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                          统一风险控制信贷户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                       小企业32万_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)	                                                                                        定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_05
WHERE IS_SJ=1
AND BRC_ORG_NM LIKE '%分行%'
group by BRC_ORG_NM
;

--分行	支行	管户人	工号	岗位 支行	管户人 12585
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_07;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_07 AS
SELECT BRC_ORG_NM ,SBR_ORG_NM ,PRM_MGR_NM,PRM_MGR_ID,MNG_TP
	,COUNT(1) 																		客户数去重_大盘
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)	资金汇总_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                  企业主客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                  工薪客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                  个体户客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND IS_32W=1 THEN CST_ID END)                         小企业32万客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                 企业主客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                 工薪客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                 个体户客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND IS_32W=1 THEN CST_ID END)                        小企业32万客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='1' THEN CST_ID END)                  企业主客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='5' THEN CST_ID END)                  工薪客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='2' THEN CST_ID END)                  个体户客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND IS_32W=1 THEN CST_ID END)                         小企业32万客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            企业主_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='5' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            工薪_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND CST_SEG_FLG='2' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)            个体户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND IS_32W=1 THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                   小企业32万_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                      活期存款规模
	--中长期储蓄商机规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               企业主_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='5' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               工薪_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND CST_SEG_FLG='2' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)               个体户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND IS_32W=1 THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)                      小企业32万_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                企业主_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='5' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                工薪_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND CST_SEG_FLG='2' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                个体户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND IS_32W=1 THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                                       小企业32万_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)	                                                                                        定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_05
WHERE IS_SJ=1
AND  PRM_MGR_NM<>''
GROUP BY BRC_ORG_NM ,SBR_ORG_NM ,PRM_MGR_NM,PRM_MGR_ID,MNG_TP
;

DROP TABLE IF EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_07_1;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_07_1 AS
SELECT  *
FROM    TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_07
WHERE   prm_mgr_nm IS NOT NULL
and mng_tp in ('客户经理','服务经理')
;


/*
SELECT '1' seq,count(1) cnt,count(DISTINCT cst_ID)
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_01
union all
SELECT '2' seq,count(1) cnt,count(DISTINCT cst_ID)
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_02
union all
SELECT '3' seq,count(1) cnt,count(DISTINCT cst_ID)
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_03
union all
SELECT '4' seq,count(1) cnt,count(DISTINCT cst_ID)
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_04
union all
SELECT '5' seq,count(1) cnt,count(DISTINCT cst_ID)
FROM TLDATA_DEV.SJXQ_SJ2023113056_CST_ZYP_05
;
各临时表数据重复情况
1	14224876	14224876
2	610859	610859
3	194198	194198
4	176224	176224
5	1291989	1291989
*/
**SJ2023112957_code3.sql
-- ODPS SQL
-- **********************************************************************
-- 功能描述:
-- **
-- 创建者: 龙彬彬
-- 创建日期: 2023-12-01 09:39:48
-- **
-- 修改日志:
-- 修改日期          修改人          修改内容
-- **
-- **********************************************************************
--信贷户	32万小企业主 经营户	非经营户-农民	非经营户-市民	企业主	工薪	个体户
--活期理财年日均(开放式理财)&ge;1万（1128）&quot;	&quot;活期存款 23年年日均>1万

--字段：CST_ID,活期存款 年龄 活期存款年日均 有效存款户 是否32万小企业主 是否经营户	是否工薪
-- 财富等级 是否客户经理	是否服务经理
-- 耗时227s 14209379
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_01;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_01 AS
SELECT T1.CST_ID
	,T1.AGE
	--1企业主,2个体工商户,3企事业高管,4非持牌个体户,5工薪族,6退休养老,7持家女性
	,CASE WHEN T2.CST_SEG_FLG IN('1','2','5','6') THEN T2.CST_SEG_FLG ELSE '' END  CST_SEG_FLG
	,CASE WHEN T3.CST_ID IS NOT NULL THEN 1 ELSE 0 END IS_32W
	,T4.AUM_GRD	                			--财富等级
	,T4.EFE_DEP_CST_IND
	,T4.EFE_LOAN_CST_IND 					--有效贷款户
	,T5.PRM_MGR_ID,T5.PRM_MGR_NM
	,T6.BRC_ORG_ID,T6.BRC_ORG_NM
	,T6.SBR_ORG_ID,T6.SBR_ORG_NM
	,CASE 	WHEN T8.POS_NM='客户经理'	THEN '客户经理'
			WHEN T8.POS_NM='服务经理'	THEN '服务经理' ELSE '' END MNG_TP	-- 经理类别
	,T8.POS_NM
    ,CASE   WHEN T9.CST_ID IS NOT NULL THEN  1
            ELSE 0 END   IS_BUS_CST
    ,CASE   WHEN T10.CST_TARGET='农户' THEN '农民'
            WHEN T10.CST_TARGET='市民' OR T10.CST_TARGET='新市民' THEN '市民'
            ELSE ''  END CST_TYPE
	,T11.DMND_DEP_BAL_YEAR_AVG				-- 年日均活期存款
FROM ADM_PUB.ADM_CSM_CBAS_IDV_BAS_INF_DD 			T1 	--客户信息表
LEFT JOIN ADM_PUB.ADM_CSM_CLAB_CST_JC_INF_DD		T2	--客户标签信息
ON 		T1.CST_ID=T2.CST_ID
AND 	T2.DT='20231130'
LEFT JOIN TLDATA_DEV.TMP_QWJ_0818_MKX_KQ 			T3 	--32万企业主表	325315
ON 		T1.CST_ID=T3.CST_ID
LEFT JOIN APP_RPT.ADM_SUBL_CST_WLTH_BUS_INF_DD 		T4	--正式客户财富业务信息表
ON 		T1.CST_ID=T4.CST_ID
AND 	T4.DT='20231130'
LEFT JOIN ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD 	T5 	--客户主管户信息
ON      T1.CST_ID = T5.CST_ID
AND     T5.DT = '20231130'
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD 			T6
ON      T6.ORG_ID = T5.PRM_ORG_ID
AND     T6.DT = '20231130'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD					T7	--员工汇总信息
ON 		T5.PRM_MGR_ID = T7.EMPE_ID
AND 	T7.DT = '20231130'
LEFT JOIN EDW.DIM_HR_ORG_JOB_INF_DD					T8	--职位信息
ON 		T7.POS_ENC=T8.POS_ID
AND 	T8.DT = '20231130'
LEFT JOIN (
    --经营性客户： 201050102 开头；随贷通2010503开头,贷款用途01开头
    SELECT  DISTINCT T1.CST_ID
    FROM EDW.DWS_BUS_LOAN_DBIL_INF_DD T1
    WHERE T1.DT = '20231130'
    AND CST_ID <> ''
    AND (SUBSTR(T1.PD_CD,1,9)='201050102' --个人经营性贷款产品
        OR(SUBSTR(T1.PD_CD,1,7)='2010503' AND SUBSTR(T1.LOAN_USG_CD,1,2)='01')
    )
)T9  ON T1.CST_ID=T9.CST_ID
LEFT JOIN LAB_BIGDATA_DEV.CST_IDV_FARMER_TARGET_INF_DD 	T10 --市民、农民 临时表
ON  T1.CST_ID=T10.CST_ID
AND T10.DT='20231101'                --最新分区
LEFT JOIN ADM_PUB.ADM_CSM_CBUS_DEP_INF_DD 				T11 --客户存款业务信息表
ON 	T1.CST_ID=T11.CST_ID
AND T11.DT='20231130'
WHERE T1.DT='20231130'
;


--存款到期 50s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_02;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_02 AS
SELECT CST_ID
	,SUM(CASE   WHEN (DEP_TRM IN('12M','18M','1Y','24M','2Y','3M','6M')
						OR (REGEXP_SUBSTR(DEP_TRM,'[0-9]+',1,1)<=1080 AND SUBSTR(DEP_TRM,-1,1)='D')
				)
		THEN GL_BAL ELSE 0 END) REGU_DEP_BAL_LESS_3     --账户总账余额
	,SUM(CASE WHEN DEP_TRM IN('36M','3Y','5Y') OR REGEXP_SUBSTR(DEP_TRM,'[0-9]+',1,1)>1080
		THEN GL_BAL ELSE 0 END) REGU_DEP_BAL_MORE_3
FROM    EDW.DWS_BUS_DEP_ACT_INF_DD		--存款账户信息表
WHERE   DT='20231130'
AND     ACT_STS_CD <> 'C'
AND     ACT_CTG_CD_1 NOT IN ( '0501' , '0509' , '0601' )    --账户状态正常
AND     LBL_PROD_TYP_CD<>'0' --存款产品类型代码 0:活期 1:定期 非活期外的存款
AND     MTU_DT>='20240101' AND MTU_DT<='20241231'   --24年到期定存
GROUP BY CST_ID
;

--活期理财年日均 140s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_03;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_03 AS
SELECT CST_ID,AVG(OPN_FNC_BAL) OPN_FNC_BAL_Y_AVG 		--活期理财年日均
	,avg(case when a.dt>='20231101' then OPN_FNC_BAL else null end) OPN_FNC_BAL_M_AVG
	,count(dt) cnt
FROM (
	SELECT A.CST_ID					--客户号
		,A.DT
		,SUM(CASE WHEN B.TRX_MTH_CD = '0' THEN A.FNC_AMT ELSE 0 END)  	AS OPN_FNC_BAL
	FROM EDW.DWS_BUS_CHM_ACT_ACM_INF_DD	 	A	--理财账户份额汇总信息
	INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 	B	--理财产品信息
	ON 	A.PD_CD=B.PD_CD
	AND B.DT='20231130'
	WHERE A.DT BETWEEN '20230101' AND '20231130'
	AND A.FNC_AMT>0
	GROUP BY A.CST_ID,A.DT
)A GROUP BY A.CST_ID
;

--理财到期 80s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_04;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_04 AS
SELECT A.CST_ID					--客户号
	,SUM(CASE WHEN B.TRX_MTH_CD = '0' THEN A.FNC_AMT ELSE 0 END)  	AS OPN_FNC_BAL --开放式理财产品余额 活期理财
	,SUM(CASE WHEN DATEDIFF(TO_DATE(B.PD_END_DT, 'YYYYMMDD'),TO_DATE(B.PD_VAL_DT, 'YYYYMMDD'),'DD')>=180 	--6个月以上理财为中长期
					AND B.PD_END_DT>='20240101' AND B.PD_END_DT<='20241231'
		THEN A.FNC_AMT ELSE 0 END) 									AS MLONG_FNC_BAL
FROM EDW.DWS_BUS_CHM_ACT_ACM_INF_DD	 	A	--理财账户份额汇总信息
INNER JOIN EDW.DIM_BUS_CHM_PD_INF_DD 	B	--理财产品信息
ON 	A.PD_CD=B.PD_CD
AND B.DT='20231130'
WHERE A.DT='20231130'
AND A.FNC_AMT>0
GROUP BY A.CST_ID
;

-- 字段汇总表 80s
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05 AS
SELECT T1.CST_ID
	,T1.AGE
	--1企业主,2个体工商户,3企事业高管,4非持牌个体户,5工薪族,6退休养老,7持家女性
	,CASE 	WHEN T1.CST_SEG_FLG='1' THEN '企业主'
			WHEN T1.CST_SEG_FLG='2' THEN '个体工商户'
			WHEN T1.CST_SEG_FLG='5' THEN '工薪族'
			WHEN T1.CST_SEG_FLG='6' THEN '退休养老' ELSE '' END CST_SEG_FLG
	,T1.IS_32W
	,T1.AUM_GRD,T1.EFE_DEP_CST_IND
	,T1.EFE_LOAN_CST_IND
	,T1.MNG_TP,T1.POS_NM
	,T1.PRM_MGR_ID,T1.PRM_MGR_NM
	,T1.BRC_ORG_ID,T1.BRC_ORG_NM
	,T1.SBR_ORG_ID,T1.SBR_ORG_NM
	,CASE 	WHEN IS_BUS_CST=1 THEN '经营户'
			WHEN IS_BUS_CST=0 AND CST_TYPE='农民' THEN '非经营户-农民'
			WHEN IS_BUS_CST=0 AND CST_TYPE='市民' THEN '非经营户-市民'
			ELSE '' END BUS_TYPE
	,COALESCE(T1.DMND_DEP_BAL_YEAR_AVG,0)	DMND_DEP_BAL_YEAR_AVG
	,COALESCE(T2.REGU_DEP_BAL_LESS_3,0)		REGU_DEP_BAL_LESS_3
	,COALESCE(T2.REGU_DEP_BAL_MORE_3,0)		REGU_DEP_BAL_MORE_3
	,COALESCE(T3.OPN_FNC_BAL_Y_AVG,0) 		OPN_FNC_BAL_Y_AVG
	,COALESCE(T4.MLONG_FNC_BAL,0)			MLONG_FNC_BAL

	,CASE WHEN T3.OPN_FNC_BAL_Y_AVG>=10000 OR
		(T1.DMND_DEP_BAL_YEAR_AVG>=10000 AND T1.AGE<=65) THEN 1 ELSE 0 END IS_FINA_SJ
	,CASE WHEN T2.REGU_DEP_BAL_LESS_3>0 OR T4.MLONG_FNC_BAL>0 THEN 1 ELSE 0 END IS_MLONG_SJ
	,CASE WHEN T2.REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END IS_LONG_SJ
	,CASE WHEN T3.OPN_FNC_BAL_Y_AVG>=10000 OR
		(T1.DMND_DEP_BAL_YEAR_AVG>=10000 AND T1.AGE<=65)
		OR T2.REGU_DEP_BAL_LESS_3>0 OR T4.MLONG_FNC_BAL>0
		OR T2.REGU_DEP_BAL_MORE_3>0 THEN 1 ELSE 0 END IS_SJ
FROM 	  TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_01 	T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_02 	T2
ON T1.CST_ID=T2.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_03 	T3
ON T1.CST_ID=T3.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_04 	T4
ON T1.CST_ID=T4.CST_ID
WHERE T1.EFE_DEP_CST_IND='1'	--存款有效户
;

--总行
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_06;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_06 AS
SELECT '全行' TP
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)																						总规模
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1
UNION ALL
SELECT '32万企业主' TP
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1 AND IS_32W=1
UNION ALL
SELECT CST_SEG_FLG
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1 AND CST_SEG_FLG<>''
GROUP BY CST_SEG_FLG
UNION ALL
SELECT MNG_TP
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1 AND MNG_TP<>''
GROUP BY MNG_TP
;






--十三家分行维度
DROP   TABLE IF 	EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_07;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_07 AS
SELECT BRC_ORG_NM  分行,'汇总' TP
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3) 																						总规模
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1 AND BRC_ORG_NM LIKE '%分行%'
GROUP BY BRC_ORG_NM
UNION ALL
SELECT BRC_ORG_NM,'32万企业主'
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1 AND IS_32W=1 AND BRC_ORG_NM LIKE '%分行%'
GROUP BY BRC_ORG_NM
UNION ALL
SELECT BRC_ORG_NM,CST_SEG_FLG
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1 AND CST_SEG_FLG<>'' AND BRC_ORG_NM LIKE '%分行%'
GROUP BY CST_SEG_FLG,BRC_ORG_NM
UNION ALL
SELECT BRC_ORG_NM,MNG_TP
	,COUNT(1) 																		客户数去重_大盘
	--理财商机客户数
	,COUNT(CASE WHEN IS_FINA_SJ=1 THEN CST_ID END) 										客户数_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_活期客户
	,COUNT(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_活期客户
	,COUNT(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN CST_ID END)                          活期理财客户数
	,COUNT(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN CST_ID END)          活期存款客户数
	--中长期储蓄商机客户数
	,COUNT(CASE WHEN IS_MLONG_SJ=1 THEN CST_ID END) 									客户数_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)               经营户_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)        非经营农民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)        非经营市民_中长期客户
	,COUNT(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)            信贷户客户数_中长期客户
	,COUNT(CASE WHEN REGU_DEP_BAL_LESS_3>0 THEN CST_ID END)                             定存3年以下客户数
	,COUNT(CASE WHEN MLONG_FNC_BAL>0 THEN CST_ID END)                                   中长期理财客户数
	--传承隔离性商机客户数
	,COUNT(CASE WHEN IS_LONG_SJ=1 THEN CST_ID END) 										客户数_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN CST_ID END)                经营户_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN CST_ID END)         非经营农民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN CST_ID END)         非经营市民_传承隔离客户
	,COUNT(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN CST_ID END)             信贷户客户数_传承隔离客户
	,COUNT(CASE WHEN REGU_DEP_BAL_MORE_3>0 THEN CST_ID END)                             定存3年及以上客户数_传承隔离客户
	----规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)
		+SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)
		+SUM(REGU_DEP_BAL_LESS_3)
		+SUM(MLONG_FNC_BAL)
		+SUM(REGU_DEP_BAL_MORE_3)
	--理财商机规模
	,SUM(CASE WHEN IS_FINA_SJ=1 THEN OPN_FNC_BAL_Y_AVG + DMND_DEP_BAL_YEAR_AVG ELSE 0 END)                 				活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='经营户' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END) 			经营户_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-农民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营农民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND BUS_TYPE='非经营户-市民' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)   非经营市民_活期规模
	,SUM(CASE WHEN IS_FINA_SJ=1 AND EFE_LOAN_CST_IND='1' THEN OPN_FNC_BAL_Y_AVG+DMND_DEP_BAL_YEAR_AVG ELSE 0 END)       信贷户_活期规模
	,SUM(CASE WHEN OPN_FNC_BAL_Y_AVG>=10000 THEN OPN_FNC_BAL_Y_AVG ELSE 0 END)                                          活期理财规模
	,SUM(CASE WHEN DMND_DEP_BAL_YEAR_AVG>=10000 AND AGE<=65 THEN DMND_DEP_BAL_YEAR_AVG ELSE 0 END)  					活期存款规模
	--中长期储蓄商机规模
	,SUM(REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL)                                                                           中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)				经营户_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营农民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)      非经营市民_中长期规模
	,SUM(CASE WHEN IS_MLONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_LESS_3 + MLONG_FNC_BAL ELSE 0 END)          信贷户_中长期规模
	,SUM(REGU_DEP_BAL_LESS_3)                                                                                           定存3年以下规模
	,SUM(MLONG_FNC_BAL)                                                                                                 中长期理财规模
	--传承隔离性商机规模
	,SUM(REGU_DEP_BAL_MORE_3)																							传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='经营户' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)								经营户_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-农民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营农民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND BUS_TYPE='非经营户-市民' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                       非经营市民_传承隔离规模
	,SUM(CASE WHEN IS_LONG_SJ=1 AND EFE_LOAN_CST_IND='1' THEN REGU_DEP_BAL_MORE_3 ELSE 0 END)                           信贷户_传承隔离规模
	,SUM(REGU_DEP_BAL_MORE_3)																							定存3年及以上规模
FROM TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_05
WHERE IS_SJ=1 AND MNG_TP<>'' AND BRC_ORG_NM LIKE '%分行%'
GROUP BY MNG_TP,BRC_ORG_NM
;

--全行
SELECT *
from TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_06
;
--分行
SELECT *
from TLDATA_DEV.SJXQ_SJ2023113057_CST_ZYP_07
;
**SJ2023120461_code.sql
/*
11.1-11.30期间
客户在我行首次购买理财且首笔购买量&ge;1万元；
10.1-11.30期间
在我行首次配置保险，名下有效保单首年保费总计&ge;0.5万元；
首次购买贵金属，且贵金属累计购买付款金额&ge;0.1万元；
首次购买基金且非货基金月日均保有量&ge;0.1万元
*/

-- 杭州分行个人客户（管户在杭州分行） + 钱塘支行
-- 1. 首次购买贵金属，且贵金属累计购买付款金额&ge;0.1万元；
-- 贵金属 18
DROP TABLE IF EXISTS tldata_dev.SJXQ_SJ2023120461_tmp01;
CREATE TABLE IF NOT EXISTS tldata_dev.SJXQ_SJ2023120461_tmp01 AS
SELECT  T1.cst_id,MIN(SUBSTR(t1.pmt_tm, 1, 10)) AS gold_fst_buy_dt --首次购买时间
        ,SUM(T1.cmdt_pay_unt_prc) AS gold_tot_buy_amt --购买金额
FROM    adm_pub.adm_pub_cst_nob_met_trx_sum_di T1 --贵金属交易整合表
LEFT JOIN    (
                 SELECT  A1.cst_id
                         ,MIN(SUBSTR(A1.pmt_tm, 1, 10)) AS pmt_tm --最早购买时间
                 FROM    adm_pub.adm_pub_cst_nob_met_trx_sum_di A1 --贵金属交易整合表
                 WHERE   A1.DT <= '20230930'
                 GROUP BY cst_id
                  HAVING MIN(SUBSTR(A1.pmt_tm, 1, 10)) <= '2023-09-30'
             ) T2  --10月之前购买过的客户
ON      T1.cst_id = T2.cst_id
LEFT JOIN    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd B2 --客户主管户信息
ON      T1.cst_id = B2.cst_id
AND     B2.DT = '20231130'
LEFT JOIN    edw.dim_hr_org_mng_org_tree_dd B6 --机构树_考核维度
ON      B2.prm_org_id = B6.org_id
AND     B6.DT = '20231130'
WHERE   T1.DT >= '20231001'
AND     T1.DT <= '20231130'
AND     T2.cst_id IS NULL --剔除23年10月前有购买贵金属客户
AND     (B6.brc_org_nm = '杭州分行' or B6.sbr_org_nm like '杭州钱塘%') --杭州分行+钱塘支行
GROUP BY T1.cst_id
HAVING SUM(T1.cmdt_pay_unt_prc) >= 1000
;

-- 2. 11.1-11.30期间 客户在我行首次购买理财且首笔购买量&ge;1万元；
DROP TABLE IF EXISTS tldata_dev.SJXQ_SJ2023120461_tmp02;
CREATE TABLE IF NOT EXISTS tldata_dev.SJXQ_SJ2023120461_tmp02 AS
SELECT  a.cst_id,a.trx_dt fina_fst_buy_dt
        ,a.trx_amt  fina_fst_buy_amt
FROM    (
            SELECT  T1.cst_id,T1.trx_dt
                    ,trx_amt --理财余额
                    ,ROW_NUMBER() OVER ( PARTITION BY t1.cst_id ORDER BY srl_nbr ASC ) AS rn
            FROM    edw.dwd_bus_chm_trx_cfm_dtl_di T1 --理财交易确认流水明细
            LEFT JOIN    (
                             SELECT  DISTINCT t1.cst_id
                             FROM    edw.dws_bus_chm_act_acm_inf_dd t1
                             WHERE   t1.dt = '20231031'
                             AND     t1.pd_tp_cd = '1' --理财
                         ) T2 --10月以前已持有或购买过我行理财产品的客户
            ON      T1.cst_id = T2.cst_id
            WHERE   T1.DT >= '20231101'
            AND     t1.dt <= '20231130'
            AND     SUBSTR(T1.trx_dt, 1, 6) = '202311'
            AND     t1.trx_sts_cd = '8' --购买成功
            AND     t1.trx_cd IN ( '100200' , '100256' , '160200' , '200208' ) --理财产品购买\定向购买\份额转让买入\定期定额处理
            AND     T2.cst_id IS NULL --剔除23年10月前有理财购买客户
        ) A
LEFT JOIN    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd B2 --客户主管户信息
ON      A.cst_id = B2.cst_id
AND     B2.DT = '20231130'
LEFT JOIN    edw.dim_hr_org_mng_org_tree_dd B6 --机构树_考核维度
ON      B2.prm_org_id = B6.org_id
AND     B6.DT = '20231130'
WHERE   rn = 1
AND     trx_amt >= 10000
AND     (B6.brc_org_nm = '杭州分行' or B6.sbr_org_nm like '杭州钱塘%') --杭州分行+钱塘支行
;


-- 3. 在我行首次配置保险，名下有效保单首年保费总计&ge;0.5万元；
DROP TABLE IF EXISTS tldata_dev.SJXQ_SJ2023120461_tmp03;
CREATE TABLE IF NOT EXISTS tldata_dev.SJXQ_SJ2023120461_tmp03 AS
SELECT  substr(col_3, 1, 10) cst_ID,col_22 insu_vld_fee
FROM    qbi_file_20231205_16_48_51
WHERE   pt = max_pt('qbi_file_20231205_16_48_51')
AND     substr(col_3, 1, 10) NOT IN (
                                        SELECT  DISTINCT cst_id
                                        FROM    app_rpt.fct_insu_agn_bus_acs_dtl_tbl
                                        WHERE   dt = '20230930'
                                    )
AND     col_60 <> '交易撤销'
AND     col_22 >= 5000 --首期保费
;

-- 4. 首次购买基金且非货基金月日均保有量&ge;0.1万元 首次购买基金日期、金额，非货基金月日均
DROP TABLE IF EXISTS tldata_dev.SJXQ_SJ2023120461_tmp04;
CREATE TABLE IF NOT EXISTS tldata_dev.SJXQ_SJ2023120461_tmp04 AS
SELECT  T.cst_id,round(sum(ncr_fnd_bal)/61,1)  ncr_fnd_bal_mon_avg
    ,sum(case when ncr_fnd_bal>0 then 1 else 0 end) bal_days
    ,max(case when t.dt = '20231130' then ncr_fnd_frs_buy_amt else 0 end) ncr_fnd_frs_buy_amt
    ,count(DISTINCT t.dt) day_cnt
FROM    adm_pub.adm_csm_cbus_fnd_bal_inf_dd T --基金交易确认流水明细
LEFT JOIN    (
                 SELECT  DISTINCT cst_id
                 FROM    edw.dim_bus_chm_fnd_act_lot_dtl_inf_dd --基金账户份额信息
                 WHERE   dt = '20230930'
             ) T1
ON      t.cst_id = t1.cst_id
LEFT JOIN    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd B2 --客户主管户信息
ON      T.cst_id = B2.cst_id
AND     B2.DT = '20231130'
LEFT JOIN    edw.dim_hr_org_mng_org_tree_dd B6 --机构树_考核维度
ON      B2.prm_org_id = B6.org_id
AND     B6.DT = '20231130'
WHERE   t.dt <= '20231130' and t.dt>='20231001'
AND     t1.cst_id IS NULL --历史未有基金账户
AND     (B6.brc_org_nm = '杭州分行' or B6.sbr_org_nm like '杭州钱塘%') --杭州分行+钱塘支行
GROUP by t.cst_ID
;

--首次购买基金日期、金额
DROP TABLE IF EXISTS tldata_dev.SJXQ_SJ2023120461_tmp05;
CREATE TABLE IF NOT EXISTS tldata_dev.SJXQ_SJ2023120461_tmp05 AS
SElECT *,ROW_NUMBER() OVER ( PARTITION BY t.cst_id ORDER BY t.BUS_DT ASC ) AS rn
from(
    SELECT  T.cst_id,t.BUS_DT,sum(t.CFM_AMT) CFM_AMT
    FROM    edw.dwd_bus_chm_fnd_trx_cfm_dtl_di T --基金交易确认流水明细
    WHERE   T.DT >= '20231001'
    AND     T.DT <= '20231130'
    and     t.bus_dt >='20231001'   -- 10-11月期间购买
    and T.TRX_STS_CD IN ( '0' , '3' , '4' , 'S' ) --交易状态：申请成功、确认成功、部分确认成功、成功
    AND T.BUS_CD IN ( '120' , '122' , '136' , '139' , '138' ) --认购确认、申购确认、产品转换确认、定时定额申购确认、快速过户确认
    AND T.CFM_AMT > 0
    GROUP by T.cst_id,t.BUS_DT
)t
;

--数据汇总
-- 客户号，首次购买理财日期 首次购买理财金额，名下有效保单累计首年保费，首次购买贵金属日期 贵金属累计购买金额
-- 首次购买基金日期、金额，非货基金月日均
DROP TABLE IF EXISTS tldata_dev.SJXQ_SJ2023120461_tmp06;
CREATE TABLE IF NOT EXISTS tldata_dev.SJXQ_SJ2023120461_tmp06 AS
select t.cst_ID
    ,case when t1.cst_ID is not null then '是' else '否' end is_gold_cst
    ,t1.gold_fst_buy_dt,t1.gold_tot_buy_amt
    ,case when t2.cst_ID is not null then '是' else '否' end is_fina_cst
    ,t2.fina_fst_buy_dt,t2.fina_fst_buy_amt
    ,case when t3.cst_ID is not null then '是' else '否' end is_insu_cst
    ,t3.insu_vld_fee
    ,case when t4.ncr_fnd_bal_mon_avg>=1000 then '是'
        else '否' end is_fund_cst,t4.ncr_fnd_frs_buy_amt
    ,t5.BUS_DT,t5.CFM_AMT
    ,case when t1.cst_ID is not null then 1 else 0 end
        + case when t2.cst_ID is not null then 1 else 0 end
        + case when t3.cst_ID is not null then 1 else 0 end
        + case when t4.ncr_fnd_bal_mon_avg>=1000 then 1 else 0 end hld_prod_cnt
from adm_pub.adm_csm_cbas_idv_bas_inf_dd        t -- 14224876
left join tldata_dev.SJXQ_SJ2023120461_tmp01    t1 on t.cst_ID=t1.cst_ID
left join tldata_dev.SJXQ_SJ2023120461_tmp02    t2 on t.cst_ID=t2.cst_ID
left join tldata_dev.SJXQ_SJ2023120461_tmp03    t3 on t.cst_ID=t3.cst_ID
left join tldata_dev.SJXQ_SJ2023120461_tmp04    t4 on t.cst_ID=t4.cst_ID
left join tldata_dev.SJXQ_SJ2023120461_tmp05    t5 on t.cst_ID=t5.cst_ID and t5.rn=1
where t.dt = '20231130'
;

--结果表
select cst_id				        客户号
    ,is_fina_cst                    是否首次购买理财
    ,coalesce(fina_fst_buy_dt,'')	首次购买理财日期
    ,coalesce(fina_fst_buy_amt,0)   首次购买理财金额
    ,coalesce(insu_vld_fee,0)       名下有效保单累计首年保费
    ,is_gold_cst                    是否首次购买贵金属
    ,coalesce(gold_fst_buy_dt,'')   首次购买贵金属日期
    ,coalesce(gold_tot_buy_amt,0)   贵金属累计购买金额
    ,is_fund_cst                    是否首次购买基金
    ,coalesce(bus_dt,'')            首次购买基金日期
    ,coalesce(CFM_AMT,0)            首次购买基金金额
from tldata_dev.SJXQ_SJ2023120461_tmp06
where hld_prod_cnt>0
;
/*
--数据量核查
SELECT '1_gold' seq,COUNT(cst_id) cnt,count(distinct cst_id) custs
from tldata_dev.SJXQ_SJ2023120461_tmp01  --42
union all
SELECT '2_fina' seq,COUNT(cst_id), count(distinct cst_id)
from tldata_dev.SJXQ_SJ2023120461_tmp02
union all
SELECT '3_insu' seq,COUNT(cst_id), count(distinct cst_id)
from tldata_dev.SJXQ_SJ2023120461_tmp03
union all
SELECT '4_fund' seq,COUNT(cst_id), count(distinct cst_id)
from tldata_dev.SJXQ_SJ2023120461_tmp04
union all
SELECT '5_fund' seq,COUNT(cst_id), count(distinct cst_id)
from tldata_dev.SJXQ_SJ2023120461_tmp05
where rn=1
SELECT '6_res' seq,COUNT(cst_id), count(distinct cst_id)
from tldata_dev.SJXQ_SJ2023120461_tmp06
;
1_gold	42	42
2_fina	309	309
3_insu	8	8
4_fund	1533438	1533438
5_fund	11882	11882
6_res	14224876	14224876
*/

**SJ2023120591_1贵金属明细捆绑贷款.sql
-- ODPS SQL
-- **********************************************************************
-- 任务描述: 贵金属捆绑客户维度
-- 创建日期: 2023-12-12
-- ----------------------------------------------------------------------
-- 任务输出
-- TLDATA_DEV.SJXQ_SJ2023120591_CUST      --贵金属捆绑销售清单
-- ----------------------------------------------------------------------
-- **********************************************************************
/*
问题:
1. 以下字段需要重新确认口径
同一风险控制号
贷款客户名称
购买人是否有效信贷户
是否行内员工
同一风险控制号下是信贷有效户的客户号
购买人是否存款有效户
购买人是否理财有效户
申请贷款时客户的信用风险等级
2. 当前、上笔贷款口径不同，当前用的 贷款申请日期，上笔是 合同表中的经办日期
*/
-- ===========================================================================================================
-- Step.1  2023年贵金属购买明细表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_01;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_01 AS
SElECT ord_id               --订单号
    ,ord_tm                 --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc       --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'dtl' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di --贵金属交易明细表
where dt between '20221101' and '20231211'
and ord_tm between '2022-11-01' and '2023-12-11'
union all
SElECT ord_id               --订单号
    ,ord_tm                 --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc       --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'hand' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_hand_di	--贵金属柜面或退款交易手工表
where dt between '20221101' and '20231211'
and ord_tm between '2022-11-01' and '2023-12-11'
;

--贵金属购买明细 cst_id+TRX_DT 维度
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_01_1;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_01_1 AS
SELECT ROW_NUMBER() over(order by ord_tm,cst_id)        SYS_SRL_NBR
    ,CONCAT_WS('|', COLLECT_SET(ord_id))                ord_id
    ,ord_tm TRX_DT
    ,cst_id,cst_nm,usr_nm
    ,CONCAT_WS('|', COLLECT_SET(pvd_nm))                pvd_nm
    ,CONCAT_WS('|', COLLECT_SET(pst_mth))               pst_mth
    ,CONCAT_WS('|', COLLECT_SET(substr(pmt_tm,1,10)))   pmt_dt
    ,CONCAT_WS('|', COLLECT_SET(pmt_mth))               pmt_mth
    ,CONCAT_WS('|', COLLECT_SET(chnl_nm))               chnl_nm
    ,CONCAT_WS('|', COLLECT_SET(ord_sts))               ord_sts
    ,CONCAT_WS('|', COLLECT_SET(cmdt_nm))               prod_nm
    ,CONCAT_WS('|', COLLECT_SET(cmdt_spec))             cmdt_spec
    ,sum(qty)                                           qty
    ,CONCAT_WS('|', COLLECT_SET(goods_typ))             goods_typ
    ,CONCAT_WS('|', COLLECT_SET(goods_return_status))   goods_return_status
    ,CONCAT_WS('|', COLLECT_SET(cast(cmdt_unt_prc as string))) cmdt_unt_prc
    ,sum(cmdt_pay_unt_prc)                              TRX_AMT
    ,CONCAT_WS('|', COLLECT_SET(cmsn_typ))              cmsn_typ
    ,CONCAT_WS('|', COLLECT_SET(mid_inc_rto))           mid_inc_rto
    ,sum(mid_inc_tot_amt)                               mid_inc_tot_amt
    ,CONCAT_WS('|', COLLECT_SET(rcm_psn_id))            rcm_psn_id
    ,CONCAT_WS('|', COLLECT_SET(rcm_psn_nm))            rcm_psn_nm
    ,CONCAT_WS('|', COLLECT_SET(rcm_psn_afl_dept_id))   rcm_psn_afl_dept_id
    ,CONCAT_WS('|', COLLECT_SET(rcm_psn_afl_dept))      rcm_psn_afl_dept
    ,CONCAT_WS('|', COLLECT_SET(rcm_psn_afl_sub_brn))   rcm_psn_afl_sub_brn
    ,CONCAT_WS('|', COLLECT_SET(rcm_psn_afl_brn))       rcm_psn_afl_brn
    ,CONCAT_WS('|', COLLECT_SET(data_src))              data_src
    ,CONCAT_WS('|', COLLECT_SET(rcm_psn_pos))           rcm_psn_pos
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_01
where cst_ID<>'无'
--where cst_id= '1645866258' and ord_tm='2022-12-09'
group by ord_tm,cst_id,cst_nm,usr_nm
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_02;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_02 AS
select a.*
    ,B.prm_mgr_id MNG_MGR_ID            --管护客户经理工号
    ,b.prm_org_id MNG_ORG_ID
    ,COALESCE(F.SAM_RSK_CTRL_ID, '')                                      AS SAM_RSK_CTRL_ID       --同一风险控制号
    ,(CASE WHEN COALESCE(F.OWN_EMP_ID, '') <> '' THEN '是' ELSE '否' END) AS WTHR_INT_EMPE         --是否行内员工
    ,(CASE WHEN G.EFE_LOAN_CST_IND = '1' THEN '是' ELSE '否' END)         AS EFE_LOAN_CST_IND      --是否信贷有效户
    ,(CASE WHEN G.EFE_DEP_CST_IND  = '1' THEN '是' ELSE '否' END)         AS EFE_DEP_CST_IND       --是否存款有效户
    ,(CASE WHEN G.EFE_CHM_CST_IND  = '1' THEN '是' ELSE '否' END)         AS EFE_CHM_CST_IND       --是否理财有效户
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_01_1         a
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD  B --客户主管户信息
ON      a.CST_ID = B.CST_ID
AND     B.DT = '@@{yyyyMMdd}'
LEFT JOIN edw.DWS_CST_IDV_BAS_INF_DD                F --个人客户基本信息汇总表
ON      a.CST_ID = F.CST_ID --客户号
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN adm_pub.ADM_CSM_CBAS_IND_INF_DD           G --客户集市-基础信息-有效户基本信息
ON      a.CST_ID = G.CST_ID --客户号
AND     G.DT = '@@{yyyyMMdd}'
;


-- ===========================================================================================================
-- Step.2 同一风险控制号数据
-- 同一风险控制号_信贷有效户_临时表_02
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_03;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_03 AS
SELECT  A.SAM_RSK_CTRL_ID                      AS SAM_RSK_CTRL_ID      --同一风险控制号
       ,CONCAT_WS('|', COLLECT_SET(A.CST_ID))  AS SAM_RSK_EFE_LOAN_CST --同一风险控制号下是信贷有效户的客户号
FROM    edw.DWS_CST_BAS_INF_DD                A --客户基础信息汇总表
INNER JOIN    adm_pub.ADM_CSM_CBAS_IND_INF_DD B --客户集市-基础信息-有效户基本信息
ON      B.CST_ID = A.CST_ID         --客户号
AND     B.EFE_LOAN_CST_IND = '1'    --有效信贷户
AND     B.DT = '@@{yyyyMMdd}'
WHERE   A.SAM_RSK_CTRL_ID <> ''     --同一风险控制号 --剔除空值和空
AND     A.DT = '@@{yyyyMMdd}'
GROUP BY A.SAM_RSK_CTRL_ID
;

-- -------------------------------------------------------------------------------------
-- 同一风险控制号_临时表_04
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_04;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_04 AS
SELECT  A.CST_ID           --客户号
       ,A.CST_CHN_NM CST_NM --客户名称
       ,A.SAM_RSK_CTRL_ID  --同一风险控制号
FROM    edw.DWS_CST_BAS_INF_DD                      A --客户集市-基础信息-有效户基本信息
INNER JOIN(
    SELECT  DISTINCT B.SAM_RSK_CTRL_ID                  --贵金属客户的统一风险控制号
    FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_02    A --贵金属相关信息
    INNER JOIN edw.DWS_CST_BAS_INF_DD               B --客户集市-基础信息-有效户基本信息
    ON      A.CST_ID = B.CST_ID
    AND     B.DT = '@@{yyyyMMdd}'
)B --同一风险控制号_临时表_03
ON      A.SAM_RSK_CTRL_ID = B.SAM_RSK_CTRL_ID --同一风险控制号 要在客户基本信息表中
AND     COALESCE(B.SAM_RSK_CTRL_ID, '') <> '' --剔除空值和空
WHERE   A.DT = '@@{yyyyMMdd}'
;
-- ===========================================================================================================
-- Step.3  信贷合同信息数据
--贵金属客户的信贷合同相关信息_临时表_05
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_05;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_05 AS
SELECT  B.CST_ID
       ,(CASE SUBSTR(B.PD_CD, 1, 9)
          WHEN '201050101' THEN '1'           --20105010100 个人消费性贷款
          WHEN '201050102' THEN '2'           --20105010200 个人经营性贷款
          WHEN '201040101' THEN '3'           --20104010100 流动资金贷款
          WHEN '201040102' THEN '4'           --20104010200 固定资产贷款
          else '5'                            --20104010600 法人购房贷款
        end)               as pd_cd           --产品代码    --普通贷款产品代码二次转码
       ,b.busi_ctr_id                         --合同流水号
       ,b.ctr_amt                             --合同金额
       ,b.ctr_bal                             --合同余额
       ,b.trm_mon                             --期限月
       ,b.intr_rat                            --执行利率
       ,b.ref_mon_intr_rat                    --参考月利率
       ,c.reg_dt                              --申请日期
       ,d.dtrb_dt                             --最早发放日期
       ,b.loan_usg_cd                         --贷款用途代码
       ,b.intr_rat_adj_cmt                    --利率调整备注
       ,b.usg_cmt                             --用途备注
       ,b.cmt                                 --备注
       ,b.busi_apl_id                         --业务申请编号
       ,b.dt                                  --合同日期
from    edw.dim_bus_loan_ctr_inf_dd b       --信贷合同信息
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD C  --信贷业务申请信息
ON      B.BUSI_APL_ID = C.APL_ID --业务申请编号
AND     NVL(C.APL_ID,'') <> ''   --剔除空值和空
AND     C.DT = '@@{yyyyMMdd}'
LEFT JOIN (
            SELECT  BUS_CTR_ID               --信贷合同编号
                   ,MIN(DTRB_DT) AS DTRB_DT  --最早发放日期
              FROM edw.DWS_BUS_LOAN_DBIL_INF_DD --贷款借据信息汇总
             WHERE DT = '@@{yyyyMMdd}'
          GROUP BY BUS_CTR_ID --信贷合同编号
          )                                      D
ON      B.BUSI_CTR_ID = D.BUS_CTR_ID --信贷合同编号
where   NVL(B.CST_ID,'') <> '' --剔除空值和空
AND     B.CRC_IND <> '1'       --剔除循环贷款
AND     SUBSTR(B.PD_CD, 1, 9) IN ( '201050101' , '201050102' , '201040101' , '201040102' , '201040106' ) --产品代码
--普通贷款:-20105010100 个人消费性贷款 20105010200 个人经营性贷款 20104010100 流动资金贷款 20104010200 固定资产贷款 20104010600 法人购房贷款
AND     B.DT = '@@{yyyyMMdd}'
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_1;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_1 AS
SELECT cst_id
    ,CONCAT_WS('|', COLLECT_SET(PD_CD))                 pd_cd
    ,CONCat_ws('|', collect_set(busi_ctr_id))           busi_ctr_id
    ,sum(ctr_amt) ctr_amt,sum(ctr_bal)                  ctr_bal
    ,max(trm_mon)                                       trm_mon
    ,max(intr_rat)                                      intr_rat
    ,max(ref_mon_intr_rat)                              ref_mon_intr_rat
    ,CONCAT_WS('|', COLLECT_SET(loan_usg_cd))           loan_usg_cd
    ,CONCAT_WS('|', COLLECT_SET(intr_rat_adj_cmt))      intr_rat_adj_cmt
    ,CONCAT_WS('|', COLLECT_SET(usg_cmt))               usg_cmt
    ,CONCAT_WS('|', COLLECT_SET(cmt))                   cmt
    ,CONCAT_WS('|', COLLECT_SET(busi_apl_id))           busi_apl_id
    ,reg_dt,min(dtrb_dt) dtrb_dt
    ,count(cst_id) cnt
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_05
group by cst_id,reg_dt
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_2;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_2
(
     SYS_SRL_NBR          STRING  COMMENT '系统流水号'
    ,CST_ID               STRING  COMMENT '客户号'
    ,CST_NM               STRING  COMMENT '客户名'
    ,SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
    ,CST_OWN_IND          STRING  COMMENT '是否客户本人'
    ,PD_CD                STRING  COMMENT '产品代码'
    ,BUSI_CTR_ID          STRING  COMMENT '合同流水号'
    ,CTR_AMT              DECIMAL COMMENT '合同金额'
    ,CTR_BAL              DECIMAL COMMENT '合同余额'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,INTR_RAT             DECIMAL COMMENT '执行利率'
    ,REF_MON_INTR_RAT     DECIMAL COMMENT '参考月利率'
    ,REG_DT               STRING  COMMENT '申请日期'
    ,APNT_START_DT        STRING  COMMENT '发放日期'
    ,LOAN_USG_CD          STRING  COMMENT '贷款用途代码'
    ,INTR_RAT_ADJ_CMT     STRING  COMMENT '利率调整备注'
    ,USG_CMT              STRING  COMMENT '用途备注'
    ,CMT                  STRING  COMMENT '备注'
    ,BUSI_APL_ID          STRING  COMMENT '业务申请编号'
    ,DIFF_TM              BIGINT  COMMENT '贷款申请与贵金属购买间隔日期'
)
COMMENT '业务合同表相关信息_临时表_05'
LIFECYCLE 31;

INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_2
SELECT  A.SYS_SRL_NBR                         --系统流水号
       ,A.CST_ID           AS CST_ID          --客户号
       ,A.CST_NM           AS CST_NM          --客户名
       ,A.SAM_RSK_CTRL_ID  AS SAM_RSK_CTRL_ID --同一风险控制号
       ,A.CST_OWN_IND      AS CST_OWN_IND     --是否客户本人
       ,B.PD_CD                               --产品代码    --普通贷款产品代码二次转码
       ,B.BUSI_CTR_ID                         --合同流水号
       ,B.CTR_AMT                             --合同金额
       ,B.CTR_BAL                             --合同余额
       ,B.TRM_MON                             --期限月
       ,B.INTR_RAT                            --执行利率
       ,B.REF_MON_INTR_RAT                    --参考月利率
       ,B.REG_DT                              --申请日期
       ,B.DTRB_DT                             --最早发放日期
       ,B.LOAN_USG_CD                         --贷款用途代码
       ,B.INTR_RAT_ADJ_CMT                    --利率调整备注
       ,B.USG_CMT                             --用途备注
       ,B.CMT                                 --备注
       ,B.BUSI_APL_ID                         --业务申请编号
       ,ABS(DATEDIFF(TO_DATE(b.REG_DT, 'yyyyMMdd'), TO_DATE(SUBSTR(A.TRX_DT,1,10),'yyyy-MM-dd'), 'dd')) AS DIFF_TM --贷款申请与贵金属购买间隔日期   --信贷业务登记申请日期 -贵金属交易日期
FROM    (
         SELECT   A1.SYS_SRL_NBR                                --系统流水号
                 ,A1.TRX_DT                                     --交易日期
                 ,A1.SAM_RSK_CTRL_ID                            --同一风险控制号
                 ,COALESCE(A3.CST_ID, A1.CST_ID) AS CST_ID      --客户号
                 ,COALESCE(A3.CST_NM, A2.CST_NM) AS CST_NM      --客户名
                 ,CASE
                    WHEN A3.CST_ID IS NULL     THEN '1'
                    WHEN A3.CST_ID = A1.CST_ID THEN '1'
                    ELSE '0'
                  END                            AS CST_OWN_IND --是否客户本人
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_02      A1 --贵金属相关信息_临时表01
         LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CUST_04 A2 --同一风险控制号_临时表_04
         ON      A1.CST_ID = A2.CST_ID --客户号
         AND     NVL(A2.CST_ID,'') <> '' --剔除空值和空
         LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CUST_04 A3 --同一风险控制号_临时表_04
         ON      A2.SAM_RSK_CTRL_ID = A3.SAM_RSK_CTRL_ID --同一风险控制号
         AND     NVL(A3.SAM_RSK_CTRL_ID,'') <> '' --剔除空值和空
        )                                        A
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_1 B
ON A.CST_ID = B.CST_ID
;

-- ------------------------------------------------------------------------------------------------------------
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_06;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_06
(
     CST_ID               STRING  COMMENT '客户号'
    ,TRX_DT               STRING  COMMENT '交易日期'
    ,DEPT_CST_NAME        STRING  COMMENT '贷款客户名称'
    ,BUS_CTR_ID           STRING  COMMENT '合同流水号'
    ,CRD_CTR_AMT          DECIMAL COMMENT '贷款合同金额'
    ,REF_INTR_RAT         DECIMAL COMMENT '参考月利率'
    ,INTR_RAT             DECIMAL COMMENT '执行月利率'
    ,CRD_DTRB_DT          STRING  COMMENT '贷款发放日期'
    ,MNG_MGR_ID_1         STRING  COMMENT '贷款管护人工号'
    ,MNG_MGR_NM_1         STRING  COMMENT '贷款管护人姓名'
    ,MNG_ORG_ID_1         STRING  COMMENT '贷款管护人机构号'
    ,REG_DT               STRING  COMMENT '贷款申请日期'
    ,DIFF_TM              BIGINT  COMMENT '贷款申请与贵金属购买间隔日期'
    ,DBIL_USG             STRING  COMMENT '借据用途'
    ,CRD_TYP              STRING  COMMENT '贷款类型'
    ,CRD_MOD_MARK         STRING  COMMENT '贷款利率优惠备注'
    ,CRD_USG_MARK         STRING  COMMENT '贷款用途备注'
    ,CRD_MARK             STRING  COMMENT '贷款备注'
    ,BUSI_APL_ID          STRING  COMMENT '业务申请编号'
    ,PD_CD                STRING  COMMENT '产品代码'
    ,SYS_SRL_NBR          STRING  COMMENT '系统流水号'
    ,TRM_MON              BIGINT  COMMENT '期限月'
)
COMMENT '当前笔贷款合同相关信息_临时表_06'
LIFECYCLE 31;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_07;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_07
(
     SYS_SRL_NBR          STRING  COMMENT '贵金属流水号'
    ,BUSI_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,CST_ID               STRING  COMMENT '客户号'
    ,PD_CD                STRING  COMMENT '产品代码转换'
    ,CTR_AMT              DECIMAL COMMENT '金额'
    ,INTR_RAT             DECIMAL COMMENT '利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,HDL_DT               STRING  COMMENT '经办日期'
    ,ACG_DT               STRING  COMMENT '日期'
)
COMMENT '当前笔贷款合同相关信息_临时表_07'
LIFECYCLE 31;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_08;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_08
(
     SYS_SRL_NBR          STRING  COMMENT '贵金属流水号'
    ,LAST_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,LAST_CTR_AMT         DECIMAL COMMENT '前一笔贷款合同金额'
    ,LAST_INTR_RAT        DECIMAL COMMENT '前一笔贷款合同执行月利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
)
COMMENT '前一笔贷款信息_临时表_08'
LIFECYCLE 31;

-- 当前笔贷款合同相关信息_优先取本人贷款、其次关联人
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CUST_06
SELECT  A.CST_ID                                         AS CST_ID       --客户号
       ,A.TRX_DT                                         AS TRX_DT       --交易日期
       ,COALESCE(B.CST_NM, C.CST_NM)                     AS DEPT_CST_NM  --贷款客户名称
       ,COALESCE(B.BUSI_CTR_ID, C.BUSI_CTR_ID)           AS BUS_CTR_ID   --合同流水号
       ,COALESCE(B.CTR_AMT, C.CTR_AMT)                   AS CRD_CTR_AMT  --贷款合同金额
       ,COALESCE(B.REF_MON_INTR_RAT, C.REF_MON_INTR_RAT) AS REF_INTR_RAT --参考月利率
       ,COALESCE(B.INTR_RAT, C.INTR_RAT)                 AS INTR_RAT     --执行月利率
       ,COALESCE(B.APNT_START_DT, C.APNT_START_DT)       AS CRD_DTRB_DT  --贷款发放日期
       ,D.ACS_MNGR_ID                                    AS MNG_MGR_ID_1 --管护客户经理工号
       ,E.EMPE_NM                                        AS MNG_MGR_NM_1 --管护客户经理姓名
       ,D.ACS_ORG_ID                                     AS MNG_ORG_ID_1 --管护机构号
       ,COALESCE(B.REG_DT, C.REG_DT)                     AS REG_DT       --贷款申请日期
       ,COALESCE(B.DIFF_TM, C.DIFF_TM)                   AS DIFF_TM      --贷款申请与贵金属购买间隔日期
       ,''                                               AS DBIL_USG     --借据用途
       ,COALESCE(G.CD_VAL_DSCR, '')                      AS CRD_TYP      --贷款类型(码值含义)
       ,COALESCE(B.INTR_RAT_ADJ_CMT, C.INTR_RAT_ADJ_CMT) AS CRD_MOD_MARK --贷款利率优惠备注
       ,COALESCE(B.USG_CMT, C.USG_CMT)                   AS CRD_USG_MARK --贷款用途备注
       ,COALESCE(B.CMT, C.CMT)                           AS CRD_MARK     --贷款备注
       ,COALESCE(B.BUSI_APL_ID, C.BUSI_APL_ID)           AS BUSI_APL_ID  --业务申请编号
       ,COALESCE(B.PD_CD, C.PD_CD)                       AS PD_CD        --产品代码
       ,A.SYS_SRL_NBR                                    AS SYS_SRL_NBR  --系统流水号
       ,COALESCE(B.TRM_MON,C.TRM_MON)                    AS TRM_MON      --期限月
FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_02 A --贵金属相关信息_临时表01
LEFT JOIN    (
              SELECT   T.*
                      ,ROW_NUMBER() OVER (PARTITION BY SYS_SRL_NBR ORDER BY DIFF_TM ASC) AS RN
              FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_2 T --业务合同相关信息_临时表_05
              WHERE   T.CST_OWN_IND = '1' --客户本人
              AND     T.DIFF_TM <= 15     --贷款申请与贵金属购买间隔日期
             )                                          B
ON      A.SYS_SRL_NBR = B.SYS_SRL_NBR --系统流水号
AND     B.RN = 1
LEFT JOIN    (
              SELECT   T.*
                      ,ROW_NUMBER() OVER (PARTITION BY SYS_SRL_NBR ORDER BY DIFF_TM ASC) AS RN
              FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_2 T --业务合同相关信息_临时表_05
              WHERE   T.CST_OWN_IND = '0' --非客户本人，同一风险控制号下的其他客户
              AND     T.DIFF_TM <= 15     --贷款申请与贵金属购买间隔日期
             )                                          C
ON      A.SYS_SRL_NBR = C.SYS_SRL_NBR --系统流水号
AND     C.RN = 1
LEFT JOIN    edw.DWD_BUS_LOAN_CTR_MGR_INF_DD    D --信贷合同管护信息
ON      COALESCE(B.BUSI_CTR_ID, C.BUSI_CTR_ID) = D.BUSI_CTR_ID --合同流水号
AND     D.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWS_HR_EMPE_INF_DD             E --员工汇总信息
ON      D.ACS_MNGR_ID = E.EMPE_ID --管护客户经理工号
AND     E.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD        F --信贷业务申请信息
ON      COALESCE(B.BUSI_APL_ID, C.BUSI_APL_ID) = F.APL_ID
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_CODE_LIBRARY_DD            G --码值表(发生类型)
ON      F.HPN_TYP_CD = G.CD_VAL --发生类型 码值
AND     G.TBL_NM = 'DIM_BUS_LOAN_CTR_INF_DD'     -- DWD_BUS_LOAN_APL_INF_DD 该表码值表错误
AND     G.FLD_NM = 'HPN_TYP_CD'
AND     G.DT = '@@{yyyyMMdd}';

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_06_1
(
     BUSI_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,CST_ID               STRING  COMMENT '客户号'
    ,PD_CD                STRING  COMMENT '产品代码转换'
    ,CTR_AMT              DECIMAL COMMENT '金额'
    ,INTR_RAT             DECIMAL COMMENT '利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,HDL_DT               STRING  COMMENT '经办日期'
    ,ACG_DT               STRING  COMMENT '日期'
)
COMMENT '贷款合同信息_历史存续状态_临时表'
LIFECYCLE 31;

INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CUST_06_1
SELECT  A.BUSI_CTR_ID              --前一笔贷款合同
       ,A.CST_ID                   --客户号
       ,(CASE SUBSTR(A.PD_CD, 1, 9)
         WHEN '201050101' THEN '1' --20105010100 个人消费性贷款
         WHEN '201050102' THEN '2' --20105010200 个人经营性贷款
         WHEN '201040101' THEN '3' --20104010100 流动资金贷款
         WHEN '201040102' THEN '4' --20104010200 固定资产贷款
         ELSE '5'                  --20104010600 法人购房贷款
       END)              AS PD_CD  --产品代码转换
       ,A.CTR_AMT                  --金额
       ,A.INTR_RAT                 --利率
       ,A.TRM_MON                  --期限月
       ,A.HDL_DT                   --经办日期
       ,A.DT             AS ACG_DT --日期
FROM    edw.DIM_BUS_LOAN_CTR_INF_DD A --信贷合同信息
WHERE   A.CRC_IND <> '1'    --剔除循环贷款
AND     SUBSTR(A.PD_CD, 1, 9) IN ('201050101', '201050102', '201040101', '201040102', '201040106') --产品代码 --普通贷款
AND     A.DT <= '@@{yyyyMMdd}' and a.dt>='20220701'
AND     A.CTR_BAL > 0           --余额不为0，存续
;



-- ------------------------------------------------------------------------------------------------------------
-- 历史贷款合同相关信息_临时表_07
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CUST_07
SELECT  B.SYS_SRL_NBR --贵金属流水号
       ,A.BUSI_CTR_ID --前一笔贷款合同
       ,A.CST_ID      --客户号
       ,A.PD_CD       --产品代码转换
       ,A.CTR_AMT     --金额
       ,A.INTR_RAT    --利率
       ,A.TRM_MON     --期限月
       ,A.HDL_DT      --经办日期
       ,A.ACG_DT      --日期
FROM  TLDATA_DEV.SJXQ_SJ2023120591_CUST_06_1 A --贷款合同信息_历史存续状态_临时表
INNER JOIN (
           SELECT  DISTINCT
                   SYS_SRL_NBR  --贵金属流水号
                  ,CST_ID       --客户号
             FROM TLDATA_DEV.SJXQ_SJ2023120591_CUST_06
            WHERE COALESCE(BUS_CTR_ID, '') <> '' --合同流水号 --剔除空值和空
            )                               B
ON      A.CST_ID = B.CST_ID
;

-- ------------------------------------------------------------------------------------------------------------
-- 前一笔贷款信息_临时表_08
-- 若在贵金属交易日前后30天内存在贷款申请的，则取其中与贵金属交易日最近的一笔贷款申请（该笔贷款额度为X）
-- 并取该笔贷款申请往前3个月内存续的上一笔贷款申请（该笔贷款额度为Y）
--
-- 前一笔：选择同一业务品种，且与当前笔不是同一天申请的贷款，当前笔贷款申请日往前3个月内有余额的
-- 也要剔除&ldquo;业务品种&rdquo;是&ldquo;随贷通&rdquo;，及&ldquo;是否循环贷款&rdquo;为&ldquo;是&rdquo;的贷款。前一笔考虑同一客户号下的前一笔。
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CUST_08
SELECT   T.SYS_SRL_NBR                   --贵金属流水号
        ,T.BUSI_CTR_ID  AS LAST_CTR_ID   --前一笔贷款合同
        ,T.CTR_AMT      AS LAST_CTR_AMT  --前一笔贷款合同金额
        ,T.INTR_RAT     AS LAST_INTR_RAT --前一笔贷款合同执行月利率
        ,T.TRM_MON                       --期限月
FROM    (
         SELECT   A.SYS_SRL_NBR --贵金属流水号
                 ,B.BUSI_CTR_ID --前一笔贷款合同
                 ,B.CTR_AMT     --前一笔贷款合同金额
                 ,B.INTR_RAT    --前一笔贷款合同执行月利率
                 ,B.TRM_MON     --期限月
                 ,ROW_NUMBER() OVER ( PARTITION BY A.SYS_SRL_NBR ORDER BY B.HDL_DT DESC ) AS RN --贵金属流水号 分组 -- 经办日期 倒序
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_06     A
         INNER JOIN  TLDATA_DEV.SJXQ_SJ2023120591_CUST_07 B
         ON      A.SYS_SRL_NBR = B.SYS_SRL_NBR --贵金属流水号
         AND     A.CST_ID      = B.CST_ID      --客户号
         AND     A.PD_CD       = B.PD_CD       --产品代码
         AND     B.ACG_DT >= TO_CHAR(DATEADD(TO_DATE(A.REG_DT, 'yyyyMMdd'), 0-90, 'dd'), 'yyyyMMdd') --贷款申请日期 --当前笔往前推3个月，有存续的
         AND     B.ACG_DT <  A.REG_DT
        ) T
WHERE   T.RN = 1;


-- ===========================================================================================================
-- 建表语句
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_09
(
     EMPE_ID STRING COMMENT '员工号'
    ,EMPE_NM STRING COMMENT '员工姓名'
    ,POS_NM  STRING COMMENT '职位名称'
)
COMMENT '员工信息处理_临时表_09'
LIFECYCLE 31;

-- ===========================================================================================================
-- Step.4  员工信息处理
-- 员工信息处理_临时表_09
INSERT   OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CUST_09
SELECT   A.EMPE_ID AS EMPE_ID --员工号
        ,A.EMPE_NM AS EMPE_NM --员工姓名
        ,B.POS_NM  AS POS_NM  --职位名称
FROM    edw.DWS_HR_EMPE_INF_DD          A -- 员工汇总信息
INNER JOIN    edw.DIM_HR_ORG_JOB_INF_DD B -- 职位信息
ON      B.POS_ID = A.POS_ENC --职位编号
AND     B.DT = '@@{yyyyMMdd}'
WHERE   A.DT = '@@{yyyyMMdd}';


-- ===========================================================================================================
-- Step.5  贵金属捆绑销售清单_最终汇总处理
-- 贵金属捆绑销售清单预处理_临时表_10
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_10;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_10 AS
SELECT  '@@{yyyy-MM-dd}'                                      AS ACG_DT               --数据日期
        ,A.SYS_SRL_NBR
        ,substr(A.TRX_DT,1,10)                                AS TRX_DT               --交易日期
        ,A.PROD_NM                                            AS PROD_NM              --产品名称
        ,A.ORD_ID                                             AS ORD_ID               --订单号
        ,A.ORD_STS                                            AS ORD_STS              --订单状态
        ,COALESCE(E.EMPE_NM, '')                              AS SAL_PPL_NM           --销售人员姓名  --销售客户经理姓名
        ,COALESCE(E.POS_NM, '')                               AS SAL_PPL_POS          --销售人员岗位
        ,A.MNG_MGR_ID                                         AS MNG_MGR_ID           --管户客户经理工号
        ,COALESCE(F.EMPE_NM, '')                              AS MNG_MGR_NM           --管户客户经理姓名
        ,COALESCE(F.POS_NM, '')                               AS MNG_MGR_POS          --管户人岗位
        ,A.MNG_ORG_ID                                         AS MNG_ORG_ID           --管户人机构号
        ,COALESCE(G.ORG_NM, '')                               AS MNG_ORG_NM           --管户人机构名称
        ,A.TRX_AMT                                            AS TRX_AMT              --交易金额
        ,A.SAM_RSK_CTRL_ID                                    AS SAM_RSK_CTRL_ID      --同一风险控制号
        ,A.CST_ID                                             AS CST_ID               --客户号
        ,COALESCE(C.DEPT_CST_NAME, '')                        AS DEPT_CST_NAME        --贷款客户名称
        ,A.EFE_LOAN_CST_IND                                   AS EFE_LOAN_CST_IND     --是否信贷有效户
        ,A.WTHR_INT_EMPE                                      AS WTHR_INT_EMPE        --是否行内员工
        ,COALESCE(B.SAM_RSK_EFE_LOAN_CST, '')                 AS SAM_RSK_EFE_LOAN_CST --同一风险控制号下是信贷有效户的客户号
        ,A.EFE_DEP_CST_IND                                    AS EFE_DEP_CST_IND      --是否存款有效户
        ,A.EFE_CHM_CST_IND                                    AS EFE_CHM_CST_IND      --是否理财有效户
        ,COALESCE(C.BUS_CTR_ID, '')                           AS BUS_CTR_ID           --当前笔贷款合同流水号
        ,(CASE WHEN J.CST_RSK_GRD = '1' THEN '低风险'
               WHEN J.CST_RSK_GRD = '2' THEN '中低风险'
               WHEN J.CST_RSK_GRD = '3' THEN '中风险'
               WHEN J.CST_RSK_GRD = '4' THEN '中高风险'
               WHEN J.CST_RSK_GRD = '5' THEN '高风险'
               WHEN J.CST_RSK_GRD = '6' THEN '黑名单'
               ELSE ''
          END)                                                AS CST_RSK_GRD          --申请贷款时客户的信用风险等级
        ,(CASE WHEN J.FIVE_CTG_CD = '01' THEN '正常一级'
               WHEN J.FIVE_CTG_CD = '02' THEN '正常二级'
               WHEN J.FIVE_CTG_CD = '03' THEN '正常三级'
               WHEN J.FIVE_CTG_CD = '04' THEN '正常四级'
               WHEN J.FIVE_CTG_CD = '05' THEN '正常五级'
               WHEN J.FIVE_CTG_CD = '06' THEN '正常六级'
               WHEN J.FIVE_CTG_CD = '07' THEN '关注一级'
               WHEN J.FIVE_CTG_CD = '08' THEN '关注二级'
               WHEN J.FIVE_CTG_CD = '09' THEN '次级一级'
               WHEN J.FIVE_CTG_CD = '10' THEN '次级二级'
               WHEN J.FIVE_CTG_CD = '11' THEN '可疑'
               WHEN J.FIVE_CTG_CD = '12' THEN '损失'
               ELSE ''
           END)                                               AS FIVE_CTG_NM          --当前笔的当前五级分类
        ,COALESCE(C.CRD_CTR_AMT, 0)                           AS CRD_CTR_AMT          --当前笔合同金额
        ,C.REF_INTR_RAT                                       AS REF_INTR_RAT         --当前笔参考月利率
        ,C.INTR_RAT                                           AS INTR_RAT             --当前笔执行月利率
        ,COALESCE(H.DEP_LN_ACM_RTO, '')                       AS DEP_LN_ACM_RTO       --当前笔合同存贷积数比
        ,COALESCE(C.TRM_MON, 0)                               AS TRM_MON              --当前笔合同期限月
        ,D.LAST_CTR_ID                                        AS LAST_CTR_ID          --前一笔贷款合同流水号
        ,COALESCE(D.LAST_CTR_AMT,0)                           AS LAST_CTR_AMT         --前一笔贷款合同金额
        ,D.LAST_INTR_RAT                                      AS LAST_INTR_RAT        --前一笔贷款合同执行月利率
        ,D.TRM_MON                                            AS LAST_TRM_MON         --前一笔合同期限月
        ,CASE
           WHEN D.LAST_INTR_RAT > 0 THEN D.LAST_INTR_RAT - C.INTR_RAT
           ELSE NULL
         END                                                  AS INTR_RAT_SPRD        --前一笔执行月利率-当前执行月利率
        ,C.CRD_DTRB_DT                                        AS CRD_DTRB_DT          --贷款发放日期
        ,COALESCE(C.MNG_MGR_ID_1, '')                         AS MNG_MGR_ID_1         --贷款管护人工号
        ,COALESCE(C.MNG_MGR_NM_1, '')                         AS MNG_MGR_NM_1         --贷款管护人姓名
        ,COALESCE(C.MNG_ORG_ID_1, '')                         AS MNG_ORG_ID_1         --贷款管护人机构号
        ,C.REG_DT                                             AS REG_DT               --贷款申请日期
        ,C.DIFF_TM                                            AS DIFF_TM              --贷款申请与贵金属购买间隔日期
        ,REPLACE(C.DBIL_USG,',', ';')                         AS DBIL_USG             --借据用途
        ,COALESCE(C.CRD_TYP, '')                              AS CRD_TYP              --贷款类型
        ,REPLACE(C.CRD_MOD_MARK,',', ';')                     AS CRD_MOD_MARK         --贷款利率优惠备注
        ,REPLACE(C.CRD_USG_MARK,',', ';')                     AS CRD_USG_MARK         --贷款用途备注
        ,REPLACE(C.CRD_MARK,',', ';')                         AS CRD_MARK             --贷款备注
        ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001
           ELSE NULL
         END)                                                 AS LOAN_RAT_SPRD        --贷款利息差
        ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001 - A.TRX_AMT
           ELSE NULL
         END)                                                 AS RAT_SPRD_AMT_INC     --利息差-贵金属购买金额
         ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001 - A.MID_INC_TOT_AMT
           ELSE NULL
         END)                                                 AS RAT_SPRD_MID_INC     --利息差-中收
        ,(CASE WHEN I.BUS_CTR_ID IS NOT NULL THEN '当前笔为低息贷款'
            ELSE '当前笔为非低息贷款' END)                     AS DX_IND               --当前笔是否低息贷款
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'yyyyMMdd'), TO_DATE(substr(A.TRX_DT,1,10), 'yyyy-MM-dd'), 'dd')  AS DIFF_DATE --日期差
FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_02          A --贵金属相关信息_临时表01
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CUST_03     B --风险控制下有效信贷户
ON      B.SAM_RSK_CTRL_ID = A.SAM_RSK_CTRL_ID --同一风险控制号
INNER JOIN    (
               SELECT   A.*
                       ,ROW_NUMBER() OVER ( PARTITION BY A.SYS_SRL_NBR ORDER BY A.REG_DT DESC ) AS RN --贵金属流水号 --贷款申请日期
               FROM    TLDATA_DEV.SJXQ_SJ2023120591_CUST_06 A
              )                                                  C --当前笔贷款合同相关信息
ON      C.SYS_SRL_NBR = A.SYS_SRL_NBR --贵金属流水号
AND     RN = 1
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CUST_08     D --前一笔贷款信息
ON      A.SYS_SRL_NBR = D.SYS_SRL_NBR --贵金属流水号
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CUST_09     E --员工信息
ON      A.RCM_PSN_ID = E.EMPE_ID --销售人员工号
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CUST_09     F --员工信息
ON      A.MNG_MGR_ID = F.EMPE_ID --管护客户经理工号
LEFT JOIN    edw.DIM_HR_ORG_BAS_INF_DD                   G --机构信息
ON      A.MNG_ORG_ID = G.ORG_ID  --管护机构号
AND     G.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD                 H --信贷业务申请信息
ON      C.BUSI_APL_ID = H.APL_ID --业务申请编号
AND     H.DT = '@@{yyyyMMdd}'
LEFT JOIN app_awp.OICS_FCT_GNRL_LOAN_AR_DTL_SMY_DD       I --普通贷款借据明细表(部分逻辑) 46273 仅有字段 BUS_CTR_ID
ON      C.BUS_CTR_ID = I.BUS_CTR_ID --信贷合同编号
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD                 J --信贷合同信息
ON      C.BUS_CTR_ID = J.BUSI_CTR_ID --信贷合同编号
AND     J.DT = '@@{yyyyMMdd}'; --交易日期

-- -----------------------------------------------------------------------------------------------------------



-- 贵金属捆绑销售清单
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_11;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_11 AS
SELECT  DISTINCT a.SYS_SRL_NBR
        ,A.ACG_DT                --数据日期
       ,A.TRX_DT                --交易日期
       ,A.PROD_NM               --产品名称
       ,A.ORD_ID                --订单号
       ,A.ORD_STS               --订单状态
       ,A.SAL_PPL_NM            --销售人员姓名
       ,A.SAL_PPL_POS           --销售人员岗位
       ,A.MNG_MGR_ID            --管户客户经理工号
       ,A.MNG_MGR_NM            --管户客户经理姓名
       ,A.MNG_MGR_POS           --管户人岗位
       ,A.MNG_ORG_ID            --管户人机构号
       ,A.MNG_ORG_NM            --管户人机构名称
       ,A.TRX_AMT               --交易金额
       ,A.SAM_RSK_CTRL_ID       --同一风险控制号
       ,A.CST_ID                --客户号
       ,A.DEPT_CST_NAME         --贷款客户名称
       ,A.EFE_LOAN_CST_IND      --是否信贷有效户
       ,A.WTHR_INT_EMPE         --是否行内员工
       ,A.SAM_RSK_EFE_LOAN_CST  --同一风险控制号下是信贷有效户的客户号
       ,A.EFE_DEP_CST_IND       --是否存款有效户
       ,A.EFE_CHM_CST_IND       --是否理财有效户
       ,A.BUS_CTR_ID            --当前笔合同流水号
       ,A.CST_RSK_GRD           --申请贷款时客户的信用风险等级  --原注释: 信用风险等级 当前笔当前的客户信用风险等级
       ,A.FIVE_CTG_NM           --当前笔的当前五级分类         --原注释: 当前笔贷款风险等级
       ,(CASE WHEN E.HPN_TYP_CD = '015' THEN D.PD_CD ELSE '' END) AS ZQ_IND  --当前笔是否展期贷款
       ,(CASE WHEN E.BUS_ID     = 'J'   THEN D.PD_CD ELSE '' END) AS ZXT_IND --当前笔是否助兴通
       ,A.CRD_CTR_AMT           --当前笔合同金额
       ,A.REF_INTR_RAT          --当前笔参考月利率
       ,A.INTR_RAT              --当前笔执行月利率
       ,A.DEP_LN_ACM_RTO        --当前笔合同存贷积数比
       ,A.TRM_MON               --当前笔合同期限月
       ,A.LAST_CTR_ID           --前一笔贷款合同流水号
       ,A.LAST_CTR_AMT          --前一笔贷款合同金额
       ,A.LAST_INTR_RAT         --前一笔贷款合同执行月利率
       ,A.LAST_TRM_MON          --前一笔合同期限月
       ,ROUND(case when coalesce(A.LAST_CTR_AMT,0) =0 then 0
            else coalesce(A.CRD_CTR_AMT,0)/A.LAST_CTR_AMT end, 2) AS CRD_LAST_CTR_AMT --当前笔合同金额/前一笔
       ,A.INTR_RAT_SPRD         --前一笔执行月利率-当前执行月利率
       ,A.CRD_DTRB_DT           --贷款发放日期
       ,A.MNG_MGR_ID_1          --贷款管护人工号
       ,A.MNG_MGR_NM_1          --贷款管护人姓名
       ,A.MNG_ORG_ID_1          --贷款管护人机构号
       ,A.REG_DT                --贷款申请日期
       ,A.DIFF_TM               --贷款申请与贵金属购买间隔日期
       ,A.DBIL_USG              --借据用途
       ,A.CRD_TYP               --贷款类型
       ,A.CRD_MOD_MARK          --贷款利率优惠备注
       ,A.CRD_USG_MARK          --贷款用途备注
       ,A.CRD_MARK              --贷款备注
       ,A.LOAN_RAT_SPRD         --贷款利息差
       ,A.RAT_SPRD_AMT_INC      --利息差-贵金属购买金额
       ,A.RAT_SPRD_MID_INC      --利息差-中收
       ,COALESCE(A.CRD_CTR_AMT-A.LAST_CTR_AMT-A.TRX_AMT,0) loan_diff_gold_amt    --贷款额度差-贵金属购买金额
       ,A.DX_IND                --当前笔是否低息贷款
       ,(CASE WHEN A.DIFF_TM >= 0 AND A.DIFF_TM <= 3  THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15
             AND (A.CRD_MOD_MARK LIKE '%贵金属%' OR A.CRD_USG_MARK LIKE '%贵金属%' OR A.CRD_MARK LIKE '%贵金属%' ) THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND A.LAST_INTR_RAT > 0 AND A.CRD_CTR_AMT * A.TRM_MON * (A.LAST_INTR_RAT - A.INTR_RAT) * 0.001 - A.TRX_AMT * 0.5 >= 0 THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND A.LAST_CTR_AMT  > 0 AND A.CRD_CTR_AMT / A.LAST_CTR_AMT > 1 AND A.CRD_CTR_AMT / A.LAST_CTR_AMT <= 1.2 THEN '是'
            WHEN (A.CST_RSK_GRD IN ('高风险','黑名单') OR A.FIVE_CTG_NM IN ('关注一级', '关注二级', '次级一级', '次级二级', '可疑', '损失')) THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND E.HPN_TYP_CD = '015' THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND E.BUS_ID     = 'J'   THEN '是'
            ELSE '否' END)      AS IS_BIND   --是否疑似捆绑
FROM TLDATA_DEV.SJXQ_SJ2023120591_CUST_10  A --贵金属捆绑销售清单预处理_临时表_10
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD      D --信贷合同信息
ON      A.BUS_CTR_ID = D.BUSI_CTR_ID --合同流水号
AND     D.DT = '@@{yyyyMMdd}'
LEFT JOIN    (
              SELECT  APL_ID       --申请编号
                     ,HPN_TYP_CD   --发生类型代码
                     ,BUS_ID       --业务标识
              FROM    edw.DWD_BUS_LOAN_APL_INF_DD --信贷业务申请信息
              WHERE   DT = '@@{yyyyMMdd}'
              AND     (HPN_TYP_CD = '015' OR BUS_ID = 'J') --发生类型代码  --业务标识
             )                                        E
ON      D.BUSI_APL_ID = E.APL_ID --申请编号
;

--结果表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_12;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CUST_12 AS
SElECT DISTINCT A.SYS_SRL_NBR   序号
    ,A.DATA_SRC        		    数据来源
    ,A.PVD_NM                  商铺名称
    ,A.ORD_ID                  订单号
    ,A.USR_NM                  买家名称
    ,A.CST_ID                  客户号
    ,A.CST_NM                  真实姓名
    ,A.PST_MTH                 邮寄方式
    ,A.TRX_DT                  下单日期
    ,A.pmt_dt                  付款时间
    ,A.PMT_MTH                 支付方式
    ,A.CHNL_NM                 渠道
    ,A.ORD_STS                 订单状态
    ,A.PROD_NM                 商品名称
    ,A.CMDT_SPEC               商品规格
    ,A.QTY                     购买数量
    ,A.GOODS_TYP               商品分类
    ,A.GOODS_RETURN_STATUS     商品退款状态
    ,A.CMDT_UNT_PRC            商品现金单价
    ,A.TRX_AMT                 商品应付现金总额
    ,A.CMSN_TYP                佣金类型
    ,A.MID_INC_RTO             佣金比例_金额
    ,A.MID_INC_TOT_AMT         佣金总额
    ,A.RCM_PSN_ID              推荐人工号
    ,A.RCM_PSN_NM              推荐人姓名
    ,A.RCM_PSN_AFL_DEPT_ID     推荐人所属部门_团队id
    ,A.RCM_PSN_AFL_DEPT        推荐人所属部门_团队
    ,A.RCM_PSN_AFL_SUB_BRN     支行名称
    ,A.RCM_PSN_AFL_BRN         分行名称

    ,B.SAM_RSK_CTRL_ID       同一风险控制号
    ,B.DEPT_CST_NAME         贷款客户名称
    ,B.EFE_LOAN_CST_IND      是否信贷有效户
    ,B.WTHR_INT_EMPE         是否行内员工
    ,B.SAM_RSK_EFE_LOAN_CST  同一风险控制号下是信贷有效户的客户号
    ,B.EFE_DEP_CST_IND       是否存款有效户
    ,B.EFE_CHM_CST_IND       是否理财有效户
    ,B.BUS_CTR_ID            当前笔合同流水号
    ,B.CST_RSK_GRD           申请贷款时客户的信用风险等级
    ,B.FIVE_CTG_NM           当前笔的当前五级分类
    ,B.ZQ_IND               当前笔是否展期贷款
    ,B.ZXT_IND              当前笔是否助兴通
    ,B.CRD_CTR_AMT           当前笔合同金额
    ,B.REF_INTR_RAT          当前笔参考月利率
    ,B.INTR_RAT              当前笔执行月利率
    ,B.DEP_LN_ACM_RTO        当前笔合同存贷积数比
    ,B.TRM_MON               当前笔合同期限月
    ,B.LAST_CTR_ID           前一笔贷款合同流水号
    ,B.LAST_CTR_AMT          前一笔贷款合同金额
    ,B.CRD_LAST_CTR_AMT     当前笔合同金额比前一笔
    ,B.LAST_INTR_RAT         前一笔贷款合同执行月利率
    ,B.LAST_TRM_MON          前一笔合同期限月
    ,B.INTR_RAT_SPRD         前一笔执行月利率_当前执行月利率
    ,B.CRD_DTRB_DT           贷款发放日期
    ,B.MNG_MGR_ID_1          贷款管护人工号
    ,B.MNG_MGR_NM_1          贷款管护人姓名
    ,B.MNG_ORG_ID_1          贷款管护人机构号
    ,B.REG_DT                贷款申请日期
    ,B.DIFF_TM               贷款申请与贵金属购买间隔日期
    ,B.DBIL_USG              借据用途
    ,B.CRD_TYP               贷款类型
    ,B.CRD_MOD_MARK          贷款利率优惠备注
    ,B.CRD_USG_MARK          贷款用途备注
    ,B.CRD_MARK              贷款备注
    ,B.LOAN_RAT_SPRD         贷款利息差
    ,B.RAT_SPRD_AMT_INC      利息差_贵金属购买金额
    ,B.RAT_SPRD_MID_INC      利息差_中收
    ,B.loan_diff_gold_amt    贷款额度差_贵金属购买金额
    ,B.DX_IND                当前笔是否低息贷款
    ,b.IS_BIND              是否疑似捆绑
FROM TLDATA_DEV.SJXQ_SJ2023120591_CUST_02        A
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023120591_CUST_11   B
ON A.SYS_SRL_NBR = B.SYS_SRL_NBR
ORDER BY A.SYS_SRL_NBR
;
/*
--数据核验
SELECT '1' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_01
union all
SELECT '11' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_01_1
union all
SELECT '2' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_02
union all
SELECT '3' seq,count(1) cnt,count(DISTINCT SAM_RSK_CTRL_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_03
union all
SELECT '4' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_04
union all
SELECT '5' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_05
union all
SELECT '51' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_1
union all
SELECT '52' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_05_2
union all
SELECT '6' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_06
union all
SELECT '61' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_06_1
union all
SELECT '7' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_07
union all
SELECT '8' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_08
union all
SELECT '9' seq,count(1) cnt,count(DISTINCT EMPE_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_09
union all
SELECT '10' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_10
union all
SELECT '11' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_11
union all
SELECT '12' seq,count(1) cnt,count(DISTINCT 序号)
from TLDATA_DEV.SJXQ_SJ2023120591_CUST_12
;
1	24200	16047
11	20336	20336
2	20336	20336
3	529025	529025
4	37088	37088
5	2858616	870589
51	2821671	870589
52	93858	20336
6	20336	20336
61	123997834	295056
7	1260124	2327
8	1472	1472
9	21955	21955
10	20336	20336
11	20336	20336
12	20336	20336
*/
**SJ2023120591_2贷款客户关联贵金属明细.sql
-- ODPS SQL
-- **********************************************************************
-- 任务描述: 贵金属捆绑客户维度
-- 创建日期: 2023-12-13
-- ----------------------------------------------------------------------
-- 任务输出
-- TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST      --贵金属捆绑销售清单
-- ----------------------------------------------------------------------
-- **********************************************************************
/* 贷款逻辑：申请、合同、贷款
*/
-- ===========================================================================================================
-- Step.1  贷款合同明细表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01 AS
SELECT  b.busi_ctr_id                         --合同流水号
    ,B.CST_ID,B.CST_NM
    ,COALESCE(F.SAM_RSK_CTRL_ID, '')               AS SAM_RSK_CTRL_ID
    ,(CASE SUBSTR(B.PD_CD, 1, 9)
        WHEN '201050101' THEN '1'           --20105010100 个人消费性贷款
        WHEN '201050102' THEN '2'           --20105010200 个人经营性贷款
        WHEN '201040101' THEN '3'           --20104010100 流动资金贷款
        WHEN '201040102' THEN '4'           --20104010200 固定资产贷款
        else '5'                            --20104010600 法人购房贷款
    end)               as pd_cd           --产品代码    --普通贷款产品代码二次转码
    ,(CASE b.CST_RSK_GRD WHEN '1' THEN '低风险' WHEN '2' THEN '中低风险'
        WHEN '3' THEN '中风险' WHEN '4' THEN '中高风险' WHEN '5' THEN '高风险'
        WHEN '6' THEN '黑名单' ELSE '' END)    AS CST_RSK_GRD          --申请贷款时客户的信用风险等级
    ,(CASE b.FIVE_CTG_CD WHEN '01' THEN '正常一级' WHEN '02' THEN '正常二级'
        WHEN '03' THEN '正常三级' WHEN '04' THEN '正常四级' WHEN '05' THEN '正常五级'
        WHEN '06' THEN '正常六级' WHEN '07' THEN '关注一级' WHEN '08' THEN '关注二级'
        WHEN '09' THEN '次级一级' WHEN '10' THEN '次级二级' WHEN '11' THEN '可疑'
        WHEN '12' THEN '损失' ELSE '' END)  AS FIVE_CTG_NM
    ,(CASE WHEN C.HPN_TYP_CD = '015' THEN B.PD_CD ELSE '' END) AS ZQ_IND  --当前笔是否展期贷款
    ,(CASE WHEN C.BUS_ID     = 'J'   THEN B.PD_CD ELSE '' END) AS ZXT_IND --当前笔是否助兴通
    ,c.hpn_typ_cd,c.BUS_ID
    ,b.ctr_amt                             --合同金额
    ,b.ctr_bal                             --合同余额
    ,b.trm_mon                             --期限月
    ,b.intr_rat                            --执行利率
    ,b.ref_mon_intr_rat                    --参考月利率
    ,COALESCE(c.DEP_LN_ACM_RTO, '') AS DEP_LN_ACM_RTO --当前笔合同存贷积数比
    ,c.reg_dt                              --申请日期
    ,d.dtrb_dt                             --发放日期
    ,E.ACS_MNGR_ID      AS MNG_MGR_ID_1 --管护客户经理工号
    ,E.ACS_ORG_ID       AS MNG_ORG_ID_1 --管护机构号
    ,COALESCE(G.CD_VAL_DSCR, '')  AS CRD_TYP      --贷款类型(码值含义)
    ,B.INTR_RAT_ADJ_CMT         AS CRD_MOD_MARK --贷款利率优惠备注
    ,B.USG_CMT                  AS CRD_USG_MARK --贷款用途备注
    ,B.CMT                      AS CRD_MARK     --贷款备注
    ,b.loan_usg_cd                         --贷款用途代码
    ,b.busi_apl_id                         --业务申请编号
    , ( CASE WHEN I.BUS_CTR_ID IS NOT NULL THEN '低息'
        ELSE '非低息' END ) AS DX_IND --当前笔是否低息贷款
from edw.dim_bus_loan_ctr_inf_dd        b  --信贷合同信息
INNER JOIN edw.DWD_BUS_LOAN_APL_INF_DD   C  --信贷业务申请信息
ON      B.BUSI_APL_ID = C.APL_ID --业务申请编号
AND     NVL(C.APL_ID,'') <> ''   --剔除空值和空
AND     C.DT = '@@{yyyyMMdd}'
and     C.REG_DT>='20221201' AND C.REG_DT<='@@{yyyyMMdd}'
LEFT JOIN (
            SELECT  BUS_CTR_ID               --信贷合同编号
                   ,MIN(DTRB_DT) AS DTRB_DT  --最早发放日期
              FROM edw.DWS_BUS_LOAN_DBIL_INF_DD --贷款借据信息汇总
             WHERE DT = '@@{yyyyMMdd}'
          GROUP BY BUS_CTR_ID --信贷合同编号
          )                                      D
ON      B.BUSI_CTR_ID = D.BUS_CTR_ID --信贷合同编号
LEFT JOIN    edw.DWD_BUS_LOAN_CTR_MGR_INF_DD    E --信贷合同管护信息
ON      B.BUSI_CTR_ID = E.BUSI_CTR_ID --合同流水号
AND     E.DT = '@@{yyyyMMdd}'
LEFT JOIN edw.DWS_CST_BAS_INF_DD                F --个人客户基本信息汇总表
ON      B.CST_ID = F.CST_ID --客户号
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_CODE_LIBRARY_DD            G --码值表(发生类型)
ON      C.HPN_TYP_CD = G.CD_VAL --发生类型 码值
AND     G.TBL_NM = 'DIM_BUS_LOAN_CTR_INF_DD'     -- DWD_BUS_LOAN_APL_INF_DD 该表码值表错误
AND     G.FLD_NM = 'HPN_TYP_CD'
AND     G.DT = '@@{yyyyMMdd}'
LEFT JOIN app_awp.OICS_FCT_GNRL_LOAN_AR_DTL_SMY_DD       I --普通贷款借据明细表(部分逻辑) 46273 仅有字段 BUS_CTR_ID
ON      b.BUSI_CTR_ID = I.BUS_CTR_ID --信贷合同编号
where   NVL(B.CST_ID,'') <> '' --剔除空值和空
AND     B.CRC_IND <> '1'       --剔除循环贷款
AND     SUBSTR(B.PD_CD, 1, 9) IN ( '201050101' , '201050102' , '201040101' , '201040102' , '201040106' ) --产品代码
--普通贷款:-20105010100 个人消费性贷款 20105010200 个人经营性贷款 20104010100 流动资金贷款 20104010200 固定资产贷款 20104010600 法人购房贷款
AND     B.DT = '@@{yyyyMMdd}'
;

--贷款合同信息_历史存续状态
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_02;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_02 AS
SELECT  A.BUSI_CTR_ID
       ,A.CST_ID                   --客户号
       ,(CASE SUBSTR(A.PD_CD, 1, 9)
         WHEN '201050101' THEN '1' --20105010100 个人消费性贷款
         WHEN '201050102' THEN '2' --20105010200 个人经营性贷款
         WHEN '201040101' THEN '3' --20104010100 流动资金贷款
         WHEN '201040102' THEN '4' --20104010200 固定资产贷款
         ELSE '5'                  --20104010600 法人购房贷款
       END)              AS PD_CD  --产品代码转换
       ,A.CTR_AMT                  --金额
       ,A.INTR_RAT                 --利率
       ,A.TRM_MON                  --期限月
       ,A.HDL_DT                   --经办日期
       ,A.DT             AS ACG_DT --日期
FROM    edw.DIM_BUS_LOAN_CTR_INF_DD A --信贷合同信息
INNER join(select distinct cst_id from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01)b on a.cst_ID=b.cst_ID
WHERE   A.CRC_IND <> '1'    --剔除循环贷款
AND     SUBSTR(A.PD_CD, 1, 9) IN ('201050101', '201050102', '201040101', '201040102', '201040106') --产品代码 --普通贷款
AND     A.DT <= '@@{yyyyMMdd}' and a.dt>='20220701'
AND     A.CTR_BAL > 0           --余额不为0，存续
;

--前一笔贷款
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_03;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_03 AS
SELECT   T.BUSI_CTR_ID                   --贵金属流水号
        ,T.LAST_CTR_ID                   --前一笔贷款合同
        ,T.CTR_AMT      AS LAST_CTR_AMT  --前一笔贷款合同金额
        ,T.INTR_RAT     AS LAST_INTR_RAT --前一笔贷款合同执行月利率
        ,T.TRM_MON      LAST_TRM_MON     --期限月
FROM    (
         SELECT   A.BUSI_CTR_ID --贵金属流水号
                 ,B.BUSI_CTR_ID LAST_CTR_ID--前一笔贷款合同
                 ,B.CTR_AMT     --前一笔贷款合同金额
                 ,B.INTR_RAT    --前一笔贷款合同执行月利率
                 ,B.TRM_MON     --期限月
                 ,ROW_NUMBER() OVER ( PARTITION BY A.BUSI_CTR_ID ORDER BY B.HDL_DT DESC ) AS RN --贵金属流水号 分组 -- 经办日期 倒序
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01     A     --当前合同
         INNER JOIN  TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_02 B     --历史
         ON      A.CST_ID      = B.CST_ID      --客户号
         AND     A.PD_CD       = B.PD_CD       --产品代码
         AND     B.ACG_DT >= TO_CHAR(DATEADD(TO_DATE(A.REG_DT, 'yyyyMMdd'), 0-90, 'dd'), 'yyyyMMdd') --贷款申请日期 --当前笔往前推3个月，有存续的
         AND     B.ACG_DT <  A.REG_DT
        ) T
WHERE   T.RN = 1
;

--贵金属购买信息汇总
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_04;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_04 AS
SElECT ord_id               --订单号
    ,ord_tm TRX_DT                --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc TRX_AMT      --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'dtl' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di --贵金属交易明细表
where dt between '20221101' and '20231211'
and ord_tm between '2022-11-01' and '2023-12-11'
union all
SElECT ord_id               --订单号
    ,ord_tm                 --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc       --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'hand' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_hand_di	--贵金属柜面或退款交易手工表
where dt between '20221101' and '20231211'
and ord_tm between '2022-11-01' and '2023-12-11'
;

--贵金属购买信息汇总
--同一风险控制号关联的贵金属交易记录
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_06;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_06 AS
SElECT T1.BUSI_CTR_ID,T1.REG_DT,T1.SAM_RSK_CTRL_ID
    ,CONCAT_WS('|', COLLECT_SET(t1.cst_id))  aS SAM_RSK_EFE_trx_CST
    ,CONCAT_WS('|', COLLECT_SET(t2.ord_id))                 ord_id
    ,CONCAT_WS('|', COLLECT_SET(t2.TRX_DT))                 trx_dt
    ,CONCAT_WS('|', COLLECT_SET(t2.cst_id))             cst_ID
    ,CONCAT_WS('|', COLLECT_SET(t2.cst_nm))             cst_nm
    ,CONCAT_WS('|', COLLECT_SET(t2.usr_nm))             usr_nm
    ,CONCAT_WS('|', COLLECT_SET(t2.pvd_nm))                pvd_nm
    ,CONCAT_WS('|', COLLECT_SET(t2.pst_mth))               pst_mth
    ,CONCAT_WS('|', COLLECT_SET(t2.substr(pmt_tm,1,10)))   pmt_tm
    ,CONCAT_WS('|', COLLECT_SET(t2.pmt_mth))               pmt_mth
    ,CONCAT_WS('|', COLLECT_SET(t2.chnl_nm))               chnl_nm
    ,CONCAT_WS('|', COLLECT_SET(t2.ord_sts))               ord_sts
    ,CONCAT_WS('|', COLLECT_SET(t2.cmdt_nm))               cmdt_nm
    ,CONCAT_WS('|', COLLECT_SET(t2.cmdt_spec))             cmdt_spec
    ,sum(t2.qty)                                           qty
    ,CONCAT_WS('|', COLLECT_SET(t2.goods_typ))             goods_typ
    ,CONCAT_WS('|', COLLECT_SET(t2.goods_return_status))   goods_return_status
    ,CONCAT_WS('|', COLLECT_SET(cast(t2.cmdt_unt_prc as string))) cmdt_unt_prc
    ,sum(TRX_AMT)                                       TRX_AMT
    ,CONCAT_WS('|', COLLECT_SET(t2.cmsn_typ))              cmsn_typ
    ,CONCAT_WS('|', COLLECT_SET(t2.mid_inc_rto))           mid_inc_rto
    ,sum(mid_inc_tot_amt)                               mid_inc_tot_amt
    ,CONCAT_WS('|', COLLECT_SET(t2.rcm_psn_id))            rcm_psn_id
    ,CONCAT_WS('|', COLLECT_SET(t2.rcm_psn_nm))            rcm_psn_nm
    ,CONCAT_WS('|', COLLECT_SET(t2.rcm_psn_afl_dept_id))   rcm_psn_afl_dept_id
    ,CONCAT_WS('|', COLLECT_SET(t2.rcm_psn_afl_dept))      rcm_psn_afl_dept
    ,CONCAT_WS('|', COLLECT_SET(t2.rcm_psn_afl_sub_brn))   rcm_psn_afl_sub_brn
    ,CONCAT_WS('|', COLLECT_SET(t2.rcm_psn_afl_brn))       rcm_psn_afl_brn
    ,CONCAT_WS('|', COLLECT_SET(t2.data_src))              data_src
    ,CONCAT_WS('|', COLLECT_SET(t2.rcm_psn_pos))           rcm_psn_pos
    ,MIN(ABS(DATEDIFF(TO_DATE(T2.TRX_DT, 'yyyy-MM-dd'), TO_DATE(T1.REG_DT,'yyyyMMdd'), 'dd'))) DIFF_TM
from(
    SElECT distinct T1.BUSI_CTR_ID,T1.REG_DT,T1.SAM_RSK_CTRL_ID,COALESCE(T2.CST_ID, T1.CST_ID) CST_ID
    from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01           t1
    INNER join TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01     t2
    on t1.sam_rsk_ctrl_id=t2.sam_rsk_ctrl_id
    and NVL(t2.SAM_RSK_CTRL_ID,'') <> '' --剔除空值和空
)t1 INNER join TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_04  t2  --贵金属购买日汇总明细表
on  T1.CST_ID = T2.CST_ID
and T2.cst_ID<>'无'
and ABS(DATEDIFF(TO_DATE(T2.TRX_DT, 'yyyy-MM-dd'), TO_DATE(T1.REG_DT,'yyyyMMdd'), 'dd'))<=15
GROUP by t1.BUSI_CTR_ID,T1.REG_DT,T1.SAM_RSK_CTRL_ID
;

--汇总
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_07;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_07 AS
SElECT T1.BUSI_CTR_ID
    ,T1.CST_ID
    ,T1.CST_NM
    ,T1.SAM_RSK_CTRL_ID
    ,t1.cst_rsk_grd
    ,t1.five_ctg_nm
    ,t1.zq_ind
    ,t1.zxt_ind
    ,t1.ctr_amt
    ,t1.ref_mon_intr_rat
    ,t1.intr_rat
    ,t1.dep_ln_acm_rto
    ,t1.trm_mon
    ,t2.LAST_CTR_ID
    ,t2.LAST_CTR_AMT
    ,ROUND(case when coalesce(T2.LAST_CTR_AMT,0)=0 then 0
        else coalesce(T1.ctr_amt,0)/T2.LAST_CTR_AMT end, 2) AS CRD_LAST_CTR_AMT --当前笔合同金额/前一笔
    ,t2.LAST_INTR_RAT
    ,t2.LAST_TRM_MON
    ,CASE WHEN T2.LAST_INTR_RAT > 0 THEN T2.LAST_INTR_RAT - T1.INTR_RAT
        ELSE NULL END INTR_RAT_SPRD        --前一笔执行月利率-当前执行月利率
    ,t1.dtrb_dt
    ,t1.mng_mgr_id_1
    ,E.EMPE_NM
    ,t1.mng_org_id_1
    ,t1.reg_dt
    ,t1.crd_typ
    ,t1.crd_mod_mark
    ,t1.crd_usg_mark
    ,t1.crd_mark
    ,(CASE WHEN t2.LAST_INTR_RAT > 0 THEN (t2.LAST_INTR_RAT - t1.INTR_RAT ) * t1.ctr_amt * t1.TRM_MON * 0.001
        ELSE NULL END ) AS LOAN_RAT_SPRD    --贷款利息差
    --贵金属交易信息
    ,T3.SAM_RSK_EFE_trx_CST
    ,T3.data_src
    ,T3.pvd_nm                 --商铺名称
    ,T3.ORD_ID
    ,T3.pst_mth                --邮寄方式
    ,T3.trx_dt                 --下单时间
    ,T3.pmt_tm                 --付款时间
    ,T3.pmt_mth                --支付方式
    ,T3.chnl_nm                --渠道
    ,T3.ord_sts                --订单状态
    ,T3.cmdt_nm                --商品名称
    ,T3.cmdt_spec              --商品规格
    ,T3.qty                    --数量
    ,T3.goods_typ              --商品分类
    ,T3.goods_return_status    --商品退款状态
    ,T3.cmdt_unt_prc           --商品现金单价
    ,T3.TRX_AMT                --商品应付现金总额
    ,T3.cmsn_typ               --佣金类型
    ,T3.mid_inc_rto            --佣金比例/金额
    ,T3.mid_inc_tot_amt        --佣金总额
    ,T3.rcm_psn_id             --推荐人工号
    ,T3.rcm_psn_nm             --推荐人姓名
    ,T3.rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,T3.rcm_psn_afl_dept       --推荐人所属部门/团队
    ,T3.rcm_psn_afl_sub_brn    --推荐人所属支行
    ,T3.rcm_psn_afl_brn        --推荐人所属分行
    ,(CASE WHEN t2.LAST_INTR_RAT > 0 THEN (t2.LAST_INTR_RAT - t1.INTR_RAT ) * t1.ctr_amt * t1.TRM_MON * 0.001 - T3.TRX_AMT
    ELSE NULL END)                                                 AS RAT_SPRD_AMT_INC     --利息差-贵金属购买金额
    ,(CASE WHEN t2.LAST_INTR_RAT > 0 THEN (t2.LAST_INTR_RAT - t1.INTR_RAT ) * t1.ctr_amt * t1.TRM_MON * 0.001 - T3.MID_INC_TOT_AMT
    ELSE NULL END)                                                 AS RAT_SPRD_MID_INC     --利息差-中收
    ,COALESCE(t1.ctr_amt,0)-COALESCE(t2.LAST_CTR_AMT,0)-COALESCE(t3.TRX_AMT,0) loan_diff_gold_amt
    ,t1.DX_IND
    ,(CASE WHEN t3.DIFF_TM >= 0 AND t3.DIFF_TM <= 3 THEN '是'
    WHEN t3.DIFF_TM > 3 AND t3.DIFF_TM <= 15 AND(t1.CRD_MOD_MARK LIKE '%贵金属%' OR t1.CRD_USG_MARK LIKE '%贵金属%' OR t1.CRD_MARK LIKE '%贵金属%' ) THEN '是'
    WHEN t3.DIFF_TM > 3 AND t3.DIFF_TM <= 15 AND t2.LAST_INTR_RAT > 0
        AND t1.ctr_amt * t1.TRM_MON *(t2.LAST_INTR_RAT - t1.INTR_RAT ) * 0.001 - t3.TRX_AMT >= 0 THEN '是'
    WHEN t3.DIFF_TM > 3 AND t3.DIFF_TM <= 15 AND t2.LAST_CTR_AMT > 0 AND t1.ctr_amt / t2.LAST_CTR_AMT > 1 AND t1.ctr_amt / t2.LAST_CTR_AMT <= 1.2 THEN '是'
    WHEN(t1.CST_RSK_GRD IN('高风险' , '黑名单' ) OR t1.FIVE_CTG_NM IN('关注一级' , '关注二级' , '次级一级' , '次级二级' , '可疑' , '损失' ) ) THEN '是'
    WHEN t3.DIFF_TM > 3 AND t3.DIFF_TM <= 15 AND t1.HPN_TYP_CD = '015' THEN '是'
    WHEN t3.DIFF_TM > 3 AND t3.DIFF_TM <= 15 AND t1.BUS_ID = 'J' THEN '是'
    ELSE '否' END ) AS IS_BIND --是否疑似捆绑
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01       t1
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_03  T2
ON T1.BUSI_CTR_ID=T2.BUSI_CTR_ID
INNER JOIN TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_06  T3
ON T1.BUSI_CTR_ID=T3.BUSI_CTR_ID
LEFT JOIN edw.DWS_HR_EMPE_INF_DD             E --员工汇总信息
ON      T1.mng_mgr_id_1 = E.EMPE_ID --管护客户经理工号
AND     E.DT = '@@{yyyyMMdd}'
;


--输出
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_08;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_08 AS
SElECT busi_ctr_id 				当前笔贷款合同流水号
    ,cst_id                     客户号
    ,cst_nm                     贷款客户名称
    ,sam_rsk_ctrl_id            贷款人同一风险控制号
    ,cst_rsk_grd                申请贷款时客户的信用风险等级
    ,five_ctg_nm                当前笔的当前五级分类
    ,zq_ind                     当前笔是否展期贷款
    ,zxt_ind                    当前笔是否助兴通
    ,ctr_amt                    当前笔合同金额
    ,ref_mon_intr_rat           当前笔参考月利率
    ,intr_rat                   当前笔执行月利率
    ,dep_ln_acm_rto             当前笔合同存贷积数比
    ,trm_mon                    当前笔合同期限月
    ,last_ctr_id                前一笔贷款合同流水号
    ,last_ctr_amt               前一笔贷款合同金额
    ,crd_last_ctr_amt           当前笔合同金额比前一笔
    ,last_intr_rat              前一笔贷款合同执行月利率
    ,last_trm_mon               前一笔合同期限月
    ,intr_rat_sprd              前一笔执行月利率_当前执行月利率
    ,dtrb_dt                    贷款发放日期
    ,mng_mgr_id_1               贷款管护人工号
    ,empe_nm                    贷款管护人姓名
    ,mng_org_id_1               贷款管护人机构号
    ,reg_dt                     贷款申请日期
    ,crd_typ                    贷款类型
    ,crd_mod_mark               贷款利率优惠备注
    ,crd_usg_mark               贷款用途备注
    ,crd_mark                   贷款备注
    ,loan_rat_sprd              贷款利息差
    ,sam_rsk_efe_trx_cst        贷款人同一风险控制号的客户号
    ,data_src                   数据来源
    ,pvd_nm                     商铺名称
    ,ord_id                     订单号
    ,pst_mth                    邮寄方式
    ,trx_dt                     下单时间
    ,pmt_tm                     付款时间
    ,pmt_mth                    支付方式
    ,chnl_nm                    渠道
    ,ord_sts					订单状态
    ,cmdt_nm                    商品名称
    ,cmdt_spec                  商品规格
    ,qty                        购买数量
    ,goods_typ                  商品分类
    ,goods_return_status        商品退款状态
    ,cmdt_unt_prc               商品现金单价
    ,trx_amt                    商品应付现金总额
    ,cmsn_typ                   佣金类型
    ,mid_inc_rto                佣金比例_金额
    ,mid_inc_tot_amt            佣金总额
    ,rcm_psn_id                 推荐人工号
    ,rcm_psn_nm                 推荐人姓名
    ,rcm_psn_afl_dept_id        推荐人所属部门_团队id
    ,rcm_psn_afl_dept           推荐人所属部门_团队
    ,rcm_psn_afl_sub_brn        支行名称
    ,rcm_psn_afl_brn            分行名称
    ,rat_sprd_amt_inc           利息差_贵金属购买金额
    ,rat_sprd_mid_inc           利息差_中收
    ,loan_diff_gold_amt         贷款额度差_贵金属购买金额
    ,dx_ind                     当前笔是否低息贷款
    ,is_bind                    是否疑似捆绑
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_07
;


/*
SELECT '1' seq,count(1) cnt,count(DISTINCT busi_ctr_id)
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_01
union all
SELECT '2' seq,count(1) cnt,count(DISTINCT busi_ctr_id)
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_02
union all
SELECT '3' seq,count(1) cnt,count(DISTINCT busi_ctr_id)
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_03
union all
SELECT '4' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_04
union all
SELECT '6' seq,count(1) cnt,count(DISTINCT BUSI_CTR_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_06
union all
SELECT '7' seq,count(1) cnt,count(DISTINCT BUSI_CTR_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_07
union all
SELECT '8' seq,count(1) cnt,count(DISTINCT 当前笔贷款合同流水号)
from TLDATA_DEV.SJXQ_SJ2023120591_LOAN_CST_08
;
1	204507	204507
2	78357428	367479
3	138199	138199
4	24200	16047
6	2254	2254
7	2254	2254
8	2254	2254
*/







**SJ2023120591_code.sql
-- ODPS SQL
-- **********************************************************************
-- 任务描述: 贵金属捆绑销售清单
-- 创建日期: 2023-12-08
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- 任务输出
-- TLDATA_DEV.SJXQ_SJ2023120591_CST      --贵金属捆绑销售清单
--
-- ----------------------------------------------------------------------
-- 其他信息:
--
-- **********************************************************************
-- ===========================================================================================================
-- Step.1  2023年贵金属购买明细表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_01;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_01 AS
select cast(col_1 as int)	SYS_SRL_NBR	--系统流水号
    ,col_2      DATA_SRC        		--数据来源
    ,col_3      PVD_NM                  --商铺名称
    ,col_4      ORD_ID                  --订单号
    ,col_5      USR_NM                  --买家名称
    ,col_6      CST_ID                  --客户号
    ,col_7      CST_NM                  --真实姓名
    ,col_8      PST_MTH                 --邮寄方式
    ,col_9      TRX_DT                  --下单日期
    ,col_10     PMT_TM                  --付款时间
    ,col_11     PMT_MTH                 --支付方式
    ,col_12     CHNL_NM                 --渠道
    ,col_13     ORD_STS                 --订单状态
    ,col_14     PROD_NM                 --商品名称
    ,col_15     CMDT_SPEC               --商品规格
    ,col_16     QTY                     --购买数量
    ,col_17     GOODS_TYP               --商品分类
    ,col_18     GOODS_RETURN_STATUS     --商品退款状态
    ,col_19     CMDT_UNT_PRC            --商品现金单价
    ,col_20     TRX_AMT                 --商品应付现金总额
    ,col_21     CMSN_TYP                --佣金类型
    ,col_22     MID_INC_RTO             --佣金比例_金额
    ,col_23     MID_INC_TOT_AMT         --佣金总额
    ,col_24     RCM_PSN_ID              --推荐人工号
    ,col_25     RCM_PSN_NM              --推荐人姓名
    ,col_26     RCM_PSN_AFL_DEPT_ID     --推荐人所属部门_团队id
    ,col_27     RCM_PSN_AFL_DEPT        --推荐人所属部门_团队
    ,col_28     RCM_PSN_AFL_SUB_BRN     --支行名称
    ,col_29     RCM_PSN_AFL_BRN         --分行名称
    ,COALESCE(F.SAM_RSK_CTRL_ID, '')                                      AS SAM_RSK_CTRL_ID       --同一风险控制号
    ,(CASE WHEN COALESCE(F.OWN_EMP_ID, '') <> '' THEN '是' ELSE '否' END) AS WTHR_INT_EMPE         --是否行内员工
    ,(CASE WHEN G.EFE_LOAN_CST_IND = '1' THEN '是' ELSE '否' END)         AS EFE_LOAN_CST_IND      --是否信贷有效户
    ,(CASE WHEN G.EFE_DEP_CST_IND  = '1' THEN '是' ELSE '否' END)         AS EFE_DEP_CST_IND       --是否存款有效户
    ,(CASE WHEN G.EFE_CHM_CST_IND  = '1' THEN '是' ELSE '否' END)         AS EFE_CHM_CST_IND       --是否理财有效户
    ,B.prm_mgr_id MNG_MGR_ID            --管护客户经理工号
    ,b.prm_org_id MNG_ORG_ID
from qbi_file_20231208_14_33_42       a          --19152
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD B --客户主管户信息
ON      a.col_6 = B.CST_ID
AND     B.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWS_CST_IDV_BAS_INF_DD           F --个人客户基本信息汇总表
ON      a.col_6 = F.CST_ID --客户号
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN    adm_pub.ADM_CSM_CBAS_IND_INF_DD      G --客户集市-基础信息-有效户基本信息
ON      a.col_6 = G.CST_ID --客户号
AND     G.DT = '@@{yyyyMMdd}'
where a.pt=max_pt('qbi_file_20231208_14_33_42')
and a.col_6 <> '无'      -- 133个无客户号
;

-- ===========================================================================================================
-- 建表语句
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_02
(
     SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
    ,SAM_RSK_EFE_LOAN_CST STRING  COMMENT '同一风险控制号下是信贷有效户的客户号'
)
COMMENT '同一风险控制号_信贷有效户_临时表_02'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_03
(
     SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
)
COMMENT '同一风险控制号_临时表_03'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_04
(
     CST_ID               STRING  COMMENT '客户号'
    ,CST_NM               STRING  COMMENT '客户名'
    ,SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
)
COMMENT '同一风险控制号_带客户信息_临时表_04'
LIFECYCLE 31;


-- ===========================================================================================================
-- Step.2 同一风险控制号数据
-- 同一风险控制号_信贷有效户_临时表_02
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_02
SELECT  A.SAM_RSK_CTRL_ID                      AS SAM_RSK_CTRL_ID      --有效信贷户 同一风险控制号
       ,CONCAT_WS('|', COLLECT_SET(A.CST_ID))  AS SAM_RSK_EFE_LOAN_CST --同一风险控制号下是信贷有效户的客户号
FROM    edw.DWS_CST_BAS_INF_DD                A --客户基础信息汇总表
INNER JOIN    adm_pub.ADM_CSM_CBAS_IND_INF_DD B --客户集市-基础信息-有效户基本信息
ON      B.CST_ID = A.CST_ID --客户号
AND     B.EFE_LOAN_CST_IND = '1' --有效信贷户
AND     B.DT = '@@{yyyyMMdd}'
WHERE   A.SAM_RSK_CTRL_ID <> ''  --同一风险控制号 --剔除空值和空
AND     A.DT = '@@{yyyyMMdd}'
GROUP BY A.SAM_RSK_CTRL_ID;

-- -------------------------------------------------------------------------------------
-- 同一风险控制号_临时表_03
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_03
SELECT  T.SAM_RSK_CTRL_ID --同一风险控制号
FROM    (
         SELECT  DISTINCT B.SAM_RSK_CTRL_ID --贵金属客户 同一风险控制号
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01    A --贵金属相关信息
         INNER JOIN    edw.DWS_CST_BAS_INF_DD           B --客户集市-基础信息-有效户基本信息
         ON      A.CST_ID = B.CST_ID
         AND     B.DT = '@@{yyyyMMdd}'
        ) T;

-- -------------------------------------------------------------------------------------
-- 同一风险控制号_临时表_04
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_04
SELECT  A.CST_ID           --客户号
       ,A.CST_CHN_NM       --客户名称
       ,A.SAM_RSK_CTRL_ID  --贵金属客户 同一风险控制号
FROM    edw.DWS_CST_BAS_INF_DD                        A --客户集市-基础信息-有效户基本信息
INNER JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_03 B --同一风险控制号_临时表_03
ON      A.SAM_RSK_CTRL_ID = B.SAM_RSK_CTRL_ID --同一风险控制号
AND     COALESCE(B.SAM_RSK_CTRL_ID, '') <> '' --剔除空值和空
WHERE   A.DT = '@@{yyyyMMdd}';

-- ===========================================================================================================
-- 建表语句
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_05
(
     SYS_SRL_NBR          STRING  COMMENT '系统流水号'
    ,CST_ID               STRING  COMMENT '客户号'
    ,CST_NM               STRING  COMMENT '客户名'
    ,SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
    ,CST_OWN_IND          STRING  COMMENT '是否客户本人'
    ,PD_CD                STRING  COMMENT '产品代码'
    ,BUSI_CTR_ID          STRING  COMMENT '合同流水号'
    ,CTR_AMT              DECIMAL COMMENT '合同金额'
    ,CTR_BAL              DECIMAL COMMENT '合同余额'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,INTR_RAT             DECIMAL COMMENT '执行利率'
    ,REF_MON_INTR_RAT     DECIMAL COMMENT '参考月利率'
    ,REG_DT               STRING  COMMENT '申请日期'
    ,APNT_START_DT        STRING  COMMENT '发放日期'
    ,LOAN_USG_CD          STRING  COMMENT '贷款用途代码'
    ,INTR_RAT_ADJ_CMT     STRING  COMMENT '利率调整备注'
    ,USG_CMT              STRING  COMMENT '用途备注'
    ,CMT                  STRING  COMMENT '备注'
    ,BUSI_APL_ID          STRING  COMMENT '业务申请编号'
    ,DT                   STRING  COMMENT '合同日期'
    ,DIFF_TM              BIGINT  COMMENT '贷款申请与贵金属购买间隔日期'
)
COMMENT '业务合同表相关信息_临时表_05'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_06
(
     CST_ID               STRING  COMMENT '客户号'
    ,TRX_DT               STRING  COMMENT '交易日期'
    ,DEPT_CST_NAME        STRING  COMMENT '贷款客户名称'
    ,BUS_CTR_ID           STRING  COMMENT '合同流水号'
    ,CRD_CTR_AMT          DECIMAL COMMENT '贷款合同金额'
    ,REF_INTR_RAT         DECIMAL COMMENT '参考月利率'
    ,INTR_RAT             DECIMAL COMMENT '执行月利率'
    ,CRD_DTRB_DT          STRING  COMMENT '贷款发放日期'
    ,MNG_MGR_ID_1         STRING  COMMENT '贷款管护人工号'
    ,MNG_MGR_NM_1         STRING  COMMENT '贷款管护人姓名'
    ,MNG_ORG_ID_1         STRING  COMMENT '贷款管护人机构号'
    ,REG_DT               STRING  COMMENT '贷款申请日期'
    ,DIFF_TM              BIGINT  COMMENT '贷款申请与贵金属购买间隔日期'
    ,DBIL_USG             STRING  COMMENT '借据用途'
    ,CRD_TYP              STRING  COMMENT '贷款类型'
    ,CRD_MOD_MARK         STRING  COMMENT '贷款利率优惠备注'
    ,CRD_USG_MARK         STRING  COMMENT '贷款用途备注'
    ,CRD_MARK             STRING  COMMENT '贷款备注'
    ,BUSI_APL_ID          STRING  COMMENT '业务申请编号'
    ,PD_CD                STRING  COMMENT '产品代码'
    ,SYS_SRL_NBR          STRING  COMMENT '系统流水号'
    ,TRM_MON              BIGINT  COMMENT '期限月'
)
COMMENT '当前笔贷款合同相关信息_临时表_06'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_07
(
     SYS_SRL_NBR          STRING  COMMENT '贵金属流水号'
    ,BUSI_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,CST_ID               STRING  COMMENT '客户号'
    ,PD_CD                STRING  COMMENT '产品代码转换'
    ,CTR_AMT              DECIMAL COMMENT '金额'
    ,INTR_RAT             DECIMAL COMMENT '利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,HDL_DT               STRING  COMMENT '经办日期'
    ,ACG_DT               STRING  COMMENT '日期'
)
COMMENT '当前笔贷款合同相关信息_临时表_07'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_08
(
     SYS_SRL_NBR          STRING  COMMENT '贵金属流水号'
    ,LAST_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,LAST_CTR_AMT         DECIMAL COMMENT '前一笔贷款合同金额'
    ,LAST_INTR_RAT        DECIMAL COMMENT '前一笔贷款合同执行月利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
)
COMMENT '前一笔贷款信息_临时表_08'
LIFECYCLE 31;

-- ===========================================================================================================
-- Step.3  信贷合同信息数据
--贵金属客户的信贷合同相关信息_临时表_05
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_05
SELECT  A.SYS_SRL_NBR                         --系统流水号
       ,A.CST_ID           AS CST_ID          --客户号
       ,A.CST_NM           AS SAM_RSK_CST_NM  --客户名
       ,A.SAM_RSK_CTRL_ID  AS SAM_RSK_CTRL_ID --同一风险控制号
       ,A.CST_OWN_IND      AS CST_OWN_IND     --是否客户本人
       ,(CASE SUBSTR(B.PD_CD, 1, 9)
          WHEN '201050101' THEN '1'           --20105010100 个人消费性贷款
          WHEN '201050102' THEN '2'           --20105010200 个人经营性贷款
          WHEN '201040101' THEN '3'           --20104010100 流动资金贷款
          WHEN '201040102' THEN '4'           --20104010200 固定资产贷款
          ELSE '5'                            --20104010600 法人购房贷款
        END)               AS PD_CD           --产品代码    --普通贷款产品代码二次转码
       ,B.BUSI_CTR_ID                         --合同流水号
       ,B.CTR_AMT                             --合同金额
       ,B.CTR_BAL                             --合同余额
       ,B.TRM_MON                             --期限月
       ,B.INTR_RAT                            --执行利率
       ,B.REF_MON_INTR_RAT                    --参考月利率
       ,C.REG_DT                              --申请日期
       ,D.DTRB_DT                             --最早发放日期
       ,B.LOAN_USG_CD                         --贷款用途代码
       ,B.INTR_RAT_ADJ_CMT                    --利率调整备注
       ,B.USG_CMT                             --用途备注
       ,B.CMT                                 --备注
       ,B.BUSI_APL_ID                         --业务申请编号
       ,B.DT                                  --合同日期
       ,ABS(DATEDIFF(TO_DATE(C.REG_DT, 'yyyyMMdd'), TO_DATE(SUBSTR(A.TRX_DT,1,10),'yyyy-MM-dd'), 'dd')) AS DIFF_TM --贷款申请与贵金属购买间隔日期   --信贷业务登记申请日期 -贵金属交易日期
FROM    (
         SELECT   A1.SYS_SRL_NBR                                --系统流水号
                 ,A1.TRX_DT                                     --交易日期
                 ,A1.SAM_RSK_CTRL_ID                            --同一风险控制号
                 ,COALESCE(A3.CST_ID, A1.CST_ID) AS CST_ID      --客户号
                 ,COALESCE(A3.CST_NM, A2.CST_NM) AS CST_NM      --客户名
                 ,CASE
                    WHEN A3.CST_ID IS NULL     THEN '1'
                    WHEN A3.CST_ID = A1.CST_ID THEN '1'
                    ELSE '0'
                  END                            AS CST_OWN_IND --是否客户本人
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01      A1 --贵金属相关信息_临时表01
         LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_04 A2 --同一风险控制号_临时表_04
         ON      A1.CST_ID = A2.CST_ID --客户号
         AND     NVL(A2.CST_ID,'') <> '' --剔除空值和空
         LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_04 A3 --同一风险控制号_临时表_04
         ON      A2.SAM_RSK_CTRL_ID = A3.SAM_RSK_CTRL_ID --同一风险控制号
         AND     NVL(A3.SAM_RSK_CTRL_ID,'') <> '' --剔除空值和空
        )                                        A
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD B --信贷合同信息
ON      A.CST_ID = B.CST_ID --客户号
AND     NVL(B.CST_ID,'') <> '' --剔除空值和空
AND     B.CRC_IND <> '1'       --剔除循环贷款
AND     SUBSTR(B.PD_CD, 1, 9) IN ( '201050101' , '201050102' , '201040101' , '201040102' , '201040106' ) --产品代码
--普通贷款:-20105010100 个人消费性贷款 20105010200 个人经营性贷款 20104010100 流动资金贷款 20104010200 固定资产贷款 20104010600 法人购房贷款
AND     B.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD C --信贷业务申请信息
ON      B.BUSI_APL_ID = C.APL_ID --业务申请编号
AND     NVL(C.APL_ID,'') <> ''   --剔除空值和空
AND     C.DT = '@@{yyyyMMdd}'
LEFT JOIN (
            SELECT  BUS_CTR_ID               --信贷合同编号
                   ,MIN(DTRB_DT) AS DTRB_DT  --最早发放日期
              FROM edw.DWS_BUS_LOAN_DBIL_INF_DD --贷款借据信息汇总
             WHERE DT = '@@{yyyyMMdd}'
          GROUP BY BUS_CTR_ID --信贷合同编号
          )                                      D
ON      B.BUSI_CTR_ID = D.BUS_CTR_ID; --信贷合同编号

-- ------------------------------------------------------------------------------------------------------------
-- 当前笔贷款合同相关信息_临时表_06
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_06
SELECT  A.CST_ID                                         AS CST_ID       --客户号
       ,A.TRX_DT                                         AS TRX_DT       --交易日期
       ,COALESCE(B.CST_NM, C.CST_NM)                     AS DEPT_CST_NM  --贷款客户名称
       ,COALESCE(B.BUSI_CTR_ID, C.BUSI_CTR_ID)           AS BUS_CTR_ID   --合同流水号
       ,COALESCE(B.CTR_AMT, C.CTR_AMT)                   AS CRD_CTR_AMT  --贷款合同金额
       ,COALESCE(B.REF_MON_INTR_RAT, C.REF_MON_INTR_RAT) AS REF_INTR_RAT --参考月利率
       ,COALESCE(B.INTR_RAT, C.INTR_RAT)                 AS INTR_RAT     --执行月利率
       ,COALESCE(B.APNT_START_DT, C.APNT_START_DT)       AS CRD_DTRB_DT  --贷款发放日期
       ,D.ACS_MNGR_ID                                    AS MNG_MGR_ID_1 --管护客户经理工号
       ,E.EMPE_NM                                        AS MNG_MGR_NM_1 --管护客户经理姓名
       ,D.ACS_ORG_ID                                     AS MNG_ORG_ID_1 --管护机构号
       ,COALESCE(B.REG_DT, C.REG_DT)                     AS REG_DT       --贷款申请日期
       ,COALESCE(B.DIFF_TM, C.DIFF_TM)                   AS DIFF_TM      --贷款申请与贵金属购买间隔日期
       ,''                                               AS DBIL_USG     --借据用途
       ,COALESCE(G.CD_VAL_DSCR, '')                      AS CRD_TYP      --贷款类型(码值含义)
       ,COALESCE(B.INTR_RAT_ADJ_CMT, C.INTR_RAT_ADJ_CMT) AS CRD_MOD_MARK --贷款利率优惠备注
       ,COALESCE(B.USG_CMT, C.USG_CMT)                   AS CRD_USG_MARK --贷款用途备注
       ,COALESCE(B.CMT, C.CMT)                           AS CRD_MARK     --贷款备注
       ,COALESCE(B.BUSI_APL_ID, C.BUSI_APL_ID)           AS BUSI_APL_ID  --业务申请编号
       ,COALESCE(B.PD_CD, C.PD_CD)                       AS PD_CD        --产品代码
       ,A.SYS_SRL_NBR                                    AS SYS_SRL_NBR  --系统流水号
       ,COALESCE(B.TRM_MON,C.TRM_MON)                    AS TRM_MON      --期限月
FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01 A --贵金属相关信息_临时表01
LEFT JOIN    (
              SELECT   T.*
                      ,ROW_NUMBER() OVER (PARTITION BY SYS_SRL_NBR ORDER BY DIFF_TM ASC) AS RN
              FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_05 T --业务合同相关信息_临时表_05
              WHERE   T.CST_OWN_IND = '1' --客户本人
              AND     T.DIFF_TM <= 15     --贷款申请与贵金属购买间隔日期
             )                                          B
ON      A.SYS_SRL_NBR = B.SYS_SRL_NBR --系统流水号
AND     B.RN = 1
LEFT JOIN    (
              SELECT   T.*
                      ,ROW_NUMBER() OVER (PARTITION BY SYS_SRL_NBR ORDER BY DIFF_TM ASC) AS RN
              FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_05 T --业务合同相关信息_临时表_05
              WHERE   T.CST_OWN_IND = '0' --非客户本人，同一风险控制号下的其他客户
              AND     T.DIFF_TM <= 15     --贷款申请与贵金属购买间隔日期
             )                                          C
ON      A.SYS_SRL_NBR = C.SYS_SRL_NBR --系统流水号
AND     C.RN = 1
LEFT JOIN    edw.DWD_BUS_LOAN_CTR_MGR_INF_DD    D --信贷合同管护信息
ON      COALESCE(B.BUSI_CTR_ID, C.BUSI_CTR_ID) = D.BUSI_CTR_ID --合同流水号
AND     D.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWS_HR_EMPE_INF_DD             E --员工汇总信息
ON      D.ACS_MNGR_ID = E.EMPE_ID --管护客户经理工号
AND     E.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD        F --信贷业务申请信息
ON      COALESCE(B.BUSI_APL_ID, C.BUSI_APL_ID) = F.APL_ID
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_CODE_LIBRARY_DD            G --码值表(发生类型)
ON      F.HPN_TYP_CD = G.CD_VAL --发生类型 码值
AND     G.TBL_NM = 'DIM_BUS_LOAN_CTR_INF_DD'     -- DWD_BUS_LOAN_APL_INF_DD 该表码值表错误
AND     G.FLD_NM = 'HPN_TYP_CD'
AND     G.DT = '@@{yyyyMMdd}';

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_06_1
(
     BUSI_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,CST_ID               STRING  COMMENT '客户号'
    ,PD_CD                STRING  COMMENT '产品代码转换'
    ,CTR_AMT              DECIMAL COMMENT '金额'
    ,INTR_RAT             DECIMAL COMMENT '利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,HDL_DT               STRING  COMMENT '经办日期'
    ,ACG_DT               STRING  COMMENT '日期'
)
COMMENT '贷款合同信息_历史存续状态_临时表'
LIFECYCLE 31;

INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_06_1
SELECT  A.BUSI_CTR_ID              --前一笔贷款合同
       ,A.CST_ID                   --客户号
       ,(CASE SUBSTR(A.PD_CD, 1, 9)
         WHEN '201050101' THEN '1' --20105010100 个人消费性贷款
         WHEN '201050102' THEN '2' --20105010200 个人经营性贷款
         WHEN '201040101' THEN '3' --20104010100 流动资金贷款
         WHEN '201040102' THEN '4' --20104010200 固定资产贷款
         ELSE '5'                  --20104010600 法人购房贷款
       END)              AS PD_CD  --产品代码转换
       ,A.CTR_AMT                  --金额
       ,A.INTR_RAT                 --利率
       ,A.TRM_MON                  --期限月
       ,A.HDL_DT                   --经办日期
       ,A.DT             AS ACG_DT --日期
FROM    edw.DIM_BUS_LOAN_CTR_INF_DD A --信贷合同信息
WHERE   A.CRC_IND <> '1'    --剔除循环贷款
AND     SUBSTR(A.PD_CD, 1, 9) IN ('201050101', '201050102', '201040101', '201040102', '201040106') --产品代码 --普通贷款
AND     A.DT <= '@@{yyyyMMdd}' and a.dt>='20220701'
AND     A.CTR_BAL > 0;        --余额不为0，存续


-- ------------------------------------------------------------------------------------------------------------
-- 历史贷款合同相关信息_临时表_07
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_07
SELECT  B.SYS_SRL_NBR --贵金属流水号
       ,A.BUSI_CTR_ID --前一笔贷款合同
       ,A.CST_ID      --客户号
       ,A.PD_CD       --产品代码转换
       ,A.CTR_AMT     --金额
       ,A.INTR_RAT    --利率
       ,A.TRM_MON     --期限月
       ,A.HDL_DT      --经办日期
       ,A.ACG_DT      --日期
FROM  TLDATA_DEV.SJXQ_SJ2023120591_CST_06_1 A --贷款合同信息_历史存续状态_临时表
INNER JOIN (
           SELECT  DISTINCT
                   SYS_SRL_NBR  --贵金属流水号
                  ,CST_ID       --客户号
             FROM TLDATA_DEV.SJXQ_SJ2023120591_CST_06
            WHERE COALESCE(BUS_CTR_ID, '') <> '' --合同流水号 --剔除空值和空
            )                               B
ON      A.CST_ID = B.CST_ID
;

-- ------------------------------------------------------------------------------------------------------------
-- 前一笔贷款信息_临时表_08
-- 若在贵金属交易日前后30天内存在贷款申请的，则取其中与贵金属交易日最近的一笔贷款申请（该笔贷款额度为X）
-- 并取该笔贷款申请往前3个月内存续的上一笔贷款申请（该笔贷款额度为Y）
--
-- 前一笔：选择同一业务品种，且与当前笔不是同一天申请的贷款，当前笔贷款申请日往前3个月内有余额的
-- 也要剔除&ldquo;业务品种&rdquo;是&ldquo;随贷通&rdquo;，及&ldquo;是否循环贷款&rdquo;为&ldquo;是&rdquo;的贷款。前一笔考虑同一客户号下的前一笔。

INSERT   OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_08
SELECT   T.SYS_SRL_NBR                   --贵金属流水号
        ,T.BUSI_CTR_ID  AS LAST_CTR_ID   --前一笔贷款合同
        ,T.CTR_AMT      AS LAST_CTR_AMT  --前一笔贷款合同金额
        ,T.INTR_RAT     AS LAST_INTR_RAT --前一笔贷款合同执行月利率
        ,T.TRM_MON                       --期限月
FROM    (
         SELECT   A.SYS_SRL_NBR --贵金属流水号
                 ,B.BUSI_CTR_ID --前一笔贷款合同
                 ,B.CTR_AMT     --前一笔贷款合同金额
                 ,B.INTR_RAT    --前一笔贷款合同执行月利率
                 ,B.TRM_MON     --期限月
                 ,ROW_NUMBER() OVER ( PARTITION BY A.SYS_SRL_NBR ORDER BY B.HDL_DT DESC ) AS RN --贵金属流水号 分组 -- 经办日期 倒序
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_06     A
         INNER JOIN  TLDATA_DEV.SJXQ_SJ2023120591_CST_07 B
         ON      A.SYS_SRL_NBR = B.SYS_SRL_NBR --贵金属流水号
         AND     A.CST_ID      = B.CST_ID      --客户号
         AND     A.PD_CD       = B.PD_CD       --产品代码
         AND     B.ACG_DT >= TO_CHAR(DATEADD(TO_DATE(A.REG_DT, 'yyyyMMdd'), 0-90, 'dd'), 'yyyyMMdd') --贷款申请日期 --当前笔往前推3个月，有存续的
         AND     B.ACG_DT <  A.REG_DT
        ) T
WHERE   T.RN = 1;


-- ===========================================================================================================
-- 建表语句
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_09
(
     EMPE_ID STRING COMMENT '员工号'
    ,EMPE_NM STRING COMMENT '员工姓名'
    ,POS_NM  STRING COMMENT '职位名称'
)
COMMENT '员工信息处理_临时表_09'
LIFECYCLE 31;

-- ===========================================================================================================
-- Step.4  员工信息处理
-- 员工信息处理_临时表_09
INSERT   OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_09
SELECT   A.EMPE_ID AS EMPE_ID --员工号
        ,A.EMPE_NM AS EMPE_NM --员工姓名
        ,B.POS_NM  AS POS_NM  --职位名称
FROM    edw.DWS_HR_EMPE_INF_DD          A -- 员工汇总信息
INNER JOIN    edw.DIM_HR_ORG_JOB_INF_DD B -- 职位信息
ON      B.POS_ID = A.POS_ENC --职位编号
AND     B.DT = '@@{yyyyMMdd}'
WHERE   A.DT = '@@{yyyyMMdd}';


-- ===========================================================================================================
-- Step.5  贵金属捆绑销售清单_最终汇总处理
-- 贵金属捆绑销售清单预处理_临时表_10
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_10;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_10 AS
SELECT  '@@{yyyy-MM-dd}'                                      AS ACG_DT               --数据日期
        ,A.SYS_SRL_NBR
        ,substr(A.TRX_DT,1,10)                                AS TRX_DT               --交易日期
        ,A.PROD_NM                                            AS PROD_NM              --产品名称
        ,A.ORD_ID                                             AS ORD_ID               --订单号
        ,A.ORD_STS                                            AS ORD_STS              --订单状态
        ,COALESCE(E.EMPE_NM, '')                              AS SAL_PPL_NM           --销售人员姓名  --销售客户经理姓名
        ,COALESCE(E.POS_NM, '')                               AS SAL_PPL_POS          --销售人员岗位
        ,A.MNG_MGR_ID                                         AS MNG_MGR_ID           --管户客户经理工号
        ,COALESCE(F.EMPE_NM, '')                              AS MNG_MGR_NM           --管户客户经理姓名
        ,COALESCE(F.POS_NM, '')                               AS MNG_MGR_POS          --管户人岗位
        ,A.MNG_ORG_ID                                         AS MNG_ORG_ID           --管户人机构号
        ,COALESCE(G.ORG_NM, '')                               AS MNG_ORG_NM           --管户人机构名称
        ,A.TRX_AMT                                            AS TRX_AMT              --交易金额
        ,A.SAM_RSK_CTRL_ID                                    AS SAM_RSK_CTRL_ID      --同一风险控制号
        ,A.CST_ID                                             AS CST_ID               --客户号
        ,COALESCE(C.DEPT_CST_NAME, '')                        AS DEPT_CST_NAME        --贷款客户名称
        ,A.EFE_LOAN_CST_IND                                   AS EFE_LOAN_CST_IND     --是否信贷有效户
        ,A.WTHR_INT_EMPE                                      AS WTHR_INT_EMPE        --是否行内员工
        ,COALESCE(B.SAM_RSK_EFE_LOAN_CST, '')                 AS SAM_RSK_EFE_LOAN_CST --同一风险控制号下是信贷有效户的客户号
        ,A.EFE_DEP_CST_IND                                    AS EFE_DEP_CST_IND      --是否存款有效户
        ,A.EFE_CHM_CST_IND                                    AS EFE_CHM_CST_IND      --是否理财有效户
        ,COALESCE(C.BUS_CTR_ID, '')                           AS BUS_CTR_ID           --当前笔贷款合同流水号
        ,(CASE WHEN J.CST_RSK_GRD = '1' THEN '低风险'
               WHEN J.CST_RSK_GRD = '2' THEN '中低风险'
               WHEN J.CST_RSK_GRD = '3' THEN '中风险'
               WHEN J.CST_RSK_GRD = '4' THEN '中高风险'
               WHEN J.CST_RSK_GRD = '5' THEN '高风险'
               WHEN J.CST_RSK_GRD = '6' THEN '黑名单'
               ELSE ''
          END)                                                AS CST_RSK_GRD          --申请贷款时客户的信用风险等级
        ,(CASE WHEN J.FIVE_CTG_CD = '01' THEN '正常一级'
               WHEN J.FIVE_CTG_CD = '02' THEN '正常二级'
               WHEN J.FIVE_CTG_CD = '03' THEN '正常三级'
               WHEN J.FIVE_CTG_CD = '04' THEN '正常四级'
               WHEN J.FIVE_CTG_CD = '05' THEN '正常五级'
               WHEN J.FIVE_CTG_CD = '06' THEN '正常六级'
               WHEN J.FIVE_CTG_CD = '07' THEN '关注一级'
               WHEN J.FIVE_CTG_CD = '08' THEN '关注二级'
               WHEN J.FIVE_CTG_CD = '09' THEN '次级一级'
               WHEN J.FIVE_CTG_CD = '10' THEN '次级二级'
               WHEN J.FIVE_CTG_CD = '11' THEN '可疑'
               WHEN J.FIVE_CTG_CD = '12' THEN '损失'
               ELSE ''
           END)                                               AS FIVE_CTG_NM          --当前笔的当前五级分类
        ,COALESCE(C.CRD_CTR_AMT, 0)                                        AS CRD_CTR_AMT          --当前笔合同金额
        ,C.REF_INTR_RAT                                       AS REF_INTR_RAT         --当前笔参考月利率
        ,C.INTR_RAT                                           AS INTR_RAT             --当前笔执行月利率
        ,COALESCE(H.DEP_LN_ACM_RTO, '')                       AS DEP_LN_ACM_RTO       --当前笔合同存贷积数比
        ,COALESCE(C.TRM_MON, 0)                               AS TRM_MON              --当前笔合同期限月
        ,D.LAST_CTR_ID                                        AS LAST_CTR_ID          --前一笔贷款合同流水号
        ,COALESCE(D.LAST_CTR_AMT,0)                           AS LAST_CTR_AMT         --前一笔贷款合同金额
        ,D.LAST_INTR_RAT                                      AS LAST_INTR_RAT        --前一笔贷款合同执行月利率
        ,D.TRM_MON                                            AS LAST_TRM_MON         --前一笔合同期限月
        ,CASE
           WHEN D.LAST_INTR_RAT > 0 THEN D.LAST_INTR_RAT - C.INTR_RAT
           ELSE NULL
         END                                                  AS INTR_RAT_SPRD        --前一笔执行月利率-当前执行月利率
        ,C.CRD_DTRB_DT                                        AS CRD_DTRB_DT          --贷款发放日期
        ,COALESCE(C.MNG_MGR_ID_1, '')                         AS MNG_MGR_ID_1         --贷款管护人工号
        ,COALESCE(C.MNG_MGR_NM_1, '')                         AS MNG_MGR_NM_1         --贷款管护人姓名
        ,COALESCE(C.MNG_ORG_ID_1, '')                         AS MNG_ORG_ID_1         --贷款管护人机构号
        ,C.REG_DT                                             AS REG_DT               --贷款申请日期
        ,C.DIFF_TM                                            AS DIFF_TM              --贷款申请与贵金属购买间隔日期
        ,REPLACE(C.DBIL_USG,',', ';')                         AS DBIL_USG             --借据用途
        ,COALESCE(C.CRD_TYP, '')                              AS CRD_TYP              --贷款类型
        ,REPLACE(C.CRD_MOD_MARK,',', ';')                     AS CRD_MOD_MARK         --贷款利率优惠备注
        ,REPLACE(C.CRD_USG_MARK,',', ';')                     AS CRD_USG_MARK         --贷款用途备注
        ,REPLACE(C.CRD_MARK,',', ';')                         AS CRD_MARK             --贷款备注
        ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001
           ELSE NULL
         END)                                                 AS LOAN_RAT_SPRD        --贷款利息差
        ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001 - A.TRX_AMT
           ELSE NULL
         END)                                                 AS RAT_SPRD_AMT_INC     --利息差-贵金属购买金额
         ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001 - A.MID_INC_TOT_AMT
           ELSE NULL
         END)                                                 AS RAT_SPRD_MID_INC     --利息差-中收
        ,(CASE WHEN I.BUS_CTR_ID IS NOT NULL THEN '当前笔为低息贷款'
            ELSE '当前笔为非低息贷款' END)                     AS DX_IND               --当前笔是否低息贷款
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'yyyyMMdd'), TO_DATE(substr(A.TRX_DT,1,10), 'yyyy-MM-dd'), 'dd')  AS DIFF_DATE --日期差
FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01          A --贵金属相关信息_临时表01
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_02     B --风险控制下有效信贷户
ON      B.SAM_RSK_CTRL_ID = A.SAM_RSK_CTRL_ID --同一风险控制号
INNER JOIN    (
               SELECT   A.*
                       ,ROW_NUMBER() OVER ( PARTITION BY A.SYS_SRL_NBR ORDER BY A.REG_DT DESC ) AS RN --贵金属流水号 --贷款申请日期
               FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_06 A
              )                                                  C --当前笔贷款合同相关信息
ON      C.SYS_SRL_NBR = A.SYS_SRL_NBR --贵金属流水号
AND     RN = 1
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_08     D --前一笔贷款信息
ON      A.SYS_SRL_NBR = D.SYS_SRL_NBR --贵金属流水号
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_09     E --员工信息
ON      A.RCM_PSN_ID = E.EMPE_ID --销售人员工号
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_09     F --员工信息
ON      A.MNG_MGR_ID = F.EMPE_ID --管护客户经理工号
LEFT JOIN    edw.DIM_HR_ORG_BAS_INF_DD                   G --机构信息
ON      A.MNG_ORG_ID = G.ORG_ID  --管护机构号
AND     G.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD                 H --信贷业务申请信息
ON      C.BUSI_APL_ID = H.APL_ID --业务申请编号
AND     H.DT = '@@{yyyyMMdd}'
LEFT JOIN app_awp.OICS_FCT_GNRL_LOAN_AR_DTL_SMY_DD       I --普通贷款借据明细表(部分逻辑) 46273 仅有字段 BUS_CTR_ID
ON      C.BUS_CTR_ID = I.BUS_CTR_ID --信贷合同编号
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD                 J --信贷合同信息
ON      C.BUS_CTR_ID = J.BUSI_CTR_ID --信贷合同编号
AND     J.DT = '@@{yyyyMMdd}'; --交易日期

-- -----------------------------------------------------------------------------------------------------------



-- 贵金属捆绑销售清单
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_11;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_11 AS
SELECT  DISTINCT a.SYS_SRL_NBR
        ,A.ACG_DT                --数据日期
       ,A.TRX_DT                --交易日期
       ,A.PROD_NM               --产品名称
       ,A.ORD_ID                --订单号
       ,A.ORD_STS               --订单状态
       ,A.SAL_PPL_NM            --销售人员姓名
       ,A.SAL_PPL_POS           --销售人员岗位
       ,A.MNG_MGR_ID            --管户客户经理工号
       ,A.MNG_MGR_NM            --管户客户经理姓名
       ,A.MNG_MGR_POS           --管户人岗位
       ,A.MNG_ORG_ID            --管户人机构号
       ,A.MNG_ORG_NM            --管户人机构名称
       ,A.TRX_AMT               --交易金额
       ,A.SAM_RSK_CTRL_ID       --同一风险控制号
       ,A.CST_ID                --客户号
       ,A.DEPT_CST_NAME         --贷款客户名称
       ,A.EFE_LOAN_CST_IND      --是否信贷有效户
       ,A.WTHR_INT_EMPE         --是否行内员工
       ,A.SAM_RSK_EFE_LOAN_CST  --同一风险控制号下是信贷有效户的客户号
       ,A.EFE_DEP_CST_IND       --是否存款有效户
       ,A.EFE_CHM_CST_IND       --是否理财有效户
       ,A.BUS_CTR_ID            --当前笔合同流水号
       ,A.CST_RSK_GRD           --申请贷款时客户的信用风险等级  --原注释: 信用风险等级 当前笔当前的客户信用风险等级
       ,A.FIVE_CTG_NM           --当前笔的当前五级分类         --原注释: 当前笔贷款风险等级
       ,(CASE WHEN E.HPN_TYP_CD = '015' THEN D.PD_CD ELSE '' END) AS ZQ_IND  --当前笔是否展期贷款
       ,(CASE WHEN E.BUS_ID     = 'J'   THEN D.PD_CD ELSE '' END) AS ZXT_IND --当前笔是否助兴通
       ,A.CRD_CTR_AMT           --当前笔合同金额
       ,A.REF_INTR_RAT          --当前笔参考月利率
       ,A.INTR_RAT              --当前笔执行月利率
       ,A.DEP_LN_ACM_RTO        --当前笔合同存贷积数比
       ,A.TRM_MON               --当前笔合同期限月
       ,A.LAST_CTR_ID           --前一笔贷款合同流水号
       ,A.LAST_CTR_AMT          --前一笔贷款合同金额
       ,A.LAST_INTR_RAT         --前一笔贷款合同执行月利率
       ,A.LAST_TRM_MON          --前一笔合同期限月
       ,ROUND(case when coalesce(A.LAST_CTR_AMT,0) =0 then 0
            else coalesce(A.CRD_CTR_AMT,0)/A.LAST_CTR_AMT end, 2) AS CRD_LAST_CTR_AMT --当前笔合同金额/前一笔
       ,A.INTR_RAT_SPRD         --前一笔执行月利率-当前执行月利率
       ,A.CRD_DTRB_DT           --贷款发放日期
       ,A.MNG_MGR_ID_1          --贷款管护人工号
       ,A.MNG_MGR_NM_1          --贷款管护人姓名
       ,A.MNG_ORG_ID_1          --贷款管护人机构号
       ,A.REG_DT                --贷款申请日期
       ,A.DIFF_TM               --贷款申请与贵金属购买间隔日期
       ,A.DBIL_USG              --借据用途
       ,A.CRD_TYP               --贷款类型
       ,A.CRD_MOD_MARK          --贷款利率优惠备注
       ,A.CRD_USG_MARK          --贷款用途备注
       ,A.CRD_MARK              --贷款备注
       ,A.LOAN_RAT_SPRD         --贷款利息差
       ,A.RAT_SPRD_AMT_INC      --利息差-贵金属购买金额
       ,A.RAT_SPRD_MID_INC      --利息差-中收
       ,COALESCE(A.CRD_CTR_AMT-A.LAST_CTR_AMT-A.TRX_AMT,0) loan_diff_gold_amt    --贷款额度差-贵金属购买金额
       ,A.DX_IND                --当前笔是否低息贷款
       ,(CASE WHEN A.DIFF_TM >= 0 AND A.DIFF_TM <= 3  THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15
             AND (A.CRD_MOD_MARK LIKE '%贵金属%' OR A.CRD_USG_MARK LIKE '%贵金属%' OR A.CRD_MARK LIKE '%贵金属%' ) THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND A.LAST_INTR_RAT > 0 AND A.CRD_CTR_AMT * A.TRM_MON * (A.LAST_INTR_RAT - A.INTR_RAT) * 0.001 - A.TRX_AMT * 0.5 >= 0 THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND A.LAST_CTR_AMT  > 0 AND A.CRD_CTR_AMT / A.LAST_CTR_AMT > 1 AND A.CRD_CTR_AMT / A.LAST_CTR_AMT <= 1.2 THEN '是'
            WHEN (A.CST_RSK_GRD IN ('高风险','黑名单') OR A.FIVE_CTG_NM IN ('关注一级', '关注二级', '次级一级', '次级二级', '可疑', '损失')) THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND E.HPN_TYP_CD = '015' THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND E.BUS_ID     = 'J'   THEN '是'
            ELSE '否' END)      AS IS_BIND   --是否疑似捆绑
FROM TLDATA_DEV.SJXQ_SJ2023120591_CST_10  A --贵金属捆绑销售清单预处理_临时表_10
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD      D --信贷合同信息
ON      A.BUS_CTR_ID = D.BUSI_CTR_ID --合同流水号
AND     D.DT = '@@{yyyyMMdd}'
LEFT JOIN    (
              SELECT  APL_ID       --申请编号
                     ,HPN_TYP_CD   --发生类型代码
                     ,BUS_ID       --业务标识
              FROM    edw.DWD_BUS_LOAN_APL_INF_DD --信贷业务申请信息
              WHERE   DT = '@@{yyyyMMdd}'
              AND     (HPN_TYP_CD = '015' OR BUS_ID = 'J') --发生类型代码  --业务标识
             )                                        E
ON      D.BUSI_APL_ID = E.APL_ID --申请编号
;

--结果表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_12;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_12 AS
SElECT DISTINCT A.SYS_SRL_NBR   序号
    ,A.DATA_SRC        		    数据来源
    ,A.PVD_NM                  商铺名称
    ,A.ORD_ID                  订单号
    ,A.USR_NM                  买家名称
    ,A.CST_ID                  客户号
    ,A.CST_NM                  真实姓名
    ,A.PST_MTH                 邮寄方式
    ,A.TRX_DT                  下单日期
    ,A.PMT_TM                  付款时间
    ,A.PMT_MTH                 支付方式
    ,A.CHNL_NM                 渠道
    ,A.ORD_STS                 订单状态
    ,A.PROD_NM                 商品名称
    ,A.CMDT_SPEC               商品规格
    ,A.QTY                     购买数量
    ,A.GOODS_TYP               商品分类
    ,A.GOODS_RETURN_STATUS     商品退款状态
    ,A.CMDT_UNT_PRC            商品现金单价
    ,A.TRX_AMT                 商品应付现金总额
    ,A.CMSN_TYP                佣金类型
    ,A.MID_INC_RTO             佣金比例_金额
    ,A.MID_INC_TOT_AMT         佣金总额
    ,A.RCM_PSN_ID              推荐人工号
    ,A.RCM_PSN_NM              推荐人姓名
    ,A.RCM_PSN_AFL_DEPT_ID     推荐人所属部门_团队id
    ,A.RCM_PSN_AFL_DEPT        推荐人所属部门_团队
    ,A.RCM_PSN_AFL_SUB_BRN     支行名称
    ,A.RCM_PSN_AFL_BRN         分行名称

    ,B.SAM_RSK_CTRL_ID       同一风险控制号
    ,B.DEPT_CST_NAME         贷款客户名称
    ,B.EFE_LOAN_CST_IND      是否信贷有效户
    ,B.WTHR_INT_EMPE         是否行内员工
    ,B.SAM_RSK_EFE_LOAN_CST  同一风险控制号下是信贷有效户的客户号
    ,B.EFE_DEP_CST_IND       是否存款有效户
    ,B.EFE_CHM_CST_IND       是否理财有效户
    ,B.BUS_CTR_ID            当前笔合同流水号
    ,B.CST_RSK_GRD           申请贷款时客户的信用风险等级
    ,B.FIVE_CTG_NM           当前笔的当前五级分类
    ,B.ZQ_IND               当前笔是否展期贷款
    ,B.ZXT_IND              当前笔是否助兴通
    ,B.CRD_CTR_AMT           当前笔合同金额
    ,B.REF_INTR_RAT          当前笔参考月利率
    ,B.INTR_RAT              当前笔执行月利率
    ,B.DEP_LN_ACM_RTO        当前笔合同存贷积数比
    ,B.TRM_MON               当前笔合同期限月
    ,B.LAST_CTR_ID           前一笔贷款合同流水号
    ,B.LAST_CTR_AMT          前一笔贷款合同金额
    ,B.CRD_LAST_CTR_AMT     当前笔合同金额比前一笔
    ,B.LAST_INTR_RAT         前一笔贷款合同执行月利率
    ,B.LAST_TRM_MON          前一笔合同期限月
    ,B.INTR_RAT_SPRD         前一笔执行月利率_当前执行月利率
    ,B.CRD_DTRB_DT           贷款发放日期
    ,B.MNG_MGR_ID_1          贷款管护人工号
    ,B.MNG_MGR_NM_1          贷款管护人姓名
    ,B.MNG_ORG_ID_1          贷款管护人机构号
    ,B.REG_DT                贷款申请日期
    ,B.DIFF_TM               贷款申请与贵金属购买间隔日期
    ,B.DBIL_USG              借据用途
    ,B.CRD_TYP               贷款类型
    ,B.CRD_MOD_MARK          贷款利率优惠备注
    ,B.CRD_USG_MARK          贷款用途备注
    ,B.CRD_MARK              贷款备注
    ,B.LOAN_RAT_SPRD         贷款利息差
    ,B.RAT_SPRD_AMT_INC      利息差_贵金属购买金额
    ,B.RAT_SPRD_MID_INC      利息差_中收
    ,B.loan_diff_gold_amt    贷款额度差_贵金属购买金额
    ,B.DX_IND                当前笔是否低息贷款
    ,b.IS_BIND              是否疑似捆绑
FROM TLDATA_DEV.SJXQ_SJ2023120591_CST_01        A
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023120591_CST_11   B
ON A.SYS_SRL_NBR = B.SYS_SRL_NBR
ORDER BY A.SYS_SRL_NBR
;
/*
--数据核验
SELECT '1' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_01
union all
SELECT '2' seq,count(1) cnt,count(DISTINCT SAM_RSK_CTRL_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_02
union all
SELECT '3' seq,count(1) cnt,count(DISTINCT SAM_RSK_CTRL_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_03
union all
SELECT '4' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_04
union all
SELECT '5' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_05
union all
SELECT '6' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_06
union all
SELECT '7' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_07
union all
SELECT '8' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_08
union all
SELECT '9' seq,count(1) cnt,count(DISTINCT EMPE_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_09
union all
SELECT '10' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_10
union all
SELECT '11' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_11
;

1	19019	19019
2	529126	529126
3	12087	12087
4	30769	30769
5	91615	19019
6	19019	19019
7	1273019	2377
8	1518	1518
9	21943	21943
10	19019	19019
11	19019	19019
*/
**SJ2023120591_code2.sql
-- ODPS SQL
-- **********************************************************************
-- 任务描述: 贵金属捆绑销售清单
-- 创建日期: 2023-12-08
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
-- 任务输出
-- TLDATA_DEV.SJXQ_SJ2023120591_CST      --贵金属捆绑销售清单
--
-- ----------------------------------------------------------------------
-- 其他信息:
--新增3个字段：购买人同一风险控制号下征信分650分以下（是/否）购买人同一风险控制号下在我行为高风险或黑名单客户（是/否）购买人同一风险控制号下近6个月逾期2万以上（是/否）
-- **********************************************************************
-- ===========================================================================================================
-- Step.1  2023年贵金属购买明细表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_01;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_01 AS
select cast(col_1 as int)	SYS_SRL_NBR	--系统流水号
    ,col_2      DATA_SRC        		--数据来源
    ,col_3      PVD_NM                  --商铺名称
    ,col_4      ORD_ID                  --订单号
    ,col_5      USR_NM                  --买家名称
    ,col_6      CST_ID                  --客户号
    ,col_7      CST_NM                  --真实姓名
    ,col_8      PST_MTH                 --邮寄方式
    ,col_9      TRX_DT                  --下单日期
    ,col_10     PMT_TM                  --付款时间
    ,col_11     PMT_MTH                 --支付方式
    ,col_12     CHNL_NM                 --渠道
    ,col_13     ORD_STS                 --订单状态
    ,col_14     PROD_NM                 --商品名称
    ,col_15     CMDT_SPEC               --商品规格
    ,col_16     QTY                     --购买数量
    ,col_17     GOODS_TYP               --商品分类
    ,col_18     GOODS_RETURN_STATUS     --商品退款状态
    ,col_19     CMDT_UNT_PRC            --商品现金单价
    ,col_20     TRX_AMT                 --商品应付现金总额
    ,col_21     CMSN_TYP                --佣金类型
    ,col_22     MID_INC_RTO             --佣金比例_金额
    ,col_23     MID_INC_TOT_AMT         --佣金总额
    ,col_24     RCM_PSN_ID              --推荐人工号
    ,col_25     RCM_PSN_NM              --推荐人姓名
    ,col_26     RCM_PSN_AFL_DEPT_ID     --推荐人所属部门_团队id
    ,col_27     RCM_PSN_AFL_DEPT        --推荐人所属部门_团队
    ,col_28     RCM_PSN_AFL_SUB_BRN     --支行名称
    ,col_29     RCM_PSN_AFL_BRN         --分行名称
    ,COALESCE(F.SAM_RSK_CTRL_ID, '')                                      AS SAM_RSK_CTRL_ID       --同一风险控制号
    ,(CASE WHEN COALESCE(F.OWN_EMP_ID, '') <> '' THEN '是' ELSE '否' END) AS WTHR_INT_EMPE         --是否行内员工
    ,(CASE WHEN G.EFE_LOAN_CST_IND = '1' THEN '是' ELSE '否' END)         AS EFE_LOAN_CST_IND      --是否信贷有效户
    ,(CASE WHEN G.EFE_DEP_CST_IND  = '1' THEN '是' ELSE '否' END)         AS EFE_DEP_CST_IND       --是否存款有效户
    ,(CASE WHEN G.EFE_CHM_CST_IND  = '1' THEN '是' ELSE '否' END)         AS EFE_CHM_CST_IND       --是否理财有效户
    ,B.prm_mgr_id MNG_MGR_ID            --管护客户经理工号
    ,b.prm_org_id MNG_ORG_ID
from qbi_file_20231208_14_33_42       a          --19152
LEFT JOIN  ADM_PUB_APP.ADM_PBLC_CST_PRM_MNG_INF_DD B --客户主管户信息
ON      a.col_6 = B.CST_ID
AND     B.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWS_CST_IDV_BAS_INF_DD           F --个人客户基本信息汇总表
ON      a.col_6 = F.CST_ID --客户号
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN    adm_pub.ADM_CSM_CBAS_IND_INF_DD      G --客户集市-基础信息-有效户基本信息
ON      a.col_6 = G.CST_ID --客户号
AND     G.DT = '@@{yyyyMMdd}'
where a.pt=max_pt('qbi_file_20231208_14_33_42')
and a.col_6 <> '无'      -- 133个无客户号
;

-- ===========================================================================================================
-- 建表语句
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_02
(
     SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
    ,SAM_RSK_EFE_LOAN_CST STRING  COMMENT '同一风险控制号下是信贷有效户的客户号'
)
COMMENT '同一风险控制号_信贷有效户_临时表_02'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_03
(
     SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
)
COMMENT '同一风险控制号_临时表_03'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_04
(
     CST_ID               STRING  COMMENT '客户号'
    ,CST_NM               STRING  COMMENT '客户名'
    ,SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
)
COMMENT '同一风险控制号_带客户信息_临时表_04'
LIFECYCLE 31;


-- ===========================================================================================================
-- Step.2 同一风险控制号数据
-- 同一风险控制号_信贷有效户_临时表_02
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_02
SELECT  A.SAM_RSK_CTRL_ID                      AS SAM_RSK_CTRL_ID      --有效信贷户 同一风险控制号
       ,CONCAT_WS('|', COLLECT_SET(A.CST_ID))  AS SAM_RSK_EFE_LOAN_CST --同一风险控制号下是信贷有效户的客户号
FROM    edw.DWS_CST_BAS_INF_DD                A --客户基础信息汇总表
INNER JOIN    adm_pub.ADM_CSM_CBAS_IND_INF_DD B --客户集市-基础信息-有效户基本信息
ON      B.CST_ID = A.CST_ID --客户号
AND     B.EFE_LOAN_CST_IND = '1' --有效信贷户
AND     B.DT = '@@{yyyyMMdd}'
WHERE   A.SAM_RSK_CTRL_ID <> ''  --同一风险控制号 --剔除空值和空
AND     A.DT = '@@{yyyyMMdd}'
GROUP BY A.SAM_RSK_CTRL_ID;

-- -------------------------------------------------------------------------------------
-- 同一风险控制号_临时表_03
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_03
SELECT  T.SAM_RSK_CTRL_ID --同一风险控制号
FROM    (
         SELECT  DISTINCT B.SAM_RSK_CTRL_ID --贵金属客户 同一风险控制号
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01    A --贵金属相关信息
         INNER JOIN    edw.DWS_CST_BAS_INF_DD           B --客户集市-基础信息-有效户基本信息
         ON      A.CST_ID = B.CST_ID
         AND     B.DT = '@@{yyyyMMdd}'
        ) T;

-- -------------------------------------------------------------------------------------
-- 同一风险控制号_临时表_04
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_04
SELECT  A.CST_ID           --客户号
       ,A.CST_CHN_NM       --客户名称
       ,A.SAM_RSK_CTRL_ID  --贵金属客户 同一风险控制号
FROM    edw.DWS_CST_BAS_INF_DD                        A --客户集市-基础信息-有效户基本信息
INNER JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_03 B --同一风险控制号_临时表_03
ON      A.SAM_RSK_CTRL_ID = B.SAM_RSK_CTRL_ID --同一风险控制号
AND     COALESCE(B.SAM_RSK_CTRL_ID, '') <> '' --剔除空值和空
WHERE   A.DT = '@@{yyyyMMdd}';

-- ===========================================================================================================
-- 建表语句
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_05
(
     SYS_SRL_NBR          STRING  COMMENT '系统流水号'
    ,CST_ID               STRING  COMMENT '客户号'
    ,CST_NM               STRING  COMMENT '客户名'
    ,SAM_RSK_CTRL_ID      STRING  COMMENT '同一风险控制号'
    ,CST_OWN_IND          STRING  COMMENT '是否客户本人'
    ,PD_CD                STRING  COMMENT '产品代码'
    ,BUSI_CTR_ID          STRING  COMMENT '合同流水号'
    ,CTR_AMT              DECIMAL COMMENT '合同金额'
    ,CTR_BAL              DECIMAL COMMENT '合同余额'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,INTR_RAT             DECIMAL COMMENT '执行利率'
    ,REF_MON_INTR_RAT     DECIMAL COMMENT '参考月利率'
    ,REG_DT               STRING  COMMENT '申请日期'
    ,APNT_START_DT        STRING  COMMENT '发放日期'
    ,LOAN_USG_CD          STRING  COMMENT '贷款用途代码'
    ,INTR_RAT_ADJ_CMT     STRING  COMMENT '利率调整备注'
    ,USG_CMT              STRING  COMMENT '用途备注'
    ,CMT                  STRING  COMMENT '备注'
    ,BUSI_APL_ID          STRING  COMMENT '业务申请编号'
    ,DT                   STRING  COMMENT '合同日期'
    ,DIFF_TM              BIGINT  COMMENT '贷款申请与贵金属购买间隔日期'
    ,DIFF_TM2             BIGINT  COMMENT '贷款申请日期_贵金属购买日期'
    ,digital_unscr        DECIMAL COMMENT ''
    ,IS_RSK_CST           BIGINT  COMMENT ''
    ,ovd_amt              DECIMAL COMMENT ''
)
COMMENT '业务合同表相关信息_临时表_05'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_06
(
     CST_ID               STRING  COMMENT '客户号'
    ,TRX_DT               STRING  COMMENT '交易日期'
    ,DEPT_CST_NAME        STRING  COMMENT '贷款客户名称'
    ,BUS_CTR_ID           STRING  COMMENT '合同流水号'
    ,CRD_CTR_AMT          DECIMAL COMMENT '贷款合同金额'
    ,REF_INTR_RAT         DECIMAL COMMENT '参考月利率'
    ,INTR_RAT             DECIMAL COMMENT '执行月利率'
    ,CRD_DTRB_DT          STRING  COMMENT '贷款发放日期'
    ,MNG_MGR_ID_1         STRING  COMMENT '贷款管护人工号'
    ,MNG_MGR_NM_1         STRING  COMMENT '贷款管护人姓名'
    ,MNG_ORG_ID_1         STRING  COMMENT '贷款管护人机构号'
    ,REG_DT               STRING  COMMENT '贷款申请日期'
    ,DIFF_TM              BIGINT  COMMENT '贷款申请与贵金属购买间隔日期'
    ,DIFF_TM2             BIGINT  COMMENT '贷款申请日期_贵金属购买日期'
    ,DBIL_USG             STRING  COMMENT '借据用途'
    ,CRD_TYP              STRING  COMMENT '贷款类型'
    ,CRD_MOD_MARK         STRING  COMMENT '贷款利率优惠备注'
    ,CRD_USG_MARK         STRING  COMMENT '贷款用途备注'
    ,CRD_MARK             STRING  COMMENT '贷款备注'
    ,BUSI_APL_ID          STRING  COMMENT '业务申请编号'
    ,PD_CD                STRING  COMMENT '产品代码'
    ,SYS_SRL_NBR          STRING  COMMENT '系统流水号'
    ,TRM_MON              BIGINT  COMMENT '期限月'
)
COMMENT '当前笔贷款合同相关信息_临时表_06'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_07
(
     SYS_SRL_NBR          STRING  COMMENT '贵金属流水号'
    ,BUSI_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,CST_ID               STRING  COMMENT '客户号'
    ,PD_CD                STRING  COMMENT '产品代码转换'
    ,CTR_AMT              DECIMAL COMMENT '金额'
    ,INTR_RAT             DECIMAL COMMENT '利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,HDL_DT               STRING  COMMENT '经办日期'
    ,ACG_DT               STRING  COMMENT '日期'
)
COMMENT '当前笔贷款合同相关信息_临时表_07'
LIFECYCLE 31;

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_08
(
     SYS_SRL_NBR          STRING  COMMENT '贵金属流水号'
    ,LAST_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,LAST_CTR_AMT         DECIMAL COMMENT '前一笔贷款合同金额'
    ,LAST_INTR_RAT        DECIMAL COMMENT '前一笔贷款合同执行月利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
)
COMMENT '前一笔贷款信息_临时表_08'
LIFECYCLE 31;

-- ===========================================================================================================
-- Step.3  信贷合同信息数据
--贵金属客户的信贷合同相关信息_临时表_05
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_05
SELECT  A.SYS_SRL_NBR                         --系统流水号
       ,A.CST_ID           AS CST_ID          --客户号
       ,A.CST_NM           AS SAM_RSK_CST_NM  --客户名
       ,A.SAM_RSK_CTRL_ID  AS SAM_RSK_CTRL_ID --同一风险控制号
       ,A.CST_OWN_IND      AS CST_OWN_IND     --是否客户本人
       ,(CASE SUBSTR(B.PD_CD, 1, 9)
          WHEN '201050101' THEN '1'           --20105010100 个人消费性贷款
          WHEN '201050102' THEN '2'           --20105010200 个人经营性贷款
          WHEN '201040101' THEN '3'           --20104010100 流动资金贷款
          WHEN '201040102' THEN '4'           --20104010200 固定资产贷款
          ELSE '5'                            --20104010600 法人购房贷款
        END)               AS PD_CD           --产品代码    --普通贷款产品代码二次转码
       ,B.BUSI_CTR_ID                         --合同流水号
       ,B.CTR_AMT                             --合同金额
       ,B.CTR_BAL                             --合同余额
       ,B.TRM_MON                             --期限月
       ,B.INTR_RAT                            --执行利率
       ,B.REF_MON_INTR_RAT                    --参考月利率
       ,C.REG_DT                              --申请日期
       ,D.DTRB_DT                             --最早发放日期
       ,B.LOAN_USG_CD                         --贷款用途代码
       ,B.INTR_RAT_ADJ_CMT                    --利率调整备注
       ,B.USG_CMT                             --用途备注
       ,B.CMT                                 --备注
       ,B.BUSI_APL_ID                         --业务申请编号
       ,B.DT                                  --合同日期
       --贷款申请与贵金属购买间隔日期   --信贷业务登记申请日期 -贵金属交易日期
       ,ABS(DATEDIFF(TO_DATE(C.REG_DT, 'yyyyMMdd'), TO_DATE(SUBSTR(A.TRX_DT,1,10),'yyyy-MM-dd'), 'dd')) AS DIFF_TM
       ,DATEDIFF(TO_DATE(C.REG_DT, 'yyyyMMdd'), TO_DATE(SUBSTR(A.TRX_DT,1,10),'yyyy-MM-dd'), 'dd')         DIFF_TM2
       ,T1.digital_unscr
       ,CASE WHEN T2.cst_id IS NOT NULL THEN 1 ELSE 0 END IS_RSK_CST
       ,T3.ovd_amt
FROM    (--45013	43490 重复
         SELECT   A1.SYS_SRL_NBR                                --系统流水号
                 ,A1.TRX_DT                                     --交易日期
                 ,A1.SAM_RSK_CTRL_ID                            --同一风险控制号
                 ,COALESCE(A3.CST_ID, A1.CST_ID) AS CST_ID      --客户号
                 ,COALESCE(A3.CST_NM, A2.CST_NM) AS CST_NM      --客户名
                 ,CASE
                    WHEN A3.CST_ID IS NULL     THEN '1'
                    WHEN A3.CST_ID = A1.CST_ID THEN '1'
                    ELSE '0'
                  END                            AS CST_OWN_IND --是否客户本人
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01      A1 --贵金属相关信息_临时表01
         LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_04 A2 --同一风险控制号_临时表_04
         ON      A1.CST_ID = A2.CST_ID --客户号
         AND     NVL(A2.CST_ID,'') <> '' --剔除空值和空
         LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_04 A3 --同一风险控制号_临时表_04
         ON      A2.SAM_RSK_CTRL_ID = A3.SAM_RSK_CTRL_ID --同一风险控制号
         AND     NVL(A3.SAM_RSK_CTRL_ID,'') <> '' --剔除空值和空
        )                                        A
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD B --信贷合同信息
ON      A.CST_ID = B.CST_ID --客户号
AND     NVL(B.CST_ID,'') <> '' --剔除空值和空
AND     B.CRC_IND <> '1'       --剔除循环贷款
AND     SUBSTR(B.PD_CD, 1, 9) IN ( '201050101' , '201050102' , '201040101' , '201040102' , '201040106' ) --产品代码
--普通贷款:-20105010100 个人消费性贷款 20105010200 个人经营性贷款 20104010100 流动资金贷款 20104010200 固定资产贷款 20104010600 法人购房贷款
AND     B.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD C --信贷业务申请信息
ON      B.BUSI_APL_ID = C.APL_ID --业务申请编号
AND     NVL(C.APL_ID,'') <> ''   --剔除空值和空
AND     C.DT = '@@{yyyyMMdd}'
LEFT JOIN (
            SELECT  BUS_CTR_ID               --信贷合同编号
                   ,MIN(DTRB_DT) AS DTRB_DT  --最早发放日期
              FROM edw.DWS_BUS_LOAN_DBIL_INF_DD --贷款借据信息汇总
             WHERE DT = '@@{yyyyMMdd}'
          GROUP BY BUS_CTR_ID --信贷合同编号
          )                                      D
ON      B.BUSI_CTR_ID = D.BUS_CTR_ID --信贷合同编号
left join (--征信分
    select cst_id,digital_unscr,row_number() over(partition by cst_id order by report_id desc) rn
    from adm_pub.adm_csm_cbus_out_crd_idv_bas_info_di
    where dt <= '@@{yyyyMMdd}'
) T1 on a.CST_ID=T1.cst_id and T1.rn=1
left join (--高风险
    select distinct dt,cst_id
    from edw.dim_bus_loan_ctr_inf_dd
    where dt between '20230101' and '@@{yyyyMMdd}' and cst_rsk_grd>='5'
) t2 on replace(a.trx_dt,'-','')=t2.dt and a.CST_ID=t2.cst_id
left join (--逾期金额
    select cst_id,report_id,ovd_amt,row_number() over(partition by cst_id order by report_id desc ) rn
    from (
        SELECT  cst_id,P1.report_id ,SUM(P1.ovd_amt) AS ovd_amt
        FROM    edw.dim_cst_ccrc_idv_loan_inf_dd P1
        WHERE   p1.DT = '@@{yyyyMMdd}'
            and substr(report_id,1,8)>='20230101'
        GROUP BY cst_id,P1.report_id
    ) a
) T3 on a.CST_ID=T3.cst_id and T3.rn=1
;

--新增3个字段
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_05_1;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_05_1 AS
SELECT SYS_SRL_NBR
    ,case
        when min(digital_unscr)<=650 then '是'
        when min(digital_unscr)>650 then '否'
    end                                         zx_score_less_650   --同一风险控制号下征信分650分以下
    ,if(sum(IS_RSK_CST)>0,'是','否')            high_rsk_black_cst  --同一风险控制号下在我行为高风险或黑名单客户
    ,if(max(ovd_amt)>=20000,'是','否')          lst_6m_ovd_amt_2w   --同一风险控制号下近6个月逾期2万以上
FROM TLDATA_DEV.SJXQ_SJ2023120591_CST_05
GROUP BY SYS_SRL_NBR
;

-- ------------------------------------------------------------------------------------------------------------
-- 当前笔贷款合同相关信息_临时表_06
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_06
SELECT  A.CST_ID                                         AS CST_ID       --客户号
       ,A.TRX_DT                                         AS TRX_DT       --交易日期
       ,COALESCE(B.CST_NM, C.CST_NM)                     AS DEPT_CST_NM  --贷款客户名称
       ,COALESCE(B.BUSI_CTR_ID, C.BUSI_CTR_ID)           AS BUS_CTR_ID   --合同流水号
       ,COALESCE(B.CTR_AMT, C.CTR_AMT)                   AS CRD_CTR_AMT  --贷款合同金额
       ,COALESCE(B.REF_MON_INTR_RAT, C.REF_MON_INTR_RAT) AS REF_INTR_RAT --参考月利率
       ,COALESCE(B.INTR_RAT, C.INTR_RAT)                 AS INTR_RAT     --执行月利率
       ,COALESCE(B.APNT_START_DT, C.APNT_START_DT)       AS CRD_DTRB_DT  --贷款发放日期
       ,D.ACS_MNGR_ID                                    AS MNG_MGR_ID_1 --管护客户经理工号
       ,E.EMPE_NM                                        AS MNG_MGR_NM_1 --管护客户经理姓名
       ,D.ACS_ORG_ID                                     AS MNG_ORG_ID_1 --管护机构号
       ,COALESCE(B.REG_DT, C.REG_DT)                     AS REG_DT       --贷款申请日期
       ,COALESCE(B.DIFF_TM, C.DIFF_TM)                   AS DIFF_TM      --贷款申请与贵金属购买间隔日期
       ,COALESCE(B.DIFF_TM2, C.DIFF_TM2)                 AS DIFF_TM2
       ,''                                               AS DBIL_USG     --借据用途
       ,COALESCE(G.CD_VAL_DSCR, '')                      AS CRD_TYP      --贷款类型(码值含义)
       ,COALESCE(B.INTR_RAT_ADJ_CMT, C.INTR_RAT_ADJ_CMT) AS CRD_MOD_MARK --贷款利率优惠备注
       ,COALESCE(B.USG_CMT, C.USG_CMT)                   AS CRD_USG_MARK --贷款用途备注
       ,COALESCE(B.CMT, C.CMT)                           AS CRD_MARK     --贷款备注
       ,COALESCE(B.BUSI_APL_ID, C.BUSI_APL_ID)           AS BUSI_APL_ID  --业务申请编号
       ,COALESCE(B.PD_CD, C.PD_CD)                       AS PD_CD        --产品代码
       ,A.SYS_SRL_NBR                                    AS SYS_SRL_NBR  --系统流水号
       ,COALESCE(B.TRM_MON,C.TRM_MON)                    AS TRM_MON      --期限月
FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01 A --贵金属相关信息_临时表01
LEFT JOIN    (
              SELECT   T.*
                      ,ROW_NUMBER() OVER (PARTITION BY SYS_SRL_NBR ORDER BY DIFF_TM ASC) AS RN
              FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_05 T --业务合同相关信息_临时表_05
              WHERE   T.CST_OWN_IND = '1' --客户本人
              AND     T.DIFF_TM <= 15     --贷款申请与贵金属购买间隔日期
             )                                          B
ON      A.SYS_SRL_NBR = B.SYS_SRL_NBR --系统流水号
AND     B.RN = 1
LEFT JOIN    (
              SELECT   T.*
                      ,ROW_NUMBER() OVER (PARTITION BY SYS_SRL_NBR ORDER BY DIFF_TM ASC) AS RN
              FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_05 T --业务合同相关信息_临时表_05
              WHERE   T.CST_OWN_IND = '0' --非客户本人，同一风险控制号下的其他客户
              AND     T.DIFF_TM <= 15     --贷款申请与贵金属购买间隔日期
             )                                          C
ON      A.SYS_SRL_NBR = C.SYS_SRL_NBR --系统流水号
AND     C.RN = 1
LEFT JOIN    edw.DWD_BUS_LOAN_CTR_MGR_INF_DD    D --信贷合同管护信息
ON      COALESCE(B.BUSI_CTR_ID, C.BUSI_CTR_ID) = D.BUSI_CTR_ID --合同流水号
AND     D.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWS_HR_EMPE_INF_DD             E --员工汇总信息
ON      D.ACS_MNGR_ID = E.EMPE_ID --管护客户经理工号
AND     E.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD        F --信贷业务申请信息
ON      COALESCE(B.BUSI_APL_ID, C.BUSI_APL_ID) = F.APL_ID
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_CODE_LIBRARY_DD            G --码值表(发生类型)
ON      F.HPN_TYP_CD = G.CD_VAL --发生类型 码值
AND     G.TBL_NM = 'DIM_BUS_LOAN_CTR_INF_DD'     -- DWD_BUS_LOAN_APL_INF_DD 该表码值表错误
AND     G.FLD_NM = 'HPN_TYP_CD'
AND     G.DT = '@@{yyyyMMdd}';

CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_06_1
(
     BUSI_CTR_ID          STRING  COMMENT '前一笔贷款合同'
    ,CST_ID               STRING  COMMENT '客户号'
    ,PD_CD                STRING  COMMENT '产品代码转换'
    ,CTR_AMT              DECIMAL COMMENT '金额'
    ,INTR_RAT             DECIMAL COMMENT '利率'
    ,TRM_MON              BIGINT  COMMENT '期限月'
    ,HDL_DT               STRING  COMMENT '经办日期'
    ,ACG_DT               STRING  COMMENT '日期'
)
COMMENT '贷款合同信息_历史存续状态_临时表'
LIFECYCLE 31;

INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_06_1
SELECT  A.BUSI_CTR_ID              --前一笔贷款合同
       ,A.CST_ID                   --客户号
       ,(CASE SUBSTR(A.PD_CD, 1, 9)
         WHEN '201050101' THEN '1' --20105010100 个人消费性贷款
         WHEN '201050102' THEN '2' --20105010200 个人经营性贷款
         WHEN '201040101' THEN '3' --20104010100 流动资金贷款
         WHEN '201040102' THEN '4' --20104010200 固定资产贷款
         ELSE '5'                  --20104010600 法人购房贷款
       END)              AS PD_CD  --产品代码转换
       ,A.CTR_AMT                  --金额
       ,A.INTR_RAT                 --利率
       ,A.TRM_MON                  --期限月
       ,A.HDL_DT                   --经办日期
       ,A.DT             AS ACG_DT --日期
FROM    edw.DIM_BUS_LOAN_CTR_INF_DD A --信贷合同信息
WHERE   A.CRC_IND <> '1'    --剔除循环贷款
AND     SUBSTR(A.PD_CD, 1, 9) IN ('201050101', '201050102', '201040101', '201040102', '201040106') --产品代码 --普通贷款
AND     A.DT <= '@@{yyyyMMdd}' and a.dt>='20220701'
AND     A.CTR_BAL > 0;        --余额不为0，存续


-- ------------------------------------------------------------------------------------------------------------
-- 历史贷款合同相关信息_临时表_07
INSERT  OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_07
SELECT  B.SYS_SRL_NBR --贵金属流水号
       ,A.BUSI_CTR_ID --前一笔贷款合同
       ,A.CST_ID      --客户号
       ,A.PD_CD       --产品代码转换
       ,A.CTR_AMT     --金额
       ,A.INTR_RAT    --利率
       ,A.TRM_MON     --期限月
       ,A.HDL_DT      --经办日期
       ,A.ACG_DT      --日期
FROM  TLDATA_DEV.SJXQ_SJ2023120591_CST_06_1 A --贷款合同信息_历史存续状态_临时表
INNER JOIN (
           SELECT  DISTINCT
                   SYS_SRL_NBR  --贵金属流水号
                  ,CST_ID       --客户号
             FROM TLDATA_DEV.SJXQ_SJ2023120591_CST_06
            WHERE COALESCE(BUS_CTR_ID, '') <> '' --合同流水号 --剔除空值和空
            )                               B
ON      A.CST_ID = B.CST_ID
;

-- ------------------------------------------------------------------------------------------------------------
-- 前一笔贷款信息_临时表_08
-- 若在贵金属交易日前后30天内存在贷款申请的，则取其中与贵金属交易日最近的一笔贷款申请（该笔贷款额度为X）
-- 并取该笔贷款申请往前3个月内存续的上一笔贷款申请（该笔贷款额度为Y）
--
-- 前一笔：选择同一业务品种，且与当前笔不是同一天申请的贷款，当前笔贷款申请日往前3个月内有余额的
-- 也要剔除&ldquo;业务品种&rdquo;是&ldquo;随贷通&rdquo;，及&ldquo;是否循环贷款&rdquo;为&ldquo;是&rdquo;的贷款。前一笔考虑同一客户号下的前一笔。

INSERT   OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_08
SELECT   T.SYS_SRL_NBR                   --贵金属流水号
        ,T.BUSI_CTR_ID  AS LAST_CTR_ID   --前一笔贷款合同
        ,T.CTR_AMT      AS LAST_CTR_AMT  --前一笔贷款合同金额
        ,T.INTR_RAT     AS LAST_INTR_RAT --前一笔贷款合同执行月利率
        ,T.TRM_MON                       --期限月
FROM    (
         SELECT   A.SYS_SRL_NBR --贵金属流水号
                 ,B.BUSI_CTR_ID --前一笔贷款合同
                 ,B.CTR_AMT     --前一笔贷款合同金额
                 ,B.INTR_RAT    --前一笔贷款合同执行月利率
                 ,B.TRM_MON     --期限月
                 ,ROW_NUMBER() OVER ( PARTITION BY A.SYS_SRL_NBR ORDER BY B.HDL_DT DESC ) AS RN --贵金属流水号 分组 -- 经办日期 倒序
         FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_06     A
         INNER JOIN  TLDATA_DEV.SJXQ_SJ2023120591_CST_07 B
         ON      A.SYS_SRL_NBR = B.SYS_SRL_NBR --贵金属流水号
         AND     A.CST_ID      = B.CST_ID      --客户号
         AND     A.PD_CD       = B.PD_CD       --产品代码
         AND     B.ACG_DT >= TO_CHAR(DATEADD(TO_DATE(A.REG_DT, 'yyyyMMdd'), 0-90, 'dd'), 'yyyyMMdd') --贷款申请日期 --当前笔往前推3个月，有存续的
         AND     B.ACG_DT <  A.REG_DT
        ) T
WHERE   T.RN = 1;


-- ===========================================================================================================
-- 建表语句
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_09
(
     EMPE_ID STRING COMMENT '员工号'
    ,EMPE_NM STRING COMMENT '员工姓名'
    ,POS_NM  STRING COMMENT '职位名称'
)
COMMENT '员工信息处理_临时表_09'
LIFECYCLE 31;

-- ===========================================================================================================
-- Step.4  员工信息处理
-- 员工信息处理_临时表_09
INSERT   OVERWRITE TABLE TLDATA_DEV.SJXQ_SJ2023120591_CST_09
SELECT   A.EMPE_ID AS EMPE_ID --员工号
        ,A.EMPE_NM AS EMPE_NM --员工姓名
        ,B.POS_NM  AS POS_NM  --职位名称
FROM    edw.DWS_HR_EMPE_INF_DD          A -- 员工汇总信息
INNER JOIN    edw.DIM_HR_ORG_JOB_INF_DD B -- 职位信息
ON      B.POS_ID = A.POS_ENC --职位编号
AND     B.DT = '@@{yyyyMMdd}'
WHERE   A.DT = '@@{yyyyMMdd}';


-- ===========================================================================================================
-- Step.5  贵金属捆绑销售清单_最终汇总处理
-- 贵金属捆绑销售清单预处理_临时表_10
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_10;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_10 AS
SELECT  '@@{yyyy-MM-dd}'                                      AS ACG_DT               --数据日期
        ,A.SYS_SRL_NBR
        ,substr(A.TRX_DT,1,10)                                AS TRX_DT               --交易日期
        ,A.PROD_NM                                            AS PROD_NM              --产品名称
        ,A.ORD_ID                                             AS ORD_ID               --订单号
        ,A.ORD_STS                                            AS ORD_STS              --订单状态
        ,COALESCE(E.EMPE_NM, '')                              AS SAL_PPL_NM           --销售人员姓名  --销售客户经理姓名
        ,COALESCE(E.POS_NM, '')                               AS SAL_PPL_POS          --销售人员岗位
        ,A.MNG_MGR_ID                                         AS MNG_MGR_ID           --管户客户经理工号
        ,COALESCE(F.EMPE_NM, '')                              AS MNG_MGR_NM           --管户客户经理姓名
        ,COALESCE(F.POS_NM, '')                               AS MNG_MGR_POS          --管户人岗位
        ,A.MNG_ORG_ID                                         AS MNG_ORG_ID           --管户人机构号
        ,COALESCE(G.ORG_NM, '')                               AS MNG_ORG_NM           --管户人机构名称
        ,A.TRX_AMT                                            AS TRX_AMT              --交易金额
        ,A.SAM_RSK_CTRL_ID                                    AS SAM_RSK_CTRL_ID      --同一风险控制号
        ,A.CST_ID                                             AS CST_ID               --客户号
        ,COALESCE(C.DEPT_CST_NAME, '')                        AS DEPT_CST_NAME        --贷款客户名称
        ,A.EFE_LOAN_CST_IND                                   AS EFE_LOAN_CST_IND     --是否信贷有效户
        ,A.WTHR_INT_EMPE                                      AS WTHR_INT_EMPE        --是否行内员工
        ,COALESCE(B.SAM_RSK_EFE_LOAN_CST, '')                 AS SAM_RSK_EFE_LOAN_CST --同一风险控制号下是信贷有效户的客户号
        ,A.EFE_DEP_CST_IND                                    AS EFE_DEP_CST_IND      --是否存款有效户
        ,A.EFE_CHM_CST_IND                                    AS EFE_CHM_CST_IND      --是否理财有效户
        ,COALESCE(C.BUS_CTR_ID, '')                           AS BUS_CTR_ID           --当前笔贷款合同流水号
        ,(CASE WHEN J.CST_RSK_GRD = '1' THEN '低风险'
               WHEN J.CST_RSK_GRD = '2' THEN '中低风险'
               WHEN J.CST_RSK_GRD = '3' THEN '中风险'
               WHEN J.CST_RSK_GRD = '4' THEN '中高风险'
               WHEN J.CST_RSK_GRD = '5' THEN '高风险'
               WHEN J.CST_RSK_GRD = '6' THEN '黑名单'
               ELSE ''
          END)                                                AS CST_RSK_GRD          --申请贷款时客户的信用风险等级
        ,(CASE WHEN J.FIVE_CTG_CD = '01' THEN '正常一级'
               WHEN J.FIVE_CTG_CD = '02' THEN '正常二级'
               WHEN J.FIVE_CTG_CD = '03' THEN '正常三级'
               WHEN J.FIVE_CTG_CD = '04' THEN '正常四级'
               WHEN J.FIVE_CTG_CD = '05' THEN '正常五级'
               WHEN J.FIVE_CTG_CD = '06' THEN '正常六级'
               WHEN J.FIVE_CTG_CD = '07' THEN '关注一级'
               WHEN J.FIVE_CTG_CD = '08' THEN '关注二级'
               WHEN J.FIVE_CTG_CD = '09' THEN '次级一级'
               WHEN J.FIVE_CTG_CD = '10' THEN '次级二级'
               WHEN J.FIVE_CTG_CD = '11' THEN '可疑'
               WHEN J.FIVE_CTG_CD = '12' THEN '损失'
               ELSE ''
           END)                                               AS FIVE_CTG_NM          --当前笔的当前五级分类
        ,COALESCE(C.CRD_CTR_AMT, 0)                                        AS CRD_CTR_AMT          --当前笔合同金额
        ,C.REF_INTR_RAT                                       AS REF_INTR_RAT         --当前笔参考月利率
        ,C.INTR_RAT                                           AS INTR_RAT             --当前笔执行月利率
        ,COALESCE(H.DEP_LN_ACM_RTO, '')                       AS DEP_LN_ACM_RTO       --当前笔合同存贷积数比
        ,COALESCE(C.TRM_MON, 0)                               AS TRM_MON              --当前笔合同期限月
        ,D.LAST_CTR_ID                                        AS LAST_CTR_ID          --前一笔贷款合同流水号
        ,COALESCE(D.LAST_CTR_AMT,0)                           AS LAST_CTR_AMT         --前一笔贷款合同金额
        ,D.LAST_INTR_RAT                                      AS LAST_INTR_RAT        --前一笔贷款合同执行月利率
        ,D.TRM_MON                                            AS LAST_TRM_MON         --前一笔合同期限月
        ,CASE
           WHEN D.LAST_INTR_RAT > 0 THEN D.LAST_INTR_RAT - C.INTR_RAT
           ELSE NULL
         END                                                  AS INTR_RAT_SPRD        --前一笔执行月利率-当前执行月利率
        ,C.CRD_DTRB_DT                                        AS CRD_DTRB_DT          --贷款发放日期
        ,COALESCE(C.MNG_MGR_ID_1, '')                         AS MNG_MGR_ID_1         --贷款管护人工号
        ,COALESCE(C.MNG_MGR_NM_1, '')                         AS MNG_MGR_NM_1         --贷款管护人姓名
        ,COALESCE(C.MNG_ORG_ID_1, '')                         AS MNG_ORG_ID_1         --贷款管护人机构号
        ,C.REG_DT                                             AS REG_DT               --贷款申请日期
        ,C.DIFF_TM                                            AS DIFF_TM              --贷款申请与贵金属购买间隔日期
        ,C.DIFF_TM2
        ,REPLACE(C.DBIL_USG,',', ';')                         AS DBIL_USG             --借据用途
        ,COALESCE(C.CRD_TYP, '')                              AS CRD_TYP              --贷款类型
        ,REPLACE(C.CRD_MOD_MARK,',', ';')                     AS CRD_MOD_MARK         --贷款利率优惠备注
        ,REPLACE(C.CRD_USG_MARK,',', ';')                     AS CRD_USG_MARK         --贷款用途备注
        ,REPLACE(C.CRD_MARK,',', ';')                         AS CRD_MARK             --贷款备注
        ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001
           ELSE NULL
         END)                                                 AS LOAN_RAT_SPRD        --贷款利息差
        ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001 - A.TRX_AMT
           ELSE NULL
         END)                                                 AS RAT_SPRD_AMT_INC     --利息差-贵金属购买金额
         ,(CASE
           WHEN D.LAST_INTR_RAT > 0 THEN ( D.LAST_INTR_RAT - C.INTR_RAT ) * C.CRD_CTR_AMT * C.TRM_MON * 0.001 - A.MID_INC_TOT_AMT
           ELSE NULL
         END)                                                 AS RAT_SPRD_MID_INC     --利息差-中收
        ,(CASE WHEN I.BUS_CTR_ID IS NOT NULL THEN '当前笔为低息贷款'
            ELSE '当前笔为非低息贷款' END)                     AS DX_IND               --当前笔是否低息贷款
        ,DATEDIFF(TO_DATE('@@{yyyyMMdd}', 'yyyyMMdd'), TO_DATE(substr(A.TRX_DT,1,10), 'yyyy-MM-dd'), 'dd')  AS DIFF_DATE --日期差
FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_01          A --贵金属相关信息_临时表01
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_02     B --风险控制下有效信贷户
ON      B.SAM_RSK_CTRL_ID = A.SAM_RSK_CTRL_ID --同一风险控制号
INNER JOIN    (
               SELECT   A.*
                       ,ROW_NUMBER() OVER ( PARTITION BY A.SYS_SRL_NBR ORDER BY A.REG_DT DESC ) AS RN --贵金属流水号 --贷款申请日期
               FROM    TLDATA_DEV.SJXQ_SJ2023120591_CST_06 A
              )                                                  C --当前笔贷款合同相关信息
ON      C.SYS_SRL_NBR = A.SYS_SRL_NBR --贵金属流水号
AND     RN = 1
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_08     D --前一笔贷款信息
ON      A.SYS_SRL_NBR = D.SYS_SRL_NBR --贵金属流水号
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_09     E --员工信息
ON      A.RCM_PSN_ID = E.EMPE_ID --销售人员工号
LEFT JOIN    TLDATA_DEV.SJXQ_SJ2023120591_CST_09     F --员工信息
ON      A.MNG_MGR_ID = F.EMPE_ID --管护客户经理工号
LEFT JOIN    edw.DIM_HR_ORG_BAS_INF_DD                   G --机构信息
ON      A.MNG_ORG_ID = G.ORG_ID  --管护机构号
AND     G.DT = '@@{yyyyMMdd}'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD                 H --信贷业务申请信息
ON      C.BUSI_APL_ID = H.APL_ID --业务申请编号
AND     H.DT = '@@{yyyyMMdd}'
LEFT JOIN app_awp.OICS_FCT_GNRL_LOAN_AR_DTL_SMY_DD       I --普通贷款借据明细表(部分逻辑) 46273 仅有字段 BUS_CTR_ID
ON      C.BUS_CTR_ID = I.BUS_CTR_ID --信贷合同编号
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD                 J --信贷合同信息
ON      C.BUS_CTR_ID = J.BUSI_CTR_ID --信贷合同编号
AND     J.DT = '@@{yyyyMMdd}'; --交易日期

-- -----------------------------------------------------------------------------------------------------------



-- 贵金属捆绑销售清单
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_11;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_11 AS
SELECT  DISTINCT a.SYS_SRL_NBR
        ,A.ACG_DT                --数据日期
       ,A.TRX_DT                --交易日期
       ,A.PROD_NM               --产品名称
       ,A.ORD_ID                --订单号
       ,A.ORD_STS               --订单状态
       ,A.SAL_PPL_NM            --销售人员姓名
       ,A.SAL_PPL_POS           --销售人员岗位
       ,A.MNG_MGR_ID            --管户客户经理工号
       ,A.MNG_MGR_NM            --管户客户经理姓名
       ,A.MNG_MGR_POS           --管户人岗位
       ,A.MNG_ORG_ID            --管户人机构号
       ,A.MNG_ORG_NM            --管户人机构名称
       ,A.TRX_AMT               --交易金额
       ,A.SAM_RSK_CTRL_ID       --同一风险控制号
       ,A.CST_ID                --客户号
       ,A.DEPT_CST_NAME         --贷款客户名称
       ,A.EFE_LOAN_CST_IND      --是否信贷有效户
       ,A.WTHR_INT_EMPE         --是否行内员工
       ,A.SAM_RSK_EFE_LOAN_CST  --同一风险控制号下是信贷有效户的客户号
       ,A.EFE_DEP_CST_IND       --是否存款有效户
       ,A.EFE_CHM_CST_IND       --是否理财有效户
       ,A.BUS_CTR_ID            --当前笔合同流水号
       ,A.CST_RSK_GRD           --申请贷款时客户的信用风险等级  --原注释: 信用风险等级 当前笔当前的客户信用风险等级
       ,A.FIVE_CTG_NM           --当前笔的当前五级分类         --原注释: 当前笔贷款风险等级
       ,(CASE WHEN E.HPN_TYP_CD = '015' THEN D.PD_CD ELSE '' END) AS ZQ_IND  --当前笔是否展期贷款
       ,(CASE WHEN E.BUS_ID     = 'J'   THEN D.PD_CD ELSE '' END) AS ZXT_IND --当前笔是否助兴通
       ,A.CRD_CTR_AMT           --当前笔合同金额
       ,A.REF_INTR_RAT          --当前笔参考月利率
       ,A.INTR_RAT              --当前笔执行月利率
       ,A.DEP_LN_ACM_RTO        --当前笔合同存贷积数比
       ,A.TRM_MON               --当前笔合同期限月
       ,A.LAST_CTR_ID           --前一笔贷款合同流水号
       ,A.LAST_CTR_AMT          --前一笔贷款合同金额
       ,A.LAST_INTR_RAT         --前一笔贷款合同执行月利率
       ,A.LAST_TRM_MON          --前一笔合同期限月
       ,ROUND(case when coalesce(A.LAST_CTR_AMT,0) =0 then 0
            else coalesce(A.CRD_CTR_AMT,0)/A.LAST_CTR_AMT end, 2) AS CRD_LAST_CTR_AMT --当前笔合同金额/前一笔
       ,A.INTR_RAT_SPRD         --前一笔执行月利率-当前执行月利率
       ,A.CRD_DTRB_DT           --贷款发放日期
       ,A.MNG_MGR_ID_1          --贷款管护人工号
       ,A.MNG_MGR_NM_1          --贷款管护人姓名
       ,A.MNG_ORG_ID_1          --贷款管护人机构号
       ,A.REG_DT                --贷款申请日期
       ,A.DIFF_TM               --贷款申请与贵金属购买间隔日期
       ,A.DIFF_TM2
       ,A.DBIL_USG              --借据用途
       ,A.CRD_TYP               --贷款类型
       ,A.CRD_MOD_MARK          --贷款利率优惠备注
       ,A.CRD_USG_MARK          --贷款用途备注
       ,A.CRD_MARK              --贷款备注
       ,A.LOAN_RAT_SPRD         --贷款利息差
       ,A.RAT_SPRD_AMT_INC      --利息差-贵金属购买金额
       ,A.RAT_SPRD_MID_INC      --利息差-中收
       ,COALESCE(A.CRD_CTR_AMT,0)-COALESCE(A.LAST_CTR_AMT,0)-COALESCE(A.TRX_AMT,0) loan_diff_gold_amt    --贷款额度差-贵金属购买金额
       ,A.DX_IND                --当前笔是否低息贷款
       ,(CASE WHEN A.DIFF_TM >= 0 AND A.DIFF_TM <= 3  THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15
             AND (A.CRD_MOD_MARK LIKE '%贵金属%' OR A.CRD_USG_MARK LIKE '%贵金属%' OR A.CRD_MARK LIKE '%贵金属%' ) THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND A.LAST_INTR_RAT > 0 AND A.CRD_CTR_AMT * A.TRM_MON * (A.LAST_INTR_RAT - A.INTR_RAT) * 0.001 - A.TRX_AMT >= 0 THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND A.LAST_CTR_AMT  > 0 AND A.CRD_CTR_AMT / A.LAST_CTR_AMT > 1 AND A.CRD_CTR_AMT / A.LAST_CTR_AMT <= 1.2 THEN '是'
            WHEN (A.CST_RSK_GRD IN ('高风险','黑名单') OR A.FIVE_CTG_NM IN ('关注一级', '关注二级', '次级一级', '次级二级', '可疑', '损失')) THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND E.HPN_TYP_CD = '015' THEN '是'
            WHEN A.DIFF_TM >  3 AND A.DIFF_TM <= 15 AND E.BUS_ID     = 'J'   THEN '是'
            ELSE '否' END)      AS IS_BIND   --是否疑似捆绑
FROM TLDATA_DEV.SJXQ_SJ2023120591_CST_10  A --贵金属捆绑销售清单预处理_临时表_10
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD      D --信贷合同信息
ON      A.BUS_CTR_ID = D.BUSI_CTR_ID --合同流水号
AND     D.DT = '@@{yyyyMMdd}'
LEFT JOIN    (
              SELECT  APL_ID       --申请编号
                     ,HPN_TYP_CD   --发生类型代码
                     ,BUS_ID       --业务标识
              FROM    edw.DWD_BUS_LOAN_APL_INF_DD --信贷业务申请信息
              WHERE   DT = '@@{yyyyMMdd}'
              AND     (HPN_TYP_CD = '015' OR BUS_ID = 'J') --发生类型代码  --业务标识
             )                                        E
ON      D.BUSI_APL_ID = E.APL_ID --申请编号
;

--结果表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_12;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023120591_CST_12 AS
SElECT DISTINCT A.SYS_SRL_NBR   序号
    ,A.DATA_SRC        		    数据来源
    ,A.PVD_NM                  商铺名称
    ,A.ORD_ID                  订单号
    ,A.USR_NM                  买家名称
    ,A.CST_ID                  客户号
    ,A.CST_NM                  真实姓名
    ,A.PST_MTH                 邮寄方式
    ,A.TRX_DT                  下单日期
    ,A.PMT_TM                  付款时间
    ,A.PMT_MTH                 支付方式
    ,A.CHNL_NM                 渠道
    ,A.ORD_STS                 订单状态
    ,A.PROD_NM                 商品名称
    ,A.CMDT_SPEC               商品规格
    ,A.QTY                     购买数量
    ,A.GOODS_TYP               商品分类
    ,A.GOODS_RETURN_STATUS     商品退款状态
    ,A.CMDT_UNT_PRC            商品现金单价
    ,A.TRX_AMT                 商品应付现金总额
    ,A.CMSN_TYP                佣金类型
    ,A.MID_INC_RTO             佣金比例_金额
    ,A.MID_INC_TOT_AMT         佣金总额
    ,A.RCM_PSN_ID              推荐人工号
    ,A.RCM_PSN_NM              推荐人姓名
    ,A.RCM_PSN_AFL_DEPT_ID     推荐人所属部门_团队id
    ,A.RCM_PSN_AFL_DEPT        推荐人所属部门_团队
    ,A.RCM_PSN_AFL_SUB_BRN     支行名称
    ,A.RCM_PSN_AFL_BRN         分行名称

    ,B.SAM_RSK_CTRL_ID       同一风险控制号
    ,B.DEPT_CST_NAME         贷款客户名称
    ,B.EFE_LOAN_CST_IND      是否信贷有效户
    ,B.WTHR_INT_EMPE         是否行内员工
    ,B.SAM_RSK_EFE_LOAN_CST  同一风险控制号下是信贷有效户的客户号
    ,B.EFE_DEP_CST_IND       是否存款有效户
    ,B.EFE_CHM_CST_IND       是否理财有效户
    ,B.BUS_CTR_ID            当前笔合同流水号
    ,B.CST_RSK_GRD           申请贷款时客户的信用风险等级
    ,B.FIVE_CTG_NM           当前笔的当前五级分类
    ,B.ZQ_IND               当前笔是否展期贷款
    ,B.ZXT_IND              当前笔是否助兴通
    ,B.CRD_CTR_AMT           当前笔合同金额
    ,c.zx_score_less_650		购买人同一风险控制号下征信分650分以下
    ,c.high_rsk_black_cst       购买人同一风险控制号下在我行为高风险或黑名单客户
    ,c.lst_6m_ovd_amt_2w        购买人同一风险控制号下近6个月逾期2万以上
    ,B.REF_INTR_RAT          当前笔参考月利率
    ,B.INTR_RAT              当前笔执行月利率
    ,B.DEP_LN_ACM_RTO        当前笔合同存贷积数比
    ,B.TRM_MON               当前笔合同期限月
    ,B.LAST_CTR_ID           前一笔贷款合同流水号
    ,B.LAST_CTR_AMT          前一笔贷款合同金额
    ,B.CRD_LAST_CTR_AMT     当前笔合同金额比前一笔
    ,B.LAST_INTR_RAT         前一笔贷款合同执行月利率
    ,B.LAST_TRM_MON          前一笔合同期限月
    ,B.INTR_RAT_SPRD         前一笔执行月利率_当前执行月利率
    ,B.CRD_DTRB_DT           贷款发放日期
    ,B.MNG_MGR_ID_1          贷款管护人工号
    ,B.MNG_MGR_NM_1          贷款管护人姓名
    ,B.MNG_ORG_ID_1          贷款管护人机构号
    ,B.REG_DT                贷款申请日期
    ,B.DIFF_TM2              贷款申请日期_贵金属购买日期
    ,B.DBIL_USG              借据用途
    ,B.CRD_TYP               贷款类型
    ,B.CRD_MOD_MARK          贷款利率优惠备注
    ,B.CRD_USG_MARK          贷款用途备注
    ,B.CRD_MARK              贷款备注
    ,B.LOAN_RAT_SPRD         贷款利息差
    ,B.RAT_SPRD_AMT_INC      利息差_贵金属购买金额
    ,B.RAT_SPRD_MID_INC      利息差_中收
    ,B.loan_diff_gold_amt    当前笔_前一笔贷款额度_贵金属购买金额
    ,B.DX_IND                当前笔是否低息贷款
    ,b.IS_BIND              是否疑似捆绑
FROM TLDATA_DEV.SJXQ_SJ2023120591_CST_01        A
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023120591_CST_11   B
ON A.SYS_SRL_NBR = B.SYS_SRL_NBR
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023120591_CST_05_1   c
ON A.SYS_SRL_NBR = c.SYS_SRL_NBR
ORDER BY A.SYS_SRL_NBR
;

/*
--数据核验
SELECT '1' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_01
union all
SELECT '2' seq,count(1) cnt,count(DISTINCT SAM_RSK_CTRL_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_02
union all
SELECT '3' seq,count(1) cnt,count(DISTINCT SAM_RSK_CTRL_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_03
union all
SELECT '4' seq,count(1) cnt,count(DISTINCT CST_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_04
union all
SELECT '5' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_05
union all
SELECT '6' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_06
union all
SELECT '7' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_07
union all
SELECT '8' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_08
union all
SELECT '9' seq,count(1) cnt,count(DISTINCT EMPE_ID)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_09
union all
SELECT '10' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_10
union all
SELECT '11' seq,count(1) cnt,count(DISTINCT SYS_SRL_NBR)
from TLDATA_DEV.SJXQ_SJ2023120591_CST_11
;

1	19019	19019
2	529183	529183
3	12088	12088
4	30783	30783
5	91737	19019
6	19019	19019
7	1283845	2382
8	1521	1521
9	21966	21966
10	19019	19019
11	19019	19019

*/
**SJ20231206146_code.sql
-- 2023年9月新增的定期理财认购/申购，非货基金认购/申购交易，交易申请确认状态为成功
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_01;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_01 AS
SELECT '定期理财'   bus_type  --业务类型
    -- ,decode(trx_cd,'100200','理财产品购买','100201','理财产品申购') --交易代码
    ,decode(t1.bus_cd,'122','申购','130','认购')   trx_type  --业务代码 交易类型
    ,t1.srl_nbr --流水号
    ,decode(t1.trx_sts_cd,'6','部分确认未全部返回','7','部分确认已全部返回','8','确认成功','S','成功') trx_sts --交易状态
    ,t1.trx_dt
    ,t1.trx_tm
    ,t1.cfm_dt --确认日期
    ,decode(t1.trx_chnl_cd,'v','纵深支付','0','柜台交易','1','网上银行','2','自助查询终端','3','电话银行'
        ,'4','云上厅堂','5','TA发起','6','低柜','7','手机银行','8','质押系统','9','批量发起'
        ,'B','微信银行','G','WEB管理台','Q','直销银行','Z','投融理财','a','贴膜卡','b','薪箐乐'
        ,'c','智能投顾','s','司法对接','T','泰惠收渠道','e','信贷系统','')  trx_chnl --交易渠道
    ,t1.trx_amt --交易金额
    ,t1.cfm_amt --确认金额
    ,t1.trx_lot --交易份额
    ,t1.cfm_lot --确认份额
    ,t1.mgr_id sale_empe_id --销售人员工号
    -- , 销售人员姓名
    -- , brc_org_nm
    -- , sbr_org_nm
    -- ,bnk_act_id 银行账号
    ,t1.tatrx_act_nbr ta交易账号
    ,t1.tacd    --ta代码
    ,t1.pd_cd   --产品代码
    ,t2.pd_nm   --产品名称
    ,CASE WHEN T2.CHM_INV_TYP_CD IN ( '1307' , 'D310' )                                            THEN '现金类'
        WHEN T2.CHM_INV_TYP_CD IN ( '1300' , '1306' , 'D300' )                                     THEN '短债类'
        WHEN T2.CHM_INV_TYP_CD = '1303' AND SUBSTR(T2.PD_CD, 1, 2) = 'CC' AND LENGTH(T2.PD_CD) = 7 THEN '纯固收'
        WHEN T2.CHM_INV_TYP_CD = '1303' AND SUBSTR(T2.PD_CD, 1, 2) = 'CC' AND LENGTH(T2.PD_CD) = 5 THEN '固收+'
        WHEN T2.CHM_INV_TYP_CD = 'D303'                                                            THEN '代销封闭'
        ELSE '' END      prod_type --产品类型
    ,concat('R',t2.rsk_grd)  pd_rsk_grd --产品风险等级
    ,t2.pfm_comp_bas    --业绩比较基准
    ,t2.pd_found_dt     --产品成立日期
    ,t2.pd_val_dt       --产品起息日期
    ,t2.pd_end_dt       --产品结束日期
    ,t1.cst_id          --cst_ID
FROM edw.dwd_bus_chm_trx_cfm_dtl_dd     t1  -- 理财交易确认流水明细
inner join edw.dim_bus_chm_pd_inf_dd    t2
on t1.pd_cd=t2.pd_cd and t2.dt='@@{yyyyMMdd}'
WHERE t1.dt = '@@{yyyyMMdd}'
and t1.trx_dt between '20231101' and '20231130'
--交易代码 ：100200:理财产品购买、100201:理财产品申购、100213:批量购买、100211:组合产品购买、100214:理财产品预约购买、100257:定向申购、100256:定向购买
-- AND t1.trx_cd IN ( '100200' , '100201' )
AND t1.trx_sts_cd IN ('6','7', '8','S' )  -- 交易成功
and t1.bus_cd in ('122','130') -- 130 认购 122 申购
and T2.CHM_INV_TYP_CD IN('1303','D303')  -- 定期
;

-- 客户上一次理财风险评测
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_02 AS
select cst_id
    ,rsk_lvl_cd     lst_rsk_lvl
    ,late_ases_dt   lst_rsk_ases_dt
from (
    select a.cst_id,a.rsk_lvl_cd,a.late_ases_dt
        ,row_number() over(partition by a.cst_id order by late_ases_dt desc) rn
    from edw.dwd_bus_chm_cst_rsk_ases_dd a
    inner join (select distinct cst_ID from TLDATA_DEV.SJXQ_SJ20231206146_CST_01)b on a.cst_ID=b.cst_ID
    where a.dt<='@@{yyyyMMdd}'
    group by a.cst_id,rsk_lvl_cd,late_ases_dt
) a where rn=2
;
-- 客户交易时理财风险评测
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_03 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_03 AS
select T1.srl_nbr,T1.trx_dt
    ,T2.rsk_lvl_cd         trx_rsk_lvl      --客户交易日风险等级
    ,T2.late_ases_dt       trx_rsk_ases_dt  --客户交易日风险测评时间
from tldata_dev.SJXQ_SJ20231206146_CST_01 T1
inner join edw.dwd_bus_chm_cst_rsk_ases_dd T2
on T1.cst_ID=T2.cst_id and T1.trx_dt=T2.dt
where T2.dt between '20231101' and '20231130'
;

--基金交易明细
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_04 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_04 AS
SELECT '非货基金' bus_type
    ,decode(t1.bus_cd,'020','认购','022','申购') trx_type
    ,t1.bus_glo_srl_nbr srl_nbr
    ,decode(trans_status,'S','成功','3','确认成功','4','部分确认成功','0','申请成功') trx_sts
    ,chnl_dt        trx_dt
    ,trx_tm
    ,cfm_dt
    ,C1.cd_val_dscr trx_chnl
    ,t1.apl_amt     trx_amt
    ,cfm_amt                    --确认金额
    ,apl_lot        trx_lot     --交易份额
    ,cfm_lot        cfm_lot     --确认份额
    ,rcm_psn_id     sale_empe_id --销售人员工号
    -- ,trx_act_id     --银行账号
    ,T1.taact_id       --ta交易账号
    ,T1.TA_CD
    ,t1.pd_cd       --产品代码
    ,t2.pd_nm       --产品名称
    ,decode(t2.fnd_typ_cd,'01','股票型','02','债券型','03','混合型','04','货币型','05','其他','06','基金中基金','') prod_type
    ,concat('R',t2.rsk_grd_cd) pd_rsk_grd
    ,t2.pfm_comp_bas    --业绩比较基准
    ,t2.found_dt        --产品成立日期
    ,''                 --产品起息日期
    ,t2.mtu_dt          --产品结束日期
    ,t1.cst_id          --cst_ID
FROM (
    -- edw.dwd_bus_chm_fnd_cst_rqs_srl_dd t1  -- 基金客户资金类交易申请流水
    select busi_code bus_cd
        ,buss_serno bus_glo_srl_nbr
        ,REPLACE(REPLACE(COALESCE(TRIM(SUBSTR(CHANNEL_DATE, 1, 10)), ''), '-', ''), '/', '') chnl_dt
        ,channel_time  trx_tm
        ,REPLACE(REPLACE(COALESCE(TRIM(SUBSTR(ACK_DATE, 1, 10)), ''), '-', ''), '/', '') CFM_DT
        ,CHANNEL_FLAG   CHNL_CD
        ,APP_AMT APL_AMT
        ,APP_VOL APL_LOT
        ,ACK_AMT CFM_AMT
        ,ACK_VOL CFM_LOT
        ,CUST_MANAGER RCM_PSN_ID
        ,TRANS_ACCT_NO TRX_ACT_ID
        ,TA_ACCT_NO TAACT_ID
        ,PROD_CODE PD_CD
        ,CUST_NO CST_ID
        ,TANO TA_CD
        ,trans_status
    from edw.cfin_fund_cust_trans_req_log --基金客户交易流水申请表
    where dt='@@{yyyyMMdd}'
    and busi_code in ('020','022') --  020认购   022申购
    and trans_status in ('S','3','4','0') -- S 成功 3 确认成功 4 部分确认成功 0 申请成功
    and REPLACE(REPLACE(COALESCE(TRIM(SUBSTR(CHANNEL_DATE, 1, 10)), ''), '-', ''), '/', '') between '20231101' and '20231130'
    union all
    select busi_code bus_cd
        ,buss_serno bus_glo_srl_nbr
        ,REPLACE(REPLACE(COALESCE(TRIM(SUBSTR(CHANNEL_DATE, 1, 10)), ''), '-', ''), '/', '') chnl_dt
        ,channel_time
        ,REPLACE(REPLACE(COALESCE(TRIM(SUBSTR(ACK_DATE, 1, 10)), ''), '-', ''), '/', '') CFM_DT
        ,CHANNEL_FLAG CHNL_CD
        ,APP_AMT APL_AMT
        ,APP_VOL APL_LOT
        ,ACK_AMT CFM_AMT
        ,ACK_VOL CFM_LOT
        ,CUST_MANAGER RCM_PSN_ID
        ,TRANS_ACCT_NO TRX_ACT_ID
        ,TA_ACCT_NO TAACT_ID
        ,PROD_CODE PD_CD
        ,CUST_NO CST_ID
        ,TANO TA_CD
        ,trans_status
    from edw.cfin_fund_cust_trans_req_log_h --基金客户交易流水申请历史表
    where dt between '20231101' and '20231130'
    and busi_code in ('020','022') --  020认购   022申购
    and trans_status in ('S','3','4','0') -- S 成功 3 确认成功 4 部分确认成功 0 申请成功
    and REPLACE(REPLACE(COALESCE(TRIM(SUBSTR(CHANNEL_DATE, 1, 10)), ''), '-', ''), '/', '') between '20231101' and '20231130'
) t1 inner join edw.dim_bus_chm_fnd_pd_inf_dd t2
on t1.pd_cd=t2.pd_cd and t2.dt='@@{yyyyMMdd}' and t2.fnd_typ_cd<>'04' -- 非货基金
LEFT JOIN (
    select distinct cd_val,cd_val_dscr
    from edw.dwd_code_library_dd
    where dt='@@{yyyyMMdd}' and tbl_nm=upper('DWD_BUS_DEP_FRZ_INF_DD') and fld_nm=upper('CHNL_CD')
) C1 ON T1.CHNL_CD=C1.cd_val
;

-- 客户上一次基金风险评测
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_05 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_05 AS
select cst_id
    ,rsk_lvl_cd     lst_rsk_lvl
    ,late_ases_dt   lst_rsk_ases_dt
from (
    select a.cst_id,cst_rsk_grd_cd rsk_lvl_cd,ases_dt late_ases_dt,
        row_number() over(partition by a.cst_id order by ases_dt desc) rn
    from edw.dim_bus_chm_fnd_cst_rsk_grd_inf_dd a
    inner join (select distinct cst_ID from TLDATA_DEV.SJXQ_SJ20231206146_CST_04)b on a.cst_ID=b.cst_ID
    where a.dt<='@@{yyyyMMdd}'
    group by a.cst_id,cst_rsk_grd_cd,ases_dt
) a where rn=2
;
-- 客户交易时基金风险评测
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_06 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_06 AS
select a.srl_nbr,a.trx_dt
    ,b.cst_rsk_grd_cd       trx_rsk_lvl     --客户交易日风险等级
    ,b.ases_dt              trx_rsk_ases_dt --客户交易日风险测评时间
from tldata_dev.SJXQ_SJ20231206146_CST_04           a
left join edw.dim_bus_chm_fnd_cst_rsk_grd_inf_dd    b
on a.cst_ID=b.cst_id and a.trx_dt=b.dt
where b.dt between '20231101' and '20231130'
;

--定期理财+基金
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_07 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_07 AS
select T1.*
    ,T4.rsk_lvl_cd,T4.late_ases_dt
    ,T2.lst_rsk_lvl,T2.lst_rsk_ases_dt
    ,T3.trx_rsk_lvl,T3.trx_rsk_ases_dt
from TLDATA_DEV.SJXQ_SJ20231206146_CST_01           T1		--理财交易
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231206146_CST_02      T2      --上次理财风评
ON T1.cst_ID=t2.cst_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231206146_CST_03      T3      --交易时理财风评
ON T1.srl_nbr=t3.srl_nbr and t1.trx_dt=t3.trx_dt
left join edw.dwd_bus_chm_cst_rsk_ases_dd           T4 		--理财风评表
on T1.CST_ID=T4.cst_id and T4.dt='@@{yyyyMMdd}'
union all
select T1.*
    ,T4.cst_rsk_grd_cd,T4.ases_dt
    ,T2.lst_rsk_lvl,T2.lst_rsk_ases_dt
    ,T3.trx_rsk_lvl,T3.trx_rsk_ases_dt
from TLDATA_DEV.SJXQ_SJ20231206146_CST_04           T1      --基金交易
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231206146_CST_05      T2      --上次基金风评
ON T1.cst_ID=t2.cst_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231206146_CST_06      T3      --交易时基金风评
ON T1.srl_nbr=t3.srl_nbr and t1.trx_dt=t3.trx_dt
left join edw.dim_bus_chm_fnd_cst_rsk_grd_inf_dd    T4      --基金风评表
on t1.cst_ID=t4.cst_ID and t4.dt='@@{yyyyMMdd}'
;

--关联其他字段（主表）
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_08 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_08 AS
SElECT T1.*
    ,T2.ta_name --发行机构
    ,DECODE(T3.gdr_cd,'1','男','2','女','') gender
    ,int(('@@{yyyyMMdd}'-t3.bth_dt)/10000)  age
    ,if(T3.fm_ind='1','是','')              is_farm
    ,if(nvl(T3.own_emp_id,'')<>'','是','')  is_empe
    ,T4.cst_chn_nm                          cst_nm
    ,T5.empe_nm                             sale_empe_nm
    ,T6.brc_org_nm
    ,T6.sbr_org_nm
    ,T7.credit_rsk_grd
    ,if(T8.efe_loan_cst_ind='1','是','')    efe_loan_cst_ind
    ,if(T8.efe_dep_cst_ind='1','是','')     efe_dep_cst_ind
    ,T9.aum_avg_360d
    ,T10.aum_bal TRX_aum_bal
    ,t11.trx_ncr_fnd_bal
FROM TLDATA_DEV.SJXQ_SJ20231206146_CST_07   T1
left join edw.finc_tbtainfo                 T2 on t1.tacd=T2.ta_code  and T2.dt='@@{yyyyMMdd}'
left join edw.dim_cst_idv_bas_inf_dd        T3 on T1.cst_ID=T3.cst_id and T3.dt='@@{yyyyMMdd}'
left join edw.dws_cst_bas_inf_dd            T4 on T1.cst_ID=T4.cst_id and T4.dt='@@{yyyyMMdd}'
left join edw.dws_hr_empe_inf_dd            T5 on T1.sale_empe_id=T5.empe_id and T5.dt='@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd    T6 on T5.org_id=T6.org_id and T6.dt='@@{yyyyMMdd}'
left join (
    select cst_id,decode(risk_level,'1','低风险','2','中低风险','3','中风险','4','中高风险','5','高风险') credit_rsk_grd
    from app_rpt.INTER_BATCH_HIGH_RISK_LST_IDV_DLM_ALL
    where dt='@@{yyyyMMdd}'
) T7 on T1.CST_ID=T7.cst_id
left join adm_pub.adm_csm_cbas_ind_inf_dd           T8 on T1.CST_ID=T8.cst_id and T8.dt='@@{yyyyMMdd}'
left join adm_pub.adm_csm_cbus_cst_fin_ast_inf_dd   T9 on T1.CST_ID=T9.cst_id and T9.dt='@@{yyyyMMdd}'
left join adm_pub.adm_csm_cbus_cst_fin_ast_inf_dd   T10
on T1.CST_ID=T10.cst_id and T1.trx_dt=T10.dt and T10.dt between '20231101' and '20231130'
left join (
    SELECT a.cst_id, a.dt, sum(A.TOT_AMT) trx_ncr_fnd_bal
    from edw.dim_bus_chm_fnd_act_lot_dtl_inf_dd a --基金账户份额信息
    inner join edw.dim_bus_chm_fnd_pd_inf_dd c on a.prod_cd = c.pd_cd and c.dt = '@@{yyyyMMdd}'
    WHERE a.dt between '20231101' and '20231130' and C.fnd_typ_cd<>'04' and A.TOT_AMT>0
    group by a.cst_id, a.dt
) t11 on T1.cst_ID=t11.cst_id and T1.trx_dt=t11.dt
;




--同一风险控制号客户
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_09 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_09 AS
select distinct a.cst_ID,trx_dt
    ,nvl(c.cst_id,a.cst_ID)             rel_cst_id
    ,nvl(c.cst_chn_nm,b.cst_chn_nm)     rel_cust_nm
from tldata_dev.SJXQ_SJ20231206146_CST_08 a
left join edw.dws_cst_bas_inf_dd b on a.cst_ID=b.cst_id and b.dt='@@{yyyyMMdd}'
left join edw.dws_cst_bas_inf_dd c on b.sam_rsk_ctrl_id=c.sam_rsk_ctrl_id
and c.dt='@@{yyyyMMdd}' and NVL(c.sam_rsk_ctrl_id,'')<>''
;

-- 前后15天贷款
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_10 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_10 AS
select a.cst_ID,trx_dt
    ,a.rel_cst_id,rel_cust_nm
    ,B.BUSI_CTR_ID                         --合同流水号
    ,B.CTR_AMT                             --合同金额
    ,B.CTR_BAL                             --合同余额
    ,B.TRM_MON                             --期限月
    ,b.stdinr                              --基准利率
    ,c.ref_year_intr_rat                   --参考年利率
    ,B.INTR_RAT                            --执行利率
    ,B.REF_MON_INTR_RAT                    --参考月利率
    ,c.aprv_exe_mon_intr_rat               --执行月利率
    ,C.REG_DT                              --申请日期
    ,G.DTRB_DT                             --发放日期
    ,E.cd_val_dscr                       FIVE_CTG
    ,case D.PREEVALUATERESULT
        when '1010' then '通过'
        when '1020' then '抗辩通过'
        when '1030' then '上诉通过'
        when '2010' then '未通过'
        when '2020' then '抗辩未通过'
        when '2030' then '上诉未通过'
        when '3010' then '待审查岗确认'
        when '3020' then '转客户经理'
        when '3030' then '转中台'
        when '4010' then '申请详情补充'
        when '4020' then '抗辩详情补充'
        when '4030' then '上诉详情补充'
        else D.PREEVALUATERESULT
    end as                                  pre_ases_res
    ,F.CD_VAL_DSCR                          HPN_TYP
    ,B.LOAN_USG_CD                         --贷款用途代码
    ,B.USG_CMT                             --用途备注
    ,nvl(b.intr_rat_adj_cmt,c.intr_rat_adj_cmt) intr_rat_adj_cmt --贷款利率优惠备注
    ,if(b.wfdk_typ in ('1','3'),'是','否') is_wfdk
    ,case
        when b.bus_lab_cd regexp '2021092200000001|2021072900000001|2020051500000003|2020051500000004|2020051500000002|2020041400000002|2020030900000003|2021092200000002|2020051800000005|2020042200000001|2020030900000001' --政策性贷款
        then '是' else '否' end is_zc_loan
    ,CASE SUBSTR(b.PD_CD, 1, 9)
         WHEN '201050101' THEN '1'
         WHEN '201050102' THEN '2'
         WHEN '201040101' THEN '3'
         WHEN '201040102' THEN '4'
         ELSE '5' END              AS PD_CD
    ,B.CMT                                 --备注
    ,B.BUSI_APL_ID                         --业务申请编号
    ,B.DT                                  --合同日期
    ,ABS(DATEDIFF(TO_DATE(C.REG_DT, 'yyyyMMdd'), TO_DATE(A.trx_dt, 'yyyyMMdd'), 'dd')) AS DIFF_TM --贷款申请与交易间隔日期
from tldata_dev.SJXQ_SJ20231206146_CST_09   a
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD    B --信贷合同信息
ON      A.rel_cst_id = B.CST_ID
AND     NVL(B.CST_ID,'') <> ''  --剔除空值和空
AND     B.CRC_IND <> '1'        --剔除循环贷款
--普通贷款:-20105010100 个人消费性贷款 20105010200 个人经营性贷款 20104010100 流动资金贷款 20104010200 固定资产贷款 20104010600 法人购房贷款
AND     SUBSTR(B.PD_CD, 1, 9) IN ( '201050101' , '201050102' , '201040101' , '201040102' , '201040106' )
AND     B.DT = '@@{yyyyMMdd}'
LEFT JOIN edw.DWD_BUS_LOAN_APL_INF_DD       C --信贷业务申请信息
ON      B.BUSI_APL_ID = C.APL_ID    --业务申请编号
AND     NVL(C.APL_ID,'') <> ''      --剔除空值和空
AND     C.DT = '@@{yyyyMMdd}'
left outer join edw.loan_customer_preevaluate_result D -- 预评估最终结果表 // 该表作用基本只提供preevaluateresult
on trim(c.pre_apl_srl_nbr) = trim(D.serialno)
and D.customerrole = '01' -- 角色为借款人
and D.dt = '@@{yyyyMMdd}'
left join edw.dwd_code_library_dd E
on b.FIVE_CTG_CD=E.cd_val
and e.fld_nm=upper('FIVE_CTG_CD')
and e.tbl_nm=upper('DIM_BUS_LOAN_CTR_INF_DD')
AND e.dt='@@{yyyyMMdd}'
LEFT JOIN EDW.DWD_CODE_LIBRARY_DD            F --码值表(发生类型)
ON      C.HPN_TYP_CD = F.CD_VAL                 --发生类型 码值
AND     F.TBL_NM = 'DIM_BUS_LOAN_CTR_INF_DD'     -- DWD_BUS_LOAN_APL_INF_DD 该表码值表错误
AND     F.FLD_NM = 'HPN_TYP_CD'
AND     F.DT = '@@{yyyyMMdd}'
LEFT JOIN (
    SELECT  BUS_CTR_ID ,MIN(DTRB_DT) AS DTRB_DT  --最早发放日期
    FROM edw.DWS_BUS_LOAN_DBIL_INF_DD   --贷款借据信息汇总
    WHERE DT = '@@{yyyyMMdd}'
    GROUP BY BUS_CTR_ID
) G ON B.BUSI_CTR_ID = G.BUS_CTR_ID
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_11 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_11 AS
select cst_ID,trx_dt
    ,a.rel_cst_id
    ,rel_cust_nm
    ,BUSI_CTR_ID                         --合同流水号
    ,CTR_AMT                             --合同金额
    ,stdinr                              --基准利率
    ,ref_year_intr_rat                   --参考年利率
    ,INTR_RAT                            --执行利率
    ,REF_MON_INTR_RAT                    --参考月利率
    ,aprv_exe_mon_intr_rat               --执行月利率
    ,a.REG_DT							 --申请日期
    ,DTRB_DT                             --发放日期
    ,FIVE_CTG
    ,pre_ases_res
    ,HPN_TYP
    ,USG_CMT
    ,intr_rat_adj_cmt
    ,is_wfdk
    ,is_zc_loan
    ,lst_BUSI_CTR_ID
    ,lst_CTR_AMT
    ,lst_INTR_RAT
    ,lst_aprv_exe_mon_intr_rat
    ,lst_REG_DT
    ,lst_DTRB_DT
from (
    select a.*
        ,b.BUSI_CTR_ID            	lst_BUSI_CTR_ID
        ,b.CTR_AMT                  lst_CTR_AMT
        ,b.INTR_RAT                 lst_INTR_RAT
        ,b.aprv_exe_mon_intr_rat    lst_aprv_exe_mon_intr_rat
        ,b.REG_DT                   lst_REG_DT
        ,b.DTRB_DT                  lst_DTRB_DT
        ,row_number() over(partition by a.cst_ID,a.trx_dt order by b.REG_DT desc) rn2
    from (
        select *,row_number() over(partition by cst_ID,trx_dt order by DIFF_TM asc) rn
        from tldata_dev.SJXQ_SJ20231206146_CST_10
        where DIFF_TM<=15
    ) a
    left join tldata_dev.SJXQ_SJ20231206146_CST_10 b on a.cst_ID=b.cst_ID and a.trx_dt=b.trx_dt
        and a.pd_cd=b.pd_cd and a.REG_DT>b.REG_DT
    where a.rn=1
) a
where rn2=1;


DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_12 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231206146_CST_12 AS
select a.bus_type              业务类型
    ,a.trx_type                交易类型
    ,a.srl_nbr                 交易流水号
    ,a.trx_sts                 交易状态
    ,concat(a.trx_dt,' ',a.trx_tm) 申请日期
    ,a.cfm_dt                  确认日期
    ,a.trx_chnl                交易渠道
    ,a.trx_amt                 交易金额
    ,a.cfm_amt                 确认金额
    ,a.trx_lot                 交易份额
    ,a.cfm_lot                 确认份额
    ,a.sale_empe_id            销售人员工号
    ,a.sale_empe_nm            销售人员姓名
    ,a.brc_org_nm              所属分行
    ,a.sbr_org_nm              所属支行
    ,a.ta交易账号           交易账号
    ,a.pd_cd                   产品代码
    ,a.pd_nm                   产品名称
    ,a.ta_name                 发行机构
    ,a.prod_type               产品类型
    ,a.pd_rsk_grd              产品风险等级
    ,a.pfm_comp_bas            业绩比较基准
    ,a.pd_found_dt             产品扣款日
    ,a.pd_val_dt               产品起息日
    ,a.pd_end_dt               产品到期日
    ,a.CST_ID                  客户号
    ,a.cst_nm                  客户名称
    ,a.age                     客户年龄
    ,a.gender                  客户性别
    ,''                        客户手机号码
    ,a.rsk_lvl_cd                                           	客户当前风险测评结果
    ,decode(a.late_ases_dt,'18991231','',a.late_ases_dt)    	客户当前结果测评时间
    ,a.lst_rsk_lvl                                          	客户上一次风险测评结果
    ,decode(a.lst_rsk_ases_dt,'18991231','',a.lst_rsk_ases_dt)  客户上一次风险测评时间
    ,a.trx_rsk_lvl                                              客户交易日风险等级
    ,decode(a.trx_rsk_ases_dt,'18991231','',a.trx_rsk_ases_dt)  客户交易日风险测评时间
    ,a.is_farm								是否农户
    ,a.efe_loan_cst_ind                     是否信贷有效户
    ,a.efe_dep_cst_ind                      是否存款有效户
    ,a.is_empe                              是否行内员工
    ,a.aum_avg_360d                         客户近一年AUM
    ,a.trx_ncr_fnd_bal                      客户交易时非货基金保有量
    ,a.TRX_aum_bal                          客户交易时AUM
    ,if(b.cst_ID is not null,'是','') 		交易日前后15天内同一风险控制号下是否存在贷款
    ,b.rel_cust_nm                  		贷款客户名称
    ,c.loan_apl_credit_rsk_grd      		当前贷款申请时客户信用风险等级
    ,a.credit_rsk_grd               		当前客户信用风险等级
    ,b.BUSI_CTR_ID                   		当前笔贷款合同流水号
    ,b.reg_dt                       		当前笔贷款申请日期
    ,b.DTRB_DT                      		当前笔贷款发放日期
    ,b.CTR_AMT                      		当前笔贷款金额
    ,ref_year_intr_rat              		当前笔贷款参考年利率
    ,INTR_RAT                       		当前笔贷款执行年利率
    ,aprv_exe_mon_intr_rat          		当前笔贷款执行月利率
    ,b.pre_ases_res                 		当前笔贷款预审批结果
    ,b.FIVE_CTG                     		当前笔贷款五级分类
    ,b.HPN_TYP                      		贷款类型
    ,b.is_zc_loan                   		是否为政策性贷款
    ,b.is_wfdk                      		是否为接力贷
    ,b.intr_rat_adj_cmt             		贷款利率优惠备注
    ,b.USG_CMT                      		贷款用途备注
    ,b.lst_BUSI_CTR_ID              		上一笔贷款合同流水号
    ,b.lst_CTR_AMT                  		上一笔贷款合同金额
    ,b.lst_INTR_RAT                 		上一笔贷款执行年利率
    ,b.lst_aprv_exe_mon_intr_rat    		上一笔贷款执行月利率
    ,b.lst_DTRB_DT                   		上一笔贷款发放日期
from TLDATA_DEV.SJXQ_SJ20231206146_CST_08       a
left join tldata_dev.SJXQ_SJ20231206146_CST_11  b
on a.cst_ID=b.cst_ID and a.trx_dt=b.trx_dt
left join (
    select distinct dt,cst_id,decode(risk_level,'1','低风险','2','中低风险','3','中风险','4','中高风险','5','高风险') loan_apl_credit_rsk_grd
    from app_rpt.INTER_BATCH_HIGH_RISK_LST_IDV_DLM_ALL
    where dt<='@@{yyyyMMdd}'
) c on b.rel_cst_id=c.cst_id and b.reg_dt=c.dt
;


/*
SElECT '01' seq,count(1) cnt,count(DISTINCT cst_id,trx_dt) CST_TRX_CNT,COUNT(DISTINCT srl_nbr) SRL_NBR
from TLDATA_DEV.SJXQ_SJ20231206146_CST_01
union all
SElECT '04' seq,count(1) cnt,count(DISTINCT cst_id,trx_dt) CST_TRX_CNT,COUNT(DISTINCT srl_nbr) SRL_NBR
from TLDATA_DEV.SJXQ_SJ20231206146_CST_04
union all
SElECT '07' seq,count(1) cnt,count(DISTINCT cst_id,trx_dt) CST_TRX_CNT,COUNT(DISTINCT srl_nbr) SRL_NBR
from TLDATA_DEV.SJXQ_SJ20231206146_CST_07
union all
SElECT '08' seq,count(1) cnt,count(DISTINCT cst_id,trx_dt) CST_TRX_CNT,COUNT(DISTINCT srl_nbr) SRL_NBR
from TLDATA_DEV.SJXQ_SJ20231206146_CST_08
;
01	6213	5942	6213
04	1736	1541	1736
07	7949	7469	7949
08	7954	7469	7949

SElECT '02' seq,count(1) cnt,count(DISTINCT cst_id)
from TLDATA_DEV.SJXQ_SJ20231206146_CST_02
union all
SElECT '03' seq,count(1) cnt,count(DISTINCT srl_nbr)
from TLDATA_DEV.SJXQ_SJ20231206146_CST_03
union all
SElECT '05' seq,count(1) cnt,count(DISTINCT cst_id)
from TLDATA_DEV.SJXQ_SJ20231206146_CST_05
union all
SElECT '06' seq,count(1) cnt,count(DISTINCT srl_nbr)
from TLDATA_DEV.SJXQ_SJ20231206146_CST_06
;
02	3722	3722
03	6213	6213
05	149	149
06	1736	1736

*/
**SJ20231213111_保险明细.sql
/*
泰隆保单号	出生日期	保险期间	首期保费	账户	管户人工号	管户人姓名	管户人所在分行

1. 出生日期：投保人
2. 保险期间：生效日期
3. 账户是 客户账号
4. 管户人存在多人考核，聚合展示
*/
--保险明细
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_01 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_01 AS
SElECT T1.insu_plcy_id       --保单号|C30
    ,T1.mgr                --客户经理|C32
    ,T1.cst_id             --客户编号|C24
    ,T1.eft_dt             --生效日期|C16
    ,T2.insu_hld_bth_dt
    ,T2.cst_act_nbr
    ,T2.frs_trm_insu_fee
    ,T2.mng_cnv_insu_fee
    ,T2.mng_mgr_id
    ,T2.mng_mgr_nm
    ,T2.brc_org_nm
FROM edw.dwd_bus_insu_plcy_insu_inf_dd  T1 --保险保单投保信息 insu_plcy_id 保单号
LEFT JOIN(
    SElECT T1.insu_plcy_id
        ,CONCAT_WS('|', COLLECT_SET(T1.insu_hld_bth_dt))   insu_hld_bth_dt     --投保人出生日期
        ,CONCAT_WS('|', COLLECT_SET(T1.cst_act_nbr))       cst_act_nbr         --客户账号
        ,AVG(T1.frs_trm_insu_fee)                          frs_trm_insu_fee
        ,sum(T1.mng_cnv_insu_fee)                          mng_cnv_insu_fee    --管护折算保费
        ,CONCAT_WS('|', COLLECT_SET(T1.mng_mgr_id))        mng_mgr_id          --管护客户经理工号
        ,CONCAT_WS('|', COLLECT_SET(T1.mng_mgr_nm))        mng_mgr_nm          --管护客户经理姓名
        ,CONCAT_WS('|', COLLECT_SET(T2.brc_org_nm))        brc_org_nm          --管护分行
    FROM app_rpt.fct_insu_agn_bus_acs_dtl_tbl   T1 --保险代销业务考核明细表 insu_plcy_id
    LEFT JOIN edw.dim_hr_org_mng_org_tree_dd    T2
    on T1.MNG_ORG_ID = T2.ORG_ID AND T2.DT = '@@{yyyyMMdd}'
    WHERE T1.dt = '@@{yyyyMMdd}'
    GROUP BY T1.insu_plcy_id
)T2 ON T1.insu_plcy_id = T2.insu_plcy_id
WHERE T1.dt = '@@{yyyyMMdd}'
;


--汇总
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_02 AS
SElECT T1.SEQ,T1.insu_plcy_id
	,T2.insu_hld_bth_dt
	,T2.eft_dt
	,T2.frs_trm_insu_fee
	,T2.cst_act_nbr
	,T2.mng_mgr_id
	,T2.mng_mgr_nm
	,T2.brc_org_nm
FROM qbi_file_20231215_14_25_38 T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231213111_CST_01  T2
ON T1.insu_plcy_id=T2.insu_plcy_id
WHERE T1.PT = MAX_PT('qbi_file_20231215_14_25_38')
;

--输出结果
select cast(SEQ as int)	 序号
    ,insu_plcy_id		 保单号
    ,insu_hld_bth_dt     投保人出生日期
    ,eft_dt              生效日期
    ,frs_trm_insu_fee    首期保费
    ,cst_act_nbr         客户账号
    ,mng_mgr_id          管户人工号
    ,mng_mgr_nm          管户人姓名
    ,brc_org_nm          管户人所在分行
FROM TLDATA_DEV.SJXQ_SJ20231213111_CST_02
ORDER BY SEQ
;

**SJ20231213111_保险明细2.sql

--保险明细
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_01 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_01 AS
SElECT T1.insu_plcy_id       --保单号|C30
    ,T1.mgr                 --客户经理|C32
    ,T1.cst_id              --客户编号|C24
    ,T1.eft_dt              --生效日期|C16
    ,T1.bz_year_prd         --保障年期
    ,T2.insu_hld_bth_dt
    ,T2.cst_act_nbr
    ,T2.frs_trm_insu_fee
    ,T2.mng_cnv_insu_fee
    ,T2.mng_mgr_id
    ,T2.mng_mgr_nm
    ,T2.brc_org_nm
FROM edw.dwd_bus_insu_plcy_insu_inf_dd  T1 --保险保单投保信息 insu_plcy_id 保单号
LEFT JOIN(
    SElECT T1.insu_plcy_id
        ,CONCAT_WS('|', COLLECT_SET(T1.insu_hld_bth_dt))   insu_hld_bth_dt     --投保人出生日期
        ,CONCAT_WS('|', COLLECT_SET(T1.cst_act_nbr))       cst_act_nbr         --客户账号
        ,AVG(T1.frs_trm_insu_fee)                          frs_trm_insu_fee
        ,sum(T1.mng_cnv_insu_fee)                          mng_cnv_insu_fee    --管护折算保费
        ,CONCAT_WS('|', COLLECT_SET(T1.mng_mgr_id))        mng_mgr_id          --管护客户经理工号
        ,CONCAT_WS('|', COLLECT_SET(T1.mng_mgr_nm))        mng_mgr_nm          --管护客户经理姓名
        ,CONCAT_WS('|', COLLECT_SET(T2.brc_org_nm))        brc_org_nm          --管护分行
    FROM app_rpt.fct_insu_agn_bus_acs_dtl_tbl   T1 --保险代销业务考核明细表 insu_plcy_id
    LEFT JOIN edw.dim_hr_org_mng_org_tree_dd    T2
    on T1.MNG_ORG_ID = T2.ORG_ID AND T2.DT = '@@{yyyyMMdd}'
    WHERE T1.dt = '@@{yyyyMMdd}'
    GROUP BY T1.insu_plcy_id
)T2 ON T1.insu_plcy_id = T2.insu_plcy_id
WHERE T1.dt = '@@{yyyyMMdd}'
;

--输出结果
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231213111_CST_02 AS
SElECT cast(T1.seq as int)	序号
	,T1.col_2           	分公司
	,T1.col_3           	中支
    ,t2.cst_ID              客户号
	,T1.col_4           	保单号
	,T1.insu_plcy_id    	泰隆保单号
	,T1.col_6           	承保日期
	,T2.insu_hld_bth_dt 	投保人出生日期
	,T1.col_7           	生效日期
	,T1.col_8           	回执日期
    ,T2.bz_year_prd         保障年期
    ,T2.frs_trm_insu_fee 	首期保费
    ,T2.cst_act_nbr      	客户账号
    ,T2.mng_mgr_id       	管户人工号
    ,T2.mng_mgr_nm       	管户人姓名
    ,T2.brc_org_nm       	管户人所在分行
	,T1.col_9           	产品名称
	,T1.col_10          	银保工号
	,T1.col_11          	银行网点
	,T1.col_12          	合作渠道
	,T1.col_13          	代理人姓名
	,T1.col_14          	入司时间
	,T1.col_15          	离司时间
	,T1.col_16          	职级
	,T1.col_17          	是否为长险
	,T1.col_18          	大个险保费
	,T1.col_19          	FYC
	,T1.col_20          	年
	,T1.col_21          	月
	,T1.col_22          	缴费频率
	,T1.col_23          	缴费次数
	,T1.col_24          	保额
	,T1.col_25          	保单状态
	,T1.col_26          	状态日期
	,T1.col_27          	是否已有继续率
FROM qbi_file_20231215_14_25_38                 T1
LEFT JOIN TLDATA_DEV.SJXQ_SJ20231213111_CST_01  T2
ON T1.insu_plcy_id=T2.insu_plcy_id
WHERE T1.PT = MAX_PT('qbi_file_20231215_14_25_38')
ORDER BY T1.SEQ
;




































**SJ2023121456_理财基金风评不一客户.sql
/*
数据日期:截至数据提取日(请在下周二即19号当天拉取)
数据范围:全行同时完成了基金签约(包含财富宝签约或基金代销签约)和理财签约的客户
取数口径:理财风评结果和基金风评结果不一致的客户
*/
--理财风评
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_01 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_01 AS
SELECT *
FROM(--'1','保守型','2','稳健型','3','平衡型','4','进取型','5','激进型'
    select a.cst_id
        ,a.rsk_lvl_cd          --风险等级代码|decimal
        ,a.rsk_vld_prd_stop_dt --风险有效期截止日期|decimal
        ,a.late_ases_dt        --最后评估日期|decimal
        ,row_number() over(partition by a.cst_id order by a.late_ases_dt desc) rn
    from edw.dwd_bus_chm_cst_rsk_ases_dd a
    where a.dt<='@@{yyyyMMdd}'
    group by a.cst_id,a.rsk_lvl_cd,a.rsk_vld_prd_stop_dt,a.late_ases_dt
)A WHERE RN=1
;

--基金风评
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_02 AS
SELECT *
FROM(--'1','低','2','中低','3','中','4','中高','5','高'
    select a.cst_id
        ,a.cst_rsk_grd_cd	        --客户风险等级代码|C1
        ,a.ases_dt	                --评估日期|C8
        ,a.nvld_dt	                --失效日期|C8
        ,a.last_ases_dt             --上次评估日期|C8
        ,row_number() over(partition by a.cst_id order by a.ases_dt desc) rn
    from edw.dim_bus_chm_fnd_cst_rsk_grd_inf_dd a
    where a.dt<='@@{yyyyMMdd}'
    group by a.cst_id,a.cst_rsk_grd_cd,a.ases_dt,a.nvld_dt,a.last_ases_dt
)A WHERE RN=1
;

--汇总
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_03 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_03 AS
SELECT T1.cst_id
    ,T1.ctr_sts_cd                          --签约状态代码|c1
    ,T1.frs_ctr_dt         FUD_SGN_DT       --首次签约日期|c8
    ,T1.late_cncl_ctr_dt   FUD_OVD_DT       --最后解约日期|c8
    ,T1.cst_nm                              --客户名称|c128
    ,T2.chm_cst_id                          --理财客户编号|C32
    ,T2.ctr_dt             FINC_SGN_DT      --签约日期|C8
    ,T2.cncl_ctr_dt        FINC_OVD_DT      --解约日期|C8
    ,T3.rsk_lvl_cd,T3.late_ases_dt,T3.rsk_vld_prd_stop_dt
    ,T4.cst_rsk_grd_cd,T4.ases_dt,T4.nvld_dt
FROM edw.dim_bus_chm_fnd_cst_ctr_inf_dd         T1 --基金客户签约信息表
INNER JOIN edw.dwd_bus_chm_ctr_inf_dd           T2 --理财客户签约信息
ON  T1.CST_ID=T2.CST_ID
AND T2.dt='@@{yyyyMMdd}'
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023121456_CST_01   T3 --理财风评
ON  T1.CST_ID=T3.CST_ID
LEFT JOIN TLDATA_DEV.SJXQ_SJ2023121456_CST_02   T4 --基金风评
ON  T1.CST_ID=T4.CST_ID
where T1.dt='@@{yyyyMMdd}'
;

--输出结果 1535
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_04 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121456_CST_04 AS
SELECT CST_ID				客户号
    ,cst_nm                 客户名称
    ,rsk_lvl_cd             理财客户风险等级
    ,late_ases_dt           理财评估日期
    ,rsk_vld_prd_stop_dt    理财风评结果有效截止日期
    ,cst_rsk_grd_cd         基金客户风险等级
    ,ases_dt                基金评估日期
    ,nvld_dt                基金风评结果失效日期
FROM TLDATA_DEV.SJXQ_SJ2023121456_CST_03
WHERE rsk_lvl_cd<>cst_rsk_grd_cd
;


/*
SElECT '01' seq,count(1) cnt,count(DISTINCT cst_id)
from TLDATA_DEV.SJXQ_SJ2023121456_CST_01
union all
SElECT '02' seq,count(1) cnt,count(DISTINCT cst_id)
from TLDATA_DEV.SJXQ_SJ2023121456_CST_02
union all
SElECT '03' seq,count(1) cnt,count(DISTINCT cst_id)
from TLDATA_DEV.SJXQ_SJ2023121456_CST_03
union all
SElECT '04' seq,count(1) cnt,count(DISTINCT 客户号)
from TLDATA_DEV.SJXQ_SJ2023121456_CST_04
;
01	465038	465038
02	95170	95170
03	358259	358259 约30万基金签约但未进行风险评估
04	1535	1535
*/




**SJ2023121566-购买封闭式理财客户清单.sql
/*
12月11日-18日，台州分行购买封闭式理财且成立的客户清单。
 (封闭式理财包括三年期一份期权\三年期两份期权、五年期一份期权和五年期两份期权;
 其他钱潮系列1号理财、小雪球和交银稳享灵动慧利6个月封闭式。

买入时间、客户号、客户姓名、产品名称、产品代码、确认金额
支行机构号、支行机构名称、部门机构号、部门机构名称、管护人工号、管护人姓名
对公客户(法定代表人客户号) 销售人工号、销售人姓名、客户手机号
*/

--理财销售明细
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_01 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_01 AS
select t1.cst_ID,t1.PD_CD,t1.trx_dt,t1.trx_tm,t1.CFM_AMT
    ,t1.mgr_id sale_empe_id
    ,t2.pd_nm
    ,T3.empe_nm sale_empe_nm
    ,t3.org_id
from edw.dwd_bus_chm_trx_cfm_dtl_dd         t1  --只有近7天分区 cst_id,pd_cd,trx_dt,trx_tm 不唯一
inner join edw.dim_bus_chm_pd_inf_dd 	    t2  --理财产品信息
on t1.pd_cd=t2.pd_cd
and t2.dt='20231219'
and t2.pd_ctg_cd='1' --理财
and t2.pd_found_dt>='20231211'
LEFT JOIN edw.dws_hr_empe_inf_dd            T3  --员工信息汇总 27748 empe_id 唯一
ON  T1.mgr_id = T3.empe_id --销售人员
AND T3.DT='20231219'
WHERE t1.dt = '20231219'
and t1.trx_dt between '20231211' and '20231219'
AND t1.trx_sts_cd IN ('6','7', '8','S' )  -- 交易成功
AND t1.bus_cd in ('122','130') -- 130 认购 122 申购
;

--账户管户
/*
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 AS
SELECT t1.cst_ID
    ,CONCAT_WS('|', COLLECT_SET(t1.mgr_id))    mng_mgr_id        --去重合并
    ,CONCAT_WS('|', COLLECT_SET(t5.empe_nm))   mng_mgr_nm
from edw.dim_bus_chm_act_inf_dd             t1  --理财账户信息
LEFT JOIN edw.dws_hr_empe_inf_dd            T5  --员工信息汇总 27748 empe_id 唯一
ON T1.mgr_id = T5.empe_id
AND T5.DT='20231219'
where t1.dt='20231219'
group by t1.cst_ID
;*/
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 AS
SELECT t1.cst_ID
    ,CONCAT_WS('|', COLLECT_SET(t1.mgr_id))    mng_mgr_id
    ,CONCAT_WS('|', COLLECT_SET(t5.empe_nm))   mng_mgr_nm        --账户管户人
    ,CONCAT_WS('|', COLLECT_SET(cast(t1.mgr_rto as string)))   mgr_rto
    ,CONCAT_WS('|', COLLECT_SET(t1.acs_org_id)) acs_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.brc_org_nm)) brc_org_nm
    ,CONCAT_WS('|', COLLECT_SET(t4.sbr_org_id)) sbr_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.sbr_org_nm)) sbr_org_nm
    ,CONCAT_WS('|', COLLECT_SET(t4.tem_org_id)) tem_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.tem_org_nm)) tem_org_nm
from edw.dwd_bus_dep_cst_act_mgr_inf_dd         t1  --客户存款账户管护信息
inner join (select distinct cst_ID from TLDATA_DEV.SJXQ_SJ2023121566_CST_01)t2 on t1.cst_id = t2.cst_id
inner join(
    select distinct cst_id,ori_trx_act_id   --签约理财对应的存款账户管户信息
    from edw.dwd_bus_chm_trx_cfm_dtl_di
    where dt>='20231211' and TRX_DT>='20231211'
)t3 on t1.cst_act_id = t3.ori_trx_act_id
and t1.cst_id=t3.cst_id
INNER join edw.dim_hr_org_mng_org_tree_dd       t4   --考核机构树 4481 org_id 唯一?
on  t1.acs_org_id = t4.org_id
and t4.dt = '20231219'
and t4.BRC_ORG_NM='台州分行'
LEFT JOIN edw.dws_hr_empe_inf_dd                T5  --员工信息汇总 27748 empe_id 唯一
ON T1.mgr_id = T5.empe_id
AND T5.DT='20231219'
where t1.dt='20231219'
group by t1.cst_ID
;


DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_03 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_03 AS
SElECT t1.cst_id,t1.mng_mgr_id,t1.mng_mgr_nm,t1.mgr_rto
    ,t1.acs_org_id
    ,t1.brc_org_nm
    ,t1.sbr_org_id
    ,t1.sbr_org_nm
    ,t1.tem_org_id
    ,t1.tem_org_nm
    ,t2.PD_CD,t2.pd_nm,t2.trx_dt,t2.trx_tm,t2.CFM_AMT
    ,t2.sale_empe_id,t2.sale_empe_nm
    ,t3.cst_chn_nm,t3.m_tel_no
    ,t4.brc_org_nm  sale_brc_org_nm
    ,t4.sbr_org_id  sale_sbr_org_id
    ,t4.sbr_org_nm  sale_sbr_org_nm
    ,t4.tem_org_id  sale_tem_org_id
    ,t4.tem_org_nm  sale_tem_org_nm
    ,t5.lgp_cst_id,t5.lgp_nm
from TLDATA_DEV.SJXQ_SJ2023121566_CST_02        t1
left join TLDATA_DEV.SJXQ_SJ2023121566_CST_01   t2
on t1.cst_id=t2.cst_id
left join adm_pub.adm_csm_cbas_idv_bas_inf_dd   t3
on t1.cst_ID=t3.cst_ID
and t3.dt='20231219'
LEFT join  edw.dim_hr_org_mng_org_tree_dd       t4  --考核机构树 4481 org_id 唯一
on  t2.org_id = t4.org_id --销售人员所在机构
and t4.dt = '20231219'
left join edw.dim_cst_entp_lgp_inf_dd           t5  --对公客户法人信息表 （主键为cst_id 对公客户）
on t1.cst_ID=t5.cst_ID
and t5.dt = '20231219'
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_04 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_04 AS
SElECT cst_ID						客户号
    ,cst_chn_nm                     客户姓名
    ,m_tel_no                       客户手机号
    ,pd_nm                          产品名称
    ,PD_CD                          产品代码
    ,concat(trx_dt,' ',trx_tm)      买入时间
    ,CFM_AMT                        确认金额
    ,sale_empe_id                   销售人工号
    ,sale_empe_nm                   销售人姓名
    ,sale_brc_org_nm                销售分行机构名称
    ,sale_sbr_org_id                销售支行机构号
    ,sale_sbr_org_nm                销售支行机构名称
    ,sale_tem_org_id                销售团队机构号
    ,sale_tem_org_nm                销售团队机构名称
    ,mng_mgr_id                     账户管护人工号
    ,mng_mgr_nm                     账户管护人姓名
    ,mgr_rto                        账户管户比例
    ,brc_org_nm                     考核分行机构名称
    ,sbr_org_id                     考核支行机构号
    ,sbr_org_nm                     考核支行机构名称
    ,tem_org_id                     考核团队机构号
    ,tem_org_nm                     考核团队机构名称
    ,lgp_cst_id                     对公法人客户号
    ,lgp_nm                         对公法人客户名称
FROM TLDATA_DEV.SJXQ_SJ2023121566_CST_03
;

/*
SElECT '1' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_01
union all
SElECT '11' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_01_1
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_02
union all
SElECT '3' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_03
union all
SElECT '4' seq,count(1) cnt,count(DISTINCT 客户号) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_04
;

1	892	827
2	275	275
3	296	275
4	296	275
*/
**SJ2023121566-购买封闭式理财客户清单2.sql
/*
12月11日-18日，台州分行购买封闭式理财且成立的客户清单。
 (封闭式理财包括三年期一份期权\三年期两份期权、五年期一份期权和五年期两份期权;
 其他钱潮系列1号理财、小雪球和交银稳享灵动慧利6个月封闭式。

买入时间、客户号、客户姓名、产品名称、产品代码、确认金额
支行机构号、支行机构名称、部门机构号、部门机构名称、管护人工号、管护人姓名
对公客户(法定代表人客户号) 销售人工号、销售人姓名、客户手机号
*/

--理财销售明细
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_01_1 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_01_1 AS
select t1.cst_ID,t1.PD_CD,t1.trx_dt,t1.trx_tm,t1.CFM_AMT
    ,t1.mgr_id sale_empe_id,t1.ori_trx_act_id --客户账号
    ,t2.pd_nm
    ,T3.empe_nm sale_empe_nm
    ,t3.org_id
from edw.dwd_bus_chm_trx_cfm_dtl_di         t1  --只有近7天分区 cst_id,pd_cd,trx_dt,trx_tm 不唯一
inner join edw.dim_bus_chm_pd_inf_dd 	    t2  --理财产品信息
on t1.pd_cd=t2.pd_cd
and t2.dt='20231219'
and t2.pd_ctg_cd='1' --理财
and t2.pd_found_dt>='20231211'
LEFT JOIN edw.dws_hr_empe_inf_dd            T3  --员工信息汇总 27748 empe_id 唯一
ON  T1.mgr_id = T3.empe_id --销售人员
AND T3.DT='20231219'
WHERE t1.dt >= '20231211'
and t1.trx_dt between '20231211' and '20231219'
AND t1.trx_sts_cd IN ('6','7', '8','S' )  -- 交易成功
AND t1.bus_cd in ('122','130') -- 130 认购 122 申购
;


--账户管户
/*
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 AS
SELECT t1.cst_ID
    ,CONCAT_WS('|', COLLECT_SET(t1.mgr_id))    mng_mgr_id        --去重合并
    ,CONCAT_WS('|', COLLECT_SET(t5.empe_nm))   mng_mgr_nm
from edw.dim_bus_chm_act_inf_dd             t1  --理财账户信息
LEFT JOIN edw.dws_hr_empe_inf_dd            T5  --员工信息汇总 27748 empe_id 唯一
ON T1.mgr_id = T5.empe_id
AND T5.DT='20231219'
where t1.dt='20231219'
group by t1.cst_ID
;*/
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_02 AS
SELECT t1.cst_ID,t1.cst_act_id
    ,CONCAT_WS('|', COLLECT_SET(t1.mgr_id))    mng_mgr_id
    ,CONCAT_WS('|', COLLECT_SET(t5.empe_nm))   mng_mgr_nm        --账户管户人
    ,CONCAT_WS('|', COLLECT_SET(cast(t1.mgr_rto as string)))   mgr_rto
    ,CONCAT_WS('|', COLLECT_SET(t1.acs_org_id)) acs_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.brc_org_nm)) brc_org_nm
    ,CONCAT_WS('|', COLLECT_SET(t4.sbr_org_id)) sbr_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.sbr_org_nm)) sbr_org_nm
    ,CONCAT_WS('|', COLLECT_SET(t4.tem_org_id)) tem_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.tem_org_nm)) tem_org_nm
from edw.dwd_bus_dep_cst_act_mgr_inf_dd         t1  --客户存款账户管护信息
inner join (select distinct cst_ID,ori_trx_act_id from TLDATA_DEV.SJXQ_SJ2023121566_CST_01_1)t2
on t1.cst_id = t2.cst_id
and t1.cst_act_id = t2.ori_trx_act_id
INNER join edw.dim_hr_org_mng_org_tree_dd       t4   --考核机构树 4481 org_id 唯一
on  t1.acs_org_id = t4.org_id
and t4.dt = '20231219'
and t4.BRC_ORG_NM='台州分行'
LEFT JOIN edw.dws_hr_empe_inf_dd                T5  --员工信息汇总 27748 empe_id 唯一
ON T1.mgr_id = T5.empe_id
AND T5.DT='20231219'
where t1.dt='20231219'
group by t1.cst_ID,t1.cst_act_id
;


DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_03 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_03 AS
SElECT t1.cst_id,t1.cst_act_id
    ,t1.mng_mgr_id,t1.mng_mgr_nm,t1.mgr_rto
    ,t1.acs_org_id
    ,t1.brc_org_nm
    ,t1.sbr_org_id
    ,t1.sbr_org_nm
    ,t1.tem_org_id
    ,t1.tem_org_nm
    ,t2.PD_CD,t2.pd_nm,t2.trx_dt,t2.trx_tm,t2.CFM_AMT
    ,t2.sale_empe_id,t2.sale_empe_nm
    ,t3.cst_chn_nm,t3.m_tel_no
    ,t4.brc_org_nm  sale_brc_org_nm
    ,t4.sbr_org_id  sale_sbr_org_id
    ,t4.sbr_org_nm  sale_sbr_org_nm
    ,t4.tem_org_id  sale_tem_org_id
    ,t4.tem_org_nm  sale_tem_org_nm
    ,t5.lgp_cst_id,t5.lgp_nm
from TLDATA_DEV.SJXQ_SJ2023121566_CST_02        t1
left join TLDATA_DEV.SJXQ_SJ2023121566_CST_01_1   t2
on t1.cst_id=t2.cst_id
and t1.cst_act_id=t2.ori_trx_act_id
left join adm_pub.adm_csm_cbas_idv_bas_inf_dd   t3
on t1.cst_ID=t3.cst_ID
and t3.dt='20231219'
LEFT join  edw.dim_hr_org_mng_org_tree_dd       t4  --考核机构树 4481 org_id 唯一
on  t2.org_id = t4.org_id --销售人员所在机构
and t4.dt = '20231219'
left join edw.dim_cst_entp_lgp_inf_dd           t5  --对公客户法人信息表 （主键为cst_id 对公客户）
on t1.cst_ID=t5.cst_ID
and t5.dt = '20231219'
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_04 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121566_CST_04 AS
SElECT cst_ID						客户号
    ,cst_chn_nm                     客户姓名
    ,m_tel_no                       客户手机号
    ,pd_nm                          产品名称
    ,PD_CD                          产品代码
    ,concat(trx_dt,' ',trx_tm)      买入时间
    ,CFM_AMT                        确认金额
    ,sale_empe_id                   销售人工号
    ,sale_empe_nm                   销售人姓名
    ,sale_brc_org_nm                销售分行机构名称
    ,sale_sbr_org_id                销售支行机构号
    ,sale_sbr_org_nm                销售支行机构名称
    ,sale_tem_org_id                销售团队机构号
    ,sale_tem_org_nm                销售团队机构名称
    ,mng_mgr_id                     账户管护人工号
    ,mng_mgr_nm                     账户管护人姓名
    ,mgr_rto                        账户管户比例
    ,brc_org_nm                     考核分行机构名称
    ,sbr_org_id                     考核支行机构号
    ,sbr_org_nm                     考核支行机构名称
    ,tem_org_id                     考核团队机构号
    ,tem_org_nm                     考核团队机构名称
    ,lgp_cst_id                     对公法人客户号
    ,lgp_nm                         对公法人客户名称
FROM TLDATA_DEV.SJXQ_SJ2023121566_CST_03
;

/*
SElECT '1' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_01
union all
SElECT '11' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_01_1
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_02
union all
SElECT '3' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_03
union all
SElECT '4' seq,count(1) cnt,count(DISTINCT 客户号) custs
from TLDATA_DEV.SJXQ_SJ2023121566_CST_04
;
1	892	827
11	892	827
2	275	275
3	296	275
4	296	275

*/
**SJ2023121566-购买封闭式理财客户清单2_1226.sql
/*
12月11日-18日，台州分行购买封闭式理财且成立的客户清单。
 (封闭式理财包括三年期一份期权\三年期两份期权、五年期一份期权和五年期两份期权;
 其他钱潮系列1号理财、小雪球和交银稳享灵动慧利6个月封闭式。

买入时间、客户号、客户姓名、产品名称、产品代码、确认金额
支行机构号、支行机构名称、部门机构号、部门机构名称、管护人工号、管护人姓名
对公客户(法定代表人客户号) 销售人工号、销售人姓名、客户手机号
*/

--理财销售明细
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_01 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_01 AS
select t1.cst_ID,t1.PD_CD,t1.trx_dt,t1.trx_tm,t1.CFM_AMT
    ,t1.mgr_id sale_empe_id,t1.ori_trx_act_id --客户账号
    ,t2.pd_nm
    ,T3.empe_nm sale_empe_nm
    ,t3.org_id
from edw.dwd_bus_chm_trx_cfm_dtl_di         t1  --只有近7天分区 cst_id,pd_cd,trx_dt,trx_tm 不唯一
inner join edw.dim_bus_chm_pd_inf_dd 	    t2  --理财产品信息
on t1.pd_cd=t2.pd_cd
and t2.dt='20231225'
and t2.pd_ctg_cd='1' --理财
and t2.pd_found_dt>='20231219'
LEFT JOIN edw.dws_hr_empe_inf_dd            T3  --员工信息汇总 27748 empe_id 唯一
ON  T1.mgr_id = T3.empe_id --销售人员
AND T3.DT='20231225'
WHERE t1.dt >= '20231219'
and t1.trx_dt between '20231219' and '20231225'
AND t1.trx_sts_cd IN ('6','7', '8','S' )  -- 交易成功
AND t1.bus_cd in ('122','130') -- 130 认购 122 申购
;

--存款账户管户
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_02 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_02 AS
SELECT t1.cst_ID,t1.cst_act_id
    ,CONCAT_WS('|', COLLECT_SET(t1.mgr_id))    mng_mgr_id
    ,CONCAT_WS('|', COLLECT_SET(t5.empe_nm))   mng_mgr_nm        --账户管户人
    ,CONCAT_WS('|', COLLECT_SET(cast(t1.mgr_rto as string)))   mgr_rto
    ,CONCAT_WS('|', COLLECT_SET(t1.acs_org_id)) acs_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.brc_org_nm)) brc_org_nm
    ,CONCAT_WS('|', COLLECT_SET(t4.sbr_org_id)) sbr_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.sbr_org_nm)) sbr_org_nm
    ,CONCAT_WS('|', COLLECT_SET(t4.tem_org_id)) tem_org_id
    ,CONCAT_WS('|', COLLECT_SET(t4.tem_org_nm)) tem_org_nm
from edw.dwd_bus_dep_cst_act_mgr_inf_dd         t1  --客户存款账户管护信息
inner join (select distinct cst_ID,ori_trx_act_id from lab_bigdata_dev.SJXQ_SJ2023122606_CST_01)t2
on t1.cst_id = t2.cst_id
and t1.cst_act_id = t2.ori_trx_act_id
INNER join edw.dim_hr_org_mng_org_tree_dd       t4   --考核机构树 4481 org_id 唯一
on  t1.acs_org_id = t4.org_id
and t4.dt = '20231225'
and t4.BRC_ORG_NM='台州分行'
LEFT JOIN edw.dws_hr_empe_inf_dd                T5  --员工信息汇总 27748 empe_id 唯一
ON T1.mgr_id = T5.empe_id
AND T5.DT='20231225'
where t1.dt='20231225'
group by t1.cst_ID,t1.cst_act_id
;


DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_03 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_03 AS
SElECT t1.cst_id,t1.cst_act_id
    ,t1.mng_mgr_id,t1.mng_mgr_nm,t1.mgr_rto
    ,t1.acs_org_id
    ,t1.brc_org_nm
    ,t1.sbr_org_id
    ,t1.sbr_org_nm
    ,t1.tem_org_id
    ,t1.tem_org_nm
    ,t2.PD_CD,t2.pd_nm,t2.trx_dt,t2.trx_tm,t2.CFM_AMT
    ,t2.sale_empe_id,t2.sale_empe_nm
    ,t3.cst_chn_nm,t3.m_tel_no
    ,t4.brc_org_nm  sale_brc_org_nm
    ,t4.sbr_org_id  sale_sbr_org_id
    ,t4.sbr_org_nm  sale_sbr_org_nm
    ,t4.tem_org_id  sale_tem_org_id
    ,t4.tem_org_nm  sale_tem_org_nm
    ,t5.lgp_cst_id,t5.lgp_nm
from lab_bigdata_dev.SJXQ_SJ2023122606_CST_02        t1
left join lab_bigdata_dev.SJXQ_SJ2023122606_CST_01   t2
on t1.cst_id=t2.cst_id
and t1.cst_act_id=t2.ori_trx_act_id
left join adm_pub.adm_csm_cbas_idv_bas_inf_dd   t3
on t1.cst_ID=t3.cst_ID
and t3.dt='20231225'
LEFT join  edw.dim_hr_org_mng_org_tree_dd       t4  --考核机构树 4481 org_id 唯一
on  t2.org_id = t4.org_id --销售人员所在机构
and t4.dt = '20231225'
left join edw.dim_cst_entp_lgp_inf_dd           t5  --对公客户法人信息表 （主键为cst_id 对公客户）
on t1.cst_ID=t5.cst_ID
and t5.dt = '20231225'
;

DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_04 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122606_CST_04 AS
SElECT cst_ID						客户号
    ,cst_chn_nm                     客户姓名
    ,m_tel_no                       客户手机号
    ,pd_nm                          产品名称
    ,PD_CD                          产品代码
    ,concat(trx_dt,' ',trx_tm)      买入时间
    ,CFM_AMT                        确认金额
    ,sale_empe_id                   销售人工号
    ,sale_empe_nm                   销售人姓名
    ,sale_brc_org_nm                销售分行机构名称
    ,sale_sbr_org_id                销售支行机构号
    ,sale_sbr_org_nm                销售支行机构名称
    ,sale_tem_org_id                销售团队机构号
    ,sale_tem_org_nm                销售团队机构名称
    ,mng_mgr_id                     账户管护人工号
    ,mng_mgr_nm                     账户管护人姓名
    ,mgr_rto                        账户管户比例
    ,brc_org_nm                     考核分行机构名称
    ,sbr_org_id                     考核支行机构号
    ,sbr_org_nm                     考核支行机构名称
    ,tem_org_id                     考核团队机构号
    ,tem_org_nm                     考核团队机构名称
    ,lgp_cst_id                     对公法人客户号
    ,lgp_nm                         对公法人客户名称
FROM lab_bigdata_dev.SJXQ_SJ2023122606_CST_03
;

/*
SElECT '1' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from lab_bigdata_dev.SJXQ_SJ2023122606_CST_01
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from lab_bigdata_dev.SJXQ_SJ2023122606_CST_02
union all
SElECT '3' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from lab_bigdata_dev.SJXQ_SJ2023122606_CST_03
union all
SElECT '4' seq,count(1) cnt,count(DISTINCT 客户号) custs
from lab_bigdata_dev.SJXQ_SJ2023122606_CST_04
;

1	784	722
2	310	310
3	352	310
4	352	310
*/
**SJ2023121581-苏州分行随贷通明细数据.sql
-- 客户号，客户名称，随贷通卡号，借据发放日期，借据期限，会计日期
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121581_CST_01 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121581_CST_01 AS
SElECT t1.cst_id,t1.cst_nm,t1.dtrb_act_id,t1.dtrb_dt,t1.apnt_mtu_day
from edw.dim_bus_loan_dbil_inf_dd           t1  --信贷借据信息 45576719 dbil_id(bus_ctr_id)
INNER join edw.dim_bus_loan_ctr_inf_dd      t2  --信贷合同信息 5820863 busi_ctr_id
on t1.bus_ctr_id = t2.busi_ctr_id
and t2.dt='20231215'
and t2.pd_cd like '2010503%' --随贷通
INNER join edw.dwd_bus_loan_ctr_mgr_inf_dd  t3  --信贷合同管护信息 5846462 busi_ctr_id
on t1.bus_ctr_id = t3.busi_ctr_id
and t3.dt = '20231215'
INNER join  edw.dim_hr_org_mng_org_tree_dd   t4 --考核机构树 4481 org_id 唯一
on t3.acs_org_id = t4.org_id
and t4.dt = '20231215'
and t4.BRC_ORG_NM='苏州分行'
where t1.dt = '20231215'
;

--结果表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023121581_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023121581_CST_02 AS
SElECT cst_id			客户号
    ,cst_nm             客户名称
    ,dtrb_act_id        随贷通卡号
    ,dtrb_dt            借据发放日期
    ,datediff(to_date(apnt_mtu_day,'yyyyMMdd'),to_date(dtrb_dt,'yyyyMMdd'),'dd') 借据期限
    ,'20231215'         会计日期
FROM TLDATA_DEV.SJXQ_SJ2023121581_CST_01
;


/*
SElECT '1' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023121581_CST_01
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT 客户号) custs
from TLDATA_DEV.SJXQ_SJ2023121581_CST_02
;
1	1445119	27154
2	1445119	27154
*/



**SJ20231218136-嘉兴分行理财全量客户清单.sql
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231218136_CST_01 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231218136_CST_01 AS
SELECT distinct t1.cst_id,t1.ta_cd,t1.mgr_id sale_empe_id
    ,t3.empe_nm sale_empe_nm
from edw.dim_bus_chm_act_inf_dd             t1
LEFT JOIN edw.dws_hr_empe_inf_dd            T3  --员工信息汇总 27748 empe_id 唯一
ON  T1.mgr_id = T3.empe_id --销售人员
AND T3.DT='20231218'
inner join (
    SElECT DISTINCT cst_id
    from  qbi_file_20231221_13_59_58            --11469 11410
    where pt=max_pt('qbi_file_20231221_13_59_58')
)t4 on t1.cst_id=t4.cst_id
WHERE t1.dt = '20231218'
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231218136_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231218136_CST_02 AS
SElECT cst_id,ta_cd
    ,CONCAT_WS('|', COLLECT_SET(sale_empe_id)) sale_empe_id
    ,CONCAT_WS('|', COLLECT_SET(sale_empe_nm)) sale_empe_nm
from TLDATA_DEV.SJXQ_SJ20231218136_CST_01
WHERE sale_empe_nm IS NOT NULL
group by cst_id,ta_cd
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ20231218136_CST_03 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ20231218136_CST_03 AS
SElECT t1.cst_id			客户号
    ,t1.cst_nm              客户名称
    ,t1.col_3               管户比例
    ,t1.mng_org_id          管户机构号
    ,t1.mng_org_nm          管户机构名称
    ,t1.mng_mgr_id          管户人工号
    ,t1.mng_mgr_nm          管户人名称
    ,T2.sale_empe_id        自营理财_TL_推荐人工号
    ,T2.sale_empe_nm        自营理财TA_TL_推荐人姓名
    ,T3.sale_empe_id        兴银理财_998_推荐人工号
    ,T3.sale_empe_nm        兴银理财_998_推荐人姓名
    ,T4.sale_empe_id        兴银理财_999_推荐人工号
    ,T4.sale_empe_nm        兴银理财_999_推荐人姓名
    ,T5.sale_empe_id        南银理财_Y5_推荐人工号
    ,T5.sale_empe_nm        南银理财_Y5_推荐人姓名
    ,T6.sale_empe_id        交银理财_Y88_推荐人工号
    ,T6.sale_empe_nm        交银理财_Y88_推荐人姓名
    ,T7.sale_empe_id        渝农商理财_YNS_推荐人工号
    ,T7.sale_empe_nm        渝农商理财_YNS_推荐人姓名
from qbi_file_20231221_13_59_58                 t1
left join TLDATA_DEV.SJXQ_SJ20231218136_CST_02  t2
on t1.cst_id=t2.cst_id and t2.ta_cd='TL'
left join TLDATA_DEV.SJXQ_SJ20231218136_CST_02  t3
on t1.cst_id=t3.cst_id and t3.ta_cd='998'
left join TLDATA_DEV.SJXQ_SJ20231218136_CST_02  t4
on t1.cst_id=t4.cst_id and t4.ta_cd='999'
left join TLDATA_DEV.SJXQ_SJ20231218136_CST_02  t5
on t1.cst_id=t5.cst_id and t5.ta_cd='Y5'
left join TLDATA_DEV.SJXQ_SJ20231218136_CST_02  t6
on t1.cst_id=t6.cst_id and t6.ta_cd='Y88'
left join TLDATA_DEV.SJXQ_SJ20231218136_CST_02  t7
on t1.cst_id=t7.cst_id and t7.ta_cd='YNS'
where t1.pt=max_pt('qbi_file_20231221_13_59_58')
;

/*
SElECT '1' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ20231218136_CST_01
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ20231218136_CST_02
union all
SElECT '3' seq,count(1) cnt,count(DISTINCT 客户号) custs
from TLDATA_DEV.SJXQ_SJ20231218136_CST_03
;
1	16945	11410
2	13517	10043
3	11469	11410
*/
**SJ2023122501-台州分行个人账户明细.sql
--数据日期：20221001-20231101
--机构：台州分行、总行营业部
-- 客户账号 账户名称 开户机构 开户日期 销户日期 账户类型 客户号 账户状态 日均余额
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_01 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_01 AS
SElECT t1.dep_act_id,t1.cst_act_id,t1.act_nm
    ,t4.brc_org_nm,t4.sbr_org_nm,t4.tem_org_nm
    ,t1.opn_dt
    ,round(datediff(TO_DATE('20231101', 'yyyymmdd'),TO_DATE(t1.opn_dt,'yyyymmdd'),'dd')/30,1) opn_mons
    ,t1.act_dstr_act_dt   --销户日期
    ,t1.cst_id
    ,decode(t1.act_sts_cd,'A','正常','B','不动户','D','久悬户','E','封闭冻结','F','金额冻结','G','未启用','H','待启用','I','转营业外收入','Y','预销户') act_sts
    ,decode(t1.ACT_CTG_CD_2,'301','I类户','302','II类户','303','III类户','')    ACT_CTG
    ,t1.last_30_days_gl_bal_acml/30     lst_30_day_avg_bal --过去30天日均余额
    ,t1.last_90_days_gl_bal_acml/90     lst_90_day_avg_bal
    ,t1.last_180_days_gl_bal_acml/180   lst_180_day_avg_bal
    ,t1.last_270_days_gl_bal_acml/270   lst_270_day_avg_bal
    ,t1.last_360_days_gl_bal_acml/360   lst_360_day_avg_bal
FROM edw.dws_bus_dep_act_inf_dd             T1             -- 存款账户信息表
left join edw.dim_hr_org_mng_org_tree_dd    t4             --考核机构树 4481 org_id 唯一
on      t1.opn_org = t4.org_id
and     t4.dt = '20231101'
WHERE   T1.DT = '20231101'
AND     T1.ACT_CTG_CD_2 in ('301','302','303')  -- I、II、III类账户
AND     T1.STL_ACT_IND = '1'                    -- 结算账户
and     T1.ACT_STS_CD <>'C'                     -- 账户状态
-- AND     T1.CCY_CD = '156'   --只取人民币
-- AND     T1.BAL_GL_IND <> '0' --剔除虚户
-- AND     T1.CST_ID <> '2000394435'  --剔除验资户，该客户是验资户专户
AND   (T1.opn_org like  '3301%' or  T1.opn_org like  '9999%') --台州分行、总行营业部
and     T1.opn_dt>='20221001'
AND     T1.opn_dt<='20231101'
;

-- 年龄 户籍地址 居住地址
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_02 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_02 AS
SElECT cst_id,doc_nbr
    ,2023-cast(SUBSTR(doc_nbr,7,4) as int) age
    ,concat(substr(regexp_replace(reg_adr,'\\s|,',''),1,greatest(length(regexp_replace(reg_adr,'\\s|,',''))-6,0)),'******')  reg_adr_pro
    ,concat(substr(regexp_replace(fml_adr,'\\s|,',''),1,greatest(length(regexp_replace(fml_adr,'\\s|,',''))-6,0)),'******')  fml_adr_pro
from edw.dws_cst_bas_inf_dd
where dt = '20231101'
;

--账户是否关闭非柜面 关闭非柜面原因
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_03 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_03 AS
SELECT  cst_act_id,lmt_cmt
    ,ROW_NUMBER() over(partition by cst_act_id order by lmt_eft_dt desc) rn
FROM    edw.dwd_bus_dep_act_lmt_inf_dd  --账户额度控制
WHERE   DT = '20231101'
AND     ACT_THRS_TYP = '2'      --暂停非柜面
and     evt_id='DPDRAW'
;

-- 是否止付 止付原因
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_04 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_04 AS
SELECT  cst_act_id,frz_rsn
    ,ROW_NUMBER() over (partition by cst_act_id order by frz_dt desc) rn
FROM    edw.dwd_bus_dep_frz_inf_dd --账户冻结登记
WHERE   DT = '20231101'
AND     FRZ_SRC_CD='2'  --止付
AND     NFRZ_IND = '0'
;

-- 客户交易
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_05 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_05 AS
SELECT  A.cst_act_id
    ,A.dep_act_id
    ,A.trx_dt
    ,A.trx_amt
    ,case when A.TRX_CHNL_CD='A01' then '柜面' else '' end trx_chnl
from  edw.DWD_BUS_DEP_BAL_CHG_DTL_DI            A
INNER join lab_bigdata_dev.SJXQ_SJ2023122501_CST_01  T2
on a.cst_act_id=t2.cst_act_id
and a.dep_act_id=t2.dep_act_id
and a.trx_dt>=t2.opn_dt         --开户至今
WHERE A.dt<='20231101'
AND   A.crd_and_dbt_ind='D'     --汇出
;

-- 客户交易-非柜面
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_05_1 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_05_1 AS
SELECT  A.cst_act_id
    ,A.dep_act_id
    ,A.trx_dt
    ,A.trx_amt
from  edw.DWD_BUS_DEP_BAL_CHG_DTL_DI            A
INNER join lab_bigdata_dev.SJXQ_SJ2023122501_CST_01  T2
on a.cst_act_id=t2.cst_act_id
and a.dep_act_id=t2.dep_act_id
and a.trx_dt>=t2.opn_dt         --开户至今
WHERE A.dt<='20231101'
AND   A.crd_and_dbt_ind='D'     --汇出
and   A.TRX_CHNL_CD not in ('A01','M08','C03','C10') -- 'A01'柜面
and   A.int_trx_no  not in ('dp2265','dp2101','dp15')
and   A.txt_code not in ('LQSF01','SBKF01','BA0004','FD0001','FD0002','FD0003','FD0004','FD0005','FD0010'
    ,'FD0011','FD0012','FD0013','FD0014','FD0015','FD0016','FD0017','FD0018','FD0019','LC0009','LN0002'
    ,'LN0003','LN0004','THKHK1','XE1207','XYKHK1','YL0035','TY0033')
and   A.smr_dscr NOT regexp '代发|代扣'
and   A.bal_fld_nm='DPLDGBAL'
;

DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_06 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_06 AS
SElECT t1.cst_act_id,t1.max_per_trx_amt
    ,t2.max_per_trx_amt_gm
    ,t3.max_per_trx_amt_fgm
    ,t4.max_day_trx_amt_gm
    ,t5.max_day_trx_amt_fgm
from(
    SElECT cst_act_id,max(trx_amt) max_per_trx_amt
    from lab_bigdata_dev.SJXQ_SJ2023122501_CST_05
    group by cst_act_id
)t1 left join (
    SElECT cst_act_id,max(trx_amt) max_per_trx_amt_gm
    from lab_bigdata_dev.SJXQ_SJ2023122501_CST_05
    where trx_chnl='柜面'
    group by cst_act_id
)t2 on t1.cst_act_id=t2.cst_act_id
left join (
    SElECT cst_act_id,max(trx_amt) max_per_trx_amt_fgm
    from lab_bigdata_dev.SJXQ_SJ2023122501_CST_05_1
    group by cst_act_id
)t3 on t1.cst_act_id=t3.cst_act_id
left join(
    SElECT cst_act_id,max(trx_amt) max_day_trx_amt_gm
    FROM(
        SElECT cst_act_id,trx_dt,sum(trx_amt) trx_amt
        from lab_bigdata_dev.SJXQ_SJ2023122501_CST_05
        where trx_chnl='柜面'
        group by cst_act_id,trx_dt
    )A GROUP by cst_act_id
)t4 on t1.cst_act_id=t4.cst_act_id
left join(
    SElECT cst_act_id,max(trx_amt) max_day_trx_amt_fgm
    FROM(
        SElECT cst_act_id,trx_dt,sum(trx_amt) trx_amt
        from lab_bigdata_dev.SJXQ_SJ2023122501_CST_05_1
        group by cst_act_id,trx_dt
    )A GROUP by cst_act_id
)t5 on t1.cst_act_id=t5.cst_act_id
;

-- 非柜额度
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_07 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_07 AS
select distinct cengcgjz cst_act_id
    ,danciedu
    ,leijiedu
from edw.core_kdpa_zheddy -- 负债账户额度定义表
where dt = '20231101'
and  zhxeleix='2'
and shijbhao='FGMXIANE' -- 非柜面限额
and edkzzhqi='1D' -- 日限额
;

--  开户日至20231101期间交易金额加总、开户日至20231101期间交易笔数加总
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_08 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_08 AS
select A.cst_act_id,a.dep_act_id
    ,SUM(B.trx_amt)     as   trx_amt_sum
    ,COUNT(1)           as   trx_numbers
from edw.DIM_BUS_DEP_ACT_INF_DD             A
INNER join edw.DWD_BUS_DEP_BAL_CHG_DTL_DI   B
ON   A.DEP_ACT_ID=B.DEP_ACT_ID
AND  A.CST_ACT_ID=B.CST_ACT_ID
AND  B.dt>= a.opn_dt
AND  B.dt<='20231101'
where  A.dt='20231101'
and    A.ACT_CTG_CD_2 in ('301','302','303') --I、II、III类账户
AND   (A.opn_org like  '3301%' or  A.opn_org like  '9999%') --台州分行、总行营业部
-- and    CONCAT(B.smr_dscr,B.cmt)  regexp  '工资'
GROUP BY  A.cst_act_id,a.dep_act_id
;


--账户常用转出渠道
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_09 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_09 AS
SElECT cst_act_id,dep_act_id,cd_val_dscr
    ,ROW_NUMBER() over(PARTITION by cst_act_id,dep_act_id order by trx_cnt desc) cnt_rn
    ,ROW_NUMBER() over(PARTITION by cst_act_id,dep_act_id order by trx_amt desc) amt_rn
from(
    SElECT t1.cst_act_id,t1.dep_act_id,t2.cd_val_dscr
        ,count(1) trx_cnt
        ,sum(t1.trx_amt) trx_amt
    from edw.DWD_BUS_DEP_BAL_CHG_DTL_DI     t1
    left join edw.dwd_code_library_dd       t2
    on t1.trx_chnl_cd=t2.cd_val
    and t2.dt='20231130'
    and t2.fld_nm = upper('trx_chnl_cd')
    and t2.tbl_nm = upper('dwd_bus_dep_bal_chg_dtl_di')
    where t1.dt>='20221001' and t1.dt<='20231101'
    and t1.trx_dt>='20221001' and t1.trx_dt<='20231101'
    and t1.crd_and_dbt_ind = 'D'   --借贷标志|C1 D借
    GROUP by t1.cst_act_id,t1.dep_act_id,t2.cd_val_dscr
)a
;

--数据汇总
DROP   TABLE IF     EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_10 purge;
CREATE TABLE IF NOT EXISTS lab_bigdata_dev.SJXQ_SJ2023122501_CST_10 AS
SElECT t1.cst_act_id			客户账号
    ,t1.act_nm                  账户名称
    ,t1.brc_org_nm              开户分行
    ,t1.sbr_org_nm              开户支行
    ,t1.tem_org_nm              开户团队
    ,t1.opn_dt                  开户日期
    ,t1.act_dstr_act_dt         销户日期
    ,t1.ACT_CTG                 账户类型
    ,t1.cst_id                  客户号
    ,t2.age                     年龄
    ,t2.reg_adr_pro             户籍地址
    ,t2.fml_adr_pro             家庭地址
    ,t1.act_sts                 账户状态
    ,case when t3.cst_act_id is not null then 1 else 0 end  账户是否关闭非柜面
    ,t3.lmt_cmt                 关闭非柜面原因
    ,case when t4.cst_act_id is not null then 1 else 0 end  是否止付
    ,t4.frz_rsn                 止付原因
    ,case when t12.certid is not null then 1 else 0 end     是否查冻
    ,t6.max_per_trx_amt			开户至今单笔汇出最大金额
    ,t6.max_per_trx_amt_gm      开户至今单笔汇出最大金额_柜面
    ,t6.max_per_trx_amt_fgm     开户至今单笔汇出最大金额_非柜面
    ,t6.max_day_trx_amt_gm      开户至今单日汇出最大金额累计_柜面
    ,t6.max_day_trx_amt_fgm     开户至今单日汇出最大金额累计_非柜面
    ,t7.danciedu                单笔非柜额度
    ,t7.leijiedu                累计非柜额度
    ,case when t1.opn_mons<=1 then t8.trx_numbers else round(t8.trx_numbers/t1.opn_mons,0) end 月均交易笔数
    ,case when t1.opn_mons<=1 then t8.trx_amt_sum else round(t8.trx_amt_sum/t1.opn_mons,0) end 月均交易金额
    ,t1.lst_30_day_avg_bal 		过去30天日均余额
    ,t1.lst_90_day_avg_bal      过去90天日均余额
    ,t1.lst_180_day_avg_bal     过去180天日均余额
    ,t1.lst_270_day_avg_bal     过去270天日均余额
    ,t1.lst_360_day_avg_bal     过去360天日均余额
    ,t9.cd_val_dscr             账户常用转出渠道
    ,t9_1.cd_val_dscr           账户转出金额最多渠道
    ,case when t10.act_id is not null then 1 else 0 end     开通电子银行及第三方支付情况
    ,case when t11.cst_id is not null then 1 else 0 end     工资户标识
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_01        t1
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_02   t2 on t1.cst_id=t2.cst_id
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_03   t3 on t1.cst_act_id=t3.cst_act_id and t3.rn=1
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_04   t4 on t1.cst_act_id=t4.cst_act_id and t4.rn=1
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_06   t6 on t1.cst_act_id=t6.cst_act_id
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_07   t7 on t1.cst_act_id=t7.CST_ACT_ID
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_08   t8
on t1.cst_act_id=t8.cst_act_id and t1.dep_act_id=t8.dep_act_id
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_09   t9
on t1.cst_act_id=t9.cst_act_id and t1.dep_act_id=t9.dep_act_id and t9.cnt_rn=1
left join lab_bigdata_dev.SJXQ_SJ2023122501_CST_09   t9_1
on t1.cst_act_id=t9_1.cst_act_id and t1.dep_act_id=t9_1.dep_act_id and t9_1.amt_rn=1
left join (
    select distinct act_id
    from edw.dwd_bus_chnl_epc_pay_agr_inf_dd    --开通电子银行及第三方支付情况
    WHERE dt = '20231101'
)t10 on t1.cst_act_id=t10.act_id
left join (
    SElECT distinct kehuhaoo  as  cst_id        --工资户标识
    from edw.core_kcpb_zhbzxx
    where dt = '20231101'
)t11 on t1.cst_id=t11.cst_id
left join(
    Select distinct certid
    from app_rpt.INTER_ENQUIRY_REG              --是否查冻
    where dt<='20231224'
)t12 on t2.doc_nbr=t12.certid
;


/*
SElECT '1' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_01
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT cst_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_02
union all
SElECT '3' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_03
union all
SElECT '4' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_04
union all
SElECT '5' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_05
union all
SElECT '6' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_06
union all
SElECT '7' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_07
union all
SElECT '8' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_08
union all
SElECT '9' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_09
union all
SElECT '10' seq,count(1) cnt,count(DISTINCT 客户账号) custs
from lab_bigdata_dev.SJXQ_SJ2023122501_CST_10
;
1	121120	121120
2	15649128	15649128
3	3915334	3647947
4	2603850	2573444
5	7339635	85951
6	85951	85951
7	3445709	3445707
8	2310553	2310553
9	9935877	4472125
10	121120	121120
*/
**SJ20231225116_1227基金劳动竞赛.sql

-- 10月31日 的定投累计申请金额 - 6月30日定投累计申请金额（需要剔除 短债、货基）
DROP TABLE  IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_01;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_01 AS
SELECT  A.CST_ID,min(A.AIP_START_DT) AIP_START_DT
    ,sum(a.ACM_AIP_SUC_AMT) ACM_AIP_SUC_AMT
    ,sum(a.ACM_SUC_TMS) ACM_SUC_TMS
    ,max(a.dt) max_dt
from(
    SElECT a.cst_ID,a.AIP_START_DT,a.ACM_AIP_SUC_AMT,a.ACM_SUC_TMS,a.AGR_STS_CD,a.dt
        ,ROW_NUMBER() over(partition by a.agr_id,a.cst_ID ORDER by a.dt desc) rn
    FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD A -- 基金定投协议信息
    LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15 B
    ON 	A.PD_CD=B.PRD_CD
    AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
    LEFT JOIN(
        SELECT Pd_cd
        FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
        WHERE DT='@@{yyyyMMdd}'
        AND fnd_typ_cd='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
    )C ON A.PD_CD=C.Pd_cd
    LEFT JOIN (
        -- 活动开始前（6月30日15：00前）已在我行存在定投扣款成功记录的客户
        SELECT  DISTINCT CST_ID
        FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD -- 基金定投协议信息
        WHERE DT='20230630' AND ACM_SUC_TMS>0    --6月30日前存在定投扣款成功客户
    )D ON A.CST_ID=D.CST_ID
    WHERE A.DT>='20230701' and a.dt<='20231031'
    AND A.AIP_START_DT BETWEEN '20230701' AND '20231031'   --基金确认时间，之前定投需剔除
    AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
    AND C.Pd_cd IS NULL 	    -- 剔除 货基
    AND D.CST_ID IS NULL 		-- 剔除 存量定投客户
)a where rn=1
GROUP by  A.CST_ID
having sum(a.ACM_AIP_SUC_AMT)>=1000 and sum(a.ACM_SUC_TMS)>=3
;

--20230903
DROP TABLE  IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_02;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_02 AS
SELECT  A.CST_ID,sum(a.ACM_AIP_SUC_AMT) ACM_AIP_SUC_AMT
    ,sum(a.ACM_SUC_TMS) ACM_SUC_TMS
from(
    SElECT a.cst_ID,a.AIP_START_DT,a.ACM_AIP_SUC_AMT,a.ACM_SUC_TMS,a.dt
        ,ROW_NUMBER() over(partition by a.agr_id,a.cst_ID ORDER by a.dt desc) rn
    FROM  EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD A -- 基金定投协议信息
    LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15 B
    ON 	A.PD_CD=B.PRD_CD
    AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
    LEFT JOIN(
        SELECT Pd_cd
        FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
        WHERE DT='@@{yyyyMMdd}'
        AND fnd_typ_cd='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
    )C ON A.PD_CD=C.Pd_cd
    WHERE a.dt>='20230701' and A.DT<='20230903'
    AND A.AIP_START_DT BETWEEN '20230701' AND '20230903'   --基金确认时间，之前定投需剔除
    AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
    AND C.Pd_cd IS NULL 	    -- 剔除 货基
)a where rn=1
GROUP by  A.CST_ID
;

--当前基金状态
DROP TABLE  IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_03;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_03 AS
select cst_ID,cst_nm,min(AGR_STS_CD) AGR_STS_CD,min(FUND_TYPE) FUND_TYPE
from(
    SElECT a.cst_ID,a.cst_nm,a.AGR_STS_CD,a.PD_CD
            ,ROW_NUMBER() over(partition by a.agr_id,a.cst_ID ORDER by a.dt desc) rn
    from EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD  a
    where a.dt>='20230701' and a.dt<='20231031'
)a LEFT JOIN(
	SELECT DISTINCT Pd_cd,fnd_typ_cd FUND_TYPE -- ,PROD_NAME
	FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
	WHERE DT='@@{yyyyMMdd}'
)C ON A.PD_CD=C.Pd_cd
where a.rn=1
group by a.cst_ID,a.cst_nm
;

-- 字段名称：客户姓名	客户号	当前财富管户人姓名	当前财富管户人工号	当前财富管户人所在团队名称	当前财富管户人所在分行名称
-- 基金类型	定投累计申请金额	定投累计申请次数	9月3日前累计定投申请金额 9月3日前累计定投申请次数	10月31日名下是否有有效定投协议

DROP TABLE  IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP AS
SELECT c.CST_NM					as 	客户姓名
	,A.CST_ID 					as	客户号
	,T3.EMPE_NM                 as 	当前财富管户人姓名
	,T2.WLTH_MNG_MNL_ID         as 	当前财富管户人工号
	,T4.TEM_ORG_NM              as	当前财富管户人所在团队名称
	,T4.BRC_ORG_NM              as 	当前财富管户人所在分行名称
	,DECODE(c.FUND_TYPE, '01','股票型','02','债券型','03','混合型','04','货币型') 基金类型
	,COALESCE(A.ACM_AIP_SUC_AMT,0)  as 定投累计申请金额
	,COALESCE(A.ACM_SUC_TMS,0)      as 定投累计申请次数
	,COALESCE(B.ACM_AIP_SUC_AMT,0)  as 9月3日前累计定投申请金额
	,COALESCE(B.ACM_SUC_TMS,0)      as 9月3日前累计定投申请次数
	,case when c.AGR_STS_CD='0' then '是' else '否' end as 10月31日名下是否有有效定投协议
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_01      A
LEFT JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_02 B
ON A.CST_ID=B.CST_ID
LEFT JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_03 c
ON A.CST_ID=c.CST_ID
LEFT JOIN EDW.DIM_BUS_CHM_FND_CST_CTR_INF_DD T2		-- 基金客户签约信息表
ON      A.CST_ID = T2.CST_ID
AND     T2.DT = '20231031'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD T3 				-- 员工汇总信息
ON      T2.WLTH_MNG_MNL_ID = T3.EMPE_ID
AND     T3.DT = '@@{yyyyMMdd}'
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD T4
ON      T4.ORG_ID = T3.ORG_ID
AND     T4.DT = '@@{yyyyMMdd}'
;
/*
SELECT '1' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_01
union all
SELECT '2' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_02
union all
SELECT '3' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP_03
union all
SELECT 'res' ,COUNT(1) CNT,COUNT(DISTINCT 客户号) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST0_ZYP
;

1	7120	7120
2	5862	5862
3	16633	16633
res	7120	7120
*/
**SJ20231225116_1227基金劳动竞赛2.sql
--活动开始前（6月30日15：00前）已在我行存在定投扣款成功记录的客户
DROP   TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_01 purge;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_01 AS
SElECT distinct cst_id
from edw.dwd_bus_chm_fnd_trx_cfm_dtl_di  --基金交易确认流水明细 一天数据量 879 788
where dt<='@@{yyyyMMdd}'
and cfm_dt<='20230630'                  --确认时间
and TRX_STS_CD IN ('0','3','4','S')     --交易状态：'0','申请成功','3','确认成功','4','部分确认成功','S','成功'
and BUS_CD ='139'                       --定时定额申购确认
;

--20230903
DROP   TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_02 purge;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_02 AS
SElECT A.cst_id
    ,count(1)           aip_cnt_0903
    ,sum(a.cfm_amt)     aip_amt_0903
from edw.dwd_bus_chm_fnd_trx_cfm_dtl_di                 A  --基金交易确认流水明细 一天数据量 879 788
LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15    B
ON 	A.PD_CD=B.PRD_CD
AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
LEFT JOIN(
    SELECT Pd_cd
    FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
    WHERE DT='@@{yyyyMMdd}'
    AND fnd_typ_cd='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
)C ON A.PD_CD=C.Pd_cd
where A.dt<='@@{yyyyMMdd}'
and A.cfm_dt>'20230630' and A.cfm_dt<='20230903'
and A.TRX_STS_CD IN ('0','3','4','S')     --交易状态：'0','申请成功','3','确认成功','4','部分确认成功','S','成功'
and A.BUS_CD ='139'                       --定时定额申购确认
AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
AND C.Pd_cd IS NULL 	    -- 剔除 货基
GROUP by A.cst_id
;

--20231031
DROP   TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_03 purge;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_03 AS
SElECT A.cst_id
    ,count(1)                               aip_cnt_1031
    ,sum(a.cfm_amt)                         aip_amt_1031
    ,CONCAT_WS('|', COLLECT_SET(e.fnd_typ)) aip_fnd_typ_1031
from edw.dwd_bus_chm_fnd_trx_cfm_dtl_di                 A  --基金交易确认流水明细 一天数据量 879 788
LEFT JOIN LAB_BIGDATA_DEV.QBI_FILE_20231115_15_37_15    B
ON 	A.PD_CD=B.PRD_CD
AND B.PT = MAX_PT('QBI_FILE_20231115_15_37_15') -- 同业存单基金、短债
LEFT JOIN(
    SELECT Pd_cd
    FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
    WHERE DT='@@{yyyyMMdd}'
    AND fnd_typ_cd='04'  -- 01-股票型；02-债券型；03-混合型；04-货币型
)C ON A.PD_CD=C.Pd_cd
left join LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_01  D on a.cst_id=d.cst_id
LEFT JOIN(
    SELECT Pd_cd,decode(fnd_typ_cd,'01','股票型','02','债券型','03','混合型','04','货币型','06','FOF基金') fnd_typ
    FROM EDW.DIM_BUS_CHM_FND_PD_INF_DD
    WHERE DT='@@{yyyyMMdd}' -- 01-股票型；02-债券型；03-混合型；04-货币型
)e ON A.PD_CD=e.Pd_cd
where A.dt<='@@{yyyyMMdd}'
and A.cfm_dt>'20230630' and A.cfm_dt<='20231031'    --确认时间
and A.TRX_STS_CD IN ('0','3','4','S')     --交易状态：'0','申请成功','3','确认成功','4','部分确认成功','S','成功'
and A.BUS_CD ='139'                       --定时定额申购确认
AND B.PRD_CD IS NULL		-- 剔除 同业存单基金、短债
AND C.Pd_cd IS NULL 	    -- 剔除 货基
and d.cst_id is null        -- 剔除 存量定投客户
GROUP by A.cst_id
having count(1)>=3 and sum(a.cfm_amt)>=1000
;

--最新基金定投协议状态
DROP   TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_04 purge;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_04 AS
select cst_ID,cst_nm,AGR_STS_CD,dt,chnl_dt,chnl_tm,trx_dt
    ,ROW_NUMBER() over(partition by a.cst_ID ORDER by a.AGR_STS_CD asc) RN          --每个客户最新状态
from(
    SElECT a.cst_ID,a.cst_nm,a.AGR_STS_CD,a.dt
        ,chnl_dt,chnl_tm        --渠道日期|c8 渠道时间|c6
        ,trx_dt                 --交易日期|c8
        ,ROW_NUMBER() over(partition by a.agr_id,a.cst_ID ORDER by a.dt desc) rn    --每个协议最新状态
    from EDW.DIM_BUS_CHM_FND_AIP_AGR_INF_DD  a
    where a.dt<='20231031'
    and a.aip_start_dt<='20231031'  --定投开始日期|c8
)a where a.rn=1
;


--数据汇总
DROP   TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_05 purge;
CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_05 AS
SELECT c.CST_NM					as 	客户姓名
	,A.CST_ID 					as	客户号
	,T3.EMPE_NM                 as 	当前财富管户人姓名
	,T2.WLTH_MNG_MNL_ID         as 	当前财富管户人工号
	,T4.TEM_ORG_NM              as	当前财富管户人所在团队名称
	,T4.BRC_ORG_NM              as 	当前财富管户人所在分行名称
	,a.aip_fnd_typ_1031             基金类型
	,COALESCE(A.aip_amt_1031,0)  as 定投累计申请金额
	,COALESCE(A.aip_cnt_1031,0)  as 定投累计申请次数
	,COALESCE(B.aip_amt_0903,0)  as 9月3日前累计定投申请金额
	,COALESCE(B.aip_cnt_0903,0)  as 9月3日前累计定投申请次数
	,case when c.AGR_STS_CD='0' then 1 else 0 end as 截止1031日是否存在有效定投协议
    ,c.dt                           协议最后更新日期
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_03          A   --1031
LEFT JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_02     B   --0903
ON A.CST_ID=B.CST_ID
LEFT JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_04     c   --协议状态
ON A.CST_ID=c.CST_ID
and c.rn=1
LEFT JOIN EDW.DIM_BUS_CHM_FND_CST_CTR_INF_DD            T2	-- 基金客户签约信息表
ON      A.CST_ID = T2.CST_ID
AND     T2.DT = '20231031'
LEFT JOIN EDW.DWS_HR_EMPE_INF_DD                        T3 	-- 员工汇总信息
ON      T2.WLTH_MNG_MNL_ID = T3.EMPE_ID
AND     T3.DT = '@@{yyyyMMdd}'
LEFT JOIN EDW.DIM_HR_ORG_MNG_ORG_TREE_DD                T4
ON      T4.ORG_ID = T3.ORG_ID
AND     T4.DT = '@@{yyyyMMdd}'
;

--输出结果
SElECT *
from LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_05
;
/*
SELECT '1' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_01
union all
SELECT '2' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_02
union all
SELECT '3' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_03
union all
SELECT '4' seq,COUNT(1) CNT,COUNT(DISTINCT CST_ID) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_04
union all
SELECT '5' seq,COUNT(1) CNT,COUNT(DISTINCT 客户号) CUSTS
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231225116_CST_05
;
1	8724	8724
2	7110	7110
3	7396	7396
4	29601	20101
5	7396	7396
*/
**SJ2023122536-财富业务清算挂账.sql
--存款账户管户
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_01 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_01 AS
select t1.cst_id,t1.cst_act_id
    ,CONCAT_WS('|', COLLECT_SET(T2.EMPE_NM))     dep_act_mng_mgr
    ,CONCAT_WS('|', COLLECT_SET(T4.sbr_org_nm))  dep_act_mng_org
from edw.dwd_bus_dep_cst_act_mgr_inf_dd     t1      --存款客户账户`管户`信息 cst_id,cst_act_id,acs_org_id, mgr_id 唯一
left join edw.dws_hr_empe_inf_dd            t2      --员工信息汇总 empe_id 唯一
on  T1.mgr_id=T2.empe_id
AND T2.DT='@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd    t4      --考核机构树 org_id 唯一
on      t1.acs_org_id = t4.org_id
and     t4.dt = '@@{yyyyMMdd}'
where t1.dt='@@{yyyyMMdd}'
GROUP by t1.cst_id,t1.cst_act_id
;

-- 信贷管户
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_02 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_02 AS
SElECT t1.cst_id
    ,CONCAT_WS('|', COLLECT_SET(T3.EMPE_NM))     loan_mng_mgr
    ,CONCAT_WS('|', COLLECT_SET(T4.sbr_org_nm))  loan_mng_org
from edw.dim_bus_loan_ctr_inf_dd            t1
left join edw.dwd_bus_loan_ctr_mgr_inf_dd   t2
on t1.busi_ctr_id=t2.busi_ctr_id
and t2.dt = '@@{yyyyMMdd}'
left join edw.dws_hr_empe_inf_dd            t3      --员工信息汇总 empe_id 唯一
on  T2.acs_mngr_id=T3.empe_id
AND T3.DT='@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd    t4      --考核机构树 org_id 唯一
on      t2.acs_org_id = t4.org_id
and     t4.dt = '@@{yyyyMMdd}'
where t1.dt='@@{yyyyMMdd}'
and NVL(t1.cst_id,'') <> ''    --剔除空值和空
GROUP by t1.cst_id
;

-- 财富管户、财富顾问、主管户
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_03 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_03 AS
select t1.cst_act_id,t1.act_nm,t1.gz_dt,t1.gz_amt,t1.gz_reason
    ,T2.CST_ID
    ,decode(t2.act_sts_cd,'A','正常','B','不动户','C','销户','D','久悬户','E','封闭冻结','F','金额冻结','G','未启用','H','待启用','I','转营业外收入','Y','预销户') act_sts
    ,t3.wlth_mng_mnl_id,t3.wlth_mng_org_id ,t3.wlth_advsr_id
    ,t5.sbr_org_nm prm_org_nm
    ,t4.prm_mgr_nm
from qbi_file_20231226_12_03_54                 t1
left join(
    Select cst_act_id,cst_ID,act_sts_cd
    from edw.dim_bus_dep_cst_act_inf_dd
    where DT='@@{yyyyMMdd}'
    union all
    Select cst_act_id,cst_ID,act_sts_cd
    from edw.dim_bus_dep_cst_act_inf_dd
    where DT='20210414'                         --该客户自 20210414 后数据缺失
    and cst_act_id='6221410011519387'
)t2 on t1.cst_act_id=t2.cst_act_id --客户存款账户信息 cst_act_id 唯一
LEFT JOIN edw.dim_bus_chm_fnd_cst_ctr_inf_dd    t3      --财富管户 财富顾问
on t2.cst_id=t3.cst_id
and t3.dt = '@@{yyyyMMdd}'
left join adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t4    --客户`主管户`信息 cst_id 唯一
on      t2.cst_id = t4.cst_id
and     t4.dt = '@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd t5             --考核机构树 org_id 唯一
on      t4.prm_org_id = t5.org_id
and     t5.dt = '@@{yyyyMMdd}'
where T1.pt=max_pt('qbi_file_20231226_12_03_54')
;

--汇总表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_04 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_04 AS
SElECT t1.cst_ID            客户号
    ,t1.cst_act_id		    客户账号
    ,t1.act_nm              账户名称
    ,t1.gz_dt               挂账日期
    ,t1.gz_amt              挂账金额
    ,t2.dep_act_mng_mgr     存款账户管户人
    ,t2.dep_act_mng_org     存款账户管户支行
    ,t3.EMPE_NM             财富管户人
    ,t4.sbr_org_nm          财富管户支行
    ,t5.EMPE_NM             财富顾问
    ,t6.sbr_org_nm          财富顾问支行
    ,t1.prm_mgr_nm          主管户人
    ,t1.prm_org_nm          主管户支行
    ,t7.loan_mng_mgr        信贷管户人
    ,t7.loan_mng_org        信贷管户支行
    ,t1.act_sts             账户状态
from TLDATA_DEV.SJXQ_SJ2023122536_CST_03        t1
left join TLDATA_DEV.SJXQ_SJ2023122536_CST_01   t2
on t1.cst_id=t2.cst_id
and t1.cst_act_id=t2.cst_act_id
left join edw.dws_hr_empe_inf_dd                t3      --员工信息汇总 empe_id 唯一
on  T1.wlth_mng_mnl_id=T3.empe_id
AND T3.DT='@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd        t4      --考核机构树 org_id 唯一
on      t1.wlth_mng_org_id = t4.org_id
and     t4.dt = '@@{yyyyMMdd}'
left join edw.dws_hr_empe_inf_dd                t5      --员工信息汇总 empe_id 唯一
on  T1.wlth_advsr_id=t5.empe_id
AND t5.DT='@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd        t6      --考核机构树 org_id 唯一
on      t5.org_id = t6.org_id
and     t6.dt = '@@{yyyyMMdd}'
left join TLDATA_DEV.SJXQ_SJ2023122536_CST_02   t7
on t1.cst_id=t7.cst_id
;

--单独6个客户账号存在问题的结果表
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_05 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_05 AS
SElECT distinct T2.CST_ID
    ,decode(t2.cst_ID,'1005819402','6214808801000219994'
        ,'1010462637','6221410010927516'
        ,'1033358485','6214808801006526087'
        ,'1013571060','6214808801002730675'
        ,'1031429255','6214808801002211874'
        ,'1034783949','6214808801005038407') cst_act_id
    ,t3.wlth_mng_mnl_id,t3.wlth_mng_org_id ,t3.wlth_advsr_id
    ,t5.sbr_org_nm prm_org_nm
    ,t4.prm_mgr_nm
from edw.dim_bus_dep_cst_act_inf_dd             t2  --客户存款账户信息 cst_act_id 唯一
LEFT JOIN edw.dim_bus_chm_fnd_cst_ctr_inf_dd    t3  --财富管户 财富顾问
on t2.cst_id=t3.cst_id
and t3.dt = '@@{yyyyMMdd}'
left join adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t4    --客户`主管户`信息 cst_id 唯一
on      t2.cst_id = t4.cst_id
and     t4.dt = '@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd t5             --考核机构树 org_id 唯一
on      t4.prm_org_id = t5.org_id
and     t5.dt = '@@{yyyyMMdd}'
where t2.dt='@@{yyyyMMdd}'
and t2.cst_ID in('1005819402' ,'1010462637' ,'1033358485' ,'1013571060' ,'1031429255' ,'1034783949')
;

DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_06 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_06 AS
SElECT DISTINCT t1.cst_ID   客户号
    ,t1.cst_act_id		    客户账号
    ,t2.act_nm              账户名称
    ,t2.gz_dt               挂账日期
    ,t2.gz_amt              挂账金额
    ,t8.dep_act_mng_mgr     存款账户管户人
    ,t8.dep_act_mng_org     存款账户管户支行
    ,t3.EMPE_NM             财富管户人
    ,t4.sbr_org_nm          财富管户支行
    ,t5.EMPE_NM             财富顾问
    ,t6.sbr_org_nm          财富顾问支行
    ,t1.prm_mgr_nm          主管户人
    ,t1.prm_org_nm          主管户支行
    ,t7.loan_mng_mgr        信贷管户人
    ,t7.loan_mng_org        信贷管户支行
    ,''                     账户状态
from TLDATA_DEV.SJXQ_SJ2023122536_CST_05        t1
left join TLDATA_DEV.SJXQ_SJ2023122536_CST_03   t2
on t1.cst_act_id=t2.cst_act_id
left join edw.dws_hr_empe_inf_dd                t3      --员工信息汇总 empe_id 唯一
on  T1.wlth_mng_mnl_id=T3.empe_id
AND T3.DT='@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd        t4      --考核机构树 org_id 唯一
on      t1.wlth_mng_org_id = t4.org_id
and     t4.dt = '@@{yyyyMMdd}'
left join edw.dws_hr_empe_inf_dd                t5      --员工信息汇总 empe_id 唯一
on  T1.wlth_advsr_id=t5.empe_id
AND t5.DT='@@{yyyyMMdd}'
left join edw.dim_hr_org_mng_org_tree_dd        t6      --考核机构树 org_id 唯一
on      t5.org_id = t6.org_id
and     t6.dt = '@@{yyyyMMdd}'
left join TLDATA_DEV.SJXQ_SJ2023122536_CST_02   t7
on t1.cst_id=t7.cst_id
left join (
    select cst_ID
        ,CONCAT_WS('|', COLLECT_SET(dep_act_mng_mgr))  dep_act_mng_mgr
        ,CONCAT_WS('|', COLLECT_SET(dep_act_mng_org))  dep_act_mng_org
    from TLDATA_DEV.SJXQ_SJ2023122536_CST_01
    group by cst_ID
)t8 on t1.cst_id=t8.cst_id
;


--输出结果
DROP   TABLE IF     EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_07 purge;
CREATE TABLE IF NOT EXISTS TLDATA_DEV.SJXQ_SJ2023122536_CST_07 AS
SElECT *
from TLDATA_DEV.SJXQ_SJ2023122536_CST_04
where 客户账号 not in (SElECT distinct 客户账号 from TLDATA_DEV.SJXQ_SJ2023122536_CST_06)
union all
SElECT *
from TLDATA_DEV.SJXQ_SJ2023122536_CST_06
;

SElECT *
from TLDATA_DEV.SJXQ_SJ2023122536_CST_07
;
/*
SElECT cst_id,wlth_mng_mnl_id,wlth_mng_mnl_org,wlth_mng_org_id
from app_rpt.adm_subl_cst_wlth_bus_inf_dd
where dt='@@{yyyyMMdd}'

SElECT '1' seq,count(1) cnt,count(DISTINCT cst_id,cst_act_id) custs
from TLDATA_DEV.SJXQ_SJ2023122536_CST_01
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT cst_ID) custs
from TLDATA_DEV.SJXQ_SJ2023122536_CST_02
union all
SElECT '3' seq,count(1) cnt,count(DISTINCT cst_act_id) custs
from TLDATA_DEV.SJXQ_SJ2023122536_CST_03
union all
SElECT '4' seq,count(1) cnt,count(DISTINCT 客户账号) custs
from TLDATA_DEV.SJXQ_SJ2023122536_CST_04
;
1	14407768	14407768
2	1798500	1798500
3	499	495
4	499	495
*/




,


**SJ20231228_贵金属购买明细.sql
--数据来源 下单日期	客户号	客户姓名	产品名称	供应商	产品类型	产品单价	购买数量	购买金额
--产品中收	推荐人工号	推荐人姓名	推荐人所属部门/团队id	推荐人所属部门/团队	分行名称	推荐人岗位

--2023年 贵金属购买信息汇总
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_01;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_01 AS
SElECT ord_id               --订单号
    ,ord_tm TRX_DT          --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc TRX_AMT --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'dtl' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di --贵金属交易明细表
where dt >= '20230101'
and ord_tm >= '2023-01-01'
union all
SElECT ord_id               --订单号
    ,ord_tm                 --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc       --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'hand' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_hand_di	--贵金属柜面或退款交易手工表
where dt >= '20230101'
and ord_tm >= '2023-01-01'
;

--是否贵金属新客（历史无交易）
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_02;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_02 AS
SElECT cst_id                 --客户号
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di     --贵金属交易明细表
where dt < '20230101'
and ord_tm < '2023-01-01'
union
SElECT cst_id                 --客户号
from adm_pub.adm_pub_cst_nob_met_trx_hand_di    --贵金属柜面或退款交易手工表
where dt < '20230101'
and ord_tm < '2023-01-01'
;

--客户年龄	客户性别 		是否23年新开卡客户
--客户23年存款日均	客户23年理财日均	客户财富等级		八大客群
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_03;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_03 AS
select t1.cst_id,t1.cst_chn_nm,t1.file_dt,t1.sam_rsk_ctrl_id
    ,decode(t2.cst_seg_flg,'1','企业主','2','个体工商户','3','企事业高管','4','非持牌个体户','5','工薪族','6','退休养老','7','持家女性','未知') cst_seg
    ,t3.age
    ,decode(t3.gdr_cd,'1','男','2','女','未知') gender
    ,t3.AUM_GRD,t3.dep_bal_year_avg,t3.fnc_year_avg_amt
    ,t3.efe_loan_cst_ind		-- 有效贷款户
from edw.dws_cst_bas_inf_dd 		            t1 	--客户基础信息汇总表
left join adm_pub.adm_csm_clab_cst_jc_inf_dd    t2  --客户标签信息
on t1.cst_id=t2.cst_id
and t2.dt='@@{yyyyMMdd}'
left join app_rpt.adm_subl_cst_wlth_bus_inf_dd 	t3  --正式客户财富业务信息表
on t1.cst_id=t3.cst_id
and t3.dt='@@{yyyyMMdd}'
where t1.dt='@@{yyyyMMdd}'
;

--客户历史保险金额
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_04;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_04 AS
SElECT cst_id,sum(insu_fee) his_insu_fee
from edw.dwd_bus_insu_plcy_insu_inf_dd
where dt ='@@{yyyyMMdd}'
and insu_dt < '20230101'
and INSU_PLCY_STS in ('0','1','A') --'正常','退保','满期退保'
group by cst_id
;

--是否同一风险控制号信贷户
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_05;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_05 AS
SELECT T1.CST_ID,T1.sam_rsk_ctrl_id,MAX(T3.efe_loan_cst_ind) is_vld_loan
FROM SJXQ_SJ20231228_CST0_03         T1
INNER join (
    select distinct cst_id
    from SJXQ_SJ20231228_CST0_01
) t2 on t1.cst_id=t2.cst_id
LEFT JOIN SJXQ_SJ20231228_CST0_03    T3
ON T1.sam_rsk_ctrl_id=T3.sam_rsk_ctrl_id
where nvl(t1.sam_rsk_ctrl_id,'')<>''        --不限制会跑不出来
GROUP BY T1.CST_ID,T1.sam_rsk_ctrl_id
;

DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_05_1;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_05_1 AS
select t1.sam_rsk_ctrl_id,max(t2.efe_loan_cst_ind) is_vld_loan --是否同一风险控制号信贷户
from(
	select distinct sam_rsk_ctrl_id
	from SJXQ_SJ20231228_CST0_03
    where nvl(sam_rsk_ctrl_id,'')<>''       --不限制会跑不出来
)t1 left join SJXQ_SJ20231228_CST0_03 t2
on t1.sam_rsk_ctrl_id=t2.sam_rsk_ctrl_id
group by t1.sam_rsk_ctrl_id
;

--统一风险控制客户
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_05_2;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_05_2 AS
select t1.cst_id
from SJXQ_SJ20231228_CST0_03 		t1
left join SJXQ_SJ20231228_CST0_05_1 	t2
on t1.sam_rsk_ctrl_id=t2.sam_rsk_ctrl_id
where t2.is_vld_loan='1'
;


--字段汇总
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST0_06;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST0_06 AS
SElECT t1.data_src				数据来源
    ,t1.trx_dt                  下单日期
    ,t1.cst_id                  客户号
    ,t1.cst_nm                  客户姓名
    ,t1.cmdt_nm                 产品名称
    ,t1.pvd_nm                  供应商
    ,t1.goods_typ               产品类型
    ,t1.cmdt_unt_prc            产品单价
    ,t1.qty                     购买数量
    ,t1.trx_amt                 购买金额
    ,t1.mid_inc_tot_amt         产品中收
    ,t1.rcm_psn_id              推荐人工号
    ,t1.rcm_psn_nm              推荐人姓名
    ,t1.rcm_psn_afl_dept_id     推荐人所属部门_团队id
    ,t1.rcm_psn_afl_dept        推荐人所属部门_团队
    ,t1.rcm_psn_afl_brn         分行名称
    ,t1.rcm_psn_pos             推荐人岗位
    ,t3.dep_bal_year_avg        客户23年存款日均
    ,t3.fnc_year_avg_amt        客户23年理财日均
    ,t3.AUM_GRD                 客户财富等级
    ,t4.his_insu_fee            客户历史保险保费
    ,t3.cst_seg                 八大客群
    ,t3.age                     客户年龄
    ,case when t5.cst_id is not null then 1 else 0 end  是否同一风险控制号信贷户
    ,t3.gender                  客户性别
    ,case when t3.file_dt>='20230101' then 1 else 0 end 是否23年新开卡客户
    ,case when t2.cst_id is null then 1 else 0 end      是否贵金属新客_历史无交易
from SJXQ_SJ20231228_CST0_01         t1
left join SJXQ_SJ20231228_CST0_02    t2 on t1.cst_id=t2.cst_id
left join SJXQ_SJ20231228_CST0_03    t3 on t1.cst_id=t3.cst_id
left join SJXQ_SJ20231228_CST0_04    t4 on t1.cst_id=t4.cst_id
left join SJXQ_SJ20231228_CST0_05_2  t5 on t1.cst_id=t5.cst_id
;

/*
SElECT '1' seq,count(1) cnt,count(DISTINCT cst_id) custs
from SJXQ_SJ20231228_CST0_01
union all
SElECT '2' seq,count(1) cnt,count(DISTINCT cst_id) custs
from SJXQ_SJ20231228_CST0_02
union all
SElECT '3' seq,count(1) cnt,count(DISTINCT cst_id) custs
from SJXQ_SJ20231228_CST0_03
union all
SElECT '4' seq,count(1) cnt,count(DISTINCT cst_id) custs
from SJXQ_SJ20231228_CST0_04
union all
SElECT '5' seq,count(1) cnt,count(DISTINCT cst_id) custs
from SJXQ_SJ20231228_CST0_05_2
union all
SElECT '6' seq,count(1) cnt,count(DISTINCT 客户号) custs
from SJXQ_SJ20231228_CST0_06
;
1	20788	14334
2	13404	13404
3	16052074	16052074
4	27363	27363
5	1215423	1215423
6	20788	14334

*/
**SJ20231229001_保险考核拆解2023管护人预测底表_机构汇总.sql

-- tbl1_所有员工表信息表
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 AS
SELECT  t1.empe_id
        ,t1.empe_nm 姓名
        ,t2.pos_nm 岗位
        ,INT(t1.srv_mon_tot / 12) 入行年限
        ,t1.empe_age 年龄
        ,CASE t1.hi_acdm_rcd_cd
           WHEN '10' THEN '研究生教育'
           WHEN '11' THEN '博士研究生毕业'
           WHEN '12' THEN '博士研究生结业'
           WHEN '13' THEN '博士研究生肄业'
           WHEN '14' THEN '硕士研究生毕业'
           WHEN '15' THEN '硕士研究生结业'
           WHEN '16' THEN '硕士研究生肄业'
           WHEN '17' THEN '研究生班毕业'
           WHEN '18' THEN '研究生班结业'
           WHEN '19' THEN '研究生班肄业'
           WHEN '20' THEN '大学本科教育'
           WHEN '21' THEN '大学本科毕业'
           WHEN '22' THEN '大学本科结业'
           WHEN '23' THEN '大学本科肄业'
           WHEN '28' THEN '大学普通班毕业'
           WHEN '30' THEN '大学专科教育'
           WHEN '31' THEN '大学专科毕业'
           WHEN '32' THEN '大学专科结业'
           WHEN '33' THEN '大学专科肄业'
           WHEN '40' THEN '中等职业教育'
           WHEN '41' THEN '中等专科毕业'
           WHEN '42' THEN '中等专科结业'
           WHEN '43' THEN '中等专科肄业'
           WHEN '44' THEN '职业高中毕业'
           WHEN '45' THEN '职业高中结业'
           WHEN '46' THEN '职业高中肄业'
           WHEN '47' THEN '技工学院毕业'
           WHEN '48' THEN '技工学院结业'
           WHEN '49' THEN '技工学院肄业'
           WHEN '60' THEN '普通高级中学教育'
           WHEN '61' THEN '普通高中毕业'
           WHEN '62' THEN '普通高中结业'
           WHEN '63' THEN '普通高中肄业'
           WHEN '70' THEN '初级中学教育'
           WHEN '71' THEN '初中毕业'
           WHEN '73' THEN '初中肄业'
           WHEN '80' THEN '小学教育'
           WHEN '81' THEN '小学毕业'
           WHEN '83' THEN '小学肄业'
           WHEN '90' THEN '文盲或半文盲'
           WHEN '98' THEN '未知'
           WHEN '99' THEN '其他'
         END 学历
        ,t3.brc_org_nm 所在分行
        ,t3.sbr_org_nm 所在支行
        ,t3.tem_org_nm 所在团队
FROM    edw.dws_hr_empe_inf_dd t1
LEFT JOIN    edw.dim_hr_org_job_inf_dd t2
ON      t1.pos_enc = t2.pos_id
AND     t2.dt = '20221231'
LEFT JOIN    edw.dim_hr_org_mng_org_tree_dd t3
ON      t1.org_id = t3.org_id
AND     t3.dt = '20221231'
WHERE   t2.pos_nm IN ( '客户经理' , '服务经理' , '理财经理' , '营业经理' , '业务团队正职' , '业务团队副职' , '支行班子正职' , '支行班子副职' )
AND     t1.dt = '20221231'
AND     t1.EMPE_STS_CD = '2' --在职
AND     (t3.brc_org_nm LIKE '%分行%' or t3.brc_org_nm LIKE '%总行%')
;
-- 8401


--tbl2_客户基础信息表
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_cst_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_cst_01 AS
SELECT  t1.cst_id 客户号
        ,t1.prm_mgr_id 主管护人工号
        ,t1.prm_mgr_nm 主管护人名称
        ,t1.prm_org_id 主管护机构号
        ,t1.prm_org_nm 主管护机构名称
        ,t2.efe_dep_cst_ind 有效存款户
        ,t2.efe_wlth_cst_ind 财富有效户
        ,t2.age 年龄
        ,t2.aum_bal AUM
        ,decode(t3.cst_seg_flg, '1', '企业主', '2', '个体工商户', '3', '企事业高管', '4', '非持牌个体户', '5', '工薪族', '6', '退休养老', '7', '持家女性', '其他') 客群标签
FROM    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t1
LEFT JOIN    app_rpt.adm_subl_cst_wlth_bus_inf_dd t2 --正式客户财富业务信息表
ON      t1.cst_id = t2.cst_id
AND     t2.dt = '20221231'
LEFT JOIN    adm_pub.adm_csm_clab_cst_jc_inf_dd t3 --客户标签信息
ON      t1.cst_id = t3.cst_id
AND     t3.dt = '20221231'
WHERE   t1.dt = '20221231'
AND     t2.age >= 30
AND     t2.age <= 65 --年龄限制
AND     ( t2.efe_dep_cst_ind = '1' OR t2.efe_wlth_cst_ind = '1' ) --存款有效户or财富有效户
;
--934891


--tbl3_2024预测1
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_01 AS
SELECT t1.empe_id 工号
,COUNT(T2.客户号)   CUSTS
-- AUM >= 50000
,count(if(t2.AUM >= 50000, t2.客户号,null))                                  AUM大于等于5万_户数_所有客户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.客户号,null))       AUM大于等于5万_户数_企业主
,count(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.客户号,null))   AUM大于等于5万_户数_个体工商户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) AUM大于等于5万_户数_非持牌个体户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.客户号,null))       AUM大于等于5万_户数_工薪族
,count(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.客户号,null))     AUM大于等于5万_户数_退休养老
,count(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.客户号,null))     AUM大于等于5万_户数_持家女性
,count(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) AUM大于等于5万_户数_其他
,sum(if(t2.AUM >= 50000, t2.AUM,0))                                          AUM大于等于5万_规模_所有客户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.AUM,0))               AUM大于等于5万_规模_企业主
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.AUM,0))           AUM大于等于5万_规模_个体工商户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         AUM大于等于5万_规模_非持牌个体户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.AUM,0))               AUM大于等于5万_规模_工薪族
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.AUM,0))             AUM大于等于5万_规模_退休养老
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.AUM,0))             AUM大于等于5万_规模_持家女性
,sum(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) AUM大于等于5万_规模_其他
-- AUM >= 10000
,count(if(t2.AUM >= 10000, t2.客户号,null))                                  AUM大于等于1万_户数_所有客户
,count(if(t2.AUM >= 10000 and t2.客群标签 = '企业主', t2.客户号,null))       AUM大于等于1万_户数_企业主
,count(if(t2.AUM >= 10000 and t2.客群标签 = '个体工商户', t2.客户号,null))   AUM大于等于1万_户数_个体工商户
,count(if(t2.AUM >= 10000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) AUM大于等于1万_户数_非持牌个体户
,count(if(t2.AUM >= 10000 and t2.客群标签 = '工薪族', t2.客户号,null))       AUM大于等于1万_户数_工薪族
,count(if(t2.AUM >= 10000 and t2.客群标签 = '退休养老', t2.客户号,null))     AUM大于等于1万_户数_退休养老
,count(if(t2.AUM >= 10000 and t2.客群标签 = '持家女性', t2.客户号,null))     AUM大于等于1万_户数_持家女性
,count(if(t2.AUM >= 10000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) AUM大于等于1万_户数_其他
,sum(if(t2.AUM >= 10000, t2.AUM,0))                                          AUM大于等于1万_规模_所有客户
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '企业主', t2.AUM,0))               AUM大于等于1万_规模_企业主
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '个体工商户', t2.AUM,0))           AUM大于等于1万_规模_个体工商户
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         AUM大于等于1万_规模_非持牌个体户
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '工薪族', t2.AUM,0))               AUM大于等于1万_规模_工薪族
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '退休养老', t2.AUM,0))             AUM大于等于1万_规模_退休养老
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '持家女性', t2.AUM,0))             AUM大于等于1万_规模_持家女性
,sum(if(t2.AUM >= 10000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) AUM大于等于1万_规模_其他
-- AUM >= 10000 AND t2.AUM < 50000
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000, t2.客户号,null))                                  AUM大于等于1万小于5万_户数_所有客户
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '企业主', t2.客户号,null))       AUM大于等于1万小于5万_户数_企业主
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '个体工商户', t2.客户号,null))   AUM大于等于1万小于5万_户数_个体工商户
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) AUM大于等于1万小于5万_户数_非持牌个体户
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '工薪族', t2.客户号,null))       AUM大于等于1万小于5万_户数_工薪族
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '退休养老', t2.客户号,null))     AUM大于等于1万小于5万_户数_退休养老
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '持家女性', t2.客户号,null))     AUM大于等于1万小于5万_户数_持家女性
,count(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) AUM大于等于1万小于5万_户数_其他
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000, t2.AUM,0))                                          AUM大于等于1万小于5万_规模_所有客户
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '企业主', t2.AUM,0))               AUM大于等于1万小于5万_规模_企业主
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '个体工商户', t2.AUM,0))           AUM大于等于1万小于5万_规模_个体工商户
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         AUM大于等于1万小于5万_规模_非持牌个体户
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '工薪族', t2.AUM,0))               AUM大于等于1万小于5万_规模_工薪族
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '退休养老', t2.AUM,0))             AUM大于等于1万小于5万_规模_退休养老
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 = '持家女性', t2.AUM,0))             AUM大于等于1万小于5万_规模_持家女性
,sum(if(t2.AUM >= 10000 AND t2.AUM < 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) AUM大于等于1万小于5万_规模_其他
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 t1 -- tbl1_所有员工表信息表
left JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_cst_01 t2 --tbl2_客户基础信息表
on t1.empe_id = t2.主管护人工号
GROUP BY t1.empe_id
;


--tbl4_2024预测2
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_02 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_02 AS
SELECT  T.*,T1.*
FROM    LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 T
LEFT JOIN    LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_01 T1
ON      T.empe_id = T1.工号
;


DROP    TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_03 PURGE;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_03 AS
SElECT t1.所在分行
    ,sum(AUM大于等于5万_户数_所有客户		) AUM大于等于5万_户数_所有客户
	,sum(AUM大于等于5万_户数_企业主         ) AUM大于等于5万_户数_企业主
	,sum(AUM大于等于5万_户数_个体工商户     ) AUM大于等于5万_户数_个体工商户
	,sum(AUM大于等于5万_户数_非持牌个体户   ) AUM大于等于5万_户数_非持牌个体户
	,sum(AUM大于等于5万_户数_工薪族         ) AUM大于等于5万_户数_工薪族
	,sum(AUM大于等于5万_户数_退休养老       ) AUM大于等于5万_户数_退休养老
	,sum(AUM大于等于5万_户数_持家女性       ) AUM大于等于5万_户数_持家女性
	,sum(AUM大于等于5万_户数_其他)    		  AUM大于等于5万_户数_其他
    ,sum(AUM大于等于5万_规模_所有客户		) AUM大于等于5万_规模_所有客户
	,sum(AUM大于等于5万_规模_企业主         ) AUM大于等于5万_规模_企业主
	,sum(AUM大于等于5万_规模_个体工商户     ) AUM大于等于5万_规模_个体工商户
	,sum(AUM大于等于5万_规模_非持牌个体户   ) AUM大于等于5万_规模_非持牌个体户
	,sum(AUM大于等于5万_规模_工薪族         ) AUM大于等于5万_规模_工薪族
	,sum(AUM大于等于5万_规模_退休养老       ) AUM大于等于5万_规模_退休养老
	,sum(AUM大于等于5万_规模_持家女性       ) AUM大于等于5万_规模_持家女性
	,sum(AUM大于等于5万_规模_其他) 		      AUM大于等于5万_规模_其他

    ,sum(AUM大于等于1万_户数_所有客户		) AUM大于等于1万_户数_所有客户
	,sum(AUM大于等于1万_户数_企业主         ) AUM大于等于1万_户数_企业主
	,sum(AUM大于等于1万_户数_个体工商户     ) AUM大于等于1万_户数_个体工商户
	,sum(AUM大于等于1万_户数_非持牌个体户   ) AUM大于等于1万_户数_非持牌个体户
	,sum(AUM大于等于1万_户数_工薪族         ) AUM大于等于1万_户数_工薪族
	,sum(AUM大于等于1万_户数_退休养老       ) AUM大于等于1万_户数_退休养老
	,sum(AUM大于等于1万_户数_持家女性       ) AUM大于等于1万_户数_持家女性
	,sum(AUM大于等于1万_户数_其他)    		  AUM大于等于1万_户数_其他
    ,sum(AUM大于等于1万_规模_所有客户		) AUM大于等于1万_规模_所有客户
	,sum(AUM大于等于1万_规模_企业主         ) AUM大于等于1万_规模_企业主
	,sum(AUM大于等于1万_规模_个体工商户     ) AUM大于等于1万_规模_个体工商户
	,sum(AUM大于等于1万_规模_非持牌个体户   ) AUM大于等于1万_规模_非持牌个体户
	,sum(AUM大于等于1万_规模_工薪族         ) AUM大于等于1万_规模_工薪族
	,sum(AUM大于等于1万_规模_退休养老       ) AUM大于等于1万_规模_退休养老
	,sum(AUM大于等于1万_规模_持家女性       ) AUM大于等于1万_规模_持家女性
	,sum(AUM大于等于1万_规模_其他) 		      AUM大于等于1万_规模_其他
from LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2023yuce_02 T1
where 岗位 in ( '客户经理' , '服务经理' ,'营业经理' , '业务团队正职' , '业务团队副职'  )-- '理财经理' , , '支行班子正职' , '支行班子副职'
GROUP by t1.所在分行
;


**SJ20231229001_保险考核拆解2024管护人预测底表_机构汇总.sql

-- tbl1_所有员工表信息表
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 AS
SELECT  t1.empe_id
        ,t1.empe_nm 姓名
        ,t2.pos_nm 岗位
        ,INT(t1.srv_mon_tot / 12) 入行年限
        ,t1.empe_age 年龄
        ,CASE t1.hi_acdm_rcd_cd
           WHEN '10' THEN '研究生教育'
           WHEN '11' THEN '博士研究生毕业'
           WHEN '12' THEN '博士研究生结业'
           WHEN '13' THEN '博士研究生肄业'
           WHEN '14' THEN '硕士研究生毕业'
           WHEN '15' THEN '硕士研究生结业'
           WHEN '16' THEN '硕士研究生肄业'
           WHEN '17' THEN '研究生班毕业'
           WHEN '18' THEN '研究生班结业'
           WHEN '19' THEN '研究生班肄业'
           WHEN '20' THEN '大学本科教育'
           WHEN '21' THEN '大学本科毕业'
           WHEN '22' THEN '大学本科结业'
           WHEN '23' THEN '大学本科肄业'
           WHEN '28' THEN '大学普通班毕业'
           WHEN '30' THEN '大学专科教育'
           WHEN '31' THEN '大学专科毕业'
           WHEN '32' THEN '大学专科结业'
           WHEN '33' THEN '大学专科肄业'
           WHEN '40' THEN '中等职业教育'
           WHEN '41' THEN '中等专科毕业'
           WHEN '42' THEN '中等专科结业'
           WHEN '43' THEN '中等专科肄业'
           WHEN '44' THEN '职业高中毕业'
           WHEN '45' THEN '职业高中结业'
           WHEN '46' THEN '职业高中肄业'
           WHEN '47' THEN '技工学院毕业'
           WHEN '48' THEN '技工学院结业'
           WHEN '49' THEN '技工学院肄业'
           WHEN '60' THEN '普通高级中学教育'
           WHEN '61' THEN '普通高中毕业'
           WHEN '62' THEN '普通高中结业'
           WHEN '63' THEN '普通高中肄业'
           WHEN '70' THEN '初级中学教育'
           WHEN '71' THEN '初中毕业'
           WHEN '73' THEN '初中肄业'
           WHEN '80' THEN '小学教育'
           WHEN '81' THEN '小学毕业'
           WHEN '83' THEN '小学肄业'
           WHEN '90' THEN '文盲或半文盲'
           WHEN '98' THEN '未知'
           WHEN '99' THEN '其他'
         END 学历
        ,t3.brc_org_nm 所在分行
        ,t3.sbr_org_nm 所在支行
        ,t3.tem_org_nm 所在团队
FROM    edw.dws_hr_empe_inf_dd t1
LEFT JOIN    edw.dim_hr_org_job_inf_dd t2
ON      t1.pos_enc = t2.pos_id
AND     t2.dt = '20231228'
LEFT JOIN    edw.dim_hr_org_mng_org_tree_dd t3
ON      t1.org_id = t3.org_id
AND     t3.dt = '20231228'
WHERE   t2.pos_nm IN ( '客户经理' , '服务经理' , '理财经理' , '营业经理' , '业务团队正职' , '业务团队副职' , '支行班子正职' , '支行班子副职' )
AND     t1.dt = '20231228'
AND     t1.EMPE_STS_CD = '2' --在职
AND     (t3.brc_org_nm LIKE '%分行%' or t3.brc_org_nm LIKE '%总行%')
;
-- 8401


--tbl2_客户基础信息表
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_cst_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_cst_01 AS
SELECT  t1.cst_id 客户号
        ,t1.prm_mgr_id 主管护人工号
        ,t1.prm_mgr_nm 主管护人名称
        ,t1.prm_org_id 主管护机构号
        ,t1.prm_org_nm 主管护机构名称
        ,t2.efe_dep_cst_ind 有效存款户
        ,t2.efe_wlth_cst_ind 财富有效户
        ,t2.age 年龄
        ,t2.aum_bal AUM
        ,decode(t3.cst_seg_flg, '1', '企业主', '2', '个体工商户', '3', '企事业高管', '4', '非持牌个体户', '5', '工薪族', '6', '退休养老', '7', '持家女性', '其他') 客群标签
FROM    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t1
LEFT JOIN    app_rpt.adm_subl_cst_wlth_bus_inf_dd t2 --正式客户财富业务信息表
ON      t1.cst_id = t2.cst_id
AND     t2.dt = '20231228'
LEFT JOIN    adm_pub.adm_csm_clab_cst_jc_inf_dd t3 --客户标签信息
ON      t1.cst_id = t3.cst_id
AND     t3.dt = '20231228'
WHERE   t1.dt = '20231228'
AND     t2.age >= 30
AND     t2.age <= 65 --年龄限制
AND     ( t2.efe_dep_cst_ind = '1' OR t2.efe_wlth_cst_ind = '1' ) --存款有效户or财富有效户
;
--934891


--tbl3_2024预测1
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_01 AS
SELECT t1.empe_id 工号
,COUNT(T2.客户号)   CUSTS
-- AUM >= 50000
,count(if(t2.AUM >= 50000, t2.客户号,null))                                  AUM大于等于5万_户数_所有客户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.客户号,null))       AUM大于等于5万_户数_企业主
,count(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.客户号,null))   AUM大于等于5万_户数_个体工商户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) AUM大于等于5万_户数_非持牌个体户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.客户号,null))       AUM大于等于5万_户数_工薪族
,count(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.客户号,null))     AUM大于等于5万_户数_退休养老
,count(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.客户号,null))     AUM大于等于5万_户数_持家女性
,count(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) AUM大于等于5万_户数_其他
,sum(if(t2.AUM >= 50000, t2.AUM,0))                                          AUM大于等于5万_规模_所有客户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.AUM,0))               AUM大于等于5万_规模_企业主
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.AUM,0))           AUM大于等于5万_规模_个体工商户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         AUM大于等于5万_规模_非持牌个体户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.AUM,0))               AUM大于等于5万_规模_工薪族
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.AUM,0))             AUM大于等于5万_规模_退休养老
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.AUM,0))             AUM大于等于5万_规模_持家女性
,sum(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) AUM大于等于5万_规模_其他
-- AUM >= 10000
,count(if(t2.AUM >= 10000, t2.客户号,null))                                  AUM大于等于1万_户数_所有客户
,count(if(t2.AUM >= 10000 and t2.客群标签 = '企业主', t2.客户号,null))       AUM大于等于1万_户数_企业主
,count(if(t2.AUM >= 10000 and t2.客群标签 = '个体工商户', t2.客户号,null))   AUM大于等于1万_户数_个体工商户
,count(if(t2.AUM >= 10000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) AUM大于等于1万_户数_非持牌个体户
,count(if(t2.AUM >= 10000 and t2.客群标签 = '工薪族', t2.客户号,null))       AUM大于等于1万_户数_工薪族
,count(if(t2.AUM >= 10000 and t2.客群标签 = '退休养老', t2.客户号,null))     AUM大于等于1万_户数_退休养老
,count(if(t2.AUM >= 10000 and t2.客群标签 = '持家女性', t2.客户号,null))     AUM大于等于1万_户数_持家女性
,count(if(t2.AUM >= 10000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) AUM大于等于1万_户数_其他
,sum(if(t2.AUM >= 10000, t2.AUM,0))                                          AUM大于等于1万_规模_所有客户
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '企业主', t2.AUM,0))               AUM大于等于1万_规模_企业主
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '个体工商户', t2.AUM,0))           AUM大于等于1万_规模_个体工商户
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         AUM大于等于1万_规模_非持牌个体户
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '工薪族', t2.AUM,0))               AUM大于等于1万_规模_工薪族
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '退休养老', t2.AUM,0))             AUM大于等于1万_规模_退休养老
,sum(if(t2.AUM >= 10000 and t2.客群标签 = '持家女性', t2.AUM,0))             AUM大于等于1万_规模_持家女性
,sum(if(t2.AUM >= 10000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) AUM大于等于1万_规模_其他

FROM LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 t1 -- tbl1_所有员工表信息表
left JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_cst_01 t2 --tbl2_客户基础信息表
on t1.empe_id = t2.主管护人工号
GROUP BY t1.empe_id
;


--tbl4_2024预测2
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_02 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_02 AS
SELECT  T.*,T1.*
FROM    LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 T
LEFT JOIN    LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_01 T1
ON      T.empe_id = T1.工号
;


DROP    TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_03 PURGE;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_03 AS
SElECT t1.所在分行
    ,sum(AUM大于等于5万_户数_所有客户		) AUM大于等于5万_户数_所有客户
	,sum(AUM大于等于5万_户数_企业主         ) AUM大于等于5万_户数_企业主
	,sum(AUM大于等于5万_户数_个体工商户     ) AUM大于等于5万_户数_个体工商户
	,sum(AUM大于等于5万_户数_非持牌个体户   ) AUM大于等于5万_户数_非持牌个体户
	,sum(AUM大于等于5万_户数_工薪族         ) AUM大于等于5万_户数_工薪族
	,sum(AUM大于等于5万_户数_退休养老       ) AUM大于等于5万_户数_退休养老
	,sum(AUM大于等于5万_户数_持家女性       ) AUM大于等于5万_户数_持家女性
	,sum(AUM大于等于5万_户数_其他)    		  AUM大于等于5万_户数_其他
    ,sum(AUM大于等于5万_规模_所有客户		) AUM大于等于5万_规模_所有客户
	,sum(AUM大于等于5万_规模_企业主         ) AUM大于等于5万_规模_企业主
	,sum(AUM大于等于5万_规模_个体工商户     ) AUM大于等于5万_规模_个体工商户
	,sum(AUM大于等于5万_规模_非持牌个体户   ) AUM大于等于5万_规模_非持牌个体户
	,sum(AUM大于等于5万_规模_工薪族         ) AUM大于等于5万_规模_工薪族
	,sum(AUM大于等于5万_规模_退休养老       ) AUM大于等于5万_规模_退休养老
	,sum(AUM大于等于5万_规模_持家女性       ) AUM大于等于5万_规模_持家女性
	,sum(AUM大于等于5万_规模_其他) 		      AUM大于等于5万_规模_其他

    ,sum(AUM大于等于1万_户数_所有客户		) AUM大于等于1万_户数_所有客户
	,sum(AUM大于等于1万_户数_企业主         ) AUM大于等于1万_户数_企业主
	,sum(AUM大于等于1万_户数_个体工商户     ) AUM大于等于1万_户数_个体工商户
	,sum(AUM大于等于1万_户数_非持牌个体户   ) AUM大于等于1万_户数_非持牌个体户
	,sum(AUM大于等于1万_户数_工薪族         ) AUM大于等于1万_户数_工薪族
	,sum(AUM大于等于1万_户数_退休养老       ) AUM大于等于1万_户数_退休养老
	,sum(AUM大于等于1万_户数_持家女性       ) AUM大于等于1万_户数_持家女性
	,sum(AUM大于等于1万_户数_其他)    		  AUM大于等于1万_户数_其他
    ,sum(AUM大于等于1万_规模_所有客户		) AUM大于等于1万_规模_所有客户
	,sum(AUM大于等于1万_规模_企业主         ) AUM大于等于1万_规模_企业主
	,sum(AUM大于等于1万_规模_个体工商户     ) AUM大于等于1万_规模_个体工商户
	,sum(AUM大于等于1万_规模_非持牌个体户   ) AUM大于等于1万_规模_非持牌个体户
	,sum(AUM大于等于1万_规模_工薪族         ) AUM大于等于1万_规模_工薪族
	,sum(AUM大于等于1万_规模_退休养老       ) AUM大于等于1万_规模_退休养老
	,sum(AUM大于等于1万_规模_持家女性       ) AUM大于等于1万_规模_持家女性
	,sum(AUM大于等于1万_规模_其他) 		      AUM大于等于1万_规模_其他
from LAB_BIGDATA_DEV.SJXQ_SJ20231229001_2024yuce_02 T1
where 岗位 in ( '客户经理' , '服务经理' ,'营业经理' , '业务团队正职' , '业务团队副职'  ) --汇总到分行岗位限制
GROUP by t1.所在分行
;


**SJ20231229002_贵金属考核拆解2023管护人预测底表_机构汇总.sql
-- tbl1_所有员工表信息表（保险贵金属通用）
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 AS
SELECT  t1.empe_id
        ,t1.empe_nm 姓名
        ,t2.pos_nm 岗位
        ,INT(t1.srv_mon_tot / 12) 入行年限
        ,t1.empe_age 年龄
        ,CASE t1.hi_acdm_rcd_cd
           WHEN '10' THEN '研究生教育'
           WHEN '11' THEN '博士研究生毕业'
           WHEN '12' THEN '博士研究生结业'
           WHEN '13' THEN '博士研究生肄业'
           WHEN '14' THEN '硕士研究生毕业'
           WHEN '15' THEN '硕士研究生结业'
           WHEN '16' THEN '硕士研究生肄业'
           WHEN '17' THEN '研究生班毕业'
           WHEN '18' THEN '研究生班结业'
           WHEN '19' THEN '研究生班肄业'
           WHEN '20' THEN '大学本科教育'
           WHEN '21' THEN '大学本科毕业'
           WHEN '22' THEN '大学本科结业'
           WHEN '23' THEN '大学本科肄业'
           WHEN '28' THEN '大学普通班毕业'
           WHEN '30' THEN '大学专科教育'
           WHEN '31' THEN '大学专科毕业'
           WHEN '32' THEN '大学专科结业'
           WHEN '33' THEN '大学专科肄业'
           WHEN '40' THEN '中等职业教育'
           WHEN '41' THEN '中等专科毕业'
           WHEN '42' THEN '中等专科结业'
           WHEN '43' THEN '中等专科肄业'
           WHEN '44' THEN '职业高中毕业'
           WHEN '45' THEN '职业高中结业'
           WHEN '46' THEN '职业高中肄业'
           WHEN '47' THEN '技工学院毕业'
           WHEN '48' THEN '技工学院结业'
           WHEN '49' THEN '技工学院肄业'
           WHEN '60' THEN '普通高级中学教育'
           WHEN '61' THEN '普通高中毕业'
           WHEN '62' THEN '普通高中结业'
           WHEN '63' THEN '普通高中肄业'
           WHEN '70' THEN '初级中学教育'
           WHEN '71' THEN '初中毕业'
           WHEN '73' THEN '初中肄业'
           WHEN '80' THEN '小学教育'
           WHEN '81' THEN '小学毕业'
           WHEN '83' THEN '小学肄业'
           WHEN '90' THEN '文盲或半文盲'
           WHEN '98' THEN '未知'
           WHEN '99' THEN '其他'
         END 学历
        ,t3.brc_org_nm 所在分行
        ,t3.sbr_org_nm 所在支行
        ,t3.tem_org_nm 所在团队
FROM    edw.dws_hr_empe_inf_dd t1
LEFT JOIN    edw.dim_hr_org_job_inf_dd t2
ON      t1.pos_enc = t2.pos_id
AND     t2.dt = '20221231'
LEFT JOIN    edw.dim_hr_org_mng_org_tree_dd t3
ON      t1.org_id = t3.org_id
AND     t3.dt = '20221231'
WHERE   t2.pos_nm IN ( '客户经理' , '服务经理' , '理财经理' , '营业经理' , '业务团队正职' , '业务团队副职' , '支行班子正职' , '支行班子副职' )
AND     t1.dt = '20221231'
AND     t1.EMPE_STS_CD = '2' --在职
AND     (t3.brc_org_nm LIKE '%分行%' or t3.brc_org_nm LIKE '%总行%')
;
-- 8401


--tbl2_客户基础信息表
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_all2022_cst_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_all2022_cst_01 AS
SELECT  t1.cst_id 客户号
        ,t1.prm_mgr_id 主管护人工号
        ,t1.prm_mgr_nm 主管护人名称
        ,t1.prm_org_id 主管护机构号
        ,t1.prm_org_nm 主管护机构名称
        ,t2.efe_dep_cst_ind 有效存款户
        ,t2.efe_wlth_cst_ind 财富有效户
        ,t2.age 年龄
        ,t2.aum_bal AUM
        ,decode(t3.cst_seg_flg, '1', '企业主', '2', '个体工商户', '3', '企事业高管', '4', '非持牌个体户', '5', '工薪族', '6', '退休养老', '7', '持家女性', '其他') 客群标签
FROM    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t1
LEFT JOIN    app_rpt.adm_subl_cst_wlth_bus_inf_dd t2 --正式客户财富业务信息表
ON      t1.cst_id = t2.cst_id
AND     t2.dt = '20221231'
LEFT JOIN    adm_pub.adm_csm_clab_cst_jc_inf_dd t3 --客户标签信息
ON      t1.cst_id = t3.cst_id
AND     t3.dt = '20221231'
WHERE   t1.dt = '20221231'
AND     t2.age >= 25
AND     t2.age <= 80 --年龄限制
AND     ( t2.efe_dep_cst_ind = '1' OR t2.efe_wlth_cst_ind = '1' ) --存款有效户or财富有效户
;
--1272368




--tbl3_2024预测1
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_01 AS
SELECT t1.empe_id 工号
-- AUM >= 300000
,count(if(t2.AUM >= 300000, t2.客户号,null))                                  投资金_AUM大于等于30万_户数_所有客户
,count(if(t2.AUM >= 300000 and t2.客群标签 = '企业主', t2.客户号,null))       投资金_AUM大于等于30万_户数_企业主
,count(if(t2.AUM >= 300000 and t2.客群标签 = '个体工商户', t2.客户号,null))   投资金_AUM大于等于30万_户数_个体工商户
,count(if(t2.AUM >= 300000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) 投资金_AUM大于等于30万_户数_非持牌个体户
,count(if(t2.AUM >= 300000 and t2.客群标签 = '工薪族', t2.客户号,null))       投资金_AUM大于等于30万_户数_工薪族
,count(if(t2.AUM >= 300000 and t2.客群标签 = '退休养老', t2.客户号,null))     投资金_AUM大于等于30万_户数_退休养老
,count(if(t2.AUM >= 300000 and t2.客群标签 = '持家女性', t2.客户号,null))     投资金_AUM大于等于30万_户数_持家女性
,count(if(t2.AUM >= 300000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) 投资金_AUM大于等于30万_户数_其他
,sum(if(t2.AUM >= 300000, t2.AUM,0))                                          投资金_AUM大于等于30万_规模_所有客户
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '企业主', t2.AUM,0))               投资金_AUM大于等于30万_规模_企业主
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '个体工商户', t2.AUM,0))           投资金_AUM大于等于30万_规模_个体工商户
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         投资金_AUM大于等于30万_规模_非持牌个体户
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '工薪族', t2.AUM,0))               投资金_AUM大于等于30万_规模_工薪族
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '退休养老', t2.AUM,0))             投资金_AUM大于等于30万_规模_退休养老
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '持家女性', t2.AUM,0))             投资金_AUM大于等于30万_规模_持家女性
,sum(if(t2.AUM >= 300000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) 投资金_AUM大于等于30万_规模_其他
-- AUM >= 50000
,count(if(t2.AUM >= 50000, t2.客户号,null))                                  首饰金_AUM大于等于5万_户数_所有客户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.客户号,null))       首饰金_AUM大于等于5万_户数_企业主
,count(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.客户号,null))   首饰金_AUM大于等于5万_户数_个体工商户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) 首饰金_AUM大于等于5万_户数_非持牌个体户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.客户号,null))       首饰金_AUM大于等于5万_户数_工薪族
,count(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.客户号,null))     首饰金_AUM大于等于5万_户数_退休养老
,count(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.客户号,null))     首饰金_AUM大于等于5万_户数_持家女性
,count(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) 首饰金_AUM大于等于5万_户数_其他
,sum(if(t2.AUM >= 50000, t2.AUM,0))                                          首饰金_AUM大于等于5万_规模_所有客户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.AUM,0))               首饰金_AUM大于等于5万_规模_企业主
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.AUM,0))           首饰金_AUM大于等于5万_规模_个体工商户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         首饰金_AUM大于等于5万_规模_非持牌个体户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.AUM,0))               首饰金_AUM大于等于5万_规模_工薪族
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.AUM,0))             首饰金_AUM大于等于5万_规模_退休养老
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.AUM,0))             首饰金_AUM大于等于5万_规模_持家女性
,sum(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) 首饰金_AUM大于等于5万_规模_其他
-- AUM >= 100000 &amp; 年龄 25-70
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000, t2.客户号,null))                                  工艺金_AUM大于等于10万_户数_所有客户
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '企业主', t2.客户号,null))       工艺金_AUM大于等于10万_户数_企业主
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '个体工商户', t2.客户号,null))   工艺金_AUM大于等于10万_户数_个体工商户
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) 工艺金_AUM大于等于10万_户数_非持牌个体户
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '工薪族', t2.客户号,null))       工艺金_AUM大于等于10万_户数_工薪族
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '退休养老', t2.客户号,null))     工艺金_AUM大于等于10万_户数_退休养老
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '持家女性', t2.客户号,null))     工艺金_AUM大于等于10万_户数_持家女性
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) 工艺金_AUM大于等于10万_户数_其他
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000, t2.AUM,0))                                          工艺金_AUM大于等于10万_规模_所有客户
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '企业主', t2.AUM,0))               工艺金_AUM大于等于10万_规模_企业主
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '个体工商户', t2.AUM,0))           工艺金_AUM大于等于10万_规模_个体工商户
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         工艺金_AUM大于等于10万_规模_非持牌个体户
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '工薪族', t2.AUM,0))               工艺金_AUM大于等于10万_规模_工薪族
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '退休养老', t2.AUM,0))             工艺金_AUM大于等于10万_规模_退休养老
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '持家女性', t2.AUM,0))             工艺金_AUM大于等于10万_规模_持家女性
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) 工艺金_AUM大于等于10万_规模_其他
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 t1 -- tbl1_所有员工表信息表
left JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231229002_all2022_cst_01 t2 --tbl2_客户基础信息表
on t1.empe_id = t2.主管护人工号
GROUP BY t1.empe_id
;


--tbl4_2024预测2
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_02 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_02 AS
SELECT  T.*,T1.*
FROM    LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all2022_empe_01 T
LEFT JOIN    LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_01 T1
ON      T.empe_id = T1.工号
;

--贵金属20221231 分行汇总
DROP    TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_03 PURGE;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_03 AS
SElECT t1.所在分行
    ,sum(投资金_AUM大于等于30万_户数_所有客户		) 投资金_AUM大于等于30万_户数_所有客户
	,sum(投资金_AUM大于等于30万_户数_企业主 		) 投资金_AUM大于等于30万_户数_企业主
	,sum(投资金_AUM大于等于30万_户数_个体工商户 	) 投资金_AUM大于等于30万_户数_个体工商户
	,sum(投资金_AUM大于等于30万_户数_非持牌个体户 	) 投资金_AUM大于等于30万_户数_非持牌个体户
	,sum(投资金_AUM大于等于30万_户数_工薪族 		) 投资金_AUM大于等于30万_户数_工薪族
	,sum(投资金_AUM大于等于30万_户数_退休养老 		) 投资金_AUM大于等于30万_户数_退休养老
	,sum(投资金_AUM大于等于30万_户数_持家女性 		) 投资金_AUM大于等于30万_户数_持家女性
	,sum(投资金_AUM大于等于30万_户数_其他)    		  投资金_AUM大于等于30万_户数_其他
    ,sum(投资金_AUM大于等于30万_规模_所有客户		) 投资金_AUM大于等于30万_规模_所有客户
	,sum(投资金_AUM大于等于30万_规模_企业主			) 投资金_AUM大于等于30万_规模_企业主
	,sum(投资金_AUM大于等于30万_规模_个体工商户		) 投资金_AUM大于等于30万_规模_个体工商户
	,sum(投资金_AUM大于等于30万_规模_非持牌个体户	) 投资金_AUM大于等于30万_规模_非持牌个体户
	,sum(投资金_AUM大于等于30万_规模_工薪族			) 投资金_AUM大于等于30万_规模_工薪族
	,sum(投资金_AUM大于等于30万_规模_退休养老		) 投资金_AUM大于等于30万_规模_退休养老
	,sum(投资金_AUM大于等于30万_规模_持家女性		) 投资金_AUM大于等于30万_规模_持家女性
	,sum(投资金_AUM大于等于30万_规模_其他	    	) 投资金_AUM大于等于30万_规模_其他

    ,sum(首饰金_AUM大于等于5万_户数_所有客户		) 首饰金_AUM大于等于5万_户数_所有客户
	,sum(首饰金_AUM大于等于5万_户数_企业主			) 首饰金_AUM大于等于5万_户数_企业主
	,sum(首饰金_AUM大于等于5万_户数_个体工商户		) 首饰金_AUM大于等于5万_户数_个体工商户
	,sum(首饰金_AUM大于等于5万_户数_非持牌个体户	) 首饰金_AUM大于等于5万_户数_非持牌个体户
	,sum(首饰金_AUM大于等于5万_户数_工薪族			) 首饰金_AUM大于等于5万_户数_工薪族
	,sum(首饰金_AUM大于等于5万_户数_退休养老		) 首饰金_AUM大于等于5万_户数_退休养老
	,sum(首饰金_AUM大于等于5万_户数_持家女性		) 首饰金_AUM大于等于5万_户数_持家女性
	,sum(首饰金_AUM大于等于5万_户数_其他 			) 首饰金_AUM大于等于5万_户数_其他
    ,sum(首饰金_AUM大于等于5万_规模_所有客户		) 首饰金_AUM大于等于5万_规模_所有客户
	,sum(首饰金_AUM大于等于5万_规模_企业主			) 首饰金_AUM大于等于5万_规模_企业主
	,sum(首饰金_AUM大于等于5万_规模_个体工商户		) 首饰金_AUM大于等于5万_规模_个体工商户
	,sum(首饰金_AUM大于等于5万_规模_非持牌个体户	) 首饰金_AUM大于等于5万_规模_非持牌个体户
	,sum(首饰金_AUM大于等于5万_规模_工薪族			) 首饰金_AUM大于等于5万_规模_工薪族
	,sum(首饰金_AUM大于等于5万_规模_退休养老		) 首饰金_AUM大于等于5万_规模_退休养老
	,sum(首饰金_AUM大于等于5万_规模_持家女性		) 首饰金_AUM大于等于5万_规模_持家女性
	,sum(首饰金_AUM大于等于5万_规模_其他 			) 首饰金_AUM大于等于5万_规模_其他

    ,sum(工艺金_AUM大于等于10万_户数_所有客户		) 工艺金_AUM大于等于10万_户数_所有客户
	,sum(工艺金_AUM大于等于10万_户数_企业主			) 工艺金_AUM大于等于10万_户数_企业主
	,sum(工艺金_AUM大于等于10万_户数_个体工商户		) 工艺金_AUM大于等于10万_户数_个体工商户
	,sum(工艺金_AUM大于等于10万_户数_非持牌个体户	) 工艺金_AUM大于等于10万_户数_非持牌个体户
	,sum(工艺金_AUM大于等于10万_户数_工薪族			) 工艺金_AUM大于等于10万_户数_工薪族
	,sum(工艺金_AUM大于等于10万_户数_退休养老		) 工艺金_AUM大于等于10万_户数_退休养老
	,sum(工艺金_AUM大于等于10万_户数_持家女性		) 工艺金_AUM大于等于10万_户数_持家女性
	,sum(工艺金_AUM大于等于10万_户数_其他 			) 工艺金_AUM大于等于10万_户数_其他
    ,sum(工艺金_AUM大于等于10万_规模_所有客户		) 工艺金_AUM大于等于10万_规模_所有客户
	,sum(工艺金_AUM大于等于10万_规模_企业主			) 工艺金_AUM大于等于10万_规模_企业主
	,sum(工艺金_AUM大于等于10万_规模_个体工商户		) 工艺金_AUM大于等于10万_规模_个体工商户
	,sum(工艺金_AUM大于等于10万_规模_非持牌个体户	) 工艺金_AUM大于等于10万_规模_非持牌个体户
	,sum(工艺金_AUM大于等于10万_规模_工薪族			) 工艺金_AUM大于等于10万_规模_工薪族
	,sum(工艺金_AUM大于等于10万_规模_退休养老		) 工艺金_AUM大于等于10万_规模_退休养老
	,sum(工艺金_AUM大于等于10万_规模_持家女性		) 工艺金_AUM大于等于10万_规模_持家女性
	,sum(工艺金_AUM大于等于10万_规模_其他 			) 工艺金_AUM大于等于10万_规模_其他
from LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2023yuce_02 T1
GROUP by t1.所在分行
;
**SJ20231229002_贵金属考核拆解2024管护人预测底表_机构汇总.sql
-- tbl1_所有员工表信息表（保险贵金属通用）
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 AS
SELECT  t1.empe_id
        ,t1.empe_nm 姓名
        ,t2.pos_nm 岗位
        ,INT(t1.srv_mon_tot / 12) 入行年限
        ,t1.empe_age 年龄
        ,CASE t1.hi_acdm_rcd_cd
           WHEN '10' THEN '研究生教育'
           WHEN '11' THEN '博士研究生毕业'
           WHEN '12' THEN '博士研究生结业'
           WHEN '13' THEN '博士研究生肄业'
           WHEN '14' THEN '硕士研究生毕业'
           WHEN '15' THEN '硕士研究生结业'
           WHEN '16' THEN '硕士研究生肄业'
           WHEN '17' THEN '研究生班毕业'
           WHEN '18' THEN '研究生班结业'
           WHEN '19' THEN '研究生班肄业'
           WHEN '20' THEN '大学本科教育'
           WHEN '21' THEN '大学本科毕业'
           WHEN '22' THEN '大学本科结业'
           WHEN '23' THEN '大学本科肄业'
           WHEN '28' THEN '大学普通班毕业'
           WHEN '30' THEN '大学专科教育'
           WHEN '31' THEN '大学专科毕业'
           WHEN '32' THEN '大学专科结业'
           WHEN '33' THEN '大学专科肄业'
           WHEN '40' THEN '中等职业教育'
           WHEN '41' THEN '中等专科毕业'
           WHEN '42' THEN '中等专科结业'
           WHEN '43' THEN '中等专科肄业'
           WHEN '44' THEN '职业高中毕业'
           WHEN '45' THEN '职业高中结业'
           WHEN '46' THEN '职业高中肄业'
           WHEN '47' THEN '技工学院毕业'
           WHEN '48' THEN '技工学院结业'
           WHEN '49' THEN '技工学院肄业'
           WHEN '60' THEN '普通高级中学教育'
           WHEN '61' THEN '普通高中毕业'
           WHEN '62' THEN '普通高中结业'
           WHEN '63' THEN '普通高中肄业'
           WHEN '70' THEN '初级中学教育'
           WHEN '71' THEN '初中毕业'
           WHEN '73' THEN '初中肄业'
           WHEN '80' THEN '小学教育'
           WHEN '81' THEN '小学毕业'
           WHEN '83' THEN '小学肄业'
           WHEN '90' THEN '文盲或半文盲'
           WHEN '98' THEN '未知'
           WHEN '99' THEN '其他'
         END 学历
        ,t3.brc_org_nm 所在分行
        ,t3.sbr_org_nm 所在支行
        ,t3.tem_org_nm 所在团队
FROM    edw.dws_hr_empe_inf_dd t1
LEFT JOIN    edw.dim_hr_org_job_inf_dd t2
ON      t1.pos_enc = t2.pos_id
AND     t2.dt = '20231228'
LEFT JOIN    edw.dim_hr_org_mng_org_tree_dd t3
ON      t1.org_id = t3.org_id
AND     t3.dt = '20231228'
WHERE   t2.pos_nm IN ( '客户经理' , '服务经理' , '理财经理' , '营业经理' , '业务团队正职' , '业务团队副职' , '支行班子正职' , '支行班子副职' )
AND     t1.dt = '20231228'
AND     t1.EMPE_STS_CD = '2' --在职
AND     (t3.brc_org_nm LIKE '%分行%' or t3.brc_org_nm LIKE '%总行%')
;
-- 8401


--tbl2_客户基础信息表
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_all_cst_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_all_cst_01 AS
SELECT  t1.cst_id 客户号
        ,t1.prm_mgr_id 主管护人工号
        ,t1.prm_mgr_nm 主管护人名称
        ,t1.prm_org_id 主管护机构号
        ,t1.prm_org_nm 主管护机构名称
        ,t2.efe_dep_cst_ind 有效存款户
        ,t2.efe_wlth_cst_ind 财富有效户
        ,t2.age 年龄
        ,t2.aum_bal AUM
        ,decode(t3.cst_seg_flg, '1', '企业主', '2', '个体工商户', '3', '企事业高管', '4', '非持牌个体户', '5', '工薪族', '6', '退休养老', '7', '持家女性', '其他') 客群标签
FROM    adm_pub_app.adm_pblc_cst_prm_mng_inf_dd t1
LEFT JOIN    app_rpt.adm_subl_cst_wlth_bus_inf_dd t2 --正式客户财富业务信息表
ON      t1.cst_id = t2.cst_id
AND     t2.dt = '20231228'
LEFT JOIN    adm_pub.adm_csm_clab_cst_jc_inf_dd t3 --客户标签信息
ON      t1.cst_id = t3.cst_id
AND     t3.dt = '20231228'
WHERE   t1.dt = '20231228'
AND     t2.age >= 25
AND     t2.age <= 80 --年龄限制
AND     ( t2.efe_dep_cst_ind = '1' OR t2.efe_wlth_cst_ind = '1' ) --存款有效户or财富有效户
;
--1272368




--tbl3_2024预测1
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_01 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_01 AS
SELECT t1.empe_id 工号
-- AUM >= 300000
,count(if(t2.AUM >= 300000, t2.客户号,null))                                  投资金_AUM大于等于30万_户数_所有客户
,count(if(t2.AUM >= 300000 and t2.客群标签 = '企业主', t2.客户号,null))       投资金_AUM大于等于30万_户数_企业主
,count(if(t2.AUM >= 300000 and t2.客群标签 = '个体工商户', t2.客户号,null))   投资金_AUM大于等于30万_户数_个体工商户
,count(if(t2.AUM >= 300000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) 投资金_AUM大于等于30万_户数_非持牌个体户
,count(if(t2.AUM >= 300000 and t2.客群标签 = '工薪族', t2.客户号,null))       投资金_AUM大于等于30万_户数_工薪族
,count(if(t2.AUM >= 300000 and t2.客群标签 = '退休养老', t2.客户号,null))     投资金_AUM大于等于30万_户数_退休养老
,count(if(t2.AUM >= 300000 and t2.客群标签 = '持家女性', t2.客户号,null))     投资金_AUM大于等于30万_户数_持家女性
,count(if(t2.AUM >= 300000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) 投资金_AUM大于等于30万_户数_其他
,sum(if(t2.AUM >= 300000, t2.AUM,0))                                          投资金_AUM大于等于30万_规模_所有客户
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '企业主', t2.AUM,0))               投资金_AUM大于等于30万_规模_企业主
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '个体工商户', t2.AUM,0))           投资金_AUM大于等于30万_规模_个体工商户
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         投资金_AUM大于等于30万_规模_非持牌个体户
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '工薪族', t2.AUM,0))               投资金_AUM大于等于30万_规模_工薪族
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '退休养老', t2.AUM,0))             投资金_AUM大于等于30万_规模_退休养老
,sum(if(t2.AUM >= 300000 and t2.客群标签 = '持家女性', t2.AUM,0))             投资金_AUM大于等于30万_规模_持家女性
,sum(if(t2.AUM >= 300000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) 投资金_AUM大于等于30万_规模_其他
-- AUM >= 50000
,count(if(t2.AUM >= 50000, t2.客户号,null))                                  首饰金_AUM大于等于5万_户数_所有客户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.客户号,null))       首饰金_AUM大于等于5万_户数_企业主
,count(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.客户号,null))   首饰金_AUM大于等于5万_户数_个体工商户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) 首饰金_AUM大于等于5万_户数_非持牌个体户
,count(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.客户号,null))       首饰金_AUM大于等于5万_户数_工薪族
,count(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.客户号,null))     首饰金_AUM大于等于5万_户数_退休养老
,count(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.客户号,null))     首饰金_AUM大于等于5万_户数_持家女性
,count(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) 首饰金_AUM大于等于5万_户数_其他
,sum(if(t2.AUM >= 50000, t2.AUM,0))                                          首饰金_AUM大于等于5万_规模_所有客户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '企业主', t2.AUM,0))               首饰金_AUM大于等于5万_规模_企业主
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '个体工商户', t2.AUM,0))           首饰金_AUM大于等于5万_规模_个体工商户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         首饰金_AUM大于等于5万_规模_非持牌个体户
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '工薪族', t2.AUM,0))               首饰金_AUM大于等于5万_规模_工薪族
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '退休养老', t2.AUM,0))             首饰金_AUM大于等于5万_规模_退休养老
,sum(if(t2.AUM >= 50000 and t2.客群标签 = '持家女性', t2.AUM,0))             首饰金_AUM大于等于5万_规模_持家女性
,sum(if(t2.AUM >= 50000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) 首饰金_AUM大于等于5万_规模_其他
-- AUM >= 100000 &amp; 年龄 25-70
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000, t2.客户号,null))                                  工艺金_AUM大于等于10万_户数_所有客户
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '企业主', t2.客户号,null))       工艺金_AUM大于等于10万_户数_企业主
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '个体工商户', t2.客户号,null))   工艺金_AUM大于等于10万_户数_个体工商户
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '非持牌个体户', t2.客户号,null)) 工艺金_AUM大于等于10万_户数_非持牌个体户
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '工薪族', t2.客户号,null))       工艺金_AUM大于等于10万_户数_工薪族
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '退休养老', t2.客户号,null))     工艺金_AUM大于等于10万_户数_退休养老
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 = '持家女性', t2.客户号,null))     工艺金_AUM大于等于10万_户数_持家女性
,count(if(t2.年龄 >= 25 AND T2.年龄 <= 70 AND t2.AUM >= 100000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.客户号,null)) 工艺金_AUM大于等于10万_户数_其他
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000, t2.AUM,0))                                          工艺金_AUM大于等于10万_规模_所有客户
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '企业主', t2.AUM,0))               工艺金_AUM大于等于10万_规模_企业主
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '个体工商户', t2.AUM,0))           工艺金_AUM大于等于10万_规模_个体工商户
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '非持牌个体户', t2.AUM,0))         工艺金_AUM大于等于10万_规模_非持牌个体户
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '工薪族', t2.AUM,0))               工艺金_AUM大于等于10万_规模_工薪族
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '退休养老', t2.AUM,0))             工艺金_AUM大于等于10万_规模_退休养老
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 = '持家女性', t2.AUM,0))             工艺金_AUM大于等于10万_规模_持家女性
,sum(if(t2.年龄 >= 25 AND T2.年龄 <= 70  AND t2.AUM >= 100000 and t2.客群标签 NOT IN ('企业主','个体工商户','非持牌个体户','工薪族','退休养老','持家女性'), t2.AUM,0)) 工艺金_AUM大于等于10万_规模_其他
FROM LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 t1 -- tbl1_所有员工表信息表
left JOIN LAB_BIGDATA_DEV.SJXQ_SJ20231229002_all_cst_01 t2 --tbl2_客户基础信息表
on t1.empe_id = t2.主管护人工号
GROUP BY t1.empe_id
;


--tbl4_2024预测2
DROP TABLE IF EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_02 PURGE;

CREATE TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_02 AS
SELECT  T.*,T1.*
FROM    LAB_BIGDATA_DEV.SJXQ_SJ20231229001_all_empe_01 T
LEFT JOIN    LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_01 T1
ON      T.empe_id = T1.工号
;

--贵金属20231228 分行汇总
DROP    TABLE IF     EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_03 PURGE;
CREATE  TABLE IF NOT EXISTS LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_03 AS
SElECT t1.所在分行
    ,sum(投资金_AUM大于等于30万_户数_所有客户		) 投资金_AUM大于等于30万_户数_所有客户
	,sum(投资金_AUM大于等于30万_户数_企业主 		) 投资金_AUM大于等于30万_户数_企业主
	,sum(投资金_AUM大于等于30万_户数_个体工商户 	) 投资金_AUM大于等于30万_户数_个体工商户
	,sum(投资金_AUM大于等于30万_户数_非持牌个体户 	) 投资金_AUM大于等于30万_户数_非持牌个体户
	,sum(投资金_AUM大于等于30万_户数_工薪族 		) 投资金_AUM大于等于30万_户数_工薪族
	,sum(投资金_AUM大于等于30万_户数_退休养老 		) 投资金_AUM大于等于30万_户数_退休养老
	,sum(投资金_AUM大于等于30万_户数_持家女性 		) 投资金_AUM大于等于30万_户数_持家女性
	,sum(投资金_AUM大于等于30万_户数_其他)    		  投资金_AUM大于等于30万_户数_其他
    ,sum(投资金_AUM大于等于30万_规模_所有客户		) 投资金_AUM大于等于30万_规模_所有客户
	,sum(投资金_AUM大于等于30万_规模_企业主			) 投资金_AUM大于等于30万_规模_企业主
	,sum(投资金_AUM大于等于30万_规模_个体工商户		) 投资金_AUM大于等于30万_规模_个体工商户
	,sum(投资金_AUM大于等于30万_规模_非持牌个体户	) 投资金_AUM大于等于30万_规模_非持牌个体户
	,sum(投资金_AUM大于等于30万_规模_工薪族			) 投资金_AUM大于等于30万_规模_工薪族
	,sum(投资金_AUM大于等于30万_规模_退休养老		) 投资金_AUM大于等于30万_规模_退休养老
	,sum(投资金_AUM大于等于30万_规模_持家女性		) 投资金_AUM大于等于30万_规模_持家女性
	,sum(投资金_AUM大于等于30万_规模_其他	    	) 投资金_AUM大于等于30万_规模_其他

    ,sum(首饰金_AUM大于等于5万_户数_所有客户		) 首饰金_AUM大于等于5万_户数_所有客户
	,sum(首饰金_AUM大于等于5万_户数_企业主			) 首饰金_AUM大于等于5万_户数_企业主
	,sum(首饰金_AUM大于等于5万_户数_个体工商户		) 首饰金_AUM大于等于5万_户数_个体工商户
	,sum(首饰金_AUM大于等于5万_户数_非持牌个体户	) 首饰金_AUM大于等于5万_户数_非持牌个体户
	,sum(首饰金_AUM大于等于5万_户数_工薪族			) 首饰金_AUM大于等于5万_户数_工薪族
	,sum(首饰金_AUM大于等于5万_户数_退休养老		) 首饰金_AUM大于等于5万_户数_退休养老
	,sum(首饰金_AUM大于等于5万_户数_持家女性		) 首饰金_AUM大于等于5万_户数_持家女性
	,sum(首饰金_AUM大于等于5万_户数_其他 			) 首饰金_AUM大于等于5万_户数_其他
    ,sum(首饰金_AUM大于等于5万_规模_所有客户		) 首饰金_AUM大于等于5万_规模_所有客户
	,sum(首饰金_AUM大于等于5万_规模_企业主			) 首饰金_AUM大于等于5万_规模_企业主
	,sum(首饰金_AUM大于等于5万_规模_个体工商户		) 首饰金_AUM大于等于5万_规模_个体工商户
	,sum(首饰金_AUM大于等于5万_规模_非持牌个体户	) 首饰金_AUM大于等于5万_规模_非持牌个体户
	,sum(首饰金_AUM大于等于5万_规模_工薪族			) 首饰金_AUM大于等于5万_规模_工薪族
	,sum(首饰金_AUM大于等于5万_规模_退休养老		) 首饰金_AUM大于等于5万_规模_退休养老
	,sum(首饰金_AUM大于等于5万_规模_持家女性		) 首饰金_AUM大于等于5万_规模_持家女性
	,sum(首饰金_AUM大于等于5万_规模_其他 			) 首饰金_AUM大于等于5万_规模_其他

    ,sum(工艺金_AUM大于等于10万_户数_所有客户		) 工艺金_AUM大于等于10万_户数_所有客户
	,sum(工艺金_AUM大于等于10万_户数_企业主			) 工艺金_AUM大于等于10万_户数_企业主
	,sum(工艺金_AUM大于等于10万_户数_个体工商户		) 工艺金_AUM大于等于10万_户数_个体工商户
	,sum(工艺金_AUM大于等于10万_户数_非持牌个体户	) 工艺金_AUM大于等于10万_户数_非持牌个体户
	,sum(工艺金_AUM大于等于10万_户数_工薪族			) 工艺金_AUM大于等于10万_户数_工薪族
	,sum(工艺金_AUM大于等于10万_户数_退休养老		) 工艺金_AUM大于等于10万_户数_退休养老
	,sum(工艺金_AUM大于等于10万_户数_持家女性		) 工艺金_AUM大于等于10万_户数_持家女性
	,sum(工艺金_AUM大于等于10万_户数_其他 			) 工艺金_AUM大于等于10万_户数_其他
    ,sum(工艺金_AUM大于等于10万_规模_所有客户		) 工艺金_AUM大于等于10万_规模_所有客户
	,sum(工艺金_AUM大于等于10万_规模_企业主			) 工艺金_AUM大于等于10万_规模_企业主
	,sum(工艺金_AUM大于等于10万_规模_个体工商户		) 工艺金_AUM大于等于10万_规模_个体工商户
	,sum(工艺金_AUM大于等于10万_规模_非持牌个体户	) 工艺金_AUM大于等于10万_规模_非持牌个体户
	,sum(工艺金_AUM大于等于10万_规模_工薪族			) 工艺金_AUM大于等于10万_规模_工薪族
	,sum(工艺金_AUM大于等于10万_规模_退休养老		) 工艺金_AUM大于等于10万_规模_退休养老
	,sum(工艺金_AUM大于等于10万_规模_持家女性		) 工艺金_AUM大于等于10万_规模_持家女性
	,sum(工艺金_AUM大于等于10万_规模_其他 			) 工艺金_AUM大于等于10万_规模_其他
from LAB_BIGDATA_DEV.SJXQ_SJ20231229002_2024yuce_02 T1
GROUP by t1.所在分行
;
**SJ2023122901-保险22年销售底表.sql

DROP TABLE IF EXISTS tmp_qwj_20221231_all_bxkb1 purge;
CREATE TABLE IF NOT EXISTS tmp_qwj_20221231_all_bxkb1 as
select
    replace(a.trx_dt,'-','') 交易日期
    ,a.cmp_nm 公司名称
    ,a.prod_nm 产品名称
    ,a.insu_plcy_id 保单号
    ,a.insu_plcy_sts 保单状态
    ,a.trx_sts 交易状态
    ,a.sal_ppl_id 销售人员工号
    ,a.sal_ppl_nm 销售人员姓名
    ,a.cmsn_fee 手续费
    ,b.insu_fee 交易金额
    ,a.insu_hld_nm 投保人姓名
    ,b.cst_id 客户号
    ,信用风险等级
    -- ,if(kq.客群 is not null,'是','') 是否32万小企业主
    ,ck.dep_bal_year_avg 存款年日均
    ,zc.fnc_year_avg_amt 理财年日均
    ,decode(xj.aum_grd,'1','一星','2','二星','3','三星','4','四星','5','五星','6','六星') 财富星级
    ,decode(kq1.CST_SEG_FLG,'1','企业主','2','个体工商户','3','企事业高管','4','非持牌个体户','5','工薪族','6','退休养老','7','持家女性','') 所属客群
    ,int(('20221231'-c1.bth_dt)/10000) 年龄
    ,930挂钩理财余额
    ,dk.com_loan_bal 交易日贷款余额
from  app_rpt.fct_insu_agn_bus_acs_dtl_tbl a
left join edw.dwd_bus_insu_plcy_insu_inf_dd b
on a.insu_plcy_id=b.insu_plcy_id and b.dt='20221231' -- 保险保单投保信息
left join (
    select distinct
        cst_id,decode(risk_level,'1','低风险','2','中低风险','3','中风险','4','中高风险','5','高风险') 信用风险等级
    from app_rpt.INTER_BATCH_HIGH_RISK_LST_IDV_DLM_ALL
    where dt='20221231'
) rl on b.cst_id=rl.cst_id
-- left join tmp_qwj_0818_mkx_kq kq on b.cst_id=kq.cst_id
left join adm_pub.adm_csm_cbus_dep_inf_dd ck on  b.cst_id=ck.cst_id and ck.dt='20221231'  -- 客户集市-业务信息-客户存款业务信息表
left join adm_pub.adm_csm_cbus_cst_fin_ast_inf_dd zc on b.cst_id=zc.cst_id and zc.dt='20221231' -- 客户集市-业务信息-客户金融资产信息表
left join adm_pub.adm_csm_cbas_cst_grd_inf_dd xj on b.cst_id=xj.cst_id and xj.dt='20221231'
left join adm_pub.adm_csm_clab_cst_jc_inf_dd kq1 on b.cst_id=kq1.cst_id and kq1.dt='20221231'
left join edw.dim_cst_idv_bas_inf_dd c1 on b.cst_id=c1.cst_id and c1.dt='20221231'
left join (
    select
        cst_id,
        sum(bal) 930挂钩理财余额
    from app_rpt.adm_subl_bus_chm_mul_dim_stat_dd a
    inner join edw.dim_bus_chm_pd_inf_dd lc on a.pd_cd=lc.pd_cd and lc.dt='20221231' and lc.pd_ctg_cd='1' --剔除基金
    where a.dt in ('20221231')
        and lc.pd_nm regexp '钱潮系列' and lc.pd_nm regexp '挂钩'
    group by cst_id
) gg on b.cst_id=gg.cst_id
left join adm_pub.adm_csm_cbus_loan_inf_dd dk on b.cst_id=dk.cst_id and a.replace(a.trx_dt,'-','')=dk.dt and dk.dt between '20190426' and '20221231'
where a.dt='20221231'
and a.INSU_PLCY_STS IN('正常','退保','满期退保')
-- and replace(a.trx_dt,'-','')>='20220101'
;

DROP TABLE IF EXISTS tmp_qwj_20221231_all_bxkb2 purge;
CREATE TABLE IF NOT EXISTS tmp_qwj_20221231_all_bxkb2 as
select
    a.交易日期
    ,a.公司名称
    ,a.产品名称
    ,a.保单号
    ,a.保单状态
    ,a.交易状态
    ,a.销售人员工号
    ,a.销售人员姓名
    ,a.手续费
    ,a.交易金额
    ,a.投保人姓名
    ,a.客户号
    ,a.信用风险等级
    -- ,a.是否32万小企业主
    ,a.存款年日均
    ,a.理财年日均
    ,a.财富星级
    ,a.所属客群
    ,a.年龄
    ,a.930挂钩理财余额
    ,A.交易日贷款余额
    ,ABS(DATEDIFF(TO_DATE(C.REG_DT, 'yyyyMMdd'), TO_DATE(A.交易日期, 'yyyyMMdd'), 'dd')) AS 间隔日期
    ,B.BUSI_CTR_ID                         合同流水号
    ,B.CTR_AMT                             合同金额
    ,case
        when B.TRM_MON >0 then B.TRM_MON
        else ROUND(MONTHS_BETWEEN(TO_DATE(b.apnt_mtu_dt,'yyyyMMdd'),TO_DATE(b.apnt_start_dt,'yyyyMMdd')))
    end as                                 期限月
    ,b.stdinr                              基准利率
    ,c.ref_year_intr_rat                   参考年利率
    ,B.INTR_RAT                            执行利率
    ,B.REF_MON_INTR_RAT                    参考月利率
    ,c.aprv_exe_mon_intr_rat               执行月利率
    ,C.REG_DT                              申请日期
    ,CASE SUBSTR(b.PD_CD, 1, 9)
        WHEN '201050101' THEN '1'
        WHEN '201050102' THEN '2'
        WHEN '201040101' THEN '3'
        WHEN '201040102' THEN '4'
        ELSE '5'
    END                                 AS PD_TP
from tmp_qwj_20221231_all_bxkb1 a
LEFT JOIN    edw.DIM_BUS_LOAN_CTR_INF_DD B --信贷合同信息
ON      A.客户号 = B.CST_ID --客户号
AND     NVL(B.CST_ID,'') <> '' --剔除空值和空
AND     B.CRC_IND <> '1'    --剔除循环贷款
AND     SUBSTR(B.PD_CD, 1, 9) IN ( '201050101' , '201050102' , '201040101' , '201040102' , '201040106' ) --产品代码 --普通贷款:-20105010100 个人消费性贷款 20105010200 个人经营性贷款 20104010100 流动资金贷款 20104010200 固定资产贷款 20104010600 法人购房贷款
AND     B.DT = '20221231'
LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD C --信贷业务申请信息
ON      B.BUSI_APL_ID = C.APL_ID --业务申请编号
AND     NVL(C.APL_ID,'') <> '' --剔除空值和空
AND     C.DT = '20221231'
;

DROP TABLE IF EXISTS tmp_qwj_20221231_all_bxkb3 purge;
CREATE TABLE IF NOT EXISTS tmp_qwj_20221231_all_bxkb3 as
select
    a.交易日期
    ,a.公司名称
    ,a.产品名称
    ,a.保单号
    ,a.保单状态
    ,a.交易状态
    ,a.销售人员工号
    ,a.销售人员姓名
    ,a.手续费
    ,a.交易金额
    ,a.投保人姓名
    -- ,a.保单号 保单号2
    ,t1.frs_trm_insu_fee   AS 首期保费
    ,a.客户号
    ,a.交易日贷款余额
    ,a.信用风险等级
    ,a.合同金额 交易日前后15天最近一笔贷款发生额
    ,a.期限月 交易日前后15天最近一笔贷款期限月
    ,a.执行利率 交易日前后15天最近一笔贷款执行利率
    ,贷款当月同类型同期限利率水平
    ,a.执行利率-贷款当月同类型同期限利率水平 较同期限利率
    -- ,a.是否32万小企业主
    ,a.存款年日均
    ,a.理财年日均
    ,a.财富星级
    ,a.所属客群
    ,a.年龄
    ,a.930挂钩理财余额
    -- ,a.交易日期 交易日期2
    ,t1.sal_org_id_fh 推荐人所属机构所属分行
    ,t1.trx_org_nm 交易机构名称
    ,t1.sal_ppl_afl_org_nm 推荐人所属机构名称
    ,t1.sal_ppl_id 推荐人工号
    ,t1.sal_ppl_nm 推荐人姓名
    ,t1.sal_ppl_pst_nm 推荐人岗位名称
    ,t1.mng_mgr_id 管护客户经理工号
    ,t1.mng_mgr_nm 管护客户经理姓名
    -- ,t1.cmp_nm 公司名称
    -- ,t1.prod_nm 产品名称
from (
    select *,row_number() over(partition by 保单号 order by 间隔日期 asc) rn,
        substr(申请日期,1,6) 申请月
    from tmp_qwj_20221231_all_bxkb2
) a
left join (
    select
        substr(C.REG_DT,1,6) 申请月
        ,CASE SUBSTR(b.PD_CD, 1, 9)
            WHEN '201050101' THEN '1'
            WHEN '201050102' THEN '2'
            WHEN '201040101' THEN '3'
            WHEN '201040102' THEN '4'
            ELSE '5'
        END  AS PD_TP
        ,case
            when B.TRM_MON >0 then B.TRM_MON
            else ROUND(MONTHS_BETWEEN(TO_DATE(b.apnt_mtu_dt,'yyyyMMdd'),TO_DATE(b.apnt_start_dt,'yyyyMMdd')))
        end as                                 期限月
        ,avg(B.INTR_RAT) 贷款当月同类型同期限利率水平
    from edw.DIM_BUS_LOAN_CTR_INF_DD B --信贷合同信息
    LEFT JOIN    edw.DWD_BUS_LOAN_APL_INF_DD C --信贷业务申请信息
    ON      B.BUSI_APL_ID = C.APL_ID --业务申请编号
    AND     NVL(C.APL_ID,'') <> '' --剔除空值和空
    AND     C.DT = '20221231'
    where NVL(B.CST_ID,'') <> '' --剔除空值和空
    AND     B.CRC_IND <> '1'    --剔除循环贷款
    AND     SUBSTR(B.PD_CD, 1, 9) IN ( '201050101' , '201050102' , '201040101' , '201040102' , '201040106' ) --产品代码 --普通贷款:-20105010100 个人消费性贷款 20105010200 个人经营性贷款 20104010100 流动资金贷款 20104010200 固定资产贷款 20104010600 法人购房贷款
    AND     B.DT = '20221231'
    group by substr(C.REG_DT,1,6)
        ,CASE SUBSTR(b.PD_CD, 1, 9)
            WHEN '201050101' THEN '1'
            WHEN '201050102' THEN '2'
            WHEN '201040101' THEN '3'
            WHEN '201040102' THEN '4'
            ELSE '5'
        END,case
            when B.TRM_MON >0 then B.TRM_MON
            else ROUND(MONTHS_BETWEEN(TO_DATE(b.apnt_mtu_dt,'yyyyMMdd'),TO_DATE(b.apnt_start_dt,'yyyyMMdd')))
        end
) b on a.申请月=b.申请月 and a.PD_TP=b.PD_TP and a.期限月=b.期限月
LEFT JOIN (
    select *,row_number() over(partition by insu_plcy_id order by mng_rto desc) rn
    from app_rpt.fct_insu_agn_bus_acs_dtl_tbl t1 --保险明细取最新日期状态
    where t1.dt = '20221231'
) t1 ON      a.保单号 = t1.insu_plcy_id and t1.rn=1
where a.rn=1
;

DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2022_01;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2022_01 AS
select t1.cst_id,t1.cst_chn_nm,t1.file_dt,t1.sam_rsk_ctrl_id
    ,decode(t2.cst_seg_flg,'1','企业主','2','个体工商户','3','企事业高管','4','非持牌个体户','5'
        ,'工薪族','6','退休养老','7','持家女性','其他') cst_seg
    ,t3.age
    ,decode(t3.gdr_cd,'1','男','2','女','未知') gender
    ,t3.AUM_GRD,t3.dep_bal_year_avg,t3.fnc_year_avg_amt
    ,t3.efe_loan_cst_ind		-- 有效贷款户
    ,t3.efe_dep_cst_ind,t3.efe_wlth_cst_ind,t3.efe_chm_cst_ind
    ,t3.aum_bal
    ,t3.prm_mgr_id
    ,t3.wlth_mng_mnl_id
from edw.dws_cst_bas_inf_dd 		            t1 	--客户基础信息汇总表
left join adm_pub.adm_csm_clab_cst_jc_inf_dd    t2  --客户标签信息
on t1.cst_id=t2.cst_id
and t2.dt='20221231'
left join app_rpt.adm_subl_cst_wlth_bus_inf_dd 	t3  --正式客户财富业务信息表
on t1.cst_id=t3.cst_id
and t3.dt='20221231'
where t1.dt='@@{yyyyMMdd}'
;

--是否同一风险控制号信贷户
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2022_02;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2022_02 AS
SELECT T1.CST_ID,T1.sam_rsk_ctrl_id,MAX(T3.efe_loan_cst_ind) is_vld_loan
FROM SJXQ_SJ2023122901_CST2022_01         T1
LEFT JOIN SJXQ_SJ2023122901_CST2022_01    T3
ON T1.sam_rsk_ctrl_id=T3.sam_rsk_ctrl_id
where nvl(t1.sam_rsk_ctrl_id,'')<>''        --不限制会跑不出来
GROUP BY T1.CST_ID,T1.sam_rsk_ctrl_id
having MAX(T3.efe_loan_cst_ind)='1'         --有效信贷户
;

--是否复投 insu_cnt>1
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2022_03;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2022_03 AS
SElECT cst_id,count(1) insu_cnt,sum(insu_fee) his_insu_fee
from edw.dwd_bus_insu_plcy_insu_inf_dd
where dt = '20221231'
and insu_dt <= '20221231'
and INSU_PLCY_STS in ('0','1','A') --'正常','退保','满期退保'
group by cst_id
;


--输出结果：订单维度
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2022_04;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2022_04 AS
SElECT t1.交易日期
	,t1.公司名称
	,t1.产品名称
	,t1.保单号
	,t1.保单状态
	,t1.交易状态
	,t1.销售人员工号
	,t1.销售人员姓名
	,t1.手续费
	,t1.交易金额
	,t1.投保人姓名
	,t1.首期保费
	,t1.客户号
	,t1.交易日贷款余额
	,t1.信用风险等级
	,t1.交易日前后15天最近一笔贷款发生额
	,t1.交易日前后15天最近一笔贷款期限月
	,t1.交易日前后15天最近一笔贷款执行利率
	,t1.贷款当月同类型同期限利率水平
	,t1.较同期限利率
	,t1.存款年日均
	,t1.理财年日均
	,t1.财富星级
	,t1.所属客群
	,t1.年龄
	,t1.930挂钩理财余额
	,t1.推荐人所属机构所属分行
	,t1.交易机构名称
	,t1.推荐人所属机构名称
	,t1.推荐人工号
	,t1.推荐人姓名
	,t1.推荐人岗位名称
	,t1.管护客户经理工号
	,t1.管护客户经理姓名

    ,CASE WHEN T2.CST_ID IS NOT NULL THEN 1 ELSE 0 END  是否同一风险控制号信贷户
    ,CASE WHEN T3.insu_cnt>1 THEN 1 ELSE 0 END          是否复投
    ,CASE WHEN T4.file_dt>='20220101' THEN 1 ELSE 0 END 是否2022新建档客户
    ,T4.gender      客户性别
    ,T5.insu_seg_desc 保险产品类型
from tmp_qwj_20221231_all_bxkb3        T1
LEFT JOIN SJXQ_SJ2023122901_CST2022_02 T2
ON T1.客户号 = T2.CST_ID
LEFT JOIN SJXQ_SJ2023122901_CST2022_03 T3
ON T1.客户号 = T3.CST_ID
LEFT JOIN SJXQ_SJ2023122901_CST2022_01 T4
ON T1.客户号 = T4.CST_ID
LEFT JOIN qbi_file_20231229_11_33_49   T5
ON T1.产品名称 = T5.insu_pd_nm
AND T5.PT = MAX_PT('lab_bigdata_dev.qbi_file_20231229_11_33_49')
where t1.交易日期>='20220101'
;

**SJ2023122901-保险23年销售底表.sql
--客户 20231025 数据
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_01;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_01 AS
select t1.cst_id,t1.cst_chn_nm,t1.file_dt,t1.sam_rsk_ctrl_id
    ,decode(t2.cst_seg_flg,'1','企业主','2','个体工商户','3','企事业高管','4','非持牌个体户','5'
        ,'工薪族','6','退休养老','7','持家女性','其他') cst_seg
    ,t3.age
    ,decode(t3.gdr_cd,'1','男','2','女','未知') gender
    ,t3.AUM_GRD,t3.dep_bal_year_avg,t3.fnc_year_avg_amt
    ,t3.efe_loan_cst_ind		-- 有效贷款户
    ,t3.efe_dep_cst_ind,t3.efe_wlth_cst_ind,t3.efe_chm_cst_ind
    ,t3.aum_bal
    ,t3.prm_mgr_id
    ,t3.wlth_mng_mnl_id
from edw.dws_cst_bas_inf_dd 		            t1 	--客户基础信息汇总表
left join adm_pub.adm_csm_clab_cst_jc_inf_dd    t2  --客户标签信息
on t1.cst_id=t2.cst_id
and t2.dt='20231025'
left join app_rpt.adm_subl_cst_wlth_bus_inf_dd 	t3  --正式客户财富业务信息表
on t1.cst_id=t3.cst_id
and t3.dt='20231025'
where t1.dt='20231025'
;

--是否同一风险控制号信贷户
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_02;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_02 AS
SELECT T1.CST_ID,T1.sam_rsk_ctrl_id,MAX(T3.efe_loan_cst_ind) is_vld_loan
FROM SJXQ_SJ2023122901_CST2023_01         T1
LEFT JOIN SJXQ_SJ2023122901_CST2023_01    T3
ON T1.sam_rsk_ctrl_id=T3.sam_rsk_ctrl_id
where nvl(t1.sam_rsk_ctrl_id,'')<>''        --不限制会跑不出来
GROUP BY T1.CST_ID,T1.sam_rsk_ctrl_id
having MAX(T3.efe_loan_cst_ind)='1'         --有效信贷户
;

--是否复投 insu_cnt>1
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_03;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_03 AS
SElECT cst_id,count(1) insu_cnt,sum(insu_fee) his_insu_fee
from edw.dwd_bus_insu_plcy_insu_inf_dd
where dt = '20231025'
and insu_dt <= '20231025'
and INSU_PLCY_STS in ('0','1','A') --'正常','退保','满期退保'
group by cst_id
;

--客户 20221231 数据
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_05;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_05 AS
select t1.cst_id,t1.cst_chn_nm,t1.file_dt,t1.sam_rsk_ctrl_id
    ,decode(t2.cst_seg_flg,'1','企业主','2','个体工商户','4','非持牌个体户','5'
        ,'工薪族','6','退休养老','7','持家女性','其他') cst_seg
    ,t3.age
    ,decode(t3.gdr_cd,'1','男','2','女','未知') gender
    ,t3.AUM_GRD,t3.dep_bal_year_avg,t3.fnc_year_avg_amt
    ,t3.efe_loan_cst_ind		-- 有效贷款户
    ,t3.efe_dep_cst_ind,t3.efe_wlth_cst_ind,t3.efe_chm_cst_ind  --存款、财富
    ,t3.aum_bal
    ,t3.prm_mgr_id
    ,t3.wlth_mng_mnl_id
    ,t4.sale_empe_id
from edw.dws_cst_bas_inf_dd 		            t1 	--客户基础信息汇总表
left join adm_pub.adm_csm_clab_cst_jc_inf_dd    t2  --客户标签信息
on t1.cst_id=t2.cst_id
and t2.dt='20221231'
left join app_rpt.adm_subl_cst_wlth_bus_inf_dd 	t3  --正式客户财富业务信息表
on t1.cst_id=t3.cst_id
and t3.dt='20221231'
inner join (
    select distinct col_14 cst_id,col_8 sale_empe_id
    from qbi_file_20231229_10_24_19
    where pt = MAX_PT('qbi_file_20231229_10_24_19')
)t4 on t1.cst_id=t4.cst_id
where t1.dt='20221231'
;

--销售人20221231数据 5万及以上
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_06;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_06 AS
SElECT sale_empe_id
    ,count(distinct cst_id) 															custs_30_65
    ,count(distinct case when aum_bal>=50000 then cst_id end) 							custs_aum5w
    ,count(distinct case when aum_bal>=50000 and cst_seg='企业主'       then cst_id end) custs_aum5w_qyz
    ,count(distinct case when aum_bal>=50000 and cst_seg='个体工商户'   then cst_id end) custs_aum5w_gtgsh
    ,count(distinct case when aum_bal>=50000 and cst_seg='非持牌个体户' then cst_id end) custs_aum5w_fcp
    ,count(distinct case when aum_bal>=50000 and cst_seg='工薪族'       then cst_id end) custs_aum5w_gx
    ,count(distinct case when aum_bal>=50000 and cst_seg='退休养老'     then cst_id end) custs_aum5w_txyl
    ,count(distinct case when aum_bal>=50000 and cst_seg='持家女性'     then cst_id end) custs_aum5w_cjnx
    ,count(distinct case when aum_bal>=50000 and cst_seg='其他'         then cst_id end) custs_aum5w_qt
    --规模
    ,sum(aum_bal) 																		aum_30_65
    ,sum(case when aum_bal>=50000 then aum_bal else 0 end)  							aum_aum5w
    ,sum(case when aum_bal>=50000 and cst_seg='企业主'       then aum_bal else 0 end) 	aum_aum5w_qyz
    ,sum(case when aum_bal>=50000 and cst_seg='个体工商户'   then aum_bal else 0 end) 	aum_aum5w_gtgsh
    ,sum(case when aum_bal>=50000 and cst_seg='非持牌个体户' then aum_bal else 0 end) 	aum_aum5w_fcp
    ,sum(case when aum_bal>=50000 and cst_seg='工薪族'       then aum_bal else 0 end) 	aum_aum5w_gx
    ,sum(case when aum_bal>=50000 and cst_seg='退休养老'     then aum_bal else 0 end) 	aum_aum5w_txyl
    ,sum(case when aum_bal>=50000 and cst_seg='持家女性'     then aum_bal else 0 end) 	aum_aum5w_cjnx
    ,sum(case when aum_bal>=50000 and cst_seg='其他'         then aum_bal else 0 end) 	aum_aum5w_qt
from SJXQ_SJ2023122901_CST2023_05
where age>=30 and age<=65
and (efe_dep_cst_ind='1' or efe_wlth_cst_ind='1')  --存款或财富有效户
GROUP by sale_empe_id
;
--1万及以上
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_07;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_07 AS
SElECT sale_empe_id
    ,count(distinct cst_id) 															 custs_30_65
    ,count(distinct case when aum_bal>=10000 then cst_id end) 							 custs_aum1w
    ,count(distinct case when aum_bal>=10000 and cst_seg='企业主'       then cst_id end) custs_aum1w_qyz
    ,count(distinct case when aum_bal>=10000 and cst_seg='个体工商户'   then cst_id end) custs_aum1w_gtgsh
    ,count(distinct case when aum_bal>=10000 and cst_seg='非持牌个体户' then cst_id end) custs_aum1w_fcp
    ,count(distinct case when aum_bal>=10000 and cst_seg='工薪族'       then cst_id end) custs_aum1w_gx
    ,count(distinct case when aum_bal>=10000 and cst_seg='退休养老'     then cst_id end) custs_aum1w_txyl
    ,count(distinct case when aum_bal>=10000 and cst_seg='持家女性'     then cst_id end) custs_aum1w_cjnx
    ,count(distinct case when aum_bal>=10000 and cst_seg='其他'         then cst_id end) custs_aum1w_qt
    --规模
    ,sum(aum_bal) 																      aum_30_65
    ,sum(case when aum_bal>=10000 then aum_bal else 0 end)  					      aum_aum1w
    ,sum(case when aum_bal>=10000 and cst_seg='企业主'       then aum_bal else 0 end) aum_aum1w_qyz
    ,sum(case when aum_bal>=10000 and cst_seg='个体工商户'   then aum_bal else 0 end) aum_aum1w_gtgsh
    ,sum(case when aum_bal>=10000 and cst_seg='非持牌个体户' then aum_bal else 0 end) aum_aum1w_fcp
    ,sum(case when aum_bal>=10000 and cst_seg='工薪族'       then aum_bal else 0 end) aum_aum1w_gx
    ,sum(case when aum_bal>=10000 and cst_seg='退休养老'     then aum_bal else 0 end) aum_aum1w_txyl
    ,sum(case when aum_bal>=10000 and cst_seg='持家女性'     then aum_bal else 0 end) aum_aum1w_cjnx
    ,sum(case when aum_bal>=10000 and cst_seg='其他'         then aum_bal else 0 end) aum_aum1w_qt
from SJXQ_SJ2023122901_CST2023_05
where age>=30 and age<=65
and (efe_dep_cst_ind='1' or efe_wlth_cst_ind='1')  --存款或财富有效户
GROUP by sale_empe_id
;
--1万-5万及以上
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_08;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_08 AS
SElECT sale_empe_id
    ,count(distinct cst_id) 																			   custs_30_65
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 then cst_id end) 					       custs_aum1w_5w
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='企业主'       then cst_id end) custs_aum1w_5w_qyz
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='个体工商户'   then cst_id end) custs_aum1w_5w_gtgsh
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='非持牌个体户' then cst_id end) custs_aum1w_5w_fcp
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='工薪族'       then cst_id end) custs_aum1w_5w_gx
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='退休养老'     then cst_id end) custs_aum1w_5w_txyl
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='持家女性'     then cst_id end) custs_aum1w_5w_cjnx
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='其他'         then cst_id end) custs_aum1w_5w_qt
    --规模
    ,sum(aum_bal) 																      aum_30_65
    ,sum(case when aum_bal>=10000 then aum_bal else 0 end) 						      aum_aum1w_5w
    ,sum(case when aum_bal>=10000 and cst_seg='企业主'       then aum_bal else 0 end) aum_aum1w_5w_qyz
    ,sum(case when aum_bal>=10000 and cst_seg='个体工商户'   then aum_bal else 0 end) aum_aum1w_5w_gtgsh
    ,sum(case when aum_bal>=10000 and cst_seg='非持牌个体户' then aum_bal else 0 end) aum_aum1w_5w_fcp
    ,sum(case when aum_bal>=10000 and cst_seg='工薪族'       then aum_bal else 0 end) aum_aum1w_5w_gx
    ,sum(case when aum_bal>=10000 and cst_seg='退休养老'     then aum_bal else 0 end) aum_aum1w_5w_txyl
    ,sum(case when aum_bal>=10000 and cst_seg='持家女性'     then aum_bal else 0 end) aum_aum1w_5w_cjnx
    ,sum(case when aum_bal>=10000 and cst_seg='其他'         then aum_bal else 0 end) aum_aum1w_5w_qt
from SJXQ_SJ2023122901_CST2023_05
where age>=30 and age<=65
and (efe_dep_cst_ind='1' or efe_wlth_cst_ind='1')  --存款或财富有效户
GROUP by sale_empe_id
;

--输出结果：订单维度
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_09;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_09 AS
SElECT seq 		    seq
    ,col_2          交易日期
    ,col_3          公司名称
    ,col_4          产品名称
    ,col_5          保单号
    ,col_6          保单状态
    ,col_7          交易状态
    ,col_8          销售人员工号
    ,col_9          销售人员姓名
    ,col_10         手续费
    ,col_11         交易金额
    ,col_12         投保人姓名
    ,col_13         首期保费
    ,col_14         客户号
    ,col_15         交易日贷款余额
    ,col_16         信用风险等级
    ,col_17         交易日前后15天最近一笔贷款发生额
    ,col_18         交易日前后15天最近一笔贷款期限月
    ,col_19         交易日前后15天最近一笔贷款执行利率
    ,col_20         贷款当月同类型同期限利率水平
    ,col_21         较同期限利率
    ,col_22         是否32万小企业主
    ,col_23         存款年日均
    ,col_24         理财年日均
    ,col_25         财富星级
    ,col_26         所属客群
    ,col_27         年龄
    ,col_28         930挂钩理财余额
    ,col_29         推荐人所属机构所属分行
    ,col_30         交易机构名称
    ,col_31         推荐人所属机构名称
    ,col_32         推荐人工号
    ,col_33         推荐人姓名
    ,col_34         推荐人岗位名称
    ,col_35         管护客户经理工号
    ,col_36         管护客户经理姓名
    ,CASE WHEN T2.CST_ID IS NOT NULL THEN 1 ELSE 0 END  是否同一风险控制号信贷户
    ,CASE WHEN T3.insu_cnt>1 THEN 1 ELSE 0 END          是否复投
    ,CASE WHEN T4.file_dt>='20230101' THEN 1 ELSE 0 END 是否2023新建档客户
    ,T4.gender      客户性别
    ,T5.insu_seg_desc 保险产品类型
from qbi_file_20231229_10_24_19        T1
LEFT JOIN SJXQ_SJ2023122901_CST2023_02 T2
ON T1.col_14 = T2.CST_ID
LEFT JOIN SJXQ_SJ2023122901_CST2023_03 T3
ON T1.col_14 = T3.CST_ID
LEFT JOIN SJXQ_SJ2023122901_CST2023_01 T4
ON T1.col_14 = T4.CST_ID
LEFT JOIN qbi_file_20231229_11_33_49   T5
ON T1.col_4 = T5.insu_pd_nm
AND T5.PT = MAX_PT('lab_bigdata_dev.qbi_file_20231229_11_33_49')
where T1.pt = MAX_PT('qbi_file_20231229_10_24_19')
;

--销售价值型保险信息
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_04;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_04 AS
SElECT t1.col_8         sale_empe_id        --销售人员工号
    ,t5.insu_seg_desc   insu_seg            --4类
    ,case when nvl(t1.col_26,'')='' or t1.col_26='企事业高管' then '其他' else  t1.col_26 end cst_seg  --7类
    ,count(1)       insu_num                --件数
    ,sum(col_10)    mid_inc_tot_amt         --手续费(中收)
    ,sum(col_13)    insu_fee                --首期保费（规模）
from qbi_file_20231229_10_24_19        T1   --保险销售明细
LEFT JOIN qbi_file_20231229_11_33_49   T5   --保险类别
ON T1.col_4 = T5.insu_pd_nm
AND T5.PT = MAX_PT('lab_bigdata_dev.qbi_file_20231229_11_33_49')
where T1.pt = MAX_PT('qbi_file_20231229_10_24_19')
GROUP by t1.col_8,t5.insu_seg_desc,t1.col_26
;

--销售人信息
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_04_1;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_04_1 AS
SElECT DISTINCT
     t1.col_8       sale_empe_id        --销售人员工号
    ,t1.col_9       sale_empe_nm
    ,t4.brc_org_nm
    ,t4.sbr_org_nm
    ,t4.tem_org_nm
from qbi_file_20231229_10_24_19        T1   --保险销售明细
left join edw.dws_hr_empe_inf_dd            t2    --员工信息汇总 empe_id 唯一
on      t1.col_8 = t2.empe_id
and     t2.dt = '20231025'
left join edw.dim_hr_org_mng_org_tree_dd    t4             --考核机构树 4481 org_id 唯一
on      t2.org_id = t4.org_id
and     t4.dt = '20231025'
where T1.pt = MAX_PT('qbi_file_20231229_10_24_19')
;

--销售人输出结果
DROP   TABLE IF     EXISTS SJXQ_SJ2023122901_CST2023_10;
CREATE TABLE IF NOT EXISTS SJXQ_SJ2023122901_CST2023_10 AS
SElECT t1.sale_empe_id          销售人员工号
    ,t1.sale_empe_nm           销售人员姓名
    ,T1.brc_org_nm  销售人分行
    ,T1.sbr_org_nm  销售人支行
    ,T1.tem_org_nm  销售人团队

    ,T4_1.insu_fee          首期保费累计_万能型_个体工商户
    ,T4_1.insu_num          保险件数_万能型_个体工商户
    ,case when T4_1.insu_num>=1 then T4_1.insu_fee/T4_1.insu_num else T4_1.insu_fee end  件均_万能型_个体工商户
    ,T4_1.mid_inc_tot_amt 保险中收_万能型_个体工商户

    ,T4_2.insu_fee     首期保费累计_万能型_企业主
    ,T4_2.insu_num        保险件数_万能型_企业主
    ,case when T4_2.insu_num>=1 then T4_2.insu_fee/T4_2.insu_num else T4_2.insu_fee end  件均_万能型_企业主
    ,T4_2.mid_inc_tot_amt 保险中收_万能型_企业主

    ,T4_3.insu_fee     首期保费累计_万能型_工薪族
    ,T4_3.insu_num        保险件数_万能型_工薪族
    ,case when T4_3.insu_num>=1 then T4_3.insu_fee/T4_3.insu_num else T4_3.insu_fee end  件均_万能型_工薪族
    ,T4_3.mid_inc_tot_amt 保险中收_万能型_工薪族

    ,T4_4.insu_fee     首期保费累计_万能型_退休养老
    ,T4_4.insu_num        保险件数_万能型_退休养老
    ,case when T4_4.insu_num>=1 then T4_4.insu_fee/T4_4.insu_num else T4_4.insu_fee end  件均_万能型_退休养老
    ,T4_4.mid_inc_tot_amt 保险中收_万能型_退休养老

    ,T4_5.insu_fee     首期保费累计_万能型_非持牌个体户
    ,T4_5.insu_num        保险件数_万能型_非持牌个体户
    ,case when T4_5.insu_num>=1 then T4_5.insu_fee/T4_5.insu_num else T4_5.insu_fee end  件均_万能型_非持牌个体户
    ,T4_5.mid_inc_tot_amt 保险中收_万能型_非持牌个体户

    ,T4_6.insu_fee     首期保费累计_万能型_其他
    ,T4_6.insu_num        保险件数_万能型_其他
    ,case when T4_6.insu_num>=1 then T4_6.insu_fee/T4_6.insu_num else T4_6.insu_fee end  件均_万能型_其他
    ,T4_6.mid_inc_tot_amt 保险中收_万能型_其他

    ,T4_7.insu_fee     首期保费累计_万能型_持家女性
    ,T4_7.insu_num        保险件数_万能型_持家女性
    ,case when T4_7.insu_num>=1 then T4_7.insu_fee/T4_7.insu_num else T4_7.insu_fee end  件均_万能型_持家女性
    ,T4_7.mid_inc_tot_amt 保险中收_万能型_持家女性

    ,T4_8.insu_fee     首期保费累计_价值型保险_个体工商户
    ,T4_8.insu_num        保险件数_价值型保险_个体工商户
    ,case when T4_8.insu_num>=1 then T4_8.insu_fee/T4_8.insu_num else T4_8.insu_fee end  件均_价值型保险_个体工商户
    ,T4_8.mid_inc_tot_amt 保险中收_价值型保险_个体工商户

    ,T4_9.insu_fee     首期保费累计_价值型保险_企业主
    ,T4_9.insu_num        保险件数_价值型保险_企业主
    ,case when T4_9.insu_num>=1 then T4_9.insu_fee/T4_9.insu_num else T4_9.insu_fee end  件均_价值型保险_企业主
    ,T4_9.mid_inc_tot_amt 保险中收_价值型保险_企业主

    ,T4_10.insu_fee     首期保费累计_价值型保险_工薪族
    ,T4_10.insu_num        保险件数_价值型保险_工薪族
    ,case when T4_10.insu_num>=1 then T4_10.insu_fee/T4_10.insu_num else T4_10.insu_fee end  件均_价值型保险_工薪族
    ,T4_10.mid_inc_tot_amt 保险中收_价值型保险_工薪族

    ,T4_11.insu_fee     首期保费累计_价值型保险_退休养老
    ,T4_11.insu_num        保险件数_价值型保险_退休养老
    ,case when T4_11.insu_num>=1 then T4_11.insu_fee/T4_11.insu_num else T4_11.insu_fee end  件均_价值型保险_退休养老
    ,T4_11.mid_inc_tot_amt 保险中收_价值型保险_退休养老

    ,T4_12.insu_fee     首期保费累计_价值型保险_非持牌个体户
    ,T4_12.insu_num        保险件数_价值型保险_非持牌个体户
    ,case when T4_12.insu_num>=1 then T4_12.insu_fee/T4_12.insu_num else T4_12.insu_fee end  件均_价值型保险_非持牌个体户
    ,T4_12.mid_inc_tot_amt 保险中收_价值型保险_非持牌个体户

    ,T4_13.insu_fee     首期保费累计_价值型保险_其他
    ,T4_13.insu_num        保险件数_价值型保险_其他
    ,case when T4_13.insu_num>=1 then T4_13.insu_fee/T4_13.insu_num else T4_13.insu_fee end  件均_价值型保险_其他
    ,T4_13.mid_inc_tot_amt 保险中收_价值型保险_其他

    ,T4_14.insu_fee     首期保费累计_价值型保险_持家女性
    ,T4_14.insu_num        保险件数_价值型保险_持家女性
    ,case when T4_14.insu_num>=1 then T4_14.insu_fee/T4_14.insu_num else T4_14.insu_fee end  件均_价值型保险_持家女性
    ,T4_14.mid_inc_tot_amt 保险中收_价值型保险_持家女性

    ,T4_15.insu_fee     首期保费累计_保障类保险_个体工商户
    ,T4_15.insu_num        保险件数_保障类保险_个体工商户
    ,case when T4_15.insu_num>=1 then T4_15.insu_fee/T4_15.insu_num else T4_15.insu_fee end  件均_保障类保险_个体工商户
    ,T4_15.mid_inc_tot_amt 保险中收_保障类保险_个体工商户

    ,T4_16.insu_fee     首期保费累计_保障类保险_企业主
    ,T4_16.insu_num        保险件数_保障类保险_企业主
    ,case when T4_16.insu_num>=1 then T4_16.insu_fee/T4_16.insu_num else T4_16.insu_fee end  件均_保障类保险_企业主
    ,T4_16.mid_inc_tot_amt 保险中收_保障类保险_企业主

    ,T4_17.insu_fee     首期保费累计_保障类保险_工薪族
    ,T4_17.insu_num        保险件数_保障类保险_工薪族
    ,case when T4_17.insu_num>=1 then T4_17.insu_fee/T4_17.insu_num else T4_17.insu_fee end  件均_保障类保险_工薪族
    ,T4_17.mid_inc_tot_amt 保险中收_保障类保险_工薪族

    ,T4_18.insu_fee     首期保费累计_保障类保险_退休养老
    ,T4_18.insu_num        保险件数_保障类保险_退休养老
    ,case when T4_18.insu_num>=1 then T4_18.insu_fee/T4_18.insu_num else T4_18.insu_fee end  件均_保障类保险_退休养老
    ,T4_18.mid_inc_tot_amt 保险中收_保障类保险_退休养老

    ,T4_19.insu_fee     首期保费累计_保障类保险_非持牌个体户
    ,T4_19.insu_num        保险件数_保障类保险_非持牌个体户
    ,case when T4_19.insu_num>=1 then T4_19.insu_fee/T4_19.insu_num else T4_19.insu_fee end  件均_保障类保险_非持牌个体户
    ,T4_19.mid_inc_tot_amt 保险中收_保障类保险_非持牌个体户

    ,T4_20.insu_fee     首期保费累计_保障类保险_其他
    ,T4_20.insu_num        保险件数_保障类保险_其他
    ,case when T4_20.insu_num>=1 then T4_20.insu_fee/T4_20.insu_num else T4_20.insu_fee end  件均_保障类保险_其他
    ,T4_20.mid_inc_tot_amt 保险中收_保障类保险_其他

    ,T4_21.insu_fee     首期保费累计_保障类保险_持家女性
    ,T4_21.insu_num        保险件数_保障类保险_持家女性
    ,case when T4_21.insu_num>=1 then T4_21.insu_fee/T4_21.insu_num else T4_21.insu_fee end  件均_保障类保险_持家女性
    ,T4_21.mid_inc_tot_amt 保险中收_保障类保险_持家女性

    ,T4_22.insu_fee     首期保费累计_理财型保险_个体工商户
    ,T4_22.insu_num        保险件数_理财型保险_个体工商户
    ,case when T4_22.insu_num>=1 then T4_22.insu_fee/T4_22.insu_num else T4_22.insu_fee end  件均_理财型保险_个体工商户
    ,T4_22.mid_inc_tot_amt 保险中收_理财型保险_个体工商户

    ,T4_23.insu_fee     首期保费累计_理财型保险_企业主
    ,T4_23.insu_num        保险件数_理财型保险_企业主
    ,case when T4_23.insu_num>=1 then T4_23.insu_fee/T4_23.insu_num else T4_23.insu_fee end  件均_理财型保险_企业主
    ,T4_23.mid_inc_tot_amt 保险中收_理财型保险_企业主

    ,T4_24.insu_fee     首期保费累计_理财型保险_工薪族
    ,T4_24.insu_num        保险件数_理财型保险_工薪族
    ,case when T4_24.insu_num>=1 then T4_24.insu_fee/T4_24.insu_num else T4_24.insu_fee end  件均_理财型保险_工薪族
    ,T4_24.mid_inc_tot_amt 保险中收_理财型保险_工薪族

    ,T4_25.insu_fee     首期保费累计_理财型保险_退休养老
    ,T4_25.insu_num        保险件数_理财型保险_退休养老
    ,case when T4_25.insu_num>=1 then T4_25.insu_fee/T4_25.insu_num else T4_25.insu_fee end  件均_理财型保险_退休养老
    ,T4_25.mid_inc_tot_amt 保险中收_理财型保险_退休养老

    ,T4_26.insu_fee     首期保费累计_理财型保险_非持牌个体户
    ,T4_26.insu_num        保险件数_理财型保险_非持牌个体户
    ,case when T4_26.insu_num>=1 then T4_26.insu_fee/T4_26.insu_num else T4_26.insu_fee end  件均_理财型保险_非持牌个体户
    ,T4_26.mid_inc_tot_amt 保险中收_理财型保险_非持牌个体户

    ,T4_27.insu_fee     首期保费累计_理财型保险_其他
    ,T4_27.insu_num        保险件数_理财型保险_其他
    ,case when T4_27.insu_num>=1 then T4_27.insu_fee/T4_27.insu_num else T4_27.insu_fee end  件均_理财型保险_其他
    ,T4_27.mid_inc_tot_amt 保险中收_理财型保险_其他

    ,T4_28.insu_fee     首期保费累计_理财型保险_持家女性
    ,T4_28.insu_num        保险件数_理财型保险_持家女性
    ,case when T4_28.insu_num>=1 then T4_28.insu_fee/T4_28.insu_num else T4_28.insu_fee end  件均_理财型保险_持家女性
    ,T4_28.mid_inc_tot_amt 保险中收_理财型保险_持家女性

	,t6.custs_30_65					客户数_大于5w_年龄30_65
	,t6.custs_aum5w                 客户数_大于5w_AUM大于5万
	,t6.custs_aum5w_qyz             客户数_大于5w_企业主
	,t6.custs_aum5w_gtgsh           客户数_大于5w_个体工商户
	,t6.custs_aum5w_fcp             客户数_大于5w_个体非持牌
	,t6.custs_aum5w_gx              客户数_大于5w_工薪
	,t6.custs_aum5w_txyl            客户数_大于5w_退休养老
	,t6.custs_aum5w_cjnx            客户数_大于5w_持家女性
	,t6.custs_aum5w_qt              客户数_大于5w_其他
	,t6.aum_30_65                   规模_大于5w_年龄30_65
	,t6.aum_aum5w                   规模_大于5w_AUM大于5万
	,t6.aum_aum5w_qyz               规模_大于5w_企业主
	,t6.aum_aum5w_gtgsh             规模_大于5w_个体工商户
	,t6.aum_aum5w_fcp               规模_大于5w_个体非持牌
	,t6.aum_aum5w_gx                规模_大于5w_工薪
	,t6.aum_aum5w_txyl              规模_大于5w_退休养老
	,t6.aum_aum5w_cjnx              规模_大于5w_持家女性
	,t6.aum_aum5w_qt                规模_大于5w_其他
	,t7.custs_30_65                 客户数_大于1w_年龄30_65
	,t7.custs_aum1w                 客户数_大于1w_AUM大于5万
	,t7.custs_aum1w_qyz             客户数_大于1w_企业主
	,t7.custs_aum1w_gtgsh           客户数_大于1w_个体工商户
	,t7.custs_aum1w_fcp             客户数_大于1w_个体非持牌
	,t7.custs_aum1w_gx              客户数_大于1w_工薪
	,t7.custs_aum1w_txyl            客户数_大于1w_退休养老
	,t7.custs_aum1w_cjnx            客户数_大于1w_持家女性
	,t7.custs_aum1w_qt              客户数_大于1w_其他
	,t7.aum_30_65                   规模_大于1w_年龄30_65
	,t7.aum_aum1w                   规模_大于1w_AUM大于5万
	,t7.aum_aum1w_qyz               规模_大于1w_企业主
	,t7.aum_aum1w_gtgsh             规模_大于1w_个体工商户
	,t7.aum_aum1w_fcp               规模_大于1w_个体非持牌
	,t7.aum_aum1w_gx                规模_大于1w_工薪
	,t7.aum_aum1w_txyl              规模_大于1w_退休养老
	,t7.aum_aum1w_cjnx              规模_大于1w_持家女性
	,t7.aum_aum1w_qt                规模_大于1w_其他
	,t8.custs_30_65                 客户数_1w_5w_年龄30_65
	,t8.custs_aum1w_5w              客户数_1w_5w_AUM大于5万
	,t8.custs_aum1w_5w_qyz          客户数_1w_5w_企业主
	,t8.custs_aum1w_5w_gtgsh        客户数_1w_5w_个体工商户
	,t8.custs_aum1w_5w_fcp          客户数_1w_5w_个体非持牌
	,t8.custs_aum1w_5w_gx           客户数_1w_5w_工薪
	,t8.custs_aum1w_5w_txyl         客户数_1w_5w_退休养老
	,t8.custs_aum1w_5w_cjnx         客户数_1w_5w_持家女性
	,t8.custs_aum1w_5w_qt           客户数_1w_5w_其他
	,t8.aum_30_65                   规模_1w_5w_年龄30_65
	,t8.aum_aum1w_5w                规模_1w_5w_AUM大于5万
	,t8.aum_aum1w_5w_qyz            规模_1w_5w_企业主
	,t8.aum_aum1w_5w_gtgsh          规模_1w_5w_个体工商户
	,t8.aum_aum1w_5w_fcp            规模_1w_5w_个体非持牌
	,t8.aum_aum1w_5w_gx             规模_1w_5w_工薪
	,t8.aum_aum1w_5w_txyl           规模_1w_5w_退休养老
	,t8.aum_aum1w_5w_cjnx           规模_1w_5w_持家女性
	,t8.aum_aum1w_5w_qt             规模_1w_5w_其他
from SJXQ_SJ2023122901_CST2023_04_1     T1
LEFT JOIN SJXQ_SJ2023122901_CST2023_06  T6
ON T1.sale_empe_id = T6.sale_empe_id
LEFT JOIN SJXQ_SJ2023122901_CST2023_07  T7
ON T1.sale_empe_id = T7.sale_empe_id
LEFT JOIN SJXQ_SJ2023122901_CST2023_08  T8
ON T1.sale_empe_id = T8.sale_empe_id
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_1  ON T1.sale_empe_id = T4_1.sale_empe_id  and T4_1.insu_seg='万能型'     and T4_1.cst_seg='个体工商户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_2  ON T1.sale_empe_id = T4_2.sale_empe_id  and T4_2.insu_seg='万能型'     and T4_2.cst_seg='企业主'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_3  ON T1.sale_empe_id = T4_3.sale_empe_id  and T4_3.insu_seg='万能型'     and T4_3.cst_seg='工薪族'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_4  ON T1.sale_empe_id = T4_4.sale_empe_id  and T4_4.insu_seg='万能型'     and T4_4.cst_seg='退休养老'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_5  ON T1.sale_empe_id = T4_5.sale_empe_id  and T4_5.insu_seg='万能型'     and T4_5.cst_seg='非持牌个体户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_6  ON T1.sale_empe_id = T4_6.sale_empe_id  and T4_6.insu_seg='万能型'     and T4_6.cst_seg='其他'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_7  ON T1.sale_empe_id = T4_7.sale_empe_id  and T4_7.insu_seg='万能型'     and T4_7.cst_seg='持家女性'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_8  ON T1.sale_empe_id = T4_8.sale_empe_id  and T4_8.insu_seg='价值型保险' and T4_8.cst_seg='个体工商户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_9  ON T1.sale_empe_id = T4_9.sale_empe_id  and T4_9.insu_seg='价值型保险' and T4_9.cst_seg='企业主'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_10 ON T1.sale_empe_id = T4_10.sale_empe_id and T4_10.insu_seg='价值型保险' and T4_10.cst_seg='工薪族'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_11 ON T1.sale_empe_id = T4_11.sale_empe_id and T4_11.insu_seg='价值型保险' and T4_11.cst_seg='退休养老'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_12 ON T1.sale_empe_id = T4_12.sale_empe_id and T4_12.insu_seg='价值型保险' and T4_12.cst_seg='非持牌个体户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_13 ON T1.sale_empe_id = T4_13.sale_empe_id and T4_13.insu_seg='价值型保险' and T4_13.cst_seg='其他'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_14 ON T1.sale_empe_id = T4_14.sale_empe_id and T4_14.insu_seg='价值型保险' and T4_14.cst_seg='持家女性'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_15 ON T1.sale_empe_id = T4_15.sale_empe_id and T4_15.insu_seg='保障类保险' and T4_15.cst_seg='个体工商户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_16 ON T1.sale_empe_id = T4_16.sale_empe_id and T4_16.insu_seg='保障类保险' and T4_16.cst_seg='企业主'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_17 ON T1.sale_empe_id = T4_17.sale_empe_id and T4_17.insu_seg='保障类保险' and T4_17.cst_seg='工薪族'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_18 ON T1.sale_empe_id = T4_18.sale_empe_id and T4_18.insu_seg='保障类保险' and T4_18.cst_seg='退休养老'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_19 ON T1.sale_empe_id = T4_19.sale_empe_id and T4_19.insu_seg='保障类保险' and T4_19.cst_seg='非持牌个体户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_20 ON T1.sale_empe_id = T4_20.sale_empe_id and T4_20.insu_seg='保障类保险' and T4_20.cst_seg='其他'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_21 ON T1.sale_empe_id = T4_21.sale_empe_id and T4_21.insu_seg='保障类保险' and T4_21.cst_seg='持家女性'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_22 ON T1.sale_empe_id = T4_22.sale_empe_id and T4_22.insu_seg='理财型保险' and T4_22.cst_seg='个体工商户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_23 ON T1.sale_empe_id = T4_23.sale_empe_id and T4_23.insu_seg='理财型保险' and T4_23.cst_seg='企业主'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_24 ON T1.sale_empe_id = T4_24.sale_empe_id and T4_24.insu_seg='理财型保险' and T4_24.cst_seg='工薪族'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_25 ON T1.sale_empe_id = T4_25.sale_empe_id and T4_25.insu_seg='理财型保险' and T4_25.cst_seg='退休养老'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_26 ON T1.sale_empe_id = T4_26.sale_empe_id and T4_26.insu_seg='理财型保险' and T4_26.cst_seg='非持牌个体户'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_27 ON T1.sale_empe_id = T4_27.sale_empe_id and T4_27.insu_seg='理财型保险' and T4_27.cst_seg='其他'
LEFT JOIN SJXQ_SJ2023122901_CST2023_04 T4_28 ON T1.sale_empe_id = T4_28.sale_empe_id and T4_28.insu_seg='理财型保险' and T4_28.cst_seg='持家女性'
;



**SJ2023122901-贵金属22年销售底表.sql
--2023年 贵金属购买信息汇总
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST2022_01;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST2022_01 AS
SElECT ord_id               --订单号
    ,ord_tm TRX_DT          --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc TRX_AMT --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'dtl' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di --贵金属交易明细表
where dt<='@@{yyyyMMdd}'
and ord_tm >= '2022-01-01' and ord_tm <= '2022-12-31'
union all
SElECT ord_id               --订单号
    ,ord_tm                 --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc       --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'hand' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_hand_di	--贵金属柜面或退款交易手工表
where dt<='@@{yyyyMMdd}'
and ord_tm >= '2022-01-01' and ord_tm <= '2022-12-31'
;

--是否贵金属新客（历史无交易）
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST2022_02;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST2022_02 AS
SElECT cst_id                 --客户号
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di     --贵金属交易明细表
where dt < '20220101'
and ord_tm < '2022-01-01'
union
SElECT cst_id                 --客户号
from adm_pub.adm_pub_cst_nob_met_trx_hand_di    --贵金属柜面或退款交易手工表
where dt < '20220101'
and ord_tm < '2022-01-01'
;

--客户年龄	客户性别 		是否23年新开卡客户
--客户23年存款日均	客户23年理财日均	客户财富等级		八大客群
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST2022_03;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST2022_03 AS
select t1.cst_id,t1.cst_chn_nm,t1.file_dt,t1.sam_rsk_ctrl_id
    ,decode(t2.cst_seg_flg,'1','企业主','2','个体工商户','3','企事业高管','4','非持牌个体户','5','工薪族','6','退休养老','7','持家女性','未知') cst_seg
    ,t3.age
    ,decode(t3.gdr_cd,'1','男','2','女','未知') gender
    ,t3.AUM_GRD,t3.dep_bal_year_avg,t3.fnc_year_avg_amt
    ,t3.efe_loan_cst_ind		-- 有效贷款户
from edw.dws_cst_bas_inf_dd 		            t1 	--客户基础信息汇总表
left join adm_pub.adm_csm_clab_cst_jc_inf_dd    t2  --客户标签信息
on t1.cst_id=t2.cst_id
and t2.dt='20221231'
left join app_rpt.adm_subl_cst_wlth_bus_inf_dd 	t3  --正式客户财富业务信息表
on t1.cst_id=t3.cst_id
and t3.dt='20221231'
where t1.dt='20221231'
;

--客户历史保险金额
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST2022_04;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST2022_04 AS
SElECT cst_id
    ,sum(insu_fee) his_insu_fee
    ,sum(insu_amt) his_insu_amt
from edw.dwd_bus_insu_plcy_insu_inf_dd
where dt = '20221231'
and INSU_PLCY_STS in ('0','A') --'正常','退保','满期退保'
and cst_id <> ''
group by cst_id
;

--是否同一风险控制号信贷户 跑不出来
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST2022_05;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST2022_05 AS
SELECT  T1.CST_ID
FROM    SJXQ_SJ20231228_CST2022_03 T1
INNER JOIN    (
                  SELECT  DISTINCT cst_id
                  FROM    SJXQ_SJ20231228_CST2022_01
              ) t2
ON      t1.cst_id = t2.cst_id
LEFT JOIN    SJXQ_SJ20231228_CST2022_03 T3
ON      T1.sam_rsk_ctrl_id = T3.sam_rsk_ctrl_id
where nvl(t1.sam_rsk_ctrl_id,'')<>''        --不限制会跑不出来
GROUP BY T1.CST_ID , T1.sam_rsk_ctrl_id
having MAX(T3.efe_loan_cst_ind) = '1'
;


--字段汇总
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST2022_06;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST2022_06 AS
SElECT t1.data_src				数据来源
    ,t1.trx_dt                  下单日期
    ,t1.cst_id                  客户号
    ,t1.cst_nm                  客户姓名
    ,t1.cmdt_nm                 产品名称
    ,t1.pvd_nm                  供应商
    ,t1.goods_typ               产品类型
    ,t1.cmdt_unt_prc            产品单价
    ,t1.qty                     购买数量
    ,t1.trx_amt                 购买金额
    ,t1.mid_inc_tot_amt         产品中收
    ,t1.rcm_psn_id              推荐人工号
    ,t1.rcm_psn_nm              推荐人姓名
    ,t1.rcm_psn_afl_dept_id     推荐人所属部门_团队id
    ,t1.rcm_psn_afl_dept        推荐人所属部门_团队
    ,t1.rcm_psn_afl_brn         分行名称
    ,t1.rcm_psn_pos             推荐人岗位
    ,t3.dep_bal_year_avg        客户22年存款日均
    ,t3.fnc_year_avg_amt        客户22年理财日均
    ,t3.AUM_GRD                 客户财富等级
    ,t4.his_insu_fee            客户历史保险费用
    ,t4.his_insu_amt            客户历史保险金额
    ,t3.cst_seg                 八大客群
    ,t3.age                     客户年龄
    ,case when t5.cst_id is not null then 1 else 0 end  是否同一风险控制号信贷户
    ,t3.gender                  客户性别
    ,case when t3.file_dt>='20220101' then 1 else 0 end 是否22年新开卡客户
    ,case when t2.cst_id is null then 1 else 0 end      是否22年贵金属新客_历史无交易
from SJXQ_SJ20231228_CST2022_01         t1
left join SJXQ_SJ20231228_CST2022_02    t2 on t1.cst_id=t2.cst_id
left join SJXQ_SJ20231228_CST2022_03    t3 on t1.cst_id=t3.cst_id
left join SJXQ_SJ20231228_CST2022_04    t4 on t1.cst_id=t4.cst_id
left join SJXQ_SJ20231228_CST2022_05    t5 on t1.cst_id=t5.cst_id
;
**SJ2023122901-贵金属23年销售底表.sql
--2023年 贵金属购买信息汇总
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_01;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_01 AS
SElECT ord_id               --订单号
    ,ord_tm TRX_DT          --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc TRX_AMT --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'dtl' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di --贵金属交易明细表
where dt >= '20230101'
and ord_tm >= '2023-01-01'
union all
SElECT ord_id               --订单号
    ,ord_tm                 --订单时间
    ,cst_id                 --客户号
    ,cst_nm                 --客户名称
    ,usr_nm                 --用户名
    ,pvd_nm                 --商铺名称
    ,pst_mth                --邮寄方式
    ,pmt_tm                 --付款时间
    ,pmt_mth                --支付方式
    ,chnl_nm                --渠道
    ,ord_sts                --订单状态
    ,cmdt_nm                --商品名称
    ,cmdt_spec              --商品规格
    ,qty                    --数量
    ,goods_typ              --商品分类
    ,goods_return_status    --商品退款状态
    ,cmdt_unt_prc           --商品现金单价
    ,cmdt_pay_unt_prc       --商品应付现金总额
    ,cmsn_typ               --佣金类型
    ,mid_inc_rto            --佣金比例/金额
    ,mid_inc_tot_amt        --佣金总额
    ,rcm_psn_id             --推荐人工号
    ,rcm_psn_nm             --推荐人姓名
    ,rcm_psn_afl_dept_id    --推荐人所属部门/团队ID
    ,rcm_psn_afl_dept       --推荐人所属部门/团队
    ,rcm_psn_afl_sub_brn    --推荐人所属支行
    ,rcm_psn_afl_brn        --推荐人所属分行
    ,data_src               --数据来源
    ,rcm_psn_pos            --员工岗位
    ,dt
    ,'hand' data_src2
from adm_pub.adm_pub_cst_nob_met_trx_hand_di	--贵金属柜面或退款交易手工表
where dt >= '20230101'
and ord_tm >= '2023-01-01'
;

--是否贵金属新客（历史无交易）
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_02;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_02 AS
SElECT cst_id                 --客户号
from adm_pub.adm_pub_cst_nob_met_trx_dtl_di     --贵金属交易明细表
where dt < '20230101'
and ord_tm < '2023-01-01'
union
SElECT cst_id                 --客户号
from adm_pub.adm_pub_cst_nob_met_trx_hand_di    --贵金属柜面或退款交易手工表
where dt < '20230101'
and ord_tm < '2023-01-01'
;

--客户年龄	客户性别 		是否23年新开卡客户
--客户23年存款日均	客户23年理财日均	客户财富等级		八大客群
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_03;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_03 AS
select t1.cst_id,t1.cst_chn_nm,t1.file_dt,t1.sam_rsk_ctrl_id
    ,decode(t2.cst_seg_flg,'1','企业主','2','个体工商户','3','企事业高管','4','非持牌个体户','5','工薪族','6','退休养老','7','持家女性','未知') cst_seg
    ,t3.age
    ,decode(t3.gdr_cd,'1','男','2','女','未知') gender
    ,t3.AUM_GRD,t3.dep_bal_year_avg,t3.fnc_year_avg_amt
    ,t3.efe_loan_cst_ind		-- 有效贷款户
from edw.dws_cst_bas_inf_dd 		            t1 	--客户基础信息汇总表
left join adm_pub.adm_csm_clab_cst_jc_inf_dd    t2  --客户标签信息
on t1.cst_id=t2.cst_id
and t2.dt='@@{yyyyMMdd}'
left join app_rpt.adm_subl_cst_wlth_bus_inf_dd 	t3  --正式客户财富业务信息表
on t1.cst_id=t3.cst_id
and t3.dt='@@{yyyyMMdd}'
where t1.dt='@@{yyyyMMdd}'
;

--客户历史保险金额
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_04;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_04 AS
SElECT cst_id
    ,sum(insu_fee) his_insu_fee
    ,sum(insu_amt) his_insu_amt
from edw.dwd_bus_insu_plcy_insu_inf_dd
where dt = '20230101'
and INSU_PLCY_STS in ('0','A') --'正常','退保','满期退保'
and cst_id <> ''
group by cst_id
;

--是否同一风险控制号信贷户 跑不出来
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_05;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_05 AS
SELECT  T1.CST_ID
FROM    SJXQ_SJ20231228_CST_03 T1
INNER JOIN    (
                  SELECT  DISTINCT cst_id
                  FROM    SJXQ_SJ20231228_CST_01
              ) t2
ON      t1.cst_id = t2.cst_id
LEFT JOIN    SJXQ_SJ20231228_CST_03 T3
ON      T1.sam_rsk_ctrl_id = T3.sam_rsk_ctrl_id
where nvl(t1.sam_rsk_ctrl_id,'')<>''        --不限制会跑不出来
GROUP BY T1.CST_ID , T1.sam_rsk_ctrl_id
having MAX(T3.efe_loan_cst_ind) = '1'
;


--字段汇总
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_06;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_06 AS
SElECT t1.data_src				数据来源
    ,t1.trx_dt                  下单日期
    ,t1.cst_id                  客户号
    ,t1.cst_nm                  客户姓名
    ,t1.cmdt_nm                 产品名称
    ,t1.pvd_nm                  供应商
    ,t1.goods_typ               产品类型
    ,t1.cmdt_unt_prc            产品单价
    ,t1.qty                     购买数量
    ,t1.trx_amt                 购买金额
    ,t1.mid_inc_tot_amt         产品中收
    ,t1.rcm_psn_id              推荐人工号
    ,t1.rcm_psn_nm              推荐人姓名
    ,t1.rcm_psn_afl_dept_id     推荐人所属部门_团队id
    ,t1.rcm_psn_afl_dept        推荐人所属部门_团队
    ,t1.rcm_psn_afl_brn         分行名称
    ,t1.rcm_psn_pos             推荐人岗位
    ,t3.dep_bal_year_avg        客户23年存款日均
    ,t3.fnc_year_avg_amt        客户23年理财日均
    ,t3.AUM_GRD                 客户财富等级
    ,t4.his_insu_fee            客户历史保险费用
    ,t4.his_insu_amt            客户历史保险金额
    ,t3.cst_seg                 八大客群
    ,t3.age                     客户年龄
    ,case when t5.cst_id is not null then 1 else 0 end  是否同一风险控制号信贷户
    ,t3.gender                  客户性别
    ,case when t3.file_dt>='20230101' then 1 else 0 end 是否23年新开卡客户
    ,case when t2.cst_id is null then 1 else 0 end      是否贵金属新客_历史无交易
from SJXQ_SJ20231228_CST_01         t1
left join SJXQ_SJ20231228_CST_02    t2 on t1.cst_id=t2.cst_id
left join SJXQ_SJ20231228_CST_03    t3 on t1.cst_id=t3.cst_id
left join SJXQ_SJ20231228_CST_04    t4 on t1.cst_id=t4.cst_id
left join SJXQ_SJ20231228_CST_05    t5 on t1.cst_id=t5.cst_id
;


--客户 20221231 数据
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_07;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_07 AS
select t1.cst_id,t1.cst_chn_nm,t1.file_dt,t1.sam_rsk_ctrl_id
    ,decode(t2.cst_seg_flg,'1','企业主','2','个体工商户','4','非持牌个体户','5'
        ,'工薪族','6','退休养老','7','持家女性','其他') cst_seg
    ,t3.age
    ,decode(t3.gdr_cd,'1','男','2','女','未知') gender
    ,t3.AUM_GRD,t3.dep_bal_year_avg,t3.fnc_year_avg_amt
    ,t3.efe_loan_cst_ind		-- 有效贷款户
    ,t3.efe_dep_cst_ind,t3.efe_wlth_cst_ind,t3.efe_chm_cst_ind  --存款、财富
    ,t3.aum_bal
    ,t3.prm_mgr_id
    ,t3.wlth_mng_mnl_id
from edw.dws_cst_bas_inf_dd 		            t1 	--客户基础信息汇总表
left join adm_pub.adm_csm_clab_cst_jc_inf_dd    t2  --客户标签信息
on t1.cst_id=t2.cst_id
and t2.dt='20221231'
left join app_rpt.adm_subl_cst_wlth_bus_inf_dd 	t3  --正式客户财富业务信息表
on t1.cst_id=t3.cst_id
and t3.dt='20221231'
inner join (
    select distinct 客户号 cst_id
    from SJXQ_SJ20231228_CST_06
)t4 on t1.cst_id=t4.cst_id
where t1.dt='20221231'
;

DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_07_1;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_07_1 AS
select t1.客户号        cst_id
    ,t1.推荐人工号      rcm_empe_id
    ,t2.efe_dep_cst_ind,t2.efe_wlth_cst_ind
    ,t2.age,t2.aum_bal,t2.cst_seg
from SJXQ_SJ20231228_CST_06 T1
LEFT JOIN SJXQ_SJ20231228_CST_07 T2
ON T1.客户号=T2.CST_ID
;

--推荐人20221231数据 30万及以上
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_08;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_08 AS
SElECT rcm_empe_id
    ,count(distinct cst_id) 															 custs_25_80
    ,count(distinct case when aum_bal>=50000 then cst_id end) 							 custs_aum30w
    ,count(distinct case when aum_bal>=50000 and cst_seg='企业主'       then cst_id end) custs_aum30w_qyz
    ,count(distinct case when aum_bal>=50000 and cst_seg='个体工商户'   then cst_id end) custs_aum30w_gtgsh
    ,count(distinct case when aum_bal>=50000 and cst_seg='非持牌个体户' then cst_id end) custs_aum30w_fcp
    ,count(distinct case when aum_bal>=50000 and cst_seg='工薪族'       then cst_id end) custs_aum30w_gx
    ,count(distinct case when aum_bal>=50000 and cst_seg='退休养老'     then cst_id end) custs_aum30w_txyl
    ,count(distinct case when aum_bal>=50000 and cst_seg='持家女性'     then cst_id end) custs_aum30w_cjnx
    ,count(distinct case when aum_bal>=50000 and cst_seg='其他'         then cst_id end) custs_aum30w_qt
    --规模
    ,sum(aum_bal) 																		aum_25_80
    ,sum(case when aum_bal>=50000 then aum_bal else 0 end)  							aum_aum30w
    ,sum(case when aum_bal>=50000 and cst_seg='企业主'       then aum_bal else 0 end) 	aum_aum30w_qyz
    ,sum(case when aum_bal>=50000 and cst_seg='个体工商户'   then aum_bal else 0 end) 	aum_aum30w_gtgsh
    ,sum(case when aum_bal>=50000 and cst_seg='非持牌个体户' then aum_bal else 0 end) 	aum_aum30w_fcp
    ,sum(case when aum_bal>=50000 and cst_seg='工薪族'       then aum_bal else 0 end) 	aum_aum30w_gx
    ,sum(case when aum_bal>=50000 and cst_seg='退休养老'     then aum_bal else 0 end) 	aum_aum30w_txyl
    ,sum(case when aum_bal>=50000 and cst_seg='持家女性'     then aum_bal else 0 end) 	aum_aum30w_cjnx
    ,sum(case when aum_bal>=50000 and cst_seg='其他'         then aum_bal else 0 end) 	aum_aum30w_qt
from SJXQ_SJ20231228_CST_07_1
where age>=25 and age<=80
and (efe_dep_cst_ind='1' or efe_wlth_cst_ind='1')  --存款或财富有效户
GROUP by rcm_empe_id
;
--5万及以上
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_09;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_09 AS
SElECT rcm_empe_id
    ,count(distinct cst_id) 															 custs_25_80
    ,count(distinct case when aum_bal>=10000 then cst_id end) 							 custs_aum5w
    ,count(distinct case when aum_bal>=10000 and cst_seg='企业主'       then cst_id end) custs_aum5w_qyz
    ,count(distinct case when aum_bal>=10000 and cst_seg='个体工商户'   then cst_id end) custs_aum5w_gtgsh
    ,count(distinct case when aum_bal>=10000 and cst_seg='非持牌个体户' then cst_id end) custs_aum5w_fcp
    ,count(distinct case when aum_bal>=10000 and cst_seg='工薪族'       then cst_id end) custs_aum5w_gx
    ,count(distinct case when aum_bal>=10000 and cst_seg='退休养老'     then cst_id end) custs_aum5w_txyl
    ,count(distinct case when aum_bal>=10000 and cst_seg='持家女性'     then cst_id end) custs_aum5w_cjnx
    ,count(distinct case when aum_bal>=10000 and cst_seg='其他'         then cst_id end) custs_aum5w_qt
    --规模
    ,sum(aum_bal) 																      aum_25_80
    ,sum(case when aum_bal>=10000 then aum_bal else 0 end)  					      aum_aum5w
    ,sum(case when aum_bal>=10000 and cst_seg='企业主'       then aum_bal else 0 end) aum_aum5w_qyz
    ,sum(case when aum_bal>=10000 and cst_seg='个体工商户'   then aum_bal else 0 end) aum_aum5w_gtgsh
    ,sum(case when aum_bal>=10000 and cst_seg='非持牌个体户' then aum_bal else 0 end) aum_aum5w_fcp
    ,sum(case when aum_bal>=10000 and cst_seg='工薪族'       then aum_bal else 0 end) aum_aum5w_gx
    ,sum(case when aum_bal>=10000 and cst_seg='退休养老'     then aum_bal else 0 end) aum_aum5w_txyl
    ,sum(case when aum_bal>=10000 and cst_seg='持家女性'     then aum_bal else 0 end) aum_aum5w_cjnx
    ,sum(case when aum_bal>=10000 and cst_seg='其他'         then aum_bal else 0 end) aum_aum5w_qt
from SJXQ_SJ20231228_CST_07_1
where age>=25 and age<=80
and (efe_dep_cst_ind='1' or efe_wlth_cst_ind='1')  --存款或财富有效户
GROUP by rcm_empe_id
;
--10万及以上
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_10;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_10 AS
SElECT rcm_empe_id
    ,count(distinct cst_id) 																			   custs_25_70
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 then cst_id end) 					       custs_aum10w
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='企业主'       then cst_id end) custs_aum10w_qyz
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='个体工商户'   then cst_id end) custs_aum10w_gtgsh
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='非持牌个体户' then cst_id end) custs_aum10w_fcp
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='工薪族'       then cst_id end) custs_aum10w_gx
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='退休养老'     then cst_id end) custs_aum10w_txyl
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='持家女性'     then cst_id end) custs_aum10w_cjnx
    ,count(distinct case when aum_bal>=10000 and aum_bal<50000 and cst_seg='其他'         then cst_id end) custs_aum10w_qt
    --规模
    ,sum(aum_bal) 																      aum_25_70
    ,sum(case when aum_bal>=10000 then aum_bal else 0 end) 						      aum_aum10w
    ,sum(case when aum_bal>=10000 and cst_seg='企业主'       then aum_bal else 0 end) aum_aum10w_qyz
    ,sum(case when aum_bal>=10000 and cst_seg='个体工商户'   then aum_bal else 0 end) aum_aum10w_gtgsh
    ,sum(case when aum_bal>=10000 and cst_seg='非持牌个体户' then aum_bal else 0 end) aum_aum10w_fcp
    ,sum(case when aum_bal>=10000 and cst_seg='工薪族'       then aum_bal else 0 end) aum_aum10w_gx
    ,sum(case when aum_bal>=10000 and cst_seg='退休养老'     then aum_bal else 0 end) aum_aum10w_txyl
    ,sum(case when aum_bal>=10000 and cst_seg='持家女性'     then aum_bal else 0 end) aum_aum10w_cjnx
    ,sum(case when aum_bal>=10000 and cst_seg='其他'         then aum_bal else 0 end) aum_aum10w_qt
from SJXQ_SJ20231228_CST_07_1
where age>=25 and age<=70
and (efe_dep_cst_ind='1' or efe_wlth_cst_ind='1')  --存款或财富有效户
GROUP by rcm_empe_id
;

--输出结果：订单维度
SElECT *
from SJXQ_SJ20231228_CST_06
;

--贵金属推荐人维度汇总
DROP   TABLE IF     EXISTS SJXQ_SJ20231228_CST_11;
CREATE TABLE IF NOT EXISTS SJXQ_SJ20231228_CST_11 AS
SElECT t1.推荐人工号
    ,t1.推荐人姓名
    ,t1.推荐人所属部门_团队id
    ,t1.推荐人所属部门_团队
    ,t1.分行名称
    ,t1.推荐人岗位

    ,t8.custs_25_80				客户数_大于30w_年龄25_80
	,t8.custs_aum30w            客户数_大于30w_AUM大于5万
	,t8.custs_aum30w_qyz        客户数_大于30w_企业主
	,t8.custs_aum30w_gtgsh      客户数_大于30w_个体工商户
	,t8.custs_aum30w_fcp        客户数_大于30w_个体非持牌
	,t8.custs_aum30w_gx         客户数_大于30w_工薪
	,t8.custs_aum30w_txyl       客户数_大于30w_退休养老
	,t8.custs_aum30w_cjnx       客户数_大于30w_持家女性
	,t8.custs_aum30w_qt         客户数_大于30w_其他
	,t8.aum_25_80               规模_大于30w_年龄25_80
	,t8.aum_aum30w              规模_大于30w_AUM大于5万
	,t8.aum_aum30w_qyz          规模_大于30w_企业主
	,t8.aum_aum30w_gtgsh        规模_大于30w_个体工商户
	,t8.aum_aum30w_fcp          规模_大于30w_个体非持牌
	,t8.aum_aum30w_gx           规模_大于30w_工薪
	,t8.aum_aum30w_txyl         规模_大于30w_退休养老
	,t8.aum_aum30w_cjnx         规模_大于30w_持家女性
	,t8.aum_aum30w_qt           规模_大于30w_其他

    ,t9.custs_25_80				客户数_大于5w_年龄25_80
	,t9.custs_aum5w             客户数_大于5w_AUM大于5万
	,t9.custs_aum5w_qyz         客户数_大于5w_企业主
	,t9.custs_aum5w_gtgsh       客户数_大于5w_个体工商户
	,t9.custs_aum5w_fcp         客户数_大于5w_个体非持牌
	,t9.custs_aum5w_gx          客户数_大于5w_工薪
	,t9.custs_aum5w_txyl        客户数_大于5w_退休养老
	,t9.custs_aum5w_cjnx        客户数_大于5w_持家女性
	,t9.custs_aum5w_qt          客户数_大于5w_其他
	,t9.aum_25_80               规模_大于5w_年龄25_80
	,t9.aum_aum5w               规模_大于5w_AUM大于5万
	,t9.aum_aum5w_qyz           规模_大于5w_企业主
	,t9.aum_aum5w_gtgsh         规模_大于5w_个体工商户
	,t9.aum_aum5w_fcp           规模_大于5w_个体非持牌
	,t9.aum_aum5w_gx            规模_大于5w_工薪
	,t9.aum_aum5w_txyl          规模_大于5w_退休养老
	,t9.aum_aum5w_cjnx          规模_大于5w_持家女性
	,t9.aum_aum5w_qt            规模_大于5w_其他

    ,t10.custs_25_70			客户数_大于10w_年龄25_70
	,t10.custs_aum10w           客户数_大于10w_AUM大于5万
	,t10.custs_aum10w_qyz       客户数_大于10w_企业主
	,t10.custs_aum10w_gtgsh     客户数_大于10w_个体工商户
	,t10.custs_aum10w_fcp       客户数_大于10w_个体非持牌
	,t10.custs_aum10w_gx        客户数_大于10w_工薪
	,t10.custs_aum10w_txyl      客户数_大于10w_退休养老
	,t10.custs_aum10w_cjnx      客户数_大于10w_持家女性
	,t10.custs_aum10w_qt        客户数_大于10w_其他
	,t10.aum_25_70              规模_大于10w_年龄25_70
	,t10.aum_aum10w             规模_大于10w_AUM大于5万
	,t10.aum_aum10w_qyz         规模_大于10w_企业主
	,t10.aum_aum10w_gtgsh       规模_大于10w_个体工商户
	,t10.aum_aum10w_fcp         规模_大于10w_个体非持牌
	,t10.aum_aum10w_gx          规模_大于10w_工薪
	,t10.aum_aum10w_txyl        规模_大于10w_退休养老
	,t10.aum_aum10w_cjnx        规模_大于10w_持家女性
	,t10.aum_aum10w_qt          规模_大于10w_其他
from(
    SElECT distinct 推荐人工号
        ,推荐人姓名
        ,推荐人所属部门_团队id
        ,推荐人所属部门_团队
        ,分行名称
        ,推荐人岗位
    from SJXQ_SJ20231228_CST_06
    where nvl(推荐人姓名,'')<>''
    and  推荐人工号<>'000000'
)t1 left join SJXQ_SJ20231228_CST_08 t8
on t1.推荐人工号=t8.rcm_empe_id
left join SJXQ_SJ20231228_CST_09 t9
on t1.推荐人工号=t9.rcm_empe_id
left join SJXQ_SJ20231228_CST_10 t10
on t1.推荐人工号=t10.rcm_empe_id
;

