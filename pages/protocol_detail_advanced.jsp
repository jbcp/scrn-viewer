<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.SimpleDateFormat" %>

<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
 
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
    } //try


    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");


    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		String protocol_id = request.getParameter("protocol_id");
		String person = "select person from protocol_detail_result where protocol_id ="+protocol_id;
		String condition = "select condition from protocol_detail_result p where p.protocol_id ="+protocol_id;
		String drug = "select drug from protocol_detail_result where protocol_id ="+protocol_id;
		String person_data="";
		String condition_data="";
		String drug_data = "";

		ResultSet rs= stmt.executeQuery(person);
		while(rs.next()){
			person_data = 	rs.getString(1);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs1 = stmt.executeQuery(condition);
		while(rs1.next()){
			condition_data = rs1.getString(1);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs2 = stmt.executeQuery(drug);
		while(rs2.next()){
			drug_data = rs2.getString(1);
		}

		out.println(img_src+"&"+user_name+"&"+person_data+"&"+condition_data+"&"+drug_data);
		stmt.close();
		conn.close();

	}
%>
