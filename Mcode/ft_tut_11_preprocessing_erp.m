function ft_tut_11_preprocessing_erp
% Tutorial: Preprocessing of EEG data and computing ERPs
%
% From: https://www.fieldtriptoolbox.org/tutorial/preprocessing_erp/

cfg              = [];
cfg.trialfun     = 'ft_tut_aux_11_trialfun_affcog';
cfg.headerfile   = fullfile(ft_tut_datadir, 'preprocessing_erp', 's04.vhdr');
cfg.datafile     = fullfile(ft_tut_datadir, 'preprocessing_erp', 's04.eeg');
cfg = ft_definetrial(cfg);

% Pre-processing and re-referencing

% Baseline-correction options
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.2 0];

% Fitering options
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 100;

% Re-referencing options - see explanation above
cfg.implicitref   = 'LM';
cfg.reref         = 'yes';
cfg.refchannel    = {'LM' 'RM'};

data = ft_preprocessing(cfg);

% Visualization

cfg = [];  % use only default options
% ft_databrowser(cfg, data);

cfg         = [];
cfg.dataset = fullfile(ft_tut_datadir, 'preprocessing_erp', 's04.vhdr');
% ft_databrowser(cfg);

% EOGV channel
cfg              = [];
cfg.channel      = {'53' 'LEOG'};
cfg.reref        = 'yes';
cfg.implicitref  = []; % this is the default, we mention it here to be explicit
cfg.refchannel   = {'53'};
eogv             = ft_preprocessing(cfg, data);


% only keep one channel, and rename to eogv
cfg              = [];
cfg.channel      = 'LEOG';
eogv             = ft_selectdata(cfg, eogv);
eogv.label       = {'eogv'};

% EOGH channel
cfg              = [];
cfg.channel      = {'57' '25'};
cfg.reref        = 'yes';
cfg.implicitref  = []; % this is the default, we mention it here to be explicit
cfg.refchannel   = {'57'};
eogh             = ft_preprocessing(cfg, data);

% only keep one channel, and rename to eogh
cfg              = [];
cfg.channel      = '25';
eogh             = ft_selectdata(cfg, eogh);
eogh.label       = {'eogh'};

% only keep all non-EOG channels
cfg         = [];
cfg.channel = setdiff(1:60, [53, 57, 25]);        % you can use either strings or numbers as selection
data        = ft_selectdata(cfg, data);

% append the EOGH and EOGV channel to the 60 selected EEG channels
cfg  = [];
data = ft_appenddata(cfg, data, eogv, eogh);

% Channel layout plot

cfg        = [];
cfg.layout = 'mpi_customized_acticap64.mat';
ft_layoutplot(cfg);

% Artifacts

% Channel mode

cfg        = [];
cfg.method = 'channel';
data_clean_1 = ft_rejectvisual(cfg, data);

cfg          = [];
cfg.method   = 'summary';
cfg.layout   = 'mpi_customized_acticap64.mat';  % for plotting individual trials
cfg.channel  = [1:60];                          % do not show EOG channels
data_clean   = ft_rejectvisual(cfg, data);

% Computing and plotting the ERPs

% use ft_timelockanalysis to compute the ERPs
cfg = [];
cfg.trials = find(data_clean.trialinfo==1);
task1 = ft_timelockanalysis(cfg, data_clean);

cfg = [];
cfg.trials = find(data_clean.trialinfo==2);
task2 = ft_timelockanalysis(cfg, data_clean);

cfg = [];
cfg.layout = 'mpi_customized_acticap64.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, task1, task2)

% Examine ERP difference waves

cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
difference = ft_math(cfg, task1, task2);

% note that the following appears to do the sam
% difference     = task1;                   % copy one of the structures
% difference.avg = task1.avg - task2.avg;   % compute the difference ERP
% however that will not keep provenance information, whereas ft_math will

cfg = [];
cfg.layout      = 'mpi_customized_acticap64.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, difference);

end
