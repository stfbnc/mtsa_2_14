%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2017/03/28
%%% time series trend, detrend and figure
%%% INPUT PARAMETERS:
%%% - pn : time series
%%% - t : time vector
%%% - typeoffit : type of fit
%%% - path_tot : path to the main folder
%%% OUTPUT PARAMETERS:
%%% - pn : detrended time series
%%% USAGE:
%%% pn = trend_detrend(pn,t,typeoffit,path_tot)

function pn = trend_detrend(pn,t,typeoffit,path_tot)

x_fit = t(~isnan(t));
[x_fit_row,x_fit_col] = size(x_fit);
if x_fit_row == 1
	x_fit = x_fit';
end
y_fit = pn(~isnan(pn));
[y_fit_row,y_fit_col] = size(y_fit);
if y_fit_row == 1
	y_fit = y_fit';
end
switch typeoffit
	case 'exponential'
		fit_curve = fit(x_fit,y_fit,'exp1','Robust','LAR','Display','off');
		pn = pn - (fit_curve.a * exp(fit_curve.b * t'));
	case 'linear'
		fit_curve = polyfit(x_fit,y_fit,1);
		fit_curve = polyval(fit_curve,t');
		pn = pn - fit_curve;
	case '5th order polynomial'
		fit_curve = polyfit(x_fit,y_fit,5);
		fit_curve = polyval(fit_curve,t');
		pn = pn - fit_curve;
	case '2nd order polynomial'
		fit_curve = polyfit(x_fit,y_fit,2);
		fit_curve = polyval(fit_curve,t');
		pn = pn - fit_curve;
	case '10th order polynomial'
		fit_curve = polyfit(x_fit,y_fit,10);
		fit_curve = polyval(fit_curve,t');
		pn = pn - fit_curve;
end
path_file = sprintf('%s/pn_time.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
	error('Failed to open %s',path_file)
end
for i = 1:length(t)
	switch typeoffit
		case 'exponential'
			fprintf(f,'%.30f %.30f %.30f\n',t(i),pn(i),fit_curve.a * exp(fit_curve.b * t(i)));
		case 'none'
			fprintf(f,'%.30f %.30f\n',t(i),pn(i));
		otherwise
			fprintf(f,'%.30f %.30f %.30f\n',t(i),pn(i),fit_curve(i));
	end
end
fclose(f);

end
