import math
import sys

# pointA is event pointB is STA
def calculate_initial_compass_bearing(pointA, pointB):
    if (type(pointA) != tuple) or (type(pointB) != tuple):
        raise TypeError("Only tuples are supported as arguments")

    lat1 = math.radians(pointA[0])
    lat2 = math.radians(pointB[0])

    diffLong = math.radians(pointB[1] - pointA[1])

    x = math.sin(diffLong) * math.cos(lat2)
    y = math.cos(lat1) * math.sin(lat2) - (math.sin(lat1)
            * math.cos(lat2) * math.cos(diffLong))

    initial_bearing = math.atan2(x, y)

    initial_bearing = math.degrees(initial_bearing)
    compass_bearing = (initial_bearing + 360) % 360

    return compass_bearing



eq_lat = float(sys.argv[1])
eq_lon = float(sys.argv[2])
sta_lat = float(sys.argv[3])
sta_lon = float(sys.argv[4])
#//pointA = (-10,120)
#pointB = (20,120)
event = (eq_lat , eq_lon)
sta = (sta_lat ,sta_lon)
print calculate_initial_compass_bearing(event, sta)
