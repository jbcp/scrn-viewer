<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*" %>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.oreilly.servlet.*"%>
<head>
<script type="text/javascript" src="./print_log.js" ></script> 
<script>print_log("logout");</script></head>
<%
    String fileName = "mssql.ini";
    String fileDir = "/dbsource";
    String filePath = request.getRealPath(fileDir) + "/";
    filePath += fileName; 
    JSONParser parser1 = new JSONParser();
    JSONObject jsonObject = new JSONObject();
    try{
        Object obj = parser1.parse(new FileReader(filePath));
        jsonObject = (JSONObject) obj;
    }catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } catch (ParseException e) {
        e.printStackTrace();
    } 

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

    DecimalFormat df = new DecimalFormat("00");
    Calendar calendar = Calendar.getInstance();

    String year = Integer.toString(calendar.get(Calendar.YEAR)); 
    String month = df.format(calendar.get(Calendar.MONTH) + 1); 
    String day = df.format(calendar.get(Calendar.DATE)); 
    String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
    String minute = df.format(calendar.get(Calendar.MINUTE));
    String second = df.format(calendar.get(Calendar.SECOND));

    String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

    int mem_id = (Integer)session.getAttribute("user_id");

	String ip_address = request.getRemoteAddr();

    String a3 = "insert system_log(system_log_date, system_log_reason, mem_id, ip_address, code) values('"+today+"', N'Successfully logged out', "+mem_id+", N'"+ip_address+"', 1001)"; 
    stmt.executeUpdate(a3);

    session.invalidate();
    response.sendRedirect("login.jsp");
%>