spool top_queries_by_stats.log

select 'RANK_BG;PCT_BG;RANK_DR;PCT_DR;RANK_CPU;PCT_CPU;RANK_ELAP;PCT_ELAP;RANK_PARSE;PCT_PARSE;RANK_EXEC;PCT_EXEC;'||
       'FLAG;SQL_ID;INSTANCE;BG;DR;CPU;ELAP;PARSE;EXEC;MODULE;SCHEMA' extraction from dual;
select * from (
select rank_buffer_gets,pct_buffer_gets,rank_disk_reads,pct_disk_reads,
       rank_cpu_time,pct_cpu_time,rank_elapsed,pct_elapsed,
       rank_parses,pct_parses,rank_executions,pct_executions,
       case when pct_buffer_gets > 5 or pct_disk_reads > 5 or pct_cpu_time > 5 or pct_elapsed > 5 or pct_executions > 5 then 1 else 0 end,
       sql_id,instance_number,buffer_gets,disk_reads,cpu_time,elapsed,parses,executions,module,schema
  from (select /*+ ordered use_nl (b st) */
          dense_rank() over (partition by t.instance_number order by buffer_gets desc, rownum) rank_buffer_gets,
          ratio_to_report(nvl(buffer_gets,0)) over (partition by t.instance_number)*100 pct_buffer_gets,
          dense_rank() over (partition by t.instance_number order by disk_reads desc, rownum) rank_disk_reads,
          ratio_to_report(nvl(disk_reads,0)) over (partition by t.instance_number)*100 pct_disk_reads,
          dense_rank() over (partition by t.instance_number order by cpu_time desc, rownum) rank_cpu_time,
          ratio_to_report(nvl(cpu_time,0)) over (partition by t.instance_number)*100 pct_cpu_time,
          dense_rank() over (partition by t.instance_number order by elapsed desc, rownum) rank_elapsed,
          ratio_to_report(nvl(elapsed,0)) over (partition by t.instance_number)*100 pct_elapsed,
          dense_rank() over (partition by t.instance_number order by parses desc, rownum) rank_parses,
          ratio_to_report(nvl(parses,0)) over (partition by t.instance_number)*100 pct_parses,
          dense_rank() over (partition by t.instance_number order by executions desc, rownum) rank_executions,
          ratio_to_report(nvl(executions,0)) over (partition by t.instance_number)*100 pct_executions,
          t.sql_id, t.instance_number, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions, t.module, t.schema
        from (select sqls.sql_id, sqls.instance_number, max(sqls.module) module, max(sqls.parsing_schema_name) schema,
                     sum(nvl(sqls.buffer_gets_delta,0)) buffer_gets, sum(nvl(sqls.disk_reads_delta,0)) disk_reads,
                     trunc(sum(nvl(sqls.cpu_time_delta,0))/1000000,2) cpu_time, trunc(sum(nvl(sqls.elapsed_time_delta,0))/1000000,2) elapsed,
                     sum(nvl(sqls.parse_calls_delta,0)) parses, sum(nvl(sqls.executions_delta,0)) executions
                from sys.dba_hist_sqlstat sqls, sys.dba_hist_snapshot snap
               where sqls.dbid = snap.dbid and sqls.snap_id = snap.snap_id and sqls.instance_number = snap.instance_number
                 and snap.end_interval_time >= to_date(&begin_date,&date_mask)
                 and snap.end_interval_time <= to_date(&end_date,&date_mask)
               group by sqls.sql_id, sqls.instance_number) t)
 where rank_buffer_gets <= 25
    or rank_disk_reads <= 25
    or rank_cpu_time <= 25
    or rank_elapsed <= 25
    or rank_parses <= 25
    or rank_executions <= 25
order by instance_number, rank_buffer_gets, rank_disk_reads, rank_cpu_time, rank_elapsed, rank_parses, rank_executions, instance_number);

spool off;

set termout on;
prompt *    top_queries_by_stats.log
set termout off;
