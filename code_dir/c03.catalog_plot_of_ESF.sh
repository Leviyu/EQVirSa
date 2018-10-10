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
#set EQ = $1
#set DATADIR = $2
#set PLOTDIR_main = $3
#set PLOTDIR = $PLOTDIR_main/$EQ
#set C_DIR = $4
#set SHELL_DIR = $5
#set PHASE = $6
set ID = $1
set DATADIR = $2
set PLOTDIR_main = $3
set SHELL_DIR = $4
set PHASE = $5
set current_EQ = $6
set EQ = $current_EQ
#set ID = T7_S
#set DATADIR = ~/EQVirSa/WORKDIR/T7
#set PLOTDIR_main = ./
#set PLOTDIR = $PLOTDIR_main/hello
#set SHELL_DIR = ~/EQVirSa/code_dir
#set PHASE = S

set PLOTDIR = $PLOTDIR_main/${ID}_${PHASE}
set DATADIR = $DATADIR/${ID}_${PHASE}
mkdir -p $PLOTDIR
mkdir -p $DATADIR
echo "plot dir is $PLOTDIR DATADIR is $DATADIR"

set INFILE = $DATADIR/INFILE
set filter_flag = `cat $INFILE|grep -w FILTER_FLAG |cut -c 14-`
set work_dir = $DATADIR

set VS_FILE_orig = $work_dir/out.station_stack.info.${PHASE}
set VS_FILE = $work_dir/out.station_stack.info.${PHASE}.${current_EQ}.tmp


# we arrange the files based on 
# by each event
# 1. good record by distance
# 2. bad record by distance
#cat /dev/null >! $VS_FILE
#cat $VS_FILE_orig |grep -w $EQ |awk '$16==1 {print $0}'|sort -n -k 10 |uniq -f 1 >> $VS_FILE
#cat $VS_FILE_orig |grep -w $EQ |awk '$16!=1 {print $0}'|sort -n -k 10 |uniq -f 1 >> $VS_FILE
cp $VS_FILE_orig $VS_FILE


set COMP = T
echo "=============================================="
echo "---> Begin Catalog Plot for $ID PHASE: $PHASE for $current_EQ"

set tmp_ps = $PLOTDIR/tmp.ps
rm $tmp_ps 2>&/dev/null
set PWD = `pwd`
# ====================================================
# 			set output pdf file and plot parameter
# ====================================================
set OUTFILE_pdf = $PLOTDIR/${ID}_${PHASE}_${current_EQ}_catalog_all_record.pdf


# =============================
# gmt setting and Page Setting 
cd $work_dir
gmtset TICK_PEN = 0.2p
gmtset ANNOT_FONT_SIZE_PRIMARY = 5p
gmtset FRAME_PEN = 0.4p
gmtset ANNOT_OFFSET_PRIMARY = 0.1c
gmtset PAPER_MEDIA = A4

set PLOT_PER_PAGE = 16
set PAGE = 1
set current_record = 1
set ploted_record = 1
set arrow_parameter = "-Svh0.005i/0.08i/0.01i"
# =============================

# establish a file containing the records that should be thrown away because of being too close to other phases only for good records


# ====================================================
# 	plot record one by one
# ====================================================
set record_num = `cat $VS_FILE |wc -l`
set EQ_mag = `check_event $current_EQ |grep -w EQ_MAG |awk '{print $2}'`
foreach ivs (`cat $VS_FILE |awk '{print $1}'`)
echo "---> Working on ivs $ivs / $record_num"
set TMP = `cat $VS_FILE|awk -v dd=$ivs '$1==dd {print $0}'`
set EQ = $TMP[2]
set EQ_lat = $TMP[3]
set EQ_lon = $TMP[4]
set EQ_RAD = $TMP[5]
set VS_STA_LAT = $TMP[6]
set VS_STA_LON = $TMP[7]
set STA_lat = $VS_STA_LAT
set STA_lon = $VS_STA_LON
set STA_RAD = $TMP[8]
set record_in_range = $TMP[9]
set VS_DIST = $TMP[10]
set VS_ONSET = $TMP[11]
set tstar_ccc = $TMP[12]
set tstar_factor = $TMP[13]
set gau_ccc = $TMP[14]
set gau_factor = $TMP[15]
set quality_flag = $TMP[16]
set ave_SNR = $TMP[17]
set stack_SNR = $TMP[18]
set stack_SNR_peak = $TMP[19]
set misfit = $TMP[20]
set misfit_pre = $TMP[21]
set misfit_bak = $TMP[22]
set stretch_ccc = $TMP[23]
set stretch_coeff = $TMP[24]
set vs_polar = $TMP[25]
set EQ_dep = $TMP[26]
#//set EQ_dep = `check_event $current_EQ |grep -w EQ_DEP |awk '{print $2}'`
set one_period = $TMP[31]
set SNR_peak_trough = $TMP[32]
set traffic_nearby = $TMP[33]

