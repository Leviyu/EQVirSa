
#include "ESF.h"
int initiate_record_name(new_RECORD* my_record)
{
	my_record->EQ = (char*)malloc(sizeof(char)*20);
	my_record->COMP = (char*)malloc(sizeof(char)*10);
	my_record->PHASE = (char*)malloc(sizeof(char)*20);
	my_record->name = (char*)malloc(sizeof(char)*20);
	my_record->NET = (char*)malloc(sizeof(char)*10);
	my_record->DIST = 0;
	my_record->DIST_DELTA = 0;
	my_record->AZ=0;
	my_record->BAZ=0;
	my_record->sta_lat = 0;
	my_record->sta_lon= 0;
	my_record->eq_lat=0;
	my_record->eq_lon=0;
	my_record->eq_dep=0;
	my_record->eq_mag = 0;
	my_record->weight = 0;
	my_record->npts_phase = 1;
	my_record->B = 0;
	my_record->E = 0;
	my_record->delta= 0.1;
	my_record->polarity = 0;
	my_record->polar_flag = 0;
	my_record->npts_signal_beg =0;
	my_record->npts_signal_end = 0;
	my_record->ray_parameter = 0;
	my_record->quality = 0;
	my_record->npts_long = 1;
	my_record->long_beg = 0;
	my_record->long_len = 1;
	my_record->long_amplitude = 1;
	my_record->npts_phase = 1;
	my_record->phase_beg = 0;
	my_record->phase_len = 0;
	my_record->npts_noise =1 ;
	my_record->noise_beg = 0;
	my_record->noise_len = 1;
	my_record->npts_ES = 1;
	my_record->ES_beg = 0;
	my_record->ES_len = 1;
	my_record->best_stretch_ccc = 0;
	my_record->best_stretch_coefficient = 0;
	my_record->best_tstar = 0;
	my_record->best_tstar_ccc = 0;
	my_record->amplitude = 0;
	my_record->prem = 0;
	my_record->prem_SNR_phase = 0;
	my_record->dt_obs_prem = 0;
	my_record->ccc = 0;
	my_record->SNR = 0;
	my_record->SNR_sig = 0;
	my_record->SNR_noi = 0;
	my_record->ONSET = 0;
	my_record->ENDSET = 0;
	my_record->misfit = 0;
	my_record->misfit2 = 0;
	my_record->misfit_pre = 0;
	my_record->misfit_bak = 0;
	my_record->record_gaussian_factor = 0;
	my_record->record_gaussian_area = 0;
	my_record->emp_gaussian_factor = 0;
	my_record->gaussian_misfit = 0;
	my_record->CCC3 = 0;
	my_record->npts_SS_peak_zero = 0;
	my_record->SS_time_phase_peak = 0;
	my_record->SS_onset_hardwire_from_S = 0;
	my_record->SS_npts_phase_peak = 0;
	my_record->ref_lat = 0;
	my_record->ref_lon = 0;
	my_record->stacking_delay_time = 0;
	my_record->fix_BAZ_delay_time = 0;
	my_record->fix_slow_delay_time = 0;
	my_record->dt_average = 0;
	my_record->dt_STD = 0;
	my_record->checked_to_be_good = 0;
	my_record->stretched_phase_win_flag = 0;
	my_record->shift_time_recorder = 0;
	my_record->num_traffic = 0;
	my_record->traffic_range_sec = 0;
	my_record->beyong_window_flag = 0;
	my_record->noise_too_short_flag = 0;


	return 0;
}
