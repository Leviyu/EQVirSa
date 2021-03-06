
#include "forward_tomography.h"


#define MAX 3100
new_record::new_record()
{
	// default componente
	this->COMP = "T";
}


new_record::~new_record()
{
}


void new_record::get_incident()
{
	double incident;
	incident = taup_incident(this->eq_lat, this->eq_lon, this->eq_dep, this->sta_lat , this->sta_lon, this->PHASE);
	this->incident = incident;

}

/******************************************************************
 * This script calcuate the crustal correction for current record
 * based on its station lat/lon
 *	
 *
 *	currently we are using CRUST 1.0 model 
 *
 * 	The crustal correction time for each record is calculated by:
 * 	1. get the crustal thickness at current station location
 * 	2. For each 
******************************************************************/

void new_record::get_crustal_correction()
{

	double lat = this->sta_lat;
	double lon = this->sta_lon;
	double thickness  = 0 ;
	double CRUST_TIME;
	double PREM_TIME;

	cout << "lat lon "<< lat << " "<< lon << endl;
	this->my_crust[0].get_single_station_correction(lat , lon, &thickness , &CRUST_TIME, &PREM_TIME );


	this->crust_correction = PREM_TIME - CRUST_TIME  ;


}



void new_record::download_sac_file()
{
	//cout << " --> download_sac_file "<< endl;
	string EQ 		= this->EQ;
	string PHASE 	= this->PHASE;
	string COMP 	= this->COMP;
	string STA 		= this->STA;
	string NET 		= this->NET;
	string sac_file1 = EQ+"."+NET+"."+STA+".BH"+COMP+".sac";
	string sac_file2 = EQ+"."+NET+"."+STA+".HH"+COMP+".sac";
	string sod_sac1 = "/mnt/soddisk/soduser/Merge.Mw6.50km/"+EQ+"/"+sac_file1;
	string sod_sac2 = "/mnt/soddisk/soduser/Merge.Mw6.50km/"+EQ+"/"+sac_file2;
	string sac_file = "";


	// if sac_file exist, we continue
	// else if sod_sac exist, copy and c06
	//if(!is_file_exist(sac_file1)  )	
	//{
		if(is_file_exist(sod_sac1))
		{
			//string command = "cp ~/Downloads/"+ sac_file1+ " .  >  /dev/null";
			//string command = "get_EQ_sac "+ EQ+"/"+sac_file1;
			//exec(command);
			sac_file = sac_file1;

			string filter_command = "csh c06.record_filter_and_resample.sh "+ sac_file1 + " " + PHASE 
				+" "+ sod_sac1 ;
			exec(filter_command);
		}
	//}
	//if(!is_file_exist(sac_file2)  )	
	//{
		if(is_file_exist(sod_sac2))
		{
			//string command = "cp ~/Downloads/"+ sac_file1+ " .  >  /dev/null";
			//string command = "get_EQ_sac "+ EQ +"/"+sac_file2;
			//exec(command);
			sac_file = sac_file2;
			string filter_command = "csh c06.record_filter_and_resample.sh "+ sac_file2 + " "+ PHASE 
				+ " "+ sod_sac2;
			exec(filter_command);
		}
	//}
}





