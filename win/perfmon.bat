@echo off
echo.

rem variavel que define a localizacao do arquivo de monitoracao
SET ARQ="%HOMEPATH%\Desktop\perflogs\%COMPUTERNAME%"

rem variavel que define a periodicidade de coleta - mascara [[hh:]mm:]ss - exs: 10 minutos = 10:00 - 1 hora = 01:00:00
SET PERIOD="01:00"

rem variavel que define tempo de armazenado por arquivo - mascara [[hh:]mm:]ss - exs: 10 minutos = 10:00 - 1 hora = 01:00:00
SET LOGROTATION="24:00:00"

rem variavel que define o inicio de execucao do perfmon - colocar uma data no passado ao inicio real - mascara dd/mm/aaaa hh:mi:ss"
SET STARTUPTIME="01/01/2012 01:00:00"

REM Variavel que define o nome do contador de performance
SET NAME = "Inm-Perfmon"

echo IDENTIFICANDO OS CONTADORES DE PROCESSADOR
echo.
rem Processor

typeperf -qx "Processor" | find /I "Processor Time" > config.txt
typeperf -qx "Processor" | find /I "Interrupts/sec" >> config.txt
typeperf -qx "Processor" | find /I "User Time" >> config.txt
typeperf -qx "Processor" | find /I "Privileged Time" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE MEMÓRIA
echo.
rem Memory

typeperf -qx "Memory"| find /I "Available Bytes" >> config.txt
typeperf -qx "Memory"| find /I "Cache Bytes" | find /I /v "Peak" >> config.txt
typeperf -qx "Memory"| find /I "Nonpaged Bytes" >> config.txt
typeperf -qx "Memory"| find /I "Pages/sec" >> config.txt
typeperf -qx "Memory"| find /I "Page Faults/sec" >> config.txt
typeperf -qx "Memory"| find /I "Page Reads/sec" >> config.txt
typeperf -qx "Memory"| find /I "Page Writes/sec" >> config.txt
typeperf -qx "Memory"| find /I "Page Writes/sec" >> config.txt
typeperf -qx "Memory"| find /I "Commit" >> config.txt
typeperf -qx "Paging File" | find /I "Usage" | find /I /v "Peak" | find /I /v "sys" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE DISCO (PHYSICAL)
echo.
rem PhysicalDisk

typeperf -qx "PhysicalDisk" | find /I "Time" >> config.txt
typeperf -qx "PhysicalDisk" | find /I "Avg. Disk Queue Length" >> config.txt
typeperf -qx "PhysicalDisk" | find /I "Avg. Disk sec" >> config.txt
typeperf -qx "PhysicalDisk" | find /I "Disk Reads/sec" >> config.txt
typeperf -qx "PhysicalDisk" | find /I "Disk Writes/sec" >> config.txt
typeperf -qx "PhysicalDisk" | find /I "Disk Read Bytes/sec" >> config.txt
typeperf -qx "PhysicalDisk" | find /I "Disk Write Bytes/sec" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE DISCO (LOGICAL)
echo.
rem LogicalDisk

typeperf -qx "LogicalDisk" | find /I "Time" >> config.txt
typeperf -qx "LogicalDisk" | find /I "Avg. Disk Queue Length" >> config.txt
typeperf -qx "LogicalDisk" | find /I "Avg. Disk sec" >> config.txt
typeperf -qx "LogicalDisk" | find /I "Disk Reads/sec" >> config.txt
typeperf -qx "LogicalDisk" | find /I "Disk Writes/sec" >> config.txt
typeperf -qx "LogicalDisk" | find /I "Disk Read Bytes/sec" >> config.txt
typeperf -qx "LogicalDisk" | find /I "Disk Write Bytes/sec" >> config.txt
typeperf -qx "LogicalDisk" | find /I "Free" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE REDE
echo.
rem Network Interface

typeperf -qx "Network Interface" | find /I "Bytes Received/sec" >> config.txt
typeperf -qx "Network Interface" | find /I "Bytes Sent/sec" >> config.txt
typeperf -qx "Network Interface" | find /I "Bytes Total/sec" >> config.txt
typeperf -qx "Network Interface" | find /I "Output Queue Length" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SISTEMA
echo.
rem System

