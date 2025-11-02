function [MaskMatrix] = GenerateCombinationMasks(numInputs)
% GenerateCombinationMasks - Generate all possible input combination masks
%
% INPUTS:
%   numInputs - Number of inputs to the node
%
% OUTPUTS:
%   MaskMatrix - (2^numInputs - 1) x numInputs binary matrix
%                Each row represents one combination of inputs
%                1 = input is included, 0 = input is excluded
%
% EXAMPLE:
%   For numInputs = 3:
%   MaskMatrix = [
%       0 0 1   % Only input 3
%       0 1 0   % Only input 2
%       0 1 1   % Inputs 2 and 3
%       1 0 0   % Only input 1
%       1 0 1   % Inputs 1 and 3
%       1 1 0   % Inputs 1 and 2
%       1 1 1   % All inputs
%   ]
%
% AUTHOR: NetPMC Granularity Extension
% DATE: 2025-11-02

    % Calculate total number of combinations (excluding empty set)
    numCombinations = 2^numInputs - 1;

    % Pre-allocate mask matrix
    MaskMatrix = zeros(numCombinations, numInputs);

    % Generate all combinations from 1 to 2^numInputs - 1
    for i = 1:numCombinations
        % Convert decimal number to binary representation
        binaryRep = dec2bin(i, numInputs);

        % Convert binary string to numeric array
        % Note: dec2bin returns MSB first, so reverse for input ordering
        for j = 1:numInputs
            MaskMatrix(i, j) = str2double(binaryRep(j));
        end
    end

end
