#ifndef _HCFILES_H_
#define _HCFILES_H_

#define AVG_PLAYS_PER_GAME  150

typedef enum
{
     bl_False = 0,
     bl_True  = 1

} boolean_e;

typedef enum
{
     ln_Offense    = 0,
     ln_Defense    = 1,
     ln_Kickoff    = 2,
     ln_Punt       = 3,
     ln_KickReturn = 4,
     ln_PuntReturn = 5,
     ln_FieldGoal  = 6

} lineup_e;

typedef enum
{
     pos_Offensive_Tackle = 0,
     pos_Offensive_Guard,
     pos_Center,
     pos_Tight_End,
     pos_Wide_Receiver,
     pos_Half_Back,
     pos_Full_Back,
     pos_Quarter_Back,
     pos_Defensive_End,
     pos_Defensive_Tackle,
     pos_Nose_Tackle,
     pos_Linebacker,
     pos_Corner_Back,
     pos_Defensive_Back,
     pos_Kicker

} position_e;

typedef struct
{
     unsigned char players [11];

} hclineup_s;

typedef struct
{
     unsigned char  carries              [ 2];
     unsigned char  fumbles_lost         [ 2];
     unsigned char  attempts             [ 2];
     unsigned char  completions          [ 2];
     unsigned char  interceptions        [ 2];
     unsigned char  receptions           [ 2];
     unsigned char  filler2              [ 4];
     unsigned char  rushing_td           [ 2];
     unsigned char  rushing_yards        [ 4];
     unsigned char  passing_yards        [ 4];
     unsigned char  receiving_yards      [ 4];
     unsigned char  filler3              [ 8];
     unsigned char  receiving_td         [ 2];
     unsigned char  passing_td           [ 2];
     unsigned char  filler4              [10];

} hcoffense_s;

typedef struct
{
     unsigned char  fumble_recoveries    [ 2];
     unsigned char  tackles              [ 2];
     unsigned char  sacks                [ 2];
     unsigned char  interceptions        [ 2];
     unsigned char  filler2              [44];

} hcdefense_s;

typedef struct
{
     unsigned char  name                 [20];
     unsigned char  number               [ 1];
     unsigned char  position             [ 1];
     unsigned char  rating               [ 1];
     unsigned char  pass_block_rating    [ 1];
     unsigned char  run_block_rating     [ 1];
     unsigned char  pass_catch_rating    [ 1];
     unsigned char  run_speed_rating     [ 1];
     unsigned char  run_strength_rating  [ 1];
     unsigned char  pass_strength_rating [ 1];
     unsigned char  pass_accuracy_rating [ 1];
     unsigned char  scramble_tendency    [ 1];
     unsigned char  run_defense_rating   [ 1];
     unsigned char  pass_defense_rating  [ 1];
     unsigned char  pass_rush_rating     [ 1];
     unsigned char  unknown1             [ 1];
     unsigned char  filler1              [46];
     unsigned char  injury_games         [ 1];

     union
     {
	  hcoffense_s offense;
	  hcdefense_s defense;

     } role;

     unsigned char  injury_duration      [ 2];

} hcplayer_s;

typedef struct
{
     unsigned char  rush_att        [  4];
     unsigned char  rush_yards      [  4]; // x10
     unsigned char  fmb_lost        [  4]; // fumbles
     unsigned char  fmb_ret         [  4];
     unsigned char  fmb_ret_yards   [  4]; // x10
     unsigned char  pass_att        [  4];
     unsigned char  pass_comp       [  4];
     unsigned char  pass_yards      [  4];
     unsigned char  pass_int        [  4];
     unsigned char  interceptions   [  4];
     unsigned char  times_sacked    [  4];
     unsigned char  sack_yards_lost [  4]; // x10
     unsigned char  sacks           [  4];
     unsigned char  punts           [  4];
     unsigned char  total_punt_dist [  4]; // x10
     unsigned char  kicks_att       [  4];
     unsigned char  kicks_made      [  4];
     unsigned char  punt_returns    [  4];
     unsigned char  punt_ret_yards  [  4]; // x10
     unsigned char  kickoff_returns [  4];
     unsigned char  kick_ret_yards  [  4]; // x10
     unsigned char  penalties       [  4];
     unsigned char  penalty_yards   [  4]; // x10?
     unsigned char  rushing_fd      [  4];
     unsigned char  passing_fd      [  4];
     unsigned char  penalty_fd      [  4];
     unsigned char  possession_time [  4]; // in seconds
     unsigned char  third_downs     [  4];
     unsigned char  _3d_conv        [  4];
     unsigned char  q1_points       [  2];
     unsigned char  q2_points       [  2];
     unsigned char  q3_points       [  2];
     unsigned char  q4_points       [  2];
     unsigned char  ot_points       [  2];
     unsigned char  q1_allowed      [  2];
     unsigned char  q2_allowed      [  2];
     unsigned char  q3_allowed      [  2];
     unsigned char  q4_allowed      [  2];
     unsigned char  ot_allowed      [  2];
     unsigned char  rush_td         [  4];
     unsigned char  pass_td         [  4];
     unsigned char  unknown16       [  4];

} hcteam_s;

typedef struct
{
     unsigned char  games           [  1];
     unsigned char  wins            [  1];
     unsigned char  losses          [  1];
     unsigned char  ties            [  1];
     unsigned char  name            [131];
     unsigned char  defense         [  1];
     unsigned char  unknown1        [  1];
     unsigned char  unknown2        [  1];
     unsigned char  unknown3        [  4];
     unsigned char  unknown4        [  4];
     unsigned char  home_jersey     [  2]; // 0RGB
     unsigned char  home_letter     [  2];
     unsigned char  road_jersey     [  2];
     unsigned char  road_letter     [  2];
     unsigned char  punt_avg        [  2]; // x10
     unsigned char  unknown5        [  1];
     unsigned char  unknown6        [  1];
     unsigned char  punt_ret_avg    [  2]; // x10
     unsigned char  kick_ret_avg    [  2]; // x10
     unsigned char  unknown7        [  1];
     unsigned char  unknown8        [  1];
     unsigned char  unknown9        [  2];
     unsigned char  unknown10       [  1];
     unsigned char  unknown11       [  1];
     unsigned char  unknown12       [  1];
     unsigned char  filler1         [149];
     hcteam_s       team_stats      [  1];
     hcplayer_s     players         [ 45];
     unsigned char  filler2         [270];
     unsigned char  unknown17       [ 24];
     hclineup_s     lineups         [  7];
     unsigned char  unknown18       [ 77];
     hcteam_s       opponent_stats  [  1];

} hcstats_s;

int word2int( unsigned char *word );
void int2word( unsigned char *word, int value );
int dword2int( unsigned char *dword );
void int2dword( unsigned char *dword, unsigned int value );
hcstats_s *readStatsFile( char *filename );
boolean_e writeStatsFile( char *filename, hcstats_s *statsFile );
char *positionName( unsigned char position );

#endif
