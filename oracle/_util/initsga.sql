PROMPT
PROMPT ==> FUN��O: EXIBE OS PRINCIPAIS PAR�METROS DO ARQUIVO DE INCIALIZA��O
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
select name, value
from   v$parameter
where  name in ('sga_max_size','pga_aggregate_target','db_cache_size','shared_pool_size')
/
