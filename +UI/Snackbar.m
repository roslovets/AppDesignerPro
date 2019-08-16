classdef Snackbar < handle
    %Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIFigure
        UILabel
        UIButton
        Root
        Message
        Type
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
        Checked
        ActionCallback
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
            addParameter(p, 'Type', 'dismissible');
            addParameter(p, 'Animation', 'slide');
            addParameter(p, 'FontSize', 12);
            addParameter(p, 'FontWeight', 'normal');
            addParameter(p, 'MarginBottom', 15);
            addParameter(p, 'MinWidth', 100);
            addParameter(p, 'MinHeight', 40);
            addParameter(p, 'Checked', false);
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
            obj.Type = args.Type;
            obj.Animation = args.Animation;
            obj.FontSize = args.FontSize;
            obj.FontWeight = args.FontWeight;
            obj.MarginBottom = args.MarginBottom;
            obj.MinWidth = args.MinWidth;
            obj.MinHeight = args.MinHeight;
            obj.Checked = args.Checked;
            if args.Show()
                obj.show();
            end
        end
        
        function show(obj)
            %% Show snackbar
            obj.close();
            obj.init();
            obj.setVisibility('on');
            obj.initAnimationWorker();
            obj.AnimationWorker.start();
        end
        
        function close(obj, varargin)
            %% Close snackbar
            delete(obj.AnimationWorker);
            obj.setVisibility('off');
        end
        
        function action(obj, varargin)
            %% Snackbar button action
            if obj.Type == "dismissible"
                obj.close();
            elseif obj.Type == "checkable"
                obj.Checked = ~obj.Checked;
                obj.redraw();
            end
            if ~isempty(obj.ActionCallback)
                obj.ActionCallback();
            end
        end
        
        function init(obj)
            %% Initialize Body
            if ~isempty(obj.Root) && isvalid(obj.Root)
                delete(obj.Root);
            end
            obj.Root = uipanel(obj.UIFigure, 'Visible', 'off');
            obj.UILabel = uilabel(obj.Root, 'Text', obj.Message);
            obj.UILabel.VerticalAlignment = 'center';
            obj.UILabel.HorizontalAlignment = 'center';
            if obj.Type == "dismissible" || obj.Type == "checkable"
                if obj.Type == "checkable"
                    btntxt = char(10003);
                else
                    btntxt = char(10005);
                end
                obj.UIButton = uibutton(obj.Root, 'Text', btntxt);
                obj.UIButton.FontSize = floor(obj.BtnSize / 2);
                obj.UIButton.ButtonPushedFcn = @obj.action;
            end
            obj.redraw();
        end
        
        function redraw(obj)
            %% Redraw snackbar
            color = obj.Color;
            fontcolor = obj.FontColor;
            if obj.Type == "checkable"
                if obj.Checked
                    obj.FontWeight = 'normal';
                    [color, fontcolor] = uitheme('none');
                else
                    obj.FontWeight = 'bold';
                end
            end
            obj.Root.BackgroundColor = color;
            txt = split(cellstr(obj.Message), newline);
            width = max(cellfun('length', txt)) * obj.FontSize * 0.5 + 50;
            width = max([obj.MinWidth width]);
            height = length(txt) * obj.FontSize * 1.2 + 22;
            height = max([obj.MinHeight height]);
            pos = obj.Root.Position;
            pos(2:4) = [obj.MarginBottom width height];
            pos = uialign(pos, obj.UIFigure, 'center', '', true);
            obj.Root.Position = pos;
            isbut = ~isempty(obj.UIButton) && isvalid(obj.UIButton);
            if isbut
                boffset = obj.BtnSize * 1.2;
            else
                boffset = 0;
            end
            obj.UILabel.Text = obj.Message;
            obj.UILabel.Position = [0, 0, pos(3) - boffset, pos(4)];
            obj.UILabel.BackgroundColor = color;
            obj.UILabel.FontColor = fontcolor;
            obj.UILabel.FontSize = obj.FontSize;
            obj.UILabel.FontWeight = obj.FontWeight;
            if isbut
                obj.UIButton.BackgroundColor = color;
                obj.UIButton.FontColor = fontcolor;
                btnpos = [pos(3) - obj.BtnSize*1.2, 0, obj.BtnSize, obj.BtnSize];
                obj.UIButton.Position = uialign(btnpos, pos, '', 'center', true);
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
%                         y = [obj.UIFigure.Position(4) obj.UIFigure.Position(4)-obj.MarginBottom-obj.Root.Position(4)];
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
        
        function set.Type(obj, type)
            %% Set theme
            type = lower(type);
            obj.validateType(type);
            obj.Type = type;
        end
        
        function set.Theme(obj, theme)
            %% Set theme
            [obj.Color, obj.FontColor] = uitheme(theme);
        end
        
        function validateType(~, type)
            %% Validate snackbar type
            typelist = ["normal" "dismissible" "checkable"];
            if ~ismember(type, typelist)
                error('Unknown type: %s. Use one of the: %s', type, join(typelist, '|'));
            end
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