void new_record::read_sac_file()
{
	//cout << "--> Read sac file"<< endl;
	int count;
	string long_win_name;
	// allocation long win memory
	this->long_win.resize(MAX);


	// 1. get PREM time for current record
	double PREM;
	string taup_command = "get_taup_time "+ this->EQ + " "+ this->STA + " "+ this->PHASE ;
	PREM = atof(exec(taup_command).c_str());

	

	if( PREM <= 0 )
		cout << "ERROR PREM <= 0 EQ lat lon dep " <<  this->eq_lat 
			<< "  " << this->eq_lon
			<< "  " << this->eq_dep
			<< " STA lat lon dep " << this->sta_lat
			<< "  " << this->sta_lon
			<< " PHASE : " << this->PHASE  << endl;


	//2. get defined long window
	double LON_BEG = this->long_beg;
	double LON_LEN = this->long_len;
	double delta =  this->delta;
	int NUM = 100000;
	int npts = (int) (LON_LEN / delta);
	vector<double> X(npts,0);



	string EQ 		= this->EQ;
	string PHASE 	= this->PHASE;
	string COMP 	= this->COMP;
	string STA 		= this->STA;
	string NET 		= this->NET;
	string sac_file1 = EQ+"."+NET+"."+STA+".BHT.sac";
	string sac_file2 = EQ+"."+NET+"."+STA+".HHT.sac";

	// get polarity 
	this->get_polar_flag();


	double abs_beg;
	double length;
	//cout << " PREM is "<< PREM << " long beg is "<< this->long_beg<< endl;
	abs_beg = PREM + this->long_beg;
	length = this->long_len;

	int error_flag = 0;
	if( is_file_exist(sac_file1) )
	{
		this->sac_file = sac_file1;
		error_flag = sac2xy_with_delta(this->sac_file,abs_beg, length, &this->long_win[0], this->delta);
	}
	else if( is_file_exist(sac_file2) )
	{
		this->sac_file = sac_file2;
		error_flag = sac2xy_with_delta(this->sac_file,abs_beg, length, &this->long_win[0], this->delta);
	}
	else
	{
		// if both not exist, we hardwire sac_file to be 0
		for(count = 0; count < npts; count++)
			this->long_win[count] = 0.00000001;
	}

	if( error_flag == 1)
	{
		for(count = 0; count < npts; count++)
			this->long_win[count] = 0.00000001;
	}




	// write xy window
	for(count = 0; count < npts; count++)
		X[count] = LON_BEG + count * delta;
	//normalize this longwin
	normalize_array(&this->long_win[0], npts);


	vector<double> long_win_flipped(npts,0);
	for(count = 0; count < npts; count++)
	{
		if( this->polarity_flag == 0)
			long_win_flipped[count] = this->long_win[count]* 1;
		else
			long_win_flipped[count] = this->long_win[count]* this->polarity_flag;
	}


	// normalize long_win
	// int normalize_array_with_flag(double* array, int len, int flag)
	normalize_array_with_flag(&this->long_win[0], npts,1);


	long_win_name = "long_win."+this->EQ+"."+this->STA+"."+this->PHASE;
	output_array2(long_win_name , &X[0],&long_win_flipped[0] , npts, 0);
	//cout << " read sac file done "<< this->EQ<< " "<< this->STA << " "<< this->PHASE  << endl;

}


void new_record::convert_long_win_to_velocity()
{
	int npts = (int)(this->long_len / this->delta);
	int count = 0;
	for(count = 0; count < npts- 1; count ++)
	{
		this->long_win[count] = this->long_win[count+1] - this->long_win[count];
	}

	return;
}

void new_record::get_polar_flag()
{
	// if this record has been calculated before we skip
	if( this->polarity_flag == 1 || this->polarity_flag == -1)
		return;
	
	string EQ = this->EQ;
	string STA = this->STA;
	string PHASE = this->PHASE;
	string COMP = "T";


	string command = "make_polar "+ EQ + " "+ STA + " "+ PHASE + " "+ COMP ;
	double polar = 0;
	polar = atof(exec(command).c_str());
	
	if( polar == 0)
		polar = 1;
	this->polarity = polar;

	if(this->polarity > 0)
		this->polarity_flag = 1;
	else
		this->polarity_flag = -1;
}