set DIST = $VS_DIST

set polar_flag = 1
# calculate polarity for current VS
#set vs_polar = `get_polarity $EQ $STA_lat $STA_lon $PHASE`
#if ($vs_polar == "" ) then
##set vs_polar = 0
#endif
#set vs_polar = `printf "%.2f" $vs_polar`


##echo "---> Working on plotting $sta PHASE is $PHASE"
set long = $work_dir/long_win.vs.${PHASE}.${ivs}
set emp = $work_dir/tstar_ES.${ivs}
set gau = $work_dir/gau_ES.${ivs}

if( ! -e $long ) then
##echo "$long does not exist! ========"
##continue
endif
if(! -e $emp ) then
##echo "$emp does not exist! ========="
##continue
endif




set xy_tmp = `minmax -C $long`
set xmin = $xy_tmp[1]
set xmax = $xy_tmp[2]
set ymin = $xy_tmp[3]
set ymax = $xy_tmp[4]
# we compute surface wave time window and ignore everything within the window


## Now lets deal with the traffic phase part


	if( $current_record == 1 ) then
		set OUTFILE = $PLOTDIR/catalog_all_eventstation_page_${PAGE}.ps
cat << EOF > ${OUTFILE}
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
		pstext -JX6i/1i -R-1/1/-1/1 -K -Y10.5i -N -P<<END>> $OUTFILE
		0 0.5 11 0 0 CB Catalog Plot for $current_EQ PHASE: $PHASE COMP:$COMP PAGE:$PAGE in filter: $filter_flag
		0  0.1 9  0 0 CB Event Lat: $EQ_lat Lon:$EQ_lon Dep: $EQ_dep Mag:$EQ_mag
		0 -0.3 9  0 0 CB StationRadius: $STA_RAD EQRadius: $EQ_RAD 
END
		pstext -JX -R -O -K -N -P -X-0.3i <<END>>$OUTFILE
END
		# add flipping flag instruction
#psxy -JX -R0/7/-1/1 -Sc0.1 -G0/0/0 -Y-0.3i -O -N -K <<EOF>>$OUTFILE
#0.5 0.3
#EOF
#psxy -JX -R0/7/-1/1 -Sc0.1 -G255/0/0  -O -K -N <<EOF>>$OUTFILE
#0.5 -0.3
#EOF
#pstext -JX -R0/7/-1/1 -O -K -N <<EOF>>$OUTFILE
#1 0.3  6 0 0 CB not flipped
#1 -0.3 6 0 0 CB flipped
#EOF

set traffic_color = (green purple orange 104/178/255 blue 255/0/0 255/100/0 255/100/100)
		# add marker information for all phases
set x_loc = 1.0
set x_loc2 = 1.5
set x_loc = 1.5

	endif
psxy -JX5i/0.5i -R$xmin/$xmax/-1/1  -O -K -N -Y-0.6i <<EOF>>$OUTFILE
EOF


	# ================== plot the trace =====================
		set long_color = 0/0/0
		set long_color_flag = `echo ddd |awk '{ if ('$vs_polar' > -0.05 && '$vs_polar' < 0.05) print "dark"; else if('$vs_polar' > -0.15 && '$vs_polar' < 0.15 ) print "green"; else print "hahaha"}'`

#set long_color_flag = "hahah"
##echo "sta $sta long color is $long_color_flag"
		if($long_color_flag == "green" ) then
		set long_color = 178/102/255
		else if( $long_color_flag == "dark" ) then
		set long_color = 0/153/51
		endif


		psxy $long -JX5i/0.5i -R$xmin/$xmax/-1/1 -W/$long_color  -O -K >>$OUTFILE

		# add a dot to indicate whether it is fliped or not
		if( $polar_flag == -1 ) then  # dark for not flip red for flipped recrod
			set flip_color = red
		else if ($polar_flag == 1) then
			set flip_color = 0/0/0
		else 
			set flip_color = yellow
		endif
		set x_loc = `echo "$xmin + 40"|bc`
#psxy -JX -R -Sc0.1 -G$flip_color  -O -K -N <<EOF >> $OUTFILE
#$x_loc 1
#EOF

		set quality_color = green 
		if($quality_flag == 2 || $quality_flag  == 3 ) then
		set quality_color = red
		endif
		set x_loc = `echo "$xmin + 45"|bc`
		if( $record_in_range < 5 ) then
		set stack_color = red
		else
		set stack_color = 0/0/0
		endif
		pstext -JX -R -G${stack_color} -O -K -N << EOF >>$OUTFILE
$x_loc 1 8 0 0 LB Stack: $record_in_range
EOF


		set emp_color = red 
		psxy $emp -JX -R -W/$emp_color -O -K>>$OUTFILE


		## add best fit gaussian here
		psxy $gau -JX -R -W/orange -O -K>>$OUTFILE


		# this is the not stretched empirical waveform
