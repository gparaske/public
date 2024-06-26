USE EDW_UAT;
DECLARE @ReportingDate datetime
;
SET @ReportingDate = '2023-12-31';

SELECT @ReportingDate REF_DT,
    SAP_ACC_ID CNID,
    SUM(AMT_SAP_ACC_BAL) OUTAM
FROM gl.SAP_ACC_BAL
WHERE SAP_ACC_ID = '4801910100'
    AND DT_REC = (SELECT MAX(DT_REC)
    FROM gl.SAP_ACC_BAL
    WHERE DT_REC<=@ReportingDate)
    AND ORG_UNIT_CD = 37
GROUP BY SAP_ACC_ID
