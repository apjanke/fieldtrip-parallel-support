function ft_tut_16_sleep
% Tutorial: Extracting the brain state and events from continuous sleep EEG
%
% From: https://www.fieldtriptoolbox.org/tutorial/sleep/

datapath = fullfile(ft_tut_datadir, 'sleep');
run(fullfile(ft_tut_datadir, 'sleep', 'Subject01.m'));

% load the continuous sleep EEG, EOG, EMG and ECG data
cfg             = [];
cfg.dataset     = [datapath filesep subjectdata.subjectdir filesep subjectdata.datafile];
cfg.continuous  = 'yes';
data_orig = ft_preprocessing(cfg);

montage_rename          = [];
montage_rename.labelold = {'C4-A1' 'ROC-LOC' 'EMG1-EMG2' 'ECG1-ECG2'};
montage_rename.labelnew = {'EEG' 'EOG' 'EMG' 'ECG'};
montage_rename.tra      = eye(4);

cfg         = [];
cfg.montage = montage_rename;
data_continuous = ft_preprocessing(cfg, data_orig);

cfg             = [];
cfg.continuous  = 'yes';
cfg.viewmode    = 'vertical'; % all channels separate
cfg.blocksize   = 30;         % view the continuous data in 30-s blocks
ft_databrowser(cfg, data_continuous);

  % segment the continuous data in segments of 30-seconds
  % we call these epochs trials, although they are not time-locked to a particular event
  cfg          = [];
  cfg.length   = 30; % in seconds;
  cfg.overlap  = 0;
  data_epoched = ft_redefinetrial(cfg, data_continuous);
  
  % Detect wake periods using EMG & EOG
  
  cfg                              = [];
  cfg.continuous                   = 'yes';
  cfg.artfctdef.muscle.interactive = 'yes';

  % channel selection, cutoff and padding
  cfg.artfctdef.muscle.channel     = 'EMG';
  cfg.artfctdef.muscle.cutoff      = 4; % z-value at which to threshold (default = 4)
  cfg.artfctdef.muscle.trlpadding  = 0;

  % algorithmic parameters
  cfg.artfctdef.muscle.bpfilter    = 'yes';
  cfg.artfctdef.muscle.bpfreq      = [20 45]; % typicall [110 140] but sampling rate is too low for that
  cfg.artfctdef.muscle.bpfiltord   = 4;
  cfg.artfctdef.muscle.bpfilttype  = 'but';
  cfg.artfctdef.muscle.hilbert     = 'yes';
  cfg.artfctdef.muscle.boxcar      = 0.2;
  
  % conservative rejection intervals around EMG events
  cfg.artfctdef.muscle.pretim  = 10; % pre-artifact rejection-interval in seconds
  cfg.artfctdef.muscle.psttim  = 10; % post-artifact rejection-interval in seconds

  % keep a copy for the exercise
  cfg_muscle_epoched = cfg;

  % feedback, explore the right threshold for all data (one trial, th=4 z-values)
  cfg = ft_artifact_muscle(cfg, data_continuous);

  % make a copy of the samples where the EMG artifacts start and end, this is needed further down
  EMG_detected = cfg.artfctdef.muscle.artifact;

  cfg_art_browse             = cfg;
  cfg_art_browse.continuous  = 'yes';
  cfg_art_browse.viewmode    = 'vertical';
  cfg_art_browse.blocksize   = 30*60; % view the data in 10-minute blocks
  ft_databrowser(cfg_art_browse, data_continuous);
  
