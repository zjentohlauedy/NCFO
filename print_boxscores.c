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

typedef struct
{
     char     name[30 + 1];
     int      q1Points;
     int      q2Points;
     int      q3Points;
     int      q4Points;
     int      otPoints;
     int      totalPoints;
     int      firstDowns;
     int      offensivePlays;
     int      rushAttempts;
     float    rushYards;
     int      passAttempts;
     int      passCompletions;
     float    passYards;
     int      interceptions;
     int      timesSacked;
     float    yardsLost;
     int      fumbles;
     int      thirdDowns;
     int      conversions;
     int      penalties;
     float    penaltyYards;
     int      puntAttempts;
     float    puntYards;
     int      returns;
     float    returnYards;
     int      possessionTime;
     int      turnovers;
     float    totalOffense;
     player_s players[45];

} team_s;


static int cmppassing( const void *arg1, const void *arg2 )
{
     const player_s *p1 = (player_s *)arg1;
     const player_s *p2 = (player_s *)arg2;
     /**/  int       cmp;

     // If both are defenders treat it as a tie,
     // defenders are always sorted lower than offense
     if      ( p1->position >= pos_Defensive_End &&
	       p2->position >= pos_Defensive_End    ) return  0;
     else if ( p1->position >= pos_Defensive_End    ) return  1;
     else if ( p2->position >= pos_Defensive_End    ) return -1;

     const offensive_stats_s *offense1 = &(p1->stats.offense);
     const offensive_stats_s *offense2 = &(p2->stats.offense);

     if ( offense1->passing.yards != offense2->passing.yards )
     {
	  return (offense1->passing.yards > offense2->passing.yards) ? -1 : 1;
     }

     if ( offense1->passing.attempts != offense2->passing.attempts )
     {
	  return offense2->passing.attempts - offense1->passing.attempts;
     }

     return strcmp( p1->name, p2->name );

     return 0;
}

static int cmprushing( const void *arg1, const void *arg2 )
{
     const player_s *p1 = (player_s *)arg1;
     const player_s *p2 = (player_s *)arg2;
     /**/  int       cmp;

     // If both are defenders treat it as a tie,
     // defenders are always sorted lower than offense
     if      ( p1->position >= pos_Defensive_End &&
	       p2->position >= pos_Defensive_End    ) return  0;
     else if ( p1->position >= pos_Defensive_End    ) return  1;
     else if ( p2->position >= pos_Defensive_End    ) return -1;

     const offensive_stats_s *offense1 = &(p1->stats.offense);
     const offensive_stats_s *offense2 = &(p2->stats.offense);

     if ( offense1->rushing.yards != offense2->rushing.yards )
     {
	  return (offense1->rushing.yards > offense2->rushing.yards) ? -1 : 1;
     }

     if ( offense1->rushing.carries != offense2->rushing.carries )
     {
	  return offense2->rushing.carries - offense1->rushing.carries;
     }

     return strcmp( p1->name, p2->name );

     return 0;
}

static int cmpreceiving( const void *arg1, const void *arg2 )
{
     const player_s *p1 = (player_s *)arg1;
     const player_s *p2 = (player_s *)arg2;
     /**/  int       cmp;

     // If both are defenders treat it as a tie,
     // defenders are always sorted lower than offense
     if      ( p1->position >= pos_Defensive_End &&
	       p2->position >= pos_Defensive_End    ) return  0;
     else if ( p1->position >= pos_Defensive_End    ) return  1;
     else if ( p2->position >= pos_Defensive_End    ) return -1;

     const offensive_stats_s *offense1 = &(p1->stats.offense);
     const offensive_stats_s *offense2 = &(p2->stats.offense);

     if ( offense1->receiving.yards != offense2->receiving.yards )
     {
	  return (offense1->receiving.yards > offense2->receiving.yards) ? -1 : 1;
     }

     if ( offense1->receiving.receptions != offense2->receiving.receptions )
     {
	  return offense2->receiving.receptions - offense1->receiving.receptions;
     }

     return strcmp( p1->name, p2->name );

     return 0;
}

