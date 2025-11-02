% Test_GranularNodeOutputs.m
%
% Example script demonstrating the granular node output computation
% with input combination masking.
%
% This script shows:
% 1. How to create test node matrices
% 2. How to call the granular computation functions
% 3. How to interpret and use the results
%
% AUTHOR: NetPMC Granularity Extension
% DATE: 2025-11-02

clear all;
close all;
clc;

fprintf('\n========================================\n');
fprintf('GRANULAR NODE OUTPUTS - TEST SCRIPT\n');
fprintf('========================================\n\n');

%% EXAMPLE 1: Simple 3-input node

fprintf('--- EXAMPLE 1: Node with 3 inputs ---\n\n');

% Create a simple test case: 1 node with 3 inputs
% CommonNeuron format: [NodeID, Input1_ID, Input2_ID, Input3_ID]
% Layer 1: IDs, Layer 2: Values

CommonNeuron_test = zeros(1, 4, 2);
CommonNeuron_test(1, :, 1) = [9, 1, 2, 3];  % Node 9 receives from nodes 1, 2, 3
CommonNeuron_test(1, :, 2) = [0, 2, 3, 5];  % Values: node 9=0 (will be computed), inputs=[2,3,5]

% CommonWiring_sort format: [NodeID, Wire1_ID, Wire2_ID, Wire3_ID]
% Layer 1: Wire IDs, Layer 2: Weights

CommonWiring_sort_test = zeros(1, 4, 2);
CommonWiring_sort_test(1, :, 1) = [9, 30, 31, 32];      % Wire IDs
CommonWiring_sort_test(1, :, 2) = [0, 0.5, 0.3, 0.2];   % Weights

% Display input setup
fprintf('Node Setup:\n');
fprintf('  Node ID: %d\n', CommonNeuron_test(1,1,1));
fprintf('  Number of inputs: 3\n');
fprintf('  Input values: [%.1f, %.1f, %.1f]\n', ...
    CommonNeuron_test(1,2,2), CommonNeuron_test(1,3,2), CommonNeuron_test(1,4,2));
fprintf('  Input weights: [%.1f, %.1f, %.1f]\n\n', ...
    CommonWiring_sort_test(1,2,2), CommonWiring_sort_test(1,3,2), CommonWiring_sort_test(1,4,2));

% Compute traditional single output
traditional_output = CommonNeuron_test(1, 2:4, 2) * CommonWiring_sort_test(1, 2:4, 2)';
fprintf('Traditional Output (all inputs): %.2f\n', traditional_output);
fprintf('  Calculation: 2*0.5 + 3*0.3 + 5*0.2 = %.2f\n\n', traditional_output);

% Compute granular outputs
GranularOutputs = ComputeGranularNodeOutputs(CommonNeuron_test, CommonWiring_sort_test);

% Display granular results
result = GranularOutputs{1};
fprintf('Granular Outputs (%d combinations):\n', size(result.OutputMatrix,1));
fprintf('%-6s %-10s %-20s %-15s\n', 'Comb', 'Value', 'Mask', 'Calculation');
fprintf('%-6s %-10s %-20s %-15s\n', '----', '-----', '----', '-----------');

for i = 1:size(result.OutputMatrix, 1)
    value = result.OutputMatrix(i, 1);
    mask = result.OutputMatrix(i, 2:end);

    % Build calculation string
    calc_str = '';
    first = true;
    for j = 1:length(mask)
        if mask(j) == 1
            if ~first
                calc_str = [calc_str ' + '];
            end
            calc_str = sprintf('%s%.1f*%.1f', calc_str, ...
                result.InputValues(j), result.InputWeights(j));
            first = false;
        end
    end

    fprintf('%-6d %-10.2f [%d %d %d]            %s\n', ...
        i, value, mask(1), mask(2), mask(3), calc_str);
end

fprintf('\nNote: Combination %d matches the traditional output!\n\n', size(result.OutputMatrix,1));

%% EXAMPLE 2: Multiple nodes with different input counts

fprintf('\n--- EXAMPLE 2: Multiple nodes with varying inputs ---\n\n');

% Node 1: 2 inputs
% Node 2: 3 inputs
% Node 3: 4 inputs

CommonNeuron_multi = zeros(3, 5, 2);
CommonWiring_sort_multi = zeros(3, 5, 2);

% Node 1: 2 inputs (will have 3 combinations: 2^2-1=3)
CommonNeuron_multi(1, 1:3, 1) = [5, 1, 2];
CommonNeuron_multi(1, 1:3, 2) = [0, 4, 6];
CommonWiring_sort_multi(1, 1:3, 1) = [5, 10, 11];
CommonWiring_sort_multi(1, 1:3, 2) = [0, 0.6, 0.4];