##psxy $orig_emp -JX -R -W/green -O -K>>$OUTFILE

		#  ===================== add vertical lines  =====================================
		psxy -JX -R -W2/204/169/228 -O -K <<EOF>>$OUTFILE
0 -1
0 1
EOF
foreach loc (-15 -10 -5 5 10 15)
		psxy -JX -R -Wfaint,204/169/228,- -O -K <<EOF>>$OUTFILE
$loc -0.1
$loc  0.1
EOF
end # foreach loc
		# add  little marker
		set imarker = -14
		set imarker_max = 14
		while ( $imarker <= $imarker_max)
		psxy -JX -R -Wfaint/204/169/228ta -O -K <<EOF>>$OUTFILE
$imarker 0.05
$imarker -0.05
EOF
@ imarker ++
			end
		#END  ===================== add vertical lines  =====================================

		# add ONSET 
		psxy -JX -R $arrow_parameter -G255/0/0  -O -K <<EOF>>$OUTFILE
$VS_ONSET 0 90 0.5
EOF
		# add SNR window
#psxy -JX -R -Wfaint/0/0/255ta -O -K <<EOF>>$OUTFILE
#$NOISE_BEG 0.5
#$NOISE_BEG -0.5
#EOF
#psxy -JX -R -Wfaint/0/0/255ta -O -K <<EOF>>$OUTFILE
#$NOISE_END 0.5
#$NOISE_END -0.5
#EOF


		# add misfit measurement onset and endset
#set misfit_beg = $ONSET
#set misfit_end = $ENDSET
#psxy -JX -R -Wthinner/255/153/51ta -O -K <<EOF>>$OUTFILE
#$misfit_beg 0.4
#$misfit_beg -0.4
#EOF
#psxy -JX -R -Wthinner/255/153/51ta -O -K <<EOF>>$OUTFILE
#$misfit_end 0.4
#$misfit_end -0.4
#EOF

		# add horizontal 0 line
		psxy -JX -R -Wfaint,204/169/228,. -O -K <<EOF>>$OUTFILE
$xmin 0
$xmax 0
EOF

	#	add traffic phase system symbal
set traffic_file = $work_dir/traffic.${ivs}
if(! -e $traffic_file) then
set kkk = 1
else 
set traffic_num = `cat $traffic_file |wc -l`
set NUM = 1
while ($NUM <= $traffic_num)
	set TMP = `cat $traffic_file |awk 'NR=='$NUM' {print $0 }' `
	set tPHASE = $TMP[2]
	set rel_time = $TMP[4]
	set tt = `printf "%.0f" $rel_time`
	if($tt == 0 ) then
@ NUM ++
continue
	endif

## decide if rel_time is too big
	set int_rel_time = `printf "%.0f" $rel_time`
	if($int_rel_time > 100 || $int_rel_time < -100 || $int_rel_time == 0 ) then
@ NUM ++
	continue
	endif

	set color = blue
	set is_SKS = `echo $tPHASE|grep SK`
	if( $is_SKS != "" ) then
	set color = orange
	endif

		psxy -JX -R -W0.8p/${color} -O -K <<EOF>>$OUTFILE
$rel_time -1
$rel_time 1
EOF
pstext -JX -R -O -K -N << EOF >> $OUTFILE
$rel_time 1.1 7 0 0 LB $tPHASE
EOF
@ NUM ++
	end #while
endif


#echo $EQ_lat $EQ_lon $STA_lat $STA_lon
# ================== add a sphere global view of EQ--sta geometry =================
set MID = `csh $SHELL_DIR/find_mid_point_on_sphere.sh $SHELL_DIR $EQ_lat $EQ_lon $STA_lat $STA_lon|awk '{print $0}'`
set MID_lat = $MID[1]
set MID_lon = $MID[2]
##set MID_lat = `awk 'NR==1 {print $1}' MID`
##set MID_lon = `awk 'NR==1 {print $2}' MID`
# add the small global map showing the gcp of this cross-section
set MAP = -R0/360/-90/90
set PROJ = -JG${MID_lon}/${MID_lat}/0.5i
set land = "255/225/160"
set sea = 103/204/1
pscoast $MAP $PROJ -Dc -A4000000 -B90g45 -W2 -G$land    -O -K -P >>$OUTFILE
psxy  $MAP $PROJ -:   -W0.001/"red" -O -P -K  <<EOF >>$OUTFILE
$EQ_lat $EQ_lon
$STA_lat $STA_lon
EOF
# add EQ and STA location
psxy $MAP $PROJ -: -Sa0.1	-W/"red" -O -P -K << EOF>>$OUTFILE
$EQ_lat $EQ_lon
EOF
psxy $MAP $PROJ -: -Si0.1  -W/"red"	-O -K -P  << EOF>>$OUTFILE
$STA_lat $STA_lon
EOF
#END ================== add a sphere global view of EQ--sta geometry =================

	# ================= add info section ===================
	pstext -JX2i/0.5i -R0/1/0/1 -O -K -N -P -X5.2i <<END>>$OUTFILE
	0 1.0  7 0 0 LB  ----------------------
	0 0.75 7 0 0 LB IVS:$ivs DIST:$VS_DIST misfit: $misfit_pre/$misfit/$misfit_bak
	0 0.5  7 0 0 LB STA:$STA_lat $STA_lon polar: $vs_polar period: $one_period near: $traffic_nearby
	0 0.25 7 0 0 LB dt:$VS_ONSET aveSNR: $ave_SNR stackSNR:$stack_SNR peakSNR:$stack_SNR_peak
	0 0.0  7 0 0 LB tstar: $tstar_ccc/$tstar_factor gau:$gau_ccc/$gau_factor stretch:${stretch_ccc}/${stretch_coeff}
