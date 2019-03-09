%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/05/06
%%% script for plots after the analysis
%%% INPUT PARAMETERS:
%%% - time : vector of times (0 if not available)
%%% - path_in : path where files for plots are located
%%% - path_out : path where to save figures
%%% - figs : cell array of strings for desired plots
%%%         - time series (time series and trend)
%%%         - spectrum (spectrum of detrended time series)
%%%         - log spectrum (spectrum of detrended time series)
%%%         - res (residuals)
%%%         - dfa (detrended fluctuations analysis)
%%%         - Ht (time dependent Hurst exponent)
%%%         - mdfa (multifractal detrended fluctuations analysis)
%%%         - distribution (histograms of distributions)
%%% - fig_format : format of figures
%%%               - epsc (for .eps)
%%%               - fig (for .fig)
%%%               - epsc-fig (for both .eps and .fig)
%%% USAGE:
%%% plots(time,path_in,path_out,figs,fig_format)

function plots(time,path_in,path_out,figs,fig_format)

fig_format_check={'fig','epsc','epsc-fig'};
if ~ismember(fig_format,fig_format_check)
    fprintf(1,'Not supported figure format!\n')
    return
end

time_label = time(1:ceil(length(time) * 7 / 100):length(time));
distributions = {'Burr' 'Exponential' 'Gamma' 'GeneralizedPareto' 'InverseGaussian' 'Lognormal' 'Poisson' 'Weibull' 'Rayleigh' 'Normal' 'tLocationScale'};
type_hist = {'Outliers' 'NoOutliers'};

for i = 1:length(figs)
    switch figs{i}
        case 'time series'
            ts_trend_plot();
        case 'spectrum'
            spectrum_plot();
        case 'log spectrum'
            log_spectrum_plot();
        case 'res'
            res_plot();
        case 'dfa'
            dfa_plot();
        case 'Ht'
            mfdfa2_plot();
        case 'mdfa'
            mdfa_plot();
        case 'distribution'
            distribution_plot();
        otherwise
            fprintf(2,'No available plot for %s\n',figs{i});
    end
end

%%%%% TIME SERIES PLOT %%%%%
function ts_trend_plot()
    path_file = sprintf('%s/pn_time.txt',path_in);
    mtx = load(path_file);
    detrended = mtx(:,2);
    try
        fit_curve = mtx(:,3);
        pn = detrended + fit_curve;
    catch
        fit_curve = nan(length(detrended),1);
        pn = nan(length(detrended),1);
    end

    figure_ts = figure('Visible','off');
    plot(pn)
    hold on
    plot(detrended,'r')
    plot(fit_curve,'k')
    if ~isscalar(time)
        set(gca,'XTick',1:ceil(length(time) * 7 / 100):length(time));
        set(gca,'XTickLabel',time_label);
        set(gca,'TickLabelInterpreter','latex');
        set(gca,'XTickLabelRotation',45);
    end
    xlim([1 length(pn)])
    ylabel('$$X_t$$','interpreter','latex')
    if isnan(pn)
        title('time series','interpreter','latex')
    else
        title('time series (original and detrended)','interpreter','latex')
        legend({'original','detrended','trend'},'Location','best','Interpreter','latex');
    end
    hold off
    file_title = sprintf('%s/ts_original_detrended',path_out);
    switch fig_format
        case 'epsc-fig'
            saveas(gcf,file_title,'epsc')
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
        case 'epsc'
            saveas(gcf,file_title,'epsc')
        case 'fig'
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
    end
    close(figure_ts)
end
%%%%%%%%%%

%%%%% SPECTRUM PLOT %%%%%
function spectrum_plot()
    path_file = sprintf('%s/spectrum_in.txt',path_in);
    mtx = load(path_file);
    freq = mtx(:,1);
    PNT = mtx(:,2);
    pth = mtx(1,3);

    figure_spectrumin = figure('Visible','off');
    plot(freq,PNT)
    hold on
    plot([freq(1) freq(end)],[pth pth],'r')
    xlim([freq(1) freq(end)])
    xlabel('$$\nu$$','Interpreter','latex')
    ylabel('$$P(\nu)$$','Interpreter','latex')
    title('lomb spectrum (initial)','Interpreter','latex')
    file_title = sprintf('%s/spectrum_in',path_out);
    switch fig_format
        case 'epsc-fig'
            saveas(gcf,file_title,'epsc')
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
        case 'epsc'
            saveas(gcf,file_title,'epsc')
        case 'fig'
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
    end
    close(figure_spectrumin)
