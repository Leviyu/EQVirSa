#!/bin/tcsh



# this script is called in each event`s directory


set sac_file = $1
set PHASE = $2
set sod_sac = $3

set INFILE = ./INFILE

set delta = `cat $INFILE |grep -w DELTA |awk '{print $2}'`

set filter = `cat $INFILE |grep -w FILTER_FLAG |awk '{$1="";print $0 }'`
set sacname = $sac_file

set macro = ./sac.macro
cat /dev/null >! $macro



# ================================
# Deal with SS Huawei
if( $PHASE == "SS" || $PHASE == "SSm") then
cat<< EOF >> $macro
r $sod_sac
interpolate delta $delta
dif
$filter
hilbert
write $sac_file
EOF
else if( $PHASE == "S3" || $PHASE == "S3m" ) then
cat<< EOF >> $macro
r $sod_sac
interpolate delta $delta
dif
$filter
mul -1
write $sac_file
EOF
else if( $PHASE == "S4" || $PHASE == "S4m" ) then
cat<< EOF >> $macro
r $sod_sac
interpolate delta $delta
dif
$filter
mul -1
hilbert
write $sac_file
EOF
else if( $PHASE == "S5" || $PHASE == "S5m" ) then
cat<< EOF >> $macro
r $sod_sac
interpolate delta $delta
dif
$filter
write $sac_file
EOF
else if( $PHASE == "S6" || $PHASE == "S6m"  ) then
cat<< EOF >> $macro
r $sod_sac
interpolate delta $delta
dif
$filter
hilbert
write $sac_file
EOF
else
cat<< EOF >> $macro
r $sod_sac
interpolate delta $delta
dif
$filter
write $sac_file
EOF

endif
sac < $macro > & /dev/null

exit 0
