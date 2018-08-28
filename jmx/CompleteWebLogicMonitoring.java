import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.Set;

import javax.management.AttributeNotFoundException;
import javax.management.MBeanServerConnection;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;



public class CompleteWebLogicMonitoring {

    private static String                sistName;
    private static String                consId;
    private static String                host;
    private static String                port;
    private static String                path;
    private static Boolean               hasHeader;

    private static MBeanServerConnection connection;
    private static JMXConnector          connector;

    private static final ObjectName      SERVICE;
    private static final String          PROTOCOL_T3;
    private static final String          JNDI;
    private static final Format          DATE_FORMATTER;
    private static final String          LINE_SEPARATOR;
    private static final String          FIELD_SEPARATOR;

//    private boolean                      collectThreadDump = false;

    static {

        PROTOCOL_T3 = "t3";
        JNDI = "/jndi/weblogic.management.mbeanservers.domainruntime";

        try {
            SERVICE = new ObjectName("com.bea:Name=DomainRuntimeService,Type=weblogic.management.mbeanservers.domainruntime.DomainRuntimeServiceMBean");

        } catch (MalformedObjectNameException localMalformedObjectNameException) {
            throw new AssertionError(localMalformedObjectNameException.getMessage());
        }

        DATE_FORMATTER = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        LINE_SEPARATOR = System.getProperty("line.separator");
        FIELD_SEPARATOR = ";";

    }

    private enum MonitoringType {

        THREAD_DUMP("ThreadStuckDump.dat", new String[] { "Text" }),
        
        THREAD_DUMP_RAW("ThreadStuckDumpRaw.dat", new String[] { "Text" }),

        CHANNEL("ChannelRuntime.dat", new String[] { "ChannelName", "MessagesReceivedCount", "MessagesSentCount", "BytesReceivedCount", "BytesSentCount",
                "ConnectionsCount" }),

        WEB_APP("WebAppComponentRuntime.dat", new String[] { "OpenSessionsCurrentCount", "SessionsOpenedTotalCount" }),

        WORK_MANAGER("WorkManagerRuntimes.dat", new String[] { "PendingRequests", "CompletedRequests", "StuckThreadCount" }),

        CLUSTER_DATA("ClusterRuntime.dat", new String[] { "Name", "ResendRequestsCount", "ForeignFragmentsDroppedCount", "FragmentsReceivedCount",
                "FragmentsSentCount", "MulticastMessagesLostCount" }),

        EJB_DATA("EJBComponentRuntime.dat", new String[] { "Name", "AccessTotalCount", "MissTotalCount", "DestroyedTotalCount", "PooledBeansCurrentCount",
                "BeansInUseCurrentCount", "WaiterCurrentCount", "TimeoutTotalCount" }),

        THREAD_POOL("ThreadPoolRuntime.dat", new String[] { "CompletedRequestCount", "ExecuteThreadTotalCount", "ExecuteThreadIdleCount", "HoggingThreadCount",
                "PendingUserRequestCount", "QueueLength", "StandbyThreadCount", "Throughput" }),

        SERVER_JDBC("JDBCDataSourceRuntimeMBeans.dat", new String[] { "Name", "ActiveConnectionsCurrentCount", "WaitSecondsHighCount",
                "WaitingForConnectionCurrentCount", "WaitingForConnectionFailureTotal", "WaitingForConnectionTotal", "WaitingForConnectionHighCount",
                "PrepStmtCacheAccessCount", "PrepStmtCacheCurrentSize", "PrepStmtCacheAddCount", "PrepStmtCacheDeleteCount", "PrepStmtCacheHitCount",
                "PrepStmtCacheMissCount" }),

        SERVER_START("ServerStartDomain.dat", new String[] { "Arguments", "ClassPath", "RootDirectory", "JavaHome" }),

        JVM_RUNTIME("JVMRuntime.dat", new String[] { "HeapFreeCurrent", "HeapFreePercent", "HeapSizeCurrent", "HeapSizeMax", "JavaVersion", "JavaVMVendor" }),

