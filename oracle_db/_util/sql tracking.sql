
select to_char(snap.end_interval_time,'dd/mm/yyyy hh24:mi:ss') snap_time, sqls.instance_number, sqls.sql_id, sqls.parsing_schema_name,
       elapsed_time_delta/1000000 elapsed_time, buffer_gets_delta, cpu_time_delta/1000000 cpu_time
  from sys.dba_hist_sqlstat sqls, sys.dba_hist_snapshot snap
 where sqls.dbid = snap.dbid and sqls.snap_id = snap.snap_id and sqls.instance_number = snap.instance_number
   and trunc(snap.end_interval_time) >= to_date('20120901','yyyymmdd') and trunc(snap.end_interval_time) <= to_date('20121130','yyyymmdd')
   and sqls.sql_id in ('gjfy6340m9k3d','cgd1x741hd2g3','7akf6xvjp5a6d','c5y7us9fqxz89','d15cdr0zt3vtp','606pqszyh1gsk','b7v2whcz3w2w7',
                       '2q31vy8c9vj6t','6r75f7k88qr4a','fw0p80jazdgks','0k8522rmdzg4k','cm5vu20fhtnq1','74jp9b3h4krhd','d3apnz76qwmrs',
                       '30hy59nc21g04','cb21bacyh3c7d','b6y9wkhxv1puz','2n1hu6d1pmvtw','7akf6xvjp5a6d','b7v2whcz3w2w7','0vd64yqsvu6tv',
                       '4vs91dcv7u1p6','0fg0zwkrjdazp','6r75f7k88qr4a','2g5uj91yrkz56','59v4zh1ac3v2a','0k8522rmdzg4k','bu5fpwaswtsh2',
                       'c6ksc6kfhjjc6','f711myt0q6cma','cm5vu20fhtnq1','d3apnz76qwmrs','ftvqca3ufkywk','b6y9wkhxv1puz','cb21bacyh3c7d',
                       '74jp9b3h4krhd','30hy59nc21g04','2n1hu6d1pmvtw')
