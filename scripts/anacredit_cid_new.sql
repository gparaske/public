USE ANACREDIT


--with a as (
--select cur.* from cid_sub cur

--left join cid_sub pre
--on cur.cid = pre.cid
--and cur.insid = pre.insid
--and cur.data_version = '2024033101'
--and  pre.data_version = '2024022901'

--where cur.data_version = '2024033101' and cur.qualification_flag = 1
--and pre.cid is null
--)





select instrument.* 
, RIGHT(SRC_PARALIST_CD, 3) AS ΕΓΚΡΙΤΙΚΟ_ΟΡΓΑΝΟ
, SRC_PARALIST_NM AS ΕΓΚΡΙΤΙΚΟ_ΟΡΓΑΝΟ_DESC

from (


select distinct a.*,  isnull(cast (c.CST_ID as nvarchar(30) ) , a.cid) Debtor , FNC_STATUS_ID, p.SRC_PARALIST_NM descr
from (
select cur.* from cid_sub cur

left join cid_sub pre
on cur.cid = pre.cid
and cur.insid = pre.insid
and cur.data_version = '2024033101'
and  pre.data_version = '2024022901'

where cur.data_version = '2024033101' --and cur.qualification_flag = 1
--and pre.cid is null
AND cur.INSID='1297409ADPTV'
) a

INNER join IFD_sub b
on a.insid = b.INSID
and a.DATA_VERSION = b.DATA_VERSION
and a.OBS_A_ID = 'GR011'
and a.crl = '2'

left join [src].[EDW_CST_CST_X_ACC] c
on b.ACC_ID = cast(c.ACC_ID as nvarchar(30))
and c.RANK_ID = 1
and c.ACC_X_CST_TYPE_ID = 1

left join [src].[EDW_acc_ACC] d
on b.ACC_ID = cast(d.ACC_ID as nvarchar(30))

left join [src].[EDW_lend_ACC_LOAN_BAL_EOD] e
on b.ACC_ID = cast(e.ACC_ID as nvarchar(30))

left join [src].[EDW_ctrl_PARALIST_MAP] p
on p.PARALIST_ID = d.FNC_STATUS_ID and p.PARAGROUP_ID = 312
and p.SRC_STM_CD = 'SAPBA'

where 
b.DATA_VERSION = '2024033101'
and b.OBS_A_ID = 'GR011'
and a.crl = '2'

) instrument

left join CRD_SUB X
on instrument.Debtor = X.cid
and instrument.DATA_VERSION = X.DATA_VERSION

LEFT JOIN [src].[EDW_ctrl_PARALIST_MAP] CC
ON X.DEPT_APPV_DIV_ID = CC.PARALIST_ID AND CC.PARAGROUP_ID = 9 
AND CC.SRC_STM_CD = 'SDPL'
AND CC.DT_END = '99991231'

and instrument.DATA_VERSION = '2024033101'
;