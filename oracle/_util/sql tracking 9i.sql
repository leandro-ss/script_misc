-- Coleta o P90 por dia, módulo e hash de buffer gets, disk reads, cpu, tempo, parse, executions e rows
select
  to_char(trunc(snap_time, 'dd'), 'dd/mm/yyyy hh24:mi:ss') snap_time,
  instance_number, hash_value, module,
  percentile_disc(0.9) within group (order by buffer_gets_delta asc) buffer_gets,
  percentile_disc(0.9) within group (order by disk_reads_delta asc) disk_reads,
  percentile_disc(0.9) within group (order by cpu_time_delta asc) cpu_time,
  percentile_disc(0.9) within group (order by elapsed_time_delta asc) elapsed_time,
  percentile_disc(0.9) within group (order by parse_calls_delta asc) parse_calls,
  percentile_disc(0.9) within group (order by executions_delta asc) executions,
  percentile_disc(0.9) within group (order by rows_processed_delta asc) rows_processed
from (
  select snap.snap_time,
         summ.instance_number,
         summ.hash_value,
         summ.module,
         greatest(summ.buffer_gets    - lag(summ.buffer_gets,1)    over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) buffer_gets_delta,
         greatest(summ.disk_reads     - lag(summ.disk_reads,1)     over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) disk_reads_delta,
         greatest(summ.cpu_time       - lag(summ.cpu_time,1)       over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) cpu_time_delta,
         greatest(summ.elapsed_time   - lag(summ.elapsed_time,1)   over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) elapsed_time_delta,
         greatest(summ.parse_calls    - lag(summ.parse_calls,1)    over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) parse_calls_delta,
         greatest(summ.executions     - lag(summ.executions,1)     over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) executions_delta,
         greatest(summ.rows_processed - lag(summ.rows_processed,1) over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) rows_processed_delta
    from stats$sql_summary summ, stats$snapshot snap
   where snap.snap_time >= to_date('20/07/2013', 'dd/mm/yyyy')
     and snap.snap_time < to_date('21/09/2013', 'dd/mm/yyyy')
     and snap.snap_id = summ.snap_id
     and snap.dbid = summ.dbid
     and snap.instance_number = summ.instance_number
)
group by trunc(snap_time, 'dd'), instance_number, hash_value, module

-- Coleta o total das estatísticas por hora, hash e módulo de hashs específicos
select
  to_char(trunc(snap_time, 'hh'), 'dd/mm/yyyy hh24:mi:ss') snap_time,
  instance_number, hash_value, module,
  sum(buffer_gets_delta) buffer_gets,
  sum(disk_reads_delta) disk_reads,
  sum(cpu_time_delta) cpu_time,
  sum(elapsed_time_delta) elapsed_time,
  sum(parse_calls_delta) parse_calls,
  sum(executions_delta) executions,
  sum(rows_processed_delta) rows_processed
from (
  select snap.snap_time,
         summ.instance_number,
         summ.hash_value,
         summ.module,
         greatest(summ.buffer_gets    - lag(summ.buffer_gets,1)    over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) buffer_gets_delta,
         greatest(summ.disk_reads     - lag(summ.disk_reads,1)     over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) disk_reads_delta,
         greatest(summ.cpu_time       - lag(summ.cpu_time,1)       over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) cpu_time_delta,
         greatest(summ.elapsed_time   - lag(summ.elapsed_time,1)   over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) elapsed_time_delta,
         greatest(summ.parse_calls    - lag(summ.parse_calls,1)    over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) parse_calls_delta,
         greatest(summ.executions     - lag(summ.executions,1)     over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) executions_delta,
         greatest(summ.rows_processed - lag(summ.rows_processed,1) over (partition by summ.instance_number, summ.module, summ.hash_value order by snap.snap_time), 0) rows_processed_delta
    from stats$sql_summary summ, stats$snapshot snap
   where snap.snap_time >= to_date('20/07/2013', 'dd/mm/yyyy')
     and snap.snap_time < to_date('21/09/2013', 'dd/mm/yyyy')
     and snap.snap_id = summ.snap_id
     and snap.dbid = summ.dbid
     and snap.instance_number = summ.instance_number
     and summ.hash_value in (75214282,907105818,1345031977,3077821661,3501643103,2070691482,3374999356,3843959347)
)
group by trunc(snap_time, 'hh'), instance_number, hash_value, module
