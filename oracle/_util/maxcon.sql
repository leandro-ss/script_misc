PROMPT
PROMPT ==> FUN��O: EXIBE AS MAIORES CONSULTAS DO BANCO DE DADOS
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
SELECT 
	B.USERNAME USERNAME,
	A.DISK_READS READS,
	A.EXECUTIONS EXECUTIONS,
	A.DISK_READS/DECODE(A.EXECUTIONS,0,1,A.EXECUTIONS) READS_EXECUTIONS_RATIO,
	A.SQL_TEXT STATEMENT
FROM
	V$SQLAREA A,
	DBA_USERS B
WHERE   
	A.PARSING_USER_ID = B.USER_ID 
AND	A.DISK_READS > 100000
ORDER BY
	A.DISK_READS DESC
/
