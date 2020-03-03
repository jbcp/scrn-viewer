<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
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
    }catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } catch (ParseException e) {
        e.printStackTrace();
    } 


    JSONObject project1 = null;
    JSONArray project = new JSONArray();

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		int user_corp = (Integer)session.getAttribute("user_corp");
		int user_id = (Integer)session.getAttribute("user_id");
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		String a1 = "select project_id, project_title, project_category, mem_name, project_start_date, project_end_date, project_status, project_description, mem_img from project, member where project_creator = member.mem_id and project_id in (select project_id from project_participant where accept = 1 and mem_id ="+user_id+") order by project_start_date desc;" ;
		ResultSet rs = stmt.executeQuery(a1);

		while(rs.next()){
			project1 = new JSONObject();
			project1.put("project_id", rs.getInt(1));
			project1.put("project_title", rs.getString(2));
			project1.put("project_creator", rs.getString(4));
			project1.put("project_start", rs.getString(5));
			project1.put("project_end", rs.getString(6));
			project1.put("project_status", rs.getString(7));
			project1.put("project_category", rs.getString(3));
			project1.put("project_description", rs.getString(8));
			project1.put("img_src", rs.getString(9));
			project.add(project1);
		}

		out.println(project+"&"+img_src+"&"+user_name);
		stmt.close();
		conn.close();
	}

	else if(action.equals("save")){
		int user_id = (Integer)session.getAttribute("user_id");
		int user_corp = (Integer)session.getAttribute("user_corp");
		String user_name = (String)session.getAttribute("user_name");

		String ip_address = request.getRemoteAddr();

		String title = request.getParameter("title");
		String project_title = URLDecoder.decode(title, "UTF-8");

		String category = request.getParameter("category");
		String project_category = URLDecoder.decode(category, "UTF-8");

		String content = request.getParameter("content");
		String project_content = URLDecoder.decode(content, "UTF-8");

		String protocol_id = request.getParameter("protocol_id");
		String project_protocol_id = URLDecoder.decode(protocol_id, "UTF-8");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;
		
		String a1 = "insert into project( project_title, project_category, project_description, project_creator, project_start_date, project_status, project_corp_id, project_protocol_id) Values(N'" + project_title + "', N'"+project_category+ "', N'"+project_content+"', "+user_id+", '"+today+"', 'Draft', "+user_corp+", N'"+protocol_id+"') SELECT @@IDENTITY;";
		String sql = a1;

		ResultSet project_q = stmt.executeQuery(a1);

		int saved_project_id = 0;
		while(project_q.next()){
			saved_project_id = project_q.getInt(1);
		}
		
		stmt.close();
		stmt = conn.createStatement();

		String a5 = "insert into project_HIS(project_id, project_title, project_category, project_description, project_creator, project_start_date, project_status, project_corp_id, project_protocol_id, edit_date, edit_reason, editor, ip_address, code) Values("+saved_project_id+", N'" + project_title + "', N'"+project_category+ "', N'"+project_content+"', "+user_id+", '"+today+"', 'Draft', "+user_corp+", N'"+protocol_id+"', '"+today+"', N'created a new project \""+project_title+"\". Project ID is \""+saved_project_id+"\".', "+user_id+", N'"+ip_address+"', 3000);";
		stmt.executeUpdate(a5);

		stmt.close();
		stmt = conn.createStatement();

		String a2 = "insert into project_participant(project_id, mem_id, parti_role, accept) values ("+saved_project_id+", "+user_id+", N'Creator', 1);";

		stmt.executeUpdate(a2);

		stmt.close();
		conn.close();
	}

	else if(action.equals("delete")){
		String project_id = request.getParameter("id");
		int user_id = (Integer)session.getAttribute("user_id");
		String user_name = (String)session.getAttribute("user_name");

		String ip_address = request.getRemoteAddr();

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;
		
		String check_role = "select parti_role from project_participant where project_id = "+project_id +" and mem_id = "+user_id;
		ResultSet user_role = stmt.executeQuery(check_role);
		String role = "";

		while(user_role.next()){
			role = user_role.getString(1);			
		}

		String check_project_title = "select project_title from project where project_id="+project_id;
		String project_title = "";
		ResultSet p_title = stmt.executeQuery(check_project_title);
		while(p_title.next()){
			project_title = p_title.getString(1);
		}

		if(role.equals("Creator")){
			String a1 = "insert into project_HIS(project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, project_irb_status, edit_date, edit_reason, editor, ip_address, code) select project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, project_irb_status, '"+today+"', N'deleted the project \""+project_title+"\". Project ID is \""+project_id+"\".', "+user_id+", N'"+ip_address+"', 3002 from project where project_id="+project_id+";";
			stmt.executeUpdate(a1);
			String a2 = "delete from project where project_id="+project_id+";";
			stmt.executeUpdate(a2);
		}

		else{
			String a3 = "delete from project_participant where project_id = "+project_id +" and mem_id = "+user_id;
			stmt.executeUpdate(a3);
		}


		stmt.close();
		conn.close();

	}
%>

