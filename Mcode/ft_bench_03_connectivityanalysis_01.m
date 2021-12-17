function ft_bench_03_connectivityanalysis_01
% Benchmark ft_connectivityanalysis (variant 1).
%
% Based on ft_tut_15_sensor_analysis.

%% Setup

% Load preprocessed data

load(fullfile(ft_tut_datadir, 'sensor_analysis', 'subjectK.mat'));

cfg  = [];
data = ft_appenddata(cfg, data_left, data_right);

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

%% Benchmark

t0 = tic;

cfg                 = [];
cfg.method          = 'coh';
cfg.channelcmb      = {'MEG' 'EMG'};
conn                = ft_connectivityanalysis(cfg, freq_csd);

te = toc(t0);
fprintf('Elapsed: %.03f s\n', te);


end
