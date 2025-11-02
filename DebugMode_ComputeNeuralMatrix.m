    
    %
    close all

    WiringExcludeControl = [];
    NodeExcludeControl   = [];

fprintf("\n\n******************* DEBUG-MODE *******************")

Wiringlist_current = 1;

ii = 0;
    
    while (ii <= 9)
    
    
        Iteration_k = Iteration_k + 1;
    
        ii = ii + 1;
    
        time_vec(ii) = ii*TimeStep;
        
         EntryConnectedNeuron_weigth_1 = 1;
    	 EntryConnectedNeuron_weigth_2 = 1;
    
    
        if ( Iteration_k == 0 || Iteration_k == 1 || Iteration_k == 2 || Iteration_k == 4 || Iteration_k == 7 ) %||  Iteration_k == 2 ||  Iteration_k == 550  )  %
    

             if (  Iteration_k == 0 )

                newConnectedID = -1;
                
             end

             
            if ( Iteration_k == 1 || Iteration_k == 4 || Iteration_k == 7 )
                fprintf('\n\n Create new neuron at the instant %f - \n', time_vec(ii))
                

                % Obsolete 
                % [newConnectedID, ProbConnexion,    MaxProbConnexion, ConnectedIDNeuron, Rank_ConnectedIDNeuron, Neuron, SortConnectedIDNeuron, PriorityNewNeuron] = ...
                %      NeuralConnexionInference(ConnectedIDNeuron, Neuron, UpdateInputNeuron, UpdateHiddenNeuron, max_load, gamma_coeff, ...
                %      Rank_ConnectedIDNeuron, PriorityNewNeuron, RefGeneratorConfig, DebugMode_connectedMatrix, ...
                %      DebugMode_inference );
    
 
                [RandomNeuronVector, newConnectedID, ConnectedIDNeuron, Rank_ConnectedIDNeuron, Neuron, SortConnectedIDNeuron, PriorityNewNeuron] = ...
                    NeuralConnexionInference_v2(ConnectedIDNeuron,  ...
                    Neuron, ...
                    Rank_ConnectedIDNeuron, ...
                    PriorityNewNeuron, ...
                    maxNeurons, ...
                    RandomNeuronVector);

            end
    
               
    
                % Check if the group remains the same : keep the same
                % line in OutputClass or create a new line in OutputClass
                % if ( RandomNeuronVector(3, Rank_ConnectedIDNeuron) == 1 )
                %     OutputClass_index = 1;
                %     OutputClass_index_ = OutputClass_index_ + 1;
                % else
                %     OutputClass_index = OutputClass_index + 1;
                % end
                % 
                % OutputClass( OutputClass_index_, OutputClass_index ) = ConnectedIDNeuron(1, Rank_ConnectedIDNeuron);
    
                % Definition of the ouput of the control
    
