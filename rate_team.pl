#!/usr/bin/perl
#

( scalar @ARGV == 1 ) || die "Usage: rate_team.pl <filename>\n";

my ($filename) = $ARGV[0];
my (%players);
my (@offense);
my (@defense);
my ($name);

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

printf "'%s' => [ %6.4f, ", $name, ($total / scalar(keys %players));

$total = 0;

for ( $i = 1; $i <= $#offense; $i++ ) {

    $total += $players{$offense[$i]};
}

printf "%6.4f, ", ($total / 11);

$total = 0;

for ( $i = 1; $i <= $#defense; $i++ ) {

    $total += $players{$defense[$i]};
}

printf "%6.4f ],\n", ($total / 11);

exit;
