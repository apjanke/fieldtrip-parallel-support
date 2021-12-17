function out = ft_tut_workshopdir(newval)
% Path to the workshop example data source directory.
%
% out = ft_tut_workshopdir
% ft_tut_workshopdir(newval)
%
% Call this with one argument to set the data directory. Call it with no
% arguments to get the current value. Errors if you call it to get the
% value without having previously set it in this Matlab session.

% Store it in appdata so it can survive a `clear classes`.

appdataName = 'ft_tut_workshopdir';
if nargin == 0
    theDir = getappdata(0, appdataName);
    if isempty(theDir)
        error('ft_tut_workshopdir has not been set yet');
    end
    out = theDir;
else
    setappdata(0, appdataName, newval);
end
