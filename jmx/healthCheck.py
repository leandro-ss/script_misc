#======================================
from java.io import FileInputStream
import java.lang
import os
import string
import sys

sys.stdout = file('currentAppState_file_DEL','w')

#propertiesFile = raw_input('Please enter path of properties file (e.g. /u01/app/oracle/domains/oms01/oms01.properties) : ')
#propInputStream = FileInputStream(propertiesFile)

propInputStream = FileInputStream('oms01.properties')
#propInputStream = FileInputStream('osb02.properties')
configProps = Properties()
configProps.load(propInputStream)

ServerUrl = configProps.get('datasource.targetServer.url')
#UserName = configProps.get('admin.username')
#Password = configProps.get('admin.password')

UserFile = configProps.get('keyfile.username')
KeyFile = configProps.get('keyfile.password')

distroList = configProps.get('distroList.email')

# This module for managed Servers list
def getRunningServerNames():
    domainConfig()
    serverNames = cmo.getServers()
    return serverNames

# This module is for sending email
def sendMailString():
    connect(userConfigFile=UserFile,userKeyFile=KeyFile,url=ServerUrl)
    domainName = cmo.getName()
    #mailCommand = 'cat currentAppState_file_DEL | /bin/mail -s  \"WLS HEALTH CHECK: \"' + domainName + '\" domain \" \"email@domain.com\" '
    mailCommand = 'cat currentAppState_file_DEL | /bin/mail -s  \"WLS HEALTH CHECK: \"' + domainName + '\" domain \" \"' + distroList + '\" '
    
    #serverNames = getRunningServerNames()
    os.system(mailCommand)
    print '*********  ALERT MAIL HAS BEEN SENT  ***********'

#This module is for retrieve the JVM statistics------------
def monitorJVMHeapSize():
# connect(UserName,Password,ServerUrl)
    connect(userConfigFile=UserFile,userKeyFile=KeyFile,url=ServerUrl)
    
    serverNames = getRunningServerNames()
    domainRuntime()
    domainName = cmo.getName()

    print 'WLS domain ' , domainName , ' server instances JVM statistics:'
    print '                                 TotalJVM     FreeJVM     UsedJVM'
    print ' '
    print '=========================================================================='
    for name in serverNames:
        try:
            cd("/ServerRuntimes/"+name.getName()+"/JVMRuntime/"+name.getName())
            freejvm = int(get('HeapFreeCurrent'))/(1024*1024)
            totaljvm = int(get('HeapSizeCurrent'))/(1024*1024)
            usedjvm = (totaljvm - freejvm)
            # writeInFile0 = '%14s  %4d MB   %4d MB   %4d MB ' %  (name.getName(),totaljvm, freejvm, usedjvm)
            writeInFile0 = '%29s  %6d MB   %6d MB   %6d MB ' %  (name.getName(),totaljvm, freejvm, usedjvm)
            print '', writeInFile0
            # cmd = "echo " + writeInFile0 + " >> currentAppState_file"
            # os.system(cmd)

        except WLSTException,e:
            pass

    print ' '

