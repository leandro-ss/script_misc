 select
  s.sid,
  s.serial#,
  p.spid,
  s.sql_hash_value,
  s.prev_hash_value,
  s.username,
  s.osuser,
  s.status,
  w.event,
  s.module,
  s.program,
  s.logon_time,
  last_call_et,
         s.machine,
  s.terminal
 from
  v$session  s,
  v$session_wait  w,
  v$process p
 where
  s.sid = w.sid  and
  p.addr = s.paddr and
  s.status = 'ACTIVE' and
  s.username is not null  
/
