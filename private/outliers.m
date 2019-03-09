%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/23
%%% find outliers in normalised residuals
%%% INPUT PARAMETERS:
%%% - t : time vector
%%% - pn_norm : normalised time series
%%% - outlier_lim : threshold for outliers identification
%%% - path_tot : path to the main folder
%%% USAGE:
%%% outliers(t,pn_norm,outlier_lim,path_tot)

function outliers(t,pn_norm,outlier_lim,path_tot)

path_file = sprintf('%s/outliers.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
    error('Failed to open %s',path_file)
end
for i = 1:length(t)
    if pn_norm(i) < -outlier_lim || pn_norm(i) > outlier_lim
        fprintf(f,'%5d\t%7.3f\n',t(i),pn_norm(i));
    end
end
fclose(f);

end
