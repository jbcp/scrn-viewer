<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="java.net.URLDecoder" %>
<%@page import="java.util.Calendar" %>
<%@page import="java.util.Date"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat" %>

 
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

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");
        int user_id = (Integer)session.getAttribute("user_id");
        String provider_id = (String)session.getAttribute("provider_id");
		String project_id = request.getParameter("Project_id");
		String eligibility_id = request.getParameter("Eligibility_id");
		String person = "select person_list from result_protocol where project_id="+project_id+" and eligibility_id="+eligibility_id+" and provider_id ="+provider_id;
		String person_data="";
		String condition_data="";
		String drug_data = "";
        String result_patient_q = "select patient_num from criteria_patient_count where project_id="+project_id+" and eligibility_id="+eligibility_id+" and provider_id="+provider_id+" and mid_id = (select max(mid_id) from mid_criteria where project_id="+project_id+" and eligibility_id="+eligibility_id+");";
        String total_patient_q = "select count(person_id) from person;";
        String doctor_patient_q = "select count(distinct person_id) from condition_occurrence where provider_id = "+provider_id;

        int total_patient = 0;
        int doctor_patient = 0; 
        int result_patient = 0;

        ResultSet rs4 = stmt.executeQuery(result_patient_q);
        while(rs4.next()){
            result_patient = rs4.getInt(1);
        }

		ResultSet rs= stmt.executeQuery(person);
		while(rs.next()){
			person_data = rs.getString(1);
		}

		stmt.close();
        conn.close();

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

    	connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
		conn= DriverManager.getConnection(connectionUrl);  
		stmt = conn.createStatement();

        ResultSet rs1 = stmt.executeQuery(total_patient_q);
        while(rs1.next()){
            total_patient = rs1.getInt(1);
        }

        ResultSet rs2 = stmt.executeQuery(doctor_patient_q);
        while(rs2.next()){
            doctor_patient = rs2.getInt(1);
        }

		out.println(img_src+"&"+user_name+"&"+person_data+"&"+total_patient+"&"+doctor_patient+"&"+result_patient+"&"+project_id);
		stmt.close();
		conn.close();

	}
%>
