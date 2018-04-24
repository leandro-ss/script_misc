spool resource.log

select 'RES_DATE;INSTANCE;RESOURCE;MIN_VAL;P01_VAL;P05_VAL;P10_VAP;AVG_VAL;P90_VAL;P95_VAL;P99_VAL;MAX_VAL;MAX_MAX;MIN_LIMIT;MAX_LIMIT' extraction from dual;

with
  t0 as (
    select snap.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           res.resource_name, res.current_utilization curr, res.max_utilization, res.limit_value
      from dba_hist_resource_limit res, dba_hist_snapshot snap
      where res.dbid = snap.dbid and res.snap_id = snap.snap_id
        and res.instance_number = snap.instance_number
        and snap.end_interval_time >= to_date(&begin_date, &date_mask)
        and snap.end_interval_time <= to_date(&end_date, &date_mask))
select * from (
select trunc(snap_time,'hh24'),instance_number,resource_name,
       min(curr),
       percentile_disc(0.01) within group (order by curr),
       percentile_disc(0.05) within group (order by curr),
       percentile_disc(0.1) within group (order by curr),
       avg(curr),
       percentile_disc(0.9) within group (order by curr),
       percentile_disc(0.95) within group (order by curr),
       percentile_disc(0.99) within group (order by curr),
       max(curr),
       max(max_utilization),
       min(limit_value),
       max(limit_value)
  from t0
group by trunc(snap_time,'hh24'), instance_number, resource_name
order by trunc(snap_time,'hh24'), instance_number, resource_name);

spool off;

set termout on;
prompt *    resource.log
set termout off;
