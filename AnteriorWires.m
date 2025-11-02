
% This function sorts all wires index that are not connected to the CurrentNeuron
% -> helps to determine which wires can be slow down for the control
% dynamics 


% (example) WiringSortList =
% 
%      3    10    31
%      3    11    32
%      3    12    33
%      4    10    42
%     ...  ...   ...

function SortAnteriorWires = AnteriorWires(WiringSortList, CurrentNeuron, Rank_ConnectedIDNeuron)

            SortAnteriorWires = [];
            
        if Rank_ConnectedIDNeuron > 2
 
            for ii = 1:length( WiringSortList(:,1) )
    
                % Check if the neuron from the WiringSortList is NOT equal
                % to the current neuron
                if ( ( WiringSortList(ii,1) == CurrentNeuron(1) || WiringSortList(ii,2) == CurrentNeuron(1) ) == 0 )
                    
                        SortAnteriorWires = [ SortAnteriorWires, WiringSortList(ii,3) ];
    
                end
    
            end
        end






