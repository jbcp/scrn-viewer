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

	String project_id = request.getParameter("project_id");
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  

    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");
	String ip_address = request.getRemoteAddr();

	if(action.equals("load")){
		JSONObject info = null;
		JSONArray project_info = new JSONArray();
		String info_s = "select * from project where project_id="+project_id;

		int user_corp = (Integer)session.getAttribute("user_corp");
		int user_id = (Integer)session.getAttribute("user_id");
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		ResultSet rs = stmt.executeQuery(info_s);

		while(rs.next()){
			info = new JSONObject();
			info.put("title", rs.getString(2));
			info.put("protocol_id", rs.getString(8));
			info.put("project_status", rs.getString(7));
			info.put("project_phase", rs.getString(11));
			info.put("project_therapeutic", rs.getString(12));
			info.put("indication", rs.getString(14));
			info.put("description", rs.getString(10));
			info.put("sponsor_name", rs.getString(14));
			info.put("project_identifier", rs.getString(15));
			info.put("project_drug", rs.getString(16));
			info.put("project_irb", rs.getString(17));
			info.put("project_irb_status", rs.getInt(18));
			project_info.add(info);
		}

		out.println(project_info+"&"+img_src+"&"+user_name);
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
		String hour = df.format(calendar.get(Calendar.HOUR));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		String title = request.getParameter("title");
		String protocol = request.getParameter("protocol");
		String status = request.getParameter("status");
		String phase = request.getParameter("phase");
		String therapeutic = request.getParameter("therapeutic");
		String indication = request.getParameter("indication");
		String description = request.getParameter("description");
		String sponsor = request.getParameter("sponsor");
		String identifier = request.getParameter("identifier");
		String drug = request.getParameter("drug");
		String irb_num = request.getParameter("irb");

		String save_info = "update project set project_title= N'"+title+"', project_status= N'"+status+"', project_protocol_id= N'"+protocol+"', project_description= N'"+description+"', project_phase= N'"+phase+"', project_therapeutic_area= N'"+therapeutic+"', project_indication= N'"+indication+"', project_sponsor_name= N'"+sponsor+"', project_identifier= N'"+identifier+"', project_end_date = null, project_drug=N'"+drug+"', project_irb = N'"+irb_num+"' where project_id="+project_id;

		stmt.executeUpdate(save_info);

		String a1 = "insert into project_HIS(project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, edit_date, edit_reason, editor, ip_address, code) select project_id, N'"+title+"', project_category, project_creator, project_start_date, project_end_date, N'"+status+"', N'"+protocol+"', project_corp_id, N'"+description+"', N'"+phase+"', N'"+therapeutic+"', N'"+indication+"', N'"+sponsor+"', N'"+identifier+"', N'"+drug+"', N'"+irb_num+"', '"+today+"', 'modified the project \""+title+"\". Project ID is \""+project_id+"\".', "+user_id+", '"+ip_address+"', 3001 from project where project_id="+project_id+";";

		stmt.executeUpdate(a1);

		if(phase.equals("Finished")){
			String save_finished = "update project set project_end_date = '"+today+"' where project_id="+project_id;

			stmt.close();
			stmt = conn.createStatement();

			stmt.executeUpdate(save_finished);
		}

		stmt.close();
		conn.close();
	
	}
	else if(action.equals("irb_check")){
		int user_id = (Integer)session.getAttribute("user_id");

		String irb_num = request.getParameter("irb");
		String title = "";

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;
		
		String a2 = "update project set project_irb = N'"+irb_num+"', project_irb_status = 1 where project_id="+project_id;
		stmt.executeUpdate(a2);

		String a4 = "select project_title from project where project_id = "+project_id;
		ResultSet a4_t = stmt.executeQuery(a4);
		while(a4_t.next()){
			title = a4_t.getString(1);
		}

		String a3 = "insert into project_HIS(project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, project_irb_status, edit_date, edit_reason, editor, ip_address, code) select project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, N'"+irb_num+"', 1, '"+today+"', 'applied IRB number approval of project \""+title+"\". Project ID is \""+project_id+"\"', "+user_id+", N'"+ip_address+"', 3005 from project where project_id="+project_id+";";
		stmt.executeUpdate(a3);

		stmt.close();
		conn.close();
	}


%>
