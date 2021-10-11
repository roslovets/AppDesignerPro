classdef Controller < handle
    %% Bind UI components to data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        UI
    end

    properties (Hidden)
        ConvRules
        Data
        DataObject = []
        DataProperty (1,1) string = ""
        DataReadFcn
        DataWriteFcn
    end

    methods

        function obj = Controller(opts)
            %% Initialize object
            arguments
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = ""
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
                opts.UI = []
            end
            obj.createConvRules();
            obj.bindData(Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn);
            obj.bindUI(opts.UI);
        end

        function bindData(obj, opts)
            %% Bind data or data source to controller
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = ""
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.Data = opts.Data;
            obj.DataObject = opts.DataObject;
            obj.DataProperty = opts.DataProperty;
            obj.DataReadFcn = opts.DataReadFcn;
            obj.DataWriteFcn = opts.DataWriteFcn;
        end

        function bindUI(obj, component)
            %% Bind UI components to controller
            arguments
                obj
            end
            arguments (Repeating)
                component
            end
            component = horzcat(component{:});
            for i = 1 : length(component)
                guiobj = component(i);
                if isnumeric(guiobj)
                    guiobj = findobj(guiobj);
                end
                if ~ismember(guiobj, obj.UI)
                    obj.UI = [obj.UI; guiobj];
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
            idx = ismember(obj.UI, [component{:}]);
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
                guiObj = obj.UI(idx(1));
                guiClass = class(guiObj);
                switch guiClass
                    case "matlab.ui.control.Table"
                        value = obj.convert(guiObj.Data, class(value));
                    case "matlab.ui.control.TextArea"
                        txt = join(string(guiObj.Value), newline);
                        value = obj.convert(txt, class(value));
                    otherwise
                        value = obj.convert(guiObj.Value, class(value));
                end
                obj.writeData(value);
            end
            obj.redrawUI();
        end

        function data = getData(obj)
            %% Get data from controller
            data = obj.readData();
        end

        function setData(obj, data)
            %% Set data to controller
            obj.writeData(data);
            obj.redrawUI();
        end

        function redrawUI(obj)
            %% Redraw UI components
            data = obj.readData();
            for i = 1 : length(obj.UI)
                guiObj = obj.UI(i);
                guiClass = class(guiObj);
                switch guiClass
                    case "matlab.ui.control.Table"
                        set(guiObj, 'Data', data);
                        if istable(data)
                            set(guiObj, 'ColumnName', data.Properties.VariableNames);
                        end
                    case "matlab.ui.control.TextArea"
                        value = obj.convert(data, class(get(guiObj, 'Value')));
                        if isempty(value)
                            value = '';
                        end
                        set(guiObj, 'Value', value);
                    otherwise
                        value = obj.convert(data, class(get(guiObj, 'Value')));
                        if isprop(guiObj, 'Limits')
                            limits = get(guiObj, 'Limits');
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
                        set(guiObj, 'Value', value);
                end
            end
        end

    end

    methods (Access=protected)

        function value = readData(obj)
            %% Read data from source
            if ~isempty(obj.DataReadFcn)
                value = obj.DataReadFcn();
            elseif obj.DataProperty ~= ""
                value = obj.DataObject.(obj.DataProperty);
            else
                value = obj.Data;
            end
        end

        function writeData(obj, value)
            %% Write data to source
            if ~isempty(obj.DataWriteFcn)
                obj.DataWriteFcn(value);
            elseif obj.DataProperty ~= ""
                obj.DataObject.(obj.DataProperty) = value;
            else
                obj.Data = value;
            end
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
            if ~isempty(to)
                from = class(data);
                if ~strcmp(from, to)
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
