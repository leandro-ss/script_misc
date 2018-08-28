PROMPT
PROMPT ==> FUNÇÃO: TEMPO ESTIMADO DE RETORNO
PROMPT
select
   a.sid,
   a.serial#,
   a.username,
   b.osuser,
   a.opname,
   to_char(a.start_time,'dd/mm/yyyy hh24:mi:ss') as "Start",
   round(100*(a.sofar/a.totalwork),2) as PCT_COMPLETED,
   a.sofar,
   a.totalwork,
   a.target,
   a.message
from
   v$session_longops a,
   v$session b
where
   a.sid = b.sid
   and b.status = 'ACTIVE'
   and a.time_remaining > 0
/