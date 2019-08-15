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
        BackgroundColor = [0.651 0.651 0.651]
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
            obj.initBody();
        end
        
        
        function show(obj)
            %% Show input
%             obj.Body.redraw();
            obj.Body.show();
            uiwait(obj.UIFigure);
        end
        
        function close(obj, varargin)
            %% Close input
            obj.Body.hide()
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
            obj.Body = UI.Overlay(obj.UIFigure, 'Width', obj.Width,...
                'Height', obj.Height, 'BackgroundColor', obj.BackgroundColor);
            panel = obj.Body.UIPanel;
            refpos = [0 0 panel.Position([3 4])];
            obj.addField(panel, obj.Message, obj.Value);
            cbtn = uibutton(panel, 'Text', 'Cancel', 'ButtonPushedFcn', @obj.close);
            cbtnpos = cbtn.Position;
            cbtnpos(3) = obj.BtnWidth;
            cbtn.Position = uialign(cbtnpos, refpos, 'right', 'bottom', true, [-5 5]);
            okbtn = uibutton(panel, 'Text', 'OK', 'ButtonPushedFcn', @(~,~)obj.apply(inp));
            okbtnpos = okbtn.Position;
            okbtnpos(3) = obj.BtnWidth;
            okbtn.Position = uialign(okbtnpos, cbtn, 'right', 'fill', false, [-(obj.BtnWidth+5) 0]);
        end
        
        function f = addField(obj, parent, title, value)
            %% Add field to input
            f = uieditfield(parent, 'Value', value);
            f.ValueChangedFcn = @(inp,~)obj.apply(inp);
            refpos = [0 0 parent.Position([3 4])];
            inppos = f.Position;
            inppos(3) = refpos(3) - 5*2;
            f.Position = uialign(inppos, refpos, 'center', 'center');
            lbl = uilabel(parent, 'Text', title);
            lbl.Position(3) = refpos(3) - 5*2;
            uialign(lbl, refpos, 'center', 'center', true, [0 inppos(4)+5]);
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.Body);
        end
        
    end
end

