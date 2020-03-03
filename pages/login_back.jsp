<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<head>
<script type="text/javascript" src="./print_log.js" ></script> 

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

    String mail_address = URLDecoder.decode(request.getParameter("id"), "UTF-8"); 
    String password_input = URLDecoder.decode(request.getParameter("password"), "UTF-8");

    int result_num = 0; 

    String a1 = "if not exists(select mem_id from member where mem_mail = N'"+mail_address+"') select 'NO' as result_pass else select mem_id from member where mem_mail = N'"+mail_address+"';";
    ResultSet rs = stmt.executeQuery(a1);

    String result="";
    int mem_id = 0;
    String mem_role = "no";
    int corp = 0;
    String mem_name = "";
    String password = "";
    String img = "";
    String provider_id = "";
    String mem_mail = "";
	String ip_address = request.getRemoteAddr();

    while(rs.next()){
        result = rs.getString(1);
    }

    stmt.close();
    stmt = conn.createStatement();

    if(result.equals("NO")){
       response.sendRedirect("login.jsp");
    }

    else{
        String a2 = "select mem_id, mem_role, mem_corp, mem_name, mem_password, mem_img, provider_id, mem_mail from member, corp where mem_id ="+result+" and member.mem_corp = corp.corp_id;";
        ResultSet rs2 = stmt.executeQuery(a2);
        while(rs2.next()){
            mem_id = rs2.getInt(1);
            mem_role = rs2.getString(2);  
            corp = rs2.getInt(3);
            mem_name = rs2.getString(4);
            password = rs2.getString(5);
            img = rs2.getString(6);
            provider_id = rs2.getString(7);
            mem_mail = rs2.getString(8);
        }

        if(password_input.equals(password)){
            session.setAttribute("user_id", mem_id);
            session.setAttribute("user_name", mem_name);
            session.setAttribute("user_role", mem_role); 
            session.setAttribute("user_corp", corp);   
            session.setAttribute("provider_id", provider_id);
            session.setAttribute("user_mail", mem_mail);
            if(img == null) img = "../upload/default_photo.jpg";
            else if(img == "") img = "../upload/default_photo.jpg";
            else session.setAttribute("img_src", img);

            DecimalFormat df = new DecimalFormat("00");
            Calendar calendar = Calendar.getInstance();

            String year = Integer.toString(calendar.get(Calendar.YEAR)); 
            String month = df.format(calendar.get(Calendar.MONTH) + 1); 
            String day = df.format(calendar.get(Calendar.DATE)); 
            String hour = df.format(calendar.get(Calendar.HOUR_OF_DAY));
            String minute = df.format(calendar.get(Calendar.MINUTE));
            String second = df.format(calendar.get(Calendar.SECOND));
        
            String today = year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second;

            String a3 = "insert system_log(system_log_date, system_log_reason, mem_id, ip_address, code) values('"+today+"', N'Successfully logged in', "+mem_id+", N'"+ip_address+"', 1000)"; 
            stmt.executeUpdate(a3);

            %>
            <script>print_log("login");</script></head>
            <%
        }
        else {
            response.sendRedirect("login.jsp");
        }
    }

    stmt.close();
    conn.close();
%>
