USE EDW

--Μπορείς να μου επιστρέψεις τα πεδία και τα data types του πίνακα ACC_LG_BT schema lg;
--Ευχαριστώ
--Απάντηση: Στο παρακάτω query επιστρέφονται τα πεδία και τα data types του πίνακα ACC_LG_BT schema lg.
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE (TABLE_NAME = 'ACC_LG_BT' AND TABLE_SCHEMA = 'lg')
OR
(TABLE_NAME = 'ACC' AND TABLE_SCHEMA = 'acc')
OR
(TABLE_NAME = 'ACC_SRGT' AND TABLE_SCHEMA = 'acc')
;


--μπορείς να μου βάλεις τα βασικά joins ώστε να κάνω select τα LGS και τα CNT_ID τους;
--Ευχαριστώ
--Απάντηση: Στο παρακάτω query έχουμε τα βασικά joins για να κάνουμε select τα LGS και τα CNT_ID τους.

SELECT ACC_UNQ_CD, CNT_ID
FROM lg.ACC_LG_BT
JOIN acc.ACC_SRGT ON ACC_LG_BT.ACC_ID = ACC_SRGT.ACC_ID
JOIN cnt.ACC_X_CNT ON ACC_SRGT.ACC_ID = ACC_X_CNT.ACC_ID

--τέλος

