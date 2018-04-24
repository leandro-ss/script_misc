PROMPT
PROMPT ==> FUN��O: EXIBE INFORMA��ES SOBRE OS BLOCOS DAS TABELAS ACIMA DA HWM
PROMPT ==> OBS: APENAS DADOS ONDE A QUANTIDADE DE MEGA BYTES LIVRES � MAIOR QUE 10
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
select
   owner,
   table_name,
   empty_blocks,
   round((blocks * 8192)/1024/1024,2) as "ESPA�O UTILIZADO MB",
   round((empty_blocks * 8192)/1024/1024,2) AS "MEGA BYTES ACIMA DA HWM"
from
   dba_tables
where
   owner not in ('SYS','SYSTEM','OUTLN')
   and empty_blocks > 0
   and (empty_blocks * 8192)/1024/1024 >= 10
order by
   5 desc
/