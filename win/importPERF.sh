#!/bin/bash

#NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.WE8ISO8859P1'; export NLS_LANG

if [ $1 == "true" ]; then
sqlplus -s  lessilva/Mokona69@CAPLANP1 <<EOF 1> /dev/null
drop table METRIC_DATA; drop table METRIC_DATA_TMP;
exit 
EOF
fi

sqlplus -s  lessilva/Mokona69@CAPLANP1 <<EOF 1> /dev/null
create table METRIC_DATA (  COLLECT_DATE DATE, METRIC_NAME VARCHAR2(128), VALUE NUMBER, IMPORT_DATE DATE); 
create table METRIC_DATA_TMP ( COLLECT_DATE DATE, METRIC_NAME  VARCHAR2(128), VALUE NUMBER, IMPORT_DATE  DATE );
exit 
EOF

# Verifica arquivos disponíveis
for FILE_NAME in `ls *.csv` ; do

    # Conta quantidade de colunas do arquivo
    comma_count=`head -n1 $FILE_NAME | tr -cd "," | wc -c`


    comma_count=`expr $comma_count + 1`


    echo "LOAD DATA"                                                                  >  mapping_tmp.ctl
    echo "  INFILE 'perfmon_loader.sql'"                                              >> mapping_tmp.ctl
    echo "  APPEND"                                                                   >> mapping_tmp.ctl
    echo "  INTO TABLE METRIC_DATA_TMP"                                               >> mapping_tmp.ctl
    echo "  FIELDS TERMINATED BY ';'"                                                 >> mapping_tmp.ctl
    echo "  OPTIONALLY ENCLOSED BY '\"'"                                              >> mapping_tmp.ctl
    echo "  TRAILING NULLCOLS"                                                        >> mapping_tmp.ctl
    echo "  (                                "                                        >> mapping_tmp.ctl
    echo "     COLLECT_DATE \"to_date(:COLLECT_DATE,'mm/dd/yyyy hh24:mi:ss____')\", " >> mapping_tmp.ctl
    echo "     METRIC_NAME,"                                                          >> mapping_tmp.ctl
    echo "     VALUE \"to_number(nvl(trim(:VALUE),0))\""                              >> mapping_tmp.ctl
    echo "  )"                                                                        >> mapping_tmp.ctl

    # Cria arquivo para a carga SQL*Loader
    for i in `seq 2 $comma_count` ; do
      eval awk -F"," \'{ if\(NR==1\) metric\=\$$i\; else print \"\"\$1\"\;\"metric\"\;\"\$$i }\' $FILE_NAME >> perfmon_loader.sql
    done

    # Importa perfmon via SQL*Loader
    export NLS_NUMERIC_CHARACTERS=.,
    sqlldr lessilva/Mokona69@CAPLANP1 control=mapping_tmp.ctl log=$FILE_NAME.log bad=$FILE_NAME.bad direct=true bindsize=10485760 readsize=10485760 errors=1000000

    # Cria script para executar merge
    echo "BEGIN "                                                                             >  perfmon_merge.sql
    echo "  MERGE INTO METRIC_DATA TGT "                                                      >> perfmon_merge.sql
    echo "  USING(SELECT DISTINCT COLLECT_DATE, METRIC_NAME, TRUNC(VALUE,2) AS VALUE,"        >> perfmon_merge.sql
    echo "        TRUNC(SYSDATE) AS IMPORT_DATE FROM METRIC_DATA_TMP) SRC"                    >> perfmon_merge.sql
    echo "    ON (TGT.COLLECT_DATE = SRC.COLLECT_DATE AND TGT.METRIC_NAME = SRC.METRIC_NAME)" >> perfmon_merge.sql
    echo "  WHEN MATCHED THEN"                                                                >> perfmon_merge.sql
    echo "    UPDATE SET TGT.VALUE = SRC.VALUE, TGT.IMPORT_DATE = SRC.IMPORT_DATE"            >> perfmon_merge.sql
    echo "  WHEN NOT MATCHED THEN"                                                            >> perfmon_merge.sql
    echo "    INSERT VALUES (SRC.COLLECT_DATE, SRC.METRIC_NAME, SRC.VALUE, SRC.IMPORT_DATE);" >> perfmon_merge.sql
    echo "  COMMIT;"                                                                          >> perfmon_merge.sql
    echo "END;"                                                                               >> perfmon_merge.sql
    echo "/"                                                                                  >> perfmon_merge.sql

# Insere a métrica na base
sqlplus -s  lessilva/Mokona69@CAPLANP1 <<EOF 1> /dev/null
set pages 0; set feedback off; set serveroutput on;
@perfmon_merge.sql;
commit;
truncate table metric_data_tmp;
alter table metric_data_tmp move;
exit
EOF

    # Remove arquivo temporário
    rm -rf $FILE_NAME
    rm -rf perfmon_loader.sql
    rm -rf perfmon_merge.sql
    rm -rf mapping_tmp.ctl

done
