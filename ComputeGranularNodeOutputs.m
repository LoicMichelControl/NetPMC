function [GranularOutputs] = ComputeGranularNodeOutputs(CommonNeuron, CommonWiring_sort)
% ComputeGranularNodeOutputs - Compute multiple outputs per node using input combinations
%
% This function replaces the single weighted sum computation with a granular
% approach that computes outputs for all possible combinations of inputs.
%
% INPUTS:
%   CommonNeuron      - 3D matrix [nodes x (1+inputs) x 2]
%                       (:, :, 1) = Neuron IDs and connectivity structure
%                       (:, :, 2) = Current input values
%                       (:, 1, :) = Node ID
%                       (:, 2+, :) = Connected input neurons
%
%   CommonWiring_sort - 3D matrix [nodes x (1+inputs) x 2]
%                       (:, :, 1) = Wire indices
%                       (:, :, 2) = Wire weights
%
% OUTPUTS:
%   GranularOutputs   - Cell array of length = number of nodes
%                       Each cell contains a struct with:
%                         .NodeID          - ID of the node
%                         .NumInputs       - Number of inputs to this node
%                         .InputValues     - 1 x N vector of input values
%                         .InputWeights    - 1 x N vector of weights
%                         .MaskMatrix      - M x N binary mask (M = 2^N - 1)
%                         .OutputMatrix    - M x (N+1) matrix
%                                            Column 1: Output values
%                                            Columns 2+: Mask used
%                         .SingleOutput    - The traditional full output (all inputs)
%
% USAGE:
%   Replace the original computation loop:
%     OLD CODE:
%       for row = 1:length(CommonNeuron(:,1,1))
%           Prod(row) = CommonNeuron(row, 2:end, 2) * CommonWiring_sort(row, 2:end, 2)';
%       end
%
%     NEW CODE:
%       GranularOutputs = ComputeGranularNodeOutputs(CommonNeuron, CommonWiring_sort);
%
% EXAMPLE:
%   If a node has 3 inputs with values [2, 3, 5] and weights [0.5, 0.3, 0.2]:
%   - Traditional output: 2*0.5 + 3*0.3 + 5*0.2 = 2.9
%   - Granular outputs: 7 combinations (2^3 - 1)
%       1) [1.0] using input 1 only
%       2) [0.9] using input 2 only
%       3) [1.0] using input 3 only
%       4) [1.9] using inputs 1+2
%       5) [2.0] using inputs 1+3
%       6) [1.9] using inputs 2+3
%       7) [2.9] using inputs 1+2+3 (same as traditional)
%
% AUTHOR: NetPMC Granularity Extension
% DATE: 2025-11-02

    % Get number of nodes
    numNodes = size(CommonNeuron, 1);

    % Initialize output cell array
    GranularOutputs = cell(numNodes, 1);

    % Process each node
    for row = 1:numNodes

        % Get node ID
        nodeID = CommonNeuron(row, 1, 1);

        % Get number of inputs (exclude first column which is node ID)
        le_CommonNeuron = size(CommonNeuron, 2);
        numInputs = le_CommonNeuron - 1;

        % Extract input values and weights
        inputValues = CommonNeuron(row, 2:le_CommonNeuron, 2);
        inputWeights = CommonWiring_sort(row, 2:le_CommonNeuron, 2);

        % Reshape to row vectors (ensure 1 x N format)
        inputValues = reshape(inputValues, 1, []);
        inputWeights = reshape(inputWeights, 1, []);

        % Generate combination masks dynamically
        MaskMatrix = GenerateCombinationMasks(numInputs);

        % Compute masked outputs for all combinations
        OutputMatrix = ComputeMaskedOutputs(inputValues, inputWeights, MaskMatrix);

        % The last row of OutputMatrix is the full combination (all inputs)
        % This matches the traditional single output
        singleOutput = OutputMatrix(end, 1);

        % Store results in structured format
        GranularOutputs{row} = struct( ...
            'NodeID', nodeID, ...
            'NumInputs', numInputs, ...
            'InputValues', inputValues, ...
            'InputWeights', inputWeights, ...
            'MaskMatrix', MaskMatrix, ...
            'OutputMatrix', OutputMatrix, ...
            'SingleOutput', singleOutput ...
        );

    end

end
