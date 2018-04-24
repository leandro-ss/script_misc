spool sql_plans.log

select 'PLAN_DATE;INSTANCE;SQL_ID;MODULE;USERNAME;PLAN_HASH' extraction from dual;

with
  t0 as (
  select snap.end_interval_time snap_time, sqls.instance_number, sqls.sql_id, sqls.module, sqls.parsing_schema_name username, plan_hash_value
    from sys.dba_hist_sqlstat sqls, sys.dba_hist_snapshot snap
   where sqls.dbid = snap.dbid and sqls.snap_id = snap.snap_id and sqls.instance_number = snap.instance_number
     and snap.end_interval_time >= to_date(&begin_date,&date_mask)
     and snap.end_interval_time <= to_date(&end_date,&date_mask)
     and sqls.sql_id in (select sql_id from (
                           select sqlsi.sql_id, count(distinct(sqlsi.plan_hash_value))
                             from sys.dba_hist_sqlstat sqlsi, sys.dba_hist_snapshot snapi
                            where sqlsi.dbid = snapi.dbid and sqlsi.snap_id = snapi.snap_id and sqlsi.instance_number = snapi.instance_number
                              and snapi.end_interval_time >= to_date(&begin_date,&date_mask)
                              and snapi.end_interval_time <= to_date(&end_date,&date_mask)
                            group by sqlsi.sql_id
                           having count(distinct(sqlsi.plan_hash_value)) > 1)))
select * from (
select snap_time,instance_number,sql_id,module,username,plan_hash_value
from t0
order by snap_time, instance_number, sql_id, plan_hash_value);

spool off;

set termout on;
prompt *    sql_plans.log
set termout off;
