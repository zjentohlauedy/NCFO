#!/bin/bash
#
ME=`basename $0`;
EXE=~/Amiga/HD/NCFO/diffhcstats;
DIR=$1;

if [[ $# -ne 1 ]];
then
    echo "Usage: $ME <path>";
    echo "Where path is where the old stat files are located";
    exit;
fi

if [[ ! -x $DIR ]];
then
    echo "ERROR: directory <$1> does not exist!"
    exit;
fi

if [[ ! -x $EXE ]];
then
    echo "WARNING: cannot find diffhcstats program!";
    exit;
fi

for file in `ls -1 *.stat`;
do
    TEAM=`basename $file .stat`;

    $EXE $TEAM.stat $DIR/$TEAM.stat $TEAM.statx
done