static int cmpdefense( const void *arg1, const void *arg2 )
{
     const player_s *p1 = (player_s *)arg1;
     const player_s *p2 = (player_s *)arg2;
     /**/  int       cmp;

     // If both are offense treat it as a tie,
     // offense are always sorted lower than defense
     if      ( p1->position < pos_Defensive_End &&
	       p2->position < pos_Defensive_End    ) return  0;
     else if ( p1->position < pos_Defensive_End    ) return  1;
     else if ( p2->position < pos_Defensive_End    ) return -1;

     const defensive_stats_s *defense1 = &(p1->stats.defense);
     const defensive_stats_s *defense2 = &(p2->stats.defense);

     if ( defense1->tackles != defense2->tackles )
     {
	  return (defense1->tackles > defense2->tackles) ? -1 : 1;
     }

     return strcmp( p1->name, p2->name );

     return 0;
}

static void print_scoreboard( team_s *roadTeam, team_s *homeTeam )
{
     printf( "%15s     1     2     3     4    OT\n", "" );
     printf( "\n" );
     printf( "%15s    %2d    %2d    %2d    %2d    %2d    %2d\n",
	     roadTeam->name,
	     roadTeam->q1Points,
	     roadTeam->q2Points,
	     roadTeam->q3Points,
	     roadTeam->q4Points,
	     roadTeam->otPoints,
	     roadTeam->totalPoints );
     printf( "%15s    %2d    %2d    %2d    %2d    %2d    %2d\n",
	     homeTeam->name,
	     homeTeam->q1Points,
	     homeTeam->q2Points,
	     homeTeam->q3Points,
	     homeTeam->q4Points,
	     homeTeam->otPoints,
	     homeTeam->totalPoints );
}

