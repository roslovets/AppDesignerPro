classdef ListController < handle
    %% Create autoupdating interactive list
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        ItemsController
        ItemsDataController
        ValueController
        Selection
    end

    methods

        function obj = ListController(opts)
            %% Initialize object
            arguments
                opts.Items = []
                opts.ItemsObject = []
                opts.ItemsProperty (1,1) string = missing
                opts.ItemsReadFcn = []
                opts.ItemsWriteFcn = []
                opts.ItemsData = []
                opts.ItemsDataObject = []
                opts.ItemsDataProperty (1,1) string = missing
                opts.ItemsDataReadFcn = []
                opts.ItemsDataWriteFcn = []
                opts.Value = []
                opts.ValueObject = []
                opts.ValueProperty (1,1) string = missing
                opts.ValueReadFcn = []
                opts.ValueWriteFcn = []
            end
            obj.ItemsController = UI.util.DataController( ...
                Data=opts.Items, ...
                DataObject=opts.ItemsObject, DataProperty=opts.ItemsProperty, ...
                DataReadFcn = opts.ItemsReadFcn, DataWriteFcn = opts.ItemsWriteFcn ...
                );
            obj.ItemsDataController = UI.util.DataController( ...
                Data=opts.ItemsData, ...
                DataObject=opts.ItemsDataObject, DataProperty=opts.ItemsDataProperty, ...
                DataReadFcn = opts.ItemsDataReadFcn, DataWriteFcn = opts.ItemsDataWriteFcn ...
                );
            obj.ValueController = UI.util.DataController( ...
                Data=opts.Value, ...
                DataObject=opts.ValueObject, DataProperty=opts.ValueProperty, ...
                DataReadFcn = opts.ValueReadFcn, DataWriteFcn = opts.ValueWriteFcn ...
                );
            obj.setItemsWithData(obj.getItems(), obj.getItemsData(), Value=obj.getValue());
        end

        function sel = get.Selection(obj)
            %% Selection getter
            sel = obj.getSelection();
        end

        function items = getItems(obj)
            %% Get List Items
            items = obj.ItemsController.readData();
        end

        function itemsData = getItemsData(obj)
            %% Get List Items
            itemsData = obj.ItemsDataController.readData();
        end

        function value = getValue(obj)
            %% Get List value
            value = obj.ValueController.readData();
        end

        function idx = getValueIdx(obj, value, itemsList)
            %% Get item index by value
            arguments
                obj
                value (:,1)
                itemsList = obj.getValues()
            end
            if ~isempty(itemsList)
                if ~isempty(value) && any(ismember(value, itemsList))
                    idx = find(ismember(itemsList, value));
                    %idx = idx(1);
                else
                    idx = 0;
                end
            else
                idx = 0;
            end
        end

        function sel = getSelection(obj)
            %% Get current selection
            value = obj.getValue();
            sel = obj.getValueIdx(value);
        end

        function item = getItem(obj)
            %% Get current item
            sel = obj.getSelection();
            items = obj.getItems();
            if sel > 0
                item = items(sel);
            else
                item = [];
            end
        end

        function itemData = getItemData(obj)
            %% Get current item data
            sel = obj.getSelection();
            itemsData = obj.getItemsData();
            if sel > 0 && ~isempty(itemsData)
                itemData = itemsData(sel);
            else
                itemData = [];
            end
        end

        function values = getValues(obj)
            %% Get List values
            values = obj.getItemsData();
            if isempty(values)
                values = obj.getItems();
            end
        end

        function obj = setItemsWithData(obj, items, itemsData, opts)
            %% Set List items
            arguments
                obj
                items (:,1)
                itemsData (:,1)
                opts.Value = []
            end
            obj.setItems(items);
            obj.setItemsData(itemsData);
            obj.select(opts.Value);
        end

        function obj = setItems(obj, items)
            %% Set List items
            obj.ItemsController.writeData(items(:));
        end

        function obj = setItemsData(obj, itemsData)
            %% Set List items data
            obj.ItemsDataController.writeData(itemsData(:));
        end

        function setValue(obj, value)
            %% Get List value
            obj.ValueController.writeData(value);
        end

        function obj = select(obj, value)
            %% Select item by value
            values = obj.getValues();
            idx = obj.getValueIdx(value);
            if idx > 0
                value = values(idx);
            elseif ~isempty(values)
                value = values(1);
            else
                value = [];
            end
            obj.setValue(value);
        end

        function obj = selectItem(obj, item)
            %% Select item by name
            items = obj.getItems();
            values = obj.getValues();
            idx = obj.getValueIdx(item, items);
            if idx > 0
                value = values(idx);
            else
                value = [];
            end
            obj.select(value);
        end

        function obj = selectIdx(obj, idx)
            %% Select item dy index
            arguments
                obj
                idx
            end
            values = obj.getValues();
            if ~isempty(values)
                idx(idx < 1) = 1;
                idx(idx > length(values)) = length(values);
                idx = unique(idx);
                value = values(idx);
            else
                value = [];
            end
            obj.select(value);
        end

        function obj = addItem(obj, item, itemData)
            %% Add new items to List
            arguments
                obj
                item
                itemData = []
            end
            items = obj.getItems();
            itemsData = obj.getItemsData();
            items = [items; item];
            itemsData = [itemsData; itemData];
            value = obj.getValue();
            obj.setItemsWithData(items, itemsData, Value=value);
        end

        function obj = replace(obj, newItem, newItemData)
            %% Replace Item
            arguments
                obj
                newItem
                newItemData = []
            end
            sel = obj.getSelection();
            if sel > 0
                items = obj.getItems();
                items(sel) = newItem;
                obj.setItems(items);
                if ~isempty(newItemData)
                    itemsData = obj.getItemsData();
                    itemsData(sel) = newItemData;
                    obj.setItemsData(itemsData);
                end
                obj.selectIdx(sel);
            end
        end

        function obj = deleteItem(obj)
            %% Delete item from List
            sel = obj.getSelection();
            if sel > 0
                items = obj.getItems();
                if ~isempty(items)
                    items(sel) = [];
                end
                itemsData = obj.getItemsData();
                if ~isempty(itemsData)
                    itemsData(sel) = [];
                end
                obj.setItemsWithData(items, itemsData);
                obj.selectIdx(sel);
            end
        end

        function obj = moveUp(obj)
            %% Move Item one step up
            obj.moveItem(-1);
        end

        function obj = moveDown(obj)
            %% Move Item one step down
            obj.moveItem(1);
        end

        function isI = isItem(obj, item)
            %% Check Item exists
            items = obj.getItems();
            isI = ismember(item, items);
        end

        function isSel = isSelected(obj, item)
            %% Check Value is selected
            sel = obj.getSelection();
            value = obj.getValue();
            isSel = (sel > 0 & item == value);
        end

    end

    methods (Access=protected)

        function obj = moveItem(obj, dir)
            %% Move Item by step
            sel = obj.getSelection();
            if sel > 0
                items = obj.getItems();
                itemsData = obj.getItemsData();
                [items, ~, selNew] = obj.moveRow(items, sel, dir);
                if ~isempty(itemsData)
                    itemsData = obj.moveRow(itemsData, sel, dir);
                end
                obj.setItemsWithData(items, itemsData);
                obj.selectIdx(selNew);
            end
        end

        function [data, idx1, idx2] = moveRow(~, data, idx1, dir)
            %% Move row in data from idx1 for step
            if ~isempty(data)
                n = size(data, 1);
                if islogical(idx1)
                    idx1 = find(idx1);
                end
                idx1 = idx1(:);
                idx2 = idx1 + sign(dir);
                idx2(idx2 < 1) = idx2(idx2 < 1) + n;
                idx2(idx2 > n) = idx2(idx2 > n) - n;
                if dir > 0
                    [~, iSort] = sort(idx1, 1, "descend");
                else
                    [~, iSort] = sort(idx1, 1, "ascend");
                end
                idx1Sort = idx1(iSort);
                idx2Sort = idx2(iSort);
                for i = 1 : length(idx1Sort)
                    idx1i = idx1Sort(i);
                    idx2i = idx2Sort(i);
                    if dir < 0
                        if idx2i <= idx1i
                            data([idx1i; idx2i], :) = data([idx2i; idx1i], :);
                        else
                            data = data([(idx1i+1 : end)'; idx1i], :);
                            break;
                        end
                    elseif dir > 0
                        if idx1i <= idx2i
                            data([idx1i; idx2i], :) = data([idx2i; idx1i], :);
                        else
                            data = data([idx1i; (1 : idx1i-1)'], :);
                            break;
                        end
                    end
                end
            end
        end

    end

end
