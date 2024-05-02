USE ANACREDIT

/*
+--------------------+----------------------+
| Type specification | Represents |
+--------------------+----------------------+
| d or i | Signed integer |
| o | Unsigned octal |
| s | String |
| u | Unsigned integer |
| x or X | Unsigned hexadecimal |
+--------------------+----------------------+
*/
DECLARE @ReportingDate datetime ;
SET @ReportingDate = '2024-04-30'--'"+ @[User::varReportingDate] +"';
--set @EffectiveEndDateText = cast(@ReportingDate as varchar)
DECLARE @OBS varchar(20);
SET @OBS = 'GR011';


--η διαδικασία πρέπει να είναι rerunable άρα θα σβίνει τις αλλαγές
--Καταλαβαίνουμε τις αλλαγές από όσα έχουν τα νέα SOURCE_SYSTEM_ID 'INSTI_1','INSTI_2','INSTI_3','INSTU_1','INSTU_2','INSTU_3'
--INSTI σημαίνει ότι αυτόν τον μήνα χρειάστηκε να κάνουμε insert την εγγραφή.
--INSTU σημαίνει ότι η εγγραφή υπήρχε και απλά θα κάνουμε update το status.
DELETE FROM dbo.IFD_SUB WHERE OBS_A_ID = 'GR011' AND REF_DT='2024-04-30' AND INSTST <> 0 AND SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3')
UPDATE B
SET B.QUALIFICATION_FLAG = 0
  , B.INSTST = 0
  , B.SOURCE_SYSTEM_ID = 'DELETED'--δεν κρατάμε κάπου την τελευταία τιμή
FROM dbo.IFD_SUB B
WHERE B.OBS_A_ID = 'GR011' AND B.REF_DT='2024-04-30' AND B.SOURCE_SYSTEM_ID IN ('INSTU_1','INSTU_2','INSTU_3')

DECLARE @MAX_RECID BIGINT = (SELECT MAX(TRY_CONVERT(BIGINT, RECID)) FROM dbo.IFD_SUB WHERE OBS_A_ID = 'GR011' AND REF_DT='2024-04-30')

--θα κάνει inserts όλα όσα 
--τον προηγούμενο ήταν ενεργά (Q=1 και INSTST=0) ή πρέπει να συνεχίσουν οι αποστολές (Q=1 και INSTST = 3 και INSTI_1 ή INSTI_2) 
--που αυτόν τον μήνα λείπουν εντελώς ως εγγραφές.
INSERT INTO dbo.IFD_SUB
SELECT '2024-04-30' AS [REF_DT]
      ,A.[REP_A_ID]
      ,A.[OBS_A_ID]
      ,@MAX_RECID + ROW_NUMBER() OVER (PARTITION BY B.CNID, B.INSID ORDER BY B.CNID, B.INSID) AS [RECID]
      ,A.[ACC_ID]
      ,A.[CNID]
      ,A.[INSID]
      ,A.[INST]
      ,A.[AMRT]
      ,A.[CUR]
      ,A.[FDRCY]
      ,A.[INCD]
      ,A.[INSEOD]
      ,A.[INTRC]
      ,A.[INTRF]
      ,A.[INTRRF]
      ,A.[INTRSM]
      ,A.[INTRT]
      ,A.[LFMD]
      ,A.[TAM]
      ,A.[PF]
      ,A.[PFL]
      ,A.[PRPS]
      ,A.[RCRS]
      ,A.[REFD]
      ,A.[STLD]
      ,A.[SUBD]
      ,A.[SCID]
      ,A.[RPR]
      ,A.[FVCCR]
      ,A.[INTRD]
      ,A.[INTRRD]
      ,A.[INSTDS]
      ,A.[INSTDSD]
      ,A.[TRAM]
      ,A.[ARRRS]
      ,A.[PDD]
      ,A.[SECT]
      ,A.[OUTAM]
      ,A.[INTRACC]
      ,A.[OBSAM]
      ,A.[INSERT_TIMESTAMP]
      ,A.[INSERT_ETL_RUN_ID]
      --,'INSTI' AS [SOURCE_SYSTEM_ID]
	  ,CASE
	   WHEN A.SOURCE_SYSTEM_ID NOT IN ('INSTI_1','INSTI_2','INSTU_1','INSTU_2')
	   THEN 'INSTI_1'
	   ELSE CONCAT('INSTI_',CAST(CAST(SUBSTRING(A.SOURCE_SYSTEM_ID,7,1) AS INT)+1 AS NVARCHAR(1))) --Αυξάνει τον μετρητή
	   END AS [SOURCE_SYSTEM_ID]
      ,A.[QUALIFICATION_FLAG]
      ,CONCAT(REPLACE(CAST(CAST('2024-04-30' AS DATE) AS NVARCHAR),'-',''), '01') AS [DATA_VERSION]
      ,A.[OPB]
      ,A.[OOB]
      ,A.[AMP]
      ,4 AS [INSTST]
