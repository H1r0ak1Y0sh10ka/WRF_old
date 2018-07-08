; This file is Analysis and Draw program.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; 15/05/2018 - 1st released
;
; This script calcurate relative vorticity for hovmueller diagram with tangential wind.
; WRF experimental result and track data are required.
; Please rewrite only the argument of "Part - Enter Constant, Directory, NAME and so on" as necessary.
;
;=====================================================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "./radialAvg.ncl"
load "./AnalysisTyphoonTools.ncl"
load "./Tools.ncl"
load "./DrawConfiguration.ncl"
begin

;********** Part - Enter Constant, Directory, NAME and so on **********

  TY_NAME = "PALI"          ; case name

  WRF_DIRC   = "/Volumes/RAID01/research/DATA/WRF/PALI-v2/"    ; WRF_DIRC = "/Volumes/Yoshi-HDD01"
  TRACK_DIRC = "/Volumes/HDD01/research/ncl/wrf/track/"
  TRACK_VER  = "v25"
  OUT_DIRC   =  "~/Dropbox/research/ncl/draw/S_qvaporflux-C_rh/"+TY_NAME+"/"

  OUTNAME_PREFIX = "WRF-trackingcut-hovumueller-S_qvaporflux-C_rh-v1-"

  INIT = stringtointeger(systemfunc("read ifland; echo $ifland")) ;(/"20160103"/)     ; initial time/date
   
  MEMBER        = (/"p09", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "c00", "p10" /)
  SWITCH_MEAN   = (systemfunc("read ifland; echo $ifland"))       ; ON is draw, OFF is not.

  N_SKIPTIME    = stringtointeger(systemfunc("read ifland; echo $ifland"))       ; number of skip time  

  N_RADIUS      = 25       ; number of grids
  N_ANGLE       = 36       ; number of angle
  DIS           = 10000    ; model resolution (meter)
  TOP           = 6000
  BOT           = 0

  TYPE = "png"  ;  TYPE = "eps"  ;  TYPE = "x11"

;********** Part - Calculate dimensions and Define directory from constant (do NOT change!!!) **********
 
  n_INIT   = dimsizes(INIT)
  n_MEMBER = dimsizes(MEMBER)
  n_zlevs  = ((TOP-BOT)/1000)+1
  zlevs    = fspan(BOT,TOP,n_zlevs)
  zlevs!0 = "lev"
  makedir(OUT_DIRC)
  SWITCH_MEAN   = str_upper(SWITCH_MEAN)

;*************************************************************************************

  do nnn = 0,n_INIT-1

  dirw = WRF_DIRC + INIT(nnn) + "/???/"    ; input directory
  cccc = WRF_DIRC + INIT(nnn) + "/c00/"    ; input directory
  wrflist = systemfunc("basename " + cccc +"wrfout*")
  listnum = stringtointeger(systemfunc("ls -l " + cccc +"wrfout* | wc -l"))

    do mmm = 0, n_MEMBER-1,1

    trackdata = TRACK_DIRC+"/PALI_"+INIT(nnn)+"_"+MEMBER(mmm)+"-track_v25.csv"
    print("Track data is "+trackdata)

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
    c_ilat = new ( (/nlines/),"integer")
    c_ilon = new ( (/nlines/),"integer")
    c_lat  = new ( (/nlines/),"float")
    c_lon  = new ( (/nlines/),"float")
