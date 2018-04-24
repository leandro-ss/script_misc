spool top_queries_by_event.log

select 'PERC;INSTANCE;EVENT;MODULE;SCHEMA;SQL_ID;BG;BG_BY_EXEC;DR;DR_BY_EXEC;CPU;CPU_BY_EXEC;ELAP;ELAP_BY_EXEC;PARSE;EXEC;SQL_TEXT_SHORT' extraction from dual;

WITH
  t0 AS (
    SELECT COUNT(*) cnt, a.instance_number, a.sql_id, a.module, c.username, a.event,
           SUM(d.buffer_gets_delta) buffer_gets, SUM(d.disk_reads_delta) disk_reads, SUM(d.cpu_time_delta)/1000000 cpu_time_s,
           SUM(d.elapsed_time_delta)/1000000 elap_time_s, SUM(d.parse_calls_delta) parses, SUM(d.executions_delta) execs
      FROM dba_hist_active_sess_history a,
           dba_hist_snapshot b,
           dba_users c,
           dba_hist_sqlstat d,
           dba_hist_sqltext e
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       and b.end_interval_time >= to_date(&begin_date,&date_mask)
       and b.end_interval_time <= to_date(&end_date,&date_mask)
       AND a.sql_id IS NOT NULL
       AND a.session_state = 'WAITING'
       -- AND a.event = :event
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
     GROUP BY a.instance_number, a.sql_id, a.module, c.username, a.event
     ORDER BY COUNT(*) DESC)
select * from (
SELECT ratio_to_report(t0.cnt) over(partition by t0.event) * 100,
       t0.instance_number,t0.event,t0.module,t0.username,t0.sql_id,
       t0.buffer_gets,
       decode(t0.execs,0,0,t0.buffer_gets/t0.execs),
       t0.disk_reads,
       decode(t0.execs,0,0,t0.disk_reads/t0.execs),
       t0.cpu_time_s,
       decode(t0.execs,0,0,t0.cpu_time_s/t0.execs),
       t0.elap_time_s,
       decode(t0.execs,0,0,t0.elap_time_s/t0.execs),
       t0.parses,
       t0.execs,
       replace(replace(to_char(substr(t1.sql_text,1,32)),chr(13),null),chr(10),null)
  FROM t0, dba_hist_sqltext t1
 WHERE t0.sql_id = t1.sql_id
order by t0.instance_number, t0.event, ratio_to_report(t0.cnt) over(partition by t0.event) desc, t0.buffer_gets desc);

spool off;

set termout on;
prompt *    top_queries_by_events.log
set termout off;