--	  ,ROW_NUMBER() OVER (PARTITION BY B.CNID, B.INSID ORDER BY B.CNID, B.INSID) AS NUM 
FROM dbo.IFD_SUB A
LEFT JOIN dbo.IFD_SUB B ON B.OBS_A_ID=A.OBS_A_ID AND B.REF_DT='2024-04-30' AND B.CNID=A.CNID AND B.INSID=A.INSID
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT=EOMONTH('2024-04-30',-1) 
AND (
     (A.QUALIFICATION_FLAG=1 AND A.INSTST=0)--τον προηγούμενο μήνα το είχαμε στείλει ως ενεργή
	 OR
--Στους πρώτους μήνες των τριμήνων (μήνες 1, 4, 7, 10) δεν θα στέλνω εγγραφές όπου τον προηγούμενο μήνα είχαν INSTST=3. Για τους υπόλοιπους μήνες θα στέλνω. 
--Άρα εφόσον θα χάνεται η μια αποστολή, τους επόμενους μήνες θα βρίσκει μόνο τις περιπτώσεις που γύρισαν σε INSTST=3 μέσα στο τρίμηνο.
	 (MONTH('2024-04-30') NOT IN (1,4,7,10) AND A.QUALIFICATION_FLAG=1 AND A.INSTST=3 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTU_1','INSTU_2'))
    )
AND B.CNID IS NULL --αυτόν τον μήνα δεν υπάρχει καθόλου η εγγραφή άρα INSERT με άλλο INSTST<>0

SELECT A.*
FROM dbo.IFD_SUB A
LEFT JOIN dbo.IFD_SUB B ON B.OBS_A_ID=A.OBS_A_ID AND B.REF_DT='2024-04-30' AND B.CNID=A.CNID AND B.INSID=A.INSID
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT=EOMONTH('2024-04-30',-1) 
AND (
     (A.QUALIFICATION_FLAG=1 AND A.INSTST=0)--τον προηγούμενο μήνα το είχαμε στείλει ως ενεργή
	 OR
--Στους πρώτους μήνες των τριμήνων (μήνες 1, 4, 7, 10) δεν θα στέλνω εγγραφές όπου τον προηγούμενο μήνα είχαν INSTST=3. Για τους υπόλοιπους μήνες θα στέλνω. 
--Άρα εφόσον θα χάνεται η μια αποστολή, τους επόμενους μήνες θα βρίσκει μόνο τις περιπτώσεις που γύρισαν σε INSTST=3 μέσα στο τρίμηνο.
	 (MONTH('2024-04-30') NOT IN (1,4,7,10) AND A.QUALIFICATION_FLAG=1 AND A.INSTST=3 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTU_1','INSTU_2'))
    )
AND B.CNID IS NULL --αυτόν τον μήνα δεν υπάρχει καθόλου η εγγραφή άρα INSERT με άλλο INSTST<>0
AND A.INSID='1241509ADPTV'

SELECT *
FROM dbo.IFD_SUB 
WHERE OBS_A_ID = 'GR011' AND REF_DT='2024-03-31' AND ACC_ID='N/A'--147
--WHERE OBS_A_ID = 'GR011' AND REF_DT='2024-03-31' AND INSID='1241509ADPTV'


--ΠΡΟΣΟΧΗ!!! κάποια πεδία πρέπει να γίνουν REFRESH. Αυτά είναι τα OUTAM, OPB, AMP
-- Τα 2.984 δάνεια αυτά λοιπόν πρέπει να προστεθούν στην υποβολή IFD 31.01. Θα πρέπει όμως να προστεθούν με τα δεδομένα τους στην Batch date 31.01.2024 και όχι κολλημένη εικόνα από 31.12.2023 (προηγούμενη υποβολή).
--Δλδ δεν γίνεται τα 311 δάνεια που λέμε παρακάτω ότι έχουν ACC_LIFE_STATUS = 5 να έρχονται με ποσά στα πεδία υπολοίπων (πχ 3067807759P8 έρχεται με ποσό στο OUTAM=OPB=77488.88) αντί για 0.00.
-- Από το παραπάνω επηρεάζεται και το instrument status flag καθώς πχ για τον λογαριασμό 3067807759P8 έχει έρθει στο αρχείο με AMP (Amount paid) = 0.00, άρα για τον λόγο αυτό πήρε και τιμή instrument status flag = 4. Ο λογαριασμός όμως έχει εισπράξεις κανονικά τον 1ο/2024 με ποσό (εικόνα από νέο πίνακα lend.ACC_LOAN_FIN_RECOV_M) συνεπώς θα έπρεπε να λάβει τιμή instrument status flag = 1.
--DT_REF ACC_ID RECOV_TP_ID               LEDGER_TP_ID  CCY               TOTAL
--2024-01-31        112938 1               1                            EUR               90500.00

--REFRESH FIELDS REFRESH FIELDS
--REFRESH FIELDS REFRESH FIELDS
--REFRESH FIELDS REFRESH FIELDS
--REFRESH FIELDS REFRESH FIELDS

--ADPTV->U&I->OPB=OUTAM=0,AMP=δεν αλλάζω
--NOSTRO->U->δεν θα τα στέλνουμε (γιατί αν κάποιο NOSTRO έγινε Q=0 για κάποιο λόγο αποκλείεται να έκλεισε ώστε να του αλλάξω το status)
--NOSTRO->Ι->Account->OPB=OUTAM=src.FILE_NOSTRO_BALANCES.We_Balance,OOB=δεν το αλλάζω,AMP=δεν το αλλάζω
--FBL->U&I->CONTRACT_REFERENCE->src.FILE_LOANDEPO_FBL.OUTSTANDING,AMP=δεν το αλλάζω
--VOSTRO->DEPS&DEPE->OPB=OUTAM=src.EDW_DEP_ACC_DEP_BAL.EOD_BAL_ACCNT->EUR. TODO (δεν δουλεύει σωστά. Φέρνει κενό για τον ένα που υπάρχει. Ίσως επειδή μπορεί να είναι καρφωτή εγγραφή.)
--rest->U->δεν χρειάζονται Refresh γιατί ήδη είναι ενημερωμένα σωστά
--rest->I->Refresh Fields: OPB,OUTAM,OOB,AMP,INTRACC,ARRRS,TRAM,PDD,INTRRD (τα FVCCR, INSTDSD τα δίνουμε 0/null)

UPDATE A
SET A.OUTAM=0, A.OPB=0
--SELECT A.*
FROM dbo.IFD_SUB A
LEFT JOIN src.FILE_LOANDEPO_FBL B WITH(NOLOCK) ON B.CONTRACT_REFERENCE+'ADPTV'=A.INSID
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND A.INSTST <> 0 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3','INSTU_1','INSTU_2','INSTU_3')
AND A.INSID LIKE '%ADPTV'

UPDATE A
SET A.OUTAM=ROUND(B.We_Balance / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0 OR B.We_Balance=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2), 
    A.OPB=ROUND(B.We_Balance / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0 OR B.We_Balance=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)--OPB=OUTAM
FROM dbo.IFD_SUB A
LEFT JOIN src.FILE_NOSTRO_BALANCES B WITH(NOLOCK) ON B.Account+'NOSTRO'=A.INSID
LEFT JOIN src.EDW_com_FX_RATES fx WITH(NOLOCK) ON fx.FX_CCY_DESCR=A.CUR AND fx.DT_REC<='2024-04-30' AND fx.FX_DATE>'2024-04-30'
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND A.INSTST <> 0 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3')
AND A.INSID LIKE '%NOSTRO'

UPDATE A
SET A.OUTAM=B.OUTSTANDING, A.OPB=B.OUTSTANDING
--SELECT B.OUTSTANDING, A.*
FROM dbo.IFD_SUB A
LEFT JOIN src.FILE_LOANDEPO_FBL B WITH(NOLOCK) ON B.CONTRACT_REFERENCE+'FBL'=A.INSID
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND A.INSTST <> 0 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3','INSTU_1','INSTU_2','INSTU_3')
AND A.INSID LIKE '%FBL'

--VOSTRO->TODO
--SELECT A.*
--FROM dbo.IFD_SUB A
--LEFT JOIN src.EDW_acc_ACC_SRGT B WITH(NOLOCK) ON B.ACC_UNQ_CD+B.SRC_STM_ID=A.INSID
--LEFT JOIN src.EDW_DEP_ACC_DEP_BAL C ON C.ACC_ID=B.ACC_ID
--WHERE A.OBS_A_ID = 'GR011'-- AND A.REF_DT='2023-12-31' --AND A.INSTST <> 0 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3')
----WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' --AND A.INSTST <> 0 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3')
--AND A.INSID LIKE '%DEP%'--VOSTRO
----OPB=OUTAM=src.EDW_DEP_ACC_DEP_BAL.EOD_BAL_ACCNT->EUR
--SELECT * FROM src.EDW_DEP_ACC_DEP_BAL WHERE ACC_ID=3547394
--SELECT * FROM EDW_UAT.DEP.ACC_DEP_BAL WHERE ACC_ID=3547394
--SELECT * FROM SRC.EDW_lend_ACC_LOAN_BAL_EOD WHERE ACC_ID=3547394
--SELECT * FROM EDW_UAT.lend.ACC_LOAN_BAL_EOD WHERE ACC_ID=3547394
--SELECT * FROM EDW_UAT.ACC.ACC_SRGT WHERE ACC_ID=3547394

--rest->I->Refresh Fields: OPB,OUTAM,OOB,AMP,INTRACC,ARRRS,TRAM,PDD,INTRRD (τα FVCCR, INSTDSD τα δίνουμε 0/null)
--CREATE TABLE #ACC_LOAN_TRN_DTL_P8(
--	[ACC_ID] [bigint] NOT NULL,
--	[TRN_AMT_FC] [decimal](15, 2) NOT NULL,
--)
--CREATE TABLE #ACC_LOAN_TRN_DTL_IRL(
--	[ACC_ID] [bigint] NOT NULL,
--	[TRN_AMT_FC] [decimal](15, 2) NOT NULL,
--)
--CREATE TABLE #ACC_LOAN_TRN_DTL_IRCR(
--	[ACC_ID] [bigint] NOT NULL,
--	[TRN_AMT_FC] [decimal](15, 2) NOT NULL,
--)
--DROP TABLE IF EXISTS #ACC_LOAN_FIN_DTL
--CREATE TABLE #ACC_LOAN_FIN_DTL(
--	[ACC_ID] [bigint] NOT NULL,
--	[EOD_OUTSTANDING_PTRMNL_CPTL_BAL_AMT] [decimal](15, 2) NOT NULL,
--	[EOD_OVD_PTRMNL_CPTL_BAL_AMT] [decimal](15, 2) NOT NULL,
--	[EOD_OUTSTANDING_3RD_CPTL_BAL_AMT] [decimal](15, 2) NOT NULL,
--	[EOD_OVD_3RD_CPTL_BAL_AMT] [decimal](15, 2) NOT NULL,
--)

