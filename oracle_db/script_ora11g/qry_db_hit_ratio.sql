spool db_hit_ratio.log

select 'DB_HIT_RATIO_DATE;INSTANCE;MIN_PERC;P01_PERC;P05_PERC;P10_PERC;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC' extraction from dual;

with
  t1 as
   (select a.snap_id, b.end_interval_time snap_time,
           a.instance_number, a.stat_name, a.value
      from dba_hist_sysstat a, dba_hist_snapshot b
     where a.dbid = b.dbid and a.instance_number = b.instance_number and a.snap_id = b.snap_id
            and b.end_interval_time >= to_date(&begin_date,&date_mask)
            and b.end_interval_time <= to_date(&end_date,&date_mask)
       and stat_name in ('db block gets','consistent gets','physical reads')),
  t2 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'db block gets'),
  t3 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'consistent gets'),
  t4 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'physical reads'),
  t5 as (select t2.snap_id, t2.snap_time, t2.instance_number, t2.value db_block_gets, t3.value consistent_gets, t4.value physical_reads
           from t2, t3, t4
          where t2.snap_id = t3.snap_id and t3.snap_id = t4.snap_id
            and t2.instance_number = t3.instance_number and t3.instance_number = t4.instance_number),
  t6 as (select snap_id, snap_time, instance_number, db_block_gets, consistent_gets, physical_reads,
                lag(db_block_gets,1,0) over (order by snap_id) db_block_gets_prev,
                lag(consistent_gets,1,0) over (order by snap_id) consistent_gets_prev,
                lag(physical_reads,1,0) over (order by snap_id) physical_reads_prev
         from t5),
  t7 as (select snap_id, snap_time, instance_number, db_block_gets, consistent_gets, physical_reads,
            case when (db_block_gets < db_block_gets_prev) then db_block_gets else db_block_gets - db_block_gets_prev end db_block_gets_delta,
            case when (consistent_gets < consistent_gets_prev) then consistent_gets else consistent_gets - consistent_gets_prev end consistent_gets_delta,
            case when (physical_reads < physical_reads_prev) then physical_reads else physical_reads - physical_reads_prev end physical_reads_delta
          from t6),
  t8 as (select snap_time, instance_number, round((1-(physical_reads_delta / (db_block_gets_delta + consistent_gets_delta)))*100,2) value
         from t7 order by snap_time, instance_number)
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
from t8
group by trunc(snap_time,'hh24'), instance_number
order by trunc(snap_time,'hh24'), instance_number);

spool off;

set termout on;
prompt *    db_hit_ratio.log
set termout off;
