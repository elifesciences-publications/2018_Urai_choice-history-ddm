function e3_serialBias_SfN_repetitionRange

global mypath datasets datasetnames
addpath(genpath('~/code/Tools'));
warning off; close all;

cmap = viridis(256);
colormap(cmap);

for d = 1:length(datasets),
    
    close all;
    subplot(6,6,1); hold on;
    dat = readtable(sprintf('%s/summary/%s/allindividualresults.csv', mypath, datasets{d}));
    dat = dat(dat.session == 0, :);
    if d == 5
        dat(dat.subjnr == 11, :) = [];
    end
    
    rep = sort(dat.repetition);
    barh(rep, 'facecolor', [0.5 0.5 0.5], 'basevalue', 0.5, 'edgecolor', 'none');
    % ylabel(sprintf('%s, n = %d', datasetnames{d}{1}, numel(rep)));
    % show on x-axis what the mean is
    box off; xlim([0.4 0.6]); ylim([0 numel(rep)+0.5]);
    plot(mean(rep), 0, 'k^', 'markerfacecolor', 'k', 'markersize', 2);
    set(gca, 'ytick', [1 numel(rep)], 'xtick', [0.4 0.5 0.6]);
    % offsetAxes;
    
    % yyaxis right;
    if d < 4
        name = strsplit(datasetnames{d}{1});
        y = ylabel({name{1} [name{2} ' ' name{3}]});
    else
        y = ylabel(sprintf('%s', datasetnames{d}{1}));
    end
    
    y.Rotation = y.Rotation + 180;
    y.Position(1) = y.Position(1) + 0.27;
    xlabel('P(repeat)');
    %axis square;
    set(gca, 'xcolor', 'k', 'ycolor', 'k');
    % text(0.7, 0, '.w');
    subplot(6,6,2); plot(0,0,'.w'); axis off;
    tightfig;
    print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/repetitionRange_d%d.pdf',d));
    % print(gcf, '-depsc', sprintf('~/Data/serialHDDM/repetitionRange_d%d.eps',d));
    
end