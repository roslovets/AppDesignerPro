classdef UIController < handle
    %% Bind UI components to data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        UI % UI Component
        UIProperty (:,1) string % Property of UI component to control
    end

    properties (Hidden)
        DataController % Data Controller object
        ConvRules % How to convert data between types
    end

    methods

        function obj = UIController(opts)
            %% Initialize object
            arguments
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
                opts.UI = []
                opts.UIProperty (:,1) string = "Value"
            end
            obj.createConvRules();
            obj.bindData( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn ...
                )
            obj.UIProperty = opts.UIProperty;
            obj.bindUI(opts.UI);
        end

        function bindData(obj, opts)
            %% Bind data or data source to controller
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.DataController = UI.util.DataController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn ...
                );
        end

        function bindUI(obj, component)
            %% Bind UI components to controller
            arguments
                obj
            end
            arguments (Repeating)
                component
            end
            components = horzcat(component{:});
            data = obj.getData();
            for i = 1 : length(components)
                uiComp = components(i);
                if isnumeric(uiComp)
                    uiComp = findobj(uiComp);
                end
                if ~ismember(uiComp, obj.UI)
                    obj.UI = [obj.UI; uiComp];
                    uiProp = obj.getUIProperty(i);
                    value = uiComp.(uiProp);
                    if isempty(data) && ~isempty(value)
                        data = obj.setData(value);
                    end
                end
            end
            obj.redrawUI();
        end

        function unbindUI(obj, component)
            %% Unbind UI components from controller
            arguments
                obj
            end
            arguments (Repeating)
                component
            end
            components = horzcat(component{:});
            idx = ismember(obj.UI, components);
            obj.UI(idx) = [];
            obj.redrawUI();
        end

        function update(obj, event)
            %% Update value on UI component event
            arguments
                obj
                event = []
            end
            if isempty(event)
                idx = 1;
            else
                idx = find(obj.UI == event.Source);
            end
            value = obj.readData();
            if ~isempty(idx)
                uiComp = obj.UI(idx(1));
                uiProp = obj.getUIProperty(idx(1));
                uiClass = class(uiComp);
                switch uiClass
                    case "matlab.ui.control.TextArea"
                        if uiProp == "Value"
                            value = join(string(uiComp.(uiProp)), newline);
                        end
                        value = obj.convert(value, class(value));
                    otherwise
                        value = obj.convert(uiComp.(uiProp), class(value));
                end
                obj.writeData(value);
            end
            obj.redrawUI();
        end

        function data = getData(obj)
            %% Get data from controller
            data = obj.readData();
        end

        function uiProp = getUIProperty(obj, idx)
            %% Get UI property name for binded component
            arguments
                obj
                idx (1,1) double = NaN;
            end
            if isnan(idx) || length(obj.UIProperty) == 1
                idx = 1;
            end
            uiProp = obj.UIProperty(idx);
        end

        function data = setData(obj, data)
            %% Set data to controller
            obj.writeData(data);
            obj.redrawUI();
        end

        function redrawUI(obj)
            %% Redraw UI components
            data = obj.readData();
            for i = 1 : length(obj.UI)
                uiComp = obj.UI(i);
                uiProp = obj.getUIProperty(i);
                value = obj.convert(data, class(get(uiComp, uiProp)));
                if isprop(uiComp, 'Limits')
                    limits = get(uiComp, 'Limits');
                    if isempty(value) || (isnumeric(value) && isnan(value)) || (isdatetime(value) && isnat(value))
                        value = limits(1);
                    elseif value < limits(1)
                        value = limits(1);
                    elseif value > limits(2)
                        value = limits(2);
                    end
                end
                if isempty(value)
                    if islogical(value)
                        value = false;
                    elseif ischar(value)
                        value = '';
                    end
                end
                if uiProp == "Value"
                    if iscellstr(value) || ischar(value)
                        value = string(value);
                    elseif iscell(value)
                        value = vertcat(value{:});
                    end
                    if length(value) > 1 && (~isprop(uiComp, "Multiselect") || uiComp.Multiselect == false)
                        value = value(1);
                    end
                end
                set(uiComp, uiProp, value);
            end
        end

        function isE = isEmpty(obj)
            %% Controller is empty
            isE = isempty(obj.UI) && obj.DataController.isEmpty();
        end

    end

    methods (Access=protected)

        function value = readData(obj)
            %% Read data from source
            value = obj.DataController.readData();
        end

        function writeData(obj, value)
            %% Write data to source
            obj.DataController.writeData(value);
        end

        function createConvRules(obj)
            %% Initialize data conversion rules
            types = {'double' 'char' 'cell' 'datetime' 'table' 'logical' 'struct' 'function_handle' 'categorical' 'string'};
            functions = {
                [] @num2str @num2cell @datetime @array2table @logical [] [] @categorical @string
                @str2double [] @cellstr @datetime [] @(x)any(logical(x)) [] @str2fun @categorical @string
                @cell2mat @char [] @datetime @cell2table [] @cell2struct [] @categorical @string
                @datenum @char @cellstr [] [] [] [] [] [] @string
                @table2array [] @table2cell [] [] [] @table2struct [] [] []
                @double [] @num2cell [] [] [] [] [] @categorical @string
                [] [] @struct2cell [] @struct2table [] [] [] [] []
                [] @func2str [] [] [] [] [] [] [] []
                @double @char @cellstr [] [] [] [] [] [] @string
                @double @char @cellstr [] [] [] [] [] [] @string
                };
            obj.ConvRules = cell2table(functions, 'VariableNames', types, 'RowNames', types);
        end

        function data = convert(obj, data, to)
            %% Convert data between formats
            arguments
                obj
                data
                to (1,1) string
            end
            if ~isempty(to)
                from = class(data);
                if ~strcmp(from, to) && to ~= "matlab.lang.OnOffSwitchState"
                    conv = obj.ConvRules{from, to}{1};
                    if isempty(conv)
                        error('Unsupported conversion from %s to %s', from, to);
                    end
                    if isstring(data) && all(ismissing(data) | data == "<missing>")
                        data = "";
                    end
                    data = conv(data);
                end
            end
        end

    end

end
