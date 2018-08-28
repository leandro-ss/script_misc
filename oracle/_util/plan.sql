PROMPT
PROMPT ==> FUNÇÃO: MOSTRA O PLANO DE EXECUÇÃO
PROMPT
select * from TABLE(dbms_xplan.display_awr('&SQL_ID'));