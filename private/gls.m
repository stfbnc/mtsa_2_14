%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2017/03/28
%%% generalised lomb spectrum
%%% INPUT PARAMETERS:
%%% - ts_vector : time series
%%% - t_vector : vector of times
%%% - frequencies : frequency vector
%%% OUTPUT PARAMETERS:
%%% - P : spectrum
%%% - frequencies : frequency vector
%%% USAGE:
%%% [P,frequencies] = gls(ts_vector,t_vector,frequencies)

function [P,frequencies] = gls(ts_vector,t_vector,frequencies)

ts_vector_not_nan = ts_vector(~isnan(ts_vector));
t_vector_not_nan = t_vector(~isnan(ts_vector));
N = length(ts_vector_not_nan);
err_vector_not_nan = ones(N,1);
if isrow(ts_vector_not_nan)
    ts_vector_not_nan = ts_vector_not_nan';
end
if isrow(t_vector_not_nan)
    t_vector_not_nan = t_vector_not_nan';
end

W = sum(1 ./ (err_vector_not_nan .^ 2));
w_err = 1 ./ (W * err_vector_not_nan .^ 2);
ts_vector_not_nan = ts_vector_not_nan - mean(ts_vector_not_nan);
sum_dev = sum(w_err .* (ts_vector_not_nan .^ 2));
P = zeros(length(frequencies),1);
for i = 1:length(frequencies)
    wt = 2 * pi * frequencies(i) * t_vector_not_nan;
    swt = sin(wt);
    cwt = cos(wt);
    Ss2wt = 2 * sum(w_err .* (cwt .* swt)) - 2 * sum(w_err .* cwt) * sum(w_err .* swt);
    Sc2wt = sum(w_err .* ((cwt - swt) .* (cwt + swt))) - sum(w_err .* cwt) ^ 2 + sum(w_err .* swt) ^ 2;
    wtau = 0.5 * atan2(Ss2wt,Sc2wt);
    swtau = sin(wtau);
    cwtau = cos(wtau);
    swttau = swt * cwtau - cwt * swtau;
    cwttau = cwt * cwtau + swt * swtau;
    P(i) = (sum(w_err .* (ts_vector_not_nan .* cwttau)) ^ 2) / (sum(w_err .* (cwttau .* cwttau)) - sum(w_err .* cwttau) ^ 2) + (sum(w_err .* (ts_vector_not_nan .* swttau)) ^ 2) / (sum(w_err .* (swttau .* swttau)) - sum(w_err .* swttau) ^ 2);
end
P = N * P / (2 * sum_dev);

if isrow(frequencies)
    frequencies = frequencies';
end

end
