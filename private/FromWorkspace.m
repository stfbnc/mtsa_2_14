%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/05/18
%%% read variables from workspace rather than from file
%%% INPUT PARAMETERS:
%%% - file_name : matrix or vector with data
%%% - var_name : name of the analysed variable
%%% - data_col : data column
%%% OUTPUT PARAMETERS:
%%% - pn : time series
%%% - path_tot : path to the main folder
%%% USAGE:
%%% [pn,path_tot] = FromWorkspace(file_name,var_name,data_col)

function [pn,path_tot] = FromWorkspace(file_name,var_name,data_col)

path = '.';
folder_path = sprintf('%s/%s_col%d_emd',path,var_name,data_col);
folder_name = sprintf('%s_col%d_emd',var_name,data_col);
if ~exist(folder_path,'dir')
    mkdir(path,folder_name);
    path_tot = folder_path;
else
    overwrite = input('You already analyzed this time series or another\ntime series in the same file. Continue? [Y/n]   ','s');
    if overwrite == 'Y'
        rmdir(folder_path,'s');
        mkdir(path,folder_name);
        path_tot = folder_path;
    else
        path_tot = 0;
    end
end

if isrow(file_name)
    file_name = file_name';
end
pn = file_name(:,data_col);

end
