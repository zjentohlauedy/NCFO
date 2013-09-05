#!/usr/bin/perl
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.

( scalar @ARGV == 1 ) || die "Usage: update_teams.pl <namesfile>\n";

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


sub select_kickoff_lineup {

    my (@players) = @{ $_[0] };
    my (@lineup)  = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

    # First the Big Dudes...
    foreach $player (@players) {

	if ( $player->[2] eq "FB" ||
	     $player->[2] eq "TE" ||
	     $player->[2] eq "LB"    ) {

	    my $temp = $player;

	    for ( $i = 0; $i < 6; $i++ ) {

		if ( $temp != 0 ) {

		    if ( @lineup[$i] == 0 ) {

			$lineup[$i] = $temp;

			$temp = 0;
		    }
		    else {

			if ( $temp->[3] > $lineup[$i]->[3] ) {

			    my $x;

			    $x          = $lineup[$i];
			    $lineup[$i] = $temp;
			    $temp       = $x;
			}
		    }
		}
	    }
	}
    }

    # Next the Speedy Dudes...
    foreach $player (@players) {

	if ( $player->[2] eq "HB" ||
	     $player->[2] eq "WR" ||
	     $player->[2] eq "CB" ||
	     $player->[2] eq "DB"    ) {

	    my $temp = $player;

	    for ( $i = 6; $i < 10; $i++ ) {

		if ( $temp != 0 ) {

		    if ( @lineup[$i] == 0 ) {

			$lineup[$i] = $temp;

			$temp = 0;
		    }
		    else {

			if ( $temp->[3] > $lineup[$i]->[3] ) {

			    my $x;

			    $x          = $lineup[$i];
			    $lineup[$i] = $temp;
			    $temp       = $x;
			}
		    }
		}
	    }
	}
    }

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
    my ($player_title)  = "Freshman";

    @player_values = ($player_number, $player_name, $player_pos, $player_rating, $player_title);

    return \@player_values;
}


