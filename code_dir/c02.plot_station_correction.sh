#!/bin/csh
# ====================================================================
# This is a csh script to make a catalog plot for each station with
# 	genera station info
#	dt distribution and std 
#	rose plot according to AZ
#	and a map view with its adjacent stations
#
# Input:
# Output:
#
#
# DATE:					Keywords:
#
# Reference:
# ===================================================================


## ======= Read in parameter ===========
set PWD = `pwd`
set INFILE = ${PWD}/INFILE
set DIR =						`grep -w CURRENT_DIR $INFILE | awk '{print $2}'`
set DATADIR =					`grep -w DATADIR $INFILE | awk '{print $2}'`
set PLOTDIR =					`grep -w PLOTDIR $INFILE | awk 'NR==1 {print $2}'`
set C_DIR =						`grep -w C_DIR $INFILE | awk '{print $2}'`
set SHELL_DIR =					`grep -w SHELL_DIR $INFILE | awk '{print $2}'`
set DELTA =						`grep -w DELTA $INFILE | awk '{print $2}'`

set ID = $1
set event = $2
set uniq_sta_list = $3

set c_code = $SHELL_DIR/main.c
set local_average_radius = 5


set WORKDIR = $DATADIR/$ID
cd $WORKDIR

set OUT = $PLOTDIR/Station_catalog_plot_${ID}.ps
set OUT_pdf = $PLOTDIR/Station_catalog_plot_${ID}.pdf
/bin/rm -r $OUT_pdf
cat /dev/null > $OUT

set big_info = $DATADIR/$ID/out.my_station.info

gmtset BASEMAP_TYPE = plain


set NUM = 1
foreach sta (`cat $big_info |awk '{print $1}'`)
	echo "--> Plotting processeing for Station $sta NUM: $NUM"
	set TMP = `grep -w $sta $big_info |awk 'NR==1 {print $0}'`

	set sta_lat = $TMP[2]
	set sta_lon = $TMP[3]
##echo "sta lat lon $sta_lat $sta_lon"	
	set sta_dt_ave = $TMP[4]
	set sta_dt_STD = $TMP[5]
	set num_record_at_current_station = $TMP[6]
	set local_average_count = $TMP[7]
	set local_average_dt = $TMP[8]

	set mean = $sta_dt_ave
	set STD = $sta_dt_STD


	set current_sta_list = $WORKDIR/out.records_of_${sta}
	## stored as format BAZ incident dt


pstext -JX6i/1i -R0/10/0/10 -Y6.5i -K -N <<EOF>> $OUT
0 9 13 0 0 LB Station Catalog Plot  
0 7 10 0 0 LB STA: $sta All Phases
0 5 10 0 0 LB LON: $sta_lon LAT: $sta_lat
0 3 10 0 0 LB Record NUM: $num_record_at_current_station
0 1 10 0 0 LB dt MEAN: $sta_dt_ave  STD: $sta_dt_STD 
0 -1 10 0 0 LB Local Radius(degree): $local_average_radius MEAN: $local_average_dt Count: $local_average_count
EOF

set dt_file = $WORKDIR/dt.tmp
cat $current_sta_list |awk '{print 0.5, $3}' > $dt_file
psxy $dt_file -JX1i/5i -S+0.2 -Ba1f1/a5f1:"Time Anomaly":W -R-1/1/-20/20 -Y-5.5i -O -K << EOF>> $OUT
EOF
psxy -JX -Sc0.3  -Gred -R -O -K << EOF >> $OUT
0 $mean
EOF

set top = `echo "$mean + $STD"|bc -l`
set bot = `echo "$mean - $STD"|bc -l`

## add std
psxy -JX -W/red -R -O -K << EOF >> $OUT
0 $bot
0 $top
EOF

psxy -JX -W/red -R -O -K -S-0.2 << EOF >> $OUT
0 $bot
0 $top
EOF


## add local average
psxy -JX -W/blue -R -O -K  << EOF >> $OUT
-1 $local_average_dt
1  $local_average_dt
EOF

if($local_average_count != 0) then
pstext -JX -R -N -O -K << EOF >> $OUT
1 $local_average_dt 8 0 0 LB local_average_dt
EOF
endif

## ========================================
## add station map
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

