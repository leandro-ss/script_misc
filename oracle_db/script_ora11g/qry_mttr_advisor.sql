spool mttr_advisor.log

select 'MTTR_DATE;INSTANCE;MTTR_TARGET;MIN_CACHE_PHYS;MAX_CACHE_PHYS;MIN_TOTAL_PHYS;MAX_TOTAL_PHYS' extraction from dual;
select * from (
select trunc(snap.end_interval_time,'hh24'),mttr.instance_number,
       mttr.mttr_target_for_estimate,
       min(mttr.estd_cache_write_factor),
       max(mttr.estd_cache_write_factor),
       min(mttr.estd_total_write_factor),
       max(mttr.estd_total_write_factor)
  from sys.dba_hist_mttr_target_advice mttr, sys.dba_hist_snapshot snap
 where mttr.dbid = snap.dbid and mttr.snap_id = snap.snap_id and mttr.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,'hh24'), mttr.instance_number, mttr.mttr_target_for_estimate
 order by trunc(snap.end_interval_time,'hh24'), mttr.instance_number, mttr.mttr_target_for_estimate);

spool off;

set termout on;
prompt *    mttr_advisor.log
set termout off;
