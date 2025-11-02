    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %                A Connectome-Based Inference of 
    %         Dynamical Neural Wiring: A Control Approach 
    % 
    %       -- Network-based Para-Model Control (NetPMC) --
    %
    %                Copyright 2024-2025 Loïc MICHEL
    %                     under the MIT license
    %
    %                         - - - - - 
    %                 version 1.0-beta 1 (Mar. 2025)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Revision history:
    
    % Creation: v 1.0-beta-1 - the complete network is created including the
    % growing structure / inference matrix management
    % beta 1 -> manages only a first layer in closed-loop + statistic
    % propagation

    clear
    warning off
    close all
    clc
    
    % NOTES ABOUT THIS VERSION:
    % This beta version is limited to few neurons that are organized as a
    % single layer (each neuron is connected to the inputs) and a single
    % output neuron, that is connected to the first layer.
    % The goal is firstly to study how the control laws (as learning algorithm) do interact
    % within these few neurons with respect to basic traing data. 
    % The ongoing developments towards a (complete) growing network would allow deeper 
    % interactions between the connexions and clusterization of neurons
    % to deal with multiple training data. 

    % GETTING STARTED:
    % To reproduce the results presented in the repository, simply run this
    % code by setting 'GraphDisplay = 0' to get the final plots /or/ set 
    % 'GraphDisplay = 1' to watch the network evolving in association with
    % the tracking dyn. of each neuron.


    % ================ Simulation settings / TO BE MODIFIED BY THE USER (beta version) ================
    MaxIterations = 2500000; %Max. iterations (= 1000 * (InstantNeuronGrowing = 2500) )

    GraphDisplay = 0; % Display the online updated graph of the control and the dynamics of connections
    Verbose = 0; % Verbose information on the terminal
    write_file = 0; % Save information to 'iteration_list.txt' file

    LearningEnable = 1; % Enable learning (if set =0 then the control ref. are constant, see below)  
    TrainingSet = 1; % (to be set =1 / learning of the sine function time-derivative)
    PlotTraingSet = 0; % Plot the data set - the program should be restarted (=0 for normal run)

    Synapse_activation_period = 100; % Period of activation of connexions
    InstantNeuronGrowing = 2500; % Period of creation of a new neuron (stops at the neuron #10 in this beta version)
    epoch_sample_cycle = 100; % Period to 'sample' the current value of the training data

    % ------- SINGLE LAYER MODE (beta version): SET THE REF. OF EACH NEURON ----------------------
    % The following control references are set from the beginning of the simulation in order to start
    % controlling each neuron. In this beta version, if 'LearningEnable = 1', then the learning starts
    % once the neuron #10 is created (the ref. 'NeuronTarget_Layer2' is replaced by
    % the training data.) 

    % ---- First layer control tracking references
    NeuronTarget_Layer1 = 1.01; % Static value of the control reference for the first neuron
    NeuronTarget_Delta = 1e-2;
    % The first neuron tracking ref. starts at 'NeuronTarget_Layer1' and the other
    % neurons tracking refs. of the first layer are increased respectively of 'NeuronTarget_Delta',
    % 2*'NeuronTarget_Delta', ... . 

    % ---- Output neuron control reference (if 'LearningEnable = 0')
    NeuronTarget_Layer2 = 2.52; % Static value of the control reference
    % The output neuron ref. is set at 'NeuronTarget_Layer2' (disabled if
    % 'LearningEnable = 1')

    % ===========================================================================
    
    % ---------------------------------------------------------------
    %                        MAIN USER SETTINGS
    % ---------------------------------------------------------------
    
    
    % Input neurons coordonates in the global neuron grid
    Input_xy = [ 0, 1.5; 1.5, 0 ];
    
    InputNeuron_Q = [ 1, 1 ]; % initial values of the two inputs
    

    
    maxNeurons = 10; % Max of controlled neuron in the map (=10 for this beta version - do not change)
    NbNeuronsPerCluster = 4; % not used in this beta version
    
    % Defines Neuron ID that will be used to initiate connexions
    EntryConnectedNeuron = [5 3]; % Do not change
    
    DisplayFullNetwork = 0; % Display the complete mapping of the network (stops the program)
    
    % The section below is the terminal display and enable write to file
    % (bug with the online graph display that does not allow 
    % Synapse_activation_period < 100 !)
 
    PlotFinalGraph = 1; % plot all graphs at the end of the simulation
    verbose_pause = 0; % pause after each synaptic reset  
    
    % ------------------------------------------------
    InitControlMaxIter = 250000; %Max. iterations to initialize every control loop
    PreRef = 0.5; % Choice of pre-stabilization very low
    ControlPMC_Init_EN = 1;
    % ------------------------------------------------
    
    % ------- SINGLE LAYER MODE (beta version): SET THE REF. OF EACH NEURON ----------------------
    % NbWires_debug_before = 1; % for debug only
    % NbWires_debug_after = 1;  % for debug only
    % --------------------------------------------------------------------------------------------
    
    InternalControlParamSwitchThreshold = 0.01; %not used (to manage control param in future versions)
    
    % ------------------------------------------------
    EnableSweepingConnexion = 1; % set to =1 do not change
    
    % ----- DEBUG ONLY MODE (some sections to be uncommented) -----
    % NOTE : if intended to run a double wiring between two neurons,
    % "For debug only" simply uncomment these sections.
    % -------------------------------------------------------------
    
    DisplayNeuron_ID = 0;
    DebugMode_connectedMatrix = 0;
    % DebugMode_inference = 0; %not used
    %-------------------------------------------------
    HierarchicalControl = 0; % Enable hierarchical control (to be tested in future versions)    
    %-------------------------------------------------
    DisplaySwitchSignal = 0;
    OnlineDebugPlot = 0;
    
    % Neural Mesh builder param (should not be changed for the demo)
    kappa = 0.1;
    iota = 1.1;
    sign_offset_neg = -1;
    sign_offset_pos = 1.4;
    offset_coord = 0.1;
    kappa = 1.1;
    iota = 0.98;
    
    % weigths of the wiring connexion (will be used in futre versions for probabilistic
    % inference)
    %gamma_coeff.gamma_lo = 0; %
    %gamma_coeff.gamma_di = 0.25;
    %gamma_coeff.gamma_we = 0.75;
    %max_load = 4;
    
    % Targeted weigth generation
    %RefGeneratorConfig.type_generator = 0;
    %RefGeneratorConfig.GenIncrement = 1e-1;
    
    % Neuron dynamical model (first order model)
    A = -1e0; % internal synapse model [A] matrix
    B = 1; % internal synapse model [A] matrix
    C = 1e0; % internal synapse model [A] matrix
    
    % oscillatory pertubation to test control robustness (to be set in
    % future versions)
    %amp_sine_pert = 0.1;
    %freq_sine_pert = 0.1;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %
    fprintf("\n\n * * * * Network-based Para-Model Control (NetPMC) - v 1.0-beta 1 (Mar. 2025) * * * * \n\n");
    pause(1)
    tic
    
    % Initialize Net-listing connected neurons
    ConnectedIDNeuron = []; % net-list table of the form:
    newConnectedID_vec = [];
    
    % From ...   -->   ... To
    % [Neuron_input_A, Neuron_1, Targeted weigth_link1 ;
    % [Neuron_input_B, Neuron_2, Targeted weigth_link2 ;
    % [Neuron_1      , Neuron_3, Targeted weigth_link3 ;
    % [Neuron_1      , Neuron_4, Targeted weigth_link4 ;
    % [Neuron_2      , Neuron_3, Targeted weigth_link5 ;
    %        ...
    %
    
    Rank_ConnectedIDNeuron = 0; %neuron counter: index of the last %%%%%%%%%%%%%%%%%%%%%%%%%%%
    RunningNeuronCreate = 1; % Flag that allows building the whole neural network -> disabled (= -1) after the initialization
    % newID = -1; % add a new neuron -> enabled to initialize (may be obsolete ?)
    %   PlotNeuronConnexion = 0; % initialization of the network: build of the neuron grid
    NumberNeuronsSweeping = 2; % during the clocking of the network : updated each time a new neuron is added
    UpdateAllNeuron = 0; % number of max neurons -> calculated at the end of the initialization of the network
    UpdateInputNeuron = 0; % numbert of input neurons
    UpdateHiddenNeuron = 0; % number of hidden neurons -> calculated at the end of the initialization of the network
    PriorityNewNeuron = -99; % index of priority for created new neurons
    OutputClass_index = 1; % index to compute the observability matrix
    OutputClass_index_ = 0; % index to compute the observability matrxi
    
    
    time_ = 0;
    %  switch_vec = 0;
    %  Max_neurons_count_vec = 0;
    TimeStep = 4e-5;
    
    % =============== CREATE THE INITIAL NEURAL MAPPING ==============
    
    % Could be displayed if 'DisplayFullNetwork = 1'.
    % NeuralMappingUpdate;
    
    % WiringRank contains every connexion index by a rank number (excluding same wires -> similar config. detection)
    
    % WiringRank matrix mapping :
    % Assign a rank number to wires (exclusing same wires -> similar config. detection)
    
    % *1 - *2  -       *3 - *4
    % 3 - 11  ->  rank #1 - 0
    % 3 - 12  ->  rank #2 - 0
    % 5 - 11  ->  rank #3 - 0
    % 5 - 12  ->  rank #4 - 0
    % 11 - 3  ->  rank #1 - 1 (keep the same rank)
    % 12 - 3  ->  rank #2 - 1 (keep the same rank)
    % ...
    
    NeuralMeshMapping_v1;
    
    % Control initialization
    delay_start_EN = zeros(1,MaxWires);
    y_int = 0;
    para_exp_err = zeros(1, MaxWires);
    
    para_stand_err1 = zeros(1, MaxWires);
    para_u1_1 = zeros(1,MaxWires);
    para_u1 = zeros(1, MaxWires);
    
    para_G1_1 = zeros(1, MaxWires);
    para_G1 = zeros(1, MaxWires);
    
    para_trapz1_1 = zeros(1, MaxWires);
    para_trapz1 = zeros(1, MaxWires);
    
    ii_1 = ones(1, MaxWires);
    
    y_ref = zeros(1, MaxWires);
    y_ref_ = ones(1, MaxWires);
    y_RK = zeros(1,MaxWires);
    
    para_u_final1 = 0;
    u_final1 = 0;
    
    % Data save management (with compression)
    length_seg = 1e3;
    %Wire weigths part
    y_sampled0 = [];
    y_sampled_in_vec = zeros(1,MaxWires)';
    y_signal_in_vec = zeros(1,MaxWires);
    index_in_vec = zeros(1,MaxWires);
    internal_cnt_in_vec = zeros(1,MaxWires);
    internal_cnt = zeros(1,MaxWires);
    
    %Neuron weights part
    y_sampled0_ = [];
    y_sampled_in_vec_= zeros(1,MaxWires)';
    y_signal_in_vec_ = zeros(1,MaxWires);
    index_in_vec_ = zeros(1,MaxWires);
    internal_cnt_in_vec_ = zeros(1,MaxWires);
    internal_cnt_ = zeros(1,MaxWires);
    
    % The goal is to locally assign (pre-defined) wires index to the current
    % configuration of neurons given in the vector 'ListConnectedNeuron'
    
    
    % Intialize the figure handle
    f1 = figure;
    set(gcf,'Position', get(gcf,'Position') + [0,0,100,0]); % get position of Figure(1)
    pos1 = get(gcf,'Position'); % get position of Figure(1)
    set(gcf,'Position', pos1 - [pos1(3)/2,0,0,0])
    
    if ( GraphDisplay == 1)
    f2 = figure;
    set(gcf,'Position', get(gcf,'Position') + [0,0,100,0]);
    pos2 = get(gcf,'Position');  % get position of Figure(2)
    set(gcf,'Position', pos2 + [pos1(3)/2,0,0,0]) % Shift position of Figure(2)
    
    % f4 = figure;
    % set(gcf,'Position', get(gcf,'Position') + [0,0,100,0]);
    % pos4 = get(gcf,'Position');  % get position of Figure(2)
    % set(gcf,'Position', pos4 + [pos1(3)/2,0,0,0]) % Shift position of Figure(2)
    %   end
    end
    
    if ( DisplaySwitchSignal == 1)
        f3 = figure;
        set(gcf,'Position', get(gcf,'Position'));
        pos3 = get(gcf,'Position');  % get position of Figure(2)
        set(gcf,'Position', pos2 - [0,2*pos1(3),0,0]) % Shift position of Figure(2)
    end
    
    % Initialize the I/O file
    
    delete 'iteration_list.txt'
    if ( write_file == 1)
        fid = fopen('iteration_list.txt', 'w');
    
        fprintf(fid, 'new simulation \n');
    end
    
    % =============== INITIALIZE THE NETWORK WITH THE TWO FIRST CONNEXIONS ==============
    
    % Since the network is progressively growing, create the sequence of
    % neurons that will be added during the simulation
    [RandomNeuronVector, ConnectedIDNeuron, Neuron, SortConnectedIDNeuron ] = ...
        CreateNeuralGrowingSequence(ConnectedIDNeuron,  ...
        Neuron, ...
        maxNeurons, ...
        NbNeuronsPerCluster, ...
        EntryConnectedNeuron);
    
    
    % Initialization of the neural network from the input neurons:
    % (single) neurons are simply connected to each neuron input in order to create the first
    % connexions
       
    cnt_input = 1;
    for tt = UpdateAllNeuron:-1:(UpdateAllNeuron - UpdateInputNeuron + 1)
    
        % Update of the Rank_ConnectedIDNeuron here since the inference
        % procedure is called later
        Rank_ConnectedIDNeuron = Rank_ConnectedIDNeuron + 1;
    
        Parent_ID = Neuron(tt).Id;
    
        % ConnectedIDNeuron matrix mapping:
        %
        % ConnectedIDNeuron[1, Rank_ConnectedIDNeuron = 1 ] : NewNeuron_1
        % ConnectedIDNeuron[2, Rank_ConnectedIDNeuron = 1 ] : PriorityNewNeuron_1
    
        % ConnectedIDNeuron[1, Rank_ConnectedIDNeuron = 2 ] : NewNeuron_2
        % ConnectedIDNeuron[2, Rank_ConnectedIDNeuron = 2 ] : PriorityNewNeuron_2
    
        % not used in this beta version
        % The 'ReferenceGenerator' generates the target weigth for the current ID neuron inside the 'ConnectedIDNeuron' vector
        % Seems to be ReferenceGenerator( Rank_ConnectedIDNeuron, RefGeneratorConfig.type_generator, RefGeneratorConfig.GenIncrement )
    
        ConnectedIDNeuron(1,Rank_ConnectedIDNeuron) = EntryConnectedNeuron(cnt_input);
        ConnectedIDNeuron(2,Rank_ConnectedIDNeuron) = Rank_ConnectedIDNeuron;
        ConnectedIDNeuron(3,Rank_ConnectedIDNeuron) = 1; % Assign group number (default)
    
        if ( RandomNeuronVector(3, Rank_ConnectedIDNeuron) == 1 )
            OutputClass_index = 1;
            OutputClass_index_ = OutputClass_index_ + 1;
        else
            OutputClass_index = OutputClass_index + 1;
        end
    
        % Will be used later for clustering
        OutputClass( OutputClass_index_, OutputClass_index ) = ConnectedIDNeuron(1, Rank_ConnectedIDNeuron);
    
        % not used
        %  PriorityNewNeuron = PriorityNewNeuron + 1;
        cnt_input = cnt_input + 1;
    
    end
    
    cnt_period_activation = Synapse_activation_period + 1; % init. to (> Synapse_activation_period) in roder to start at 0
    
    ControlFlagManagement = zeros(1,MaxWires);
    InternalCount = 0; % only for the 'validConnexion' loop
    le_WiringSortList = 1; % should be initialized to '1'
    Wiringlist_current = 1; % should be initialized to '1' since it allows starting
    % the Wire index at '1' (if '0' -> cretae trouble with the wiring
    % index)
    
    Iteration_k = -1; % general iterator
    
    color_vector_string;
    
    
    PMC_ParamSettings;
    
    % =============================================================================
    % For debug only -> to check the growing sequence of the network
    %    OutputNeuron_Q = 1;
    %    DebugMode_ComputeNeuralMatrix;
    % =============================================================================
    
    
    % =============================================================
    %   - - - - - - - - - STARTING THE CONTROL - - - - - - - - -
    % =============================================================
    
    % Initialization of every controllers -> very important to ensure
    % stability while starting wirings
    
    fprintf("Neuron network dynamics... starting ! \n");
    
    fprintf("Set the Synapse_activation_period = %f ", Synapse_activation_period)
    
    if ( EnableSweepingConnexion == 1 )
        fprintf('(Sweeping connexion enabled !) \n');
    else
        fprintf('(Sweeping connexion disabled !) \n');
    end
    
    if ( HierarchicalControl == 1 )
        fprintf('(Hierarchical control enabled !) \n');
    else
        fprintf('(Hierarchical control disabled !) \n');
    end
    
  
    % ------------ INITIALIZE CONTROLLERS ------------
        % The goal is simply to initialize the control to predefined values
        % before beeing updated through the wires
    if ( ControlPMC_Init_EN == 1 )
        ControlPMC_Init_v2;
    else
        OutputFeedback = 0;
    end
        
    % ------------ SET THE INPUT NEURONS ------------
    % Warning : InputNeuronID(1) should give the index of the first
    % input neuron ... InputNeuronID(2) is the index of the sec. input
    % neuron
    
    NeuronWeigthList(1,InputNeuronID(1) ) = InputNeuron_Q(1);
    NeuronWeigthList(1,InputNeuronID(2) ) = InputNeuron_Q(2);
    
    %duplicate to the second line
    NeuronWeigthList(2,InputNeuronID(1) ) = InputNeuron_Q(1);
    NeuronWeigthList(2,InputNeuronID(2) ) = InputNeuron_Q(2);
    
    
    % =============================================================================
    % For debug only -> to check the growing sequence of the network
    % considering a single layer of a couple neurons and a single output
    % neuron
    %  VerifyConnectNeuronSeq;
    %
    % =============================================================================
    
    
    grow_index = 1;
    pourcent_id = 0;
    pourcent_id_ = 0;
    ind_training = 1;
    t_ind = 0;
    
    % Initialization of the dataset
    DataTrainingEpoch;
    
    newConnectedID = -1;
    
    % Init the output vectors for display purpose
    OutputFeedback_vec = zeros(10, 100000);
    StatFeedback_vec = zeros(5, 100000);

    ii = 0;
    
    while (Iteration_k <= MaxIterations )
    
        Iteration_k = Iteration_k + 1;
        
        % ============ TRAINING SECTION ============
    
        % Switch to learning -> when newConnectedID = 10 then
        % run the learning considering the training_input and
        % training_output data assigned to
        % 'NeuronWeigthList(1,InputNeuronID(1) )'
        % and 'NeuronTarget_Layer2'
        if ( LearningEnable == 1 & newConnectedID == 10 )
    
            if ( ind_training < length(Training_input(1,:)) )
    
                if ( t_ind == epoch_sample_cycle)
    
                    ind_training = ind_training + 1;
    
                    t_ind = 0;
    
                else
    
                    t_ind = t_ind + 1;
    
                end
    
            else
    
                ind_training = 1;
    
            end
            %
    
            NeuronWeigthList(1,InputNeuronID(1) ) = Training_input(1, ind_training );
            NeuronWeigthList(1,InputNeuronID(2) ) = Training_input(2, ind_training );
    
            NeuronWeigthList(2,InputNeuronID(1) ) = Training_input(1, ind_training );
            NeuronWeigthList(2,InputNeuronID(2) ) = Training_input(2, ind_training );
    
            NeuronTarget_Layer2 = Training_output( ind_training );
    
            % Save for final plot (at the end of the program)
            Training_epoch_1 = Training_input(1, ind_training );
            Training_epoch_2 = Training_input(2, ind_training );
            Training_epoch_output = Training_output( ind_training );

            % Update the neuron #10 reference
            NeuronWeigthList(2, 10) = NeuronTarget_Layer2;
       
    
        else
    
            Training_epoch_1 = 0;
            Training_epoch_2 = 0;
            Training_epoch_output = 0;
    
        end
    
    
        % =============================================================
        % Manage the wiring activation
    
        if ( EnableSweepingConnexion == 1 )
    
            if ( cnt_period_activation <= Synapse_activation_period )
    
                cnt_period_activation = cnt_period_activation + 1;
    
            else
                cnt_period_activation = 0;
                Wiringlist_current = Wiringlist_current + 1;
    
                if ( Wiringlist_current > le_WiringSortList) % do +1 in le_WiringSortList to take the last in the counting since 'Wiringlist_current' starts at '1'
                    Wiringlist_current = 1;
                end
    
            end
    
        else
    
        end
    
        %  PeriodicSynapseActivation save for plotting (should be
        %  commented)
        %  switch_vec(ii,1) = Wiringlist_current
        %  switch_vec(ii,2) = cnt_period_activation;
    
        % --- For debug only -> FORCES THE WIRING INDEX
        % Wiringlist_current = 1;
        % ------------------------
    
        if ( (Iteration_k == 0) || Iteration_k == floor( grow_index * InstantNeuronGrowing) )
    
            % The references of the two first neurons are set at the first
            % iteration
            if (  Iteration_k == 0 )
    
                NeuronWeigthList(2, EntryConnectedNeuron(1) ) = NeuronTarget_Layer1;
                NeuronWeigthList(2, EntryConnectedNeuron(2) ) = NeuronTarget_Layer1 + NeuronTarget_Delta;
    
            end
    
            % * * * * * * * * * * * * * * * * * * *
            %  CHECK THE GROWING SEQUENCE for the beta version
    
            % Case of 3 neurons only in the first layer
    
            %  3    11    12
            %  5    11    12
            %  9    11    12
            %
            %
            %
            %  3    32    33
            %  5    54    55
            %  9    98    99
    
    
            %  3    11    12
            %  4    11    12
            %  5    11    12
            %  9    11    12
            %
            %
            %  3    32    33
            %  4    43    44
            %  5    54    55
            %  9    98    99
    
    
            % Case of 5 neurons in the first layer
            % and 1 neuron in the sec. layer (output)
            %
            % 3   -10    11    12     0     0
            % 4   -10    11    12     0     0
            % 5   -10    11    12     0     0
            % 8   -10    11    12     0     0
            % 10    3     4     5     8     9
            % 9   -10    11    12     0     0
            %
            %
            %
            % 3   -31    32    33  -555  -555
            % 4   -42    43    44  -555  -555
            % 5   -53    54    55  -555  -555
            % 8   -86    87    88  -555  -555
            % 10   31    42    53    86    97
            % 9   -97    98    99  -555  -555
    
            % * * * * * * * * * * * * * * * * * * *
    
            if ( Iteration_k == floor( grow_index * InstantNeuronGrowing) )
                %---------------------------------------
    
                grow_index = grow_index + 1;
    
                % Obsolete
                % [newConnectedID, ProbConnexion,    MaxProbConnexion, ConnectedIDNeuron, Rank_ConnectedIDNeuron, Neuron, SortConnectedIDNeuron, PriorityNewNeuron] = ...
                %     NeuralConnexionInference(ConnectedIDNeuron, Neuron, UpdateInputNeuron, UpdateHiddenNeuron, max_load, gamma_coeff, ...
                %     Rank_ConnectedIDNeuron, PriorityNewNeuron, RefGeneratorConfig, DebugMode_connectedMatrix, ...
                %     DebugMode_inference );
    
                % ---------------------------------------------------
                % Proposed neuron sequence growing : 3  5	9  4  8  10	 7	2	6	1	0
                % ---------------------------------------------------
    
                % It is better to generate random new neurons - may be expanded in future versions ;)
                [RandomNeuronVector, newConnectedID, ConnectedIDNeuron, Rank_ConnectedIDNeuron, Neuron, SortConnectedIDNeuron, PriorityNewNeuron] = ...
                    NeuralConnexionInference_v2(ConnectedIDNeuron,  ...
                    Neuron, ...
                    Rank_ConnectedIDNeuron, ...
                    PriorityNewNeuron, ...
                    maxNeurons, ...
                    RandomNeuronVector);
    
    
                %======================================================
                %======================================================
                %
                %       THIS SECTION SHOULD NOT BE CHANGED IN THIS
                %                       BETA VERSION
    
                if ( grow_index >= 4)
                    grow_index = 4;
                end
    
                % -----------------------------------------------------
                % -----------------------------------------------------
                % This forces the #10 to NeuronTarget_Layer2 -- STATIC
                % WITHOUT UPDATE
                if (newConnectedID == 10)
    
                    plot_epoch_time_1 = Iteration_k;
    
                    % Hierarchical : The NeuronTarget_Layer2 is layer is assigned either
                    % to only #10 or to all neurons of the first layer
                    if ( HierarchicalControl == 1 )
    
                        fprintf('Warning: rectified wires for the control param: \n');
                        for id__ant = 1:length(SortAnteriorWires)
    
                            PMC_Kp( SortAnteriorWires(id__ant) ) = aa_1;
                            PMC_Kint( SortAnteriorWires(id__ant) ) = bb_1;
    
                            fprintf('[%d] ', SortAnteriorWires(id__ant) );
    
                        end
                        % Applied to all neurons
                        NeuronWeigthList(2, :) = NeuronTarget_Layer2;
    
                    else
                        % Applied to only the #10 neuron
                        NeuronWeigthList(2, 10) = NeuronTarget_Layer2;
       
                    end
    
                    fprintf('\n');
    
                else
                    NeuronWeigthList(2, newConnectedID ) = NeuronTarget_Layer1 + grow_index * NeuronTarget_Delta;
                end
    
                %======================================================
                %======================================================
    
                fprintf('\n\n Create new neuron #%d at the instant %e -- Iteration_k = %d with target %f \n', newConnectedID, time_, Iteration_k, NeuronWeigthList(2, newConnectedID ));
    
                if ( write_file == 1)
                    fprintf('\n\n Create new neuron #%d at the instant %e -- Iteration_k = %d with target %f \n', newConnectedID, time_, Iteration_k, NeuronWeigthList(2, newConnectedID ));
                end
    
    
                % Check if the group remains the same : keep the same
                % line in OutputClass or create a new line in OutputClass
                if ( RandomNeuronVector(3, Rank_ConnectedIDNeuron) == 1 )
                    OutputClass_index = 1;
                    OutputClass_index_ = OutputClass_index_ + 1;
                else
                    OutputClass_index = OutputClass_index + 1;
                end
    
                OutputClass( OutputClass_index_, OutputClass_index ) = ConnectedIDNeuron(1, Rank_ConnectedIDNeuron);
    
                SortAnteriorWires = AnteriorWires(WiringSortList, ConnectedIDNeuron(1, Rank_ConnectedIDNeuron), Rank_ConnectedIDNeuron );
    
                fprintf('\n List of anterior Wires :')
                for hhh = 1:length( SortAnteriorWires )
                    fprintf('[%d]', SortAnteriorWires(hhh));
                end
                fprintf('\n');
    
            end
    
            ListConnectedNeuron = [unique(sort(ConnectedIDNeuron(1,:) )), InputNeuronID];
    
            % ---- CREATION OF NODE MATRICES
    
            % ListConnectedNeuron contains InputNeurons - remove input neurons ('NbOfInputNeuron')
            OnlyConnectedNeurons_ForbConnexion = ListConnectedNeuron(1: length(ListConnectedNeuron) - NbOfInputNeuron);
    
            ConnectedNeuron_ForbConnexion = perms(OnlyConnectedNeurons_ForbConnexion);
    
            %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            % This section manages the growing sequence in this beta
            % version
    
    
            % % For debug only -> Check a simple switch from the
            % % layer_1 to the layer_2
            %      NbNeuronLayer = 3;
            %      ForbConnexionNeuron_A = 3;
            %      ForbConnexionNeuron_B = 5;
            %
            %      ForbConnexionNeuron_C = 0;
            %      ForbConnexionNeuron_D = 0;
            % % ------------------------------------
    
    
            % -------------------------------------------
            % -------------------------------------------
    
            % Management of the first layer only with 5 neurons / neuron #6 is output (v 1.0-beta 1)
    
            %======================================================
            %======================================================
            %
            %       THIS SECTION SHOULD NOT BE CHANGED IN THIS
            %                       BETA VERSION
    
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
    
            %=====================================================
            %=====================================================
    
            %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
            % IMPORTANT : 'WiringSortList' MUST BE used instead of
            % 'WiringListSub' since it avoid redundance of wires
    
            EnableCoupling = 0; % should be set -> no more used / deprecated
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
            % For debug only -> FORCES le_WiringSortList for debug purpose
            % if (  Iteration_k >= InstantNeuronGrowing )
            %     le_WiringSortList = NbWires_debug_after;
            % else
            %     le_WiringSortList = NbWires_debug_before;
            % end
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
    
                            % for debug
                            % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_A )
                            % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_B )
                            % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_C )
                            % find(newConnectedID_vec(ssd) == ForbConnexionNeuron_D )
    
                            fprintf('Warning: a connexion is forbidden in line %d \n', id_u);
    
                            line_cnt( id_u ) = line_cnt( id_u ) + 1;
    
                        end
    
                    end
    
                end
    
            end
    
            % if ( mean( line_cnt ) == length( newConnectedID_vec ) )
            %     fprintf('Check nodes distribution in the forward propagation -> OK \n');
            % else
            %     fprintf('Problem - please check ... Abort !');
            %     pa
            % end
    
            % Post-C / correcting the current node -> remove negative (-) sign
            if ( length( newConnectedID_vec ) >= 2)
    
                IndexLastConnectedID = find( CommonNeuron(:,:,1) == newConnectedID_vec(end) );
    
                CommonNeuron( IndexLastConnectedID ,:,1) = abs( CommonNeuron( IndexLastConnectedID ,:,1) );
                CommonWiring_sort( IndexLastConnectedID ,:,1) = abs( CommonWiring_sort( IndexLastConnectedID ,:,1) );
    
            end
    
    
            fprintf('------------------- \n');
    
            %---------------------------------------
            % ---- CREATION OF NODE MATRICES
    
            % Create the list of the wiring index between the listed connected neurons
            %  [WiringSortList]
    
            % Create the list of connections associated to the connected neurons
            % (except the 'EntryConnectedNeuron')
            %  [CommonNeuron]
    
            % Create the list of all wires associated to the connected neurons
            %  [CommonWiring_sort]
    
    
            % =============================================================================
    
            % Associated the priority rank to each neuron
            Priority_sort = ListControlPriority ( WiringSortList,  ConnectedIDNeuron );
    
            % Update of the Probability matrix -> used in future versions
            %            [ProbConnexion_ID, ProbConnexion_Sum] = ComputeProbabilityMatrix ( gamma_coeff, CommonNeuron , Neuron, max_load );
    
            %  if ( DebugMode_connectedMatrix == 1)
            % fprintf('*** ConnectedID matrix : \n');
            % fprintf('TargetNeuron ID = %d \n', ConnectedIDNeuron(1,end) )
            %
            %
            % fprintf('*** List of connected neurons : \n');
            % CommonNeuron
            %
            % fprintf('*** Priority_sort : \n');
            % Priority_sort
            %
            % fprintf('*** Neuron-WiringList : \n');
            % CommonWiring_sort
            %
            % fprintf('*** Wires sort : \n');
            % list_Wires_sort
    
            %fprintf('*** NeuronWeigth List : \n');
            %NeuronWeigthList
    
            %fprintf('*** WiringSortList List : \n');
            % WiringSortList
    
            %% =========================================================
            % Update the network display with respect to current activated connections
    
            % The variable 'Read_WiringList' is assumed to be internal
            % to this debug part - try to avoid conflicts with the
            % activated neuron
    
            % RESET is also done later in the code but necessary here to
            % initialize the figure (f1)
            % % Regular mode I -  Reset of the connexions ( set 'w' to the plot)
    
            %  if ( GraphDisplay == 1 )
    
            for Read_WiringList = 1:length( WiringSortList(:,1) )
    
                figure(f1);
                plot ( [ Neuron( WiringSortList(Read_WiringList,1) ).x, Neuron( WiringSortList(Read_WiringList,2) ).x], [ Neuron( WiringSortList(Read_WiringList,1) ).y, Neuron( WiringSortList(Read_WiringList,2) ).y] ,'-w', 'linewidth', 2)
                set(gcf,'Color','w');
                hold on
            end
    
            %  end
    
            % =============================================================
            % Regular mode II - Re-Plot / update the network structure
            for count = 1:length( Neuron ) % - length( Input_xy))
    
                if ( isempty( find ( Neuron(count).Id == ListConnectedNeuron ) ) == 0)
                    grid on
                    hold on
    
                    if ( isempty( find ( Neuron(count).Id == InputNeuronID ) ) == 0)
    
                        scatter( Neuron(count).x, Neuron(count).y , 500, 'y', 'filled')
    
                    else
    
                        scatter( Neuron(count).x, Neuron(count).y , 500, 'c', 'filled')
    
                    end
    
                    % if ( count < ( length( Neuron ) - length( Input_xy) ) )
                    %     scatter( Neuron(count).x, Neuron(count).y , 500, 'c', 'filled')
                    % else
                    %     scatter( Neuron(count).x, Neuron(count).y , 500, 'y', 'filled')
                    % end
    
                    % Display neuron ID
                    txt_neuron_ID(count) = text(Neuron(count).x, Neuron(count).y, int2str( Neuron(count).Id ));
                    txt_neuron_ID(count).Color = 'k';
                    txt_neuron_ID(count).FontSize = 14;
                    xlim([-0.5, 3.5]);
                    ylim([-0.5, 2 ]);
    
                end
    
            end
    
            % =============================================================
    
            if ( DebugMode_connectedMatrix == 1)
    
                % Debug mode I - plot ALL connexions
                for IndexPlotNeuro = 1:length( CommonWiring_sort(:,1) )
    
                    for IndexPlotWire = 2:length( CommonWiring_sort(1,:)  )
    
                        %  CommonNeuron(IndexPlotNeuro,1)
                        %  CommonNeuron(IndexPlotNeuro,IndexPlotWire)
    
                        ColorPlotIndex = ColorPlotIndex + 1;
                        if ( CommonWiring_sort(IndexPlotNeuro,IndexPlotWire) > 0)
                            figure(f1);
                            plot ( [ Neuron( CommonNeuron(IndexPlotNeuro,1) ).x, Neuron( CommonNeuron(IndexPlotNeuro, IndexPlotWire) ).x], [ Neuron( CommonNeuron(IndexPlotNeuro,1) ).y, Neuron( CommonNeuron(IndexPlotNeuro,IndexPlotWire) ).y] ,color_vec_str(ColorPlotIndex), 'linewidth', 2)
                            set(gcf,'Color','w');
                            hold on
                        end
    
                    end
                    pause(5)
    
                end
    
                % =============================================================
                % Debug mode II - Checking with the main WiringSublist that each neuron is taken into account
    
                for Read_WiringList = 1:length( WiringSortList(:,1) )
    
                    % WiringSortList(Read_WiringList,1);
                    % WiringSortList(Read_WiringList,2);
    
                    figure(f1);
                    plot ( [ Neuron( WiringSortList(Read_WiringList,1) ).x, Neuron( WiringSortList(Read_WiringList,2) ).x], [ Neuron( WiringSortList(Read_WiringList,1) ).y, Neuron( WiringSortList(Read_WiringList,2) ).y] ,'+g', 'MarkerSize',12, 'linewidth', 2)
                    set(gcf,'Color','w');
                    hold on
                end
    
    
            end
            % End of the debug mode
            % pause
        end
        % =============================================================
    
        % =============================================================
        % MANAGEMENT OF THE CONTROL
        % =============================================================
    
        % 1 - Pick up the wire# in the WiringList
        % 2 - Pick up the (both) active neurons in the WiringList
        % 3 - Which neuron to update (as a controlled neuron) -> Chech the priority : deduce the UpdatingNeuronIndex
        % 4 - Update the NeuronWeigthList (simply indexed by the
        % UpdatingNeuronIndex)
        % 5 - Update the CommonNeuron
        % 6 - Update the CommonWiring_sort / WiringWeigthList
        % 7 - Compute the product between weigth and neurons
        % 8 - Update the NeuronWeigthList with the computed product
        % 9 - Save statistics for propagation
    
    
        % 1/ Pick up the #wire in the WiringSortList (indexed by
        % 'Wiringlist_current')
        % -> Read the WiringSortList to sweep all possible connexions
    
        ActivatedWire = WiringSortList(Wiringlist_current,3);
    
        % =============================================================
    
        % Just to dispaly the switching signal for debug
        % if ( DisplaySwitchSignal == 1)
        %     %
        %     figure(f3);
        %     plot(switch_vec( 1:end , 2),'b', 'Linewidth', 3);
        %     hold on
        %     plot(50*switch_vec( 1:end , 1),'r', 'Linewidth', 3);
        %     %
        % end
    
        % Time computation
        time_ = Iteration_k * TimeStep;
    
        % Define a sine perturbation (to be used later)
        %  sin_vec_ = amp_sine_pert * sin( 2*pi*freq_sine_pert * time_ ) ;
    
        % =============================================================
        % PLOT THE CURRENT WIRING CONNEXION
    
        %A/ Reset of the connexions ( set 'w' to the plot)
    
        if ( cnt_period_activation == 0 )
    
            if ( GraphDisplay == 1 )
    
                for Read_WiringList = 1:length( WiringSortList(:,1) )
    
                    figure(f1);
                    plot ( [ Neuron( WiringSortList(Read_WiringList,1) ).x, Neuron( WiringSortList(Read_WiringList,2) ).x], [ Neuron( WiringSortList(Read_WiringList,1) ).y, Neuron( WiringSortList(Read_WiringList,2) ).y] ,'-w', 'linewidth', 2)
                    hold on
    
                    %B/ Plot the current connexion
                    figure(f1);
                    plot ( [ Neuron( WiringSortList(Wiringlist_current,1) ).x, Neuron( WiringSortList(Wiringlist_current,2) ).x], [ Neuron( WiringSortList(Wiringlist_current,1) ).y, Neuron( WiringSortList(Wiringlist_current,2) ).y] ,'--k', 'linewidth', 2)
                    hold on
    
                end
    
            end
    
            % 2/ Pick up the (both) active neurons in the WiringSortList
            ActiveNeurons = WiringSortList(Wiringlist_current, 1:2);
    
            % 3/ Which neuron to update -> Chech the priority : deduce the
            % UpdatingNeuronIndex
            if (Priority_sort(Wiringlist_current,1) > Priority_sort(Wiringlist_current,2))
    
                UpdatingNeuronIndex = WiringSortList(Wiringlist_current, 1);
                LowPriorityIndex = WiringSortList(Wiringlist_current, 2);
    
            else
    
                UpdatingNeuronIndex = WiringSortList(Wiringlist_current, 2);
                LowPriorityIndex = WiringSortList(Wiringlist_current, 1);
    
            end
    
            % The UpdatingNeuronIndex corresponds to the highest priority
            % => corresponds to the controlled neuron
            OutputControlledIndex = UpdatingNeuronIndex;
    
    
            % ======= SUMMARY DISPLAYED FOR NEURON & WIRE UPDATE
    
            if ( Verbose == 1)
    
                fprintf('\n * * * * * * * iteration #%d (nb wires = %d) * * * * * * * \n\n', Iteration_k, le_WiringSortList);
    
                % Check the group number
                UpdatingNeuronIndex_ = find( UpdatingNeuronIndex == ConnectedIDNeuron(1, : ) );
    
    
                fprintf('Neuron #%d (priority over #%d) associated to %d weigths with the target: %f and the wires: \n', UpdatingNeuronIndex, ...
                    LowPriorityIndex, NeuronWeigthList(3, UpdatingNeuronIndex), NeuronWeigthList(2, UpdatingNeuronIndex) );
    
    
                fprintf('\n-------> group %d - Ouput neuron #%d ( ref. = %f) <------- \n', ConnectedIDNeuron(3, Rank_ConnectedIDNeuron ), ConnectedIDNeuron(1, Rank_ConnectedIDNeuron), NeuronWeigthList(2,OutputControlledIndex)  );
    
                % This index is valid only for the 'CommonWiring_sort' matrix
                % to identify neuron -> not to be used in the 'NeuronWeigthList' matrix
    
                IndexActiveNeuron_Common = find ( UpdatingNeuronIndex == CommonWiring_sort(:,1,1) );
    
                fprintf('\n -------------- WIRES STATUS -------------- \n');
    
                for uuu = 1:length( CommonWiring_sort(:,1,1)  )
    
                    for uu = 2:length( CommonWiring_sort(uuu ,:,1) ) % sweep connected wires
    
                        if ( CommonWiring_sort(uuu,uu,1) > 0 )
    
                            for sweep_id = 1:length( WiringSortList( :,1 ) )
    
                                if ( WiringSortList( sweep_id, 3 ) == CommonWiring_sort(uuu, uu) )
    
                                    % Check if the UpdatingNeuronIndex corresponds to
                                    % the ActivatedWire (from uu = 2)
                                    if ( CommonWiring_sort(uuu,uu,1) == ActivatedWire )
    
                                        % !!!! NOTE: NeuronWeigthList(3+ CommonWiring_sort(IndexActiveNeuron_Common,uu,1), CommonWiring_sort(IndexActiveNeuron_Common,1,1)) is equivalent to NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)
                                        fprintf('[%d] -> [out. = %f -> verr. %d -- list-index wire #%d [wiring #%d] between : %d <=> %d]   \n', CommonWiring_sort(uuu,uu,1), ...
                                            WiringWeigthList(ActivatedWire), ...
                                            ControlFlagManagement(ActivatedWire),...
                                            sweep_id, ...
                                            WiringSortList(sweep_id,3), ...
                                            WiringSortList(sweep_id,1), ...
                                            WiringSortList(sweep_id,2));
    
    
                                        if ( write_file == 1)
                                            fprintf(fid, '[%d] -> [out. = %f -> list-index wire #%d [wiring #%d] between : %d <=> %d -- Ouput neuron #%d :: meas. = %f -  ref. = %f)]   \n', CommonWiring_sort(uuu,uu,1), ...
                                                WiringWeigthList(ActivatedWire), ...
                                                sweep_id, ...
                                                WiringSortList(sweep_id,3), ...
                                                WiringSortList(sweep_id,1), ...
                                                WiringSortList(sweep_id,2), ...
                                                ConnectedIDNeuron(1, Rank_ConnectedIDNeuron), ...
                                                NeuronWeigthList(1,OutputControlledIndex), ...
                                                NeuronWeigthList(2,OutputControlledIndex) );
                                            fprintf('print into file \n');
                                        end
    
                                    else
                                        fprintf('[%d] -> inactive  --  list-index wire #%d [wiring #%d] between : %d <=> %d] \n', ...
                                            CommonWiring_sort(uuu,uu,1), ...
                                            sweep_id, ...
                                            WiringSortList(sweep_id,3), ...
                                            WiringSortList(sweep_id,1), ...
                                            WiringSortList(sweep_id,2));
                                    end
    
                                end
    
                            end
    
    
                            % This is related to the wiring control - to be used
                            % later if a sub-control is needed for the wire.
                            % fprintf('[%d] -> ratio %f (weigthed at %f) -> [ref = %f - err = %f -> verr. %d]  *  \n', CommonWiring_sort(IndexActiveNeuron_Common,uu,1), ...
                            %                                                                                 NeuronWeigthList(3 + CommonWiring_sort(IndexActiveNeuron_Common,uu,1), CommonWiring_sort(IndexActiveNeuron_Common,1,1)), ...
                            %                                                                                 ((( NeuronWeigthList(2, UpdatingNeuronIndex)* NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  ))), ...
                            %                                                                                 ((( ( 1 / NeuronWeigthList( 2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex)* NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  )  ))), ...
                            %                                                                                 abs(OutputFeedback - ((( ( 1 / NeuronWeigthList( 2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex)* NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  )  )))), ...
                            %                                                                                 ControlFlagManagement(ActivatedWire) );
    
    
                        end
    
                    end
    
                end
    
                % Old version -> no more used!
                % for uu = 2:length( CommonWiring_sort(IndexActiveNeuron_Common,:,1) ) % sweep connected wires
                %     if ( CommonWiring_sort(IndexActiveNeuron_Common,uu,1) > 0 )
                %
                %         % This is related to the wiring control - to be used
                %         % later if a sub-control is needed for the wire.
                %         % fprintf('[%d] -> ratio %f (weigthed at %f) -> [ref = %f - err = %f -> verr. %d]  *  \n', CommonWiring_sort(IndexActiveNeuron_Common,uu,1), ...
                %         %                                                                                 NeuronWeigthList(3 + CommonWiring_sort(IndexActiveNeuron_Common,uu,1), CommonWiring_sort(IndexActiveNeuron_Common,1,1)), ...
                %         %                                                                                 ((( NeuronWeigthList(2, UpdatingNeuronIndex)* NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  ))), ...
                %         %                                                                                 ((( ( 1 / NeuronWeigthList( 2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex)* NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  )  ))), ...
                %         %                                                                                 abs(OutputFeedback - ((( ( 1 / NeuronWeigthList( 2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex)* NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  )  )))), ...
                %         %                                                                                 ControlFlagManagement(ActivatedWire) );
                %
                %         % Check if the UpdatingNeuronIndex corresponds to
                %         % the ActivatedWire (from uu = 2)
                %         if ( CommonWiring_sort(IndexActiveNeuron_Common,uu,1) == ActivatedWire )
                %
                %             % !!!! NOTE: NeuronWeigthList(3+ CommonWiring_sort(IndexActiveNeuron_Common,uu,1), CommonWiring_sort(IndexActiveNeuron_Common,1,1)) is equivalent to NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)
                %             fprintf('[%d] -> [out. = %f -> verr. %d]   \n', CommonWiring_sort(IndexActiveNeuron_Common,uu,1), ...
                %                 WiringWeigthList(ActivatedWire), ...
                %                 ControlFlagManagement(ActivatedWire) );
                %         else
                %             fprintf('[%d] -> inactive \n', CommonWiring_sort(IndexActiveNeuron_Common,uu,1) );
                %         end
                %
                %     end
                % end
    
                %  fprintf('Check the sum of the sub-weigths for the #%d neuron ID ', CommonWiring_sort(IndexActiveNeuron_Common,1,1) );
                if ( sum(NeuronWeigthList(4:end, CommonWiring_sort(IndexActiveNeuron_Common,1,1))) == 1 )
                    %  fprintf(' --> OK \n')
                else
                    fprintf('---> Problem  (sum = %f) !!!' , sum(NeuronWeigthList(4:end, CommonWiring_sort(IndexActiveNeuron_Common,1,1))))
                    pause
                end
    
                fprintf('\n -------------- NEURON STATUS -------------- \n');
    
                jj = 0;
                for ii = 1: (length( ListConnectedNeuron ) - UpdateInputNeuron)
    
                    jj = jj + 1;
                    fprintf('[%d : (ref = %f, meas = %f) -> err = %f] \n', ListConnectedNeuron(ii), NeuronWeigthList(2,ListConnectedNeuron(ii)),  NeuronWeigthList(1,ListConnectedNeuron(ii)), NeuronWeigthList(2,ListConnectedNeuron(ii)) - NeuronWeigthList(1,ListConnectedNeuron(ii)))
    
                end
    
                % ---------------------------------------
    
                if (verbose_pause == 1)
                    pause
                end
    
                % NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)
                % gives the targeted sub-weigth of each ActivatedWire
                % w.r.t. a particular #neuron (UpdatingNeuronIndex)
                % targeted at NeuronWeigthList(2, UpdatingNeuronIndex)
    
            else
    
                % DUPLICATION ONLY TO WRITE IN A FILE (optional)
    
                if ( write_file == 1 )
    
                    % fprintf('\n * * * * * * * iteration #%d (nb wires = %d) * * * * * * * \n\n', Iteration_k, le_WiringSortList);
    
                    % Check the group number
                    UpdatingNeuronIndex_ = find( UpdatingNeuronIndex == ConnectedIDNeuron(1, : ) );
    
                    IndexActiveNeuron_Common = find ( UpdatingNeuronIndex == CommonWiring_sort(:,1,1) );
    
                    for uuu = 1:length( CommonWiring_sort(:,1,1)  )
    
                        for uu = 2:length( CommonWiring_sort(uuu ,:,1) ) % sweep connected wires
    
                            if ( CommonWiring_sort(uuu,uu,1) > 0 )
    
                                for sweep_id = 1:length( WiringSortList( :,1 ) )
    
                                    if ( WiringSortList( sweep_id, 3 ) == CommonWiring_sort(uuu, uu) )
    
                                        % Check if the UpdatingNeuronIndex corresponds to
                                        % the ActivatedWire (from uu = 2)
                                        if ( CommonWiring_sort(uuu,uu,1) == ActivatedWire )
    
                                            if ( write_file == 1)
                                                fprintf(fid, '[%d] -> [out. = %f -> list-index wire #%d [wiring #%d] between : %d <=> %d -- Ouput neuron #%d :: meas. = %f -  ref. = %f)]   \n', CommonWiring_sort(uuu,uu,1), ...
                                                    WiringWeigthList(ActivatedWire), ...
                                                    sweep_id, ...
                                                    WiringSortList(sweep_id,3), ...
                                                    WiringSortList(sweep_id,1), ...
                                                    WiringSortList(sweep_id,2), ...
                                                    ConnectedIDNeuron(1, Rank_ConnectedIDNeuron), ...
                                                    NeuronWeigthList(1,OutputControlledIndex), ...
                                                    NeuronWeigthList(2,OutputControlledIndex) );
                                                % fprintf('print into file \n');
                                            end
    
                                        end
    
                                    end
    
                                end
    
                            end
    
                        end
    
                    end
    
                end
    
            end
    
        end
        % End of the of 'cnt_period_activation'
    
    
        %  if ( EnableControl == 1)
        
        if delay_start_EN(ActivatedWire) == 0
            delay_start(ActivatedWire) = ii;
            delay_start_EN(ActivatedWire) = 1;
        end
    
        % =============================
    
        % NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)
        % gives the targeted sub-weigth of each ActivatedWire
        % w.r.t. the associated #neuron (UpdatingNeuronIndex)
        % targeted at NeuronWeigthList(2, UpdatingNeuronIndex)
        % Hence, the TRUE targeted sub-weigth is the ratio between
        % the targeted sub-weigth and the LowPriorityIndex neuron
        % weigth.
    
        % This is related to the wiring control - to be used
        % later if a sub-control is needed for the wire.
        %
        % VALIDATION first of the true targeted sub-weigth (otherwise
        % abort the program !)
        % if (  ( 1 / NeuronWeigthList( 2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex) * NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  ) == PreRef )
        %
        %     fprintf('===== Problem with the Control Initialization - Abort !');
        %     break
        %
        % end
    
        % CONTROL OF WIRES - to be checked later
        % This is related to the wiring control - to be used
        % later if a sub-control is needed for the wire.
        %
        % Check when the controlled sub-weigth passes the threshold
        % swith from high speed control parameter to low speed control
        % parameters
    
        % if ( abs( OutputFeedback - ((( ( 1 / NeuronWeigthList(2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex)*NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  )  )))  ) <= InternalControlParamSwitchThreshold || ...
        %         (ControlParamHold == 1 && ControlFlagManagement(ActivatedWire) == 1 ) )
    
    
        PMC_Kp(ActivatedWire) = aa_1;
        PMC_Kint(ActivatedWire) = bb_1;
        PMC_K_alpha(ActivatedWire) = PMC_K_alpha_1;
        PMC_K_beta(ActivatedWire) = PMC_K_beta_1;
        PMC_FinalScale(ActivatedWire) = PMC_FinalScale_1;
    
        % * * * * * * * * * NOT USED IN THIS BETA VERSION -> see later how to change online dynamics of the control * * * * * * * * *
        %
        %  if ( ControlFlagManagement(ActivatedWire) == 0 )
        % %
        % %
        % %     if ( abs( OutputFeedback - NeuronWeigthList(2, OutputControlledIndex) ) <= InternalControlParamSwitchThreshold || ...
        % %             (ControlParamHold == 1 && ControlFlagManagement(ActivatedWire) == 1 ) )
        % %
        % %
        % %         % Kp_stab = 1e-2; %1e-2;
        % %         % Ki_stab = 100; %1e-2;
        % %         %
        % %         %             PMC_Kp(ActivatedWire) = 0.1 * Kp_stab;
        % %         %             PMC_Kint(ActivatedWire) = 0.1 * Ki_stab;
        % %         %             PMC_K_alpha(ActivatedWire) = 1e2;
        % %         %             PMC_K_beta(ActivatedWire) = 10;
        % %         %             PMC_FinalScale(ActivatedWire) = 1e5;
        % %
        % %
        % %         PMC_Kp(ActivatedWire) = aa_5;
        % %         PMC_Kint(ActivatedWire) = bb_5;
        % %         PMC_K_alpha(ActivatedWire) = PMC_K_alpha_1;
        % %         PMC_K_beta(ActivatedWire) = PMC_K_beta_1;
        % %         PMC_FinalScale(ActivatedWire) = PMC_FinalScale_1;
        % %
        % %         ControlFlagManagement(ActivatedWire) = 1;
        % %
        % %     else
        % %
        % %         PMC_Kp(ActivatedWire) = PMC_Kp_2;
        % %         PMC_Kint(ActivatedWire) = PMC_Kint_2;
        % %         PMC_K_alpha(ActivatedWire) = PMC_K_alpha_2;
        % %         PMC_K_beta(ActivatedWire) = PMC_K_beta_2;
        % %         PMC_FinalScale(ActivatedWire) = PMC_FinalScale_2;
        % %
        % %     end
        %
        % else
        %
        %
        %     % if ( Iteration_k >= 2500 )
        %     %
        %     %     PMC_Kp(ActivatedWire) = PMC_Kp_3;
        %     %     PMC_Kint(ActivatedWire) = PMC_Kint_3;
        %     %    PMC_K_alpha(ActivatedWire) = PMC_K_alpha_3;
        %     %    PMC_K_beta(ActivatedWire) = PMC_K_beta_3;
        %     %    PMC_FinalScale(ActivatedWire) = PMC_FinalScale_3;
        %     %
        %     % end
        %
        % end
    
    
    
        % Using a struct to map the control throughout the connexions takes too much time especially in separate files! -> maybe for future releases ;)
    
        if (ii_1(ActivatedWire) > delay_start(ActivatedWire) )
    
            ii_1(ActivatedWire) = ii_1(ActivatedWire) + 1;
    
        end
    
        % 4/ Update the NeuronWeigthList
        % -> done direclty inside the control
    
        if (Iteration_k >= delay_start(ActivatedWire) )
    
            % ActivatedWire_vec(ii) = ActivatedWire;
    
            y_int(ActivatedWire) =  PMC_K_alpha(ActivatedWire) * exp( - PMC_K_beta(ActivatedWire)  *  ii_1(ActivatedWire) * TimeStep  );
    
            % fprintf('\n #1');
    
            % In these two lines, the REFERENCE is given by NeuronWeigthList(2,UpdatingNeuronIndex) and the MEASURE is given by NeuronWeigthList(1,UpdatingNeuronIndex).
            % NeuronWeigthList should centralize every weights of the full network.
    
            % !!!! NeuronWeigthList(1, CommonNeuron(row, 1 ) ) is updated with Prod(row) in section 8/ !!!!
            % !!!! NeuronWeigthList(1, OutputControlledIndex) is read to provide the feedback measure !!!!
            % !!!! NeuronWeigthList(2, OutputControlledIndex) provides the tracking reference !!!!
    
            OutputFeedback = NeuronWeigthList(1,OutputControlledIndex); %WiringWeigthList(ActivatedWire); %NeuronWeigthList(1,UpdatingNeuronIndex);  %
            % fprintf('\n #2');
    
            para_exp_err(ActivatedWire) = y_int(ActivatedWire) - OutputFeedback;
            % fprintf('\n #3');
    
            % Used for the control of the wires - to be investigated for neurons propagation:
            % para_stand_err1(ActivatedWire) = ((( ( 1 / NeuronWeigthList( 2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex) * NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  )  ))) - OutputFeedback;
    
            para_stand_err1(ActivatedWire) =  NeuronWeigthList(2, OutputControlledIndex) - OutputFeedback;
    
            para_u1(ActivatedWire) = para_u1(ActivatedWire) + PMC_Kp(ActivatedWire) * para_exp_err(ActivatedWire);
            % fprintf('\n #5');
    
            para_G1_1(ActivatedWire) = para_G1(ActivatedWire);
            % fprintf('\n #6');
    
            para_G1(ActivatedWire) = PMC_Kint(ActivatedWire)*para_stand_err1(ActivatedWire);
            % fprintf('\n #7');
    
            para_trapz1(ActivatedWire) = para_trapz1(ActivatedWire) + TimeStep*(para_G1_1(ActivatedWire) + para_G1(ActivatedWire) )/2;
            % fprintf('\n #8');
    
            para_u_final1(ActivatedWire) = para_u1(ActivatedWire)*para_trapz1(ActivatedWire)/PMC_FinalScale(ActivatedWire);
            % fprintf('\n #9');
    
            ActivatedWireSystem = ActivatedWire;
    
            %   para_u_final1_vec(ActivatedWireSystem, ii ) = para_u_final1(ActivatedWireSystem);
    
            y_RK( ActivatedWireSystem ) = (1 + TimeStep*A)*y_RK( ActivatedWireSystem ) + TimeStep * B*para_u_final1(ActivatedWireSystem);
            % fprintf('\n #10');
    
            % This part is kept but should no be more used in
            % future versions: allows damping the evolution of the
            % controlled weigths through a factor that increases
            % slowly
            %
            % if ( ActivatedWire ~= 32 && ActivatedWire ~= 33 && ActivatedWire ~= 32 &&  ActivatedWire ~= 54 && ActivatedWire ~= 55 )
            %
            %     if W_damping( ActivatedWire ) <= 1
            %     W_damping( ActivatedWire ) = W_damping( ActivatedWire ) + 1e-2;
            %     else
            %         W_damping( ActivatedWire ) = 1;
            %     end
            %
            % else
            %
            %     W_damping( ActivatedWire ) = 1;
            % end
            %
            % fprintf("ActivatedWire = %d, W_damping( ActivatedWire ) = %f", ActivatedWire, W_damping( ActivatedWire ))
    
            WiringWeigthList(ActivatedWire) =  y_RK( ActivatedWireSystem );  % -0.1 * sin( 2*pi*freq * time_ ) ;
    
    
            % ---------------------------------------------------
            % Proposed neuron sequence growing : 3  5	9  4  8  10	 7	2	6	1	0
            % ---------------------------------------------------
    
            % 3   -10    11    12     0     0
            % 4   -10    11    12     0     0
            % 5   -10    11    12     0     0
            % 8   -10    11    12     0     0
            % 10    3     4     5     8     9
            % 9   -10    11    12     0     0
            %
            %
            %
            % 3   -31    32    33  -555  -555
            % 4   -42    43    44  -555  -555
            % 5   -53    54    55  -555  -555
            % 8   -86    87    88  -555  -555
            % 10   31    42    53    86    97 -> the #10 connects all neurons
            % 9   -97    98    99  -555  -555
    
    
            % =============================================================================
            %  SAVE DATA IN VECTORS
    
            if ( Verbose == 0 )
                OutputFeedback_vec(1, Iteration_k+1) = NeuronWeigthList(1, 3);
                y_ref_vec(1,Iteration_k+1) = NeuronWeigthList(2, 3);
                Wiring_vec(1,Iteration_k+1) = y_RK( 32 );
                Wiring_vec(2,Iteration_k+1) = y_RK( 33 );
                %
                OutputFeedback_vec(2, Iteration_k+1) = NeuronWeigthList(1, 5);
                y_ref_vec(2,Iteration_k+1) = NeuronWeigthList(2, 5);
                Wiring_vec(3,Iteration_k+1) = y_RK( 54 );
                Wiring_vec(4,Iteration_k+1) = y_RK( 55 );
                %
                OutputFeedback_vec(3, Iteration_k+1) = NeuronWeigthList(1, 9);
                y_ref_vec(3,Iteration_k+1) = NeuronWeigthList(2, 9);
                Wiring_vec(5,Iteration_k+1) = y_RK( 98 );
                Wiring_vec(6,Iteration_k+1) = y_RK( 99 );
                %
                OutputFeedback_vec(4, Iteration_k+1) = NeuronWeigthList(1, 4);
                y_ref_vec(4,Iteration_k+1) = NeuronWeigthList(2, 4);
                Wiring_vec(7,Iteration_k+1) = y_RK( 43 );
                Wiring_vec(8,Iteration_k+1) = y_RK( 44 );
                %
                OutputFeedback_vec(5, Iteration_k+1) = NeuronWeigthList(1, 8);
                y_ref_vec(5,Iteration_k+1) = NeuronWeigthList(2, 8);
                Wiring_vec(9,Iteration_k+1) = y_RK( 87 );
                Wiring_vec(10,Iteration_k+1) = y_RK( 88 );
                %
                OutputFeedback_vec(6, Iteration_k+1) = NeuronWeigthList(1, 10);
                y_ref_vec(6,Iteration_k+1) = NeuronWeigthList(2, 10);
                Wiring_vec(11,Iteration_k+1) = y_RK( 31 );
                Wiring_vec(12,Iteration_k+1) = y_RK( 42 );
                Wiring_vec(13,Iteration_k+1) = y_RK( 53 );
                Wiring_vec(14,Iteration_k+1) = y_RK( 86 );
                Wiring_vec(15,Iteration_k+1) = y_RK( 97 );
            end
    
    
            if (Verbose == 0 & LearningEnable == 1)
                OutputFeedback_vec(7, Iteration_k+1) =  Training_epoch_1;
                OutputFeedback_vec(8, Iteration_k+1) =  Training_epoch_2;
                OutputFeedback_vec(9, Iteration_k+1) =  Training_epoch_output;
            end
    
            %y_ref_vec(Iteration_k+1) = ((( ( 1 / NeuronWeigthList( 2, LowPriorityIndex ) ) * ( NeuronWeigthList(2, UpdatingNeuronIndex)* NeuronWeigthList(3+ ActivatedWire, UpdatingNeuronIndex)  )  )));
    
    
            % % =============================================================================
    
            % debug only - display of all internal variables at each
            % interation
            %
            % fprintf("---------------- PRINT FOR CONTROL DEBUG ------------ \n")
            %
            %                     Iteration_k
            %
            %                     ActivatedWire
            %
            %                     y_int(ActivatedWire)
            %
            %                     OutputFeedback
            %
            %                     para_exp_err(ActivatedWire)
            %                     para_stand_err1(ActivatedWire)
            %
            %                     para_u1(ActivatedWire)
            %                     PMC_Kp(ActivatedWire)
            %                     para_exp_err(ActivatedWire);
            %
            %                     para_G1_1(ActivatedWire)
            %                     para_G1(ActivatedWire);
            %                     PMC_Kint(ActivatedWire)
            %                     para_stand_err1(ActivatedWire);
            %
            %                     para_trapz1(ActivatedWire)
            %                     para_G1_1(ActivatedWire)
            %                     para_G1(ActivatedWire)
            %
            %                     para_u_final1(ActivatedWire)
            %                     para_u1(ActivatedWire)
            %                     para_trapz1(ActivatedWire)
            %                     PMC_FinalScale(ActivatedWire);
            %
            %                     ActivatedWireSystem
            %                     ActivatedWire;
            %
            %                     y_RK( ActivatedWireSystem )
            %                     para_u_final1(ActivatedWireSystem);
            %
            %                     WiringWeigthList(ActivatedWire)
            %
            %
            % fprintf("-----------------------------------------");
            %
            % pause
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        end
      
        % 5/ Update the CommonNeuron -> for each neuron available from the
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
    
    
        % % % % 6b / Update the CommonWiring_sort by excluding the negative
        % % % % wires EXCEPT THE CURRENT WIRES
        % % %
        % % % for id_u = 1:length( CommonWiring_sort(:,1,1) )
        % % %
        % % %     for ppp = 1:length( CommonWiring_sort(1,:,1) )
        % % %
        % % %         for ssd = 1:length( NodeExcludeControl )
        % % %
        % % %             if ( CommonNeuron(id_u,1,1) ~= NodeExcludeControl(ssd) & CommonNeuron(id_u,ppp,1) == NodeExcludeControl(ssd) )
        % % %
        % % %                 CommonWiring_sort(id_u,ppp,1) = -CommonWiring_sort(id_u,ppp,1);
        % % %                 CommonNeuron(id_u,ppp,1) = -CommonNeuron(id_u,ppp,1);
        % % %
        % % %             end
        % % %
        % % %         end
        % % %
        % % %     end
        % % %
        % % % end
        % % % % correcting the current node - remove negative (-) sign
        % % % if ( length( NodeExcludeControl ) > 2)
        % % %
        % % %     IndexLastConnectedID = find( CommonNeuron(:,:,1) == NodeExcludeControl(end) );
        % % %
        % % %     CommonNeuron( IndexLastConnectedID ,:,1) = abs( CommonNeuron( IndexLastConnectedID ,:,1) );
        % % %     CommonWiring_sort( IndexLastConnectedID ,:,1) = abs( CommonWiring_sort( IndexLastConnectedID ,:,1) );
        % % %
        % % % end
        % % %
    
        % 6c / Finaly removing the negative wires AND count active
        % neurons
    
        CommonWiring_sort_backup = CommonWiring_sort;
    
        % ========================================================
        %     PREPARATION OF THE NEURON MULTI-DATA / INCOMPLETE
        %       and limited to fwd propagation of the control
        % ========================================================
    
        % only a single data for the neuron for the moment
        % will be extended in future versions
    
        for id_u = 1:length( CommonWiring_sort(:,1,1) )
    
            Count_positive_neuron = 0;
            Count_zero_neuron = 0;
            for ppp = 1:length( CommonWiring_sort(1,:,1) )
    
                % If a neuron is negative (-)
                if ( CommonWiring_sort(id_u,ppp,1) < 0)
    
                    % CommonWiring_sort_positive is used only to display
                    % CommonWiring_sort_positive(id_u,ppp,2) = 0;
                    CommonWiring_sort(id_u,ppp,2) = 0;
                    %  CommonWiring_sort(id_u,ppp,3) = 0;
                    %  CommonWiring_sort(id_u,ppp,4) = 0;
    
                    % If a neuron is negative (-) AND (> -100), then count it as 'Count_zero_neuron'
                    % if ( ppp >= 2 & CommonWiring_sort(id_u,ppp,1) > -100 )
                    %
                    %     Count_zero_neuron = Count_zero_neuron + 1;
                    % end
    
                else
    
                    %   CommonWiring_sort(id_u,ppp,3) = CommonWiring_sort(id_u,ppp,2);
                    %   CommonWiring_sort(id_u,ppp,4) = CommonWiring_sort(id_u,ppp,2);
    
                    % if ( ppp >= 2 )
                    %
                    %     Count_positive_neuron = Count_positive_neuron + 1;
                    %
                    % end
    
                end
    
            end
    
            % Theoretically : NeuronWeigthList(3, CommonWiring_sort(id_u, 1, 1) ) == ( Count_positive_neuron + Count_zero_neuron )
            %fprintf('neuron #%d -> expected nb of neurons : %d - pos. neurons : %d - zero neurons : %d \n', CommonWiring_sort(id_u, 1, 1), NeuronWeigthList(3, CommonWiring_sort(id_u, 1, 1) ), Count_positive_neuron, Count_zero_neuron);
    
            %CommonWiring_sort(id_u, 1, 2) = Count_positive_neuron;
    
        end
    
    
        % 6d / To be developed later - moving wiring during
        % learning phase
    
        % for id_u = 1:length( CommonWiring_sort(:,1,1) )
        %
        %     Count_positive_neuron = 0;
        %     for ppp = 2:length( CommonWiring_sort(1,:,1) )
        %
        %         if ( CommonWiring_sort(id_u, ppp, 2) > 0 & Count_positive_neuron < floor(CommonWiring_sort(id_u, 1, 2) / 2) )
        %          CommonWiring_sort(id_u,ppp,3) = -2;
        %          Count_positive_neuron = Count_positive_neuron + 1;
        %         else
        %          CommonWiring_sort(id_u,ppp,3) = 3;
        %         end
        %
        %     end
        %
        % end
    
    
        % 7 / Compute the product between weigth and neurons
        for row = 1:length( CommonNeuron(:,1,1) )
    
            le_CommonNeuron = length( CommonNeuron(1,:,1) );
            Prod(row) = CommonNeuron(row, 2:le_CommonNeuron, 2 ) * CommonWiring_sort(row, 2:le_CommonNeuron, 2 )';
            CommonNeuron(row, 1, 2) = Prod(row); % set new measures to the CommonNeuron(:,1,2)
    
            % for test purpose : 24 * CommonNeuron(row, 1 );
            Stat(1,row) = mean( CommonWiring_sort(row, 2:le_CommonNeuron, 2 ));
    
            % for test purpose : 72 * CommonNeuron(row, 1 );
            Stat(2,row) = std( CommonWiring_sort(row, 2:le_CommonNeuron, 2 ));
            %   CommonWiring_sort(row, 1, 2) = Prod(row); % duplicate to CommonWiring_sort(:,1,2)
    
        end
    
        % for test purpose for the statistics
    
        %   3    4    5    8    10    9
        %
        % NeuronStatList =
        %
        %   Columns 1 through 7
        %
        %            0           0         300         400         500           0           0
        %            0           0         450         600         750           0           0
        %
        %   Columns 8 through 13
        %
        %          800         900        1000           0           0           0
        %         1200       -1200        1500           0           0           0
    
    
        % CommonNeuron
        %
        % CommonWiring_sort
        %
        % Prod
    
        % 8 / Update the NeuronWeigthList with the computed product
    
        for row = 1:length( CommonNeuron(:,1) )
    
            % For a particular neuron 'x':
    
            % index (1,x) refers to the 'measured / controlled' value
            % index (2,x) refers to the targeted value
            % index (3,x) refers to the nb of connexions associated to 'x'
            % index (>3,x) list all sub-targeted weigths (that amis to help
            % converging the control)
    
            % Set new measures from the control to the index NeuronWeigthList(1,:)
            % the references NeuronWeigthList(2,:) are not modified at this point!!
            NeuronWeigthList(1, CommonNeuron(row, 1 ) ) = Prod(row);
            NeuronStatList(1, CommonNeuron(row, 1 ) ) = Stat(1,row);
            NeuronStatList(2, CommonNeuron(row, 1 ) ) = Stat(2,row);
        end
    
        % 9 / Save statistics for propagation
        NeuronStatList_1 = 0;
        NeuronStatList_2 = 0;
        if ( newConnectedID == 10)
    
            for row = 1:length( CommonNeuron(:,1) )
    
                if ( CommonNeuron(row, 1 ) ~= newConnectedID )
    
                    NeuronStatList_1 = NeuronStatList_1 + NeuronStatList(1, CommonNeuron(row, 1 ) );
                    NeuronStatList_2 = NeuronStatList_2 + NeuronStatList(2, CommonNeuron(row, 1 ) );
    
                end
    
            end
    
            NeuronStatList(1, newConnectedID ) = NeuronStatList_1;
            NeuronStatList(2, newConnectedID ) = NeuronStatList_2;
    
            StatFeedback_vec(1, Iteration_k+1) = NeuronStatList(1, newConnectedID );
            StatFeedback_vec(2, Iteration_k+1) = NeuronStatList(2, newConnectedID );
        end
    
    
    
        %------------------------------------------
        %   SUMMARY
        %
        % CommonNeuron is split into:
        % '1'-index: last neurons with the list of connected neurons
        % '2'-index: weigths of the connected neurons (result of the
        % Prod computation in the first col.)
    
        % CommonWiring_sort is split into:
        % '1'-index: last neurons with list of connected wires
        % '2'-index: controlled wires (driven by the PMC), whose
        % weigthed sum is equal to the Prod.
    
        % ********************
        % CommonNeuron(:,:,1) =
        %
        %      3    11    12
        %      5    11    12
        %
        %
        % CommonNeuron(:,:,2) =
        %
        %     0.8999    4.0000    5.0000
        %     0.8999    4.0000    5.0000
        %
        %
        % CommonWiring_sort(:,:,1) =
        %
        %      3    32    33
        %      5    54    55
        %
        %
        % CommonWiring_sort(:,:,2) =
        %
        %     0.8999    0.1000    0.1000
        %     0.8999    0.1000    0.1000
    
        % END /
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    CommonNeuron
        %
        %    CommonWiring_sort
        %
        % %   NeuronWeigthList
        % %
        % % %   WiringWeigthList(1:40)
        % %
        % %    Prod
        % %
        %     pause
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % ==============================================================================================================
        % ==============================================================================================================
        %
        %           * * * * * * Prepare data for online plotting (if 'GraphDisplay' == 1) * * * * * *
        %
        % It is expected to be a windowed plot, i.e. re-cycling plotting vector like a scope, in order to avoid too much 
        % data to store.
        % this is not necessary for this beta version since few data are
        % involved for the demo
    
        if ( GraphDisplay == 1 )

            margin_le_plot_f2 = 10;

          % the iteration should be dependant on the vector that are
          % being plotted to avoid loosing data -> to be improved later
          %  ii = ii + 1;
        
        
            % Assign the controlled 'WiringWeigthList' as output feedback for plotting
            for tt = 1:MaxWires
        
                if (ii >= (index_in_vec(tt)) * length_seg && ii <= (index_in_vec(tt)+1) *length_seg)
        
                    internal_cnt(tt) = internal_cnt(tt) + 1;
        
                    yy_signal_int1(tt,internal_cnt(tt)) = WiringWeigthList(tt);
        
                    if (y_sampled_in_vec(tt,1) == 0 )
                        y_sampled_out(tt,1:length( [  yy_signal_int1(tt,1:internal_cnt) ] )) = [  yy_signal_int1(tt,1:internal_cnt) ]; % length_seg+
        
                    else
                        y_sampled_out(tt,1:length( [ y_sampled_in_vec(tt,:), yy_signal_int1(tt,1:internal_cnt) ] )) = [ y_sampled_in_vec(tt,:), yy_signal_int1(tt,1:internal_cnt) ]; % length_seg+
                    end
        
                    if ii == ( (index_in_vec(tt) + 1) * length_seg )
        
                        internal_cnt(tt) = 0;
                        index_in_vec(tt) = index_in_vec(tt) + 1;
        
                        y_sampled_in_vec(tt, 1:length( downsample( y_sampled_out(tt,2:end), 10 ) )) = downsample( y_sampled_out(tt,2:end), 10 );
        
                    end
        
                end
        
            end
        
            le_y_sampled_out = length( y_sampled_out ) - margin_le_plot_f2;
        
            % Assign the controlled 'NeuronWeigthList' as output feedback for plotting
            for tt = 1:length( NeuronWeigthList(1,:) )
        
                if (ii >= (index_in_vec_(tt)) * length_seg && ii <= (index_in_vec_(tt)+1) *length_seg)
        
                    internal_cnt_(tt) = internal_cnt_(tt) + 1;
        
                    yy_signal_int1_(tt,internal_cnt_(tt)) = NeuronWeigthList(1, tt); % Carefull here: that's the measure of the neruno weigth that is plotted
        
                    if (y_sampled_in_vec_(tt,1) == 0 )
                        y_sampled_out_(tt,1:length( [  yy_signal_int1_(tt,1:internal_cnt_) ] )) = [  yy_signal_int1_(tt,1:internal_cnt_) ]; % length_seg+
                    else
                        y_sampled_out_(tt,1:length( [ y_sampled_in_vec_(tt,:), yy_signal_int1_(tt,1:internal_cnt_) ] )) = [ y_sampled_in_vec_(tt,:), yy_signal_int1_(tt,1:internal_cnt_) ]; % length_seg+
                    end
        
                    if ii == ( (index_in_vec_(tt) + 1) * length_seg )
        
                        internal_cnt_(tt) = 0;
                        index_in_vec_(tt) = index_in_vec_(tt) + 1;
        
                        y_sampled_in_vec_(tt, 1:length( downsample( y_sampled_out_(tt,2:end), 10 ) )) = downsample( y_sampled_out_(tt,2:end), 10 );
        
                    end
        
                end
        
            end
        
            le_y_sampled_out_ = length( y_sampled_out_ ) - margin_le_plot_f2;
        
        
            % Simply to be more confortable to use in the plot: Separate Neuron from the associated wires

            % #neuron and #wiring are captured in order to prepare the
            % legends of the plots
        
            % Example :
            %CommonWiring_sort(:,:,1) =
        
            %    3    32    33
            %    5    54    55
        
            for id_plot_com_wiring = 1:length( CommonWiring_sort(:,1,1) )
        
                NeuronPlotIndex(id_plot_com_wiring) = CommonWiring_sort(id_plot_com_wiring,1,1);
        
                ttt = 1;
                for (tt = 2 : length( CommonWiring_sort(id_plot_com_wiring,:,1) ) )
        
                    if ( CommonWiring_sort(id_plot_com_wiring,tt,1) > 0 )
                        WirePlotIndex(id_plot_com_wiring,ttt) = CommonWiring_sort(id_plot_com_wiring,tt,1);
        
                        ttt = ttt + 1;
                    end
                end
        
                % legend of the neuron plot
                legend_Neuron{id_plot_com_wiring} = sprintf('''%d''', NeuronPlotIndex(id_plot_com_wiring) );
        
                % integer version of the legend - to be used for the
                % reference
                legend_Neuron_(id_plot_com_wiring) = NeuronPlotIndex(id_plot_com_wiring);
        
                for (kk = 1:length(WirePlotIndex(id_plot_com_wiring,:))  )
        
                    % legend of the wire plot
                    legend_Wire{id_plot_com_wiring,kk} = sprintf('''%d''', WirePlotIndex(id_plot_com_wiring,kk));
        
                end
        
            end
        
            id_plot_com_wiring = 1;
        
            % plot only during wiring activation
            if ( cnt_period_activation == 0 && Iteration_k >= 2)
        
                if ( EnableSweepingConnexion == 0 & OnlineDebugPlot == 1)
        
                    % =============================================================================
                    % For debug only -> check simply if a double wire between two neurons works
                    %
                    %   if ( Iteration_k >= InstantNeuronGrowing)
        
                    %       figure(f2)
                    %       subplot(2,1,1)
                    %       hold on
                    %       plot(y_sampled_out_(3,:), 'b', 'linewidth', 2 )
                    %       plot(y_sampled_out_(9,:), 'r', 'linewidth', 2 )
                    %
                    %       subplot(2,1,2)
                    %       hold on
                    %       plot(y_sampled_out(32,:), 'b', 'linewidth', 2 )
                    %       plot(y_sampled_out(30,:), 'r', 'linewidth', 2 )
        
                    %       if ( Iteration_k >= InstantNeuronGrowing)
                    %       pause
                    %       end
        
                    %   end
                    % =============================================================================
        
                end
        
        
                %=========================================
                %
                %    PLOT SECTION of the controlled wires / neurons
        
                % Could be simplified ! ! !
                if ( length( CommonWiring_sort(:,1,1)) == 2 )
                    matplot = 2;
                end
        
                if ( length( CommonWiring_sort(:,1,1)) == 3 )
                    matplot = 3;
                end
        
                if ( length( CommonWiring_sort(:,1,1)) == 4 )
                    matplot = 4;
                end
        
                figure(f2)
        
                % Create the string to evaluate the wires plot ->
                % subplot 2 of figure f2
                string_plot_wiring = [];
        
                string_plot_wiring = [string_plot_wiring,'plot('];
        
                for uuu = 1:length( WirePlotIndex(id_plot_com_wiring,:) )
                    if ( WirePlotIndex(id_plot_com_wiring,uuu) > 0 )
                        string_plot_wiring = [string_plot_wiring, sprintf('1:le_y_sampled_out, y_sampled_out(WirePlotIndex(id_plot_com_wiring,%d),1:le_y_sampled_out), color_vec_str(%d), ',uuu,uuu)];  
                    end
        
                    if ( uuu == length( WirePlotIndex(id_plot_com_wiring,:) ) )
                        string_plot_wiring = [string_plot_wiring, ' ''linewidth'', 2)'];
                    end
                end
        
                ttt = 1;
                while ttt <= ( 2 * matplot )
        
                    %  if ( length( CommonWiring_sort(:,1,1)) >= 2 )
        
                    subplot(matplot,2,ttt)
                    %  hold on
                    plot(1:le_y_sampled_out_, y_sampled_out_(NeuronPlotIndex(id_plot_com_wiring),1:le_y_sampled_out_), 'b', 'linewidth', 2 )
                    hold on
                    % Plot the controlled neuron
                    if ( OutputControlledIndex == legend_Neuron_(id_plot_com_wiring) )
                        plot(1:le_y_sampled_out_, NeuronWeigthList(2, OutputControlledIndex) * ones(1,le_y_sampled_out_), 'm--', 'linewidth', 2 )
                    end
                    legend( legend_Neuron{id_plot_com_wiring} );
        
                    ttt = ttt + 1;
                    subplot(matplot,2,ttt)
                    eval( string_plot_wiring );
                    legend( legend_Wire{id_plot_com_wiring,:} );
                    set(gcf,'Color','w');
    
                    id_plot_com_wiring = id_plot_com_wiring + 1;
        
                    ttt = ttt + 1;
                    %  end
        
                end
    
                if ( Iteration_k == 102)
                    fprintf('\n\n Press a key to continue (only this iteration)... \n')
                pause
                end
        
            end

        end
    
    
        % end
    
        % fprintf('--------- Debug mode ---------')
        % pause
        % fprintf('------------------------------')
    
        % End of the control section
    
        if ( (100 * Iteration_k / MaxIterations)  >= 10 * pourcent_id )
    
            pourcent_id = pourcent_id + 1;
    
            fprintf('\n %d %% completed \n', floor(100 * Iteration_k / MaxIterations ));
    
            pause(0.1)
    
        end


    end

        %    End of online plotting (if 'GraphDisplay' == 1)

        % ==============================================================================================================
        % ==============================================================================================================
    
    
    close all

    if ( write_file == 1)
    fclose(fid);
    end
    
    if (Verbose == 0)
        NeuronPropagationPlot;
    end
    
    fprintf("End of the program! \n")
    
    toc