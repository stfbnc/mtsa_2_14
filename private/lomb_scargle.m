%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/05/06
%%% lomb spectrum and figure
%%% INPUT PARAMETERS:
%%% - pn : time series
%%% - ofac : oversampling factor
%%% - Delta_t : sampling time
%%% - t : time vector
%%% - path_tot : path to the main folder
%%% OUTPUT PARAMETERS:
%%% - PNT : spectrum
%%% - freq : frequency vector
%%% - pth : threshold for lomb spectrum
%%% USAGE:
%%% [PNT,freq,pth] = lomb_scargle(pn,ofac,Delta_t,t,path_tot)

function [PNT,freq,pth] = lomb_scargle(pn,ofac,Delta_t,t,path_tot)

if rem(length(pn) * ofac,2)
	freq = (1:floor(0.5 * length(pn) * ofac)) / (length(pn) * Delta_t * ofac);
else
	freq = (1:floor(0.5 * length(pn) * ofac) - 1) / (length(pn) * Delta_t * ofac);
end
[PNT,freq] = gls(pn,t,freq);
M_pth = 2.0 * length(freq) / ofac;
peak_prob = 0.95;
pth = (-log(1.0 - peak_prob ^ (1.0 / M_pth)));

if ischar(path_tot)
    path_file = sprintf('%s/spectrum_in.txt',path_tot);
    f = fopen(path_file,'w');
    if f < 0
	    error('Failed to open %s',path_file)
    end
    for i = 1:length(freq)
	    fprintf(f,'%f %f %f\n',freq(i),PNT(i),pth);
    end
    fclose(f);
end

end
