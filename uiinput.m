function [val, ok] = uiinput(varargin)
%UIINPUT Summary of this function goes here
%   Detailed explanation goes here
i = UI.Input(varargin{:});
i.show();
val = i.Value;
ok = i.Ok;