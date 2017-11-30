#!/bin/tcsh


set ID = $1
if($ID == "" || $ID == " ") then
exit 0
endif

set PWD = `pwd`

# Construct INFILE from INFILE.mother
set old_file = $PWD/.INFILE
set new_file = $PWD/INFILE
cat /dev/null >! $new_file

cp $old_file $new_file
set bigdir = `cat $old_file|grep CURRENT_DIR|awk '{print $2}'`

foreach NAME ( WORKDIR PLOTDIR SRCDIR EXISTING_EVENTINFO )
	set full_name = "<${NAME}>"
	set name_content = `cat $old_file |grep $NAME |awk 'NR==1 {print $2}'`
	set new_name = "<${NAME}>	$bigdir/$name_content"
	sed -i "/${full_name}/c ${new_name}" $new_file
end


set WORKDIR = `cat $PWD/INFILE |grep WORKDIR |awk 'NR==1 {print $2}'`


echo "--> Run_work.sh"
csh run_work.sh $ID $WORKDIR $PWD

##cat $PWD/LOG/logfile.${ID}.*
##get_virtual_station

