use anacredit


SELECT * FROM stg.F_BIC WHERE BIC LIKE 'ETHNCYNN%'

--NATIONAL BANK OF GREECE S.A. CYPRUS BRANCH (578)
SELECT TOP 10 * FROM dbo.CRD WHERE CID='ETHNCYNNXXX' AND REF_DT='2024-02-29'
SELECT TOP 10 * FROM dbo.CRD WHERE CID='ETHNCYNNXXX' AND REF_DT='2024-03-31'

SELECT TOP 10 * FROM EDW.cst.CST WHERE CST_NM

SELECT * FROM dbo.SPRT_CST_ADD ORDER BY CID_OLD

[cst].[CST_MIGR]

SELECT TOP 10 * FROM EDW.CST.ORG_FIN_STMNT_DTLS
SELECT TOP 10 * FROM [dbo].[REF_ACTY_TYPE]

--org_cst_dt   
if OBJECT_ID('tempdb.dbo.#org_fstd') is NOT NULL drop table #org_fstd
Select CLNT_ID,STMT_CURR ,ROW_NUMBER() OVER(PARTITION BY CLNT_ID ORDER BY [DT_FIN_STMNT] desc) AS RN
into #org_fstd
	from [src].[EDW_CST_ORG_FIN_STMNT_DTLS]
	where [STMT_CURR]= 'EUR'
	and DT_END ='9999-12-31' 
	and RCD_STS=1
;
CREATE nonCLUSTERED INDEX IX_org_fstd ON #org_fstd (CLNT_ID);
-----------------------------------------------------------------------

if OBJECT_ID('tempdb.dbo.#org_cst') is NOT NULL drop table #org_cst;
select org_cst_dt.CLNT_ID, org_cst_dt.RA_NO_OF_PERSONNEL
into #org_cst
	from [src].[EDW_CST_ORG_CST_DT] org_cst_dt
	where org_cst_dt.DT_END = '9999-12-31' 
		AND org_cst_dt.RCD_STS = 1 
		AND org_cst_dt.[DSP_ROUNDING] is null 
		AND org_cst_dt.FLG_DBS = 0 
;
CREATE nonCLUSTERED INDEX IX_org_cst ON #org_cst (CLNT_ID);
-----------------------------------------------------------------------

if OBJECT_ID('tempdb.dbo.##org_cst_dt') is NOT NULL drop table ##org_cst_dt;
select a.CLNT_ID, a.RA_NO_OF_PERSONNEL
	into ##org_cst_dt
		from #org_cst a
		inner join #org_fstd b
		on a.CLNT_ID= b.CLNT_ID
		and b.RN=1
;
CREATE CLUSTERED INDEX IX_org_cst_dt ON ##org_cst_dt (CLNT_ID);
-----------------------------------------------------------------------

if OBJECT_ID('tempdb.dbo.##refacty') is NOT NULL drop table ##refacty;
select distinct ACTR 
into ##refacty from [dbo].[REF_ACTY_TYPE]
CREATE CLUSTERED INDEX IX_refacty ON ##refacty (ACTR);


DROP TABLE IF EXISTS ##CST_LOG_ADDR
CREATE TABLE ##CST_LOG_ADDR(
	cst_id [bigint] NOT NULL,
	address_value NVARCHAR(40) NULL
);

DROP TABLE IF EXISTS #CST_LOG_ADDR_PH
CREATE TABLE #CST_LOG_ADDR_PH( 
cst_id [bigint] NOT NULL,
address_value NVARCHAR(30) NULL,
ORDERING smallint null,
dt_eff date null);

DROP TABLE IF EXISTS ##CST_LOG_ADDR_PH_FINAL
CREATE TABLE ##CST_LOG_ADDR_PH_FINAL(
	cst_id [bigint] NOT NULL,
	address_value NVARCHAR(30) NULL
);



