select
 a.ksppinm "Parameter",
 b.ksppstvl "Session Value",
 c.ksppstvl "Instance Value"
from
 x$ksppi a, x$ksppcv b, x$ksppsv c
where a.indx = b.indx
and a.indx = c.indx
and a.ksppinm like '/_%' escape'/';
