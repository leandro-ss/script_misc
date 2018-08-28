-- Baseado no Note:387077.1

select spid, program from v$process 
    where program!= 'PSEUDO'
    and addr not in (select paddr from v$session)
    and addr not in (select paddr from v$bgprocess);