#!/bin/tcsh



set WORKDIR = $1
set PLOTDIR = $2
set ID = $3
set PWD = $4
set PHASE = $5
set EQ = $6
set SRCDIR = $7

# gmtset PAPER_MEDIA = A4
# gmtset ANNOT_FONT_SIZE_PRIMARY = 10
# gmtset ANNOT_FONT_SIZE_SECONDARY = 10
# gmtset LABEL_FONT_SIZE = 10

gmtset PS_MEDIA = A4
gmtset FONT_ANNOT_PRIMARY = 10
gmtset FONT_ANNOT_SECONDARY = 10
gmtset FONT_LABEL = 10

set OUT = $PLOTDIR/c01.${PHASE}_virsual_station_stack.ps
set OUT_pdf = $PLOTDIR/c01.${PHASE}_virsual_station_stack.pdf
cat /dev/null >! $OUT

cat << EOF >> $OUT
[ /_objdef {ZaDb} /type /dict /OBJ pdfmark
[ {ZaDb} <<
    /Type /Font
    /Subtype /Type1
    /Name /ZaDb
    /BaseFont /ZapfDingbats
>> /PUT pdfmark
[ /_objdef {Helv} /type /dict /OBJ pdfmark
[ {Helv} <<
    /Type /Font
    /Subtype /Type1
    /Name /Helv
    /BaseFont /Helvetica
>> /PUT pdfmark
[ /_objdef {aform} /type /dict /OBJ pdfmark
[ /_objdef {afields} /type /array /OBJ pdfmark
[ {aform} <<
    /Fields {afields}
    /DR << /Font << /ZaDb {ZaDb} /Helv {Helv} >> >>
    /DA (/Helv 0 Tf 0 g)
    /NeedAppearances true
>> /PUT pdfmark
[ {Catalog} << /AcroForm {aform} >> /PUT pdfmark
EOF


set grid_info = $WORKDIR/out.station_stack.info.${PHASE}
cat $grid_info
set bk_grid_info = $WORKDIR/out.station_stack.info.${PHASE}.bk
cp $grid_info $bk_grid_info

##cat $bk_grid_info |grep -v radius |sort -k 15 -n -r >! $grid_info

#sort -k 15 -n -r $bk_grid_info >! $grid_info

set NUM_MAX = `cat $grid_info |wc -l`
set NUM = 1
echo "=====> Working on c01 stack for virsual station"
while ($NUM <= $NUM_MAX )
	echo "--> work on $NUM / $NUM_MAX"

set TMP = `cat $grid_info|awk -v dd=$NUM 'NR==dd {print $0}'`

set vs_index = $TMP[1]
set EQ_name = $TMP[2]
set eq_lat = $TMP[3]
set eq_lon = $TMP[4]
set eq_rad = $TMP[5]
set sta_lat = $TMP[6]
set sta_lon = $TMP[7]
set sta_rad = $TMP[8]
set record_num = $TMP[9]
set grid_dist = $TMP[10]
##set ilat = $TMP[1]
##set ilon = $TMP[2]
####set lat = $TMP[3]
##set lon = $TMP[4]
set grid_lat = $sta_lat
set grid_lon = $sta_lon
##set radius = $TMP[5]
##set record_num = $TMP[6]
set record_list_file = $WORKDIR/out.VS_eventStation_list.${PHASE}.${vs_index}
##set record_list_file = $WORKDIR/out.grid_station_list.${PHASE}.${ilat}.${ilon}

##set ave_SNR = $TMP[8]
##set stack_SNR = $TMP[9]
##set ONSET = $TMP[10]
##set tstar_ccc = $TMP[11]
##set tstar_factor = $TMP[12]
##set gau_ccc = $TMP[13]
##set gau_factor = $TMP[14]
##set quality = $TMP[15]

set event_tmp = $WORKDIR/eventStation
set TTT = `cat $event_tmp |grep -w $EQ_name|awk 'NR==2 {print $0}'`
echo $TTT
set EQ_lat = $TTT[11]
set EQ_lon = $TTT[12]
set EQ_dep = $TTT[13]
set EQ_mag = $TTT[16]

echo "--> Add text"
pstext  -JX4i/1.5i -R0/10/0/10 -K -N -Y6i << EOF >> $OUT
0 12 10 0 0 LB Virsual Station Stack
0 11 10 0 0 LB EQ: $EQ_name 
0 10 10 0 0 LB LAT/LON: $EQ_lat $EQ_lon DEP: $EQ_dep MAG:$EQ_mag
0 9 10 0 0 LB EQ_LAT/LON/Radius  $eq_lat / $eq_lon / $eq_rad
0 8 10 0 0 LB STA_LAT/LON/Radius $sta_lat / $sta_lon / $sta_rad
0 7 10 0 0 LB Records within range: $record_num
0 6 10 0 0 LB PHASE: $PHASE
EOF
##0 5 10 0 0 LB ave_SNR: $ave_SNR stack_SNR: $stack_SNR

## add a quality marker here
##if ($quality == 1 ) then
	##psxy -JX -R -O -K -Sa0.5 -Gred -N << EOF >> $OUT
	##10 5
	##EOF
	##endif



## ========================================
## add station map
echo "--> Add station map"
##set sta_lon = $lon
##set sta_lat = $lat
set LONINC = 30
set LATINC = 30
set LONMIN = `echo "$sta_lon - $LONINC"|bc -l`
set LONMAX = `echo "$sta_lon + $LONINC"|bc -l`
set LATMIN = `echo "$sta_lat - $LATINC"|bc -l`
set LATMAX = `echo "$sta_lat + $LATINC"|bc -l`
if(`printf %.0f $LATMIN `< -90) then
set LATMIN = -90
endif
if(`printf %.0f $LATMAX ` > 90) then
set LATMAX = 90
endif
##if(`printf %.0f $LONMAX ` > 180) then
##set LONMAX = `echo "$LONMAX - 360"|bc -l`
##endif
##if(`printf %.0f $LONMIN ` < -180) then
##set LONMIN = `echo "$LONMIN + 360"|bc -l`
##endif

##//echo "$LATMIN $LATMAX $LONMIN $LONMAX"


set REG = -R$LONMIN/$LONMAX/$LATMIN/$LATMAX
set PROJ = -JQ$sta_lon/$sta_lat/3i
##set PROJ = -JG$sta_lon/$sta_lat/3i
set land = "255/255/160"
set sea = 103/204/0

pscoast $REG $PROJ -Ba10/a10wsne -Dh -G$land -A40000 -W0.5 -O  -Y-5i  -K  << EOF >> $OUT
EOF

##pscoast $REG $PROJ -Ba10/a10wsne -Dh -G$land -S$sea -A40000 -W2 -O -X3i -Y2i  -K  << EOF >> $OUT
## add station on current map
#psxy   $REG $PROJ -Sa0.3  -Gred -O -N -K <<EOF >> $OUT
#$sta_lon $sta_lat
#EOF

## add local_average_radius area 
echo "--> Add local average radius area"
set local_average_radius = $sta_rad
set RADIUS = `echo "2*$local_average_radius * 111.12"|bc -l`
psxy   $REG $PROJ -SE  -Wred -O -N -K <<EOF >> $OUT
$sta_lon $sta_lat 0 $RADIUS $RADIUS
EOF

## add the rest of the station on it
# echo "--> Add rest of stations"
# set big_info = $WORKDIR/eventStation
# set eventinfo = $big_info
# foreach other_sta (`cat $big_info |awk '{print $1}'`)
# 	set TMP = `grep -w $other_sta $big_info |awk 'NR==1 {print $0}'`
# 	set sta_lat_tmp = $TMP[9]
# 	set sta_lon_tmp = $TMP[10]
# 	set flag1 = `cat $record_list_file |grep -w $other_sta |awk 'NR==1 {print $1}' `
# 	set star_color = blue
# 	if( $flag1 != "") then
# 		set star_color = red
# 	endif

# psxy   $REG $PROJ -Sa0.1  -G${star_color} -O  -K <<EOF >> $OUT
# $sta_lon_tmp $sta_lat_tmp
# EOF
# end


## add some description
pstext -R0/10/0/10 -JX1i/1i -Y-1.5i -O -N -K << EOF>>$OUT
0 8 10 0 0 LB Grid Location
EOF
pstext -R0/10/0/10 -JX1i/1i -Y+1.5i -O -K << EOF>>$OUT
EOF


psxy $PROJ $REG -O -K -X4i -Y0i  << EOF>>$OUT
EOF

#########################################################33

# add station stack relative to PREM
echo "--> Add station stack relative to PREM"
set sta_stack = $WORKDIR/long_win.vs.${PHASE}.${vs_index}
set minmax_command = "gmt gmtinfo -C"
set XMIN = `cat $sta_stack |${minmax_command} |awk '{print $1}'`
set XMAX = `cat $sta_stack |${minmax_command} |awk '{print $2}'`
set DISTMIN = `echo "$grid_dist -5"|bc -l`
set DISTMAX = `echo "$grid_dist +5"|bc -l`

set REG = -R$XMIN/$XMAX/$DISTMIN/$DISTMAX
set PROJ = -JX4i/4i

# add SNR phase and noise window
set NOISE_BEG = -50
set NOISE_LEN = 30
set NOISE_END = `echo "$NOISE_BEG + $NOISE_LEN"|bc -l`
set PHASE_BEG = -10
set PHASE_LEN = 30
set PHASE_END = `echo "$PHASE_BEG + $PHASE_LEN"|bc -l`

psxy $PROJ $REG -O -K -L -G255/229/204  -N << EOF>> $OUT
$NOISE_BEG $DISTMIN
$NOISE_END $DISTMIN
$NOISE_END $DISTMAX
$NOISE_BEG $DISTMAX
$NOISE_BEG $DISTMIN
EOF

psxy $PROJ $REG -O -K -L -G204/229/255 -N << EOF>> $OUT
$PHASE_BEG $DISTMIN
$PHASE_END $DISTMIN
$PHASE_END $DISTMAX
$PHASE_BEG $DISTMAX
$PHASE_BEG $DISTMIN
EOF




set tmp_file = $WORKDIR/tmp.tmp


psxy  $PROJ $REG -O -K -N  -Ba50f10:"Time relative to PREM prediction":/a5f2:"Dist":SWne << EOF>>$OUT
EOF


echo "--> Add stations in range"

set irecord = 1
set irecord_max = $record_num
while($irecord <= $irecord_max)
	#//echo "--> go for $irecord / $irecord_max"
	# set record_sta = `cat $record_list_file |awk -v dd=$irecord 'NR==dd {print $1}'`
	# set record_EQ = `cat $eventinfo |grep -w $record_sta |awk 'NR==1 {print $19}'`
	#ls $eventinfo
	#//echo "record station is $record_sta record EQ is $record_EQ"
	# set record_phase = $PHASE
	# set record_dist = `cat $eventinfo |grep -w $record_sta |awk 'NR==1 {print $3}'`
	#set tmp_sta_lat = `cat $eveninfo |grep -w $record_sta |awk 'NR==1 {print $9}'`
	#set tmp_sta_lon = `cat $eveninfo |grep -w $record_sta |awk 'NR==1 {print $10}'`
	#//echo " irecord $irecord dist $record_dist"

	# set record_file = $WORKDIR/long_win.${EQ}.${record_sta}.${record_phase}
	#echo $record_file
	set record_file = `cat $record_list_file |awk -v dd=$irecord 'NR==dd {print $1}'`
	set record_file = $WORKDIR/$record_file
	echo "$record_file"
	set record_dist = `cat $record_list_file |awk -v dd=$irecord 'NR==dd {print $2}'`
	cat $record_file|awk -v dist=$record_dist  '{print $1,$2+dist}'>! $tmp_file
	# cat $tmp_file

psxy $tmp_file $PROJ $REG -O -K -Wgrey << EOF >>$OUT
EOF

@ irecord ++
end

## add station stack in the box
cat $sta_stack |awk '{print $1,$2+'$grid_dist'}' >! $tmp_file
psxy $tmp_file -O -K $PROJ $REG -W4,red -N << EOF>>$OUT
EOF


psxy -JX -R -O  -K << EOF -Y-0.17i >>$OUT
EOF

cat $sta_stack |awk '{print $1,$2}' >! $tmp_file
set new_REG = -R$XMIN/$XMAX/-1.2/1.2 
set new_PROJ = -JX4i/1i
psxy $tmp_file -O -K $new_PROJ $new_REG -W4,red -N << EOF>>$OUT
EOF

# set tstar_ES = $WORKDIR/tstar_ES.${ilat}.${ilon}
# psxy $tstar_ES  -O -K $new_PROJ $new_REG -N <<EOF>>$OUT
# EOF

# set gau_ES = $WORKDIR/gau_ES.${ilat}.${ilon}
# #psxy $gau_ES  -O -K -Ba50f10 $new_PROJ $new_REG -N -Worange <<EOF>>$OUT
# psxy $gau_ES  -O -K  $new_PROJ $new_REG -N -Worange <<EOF>>$OUT
# EOF

#psxy -JX -R -O -Ba50f10S -K << EOF >>$OUT
#EOF

psxy $new_PROJ $new_REG -O -K -X0.3i << EOF >>$OUT
EOF

# pstext $new_PROJ $new_REG -O -K  -N<< EOF >>$OUT
# $XMAX 0.9 8 0 0 LB ONSET: $ONSET
# $XMAX 0.6 8 0 0 LB tstar ccc: $tstar_ccc gau ccc $gau_ccc
# $XMAX 0.3 8 0 0 LB tstar factor: $tstar_factor gau factor $gau_factor
# $XMAX 0.0 8 0 0 LB black trace: best-fit t*(S E.W.)
# $XMAX -0.3 8 0 0 LB orange trace: best-fit gau to t*(S E.W.)
# EOF
psxy $new_PROJ $new_REG -O -K -X-0.3i << EOF >>$OUT
EOF

## add arrow
set arrow_parameter = "-Svh0.005i/0.08i/0.01i"
# psxy $new_PROJ $new_REG $arrow_parameter -G255/0/0  -O -K <<EOF>>$OUT
# $ONSET 0 90 0.4
# EOF

#set phase_win_file = $WORKDIR/phase_win.${ilat}.${ilon}
#psxy $phase_win_file  -O -K $new_PROJ $new_REG -N -Wblue <<EOF>>$OUT
#EOF



psxy -JX -R -O  -K << EOF >>$OUT
EOF



## add grid center and EQ geometry
# set eventinfo = $WORKDIR/eventStation.${EQ}
# set EQ_lat = `cat $eventinfo |awk 'NR==1 {print $11}'`
# set EQ_lon = `cat $eventinfo |awk 'NR==1 {print $12}'`
set tmp_data = $WORKDIR/tmp.dd
set mid_point_code = $SRCDIR/find_mid_point_on_sphere
cp $mid_point_code .
./find_mid_point_on_sphere $EQ_lat $EQ_lon $sta_lat $sta_lon >! $tmp_data

echo "EQ $EQ_lat $EQ_lon "
echo "STA $sta_lat $sta_lon"

set MID_lat = `cat $tmp_data|awk '{print $1}'`
set MID_lon = `cat $tmp_data|awk '{print $2}'`
set MAP = -R-180/180/-90/90
set PROJ = -JG${MID_lon}/${MID_lat}/1.5i
set land = "255/225/160"
set sea = 103/204/1
echo " mid lat lon $MID_lat $MID_lon"
pscoast $MAP $PROJ -Dc -A4000000  -W2 -S255/255/255 -G255/255/255    -O -K -P -X-4.6i -Y3.5i>>$OUT
pscoast $MAP $PROJ -Dc -A4000000 -B90g45 -W2 -G$land    -O -K -P>>$OUT
psxy  $MAP $PROJ -:   -W1/"red" -O -P -K  <<EOF >>$OUT
$EQ_lat $EQ_lon
$grid_lat $grid_lon
EOF
# add EQ and STA location
psxy $MAP $PROJ -: -Sa0.1	-W/"red" -O -P -K << EOF>>$OUT
$EQ_lat $EQ_lon
EOF
psxy $MAP $PROJ -: -Si0.1  -W/"red"	-O -K -P  << EOF>>$OUT
$grid_lat $grid_lon
EOF

## add picking box pdfmaker

psxy $PROJ $REG -O -K -X9.5i << EOF>>$OUT
EOF

cat  << EOF >> $OUT
[ 
/T ( ${EQ_name}_${PHASE}_${vs_index} )
/FT /Btn
/Rect [-150 0 -30 100] % — position
/F 4 /H /O
/BS << /W 1 /S /S >>
/MK << /CA (8) /BC [ 0 ] /BG [ 1 ] >>  % Colors
/DA (/ZaDb 0 Tf 1 0 0 rg) % — size and colors
/AP << /N << /${EQ_name}_${PHASE}_${vs_index} /null >> >> % — checkbox value
/Subtype /Widget
/ANN pdfmark
EOF


psxy -JX -R -O << EOF >>$OUT
EOF

@ NUM ++
end # NUM








ps2pdf $OUT $OUT_pdf
rm $OUT
open $OUT_pdf
exit 0
