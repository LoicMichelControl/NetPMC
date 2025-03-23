

function division_list = division_by_two( division_list, n )

division_list_ = division_list(n) / 2;

division_list(n) = division_list_;

division_list = [division_list, division_list_];

if ( sum( division_list ) ~= 1 )

fprintf( "====== problem with the division !" )
pa

else

%fprintf( "====== OK !" )

end