#!/usr/bin/perl
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.

( scalar @ARGV == 1 ) || die "Usage: gen_teams.pl <namesfile>\n";

my ($namesfile) = $ARGV[0];
my ($first_record) = 1;
my ($skip) = 0;
my ($input, $output);
my (@player_names);

my (%positions) = ('OT' =>  6,
		   'OG' =>  7,
		   'CR' =>  8,
		   'TE' =>  5,
		   'WR' =>  4,
		   'HB' =>  2,
		   'FB' =>  3,
		   'QB' =>  1,
		   'DE' => 10,
		   'DT' =>  9,
		   'NT' =>  9,
		   'LB' => 11,
		   'CB' => 12,
		   'DB' => 13,
		   'KI' => 14 );

#                                                                Home Jersey     Home Letters   Visiting Jersey Visiting Letters
my (%teams) = ( 'ual' => [ 'Alabama',        'Crimson Tide',    [  9,  0,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  9,  0,  0 ] ],
		'uar' => [ 'Arkansas',       'Razorbacks',      [ 12,  1,  3 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  1,  3 ] ],
		'uaz' => [ 'Arizona',        'Sun Devils',      [  8,  0,  0 ], [ 15, 13,  0 ], [ 15, 15, 15 ], [  8,  0,  0 ] ],
		'uca' => [ 'California',     'Golden Bears',    [  1,  1,  7 ], [ 15, 13,  1 ], [ 15, 15, 15 ], [  1,  1,  7 ] ],
		'uco' => [ 'Colorado',       'Buffalos',        [  0,  0,  0 ], [ 12, 11,  7 ], [ 12, 12, 12 ], [  0,  0,  0 ] ],
		'uct' => [ 'Connecticut',    'Huskies',         [  0,  2,  6 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  0,  2,  6 ] ],
		'ude' => [ 'Delaware',       'Blue Hens',       [  4,  6, 14 ], [ 15, 15,  0 ], [ 15, 15, 15 ], [  4,  6, 14 ] ],
	 	'ufl' => [ 'Florida',        'Gators',          [  0,  2, 10 ], [ 15,  4,  0 ], [ 15, 15, 15 ], [  0,  2, 10 ] ],
		'uga' => [ 'Georgia',        'Bulldogs',        [ 15,  0,  0 ], [  0,  0,  0 ], [ 15, 15, 15 ], [ 15,  0,  0 ] ],
		'uid' => [ 'Idaho',          'Vandals',         [  0,  0,  0 ], [ 12, 11,  7 ], [ 12, 12, 12 ], [  0,  0,  0 ] ],
		'uil' => [ 'Illinois',       'Fighting Illini', [ 15,  6,  0 ], [  0,  3,  6 ], [ 15, 15, 15 ], [  0,  3,  6 ] ],
		'uin' => [ 'Indiana',        'Hoosiers',        [  9,  0,  0 ], [ 15, 15, 12 ], [ 15, 15, 12 ], [  9,  0,  0 ] ],
		'uia' => [ 'Iowa',           'Hawkeyes',        [  0,  0,  0 ], [ 12, 11,  3 ], [ 15, 15, 15 ], [  0,  0,  0 ] ],
		'uks' => [ 'Kansas',         'Jayhawks',        [  0,  2, 12 ], [ 14,  0,  0 ], [ 15, 15, 15 ], [  0,  2, 12 ] ],
		'uky' => [ 'Kentucky',       'Wildcats',        [  0,  4,  7 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  0,  4,  7 ] ],
		'ula' => [ 'Louisiana',      'Ragin Cajuns',    [  4,  1,  7 ], [ 15, 13,  2 ], [ 15, 15, 15 ], [  4,  1,  7 ] ],
		'uma' => [ 'Massachusetts',  'Minutemen',       [  8,  0,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  8,  0,  0 ] ],
		'umd' => [ 'Maryland',       'Terrapins',       [ 12,  1,  2 ], [  0,  0,  0 ], [ 15, 15, 15 ], [  0,  0,  0 ] ], # Also Gold: 15, 13, 1
		'ume' => [ 'Maine',          'Black Bears',     [  0,  2,  4 ], [  7, 11, 14 ], [ 15, 15, 15 ], [  0,  2,  4 ] ],
		'umi' => [ 'Michigan',       'Wolverines',      [  0,  3,  6 ], [ 15, 13,  3 ], [ 15, 15, 15 ], [  0,  3,  6 ] ],
		'umn' => [ 'Minnesota',      'Golden Gophers',  [  8,  0,  0 ], [ 15, 13,  0 ], [ 15, 15, 15 ], [  8,  0,  0 ] ],
		'umo' => [ 'Missouri',       'Tigers',          [  0,  0,  0 ], [ 15, 12,  3 ], [ 15, 15, 15 ], [  0,  0,  0 ] ],
		'ums' => [ 'Mississippi',    'Rebels',          [ 12,  1,  2 ], [  0,  2,  6 ], [ 15, 15, 15 ], [ 12,  1,  2 ] ],
		'umt' => [ 'Montana',        'Grizzlies',       [  6,  0,  3 ], [  9,  9,  9 ], [  9,  9,  9 ], [  6,  0,  3 ] ],
		'unc' => [ 'North Carolina', 'Tarheels',        [  5, 10, 13 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  5, 10, 13 ] ],
		'und' => [ 'North Dakota',   'Fighting Sioux',  [  0, 10,  0 ], [  0,  0,  0 ], [ 15, 15, 15 ], [  0, 10,  0 ] ],
		'une' => [ 'Nebraska',       'Corn Huskers',    [ 15,  2,  0 ], [ 15, 15, 13 ], [ 15, 15, 13 ], [ 15,  2,  0 ] ],
		'unh' => [ 'New Hampshire',  'Big Green',       [  0,  6,  3 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  0,  6,  3 ] ],
		'unj' => [ 'New Jersey',     'Scarlet Knights', [ 12,  0,  1 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  0,  1 ] ],
		'unm' => [ 'New Mexico',     'Lobos',           [ 13,  0,  3 ], [ 12, 12, 12 ], [ 12, 12, 12 ], [ 13,  0,  3 ] ],
		'unv' => [ 'Nevada',         'Wolf Pack',       [  0,  0,  8 ], [ 12, 12, 12 ], [ 12, 12, 12 ], [  0,  0,  8 ] ],
		'uny' => [ 'New York',       'Bobcats',         [  4,  2,  6 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  4,  2,  6 ] ],
		'uoh' => [ 'Ohio',           'Buckeyes',        [ 15,  2,  0 ], [ 10, 10, 10 ], [ 10, 10, 10 ], [ 15,  2,  0 ] ],
		'uok' => [ 'Oklahoma',       'Sooners',         [  9,  0,  1 ], [ 15, 15, 13 ], [ 15, 15, 13 ], [  9,  0,  1 ] ],
		'uor' => [ 'Oregon',         'Ducks',           [  0,  6,  6 ], [ 15, 13,  0 ], [ 15, 15, 15 ], [  0,  6,  6 ] ],
		'upa' => [ 'Pennsylvania',   'Nittany Lions',   [  1,  2,  5 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [  1,  2,  5 ] ],
		'uri' => [ 'Rhode Island',   'Rams',            [  8, 12, 15 ], [  0,  0,  8 ], [ 15, 15, 15 ], [  8, 12, 15 ] ],
		'usc' => [ 'South Carolina', 'Gamecocks',       [  8,  2,  3 ], [  0,  0,  0 ], [ 15, 15, 15 ], [  0,  0,  0 ] ],
		'usd' => [ 'South Dakota',   'Coyotes',         [ 14,  4,  3 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 14,  4,  3 ] ],
		'utn' => [ 'Tennessee',      'Volunteers',      [ 15,  7,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 15,  7,  0 ] ],
		'utx' => [ 'Texas',          'Longhorns',       [ 12,  5,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  5,  0 ] ],
		'uut' => [ 'Utah',           'Utes',            [ 12,  0,  0 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  0,  0 ] ],
		'uva' => [ 'Virginia',       'Cavaliers',       [ 15,  6,  0 ], [  0,  0,  8 ], [ 15, 15, 15 ], [  0,  0,  8 ] ],
		'uvt' => [ 'Vermont',        'Catamounts',      [  0,  6,  3 ], [ 12, 12,  0 ], [ 15, 15, 15 ], [  0,  6,  3 ] ],
		'uwa' => [ 'Washington',     'Cougars',         [  9,  1,  3 ], [  6,  6,  7 ], [ 15, 15, 15 ], [  9,  1,  3 ] ],
		'uwi' => [ 'Wisconsin',      'Badgers',         [ 12,  1,  2 ], [ 15, 15, 15 ], [ 15, 15, 15 ], [ 12,  1,  2 ] ],
		'uwv' => [ 'West Virginia',  'Mountaineers',    [ 15, 12,  0 ], [  0,  3,  6 ], [ 15, 15, 15 ], [  0,  3,  6 ] ],
		'uwy' => [ 'Wyoming',        'Cowboys',         [  4,  2,  2 ], [ 15, 12,  2 ], [ 15, 15, 15 ], [  4,  2,  2 ] ] );




sub compare {

    my ($player_number0, $player_name0, $player_pos0, $player_rating0) = @{ $_[0] };
    my ($player_number1, $player_name1, $player_pos1, $player_rating1) = @{ $_[1] };
    my ($retval);

    if ( $positions{$player_pos0} < $positions{$player_pos1} ) {

	$retval = -1;
    }
    elsif ( $positions{$player_pos0} > $positions{$player_pos1} ) {

	$retval = 1;
    }
    else {

	if    ( $player_rating0 < $player_rating1 ) { $retval =  1; }
	elsif ( $player_rating0 > $player_rating1 ) { $retval = -1; }
	else                                        { $retval =  0; }
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

sub sort_players {

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


sub clear_selections {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        $player->[5] = 0;
    }
}


sub find_best_quarterback {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "QB" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_halfback {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "HB" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_fullback {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "FB" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_center {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "CR" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_offensive_guard {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "OG" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_offensive_tackle {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "OT" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_tight_end {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "TE" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_wide_receiver {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "WR" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_defensive_tackle {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "DT" ||
             $player->[2] eq "NT"    ) {

            if ( $player->[5] == 0 ) {

                $player->[5] = 1;

                return $player;
            }
        }
    }
}

sub find_best_defensive_end {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "DE" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_linebacker {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "LB" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_cornerback {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "CB" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}

sub find_best_safety {

    my (@players) = @{ $_[0] };

    foreach $player (@players) {

        if ( $player->[2] eq "DB" && $player->[5] == 0 ) {

            $player->[5] = 1;

            return $player;
        }
    }
}


sub select_offense_lineup {

    my (@players) = @{ $_[0] };
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    my $quarterback  = find_best_quarterback(      \@players );
    my $halfback     = find_best_halfback(         \@players );
    my $fullback     = find_best_fullback(         \@players );
    my $center       = find_best_center(           \@players );
    my $left_guard   = find_best_offensive_guard(  \@players );
    my $right_guard  = find_best_offensive_guard(  \@players );
    my $left_tackle  = find_best_offensive_tackle( \@players );
    my $right_tackle = find_best_offensive_tackle( \@players );
    my $tight_end    = find_best_tight_end(        \@players );
    my $split_end    = find_best_wide_receiver(    \@players );
    my $flanker      = find_best_wide_receiver(    \@players );

    # OT  OG  CR  OG  OT  TE  SE  HB  FB  FL  QB
    $lineup[ 0] = $left_tackle;
    $lineup[ 1] = $left_guard;
    $lineup[ 2] = $center;
    $lineup[ 3] = $right_guard;
    $lineup[ 4] = $right_tackle;
    $lineup[ 5] = $tight_end;
    $lineup[ 6] = $split_end;
    $lineup[ 7] = $halfback;
    $lineup[ 8] = $fullback;
    $lineup[ 9] = $flanker;
    $lineup[10] = $quarterback;

    clear_selections( \@players );

    return \@lineup;
}


sub select_34defense_lineup {

    my (@players) = @{ $_[0] };
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    my $nose_tackle   = find_best_defensive_tackle( \@players );
    my $left_end      = find_best_defensive_end(    \@players );
    my $right_end     = find_best_defensive_end(    \@players );
    my $left_olb      = find_best_linebacker(       \@players );
    my $left_ilb      = find_best_linebacker(       \@players );
    my $right_ilb     = find_best_linebacker(       \@players );
    my $right_olb     = find_best_linebacker(       \@players );
    my $left_corner   = find_best_cornerback(       \@players );
    my $right_corner  = find_best_cornerback(       \@players );
    my $free_safety   = find_best_safety(           \@players );
    my $strong_safety = find_best_safety(           \@players );

    # DE  NT  DE  LB  LB  LB  LB  CB  DB  DB  CB
    $lineup[ 0] = $left_end;
    $lineup[ 1] = $nose_tackle;
    $lineup[ 2] = $right_end;
    $lineup[ 3] = $left_olb;
    $lineup[ 4] = $left_ilb;
    $lineup[ 5] = $right_ilb;
    $lineup[ 6] = $right_olb;
    $lineup[ 7] = $left_corner;
    $lineup[ 8] = $free_safety;
    $lineup[ 9] = $strong_safety;
    $lineup[10] = $right_corner;

    clear_selections( \@players );

    return \@lineup;
}


sub select_43defense_lineup {

    my (@players) = @{ $_[0] };
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    my $left_tackle   = find_best_defensive_tackle( \@players );
    my $right_tackle  = find_best_defensive_tackle( \@players );
    my $left_end      = find_best_defensive_end(    \@players );
    my $right_end     = find_best_defensive_end(    \@players );
    my $left_olb      = find_best_linebacker(       \@players );
    my $middle_lb     = find_best_linebacker(       \@players );
    my $right_olb     = find_best_linebacker(       \@players );
    my $left_corner   = find_best_cornerback(       \@players );
    my $right_corner  = find_best_cornerback(       \@players );
    my $free_safety   = find_best_safety(           \@players );
    my $strong_safety = find_best_safety(           \@players );

    # DE  DT  DT  DE  LB  LB  LB  CB  DB  DB  CB
    $lineup[ 0] = $left_end;
    $lineup[ 1] = $left_tackle;
    $lineup[ 2] = $right_tackle;
    $lineup[ 3] = $right_end;
    $lineup[ 4] = $left_olb;
    $lineup[ 5] = $middle_lb;
    $lineup[ 6] = $right_olb;
    $lineup[ 7] = $left_corner;
    $lineup[ 8] = $free_safety;
    $lineup[ 9] = $strong_safety;
    $lineup[10] = $right_corner;

    clear_selections( \@players );

    return \@lineup;
}


sub add_player_to_ranked_list {

    my ($list)   = $_[0];
    my ($player) = $_[1];
    my ($size)   = $_[2];

    for ( $i = 0; $i < $size; $i++ ) {

        if ( $player != 0 ) {

            if ( $list->[$i] == 0 ) {

                $list->[$i] = $player;

                $player = 0;
            }
            else {

                if ( $player->[3] > $list->[$i]->[3] ) {

                    my $x;

                    $x          = $list->[$i];
                    $list->[$i] = $player;
                    $player     = $x;
                }
            }
        }
    }
}

sub select_kickoff_lineup {

    my (@players) = @{ $_[0] };
    my ($kicker)  = $_[1];
    my (@big)     = ( 0, 0, 0, 0, 0, 0 );
    my (@fast)    = ( 0, 0, 0, 0 );
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    foreach $player (@players) {

	if ( $player->[2] eq "FB" ||
	     $player->[2] eq "TE" ||
	     $player->[2] eq "LB"    ) {

            add_player_to_ranked_list( \@big, $player, 6 );
	}
    }

    foreach $player (@players) {

	if ( $player->[2] eq "HB" ||
	     $player->[2] eq "WR" ||
	     $player->[2] eq "CB" ||
	     $player->[2] eq "DB"    ) {

            add_player_to_ranked_list( \@fast, $player, 4 );
	}
    }

    # SP  SP  SZ  SZ  SZ  SZ  SZ  SZ  SP  SP  KI
    $lineup[ 0] = $fast[0];
    $lineup[ 1] = $fast[3];
    $lineup[ 2] =  $big[5];
    $lineup[ 3] =  $big[3];
    $lineup[ 4] =  $big[0];
    $lineup[ 5] =  $big[1];
    $lineup[ 6] =  $big[2];
    $lineup[ 7] =  $big[4];
    $lineup[ 8] = $fast[2];
    $lineup[ 9] = $fast[1];
    $lineup[10] = $kicker;

    return \@lineup;
}


sub select_punt_lineup {

    my (@players) = @{ $_[0] };
    my ($punter)  =    $_[1];
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    my $center       = find_best_center(           \@players );
    my $left_guard   = find_best_offensive_guard(  \@players );
    my $right_guard  = find_best_offensive_guard(  \@players );
    my $left_tackle  = find_best_offensive_tackle( \@players );
    my $right_tackle = find_best_offensive_tackle( \@players );
    my $left_end     = find_best_tight_end(        \@players );
    my $right_end    = find_best_tight_end(        \@players );
    my $left_gunner  = find_best_wide_receiver(    \@players );
    my $right_gunner = find_best_wide_receiver(    \@players );
    my $halfback     = find_best_halfback(         \@players );

    # TE  OT  OG  CR  OG  OT  TE  WR  HB  WR  PU
    $lineup[ 0] = $left_end;
    $lineup[ 1] = $left_tackle;
    $lineup[ 2] = $left_guard;
    $lineup[ 3] = $center;
    $lineup[ 4] = $right_guard;
    $lineup[ 5] = $right_tackle;
    $lineup[ 6] = $right_end;
    $lineup[ 7] = $left_gunner;
    $lineup[ 8] = $halfback;
    $lineup[ 9] = $right_gunner;
    $lineup[10] = $punter;

    clear_selections( \@players );

    return \@lineup;
}


sub select_kickoff_return_lineup {

    my (@players) = @{ $_[0] };
    my (@big)     = ( 0, 0, 0, 0, 0 );
    my (@med)     = ( 0, 0, 0, 0 );
    my (@ret)     = ( 0, 0 );
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    foreach $player (@players) {

	if ( $player->[2] eq "CR" ||
	     $player->[2] eq "OG" ||
	     $player->[2] eq "OT" ||
	     $player->[2] eq "DE" ||
	     $player->[2] eq "DT" ||
	     $player->[2] eq "NT"    ) {

            add_player_to_ranked_list( \@big, $player, 5 );
	}
    }

    foreach $player (@players) {

	if ( $player->[2] eq "FB" ||
	     $player->[2] eq "TE" ||
	     $player->[2] eq "LB"    ) {

            add_player_to_ranked_list( \@med, $player, 4 );
	}
    }

    foreach $player (@players) {

	if ( $player->[2] eq "HB" ||
	     $player->[2] eq "WR" ||
	     $player->[2] eq "CB" ||
	     $player->[2] eq "DB"    ) {

            add_player_to_ranked_list( \@ret, $player, 2 );
	}
    }

    # LG  LG  LG  LG  LG  MD  MD  MD  MD  KR  KR
    $lineup[ 0] = $big[3];
    $lineup[ 1] = $big[2];
    $lineup[ 2] = $big[0];
    $lineup[ 3] = $big[1];
    $lineup[ 4] = $big[4];
    $lineup[ 5] = $med[1];
    $lineup[ 6] = $med[0];
    $lineup[ 7] = $med[2];
    $lineup[ 8] = $med[3];
    $lineup[ 9] = $ret[1];
    $lineup[10] = $ret[0];

    return \@lineup;
}


sub select_fieldgoal_lineup {

    my (@players) = @{ $_[0] };
    my ($kicker)  =    $_[1];
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    my $center       = find_best_center(           \@players );
    my $left_guard   = find_best_offensive_guard(  \@players );
    my $right_guard  = find_best_offensive_guard(  \@players );
    my $left_tackle  = find_best_offensive_tackle( \@players );
    my $right_tackle = find_best_offensive_tackle( \@players );
    my $left_end     = find_best_tight_end(        \@players );
    my $right_end    = find_best_tight_end(        \@players );
    my $left_wing    = find_best_fullback(         \@players );
    my $right_wing   = find_best_fullback(         \@players );
    my $quarterback  = find_best_quarterback(      \@players );

    # TE  OT  OG  CR  OG  OT  TE  FB  FB  QB  KI
    $lineup[ 0] = $left_end;
    $lineup[ 1] = $left_tackle;
    $lineup[ 2] = $left_guard;
    $lineup[ 3] = $center;
    $lineup[ 4] = $right_guard;
    $lineup[ 5] = $right_tackle;
    $lineup[ 6] = $right_end;
    $lineup[ 7] = $left_wing;
    $lineup[ 8] = $right_wing;
    $lineup[ 9] = $quarterback;
    $lineup[10] = $kicker;

    clear_selections( \@players );

    return \@lineup;
}


sub select_punt_return_lineup {

    my (@players) = @{ $_[0] };
    my (@big)     = ( 0, 0, 0, 0, 0, 0 );
    my (@med)     = ( 0, 0 );
    my (@fast)    = ( 0, 0, 0 );
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    foreach $player (@players) {

	if ( $player->[2] eq "LB" ||
	     $player->[2] eq "DE" ||
	     $player->[2] eq "DT" ||
	     $player->[2] eq "NT"    ) {

            add_player_to_ranked_list( \@big, $player, 6 );
	}
    }

    foreach $player (@players) {

	if ( $player->[2] eq "FB" ||
	     $player->[2] eq "TE"    ) {

            add_player_to_ranked_list( \@med, $player, 2 );
	}
    }

    foreach $player (@players) {

	if ( $player->[2] eq "HB" ||
	     $player->[2] eq "WR" ||
	     $player->[2] eq "CB" ||
	     $player->[2] eq "DB"    ) {

            add_player_to_ranked_list( \@fast, $player, 3 );
	}
    }

    # FS  LG  LG  LG  LG  LG  LG  FS  MD  MD  FS
    $lineup[ 0] = $fast[1];
    $lineup[ 1] =  $big[4];
    $lineup[ 2] =  $big[3];
    $lineup[ 3] =  $big[0];
    $lineup[ 4] =  $big[1];
    $lineup[ 5] =  $big[2];
    $lineup[ 6] =  $big[5];
    $lineup[ 7] = $fast[2];
    $lineup[ 8] =  $med[1];
    $lineup[ 9] =  $med[0];
    $lineup[10] = $fast[0];

    return \@lineup;
}

sub find_returner {

    my (@players)    = @{ $_[0] };
    my ($ineligible) =    $_[1];

    my (@best_returner) = ( 0, "", "", 0);

    foreach $player (@players) {

	if ( $player->[2] eq "HB" ||
	     $player->[2] eq "WR" ||
	     $player->[2] eq "CB" ||
	     $player->[2] eq "DB"    ) {

	    if ( $player->[0] != $ineligible       &&
		 $player->[3]  > $best_returner[3]    ) {

		@best_returner = @{ $player };
	    }
	}
    }

    return \@best_returner;
}


sub generate_player {

    my (@player_values);
    my ($player_number) = 0;
    my ($player_pos)    = $_[1];

    while ( $player_number == 0 ) {

	if    ( $player_pos eq "OT" ) { $player_number = int( rand( 20 ) ) + 60; }
	elsif ( $player_pos eq "OG" ) { $player_number = int( rand( 20 ) ) + 60; }
	elsif ( $player_pos eq "CR" ) { $player_number = int( rand( 20 ) ) + 60; }
	elsif ( $player_pos eq "TE" ) { $player_number = int( rand( 10 ) ) + 80; }
	elsif ( $player_pos eq "WR" ) { $player_number = int( rand( 10 ) ) + 80; }
	elsif ( $player_pos eq "HB" ) { $player_number = int( rand( 10 ) ) + 20; }
	elsif ( $player_pos eq "FB" ) { $player_number = int( rand( 10 ) ) + 30; }
	elsif ( $player_pos eq "QB" ) { $player_number = int( rand( 19 ) ) +  1; }
	elsif ( $player_pos eq "DE" ) { $player_number = int( rand( 10 ) ) + 90; }
	elsif ( $player_pos eq "DT" ) { $player_number = int( rand( 10 ) ) + 90; }
	elsif ( $player_pos eq "NT" ) { $player_number = int( rand( 10 ) ) + 90; }
	elsif ( $player_pos eq "LB" ) { $player_number = int( rand( 10 ) ) + 50; }
	elsif ( $player_pos eq "CB" ) { $player_number = int( rand( 20 ) ) + 20; }
	elsif ( $player_pos eq "DB" ) { $player_number = int( rand( 10 ) ) + 40; }
	elsif ( $player_pos eq "KI" ) { $player_number = int( rand( 19 ) ) +  1; }
	else                          { $player_number = int( rand( 99 ) ) +  1; }

	foreach $player (@{ $_[0] }) {

	    @p = @{ $player };

	    if ( $player_number == $p[0] ) {

		$player_number = 0;
	    }
	}
    }

    my ($player_name)   = pop @player_names;
    my ($player_rating) = (int( rand( 41 ) ) + 10) / 10;

    my ($player_title) = int( rand( 4 ) );

    if ( $player_title == 0 ) { $player_title = "Freshman";  }
    if ( $player_title == 1 ) { $player_title = "Sophomore"; }
    if ( $player_title == 2 ) { $player_title = "Junior";    }
    if ( $player_title == 3 ) { $player_title = "Senior";    }

    @player_values = ($player_number, $player_name, $player_pos, $player_rating, $player_title, 0);

    push @{ $_[0] }, [ @player_values ];
}


sub print_lineup {

    my ($label)  =    $_[0];
    my (@lineup) = @{ $_[1] };

    printf $output "%s %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
    $label,
    $lineup[ 0]->[0],
    $lineup[ 1]->[0],
    $lineup[ 2]->[0],
    $lineup[ 3]->[0],
    $lineup[ 4]->[0],
    $lineup[ 5]->[0],
    $lineup[ 6]->[0],
    $lineup[ 7]->[0],
    $lineup[ 8]->[0],
    $lineup[ 9]->[0],
    $lineup[10]->[0];
}


sub generate_team {

    my (@players);
    my (@team_values) = @{ $_[0] };
    my ($team, $team_name, $hj, $hl, $vj, $vl) = @team_values;
    my ($defense);

    $team_filename = $team_abbr.".team";

    if   ( rand( 100 ) >= 50 ) { $defense = 43 }
    else                       { $defense = 34 }

    generate_player( \@players, "CB" );
    generate_player( \@players, "CB" );
    generate_player( \@players, "CB" );
    generate_player( \@players, "CB" );
    generate_player( \@players, "CR" );
    generate_player( \@players, "CR" );
    generate_player( \@players, "CR" );
    generate_player( \@players, "DB" );
    generate_player( \@players, "DB" );
    generate_player( \@players, "DB" );
    generate_player( \@players, "DE" );
    generate_player( \@players, "DE" );
    generate_player( \@players, "DE" );
    generate_player( \@players, "FB" );
    generate_player( \@players, "FB" );
    generate_player( \@players, "HB" );
    generate_player( \@players, "HB" );
    generate_player( \@players, "LB" );
    generate_player( \@players, "LB" );
    generate_player( \@players, "LB" );
    generate_player( \@players, "LB" );
    generate_player( \@players, "LB" );
    generate_player( \@players, "OG" );
    generate_player( \@players, "OG" );
    generate_player( \@players, "OG" );
    generate_player( \@players, "OT" );
    generate_player( \@players, "OT" );
    generate_player( \@players, "OT" );
    generate_player( \@players, "QB" );
    generate_player( \@players, "QB" );
    generate_player( \@players, "QB" );
    generate_player( \@players, "TE" );
    generate_player( \@players, "TE" );
    generate_player( \@players, "TE" );
    generate_player( \@players, "WR" );
    generate_player( \@players, "WR" );
    generate_player( \@players, "WR" );
    generate_player( \@players, "WR" );

    if ( $defense == 34 ) {

	generate_player( \@players, "LB" );
	generate_player( \@players, "LB" );
	generate_player( \@players, "NT" );
	generate_player( \@players, "NT" );
	generate_player( \@players, "NT" );
    }

    if ( $defense == 43 ) {

	generate_player( \@players, "DE" );
	generate_player( \@players, "DT" );
	generate_player( \@players, "DT" );
	generate_player( \@players, "DT" );
	generate_player( \@players, "DT" );
    }

    generate_player( \@players, "KI" ); # Punter - index 43
    generate_player( \@players, "KI" ); # Kicker - index 44

    # kicking stats...
    my @punter = @{ $players[43] };
    my @kicker = @{ $players[44] };
    my $punt_distance = (($punter[3] / 5.0) * 20) + 30;
    my $fg_accuracy   = (($kicker[3] / 5.0) * 35) + 65;

    sort_players( \@players );

    print "Creating $team_filename for $team $team_name\n";

    open( $output, ">$team_filename" ) || die "Cannot open team file <$team_filename> for writing.\n";

    # Team Name
    print $output ".NA \"$team\"\n";

    # Kicking Player and Average
    my $fg_attempts = int( rand( 31 ) ) + 20;
    my $fg_made     = int( $fg_attempts * ($fg_accuracy / 100) );

    printf $output ".PU %2d %4.1f\n", $punter[0], $punt_distance;           # NFL Average: 30 - 50
    printf $output ".FG %2d %2d %2d\n", $kicker[0], $fg_made, $fg_attempts; # NFL Average: 20 - 50 att, 65-100%

    # Returning Player and *Team* Average
    my $returner = find_returner( \@players, 0              );
    my $ret_back = find_returner( \@players, $returner->[0] );

    printf $output ".KR %2d %4.1f\n", $returner->[0], rand( 15 ) + 15; # NFL Average: 15 - 30
    printf $output ".PR %2d %4.1f\n", $returner->[0], rand( 10 ) + 5;  # NFL Average:  5 - 15

    # Jersey Colors
    printf $output ".HJ %2d %2d %2d\n", $hj->[0], $hj->[1], $hj->[2];
    printf $output ".HL %2d %2d %2d\n", $hl->[0], $hl->[1], $hl->[2];
    printf $output ".VJ %2d %2d %2d\n", $vj->[0], $vj->[1], $vj->[2];
    printf $output ".VL %2d %2d %2d\n", $vl->[0], $vl->[1], $vl->[2];

    print $output ".HF \"$team_name Home Field\" O N\n";
    print $output ".ND $defense\n";
    print $output ".PL\n";

    foreach $player (@players) {

	@player_values = @{ $player };

	my $player_number   =     $player_values[0];
	my $player_name     = '"'.$player_values[1].'"';
	my $player_position =     $player_values[2];
	my $player_rating   =     $player_values[3];
	my $player_title    =     $player_values[4];


	printf $output "%2d %-25s %s %3.1f  \$ %s\n", $player_number, $player_name, $player_position, $player_rating, $player_title;
    }

    my @lineup = @{ select_offense_lineup( \@players ) };

    print_lineup( ".LO", \@lineup );

    if ( $defense == 34 ) {

        my @lineup = @{ select_34defense_lineup( \@players ) };

        print_lineup( ".LD", \@lineup );
    }

    if ( $defense == 43 ) {

        my @lineup = @{ select_43defense_lineup( \@players ) };

        print_lineup( ".LD", \@lineup );
    }

    my @lineup = @{ select_kickoff_lineup( \@players, \@kicker ) };

    print_lineup( ".LK", \@lineup );

    my @lineup = @{ select_punt_lineup( \@players, \@punter ) };

    print_lineup( ".LP", \@lineup );

    my @lineup = @{ select_kickoff_return_lineup( \@players ) };

    print_lineup( ".LR", \@lineup );

    my @lineup = @{ select_punt_return_lineup( \@players ) };

    print_lineup( ".LQ", \@lineup );

    my @lineup = @{ select_fieldgoal_lineup( \@players, \@kicker ) };

    print_lineup( ".LF", \@lineup );

    print $output ".EN\n";

    close( $output );
}


open( $input, "<$namesfile" ) || die "Cannot open names file <$namesfile>\n";

while ( <$input> ) {

    chomp;

    push @player_names, $_;
}

close( $input );

foreach $team_abbr (sort keys %teams) {

    @team_values = @{ $teams{$team_abbr} };

    generate_team( \@team_values );
}

open( $output, ">$namesfile" ) || die "Cannot open names file <$namesfile> for writing.\n";

foreach $name (@player_names) {

    print $output "$name\n";
}

close( $output );

exit;


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
#          6   7   8
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
