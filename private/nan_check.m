%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/23
%%% check on number of nans
%%% INPUT PARAMETERS:
%%% - pn : time series
%%% OUTPUT PARAMETERS:
%%% - pn : time series
%%% - nan_percentage : percentage of missing data
%%% USAGE:
%%% [pn,nan_percentage] = nan_check(pn)

function [pn,nan_percentage] = nan_check(pn)

not_nan_pos = find(~isnan(pn));
if not_nan_pos(end) ~= length(pn)
    pn = pn(1:not_nan_pos(end));
end
if not_nan_pos(1) ~= 1
    pn = pn(not_nan_pos(1):end);
end
nan_percentage = (length(pn(isnan(pn))) / length(pn)) * 100;

end
