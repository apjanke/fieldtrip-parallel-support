function ft_tut_06_trigger_based_trial_selection
% Tutorial: Trigger-based trial selection
%
% From: https://www.fieldtriptoolbox.org/tutorial/preprocessing/

% Define trials and read their data in

cfg                         = [];
cfg.dataset                 = fullfile(ft_tut_datadir, 'Subject01', 'Subject01.ds');
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = 'backpanel trigger';
cfg.trialdef.eventvalue     = [3 5 9]; % the values of the stimulus trigger for the three conditions
% 3 = fully incongruent (FIC), 5 = initially congruent (IC), 9 = fully congruent (FC)
cfg.trialdef.prestim        = 1; % in seconds
cfg.trialdef.poststim       = 2; % in seconds

cfg = ft_definetrial(cfg);

cfg.channel    = {'MEG' 'EOG'};
cfg.continuous = 'yes';
data_all = ft_preprocessing(cfg);

figure
plot(data_all.time{1}, data_all.trial{1}(130,:))

% Split conditions by selecting trials according to their trigger value

cfg=[];
cfg.trials = data_all.trialinfo==3;
dataFIC = ft_selectdata(cfg, data_all);

cfg.trials = data_all.trialinfo==5;
dataIC = ft_selectdata(cfg, data_all);

cfg.trials = data_all.trialinfo==9;
dataFC = ft_selectdata(cfg, data_all);

% Trial selection using a custom function

cfg = [];
cfg.dataset              = fullfile(ft_tut_datadir, 'Subject01', 'Subject01.ds');
cfg.trialfun             = 'ft_tut_aux_06_mytrialfun';     % it will call your function and pass the cfg
cfg.trialdef.eventtype  = 'backpanel trigger';
cfg.trialdef.eventvalue = [3 5 9];           % read all conditions at once
cfg.trialdef.prestim    = 1; % in seconds
cfg.trialdef.poststim   = 2; % in seconds

cfg = ft_definetrial(cfg);

cfg.channel = {'MEG' 'STIM'};
dataMytrialfun = ft_preprocessing(cfg);

end

