PROMPT
PROMPT ==> FUN��O: EXIBE INFORMA��ES SOBRE OS PRIVIL�GIOS DE UM USU�RIO/ROLE SOBRE TABELAS, PROCEDURES, ETC.
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
ACCEPT ROLEUSER PROMPT "DIGITE O NOME DO USU�RIO OU ROLE...: "
SELECT
	*
FROM
	DBA_TAB_PRIVS
WHERE
	GRANTEE = UPPER('&ROLEUSER')
/
UNDEFINE ROLEUSER