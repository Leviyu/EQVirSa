#!/bin/csh

# ==================================================
#	This Script plot the catalog plot of ESF
#	
#	Hongyu DATE: 
#	Key words: 
# ==================================================


# ====================================================
# 			define input parameter of shell 
# ====================================================
set ID = $1
set DATADIR = $2
set PLOTDIR_main = $3
set SHELL_DIR = $4
set PHASE = $5

set VS_FILE_orig = $DATADIR/${ID}_${PHASE}/out.station_stack.info.${PHASE}
foreach EQ (`cat $VS_FILE_orig|awk '{print $2}'|sort|uniq`)
	echo "--> Plot catalog for $EQ"
	csh $SHELL_DIR/c03.catalog_plot_of_ESF.sh $ID $DATADIR $PLOTDIR_main $SHELL_DIR $PHASE $EQ
end 


