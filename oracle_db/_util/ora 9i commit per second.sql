
select sy.snap_id, ss.snap_time, trunc((sy.value - lag(sy.value,1)
over (partition by sy.dbid order by ss.snap_time))/(30*60)) as commit_per_second
from stats$sysstat sy, stats$snapshot ss
where sy.statistic# = 4
and sy.snap_id = ss.snap_id
and ss.snap_time between to_date('25/07/2011','dd/mm/yyyy')
and to_date('29/07/2011','dd/mm/yyyy')
