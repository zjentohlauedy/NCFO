#!/usr/bin/perl
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.
use File::Basename;

my ($location) = (fileparse( $0 ))[1];

my ($record_program) = $location . "get_record";
my ($stats_program)  = $location . "get_player_stats";

my (@conferences) = ( 'New England', 'Atlantic', 'Southeast', 'Great Lake', 'Southwest', 'Northwest', 'Midwest', 'South' );



my (%teams) = ( 'New England' => [ 'uct', 'ume', 'uma', 'unh', 'uri', 'uvt' ],
		'Atlantic'    => [ 'ude', 'umd', 'unj', 'uny', 'uva', 'uwv' ],
		'Southeast'   => [ 'ual', 'ufl', 'uga', 'unc', 'usc', 'utn' ],
		'Great Lake'  => [ 'uil', 'uin', 'uky', 'umi', 'uoh', 'upa' ],
		'Southwest'   => [ 'uaz', 'uca', 'uco', 'unv', 'unm', 'uut' ],
		'Northwest'   => [ 'uid', 'umt', 'une', 'uor', 'uwa', 'uwy' ],
		'Midwest'     => [ 'uia', 'uks', 'umn', 'und', 'usd', 'uwi' ],
		'South'       => [ 'uar', 'ula', 'ums', 'umo', 'uok', 'utx' ] );


sub get_roster {

    my ($stats_filename) = $_[0].".stat";
    my ($input);

    open( $input, "$stats_program $stats_filename|");

    while (<$input>) {

	print "$_";
    }

    close( $input );
}

sub get_record {

    my ($stats_filename) = $_[0].".stat";
    my (@details);

    if ( -e $stats_filename ) {

	@details = split( ",", `$record_program $stats_filename` );
    }
    else {

	@details = ( $_[0], 0, 0, 0, 0, 0 );
    }

    return \@details;
}

foreach $conference (@conferences) {

    print "$conference\n";
    print "\n";

    foreach $team ( @{ $teams{$conference} } ) {

	my ($record) = get_record( $team );

	printf "%s  %2d - %2d - %2d\n", $record->[0], $record->[1], $record->[2], $record->[3];
	print "\n";

	get_roster( $team );

	print "\n";
    }
}

exit;
