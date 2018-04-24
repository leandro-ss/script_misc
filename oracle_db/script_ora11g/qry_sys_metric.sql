pool sys_metric.log

select 'METRIC_DATE;INSTANCE;METRIC_NAME;MIN_VAL;P01_VAL;P05_VAL;P10_VAL;AVG_VAL;P90_VAL;P95_VAL;P99_CAL;MAX_VAL;MIN_STDDEV;AVG_STDDEV;MAX_STDDEV' extraction from dual;
select * from (
select trunc(snap_time,'hh24'),instance_number,metric_name,
       min(value),
       percentile_disc(0.01) within group (order by value),
       percentile_disc(0.05) within group (order by value),
       percentile_disc(0.1) within group (order by value),
       avg(value),
       percentile_disc(0.9) within group (order by value),
       percentile_disc(0.95) within group (order by value),
       percentile_disc(0.99) within group (order by value),
       max(value),
       min(std),
       avg(std),
       max(std)
from (select snap.end_interval_time snap_time, metric.instance_number, metric.metric_id, metric.metric_name,
             metric.average value, metric.standard_deviation std
        from sys.dba_hist_sysmetric_summary metric, sys.dba_hist_snapshot snap
       where metric.dbid = snap.dbid and metric.snap_id = snap.snap_id
         and metric.instance_number = snap.instance_number
         and snap.end_interval_time >= to_date(&begin_date, &date_mask)
         and snap.end_interval_time <= to_date(&end_date, &date_mask)
         and metric_name in ('Active Parallel Sessions','Active Serial Sessions','Average Active Sessions',
                             'Background Checkpoints Per Sec','Buffer Cache Hit Ratio',
                             'Consistent Read Changes Per Sec','Consistent Read Gets Per Sec','Current Logons Count',
                             'Current Open Cursors Count','Current OS Load','Cursor Cache Hit Ratio',
                             'Database Time Per Sec','Database Wait Time Ratio','DB Block Gets Per Sec',
                             'DBWR Checkpoints Per Sec','DDL statements parallelized Per Sec','DML statements parallelized Per Sec',
                             'Executions Per Sec','I/O Megabytes per Second','I/O Requests per Second',
                             'Library Cache Hit Ratio','Library Cache Miss Ratio','Logical Reads Per Sec',
                             'Open Cursors Per Sec','Parse Failure Count Per Sec','PGA Cache Hit %',
                             'Physical Reads Per Sec','Physical Writes Per Sec','Process Limit %',
                             'Queries parallelized Per Sec','Recursive Calls Per Sec','Session Count','Session Limit %',
                             'Shared Pool Free %','Temp Space Used','Total Parse Count Per Sec',
                             'Total PGA Allocated','Total PGA Used by SQL Workareas','Total Table Scans Per Sec',
                             'User Commits Per Sec','User Rollbacks Per Sec','User Transaction Per Sec'))
group by trunc(snap_time,'hh24'), instance_number, metric_name
order by trunc(snap_time,'hh24'), instance_number, metric_name);

spool off;

set termout on;
prompt *    sys_metric.log
set termout off;
