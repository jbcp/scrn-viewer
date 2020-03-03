<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.oreilly.servlet.*" %>

<%
    String uploadPath = request.getRealPath("/upload");
    int maxSize = 1024 * 1024 * 10; 

    String name = "";
    String subject = "";

    String fileName1 = ""; 
    String originalName1 = "";
    long fileSize = 0; 
    String fileType = ""; 
    MultipartRequest multi = null;

    try{
        multi = new MultipartRequest(request,uploadPath,maxSize,"utf-8");
        name = "user_"+(Integer)session.getAttribute("user_id");
        subject = "photo_"+(Integer)session.getAttribute("user_id");
        Enumeration files = multi.getFileNames();

        while(files.hasMoreElements()){
            String file1 = (String)files.nextElement();
            originalName1 = multi.getOriginalFileName(file1);
            fileName1 = multi.getFilesystemName(file1); 
            fileType = multi.getContentType(file1);

            File file = multi.getFile(file1);
            fileSize = file.length();
        }

	 	
		String fileName = originalName1;
		String now = "photo_"+(Integer)session.getAttribute("user_id");
		int i = -1;
		i = fileName.lastIndexOf("."); 
		String realFileName = now + fileName.substring(i, fileName.length()); 
		
		File oldFile = new File(uploadPath +"/"+ fileName);
		File newFile = new File(uploadPath +"/"+ realFileName); 
		
        boolean success = oldFile.renameTo(newFile);
        if ( !success ) {
            newFile.delete();
			oldFile.renameTo(newFile);
        }

		out.println(uploadPath +"/"+ realFileName);
	
    }catch(Exception e){

        e.printStackTrace();

    }
%>


