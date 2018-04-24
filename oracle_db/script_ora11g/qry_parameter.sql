spool parameter.log

select 'PARAMETER;INSTANCE;VALUE;DEFAULT' extraction from dual;
select * from (
  select name,inst_id,value,isdefault
    from gv$parameter
   order by name, inst_id);

spool off;

set termout on;
prompt *    parameter.log
set termout off;
