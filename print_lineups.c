#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"


static void print_lineup( hclineup_s *hclineup, char *label )
{
     int i;

     printf( "%s ", label );

     for ( i = 0; i < 11; ++i ) printf( "%2d ", hclineup->players[i] );

     printf( "\n" );
}

int main( int argc, char *argv[] )
{
     hcstats_s *statsFile;


     if ( argc < 2 )
     {
	  printf( "Usage: %s <statsfile>.\n", argv[0] );

	  return EXIT_SUCCESS;
     }

     if ( (statsFile = readStatsFile( argv[1] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[1] );

          return EXIT_SUCCESS;
     }

     print_lineup( &(statsFile->lineups[ ln_Offense    ]), ".LO" );
     print_lineup( &(statsFile->lineups[ ln_Defense    ]), ".LD" );
     print_lineup( &(statsFile->lineups[ ln_Kickoff    ]), ".LK" );
     print_lineup( &(statsFile->lineups[ ln_Punt       ]), ".LP" );
     print_lineup( &(statsFile->lineups[ ln_KickReturn ]), ".LR" );
     print_lineup( &(statsFile->lineups[ ln_PuntReturn ]), ".LQ" );
     print_lineup( &(statsFile->lineups[ ln_FieldGoal  ]), ".LF" );

     free( statsFile );

     return EXIT_SUCCESS;
}
