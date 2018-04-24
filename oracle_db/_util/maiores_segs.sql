PROMPT
PROMPT ==> FUNÇÃO: EXIBE OS 10 MAIORES SEGMENTOS DA BASE
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
SELECT
   *
FROM
        (SELECT
    		TABLESPACE_NAME,
	        SEGMENT_NAME,
                SEGMENT_TYPE,
                OWNER,
                EXTENTS,
                ROUND(BYTES/1024/1024,2)
         FROM
                DBA_SEGMENTS
         WHERE
                OWNER NOT IN ('SYS','SYSTEM')
         ORDER BY
                BYTES DESC)
WHERE
        ROWNUM <= 10
/