sub generate_team {

    my (@players);
    my (@team_values) = @{ $_[0] };
    my ($team, $team_name, $hj, $hl, $vj, $vl) = @team_values;
    my ($defense);
    my ($punter, $kicker, $defense);

    $team_filename = $team_abbr.".team";

    open( $input, "<$team_filename" ) || die "Cannot open team file <$team_filename> for reading.\n";

    while ( <$input> ) {

	chomp;

	if ( m/^\.ND/ ) {

	    my (@temp) = split( " +" );

	    $defense = $temp[1];
	}

	if ( m/^\.PU/ ) {

	    my (@temp) = split( " +" );

	    $punter = $temp[1];
	}

	if ( m/^\.FG/ ) {

	    my (@temp) = split( " +" );

	    $kicker = $temp[1];
	}

	if ( m/^ *[0-9]/ ) {

	    my (@temp) = split( "\"" );

	    my ($player_number) = substr( $_,  0,  2 );
	    my ($player_name)   = $temp[1];
	    my ($player_pos)    = substr( $_, 29,  2 );
	    my ($player_rating) = substr( $_, 32,  3 );
	    my ($player_title)  = substr( $_, 39     );

	    push @players, [ $player_number, $player_name, $player_pos, $player_rating, $player_title ];
	}
    }

    close( $input );

    foreach $player (@players) {

	my $potential = 5.0 - $player->[3];

	$player->[3] += (int( rand( $potential * 5 ) ) / 10);

	if ( $player->[0] == $punter ) { $punter = $player; };
	if ( $player->[0] == $kicker ) { $kicker = $player; };

	if ( $player->[4] =~ /Freshman/  ) {

	    $player->[4] = "Sophomore";
	}
	elsif ( $player->[4] =~ /Sophomore/ ) {

	    $player->[4] = "Junior";
	}
	elsif ( $player->[4] =~ /Junior/    ) {

	    $player->[4] = "Senior";
	}
	elsif ( $player->[4] =~ /Senior/    ) {

	    $player->[4] = "Graduate";

	    # set the player's number to 0 so it can be reused
	    $player->[0] = 0;
	}
    }

    for ( $i = 0; $i < (scalar @players); $i++ ) {

	if ( $players[$i]->[4] =~ /Graduate/ ) {

	    my $new_recruit = generate_player( \@players, $players[$i]->[2] );

	    if ( $punter == $players[$i] ) { $punter = $new_recruit; }
	    if ( $kicker == $players[$i] ) { $kicker = $new_recruit; }

	    $players[$i] = $new_recruit;
	}
    }

    my $punt_distance = (($punter->[3] / 5.0) * 20) + 30;
    my $fg_accuracy   = (($kicker->[3] / 5.0) * 35) + 65;

    sort_players( \@players );

    open( $output, ">$team_filename" ) || die "Cannot open team file <$team_filename> for writing.\n";

    # Team Name
    print $output ".NA \"$team\"\n";

    # Kicking Player and Average
    my $fg_attempts = int( rand( 31 ) ) + 20;
    my $fg_made     = int( $fg_attempts * ($fg_accuracy / 100) );

    printf $output ".PU %2d %4.1f\n",   $punter->[0], $punt_distance;           # NFL Average: 30 - 50
    printf $output ".FG %2d %2d %2d\n", $kicker->[0], $fg_made, $fg_attempts; # NFL Average: 20 - 50 att, 65-100%

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

    #                    OT  OG  CR  OG  OT  TE  WR  HB  FB  WR  QB
    printf $output ".LO %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
    $players[14]->[0],
    $players[17]->[0],
    $players[20]->[0],
    $players[18]->[0],
    $players[15]->[0],
    $players[11]->[0],
    $players[ 7]->[0],
    $players[ 3]->[0],
    $players[ 5]->[0],
    $players[ 8]->[0],
    $players[ 0]->[0];

    if ( $defense == 34 ) {

	#                    DE  NT  DE  LB  LB  LB  LB  CB  DB  DB  CB
	printf $output ".LD %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
	$players[26]->[0],
	$players[23]->[0],
	$players[27]->[0],
	$players[29]->[0],
	$players[30]->[0],
	$players[31]->[0],
	$players[32]->[0],
	$players[36]->[0],
	$players[40]->[0],
	$players[41]->[0],
	$players[37]->[0];
    }

    if ( $defense == 43 ) {

	#                    DE  DT  DT  DE  LB  LB  LB  CB  DB  DB  CB
	printf $output ".LD %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
	$players[27]->[0],
	$players[23]->[0],
	$players[24]->[0],
	$players[28]->[0],
	$players[31]->[0],
	$players[32]->[0],
	$players[33]->[0],
	$players[36]->[0],
	$players[40]->[0],
	$players[41]->[0],
	$players[37]->[0];
    }

    my @lineup = @{ select_kickoff_lineup( \@players ) };
    #                    SP  SP  SZ  SZ  SZ  SZ  SZ  SZ  SP  SP  KI
    printf $output ".LK %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
    $lineup[6]->[0],
    $lineup[7]->[0],
    $lineup[0]->[0],
    $lineup[1]->[0],
    $lineup[2]->[0],
    $lineup[3]->[0],
    $lineup[4]->[0],
    $lineup[5]->[0],
    $lineup[8]->[0],
    $lineup[9]->[0],
    $kicker->[   0];

    #                    TE  OT  OG  CR  OG  OT  TE  WR  HB  WR  PU
    printf $output ".LP %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
    $players[12]->[0],
    $players[14]->[0],
    $players[17]->[0],
    $players[20]->[0],
    $players[18]->[0],
    $players[15]->[0],
    $players[11]->[0],
    $players[ 7]->[0],
    $players[ 3]->[0],
    $players[ 8]->[0],
    $punter->[     0];

    if ( $defense == 34 ) {

	#                    OT  OG  CR  OG  OT  LB  LB  LB  TE  KR  KR
	printf $output ".LR %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
	$players[14]->[0],
	$players[17]->[0],
	$players[20]->[0],
	$players[18]->[0],
	$players[15]->[0],
	$players[29]->[0],
	$players[30]->[0],
	$players[31]->[0],
	$players[11]->[0],
	$ret_back->[   0],
	$returner->[   0];

	#                    CB  LB  DE  DT  NT  DE  LB  CB  DB  DB  KR
	printf $output ".LQ %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
	($returner->[0] != $players[36]->[0]) ? $players[36]->[0] : $players[38]->[0],
	$players[29]->[0],
	$players[26]->[0],
	$players[23]->[0],
	$players[24]->[0],
	$players[27]->[0],
	$players[30]->[0],
	$players[37]->[0],
	($returner->[0] != $players[40]->[0]) ? $players[40]->[0] : $players[42]->[0],
	$players[41]->[0],
	$returner->[   0];
    }

    if ( $defense == 43 ) {

	#                    OT  OG  CR  OG  OT  LB  LB  LB  TE  KR  KR
	printf $output ".LR %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
	$players[14]->[0],
	$players[17]->[0],
	$players[20]->[0],
	$players[18]->[0],
	$players[15]->[0],
	$players[31]->[0],
	$players[32]->[0],
	$players[33]->[0],
	$players[11]->[0],
	$ret_back->[   0],
	$returner->[   0];

	#                    CB  LB  DE  DT  DT  DE  LB  CB  DB  DB  KR
	printf $output ".LQ %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
	($returner->[0] != $players[36]->[0]) ? $players[36]->[0] : $players[38]->[0],
	$players[31]->[0],
	$players[27]->[0],
	$players[23]->[0],
	$players[24]->[0],
	$players[28]->[0],
	$players[32]->[0],
	$players[37]->[0],
	($returner->[0] != $players[40]->[0]) ? $players[40]->[0] : $players[42]->[0],
	$players[41]->[0],
	$returner->[   0];
    }

    #                    TE  OT  OG  CR  OG  OT  TE  FB  FB  QB  KI
    printf $output ".LF %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n",
    $players[12]->[0],
    $players[14]->[0],
    $players[17]->[0],
    $players[20]->[0],
    $players[18]->[0],
    $players[15]->[0],
    $players[11]->[0],
    $players[ 5]->[0],
    $players[ 6]->[0],
    $players[ 2]->[0],
    $kicker->[     0];

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
