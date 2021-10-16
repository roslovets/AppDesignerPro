classdef UIListController < handle
    %% Create autoupdating interactive UI list strongly binded with data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        ListController
        ItemsUIController
        ItemsDataUIController
        ValueUIController
        StateUIController
        ItemUIController
    end

    methods
        function obj = UIListController(opts)
            %% Initialize object
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
            obj.ListController = UI.util.ListController( ...
                Items=opts.Items, ...
                ItemsObject=opts.ItemsObject, ItemsProperty=opts.ItemsProperty, ...
                ItemsReadFcn = opts.ItemsReadFcn, ItemsWriteFcn = opts.ItemsWriteFcn, ...
                ItemsData=opts.ItemsData, ...
                ItemsDataObject=opts.ItemsDataObject, ItemsDataProperty=opts.ItemsDataProperty, ...
                ItemsDataReadFcn = opts.ItemsDataReadFcn, ItemsDataWriteFcn = opts.ItemsDataWriteFcn, ...
                Value=opts.Value, ...
                ValueObject=opts.ValueObject, ValueProperty=opts.ValueProperty, ...
                ValueReadFcn = opts.ValueReadFcn, ValueWriteFcn = opts.ValueWriteFcn, ...
                State=opts.State, ...
                StateObject=opts.StateObject, StateProperty=opts.StateProperty, ...
                StateWriteFcn = opts.StateWriteFcn ...
                );
            obj.bindItems( ...
                DataReadFcn=@()obj.ListController.getItems(), ...
                DataWriteFcn=@(x)obj.ListController.setItems(x) ...
                );
            obj.bindItemsData( ...
                DataReadFcn=@()obj.ListController.getItemsData(), ...
                DataWriteFcn=@(x)obj.ListController.setItemsData(x) ...
                );
            obj.bindValue( ...
                DataReadFcn=@()obj.ListController.getValue(), ...
                DataWriteFcn=@(x)obj.ListController.select(x) ...
                );
            obj.bindState( ...
                DataReadFcn=@()obj.ListController.getState(), ...
                UIProperty=opts.StateUIProperty ...
                );
            obj.bindItem( ...
                DataReadFcn=@()obj.ListController.getItem(), ...
                DataWriteFcn=@(x)obj.ListController.selectItem(x) ...
                );
            obj.ItemsUIController.bindUI(opts.ItemsUI);
            obj.ItemsDataUIController.bindUI(opts.ItemsDataUI);
            obj.ValueUIController.bindUI(opts.ValueUI);
            obj.StateUIController.bindUI(opts.StateUI);
            obj.ItemUIController.bindUI(opts.ItemUI);
        end

        function bindItems(obj, opts)
            %% Bind List items
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.ItemsUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
                UIProperty='Items' ...
                );
        end

        function bindItemsData(obj, opts)
            %% Bind List items data
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.ItemsDataUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
                UIProperty='ItemsData' ...
                );
        end

        function bindValue(obj, opts)
            %% Bind List value
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.ValueUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn ...
                );
        end

        function bindState(obj, opts)
            %% Bind List state
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.UIProperty = []
            end
            obj.StateUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, ...
                UIProperty=opts.UIProperty ...
                );
        end

        function bindItem(obj, opts)
            %% Bind List item
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.ItemUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn ...
                );
        end

        function bindItemsUI(obj, component)
            %% Bind List items to UI component
            obj.ItemsUIController.bindUI(component);
        end

        function bindItemsDataUI(obj, component)
            %% Bind List items data to UI component
            obj.ItemsDataUIController.bindUI(component);
        end

        function redrawUI(obj)
            %% Redraw List
            obj.ItemsUIController.redrawUI();
            obj.ItemsDataUIController.redrawUI();
            obj.ValueUIController.redrawUI();
            obj.StateUIController.redrawUI();
            obj.ItemUIController.redrawUI();
        end

        function bindValueUI(obj, component)
            %% Bind List value to UI component
            obj.ValueUIController.bindUI(component);
        end

        function select(obj, value)
            %% Select item by value
            obj.ListController.select(value);
            obj.ValueUIController.redrawUI();
        end

        function selectItem(obj, item)
            %% Select item by name
            arguments
                obj
                item (1,1) string
            end
            obj.ListController.selectItem(item);
            obj.ValueUIController.redrawUI();
        end

        function value = getValue(obj)
            %% Get List value
            value = obj.ListController.getValue();
        end

        function item = getItem(obj)
            %% Get selected Item
            item = obj.ListController.getItem();
        end

        function items = getItems(obj)
            %% Get List Items
            items = obj.ListController.getItems();
        end

        function itemsData = getItemsData(obj)
            %% Get List Items Data
            itemsData = obj.ListController.getItemsData();
        end

        function values = getValues(obj)
            %% Get all values
            values = obj.ListController.getValues();
        end

        function updateValue(obj, event)
            %% Update List value from UI
            arguments
                obj
                event = []
            end
            obj.ValueUIController.update(event);
            obj.ItemUIController.update(event);
        end

        function updateItems(obj, event)
            %% Update List items from UI
            arguments
                obj
                event = []
            end
            obj.ItemsUIController.update(event)
        end

        function addItem(obj, item, itemData)
            %% Add new items to List
            arguments
                obj
                item = []
                itemData = []
            end
            items = obj.getItems();
            items = string(items);
            items = items(:);
            [newItem, newIdx] = UI.util.generateItem(items);
            if isempty(item)
                item = newItem;
            end
            if obj.ItemsDataUIController.isEmpty()
                itemData = [];
            elseif isempty(itemData)
                itemData = newIdx;
            end
            obj.ListController.addItem(item, itemData);
            obj.redrawUI();
        end

        function deleteItem(obj)
            %% Delete item from List
            obj.ListController.deleteItem();
            obj.redrawUI();
        end

        function moveItemUp(obj)
            %% Move Item one step up
            obj.ListController.moveUp();
            obj.redrawUI();
        end

        function moveItemDown(obj)
            %% Move Item one step down
            obj.ListController.moveDown();
            obj.redrawUI();
        end

        function renameItem(obj, newItem)
            %% Rename selected Item
            arguments
                obj
                newItem (1,1) string
            end
            obj.ListController.replace(newItem);
            obj.redrawUI();
        end

    end

end