--SELECT *
--INTO #ACC_LOAN_TRN_DTL
--FROM (
--	SELECT * FROM ##ACC_LOAN_TRN_DTL_P8 
--	UNION ALL
--	SELECT * FROM ##ACC_LOAN_TRN_DTL_IRL 
--	UNION ALL
--	SELECT * FROM ##ACC_LOAN_TRN_DTL_IRCR 
--) TMP

UPDATE A SET 
--SELECT
  A.OUTAM=(
	CASE
	WHEN ACC.ACC_LIFE_STATUS_ID = 5 THEN 0 --Αν έχει κλείσει ο λογ/σμός δεν πρέπει να στέλνουμε ποσό
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN ROUND(bal.EOD_3RD_PARTY_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)--Co-Financed
	ELSE ROUND(bal.EOD_PTRMNL_BOOK_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)
	END
)
--	AS OUTAM,
, A.OPB=(--OPB=OUTAM
	CASE
	WHEN ACC.ACC_LIFE_STATUS_ID = 5 THEN 0 --Αν έχει κλείσει ο λογ/σμός δεν πρέπει να στέλνουμε ποσό
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN ROUND(bal.EOD_3RD_PARTY_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)--Co-Financed
	ELSE ROUND(bal.EOD_PTRMNL_BOOK_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)
	END
)
--	AS OPB,
, A.OOB=(
	CASE
	WHEN ACC.ACC_LIFE_STATUS_ID = 5 THEN 0 --Αν έχει κλείσει ο λογ/σμός δεν πρέπει να στέλνουμε ποσό
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN ISNULL(ROUND(bal.EOD_3RD_PARTY_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2),0)--Co-Financed
		-ISNULL(ROUND((ISNULL(DTL.EOD_OUTSTANDING_3RD_CPTL_BAL_AMT,0) + ISNULL(DTL.EOD_OVD_3RD_CPTL_BAL_AMT,0)) / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2),0)
	ELSE ISNULL(ROUND(bal.EOD_PTRMNL_BOOK_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2),0)
		-ISNULL(ROUND((ISNULL(DTL.EOD_OUTSTANDING_PTRMNL_CPTL_BAL_AMT,0) + ISNULL(DTL.EOD_OVD_PTRMNL_CPTL_BAL_AMT,0)) / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT=0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2),0)
	END
)
--	AS OOB,
, A.AMP=(
	CASE
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN ISNULL(ROUND(ACC_LOAN_TRN_DTL.TRN_AMT_FC / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2) * ((100-cofnc.SENIORITY_PCT)/100) ,0)
	ELSE ISNULL(CASE 
				WHEN cofnc.ACC_ID IS NULL 
				THEN ROUND(ACC_LOAN_TRN_DTL.TRN_AMT_FC / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)
				ELSE ROUND(ACC_LOAN_TRN_DTL.TRN_AMT_FC / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2) * (cofnc.SENIORITY_PCT/100)
				END ,0)
	END
)
--	AS AMP,
, A.INTRACC=(
	CASE
	WHEN ACC.ACC_LIFE_STATUS_ID = 5 THEN 0 --Αν έχει κλείσει ο λογ/σμός δεν πρέπει να στέλνουμε ποσό
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN NULL--Co-Financed
	ELSE ROUND((ISNULL(EDW_LEND_ACCRUALS.EOD_ACCR_PTRMNL_INT_AMT,0) + ISNULL(EDW_LEND_ACCRUALS.EOD_ACCR_PTRMNL_OVD_INT_AMT,0)) / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)
	END
)
--	AS INTRACC,
, A.ARRRS=(
	CASE
	WHEN ACC.ACC_LIFE_STATUS_ID = 5 THEN 0 --Αν έχει κλείσει ο λογ/σμός δεν πρέπει να στέλνουμε ποσό
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN ROUND(bal.EOD_OVD_3RD_PARTY_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)--Co-Financed
	ELSE ROUND(bal.EOD_OVD_PTRMNL_BOOK_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)
	END
)
--	AS ARRRS,
, A.TRAM=(
	CASE
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN ROUND(bal.EOD_3RD_PARTY_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)--Co-Financed
	ELSE (
		CASE 
		WHEN EDW_LEND_ACC_LOAN_SCRZ.ACC_ID IS NOT NULL AND ISNULL(EDW_LEND_ACC_LOAN_SCRZ.DT_EXIT,'9999-12-31')>'2024-04-30'
		THEN ROUND(bal.EOD_PTRMNL_BOOK_BAL_AMT / CASE WHEN (A.CUR='EUR' OR fx.FX_ECBREF_PCT = 0) THEN 1 ELSE fx.FX_ECBREF_PCT END,2)
		ELSE 0
		END
		)
	END
)
--	AS TRAM,
, A.PDD=(
	CASE
	WHEN ACC.ACC_LIFE_STATUS_ID = 5 THEN '1900-01-01' --Αν έχει κλείσει ο λογ/σμός δεν πρέπει να στέλνουμε τιμή
	ELSE ISNULL(DATEADD(day, EDW_LEND_ACC_DPD_DLQ_SMY_M.DLY_DAYS*(-1)+1, '2024-04-30'),'1900-01-01')
	END
)
--	AS PDD
, A.INTRRD=(
	CASE
	WHEN ACC.ACC_LIFE_STATUS_ID = 5 THEN NULL --Αν έχει κλείσει ο λογ/σμός δεν πρέπει να στέλνουμε τιμή
	WHEN cofnc.ACC_ID IS NOT NULL AND COF.OBS_A_ID IS NOT NULL--Co-Financed (2nd Row)
	THEN NULL--Co-Financed
    WHEN ISNULL(EDW_LEND_ACC_LOAN_RATES.DT_BASE_RATE_NXT_RVSN,'1111-11-11') >= '2024-04-30'
     AND EDW_LEND_ACC_LOAN_RATES.DT_BASE_RATE_NXT_RVSN <> '9999-12-31' 
    THEN EDW_LEND_ACC_LOAN_RATES.DT_BASE_RATE_NXT_RVSN 
	END
)
--	AS INTRRD
--SELECT A.*
FROM dbo.IFD_SUB A
--Τα Co-Financed έχουν δύο εγγραφές στο Anacredit
--Αν υπάρχει lend.ACC_COFNC και COF σημαίνει ότι είναι η πρώτη εγγραφή του Co-Financed, άρα ποσό * (SENIORITY_PCT/100)
--Αν υπάρχει lend.ACC_COFNC και όχι COF σημαίνει ότι είναι η δεύτερη εγγραφή του Co-Financed (δηλαδή η '_1') άρα ποσό * ((100-SENIORITY_PCT)/100)
LEFT JOIN dbo.IFD_SUB COF WITH(NOLOCK) ON COF.OBS_A_ID=A.OBS_A_ID AND COF.REF_DT=A.REF_DT AND COF.INSID+'_1'=A.INSID --AND COF.INSTST=A.INSTST AND COF.SOURCE_SYSTEM_ID=A.SOURCE_SYSTEM_ID
AND ISNUMERIC(COF.ACC_ID) = 1
LEFT JOIN src.EDW_com_FX_RATES fx WITH(NOLOCK) ON fx.FX_CCY_DESCR=A.CUR AND fx.DT_REC<='2024-04-30' AND fx.FX_DATE>'2024-04-30'
LEFT JOIN src.EDW_LEND_ACC_LOAN_BAL_EOD bal WITH(NOLOCK) ON bal.ACC_ID = A.ACC_ID AND bal.DT_EFF<='2024-04-30' AND bal.DT_END>'2024-04-30'
LEFT JOIN src.EDW_lend_ACC_COFNC cofnc ON cofnc.ACC_ID = A.ACC_ID AND cofnc.DT_END>EOMONTH('2024-04-30',-1) and cofnc.DT_EFF<=EOMONTH('2024-04-30',-1) AND cofnc.RCD_STS=1 AND cofnc.SENIORITY_PCT<>100
LEFT JOIN src.EDW_acc_ACC ACC ON ACC.ACC_ID = A.ACC_ID AND ACC.DT_END>'2024-04-30' and ACC.DT_EFF<='2024-04-30'
--LEFT JOIN EDW_UAT.lend.ACC_LOAN_FIN_DTL DTL WITH(NOLOCK) ON DTL.ACC_ID = A.ACC_ID AND DTL.DT_EFF<='2024-04-30' AND DTL.DT_END>'2024-04-30'
LEFT JOIN #ACC_LOAN_FIN_DTL DTL ON DTL.ACC_ID = A.ACC_ID
--LEFT JOIN EDW_UAT.lend.ACC_LOAN_TRN_DTL ACC_LOAN_TRN_DTL WITH(NOLOCK) ON ACC_LOAN_TRN_DTL.ACC_ID = A.ACC_ID AND ACC_LOAN_TRN_DTL.DT_ACCOUNTING='2024-04-30'--ΘΕΛΕΙ SUM ΥΠΑΡΧΕΙ Ο ΠΙΝΑΚΑΣ ##ACC_LOAN_TRN_DTL_P8
LEFT JOIN #ACC_LOAN_TRN_DTL ACC_LOAN_TRN_DTL ON ACC_LOAN_TRN_DTL.ACC_ID = A.ACC_ID
LEFT JOIN (
	SELECT *, ROW_NUMBER () OVER (PARTITION BY EDW_LEND_ACCRUALS.ACC_ID ORDER BY EDW_LEND_ACCRUALS.DT_REC DESC) AS RN
	FROM src.EDW_LEND_ACCRUALS EDW_LEND_ACCRUALS
	WHERE EDW_LEND_ACCRUALS.DT_REC<='2024-04-30'
	) EDW_LEND_ACCRUALS ON EDW_LEND_ACCRUALS.ACC_ID = A.ACC_ID AND EDW_LEND_ACCRUALS.RN= 1
