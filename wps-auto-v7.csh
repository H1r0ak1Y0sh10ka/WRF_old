#!/bin/sh -f

#### adected ensemble downscale experiments

set WPSDIR = /Users/yoshioka-hiroaki/local/model/WRFv3.4.1/WPS
set WRFDIR = /Users/yoshioka-hiroaki/local/model/WRFv3.6.1/WRFV3/run
set WORKDIR = /Users/yoshioka-hiroaki/model/PALI-v2
set DATADIR = /Volumes/RAID01/research/DATA/
echo ${DATADIR}

set ungrib  = on
set geogrid = off
set metgrid = on
set real    = on

###### set time #######

set dom         = 1       # domain number (1 only)

set stayear     = 2016    # YYYY
set stamonth    = 01      # MM
set staday      = 01      # DD
set stahour     = 00      # HH
set stamin      = 00      # MM
set stasec      = 00      # SS

set endyear     = 2016    # YYYY
set endmonth    = 01      # MM
set endday      = 09      # DD
set endhour     = 00      # HH
set endmin      = 00      # MM
set endsec      = 00      # SS

set dataint     = 21600    #initial data intarval (sec)

###### set domain ######

set centerlon   = -174.00
set centarlat   = 7.00
set resolution  = 10000   #meter
set gridx       = 251
set gridy       = 251
set mapc        = mercator

##### set run ######

set timestep = 30

echo ${stayear},${stamonth},${staday},${stahour},${stamin},${stasec}
echo ${endyear},${endmonth},${endday},${endhour},${endmin},${endsec}
echo 'started'

##### making working directory #####
if(! -d ${WORKDIR})then
mkdir ${WORKDIR}
endif
if(! -d ${WORKDIR}/wrfdir)then
mkdir ${WORKDIR}/wrfdir
endif
if(! -d ${WORKDIR}/wpsdir)then
mkdir ${WORKDIR}/wpsdir
endif

###### WPS ######
cd ${WORKDIR}/wpsdir
ln -fs ${WPSDIR}/geogrid/GEOGRID.TBL.ARW ./GEOGRID.TBL
ln -fs ${WPSDIR}/metgrid/METGRID.TBL.ARW ./METGRID.TBL
#ln -fs ${WPSDIR}/metgrid/METGRID.TBL.GEFSR2 ./METGRID.TBL


set mem = 10 
set mmm = c00
while (${mem} <= 10 )
cd ${WORKDIR}/wpsdir

if (${mem} == 0)then
set mmm = c0${mem}
else if (${mem} >= 1 && ${mem} < 10)then
set mmm = p0${mem}
else if (${mem} >= 10 && ${mem} < 100)then
set mmm = p${mem}
endif

echo 'member is '${mmm}

foreach FILENAME( GEFS_ATMOS FNL_SOIL ) #GFS_SOILGEFS_ATMOS 
echo ${FILENAME}
 
if( -d ./namelist.wps)then
rm -f ./namelist.wps
endif

cat>./namelist.wps<<EOF
&share
 wrf_core = 'ARW',
 max_dom = ${dom},
 start_date = '${stayear}-${stamonth}-${staday}_${stahour}:${stamin}:${stasec}',
 end_date   = '${endyear}-${endmonth}-${endday}_${endhour}:${endmin}:${endsec}',
 interval_seconds = ${dataint}
 io_form_geogrid = 2,
 debug_level = 1000,
/

&geogrid
 parent_id         =    1,
 parent_grid_ratio =    1,
 i_parent_start    =    1,
 j_parent_start    =    1,
 e_we              =  ${gridy},
 e_sn              =  ${gridx},
 geog_data_res     = '30s',
 dx = ${resolution},
 dy = ${resolution},
 map_proj = '${mapc}',
 ref_lat   =  ${centarlat},
 ref_lon   = ${centerlon},
 truelat1  =  30.0,
 truelat2  =  60.0,
 stand_lon = 135.0,
 geog_data_path = '/Users/yoshioka-hiroaki/local/model/geog/'
 opt_geogrid_tbl_path = './'
/

&ungrib
 out_format = 'WPS',
 prefix = '${FILENAME}',
/

&metgrid
 fg_name = 'FNL_SOIL','GEFS_ATMOS',
 io_form_metgrid = 2, 
 opt_metgrid_tbl_path         = './',
/

EOF

if (${FILENAME} == GEFS_ATMOS)then

        echo ${WPSDIR}'/link_grib.csh ${DATADIR}/GEFSR2/'${stayear}${stamonth}${staday}'/'${stayear}${stamonth}${staday}'_${mmm}_f???.grib2'
        ${WPSDIR}/link_grib.csh ${DATADIR}/GEFSR2/${stayear}${stamonth}${staday}/${stayear}${stamonth}${staday}_${mmm}_f???.grib2
        ln -sf ${WPSDIR}/ungrib/Variable_Tables/Vtable.GEFSR2_new ./Vtable
${WPSDIR}/ungrib.exe

else if (${FILENAME} == GFS_SOIL) then

        echo ${WPSDIR}'/link_grib.csh ~/DATA/GFS-anl/gfsanl_4_'${stayear}${stamonth}${staday}'.grb2'
        ${WPSDIR}/link_grib.csh ~/DATA/GFS-anl/gfsanl_3_${stayear}*.grb
        ln -sf ${WPSDIR}/ungrib/Variable_Tables/Vtable.GFS_soilonly_new2 ./Vtable
        ${WPSDIR}/ungrib.exe

else if (${FILENAME} == FNL_SOIL) then

        ${WPSDIR}/link_grib.csh ${DATADIR}/NCEP-FNL/fnl_${stayear}*.grib2
        ln -sf ${WPSDIR}/ungrib/Variable_Tables/Vtable.GFS_soilonly_new2 ./Vtable
        ${WPSDIR}/ungrib.exe

