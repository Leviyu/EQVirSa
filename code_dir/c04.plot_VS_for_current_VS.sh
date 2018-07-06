#!/bin/tcsh


set input_file = ./INPUT.plot
set vs_index = $1

set T = `cat $input_file `

set BIG_WORKDIR = $T[1]
set PLOTDIR = $T[2]
set ID = $T[3]
set PWD = $T[4]
set PHASE = $T[5]
set EQ = $T[6]
set SRCDIR = $T[7]
set ivs = $vs_index

set ivs = `echo "$ivs + 1"|bc`

gmtset PAPER_MEDIA = A4
gmtset ANNOT_FONT_SIZE_PRIMARY = 10
gmtset ANNOT_FONT_SIZE_SECONDARY = 10
gmtset LABEL_FONT_SIZE = 10

#gmtset PS_MEDIA = A4
#gmtset FONT_ANNOT_PRIMARY = 10
#gmtset FONT_ANNOT_SECONDARY = 10
#gmtset FONT_LABEL = 10


set WORKDIR = $BIG_WORKDIR/$EQ


set OUT = $PLOTDIR/virsual_station_stack_${PHASE}_VS_${ivs}.ps
set OUT_pdf = $PLOTDIR/virsual_station_stack_${PHASE}_VS_${ivs}.pdf
#set OUT_pdf = $PLOTDIR/c01.${PHASE}_virsual_station_stack.pdf
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


#//echo "workdir is $WORKDIR"
set grid_info = $WORKDIR/out.station_stack.info.${PHASE}
cat $grid_info
#set bk_grid_info = $WORKDIR/out.station_stack.info.${PHASE}.bk
#cp $grid_info $bk_grid_info
##cat $bk_grid_info |grep -v radius |sort -k 15 -n -r >! $grid_info
#sort -k 15 -n -r $bk_grid_info >! $grid_info

#set NUM_MAX = `cat $grid_info |wc -l`
set NUM = $ivs
echo "=====> Working on c01 stack for virsual station"
#while ($NUM <= $NUM_MAX )
	#echo "--> work on $NUM / $NUM_MAX"

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
set ONSET = $TMP[11]
set tstar_ccc = $TMP[12]
set tstar_factor = $TMP[13]
set gau_ccc = $TMP[14]
set gau_factor = $TMP[15]
set quality = $TMP[16]
set ave_SNR = $TMP[17]
set stack_SNR = $TMP[18]
#//echo "griddist is $grid_dist"
set grid_lat = $sta_lat
set grid_lon = $sta_lon
set record_list_file = $WORKDIR/out.VS_eventStation_list.${PHASE}.${vs_index}
##set record_list_file = $WORKDIR/out.grid_station_list.${PHASE}.${ilat}.${ilon}


set event_tmp = $WORKDIR/eventStation
set TTT = `cat $event_tmp |grep -w $EQ_name|awk 'NR==2 {print $0}'`
#echo $TTT
set EQ_lat = $TTT[11]
set EQ_lon = $TTT[12]
set EQ_dep = $TTT[13]
set EQ_mag = $TTT[16]

echo "--> Add text"
pstext  -JX4i/2i -R0/10/0/10 -K -N  -Xa5.5i -Ya5i<< EOF >> $OUT
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
#if ($quality == 1 ) then
	##psxy -JX -R -O -K -Sa0.5 -Gred -N << EOF >> $OUT
	##10 5
	##EOF
	##endif

## ================================================
## add station map
echo "--> Add EQ map"
##set sta_lon = $lon
##set sta_lat = $lat
set LONINC = 40
set LATINC = 40
set LONMIN = `echo "$eq_lon - $LONINC"|bc -l`
set LONMAX = `echo "$eq_lon + $LONINC"|bc -l`
set LATMIN = `echo "$eq_lat - $LATINC"|bc -l`
set LATMAX = `echo "$eq_lat + $LATINC"|bc -l`
echo "===============>$eq_lat $eq_lon"
if(`printf %.0f $LATMIN `< -90) then
set LATMIN = -90
endif
if(`printf %.0f $LATMAX ` > 90) then
set LATMAX = 90
endif

