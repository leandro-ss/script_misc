spool sga_advisor.log

select 'SGA_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_PHYS_READ;MAX_PHYS_READ' extraction from dual;
select * from (
select trunc(snap.end_interval_time,'hh24'),sga.instance_number,
       trunc(max(sga.sga_size),2),
       sga.sga_size_factor,
       min(sga.estd_physical_reads),
       max(sga.estd_physical_reads)
  from sys.dba_hist_sga_target_advice sga, sys.dba_hist_snapshot snap
 where sga.dbid = snap.dbid and sga.snap_id = snap.snap_id and sga.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,'hh24'), sga.instance_number, sga.sga_size_factor
 order by trunc(snap.end_interval_time,'hh24'), sga.instance_number, sga.sga_size_factor);

spool off;

set termout on;
prompt *    sga_advisor.log
set termout off;
