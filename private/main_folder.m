%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/05/11
%%% create main folder
%%% INPUT PARAMETERS:
%%% - file_name : file name
%%% - path : path to file
%%% - data_col : data column
%%% OUTPUT PARAMETERS:
%%% - path_tot : path to the main folder
%%% USAGE:
%%% path_tot = main_folder(file_name,path,data_col)

function path_tot = main_folder(file_name,path,data_col)

last_dot = find(file_name == '.');
last_dot = last_dot(end);
filename_noext = file_name(1:last_dot - 1);
folder_path = sprintf('%s/%s_col%d',path,filename_noext,data_col);
folder_name = sprintf('%s_col%d',filename_noext,data_col);
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

end
