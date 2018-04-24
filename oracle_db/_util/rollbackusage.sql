PROMPT
PROMPT ==> FUNÇÃO: EXIBE A UTILIZAÇÃO DOS SEGMENTOS DE ROLLBACK POR USUÁRIO
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
select
  a.username,
  a.osuser,
  a.machine,
  a.sid,
  a.serial#,
  c.used_ublk,
  c.used_urec,
  round(c.used_ublk * p.value / 1024 / 1024,2) mb_used,
  b.segment_name,
  b.tablespace_name
from
  v$parameter p,
  v$session a,
  dba_rollback_segs b,
  v$transaction c
where
  p.name       = 'db_block_size' and
  b.segment_id = c.xidusn        and
  a.taddr      = c.addr
order by
  c.used_ublk desc
/
