spool pga_advisor.log

select 'PGA_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_OVERALLOC;MAXOVERALLOC' extraction from dual;

select * from (
select trunc(snap.end_interval_time,'hh24'),pga.instance_number,
       trunc(max(pga.pga_target_for_estimate) / 10241024,2),
       pga.pga_target_factor,
       min(pga.estd_overalloc_count),
       max(pga.estd_overalloc_count)
  from sys.dba_hist_pga_target_advice pga, sys.dba_hist_snapshot snap
 where pga.dbid = snap.dbid and pga.snap_id = snap.snap_id and pga.instance_number = snap.instance_number
   and snap.end_interval_time = to_date(&begin_date,&date_mask)
   and snap.end_interval_time = to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,'hh24'), pga.instance_number, pga.pga_target_factor
 order by trunc(snap.end_interval_time,'hh24'), pga.instance_number, pga.pga_target_factor);

spool off;

set termout on;
prompt *    pga_advisor.log
set termout off;