------update CRD---------
------update CRD-HOUID-------------
--select * from CRD_SUB a
update a
set	a.HOUID = b.f_cid
from STG.CRD_TMP a
inner join [dbo].[SPRT_CST_ADD] b
on a.HOUID = b.CID_NEW
where b.REASON='MERGE'
;
------update CRD---------
------update CRD-IPUID-------------
--select * from CRD_SUB a
update a
set	a.IPUID = b.f_cid
from  STG.CRD_TMP a
inner join [dbo].[SPRT_CST_ADD] b
on a.IPUID = b.CID_NEW
where b.REASON='MERGE'
;
------update CRD---------
------update CRD-UPCID-------------
--select * from CRD_SUB a
update a
set	a.UPCID = b.f_cid
from  STG.CRD_TMP a
inner join [dbo].[SPRT_CST_ADD] b
on a.UPCID = b.CID_NEW
where b.REASON='MERGE'
;

------update CRD-------------
--select * from crd_sub a
update a
set	a.cid = b.f_cid
from  STG.CRD_TMP a
inner join [dbo].[SPRT_CST_ADD] b
on a.cid = b.CID_NEW
where b.REASON='MERGE'
;

"
----------------------- extra records NICOSIA KYPROY ---------------------------------------------------

DECLARE @DATA_VERSION NVARCHAR(10);
DECLARE @ReportingDate datetime ;
DECLARE @OBS varchar(20) ;
DECLARE @RunID int;
DECLARE @CID NVARCHAR(30);
DECLARE @CNID NVARCHAR(30);
DECLARE @OUTAM NUMERIC(18,2);

SET @RunID = 1 ;
SET @ReportingDate = '"+ @[User::varReportingDate] +"' ;
SET @DATA_VERSION	=convert(nvarchar(10), @ReportingDate, 112 )+'0'+cast(@RunID as char(1));
SET @OBS = 'GR011';

USE Anacredit
SELECT * FROM [src].[FILE_TREASURY_PRTF] 
WHERE CounterParty='ETHNCYNNXXX'


select top 100 CID, * from anacredit.dbo.CRD_SUB where CID = 'ETHNCYNNXXX' AND REF_DT='2024-03-31'

--208,778,887.72
select top 100
       REF_DT, QUALIFICATION_FLAG, SOURCE_SYSTEM_ID, CID, CNID, INSID, *
--SELECT SUM(IFD_SUB.OUTAM) OUTAM
from anacredit.dbo.CID_SUB
--left join anacredit.dbo.ifd_sub on ifd_SUB.INSID = CID_SUB.INSID AND IFD_SUB.REF_DT = CID_SUB.REF_DT
where CID_SUB.CID = 'ETHNCYNNXXX' AND CID_SUB.REF_DT='2024-03-31'
AND CID_SUB.SOURCE_SYSTEM_ID='ADPTV'
ORDER BY CID_SUB.QUALIFICATION_FLAG

select top 100
       REF_DT, QUALIFICATION_FLAG, SOURCE_SYSTEM_ID, CID, CNID, INSID, *
from anacredit.dbo.CID
where CID = 'ETHNCYNNXXX' AND REF_DT='2024-03-31'

SELECT * FROM ANACREDIT.DBO.CID_SUB WHERE INSID='1297409ADPTV' AND REF_DT='2024-02-29'





--1297409ADPTV
SELECT *
FROM anacredit.dbo.CID_ADD
WHERE CID='ETHNCYNNXXX'
--ANAPV081 ANACRD_T_ANACREDIT_GR011_DBO_CID_SUB_M.DTSX
--\\S000013845\WINSCHED\ANA\PACKAGES\ANACRD_E_DELTA_EO_CID_SUB_M.DTSX DEN BGAZEI DELTA

and cur.data_version = '2024033101'
and  pre.data_version = '2024022901'
2024013101


select cur.* from cid_sub cur
where-- cur.data_version = '2024022901' AND 
cur.INSID='1297409ADPTV'
ORDER BY REF_DT, CRL

SELECT TOP 10 * FROM  [dbo].[ANACREDIT_DQA]
WHERE S_REF_DT='2024-03-31' AND S_OBS_A_ID='GR011'



