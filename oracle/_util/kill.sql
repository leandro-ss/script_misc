PROMPT
PROMPT ==> FUN��O: CRIA COMANDO PARA MATAR OS USU�RIOS INATIVOS
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
UNDEFINE USER
SELECT
	USERNAME,
	OSUSER,
	STATUS,
	'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#||''';'
FROM
	V$SESSION
WHERE
	USERNAME = DECODE('&&USER','*',USERNAME,'&USER')
AND
	STATUS NOT IN ('ACTIVE','KILLED')
ORDER BY
	USERNAME, OSUSER
/
UNDEFINE USER