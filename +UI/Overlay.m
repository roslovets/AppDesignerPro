classdef Overlay < handle
    %% Show empty dialog panel in uifigure
    %   Allows to create custom dialogs embedded in uifigures and apps
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io
    
    properties
        UIFigure        % Parent uifigure
        UIPanel         % Overlay uipanel
        Title           % Overlay panel title
        Root            % UI root of overlay
        Height          % Overlay dialog height
        Width           % Overlay dialog Width
        BackgroundColor % Background color
    end
    
    methods
        function obj = Overlay(varargin)
            %% Constructor
            p = inputParser();
            p.addOptional('uifig', []);
            p.addParameter('Title', '', @(x)ischar(x)||isstring(x));
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
            obj.Title = args.Title;
            obj.Height = args.Height;
            obj.Width = args.Width;
            obj.BackgroundColor = args.BackgroundColor;
            obj.redraw();
            if args.Show
                obj.show();
            end
        end
        
        function show(obj)
            %% Show dialog
            obj.Root.Visible = 'on';
        end
        
        function hide(obj)
            %% Hide dialog
            obj.Root.Visible = 'off';
        end
        
        function redraw(obj)
            %% Initialize UI
            if ~isempty(obj.Root) && isvalid(obj.Root)
                delete(obj.Root);
            end
            obj.Root = uigridlayout(obj.UIFigure, 'Visible', 'off');
            obj.Root.RowHeight = {'1x'};
            obj.Root.ColumnWidth = {'1x'};
            obj.Root.Padding = 0;
            if strcmpi(string(obj.BackgroundColor), 'none')
                parent = obj.Root;
            else
                parent = uipanel(obj.Root, 'BackgroundColor', obj.BackgroundColor);
            end
            grid2 = uigridlayout(parent);
            grid2.RowHeight = {'1x', obj.Height, '1x'};
            grid2.ColumnWidth = {'1x', obj.Width, '1x'};
            obj.UIPanel = uipanel(grid2);
            obj.UIPanel.Layout.Row = 2;
            obj.UIPanel.Layout.Column = 2;
            if ~isempty(obj.Title)
                obj.UIPanel.Title = obj.Title;
            end
        end
        
        function yes = isVisible(obj)
            %% Check overlay is visible
            yes = obj.Root.Visible == "on";
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.Root);
        end
        
    end
end