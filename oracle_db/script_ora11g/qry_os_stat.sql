spool os_stat.log

select 'OS_DATE;INSTANCE;STAT_NAME;MIN_VAL;P01_VAL;P05_VAL;P10_VAL;AVG_VAL;P90_VAL;P95_VAL;P99_CAL;MAX_VAL' extraction from dual;
select * from (
select trunc(snap_time,'hh24'),instance_number,stat_name,
       min(value),
       percentile_disc(0.01) within group (order by value),
       percentile_disc(0.05) within group (order by value),
       percentile_disc(0.1) within group (order by value),
       avg(value),
       percentile_disc(0.9) within group (order by value),
       percentile_disc(0.95) within group (order by value),
       percentile_disc(0.99) within group (order by value),
       max(value)
from (select snap_time, instance_number, stat_name,
             case when stat_id in (0, 15, 16, 17) then value else delta_value end value
        from (select snap.end_interval_time snap_time, os.instance_number, os.stat_id, os.stat_name,
                     os.value - lag(os.value, 1) over (partition by os.instance_number, os.stat_name order by snap.end_interval_time) delta_value, os.value
                from sys.dba_hist_osstat os, sys.dba_hist_snapshot snap
               where os.dbid = snap.dbid and os.snap_id = snap.snap_id
                 and os.instance_number = snap.instance_number
                 and snap.end_interval_time >= to_date(&begin_date, &date_mask)
                 and snap.end_interval_time <= to_date(&end_date, &date_mask)
                 and os.stat_id in (0, 1, 2, 3, 4, 5, 6, 15, 16, 17)))
where value is not null
group by trunc(snap_time,'hh24'), instance_number, stat_name
order by trunc(snap_time,'hh24'), instance_number, stat_name);

spool off;

set termout on;
prompt *    os_stat.log
set termout off;
