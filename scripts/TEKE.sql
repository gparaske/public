
use EDW
select * from acc.acc_srgt where acc_unq_cd='5600017717'
-- ACC_ID
-- 72443858
-- CLA
select * from acc.acc_srgt where acc_unq_cd='5600014677'
-- ACC_ID
-- 72308517

5600017726
DROP TABLE IF EXISTS #ACC_SRGT
SELECT *
INTO #ACC_SRGT 
FROM acc.acc_srgt S 
WHERE S.SRC_STM_ID IN ('CLA', 'P8') 
and acc_id=72443858

---------------------------------------------- PERIMETER -----------------------------------------------------------
DROP TABLE IF EXISTS #ACC_SUM
SELECT ACC_ID, 
SUM( EOD_OVD_PTRMNL_BOOK_BAL_AMT +EOD_A88_OVD_INT_AMT + EOD_OVD_3RD_PARTY_BAL_AMT + EOD_PRTL_WRT_OFF_AMT) AS AMT_SUM
INTO #ACC_SUM
FROM lend.ACC_LOAN_BAL_EOD
WHERE dt_eff <= '2024-04-30'
      AND DT_END > '2024-04-30'
      and acc_id=72443858
GROUP BY ACC_ID
	    

DROP TABLE IF EXISTS #TEKE_P8_PERIMETER
SELECT acc.ACC_ID, acc.APPL_TP_ID, acc.MGN_BRNCH_ID as MGN_BRNCH_ID, acc.ACC_CTG_PRD_ID,srgt.acc_unq_cd as acc_unq_cd,
	   PRD.PRD_CD, PRD.PRD_GRP_ID, ACC.PRD_ID
INTO #TEKE_P8_PERIMETER
FROM acc.ACC acc
INNER JOIN com.PRD
	ON PRD.PRD_ID = ACC.PRD_ID
inner join #acc_srgt srgt
      on srgt.acc_id = acc.acc_id
INNER JOIN #ACC_SUM ACC_SUM 
	ON ACC_SUM.ACC_ID = acc.ACC_ID
LEFT JOIN LEND.ACC_LOAN_EARTH_SUPPL_FIN EARTH
ON EARTH.ACC_ID = ACC.ACC_ID
WHERE acc.ACC_LIFE_STATUS_ID = 4
/**cosmos start**/
AND acc.APPL_TP_ID IN ('CLA', 'P8')  --isodunamo me feed_src_stm
/**cosmos end**/
AND ACC_SUM.AMT_SUM > 0
AND acc.DT_EFF <= '2024-04-30'
AND acc.DT_END >  '2024-04-30'
AND PRD.DT_EFF <= '2024-04-30'
AND PRD.DT_END > '2024-04-30'
AND EARTH.ACC_ID IS NULL
and acc.acc_id=72443858
----------------------------------------------------------------------------------------------------------------------

--Για τα επιχειρηματικά δάνεια ACC_CTG_PRD_ID = 3 (δηλ. όλα τα άλλα, εκτός των παραπάνω δανείων ιδιωτών) 
--χρησιμοποιείται η αντίστοιχη κωδικοποίηση που δίνουμε και για τον Λευκό Τειρεσία, ανεξάρτητα από το εγκριτικό 
--όργανο του πελάτη.( βλ. και πίνακα EDW στήλη J)
--DECLARE '2024-04-30' DATE = '2022-02-28'
DROP TABLE IF EXISTS #APPR_FIELDS
select          PER.acc_id,PER.ACC_UNQ_CD,PER.APPL_TP_ID,APPR_ACC.APPR_ID,APPR_ACC.STATUS_CONN_ID,
                APPR_SRGT.APPR_STM_CD, APPR.APPR_TP_ID,PER.PRD_CD,
				APPR.APPR_CTG_ID
INTO #APPR_FIELDS
from #TEKE_P8_PERIMETER PER
--egkrish X daneio
INNER join [appr].[APPR_X_ACC] APPR_ACC 
	on PER.ACC_ID=APPR_ACC.ACC_ID 
	and APPR_ACC.DT_EFF<='2024-04-30' 
	and APPR_ACC.DT_END>'2024-04-30'
	and APPR_ACC.STATUS_CONN_ID=1
INNER join [appr].[APPR_SRGT] APPR_SRGT 
	on APPR_ACC.APPR_ID=APPR_SRGT.APPR_ID
INNER JOIN appr.APPR APPR
	ON APPR.APPR_ID = APPR_SRGT.APPR_ID
	AND APPR.DT_EFF <= '2024-04-30'
	AND APPR.DT_END > '2024-04-30'
    and APPR_ACC.acc_id=72443858
