--
-- DBA_INDEXES -  RECUPERA ÍNDICES DE UMA TABELA ESPECÍFICA
--
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

ACCEPT TABLE_NAME CHAR PROMPT "Enter TABLE ==> TABLE_NAME"


SELECT INDEX_NAME, LAST_ANALYZED, NUM_ROWS FROM DBA_INDEXES WHERE TABLE_NAME = '&&TABLE_NAME'
