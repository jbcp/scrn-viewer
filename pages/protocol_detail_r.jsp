<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@ page import="java.net.URLDecoder" %>

<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
 
<%
    String fileName = "mssql.ini"; 
	String rfileName = "r_loc.ini";
    String fileDir = "/dbsource"; 
    String filePath = request.getRealPath(fileDir) + "/";
	String rfilePath = request.getRealPath(fileDir) + "/";
    filePath += fileName; 
	String rlocfile = rfilePath + rfileName;
    JSONParser parser1 = new JSONParser();
	JSONParser parser_r = new JSONParser();
    JSONObject jsonObject = new JSONObject();
	JSONObject jsonObject_r = new JSONObject();
    try{
        Object obj = parser1.parse(new FileReader(filePath));
		Object r_obj = parser_r.parse(new FileReader(rlocfile));
        jsonObject = (JSONObject) obj;
		jsonObject_r = (JSONObject) r_obj;
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
    stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

	String action = request.getParameter("action");

	if(action.equals("load")){
		String img_src= (String)session.getAttribute("img_src");
		String user_name = (String)session.getAttribute("user_name");
		String user_id = (String)session.getAttribute("provider_id");

		String eligibility_id = request.getParameter("eligibility_id");
		String project_id = request.getParameter("project_id");

		String check = "select person_list, condition_list, drug_list, measurement_list, procedure_list from result_protocol where eligibility_id="+eligibility_id+" and project_id="+project_id+" and provider_id ="+user_id;
	

		ResultSet rs_c = stmt.executeQuery(check);
		
		String person = "no";
		String condition ="no";
		String drug = "no";
		String measurement = "no";
		String procedure = "no";

		while(rs_c.next()){
			if(rs_c.getString(1) != null) person = rs_c.getString(1);
			if(rs_c.getString(2) != null) condition = rs_c.getString(2);
			if(rs_c.getString(3) != null) drug = rs_c.getString(3);
			if(rs_c.getString(4) != null) measurement = rs_c.getString(4);
			if(rs_c.getString(5) != null) procedure = rs_c.getString(5);
		}
		out.println(img_src+"&"+user_name+"&"+person+"&"+condition+"&"+drug+"&"+procedure+"&"+measurement);
		stmt.close();
		conn.close();
	}

	else if(action.equals("execute")){
		String code = request.getParameter("code");
		String project_id = request.getParameter("project_id");
		String eligibility_id = request.getParameter("eligibility_id");
		String demo = request.getParameter("demo");
		String condition = request.getParameter("condi");
		String drug = request.getParameter("drug");
		String measure = request.getParameter("measure");
		String proce = request.getParameter("proc");
		String load_demo = "Demographic <- fromJSON(\""+jsonObject_r.get("location")+"/pages/r_data.jsp?action=demographic&project_id="+project_id+"&eligibility_id="+eligibility_id+"\")";
		String load_condi ="Condition <- fromJSON(\""+jsonObject_r.get("location")+"/pages/r_data.jsp?action=condition&project_id="+project_id+"&eligibility_id="+eligibility_id+"\")";
		String load_drug = "Drug <- fromJSON(\""+jsonObject_r.get("location")+"/pages/r_data.jsp?action=medication&project_id="+project_id+"&eligibility_id="+eligibility_id+"\")";
		String load_meas = "Measurement <- fromJSON(\""+jsonObject_r.get("location")+"/pages/r_data.jsp?action=measurement&project_id="+project_id+"&eligibility_id="+eligibility_id+"\")";
		String load_proc = "Procedure <- fromJSON(\""+jsonObject_r.get("location")+"/pages/r_data.jsp?action=procedure&project_id="+project_id+"&eligibility_id="+eligibility_id+"\")";
		code = URLDecoder.decode(code, "UTF-8");
		FileWriter test = new FileWriter(jsonObject_r.get("r_tot_loc")+"code.r");
		test.write("library(jsonlite)");
		test.write("\n");

		if(demo.equals("1")) {
			test.write(load_demo.toString());
			test.write("\n");
		}
		if(condition.equals("1")) {
			test.write(load_condi.toString());
			test.write("\n");
		}
		if(drug.equals("1")) {
			test.write(load_drug.toString());
			test.write("\n");
		}
		if(measure.equals("1")) {
			test.write(load_meas.toString());
			test.write("\n");
		}
		if(proce.equals("1")) {
			test.write(load_proc.toString());
			test.write("\n");
		}
		test.write(code.toString());
		test.flush();

		String cmd = "";
		String str = null;
		String result = "";
		StringBuffer sb = null;

		sb = new StringBuffer();

		String command = "Rscript "+jsonObject_r.get("r_tot_loc")+"code.r";
		Process proc = Runtime.getRuntime().exec(command);

		BufferedReader br = new BufferedReader(new InputStreamReader(proc.getInputStream()));

		while((str = br.readLine())!= null){
			sb.append(str).append("</br>");
			out.println(str);
		}

		try{
			proc.waitFor();
			int rtn = proc.exitValue();
			if(rtn != 0){
				result = "exit value was non-zero " + rtn;
			}
		}catch(InterruptedException e){
			result = "process was interrupted";
		}finally{
			br.close();
		}
		stmt.close();
		conn.close();
		out.println(result);
	}
%>
