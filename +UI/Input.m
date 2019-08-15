classdef Input < handle
    %GUIINPUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIFigure
        UIInput
        Body
        Value = ''
        Height = 95
        Width = 200
        BtnWidth = 75
        Color = [0.651 0.651 0.651]
        FontSize = 12
        Message = 'Enter value'
        Ok = false
    end
    
    methods
        function obj = Input(uifig, msg, value)
            %% Constructor
            if nargin > 0
                obj.UIFigure = uifig;
            else
                obj.UIFigure = uifigure;
            end
            if nargin > 1
                obj.Message = msg;
            end
            if nargin > 2
                obj.Value = value;
            end
        end
        
        
        function show(obj)
            %% Show input
            obj.close();
            obj.initBody();
            uiwait(obj.UIFigure);
        end
        
        function close(obj, varargin)
            %% Close input
            delete(obj.Body);
            uiresume(obj.UIFigure);
        end
        
        function apply(obj, inputObj)
            %% Apply and close input
            obj.Value = inputObj.Value;
            obj.Ok = true;
            obj.close();
        end
        
        function initBody(obj)
            %% Initialize Body
            if ~isempty(obj.Body) && isvalid(obj.Body)
                delete(obj.Body);
            end
            obj.Body = uigridlayout(obj.UIFigure);
            obj.Body.RowHeight = {'1x'};
            obj.Body.ColumnWidth = {'1x'};
            obj.Body.Padding = 0;
            panel = uipanel(obj.Body);
            panel.BackgroundColor = obj.Color;
            grid2 = uigridlayout(panel);
            grid2.RowHeight = {'1x', obj.Height, '1x'};
            grid2.ColumnWidth = {'1x', obj.Width, '1x'};
            panel2 = uipanel(grid2);
            panel2.Layout.Row = 2;
            panel2.Layout.Column = 2;
            inp = uieditfield(panel2, 'Value', obj.Value);
            inp.ValueChangedFcn = @(inp,~)obj.apply(inp);
            refpos = [0 0 obj.Width obj.Height];
            inppos = inp.Position;
            inppos(3) = refpos(3) - 5*2;
            inp.Position = uialign(inppos, refpos, 'center', 'center');
            lbl = uilabel(panel2, 'Text', obj.Message);
            lbl.Position(3) = refpos(3) - 5*2;
            uialign(lbl, refpos, 'center', 'center', true, [0 inppos(4)+5]);
            cbtn = uibutton(panel2, 'Text', 'Cancel', 'ButtonPushedFcn', @obj.close);
            cbtnpos = cbtn.Position;
            cbtnpos(3) = obj.BtnWidth;
            cbtn.Position = uialign(cbtnpos, refpos, 'right', 'bottom', true, [-5 5]);
            okbtn = uibutton(panel2, 'Text', 'OK', 'ButtonPushedFcn', @(~,~)obj.apply(inp));
            okbtnpos = okbtn.Position;
            okbtnpos(3) = obj.BtnWidth;
            okbtn.Position = uialign(okbtnpos, cbtn, 'right', 'fill', false, [-(obj.BtnWidth+5) 0]);
        end
        
    end
end

