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

	String ip_address = request.getRemoteAddr();

    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		int mem_corp = (Integer)session.getAttribute("user_corp");
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");
		int mem_id = (Integer)session.getAttribute("user_id");

		JSONObject project_info = null;
		JSONObject mem_list = null;
		JSONObject eligibility_list = null;
		JSONObject invest_list = null;

		JSONArray info = new JSONArray();
		JSONArray mem = new JSONArray();
		JSONArray eligibility = new JSONArray();
		JSONArray invest = new JSONArray();

		String a1 = "select * from project, member where project_id ="+project_id+" and project_creator = mem_id";
		String a0 = "select member.mem_id, mem_name, mem_position, mem_dept, parti_role, accept, mem_img  from project_participant, member where project_id = "+project_id+" and project_participant.mem_id = member.mem_id;";
		String a2 = "select * from eligibility e, member m, eligibility_status s where e.project_id ="+project_id+" and e.eligibility_creator = m.mem_id and e.eligibility_id = s.eligibility_id and s.mem_id ="+mem_id;
		ResultSet rs = stmt.executeQuery(a0);

		while(rs.next()){
			mem_list = new JSONObject();
			mem_list.put("mem_id", rs.getInt(1));
			mem_list.put("mem_name", rs.getString(2));
			mem_list.put("mem_posi", rs.getString(3));
			mem_list.put("mem_dept", rs.getString(4));
			mem_list.put("mem_role", rs.getString(5));
			mem_list.put("accept", rs.getInt(6));
			mem_list.put("img_src", rs.getString(7));
			mem.add(mem_list);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs2 = stmt.executeQuery(a1);
		while(rs2.next()){
			project_info = new JSONObject();
			project_info.put("project_title", rs2.getString(2));
			project_info.put("project_creator", rs2.getString(20));
			project_info.put("project_category", rs2.getString(3));
			project_info.put("project_start", rs2.getString(5));
			project_info.put("project_description", rs2.getString(10));
			project_info.put("project_id", rs2.getInt(1));
			project_info.put("project_end", rs2.getString(6));
			project_info.put("project_status", rs2.getString(7));
			project_info.put("project_protocol", rs2.getString(8));
			project_info.put("project_phase", rs2.getString(11));
			info.add(project_info);
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet rs3 = stmt.executeQuery(a2);
		while(rs3.next()){
			eligibility_list = new JSONObject();
			eligibility_list.put("eligibility_id", rs3.getInt(1));
			eligibility_list.put("eligibility_title", rs3.getString(2));
			eligibility_list.put("eligibility_create_date", rs3.getString(5));
			eligibility_list.put("eligibility_modify_date", rs3.getString(6));
			eligibility_list.put("eligibility_execute_date", rs3.getString(26));
			eligibility_list.put("eligibility_status", rs3.getString(25));
			eligibility_list.put("eligibility_creator", rs3.getString(11));
			eligibility_list.put("eligibility_last_editor", rs3.getString(3));
			eligibility_list.put("new_check", rs3.getInt(28));
			eligibility.add(eligibility_list);
		}

		out.println(mem+"&"+info+"&"+eligibility+"&"+img_src+"&"+user_name+"&"+invest);
		stmt.close();
		conn.close();
	}

	else if(action.equals("memberload")){

		int corp_id = (Integer)session.getAttribute("user_corp");
		JSONObject corp_mem = null;

		JSONArray mem = new JSONArray();

		String a2 = "select * from member Where mem_corp = "+corp_id+" and mem_id not in(select mem_id from project_participant where project_id = "+project_id+")";

		ResultSet rs2 = stmt.executeQuery(a2);

		while(rs2.next()){
			corp_mem = new JSONObject();
			corp_mem.put("mem_name", rs2.getString(2));
			corp_mem.put("mem_posi", rs2.getString(3));
			corp_mem.put("mem_id", rs2.getInt(1));
			corp_mem.put("mem_dept", rs2.getString(11));
			corp_mem.put("mem_img", rs2.getString(10));
			mem.add(corp_mem);
		}

		out.println(mem);
		stmt.close();
		conn.close();
	}

	else if(action.equals("membersave")){

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		int user_id = (Integer)session.getAttribute("user_id");
		String mem_id = request.getParameter("mem_id");
		String a0 = "select mem_position, mem_corp from member where mem_id = "+mem_id;

		ResultSet rs = stmt.executeQuery(a0);
		String mem_position = "";
		String mem_corp="";

		while(rs.next()){
			mem_position = rs.getString(1);
			mem_corp = rs.getString(2);
		}
		stmt.close();
		stmt = conn.createStatement();

		String a1 = "insert into project_participant(project_id, mem_id) values("+project_id+", "+mem_id+");";

		stmt.executeUpdate(a1);

		String a3 = "select project_title from project where project_id = "+project_id;
		String title = "";

		ResultSet a3_t = stmt.executeQuery(a3);
		while(a3_t.next()){
			title = a3_t.getString(1);
		}

		String a2 = "insert into project_HIS(project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, edit_date, edit_reason, editor, ip_address, code) select project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, '"+today+"', 'added member(s) to the project \""+title+"\". Project ID is \""+project_id+"\"', "+user_id+", '"+ip_address+"', 3003 from project where project_id="+project_id+";";
		stmt.executeUpdate(a2);
		stmt.close();
		conn.close();
	}

	else if(action.equals("memberdelete")){

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;
		int user_id = (Integer)session.getAttribute("user_id");

		String mem_id = request.getParameter("mem_id");
		String pid = "select provider_id from member where mem_id="+mem_id;
		ResultSet rs1 = stmt.executeQuery(pid);
		int provider_id = 0;

		while(rs1.next()){
			provider_id = rs1.getInt(1);
		}

		String a0 = "delete from project_participant where project_id = "+project_id+" and mem_id = "+mem_id+";";
		String a1 = "update result_site set contact = 0 where doctor_id = "+provider_id+" and project_id = "+project_id;

		stmt.executeUpdate(a0);
		stmt.executeUpdate(a1);

		String a3 = "select project_title from project where project_id = "+project_id;
		String title = "";

		ResultSet a3_t = stmt.executeQuery(a3);
		while(a3_t.next()){
			title = a3_t.getString(1);
		}

		String a2 = "insert into project_HIS(project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, edit_date, edit_reason, editor, ip_address, code) select project_id, project_title, project_category, project_creator, project_start_date, project_end_date, project_status, project_protocol_id, project_corp_id, project_description, project_phase, project_therapeutic_area, project_indication, project_sponsor_name, project_identifier, project_drug, project_irb, '"+today+"', 'deleted member(s) from the project \""+title+"\". Porject ID is \""+project_id+"\"', "+user_id+", '"+ip_address+"', 3004 from project where project_id="+project_id+";";
		stmt.executeUpdate(a2);

		stmt.close();
		conn.close();
	}

	else if(action.equals("createeligibility")){
		String eligibility_title = request.getParameter("title");
		eligibility_title = URLDecoder.decode(eligibility_title, "UTF-8");

		String duplicate = request.getParameter("duplicate");

		int creator = (Integer)session.getAttribute("user_id");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;


		String a0 = "insert into eligibility(eligibility_title, eligibility_last_editor, project_id, eligibility_create_date, eligibility_modify_date, eligibility_creator) values(N'"+eligibility_title+"', N'"+creator+"', "+project_id+", '"+today+"', '"+today+"', N'"+creator+"')  SELECT @@IDENTITY";
		int new_eligibility = 0;

		ResultSet rs1 = stmt.executeQuery(a0);
		while(rs1.next()){
			new_eligibility = rs1.getInt(1);
		}

		String a4 = "insert into eligibility_HIS(eligibility_id, eligibility_title, eligibility_last_editor, project_id, eligibility_create_date, eligibility_modify_date, eligibility_creator, edit_date, edit_reason, editor, ip_address, code) values( "+new_eligibility+", N'"+eligibility_title+"', N'"+creator+"', "+project_id+", '"+today+"', '"+today+"', N'"+creator+"', '"+today+"', 'created a new eligibility \""+eligibility_title+"\". Eligibility ID is \""+new_eligibility+"\".', N'"+creator+"', N'"+ip_address+"', 3500)";
		stmt.executeUpdate(a4);
		
		String a2 = "select mem_id from project_participant where project_id = "+project_id;
		Statement stmt2 = conn.createStatement();
		ResultSet rs2 = stmt.executeQuery(a2);
		while(rs2.next()){
			String a1 = "insert into eligibility_status(eligibility_id, mem_id, status) values("+new_eligibility+", "+rs2.getInt(1)+", N'Ready');";
			stmt2.executeUpdate(a1);
		}
		stmt2.close();
		Connection conn1= DriverManager.getConnection(connectionUrl);  
		Statement stmt1 = conn1.createStatement();

		if(!duplicate.equals("0")){
			String mid_cri = "select * from mid_criteria where project_id = "+project_id+" and eligibility_id ="+duplicate;
			ResultSet mid_rs = stmt.executeQuery(mid_cri);
			while(mid_rs.next()){
				String insert_mid = "insert into mid_criteria(project_id, eligibility_id, mid_title, mid_state) select project_id, '"+new_eligibility+"', mid_title, mid_state from mid_criteria where mid_id = "+mid_rs.getInt(1) +" SELECT @@IDENTITY";
				int new_mid = 0;
				ResultSet new_mid_rs = stmt1.executeQuery(insert_mid);
				while(new_mid_rs.next()){
					new_mid = new_mid_rs.getInt(1);
				}
				String duplicate_criterias = "insert into criteria(eligibility_id, project_id, mid_id, criteria_table, criteria_attribute, criteria_date_standard, criteria_value, criteria_state, criteria_title, criteria_addition, criteria_addition_min_value, criteria_addition_max_value, criteria_addition_min_condition, criteria_addition_max_condition, criteria_measurement_method, criteria_measurement_count, patient_count, criteria_table_source_value, criteria_addition_source_value, criteria_date_source_value, state, isdivider) select '"+new_eligibility+"', project_id, '"+new_mid+"', criteria_table, criteria_attribute, criteria_date_standard, criteria_value, criteria_state, criteria_title, criteria_addition, criteria_addition_min_value, criteria_addition_max_value, criteria_addition_min_condition, criteria_addition_max_condition, criteria_measurement_method, criteria_measurement_count, patient_count, criteria_table_source_value, criteria_addition_source_value, criteria_date_source_value, state, isdivider from criteria where project_id = "+project_id+" and eligibility_id ="+duplicate+" and mid_id = "+mid_rs.getInt(1);
				stmt1.executeUpdate(duplicate_criterias);
			}

			String a6 = "select eligibility_title from eligibility where eligibility_id = "+duplicate;
			ResultSet duplicate_study = stmt.executeQuery(a6);
			String duplicate_title = "";
			while(duplicate_study.next()){
				duplicate_title = duplicate_study.getString(1);
			}	

			String a5 = "insert into eligibility_HIS(eligibility_id, eligibility_title, eligibility_last_editor, project_id, eligibility_create_date, eligibility_modify_date, eligibility_creator, edit_date, edit_reason, editor, ip_address, code) values( "+new_eligibility+", N'"+eligibility_title+"', N'"+creator+"', "+project_id+", '"+today+"', '"+today+"', N'"+creator+"', '"+today+"', 'duplicated the eligibility \""+duplicate_title+"\" to \""+eligibility_title+"\". Duplicated eligibility ID is \""+duplicate+"\" and new eligibility ID is \""+new_eligibility+"\".', N'"+creator+"', N'"+ip_address+"', 3503)";
			stmt.executeUpdate(a5);

		}

		stmt1.close();
		conn1.close();
		stmt.close();
		conn.close();
	}

	else if(action.equals("eligibilitydelete")){
		String eligibility_id = request.getParameter("eligibility_id");
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

		int visit_count = 0;
		String a3 = "select count(criteria_id) from criteria where project_id = "+project_id+" and eligibility_id = "+eligibility_id+" and criteria_table_source_value like 'Visit_occurrence';";
		String a2 = "delete from criteria where project_id = "+project_id+" and eligibility_id = "+eligibility_id+" and criteria_table_source_value like 'Visit_occurrence';";
		String a0 = "delete from eligibility where project_id = "+project_id+" and eligibility_id = "+eligibility_id+";";
		
		ResultSet visit_rs = stmt.executeQuery(a3);
		while(visit_rs.next()){
			visit_count = visit_rs.getInt(1);
		}

		if(visit_count > 0) stmt.executeUpdate(a2);
		String a4 = "select eligibility_title from eligibility where eligibility_id="+eligibility_id;
		String eligibility_title = "";
		ResultSet t_a4 = stmt.executeQuery(a4);
		while(t_a4.next()){
			eligibility_title = t_a4.getString(1);
		}

		String a1 = "insert into eligibility_HIS(eligibility_id, eligibility_title, eligibility_last_editor, project_id, eligibility_create_date, eligibility_modify_date, eligibility_execute_date, eligibility_creator, eligibility_total_patients, edit_date, edit_reason, editor, ip_address, code) select eligibility_id, eligibility_title, eligibility_last_editor, project_id, eligibility_create_date, eligibility_modify_date, eligibility_execute_date, eligibility_creator, eligibility_total_patients, '"+today+"', 'deleted the eligibility \""+eligibility_title+"\". Eligibility ID is \""+eligibility_id+"\".', "+user_id+", N'"+ip_address+"', 3501 from eligibility where project_id = "+project_id+" and eligibility_id = "+eligibility_id+";";

		stmt.executeUpdate(a1);
		stmt.executeUpdate(a0);

		stmt.close();
		conn.close();
	}

	else if(action.equals("eligibilityexecute")){

		int user_id = (Integer)session.getAttribute("user_id");
		String provider = (String)session.getAttribute("provider_id");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		String[] ips = ip_address.split("[.]");
		String eligibility_id = request.getParameter("eligibility_id");

		String sql_fileName = "sql_log_"+eligibility_id+year+month+day+hour+minute+second+ips[3]+user_id;
		String a3 = "update eligibility_status set status = N'In Progress', eligibility_execute_date = N'"+today+"', fileName = N'"+sql_fileName+"' where eligibility_id = "+eligibility_id+" and mem_id ="+user_id;
		stmt.executeUpdate(a3);

		String a2 = "select eligibility_title from eligibility where eligibility_id = "+eligibility_id;
		String e_title = "";

		ResultSet t_a2 = stmt.executeQuery(a2);
		while(t_a2.next()){
			e_title = t_a2.getString(1);
		}

		String a1 = "insert into eligibility_HIS(eligibility_id, eligibility_title, eligibility_last_editor, project_id, eligibility_create_date, eligibility_modify_date, eligibility_execute_date, eligibility_status, eligibility_creator, eligibility_total_patients, edit_date, edit_reason, editor, ip_address, code) select eligibility_id, eligibility_title, eligibility_last_editor, project_id, eligibility_create_date, eligibility_modify_date, '"+today+"', N'In Progress', eligibility_creator, eligibility_total_patients, '"+today+"', 'executed the eligibility \""+e_title+"\". Eligibility ID is \""+eligibility_id+"\".', "+user_id+", N'"+ip_address+"', 3504 from eligibility where project_id = "+project_id+" and eligibility_id = "+eligibility_id+";";

		stmt.executeUpdate(a1);
		
		out.print(provider+"/"+user_id+"/"+sql_fileName);
		stmt.close();
		conn.close();
	}

	else if(action.equals("sqllogload")){

		String eligibility_id = request.getParameter("eligibility_id");

		String a1 = "select fileName from eligibility_status where eligibility_id = "+eligibility_id;
		String sql_title = "";

		ResultSet rs1 = stmt.executeQuery(a1);
		while(rs1.next()){
			sql_title = rs1.getString(1);
		}
    	JSONParser log_parser = new JSONParser();

		Object log = log_parser.parse(new FileReader(request.getRealPath("/log")+"/sql/"+sql_title+".log"));
		JSONObject log_data_pre = (JSONObject)log;
		JSONObject log_data = (JSONObject)log_data_pre.get("query");

		String sql_content = (String)log_data.get("site_patient");

		out.print(sql_content);
		stmt.close();
		conn.close();
	}
	else if(action.equals("checkdone")){
		
		JSONArray eligibility_status_array = new JSONArray();
		JSONObject status_e ;
		int user_id = (Integer)session.getAttribute("user_id");
		String a2 = "select s.eligibility_id, s.status from eligibility e, eligibility_status s where e.project_id="+project_id+" and e.eligibility_id = s.eligibility_id and s.mem_id = "+user_id;

		ResultSet rs2 = stmt.executeQuery(a2);

		while(rs2.next()){
			status_e = new JSONObject();
			status_e.put("eligibility_id", rs2.getInt(1));
			status_e.put("eligibility_status", rs2.getString(2));
			eligibility_status_array.add(status_e);
		}

		out.print(eligibility_status_array);
		stmt.close();
		conn.close();
	}
	else if(action.equals("newdelete")){
		String eligibility_id = request.getParameter("eligibility_id");

		String new_update = "update eligibility_status set [check]= 1 where eligibility_id="+eligibility_id;
		stmt.executeUpdate(new_update);

		stmt.close();
		conn.close();
	}

%>
