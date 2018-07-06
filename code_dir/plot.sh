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



#echo "workdir is $WORKDIR "
csh $PWD/code_dir/c03.main.sh $ID $WORKDIR $PLOTDIR $SRCDIR $PHASE 
#csh $PWD/code_dir/c03.catalog_plot_of_ESF.sh $ID $WORKDIR $PLOTDIR $SRCDIR $PHASE
echo "csh $PWD/code_dir/c01.plot_virsual_station_stack.sh $WORKDIR $PLOTDIR $ID $PWD $PHASE $EQ $SRCDIR " >! $WORKDIR/try.${PHASE}.sh
#cd $WORKDIR
#csh try.${PHASE}.sh
#csh $PWD/code_dir/c01.plot_virsual_station_stack.sh $WORKDIR $PLOTDIR $ID $PWD $PHASE $EQ $SRCDIR  


#to_hongyu $PLOTDIR/$ID
