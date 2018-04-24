# coding: utf-8
'''
Created on Out 25, 2015

@author: Diogenes Buarque Ianakiara
@e-mail: diogenes.buarque@inmetrics.com.br

@author: Guilherme Botelho Diniz Junqueira
@e-mail: guilherme.junqueira@inmetrics.com.br
@version 2.5

@author: Evandro Grezeli de Barros Neves
@e-mail: evandro.neves@inmetrics.com.br
@version 2.6

@author: Bruno Campos
@e-mail: bruno.campos@inmetrics.com.br
@version 2.7

@author: Guilherme Botelho Diniz Junqueira
@e-mail: guilherme.junqueira@inmetrics.com.br
@version 2.8

'''

#------------------------------------------------------------------------------------
# Este programa deve se utilizado para coletar metricas do websphere 6.1 ou superior
#------------------------------------------------------------------------------------

import sys
import os
import re
import traceback
from com.ibm.websphere.pmi.stat import *;
from java.util import Date
#from java.util.regex import *
from java.text import SimpleDateFormat
from java.lang import *

def collectPMI(cellName, nodeName, serverName, completeServerName, module):
    dateStr = DAY_FORMAT.format(Date())

    # Querying the PerfMBean for the desired info
    perfObjectName = AdminControl.queryNames('cell='+cellName+',process='+serverName+',node='+nodeName+',type=Perf,*')
    perfObject     = AdminControl.makeObjectName(perfObjectName)

    params  = [AdminControl.makeObjectName(completeServerName), java.lang.Boolean ('true')]
    sigs    = ['javax.management.ObjectName','java.lang.Boolean']
    statObj = AdminControl.invoke_jmx (perfObject, 'getStatsObject', params, sigs)
        
    fullStats = walkPmiTree("", statObj, module)

    try:
        fullFileName     = os.path.join(OUTPUT_PATH, dateStr + '_' + cellName + '_' + nodeName + '_' + serverName + '_metrics.csv')
        serverMetricFile = openFileWithHeader(fullFileName, getEmptyStatDict().keys(), SEP)
        for aStat in fullStats:
            serverMetricFile.write(SEP.join(aStat.values()) + '\n')
    finally:
        serverMetricFile.close()

# Navega a arvore PMI e retorna uma lista de dicionarios, cada um contendo uma estatistica
def walkPmiTree(parentStatObjName, statObj, module):
    stats = []
    if(module == 'ALL_MODULES'):
        stats = getStatisticsDictionariesList(parentStatObjName, statObj)
        for ss in statObj.getSubStats():
            stats += walkPmiTree(parentStatObjName + '\\' + statObj.getName(), ss, module)
    else:
        if(parentStatObjName.count('\\') == 1):
            if(statObj.getName() == module):
                stats = getStatisticsDictionariesList(parentStatObjName, statObj);
                for ss in statObj.getSubStats():
                    stats += walkPmiTree(parentStatObjName + '\\' + statObj.getName(), ss, module)
        else:
            stats = getStatisticsDictionariesList(parentStatObjName, statObj);
            for ss in statObj.getSubStats():
                stats += walkPmiTree(parentStatObjName + '\\' + statObj.getName(), ss, module)

    return(stats)

#http://publib.boulder.ibm.com/infocenter/dmndhelp/v6rxmx/index.jsp?topic=/com.ibm.wsps.602.javadoc.doc/doc/com/ibm/websphere/pmi/stat/WSStatistic.html
def getStatisticsDictionariesList(parentStatObjName, statObj):
    statistics = statObj.getStatistics()
    stats = []    

    if(len(statistics) > 0 ):
        for st in statistics:
            try:
                output = getEmptyStatDict()
                output['StatObj'] = parentStatObjName + '\\' + statObj.getName()
                output['StatisticName'] = st.getName()
                output['StartTime'] = DAYHOUR_FORMAT.format(st.getStartTime())
                output['LastSampleTime'] = DAYHOUR_FORMAT.format(st.getLastSampleTime())
                if(isinstance(st, WSAverageStatistic)):
                    output['Count'] = str(st.getCount())
                    output['Max'] = str(st.getMax())
                    output['Mean'] = str(st.getMean())
                    output['Min'] = str(st.getMin())
                    output['SumOfSquares'] = str(st.getSumOfSquares())
                    output['Total'] = str(st.getTotal())
                    if(isinstance(st, WSTimeStatistic)):
                        output['MinTime'] = str(st.getMinTime())
                        output['MaxTime'] = str(st.getMaxTime())
                        output['TotalTime'] = str(st.getTotalTime())
                elif(isinstance(st, WSBoundaryStatistic)):            
                    output['LowerBoundary'] = str(st.getLowerBound())
                    output['UpperBoundary'] = str(st.getUpperBound())
                    if(isinstance(st, WSBoundedRangeStatistic)):
                        output['Current'] = str(st.getCurrent())
                        output['HighWaterMark'] = str(st.getHighWaterMark())
                        output['Integral'] = str(st.getIntegral())
                        output['LowWaterMark'] = str(st.getLowWaterMark())
                        output['Mean'] = str(st.getMean())
                elif(isinstance(st, WSRangeStatistic)):
                    output['Current'] = str(st.getCurrent())
                    output['HighWaterMark'] = str(st.getHighWaterMark())
                    output['Integral'] = str(st.getIntegral())
                    output['LowWaterMark'] = str(st.getLowWaterMark())
                    output['Mean'] = str(st.getMean())
                    # Not sure if this is needed
                    if(isinstance(st, WSBoundedRangeStatistic)):
                        output['LowerBoundary'] = str(st.getLowerBound())
                        output['UpperBoundary'] = str(st.getUpperBound())
                elif(isinstance(st, WSCountStatistic)):
                    output['Count'] = str(st.getCount())
                elif(isinstance(st, WSDoubleStatistic)):
                    output['Double'] = str(statObj.getDouble())
                else:
                    raise TypeError('Object ' + output['StatObj'] + ' has an unknown statistic type: ' + type(st))
                stats.append(output)
            except:
                sys.stderr.write('Exception processing %s\\%s\\%s\n' % (
                    parentStatObjName, statObj.getName(), st.getName()
                ))
                traceback.print_exc()
    return(stats)

