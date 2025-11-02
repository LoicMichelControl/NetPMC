    
    
function [newConnectedID, ProbConnexion_ID, MaxProbConnexion, ConnectedIDNeuron, Rank_ConnectedIDNeuron, Neuron, SortConnectedIDNeuron, CountNewNeuron] = ...         
    NeuralConnexionInference(ConnectedIDNeuron,  ...
    Neuron, ...
    UpdateInputNeuron, ...
    UpdateHiddenNeuron, ...
    max_load, ...
    gamma_coeff, ...
    Rank_ConnectedIDNeuron, ...
    CountNewNeuron, ...
    RefGeneratorConfig, ...
    DebugMode_connectedMatrix, ...
    DebugMode_inference)
    
    % The goal is to connect a new neuron 'Target neuron' to (at least) two
    % neurons: the first task is to search for a candidate neuron that will be connected to the 'Parent' neuron and satisfy
    % the min Prob_connexion constraints defined as:
    
    % - Prob_connexion.dist : standard euclidian distance : sqrt( (Neuron(Parent_ID).x - Neuron(Target_ID).x).^2 + (Neuron(Parent_ID).y - Neuron(Target_ID).y).^2 + 1e-6)
    
    % - Prob_connexion.load : The probability is decreased w.r.t. the internal load (existing prior connexions) of the neurons that are suceptible to be connected ->
    % the most loaded are the neurons, the less favorable is the connexion.
    
    % - Prob_connexion.weigth : measures the difference of weigths between the neurons => the closest weight is, the
    % most favorable connexion is -> favorize the connexion between close weigths
    
    % Each connexion is 'scanned' through these constraints and the connexion that
    % has the highest Probability of connexion 'prob_connexion' is selected to create the new connexion.
    
    % Once the first connexion is made, the next step is to determine the
    % second connexion (and possibly a third connexion) with neuron(s) that is/are already connected, following the
    % same Prob_connexion-constraints-based strategy.
    
    ExcludedNeurons = []; % May not be used ? see in future versions -> !!!not set as output variable of the function!!!!
    
    % List all the connected neurons excluding the input neurons :
    % Warning : sub-size of the ConnectedIDNeuron matrix : [:, 2]

    SortConnectedIDNeuron = unique ( ConnectedIDNeuron(:,1:2)  );
    
    % since the input neurons are listed at the very end IDs, easier to remove
    % by substracting 'UpdateInputNeuron'
    SortConnectedIDNeuron = SortConnectedIDNeuron(1:end-UpdateInputNeuron);
    
    % To update the display of the connexion matrix (debug only)
    ProbConnexion_counter = 1;

    if ( DebugMode_inference == 1)

            fprintf('================ INFERENCE CODE TRACE ==================== \n');
            fprintf('========================================================== \n');

    end

    % Assign the constraints
    gamma_lo = gamma_coeff.gamma_lo;
    gamma_di = gamma_coeff.gamma_di;
    gamma_we = gamma_coeff.gamma_we;

    % Increase the Rank of the ConnectedIDNeuron matrix
    Rank_ConnectedIDNeuron = Rank_ConnectedIDNeuron + 1;

    % Target wiegthy obtained from the Ref. Generator
    Target_weigth = ReferenceGenerator( Rank_ConnectedIDNeuron, RefGeneratorConfig.type_generator, RefGeneratorConfig.GenIncrement );
   
    % Sweep all connected neurons
    for ( ParIndex = 1:length( SortConnectedIDNeuron ) )
    
        Parent_ID = SortConnectedIDNeuron(ParIndex);
    
        if ( DebugMode_inference == 1)

            fprintf('Parent_ID : %d - Current weight : %f -- Targeted weigth : %f \n', Parent_ID, Neuron(Parent_ID).weigth, -999)
        end
    
        % Sweep all available neurons to envisage a possible connexion
        for (Target_ID = 1:UpdateHiddenNeuron )
    
            % A Targeted neuron can not be the Parent neuron and
            % Look at the possiblity of re-connecting an existing neuron
            % Target_ID ~max( Target_ID == SortConnectedIDNeuron )
            if ( Target_ID ~= Parent_ID && ( ~max( Target_ID == SortConnectedIDNeuron ) ) )
    
                % Compute the 'We' (weight) criteria, the 'Lo' (load) criteria
                % and the 'Di' (distance) criteria as a field of the 'ProbConnexion'
                % matrix that sweeps the connexion(s) between each Parent neuron
                % and Target neuron. A weighted sum of the criteria allows
                % calculating a global probability for each connexion.
    
                % Architecture of the ProbConnexion matrix: each i-j element
                % designates the probability field (of criteria) of connexion between the
                % i=Target_ID and the j=Parent_ID.
    
                %             ProbConnexion_ID(Target_ID, Parent_ID).We
                %             ProbConnexion_ID(Target_ID, Parent_ID).Lo
                %             ProbConnexion_ID(Target_ID, Parent_ID).Di
    
                % Note that the global probability must be defined in a
                % separate matrix regarding future calls in other functions.
    
                % The 'We' criteria examines the relative difference between the Target
                % weight and the Parent_weigth
                % -> the probability of connexion is increased if the weights are close
                ProbConnexion_ID(Target_ID, Parent_ID).We = abs(Neuron(Parent_ID).weigth - Target_weigth);

                % !!!!!!!!!! TBD if the most pertinent is the Target_weigth
                % or the current_weigth (but it should be zero at the
                % beginning ? or not ?)
    
                % The 'Lo' criteria examines the loads of the neurons
                % -> the probability of connexion is increased if the neurons are few loaded and far from the max. of load
                % (may be useless... to be determined by the experience ;) )
                ProbConnexion_ID(Target_ID, Parent_ID).Lo = ( Neuron(Parent_ID).load - max_load ) + ( Neuron(Target_ID).load - max_load );
    
                % The 'Di' criteria examines the distance between the neurons
                % the probability is increased is the neurons are very close
                ProbConnexion_ID(Target_ID, Parent_ID).Di = sqrt( (Neuron(Parent_ID).x - Neuron(Target_ID).x).^2 + (Neuron(Parent_ID).y - Neuron(Target_ID).y).^2 + 1e-6);
    
    
            else
                % In case of Target_ID == Parent_ID or re-connexion between already
                % connected neurons -> destroy the probability of connexion
    
                ProbConnexion_ID(Target_ID, Parent_ID).We = 99 ;
    
                ProbConnexion_ID(Target_ID, Parent_ID).Lo = 99 ;
    
                ProbConnexion_ID(Target_ID, Parent_ID).Di = 99 ;
    
                % May not be used ? see in future versions
                ExcludedNeurons = [ExcludedNeurons, Target_ID];
    
            end
    
            % The global probability of connexion is calculated through a weigthed sum of each criteria.
            ProbConnexion_IDSum(Target_ID, Parent_ID) = gamma_we * ProbConnexion_ID(Target_ID, Parent_ID).We + gamma_lo * ProbConnexion_ID(Target_ID, Parent_ID).Lo + gamma_di * ProbConnexion_ID(Target_ID, Parent_ID).Di;
    
              
                ProbConnexion_ID_display(ProbConnexion_counter,1) = Target_ID;
                ProbConnexion_ID_display(ProbConnexion_counter,2) = Parent_ID;
                ProbConnexion_ID_display(ProbConnexion_counter,7) = Neuron(Parent_ID).weigth;
                ProbConnexion_ID_display(ProbConnexion_counter,3) = ProbConnexion_ID(Target_ID, Parent_ID).We;
                ProbConnexion_ID_display(ProbConnexion_counter,4) = ProbConnexion_ID(Target_ID, Parent_ID).Lo;
                ProbConnexion_ID_display(ProbConnexion_counter,5) = ProbConnexion_ID(Target_ID, Parent_ID).Di;
                ProbConnexion_ID_display(ProbConnexion_counter,6) = ProbConnexion_IDSum(Target_ID, Parent_ID);
    
    
                ProbConnexion_counter = ProbConnexion_counter + 1;
        end
    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % A/ Validate the Target Neuron
    
    % Sort in ascending order, the three most probable connexions of neurons
    % among each (permitted) combination 'Target_ID' - 'Parent_ID'.
    
    [MaxProbConnexion.T, MaxProbConnexion.P, ProbConnexion_IDSum_min] = SortMinimumElementMatrice( ProbConnexion_IDSum, 3 );
    
    %%%% Update the connectivity matrix
       
    % Instantiation of the new neuron that has been 'selected' for the
    % connexion: the first element of the 'T' and 'P' MaxProbConnexion vectors

    % these two following lines are obsolete -> needs the Ref. Generator to be
    % included -> everything in the same line ;) 
    % ConnectedIDNeuron(Rank_ConnectedIDNeuron, 1) = MaxProbConnexion.P(1);
    % ConnectedIDNeuron(Rank_ConnectedIDNeuron, 2) = MaxProbConnexion.T(1);
      
    ConnectedIDNeuron(Rank_ConnectedIDNeuron,:) = [MaxProbConnexion.P(1), MaxProbConnexion.T(1), CountNewNeuron, Rank_ConnectedIDNeuron];

    % Validation: Check the specific line of the ProbConnexion_ID_display matrix that
    % is associated to MaxProbConnexion.P(1) and MaxProbConnexion.T(1) and A_min(1)
    % -> the 'Target_find' gives the index of the selected Target Neuron (as
    % the index in ProbConnexion_ID_display(:,1))
    % if it is empty, then display a problem and stop.
    
    Target_find = find( ProbConnexion_ID_display(:,1) == MaxProbConnexion.T(1) & ProbConnexion_ID_display(:,2) == MaxProbConnexion.P(1) & ProbConnexion_ID_display(:,6) == ProbConnexion_IDSum_min(1));
    
    if ( isempty(Target_find) == 1)
    
        display("caught exception - stopping");
    
        pause
    
    else
        % The value of MaxProbConnexion.T(1) is the ID of the Targeted
        % Parent neuron
        fprintf('Found Target neuron : ID #%d \n', MaxProbConnexion.T(1));
    end
    
    
    % Assign the targeted weigth to the Target neuron
    Neuron(MaxProbConnexion.T(1)).weigth_target = Target_weigth;
    
    % B/ Validate the Sec. Parent Neuron
    
    % Knowing the target neuron for the first connexion, we look at another
    % already connected neuron 'Sec. Parent' neuron to connect with.
    
    [ ~, MaxProbConnexionSec.P, ~ ] = SortMinimumElementMatrice( ProbConnexion_IDSum( MaxProbConnexion.T(1),:), 3 );
    
    % check whether the selected Sec. Parent is not the same neuron at the 'Parent' neuron
    % => the most probable neuron is designated in
    % MaxProbConnexionSec_selected(1) since MaxProbConnexionSec.P is
    % order by decreasing probabilities.
    
    id = 1;
    for zz = 1:length(MaxProbConnexionSec.P)
    
        if ( MaxProbConnexionSec.P(zz) ~= MaxProbConnexion.P(1) ) % ((MinProb_SecConnection(zz) > 0 ?? )
            MaxProbConnexionSec_selected(id) = MaxProbConnexionSec.P(zz);
            id = id + 1;
        end
    
    end
    
    % Validation: Check which specific line of the ProbConnexion_ID_display matrix that
    % is associated to MaxProbConnexion.T(1)
    % -> the 'Parent2_find' gives the index of the selected sec. Parent Neuron (as
    % the index in ProbConnexion_ID_display(:,2))
    % if it is empty, then display a problem and stop.
    
    Parent2_find = find( ProbConnexion_ID_display(:,1) == MaxProbConnexion.T(1) & ProbConnexion_ID_display(:,2) == MaxProbConnexionSec_selected(1) );
    
    
    if ( isempty(Parent2_find) == 1)
    
        display("caught exception - stopping");
    
        pause
    
    else
        % The value of MaxProbConnexionSec_selected(1) is the ID of the Sec.
        % Parent neuron
        fprintf('Found Sec. Parent neuron : ID #%d \n', MaxProbConnexionSec_selected(1));
    end


    % C/ Validate the Third Parent Neuron
    
    % Knowing the target neuron for the first connexion and a Sec. Parent neuron, we look at another
    % already connected neuron 'Th. Parent' neuron to connect with.

    id = 1;

     % Look for a possible Third Parent that is neither the same neuron at
     % the 'Parent' neuron, nor the same as the Sec. Parent.
    % => the most probable neuron is designated in
    % MaxProbConnexionTh_selected(1) since MaxProbConnexionSec.P is
    % order by decreasing probabilities.

    MaxProbConnexionTh_selected = 0;
    for zz = 1:length(MaxProbConnexionSec.P)
    
        if ( MaxProbConnexionSec.P(zz) ~= MaxProbConnexion.P(1) && MaxProbConnexionSec.P(zz) ~= MaxProbConnexionSec_selected(1) ) % ((MinProb_SecConnection(zz) > 0 ?? )
            MaxProbConnexionTh_selected(id) = MaxProbConnexionSec.P(zz);
            id = id + 1;
        end
    
    end

    if ( (MaxProbConnexionTh_selected) == 0)
    
    fprintf('Found Third Parent neuron : none \n');
    
    else
        % The value of MaxProbConnexionSec_selected(1) is the ID of the Th.
        % Parent neuron
        fprintf('Found Third Parent neuron : ID #%d \n', MaxProbConnexionTh_selected(1));
    end

    
    % For debug purpose: display the ProbConnexion_ID_display
    if ( DebugMode_inference == 1 )
    
        fprintf("Target ID - (Parent ID - Parent We) - 'We' - 'Lo' - 'Di' - sum \n");
    
        for uu = 1: (ProbConnexion_counter - 1)
    
            if ( uu == Parent2_find)
                fprintf("\t %d \t (%d \t %2.2f) \t %2.2f \t %2.2f \t %2.2f \t %2.2f -> Selected Sec. Parent Neuron :: (T,P)neurons = (%d, %d)  \n", ProbConnexion_ID_display(uu,1), ProbConnexion_ID_display(uu,2), ProbConnexion_ID_display(uu,7), ProbConnexion_ID_display(uu,3), ProbConnexion_ID_display(uu,4), ProbConnexion_ID_display(uu,5), ProbConnexion_ID_display(uu,6), ProbConnexion_ID_display(uu,1), ProbConnexion_ID_display(uu,2))
            end
    
            if ( uu == Target_find)
                fprintf("\t %d \t (%d \t %2.2f) \t %2.2f \t %2.2f \t %2.2f \t %2.2f -> Selected Target Neuron :: (T,P)neurons = (%d, %d) \n", ProbConnexion_ID_display(uu,1), ProbConnexion_ID_display(uu,2), ProbConnexion_ID_display(uu,7), ProbConnexion_ID_display(uu,3), ProbConnexion_ID_display(uu,4), ProbConnexion_ID_display(uu,5), ProbConnexion_ID_display(uu,6), ProbConnexion_ID_display(uu,1), ProbConnexion_ID_display(uu,2))
    
            else
                fprintf("\t %d \t (%d \t %2.2f) \t %2.2f \t %2.2f \t %2.2f \t %2.2f \n", ProbConnexion_ID_display(uu,1), ProbConnexion_ID_display(uu,2), ProbConnexion_ID_display(uu,7), ProbConnexion_ID_display(uu,3), ProbConnexion_ID_display(uu,4), ProbConnexion_ID_display(uu,5), ProbConnexion_ID_display(uu,6))
    
            end
    
        end
    
        % Display the ordered list of the Parent neuron candidates
        fprintf("Ordered list / max Prob. connexion : ( ");
    
        for zz = 1:length(MaxProbConnexionSec.P)
    
            fprintf("%d,", MaxProbConnexionSec.P(zz));
    
        end
    
        fprintf(") \n");
    
    end
    
    
     % D/ Update the connectivity matrix : finally the two ('Parent' + 'Sec. Parent') neurons are both connected to the 'Target' neuron.
    
    Rank_ConnectedIDNeuron = Rank_ConnectedIDNeuron + 1;
    
   % these two following lines are obsolete -> needs the Ref. Generator to be
   % included -> everything in the same line ;) 
   % ConnectedIDNeuron(Rank_ConnectedIDNeuron, 1) = MaxProbConnexionSec_selected(1);
   % ConnectedIDNeuron(Rank_ConnectedIDNeuron, 2) = MaxProbConnexion.T(1); 

    Target_weigth = ReferenceGenerator( Rank_ConnectedIDNeuron, RefGeneratorConfig.type_generator, RefGeneratorConfig.GenIncrement );
    
    ConnectedIDNeuron(Rank_ConnectedIDNeuron,:) = [MaxProbConnexionSec_selected(1), MaxProbConnexion.T(1), CountNewNeuron, Rank_ConnectedIDNeuron];

    % Targeted neuron assigned to 'newConnectedID'
    newConnectedID = ConnectedIDNeuron(Rank_ConnectedIDNeuron,2);

    % Rank_ConnectedIDNeuron = Rank_ConnectedIDNeuron + 1;
    % ConnectedIDNeuron(Rank_ConnectedIDNeuron, 1) = MaxProbConnexionTh_selected(1);
    % ConnectedIDNeuron(Rank_ConnectedIDNeuron, 2) = MaxProbConnexion.T(1);
    
                if ( DebugMode_connectedMatrix == 1)

                 fprintf('========================================================== \n');

                   fprintf('NewConnectedID : %d \n', newConnectedID);

                        fprintf('ConnectedID matrix : \n');
                    fprintf(' Parent ID    TargetNeuron ID    #NeuronIndex       Rank \n' )
    
                    for jjj = 1:Rank_ConnectedIDNeuron
                    fprintf(' %d \t\t %d \t\t %f \t %d \n', ConnectedIDNeuron(jjj,1), ConnectedIDNeuron(jjj,2), ConnectedIDNeuron(jjj,3), ConnectedIDNeuron(jjj,4) )
                    end

                fprintf('========================================================== \n');


                end


                % Update CountNewNeuron to prepare the next 'ordered' neuron
                CountNewNeuron = CountNewNeuron + 1;