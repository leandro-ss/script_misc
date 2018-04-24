spool memory_target_advisor.log

select 'MEMORY_TARGET_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_DB_TIME;MAX_DB_TIME' extraction from dual;
select * from (
select trunc(snap.end_interval_time,'hh24'),mem.instance_number,
       trunc(max(mem.memory_size)),
       mem.memory_size_factor,
       min(mem.estd_db_time),
       max(mem.estd_db_time)
  from sys.dba_hist_memory_target_advice mem, sys.dba_hist_snapshot snap
 where mem.dbid = snap.dbid and mem.snap_id = snap.snap_id and mem.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,'hh24'), mem.instance_number, mem.memory_size_factor
 order by trunc(snap.end_interval_time,'hh24'), mem.instance_number, mem.memory_size_factor);

spool off;

set termout on;
prompt *    memory_target_advisor.log
set termout off;
