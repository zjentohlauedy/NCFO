#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"


typedef struct
{
     int   attempts;
     int   completions;
     float yards;
     int   touchdowns;
     int   interceptions;

} passing_s;

typedef struct
{
     int   carries;
     float yards;
     int   touchdowns;

} rushing_s;

typedef struct
{
     int   receptions;
     float yards;
     int   touchdowns;

} receiving_s;

typedef struct
{
     passing_s   passing;
     rushing_s   rushing;
     receiving_s receiving;
     int         fumbles;

} offensive_stats_s;

typedef struct
{
     int tackles;
     int sacks;
     int interceptions;
     int fumble_recoveries;

} defensive_stats_s;

typedef struct
{
     int        number;
     char       name[20 + 1];
     position_e position;
     float      rating;

     union
     {
	  offensive_stats_s offense;
	  defensive_stats_s defense;

     } stats;

} player_s;


static void print_offense_header( void )
{
     printf( "      Offense           Rating Att Cmp  Pct.   Yards Avg. TD IN Car  Yards Avg. TD Rec  Yards Avg. TD  F\n" );
     //       65 OT Neman, John          2.2   0   0   0.0%    0.0  0.0  0  0   0    0.0  0.0  0   0    0.0  0.0  0  0
}


static void print_defense_header( void )
{
     printf( "      Defense           Rating Tackles Sacks Int. FR\n" );
     //       93 DE Seals, James         4.8      16     2   0   0
}

static void print_player_stats( player_s *player )
{
     printf( "%2d %s %-20s %3.1f ",
	     player->number,
	     positionName( player->position ),
	     player->name,
	     player->rating );

     if ( player->position >= 8 )
     {
	  defensive_stats_s *defense = &(player->stats.defense);

	  printf( "    %3d    %2d  %2d  %2d\n",
		  defense->tackles,
		  defense->sacks,
		  defense->interceptions,
		  defense->fumble_recoveries );
     }
     else
     {
	  offensive_stats_s *offense = &(player->stats.offense);

	  printf( "%3d %3d %5.1f%% %6.1f %4.1f %2d %2d ",
		  offense->passing.attempts,
		  offense->passing.completions,
		  (offense->passing.attempts > 0) ? (float)offense->passing.completions / (float)offense->passing.attempts * 100.0 : 0,
		  offense->passing.yards,
		  (offense->passing.completions > 0) ? offense->passing.yards / (float)offense->passing.completions : 0,
		  offense->passing.touchdowns,
		  offense->passing.interceptions );

	  printf( "%3d %6.1f %4.1f %2d ",
		  offense->rushing.carries,
		  offense->rushing.yards,
		  (offense->rushing.carries > 0) ? offense->rushing.yards / (float)offense->rushing.carries : 0,
		  offense->rushing.touchdowns );

	  printf( "%3d %6.1f %4.1f %2d ",
		  offense->receiving.receptions,
		  offense->receiving.yards,
		  (offense->receiving.receptions > 0) ? offense->receiving.yards / (float)offense->receiving.receptions : 0,
		  offense->receiving.touchdowns );

	  printf( "%2d\n", offense->fumbles );
     }
}

static int cmpplr( const void *arg1, const void *arg2 )
{
     const player_s *p1 = (player_s *)arg1;
     const player_s *p2 = (player_s *)arg2;
     /**/  int       cmp;

     if ( p1->position != p2->position ) return p1->position - p2->position;

     if ( p1->number != p2->number ) return p1->number - p2->number;

     return 0;
}

static void copy_player( player_s *player, hcplayer_s *hcplayer )
{
     strcpy( player->name, hcplayer->name );

     player->number = hcplayer->number[0];
     player->position = hcplayer->position[0];
     player->rating   = (float)hcplayer->rating[0] / 10.0;

     if ( player->position >= pos_Defensive_End )
     {
	  defensive_stats_s *defense   = &player->stats.defense;
	  hcdefense_s       *hcdefense = &hcplayer->role.defense;

	  defense->tackles           = word2int( hcdefense->tackles           );
	  defense->sacks             = word2int( hcdefense->sacks             );
	  defense->interceptions     = word2int( hcdefense->interceptions     );
	  defense->fumble_recoveries = word2int( hcdefense->fumble_recoveries );
     }
     else
     {
	  offensive_stats_s *offense   = &player->stats.offense;
	  hcoffense_s       *hcoffense = &hcplayer->role.offense;

	  offense->fumbles = word2int( hcoffense->fumbles_lost );

	  // Passing
	  offense->passing.attempts      =         word2int( hcoffense->attempts      );
	  offense->passing.completions   =         word2int( hcoffense->completions   );
	  offense->passing.yards         = (float)dword2int( hcoffense->passing_yards ) / 10.0;
	  offense->passing.touchdowns    =         word2int( hcoffense->passing_td    );
	  offense->passing.interceptions =         word2int( hcoffense->interceptions );

	  // Rushing
	  offense->rushing.carries    =         word2int( hcoffense->carries       );
	  offense->rushing.yards      = (float)dword2int( hcoffense->rushing_yards ) / 10.0;
	  offense->rushing.touchdowns =         word2int( hcoffense->rushing_td    );

	  // Receiving
	  offense->receiving.receptions =         word2int( hcoffense->receptions      );
	  offense->receiving.yards      = (float)dword2int( hcoffense->receiving_yards ) / 10.0;
	  offense->receiving.touchdowns =         word2int( hcoffense->receiving_td    );
     }
}

int main( int argc, char *argv[] )
{
     player_s  *players;
     hcstats_s *statsFile;
     int        offenseHeader;
     int        defenseHeader;
     int        i;


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

     if ( (players = malloc( sizeof(player_s) * 45 )) == NULL )
     {
	  printf( "Cannot allocate memory for players.\n" );

          free( statsFile );

	  return EXIT_FAILURE;
     }

     for ( i = 0; i < 45; ++i ) {

	  copy_player( &players[i], &(statsFile->players[i]) );
     }

     qsort( players, 45, sizeof(player_s), cmpplr );

     offenseHeader = 0;
     defenseHeader = 0;

     for ( i = 0; i < 45; ++i ) {

	  if ( players[i].position < pos_Defensive_End  &&  offenseHeader == 0 )
	  {
	       print_offense_header();

	       offenseHeader = 1;
	  }

	  if ( players[i].position >= pos_Defensive_End  &&  defenseHeader == 0 )
	  {
	       printf( "\n" );

	       print_defense_header();

	       defenseHeader = 1;
	  }

	  print_player_stats( &players[i] );
     }

     free( players );
     free( statsFile );

     return EXIT_SUCCESS;
}
