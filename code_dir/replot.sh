#!/bin/tcsh


set PWD = `pwd`




## just work for TA
set BIG_ID = $1
set EQ_FILE = $2
#set EQ = 199603171758
set PHASE_ALL = ( ScS Sdiff ScSScS ScSScSScS ScSScSScSm ScSScSScSScS ScSScSScSScSm )

if($BIG_ID == "" || $BIG_ID == " ") then
echo "Give me ID "
exit 0
endif


echo "--> Working on $EQ_FILE"

foreach EQ (`cat $EQ_FILE`)

set ID = ${BIG_ID}_${EQ}
#csh $PWD/work.sh $ID $EQ >& logfile.${ID}  

foreach PHASE (`echo $PHASE_ALL`)
csh $PWD/plot.sh $ID $PHASE $EQ > & $PWD/LOG/replot.${ID}
end 

end 
