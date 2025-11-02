    
    
    % WiringRank matrix: assigned a rank number to wires (exclusing same wires -> similar config. detection)
    % example:
    % 3 - 11  ->  rank #1
    % 3 - 12  ->  rank #2
    % 5 - 11  ->  rank #3
    % 5 - 12  ->  rank #4
    % 3 - 11  ->  rank #1 (keep the same rank)
    % 3 - 12  ->  rank #2
    % ...
    
    
    function [NodeExcludeControl, WiringExcludeControl, WiringSortList, WiringSubList, CommonNeuron_sort, CommonWiring_sort, NeuronWeigthList] = ...
        NodeMatrixManagement_v2_b(NodeExcludeControl, WiringExcludeControl, NeuronWeigthList, newConnectedID, EnableCoupling, ...
        InputNeuronID, ListConnectedNeuron, WiringRank, ForbConnexionNeuron_A, ForbConnexionNeuron_B, ...
        ForbConnexionNeuron_C, ForbConnexionNeuron_D)


    % 0/ First

    NodeExcludeControl = [ NodeExcludeControl, newConnectedID];
    
    % A/  gives a list of the wiring index (as a sublist of the general list) between the ONLY listed connected neurons
    
    count_Wiring = 1;
    
    % Sweep all lines of WiringRank
    for uu = 1: length(WiringRank)
    
        % Detect the #wire of two connected neurons taken from the 'ListConnectedNeuron' excluding forbidden neurons
        % -> reduces the list of neurons to those which are connected
        % through the list
        % It uses find to look among the connected list and switch the
        % neurons by the #wire index
        if ( find(WiringRank(uu,1) == ListConnectedNeuron) & find(WiringRank(uu,2) == ListConnectedNeuron ) & ...
                ~(WiringRank(uu,1) == ForbConnexionNeuron_A & WiringRank(uu,2) == ForbConnexionNeuron_B ) & ...
                ~(WiringRank(uu,1) == ForbConnexionNeuron_B & WiringRank(uu,2) == ForbConnexionNeuron_A ) & ...
                ~(WiringRank(uu,1) == ForbConnexionNeuron_C & WiringRank(uu,2) == ForbConnexionNeuron_D ) & ...
                ~(WiringRank(uu,1) == ForbConnexionNeuron_D & WiringRank(uu,2) == ForbConnexionNeuron_C ))
    
            WiringSubList(count_Wiring,:) = [ WiringRank(uu,1), WiringRank(uu,2), WiringRank(uu,3) ];
    
            count_Wiring = count_Wiring + 1;
        end
    
    end
    
    % Avoid duplication of Ranks by re-assigning connected neurons by (unique) ranks
    % -> first compute a unique of the previous Rank list, then sweep this new (unique) list to re-assign
    % the connexions
    
    RankVec = unique( sort(WiringSubList(:,3) ));
    
    for yy = 1:length( RankVec )
    
        IndexRankSort = find ( WiringSubList(:,3) == RankVec(yy) );
    
        WiringSortList(yy,1) =  WiringSubList(IndexRankSort(1), 1);
        WiringSortList(yy,2) =  WiringSubList(IndexRankSort(1), 2);
        WiringSortList(yy,3) =  WiringSubList(IndexRankSort(1), 3);
    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % B/   lists all immediate neighborhood neurons associated to the connected neurons
    
    kk = 1;
    qq = 0;
    % sweep the complete matrix rows
    for ii = 1:length( WiringSubList(:,1) )
    
        for jj = 1:2 % sweep the two first columns
    
            % pick-up the (i,j) element as a 'pivot' : zig-zag between col(1)
            % and col(2)
            Pivot = WiringSubList( ii, jj );
    
            if ( ( isempty( find ( Pivot == InputNeuronID) ) == 1 ) )
    
                qq = qq + 1; % q is the line associated to a neuron (for which other connected neurons are listed)
                kk = 2;      % k is the counter of associated neurons (>2 since the first one is the pivot)
                CommonNeuron(qq, 1) = Pivot;
                for iii = 1:length( WiringSubList(:,1) )
    
                    % Check if the iii th line contains the pivot: if
                    % yes, then save the associated / complement neurons ID into CommonNeuron
                    % (indexed by 3 - 1 = 2 or 3 - 2 = 1 for the
                    % complement neuron)
    
                    if ( isempty( find( Pivot == WiringSubList(iii, 1:2 ) ) ) == 0 )
    
                        % if equal to pivot > 0, then assign to CommonWiring
                        % the complement of the line
    
                        % EnabledCoupling == 1 -> verify if the newConnectedID is
                        % present in the WiringSubList
                        % find ( WiringSubList(iii, 3-find ( Pivot == WiringSubList(iii,[1:2]) ) ) == newConnectedID )
                        % EnabledCoupling == 1 -> then put a (-) to the
                        % newConnectedID in all previous lines of
                        % CommonNeuron -> this removes the contribution
                        % of newConnectedID in all lines -> will be
                        % rejected by the product computing

                        % NodeExcludeControl contains all last 'newConnectedID' connected
                        % neurons -> easier to remove them from CommonNeuronNodeExcludeControl(ssd) 

                       
                            % if ( ( EnableCoupling == 1 & ( find ( WiringSubList(iii, 3-find ( Pivot == abs( WiringSubList(iii,[1:2]) ) ) ) == NodeExcludeControl(ssd)  ) ) == 1 ) )
                            %     CommonNeuron(qq, kk) = -WiringSubList(iii, 3-find ( Pivot == WiringSubList(iii,[1:2]) ) );
                            % else
                                CommonNeuron(qq, kk) = WiringSubList(iii, 3-find ( Pivot == WiringSubList(iii,[1:2]) ) );
                            % end

                          %  pause
   
                        
                        % Check if lines are identical (via the averaged) - simply cancel the line
                        % with a -99 that will be removed with the final
                        % elimination
    
                        for tt = 1:qq-1
    
                            if ( mean( CommonNeuron(tt, :) == CommonNeuron(qq, :) ) == 1 )
    
                                CommonNeuron(tt, :) = -555 + 0 * CommonNeuron(tt, :);
    
                            end
    
                        end
    
                        kk = kk + 1;
                    end
    
                end
    
            end
    
        end
    
    end
    
    % eliminates -99 lines
    bbb = 1;
    for aaa = 1:length(  CommonNeuron(:,1)  )
    
        % eliminate lines containing -99: save only lines ~= -99
        if ( CommonNeuron(aaa,1) ~= -555 )
    
            CommonNeuron_sort_(bbb,:) = CommonNeuron(aaa,:);
    
            bbb = bbb + 1;
    
        end
    
    end
    
    % Make a "unique" to remove redundance of neurons and keeping zeros at the end
    for aaa = 1:length(  CommonNeuron_sort_(:,1)  )
    
        CommonNeuron_sort(aaa,:) = [CommonNeuron_sort_(aaa,1), unique(CommonNeuron_sort_(aaa,2:end), 'stable') ];
    
    end
    
    % !!!! CommonNeuron_sort does not contain any -99 line !!!!



    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % C /    lists all #wirings associated to the connected neurons
    
    %Simply re-assign
    CommonWiring_sort = CommonNeuron_sort;
    
    kk = 1;
    qq = 0;
    % sweep the complete matrix rows
    for ii = 1:length( CommonWiring_sort(:,1) )
    
        % pick-up the (i,1) element as a 'pivot'
        Pivot = CommonWiring_sort( ii, 1 );
    
        for jj = 2:length( CommonWiring_sort(1,:) ) % sweep the tow first columns
    
            valid = 0;
            for zz = 1: length( WiringSubList(:,1)  )
    
                % Check which neuron the pivot is connected with -> assign
                % the corresponding wire index#
                % Check if CommonWiring_sort( ii, jj ) < 0 to save the
                % corresponding wire
                if ( WiringSubList(zz,1) == Pivot & abs(CommonWiring_sort( ii, jj )) == WiringSubList(zz,2) & valid == 0 )
    
                    % Substitute the (zz,2) neuron by its associated wire
                    % (zz,3)


                    % SHOULD NOT BE USED AT THIS POINT :
                    % EnableCoupling -> if the sign is (-) then simply add the (-) sign to the
                    % connexion -> will be rejected by the product computing
                    % check with the 'EnabledCoupling' section
    
                    if ( CommonWiring_sort( ii, jj ) < 0)
    
                        % Notify wires to be rejected by adding a (-)
                        % sign
                        CommonWiring_sort( ii, jj ) = sign( CommonWiring_sort( ii, jj ) ) * WiringSubList(zz,3);
    
                        % Notify the exclusion of the rejected wire
                        WiringExcludeControl = [WiringExcludeControl, WiringSubList(zz,3)];
    
                    else
    
                        CommonWiring_sort( ii, jj ) = WiringSubList(zz,3);
    
                    end
    
                    valid = 1;
    
    
    
                end
    
            end
    
            if ( valid == 0)
                CommonWiring_sort( ii, jj ) = - 555;
            end
    
        end
    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % D / Determine the number of wires that are connected to each neuron
    % -> Simply count the the wires for each row in the CommonWiring
    % -> assignation to the (:,1,3) dimension of CommonWiring_sort (in
    % order to avoid conflicts with the regular updates
    % - to be improved ;) )
    
    for ii = 1:length( CommonWiring_sort(:,1,1) )
    
        WiresCounter_Neuron = 0;
        Vec_Wiring = [];
        for jj = 2:length( CommonWiring_sort(1,:,1) )
    
            if CommonWiring_sort(ii,jj,1) > 0
    
                Vec_Wiring = [Vec_Wiring, CommonWiring_sort(ii,jj,1)];
    
                WiresCounter_Neuron = WiresCounter_Neuron + 1;
    
            end
    
        end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % E / Set the sub-targeted weigths of the neurons :
        % - determine how many connexions are deplyed per neuron (update from Section D of the NodeManagement)
        % - list sub-targeted weigths (that will be applied for the control)
        % in NeuronWeigthList with larger row-dimension (sub-targeted > 3, :) since it could
        % be directly multiplied with the reference NeuronWeigthList(2,:)
    
        % For a particular neuron 'x':
        % index (1,x) refers to the 'measured / controlled' value
        % index (2,x) refers to the targeted value
        % index (3,x) refers to the nb of connexions associated to 'x'
        % index (>3,x) list all sub-targeted weigths (that amis to help
        % converging the control)
    
        NeuronWeigthList(3, CommonWiring_sort(ii, 1 ) ) = WiresCounter_Neuron; % update from Section D of the NodeManagement
    
    
        % For each indexed neuron weight, compute the sub-weigth
        % and store to the upper row-based dimension (sub-targeted > 3, :)
        % associated to the Reference NeuronWeigthList(2,:,1)
        yy = 0;
        division_list = 1;
        for tt = 1:WiresCounter_Neuron-1
    
            % sweep the division_list to divide again into
            % small numbers
            yy = yy + 1;
    
            division_list = division_by_two( division_list, yy );
        end
    
        % Once the division list is obtain, just save it
        % into NeuronWeigthList(sub-targeted > 3, :)
        for yy = 1:length( division_list )

            NeuronWeigthList(3 + Vec_Wiring , CommonWiring_sort(ii, 1, 1 ) ) = division_list;
            
        end
    
    end
    
    
    % END