void new_record::calculate_SNR()
{
	//cout << "--> Calculate SNR "<< endl;
	// this function calculate the SNR of current record for current PHASE
	

	// 1. check if noise_beg and noise len defined
	if( this->noise_beg == 0 || this->noise_len == 0 || this->noise_beg != this->noise_beg )
	{
		cout << "ERROR Noise window for current station is not defined" << endl;
		this->SNR = 0.5;
		return;
	}


	double noise_signal;
	double phase_signal;
	noise_signal = 0;
	phase_signal = 0;

	int npts_noise_beg;
	int npts_noise_len;
	int npts_phase_beg;
	int npts_phase_len;

	npts_noise_beg = (int) ( (this->noise_beg - this->long_beg ) / this->delta );
	npts_phase_beg = (int) ( (this->phase_beg - this->long_beg ) / this->delta );
	npts_noise_len = (int) (this->noise_len  / this->delta);
	npts_phase_len = (int) (this->phase_len  / this->delta);
	int count;
	for(count = 0; count < npts_noise_len ; count++)
	{
		noise_signal += fabs  ( this->long_win[npts_noise_beg + count] );
	}

	for(count = 0; count < npts_phase_len ; count++)
	{
		phase_signal += fabs( this->long_win[npts_phase_beg + count] );
	}

	if( noise_signal == 0)
	{
		cout << "ERROR when calculateing SNR, noise signal is zero!" << endl;
		this->SNR = 1;
	}
	else
		this->SNR = (phase_signal/ npts_phase_len) / (noise_signal / npts_noise_len);


	if(this->SNR != this->SNR )
		this->SNR = 0.5;


}




void new_record::read_cross_point_info(new_tomo* my_tomo)
{
	//cout <<  "read_cross_point_info" << endl;
	this->cross_point_file = my_tomo->cross_point_dir + "/cross_point."
		+this->EQ + "."+ this->STA+ "."+this->PHASE+"."+this->COMP;

	this->read_taup_path_info(my_tomo->taup_path_dir);
	this->find_cross_points(my_tomo);
	// read in cross point file
	ifstream myfile;
	myfile.open(this->cross_point_file.c_str());
	int line_num ;
	line_num = 0;
	line_num = count_file_num(this->cross_point_file);

	//read in cross file
	cout << "read in cross file max num is " << this->cross_point_file << " max num" << line_num << endl;
	int count;
	double code_PREM_time;
	code_PREM_time = 0;
	for(count = 0; count < line_num ; count ++)
	//while(!myfile.eof())
	{
		myfile >> this->CP_dep[count];
		//cout << "dep is " << this->CP_dep[count]<< endl;
		myfile >> this->CP_lat[count];
		myfile >> this->CP_lon[count];
		myfile >> this->CP_idep[count];
		myfile >> this->CP_ilat[count];
		myfile >> this->CP_ilon[count];
		myfile >> this->CP_dl[count];
		myfile >> this->CP_v_PREM[count];
		myfile >> this->CP_weight[count];
		code_PREM_time += this->CP_dl[count] / this->CP_v_PREM[count];
		cout << " dep "<< this->CP_dep[count] 
			<< " dl " << this->CP_dl[count]
			<< " PREM "<< this->CP_v_PREM[count]
			<< endl;

		// debug check for unread value
		if(this->CP_v_PREM[count] == 0)
		{
			// when this condition happen, we manually set the CP of this file
			cout << "ERROR current file not read in cause v_prem is zero "<< this->cross_point_file << endl;
			this->CP_num = 0;
			this->code_PREM = 0;
			return ;
			

			cout << "line num  " << count << endl;
			cout << this->CP_idep[count]
				<< "      " << this->CP_ilat[count]
				<< "      " << this->CP_ilon[count] << endl;
			cout << "ERROR CP_V_prem is 0, record is " << this->STA << endl;
			cout <<"V_PREM is "<< this->CP_v_PREM[count] << endl;
		}


		//line_num ++;
	}
	//line_num--;


	//cout <<"file name " << this->cross_point_file << "file line is " << line_num << endl;
	this->CP_num = line_num;
	this->code_PREM = code_PREM_time;

	myfile.close();

}

