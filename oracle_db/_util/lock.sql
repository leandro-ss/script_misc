PROMPT ==> FUNÇÃO: EXIBE OS OBJETOS EM LOCK NA BASE DE DADOS E QUEM ESTA LOCKANDO/LOCKADO
PROMPT ==> OBS:    EXIBE INFORMACOES APENAS SE EXISTIREM USUARIOS LOCKANDO OUTROS USUARIOS
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
col waiting_for_session 	format a19
col lock_action 		format a11
col logon_time			format a19
col object			format a50
PROMPT
PROMPT AGUARDE...
select
	decode(s.lockwait,null,'Locking','Locked') 		lock_action,
	s.lockwait,
	w.session_id,
	s.serial#,
	decode(h.session_id,w.session_id,null,h.session_id)	waiting_for_session,
	v.oracle_username,
	v.os_user_name,
	a.owner||'.'||a.object_name				object,
	s.status,
	a.object_type,
	s.terminal,
	to_char(s.logon_time,'dd/mm/yyyy hh24:mi:ss') 		logon_time,
	v.xidusn						undo_segment_number,
	v.xidslot						slot_number,
	v.xidsqn						sequence_number,
	v.locked_mode
from
	v$locked_object v,
	dba_objects     a,
	v$session       s,
	dba_locks w,
	dba_locks h
where
	a.object_id  		= 	v.object_id
  	and  s.sid        	= 	v.session_id
  	and  s.sid        	= 	w.session_id
	and  h.mode_held      	!=  	'None'
	and  h.mode_held      	!=  	'Null'
	and  w.lock_type       	=  	h.lock_type
	and  w.lock_id1        	=  	h.lock_id1
	and  w.lock_id2        	=  	h.lock_id2
	and  h.blocking_others	= 	'Blocking'
order by
	decode(s.lockwait,null,'Locking','Locked') desc, owner, object_name
;
