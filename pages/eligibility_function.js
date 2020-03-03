function full_modal_init(table){

    if(table == "measurement"){
        
        newj("#no-check").prop("checked", true);
        document.getElementById("no-check").setAttribute("checked","");
        document.getElementById("duration_button_3_b").setAttribute("disabled", "");
        document.getElementById("duration_button_6_b").setAttribute("disabled", "");
        document.getElementById("duration_button_9_b").setAttribute("disabled", "");
        document.getElementById("duration_button_12_b").setAttribute("disabled", "");
        document.getElementById("duration_button_self_b").setAttribute("disabled", "");
        document.getElementById("duration_button_3").setAttribute("disabled", "");
        document.getElementById("duration_button_6").setAttribute("disabled", "");
        document.getElementById("duration_button_9").setAttribute("disabled", "");
        document.getElementById("duration_button_12").setAttribute("disabled", "");
        document.getElementById("duration_button_self").setAttribute("disabled", "");

        newj("#no-check-value").prop("checked", true);
        document.getElementById("no-check-value").setAttribute("checked","");
        document.getElementById("duration_modal").setAttribute("disabled", "");
        document.getElementById("duration_modal").value = "";
        document.getElementById("value_min").setAttribute("disabled", "");
        document.getElementById("value_max").setAttribute("disabled", "");
        document.getElementById("value_min_condition").setAttribute("disabled", "");
        document.getElementById("value_max_condition").setAttribute("disabled", "");
        document.getElementById("value_min").value = "";
        document.getElementById("value_min_condition").value = "";
        document.getElementById("value_max").value = "";
        document.getElementById("value_max_condition").value = "";
    
        newj("#no-check-measure").prop("checked", true);
        document.getElementById("no-check-measure").setAttribute("checked","");
        document.getElementById("measure_count").setAttribute("disabled", "");
        document.getElementById("measure_calc").setAttribute("disabled", "");
        document.getElementById("measure_count").value = "";
        document.getElementById("measure_calc").value = "";    
    }
    
    else if(table == "age"){
        newj('#no-check-age').prop("checked", true);
        document.getElementById("no-check-age").setAttribute("checked","");
        document.getElementById("age_min").setAttribute("disabled", "");
        document.getElementById("age_max").setAttribute("disabled", "");
        document.getElementById("age_min_condition").setAttribute("disabled", "");
        document.getElementById("age_max_condition").setAttribute("disabled", "");
        document.getElementById("age_min").value = "";
        document.getElementById("age_min_condition").value = "";
        document.getElementById("age_max").value = "";
        document.getElementById("age_max_condition").value = "";

    }

    else if(table == "sql"){
        document.getElementById("sqlcode").value = "";
    }

    else{
        newj("#check-all").prop("checked", true);

        newj("#no-check-mini").prop("checked", true);
        document.getElementById("no-check-mini").setAttribute("checked","");
        document.getElementById("duration_button_3_mini").setAttribute("disabled", "");
        document.getElementById("duration_button_6_mini").setAttribute("disabled", "");
        document.getElementById("duration_button_9_mini").setAttribute("disabled", "");
        document.getElementById("duration_button_12_mini").setAttribute("disabled", "");
        document.getElementById("duration_button_self_mini").setAttribute("disabled", "");
        document.getElementById("duration_button_3_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_button_6_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_button_9_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_button_12_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_button_self_mini_b").setAttribute("disabled", "");

        document.getElementById("duration_modal_mini").setAttribute("disabled", "");
        document.getElementById("duration_modal_mini").value = "";
    }
}

function full_modal_init_ex(table){

    if(table == "measurement"){
        
        newj("#no-check-ex").prop("checked", true);
        document.getElementById("duration_ex_button_3_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_6_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_9_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_12_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_self_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_3").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_6").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_9").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_12").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_self").setAttribute("disabled", "");
    
        newj("#no-check-value-ex").prop("checked", true);
        document.getElementById("duration_modal_ex").setAttribute("disabled", "");
        document.getElementById("duration_modal_ex").value = "";
        document.getElementById("value_min_ex").setAttribute("disabled", "");
        document.getElementById("value_max_ex").setAttribute("disabled", "");
        document.getElementById("value_min_condition_ex").setAttribute("disabled", "");
        document.getElementById("value_max_condition_ex").setAttribute("disabled", "");
        document.getElementById("value_min_ex").value = "";
        document.getElementById("value_min_condition_ex").value = "";
        document.getElementById("value_max_ex").value = "";
        document.getElementById("value_max_condition_ex").value = "";

    
        newj("#no-check-measure-ex").prop("checked", true);
        document.getElementById("measure_count_ex").setAttribute("disabled", "");
        document.getElementById("measure_calc_ex").setAttribute("disabled", "");
        document.getElementById("measure_count_ex").value = "";
        document.getElementById("measure_calc_ex").value = "";    
    }
    
    else if(table == "age"){
        newj('#no-check-age-ex').prop("checked", true);
        document.getElementById("age_min_ex").setAttribute("disabled", "");
        document.getElementById("age_max_ex").setAttribute("disabled", "");
        document.getElementById("age_min_condition_ex").setAttribute("disabled", "");
        document.getElementById("age_max_condition_ex").setAttribute("disabled", "");
        document.getElementById("age_min_ex").value = "";
        document.getElementById("age_min_condition_ex").value = "";
        document.getElementById("age_max_ex").value = "";
        document.getElementById("age_max_condition_ex").value = "";

    }

    else if(table == "sql"){
        document.getElementById("sqlcodeex").value = "";
    }

    else{

        newj("#check-ex-all").prop("checked", true);

        newj("#no-check-mini-ex").prop("checked", true);
        document.getElementById("duration_ex_button_3_mini").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_6_mini").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_9_mini").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_12_mini").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_self_mini").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_3_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_6_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_9_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_12_mini_b").setAttribute("disabled", "");
        document.getElementById("duration_ex_button_self_mini_b").setAttribute("disabled", "");

        document.getElementById("duration_modal_ex_mini").setAttribute("disabled", "");
        document.getElementById("duration_modal_ex_mini").value = "";
    }
}