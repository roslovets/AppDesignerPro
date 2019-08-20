classdef Reactive < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Source
        GUI
        Reader
        Writer
    end
    
    properties (Hidden)
        ConvRules
    end
    
    methods
        function obj = Reactive(source, reader, writer)
            %% Create new reactive element
            obj.Source = source;
            if nargin > 1 && ~isempty(reader)
                obj.Reader = reader;
            end
            if nargin > 2 && ~isempty(writer)
                obj.Writer = writer;
            end
            obj.createConvRules();
        end
        
        function data = readData(obj)
            %% Read data from source
            if ~isempty(obj.Reader)
                if class(obj.Reader) == "function_handle"
                    data = obj.Reader();
                else
                    data = obj.Source.(obj.Reader);
                end
            else
                data = obj.Source;
            end
        end
        
        function writeData(obj, data)
            %% Write data into source
            if ~isempty(obj.Writer)
                if class(obj.Writer) == "function_handle"
                    obj.Writer(data);
                else
                    obj.Source.(obj.Writer) = data;
                end
            else
                obj.Source = data;
            end
        end
        
        function bind(obj, varargin)
            %% Bind GUI object to source
            for i = 1 : length(varargin)
                guiobj = varargin{i};
                if isnumeric(guiobj)
                    guiobj = findobj(guiobj);
                end
                if ~ismember(guiobj, obj.GUI)
                    obj.GUI = [obj.GUI; guiobj];
                end
            end
            obj.redraw();
        end
        
        function unbind(obj, varargin)
            %% Unbind GUI object from source
            idx = ismember(obj.GUI, [varargin{:}]);
            obj.GUI(idx) = [];
            obj.redraw();
        end
        
        function redraw(obj)
            %% Redraw GUI
            data = obj.readData();
            for i = 1 : length(obj.GUI)
                guiObj = obj.GUI(i);
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
                        if ischar(value) && isempty(value)
                            value = '';
                        end
                        set(guiObj, 'Value', value);
                end
            end
        end
        
        function update(obj, event)
            %% Edit Table data from GUI
            if nargin < 2
                idx = 1;
            else
                idx = find(obj.GUI == event.Source);
            end
            data = obj.readData();
            if ~isempty(idx)
                guiObj = obj.GUI(idx(1));
                guiClass = class(guiObj);
                switch guiClass
                    case "matlab.ui.control.Table"
                        data = obj.convert(guiObj.Data, class(data));
                    case "matlab.ui.control.TextArea"
                        txt = join(string(guiObj.Value), newline);
                        data = obj.convert(txt, class(data));
                    otherwise
                        data = obj.convert(guiObj.Value, class(data));
                end
                obj.writeData(data);
            end
            obj.redraw();
        end
        
        function createConvRules(obj)
            %% Init conversion rules
            VARS = {'double' 'char' 'cell' 'datetime' 'table' 'logical' 'struct' 'function_handle' 'categorical' 'string'};
            RULES = {
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
            obj.ConvRules = cell2table(RULES, 'VariableNames', VARS, 'RowNames', VARS);
        end
        
        function data = convert(obj, data, to)
            %% Get variable type
            if ~isempty(to)
                from = class(data);
                if ~strcmp(from, to)
                    conv = obj.ConvRules{from, to}{1};
                    if isempty(conv)
                        error('Unsupported conversion from %s to %s', from, to);
                    end
                    if isstring(data) && (ismissing(data) || data == "<missing>")
                        data = "";
                    end
                    data = conv(data);
                end
            end
        end
        
    end
end