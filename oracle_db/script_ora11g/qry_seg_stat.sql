spool seg_stat.log

select 'SEG_DATE;INSTANCE;OWNER;OBJECT;SUBOBJECT;LOGICAL_READS;BUFFER_BUSY;BLOCK_CHANGES;PHYS_READ;PHYS_WRITE' extraction from dual;

with
  t0 as (
    select snap.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           obj.owner, obj.object_name, obj.subobject_name,
           seg.logical_reads_delta,
           seg.buffer_busy_waits_delta,
           seg.db_block_changes_delta,
           seg.physical_reads_delta,
           seg.physical_writes_delta
      from dba_hist_seg_stat seg, dba_hist_snapshot snap, dba_objects obj
      where seg.dbid = snap.dbid and seg.snap_id = snap.snap_id
        and seg.instance_number = snap.instance_number
        and snap.end_interval_time >= to_date(&begin_date, &date_mask)
        and snap.end_interval_time <= to_date(&end_date, &date_mask)
        and seg.obj# = obj.object_id),
  t1 as (
    select instance_number, snap_id, snap_time, owner, object_name, subobject_name,
           logical_reads_delta, buffer_busy_waits_delta, db_block_changes_delta, physical_reads_delta, physical_writes_delta,
           rank() over (partition by instance_number, snap_id order by logical_reads_delta desc) lr_rank,
           rank() over (partition by instance_number, snap_id order by buffer_busy_waits_delta desc) bb_rank,
           rank() over (partition by instance_number, snap_id order by db_block_changes_delta desc) bc_rank,
           rank() over (partition by instance_number, snap_id order by physical_reads_delta desc) pr_rank,
           rank() over (partition by instance_number, snap_id order by physical_writes_delta desc) pw_rank
      from t0),
  t2 as (
    select instance_number, snap_id, snap_time, owner, object_name, subobject_name,
           logical_reads_delta, buffer_busy_waits_delta, db_block_changes_delta, physical_reads_delta, physical_writes_delta
      from t1 where lr_rank <= 25 or bb_rank <= 25 or bc_rank <= 25 or pr_rank <= 25 or pw_rank <= 25)
select * from (
select trunc(snap_time,'hh24'),instance_number,owner,object_name,subobject_name,
       avg(logical_reads_delta),
       avg(buffer_busy_waits_delta),
       avg(db_block_changes_delta),
       avg(physical_reads_delta),
       avg(physical_writes_delta)
  from t2
group by trunc(snap_time,'hh24'), instance_number, owner, object_name, subobject_name
order by trunc(snap_time,'hh24'), instance_number, owner, object_name, subobject_name);

spool off;

set termout on;
prompt *    seg_stat.log
set termout off;
