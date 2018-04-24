PROMPT
PROMPT ==> FUNÇÃO: PGA ADVICE
PROMPT
--------------------------------------------------------------------------------------------
                                      -- PGA ADVICE
--------------------------------------------------------------------------------------------
--sqlplus -s -m "HTML ON TABLE 'BORDER="2"'" O3181777/inmtim#0212@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.112.34.53)(PORT=1534)))(CONNECT_DATA=(SID=PREPP1)))' @pga_advice.sql>pga_advice.html

SET LINESIZE 150 PAGESIZE 300
COLUMN C1 HEADING 'TARGET(M)'
COLUMN C2 HEADING 'TARGET|FACTOR'
COLUMN C3 HEADING 'PROCESSED (M)'
COLUMN c4 heading 'Estimated|Extra Mb RW'
COLUMN c5 heading 'Estimated|Cache Hit %'
column c6 heading 'Estimated|Over-Alloc.'
SELECT Round(PGA_TARGET_FOR_ESTIMATE/1024/1024)         c1,
       ROUND(PGA_TARGET_FACTOR,2)                       c2,
       Round(BYTES_PROCESSED/1024/1024,2)               c3,
       Round(ESTD_EXTRA_BYTES_RW/1024/1024,2)           c4,
       ESTD_PGA_CACHE_HIT_PERCENTAGE                    c5,
       ESTD_OVERALLOC_COUNT                             c6
FROM V$PGA_TARGET_ADVICE;


PROMPT
PROMPT ==> FUNÇÃO: SHARED POOL ADVICE
PROMPT
--sqlplus -s -m "HTML ON TABLE 'BORDER="2"'" O3181777/inmtim#0212@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.112.34.53)(PORT=1534)))(CONNECT_DATA=(SID=PREPP1)))' @db_cache.sql>db_cache.html
SET numwidth 15
set lines 300
set pages 999
column c1     heading 'Pool |Size(M)'
column c2     heading 'Size|Factor'
column c3     heading 'Est|LC(M)  '
column c4     heading 'Est LC|Mem. Obj.'
column c5     heading 'Est|Time|Saved|(sec)'
column c6     heading 'Est|Parse|Saved|Factor'
COLUMN c7     heading 'Est|Parse|Time'
COLUMN c8     heading 'Est|Parse|Factor'
column c9     heading 'Est|Object Hits'   format 999,999,999,999
SELECT shared_pool_size_for_estimate c1,
              shared_pool_size_factor c2,
              estd_lc_size c3,
              estd_lc_memory_objects c4,
              estd_lc_time_saved c5,
              estd_lc_time_saved_factor c6,
              ESTD_LC_LOAD_TIME c7,
              ESTD_LC_LOAD_TIME_FACTOR c8,
              estd_lc_memory_object_hits c9
              FROM V$SHARED_POOL_ADVICE;

PROMPT
PROMPT ==> FUNÇÃO: DB CACHE ADVICE
PROMPT
SET pages 600
SET lines 150
column c1   heading 'Cache Size (meg)'      format 999,999,999,999
column c4   heading 'Estimate Physical Reads' format 999,999,999,999
column c2   heading 'Buffers for Estimate'  format 999,999,999,999
COLUMN c3   heading 'Physical Reads Factor'
COLUMN c5   heading 'Size Factor'
select
   size_for_estimate          c1,
   size_factor                c5,
   buffers_for_estimate       c2,
   estd_physical_read_factor  c3,
   estd_physical_reads        c4
from
   v$db_cache_advice
--where   name = 'DEFAULT'
and
   block_size  = (SELECT value FROM V$PARAMETER
                   WHERE name = 'db_block_size')
and
   advice_status = 'ON'
/
