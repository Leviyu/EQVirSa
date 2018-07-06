import numpy as np
import sys 
import os




file_name = sys.argv[1]

dt_array = []

with open(file_name,"r") as f:
    for line in f.readlines():
        value = float(line.strip())
        #print(value)
        dt_array.append(value)



#print(dt_array)
mean = np.mean(dt_array)
std = np.std(dt_array)
print("{} {}".format(mean.round(2),std.round(2)))


