function ft_ex_10_ica_remove_ecg_artifacts
% Example: Use ICA to remove ECG artifacts
%
% From: https://www.fieldtriptoolbox.org/example/use_independent_component_analysis_ica_to_remove_ecg_artifacts/

% ft_preprocessing of example dataset
cfg = [];
cfg.dataset = fullfile(ft_tut_datadir, 'ArtifactRemoval', 'ArtifactRemoval.ds');
cfg.trialdef.eventtype = 'trial';
cfg = ft_definetrial(cfg);

cfg = ft_artifact_jump(cfg);
cfg = ft_rejectartifact(cfg);
cfg.trl([3 11 23],:) = []; % quick removal of trials with muscle artifacts, works only for this dataset!

% Preprocess the data

cfg.channel            = {'MEG', 'EEG058'}; % channel 'EEG058' contains the ECG recording
cfg.continuous         = 'yes';
data = ft_preprocessing(cfg);

% split the ECG and MEG datasets, since ICA will be performed on MEG data but not on ECG channel
% 1 - ECG dataset
cfg              = [];
cfg.channel      = {'EEG'};
ecg              = ft_selectdata(cfg, data);
ecg.label{:}     = 'ECG'; % for clarity and consistency rename the label of the ECG channel
% 2 - MEG dataset
cfg              = [];
cfg.channel      = {'MEG'};
data              = ft_selectdata(cfg, data);

% Downsample or ICA will take too long

data_orig = data; %save the original data for later use
cfg            = [];
cfg.resamplefs = 150;
cfg.detrend    = 'no';
data           = ft_resampledata(cfg, data);

% Do the component analysis

cfg            = [];
cfg.method     = 'runica';
comp           = ft_componentanalysis(cfg, data);

% Examine component topology

cfg           = [];
cfg.component = [1:20];       % specify the component(s) that should be plotted
cfg.layout    = 'CTF275.lay'; % specify the layout file that should be used for plotting
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)

% Examine their time courses

cfg          = [];
cfg.channel  = [2:5 15:18]; % components to be plotted
cfg.viewmode = 'component';
cfg.layout   = 'CTF275.lay'; % specify the layout file that should be used for plotting
% ft_databrowser(cfg, comp)

% go back to the raw data on disk and detect the peaks in the ECG channel, i.e. the QRS-complex
cfg                       = [];
cfg.trl                   = data_orig.cfg.previous.trl;
cfg.dataset               = data_orig.cfg.previous.dataset;
cfg.continuous            = 'yes';
cfg.artfctdef.ecg.pretim  = 0.25;
cfg.artfctdef.ecg.psttim  = 0.50-1/1200;
cfg.channel               = {'ECG'};
cfg.artfctdef.ecg.inspect = {'ECG'};
[cfg, artifact]           = ft_artifact_ecg(cfg, ecg);

% Go on with the analysis

% preproces the data around the QRS-complex, i.e. read the segments of raw data containing the ECG artifact
cfg            = [];
cfg.dataset    = data_orig.cfg.previous.dataset;
cfg.continuous = 'yes';
cfg.padding    = 10;
cfg.dftfilter  = 'yes';
cfg.demean     = 'yes';
cfg.trl        = [artifact zeros(size(artifact,1),1)];
cfg.channel    = {'MEG'};
data_ecg       = ft_preprocessing(cfg);
cfg.channel    = {'EEG058'};
ecg            = ft_preprocessing(cfg);
ecg.channel{:} = 'ECG'; % renaming is purely for clarity and consistency

% resample to speed up the decomposition and frequency analysis, especially usefull for 1200Hz MEG data
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
data_ecg       = ft_resampledata(cfg, data_ecg);
ecg            = ft_resampledata(cfg, ecg);

% decompose the ECG-locked datasegments into components, using the previously found (un)mixing matrix
cfg           = [];
cfg.unmixing  = comp.unmixing;
cfg.topolabel = comp.topolabel;
comp_ecg      = ft_componentanalysis(cfg, data_ecg);

% append the ecg channel to the data structure;
comp_ecg      = ft_appenddata([], ecg, comp_ecg);

% average the components timelocked to the QRS-complex
cfg           = [];
timelock      = ft_timelockanalysis(cfg, comp_ecg);

% look at the timelocked/averaged components and compare them with the ECG
figure
subplot(2,1,1); plot(timelock.time, timelock.avg(1,:))
subplot(2,1,2); plot(timelock.time, timelock.avg(2:end,:))
figure
subplot(2,1,1); plot(timelock.time, timelock.avg(1,:))
subplot(2,1,2); imagesc(timelock.avg(2:end,:));

% Second method: calculate coherence of component analysis with heartbeat

% compute a frequency decomposition of all components and the ECG
cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'fourier';
cfg.foilim     = [0 100];
cfg.taper      = 'hanning';
cfg.pad        = 'maxperlen';
freq           = ft_freqanalysis(cfg, comp_ecg);

% compute coherence between all components and the ECG
cfg            = [];
cfg.channelcmb = {'all' 'ECG'};
cfg.jackknife  = 'no';
cfg.method     = 'coh';
fdcomp         = ft_connectivityanalysis(cfg, freq);

% look at the coherence spectrum between all components and the ECG
figure;
subplot(2,1,1); plot(fdcomp.freq, abs(fdcomp.cohspctrm));
subplot(2,1,2); imagesc(abs(fdcomp.cohspctrm));

% decompose the original data as it was prior to downsampling to 150Hz
cfg           = [];
cfg.unmixing  = comp.unmixing;
cfg.topolabel = comp.topolabel;
comp_orig     = ft_componentanalysis(cfg, data_orig);

% the original data can now be reconstructed, excluding those components
cfg           = [];
cfg.component = [4 17];
data_clean    = ft_rejectcomponent(cfg, comp_orig, data_orig);

end
