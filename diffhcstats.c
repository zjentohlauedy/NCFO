#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"


static void diffPlayers( hcplayer_s *newplayer, hcplayer_s *oldplayer )
{
     if ( newplayer->number[0] != oldplayer->number[0] )
     {
	  printf( "WARNING: Comparing different players!" );
     }

     if ( newplayer->position[0] < pos_Defensive_End )
     {
	  // Offense
	  hcoffense_s *newoffense = &(newplayer->role.offense);
	  hcoffense_s *oldoffense = &(oldplayer->role.offense);

	  int2word( newoffense->carries,       word2int( newoffense->carries       ) - word2int( oldoffense->carries       ) );
	  int2word( newoffense->fumbles_lost,  word2int( newoffense->fumbles_lost  ) - word2int( oldoffense->fumbles_lost  ) );
	  int2word( newoffense->attempts,      word2int( newoffense->attempts      ) - word2int( oldoffense->attempts      ) );
	  int2word( newoffense->completions,   word2int( newoffense->completions   ) - word2int( oldoffense->completions   ) );
	  int2word( newoffense->interceptions, word2int( newoffense->interceptions ) - word2int( oldoffense->interceptions ) );
	  int2word( newoffense->receptions,    word2int( newoffense->receptions    ) - word2int( oldoffense->receptions    ) );
	  int2word( newoffense->rushing_td,    word2int( newoffense->rushing_td    ) - word2int( oldoffense->rushing_td    ) );
	  int2word( newoffense->receiving_td,  word2int( newoffense->receiving_td  ) - word2int( oldoffense->receiving_td  ) );
	  int2word( newoffense->passing_td,    word2int( newoffense->passing_td    ) - word2int( oldoffense->passing_td    ) );

	  int2dword( newoffense->rushing_yards,   dword2int( newoffense->rushing_yards   ) - dword2int( oldoffense->rushing_yards   ) );
	  int2dword( newoffense->passing_yards,   dword2int( newoffense->passing_yards   ) - dword2int( oldoffense->passing_yards   ) );
	  int2dword( newoffense->receiving_yards, dword2int( newoffense->receiving_yards ) - dword2int( oldoffense->receiving_yards ) );
     }
     else
     {
	  // Defense
	  hcdefense_s *newdefense = &(newplayer->role.defense);
	  hcdefense_s *olddefense = &(oldplayer->role.defense);

	  int2word( newdefense->fumble_recoveries, word2int( newdefense->fumble_recoveries ) - word2int( olddefense->fumble_recoveries ) );
	  int2word( newdefense->tackles,           word2int( newdefense->tackles           ) - word2int( olddefense->tackles           ) );
	  int2word( newdefense->sacks,             word2int( newdefense->sacks             ) - word2int( olddefense->sacks             ) );
	  int2word( newdefense->interceptions,     word2int( newdefense->interceptions     ) - word2int( olddefense->interceptions     ) );
     }
}

