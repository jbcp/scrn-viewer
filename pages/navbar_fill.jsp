<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
<%@page import="java.net.URLDecoder"%>

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

    JSONObject message;
    JSONArray message_list  = new JSONArray();

	String action = request.getParameter("action");

	if(action.equals("load")){
        int user_id = (Integer)session.getAttribute("user_id");
        String loadmessage = "select m.mem_name, mem_img, project_title, project_protocol_id, project_description, project_drug, project_phase, pp.parti_id  from member m, project p, project_participant pp where pp.project_id = p.project_id and p.project_creator = m.mem_id and pp.accept = 0 and pp.mem_id = "+user_id;

        ResultSet rs = stmt.executeQuery(loadmessage);

        while(rs.next()){
            message = new JSONObject();
            message.put("creator", rs.getString(1));
            message.put("creator_img", rs.getString(2));
            message.put("project_title", rs.getString(3));
            message.put("project_protocol_id", rs.getString(4));
            message.put("project_description", rs.getString(5));
            message.put("project_drug", rs.getString(6));
            message.put("project_phase", rs.getString(7));
            message.put("participant_id", rs.getInt(8));
            message_list.add(message);
        }
		stmt.close();
		conn.close();

        out.println(message_list);
	}

    else if(action.equals("save")){
        
        Statement stmt1 = conn.createStatement();

        String parti_id = request.getParameter("parti_id");
        String message_response = request.getParameter("response");
		int mem_id = (Integer)session.getAttribute("user_id");

        String saveresponse = "update project_participant set accept = "+message_response+" where parti_id="+parti_id;
        stmt.executeUpdate(saveresponse);
		
        if(message_response.equals("1")){
            String a0 = "select project_id from project_participant where parti_id = "+parti_id;
            int project_id = 0;
            ResultSet rs0 = stmt.executeQuery(a0);
            while(rs0.next()){
                project_id = rs0.getInt(1);
            }
            String a1 = "select eligibility_id from eligibility where project_id = "+project_id;
            ResultSet rs1 = stmt.executeQuery(a1);
            while(rs1.next()){
                String a2 = "insert into eligibility_status(eligibility_id, mem_id, status) values("+rs1.getInt(1)+", "+mem_id+", N'Ready');";
                stmt1.executeUpdate(a2);
            }
            stmt1.close();
                    out.println("save");

        }
        stmt.close();
		conn.close();

	}

%>
