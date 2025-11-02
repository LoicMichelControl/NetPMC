function [OutputMatrix] = ComputeMaskedOutputs(inputValues, inputWeights, MaskMatrix)
% ComputeMaskedOutputs - Compute multiple outputs using masked combinations
%
% INPUTS:
%   inputValues   - 1 x N vector of input values
%   inputWeights  - 1 x N vector of corresponding weights
%   MaskMatrix    - M x N binary mask matrix (from GenerateCombinationMasks)
%                   Each row defines which inputs to include
%
% OUTPUTS:
%   OutputMatrix  - M x (N+1) matrix where:
%                   Column 1: Output value (masked weighted sum)
%                   Columns 2 to N+1: The mask used (for reference)
%
% COMPUTATION:
%   For each mask row i:
%     OutputMatrix(i,1) = sum(inputValues .* inputWeights .* MaskMatrix(i,:))
%     OutputMatrix(i,2:end) = MaskMatrix(i,:)
%
% EXAMPLE:
%   inputValues = [2, 3, 5];
%   inputWeights = [0.5, 0.3, 0.2];
%   MaskMatrix = [1 0 0; 1 1 0; 1 1 1];
%
%   Result:
%   OutputMatrix(1,:) = [1.0, 1, 0, 0]  % 2*0.5 = 1.0
%   OutputMatrix(2,:) = [1.9, 1, 1, 0]  % 2*0.5 + 3*0.3 = 1.9
%   OutputMatrix(3,:) = [2.9, 1, 1, 1]  % 2*0.5 + 3*0.3 + 5*0.2 = 2.9
%
% AUTHOR: NetPMC Granularity Extension
% DATE: 2025-11-02

    % Get dimensions
    numCombinations = size(MaskMatrix, 1);
    numInputs = length(inputValues);

    % Initialize output matrix
    % Column 1 = output value, Columns 2+ = mask used
    OutputMatrix = zeros(numCombinations, numInputs + 1);

    % Compute masked output for each combination
    for i = 1:numCombinations
        % Get current mask
        currentMask = MaskMatrix(i, :);

        % Apply mask to inputs and weights, then compute weighted sum
        maskedInputs = inputValues .* currentMask;
        maskedWeights = inputWeights .* currentMask;

        % Compute output as dot product
        maskedOutput = sum(maskedInputs .* maskedWeights);

        % Store result and mask
        OutputMatrix(i, 1) = maskedOutput;           % Output value
        OutputMatrix(i, 2:end) = currentMask;        % Mask used
    end

end
