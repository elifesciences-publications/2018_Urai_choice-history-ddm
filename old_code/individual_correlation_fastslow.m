function alldat = individual_correlation_fastslow
% from the csv table, make an overview of repetition behaviour

% get a huge list with values for each participant
% can then work with this dataframe

close all; clc;
addpath(genpath('~/code/Tools'));

global mypath datasets datasetnames colors
cnt = 1;

% ============================================ %
% ONE LARGE PLOT WITH PANEL FOR EACH DATASET
% ============================================ %

doText = false;

close all;
for d = length(datasets):-1:1
    disp(datasets{d});
    
    results = readtable(sprintf('%s/summary/%s/allindividualresults.csv', mypath, datasets{d}));
    results = results(results.session == 0, :);
    allresults = struct(); alltitles = {};
    
    % ============================================ %
    % RECODE INTO HISTORY SHIFT POINT ESTIMATES
    % ============================================ %
    
    % use the stimcoding difference
    try
        results.z_prevresp = ...
            results.(['z_1__stimcodingdczprevresp']) - results.(['z_2__stimcodingdczprevresp']);
        results.v_prevresp = ...
            results.(['dc_1__stimcodingdczprevresp']) - results.(['dc_2__stimcodingdczprevresp']);
    catch
        results.z_prevresp = ...
            results.(['z_1_0__stimcodingdczprevresp']) - results.(['z_2_0__stimcodingdczprevresp']);
        results.v_prevresp = ...
            results.(['dc_1_0__stimcodingdczprevresp']) - results.(['dc_2_0__stimcodingdczprevresp']);
    end
    
    set2 =  cbrewer('qual', 'Set2', 10);
    pastel2 =  cbrewer('qual', 'Pastel2', 10);
    
    % assign to structure
    allresults(1).z_prevresp     = results.z_prevresp;
    allresults(1).v_prevresp     = results.v_prevresp;
    allresults(1).criterionshift = results.repetition_fastRT;
    allresults(1).title         = {datasetnames{d}{1}, 'Fast'};
    allresults(1).marker 			= 'o'; % yellow
    allresults(1).meancolor 		= set2(1, :);
    allresults(1).scattercolor	 	= pastel2(1, :);
    
    % also after error choices
    allresults(2).z_prevresp     = results.z_prevresp;
    allresults(2).v_prevresp     = results.v_prevresp;
    allresults(2).criterionshift = results.repetition_slowRT;
    allresults(2).title             = {datasetnames{d}{1}, 'Slow'};
    allresults(2).marker         = 's';
    allresults(2).meancolor 		= set2(2, :); % orange
    allresults(2).scattercolor	 	= pastel2(2, :);
    
    disp(datasets{d}); disp(numel(unique(results.subjnr)));
    close all;
    
    % PLOT
    sp1 = subplot(4,4,1); hold on;
    [rho1, tt1] = plotScatter(allresults, 'z_prevresp', 0.585, doText);
    ylabel('P(repeat)');
    
    sp2 = subplot(4,4,2); hold on;
    [rho2, tt2, handles] = plotScatter(allresults, 'v_prevresp', 0.05, doText);
    set(gca, 'yticklabel', []);
    
    set(sp2, 'ylim', get(sp1, 'ylim'), 'ytick', get(sp1, 'ytick'));
    
    % compute the difference in correlation
    [rho3, pval3] = corr(cat(1, allresults(:).v_prevresp), cat(1, allresults(:).z_prevresp), ...
        'rows', 'complete', 'type', 'spearman');
    if pval3 < 0.05,
        fprintf('warning %s: rho = %.3f, pval = %.3f \n', datasets{d}, rho3, pval3);
    end
    [rhodiff, ~, pval] = rddiffci(rho1,rho2,rho3,numel(~isnan( cat(1, allresults(:).criterionshift))), 0.05);
    
    % move together
    sp2.Position(1) = sp2.Position(1) - 0.08;
    ss = suplabel(cat(2, datasetnames{d}{1}, ' ', datasetnames{d}{2}), 't');
    set(ss, 'fontweight', 'normal');
    ss.FontWeight = 'normal';
    ss.Position(2) = ss.Position(2) - 0.03;
    
    % add colored axes after suplabel (which makes them black)
    xlabel(sp1, 'History shift in z');
    set(sp1, 'xcolor', colors(1, :));
    xlabel(sp2, 'History shift in v_{bias}');
    set(sp2, 'xcolor', colors(2, :));
    
    if doText,
        %% add line between the two correlation coefficients
        txt = {sprintf('\\Delta\\rho(%d) = %.3f, p = %.3f', length(find(~isnan(cat(1, allresults(:).criterionshift) )))-3, rhodiff, pval)};
        if pval < 0.001,
            txt = {sprintf('\\Delta\\rho(%d) = %.3f, p < 0.001', length(find(~isnan(cat(1, allresults(:).criterionshift) )))-3,  rhodiff)};
        end
        title(txt, 'fontweight', 'normal', 'fontsize', 8, 'horizontalalignment', 'left');
    end
    
    tightfig;
    print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/figure1c_HDDM_modelfree_fastslow_d%d.pdf', d));
    
    for a = 1:length(allresults),
        
        % % SAVE CORRELATIONS FOR OVERVIEW PLOT
        % [r,p,rlo,rup] = corrcoef(allresults(a).z_prevresp, allresults(a).criterionshift);
        % alldat(cnt).corrz = r(1,2);
        % alldat(cnt).corrz_ci = [rlo(1,2) rup(1,2)];
        % alldat(cnt).pz = p(1,2);
        % alldat(cnt).bfz = corrbf(r(1,2), numel(allresults(a).z_prevresp));
        
        % [r,p,rlo,rup] = corrcoef(allresults(a).v_prevresp, allresults(a).criterionshift);
        % alldat(cnt).corrv = r(1,2);
        % alldat(cnt).corrv_ci = [rlo(1,2) rup(1,2)];
        % alldat(cnt).pv = p(1,2);
        % alldat(cnt).bfv = corrbf(r(1,2), numel(allresults(a).v_prevresp));
        
        
        % SAVE CORRELATIONS FOR OVERVIEW PLOT
        % COMPUTE THE SPEARMANS CORRELATION AND ITS CONFIDENCE INTERVAL!
        [alldat(cnt).corrz, alldat(cnt).corrz_ci, alldat(cnt).pz, alldat(cnt).bfz] = ...
            spearmans(allresults(a).z_prevresp, allresults(a).criterionshift);
        
        [alldat(cnt).corrv, alldat(cnt).corrv_ci, alldat(cnt).pv, alldat(cnt).bfv] = ...
            spearmans(allresults(a).v_prevresp, allresults(a).criterionshift);
        
        alldat(cnt).datasets = datasets{d};
        alldat(cnt).datasetnames = datasetnames{d};
        % alldat(cnt).datasetnames = allresults(a).title;
        
        % also add the difference in r, Steigers test
        [r,p,rlo,rup] = corrcoef(allresults(a).v_prevresp, allresults(a).z_prevresp);
        
        [rhodiff, rhodiffci, pval] = rddiffci(alldat(cnt).corrz,alldat(cnt).corrv, ...
            r(1,2), ...
            numel(allresults(a).v_prevresp), 0.05);
        
        alldat(cnt).corrdiff = rhodiff;
        alldat(cnt).corrdiff_ci = rhodiffci;
        alldat(cnt).pdiff = pval;
        alldat(cnt).nsubj  = numel(allresults(a).criterionshift);
        
        
        alldat(cnt).marker          = allresults(a).marker;
        alldat(cnt).scattercolor    = allresults(a).scattercolor;
        alldat(cnt).meancolor       = allresults(a).meancolor;
        
        cnt = cnt + 1;
    end
end

end
