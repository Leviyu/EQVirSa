#!/bin/tcsh



# this script implemented the S ES searching by project name


set PWD = `pwd`



set job_name_file = ./job_name



foreach JOB (`cat $job_name_file`)
	#foreach JOB (`echo $possible_job_name`)
	$PWD/c00.get_all_possible_S_ES.sh $JOB > & $PWD/LOG/logfile.$JOB &
end 
