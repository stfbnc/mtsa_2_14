%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/23
%%% residuals and figure
%%% INPUT PARAMETERS:
%%% - pn : time series
%%% - t : time vector
%%% - outlier_lim : threshold for outliers identification
%%% - path_tot : path to the main folder
%%% - OUTPUT PARAMETERS:
%%% - pn_norm : normalised time series
%%% USAGE:
%%% pn_norm = residuals(pn,t,outlier_lim,path_tot)

function pn_norm = residuals(pn,t,outlier_lim,path_tot)

m_res = nanmean(pn);
s_res = nanstd(pn,1);
pn_norm = (pn - m_res) / s_res;
num_outliers = length(pn_norm(pn_norm < -outlier_lim | pn_norm > outlier_lim));
path_file = sprintf('%s/res.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
    error('Failed to open %s',path_file)
end
for i = 1:length(pn_norm)
    fprintf(f,'%.30f %.30f %.30f %.2f\n',t(i),pn(i),pn_norm(i),outlier_lim);
end
fclose(f);

end