end
%%%%%%%%%%

%%%%% LOG SPECTRUM PLOT %%%%%
function log_spectrum_plot()
    path_file = sprintf('%s/spectrum_in.txt',path_in);
    mtx = load(path_file);
    freq = mtx(:,1);
    PNT = mtx(:,2);
    pth = mtx(1,3);

    figure_logspectrumin = figure('Visible','off');
    loglog(freq,PNT)
    hold on
    plot([freq(1) freq(end)],[pth pth],'r')
    xlim([freq(1) freq(end)])
    xlabel('$$\nu$$','Interpreter','latex')
    ylabel('$$P(\nu)$$','Interpreter','latex')
    title('log lomb spectrum (initial)','Interpreter','latex')
    file_title = sprintf('%s/spectrum_in_log',path_out);
    switch fig_format
        case 'epsc-fig'
            saveas(gcf,file_title,'epsc')
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
        case 'epsc'
            saveas(gcf,file_title,'epsc')
        case 'fig'
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
    end
    close(figure_logspectrumin)
end
%%%%%%%%%%

%%%%% RESIDUALS PLOT %%%%%
function res_plot()
    path_file = sprintf('%s/res.txt',path_in);
    mtx = load(path_file);
    pn = mtx(:,2);
    pn_norm = mtx(:,3);
    outlier_lim = mtx(1,4);

    res_fig = figure('Visible','off');
    subplot(2,1,1)
    plot(pn)
    xlim([1 length(pn)])
    if ~isscalar(time)
        set(gca,'XTick',1:ceil(length(time) * 7 / 100):length(time))
        set(gca,'XTickLabel',time_label)
        set(gca,'TickLabelInterpreter','latex')
        set(gca,'XTickLabelRotation',45)
    end
    title('residuals','interpreter','latex')
    subplot(2,1,2)
    bar(pn_norm)
    hold on
    plot([1 length(pn_norm)],[-outlier_lim -outlier_lim],'r')
    plot([1 length(pn_norm)],[outlier_lim outlier_lim],'r')
    xlim([1 length(pn_norm)])
    if ~isscalar(time)
        set(gca,'XTick',1:ceil(length(time) * 7 / 100):length(time))
        set(gca,'XTickLabel',time_label)
        set(gca,'TickLabelInterpreter','latex')
        set(gca,'XTickLabelRotation',45)
    end
    title('normalised residuals','interpreter','latex')
    hold off
    file_title=sprintf('%s/res',path_out);
    switch fig_format
        case 'epsc-fig'
            saveas(gcf,file_title,'epsc')
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
        case 'epsc'
            saveas(gcf,file_title,'epsc')
        case 'fig'
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
    end
    close(res_fig)
end
%%%%%%%%%%

%%%%% DFA PLOT %%%%%
function dfa_plot()
    path_file = sprintf('%s/dfa.txt',path_in);
    mtx = load(path_file);
    n = mtx(:,1);
    F = mtx(:,2);
    DFA_fit = mtx(:,3);
    H_mono = mtx(1,4);
    H_err = mtx(1,5);

    figure_DFA = figure('Visible','off');
    plot(log(n),log(F),'.','markersize',20)
    hold on
    plot(log(n),DFA_fit)
    xlim([log(n(1)) log(n(end))])
    ylabel('log(F(n))','interpreter','latex')
    xlabel('log(n)','interpreter','latex')
    title('DFA fit','interpreter','latex')
    legend({sprintf('\\alpha = %.2f, %.2f',H_mono,H_err)},'FontSize',12,'Location','best');
    hold off
    file_title = sprintf('%s/dfa',path_out);
    switch fig_format
        case 'epsc-fig'
            saveas(gcf,file_title,'epsc')
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
        case 'epsc'
            saveas(gcf,file_title,'epsc')
        case 'fig'
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
    end
    close(figure_DFA)
end
%%%%%%%%%%

%%%%% MFDFA2 PLOT %%%%%
function mfdfa2_plot()
    path_file = sprintf('%s/Ht.txt',path_in);
    mtx = load(path_file);
    Ht_plot = mtx(:,1);

    figure_MFDFA2 = figure('Visible','off');
    plot(Ht_plot,'y')
    set(gcf,'color',[0 0 0])
    hold on
    plot(0.5 * ones(length(Ht_plot),1),'w')
    plot(ones(length(Ht_plot),1),'m')
    plot(1.5 * ones(length(Ht_plot),1),'r')
    xlim([1 length(Ht_plot)])
    xlabel('time')
    ylim([0 3])
    ylabel('$$H_t$$','interpreter','latex')
    title('local Hurst exponent')
    set(gca,'color','black')
    set(gcf,'color','white')
    set(gcf,'inverthardcopy','off')
    file_title = sprintf('%s/MFDFA2',path_out);
    switch fig_format
        case 'epsc-fig'
            saveas(gcf,file_title,'epsc')
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
        case 'epsc'
            saveas(gcf,file_title,'epsc')
        case 'fig'
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
    end
    close(figure_MFDFA2)
