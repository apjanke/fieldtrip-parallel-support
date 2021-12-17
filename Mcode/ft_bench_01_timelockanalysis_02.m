function ft_bench_01_timelockanalysis_02
% Benchmark ft_timelockanalysis (variant 2).
%
% Based on ft_tut_12_preprocessing_combined_meg_eeg.

%% Setup

% Trial definition for both standard and deviant trial

cfg = [];
cfg.dataset = fullfile(ft_tut_workshopdir, 'natmeg', 'oddball1_mc_downsampled.fif');

cfg.trialdef.prestim        = 1;
cfg.trialdef.poststim       = 1;
cfg.trialdef.std_triggers   = 1;
cfg.trialdef.stim_triggers  = [1 2]; % 1 for standard, 2 for deviant
cfg.trialdef.odd_triggers   = 2;
cfg.trialdef.rsp_triggers   = [256 4096];
cfg.trialfun                = 'ft_tut_aux_12_trialfun_oddball_stimlocked';
cfg                         = ft_definetrial(cfg);

cfg.continuous              = 'yes';
cfg.hpfilter                = 'no';
cfg.detrend                 = 'no';
cfg.continuous              = 'yes';
cfg.demean                  = 'yes';
cfg.dftfilter               = 'yes';
cfg.dftfreq                 = [50 100];
cfg.channel                 = 'MEG';

data_MEG                    = ft_preprocessing(cfg);

% Degenerate for benchmarking: no artifact rejection

data_MEG_clean = data_MEG;

cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 25;
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.5 0];
data_MEG_filt       = ft_preprocessing(cfg,data_MEG_clean);


ix_standard = find(data_MEG_filt.trialinfo(:,1) == 1);
ix_oddball = find(data_MEG_filt.trialinfo(:,1) == 2);

%% Benchmark

t0 = tic;

cfg = [];
cfg.trials          = ix_standard;
ERF_standard        = ft_timelockanalysis(cfg,data_MEG_filt);

cfg = [];
cfg.trials          = ix_oddball;
ERF_oddball         = ft_timelockanalysis(cfg,data_MEG_filt);

te = toc(t0);
fprintf('Elapsed: %.03f s\n', te);

end