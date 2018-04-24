
variable data_inicial varchar2(8)
variable data_final   varchar2(8)

exec select '20130301' into :data_inicial from dual;
exec select '20130315' into :data_final   from dual;

set pages 0;
set feedback off;
set serveroutput on size unlimited;
set trimspool on;
set lines 320;
set verify off;

spool sizes.log

show parameter sga;
show parameter pga;
show parameter cache;
show parameter shared;

spool off

spool sga.log

select 'mes;instancia;tamanho;fator;minimo_leituras_fisicas;maximo_leituras_fisicas' sga_extract from dual;
select to_char(snap.end_interval_time, 'mon/yyyy')||';'||sga.instance_number||';'||trim(to_char(trunc(max(sga.sga_size),2),'999990.00'))||';'||trim(to_char(sga.sga_size_factor,'999990.00'))||';'||min(sga.estd_physical_reads)||';'||max(sga.estd_physical_reads)
  from sys.dba_hist_sga_target_advice sga, sys.dba_hist_snapshot snap
 where sga.dbid = snap.dbid and sga.snap_id = snap.snap_id and sga.instance_number = snap.instance_number
   and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd') and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
 group by to_char(snap.end_interval_time, 'mon/yyyy'), sga.instance_number, sga.sga_size_factor;

spool off;

spool pga.log

select 'mes;instancia;tamanho;fator;minimo_overallocation;maximo_overallocation' pga_extract from dual;
select to_char(snap.end_interval_time, 'mon/yyyy')||';'||pga.instance_number||';'||trim(to_char(trunc(max(pga.pga_target_for_estimate)/1024/1024,2),'999990.00'))||';'||trim(to_char(pga.pga_target_factor,'999990.00'))||';'||min(pga.estd_overalloc_count)||';'||max(pga.estd_overalloc_count)
  from sys.dba_hist_pga_target_advice pga, sys.dba_hist_snapshot snap
 where pga.dbid = snap.dbid and pga.snap_id = snap.snap_id and pga.instance_number = snap.instance_number
   and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd') and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
 group by to_char(snap.end_interval_time, 'mon/yyyy'), pga.instance_number, pga.pga_target_factor;

spool off;

spool db_cache.log

select 'mes;instancia;tamanho;fator;minimo_leituras_fisicas;maximo_leituras_fisicas' sga_extract from dual;
select to_char(snap.end_interval_time, 'mon/yyyy')||';'||db.instance_number||';'||trim(to_char(trunc(max(db.size_for_estimate)),'999990.00'))||';'||trim(to_char(trunc(db.size_factor,1),'999990.00'))||';'||min(db.physical_reads)||';'||max(db.physical_reads)
  from sys.dba_hist_db_cache_advice db, sys.dba_hist_snapshot snap
 where db.dbid = snap.dbid and db.snap_id = snap.snap_id and db.instance_number = snap.instance_number
   and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd') and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
 group by to_char(snap.end_interval_time, 'mon/yyyy'), db.instance_number, trunc(db.size_factor,1);

spool off;

spool shared_pool.log

select 'mes;instancia;tamanho;fator;minimo_memory_object_hits;maximo_memory_object_hits' sga_extract from dual;
select to_char(snap.end_interval_time, 'mon/yyyy')||';'||shared.instance_number||';'||max(shared.shared_pool_size_for_estimate)||';'||trim(to_char(trunc(shared.shared_pool_size_factor,1),'999990.00'))||';'||min(shared.estd_lc_memory_object_hits)||';'||max(shared.estd_lc_memory_object_hits)
  from sys.dba_hist_shared_pool_advice shared, sys.dba_hist_snapshot snap
 where shared.dbid = snap.dbid and shared.snap_id = snap.snap_id and shared.instance_number = snap.instance_number
   and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd') and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
 group by to_char(snap.end_interval_time, 'mon/yyyy'), shared.instance_number, trunc(shared.shared_pool_size_factor,1);

spool off;

spool top_queries.log

select 'rank_buffer_gets;pct_buffer_gets;rank_disk_reads;pct_disk_reads;rank_cpu_time;pct_cpu_time;rank_elapsed;pct_elapsed;rank_parses;pct_parses;rank_executions;pct_executions;'||
       'flag;sql_id;instancia;buffer_gets;disk_reads;cpu_time;elapsed;parses;executions;module;schema' top_sql_extract from dual;
select rank_buffer_gets||';'||trim(to_char(pct_buffer_gets,'990.00'))||';'||rank_disk_reads||';'||trim(to_char(pct_disk_reads,'990.00'))||';'||
       rank_cpu_time||';'||trim(to_char(pct_cpu_time,'990.00'))||';'||rank_elapsed||';'||trim(to_char(pct_elapsed,'990.00'))||';'||
       rank_parses||';'||trim(to_char(pct_parses,'990.00'))||';'||rank_executions||';'||trim(to_char(pct_executions,'990.00'))||';'||
       case when pct_buffer_gets > 5 or pct_disk_reads > 5 or pct_cpu_time > 5 or pct_elapsed > 5 or pct_parses > 5 or pct_executions > 5 then 1 else 0 end||';'||
       sql_id||';'||instance_number||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions||';'||module||';'||schema
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
                 and trunc(snap.end_interval_time) >= to_date(:data_inicial,'yyyymmdd') and trunc(snap.end_interval_time) <= to_date(:data_final,'yyyymmdd')
               group by sqls.sql_id, sqls.instance_number) t)
 where rank_buffer_gets <= 25 or rank_disk_reads <= 25 or rank_cpu_time <= 25 or rank_elapsed <= 25 or rank_parses <= 25 or rank_executions <= 25;

spool off;
