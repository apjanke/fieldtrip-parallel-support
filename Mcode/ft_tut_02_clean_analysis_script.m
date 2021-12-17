function ft_tut_02_clean_analysis_script
% Tutorial: Creating a clean analysis script
%
% From: https://www.fieldtriptoolbox.org/tutorial/scripting/
%
% This is currently broken because the Subject1.zip file on the FTP site
% (ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/) doesn't contain
% a mtw05a_1200hz_20090819_04_600Hz.ds directory, which is referenced by
% the Subjectm script from the example code in the tutorial. I'm not sure
% how to fix that. -apj
%
% Also it can't find the specified trialfun:
%   "the specified trialfun 'motormirror_trialfun' was not found"
% The code comment says it's in "/Scripts", but there's no /Scripts in the
% FieldTrip repo.

do_preprocess_MM('ft_tut_aux_01_Subject01');

end

function do_preprocess_MM(Subjectm)

cfg = [];
if nargin == 0
  disp('Not enough input arguments');
  return;
end
eval(Subjectm);
outputdir = fullfile(ft_tut_workdir, 'AnalysisM');

%%% define trials
cfg.dataset             = [subjectdata.subjectdir filesep subjectdata.datadir];
cfg.trialdef.eventtype  = 'frontpanel trigger';
cfg.trialdef.prestim  = 1.5;
cfg.trialdef.poststim  = 1.5;
%cfg.continuous    = 'no';
cfg.lpfilter    = 'no';
cfg.continuous    = 'yes';
cfg.trialfun    = 'motormirror_trialfun';   % located in \Scripts
cfg.channel    = 'MEG';
cfg.layout    = 'EEG1020.lay';
cfg       = ft_definetrial(cfg);

%%% if there are visual artifacts already in subject m-file use those. They will show up in databrowser
try
  cfg.artfctdef.eog.artifact = subjectdata.visualartifacts;
catch
end

%%% visual detection of jumps etc
cfg.continuous   = 'yes';
cfg.blocksize   = 20;
cfg.eventfile   = [];
cfg.viewmode   = 'butterfly';
cfg     = ft_databrowser(cfg);

%%% enter visually detected artifacts in subject m-file;
fid = fopen([subjectdata.mfiledir filesep Subjectm '.m'],'At');
fprintf(fid,'\n%s\n',['%%% Entered @ ' datestr(now)]);
fprintf(fid,'%s',['subjectdata.visualartifacts = [ ' ]);
if isempty(cfg.artfctdef.visual.artifact) == 0
  for i = 1 : size(cfg.artfctdef.visual.artifact,1)
    fprintf(fid,'%u%s%u%s',cfg.artfctdef.visual.artifact(i,1),' ',cfg.artfctdef.visual.artifact(i,2),';');
  end
end

fprintf(fid,'%s\n',[ ' ]; ']);
fclose all;

%%% reject artifacts
cfg.artfctdef.reject = 'complete';
cfg = ft_rejectartifact(cfg);

%%% make directory, if needed, to save all analysis data
if exist(outputdir) == 0
  mkdir(outputdir)
end

%%% Preprocess and SAVE
dataM = ft_preprocessing(cfg);
save([outputdir filesep subjectdata.subjectnr '_preproc_dataM'],'dataM','-V7.3')

end