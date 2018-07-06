#!/bin/tcsh



set PWD = `pwd`

foreach EQ (`ls logfile* |awk -F"__" '{print $2}' `)
	echo "---> Working on $EQ"

	set ID = APR3__${EQ}


set PHASE_ALL = ( ScS Sdiff ScSScS ScSScSScS ScSScSScSm ScSScSScSScS ScSScSScSScSm )
foreach PHASE (`echo $PHASE_ALL`)
	#csh $PWD/plot.sh $ID $PHASE

	csh $PWD/plot.sh $ID $PHASE >! $PWD/LOG/logfile.${ID}
end #PHASE

end 

