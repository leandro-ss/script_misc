spool shared_pool_reserved.log

select 'SHARED_RESERVED_SIZE;FREE_SPACE;FREE_PIECES;LARGEST_FREE_PIECE;USED_SPACE;USED_PIECES;LARGEST_USED_PIECE;MISSES;FAILURES_AFTER_FLUSH' extraction from dual;

select
trunc(p.value/1024/1024,2),
trunc(s.free_space/1024/1024,2),
s.free_count,'999999999990.00')),
trunc(s.max_free_size/1024/1024,2),
trunc(s.used_space/1024/1024,2),
s.used_count
trunc(s.max_used_size/1024/1024,2),
s.request_misses,
s.request_failures,
from v$parameter p, v$shared_pool_reserved s
where p.name = 'shared_pool_reserved_size';

spool off;

set termout on;
prompt *    shared_pool_reserved.log                                                  *
set termout off;
