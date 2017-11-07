function e6_serialBias_SfN_modelFree_CRF_PPC
% ========================================== %
% conditional response functions from White & Poldrack
% run on simulated rather than real data
% ========================================== %

addpath(genpath('~/code/Tools'));
warning off; close all; clear;
global datasets datasetnames mypath

qntls = [.2, .4, .6, .8, .95]; % White & Poldrack
% qntls = [.1, .3, .5, .7, .9, 1]; % Leite & Ratcliff

for d = 1:length(datasets),
    
    % plot
    close all;
    subplot(441); hold on;
    % plot(qntls, 0.5*ones(size(qntls)), 'color',  'k', 'linewidth', 0.5);
    
    % redo this for each simulation
    models = {'stimcoding_z_prevresp', 'stimcoding_dc_prevresp', 'stimcoding_dc_z_prevresp', 'stimcoding_nohist', 'stimcoding_nohist'};
    colors = {[141 165 8] ./ 256, [8 141 165] ./ 256, {[8 141 165] ./ 256, [141 165 8] ./ 256}, [0.5 0.5 0.5], [0 0 0]};

    for m = 1:length(models),
        
		if ~exist(sprintf('%s/%s/%s/ppc_data.csv', mypath, datasets{d}, models{m}), 'file'),
			continue;
		else
			fprintf('%s/%s/%s/ppc_data.csv \n', mypath, datasets{d}, models{m});
		end
		
        % load simulated data - make sure this has all the info we need
        alldata    = readtable(sprintf('%s/%s/%s/ppc_data.csv', mypath, datasets{d}, models{m}));
        alldata    = sortrows(alldata, {'subj_idx'});
        
        if m < length(models),
            % use the simulations rather than the subjects' actual responses
            alldata.rt          = abs(alldata.rt_sampled);
            alldata.response    = alldata.response_sampled;
        end
      
        % make sure to use absolute RTs
        alldata.rt = abs(alldata.rt);
        
        % recode into repeat and alternate for the model
        alldata.repeat = zeros(size(alldata.response));
        alldata.repeat(alldata.response == (alldata.prevresp > 0)) = 1;
        
        %% define repeaters and alternators
        dat = readtable(sprintf('%s/summary/%s/allindividualresults.csv', mypath, datasets{d}));
        dat = dat(dat.session == 0, :);
  
        % recode into biased and unbiased choices 
        alldata.biased = alldata.repeat;
        altIdx = ismember(alldata.subj_idx, unique(dat.subjnr(dat.repetition < 0.5)));
        alldata.biased(altIdx) = double(~(alldata.biased(altIdx))); % flip
        
        % divide RT into quantiles for each subject
        discretizeRTs = @(x) {discretize(x, quantile(x, [0, qntls]))};
        rtbins = splitapply(discretizeRTs, alldata.rt, findgroups(alldata.subj_idx));
        alldata.rtbins = cat(1, rtbins{:});
        
        % get RT quantiles for choices that are in line with or against the bias
        [gr, sjidx, rtbins] = findgroups(alldata.subj_idx, alldata.rtbins);
        cpres               = array2table([sjidx, rtbins], 'variablenames', {'subj_idx', 'rtbin'});
        cpres.choice        = splitapply(@nanmean, alldata.biased, gr); % choice proportion
        
        % make into a subjects by rtbin matrix
        mat = unstack(cpres, 'choice', 'rtbin');
        mat = mat{:, 2:end}; % remove the last one, only has some weird tail
        
        % biased choice proportion
        if m < length(models),
            if isnumeric(colors{m})
                plot(qntls, nanmean(mat, 1), 'color', colors{m}, 'linewidth', 1.5);
            elseif iscell(colors{m}) % superimposed lines for dashed
                plot(qntls, nanmean(mat, 1), 'color', colors{m}{1}, 'linewidth', 1.5);
                plot(qntls, nanmean(mat, 1), ':', 'color', colors{m}{2}, 'linewidth', 1.5);
            end
        else
            %% ALSO ADD THE REAL DATA
            h = ploterr(qntls, nanmean(mat, 1), [], nanstd(mat, [], 1) ./ sqrt(size(mat, 1)), 'k-o', 'abshhxy', 0);
            set(h(1), 'color', 'k', 'markerfacecolor', 'k', 'markeredgecolor', 'w', 'linewidth', 1, 'markersize', 4);
            % plot(qntls, nanmean(mat, 1), 'color', colors{m}, 'linewidth', 1.5);
        end
    end
        
    axis tight; box off;
    set(gca, 'xtick', qntls);
    axis square;  offsetAxes;
    xlabel('RT (quantiles)'); ylabel('Fraction biased choices');
    title(datasetnames{d}{1});
    tightfig;
    print(gcf, '-dpdf', sprintf('~/Data/serialHDDM/CRF_PPC_d%d.pdf', d));
	fprintf('~/Data/serialHDDM/CRF_PPC_d%d.pdf \n', d);
    
end

end
