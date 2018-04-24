    select to_char(s.end_interval_time, 'dd/mm/yyyy hh24:mi:ss') snap_date,
    case 
      when d.snap_id between 5615 and 5639 then 'setembro'
      when d.snap_id between 4121 and 4140 then 'julho'
    end janela,
    d.sql_id, d.plan_hash_value,
    sum(d.buffer_gets_delta) buffer_gets,
    sum(d.disk_reads_delta) disk_reads,
    sum(d.cpu_time_total) cpu_time,
    sum(d.elapsed_time_delta) elapsed_time,
    sum(d.executions_delta) execs,
    sum(d.rows_processed_delta) rows_processed
      from dba_hist_sqlstat d, dba_hist_snapshot s
     where (d.snap_id between 5615 and 5639 or d.snap_id between 4121 and 4140)
       and d.module like '%bch%' and sql_id = 'd4x4pax2vbr4k'
and d.snap_id = s.snap_id
and d.instance_number = s.instance_number
group by
to_char(s.end_interval_time, 'dd/mm/yyyy hh24:mi:ss'),
case 
      when d.snap_id between 5615 and 5639 then 'setembro'
      when d.snap_id between 4121 and 4140 then 'julho'
    end,
    d.sql_id, d.plan_hash_value
