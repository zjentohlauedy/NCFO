#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>


#define SWAP( A, B )  do { int x = A; A = B; B = x; } while ( 0 )


typedef struct
{
     int road;
     int home;

} game_s;


static game_s games[10][24]     = { 0 };
static int    teams[48]         = { 0 };
static int    day;
static char   teamNames[48][16] = { 0 };


static void initTeamNames( void )
{
     // New England
     strcpy( teamNames[ 0], "Connecticut"    );
     strcpy( teamNames[ 1], "Maine"          );
     strcpy( teamNames[ 2], "Massachusetts"  );
     strcpy( teamNames[ 3], "New Hampshire"  );
     strcpy( teamNames[ 4], "Rhode Island"   );
     strcpy( teamNames[ 5], "Vermont"        );
     // Atlantic
     strcpy( teamNames[ 6], "Delaware"       );
     strcpy( teamNames[ 7], "Maryland"       );
     strcpy( teamNames[ 8], "New Jersey"     );
     strcpy( teamNames[ 9], "New York"       );
     strcpy( teamNames[10], "Virginia"       );
     strcpy( teamNames[11], "West Virginia"  );
     // Southeast
     strcpy( teamNames[12], "Alabama"        );
     strcpy( teamNames[13], "Florida"        );
     strcpy( teamNames[14], "Georgia"        );
     strcpy( teamNames[15], "North Carolina" );
     strcpy( teamNames[16], "South Carolina" );
     strcpy( teamNames[17], "Tennessee"      );
     // Great Lake
     strcpy( teamNames[18], "Illinois"       );
     strcpy( teamNames[19], "Indiana"        );
     strcpy( teamNames[20], "Kentucky"       );
     strcpy( teamNames[21], "Michigan"       );
     strcpy( teamNames[22], "Ohio"           );
     strcpy( teamNames[23], "Pennsylvania"   );
     // Southwest
     strcpy( teamNames[24], "Arizona"        );
     strcpy( teamNames[25], "California"     );
     strcpy( teamNames[26], "Colorado"       );
     strcpy( teamNames[27], "Nevada"         );
     strcpy( teamNames[28], "New Mexico"     );
     strcpy( teamNames[29], "Utah"           );
     // Northwest
     strcpy( teamNames[30], "Idaho"          );
     strcpy( teamNames[31], "Montana"        );
     strcpy( teamNames[32], "Nebraska"       );
     strcpy( teamNames[33], "Oregon"         );
     strcpy( teamNames[34], "Washington"     );
     strcpy( teamNames[35], "Wyoming"        );
     // Midwest
     strcpy( teamNames[36], "Iowa"           );
     strcpy( teamNames[37], "Kansas"         );
     strcpy( teamNames[38], "Minnesota"      );
     strcpy( teamNames[39], "North Dakota"   );
     strcpy( teamNames[40], "South Dakota"   );
     strcpy( teamNames[41], "Wisconsin"      );
     // South
     strcpy( teamNames[42], "Arkansas"       );
     strcpy( teamNames[43], "Louisiana"      );
     strcpy( teamNames[44], "Mississippi"    );
     strcpy( teamNames[45], "Missouri"       );
     strcpy( teamNames[46], "Oklahoma"       );
     strcpy( teamNames[47], "Texas"          );
}


static void shuffle( int list[], int length )
{
     int i;

     // Randomize the schedule
     for( i = length; i > 1; --i )
     {
          int n = rand() % (i - 1);
          int x;

          x           = list[n    ];
          list[n    ] = list[i - 1];
          list[i - 1] = x;
     }

}


static void rotate( int list[], int length )
{
     int i;
     int x = list[length - 1];

     for ( i = length - 1; i > 0; --i )
     {
          list[i] = list[i - 1];
     }

     list[0] = x;
}


static void scheduleDivisionGames( game_s *gameday )
{
     int i;
     int j;

     for ( i = 0; i < 48; i += 6 )
     {
          for ( j = 0; j < 3; ++j )
          {
               int match = (i / 2) + j;
               int road  = i + j;
               int home  = i + 5 - j;

	       // Find the last time the teams played and make sure location is reversed
               {
                    int x, y;

                    for ( x = day - 1; x >= 0; --x )
                    {
                         game_s *g = games[x];

                         for ( y = 0; y < 24; ++y )
                         {
                              if ( g[y].road == teams[home]  &&  g[y].home == teams[road] ) goto done;

                              if ( g[y].road == teams[road]  &&  g[y].home == teams[home] )
                              {
                                   SWAP( road, home );

                                   goto done;
                              }
                         }
                    }
               }

          done:
               gameday[match].road = teams[road];
               gameday[match].home = teams[home];
          }
     }
}


