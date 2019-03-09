%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/24
%%% distribution of residuals
%%% INPUT PARAMETERS:
%%% - pn : time series
%%% - path_tot : path to the main folder
%%% - type_hist : 'Outliers' for time series with outliers, 'NoOutliers' for time series without outliers
%%% USAGE:
%%% distributions_fit(pn,path_tot,type_hist)

function distributions_fit(pn,path_tot,type_hist)

path_tot = sprintf('%s/distributions',path_tot);
if ~exist(path_tot,'dir')
    mkdir(path_tot);
end

if ~any(pn < 0)
	f_hist = fopen(sprintf('%s/distributions_fit_param_%s.txt',path_tot,type_hist),'w');
	fprintf(f_hist,'Distribution     \tfit_param1\tfit_param2\tfit_param3\tmu\tsigma\ttest_ad\tp_ad\ttest_ks\tp_ks\tshift\n');
	distributions = {'Burr' 'Exponential' 'Gamma' 'GeneralizedPareto' 'InverseGaussian' 'Lognormal' 'Poisson' 'Weibull' 'Rayleigh' 'Normal' 'tLocationScale'};
	for i = 1:length(distributions)
		param_matrix = nan(length(distributions),5);
		test_value = nan;
		p_value = nan;
		test_value2 = nan;
		p_value2 = nan;
		try
			pdf_fit = fitdist(pn,distributions{i});
			param_matrix(i,4) = mean(pdf_fit);
			param_matrix(i,5) = sqrt(var(pdf_fit));
			switch distributions{i}
				case 'Burr'
					param_matrix(i,1) = pdf_fit.alpha;
					param_matrix(i,2) = pdf_fit.c;
					param_matrix(i,3) = pdf_fit.k;
				case 'Exponential'
					param_matrix(i,1) = pdf_fit.mu;
				case 'Gamma'
					param_matrix(i,1) = pdf_fit.a;
					param_matrix(i,2) = pdf_fit.b;
				case 'GeneralizedPareto'
					param_matrix(i,1) = pdf_fit.k;
					param_matrix(i,2) = pdf_fit.sigma;
					param_matrix(i,3) = pdf_fit.theta;
				case 'InverseGaussian'
					param_matrix(i,1) = pdf_fit.mu;
					param_matrix(i,2) = pdf_fit.lambda;
				case 'Lognormal'
					param_matrix(i,1) = pdf_fit.mu;
					param_matrix(i,2) = pdf_fit.sigma;
				case 'Poisson'
					param_matrix(i,1) = pdf_fit.lambda;
				case 'Weibull'
					param_matrix(i,1) = pdf_fit.a;
					param_matrix(i,2) = pdf_fit.b;
				case 'Rayleigh'
					param_matrix(i,1) = pdf_fit.b;
				case 'Normal'
					param_matrix(i,1) = pdf_fit.mu;
					param_matrix(i,2) = pdf_fit.sigma;
				case 'tLocationScale'
					param_matrix(i,1) = pdf_fit.mu;
					param_matrix(i,2) = pdf_fit.sigma;
					param_matrix(i,3) = pdf_fit.nu;
			end
            figure_histo = figure('Visible','off');
			histo = histogram(pn,'BinMethod','fd','Normalization','pdf','DisplayStyle','stairs');
			pdf_values = pdf(pdf_fit,histo.BinEdges);
            file_hist = fopen(sprintf('%s/%s_hist_res_%s.txt',path_tot,distributions{i},type_hist),'w');
            for i_file = 1:length(histo.Values)
                fprintf(file_hist,'%f %f %f\n',histo.BinEdges(i_file),histo.Values(i_file),pdf_values(i_file));
            end
            fclose(file_hist);
            close(figure_histo);
			try
				[test_value,p_value] = adtest(pn,'Distribution',pdf_fit);
			catch
			end
			try
				[test_value2,p_value2] = kstest(pn,'CDF',pdf_fit);
			catch
			end
		catch
		end
		fprintf(f_hist,'%-17s\t%-9.2f\t%-9.2f\t%-9.2f\t%-5.2f\t%-5.2f\t%-6d\t%4.2f\t%-6d\t%4.2f\n',distributions{i},param_matrix(i,1),param_matrix(i,2),...
		param_matrix(i,3),param_matrix(i,4),param_matrix(i,5),test_value,p_value,test_value2,p_value2);
	end
	fclose(f_hist);
