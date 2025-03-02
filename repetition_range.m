function repetition_range

% Code to fit the history-dependent drift diffusion models described in
% Urai AE, Gee JW de, Donner TH (2018) Choice history biases subsequent evidence accumulation. bioRxiv:251595
%
% MIT License
% Copyright (c) Anne Urai, 2018
% anne.urai@gmail.com

global mypath datasets datasetnames
addpath(genpath('~/code/Tools'));
warning off; close all;

cmap = viridis(256);
colormap(cmap);

markers = {'d', 's', '^', 'v',  '>', '<'};
colors = cbrewer('qual', 'Set2', length(datasets));

for d = 1:length(datasets),
    
    close all;
    subplot(4,4,1); hold on;
    dat = readtable(sprintf('%s/summary/%s/allindividualresults.csv', mypath, datasets{d}));
    dat = dat(dat.session == 0, :);
    if d == 5
        dat(dat.subjnr == 11, :) = [];
    end
    
    rep = sort(dat.repetition);
    b = barh(rep, 'facecolor', [0.5 0.5 0.5], 'basevalue', 0.5, 'edgecolor', 'none');
    plot([0.5 0.5],[0.5 numel(rep)+0.5],  'k');
    b(1).BaseLine.LineStyle = 'none';
    
    % ylabel(sprintf('%s, n = %d', datasetnames{d}{1}, numel(rep)));
    % show on x-axis what the mean is
    box off; xlim([0.4 0.65]); ylim([1 numel(rep)+0.5]);
    plot(mean(rep), 0, 'marker', markers{d}, 'markerfacecolor', ...
        'w', 'markeredgecolor', colors(d, :), 'markersize', 5);
    set(gca, 'ytick', [1 numel(rep)], 'xtick', [0.4 0.5 0.6]);
    
    ylabel('# Observers')   
    if d == length(datasets),
        xlabel('P(repeat)');
    else
        set(gca, 'xticklabel', []);
    end
    try; offsetAxes; end % sometimes throws an error
    set(gca, 'xcolor', 'k', 'ycolor', 'k');

    tightfig;
    print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/repetitionRange_d%d.pdf',d));
    % print(gcf, '-depsc', sprintf('~/Data/serialHDDM/repetitionRange_d%d.eps',d));
    
end