PROMPT ==> FUN��O: EXIBE INFORMA��ES SOBRE OS PRIVILEGIADOS SOBRE DETERMINADA TABELA, PROCEDURE, ETC
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT 
ACCEPT OBJECT PROMPT "DIGITE O NOME DO OBJETO...: "
SELECT
	*
FROM
	DBA_TAB_PRIVS
WHERE
	TABLE_NAME = UPPER('&OBJECT')
/
UNDEFINE OBJECT