%% Create structures for statistics

stories = {'fn001078', 'fn001155', 'fn001293', 'fn001294', 'fn001443', 'fn001481', 'fn001498'};
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
feat_band = {'entr_12-18', 'perp_12-18', 'entr_04-08', 'perp_04-08'};


% Create structures for averaging
save_dir = '/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss/MI_combined';

for i = 1:numel(feat_band)
    getdata = fullfile('/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss', ...
                       ['*' feat_band{i} '*']);

    files = dir(getdata);
    files = {files.name}';
    
    miReal = cell(numel(files), 1);
    miShuf = cell(numel(files), 1);

    for k = 1 : numel(files)

        filename = files{k};
        load(filename);
        
        % real MI condition
        miReal{k} = stat;
        miReal{k} = rmfield(miReal{k}, 'statshuf');    % remove the statshuf timecourse
        
        % surrogate MI
        miShuf{k} = stat;
        miShuf{k} = rmfield(miShuf{k}, {'statshuf', 'stat'});   % remove old .statshuf & .stat field
        miShuf{k}.stat = mean(stat.statshuf, 3);                % add .statshuf timecourse as .stat field
        miShuf{k} = orderfields(miShuf{k}, miReal{k});          % order fields as in miReal

    end    

    saveMi = fullfile(save_dir, ['mi_' filename(14:23)] );
    save(saveMi, 'miReal', 'miShuf');

end

%% PLOTS (if needed)

% Plot for all subjects
for isub = 1:length(miReal)
    
    subplot(3,4,isub)
    
%   plot the lines in front of the rectangle
%     plot(miReal{isub}.time,miReal{isub}.stat(:,:));
%     hold on;
%     plot(miShuf{isub}.time,miShuf{isub}.stat(:,:), 'r');
%     hold on;
     plot(miReal{isub}.time, mean(miReal{isub}.stat, 1), 'b');
     hold on;
     plot(miShuf{isub}.time, mean(miShuf{isub}.stat, 1), 'r');
     title(strcat('subject_ ', num2str(isub)))

end

subplot(3,4,11);
text(0.5,0.5,'Real','color','b') ;text(0.5,0.3,'Shuffle','color','r')
axis off

%% Dependent sample t-test (FT-style)

cfg = [];
cfg.channel     = 'MEG'; %now all channels
%cfg.latency     = [0 0.5];
%cfg.avgovertime = 'yes';
cfg.parameter   = 'stat';
cfg.method      = 'analytic';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'bonferroni';
cfg.tail = 1;

Nsub = numel(miReal);
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
 
stat = ft_timelockstatistics(cfg, miReal{:}, miShuf{:});

