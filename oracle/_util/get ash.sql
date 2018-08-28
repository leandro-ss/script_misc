select to_char(sample_time,'dd/mm/yyyy hh24')||':00:00' sample_time, instance_number, max(sessions) sessions
  from (select to_date(to_char(ash.sample_time,'dd/mm/yyyy hh24:mi')||':00','dd/mm/yyyy hh24:mi:ss') sample_time, ash.instance_number, count(*) sessions
          from dba_hist_active_sess_history ash, sys.dba_hist_snapshot snap
         where ash.dbid = snap.dbid and ash.snap_id = snap.snap_id and ash.instance_number = snap.instance_number
           and trunc(snap.end_interval_time) >= to_date('01092012', 'ddmmyyyy') and trunc(snap.end_interval_time) <= to_date('30112012', 'ddmmyyyy')
         group by to_char(ash.sample_time,'dd/mm/yyyy hh24:mi'), ash.instance_number)
 group by to_char(sample_time,'dd/mm/yyyy hh24')||':00:00', instance_number;
