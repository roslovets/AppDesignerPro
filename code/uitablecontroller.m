function c = uitablecontroller(opts)
%UI Table Controller
%   Binds table data with UI elements
%   Documentation is under development, please examine examples: uiexample
%
%   Example app: uireactivetableExample
arguments
    opts.Data = []
    opts.DataObject = []
    opts.DataProperty (1,1) string = ""
    opts.DataReadFcn = []
    opts.DataWriteFcn = []
    opts.UI = []
end
c = UI.TableController( ...
    Data=opts.Data, ...
    DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
    DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
    UI=opts.UI ...
    );
