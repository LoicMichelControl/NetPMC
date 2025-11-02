    
    % This routine double checks if everything is correct among the matrices
    % 'WiringListSub', 'CommonNeuron' and 'CommonWiring_sort'.
    % First check from 'CommonNeuron' if the pair (Neuron_A, Neuron_B)  belongs
    % to the (original) WiringRank -> re-check the index in WiringRank to
    % valide the pair (Neuron_A, Neuron_B) -> then deduce the #wiringRank ( as WiringRank(:,3) ) that
    % must correspond to the same position in 'CommonWiring_sort'.
    % Then verify if the Pivot corresponds to a connected neuron in
    % 'ConnectedIDNeuron'
    % Lastly, check if the priority assigned in to the 'ConnectedIDNeuron'
    % corresponds to the Priority_sort.

    % Warning 'WiringListSub' should be replaced by 'WiringSortList'.
    
    function Error = NodeMatrixChecking_b(InputNeuronID, ListConnectedNeuron, ...
                                        WiringRank, ForbConnexionNeuron_A, ForbConnexionNeuron_B, ...
                                        ForbConnexionNeuron_C, ForbConnexionNeuron_D, WiringListSub, ...
                                        CommonNeuron, CommonWiring_sort, NeuronWeigthList, ...
                                        ConnectedIDNeuron, Priority_sort, OnlyConnectedNeurons_without_Input)
    
    % Example of call:
    %       InputNeuronID, ListConnectedNeuron, WiringRank, 3,                     5,
    %       0,                     0,                     WiringListSub,
    %       CommonNeuron, CommonWiring_sort, NeuronWeigthList,
    %       ConnectedIDNeuron, Priority_sort
    
    CommonWiring_sort(:,:,1)
    
    fprintf('Double check all matrices... \n')
    
    % uncomment this to display 
    % WiringRank
    % 
    % WiringListSub
    % 
    % CommonNeuron
    % 
    % CommonWiring_sort
    
    % Example:
    
    % WiringListSub =
    %
    %      3    11    32
    %      3    12    33
    %      5    11    54
    %      5    12    55
    %
    %
    % CommonNeuron =
    %
    %      3    11    12
    %      5    11    12
    %
    %
    % CommonWiring_sort =
    %
    %      3    32    33
    %      5    54    55
    
    
    Error = 0;
    
    % Take the pivot as connected neuron and sweep

    fprintf('Warning : zero node are automatically removed \n')
    for Pivot = 1:length( CommonNeuron(:,1) )
    
        for jj = 2:length( CommonNeuron(1,:) )
    
            if ( CommonNeuron(Pivot,jj) > -555 && CommonNeuron(Pivot,jj) ~= 0 )
    
                if ( CommonNeuron(Pivot,jj,1) < 0)
                CommonNeuron(Pivot,jj,1) = abs(CommonNeuron(Pivot,jj,1));
                end

                % Simultaneous check of each pair connected neurons (A,B)
                % within 'WiringListSub' and 'WiringRank'
                % Warning : since 'WiringListSub' is a subset of
                % 'WiringRank', connexions can exist only in 'WiringRank'
                % -> display a warning at the end in case of error
                if ( ( ( isempty( find ( WiringListSub(:,1) == CommonNeuron(Pivot,1,1) ) ) == 0 && isempty( find ( WiringListSub(:,2) == CommonNeuron(Pivot,jj,1) ) ) == 0 ) || ...
                       ( isempty( find ( WiringListSub(:,2) == CommonNeuron(Pivot,1,1) ) ) == 0 && isempty( find ( WiringListSub(:,1) == CommonNeuron(Pivot,jj,1) ) ) == 0 ) ) && ...
                     ( ( isempty( find ( WiringRank(:,1) == CommonNeuron(Pivot,1,1) ) ) == 0 && isempty( find ( WiringRank(:,2) == CommonNeuron(Pivot,jj,1) ) ) == 0 ) || ...
                       ( isempty( find ( WiringRank(:,2) == CommonNeuron(Pivot,1,1) ) ) == 0 && isempty( find ( WiringRank(:,1) == CommonNeuron(Pivot,jj,1) ) ) == 0 ) ) )
   

                    if ( isempty( find ( WiringRank(:,1) == CommonNeuron(Pivot,1,1) ) ) == 0 && isempty( find ( WiringRank(:,2) == CommonNeuron(Pivot,jj,1) ) ) == 0 )
    
                        % Determine the index in the WiringRank and WiringSublist
                        index_WiringRank = intersect( find ( WiringRank(:,1) == CommonNeuron(Pivot,1,1) ), find ( WiringRank(:,2) == CommonNeuron(Pivot,jj,1) ) );
                        index_WiringListSub_A = intersect( find ( WiringListSub(:,1) == CommonNeuron(Pivot,1,1) ), find ( WiringListSub(:,2) == CommonNeuron(Pivot,jj,1) ) );
    
                         if (  isempty( index_WiringListSub_A ) > 0 )
                         fprintf('Warning : index_WiringListSub is empty : (%d, %d) is not an assigned connexion ! \n', CommonNeuron(Pivot,1,1), CommonNeuron(Pivot,jj,1));
                         else
                        index_WiringListSub = index_WiringListSub_A;
                        end

                        if (  isempty( index_WiringRank ) > 0 )
                        fprintf('Warning : index_WiringRank (A) is empty \n');
                        end
                    end

    
                    if ( isempty( find ( WiringRank(:,2) == CommonNeuron(Pivot,1,1) ) ) == 0 && isempty( find ( WiringRank(:,1) == CommonNeuron(Pivot,jj,1) ) ) == 0 )
    
                        % Determine the index in the WiringRank and WiringSublist
                        index_WiringRank = intersect( find (  WiringRank(:,2) == CommonNeuron(Pivot,1,1) ), find ( WiringRank(:,1) == CommonNeuron(Pivot,jj,1) ) );
                        index_WiringListSub_B = intersect( find ( WiringListSub(:,2) == CommonNeuron(Pivot,1,1) ), find ( WiringListSub(:,1) == CommonNeuron(Pivot,jj,1) ) );
    
                            if (  isempty( index_WiringListSub_B ) > 0 )
                            fprintf('Warning : index_WiringListSub is empty : (%d, %d) is not an assigned connexion ! \n', CommonNeuron(Pivot,jj,1), CommonNeuron(Pivot,1,1));
                            else
                                index_WiringListSub = index_WiringListSub_B;
                            end

                            if (  isempty( index_WiringRank ) > 0 )
                            fprintf('Warning : index_WiringRank (B) is empty \n');
                            end
                    end

                    if ( length(index_WiringListSub) > 1)
                        fprintf("Warning : le_index_WiringListSub > 1 \n");
                    end

                    if ( length(index_WiringRank) > 1)
                        fprintf("Warning : le_index_WiringRank > 1 \n");
                    end


                        % fprintf('ooooooooooo')
                        % WiringRank(index_WiringRank,3)
                        % CommonWiring_sort(Pivot,jj,1) 
                        % fprintf('ooooooooooo')

                    if ( CommonWiring_sort(Pivot,jj,1) > 0)
                    fprintf('checking %d (%d,%d) & ', CommonWiring_sort(Pivot,jj,1), Pivot, jj);
                    else
                     fprintf('checking negative %d (%d,%d) & ', CommonWiring_sort(Pivot,jj,1), Pivot, jj);    
                    end

                    % Re-check the pair (Neuron_A, Neuron_B) -> deduce the
                    % #wiringRank ( as WiringRank(:,3) ) == 'CommonWiring_sort'

                    % Warning : set 'abs' for the negative connexion
                    if (   ( WiringRank(index_WiringRank,1) == CommonNeuron(Pivot,1,1) && WiringRank(index_WiringRank,2) == CommonNeuron(Pivot,jj,1) || ...
                             WiringRank(index_WiringRank,2) == CommonNeuron(Pivot,1,1) && WiringRank(index_WiringRank,1) == CommonNeuron(Pivot,jj,1) ) && ...
                           ( WiringListSub(index_WiringListSub,1) == CommonNeuron(Pivot,1,1) &&  WiringListSub(index_WiringListSub,2) == CommonNeuron(Pivot,jj,1) || ...
                             WiringListSub(index_WiringListSub,2) == CommonNeuron(Pivot,1,1) &&  WiringListSub(index_WiringListSub,1) == CommonNeuron(Pivot,jj,1) ) && ...
                             WiringRank(index_WiringRank,3) == abs(CommonWiring_sort(Pivot,jj,1))  )
    
                        % Verify if the Pivot corresponds to a connected neuron in 'ConnectedIDNeuron'
                        if ( isempty( find ( ConnectedIDNeuron(1,:,1) == CommonNeuron(Pivot,1,1) ) ) == 0 )
    
                            % Determine the index
                            index_NeuronID = find ( ConnectedIDNeuron(1,:) == CommonNeuron(Pivot,1,1) );
    
                            % Check if the priority assigned in to the 'ConnectedIDNeuron' corresponds to the Priority_sort.
                            if ( isempty ( find ( ConnectedIDNeuron(2,index_NeuronID) ==  Priority_sort(index_WiringListSub, :) ) ) == 0 )
    
                               IdPriority = find ( ConnectedIDNeuron(2,index_NeuronID) ==  Priority_sort(index_WiringListSub, :) );

                                % Last check ;)
                                if ( ConnectedIDNeuron(2,index_NeuronID) == Priority_sort(index_WiringListSub, IdPriority) )
                                fprintf("Checking priority for neuron #%d = %d  -> OK \n", ConnectedIDNeuron(1,index_NeuronID), ConnectedIDNeuron(2,index_NeuronID) );
                                else
                                fprintf("Problem with priority for neuron #%d \n ", ConnectedIDNeuron(1,index_NeuronID));
                                Error = Error + 1;
                                end
    
                            else
    
                                fprintf("\n Error in l.%d, c.%d :: the priority associated to #neuron is not correct! \n" , Pivot, jj );
                                Error = Error + 1;
    
                            end
    
                        else
    
                            fprintf("\n Error in l.%d, c.%d:: the #neuron %d is not associated to the connectedIDneuron! \n", Pivot, jj, CommonNeuron(Pivot,1)  );
                            Error = Error + 1;
    
                        end
    
    
                    else
    
                        fprintf("\n Error in l.%d, c.%d :: #wiring %d not found! \n", Pivot, jj, CommonWiring_sort(Pivot,jj) );
                        Error = Error + 1;
    
                    end
    
                else

                    if ( isempty( find ( WiringRank(:,1) == CommonNeuron(Pivot,1) ) ) == 0 & isempty( find ( WiringRank(:,2) == CommonNeuron(Pivot,jj) ) ) == 0 )
    
                        % Determine the index in the WiringRank and WiringSublist
                        index_WiringRank = intersect( find ( WiringRank(:,1) == CommonNeuron(Pivot,1) ), find ( WiringRank(:,2) == CommonNeuron(Pivot,jj) ) );
                        index_WiringListSub = intersect( find ( WiringListSub(:,1) == CommonNeuron(Pivot,1) ), find ( WiringListSub(:,2) == CommonNeuron(Pivot,jj) ) );
    
                    end
    
    
                    if ( isempty( find ( WiringRank(:,2) == CommonNeuron(Pivot,1) ) ) == 0 & isempty( find ( WiringRank(:,1) == CommonNeuron(Pivot,jj) ) ) == 0 )
    
                        % Determine the index in the WiringRank and WiringSublist
                        index_WiringRank = intersect( find (    WiringRank(:,2) == CommonNeuron(Pivot,1) ), find ( WiringRank(:,1) == CommonNeuron(Pivot,jj) ) );
                        index_WiringListSub = intersect( find ( WiringListSub(:,2) == CommonNeuron(Pivot,1) ), find ( WiringListSub(:,1) == CommonNeuron(Pivot,jj) ) );
    

                    end

                    if (  isempty( index_WiringListSub ) > 0 )
                    fprintf('\n Warning : index_WiringListSub is empty \n');
                    end

                    if (  isempty( index_WiringRank ) > 0 )
                    fprintf('\n Warning : index_WiringRank is empty \n');
                    end
    
                    fprintf("\n Error in l.%d, c.%d :: #neurons (%d  %d) not declared! \n", Pivot, jj, CommonNeuron(Pivot,1), CommonNeuron(Pivot,jj) );
                    Error = Error + 1;
    
                end
    
   
            end
    
        end
    
    end

        fb_A = 0; % check for forbidden connexions 
        fb_C = 0; 

        % Check if the connexions in the WiringListSub match with the
        % forbidden list (case A and B)
        for uu = 1:length( WiringListSub(:,1) )

                if ( ( isempty(find(WiringListSub(uu,1) == ForbConnexionNeuron_A ) ) == 0 && ...
                       isempty(find(WiringListSub(uu,2) == ForbConnexionNeuron_B ) ) == 0 ) || ...
                     ( isempty(find(WiringListSub(uu,2) == ForbConnexionNeuron_A ) ) == 0 && ...
                       isempty(find(WiringListSub(uu,1) == ForbConnexionNeuron_B ) ) == 0 ) )
                    fprintf('Error : Somme forbiden neurons are connected! \n')
                    Error = Error + 1;
                    fb_A = 1; 
                end

        end

        if ( fb_A == 0 )

            fprintf('Forbiden neurons connexions checked (list A and B) -> OK \n');

        end

        % Check if the connexions in the WiringListSub match with the
        % forbidden list (case C and D)

        for uu = 1:length( WiringListSub(:,1) )

                if ( ( isempty(find(WiringListSub(uu,1) == ForbConnexionNeuron_C ) ) == 0 && ...
                       isempty(find(WiringListSub(uu,2) == ForbConnexionNeuron_D ) ) == 0 ) || ...
                     ( isempty(find(WiringListSub(uu,2) == ForbConnexionNeuron_C ) ) == 0 && ...
                       isempty(find(WiringListSub(uu,1) == ForbConnexionNeuron_D ) ) == 0 ) )
                    fprintf('Error : Somme forbiden neurons are connected! \n')
                    Error = Error + 1;
                    fb_C = 1;
                end

        end

        if ( fb_C == 0 )

            fprintf('Forbiden neurons connexions checked (list C and D) -> OK \n');

        end

               
    if ( Error > 0)
    
        fprintf('Error in the checking - Abort !')
        pa
    
    end
    
    fprintf('Done. \n\n')
