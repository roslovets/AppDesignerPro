classdef TableController < UI.Controller
    %% Create autoupdating reactive table strongly binded with data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        VarType
        ColumnName
        UIVars = cell2table(cell(0, 3), 'VariableNames', {'VarName' 'UIComponent' 'UIController'})
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
                opts.UI = []
            end
            obj = obj@UI.Controller( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
                UI=opts.UI ...
                );
            obj.setVariables();
        end

        function setVariables(obj)
            %% Set variables types
            data = obj.getData();
            if istable(data) && ~isempty(data)
                ts = varfun(@(x) string(class(x)), data);
                ts.Properties.VariableNames = data.Properties.VariableNames;
                obj.VarType = ts;
            end
        end

        function redrawUI(obj)
            %% Redraw table
            redrawUI@UI.Controller(obj);
            if ~isempty(obj.ColumnName)
                for i = 1 : length(obj.UI)
                    obj.UI(i).ColumnName = obj.ColumnName;
                end
            end
        end

        function update(obj, event)
            %% Update table
            arguments
                obj
                event = []
            end
            update@UI.Controller(obj, event);
            obj.redrawVars();
        end

        function sel = getSelection(obj)
            %% Get current table selection
            sel = obj.UI(1).Selection;
        end

        function setSelection(obj, sel)
            %% Set current table selection
            obj.UI(1).Selection = sel;
        end

        function select(obj, ids)
            %% Select cell
            if ~isempty(ids)
                if class(ids) == "matlab.ui.eventdata.CellSelectionChangeData"
                    ids = ids.Indices;
                end
                if ~isempty(ids)
                    obj.setSelection(ids);
                end
            else
                obj.setSelection([]);
            end
            obj.redrawVars();
        end

        function val = get(obj, varName)
            %% Get selected value
            arguments
                obj
                varName (1,1) string = ""
            end
            sel = obj.getSelection();
            if isempty(sel)
                val = [];
            else
                data = obj.getData();
                if sel(1) > height(data)
                    val = [];
                else
                    if varName ~= ""
                        val = data{sel(1), varName};
                    else
                        val = data{sel(1), sel(2)};
                    end
                end
            end
        end

        function set(obj, varName, value)
            %% Set value to selected row of specified variable
            arguments
                obj
                varName (1,1) string
                value
            end
            sel = obj.getSelection();
            if ~isempty(sel)
                data = obj.getData();
                if sel(1) <= height(data)
                    data{sel(1), varName} = value;
                    obj.setData(data);
                end
            end
        end

        function vals = getRow(obj)
            %% Get selected row
            sel = obj.getSelection();
            if isempty(sel)
                vals = [];
            else
                data = obj.getData();
                vals = data(sel(1), :);
            end
        end

        function addRow(obj, varargin)
            %% Add a new row to the end of the Table
            data = obj.getData();
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
            obj.setData(data);
            obj.select([height(data) 1]);
        end

        function deleteRow(obj, rownum)
            %% Delete row from Table
            arguments
                obj
                rownum (1,1) double = NaN
            end
            if isnan(rownum)
                sel = obj.getSelection();
                if ~isempty(sel)
                    rownum = sel(:, 1);
                else
                    rownum = [];
                end
            end
            if ~isempty(rownum)
                data = obj.getData();
                if rownum <= height(data)
                    data(rownum, :) = [];
                    curSel = obj.getSelection();
                    obj.setData(data);
                    if ~isempty(data) && ~isempty(curSel)
                        obj.setSelection([min([height(obj.getData()), rownum(1)]), curSel(2)]);
                    end
                end
            end
        end

        function bindVar(obj, varName, component)
            %% Bind table variable to GUI object
            uiController = UI.Controller( ...
                DataReadFcn=@()obj.readVarData(varName), DataWriteFcn=@(x)obj.writeVarData(varName, x), ...
                UI=component ...
                );
            obj.UIVars = [obj.UIVars; {varName component uiController}];
        end

        function moveRow(obj, step)
            %% Move row by step
            sel = obj.getSelection();
            if ~isempty(sel)
                data = obj.getData();
                idx1 = sel(1);
                [data, ~, idx2] = UI.internal.moveRow(data, idx1, step);
                obj.setData(data);
                sel(1) = idx2;
                obj.setSelection(sel);
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

        function updateVar(obj, var)
            %% Update Table Variable from GUI
            if ~isempty(obj.UIVars)
                if ischar(var) || isstring(var)
                    idx = find(obj.UIVars.VarName == string(var));
                elseif isgraphics(var)
                    idx = find(obj.UIVars.UIComponent == var);
                else
                    idx = find(obj.UIVars.UIComponent == var.Source);
                end
                if ~isempty(idx)
                    obj.UIVars.UIController(idx(1)).update();
                end
                obj.redrawUI();
            end
        end

        function data = readVarData(obj, var)
            %% Read Variable data
            data = obj.get(var);
        end

        function writeVarData(obj, var, vardata)
            %% Write Variable data
            sel = obj.getSelection();
            if ~isempty(sel)
                data = obj.getData();
                data{sel(1), var} = obj.convert(vardata, obj.getVarType(var));
                obj.setData(data);
            end
        end

        function redrawVars(obj)
            %% Redraw Variables GUI
            if ~isempty(obj.UIVars)
                for i = 1 : height(obj.UIVars)
                    obj.UIVars.UIController(i).redrawUI();
                end
            end
        end

        function type = getVarType(obj, var)
            %% Get Table variable type
            if ~isempty(obj.VarType)
                if isnumeric(var)
                    data = obj.getData();
                    varname = data.Properties.VariableNames{var};
                else
                    varname = var;
                end
                type = obj.VarType.(varname){1};
            else
                type = '';
            end
        end

    end

end
