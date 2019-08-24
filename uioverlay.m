function h = uioverlay(varargin)
% Show empty dialog panel in uifigure
%   Allows to create custom dialogs embedded in uifigures and apps
%
%   h = UIOVERLAY(uifig)
%   h = UIOVERLAY(__, Name, Value)
%   h = UIOVERLAY(__, 'Show', false)
%
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
%   Example 1:
%       i = uiinput(uifigure, {'Enter text' 'Check'}, {'' false}, 'Width', 300);
%   Example 2:
%       h = uiinput(uifigure, 'Enter', '', 'Show', false)
%       h.Transparent = true;
%       h.CancelText = 'Close';
%       h.redraw
%       h.show
%
%   Author: Pavel Roslovets, ETMC Exponenta
%           https://roslovets.github.io

h = UI.Overlay(varargin{:});