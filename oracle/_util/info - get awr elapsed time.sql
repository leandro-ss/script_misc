select dbid, instance_number, ceil((substr(flush_elapsed,11,2)*60 + substr(flush_elapsed,14,2))/2)*2, count(*)
from dba_hist_snapshot group by dbid, instance_number, ceil((substr(flush_elapsed,11,2)*60 + substr(flush_elapsed,14,2))/2)*2