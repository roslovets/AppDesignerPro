classdef Snackbar < handle
    %Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIFigure
        Root
        Message
        Dismissible
        Time
        Animation
        FontSize
        FontWeight
        MarginBottom
        Theme
        Color
        FontColor
        MinWidth
        MinHeight
        BtnSize = 24
        AnimationWorker
    end
    
    methods
        function obj = Snackbar(varargin)
            %% Constructor
            p = inputParser;
            addOptional(p, 'uifig', []);
            addOptional(p, 'msg', '', @(x) ischar(x) || isstring(x));
            addParameter(p, 'Theme', 'dark');
            addParameter(p, 'Time', 3);
            addParameter(p, 'Dismissible', true);
            addParameter(p, 'Animation', 'slide');
            addParameter(p, 'FontSize', 12);
            addParameter(p, 'FontWeight', 'normal');
            addParameter(p, 'MarginBottom', 15);
            addParameter(p, 'MinWidth', 100);
            addParameter(p, 'MinHeight', 40);
            addParameter(p, 'Show', true);
            parse(p, varargin{:});
            args = p.Results;
            if isempty(args.uifig)
                obj.UIFigure = uifigure;
            else
                obj.UIFigure = args.uifig;
            end
            obj.Message = args.msg;
            obj.Theme = args.Theme;
            obj.Time = args.Time;
            obj.Dismissible = args.Dismissible;
            obj.Animation = args.Animation;
            obj.FontSize = args.FontSize;
            obj.FontWeight = args.FontWeight;
            obj.MarginBottom = args.MarginBottom;
            obj.MinWidth = args.MinWidth;
            obj.MinHeight = args.MinHeight;
            if args.Show()
                obj.show();
            end
        end
        
        function show(obj)
            %% Show snackbar
            obj.close();
            obj.redraw();
            obj.setVisibility('on');
            obj.initAnimationWorker();
            obj.AnimationWorker.start();
        end
        
        function close(obj, varargin)
            %% Close snackbar
            delete(obj.AnimationWorker);
            obj.setVisibility('off');
        end
        
        function redraw(obj)
            %% Initialize Body
            if ~isempty(obj.Root) && isvalid(obj.Root)
                delete(obj.Root);
            end
            obj.Root = uipanel(obj.UIFigure, 'Visible', 'off');
            obj.Root.BackgroundColor = obj.Color;
            uilbl = uilabel(obj.Root, 'Text', obj.Message);
            uilbl.VerticalAlignment = 'center';
            uilbl.HorizontalAlignment = 'center';
            uilbl.BackgroundColor = obj.Color;
            uilbl.FontColor = obj.FontColor;
            uilbl.FontSize = obj.FontSize;
            uilbl.FontWeight = obj.FontWeight;
            txt = split(cellstr(obj.Message), newline);
            width = max(cellfun('length', txt)) * obj.FontSize * 0.5 + 50;
            width = max([obj.MinWidth width]);
            height = length(txt) * obj.FontSize * 1.2 + 22;
            height = max([obj.MinHeight height]);
            pos = obj.Root.Position;
            if obj.Dismissible
                boffset = obj.BtnSize * 1.2;
            else
                boffset = 0;
            end
            pos(2:4) = [obj.MarginBottom width height];
            pos = uialign(pos, obj.UIFigure, 'center', '', true);
            obj.Root.Position = pos;
            uilbl.Position = [0, 0, pos(3) - boffset, pos(4)];
            if obj.Dismissible
                uibtn = uibutton(obj.Root, 'Text', char(10005));
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
            obj.AnimationWorker = UI.Animation(obj.Root);
            if obj.Animation == "none"
                closedelay = obj.Time;
            else
                switch obj.Animation
                    case "slide"
                        x = obj.Root.Position(1);
                        y = [-obj.Root.Position(4) obj.MarginBottom];
                    case "zoom"
                        x = [0.9 1];
                        y = [0.9 1];
                    case "roll"
                        x = [0 1];
                        y = 1;
                end
                obj.AnimationWorker.add(obj.Animation, x, y);
                if isfinite(obj.Time)
                    obj.AnimationWorker.addDelay(obj.Time);
                    obj.AnimationWorker.add(obj.Animation, fliplr(x), fliplr(y));
                    closedelay = 0;
                end
            end
            if isfinite(obj.Time)
                obj.AnimationWorker.addTask(@obj.close, closedelay);
            end
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
            if ~isempty(obj.Root) && isvalid(obj.Root)
                obj.Root.Visible = vis;
            end
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.AnimationWorker);
            delete(obj.Root);
        end
        
    end
end