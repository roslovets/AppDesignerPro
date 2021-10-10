classdef Input < handle
    %% Show input dialog with text edits and checkboxes in uifigure
    %   Allows to create input dialogs embedded in uifigures and apps
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io
    
    properties
        UIFigure      % Parent uifigure
        UIOverlay     % UI.Overlay object
        UIFields      % Fields UI objects
        UILabels      % UI lables for fields
        Title         % Overlay title
        Fields        % Fields labels and values
        Values        % uiinput values
        Transparent   % Transparent background
        Width         % uiinput width
        Height        % uiinput height
        OkText        % Text of the OK button
        CancelText    % Text of the Cancel button
        BtnWidth = 75 % Width of buttons
        Ok = false    % uiinput is applied
        Wait          % pause MATLAB after call
    end
    
    methods
        function obj = Input(varargin)
            %% Constructor
            p = inputParser();
            p.addOptional('uifig', []);
            p.addOptional('titles', 'Enter value', @(s)isstring(s)||ischar(s)||iscellstr(s));
            p.addOptional('values', '', @(x)iscell(x)||ischar(x)||isstring||islogical(x));
            p.addParameter('Title', '', @(x)ischar(x)||isstring(x));
            p.addParameter('Width', 200);
            p.addParameter('Transparent', false);
            p.addParameter('OkText', 'OK', @(x)ischar(x)||isstring(x));
            p.addParameter('CancelText', 'Cancel', @(x)ischar(x)||isstring(x));
            p.addParameter('Wait', true);
            p.addParameter('Show', true);
            p.parse(varargin{:});
            args = p.Results;
            if isempty(args.uifig)
                obj.UIFigure = uifigure;
            else
                obj.UIFigure = args.uifig;
            end
            obj.Title = args.Title;
            obj.Width = args.Width;
            obj.Transparent = args.Transparent;
            obj.OkText = args.OkText;
            obj.CancelText = args.CancelText;
            obj.Fields = cell2table(cell(0, 2), 'VariableNames', {'title' 'value'});
            obj.addFields(args.titles, args.values);
            obj.Wait = args.Wait;
            if args.Show
                obj.show();
            end
        end
        
        function show(obj)
            %% Show input
            obj.UIOverlay.show();
            if obj.Wait
                uiwait(obj.UIFigure);
            end
        end
        
        function addFields(obj, labels, values)
            %% Add field to input form
            labels = cellstr(labels);
            if isstring(values) || ischar(values)
                values = cellstr(values);
            end
            obj.Fields = [obj.Fields; [labels(:) values(:)]];
            obj.redraw();
        end
        
        function close(obj, varargin)
            %% Close input
            obj.UIOverlay.hide()
            uiresume(obj.UIFigure);
        end
        
        function apply(obj)
            %% Apply and close input
            obj.Values = get(obj.UIFields, 'Value');
            obj.Ok = true;
            obj.close();
        end
        
        function redraw(obj)
            %% Redraw UI objects
            if ~isempty(obj.UIOverlay) && isvalid(obj.UIOverlay)
                delete(obj.UIOverlay);
            end
            if iscell(obj.Fields.value)
                lblnum = nnz(~cellfun(@(x)islogical(x) || isnumeric(x), obj.Fields.value));
            else
                lblnum = 0;
            end
            obj.Height = 40 + height(obj.Fields) * 30 + lblnum * 20;
            if ~isempty(obj.Title)
                obj.Height = obj.Height + 20;
            end
            if obj.Transparent
                args = {'BackgroundColor', 'none'};
            else
                args = {};
            end
            obj.UIOverlay = UI.Overlay(obj.UIFigure, 'Width', obj.Width,...
                'Height', obj.Height, 'Show', false, 'Title', obj.Title, args{:});
            panel = obj.UIOverlay.UIPanel;
            refpos = [0 0 obj.Width obj.Height];
            obj.drawFields(panel);
            cbtn = uibutton(panel, 'Text', obj.CancelText, 'ButtonPushedFcn', @obj.close);
            cbtnpos = cbtn.Position;
            cbtnpos(3) = obj.BtnWidth;
            cbtn.Position = uialign(cbtnpos, refpos, 'right', 'bottom', true, [-7 7]);
            okbtn = uibutton(panel, 'Text', obj.OkText, 'ButtonPushedFcn', @(~,~)obj.apply());
            okbtnpos = okbtn.Position;
            okbtnpos(3) = obj.BtnWidth;
            okbtn.Position = uialign(okbtnpos, cbtn, 'right', 'same', false, [-(obj.BtnWidth+5) 0]);
        end
        
        function f = drawFields(obj, parent)
            %% Add field to input
            refpos = [0 0 obj.Width obj.Height];
            fields = flipud(obj.Fields);
            for i = 1 : height(fields)
                title = fields.title{i};
                if iscell(fields.value)
                    value = fields.value{i};
                else
                    value = fields.value(i);
                end
                chb = islogical(value) || isnumeric(value);
                if ~chb
                    f = uieditfield(parent, 'Value', value);
                else
                    f = uicheckbox(parent, 'Value', value, 'Text', title);
                end
                inppos = f.Position;
                inppos(3) = refpos(3) - 14;
                if i == 1
                    f.Position = uialign(inppos, refpos, 'center', 'bottom', false, [0 40]);
                else
                    if class(obj.UIFields(end)) == "matlab.ui.control.CheckBox"
                        offsety = 30;
                    else
                        offsety = 50;
                    end
                    f.Position = uialign(inppos, obj.UIFields(i-1), 'left', 'top', false, [0 offsety]);
                end
                if ~chb
                    lbl = uilabel(parent, 'Text', title);
                    lbl.Position(3) = refpos(3) - 5*2;
                    lbloffset = [0 inppos(4)];
                    uialign(lbl, f.Position, 'left', 'center', false, lbloffset);
                    obj.UILabels = [obj.UILabels; lbl];
                end
                obj.UIFields = [obj.UIFields; f];
            end
            obj.UIFields = flipud(obj.UIFields);
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.UIOverlay);
        end
        
    end
end