        JROCKIT_RUNTIME("JVMRuntime.dat", new String[] { "HeapFreeCurrent", "HeapFreePercent", "HeapSizeCurrent", "HeapSizeMax", "JavaVersion", "JavaVMVendor",
                "TotalNumberOfThreads", "NumberOfDaemonThreads", "TotalGarbageCollectionTime", "TotalGarbageCollectionCount", "Parallel", "Incremental",
                "Generational", "GCHandlesCompaction" }),

        JMS_SERVER("JMSServerRuntime.dat", new String[] { "Name", "MessagesCurrentCount", "MessagesPendingCount", "MessagesHighCount", "MessagesReceivedCount",
                "ConsumersCurrentCount" });

        String[] strArray;

        String   filename;

        MonitoringType(String fileName, String... strArray) {
            this.strArray = strArray;
            this.filename = fileName;
        }
    }

    private CompleteWebLogicMonitoring(String param1 // hostname
                                       ,
                                       String param2 // port
                                       ,
                                       String param3 // user
                                       ,
                                       String param4 // passwd
                                       ,
                                       String param5 // path_out
                                       ,
                                       String param6 // console_id
                                       ,
                                       String param7 // system_name
                                       ,
                                       String param8 // header
    ) throws IOException, MalformedURLException {

        JMXServiceURL serviceURL = new JMXServiceURL(PROTOCOL_T3, param1, Integer.valueOf(param2), JNDI);

        Map<String, String> localHashtable = new Hashtable<String, String>();
        localHashtable.put("java.naming.security.principal", param3);
        localHashtable.put("java.naming.security.credentials", param4);
        localHashtable.put("jmx.remote.protocol.provider.pkgs", "weblogic.management.remote");

        host = param1;
        port = param2;
        path = param5;
        consId = param6;
        sistName = param7;
        hasHeader = Integer.valueOf(param8) == 1 ? true : false;

        connector = JMXConnectorFactory.connect(serviceURL, localHashtable);
        connection = connector.getMBeanServerConnection();
    }

    private void getServerStart() throws Exception {
        MonitoringType type = MonitoringType.SERVER_START;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        ObjectName domain = getDomainConfiguration();
        for (ObjectName servers : (ObjectName[]) connection.getAttribute(domain, "Servers")) {
            String name = (String) connection.getAttribute(servers, "Name");
            String address = (String) connection.getAttribute(servers, "ListenAddress");

            ObjectName serverStart = (ObjectName) connection.getAttribute(servers, "ServerStart");

            if (address != null) {
                write(type.filename, concat(getInfo(type.strArray, serverStart), consId, sistName, formatDate(localDate), formatHost(address), name));
            }
        }
    }

