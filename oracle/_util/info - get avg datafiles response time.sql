
-- get avg response time by tablespace

select to_char(snap_date, 'dd/mm/yyyy') snap_date, instance_number, tsname, avg_read_time_ms, max_read_time_ms, p90_read_time_ms from (
select trunc(snap_date) snap_date, instance_number, tsname,
       trunc(avg(avg_read_time_ms), 2) avg_read_time_ms, max(avg_read_time_ms) max_read_time_ms, PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY avg_read_time_ms ASC) p90_read_time_ms
  from (select snap_date, instance_number, tsname, trunc((readtim - readtim_lag) / (phyrds - phyrds_lag) * 10, 2) avg_read_time_ms
          from (select s.end_interval_time snap_date, s.instance_number, f.tsname,
                       f.readtim, lag(f.readtim,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) readtim_lag,
                       f.phyrds, lag(f.phyrds,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) phyrds_lag
                  from dba_hist_filestatxs f, dba_hist_snapshot s
                 where f.snap_id = s.snap_id
                   and f.instance_number = s.instance_number
                   and trunc(s.end_interval_time) between to_date('01/06/2013', 'dd/mm/yyyy') and to_date('30/06/2013', 'dd/mm/yyyy'))
         where readtim_lag is not null and phyrds_lag is not null and (phyrds - phyrds_lag) > 0)
 group by trunc(snap_date), instance_number, tsname)
 order by avg_read_time_ms;

-- get avg response time by datafile

select to_char(snap_date, 'dd/mm/yyyy') snap_date, instance_number, filename, avg_read_time_ms, max_read_time_ms, p90_read_time_ms from (
select trunc(snap_date) snap_date, instance_number, filename,
       trunc(avg(avg_read_time_ms), 2) avg_read_time_ms, max(avg_read_time_ms) max_read_time_ms, PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY avg_read_time_ms ASC) p90_read_time_ms
  from (select snap_date, instance_number, filename, trunc((readtim - readtim_lag) / (phyrds - phyrds_lag) * 10, 2) avg_read_time_ms
          from (select s.end_interval_time snap_date, s.instance_number, f.filename,
                       f.readtim, lag(f.readtim,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) readtim_lag,
                       f.phyrds, lag(f.phyrds,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) phyrds_lag
                  from dba_hist_filestatxs f, dba_hist_snapshot s
                 where f.snap_id = s.snap_id
                   and f.instance_number = s.instance_number
                   and trunc(s.end_interval_time) between to_date('01/06/2013', 'dd/mm/yyyy') and to_date('30/06/2013', 'dd/mm/yyyy'))
         where readtim_lag is not null and phyrds_lag is not null and (phyrds - phyrds_lag) > 0)
 group by trunc(snap_date), instance_number, filename)
 order by avg_read_time_ms;
 