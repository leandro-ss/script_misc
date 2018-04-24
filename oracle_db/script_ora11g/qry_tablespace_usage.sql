spool tablespace_usage.log

select 'TBS_DATE;TABLESPACE;MIN_PERC;P01_PERC;P05_PERC;P10_VAP;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC;MAX_SIZE' extraction from dual;

with
  t0 as (
    select snap.snap_id, snap.end_interval_time snap_time,
           tab.tsname, trunc(((tsu.tablespace_usedsize * dba_tab.block_size) / (tsu.tablespace_size * dba_tab.block_size))*100, 2) perc,
           trunc((tsu.tablespace_size * dba_tab.block_size)/1024/1024/1024) total_gb
      from dba_hist_tbspc_space_usage tsu, dba_hist_tablespace tab, dba_hist_snapshot snap, dba_tablespaces dba_tab
      where tsu.dbid = snap.dbid and tsu.snap_id = snap.snap_id
        and tab.dbid = snap.dbid
        and tsu.tablespace_id = tab.ts#
        and tab.tsname = dba_tab.tablespace_name
        and snap.end_interval_time >= to_date(&begin_date, &date_mask)
        and snap.end_interval_time <= to_date(&end_date, &date_mask))
select * from (
select trunc(snap_time,'hh24'),tsname,
       min(perc),
       percentile_disc(0.01) within group (order by perc),
       percentile_disc(0.05) within group (order by perc),
       percentile_disc(0.1) within group (order by perc),
       avg(perc),
       percentile_disc(0.9) within group (order by perc),
       percentile_disc(0.95) within group (order by perc),
       percentile_disc(0.99) within group (order by perc),
       max(perc),
       max(total_gb)
  from t0
group by trunc(snap_time,'hh24'), tsname
order by trunc(snap_time,'hh24'), tsname);

spool off;

set termout on;
prompt *    tablespace_usage.log
set termout off;