cfg_muscle_epoched.continuous                   = 'no';
cfg_muscle_epoched.artfctdef.muscle.interactive = 'yes';
cfg_muscle_epoched = ft_artifact_muscle(cfg_muscle_epoched, data_epoched);

  cfg = [];
  cfg.continuous                = 'yes';
  cfg.artfctdef.eog.interactive = 'yes';

  % channel selection, cutoff and padding
  cfg.artfctdef.eog.channel     = 'EOG';
  cfg.artfctdef.eog.cutoff      = 2.5; % z-value at which to threshold (default = 4)
  cfg.artfctdef.eog.trlpadding  = 0;
  cfg.artfctdef.eog.boxcar      = 10;

  % conservative rejection intervals around EOG events
  cfg.artfctdef.eog.pretim      = 10; % pre-artifact rejection-interval in seconds
  cfg.artfctdef.eog.psttim      = 10; % post-artifact rejection-interval in seconds
  
  cfg = ft_artifact_eog(cfg, data_continuous);

  % make a copy of the samples where the EOG artifacts start and end, this is needed further down
  EOG_detected = cfg.artfctdef.eog.artifact;
  
  % replace the artifactual segments with zero
  cfg = [];
  cfg.artfctdef.muscle.artifact = EMG_detected;
  cfg.artfctdef.eog.artifact    = EOG_detected;
  cfg.artfctdef.reject          = 'value';
  cfg.artfctdef.value           = 0;
  data_continuous_clean = ft_rejectartifact(cfg, data_continuous);
  data_epoched_clean    = ft_rejectartifact(cfg, data_epoched);
  
  cfg             = [];
  cfg.continuous  = 'yes';
  cfg.viewmode    = 'vertical';
  cfg.blocksize   = 60*60*2; % view the data in blocks
  ft_databrowser(cfg, data_continuous_clean);
  
  % Estimating frequency-represetation over sleep
  
% define the EEG frequency bands of interest
freq_bands = [
  0.5  4    % slow-wave band actity
  4    8    % theta band actity
  8   11    % alpha band actity
  11  16    % spindle band actity
  ];

cfg = [];
cfg.output        = 'pow';
cfg.channel       = 'EEG';
cfg.method        = 'mtmfft';
cfg.taper         = 'hanning';
cfg.foi           = 0.5:0.5:16; % in 0.5 Hz steps
cfg.keeptrials    = 'yes';
freq_epoched = ft_freqanalysis(cfg, data_epoched_clean);

begsample = data_epoched_clean.sampleinfo(:,1);
endsample = data_epoched_clean.sampleinfo(:,2);
time      = ((begsample+endsample)/2) / data_epoched_clean.fsample;

freq_continuous           = freq_epoched;
freq_continuous.powspctrm = permute(freq_epoched.powspctrm, [2, 3, 1]);
freq_continuous.dimord    = 'chan_freq_time'; % it used to be 'rpt_chan_freq'
freq_continuous.time      = time;             % add the description of the time dimension

figure
cfg                = [];
cfg.baseline       = [min(freq_continuous.time) max(freq_continuous.time)];
cfg.baselinetype   = 'normchange';
cfg.zlim           = [-0.5 0.5];
ft_singleplotTFR(cfg, freq_continuous);

