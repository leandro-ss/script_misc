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

--
ACCEPT event CHAR PROMPT "Enter Wait Event ==> "
ACCEPT date_ini CHAR PROMPT "Enter Begin (ddmmyyyy) ==> "
ACCEPT date_fim CHAR PROMPT "Enter End   (ddmmyyyy) ==> "


WITH BLOCKER AS
  (
  SELECT DISTINCT BLOCKER.SQL_ID, BLOCKER.SQL_OPNAME
  FROM DBA_HIST_ACTIVE_SESS_HISTORY ASH
  JOIN DBA_HIST_ACTIVE_SESS_HISTORY BLOCKER
  ON ASH.SESSION_SERIAL#      =BLOCKER.BLOCKING_SESSION_SERIAL#
  AND BLOCKER.SAMPLE_ID       = ASH.SAMPLE_ID
  AND BLOCKER.SNAP_ID         = ASH.SNAP_ID
  AND BLOCKER.INSTANCE_NUMBER = ASH.INSTANCE_NUMBER
  AND ASH.EVENT               ='&&event';
  JOIN DBA_HIST_SNAPSHOT SNAP
  ON SNAP.SNAP_ID = ASH.SNAP_ID
  AND SNAP.INSTANCE_NUMBER = ASH.INSTANCE_NUMBER
  AND SNAP.END_INTERVAL_TIME >= TO_DATE ('&&date_ini' , 'DD-MM-YYYY HH24:MI:SS')
  AND SNAP.END_INTERVAL_TIME  < TO_DATE ('&&date_fim' , 'DD-MM-YYYY HH24:MI:SS')
  AND ASH.EVENT = 'read by other session'
)
SELECT B.SQL_OPNAME, T.SQL_ID, T.SQL_TEXT
FROM DBA_HIST_SQLTEXT T
JOIN BLOCKER B
ON T.SQL_ID=B.SQL_ID ;