%                NeuronWeigthList(2, newConnectedID ) = 1.11;
    
            
    
            % Defines the control target for the EntryConnectedNeuron = 1
            % The goal is simply to start the control to "correct" values
            % before beeing updated through the wires
            if ( Iteration_k == 0 )
    
                NeuronWeigthList(2, EntryConnectedNeuron(1) ) = EntryConnectedNeuron_weigth_1;
                NeuronWeigthList(2, EntryConnectedNeuron(2) ) = EntryConnectedNeuron_weigth_2;
    
            end
    
            ListConnectedNeuron = [unique(sort(ConnectedIDNeuron(1,:) )), InputNeuronID];           
    
            % ---- CREATION OF NODE MATRIX
    
            % Create the list of the wiring index between the listed connected neurons
            %  [WiringSortList]
    
            % Create the list of connections associated to the connected neurons
            % (except the 'EntryConnectedNeuron')
            %  [CommonNeuron]
    
            % Create the list of all wires associated to the connected neurons
            %  [CommonWiring_sort]

               % old version without the wiring-exclusion management
            %  [WiringSortList, WiringListSub, CommonNeuron, CommonWiring_sort, NeuronWeigthList] = ...
            %     NodeMatrixManagement(NeuronWeigthList, InputNeuronID, ListConnectedNeuron, WiringRank, 3, 5, 0, 0);
    
            EnableCoupling = 1;
           
              % [WiringExcludeControl, WiringSortList, WiringListSub, CommonNeuron, CommonWiring_sort, NeuronWeigthList] = ...
              %    NodeMatrixManagement_v2(WiringExcludeControl, NeuronWeigthList, newConnectedID, EnableCoupling, InputNeuronID, ListConnectedNeuron, WiringRank, 3, 5, 0, 0);

                [NodeExcludeControl, WiringExcludeControl, WiringSortList, WiringListSub, CommonNeuron, CommonWiring_sort, NeuronWeigthList] = ...
                 NodeMatrixManagement_v2_b(NodeExcludeControl, WiringExcludeControl, NeuronWeigthList, newConnectedID, EnableCoupling, InputNeuronID, ListConnectedNeuron, WiringRank, 3, 5, 0, 0);

            le_WiringSortList = length( unique( WiringSortList(:,3) ) );
    
            list_Wires_sort = sort(unique(WiringSortList(:,3)));
            
            % Associated the priority rank to each neuron
            Priority_sort = ListControlPriority ( WiringSortList,  ConnectedIDNeuron );
    
            fprintf("---------")
    
            %  if ( DebugMode_connectedMatrix == 1)
            fprintf('*** ConnectedID matrix : \n');
            fprintf('TargetNeuron ID = %d \n', ConnectedIDNeuron(1,end) )


            fprintf('*** List of connected neurons : \n');
            CommonNeuron

            fprintf('*** WiringListSub : \n');
            WiringListSub

            fprintf('*** Priority_sort : \n');
            Priority_sort

            fprintf('*** Neuron-WiringList : \n');
            CommonWiring_sort

            fprintf('*** Wires sort : \n');
            list_Wires_sort

            %fprintf('*** NeuronWeigth List : \n');
            %NeuronWeigthList

            fprintf('*** WiringSortList : \n');
            WiringSortList

            fprintf('*** Node/WiringExcludeControl : \n');
            WiringExcludeControl
            NodeExcludeControl


            % Assign simply the #wire index to the wiring weigth
            for rr = 1:length( list_Wires_sort )

                WiringWeigthList( list_Wires_sort(rr) ) = list_Wires_sort(rr);

            end

          %  pause

        end


            
            % 1/ Pick up the wire# in the WiringListSub (indexed by
            % 'Wiringlist_current')
            ActivatedWire = WiringListSub(Wiringlist_current,3);
    
            time_ = ii*TimeStep;
   

            % 2/ Pick up the (both) active neurons in the WiringListSub
            ActiveNeurons = WiringListSub(Wiringlist_current, 1:2);
    
            % 3/ Which neuron to update -> Chech the priority : deduce the
            % UpdatingNeuronIndex
            if (Priority_sort(Wiringlist_current,1) > Priority_sort(Wiringlist_current,2))
    
                UpdatingNeuronIndex = WiringListSub(Wiringlist_current, 1);
    
            else
    
                UpdatingNeuronIndex = WiringListSub(Wiringlist_current, 2);
    
            end


            % fprintf('Neuron #%d associated to %d weigths : \n', UpdatingNeuronIndex, NeuronWeigthList(3, UpdatingNeuronIndex) );
            % 
            %         IndexActiveNeuron_Common = find ( UpdatingNeuronIndex == CommonWiring_sort(:,1,1) );
            % 
            %         for uu = 2:length( CommonWiring_sort(IndexActiveNeuron_Common,:,1) )
            %             if ( CommonWiring_sort(IndexActiveNeuron_Common,uu,1) > 0 )
            % 
            %             fprintf('[%d] -> [%d] \n', CommonWiring_sort(IndexActiveNeuron_Common,uu,1), NeuronWeigthList(3+ CommonWiring_sort(IndexActiveNeuron_Common,uu,1), CommonWiring_sort(IndexActiveNeuron_Common,1,1)) );
            %             end
            %         end
            %         fprintf('--------------');


              %  fprintf('iteration #%d (nb wires = %d) -> index wire %d [wiring #%d] : %d -> %d \n\n', Iteration_k, le_WiringListSub, Wiringlist_current, ActivatedWire, WiringListSub(Wiringlist_current,1), WiringListSub(Wiringlist_current,2) );
        
    
            % 4a/ Update the NeuronWeigthList
    
            % Output side :
            % + NeuronWeigthList(1,UpdatingNeuronIndex) contains
            % the measure from the control side
            % + NeuronWeigthList(2,UpdatingNeuronIndex) contains
            % the REFERENCE of the tracking
            % -> CONCENRS ONLY THE REFERENCE
    
    
            NeuronWeigthList(2,UpdatingNeuronIndex) = OutputNeuron_Q(1);
    
            % Input side
            % Warning : InputNeuronID(1) should give the index of the first
            % input neuron ... InputNeuronID(2) is the index of the sec. input
            % neuron
            % It is assigned also to the measure since that fixed values
    
            NeuronWeigthList(1,InputNeuronID(1) ) = InputNeuron_Q(1);
            NeuronWeigthList(1,InputNeuronID(2) ) = InputNeuron_Q(2);
    
            % 4b/ Update the WiringWeigthList
            %   WiringWeigthList(ActivatedWire) = W_update(ActivatedWire);
    
            % Wupdate_test_vector;
            % for ee = 1:length (  W_update )
            % 
            %     WiringWeigthList(ee) = W_update(ee);
            % end
    
    
            % 5a/ Update the CommonNeuron -> for each neuron available from the
            % CommonNeuron, get the (row_update_neuron, col_update_neuron)
            % index and update the CommonNeuron(:,:, 2) with the corresponding
            % Neuron weigths

            for yy = 1:length( NeuronWeigthList(1,:) )
                [row_update_neuron, col_update_neuron] = find( CommonNeuron(:,:,1) == yy);
                     
                if ( isempty( row_update_neuron ) == 0 & isempty( col_update_neuron ) == 0 )
    
                    for uy = 1:length( row_update_neuron )
                        CommonNeuron( row_update_neuron(uy), col_update_neuron(uy), 2) = NeuronWeigthList(1,yy);
                    end
    
                end
    
            end
          
 
            % 6 / Update the CommonWiring_sort -> for each wire available from the
            % CommonWiring_sort, get the (row_update_wire, col_update_wire)
            % index and update the CommonWiring_sort(:,:,2) with the
            % corresponding wiring weights

            % WARNING: NEEDS TO PUT AN ABS in the find( ) since it looks
            % directly in the 'CommonWiring_sort' to look at (positive)
            % wires !!
            % the modification expected to disabled newID in previous lines
            % of 'CommonWiring_sort' must be done in another way
    
            for yy = 1:length( WiringWeigthList )
                [row_update_wire, col_update_wire] = find( abs( CommonWiring_sort(:,:,1) ) == yy );
        
                if ( isempty( row_update_wire ) == 0 & isempty( col_update_wire ) == 0 )
    
                    for uy = 1:length( row_update_wire )
                        CommonWiring_sort( row_update_wire(uy), col_update_wire(uy), 2 ) = WiringWeigthList(yy);
                    end
    
                end
    
            end


            % 6b / Update the CommonWiring_sort by excluding the negative
            % wires EXCEPT THE CURRENT WIRES

           for id_u = 1:length( CommonWiring_sort(:,1,1) )

               for ppp = 1:length( CommonWiring_sort(1,:,1) )

                   for ssd = 1:length( NodeExcludeControl )

                        if ( CommonNeuron(id_u,1,1) ~= NodeExcludeControl(ssd) & CommonNeuron(id_u,ppp,1) == NodeExcludeControl(ssd) )

                            CommonWiring_sort(id_u,ppp,1) = -CommonWiring_sort(id_u,ppp,1);
                            CommonNeuron(id_u,ppp,1) = -CommonNeuron(id_u,ppp,1);

                        end

                    end

               end

           end
            % correcting the current node  
           if ( length( NodeExcludeControl ) > 2)

            IndexLastConnectedID = find( CommonNeuron(:,:,1) == NodeExcludeControl(end) );

           CommonNeuron( IndexLastConnectedID ,:,1) = abs( CommonNeuron( IndexLastConnectedID ,:,1) );
           CommonWiring_sort( IndexLastConnectedID ,:,1) = abs( CommonWiring_sort( IndexLastConnectedID ,:,1) );

           end

           % 6c / Finaly removing the negative wires 
            CommonWiring_sort_backup = CommonWiring_sort;

           for id_u = 1:length( CommonWiring_sort(:,1,1) )

               for ppp = 1:length( CommonWiring_sort(1,:,1) )


                   if ( CommonWiring_sort(id_u,ppp,1) < 0)
                    %   CommonWiring_sort_positive(id_u,ppp,2) = 0;
                       CommonWiring_sort(id_u,ppp,2) = 0;
                   else
                   %    CommonWiring_sort_positive(id_u,ppp,2) = CommonWiring_sort(id_u,ppp,2);
                       CommonWiring_sort(id_u,ppp,2) = CommonWiring_sort(id_u,ppp,2);
                   end

               end

            end


            % 7 / Compute the product between weigth and neurons
            % GRANULARITY EXTENSION: Compute outputs for all input combinations

            % Call granular computation function
            GranularOutputs = ComputeGranularNodeOutputs(CommonNeuron, CommonWiring_sort);

            % Maintain backward compatibility: extract single output for each node
            for row = 1:length( CommonNeuron(:,1,1) )
                % Get the traditional single output (all inputs combined)
                Prod(row) = GranularOutputs{row}.SingleOutput;
                CommonNeuron(row, 1, 2 ) = Prod(row); % set new measures to the CommonNeuron(:,2)
            end

            % OPTIONAL: Display granular outputs for debugging
            % Uncomment the following section to see all combination outputs
             fprintf('\n=== GRANULAR OUTPUTS ===\n');
             for row = 1:length(GranularOutputs)
                 fprintf('Node %d: %d inputs -> %d output combinations\n', ...
                     GranularOutputs{row}.NodeID, ...
                     GranularOutputs{row}.NumInputs, ...
                     size(GranularOutputs{row}.OutputMatrix, 1));
                 disp('Output Matrix [Value | Mask]:');
                 disp(GranularOutputs{row}.OutputMatrix);
             end

            % 8 / Update the NeuronWeigthList with the computed product

            for row = 1:length( CommonNeuron(:,1) )

                    % For a particular neuron 'x':

                    % index (1,x) refers to the 'measured / controlled' value
                    % index (2,x) refers to the targeted value
                    % index (3,x) refers to the nb of connexions associated to 'x'
                    % index (>3,x) list all sub-targeted weigths (that amis to help
                    % converging the control)

                % set new measures from the control to the index NeuronWeigthList(1,:)
                % the references NeuronWeigthList(2,:) are not modified at this point!!
                NeuronWeigthList(1, CommonNeuron(row, 1 ) ) = Prod(row);
                WiringWeigthList( CommonNeuron(row, 1 ) ) = Prod(row);

            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           CommonNeuron

           CommonWiring_sort

       %    fprintf('CommonWiring_sort_positive \n')

       %        CommonWiring_sort_positive(:,:,2)

       %    NeuronWeigthList(1:2,:)

         %  WiringWeigthList(1:40)

            Prod

      %      pause
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % END /
    
    
       %     CommonNeuron
    
       %     CommonWiring
    
       %     CommonWiring_sort
    
       %      NeuronWeigthList
    
       %     WiringWeigthList(1:40)
    
    
             fprintf("ITERATION : %d \n", Iteration_k);
                    
            pause
    
    end