group by		PER.acc_id,PER.ACC_UNQ_CD,PER.APPL_TP_ID,APPR_ACC.APPR_ID,APPR_ACC.STATUS_CONN_ID,
                APPR_SRGT.APPR_STM_CD, APPR.APPR_TP_ID,PER.PRD_CD,
				APPR.APPR_CTG_ID
order by acc_id
select * from [appr].[APPR_X_ACC] where acc_id=72443858
select * from [appr].[APPR_X_ACC] where acc_id=72308517

DROP TABLE IF EXISTS #P8_SSX
SELECT  DISTINCT

PER.ACC_ID, PER.ACC_UNQ_CD, PER.PRD_ID, ACC_LOAN.ACC_OBJ_TP_ID, PER.PRD_GRP_ID,ACC_LOAN.LOAN_SCP_ID, APPR_FIELDS.APPR_ID, APPR_FIELDS.APPR_STM_CD,
    CASE  WHEN PER.PRD_CD IN (91, 92, 93, 94)			OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (24, 27, 28, 29, 30,109,112,114,115,116))	THEN
				 CASE WHEN PER.PRD_CD IN (91)		OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (24, 30,109,116))				THEN '6' --Stegastiko
				      WHEN PER.PRD_CD IN (92, 93)	OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (28, 29,114,115))				THEN '1' --Proswpiko
				 	  WHEN PER.PRD_CD IN (94)		OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (27,112))					THEN '2' --Katanalwtiko
					  ELSE 'Λ'
				 END --select top 10 * from com.PRD_SRGT
	    ----------------------------------------------------Epixeirhmatika Lefkos Teiresias------------------------------------------------------
		WHEN PER.ACC_CTG_PRD_ID = 3 THEN 
				--Αν APPR_TP_ID = Όριο και PRD_CD = 20 τότε F
				CASE WHEN APPR_FIELDS.APPR_TP_ID = 2 AND /**cosmos start**/PER.PRD_CD IN (20,10812)/**cosmos end**/ THEN 'F'
					 WHEN (/**cosmos start**/APPR_FIELDS.PRD_CD NOT IN (20,10812)/**cosmos end**/ AND APPR_FIELDS.APPR_TP_ID = 2 AND  ACC_LOAN.LOAN_SCP_ID IN (6,7,8,9,10,11,12,13,14,/*COSMOS START 2024*/249,250,251,252,253,254,255,256,257)/*COSMOS END 2024*/)
					 OR (APPR_FIELDS.APPR_TP_ID = 2 AND  ACC_LOAN.LOAN_SCP_ID IN (6,7,8,9,10,11,12,13,14,/*COSMOS START 2024*/249,250,251,252,253,254,255,256,257)/*COSMOS END 2024*/ AND /**cosmos start**/APPR_FIELDS.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID NOT IN (24, 27, 28, 29, 30))
					 THEN 'K'
					 --Αν APPR_TP_ID = Εφάπαξ και PRD_CD = 20 τότε D
					 WHEN APPR_FIELDS.APPR_TP_ID = 1 OR APPR_FIELDS.APPR_STM_CD IN ('0000000000', '1111111111', '2222222222', '9999999999') THEN
					     CASE WHEN /**cosmos start**/PER.PRD_CD IN (20,10812)/**cosmos end**/ THEN 'D'

							  WHEN APPR_FIELDS.APPR_CTG_ID NOT IN ('06', '07') 
							  AND ACC_LOAN.LOAN_SCP_ID IN (6,7,8,9,10,11,12,13,14,/*COSMOS START 2024*/249,250,251,252,253,254,255,256,257)/*COSMOS END 2024*/ 
							  AND (PER.PRD_CD NOT IN (20,84,85,86,87,88,89,90,91,92,93,94,186,188,189,190,/*COSMOS START 2024*/10812,11003,11004,11005,11006,11007,11008/*COSMOS END 2024*/)
							  OR (/**cosmos start**/PER.PRD_CD IN (99, 10103) /**cosmos end**/
							  AND ACC_LOAN.ACC_OBJ_TP_ID NOT IN (24, 27, 28, 29, 30,109,112,114,115,116)))
							  THEN 'T'

							  WHEN APPR_FIELDS.APPR_CTG_ID NOT IN ('06', '07') 
							  AND ((ACC_LOAN.LOAN_SCP_ID BETWEEN 15 AND 38) /*COSMOS START 2024*/OR (ACC_LOAN.LOAN_SCP_ID BETWEEN 258 AND 280)/*COSMOS END 2024*/)
							  AND ((ACC_LOAN.ACC_OBJ_TP_ID NOT IN (24, 27, 28, 29, 30,109,112,114,115,116) AND /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/)
							  OR PER.PRD_CD NOT IN (20,84,85,86,87,88,89,90,91,92,93,94,186,188,189,190,/*COSMOS START 2024*/10812,11003,11004,11005,11006,11007,11008/*COSMOS END 2024*/))
					          THEN 'P'

							  WHEN APPR_FIELDS.APPR_CTG_ID IN ('07') AND /**cosmos start**/PER.PRD_CD IN (084,11003)/**cosmos end**/ AND ISNULL(KYA.KYA_ID,0) <> 72 THEN 'Ι'
							  WHEN APPR_FIELDS.APPR_CTG_ID IN ('06') AND /**cosmos start**/PER.PRD_CD IN (084,11003)/**cosmos end**/ AND ISNULL(KYA.KYA_ID,0) <> 72 THEN 'W'
							  WHEN APPR_FIELDS.APPR_CTG_ID IN ('06','07') AND /**cosmos start**/PER.PRD_CD IN (084,11003)/**cosmos end**/ AND ISNULL(KYA.KYA_ID,0) = 72 THEN 'Π'
	
							  WHEN APPR_FIELDS.APPR_CTG_ID NOT IN ('06','07') 
							  AND /**cosmos start**/PER.PRD_CD IN (84, 85, 86, 87, 88, 89, 90, 186, 188, 189, 190,/*COSMOS START*/11003, 11004, 11005, 11006, 11007, 11008/**COSMOS END**/) AND ISNULL(KYA.KYA_ID,0) <> 72 
							  THEN 'Δ'
							
							  WHEN PER.PRD_CD IN (92, 93) THEN '1'
							  WHEN /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (28, 29,114,115) THEN '1'

							  WHEN PER.PRD_CD IN (94) THEN '2'
							  WHEN /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (27,112) THEN '2'

							  WHEN PER.PRD_CD IN (91) THEN '6'
							  WHEN /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (24, 30,109,116) THEN '6'
							  ELSE 'Λ'
						 END
				    ELSE 'Λ'
 				END
		ELSE 'Λ'
	END AS P8_SSX,
		APPR_FIELDS.APPR_TP_ID,
		APPR_FIELDS.APPR_CTG_ID,
		PER.PRD_CD,PER.ACC_CTG_PRD_ID,
		KYA.KYA_ID