LEFT JOIN src.EDW_lend_ACC_LOAN_SCRZ EDW_lend_ACC_LOAN_SCRZ ON EDW_LEND_ACC_LOAN_SCRZ.ACC_ID = A.ACC_ID
	AND EDW_LEND_ACC_LOAN_SCRZ.DT_EFF <= '2024-04-30'
	AND EDW_LEND_ACC_LOAN_SCRZ.DT_END > '2024-04-30'
	AND EDW_LEND_ACC_LOAN_SCRZ.POOL_TP_ID in (8,9)
LEFT JOIN src.EDW_LEND_ACC_DPD_DLQ_SMY_M  EDW_LEND_ACC_DPD_DLQ_SMY_M ON EDW_LEND_ACC_DPD_DLQ_SMY_M.ACC_ID = A.ACC_ID
	AND EDW_LEND_ACC_DPD_DLQ_SMY_M.DT_REC= '2024-04-30' 
	AND EDW_LEND_ACC_DPD_DLQ_SMY_M.BCK_TP_ID='3'
LEFT JOIN src.EDW_lend_ACC_LOAN_RATES EDW_LEND_ACC_LOAN_RATES ON EDW_LEND_ACC_LOAN_RATES.ACC_ID = A.ACC_ID
 AND EDW_LEND_ACC_LOAN_RATES.RCD_STS =1 
 AND EDW_LEND_ACC_LOAN_RATES.DT_EFF <= '2024-04-30'
 AND EDW_LEND_ACC_LOAN_RATES.DT_END > '2024-04-30'
 and EDW_lend_ACC_LOAN_RATES.RATE_TP_ID=1  --cosmos20221018
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND A.INSTST <> 0 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3')
AND ISNUMERIC(A.ACC_ID) = 1

