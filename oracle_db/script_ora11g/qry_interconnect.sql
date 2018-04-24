spool interconnect.log

select 'INTERCONNECT_DATE;SOURCE;TARGET;MIN_500B;AVG_500B;P90_500B;P95_500B;P99_500B;MAX_500B;MIN_8K;AVG_8K;P90_8K;P95_8K;P99_8K;MAX_8K' extraction from dual;

WITH
  t1 AS (
select snap.snap_id, snap.end_interval_time snap_time,
       ic.instance_number, ic.target_instance,
       ic.cnt_500b, ic.wait_500b, ic.cnt_8k, ic.wait_8k
        from sys.dba_hist_interconnect_pings ic, sys.dba_hist_snapshot snap
       where ic.dbid = snap.dbid and ic.snap_id = snap.snap_id
         and ic.instance_number = snap.instance_number
         and snap.end_interval_time >= to_date(&begin_date,&date_mask)
         and snap.end_interval_time <= to_date(&end_date,&date_mask)
         and ic.instance_number <> ic.target_instance),
  t2 AS (
    SELECT snap_id, snap_time, instance_number, target_instance, cnt_500b, wait_500b, cnt_8k, wait_8k,
           cnt_500b - LAG(cnt_500b,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) cnt_500b_prev,
           wait_500b - LAG(wait_500b,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) wait_500b_prev,
           cnt_8k - LAG(cnt_8k,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) cnt_8k_prev,
           wait_8k - LAG(wait_8k,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) wait_8k_prev
      FROM t1),
  t3 AS (
    SELECT instance_number, target_instance, snap_id, snap_time,
           CASE WHEN cnt_500b < cnt_500b_prev THEN cnt_500b ELSE cnt_500b - cnt_500b_prev END cnt_500b_delta,
           CASE WHEN wait_500b < wait_500b_prev THEN wait_500b ELSE wait_500b - wait_500b_prev END wait_500b_delta,
           CASE WHEN cnt_8k < cnt_8k_prev THEN cnt_8k ELSE cnt_8k - cnt_8k_prev END cnt_8k_delta,
           CASE WHEN wait_8k < wait_8k_prev THEN wait_8k ELSE wait_8k - wait_8k_prev END wait_8k_delta
      FROM t2),
  t4 as (select snap_time, instance_number, target_instance,
                round((wait_500b_delta / cnt_500b_delta) * 100,2) ic_500b,
                round((wait_8k_delta / cnt_8k_delta) * 100,2) ic_8k
         from t3 where cnt_500b_delta > 0 or cnt_8k_delta > 0
        order by snap_time, instance_number, target_instance)
select * from (
select trunc(snap_time,'hh24'),instance_number,target_instance,
       min(ic_500b),
       avg(ic_500b),
       percentile_disc(0.9) within group (order by ic_500b),
       percentile_disc(0.95) within group (order by ic_500b),
       percentile_disc(0.99) within group (order by ic_500b),
       max(ic_500b),
       min(ic_8k),
       avg(ic_8k),
       percentile_disc(0.9) within group (order by ic_8k),
       percentile_disc(0.95) within group (order by ic_8k),
       percentile_disc(0.99) within group (order by ic_8k),
       max(ic_8k)
from t4
group by trunc(snap_time,'hh24'), instance_number, target_instance
order by trunc(snap_time,'hh24'), instance_number, target_instance);

spool off

set termout on;
prompt *    interconnect.log
set termout off;
