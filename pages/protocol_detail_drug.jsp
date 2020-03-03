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
    } 


    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");
		String project_id = request.getParameter("project_id");
        String eligibility_id = request.getParameter("eligibility_id");
		String drug = "select drug_list from result_protocol where project_id="+project_id+" and eligibility_id="+eligibility_id;
		String drug_data = "";

		ResultSet rs2 = stmt.executeQuery(drug);
		while(rs2.next()){
			drug_data = rs2.getString(1);
		}

		out.println(img_src+"&"+user_name+"&"+drug_data);
		stmt.close();
		conn.close();
	}
    else if(action.equals("execute")){
        String project_id = request.getParameter("project_id");
		String eligibility_id = request.getParameter("eligibility_id");
		String exe_check = "select drug_list, drug_exe_datetime from result_protocol where project_id ="+project_id+" and eligibility_id ="+eligibility_id;
		int drug_data=0;
        String drug_date = "";

		int user_id = (Integer)session.getAttribute("user_id");
		String provider = (String)session.getAttribute("provider_id");

		ResultSet rs2 = stmt.executeQuery(exe_check);
		while(rs2.next()){
            if(rs2.getString(1) == null) drug_data = 0;
            else drug_data = 1;
            drug_date = rs2.getString(2);
		}

        if(drug_date == null){
            DecimalFormat df = new DecimalFormat("00");
            Calendar calendar = Calendar.getInstance();

            String year = Integer.toString(calendar.get(Calendar.YEAR)); 
            String month = df.format(calendar.get(Calendar.MONTH) + 1); 
            String day = df.format(calendar.get(Calendar.DATE)); 
            String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
            String minute = df.format(calendar.get(Calendar.MINUTE));
            String second = df.format(calendar.get(Calendar.SECOND));

            String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

            String execute = "update result_protocol set drug_exe_datetime = '"+today+"' where project_id ="+project_id+" and eligibility_id ="+eligibility_id;
            stmt.executeUpdate(execute);
        
        }
		out.println(drug_data+"&"+drug_date+"&"+provider+"/"+user_id);
		stmt.close();
		conn.close();
	}
    else if(action.equals("refresh")){
        String project_id = request.getParameter("project_id");
		String eligibility_id = request.getParameter("eligibility_id");

		int user_id = (Integer)session.getAttribute("user_id");
		String provider = (String)session.getAttribute("provider_id");

        String refresh_drug = "update result_protocol set drug_list = NULL where project_id ="+project_id+" and eligibility_id ="+eligibility_id;
        stmt.executeUpdate(refresh_drug);

        DecimalFormat df = new DecimalFormat("00");
        Calendar calendar = Calendar.getInstance();

        String year = Integer.toString(calendar.get(Calendar.YEAR)); 
        String month = df.format(calendar.get(Calendar.MONTH) + 1); 
        String day = df.format(calendar.get(Calendar.DATE)); 
        String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
        String minute = df.format(calendar.get(Calendar.MINUTE));
        String second = df.format(calendar.get(Calendar.SECOND));

        String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

        String refresh_date = "update result_protocol set drug_exe_datetime = '"+today+"' where project_id ="+project_id+" and eligibility_id ="+eligibility_id;
        stmt.executeUpdate(refresh_date);

        out.println(provider+"/"+user_id);
		stmt.close();
		conn.close();

    }

%>
