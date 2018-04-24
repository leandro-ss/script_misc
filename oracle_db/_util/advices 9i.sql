advices 9i

spool pga.log

select 'mes;instancia;tamanho;fator;minimo_overallocation;maximo_overallocation' pga_extract from dual;
select to_char(snap.snap_time, 'mon/yyyy')||';'||pga.instance_number||';'||trim(to_char(trunc(max(pga.pga_target_for_estimate)/1024/1024,2),'999990.00'))||';'||
       trim(to_char(pga.pga_target_factor,'999990.00'))||';'||min(pga.estd_overalloc_count)||';'||max(pga.estd_overalloc_count)
  from stats$pga_target_advice pga, stats$snapshot snap
 where pga.dbid = snap.dbid and pga.snap_id = snap.snap_id and pga.instance_number = snap.instance_number
   and trunc(snap.snap_time) >= to_date('20130901','yyyymmdd') and trunc(snap.snap_time) <= to_date('20130915','yyyymmdd')
 group by to_char(snap.snap_time, 'mon/yyyy'), pga.instance_number, pga.pga_target_factor;

spool off;

spool db_cache.log

select 'mes;instancia;tamanho;fator;minimo_leituras_fisicas;maximo_leituras_fisicas' sga_extract from dual;
select to_char(snap.snap_time, 'mon/yyyy')||';'||db.instance_number||';'||trim(to_char(trunc(max(db.size_for_estimate)),'999990.00'))||';'||
       trim(to_char(trunc(db.size_factor,1),'999990.00'))||';'||min(db.estd_physical_reads)||';'||max(db.estd_physical_reads)
  from stats$db_cache_advice db, stats$snapshot snap
 where db.dbid = snap.dbid and db.snap_id = snap.snap_id and db.instance_number = snap.instance_number
   and trunc(snap.snap_time) >= to_date('20130901','yyyymmdd') and trunc(snap.snap_time) <= to_date('20130915','yyyymmdd')
 group by to_char(snap.snap_time, 'mon/yyyy'), db.instance_number, trunc(db.size_factor,1);

spool off;

spool shared_pool.log

select 'mes;instancia;tamanho;fator;minimo_memory_object_hits;maximo_memory_object_hits' sga_extract from dual;
select to_char(snap.snap_time, 'mon/yyyy')||';'||shared.instance_number||';'||max(shared.shared_pool_size_for_estimate)||';'||
       trim(to_char(trunc(shared.shared_pool_size_factor,1),'999990.00'))||';'||min(shared.estd_lc_memory_object_hits)||';'||max(shared.estd_lc_memory_object_hits)
  from stats$shared_pool_advice shared, stats$snapshot snap
 where shared.dbid = snap.dbid and shared.snap_id = snap.snap_id and shared.instance_number = snap.instance_number
   and trunc(snap.snap_time) >= to_date('20130901','yyyymmdd') and trunc(snap.snap_time) <= to_date('20130915','yyyymmdd')
 group by to_char(snap.snap_time, 'mon/yyyy'), shared.instance_number, trunc(shared.shared_pool_size_factor,1);

spool off;