static void print_team_stats( team_s *roadTeam, team_s *homeTeam )
{
     char *fmt = "%-17s%-27s%s\n";
     char  roadBuffer[100];
     char  homeBuffer[100];

     printf( fmt, roadTeam->name, "", homeTeam->name );

     sprintf( roadBuffer, "%d", roadTeam->totalPoints );
     sprintf( homeBuffer, "%d", homeTeam->totalPoints );

     printf( fmt, roadBuffer, "     Points Scored", homeBuffer );

     sprintf( roadBuffer, "%d", roadTeam->firstDowns );
     sprintf( homeBuffer, "%d", homeTeam->firstDowns );

     printf( fmt, roadBuffer, "      First Downs", homeBuffer );

     sprintf( roadBuffer, "%d", roadTeam->offensivePlays );
     sprintf( homeBuffer, "%d", homeTeam->offensivePlays );

     printf( fmt, roadBuffer, "    Offensive Plays", homeBuffer );

     sprintf( roadBuffer, "%d: %0.1f: %0.1f",
	      roadTeam->rushAttempts,
	      roadTeam->rushYards,
	      (roadTeam->rushAttempts > 0) ? roadTeam->rushYards / (float)roadTeam->rushAttempts : 0 );

     sprintf( homeBuffer, "%d: %0.1f: %0.1f",
	      homeTeam->rushAttempts,
	      homeTeam->rushYards,
	      (homeTeam->rushAttempts > 0) ? homeTeam->rushYards / (float)homeTeam->rushAttempts : 0 );

     printf( fmt, roadBuffer, "        Rushing", homeBuffer );

     sprintf( roadBuffer, "%d: %d: %d: %0.1f",
	      roadTeam->passCompletions,
	      roadTeam->passAttempts,
	      roadTeam->interceptions,
	      roadTeam->passYards );

     sprintf( homeBuffer, "%d: %d: %d: %0.1f",
	      homeTeam->passCompletions,
	      homeTeam->passAttempts,
	      homeTeam->interceptions,
	      homeTeam->passYards );

     printf( fmt, roadBuffer, "        Passing", homeBuffer );

     sprintf( roadBuffer, "%0.1f", (roadTeam->passAttempts > 0) ? (float)roadTeam->passCompletions / (float)roadTeam->passAttempts * 100.0 : 0 );
     sprintf( homeBuffer, "%0.1f", (homeTeam->passAttempts > 0) ? (float)homeTeam->passCompletions / (float)homeTeam->passAttempts * 100.0 : 0 );

     printf( fmt, roadBuffer, "       Passing %", homeBuffer );

     sprintf( roadBuffer, "%0.1f", (roadTeam->passAttempts > 0) ? (float)roadTeam->passYards / (float)roadTeam->passAttempts : 0 );
     sprintf( homeBuffer, "%0.1f", (homeTeam->passAttempts > 0) ? (float)homeTeam->passYards / (float)homeTeam->passAttempts : 0 );

     printf( fmt, roadBuffer, "     Yards/Attempt", homeBuffer );

     sprintf( roadBuffer, "%0.1f", (roadTeam->passCompletions > 0) ? (float)roadTeam->passYards / (float)roadTeam->passCompletions : 0 );
     sprintf( homeBuffer, "%0.1f", (homeTeam->passCompletions > 0) ? (float)homeTeam->passYards / (float)homeTeam->passCompletions : 0 );

     printf( fmt, roadBuffer, "    Yards/Completion", homeBuffer );

     sprintf( roadBuffer, "%d: %0.1f", roadTeam->timesSacked, roadTeam->yardsLost );
     sprintf( homeBuffer, "%d: %0.1f", homeTeam->timesSacked, homeTeam->yardsLost );

     printf( fmt, roadBuffer, "Lost Attempting to Pass", homeBuffer );

     sprintf( roadBuffer, "%d", roadTeam->fumbles );
     sprintf( homeBuffer, "%d", homeTeam->fumbles );

     printf( fmt, roadBuffer, "      Fumbles Lost", homeBuffer );

     sprintf( roadBuffer, "%d/%d", roadTeam->conversions, roadTeam->thirdDowns );
     sprintf( homeBuffer, "%d/%d", homeTeam->conversions, homeTeam->thirdDowns );

     printf( fmt, roadBuffer, "Third Down Conversions", homeBuffer );

     sprintf( roadBuffer, "%d: %0.1f", roadTeam->penalties, roadTeam->penaltyYards );
     sprintf( homeBuffer, "%d: %0.1f", homeTeam->penalties, homeTeam->penaltyYards );

     printf( fmt, roadBuffer, "       Penalties", homeBuffer );

     sprintf( roadBuffer, "%d: %0.1f",
	      roadTeam->puntAttempts,
	      (roadTeam->puntAttempts > 0 ) ? roadTeam->puntYards / (float)roadTeam->puntAttempts : 0 );

     sprintf( homeBuffer, "%d: %0.1f",
	      homeTeam->puntAttempts,
	      (homeTeam->puntAttempts > 0 ) ? homeTeam->puntYards / (float)homeTeam->puntAttempts : 0 );

     printf( fmt, roadBuffer, "        Punting", homeBuffer );

     sprintf( roadBuffer, "%d: %0.1f", roadTeam->returns, roadTeam->returnYards );
     sprintf( homeBuffer, "%d: %0.1f", homeTeam->returns, homeTeam->returnYards );

     printf( fmt, roadBuffer, "      Return Yards", homeBuffer );

     sprintf( roadBuffer, "%02d:%02d", roadTeam->possessionTime / 60, roadTeam->possessionTime % 60 );
     sprintf( homeBuffer, "%02d:%02d", homeTeam->possessionTime / 60, homeTeam->possessionTime % 60 );

     printf( fmt, roadBuffer, "   Time of Possession", homeBuffer );

     sprintf( roadBuffer, "%d", roadTeam->turnovers );
     sprintf( homeBuffer, "%d", homeTeam->turnovers );

     printf( fmt, roadBuffer, "       Turnovers", homeBuffer );

     sprintf( roadBuffer, "%0.1f", roadTeam->totalOffense );
     sprintf( homeBuffer, "%0.1f", homeTeam->totalOffense );

     printf( fmt, roadBuffer, "     Total Offense", homeBuffer );

}