--5015
--Υπήρξαν περιπτώσεις που οι ημέρες υπερημέριας πήγαιναν το PDD πιο πίσω από το STLD
UPDATE dbo.IFD_SUB SET PDD = STLD
WHERE OBS_A_ID='GR011' AND REF_DT='2024-04-30' AND PDD IS NOT NULL AND PDD<>'1900-01-01' AND PDD<STLD AND SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3')

--θα κάνει updates όλα όσα τον προηγούμενο ήταν Q=1 και INSTST=0 που αυτόν τον μήνα έχουν Q=0
--ΠΡΟΣΟΧΗ!!! Επειδή κάνουμε REFRESH μόνο συγκεκριμένα πεδία μπορεί να μας σκάνε λάθη.
--Τον επόμενο, το Q=1 αλλά το INSTST<>0 κι έτσι θα το κάνει μόνο για έναν μήνα.
--όπως επίσης για τα INSTST=3, το Q=1 αλλά στέλνει όσο το system_id είναι _1 ή _2.
UPDATE B
SET B.QUALIFICATION_FLAG = 1
  , B.INSTST = 4
  , B.SOURCE_SYSTEM_ID = CASE
                         WHEN A.SOURCE_SYSTEM_ID NOT IN ('INSTI_1','INSTI_2','INSTU_1','INSTU_2')
                         THEN 'INSTU_1'
                         ELSE CONCAT('INSTU_',CAST(CAST(SUBSTRING(A.SOURCE_SYSTEM_ID,7,1) AS INT)+1 AS NVARCHAR(1))) --Αυξάνει τον μετρητή
                         END
