SELECT DATA,
  NVL (MAX (DECODE (INSTANCE_NUMBER,1, avg_read_time_ms)), NULL) BPCSP1
FROM
  (SELECT TRUNC(SNAP_DATE,'HH24') DATA,
    instance_number,
    TRUNC(AVG(avg_read_time_ms), 2) avg_read_time_ms,
    TRUNC(MAX(avg_read_time_ms), 2) avg_max_read_time_ms
  FROM
    (SELECT snap_date,
      instance_number,
      filename,
      TRUNC((readtim - readtim_lag) / (phyrds - phyrds_lag) * 10, 2) avg_read_time_ms
    FROM
      (SELECT s.end_interval_time snap_date,
        s.instance_number,
        f.filename,
        f.readtim,
        lag(f.readtim,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time) readtim_lag,
        f.phyrds,
        lag(f.phyrds,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time) phyrds_lag
      FROM DBA_HIST_FILESTATXS f,
        DBA_HIST_SNAPSHOT s
      WHERE f.snap_id            = s.snap_id
      AND f.instance_number      = s.instance_number
      AND s.begin_interval_time >= TRUNC(ADD_MONTHS(SYSDATE,   -1),'MM')
      AND s.end_interval_time   <= LAST_DAY(ADD_MONTHS(SYSDATE,-1))
      )
    WHERE readtim_lag        IS NOT NULL
    AND phyrds_lag           IS NOT NULL
    AND (phyrds - phyrds_lag) > 0
    )
  GROUP BY TRUNC(SNAP_DATE,'HH24'),
    instance_number
  )
GROUP BY data
ORDER BY data