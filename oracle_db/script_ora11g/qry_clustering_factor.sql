spool clustering_factor.log

select 'OWNER;INDEX;PARTITION;SUB_PARTITION;TYPE;STATUS;CLUSTERING_FACTOR;DISTINCT_KEYS;LEAF_BLOCKS;CLUSTERING_X_DISTINCT;CLUSTERING_X_LEAF' extraction from dual;

select * from (
select owner,index_name,partition,sub_partition,index_type,status,clustering_factor,distinct_keys,leaf_blocks,
       clustering_factor / distinct_keys,
       clustering_factor / leaf_blocks
  from (select owner, index_name, '' partition, '' sub_partition, index_type, status, leaf_blocks, clustering_factor, distinct_keys
          from dba_indexes
         union all
        select index_owner, index_name, partition_name, '' sub_partition, '' index_type, status, leaf_blocks, clustering_factor, distinct_keys
          from dba_ind_partitions
         union all
        select index_owner, index_name, partition_name, '' sub_partition, '' index_type, status, leaf_blocks, clustering_factor, distinct_keys
          from dba_ind_subpartitions)
         where distinct_keys > 0 and leaf_blocks > 0
            and owner not in ('SYS', 'SYSTEM', 'WMSYS', 'EXFSYS', 'CTXSYS', 'MDSYS', 'XDB', 'ORDDATA', 'ORDSYS', 'DBSNMP', 'OLAPSYS', 'SYSMAN')
            and clustering_factor / distinct_keys >= (20/100)
order by owner, index_name, partition, sub_partition);

spool off;

set termout on;
prompt *    clustering_factor.log
set termout off;

-- Melhor cenário quando "Clustering Factor" for o mais próximo possível de "Leaf Blocks"
-- Pior cenário quando "Clustering Factor" for o mais próximo possível de "Distinct Keys"
