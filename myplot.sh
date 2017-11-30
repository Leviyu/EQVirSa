#!/bin/tcsh
#
#	
#
#	This jon try to do the forward tomography algorithm
#
#
# Get input information

set PWD = `pwd`
set ID = T1
set PHASE = S
set EQ = $ID
set WORKDIR = $PWD/WORKDIR
set PLOTDIR = $PWD/PLOTDIR
set SRCDIR = $PWD/code_dir

csh $PWD/code_dir/c01.plot_virsual_station_stack.sh $WORKDIR/$ID/$ID $PLOTDIR $ID $PWD $PHASE $EQ $SRCDIR