--ANAPV276
--ANAPV277 ANACRD_E_DELTA_EO_CRD_SUB_M.DTSX
--ANAPV309 ANACRD_E_DELTA_EO_IFD_SUB_M.DTSX
--ANAPV316 ANACRD_E_DELTA_EO_IPRD_SUB_M.DTSX
--ANAPV330
--ANAPV331
--ANAPV332 \\S000013845\WINSCHED\ANA\PACKAGES\ANACRD_E_NEW_EO_CID_SUB_M.DTSX EINAI AKOMA Q=1
--ANAPV333 ANACRD_E_NEW_EO_CRD_SUB_M.DTSX
--ANAPV334 ANACRD_E_NEW_EO_IFD_SUB_M.DTSX
--ANAPV335, 
--ANAPV336 ANACRD_E_NEW_EO_JLD_SUB_M.DTSX
--ANAPV337 ANACRD_E_NEW_EO_PRD_SUB_M.DTSX
--ANAPV354, ANAPV433, ANAPV434, ANAPV435, ANAPV436, ANAPV437, ANAPV438


SELECT QUALIFICATION_FLAG, * from anacredit.dbo.CID WHERE INSID='1224596ADPTV' AND REF_DT='2024-03-31'
SELECT QUALIFICATION_FLAG, * from anacredit.dbo.CID_SUB WHERE INSID='1224596ADPTV' AND REF_DT='2024-03-31'
SELECT TOP 10 * FROM anacredit.[dbo].[ANACREDIT_CID_DQ_ERR] WHERE  INSID='1250557ADPTV'
SELECT TOP 10 * FROM anacredit.[dbo].[ANACREDIT_CID_DQ_ERR] WHERE CID='ETHNCYNNXXX'

SELECT QUALIFICATION_FLAG, * FROM ANACREDIT.DBO.CRD WHERE CID='ETHNCYNNXXX' AND REF_DT='2024-03-31'
SELECT QUALIFICATION_FLAG, * FROM ANACREDIT.DBO.CRD_SUB WHERE CID='ETHNCYNNXXX' AND REF_DT='2024-03-31'
SELECT QUALIFICATION_FLAG, * FROM ANACREDIT.DBO.CRD WHERE CID='ETHNCYNNXXX' AND REF_DT='2024-02-29'
SELECT QUALIFICATION_FLAG, * FROM ANACREDIT.DBO.CRD_SUB WHERE CID='ETHNCYNNXXX' AND REF_DT='2024-02-29'


select top 100
       REF_DT, QUALIFICATION_FLAG, SOURCE_SYSTEM_ID, CID, CNID, INSID, *
from anacredit.dbo.CID_SUB
where SOURCE_SYSTEM_ID='ADPTV' AND REF_DT='2024-03-31'
ORDER BY CID_SUB.QUALIFICATION_FLAG



SELECT QUALIFICATION_FLAG, * FROM ANACREDIT.DBO.IFD_SUB WHERE INSID='1250557ADPTV' AND REF_DT='2024-03-31'
SELECT QUALIFICATION_FLAG, * FROM ANACREDIT.DBO.CRD_SUB WHERE CID='ETHNCYNNXXX' AND REF_DT='2024-03-31'
SELECT * FROM [dbo].[ANACREDIT_IFD_DQ_ERR] WHERE INSID='1250557ADPTV' 
SELECT TOP 10 * FROM [dbo].[ANACREDIT_CID_DQ_ERR] WHERE  INSID='1250557ADPTV'--CID='ETHNCYNNXXX'


ADPTV          
            ETHNCYNNXXX
