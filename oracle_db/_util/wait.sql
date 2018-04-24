COL EVENT             FORMAT A30
COL TIME_WAITED_TOTAL FORMAT 999,999,999,999
COL TIME_WAITED_AVG   FORMAT 999,999,999,999.0

prompt =====================
prompt Waits
prompt =====================
select a.sid,
       a.event,
       a.p2,
       a.wait_time,
       a.seconds_in_wait,
       a.state,
       b.name
from v$session_wait a,
     v$latch        b
where a.p2 not in (0,1)
and   a.p2      = b.latch# (+)
order by a.p2
/

prompt =====================
prompt Waits por LATCH FREE
prompt =====================
select a.sid, b.name
from v$session_wait a,
     v$latch        b
where a.event = 'latch free'
and   a.p2    = b.latch#
/

prompt =======================
prompt Session Waits por EVENT
prompt =======================
SELECT EVENT, SUM(TIME_WAITED) TIME_WAITED_TOTAL, AVG(TIME_WAITED) TIME_WAITED_AVG
FROM V$SESSION_EVENT
GROUP BY EVENT
ORDER BY TIME_WAITED_AVG
/

prompt =======================
prompt System Waits por EVENT
prompt =======================
SELECT *
FROM V$SYSTEM_EVENT
ORDER BY AVERAGE_WAIT
/