pscoast $REG $PROJ -Ba10/a10wsne -Dh -G$land -A40000 -W2 -O -X2.5i -Y1i  -K  << EOF >> $OUT
EOF

##pscoast $REG $PROJ -Ba10/a10wsne -Dh -G$land -S$sea -A40000 -W2 -O -X3i -Y2i  -K  << EOF >> $OUT
## add station on current map
psxy   $REG $PROJ -Sa0.3  -Gred -O -N -K <<EOF >> $OUT
$sta_lon $sta_lat
EOF

## add local_average_radius area 
set RADIUS = `echo "2*$local_average_radius * 111.12"|bc -l`
psxy   $REG $PROJ -SE  -Wred -O -N -K <<EOF >> $OUT
$sta_lon $sta_lat 0 $RADIUS $RADIUS
EOF

## add the rest of the station on it
## add the rest of the station on it
## add the rest of the station on it
## add the rest of the station on it
foreach other_sta (`cat $big_info |awk '{print $1}'`)
	set TMP = `grep -w $other_sta $big_info |awk 'NR==1 {print $0}'`
	set sta_lat_tmp = $TMP[2]
	set sta_lon_tmp = $TMP[3]

psxy   $REG $PROJ -Sa0.15  -Ggreen -O  -K <<EOF >> $OUT
$sta_lon_tmp $sta_lat_tmp
EOF
end


## add some description
pstext -R0/10/0/10 -JX1i/1i -Y-1.5i -O -N -K << EOF>>$OUT
0 8 10 0 0 LB Station Location 
EOF
pstext -R0/10/0/10 -JX1i/1i -Y+1.5i -O -K << EOF>>$OUT
EOF



# add current grid location and its coverage
##set grid_coverage = grd.coverage.tmp
##set grd_lat_min = `echo "$clat - $RADIUS"|bc -l`
##set grd_lat_max = `echo "$clat + $RADIUS"|bc -l`
##set grd_lon_min = `echo "$clon - $RADIUS"|bc -l`
##set grd_lon_max = `echo "$clon + $RADIUS"|bc -l`
##psxy -: $REG $PROJ   -O -K -W3/green  << EOF >> $OUT
##$grd_lat_min $grd_lon_min
##$grd_lat_min $grd_lon_max
##$grd_lat_max $grd_lon_max
##$grd_lat_max $grd_lon_min
##$grd_lat_min $grd_lon_min
##EOF

##pscoast $REG $PROJ -Ba0g45/a0g45/wsne -Dh -A4000 -W2 -P -V -O  -K >>$OUT
## add BAZ incient angle dt  ball
set AZ_file = $WORKDIR/AZ.tmp
set REG = -R0/360/0/1
set PROJ = -JPa3i
psbasemap $REG $PROJ -X3.5i -B45 -O -K >> $OUT

set BAZ_INC_DT_po = $WORKDIR/BAZ_INC_DT.tmp.po
set BAZ_INC_DT_ne = $WORKDIR/BAZ_INC_DT.tmp.ne
cat $current_sta_list |awk '$3>=0 {print $1,$2,$3/10*0.5}' > $BAZ_INC_DT_po
cat $current_sta_list |awk '$3<0 {print $1,$2,$3/10*0.5}' > $BAZ_INC_DT_ne
psxy $BAZ_INC_DT_po  -R -JP -O -K -W/red -S+ >> $OUT
psxy $BAZ_INC_DT_ne  -R -JP -O -K -W/blue -S+ >> $OUT



## add centra star , mark station location
psxy -R -JP -O -K -Gred -Sa+0.3 << EOF >> $OUT
0 0 1
EOF


## add some description
pstext -R0/10/0/10 -JX1i/1i -Y-1.5i -N -O -K << EOF>>$OUT
0 8 10 0 0 LB BAZ-Incident_angle-travel_time_anomaly Plot
0 5 10 0 0 LB dt Red: positive value Blue: negative value
EOF
pstext -R0/10/0/10 -JX1i/1i -Y+1.5i -O -K << EOF>>$OUT
EOF




pstext -JX -R -O << EOF >> $OUT
EOF

@ NUM ++
	end #$sta

ps2pdf $OUT $OUT_pdf
rm $OUT
##gs $OUT_pdf
