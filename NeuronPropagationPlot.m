    
    % =============================================================================
    
    
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
    
    
    % %  For debug only -> SAVE DATA IN VECTORS
    %     OutputFeedback_vec(1, Iteration_k+1) = NeuronWeigthList(1, 3);
    %     y_ref_vec(1,Iteration_k+1) = NeuronWeigthList(2, 3);
    %     Wiring_vec(1,Iteration_k+1) = y_RK( 32 );
    %     Wiring_vec(2,Iteration_k+1) = y_RK( 33 );
    %     %
    %     OutputFeedback_vec(2, Iteration_k+1) = NeuronWeigthList(1, 5);
    %     y_ref_vec(2,Iteration_k+1) = NeuronWeigthList(2, 5);
    %     Wiring_vec(3,Iteration_k+1) = y_RK( 54 );
    %     Wiring_vec(4,Iteration_k+1) = y_RK( 55 );
    %     %
    %     OutputFeedback_vec(3, Iteration_k+1) = NeuronWeigthList(1, 9);
    %     y_ref_vec(3,Iteration_k+1) = NeuronWeigthList(2, 9);
    %     Wiring_vec(5,Iteration_k+1) = y_RK( 98 );
    %     Wiring_vec(6,Iteration_k+1) = y_RK( 99 );
    %     %
    %     OutputFeedback_vec(4, Iteration_k+1) = NeuronWeigthList(1, 4);
    %     y_ref_vec(4,Iteration_k+1) = NeuronWeigthList(2, 4);
    %     Wiring_vec(7,Iteration_k+1) = y_RK( 43 );
    %     Wiring_vec(8,Iteration_k+1) = y_RK( 44 );
    %     %
    %     OutputFeedback_vec(5, Iteration_k+1) = NeuronWeigthList(1, 8);
    %     y_ref_vec(5,Iteration_k+1) = NeuronWeigthList(2, 8);
    %     Wiring_vec(9,Iteration_k+1) = y_RK( 87 );
    %     Wiring_vec(10,Iteration_k+1) = y_RK( 88 );
    %     %
    %     OutputFeedback_vec(6, Iteration_k+1) = NeuronWeigthList(1, 10);
    %     y_ref_vec(6,Iteration_k+1) = NeuronWeigthList(2, 10);
    %     Wiring_vec(11,Iteration_k+1) = y_RK( 31 );
    %     Wiring_vec(12,Iteration_k+1) = y_RK( 42 );
    %     Wiring_vec(13,Iteration_k+1) = y_RK( 53 );
    %     Wiring_vec(14,Iteration_k+1) = y_RK( 86 );
    %     Wiring_vec(15,Iteration_k+1) = y_RK( 97 );
    
    
    figure(1)
    subplot(3,1,1)
    plot( OutputFeedback_vec(1,:), 'b', 'LineWidth', 2)
    hold on
    plot( y_ref_vec(1,:), '--r', 'LineWidth', 2)
    plot( Wiring_vec(1,:), '-c', 'LineWidth', 2)
    plot( Wiring_vec(2,:), '--m', 'LineWidth', 2)
    legend('Neuron #3 output', 'Neuron #3 ref', 'W32', 'W33' )
    set(gca,'FontSize',30);
    subplot(3,1,2)
    plot( OutputFeedback_vec(2,:), 'b', 'LineWidth', 2)
    hold on
    plot( y_ref_vec(2,:), '--r', 'LineWidth', 2)
    plot( Wiring_vec(3,:), '-c', 'LineWidth', 2)
    plot( Wiring_vec(4,:), '--m', 'LineWidth', 2)
    legend('Neuron #5 output', 'Neuron #5 ref', 'W54', 'W55' )
    set(gca,'FontSize',30);
    subplot(3,1,3)
    plot( OutputFeedback_vec(3,:), 'b', 'LineWidth', 2)
    hold on
    plot( y_ref_vec(3,:), '--r', 'LineWidth', 2)
    plot( Wiring_vec(5,:), '-c', 'LineWidth', 2)
    plot( Wiring_vec(6,:), '--m', 'LineWidth', 2)
    legend('Neuron #9 output', 'Neuron #9 ref', 'W98', 'W9' )
    xlabel('Iterations')
    set(gca,'FontSize',30);
    set(gcf,'Color','w');
    
    
    figure(2)
    subplot(2,1,1)
    plot( OutputFeedback_vec(4,:), 'b', 'LineWidth', 2)
    hold on
    plot( y_ref_vec(4,:), '--r', 'LineWidth', 2)
    plot( Wiring_vec(7,:), '-c', 'LineWidth', 2)
    plot( Wiring_vec(8,:), '--m', 'LineWidth', 2)
    legend('Neuron #4 output', 'Neuron #4 ref', 'W43', 'W44' )
    set(gca,'FontSize',30);
    subplot(2,1,2)
    plot( OutputFeedback_vec(5,:), 'b', 'LineWidth', 2)
    hold on
    plot( y_ref_vec(5,:), '--r', 'LineWidth', 2)
    plot( Wiring_vec(9,:), '-c', 'LineWidth', 2)
    plot( Wiring_vec(10,:), '--m', 'LineWidth', 2)
    legend('Neuron #8 output', 'Neuron #8 ref', 'W87', 'W88' )
    xlabel('Iterations')
    set(gca,'FontSize',30);
    set(gcf,'Color','w');
    
    
    figure(3)
    plot( OutputFeedback_vec(6,:), 'b', 'LineWidth', 2)
    hold on
    plot( y_ref_vec(6,:), '--r', 'LineWidth', 2)
    plot(            Wiring_vec(11,:), '-c', 'LineWidth', 2)
    plot(            Wiring_vec(12,:), '--m', 'LineWidth', 2)
    plot(            Wiring_vec(13,:), '-y', 'LineWidth', 2)
    plot(            Wiring_vec(14,:), '--g', 'LineWidth', 2)
    plot(            Wiring_vec(15,:), '--k', 'LineWidth', 2)
    legend('Neuron #10 output', 'Neuron #10 ref', 'W31', 'W42', 'W53', 'W86', 'W97' )
    xlabel('Iterations')
    set(gcf,'Color','w');
    set(gca,'FontSize',30);
    
    
    length_plot_ep = 10000;
    
    if (newConnectedID == 10 )
        figure(4)
        subplot(3,1,1)
        plot( OutputFeedback_vec(7,plot_epoch_time_1:plot_epoch_time_1+length_plot_ep), 'b', 'LineWidth', 3)
        title('Training Data - input #1 / time');
        set(gca,'FontSize',30);
        subplot(3,1,2)
        plot( OutputFeedback_vec(8,plot_epoch_time_1:plot_epoch_time_1+length_plot_ep), 'b', 'LineWidth', 3)
        ylim([0.95, 1.05]);
        title('Training Data - input #2 / data');
        set(gca,'FontSize',30);
        subplot(3,1,3)
        plot( OutputFeedback_vec(9,plot_epoch_time_1:plot_epoch_time_1+length_plot_ep), 'b', 'LineWidth', 3)
        ylim([2.53, 2.55]);
        title('Training Data - output / sign of data');
        xlabel('Iterations')
        set(gcf,'Color','w');
        set(gca,'FontSize',30);
    
    end
    
    
    if (newConnectedID == 10)
    
        figure(5)
        subplot(2,1,1)
        plot ( StatFeedback_vec(1,plot_epoch_time_1:end) , 'b', 'LineWidth', 3)
        title('Propagation of wires stat. / mean value')
        set(gca,'FontSize',30);
        subplot(2,1,2)
        plot ( StatFeedback_vec(2,plot_epoch_time_1:end) , 'b', 'LineWidth', 3)
        title('Propagation of wires stat. / std value')
        xlabel('Iterations')
        set(gcf,'Color','w');
        set(gca,'FontSize',30);
    
    end