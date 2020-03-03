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

<%
    String fileName = "mssql.ini";
    String fileDir = "/dbsource";
    String filePath = request.getRealPath(fileDir) + "/";
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

    JSONObject log = null;
    JSONArray logs = new JSONArray();


    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		int user_id = (Integer)session.getAttribute("user_id");
		int mem_corp = (Integer)session.getAttribute("user_corp");

		String eligibility_log = "select eligibility_id, project_id, edit_date, edit_reason, mem_img, mem_name, ip_address, mem_role, code from eligibility_HIS, member where editor = mem_id;";
		String member_log = "select m1.mem_id, m1.mem_name, m1.edit_date, m1.edit_reason, m2.mem_img, m2.mem_name, m1.ip_address, m2.mem_role, m1.code from member_HIS m1, member m2 where m1.editor = m2.mem_id;";
		String notice_log = "select notice_id, notice_title, edit_date, edit_reason, mem_img, mem_name, ip_address, mem_role, code from notice_HIS, member where editor = mem_id;";
		String project_log = "select project_id, project_title, edit_date, edit_reason, mem_img, mem_name, ip_address, mem_role, code from project_HIS, member where editor = mem_id";
		String system_log = "select s.system_log_date, s.system_log_reason, n.mem_img, n.mem_name, s.ip_address, n.mem_role, s.code from system_log s, member n where s.mem_id = n.mem_id";
		ResultSet rs = stmt.executeQuery(eligibility_log);
		while(rs.next()){
			log = new JSONObject();
			log.put("eligibility_id", rs.getInt(1));
			log.put("project_id", rs.getInt(2));
			log.put("edit_date", rs.getString(3));
			log.put("edit_reason", rs.getString(4));
			log.put("mem_img", rs.getString(5));
			log.put("mem_name", rs.getString(6));
			log.put("ip_address", rs.getString(7));
			log.put("mem_position", rs.getString(8));
			log.put("code", rs.getInt(9));
			log.put("site", "eligibility");
			logs.add(log);
		}

		stmt.close();
		stmt = conn.createStatement();
		
		ResultSet rs1 = stmt.executeQuery(member_log);
		while(rs1.next()){
			log = new JSONObject();
			log.put("mem_id", rs1.getInt(1));
			log.put("name", rs1.getString(2));
			log.put("edit_date", rs1.getString(3));
			log.put("edit_reason", rs1.getString(4));
			log.put("mem_img", rs1.getString(5));
			log.put("mem_name", rs1.getString(6));
			log.put("ip_address", rs1.getString(7));
			log.put("mem_position", rs1.getString(8));
			log.put("code", rs1.getInt(9));
			log.put("site", "member");
			logs.add(log);
		}

		ResultSet rs2 = stmt.executeQuery(notice_log);
		while(rs2.next()){
			log = new JSONObject();
			log.put("notice_id", rs2.getInt(1));
			log.put("notice_title", rs2.getString(2));
			log.put("edit_date", rs2.getString(3));
			log.put("edit_reason", rs2.getString(4));
			log.put("mem_img", rs2.getString(5));
			log.put("mem_name", rs2.getString(6));
			log.put("ip_address", rs2.getString(7));
			log.put("mem_position", rs2.getString(8));
			log.put("code", rs2.getInt(9));
			log.put("site", "notice");
			logs.add(log);
		}

		ResultSet rs3 = stmt.executeQuery(project_log);
		while(rs3.next()){
			log = new JSONObject();
			log.put("project_id", rs3.getInt(1));
			log.put("project_title", rs3.getString(2));
			log.put("edit_date", rs3.getString(3));
			log.put("edit_reason", rs3.getString(4));
			log.put("mem_img", rs3.getString(5));
			log.put("mem_name", rs3.getString(6));
			log.put("ip_address", rs3.getString(7));
			log.put("mem_position", rs3.getString(8));
			log.put("code", rs3.getInt(9));
			log.put("site", "project");
			logs.add(log);
		}

		ResultSet rs4 = stmt.executeQuery(system_log);
		while(rs4.next()){
			log = new JSONObject();
			log.put("edit_date", rs4.getString(1));
			log.put("edit_reason", rs4.getString(2));
			log.put("mem_img", rs4.getString(3));
			log.put("mem_name", rs4.getString(4));
			log.put("ip_address", rs4.getString(5));
			log.put("mem_position", rs4.getString(6));
			log.put("code", rs4.getInt(7));
			log.put("site", "System");
			logs.add(log);
		}

		stmt.close();
		conn.close();

		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		out.println(logs+"&"+img_src+"&"+user_name);
	}

%>
