select snap_time, instance_number, stat_name,
       case when stat_name = 'LOAD' then trim(to_char(value,'999999999990.00')) else trim(to_char(delta_value,'999999999990.00')) end value
  from (select to_char(snap.end_interval_time, 'dd/mm/yyyy hh24:mi:ss') snap_time, os.instance_number, os.stat_name,
               os.value - lag(os.value, 1) over (partition by os.instance_number, os.stat_name order by snap.end_interval_time) delta_value, os.value
          from sys.dba_hist_osstat os, sys.dba_hist_snapshot snap
         where os.dbid = snap.dbid and os.snap_id = snap.snap_id and os.instance_number = snap.instance_number
           and trunc(snap.end_interval_time) >= to_date('01092012', 'ddmmyyyy') and trunc(snap.end_interval_time) <= to_date('30112012', 'ddmmyyyy')
           and os.stat_id in (1, 2, 3, 4, 5, 6, 15))
 where delta_value > 0 or stat_name = 'LOAD';
