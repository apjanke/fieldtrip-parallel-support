function ft_tut_05_reading_continuous
% Tutorial: Preprocessing - Reading continuous EEG and MEG data
%
% From: https://www.fieldtriptoolbox.org/tutorial/continuous/

% Read continuous EEG data in to memory

cfg = [];
cfg.dataset = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
data_eeg    = ft_preprocessing(cfg)

% Plot the potential in one of the channels

chansel = 1;
figure;
plot(data_eeg.time{1}, data_eeg.trial{1}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
legend(data_eeg.label(chansel))

% Read continuous MEG data into memory

cfg = [];
cfg.dataset     = fullfile(ft_tut_datadir, 'Subject01', 'Subject01.ds');
data_meg        = ft_preprocessing(cfg)

% Plot data in a subset of trials

for trialsel=1:10
  chansel = 1; % this is the STIM channel that contains the trigger
  figure;
  plot(data_meg.time{trialsel}, data_meg.trial{trialsel}(chansel, :))
  xlabel('time (s)')
  ylabel('channel amplitude (a.u.)')
  title(sprintf('trial %d', trialsel));
end

% Force epoched data to be interpreted as continuous

cfg = [];
cfg.dataset     = fullfile(ft_tut_datadir, 'Subject01', 'Subject01.ds');
cfg.continuous  = 'yes';              % force it to be continuous
data_meg        = ft_preprocessing(cfg)

chansel = 2;                          % this is SCLK01
figure
plot(data_meg.time{1}, data_meg.trial{1}(chansel, :))
xlabel('time (s)')
ylabel(data_meg.label{chansel})

% Filtering and re-referencing

cfg = [];
cfg.dataset     = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
cfg.reref       = 'yes';
cfg.channel     = 'all';
cfg.implicitref = 'M1';         % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel  = {'M1', '53'}; % the average of these two is used as the new reference, channel '53' corresponds to the right mastoid (M2)
data_eeg        = ft_preprocessing(cfg);

chanindx = find(strcmp(data_eeg.label, '53'));
data_eeg.label{chanindx} = 'M2';

cfg = [];
cfg.channel     = [1:61 65];                      % keep channels 1 to 61 and the newly inserted M1 channel
data_eeg        = ft_preprocessing(cfg, data_eeg);

figure
plot(data_eeg.time{1}, data_eeg.trial{1}(1:3,:));
legend(data_eeg.label(1:3));

% Read data for the horizontal EOG

cfg = [];
cfg.dataset    = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
cfg.channel    = {'51', '60'};
cfg.reref      = 'yes';
cfg.refchannel = '51';
data_eogh      = ft_preprocessing(cfg);

% Confirm that channel 51 is referenced to itself

figure
plot(data_eogh.time{1}, data_eogh.trial{1}(1,:));
hold on
plot(data_eogh.time{1}, data_eogh.trial{1}(2,:),'g');
legend({'51' '60'});

% Rename channel 60 to EOGH, for convenience

data_eogh.label{2} = 'EOGH';

cfg = [];
cfg.channel = 'EOGH';
data_eogh   = ft_preprocessing(cfg, data_eogh); % nothing will be done, only the selection of the interesting channel

% Similar processing for the vertical EOG

cfg = [];
cfg.dataset    = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
cfg.channel    = {'50', '64'};
cfg.reref      = 'yes';
cfg.refchannel = '50';
data_eogv      = ft_preprocessing(cfg);

data_eogv.label{2} = 'EOGV';

cfg = [];
cfg.channel = 'EOGV';
data_eogv   = ft_preprocessing(cfg, data_eogv); % nothing will be done, only the selection of the interesting channel

% Combine the three raw structures into a single representation

cfg = [];
data_all = ft_appenddata(cfg, data_eeg, data_eogh, data_eogv);

% Segmenting continuous data into trials

cfg = [];
cfg.dataset             = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
cfg.trialdef.eventtype  = '?';
dummy                   = ft_definetrial(cfg);

% Select trials for animals and tools

cfg = [];
cfg.dataset             = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
cfg.trialdef.eventtype  = 'Stimulus';
cfg.trialdef.eventvalue = {'S111', 'S121', 'S131', 'S141'};
cfg_vis_animal          = ft_definetrial(cfg);

cfg.trialdef.eventvalue = {'S151', 'S161', 'S171', 'S181'};
cfg_vis_tool            = ft_definetrial(cfg);

data_vis_animal = ft_redefinetrial(cfg_vis_animal, data_all);
data_vis_tool   = ft_redefinetrial(cfg_vis_tool,   data_all);

% Segmenting continuous data into one-second pieces

cfg = [];
cfg.dataset              = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
cfg.trialfun             = 'ft_trialfun_general';
cfg.trialdef.triallength = 1;                      % duration in seconds
cfg.trialdef.ntrials     = inf;                    % number of trials, inf results in as many as possible
cfg                      = ft_definetrial(cfg);

% read the data from disk and segment it into 1-second pieces
data_segmented           = ft_preprocessing(cfg);

% read it from disk as a single continuous segment and then segment it
cfg = [];
cfg.dataset              = fullfile(ft_tut_datadir, 'SubjectEEG', 'subj2.vhdr');
data_cont                = ft_preprocessing(cfg);

cfg = [];
cfg.length               = 1;
data_segmented           = ft_redefinetrial(cfg, data_cont);

end
