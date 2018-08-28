------------------------------------------------------------------------
-- para verificar as sessões
------------------------------------------------------------------------
col username format a10
set linesize 300
col job_name format a20
col program format a60
SELECT TO_CHAR (SYSDATE, 'YYYY-MM-DD HH24:MI:SS') "DATE",
     s.program,
     s.sid,
     s.status,
     s.username,
     d.job_name,
     p.spid,
     s.serial#,
     p.pid
FROM V$SESSION s, V$PROCESS p, DBA_DATAPUMP_SESSIONS d
WHERE p.addr = s.paddr AND s.saddr = d.saddr;