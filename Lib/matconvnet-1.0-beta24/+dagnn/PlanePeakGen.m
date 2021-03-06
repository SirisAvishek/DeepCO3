classdef PlanePeakGen < dagnn.ElementWise
    properties
        BatchSize = [];
        PeakMasks = [];
        ThresholdFun = @(X)median(X);
        NumPositiveData = [];
        EnblePeakBack = false;
    end
    
    methods
        function outputs = forward(obj, inputs, params)
            obj.BatchSize = size(inputs{1});
            if length(obj.BatchSize) == 2
                obj.BatchSize = [obj.BatchSize 1 1];
            end
            obj.PeakMasks = gpuArray.false(obj.BatchSize);
            obj.NumPositiveData = zeros(1,  obj.BatchSize(end));
            PositiveData = gpuArray.zeros(obj.BatchSize(end), 1, 'single');
            
            for i = 1:obj.BatchSize(end)
                TempMap = inputs{1}(:,:,:,i);
                obj.PeakMasks(:,:,:,i) = imregionalmax(TempMap) ...
                    & TempMap >= obj.ThresholdFun(TempMap(:));
                TeampData = TempMap(obj.PeakMasks(:,:,:,i));
                obj.NumPositiveData(i) = length(TeampData);
                PositiveData(i) = mean(TeampData);
            end
            outputs = {PositiveData};
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
            if ~obj.EnblePeakBack
                derInputs{1} = gpuArray.zeros(obj.BatchSize, 'single');
                for i = 1:obj.BatchSize(end)
                    TempPeakMasks = obj.PeakMasks(:,:,:,i);
                    TempDerInputs = derInputs{1}(:,:,:,i);
                    TempDerInputs(TempPeakMasks) = derOutputs{1}(i) / obj.NumPositiveData(i);
                    derInputs{1}(:,:,:,i) = TempDerInputs;
                end
            else
                derInputs{1} = derOutputs{1};
            end
            derParams = {};
        end
        
        
        function obj = PlanePeakGen(varargin)
            obj.load(varargin) ;
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 