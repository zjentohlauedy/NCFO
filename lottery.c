#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

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

int main( int argc, char *argv[] )
{
     int token[100];
     int tokens;
     int picks;
     int i;

     if ( argc < 2 )
     {
	  printf( "Usage: %s <num picks>.\n", argv[0] );

	  return EXIT_SUCCESS;
     }

     if ( (picks = atoi( argv[1] )) == 0 )
     {
	  printf( "No picks to make.\n" );

	  return EXIT_SUCCESS;
     }

     for ( i = 0; i < 100; ++i ) token[i] = i;

     srand( time( NULL ) );

     for ( tokens = 100, i = 1; tokens > 0 && i <= picks; --tokens, ++i )
     {
	  usleep( 3000000 + (rand() % 4000000) );

	  shuffle( token, tokens );

	  int pick = rand() % tokens;

	  printf( "Team %d picks token #%02d.\n", i, token[pick] );

	  token[pick] = token[tokens - 1];

	  srand( time( NULL ) );
     }
}
