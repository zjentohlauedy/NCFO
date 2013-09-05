#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include "hcfiles.h"


int word2int( unsigned char *word )
{
     return (word[0]<<8) + word[1];
}


void int2word( unsigned char *word, int value )
{
     word[0] = (value & 0x0000ff00)>>8;
     word[1] = (value & 0x000000ff);
}


int dword2int( unsigned char *dword )
{
     return (dword[0]<<24) + (dword[1]<<16) + (dword[2]<<8) + dword[3];
}


void int2dword( unsigned char *dword, unsigned int value )
{
     dword[0] = (value & 0xff000000)>>24;
     dword[1] = (value & 0x00ff0000)>>16;
     dword[2] = (value & 0x0000ff00)>>8;
     dword[3] = (value & 0x000000ff);
}


char *positionName( unsigned char position )
{
     switch ( position )
     {
     case pos_Offensive_Tackle: return "OT";
     case pos_Offensive_Guard:  return "OG";
     case pos_Center:           return "CR";
     case pos_Tight_End:        return "TE";
     case pos_Wide_Receiver:    return "WR";
     case pos_Half_Back:        return "HB";
     case pos_Full_Back:        return "FB";
     case pos_Quarter_Back:     return "QB";
     case pos_Defensive_End:    return "DE";
     case pos_Defensive_Tackle: return "DT";
     case pos_Nose_Tackle:      return "NT";
     case pos_Linebacker:       return "LB";
     case pos_Corner_Back:      return "CB";
     case pos_Defensive_Back:   return "DB";
     case pos_Kicker:           return "KI";
     }

     return "NA";
}


hcstats_s *readStatsFile( char *filename )
{
     hcstats_s *statsFile;
     size_t     filesize;
     int        fd;


     filesize = sizeof(hcstats_s);

     if ( (statsFile = malloc( filesize )) == NULL )
     {
	  printf( "Cannot allocate memory for stats file.\n" );

	  return NULL;
     }

     if ( (fd = open( filename, O_RDONLY )) < 0 )
     {
	  printf( "Cannot open file <%s>: %s\n", filename, strerror(errno) );

	  free( statsFile );

	  return NULL;
     }

     if ( read( fd, statsFile, filesize ) < filesize )
     {
	  printf( "Unexpected end of file <%s>.\n", filename );

	  free( statsFile );

	  if ( close( fd ) < 0 )
	  {
	       printf( "Error closing file <%s>: %s\n", filename, strerror(errno) );
	  }

	  return NULL;
     }

     if ( close( fd ) < 0 )
     {
	  printf( "Error closing file <%s>: %s\n", filename, strerror(errno) );

          free( statsFile );

	  return NULL;
     }

     return statsFile;
}


boolean_e writeStatsFile( char *filename, hcstats_s *statsFile )
{
     size_t        filesize;
     int           bytes_written;
     int           fd;


     filesize = sizeof(hcstats_s);

     if ( (fd = creat( filename, S_IRUSR | S_IWUSR )) < 0 )
     {
	  printf( "Cannot open file <%s>: %s\n", filename, strerror(errno) );

	  return bl_False;
     }

     if ( (bytes_written = write( fd, statsFile, filesize )) < filesize )
     {
          if ( bytes_written < 0 )
          {
               printf( "Error writing to output file: %s\n", strerror( errno ) );

               if ( close( fd ) < 0 )
               {
                    printf( "Error closing output file: %s\n", strerror(errno) );
               }

               return bl_False;
          }

          printf( "Warning: incomplete buffer written to output file!\n" );
     }

     if ( close( fd ) < 0 )
     {
	  printf( "Error closing file <%s>: %s\n", filename, strerror(errno) );

	  return bl_False;
     }

     return bl_True;
}
