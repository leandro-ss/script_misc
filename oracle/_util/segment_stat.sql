SET lines 300 pages 600
COLUMN STATISTIC_NAME format a30
column value format 999,999,999,999,999
select *
from
  (select statistic_name,
     st.owner,
     st.obj#,
     st.object_type,
     st.object_name,
     st.value,
     dense_rank() over(partition by statistic_name
   order by st.value desc) rnk
   from v$segment_statistics st)
where rnk < = 10
 and statistic_name in ('logical reads', 'physical reads');
