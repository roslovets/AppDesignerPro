classdef UITableController < handle
    %% Create autoupdating reactive table strongly binded with data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties
        TableController
        DataUIController
        SelectionUIController
        ValueUIController
    end

    methods
        function obj = UITableController(opts)
            %% Initialize object
            arguments
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
                opts.DataUI = []
                opts.Selection = []
                opts.SelectionObject = []
                opts.SelectionProperty (1,1) string = missing
                opts.SelectionReadFcn = []
                opts.SelectionWriteFcn = []
                opts.SelectionUI = []
                opts.Value = []
                opts.ValueObject = []
                opts.ValueProperty (1,1) string = missing
                opts.ValueReadFcn = []
                opts.ValueWriteFcn = []
                opts.ValueUI = []
            end
            obj.TableController = UI.util.TableController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn = opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
                Selection=opts.Selection, ...
                SelectionObject=opts.SelectionObject, SelectionProperty=opts.SelectionProperty, ...
                SelectionReadFcn = opts.SelectionReadFcn, SelectionWriteFcn = opts.SelectionWriteFcn, ...
                Value=opts.Value, ...
                ValueObject=opts.ValueObject, ValueProperty=opts.ValueProperty, ...
                ValueReadFcn = opts.ValueReadFcn, ValueWriteFcn = opts.ValueWriteFcn ...
                );
            obj.bindData( ...
                DataReadFcn=@()obj.TableController.getData(), ...
                DataWriteFcn=@(x)obj.TableController.setData(x), ...
                UI=opts.DataUI ...
                );
            obj.bindSelection( ...
                DataReadFcn=@()obj.TableController.getSelection(), ...
                DataWriteFcn=@(x)obj.TableController.setSelection(x), ...
                UI=opts.SelectionUI ...
                );
            obj.bindValue( ...
                DataReadFcn=@()obj.TableController.getValue(), ...
                DataWriteFcn=@(x)obj.TableController.setValue(x), ...
                UI=opts.ValueUI ...
                );
        end

        function bindData(obj, opts)
            %% Bind Table data
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
                opts.UI = []
            end
            obj.DataUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
                UI = opts.UI, UIProperty="Data" ...
                );
        end

        function bindSelection(obj, opts)
            %% Bind Table selection
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
                opts.UI = []
            end
            obj.SelectionUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
                UI = opts.UI, UIProperty="Selection" ...
                );
        end

        function bindValue(obj, opts)
            %% Bind Table value
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
                opts.UI = []
            end
            obj.ValueUIController = UI.UIController( ...
                Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn, ...
                UI = opts.UI, UIProperty="Value" ...
                );
        end

        function redrawUI(obj)
            %% Redraw table
            obj.DataUIController.redrawUI();
            obj.SelectionUIController.redrawUI();
            obj.ValueUIController.redrawUI();
        end

        function updateSelection(obj, event)
            %% Update Table selection from UI
            arguments
                obj
                event = []
            end
            obj.SelectionUIController.update(event);
            obj.ValueUIController.update(event);
        end

        function updateValue(obj, event)
            %% Update Table value from UI
            arguments
                obj
                event = []
            end
            obj.ValueUIController.update(event);
            obj.DataUIController.update(event);
        end

        function sel = getSelection(obj)
            %% Get current Table selection
            sel = obj.TableController.getSelection();
        end

        function select(obj, sel)
            %% Select cell
            obj.TableController.select(sel);
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

        function addRow(obj, values)
            %% Add a new row to the end of the Table
            obj.TableController.addRow(values);
            obj.redrawUI();
        end

        function deleteRow(obj)
            %% Delete row from Table
            obj.TableController.deleteRow();
            obj.redrawUI();
        end

        function bindVar(obj, varName, component)
            %% Bind table variable to GUI object
            uiController = UI.UIController( ...
                DataReadFcn=@()obj.readVarData(varName), DataWriteFcn=@(x)obj.writeVarData(varName, x), ...
                UI=component ...
                );
            obj.UIVars = [obj.UIVars; {varName component uiController}];
        end

        function moveRowUp(obj)
            %% Move row one step up
            obj.TableController.moveRowUp();
            obj.redrawUI();
        end

        function moveRowDown(obj)
            %% Move row one step down
            obj.TableController.moveRowDown();
            obj.redrawUI();
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
