select T.TABLESPACE_NAME, T.BYTES_USED/1024/1024 AS USED_MB, T.BYTES_FREE/1024/1024 AS FREE_MB, (select SUM(df.BYTES/1024/1024)
from dba_temp_files df, v$temp_space_header t
where t.tablespace_name=df.tablespace_name) as TOTAL_MB
FROM V$TEMP_SPACE_HEADER t;

