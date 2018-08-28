PROMPT
PROMPT ==> FUN��O: EXIBE A QUANTIDADE DE IO POR DATAFILE
PROMPT ==> DESENVOLVIDO POR DANILO MENDES
PROMPT
COL PHYRDS  FORMAT 999,999,999
COL PHYWRTS FORMAT 999,999,999
COL READTIM FORMAT 999,999,999
COL WRITETIM FORMAT 999,999,999
COL NAME FORMAT A50
SELECT
	D.TABLESPACE_NAME TABLESPACE,
	NAME,
	PHYRDS,
	PHYWRTS,
	READTIM,
	WRITETIM
FROM
	V$FILESTAT A,
	V$DBFILE B,
	DBA_DATA_FILES D
WHERE
	A.FILE# 	= B.FILE#
	AND D.FILE_NAME = B.NAME
ORDER  BY
	READTIM DESC
/