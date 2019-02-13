function barplots_modelcomparison_regression()

% Code to fit the history-dependent drift diffusion models described in
% Urai AE, Gee JW de, Donner TH (2018) Choice history biases subsequent evidence accumulation. bioRxiv:251595
%
% MIT License
% Copyright (c) Anne Urai, 2018
% anne.urai@gmail.com

addpath(genpath('~/code/Tools'));
warning off; close all;
global datasets datasetnames mypath colors

modelIC = {'aic'};
for s = 1:length(modelIC),
    
    % ============================================ %
    % DIC COMPARISON BETWEEN DC, Z AND BOTH
    % ============================================ %
    
    % 1. STIMCODING, only prevresps
    mdls = {'regress_nohist', ...
        'regress_z_lag1', ...
        'regress_dc_lag1', ...
        'regress_dcz_lag1', ...
        'regress_z_lag2', ...
        'regress_dc_lag2', ...
        'regress_dcz_lag2', ...
        'regress_z_lag3', ...
        'regress_dc_lag3', ...
        'regress_dcz_lag3', ...
        'regress_z_lag4', ...
        'regress_dc_lag4', ...
        'regress_dcz_lag4', ...
        'regress_z_lag5', ...
        'regress_dc_lag5', ...
        'regress_dcz_lag5', ...
        'regress_z_lag6', ...
        'regress_dc_lag6', ...
        'regress_dcz_lag6'};

    numlags = 6;
    lagnames = {'1', '2', '3', '4', '5', '6'};

    for d = 1:length(datasets),
        close all;
        subplot(4, 4, 1);
        getPlotModelIC(mdls, modelIC{s}, d, colors);
        title(datasetnames{d});
        set(gca, 'xtick', 2:3:length(mdls), 'xticklabel', lagnames);
        xlabel('Lags (# trials)')

		switch modelIC{s}
        case 'dic_original'
        	ylabel({'\Delta DIC from model'; 'without history'}, 'interpreter', 'tex');
        case 'bic'
            ylabel({'\Delta BIC from model'; 'without history'}, 'interpreter', 'tex');
        case 'aic'
            ylabel({'\Delta AIC from model'; 'without history'}, 'interpreter', 'tex');
        end

        drawnow; tightfig;
        print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/modelcomparison_regression_%s_d%d.pdf', modelIC{s}, d));
    end
end

close all;

end

% ============================================ %
% DIC COMPARISON BETWEEN DC, Z AND BOTH
% ============================================ %

function getPlotModelIC(mdls, s, d, colors)

global datasets mypath 
colors(3, :) = mean(colors([1 2], :));
axis square; hold on;

mdldic = nan(1, length(mdls));
for m = 1:length(mdls),
    try
    modelcomp = readtable(sprintf('%s/%s/%s/model_comparison.csv', ...
        mypath, datasets{d}, mdls{m}), 'readrownames', true);
    mdldic(m) = modelcomp.(s);
catch
    fprintf('%s/%s/%s/model_comparison.csv  NOT FOUND\n', ...
        mypath, datasets{d}, mdls{m})
    end
end

% everything relative to the full model
mdldic = bsxfun(@minus, mdldic, mdldic(1));
mdldic = mdldic(2:end);
mdls = mdls(2:end);
[~, bestMdl] = min(mdldic);

for i = 1:length(mdldic),

    % move together in clusters of 3
    if contains(mdls{i}, '_z_'),
        xpos = i+0.2;
        thiscolor = colors(1, :);
    elseif contains(mdls{i}, '_dc_'),
        xpos = i;
        thiscolor = colors(2, :);

    elseif contains(mdls{i}, '_dcz_'), 
        xpos = i-0.2;
        thiscolor = colors(3, :);

    end

    % best fit with outline
    if i == bestMdl,
        b = bar(xpos, mdldic(i), 'facecolor', thiscolor, 'barwidth', 0.8, 'BaseValue', 0, ...
        'edgecolor', 'k');
    else
        b = bar(xpos, mdldic(i), 'facecolor', thiscolor, 'barwidth', 0.8, 'BaseValue', 0, ...
        'edgecolor', 'none');
    end
end

axis square; axis tight; 
xlim([0.5 length(mdldic)+0.5]);
offsetAxes; box off;
set(gca, 'color', 'none');
set(gca, 'xcolor', 'k', 'ycolor', 'k');

end
