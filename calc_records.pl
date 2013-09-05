#!/usr/bin/perl
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.

( scalar @ARGV == 1 ) || die "Usage: calc_records.pl <filename>\n";

my ($filename) = $ARGV[0];
my ($first_record) = 1;
my ($skip) = 0;
my ($input);
my (@road_fields, @home_fields);
my (%teams);


my (%divisions) = ( 'Connecticut'   => 1, 'Delaware'      => 2, 'Alabama'        => 3, 'Illinois'     => 4, 'Arizona'    => 5, 'Idaho'      => 6, 'Iowa'         => 7, 'Arkansas'    => 8,
		    'Maine'         => 1, 'Maryland'      => 2, 'Florida'        => 3, 'Indiana'      => 4, 'California' => 5, 'Montana'    => 6, 'Kansas'       => 7, 'Louisiana'   => 8,
		    'Massachusetts' => 1, 'New Jersey'    => 2, 'Georgia'        => 3, 'Kentucky'     => 4, 'Colorado'   => 5, 'Nebraska'   => 6, 'Minnesota'    => 7, 'Mississippi' => 8,
		    'New Hampshire' => 1, 'New York'      => 2, 'North Carolina' => 3, 'Michigan'     => 4, 'Nevada'     => 5, 'Oregon'     => 6, 'North Dakota' => 7, 'Missouri'    => 8,
		    'Rhode Island'  => 1, 'Virginia'      => 2, 'South Carolina' => 3, 'Ohio'         => 4, 'New Mexico' => 5, 'Washington' => 6, 'South Dakota' => 7, 'Oklahoma'    => 8,
		    'Vermont'       => 1, 'West Virginia' => 2, 'Tennessee'      => 3, 'Pennsylvania' => 4, 'Utah'       => 5, 'Wyoming'    => 6, 'Wisconsin'    => 7, 'Texas'       => 8 );

sub update_entry {

#   my (%records) = %{ $_[0] };
    my ($entry)   =    $_[1];
    my ($wins)    =    $_[2];
    my ($losses)  =    $_[3];
    my (@record)  = (0, 0);

    if   ( exists( ${ $_[0] }{$entry} ) ) {

	@record = @{ ${ $_[0] }{$entry} };
    }

    $record[0] += $wins;
    $record[1] += $losses;

    ${ $_[0] }{$entry} = [ @record ];
}


sub update_team {

    my ($team, $scored, $opponent, $allowed, $home) = @_;
    my (%records) = ( );
    my ($won) = ($scored > $allowed) ? 1 : 0;
    my ($wins, $losses);

    # Get the records hash from the teams hash or use the empty one that team
    # is not in the table yet
    if   ( exists( $teams{$team} ) ) {

	%records = %{ $teams{$team} };
    }

    if   ( $won ) { $wins = 1; $losses = 0; }
    else          { $wins = 0; $losses = 1; }

    update_entry( \%records, "Record", $wins,   $losses  );
    update_entry( \%records, "Score",  $scored, $allowed );

    if ( $divisions{$team} == $divisions{$opponent} ) {

	update_entry( \%records, "Division", $wins,   $losses  );
    }

    if   ( $home ) { update_entry( \%records, "Home", $wins,   $losses  ); }
    else           { update_entry( \%records, "Road", $wins,   $losses  ); }

    update_entry( \%records, $opponent, $wins,   $losses  );

    $teams{$team} = { %records };
}


sub process_games {

    my (@road) = (@{$_[0]});
    my (@home) = (@{$_[1]});

    for ( $i = 1; $i < (scalar @home); $i += 2 ) {

	update_team( $road[$i], $road[$i + 1], $home[$i], $home[$i + 1], 0 );
	update_team( $home[$i], $home[$i + 1], $road[$i], $road[$i + 1], 1 );
    }
}


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
	    }

	    @road_fields = ( );
	    @home_fields = ( );
	}
    }
}

close( $input );

foreach $team (sort keys %teams) {

    my (@rec) = @{ $teams{$team}{'Record'} };
    my ($count);

    printf "%-15s %3d-%3d  ", $team, $rec[0], $rec[1];

    @rec = @{ $teams{$team}{'Division'} };

    printf "%2d-%2d  ", $rec[0], $rec[1];

    @rec = @{ $teams{$team}{'Home'} };

    printf "%2d-%2d  ", $rec[0], $rec[1];

    @rec = @{ $teams{$team}{'Road'} };

    printf "%2d-%2d  ", $rec[0], $rec[1];

    @rec = @{ $teams{$team}{'Score'} };

    printf "%4d  %4d\n", $rec[0], $rec[1];

    $count = 0;

    foreach $record (sort keys %{ $teams{$team} }) {

	if ( $record ne "Record"   &&
	     $record ne "Division" &&
	     $record ne "Home"     &&
	     $record ne "Road"     &&
	     $record ne "Score"       ) {

	    my (@totals) = @{ $teams{$team}{$record} };

	    printf "   %15s %1d-%1d", $record, $totals[0], $totals[1];

	    $count++;

	    if ( $count == 3 ) {

		print "\n";

		$count = 0;
	    }
	}
    }

    if ( $count > 0 ) { print "\n"; }

    print "\n";
}