SET @CID = 'CITIGB2LXXX' ;		-- 4012117467	--έως 2019-01-31	
SET @CNID = '292403_292403';	-- HRSWP		--έως 2019-01-31
SET @OUTAM = ( select outam from ##temp_table_HSBC where CNID = @CNID ) ;


delete from CRD_SUB
where cid ='CITIUS33XXX' 
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[CrD_sub]
SELECT 
REF_DT, REP_A_ID, OBS_A_ID
,RECID
,CID
,NIDT, NID, AFM, IMO, GEMH, LEI, ESD, HOUID, IPUID, UPCID ,NAME, AStr, AC, ACTY, APC, ACTR, LF, ISctr, EA, SLP, DILP, ES ,DES, NE, BST, AT, AST, CR
,OLD, PR
,'1', '1', '1' -- HO , PAR, UP
,OCR, SRV
,CURRENT_TIMESTAMP INSERT_TIMESTAMP
,1 INSERT_ETL_RUN_ID
,SOURCE_SYSTEM_ID
,1 QUALIFICATION_FLAG
,@DATA_VERSION DATA_VERSION
,DEL_APPV_DIV_ID, DEPT_APPV_DIV_ID
,EM,PH
FROM CrD
WHERE cid ='CITIUS33XXX' and REF_DT = @ReportingDate
;


delete from CRD_SUB
where cid = @CID
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[CrD_sub]
SELECT 
@ReportingDate REF_DT, 'GR011' REP_A_ID, 'GR011' OBS_A_ID
,RECID
--,(select max(cast(recid as int))+1 from CRD where REF_DT = @ReportingDate) recid
,@cid CID
,NIDT, NID, AFM, IMO, GEMH, LEI, ESD, HOUID, IPUID, UPCID ,NAME, AStr, AC, ACTY, APC, ACTR, LF, ISctr, EA, SLP, DILP, ES ,DES, NE, BST, AT, AST, CR
,1 OLD
, PR, HO, PAR, UP, OCR, SRV
,CURRENT_TIMESTAMP INSERT_TIMESTAMP
,1 INSERT_ETL_RUN_ID
,SOURCE_SYSTEM_ID
,1 QUALIFICATION_FLAG
,@DATA_VERSION DATA_VERSION
,DEL_APPV_DIV_ID, DEPT_APPV_DIV_ID
,EM,PH
FROM CrD
WHERE CID = @CID and REF_DT = @ReportingDate --and QUALIFICATION_FLAG = 0
;

delete from CID_SUB
where CNID = @CNID
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[CID_sub]
SELECT @ReportingDate REF_DT
           ,'GR011'  REP_A_ID
           ,'GR011' OBS_A_ID
           ,case when crl =1 then (select max(cast(recid as int))+1 from CID_sub where REF_DT = @ReportingDate) 
				 when crl =2 then (select max(cast(recid as int))+2 from CID_sub where REF_DT = @ReportingDate) 
				 when crl =7 then (select max(cast(recid as int))+3 from CID_SUB where REF_DT = @ReportingDate) 
				end as recid
           ,cid 
           ,CNID 
           ,INSID
           ,CRL 
           ,CURRENT_TIMESTAMP INSERT_TIMESTAMP
           ,1 INSERT_ETL_RUN_ID
           ,SOURCE_SYSTEM_ID
           ,1 QUALIFICATION_FLAG
           ,@DATA_VERSION  DATA_VERSION
FROM CID_ADD 
WHERE CNID = @CNID
;

delete from CRID_SUB
where CID = @CID
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[CRID_sub]
SELECT @ReportingDate REF_DT
       ,'GR011'  REP_A_ID
       ,'GR011' OBS_A_ID
       ,(select max(cast(recid as int))+1 from CRID_SUB where REF_DT = @ReportingDate) recid
       ,cid 
       ,PD
       ,DS
       ,DSD 
       ,CURRENT_TIMESTAMP INSERT_TIMESTAMP
       ,1 INSERT_ETL_RUN_ID
       ,SOURCE_SYSTEM_ID
       ,1 QUALIFICATION_FLAG
       ,@DATA_VERSION  DATA_VERSION
FROM CRID_ADD 
WHERE CID = @CID
;

delete from AD_SUB
where CNID = @CNID
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[AD_sub]
SELECT @ReportingDate REF_DT
	,REP_A_ID, OBS_A_ID
	,(select max(cast(recid as int))+1 from AD_SUB where REF_DT = @ReportingDate) recid
	,ACC_ID, CNID, INSID
	,ACCNTC, BSR, ACCMRO, ACCMIMP, IMPS, IMPASSM, SRCENC, ACCMFVC
	,PERS, PRESD, PRVOB, FRBS, FRBSD, RECSD, PP
	,@OUTAM CAMM
	,CURRENT_TIMESTAMP INSERT_TIMESTAMP
	,1 INSERT_ETL_RUN_ID
	,SOURCE_SYSTEM_ID
	,1 QUALIFICATION_FLAG
	,@DATA_VERSION DATA_VERSION
FROM AD_ADD 
WHERE CNID = @CNID
;

delete from IFD_SUB
where CNID = @CNID
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[IFD_sub]
SELECT @ReportingDate REF_DT
,REP_A_ID, OBS_A_ID
,(select max(cast(recid as int))+1 from IFD_SUB where REF_DT = @ReportingDate) recid
, ACC_ID, CNID, INSID
,INST, AMRT, CUR, FDRCY, INCD, INSEOD, INTRC, INTRF
,INTRRF, INTRSM, INTRT, LFMD, TAM, PF
,PFL, PRPS, RCRS, REFD, STLD, SUBD
,SCID, RPR, FVCCR, INTRD, INTRRD
,INSTDS, INSTDSD, TRAM, ARRRS
,PDD, SECT
,@OUTAM OUTAM
,INTRACC, OBSAM
,CURRENT_TIMESTAMP INSERT_TIMESTAMP
,1 INSERT_ETL_RUN_ID
,SOURCE_SYSTEM_ID
,1 QUALIFICATION_FLAG
,@DATA_VERSION DATA_VERSION
,OPB, OOB, AMP, INSTST
FROM IFD_ADD 
WHERE CNID = @CNID
;

delete from JLD_SUB
where CNID = @CNID
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[JLD_sub]
SELECT @ReportingDate REF_DT
,REP_A_ID, OBS_A_ID
,(select max(cast(recid as int))+1 from JLD_SUB where REF_DT = @ReportingDate) recid
,CID, CNID, INSID, JLBAM
,CURRENT_TIMESTAMP INSERT_TIMESTAMP
,1 INSERT_ETL_RUN_ID
,SOURCE_SYSTEM_ID
,1 QUALIFICATION_FLAG
,@DATA_VERSION DATA_VERSION

FROM JLD_ADD 
WHERE CNID = @CNID
;


delete from IPRD_SUB
where CNID = @CNID
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[IPRD_sub]
SELECT @ReportingDate REF_DT
,REP_A_ID, OBS_A_ID
,(select max(cast(recid as int))+1 from IPRD_SUB where REF_DT = @ReportingDate) recid
, CNID, INSID, PRID, PRAV, PR3PPRI
,CURRENT_TIMESTAMP INSERT_TIMESTAMP
,1 INSERT_ETL_RUN_ID
,SOURCE_SYSTEM_ID
,1 QUALIFICATION_FLAG
,@DATA_VERSION DATA_VERSION

FROM IPRD_ADD 
WHERE CNID = @CNID
;

delete from PRD_SUB
where PRID IN ( SELECT PRID FROM IPRD_ADD WHERE CNID = @CNID)
and REF_DT = @ReportingDate
;
INSERT INTO [dbo].[PRD_sub]
SELECT @ReportingDate REF_DT
,REP_A_ID, OBS_A_ID
,(select max(cast(recid as int))+1 from PRD_SUB where REF_DT = @ReportingDate) recid
,PRID, PRCID, PRT, PRV, PRVT, PRVA, RECL, PRVD, PRMD, PROV, PROVD
,CURRENT_TIMESTAMP INSERT_TIMESTAMP
,1 INSERT_ETL_RUN_ID
,SOURCE_SYSTEM_ID
,1 QUALIFICATION_FLAG
,@DATA_VERSION DATA_VERSION
FROM PRD_ADD 
WHERE PRID IN ( SELECT PRID FROM IPRD_ADD WHERE CNID = @CNID)
;
"