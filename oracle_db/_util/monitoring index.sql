Pessoal,

Não sei se todos conhecem, então.....

Visando identificar indexes que não estão sendo utilizados com assertividade podemos utilizar a monitoração de uso. Seguem os comandos:

ALTER INDEX index MONITORING USAGE;

Ou

ALTER INDEX index NOMONITORING USAGE;


Para visualizar o uso:

SELECT index_name,
       table_name,
       monitoring,
       used,
       start_monitoring,
       end_monitoring
FROM   v$object_usage
--WHERE  index_name = 'MY_INDEX_I'
ORDER BY index_name;

INDEX_NAME                     TABLE_NAME                     MON USE START_MONITORING    END_MONITORING
------------------------------ ------------------------------ --- --- ------------------- -------------------
IDX01_TMNEGOCIO_SS             TMNEGOCIO_SISTEMA_SERVIDOR     YES NO  09/18/2013 15:07:48
IDX02_TMNEGOCIO_SS             TMNEGOCIO_SISTEMA_SERVIDOR     YES NO  09/18/2013 15:07:47
IDX03_TMNEGOCIO_SS             TMNEGOCIO_SISTEMA_SERVIDOR     YES NO  09/18/2013 15:07:47
IDX04_TMNEGOCIO_SS             TMNEGOCIO_SISTEMA_SERVIDOR     YES NO  09/18/2013 15:07:47
IDX05_TMNEGOCIO_SS             TMNEGOCIO_SISTEMA_SERVIDOR     YES NO  09/18/2013 15:07:47
IDX07_TMNEGOCIO_SS             TMNEGOCIO_SISTEMA_SERVIDOR     YES NO  09/18/2013 15:07:47
UK01_TMNEGOCIO_SIST_SERVIDOR   TMNEGOCIO_SISTEMA_SERVIDOR     YES NO  09/18/2013 15:07:47

Com essa ferramenta, elimina-se o risco de dropar um índice que é utilizado. Além disso, pode-se eliminar significante utilização de CPU e I/O, que podem causar menor desempenho em sistemas que realizam grande quantidade de operações de escrita.

[]s,