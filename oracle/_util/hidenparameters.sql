PROMPT
PROMPT ==> FUNÇÃO: EXIBE INFORMAÇÕES SOBRE PARAMETROS NAO-DOCUMENTADOS DA BASE DE DADOS
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> OBS: Alterar a clausula WHERE para verificar outros parametros
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
COLUMN parameter           FORMAT a37
COLUMN description         FORMAT a80
COLUMN "Session VALUE"     FORMAT a20
COLUMN "Instance VALUE"    FORMAT a20
SELECT
   a.ksppinm  "Parameter",
   a.ksppdesc "Description",
   b.ksppstvl "Session Value",
   c.ksppstvl "Instance Value"
FROM
   x$ksppi a,
   x$ksppcv b,
   x$ksppsv c
WHERE
   a.indx = b.indx
   AND
   a.indx = c.indx
   AND
   a.ksppinm in ('_optimizer_cost_based_transformation','_gby_hash_aggregation_enabled','_new_initial_join_orders')

/