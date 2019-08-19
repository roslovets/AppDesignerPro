classdef Snackbar < handle
    %Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIFigure
        UILabel
        UIButton
        UIActions
        Root
        Message
        Type
        Time
        Location
        Actions
        Animation
        FontSize
        FontWeight
        Margin
        Theme
        Color
        FontColor
        MinWidth
        MinHeight
        Offset
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
            addParameter(p, 'Location', 'bottom');
            addParameter(p, 'Actions', []);
            addParameter(p, 'Animation', 'slide');
            addParameter(p, 'FontSize', 12);
            addParameter(p, 'FontWeight', 'normal');
            addParameter(p, 'Margin', 15);
            addParameter(p, 'MinWidth', 100);
            addParameter(p, 'MinHeight', 40);
            addParameter(p, 'Offset', [0 0]);
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
            obj.Location = args.Location;
            obj.Animation = args.Animation;
            obj.FontSize = args.FontSize;
            obj.FontWeight = args.FontWeight;
            obj.Margin = args.Margin;
            obj.MinWidth = args.MinWidth;
            obj.MinHeight = args.MinHeight;
            obj.Offset = args.Offset;
            obj.Checked = args.Checked;
            if isempty(args.Actions) || iscell(args.Actions)
                obj.Actions = cell2table(cell(0, 2), 'VariableNames', {'name' 'fcn'});
                if iscell(args.Actions)
                    obj.Actions = [obj.Actions; args.Actions];
                end
            else
                obj.Actions = args.Actions;
            end
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
        
        function mainAction(obj, varargin)
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
                obj.UIButton.ButtonPushedFcn = @obj.mainAction;
            end
            if ~isempty(obj.Actions)
                obj.UIActions = gobjects(1, height(obj.Actions));
                for i = 1 : height(obj.Actions)
                    obj.UIActions(i) = uibutton(obj.Root,...
                        'Text', obj.Actions.name{i}, 'ButtonPushedFcn', obj.Actions.fcn{i});
                end
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
            isbut = ~isempty(obj.UIButton) && isvalid(obj.UIButton);
            isact = ~isempty(obj.UIActions) && all(isvalid(obj.UIActions));
            boffset = isbut * obj.BtnSize * 1.2;
            actoffset = isact * 30;
            [w, h] = obj.calcTextSize(obj.Message, obj.FontSize);
            w = max([obj.MinWidth, w + 25 + boffset]);
            h = max([obj.MinHeight, h + 22 + actoffset]);
            pos = obj.Root.Position;
            pos(3:4) = [w h];
            switch obj.Location
                case "bottom"
                    pos = uialign(pos, obj.UIFigure, 'center', 'bottom', true, [0 obj.Margin]);
                case "top"
                    pos = uialign(pos, obj.UIFigure, 'center', 'top', true, [0 -obj.Margin]);
                case "left"
                    pos = uialign(pos, obj.UIFigure, 'left', 'center', true, [obj.Margin 0]);
                case "right"
                    pos = uialign(pos, obj.UIFigure, 'right', 'center', true, [-obj.Margin 0]);
                case "center"
                    pos = uialign(pos, obj.UIFigure, 'center', 'center', true);
            end
            pos([1 2]) = pos([1 2]) + obj.Offset;
            obj.Root.Position = pos;
            set(obj.UILabel, 'Text', obj.Message,...
                'BackgroundColor', color, 'FontColor', fontcolor,...
                'FontSize', obj.FontSize, 'FontWeight', obj.FontWeight);
            obj.UILabel.Position = [0, actoffset, pos(3) - boffset, pos(4) - actoffset];
            if isbut
                set(obj.UIButton, 'BackgroundColor', color, 'FontColor', fontcolor);
                btnpos = [pos(3) - obj.BtnSize*1.2, 0, obj.BtnSize, obj.BtnSize];
                pos([2 4]) = pos([2 4]) + actoffset;
                obj.UIButton.Position = uialign(btnpos, pos, '', 'center', true);
            end
            if isact
                set(obj.UIActions, 'BackgroundColor', color);
                set(obj.UIActions, 'FontColor', fontcolor);
                for i = 1 : length(obj.UIActions)
                    obj.UIActions(i).Position(3) = obj.calcTextSize(obj.UIActions(i));
                end
                uialign(obj.UIActions, obj.Root, 'center', 'bottom', true, [0 7], 'HorDist', 7);
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
                        switch obj.Location
                            case "bottom"
                                x = obj.Root.Position(1);
                                y = [-obj.Root.Position(4) obj.Root.Position(2)];
                            case "left"
                                x = [-obj.Root.Position(3) obj.Root.Position(1)];
                                y = obj.Root.Position(2);
                            case "right"
                                x = [obj.UIFigure.Position(3) obj.Root.Position(1)];
                                y = obj.Root.Position(2);
                            otherwise % top, center
                                x = obj.Root.Position(1);
                                y = [obj.UIFigure.Position(4) obj.Root.Position(2)];
                        end
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
        
        function [w, h] = calcTextSize(~, obj, fontsize)
            %% Calculate size of element with text
            if isgraphics(obj)
                txt = obj.Text;
            else
                txt = obj;
            end
            if nargin < 3
                fontsize = obj.FontSize;
            end
            txt = cellstr(txt);
            if contains(txt, newline)
                txt = split(txt, newline);
            end
            w = max(cellfun('length', txt)) * fontsize * 0.5 + 25;
            h = length(txt) * fontsize * 1.2;
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