static void print_passing( team_s *roadTeam, team_s *homeTeam )
{
     int i;

     printf( "      Passing             Cmp Att  Pct.   Yards Avg. TD Int.\n" );
     printf( "%s:\n", roadTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  passing_s *passing;

	  if ( roadTeam->players[i].position >= pos_Defensive_End ) continue;

	  passing = &(roadTeam->players[i].stats.offense.passing);

	  if ( passing->attempts == 0 ) continue;

	  printf( "%2d %s %-20s ",
		  roadTeam->players[i].number,
		  positionName( roadTeam->players[i].position ),
		  roadTeam->players[i].name );

	  printf( "%2d  %2d %5.1f%%  %5.1f %4.1f %2d %2d\n",
		  passing->completions,
		  passing->attempts,
		  (float)passing->completions / (float)passing->attempts * 100.0,
		  passing->yards,
		  (passing->completions > 0) ? passing->yards / (float)passing->completions : 0,
		  passing->touchdowns,
		  passing->interceptions );
     }

     printf( "%s:\n", homeTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  passing_s *passing;

	  if ( homeTeam->players[i].position >= pos_Defensive_End ) continue;

	  passing = &(homeTeam->players[i].stats.offense.passing);

	  if ( passing->attempts == 0 ) continue;

	  printf( "%2d %s %-20s ",
		  homeTeam->players[i].number,
		  positionName( homeTeam->players[i].position ),
		  homeTeam->players[i].name );

	  printf( "%2d  %2d %5.1f%%  %5.1f %4.1f %2d %2d\n",
		  passing->completions,
		  passing->attempts,
		  (float)passing->completions / (float)passing->attempts * 100.0,
		  passing->yards,
		  (passing->completions > 0) ? passing->yards / (float)passing->completions : 0,
		  passing->touchdowns,
		  passing->interceptions );
     }
}

static void print_rushing( team_s *roadTeam, team_s *homeTeam )
{
     int i;

     printf( "      Rushing             Car             Yards Avg. TD\n" );
     printf( "%s:\n", roadTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  rushing_s *rushing;

	  if ( roadTeam->players[i].position >= pos_Defensive_End ) continue;

	  rushing = &(roadTeam->players[i].stats.offense.rushing);

	  if ( rushing->carries == 0 ) continue;

	  printf( "%2d %s %-20s ",
		  roadTeam->players[i].number,
		  positionName( roadTeam->players[i].position ),
		  roadTeam->players[i].name );

	  printf( "%2d             %5.1f %4.1f %2d\n",
		  rushing->carries,
		  rushing->yards,
		  rushing->yards / (float)rushing->carries,
		  rushing->touchdowns );
     }

     printf( "%s:\n", homeTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  rushing_s *rushing;

	  if ( homeTeam->players[i].position >= pos_Defensive_End ) continue;

	  rushing = &(homeTeam->players[i].stats.offense.rushing);

	  if ( rushing->carries == 0 ) continue;

	  printf( "%2d %s %-20s ",
		  homeTeam->players[i].number,
		  positionName( homeTeam->players[i].position ),
		  homeTeam->players[i].name );

	  printf( "%2d             %5.1f %4.1f %2d\n",
		  rushing->carries,
		  rushing->yards,
		  rushing->yards / (float)rushing->carries,
		  rushing->touchdowns );
     }
}

