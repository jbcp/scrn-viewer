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
	String fileName_cdm = "cdm.ini";
    String fileDir = "/dbsource";
    String filePath = request.getRealPath(fileDir) + "/"; 
	String path_cdm = filePath + fileName_cdm;
	String path_mssql = filePath + fileName;
    JSONParser parser1 = new JSONParser();
    JSONObject jsonObject = new JSONObject();
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

    JSONParser parser2 = new JSONParser();
    JSONObject jsonObject1 = new JSONObject();
    try{
        Object obj = parser2.parse(new FileReader(path_cdm));
        jsonObject1 = (JSONObject) obj;
	}catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } catch (ParseException e) {
        e.printStackTrace();
    } 

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    String connectionUrl1 = "jdbc:sqlserver://"+jsonObject1.get("ip")+":"+jsonObject1.get("port")+";" +  "databaseName="+jsonObject1.get("dbName")+";user="+jsonObject1.get("id")+";password="+jsonObject1.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  
    Connection conn_cdm= DriverManager.getConnection(connectionUrl1);  

	String project_id = request.getParameter("project_id");
	String eligibility_id = request.getParameter("eligibility_id");

    Statement stmt =null;
	Statement stmt_cdm = null;
    stmt = conn.createStatement();
	stmt_cdm = conn_cdm.createStatement();

	String action = request.getParameter("action");
    
	if(action.equals("demographic")){
		JSONArray demo_people = new JSONArray();
		String demographic_pre = "select person_id from result_protocol_detail where project_id ="+project_id+" and eligibility_id="+eligibility_id;

		ResultSet rs = stmt.executeQuery(demographic_pre);
		while(rs.next()){
            JSONObject person = new JSONObject();
			person.put("person_id", rs.getInt(1));
			
			String demographic = "select p.year_of_birth, p.month_of_birth, p.day_of_birth, p.gender_source_value from dbo.PERSON p where p.person_id="+ rs.getInt(1);
			ResultSet demo_rs = stmt_cdm.executeQuery(demographic);
			while(demo_rs.next()){
				person.put("year_of_birth", demo_rs.getInt(1));
				person.put("month_of_birth", demo_rs.getInt(2));
				person.put("day_of_birth", demo_rs.getInt(3));
				person.put("gender_source_value", demo_rs.getString(4));
			}			
            demo_people.add(person);
		}


		out.println(demo_people);
		stmt.close();
		stmt_cdm.close();
		conn.close();
		conn_cdm.close();
	}

    if(action.equals("condition")){
		JSONArray diag_people = new JSONArray();
		String diagnosis_pre = "select person_id from result_protocol_detail where project_id ="+project_id+" and eligibility_id="+eligibility_id;

		ResultSet rs = stmt.executeQuery(diagnosis_pre);
		while(rs.next()){
            JSONObject person = new JSONObject();
			person.put("person_id", rs.getInt(1));
			String diagnosis = "select p.concept_name, c.condition_start_date, c.condition_type_concept_id from dbo.CONDITION_OCCURRENCE c, dbo.concept p where c.condition_concept_id = p.concept_id and c.person_id = "+rs.getInt(1);
			ResultSet diag_rs = stmt_cdm.executeQuery(diagnosis);
			while(diag_rs.next()){
				person.put("condition_concept_name", diag_rs.getString(1));
				person.put("condition_start_date", diag_rs.getString(2));
				person.put("condition_type_concept_id", diag_rs.getInt(3));
			}
            diag_people.add(person);
		}


		out.println(diag_people);
		stmt.close();
		stmt_cdm.close();
		conn.close();
		conn_cdm.close();
	}

    if(action.equals("medication")){
		JSONArray medi_people = new JSONArray();
		String medication_pre = "select person_id from result_protocol_detail where project_id ="+project_id+" and eligibility_id="+eligibility_id;

		ResultSet rs = stmt.executeQuery(medication_pre);
		while(rs.next()){
            JSONObject person = new JSONObject();
			person.put("person_id", rs.getInt(1));
			String medication = "select c.concept_name, p.drug_exposure_start_date, p.drug_exposure_end_date from dbo.DRUG_EXPOSURE p, dbo.concept c where p.drug_concept_id = c.concept_id and p.person_id = "+rs.getInt(1);
			ResultSet medi_rs = stmt_cdm.executeQuery(medication);
			while(medi_rs.next()){
				person.put("drug_concept_name", medi_rs.getString(1));
				person.put("drug_exposure_start_date", medi_rs.getString(2));
				person.put("drug_exposure_end_date", medi_rs.getString(3));
			}
            medi_people.add(person);
		}


		out.println(medi_people);
		stmt.close();
		stmt_cdm.close();
		conn.close();
		conn_cdm.close();
    }

	if(action.equals("measurement")){
		JSONArray meas_people = new JSONArray();
		String measure_pre = "select person_id from result_protocol_detail where project_id ="+project_id+" and eligibility_id="+eligibility_id;

		ResultSet rs = stmt.executeQuery(measure_pre);
		while(rs.next()){
            JSONObject person = new JSONObject();
			person.put("person_id", rs.getInt(1));
			String measurement = "select c.concept_name, p.measurement_date, p.range_high, p.range_low, p.value_as_number from dbo.Measurement p, dbo.concept c where p.measurement_concept_id = c.concept_id and p.person_id = "+ rs.getInt(1);
			ResultSet meas_rs = stmt_cdm.executeQuery(measurement);
			while(meas_rs.next()){
				person.put("measurement_concept_name", meas_rs.getString(1));
				person.put("range_high", meas_rs.getString(2));
				person.put("range_low", meas_rs.getString(3));
				person.put("value_as_number", meas_rs.getInt(4));

			}
            meas_people.add(person);
		}


		out.println(meas_people);
		stmt.close();
		stmt_cdm.close();
		conn.close();
		conn_cdm.close();
    }

	if(action.equals("procedure")){
		JSONArray proc_people = new JSONArray();
		String proc_pre = "select person_id from result_protocol_detail where project_id ="+project_id+" and eligibility_id="+eligibility_id;

		ResultSet rs = stmt.executeQuery(proc_pre);
		while(rs.next()){
            JSONObject person = new JSONObject();
			person.put("person_id", rs.getInt(1));
			String procedure = "select c.concept_name, p.procedure_date, from dbo.Procedure p, dbo.concept c where p.procedure_concept_id = c.concept_id and p.person_id = "+ rs.getInt(1);
			ResultSet proc_rs = stmt_cdm.executeQuery(procedure);
			while(proc_rs.next()){
				person.put("procedure_concept_name", proc_rs.getString(1));
				person.put("procedure_date", proc_rs.getString(2));
			}
            proc_people.add(person);
		}


		out.println(proc_people);
		stmt.close();
		stmt_cdm.close();
		conn.close();
		conn_cdm.close();
    }
%>
