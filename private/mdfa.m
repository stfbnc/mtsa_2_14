%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/23
%%% multifractal detrended fluctuations analysis
%%% INPUT PARAMETERS:
%%% - H_mono : dfa coefficient
%%% - pn : time series
%%% - min_win : smaller window for algorithm computation
%%% - q_max : max order of q in algorithm computation
%%% - rev_seg : if 1, the algorithm is computed forward and backward, if 0 only forward
%%% - path_tot : path to the main folder
%%% USAGE:
%%% mdfa(H_mono,pn,min_win,q_max,rev_seg,path_tot)

function mdfa(H_mono,pn,min_win,q_max,rev_seg,path_tot)

if isrow(pn)
	pn = pn';
end
nan_pos = find(isnan(pn));
N = length(pn);
t = 1:N;
a_ave = nanmean(pn);
pn = pn - a_ave;
y = zeros(1,N);
for i = 1:N
	y(i) = nansum(pn(1:i));
end
y(nan_pos) = nan;
max_win = 5;
end_dfa = floor(N / max_win);
n = min_win:end_dfa;
s = n';
%q = linspace(-q_max,q_max,101);
q = [-3,-2,-1,0,1,2,3];

F = zeros(length(q),length(s));
for i = 1:length(s)
	N_s = floor(N / s(i));
	F_nu1 = zeros(N_s,1);
	if rev_seg == 1
		F_nu2 = zeros(N_s,1);
	end
	for v = 1:N_s
		start_lim = (v - 1) * s(i) + 1;
		end_lim = v * s(i);
		t_fit = t(start_lim:end_lim);
		y_fit = y(start_lim:end_lim);
		if length(y_fit(isnan(y_fit))) / length(y_fit) <= 0.2
			n_fit = polyfit(t_fit(~isnan(y_fit)),y_fit(~isnan(y_fit)),1);
			%n_fit = fit(t_fit(~isnan(y_fit))',y_fit(~isnan(y_fit))','poly1','Robust','LAR');
			F_nu1(v) = nansum((y(start_lim:end_lim) - n_fit(2) - n_fit(1) * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
			%F_nu1(v) = nansum((y(start_lim:end_lim) - n_fit.p2 - n_fit.p1 * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
		else
			F_nu1(v) = nan;
		end
	end
	if rev_seg == 1
		for v = 1:N_s
			start_lim = (v - 1) * s(i) + 1 + (N - N_s * s(i));
			end_lim = v * s(i) + (N - N_s * s(i));
			t_fit = t(start_lim:end_lim);
			y_fit = y(start_lim:end_lim);
			if length(find(isnan(y_fit))) / length(y_fit) <= 0.2
				n_fit2 = polyfit(t_fit(~isnan(y_fit)),y_fit(~isnan(y_fit)),1);
				%n_fit2 = fit(t_fit(~isnan(y_fit))',y_fit(~isnan(y_fit))','poly1','Robust','LAR');
				F_nu2(v) = nansum((y(start_lim:end_lim) - n_fit2(2) - n_fit2(1) * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
				%F_nu2(v) = nansum((y(start_lim:end_lim) - n_fit2.p2 - n_fit2.p1 * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
			else
				F_nu2(v) = nan;
			end
		end
    	F_nu = [F_nu1;F_nu2];
    else
	    F_nu = F_nu1;
	end
	for k = 1:length(q)
        if q(k) == 0
        	if rev_seg == 1
	        	F(k,i) = exp(nansum(log(F_nu)) / (2 * length(F_nu(~isnan(F_nu)))));
        	else
				F(k,i) = exp(nansum(log(F_nu)) / (2 * length(F_nu(~isnan(F_nu)))));
			end
		else
			if rev_seg == 1
				F(k,i) = (nansum(F_nu .^ (q(k) / 2)) / length(F_nu(~isnan(F_nu)))) ^ (1 / q(k));
			else
				F(k,i) = (nansum(F_nu .^ (q(k) / 2)) / length(F_nu(~isnan(F_nu)))) ^ (1 / q(k));
			end
        end
	end
end

H = zeros(length(q),1);
H_err = zeros(length(q),1);
MDFA_fit = zeros(length(n),length(q));
for i = 1:length(q)
	%log_fit = fit(log(n'),log(F(i,:)'),'poly1','Robust','LAR');
    [log_fit,struct_fit] = polyfit(log(n),log(F(i,:)),1);
    MDFA_fit(:,i) = polyval(log_fit,log(n));
    %MDFA_fit(:,i) = log_fit.p2 + log_fit.p1 * log(n);
	H(i) = log_fit(1);
	%H(i) = log_fit.p1;
	sterr = sqrt(diag(inv(struct_fit.R) * inv(struct_fit.R')) .* (struct_fit.normr .^ 2) ./ struct_fit.df);
	H_err(i) = sterr(1);
	%H_conf = confint(log_fit,0.95);
    %H_err(i) = H(i) - H_conf(1,1);
end

tau = H .* q' - 1;
alpha = diff(tau) ./ (q(2) - q(1));
sing_spec = q(1:end - 1)' .* alpha - tau(1:end - 1);

path_file = sprintf('%s/mdfa1.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
	error('Failed to open %s',path_file)
end
for i = 1:length(n)
	fprintf(f,'%f %f %f %f %f %f %f\n',n(i),F(1,i),MDFA_fit(i,1),F(find(q == 0),i),MDFA_fit(i,find(q == 0)),F(end,i),MDFA_fit(i,end));
end
fclose(f);
path_file = sprintf('%s/mdfa2.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
	error('Failed to open %s',path_file)
end
for i = 1:length(q)
	fprintf(f,'%f %f %f %f %f\n',q(i),H(i),H_err(i),H_mono,tau(i));
end
fclose(f);
path_file = sprintf('%s/mdfa3.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
	error('Failed to open %s',path_file)
end
for i = 1:length(alpha)
	fprintf(f,'%f %f\n',alpha(i),sing_spec(i));
end
fclose(f);

end
