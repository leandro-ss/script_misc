WITH
  t0 AS (
    SELECT COUNT(*) cnt,
           a.sql_id,
           a.module,
           c.username,
           SUM(d.buffer_gets_delta) buffer_gets,
           SUM(d.disk_reads_delta) disk_reads,
           SUM(d.cpu_time_delta)/1000000 cpu_time_s,
           SUM(d.elapsed_time_delta)/1000000 elap_time_s,
           SUM(d.parse_calls_delta) parses,
           SUM(d.executions_delta) execs
      FROM dba_hist_active_sess_history a,
           dba_hist_snapshot b,
           dba_users c,
           dba_hist_sqlstat d,
           dba_hist_sqltext e
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       AND b.instance_number = :inst_id
       AND b.snap_id BETWEEN :snap_start AND :snap_end
       AND a.sql_id IS NOT NULL
       AND a.session_state = 'WAITING' AND a.event = :event
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
       AND 1=1
       AND 1=1
       AND e.command_type IN (3, 2, 6, 7)
     GROUP BY a.sql_id, a.module, c.username
     ORDER BY COUNT(*) DESC),
  t1 AS (
    SELECT *
      FROM t0
     WHERE ROWNUM <= 25)
SELECT -1 qtd,
       -1 peak_id,
       ROUND(ratio_to_report(t1.cnt) over() * 100,2) pct,
       t1.module,
       t1.username,
       t1.sql_id,
       buffer_gets,
       decode(execs,0,0,buffer_gets/execs) buffer_gets_by_exec,
       disk_reads,
       decode(execs,0,0,disk_reads/execs) disk_reads_by_exec,
       round(cpu_time_s,2) cpu_time_s,
       round(decode(execs,0,0,cpu_time_s/execs),2) cpu_time_by_exec_s,
       round(elap_time_s,2) elap_time_s,
       round(decode(execs,0,0,elap_time_s/execs),2) elap_time_by_exec_s,
       parses,
       execs,
       replace(replace(to_char(substr(t2.sql_text,1,32)),chr(13),null),chr(10),null) sql_text
  FROM t1,
       dba_hist_sqltext t2
 WHERE t1.sql_id = t2.sql_id
 ORDER BY pct DESC