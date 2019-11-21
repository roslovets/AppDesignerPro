classdef ReactiveList < UI.Reactive
    %% Create autoupdating reactive list strongly binded with data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io
    
    properties
        Selection
        GUIValue
        ItemsData
        DefaultItemName = "Item"
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
        
        function select(obj, varargin)
            %% Select item
            obj.redrawValue(varargin{:});
        end
        
        function val = getValue(obj, event)
            %% Get selected value
            if nargin > 1
                guiObj = event.Source;
            else
                guiObj = obj.GUI(1);
            end
            val = guiObj.Value;
        end
        
        function [items, vals] = getValues(obj, event)
            %% Get all values
            if nargin > 1
                guiObj = event.Source;
            else
                guiObj = obj.GUI(1);
            end
            vals = get(guiObj, 'ItemsData');
            items = get(guiObj, 'Items');
        end
        
        function setValues(obj, items, vals, event)
            %% Get all values
            if nargin > 3
                guiObj = event.Source;
            else
                guiObj = obj.GUI(1);
            end
            if ~isempty(guiObj.ItemsData)
                obj.setData(vals);
            end
            obj.writeData(items);
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
            obj.redrawValue();
        end
        
        function redrawValue(obj, varargin)
            %% Redraw Value GUI
            if ~isempty(obj.GUIValue)
                for i = 1 : height(obj.GUIValue)
                    obj.GUIValue.GUIReact(i).redraw();
                end
            end
            value = obj.getValue(varargin{:});
            guiN = length(obj.GUI);
            if ~isempty(value) && guiN > 1
                for i = 1 : guiN
                    set(obj.GUI(i), 'Value', value);
                end
            end
        end
        
        function addItem(obj, item, dataValue)
            %% Add new items to List
            data = obj.readData();
            data = string(data);
            data = data(:);
            if nargin < 2 || isempty(item)
                [idx, item] = UI.Utils.genUniqueIdx(data, obj.DefaultItemName);
            else
                item = string(item);
                item = item(:);
            end
            data = [data; item];
            obj.writeData(data);
            if ~isempty(obj.ItemsData)
                d = obj.ItemsData.readData{1};
                d = d(:);
                if nargin < 3
                    dataValue = idx;
                end
                d = [d; dataValue];
                obj.setData(d);
            end
            obj.redraw();
        end
        
        function deleteItem(obj, val)
            %% Delete row from Table
            if nargin < 2
                val = obj.getValue();
            end
            if ~isempty(val)
                [items, values] = obj.getValues();
                if ischar(val) || iscellstr(val)
                    val = string(val);
                end
                if ~isempty(values)
                    idx = find(values == val);
                    values(idx) = [];
                else
                    idx = find(items == val);
                end
                items(idx) = [];
                obj.setValues(items, values);
                obj.redraw();
                obj.redrawValue();
            end
        end
        
        function moveItem(obj, step)
            %% Move Item by step
            value = obj.getValue();
            if ~isempty(value)
                data = obj.readData();
                data = data(:);
                idx1 = data == value;
                data = UI.internal.moveRow(data, idx1, step);
                obj.writeData(data);
                obj.redraw();
                obj.select();
            end
        end
        
        function moveItemUp(obj)
            %% Move Item one step up
            obj.moveItem(-1);
        end
        
        function moveItemDown(obj)
            %% Move Item one step down
            obj.moveItem(1);
        end
        
        function yes = isItem(obj, item)
            %% Check Item exists
            data = obj.readData();
            yes = ismember(item, data);
        end
        
        
    end
end

