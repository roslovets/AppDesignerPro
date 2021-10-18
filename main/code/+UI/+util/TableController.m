classdef TableController < handle
    %% Create autoupdating interactive table
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        DataController
        SelectionController
        ValueController
        SelectionType (1,1) string
        ValueType (1,1) string
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
                opts.SelectionType (1,1) string  ...
                    {mustBeMember(opts.SelectionType,["cell","row","column"])} = "cell"
                opts.Value = []
                opts.ValueObject = []
                opts.ValueProperty (1,1) string = missing
                opts.ValueReadFcn = []
                opts.ValueWriteFcn = []
                opts.ValueType (1,1) string  ...
                    {mustBeMember(opts.ValueType,["table","cell","raw"])} = "raw"
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
            obj.SelectionType = opts.SelectionType;
            obj.ValueType = opts.ValueType;
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
            if obj.SelectionType == "cell"
                value = obj.getCell();
            elseif obj.SelectionType == "row"
                value = obj.getRow();
            elseif obj.SelectionType == "column"
                value = obj.getColumn();
            else
                value = [];
            end
            if ~isempty(value)
                if obj.ValueType == "cell"
                    value = table2cell(value);
                elseif obj.ValueType == "raw"
                    value = value{:, :};
                end
            end
        end

        function row = getCell(obj)
            %% Get selected Table cell
            data = obj.getData();
            [rowIdx, colIdx] = obj.getSelectionIdx(Data=data);
            row = data(rowIdx, colIdx);
        end

        function row = getRow(obj)
            %% Get selected Table row
            data = obj.getData();
            rowIdx = obj.getSelectionIdx(Data=data);
            row = data(rowIdx, :);
        end

        function column = getColumn(obj)
            %% Get xelected Table column
            data = obj.getData();
            [~, columnIdx] = obj.getSelectionIdx(Data=data);
            column = data(:, columnIdx);
        end

        function obj = setData(obj, data)
            %% Set Table data
            arguments
                obj
                data table
            end
            obj.DataController.writeData(data);
            value = obj.getValue();
            obj.ValueController.writeData(value);
        end

        function obj = setSelection(obj, sel)
            %% Set Table selection
            obj.SelectionController.writeData(sel);
            value = obj.getValue();
            obj.ValueController.writeData(value);
        end

        function setValue(obj, value)
            %% Get Table value
            data = obj.getData();
            sel = obj.getSelection();
            if ~isempty(sel)
                [rowIdx, colIdx] = obj.getSelectionIdx(sel, data=Data);
                if iscell(value) || istable(value)
                    data(rowIdx, colIdx) = value;
                else
                    data{rowIdx, colIdx} = value;
                end
                obj.setData(data);
            end
        end

        function obj = select(obj, sel, opts)
            %% Select Table section by indices
            arguments
                obj
                sel
                opts.Data = obj.getData();
            end
            if ~isempty(sel)
                if obj.SelectionType == "cell"
                    sel(sel(:,1) > height(opts.Data), 1) = height(opts.Data);
                    sel(sel(:,1) <= 0, :) = [];
                    sel = unique(sel, 'rows');
                end
                obj.setSelection(sel);
            end
        end

        function obj = addRow(obj, row)
            %% Add new row to Table
            arguments
                obj
                row {mustBeA(row,["cell","table"])}
            end
            data = obj.getData();
            data = [data; row];
            obj.setData(data);
        end

        function obj = deleteRow(obj)
            %% Delete rows from Data
            sel = obj.getSelection();
            data = obj.getData();
            if ~isempty(sel) && ~isempty(data)
                rowIdx = obj.getSelectionIdx(sel, Data=data);
                data(rowIdx, :) = [];
                obj.select(sel, Data=data);
                obj.setData(data);
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

        function [rowIdx, colIdx] = getSelectionIdx(obj, sel, opts)
            %% Get selected indices
            arguments
                obj
                sel = obj.getSelection()
                opts.Data = obj.getData()
            end
            if ~isempty(sel)
                if obj.SelectionType == "cell"
                    rowIdx = unique(sel(:,1));
                    colIdx = unique(sel(:,2));
                elseif obj.SelectionType == "row"
                    rowIdx = unique(sel(:));
                    colIdx = (1 : width(opts.Data))';
                elseif obj.SelectionType == "column"
                    rowIdx = (1 : height(opts.Data))';
                    colIdx = unique(sel(:));
                end
            else
                rowIdx = [];
                colIdx = [];
            end
        end

    end

    methods (Access=protected)

        function obj = moveRow(obj, dir)
            %% Move Table row in specified direction
            sel = obj.getSelection();
            data = obj.getData();
            if ~isempty(sel) && ~isempty(data)
                iRow = obj.getSelectionIdx(sel, Data=data);
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
