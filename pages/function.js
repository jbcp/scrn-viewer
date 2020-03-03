function duration_button_set(condition, option){
    if(option == "set"){
        document.getElementById("duration_"+coniditon+"_button_3").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_6").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_9").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_12").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_24").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_self").setAttribute("disabled","");    
    }
    else if(option == "remove"){
        document.getElementById("duration_"+coniditon+"_button_3").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_6").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_9").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_12").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_24").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_self").removeAttribute("disabled");    
    }
}

function duration_button_mini_set(condition, option){
    if(option == "set"){
        document.getElementById("duration_"+coniditon+"_button_3_mini").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_6_mini").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_9_mini").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_12_mini").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_24_mini").setAttribute("disabled","");
        document.getElementById("duration_"+condition+"_button_self_mini").setAttribute("disabled","");    
    }
    else if(option == "remove"){
        document.getElementById("duration_"+coniditon+"_button_3_mini").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_6_mini").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_9_mini").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_12_mini").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_24_mini").removeAttribute("disabled");
        document.getElementById("duration_"+condition+"_button_self_mini").removeAttribute("disabled");    
    }
}

function value_set(condition, option){
    if(option=="set"){
        document.getElementById("value_min_"+condition).setAttribute("disabled","");
        document.getElementById("value_max_"+condition).setAttribute("disabled","");
        document.getElementById("value_min_condition_"+condition).setAttribute("disabled","");
        document.getElementById("value_max_condition_"+condition).setAttribute("disabled","");
    }
    else if(option=="remove"){
        document.getElementById("value_min_"+condition).removeAttribute("disabled");
        document.getElementById("value_max_"+condition).removeAttribute("disabled");
        document.getElementById("value_min_condition_"+condition).removeAttribute("disabled");
        document.getElementById("value_max_condition_"+condition).removeAttribute("disabled");
    }
}

function measure_set(condition, option){
    if(option=="set"){
        document.getElementById("measure_count_"+condition).setAttribute("disabled","");
        document.getElementById("measure_calc_"+condition).setAttribute("disabled","");
    }
    else if(option=="remove"){
        document.getElementById("measure_count_"+condition).removeAttribute("disabled");
        document.getElementById("measure_calc_"+coniditon).removeAttribute("disabled");
    }
}

function age_set(condition, option){
    if(option=="set"){
        document.getElementById("age_min_"+condition).setAttribute("disabled","");
        document.getElementById("age_max_"+condition).setAttribute("disabled","");
        document.getElementById("age_min_condition_"+condition).setAttribute("disabled","");
        document.getElementById("age_max_condition_"+condition).setAttribute("disabled","");
    }
    else if(option=="remove"){
        document.getElementById("age_min_"+condition).removeAttribute("disabled");
        document.getElementById("age_max_"+condition).removeAttribute("disabled");
        document.getElementById("age_min_condition_"+condition).removeAttribute("disabled");
        document.getElementById("age_max_condition_"+condition).removeAttribute("disabled");
    }
}

function enterkey(condition){
    if(window.event.keyCode == 13){
        if(condition == "in") itemmodal_in();
        else if(coniditon == "ex") itemmodal_ex();
    }
}
