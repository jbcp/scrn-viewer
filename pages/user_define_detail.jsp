<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
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


    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();
	String ip_address = request.getRemoteAddr();

	String action = request.getParameter("action");

	if(action.equals("load")){
		JSONObject criteria = null;
		JSONObject visit = null;
		JSONObject info = null;
		JSONArray populations = new JSONArray();
		JSONArray criteria_set_in = new JSONArray();
		JSONArray criteria_set_ex = new JSONArray();
		JSONArray info_list = new JSONArray();
		String define_id = request.getParameter("define_id");

		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		String info_s = "select define_title from user_define where define_id ="+define_id;
		ResultSet info_r = stmt.executeQuery(info_s);
		while(info_r.next()){
			info = new JSONObject();
			info.put("title", info_r.getString(1));
			info_list.add(info);
		}

		stmt.close();
		stmt = conn.createStatement();

		String status_data = "";
		String a2 = "select * from user_define_criteria where define_id = "+define_id+" and criteria_table = 4";
		ResultSet rs2 = stmt.executeQuery(a2);
		while(rs2.next()){
			visit = new JSONObject();
			visit.put("type", "visit");
			visit.put("value", rs2.getString(19));
			visit.put("period", rs2.getInt(7));
			populations.add(visit);
		}

		String a4 = "select * from user_define_mid_criteria where define_id ="+define_id+" and mid_state = 1";
		ResultSet rs4 = stmt.executeQuery(a4);
		while(rs4.next()){
			criteria = new JSONObject();
			criteria.put("title", rs4.getString(3));
			criteria.put("id", rs4.getInt(1));
			criteria.put("small", new JSONArray());
			criteria_set_in.add(criteria);
		}

		String a5 = "select * from user_define_mid_criteria where define_id ="+define_id+" and mid_state = 2";
		ResultSet rs5 = stmt.executeQuery(a5);
		while(rs5.next()){
			criteria = new JSONObject();
			criteria.put("title", rs5.getString(3));
			criteria.put("id", rs5.getInt(1));
			criteria_set_ex.add(criteria);
		}

		for(int i = 0; i < criteria_set_in.size(); i++){
			JSONObject data_output = (JSONObject)criteria_set_in.get(i);
			JSONArray criterias = new JSONArray();

			String a3 = "select * from user_define_criteria where define_id ="+define_id+" and criteria_table <> 4 and mid_id="+data_output.get("id");
			ResultSet rs3 = stmt.executeQuery(a3);
			while(rs3.next()){
				criteria = new JSONObject();
				criteria.put("title", rs3.getString(9));
				int status_int = rs3.getInt(8);
				
				if(status_int == 1){
					status_data = "inclusion";
				}
				else if(status_int == 2){
					status_data = "exclusion";
				}
				
				int divider_int = rs3.getInt(21);
				String divider_data = "";
				if(divider_int == 0) divider_data = "no";
				else divider_data = "yes";

				criteria.put("status", status_data);
				criteria.put("table", rs3.getString(17));
				criteria.put("attribute", rs3.getInt(5));
				criteria.put("addition", rs3.getString(18));
				criteria.put("addition_query", rs3.getString(10));
				criteria.put("addition_date", rs3.getString(19));
				criteria.put("value_min", rs3.getString(11));
				criteria.put("value_max", rs3.getString(12));
				criteria.put("measure_count", rs3.getString(16));
				criteria.put("measure_method", rs3.getString(15));
				criteria.put("min_condition", rs3.getString(13));
				criteria.put("max_condition", rs3.getString(14));
				criteria.put("heir", rs3.getInt(5));
				criteria.put("condition", rs3.getInt(6));
				criteria.put("state", rs3.getString(20));
				criteria.put("isdivider", divider_data);
				criteria.put("id", rs3.getInt(1));
				criterias.add(criteria);
			}
			data_output.put("small", criterias);

		}

		for(int i = 0; i < criteria_set_ex.size(); i++){
			JSONObject data_output = (JSONObject)criteria_set_ex.get(i);
			JSONArray criterias = new JSONArray();
			String a3 = "select * from user_define_criteria where define_id ="+define_id+" and criteria_table <> 4 and mid_id="+data_output.get("id");
			ResultSet rs3 = stmt.executeQuery(a3);
			while(rs3.next()){
				criteria = new JSONObject();
				criteria.put("title", rs3.getString(9));
				int status_int = rs3.getInt(8);
				
				if(status_int == 1){
					status_data = "inclusion";
				}
				else if(status_int == 2){
					status_data = "exclusion";
				}

				int divider_int = rs3.getInt(21);
				String divider_data = "";
				if(divider_int == 0) divider_data = "no";
				else divider_data = "yes";
				
				criteria.put("status", status_data);
				criteria.put("table", rs3.getString(17));
				criteria.put("attribute", rs3.getInt(5));
				criteria.put("addition", rs3.getString(18));
				criteria.put("addition_query", rs3.getString(10));
				criteria.put("addition_date", rs3.getString(19));
				criteria.put("value_min", rs3.getString(11));
				criteria.put("value_max", rs3.getString(12));
				criteria.put("measure_count", rs3.getString(16));
				criteria.put("measure_method", rs3.getString(15));
				criteria.put("min_condition", rs3.getString(13));
				criteria.put("max_condition", rs3.getString(14));
				criteria.put("heir", rs3.getInt(5));
				criteria.put("condition", rs3.getInt(6));
				criteria.put("state", rs3.getString(20));
				criteria.put("isdivider", divider_data);
				criteria.put("id", rs3.getInt(1));
				criterias.add(criteria);
			}
			data_output.put("small", criterias);
		}

		String a7 = "select top 1 * from criteria order by criteria_id desc;";
		ResultSet rs7 = stmt.executeQuery(a7);
		int last_row_num = 0;
		while(rs7.next()){
			last_row_num = rs7.getInt(1);
		}

		out.println(criteria_set_in +"&"+criteria_set_ex+"&"+info_list+"&"+img_src+"&"+user_name+"&"+populations+"&"+last_row_num);
		stmt.close();
		conn.close();
	}


	else if(action.equals("save")){
		int user_id = (Integer)session.getAttribute("user_id");

		String input_criteria = request.getParameter("data");
		input_criteria = URLDecoder.decode(input_criteria, "UTF-8");
		String new_title = request.getParameter("title");
		new_title = URLDecoder.decode(new_title, "UTF-8");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;


		JSONParser parser = new JSONParser();
		JSONObject criteria = (JSONObject)parser.parse(input_criteria);

		JSONObject info = (JSONObject)criteria.get("info");
		String new_query_string = String.valueOf(info.get("define_id"));
		int new_define_id = Integer.parseInt(new_query_string);


		String title_s = "update user_define set define_title= N'"+new_title+"', define_start_date= N'"+today+"' where define_id ="+new_define_id;
		stmt.executeUpdate(title_s);

		String or_title = "select define_title from user_define where define_id = "+new_define_id;
		String original_title = "";
		ResultSet or_t = stmt.executeQuery(or_title);
		while(or_t.next()){
			original_title = or_t.getString(1);
		}

		String title_his = "insert into user_define_HIS(define_id, define_title, define_creator, define_start_date, edit_date, edit_reason, editor, ip_address, code) select define_id, N'"+new_title+"', define_creator, define_start_date, '"+today+"', N'modified the user define \""+original_title+"\". User define ID is \""+new_define_id+"\".', "+user_id+", N'"+ip_address+"', 4002 from user_define where define_id = "+new_define_id+";";
		stmt.executeUpdate(title_his);

		stmt.close();
		stmt = conn.createStatement();


		String a0 = "delete from user_define_criteria where define_id ="+new_define_id;
		stmt.executeUpdate(a0);
		

		String delete_mid = "delete from user_define_mid_criteria where define_id ="+new_define_id;
		stmt.executeUpdate(delete_mid);
		stmt.close();

		JSONArray criteria_set_input = (JSONArray)criteria.get("set");
		JSONArray inclusion_set = (JSONArray)criteria_set_input.get(0);

		for(int j = 0; j < inclusion_set.size(); j++){
			int mid_id = 0;
			int state_data = 1;

			//save mid
			JSONObject mid = (JSONObject)inclusion_set.get(j);
			String mid_title_text = String.valueOf(mid.get("title"));
			out.println("title:"+mid_title_text);
			if(!mid_title_text.equals("")){
				stmt = conn.createStatement();

				String mid_save = "insert into user_define_mid_criteria(define_id, mid_title, mid_state) values("+new_define_id+", N'"+mid_title_text+"', "+state_data+") SELECT @@IDENTITY;";
				
				ResultSet saved_mid_id = stmt.executeQuery(mid_save);

				while(saved_mid_id.next()){
					mid_id = saved_mid_id.getInt(1);
				}

				String his_save = "insert into user_define_mid_criteria_HIS(mid_id, define_id, mid_title, mid_state, edit_date, edit_reason, editor) values("+mid_id+", "+new_define_id+", N'"+mid_title_text+"', "+state_data+", '"+today+"', 'created', "+user_id+");";
				stmt.executeUpdate(his_save);
			}

			else{
				String table = String.valueOf(mid.get("table"));
				int table_data = 0;

				if(table.equals("person")){
					table_data = 0;
				}
				else if(table.equals("Measurement")){
					table_data = 3;
				}
				else if(table.equals("Observation")){
					table_data = 14;
				}
				else if(table.equals("Condition_occurrence")){
					table_data = 6;
				}
				else if(table.equals("Drug_exposure")){
					table_data = 5;
				}
				else if(table.equals("User_Define")){
					table_data = 9;
				}
				else if(table.equals("Visit_occurrence")){
					table_data = 4;
				}
				else if(table.equals("Procedure")){
					table_data = 8;
				}
				else if(table.equals("SQL")){
					table_data = 7;
				}
				String attribute = String.valueOf(mid.get("attribute"));
				int attribute_data = 0;
				if(table.equals("Drug_exposure")){
					attribute_data = Integer.parseInt(attribute);
				}
				else if(table.equals("Condition_occurrence")){
					if(attribute.equals("1")){
						attribute_data = 1;
					}
					else if(attribute.equals("2")){
						attribute_data = 2;
					}
					else if(attribute.equals("3")){
						attribute_data=3;
					}
					else if(attribute.equals("4")){
						attribute_data=4;
					}
				}

				String condition = String.valueOf(mid.get("condition"));
				int condition_data = Integer.parseInt(condition);

				String value = String.valueOf(mid.get("value"));
				int value_data = Integer.parseInt(value);

				String title_data = "";
				String addition_data = "";

				title_data = String.valueOf(mid.get("title"));

				if(title_data.equals("Year")) attribute_data = 1;

				addition_data = String.valueOf(mid.get("addition"));
				addition_data = addition_data.replace("%25", "%");
				String addition_data_text = "";
				addition_data_text = String.valueOf(mid.get("addition_text"));
				addition_data_text = URLDecoder.decode(addition_data_text, "UTF-8");
				addition_data_text = addition_data_text.replace("%25", "%");

				String date_addition_value = "";
				date_addition_value = String.valueOf(mid.get("date_addition_value"));
				date_addition_value = URLDecoder.decode(date_addition_value, "UTF-8");

				String value_min = "";
				value_min = String.valueOf(mid.get("value_min"));
				value_min = URLDecoder.decode(value_min, "UTF-8");

				String value_max = "";
				value_max = String.valueOf(mid.get("value_max"));
				value_max = URLDecoder.decode(value_max, "UTF-8");

				String measure_count = "";
				measure_count =  String.valueOf(mid.get("measure_count"));
				measure_count = URLDecoder.decode(measure_count, "UTF-8");

				String measure_method = "";
				measure_method = String.valueOf(mid.get("measure_method"));
				measure_method = URLDecoder.decode(measure_method,"UTF-8"); 
			
				String min_condition = "";
				min_condition = String.valueOf(mid.get("min_condition"));
				min_condition = URLDecoder.decode(min_condition,"UTF-8"); 
			
				String max_condition = "";
				max_condition = String.valueOf(mid.get("max_condition"));
				max_condition = URLDecoder.decode(max_condition,"UTF-8"); 

				String state = "";
				state = String.valueOf(mid.get("state"));
				state = URLDecoder.decode(state, "UTF-8");

				String isdivider_txt = "";
				isdivider_txt = String.valueOf(mid.get("isdivider"));
				isdivider_txt = URLDecoder.decode(isdivider_txt, "UTF-8");

				int isdivider = 0;
				if(isdivider_txt.equals("yes")) isdivider = 1;
				
				out.println(state);
				String inclusion_insert = "insert into user_define_criteria(define_id, criteria_table, criteria_attribute, criteria_date_standard, criteria_value, criteria_state, criteria_title, criteria_table_source_value, criteria_addition, criteria_addition_source_value, criteria_date_source_value, criteria_addition_min_value, criteria_addition_max_value, criteria_measurement_count, criteria_measurement_method, criteria_addition_min_condition, criteria_addition_max_condition, state, isdivider) values("+new_define_id+", "+table_data+", "+attribute_data+", "+condition_data+", N'"+value_data+"', "+state_data+", N'"+title_data+"', N'"+table+"', N'"+addition_data+"', N'"+addition_data_text+"', N'"+date_addition_value+"', N'"+value_min+"', N'"+value_max+"', N'"+measure_count+"', N'"+measure_method+"', N'"+min_condition+"', N'"+max_condition+"', N'"+state+"', "+isdivider+");";
				
				stmt = conn.createStatement();

				stmt.executeUpdate(inclusion_insert);
				stmt.close();

			}

			
			JSONArray criteria_set = (JSONArray)mid.get("small");
			if(criteria_set != null){
				for(int i = 0; i < criteria_set.size(); i++){
					stmt = conn.createStatement();
					JSONObject object = (JSONObject)criteria_set.get(i);
					
					String table = String.valueOf(object.get("table"));
					int table_data = 0;

					if(table.equals("person")){
						table_data = 0;
					}
					else if(table.equals("Measurement")){
						table_data = 3;
					}
					else if(table.equals("Observation")){
						table_data = 14;
					}
					else if(table.equals("Condition_occurrence")){
						table_data = 6;
					}
					else if(table.equals("Drug_exposure")){
						table_data = 5;
					}
					else if(table.equals("User_Define")){
						table_data = 9;
					}
					else if(table.equals("Visit_occurrence")){
						table_data = 4;
					}
					else if(table.equals("Procedure")){
						table_data = 8;
					}
					else if(table.equals("SQL")){
						table_data = 7;
					}

					String attribute = String.valueOf(object.get("attribute"));
					int attribute_data = 0;
					if(table.equals("Drug_exposure")){
						attribute_data = Integer.parseInt(attribute);
					}
					else if(table.equals("Condition_occurrence")){
						if(attribute.equals("1")){
							attribute_data = 1;
						}
						else if(attribute.equals("2")){
							attribute_data = 2;
						}
						else if(attribute.equals("3")){
							attribute_data=3;
						}
						else if(attribute.equals("4")){
							attribute_data=4;
						}
					}

					String condition = String.valueOf(object.get("condition"));
					int condition_data = Integer.parseInt(condition);

					String value = String.valueOf(object.get("value"));
					int value_data = Integer.parseInt(value);

					String title_data = "";
					String addition_data = "";

					title_data = String.valueOf(object.get("title"));

					if(title_data.equals("Year")) attribute_data = 1;

					addition_data = String.valueOf(object.get("addition"));
					addition_data = addition_data.replace("%25", "%");
					String addition_data_text = "";
					addition_data_text = String.valueOf(object.get("addition_text"));
					addition_data_text = URLDecoder.decode(addition_data_text, "UTF-8");
					addition_data_text = addition_data_text.replace("%25", "%");

					String date_addition_value = "";
					date_addition_value = String.valueOf(object.get("date_addition_value"));
					date_addition_value = URLDecoder.decode(date_addition_value, "UTF-8");

					String value_min = "";
					value_min = String.valueOf(object.get("value_min"));
					value_min = URLDecoder.decode(value_min, "UTF-8");

					String value_max = "";
					value_max = String.valueOf(object.get("value_max"));
					value_max = URLDecoder.decode(value_max, "UTF-8");

					String measure_count = "";
					measure_count =  String.valueOf(object.get("measure_count"));
					measure_count = URLDecoder.decode(measure_count, "UTF-8");

					String measure_method = "";
					measure_method = String.valueOf(object.get("measure_method"));
					measure_method = URLDecoder.decode(measure_method,"UTF-8"); 
				
					String min_condition = "";
					min_condition = String.valueOf(object.get("min_condition"));
					min_condition = URLDecoder.decode(min_condition,"UTF-8"); 
				
					String max_condition = "";
					max_condition = String.valueOf(object.get("max_condition"));
					max_condition = URLDecoder.decode(max_condition,"UTF-8"); 

					String state = "";
					state = String.valueOf(object.get("state"));
					state = URLDecoder.decode(state, "UTF-8");

					String isdivider_txt = "";
					isdivider_txt = String.valueOf(object.get("isdivider"));
					isdivider_txt = URLDecoder.decode(isdivider_txt, "UTF-8");

					int isdivider = 0;
					if(isdivider_txt.equals("yes")) isdivider = 1;
					
					int criteria_id_saved = 0;
					String inclusion_insert = "insert into user_define_criteria(criteria_table, criteria_attribute, criteria_date_standard, criteria_value, define_id, criteria_state, criteria_title, criteria_table_source_value, criteria_addition, criteria_addition_source_value, criteria_date_source_value, criteria_addition_min_value, criteria_addition_max_value, criteria_measurement_count, criteria_measurement_method, criteria_addition_min_condition, criteria_addition_max_condition, mid_id, state, isdivider) values("+table_data+", "+attribute_data+", "+condition_data+", N'"+value_data+"', "+new_define_id+", "+state_data+", N'"+title_data+"', N'"+table+"', N'"+addition_data+"', N'"+addition_data_text+"', N'"+date_addition_value+"', N'"+value_min+"', N'"+value_max+"', N'"+measure_count+"', N'"+measure_method+"', N'"+min_condition+"', N'"+max_condition+"', "+mid_id+", N'"+state+"', "+isdivider+") SELECT @@IDENTITY;";

					ResultSet r7 = stmt.executeQuery(inclusion_insert);
					while(r7.next()){
						criteria_id_saved = r7.getInt(1);
					}


					String his_criteria = "insert into user_define_criteria_HIS(criteria_id, criteria_table, criteria_attribute, criteria_date_standard, criteria_value, define_id, criteria_state, criteria_title, criteria_table_source_value, criteria_addition, criteria_addition_source_value, criteria_date_source_value, criteria_addition_min_value, criteria_addition_max_value, criteria_measurement_count, criteria_measurement_method, criteria_addition_min_condition, criteria_addition_max_condition, mid_id, state, isdivider, edit_date, edit_reason, editor) values("+criteria_id_saved+", "+table_data+", "+attribute_data+", "+condition_data+", N'"+value_data+"', "+new_define_id+", "+state_data+", N'"+title_data+"', N'"+table+"', N'"+addition_data+"', N'"+addition_data_text+"', N'"+date_addition_value+"', N'"+value_min+"', N'"+value_max+"', N'"+measure_count+"', N'"+measure_method+"', N'"+min_condition+"', N'"+max_condition+"', "+mid_id+", N'"+state+"', "+isdivider+", '"+today+"', 'created',"+user_id+");";
					stmt.executeUpdate(his_criteria);

					stmt.close();
				}
			}
		}

		JSONArray exclusion_set = (JSONArray)criteria_set_input.get(1);

		for(int j = 0; j < exclusion_set.size(); j++){

			int mid_id = 0;
			int state_data = 2;

			//save mid
			JSONObject mid = (JSONObject)exclusion_set.get(j);
			String mid_title_text = String.valueOf(mid.get("title"));
			String mid_save = "insert into user_define_mid_criteria(define_id, mid_title, mid_state) values("+new_define_id+", N'"+mid_title_text+"', "+state_data+") SELECT @@IDENTITY;";
			stmt = conn.createStatement();

			ResultSet saved_mid_id = stmt.executeQuery(mid_save);

			while(saved_mid_id.next()){
				mid_id = saved_mid_id.getInt(1);
			}

			String his_save = "insert into user_define_mid_criteria_HIS(mid_id, define_id, mid_title, mid_state, edit_date, edit_reason, editor) values("+mid_id+", "+new_define_id+", N'"+mid_title_text+"', "+state_data+", '"+today+"', 'created', "+user_id+");";
			stmt.executeUpdate(his_save);

			JSONArray criteria_set1 = (JSONArray)mid.get("small");

			for(int i = 0; i < criteria_set1.size(); i++){
				stmt = conn.createStatement();
				JSONObject object = (JSONObject)criteria_set1.get(i);
			
				
				String table = String.valueOf(object.get("table"));
				int table_data = 0;

				if(table.equals("person")){
					table_data = 0;
				}
				else if(table.equals("Measurement")){
					table_data = 3;
				}
				else if(table.equals("Observation")){
					table_data = 14;
				}

				else if(table.equals("Condition_occurrence")){
					table_data = 6;
				}
				else if(table.equals("Drug_exposure")){
					table_data =5;
				}
				else if(table.equals("User_Define")){
					table_data = 9;
				}
				else if(table.equals("SQL")){
					table_data = 7;
				}

				String attribute = String.valueOf(object.get("attribute"));
				int attribute_data = 0;
				if(table.equals("Drug_exposure")){
					attribute_data = Integer.parseInt(attribute);
				}
				else if(table.equals("Condition_occurrence")){
					if(attribute.equals("1")){
						attribute_data = 1;
					}
					else if(attribute.equals("2")){
						attribute_data = 2;
					}
					else if(attribute.equals("3")){
						attribute_data=3;
					}
					else if(attribute.equals("4")){
						attribute_data=4;
					}
				}

				String condition = String.valueOf(object.get("condition"));
				int condition_data = Integer.parseInt(condition);

				String value = String.valueOf(object.get("value"));
				int value_data = Integer.parseInt(value);
				String title_data = "";
				title_data = String.valueOf(object.get("title"));
				if(title_data.equals("Year")) attribute_data = 1;

				String addition_data = "";
				addition_data = String.valueOf(object.get("addition"));
				addition_data = addition_data.replace("%25", "%");
				String addition_data_text = "";
				addition_data_text = String.valueOf(object.get("addition_text"));
				addition_data_text = URLDecoder.decode(addition_data_text, "UTF-8");
				addition_data_text = addition_data_text.replace("%25", "%");
				
				String date_addition_value = "";
				date_addition_value = String.valueOf(object.get("date_addition_value"));
				date_addition_value = URLDecoder.decode(date_addition_value, "UTF-8");

				String value_min = "";
				value_min = String.valueOf(object.get("value_min"));
				value_min = URLDecoder.decode(value_min, "UTF-8");

				String value_max = "";
				value_max = String.valueOf(object.get("value_max"));
				value_max = URLDecoder.decode(value_max, "UTF-8");

				String measure_count = "";
				measure_count =  String.valueOf(object.get("measure_count"));
				measure_count = URLDecoder.decode(measure_count, "UTF-8");

				String measure_method = "";
				measure_method = String.valueOf(object.get("measure_method"));
				measure_method = URLDecoder.decode(measure_method,"UTF-8"); 

				String min_condition = "";
				min_condition = String.valueOf(object.get("min_condition"));
				min_condition = URLDecoder.decode(min_condition,"UTF-8"); 
			
				String max_condition = "";
				max_condition = String.valueOf(object.get("max_condition"));
				max_condition = URLDecoder.decode(max_condition,"UTF-8"); 
			
				String state = "";
				state = String.valueOf(object.get("state"));
				state = URLDecoder.decode(state, "UTF-8");

				String isdivider_txt = "";
				isdivider_txt = String.valueOf(object.get("isdivider"));
				isdivider_txt = URLDecoder.decode(isdivider_txt, "UTF-8");

				int isdivider = 0;
				if(isdivider_txt.equals("yes")) isdivider = 1;

				int criteria_id_saved = 0;
				String exclusion_insert = "insert into user_define_criteria(criteria_table, criteria_attribute, criteria_date_standard, criteria_value, define_id, criteria_state, criteria_title, criteria_table_source_value, criteria_addition, criteria_addition_source_value, criteria_date_source_value, criteria_addition_min_value, criteria_addition_max_value, criteria_measurement_count, criteria_measurement_method, criteria_addition_min_condition, criteria_addition_max_condition, mid_id, state, isdivider) values("+table_data+", "+attribute_data+", "+condition_data+", N'"+value_data+"', "+new_define_id+", "+state_data+", N'"+title_data+"', N'"+table+"', N'"+addition_data+"', N'"+addition_data_text+"', N'"+date_addition_value+"', N'"+value_min+"', N'"+value_max+"', N'"+measure_count+"', N'"+measure_method+"', N'"+min_condition+"', N'"+max_condition+"', "+mid_id+", N'"+state+"', "+isdivider+") SELECT @@IDENTITY;";

				ResultSet r7 = stmt.executeQuery(exclusion_insert);
				while(r7.next()){
					criteria_id_saved = r7.getInt(1);
				}


				String his_criteria = "insert into user_define_criteria_HIS(criteria_id, criteria_table, criteria_attribute, criteria_date_standard, criteria_value, define_id, criteria_state, criteria_title, criteria_table_source_value, criteria_addition, criteria_addition_source_value, criteria_date_source_value, criteria_addition_min_value, criteria_addition_max_value, criteria_measurement_count, criteria_measurement_method, criteria_addition_min_condition, criteria_addition_max_condition, mid_id, state, isdivider, edit_date, edit_reason, editor) values("+criteria_id_saved+", "+table_data+", "+attribute_data+", "+condition_data+", N'"+value_data+"', "+new_define_id+", "+state_data+", N'"+title_data+"', N'"+table+"', N'"+addition_data+"', N'"+addition_data_text+"', N'"+date_addition_value+"', N'"+value_min+"', N'"+value_max+"', N'"+measure_count+"', N'"+measure_method+"', N'"+min_condition+"', N'"+max_condition+"', "+mid_id+", N'"+state+"', "+isdivider+", '"+today+"', 'created',"+user_id+");";
				stmt.executeUpdate(his_criteria);


			}
		}
		
		stmt.close();
		conn.close();

	}

%>
