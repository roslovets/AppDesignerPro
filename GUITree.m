classdef GUITree
    %GUITREE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        GUI
        LeafIcon
    end
    
    methods
        function obj = GUITree(guiobj)
            %% GUI Tree
            obj.GUI = guiobj;
        end
        
        function node = addNode(obj, tree, name, data, icon)
            %% Add one node
            if nargin < 2
                tree = obj.GUI;
            end
            node = uitreenode(tree, 'Text', name);
            if nargin > 3
                node.NodeData = data;
            end
            if nargin > 4 && ~isempty(icon)
                node.Icon = icon;
            end
        end
        
        function addNodes(obj, s, tree)
            %% Add several nodes
            if nargin < 3
                tree = obj.GUI;
            end
            if isstruct(s)
                fs = fieldnames(s);
                for i = 1 : length(fs)
                    data = s.(fs{i});
                    if isstruct(data)
                        node = obj.addNode(tree, fs{i});
                    else
                        node = obj.addNode(tree, fs{i}, data, obj.LeafIcon);
                    end
                    obj.addNodes(s.(fs{i}), node);
                end
            end
        end
        
        function [path, key] = getNodePath(obj, tree)
            %% Get path of node
            if nargin < 2
                tree = obj.GUI;
            end
            if class(tree) == "matlab.ui.container.Tree"
                node = tree.SelectedNodes;
            else
                node = tree;
            end
            path = string(node.Text);
            while class(node.Parent) == "matlab.ui.container.TreeNode"
                node = node.Parent;
                path = [string(node.Text); path];
            end
            key = join(path, '.');
        end
        
        function map = getNodesList(obj, tree, map, prefix)
            %% Get nodes list
            if nargin < 2
                tree = obj.GUI;
            end
            node = tree;
            if nargin < 3
                map = string([]);
            end
            if nargin < 4
                prefix = "";
            end
            if class(node) == "matlab.ui.container.TreeNode"
                if prefix ~= ""
                    prefix = prefix + "." + node.Text;
                else
                    prefix = prefix + node.Text;
                end
            else
                prefix = "";
            end
            for i = 1 : length(node.Children)
                ch = node.Children(i);
                if isempty(ch.Children)
                    map = [map; prefix + "." + string(ch.Text)];
                end
                map = obj.getNodesList(ch, map, prefix);
            end
        end
        
        function select(obj, value)
            %% Select node
            tree = obj.GUI;
            path = split(value, '.');
            nodes = tree.Children;
            i = 1;
            while 1
                isNode = arrayfun(@(x) x.Text==path(i), nodes);
                if any(isNode)
                    num = find(isNode);
                    node = nodes(num(1));
                    tree.SelectedNodes = node;
                    scroll(tree, node);
                    nodes = node.Children;
                    i = i + 1;
                    if i > length(path)
                        break;
                    end
                else
                    break
                end
                if isempty(nodes)
                    break
                end
            end
        end
        
        function clear(obj)
            %% Delete children
            delete(obj.GUI.Children);
        end
        
    end
end

