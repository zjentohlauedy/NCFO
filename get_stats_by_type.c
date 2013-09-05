#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"


typedef enum
{
     st_Passing       = 'A',
     st_Rushing       = 'B',
     st_Receiving     = 'C',
     st_Tackles       = 'D',
     st_Sacks         = 'E',
     st_Interceptions = 'F',
     st_AllPurpose    = 'G',
     st_Overall       = 'H'

} stat_types_e;

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


static       player_s  *players       = NULL;
static const char      *progname      = NULL;
static       char       teamname[30];


static void print_usage( void )
{
     printf( "Usage: %s <statsfile> <type>.\n", progname );
     printf( "       Where valid types are:\n" );
     printf( "       A. Passing\n" );
     printf( "       B. Rushing\n" );
     printf( "       C. Receiving\n" );
     printf( "       D. Tackles\n" );
     printf( "       E. Sacks\n" );
     printf( "       F. Interceptions\n" );
     printf( "       G. All Purpose\n" );
     printf( "       H. Overall\n" );
}

static void print_passers( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position >= pos_Defensive_End ) continue;

          passing_s *passing = &(players[i].stats.offense.passing);

          if ( passing->attempts == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%d;%d;%0.1f%%;%0.1f;%0.1f;%d;%d\n",
                  passing->attempts,
		  passing->completions,
		  (passing->attempts > 0) ? (float)passing->completions / (float)passing->attempts * 100.0 : 0,
		  passing->yards,
		  (passing->completions > 0) ? passing->yards / (float)passing->completions : 0,
		  passing->touchdowns,
		  passing->interceptions );
     }
}

static void print_rushers( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position >= pos_Defensive_End ) continue;

          rushing_s *rushing = &(players[i].stats.offense.rushing);

          if ( rushing->carries == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%d;%0.1f;%0.1f;%d\n",
		  rushing->carries,
		  rushing->yards,
		  (rushing->carries > 0) ? rushing->yards / (float)rushing->carries : 0,
		  rushing->touchdowns );
     }
}

static void print_receivers( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position >= pos_Defensive_End ) continue;

          receiving_s *receiving = &(players[i].stats.offense.receiving);

          if ( receiving->receptions == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%d;%0.1f;%0.1f;%d\n",
		  receiving->receptions,
		  receiving->yards,
		  (receiving->receptions > 0) ? receiving->yards / (float)receiving->receptions : 0,
		  receiving->touchdowns );
     }
}

static void print_all_purpose( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position >= pos_Defensive_End ) continue;

          rushing_s   *rushing   = &(players[i].stats.offense.rushing);
          receiving_s *receiving = &(players[i].stats.offense.receiving);

          if ( rushing->carries == 0 && receiving->receptions == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%0.1f;%d\n",
		  rushing->yards + receiving->yards,
		  rushing->touchdowns + receiving->touchdowns );
     }
}

static void print_overall( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position >= pos_Defensive_End ) continue;

          passing_s   *passing   = &(players[i].stats.offense.passing);
          rushing_s   *rushing   = &(players[i].stats.offense.rushing);
          receiving_s *receiving = &(players[i].stats.offense.receiving);

          if ( passing->attempts == 0 && rushing->carries == 0 && receiving->receptions == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%0.1f;%d\n",
		  passing->yards + rushing->yards + receiving->yards,
		  passing->touchdowns + rushing->touchdowns + receiving->touchdowns );
     }
}

static void print_tacklers( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position < pos_Defensive_End ) continue;

          defensive_stats_s *defense = &(players[i].stats.defense);

          if ( defense->tackles == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%d\n", defense->tackles );
     }
}

static void print_sackers( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position < pos_Defensive_End ) continue;

          defensive_stats_s *defense = &(players[i].stats.defense);

          if ( defense->sacks == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%d\n", defense->sacks );
     }
}

static void print_intercepters( void )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position < pos_Defensive_End ) continue;

          defensive_stats_s *defense = &(players[i].stats.defense);

          if ( defense->interceptions == 0 ) continue;

          printf( "%s;%s;%s;", positionName( players[i].position ), players[i].name, teamname );
          printf( "%d\n", defense->interceptions );
     }
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
     hcstats_s *statsFile;
     int        i;
     char       stat_type;


     progname = argv[0];

     if ( argc < 3 )
     {
          print_usage();

	  return EXIT_SUCCESS;
     }

     stat_type = *argv[2];

     switch ( stat_type )
     {
     case st_Passing:
     case st_Rushing:
     case st_Receiving:
     case st_Tackles:
     case st_Sacks:
     case st_Interceptions:
     case st_AllPurpose:
     case st_Overall:

          break;

     default:

          print_usage();

          return EXIT_SUCCESS;
     }

     if ( (statsFile = readStatsFile( argv[1] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[1] );

          return EXIT_FAILURE;
     }

     if ( (players = malloc( sizeof(player_s) * 45 )) == NULL )
     {
	  printf( "Cannot allocate memory for players.\n" );

	  return EXIT_FAILURE;
     }

     strcpy( teamname, statsFile->name );

     for ( i = 0; i < 45; ++i ) {

	  copy_player( &players[i], &(statsFile->players[i]) );
     }

     switch ( stat_type )
     {
     case st_Passing:       print_passers();      break;
     case st_Rushing:       print_rushers();      break;
     case st_Receiving:     print_receivers();    break;
     case st_Tackles:       print_tacklers();     break;
     case st_Sacks:         print_sackers();      break;
     case st_Interceptions: print_intercepters(); break;
     case st_AllPurpose:    print_all_purpose();  break;
     case st_Overall:       print_overall();      break;
     }

     free( players );

     return EXIT_SUCCESS;
}
