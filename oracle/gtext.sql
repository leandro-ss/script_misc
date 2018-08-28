-------------------------------------------------------------------------------------------------------
-- 
-- 
-- 
-------------------------------------------------------------------------------------------------------

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

select dbms_lob.substr( sql_text, 4000, 1    ) from dba_hist_sqltext where sql_id = '&sql_id'
union all
select dbms_lob.substr( sql_text, 4000, 4001 ) from dba_hist_sqltext where sql_id = '&sql_id';
