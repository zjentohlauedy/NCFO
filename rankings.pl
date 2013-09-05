#!/usr/bin/perl
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.

( scalar @ARGV == 1 ) || die "Usage: rankings.pl <filename>\n";

my ($filename) = $ARGV[0];
my ($first_record) = 1;
my ($skip) = 0;
my ($input);
my (@road_fields, @home_fields);


my (@files) = ( 'ual', 'uar', 'uaz', 'uca', 'uco', 'uct', 'ude', 'ufl',
                'uga', 'uid', 'uil', 'uin', 'uia', 'uks', 'uky', 'ula',
                'uma', 'umd', 'ume', 'umi', 'umn', 'umo', 'ums', 'umt',
                'unc', 'und', 'une', 'unh', 'unj', 'unm', 'unv', 'uny',
                'uoh', 'uok', 'uor', 'upa', 'uri', 'usc', 'usd', 'utn',
                'utx', 'uut', 'uva', 'uvt', 'uwa', 'uwi', 'uwv', 'uwy' );


my (%ratings) = (
    'Alabama'        => 0,
    'Arizona'        => 0,
    'Arkansas'       => 0,
    'California'     => 0,
    'Colorado'       => 0,
    'Connecticut'    => 0,
    'Delaware'       => 0,
    'Florida'        => 0,
    'Georgia'        => 0,
    'Idaho'          => 0,
    'Illinois'       => 0,
    'Indiana'        => 0,
    'Iowa'           => 0,
    'Kansas'         => 0,
    'Kentucky'       => 0,
    'Louisiana'      => 0,
    'Maine'          => 0,
    'Maryland'       => 0,
    'Massachusetts'  => 0,
    'Michigan'       => 0,
    'Minnesota'      => 0,
    'Mississippi'    => 0,
    'Missouri'       => 0,
    'Montana'        => 0,
    'Nebraska'       => 0,
    'Nevada'         => 0,
    'New Hampshire'  => 0,
    'New Jersey'     => 0,
    'New Mexico'     => 0,
    'New York'       => 0,
    'North Carolina' => 0,
    'North Dakota'   => 0,
    'Ohio'           => 0,
    'Oklahoma'       => 0,
    'Oregon'         => 0,
    'Pennsylvania'   => 0,
    'Rhode Island'   => 0,
    'South Carolina' => 0,
    'South Dakota'   => 0,
    'Tennessee'      => 0,
    'Texas'          => 0,
    'Utah'           => 0,
    'Vermont'        => 0,
    'Virginia'       => 0,
    'Washington'     => 0,
    'West Virginia'  => 0,
    'Wisconsin'      => 0,
    'Wyoming'        => 0 );

my (%prev_ratings) = %ratings;

sub compare {

    my ($team0)   = $_[0];
    my ($team1)   = $_[1];
    my ($rating0) = $ratings{$team0};
    my ($rating1) = $ratings{$team1};

    if ( $rating0 != $rating1 ) {

        return ($rating0 > $rating1) ? -1 : 1;
    }

    return ($team0 lt $team1) ? -1 : 1;
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


sub update_team {

    my ($team, $scored, $opponent, $allowed, $home) = @_;
    my ($my_rating) = $prev_ratings{$team};
    my ($other_rating) = $prev_ratings{$opponent};

    $ratings{$team} += ($scored - $allowed);

    if ( $scored > $allowed ) {

        $ratings{$team} += 10 + int( $other_rating / 4 );
    }
    elsif ( $scored < $allowed ) {

        $ratings{$team} -= (50 + (($my_rating > $other_rating) ? int( ($my_rating - $other_rating) / 4 ) : 0));
    }
}


sub process_games {

    my (@road) = (@{$_[0]});
    my (@home) = (@{$_[1]});

    for ( $i = 1; $i < (scalar @home); $i += 2 ) {

	update_team( $road[$i], $road[$i + 1], $home[$i], $home[$i + 1], 0 );
	update_team( $home[$i], $home[$i + 1], $road[$i], $road[$i + 1], 1 );
    }
}


sub rate_team {

    my ($filename) = $_[0].".team";
    my ($input);
    my (%players);
    my (@offense);
    my (@defense);
    my ($name);
    my ($off_rating);
    my ($def_rating);
    my ($total_rating);

    open( $input, "<$filename" ) || die "Cannot open input file <$filename>\n";

    while ( <$input> ) {

        chomp;

        if ( $_ =~ /^\.NA/ ) {

            my (@temp) = split( /"/ );

            $name = $temp[1];
        }

        if ( $_ =~ /^\.LO/ ) {

            @offense = split( / +/ );
        }

        if ( $_ =~ /^\.LD/ ) {

            @defense = split( / +/ );
        }

        if ( $_ =~ /^[ 0-9]/ ) {

            my (@fields) = split( / +/ );

            if ( $#fields == 6 ) {

                $players{$fields[0]} = $fields[4];
            }
            else {

                $players{$fields[1]} = $fields[5];
            }
        }
    }

    close( $input );


    my ($total) = 0;

    foreach $player (keys %players) {

        $total += $players{$player};
    }

    $total_rating = ($total / scalar(keys %players));

    $total = 0;

    for ( $i = 1; $i <= $#offense; $i++ ) {

        $total += $players{$offense[$i]};
    }

    $off_rating = ($total / 11);

    $total = 0;

    for ( $i = 1; $i <= $#defense; $i++ ) {

        $total += $players{$defense[$i]};
    }

    $def_rating = ($total / 11);

    $ratings{$name} = ($total_rating) + ($off_rating * 2) + ($def_rating * 2);
}


foreach $file (@files) {

    rate_team( $file );
}

my (@teamlist) = sort keys %ratings;

sort_teams( \@teamlist );

for ( $i = 0; $i <= $#teamlist; $i++ ) {

    $ratings{$teamlist[$i]} = 500 - ($i * 10);
}

%prev_ratings = %ratings;

open( $input, "<$filename" ) || die "Cannot open input file <$filename>\n";

while ( <$input> ) {

    if ( $first_record ) {

	$first_record = 0;
    }
    else {

	chomp;

	if ( scalar @road_fields == 0 ) {

	    @road_fields = split( "," );
	}
	elsif ( scalar @home_fields == 0 ) {

	    @home_fields = split( "," );
	}

	if ( scalar @road_fields > 0  &&
	     scalar @home_fields > 0     ) {

	    # make sure every game has been played for this day
	    $skip = 0;

	    foreach $field (@home_fields) {

		if ( $field eq "" ) { $skip = 1 };
	    }

	    if ( $skip == 0 ) {

		process_games( \@road_fields, \@home_fields );

                %prev_ratings = %ratings;
	    }

	    @road_fields = ( );
	    @home_fields = ( );
	}
    }
}

close( $input );

sort_teams( \@teamlist );

for ( $i = 0; $i < 25; $i++ ) {

    printf "%2d. %s\n", $i + 1, $teamlist[$i];
}

exit;
