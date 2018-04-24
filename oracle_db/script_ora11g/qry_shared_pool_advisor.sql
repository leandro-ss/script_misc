spool shared_pool_advisor.log

select 'SHARED_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_OBJ_HITS;MAX_OBJ_HITS' extraction from dual;
select * from (
select trunc(snap.end_interval_time,'hh24'),shared.instance_number,
       max(shared.shared_pool_size_for_estimate),
       shared.shared_pool_size_factor,
       min(shared.estd_lc_memory_object_hits),
       max(shared.estd_lc_memory_object_hits)
  from sys.dba_hist_shared_pool_advice shared, sys.dba_hist_snapshot snap
 where shared.dbid = snap.dbid and shared.snap_id = snap.snap_id and shared.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,'hh24'), shared.instance_number, shared.shared_pool_size_factor
 order by trunc(snap.end_interval_time,'hh24'), shared.instance_number, shared.shared_pool_size_factor);

spool off;

set termout on;
prompt *    shared_pool_advisor.log
set termout off;
