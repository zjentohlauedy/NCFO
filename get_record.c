#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"

int main( int argc, char *argv[] )
{
     hcstats_s *statsFile;
     char      *filename;
     size_t     filesize;
     int        fd;


     if ( argc < 2 )
     {
	  printf( "Usage: %s <statsfile>.\n", argv[0] );

	  return EXIT_SUCCESS;
     }

     if ( (statsFile = readStatsFile( argv[1] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[1] );

          return EXIT_FAILURE;
     }

     int points_scored  = 0;
     int points_allowed = 0;

     points_scored += (statsFile->team_stats[0].q1_points[0]<<8) + statsFile->team_stats[0].q1_points[1];
     points_scored += (statsFile->team_stats[0].q2_points[0]<<8) + statsFile->team_stats[0].q2_points[1];
     points_scored += (statsFile->team_stats[0].q3_points[0]<<8) + statsFile->team_stats[0].q3_points[1];
     points_scored += (statsFile->team_stats[0].q4_points[0]<<8) + statsFile->team_stats[0].q4_points[1];
     points_scored += (statsFile->team_stats[0].ot_points[0]<<8) + statsFile->team_stats[0].ot_points[1];

     points_allowed += (statsFile->team_stats[0].q1_allowed[0]<<8) + statsFile->team_stats[0].q1_allowed[1];
     points_allowed += (statsFile->team_stats[0].q2_allowed[0]<<8) + statsFile->team_stats[0].q2_allowed[1];
     points_allowed += (statsFile->team_stats[0].q3_allowed[0]<<8) + statsFile->team_stats[0].q3_allowed[1];
     points_allowed += (statsFile->team_stats[0].q4_allowed[0]<<8) + statsFile->team_stats[0].q4_allowed[1];
     points_allowed += (statsFile->team_stats[0].ot_allowed[0]<<8) + statsFile->team_stats[0].ot_allowed[1];

     printf( "%s,%d,%d,%d,%d,%d\n", statsFile->name, statsFile->wins[0], statsFile->losses[0], statsFile->ties[0], points_scored, points_allowed );

     free( statsFile );

     return EXIT_SUCCESS;
}
