#!/usr/bin/perl
#
# Reads filled in schedule.csv file and calculates
# Overall, Division and Head-To-Head records as well
# as scoring totals.
use File::Basename;

my ($location) = (fileparse( $0 ))[1];

my ($stats_program)  = $location . "get_stats_by_type";

my (@files) = ( 'ual', 'uar', 'uaz', 'uca', 'uco', 'uct', 'ude', 'ufl',
                'uga', 'uid', 'uil', 'uin', 'uia', 'uks', 'uky', 'ula',
                'uma', 'umd', 'ume', 'umi', 'umn', 'umo', 'ums', 'umt',
                'unc', 'und', 'une', 'unh', 'unj', 'unm', 'unv', 'uny',
                'uoh', 'uok', 'uor', 'upa', 'uri', 'usc', 'usd', 'utn',
                'utx', 'uut', 'uva', 'uvt', 'uwa', 'uwi', 'uwv', 'uwy' );

my (@categories) = ( 'PassYards', 'PassTD', 'RushYards', 'RushTD', 'RecYards', 'RecTD', 'Tackles', 'Sacks', 'Ints', );

my (%types) = ( 'PassYards' => 'A',
                'PassTD'    => 'A',
                'RushYards' => 'B',
                'RushTD'    => 'B',
                'RecYards'  => 'C',
                'RecTD'     => 'C',
                'Tackles'   => 'D',
                'Sacks'     => 'E',
                'Ints'      => 'F' );

my (%indexes) = ( 'PassYards' => 6,
                  'PassTD'    => 8,
                  'RushYards' => 4,
                  'RushTD'    => 6,
                  'RecYards'  => 4,
                  'RecTD'     => 6,
                  'Tackles'   => 3,
                  'Sacks'     => 3,
                  'Ints'      => 3 );

my (%lists);


sub print_list {

    my (@list) = @{ $_[0] };
    my ($idx)  =    $_[1];

    foreach $entry (@list) {

        printf "%s %-20s %-15s %4d\n",
        $entry->[0],
        $entry->[1],
        $entry->[2],
        $entry->[$idx];
    }
}

sub rank_entry {

    my ($entry) = $_[1];
    my ($idx)   = $_[2];

    for ( $i = 0; $i <= $#{ $_[0] }; $i++ ) {

        if ( $entry != 0 ) {

            if ( $_[0]->[$i] == 0 ) {

                $_[0]->[$i] = $entry;

                $entry = 0;
            }
            else {

                if ( $entry->[$idx] > $_[0]->[$i]->[$idx] ) {

                    my $x;

                    $x          = $_[0]->[$i];
                    $_[0]->[$i] = $entry;
                    $entry      = $x;
                }
            }
        }
    }
}

sub get_stats {

    my ($stats_filename) = $_[0].".stat";
    my ($category) = $_[1];
    my ($input);

    open( $input, "$stats_program $stats_filename $types{$category}|");

    while (<$input>) {

	chomp;

        my (@fields)  = split( /;/ );

        rank_entry( $lists{$category}, \@fields, $indexes{$category} );

#        if    ( $category eq "PassYards" ) { rank_entry( \@passing,   \@fields, 6 ); }
#        elsif ( $category eq "PassTD"    ) { rank_entry( \@passing,   \@fields, 8 ); }
#        elsif ( $category eq "RushYards" ) { rank_entry( \@rushing,   \@fields, 4 ); }
#        elsif ( $category eq "RushTD"    ) { rank_entry( \@rushing,   \@fields, 6 ); }
#        elsif ( $category eq "RecYards"  ) { rank_entry( \@receiving, \@fields, 4 ); }
#        elsif ( $category eq "RecTD"     ) { rank_entry( \@receiving, \@fields, 6 ); }
#        elsif ( $category eq "Tackles"   ) { rank_entry( \@tackling,  \@fields, 3 ); }
#        elsif ( $category eq "Sacks"     ) { rank_entry( \@sacking,   \@fields, 3 ); }
#        elsif ( $category eq "Ints"      ) { rank_entry( \@picking,   \@fields, 3 ); }
    }

    close( $input );
}

foreach $category (@categories) {

    $lists{$category} = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
}

foreach $file (@files) {

    foreach $category (@categories) {

        get_stats( $file, $category );
    }
}


foreach $category (@categories) {

    if    ( $category eq "PassYards" ) { print "Passing Yards\n"; }
    elsif ( $category eq "PassTD"    ) { print "Passing TD\n"; }
    elsif ( $category eq "RushYards" ) { print "Rushing Yards\n"; }
    elsif ( $category eq "RushTD"    ) { print "Rushing TD\n"; }
    elsif ( $category eq "RecYards"  ) { print "Receiving Yards\n"; }
    elsif ( $category eq "RecTD"     ) { print "Receiving TD\n"; }
    elsif ( $category eq "Tackles"   ) { print "Tackles\n"; }
    elsif ( $category eq "Sacks"     ) { print "Sacks\n"; }
    elsif ( $category eq "Ints"      ) { print "Interceptions\n"; }

    print_list( $lists{$category}, $indexes{$category} );

    print "\n";
}

exit;

print "Passing:\n";

print_list( $lists{""}, $indexes{""} );

print "\n";
print "Rushing:\n";

print_list( \@rushing, 4 );

print "\n";
print "Receiving:\n";

print_list( \@receiving, 4 );

print "\n";
print "Tackles:\n";

print_list( \@tackling, 3 );

print "\n";
print "Sacks:\n";

print_list( \@sacking, 3 );

print "\n";
print "Interceptions:\n";

print_list( \@picking, 3 );

print "\n";

exit;
