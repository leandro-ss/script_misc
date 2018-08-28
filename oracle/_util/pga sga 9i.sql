select to_char(snap.snap_time,'dd/mm/yyyy hh24:mi:ss')||';'||to_char(snap.instance_number)||';'||nvl2(sgas.pool,sgas.pool, sgas.name)||';'||
to_char(sum(case when sgas.name like '%free memory%' then 0 else sgas.bytes end)/1024/1024,'999990.00')||';'||
to_char(sum(case when sgas.name like '%free memory%' then sgas.bytes else 0 end)/1024/1024,'999990.00')
from stats$sgastat sgas, stats$snapshot snap
where sgas.snap_id = snap.snap_id
and trunc(snap.snap_time) >= to_date('20130901','yyyymmdd')
and trunc(snap.snap_time) <= to_date('20130915','yyyymmdd')
group by snap.snap_time,snap.instance_number,nvl2(sgas.pool,sgas.pool, sgas.name);


    select to_char(snap.snap_time,'dd/mm/yyyy hh24:mi:ss')||';'||
    to_char(snap.instance_number)||';'||pgas.name||';'||
    to_char(sum(pgas.value)/1024/1024,'999990.00')
      from stats$pgastat pgas, stats$snapshot snap
     where snap.instance_number = pgas.instance_number
       and trunc(snap.snap_time) >= to_date('20130901','yyyymmdd')
       and trunc(snap.snap_time) <= to_date('20130915','yyyymmdd')
       and pgas.snap_id = snap.snap_id
       and pgas.name in
           ('total PGA allocated', 'total PGA inuse')
     group by snap.snap_time, snap.instance_number, pgas.name;