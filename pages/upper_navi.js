
function upper_navi_1(top){
    var navi_item1 = document.createElement("a");
    navi_item1.setAttribute("href", "#");
    navi_item1.setAttribute("style", "font-size:20px");
    navi_item1.appendChild(document.createTextNode(top));
    document.getElementById("upper_navi").appendChild(navi_item1);
}

function upper_navi_2(top, project_id){
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == this.DONE && this.status == 200) {
            var project_title = xhttp.responseText.trim();

            var navi_item1 = document.createElement("a");

            switch (top) {
                case "Projects":
                    navi_item1.setAttribute("href", 'projects.html');
                break;

                case "User define set":
                    navi_item1.setAttribute("href", 'user_define.html');
                break;

                default:
                    navi_item1.setAttribute("href", "projects.html");
                break;
            }

            navi_item1.setAttribute("style", "font-size:20px");
            navi_item1.appendChild(document.createTextNode(top));
            document.getElementById("upper_navi").appendChild(navi_item1);
            
            var slash_item = document.createElement("a");
            slash_item.setAttribute("style", "font-size:20px");
            slash_item.appendChild(document.createTextNode("/"));
            document.getElementById("upper_navi").appendChild(slash_item);
            
            var navi_item2 = document.createElement("a");
            switch (top) {
                case "Projects":
                    navi_item2.setAttribute("href", 'project_detail.html');
                break;

                case "User define set":
                    navi_item2.setAttribute("href", 'user_define_detail.html');
                break;

                default:
                    navi_item2.setAttribute("href", "projects.html");
                break;
            }
            navi_item2.setAttribute("style", "font-size:20px");
            navi_item2.appendChild(document.createTextNode(project_title));
            document.getElementById("upper_navi").appendChild(navi_item2);
        
        }
    }
    xhttp.open("GET", "./upper_navi_fill.jsp?action=load2&table="+top+"&project_id=" + project_id);
    xhttp.send();

}

function upper_navi_3(top, project_id, eligibility_id){
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == this.DONE && this.status == 200) {

            var title_input = xhttp.responseText.trim();
            var title_array = title_input.split("&");
            var project_title = title_array[0];
            var eligibility_title = title_array[1];
            var navi_item1 = document.createElement("a");
            navi_item1.setAttribute("href", "projects.html");
            navi_item1.setAttribute("style", "font-size:20px");
            navi_item1.appendChild(document.createTextNode(top));
            document.getElementById("upper_navi").appendChild(navi_item1);
            
            var slash_item = document.createElement("a");
            slash_item.setAttribute("style", "font-size:20px");
            slash_item.appendChild(document.createTextNode("/"));
            document.getElementById("upper_navi").appendChild(slash_item);
            
            var navi_item2 = document.createElement("a");

            switch (top) {
                case "Projects":
                    navi_item2.setAttribute("href", 'project_detail.html');
                break;
            
                default:
                    navi_item2.setAttribute("href", "projects.html");
                break;
            }

            navi_item2.setAttribute("style", "font-size:20px");
            navi_item2.appendChild(document.createTextNode(project_title));
            document.getElementById("upper_navi").appendChild(navi_item2);

            var slash_item2 = document.createElement("a");
            slash_item2.setAttribute("style", "font-size:20px");
            slash_item2.appendChild(document.createTextNode("/"));
            document.getElementById("upper_navi").appendChild(slash_item2);
            
            var navi_item3 = document.createElement("a");

            switch (top) {
                case "Projects":
                    navi_item3.setAttribute("href", 'eligibility_detail.html');
                break;
            
                default:
                    navi_item3.setAttribute("href", "projects.html");
                break;
            }

            navi_item3.setAttribute("style", "font-size:20px");
            navi_item3.appendChild(document.createTextNode(eligibility_title));
            document.getElementById("upper_navi").appendChild(navi_item3);

 

        }
    }
    xhttp.open("GET", "./upper_navi_fill.jsp?action=load3&table="+top+"&project_id=" + project_id + "&eligibility_id="+eligibility_id);
    xhttp.send();

}

function upper_navi_4(project_id, eligibility_id){
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == this.DONE && this.status == 200) {

            var title_input = xhttp.responseText.trim();
            var title_array = title_input.split("&");
            var project_title = title_array[0];
            var eligibility_title = title_array[1];
            
            var h1_title = document.createElement("label");

            h1_title.setAttribute("style", "font-weight:bold; font-size: 25px;");
            h1_title.appendChild(document.createTextNode(project_title));

            var h3_title = document.createElement("label");
            h3_title.setAttribute("style", "font-size: 20px; color:rgb(55, 158, 163)");
            h3_title.appendChild(document.createTextNode(eligibility_title));
            document.getElementById("project_title").appendChild(h1_title);
            document.getElementById("project_title").appendChild(document.createElement("br"));
            document.getElementById("project_title").appendChild(h3_title);

          
        }
    }
    xhttp.open("GET", "./upper_navi_fill.jsp?action=load3&project_id=" + project_id + "&eligibility_id="+eligibility_id);
    xhttp.send();

}