#This module is for retrieve the JMS statistics------------
def monitorJMSQueue():
    connect(userConfigFile=UserFile,userKeyFile=KeyFile,url=ServerUrl)
    serverNames = domainRuntimeService.getServerRuntimes();
    domainRuntime()
    
    if (len(serverNames) > 0):
       for server in serverNames:
           print '=========================================================================='
           print 'JMS statistics on ' , server.getName() , ' @ ' , server.getCurrentMachine()
           print server.getListenAddress()
           print '=========================================================================='
           jmsRuntime = server.getJMSRuntime();
           jmsServers = jmsRuntime.getJMSServers();
           for jmsServer in jmsServers:
               destinations = jmsServer.getDestinations();
               for destination in destinations:
                   print '  DestinationName             ' ,  destination.getName()
                   print '  DestinationType             ' ,  destination.getDestinationType()
                   # print '  Type                        ' ,  destination.getType()
                   # print '  BytesCurrentCount           ' ,  destination.getBytesCurrentCount()
                   # print '  BytesHighCount              ' ,  destination.getBytesHighCount()
                   # print '  BytesPendingCount           ' ,  destination.getBytesPendingCount()
                   # print '  BytesReceivedCount          ' ,  destination.getBytesReceivedCount()
                   # print '  BytesThresholdTime          ' ,  destination.getBytesThresholdTime()
                   print '  ConsumersCurrentCount       ' ,  destination.getConsumersCurrentCount()
                   print '  ConsumersHighCount          ' ,  destination.getConsumersHighCount()
                   # print '  ConsumersTotalCount         ' ,  destination.getConsumersTotalCount()
                   print '  ConsumptionPausedState      ' ,  destination.getConsumptionPausedState()
                   # print '  '
                   # print '  DestinationInfo             ' ,  destination.getDestinationInfo()
                   # print '  '
                   print '  MessagesCurrentCount        ' ,  destination.getMessagesCurrentCount()
                   print '  MessagesDeletedCurrentCount ' ,  destination.getMessagesDeletedCurrentCount()
                   print '  MessagesHighCount           ' ,  destination.getMessagesHighCount()
                   print '  MessagesMovedCurrentCount   ' ,  destination.getMessagesMovedCurrentCount()
                   print '  MessagesPendingCount        ' ,  destination.getMessagesPendingCount()
                   print '  MessagesReceivedCount       ' ,  destination.getMessagesReceivedCount()
                   print '  MessagesThresholdTime       ' ,  destination.getMessagesThresholdTime()
                   # print '  Parent                      ' ,  destination.getParent()
                   print '  Paused                      ' ,  destination.isPaused()
                   # print '  InsertionPaused             ' ,  destination.isInsertionPaused()
                   print '  InsertionPausedState        ' ,  destination.getInsertionPausedState()
                   # print '  ProductionPaused            ' ,  destination.isProductionPaused()
                   print '  ProductionPausedState       ' ,  destination.getProductionPausedState()
                   print '  State                       ' ,  destination.getState()
                   print '  ---------------------------------------------'
           print '  '


if __name__== "main":
    monitorJVMHeapSize()
    print '=========================================================================='
    monitorJMSQueue()
    disconnect()
#Application state monitoring-------------------
print '=========================================================================='
redirect('wlst.log','false')
#connect(UserName,Password,ServerUrl)
connect(userConfigFile=UserFile,userKeyFile=KeyFile,url=ServerUrl)
cd ('AppDeployments')
myapps=cmo.getAppDeployments()
print '=========================================================================='
print 'Following Applications are not in STATE_ACTIVE'
print ' '
print '=========================================================================='
for appName in myapps:
    domainConfig()
    cd ('/AppDeployments/'+appName.getName()+'/Targets')
    mytargets = ls(returnMap='true')
    domainRuntime()
    cd('AppRuntimeStateRuntime/AppRuntimeStateRuntime')
    for targetinst in mytargets:
	currentAppState=cmo.getCurrentState(appName.getName(),targetinst)
	if currentAppState != "STATE_ACTIVE":
           writeInFile ='Applicaiton = "'+ appName.getName() +'"   //    Targeted Server = "'+str(mytargets)+'"   //     Current STATE = "'+ currentAppState +'"'
	   print '', writeInFile
	   # cmd = "echo " + writeInFile + " >> currentAppState_file"
	   # os.system(cmd)

