    
    % neuron counter from one each call / deleted at the end of the script
    count = 1;
    
    % Neuron mapping as a structure:
    % Neuron(count = 1) : Id_1, x1, y1, weigth1, weigth_target1, load1
    % Neuron(count = 2) : Id_2, x2, y2, weigth2, weigth_target2, load2
    % Neuron(count = 3) : Id_3, x3, y3, weigth3, weigth_target3, load3
    %        ...                        ..
    % Neuron [input - 1] (count = n-1) : Id(n-1), x, y, weigth, weigth_target, load
    % Neuron [input - 2] (count = n)   : Id(n), x, y, weigth, weigth_target, load
    
    % The n last lines contains the input neurons -> much easier to update if
    % new input neurons are created while the program runs (not need
    % to re-assign other neurons ID in case of the inclusion of a new input neuron)
    
    % 'RunningNeuronCreate' : Flag that allows building the whole neural network -> disabled (= -1) after the initialization
    
    % =============== HIDDEN NEURON NET. BUILD (maximum of neurons = 'Max_Neurons') ==============
    
    
    % Having called the mesh builder, the following loop is called to create the neural network
    % and to update the 'count' variable (the network is created just one time).
    
    % The mesh builder requires only two input neurons : more inputs can be
    % added during the Network run
    
    %   NeuronMesh(1).Test = 1; % this field is only used for debug
    NeuronMesh(1).x = Input_xy(1,1);
    NeuronMesh(1).y = Input_xy(1,2);
    
    %    NeuronMesh(2).Test = 2; % this field is only used for debug
    NeuronMesh(2).x = Input_xy(2,1);
    NeuronMesh(2).y = Input_xy(2,2);
    
    NbOfInputNeuron = length( Input_xy );
    
    % Call the builder
    NeuronMesh = NetworkMeshBuilder (kappa, iota, sign_offset_neg, sign_offset_pos, offset_coord, maxNeurons, NeuronMesh );
    
    % Generate all the 'Max_Neurons' neurons in w.r.t. the
    % Neuron mapping (except the input neurons)
    for count = 1:1:length( NeuronMesh ) - length( Input_xy )
    
        % Neuron creation (only one time at the very first
        % initialization)
    
        if RunningNeuronCreate == 1
    
            Neuron(count).Id = count;  % ID assignation
            Neuron(count).x = NeuronMesh(count + length( Input_xy )).x; % x-position / the input neurons are omitted
            Neuron(count).y = NeuronMesh(count + length( Input_xy )).y; % y-position / the input neurons are omitted
            Neuron(count).weigth = 0; % weigth
            Neuron(count).weigth_target = 0; % weigth
            Neuron(count).load = 0; % load: nb of connexion of a neuron
            NeuronList(count) = Neuron(count).Id; % separate save of ID (as a non field) to process the wirings
    
        end
    
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        count = count + 1; % neuron counter (must be re-updated each time of the Mapping Update)
    
    end
    
    % =============== INPUT NEURONS BUILD ==============
    
    
    % Create and display input neurons whose coordonates are inside the grid [0, grid_x_max; 0, grid_y_max]
    % BASED on the 'count' variable previoulsy properly updated
    % !!!!!!!!!!!!!!!!!!!!!!!! The neuron inputs could be be updated
    % according to the time ???
    
    % This loop is always called - even if the network is already created - in
    % order to update the 'count' variable, but the network is created just one time.
    % should be improved in future versions ;)
    
    for countInput = 1:NbOfInputNeuron
        %
        %     % Initialization phase to build the set of neurons / global map
        %     % that will be progressively used during the network regular update
        %
        %     % ============== RunningNeuronCreate == 1
    
        if RunningNeuronCreate == 1
    
            Neuron(count).Id = count; % ID assignation
            Neuron(count).x = NeuronMesh(countInput).x; % x-position
            Neuron(count).y = NeuronMesh(countInput).y; % y-position
            Neuron(count).weigth = 0; % weigth
            Neuron(count).weigth_target = 0; % weigth
            Neuron(count).load = 0;  % load: nb of connexion of a neuron
            NeuronList(count) = Neuron(count).Id; % separate save of ID (as a non field) to process the wirings
            InputNeuronID(countInput) = count;
        end
    
        count = count + 1;
    
    end
    
    % Create a NeuronWeightList to update the REFERENCE weight of each neuron
    NeuronWeigthList = zeros(2,count);
    NeuronStatList = zeros(2,count);

    % For a particular neuron 'x':

    % index (1,x) refers to the 'measured / controlled' value
    % index (2,x) refers to the targeted value
    % index (3,x) refers to the nb of connexions associated to 'x'
    % index (>3,x) list all sub-targeted weigths (that amis to help
    % converging the control)

    
    % =============== DISPLAY NEURONS ==============
    
    % OPTIONAL Neuron display (only during the
    % initialization): display of the general mapping without
    % the connexions if 'DisplayFullNetwork = 1'
    
    if ( DisplayFullNetwork == 1 )
    
        for count_ = 1:1:length( Neuron )
    
            % scatter(Neuron(count_).x, Neuron(count_).y, 500, 'm', 'filled')
    
            % Display current weigth
            %   txt_current_weigth(count) = text(Neuron(count).x, Neuron(count).y-0.1, int2str( Neuron(count).weigth_target ));
            %   txt_current_weigth(count).Color = 'red';
            %   txt_current_weigth(count).FontSize = 14;
    
            % Display neuron ID
    
            if ( count_ <= length( Neuron ) - NbOfInputNeuron )
                scatter(Neuron(count_).x, Neuron(count_).y, 800, 'c', 'filled')
            else
                scatter(Neuron(count_).x, Neuron(count_).y, 800, 'y', 'filled')
            end
    
            txt_neuron_ID(count_) = text(Neuron(count_).x, Neuron(count_).y, int2str( Neuron(count_).Id ));
            txt_neuron_ID(count_).Color = 'black';
            txt_neuron_ID(count_).FontSize = 14;
    
            grid on
            hold on
    
        end
    
        % Not clear wheater if the global network map can be used in the future
        % while running the complete code ... for the moment, say we
        % abort the program after having displayed the global network map
    
        %% =======================================================
        %% =======================================================
        %% =======================================================
    
           fprintf('Please restart the program by disabling ''DisplayFullNetwork == 0''... Abort ! \n\n')
           pa
        %   return
    
    end
    
    % =============== UPDATE NEURON FLAG ==============
    
    % assign the number of neurons that have been built to:
    % 'UpdateInputNeuron'= number of input neurons
    % 'UpdateHiddenNeuron' = number of stand. neurons
    if RunningNeuronCreate == 1
    
        UpdateAllNeuron = count - 1;
        UpdateInputNeuron = length( Input_xy );
        UpdateHiddenNeuron = UpdateAllNeuron - UpdateInputNeuron;
    
        % check if the increment of the create neurons correspond to the
        % max. expected
        if ( UpdateHiddenNeuron == maxNeurons )
            fprintf('Neuron network initialized. \n')
        else
    
            display('problem with the creation of the neuron system !! abort')
        end
    
    end
    
    %  pause
    
    % =============== DEF. OF NEURON WIRING ==============
    
    color = ['b', 'r', 'c', 'm', 'y', 'g', '--b', '--r', '--c', '--m', '--y', '--g'];
    
    index_wiring = 1;
    WiringRank = [0, 0, 0];
    
    % WiringRank contains every connexion index by a rank number (excluding same wires -> similar config. detection)
    
    % The goal is to locally assign (pre-defined) wires index to the current
    % configuration of neurons given in the vector 'ListConnectedNeuron'
    
    % Assign a rank number to wires (exclusing same wires -> similar config. detection)
    % example:
    % *1 - *2   -      *3 - *4
    % 3 - 11  ->  rank #1 - 0
    % 3 - 12  ->  rank #2 - 0
    % 5 - 11  ->  rank #3 - 0
    % 5 - 12  ->  rank #4 - 0
    % 11 - 3  ->  rank #1 - 1 (keep the same rank)
    % 12 - 3  ->  rank #2 - 1 (keep the same rank)
    % ...
    
    % Sweep neurons (execept the inputs) in order to create connections with
    % all neurons
    for IndexFromNeuron = 1: ( length( NeuronList ) - length( Input_xy) )
    
        for IndexToNeuron = 1 : length( NeuronList )
    
            if ( IndexToNeuron ~= IndexFromNeuron  )
    
                % Given a new possible connection x_new_1 and x_new_2,
                % and an older connection x_old_1 and x_old_2
                % check if x_new_1 == (x_old_1, x_old_2) or x_new_2 == (x_old_1, x_old_2)
                % already exist: if yes RankDoubleConnection != 1 and
                % assign the previous rank from (x_old_1, x_old_2)
                RankDoubleConnection = -1;
                for SearchDoubleWiring = 1:length( WiringRank(:,1) )
    
                    if ( ( ( Neuron(IndexFromNeuron).Id == WiringRank( SearchDoubleWiring, 1 ) ) && ( Neuron(IndexToNeuron).Id == WiringRank( SearchDoubleWiring, 2 )) || ...
                            ( Neuron(IndexToNeuron).Id == WiringRank( SearchDoubleWiring, 1 )) && (Neuron(IndexFromNeuron).Id == WiringRank( SearchDoubleWiring, 2 )) ) && ...
                            RankDoubleConnection == -1)
    
                        RankDoubleConnection = WiringRank( SearchDoubleWiring, 3 );
    
                    end
    
                end
    
                WiringRank( index_wiring, 1 ) = Neuron(IndexFromNeuron).Id;
                WiringRank( index_wiring, 2 ) = Neuron(IndexToNeuron).Id;
    
                if ( RankDoubleConnection == -1  )
                    WiringRank( index_wiring, 3 ) = index_wiring;
                    WiringRank( index_wiring, 4 ) = 0;
                else
                    WiringRank( index_wiring, 3 ) = RankDoubleConnection;
                    WiringRank( index_wiring, 4 ) = 1;
                end
    
                % Display all connexions w.r.t. the indexed
                % 'IndexFromNeuron'
                %
                % plot ( [ Neuron( WiringRank( index_wiring,1 ) ).x, Neuron( WiringRank( index_wiring,2 ) ).x], ...
                %    [ Neuron( WiringRank( index_wiring,1 ) ).y, Neuron( WiringRank( index_wiring,2 ) ).y] ,color(IndexFromNeuron), 'linewidth', 2)
    
                index_wiring = index_wiring + 1;
    
            end
    
        end
    
    end
    
    % Create a WiringWeigthList to update the weight of each neuron
    WiringWeigthList = zeros(1,index_wiring);
    % Also create the W_damping matrix (that will damp the transient of
    % each new wire connexion)
    W_damping = zeros(1,index_wiring);
    
    if ( DebugMode_connectedMatrix == 1 )

        fprintf("===== Display the Wiring matrix ===== \n")
        WiringRank
        fprintf("===================================== \n")

    end
    
        % Catch the total number of wires
        MaxWires = WiringRank(end,3);

    % =============== end of initialization of the neural network ==============
    
    RunningNeuronCreate = -1;


    
    
    % delete the neuron counter / will be reset at each call
    clear count
    
    
    

