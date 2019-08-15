classdef AsyncWorker < handle
    %AsyncWorker Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data
        Tasks
        CurrentTaskNum = 0
        Running = false
        CurrentTimer
    end
    
    methods
        function obj = AsyncWorker(data)
            %% Constructor
            if nargin > 0
                obj.Data = data;
            end
        end
        
        function start(obj)
            %% Start tasks
            obj.CurrentTaskNum = 1;
            obj.Running = 1;
            tmr = obj.Tasks{1}();
            start(tmr);
            obj.CurrentTimer = tmr;
        end
        
        function stop(obj)
            %% Stop all tasks
            if obj.Running
                obj.Running = false;
                if ~isempty(obj.CurrentTimer) && isvalid(obj.CurrentTimer)
                    stop(obj.CurrentTimer);
                end
            end
        end
        
        function addTask(obj, fcn, delay)
            %% Add task to worker
            if nargin < 3
                delay = 0;
            end
            obj.Tasks = [obj.Tasks; {obj.createTask(fcn, delay)}];
        end
        
        function addDelay(obj, delay)
            %% Add delay to worker
            obj.addTask([], delay);
        end
        
        function addRepeatedTask(obj, fcn, step, iterations, delay)
            %% Add repeated task to worker
            if nargin < 5
                delay = 0;
            end
            obj.Tasks = [obj.Tasks; {obj.createRepeatedTask(fcn, step, iterations, delay)}];
        end
        
        function task = createTask(obj, fcn, time)
            %% Create timed task
            task = @()timer('ExecutionMode', 'singleShot', 'StartDelay', time,...
                'UserData', struct('Iterations', 1, 'CurrentIteration', 1),...
                'TimerFcn', @(tmr,~,~) obj.timerFcn(tmr, fcn),...
                'StopFcn', @(tmr,~,~) obj.timerStopFcn(tmr),...
                'Name', "AsyncWorker Task" + length(obj.Tasks));
        end
        
        function task = createRepeatedTask(obj, fcn, step, iterations, delay)
            %% Create timed task
            task = @()timer('ExecutionMode', 'fixedRate', 'StartDelay', delay,...
                'Period', step, 'BusyMode', 'drop',...
                'UserData', struct('Iterations', iterations, 'CurrentIteration', 1),...
                'TimerFcn', @(tmr,~,~) obj.timerFcn(tmr, fcn),...
                'StopFcn', @(tmr,~,~) obj.timerStopFcn(tmr),...
                'Name', "AsyncWorker Task" + length(obj.Tasks));
        end
        
        function timerFcn(obj, tmr, fcn)
            %% Timer function
            if obj.CurrentTaskNum == 1 && isempty(obj.getData(tmr))
                tmr.UserData.Data = obj.Data;
                obj.CurrentTimer = tmr;
            end
            if ~isempty(fcn) && obj.Running
                if tmr.UserData.CurrentIteration <= tmr.UserData.Iterations
                    data = obj.getData(tmr);
                    if ~isempty(data)
                        tmr.UserData.Data = fcn(obj, data);
                    else
                        fcn(obj);
                    end
                    tmr.UserData.CurrentIteration = tmr.UserData.CurrentIteration + 1;
                else
                    stop(tmr);
                end
            end
        end
        
        function timerStopFcn(obj, tmr)
            %% Timer stop function
            data = obj.getData(tmr);
            delete(tmr);
            if isvalid(obj)
                num = obj.CurrentTaskNum + 1;
                if obj.Running && num <= length(obj.Tasks)
                    nexttimer = obj.Tasks{num}();
                    nexttimer.UserData.Data = data;
                    start(nexttimer);
                    obj.CurrentTaskNum = num;
                    obj.CurrentTimer = nexttimer;
                else
                    obj.Running = false;
                    obj.CurrentTaskNum = 0;
                    obj.CurrentTimer = [];
                    obj.Data = data;
                end
            end
        end
        
        function data = getData(~, tmr)
            %% Get data from timer
            udata = tmr.UserData;
            if ~isempty(udata) && isfield(udata, 'Data')
                data = udata.Data;
            else
                data = [];
            end
        end
        
        function citeration = getCurrentIteration(obj, tmr)
            %% Get iteration from timer
            if nargin < 2
                tmr = obj.CurrentTimer;
            end
            citeration = [];
            if ~isempty(tmr)
                udata = tmr.UserData;
                if ~isempty(udata) && isfield(udata, 'CurrentIteration')
                    citeration = udata.CurrentIteration;
                end
            end
        end
        
        function delete(obj)
            %% Destructor
            if obj.Running
                obj.stop();
            end
        end
        
    end
end
