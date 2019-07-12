#!/bin/tcsh



set PWD = `pwd`
set ID = `cat $PWD/INFILE |grep ID |awk '{print $2}'`
echo "---> Working on ID : $ID"
set old_file = $PWD/INFILE
set new_file = $PWD/WORKDIR/INFILE
cat /dev/null >! $new_file

cp $old_file $new_file
set bigdir = `cat $old_file|grep CURRENT_DIR|awk 'NR==1 {print $2}'`

foreach NAME ( WORKDIR PLOTDIR SRCDIR EXISTING_EVENTINFO CPP_LAB C_DIR)
	set full_name = "<${NAME}>"
	set name_content = `cat $old_file |grep -w $full_name |awk 'NR==1 {print $2}'`
	set new_name = "<${NAME}>	$bigdir/$name_content"
	sed -i "/${full_name}/c ${new_name}" $new_file
end


set WORKDIR = `cat $new_file |grep WORKDIR |awk 'NR==1 {print $2}'`
echo "WORKDIR is $WORKDIR"

echo "--> Run_work.sh"

csh $PWD/code_dir/run_work.sh $ID $WORKDIR $PWD

