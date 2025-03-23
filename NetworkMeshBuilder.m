 
    % % This function tries to create a 'pseudo' random map of a neuron network
    % % (baed on iterative-averaged algorithm).
    % 
    % 
    % % NewPoint = @( x1, y1, x2, y2 )( [ 1.5*(x1 + x2)/2, 0.5* max(y1, y2) + (y1 + y2)/2 ) ] )
    % 
    % % defines the coordinates of a new point P3 based on the average of two
    % % existing points (P1, P2)
    % 



function NeuronMesh = NetworkMeshBuilder (kappa, iota, sign_offset_neg, sign_offset_pos, offset_coord, MaxNeuron, NeuronMesh )

    
    % Simple strategy to build a neural mapping:
    
    % 1/ From two input neurons [ (x1, y1) and (x2, y2) ], we do expect to create a first neuron
    % (x2, y2) that is located at the kappa-middle in -x and iota-upper from
    % the middle in -y. Both new coordonates are (linearly) offsetted with the
    % 'offset_coord' and 'sign_offset' to increase the space between the neurons. The offset is
    % changed according to the index of the neuron to span a correct display
    % grid.
    % 2/ From the two input neurons [ (x1, y1) and (x2, y2) ] and [the first
    % created neuron (x3, y3)], we do expect to create a sec. neuron
    % (x4, y4) that is located at the kappa-middle {between (x2, y2) and (x3, y3)} in -x and iota-upper
    % from the middle between {(x2, y2) and (x3, y3)} in -y. Both new coordonates are (linearly) offsetted with the
    % 'offset_coord' and 'sign_offset' to increase the space between the neurons. The offset is
    % changed according to the index of the neuron to span a correct display
    % grid.
    % 3/ From the two input neurons [ (x1, y1) and (x2, y2) ] and [the first
    % created neuron (x3, y3) + the sec. neuron (x4, y4)], we do expect to create a third. neuron
    % (x5, y5) that is located at the kappa-middle {between (x1, y1) and (x3, y3)} in -x and iota-upper
    % from the middle between {(x1, y1) and (x3, y3)} in -y. Both new coordonates are (linearly) offsetted with the
    % 'offset_coord' and 'sign_offset' to increase the space between the neurons. The offset is
    % changed according to the index of the neuron to span a correct display
    % grid.
    
    % defining initial trame : [T1, T2, T3, T4, T5]
    
    % 1/        +   +   =
    
    % 2/            +   +   =
    
    % 3/        +       +       =
    
    % defining new trame : [T1', T2', T3', T4', T5']
    
    % 4/   transfer   T4 -> T1'  &  T5 -> T2'
    
    % This micro-sequence allows performing the neural mapping strategy using
    % an opcode vector that sequences the operations on the neurons
    % coordonates.
    
    % the first third sequence
    OpCode(1,:) = [1, 2, 3]; %-> (1,3) must be stored in a vector to be re-used after
    OpCode(2,:) = [2, 3, 4]; %-> (2,3) must be stored in a vector to be re-used after
    OpCode(3,:) = [1, 3, 5]; %-> (3,3) must be stored in a vector to be re-used after
    
    indexOpCode = -2;
    
    % Iterating to the next sequences
    for uu = 1:100
        indexOpCode = indexOpCode + 3;
    
        OpCode(indexOpCode+3,:) = 3 + OpCode(indexOpCode,:) ;
        OpCode(indexOpCode+4,:) = 3 + OpCode(indexOpCode+1,:) ;
        OpCode(indexOpCode+5,:) = 3 + OpCode(indexOpCode+2,:) ;
    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Example :
    
    % Opcode test :
    operation = @(x,y)( x + y );
    
    index_1 = 1;
       
    % Example in the Debug mode (commented) : uses only the addition of the 'test' field of
    % 'NeuronMesh'
    
    % Simply uncomment the following section
    
    % %------------------------------------------------
    % OpCodeexcute = @(OpCode, NeuronMesh, index )( operation( NeuronMesh( OpCode(index,1) ).Test,  NeuronMesh( OpCode(index,2) ).Test )  );
    % for ttt = 1:20
    %
    %  %-> the value OpCode(:,3) is stored in the T vector
    %
    %     T(OpCode( index_1, 3 ) ) = OpCodeexcute(OpCode, NeuronMesh, index_1  );
    %     NeuronMesh(ttt+2).Test = T(OpCode( index_1, 3 ) );
    %
    %  T
    %
    %  NeuronMesh(end).Test
    %
    % % NeuronMesh(:).Test
    %
    % index_1 = index_1 + 1;
    %
    % pause
    %
    % end
    % %------------------------------------------------
    
    % it should give the following result:
    %
    % %  trame : [T1, T2, T3, T4, T5]
    %
    % % 1/        +   +   =
    %
    % % 2/            +   +   =
    %
    % % 3/        +       +       =
    %
    % % 4/      T4 -> T1  &  T5 -> T2
    %
    % % First :
    %
    % % T1(1) + T2(2) -> T3 = 3
    %
    % % T2(2) + T3(3) -> T4 = 5
    %
    % % T1(1) + T3(3) -> T5 = 4
    %
    % % Second :
    %
    % % T1'(5) + T2'(4) -> T6 = 9
    %
    % % T2'(4) + T6'(9) -> T7 = 13
    %
    % % T1'(5) + T6'(9) -> T8 = 14
    %
    % % Third :
    %
    % % T1''(13) + T2''(14) -> T9 = 27
    %
    % % T2''(14) + T9(27)   -> T10 = 41
    %
    % % T1''(13) + T9(27)   -> T11 = 40
    %
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Be careful since the neuron-index of each neuron are directly taken from
    % 'NeuronMesh' which are pointed by the OpCode(index,1) and OpCode(index,2) -> the next neuron
    % is stored in the next index assigned to 'NeuronMesh'OpCode(index,3).
    
    index = 1;
    sign_sw = 1;

    % Create the neuron mesh
    
    for ii = 1:MaxNeuron
    
    
        if ( sign_sw == 1)
            sign_sw = 0;
            sign_offset = sign_offset_neg;
        else
            sign_offset = sign_offset_pos;
            sign_sw = 1;
        end
    
        % Defines a new point based on the averaged location of the two
        % neurons (including offset...)
        NewPoint = @( x1, y1, x2, y2, offset_coord, sign_offset )( [ kappa*((x1 + x2 )/2 + sign_offset * offset_coord), iota*((y1 + y2)/2 + 0.5 * sign_offset * offset_coord) ] );
    
    
        OpCodeexcute = @(OpCode, NeuronMesh, index, offset_coord)( NewPoint( NeuronMesh( OpCode(index,1) ).x, ...
            NeuronMesh( OpCode(index,1) ).y, ...
            NeuronMesh( OpCode(index,2) ).x, ...
            NeuronMesh( OpCode(index,2) ).y, ...
            offset_coord, sign_offset ) );
    
        OutOpCode = OpCodeexcute(OpCode, NeuronMesh, index, offset_coord );
    
        %    fprintf('-----------');
    
        NeuronMesh( OpCode(index,3) ).x = OutOpCode(1);
        NeuronMesh( OpCode(index,3) ).y = OutOpCode(2);
        NeuronMesh( OpCode(index,3) ).ID = OpCode(index,3);
    
    %    scatter(NeuronMesh( OpCode(index,3) ).x, NeuronMesh( OpCode(index,3) ).y, 500, 'g', 'filled')
    
        index = index + 1;
    
        if uu > 1
    
            offset_coord = offset_coord + 0.1;
       
        end
        
    end

    % Rectify the neuron #10 for better positionning in the grid (beta
    % version) -> modifiy the neuron #8.
    NeuronMesh(10).x = 2.1;
    NeuronMesh(10).y = 1.7;