%% ================ DOUBLE CHECK 

Q3 = InputNeuron_Q(1) * WiringWeigthList(32) + InputNeuron_Q(2) * WiringWeigthList(33);  % 293
Q5 = InputNeuron_Q(1) * WiringWeigthList(54) + InputNeuron_Q(2) * WiringWeigthList(55);  % 491
            
            % Normal running
            Q9 = 0;

            Q3_ = Q9 * WiringWeigthList(30) + InputNeuron_Q(1) * WiringWeigthList(32) + InputNeuron_Q(2) * WiringWeigthList(33); % 293
            
            Q5_ = Q9 * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(54) + InputNeuron_Q(2) * WiringWeigthList(55); % 491

            Q9_ = Q3 * WiringWeigthList(30) + Q5 * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(98) + InputNeuron_Q(2) * WiringWeigthList(99); % 35209


            Q3_ = Q9_ * WiringWeigthList(30) + InputNeuron_Q(1) * WiringWeigthList(32) + InputNeuron_Q(2) * WiringWeigthList(33); % 1056563
            
            Q5_ = Q9_ * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(54) + InputNeuron_Q(2) * WiringWeigthList(55); % 1831359

            Q9_ = Q3 * WiringWeigthList(30) + Q5 * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(98) + InputNeuron_Q(2) * WiringWeigthList(99); % 35209

            % Cancel back-flowing

            Q3_ = Q9 * 0 * WiringWeigthList(30) + InputNeuron_Q(1) * WiringWeigthList(32) + InputNeuron_Q(2) * WiringWeigthList(33); % 293
            
            Q5_ = Q9 * 0 * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(54) + InputNeuron_Q(2) * WiringWeigthList(55); % 491

            Q9_ = Q3 * WiringWeigthList(30) + Q5 * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(98) + InputNeuron_Q(2) * WiringWeigthList(99); % 35209

            %
            Q3_ = Q9_ * 0 * WiringWeigthList(30) + InputNeuron_Q(1) * WiringWeigthList(32) + InputNeuron_Q(2) * WiringWeigthList(33); % 293
            
            Q5_ = Q9_ * 0 * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(54) + InputNeuron_Q(2) * WiringWeigthList(55); % 491

            Q9_ = Q3 * WiringWeigthList(30) + Q5 * WiringWeigthList(52) + InputNeuron_Q(1) * WiringWeigthList(98) + InputNeuron_Q(2) * WiringWeigthList(99); % 35209



