#!/bin/tcsh

# 
#	Down load the record listed in eventinfo
# 
set LAB_PWD = $1
set DIR_ID = $2
set JOB_ID = $3
set event = $4
set COMP = $5

set PWD = $LAB_PWD/00_who_am_I

set NUM = 1
set NUM_MAX = `cat $event |wc -l`

echo "--> Downloading data for $NUM_MAX records "
while ($NUM <= $NUM_MAX) 


	set TMP = `cat $event |awk -v dd=$NUM 'NR==dd {print $0}'`


	set EQ = $TMP[19]
	set STA = $TMP[1]
	set NET = $TMP[2]
	#/echo "Downloading data for $EQ $STA"

	set sac_file1 = "${EQ}.${NET}.${STA}.BH${COMP}.sac"
	set sac_file2 = "${EQ}.${NET}.${STA}.HH${COMP}.sac"

	## if file exist then we skip downloading
	if (-e $sac_file1 || -e $sac_file2  ) then
@ NUM ++
		continue
	endif


	get_EQ_sac $EQ/$sac_file1  > & /dev/null
	get_EQ_sac $EQ/$sac_file2  > & /dev/null



	#echo "  get_EQ_sac $EQ/$sac_file1"
	#get_EQ_sac $EQ/$sac_file1 > & /dev/null
	#get_EQ_sac $EQ/$sac_file2 > & /dev/null

	if (-e $sac_file1  ) then
	set sac_file = $sac_file1
	else if (-e $sac_file2) then
	set sac_file = $sac_file2
	else 
@ NUM ++
		continue
	endif

	#interp delta 0.1
sac << EOF >> /dev/null 
r $sac_file
lp co 0.1 n 1 p 1
interpolate delta 0.1
dif
w over
q
EOF


@ NUM ++
end