END
#0 0.5  7 0 0 LB ccc:$ccc SNR:$SNR CCC3: $CCC3  dt:$dt_obs_prem 
#0 0.25 7 0 0 LB stretch_ccc: $best_stretch_ccc factor: $best_stretch_coeff tstar: $tstar ccc: $tstar_ccc
#0 0.0  7 0 0 LB AZ:$AZ misfit:$misfit $misfit2 weight: $record_weight polar: $CMT_polar_prediction

	# add pdfmarker
if($quality_flag >= 1) then
cat  << EOF >> $OUTFILE
[ 
/T ( ivs_${ivs} )
/V /ivs_${ivs}
/FT /Btn
/Rect [-150 0 -30 100] % — position
/F 4 /H /O
/BS << /W 1 /S /S >>
/MK << /CA (8) /BC [ 0 ] /BG [ 1 ] >>  % Colors
/DA (/ZaDb 0 Tf 1 0 0 rg) % — size and colors
/AP << /N << /ivs_${ivs} /null >> >> % — checkbox value
/Subtype /Widget
/ANN pdfmark
EOF
else 
cat  << EOF >> $OUTFILE
[ 
/T ( ivs_${ivs} )
/FT /Btn
/Rect [-150 0 -30 100] % — position
/F 4 /H /O
/BS << /W 1 /S /S >>
/MK << /CA (8) /BC [ 0 ] /BG [ 1 ] >>  % Colors
/DA (/ZaDb 0 Tf 1 0 0 rg) % — size and colors
/AP << /N << /ivs_${ivs} /null >> >> % — checkbox value
/Subtype /Widget
/ANN pdfmark
EOF
endif

#cat  << EOF >> $OUTFILE
#[ 
#/T ( ${ivs}_problem )
#/FT /Btn
#/Rect [-1700 0 -1600 100] % — position
#/F 4 /H /O
#/BS << /W 1 /S /S >>
#/MK << /CA (8) /BC [ 0 ] /BG [ 1 ] >>  % Colors
#/DA (/ZaDb 0 Tf 1 0 0 rg) % — size and colors
#/AP << /N << /${ivs}_problem /null >> >> % — checkbox value
#/Subtype /Widget
#/ANN pdfmark
#EOF

cat  << EOF >> $OUTFILE
[ 
/Subtype /Widget
/Rect [-1700 0 -1600 100] % — position
/T ( ${ivs}_shift )
/FT /Tx
/DA (/Helv 10 Tf 0 0 1 rg ) % size and colors
/V (0.0              ${ivs}_shift )
/AA <<
>>
/ANN pdfmark
EOF

	pstext -JX -R -O -K -N -P -X-5.2i <<END>>$OUTFILE
END


##echo "current record is $current_record record num is $record_num ploted record is $ploted_record"

	if( $ploted_record == $record_num ) then
		psxy  -JX5i/0.5i -R$xmin/$xmax/-1/1 -Ba10f5S -O  -N -P <<EOF>>$OUTFILE
EOF
		cat $OUTFILE >> $tmp_ps
		rm $OUTFILE 2>&/dev/null
	else if ( $current_record == $PLOT_PER_PAGE ) then
		psxy  -JX5i/0.5i -R$xmin/$xmax/-1/1 -Ba10f5S -O  -N -P <<EOF>>$OUTFILE
EOF
		@ PAGE ++
		@ ploted_record ++
		set current_record = 1
		cat $OUTFILE >> $tmp_ps
		rm $OUTFILE 2>&/dev/null
	else 
		@ current_record ++
		@ ploted_record ++
	endif
end #sta foreach

ps2pdf $tmp_ps $OUTFILE_pdf
#/bin/rm $tmp_ps
#to_hongyu $OUTFILE_pdf
