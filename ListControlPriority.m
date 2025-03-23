    
% This function gives the priority index (rank) that is associated to each
% neuron in a table similar to the the 'CommonWiringList' 

function PriorityControlMatrix = ListControlPriority ( CommonWiringList,  ConnectedIDNeuron )
    
    % Sweeps each neuron of the 'CommonWiringList' 
    for ii = 1:length( CommonWiringList(:,1) )
    
        for jj = 1:length( CommonWiringList(1,:) )-1 % sweep the two first columns
    
            % For a (ii,jj) particular neuron, find the index of the
            % neuron in the 'ConnectedIDNeuron' matrix
            found_rank_priority = find(CommonWiringList(ii, jj) == ConnectedIDNeuron(1,:));

        if ( isempty(found_rank_priority) == 0)

        % For a (ii,jj) particular neuron, assign - similarly to 'CommonWiringList' - the #priority of this neurons given
        % in the 'found_rank_priority' index 
        PriorityControlMatrix(ii,jj) = ConnectedIDNeuron(2,found_rank_priority(1));

        else
        PriorityControlMatrix(ii,jj) =  -99;
        end

        end
    
    end

% Example:

    % CommonWiringList =
% 
%      3    11    32
%      3    12    33
%      5    11    54
%      5    12    55


% ConnectedIDNeuron =
% 
%     12     5     1     1
%     11     3     2     2




