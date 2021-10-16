classdef DataController < handle
    %% Bind UI components to data
    %   Author: Pavel Roslovets, ETMC Exponenta
    %           https://roslovets.github.io

    properties (Hidden)
        Data
        DataObject = []
        DataProperty (1,1) string = missing
        DataReadFcn
        DataWriteFcn
    end

    methods

        function obj = DataController(opts)
            %% Initialize object
            arguments
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.bindData(Data=opts.Data, ...
                DataObject=opts.DataObject, DataProperty=opts.DataProperty, ...
                DataReadFcn=opts.DataReadFcn, DataWriteFcn = opts.DataWriteFcn);
        end

        function bindData(obj, opts)
            %% Bind data or data source to controller
            arguments
                obj
                opts.Data = []
                opts.DataObject = []
                opts.DataProperty (1,1) string = missing
                opts.DataReadFcn = []
                opts.DataWriteFcn = []
            end
            obj.Data = opts.Data;
            obj.DataObject = opts.DataObject;
            obj.DataProperty = opts.DataProperty;
            obj.DataReadFcn = opts.DataReadFcn;
            obj.DataWriteFcn = opts.DataWriteFcn;
        end

        function isE = isEmpty(obj)
            %% DataController is empty
            isE = isempty(obj.Data) && isempty(obj.DataObject) &&...
                isempty(obj.DataReadFcn) && isempty(obj.DataWriteFcn);
        end

        function value = readData(obj)
            %% Read data from source
            if ~isempty(obj.DataReadFcn)
                value = obj.DataReadFcn();
            elseif ~ismissing(obj.DataProperty)
                value = obj.DataObject.(obj.DataProperty);
            else
                value = obj.Data;
            end
        end

        function writeData(obj, value)
            %% Write data to source
            if ~isempty(obj.DataWriteFcn)
                obj.DataWriteFcn(value);
            elseif ~ismissing(obj.DataProperty)
                obj.DataObject.(obj.DataProperty) = value;
            else
                obj.Data = value;
            end

        end

    end

end
