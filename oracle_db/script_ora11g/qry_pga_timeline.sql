spool pga_timeline.log

select 'PGA_DATE;INSTANCE;MIN_SIZE;AVG_SIZE;P90_SIZE;P95_SIZE;P99_SIZE;MAX_SIZE' extraction from dual;
select * from (
select trunc(snap.end_interval_time,'hh24'),snap.instance_number,
       min(pgas.value)/1024/1024,
       avg(pgas.value)/1024/1024,
       percentile_disc(0.9) within group (order by pgas.value/1024/1024),
       percentile_disc(0.95) within group (order by pgas.value/1024/1024),
       percentile_disc(0.99) within group (order by pgas.value/1024/1024),
       max(pgas.value)/1024/1024
  from dba_hist_pgastat pgas, dba_hist_snapshot snap
 where snap.instance_number = pgas.instance_number
   and snap.dbid = pgas.dbid
   and snap.end_interval_time >= to_date(&begin_date, &date_mask)
   and snap.end_interval_time <= to_date(&end_date, &date_mask)
   and pgas.snap_id = snap.snap_id
   and pgas.name = 'total PGA allocated'
 group by trunc(snap.end_interval_time,'hh24'), snap.instance_number
 order by trunc(snap.end_interval_time,'hh24'), snap.instance_number);

spool off;

set termout on;
prompt *    pga_timeline.log
set termout off;

