%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2017/03/28
%%% finds and filters peaks
%%% INPUT PARAMETERS:
%%% - max_iter : number of times the spectrum is computed and peaks filtered
%%% - path_tot : path to the main folder
%%% - PNT : spectrum
%%% - freq : frequency vector
%%% - pth : threshold for lomb spectrum
%%% - units_converter : number to convert time units and to obtain periods in units of time units
%%% - year_in : initial year
%%% - year_fin : final year
%%% - t : time vector
%%% - Delta_t : sampling time
%%% - ofac : oversampling factor
%%% OUTPUT PARAMETERS:
%%% - pn : time series without periodicities
%%% - sig_to_noise : percentage of periodicities
%%% USAGE:
%%% [pn,sig_to_noise] = peaks_filter(max_iter,path_tot,PNT,freq,pth,units_converter,year_in,year_fin,t,Delta_t,pn,ofac)

function [pn,sig_to_noise] = peaks_filter(max_iter,path_tot,PNT,freq,pth,units_converter,year_in,year_fin,t,Delta_t,pn,ofac)

%%% opening files
path_file = sprintf('%s/freq_peak_percentage.txt',path_tot);
f_peaks = fopen(path_file,'w');
if f_peaks < 0
	error('Failed to open %s',path_file)
end
fprintf(f_peaks,'%n_peak\tfreq\ttime\tpercentage\n');

fprintf(2,'\nn_peak     freq         time    percentage\n\n')

%%% initialising variables
nan_pos_pn = find(isnan(pn));
tot_spectrum = sum(PNT);
PNT_single = PNT;
freq_single = freq;
part_over_tot = 0.0;
iter_peaks = 0;
freq_fig = [];

%%% loop over filtered percentage
while iter_peaks < max_iter
	iter_peaks = iter_peaks + 1;

    %%% finding peaks
	pks = findpeaks(PNT_single);
	if PNT_single(2) < PNT_single(1)
		pks(end + 1) = PNT_single(1);
	end
	if PNT_single(end - 1) < PNT_single(end)
		pks(end + 1) = PNT_single(end);
	end
	num_peaks = length(pks(pks > pth));
	if num_peaks ~= 0
		ord = pks(pks > pth);
		for it_peak = 1:length(ord)
			for i = 1:length(PNT_single)
				if ord(it_peak) == PNT_single(i)
					locs_new = freq_single(i);
				end
			end
			j = find(freq_single == locs_new);
			if j == 1
				interval(it_peak,1) = freq_single(1);
				x1 = 1;
				for k = (j + 1):1:length(freq_single)
					if PNT_single(k) > PNT_single(k - 1)
						interval(it_peak,2) = freq_single(k - 1);
						x2 = k - 1;
						break
					else
						interval(it_peak,2) = freq_single(end);
						x2 = length(freq_single);
					end
				end
			elseif j == length(freq_single)
				for k = (j - 1):-1:1
					if PNT_single(k) > PNT_single(k + 1)
						interval(it_peak,1) = freq_single(k + 1);
						x1 = k + 1;
						break
					else
						interval(it_peak,1) = freq_single(1);
						x1 = 1;
					end
				end
				interval(it_peak,2) = freq_single(end) + (freq_single(end) - interval(it_peak,1)) + freq_single(1);
				x2 = length(freq_single);
			else
				for k = (j - 1):-1:1
					if PNT_single(k) > PNT_single(k + 1)
						interval(it_peak,1) = freq_single(k + 1);
						x1 = k + 1;
						break
					else
						interval(it_peak,1) = freq_single(1);
						x1 = 1;
					end
				end
				for k = (j + 1):1:length(freq_single)
					if PNT_single(k) > PNT_single(k - 1)
						interval(it_peak,2) = freq_single(k - 1);
						x2 = k - 1;
						break
					else
						interval(it_peak,2) = freq_single(end);
						x2 = length(freq_single);
					end
				end
			end
		
			ratio = (sum(PNT(x1:x2)) / tot_spectrum) * 100;
			part_over_tot = part_over_tot + ratio;
			PNT(x1:x2) = 0.0;

			if (1 / locs_new) > (units_converter * (year_fin - year_in + 1))
				freq_fig(end + 1) = units_converter * (year_fin - year_in + 1);
				if iter_peaks > 1
                    %%% ends if repeated peak
					if freq_fig(end) == freq_fig(end - 1)
						break
					end
				end
				fprintf(f_peaks,'%2d\t%9.8f\t%9.4f\t%5.2f\n',iter_peaks,(1 / (units_converter * (year_fin - year_in + 1))),units_converter * (year_fin - year_in + 1),ratio);
				fprintf(1,'   %2d     %9.8f   %9.4f     %5.2f\n',iter_peaks,(1 / (units_converter * (year_fin - year_in + 1))),units_converter * (year_fin - year_in + 1),ratio)
			else
				freq_fig(end + 1) = (1 / locs_new);
				if iter_peaks > 1
					if freq_fig(end) == freq_fig(end - 1)
						break
					end
				end
				fprintf(f_peaks,'\t%2d\t%9.8f\t%9.4f\t%5.2f\n',iter_peaks,locs_new,(1 / locs_new),ratio);
				fprintf(1,'   %2d     %9.8f   %9.4f     %5.2f\n',iter_peaks,locs_new,(1 / locs_new),ratio)
			end
		end
%%% filtering
		it_filt = 0;
%%% filtering from the new time series
		while it_filt <= 10
			it_filt = it_filt + 1;
			t(nan_pos_pn) = (nan_pos_pn - 1) * Delta_t + 1;
			ts = timeseries(pn,t);
			m = mean(ts);
			dataContent = ts.data;
			nandata = isnan(dataContent(:,1));
			if any(nandata(:))
				tuniform = linspace(t(1),t(end),length(t));
				ts = ts.resample(tuniform);
			end
			Ts = ts.TimeInfo.Increment;
			ts = ts.detrend('constant',1);
			data = ts.Data;
			sz = size(data);
			idata = fft(data,ofac * sz(1));
    		if rem(length(pn) * ofac,2)
    			fdata = [0 freq_single' fliplr(freq_single')];
    		else
   				fdata = [0 freq_single' floor(0.5 * length(pn) * ofac)/(length(pn) * Delta_t * ofac) fliplr(freq_single')];
   			end
   			I = false(size(fdata));
   			for i_int = 1:size(interval,1)
   				I = I | (fdata >= min(interval(i_int,:)) & fdata <= max(interval(i_int,:)));
			end
			idata(I,:) = 0;
			pn = real(ifft(idata));
			pn = pn + m;
			pn = pn(1:length(pn) / ofac);
			pn(nan_pos_pn) = nan;
			t(nan_pos_pn) = nan;
		end
	else
		break
	end
		
end

fclose(f_peaks);

if part_over_tot ~= 0
	sig_to_noise = part_over_tot;
else
	ratio = 0;
	freq_fig = 0;
	sig_to_noise = 0.0;
end

end