set coast_map_size = 2.5
set REG = -R$LONMIN/$LONMAX/$LATMIN/$LATMAX
set PROJ = -JQ$eq_lon/$eq_lat/${coast_map_size}i
set land = "255/255/160"
set sea = 103/204/0
pscoast $REG $PROJ -Ba20/a20nwse -Dh -G$land -A40000 -W1 -O -Xa1i  -Ya5i  -K  << EOF >> $OUT
EOF

## add local_average_radius area 
echo "--> Add local average radius area"
set local_average_radius = $sta_rad
set RADIUS = `echo "2*$local_average_radius * 111.12"|bc -l`
psxy   $REG $PROJ -SE  -Wred -O -N -K  -Ya1i -Ya5i<<EOF >> $OUT
$eq_lon $eq_lat 0 $RADIUS $RADIUS
EOF
# add EQ location
psxy   $REG $PROJ -Sa0.5  -Gred -O -N -K  -Ya1i -Ya5i<<EOF >> $OUT
$eq_lon $eq_lat 
EOF
# add other EQ on top

## ================================================


## ================================================
## add station map
echo "--> Add station map"
##set sta_lon = $lon
##set sta_lat = $lat
set LONINC = 15
set LATINC = 15
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

set REG = -R$LONMIN/$LONMAX/$LATMIN/$LATMAX
set PROJ = -JQ$sta_lon/$sta_lat/${coast_map_size}i
##set PROJ = -JG$sta_lon/$sta_lat/3i
set land = "255/255/160"
set sea = 103/204/0
set LOC = "-Xa1i -Ya1i"
pscoast $REG $PROJ -Ba10/a10wsne -Dh -G$land -A40000 -W0.5 -O ${LOC} -K  << EOF >> $OUT
EOF

## add local_average_radius area 
echo "--> Add local average radius area"
set local_average_radius = $sta_rad
set RADIUS = `echo "2*$local_average_radius * 111.12"|bc -l`
psxy   $REG $PROJ -SE  -Wred -O -N -K ${LOC}<<EOF >> $OUT
$sta_lon $sta_lat 0 $RADIUS $RADIUS
EOF
# add station grid location
psxy   $REG $PROJ -St0.2  -Gred -O -N -K ${LOC}<<EOF >> $OUT
$sta_lon $sta_lat 
EOF
## ================================================

## add the rest of the station on it
echo "--> Add rest of stations/events"
set rest_sta = $WORKDIR/rest.sta.$$
cat /dev/null >! $rest_sta
cat $WORKDIR/eventStation |awk '{print $1,$9,$10}' |sort -u -k1,1 | \
	awk 'function abs(x){return ((x < 0.0) ? -x : x)} { if( abs($2 - '$sta_lat') < 30 && abs($3 - '$sta_lon' < 30)) print $3,$2,$1}' > $rest_sta
set star_color = blue
psxy  $rest_sta  $REG $PROJ -Sa0.2  -G${star_color} -O  -K ${LOC}<<EOF >> $OUT
EOF

## plot record witin range as red
set record_in_range = $WORKDIR/records_in_range.$$
cat /dev/null>! $record_in_range
foreach mysta (`cat $record_list_file|awk -F"." '{print $3}'`)
	set TT = `cat $WORKDIR/eventStation |grep -w $mysta |awk 'NR==1 {print $0}'`
	set mysta_lat = $TT[9]
	set mysta_lon = $TT[10]
	set star_color = red

psxy    $REG $PROJ -Sa0.2  -G${star_color} -O  -K ${LOC}<<EOF >> $OUT
$mysta_lon $mysta_lat
EOF
end #mysta

# add events location
set rest_eq = $WORKDIR/rest.eq.$$
cat /dev/null >! $rest_eq
cat $WORKDIR/eventStation |awk '{print $19,$11,$12}' |sort -u -k1,1 |\
	awk 'function abs(x){return ((x < 0.0) ? -x : x)} { if( abs($2 - '$eq_lat') < 30 && abs($3 - '$eq_lon' < 30)) print $3,$2}' > $rest_eq
