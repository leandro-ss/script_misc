DEFINE MASTER_SITE      = &MASTER_SITE

DEFINE TABLE_OWNER      = &TABLE_OWNER
DEFINE TABLE_NAME       = &TABLE_NAME

DEFINE TABLESPACE_INDEX = &TABLESPACE_INDEX
DEFINE TABLESPACE_DATA  = &TABLESPACE_DATA

SET ECHO OFF HEAD OFF FEEDBACK OFF VERIFY OFF TRIMSPOOL ON LINESIZE 999 PAGESIZE 50000

ttitle  left 'PROMPT'	 skip 1 -
        left 'PROMPT... Gerando Snapshot '	tab skip 1 -
        left 'PROMPT'	 skip 1 -
        left 'create snapshot ' own '.' tab skip 1 left ' tablespace &TABLESPACE_DATA using index tablespace &TABLESPACE_INDEX refresh fast start with sysdate with primary key as select '

column id                  noprint
column own   new_value own noprint
column tab   new_value tab noprint
column tam   format a15
column col   format a120
column null1 format a40
column null2 format a100

break on own on tab skip page

PROMPT
PROMPT  AGUARDE, gerando Materialized View...
PROMPT

set term off

spool G_SNP_&TABLE_OWNER._&TABLE_NAME..SQL

select column_id              "id",
       owner                  "own",
       table_name             "tab",
       '  '||column_name||',' "col"
from dba_tab_columns x
where column_id < (
  select max(column_id)
  from dba_tab_columns w
  where w.table_name = x.table_name
  and   w.owner      = x.owner)
and   x.table_name = UPPER('&TABLE_NAME')
and   x.owner      = UPPER('&TABLE_OWNER')
union
select column_id    "id",
       y.owner      "own",
       y.table_name "tab",
       '  ' || column_name  || ' from '||y.owner||'.'||y.table_name||'@&MASTER_SITE;' "null2"
from dba_tab_columns y,
     dba_tables h
where column_id = (
  select max(column_id)
  from dba_tab_columns z
  where z.table_name = y.table_name
  and   z.owner      = y.owner)
and   y.table_name = h.table_name
and   y.owner      = h.owner
and   h.table_name = UPPER('&TABLE_NAME')
and   h.owner      = UPPER('&TABLE_OWNER')
order by "id";

spool  off
ttitle off

clear breaks
clear columns

--set pagesize 50000 linesize 999 verify on feed on head on
set term on

--UNDEFINE MASTER_SITE
--UNDEFINE TABLE_OWNER
--UNDEFINE TABLE_NAME
--UNDEFINE TABLESPACE_INDEX
--UNDEFINE TABLESPACE_DATA
ACCEPT DUMMY_ PROMPT 'PRESSIONE [ENTER]'
