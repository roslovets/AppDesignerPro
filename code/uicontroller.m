function c = uicontroller(opts)
%UI Controller
%   Binds data with UI components
%   Documentation is under development, please examine examples: uiexamples
%
%   Example app: uireactiveExample
arguments
    opts.Data = []
    opts.DataObject = []
    opts.DataProperty (1,1) string = missing
    opts.DataReadFcn = []
    opts.DataWriteFcn = []
    opts.UI = []
end
c = UI.Controller( ...
    Data=opts.Data, ...
    DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
    DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
    UI=opts.UI ...
    );
