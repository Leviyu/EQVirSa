#!/bin/tcsh



# this script implemented the S ES searching by project name


set PWD = `pwd`

#set possible_job_name = (\
#Dec_multi_phase_ID_1\
#DEC_multi_phase_ID_1 \
#Dec_multi_phase_ID_2\
#DEC_multi_phase_ID_2\
#DEC_Regular_phase_ID_1\
#DEC_Regular_phase_ID_2\
#DEC_Regular_phase_ID_3\
#DEC_Regular_phase_ID_4\
#FEB_06_RUN_1\
#FEB_06_RUN_2\
#FEB_06_RUN_3\
#FEB_06_RUN_4\
#FEB_13_RUN_2\
#FEB_13_RUN_3\
#FEB_13_RUN_4\
#FEB_multi_rest\
#FEB_regular_ID1\
#FEB_regular_ID2\
#FEB_regular_ID3\
#FEB_regular_ID4\
#JAN_multi_rest\
#JAN_regular_phase_ID1\
#JAN_regular_phase_ID2\
#JAN_regular_phase_ID3\
#JAN_regular_phase_ID4\
#multi_phase_ID_1\
#multi_phase_ID_2\
#Regular_phase_ID_1\
#Regular_phase_ID_2\
#Regular_phase_ID_3\
#Regular_phase_ID_4)


set job_name_file = ./job_name



foreach JOB (`cat $job_name_file`)
	#foreach JOB (`echo $possible_job_name`)
	$PWD/c00.get_all_possible_S_ES.sh $JOB > & $PWD/LOG/logfile.$JOB &
end 
