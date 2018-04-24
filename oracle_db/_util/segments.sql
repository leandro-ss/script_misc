PROMPT
PROMPT ==> FUNÇÃO: EXIBE OS SEGMENTOS QUE ULTRAPASSAM 50% DO SEU TAMANHO MÁXIMO
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
select owner,
       segment_type,
       segment_name,
       tablespace_name,	
       initial_extent/1024/1024 initial_extent,
       next_extent/1024/1024 next_extent,
       extents,
       max_extents,
       bytes/1024/1024 bytes
from   
	dba_segments
where  
	extents > .5 * max_extents
/
