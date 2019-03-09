%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/07/03
%%% detrended fluctuations analysis
%%% INPUT PARAMETERS:
%%% - pn : time series
%%% - min_win : smaller window for algorithm computation
%%% - ord : polynomial fit order
%%% - rev_seg : if 1, the algorithm is computed forward and backward, if 0 only forward
%%% - path_tot : path to the main folder
%%% OUTPUT PARAMETERS:
%%% - H_mono : dfa coefficient
%%% USAGE:
%%% H_mono = dfa(pn,min_win,ord,rev_seg,path_tot)

function H_mono = dfa(pn,min_win,ord,rev_seg,path_tot)

if isrow(pn)
	pn = pn';
end
nan_pos = find(isnan(pn));
N = length(pn);
t = 1:N;
a_ave = nanmean(pn);
pn = pn-a_ave;
y = zeros(1,N);
for i = 1:N
	y(i) = nansum(pn(1:i));
end
y(nan_pos) = nan;
max_win = 5;
end_dfa = floor(N / max_win);
n = min_win:end_dfa;
s = n';

F = zeros(1,length(s));
for i = 1:length(s)
	N_s = floor(N / s(i));
	F_nu1 = zeros(N_s,1);
	if rev_seg == 1
		F_nu2 = zeros(N_s,1);
	end
	for v = 1:N_s
		start_lim = (v-1) * s(i) + 1;
		end_lim = v * s(i);
		t_fit = t(start_lim:end_lim);
		y_fit = y(start_lim:end_lim);
		if length(y_fit(isnan(y_fit))) / length(y_fit) <= 0.2
			n_fit = polyfit(t_fit(~isnan(y_fit)),y_fit(~isnan(y_fit)),ord);
			%n_fit = fit(t_fit(~isnan(y_fit))',y_fit(~isnan(y_fit))',sprintf('poly%d',ord),'Robust','LAR');
			F_nu1(v) = nansum((y(start_lim:end_lim) - n_fit(2) - n_fit(1) * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
			%F_nu1(v) = nansum((y(start_lim:end_lim) - n_fit.p2 - n_fit.p1 * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
		else
			F_nu1(v) = nan;
		end
	end
	if rev_seg == 1
		for v = 1:N_s
			start_lim = (v-1) * s(i) + 1 + (N - N_s * s(i));
			end_lim = v * s(i) + (N - N_s * s(i));
			t_fit = t(start_lim:end_lim);
			y_fit = y(start_lim:end_lim);
			if length(find(isnan(y_fit))) / length(y_fit) <= 0.2
				n_fit2 = polyfit(t_fit(~isnan(y_fit)),y_fit(~isnan(y_fit)),ord);
				%n_fit2 = fit(t_fit(~isnan(y_fit))',y_fit(~isnan(y_fit))',sprintf('poly%d',ord),'Robust','LAR');
				F_nu2(v) = nansum((y(start_lim:end_lim) - n_fit2(2) - n_fit2(1) * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
				%F_nu2(v) = nansum((y(start_lim:end_lim) - n_fit2.p2 - n_fit2.p1 * t(start_lim:end_lim)) .^ 2) / length(y_fit(~isnan(y_fit)));
			else
				F_nu2(v) = nan;
			end
		end
		F_nu = [F_nu1;F_nu2];
		F(i) = sqrt(nansum(F_nu) / length(F_nu(~isnan(F_nu))));
	else
		F_nu = F_nu1;
		F(i) = sqrt(nansum(F_nu) / length(F_nu(~isnan(F_nu))));
	end
end

[log_fit,struct_fit] = polyfit(log(n),log(F),1);
%log_fit = fit(log(n'),log(F'),'poly1','Robust','LAR');
DFA_fit = polyval(log_fit,log(n));
%DFA_fit = log_fit.p2 + log_fit.p1 * log(n);
H_mono = log_fit(1);
%H_mono = log_fit.p1;
%H_err = confint(log_fit,0.95);
%H_err = H_mono - H_err(1,1);
sterr = sqrt(diag(inv(struct_fit.R) * inv(struct_fit.R')) .* (struct_fit.normr .^2) ./ struct_fit.df);
H_err = sterr(1);

path_file = sprintf('%s/dfa.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
	error('Failed to open %s',path_file)
end
for i = 1:length(n)
	fprintf(f,'%.30f %.30f %.30f %.10f %.10f\n',n(i),F(i),DFA_fit(i),H_mono,H_err);
end
fclose(f);

end
