classdef GUISnackbar < handle
    %Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIFigure
        Body
        Message = ''
        Dismissible = true
        Time = 3
        Animation
        FontSize = 12
        MarginBottom = 15
        Theme
        Color
        FontColor
        MinWidth = 100
        MinHeight = 40
        BtnSize = 24
        AnimationWorker
    end
    
    methods
        function obj = GUISnackbar(uifig, msg)
            %% Constructor
            obj.UIFigure = uifig;
            obj.Message = msg;
            obj.Theme = 'dark';
            obj.Animation = 'slide';
        end
        
        function show(obj)
            %% Show snackbar
            obj.close();
            obj.initBody();
            obj.initAnimationWorker();
            obj.AnimationWorker.start();
            obj.setVisibility('on');
        end
        
        function close(obj, varargin)
            %% Close snackbar
            delete(obj.AnimationWorker);
            obj.setVisibility('off');
        end
        
        function initBody(obj)
            %% Initialize Body
            if ~isempty(obj.Body) && isvalid(obj.Body)
                delete(obj.Body);
            end
            obj.Body = uipanel(obj.UIFigure, 'Visible', 'off');
            obj.Body.BackgroundColor = obj.Color;
            uilbl = uilabel(obj.Body, 'Text', obj.Message);
            uilbl.VerticalAlignment = 'center';
            uilbl.HorizontalAlignment = 'center';
            uilbl.BackgroundColor = obj.Color;
            uilbl.FontColor = obj.FontColor;
            uilbl.FontSize = obj.FontSize;
            txt = split(cellstr(obj.Message), newline);
            width = max(cellfun('length', txt)) * obj.FontSize * 0.5 + 50;
            width = max([obj.MinWidth width]);
            height = length(txt) * obj.FontSize * 1.2 + 22;
            height = max([obj.MinHeight height]);
            pos = obj.Body.Position;
            if obj.Dismissible
                boffset = obj.BtnSize * 1.2;
            else
                boffset = 0;
            end
            pos(2:4) = [obj.MarginBottom width height];
            pos = uialign(pos, obj.UIFigure, 'center', '', true);
            obj.Body.Position = pos;
            uilbl.Position = [0, 0, pos(3) - boffset, pos(4)];
            if obj.Dismissible
                uibtn = uibutton(obj.Body, 'Text', 'X');
                uibtn.BackgroundColor = obj.Color;
                uibtn.FontColor = obj.FontColor;
                uibtn.FontSize = floor(obj.BtnSize / 2);
                btnpos = [pos(3) - obj.BtnSize*1.2, 0, obj.BtnSize, obj.BtnSize];
                uibtn.Position = uialign(btnpos, pos, '', 'center', true);
                uibtn.ButtonPushedFcn = @obj.close;
            end
        end
        
        function initAnimationWorker(obj)
            %% Create animation worker
            obj.AnimationWorker = UI.Animation(obj.Body);
            if obj.Animation == "none"
                closedelay = obj.Time;
            else
                switch obj.Animation
                    case "slide"
                        x = obj.Body.Position(1);
                        y = [-obj.Body.Position(4) obj.MarginBottom];
                    case "zoom"
                        x = [0.9 1];
                        y = [0.9 1];
                    case "roll"
                        x = [0 1];
                        y = 1;
                end
                obj.AnimationWorker.add(obj.Animation, x, y);
                obj.AnimationWorker.addDelay(obj.Time);
                obj.AnimationWorker.add(obj.Animation, fliplr(x), fliplr(y));
                closedelay = 0;
            end
            obj.AnimationWorker.addTask(@obj.close, closedelay);
        end
        
        function set.Animation(obj, animation)
            %% Set animation type
            UI.Animation.validate(animation);
            obj.Animation = animation;
        end
        
        function set.Theme(obj, theme)
            %% Set theme
            [obj.Color, obj.FontColor] = uitheme(theme);
        end
        
        function setVisibility(obj, vis)
            %% Set visibility of panel
            if ~isempty(obj.Body) && isvalid(obj.Body)
                obj.Body.Visible = vis;
            end
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.AnimationWorker);
            delete(obj.Body);
        end
        
    end
end