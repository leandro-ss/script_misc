PROMPT
PROMPT ==> FUNÇÃO: EXIBE INFORMAÇÕES SOBRE OS BLOCOS DAS TABELAS ACIMA DA HWM
PROMPT ==> OBS: APENAS DADOS ONDE A QUANTIDADE DE MEGA BYTES LIVRES É MAIOR QUE 10
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
select
   owner,
   table_name,
   empty_blocks,
   round((blocks * 8192)/1024/1024,2) as "ESPAÇO UTILIZADO MB",
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