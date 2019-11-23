classdef ReactiveList < UI.Reactive
    %% Create autoupdating reactive list strongly binded with data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io
    
    properties
        Selection
        GUIValue
        ItemsDataReact
        DefaultItemName = "Item"
    end
    
    methods
        function obj = ReactiveList(varargin)
            %% GUI Reactive List
            obj = obj@UI.Reactive(varargin{:});
        end
        
        function redraw(obj)
            %% Redraw List
            items = obj.getValues();
            for i = 1 : length(obj.GUI)
                guiObj = obj.GUI(i);
                set(guiObj, 'Items', items);
            end
        end
        
        function update(obj, items)
            %% Update List items
            obj.setItems(items);
            obj.redraw();
            obj.redrawValue();
        end
        
        function select(obj, value)
            %% Select item
            if nargin < 2
                value = [];
            end
            obj.redrawValue(value);
        end
        
        function selectPrevious(obj, items, data, items_i, data_i)
            %% Select previous value
            if isempty(data)
                idx = items_i;
                values = items;
            else
                idx = data_i;
                values = data;
            end
            i = min([idx; length(values)]);
            if i > 0
                obj.select(values(i));
            end
        end
        
        function val = getValue(obj, event)
            %% Get selected value
            if nargin > 1 && ~isempty(event)
                guiObj = event.Source;
            else
                guiObj = obj.GUI(1);
            end
            val = guiObj.Value;
        end
        
        function [items, data] = getValues(obj)
            %% Get all values
            if ~isempty(obj.ItemsDataReact)
                data = obj.ItemsDataReact.readData{1};
                data = data(:);
            else
                data = [];
            end
            items = obj.readData();
            items = string(items);
            items = items(:);
        end
        
        function setValues(obj, items, data)
            %% Set values
            obj.setItems(items);
            if nargin > 2
                obj.setItemsData(data);
            end
        end
        
        function setItems(obj, items)
            %% Set List Items
            obj.writeData(items);
        end
        
        function setItemsData(obj, varargin)
            %% Set Items Data to List
            obj.ItemsDataReact = UI.Reactive(varargin);
            [~, data] = obj.getValues();
            for i = 1 : length(obj.GUI)
                guiObj = obj.GUI(i);
                set(guiObj, 'ItemsData', data);
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
        
        function redrawValue(obj, event)
            %% Redraw Value GUI
            if nargin < 2
                event = [];
            end
            if isempty(event) || UI.Utils.iseventdata(event)
                value = obj.getValue(event);
            else
                value = event;
            end
            guiN = length(obj.GUI);
            if ~isempty(value) && guiN > 1
                for i = 1 : guiN
                    if ~UI.Utils.iseventdata(event) || (event.Source ~= obj.GUI(i))
                        set(obj.GUI(i), 'Value', value);
                    end
                end
            end
            if ~isempty(obj.GUIValue)
                for i = 1 : height(obj.GUIValue)
                    obj.GUIValue.GUIReact(i).redraw(event);
                end
            end
        end
        
        function addItem(obj, item, dataValue)
            %% Add new items to List
            items = obj.getValues();
            items = string(items);
            items = items(:);
            if nargin < 2 || isempty(item)
                [idx, item] = UI.Utils.genUniqueIdx(items, obj.DefaultItemName);
            else
                item = string(item);
                item = item(:);
            end
            items = [items; item];
            obj.setItems(items);
            if ~isempty(obj.ItemsDataReact)
                [~, data] = obj.getValues();
                if ~isempty(data)
                    if nargin < 3
                        dataValue = idx;
                    end
                    data = [data; dataValue];
                    obj.setItemsData(data);
                end
            end
            obj.redraw();
        end
        
        function deleteItem(obj, val)
            %% Delete row from Table
            if nargin < 2
                val = obj.getValue();
            end
            if ~isempty(val)
                [items, data] = obj.getValues();
                [items_i, data_i] = getValueIdx(obj, val);
                items(items_i) = [];
                data(data_i) = [];
                obj.setValues(items, data);
                obj.selectPrevious(items, data, items_i, data_i);
                obj.redraw();
            end
        end
        
        function moveItem(obj, step)
            %% Move Item by step
            value = obj.getValue();
            if ~isempty(value)
                [items, data] = obj.getValues();
                [items_i, data_i] = getValueIdx(obj, value);
                items = UI.internal.moveRow(items, items_i, step);
                data = UI.internal.moveRow(data, data_i, step);
                obj.setValues(items, data);
                obj.redraw();
                obj.redrawValue();
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
            items = obj.getValues();
            yes = ismember(item, items);
        end
        
        function [items_i, data_i] = getValueIdx(obj, val)
            %% Get indices of specified value
            if nargin < 2
                val = obj.getValue();
            end
            if ~isempty(val)
                [items, data] = obj.getValues();
                if ischar(val) || iscellstr(val)
                    val = string(val);
                end
                if ~isempty(data)
                    data_i = find(ismember(data, val));
                    items_i = data_i;
                else
                    data_i = [];
                    items_i = find(ismember(items, val));
                end
            end
        end
        
        
    end
    
end

