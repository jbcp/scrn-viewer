<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@ page import="java.net.URLDecoder" %>

<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
 
<%
	String fileName = "mssql.ini"; 
	String fileName_cdm = "cdm.ini";
    String fileDir = "/dbsource";
    String filePath = request.getRealPath(fileDir) + "/";
	String path_cdm = filePath + fileName_cdm;
	String path_mssql = filePath + fileName;
    JSONParser parser1 = new JSONParser();
    JSONObject jsonObject = new JSONObject();
    try{
        Object obj = parser1.parse(new FileReader(path_cdm));
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

	JSONArray inclusion = new JSONArray();
	JSONArray exclusion = new JSONArray();
	JSONObject criteria;

	String action = request.getParameter("action");

	if(action.equals("load")){
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		String project_id = request.getParameter("project_id");
		String eligibility_id = request.getParameter("eligibility_id");

		String total_patient_q = "select count(person_id) from 'Patient table';";
		String total_site_q = "select count(corp_id) from corp;";
		String inclusion_q = "select criteria_table_source_value, criteria_title, criteria_addition_min_value, criteria_addition_max_value, patient_count, criteria_addition_source_value, criteria_date_source_value from criteria where criteria_state=1 and project_id="+project_id+" and eligibility_id="+eligibility_id;
		String exclusion_q = "select criteria_table_source_value, criteria_title, criteria_addition_min_value, criteria_addition_max_value, patient_count, criteria_addition_source_value, criteria_date_source_value from criteria where criteria_state=2 and project_id="+project_id+" and eligibility_id="+eligibility_id;

		int total_patient = 0;
		int total_site = 0;
		
		ResultSet rs = stmt.executeQuery(total_patient_q);
		while(rs.next()){
			total_patient = rs.getInt(1);
		}

		conn.close();
		stmt.close();

		try{
			Object obj = parser1.parse(new FileReader(path_mssql));
			jsonObject = (JSONObject) obj;
		}catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		}

    	connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
	    conn= DriverManager.getConnection(connectionUrl);  
		stmt = conn.createStatement();

		ResultSet rs1 = stmt.executeQuery(total_site_q);
		while(rs1.next()){
			total_site = rs1.getInt(1)-1;
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs2 = stmt.executeQuery(inclusion_q);
		while(rs2.next()){
			criteria = new JSONObject();
			criteria.put("table", rs2.getString(1));
			criteria.put("title", rs2.getString(2));
			criteria.put("value_min", rs2.getString(3));
			criteria.put("value_max", rs2.getString(4));
			criteria.put("count", rs2.getInt(5));
			criteria.put("site", total_site);
			criteria.put("percent", (int)rs2.getInt(5)*100/total_patient);
			criteria.put("total_patient", total_patient);
			criteria.put("criteria_addition_text", rs2.getString(6));
			criteria.put("date_addition_value", rs2.getString(7));
			inclusion.add(criteria);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs3 = stmt.executeQuery(exclusion_q);
		while(rs3.next()){
			criteria = new JSONObject();
			criteria.put("table", rs3.getString(1));
			criteria.put("title", rs3.getString(2));
			criteria.put("value_min", rs3.getString(3));
			criteria.put("value_max", rs3.getString(4));
			criteria.put("count", rs3.getInt(5));
			criteria.put("site", total_site);
			criteria.put("percent", (int)rs3.getInt(5)/total_patient);
			criteria.put("criteria_addition_text", rs3.getString(6));
			criteria.put("date_addition_value", rs3.getString(7));
			exclusion.add(criteria);
		}

		out.println(img_src+"&"+user_name+"&"+inclusion+"&"+exclusion);
		stmt.close();
		conn.close();
	}
%>