endif

end

if(${geogrid} == on)then
if(${mem} == 0)then
${WPSDIR}/geogrid.exe
endif
endif

if(${metgrid} == on)then
${WPSDIR}/metgrid.exe
endif

###### WRF ######
cd ${WORKDIR}/wrfdir
ln -fs ${WRFDIR}/ETAMPNEW_DATA .
ln -fs ${WRFDIR}/ETAMPNEW_DATA.expanded_rain .
ln -fs ${WRFDIR}/GENPARM.TBL .
ln -fs ${WRFDIR}/LANDUSE.TBL .
ln -fs ${WRFDIR}/SOILPARM.TBL .
ln -fs ${WRFDIR}/VEGPARM.TBL .
ln -fs ${WRFDIR}/tr49t67 .
ln -fs ${WRFDIR}/tr49t85 .
ln -fs ${WRFDIR}/tr67t85 .
ln -fs ${WRFDIR}/ozone.formatted .
ln -fs ${WRFDIR}/ozone_lat.formatted .
ln -fs ${WRFDIR}/ozone_plev.formatted .
ln -fs ${WRFDIR}/RRTM_DATA .
ln -fs ${WRFDIR}/RRTMG_LW_DATA .
ln -fs ${WRFDIR}/RRTMG_SW_DATA .
ln -fs ${WORKDIR}/wpsdir/met_em* .

if( -d ./namelist.input)then
rm -f ./namelist.input
endif

cat>./namelist.input<<EOF
&time_control
 run_days                            = 0,
 run_hours                           = 0,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = ${stayear},
 start_month                         = ${stamonth},
 start_day                           = ${staday},
 start_hour                          = ${stahour},
 start_minute                        = ${stamin},
 start_second                        = ${stasec},
 end_year                            = ${endyear},
 end_month                           = ${endmonth},
 end_day                             = ${endday},
 end_hour                            = ${endhour},
 end_minute                          = ${endmin},
 end_second                          = ${endsec},
 interval_seconds                    = ${dataint},
 input_from_file                     = .true.,
 fine_input_stream                   =  0,
 history_interval                    = 60,
 frames_per_outfile                  = 24,
 restart                             = .false.,
 restart_interval                    = 2880,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 io_form_auxinput2                   = 2
 debug_level                         = 0
/

&domains
 time_step                           = ${timestep},
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = ${dom},
 e_we                                = ${gridy},
 e_sn                                = ${gridx},
 e_vert                              = 40, 
 p_top_requested                     = 1000,
 num_metgrid_levels                  = 12,
 num_metgrid_soil_levels             = 4,
 dx                                  = ${resolution},
 dy                                  = ${resolution}, 
 grid_id                             = 1, 
 parent_id                           = 0,
 i_parent_start                      = 1,
 j_parent_start                      = 1,
 parent_grid_ratio                   = 1, 
 parent_time_step_ratio              = 1,
 feedback                            = 1,
 smooth_option                       = 0,
/

&physics
 mp_physics                          = 6,
 ra_lw_physics                       = 1,
 ra_sw_physics                       = 2,
 radt                                = 10,
 sf_sfclay_physics                   = 1,
 sf_surface_physics                  = 1,
 bl_pbl_physics                      = 5,
 bldt                                = 0,
 cu_physics                          = 1,
 cudt                                = 5,
 isfflx                              = 1,
 isftcflx                            = 2, 
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = 4,
 sf_urban_physics                    = 0,
/

&fdda
 /

&dynamics
 w_damping                           = 0,
 diff_opt                            = 1,
 km_opt                              = 4,
 diff_6th_opt                        = 0, 
 diff_6th_factor                     = 0.12,
 base_temp                           = 290.
 damp_opt                            = 0,
 zdamp                               = 5000., 
 dampcoef                            = 0.2,
 khdif                               = 0,
 kvdif                               = 0,
 non_hydrostatic                     = .true.,
 moist_adv_opt                       = 1,    
 scalar_adv_opt                      = 1,    
 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true.,
 nested                              = .false., 
 /

&grib2
 /

&namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /

EOF

if (${real} == on) then
${WRFDIR}/real.exe
endif


##### making initial data directory #####
if(! -d ${WORKDIR}/wrfdir/${mmm})then
mkdir ${WORKDIR}/wrfdir/${mmm}
endif

mv ${WORKDIR}/wrfdir/wrfinput* ${WORKDIR}/wrfdir/${mmm}/
mv ${WORKDIR}/wrfdir/wrfbdy* ${WORKDIR}/wrfdir/${mmm}/
mv ${WORKDIR}/wrfdir/namelist* ${WORKDIR}/wrfdir/${mmm}/


@ mem++
end 

##### initial data moving to calculate directory #####

mkdir ${WORKDIR}/${stayear}${stamonth}${staday}
mkdir ~/mnt/mnt_la/model/WRFv3.6.1/rundir/PALI-v2/${stayear}${stamonth}${staday}
mv ${WORKDIR}/wrfdir/c00 ${WORKDIR}/${stayear}${stamonth}${staday}/
mv ${WORKDIR}/wrfdir/p?? ${WORKDIR}/${stayear}${stamonth}${staday}/
mv ${WORKDIR}/${stayear}${stamonth}${staday}/c00 ~/mnt/mnt_la/model/WRFv3.6.1/rundir/PALI-v2/${stayear}${stamonth}${staday}/
mv ${WORKDIR}/${stayear}${stamonth}${staday}/p?? ~/mnt/mnt_la/model/WRFv3.6.1/rundir/PALI-v2/${stayear}${stamonth}${staday}/



echo 'shell scprit finished'



