#!/usr/bin/perl
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.
use File::Basename;

my ($reader_program) = (fileparse( $0 ))[1] . "get_record";

my (@standings);

my (%conferences) = ( 1 => 'New England',
		      2 => 'Atlantic',
		      3 => 'Southeast',
		      4 => 'Great Lake',
		      5 => 'Southwest',
		      6 => 'Northwest',
		      7 => 'Midwest',
		      8 => 'South' );

my (%teams) = ( 'ual' => 3,
		'uar' => 8,
		'uaz' => 5,
		'uca' => 5,
		'uco' => 5,
		'uct' => 1,
		'ude' => 2,
	 	'ufl' => 3,
		'uga' => 3,
		'uid' => 6,
		'uil' => 4,
		'uin' => 4,
		'uia' => 7,
		'uks' => 7,
		'uky' => 4,
		'ula' => 8,
		'uma' => 1,
		'umd' => 2,
		'ume' => 1,
		'umi' => 4,
		'umn' => 7,
		'umo' => 8,
		'ums' => 8,
		'umt' => 6,
		'unc' => 3,
		'und' => 7,
		'une' => 6,
		'unh' => 1,
		'unj' => 2,
		'unm' => 5,
		'unv' => 5,
		'uny' => 2,
		'uoh' => 4,
		'uok' => 8,
		'uor' => 6,
		'upa' => 4,
		'uri' => 1,
		'usc' => 3,
		'usd' => 7,
		'utn' => 3,
		'utx' => 8,
		'uut' => 5,
		'uva' => 2,
		'uvt' => 1,
		'uwa' => 6,
		'uwi' => 7,
		'uwv' => 2,
		'uwy' => 6 );




sub compare {

    my (@team0)  = @{ $_[0] };
    my (@team1)  = @{ $_[1] };
    my ($sdiff0) = $team0[4] - $team0[5];
    my ($sdiff1) = $team1[4] - $team1[5];
    my ($retval);


    if ( $team0[1] != $team1[1] ) {

	$retval = ($team0[1] > $team1[1]) ? -1 : 1;
    }
    elsif ( $team0[2] != $team1[2] ) {

	$retval = ($team0[2] > $team1[2]) ? 1 : -1;
    }
    elsif ( $sdiff0 != $sdiff1 ) {

	$retval = ($sdiff0 > $sdiff1) ? -1 : 1;
    }
    elsif ( $team0[4] != $team1[4] ) {

	$retval = ($team0[4] > $team1[4]) ? -1 : 1;
    }
    else {

	$retval = ($team0[0] lt $team1[0]) ? 1 : -1;
    }

    return $retval;
}



sub partition {

    my ( $array, $first, $last ) = @_;

    my $i = $first;
    my $j = $last - 1;
    my $pivot = $array->[ $last ];

 SCAN: {
        do {
            # $first <= $i <= $j <= $last - 1
            # Point 1.

            # Move $i as far as possible.
            while ( compare( $array->[ $i ], $pivot ) <= 0 ) {

                $i++;

                last SCAN if $j < $i;
            }

            # Move $j as far as possible.
            while ( compare( $array->[ $j ], $pivot ) >= 0 ) {
                $j--;
                last SCAN if $j < $i;
            }

	    # $i and $j did not cross over, so swap a low and a high value.
            @$array[ $j, $i ] = @$array[ $i, $j ];

        } while ( --$j >= ++$i );
    }
    # $first - 1 <= $j < $i <= $last
    # Point 2.

    # Swap the pivot with the first larger
    # element (if there is one).
    if ( $i < $last ) {

        @$array[ $last, $i ] = @$array[ $i, $last ];

        ++$i;
    }

    # Point 3.

    return ( $i, $j );   # The new bounds exclude the middle.
}

sub quicksort_recurse {

    my ( $array, $first, $last ) = @_;

    if ( $last > $first ) {

        my ( $first_of_last, $last_of_first ) = partition( $array, $first, $last );

        local $^W = 0; # Silence deep recursion warning.

        quicksort_recurse($array, $first,         $last_of_first);
        quicksort_recurse($array, $first_of_last, $last);
    }
}

