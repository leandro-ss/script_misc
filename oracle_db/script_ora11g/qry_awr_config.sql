spool awr_config.log

select 'DBID;INTERVAL;RETENTION' extraction from dual;

select dbid,substr(snap_interval, instr(snap_interval, ' ')+1, 8),to_number(substr(retention, instr(retention, '+')+1, 6)) from dba_hist_wr_control;

spool off;

set termout on;
prompt *    awr_config.log
set termout off;