;---ReMEMBER that fields start at 1, not 0.
      do nf=0,nfields-1
      fields(nf,:) = str_get_field(lines,nf+1,delim)    
      c_ilat(:) = stringtointeger(fields(2,:))
      c_lat(:)  = stringtofloat(fields(4,:))
      c_ilon(:) = stringtointeger(fields(3,:))
      c_lon(:)  = stringtofloat(fields(5,:))
      end do

    filw = systemfunc("ls " + WRF_DIRC + INIT(nnn) + "/" + MEMBER(mmm) + "/wrfout*")  ; or WRF_*grb
    f    = addfiles (filw+".nc", "r")   ; note the "s" of addfile
    ListSetType (f, "join")

    dlat    = wrf_user_getvar(f[0],"lat",0)  ; get all times in the file
    dlon    = wrf_user_getvar(f[0],"lon",0)  ; get all times in the file
    lat     = dlat(:,0)
    lon     = dlon(0,:)
    nlat    = dimsizes(lat)
    nlon    = dimsizes(lon)
    sigma   = f[0]->ZNU(0,:)
    nz      = dimsizes(sigma)
    dx      = f[0]@DX
    dy      = f[0]@DY
  
    n_timestep=0

      do iii = 0,listnum-1,1
      dtimes = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
      n_times = count_unique_values(dtimes) ; number of times in the file 
      n_timestep=n_timestep+n_times
      end do ; iii loop

    times      = new ( (/n_timestep/),"string")
    zz         = new ( (/nz,nlat,nlon/),"float")
    uu         = new ( (/nz,nlat,nlon/),"float")
    vv         = new ( (/nz,nlat,nlon/),"float")
    rh         = new ( (/nz,nlat,nlon/),"float")
    qvapor     = new ( (/nz,nlat,nlon/),"float")
    qvaporflux = new ( (/nz,nlat,nlon/),"float")

    qvaporflux_levs = new ( (/n_zlevs,nlat,nlon/),"float")
    rh_levs         = new ( (/n_zlevs,nlat,nlon/),"float")
    if(isdefined("h_diabatic_cyclind").eq.False)then
    qvaporflux_cyclind = new ( (/n_MEMBER,n_timestep,n_zlevs,N_RADIUS+1,N_ANGLE/),"float") 
    rh_cyclind         = new ( (/n_MEMBER,n_timestep,n_zlevs,N_RADIUS+1,N_ANGLE/),"float") 
    end if

    c_ttt=0

      do iii =0,listnum-1,1
    
      print("Now reading file is "+filw(iii))

      timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
      n_times = count_unique_values(timesd) ; number of times in the file 

        do it = 0,n_times-1, N_SKIPTIME
        times(c_ttt) = timesd(it)                             ; get all times in the file
        zz(:,:,:)    = wrf_user_getvar(f[iii],"z",it)         ; z on mass points
        dammy = f[iii]->QVAPOR
        qvapor(:,:,:) = dammy(it,:,:,:)*1000
        delete(dammy)

        uu(:,:,:)    = wrf_user_getvar(f[iii],"ua",it)         ; u on mass points
        vv(:,:,:)    = wrf_user_getvar(f[iii],"va",it)         ; v on mass points
        qvaporflux(:,:,:)    = uv2vr_cfd (uu*qvapor,vv*qvapor,lat,lon, 3)
        qvaporflux_levs(:,:,:) = wrf_user_intrp3d(qvaporflux(:,:,:),zz(:,:,:),"h", zlevs,0.,False)

        rh(:,:,:)    = wrf_user_getvar(f[iii],"rh",it)         ; rh on mass points
        rh_levs(:,:,:) = wrf_user_intrp3d(rh(:,:,:),zz(:,:,:),"h", zlevs,0.,False)

        dammy = rectangular2polar(qvaporflux_levs(:,:,:),N_RADIUS,N_ANGLE,c_ilat(c_ttt),c_ilon(c_ttt))
        qvaporflux_cyclind(mmm,c_ttt,:,:,:) = dammy[0]
        delete(dammy)
        dammy = rectangular2polar(rh_levs(:,:,:),N_RADIUS,N_ANGLE,c_ilat(c_ttt),c_ilon(c_ttt))
        rh_cyclind(mmm,c_ttt,:,:,:) = dammy[0]
        delete(dammy)
        
        c_ttt = c_ttt + N_SKIPTIME

        end do ;;;it loop
      end do ; iii loop

      print("Now drawing time is ")
