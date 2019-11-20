function varargout = uiinput(varargin)
%Show in uifigure input dialog with text edits and checkboxes
%   Allows to create input dialogs embedded in uifigures and apps
%
%   inp = UIINPUT(uifig)
%   inp = UIINPUT(uifig, label)
%   inp = UIINPUT(uifig, labels, values)
%   inp = UIINPUT(__, Name, Value)
%   h = UIINPUT(__, 'Show', false)
%
%   Inputs:
%   uifig: uifigure object or another parent UI container
%   label: char array - label of the input
%   labels: cell string | string array - labels if the inputs
%   values: cell array of chars or logicals - predefined values of
%   unputs. Edits will be drown for char values, checkboxes - for logical
%   values.
%
%   Name-value parameters:
%   'Title': char | string - title of input dialog (defalut: '')
%   'Width': double - with of input dialog (default: 200)
%   'Transparent': logical - background transparency (default: false)
%   'OkText': char | string - Text of the OK button (default: 'OK')
%   'CancelText': char | string - Text of the Cancel button (default: 'Cancel')
%   'Wait': logical - pause execution while input dialog is opened (default: true)
%   'Show': logical - open input dialog immediately (default: true)
%
%   Outputs:
%   inp: cell | char | logical - uiinput values
%   h: Input - UI.Input object
%
%   Example 1:
%       i = uiinput(uifigure, {'Enter text' 'Check'}, {'' false}, 'Width', 300);
%   Example 2:
%       h = uiinput(uifigure, 'Enter', '', 'Show', false)
%       h.Transparent = true;
%       h.CancelText = 'Close';
%       h.redraw
%       h.show
%
%   Example app: uiinputExample
%
%   Author: Pavel Roslovets, ETMC Exponenta
%           https://roslovets.github.io

showi = cellfun(@(x) (isstring(x)||ischar(x))&&strcmp(x, 'Show'), varargin);
showi = find(showi);
i = UI.Input(varargin{:});
if ~isempty(showi) && ~varargin{showi + 1}
    varargout = {i};
else
    varargout = {i.Values i.Ok};
end