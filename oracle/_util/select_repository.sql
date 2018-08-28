
variable data_inicial varchar2(8)
variable data_final   varchar2(8)

exec select '20120501' into :data_inicial from dual;
exec select '20120531' into :data_final   from dual;

set pages 0;
set feedback off;
set serveroutput on size unlimited;
set trimspool on;

spool redo_log.log

select 'SWITCH_DATE;MINUTE_INTERVAL' as header from dual
union all
select to_char(first_time,'dd/mm/yyyy hh24:mi:ss')||';'||interval_min as file_content
  from
   (select
      first_time,
      round((first_time - lag(first_time,1) over (partition by thread# order by sequence#))*24*60) interval_min
    from v$loghist
    where thread# = 1
    and trunc(first_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(first_time) <= to_date(:data_final,'yyyymmdd'))
 where interval_min is not null;

spool off;

spool parse.log

with
  t1 as (select a.snap_id, to_date(to_char(b.end_interval_time,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') snap_time, a.stat_name, a.value
         from dba_hist_sysstat a, dba_hist_snapshot b where a.dbid = b.dbid
         and a.instance_number = b.instance_number and a.snap_id = b.snap_id and b.instance_number = 1
         and trunc(b.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
         and trunc(b.end_interval_time) <= to_date(:data_final,'yyyymmdd')
         and stat_name in ('parse count (total)','parse count (hard)','session cursor cache hits')),
  t2 as (select snap_id, snap_time, stat_name, value from t1 where stat_name = 'parse count (total)'),
  t3 as (select snap_id, snap_time, stat_name, value from t1 where stat_name = 'parse count (hard)'),
  t4 as (select snap_id, snap_time, stat_name, value from t1 where stat_name = 'session cursor cache hits'),
  t5 as (select t2.snap_id, t2.snap_time, t2.value total_parses, t3.value hard_parses, t4.value session_cursor_cache_hit
         from t2, t3, t4 where t2.snap_id = t3.snap_id and t3.snap_id = t4.snap_id),
  t6 as (select snap_id, snap_time, total_parses, hard_parses, session_cursor_cache_hit,
           lag(total_parses,1,0) over (order by snap_id) total_parses_prev,
           lag(hard_parses,1,0) over (order by snap_id) hard_parses_prev,
           lag(session_cursor_cache_hit,1,0) over (order by snap_id) sess_cur_cache_hit_prev
         from t5),
  t7 as (select snap_id, snap_time, total_parses, hard_parses, session_cursor_cache_hit,
           case when (total_parses < total_parses_prev) then total_parses else total_parses - total_parses_prev end total_parses_delta,
           case when (hard_parses < hard_parses_prev) then hard_parses else hard_parses - hard_parses_prev end hard_parses_delta,
           case when (session_cursor_cache_hit < sess_cur_cache_hit_prev) then session_cursor_cache_hit else session_cursor_cache_hit - sess_cur_cache_hit_prev end session_cursor_cache_hit_delta
         from t6),
  t8 as (select rownum rn, t7.*,
           round(session_cursor_cache_hit_delta / total_parses_delta * 100,2) perc_cursor_cache_hits,
           round(((total_parses_delta - session_cursor_cache_hit_delta - hard_parses_delta) / total_parses_delta) * 100,2) perc_soft_parses,
           round(hard_parses_delta / total_parses_delta * 100,2) perc_hard_parses
         from t7 order by to_date(snap_time,'dd/mm/yyyy hh24:mi:ss'))
select 'PARSE_DATE;CACHE;SOFT;HARD' from dual
union all
select to_char(snap_time,'dd/mm/yyyy hh24:mi:ss')||';'||to_char(perc_cursor_cache_hits,'990.00')||';'||to_char(perc_soft_parses,'990.00')||';'||to_char(perc_hard_parses,'990.00')
from t8 where rn > 1 and not (perc_cursor_cache_hits < 0 or perc_soft_parses < 0 or perc_hard_parses < 0);

spool off;

spool hit_ratio.log

with
  t1 as
   (select a.snap_id, to_date(to_char(b.end_interval_time,'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi') snap_time, a.stat_name, a.value
    from dba_hist_sysstat a, dba_hist_snapshot b
    where a.dbid = b.dbid and a.instance_number = b.instance_number and a.snap_id = b.snap_id and b.instance_number = 1
    and trunc(b.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(b.end_interval_time) <= to_date(:data_final,'yyyymmdd')
    and stat_name in ('db block gets','consistent gets','physical reads')),
  t2 as (select snap_id, snap_time, stat_name, value from t1 where stat_name = 'db block gets'),
  t3 as (select snap_id, snap_time, stat_name, value from t1 where stat_name = 'consistent gets'),
  t4 as (select snap_id, snap_time, stat_name, value from t1 where stat_name = 'physical reads'),
  t5 as (select t2.snap_id, t2.snap_time, t2.value db_block_gets, t3.value consistent_gets, t4.value physical_reads
         from t2, t3, t4 where t2.snap_id = t3.snap_id and t3.snap_id = t4.snap_id),
  t6 as (select snap_id, snap_time, db_block_gets, consistent_gets, physical_reads,
                lag(db_block_gets,1,0) over (order by snap_id) db_block_gets_prev,
                lag(consistent_gets,1,0) over (order by snap_id) consistent_gets_prev,
                lag(physical_reads,1,0) over (order by snap_id) physical_reads_prev
         from t5),
  t61 as (select snap_id, snap_time, db_block_gets, consistent_gets, physical_reads,
            case when (db_block_gets < db_block_gets_prev) then db_block_gets else db_block_gets - db_block_gets_prev end db_block_gets_delta,
            case when (consistent_gets < consistent_gets_prev) then consistent_gets else consistent_gets - consistent_gets_prev end consistent_gets_delta,
            case when (physical_reads < physical_reads_prev) then physical_reads else physical_reads - physical_reads_prev end physical_reads_delta
          from t6),
  t7 as (select rownum rn, t61.*,
           round((db_block_gets_delta + consistent_gets_delta - physical_reads_delta) / decode((db_block_gets_delta + consistent_gets_delta),0,1,(db_block_gets_delta + consistent_gets_delta)) * 100,2) value
         from t61 order by to_date(snap_time,'dd/mm/yyyy hh24:mi'))
select 'HIT_RATIO_DATE;PERC' from dual
union all
select to_char(chart_date,'dd/mm/yyyy hh24:mi:ss')||';'||to_char(min(value),'990.00')
  from (select snap_time chart_date, value
          from t7 where rn > 1) with_qry
 group by chart_date;

spool off;

spool sga.log

select 'SGA_DATE;INSTANCE;POOL;USED;FREE' from dual
union all
select to_char(snap.begin_interval_time,'dd/mm/yyyy hh24:mi:ss')||';'||to_char(snap.instance_number)||';'||nvl2(sgas.pool,sgas.pool, sgas.name)||';'||
to_char(sum(case when sgas.name like '%free memory%' then 0 else sgas.bytes end)/1024/1024,'999990.00')||';'||
to_char(sum(case when sgas.name like '%free memory%' then sgas.bytes else 0 end)/1024/1024,'999990.00')
from dba_hist_sgastat sgas, dba_hist_snapshot snap
where sgas.snap_id = snap.snap_id
and trunc(snap.begin_interval_time) >= to_date(:data_inicial,'yyyymmdd')
and trunc(snap.begin_interval_time) <= to_date(:data_final,'yyyymmdd')
group by snap.begin_interval_time,snap.instance_number,nvl2(sgas.pool,sgas.pool, sgas.name);

spool off;

spool pga.log

select 'PGA_DATE;INSTANCE;TYPE;SIZE' from dual
union all
select to_char(snap.begin_interval_time,'dd/mm/yyyy hh24:mi:ss')||';'||to_char(snap.instance_number)||';'||pgas.name||';'||to_char(sum(pgas.value)/1024/1024,'999990.00')
  from dba_hist_pgastat pgas, dba_hist_snapshot snap
 where snap.instance_number = pgas.instance_number
   and trunc(snap.begin_interval_time) >= to_date(:data_inicial,'yyyymmdd')
   and trunc(snap.begin_interval_time) <= to_date(:data_final,'yyyymmdd')
   and pgas.snap_id = snap.snap_id
   and pgas.name in
       ('total PGA allocated', 'total PGA inuse')
 group by snap.begin_interval_time, snap.instance_number, pgas.name;

spool off;

spool wait_event.log

declare
    i integer := 0;
    last_startup date;
    last_id integer;
    last_datahora varchar2(20);
    cursor c_snap is
        select snap_id, startup_time, to_char(end_interval_time,'dd/mm/yyyy hh24:mi:ss') datahora
          from sys.dba_hist_snapshot
         where instance_number = 1
         and trunc(end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
         and trunc(end_interval_time) <= to_date(:data_final,'yyyymmdd')
         order by end_interval_time;
    cursor c_data (v_bid in integer, v_eid in integer) is
        select event , time time_s
                  from (  select e.event_name event, (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000 time
                         from sys.dba_hist_system_event b
                            , sys.dba_hist_system_event e
                        where b.snap_id(+)          = v_bid
                          and e.snap_id             = v_eid
                          and b.instance_number = 1
                          and e.instance_number = 1
                          and b.event_id(+)         = e.event_id
                          and e.total_waits         > nvl(b.total_waits,0)
                          and e.wait_class not in ('Idle')
                        UNION ALL
                       select 'CPU' event, (e.value-b.value)/1000000 time
                         from sys.dba_hist_sys_time_model b, sys.dba_hist_sys_time_model e
                        where e.snap_id         = v_eid
                          and b.snap_id         = v_bid
                          and b.instance_number = 1
                          and e.instance_number = 1
                          and e.stat_name       = 'DB CPU'
                          and b.stat_name       = 'DB CPU'
                        order by time desc
                      )
         where rownum <= 25
           and time > 0;
begin
   dbms_output.put_line('SNAPSHOT_ID;EVENT_DATE;EVENT;TIME');
   for r_snap in c_snap loop
       i := i+1;
       if (i > 1) and (r_snap.startup_time = last_startup) then
         for r_data in c_data (last_id, r_snap.snap_id) loop
          dbms_output.put_line(last_id||';'||last_datahora||';'||r_data.event||';'||round(r_data.time_s));
         end loop;
       end if;
       last_startup := r_snap.startup_time;
       last_id      := r_snap.snap_id;
       last_datahora:= r_snap.datahora;
   end loop;
end;
/

spool off;

set pages 1000;
set lines 160;
set verify off;
column cpu_time format a12
column elapsed format a12
column parses format 99999999
column executions format 99999999
column pct format 90.99

spool top_buffer_gets.log

select 'PCT;SQL_ID;BUFFER_GETS;DISK_READS;CPU_TIME;ELAPSED;PARSES;EXECUTIONS' from dual
union all
select to_char(pct,'990.00')||';'||sql_id||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions
from (
  select /*+ ordered use_nl (b st) */
    ratio_to_report(nvl(buffer_gets,0)) over ()*100 PCT, t.sql_id, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions
  from (
    SELECT
      sqls.SQL_ID,
      SUM(sqls.BUFFER_GETS_DELTA) buffer_gets,
      SUM(sqls.DISK_READS_DELTA) disk_reads,
      trunc(SUM(sqls.CPU_TIME_DELTA)/1000000,2) cpu_time,
      trunc(SUM(sqls.ELAPSED_TIME_DELTA)/1000000,2) elapsed,
      SUM(sqls.PARSE_CALLS_DELTA) parses,
      SUM(sqls.EXECUTIONS_DELTA) executions
    FROM DBA_HIST_SQLSTAT sqls, DBA_HIST_SNAPSHOT snap
    WHERE sqls.INSTANCE_NUMBER = 1
    AND sqls.SNAP_ID = snap.snap_id
    and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
    GROUP BY sqls.SQL_ID) t order by pct desc
) where rownum <= 25;

spool off;

spool top_disk_reads.log

select 'PCT;SQL_ID;BUFFER_GETS;DISK_READS;CPU_TIME;ELAPSED;PARSES;EXECUTIONS' from dual
union all
select to_char(pct,'990.00')||';'||sql_id||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions
from (
  select /*+ ordered use_nl (b st) */
    ratio_to_report(nvl(disk_reads,0)) over ()*100 PCT, t.sql_id, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions
  from (
    SELECT
      sqls.SQL_ID,
      SUM(sqls.BUFFER_GETS_DELTA) buffer_gets,
      SUM(sqls.DISK_READS_DELTA) disk_reads,
      trunc(SUM(sqls.CPU_TIME_DELTA)/1000000,2) cpu_time,
      trunc(SUM(sqls.ELAPSED_TIME_DELTA)/1000000,2) elapsed,
      SUM(sqls.PARSE_CALLS_DELTA) parses,
      SUM(sqls.EXECUTIONS_DELTA) executions
    FROM DBA_HIST_SQLSTAT sqls, DBA_HIST_SNAPSHOT snap
    WHERE sqls.INSTANCE_NUMBER = 1
    AND sqls.SNAP_ID = snap.snap_id
    and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
    GROUP BY sqls.SQL_ID) t order by pct desc
) where rownum <= 25;

spool off;

spool top_cpu_time.log

select 'PCT;SQL_ID;BUFFER_GETS;DISK_READS;CPU_TIME;ELAPSED;PARSES;EXECUTIONS' from dual
union all
select to_char(pct,'990.00')||';'||sql_id||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions
from (
  select /*+ ordered use_nl (b st) */
    ratio_to_report(nvl(cpu_time,0)) over ()*100 PCT, t.sql_id, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions
  from (
    SELECT
      sqls.SQL_ID,
      SUM(sqls.BUFFER_GETS_DELTA) buffer_gets,
      SUM(sqls.DISK_READS_DELTA) disk_reads,
      trunc(SUM(sqls.CPU_TIME_DELTA)/1000000,2) cpu_time,
      trunc(SUM(sqls.ELAPSED_TIME_DELTA)/1000000,2) elapsed,
      SUM(sqls.PARSE_CALLS_DELTA) parses,
      SUM(sqls.EXECUTIONS_DELTA) executions
    FROM DBA_HIST_SQLSTAT sqls, DBA_HIST_SNAPSHOT snap
    WHERE sqls.INSTANCE_NUMBER = 1
    AND sqls.SNAP_ID = snap.snap_id
    and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
    GROUP BY sqls.SQL_ID) t order by pct desc
) where rownum <= 25;

spool off;

spool top_elapsed_time.log

select 'PCT;SQL_ID;BUFFER_GETS;DISK_READS;CPU_TIME;ELAPSED;PARSES;EXECUTIONS' from dual
union all
select to_char(pct,'990.00')||';'||sql_id||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions
from (
  select /*+ ordered use_nl (b st) */
    ratio_to_report(nvl(elapsed,0)) over ()*100 PCT, t.sql_id, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions
  from (
    SELECT
      sqls.SQL_ID,
      SUM(sqls.BUFFER_GETS_DELTA) buffer_gets,
      SUM(sqls.DISK_READS_DELTA) disk_reads,
      trunc(SUM(sqls.CPU_TIME_DELTA)/1000000,2) cpu_time,
      trunc(SUM(sqls.ELAPSED_TIME_DELTA)/1000000,2) elapsed,
      SUM(sqls.PARSE_CALLS_DELTA) parses,
      SUM(sqls.EXECUTIONS_DELTA) executions
    FROM DBA_HIST_SQLSTAT sqls, DBA_HIST_SNAPSHOT snap
    WHERE sqls.INSTANCE_NUMBER = 1
    AND sqls.SNAP_ID = snap.snap_id
    and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
    GROUP BY sqls.SQL_ID) t order by pct desc
) where rownum <= 25;

spool off;

spool top_parse.log

select 'PCT;SQL_ID;BUFFER_GETS;DISK_READS;CPU_TIME;ELAPSED;PARSES;EXECUTIONS' from dual
union all
select to_char(pct,'990.00')||';'||sql_id||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions
from (
  select /*+ ordered use_nl (b st) */
    ratio_to_report(nvl(parses,0)) over ()*100 PCT, t.sql_id, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions
  from (
    SELECT
      sqls.SQL_ID,
      SUM(sqls.BUFFER_GETS_DELTA) buffer_gets,
      SUM(sqls.DISK_READS_DELTA) disk_reads,
      trunc(SUM(sqls.CPU_TIME_DELTA)/1000000,2) cpu_time,
      trunc(SUM(sqls.ELAPSED_TIME_DELTA)/1000000,2) elapsed,
      SUM(sqls.PARSE_CALLS_DELTA) parses,
      SUM(sqls.EXECUTIONS_DELTA) executions
    FROM DBA_HIST_SQLSTAT sqls, DBA_HIST_SNAPSHOT snap
    WHERE sqls.INSTANCE_NUMBER = 1
    AND sqls.SNAP_ID = snap.snap_id
    and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
    GROUP BY sqls.SQL_ID) t order by pct desc
) where rownum <= 25;

spool off;

spool top_execution.log

select 'PCT;SQL_ID;BUFFER_GETS;DISK_READS;CPU_TIME;ELAPSED;PARSES;EXECUTIONS' from dual
union all
select to_char(pct,'990.00')||';'||sql_id||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions
from (
  select /*+ ordered use_nl (b st) */
    ratio_to_report(nvl(executions,0)) over ()*100 PCT, t.sql_id, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions
  from (
    SELECT
      sqls.SQL_ID,
      SUM(sqls.BUFFER_GETS_DELTA) buffer_gets,
      SUM(sqls.DISK_READS_DELTA) disk_reads,
      trunc(SUM(sqls.CPU_TIME_DELTA)/1000000,2) cpu_time,
      trunc(SUM(sqls.ELAPSED_TIME_DELTA)/1000000,2) elapsed,
      SUM(sqls.PARSE_CALLS_DELTA) parses,
      SUM(sqls.EXECUTIONS_DELTA) executions
    FROM DBA_HIST_SQLSTAT sqls, DBA_HIST_SNAPSHOT snap
    WHERE sqls.INSTANCE_NUMBER = 1
    AND sqls.SNAP_ID = snap.snap_id
    and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd')
    and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
    GROUP BY sqls.SQL_ID) t order by pct desc
) where rownum <= 25;

spool off;