static void print_receiving( team_s *roadTeam, team_s *homeTeam )
{
     int i;

     printf( "      Receiving           Rec             Yards Avg. TD\n" );
     printf( "%s:\n", roadTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  receiving_s *receiving;

	  if ( roadTeam->players[i].position >= pos_Defensive_End ) continue;

	  receiving = &(roadTeam->players[i].stats.offense.receiving);

	  if ( receiving->receptions == 0 ) continue;

	  printf( "%2d %s %-20s ",
		  roadTeam->players[i].number,
		  positionName( roadTeam->players[i].position ),
		  roadTeam->players[i].name );

	  printf( "%2d             %5.1f %4.1f %2d\n",
		  receiving->receptions,
		  receiving->yards,
		  receiving->yards / (float)receiving->receptions,
		  receiving->touchdowns );
     }

     printf( "%s:\n", homeTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  receiving_s *receiving;

	  if ( homeTeam->players[i].position >= pos_Defensive_End ) continue;

	  receiving = &(homeTeam->players[i].stats.offense.receiving);

	  if ( receiving->receptions == 0 ) continue;

	  printf( "%2d %s %-20s ",
		  homeTeam->players[i].number,
		  positionName( homeTeam->players[i].position ),
		  homeTeam->players[i].name );

	  printf( "%2d             %5.1f %4.1f %2d\n",
		  receiving->receptions,
		  receiving->yards,
		  receiving->yards / (float)receiving->receptions,
		  receiving->touchdowns );
     }
}

