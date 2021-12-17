function ft_tut_01
%

cfg = [];
cfg.dataset     = 'SubjectEEG/subj2.vhdr';
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

end