select to_char(snap.end_interval_time, 'dd/mm/yyyy hh24:mi:ss') snap_time, stat.instance_number,
       sum(stat.cpu_time_delta) cpu_time, sum(stat.elapsed_time_delta) elapsed, sum(stat.executions_delta) executions,
       sum(stat.buffer_gets_delta) buffer_gets, sum(stat.rows_processed_delta) rows_processed
  from sys.dba_hist_sqlstat stat, sys.dba_hist_snapshot snap
 where stat.dbid = snap.dbid and stat.snap_id = snap.snap_id and stat.instance_number = snap.instance_number
   and trunc(snap.end_interval_time) >= to_date('01092012', 'ddmmyyyy') and trunc(snap.end_interval_time) <= to_date('30112012', 'ddmmyyyy')
 group by to_char(snap.end_interval_time, 'dd/mm/yyyy hh24:mi:ss'), stat.instance_number;
