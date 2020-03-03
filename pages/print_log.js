function print_log(event_name, addition_message=" "){
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == this.DONE && this.status == 200) {
            if(event_name == "login") location.href = "dashboard.html";
            else if(event_name == "logout") location.href = "login.jsp";
        }
    }
    xhttp.open("POST", "./print_log.jsp", true);
    xhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhttp.send("event_name=" + event_name + "&addition=" + addition_message);
}