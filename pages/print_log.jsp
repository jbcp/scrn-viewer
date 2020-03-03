<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.io.*"%>
 
<%

    DecimalFormat df = new DecimalFormat("00");
    Calendar calendar = Calendar.getInstance();

    String year = Integer.toString(calendar.get(Calendar.YEAR)); 
    String month = df.format(calendar.get(Calendar.MONTH) + 1); 
    String day = df.format(calendar.get(Calendar.DATE)); 
    String hour = df.format(calendar.get(Calendar.HOUR));
    String minute = df.format(calendar.get(Calendar.MINUTE));
    String second = df.format(calendar.get(Calendar.SECOND));

    String today = year+month+day;
    String now = today+hour+minute+second;

    String logpath = request.getRealPath("/log")+"/";
	
    String event_name = (String)request.getParameter("event_name");
    String addition = (String)request.getParameter("addition");
    String filename = "";
    String logcontent = "";

    if(event_name.equals("login")){
        filename = today+"_login.txt";
        logcontent = today+" "+hour+minute+second+" Login " + (String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("logout")){
        filename = today+"_login.txt";
        logcontent = today+" "+hour+minute+second+" Logout " + (String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("write_notice")){
        filename = today+"_dashboard.txt";
        logcontent = today+" "+hour+minute+second+" write_notice "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("delete_notice")){
        filename = today+"_dashboard.txt";
        logcontent = today+" "+hour+minute+second+" delete_notice "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("create_project")){
        filename = today+"_project.txt";
        logcontent = today+" "+hour+minute+second+" create_project "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("delete_project")){
        filename = today+"_project.txt";
        logcontent = today+" "+hour+minute+second+" delete_project "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("modify_project")){
        filename = today+"_project.txt";
        logcontent = today+" "+hour+minute+second+" modify_project "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("add_invest")){
        filename = today+"_project.txt";
        logcontent = today+" "+hour+minute+second+" add_invest "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("delete_invest")){
        filename = today+"_project.txt";
        logcontent = today+" "+hour+minute+second+" delete_invest "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("add_query")){
        filename = today+"_eligibility.txt";
        logcontent = today+" "+hour+minute+second+" add_query "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("delete_query")){
        filename = today+"_eligibility.txt";
        logcontent = today+" "+hour+minute+second+" delete_query "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("execute_query")){
        filename = today+"_eligibility.txt";
        logcontent = today+" "+hour+minute+second+" execute_query "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("modify_query")){
        filename = today+"_eligibility.txt";
        logcontent = today+" "+hour+minute+second+" modify_query "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("show_result")){
        filename = today+"_eligibility.txt";
        logcontent = today+" "+hour+minute+second+" show_result "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("create_ud")){
        filename = today+"_userdefine.txt";
        logcontent = today+" "+hour+minute+second+" create_ud "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("delete_ud")){
        filename = today+"_userdefine.txt";
        logcontent = today+" "+hour+minute+second+" delete_ud "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("modify_ud")){
        filename = today+"_userdefine.txt";
        logcontent = today+" "+hour+minute+second+" modify_ud "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("modify_account")){
        filename = today+"_account.txt";
        logcontent = today+" "+hour+minute+second+" modify_account " + (String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("add_member")){
        filename = today+"_admin.txt";
        logcontent = today+" "+hour+minute+second+" add_member "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }
    else if(event_name.equals("delete_member")){
        filename = today+"_admin.txt";
        logcontent = today+" "+hour+minute+second+" delete_member "+ addition + " "+(String)session.getAttribute("user_mail")+"\n";
    }

    logpath += filename;

    try{
        File logfile = new File(logpath);
        logfile.createNewFile();
        FileWriter lw = new FileWriter(logpath, true);
        lw.write(logcontent);
        lw.close();
    } catch(IOException e){
        out.println(e.toString());
    }

    if(event_name.equals("logout")) session.invalidate();
    
%>