% Node 2: 3 inputs (will have 7 combinations: 2^3-1=7)
CommonNeuron_multi(2, 1:4, 1) = [7, 1, 2, 3];
CommonNeuron_multi(2, 1:4, 2) = [0, 2, 3, 5];
CommonWiring_sort_multi(2, 1:4, 1) = [7, 20, 21, 22];
CommonWiring_sort_multi(2, 1:4, 2) = [0, 0.5, 0.3, 0.2];

% Node 3: 4 inputs (will have 15 combinations: 2^4-1=15)
CommonNeuron_multi(3, 1:5, 1) = [9, 1, 2, 3, 4];
CommonNeuron_multi(3, 1:5, 2) = [0, 1, 2, 3, 4];
CommonWiring_sort_multi(3, 1:5, 1) = [9, 30, 31, 32, 33];
CommonWiring_sort_multi(3, 1:5, 2) = [0, 0.4, 0.3, 0.2, 0.1];

% Compute granular outputs for all nodes
GranularOutputs_multi = ComputeGranularNodeOutputs(CommonNeuron_multi, CommonWiring_sort_multi);

% Display summary
fprintf('Summary of Multiple Nodes:\n');
fprintf('%-8s %-12s %-18s %-15s\n', 'Node ID', 'Num Inputs', 'Combinations', 'Single Output');
fprintf('%-8s %-12s %-18s %-15s\n', '-------', '----------', '------------', '-------------');

for i = 1:length(GranularOutputs_multi)
    result = GranularOutputs_multi{i};
    fprintf('%-8d %-12d %-18d %-15.3f\n', ...
        result.NodeID, result.NumInputs, ...
        size(result.OutputMatrix, 1), result.SingleOutput);
end

fprintf('\n');

%% EXAMPLE 3: Accessing specific combinations

fprintf('\n--- EXAMPLE 3: Accessing specific output combinations ---\n\n');

% Using the first node from Example 1
result = GranularOutputs{1};

fprintf('For Node %d with inputs [2, 3, 5]:\n\n', result.NodeID);

% Find and display output using only first input
mask_first_only = [1 0 0];
for i = 1:size(result.OutputMatrix, 1)
    if isequal(result.OutputMatrix(i, 2:end), mask_first_only)
        fprintf('Output using ONLY first input:\n');
        fprintf('  Value: %.2f\n', result.OutputMatrix(i, 1));
        fprintf('  Mask: [%d %d %d]\n\n', result.OutputMatrix(i, 2:end));
    end
end

% Find and display output using first two inputs
mask_first_two = [1 1 0];
for i = 1:size(result.OutputMatrix, 1)
    if isequal(result.OutputMatrix(i, 2:end), mask_first_two)
        fprintf('Output using first TWO inputs:\n');
        fprintf('  Value: %.2f\n', result.OutputMatrix(i, 1));
        fprintf('  Mask: [%d %d %d]\n\n', result.OutputMatrix(i, 2:end));
    end
end

% Display all outputs
fprintf('All output values:\n');
fprintf('  ');
fprintf('%.2f  ', result.OutputMatrix(:, 1));
fprintf('\n\n');

%% EXAMPLE 4: Direct function usage

fprintf('\n--- EXAMPLE 4: Direct usage of helper functions ---\n\n');

% Test mask generation
fprintf('Test 1: Generate masks for 4 inputs\n');
masks_4 = GenerateCombinationMasks(4);
fprintf('Number of combinations for 4 inputs: %d (expected: 2^4-1 = 15)\n', size(masks_4, 1));
fprintf('First 5 masks:\n');
disp(masks_4(1:5, :));

% Test masked output computation
fprintf('Test 2: Direct masked computation\n');
test_inputs = [1, 2, 3];
test_weights = [0.5, 0.3, 0.2];
test_masks = [1 0 0; 0 1 0; 1 1 1];  % Custom masks

outputs = ComputeMaskedOutputs(test_inputs, test_weights, test_masks);
fprintf('Inputs: [%.1f, %.1f, %.1f]\n', test_inputs);
fprintf('Weights: [%.1f, %.1f, %.1f]\n', test_weights);
fprintf('Custom masks:\n');
disp(test_masks);
fprintf('Resulting outputs:\n');
disp(outputs);

fprintf('\n========================================\n');
fprintf('TEST SCRIPT COMPLETE\n');
fprintf('========================================\n\n');