void new_record::find_cross_points(new_tomo* my_tomo)
{

	//cout << "--> working on finding cross points " << endl;
	// go through taup_path (0.05degree sampled)
	// Decide whether we go to the next cell
	// if index of dep lat lon does not change, the same cell

	int count;
	int old_index_dep, old_index_lat, old_index_lon;
	old_index_dep = 0;
	old_index_lat = 0;
	old_index_lon = 0;
	double lat_tmp,lon_tmp;
	double dep_tmp;
	int idep, ilat, ilon;
	int index_dep, index_lat, index_lon;

	double angle[MAX];
	double radius[MAX];

	this->CP_num = 0;



	for(count = 0; count < this->taup_path_max_num ; count ++)
	{

		// find the lat lon of current point
		waypoint(this->eq_lon , this->eq_lat, this->sta_lon,this->sta_lat, this->angle[count],&lon_tmp, &lat_tmp);


		dep_tmp = 6371 - this->radius[count];


		// check the location of current point
		index_dep = my_tomo->find_index_dep2(dep_tmp);

		index_lat = my_tomo->find_index_lat(lat_tmp);
		index_lon = my_tomo->find_index_lon(lon_tmp, index_lat);
		
		if(count <= this->taup_path_max_num  -1) 
		{
			// if stay in the same cell, continue
			if(this->CP_num != 0 && ( index_dep != old_index_dep 
					||  index_lat != old_index_lat
					|| index_lon != old_index_lon ))
			{
				double old_dep, old_lat, old_lon;
				double cross_dep, cross_lat, cross_lon;
				double delta_angle, mid_radius;
				old_dep = this->CP_dep[this->CP_num -1];
				old_lat = this->CP_lat[this->CP_num -1];
				old_lon = this->CP_lon[this->CP_num -1];

				// find extra cross-points
				my_tomo->pointA_pointB_find_cross_pointC(old_dep, old_lat, old_lon,
						dep_tmp, lat_tmp, lon_tmp,
						old_index_dep, old_index_lat, old_index_lon,
						index_dep, index_lat, index_lon,
						&cross_dep, &cross_lat, &cross_lon,
						&delta_angle, &mid_radius);

				// add this point into our path
				this->CP_lat[this->CP_num] = cross_lat;
				this->CP_lon[this->CP_num] = cross_lon;
				this->CP_dep[this->CP_num] = cross_dep;

				this->CP_ilat[this->CP_num] = index_lat;
				this->CP_ilon[this->CP_num] = index_lon;
				this->CP_idep[this->CP_num] = index_dep;
				double delta_angle_current_line;
				delta_angle_current_line = (this->angle[count] - this->angle[count-1]);
				angle[this->CP_num] = this->angle[count-1] + delta_angle *delta_angle_current_line;
				radius[this->CP_num] = mid_radius;
				this->CP_num ++;
				

				old_index_dep = index_dep;
				old_index_lat = index_lat;
				old_index_lon = index_lon;
				this->CP_lat[this->CP_num] = lat_tmp;
				this->CP_lon[this->CP_num] = lon_tmp;
				this->CP_dep[this->CP_num] = dep_tmp;

				this->CP_ilat[this->CP_num] = index_lat;
				this->CP_ilon[this->CP_num] = index_lon;
				this->CP_idep[this->CP_num] = index_dep;
				angle[this->CP_num] = this->angle[count];
				radius[this->CP_num] = this->radius[count];

				this->CP_num ++;
			}
			else
			{

				old_index_dep = index_dep;
				old_index_lat = index_lat;
				old_index_lon = index_lon;
				this->CP_lat[this->CP_num] = lat_tmp;
				this->CP_lon[this->CP_num] = lon_tmp;
				this->CP_dep[this->CP_num] = dep_tmp;

				this->CP_ilat[this->CP_num] = index_lat;
				this->CP_ilon[this->CP_num] = index_lon;
				this->CP_idep[this->CP_num] = index_dep;
				angle[this->CP_num] = this->angle[count];
				radius[this->CP_num] = this->radius[count];

				this->CP_num ++;




			}
		}

	}

	// now update the dl info and V_prem info for current 
	
	// we have CP_num points and CP_num -1 cells
	double delta_angle;
	int dep_index_tmp1;
	double RMS_tmp;
	double R1, R2;
	double c_dep,c_lat,c_lon;
	double PREM_tmp;
	double SUM_dl;
	double weight_cell[this->CP_num];
	double SUM_RMS;
	SUM_dl = 0;
	SUM_RMS = 0;

	for(count = 0; count < this->CP_num -1 ; count ++)
	{
		// calculate the dl between two points
		delta_angle = angle[count +1]- angle[count];
		delta_angle = delta_angle / 180 * 3.1415926;
		R1 = radius[count];
		R2 = radius[count+1];
		this->CP_dl[count] = sqrt( R1*R1 + R2*R2 - 2*R1*R2*cos(delta_angle) );
		double dep_haha;
		dep_haha =  ( this->CP_dep[count] + this->CP_dep[count+1] ) /2; 
		if(dep_haha >= 2890 )
			dep_haha = 2890;
		prem_s(dep_haha, &PREM_tmp, 0 );
		this->CP_v_PREM[count] = PREM_tmp;
		

		// construct the weight to distribute travel time  residual
		//my_tomo.weight_ratio_path_length_RMS_tomo = 0;
		
		dep_index_tmp1 = this->CP_idep[count];
		RMS_tmp = my_tomo->RMS_weight[dep_index_tmp1];
		//cout << "RMS tmp is " << RMS_tmp << endl;

		SUM_dl += this->CP_dl[count];
		SUM_RMS += RMS_tmp;


		if(SUM_dl == 0 || SUM_dl!= SUM_dl )
		{
			cout << "count  " << count <<endl;
			cout << "R1 R2 delta angle  " << R1 << "    " << R2 << "   " << delta_angle <<endl;
			cout << "cp dl is " << this->CP_dl[count] << endl;;
			cout << "ERROR SUM_dl problem" << endl;
		}
	}

	if(SUM_RMS == 0 || SUM_RMS != SUM_RMS )
		cout << "ERROR SUM_RMS problem" << endl;

	// normalize dl and RMS
	double weight_RMS[this->CP_num];
	double weight_dl[this->CP_num];
	double SUM_weight;
	SUM_weight = 0;
	for(count = 0; count < this->CP_num -1 ; count ++)
	{
		dep_index_tmp1 = this->CP_idep[count];
		RMS_tmp = my_tomo->RMS_weight[dep_index_tmp1];
		weight_RMS[count] = RMS_tmp / SUM_RMS * my_tomo->weight_ratio_path_length_RMS_tomo;
		weight_dl[count] = this->CP_dl[count] / SUM_dl;

		weight_cell[count] = weight_RMS[count] * weight_dl[count];
		SUM_weight += weight_cell[count];

	}




	// define weight for each cell
	for(count = 0; count < this->CP_num -1 ; count++)
	{
		this->CP_weight[count] = weight_cell[count] / SUM_weight;
	}

	// output as cross-file info
	ofstream myfile;
	myfile.open(this->cross_point_file.c_str());
	for(count = 0; count < this->CP_num -1; count++)
	{
		if( this->CP_dl[count] == 0 )
			continue;
		myfile << fixed
			<< setw(15) << setprecision(2) << this->CP_dep[count]
			<< setw(15) << setprecision(2) << this->CP_lat[count]
			<< setw(15) << setprecision(2) << this->CP_lon[count]
			<< setw(15) << setprecision(2) << this->CP_idep[count]
			<< setw(15) << setprecision(2) << this->CP_ilat[count]
			<< setw(15) << setprecision(2) << this->CP_ilon[count]
			<< setw(15) << setprecision(4) << this->CP_dl[count]
			<< setw(15) << setprecision(4) << this->CP_v_PREM[count]
			<< setw(15) << setprecision(4) << this->CP_weight[count]
			<< endl;

	}
	
	myfile.close();

}






