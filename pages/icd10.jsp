<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.io.*"%>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="org.json.simple.parser.ParseException"%>
 
<%
    String fileName = "cdm.ini"; 
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

    JSONArray result = new JSONArray();

    Statement stmt =null;
    stmt = conn.createStatement();

    String levels = request.getParameter("level");
    String title = request.getParameter("title");
    title = URLDecoder.decode(title);

    String get = "";

    if(levels.equals("0")){
        get = "select 'Mid category', count(*) from 'icd10 - snomed mapping table' where 'Large category' Like '"+title+"' escape '/' group by 'Mid category'";
        ResultSet large = stmt.executeQuery(get);

        while(large.next()){
            JSONObject item = new JSONObject();
            item.put("title", large.getString(1));
            item.put("value", 2);
            item.put("isChecked", "false");
            if(large.getInt(2) > 1)
                item.put("items", new JSONArray());
            result.add(item);
        }
        stmt.close();
		conn.close();

    }

    else if(levels.equals("1")){
        get = "select 'Small category', count(*) from 'icd10 - snomed mapping table' where 'Mid category' Like '"+title+"' escape '/' group by 'Small category'";
        ResultSet mid = stmt.executeQuery(get);

        while(mid.next()){
            JSONObject item = new JSONObject();
            item.put("title", mid.getString(1));
            item.put("value", 3);
            item.put("isChecked", false);
            
            if(mid.getInt(2) > 1)
                item.put("items", new JSONArray());
            result.add(item);
        }
        stmt.close();
		conn.close();

    }
    
    else if(levels.equals("2")){
        get = "select distinct 'Code name', 'Code ID' from 'icd10 - snomed mapping table' where 'Small category' Like '"+title+"' escape '/'";
        
        ResultSet small = stmt.executeQuery(get);

        while(small.next()){
            JSONObject item = new JSONObject();
            item.put("title", small.getString(1));
            item.put("isChecked", false);
            item.put("value", 4);
            item.put("concept_id", small.getInt(2));
            result.add(item);
        }
        stmt.close();
		conn.close();


    }

    out.print(result);


%>
