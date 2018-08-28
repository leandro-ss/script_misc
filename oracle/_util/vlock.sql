PROMPT
PROMPT ==> FUNÇÃO: EXIBE OS OBJETOS EM LOCK NA BASE DE DADOS
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
PROMPT AGUARDE...
SELECT
  S.LOCKWAIT,
  v.ORACLE_USERNAME,
  v.OS_USER_NAME,
  s.sid,
  s.serial#,
  a.OBJECT_NAME,
  s.status,
  s.fixed_table_sequence,
  a.object_type,
  s.TERMINAL,  
  to_char(s.logon_time,'DD/MM/YYYY HH24:MI:SS') LOGON_TIME,
  v.locked_mode
FROM
  v$locked_object v,
  dba_objects     a,
  v$session       s
WHERE
  a.OBJECT_ID  = v.OBJECT_ID AND
  s.SID        = v.SESSION_ID
ORDER BY
  a.OBJECT_NAME,
  s.logon_time
/
