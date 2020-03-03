<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat"%>

 
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
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } catch (ParseException e) {
        e.printStackTrace();
    } 

	String date = request.getParameter("date");
	String eligibility_id = request.getParameter("eligibility_id");

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
	
	String ip_address = request.getRemoteAddr();


    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  

    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		JSONObject criteria = null;
		JSONObject visit = null;
		JSONArray populations = new JSONArray();
		JSONArray criteria_set_in = new JSONArray();
		JSONArray criteria_set_ex = new JSONArray();

		String status_data = "";

		String a2 = "select * from criteria_HIS where eligibility_id = "+eligibility_id+" and edit_date = '"+date+"' and criteria_table = 4 order by criteria_id asc";
		ResultSet rs2 = stmt.executeQuery(a2);
		while(rs2.next()){
			visit = new JSONObject();
			visit.put("type", "visit");
			visit.put("value", rs2.getString(21));
			visit.put("period", rs2.getInt(8));
			populations.add(visit);
		}

		String a4 = "select * from mid_criteria_HIS where eligibility_id = "+eligibility_id+" and edit_date = '"+date+"' and mid_state = 1 order by mid_id asc";
		ResultSet rs4 = stmt.executeQuery(a4);
		while(rs4.next()){
			criteria = new JSONObject();
			criteria.put("title", rs4.getString(4));
			criteria.put("id", rs4.getInt(1));
			criteria.put("small", new JSONArray());
			criteria_set_in.add(criteria);
		}

		String a5 = "select * from mid_criteria_HIS where eligibility_id = "+eligibility_id+" and edit_date = '"+date+"' and mid_state = 2 order by mid_id asc";
		ResultSet rs5 = stmt.executeQuery(a5);
		while(rs5.next()){
			criteria = new JSONObject();
			criteria.put("title", rs5.getString(4));
			criteria.put("id", rs5.getInt(1));
			criteria_set_ex.add(criteria);
		}

		for(int i = 0; i < criteria_set_in.size(); i++){
			JSONObject data_output = (JSONObject)criteria_set_in.get(i);
			JSONArray criterias = new JSONArray();

			String a3 = "select * from criteria_HIS where edit_date = '"+date+"' and criteria_table <> 4 and mid_id="+data_output.get("id")+" order by criteria_id asc";
			ResultSet rs3 = stmt.executeQuery(a3);
			while(rs3.next()){
				criteria = new JSONObject();
				criteria.put("title", rs3.getString(10));
				int status_int = rs3.getInt(9);
				
				if(status_int == 1){
					status_data = "inclusion";
				}
				else if(status_int == 2){
					status_data = "exclusion";
				}
				
				int divider_int = rs3.getInt(23);
				String divider_data = "";
				if(divider_int == 0) divider_data = "no";
				else divider_data = "yes";

				criteria.put("status", status_data);
				criteria.put("table", rs3.getString(19));
				criteria.put("attribute", rs3.getInt(8));
				criteria.put("addition", rs3.getString(20));
				criteria.put("addition_query", rs3.getString(11));
				criteria.put("addition_date", rs3.getString(21));
				criteria.put("value_min", rs3.getString(12));
				criteria.put("value_max", rs3.getString(13));
				criteria.put("measure_count", rs3.getString(17));
				criteria.put("measure_method", rs3.getString(16));
				criteria.put("min_condition", rs3.getString(14));
				criteria.put("max_condition", rs3.getString(15));
				criteria.put("heir", rs3.getInt(6));
				criteria.put("condition", rs3.getInt(7));
				criteria.put("state", rs3.getString(22));
				criteria.put("isdivider", divider_data);
				criteria.put("id", rs3.getInt(1));
				criterias.add(criteria);
			}
			data_output.put("small", criterias);

		}

		for(int i = 0; i < criteria_set_ex.size(); i++){
			JSONObject data_output = (JSONObject)criteria_set_ex.get(i);
			JSONArray criterias = new JSONArray();
			String a3 = "select * from criteria_HIS where edit_date = '"+date+"' and criteria_table <> 4 and mid_id="+data_output.get("id")+" order by criteria_id asc";
			ResultSet rs3 = stmt.executeQuery(a3);
			while(rs3.next()){
				criteria = new JSONObject();
				criteria.put("title", rs3.getString(10));
				int status_int = rs3.getInt(9);
				
				if(status_int == 1){
					status_data = "inclusion";
				}
				else if(status_int == 2){
					status_data = "exclusion";
				}

				int divider_int = rs3.getInt(23);
				String divider_data = "";
				if(divider_int == 0) divider_data = "no";
				else divider_data = "yes";
				
				criteria.put("status", status_data);
				criteria.put("table", rs3.getString(19));
				criteria.put("attribute", rs3.getInt(8));
				criteria.put("addition", rs3.getString(20));
				criteria.put("addition_query", rs3.getString(11));
				criteria.put("addition_date", rs3.getString(21));
				criteria.put("value_min", rs3.getString(12));
				criteria.put("value_max", rs3.getString(13));
				criteria.put("measure_count", rs3.getString(17));
				criteria.put("measure_method", rs3.getString(16));
				criteria.put("min_condition", rs3.getString(14));
				criteria.put("max_condition", rs3.getString(15));
				criteria.put("heir", rs3.getInt(6));
				criteria.put("condition", rs3.getInt(7));
				criteria.put("state", rs3.getString(22));
				criteria.put("isdivider", divider_data);
				criteria.put("id", rs3.getInt(1));
				criterias.add(criteria);
			}
			data_output.put("small", criterias);
		}

		out.println(criteria_set_in +"&"+criteria_set_ex+"&"+populations);
		stmt.close();
		conn.close();
	}

%>
