function [comp]  = streams_componentanalysis_fastica(subject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

datadir = '/project/3011044.02/preproc/meg';
d = [subject '_meg.mat'];
datafile = fullfile(datadir, d);
compfile = fullfile(datadir, [subject '_comp.mat']);

load(datafile);

cfg                   = [];
cfg.method            = 'fastica';
cfg.fastica.lastEig   = 80;
cfg.fastica.g         = 'tanh';
cfg.channel           = 'MEG';
cfg.numcomponent      = 20;
comp                  = ft_componentanalysis(cfg, data);

save(compfile, 'comp');

end

