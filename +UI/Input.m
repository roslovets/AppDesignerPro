classdef Input < handle
    %GUIINPUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIFigure
        UIOverlay
        UIFields
        Fields
        Values
        Transparent
        Width
        Height
        FieldsGap = 50
        BtnWidth = 75
        Ok = false
    end
    
    methods
        function obj = Input(varargin)
            %% Constructor
            p = inputParser();
            p.addOptional('uifig', []);
            p.addOptional('titles', 'Enter value', @(s)isstring(s)||ischar(s)||iscellstr(s));
            p.addOptional('values', '', @(s)isstring(s)||ischar(s)||iscellstr(s));
            p.addParameter('Width', 200);
            p.addParameter('Transparent', false);
            p.addParameter('Show', true);
            p.parse(varargin{:});
            args = p.Results;
            if isempty(args.uifig)
                obj.UIFigure = uifigure;
            else
                obj.UIFigure = args.uifig;
            end
            obj.Width = args.Width;
            obj.Transparent = args.Transparent;
            obj.Fields = cell2table(cell(0, 2), 'VariableNames', {'title' 'value'});
            obj.addFields(args.titles, args.values);
            if args.Show
                obj.show();
            end
        end
        
        function show(obj)
            %% Show input
            obj.UIOverlay.show();
            uiwait(obj.UIFigure);
        end
        
        function addFields(obj, labels, values)
            %% Add field to input form
            labels = cellstr(labels);
            values = cellstr(values);
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
            %% Initialize Body
            if ~isempty(obj.UIOverlay) && isvalid(obj.UIOverlay)
                delete(obj.UIOverlay);
            end
            obj.Height = 40 + height(obj.Fields) * obj.FieldsGap;
            if obj.Transparent
                args = {'BackgroundColor', 'none'};
            else
                args = {};
            end
            obj.UIOverlay = UI.Overlay(obj.UIFigure, 'Width', obj.Width,...
                'Height', obj.Height, 'Show', false, args{:});
            panel = obj.UIOverlay.UIPanel;
            refpos = [0 0 obj.Width obj.Height];
            obj.drawFields(panel);
            cbtn = uibutton(panel, 'Text', 'Cancel', 'ButtonPushedFcn', @obj.close);
            cbtnpos = cbtn.Position;
            cbtnpos(3) = obj.BtnWidth;
            cbtn.Position = uialign(cbtnpos, refpos, 'right', 'bottom', true, [-7 7]);
            okbtn = uibutton(panel, 'Text', 'OK', 'ButtonPushedFcn', @(~,~)obj.apply());
            okbtnpos = okbtn.Position;
            okbtnpos(3) = obj.BtnWidth;
            okbtn.Position = uialign(okbtnpos, cbtn, 'right', 'same', false, [-(obj.BtnWidth+5) 0]);
        end
        
        function f = drawFields(obj, parent)
            %% Add field to input
            refpos = [0 0 obj.Width obj.Height];
            fields = obj.Fields;
            for i = 1 : height(fields)
                title = fields.title{i};
                value = fields.value{i};
                f = uieditfield(parent, 'Value', value);
%                 f = uicheckbox(parent);
                inppos = f.Position;
                inppos(3) = refpos(3) - 14;
                inpoffset = [0, (height(fields)+1-i) * obj.FieldsGap - 10];
                f.Position = uialign(inppos, refpos, 'center', 'bottom', false, inpoffset);
                lbl = uilabel(parent, 'Text', title);
                lbl.Position(3) = refpos(3) - 5*2;
                lbloffset = [0 inppos(4)];
                uialign(lbl, f.Position, 'left', 'center', false, lbloffset);
                obj.UIFields = [obj.UIFields; f];
            end
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.UIOverlay);
        end
        
    end
end