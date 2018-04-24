spool latch.log

select 'LATCH_DATE;INSTANCE;LATCH;MIN_LATCH;AVG_LATCH;P90_LATCH;P95_LATCH;P99_LATCH;MAX_LATCH' extraction from dual;

with
  t1 as (
    select snap.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           lat.latch_name latch, nvl(lat.wait_time,0)/1000000 time_s, startup_time
      from dba_hist_snapshot snap,
           dba_hist_latch lat
     where lat.dbid = snap.dbid and lat.snap_id = snap.snap_id and lat.instance_number = snap.instance_number
       and snap.end_interval_time >= to_date(&begin_date, &date_mask)
       and snap.end_interval_time <= to_date(&end_date, &date_mask)
       and upper('S') = 'S'),
  t2 as (
    select instance_number,
           snap_id,
           snap_time,
           latch,
           time_s,
           lag(time_s,1) over (partition by instance_number, latch order by snap_id) pre_time_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, latch order by snap_id),
           time_s - (lag(time_s,1) over (partition by instance_number, latch order by snap_id)), time_s) delta_s,
           startup_time
      from t1),
  t3 as (
    select instance_number, snap_id, snap_time, latch, time_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t2
     where pre_time_s is not null),
  t4 as (
    select instance_number, snap_time, latch, delta_s from t3 where rank <= 25),
  t5 as (
    select instance_number, trunc(snap_time,'hh24') snap_time, latch,
           min(delta_s) min_latch,
           avg(delta_s) avg_latch,
           percentile_disc(0.90) within group (order by delta_s) p90_latch,
           percentile_disc(0.95) within group (order by delta_s) p95_latch,
           percentile_disc(0.99) within group (order by delta_s) p99_latch,
           max(delta_s) max_latch
      from t4
     group by instance_number, trunc(snap_time,'hh24'), latch
     order by instance_number, trunc(snap_time,'hh24'), 6 desc)
select * from (
select snap_time,instance_number,latch,
       min_latch,
       avg_latch,
       p90_latch,
       p95_latch,
       p99_latch,
       max_latch
from t5
where min_latch > 0.01 or avg_latch > 0.01 or p90_latch > 0.01 or p95_latch > 0.01 or p99_latch > 0.01 or max_latch > 0.01
order by snap_time, instance_number, latch);

spool off;

set termout on;
prompt *    latch.log
set termout off;
