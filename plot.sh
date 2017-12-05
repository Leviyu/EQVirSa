#!/bin/tcsh
#
#	
#
#	This jon try to do the forward tomography algorithm
#
#
# Get input information

set ID = $1
set PHASE = $2
set EQ = $3
set WORKDIR = $4
set PLOTDIR = $5
set PWD = $6
set SRCDIR = $PWD/code_dir
#//echo $ID 




csh $PWD/code_dir/c01.plot_virsual_station_stack.sh $WORKDIR $PLOTDIR $ID $PWD $PHASE $EQ $SRCDIR

to_hongyu $PLOTDIR