def getEmptyStatDict():
    output = {
       'StatObj': '',
       'StatisticName': '',
       'StartTime': '',
       'LastSampleTime': '',
       'Count': '',
       'Max': '',
       'Mean': '',
       'Min': '',
       'SumOfSquares': '',
       'Total': '',
       'MinTime': '',
       'MaxTime': '',
       'TotalTime': '',
       'LowerBoundary': '',
       'UpperBoundary': '',
       'Current': '',
       'HighWaterMark': '',
       'Integral': '',
       'LowWaterMark': '',
       'Double': '',
    }
    return(output)

def openFileWithHeader(fullPath, header, sep):
    # If the file exists, we do not need to write the header
    if (os.path.isfile(fullPath)):
        # Abre o arquivo em modo append
        outfile = open(fullPath, 'a')
    else:
        # Abre o arquivo em modo write
        outfile = open(fullPath, 'w')
        outfile.write(sep.join(header) + '\n')
    return(outfile)

#--------------------------------------------- Non configurable section ---------------------------------------
DAY_FORMAT  = SimpleDateFormat('yyyy-MM-dd')
DAYHOUR_FORMAT = SimpleDateFormat('yyyy-MM-dd HH:mm:ss')
SEP = ';'

#----------------------------------------------- Configurable section -----------------------------------------
'''
### Choose the desired modules for filtering or specify ALL_MODULES for complete retrieval:

# Some known modules: 
'beanModule', 'connectionPoolModule', 'hamanagerModule', 'objectPoolModule', 'servletSessionsModule',
'threadPoolModule', 'jvmRuntimeModule', 'transactionModule', 'webAppModule', 'cacheModule',
'orbPerfModule', 'SipContainerModule', 'systemModule'

# Common monitoring
MODULES = [
    'connectionPoolModule', 'objectPoolModule', 'servletSessionsModule', 'threadPoolModule',
    'jvmRuntimeModule', 'transactionModule'
]
'''

# Full monitoring
MODULES = [ 'ALL_MODULES' ]

#--------------------------------------------------- MAIN PROGRAM ---------------------------------------------
if (len(sys.argv) == 2):
    OUTPUT_PATH = sys.argv[0]
    errFilePath = os.path.join(OUTPUT_PATH, DAY_FORMAT.format(Date()) + '_error.log')
    ERROR_FILE  = openFileWithHeader(errFilePath, [], '')
    origin      = sys.argv[1]
    
    # Get all servers
    serverNames = ''
    if(origin == 'ALL_CELL'):
        serverNames = AdminControl.queryNames('WebSphere:type=Server,processType=*anagedProcess,*')
    else:
        serverNames = AdminControl.queryNames('WebSphere:type=Server,processType=*anagedProcess,' + origin + ',*')

    for completeServerName in serverNames.split('\n'):
        # Get some attributes so we can query the related PerfMBean
        cellName   = AdminControl.getAttribute(completeServerName, 'cellName')
        nodeName   = AdminControl.getAttribute(completeServerName, 'nodeName')
        serverName = AdminControl.getAttribute(completeServerName, 'name')

        print 'Collecting metrics for ' + serverName + ' on node ' + nodeName + ' that belongs to cell ' + cellName

        for aModule in MODULES:
            try:
                collectPMI(cellName, nodeName, serverName, completeServerName, aModule)
            except Error, e:
                ERROR_FILE.write('Erro no processamento de metricas do servidor: ' + completeServerName)
                ERROR_FILE.write(e)
            #pass
    ERROR_FILE.close()

else:
    print 'Este script requer 2 parametros para sua execucao:'
    print '   1) Diretorio para gravacao das coletas sem barra no final'
    print '   2) Nome do server para o qual se deseja a coleta ou ALL_CELL para coletar toda a celula'
    print
    print '!!! IMPORTANTE !!!'
    print '   1) O nome do server deve ser informado no seguinte formato: \'cell=<cellName>,node=<nodeName>,name=<serverName>\''
    print '   2) Não esqueca de configurar os modulos desejados na secao \'configurable section\' do script wasadmin.py'