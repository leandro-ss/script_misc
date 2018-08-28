-------------------------------------------------------------------------------------------------------
--
-- SESSION_LONGOPS - SESSOES COM MAIOR TEMPO DE PROCESSAMENTO
--
-------------------------------------------------------------------------------------------------------
set timing off
set autot off
set trimspool on
set trimout on
set long 40000
set lines 2000
set linesize 255;
set pages 0
set echo off
set heading off
set feedback off
set verify off;
set colsep ";"
set serveroutput on size unlimited;



SELECT SID,
       OPNAME,
       TARGET,
       EVENT,
       TRUNC(ELAPSED_SECONDS, 5)         ELAPSED_SECONDS,
       TO_CHAR(START_TIME, 'HH24:MI:SS') START_TIME,
       ROUND((SOFAR/TOTALWORK)*100, 2)   TOTALWORK
FROM V$SESSION_LONGOPS A JOIN V$SESSION B  USING (SID,USERNAME)
WHERE  1=1 --USERNAME IN ('LESSILVA','SCAPACITY01')  
  AND B.STATUS = 'ACTIVE'
  AND A.TIME_REMAINING > 0
ORDER BY ELAPSED_SECONDS;
