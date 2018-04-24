spool redo_log.log
-- Dados demonstram o intervalo medio entre as trocas de REDO LOG FILE tendo como o desejavel a troca com um interlo entre 5 e 15 para evitar a
-- ocorrencia do evento LOG FILE SYNC caso intervalo mal configurado pode ocasionar o evento LOG PARALLEL WRITE

select 'SWITCH_DATE;INSTANCE;MIN_INTERVAL;AVG_INTERVAL;P90_INTERVAL;P95_INTERVAL;P99_INTERVAL;MAX_INTERVAL' extraction from dual;
select * from (
select trunc(first_time,'hh24'),
	   thread#,
       min(interval_min),
       avg(interval_min),
       percentile_disc(0.9) within group (order by interval_min),
       percentile_disc(0.95) within group (order by interval_min),
       percentile_disc(0.99) within group (order by interval_min),
       max(interval_min)
  from
   (select first_time, thread#, round((first_time - lag(first_time,1) over (partition by thread# order by sequence#))*24*60) interval_min
     from v$loghist
    where first_time >= to_date(&begin_date,&date_mask)
      and first_time <= to_date(&end_date,&date_mask))
 where interval_min is not null
 group by trunc(first_time,'hh24'), thread#
 order by trunc(first_time,'hh24'), thread#);

spool off;

set termout on;
prompt *    redo_log.log
set termout off;
