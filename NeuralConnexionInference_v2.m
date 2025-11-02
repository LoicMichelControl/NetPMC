    
    
function [RandomNeuronVector, newConnectedID, ConnectedIDNeuron, Rank_ConnectedIDNeuron, Neuron, SortConnectedIDNeuron, PriorityNewNeuron_ ] = ...
        NeuralConnexionInference_v2(ConnectedIDNeuron,  ...
        Neuron, ...
        Rank_ConnectedIDNeuron, ...
        PriorityNewNeuron_, ...
        maxNeurons, ...
        RandomNeuronVector)
    
    % The goal is to connect a new neuron 'Target neuron' in a pseuo-random
    % manner
    
    
    ExcludedNeurons = []; % May not be used ? see in future versions -> !!!not set as output variable of the function!!!!
    
    % List all the connected neurons excluding the input neurons (not listed in the vector):
    SortConnectedIDNeuron = sort( unique ( ConnectedIDNeuron ) );
        
    % Increase the Rank of the ConnectedIDNeuron matrix
    Rank_ConnectedIDNeuron = Rank_ConnectedIDNeuron + 1;

    % Assign the new connected neuron ID from the 'RandomNeuronVector'
    newConnectedID = RandomNeuronVector(1,  Rank_ConnectedIDNeuron );
    
            % ConnectedIDNeuron matrix mapping:
        %
        % ConnectedIDNeuron[1, Rank_ConnectedIDNeuron = 1 ] :  NewNeuron_1
        % ConnectedIDNeuron[2, Rank_ConnectedIDNeuron = 1 ] :  PriorityNewNeuron_1
        % ConnectedIDNeuron[3, Rank_ConnectedIDNeuron = 1 ] :  Group

        % ConnectedIDNeuron[1, Rank_ConnectedIDNeuron = 2 ] :  NewNeuron_2
        % ConnectedIDNeuron[2, Rank_ConnectedIDNeuron = 2 ] :  PriorityNewNeuron_2
        % ConnectedIDNeuron[3, Rank_ConnectedIDNeuron = 2 ] :  Group
        
    ConnectedIDNeuron(1, Rank_ConnectedIDNeuron) = newConnectedID;
    ConnectedIDNeuron(2, Rank_ConnectedIDNeuron) = Rank_ConnectedIDNeuron;
    ConnectedIDNeuron(3, Rank_ConnectedIDNeuron) = RandomNeuronVector(2,Rank_ConnectedIDNeuron);
    
    % Update PriorityNewNeuron to prepare the next 'ordered' neuron
   % PriorityNewNeuron = PriorityNewNeuron + 1;