-- SELECT *
FROM dbo.IFD_SUB B
LEFT JOIN dbo.IFD_SUB A ON A.OBS_A_ID=B.OBS_A_ID AND A.REF_DT=EOMONTH('2024-04-30',-1) AND B.CNID=A.CNID AND B.INSID=A.INSID 
WHERE B.OBS_A_ID = 'GR011' AND B.REF_DT='2024-04-30' 
AND (
     (A.QUALIFICATION_FLAG=1 AND A.INSTST=0)--τον προηγούμενο μήνα το είχαμε στείλει ως ενεργή
	 OR
	 (A.QUALIFICATION_FLAG=1 AND A.INSTST=3 AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTU_1','INSTU_2'))
    )
AND B.QUALIFICATION_FLAG=0 --αυτόν τον μήνα είναι μηδέν
AND B.INSID NOT LIKE '%NOSTRO'

--Για όσα έχουν γίνει INSERT ή UPDATE με την παραπάνω διαδικασία πρέπει να ενημερωθεί σωστά το INSTST
--0: ενεργό (ACC_LIFE_STATUS_ID = 4 & OUTAM > 0)
--1: κλειστό (ACC_LIFE_STATUS_ID = 5 & AMP > 0 και δεν είναι 2, 3 ή μια συγκεκριμένη ομάδα του 4)
--2: μεταφέρθηκε (ACC_LOAN_EARTH_SUPPL_FIN exists)
--3: διαγράφηκε (ACC_PARAGRP.FNC_STATUS_ID exists in 3M period)
--4: other (είναι το default)
-- EDW -> Anacredit (TEST-START)
DROP TABLE IF EXISTS #ACC_LOAN_EARTH_SUPPL_FIN
CREATE TABLE #ACC_LOAN_EARTH_SUPPL_FIN(
	[ACC_ID] [bigint] NOT NULL
)
INSERT INTO #ACC_LOAN_EARTH_SUPPL_FIN
SELECT ACC_ID 
FROM EDW.lend.ACC_LOAN_EARTH_SUPPL_FIN WITH(NOLOCK) WHERE DT_REF BETWEEN DATEADD(DAY,1,EOMONTH('2024-04-30',-1)) AND '2024-04-30'
-- EDW -> Anacredit (TEST-END)

