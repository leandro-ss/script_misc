spool parse.log

select 'PARSE_DATE;INSTANCE;AVG_CACHE;AVG_SOFT;AVG_HARD' extraction from dual;

with
  t1 as (select a.snap_id, b.end_interval_time snap_time,
                a.instance_number, a.stat_name, a.value
           from dba_hist_sysstat a, dba_hist_snapshot b
          where a.dbid = b.dbid
            and a.instance_number = b.instance_number
            and a.snap_id = b.snap_id
            and b.end_interval_time >= to_date(&begin_date,&date_mask)
            and b.end_interval_time <= to_date(&end_date,&date_mask)
            and stat_name in ('parse count (total)','parse count (hard)','session cursor cache hits')),
  t2 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'parse count (total)'),
  t3 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'parse count (hard)'),
  t4 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'session cursor cache hits'),
  t5 as (select t2.snap_id, t2.snap_time, t2.instance_number, t2.value total_parses, t3.value hard_parses, t4.value session_cursor_cache_hit
           from t2, t3, t4
          where t2.snap_id = t3.snap_id and t3.snap_id = t4.snap_id
            and t2.instance_number = t3.instance_number and t3.instance_number = t4.instance_number),
  t6 as (select snap_id, snap_time, instance_number, total_parses, hard_parses, session_cursor_cache_hit,
           lag(total_parses,1,0) over (order by snap_id) total_parses_prev,
           lag(hard_parses,1,0) over (order by snap_id) hard_parses_prev,
           lag(session_cursor_cache_hit,1,0) over (order by snap_id) sess_cur_cache_hit_prev
         from t5),
  t7 as (select snap_id, snap_time, instance_number, total_parses, hard_parses, session_cursor_cache_hit,
           case when (total_parses < total_parses_prev) then total_parses else total_parses - total_parses_prev end total_parses_delta,
           case when (hard_parses < hard_parses_prev) then hard_parses else hard_parses - hard_parses_prev end hard_parses_delta,
           case when (session_cursor_cache_hit < sess_cur_cache_hit_prev) then session_cursor_cache_hit else session_cursor_cache_hit - sess_cur_cache_hit_prev end session_cursor_cache_hit_delta
         from t6),
  t8 as (select rownum rn, t7.*,
           round(session_cursor_cache_hit_delta / total_parses_delta * 100,2) perc_cursor_cache_hits,
           round(((total_parses_delta - session_cursor_cache_hit_delta - hard_parses_delta) / total_parses_delta) * 100,2) perc_soft_parses,
           round(hard_parses_delta / total_parses_delta * 100,2) perc_hard_parses
         from t7 order by snap_time, instance_number)
select * from (
select trunc(snap_time,'hh24'),instance_number,
       avg(perc_cursor_cache_hits),
       avg(perc_soft_parses),
       avg(perc_hard_parses)
from t8 where rn > 1 and not (perc_cursor_cache_hits < 0 or perc_soft_parses < 0 or perc_hard_parses < 0)
group by trunc(snap_time,'hh24'), instance_number
order by trunc(snap_time,'hh24'), instance_number);

spool off;

set termout on;
prompt *    parse.log
set termout off;
