set trimspool on
set lines 2000
set pages 0
set heading off

spool 11_pga_timeline.log

select 'SNAP_DATE;INSTANCE_NUMBER;AVG_PGA_ALLOCATED;MAX_PGA_ALLOCATED' from dual;

select to_char(s.end_interval_time, 'dd/mm/yyyy hh24')||':00:00'||';SIEBELP1'||s.instance_number||';'||trunc(avg(p.value/1024/1024), 2)||';'||trunc(max(p.value/1024/1024), 2)
  from dba_hist_pgastat p, dba_hist_snapshot s
 where p.snap_id = s.snap_id
   and p.instance_number = s.instance_number
   and trunc(s.begin_interval_time) >= to_date(:data_inicial,'yyyymmdd')
   and trunc(s.end_interval_time) <= to_date(:data_final,'yyyymmdd')
   and p.name = 'total PGA allocated'
 group by to_char(s.end_interval_time, 'dd/mm/yyyy hh24'), s.instance_number;

spool off
