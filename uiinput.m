function varargout = uiinput(varargin)
%UIINPUT Summary of this function goes here
%   Detailed explanation goes here
showi = cellfun(@(x) (isstring(x)||ischar(x))&&strcmp(x, 'Show'), varargin);
showi = find(showi);
i = UI.Input(varargin{:});
if ~isempty(showi) && ~varargin{showi+1}
    varargout = {i};
else
    varargout = {i.Values i.Ok};
end