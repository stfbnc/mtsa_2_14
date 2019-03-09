%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/19
%%% separate path and file name
%%% INPUT PARAMETERS:
%%% - file_name : full path to file
%%% OUTPUT PARAMETERS:
%%% - path : path to the file
%%% - file_name : file name
%%% USAGE:
%%% [path,file_name] = path_file_sep(file_name)

function [path,file_name] = path_file_sep(file_name)

slash = find(file_name == '/');
if isempty(slash)
    path = '.';
else
    path = file_name(1:(slash(end) - 1));
    file_name = file_name((slash(end) + 1):end);
end

end
