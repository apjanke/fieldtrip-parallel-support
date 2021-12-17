function ft_tut_09_automatic_artifact_rejection
% Tutorial: Automatic artifact rejection
%
% From: https://www.fieldtriptoolbox.org/tutorial/automatic_artifact_rejection/

% Define our trial

cfg                    = [];
cfg.dataset            = fullfile(ft_tut_datadir, 'ArtifactMEG.ds');
cfg.headerformat       = 'ctf_ds';
cfg.dataformat         = 'ctf_ds';
cfg.trialdef.eventtype = 'trial';
cfg                    = ft_definetrial(cfg);
trl                    = cfg.trl(1:50,:); % we'll only use the first 50 trials for this example

% Jump artifact detection

% jump
cfg = [];
cfg.trl = trl;
cfg.datafile = fullfile(ft_tut_datadir, 'ArtifactMEG.ds');
cfg.headerfile = fullfile(ft_tut_datadir, 'ArtifactMEG.ds');
cfg.continuous = 'yes';

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = 'MEG';
cfg.artfctdef.zvalue.cutoff = 20;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;

% algorithmic parameters
cfg.artfctdef.zvalue.cumulative = 'yes';
cfg.artfctdef.zvalue.medianfilter = 'yes';
cfg.artfctdef.zvalue.medianfiltord = 9;
cfg.artfctdef.zvalue.absdiff = 'yes';

% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';

[cfg, artifact_jump] = ft_artifact_zvalue(cfg);

% Detection of muscle artifacts

% muscle
cfg            = [];
cfg.trl        = trl;
cfg.datafile   = fullfile(ft_tut_datadir, 'ArtifactMEG.ds');
cfg.headerfile = fullfile(ft_tut_datadir, 'ArtifactMEG.ds');
cfg.continuous = 'yes';

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel      = 'MRT*';
cfg.artfctdef.zvalue.cutoff       = 4;
cfg.artfctdef.zvalue.trlpadding   = 0;
cfg.artfctdef.zvalue.fltpadding   = 0;
cfg.artfctdef.zvalue.artpadding   = 0.1;

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter     = 'yes';
cfg.artfctdef.zvalue.bpfreq       = [110 140];
cfg.artfctdef.zvalue.bpfiltord    = 9;
cfg.artfctdef.zvalue.bpfilttype   = 'but';
cfg.artfctdef.zvalue.hilbert      = 'yes';
cfg.artfctdef.zvalue.boxcar       = 0.2;

% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';

[cfg, artifact_muscle] = ft_artifact_zvalue(cfg);

% Detection of EOG artifacts

 % EOG
 cfg            = [];
 cfg.trl        = trl;
 cfg.datafile   = fullfile(ft_tut_datadir, 'ArtifactMEG.ds');
 cfg.headerfile = fullfile(ft_tut_datadir, 'ArtifactMEG.ds');
 cfg.continuous = 'yes';

 % channel selection, cutoff and padding
 cfg.artfctdef.zvalue.channel     = 'EOG';
 cfg.artfctdef.zvalue.cutoff      = 4;
 cfg.artfctdef.zvalue.trlpadding  = 0;
 cfg.artfctdef.zvalue.artpadding  = 0.1;
 cfg.artfctdef.zvalue.fltpadding  = 0;

 % algorithmic parameters
 cfg.artfctdef.zvalue.bpfilter   = 'yes';
 cfg.artfctdef.zvalue.bpfilttype = 'but';
 cfg.artfctdef.zvalue.bpfreq     = [2 15];
 cfg.artfctdef.zvalue.bpfiltord  = 4;
 cfg.artfctdef.zvalue.hilbert    = 'yes';

 % feedback
 cfg.artfctdef.zvalue.interactive = 'yes';

 [cfg, artifact_EOG] = ft_artifact_zvalue(cfg);
end