-- 2 Non-Active (totally transferred)
UPDATE A
SET A.INSTST = 2 -- Non-Active (totally transferred)
, A.TRAM = D.OUTAM
FROM dbo.IFD_SUB A
LEFT JOIN src.EDW_acc_ACC B ON B.ACC_ID = TRY_CONVERT(BIGINT, A.ACC_ID) AND B.ACC_LIFE_STATUS_ID = 5
INNER JOIN #ACC_LOAN_EARTH_SUPPL_FIN C ON C.ACC_ID = TRY_CONVERT(BIGINT, A.ACC_ID)
LEFT JOIN dbo.IFD_SUB D ON D.OBS_A_ID=A.OBS_A_ID AND D.REF_DT=EOMONTH('2024-04-30',-1) AND D.CNID=A.CNID AND D.INSID=A.INSID 
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3','INSTU_1','INSTU_2','INSTU_3')

-- EDW -> Anacredit (TEST-START)
DROP TABLE IF EXISTS #ACC_PARAGRP
CREATE TABLE #ACC_PARAGRP(
	[ACC_ID] [bigint] NOT NULL
)
INSERT INTO #ACC_PARAGRP
SELECT ACC_ID
FROM EDW.acc.ACC_PARAGRP WITH(NOLOCK)
WHERE TBL_SCHM_MN='acc'
AND TBL_NM='ACC'
AND TBL_FLD_NM='FNC_STATUS_ID'
AND PARAGROUP_ID=312 
AND PARALIST_ID=4
AND (
     (DT_EFF BETWEEN DATEADD(DAY,1,EOMONTH('2024-04-30',-3)) AND '2024-04-30')
	 OR
     (DT_END BETWEEN DATEADD(DAY,1,EOMONTH('2024-04-30',-3)) AND '2024-04-30')
    )