else
	f_hist = fopen(sprintf('%s/distributions_fit_param_%s.txt',path_tot,type_hist),'w');
	fprintf(f_hist,'Distribution     \tfit_param1\tfit_param2\tfit_param3\tmu\tsigma\ttest_ad\tp_ad\ttest_ks\tp_ks\tshift\n');
	distributions_neg = {'Normal' 'tLocationScale'};
	distributions_pos = {'Burr' 'Exponential' 'Gamma' 'GeneralizedPareto' 'InverseGaussian' 'Lognormal' 'Poisson' 'Weibull' 'Rayleigh'};
	pn2 = pn - 2 * floor(min(pn));
	for i = 1:length(distributions_pos)
		param_matrix = nan(length(distributions_neg) + length(distributions_pos),5);
		test_value = nan;
		p_value = nan;
		test_value2 = nan;
		p_value2 = nan;
		try
			pdf_fit = fitdist(pn2,distributions_pos{i});
			param_matrix(i,4) = mean(pdf_fit);
			param_matrix(i,5) = sqrt(var(pdf_fit));
			switch distributions_pos{i}
				case 'Burr'
					param_matrix(i,1) = pdf_fit.alpha;
					param_matrix(i,2) = pdf_fit.c;
					param_matrix(i,3) = pdf_fit.k;
				case 'Exponential'
					param_matrix(i,1) = pdf_fit.mu;
				case 'Gamma'
					param_matrix(i,1) = pdf_fit.a;
					param_matrix(i,2) = pdf_fit.b;
				case 'GeneralizedPareto'
					param_matrix(i,1) = pdf_fit.k;
					param_matrix(i,2) = pdf_fit.sigma;
					param_matrix(i,3) = pdf_fit.theta;
				case 'InverseGaussian'
					param_matrix(i,1) = pdf_fit.mu;
					param_matrix(i,2) = pdf_fit.lambda;
				case 'Lognormal'
					param_matrix(i,1) = pdf_fit.mu;
					param_matrix(i,2) = pdf_fit.sigma;
				case 'Poisson'
					param_matrix(i,1) = pdf_fit.lambda;
				case 'Weibull'
					param_matrix(i,1) = pdf_fit.a;
					param_matrix(i,2) = pdf_fit.b;
				case 'Rayleigh'
					param_matrix(i,1) = pdf_fit.b;
			end
            figure_histo = figure('Visible','off');
			histo = histogram(pn2,'BinMethod','fd','Normalization','pdf','DisplayStyle','stairs');
			pdf_values = pdf(pdf_fit,histo.BinEdges);
            file_hist = fopen(sprintf('%s/%s_hist_res_%s.txt',path_tot,distributions_pos{i},type_hist),'w');
            for i_file = 1:length(histo.Values)
                fprintf(file_hist,'%f %f %f\n',histo.BinEdges(i_file),histo.Values(i_file),pdf_values(i_file));
            end
            fclose(file_hist);
            close(figure_histo);
			try
				[test_value,p_value] = adtest(pn2,'Distribution',pdf_fit);
			catch
			end
			try
				[test_value2,p_value2] = kstest(pn2,'CDF',pdf_fit);
			catch
			end
		catch
		end
		fprintf(f_hist,'%-17s\t%-9.2f\t%-9.2f\t%-9.2f\t%-5.2f\t%-5.2f\t%-6d\t%4.2f\t%-6d\t%4.2f\t%-5d\n',distributions_pos{i},param_matrix(i,1),...
		param_matrix(i,2),param_matrix(i,3),param_matrix(i,4),param_matrix(i,5),test_value,p_value,test_value2,p_value2,-2*floor(min(pn)));
	end
	for i = 1:length(distributions_neg)
		param_matrix = nan(length(distributions_neg)+length(distributions_pos),5);
		test_value = nan;
		p_value = nan;
		test_value2 = nan;
		p_value2 = nan;
		try
			pdf_fit = fitdist(pn,distributions_neg{i});
			param_matrix(length(distributions_pos) + i,4) = mean(pdf_fit);
			param_matrix(length(distributions_pos) + i,5) = sqrt(var(pdf_fit));
			switch distributions_neg{i}
				case 'Normal'
					param_matrix(length(distributions_pos) + i,1) = pdf_fit.mu;
					param_matrix(length(distributions_pos) + i,2) = pdf_fit.sigma;
				case 'tLocationScale'
					param_matrix(length(distributions_pos) + i,1) = pdf_fit.mu;
					param_matrix(length(distributions_pos) + i,2) = pdf_fit.sigma;
					param_matrix(length(distributions_pos) + i,3) = pdf_fit.nu;
			end
            figure_histo = figure('Visible','off');
			histo = histogram(pn,'BinMethod','fd','Normalization','pdf','DisplayStyle','stairs');
			pdf_values = pdf(pdf_fit,histo.BinEdges);
            file_hist = fopen(sprintf('%s/%s_hist_res_%s.txt',path_tot,distributions_neg{i},type_hist),'w');
            for i_file = 1:length(histo.Values)
                fprintf(file_hist,'%f %f %f\n',histo.BinEdges(i_file),histo.Values(i_file),pdf_values(i_file));
            end
            fclose(file_hist);
            close(figure_histo);
			try
				[test_value,p_value] = adtest(pn,'Distribution',pdf_fit);
			catch
			end
			try
				[test_value2,p_value2] = kstest(pn,'CDF',pdf_fit);
			catch
			end
		catch
		end
		fprintf(f_hist,'%-17s\t%-9.2f\t%-9.2f\t%-9.2f\t%-5.2f\t%-5.2f\t%-6d\t%4.2f\t%-6d\t%4.2f\tNaN  \n',distributions_neg{i},param_matrix(length(distributions_pos) + i,1),...
		param_matrix(length(distributions_pos) + i,2),param_matrix(length(distributions_pos) + i,3),param_matrix(length(distributions_pos) + i,4),...
		param_matrix(length(distributions_pos) + i,5),test_value,p_value,test_value2,p_value2);
	end
	fclose(f_hist);
end

end