typeperf -qx "Paging File" | find /I "Usage" | find /V "Peak" >> config.txt
typeperf -qx "System" | find /I "Context Switches/sec" >> config.txt
typeperf -qx "System" | find /I "Processor Queue Length" >> config.txt
typeperf -qx "System" | find /I "Processes" >> config.txt
typeperf -qx "System" | find /I "Threads" >> config.txt
typeperf -qx "Server" | find /I "Server Sessions" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE PROCESSO (GERAL)
echo.
rem Process

typeperf -qx "Process" | find /I "_Total" | find /I "Time" | find /V "Elapsed">> config.txt
typeperf -qx "Process" | find /I "_Total" | find /I "Page F" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "_Total" | find /I "Working" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "_Total" | find /I "Virtual" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "_Total" | find /I "Private" | find /V "Working">> config.txt
typeperf -qx "Process" | find /I "_Total" | find /I "Thread">> config.txt
typeperf -qx "Process" | find /I "_Total" | find /I "Pool">> config.txt

echo IDENTIFICANDO OS CONTADORES DE PROCESSO (BY PROCESS)
echo.
rem Process

typeperf -qx "Process" | find /I "Time" | find /V "Elapsed">> config.txt
typeperf -qx "Process" | find /I "Page F" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "Working" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "Virtual" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "Private" | find /V "Working">> config.txt
typeperf -qx "Process" | find /I "Thread">> config.txt
typeperf -qx "Process" | find /I "Pool">> config.txt


echo IDENTIFICANDO OS CONTADORES DE PROCESSO (SQL SERVER)
echo.
rem Process

typeperf -qx "Process" | find /I "sqlservr" | find /I "Time" | find /V "Elapsed">> config.txt
typeperf -qx "Process" | find /I "sqlservr" | find /I "Page F" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "sqlservr" | find /I "Working" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "sqlservr" | find /I "Virtual" | find /V "Peak">> config.txt
typeperf -qx "Process" | find /I "sqlservr" | find /I "Private" | find /V "Working">> config.txt
typeperf -qx "Process" | find /I "sqlservr" | find /I "Thread">> config.txt
typeperf -qx "Process" | find /I "sqlservr" | find /I "Pool">> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (BUFFER MANAGER)
echo.
rem Buffer Manager

typeperf -qx "MSSQL$SNEPDB23C01:Buffer Manager" | find /I "Buffer cache hit ratio" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Buffer Manager" | find /I "page" | find /V "/sec" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (LOCKS)
echo.
rem Locks

typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "Key" | find /I "Lock Requests/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "Page" | find /I "Lock Requests/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "Object" | find /I "Lock Requests/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "_Total" | find /I "Lock Requests/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "_Total" | find /I "Number of Deadlocks/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "Key" | find /I "Average Wait Time" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "Page" | find /I "Average Wait Time" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "Object" | find /I "Average Wait Time" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Locks" | find /I "_Total" | find /I "Average Wait Time" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (DATABASES)
echo.
rem Databases

typeperf -qx "MSSQL$SNEPDB23C01:Databases" | find /I "Percent Log Used" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Databases" | find /I "Active Transactions" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Databases" | find /I "Transactions/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Databases" | find /I "Log Cache Hit Ratio" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (ACESS METHODS)
echo.
rem Access

typeperf -qx "MSSQL$SNEPDB23C01:Access Methods" | find /I "Full Scans/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Access Methods" | find /I "Range Scans/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Access Methods" | find /I "Index Searches/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Access Methods" | find /I "Table Lock Escalations/sec" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (SQL)
echo.
rem SQL

typeperf -qx "MSSQL$SNEPDB23C01:SQL Errors" | find /I "Errors/sec" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:SQL Statistics" | find /I "Batch Requests/sec" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (MEMORY MANAGER)
echo.
rem Memory

typeperf -qx "MSSQL$SNEPDB23C01:Memory Manager" | find /I "Target Server Memory" >> config.txt
typeperf -qx "MSSQL$SNEPDB23C01:Memory Manager" | find /I "Total Server Memory" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (LATCH)
echo.
rem Wait

typeperf -qx "MSSQL$SNEPDB23C01:Latches" | find /I "Latches" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE SQL SERVER (WAIT)
echo.
rem Wait

