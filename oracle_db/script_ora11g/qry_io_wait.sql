spool io_wait.log

select 'IO_WAIT_DATE;INSTANCE;FUNCTION;FILETYPE;MIN_WAIT;AVG_WAIT;P90_WAIT;P95_WAIT;P99_WAIT;MAX_WAIT' extraction from dual;

with
  t0 as (
    select io.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           io.function_name, io.filetype_name, io.wait_time/1000 wait_s, startup_time
      from dba_hist_iostat_detail io, dba_hist_snapshot snap
     where io.dbid = snap.dbid
       and io.instance_number = snap.instance_number
       and io.snap_id = snap.snap_id
       and snap.end_interval_time >= to_date(&begin_date,&date_mask)
       and snap.end_interval_time <= to_date(&end_date,&date_mask)),
  t1 as (
    select instance_number, snap_id, snap_time, function_name, filetype_name, wait_s,
           lag(wait_s,1) over (partition by instance_number, function_name, filetype_name order by snap_id) pre_wait_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, function_name, filetype_name order by snap_id),
           wait_s - (lag(wait_s,1) over (partition by instance_number, function_name, filetype_name order by snap_id)), wait_s) delta_s,
           startup_time
      from t0),
  t2 as (
    select instance_number, snap_id, snap_time, function_name, filetype_name, wait_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t1
     where pre_wait_s is not null),
  t3 AS (
    select instance_number, snap_time, function_name, filetype_name, delta_s from t2 where rank <= 25),
  t4 as (
    select instance_number, trunc(snap_time,'hh24') snap_time, function_name, filetype_name,
           min(delta_s) min_wait,
           avg(delta_s) avg_wait,
           percentile_disc(0.90) within group (order by delta_s) p90_wait,
           percentile_disc(0.95) within group (order by delta_s) p95_wait,
           percentile_disc(0.99) within group (order by delta_s) p99_wait,
           max(delta_s) max_wait
      from t3
     group by instance_number, trunc(snap_time,'hh24'), function_name, filetype_name
     order by instance_number, trunc(snap_time,'hh24'), 7 desc)
select * from (
select snap_time,instance_number,function_name,filetype_name,
       min_wait,
       avg_wait,
       p90_wait,
       p95_wait,
       p99_wait,
       max_wait
from t4
order by snap_time, instance_number, function_name, filetype_name);

spool off;

set termout on;
prompt *    io_wait.log
set termout off;