set star_color = red
psxy  $rest_eq  $REG $PROJ -Sa0.2  -G${star_color} -O  -K ${LOC}<<EOF >> $OUT
EOF
set star_color = blue
psxy    $REG $PROJ -Sa0.2  -G${star_color} -O  -K ${LOC}<<EOF >> $OUT
$eq_lon $eq_lat
EOF

## add some description
set LOC = "-Xa3i -Ya0.5i"
pstext -R0/10/0/10 -JX1i/1i -Y-1.5i -O -N -K ${LOC} << EOF>>$OUT
0 8 10 0 0 LB Grid Location
EOF


#########################################################33

# add station stack relative to PREM
echo "--> Add station stack relative to PREM"
set sta_stack = $WORKDIR/long_win.vs.${PHASE}.${vs_index}
set minmax_command = "minmax -C"
#set minmax_command = "gmt gmtinfo -C"
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

set LOC = "-Xa4.5i -Ya1i"
psxy $PROJ $REG -O -K -L -G255/229/204  -N ${LOC}<< EOF>> $OUT
$NOISE_BEG $DISTMIN
$NOISE_END $DISTMIN
$NOISE_END $DISTMAX
$NOISE_BEG $DISTMAX
$NOISE_BEG $DISTMIN
EOF

psxy $PROJ $REG -O -K -L -G204/229/255 -N ${LOC}<< EOF>> $OUT
$PHASE_BEG $DISTMIN
$PHASE_END $DISTMIN
$PHASE_END $DISTMAX
$PHASE_BEG $DISTMAX
$PHASE_BEG $DISTMIN
EOF




set tmp_file = $WORKDIR/tmp.$$


psxy ${LOC} $PROJ $REG -O -K -N  -Ba50f10:"Time relative to PREM prediction":/a5f2:"Dist":SWne << EOF>>$OUT
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

psxy $tmp_file $PROJ $REG -O -K -Wgrey ${LOC}<< EOF >>$OUT
EOF

@ irecord ++
end

## add station stack in the box
cat $sta_stack |awk -v dd=$grid_dist '{print $1,$2+dd}' >! $tmp_file
psxy $tmp_file -O -K $PROJ $REG -W4,red -N ${LOC}<< EOF>>$OUT
EOF



cat $sta_stack |awk '{print $1,$2}' >! $tmp_file
set new_REG = -R$XMIN/$XMAX/-1.2/1.2 
set new_PROJ = -JX4i/1i
psxy $tmp_file -O -K $new_PROJ $new_REG -W4,red -N ${LOC}<< EOF>>$OUT
EOF


set tstar_ES = $WORKDIR/tstar_ES.${vs_index}
psxy $tstar_ES  -O -K $new_PROJ $new_REG -N ${LOC} <<EOF>>$OUT
EOF

set gau_ES = $WORKDIR/gau_ES.${vs_index}
#psxy $gau_ES  -O -K -Ba50f10 $new_PROJ $new_REG -N -Worange <<EOF>>$OUT
psxy $gau_ES  -O -K  $new_PROJ $new_REG -N -Worange ${LOC} <<EOF>>$OUT
EOF

#psxy -JX -R -O -Ba50f10S -K << EOF >>$OUT
#EOF

set text_LOC = "-Xa7.0i -Ya3i"
pstext -JX4i/1.5i $new_REG -O -K  -N ${text_LOC}<< EOF >>$OUT
0 0.9 10 0 0 LB ONSET: $ONSET
0 0.6 10 0 0 LB ccc: $tstar_ccc gau ccc $gau_ccc
0 0.3 10 0 0 LB factor: $tstar_factor gau factor $gau_factor
0 0.0 10 0 0 LB black trace: best-fit S E.W.
0 -0.3 10 0 0 LB orange trace: best-fit Gaussian Function
0 -0.6 10 0 0 LB Quality: $quality
0 -0.9 10 0 0 LB Average SNR/Stack SNR: $ave_SNR / $stack_SNR

EOF

