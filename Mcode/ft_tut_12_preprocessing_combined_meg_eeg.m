function ft_tut_12_preprocessing_combined_meg_eeg
% Tutorial: Preprocessing and event-related activity in combined MEG/EEG data
%
% From: https://www.fieldtriptoolbox.org/workshop/natmeg/preprocessing/

% Examine magnetometer

cfg = [];
cfg.dataset    = fullfile(ft_tut_workshopdir, 'natmeg', 'oddball1_mc_downsampled.fif');
cfg.continuous = 'yes';
cfg.channel    = 'MEG*1';
cfg.viewmode   = 'vertical';
cfg.blocksize  = 1; % Length of data to display, in seconds

ft_databrowser(cfg);

% Examine gradiometer

cfg = [];
cfg.dataset = fullfile(ft_tut_workshopdir, 'natmeg', 'oddball1_mc_downsampled.fif');
cfg.channel = {'MEG*2', 'MEG*3'};
cfg.viewmode = 'vertical';
cfg.blocksize = 1;                             % Length of data to display, in seconds

ft_databrowser(cfg);

% Examine EEG channel

cfg = [];
cfg.dataset = fullfile(ft_tut_workshopdir, 'natmeg', 'oddball1_mc_downsampled.fif');
cfg.channel = 'EEG';
cfg.viewmode = 'vertical';
cfg.blocksize = 1;                             % Length of data to display, in seconds
cfg.preproc.demean = 'yes';                    % Demean the data before display
cfg.ylim = [-4e-6 4e-6];

ft_databrowser(cfg);

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

figure
plot(data_MEG.time{1}, data_MEG.trial{1}(130,:))

% separately for magnetometers
cfg               = [];
cfg.metric        = 'zvalue';
cfg.layout        = 'neuromag306all.lay';
cfg.channel       = 'MEG*1';
cfg.keepchannel   = 'yes';  % This keeps those channels that are not displayed in the data
data_MEG_clean    = ft_rejectvisual(cfg,data_MEG);

% separately for gradiometers
cfg.channel = {'MEG*2','MEG*3'};
data_MEG_clean    = ft_rejectvisual(cfg,data_MEG_clean);

cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 25;
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.5 0];
data_MEG_filt       = ft_preprocessing(cfg,data_MEG_clean);

cfg = [];
cfg.trials          = find(data_MEG_filt.trialinfo(:,1) == 1);
ERF_standard        = ft_timelockanalysis(cfg,data_MEG_filt);

cfg.trials          = find(data_MEG_filt.trialinfo(:,1) == 2);
ERF_oddball         = ft_timelockanalysis(cfg,data_MEG_filt);

cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';

ERF_diff = ft_math(cfg, ERF_oddball, ERF_standard);

cfg = [];
cfg.fontsize = 6;
cfg.layout = 'neuromag306mag.lay';
cfg.ylim = [-2.5e-13 2.5e-13];
cfg.xlim = [-0.2 0.6];

figure
ft_multiplotER(cfg, ERF_standard, ERF_oddball, ERF_diff );
legend({'Standard';'Oddball';'Difference'});

cfg = [];
cfg.fontsize = 6;
cfg.layout   = 'neuromag306mag.lay';
cfg.xlim     = [-0.2 0.6];
cfg.ylim     = [-3e-13 3e-13];
cfg.channel  = 'MEG0211';

figure;
ft_singleplotER(cfg, ERF_standard, ERF_oddball, ERF_diff);
legend({'Standard';'Oddball';'Difference'});

% Plot topographic distribution of data averaged over time

cfg                 = [];
cfg.layout          = 'neuromag306mag.lay'; % name will change
cfg.zlim            = [-3e-13 3e-13];
cfg.xlim            = [0.08 0.15];
cfg.style           = 'straight';
cfg.comment         = 'no';
cfg.marker          = 'off';
cfg.colorbar        = 'southoutside';

figure;
subplot(1,3,1);
ft_topoplotER(cfg, ERF_standard);
title('Standard');
axis tight

subplot(1,3,2);
ft_topoplotER(cfg, ERF_oddball);
title('Oddball');
axis tight

subplot(1,3,3);
ft_topoplotER(cfg, ERF_diff);
title('Difference');
axis tight

% Combine planar
cfg = [];
ERF_standard_cmb    = ft_combineplanar(cfg, ERF_standard);
ERF_oddball_cmb     = ft_combineplanar(cfg, ERF_oddball);
ERF_diff_cmb        = ft_combineplanar(cfg, ERF_diff);

cfg = [];
cfg.fontsize = 6;
cfg.layout   = 'neuromag306cmb.lay';
cfg.ylim     = [0 8e-12];
cfg.xlim     = [-0.2 0.6];

figure;
ft_multiplotER(cfg, ERF_standard_cmb, ERF_oddball_cmb, ERF_diff_cmb);
legend({'Standard', 'Oddball', 'Difference'});

% Zoom in on one combined channel

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize   = 6;
cfg.layout     = 'neuromag306cmb.lay';
cfg.xlim       = [-0.2 0.6];
cfg.ylim       = [0 8e-12];
cfg.channel    = 'MEG0222+0223';

figure;
ft_singleplotER(cfg, ERF_standard_cmb, ERF_oddball_cmb, ERF_diff_cmb);
legend({'Standard', 'Oddball', 'Difference'});

% Examine topographical spred of field

