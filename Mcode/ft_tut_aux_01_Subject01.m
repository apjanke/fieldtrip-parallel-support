% script ft_tut_aux_01_Subject01.m
% Intended for eval-ing inside ft_tut_02_clean_analysis_script

% ensure that we don't mix up subjects
clear subjectdata

% define the filenames, parameters and other information that is subject specific
subjectdata.subjectdir        = fullfile(ft_tut_datadir, 'Subject01');
subjectdata.datadir           = 'mtw05a_1200hz_20090819_04_600Hz.ds';
subjectdata.subjectnr         = '01';
subjectdata.MRI               = '01_mri';
subjectdata.badtrials         = [1 3]; % subject made a mistake on the first and third trial

% more information can be added to this script when needed
% ...