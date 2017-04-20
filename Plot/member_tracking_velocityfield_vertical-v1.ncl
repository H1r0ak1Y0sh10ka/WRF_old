
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Volumes/HDD01/research/ncl/wrf/radialAvg.ncl"
begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;  a = addfile("~/model/ensemble-v2/20160106/c00/wrfout_d01_2016-01-10_00:00:00.nc","r")

;********** control part **********
  plo=1 ; plot is 1, not is 0

   WORK = "/Volumes/RAID01"
  ;trackdata = "/Volumes/HDD01/reseach/ncl/wrf/track/PALI_"+init+"_"+member(mem)+"-track_v24.csv"
   dirc = WORK+ "/research/DATA/WRF/PALI-v2/"


 ; init = (/"20160106","20160106-p01deg","20160106-p02deg","20160106-p03deg","20160106-p04deg","20160106-p05deg","20160106-p06deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p10deg","20160106-p20deg"/)
   init = (/"20160106"/)

  n_init = dimsizes(init)
  member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
  n_member = dimsizes(member)

  n_skiptime = 6
  n_grid = 41
  r_grid = floattointeger((n_grid-1)*0.5)

  radius_km      = 200 ; kilometer
  n_radius       = 25  ; number of grids
  n_angle_division = 36  ; number
 ;angle_deltadeg = 45.0 ; degree 
  dis = 10000   ; meter
  
; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "eps"
 type = "png"

;*************************************************************************************

  do nnn = 0,n_init-1

  dirw = dirc + init(nnn) + "/???/"    ; input directory
  cccc = dirc + init(nnn) + "/c00/"    ; input directory

  wrflist = systemfunc("basename " + cccc +"wrfout*")
  listnum = stringtointeger(systemfunc("ls -l " + cccc +"wrfout* | wc -l"))
;  print(wrflist)

  do mmm = 0, 0;n_member-1
    if(plo.eq.1)then
     trackdata = "/Volumes/HDD01/research/ncl/wrf/track/PALI_"+init(nnn)+"_"+member(mmm)+"-track_v25.csv"
    print("Track data is "+trackdata+".")
;---Read in file as array of strings so we can parse each line
  lines  = asciiread(trackdata,-1,"string")
  nlines = dimsizes(lines)   ; First line is not a header
;---This file has quotes around everything, which we don't want.
  dq    = str_get_dq()
  lines = str_sub_str(lines,dq,"")   ; Replace quotes with empty string
;---First line is name of each field
  delim       = ","
  field_names = str_split(lines(0),delim)
  nfields     = dimsizes(field_names)
;---We're going to read the whole file as a 2D array of strings
  fields = new((/nfields,nlines/),string)
  if(mmm.eq.0)then
  c_ilat  = new ( (/n_member,nlines/),"integer")
  c_ilon  = new ( (/n_member,nlines/),"integer")
  c_lat  = new ( (/n_member,nlines/),"float")
  c_lon  = new ( (/n_member,nlines/),"float")
  end if
;---Remember that fields start at 1, not 0.
  do nf=0,nfields-1
    fields(nf,:) = str_get_field(lines,nf+1,delim)    
    c_ilat(mmm,:) = stringtointeger(fields(2,:))
    c_lat(mmm,:)  = stringtofloat(fields(4,:))
    c_ilon(mmm,:) = stringtointeger(fields(3,:))
    c_lon(mmm,:)  = stringtofloat(fields(5,:))
  end do
    end if

  filw = systemfunc("ls " + dirc + init(nnn) + "/" + member(mmm) + "/wrfout*")  ; or WRF_*grb
  f    = addfiles (filw+".nc", "r")   ; note the "s" of addfile
  ListSetType (f, "join")

  dlat = wrf_user_getvar(f[0],"lat",0)  ; get all times in the file
  dlon = wrf_user_getvar(f[0],"lon",0)  ; get all times in the file
  lat  = dlat(:,0)
  lon  = dlon(0,:)
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)
  sigma= f[0]->ZNU(0,:)
  nz   = dimsizes(sigma)

  z_top = 10000
  n_zlevs = 51
  zlevs = fspan(0,z_top,n_zlevs)
  zlevs!0 = "lev"

  dx = f[0]@DX
  dy = f[0]@DY
  ff  = new ( (/nlat,nlon/),"float")
  ff(:,:)    = f[0]->F(0,:,:)
  
  n_timestep=0
  do iii = 0,listnum-1,1
  dtimes = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(dtimes) ; number of times in the file 
  n_timestep=n_timestep+n_times
  end do ; iii loop

  times   = new ( (/n_timestep/),"string")
  uu      = new ( (/n_timestep,nz,nlat,nlon/),"float")
  vv      = new ( (/n_timestep,nz,nlat,nlon/),"float")
  zz      = new ( (/n_timestep,nz,nlat,nlon/),"float")
  vtheta  = new ( (/n_timestep,nz,nlat,nlon/),"float")
  vr      = new ( (/n_timestep,nz,nlat,nlon/),"float")

  u_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  v_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  vtheta_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  vr_levs = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")

  c_ttt=0

  do iii =0,1;listnum-1,1
  print("Now reading file is "+filw(iii))

  timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(timesd) ; number of times in the file 

    do it = 0,n_times-1
     times(c_ttt)     = timesd(it)                             ; get all times in the file
     uu(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"ua",it)        ; u averaged to mass points
     vv(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"va",it)        ; v averaged to mass points
     zz(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"z",it)         ; z on mass points

     vComps = calcWindComponents(uu(c_ttt,:,:,:),vv(c_ttt,:,:,:),lat,lon,c_lat(mmm,c_ttt),c_lon(mmm,c_ttt))
     vr(c_ttt,:,:,:) = vComps[0]
     vtheta(c_ttt,:,:,:) = vComps[1]
     delete(vComps)

     do iz = 0, n_zlevs-1,1
     vtheta_levs(c_ttt,iz,:,:)   = wrf_user_intrp3d(vtheta(c_ttt,:,:,:),zz(c_ttt,:,:,:),"h", zlevs(iz) ,0.,False)
     vr_levs(c_ttt,iz,:,:)       = wrf_user_intrp3d(vr(c_ttt,:,:,:),zz(c_ttt,:,:,:),"h", zlevs(iz) ,0.,False)
     end do  ;;; iz loop

     c_ttt=c_ttt+1

    end do ;;;it loop

  end do ; iii loop


;;;;;; ento zahyo junbi ;;;;;;;;

    angle_div_deg=360.0/int2flt(n_angle_division)
    angle_phi=new ( (/n_angle_division/),"float")
    pi = 4.0*atan(1.0) 

    angle_phi=new ( (/n_angle_division/),"float")
    Cylind_x=new( (/n_radius+1,n_angle_division/),"float")  ;Cylindrical coordinate
    Cylind_y=new( (/n_radius+1,n_angle_division/),"float")  ;Cylindrical coordinate

    vtheta_cyclind=new( (/n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 
    vr_yclind=new( (/n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 

    do na = 0,n_angle_division-1
    Angle=angle_div_deg*int2flt(na)
    angle_phi(na)=pi*(Angle/180.0)
    end do

exit

end








