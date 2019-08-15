classdef Animation < handle
    %ANIMATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UI
        AnimationTime = 0.25
        FrameRate = 25
        Worker
    end
    
    methods
        function obj = Animation(ui)
            %% Constructor
            obj.UI = ui;
            obj.Worker = AsyncWorker();
        end
        
        function start(obj)
            %% Start animation
            obj.Worker.start();
        end
        
        function add(obj, type, x, y)
            %% Add animation
            switch lower(type)
                case 'slide'
                    obj.addSlide(x, y);
                case 'zoom'
                    obj.addZoom(x, y);
                case 'roll'
                    obj.addRoll(x, y);
                otherwise
                    obj.validate(type);
            end
        end
        
        function addSlide(obj, x, y)
            %% Add slide animation
            [x, y] = obj.vectorize(x, y);
            uipos = obj.UI.Position;
            pos = [x' y' repmat([uipos(3) uipos(4)], length(x), 1)];
            obj.addAnimTask(pos);
        end
        
        function addZoom(obj, xs, ys)
            %% Add zoom animation
            [xs, ys] = obj.vectorize(xs, ys);
            uipos = obj.UI.Position;
            pos = zeros(length(xs), 4);
            pos(:, [3 4]) = uipos([3 4]) .* [xs' ys'];
            pos(:, [1 2]) = uipos([1 2]) + uipos([3 4])/2 - pos(:, [3 4])/2;
            obj.addAnimTask(pos);
        end
        
        function addRoll(obj, xs, ys)
            %% Add zoom animation
            [xs, ys] = obj.vectorize(xs, ys);
            uipos = obj.UI.Position;
            pos = repmat(uipos, length(xs), 1);
            pos(:, [3 4]) = [xs' ys'] .* pos(:, [3 4]);
            obj.addAnimTask(pos);
        end
        
        function addDelay(obj, delay)
            %% Add delay task
            obj.Worker.addDelay(delay);
        end
        
        function addTask(obj, varargin)
            %% Add task to worker
            obj.Worker.addTask(varargin{:});
        end
        
        function addAnimTask(obj, pos)
            %% Add animation task to worker
            iters = size(pos, 1);
            step = 1 / obj.FrameRate;
            obj.Worker.addRepeatedTask(@(w, ~) obj.animate(w, pos), step, iters);
        end
        
        function animate(obj, worker, pos)
            %% Animate figure
            i = worker.getCurrentIteration();
            if ~isempty(obj.UI) && isvalid(obj.UI)
                obj.UI.Position = pos(i, :);
            else
                worker.stop();
            end
        end
        
        function [x, y] = vectorize(obj, x, y)
            %% Vectorize inputs
            if isscalar(x)
                x = [x x];
            end
            if isscalar(y)
                y = [y y];
            end
            pnum = floor(obj.AnimationTime * obj.FrameRate);
            x = linspace(x(1), x(2), pnum);
            y = linspace(y(1), y(2), pnum);
        end
        
        function delete(obj)
            %% Destructor
            delete(obj.Worker);
        end
        
    end
    
    
    methods (Static)
        
        function validate(type)
            %% Validate animation type
            if ~isempty(type)
                type = lower(type);
                typelist = ["slide" "zoom" "roll" "none"];
                if ~ismember(type, typelist)
                    error('Unknown animation: %s. Use one of the: %s', type, join(typelist, '|'));
                end
            end
        end
        
    end
end