void new_record::read_taup_path_info(string taup_path_dir)
{
	
	double sampling_rate;
	sampling_rate = 0.01;				// sample a point every 0.05 degree

	this->taup_path_file = taup_path_dir + "/taup_path."+this->EQ+"."+this->STA+"."+this->PHASE
		+"."+this->COMP;

	ifstream myfile;
	myfile.open(this->taup_path_file.c_str());
	double tmp1,tmp2;
	int line_max;
	line_max = count_file_num(this->taup_path_file);
	// allocate memory for taup angle and radius
	this->angle.resize(line_max);
	this->radius.resize(line_max);
	double angle[line_max];
	double radius[line_max];

	int count;
	//read in data line by line
	// make sure the the angle is increasing 
	double old_angle;
	for(count = 0 ; count < line_max;count++)
	{
		//myfile >> angle[count];
		myfile >> this->angle[count];
		if( angle[count] == old_angle)
			angle[count] += 0.001;
		myfile >> this->radius[count];
		//myfile >> radius[count];
		myfile >> tmp1;
		myfile >> tmp2;
		
		old_angle = angle[count];
	}

	this->taup_path_max_num = line_max;

	myfile.close();

}




void new_record::initiate_CP()
{
	//cout << "--> Initiate CP info " << endl;
	this->CP_v_PREM.resize(MAX);
	this->CP_lat.resize(MAX);
	this->CP_dep.resize(MAX);
	this->CP_lon.resize(MAX);
	this->CP_lat.resize(MAX);
	this->CP_ilat.resize(MAX);
	this->CP_idep.resize(MAX);
	this->CP_ilon.resize(MAX);
	this->CP_dl.resize(MAX);
	this->CP_weight.resize(MAX);
	this->current_CP_weight.resize(MAX);


}
void new_record::free_CP()
{
	////cout << "--> Initiate CP info " << endl;
}