%% ================ DOUBLE CHECK - obsolete / built from the previous version of the inference algorithm ================

    
            % % Initialization from input neurons Q11 and Q12
            % 
            % %      3 =   11    12 : Q11 * [32] + Q12 * [33]
            % %      5 =   11    12 : Q11 * [54] + Q12 * [55]
            % 
            % Q3 = InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(2) * W_update(33);  % 121
            % Q5 = InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(2) * W_update(55);  % 148
            % 
            % % ==== ITERATION 0 : Prod = 121   148
            % 
            % % A / INTRODUCTION OF THE Q1 NEURON
            % % ---------------------------------
            % 
            % % 3  =   1    11    12     0
            % % 1  =   3     5    11    12
            % % 5  =   1    11    12     0
            % 
            % 
            % Q1 = 0;  % init    
            % 
            % Q3_ = Q1 * W_update(2) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(2) * W_update(33); % 121
            % 
            % Q5_ = Q1 * W_update(4) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(2) * W_update(55); % 148
            % 
            % Q1_ = Q3 * W_update(2) + Q5 * W_update(4) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 735
            % 
            % % ==== ITERATION 1 : Prod = 121   735   148
            % 
            % Q1_a = Q3_ * W_update(2) + Q5_ * W_update(4) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 735
            % 
            % Q3_a = Q1_ * W_update(2) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(2) * W_update(33); % 1591
            % 
            % Q5_a = Q1_ * W_update(4) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(2) * W_update(55); % 2353
            % 
            % % ==== ITERATION 2 : Prod = 1591   735   2353
            % 
            %  Q1_b = Q3_a * W_update(2) + Q5_a * W_update(4) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 10290
            % 
            % Q3_b = Q1_a * W_update(2) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(2) * W_update(33); % 1591
            % 
            % Q5_b = Q1_a * W_update(4) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(2) * W_update(55); % 2353
            % 
            % 
            % % ==== ITERATION 3 : Prod = 1591   10290   2353
            % 
            % % B / INTRODUCTION OF THE Q7 NEURON
            % % ---------------------------------
            % 
            % %   1  =   3     5     7    11    12
            % %   3  =   1     7    11    12     0
            % %   5  =   1     7    11    12     0
            % %   7  =   1     3     5    11    12
            % 
            % 
            % Q7_b = 0;  % init
            % 
            % Q1_c = Q3_b * W_update(2) + Q5_b * W_update(4) + Q7_b * W_update(6) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 10290
            % 
            % Q3_c = Q1_b * W_update(2) + Q7_b * W_update(28) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(2) * W_update(33); % 20701
            % 
            % Q5_c = Q1_b * W_update(4) + Q7_b * W_update(50) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(2) * W_update(55); % 31018
            % 
            % Q7_c = Q1_b * W_update(6) + Q3_b * W_update(28) + Q5_b * W_update(50) +  InputNeuron_Q(1) * W_update(76) +  InputNeuron_Q(2) * W_update(77); % 95713
            % 
            % % ==== ITERATION 4 : Prod = 10290       20701       31018       95713
            % 
            % Q1_d = Q3_c * W_update(2) + Q5_c * W_update(4) + Q7_c * W_update(6) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 517357
            % 
            % Q3_d = Q1_c * W_update(2) + Q7_c * W_update(28) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(2) * W_update(33); % 1169257
            % 
            % Q5_d = Q1_c * W_update(4) + Q7_c * W_update(50) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(2) * W_update(55); % 1466713
            % 
            % Q7_d = Q1_c * W_update(6) + Q3_c * W_update(28) + Q5_c * W_update(50) +  InputNeuron_Q(1) * W_update(76) +  InputNeuron_Q(2) * W_update(77); % 755008
            % 
            % % ==== ITERATION 5 : Prod =  517357     1169257     1466713      755008
            % 
            % Q1_e = Q3_d * W_update(2) + Q5_d * W_update(4) + Q7_d * W_update(6) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 9758734
            % 
            % Q3_e = Q1_d * W_update(2) + Q7_d * W_update(28) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(2) * W_update(33); % 10094931
            % 
            % Q5_e = Q1_d * W_update(4) + Q7_d * W_update(50) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(2) * W_update(55); % 12877339
            % 
            % Q7_e = Q1_d * W_update(6) + Q3_d * W_update(28) + Q5_d * W_update(50) +  InputNeuron_Q(1) * W_update(76) +  InputNeuron_Q(2) * W_update(77); % 38101373
            % 
            % % ==== ITERATION 6 : Prod = 9758734    10094931    12877339    38101373     
            % 
            % % C / INTRODUCTION OF THE Q2 NEURON
            % % ---------------------------------
            % 
            % 
            %  % 1  =   2     3     5     7    11    12
            %  % 2  =   1     3     5     7    11    12
            %  % 3  =   1     2     7    11    12     0
            %  % 5  =   1     2     7    11    12     0
            %  % 7  =   1     2     3     5    11    12
            % 
            %  Q2_e = 0;  % init
            % 
            %  Q1_f = Q2_e * W_update(1) + Q3_e * W_update(2) + Q5_e * W_update(4) + Q7_e * W_update(6) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 211227420  
            % 
            %  Q2_f = Q1_e * W_update(1) + Q3_e * W_update(13) + Q5_e * W_update(15) + Q7_e *  W_update(17) + InputNeuron_Q(1) *  W_update(21) + InputNeuron_Q(2) *  W_update(22); % 526354414          
            % 
            %  Q3_f = Q1_e * W_update(2) + Q2_e * W_update(13) + Q7_e * W_update(28) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(1) * W_update(33); % 476734079
            % 
            %  Q5_f = Q1_e * W_update(4) + Q2_e * W_update(15) + Q7_e * W_update(50) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(1) * W_update(55); % 600796962
            % 
            %  Q7_f = Q1_e * W_update(6) + Q2_e * W_update(17) + Q3_e * W_update(28) + Q5_e * W_update(50) + InputNeuron_Q(1) * W_update(76) + InputNeuron_Q(1) * W_update(77); % 353334378
            % 
            % 
            %  % ==== ITERATION 7 : Prod =   211227420   526354414   476734065   600796945   353334359
            % 
            %  Q1_g = Q2_f * W_update(1) + Q3_f * W_update(2) + Q5_f * W_update(4) + Q7_f * W_update(6) + InputNeuron_Q(1) * W_update(10) + InputNeuron_Q(2) * W_update(11); % 4.6956e+09
            % 
            %  Q2_g = Q1_f * W_update(1) + Q3_f * W_update(13) + Q5_f * W_update(15) + Q7_f *  W_update(17) + InputNeuron_Q(1) *  W_update(21) + InputNeuron_Q(2) *  W_update(22); % 1.1535e+10          
            % 
            %  Q3_g = Q1_f * W_update(2) + Q2_f * W_update(13) + Q7_f * W_update(28) + InputNeuron_Q(1) * W_update(32) + InputNeuron_Q(1) * W_update(33); % 8.3469e+09
            % 
            %  Q5_g = Q1_f * W_update(4) + Q2_f * W_update(15) + Q7_f * W_update(50) + InputNeuron_Q(1) * W_update(54) + InputNeuron_Q(1) * W_update(55); % 1.0145e+10
            % 
            %  Q7_g = Q1_f * W_update(6) + Q2_f * W_update(17) + Q3_f * W_update(28) + Q5_f * W_update(50) + InputNeuron_Q(1) * W_update(76) + InputNeuron_Q(1) * W_update(77); % 2.0315e+10
            % 
            %  % ==== ITERATION 8 : Prod = 1.0e+10 * [0.4696    1.1535   0.8347    1.0145    2.0315]
            % 
            % 
            %  fprintf("----------------------- \n");
            %  fprintf("----------------------- \n");
            % 
            %     abs( Prod(1) - Q1_g ) 
            %     abs( Prod(2) - Q2_g )  
            %     abs( Prod(3) - Q3_g )  
            %     abs( Prod(4) - Q5_g ) 
            %     abs( Prod(5) - Q7_g )
            % 
            %  fprintf("----------------------- \n");
            %  fprintf("----------------------- \n");

             fprintf("End of the debug !")
                
             fprintf('End of the program !')

             pa