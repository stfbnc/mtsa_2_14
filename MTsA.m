%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/06/19
%%% MTsA (v 2.14)
%%% INPUT PARAMETERS:
%%% - file_name : path to file + file name
%%% - data_col : number of data column
%%% - Delta_t : sampling time
%%% - time_units : units of sampling time
%%%               - seconds
%%%               - minutes
%%%               - hours
%%%               - days
%%%               - weeks
%%%               - months
%%% - typeoffit : choice of fit for trend removal
%%%              - none
%%%              - linear
%%%              - 2nd order polynomial
%%%              - 5th order polynomial
%%%              - exponential
%%% - year_in : initial year of time series
%%% - year_fin : final year of time series
%%% - scale_min : smaller scale for DFA and MDFA
%%% - scale_MFDFA : scales for local hurst exponent
%%% USAGE:
%%% MTsA(file_name,data_col,Delta_t,time_units,typeoffit,year_in,year_fin,scale_min,scale_MFDFA)
%%% EXAMPLE:
%%% MTsA(''../file.txt'',2,7,''days'',''linear'',1900,2000,10,5)

function MTsA(file_name,data_col,Delta_t,time_units,typeoffit,year_in,year_fin,scale_min,scale_MFDFA)

clc
warning('off','all')
fprintf(1,'\n\n        MTsA (v 2.14)        \n\n');

%%% defining some variables
nan_limit = 28;
outlier_lim = 3;
ofac = 4;
rev_seg = 1;
ord = 1;

if ischar(file_name)
    if ~exist(file_name,'file')
	    fprintf(1,'File not found!\n')
	    return
    end

    %%% separate path and file name
    [path,file_name] = path_file_sep(file_name);
end

%%% checks on input variables
check_res = var_check(data_col,Delta_t,time_units,typeoffit,year_in,year_fin);
if check_res == 1
    return
end

%%% defining converter for time units
units_converter = t_converter(time_units);

if ischar(file_name)
    %%% main folder
    path_tot = main_folder(file_name,path,data_col);
    if path_tot == 0
        return
    end

    %%% read and load file
    pn = load_file(path,file_name,data_col);
else
    %%% variables for the analysis
    [pn,path_tot] = FromWorkspace(file_name,inputname(1),data_col);
    if path_tot == 0
        return
    end
end

%%% checks on NaNs
[pn,nan_percentage] = nan_check(pn);
if nan_percentage > nan_limit
    error('Too much missing data for an accurate analysis!\n')
end

%%% creates t_vector
t = t_vector(pn,Delta_t);

%%% time series trend and detrend
pn = trend_detrend(pn,t,typeoffit,path_tot);

%%% lomb spectrum and figure
[PNT,freq,pth] = lomb_scargle(pn,ofac,Delta_t,t,path_tot);

%%% filtering peaks
[pn,sig_to_noise] = peaks_filter(1,path_tot,PNT,freq,pth,units_converter,year_in,year_fin,t,Delta_t,pn,ofac);

%%% normalized residuals
pn_norm = residuals(pn,t,outlier_lim,path_tot);

%%% file with outliers
outliers(t,pn_norm,outlier_lim,path_tot);

%%% detrended fluctuations analysis
dfa_coeff = dfa(pn,scale_min,ord,rev_seg,path_tot);

%%% multifractal detrended fluctuations analysis
mdfa(dfa_coeff,pn,scale_min,3,rev_seg,path_tot);

%%% time dependent hurst coefficient
MFDFA2(pn,scale_MFDFA,1,path_tot);

%%% distribution of residuals with outliers
distributions_fit(pn,path_tot,'Outliers');

%%% distribution of residuals without outliers (put outliers to nan)
pos_out = find(pn_norm < -outlier_lim | pn_norm > outlier_lim);
pn(pos_out) = nan;
distributions_fit(pn,path_tot,'NoOutliers');

%%% resume
resume(sig_to_noise,dfa_coeff,path_tot);

fprintf(1,'\n\n        END OF THE ANALYSIS        \n\n');

end
