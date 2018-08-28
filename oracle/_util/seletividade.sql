column sum for 9999999999 head 'Total #| Rows'
column cnt for 999999  head 'Total #| Dist Values'
column min for 999999  head 'Min #| of Rows'
column avg for 999999  head 'Avg #| of Rows'
column max for 999999  head 'Max #| of Rows'
column bsel for 999999.99  head 'Best|Selectivity [%]'
column asel for 999999.99  head 'Avg|Selectivity [%]'
column wsel for 999999.99 head 'Worst|Selectivity [%]'
select sum(a) sum,
count(a) cnt,
min(a) min,
round(avg(a),1) avg,
max(a) max,
round(min(a)/sum(a)*100,2) bsel,
round(avg(a)/sum(a)*100,2) asel,
round(max(a)/sum(a)*100,2) wsel
from (select count(*) a from TB_EMPRESA group by CD_CNPJ_RAIZ);