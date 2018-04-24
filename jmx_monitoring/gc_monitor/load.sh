#!/usr/bin/ksh

set -x
cd . ./.profile

# pega no fqdn pela linha de comando
FQDN="$1"

# diretorio remoto de onde extrair os dados
ACL_REMOTE_HOME="$2"

# prefixo logs http para o grep
PREFIX="$3"

# sufixo para os arquivos de saida
SUFFIX="$4"

# diretorio local
ACL_LOCAL_HOME="$5"

# sufixo para definição de arquivos zips
SUFFIX_GZIP="gz"

# pega o hostname remoto
REMOTE_HOSTNAME="${echo $FQDN | sed 's/\([A-z]*\).*/\L\1/g'}"

# arquivos de contagem
FLE_CNT_ANT=${ACL_LOCAL_HOME}/$REMOTE_HOSTNAME"_"$SUFFIX"_ANT.cnt"
FLE_CNT_ATL=${ACL_LOCAL_HOME}/$REMOTE_HOSTNAME"_"$SUFFIX"_ATL.cnt"

# arquivos de controle 
FLE_AWK=${ACL_LOCAL_HOME}/$REMOTE_HOSTNAME"_"$SUFFIX".awk"
ACL_CTL=${ACL_LOCAL_HOME}/$REMOTE_HOSTNAME"_"$SUFFIX".ctl"
ACL_LOG=${ACL_LOCAL_HOME}/$REMOTE_HOSTNAME"_"$SUFFIX".log"

# Home do usuário
FLE_TMP=$SUFFIX"_gc_tmp.log"

touch "$FLE_CNT_ATL" 
touch "$FLE_CNT_ANT"

echo "`date '+%Y-%m-%d %T'` Iniciando Conexão $REMOTE_HOSTNAME";

ssh scap01@$FQDN "awk -v r=0 '{if(FNR==1 && NR!=1) print r; else r = FILENAME\"|\"FNR\"|\"\$0;}END{print FILENAME\"|\"FNR\"|\"\$0;}' $ACL_REMOTE_HOME/$PREFIX*" > "$FLE_CNT_ATL"

# pega lista de logs do host remoto
for arquivo in $(ssh scap01@$FQDN "find $ACL_REMOTE_HOME -maxdepth 1 | grep -i $PREFIX"); do

  #Carregando numero da ult linha lida
  ult_linha_anterior="$(awk -v ARQUIVO="$arquivo" 'BEGIN {FS="\\|"} { if ( ARQUIVO==$1) print $2}' $FLE_CNT_ANT)"

    #Condição para o caso do arquivo ainda não estar presente na listagem anterior
  [ -z "$ult_linha_anterior" ] && ult_linha_anterior=0  

  #Carregando numero da ult linha lida
  ult_linha_atual="$(awk -v ARQUIVO="$arquivo" 'BEGIN {FS="|"} { if ( ARQUIVO==$1) print $2}' $FLE_CNT_ATL)"
  
  if [ $ult_linha_anterior -ne 0 ] && [ $ult_linha_atual -ge $ult_linha_anterior ]; then
  
    ult_texto_anterior="$(awk -v ARQUIVO="$arquivo" 'BEGIN {FS="|"} { if ( ARQUIVO==$1) print $3}' $FLE_CNT_ANT)"
    
    if [ $(ssh scap01@$FQDN "tail -$ult_linha_anterior | head -1") -eq $ult_texto_anterior ]; then

        #Calcula a diferença na quantidade de linhas
        numero_linha="$(expr $ult_linha_atual - $ult_linha_anterior)"
        #Gera um arquivo auxiliar para utilização em transferência posterior
        ssh scap01@$FQDN "tail -n $numero_linha $arquivo > ~/$FLE_TMP"
        #Realiza a transferencia com um nível de compactação pré-definido
        scp -C scap01@$FQDN:~/$FLE_TMP $ACL_LOCAL_HOME/$REMOTE_HOSTNAME

    else

        #Realiza a transferencia com um nível de compactação pré-definido
        scp -C scap01@$FQDN:$arquivo $ACL_LOCAL_HOME/$REMOTE_HOSTNAME   
        
    fi
 
  elif [ $ult_linha_atual -lt $ult_linha_anterior ]; then
  
    #Realiza a transferencia com um nível de compactação pré-definido
    scp -C scap01@$FQDN:$arquivo $ACL_LOCAL_HOME/$REMOTE_HOSTNAME  
  
  fi
done

cat "$FLE_CNT_ATL" > "$FLE_CNT_ANT"

echo "`date '+%Y-%m-%d %T'` $REMOTE_HOSTNAME: Parseando logs $ACL_LOCAL_HOME/$REMOTE_HOSTNAME"

