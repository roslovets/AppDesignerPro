function uidoc()
% Open App Designer Pro documentation
cdir = fileparts(mfilename("fullpath"));
web(fullfile(cdir, '../doc/GettingStarted.html'));