PROMPT
PROMPT ==> FUNÇÃO: INFORMACOES DA TABELA
PROMPT
select t.table_name, t.last_analyzed, num_rows, s.bytes/1024/1024 as tamanho_mb
from
	dba_tables t, dba_segments s
  WHERE
    t.table_name=s.segment_name
      AND t.table_name='&Table_Name'
/