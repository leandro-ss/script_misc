--sqlplus -s -m "HTML ON TABLE 'BORDER="2"'" O3181777/inmtim#0212@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.112.34.53)(PORT=1534)))(CONNECT_DATA=(SID=PREPP1)))' @db_cache.sql>db_cache.html
SET numwidth 15
set lines 150
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
