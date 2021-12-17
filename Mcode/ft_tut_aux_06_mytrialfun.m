function trl = ft_tut_aux_06_mytrialfun(cfg)
% Auxiliary trial definition function for Tutorial 6
%
% This function requires the following fields to be specified:
%
% cfg.dataset
% cfg.trialdef.eventtype
% cfg.trialdef.eventvalue
% cfg.trialdef.prestim
% cfg.trialdef.poststim

hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

trl = [];

for i=1:length(event)
if strcmp(event(i).type, cfg.trialdef.eventtype)
  % it is a trigger, see whether it has the right value
  if ismember(event(i).value, cfg.trialdef.eventvalue)
    % add this to the trl definition
    begsample     = event(i).sample - cfg.trialdef.prestim*hdr.Fs;
    endsample     = event(i).sample + cfg.trialdef.poststim*hdr.Fs - 1;
    offset        = -cfg.trialdef.prestim*hdr.Fs;
    trigger       = event(i).value; % remember the trigger (=condition) for each trial
    if isempty(trl)
      prevtrigger = nan;
    else
      prevtrigger   = trl(end, 4); % the condition of the previous trial
    end
    trl(end+1, :) = [round([begsample endsample offset])  trigger prevtrigger];
  end
end
end

samecondition = trl(:,4)==trl(:,5); % find out which trials were preceded by a trial of the same condition
trl(samecondition,:) = []; % delete those trials

end
