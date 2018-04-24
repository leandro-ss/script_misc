spool table_fragmentation.log

select 'OWNER;TABLE;PARTITION;SUB_PARTITION;ACTUAL;EXPECTED;REDUCTION;REDUCTION_PERC' extraction from dual;
select * from (
select owner,table_name,partition,sub_partition,
       actual_size,
       expected_size,
       reduction_size,
       reduction_perc
  from (select * from (select owner, table_name, '' partition, '' sub_partition,
                              round((blocks*8/1024),2) actual_size, round((num_rows*avg_row_len/1024/1024),2) expected_size,
                              round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2) reduction_size,
                              ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 reduction_perc
                         from dba_tables
                        where num_rows > 0)
         union all
        select * from (select table_owner, table_name, partition_name, '' sub_partition,
                              round((blocks*8/1024),2) actual_size, round((num_rows*avg_row_len/1024/1024),2) expected_size,
                              round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2) reduction_size,
                              ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 reduction_perc
                         from dba_tab_partitions
                        where num_rows > 0)
         union all
        select * from (select table_owner, table_name, partition_name, subpartition_name,
                              round((blocks*8/1024),2) actual_size, round((num_rows*avg_row_len/1024/1024),2) expected_size,
                              round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2) reduction_size,
                              ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 reduction_perc
                         from dba_tab_subpartitions
                        where num_rows > 0))
 where owner not in ('SYS', 'SYSTEM', 'WMSYS', 'EXFSYS', 'CTXSYS', 'MDSYS', 'XDB', 'ORDDATA', 'ORDSYS', 'DBSNMP', 'OLAPSYS', 'SYSMAN')
   and reduction_perc >= 20
   and actual_size > 1
   order by owner, table_name, partition, sub_partition);

spool off;

set termout on;
prompt *    table_fragmentation.log
set termout off;
