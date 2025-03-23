    
    %     clear all
    %     close all
    %     clc
    
    
    % Example of data set
    
    % Sine function and its time-derivative
    if ( TrainingSet == 1)
    
        % Def. of a sine function
        sine_ = @(t)(1 + 0.01 * sin( 8*t) );
    
        time_1 = [0:0.01:1];
    
        input_1 = 0.01 + sine_( time_1 );
    
        % Evaluation of the variations
        output_1 = 10 * diff( input_1 );
    
        % Use of a sing function
        % for oo = 1:length( output_1 )
        %
        %     if ( output_1(oo) > 0 )
        %         output_1_(oo) = 0.1;
        %     else
        %         output_1_(oo) = -0.1;
        %     end
        %
        % end
    
        % figure(1)
        % plot ( time_1, input_1 )
        % hold on
        % plot ( time_1(1:end-1) , output_1_ )
    
    
        % Assign to the training data
        Training_input(1,:) = time_1;
        Training_input(2,:) = input_1;
        Training_output = 2.54 + [output_1, output_1(end)];
    
    end
    
    
    %--------------------------------------------
    %--------------------------------------------
    %--------------------------------------------
    
    if ( Iteration_k == -1 & PlotTraingSet == 1)
        subplot(2,1,1)
        plot ( Training_input(1,:), Training_input(2,:), 'linewidth',2 )
        subplot(2,1,2)
        plot ( Training_input(1,:) , Training_output , 'linewidth',2)
        

        fprintf('Please restart the program - Abort!')
        pa
    end
    
    % EPOCH TRAINING: transfered to the main program
    % ind_training = 1;
    % t_ind = 0;
    %
    % for oo = 1:10*length(Training_input)
    %
    %     if ( ind_training < length(Training_input) )
    %
    %         if ( t_ind == 5)
    %
    %         ind_training = ind_training + 1;
    %
    %         t_ind = 0;
    %
    %         else
    %
    %             t_ind = t_ind + 1;
    %
    %         end
    %
    %     else
    %
    %         ind_training = 1;
    %
    %     end
    %
    %       Training_epoch(oo) = Training_input(2, ind_training );
    %
    %
    % end
    %
    %
    % figure(2)
    % plot( Training_epoch );
    
    
    

