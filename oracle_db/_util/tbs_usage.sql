set lines 300 pages 600
select TABLESPACE_NAME, (USED_SPACE*8192)/1024/1024 as "USED_MB", (TABLESPACE_SIZE*8192)/1024/1024 AS  "TOTAL_SIZE_MB",USED_PERCENT
from dba_tablespace_usage_metrics;
