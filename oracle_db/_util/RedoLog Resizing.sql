
-- Verifica tamanho dos grupos atuais
select a.group#, b.thread#, a.member, b.bytes
from v$logfile a, v$log b where a.group# = b.group#;

-- Verifica status dos grupos atuais
select group#, status from v$log;

-- Força switch logfile
alter system switch logfile;

-- Força checkpoint
alter system checkpoint global;

-- Dropa grupo
alter database drop logfile group 3;

-- Adiciona grupo
alter database add logfile thread 1 group 1 ('C:\ORACLE\PRODUCT\10.2.0\ORADATA\ORCL\REDO0001.LOG') size 100m reuse;

-- Adiciona membros a grupos existentes
alter database add logfile member 'C:\ORACLE\PRODUCT\10.2.0\ORADATA\ORCL\REDO00031.LOG' to group 1;
