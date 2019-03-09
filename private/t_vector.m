%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/05/11
%%% creates t vector
%%% INPUT PARAMETERS:
%%% - pn : time series
%%% - Delta_t : sampling time
%%% OUTPUT PARAMETERS:
%%% - t : time vector
%%% USAGE:
%%% t = t_vector(pn,Delta_t)

function t = t_vector(pn,Delta_t)

t_fin = (length(pn) - 1) * Delta_t + 1;
t = 1:Delta_t:t_fin;
nan_pos_pn = find(isnan(pn));
t(nan_pos_pn) = nan;

end
