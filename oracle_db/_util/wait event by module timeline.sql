
WITH
  t0 AS (
    SELECT COUNT(*) cnt,
           a.module,
           c.username,
           a.event,
           to_char(b.end_interval_time, 'dd/mm/yyyy hh24:mi:ss') snap_time
      FROM dba_hist_active_sess_history a,
           dba_hist_snapshot b,
           dba_users c,
           dba_hist_sqlstat d,
           dba_hist_sqltext e
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       AND b.instance_number = 1
--       AND b.snap_id BETWEEN 4121 and 4140
       AND b.snap_id BETWEEN 5615 and 5639
       and a.module like '%bch%'
       AND a.sql_id IS NOT NULL
       AND a.session_state = 'WAITING' --AND a.event = :event
       AND a.user_id = c.user_id
       AND d.dbid = a.dbid
       AND d.instance_number = a.instance_number
       AND d.sql_id = a.sql_id
       AND d.dbid = b.dbid
       AND d.instance_number = b.instance_number
       AND d.snap_id = a.snap_id
       AND d.sql_id = a.sql_id
       AND e.dbid = b.dbid
       AND e.sql_id = a.sql_id
       AND e.command_type IN (3, 2, 6, 7)
     GROUP BY a.module, c.username, a.event, b.end_interval_time
     ORDER BY COUNT(*) DESC)
SELECT ROUND(ratio_to_report(t1.cnt) over(partition by t1.snap_time, t1.module, t1.username) * 100,2) pct,
       t1.event,
       t1.module,
       t1.username,
       t1.snap_time
  FROM t0 t1
 ORDER BY pct DESC;
