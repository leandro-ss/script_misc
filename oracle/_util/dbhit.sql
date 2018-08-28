col phys     format 999,999,999 heading 'Physical Reads'
col gets     format 999,999,999 heading 'Db Block Gets'
col con_gets format 999,999,999 heading 'Consistent Gets'
col hitratio format 999.99 heading ' Hit Ratio '
PROMPT
PROMPT ==> FUNÇÃO: MOSTRA A RAZÃO DE ACERTO DO CACHE DO BANCO DE DADOS
select
	sum(decode(name,'physical reads',value,0)) phys,
       	sum(decode(name,'db block gets',value,0)) gets,
        sum(decode(name,'consistent gets',value,0)) con_gets,
        (1 - (sum(decode(name,'physical reads',value,0))/
             (sum(decode(name,'db block gets',value,0)) +
              sum(decode(name,'consistent gets',value,0))))) * 100 hitratio
from
	v$sysstat
/
