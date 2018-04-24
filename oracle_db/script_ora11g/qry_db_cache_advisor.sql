spool db_cache_advisor.log

select 'DB_CACHE_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_PHYS_READ;MAX_PHYS_READ' extraction from dual;
select * from (
select trunc(snap.end_interval_time,'hh24'),db.instance_number,
       trunc(max(db.size_for_estimate)),
       db.size_factor,
       min(db.physical_reads),
       max(db.physical_reads)
  from sys.dba_hist_db_cache_advice db, sys.dba_hist_snapshot snap
 where db.dbid = snap.dbid and db.snap_id = snap.snap_id and db.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,'hh24'), db.instance_number, db.size_factor
 order by trunc(snap.end_interval_time,'hh24'), db.instance_number, db.size_factor);

spool off;

set termout on;
prompt *    db_cache_advisor.log
set termout off;
