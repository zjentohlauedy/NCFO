#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"


#define SWAP_PLAYER_PTR( P1, P2 ) \
{                                 \
     player_s *px;                \
                                  \
     (px) = (P1);                 \
     (P1) = (P2);                 \
     (P2) = (px);                 \
}


typedef struct
{
     int        number;
     position_e position;
     float      rating;
     int        injury;
     int        games;
     int        selected;

} player_s;


// prototypes
static player_s *find_best_center(           player_s *players, int exclusive );
static player_s *find_best_cornerback(       player_s *players, int exclusive );
static player_s *find_best_defensive_end(    player_s *players, int exclusive );
static player_s *find_best_defensive_tackle( player_s *players, int exclusive );
static player_s *find_best_fullback(         player_s *players, int exclusive );
static player_s *find_best_halfback(         player_s *players, int exclusive );
static player_s *find_best_linebacker(       player_s *players, int exclusive );
static player_s *find_best_offensive_guard(  player_s *players, int exclusive );
static player_s *find_best_offensive_tackle( player_s *players, int exclusive );
static player_s *find_best_quarterback(      player_s *players, int exclusive );
static player_s *find_best_safety(           player_s *players, int exclusive );
static player_s *find_best_tight_end(        player_s *players, int exclusive );
static player_s *find_best_wide_receiver(    player_s *players, int exclusive );

/*
     if ( ! exclusive )
     {
          if ( (alternate = find_best_fullback( players, 1 )) != NULL ) return alternate;
     }
*/

static struct { int rank; } position_order[] = {
     /* pos_Offensive_Tackle */  6,
     /* pos_Offensive_Guard  */  7,
     /* pos_Center           */  8,
     /* pos_Tight_End        */  5,
     /* pos_Wide_Receiver    */  4,
     /* pos_Half_Back        */  2,
     /* pos_Full_Back        */  3,
     /* pos_Quarter_Back     */  1,
     /* pos_Defensive_End    */ 10,
     /* pos_Defensive_Tackle */  9,
     /* pos_Nose_Tackle      */  9,
     /* pos_Linebacker       */ 11,
     /* pos_Corner_Back      */ 12,
     /* pos_Defensive_Back   */ 13,
     /* pos_Kicker           */ 14
};


static void write_lineup( hclineup_s *hclineup, int *lineup )
{
     int i;

     for ( i = 0; i < 11; ++i ) hclineup->players[i] = lineup[i];
}

static int cmpplr( const void *arg1, const void *arg2 )
{
     const player_s *p1 = (player_s *)arg1;
     const player_s *p2 = (player_s *)arg2;
     /**/  int       cmp;

     if ( position_order[p1->position].rank != position_order[p2->position].rank )
          return position_order[p1->position].rank - position_order[p2->position].rank;

     if ( p1->rating != p2->rating ) return (int)(p2->rating * 10.0) - (int)(p1->rating * 10.0);

     return 0;
}

static void clear_selections( player_s *players )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          players[i].selected = 0;
     }
}