cfg                     = [];
cfg.frequency           = freq_bands(1,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_swa     = ft_selectdata(cfg, freq_continuous);

cfg                     = [];
cfg.frequency           = freq_bands(2,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_theta   = ft_selectdata(cfg, freq_continuous);

cfg                     = [];
cfg.frequency           = freq_bands(3,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_alpha   = ft_selectdata(cfg, freq_continuous);

cfg                     = [];
cfg.frequency           = freq_bands(4,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_spindle = ft_selectdata(cfg, freq_continuous);

  data_continuous_swa                  = [];
  data_continuous_swa.label            = {'swa'};
  data_continuous_swa.time{1}          = freq_continuous_swa.time;
  data_continuous_swa.trial{1}         = squeeze(freq_continuous_swa.powspctrm)';

  data_continuous_swa_spindle          = [];
  data_continuous_swa_spindle.label    = {'theta'};
  data_continuous_swa_spindle.time{1}  = freq_continuous_theta.time;
  data_continuous_swa_spindle.trial{1} = squeeze(freq_continuous_theta.powspctrm)';

  data_continuous_alpha                = [];
  data_continuous_alpha.label          = {'alpha'};
  data_continuous_alpha.time{1}        = freq_continuous_alpha.time;
  data_continuous_alpha.trial{1}       = squeeze(freq_continuous_alpha.powspctrm)';

  data_continuous_spindle              = [];
  data_continuous_spindle.label        = {'spindle'};
  data_continuous_spindle.time{1}      = freq_continuous_spindle.time;
  data_continuous_spindle.trial{1}     = squeeze(freq_continuous_spindle.powspctrm)';

  cfg = [];
  data_continuous_perband = ft_appenddata(cfg, ...
  data_continuous_swa, ...
  data_continuous_swa_spindle, ...
  data_continuous_alpha, ...
  data_continuous_spindle);

  cfg        = [];
  cfg.scale  = 100; % in percent
  cfg.demean = 'no';
  data_continuous_perband = ft_channelnormalise(cfg, data_continuous_perband);
  
  cfg        = [];
  cfg.boxcar = 300;
  data_continuous_perband = ft_preprocessing(cfg, data_continuous_perband);
  
  
  cfg             = [];
  cfg.continuous  = 'yes';
  cfg.viewmode    = 'vertical';
  cfg.blocksize   = 60*60*2; %view the whole data in blocks
  ft_databrowser(cfg, data_continuous_perband);

% Identify non-REM sleep

montage_sum          = [];
montage_sum.labelold = {'swa', 'theta', 'alpha', 'spindle'};
montage_sum.labelnew = {'swa', 'theta', 'alpha', 'spindle', 'swa+spindle'};
montage_sum.tra      = [
  1 0 0 0
  0 1 0 0
  0 0 1 0
  0 0 0 1
  1 0 0 1   % the sum of two channels
  ];

cfg = [];
cfg.montage = montage_sum;
data_continuous_perband_sum = ft_preprocessing(cfg, data_continuous_perband);

cfg = [];
cfg.continuous   = 'yes';
cfg.viewmode    = 'vertical';
cfg.blocksize   = 60*60*2; % view the whole data in blocks
ft_databrowser(cfg, data_continuous_perband_sum);

cfg = [];
cfg.artfctdef.threshold.channel   = {'swa+spindle'};
cfg.artfctdef.threshold.bpfilter  = 'no';
cfg.artfctdef.threshold.max       = nanmean(data_continuous_perband_sum.trial{1}(5,:)); % mean of the 'swa+spindle' channel
cfg = ft_artifact_threshold(cfg, data_continuous_perband_sum);

% keep the begin and end sample of each "artifact", we need it later
nonREM_detected = cfg.artfctdef.threshold.artifact;

% construct a hypnogram, Wake-0, Stage-1, Stage-2, Stage-3, Stage-4, REM-5
hypnogram = -1 * ones(1,numel(data_epoched.trial)); %initalize the vector with -1 values

%REM defined by the detected EOG activity
for i=1:size(EOG_detected,1)
    start_sample = EOG_detected(i,1);
    end_sample   = EOG_detected(i,2);
    start_epoch  = ceil((start_sample)/(30*128));
    end_epoch    = ceil((  end_sample)/(30*128));
    hypnogram(start_epoch:end_epoch) = 5; % REM
end

%Non-REM defined by EMG
for i=1:size(nonREM_detected,1)
    start_epoch = nonREM_detected(i,1);
    end_epoch   = nonREM_detected(i,2);
    hypnogram(start_epoch:end_epoch) = 2.5; % it could be any of 1, 2, 3 or 4
end

%Epochs with detected EMG artifacts are now again (re)labled as Wake
for i=1:size(EMG_detected,1)
    start_sample = EMG_detected(i,1);
    end_sample   = EMG_detected(i,2);
    start_epoch  = ceil((start_sample)/(30*128));
    end_epoch    = ceil((  end_sample)/(30*128));
    hypnogram(start_epoch:end_epoch) = 0; % wake
end

% prune the hypnogram to complete 30-sec epochs in the data
% discarding the rest at the end
number_complete_epochs = floor(data_orig.sampleinfo(2)/(30*128));
hypnogram = hypnogram(1:number_complete_epochs);

% Wake-0, Stage-1, Stage-2, Stage-3, Stage-4, REM-5, Movement Time-0.5
prescored = load([datapath filesep subjectdata.subjectdir filesep subjectdata.hypnogramfile])';

figure
plot([prescored-0.05; hypnogram+0.05]', 'LineWidth', 1); % shift them a little bit
legend({'prescored', 'hypnogram'})
ylim([-1.1 5.1]);

lab = yticklabels; %lab = get(gca,'YTickLabel'); %prior to MATLAB 2016b use this

lab(strcmp(lab, '0'))  = {'wake'};
lab(strcmp(lab, '1'))  = {'S1'};
lab(strcmp(lab, '2'))  = {'S2'};
lab(strcmp(lab, '3'))  = {'SWS'};
lab(strcmp(lab, '4'))  = {'SWS'};
lab(strcmp(lab, '5'))  = {'REM'};
lab(strcmp(lab, '-1')) = {'?'};
yticklabels(lab); %set(gca,'YTickLabel',lab) ; %prior to MATLAB 2016b use this

% View either prescored or estimated hypnogram info

artfctdef = [];
if false % can either choose true or false here to switch between presocred and estimated hypnogram
  epochs_wake   = find(prescored == 0);
  epochs_S1     = find(prescored == 1);
  epochs_S2     = find(prescored == 2);
  epochs_SWS    = find(prescored == 3 | prescored == 4);
  epochs_nonREM = find(prescored >= 1 & prescored <= 4);
  epochs_REM    = find(prescored == 5);

  artfctdef.S1.artifact      = [epochs_S1(:)   epochs_S1(:)];
  artfctdef.S2.artifact      = [epochs_S2(:)   epochs_S2(:)];
  artfctdef.SWS.artifact     = [epochs_SWS(:)  epochs_SWS(:)];
else
  epochs_wake   = find(hypnogram == 0);
  epochs_nonREM = find(hypnogram >= 1 & hypnogram <= 4);
  epochs_REM    = find(hypnogram == 5);

  artfctdef.nonREM.artifact  = [epochs_nonREM(:)  epochs_nonREM(:)];
end

% View in time-resolved spectral estimates

artfctdef.wake.artifact    = [epochs_wake(:) epochs_wake(:)];
artfctdef.REM.artifact     = [epochs_REM(:)  epochs_REM(:)];

cfg               = [];
cfg.continuous    = 'yes';
cfg.artfctdef     = artfctdef;
cfg.blocksize     = 60*60*2;
cfg.viewmode      = 'vertical';
cfg.artifactalpha = 0.7; % this make the colors less transparent and thus more vibrant
ft_databrowser(cfg, data_continuous_perband_sum);

% in the original data there are 30*128 samples per epoch
% the first epoch is from sample 1 to sample 3840, etc.
artfctdef                  = [];
artfctdef.wake.artifact    = [(epochs_wake(:)  -1)*30*128+1 (epochs_wake(:)  +0)*30*128];
%artfctdef.S1.artifact      = [(epochs_S1(:)    -1)*30*128+1 (epochs_S1(:)    +0)*30*128];
%artfctdef.S2.artifact      = [(epochs_S2(:)    -1)*30*128+1 (epochs_S2(:)    +0)*30*128];
%artfctdef.SWS.artifact     = [(epochs_SWS(:)   -1)*30*128+1 (epochs_SWS(:)   +0)*30*128];
artfctdef.nonREM.artifact  = [(epochs_nonREM(:)-1)*30*128+1 (epochs_nonREM(:)+0)*30*128];
artfctdef.REM.artifact     = [(epochs_REM(:)   -1)*30*128+1 (epochs_REM(:)   +0)*30*128];

cfg               = [];
cfg.continuous    = 'yes';
cfg.artfctdef     = artfctdef;
cfg.blocksize     = 60*60*2;
cfg.viewmode      = 'vertical';
cfg.artifactalpha = 0.7;
ft_databrowser(cfg, data_continuous);

% Event detection during sleep

%% find heart R-waves in ECG
cfg            = [];
cfg.continuous = 'yes';

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = 'ECG';
cfg.artfctdef.zvalue.cutoff      = 0.5;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfreq      = [20 45];
cfg.artfctdef.zvalue.bpfiltord   = 4;
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;
cfg.artfctdef.zvalue.artfctpeak  = 'yes'; % to get the peak of the R-wave

% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';

cfg = ft_artifact_zvalue(cfg, data_continuous);
 Rwave_peaks = cfg.artfctdef.zvalue.peaks;

% Check if detected peaks are good estimates of the R-wave

artfctdef = [];
artfctdef.rwave.artifact = [Rwave_peaks-10 Rwave_peaks+10];

cfg = [];
cfg.continuous    = 'yes';
cfg.artfctdef     = artfctdef;
cfg.blocksize     = 60;
cfg.viewmode      = 'vertical';
cfg.artifactalpha = 0.7;
ft_databrowser(cfg, data_continuous);

% Compute continuous heart rate signal

heart_rate = 60 ./ (diff(Rwave_peaks') ./ data_continuous.fsample);

% determine the time in seconds of each detected beat
heart_time = Rwave_peaks / data_continuous.fsample;

% let us place the heart rate in between the beats
heart_time = (heart_time(1:end-1) + heart_time(2:end)) / 2;

figure;
plot(heart_time, heart_rate)
xlabel('time (s)');
ylabel('heart rate (bpm)');

% Sleep spindles and slow waves in EEG

cfg        = [];
cfg.trials = (data_epoched.trialinfo >= 2  & data_epoched.trialinfo <= 4); % Only non-REM stages, but not Stage 1
data_epoched_nonREM = ft_selectdata(cfg, data_epoched);

cfg          = [];
cfg.trl(1,1) = data_continuous.sampleinfo(1);
cfg.trl(1,2) = data_continuous.sampleinfo(2);
cfg.trl(1,3) = 0;
data_continuous_nonREM = ft_redefinetrial(cfg, data_epoched_nonREM);

% replace the nans with zeros
selnan = any(isnan(data_continuous_nonREM.trial{1}), 1);
data_continuous_nonREM.trial{1}(:,selnan) = 0;

% Visualization

cfg            = [];
cfg.continuous = 'yes';
cfg.blocksize  = 60*60*2;
cfg.viewmode   = 'vertical';
ft_databrowser(cfg, data_continuous_nonREM);

% Slow-wave or sleep spindle detection in EEG

cfg            = [];
cfg.continuous = 'yes';

% channel selection and padding
cfg.artfctdef.zvalue.channel     = 'EEG';
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.1;

% cutoff and algorithmic parameters
cfg.artfctdef.zvalue.cutoff      = 1.75; % 1.75 for both slow waves and spindles
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfiltord   = 4;
cfg.artfctdef.zvalue.bpfilttype  = 'but';

if true % true for slow-waves, false for spindles
    cfg.artfctdef.zvalue.bpfreq      = [0.5 4];
else
    cfg.artfctdef.zvalue.bpfreq      = [12 15];
end

cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;
cfg.artfctdef.zvalue.artfctpeak  = 'yes'; % to get the peak of the event envelope

% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';

[cfg, ] = ft_artifact_zvalue(cfg,data_continuous_nonREM);

event_detected = cfg.artfctdef.zvalue.artifact;
event_peaks    = cfg.artfctdef.zvalue.peaks;
event_duration = (event_detected(:,2)-event_detected(:,1)+1) ./ data_continuous_nonREM.fsample;

% find slow waves/spindles only with the right duration of 0.5 to 2 seconds
duration_min       = 0.5;
duration_max       = 2;
valid_events_index = ((event_duration > duration_min) & (event_duration < duration_max));

%update our event information accodingly with the valid slow waves or sleep spindles.
event_detected     = event_detected(valid_events_index,:);
event_peaks        = event_peaks(valid_events_index);
event_duration     = event_duration(valid_events_index);

%number of events
num_events = numel(event_peaks)
%mean event duration
mean_event_duration = mean(event_duration)


%%% get the trials to get the data +-1 second around the envelope
%%% peak that we detected
cfg = [];
cfg.channel     = {'EEG'};
data_continuous_nonREM_EEG  =  ft_selectdata(cfg,data_continuous_nonREM);

% filter the data in the slow wave or spindle band to remove non-event noise
cfg.bpfilter    = 'yes';
if true % true for slow-waves, false for spindles
    cfg.bpfreq  = [0.5 4];
else
    cfg.bpfreq  = [12 15];
end
data_continuous_nonREM_EEG_event_filtered = ft_preprocessing(cfg,data_continuous_nonREM_EEG);

% redefine the trial with the offset preserving timepoint from beginning of the raw data
search_offset = data_continuous_nonREM.fsample% +-1 seconds around the center
cfg.trl = [event_peaks-search_offset event_peaks+search_offset -search_offset+event_peaks];
data_continuous_nonREM_EEG_event_filtered_temp   = ft_redefinetrial(cfg,data_continuous_nonREM_EEG_event_filtered);

% find the minimums within the trials
event_trial_minimums = cellfun(@(signal) find(signal == min(signal),1,'first'),data_continuous_nonREM_EEG_event_filtered_temp.trial);

% update the times from the time points with respect to the original raw data
event_minimum_times = event_trial_minimums;
for iTrialSpindle = 1:numel(data_continuous_nonREM_EEG_event_filtered_temp.trial)
    event_minimum_times(iTrialSpindle) = data_continuous_nonREM_EEG_event_filtered_temp.time{iTrialSpindle}(event_trial_minimums(iTrialSpindle));
end

% get the samples of the minimum sleep spindle signals (troughs)
event_minimum_samples = round(event_minimum_times*data_continuous_nonREM.fsample);

% a buffer we need to have padding left and right to make nice
% time-frequency graph later on
padding_buffer = 4*data_continuous_nonREM.fsample; % 8 seconds
cfg     = [];
cfg.trl = [event_minimum_samples'-data_continuous_nonREM.fsample-padding_buffer event_minimum_samples'+data_continuous_nonREM.fsample+padding_buffer repmat(-(data_continuous_nonREM.fsample+padding_buffer),numel(event_minimum_samples),1)];
data_continuous_nonREM_EEG_events = ft_redefinetrial(cfg,data_continuous_nonREM_EEG);

% Sanity check

figure
cfg        = [];
[timelock] = ft_timelockanalysis(cfg, data_continuous_nonREM_EEG_events);
cfg        = [];
cfg.xlim   = [-1.5 1.5];
cfg.title  = 'Non-REM event ERP time-locked to down-peak';
ft_singleplotER(cfg,timelock)

% Event related Time-Frequency

cfg               = [];
cfg.channel       = 'EEG';
cfg.method        = 'wavelet';
cfg.length        = 4;
cfg.foi           = 1:0.5:16; % 0.5 Hz steps
cfg.toi           = [(-padding_buffer-1.5):0.1:(1.5+padding_buffer)]; % 0.1 s steps
event_freq = ft_freqanalysis(cfg, data_continuous_nonREM_EEG_events);

% view the time-frequency of a slow wave or spindle event
figure
cfg                = [];
cfg.baseline       = [-1.5 1.5]; % a 3 s baseline around the event as it has no clear start or end.
cfg.baselinetype   = 'normchange';
cfg.zlim           = [-0.2 0.2];
cfg.xlim           = [-1.5 1.5];
cfg.title          = 'Event, time-frequency';
ft_singleplotTFR(cfg,event_freq);

% View detected events in original data

cfg                                 = [];
cfg.continuous                       = 'yes';
cfg.viewmode                        = 'vertical';
cfg.blocksize                       = 60; %view the data in 30-s blocks
cfg.event                           = struct('type', {}, 'sample', {});
cfg.artfctdef.event.artifact        = event_detected;
%cfg.artfctdef.slow_waves.artifact  = event_detected;
%cfg.artfctdef.spindles.artifact    = event_detected;
cfg.artfctdef.eventpeaks.artfctpeak = event_minimum_samples;
cfg.plotevents                      = 'yes';
ft_databrowser(cfg, data_continuous_nonREM);

end
