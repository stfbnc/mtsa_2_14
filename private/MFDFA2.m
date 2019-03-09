%%% modified Ihlen's MFDFA2 function
%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/23
%%% computes local hurst exponent
%%% INPUT PARAMETERS:
%%% - signal : time series
%%% - scale : time scale for algorithm computation
%%% - m : fit order
%%% - path_tot : path to the main folder
%%% USAGE:
%%% MFDFA2(signal,scale,m,path_tot)

function MFDFA2(signal,scale,m,path_tot)

nan_pos = find(isnan(signal));
X = zeros(1,length(signal));
for i = 1:length(signal)
	X(i) = nansum(signal(1:i));
end
X(nan_pos) = nan;
if size(X,2) == 1;
   X = X';
end

scmin = 4;
scmax = length(signal) / 5;
scale0 = scmin:scmax;

for ns = 1:length(scale0),
    segments(ns) = floor(length(X) / scale0(ns));
    for v = 1:segments(ns),
		Index0 = ((((v - 1) * scale0(ns)) + 1):(v * scale0(ns)));
		X_fit = X(Index0);
		if length(X_fit(isnan(X_fit))) / length(X_fit) <= 0.2
			C0 = polyfit(Index0(~isnan(X_fit)),X_fit(~isnan(X_fit)),m);
            %C0 = fit(Index0(~isnan(X_fit))',X_fit(~isnan(X_fit))','poly1','Robust','LAR');
			fit0 = polyval(C0,Index0);
            %fit0 = C0.p2 + C0.p1 * Index0;
			RMS0{ns}(v) = sqrt(nanmean((X_fit - fit0) .^ 2));
		else
			RMS0{ns}(v) = nan;
		end
    end
    Fq0(ns) = exp(0.5 * nanmean(log(RMS0{ns} .^ 2)));
end

halfmax = floor(max(scale) / 2);
Time_index = halfmax + 1:length(X) - halfmax;
for ns = 1:length(scale),
    halfseg = floor(scale(ns) / 2);
    for v = halfmax + 1:length(X) - halfmax;
        Index = v - halfseg:v + halfseg;
        X_fit = X(Index);
        if length(X_fit(isnan(X_fit))) / length(X_fit) <= 0.2
	        C = polyfit(Index(~isnan(X_fit)),X_fit(~isnan(X_fit)),m);
            %C = fit(Index(~isnan(X_fit))',X_fit(~isnan(X_fit))','poly1','Robust','LAR');
    	    fitt = polyval(C,Index);
            %fitt = C.p2 + C.p1 * Index;
    	    RMS{ns}(v) = sqrt(nanmean((X(Index) - fitt) .^ 2));
    	else
    		RMS{ns}(v) = nan;
    	end
    end
    F(ns) = exp(0.5 * nanmean(log(RMS{ns} .^ 2)));
end
C = polyfit(log(scale0),log(Fq0),1);
%C = fit(log(scale0),log(Fq0),'poly1','Robust','LAR');
Regfit = polyval(C,log(scale));
%Regfit = C.p2 + C.p1 * log(scale);
Hq0 = C(1);
%Hq0 = C.p1;
maxL = length(Time_index);
for ns = 1:length(scale);
	RMSt = RMS{ns}(Time_index);
	resRMS = Regfit(ns) - log(RMSt);
	logscale = log(maxL) - log(scale(ns));
    Ht(ns,:) = resRMS ./ logscale + Hq0;
end

Ht_plot = Ht(1,:);
path_file = sprintf('%s/Ht.txt',path_tot);
f = fopen(path_file,'w');
if f < 0
	error('Failed to open %s',path_file)
end
for i = 1:length(Ht_plot)
	fprintf(f,'%f\n',Ht_plot(i));
end
fclose(f);

end
