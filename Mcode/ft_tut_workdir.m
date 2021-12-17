function out = ft_tut_workdir(newval)
% Path to the tutorial working data directory.
%
% out = ft_tut_workdir
% ft_tut_workdir(newval)
%
% The working data directory is a directory that the tutorial functions can
% write data in to. It should be a directory devoted exclusively to that
% use. It is not the same as the source data directory defined by
% ft_tut_datadir.
%
% Call this with one argument to set the working data directory. Call it with no
% arguments to get the current value. Errors if you call it to get the
% value without having previously set it in this Matlab session.

% Store it in appdata so it can survive a `clear classes`.

appdataName = 'ft_tut_workdir';
if nargin == 0
    theDir = getappdata(0, appdataName);
    if isempty(theDir)
        error('ft_tut_workdir has not been set yet');
    end
    out = theDir;
else
    setappdata(0, appdataName, newval);
end
