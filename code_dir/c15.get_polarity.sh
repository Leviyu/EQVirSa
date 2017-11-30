#!/bin/csh
# ====================================================================
# This is a csh script to get the polarity for record
# 
# 	We dont use polar info for ScS and Sdiff
#
# Input:	CMT 
#			PHASE
#			COMP
# Output:
#
#
# DATE:					Keywords:
#
# Reference:
# ===================================================================


set PWD = $1
set WORKDIR = $2
set PLOTDIR = $3
set PHASE = $4
#set PWD = `pwd`
#set WORKDIR = $PWD/KKK
#set PLOTDIR = $PWD/KKK
#set PHASE = S


set polarity_info = $WORKDIR/eventinfo.polarity
set eventStation = $WORKDIR/eventStation
set work_dir = $WORKDIR

set EQ = `cat $eventStation |awk 'NR==2 {print $19}'`

set CMT_file = $work_dir/CMT.data
set CMT = `grep -w $EQ $CMT_file`
echo "----> Looking for CMT Info "
set EQ_name_found = `echo $CMT |awk '{print $1}'`

# if we dont find CMT info, we dont use CMT
if( $EQ_name_found  == "" ) then
echo "----> CMT for $EQ is not found"
awk '{print $1,0}' $eventStation > $polarity_info
exit 0
else 
echo "----> CMT for $EQ is $CMT"
endif

set strike =  $CMT[2]
set dip = $CMT[3]
set rake = $CMT[4]

echo $strike $dip $rake
set CMT2RAD = $PWD/radiation.f90
f95 $CMT2RAD -o CMT2RAD
CMT2RAD << EOF > & /dev/null
$strike $dip $rake
EOF

# find the component P SV SH for current phase
#if(`echo $PHASE |grep P` != "") then
	#set the_comp = P
#endif

#if(`echo $PHASE |grep S` != "") then
	#if( $COMP == T ) then
	#set the_comp = SH
	#else if($COMP == R ) then
	#set the_comp = SV
	#endif
#endif

set the_comp = SH

set RADTHAZ = $PWD/radiation_th,az.f
f95 $RADTHAZ -o RADTHAZ
/bin/rm -r $polarity_info > & /dev/null
foreach STA (`awk '{print $1}' $eventStation`)
	set TMP = `awk -v sta=$STA '$1==sta {print $0}' $eventStation`
	set DIST = $TMP[3]
	set AZ = $TMP[5]
	set EQ_DEP = $TMP[13]


	set take_off = `csh $PWD/c101.get_taup_takeoff_for_record.sh $EQ $STA $PHASE $WORKDIR|awk 'NR==1 {print $1}'`

##if(`echo $PHASE | grep m ` != "" ) then
##set PHASE = `echo $PHASE | sed 's/.$//' `
##endif
##set take_off = `taup_time -mod prem -ph $PHASE -deg $DIST -h $EQ_DEP | awk 'NR==6 {print $6}'`

##echo $STA $strike $dip $rake $the_comp $take_off $AZ	
RADTHAZ <<EOF >$work_dir/polarity.tmp
$strike $dip $rake
$the_comp
$take_off $AZ
EOF

	set polar_pre = `awk -v sta=$STA 'NR==1 {print $1}' $work_dir/polarity.tmp`
	
	echo "$STA $polar_pre" >> $polarity_info

	end	#STA


	echo "--> Looking for CMT and polar info DONE"

exit 0


