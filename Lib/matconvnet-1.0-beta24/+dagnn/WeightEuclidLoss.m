classdef WeightEuclidLoss < dagnn.Loss
  properties
    WeightMat = []
  end

  methods
    function outputs = forward(obj, inputs, params)
      Mask = inputs{2} > mean(mean(inputs{2}, 1), 2);
      obj.WeightMat = gpuArray.ones(size(Mask));
      NegativeRatio = mean(mean(Mask, 1), 2) .* single(Mask == 0); % inverse
      PostiveRatio = mean(mean(Mask == 0, 1), 2) .* single(Mask == 1); % inverse
      obj.WeightMat(Mask == 0) = NegativeRatio(Mask == 0);
      obj.WeightMat(Mask) = PostiveRatio(Mask);
      outputs{1} = obj.WeightMat .* (inputs{1} - inputs{2}) .^ 2;
      outputs{1} = sum(outputs{1}(:)) / (size(inputs{1},1) * size(inputs{1},2));
      n = obj.numAveraged;  
      m = n + size(inputs{1},4) ;
      obj.average = (n * obj.average + double(gather(outputs{1}))) / m ;
      obj.numAveraged = m;
    end

    function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
      derInputs{1} = derOutputs{1} * obj.WeightMat .* (2 * (inputs{1} - inputs{2})) / (size(inputs{1},1) * size(inputs{1},2));
      derInputs{2} = []; 
      derParams = {};
    end
    
    function reset(obj)
      obj.average = 0 ;
      obj.numAveraged = 0 ;
    end
  
    function obj = EuclidLoss(varargin)
      obj.load(varargin) ;
    end
  end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         