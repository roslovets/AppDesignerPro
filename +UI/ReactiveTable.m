classdef ReactiveTable < UI.Reactive
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Table
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
            ts = varfun(@(x) string(class(x)), data);
            ts.Properties.VariableNames = data.Properties.VariableNames;
            obj.VarType = ts;
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
            obj.redraw();
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
            if isnumeric(var)
                data = obj.readData();
                varname = data.Properties.VariableNames{var};
            else
                varname = var;
            end
            type = obj.VarType.(varname){1};
        end
        
        
    end
end

