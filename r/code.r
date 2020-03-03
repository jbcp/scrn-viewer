library(jsonlite)
Demographic <- fromJSON("http://192.1.170.220/scrn_ver_1.1.1//pages/r_data.jsp?action=demographic&project_id=1&eligibility_id=2")
# Example:
# 1. Click 'Check button' of 'Demographic' on the right to use it's data.
# 2. Input R code in this input box. 
#
#    str(Demographic)
#    summary(Demographic$day_of_birth)   # "Demographic$day_of_birth" is to select a variable of Demographic'day_of_birth 
#
# 3. Click 'Execute' button.


str(Demographic);
print('');
summary(Demographic$day_of_birth);
										