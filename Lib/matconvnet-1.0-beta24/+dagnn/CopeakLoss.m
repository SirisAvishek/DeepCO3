classdef CopeakLoss < dagnn.Loss
    properties
        eps = 10^-5;
        NumInputs = [];
        c = [];
        x = [];
    end
    
    methods
        function outputs = forward(obj, inputs, params)
            if length(inputs) == 2
                obj.NumInputs = [length(inputs{1}) length(inputs{2})];
                obj.c = cat(1, gpuArray.ones(obj.NumInputs(1), 1), -gpuArray.ones(obj.NumInputs(2), 1));
                obj.x = cat(1, inputs{1}, inputs{2});
                a = -obj.c.*obj.x ;
                b = max(0, a) ;
                t = b + log(exp(-b) + exp(a-b)) ;
                outputs{1} = mean(t(1:obj.NumInputs(1))) + mean(t(obj.NumInputs(1)+1:end));
                NumData = length(inputs{1}) + length(inputs{2});
            else
                obj.NumInputs = length(inputs{1});
                obj.c = gpuArray.ones(obj.NumInputs(1), 1);
                obj.x = inputs{1};
                a = -obj.c.*obj.x ;
                b = max(0, a) ;
                t = b + log(exp(-b) + exp(a-b)) ;
                outputs{1} = mean(t);
                NumData = length(inputs{1});
            end
            n = obj.numAveraged;
            m = n + NumData;
            obj.average = (n * obj.average + double(gather(outputs{1} * NumData))) / m ;
            obj.numAveraged = m;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
            y = - derOutputs{1} .* obj.c ./ (1 + exp(obj.c.*obj.x)) ;
            derInputs{1} = y(1:obj.NumInputs(1)) / obj.NumInputs(1);
            if length(inputs) == 2
                derInputs{2} = y(obj.NumInputs(1)+1:end) / obj.NumInputs(2);
            end
            derParams = {};
        end
        
        function reset(obj)
            obj.average = 0 ;
            obj.numAveraged = 0 ;
        end
        function obj = CopeakLoss(varargin)
            obj.load(varargin) ;
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 