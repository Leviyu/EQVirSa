#!/bin/tcsh
#
# we tried to grab S Empirical Wavelet from processed EQs on EQ1
# we search for all possible jobs and download possible EW





set possible_job_name = ( $1 )


set EQ_LIST = ./EQ_LIST

foreach EQ (`cat $EQ_LIST|awk '{print $1}'`)
	echo "--> Working on $EQ"
foreach job (`echo $possible_job_name`)
	set possible_dir = /mnt/data2/hongyu/git_lib/DATADIR/$job/$EQ/S_ES.third.out
	set new_name = S_ES.${EQ}

	#if( -e $new_name) then
		#continue
		#endif
	
	if( ! -e $possible_dir ) then
	continue
	endif


	#echo $possible_dir
	cp $possible_dir . > & /dev/null
	if(! -e ./S_ES.third.out ) then
		continue
	endif
	set line_num = `cat ./S_ES.third.out | wc -l`
	set new_name = S_ES.${EQ}

	if($line_num < 20) then
		rm S_ES.third.out  > & /dev/null
		else 
		mv S_ES.third.out $new_name > & /dev/null
		echo "got it "
	endif

end # job
end #EQ 

