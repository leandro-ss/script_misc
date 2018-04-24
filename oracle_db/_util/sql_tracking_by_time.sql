
drop table inmetrics.sql_tracking purge

create table inmetrics.sql_tracking as

insert into inmetrics.sql_tracking
select ses.sql_id, ses.event, sql.SQL_FULLTEXT, sysdate as sql_date from v$session ses, v$sql sql
where ses.status = 'ACTIVE'
and ses.username is not null
and ses.username <> 'INMETRICS'
and ses.sql_id = sql.sql_id
order by ses.sql_id;


truncate table inmetrics.sql_tracking

select * from inmetrics.sql_tracking