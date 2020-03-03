<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%

    String role = (String)session.getAttribute("user_role");

    out.print(role);
%>