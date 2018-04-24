
-- !! ATENÇÃO !! remover o trunc do filtro de data para uma análise mais detalhada

-- recupera pior tempo na pior snapshot de todos os datafiles no período especificado
  select min(snap_date) min_date, max(snap_date) max_date, instance_number, max(avg_read_time_ms) max_read_time_ms, 20 threshold
    from (select snap_date, instance_number, filename, trunc((readtim - readtim_lag) / (phyrds - phyrds_lag) * 10, 2) avg_read_time_ms
            from (select s.end_interval_time snap_date, s.instance_number, f.filename,
                         f.readtim, lag(f.readtim,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) readtim_lag,
                         f.phyrds, lag(f.phyrds,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) phyrds_lag
                    from dba_hist_filestatxs f, dba_hist_snapshot s
                   where f.snap_id = s.snap_id
                     and f.instance_number = s.instance_number
                     and trunc(s.end_interval_time) between to_date('02/03/2013 12:00:00', 'dd/mm/yyyy hh24:mi:ss') and to_date('02/03/2013 21:00:00', 'dd/mm/yyyy hh24:mi:ss'))
           where readtim_lag is not null and phyrds_lag is not null and (phyrds - phyrds_lag) > 0)
   group by instance_number;

-- recupera pior tempo na pior snapshot por datafile no período especificado

  select min_date, max_date, instance_number, filename, avg_read_time_ms, max_read_time_ms, threshold from (
  select to_char(min(snap_date), 'dd/mm/yyyy hh24:mi:ss') min_date, to_char(max(snap_date), 'dd/mm/yyyy hh24:mi:ss') max_date, instance_number, filename,
         avg(avg_read_time_ms) avg_read_time_ms, max(avg_read_time_ms) max_read_time_ms, 20 threshold
    from (select snap_date, instance_number, filename, trunc((readtim - readtim_lag) / (phyrds - phyrds_lag) * 10, 2) avg_read_time_ms
            from (select s.end_interval_time snap_date, s.instance_number, f.filename,
                         f.readtim, lag(f.readtim,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) readtim_lag,
                         f.phyrds, lag(f.phyrds,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) phyrds_lag
                    from dba_hist_filestatxs f, dba_hist_snapshot s
                   where f.snap_id = s.snap_id
                     and f.instance_number = s.instance_number
                     and f.filename in (select file_name from dba_data_files where tablespace_name = 'SIEBEL_DATA_128M')
                     and trunc(s.end_interval_time) = to_date('07/03/2013', 'dd/mm/yyyy'))
           where readtim_lag is not null and phyrds_lag is not null and (phyrds - phyrds_lag) > 0)
   group by instance_number, filename)
   order by avg_read_time_ms;

-- recupera histórico do datafile na linha do tempo no período especificado
  select to_char(snap_date, 'dd/mm/yyyy hh24:mi:ss') snap_date, instance_number, filename, trunc((readtim - readtim_lag) / (phyrds - phyrds_lag) * 10, 2) avg_read_time_ms, 20 threshold
    from (select s.end_interval_time snap_date, s.instance_number, f.filename,
                 f.readtim, lag(f.readtim,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) readtim_lag,
                 f.phyrds, lag(f.phyrds,1) over (partition by s.instance_number, f.filename order by s.end_interval_time) phyrds_lag
            from dba_hist_filestatxs f, dba_hist_snapshot s
           where f.snap_id = s.snap_id
             and f.instance_number = s.instance_number
             and f.filename = '&datafile'
                     and trunc(s.end_interval_time) between to_date('02/03/2013 12:00:00', 'dd/mm/yyyy hh24:mi:ss') and to_date('02/03/2013 21:00:00', 'dd/mm/yyyy hh24:mi:ss'))
   where readtim_lag is not null and phyrds_lag is not null and (phyrds - phyrds_lag) > 0 and readtim > readtim_lag and phyrds > phyrds_lag
   order by snap_date;