end
%%%%%%%%%%

%%%%% MDFA PLOT %%%%%
function mdfa_plot()
    path_file = sprintf('%s/mdfa1.txt',path_in);
    mtx = load(path_file);
    n = mtx(:,1);
    F1 = mtx(:,2);
    MDFA_fit1 = mtx(:,3);
    F2 = mtx(:,4);
    MDFA_fit2 = mtx(:,5);
    F3 = mtx(:,6);
    MDFA_fit3 = mtx(:,7);
    path_file = sprintf('%s/mdfa2.txt',path_in);
    mtx = load(path_file);
    q = mtx(:,1);
    H = mtx(:,2);
    H_err= mtx(:,3);
    H_mono = mtx(:,4);
    path_file = sprintf('%s/mdfa3.txt',path_in);
    mtx = load(path_file);
    alpha = mtx(:,1);
    sing_spec = mtx(:,2);

    figure_MDFA = figure('Visible','off');
    subplot(2,2,1)
    plot(log(n),log(F1),'b.')
    hold on
    plot(log(n),MDFA_fit1,'b')
    plot(log(n),log(F2),'r.')
    plot(log(n),MDFA_fit2,'r')
    plot(log(n),log(F3),'g.')
    plot(log(n),MDFA_fit3,'g')
    xlim([log(n(1)) log(n(end))])
    xlabel('log(n)','interpreter','latex')
    ylabel('log(F(n))','interpreter','latex')
    title('MDFA fit','interpreter','latex')
    legend({'q=-3','','q=0','','q=3',''},'Location','best','interpreter','latex')
    hold off
    subplot(2,2,2)
    errorbar(q,H,H_err,'.-')
    hold on
    plot([q(1) q(end)],[H_mono H_mono],'k')
    xlim([q(1) q(end)])
    xlabel('q','interpreter','latex')
    ylabel('h(q)','interpreter','latex')
    title('Generalised Hurst exponent','interpreter','latex')
    legend({'h(q)','H'},'Location','best','interpreter','latex')
    hold off
    subplot(2,2,3)
    plot(alpha,sing_spec,'.-')
    xlabel('$$\alpha$$','interpreter','latex')
    ylabel('f($$\alpha$$)','interpreter','latex')
    ylim([min(sing_spec) - 0.2 1.2])
    title('Singularity spectrum','interpreter','latex')
    file_title = sprintf('%s/mdfa',path_out);
    switch fig_format
        case 'epsc-fig'
            saveas(gcf,file_title,'epsc')
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
        case 'epsc'
            saveas(gcf,file_title,'epsc')
        case 'fig'
            set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
            savefig(file_title)
    end
    close(figure_MDFA)
end
%%%%%%%%%%

%%%%% DISTRIBUTION PLOT %%%%%
function distribution_plot()
    for i = 1:length(distributions)
        for j = 1:length(type_hist)
            try
                path_file = sprintf('%s/distributions/%s_hist_res_%s.txt',path_in,distributions{i},type_hist{j});
                mtx = load(path_file);
                bins = mtx(:,1);
                values = mtx(:,2);
                pdf_values = mtx(:,3);

                figure_hist = figure('Visible','off');
                stairs(bins,values)
                hold on
                plot(bins,pdf_values,'LineWidth',2)
                xlabel('$$N_t$$','interpreter','latex')
                ylabel('$$H(N_t)$$','interpreter','latex')
                title({sprintf('Fitted distribution: %s',distributions{i})},'interpreter','latex')
                file_title = sprintf('%s/distributions/%s_hist_res_%s',path_out,distributions{i},type_hist{j});
                switch fig_format
                    case 'epsc-fig'
                        saveas(gcf,file_title,'epsc')
                        set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
                        savefig(file_title)
                    case 'epsc'
                        saveas(gcf,file_title,'epsc')
                    case 'fig'
                        set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
                        savefig(file_title)
                end
                close(figure_hist)
            catch
            end
        end
    end
end
%%%%%%%%%%

end
