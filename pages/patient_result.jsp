<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.io.*"%>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="org.json.simple.parser.ParseException"%>
 
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
    } //try

    JSONParser parser2 = new JSONParser();
    JSONObject jsonObject1 = new JSONObject();
    try{
        Object obj = parser2.parse(new FileReader(path_mssql));
        jsonObject1 = (JSONObject) obj;
	}catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } catch (ParseException e) {
        e.printStackTrace();
    }

    JSONObject patient = null;
	JSONObject drug = null;
	JSONObject condition = null;
	JSONObject procedure = null;
	JSONObject doctor = null;
	JSONObject measurement = null;
    JSONArray patient_list = new JSONArray();
	JSONArray doctor_list = new JSONArray();
	JSONArray drug_list = new JSONArray();
	JSONArray drug_d_list = new JSONArray();
	JSONArray condition_list = new JSONArray();
	JSONArray condition_d_list = new JSONArray();
	JSONArray procedure_list = new JSONArray();
	JSONArray procedure_d_list = new JSONArray();
	JSONArray measurement_list = new JSONArray();
	JSONArray measurement_d_list = new JSONArray();


    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    String connectionUrl1 = "jdbc:sqlserver://"+jsonObject1.get("ip")+":"+jsonObject1.get("port")+";" +  "databaseName="+jsonObject1.get("dbName")+";user="+jsonObject1.get("id")+";password="+jsonObject1.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl1);  
    Connection conn_cdm= DriverManager.getConnection(connectionUrl);  

	String project_id = request.getParameter("project_id");
	String eligibility_id = request.getParameter("eligibility_id");

    Statement stmt =null;
	Statement stmt_cdm = null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		int year = calendar.get(Calendar.YEAR); 
		String provider_id = (String)session.getAttribute("provider_id");
		
		String patient_result = "select distinct r.patient_id, r.patient_status from result_patient r where r.project_id = "+project_id+" AND r.eligibility_id ="+eligibility_id+" AND r.provider_id = "+provider_id+";";
		String doctor_result = "select d.patient_num, d.male_num, d.female_num, d.contact from result_site d where d.project_id = "+project_id+" AND d.eligibility_id ="+eligibility_id+" and d.doctor_id ="+provider_id;

		ResultSet rs = stmt.executeQuery(patient_result);
		String gender_text = "";
		while(rs.next()){
			patient = new JSONObject();
			patient.put("cdm_id", rs.getInt(1));

			String patient_name = "select person_name, source_person_id from name..person_name where person_id = "+rs.getInt(1);
			stmt_cdm = conn_cdm.createStatement();
			ResultSet name_rs = stmt_cdm.executeQuery(patient_name);
			while(name_rs.next()){			
				patient.put("name", name_rs.getString(1));
				patient.put("id", name_rs.getString(2));
			}

			String patient_info = "select year_of_birth, gender_concept_id from person where person_id =  "+rs.getInt(1);
			ResultSet info_rs = stmt_cdm.executeQuery(patient_info);
			while(info_rs.next()){
				patient.put("age", year-info_rs.getInt(1)+1);
				if(info_rs.getInt(2) == 8507) gender_text = "MALE";
				else if(info_rs.getInt(2) == 8532) gender_text = "FEMALE";
				patient.put("gender", gender_text);
			}

			String patient_visit = "select p.visit_start_date, p.visit_concept_id from (select max(visit_start_date) as visit_start_date, visit_concept_id, person_id from visit_occurrence group by person_id, visit_concept_id) p where p.person_id =  "+rs.getInt(1);
			ResultSet visit_rs = stmt_cdm.executeQuery(patient_visit);
			String visit_type = "";
			while(visit_rs.next()){
				patient.put("last_visit", visit_rs.getString(1));
				if(visit_rs.getInt(2) == 9201) visit_type = "Inpatient";
				else if(visit_rs.getInt(2) == 9202) visit_type = "Outpatient";
				else if(visit_rs.getInt(2) == 9203) visit_type = "Emergency";
				patient.put("last_visit_type", visit_type);
			}

			patient.put("status", rs.getString(2));
			patient_list.add(patient);
			stmt_cdm.close();

		}

		stmt.close();
		conn_cdm.close();

		stmt = conn.createStatement();

		ResultSet rs1 = stmt.executeQuery(doctor_result);
		while(rs1.next()){
			doctor = new JSONObject();
			doctor.put("patient_num", rs1.getInt(1));
			doctor.put("male_num", rs1.getString(2));
			doctor.put("female_num", rs1.getString(3));

			doctor_list.add(doctor);

		}

		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		String project_info = "Select project_irb_status from project where project_id="+project_id;
		ResultSet pi_rs = stmt.executeQuery(project_info);
		int project_irb_status = 0;
		while(pi_rs.next()){
			project_irb_status = pi_rs.getInt(1);
		}

		out.println(patient_list+"&"+doctor_list+"&"+img_src+"&"+user_name+"&"+project_irb_status);
		stmt.close();
		conn.close();
	}
	else if(action.equals("save")){
		String patient_id = request.getParameter("patient_id");
		String status = request.getParameter("status");
		String provider_id = (String)session.getAttribute("provider_id");

		String save = "update result_patient set patient_status=N'"+status+"' where patient_id ="+patient_id+" and provider_id = "+provider_id+" and project_id ="+project_id +" and eligibility_id="+eligibility_id;

		stmt.executeUpdate(save);
		
		stmt.close();
		conn.close();
	}
	else if(action.equals("loaddurginfo")){
		String patient_id = request.getParameter("patient_id");

		conn.close();
		stmt.close();

		connectionUrl = "CDM ADDRESS";
	    conn= DriverManager.getConnection(connectionUrl);  
		stmt = conn.createStatement();

		String drugd = "SELECT distinct d1.drug_concept_id, c1.concept_name as drug_name, d1.drug_exposure_start_date, d1.drug_exposure_end_date, c2.concept_name as route_concept_id FROM (SELECT drug_concept_id, min(drug_exposure_start_date) as drug_exposure_start_date, max(drug_exposure_end_date) as drug_exposure_end_date, route_concept_id FROM 'Drug Exposure Table' WHERE person_id ="+patient_id+" and drug_exposure_start_date between '2017-06-01' and '2018-12-31' group by drug_concept_id, route_concept_id)d1, dbo.concept c1, dbo.concept c2 WHERE d1.drug_concept_id = c1.concept_id and d1.route_concept_id = c2.concept_id ORDER BY d1.drug_exposure_start_date DESC";
		String drugq = "SELECT distinct d1.drug_concept_id, c1.concept_name as drug_name, d1.drug_exposure_start_date, d1.drug_exposure_end_date, d1.quantity, d1.days_supply, c2.concept_name as route_concept_id,d1.dose_unit_source_value FROM (SELECT * FROM 'Drug Exposure Table' WHERE person_id ="+patient_id+" and drug_exposure_start_date between '2017-06-01' and '2018-12-31'  )d1, concept c1, concept c2 WHERE d1.drug_concept_id = c1.concept_id and d1.route_concept_id = c2.concept_id ORDER BY drug_exposure_start_date DESC;";
		
		ResultSet rs1 = stmt.executeQuery(drugq);
		while(rs1.next()){
			drug = new JSONObject();
			drug.put("drug_id", rs1.getInt(1));
			drug.put("drug_name", rs1.getString(2));
			drug.put("drug_exposure_start", rs1.getString(3));
			drug.put("drug_exposure_end", rs1.getString(4));
			drug.put("quantity", rs1.getInt(5));
			drug.put("days_supply", rs1.getInt(6));
			drug.put("route_concept", rs1.getString(7));
			drug.put("dose_unit", rs1.getString(8));
			drug_list.add(drug);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs11 = stmt.executeQuery(drugd);
		while(rs11.next()){
			drug = new JSONObject();
			drug.put("drug_id", rs11.getInt(1));
			drug.put("drug_name", rs11.getString(2));
			drug.put("drug_exposure_start", rs11.getString(3));
			drug.put("drug_exposure_end", rs11.getString(4));			
			drug.put("route_concept", rs11.getString(5));
			drug_d_list.add(drug);
		}

		out.print(drug_list +"&" + drug_d_list);
		stmt.close();
		conn.close();
	}
	else if(action.equals("loadconditioninfo")){
		String patient_id = request.getParameter("patient_id");

		stmt_cdm = conn_cdm.createStatement();

		String conditionq = "SELECT d1.condition_concept_id, c1.concept_name as condition_name, d1.condition_start_date, c2.concept_name FROM (SELECT * FROM 'Condition Ocurrence table' WHERE person_id ="+patient_id+" and condition_start_date between '2017-06-01' and '2018-12-31')d1, concept c1, concept c2 WHERE d1.condition_concept_id = c1.concept_id and d1.condition_type_concept_id = c2.concept_id ORDER BY condition_start_date DESC;";
		String conditiond = "SELECT d1.condition_concept_id, c1.concept_name as condition_name, d1.condition_start_date, d1.condition_end_date FROM (SELECT condition_concept_id, condition_type_concept_id, min(condition_start_date)as condition_start_date, max(condition_start_date)as condition_end_date FROM 'Condition Ocurrence table' WHERE person_id ="+patient_id+" and condition_start_date between '2017-06-01' and '2018-12-31' group by condition_concept_id,condition_type_concept_id)d1, 'Concept table' c1, 'Concept table' c2 WHERE d1.condition_concept_id = c1.concept_id and d1.condition_type_concept_id = c2.concept_id ORDER BY condition_start_date DESC;";
		ResultSet rs2 = stmt_cdm.executeQuery(conditionq);
		while(rs2.next()){
			condition = new JSONObject();
			condition.put("condition_id", rs2.getInt(1));
			condition.put("condition_name", rs2.getString(2));
			condition.put("condition_start_date", rs2.getString(3));
			condition.put("concept_name", rs2.getString(4));
			condition_list.add(condition);
		}

		ResultSet rs22 = stmt_cdm.executeQuery(conditiond);
		while(rs22.next()){
			condition = new JSONObject();
			condition.put("condition_id", rs22.getInt(1));
			condition.put("condition_name", rs22.getString(2));
			condition.put("condition_start_date", rs22.getString(3));
			condition.put("condition_end_date", rs22.getString(4));
			condition_d_list.add(condition);
		}
		out.print(condition_list+"&"+condition_d_list);
		stmt.close();
		stmt_cdm.close();
		conn.close();
		conn_cdm.close();
	}
	else if(action.equals("loadmeasureinfo")){
		String patient_id = request.getParameter("patient_id");
		String measurementq = "SELECT d1.measurement_concept_id, c1.concept_name as measurement_name, d1.measurement_date, c2.concept_name  as measurement_type_concept_id, value_as_number, range_low, range_high, unit_source_value FROM (SELECT * FROM 'Measurement table' WHERE person_id="+patient_id+" and measurement_date between '2017-06-01' and '2018-12-31' )d1, 'Concept table' c1, 'Concept table' c2 WHERE d1.measurement_concept_id = c1.concept_id and d1.measurement_type_concept_id = c2.concept_id ORDER BY measurement_date DESC;";
		String measurementd = "SELECT distinct d1.measurement_concept_id, c1.concept_name as measurement_name, c2.concept_name  as measurement_type_concept_id, unit_source_value FROM (SELECT * FROM 'Measurement table' WHERE person_id="+patient_id+" and measurement_date between '2017-06-01' and '2018-12-31' )d1, 'Concept table' c1, 'Concept table' c2 WHERE d1.measurement_concept_id = c1.concept_id and d1.measurement_type_concept_id = c2.concept_id;";
		stmt_cdm = conn_cdm.createStatement();

		ResultSet rs3 = stmt_cdm.executeQuery(measurementq);
		while(rs3.next()){
			measurement = new JSONObject();
			measurement.put("measurement_id", rs3.getInt(1));
			measurement.put("measurement_name", rs3.getString(2));
			measurement.put("measurement_date", rs3.getString(3));
			measurement.put("measurement_type", rs3.getString(4));
			measurement.put("value", rs3.getInt(5));
			measurement.put("range_low", rs3.getInt(6));
			measurement.put("range_high", rs3.getInt(7));
			measurement.put("unit", rs3.getString(8));
			measurement_list.add(measurement);
		}

		ResultSet rs33 = stmt_cdm.executeQuery(measurementd);
		while(rs33.next()){
			measurement = new JSONObject();
			measurement.put("measurement_id", rs33.getInt(1));
			measurement.put("measurement_name", rs33.getString(2));
			measurement.put("measurement_type", rs33.getString(3));
			measurement.put("unit", rs33.getString(4));
			measurement_d_list.add(measurement);
		}

		out.print(measurement_list+"&"+measurement_d_list);
		stmt.close();
		conn.close();
	}
	else if(action.equals("loadprocedureinfo")){
		String patient_id = request.getParameter("patient_id");

		stmt_cdm = conn_cdm.createStatement();

		String procedureq = "SELECT d1.procedure_concept_id, c1.concept_name as procedure_name, d1.procedure_date, c2.concept_name FROM (SELECT * FROM 'Procedure table' WHERE person_id ="+patient_id+" and procedure_date between '2017-06-01' and '2018-12-31')d1, concept c1, concept c2 WHERE d1.procedure_concept_id = c1.concept_id and d1.procedure_type_concept_id = c2.concept_id ORDER BY procedure_date DESC;";
		String procedured = "SELECT d1.procedure_concept_id, c1.concept_name as procedure_name, d1.procedure_start_date, d1.procedure_end_date, c2.concept_name FROM (SELECT procedure_concept_id, procedure_type_concept_id, min(procedure_date) as procedure_start_date, max(procedure_date) as procedure_end_date FROM 'Procedure table' WHERE person_id ="+patient_id+" and procedure_date between '2017-06-01' and '2018-12-31' group by procedure_concept_id, procedure_type_concept_id)d1, 'Concept table' c1, 'Concept table' c2 WHERE d1.procedure_concept_id = c1.concept_id and d1.procedure_type_concept_id = c2.concept_id ORDER BY d1.procedure_start_date DESC;";
		ResultSet rs2 = stmt_cdm.executeQuery(procedureq);
		while(rs2.next()){
			procedure = new JSONObject();
			procedure.put("procedure_id", rs2.getInt(1));
			procedure.put("procedure_name", rs2.getString(2));
			procedure.put("procedure_start_date", rs2.getString(3));
			procedure.put("concept_name", rs2.getString(4));
			procedure_list.add(procedure);
		}

		ResultSet rs22 = stmt_cdm.executeQuery(procedured);
		while(rs22.next()){
			procedure = new JSONObject();
			procedure.put("procedure_id", rs22.getInt(1));
			procedure.put("procedure_name", rs22.getString(2));
			procedure.put("procedure_start_date", rs22.getString(3));
			procedure.put("procedure_end_date", rs22.getString(4));
			procedure_d_list.add(procedure);
		}
		out.print(procedure_list+"&"+procedure_d_list);
		stmt.close();
		stmt_cdm.close();
		conn.close();
		conn_cdm.close();
	}


	else if(action.equals("loadmeasuredetail")){
		String concept_id = request.getParameter("concept_id");
		String patient_id = request.getParameter("patient_id");

		String measure_detail = "SELECT d1.measurement_concept_id, d1.measurement_date, value_as_number, range_low, range_high, unit_source_value, c1.concept_name as measurement_name FROM (SELECT * FROM 'Measurement table' WHERE person_id="+patient_id+" and measurement_date between '2017-06-01' and '2018-12-31' )d1, 'Concept table' c1, 'Concept table' c2 WHERE d1.measurement_concept_id="+concept_id+" and d1.measurement_concept_id = c1.concept_id and d1.measurement_type_concept_id = c2.concept_id ORDER BY measurement_date ASC;";
		stmt_cdm = conn_cdm.createStatement();

		ResultSet rs4 = stmt_cdm.executeQuery(measure_detail);
		while(rs4.next()){
			measurement = new JSONObject();
			measurement.put("measurement_id", rs4.getInt(1));
			measurement.put("measurement_date", rs4.getString(2));
			measurement.put("value", rs4.getInt(3));
			measurement.put("range_low", rs4.getInt(4));
			measurement.put("range_high", rs4.getInt(5));
			measurement.put("unit", rs4.getString(6));
			measurement.put("measurement_name", rs4.getString(7));
			measurement_list.add(measurement);
		}

		out.print(measurement_list);
		stmt.close();
		conn.close();

	}

	else if(action.equals("loadconditiondetail")){
		String concept_id = request.getParameter("concept_id");
		String patient_id = request.getParameter("patient_id");

		conn.close();
		stmt.close();

		connectionUrl = "CDM ADDRESS";
	    conn= DriverManager.getConnection(connectionUrl);  
		stmt = conn.createStatement();

		String condition_detail = "SELECT d1.condition_concept_id, c1.concept_name as condition_name, d1.condition_start_date, c2.concept_name FROM (SELECT * FROM 'Condition Occurrence table' WHERE person_id ="+patient_id+" and condition_start_date between '2017-06-01' and '2018-12-31')d1, 'Concept table' c1, 'Concept table' c2 WHERE d1.condition_concept_id ="+concept_id+" and d1.condition_concept_id = c1.concept_id and d1.condition_type_concept_id = c2.concept_id ORDER BY condition_start_date ASC";
		ResultSet rs5 = stmt.executeQuery(condition_detail);
		while(rs5.next()){
			condition = new JSONObject();
			condition.put("condition_id", rs5.getInt(1));
			condition.put("condition_name", rs5.getString(2));
			condition.put("condition_start_date", rs5.getString(3));
			condition.put("concept_name", rs5.getString(4));
			condition_list.add(condition);
		}
		out.print(condition_list);
		stmt.close();
		conn.close();


	}
	else if(action.equals("loadproceduredetail")){
		String concept_id = request.getParameter("concept_id");
		String patient_id = request.getParameter("patient_id");

		conn.close();
		stmt.close();

		connectionUrl = "CDM ADDRESS";
	    conn= DriverManager.getConnection(connectionUrl);  
		stmt = conn.createStatement();

		String condition_detail = "SELECT d1.procedure_concept_id, c1.concept_name as procedure_name, d1.procedure_date, c2.concept_name FROM (SELECT * FROM 'Procedure Occurrence table' WHERE person_id ="+patient_id+" and procedure_date between '2017-06-01' and '2018-12-31')d1, 'Concept table' c1, 'Concept table' c2 WHERE d1.procedure_concept_id ="+concept_id+" and d1.procedure_concept_id = c1.concept_id and d1.procedure_type_concept_id = c2.concept_id ORDER BY d1.procedure_date ASC";
		ResultSet rs5 = stmt.executeQuery(condition_detail);
		while(rs5.next()){
			condition = new JSONObject();
			condition.put("procedure_id", rs5.getInt(1));
			condition.put("procedure_name", rs5.getString(2));
			condition.put("procedure_start_date", rs5.getString(3));
			condition.put("concept_name", rs5.getString(4));
			condition_list.add(condition);
		}
		out.print(condition_list);
		stmt.close();
		conn.close();


	}
	else if(action.equals("loaddrugdetail")){
		String concept_id = request.getParameter("concept_id");
		String patient_id = request.getParameter("patient_id");

		conn.close();
		stmt.close();

		connectionUrl = "CDM ADDRESS";
	    conn= DriverManager.getConnection(connectionUrl);  
		stmt = conn.createStatement();

		String drug_detail = "SELECT d1.drug_concept_id, c1.concept_name as drug_name, d1.drug_exposure_start_date, d1.drug_exposure_end_date,  d1.quantity, d1.days_supply, c2.concept_name as route_concept_id,d1.dose_unit_source_value FROM (SELECT * FROM 'Drug exposure table' WHERE person_id ="+patient_id+" and drug_exposure_start_date between '2017-06-01' and '2018-12-31')d1, dbo.concept c1, dbo.concept c2 WHERE d1.drug_concept_id ="+concept_id+" and d1.drug_concept_id = c1.concept_id and d1.route_concept_id = c2.concept_id ORDER BY drug_exposure_start_date ASC";
		ResultSet rs6 = stmt.executeQuery(drug_detail);
		while(rs6.next()){
			drug = new JSONObject();
			drug.put("drug_id", rs6.getInt(1));
			drug.put("drug_name", rs6.getString(2));
			drug.put("drug_exposure_start", rs6.getString(3));
			drug.put("drug_exposure_end", rs6.getString(4));
			drug.put("quantity", rs6.getInt(5));
			drug.put("days_supply", rs6.getInt(6));
			drug.put("route_concept", rs6.getString(7));
			drug.put("dose_unit", rs6.getString(8));
			drug_list.add(drug);
		}
		out.print(drug_list);
		stmt.close();
		conn.close();


	}

%>
