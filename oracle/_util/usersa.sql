PROMPT
PROMPT ==> FUN��O: EXIBE OS USU�RIOS ATIVOS NA BASE
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
COL EVENT FORMAT A30
COL CONSISTENT_GETS FORMAT 999,999,990
COL PHYSICAL_READS FORMAT 999,999,990
COL BLOCK_GETS FORMAT 999,999,990
COL BLOCK_CHANGES FORMAT 999,999,990
SELECT
   S.SQL_HASH_VALUE,
   S.PREV_HASH_VALUE,
   S.USERNAME,
   S.OSUSER,
   S.SID,
   S.SERIAL#,
   P.SPID,
   ST3.VALUE CPU_USAGE,
   IO.CONSISTENT_GETS,
   IO.PHYSICAL_READS,
   IO.BLOCK_GETS,
   IO.BLOCK_CHANGES,
   ROUND(ST2.VALUE/1024/1024,2) PGA_MBYTES,
   ROUND(ST1.VALUE/1024/1024,2) UGA_MBYTES,
   W.EVENT,
   L.NAME LATCHNAME,
   S.STATUS,
   S.SERVER,
   S.MACHINE,
   S.MODULE,
   S.PROGRAM,
   TO_CHAR(S.LOGON_TIME,'DD/MM/YYYY HH24:MI:SS') LOGON,
   S.LAST_CALL_ET
FROM
   V$SESSION 		S,
   V$PROCESS 		P,
   V$SESSION_WAIT 	W,
   V$SESS_IO 		IO,
   V$LATCHNAME  	L,
   V$SESSTAT		ST1,
   V$SESSTAT		ST2,
   V$SESSTAT		ST3,
   V$STATNAME		STN1,
   V$STATNAME		STN2,
   V$STATNAME		STN3
WHERE
   S.SID 		= W.SID
   AND IO.SID      	= S.SID
   AND ST1.SID		= S.SID
   AND ST2.SID		= S.SID
   AND ST3.SID		= S.SID
   AND STN1.NAME	= 'session uga memory'
   AND STN2.NAME	= 'session pga memory'
   AND STN3.NAME	= 'CPU used by this session'
   AND ST1.STATISTIC#   = STN1.STATISTIC#
   AND ST2.STATISTIC#   = STN2.STATISTIC#
   AND ST3.STATISTIC#   = STN3.STATISTIC#
   AND S.USERNAME  	!= 'UNKNOWN'
   AND S.TYPE      	!= 'BACKGROUND'
   AND S.STATUS  	= 'ACTIVE'
   AND P.ADDR 		= S.PADDR
   AND W.P2   		= L.LATCH# (+)
ORDER  BY
	ST3.VALUE DESC, IO.CONSISTENT_GETS DESC, ROUND(ST2.VALUE/1024/1024,2) DESC
/