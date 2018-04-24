spool enqueue.log

select 'ENQUEUE_DATE;INSTANCE;ENQUEUE;MIN_ENQ;AVG_ENQ;P90_ENQ;P95_ENQ;P99_ENQ;MAX_ENQ' extraction from dual;

with
  t0 as (
    select s.instance_number, s.snap_id, s.end_interval_time snap_time,
           e.eq_type || ': ' || e.req_reason enqueue, nvl(e.cum_wait_time,0)/1000 time_s,
           startup_time
      from dba_hist_snapshot s,
           dba_hist_enqueue_stat e
     where e.snap_id = s.snap_id
       and e.instance_number = s.instance_number
       and e.dbid = s.dbid
       and s.end_interval_time >= to_date(&begin_date,&date_mask)
       and s.end_interval_time <= to_date(&end_date,&date_mask)),
  t1 as (
    select instance_number, snap_id, snap_time, enqueue, time_s,
           lag(time_s,1) over (partition by instance_number, enqueue order by snap_id) pre_time_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, enqueue order by snap_id),
           time_s - (lag(time_s,1) over (partition by instance_number, enqueue order by snap_id)), time_s) delta_s,
           startup_time
      from t0),
  t2 as (
    select instance_number, snap_id, snap_time, enqueue, time_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t1 where pre_time_s is not null),
  t3 AS (
    select instance_number, snap_time, enqueue, delta_s from t2 where rank <= 25),
  t4 as (
    select instance_number, trunc(snap_time,'hh24') snap_time, enqueue,
           min(delta_s) min_enq,
           avg(delta_s) avg_enq,
           percentile_disc(0.90) within group (order by delta_s) p90_enq,
           percentile_disc(0.95) within group (order by delta_s) p95_enq,
           percentile_disc(0.99) within group (order by delta_s) p99_enq,
           max(delta_s) max_enq
      from t3
     group by instance_number, trunc(snap_time,'hh24'), enqueue
     order by instance_number, trunc(snap_time,'hh24'), 6 desc)
select * from (
select snap_time,instance_number,enqueue,
       min_enq,
       avg_enq,
       p90_enq,
       p95_enq,
       p99_enq,
       max_enq
from t4
order by snap_time, instance_number, enqueue);

spool off;

set termout on;
prompt *    enqueue.log
set termout off;
