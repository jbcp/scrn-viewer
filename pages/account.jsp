<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="com.oreilly.servlet.*"%>
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

    JSONObject info = null;
	JSONObject range = null;
    JSONArray account = new JSONArray();

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  
    Connection conn= DriverManager.getConnection(connectionUrl);  
    Statement stmt =null;
    stmt = conn.createStatement();

	String action = request.getParameter("action");
	String ip_address = request.getRemoteAddr();

	if(action.equals("load")){
		int user_id = (Integer)session.getAttribute("user_id");

		String info_s = "select mem_name, corp_name_kr, mem_position, mem_mail, mem_mobile, mem_phone, mem_role, mem_dept from member, corp where mem_corp = corp_id and mem_id = "+user_id+";";
		ResultSet rs = stmt.executeQuery(info_s);
		
		while(rs.next()){
			info = new JSONObject();
			info.put("name", rs.getString(1));
			info.put("corp_name", rs.getString(2));
			info.put("position", rs.getString(3));
			info.put("mail", rs.getString(4));
			info.put("mobile", rs.getString(5));
			info.put("phone", rs.getString(6));
			info.put("role", rs.getString(7));
			info.put("dept", rs.getString(8));
			account.add(info);
		}
		stmt.close();
		conn.close();

		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");

		out.println(account+"&"+range+"&"+img_src+"&"+user_name);
	}

	else if(action.equals("save")){
		int user_id = (Integer)session.getAttribute("user_id");
		int user_corp = (Integer)session.getAttribute("user_corp");
		String user_name = (String)session.getAttribute("user_name");

		String mobile = request.getParameter("mobile");
		String phone = request.getParameter("phone");
		String password = request.getParameter("password");
		String realFolder = request.getParameter("imgfile");

		String a1 = "";

		if(password == ""){
			if(realFolder.equals("no")) a1 = "update member set mem_mobile= N'"+mobile+"', mem_phone=N'"+phone+"' where mem_id = "+user_id;
			else {
				a1 = "update member set mem_mobile= N'"+mobile+"', mem_phone=N'"+phone+"', mem_img = N'"+realFolder+"' where mem_id = "+user_id;
				session.removeAttribute("img_src");
				session.setAttribute("img_src", realFolder);
			}
		}
		else{
			if(realFolder.equals("no")) a1 = "update member set mem_mobile= N'"+mobile+"', mem_phone=N'"+phone+"', mem_password=N'"+password+"' where mem_id = "+user_id;
			else {
				a1 = "update member set mem_mobile= N'"+mobile+"', mem_phone=N'"+phone+"', mem_password=N'"+password+"', mem_img = N'"+realFolder+"' where mem_id = "+user_id;
				session.removeAttribute("img_src");
				session.setAttribute("img_src", realFolder);
			}
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
		String a5 = "insert member_HIS(mem_id, mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, edit_date, edit_reason, editor, ip_address, code) select mem_id, mem_name, mem_position, mem_mail, mem_password, mem_mobile, mem_phone, mem_corp, mem_role, mem_img, mem_dept, provider_id, '"+today+"', N'modified account. Modified member name is \""+user_name+"\", member ID is \""+user_id+"\"', "+user_id+", N'"+ip_address+"', 5000 from member where mem_id="+user_id;

		stmt.executeUpdate(a1);
		stmt.executeUpdate(a5);

		stmt.close();
		conn.close();
	}


%>
