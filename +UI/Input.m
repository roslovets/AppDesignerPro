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
            parent = obj.Body.Main;
            inp = uieditfield(parent, 'Value', obj.Value);
            inp.ValueChangedFcn = @(inp,~)obj.apply(inp);
            refpos = [0 0 obj.Width obj.Height];
            inppos = inp.Position;
            inppos(3) = refpos(3) - 5*2;
            inp.Position = uialign(inppos, refpos, 'center', 'center');
            lbl = uilabel(parent, 'Text', obj.Message);
            lbl.Position(3) = refpos(3) - 5*2;
            uialign(lbl, refpos, 'center', 'center', true, [0 inppos(4)+5]);
            cbtn = uibutton(parent, 'Text', 'Cancel', 'ButtonPushedFcn', @obj.close);
            cbtnpos = cbtn.Position;
            cbtnpos(3) = obj.BtnWidth;
            cbtn.Position = uialign(cbtnpos, refpos, 'right', 'bottom', true, [-5 5]);
            okbtn = uibutton(parent, 'Text', 'OK', 'ButtonPushedFcn', @(~,~)obj.apply(inp));
            okbtnpos = okbtn.Position;
            okbtnpos(3) = obj.BtnWidth;
            okbtn.Position = uialign(okbtnpos, cbtn, 'right', 'fill', false, [-(obj.BtnWidth+5) 0]);
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.Body);
        end
        
    end
end

