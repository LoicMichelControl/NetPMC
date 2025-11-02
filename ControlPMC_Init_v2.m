    
   
    
 %   MaxWires = 100;

    fprintf('Starting initialization of all controllers... ')
    
    for PreIndex = 1:MaxWires

    %    PreIndex
    
        OutputFeedback = 0;
    
        ii = 0;
        while (ii <= InitControlMaxIter )
    
            ii = ii + 1;
    
            if ( OutputFeedback >=  0.99*PreRef || ControlFlagManagement(PreIndex) == 1 )
    
                % PMC_Kp(PreIndex) = 1e-1;
                % PMC_Kint(PreIndex) = 100;
                % PMC_K_alpha(PreIndex) = 1e2;
                % PMC_K_beta(PreIndex) = 10;
                % PMC_FinalScale(PreIndex) = 1e5;

                 PMC_Kp(PreIndex) = aa_1; %1e-3;
                PMC_Kint(PreIndex) = bb_1; %1e-3;
                PMC_K_alpha(PreIndex) = 1e2;
                PMC_K_beta(PreIndex) = 10;
                PMC_FinalScale(PreIndex) = 1e5;
    
                ControlFlagManagement(PreIndex) = 1;
            else
    
                PMC_Kp(PreIndex) = 10;
                PMC_Kint(PreIndex) = 10;
                PMC_K_alpha(PreIndex) = 1e4;
                PMC_K_beta(PreIndex) = 10;
                PMC_FinalScale(PreIndex) = 1e+03;
    
            end
    
            y_int(PreIndex) =  PMC_K_alpha(PreIndex) * exp( - PMC_K_beta(PreIndex)  *  ii * TimeStep  );
    
            % In these two lines, the REFENCE is given by NeuronWeigthList(2,UpdatingNeuronIndex)
            % and the MEASURE is given by NeuronWeigthList(1,UpdatingNeuronIndex).
            % As expected, NeuronWeigthList should centralize every
            % weights of the full network.
    
                OutputFeedback = WiringWeigthList(PreIndex);
    
            % OutputFeedback_vec(ii) = OutputFeedback(PreIndex);
    
            para_exp_err(PreIndex) = y_int(PreIndex) - OutputFeedback;
    
            para_stand_err1(PreIndex) = PreRef - OutputFeedback;  %NeuronWeigthList(1,UpdatingNeuronIndex);  % W_update(PreIndex);
    
            %   para_stand_err1(PreIndex) = (( NeuronWeigthList(1,UpdatingNeuronIndex)* NeuronWeigthList(3 + PreIndex, UpdatingNeuronIndex) )) - W_update(PreIndex);  %NeuronWeigthList(1,UpdatingNeuronIndex);  % W_update(PreIndex);
    
            %  para_stand_err1(PreIndex) = (( NeuronWeigthList(2,UpdatingNeuronIndex)* NeuronWeigthList(3 + PreIndex, UpdatingNeuronIndex) / 2)) - (( NeuronWeigthList(1,UpdatingNeuronIndex)* NeuronWeigthList(3 + PreIndex, UpdatingNeuronIndex) ));  %NeuronWeigthList(1,UpdatingNeuronIndex);  % W_update(PreIndex);
    
            %  para_stand_err1(PreIndex) = 1 - W_update(PreIndex);  %NeuronWeigthList(1,UpdatingNeuronIndex);  % W_update(PreIndex);
    
    
            para_u1(PreIndex) = para_u1(PreIndex) + PMC_Kp(PreIndex) * para_exp_err(PreIndex);
            para_u1_vec(PreIndex, ii ) = para_u1(PreIndex);
    
            para_G1_1(PreIndex) = para_G1(PreIndex);
            para_G1(PreIndex) = PMC_Kint(PreIndex)*para_stand_err1(PreIndex);
    
            para_trapz1(PreIndex) = para_trapz1(PreIndex) + TimeStep*(para_G1_1(PreIndex) + para_G1(PreIndex) )/2;
    
            para_u_final1(PreIndex) = para_u1(PreIndex)*para_trapz1(PreIndex)/PMC_FinalScale(PreIndex);
    
            para_u_final1_vec(PreIndex, ii ) = para_u_final1(PreIndex);
    
            y_RK( PreIndex ) = (1 + TimeStep*A)*y_RK( PreIndex ) + TimeStep * B*para_u_final1(PreIndex);
    
            %OutputFeedback(PreIndex) = y_RK( PreIndex );
    
            WiringWeigthList(PreIndex) = y_RK( PreIndex);  % -0.1 * sin( 2*pi*freq * time_ ) ;

            %% should be disabled !!
            %   W_update_vec(PreIndex,ii+1) = W_update(PreIndex);
    
            OutputFeedback_vec(PreIndex,ii+1) = OutputFeedback;
            y_ref_vec(PreIndex,ii+1) = y_ref_(PreIndex);
    
        end
    
    end

    fprintf('Done ! \n')

   % % % % DEBUG : simply to plot in order to verify the control
   % % % 
   % %  for i_PreIndex = 1:length( OutputFeedback_vec(:,1) )
   % % 
   % % 
   %      i_PreIndex = 1;
   %      plot( OutputFeedback_vec(i_PreIndex, :), color_vec_str(i_PreIndex) );
   %      hold on
   % % 
   % % 
   % %      i_PreIndex
   % % 
   % %      pause(10)
   % % 
   % %  end
   % 
   %             % if ( ii >= 1000000 )
   %             % 
   %             %  PreRef = 0.8;
   %             % 
   %             % end
   % 
   % % 
   %  pause

    clear OutputFeedback_vec
    clear y_ref_vec
    init_control = zeros(1,MaxWires);