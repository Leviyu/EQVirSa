#!/bin/tcsh


set vs_index = $1
csh c04.plot_VS_for_current_VS.sh $vs_index > & /dev/null &
