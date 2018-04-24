alter session set nls_date_format = 'dd-mm-yyyy hh24:mi:ss';
Set lines 1000 pages 1000
col DB_User for a15
col machine for a20
col Client_User for a15
col SPID for a10

SELECT   si.SID, s.serial# "Serial#",s.sql_id, p.spid, s.username "DB_User", s.osuser "Client_User",
         s.status "Status", s.machine "Machine",
         s.logon_time "Connect_Time",
         SYSDATE - (s.last_call_et / 86400) "Last_Call", p.program, s.module
    FROM v$session s,
         v$process p,
         SYS.V_$SESS_IO si
   WHERE s.paddr    = p.addr(+)
     AND si.SID(+)  = s.SID
     AND s.TYPE     <> 'BACKGROUND' -- processos de segundo plano da instância oracle
     AND s.status   <> 'INACTIVE'
	--AND s.machine like '%mabolo%'
	  --AND s.username='OIM'
	  --and p.spid=29665
		--and s.serial#=29664
	 --AND s.SID in (345)
     --AND s.last_call_et > 300
     ORDER BY 10,11;