<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.lang.Math" %>

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


    JSONObject doctor = null;
	JSONObject graph = null;
	JSONObject info = null;
    JSONArray doctor_list = new JSONArray();
	JSONArray graph_data = new JSONArray();

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");


    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  

	String study_id = request.getParameter("study_id");

    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		String query_id = request.getParameter("query_id");

		String result_setting = "Update doctor_result set contact = 1 where study_id="+study_id+"AND qeury_id="+query_id+"AND doctor_id in (select mem_id from study_invest where study_id = "+study_id+");";
		String query_site = "select count(distinct corp_id) from doctor_result where study_id = "+study_id+" AND qeury_id ="+query_id;
		String total_site = "select count(corp_id) from corp where corp_type Like N'site'";
		String query_doctor = "select count(distinct doctor_id) from doctor_result where study_id = "+study_id+" AND qeury_id ="+query_id;
		String total_doctor = "select count(PROVIDER_NAME) from 'provider email mapping table'";
		String qeury_patient = 	"select sum(r.patient_num) from scrn_cloud..doctor_result r, 'provider email-tel mapping table' p, scrn_cloud..member m  where r.doctor_id = p.PROVIDER_ID and m.mem_mail = P.EMAIL and r.study_id = "+study_id+" AND r.qeury_id ="+query_id;
		String total_patient = "select count(*) from 'Patient table'";
		String qeury_patient_max = "select max(patient_num) from doctor_result where study_id = "+study_id+" AND qeury_id ="+query_id;
		String query_info = "select query_title from query where study_id = "+study_id+" AND query_id ="+query_id;
		String doctor_result = "select c.corp_name_kr, d.doctor_id, d.patient_num, d.male_num, d.female_num, d.contact, d.interest, p.provider_name, p.dept from scrn_cloud..doctor_result d, scrn_cloud..corp c, 'provider name mapping table' p where d.study_id = "+study_id+" AND d.qeury_id ="+query_id+" and d.corp_id = c.corp_id and d.doctor_id =p.provider_id;";

		stmt.executeUpdate(result_setting);
		stmt.close();
		stmt = conn.createStatement();

		graph = new JSONObject();
		int query_site_num = 0;
		int total_site_num = 0;
		ResultSet rs1 = stmt.executeQuery(query_site);
		while(rs1.next()){
			query_site_num = rs1.getInt(1);
			graph.put("query_site", rs1.getInt(1));
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs2 = stmt.executeQuery(total_site);
		while(rs2.next()){
			total_site_num = rs2.getInt(1);
			graph.put("total_site", rs2.getInt(1));
			graph.put("percent_site", ((query_site_num*100)/total_site_num));
		}
		graph_data.add(graph);

		stmt.close();
		stmt = conn.createStatement();

		graph = new JSONObject();
		int query_doctor_num = 0;
		int total_doctor_num = 0;
		ResultSet rs3 = stmt.executeQuery(query_doctor);
		while(rs3.next()){
			query_doctor_num = rs3.getInt(1);
			graph.put("query_doctor", rs3.getInt(1));
		}
		
		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs4 = stmt.executeQuery(total_doctor);
		while(rs4.next()){
			total_doctor_num = 300;
			graph.put("total_doctor", rs4.getInt(1));
			
			graph.put("percent_doctor", ((query_doctor_num*100)/total_doctor_num));
		}

		graph_data.add(graph);

		stmt.close();
		stmt = conn.createStatement();

		graph = new JSONObject();
		int qeury_patient_num = 0;
		int total_patient_num = 0;
		ResultSet rs5 = stmt.executeQuery(qeury_patient);
		while(rs5.next()){
			qeury_patient_num = rs5.getInt(1);
			graph.put("query_patient", rs5.getInt(1));
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs6 = stmt.executeQuery(total_patient);
		while(rs6.next()){
			total_patient_num = rs6.getInt(1);
			graph.put("total_patient", rs6.getInt(1));
			graph.put("percent_patient", ((qeury_patient_num*100)/total_patient_num));
		}
		
		graph_data.add(graph);

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs = stmt.executeQuery(doctor_result);

		while(rs.next()){
			doctor = new JSONObject();
			doctor.put("site", rs.getString(1));
			doctor.put("doctor_id", rs.getString(2));
			doctor.put("patient_num", rs.getInt(3));
			doctor.put("male_num", rs.getString(4));
			doctor.put("female_num", rs.getString(5));
			doctor.put("contact", rs.getInt(6));
			doctor.put("interest", rs.getInt(7));
			doctor.put("doctor_name", rs.getString(8));
			doctor.put("doctor_dept", rs.getString(9));

			doctor_list.add(doctor);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs_t = stmt.executeQuery(query_info);
		String query_title = "";
		while(rs_t.next()){
			query_title = rs_t.getString(1);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs_max = stmt.executeQuery(qeury_patient_max);
		int max_patient = 0;
		while(rs_max.next()){
			max_patient = rs_max.getInt(1);
		}
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		out.println(doctor_list+"&"+graph_data+"&"+query_title+"&"+img_src+"&"+user_name+"&"+max_patient);
		stmt.close();
		conn.close();
	}

	else if(action.equals("memberadd")){
		String mem_id = request.getParameter("mem_id");
		String mem_id_check = "select mem_id from member where provider_id="+mem_id;

		int provider_id = 0;
		ResultSet p_id = stmt.executeQuery(mem_id_check);
		while(p_id.next()){
			provider_id = p_id.getInt(1);
		}

		stmt.close();
		stmt = conn.createStatement();

		String memcheck = "update doctor_result set contact = 1 where doctor_id = "+mem_id+" and study_id = "+study_id;
		String memadd = "insert into study_parti(study_id, mem_id) values("+study_id+", "+provider_id+");";

		stmt.executeUpdate(memadd);
		stmt.close();

		stmt = conn.createStatement();
		stmt.executeUpdate(memcheck);

		stmt.close();
		conn.close();
	}

	else if(action.equals("memberdelete")){
		String mem_id = request.getParameter("mem_id");

		String mem_id_check = "select mem_id from member where provider_id="+mem_id;

		int provider_id = 0;
		ResultSet p_id = stmt.executeQuery(mem_id_check);
		while(p_id.next()){
			provider_id = p_id.getInt(1);
		}

		stmt.close();
		stmt = conn.createStatement();

		String memdelete = "delete from study_parti where study_id = "+study_id+" and mem_id = "+provider_id;
		String memcheck = "update doctor_result set contact = 0 where doctor_id = "+mem_id+" and study_id = "+study_id;
		stmt.executeUpdate(memdelete);
		stmt.close();

		stmt = conn.createStatement();
		stmt.executeUpdate(memcheck);

		stmt.close();
		conn.close();
	}
	
	else if(action.equals("memberinterestadd")){
		String mem_id = request.getParameter("mem_id");

		String memcheck = "update doctor_result set interest = 1 where doctor_id = "+mem_id+" and study_id = "+study_id;

		stmt.executeUpdate(memcheck);

		stmt.close();
		conn.close();
	}

	else if(action.equals("memberinterestdelete")){
		String mem_id = request.getParameter("mem_id");

		String memcheck = "update doctor_result set interest = 0 where doctor_id = "+mem_id+" and study_id = "+study_id;

		stmt.executeUpdate(memcheck);

		stmt.close();
		conn.close();
	}

	else if(action.equals("memberinfoload")){
		String mem_id = request.getParameter("mem_id");
		String mem_info = "select m.mem_name, c.corp_name_kr, m.mem_mail from scrn_cloud..member m, 'provider email-tel mapping table' p, scrn_cloud..corp c where p.PROVIDER_ID ="+mem_id+"and p.EMAIL = m.mem_mail and c.corp_id=m.mem_corp;";
		JSONArray info_list = new JSONArray();

		ResultSet m_info =	stmt.executeQuery(mem_info);
		while(m_info.next()){
			info = new JSONObject();
			info.put("name", m_info.getString(1));
			info.put("site", m_info.getString(2));
			info.put("mail", m_info.getString(3));
			info_list.add(info);
		}
		out.println(info_list);
		stmt.close();
		conn.close();

	}

%>
