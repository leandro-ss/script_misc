spool sga_timeline.log

select 'SGA_DATE;INSTANCE;POOL;MIN_SIZE;AVG_SIZE;P90_SIZE;P95_SIZE;P99_SIZE;MAX_SIZE' extraction from dual;
select * from (
select trunc(end_interval_time,'hh24'),instance_number,pool,
       min(bytes)/1024/1024,
       avg(bytes)/1024/1024,
       percentile_disc(0.90) within group (order by bytes/1024/1024),
       percentile_disc(0.95) within group (order by bytes/1024/1024),
       percentile_disc(0.99) within group (order by bytes/1024/1024),
       max(bytes)/1024/1024
  from (
select snap.end_interval_time, snap.instance_number,
       case when sgas.name = 'free memory'
       then nvl2(sgas.pool,sgas.pool, sgas.name) || ' (free)'
       else nvl2(sgas.pool,sgas.pool, sgas.name) end pool,
       sum(sgas.bytes) bytes
  from dba_hist_sgastat sgas, dba_hist_snapshot snap
 where sgas.snap_id = snap.snap_id
   and sgas.instance_number = snap.instance_number
   and sgas.dbid = snap.dbid
   and snap.end_interval_time >= to_date(&begin_date, &date_mask)
   and snap.end_interval_time <= to_date(&end_date, &date_mask)
 group by snap.end_interval_time,
       snap.instance_number,
       case when sgas.name = 'free memory'
       then nvl2(sgas.pool,sgas.pool, sgas.name) || ' (free)'
       else nvl2(sgas.pool,sgas.pool, sgas.name) end)
 group by trunc(end_interval_time,'hh24'),instance_number,pool
 order by trunc(end_interval_time,'hh24'),instance_number,pool);

spool off;

set termout on;
prompt *    sga_timeline.log
set termout off;
