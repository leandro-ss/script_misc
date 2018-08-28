PROMPT
PROMPT ==> FUNÇÃO: VERIFICA FALHAS NA REPLICAÇÃO DOS DADOS
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
PROMPT ===================================
PROMPT QUANTIDADE DE REGISTROS DA DEFERROR
PROMPT ===================================
select count(*) QTD from deferror;

PROMPT ===================================
PROMPT QUANTIDADE DE REGISTROS DA DEFTRAN
PROMPT ===================================
select count(*) QTD from deftran;

PROMPT ===================================
PROMPT QUANTIDADE DE REGISTROS DA DEFCALL
PROMPT ===================================
select count(*) QTD from defcall;

PROMPT ===================================
PROMPT ERROS DA REPCATLOG
PROMPT ===================================
select * from DBA_REPCATLOG;
PROMPT ===================================
PROMPT LIMPAR AS FALHAS DA REPLICACAO
PROMPT ===================================
PROMPT EXECUTAR @purge.sql
PROMPT 
PROMPT 