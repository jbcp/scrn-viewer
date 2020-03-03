<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.parser.ParseException"%>


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

    JSONObject item1 = null;
    JSONArray item = new JSONArray();
	String table = request.getParameter("table");

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

	String connectionUrl = "jdbc:sqlserver://"+jsonObject.get("ip")+":"+jsonObject.get("port")+";" +  "databaseName="+jsonObject.get("dbName")+";user="+jsonObject.get("id")+";password="+jsonObject.get("password")+";characterEncoding=UTF-8;";  

    Connection conn= DriverManager.getConnection(connectionUrl);  

    Statement stmt =null;
    stmt = conn.createStatement();

	if(table.equals("drug")){
		int i = 1;
		String drug = "select distinct(FIFTH) from 'atc - rxnorm mapping table';";
		ResultSet drug_result = stmt.executeQuery(drug);
		while(drug_result.next()){
			item1 = new JSONObject();
			item1.put("domain_id", "Drug");
			item1.put("title", drug_result.getString(1));
			item1.put("concept_id", i);
			item1.put("heir", "5");
			item.add(item1);
			i++;
		}

		out.print(item);
		stmt.close();
		conn.close();
	}

	else if(table.equals("condition")){
		int i = 100000;
		String concept = "select distinct(concept_name) from 'icd10 - snomed mapping table';";
		String small = "select distinct(SMALL) from 'icd10 - snomed mapping table';";
		String mid = "select distinct(MID) from 'icd10 - snomed mapping table';";
		
		stmt.close();
		stmt = conn.createStatement();

		ResultSet condition_mid = stmt.executeQuery(mid);
		while(condition_mid.next()){
			item1 = new JSONObject();
			item1.put("domain_id", "Condition");
			item1.put("title", condition_mid.getString(1));
			item1.put("concept_id", i);
			item1.put("heir", "2");
			item.add(item1);
			i++;
		}

		stmt.close();
		stmt = conn.createStatement();

		ResultSet condition_small = stmt.executeQuery(small);
		while(condition_small.next()){
			item1 = new JSONObject();
			item1.put("domain_id", "Condition");
			item1.put("title", condition_small.getString(1));
			item1.put("concept_id", i);
			item1.put("heir", "3");
			item.add(item1);
			i++;
		}

		//더 많은 검색을 원한다면 아래 주석을 해제
		/*
		stmt.close();
		stmt = conn.createStatement();

		ResultSet condition_result = stmt.executeQuery(concept);
		while(condition_result.next()){
			item1 = new JSONObject();
			item1.put("domain_id", "Condition");
			item1.put("title", condition_result.getString(1));
			item1.put("concept_id", i);
			item1.put("heir", "4");
			item.add(item1);
			i++;
		}*/
		out.print(item);
		stmt.close();
		conn.close();
	}

	else if(table.equals("measurement")){
		String measurement = "select * from 'measurement observation mapping table' where domain_id Like N'Measurement' or domain_id Like N'Observation' ;";
		ResultSet rs = stmt.executeQuery(measurement);
		while(rs.next()){
			item1 = new JSONObject();
			item1.put("domain_id", rs.getString(2));
			item1.put("title", rs.getString(1));
			item1.put("concept_id", rs.getInt(3));
			item1.put("heir", "1");
			item.add(item1);
		}
		out.print(item);
		stmt.close();
		conn.close();

	}

	else if(table.equals("procedure")){
		String procedure = "select * from 'measurement observation mapping table' where domain_id Like N'Procedure';";
		ResultSet rs = stmt.executeQuery(procedure);
		while(rs.next()){
			item1 = new JSONObject();
			item1.put("domain_id", rs.getString(2));
			item1.put("title", rs.getString(1));
			item1.put("concept_id", rs.getInt(3));
			item1.put("heir", "1");
			item.add(item1);
		}
		out.print(item);
		stmt.close();
		conn.close();

	}

	else if(table.equals("age")){
		item1 = new JSONObject();
		item1.put("domain_id", "age");
		item1.put("title","Year" );
		item1.put("concept_id",0);
		item.add(item1);
		out.print(item);
		stmt.close();
		conn.close();


	}

	else if(table.equals("gender")){
		item1 = new JSONObject();
		item1.put("domain_id", "gender");
		item1.put("title", "Female");
		item1.put("concept_id", 8532);
		item.add(item1);

		item1 = new JSONObject();
		item1.put("domain_id", "gender");
		item1.put("title", "Male");
		item1.put("concept_id", 8507);
		item.add(item1);

		item1 = new JSONObject();
		item1.put("domain_id", "gender");
		item1.put("title", "Both");
		item1.put("concept_id", 8532);
		item.add(item1);

		out.print(item);
		stmt.close();
		conn.close();


	}


	else if(table.equals("user_define")){
		String user_q = "select define_title, define_id from user_define";

		
		ResultSet uq = stmt.executeQuery(user_q);
		while(uq.next()){
			item1 = new JSONObject();
			item1.put("domain_id", "user_define");
			item1.put("title", uq.getString(1));
			item1.put("concept_id", uq.getInt(2));
			item.add(item1);

		}
		stmt.close();
		conn.close();

		out.print(item);
	}
	


%>
