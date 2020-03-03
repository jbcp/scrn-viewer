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
    JSONArray mid_inclusion = new JSONArray();
    JSONArray mid_exclusion = new JSONArray();
    JSONArray visit = new JSONArray();
	JSONObject criteria;
    JSONObject mid;

	String action = request.getParameter("action");

	if(action.equals("load")){
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");
        String provider_id = (String)session.getAttribute("provider_id");

		String project_id = request.getParameter("project_id");
		String eligibility_id = request.getParameter("eligibility_id");

		String total_patient_q = "select count(distinct person_id) from condition_occurrence where provider_id = "+provider_id;
		String total_site_q = "select count(corp_id) from corp;";
		String visit_q = "select criteria_table_source_value, criteria_title, criteria_addition_min_value, criteria_addition_max_value, patient_count, criteria_addition_source_value, criteria_date_source_value from criteria where criteria_table = 4 and criteria_state=1 and project_id="+project_id+" and eligibility_id="+eligibility_id;
        String inclusion_mid = "select m.mid_title, c.patient_num, m.mid_id from mid_criteria m, criteria_patient_count c where m.mid_state = 1 and m.project_id="+project_id+" and m.eligibility_id="+eligibility_id+" and m.mid_id = c.mid_id and c.provider_id="+provider_id;
        String exclusion_mid = "select m.mid_title, c.patient_num, m.mid_id from mid_criteria m, criteria_patient_count c where m.mid_state = 2 and m.project_id="+project_id+" and m.eligibility_id="+eligibility_id+" and m.mid_id = c.mid_id and c.provider_id="+provider_id;

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

        ResultSet rs0 = stmt.executeQuery(visit_q);
        while(rs0.next()){
            criteria = new JSONObject();
			criteria.put("table", rs0.getString(1));
			criteria.put("title", rs0.getString(2));
			criteria.put("value_min", rs0.getString(3));
			criteria.put("value_max", rs0.getString(4));
			criteria.put("count", rs0.getInt(5));
			criteria.put("site", total_site);
			criteria.put("percent", (int)rs0.getInt(5)*100/total_patient);
			criteria.put("total_patient", total_patient);
			criteria.put("criteria_addition_text", rs0.getString(6));
			criteria.put("date_addition_value", rs0.getString(7));
            visit.add(criteria);
        }
        ResultSet rs4 = stmt.executeQuery(inclusion_mid);
        while(rs4.next()){
            mid = new JSONObject();
            mid.put("title", rs4.getString(1));
            mid.put("count", rs4.getInt(2));
            mid.put("mid_id", rs4.getInt(3));
            mid.put("site", total_site);
			mid.put("small", new JSONArray());
            mid_inclusion.add(mid); 
        }

        stmt.close();
        stmt = conn.createStatement();

        ResultSet rs5 = stmt.executeQuery(exclusion_mid);
        while(rs5.next()){
            mid = new JSONObject();
            mid.put("title", rs5.getString(1));
            mid.put("count", rs5.getInt(2));
            mid.put("mid_id", rs5.getInt(3));
            mid.put("site", total_site);
			mid.put("small", new JSONArray());
            mid_exclusion.add(mid);
        }

		for(int i = 0; i < mid_inclusion.size(); i++){
			JSONObject data = (JSONObject)mid_inclusion.get(i);
			JSONArray small = new JSONArray();

			String inclusion_q = "select criteria_table_source_value, criteria_title, criteria_addition_min_value, criteria_addition_max_value, patient_count, criteria_addition_source_value, criteria_date_source_value, mid_id, state, isdivider, criteria_value from criteria where criteria_table != 4 and criteria_state=1 and project_id="+project_id+" and eligibility_id="+eligibility_id+" and mid_id = "+data.get("mid_id");

			ResultSet rs2 = stmt.executeQuery(inclusion_q);
			while(rs2.next()){
				criteria = new JSONObject();
				criteria.put("status", "Inclusion");
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
				criteria.put("mid_id", data.get("mid_id"));
				criteria.put("state", rs2.getString(9));
				criteria.put("divider", rs2.getInt(10));
				criteria.put("id", rs2.getInt(11));
				small.add(criteria);
			}

			data.put("small", small);
		}

		for(int i = 0; i < mid_exclusion.size(); i++){
			JSONObject data = (JSONObject)mid_exclusion.get(i);
			JSONArray small = new JSONArray();

			String exclusion_q = "select criteria_table_source_value, criteria_title, criteria_addition_min_value, criteria_addition_max_value, patient_count, criteria_addition_source_value, criteria_date_source_value, mid_id, state, isdivider, criteria_value from criteria where criteria_state=2 and project_id="+project_id+" and eligibility_id="+eligibility_id+" and mid_id = "+data.get("mid_id");

			ResultSet rs3 = stmt.executeQuery(exclusion_q);
			while(rs3.next()){
				criteria = new JSONObject();
				criteria.put("status", "Exclusion");
				criteria.put("table", rs3.getString(1));
				criteria.put("title", rs3.getString(2));
				criteria.put("value_min", rs3.getString(3));
				criteria.put("value_max", rs3.getString(4));
				criteria.put("count", rs3.getInt(5));
				criteria.put("site", total_site);
				criteria.put("percent", (int)rs3.getInt(5)/total_patient);
				criteria.put("criteria_addition_text", rs3.getString(6));
				criteria.put("date_addition_value", rs3.getString(7));
				criteria.put("mid_id", data.get("mid_id"));
				criteria.put("state", rs3.getString(9));
				criteria.put("divider", rs3.getInt(10));
				criteria.put("id", rs3.getInt(11));
				small.add(criteria);
			}

			data.put("small", small);
		}
		out.println(img_src+"&"+user_name+"&"+visit+"&"+inclusion+"&"+exclusion+"&"+mid_inclusion+"&"+mid_exclusion);
		stmt.close();
		conn.close();
	}
%>
