set lines 300
set Pages 300
COL SQl_TEXT for a100
select a.SQl_TEXT
from v$session s, v$process p,v$sqlarea a
where p.addr=s.paddr
  AND a.HASH_VALUE = s.SQL_HASH_VALUE
  and s.sid = '&SID'
/
