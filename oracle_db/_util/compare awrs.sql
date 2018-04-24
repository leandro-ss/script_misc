Pessoal, boa tarde !
Estava trabalhando na SR13281715, que consiste em analisar o Banco de Dados Oracle em 2 períodos, e fazer um comparativo entre essas datas.
Utilizando o script abaixo, podemos comparar as características de desempenho do banco de dados a partir de diferentes períodos de tempo.
@$ORACLE_HOME/rdbms/admin/awrddrpt.sql
 
Essa ferramenta, pode nos ajudar em analises futuras !
 
Estou anexando um exemplo do relatório.
 
Exemplo de Utilização:

5.3.5.5 Running the awrddrpt.sql Report
To compare detailed performance attributes and configuration settings between two time periods, run the awrddrpt.sql script at the SQL prompt to generate an HTML or text report:
@$ORACLE_HOME/rdbms/admin/awrddrpt.sql

First, you need to specify whether you want an HTML or a text report.
Enter value for report_type: text
Specify the number of days for which you want to list snapshot Ids for the first time period.
Enter value for num_days: 2

After the list displays, you are prompted for the beginning and ending snapshot Id for the first time period.
Enter value for begin_snap: 102
Enter value for end_snap: 103

Next, specify the number of days for which you want to list snapshot Ids for the second time period.
Enter value for num_days2: 1
After the list displays, you are prompted for the beginning and ending snapshot Id for the second time period.
Enter value for begin_snap2: 126
Enter value for end_snap2: 127
Next, accept the default report name or enter a report name. The default name is accepted in the following example:
Enter value for report_name:
Using the report name awrdiff_1_102_1_126.txt