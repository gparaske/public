SELECT TOP (1000) [CurrentBatchDate]
      ,[NextBatchDate]
      ,[PreviousBatchDate]
      ,[PreviousPhysicalDate]
      ,[LastPhysicalDateCurMonth]
      ,[FirstPhysicalDatePrevMonth]
      ,[LastPhysicalDatePrevMonth]
  FROM [EDW].[ctrl].[BATCH_DATE]
  
/* Η αρχή του μήνα: */
declare @PREV_DTSTART nvarchar(20);
SET @PREV_DTSTART = DATEADD(DAY,1,EOMONTH('2018-03-11',-1));
SELECT @PREV_DTSTART AS "FIRST DAY OF MONTH";

/* Η αρχή του μήνα: */
SELECT DATEADD(DAY,1,EOMONTH('2022-06-30',-1))
/* Η αρχή του έτους: */
SELECT DATEADD(yy, DATEDIFF(yy, 0, '2022-06-30'), 0) 
/* Η αρχή του τριμήνου: */
SELECT DATEADD(qq, DATEDIFF(qq, 0, '2023-07-03')-1, 0)
/* Τέλος του μήνα: */
SELECT EOMONTH('2022-06-15')
/* Τέλος του προηγούμενου μήνα: */
SELECT EOMONTH('2022-06-15',-1)
/* Τέλος του προηγούμενου τριμήνου: */
SELECT DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-03-31')-1, 0)))
/* Τέλος του τριμήνου: */
SELECT DATEADD(DAY,-1,DATEADD(MM, 6, DATEADD(qq, DATEDIFF(qq, 0, '2024-03-31')-1, 0)))
/* Αυξουσα απομάκρινση από την αρχή του τριμήνου: */
SELECT DATEDIFF(MONTH, DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-01-31')-1, 0))), '2024-01-31'), DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-01-31')-1, 0))), '2024-01-31'
UNION ALL
SELECT DATEDIFF(MONTH, DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-02-29')-1, 0))), '2024-02-29'), DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-02-29')-1, 0))), '2024-02-29'
UNION ALL
SELECT DATEDIFF(MONTH, DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-03-31')-1, 0))), '2024-03-31'), DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-03-31')-1, 0))), '2024-03-31'

SELECT DATEDIFF(MONTH, DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-04-30')-1, 0))), '2024-04-30'), DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-04-30')-1, 0))), '2024-04-30'
UNION ALL
SELECT DATEDIFF(MONTH, DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-05-31')-1, 0))), '2024-05-31'), DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-05-31')-1, 0))), '2024-05-31'
UNION ALL
SELECT DATEDIFF(MONTH, DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-06-30')-1, 0))), '2024-06-30'), DATEADD(DAY,-1,DATEADD(MM, 3, DATEADD(qq, DATEDIFF(qq, 0, '2024-06-30')-1, 0))), '2024-06-30'

SELECT MONTH('2024-01-31'), MONTH('2024-02-29'), MONTH('2024-03-31'), MONTH('2024-04-30'), MONTH('2024-05-31'), MONTH('2024-06-30')

/* Συνταγή: */
declare @EKDOSH nvarchar(20);
SET @EKDOSH = '2020-10-09';
SELECT @EKDOSH as "ΕΚΔΟΣΗ"
     , FORMAT(DATEADD(DAY, 28, @EKDOSH), 'yyyy-MM-dd') AS "ΔΕΥΤΕΡΗ"
     , FORMAT(DATEADD(DAY, 28+28, @EKDOSH), 'yyyy-MM-dd') AS "ΤΡΙΤΗ"
     , FORMAT(DATEADD(DAY, 28+28+28, @EKDOSH), 'yyyy-MM-dd') AS "ΕΠΑΝΕΚΔΟΣΗ";
     --, FORMAT(DATEADD(DAY, 28+28+28, @EKDOSH), 'yyyy-MM-dd') AS "ΤΕΤΑΡΤΗ"
     --, FORMAT(DATEADD(DAY, 28+28+28+28, @EKDOSH), 'yyyy-MM-dd') AS "ΕΠΑΝΕΚΔΟΣΗ";

--ΕΚΔΟΣΗ		ΔΕΥΤΕΡΗ		ΤΡΙΤΗ		ΤΕΤΑΡΤΗ		ΕΠΑΝΕΚΔΟΣΗ
--2019-06-15	2019-07-13	2019-08-10	2019-09-07	2019-10-05
--ΕΚΔΟΣΗ		ΔΕΥΤΕΡΗ		ΤΡΙΤΗ		ΕΠΑΝΕΚΔΟΣΗ
--2020-10-09	2020-11-02	2020-12-01	2021-01-09