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

    JSONObject project1 = null;
	JSONObject notice1 = null;
	JSONObject graph = null;
    JSONArray project = new JSONArray();
	JSONArray notice = new JSONArray();
	JSONArray graph_data = new JSONArray();

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();
	String ip_address = request.getRemoteAddr();

	String action = request.getParameter("action");

	if(action.equals("load")){
		int user_corp = (Integer)session.getAttribute("user_corp");
		int user_id = (Integer)session.getAttribute("user_id");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR));
		String last_year = Integer.toString(calendar.get(Calendar.YEAR)-1);

		String total_project = "select count(*) from project where project_id in (select project_id from project_participant where accept = 1 and mem_id ="+user_id+")";
		String total_patients = "select count(*) from 'Patient's table'"; // Patient's table
		String total_doctors = "select count(*) from member where mem_corp= "+user_corp+"and mem_position = N'doctor'";
		
		String this_year_project = "select MONTH(project_start_date), count(*) from project where YEAR(project_start_date) = "+year+" and project_id in (select project_id from project_participant where accept = 1 and mem_id ="+user_id+") group by MONTH(project_start_date) order by MONTH(project_start_date);";
		String last_year_project = "select MONTH(project_start_date), count(*) from project where YEAR(project_start_date) = "+last_year+" and project_id in (select project_id from project_participant where accept = 1 and mem_id ="+user_id+") group by MONTH(project_start_date) order by MONTH(project_start_date);"; 

		String a1 = "select project_id, project_title, mem_name, project_start_date, project_status from project, member where project_creator = member.mem_id and project_id in (select project_id from project_participant where accept = 1 and mem_id ="+user_id+")" ;
		String a2 = "select * from notice where notice_corp = "+user_corp+";";
		
		graph = new JSONObject();
		int total_project_num = 0;
		int total_patients_num = 0;
		int total_doctors_num = 0;

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs1 = stmt.executeQuery(total_project);
		while(rs1.next()){
			total_project_num = rs1.getInt(1);
			if(total_project_num == 0) total_project_num = 1;
			graph.put("total_project", rs1.getInt(1));
		}
		graph_data.add(graph);

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

		graph = new JSONObject();
		ResultSet rs2 = stmt.executeQuery(total_patients);
		while(rs2.next()){
			total_patients_num = rs2.getInt(1);
			graph.put("total_patients", rs2.getInt(1));
		}

		graph_data.add(graph);

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
		
		graph = new JSONObject();
		ResultSet rs3 = stmt.executeQuery(total_doctors);
		while(rs3.next()){
			total_doctors_num = rs3.getInt(1);
			graph.put("total_doctors", rs3.getInt(1));

		}

		graph_data.add(graph);

		stmt.close();
		stmt = conn.createStatement();

		String this_year_result = "";

		ResultSet rs5 = stmt.executeQuery(this_year_project);
		int index = 1;
		while(rs5.next()){
			while(index != rs5.getInt(1)){
				if(index == 1) this_year_result = Integer.toString(0);
				else this_year_result = this_year_result + ", "+ Integer.toString(0);
				index++;
			}
			if(index == 1) this_year_result = Integer.toString(rs5.getInt(2));
			else this_year_result = this_year_result+", "+ Integer.toString(rs5.getInt(2));
			index++;
		}
		while(index <= 12){
			if(index == 1) this_year_result = Integer.toString(0);
			else this_year_result = this_year_result + ", "+ Integer.toString(0);
			index++;
		}

		stmt.close();
		stmt = conn.createStatement();

		String last_year_result = "";
		ResultSet rs6 = stmt.executeQuery(last_year_project);
		index = 1;
		while(rs6.next()){
			while(index != rs6.getInt(1)){
				if(index == 1) last_year_result = Integer.toString(0);
				else last_year_result = last_year_result + ", "+ Integer.toString(0);
				index++;
			}
			if(index == 1) last_year_result = Integer.toString(rs6.getInt(2));
			else last_year_result = last_year_result+", "+ Integer.toString(rs6.getInt(2));
			index++;
		}
		while(index <= 12){
			if(index == 1) last_year_result = Integer.toString(0);
			else last_year_result = last_year_result + ", "+ Integer.toString(0);
			index++;
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs7 = stmt.executeQuery(a2);
		while(rs7.next()){
			notice1 = new JSONObject();
			notice1.put("notice_id", rs7.getInt(1));
			notice1.put("notice_title", rs7.getString(2));
			notice1.put("notice_content", rs7.getString(3));
			notice1.put("notice_corp", rs7.getInt(4));
			notice1.put("write_date", rs7.getString(5));
			notice.add(notice1);
		}

		ResultSet rs = stmt.executeQuery(a1);

		while(rs.next()){
			project1 = new JSONObject();
			project1.put("project_id", rs.getInt(1));
			project1.put("project_title", rs.getString(2));
			project1.put("project_creator", rs.getString(3));
			project1.put("project_start", rs.getString(4));
			project1.put("project_status", rs.getString(5));
			project.add(project1);
		}
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		out.println(graph_data+"&"+this_year_result+"&"+last_year_result+"&"+notice+"&"+project+"&"+img_src+"&"+user_name);
		stmt.close();
		conn.close();
	}

	else if(action.equals("noticesave")){
		int user_id = (Integer)session.getAttribute("user_id");
		int user_corp = (Integer)session.getAttribute("user_corp");

		String title = request.getParameter("title");
		String notice_title = URLDecoder.decode(title, "UTF-8");

		String content = request.getParameter("content");
		String notice_content = URLDecoder.decode(content, "UTF-8");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;
		
		String a1 = "insert into Notice( notice_title, notice_content, notice_corp, write_date) Values(N'"+ notice_title + "', N'"+notice_content+ "', "+user_corp+", N'"+today+"') SELECT @@IDENTITY;";

		ResultSet rs = stmt.executeQuery(a1);
		int saved_notice_id = 0;
		while(rs.next()){
			saved_notice_id = rs.getInt(1);
		}

		String a2 = "insert into Notice_HIS(notice_id, notice_title, notice_content, notice_corp, write_date, edit_date, edit_reason, editor, ip_address, code) Values("+saved_notice_id+", N'"+ notice_title + "', N'"+notice_content+ "', "+user_corp+", N'"+today+"', N'"+today+"', N'created a new notice \""+notice_title+"\". Notice ID is \""+saved_notice_id+"\".', "+user_id+", N'"+ip_address+"', 2000);";
		stmt.executeUpdate(a2);
		stmt.close();
		conn.close();
	}

	else if(action.equals("noticedelete")){
		String notice_id = request.getParameter("id");
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

		String a1 = "select notice_title from notice where notice_id = "+notice_id;
		String title = "";
		ResultSet a1_t = stmt.executeQuery(a1);
		while(a1_t.next()){
			title = a1_t.getString(1);
		}

		String a3 = "insert into Notice_HIS(notice_id, notice_title, notice_content, notice_corp, write_date, edit_date, edit_reason, editor, ip_address, code) select notice_id, notice_title, notice_content, notice_corp, write_date, '"+today+"', 'deleted the notice \""+title+"\". Notice ID is \""+notice_id+"\"', "+user_id+", N'"+ip_address+"', 2001 from notice where notice_id = "+notice_id;
		stmt.executeUpdate(a3);


		String a2 = "delete from notice where notice_id="+notice_id+";";
        stmt.executeUpdate(a2);
    
		stmt.close();
		conn.close();

	}

%>