## add arrow
set arrow_parameter = "-Svh0.01i/0.10i/0.03i"
psxy $new_PROJ $new_REG $arrow_parameter -G255/0/0  -O -K ${LOC}<<EOF>>$OUT
$ONSET 0 90 1.2
EOF

#set phase_win_file = $WORKDIR/phase_win.${ilat}.${ilon}
#psxy $phase_win_file  -O -K $new_PROJ $new_REG -N -Wblue <<EOF>>$OUT
#EOF






## add grid center and EQ geometry
# set eventinfo = $WORKDIR/eventStation.${EQ}
# set EQ_lat = `cat $eventinfo |awk 'NR==1 {print $11}'`
# set EQ_lon = `cat $eventinfo |awk 'NR==1 {print $12}'`
set tmp_data = $WORKDIR/tmpdata.$$
set mid_point_code = $SRCDIR/find_mid_point_on_sphere
cp $mid_point_code .
./find_mid_point_on_sphere $EQ_lat $EQ_lon $sta_lat $sta_lon >! $tmp_data

#//echo "EQ $EQ_lat $EQ_lon "
#echo "STA $sta_lat $sta_lon"

set MID_lat = `cat $tmp_data|awk '{print $1}'`
set MID_lon = `cat $tmp_data|awk '{print $2}'`
set MAP = -R-180/180/-90/90
set PROJ = -JG${MID_lon}/${MID_lat}/2.1i
set land = "255/225/160"
set sea = 103/204/1
#echo " mid lat lon $MID_lat $MID_lon"
set LOC = "-Xa0.2i -Ya3.5i"
pscoast $MAP $PROJ -Dc -A4000000  -W2 -S255/255/255 -G255/255/255    -O -K -P ${LOC}>>$OUT
pscoast $MAP $PROJ -Dc -A4000000 -B90g45 -W2 -G$land    -O -K -P ${LOC}>>$OUT
psxy  $MAP $PROJ -:   -W1/"red" -O -P -K  ${LOC}<<EOF >>$OUT
$EQ_lat $EQ_lon
$grid_lat $grid_lon
EOF
# add EQ and STA location
psxy $MAP $PROJ -: -Sa0.3	-Gred -O -P -K ${LOC}<< EOF>>$OUT
$EQ_lat $EQ_lon
EOF
psxy $MAP $PROJ -: -Si0.3  -Gred	-O -K -P  ${LOC}<< EOF>>$OUT
$grid_lat $grid_lon
EOF

## add picking box pdfmaker

psxy $PROJ $REG -O -K  ${LOC}<< EOF>>$OUT
EOF

if($quality == 1) then
cat  << EOF >> $OUT
[ 
/T ( ${EQ_name}_${PHASE}_${vs_index} )
/V /${EQ_name}_${PHASE}_${vs_index}
/FT /Btn
/Rect [3000 200 3200 400] % — position
/F 4 /H /O
/BS << /W 1 /S /S >>
/MK << /CA (8) /BC [ 0 ] /BG [ 1 ] >>  % Colors
/DA (/ZaDb 0 Tf 1 0 0 rg) % — size and colors
/AP << /N << /${EQ_name}_${PHASE}_${vs_index} /null >> >> % — checkbox value
/Subtype /Widget
/ANN pdfmark
EOF
else
cat  << EOF >> $OUT
[ 
/T ( ${EQ_name}_${PHASE}_${vs_index} )
/FT /Btn
/Rect [3000 200 3200 400] % — position
/F 4 /H /O
/BS << /W 1 /S /S >>
/MK << /CA (8) /BC [ 0 ] /BG [ 1 ] >>  % Colors
/DA (/ZaDb 0 Tf 1 0 0 rg) % — size and colors
/AP << /N << /${EQ_name}_${PHASE}_${vs_index} /null >> >> % — checkbox value
/Subtype /Widget
/ANN pdfmark
EOF
endif

psxy -JX -R -O << EOF >>$OUT
EOF



ps2pdf $OUT $OUT_pdf
#rm $OUT
#gs $OUT_pdf
#to_hongyu $OUT_pdf
exit 0