typeperf -qx "MSSQL$SNEPDB23C01:Wait Statistics" | find /I "Average wait time" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE ISS (ASP.NET)
echo.
rem Memory

echo Todos

typeperf -qx | find /I ".NET CLR Memory" >> config.txt
typeperf -qx "ASP.NET Apps v2.0.50727" | find /I "_Total_" >> config.txt
typeperf -qx "ASP.NET Apps v4.0.30319" | find /I "_Total_" >> config.txt

typeperf -qx "ASP.NET v4.0.30319" | find /I "Sessions" >> config.txt
typeperf -qx "ASP.NET v4.0.30319" | find /I "Applications Running" >> config.txt           
typeperf -qx "ASP.NET v4.0.30319" | find /I "Worker Processes Running" >> config.txt       
typeperf -qx "ASP.NET v4.0.30319" | find /I "Request Execution Time" >> config.txt         
typeperf -qx "ASP.NET v4.0.30319" | find /I "Request Wait Time" >> config.txt              
typeperf -qx "ASP.NET v4.0.30319" | find /I "Requests Current" >> config.txt               
typeperf -qx "ASP.NET v4.0.30319" | find /I "Requests Queued" >> config.txt                
typeperf -qx "ASP.NET v4.0.30319" | find /I "Requests Rejected" >> config.txt              
typeperf -qx "ASP.NET v4.0.30319" | find /I "State Server Sessions Active" >> config.txt   
typeperf -qx "ASP.NET v4.0.30319" | find /I "State Server Sessions Timed Out" >> config.txt

echo IDENTIFICANDO OS CONTADORES DE WEB_SERVICE.NET
echo.
rem Memory

typeperf -qx "Web Service" | find /I "Bytes Received/sec" >> config.txt
typeperf -qx "Web Service" | find /I "Bytes Sent/sec" >> config.txt
typeperf -qx "Web Service" | find /I "Connection Attempts/sec" >> config.txt
typeperf -qx "Web Service" | find /I "Files/sec" >> config.txt
typeperf -qx "Web Service" | find /I "Logon Attempts/sec" >> config.txt
typeperf -qx "Web Service" | find /I "Total Method Requests" >> config.txt
typeperf -qx "Web Service" | find /I "Total Method Requests/sec" >> config.txt
typeperf -qx "Web Service" | find /I "Not Found Errors/sec" >> config.txt
typeperf -qx "Web Service" | find /I "Locked Errors/sec" >> config.txt

rm unique.vbs
echo Const ForReading  = 1 >> unique.vbs
echo Set objDictionary = CreateObject("Scripting.Dictionary")>> unique.vbs
echo Set objFSO = CreateObject("Scripting.FileSystemObject")>> unique.vbs
echo Set objFile = objFSO.OpenTextFile("config.txt", ForReading)>> unique.vbs
echo Do Until objFile.AtEndOfStream>> unique.vbs
echo strName = objFile.ReadLine>> unique.vbs
echo If Not objDictionary.Exists(strName) Then>> unique.vbs
echo objDictionary.Add strName, strName>> unique.vbs
echo End If>> unique.vbs
echo Loop>> unique.vbs
echo objFile.Close>> unique.vbs
echo For Each strKey in objDictionary.Keys>> unique.vbs
echo wscript.Echo strKey>> unique.vbs
echo Next>> unique.vbs

echo REMOVENDO CONTADORES DUPLICADOS.
echo.
rem Unique
cscript //Nologo %0\..\unique.vbs > metricas.txt

echo PARANDO O CONTADOR DE PERFORMANCE ATUAL, CASO EXISTA.
echo.
logman stop Inm-Perfmon

echo DELETANDO O CONTADOR DE PERFORMANCE %NAME%.
echo.
logman delete Inm-Perfmon

echo CRIANDO O CONTADOR DE PERFORMANCE %NAME%.
echo.
logman create counter Inm-Perfmon -cf "metricas.txt" -f csv -o %ARQ% -si %PERIOD% -cnf %LOGROTATION% -v mmddhhmm -b %STARTUPTIME%

echo INICIANDO O CONTADOR DE PERFORMANCE %NAME%.
echo.
logman start Inm-Perfmon
