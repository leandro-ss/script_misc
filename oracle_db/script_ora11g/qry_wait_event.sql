spool wait_event.log

select 'WAIT_DATE;INSTANCE;EVENT;WAIT_CLASS;MIN_WAIT;AVG_WAIT;P90_WAIT;P95_WAIT;P99_WAIT;MAX_WAIT' extraction from dual;

with
  t1 as (
    select s.instance_number, s.snap_id, s.end_interval_time snap_time,
           e.event_name event, e.wait_class, nvl(e.time_waited_micro,0)/1000000 time, e.total_waits,
           startup_time
      from dba_hist_snapshot s,
           dba_hist_system_event e
     where s.snap_id = e.snap_id
       and s.instance_number = e.instance_number
       and s.dbid = e.dbid
       and e.wait_class not in ('Idle')
       and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)
     union all
    select s.instance_number, s.snap_id, s.end_interval_time snap_time,
           'CPU' event, 'CPU' wait_class, nvl(c.value,0)/1000000 time, 0 total_waits, startup_time
      from dba_hist_snapshot s,
           dba_hist_sys_time_model c
     where s.snap_id = c.snap_id
       and s.instance_number = c.instance_number
       and s.dbid = c.dbid
       and c.stat_name = 'DB CPU'
       and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)),
  t2 as (
    select instance_number, snap_id, snap_time, event, wait_class, time time_s,
           lag(time,1) over (partition by instance_number, event, wait_class order by snap_id) pre_time_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, event, wait_class order by snap_id),
           time - (lag(time,1) over (partition by instance_number, event, wait_class order by snap_id)), time) delta_s,
           startup_time
      from t1),
  t3 as (
    select instance_number, snap_id, snap_time, event, wait_class, time_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t2
      where pre_time_s is not null)
select * from (
select trunc(snap_time,'hh24'),instance_number,event,wait_class,
       min(delta_s),
       avg(delta_s),
       percentile_disc(0.90) within group (order by delta_s),
       percentile_disc(0.95) within group (order by delta_s),
       percentile_disc(0.99) within group (order by delta_s),
       max(delta_s)
from t3
where rank <= 25
group by trunc(snap_time,'hh24'), instance_number, event, wait_class
order by trunc(snap_time,'hh24'), instance_number, event, wait_class);

spool off;

set termout on;
prompt *    wait_event.log
set termout off;
