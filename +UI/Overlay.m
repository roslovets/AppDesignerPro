classdef Overlay < handle
    %GUIINPUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UIFigure
        Body
        Main
        Height
        Width
        BackgroundColor
    end
    
    methods
        function obj = Overlay(varargin)
            %% Constructor
            p = inputParser();
            p.addOptional('uifig', []);
            p.addParameter('Height', 100);
            p.addParameter('Width', 200);
            p.addParameter('BackgroundColor', [0.651 0.651 0.651]);
            p.addParameter('Show', true);
            p.parse(varargin{:});
            args = p.Results;
            if isempty(args.uifig)
                obj.UIFigure = uifigure;
            else
                obj.UIFigure = args.uifig;
            end
            obj.Height = args.Height;
            obj.Width = args.Width;
            obj.BackgroundColor = args.BackgroundColor;
            obj.redraw();
        end
        
        
        function show(obj)
            %% Show input
            obj.Body.Visible = 'on';
        end
        
        function hide(obj)
            %% Show input
            obj.Body.Visible = 'off';
        end
        
        function redraw(obj)
            %% Initialize Body
            if ~isempty(obj.Body) && isvalid(obj.Body)
                delete(obj.Body);
            end
            obj.Body = uigridlayout(obj.UIFigure);
            obj.Body.RowHeight = {'1x'};
            obj.Body.ColumnWidth = {'1x'};
            obj.Body.Padding = 0;
            if strcmpi(string(obj.BackgroundColor), 'none')
                parent = obj.Body;
            else
                parent = uipanel(obj.Body, 'BackgroundColor', obj.BackgroundColor);
            end
            grid2 = uigridlayout(parent);
            grid2.RowHeight = {'1x', obj.Height, '1x'};
            grid2.ColumnWidth = {'1x', obj.Width, '1x'};
            obj.Main = uipanel(grid2);
            obj.Main.Layout.Row = 2;
            obj.Main.Layout.Column = 2;
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.Body);
        end
        
    end
end

