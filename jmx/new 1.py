# WLST / Python script I created to retrieve statistics from some JMS Queues
# The statistics are dumped to a csv file, and then processed to add a header
# 
# Usage:
# ${WL_HOME}/common/bin/wlst.sh foo.py

# Read the following info regarding the "import time" issue:
# http://www.javamonamour.org/2013/03/java-package-weblogictime-has-no.html
from time import localtime, strftime
import sys

uname = 'foo'
pwd = 'bar'
url = 't3://localhost:7001'
log = '/foo/bar/foo.csv'
queues = ['fooJMSModule!FooRequestQueue', 'fooJMSModule!FooResponseQueue']

def monitorQueues():
    f = open(log,'a+')
    connect(uname, pwd, url)
    servers = domainRuntimeService.getServerRuntimes()
    if (len(servers) > 0):
        for server in servers:
            jmsRuntime = server.getJMSRuntime();
            jmsServers = jmsRuntime.getJMSServers();
            for jmsServer in jmsServers:
                destinations = jmsServer.getDestinations();
                for destination in destinations:
                    if destination.getName() in queues:
                        day = strftime("%Y.%m.%d", localtime())
                        hour = strftime("%H:%M", localtime())
                        N = destination.getName()
                        BCC = destination.getBytesCurrentCount()
                        BHC = destination.getBytesHighCount()
                        BRC = destination.getBytesReceivedCount()
                        BTT = destination.getBytesThresholdTime()
                        CCC = destination.getConsumersCurrentCount()
                        CHC = destination.getConsumersHighCount()
                        CTC = destination.getConsumersTotalCount()
                        CPS = destination.getConsumptionPausedState()
                        DI = destination.getDestinationInfo()
                        DT = destination.getDestinationType()
                        DS = destination.getDurableSubscribers()
                        IPS = destination.getInsertionPausedState()
                        MCC = destination.getMessagesCurrentCount()
                        MHC = destination.getMessagesHighCount()
                        MPC = destination.getMessagesPendingCount()
                        MRC = destination.getMessagesReceivedCount()
                        MTT = destination.getMessagesThresholdTime()
                        PPS = destination.getProductionPausedState()
                        S = destination.getState()
                        CP = destination.isConsumptionPaused()
                        IP = destination.isInsertionPaused()
                        PP = destination.isProductionPaused()
                        print >>f,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s' % (day, hour, N, BCC, BHC, BRC, BTT, CCC, CHC, CTC, CPS, DT, DS, IPS, MCC, MHC, MPC, MRC, MTT, PPS, S, CP, IP, PP)
    f.close()

if __name__ == 'main':
    monitorQueues()