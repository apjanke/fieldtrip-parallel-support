function ft_tut_15_sensor_analysis
% Tutorial: Sensor-level ERF, TFR and connectivity analysis
%
% From: https://www.fieldtriptoolbox.org/tutorial/sensor_analysis/

% Load preprocessed data

load(fullfile(ft_tut_datadir, 'sensor_analysis', 'subjectK.mat'));

% Visualization

plot(data_left.time{1}, data_left.trial{1}(130,:));

figure
for k = 1:10
plot(data_left.time{k}, data_left.trial{k}(130,:)+k*1.5e-12);
hold on;
end
plot([0 0], [0 1], 'k');
ylim([0 11*1.5e-12]);
set(gca, 'ytick', (1:10).*1.5e-12);
set(gca, 'yticklabel', 1:10);
ylabel('trial number');
xlabel('time (s)');

% Event-related analysis

cfg  = [];
data = ft_appenddata(cfg, data_left, data_right);

cfg                 = [];
cfg.channel         = 'MEG';
tl                  = ft_timelockanalysis(cfg, data);

% Visualization

cfg                 = [];
cfg.showlabels      = 'yes';
cfg.showoutline     = 'yes';
cfg.layout          = 'CTF151_helmet.mat';
ft_multiplotER(cfg, tl);

% Planar gradient

cfg                 = [];
cfg.method          = 'template';
cfg.template        = 'CTF151_neighb.mat';
neighbours          = ft_prepare_neighbours(cfg, data);

cfg                 = [];
cfg.method          = 'sincos';
cfg.neighbours      = neighbours;
data_planar         = ft_megplanar(cfg, data);

cfg                 = [];
cfg.channel         = 'MEG';
tl_planar           = ft_timelockanalysis(cfg, data_planar);

cfg                 = [];
tl_plancmb          = ft_combineplanar(cfg, tl_planar);

cfg                 = [];
cfg.showlabels      = 'yes';
cfg.showoutline     = 'yes';
cfg.layout          = 'CTF151_helmet.mat';
ft_multiplotER(cfg, tl_plancmb);

% Time-frequency analysis

cfg                 = [];
cfg.toilim          = [-0.8 1];
cfg.minlength       = 'maxperlen'; % this ensures all resulting trials are equal length
data_small          = ft_redefinetrial(cfg, data_planar);

cfg                 = [];
cfg.method          = 'mtmconvol';
cfg.taper           = 'hanning';
cfg.channel         = 'MEG';

% set the frequencies of interest
cfg.foi             = 20:5:100;

% set the timepoints of interest: from -0.8 to 1.1 in steps of 100ms
cfg.toi             = -0.8:0.1:1;

% set the time window for TFR analysis: constant length of 200ms
cfg.t_ftimwin       = 0.2 * ones(length(cfg.foi), 1);

% average over trials
cfg.keeptrials      = 'no';

% pad trials to integer number of seconds, this speeds up the analysis
% and results in a neatly spaced frequency axis
cfg.pad             = 2;
freq                = ft_freqanalysis(cfg, data_small);

cfg                 = [];
freq                = ft_combineplanar(cfg, freq);

% Visualization

cfg                 = [];
cfg.interactive     = 'yes';
cfg.showoutline     = 'yes';
cfg.layout          = 'CTF151_helmet.mat';
cfg.baseline        = [-0.8 0];
cfg.baselinetype    = 'relchange';
cfg.zlim            = 'maxabs';
ft_multiplotTFR(cfg, freq);

cfg = [];
ft_analysispipeline(cfg, freq);

% Cortico-muscular coherence

cfg                 = [];
cfg.toilim          = [-1 -0.0025];
cfg.minlength       = 'maxperlen'; % this ensures all resulting trials are equal length
data_stim           = ft_redefinetrial(cfg, data);

cfg                 = [];
cfg.output          = 'powandcsd';
cfg.method          = 'mtmfft';
cfg.taper           = 'dpss';
cfg.tapsmofrq       = 5;
cfg.foilim          = [5 100];
cfg.keeptrials      = 'yes';
cfg.channel         = {'MEG' 'EMGlft' 'EMGrgt'};
cfg.channelcmb      = {'MEG' 'EMGlft'; 'MEG' 'EMGrgt'};
freq_csd            = ft_freqanalysis(cfg, data_stim);

cfg                 = [];
cfg.method          = 'coh';
cfg.channelcmb      = {'MEG' 'EMG'};
conn                = ft_connectivityanalysis(cfg, freq_csd);

% Visualization

cfg                 = [];
cfg.parameter       = 'cohspctrm';
cfg.xlim            = [5 80];
cfg.refchannel      = 'EMGlft';
cfg.layout          = 'CTF151_helmet.mat';
cfg.showlabels      = 'no';
cfg.interactive     = 'yes';
figure;
ft_multiplotER(cfg, conn);


end