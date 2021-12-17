function ft_bench_01_timelockanalysis_01
% Benchmark ft_timelockanalysis (variant 1).
%
% Based on ft_tut_11_preprocessing_erp.

%% Setup

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

ix_task1 = find(data.trialinfo==1);
ix_task2 = find(data.trialinfo==2);

%% Benchmark

% use ft_timelockanalysis to compute the ERPs

t0 = tic;

cfg = [];
cfg.trials = ix_task1;
task1 = ft_timelockanalysis(cfg, data);

cfg = [];
cfg.trials = ix_task2;
task2 = ft_timelockanalysis(cfg, data);

te = toc(t0);
fprintf('Elapsed: %.03f s\n', te);

end