-- EDW -> Anacredit (TEST-END)
-- 3 Non-Active (totally written-off)
UPDATE A
SET A.INSTST = 3 -- Non-Active (totally written-off)
FROM dbo.IFD_SUB A
INNER JOIN #ACC_PARAGRP B ON B.ACC_ID = TRY_CONVERT(BIGINT, A.ACC_ID)
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3','INSTU_1','INSTU_2','INSTU_3')

-- 4 Non-Active (other)
-- Αυτή είναι η default τιμή, ωστόσο πρέπει να καταγράψουμε αυτήν την συγκεκριμένη ομάδα
-- καθώς για να βρούμε τα 1 πρέπει να εξαιρέσουμε αυτά τα συγκεκριμένα
-- Anacredit -> EDW
DROP TABLE IF EXISTS #IFD
CREATE TABLE #IFD(
	[ACC_ID] [bigint] NOT NULL
)
INSERT INTO #IFD
SELECT A.ACC_ID
FROM dbo.IFD_SUB A
LEFT JOIN src.EDW_acc_ACC B ON B.ACC_ID = TRY_CONVERT(BIGINT, A.ACC_ID) AND B.ACC_LIFE_STATUS_ID = 5
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND ISNUMERIC(A.ACC_ID)=1

-- EDW -> Anacredit (TEST-START)
DROP TABLE IF EXISTS #ACC_LOAN_TRNF
CREATE TABLE #ACC_LOAN_TRNF(
	[ACC_ID] [bigint] NOT NULL
)
INSERT INTO #ACC_LOAN_TRNF
SELECT A.ORIG_ACC_ID AS ACC_ID
FROM EDW.lend.ACC_LOAN_TRNF A WITH(NOLOCK)
INNER JOIN #IFD B WITH(NOLOCK) ON B.ACC_ID = A.ORIG_ACC_ID
WHERE A.TRNF_TP_ID IN (1,3)
-- EDW -> Anacredit (TEST-END)

-- 1 Non-Active (totally repaid)
UPDATE A
SET A.INSTST = 1 -- Non-Active (totally repaid)
FROM dbo.IFD_SUB A
LEFT JOIN src.EDW_acc_ACC B ON B.ACC_ID = TRY_CONVERT(BIGINT, A.ACC_ID) AND B.ACC_LIFE_STATUS_ID = 5
LEFT JOIN #ACC_LOAN_TRNF C ON C.ACC_ID = B.ACC_ID
WHERE A.OBS_A_ID = 'GR011' AND A.REF_DT='2024-04-30' AND A.SOURCE_SYSTEM_ID IN ('INSTI_1','INSTI_2','INSTI_3','INSTU_1','INSTU_2','INSTU_3')
AND A.AMP>0
AND C.ACC_ID IS NULL -- είναι 4
AND A.INSTST = 4 -- το INSTST δεν έχει αλλάξει ακόμα (δεν είναι 2 ή 3)

