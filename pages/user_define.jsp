<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject" %>
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


    JSONObject user_define1 = null;
    JSONArray user_define = new JSONArray();

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");
	String ip_address = request.getRemoteAddr();

	if(action.equals("load")){
		int user_id = (Integer)session.getAttribute("user_id");
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		String a1 = "select define_id, define_title, mem_name, define_start_date from user_define, member where define_creator = mem_id and define_creator =  "+user_id;
		ResultSet rs = stmt.executeQuery(a1);

		while(rs.next()){
			user_define1 = new JSONObject();
			user_define1.put("define_id", rs.getInt(1));
			user_define1.put("define_title", rs.getString(2));
			user_define1.put("define_creator", rs.getString(3));
			user_define1.put("define_start", rs.getString(4));
			user_define.add(user_define1);
		}

		out.println(user_define+"&"+img_src+"&"+user_name);
		stmt.close();
		conn.close();
	}

	else if(action.equals("save")){
		int user_id = (Integer)session.getAttribute("user_id");
		int user_corp = (Integer)session.getAttribute("user_corp");

		String title = request.getParameter("title");
		String define_title = URLDecoder.decode(title, "UTF-8");

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;
			
		String a1 = "insert into user_define( define_title, define_creator, define_start_date) Values(N'" + define_title + "', "+user_id+", '"+today+"') SELECT @@IDENTITY;";

		ResultSet userdefine_q = stmt.executeQuery(a1);
		int saved_user_define_id = 0;
		while(userdefine_q.next()){
			saved_user_define_id = userdefine_q.getInt(1);
		}

		String a2 = "insert into user_define_HIS(define_id, define_title, define_creator, define_start_date, editor, edit_date, edit_reason, ip_address, code) Values("+saved_user_define_id+", N'" + define_title + "', "+user_id+", '"+today+"', "+user_id+", '"+today+"', N'created a new user define \""+define_title+"\". User define ID is \""+saved_user_define_id+"\".', N'"+ip_address+"', 4000)";
		stmt.executeUpdate(a2);

		stmt.close();
		conn.close();
	}

	else if(action.equals("delete")){
		String define_id = request.getParameter("id");
		int return_value = 0;
		int user_id = (Integer)session.getAttribute("user_id");

		String a_title ="select define_title from user_define where define_id="+define_id;
		String title = "";
		ResultSet a_t = stmt.executeQuery(a_title);
		while(a_t.next()){
			title = a_t.getString(1);
		}

		DecimalFormat df = new DecimalFormat("00");
		Calendar calendar = Calendar.getInstance();

		String year = Integer.toString(calendar.get(Calendar.YEAR)); 
		String month = df.format(calendar.get(Calendar.MONTH) + 1); 
		String day = df.format(calendar.get(Calendar.DATE)); 
		String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
		String minute = df.format(calendar.get(Calendar.MINUTE));
		String second = df.format(calendar.get(Calendar.SECOND));
	
		String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

		String a1 = "insert into user_define_HIS(define_id, define_title, define_creator, define_start_date, editor, edit_date, edit_reason, ip_address, code) select define_id, define_title, define_creator, define_start_date, "+user_id+", '"+today+"', N'deleted the user define \""+title+"\". User define ID is \""+define_id+"\"', N'"+ip_address+"', 4001 from user_define where define_id = "+define_id;
		stmt.executeUpdate(a1);
	
		String a2 = "delete from user_define where define_id="+define_id+";";
        stmt.executeUpdate(a2);
        return_value = 0;

    
    	out.print(return_value);

		stmt.close();
		conn.close();

	}

%>
