spool sql_tracking.log

select 'TRACKING_DATE;INSTANCE;SQL_ID;MODULE;USERNAME;ELAP;BG;CPU;EXECS;INV;PARSE;DR;PHYS_READ;PHYS_WRITE;INTERCONNECT_MB;ROWS' extraction from dual;

with
  t0 as (
  select snap.end_interval_time snap_time, sqls.instance_number, sqls.sql_id, sqls.plan_hash_value, sqls.module, sqls.parsing_schema_name username,
         elapsed_time_delta/1000000 elap, buffer_gets_delta bg, cpu_time_delta/1000000 cpu,
         executions_delta execs, invalidations_delta inv, parse_calls_delta parse,
         disk_reads_delta dr, physical_read_bytes_delta phys_read, physical_write_bytes_delta phys_write,
         io_interconnect_bytes_delta/1024/1024 interconnect_mb, rows_processed_delta rows_proc
    from sys.dba_hist_sqlstat sqls, sys.dba_hist_snapshot snap
   where sqls.dbid = snap.dbid and sqls.snap_id = snap.snap_id and sqls.instance_number = snap.instance_number
     and snap.end_interval_time >= to_date(&begin_date,&date_mask)
     and snap.end_interval_time <= to_date(&end_date,&date_mask))
select * from (
select trunc(snap_time,'hh24'),instance_number,sql_id,plan_hash_value,module,username,
       avg(elap),
       avg(bg),
       avg(cpu),
       avg(execs),
       avg(inv),
       avg(parse),
       avg(dr),
       avg(phys_read),
       avg(phys_write),
       avg(interconnect_mb),
       avg(rows_proc)
from t0
group by trunc(snap_time,'hh24'), instance_number, sql_id, plan_hash_value, module, username
order by trunc(snap_time,'hh24'), instance_number, sql_id, plan_hash_value, module, username);

spool off;

set termout on;
prompt *    sql_tracking.log
set termout off;
