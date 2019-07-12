#!/bin/tcsh
#
#	
#
# This project try to implement the following tasks:
# 1. read in the eventStation from one EQ
# 	 read in PHASE name
# 2. Define grid points around global
# 3. for each grid point
# 	a. find stations within range
#	b. relocate the grid center based on the stations in range
# 	b. stack stations relative to PREM predicted time
#			during stacking
#			we recalculate the stacked SNR
#			stations are weighted based on gaussian distribution
#


## ======= Read in parameter ===========
set PWD = 		$1
set DATADIR = 	$2
set PLOTDIR = 	$3
set EQ =		$4
set C_DIR = 	$5
set SHELL_DIR = $6
set ID =		$7
set DIR = 		$8
set PHASE = 	$9

set INFILE = $DATADIR/INFILE
mkdir -p $PLOTDIR/$EQ
mkdir -p $DATADIR/$EQ
cp $DATADIR/CMT.data $DATADIR/$EQ/
cp $DATADIR/INFILE* $DATADIR/$EQ/
cp $DATADIR/eventinfo $DATADIR/$EQ/eventinfo

echo "============================================================================="
echo "****Empirical Wavelet Algorithm Running for $EQ   PHASE: $PHASE **********`date`"
set INPUT = ($EQ $DATADIR  $PLOTDIR $C_DIR $SHELL_DIR   $DIR $PHASE)
set father = $SHELL_DIR/c00.go_for_ESF.sh

cp $C_DIR/virtual_station/virtual_station $DATADIR/$EQ
cd $DATADIR/$EQ
set unique_EQ_list = $DATADIR/$EQ/
##get_EQ_sac $EQ/eventStation.${EQ}
cp $PWD/eventStation eventStation
cp $PWD/code_dir/getEventinfoNum .
cp $PWD/code_dir/get_EQ_sac .
cp $PWD/code_dir/c04.plot_VS_for_current_VS.sh .
cp $PWD/code_dir/c05.run_c04_in_background.sh .
cp $PWD/code_dir/make_polar .
cp $PWD/code_dir/c06.record_filter_and_resample.sh .
cp $PWD/code_dir/unique_station.list .
#//cp $PWD/code_dir/list.unique_EQ .


# prepare a plot_script INPUT for ivs
echo $DATADIR $PLOTDIR $ID $PWD $PHASE $EQ $PWD/code_dir >! $DATADIR/$EQ/INPUT.plot

cat $DATADIR/$EQ/eventinfo |grep -w $PHASE |awk '{print $12,$1,$20}'>! $DATADIR/$EQ/eventinfo.EQ.STA.PHASE
./virtual_station <<EOF
$PHASE 
EOF

echo "***Empirical Wavelet Algorithm Ending for $EQ   PHASE: $PHASE **********`date`"
echo "============================================================================="
csh $PWD/code_dir/plot.sh $ID $PHASE $EQ $DATADIR $PLOTDIR  $PWD 

exit 0