void new_record::calculate_tomo_correction(new_tomo* my_tomo)
{

	//cout << "--> working on tomo correction "<< endl;
	int count;
	double velocity_tmp;
	double dvs_tomo;
	int idep, ilat , ilon;
	this->dt_tomo_correction = 0;

	for(count = 0; count < this->CP_num; count ++)
	{
		idep = this->CP_idep[count];
		ilat = this->CP_ilat[count];
		ilon = this->CP_ilon[count];
		dvs_tomo = my_tomo->my_cell[idep][ilat][ilon].dvs;
		velocity_tmp = this->CP_v_PREM[count] * (1+ dvs_tomo / 100);

		this->dt_tomo_correction += (this->CP_dl[count] /  velocity_tmp ) 
			- (this->CP_dl[count] / this->CP_v_PREM[count]);

		if( this->CP_v_PREM[count] == 0)
			cout << "idep ilat ilon  " << idep << "   " << ilat << "   " << ilon << endl;

	}




	//cout <<"tomography correction is  "<< this->dt_tomo_correction << endl;

}

void new_record::get_ellip_corr()
{
	double ellip_corr;
	string PHASE;
	char* P;
	int count;
	double depth;
	double colat;
	double dist;
	double az;
	double dt;
	PHASE = this->PHASE;


	int default_phase = 0;


	vector<string> v = {"P", "Pdiff", "PcP", "ScS", "PP", "S" ,"Sdiff", "PcS", "PS", "SP", "SS"};

	//cout << "phase table length is " << PHASE_TABLE[] length()<< endl;
	for (count = 0; count < v.size(); count++)
	{
		if( v[count].compare( PHASE) == 0  )
		{
			//cout << "PHASE is default" << endl;
			default_phase = 1;
		}

	}
	// for phase that is check able in Kennett table, we use the origional table


	// find default phase ellip corr
	if(default_phase  == 1 )
	{

		P = string_to_char(PHASE);
		depth = this->eq_dep;
		colat = 90 - this->eq_lat;
		az = this->AZ;
		dist = this->DIST;
		ellipcor_kennett(P, depth , colat, dist,  az, &dt);

		this->ellip_corr = dt;
		cout << " sta "<< this->STA << " ellip corr is "<< dt << endl;


	}
	else
	{
		string phase_family;
		// multi S family
		if(PHASE.compare("SSS") == 0 || 
			PHASE.compare("SSSm") == 0 ||	
			PHASE.compare("SSSS") == 0 ||	
			PHASE.compare("SSSSm") == 0 ||	
			PHASE.compare("SSSSS") == 0 ||	
			PHASE.compare("SSSSSm") == 0 ||	
			PHASE.compare("SSSSSS") == 0 ||	
			PHASE.compare("SSSSSSm") == 0 ||	
			PHASE.compare("SSSSSSS") == 0 ||	
			PHASE.compare("SSSSSSSm") == 0 	)
		{
			phase_family = "S";

		}
		else if ( 
				PHASE.compare("ScSScSm") == 0 ||	
				PHASE.compare("ScSScSScS") == 0 ||	
				PHASE.compare("ScSScSScSm") == 0 ||	
				PHASE.compare("ScSScSScSScS") == 0 ||	
				PHASE.compare("ScSScSScSScSm") == 0 ||	
				PHASE.compare("ScSScSScSScSScS") == 0 ||	
				PHASE.compare("ScSScSScSScSScSm") == 0 ||	
				PHASE.compare("ScSScSScSScSScSScS") == 0 ||	
				PHASE.compare("ScSScSScSScSScSScSm") == 0 )
		{
			phase_family = "ScS";
		}
			this->ellip_corr = 0;


			string eventinfo = this->record_file;
			// first run get_surface_bounce_point_location to get all the surface bounce points
			string command;
			command = "get_surface_bounce_point_location " + this->EQ + " " + this->STA + " " + this->PHASE +" " + eventinfo;
			//cout << command << endl;
			exec(command);


			string bounce_point_file = "tmp.get_surface_bounce_point_location";

			ifstream myfile;
			myfile.open(bounce_point_file.c_str());


			int legs = count_file_num(bounce_point_file );
			//cout << " " << eventinfo << " has " << legs << " legs " << endl;


			double prev_leg_dist = 0;

			for(count = 1; count <= legs ; count ++)
			{
				if( count == 1)
				{
					P = string_to_char(phase_family);
					depth = this->eq_dep;
					colat = 90 - this->eq_lat;
					az = this->AZ;
					double t_dist, t_dep, t_time, t_lat, t_lon;
					myfile >> t_dist >> t_dep >> t_time >> t_lat >> t_lon ;
					t_dist = fabs(t_dist);
					dist = t_dist;	
					ellipcor_kennett(P, depth, colat , dist, az , &dt);
					this->ellip_corr += dt;
					prev_leg_dist = t_dist;
				}
				else
				{
					P = string_to_char(phase_family);
					depth = 0;
					//get new colat 
					az = this->AZ;
					double new_lat, new_lon;
					double t_dist, t_dep, t_time, t_lat, t_lon;
					myfile >> t_dist >> t_dep >> t_time >> t_lat >> t_lon ;
					t_dist = fabs(t_dist);
					point_AZ_dist_point( this->eq_lat,this->eq_lon , az , t_dist , &new_lat , &new_lon);
					colat = 90 - new_lat;
					dist = t_dist - prev_leg_dist;
					prev_leg_dist = t_dist;
					ellipcor_kennett(P, depth, colat , dist, az , &dt);
					this->ellip_corr += dt;

				}

			}
			myfile.close();

	}


}


