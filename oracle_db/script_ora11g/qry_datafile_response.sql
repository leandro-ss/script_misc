spool datafile_response.log

select 'DATAFILE_DATE;INSTANCE;TYPE;FILENAME;MIN_MS;AVG_MS;P90_MS;P95_MS;P99_MS;MAX_MS;THRESHOLD' extraction from dual;

with
  t0 as (
    select s.instance_number, s.snap_id, s.end_interval_time snap_time, t.contents, f.filename, startup_time,
           decode(startup_time,lag(startup_time,1) over (partition by s.instance_number, f.filename order by s.end_interval_time),
           f.readtim - lag(f.readtim,1) over (partition by s.instance_number, f.filename order by s.end_interval_time), f.readtim) delta_readtim,
           decode(startup_time,lag(startup_time,1) over (partition by s.instance_number, f.filename order by s.end_interval_time),
           f.phyrds - lag(f.phyrds,1) over (partition by s.instance_number, f.filename order by s.end_interval_time), f.phyrds) delta_phyrds
      from dba_hist_filestatxs f, dba_hist_snapshot s, dba_hist_tablespace t
     where f.snap_id = s.snap_id
       and f.instance_number = s.instance_number
       and f.dbid = s.dbid
       and f.dbid = t.dbid
       and f.ts# = t.ts#
       and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)),
  t1 as (
    select instance_number, snap_id, snap_time, contents, filename,
           delta_readtim / delta_phyrds * 10 avg_read_time_ms
      from t0
     where delta_phyrds > 0),
  t2 as (
  select instance_number, snap_id, snap_time, contents, filename, avg_read_time_ms,
         rank() over (partition by instance_number, snap_id, contents order by avg_read_time_ms desc) rank
    from t1),
  t3 as (
    select instance_number, snap_time, contents, filename, avg_read_time_ms from t2 where rank <= 25)
select * from (
select trunc(snap_time,'hh24'),instance_number,contents,filename,
       min(avg_read_time_ms),
       avg(avg_read_time_ms),
       percentile_disc(0.90) within group (order by avg_read_time_ms),
       percentile_disc(0.95) within group (order by avg_read_time_ms),
       percentile_disc(0.99) within group (order by avg_read_time_ms),
       max(avg_read_time_ms),
       20
from t3
     group by trunc(snap_time,'hh24'), instance_number, contents, filename
     order by trunc(snap_time,'hh24'), instance_number, contents, filename);

spool off;

set termout on;
prompt *    datafile_response.log
set termout off;