    private void getJdbcRuntime() throws Exception {
        MonitoringType type = MonitoringType.SERVER_JDBC;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        for (ObjectName serverRuntimes : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntimes, "Name");
            String adress = (String) connection.getAttribute(serverRuntimes, "ListenAddress");

            ObjectName[] jdbcDataSourceArray = (ObjectName[]) connection.getAttribute(new ObjectName("com.bea:Name=" + name + ",ServerRuntime=" + name
                    + ",Location=" + name + ",Type=JDBCServiceRuntime"), "JDBCDataSourceRuntimeMBeans");

            for (ObjectName jdbcDataSource : jdbcDataSourceArray) {

                write(type.filename, concat(getInfo(type.strArray, jdbcDataSource), consId, sistName, formatDate(localDate), formatHost(adress), name));

            }
        }
    }

    private void getJvmRuntime() throws Exception {
        MonitoringType type = MonitoringType.JVM_RUNTIME;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        for (ObjectName serverRuntimes : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntimes, "Name");
            String adress = (String) connection.getAttribute(serverRuntimes, "ListenAddress");
            ObjectName jvmRuntime = (ObjectName) connection.getAttribute(serverRuntimes, "JVMRuntime");

            write(type.filename, concat(getInfo(type.strArray, jvmRuntime), consId, sistName, formatDate(localDate), formatHost(adress), name));
        }
    }

    private void getJRockitRuntime() throws Exception {
        MonitoringType type = MonitoringType.JROCKIT_RUNTIME;
        Date localDate = new Date();

        List<String[]> list = new ArrayList<String[]>();

        for (ObjectName serverRuntime : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String host = (String) connection.getAttribute(serverRuntime, "ListenAddress");
            ObjectName jvmRuntime = (ObjectName) connection.getAttribute(serverRuntime, "JVMRuntime");

            list.add(concat(getInfo(type.strArray, jvmRuntime), consId, sistName, formatDate(localDate), formatHost(host), name));
        }

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server;"));
        }

        for (String str[] : list) {
            write(type.filename, str);
        }
    }

    private void getJmsRuntime() throws Exception {
        MonitoringType type = MonitoringType.JMS_SERVER;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server;"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");
            ObjectName jmsRuntime = (ObjectName) connection.getAttribute(serverRuntime, "JMSRuntime");
            ObjectName[] jmsServerArray = (ObjectName[]) connection.getAttribute(jmsRuntime, "JMSServers");

            for (ObjectName jmsServer : jmsServerArray) {
                ObjectName[] destinationArray = (ObjectName[]) connection.getAttribute(jmsServer, "Destinations");

                for (ObjectName destination : destinationArray) {
                    String nameJMS = (String) connection.getAttribute(jmsServer, "Name");
                    write(type.filename,
                            concat(getInfo(type.strArray, destination), consId, sistName, formatDate(localDate), formatHost(adress), name, nameJMS));

                }
            }
        }
    }

    private void getThreadPoolRuntime() throws Exception {
        MonitoringType type = MonitoringType.THREAD_POOL;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server;"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");

            ObjectName threadPoolRuntime = (ObjectName) connection.getAttribute(serverRuntime, "ThreadPoolRuntime");

            write(type.filename, concat(getInfo(type.strArray, threadPoolRuntime), consId, sistName, formatDate(localDate), formatHost(adress), name));

        }
    }

    private void getEJBData() throws Exception {
        MonitoringType type = MonitoringType.EJB_DATA;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");
            ObjectName[] applicationRuntimeArray = (ObjectName[]) connection.getAttribute(serverRuntime, "ApplicationRuntimes");

            for (ObjectName applicationRuntime : applicationRuntimeArray) {
                ObjectName[] componentRuntimeArray = (ObjectName[]) connection.getAttribute(applicationRuntime, "ComponentRuntimes");
                String nameApp = (String) connection.getAttribute(applicationRuntime, "Name");

                for (ObjectName componentRuntime : componentRuntimeArray) {
                    String typeComponent = (String) connection.getAttribute(componentRuntime, "Type");

                    if (typeComponent.toString().equals("EJBComponentRuntime")) {
                        ObjectName[] ejbRuntimeArray = (ObjectName[]) connection.getAttribute(componentRuntime, "EJBRuntimes");

                        for (ObjectName ejbRuntime : ejbRuntimeArray) {
                            ObjectName poolRuntime = (ObjectName) connection.getAttribute(ejbRuntime, "PoolRuntime");

                            write(type.filename,
                                    concat(getInfo(type.strArray, poolRuntime), consId, sistName, formatDate(localDate), formatHost(adress), name, nameApp));

                        }
                    }
                }
            }
        }
    }

    private void getCluster() throws Exception {
        MonitoringType type = MonitoringType.CLUSTER_DATA;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");
            ObjectName clusterRuntime = (ObjectName) connection.getAttribute(serverRuntime, "ClusterRuntime");
            if (clusterRuntime != null) {
                write(type.filename, concat(getInfo(type.strArray, clusterRuntime), consId, sistName, formatDate(localDate), formatHost(adress), name));
            }
        }
    }

    private void getWeb() throws Exception {
        MonitoringType type1 = MonitoringType.WORK_MANAGER;
        MonitoringType type2 = MonitoringType.WEB_APP;
        Date localDate = new Date();

        if (hasHeader) {
            write(type1.filename, concat(type1.strArray, "console_id;sistema_id;datetime;hostname;server;ApplicationName;WorkManagerName"));
            write(type2.filename, concat(type2.strArray, "console_id;sistema_id;datetime;hostname;server;ApplicationName;ComponentName"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");

            ObjectName[] applicationRuntimeArray = (ObjectName[]) connection.getAttribute(serverRuntime, "ApplicationRuntimes");

            for (ObjectName applicationRuntime : applicationRuntimeArray) {
                ObjectName[] workManagerRuntimeArray = (ObjectName[]) connection.getAttribute(applicationRuntime, "WorkManagerRuntimes");

                for (ObjectName workManagerRuntime : workManagerRuntimeArray) {

                    String applicationName = (String) connection.getAttribute(applicationRuntime, "Name");
                    String workManagerName = (String) connection.getAttribute(workManagerRuntime, "Name");

                    if (Integer.parseInt(connection.getAttribute(workManagerRuntime, "StuckThreadCount").toString()) != 0) {
  //                      collectThreadDump = true;
                    }

                    write(type1.filename,
                            concat(getInfo(type1.strArray, workManagerRuntime), consId, sistName, formatDate(localDate), formatHost(adress), name,
                                    applicationName, workManagerName));

                }

                ObjectName[] componentRuntimeArray = (ObjectName[]) connection.getAttribute(applicationRuntime, "ComponentRuntimes");

                for (ObjectName componentRuntime : componentRuntimeArray) {
                    String componentType = (String) connection.getAttribute(componentRuntime, "Type");

                    if (componentType.toString().equals("WebAppComponentRuntime")) {

                        String applicationName = (String) connection.getAttribute(applicationRuntime, "Name");
                        String componentName = (String) connection.getAttribute(componentRuntime, "ComponentName");

                        write(type2.filename,
                                concat(getInfo(type2.strArray, componentRuntime), consId, sistName, formatDate(localDate), formatHost(adress), name,
                                        applicationName, componentName));

                    }
                }
            }
        }
    }

    private void getChannelRuntime() throws Exception {
        MonitoringType type = MonitoringType.CHANNEL;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {
            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");
            ObjectName[] serverChannelRuntimeArray = (ObjectName[]) connection.getAttribute(serverRuntime, "ServerChannelRuntimes");

            for (ObjectName serverChannelRuntime : serverChannelRuntimeArray) {

                write(type.filename, concat(getInfo(type.strArray, serverChannelRuntime), consId, sistName, formatDate(localDate), formatHost(adress), name));

            }
        }

    }

    @SuppressWarnings("unused")
    private void getThreadDump() throws Exception {
        MonitoringType type = MonitoringType.THREAD_DUMP;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {

            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");
            ObjectName localObjectName = (ObjectName) connection.getAttribute(serverRuntime, "JVMRuntime");

            Scanner in = new Scanner(connection.getAttribute(localObjectName, "ThreadStackDump").toString());
            in.useDelimiter("[\\r]?\\n[\\r]?\\n");

            String result = new String();

            while (in.hasNext()) {
                String strNext = in.next();

                result += strNext.contains("STUCK") ? strNext + "\n" : "";
            }

            if (!result.isEmpty()) {

                write(FIELD_SEPARATOR, "||\n", type.filename,
                        concat(new String[] { "<clob>" + result + "</clob>" }, consId, sistName, formatDate(localDate), formatHost(adress), name));
            }

            in.close();
        }
    }
    
    private void getThreadDumpRaw() throws Exception {
        MonitoringType type = MonitoringType.THREAD_DUMP;
        Date localDate = new Date();

        if (hasHeader) {
            write(type.filename, concat(type.strArray, "console_id;sistema_id;datetime;hostname;server"));
        }

        for (ObjectName serverRuntime : getServerRuntimes()) {

            String name = (String) connection.getAttribute(serverRuntime, "Name");
            String adress = (String) connection.getAttribute(serverRuntime, "ListenAddress");
            ObjectName localObjectName = (ObjectName) connection.getAttribute(serverRuntime, "JVMRuntime");

            String result = connection.getAttribute(localObjectName, "ThreadStackDump").toString();

            if (!result.isEmpty()) {

                write(FIELD_SEPARATOR, "||\n", type.filename,
                        concat(new String[] { "<clob>" + result + "</clob>" }, consId, sistName, formatDate(localDate), formatHost(adress), name));
            }
        }
    }

    private ObjectName[] getServerRuntimes() throws Exception {
        return (ObjectName[]) connection.getAttribute(SERVICE, "ServerRuntimes");
    }

    private ObjectName getDomainConfiguration() throws Exception {
        return (ObjectName) connection.getAttribute(SERVICE, "DomainConfiguration");
    }

    private Object[] getInfo(String[] type, ObjectName objectName) throws Exception {
        List<String> result = new ArrayList<String>();

        for (String key : type) {
            Object obj = connection.getAttribute(objectName, key);
            result.add(obj != null ? obj.toString() : "null");
        }

        return result.toArray();
    }

    private static String formatHost(String host) {
        return host.replaceAll(".internal.timbrasil.com.br", "").replaceAll("/[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}", "");
    }

    private static String formatDate(Date date) {
        return DATE_FORMATTER.format(date);
    }

    private String[] concat(Object[] b, Object... a) {
        String[] c = new String[a.length + b.length];
        System.arraycopy(a, 0, c, 0, a.length);
        System.arraycopy(b, 0, c, a.length, b.length);
        return c;
    }

    private void write(String fileName, String... textArray) throws IOException {
        write(FIELD_SEPARATOR, LINE_SEPARATOR, fileName, textArray);
    }

    private void write(String separatorField, String separatorLine, String fileName, String... textArray) throws IOException {

        FileWriter fileWriter = null;

        try {

            fileWriter = new FileWriter(path + "/" + host + "_" + port + "_test_" + fileName, true);

            for (String text : textArray) {

                fileWriter.write(text);
                fileWriter.write(separatorField);

            }

            fileWriter.write(separatorLine);

        } finally {
            if (fileWriter != null) {
                fileWriter.close();
            }
        }
    }

    public static void main(String[] a) throws Exception {
        if (a != null && 8 > a.length) {
            System.out.print("Usage: java CompleteWebLogicMonitoring adm-host adm-port adm-username adm-password path_output system-id console-id hasHeader");

            System.out.print("<type>" + LINE_SEPARATOR + "Type: ");

            for (MonitoringType type : MonitoringType.values()) {

                System.out.print(type.toString().toLowerCase() + " ");
            }

            System.exit(0);
        }

        CompleteWebLogicMonitoring local = new CompleteWebLogicMonitoring(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);

        Set<String> setType = new LinkedHashSet<String>();

        for (int i = 8; i < a.length; i++) {
            setType.add(a[i].toUpperCase());
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.JROCKIT_RUNTIME.name()) || setType.contains(MonitoringType.JVM_RUNTIME.name())) {
                local.getJRockitRuntime();
            }
        } catch (AttributeNotFoundException e) {
            /* Erro de acordo com regra previamente estabelecida* */
            try {

                local.getJvmRuntime();

            } catch (Exception e1) {
                // e.printStackTrace();
                PrintWriter file = new PrintWriter(new File("stackTrace.log"));
                e1.printStackTrace(file);
                file.close();
            }
        } catch (Exception e2) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e2.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || (setType.contains(MonitoringType.SERVER_START.name()))) {
                local.getServerStart();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.JMS_SERVER.name())) {
                local.getJmsRuntime();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.SERVER_JDBC.name())) {
                local.getJdbcRuntime();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.THREAD_POOL.name())) {
                local.getThreadPoolRuntime();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.EJB_DATA.name())) {
                local.getEJBData();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.CLUSTER_DATA.name())) {
                local.getCluster();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.WEB_APP.name())) {
                local.getWeb();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            if (8 == a.length || setType.contains(MonitoringType.CHANNEL.name())) {
                local.getChannelRuntime();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }

        try {
            //if ((8 == a.length && local.collectThreadDump) || setType.contains(MonitoringType.THREAD_DUMP.name())) {
            //    local.getThreadDump();
            //}
            
            if (8 == a.length || setType.contains(MonitoringType.THREAD_DUMP.name())) {
                local.getThreadDumpRaw();
            }

        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }
        
        try {
            if (setType.contains(MonitoringType.THREAD_DUMP_RAW.name())) {
                local.getThreadDumpRaw();
            }
        } catch (Exception e) {
            // e.printStackTrace();
            PrintWriter file = new PrintWriter(new File("stackTrace.log"));
            e.printStackTrace(file);
            file.close();
        }


        connector.close();
    }
}
