alter session set nls_date_format = 'dd-mm-yyyy hh24:mi:ss';
Set lines 1000 pages 1000
col DB_User for a15
col machine for a20
col Client_User for a15
col SPID for a10
COL COMMAND FORMAT A60
SELECT   s.username, s.event ,'ALTER SYSTEM KILL SESSION '''||si.SID||','|| s.serial#||'''IMMEDIATE;' COMMAND,
         s.status "Status", s.machine "Machine",
         s.logon_time "Connect_Time",
         SYSDATE - (s.last_call_et / 86400) "Last_Call", p.program, s.module
    FROM v$session s,
         v$process p,
         SYS.V_$SESS_IO si
   WHERE s.paddr    = p.addr(+)
     AND si.SID(+)  = s.SID
     AND s.TYPE     <> 'BACKGROUND' -- processos de segundo plano da inst�ncia oracle
     AND s.status   <> 'INACTIVE'
	--AND s.machine like '%mabolo%'
	  --AND s.username='IMPMINFRA'
    AND s.sql_id='8379cqruvtqtu'
	  --and p.spid=29665
		--and s.serial#=29664
	 --AND s.SID in (345)
     --AND s.last_call_et > 300
     ORDER BY "Connect_Time", "Last_Call";