USE EDW

-- μπορείς να μου φτιάξεις τα joins μεταξύ του πίνακα acc.acc και lg.acc_lg_bt;
SELECT TOP 10 * FROM acc.acc
INNER JOIN lg.acc_lg_bt
ON acc.acc.acc_id = lg.acc_lg_bt.acc_id
--WHERE acc.acc.acc_id = 1;

-- στο παραπάνω query θέλω να μου φέρνει τα contracts μέσω του πίνακα cnt.ACC_X_CNT:
SELECT TOP 10 ACC_X_CNT.* FROM acc.acc
INNER JOIN lg.acc_lg_bt
ON acc.acc.acc_id = lg.acc_lg_bt.acc_id
INNER JOIN cnt.ACC_X_CNT
ON acc.acc.acc_id = cnt.ACC_X_CNT.acc_id
--WHERE acc.acc.acc_id = 1;

-- στο παραπάνω query θέλω να μου φτιάξεις το join με τον cnt.CNT_MAIN
SELECT TOP 10 CNT_MAIN.* FROM acc.acc
INNER JOIN lg.acc_lg_bt
ON acc.acc.acc_id = lg.acc_lg_bt.acc_id
INNER JOIN cnt.ACC_X_CNT
ON acc.acc.acc_id = cnt.ACC_X_CNT.acc_id
INNER JOIN cnt.CNT_MAIN
ON cnt.ACC_X_CNT.cnt_id = cnt.CNT_MAIN.cnt_id
--WHERE acc.acc.acc_id = 1;

-- στο παραπάνω query θέλω να μου φέρεις και τον πελάτη μέσω του πίνακα cst.CST_X_ACC ή cnt.CNT_X_CST:
SELECT TOP 10 CST_X_ACC.* FROM acc.acc
INNER JOIN lg.acc_lg_bt
ON acc.acc.acc_id = lg.acc_lg_bt.acc_id
INNER JOIN cnt.ACC_X_CNT
ON acc.acc.acc_id = cnt.ACC_X_CNT.acc_id
INNER JOIN cnt.CNT_MAIN
ON cnt.ACC_X_CNT.cnt_id = cnt.CNT_MAIN.cnt_id
INNER JOIN cst.CST_X_ACC
ON acc.acc.acc_id = cst.CST_X_ACC.acc_id
--WHERE acc.acc.acc_id = 1;

-- θέλω να κάνω join με τον acc.acc_srgt αλλά επειδή είναι πολύ μεγάλος θέλω να χρησιμοποιήσω κάποιον temporary πίνακα:
SELECT TOP 10 * INTO #ACC_SRGT FROM acc.acc_srgt
WHERE src_stm_id = 'LGS'