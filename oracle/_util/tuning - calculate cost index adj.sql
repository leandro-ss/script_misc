select
a.average_wait full_wait,
b.average_wait index_wait,
trunc(a.total_waits /(a.total_waits + b.total_waits), 2) full_percent,
trunc(b.total_waits /(a.total_waits + b.total_waits), 2) index_percent,
trunc((b.average_wait / a.average_wait) * 100, 2) estimated_value
from
v$system_event a,
v$system_event b
where a.event = 'db file scattered read'
and b.event = 'db file sequential read';