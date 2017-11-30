#!/bin/tcsh


set PWD = `pwd`




## just work for TA


foreach PHASE ( SSSS SSSSS ScSScS ScSScSScS ScSScSScSm ScSScSScSScSm SSSSm SSSSSm )
	#foreach PHASE (ScSScSScSScS S  Sdiff ScS SS SSS SSSS SSSSS ScSScS ScSScSScS ScSScSScSm ScSScSScSScSm SSSSm SSSSSm )



set ID = Dec30_${PHASE}
echo "--> Working on $ID"
csh $PWD/plot.sh $ID $PHASE >& logfile.${ID} &
sleep 10s
end