static void diffTeams( hcteam_s *newteam, hcteam_s *oldteam )
{
     int2dword( newteam->rush_att,        dword2int( newteam->rush_att        ) - dword2int( oldteam->rush_att        ) );
     int2dword( newteam->rush_yards,      dword2int( newteam->rush_yards      ) - dword2int( oldteam->rush_yards      ) );
     int2dword( newteam->fmb_lost,        dword2int( newteam->fmb_lost        ) - dword2int( oldteam->fmb_lost        ) );
     int2dword( newteam->fmb_ret,         dword2int( newteam->fmb_ret         ) - dword2int( oldteam->fmb_ret         ) );
     int2dword( newteam->fmb_ret_yards,   dword2int( newteam->fmb_ret_yards   ) - dword2int( oldteam->fmb_ret_yards   ) );
     int2dword( newteam->pass_att,        dword2int( newteam->pass_att        ) - dword2int( oldteam->pass_att        ) );
     int2dword( newteam->pass_comp,       dword2int( newteam->pass_comp       ) - dword2int( oldteam->pass_comp       ) );
     int2dword( newteam->pass_yards,      dword2int( newteam->pass_yards      ) - dword2int( oldteam->pass_yards      ) );
     int2dword( newteam->pass_int,        dword2int( newteam->pass_int        ) - dword2int( oldteam->pass_int        ) );
     int2dword( newteam->interceptions,   dword2int( newteam->interceptions   ) - dword2int( oldteam->interceptions   ) );
     int2dword( newteam->times_sacked,    dword2int( newteam->times_sacked    ) - dword2int( oldteam->times_sacked    ) );
     int2dword( newteam->sack_yards_lost, dword2int( newteam->sack_yards_lost ) - dword2int( oldteam->sack_yards_lost ) );
     int2dword( newteam->sacks,           dword2int( newteam->sacks           ) - dword2int( oldteam->sacks           ) );
     int2dword( newteam->punts,           dword2int( newteam->punts           ) - dword2int( oldteam->punts           ) );
     int2dword( newteam->total_punt_dist, dword2int( newteam->total_punt_dist ) - dword2int( oldteam->total_punt_dist ) );
     int2dword( newteam->kicks_made,      dword2int( newteam->kicks_made      ) - dword2int( oldteam->kicks_made      ) );
     int2dword( newteam->kicks_att,       dword2int( newteam->kicks_att       ) - dword2int( oldteam->kicks_att       ) );
     int2dword( newteam->punt_returns,    dword2int( newteam->punt_returns    ) - dword2int( oldteam->punt_returns    ) );
     int2dword( newteam->punt_ret_yards,  dword2int( newteam->punt_ret_yards  ) - dword2int( oldteam->punt_ret_yards  ) );
     int2dword( newteam->kickoff_returns, dword2int( newteam->kickoff_returns ) - dword2int( oldteam->kickoff_returns ) );
     int2dword( newteam->kick_ret_yards,  dword2int( newteam->kick_ret_yards  ) - dword2int( oldteam->kick_ret_yards  ) );
     int2dword( newteam->penalties,       dword2int( newteam->penalties       ) - dword2int( oldteam->penalties       ) );
     int2dword( newteam->penalty_yards,   dword2int( newteam->penalty_yards   ) - dword2int( oldteam->penalty_yards   ) );
     int2dword( newteam->rushing_fd,      dword2int( newteam->rushing_fd      ) - dword2int( oldteam->rushing_fd      ) );
     int2dword( newteam->passing_fd,      dword2int( newteam->passing_fd      ) - dword2int( oldteam->passing_fd      ) );
     int2dword( newteam->penalty_fd,      dword2int( newteam->penalty_fd      ) - dword2int( oldteam->penalty_fd      ) );
     int2dword( newteam->possession_time, dword2int( newteam->possession_time ) - dword2int( oldteam->possession_time ) );
     int2dword( newteam->third_downs,     dword2int( newteam->third_downs     ) - dword2int( oldteam->third_downs     ) );
     int2dword( newteam->_3d_conv,        dword2int( newteam->_3d_conv        ) - dword2int( oldteam->_3d_conv        ) );
     int2dword( newteam->rush_td,         dword2int( newteam->rush_td         ) - dword2int( oldteam->rush_td         ) );
     int2dword( newteam->pass_td,         dword2int( newteam->pass_td         ) - dword2int( oldteam->pass_td         ) );
     int2dword( newteam->unknown16,       dword2int( newteam->unknown16       ) - dword2int( oldteam->unknown16       ) );

     int2word( newteam->q1_points,  word2int( newteam->q1_points  ) - word2int( oldteam->q1_points  ) );
     int2word( newteam->q2_points,  word2int( newteam->q2_points  ) - word2int( oldteam->q2_points  ) );
     int2word( newteam->q3_points,  word2int( newteam->q3_points  ) - word2int( oldteam->q3_points  ) );
     int2word( newteam->q4_points,  word2int( newteam->q4_points  ) - word2int( oldteam->q4_points  ) );
     int2word( newteam->ot_points,  word2int( newteam->ot_points  ) - word2int( oldteam->ot_points  ) );
     int2word( newteam->q1_allowed, word2int( newteam->q1_allowed ) - word2int( oldteam->q1_allowed ) );
     int2word( newteam->q2_allowed, word2int( newteam->q2_allowed ) - word2int( oldteam->q2_allowed ) );
     int2word( newteam->q3_allowed, word2int( newteam->q3_allowed ) - word2int( oldteam->q3_allowed ) );
     int2word( newteam->q4_allowed, word2int( newteam->q4_allowed ) - word2int( oldteam->q4_allowed ) );
     int2word( newteam->ot_allowed, word2int( newteam->ot_allowed ) - word2int( oldteam->ot_allowed ) );
}

static void diffStats( hcstats_s *newstats, hcstats_s *oldstats )
{
     int i;

     newstats->games[0]  -= oldstats->games[0];
     newstats->wins[0]   -= oldstats->wins[0];
     newstats->losses[0] -= oldstats->losses[0];
     newstats->ties[0]   -= oldstats->ties[0];

     diffTeams( &(newstats->team_stats[0]),     &(oldstats->team_stats[0])     );
     diffTeams( &(newstats->opponent_stats[0]), &(oldstats->opponent_stats[0]) );

     for ( i = 0; i < 45; ++i )
     {
	  diffPlayers( &(newstats->players[i]), &(oldstats->players[i]) );
     }
}

int main( int argc, char *argv[] )
{
     hcstats_s *newstats;
     hcstats_s *oldstats;


     if ( argc < 4 )
     {
	  printf( "Usage: %s <newstats> <oldstats> <output>.\n", argv[0] );

	  return EXIT_SUCCESS;
     }

     if ( (newstats = readStatsFile( argv[1] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[1] );

          return EXIT_SUCCESS;
     }

     if ( (oldstats = readStatsFile( argv[2] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[2] );

          free( newstats );

          return EXIT_SUCCESS;
     }

     if ( strcmp( newstats->name, oldstats->name ) != 0 )
     {
	  printf( "Stats files for different teams. Exiting.\n" );

	  free( newstats );
	  free( oldstats );

	  return EXIT_SUCCESS;
     }

     diffStats( newstats, oldstats );

     if ( ! writeStatsFile( argv[3], newstats ) )
     {
          printf( "Cannot save stats changes.\n" );

	  free( newstats );
	  free( oldstats );

          return EXIT_FAILURE;
     }

     free( newstats );
     free( oldstats );

     return EXIT_SUCCESS;
}
