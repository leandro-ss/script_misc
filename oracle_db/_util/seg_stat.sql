SET lines 300 pages 600
COLUMN STATISTIC_NAME format a30
column object_name format a50
column object_type format a40
column reads format 999,999,999,999,999
SELECT *
FROM
  (SELECT t1.* ,
    dense_rank() over (partition BY statistic_name order by t1.reads DESC) rnk
  FROM
    (SELECT 'physical reads' AS statistic_name,
      owner,
      object_name,
      object_type,
      reads
    FROM
      (SELECT *
      FROM
        (SELECT 'ultimos_30_dias' AS ultimos_30_dias,
          o.OWNER ,
          o.OBJECT_NAME ,
          o.OBJECT_TYPE ,
          SUM(physical_reads_delta) reads
        FROM dba_hist_seg_stat hist ,
          dba_hist_snapshot awr,
          DBA_OBJECTS o
        WHERE hist.snap_id          =awr.snap_id
        AND hist.OBJ#               = o.OBJECT_ID
        AND awr.BEGIN_INTERVAL_TIME > SYSDATE - 30
        GROUP BY o.OWNER ,
          o.OBJECT_NAME ,
          o.OBJECT_TYPE
        )
      )
    UNION ALL
    SELECT 'logical reads' AS statistic_name,
      owner,
      object_name,
      object_type,
      reads
    FROM
      (SELECT *
      FROM
        (SELECT 'ultimos_30_dias' AS ultimos_30_dias,
          o.OWNER ,
          o.OBJECT_NAME ,
          o.OBJECT_TYPE ,
          SUM(logical_reads_delta) reads
        FROM dba_hist_seg_stat hist ,
          dba_hist_snapshot awr,
          DBA_OBJECTS o
        WHERE hist.snap_id          =awr.snap_id
        AND hist.OBJ#               = o.OBJECT_ID
        AND awr.BEGIN_INTERVAL_TIME > SYSDATE - 30
        GROUP BY o.OWNER ,
          o.OBJECT_NAME ,
          o.OBJECT_TYPE
        )
      )
    )t1
  )
WHERE rnk < 10;