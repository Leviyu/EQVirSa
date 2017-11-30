#!/bin/tcsh


set PWD = `pwd`




# 
# We divide our EQ list into 4 parts and do parallel processing

set BIG_ID = APR24




# 1. divide EQ list into 8 parts
set big_list = ./list.eq_virtual_stack
#cat $big_list |awk 'NR <= 100{print $0}' >! PART1
#cat $big_list |awk 'NR>100 && NR <= 200{print $0}' >! PART2
#cat $big_list |awk 'NR>200 && NR <= 300{print $0}' >! PART3
#cat $big_list |awk 'NR>300 && NR <= 400{print $0}' >! PART4
#cat $big_list |awk 'NR>400 && NR <= 500{print $0}' >! PART5
#cat $big_list |awk 'NR>500 {print $0}' >! PART6




# 2. run each 
set PART_LIST = ( 1 2 3 4 5 6 )
foreach PART_NUM ( `echo $PART_LIST `)
echo "--> Working on Part: $PART_NUM"
set part_file = $PWD/PART${PART_NUM}
csh $PWD/mother.file.sh $BIG_ID $part_file &
#csh $PWD/replot.sh $BIG_ID $part_file &

end 
