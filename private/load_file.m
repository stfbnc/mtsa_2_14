%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/25
%%% read and load file
%%% INPUT PARAMETERS:
%%% - path : path to file
%%% - file_name : file name
%%% - data_col : data column
%%% OUTPUT PARAMETERS:
%%% - pn : time series
%%% USAGE:
%%% pn = load_file(path,file_name,data_col)

function pn = load_file(path,file_name,data_col)

[filepath,name,ext] = fileparts(file_name);
if ext == '.mat'
    fprintf(2,'Please provide data vector instead of .mat file!\n');
elseif ismember(ext,['.xlsx','.xls'])
    pn = xlsread(file_name);
    pn = pn(:,data_col);
elseif ismember(ext,['.txt','.dat','.csv'])
    path_file = sprintf('%s/%s',path,file_name);
    fid = fopen(path_file,'r');
    if fid < 0
        error('Failed to open %s',path_file)
    end
    i = 1;
    while ~feof(fid)
        fid_lin = split(fgets(fid));
        pn(i) = fid_lin(data_col);
        i = i + 1;
    end
    fclose(fid);
    pn = str2double(pn);
else
    fprintf(2,'Not supported file extension!\n');
end
if isrow(pn)
    pn = pn';
end

end