static player_s *find_best_quarterback( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Quarter_Back ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_halfback(      players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_wide_receiver( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_cornerback(    players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_halfback( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Half_Back ) continue;

          if ( players[i].selected  ||  players[i].injury > 0) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_fullback(      players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_wide_receiver( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_cornerback(    players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_safety(        players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_fullback( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Full_Back ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_halfback(   players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_tight_end(  players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_safety(     players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_linebacker( players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_center( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Center ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_offensive_guard(  players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_offensive_tackle( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_defensive_tackle( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_defensive_end(    players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_offensive_guard( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Offensive_Guard ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_center(           players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_offensive_tackle( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_defensive_tackle( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_defensive_end(    players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_offensive_tackle( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Offensive_Tackle ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_offensive_guard(  players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_center(           players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_defensive_end(    players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_defensive_tackle( players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_tight_end( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Tight_End ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_fullback(      players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_wide_receiver( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_safety(        players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_linebacker(    players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_wide_receiver( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Wide_Receiver ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_halfback(   players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_tight_end(  players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_cornerback( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_safety(     players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_defensive_tackle( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Defensive_Tackle &&
               players[i].position != pos_Nose_Tackle         ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_defensive_end(    players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_linebacker(       players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_offensive_guard(  players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_offensive_tackle( players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_defensive_end( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Defensive_End ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_defensive_tackle( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_linebacker(       players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_offensive_tackle( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_offensive_guard(  players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_linebacker( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Linebacker ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_defensive_end(    players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_defensive_tackle( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_safety(           players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_fullback(         players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_tight_end(        players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_cornerback( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Corner_Back ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_safety(        players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_wide_receiver( players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_halfback(      players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static player_s *find_best_safety( player_s *players, int exclusive )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Defensive_Back ) continue;

          if ( players[i].selected  ||  players[i].injury > 0 ) continue;

          players[i].selected = 1;

          return &(players[i]);
     }

     if ( ! exclusive )
     {
          player_s *alternate;

          if ( (alternate = find_best_cornerback(    players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_linebacker(    players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_halfback(      players, 1 )) != NULL ) return alternate;
          if ( (alternate = find_best_wide_receiver( players, 1 )) != NULL ) return alternate;
     }

     return NULL;
}

static void select_offense_lineup( player_s *players, int *lineup )
{
     struct
     {
          player_s *quarterback;
          player_s *halfback;
          player_s *fullback;
          player_s *center;
          player_s *left_guard;
          player_s *right_guard;
          player_s *left_tackle;
          player_s *right_tackle;
          player_s *tight_end;
          player_s *split_end;
          player_s *flanker;

     } positions = { 0 };

     positions.quarterback  = find_best_quarterback(      players, 1 );
     positions.halfback     = find_best_halfback(         players, 1 );
     positions.fullback     = find_best_fullback(         players, 1 );
     positions.center       = find_best_center(           players, 1 );
     positions.left_guard   = find_best_offensive_guard(  players, 1 );
     positions.right_guard  = find_best_offensive_guard(  players, 1 );
     positions.left_tackle  = find_best_offensive_tackle( players, 1 );
     positions.right_tackle = find_best_offensive_tackle( players, 1 );
     positions.tight_end    = find_best_tight_end(        players, 1 );
     positions.split_end    = find_best_wide_receiver(    players, 1 );
     positions.flanker      = find_best_wide_receiver(    players, 1 );

     if ( positions.quarterback  == NULL ) positions.quarterback  = find_best_quarterback(      players, 0 );
     if ( positions.halfback     == NULL ) positions.halfback     = find_best_halfback(         players, 0 );
     if ( positions.fullback     == NULL ) positions.fullback     = find_best_fullback(         players, 0 );
     if ( positions.center       == NULL ) positions.center       = find_best_center(           players, 0 );
     if ( positions.left_guard   == NULL ) positions.left_guard   = find_best_offensive_guard(  players, 0 );
     if ( positions.right_guard  == NULL ) positions.right_guard  = find_best_offensive_guard(  players, 0 );
     if ( positions.left_tackle  == NULL ) positions.left_tackle  = find_best_offensive_tackle( players, 0 );
     if ( positions.right_tackle == NULL ) positions.right_tackle = find_best_offensive_tackle( players, 0 );
     if ( positions.tight_end    == NULL ) positions.tight_end    = find_best_tight_end(        players, 0 );
     if ( positions.split_end    == NULL ) positions.split_end    = find_best_wide_receiver(    players, 0 );
     if ( positions.flanker      == NULL ) positions.flanker      = find_best_wide_receiver(    players, 0 );

     // OT  OG  CR  OG  OT  TE  SE  HB  FB  FL  QB
     lineup[ 0] = positions.left_tackle->number;
     lineup[ 1] = positions.left_guard->number;
     lineup[ 2] = positions.center->number;
     lineup[ 3] = positions.right_guard->number;
     lineup[ 4] = positions.right_tackle->number;
     lineup[ 5] = positions.tight_end->number;
     lineup[ 6] = positions.split_end->number;
     lineup[ 7] = positions.halfback->number;
     lineup[ 8] = positions.fullback->number;
     lineup[ 9] = positions.flanker->number;
     lineup[10] = positions.quarterback->number;

     clear_selections( players );
}

static void select_34defense_lineup( player_s *players, int *lineup )
{
     struct
     {
          player_s *nose_tackle;
          player_s *left_end;
          player_s *right_end;
          player_s *left_olb;
          player_s *left_ilb;
          player_s *right_ilb;
          player_s *right_olb;
          player_s *left_corner;
          player_s *right_corner;
          player_s *free_safety;
          player_s *strong_safety;

     } positions = { 0 };

     positions.nose_tackle   = find_best_defensive_tackle( players, 1 );
     positions.left_end      = find_best_defensive_end(    players, 1 );
     positions.right_end     = find_best_defensive_end(    players, 1 );
     positions.left_olb      = find_best_linebacker(       players, 1 );
     positions.left_ilb      = find_best_linebacker(       players, 1 );
     positions.right_ilb     = find_best_linebacker(       players, 1 );
     positions.right_olb     = find_best_linebacker(       players, 1 );
     positions.left_corner   = find_best_cornerback(       players, 1 );
     positions.right_corner  = find_best_cornerback(       players, 1 );
     positions.free_safety   = find_best_safety(           players, 1 );
     positions.strong_safety = find_best_safety(           players, 1 );

     if ( positions.nose_tackle   == NULL ) positions.nose_tackle   = find_best_defensive_tackle( players, 0 );
     if ( positions.left_end      == NULL ) positions.left_end      = find_best_defensive_end(    players, 0 );
     if ( positions.right_end     == NULL ) positions.right_end     = find_best_defensive_end(    players, 0 );
     if ( positions.left_olb      == NULL ) positions.left_olb      = find_best_linebacker(       players, 0 );
     if ( positions.left_ilb      == NULL ) positions.left_ilb      = find_best_linebacker(       players, 0 );
     if ( positions.right_ilb     == NULL ) positions.right_ilb     = find_best_linebacker(       players, 0 );
     if ( positions.right_olb     == NULL ) positions.right_olb     = find_best_linebacker(       players, 0 );
     if ( positions.left_corner   == NULL ) positions.left_corner   = find_best_cornerback(       players, 0 );
     if ( positions.right_corner  == NULL ) positions.right_corner  = find_best_cornerback(       players, 0 );
     if ( positions.free_safety   == NULL ) positions.free_safety   = find_best_safety(           players, 0 );
     if ( positions.strong_safety == NULL ) positions.strong_safety = find_best_safety(           players, 0 );

     // DE  NT  DE  LB  LB  LB  LB  CB  DB  DB  CB
     lineup[ 0] = positions.left_end->number;
     lineup[ 1] = positions.nose_tackle->number;
     lineup[ 2] = positions.right_end->number;
     lineup[ 3] = positions.left_olb->number;
     lineup[ 4] = positions.left_ilb->number;
     lineup[ 5] = positions.right_ilb->number;
     lineup[ 6] = positions.right_olb->number;
     lineup[ 7] = positions.left_corner->number;
     lineup[ 8] = positions.free_safety->number;
     lineup[ 9] = positions.strong_safety->number;
     lineup[10] = positions.right_corner->number;

     clear_selections( players );
}

static void select_43defense_lineup( player_s *players, int *lineup )
{
     struct
     {
          player_s *left_tackle;
          player_s *right_tackle;
          player_s *left_end;
          player_s *right_end;
          player_s *left_olb;
          player_s *middle_lb;
          player_s *right_olb;
          player_s *left_corner;
          player_s *right_corner;
          player_s *free_safety;
          player_s *strong_safety;

     } positions = { 0 };

     positions.left_tackle   = find_best_defensive_tackle( players, 1 );
     positions.right_tackle  = find_best_defensive_tackle( players, 1 );
     positions.left_end      = find_best_defensive_end(    players, 1 );
     positions.right_end     = find_best_defensive_end(    players, 1 );
     positions.left_olb      = find_best_linebacker(       players, 1 );
     positions.middle_lb     = find_best_linebacker(       players, 1 );
     positions.right_olb     = find_best_linebacker(       players, 1 );
     positions.left_corner   = find_best_cornerback(       players, 1 );
     positions.right_corner  = find_best_cornerback(       players, 1 );
     positions.free_safety   = find_best_safety(           players, 1 );
     positions.strong_safety = find_best_safety(           players, 1 );

     if ( positions.left_tackle   == NULL ) positions.left_tackle   = find_best_defensive_tackle( players, 0 );
     if ( positions.right_tackle  == NULL ) positions.right_tackle  = find_best_defensive_tackle( players, 0 );
     if ( positions.left_end      == NULL ) positions.left_end      = find_best_defensive_end(    players, 0 );
     if ( positions.right_end     == NULL ) positions.right_end     = find_best_defensive_end(    players, 0 );
     if ( positions.left_olb      == NULL ) positions.left_olb      = find_best_linebacker(       players, 0 );
     if ( positions.middle_lb     == NULL ) positions.middle_lb     = find_best_linebacker(       players, 0 );
     if ( positions.right_olb     == NULL ) positions.right_olb     = find_best_linebacker(       players, 0 );
     if ( positions.left_corner   == NULL ) positions.left_corner   = find_best_cornerback(       players, 0 );
     if ( positions.right_corner  == NULL ) positions.right_corner  = find_best_cornerback(       players, 0 );
     if ( positions.free_safety   == NULL ) positions.free_safety   = find_best_safety(           players, 0 );
     if ( positions.strong_safety == NULL ) positions.strong_safety = find_best_safety(           players, 0 );

     // DE  DT  DT  DE  LB  LB  LB  CB  DB  DB  CB
     lineup[ 0] = positions.left_end->number;
     lineup[ 1] = positions.left_tackle->number;
     lineup[ 2] = positions.right_tackle->number;
     lineup[ 3] = positions.right_end->number;
     lineup[ 4] = positions.left_olb->number;
     lineup[ 5] = positions.middle_lb->number;
     lineup[ 6] = positions.right_olb->number;
     lineup[ 7] = positions.left_corner->number;
     lineup[ 8] = positions.free_safety->number;
     lineup[ 9] = positions.strong_safety->number;
     lineup[10] = positions.right_corner->number;

     clear_selections( players );
}

static void add_player_to_ranked_list( player_s *player_list[], player_s *player, int list_size )
{
     int i;

     for ( i = 0; i < list_size; ++i )
     {
          if ( player_list[i] == NULL )
          {
               player_list[i] = player;

               break;
          }

          if ( player->rating > player_list[i]->rating ) SWAP_PLAYER_PTR( player_list[i], player );
     }
}

static void select_kickoff_lineup( player_s *players, int *lineup, int kicker )
{
#define num_big_players   6
#define num_fast_players  4

     player_s *big_players [num_big_players ] = { 0 };
     player_s *fast_players[num_fast_players] = { 0 };
     player_s *player                         = NULL;
     int       i;
     int       j;


     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Full_Back  &&
               players[i].position != pos_Tight_End  &&
               players[i].position != pos_Linebacker    ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( big_players, &players[i], num_big_players );
     }

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Half_Back      &&
               players[i].position != pos_Wide_Receiver  &&
               players[i].position != pos_Corner_Back    &&
               players[i].position != pos_Defensive_Back    ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( fast_players, &players[i], num_fast_players );
     }

     for ( i = 0; i < 11; ++i ) lineup[i] = 0;

     // SP  SP  SZ  SZ  SZ  SZ  SZ  SZ  SP  SP  KI
     lineup[ 0] = fast_players[0]->number;
     lineup[ 1] = fast_players[3]->number;
     lineup[ 2] =  big_players[5]->number;
     lineup[ 3] =  big_players[3]->number;
     lineup[ 4] =  big_players[0]->number;
     lineup[ 5] =  big_players[1]->number;
     lineup[ 6] =  big_players[2]->number;
     lineup[ 7] =  big_players[4]->number;
     lineup[ 8] = fast_players[2]->number;
     lineup[ 9] = fast_players[1]->number;
     lineup[10] = kicker;

#undef num_big_players
#undef num_fast_players
}

static void select_punt_lineup( player_s *players, int *lineup, int punter )
{
     struct
     {
          player_s *center;
          player_s *left_guard;
          player_s *right_guard;
          player_s *left_tackle;
          player_s *right_tackle;
          player_s *left_end;
          player_s *right_end;
          player_s *left_gunner;
          player_s *right_gunner;
          player_s *halfback;

     } positions = { 0 };

     positions.center       = find_best_center(           players, 1 );
     positions.left_guard   = find_best_offensive_guard(  players, 1 );
     positions.right_guard  = find_best_offensive_guard(  players, 1 );
     positions.left_tackle  = find_best_offensive_tackle( players, 1 );
     positions.right_tackle = find_best_offensive_tackle( players, 1 );
     positions.left_end     = find_best_tight_end(        players, 1 );
     positions.right_end    = find_best_tight_end(        players, 1 );
     positions.left_gunner  = find_best_wide_receiver(    players, 1 );
     positions.right_gunner = find_best_wide_receiver(    players, 1 );
     positions.halfback     = find_best_halfback(         players, 1 );

     if ( positions.center       == NULL ) positions.center       = find_best_center(           players, 0 );
     if ( positions.left_guard   == NULL ) positions.left_guard   = find_best_offensive_guard(  players, 0 );
     if ( positions.right_guard  == NULL ) positions.right_guard  = find_best_offensive_guard(  players, 0 );
     if ( positions.left_tackle  == NULL ) positions.left_tackle  = find_best_offensive_tackle( players, 0 );
     if ( positions.right_tackle == NULL ) positions.right_tackle = find_best_offensive_tackle( players, 0 );
     if ( positions.left_end     == NULL ) positions.left_end     = find_best_tight_end(        players, 0 );
     if ( positions.right_end    == NULL ) positions.right_end    = find_best_tight_end(        players, 0 );
     if ( positions.left_gunner  == NULL ) positions.left_gunner  = find_best_wide_receiver(    players, 0 );
     if ( positions.right_gunner == NULL ) positions.right_gunner = find_best_wide_receiver(    players, 0 );
     if ( positions.halfback     == NULL ) positions.halfback     = find_best_halfback(         players, 0 );

     // TE  OT  OG  CR  OG  OT  TE  WR  HB  WR  PU
     lineup[ 0] = positions.left_end->number;
     lineup[ 1] = positions.left_tackle->number;
     lineup[ 2] = positions.left_guard->number;
     lineup[ 3] = positions.center->number;
     lineup[ 4] = positions.right_guard->number;
     lineup[ 5] = positions.right_tackle->number;
     lineup[ 6] = positions.right_end->number;
     lineup[ 7] = positions.left_gunner->number;
     lineup[ 8] = positions.halfback->number;
     lineup[ 9] = positions.right_gunner->number;
     lineup[10] = punter;

     clear_selections( players );
}

static void select_kickoff_return_lineup( player_s *players, int *lineup )
{
#define num_big_players  5
#define num_med_players  4
#define num_returners    2

     player_s *big_players [num_big_players] = { 0 };
     player_s *med_players [num_med_players] = { 0 };
     player_s *returners   [num_returners  ] = { 0 };
     player_s *player                        = NULL;
     int       i;
     int       j;


     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Center           &&
               players[i].position != pos_Offensive_Guard  &&
               players[i].position != pos_Offensive_Tackle &&
               players[i].position != pos_Defensive_End    &&
               players[i].position != pos_Defensive_Tackle &&
               players[i].position != pos_Nose_Tackle         ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( big_players, &players[i], num_big_players );
     }

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Full_Back  &&
               players[i].position != pos_Tight_End  &&
               players[i].position != pos_Linebacker    ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( med_players, &players[i], num_med_players );
     }

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Half_Back      &&
               players[i].position != pos_Wide_Receiver  &&
               players[i].position != pos_Corner_Back    &&
               players[i].position != pos_Defensive_Back    ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( returners, &players[i], num_returners );
     }

     for ( i = 0; i < 11; ++i ) lineup[i] = 0;

     // LG  LG  LG  LG  LG  MD  MD  MD  MD  KR  KR
     lineup[ 0] = big_players[3]->number;
     lineup[ 1] = big_players[2]->number;
     lineup[ 2] = big_players[0]->number;
     lineup[ 3] = big_players[1]->number;
     lineup[ 4] = big_players[4]->number;
     lineup[ 5] = med_players[1]->number;
     lineup[ 6] = med_players[0]->number;
     lineup[ 7] = med_players[2]->number;
     lineup[ 8] = med_players[3]->number;
     lineup[ 9] = returners[1]->number;
     lineup[10] = returners[0]->number;

#undef num_big_players
#undef num_med_players
#undef num_returners
}

static void select_punt_return_lineup( player_s *players, int *lineup )
{
#define num_big_players   6
#define num_med_players   2
#define num_fast_players  3

     player_s *big_players  [num_big_players ] = { 0 };
     player_s *med_players  [num_med_players ] = { 0 };
     player_s *fast_players [num_fast_players] = { 0 };
     player_s *player                          = NULL;
     int       i;
     int       j;


     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Linebacker       &&
               players[i].position != pos_Defensive_End    &&
               players[i].position != pos_Defensive_Tackle &&
               players[i].position != pos_Nose_Tackle         ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( big_players, &players[i], num_big_players );
     }

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Full_Back &&
               players[i].position != pos_Tight_End    ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( med_players, &players[i], num_med_players );
     }

     for ( i = 0; i < 45; ++i )
     {
          if ( players[i].position != pos_Half_Back      &&
               players[i].position != pos_Wide_Receiver  &&
               players[i].position != pos_Corner_Back    &&
               players[i].position != pos_Defensive_Back    ) continue;

          if ( players[i].injury > 0 ) continue;

          add_player_to_ranked_list( fast_players, &players[i], num_fast_players );
     }

     for ( i = 0; i < 11; ++i ) lineup[i] = 0;

     // FS  LG  LG  LG  LG  LG  LG  FS  MD  MD  FS
     lineup[ 0] = fast_players[1]->number;
     lineup[ 1] = big_players[4]->number;
     lineup[ 2] = big_players[3]->number;
     lineup[ 3] = big_players[0]->number;
     lineup[ 4] = big_players[1]->number;
     lineup[ 5] = big_players[2]->number;
     lineup[ 6] = big_players[5]->number;
     lineup[ 7] = fast_players[2]->number;
     lineup[ 8] = med_players[1]->number;
     lineup[ 9] = med_players[0]->number;
     lineup[10] = fast_players[0]->number;

#undef num_big_players
#undef num_med_players
#undef num_fast_players
}

static void select_fieldgoal_lineup( player_s *players, int *lineup, int kicker )
{
     struct
     {
          player_s *center;
          player_s *left_guard;
          player_s *right_guard;
          player_s *left_tackle;
          player_s *right_tackle;
          player_s *left_end;
          player_s *right_end;
          player_s *left_wing;
          player_s *right_wing;
          player_s *quarterback;

     } positions = { 0 };

     positions.center       = find_best_center(           players, 1 );
     positions.left_guard   = find_best_offensive_guard(  players, 1 );
     positions.right_guard  = find_best_offensive_guard(  players, 1 );
     positions.left_tackle  = find_best_offensive_tackle( players, 1 );
     positions.right_tackle = find_best_offensive_tackle( players, 1 );
     positions.left_end     = find_best_tight_end(        players, 1 );
     positions.right_end    = find_best_tight_end(        players, 1 );
     positions.left_wing    = find_best_fullback(         players, 1 );
     positions.right_wing   = find_best_fullback(         players, 1 );
     positions.quarterback  = find_best_quarterback(      players, 1 );

     if ( positions.center       == NULL ) positions.center       = find_best_center(           players, 0 );
     if ( positions.left_guard   == NULL ) positions.left_guard   = find_best_offensive_guard(  players, 0 );
     if ( positions.right_guard  == NULL ) positions.right_guard  = find_best_offensive_guard(  players, 0 );
     if ( positions.left_tackle  == NULL ) positions.left_tackle  = find_best_offensive_tackle( players, 0 );
     if ( positions.right_tackle == NULL ) positions.right_tackle = find_best_offensive_tackle( players, 0 );
     if ( positions.left_end     == NULL ) positions.left_end     = find_best_tight_end(        players, 0 );
     if ( positions.right_end    == NULL ) positions.right_end    = find_best_tight_end(        players, 0 );
     if ( positions.left_wing    == NULL ) positions.left_wing    = find_best_fullback(         players, 0 );
     if ( positions.right_wing   == NULL ) positions.right_wing   = find_best_fullback(         players, 0 );
     if ( positions.quarterback  == NULL ) positions.quarterback  = find_best_quarterback(      players, 0 );

     // TE  OT  OG  CR  OG  OT  TE  FB  FB  QB  KI
     lineup[ 0] = positions.left_end->number;
     lineup[ 1] = positions.left_tackle->number;
     lineup[ 2] = positions.left_guard->number;
     lineup[ 3] = positions.center->number;
     lineup[ 4] = positions.right_guard->number;
     lineup[ 5] = positions.right_tackle->number;
     lineup[ 6] = positions.right_end->number;
     lineup[ 7] = positions.left_wing->number;
     lineup[ 8] = positions.right_wing->number;
     lineup[ 9] = positions.quarterback->number;
     lineup[10] = kicker;

     clear_selections( players );
}

static void copy_player( player_s *player, hcplayer_s *hcplayer )
{
     player->number   = hcplayer->number[0];
     player->position = hcplayer->position[0];
     player->rating   = (float)hcplayer->rating[0] / 10.0;
     player->injury   = word2int( hcplayer->injury_duration );
     player->games    = hcplayer->injury_games[0];
}

static void set_lineups( player_s *players, hcstats_s *statsFile, int punter, int kicker )
{
     void (*select_defense_lineup)(player_s *, int *) = NULL;
     int    lineup[11];

     if   ( statsFile->defense[0] == 34 ) select_defense_lineup = select_34defense_lineup;
     else                                 select_defense_lineup = select_43defense_lineup;

     select_offense_lineup(        players, lineup         );  write_lineup( &(statsFile->lineups[ ln_Offense    ]), lineup );
     select_defense_lineup(        players, lineup         );  write_lineup( &(statsFile->lineups[ ln_Defense    ]), lineup );
     select_kickoff_lineup(        players, lineup, kicker );  write_lineup( &(statsFile->lineups[ ln_Kickoff    ]), lineup );
     select_punt_lineup(           players, lineup, punter );  write_lineup( &(statsFile->lineups[ ln_Punt       ]), lineup );
     select_kickoff_return_lineup( players, lineup         );  write_lineup( &(statsFile->lineups[ ln_KickReturn ]), lineup );
     select_punt_return_lineup(    players, lineup         );  write_lineup( &(statsFile->lineups[ ln_PuntReturn ]), lineup );
     select_fieldgoal_lineup(      players, lineup, kicker );  write_lineup( &(statsFile->lineups[ ln_FieldGoal  ]), lineup );
}

static player_s *convert_players( hcstats_s *statsFile )
{
     player_s *players;
     int       i;

     if ( (players = malloc( sizeof(player_s) * 45 )) == NULL )
     {
	  printf( "Cannot allocate memory for players.\n" );

	  return NULL;
     }

     for ( i = 0; i < 45; ++i ) {

	  copy_player( &players[i], &(statsFile->players[i]) );
     }

     qsort( players, 45, sizeof(player_s), cmpplr );

     return players;
}

static void update_player_injuries( hcstats_s *statsFile )
{
     int i;

     for ( i = 0; i < 45; ++i )
     {
          int injury_duration = word2int( statsFile->players[i].injury_duration );

          if ( statsFile->players[i].injury_games[0] > 0 )
          {
               if ( (statsFile->players[i].injury_games[0] -= 1) == 0 )
               {
                    int2word( statsFile->players[i].injury_duration, 0 );

                    printf( "%d %s %s Now able to play.\n",
                            statsFile->players[i].number[0],
                            positionName( statsFile->players[i].position[0] ),
                            statsFile->players[i].name );
               }
               else
               {
                    int2word( statsFile->players[i].injury_duration, AVG_PLAYS_PER_GAME * 2 );

                    printf( "%d %s %s Out for %d games.\n",
                            statsFile->players[i].number[0],
                            positionName( statsFile->players[i].position[0] ),
                            statsFile->players[i].name,
                            statsFile->players[i].injury_games[0] );
               }
          }
          else if ( injury_duration > 0 )
          {
               statsFile->players[i].injury_games[0] = (injury_duration / 150) + (((injury_duration % 150) > 50) ?  1 : 0);

               if ( statsFile->players[i].injury_games[0] > 0 )
               {
                    int2word( statsFile->players[i].injury_duration, AVG_PLAYS_PER_GAME * 2 );

                    printf( "%d %s %s Out for %d games.\n",
                            statsFile->players[i].number[0],
                            positionName( statsFile->players[i].position[0] ),
                            statsFile->players[i].name,
                            statsFile->players[i].injury_games[0] );
               }
               else
               {
                    int2word( statsFile->players[i].injury_duration, 0 );
               }
          }
     }
}

int main( int argc, char *argv[] )
{
     player_s  *players;
     hcstats_s *statsFile;
     int        punter;
     int        kicker;


     if ( argc != 2  &&  argc != 4 )
     {
	  printf( "Usage: %s <statsfile> [<punter> <kicker>].\n", argv[0] );

	  return EXIT_SUCCESS;
     }

     if ( (statsFile = readStatsFile( argv[1] )) == NULL )
     {
          printf( "Unable to load stats file <%s>.\n", argv[1] );

          return EXIT_SUCCESS;
     }

     punter = (argc == 4) ? atoi(argv[2]) : statsFile->lineups[ ln_Punt      ].players[10];
     kicker = (argc == 4) ? atoi(argv[3]) : statsFile->lineups[ ln_FieldGoal ].players[10];

     update_player_injuries( statsFile );

     if ( (players = convert_players( statsFile )) == NULL )
     {
          printf( "Unable to convert players.\n" );

          free( statsFile );

          return EXIT_SUCCESS;
     }

     set_lineups( players, statsFile, punter, kicker );

     if ( ! writeStatsFile( argv[1], statsFile ) )
     {
          printf( "Cannot save stats changes.\n" );

	  free( statsFile );
          free( players );

          return EXIT_FAILURE;
     }

     free( statsFile );
     free( players );

     return EXIT_SUCCESS;
}
