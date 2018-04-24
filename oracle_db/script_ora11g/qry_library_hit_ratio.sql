spool library_hit_ratio.log

select 'LIBRARY_HIT_RATIO_DATE;INSTANCE;MIN_PERC;P01_PERC;P05_PERC;P10_PERC;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC' extraction from dual;

WITH
  t1 AS (
    SELECT b.instance_number, a.snap_id, b.end_interval_time snap_time,
           SUM(a.pins) pins,
           SUM(reloads) reloads
      FROM dba_hist_librarycache a, dba_hist_snapshot b
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       and b.end_interval_time >= to_date(&begin_date,&date_mask)
       and b.end_interval_time <= to_date(&end_date,&date_mask)
     GROUP BY b.instance_number, a.snap_id, b.end_interval_time),
  t2 AS (
    SELECT instance_number, snap_id, snap_time, pins, reloads,
           pins - LAG(pins,1,0) OVER (PARTITION BY instance_number ORDER BY snap_id) pins_prev,
           reloads - LAG(reloads,1,0) OVER (PARTITION BY instance_number ORDER BY snap_id) reloads_prev
      FROM t1),
  t3 AS (
    SELECT instance_number, snap_id, snap_time, pins, reloads,
           CASE WHEN pins < pins_prev THEN pins ELSE pins - pins_prev END pins_delta,
           CASE WHEN reloads < reloads_prev THEN reloads ELSE reloads - reloads_prev END reloads_delta
      FROM t2),
  t4 as (select snap_time, instance_number, round((pins_delta / (pins + reloads)) * 100,2) value
         from t3 where pins_delta > 0 order by snap_time, instance_number)
select * from (
select trunc(snap_time,'hh24'),instance_number,
       min(value),
       percentile_disc(0.01) within group (order by value),
       percentile_disc(0.05) within group (order by value),
       percentile_disc(0.1) within group (order by value),
       avg(value),
       percentile_disc(0.9) within group (order by value),
       percentile_disc(0.95) within group (order by value),
       percentile_disc(0.99) within group (order by value),
       max(value)
from t4
group by trunc(snap_time,'hh24'), instance_number
order by trunc(snap_time,'hh24'), instance_number);

spool off;

set termout on;
prompt *    library_hit_ratio.log
set termout off;
