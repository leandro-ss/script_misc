spool java_pool_advisor.log

select 'JAVA_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_OBJ_HITS;MAX_OBJ_HITS' extraction from dual;
select * from (
select trunc(snap.end_interval_time,'hh24'),java.instance_number,
       max(java.java_pool_size_for_estimate),
       java.java_pool_size_factor,
       min(java.estd_lc_memory_object_hits),
       max(java.estd_lc_memory_object_hits)
  from sys.dba_hist_java_pool_advice java, sys.dba_hist_snapshot snap
 where java.dbid = snap.dbid and java.snap_id = snap.snap_id and java.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,'hh24'), java.instance_number, java.java_pool_size_factor
 order by trunc(snap.end_interval_time,'hh24'), java.instance_number, java.java_pool_size_factor);

spool off;

set termout on;
prompt *    java_pool_advisor.log
set termout off;
