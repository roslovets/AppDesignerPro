function s = uisnackbar(varargin)
%UIINPUT Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;
addOptional(p, 'uifig', []);
addOptional(p, 'msg', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'Theme', '');
addParameter(p, 'Time', 3);
parse(p, varargin{:});
if isempty(p.Results.uifig)
    uifig = uifigure;
else
    uifig = p.Results.uifig;
end
s = GUISnackbar(uifig, p.Results.msg);
if ~isempty(p.Results.Theme)
    s.Theme = p.Results.Theme;
end
s.Time = p.Results.Time;
s.show();