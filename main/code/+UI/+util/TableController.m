classdef TableController < handle
    %% Create autoupdating interactive table
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        DataController
        SelectionController
        ValueController
        SelectionType = "cell"
    end

    methods

        function obj = TableController(opts)
            %% Initialize object
            arguments
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
                opts.Selection = []
                opts.SelectionObject = []
                opts.SelectionProperty (1,1) string = missing
                opts.SelectionReadFcn = []
                opts.SelectionWriteFcn = []
                opts.Value = []
                opts.ValueObject = []
                opts.ValueProperty (1,1) string = missing
                opts.ValueReadFcn = []
                opts.ValueWriteFcn = []
            end
            obj.DataController = UI.util.DataController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn = opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn ...
                );
            obj.SelectionController = UI.util.DataController( ...
                Data=opts.Selection, ...
                DataObject=opts.SelectionObject, DataProperty=opts.SelectionProperty, ...
                DataReadFcn = opts.SelectionReadFcn, DataWriteFcn = opts.SelectionWriteFcn ...
                );
            obj.ValueController = UI.util.DataController( ...
                Data=opts.Value, ...
                DataObject=opts.ValueObject, DataProperty=opts.ValueProperty, ...
                DataReadFcn = opts.ValueReadFcn, DataWriteFcn = opts.ValueWriteFcn ...
                );
        end

        function data = getData(obj)
            %% Get Table data
            data = obj.DataController.readData();
        end

        function selection = getSelection(obj)
            %% Get Table selection
            selection = obj.SelectionController.readData();
        end

        function value = getValue(obj)
            %% Get Table value
            data = obj.getData();
            sel = obj.getSelection();
            if ~isempty(sel)
                if obj.SelectionType == "cell"
                    if height(sel) == 1
                        value = data{sel(1), sel(2)};
                    else
                        value = data(unique(sel(:,1)), unique(sel(:,2)));
                    end
                else
                    value = [];
                end
            else
                value = [];
            end
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

        function obj = setData(obj, data)
            %% Set Table data
            arguments
                obj
                data table
            end
            obj.DataController.writeData(data);
        end

        function obj = setSelection(obj, sel)
            %% Set Table selection
            obj.SelectionController.writeData(sel);
        end

        function setValue(obj, value)
            %% Get List value
            data = obj.getData();
            sel = obj.getSelection();
            if obj.SelectionType == "cell"
                if height(sel) == 1
                    data{sel(1), sel(2)} = value;
                else
                    data{unique(sel(:,1)), unique(sel(:,2))} = value;
                end
            else
                value = [];
            end
            obj.setData(data);
            obj.ValueController.writeData(value);
        end

        function obj = select(obj, sel)
            %% Select Table section by indices
            data = obj.getData();
            if ~isempty(sel)
                if obj.SelectionType == "cell"
                    sel(sel(:,1) > height(data), 1) = height(data);
                    sel(sel(:,1) <= 0, :) = [];
                    sel = unique(sel, 'rows');
                end
                obj.setSelection(sel);
            end
        end

        function obj = addRow(obj, values)
            %% Add new row to Table
            arguments
                obj
                values cell
            end
            data = obj.getData();
            data = [data; values];
            obj.setData(data);
        end

        function obj = deleteRow(obj)
            %% Delete rows from Data
            sel = obj.getSelection();
            data = obj.getData();
            if ~isempty(sel) && ~isempty(data)
                rowN = obj.getRowNum();
                data(rowN, :) = [];
                obj.setData(data);
                obj.select(sel);
            end
        end

        function obj = moveRowUp(obj)
            %% Move Item one step up
            obj.moveRow(-1);
        end

        function obj = moveRowDown(obj)
            %% Move Item one step down
            obj.moveRow(1);
        end

        function rowsN = getRowNum(obj)
            %% Get selected rows number
            sel = obj.getSelection();
            if ~isempty(sel)
                if obj.SelectionType == "cell"
                    rowsN = unique(sel(:,1));
                end
            else
                rowsN = [];
            end
        end

    end

    methods (Access=protected)

        function obj = moveRow(obj, dir)
            %% Move Table row in specified direction
            sel = obj.getSelection();
            data = obj.getData();
            if ~isempty(sel) && ~isempty(data)
                iRow = obj.getRowNum();
                [data, ~, iRowNew] = UI.util.moveRows(data, iRow, dir);
                obj.setData(data);
                if obj.SelectionType == "cell"
                    selNew = sel;
                    for i = 1 : length(iRow)
                        selNew(sel(:,1) == iRow(i), 1) = iRowNew(i);
                    end
                    sel = selNew;
                end
                obj.setData(data);
                obj.setSelection(sel);
            end
        end

    end

end