sub sort_teams {

    # The recursive version is bad with BIG lists
    # because the function call stack gets REALLY deep.
    quicksort_recurse($_[ 0 ], 0, $#{ $_[ 0 ] });
}

# If you expect that many of your keys will be the same,
# try adding this before the <LITERAL>return</LITERAL> in
# <LITERAL>partition()</LITERAL>:
#
# Extend the middle partition as much as possible.
#
# ++$i while $i <= $last  && $array->[ $i ] eq $pivot;
# --$j while $j >= $first && $array->[ $j ] eq $pivot;



sub get_record {

    my ($stats_filename) = $_[0].".stat";
    my (@details);

    if ( -e $stats_filename ) {

	@details = split( ",", `$reader_program $stats_filename` );
    }
    else {

	@details = ( $_[0], 0, 0, 0, 0, 0 );
    }

    return \@details;
}

foreach $team_abbr (sort keys %teams) {

    my ($record) = get_record( $team_abbr );

    $conference = $teams{$team_abbr};

    push @{ $standings[$conference] }, $record;
}


for ( $i = 1; $i <= 8; $i++ ) {

    sort_teams( $standings[$i] );
}


printf "%-16s W  L  T    ", $conferences{1};
printf "%-16s W  L  T    ", $conferences{2};
printf "%-16s W  L  T    ", $conferences{3};
printf "%-16s W  L  T    ", $conferences{4};

print "\n";
print "-                -  -  -    -                -  -  -    -                -  -  -    -                -  -  -    \n";

for ( $i = 0; $i < 6; $i++ ) {

    printf( "%-15s %2d %2d %2d    ",
	    $standings[1]->[$i]->[0],
	    $standings[1]->[$i]->[1],
	    $standings[1]->[$i]->[2],
	    $standings[1]->[$i]->[3] );

    printf( "%-15s %2d %2d %2d    ",
	    $standings[2]->[$i]->[0],
	    $standings[2]->[$i]->[1],
	    $standings[2]->[$i]->[2],
	    $standings[2]->[$i]->[3] );

    printf( "%-15s %2d %2d %2d    ",
	    $standings[3]->[$i]->[0],
	    $standings[3]->[$i]->[1],
	    $standings[3]->[$i]->[2],
	    $standings[3]->[$i]->[3] );

    printf( "%-15s %2d %2d %2d    ",
	    $standings[4]->[$i]->[0],
	    $standings[4]->[$i]->[1],
	    $standings[4]->[$i]->[2],
	    $standings[4]->[$i]->[3] );

    print "\n";
}

print "\n";
print "\n";

printf "%-16s W  L  T    ", $conferences{5};
printf "%-16s W  L  T    ", $conferences{6};
printf "%-16s W  L  T    ", $conferences{7};
printf "%-16s W  L  T    ", $conferences{8};

print "\n";
print "-                -  -  -    -                -  -  -    -                -  -  -    -                -  -  -    \n";

for ( $i = 0; $i < 6; $i++ ) {

    printf( "%-15s %2d %2d %2d    ",
	    $standings[5]->[$i]->[0],
	    $standings[5]->[$i]->[1],
	    $standings[5]->[$i]->[2],
	    $standings[5]->[$i]->[3] );

    printf( "%-15s %2d %2d %2d    ",
	    $standings[6]->[$i]->[0],
	    $standings[6]->[$i]->[1],
	    $standings[6]->[$i]->[2],
	    $standings[6]->[$i]->[3] );

    printf( "%-15s %2d %2d %2d    ",
	    $standings[7]->[$i]->[0],
	    $standings[7]->[$i]->[1],
	    $standings[7]->[$i]->[2],
	    $standings[7]->[$i]->[3] );

    printf( "%-15s %2d %2d %2d    ",
	    $standings[8]->[$i]->[0],
	    $standings[8]->[$i]->[1],
	    $standings[8]->[$i]->[2],
	    $standings[8]->[$i]->[3] );

    print "\n";
}

exit;


for ( $i = 0; $i < 8; $i++ ) {

    @conf = @{ $standings[$i] };

    printf "%-30s\n", $conferences{$i};

    foreach $team (@conf) {

	printf( "%-15s %2d %2d %2d\n", $team->[0], $team->[1], $team->[2], $team->[3] );
    }

    print "\n";
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   OFFENSE
#
#  .LO 1 2 3 4 5 6 7 8 9 A B
#
#
#  7       1 2 3 4 5 6
#              B             A
#              9
#              8
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   DEFENSE
#
#  .LD 1 2 3 4 5 6 7 8 9 A B
#
#
#      9              A
#
#        4   5   6   7
#  8       1   2   3       B
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   KICKOFF
#
#  .LK 1 2 3 4 5 6 7 8 9 A B
#
#
#  1 2 3 4 5   6 7 8 9 A
#
#            B
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   PUNT
#
#  .LP 1 2 3 4 5 6 7 8 9 A B
#
#
#  8     1 2 3 4 5 6 7     A
#                9
#
#
#              B
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   KICKOFF RETURN
#
#  .LR 1 2 3 4 5 6 7 8 9 A B
#
#
#            A   B
#
#              9
#
#         6    7   8
#
#      1   2   3   4   5
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   PUNT RETURN
#
#  .LQ 1 2 3 4 5 6 7 8 9 A B
#
#            B
#
#
#        9         A
#
#
#  1     2 3 4 5 6 7     8
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   FIELD GOAL DEFENSE (same lineup is punt return)
#
#  .LQ 1 2 3 4 5 6 7 8 9 A B
#
#       9             A
#      1 2 3 4 5 6 7 8 9
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   FIELD GOAL
#
#  .LF 1 2 3 4 5 6 7 8 9 A B
#
#
#        1 2 3 4 5 6 7
#       8             9
#
#               A
#              B
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
