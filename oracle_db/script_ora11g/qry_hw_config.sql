spool hw_config.log

select 'INST_ID;INSTANCE;THREAD;HOSTNAME;CPUS;CORES;CPU_BY_CORE;SOCKETS;MEMORY_GB;VERSION;STATUS;STARTUP_TIME' extraction from dual;
select i.inst_id,i.instance_number,i.thread#,upper(i.host_name),
       o1.value,o2.value,trunc(o1.value/o2.value),o3.value,
       ceil(o4.value/1024/1024/1024),
       i.version,i.status,i.startup_time
  from gv$instance i, gv$osstat o1, gv$osstat o2, gv$osstat o3, gv$osstat o4
 where i.INST_ID = o1.inst_id (+)
   and i.INST_ID = o2.inst_id (+)
   and i.INST_ID = o3.inst_id (+)
   and i.INST_ID = o4.inst_id (+)
   and o1.stat_name (+) = 'NUM_CPUS'
   and o2.stat_name (+) = 'NUM_CPU_CORES'
   and o3.stat_name (+) = 'NUM_CPU_SOCKETS'
   and o4.stat_name (+) = 'PHYSICAL_MEMORY_BYTES';

spool off;

set termout on;
prompt *    hw_config.log
set termout off;
