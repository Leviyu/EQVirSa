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


set INFILE = $DATADIR/INFILE
set EQ_PHASE_LIST = `grep -w PHASE_LIST $INFILE | awk 'NR==1 {print $0}' |cut -f2-`
#echo "phase list is $EQ_PHASE_LIST"
set ED_CHECK_FILE = `grep -w ED_CHECK_FILE $INFILE | awk 'NR==1 {print $2}' `
/bin/rm -r $PLOTDIR/$EQ >& /dev/null
/bin/rm -r $DATADIR/$EQ >& /dev/null
mkdir -p $PLOTDIR/$EQ
mkdir -p $DATADIR/$EQ
cp $DATADIR/CMT.data $DATADIR/$EQ/
cp $DATADIR/INFILE* $DATADIR/$EQ/
cp $DATADIR/eventinfo $DATADIR/$EQ/eventinfo


##set new_phase_list = `cat $PWD/eventinfo.final |grep -w $EQ | awk '{print $20}'|sort|uniq |awk '{printf "%s ",$0}'`


	foreach PHASE ( `echo $EQ_PHASE_LIST `)
	##foreach PHASE ( `echo $new_phase_list `)
		echo "============================================================================="
		echo "****Empirical Wavelet Algorithm Running for $EQ   PHASE: $PHASE **********`date`"
		set INPUT = ($EQ $DATADIR  $PLOTDIR $C_DIR $SHELL_DIR   $DIR $PHASE)
		set father =					$SHELL_DIR/c00.go_for_ESF.sh
cp $C_DIR/virtual_station/virtual_station $DATADIR/$EQ
cd $DATADIR/$EQ
set unique_EQ_list = $DATADIR/$EQ/
##get_EQ_sac $EQ/eventStation.${EQ}
cp $PWD/eventStation eventStation
cp $PWD/code_dir/getEventinfoNum .
cp $PWD/code_dir/get_EQ_sac .
##cp eventStation.${EQ} eventStation
# creat EQ_LIST and STA_LIST
set EQ_LIST = $DATADIR/$EQ/list.EQ
set STA_LIST = $DATADIR/$EQ/list.STA

cat $DATADIR/$EQ/eventinfo |grep -w $PHASE |awk '{print $12,$1,$20}'>! $DATADIR/$EQ/eventinfo.EQ.STA.PHASE

./virtual_station <<EOF
$PHASE
EOF

		echo "***Empirical Wavelet Algorithm Ending for $EQ   PHASE: $PHASE **********`date`"
		echo "============================================================================="
	csh $PWD/plot.sh $ID $PHASE $ID $DATADIR $PLOTDIR  $PWD

	end #  PHASE
#csh $PWD/plot.sh $ID $EQ
##/bin/rm -rf $DATADIR/$EQ/1*sac
##/bin/rm -rf $DATADIR/$EQ/2*sac

### check if current EQ is checked 
#set ed_check_file = $ED_CHECK_FILE
#set fff = `cat $ed_check_file |grep $EQ |awk 'NR==1 {print $1}' `
#if($fff != "" ) then
#mv $PLOTDIR/$EQ $PLOTDIR/${EQ}_update
#endif







exit 0




csh $PWD/c15.get_polarity.sh $PWD $WORKDIR $PLOTDIR $PHASE

set S_ES = $PWD/S_EW_DIR/S_ES.${EQ}


./DD << EOF 
$eventinfo $PHASE $S_ES
EOF

cd $PWD
csh $PWD/plot.sh $ID $PHASE $EQ

