%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/23
%%% resume
%%% INPUT PARAMETERS:
%%% - sig_to_noise : percentage of periodicities
%%% - dfa_coeff : dfa coefficient
%%% - path_tot : path to the main folder
%%% USAGE:
%%% resume(sig_to_noise,dfa_coeff,path_tot)

function resume(sig_to_noise,dfa_coeff,path_tot)

f = fopen(sprintf('%s/distributions/distributions_fit_param_NoOutliers.txt',path_tot),'r');
dist_all = textscan(f,'%s %f %f %f %f %f %f %f %f %f %f','delimiter','\t','CollectOutput',true,'EmptyValue',NaN,'HeaderLines',1);
fclose(f);
path_file = sprintf('%s/resume.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
    error('Failed to open %s',path_file)
end
fprintf(f,'harmonic percentage                    -> %.2f%%\n',sig_to_noise);
fprintf(f,'residuals percentage                   -> %.2f%%\n',100 - sig_to_noise);
fprintf(f,'\n------------------------------------------------\n\n');
fprintf(f,'DFA coefficient -> %.2f\n',dfa_coeff);
fprintf(f,'\n------------------------------------------------\n\n');
fprintf(f,'DISTRIBUTIONS    \t AD \t KS \n');
for i = 1:length(dist_all{1})
    if dist_all{2}(i,6) + dist_all{2}(i,8) == 0.0
        fprintf(f,'%-17s\t%.2f\t%.2f\n',char(dist_all{1}(i)),dist_all{2}(i,7),dist_all{2}(i,9));
    end
end
fclose(f);

end
