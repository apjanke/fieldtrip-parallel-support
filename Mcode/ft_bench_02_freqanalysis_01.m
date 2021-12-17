function ft_bench_02_freqanalysis_01
% Benchmark ft_freqanalysis (variant 1).
%
% Based on ft_tut_13_timefrequency_analysis.

%% Setup

% Trial definition for all conditions together

cfg                         = [];
cfg.dataset                 = fullfile(ft_tut_datadir, 'Subject01', 'Subject01.ds');
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = 'backpanel trigger';
cfg.trialdef.eventvalue     = [3 5 9]; % the values of the stimulus trigger for the three conditions
% 3 = fully incongruent (FIC), 5 = initially congruent (IC), 9 = fully congruent (FC)
cfg.trialdef.prestim        = 1; % in seconds
cfg.trialdef.poststim       = 2; % in seconds

cfg = ft_definetrial(cfg);

% Cleaning

% remove the trials that have artifacts from the trl
cfg.trl([2, 5, 6, 8, 9, 10, 12, 39, 43, 46, 49, 52, 58, 84, 102, 107, 114, 115, 116, 119, 121, 123, 126, 127, 128, 133, 137, 143, 144, 147, 149, 158, 181, 229, 230, 233, 241, 243, 245, 250, 254, 260],:) = [];

% preprocess the data
cfg.channel   = {'MEG', '-MLP31', '-MLO12'};        % read all MEG channels except MLP31 and MLO12
cfg.demean    = 'yes';                              % do baseline correction with the complete trial

data_all = ft_preprocessing(cfg);

cfg = [];
cfg.trials = data_all.trialinfo == 3;
dataFIC = ft_redefinetrial(cfg, data_all);

%% Benchmark


% Time-frequency analysis I

t0 = tic;

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'MEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:2:30;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
TFRhann = ft_freqanalysis(cfg, dataFIC);

te = toc(t0);
fprintf('Elapsed (1): %.03f s\n', te);

% Time-frequency analysis II

t0 = tic;

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'MRC15';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;
cfg.t_ftimwin    = 7./cfg.foi;  % 7 cycles per time window
cfg.toi          = -0.5:0.05:1.5;
TFRhann7 = ft_freqanalysis(cfg, dataFIC);

te = toc(t0);
fprintf('Elapsed (2): %.03f s\n', te);

% Time-frequency analysis III

t0 = tic;

cfg = [];
cfg.output     = 'pow';
cfg.channel    = 'MEG';
cfg.method     = 'mtmconvol';
cfg.foi        = 1:2:30;
cfg.t_ftimwin  = 5./cfg.foi;
cfg.tapsmofrq  = 0.4 *cfg.foi;
cfg.toi        = -0.5:0.05:1.5;
TFRmult = ft_freqanalysis(cfg, dataFIC);

te = toc(t0);
fprintf('Elapsed (3): %.03f s\n', te);

% Time-frequency analysis IV

t0 = tic;

cfg = [];
cfg.channel    = 'MEG';
cfg.method     = 'wavelet';
cfg.width      = 7;
cfg.output     = 'pow';
cfg.foi        = 1:2:30;
cfg.toi        = -0.5:0.05:1.5;
TFRwave = ft_freqanalysis(cfg, dataFIC);

te = toc(t0);
fprintf('Elapsed (3): %.03f s\n', te);

end