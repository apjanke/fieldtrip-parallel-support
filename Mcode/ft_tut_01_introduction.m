function ft_tut_01_introduction
% Tutorial 01: Introduction
%
% From https://www.fieldtriptoolbox.org/tutorial/introduction/

cfg1                         = [];
cfg1.dataset                 = fullfile(ft_tut_datadir, 'Subject01', 'Subject01.ds');
cfg1.trialdef.eventtype      = 'backpanel trigger';
cfg1.trialdef.eventvalue     = 3; % the value of the stimulus trigger for fully incongruent (FIC).
cfg1.trialdef.prestim        = 1;
cfg1.trialdef.poststim       = 2;

cfg1         = ft_definetrial(cfg1);
dataPrepro   = ft_preprocessing(cfg1);

cfg2         = [];
dataTimelock = ft_timelockanalysis(cfg2,dataPrepro);

end

