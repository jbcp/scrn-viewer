<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

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

    JSONObject project1 = null;
    JSONArray project = new JSONArray();
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");


    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load2")){
        String table = request.getParameter("table");
		String project_id = request.getParameter("project_id");
        String a1 ="";
        
        switch(table){
            case "Projects":
                a1 = "select project_protocol_id from project where project_id="+project_id;
            break;

            case "User define set":
                a1 = "select define_title from user_define where define_id="+project_id;
            break;

        }
        String project_title = "";
		ResultSet rs = stmt.executeQuery(a1);

		while(rs.next()){
            project_title = rs.getString(1);
		}

		out.println(project_title);
		stmt.close();
		conn.close();
	}

    if(action.equals("load3")){
		String project_id = request.getParameter("project_id");
   		String eligibility_id = request.getParameter("eligibility_id");

        String a1 = "select project_protocol_id from project where project_id="+project_id;
        String project_title = "";
		ResultSet rs = stmt.executeQuery(a1);

		while(rs.next()){
            project_title = rs.getString(1);
		}

        String a2 = "select eligibility_title from eligibility where project_id="+project_id+" and eligibility_id ="+eligibility_id;
        String eligibility_title = "";
		ResultSet rs2 = stmt.executeQuery(a2);

		while(rs2.next()){
            eligibility_title = rs2.getString(1);
		}

		out.println(project_title+"&"+eligibility_title);
		stmt.close();
		conn.close();
	}



%>
