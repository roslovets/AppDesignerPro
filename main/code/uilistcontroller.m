function c = uilistcontroller(opts)
%Reactive UI List
%   Binds items data from list with UI elements
%   Documentation is under development, please examine examples: uiexample
%
%   Example app: uireactivelistExample
arguments
    opts.Items = []
    opts.ItemsObject = []
    opts.ItemsProperty (1,1) string = missing
    opts.ItemsReadFcn = []
    opts.ItemsWriteFcn = []
    opts.ItemsUI = []
    opts.ItemsData = []
    opts.ItemsDataObject = []
    opts.ItemsDataProperty (1,1) string = missing
    opts.ItemsDataReadFcn = []
    opts.ItemsDataWriteFcn = []
    opts.ItemsDataUI = []
    opts.Value = []
    opts.ValueObject = []
    opts.ValueProperty (1,1) string = missing
    opts.ValueReadFcn = []
    opts.ValueWriteFcn = []
    opts.ValueUI = []
    opts.State = []
    opts.StateObject = []
    opts.StateProperty (1,1) string = missing
    opts.StateWriteFcn = []
    opts.StateUI = []
    opts.StateUIProperty (:,1) string = "Enable"
    opts.Item = []
    opts.ItemObject = []
    opts.ItemProperty (1,1) string = missing
    opts.ItemReadFcn = []
    opts.ItemWriteFcn = []
    opts.ItemUI = []
end
args = namedargs2cell(opts);
c = UI.UIListController(args{:});
