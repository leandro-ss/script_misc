-------------------------------------------------------------------------------------------------------
--
-- File name:   build_bind_vars_awr.sql
--
-- Purpose:     Build SQL*Plus test script w/ variable definitions  - including binds from AWR - formerly build_bind_vars_awr.sql
--
-- Author:      Kerry Osborne
--
-- Description: This script creates a file which can be executed in SQL*Plus. It creates bind variables, 
--              sets the bind variables to the values stored in DBA_HIST_SQLSTAT.BIND_DATA, and then executes 
--              the statement. The sql_id is used for the file name and is also placed in the statement
--              as a comment. Note that numeric bind variable names are not permited in SQL*Plus, so if
--              the statement has numberic bind variable names, they have an 'N' prepended to them. Also
--              note that CHAR variables are converted to VARCHAR2. You should also watch out for dates
--              as SQL*Plus doesn't have a date datatype.
--
-- Usage:       This scripts prompts for two values.
--
--              sql_id:   this is the sql_id of the statement you want to duplicate
--
--              snap_id: this is the snapshot to pull the data from (if you want a specific one)
--
-- See kerryosborne.oracle-guy.com for more info.
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

--
ACCEPT SQL_ID CHAR PROMPT "Enter SQL_ID ==> "
ACCEPT SNAP_ID CHAR PROMPT "Enter SNAP_ID ==> "
VAR ISDIGITS NUMBER
VAR BIND_COUNT NUMBER

COL SQL_TEXT FOR A140 WORD_WRAP
--
--
-- COMENTADO BY LEANDRO spool '&&sql_id'
BEGIN


-- Check for Bind Variables
SELECT COUNT(*) INTO :BIND_COUNT
FROM DBA_HIST_SQL_BIND_METADATA B
WHERE B.SQL_ID = '&&sql_id';


--Check for numeric bind variable names
IF :BIND_COUNT > 0 THEN
SELECT CASE REGEXP_SUBSTR(REPLACE(NAME,':',''),'[[:digit:]]') WHEN REPLACE(NAME,':','') THEN 1 END INTO :ISDIGITS
FROM DBA_HIST_SQL_BIND_METADATA B
WHERE B.SQL_ID = '&&sql_id'
AND ROWNUM < 2
ORDER BY POSITION;
END IF;
END;
/


-- Create variable statements
SELECT
CASE WHEN :BIND_COUNT > 0 THEN
   'variable ' || CASE :ISDIGITS WHEN 1 THEN REPLACE(NAME,':','N') ELSE SUBSTR(NAME,2,30) END || ' ' ||
   REPLACE(DATATYPE_STRING,'CHAR(','VARCHAR2(') 
ELSE NULL END TXT
FROM DBA_HIST_SQL_BIND_METADATA
WHERE SQL_ID='&&sql_id';


-- Set variable values from DBA_HIST_SQLSTAT 
SELECT CASE WHEN :BIND_COUNT > 0 THEN 'begin' ELSE '-- No Bind Variables' END TXT FROM DUAL;

SELECT  
CASE WHEN :BIND_COUNT > 0 THEN
   CASE :ISDIGITS WHEN 1 THEN REPLACE(B.NAME,':',':N') ELSE B.NAME END ||
   ' := ' ||
   CASE WHEN B.DATATYPE = 1 THEN '''' ELSE NULL END ||
   CASE WHEN B.DATATYPE != 1 AND A.VALUE_STRING IS NULL THEN 'NULL' ELSE A.VALUE_STRING  END ||
   CASE WHEN B.DATATYPE = 1 THEN '''' ELSE NULL END ||
   ';' 
ELSE NULL END TXT
FROM TABLE(
  SELECT DBMS_SQLTUNE.EXTRACT_BINDS(BIND_DATA) FROM DBA_HIST_SQLSTAT
  WHERE SQL_ID LIKE NVL('&&sql_id',SQL_ID)
  AND SNAP_ID LIKE NVL('&&snap_id',SNAP_ID)
AND ROWNUM < 2
AND BIND_DATA IS NOT NULL) A, DBA_HIST_SQL_BIND_METADATA B
WHERE B.SQL_ID = '&&sql_id'
AND A.POSITION = B.POSITION
ORDER BY B.POSITION;

SELECT CASE WHEN :BIND_COUNT > 0 THEN 'end;' ELSE NULL END TXT FROM DUAL;
SELECT CASE WHEN :BIND_COUNT > 0 THEN '/' ELSE NULL END TXT FROM DUAL;

-- Generate statement
SELECT CASE WHEN :BIND_COUNT > 0 THEN 'set timing on' ELSE NULL END TXT FROM DUAL;
SELECT CASE WHEN :BIND_COUNT > 0 THEN 'set autotrace trace explain statistics' ELSE NULL END TXT FROM DUAL;

SELECT REGEXP_REPLACE(SQL_TEXT,'(select |SELECT )',' select /* test &&sql_id */ ',1,1) SQL_TEXT FROM (
SELECT CASE :ISDIGITS WHEN 1 THEN REPLACE(SQL_TEXT,':',':N') ELSE SQL_TEXT END ||';' SQL_TEXT
FROM DBA_HIST_SQLTEXT
WHERE SQL_ID = '&&sql_id');

-- COMENTADO BY LEANDRO spool off;