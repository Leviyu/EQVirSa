#!/bin/tcsh
#
#	
#
#	This jon try to do the forward tomography algorithm
#
#
# Get input information

set PWD = `pwd`
set ID = T11_big
set PHASE = ScS
set EQ = $ID
set WORKDIR = $PWD/WORKDIR/$ID/$ID
set PLOTDIR = $PWD/PLOTDIR/$ID
set SRCDIR = $PWD/code_dir

csh $PWD/code_dir/c01.plot_virsual_station_stack.sh $WORKDIR $PLOTDIR $ID $PWD $PHASE $EQ $SRCDIR

