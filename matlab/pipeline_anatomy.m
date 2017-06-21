%% MRI PREPROCESSING, HEADMODEL, SOURCEMODEL

% PREPOCESSING
subject = 's05';

% converting dicoms to mgz format
streams_anatomy_dicom2mgz(subject);

% reslicing to freesufer-friendly 256x256x256
streams_anatomy_mgz2mni(subject);

streams_anatomy_mgz2ctf(subject);

% Skullstriping
streams_anatomy_skullstrip(subject);

%% Freesurfer scripts (creates subject-specific subdirectory in the directory where previous files are stored)
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end
subjects = {'s12' 's13' 's14' 's15' 's16' 's17' 's18' 's19' 's20' 's21' 's22' 's23' 's24' 's25' 's26'};

for i = 1:numel(subjects)
  
  subject = subjects{i};
  
  qsubfeval('qsub_streams_anatomy_freesurfer', subject,...
            'memreq', 1024^3 * 6,...
            'timreq', 720*60,...
            'batchid', 'streams_freesurferI');
end

%% Check-up and white matter segmentation cleaning if needed

streams_anatomy_volumetricQC(subject)

streams_anatomy_wmclean(subject)

%% Freesurfer qsub2
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

qsubfeval('qsub_streams_anatomy_freesurfer2', subject,...
          'memreq', 1024^3 * 7,...
          'timreq', 720*60,...
          'batchid', 'streams_freesurfer2');

%% Post-processing Freesurfer script: workbench HCP tool
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = {'s03' 's04' 's05' 's07' 's08' 's09' 's10'};

for k = 1:numel(subjects)
  
  subject = subjects{k};
  qsubfeval('streams_anatomy_workbench', subject,...
            'memreq', 1024^3 * 6,...
            'timreq', 480*60,...
            'batchid', 'streams_workbench');
          
end


% Coregistration check
streams_anatomy_coregistration_qc(subject);


%%  Sourcemodel
subjects = {'s04' 's05' 's07' 's08' 's09' 's10'};
for h = 1:numel(subjects)

  subject = subjects{h};
  streams_anatomy_sourcemodel2d(subject);

       
end

%% Headmodel

subjects = {'s04' 's05' 's07' 's08' 's09' 's10'};
for i = 1:numel(subjects)
   
  subject = subjects{i};
  qsubfeval('streams_anatomy_headmodel', subject, ...
            'memreq', 1024^3 * 5,...
            'timreq', 20*60,...
            'batchid', 'streams_headmodel')

end

%% Leadfield parcellation

subjects = {'s03' 's04' 's05' 's07' 's08' 's09' 's10'};
for h = 1:numel(subjects)

  subject = subjects{h};
  qsubfeval('streams_leadfield', subject, ...
            'memreq', 1024^3 * 6,...
            'timreq', 25*60,...
            'batchid', 'streams_headmodel');

       
end
