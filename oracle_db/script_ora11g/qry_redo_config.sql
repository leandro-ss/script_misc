spool redo_config.log

select 'INSTANCE;GROUPS;MEMBERS_PER_GROUP;SIZE_MB' extraction from dual;
select thread#,count(*),members,trunc(bytes/1024/1024)
  from gv$log
 group by thread#, members, bytes;

spool off;

set termout on;
prompt *    redo_config.log
set termout off;
