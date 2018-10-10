#include "hongyulibcpp.h"
#include<complex.h>
/******************************************************************
 * This is a c script to convert longitude to the [0,360]
 *
 *
******************************************************************/
double lon2360(double lon)
{

	double ans=lon;
    if (ans>=0) ans-=360.0*((int)(ans/360));
	    else ans+=360.0*(1+(int)(-ans/360));
	if (ans>=360) ans=0;
		return ans;

	return ans;
}
