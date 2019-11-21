classdef ReactiveList < UI.Reactive
    %% Create autoupdating reactive list strongly binded with data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io
    
    properties
        Selection
        GUIValue
        ItemsData
    end
    
    methods
        function obj = ReactiveList(varargin)
            %% GUI Reactive List
            obj = obj@UI.Reactive(varargin{:});
        end
        
        function redraw(obj)
            %% Redraw List
            items = obj.readData();
            for i = 1 : length(obj.GUI)
                guiObj = obj.GUI(i);
                set(guiObj, 'Items', items);
            end
        end
        
        function update(obj, items)
            %% Update List items
            obj.writeData(items);
            obj.redraw();
            obj.redrawValue();
        end
        
        function select(obj)
            %% Select item
            obj.redrawValue();
        end
        
        function val = getValue(obj)
            %% Get selected value
            val = obj.GUI(1).Value;
        end
        
        function setData(obj, varargin)
            %% Set Items Data to List
            obj.ItemsData = UI.Reactive(varargin);
            data = obj.ItemsData.readData();
            for i = 1 : length(obj.GUI)
                guiObj = obj.GUI(i);
                set(guiObj, 'ItemsData', data{1});
            end
        end
        
        function bindValue(obj, guiobj)
            %% Bind table variable to GUI object
            if isempty(obj.GUIValue)
                obj.GUIValue = cell2table(cell(0, 2), 'VariableNames', {'GUIObj' 'GUIReact'});
            end
            guireact = UI.Reactive(obj.GUI, 'Value', 'Value');
            guireact.bind(guiobj);
            obj.GUIValue = [obj.GUIValue; {guiobj guireact}];
        end
        
        function updateValue(obj, event)
            %% Update List value from GUI
            if ~isempty(obj.GUIValue)
                idx = find(obj.GUIValue.GUIObj == event.Source);
                if ~isempty(idx)
                    obj.GUIValue.GUIReact(idx(1)).update();
                end
            end
        end
        
        function redrawValue(obj)
            %% Redraw Value GUI
            if ~isempty(obj.GUIValue)
                for i = 1 : height(obj.GUIValue)
                    obj.GUIValue.GUIReact(i).redraw();
                end
            end
        end
        
        function newRow(obj, varargin)
            %% Add new row to Table
            data = obj.readData();
            if istable(data) && ~isempty(data.Properties.VariableNames)
                newrow = repmat({''}, 1, width(data));
                for i = 1 : length(newrow)
                    newrow{i} = obj.convert(newrow{i}, obj.getVarType(i));
                end
                data = [data; newrow];
                if ~isempty(varargin)
                    for i = 1 : 2 : length(varargin)
                        var = varargin{i};
                        value = varargin{i+1};
                        data{end, var} = obj.convert(value, obj.getVarType(var));
                    end
                end
            else
                data = struct2table(struct(varargin{:}), 'AsArray', true);
            end
            obj.writeData(data);
            obj.redraw();
            obj.select([height(data) 1]);
        end
        
        function deleteRow(obj, rownum)
            %% Delete row from Table
            if nargin < 2
                if ~isempty(obj.Selection)
                    rownum = obj.Selection.Row;
                else
                    rownum = [];
                end
            end
            if ~isempty(rownum)
                data = obj.readData();
                if rownum <= height(data)
                    data(rownum, :) = [];
                    obj.writeData(data);
                    obj.redraw();
                end
            end
        end
        
        function moveRow(obj, step)
            %% Move row by step
            if ~isempty(obj.Selection)
                data = obj.readData();
                n = height(data);
                idx1 = obj.Selection.Row;
                idx2 = obj.Selection.Row + step;
                if idx2 < 1
                    idx2 = n;
                elseif idx2 > n
                    idx2 = 1;
                end
                if idx1 == 1 && idx2 == n
                    data = data([2 : end, 1], :);
                elseif idx1 == n && idx2 == 1
                    data = data([end, 1 : end-1], :);
                else
                    data([idx1 idx2], :) = data([idx2 idx1], :);
                end
                obj.writeData(data);
                obj.redraw();
                obj.Selection.Row = idx2;
            end
        end
        
        function moveRowUp(obj)
            %% Move row one step up
            obj.moveRow(-1);
        end
        
        function moveRowDown(obj)
            %% Move row one step down
            obj.moveRow(1);
        end
        
        
    end
end

