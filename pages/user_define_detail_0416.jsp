<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.SimpleDateFormat" %>

<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
 
<%
    String fileName = "mssql.ini";
    String fileDir = "/dbsource";
    String filePath = request.getRealPath(fileDir) + "/";
    filePath += fileName;
    // 파일읽기
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

	String define_id = request.getParameter("define_id");

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  

    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");

	if(action.equals("load")){
		JSONObject criteria = null;
		JSONObject visit = null;
		JSONObject info = null;
		JSONArray populations = new JSONArray();
		JSONArray criteria_set = new JSONArray();
		JSONArray info_list = new JSONArray();

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

		String a2 = "select * from user_criteria_detail where user_define_id = "+define_id+" and criteria_detail_table = 4";
		ResultSet rs2 = stmt.executeQuery(a2);
		while(rs2.next()){
			visit = new JSONObject();
			visit.put("type", "visit");
			visit.put("value", rs2.getString(12));
			visit.put("period", rs2.getInt(5));
			populations.add(visit);
		}

		String a3 = "select * from user_criteria_detail where user_define_id ="+define_id+" and criteria_detail_table <> 4";
		ResultSet rs3 = stmt.executeQuery(a3);
		while(rs3.next()){
			criteria = new JSONObject();
			criteria.put("title", rs3.getString(7));
			int status_int = rs3.getInt(6);
			
			if(status_int == 1){
				status_data = "inclusion";
			}
			else if(status_int == 2){
				status_data = "exclusion";
			}
			
			criteria.put("status", status_data);
			criteria.put("table", rs3.getString(8));
			criteria.put("attribute", rs3.getInt(5));
			criteria.put("addition", rs3.getString(11));
			criteria.put("addition_query", rs3.getString(10));
			criteria.put("addition_date", rs3.getString(12));
			criteria.put("value_min", rs3.getString(13));
			criteria.put("value_max", rs3.getString(14));
			criteria.put("measure_count", rs3.getString(17));
			criteria.put("measure_method", rs3.getString(16));
			criteria.put("min_condition", rs3.getString(18));
			criteria.put("max_condition", rs3.getString(19));
			criteria.put("heir", rs3.getInt(3));
			criteria.put("condition", rs3.getInt(4));
			criteria_set.add(criteria);
		}

		out.println(criteria_set +"&"+info_list+"&"+img_src+"&"+user_name+"&"+populations);
		stmt.close();
		conn.close();
	}


	else if(action.equals("save")){

		String input_criteria = request.getParameter("data");
		input_criteria = URLDecoder.decode(input_criteria, "UTF-8");
		String new_title = request.getParameter("title");
		new_title = URLDecoder.decode(new_title, "UTF-8");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;


		JSONParser parser = new JSONParser();
		JSONObject criteria = (JSONObject)parser.parse(input_criteria);

		JSONObject info = (JSONObject)criteria.get("info");
		String new_query_string = String.valueOf(info.get("define_id"));
		int new_define_id = Integer.parseInt(new_query_string);


		String title_s = "update user_define set define_title= N'"+new_title+"' where define_id ="+new_define_id;
		stmt.executeUpdate(title_s);
		stmt.close();
		stmt = conn.createStatement();

		String a0 = "delete from user_criteria_detail where user_define_id ="+new_define_id;
		stmt.executeUpdate(a0);
		stmt.close();

		JSONArray criteria_set = (JSONArray)criteria.get("set");
		JSONObject inclusion_set = (JSONObject)criteria_set.get(0);
		JSONArray criteria_detail_set = (JSONArray)inclusion_set.get("criteria_detail_set");


		for(int i = 0; i < criteria_detail_set.size(); i++){
			stmt = conn.createStatement();
			JSONObject object = (JSONObject)criteria_detail_set.get(i);
			
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
			int state_data = 1;

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


			String inclusion_insert = "insert into user_criteria_detail(criteria_detail_table, criteria_detail_attribute, criteria_detail_condition, criteria_detail_value, user_define_id, criteria_state, criteria_title, criteria_table, criteria_addition, criteria_addition_text, date_addition_value, value_addition_min, value_addition_max, measurement_count, measurement_method, min_condition, max_condition) values("+table_data+", "+attribute_data+", "+condition_data+", N'"+value_data+"', "+new_define_id+", "+state_data+", N'"+title_data+"', N'"+table+"', N'"+addition_data+"', N'"+addition_data_text+"', N'"+date_addition_value+"', N'"+value_min+"', N'"+value_max+"', N'"+measure_count+"', N'"+measure_method+"', N'"+min_condition+"', N'"+max_condition+"');";

			stmt.executeUpdate(inclusion_insert);
			stmt.close();

		}

		JSONObject exclusion_set = (JSONObject)criteria_set.get(1);
		JSONArray criteria_detail_set1 = (JSONArray)exclusion_set.get("criteria_detail_set");

		for(int i = 0; i < criteria_detail_set1.size(); i++){
			stmt = conn.createStatement();
			JSONObject object = (JSONObject)criteria_detail_set1.get(i);
			
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
			int state_data = 2;
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
		
			String exclusion_insert = "insert into user_criteria_detail(criteria_detail_table, criteria_detail_attribute, criteria_detail_condition, criteria_detail_value, user_define_id, criteria_state, criteria_title, criteria_table, criteria_addition, criteria_addition_text, date_addition_value, value_addition_min, value_addition_max, measurement_count, measurement_method, min_condition, max_condition) values("+table_data+", "+attribute_data+", "+condition_data+", N'"+value_data+"', "+new_define_id+", "+state_data+", N'"+title_data+"', N'"+table+"', N'"+addition_data+"', N'"+addition_data_text+"', N'"+date_addition_value+"', N'"+value_min+"', N'"+value_max+"', N'"+measure_count+"', N'"+measure_method+"', N'"+min_condition+"', N'"+max_condition+"');";

			stmt.executeUpdate(exclusion_insert);
			stmt.close();

		}

		conn.close();
	}

%>
