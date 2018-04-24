spool memory_resize.log

select 'RESIZE_DATE;INSTANCE;MEMORY_AREA;OPER_TYPE;INITIAL;TARGET;FINAL' extraction from dual;
select * from (
select ops.end_time,ops.instance_number,ops.parameter,ops.oper_type,
       trunc(ops.initial_size/1024/1024),
       trunc(ops.target_size/1024/1024),
       trunc(ops.final_size/1024/1024)
  from dba_hist_memory_resize_ops ops, dba_hist_snapshot snap
 where ops.snap_id = snap.snap_id
   and ops.dbid = snap.dbid
   and ops.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
   and ops.end_time between snap.begin_interval_time and snap.end_interval_time
   and status = 'COMPLETE'
   order by ops.end_time, ops.instance_number);

spool off;

set termout on;
prompt *    memory_resize.log
set termout off;
