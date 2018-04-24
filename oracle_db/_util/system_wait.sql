PROMPT
PROMPT ==> FUNÇÃO: EXIBE INFORMAÇÕES SOBRE OS WAITS DO SISTEMA
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
select 
	event, 
	total_waits, 
	total_timeouts, 
	time_waited, 
	average_wait
from 
	v$system_event
order by 
	time_waited desc
/