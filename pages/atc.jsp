<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.net.URLDecoder" %>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>
 
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
        get = "select SECOND, count(*) from 'atc - rxnorm mapping table' where FIRST Like '"+title+"' escape '/' group by SECOND";
        ResultSet first = stmt.executeQuery(get);

        while(first.next()){
            String output = first.getString(1);
            if(output.equals("")){}
            else{
                JSONObject item = new JSONObject();
                item.put("title", first.getString(1));
                item.put("value", 2);
                item.put("isChecked", "false");
                if(first.getInt(2) > 1)
                    item.put("items", new JSONArray());
                result.add(item);
            }
        }
        stmt.close();
		conn.close();

    }

    else if(levels.equals("1")){
        get = "select THIRD, count(*) from 'atc - rxnorm mapping table' where SECOND Like '"+title+"' escape '/' group by THIRD";
        ResultSet second = stmt.executeQuery(get);

        while(second.next()){
            String output = second.getString(1);
            if(output.equals("")){}
            else {
                JSONObject item = new JSONObject();
                item.put("title", second.getString(1));
                item.put("value", 3);
                item.put("isChecked", false);
                
                if(second.getInt(2) > 1)
                    item.put("items", new JSONArray());
                result.add(item);
            }
        }
        stmt.close();
		conn.close();

    }
    
    else if(levels.equals("2")){
        get = "select FORTH, count(*) from 'atc - rxnorm mapping table' where THIRD Like '"+title+"' escape '/' group by FORTH";
        
        ResultSet third = stmt.executeQuery(get);

        while(third.next()){
            String output = third.getString(1);
            if(output.equals("")){}
            else{
                JSONObject item = new JSONObject();
                item.put("title", third.getString(1));
                item.put("value", 4);
                item.put("isChecked", false);
                
                if(third.getInt(2) > 1)
                    item.put("items", new JSONArray());
                result.add(item);
            }
        }
        stmt.close();
		conn.close();


    }

    else if(levels.equals("3")){
        get = "select distinct FIFTH from 'atc - rxnorm mapping table' where FORTH Like '"+title+"' escape '/'";
        
        ResultSet fifth = stmt.executeQuery(get);

        int i = 18654;
        while(fifth.next()){
            String output = fifth.getString(1);
            if(output.equals("")){}
            else{
                JSONObject item = new JSONObject();
                item.put("title", fifth.getString(1));
                item.put("isChecked", false);
                item.put("value", 5);
                item.put("concept_id", i);
                result.add(item);
                i++;
            }
        }
        stmt.close();
		conn.close();

    }


    out.print(result);


%>
