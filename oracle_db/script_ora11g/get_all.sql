
-- Início do Script

alter session set nls_date_format = 'DD/MM/YYYY HH24:MI:SS';
set serveroutput on size unlimited;
set lines 32767;
set pages 0;
set trimspool on;
set heading off;
set feedback off;
set verify off;
set timing off;
set colsep ";";


prompt
select '   Horário da base   : ' || sysdate from dual;
prompt

-- Início da Configuração do Script

def date_mask = '''dd/mm/yyyy'''

variable begin_date_default varchar2(10)
variable end_date_default    varchar2(10)

exec select to_char( decode(  sign(extract(day from sysdate)-20),   1,trunc(sysdate,'mm'),   -1,add_months( trunc(sysdate,'mm'),-1)+14  ),&date_mask) into :begin_date_default from dual;
exec select to_char( trunc(sysdate, 'dd')                                                                                                ,&date_mask) into :end_date_default   from dual;

prompt ********************************************************************************
prompt *                                                                              *
prompt *  Configuração dos parâmetros para início da extração de estatísticas         *
prompt *                                                                              *
prompt *  !! ATENÇÃO !! Para os valores de texto, deve-se utilizar aspas simples ''   *
prompt *                                                                              *
prompt ********************************************************************************
prompt *                                                                              *
prompt *  Período de análise                                                          *
prompt *                                                                              *
prompt *                                                                              *
prompt *  Data de início                                      (com aspas simples '')  *
ACCEPT begin_date PROMPT '*  Valor : ' DEFAULT :begin_date_default
prompt *                                                                              *
prompt *  Data de término                                     (com aspas simples '')  *
ACCEPT end_date   PROMPT '*  Valor : ' DEFAULT :end_date_default
prompt ********************************************************************************
prompt *
prompt *  Início das extrações
prompt *

set termout off;

@qry_awr_config.sql
@qry_clustering_factor.sql
@qry_datafile_response.sql
@qry_db_cache_advisor.sql
@qry_db_hit_ratio.sql
@qry_dictionary_hit_ratio.sql
@qry_enqueue.sql
@qry_hw_config.sql
@qry_interconnect.sql
@qry_io_wait.sql
@qry_java_pool_advisor.sql
@qry_latch.sql
@qry_library_hit_ratio.sql
@qry_memory_resize.sql
@qry_memory_target_advisor.sql
@qry_mttr_advisor.sql
@qry_os_stat.sql
@qry_parameter.sql
@qry_parse.sql
@qry_pga_advisor.sql
@qry_pga_timeline.sql
@qry_redo_config.sql
@qry_redo_log.txt
@qry_resource.sql
@qry_seg_stat.sql
@qry_sga_advisor.sql
@qry_sga_timeline.sql
@qry_shared_pool_advisor.sql
@shared_pool_reserved.sql
@qry_sql_plans.sql
@qry_sql_tracking.sql
@qry_sys_metric.sql
@qry_tablespace_usage.sql
@qry_table_fragmentation.sql
@qry_tempfile_response.sql
@qry_top_queries_by_event.sql
@qry_top_queries_by_stats.sql
@qry_wait_event.sql

set termout on;
prompt *
prompt *  Término das extrações
prompt *
set termout off;

exit