void initMagicNumbers( int *array, size_t length, int max_value )
{
     for (int i = 0; i < length; ++i ) array[i] = -1;

     for ( int i = 0; i < length; ++i )
     {
	  int n = -1;

	  do
	  {
	       n = rand() % max_value;

	       for ( int j = 0; j < i; ++j )
	       {
		    if ( n == array[j] )
		    {
			 n = -1;

			 break;
		    }
	       }
	  }
	  while ( n < 0 );

	  array[i] = n;
     }
}


void main( int argc, char *argv[] )
{
     time_t  t = time( NULL );
     int     mx[24];
     int     my[10];

     // seed random number generator...
     srand( t );

     for ( int i = 0; i < 48; ++i ) teams[i] = i;

     initMagicNumbers( mx, 24, 99 );
     initMagicNumbers( my, 10, 99 );

     day = 0;

     // Divisions
     shuffle( &teams[ 0], 6 );
     shuffle( &teams[ 6], 6 );
     shuffle( &teams[12], 6 );
     shuffle( &teams[18], 6 );
     shuffle( &teams[24], 6 );
     shuffle( &teams[30], 6 );
     shuffle( &teams[36], 6 );
     shuffle( &teams[42], 6 );

     for ( int series = 0; series < 6 - 1; ++series )
     {
          for ( int round = 0; round < 2; ++round )
          {
               scheduleDivisionGames( games[day] );

               day++;
          }

          // Rotate each division individually (first team in each div. stays put)
          rotate( &teams[ 0], 6 - 1 );
          rotate( &teams[ 6], 6 - 1 );
          rotate( &teams[12], 6 - 1 );
          rotate( &teams[18], 6 - 1 );
          rotate( &teams[24], 6 - 1 );
          rotate( &teams[30], 6 - 1 );
          rotate( &teams[36], 6 - 1 );
          rotate( &teams[42], 6 - 1 );
     }

     // Randomize the schedule
     for( int j = 0; j < 24; j += 3 )
     {
	  for( int i = 10; i > 1; --i )
	  {
	       int n = rand() % (i - 1);

	       // swap n and i - 1;
	       game_s  gameday[3];

	       memcpy(  gameday,         &games[n    ][j], sizeof(game_s) * 3 );
	       memcpy( &games[n    ][j], &games[i - 1][j], sizeof(game_s) * 3 );
	       memcpy( &games[i - 1][j],  gameday,         sizeof(game_s) * 3 );
	  }
     }

     // Randomize the games within each gameday
     for ( int i = 0; i < 10; ++i )
     {
	  for ( int j = 24; j > 1; --j )
	  {
	       int n = rand() % (j - 1);

	       // swap n and i - 1;
	       game_s  game;

	       game            = games[i][j - 1];
	       games[i][j - 1] = games[i][n];
	       games[i][n]     = game;
	  }
     }

     initTeamNames();

     for ( int i = 0; i < 24; ++i )
     {
	  if ( i > 0 )
	  {
	       printf( ",%02d,", mx[i - 1] );
	  }
	  else
	  {
	       printf( ","  );
	  }

	  printf( "%02d", i + 1 );
     }

     printf( ",%02d\n", mx[23] );

     for ( int i = 0; i < 10; ++i )
     {

	  printf( "%02d", my[i] );

	  for ( int j = 0; j < 24; ++j )
	  {
	       if   ( j > 0 ) printf( ",," );
	       else           printf( ","  );

	       printf( "%s", teamNames[games[i][j].road] );
	  }

	  printf( "\n" );
	  printf( "%02d", i + 1 );

	  for ( int j = 0; j < 24; ++j )
	  {
	       if   ( j > 0 ) printf( ",," );
	       else           printf( ","  );

	       printf( "%s", teamNames[games[i][j].home] );
	  }

	  printf( "\n" );

	  printf( ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n" );
     }
}