INTO #P8_SSX
FROM #TEKE_P8_PERIMETER PER
LEFT JOIN lend.ACC_LOAN	ACC_LOAN
	ON PER.ACC_ID = ACC_LOAN.ACC_ID
	AND ACC_LOAN.RCD_STS = 1
	AND ACC_LOAN.DT_EFF <= '2024-04-30'
	AND ACC_LOAN.DT_END > '2024-04-30'
LEFT JOIN [lend].[ACC_X_KYA] KYA
	ON KYA.ACC_ID = PER.ACC_ID
	AND KYA.DT_EFF <= '2024-04-30'
	AND KYA.DT_END > '2024-04-30'
	AND KYA.RCD_STS = 1
INNER JOIN #APPR_FIELDS APPR_FIELDS ---mallon kovw
	ON APPR_FIELDS.ACC_ID = PER.ACC_ID

GROUP BY PER.ACC_ID, PER.ACC_UNQ_CD, PER.PRD_ID, ACC_LOAN.ACC_OBJ_TP_ID, PER.PRD_GRP_ID, ACC_LOAN.LOAN_SCP_ID, APPR_FIELDS.APPR_ID, APPR_FIELDS.APPR_STM_CD, 

  CASE  WHEN PER.PRD_CD IN (91, 92, 93, 94)			OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (24, 27, 28, 29, 30,109,112,114,115,116))	THEN
				 CASE WHEN PER.PRD_CD IN (91)		OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (24, 30,109,116))				THEN '6' --Stegastiko
				      WHEN PER.PRD_CD IN (92, 93)	OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (28, 29,114,115))				THEN '1' --Proswpiko
				 	  WHEN PER.PRD_CD IN (94)		OR (/**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (27,112))					THEN '2' --Katanalwtiko
					  ELSE 'Λ'
				 END --select top 10 * from com.PRD_SRGT
	    ----------------------------------------------------Epixeirhmatika Lefkos Teiresias------------------------------------------------------
		WHEN PER.ACC_CTG_PRD_ID = 3 THEN 
				--Αν APPR_TP_ID = Όριο και PRD_CD = 20 τότε F
				CASE WHEN APPR_FIELDS.APPR_TP_ID = 2 AND /**cosmos start**/PER.PRD_CD IN (20,10812)/**cosmos end**/ THEN 'F'
					 WHEN (/**cosmos start**/APPR_FIELDS.PRD_CD NOT IN (20,10812)/**cosmos end**/ AND APPR_FIELDS.APPR_TP_ID = 2 AND  ACC_LOAN.LOAN_SCP_ID IN (6,7,8,9,10,11,12,13,14,/*COSMOS START 2024*/249,250,251,252,253,254,255,256,257)/*COSMOS END 2024*/)
					 OR (APPR_FIELDS.APPR_TP_ID = 2 AND  ACC_LOAN.LOAN_SCP_ID IN (6,7,8,9,10,11,12,13,14,/*COSMOS START 2024*/249,250,251,252,253,254,255,256,257)/*COSMOS END 2024*/ AND /**cosmos start**/APPR_FIELDS.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID NOT IN (24, 27, 28, 29, 30))
					 THEN 'K'
					 --Αν APPR_TP_ID = Εφάπαξ και PRD_CD = 20 τότε D
					 WHEN APPR_FIELDS.APPR_TP_ID = 1 OR APPR_FIELDS.APPR_STM_CD IN ('0000000000', '1111111111', '2222222222', '9999999999') THEN
					     CASE WHEN /**cosmos start**/PER.PRD_CD IN (20,10812)/**cosmos end**/ THEN 'D'

							  WHEN APPR_FIELDS.APPR_CTG_ID NOT IN ('06', '07') 
							  AND ACC_LOAN.LOAN_SCP_ID IN (6,7,8,9,10,11,12,13,14,/*COSMOS START 2024*/249,250,251,252,253,254,255,256,257)/*COSMOS END 2024*/ 
							  AND (PER.PRD_CD NOT IN (20,84,85,86,87,88,89,90,91,92,93,94,186,188,189,190,/*COSMOS START 2024*/10812,11003,11004,11005,11006,11007,11008/*COSMOS END 2024*/)
							  OR (/**cosmos start**/PER.PRD_CD IN (99, 10103) /**cosmos end**/
							  AND ACC_LOAN.ACC_OBJ_TP_ID NOT IN (24, 27, 28, 29, 30,109,112,114,115,116)))
							  THEN 'T'

							  WHEN APPR_FIELDS.APPR_CTG_ID NOT IN ('06', '07') 
							  AND ((ACC_LOAN.LOAN_SCP_ID BETWEEN 15 AND 38) /*COSMOS START 2024*/OR (ACC_LOAN.LOAN_SCP_ID BETWEEN 258 AND 280)/*COSMOS END 2024*/)
							  AND ((ACC_LOAN.ACC_OBJ_TP_ID NOT IN (24, 27, 28, 29, 30,109,112,114,115,116) AND /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/)
							  OR PER.PRD_CD NOT IN (20,84,85,86,87,88,89,90,91,92,93,94,186,188,189,190,/*COSMOS START 2024*/10812,11003,11004,11005,11006,11007,11008/*COSMOS END 2024*/))
					          THEN 'P'

							  WHEN APPR_FIELDS.APPR_CTG_ID IN ('07') AND /**cosmos start**/PER.PRD_CD IN (084,11003)/**cosmos end**/ AND ISNULL(KYA.KYA_ID,0) <> 72 THEN 'Ι'
							  WHEN APPR_FIELDS.APPR_CTG_ID IN ('06') AND /**cosmos start**/PER.PRD_CD IN (084,11003)/**cosmos end**/ AND ISNULL(KYA.KYA_ID,0) <> 72 THEN 'W'
							  WHEN APPR_FIELDS.APPR_CTG_ID IN ('06','07') AND /**cosmos start**/PER.PRD_CD IN (084,11003)/**cosmos end**/ AND ISNULL(KYA.KYA_ID,0) = 72 THEN 'Π'
	
							  WHEN APPR_FIELDS.APPR_CTG_ID NOT IN ('06','07') 
							  AND /**cosmos start**/PER.PRD_CD IN (84, 85, 86, 87, 88, 89, 90, 186, 188, 189, 190,/*COSMOS START*/11003, 11004, 11005, 11006, 11007, 11008/**COSMOS END**/) AND ISNULL(KYA.KYA_ID,0) <> 72 
							  THEN 'Δ'
							
							  WHEN PER.PRD_CD IN (92, 93) THEN '1'
							  WHEN /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (28, 29,114,115) THEN '1'

							  WHEN PER.PRD_CD IN (94) THEN '2'
							  WHEN /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (27,112) THEN '2'

							  WHEN PER.PRD_CD IN (91) THEN '6'
							  WHEN /**cosmos start**/PER.PRD_CD IN (99, 10103)/**cosmos end**/ AND ACC_LOAN.ACC_OBJ_TP_ID IN (24, 30,109,116) THEN '6'
							  ELSE 'Λ'
						 END
				    ELSE 'Λ'
 				END
		ELSE 'Λ'
	END, -- END CASE FOR P8 P8_SSX

APPR_FIELDS.APPR_TP_ID, APPR_FIELDS.APPR_CTG_ID, PER.PRD_CD, PER.ACC_CTG_PRD_ID, KYA.KYA_ID



-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

--Eggyhtes
--Για την ευρωποίηση
--------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #FX_RATES 
 
SELECT    FX_CCY_DESCR,FX_ECBREF_PCT
INTO      #FX_RATES
FROM      COM.FX_RATES AS FX
WHERE     FX_SEQ_NUM=(SELECT MIN(FX_SEQ_NUM) FROM COM.FX_RATES AS X WHERE X.FX_DATE>'2024-04-30' )
AND       DT_REC = (SELECT MIN(DT_REC) FROM COM.FX_RATES AS X WHERE X.FX_DATE>'2024-04-30' )
 
CREATE UNIQUE INDEX IDX1 ON #FX_RATES (FX_CCY_DESCR)
---------------------------------------------------------------------------------------------------

/**********ΕΓΓΥΗΤΕΣ*********/ 

DROP TABLE IF EXISTS #GUARANTEES_ALL

SELECT *
INTO #GUARANTEES_ALL
FROM 
(
SELECT 3 AS ID,
ISNULL(MRG.NEW_CST_ID,A.CST_ID) AS CST_ID ,
ACC.ACC_ID,
ACC.APPL_TP_ID AS FEED_SRC_STM,
ACC.CCY,
ACC.ACC_CTG_PRD_ID,
ACC.ACC_SUB_CTG_ID,
ACC.FNC_STATUS_ID,
N'ΕΓΓΥΗΤΗΣ' AS CST_TYPE_NM,
ACC.DT_ACC_STRT,
ISNULL(ACC.DT_ACC_CLOSE,'9999-12-31') AS DT_ACC_CLOSE,
PRD.PRD_GRP_ID,
PRD.PRD_CD

FROM COLL.CST_X_COLL A 
INNER JOIN COLL.COLL_D B ON A.COLL_ID=B.COLL_ID AND B.DT_END>'2024-04-30' AND B.DT_EFF<='2024-04-30' AND B.COLL_STATUS_ID=2 AND B.COLL_TP_ID IN (1)
INNER JOIN COLL.RTL_ACC_X_COLL C ON C.COLL_ID=B.COLL_ID AND C.DT_EFF<='2024-04-30' AND C.DT_END>'2024-04-30' 
INNER JOIN ACC.ACC ACC ON ACC.ACC_ID=B.ACC_ID AND ACC.DT_EFF<='2024-04-30' AND ACC.DT_END>'2024-04-30' AND ACC.APPL_TP_ID IN ('IRL','IRCR','P8','LAA', 'CLA', 'ODA') AND ACC.ACC_LIFE_STATUS_ID=4 
AND ACC.ACC_CTG_PRD_ID IN (1,2,3,4)
LEFT JOIN COM.PRD PRD ON PRD.PRD_ID=ACC.PRD_ID AND PRD.DT_EFF<='2024-04-30' AND PRD.DT_END>'2024-04-30' 
LEFT JOIN CST.CST_MERGED MRG ON MRG.OLD_CST_ID=A.CST_ID AND MRG.MRG_TYPE_ID=1 AND MRG.NEW_CST_ID<>MRG.OLD_CST_ID AND MRG.DT_EFF<='2024-04-30' AND MRG.DT_END>'2024-04-30'
WHERE  A.DT_END> '2024-04-30'  AND A.DT_EFF<='2024-04-30' AND A.COLL_X_CST_TP_ID = 1  AND A.RCD_STS=1
AND ISNULL(PRD.PRD_GRP_ID,0)<>'1190'

UNION

SELECT 4 AS ID,
ISNULL(MRG.NEW_CST_ID,A.CST_ID) AS CST_ID ,
ACC.ACC_ID,
ACC.APPL_TP_ID AS FEED_SRC_STM,
ACC.CCY,
ACC.ACC_CTG_PRD_ID,
ACC.ACC_SUB_CTG_ID,
ACC.FNC_STATUS_ID,
N'ΕΓΓΥΗΤΗΣ' AS CST_TYPE_NM,
ACC.DT_ACC_STRT,
ISNULL(ACC.DT_ACC_CLOSE,'9999-12-31') AS DT_ACC_CLOSE,
PRD.PRD_GRP_ID,
PRD.PRD_CD

FROM COLL.CST_X_COLL A 
INNER JOIN COLL.COLL_D B ON A.COLL_ID=B.COLL_ID AND B.DT_END>'2024-04-30' AND B.DT_EFF<='2024-04-30' AND B.COLL_STATUS_ID=2 AND B.COLL_TP_ID IN (1)
INNER JOIN COLL.CRP_CNT_X_COLL C ON C.COLL_ID=B.COLL_ID AND C.DT_EFF<='2024-04-30' AND C.DT_END>'2024-04-30' 
INNER JOIN CNT.ACC_X_CNT D ON D.CNT_ID=C.CNT_ID AND D.DT_EFF<='2024-04-30' AND D.DT_END>'2024-04-30' AND D.RCD_STS=1
/**cosmos start**/
INNER JOIN ACC.ACC ACC ON ACC.ACC_ID=D.ACC_ID AND ACC.DT_EFF<='2024-04-30' AND ACC.DT_END>'2024-04-30' AND ACC.APPL_TP_ID IN ('IRL','IRCR','P8','LAA', 'CLA', 'ODA') AND ACC.ACC_LIFE_STATUS_ID=4 
/**cosmos end**/
AND ACC.ACC_CTG_PRD_ID IN (1,2,3,4)
LEFT JOIN COM.PRD PRD ON PRD.PRD_ID=ACC.PRD_ID AND PRD.DT_EFF<='2024-04-30' AND PRD.DT_END>'2024-04-30'
LEFT JOIN CST.CST_MERGED MRG ON MRG.OLD_CST_ID=A.CST_ID AND MRG.MRG_TYPE_ID=1 AND MRG.NEW_CST_ID<>MRG.OLD_CST_ID AND MRG.DT_EFF<='2024-04-30' AND MRG.DT_END>'2024-04-30'
WHERE  A.DT_END> '2024-04-30'  AND A.DT_EFF<='2024-04-30' AND A.COLL_X_CST_TP_ID = 1 AND A.RCD_STS=1
AND ISNULL(PRD.PRD_GRP_ID,0)<>'1190'
) AS GUARANTEES_ALL

--Eggyhtes ends
--Eggyhtes count
DROP TABLE IF EXISTS #COUNT_EGG_P8
select acc_id,count(CST_ID) as COUNT_EGG_P8
into #COUNT_EGG_P8
from #GUARANTEES_ALL
group by 
acc_id
------------------------------------------------------------


--DROP TABLE IF EXISTS #ACC_SUM
--SELECT ACC_ID, 
--SUM( EOD_OVD_PTRMNL_BOOK_BAL_AMT +EOD_A88_OVD_INT_AMT + EOD_OVD_3RD_PARTY_BAL_AMT + EOD_PRTL_WRT_OFF_AMT) AS AMT_SUM
--INTO #ACC_SUM
--FROM lend.ACC_LOAN_BAL_EOD
--WHERE dt_eff <= '2024-04-30'
--      AND DT_END > '2024-04-30'

--GROUP BY ACC_ID
	    

--DROP TABLE IF EXISTS #TEKE_P8_PERIMETER
--SELECT acc.ACC_ID, acc.APPL_TP_ID, acc.MGN_BRNCH_ID as MGN_BRNCH_ID, acc.ACC_CTG_PRD_ID,srgt.acc_unq_cd as acc_unq_cd
--INTO #TEKE_P8_PERIMETER
--FROM acc.ACC acc
--inner join #ACC_SRGT srgt
--      on srgt.acc_id = acc.acc_id
--INNER JOIN #ACC_SUM ACC_SUM 
--	ON ACC_SUM.ACC_ID = acc.ACC_ID
--LEFT JOIN LEND.ACC_LOAN_EARTH_SUPPL_FIN EARTH
--ON EARTH.ACC_ID = ACC.ACC_ID
--WHERE acc.ACC_LIFE_STATUS_ID = 4
--AND acc.APPL_TP_ID = 'P8' --isodunamo me feed_src_stm
--AND ACC_SUM.AMT_SUM > 0
--AND acc.DT_EFF <= '2024-04-30'
--AND acc.DT_END >  '2024-04-30'
--AND EARTH.ACC_ID IS NULL


-----pedio symbashs
DROP TABLE IF EXISTS #SYMBASH
SELECT   P8_PERIMETER.ACC_ID,P8_PERIMETER.ACC_CTG_PRD_ID,CNT_SRGT.CNT_UNQ_CD,--ACC_LOAN.LOAN_TP_ID,CNT_SRGT_MASTER.CNT_UNQ_CD,
	CASE WHEN P8_PERIMETER.ACC_CTG_PRD_ID = 3 THEN CNT_SRGT.CNT_UNQ_CD 
	END AS SYMBASH
INTO #SYMBASH
FROM #TEKE_P8_PERIMETER P8_PERIMETER
LEFT JOIN CNT.ACC_X_CNT ACC_X_CNT
	ON P8_PERIMETER.ACC_ID = ACC_X_CNT.ACC_ID
	AND ACC_X_CNT.DT_END > '2024-04-30'
	AND ACC_X_CNT.DT_EFF <= '2024-04-30'
	AND ACC_X_CNT.RCD_STS = 1
LEFT JOIN CNT.CNT_SRGT CNT_SRGT
	ON CNT_SRGT.CNT_ID = ACC_X_CNT.CNT_ID
GROUP BY P8_PERIMETER.ACC_ID,P8_PERIMETER.ACC_CTG_PRD_ID,CNT_SRGT.CNT_UNQ_CD, 
CASE WHEN P8_PERIMETER.ACC_CTG_PRD_ID = 3 THEN CNT_SRGT.CNT_UNQ_CD END -- CHANGE CASE FOR SYMBASH

--"Από τον πίνακα cnt.CNT_X_CST με CNT_CST_RLTP_TP_ID=1 και RCD_STS=1 βρίσκω αν υπάρχουν συνοφειλέτες την batch date. 
--Αν δεν υπάρχουν τότε το πεδίο παίρνει τιμή 1.
--Αν υπάρχουν τότε το πεδίο παίρνει τιμή count(CST_ID) +1 [εναλλακτικά μπορεί να υπολογιστεί ως max(CST_SN) + 1]"
DROP TABLE IF EXISTS #COUNT_CST
SELECT ACC_X_CNT.ACC_ID, COUNT(CNT_X_CST.CST_ID)+1 AS COUNT_CST
INTO #COUNT_CST
FROM cnt.ACC_X_CNT ACC_X_CNT
INNER JOIN #TEKE_P8_PERIMETER PER
	ON PER.ACC_ID = ACC_X_CNT.ACC_ID
	AND PER.ACC_ID = ACC_X_CNT.ACC_ID
	AND ACC_X_CNT.RCD_STS = 1
	AND ACC_X_CNT.DT_EFF <= '2024-04-30'
	AND ACC_X_CNT.DT_END > '2024-04-30'
LEFT JOIN cnt.CNT_X_CST	CNT_X_CST
	ON CNT_X_CST.CNT_ID = ACC_X_CNT.CNT_ID
	AND CNT_X_CST.RCD_STS = 1
	AND CNT_X_CST.DT_EFF <= '2024-04-30'
	AND CNT_X_CST.DT_END > '2024-04-30'
	AND CNT_X_CST.CNT_CST_RLTP_TP_ID = 1
GROUP BY ACC_X_CNT.ACC_ID


DROP TABLE IF EXISTS #LHX_ΑΜΝΤ
SELECT ACC_LOAN_BAL.ACC_ID 
	   ,SUM(ISNULL(IIF(EOD_OVD_PTRMNL_BOOK_BAL_AMT          <-999999999999.99,0,EOD_OVD_PTRMNL_BOOK_BAL_AMT), 0)           + 
		    ISNULL(IIF(EOD_A88_OVD_INT_AMT                  <-999999999999.99,0,EOD_A88_OVD_INT_AMT), 0) 	               +
		    ISNULL(IIF(EOD_OVD_3RD_PARTY_BAL_AMT            <-999999999999.00,0,EOD_OVD_3RD_PARTY_BAL_AMT), 0)             +
		    ISNULL(IIF(EOD_ACCR_PTRMNL_OVD_INT_AMT          <-999999999999.00,0,EOD_ACCR_PTRMNL_OVD_INT_AMT), 0)           +
		    ISNULL(IIF(EOD_ACCR_OVD_INT_AMT                 <-999999999999.00,0,EOD_ACCR_OVD_INT_AMT), 0)	               +
		    ISNULL(IIF(EOD_ACCR_PTRMNL_3RD_PARTY_OVD_INT_AMT<-999999999999.00,0,EOD_ACCR_PTRMNL_3RD_PARTY_OVD_INT_AMT), 0) +
		    ISNULL(IIF(EOD_ACCR_3RD_PARTY_OVD_INT_AMT       <-999999999999.00,0,EOD_ACCR_3RD_PARTY_OVD_INT_AMT), 0)		   +
			ISNULL(IIF(EOD_PRTL_WRT_OFF_AMT					<-999999999999.00,0,EOD_PRTL_WRT_OFF_AMT),0) 
		   ) AS LHX_AMNT
INTO #LHX_ΑΜΝΤ 

FROM  #TEKE_P8_PERIMETER PER
LEFT JOIN lend.ACC_LOAN_BAL_EOD ACC_LOAN_BAL
	ON PER.ACC_ID = ACC_LOAN_BAL.ACC_ID
	AND ACC_LOAN_BAL.DT_EFF <= '2024-04-30'
	AND ACC_LOAN_BAL.DT_END >  '2024-04-30'
LEFT JOIN lend.ACCRUALS ACCRUALS 
ON  ACCRUALS.ACC_ID = ACC_LOAN_BAL.ACC_ID
	AND ACCRUALS.DT_REC = '2024-04-30'

GROUP BY ACC_LOAN_BAL.[ACC_ID],
	     ACC_LOAN_BAL.[BAL_TP_ID]


DROP TABLE IF EXISTS #LHX_ΑΜΝΤ_EUR
SELECT ACC.ACC_ID, 
       CAST(LHX_ΑΜΝΤ.LHX_AMNT/ISNULL(FX_RATES.FX_ECBREF_PCT,1) AS DECIMAL(15,2))  AS LHX_ΑΜΝΤ_EUR,
	   ACC.CCY
INTO #LHX_ΑΜΝΤ_EUR
FROM #LHX_ΑΜΝΤ LHX_ΑΜΝΤ
INNER JOIN ACC.ACC ACC
ON ACC.ACC_ID = LHX_ΑΜΝΤ.ACC_ID
AND ACC.DT_EFF <= '2024-04-30'
AND ACC.DT_END >  '2024-04-30'
LEFT JOIN #FX_RATES FX_RATES ON FX_RATES.FX_CCY_DESCR=ACC.CCY

-------------------------------------- select distinct * from #teke_loan_p8 where symbash_system <> '1'
INSERT INTO #TEKE_LOAN_P8
SELECT	DISTINCT
		'2024-04-30' as RUN_ID,
		CASE WHEN P8_PERIMETER.APPL_TP_ID IN ('P8')  THEN CONCAT('08', ACC_SRGT.ACC_UNQ_CD)
			 WHEN P8_PERIMETER.APPL_TP_ID IN ('CLA') THEN CONCAT('09', ACC_SRGT.ACC_UNQ_CD)
		END AS TEKE_IBAN,
		/**cosmos start**/
		CASE WHEN P8_PERIMETER.APPL_TP_ID IN ('P8')  THEN '08'
			 WHEN P8_PERIMETER.APPL_TP_ID IN ('CLA') THEN '09'
		/**cosmos end**/
		END AS LOAN_SYSTEM,
		ACC_SRGT.ACC_UNQ_CD AS LOAN_ID,
	    P8_PERIMETER.MGN_BRNCH_ID AS BR_GL,
		/**cosmos start**/
		CASE WHEN P8_PERIMETER.APPL_TP_ID IN ('CLA', 'P8')  THEN '00' 
		/**cosmos end**/
		END AS LOAN_PARTIC,
		ISNULL(SSX.P8_SSX, N'Λ '),

		CASE WHEN P8_PERIMETER.ACC_CTG_PRD_ID = 3 THEN '1' ELSE '00'
		END AS SYMBASH_SYSTEM,
		-- Μόνο για ACC_CTG_PRD_ID=3 δίνεται το CNT_UNQ_CD 
        -- που αντλείται από την εγγραφή του ACC_X_CNT
		ISNULL(SYMBASH.SYMBASH,'') AS SYMBASH,

		'00' AS LHX_AMNT_GL,
		'00' AS LHX_AMNT_NO_GL,
		  LHX_ΑΜΝΤ_EUR.LHX_ΑΜΝΤ_EUR AS LHX_AMNT,
		--Αν ο λογαριασμός είναι σε συνάλλαγμα, γίνεται αποτίμηση σε € με 
		--ECBRef του τελευταίου δελτίου της ημέρας έκδοσης του αρχείου."

		----CST_X_ACC και COUNT(CST_ID) με ACC_X_CST_TYPE_ID=1
		COUNT_CST.COUNT_CST AS ΒΕΝ_CNTR,
		ISNULL(COUNT_EGG_P8.COUNT_EGG_P8,0) AS EGG_CNTR

FROM #TEKE_P8_PERIMETER P8_PERIMETER
LEFT JOIN #ACC_SRGT	ACC_SRGT
	ON P8_PERIMETER.ACC_ID = ACC_SRGT.ACC_ID
LEFT JOIN #COUNT_CST COUNT_CST
	ON COUNT_CST.ACC_ID = P8_PERIMETER.ACC_ID
LEFT JOIN #LHX_ΑΜΝΤ_EUR LHX_ΑΜΝΤ_EUR  
	ON LHX_ΑΜΝΤ_EUR.ACC_ID = P8_PERIMETER.ACC_ID
LEFT JOIN #COUNT_EGG_P8 COUNT_EGG_P8
ON COUNT_EGG_P8.ACC_ID = P8_PERIMETER.ACC_ID
LEFT JOIN #SYMBASH SYMBASH
	ON SYMBASH.ACC_ID = P8_PERIMETER.ACC_ID
LEFT JOIN #P8_SSX	SSX
	ON SSX.ACC_ID = P8_PERIMETER.ACC_ID
--WHERE COUNT_CST.COUNT_CST != 1
LEFT JOIN lend.ACC_LOAN_BAL_EOD ACC_LOAN_BAL
	ON ACC_LOAN_BAL.ACC_ID = P8_PERIMETER.ACC_ID
	AND ACC_LOAN_BAL.DT_EFF <= '2024-04-30'
	AND ACC_LOAN_BAL.DT_END >  '2024-04-30'
LEFT JOIN lend.ACCRUALS ACCRUALS 
	ON ACCRUALS.ACC_ID = ACC_LOAN_BAL.ACC_ID
	AND ACCRUALS.DT_REC = '2024-04-30'
