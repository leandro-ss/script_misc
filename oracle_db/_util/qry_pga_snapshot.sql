set trimspool on
set lines 2000
set pages 0
set heading off

spool 12_pga_snapshot.log

select 'INST_ID;USERNAME;OSUSER;EVENT;SESSIONS;PGA_USED_MEM;PGA_ALLOC_MEM' from dual;

select s.inst_id||';'||nvl(s.username, 'BACKGROUND')||';'||s.osuser||';'||s.event||';'||count(*)||';'||trunc(sum(p.pga_used_mem/1024/1024), 2)||';'||trunc(sum(p.pga_alloc_mem/1024/1024), 2)
  from gv$session s, gv$process p
 where s.INST_ID = p.INST_ID
   and s.paddr = p.addr
 group by s.inst_id, nvl(s.username, 'BACKGROUND'), s.osuser, s.event
 order by sum(p.pga_used_mem) desc;

spool off