cfg                 = [];
cfg.layout          = 'neuromag306cmb.lay'; % name will change
cfg.zlim            = 'zeromax';
cfg.xlim            = [0.08 0.15];
cfg.style           = 'straight';
cfg.comment         = 'no';
cfg.marker          = 'off';
cfg.colorbar        = 'southoutside';

figure;
subplot(1,3,1);
ft_topoplotER(cfg, ERF_standard_cmb);
title('Standard');
axis tight

subplot(1,3,2);
ft_topoplotER(cfg, ERF_oddball_cmb);
title('Deviant');
axis tight

subplot(1,3,3);
ft_topoplotER(cfg, ERF_diff_cmb);
title('Difference');
axis tight

% Preprocessing and averaging EEG

% Reading and preprocessing interesting trials

cfg = [];
cfg.dataset = fullfile(ft_tut_workshopdir, 'natmeg', 'oddball1_mc_downsampled.fif');

cfg.trialdef.prestim        = 1;
cfg.trialdef.poststim       = 1;
cfg.trialdef.std_triggers   = 1;
cfg.trialdef.stim_triggers  = [1 2];
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
cfg.channel                 = 'EEG';

cfg.reref                   = 'yes'; % recorded with left mastoid
cfg.refchannel              = 'all';

data_EEG                    = ft_preprocessing(cfg);

% Interactively reject artifacts

cfg               = [];
cfg.metric        = 'zvalue';
cfg.layout        = 'natmeg_customized_eeg1005.lay';
data_EEG_clean    = ft_rejectvisual(cfg,data_EEG);

% Timelock analysis

cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 25;
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.5 0];
data_EEG_filt       = ft_preprocessing(cfg,data_EEG_clean);

cfg = [];
cfg.trials          = find(data_EEG_filt.trialinfo(:,1) == 1);
ERP_standard        = ft_timelockanalysis(cfg, data_EEG_filt);

cfg.trials          = find(data_EEG_filt.trialinfo(:,1) == 2);
ERP_oddball         = ft_timelockanalysis(cfg, data_EEG_filt);

cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';

ERP_diff = ft_math(cfg, ERP_oddball, ERP_standard);

% Plot results of EEG

cfg          = [];
cfg.fontsize = 6;
cfg.layout   = 'natmeg_customized_eeg1005.lay';
cfg.ylim     = [-3e-6 3e-6];
cfg.xlim     = [-0.2 0.6];

figure;
ft_multiplotER(cfg, ERP_standard, ERP_oddball, ERP_diff);

cfg            = [];
cfg.showlabels = 'yes';
cfg.fontsize   = 6;
cfg.layout     = 'natmeg_customized_eeg1005.lay';
cfg.xlim       = [-0.2 0.6];
cfg.ylim       = [-8e-6 8e-6];
cfg.channel    = 'EEG020';

figure;
ft_singleplotER(cfg, ERP_standard, ERP_oddball, ERP_diff);
legend({'Standard';'Oddball';'Difference'});

% Topo
cfg                 = [];
cfg.layout          = 'natmeg_customized_eeg1005.lay';
cfg.zlim            = [-3e-6 3e-6];
cfg.xlim            = [0.08 0.15];
cfg.style           = 'straight';
cfg.comment         = 'no';
cfg.marker          = 'off';
cfg.colorbar        = 'southoutside';

figure;
subplot(1,3,1);
ft_topoplotER(cfg,ERP_standard);
title('Standard');
axis tight

subplot(1,3,2);
ft_topoplotER(cfg,ERP_oddball);
title('Deviant');
axis tight

subplot(1,3,3);
ft_topoplotER(cfg,ERP_diff);
title('Difference');
axis tight

% Scalp current density (SCD)

cfg                 = [];
cfg.method          = 'finite';
cfg.elec            = ERP_standard.elec;

scd_ERP_standard    = ft_scalpcurrentdensity(cfg, ERP_standard);
scd_ERP_oddball     = ft_scalpcurrentdensity(cfg, ERP_oddball);
scd_ERP_diff        = ft_scalpcurrentdensity(cfg, ERP_diff);

% Plot SCD results

cfg                 = [];
cfg.layout          = 'natmeg_customized_eeg1005.lay'; % name will change
cfg.zlim            = 'maxabs';
cfg.xlim            = [0.08 0.15];
cfg.style           = 'straight';
cfg.comment         = 'no';
cfg.marker          = 'off';
cfg.colorbar        = 'southoutside';

figure;
subplot(1,3,1);
ft_topoplotER(cfg,scd_ERP_standard);
title('Standard');
axis tight;

subplot(1,3,2);
ft_topoplotER(cfg,scd_ERP_oddball);
title('Oddball');
axis tight;

subplot(1,3,3);
ft_topoplotER(cfg,scd_ERP_diff);
title('Difference');
axis tight;

% Combining MEG and EEG

cfg      = [];
data_all = ft_appenddata(cfg, data_MEG, data_EEG);

cfg = [];
cfg.channel    = 'EEG';
cfg.metric     = 'zvalue';
cfg.keepchannel= 'yes';
cfg.layout     = 'neuromag306all.lay';
data_all_clean = ft_rejectvisual(cfg, data_all);

cfg.channel    = 'MEGMAG';
data_all_clean = ft_rejectvisual(cfg, data_all_clean);

cfg.channel    = 'MEGGRAD';
data_all_clean = ft_rejectvisual(cfg, data_all_clean);