;************************************************
; create plot of EACH MEMBER
;************************************************
; Set some basic resources

      wks01 = gsn_open_wks(TYPE,OUT_DIRC + "/" + OUTNAME_PREFIX + TY_NAME + "-" + INIT(nnn) + "-" + MEMBER(mmm))

      res_title = True
      res_title@gsnLeftString       = "Case; "+ TY_NAME + "~C~Init; " + times(0)
      res_title@gsnRightString      = "Mem; " + MEMBER(mmm)

      res_basis = True
      res_basis@gsnDraw             = False
      res_basis@gsnFrame            = False
      res_basis@gsnMaximize         = True
      res_basis@vpWidthF            = 0.50
      res_basis@vpHeightF           = 0.75
      res_basis@vpXF                = 0.2
      res_basis@vpYF                = 0.9

      res_basis@tiXAxisString       = "Radius from the centre (km)" 
      res_basis@tiXAxisFontHeightF  = 0.025                             ; default 
      res_basis@tmXBMode            = "Explicit"
      res_basis@tmXBValues          = ispan(0,N_RADIUS,5)
      res_basis@tmXBLabels          = tostring(ispan(0,N_RADIUS,5)*10)
      res_basis@tmXBLabelFontHeightF= 0.03

      res_basis@tiYAxisString       = "Forecast time(hour)" 
      res_basis@tiYAxisFontHeightF  = 0.025                             ; default 
      res_basis@tmYLMode            = "Manual"
      res_basis@tmYLTickStartF      = 0
      res_basis@tmYLTickSpacingF    = 24
      res_basis@tmYLTickEndF        = c_ttt-N_SKIPTIME
      res_basis@tmYLLabelFontHeightF= 0.03;

      res = True
      res = res_basis
      res = res_title

      shade01_opts = True
      shade01_opts = res
      Config_qvaporflux_shade(shade01_opts)

      contour01_opts = True
      contour01_opts = res
      Config_rh_contour(contour01_opts)

      dammy          = dim_avg_n(qvaporflux_cyclind(mmm,:,:,:,:),3)
      shade01_data   = dim_avg_n(dammy,1)
      delete(dammy)
      shade01_data   = linmsg_n(shade01_data,0,0)
      dammy          = dim_avg_n(rh_cyclind(mmm,:,:,:,:),3)
      contour01_data = dim_avg_n(dammy,1)
      delete(dammy)
      contour01_data = linmsg_n(contour01_data,0,0)

      plots          = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
      plots_contour  = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
      overlay(plots,plots_contour)

      draw(plots)
      frame(wks01)

      delete(timesd)
    delete(shade01_data)
    delete(contour01_data)

    end do ; mmm loop
exit
  if(SWITCH_MEAN .eq."ON") then
  print("Now start to drawing ENSEMBLE MEAN.")  

;************************************************
; create plot of ENSEMBLE MEAN and SPREAD
;************************************************

; Set some basic resources

    wks01 = gsn_open_wks(TYPE,OUT_DIRC + "/" + OUTNAME_PREFIX + TY_NAME + "-" + INIT(nnn) + "-mean-" + (ZLEVS)+"m")
    wks02 = gsn_open_wks(TYPE,OUT_DIRC + "/" + OUTNAME_PREFIX + TY_NAME + "-" + INIT(nnn) + "-sprd-" + (ZLEVS)+"m")

    res_title = True
    res_title@gsnLeftString       = "Case; "+ TY_NAME + " Height; " + ZLEVS*0.001 + "km ~C~Init; " + times(0)
    res_title@gsnRightString      = "Mem; Mean"
       
    res = res_basis
    res = res_title

    shade01_opts = True
    shade01_opts = res
    Config_rv_shade(shade01_opts)

    contour01_opts = True
    contour01_opts = res
    Config_vt_kyodo_contour(contour01_opts)

    rv_azimuth_mean = dim_avg(rv_cyclind(:,:,0,:,:))
    shade01_data    = dim_avg_n(linmsg_n(rv_azimuth_mean,0,1),0)
    vt_azimuth_mean = dim_avg(vt_cyclind(:,:,0,:,:))
    coutour01_data  = dim_avg_n(linmsg_n(vt_azimuth_mean,0,1),0) 
    plots           = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
    plots_contour   = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
    overlay(plots,plots_contour)

    vt_max_r   = new (n_timestep,"integer") 
       do it =0,c_ttt-N_SKIPTIME
       vt_max_r(it) = maxind (contour01_data(it,:))    
       end do

    plres = True
    plres@gsLineColor               = "grey"   ; Set the line color.
    plres@gsLineThicknessF          = 14.0
    contour_rmw = gsn_add_polyline  (wks01, plots, vt_max_r , ispan(0,c_ttt-N_SKIPTIME,1), plres)

    draw(plots)
    frame(wks01)
  
    res_title@gsnRightString      = "Mem; Sprd"
    res = res_basis
    res = res_title

    shade02_opts = True
    shade02_opts = res
    Config_rvSprd_shade(shade02_opts)
    shade02_data   = dim_stddev_n(linmsg_n(rv_azimuth_mean,0,1),0)
    plots          = gsn_csm_contour(wks02, shade02_data   ,shade02_opts)

    contour_rmw = gsn_add_polyline  (wks02, plots, vt_max_r , ispan(0,c_ttt-N_SKIPTIME,1), plres)

    draw(plots)
    frame(wks02)

  end if

  end do ; nnn loop

exit

end




