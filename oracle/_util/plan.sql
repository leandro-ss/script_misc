PROMPT
PROMPT ==> FUN��O: MOSTRA O PLANO DE EXECU��O
PROMPT
select * from TABLE(dbms_xplan.display_awr('&SQL_ID'));