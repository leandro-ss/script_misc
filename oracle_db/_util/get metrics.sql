SELECT dm.instance_number||';'||METRIC_NAME||';'||to_char(TRUNC(begin_interval_time,'hh'), 'dd/mm/yyyy hh24:mi:ss')||';'||
trim(to_char(trunc(PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY (average + standard_deviation) ASC),2), '9999999999990.00')) as extract
FROM dba_hist_sysmetric_summary dm, dba_hist_snapshot ds
WHERE dm.snap_id = ds.snap_id
and dm.instance_number = ds.instance_number
AND TRUNC(Ds.BEGIN_INTERVAL_TIME) >= to_date('01/07/2013','dd/mm/yyyy')
AND metric_name in ('Logons Per Sec','User Commits Per Sec','Logical Reads Per Sec','Average Active Sessions',
'DB Block Gets Per Sec','Current Logons Count','User Calls Per Sec','Executions Per Sec',
'Physical Reads Per Sec','Open Cursors Per Sec','Consistent Read Gets Per Sec',
'User Transaction Per Sec','Physical Writes Per Sec','I/O Requests per Second')
group by dm.instance_number, METRIC_NAME, to_char(TRUNC(begin_interval_time,'hh'), 'dd/mm/yyyy hh24:mi:ss');