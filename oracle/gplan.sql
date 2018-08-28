-------------------------------------------------------------------------------------------------------
--
-- 
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

ACCEPT sql_id CHAR PROMPT "Enter SQL_ID ==> "

select * from TABLE(dbms_xplan.display_awr('&&sql_id'));