#connect(UserName,Password,ServerUrl)
connect(userConfigFile=UserFile,userKeyFile=KeyFile,url=ServerUrl)
serverNames=domainRuntimeService.getServerRuntimes();
if (len(serverNames) > 0):
   for server in serverNames:
       jdbcServiceRT = server.getJDBCServiceRuntime();
       dataSources = jdbcServiceRT.getJDBCDataSourceRuntimeMBeans();

       print '=========================================================================='
       print 'DataSource statistics on ' , server.getName() , ' @ ' , server.getCurrentMachine()
       print server.getListenAddress()
       print '=========================================================================='
       if (len(dataSources) > 0):
           for dataSource in dataSources:
               print '  ModuleId                           '  ,  dataSource.getModuleId()
               print '  Name                               '  ,  dataSource.getName()
               print '  State                              '  ,  dataSource.getState()
               print '  Properties                         '  ,  dataSource.getProperties()
               print '  ActiveConnectionsAverageCount      '  ,  dataSource.getActiveConnectionsAverageCount()
               print '  ActiveConnectionsCurrentCount      '  ,  dataSource.getActiveConnectionsCurrentCount()
               print '  ActiveConnectionsHighCount         '  ,  dataSource.getActiveConnectionsHighCount()
               print '  ConnectionDelayTime                '  ,  dataSource.getConnectionDelayTime()
               print '  ConnectionsTotalCount              '  ,  dataSource.getConnectionsTotalCount()
               print '  CurrCapacity                       '  ,  dataSource.getCurrCapacity()
               print '  CurrCapacityHighCount              '  ,  dataSource.getCurrCapacityHighCount()
               print '  DeploymentState                    '  ,  dataSource.getDeploymentState()
               print '  FailedReserveRequestCount          '  ,  dataSource.getFailedReserveRequestCount()
               print '  FailuresToReconnectCount           '  ,  dataSource.getFailuresToReconnectCount()
               print '  HighestNumAvailable                '  ,  dataSource.getHighestNumAvailable()
               print '  HighestNumUnavailable              '  ,  dataSource.getHighestNumUnavailable()
               print '  LeakedConnectionCount              '  ,  dataSource.getLeakedConnectionCount()
               print '  NumAvailable                       '  ,  dataSource.getNumAvailable()
               print '  NumUnavailable                     '  ,  dataSource.getNumUnavailable()
               print '  Parent                             '  ,  dataSource.getParent()
               # print '  PrepStmtCacheAccessCount           '  ,  dataSource.getPrepStmtCacheAccessCount()
               # print '  PrepStmtCacheAddCount              '  ,  dataSource.getPrepStmtCacheAddCount()
               # print '  PrepStmtCacheCurrentSize           '  ,  dataSource.getPrepStmtCacheCurrentSize()
               # print '  PrepStmtCacheDeleteCount           '  ,  dataSource.getPrepStmtCacheDeleteCount()
               # print '  PrepStmtCacheHitCount              '  ,  dataSource.getPrepStmtCacheHitCount()
               # print '  PrepStmtCacheMissCount             '  ,  dataSource.getPrepStmtCacheMissCount()
               print '  ReserveRequestCount                '  ,  dataSource.getReserveRequestCount()
               print '  Type                               '  ,  dataSource.getType()
               print '  VersionJDBCDriver                  '  ,  dataSource.getVersionJDBCDriver()
               print '  WaitingForConnectionCurrentCount   '  ,  dataSource.getWaitingForConnectionCurrentCount()
               # print '  WaitingForConnectionFailureTotal   '  ,  dataSource.getWaitingForConnectionFailureTotal()
               # print '  WaitingForConnectionHighCount      '  ,  dataSource.getWaitingForConnectionHighCount()
               # print '  WaitingForConnectionSuccessTotal   '  ,  dataSource.getWaitingForConnectionSuccessTotal()
               # print '  WaitingForConnectionTotal          '  ,  dataSource.getWaitingForConnectionTotal()
               # print '  WaitSecondsHighCount               '  ,  dataSource.getWaitSecondsHighCount()
               print '  ---------------------------------------------'
               print ' '
   
   sendMailString()
   cmd = "rm -f wlst.log currentAppState_file_DEL"
   os.system(cmd)
   disconnect()
   #======================================