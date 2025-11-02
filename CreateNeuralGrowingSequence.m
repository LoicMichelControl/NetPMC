

function [RandomNeuronVector, ConnectedIDNeuron, Neuron, SortConnectedIDNeuron ] = ...
        CreateNeuralGrowingSequence(ConnectedIDNeuron,  ...
        Neuron, ...
        maxNeurons, ...
        NbNeuronsPerCluster, ...
        EntryConnectedNeuron)
    
    % The goal is to connect a new neuron 'Target neuron' in a pseuo-random
    % manner
    
    
    ExcludedNeurons = []; % May not be used ? see in future versions -> !!!not set as output variable of the function!!!!
    
    % List all the connected neurons excluding the input neurons (not listed in the vector):
    SortConnectedIDNeuron = sort( unique ( ConnectedIDNeuron ) );
        

    % Divide neurons into two categories: 
    % From the meshing, it appears that a natural switch between low and
    % high locations in the grid allows switching for a pseudo-random
    % positionning of the neurons

    divide_part_low = 1:1:floor(maxNeurons/2);
    divide_part_up = floor(maxNeurons/2)+1:1:maxNeurons;
    
    % flip to 'randomize'  
    divide_part_low = flip(divide_part_low);
    divide_part_up = flip(divide_part_up);

    % Create alternative switching between low and high parts
    % -> 'RandomNeuronVector' is the resultiung vector
    switch_part = 1; % switch 0 -> 1 and 1 -> 0
    
    counter_ = 1; % counter to progess in each low and high vectors   
    rand_vector_cnt = 1; % progression in the 'RandomNeuronVector'

    RandomNeuronVector = zeros(2,maxNeurons+10); % init. of the RandomNeuronVector

    qq = 1; % counter for neuron clustering

    % the upper bound bound must be properly defined - see later
    for rr = 1:(maxNeurons+10) % a security margin of 10 - to be sure to avoid bugs ;)

        RandomNeuronVector(2, rand_vector_cnt) = qq;
        RandomNeuronVector(3, 1) = 1;
        if ( rand_vector_cnt >= qq * NbNeuronsPerCluster )
           
            if ( rand_vector_cnt == qq * NbNeuronsPerCluster )

                RandomNeuronVector(3, rand_vector_cnt + 1) = 1;

            end

             qq = qq + 1;

        end
    
        if (switch_part == 1)
    
            if (counter_ <= length( divide_part_up ))
                RandomNeuronVector(1, rand_vector_cnt) = divide_part_up(counter_);
                switch_part = 0;
                
                rand_vector_cnt = rand_vector_cnt + 1;
            end
    
        else
    
            if (counter_ <= length( divide_part_low ))
                RandomNeuronVector(1, rand_vector_cnt) = divide_part_low(counter_);
                switch_part = 1;

                rand_vector_cnt = rand_vector_cnt + 1;
    
                counter_ = counter_ + 1;
            end
    
        end
    
    end


        if ( EntryConnectedNeuron(1) ~= RandomNeuronVector(1,1) )
                 
            Index_Entry_1 = find (  EntryConnectedNeuron(1) == RandomNeuronVector(1,:) );

            if ( Index_Entry_1 > 2 )
            RandomNeuronVector(1,Index_Entry_1) = RandomNeuronVector(1,1);
            RandomNeuronVector(1,1) = EntryConnectedNeuron(1);
            end

            
        end

              
        if ( EntryConnectedNeuron(1) ~= RandomNeuronVector(1,2) )

          Index_Entry_1 = find (  EntryConnectedNeuron(1) == RandomNeuronVector(1,:) );

          if ( Index_Entry_1 > 2 )
          RandomNeuronVector(1,Index_Entry_1) = RandomNeuronVector(1,2);
          RandomNeuronVector(1,2) = EntryConnectedNeuron(1);
          end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if ( EntryConnectedNeuron(2) ~= RandomNeuronVector(1,1) )
            
            Index_Entry_2 = find (  EntryConnectedNeuron(2) == RandomNeuronVector(1,:) );

            if ( Index_Entry_2 > 2 )
            RandomNeuronVector(1,Index_Entry_2) = RandomNeuronVector(1,1);
            RandomNeuronVector(1,1) = EntryConnectedNeuron(2);
            end

        end

        if ( EntryConnectedNeuron(2) ~= RandomNeuronVector(1,2)  )

          Index_Entry_2 = find (  EntryConnectedNeuron(2) == RandomNeuronVector(1,:) );

          if ( Index_Entry_2 > 2 )
          RandomNeuronVector(1,Index_Entry_2) = RandomNeuronVector(1,2);
          RandomNeuronVector(1,2) = EntryConnectedNeuron(2);

          end
        end
