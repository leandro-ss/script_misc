PROMPT
PROMPT ==> FUNÇÃO: EXIBE OS SEGMENTOS QUE ESTÃO ACIMA DE UM VALOR X NO DATAFILE
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
ACCEPT TABLESPACE_ PROMPT 'DIGITE O NOME DO TABLESPACE ........................................: '
ACCEPT MB_         PROMPT 'ENTRE COM O VALOR MÁXIMO PARA O TAMANHO DO DATAFILE EM MEGA BYTES ..: '
SELECT 
	DISTINCT owner, 
	segment_name, 
	segment_type, 
	tablespace_name, 
	file_id
FROM 
	dba_extents
WHERE 
	((block_id+1)*(SELECT value FROM v$parameter WHERE UPPER(name)='DB_BLOCK_SIZE')+BYTES) > &MB_*1024*1024
	AND tablespace_name='&TABLESPACE_'
ORDER BY 
	file_id, owner, segment_name, segment_type
/
