#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"


static void print_player_stats( hcplayer_s *player )
{
     printf( "%2d %s %s %3.1f\n",
	     player->number[0],
	     player->name,
	     positionName( player->position[0] ),
	     (float)(player->rating[0]) / 10.0 );
     printf( "Ratings: %3.1f %3.1f %3.1f %3.1f %3.1f %3.1f %3.1f %3.1f %3.1f %3.1f %3.1f\n",
	     (float)(player->pass_block_rating[0]) / 10.0,
	     (float)(player->run_block_rating[0]) / 10.0,
	     (float)(player->pass_catch_rating[0]) / 10.0,
	     (float)(player->run_speed_rating[0]) / 10.0,
	     (float)(player->run_strength_rating[0]) / 10.0,
	     (float)(player->pass_strength_rating[0]) / 10.0,
	     (float)(player->pass_accuracy_rating[0]) / 10.0,
	     (float)(player->scramble_tendency[0]) / 10.0,
	     (float)(player->run_defense_rating[0]) / 10.0,
	     (float)(player->pass_defense_rating[0]) / 10.0,
	     (float)(player->pass_rush_rating[0]) / 10.0 );

     if ( player->position[0] >= 8 )
     {
	  printf( "Tackles: %d; Sacks: %d; Int.: %d; Fumble Rec.: %d\n",
		  word2int( player->role.defense.tackles ),
		  word2int( player->role.defense.sacks ),
		  word2int( player->role.defense.interceptions ),
		  word2int( player->role.defense.fumble_recoveries ) );
     }
     else
     {
	  switch ( player->position[0] )
	  {
	  case  3:

	       printf( "Receiving: %d catches for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.receptions ),
		       (float)dword2int( player->role.offense.receiving_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.receiving_yards ) / 10.0) / (float)word2int( player->role.offense.receptions ),
		       word2int( player->role.offense.receiving_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       break;

	  case  4:

	       printf( "Receiving: %d catches for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.receptions ),
		       (float)dword2int( player->role.offense.receiving_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.receiving_yards ) / 10.0) / (float)word2int( player->role.offense.receptions ),
		       word2int( player->role.offense.receiving_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       printf( "Rushing: %d carries for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.carries ),
		       (float)dword2int( player->role.offense.rushing_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.rushing_yards ) / 10.0) / (float)word2int( player->role.offense.carries ),
		       word2int( player->role.offense.rushing_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       break;

	  case  5:

	       printf( "Rushing: %d carries for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.carries ),
		       (float)dword2int( player->role.offense.rushing_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.rushing_yards ) / 10.0) / (float)word2int( player->role.offense.carries ),
		       word2int( player->role.offense.rushing_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       printf( "Receiving: %d catches for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.receptions ),
		       (float)dword2int( player->role.offense.receiving_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.receiving_yards ) / 10.0) / (float)word2int( player->role.offense.receptions ),
		       word2int( player->role.offense.receiving_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       printf( "Passing: %d of %d for %0.1f, %0.1f avg., %d TD, %d Int.\n",
		       word2int( player->role.offense.completions ),
		       word2int( player->role.offense.attempts ),
		       (float)dword2int( player->role.offense.passing_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.passing_yards ) / 10.0) / (float)word2int( player->role.offense.completions ),
		       word2int( player->role.offense.passing_td ),
		       word2int( player->role.offense.interceptions ) );

	       break;

	  case  6:

	       printf( "Rushing: %d carries for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.carries ),
		       (float)dword2int( player->role.offense.rushing_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.rushing_yards ) / 10.0) / (float)word2int( player->role.offense.carries ),
		       word2int( player->role.offense.rushing_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       printf( "Receiving: %d catches for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.receptions ),
		       (float)dword2int( player->role.offense.receiving_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.receiving_yards ) / 10.0) / (float)word2int( player->role.offense.receptions ),
		       word2int( player->role.offense.receiving_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       break;

	  case  7:

	       printf( "Passing: %d of %d for %0.1f, %0.1f avg., %d TD, %d Int.\n",
		       word2int( player->role.offense.completions ),
		       word2int( player->role.offense.attempts ),
		       (float)dword2int( player->role.offense.passing_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.passing_yards ) / 10.0) / (float)word2int( player->role.offense.completions ),
		       word2int( player->role.offense.passing_td ),
		       word2int( player->role.offense.interceptions ) );

	       printf( "Rushing: %d carries for %0.1f yards, %0.1f avg., %d TD, %d Fum.\n",
		       word2int( player->role.offense.carries ),
		       (float)dword2int( player->role.offense.rushing_yards ) / 10.0,
		       ((float)dword2int( player->role.offense.rushing_yards ) / 10.0) / (float)word2int( player->role.offense.carries ),
		       word2int( player->role.offense.rushing_td ),
		       word2int( player->role.offense.fumbles_lost ) );

	       break;

	  }
     }

     printf( "\n" );
}

static void print_team_stats( hcteam_s *team_stats, char *name )
{
     printf( "Rushing: %d for %0.1f, %0.1f avg., %d TD\n",
	     dword2int( team_stats[0].rush_att ),
	     (float)(dword2int( team_stats[0].rush_yards )) / 10.0,
	     ((float)(dword2int( team_stats[0].rush_yards )) /10.0) / (float)(dword2int( team_stats[0].rush_att )),
	     dword2int( team_stats[0].rush_td ) );
     printf( "Fumbles: %d  Returns: %d for %0.1f, %0.1f avg.\n",
	     dword2int( team_stats[0].fmb_lost ),
	     dword2int( team_stats[0].fmb_ret ),
	     (float)(dword2int( team_stats[0].fmb_ret_yards )) / 10.0,
	     ((float)(dword2int( team_stats[0].fmb_ret_yards )) /10.0) / (float)(dword2int( team_stats[0].fmb_ret )) );
     printf( "Passing: %d of %d for %0.1f, %0.1f avg., %d TD, %d int.\n",
	     dword2int( team_stats[0].pass_comp ),
	     dword2int( team_stats[0].pass_att ),
	     (float)(dword2int( team_stats[0].pass_yards )) / 10.0,
	     ((float)(dword2int( team_stats[0].pass_yards )) /10.0) / (float)(dword2int( team_stats[0].pass_comp )),
	     dword2int( team_stats[0].pass_td ),
	     dword2int( team_stats[0].pass_int ) );
     printf( "Sacked %d times for %01.f yards.\n",
	     dword2int( team_stats[0].times_sacked ),
	     (float)(dword2int( team_stats[0].sack_yards_lost )) / 10.0 );
     printf( "Sacks: %d, Int: %d Fumb. Rec: %d Return Yards: %0.1f, %0.1f avg.\n",
	     dword2int( team_stats[0].sacks ),
	     dword2int( team_stats[0].interceptions ),
	     dword2int( team_stats[0].fmb_ret ),
	     (float)(dword2int( team_stats[0].fmb_ret_yards )) / 10.0,
	     ((float)(dword2int( team_stats[0].fmb_ret_yards )) /10.0) / (float)(dword2int( team_stats[0].fmb_ret ) + dword2int( team_stats[0].interceptions )) );
     printf( "Punts: %d for %0.1f, %0.1f avg.\n",
	     dword2int( team_stats[0].punts ),
	     (float)(dword2int( team_stats[0].total_punt_dist )) / 10.0,
	     ((float)(dword2int( team_stats[0].total_punt_dist )) /10.0) / (float)(dword2int( team_stats[0].punts )) );
     printf( "Field Goals: %d of %d %6.2f%%\n",
	     dword2int( team_stats[0].kicks_made ),
	     dword2int( team_stats[0].kicks_att ),
             (float)dword2int( team_stats[0].kicks_made ) / (float)dword2int( team_stats[0].kicks_att ) * 100.0 );
     printf( "Punt Returns: %d for %0.1f, %0.1f avg.\n",
	     dword2int( team_stats[0].punt_returns ),
	     (float)(dword2int( team_stats[0].punt_ret_yards )) / 10.0,
	     ((float)(dword2int( team_stats[0].punt_ret_yards )) /10.0) / (float)(dword2int( team_stats[0].punt_returns )) );
     printf( "Kickoff Returns: %d for %0.1f, %0.1f avg.\n",
	     dword2int( team_stats[0].kickoff_returns ),
	     (float)(dword2int( team_stats[0].kick_ret_yards )) / 10.0,
	     ((float)(dword2int( team_stats[0].kick_ret_yards )) /10.0) / (float)(dword2int( team_stats[0].kickoff_returns )) );
     printf( "Penalties: %d for %0.1f yards.\n",
	     dword2int( team_stats[0].penalties ),
	     (float)(dword2int( team_stats[0].penalty_yards )) / 10.0 );
     printf( "Possession Time: %d:%02d\n",
	     dword2int( team_stats[0].possession_time ) / 60,
	     dword2int( team_stats[0].possession_time ) % 60 );
     printf( "3rd Down Coversions: %d of %d (%0.1f%%)\n",
	     dword2int( team_stats[0]._3d_conv ),
	     dword2int( team_stats[0].third_downs ),
	     (float)dword2int( team_stats[0]._3d_conv ) / (float)dword2int( team_stats[0].third_downs ) * 100.0 );

     int points_scored  = 0;
     int points_allowed = 0;

     points_scored += word2int( team_stats[0].q1_points );
     points_scored += word2int( team_stats[0].q2_points );
     points_scored += word2int( team_stats[0].q3_points );
     points_scored += word2int( team_stats[0].q4_points );
     points_scored += word2int( team_stats[0].ot_points );

     points_allowed += word2int( team_stats[0].q1_allowed );
     points_allowed += word2int( team_stats[0].q2_allowed );
     points_allowed += word2int( team_stats[0].q3_allowed );
     points_allowed += word2int( team_stats[0].q4_allowed );
     points_allowed += word2int( team_stats[0].ot_allowed );

     printf( "%-15s %3d %3d %3d %3d %3d  %4d\n",
	     "Opponents",
	     word2int( team_stats[0].q1_allowed ),
	     word2int( team_stats[0].q2_allowed ),
	     word2int( team_stats[0].q3_allowed ),
	     word2int( team_stats[0].q4_allowed ),
	     word2int( team_stats[0].ot_allowed ),
	     points_allowed );

     printf( "%-15s %3d %3d %3d %3d %3d  %4d\n",
	     name,
	     word2int( team_stats[0].q1_points ),
	     word2int( team_stats[0].q2_points ),
	     word2int( team_stats[0].q3_points ),
	     word2int( team_stats[0].q4_points ),
	     word2int( team_stats[0].ot_points ),
	     points_scored );
}

int main( int argc, char *argv[] )
{
     hcstats_s *statsFile;
     int        i;
     int        j;


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

     printf( "%s %d %d %d\n", statsFile->name, statsFile->wins[0], statsFile->losses[0], statsFile->ties[0] );
     printf( "Defense: %d\n", statsFile->defense[0] );
     printf( "Colors: %03X %03X %03X %03X\n",
	     word2int( statsFile->home_jersey ),
	     word2int( statsFile->home_letter ),
	     word2int( statsFile->road_jersey ),
	     word2int( statsFile->road_letter ) );
     printf( "Punt Avg: %0.1f\n", (float)(word2int( statsFile->punt_avg )) / 10.0 );
     printf( "Punt Return Avg: %0.1f\n", (float)(word2int( statsFile->punt_ret_avg )) / 10.0 );
     printf( "Kick Return Avg: %0.1f\n", (float)(word2int( statsFile->kick_ret_avg )) / 10.0 );
     printf( "\n" );

     printf( "%s:\n", statsFile->name );
     print_team_stats( statsFile->team_stats, statsFile->name );

     printf( "\n" );
     printf( "%s:\n", "Opponents" );
     print_team_stats( statsFile->opponent_stats, statsFile->name );

     printf( "\n" );
     printf( "%s:\n", "Players" );

     for ( i = 0; i < 45; ++i ) {

	  print_player_stats( &statsFile->players[i] );
     }

     printf( "Lineups:\n" );

     for ( i = 0; i < 7; ++i )
     {
          for ( j = 0; j < 11; ++j )
          {
               printf( "%2d ", statsFile->lineups[i].players[j] );
          }

          printf( "\n" );
     }

     printf( "\n" );

     free( statsFile );

     return EXIT_SUCCESS;
}
