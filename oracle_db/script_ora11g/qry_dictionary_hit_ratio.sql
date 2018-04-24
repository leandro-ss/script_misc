spool dictionary_hit_ratio.log

select 'DICTIONARY_HIT_RATIO_DATE;INSTANCE;MIN_PERC;P01_PERC;P05_PERC;P10_PERC;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC' extraction from dual;

WITH
  t1 AS (
    SELECT b.instance_number, a.snap_id, b.end_interval_time snap_time,
           SUM(a.gets) gets,
           SUM(getmisses) getmisses
      FROM dba_hist_rowcache_summary a, dba_hist_snapshot b
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       and b.end_interval_time >= to_date(&begin_date,&date_mask)
       and b.end_interval_time <= to_date(&end_date,&date_mask)
     GROUP BY b.instance_number, a.snap_id, b.end_interval_time),
  t2 AS (
    SELECT instance_number, snap_id, snap_time, gets, getmisses,
           gets - LAG(gets,1,0) OVER (ORDER BY snap_id) gets_prev,
           getmisses - LAG(getmisses,1,0) OVER (ORDER BY snap_id) getmisses_prev
      FROM t1),
  t3 AS (
    SELECT instance_number, snap_id, snap_time, gets, getmisses,
           CASE WHEN gets < gets_prev THEN gets ELSE gets - gets_prev END gets_delta,
           CASE WHEN getmisses < getmisses_prev THEN getmisses ELSE getmisses - getmisses_prev END getmisses_delta
      FROM t2),
  t4 AS (
    SELECT snap_time, instance_number, round((gets_delta / (gets + getmisses)) * 100,2) value
      FROM t3 where gets_delta > 0 ORDER BY snap_time, instance_number)
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
prompt *    dictionary_hit_ratio.log
set termout off;
