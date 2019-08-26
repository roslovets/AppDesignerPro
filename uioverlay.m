function [ov, h] = uioverlay(varargin)
% Show empty dialog panel in uifigure
%   Allows to create custom dialogs embedded in uifigures and apps
%
%   ov = UIOVERLAY(uifig)
%   ov = UIOVERLAY(__, Name, Value)
%   ov = UIOVERLAY(__, 'Show', false)
%   [ov, h] = UIOVERLAY(__)
%
%   Inputs:
%   uifig: uifigure object or another parent UI container
%
%   Name-value parameters:
%   'Title': char | string - title of overlay panel (defalut: '')
%   'Width': double - with of overlay panel (default: 200)
%   'Height': double - height of overlay panel (default: 100)
%   'BackGroundColor': 3x1 double | 'none' - background color (default: gray)
%   'Show': logical - show overlay panel immediately (default: true)
%
%   Outputs:
%   ov: Overlay - UI.Overlay object
%   h: Panel - uipanel for overlay content
%
%   Example 1:
%       [ov, h] = uioverlay;
%       but = uibutton(h);
%       uialign(but, h, 'center', 'center', true);
%   Example 2:
%       [ov, h] = uioverlay(uifigure, 'Title', 'Overlay Panel', 'Width', 300,...
%               'Height', 200, 'BackgroundColor', 'none');
%       h.BackgroundColor = 'white';
%       h.FontSize = 20;
%       
%
%   Author: Pavel Roslovets, ETMC Exponenta
%           https://roslovets.github.io

ov = UI.Overlay(varargin{:});
h = ov.UIPanel;