echo ' ###### SCRIPT PARA COLETA DE GC SOB ALGORITMO SREIAL - TESTADO EM HOSTSPOT JDK6 ###### ' > "${FLE_AWK_SERIAL}"
echo 'BEGIN{ OFS=";";}'                                                                        >> "${FLE_AWK_SERIAL}"
echo '{'                                                                                       >> "${FLE_AWK_SERIAL}"
echo ''                                                                                        >> "${FLE_AWK_SERIAL}"
echo '   match( $0,/OC#[0-9]+|YC#[0-9]+/, arr);'                                               >> "${FLE_AWK_SERIAL}"
echo ''                                                                                        >> "${FLE_AWK_SERIAL}"
echo '   gsub("Jan","01");    gsub("Feb","02");    gsub("Mar","03");    gsub("Apr","04");'     >> "${FLE_AWK_SERIAL}"
echo '   gsub("May","05");    gsub("Jun","06");    gsub("Jul","07");    gsub("Aug","08");'     >> "${FLE_AWK_SERIAL}"
echo '   gsub("Sep","09");    gsub("Oct","10");    gsub("Nov","11");    gsub("Dec","12");'     >> "${FLE_AWK_SERIAL}"
echo ''                                                                                        >> "${FLE_AWK_SERIAL}"
echo '   gsub("[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#"," ");'                                 >> "${FLE_AWK_SERIAL}"
echo ''                                                                                        >> "${FLE_AWK_SERIAL}"
echo '   if( 0 < length(arr[0])){'                                                             >> "${FLE_AWK_SERIAL}"
echo ''                                                                                        >> "${FLE_AWK_SERIAL}"
echo '        print HOSTNAME, INSTANCE, arr[0], $2"/"$1"/"$4" "$3, $9, $10, $11, $12;'         >> "${FLE_AWK_SERIAL}"
echo '   }'                                                                                    >> "${FLE_AWK_SERIAL}"
echo '}'                                                                                       >> "${FLE_AWK_SERIAL}"

echo ' ###### SCRIPT PARA COLETA DE GC SOB ALGORITMO CMS - TESTADO EM HOSTSPOT JDK6 ######     '> "${FLE_AWK_CMS}"
echo 'BEGIN{ OFS=";"; temp =0;}'                                                               >> "${FLE_AWK_CMS}"
echo '{'                                                                                       >> "${FLE_AWK_CMS}"
echo '   match( $0,/Full GC|ParNew|concurrent mode failure|CMS[A-z\-]*:/, arr);'               >> "${FLE_AWK_CMS}"
echo '   gsub( "[[:alpha:]]|\\[|\\]|\\(|\\)|\\-|\\,|>|#|:|=|\\/" ," ");'                       >> "${FLE_AWK_CMS}"
echo '   gsub( ":", "", arr[0]);'                                                              >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '   if(arr[0] == "ParNew"){'                                                              >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE,arr[0] " - YOUNG GC", $1, $3, $4, $5, $6;'              >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '   } else if(arr[0] == "Full GC"){'                                                      >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE,arr[0] " - OLD GC", $1, $3, $4, $5, $6;'                >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE,arr[0] " - TOTAL GC", $1, $7, $8, $9;'                  >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE,arr[0] " - PERM GC", $1, $10, $11, $12, $13;'           >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '    }else if( 0 < match(arr[0], "CMS-initial-mark")){'                                   >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0],$1, $4, $5, $6;'                                >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '    }else if( 0 < match(arr[0], "CMS-concurrent")){'                                     >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0],$1 ,"","","", $3;'                              >> "${FLE_AWK_CMS}"
echo ' '                                                                                       >> "${FLE_AWK_CMS}"
echo '   } else if( 0 < match(arr[0], "CMS-remark")){'                                         >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0]" - YOUNG GC",$1, "", $2, $3, $5;'               >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0]" - OLD GC", $1, "", $9, $10, $13;'              >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0]" - TOTAL GC", $1, "", $11, $12;'                >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '   } else if( 0 < match(arr[0], "concurrent mode failure")){'                            >> "${FLE_AWK_CMS}"
echo ''                                                                                        >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0]" - OLD GC", temp_data, $1, $2, $3, $4;'         >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0]" - TOTAL GC", temp_data, $5, $6, $7, $11;'      >> "${FLE_AWK_CMS}"
echo '        print HOSTNAME, INSTANCE, arr[0]" - PERM GC", temp_data, $8, $9, $10, $11;'      >> "${FLE_AWK_CMS}"
echo '   }'                                                                                    >> "${FLE_AWK_CMS}"
echo '   temp_data = $1'                                                                       >> "${FLE_AWK_CMS}"
echo '}'                                                                                       >> "${FLE_AWK_CMS}"

awk -v HOSTNAME="$REMOTE_HOSTNAME" -v INSTANCE="$SUFFIX" -f "${FLE_AWK}" "$REMOTE_HOSTNAME"/"$PREFIX"* > $REMOTE_HOSTNAME"_"$SUFFIX".csv"

echo "`date '+%Y-%m-%d %T'` $REMOTE_HOSTNAME: Iniciando loader $SUFFIX"

echo "LOAD DATA"                                                                            > "${ACL_CTL}"
echo "INFILE '${ACL_LOCAL_HOME}/"$REMOTE_HOSTNAME"_"$SUFFIX".csv'"                         >> "${ACL_CTL}"
echo "APPEND INTO TABLE CAPACITY.TOUT_GC"                                                  >> "${ACL_CTL}"
echo "FIELDS TERMINATED BY ';'"                                                            >> "${ACL_CTL}"
echo "("                                                                                   >> "${ACL_CTL}"
echo "HOSTNAME,"                                                                           >> "${ACL_CTL}"
echo "INSTANCIA,"                                                                          >> "${ACL_CTL}"
echo "DATA DATE \"dd/mm/yyyy HH24:MI:SS\","                                                >> "${ACL_CTL}"
echo "GC_ANTES,"                                                                           >> "${ACL_CTL}"
echo "GC_DEPOIS,"                                                                          >> "${ACL_CTL}"
echo "GC_TAMANHO,"                                                                         >> "${ACL_CTL}"
echo "TEMPO)"                                                                              >> "${ACL_CTL}"

${ORACLE_HOME}/bin/sqlldr userid="impmnegocio/intim#2011" control=${ACL_CTL} log=${ACL_LOG} errors=10000000

echo "`date '+%Y-%m-%d %T'` $REMOTE_HOSTNAME: Removendo arquivos copiados"

find $ACL_LOCAL_HOME/$REMOTE_HOSTNAME -name "$PREFIX*" -exec rm -f {} \;
