classdef ReactiveTable < UI.Reactive
    %% Create autoupdating reactive table strongly binded with data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io
    
    properties
        Selection
        VarType
        ColumnName
        GUIVar
    end
    
    methods
        function obj = ReactiveTable(varargin)
            %% GUI Reactive Table
            obj = obj@UI.Reactive(varargin{:});
            obj.setVariables();
        end
        
        function setVariables(obj)
            %% Set variables types
            data = obj.readData();
            if istable(data) && ~isempty(data)
                ts = varfun(@(x) string(class(x)), data);
                ts.Properties.VariableNames = data.Properties.VariableNames;
                obj.VarType = ts;
            end
        end
        
        function redraw(obj)
            %% Redraw table
            redraw@UI.Reactive(obj);
            if ~isempty(obj.ColumnName)
                obj.GUI(1).ColumnName = obj.ColumnName;
            end
        end
        
        function update(obj, varargin)
            %% Update table
            update@UI.Reactive(obj, varargin{:});
            obj.redrawVars();
        end
        
        function select(obj, ids)
            %% Select cell
            if ~isempty(ids)
                if class(ids) == "matlab.ui.eventdata.CellSelectionChangeData"
                    ids = ids.Indices;
                end
                obj.Selection.Row = ids(1, 1);
                obj.Selection.Col = ids(1, 2);
            else
                obj.Selection = [];
            end
            %obj.redraw();
            obj.redrawVars();
        end
        
        function val = get(obj, varname)
            %% Get selected value
            if isempty(obj.Selection)
                val = [];
            else
                data = obj.readData();
                if obj.Selection.Row > height(data)
                    val = [];
                else
                    if nargin < 2
                        val = data{obj.Selection.Row, obj.Selection.Col};
                    else
                        val = data{obj.Selection.Row, varname};
                    end
                end
            end
        end
        
        function set(obj, varname, value)
            %% Set value to selected row of specified variable
            if ~isempty(obj.Selection)
                data = obj.readData();
                if obj.Selection.Row <= height(data)
                    data{obj.Selection.Row, varname} = value;
                    obj.writeData(data);
                    obj.redraw();
                end
            end
        end
        
        function vals = getRow(obj)
            %% Get selected row
            if isempty(obj.Selection)
                vals = [];
            else
                data = obj.readData();
                vals = data(obj.Selection.Row, :);
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
        
        function bindVar(obj, var, guiobj)
            %% Bind table variable to GUI object
            if isempty(obj.GUIVar)
                obj.GUIVar = cell2table(cell(0, 3), 'VariableNames', {'Var' 'GUIObj' 'GUIReact'});
            end
            guireact = UI.Reactive([], @()obj.readVarData(var), @(x)obj.writeVarData(var, x));
            guireact.bind(guiobj);
            obj.GUIVar = [obj.GUIVar; {var guiobj guireact}];
        end
        
        function moveRow(obj, step)
            %% Move row by step
            if ~isempty(obj.Selection)
                data = obj.readData();
                idx1 = obj.Selection.Row;
                [data, ~, idx2] = UI.internal.moveRow(data, idx1, step);
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
        
        function updateVar(obj, var)
            %% Update Table Variable from GUI
            if ~isempty(obj.GUIVar)
                if ischar(var) || isstring(var)
                    idx = find(obj.GUIVar.Var == string(var));
                elseif isgraphics(var)
                    idx = find(obj.GUIVar.GUIObj == var);
                else
                    idx = find(obj.GUIVar.GUIObj == var.Source);
                end
                if ~isempty(idx)
                    obj.GUIVar.GUIReact(idx(1)).update();
                end
                obj.redraw();
            end
        end
        
        function data = readVarData(obj, var)
            %% Read Variable data
            data = obj.get(var);
        end
        
        function writeVarData(obj, var, vardata)
            %% Write Variable data
            if ~isempty(obj.Selection)
                data = obj.readData();
                data{obj.Selection.Row, var} = obj.convert(vardata, obj.getVarType(var));
                obj.writeData(data);
            end
        end
        
        function redrawVars(obj)
            %% Redraw Variables GUI
            if ~isempty(obj.GUIVar)
                for i = 1 : height(obj.GUIVar)
                    obj.GUIVar.GUIReact(i).redraw();
                end
            end
        end
        
        function type = getVarType(obj, var)
            %% Get Table variable type
            if ~isempty(obj.VarType)
                if isnumeric(var)
                    data = obj.readData();
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

