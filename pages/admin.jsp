<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.net.URLDecoder" %>
<%@page import="java.io.*"%>
<%@page import="java.util.*" %>
<%@page import="com.oreilly.servlet.*"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat"%>

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

    JSONObject info = null;
	JSONObject project = null;
	JSONObject detail = null;
    JSONArray account = new JSONArray();
	JSONArray projects = new JSONArray();
	JSONArray details = new JSONArray();
	JSONArray eligibility_list = new JSONArray();

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");
	String ip_address = request.getRemoteAddr();

	if(action.equals("load")){
		int user_id = (Integer)session.getAttribute("user_id");
		int mem_corp = (Integer)session.getAttribute("user_corp");

		String info_s = "select mem_name, mem_position, mem_mail, mem_mobile, mem_phone, mem_id, mem_role, mem_dept, mem_img from member where mem_corp = "+mem_corp+";";
		String project_s = "select project_id, project_title, project_start_date, mem_name, project_irb, project_irb_status from project, member where (project_irb_status = 1 or project_irb_status = 2) and project_creator = mem_id";

		ResultSet rs = stmt.executeQuery(info_s);
		while(rs.next()){
			info = new JSONObject();
			info.put("name", rs.getString(1));
			info.put("position", rs.getString(2));
			info.put("mail", rs.getString(3));
			info.put("phone", rs.getString(4));
			info.put("corphone", rs.getString(5));
			info.put("id", rs.getInt(6));
			info.put("role", rs.getString(7));
			info.put("dept", rs.getString(8));
			info.put("mem_img", rs.getString(9));
			account.add(info);
		}

		ResultSet rs2 = stmt.executeQuery(project_s);
		while(rs2.next()){
			project = new JSONObject();
			project.put("id", rs2.getInt(1));
			project.put("title", rs2.getString(2));
			project.put("start_date", rs2.getString(3));
			project.put("creator", rs2.getString(4));
			project.put("irb", rs2.getString(5));
			project.put("status", rs2.getString(6));
			projects.add(project);
		}
		stmt.close();
		conn.close();

		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		out.println(account+"&"+img_src+"&"+user_name+"&"+projects);
	}

	else if(action.equals("modify")){
		JSONObject mem_info;
		JSONArray m_info = new JSONArray();
		String id = request.getParameter("id");

		String a1 = "select mem_name, mem_position, mem_mail, mem_mobile, mem_phone, mem_role, mem_dept from member where mem_id ="+id+";";

		ResultSet rs1 = stmt.executeQuery(a1);

		while(rs1.next()){
			mem_info = new JSONObject();
			mem_info.put("name", rs1.getString(1));
			mem_info.put("position", rs1.getString(2));
			mem_info.put("mail", rs1.getString(3));
			mem_info.put("phone", rs1.getString(4));
			mem_info.put("corphone", rs1.getString(5));
			mem_info.put("role", rs1.getString(6));
			mem_info.put("dept", rs1.getString(7));
			m_info.add(mem_info);
		}

		out.println(m_info);
		stmt.close();
		conn.close();
	}

	else if(action.equals("save")){
		int user_id = (Integer)session.getAttribute("user_id");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		String new_name = request.getParameter("name");
		new_name = URLDecoder.decode(new_name, "UTF-8");
		String new_position = request.getParameter("position");
		new_position = URLDecoder.decode(new_position, "UTF-8");
		String new_mail = request.getParameter("mail");
		String new_phone = request.getParameter("phone");
		String new_corphone = request.getParameter("corphone");
		String mem_id = request.getParameter("id");
		String new_role = request.getParameter("role");
		String new_dept = request.getParameter("dept");

		String a2 = "update member set mem_name = N'"+new_name+"', mem_position = N'"+new_position+"', mem_mail = N'"+new_mail+"', mem_mobile = N'"+new_phone+"', mem_phone=N'"+new_corphone+"', mem_role=N'"+new_role+"', mem_dept = N'"+new_dept+"' where mem_id="+mem_id;
		String a5 = "insert member_HIS(mem_id, mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, edit_date, edit_reason, editor, ip_address, code) select mem_id, mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, '"+today+"', N'modified a member. Modified member name is \""+new_name+"\", member ID is \""+mem_id+"\"', "+user_id+", N'"+ip_address+"', 1004 from member where mem_id="+mem_id;
		stmt.executeUpdate(a2);
		stmt.executeUpdate(a5);
		stmt.close();
		conn.close();

	}

	else if(action.equals("newmemsave")){
		int user_id = (Integer)session.getAttribute("user_id");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		int mem_corp = (Integer)session.getAttribute("user_corp");
		String new_name = request.getParameter("name");
		new_name = URLDecoder.decode(new_name, "UTF-8");
		String new_position = request.getParameter("position");
		new_position = URLDecoder.decode(new_position, "UTF-8");
		String new_mail = request.getParameter("mail");
		String new_phone = request.getParameter("phone");
		String new_corphone = request.getParameter("corphone");
		String mem_role = request.getParameter("role");
		String mem_dept = request.getParameter("dept");

		conn.close();
		stmt.close();

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

		int provider_id=0;
		String provider_id_search = "if not exists(select PROVIDER_ID from 'provider mapping table' where EMAIL Like N'"+new_mail+"') select 0 as result_id else select PROVIDER_ID from 'provider mapping table' where EMAIL Like N'"+new_mail+"';";
		
		ResultSet p_id = stmt.executeQuery(provider_id_search);

		while(p_id.next()){
			provider_id = p_id.getInt(1);
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

		int new_mem_id = 0;

		String a3 = "insert into member(mem_name, mem_position, mem_mail, mem_mobile, mem_phone, mem_role, mem_corp, mem_img, mem_dept) values(N'"+new_name+"', N'"+new_position+"', N'"+new_mail+"', N'"+new_phone+"', N'"+new_corphone+"', N'"+mem_role+"', "+mem_corp+", N'/scrn_ver_1.1.1/upload/default_photo.png', N'"+mem_dept+"') SELECT @@IDENTITY;";
		String a4 = "insert into member(mem_name, mem_position, mem_mail, mem_mobile, mem_phone, mem_role, mem_corp, mem_img, mem_dept, provider_id) values(N'"+new_name+"', N'"+new_position+"', N'"+new_mail+"', N'"+new_phone+"', N'"+new_corphone+"', N'"+mem_role+"', "+mem_corp+", N'/scrn_ver_1.1.1/upload/default_photo.png', N'"+mem_dept+"', "+provider_id+") SELECT @@IDENTITY;";

		ResultSet rs2;
		if(provider_id == 0) rs2 = stmt.executeQuery(a3);
		else rs2 = stmt.executeQuery(a4);

		while(rs2.next()){
			new_mem_id = rs2.getInt(1);
		}
		
		String a5 = "insert member_HIS(mem_id, mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, edit_date, edit_reason, editor, ip_address, code) select "+new_mem_id+", mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, '"+today+"', N'added a member to the system. Added member name is \""+new_name+"\", member ID is \""+new_mem_id+"\"', "+user_id+", N'"+ip_address+"', 1002 from member where mem_id="+new_mem_id;
		out.print(new_mem_id);
		stmt.executeUpdate(a5);
		stmt.close();
		conn.close();

	}

	else if(action.equals("memberdelete")){
		String id = request.getParameter("id");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		String a3 = "select mem_name from member where mem_id = "+id;
		String name = "";
		ResultSet a3_n = stmt.executeQuery(a3);
		while(a3_n.next()){
			name = a3_n.getString(1);
		}
		String a5 = "insert member_HIS(mem_id, mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, edit_date, edit_reason, editor, ip_address, code) select mem_id, mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, '"+today+"', N'deleted a member from the system. Deleted member name is \""+name+"\", member ID is \""+id+"\".', "+id+", N'"+ip_address+"', 1003 from member where mem_id="+id;
		String a4 = "delete from member where mem_id = "+id;

		stmt.executeUpdate(a5);
		stmt.executeUpdate(a4);
		stmt.close();
		conn.close();

	}

	else if(action.equals("projectdetail")){
		String project_id = request.getParameter("project_id");

		String project_info = "select project_title, project_category, project_protocol_id, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_irb, project_description, project_irb_status from project where project_id="+project_id;
		ResultSet pr_info = stmt.executeQuery(project_info);
		while(pr_info.next()){
			detail = new JSONObject();
			detail.put("title", pr_info.getString(1));
			detail.put("category", pr_info.getString(2));
			detail.put("protocol_id", pr_info.getString(3));
			detail.put("phase", pr_info.getString(4));
			detail.put("therapeutic_area", pr_info.getString(5));
			detail.put("indication", pr_info.getString(6));
			detail.put("sponsor", pr_info.getString(7));
			detail.put("identifier", pr_info.getString(8));
			detail.put("irb", pr_info.getString(9));
			detail.put("description", pr_info.getString(10));
			detail.put("irb_status", pr_info.getInt(11));
			details.add(detail);
		}

		stmt.close();
		conn.close();

		out.println(details);
	}

	else if(action.equals("approve")){
		String project_id = request.getParameter("project_id");
		int user_id = (Integer)session.getAttribute("user_id");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		String approve_q = "update project set project_irb_status = 2 where project_id="+project_id;
	
		stmt.executeUpdate(approve_q);

		String a2 = "select project_title from project where project_id = "+project_id;
		String title = "";

		ResultSet a2_t = stmt.executeQuery(a2);
		while(a2_t.next()){
			title = a2_t.getString(1);
		}

		String a1 = "insert into project_HIS(project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, project_irb_status, edit_date, edit_reason, editor, ip_address, code) select project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, 2, '"+today+"', 'approved IRB of project \""+title+"\". Project ID is \""+project_id+"\".', "+user_id+", N'"+ip_address+"', 3006 from project where project_id="+project_id+";";
		stmt.executeUpdate(a1);

		stmt.close();
		conn.close();
	}
%>
