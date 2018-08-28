select 
	Username,
	OSUSER,
	Consistent_Gets,
	Block_Gets,
	Physical_Reads,
	100*( Consistent_Gets + Block_Gets - Physical_Reads)/
	( Consistent_Gets + Block_Gets ) "Hit Ratio %"
from 
	V$SESSION,
	V$SESS_IO
where 
	V$SESSION.SID = V$SESS_IO.SID
	and ( Consistent_Gets + Block_Gets )>0
	and username is not null
	and status = 'ACTIVE'
order by 
	Username,"Hit Ratio %"
/