function ft_ex_11_ica_remove_eog_artifacts
% Example: Use ICA to remove EOG artifacts
%
% From: https://www.fieldtriptoolbox.org/example/use_independent_component_analysis_ica_to_remove_eog_artifacts/

% preprocessing of example dataset
cfg = [];
cfg.dataset            = fullfile(ft_tut_datadir, 'ArtifactMEG', 'ArtifactMEG.ds');
cfg.trialdef.eventtype = 'trial';
cfg = ft_definetrial(cfg);

cfg.channel            = 'MEG';
cfg.continuous         = 'yes';
data = ft_preprocessing(cfg);

% downsample the data to speed up the next step
cfg = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
data = ft_resampledata(cfg, data);

% ICA decomposition

% perform the independent component analysis (i.e., decompose the data)
cfg        = [];
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB

comp = ft_componentanalysis(cfg, data);

% Identify the artifacts

% plot the components for visual inspection
figure
cfg = [];
cfg.component = 1:20;       % specify the component(s) that should be plotted
cfg.layout    = 'CTF151.lay'; % specify the layout file that should be used for plotting
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)

% Further inspection of the time course of components

cfg = [];
cfg.layout = 'CTF151.lay'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
% ft_databrowser(cfg, comp)

% Remove the artifacts
% remove the bad components and backproject the data
cfg = [];
cfg.component = [9 10 14 24]; % to be removed component(s)
data = ft_rejectcomponent(cfg, comp, data);



end