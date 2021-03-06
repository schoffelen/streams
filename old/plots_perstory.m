clear all
close all

datadir = '/project/3011044.02/analysis/mi/';
savedir = '/project/3011044.02/analysis/mi/per_story';

stories = {'1078', '1155', '1172', '1293', '1294', '1443', '1481', '1498'};
freqs = {'01-03', '04-08', '09-12' '13-18'};
datatype = 'ang_aud';

% plotting parameters for topoplot
cfg                    = [];   
cfg.zlim               = 'maxmin';
cfg.comment            = 'no';
cfg.colorbar           = 'EastOutside';
cfg.style              = 'straight';
cfg.colormap           = 'jet';
cfg.layout             = 'CTF275_helmet.mat';
cfg.comment            = 'xlim';

for h = 1:numel(freqs)
    
    freq = freqs{h};
    
    for k = 1:numel(stories)
    
      
        % specify data
        datadir = '/project/3011044.02/analysis/mi/per_subject/';
        story = stories{k};

        % plot the sensor-level data
        filename_sens = ['all_' story  '_' datatype '_' freq '_sens_30hz.mat'];
        fullfilename_sens = fullfile(savedir,['ga_' filename_sens]);
        load(fullfilename_sens);
        
        figure('Color', [1 1 1]);
        
        % plot timecourses
        h = subplot(3, 2, 2);
        plot(ga.time, ga.avg);
        xlim([min(ga.time) max(ga.time)]);
        xlabel(h, 'lag (s)',  'FontWeight', 'bold');
        ylabel(h, 'MI (bit)', 'FontWeight', 'bold');
        
        % take the time point with max MI value for topo
        [maxvalue, I] = max(max(ga.avg));
        ga.time = ga.time(:, I);
        ga.avg = ga.avg(:, I);
        ga.avg = ga.avg-min(ga.avg);
        
        % plot topography
        fprintf('plotting %s \n', filename_sens)
        subplot(3, 2, 1);
        ft_topoplotER(cfg, ga);

        clear title
        title([story ' ' datatype(1:3) ' ' datatype(end-2:end) ' ' freq]);

        % source level plot
        filename_source = ['all_' story  '_' datatype '_' freq '_lcmv_30hz.mat'];
        functional = [filename_source '.mat'];
        sourcemodel = ['~/pro/streams/data/MRI/preproc/' story '_sourcemodel.mat'];

        fprintf('plotting %s \n\n', filename_source)

        % load the data
        load(functional) 
        load(sourcemodel)
        load atlas_subparc374_8k

        % add anatomical information to functional struct
        s = ga;
        s.stat = ga.avg;
        s = rmfield(s, {'avg', 'var', 'dof'});
        s.brainordinate.pos = sourcemodel.pos;
        s.brainordinate.tri = sourcemodel.tri;
        s.brainordinate.parcellation = atlas.parcellation;
        s.brainordinate.parcellationlabel = atlas.parcellationlabel;

        %plot time MI timecourse for all parcels
        h = subplot(3, 2, 5); set(h,'Position',[0.13 0.06 0.30 0.25]);
        plot(s.time, s.stat);
        xlim([min(s.time), max(s.time)]);
        axis([min(s.time), max(s.time), min(min(s.stat)), max(max(s.stat))]);
        xlabel(h, 'lag (s)',  'FontWeight', 'bold');
        ylabel(h, 'MI (bit)', 'FontWeight', 'bold');

        % Get the time point with maximum MI values accoring to the
        % sensor-level data
        s.time = s.time(:, I);
        s.stat = s.stat(:, I);
        s.stat = s.stat-min(s.stat);

        % plot on cortical surface
        splot = ft_checkdata(s, 'datatype', 'source'); % new data structure variable for ft_plot_mesh
        % left hemisphere
        h = subplot(3, 2, 3); set(h,'position',[0.10 0.35 0.30 0.30]);
        ft_plot_mesh(splot, 'vertexcolor', splot.stat);

        view(160, 10);
        h = light; set(h, 'position', [0 1 0]);
        lighting gouraud
        
        % plot the right hemisphere
        h = subplot(3, 2, 4); set(h,'Position',[0.55 0.35 0.30 0.30]);
        ft_plot_mesh(splot, 'vertexcolor', splot.stat);
        xlabel(h, sprintf('time: %ss', num2str(splot.time)));
        ax = gca;
        ax.XLabel.Position(2) = -0.75; 
        
        hc = colorbar; set(hc, 'YLim', [min(splot.stat) max(splot.stat)]);
        ax = gca; % get colorobar axes
        set(hc, 'Position', [0.90 0.35 0.02 0.27]); % arrange colorbar y coordinate
        ylabel(hc, 'MI (bit)', 'FontSize', 12, 'FontWeight', 'bold');

        view(20, 10);
        h = light; set(h, 'position', [0 -1 0]);
        lighting gouraud
        
        print(fullfile(savedir, ['ga_all_' story '_' datatype '_' freq]), '-dpdf', '-fillpage');
        close all
        
    end
    
    % append separate pdfs into a single firle(requires export_fig toolbox)
    append_names_list = dir([savedir '/ga_all_*' datatype '*' freq '*.pdf']);
    append_names = {append_names_list.name}';

    for i=1:numel(append_names)

        append_names{i} = fullfile(savedir, append_names{i});

    end

    jointpdf = fullfile(savedir, ['appended_' datatype '_' freq '.pdf']);
    append_pdfs(jointpdf, append_names{:});
    
end