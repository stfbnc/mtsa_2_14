%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/06/19
%%% checks input variables
%%% INPUT PARAMETERS:
%%% - data_col : data column
%%% - Delta_t : sampling time
%%% - time_units : time units
%%% - typeoffit : type of fit
%%% - year_in : initial year
%%% - year_fin : final year
%%% OUTPUT PARAMETERS:
%%% - return_check : check for correct input parameters (0 if ok, 1 otherwise)
%%% USAGE:
%%% return_check = var_check(data_col,Delta_t,time_units,typeoffit,year_in,year_fin)

function return_check = var_check(data_col,Delta_t,time_units,typeoffit,year_in,year_fin)

return_check = 0;
if data_col <= 0
    fprintf(1,'Data column must be a positive number!\n')
    return_check = 1;
end
if Delta_t <= 0
    fprintf(1,'Sampling time must be grater than zero!\n')
    return_check = 1;
end
time_units_check = {'seconds','minutes','hours','days','weeks','months'};
if ~ismember(time_units,time_units_check)
    fprintf(1,'Not supported time units!\n')
    return_check = 1;
end
typeoffit_check = {'exponential','linear','2nd order polynomial','5th order polynomial','10th order polynomial','none'};
if ~ismember(typeoffit,typeoffit_check)
    fprintf(1,'Not supported type of fit!\n')
    return_check = 1;
end
year_check = clock;
year_check = year_check(1);
if year_fin > year_check || year_fin <= year_in || year_fin <= 0 || year_in <= 0
    fprintf(1,'Invalid years!\n')
    return_check = 1;
end

end