static void print_defense( team_s *roadTeam, team_s *homeTeam )
{
     int i;

     printf( "      Defense             Tck. Sacks  Int.  FR\n" );
     printf( "%s:\n", roadTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  defensive_stats_s *defense;

	  if ( roadTeam->players[i].position < pos_Defensive_End ) continue;

	  defense = &(roadTeam->players[i].stats.defense);

	  if ( defense->tackles           == 0 &&
	       defense->sacks             == 0 &&
	       defense->interceptions     == 0 &&
	       defense->fumble_recoveries == 0    ) continue;

	  printf( "%2d %s %-20s ",
		  roadTeam->players[i].number,
		  positionName( roadTeam->players[i].position ),
		  roadTeam->players[i].name );

	  printf( "%2d   %2d    %2d    %2d\n",
		  defense->tackles,
		  defense->sacks,
		  defense->interceptions,
		  defense->fumble_recoveries );
     }

     printf( "%s:\n", homeTeam->name );

     for ( i = 0; i < 45; ++i )
     {
	  defensive_stats_s *defense;

	  if ( homeTeam->players[i].position < pos_Defensive_End ) continue;

	  defense = &(homeTeam->players[i].stats.defense);

	  if ( defense->tackles           == 0 &&
	       defense->sacks             == 0 &&
	       defense->interceptions     == 0 &&
	       defense->fumble_recoveries == 0    ) continue;

	  printf( "%2d %s %-20s ",
		  homeTeam->players[i].number,
		  positionName( homeTeam->players[i].position ),
		  homeTeam->players[i].name );

	  printf( "%2d   %2d    %2d    %2d\n",
		  defense->tackles,
		  defense->sacks,
		  defense->interceptions,
		  defense->fumble_recoveries );
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

static void copy_team( team_s *team, hcstats_s *stats )
{
     int i;

     strcpy( team->name, stats->name );

     team->q1Points = word2int( stats->team_stats[0].q1_points );
     team->q2Points = word2int( stats->team_stats[0].q2_points );
     team->q3Points = word2int( stats->team_stats[0].q3_points );
     team->q4Points = word2int( stats->team_stats[0].q4_points );
     team->otPoints = word2int( stats->team_stats[0].ot_points );

     team->totalPoints = ( team->q1Points +
			   team->q2Points +
			   team->q3Points +
			   team->q4Points +
			   team->otPoints   );

     team->rushAttempts    = dword2int(stats->team_stats[0].rush_att);
     team->rushYards       = (float)dword2int(stats->team_stats[0].rush_yards) / 10.0;
     team->passAttempts    = dword2int(stats->team_stats[0].pass_att);
     team->passCompletions = dword2int(stats->team_stats[0].pass_comp);
     team->passYards       = (float)dword2int(stats->team_stats[0].pass_yards) / 10.0;
     team->interceptions   = dword2int(stats->team_stats[0].pass_int);
     team->timesSacked     = dword2int(stats->team_stats[0].times_sacked);
     team->yardsLost       = (float)dword2int(stats->team_stats[0].sack_yards_lost) / 10.0;
     team->fumbles         = dword2int(stats->team_stats[0].fmb_lost);
     team->thirdDowns      = dword2int(stats->team_stats[0].third_downs);
     team->conversions     = dword2int(stats->team_stats[0]._3d_conv);
     team->penalties       = dword2int(stats->team_stats[0].penalties);
     team->penaltyYards    = (float)dword2int(stats->team_stats[0].penalty_yards) / 10.0;
     team->puntAttempts    = dword2int(stats->team_stats[0].punts);
     team->puntYards       = (float)dword2int(stats->team_stats[0].total_punt_dist) / 10.0;
     team->possessionTime  = dword2int(stats->team_stats[0].possession_time);

     team->returns         = dword2int(stats->team_stats[0].punt_returns) + dword2int(stats->team_stats[0].kickoff_returns);
     team->returnYards     = (float)(dword2int(stats->team_stats[0].punt_ret_yards) + dword2int(stats->team_stats[0].kick_ret_yards)) / 10.0;

     team->firstDowns      = dword2int(stats->team_stats[0].rushing_fd) + dword2int(stats->team_stats[0].passing_fd) + dword2int(stats->team_stats[0].penalty_fd);

     team->turnovers       = team->fumbles + team->interceptions;
     team->totalOffense    = team->rushYards + team->passYards - team->yardsLost;
     team->offensivePlays  = team->rushAttempts + team->passAttempts;

     for ( i = 0; i < 45; ++i ) {

	  copy_player( &(team->players[i]), &(stats->players[i]) );
     }
}

int main( int argc, char *argv[] )
{
     team_s    *homeTeam;
     team_s    *roadTeam;
     hcstats_s *stats;
     char      *filename;
     size_t     filesize;
     int        fd;
     int        i;


     if ( argc < 3 )
     {
	  printf( "Usage: %s <roadstats> <homestats>.\n", argv[0] );

	  return EXIT_SUCCESS;
     }

     // Road Team
     if ( (stats = readStatsFile( argv[1] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[1] );

          return EXIT_SUCCESS;
     }

     if ( (roadTeam = malloc( sizeof(team_s) )) == NULL )
     {
	  printf( "Cannot allocate memory for road team.\n" );

	  free( stats );

	  return EXIT_FAILURE;
     }

     copy_team( roadTeam, stats );

     free( stats );

     // Home Team
     if ( (stats = readStatsFile( argv[2] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[2] );

          free( roadTeam );

          return EXIT_SUCCESS;
     }

     if ( (homeTeam = malloc( sizeof(team_s) )) == NULL )
     {
	  printf( "Cannot allocate memory for home team.\n" );

	  free( stats );
	  free( roadTeam );

	  return EXIT_FAILURE;
     }

     copy_team( homeTeam, stats );

     free( stats );

     printf( "\n\n" );

     print_scoreboard( roadTeam, homeTeam );

     printf( "\n\n" );

     print_team_stats( roadTeam, homeTeam );

     printf( "\n\n" );

     qsort( roadTeam->players, 45, sizeof(player_s), cmppassing );
     qsort( homeTeam->players, 45, sizeof(player_s), cmppassing );

     print_passing( roadTeam, homeTeam );

     printf( "\n\n" );

     qsort( roadTeam->players, 45, sizeof(player_s), cmprushing );
     qsort( homeTeam->players, 45, sizeof(player_s), cmprushing );

     print_rushing( roadTeam, homeTeam );

     printf( "\n\n" );

     qsort( roadTeam->players, 45, sizeof(player_s), cmpreceiving );
     qsort( homeTeam->players, 45, sizeof(player_s), cmpreceiving );

     print_receiving( roadTeam, homeTeam );

     printf( "\n\n" );

     qsort( roadTeam->players, 45, sizeof(player_s), cmpdefense );
     qsort( homeTeam->players, 45, sizeof(player_s), cmpdefense );

     print_defense( roadTeam, homeTeam );

     free( roadTeam );
     free( homeTeam );

     return EXIT_SUCCESS;
}
