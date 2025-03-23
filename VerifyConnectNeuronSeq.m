    
    newConnectedID_vec = [];

    for ii = 1:4
    
        % 3	  5	 9	4	8	10	7	2	6	1	0
    
        [RandomNeuronVector, newConnectedID, ConnectedIDNeuron, Rank_ConnectedIDNeuron, Neuron, SortConnectedIDNeuron, PriorityNewNeuron] = ...
            NeuralConnexionInference_v2(ConnectedIDNeuron,  ...
            Neuron, ...
            Rank_ConnectedIDNeuron, ...
            PriorityNewNeuron, ...
            maxNeurons, ...
            RandomNeuronVector);
    
        % Check if the group remains the same : keep the same
        % line in OutputClass or create a new line in OutputClass
        if ( RandomNeuronVector(3, Rank_ConnectedIDNeuron) == 1 )
            OutputClass_index = 1;
            OutputClass_index_ = OutputClass_index_ + 1;
        else
            OutputClass_index = OutputClass_index + 1;
        end
    
        OutputClass( OutputClass_index_, OutputClass_index ) = ConnectedIDNeuron(1, Rank_ConnectedIDNeuron);
    
        % Definition of the ouput of the control
    
    
        ListConnectedNeuron = [unique(sort(ConnectedIDNeuron(1,:) )), InputNeuronID];
    
        % ---- CREATION OF NODE MATRICES
    
        % ListConnectedNeuron contains InputNeurons - back to only connected
        % neurons
        %  OnlyConnectedNeurons_without_Input = ListConnectedNeuron(1: length(ListConnectedNeuron) - NbOfInputNeuron);
    
        OnlyConnectedNeurons_ForbConnexion = ListConnectedNeuron(1: length(ListConnectedNeuron) - NbOfInputNeuron);
    
        ConnectedNeuron_ForbConnexion = perms(OnlyConnectedNeurons_ForbConnexion);
    
        Rank_ConnectedIDNeuron


         %    NbNeuronLayer = 3;  
         %    ForbConnexionNeuron_A = 3;
         %    ForbConnexionNeuron_B = 5;

        NbNeuronLayer = 6; 

        if ( Rank_ConnectedIDNeuron >= NbNeuronLayer)

            LastConnectedNeurons_ForbConnexion = perms([unique(sort( [ConnectedIDNeuron(1,NbNeuronLayer:end), InputNeuronID] ) ) ] ) ;

            ForbConnexionNeuron_C = LastConnectedNeurons_ForbConnexion(:,1);
            ForbConnexionNeuron_D = LastConnectedNeurons_ForbConnexion(:,2);

        else

            ForbConnexionNeuron_A = ConnectedNeuron_ForbConnexion(:,1);
            ForbConnexionNeuron_B = ConnectedNeuron_ForbConnexion(:,2);


            ForbConnexionNeuron_C = 0;
            ForbConnexionNeuron_D = 0;

        end
    
    
        % IMPORTANT : 'WiringSortList' MUST BE used instead of
        % 'WiringListSub' since it avoid redundance of wires
    
        EnableCoupling = 0; % deprecated
        [WiringSortList, WiringListSub, CommonNeuron, CommonWiring_sort, NeuronWeigthList, WiringSubList_aux, newConnectedID_vec] = ...
            NodeMatrixManagement_v3_b(NeuronWeigthList, newConnectedID, newConnectedID_vec, EnableCoupling, InputNeuronID, ...
            ListConnectedNeuron, WiringRank, ForbConnexionNeuron_A, ForbConnexionNeuron_B, ...
            ForbConnexionNeuron_C, ForbConnexionNeuron_D);

            % Create the list of the wiring index between the listed connected neurons
            %  [WiringSortList]
    
            % Create the list of connections associated to the connected neurons
            % (except the 'EntryConnectedNeuron')
            %  [CommonNeuron]
    
            % Create the list of all wires associated to the connected neurons
            %  [CommonWiring_sort]

            le_WiringSortList = length( unique( WiringSortList(:,3) ) );
    
            list_Wires_sort = sort(unique(WiringSortList(:,3)));
    
            fprintf("---------")
    
            % =============================================================================
            % =============================================================================
            % FORCES le_WiringSortList for debug purpose -> check the
            % two first wires only (should be commented)
    
            % =============================================================================
            % For debug only -> check simply if a double wire between two neurons works
            if (  Iteration_k >= InstantNeuronGrowing )
                le_WiringSortList = 1; %2; %3;
            else
                le_WiringSortList = 1; %2;
            end
            % =============================================================================
    
            % Associated the priority rank to each neuron
            Priority_sort = ListControlPriority ( WiringSortList,  ConnectedIDNeuron );
    
            % ================================================
            % For debug / test only : testing some induced errors in the matrix
    
            % Priority_sort(2,1) = -5;
            % % Error in l.1, c.3 :: the priority associated to #neuron is not correct!
            %
            % ConnectedIDNeuron(1,2) = 8;
            % % Error in l.2, c.2:: the #neuron 5 is not associated to the connectedIDneuron!
            % % Error in l.2, c.3:: the #neuron 5 is not associated to the connectedIDneuron!
    
            % CommonWiring_sort(2,2) = 78;
            % Error in l.2, c.2 :: #wiring 78 not found!
    
            %CommonNeuron(2,1) = 8;
            %CommonNeuron(2,2) = 10;
            % Warning : index_WiringSortList is empty
            % Error in l.2, c.2 :: #neurons (8  10) not declared!
            % Warning : index_WiringSortList is empty
            % Error in l.2, c.3 :: #neurons (8  12) not declared!
            % ================================================
    
    
            %   NodeMatrixChecking(InputNeuronID, ListConnectedNeuron, WiringRank, 3, 5, 0, 0, ...
            %      WiringSortList, CommonNeuron, CommonWiring_sort, NeuronWeigthList, ConnectedIDNeuron, Priority_sort);
    
            NodeMatrixChecking_b(InputNeuronID, ListConnectedNeuron, WiringRank, ForbConnexionNeuron_A, ForbConnexionNeuron_B, ...
                ForbConnexionNeuron_C, ForbConnexionNeuron_D, ...
                WiringSortList, CommonNeuron, CommonWiring_sort, NeuronWeigthList, ConnectedIDNeuron, Priority_sort, OnlyConnectedNeurons_ForbConnexion);
    
    
            % Post-A / Update the CommonWiring_sort by excluding the negative
            % wires EXCEPT THE CURRENT WIRES

            for id_v = 1:length( newConnectedID_vec )
    
                for id_u = 1:length( CommonWiring_sort(:,1,1) )
    
                    for ppp = 2:length( CommonWiring_sort(1,:,1) )
   
                        if ( CommonNeuron(id_u,ppp,1) == newConnectedID_vec(id_v) )
                            
                            CommonWiring_sort(id_u,ppp,1) = -CommonWiring_sort(id_u,ppp,1);
                            CommonNeuron(id_u,ppp,1) = -CommonNeuron(id_u,ppp,1);
    
                        end
    
                    end
    
                end
    
            end

            % Post-B / Double check if every neurons are present in each line -
            % excluding the forbidden connexions

                line_cnt = zeros(1,length( CommonWiring_sort(:,1,1)) );   

                for id_u = 1:length( CommonWiring_sort(:,1,1) )

                    for ssd = 1:length( newConnectedID_vec )
    
                        check_id_u = 0;

                        for ppp = 1:length( CommonWiring_sort(1,:,1) )
   
                            if ( abs(CommonNeuron(id_u,ppp,1)) == newConnectedID_vec(ssd) )
                                
                                check_id_u = 1;
        
                            end
    
                        end

                        if ( check_id_u == 1)
                        
                            line_cnt( id_u ) = line_cnt( id_u ) + 1;

                        else

                            if ( isempty(find(newConnectedID_vec(ssd) == ForbConnexionNeuron_A ) ) == 0 || ...
                                 isempty(find(newConnectedID_vec(ssd) == ForbConnexionNeuron_B ) ) == 0 || ...
                                 isempty(find(newConnectedID_vec(ssd) == ForbConnexionNeuron_C ) ) == 0 || ...
                                 isempty(find(newConnectedID_vec(ssd) == ForbConnexionNeuron_D ) ) == 0 )


                                % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_A )
                                % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_B )
                                % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_C )
                                % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_D )

                                fprintf('Warning: a neuron is forbidden in line %d \n', id_u);

                                line_cnt( id_u ) = line_cnt( id_u ) + 1;

                            end

                        end
    
                    end
    
                end
                
                if ( mean( line_cnt ) == length( newConnectedID_vec ) )
                    fprintf('Check nodes distribution in the forward propagation -> OK \n');
                else
                    fprintf('Problem - please check ... Abort !');
                    pa
                end

            % Post-C / correcting the current node -> remove negative (-) sign
            if ( length( newConnectedID_vec ) >= 2)

                IndexLastConnectedID = find( CommonNeuron(:,:,1) == newConnectedID_vec(end) );

                CommonNeuron( IndexLastConnectedID ,:,1) = abs( CommonNeuron( IndexLastConnectedID ,:,1) );
                CommonWiring_sort( IndexLastConnectedID ,:,1) = abs( CommonWiring_sort( IndexLastConnectedID ,:,1) );

            end

            
                fprintf('------------------- \n');

        CommonNeuron
    
     %   WiringSortList
    
     %   CommonWiring_sort

     %   newConnectedID_vec

     pause

    end
    
    
    fprintf('* * * * * * End of debug * * * * * * * *\n')


    fprintf('Abort the program - please restart \n')

    pa