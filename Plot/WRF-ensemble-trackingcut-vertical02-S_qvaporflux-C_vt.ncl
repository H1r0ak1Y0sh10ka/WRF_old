; This file is Draw Configuration.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; 23/06/2018 - 1st released
;
; This script calcurate tangential wind and water vapor flux for vertical structure.
; WRF experimental result and track data required.
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
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

;********** Part - Enter Constant, Directory, NAME and so on **********

  TY_NAME = "PALI"          ; case name

  WRF_DIRC   = "/Volumes/RAID01/research/DATA/WRF/PALI-v2/"    ; WRF_DIRC = "/Volumes/Yoshi-HDD01"
  TRACK_DIRC = "/Volumes/HDD01/research/ncl/wrf/track/"
  TRACK_VER  = "v25"
  OUT_DIRC   =  "~/Dropbox/research/ncl/draw/S_qvaporfluxC_vt/"+TY_NAME+"/"

  OUTNAME_PREFIX = "WRF-trackingcut-vertical02-S_qvaporflux-C_vt-v1-"

  INIT = stringtointeger(systemfunc("read ifland; echo $ifland")) ;(/"20160103"/) ; initial time/date
   
  MEMBER        = (/"p09", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "c00", "p10" /)
  SWITCH_MEAN   = (systemfunc("read ifland; echo $ifland")) ;   ON is draw, OFF is not.

  N_SKIPTIME    = stringtointeger(systemfunc("read ifland; echo $ifland"))       ; number of skip time  

  RADIUS_KM     = 200      ; kilometer
  N_RADIUS      = 25       ; number of grids
  N_ANGLE       = 36       ; number of angle
  DIS           = 10000    ; meter
  ZTOP          = 20000    ; meter
  N_ZLEVS       = 101      ; number of vertical

  TYPE = "png"  ;  TYPE = "eps"  ;  TYPE = "x11"

  AVE_TIME_STA = (/48,96/)
  AVE_TIME_END = (/96,144/)

;********** Part - Calculate dimensions and Define directory from constant (do NOT change!!!) **********
 
  n_INIT   = dimsizes(INIT)
  n_MEMBER = dimsizes(MEMBER)
  zlevs    = fspan(0,ZTOP,N_ZLEVS)
  zlevs!0  = "lev"
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
    ff      = new ( (/nlat,nlon/),"float")
    ff(:,:) = f[0]->F(0,:,:)
  
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
    qvapor     = new ( (/nz,nlat,nlon/),"float")
    qvaporflux = new ( (/nz,nlat,nlon/),"float")

    qvaporflux_levs = new ( (/N_ZLEVS,nlat,nlon/),"float")
    vt_levs         = new ( (/N_ZLEVS,nlat,nlon/),"float")
    if(isdefined("h_diabatic_cyclind").eq.False)then
    qvaporflux_cyclind = new ( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    vt_cyclind         = new ( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
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
        vComps = calcWindComponents(uu,vv,lat,lon,c_lat(c_ttt),c_lon(c_ttt))
        qvaporflux(:,:,:)    = uv2vr_cfd (uu*qvapor,vv*qvapor,lat,lon, 3)

        qvaporflux_levs(:,:,:) = wrf_user_intrp3d(qvaporflux(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
        vt_levs(:,:,:)         = wrf_user_intrp3d(vComps[1],zz(:,:,:),"h", zlevs,0.,False)
        delete(vComps)

        dammy = rectangular2polar(qvaporflux_levs(:,:,:),N_RADIUS,N_ANGLE,c_ilat(c_ttt),c_ilon(c_ttt))
        qvaporflux_cyclind(mmm,c_ttt,:,:,:) = dammy[0]
        delete(dammy)
        dammy = rectangular2polar(vt_levs(:,:,:),N_RADIUS,N_ANGLE,c_ilat(c_ttt),c_ilon(c_ttt))
        vt_cyclind(mmm,c_ttt,:,:,:) = dammy[0]
        delete(dammy)
        
        print("Now drawing time is "+times(c_ttt))
;************************************************
; create plot of EACH MEMBER
;************************************************
; Set some basic resources

        if(c_ttt.lt.10)then
        ft_time = "FT00"+c_ttt
        else if (c_ttt.ge.10.and.c_ttt.lt.100)then
        ft_time   = "FT0"+c_ttt
        else if (c_ttt.ge.100)then
        ft_time   = "FT"+c_ttt
        end if 
        end if
        end if

        wks01 = gsn_open_wks(TYPE,OUT_DIRC + "/" + OUTNAME_PREFIX + TY_NAME + "-" + INIT(nnn) + "-" + MEMBER(mmm) + "-" + ft_time + "-" + times(c_ttt))

        res_title = True
        res_title@gsnLeftString       = ft_time + ", " + times(c_ttt)
        res_title@gsnRightString      = "Mem; " + MEMBER(mmm)

        res_basis = True
        res_basis@gsnDraw             = False
        res_basis@gsnFrame            = False
        res_basis@gsnMaximize         = True
        res_basis@vpWidthF            = 0.60
        res_basis@vpHeightF           = 0.60

        Y_LABEL =  zlevs*0.001 

        res_basis@tiXAxisString       = "Radius from the centre (km)"  
        res_basis@tmXBMode            = "Explicit"
        res_basis@tmXBValues          = ispan(0,N_RADIUS,5)
        res_basis@tmXBLabels          = tostring(ispan(0,N_RADIUS,5)*10)
        res_basis@tmXBLabelFontHeightF= 0.02

        res_basis@tiYAxisString       = "Height(km)"  
        res_basis@tmYLMode            = "Explicit"
        res_basis@tmYLValues          = ispan(0,N_ZLEVS-1,10)
        res_basis@tmYLLabels          = Y_LABEL(ispan(0,N_ZLEVS-1,10))
        res_basis@tmYLLabelFontHeightF= 0.02

        res = True
        res = res_basis
        res = res_title

        shade01_opts = True
        shade01_opts = res
        Config_qvaporflux_shade(shade01_opts)
        
        contour01_opts = True
        contour01_opts = res
        Config_vt_contour(contour01_opts)
        
        shade01_data   = dim_avg_n(qvaporflux_cyclind(mmm,c_ttt,:,:,:),2)
        contour01_data = dim_avg_n(vt_cyclind(mmm,c_ttt,:,:,:),2)
        plots          = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
        plots_contour  = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
        overlay(plots,plots_contour)
        draw(plots)
        frame(wks01)

        c_ttt = c_ttt + N_SKIPTIME
  
        end do ;;;it loop
      end do ; iii loop

    delete(timesd)
    delete(shade01_data)
    delete(contour01_data)

if(dimsizes(AVE_TIME_END).ne.0)then
      do iia = 0, dimsizes(AVE_TIME_END)-1,1
;************************************************
; create plot
;************************************************
; Set some basic resources
        wks01 = gsn_open_wks(TYPE,OUT_DIRC + "/" + OUTNAME_PREFIX + TY_NAME + "-" + INIT(nnn) + "-" + MEMBER(mmm) + "-" + ft_time + "-" + times(AVE_TIME_STA(iia))+"-"+times(AVE_TIME_END(iia)))

        res_title = True
        res_title@gsnLeftString            = "FT"+AVE_TIME_STA(iia)+"-FT"+AVE_TIME_END(iia)
        res_title@gsnRightString      = "Mem; " + MEMBER(mmm)

        res_basis = True
        res_basis@gsnDraw             = False
        res_basis@gsnFrame            = False
        res_basis@gsnMaximize         = True
        res_basis@vpWidthF            = 0.60
        res_basis@vpHeightF           = 0.60

        Y_LABEL =  zlevs*0.001 

        res_basis@tiXAxisString       = "Radius from the centre (km)"  
        res_basis@tmXBMode            = "Explicit"
        res_basis@tmXBValues          = ispan(0,N_RADIUS,5)
        res_basis@tmXBLabels          = tostring(ispan(0,N_RADIUS,5)*10)
        res_basis@tmXBLabelFontHeightF= 0.02

        res_basis@tiYAxisString       = "Height(km)"  
        res_basis@tmYLMode            = "Explicit"
        res_basis@tmYLValues          = ispan(0,N_ZLEVS-1,10)
        res_basis@tmYLLabels          = Y_LABEL(ispan(0,N_ZLEVS-1,10))
        res_basis@tmYLLabelFontHeightF= 0.02

        res = True
        res = res_basis
        res = res_title

        shade01_opts = True
        shade01_opts = res
        Config_qvaporflux_shade(shade01_opts)
        
        contour01_opts = True
        contour01_opts = res
        Config_vt_contour(contour01_opts)

        shade01_data   = dim_avg_n(qvaporflux_cyclind(mmm,:,:,:,:),3)
        contour01_data = dim_avg_n(vt_cyclind(mmm,:,:,:,:),3)
        plots          = gsn_csm_contour(wks01, dim_avg_n(shade01_data(AVE_TIME_STA(iia):AVE_TIME_END(iia),:,:),0)   ,shade01_opts)
        plots_contour  = gsn_csm_contour(wks01, dim_avg_n(contour01_data(AVE_TIME_STA(iia):AVE_TIME_END(iia),:,:),0) ,contour01_opts)
        overlay(plots,plots_contour)
        draw(plots)
        frame(wks01)
        delete(shade01_data)
        delete(contour01_data)
      end do ; iia loop
end if

    end do ; mmm loop
exit
  if(SWITCH_MEAN .eq."ON") then
  print("Now start to drawing ENSEMBLE MEAN.")  

;************************************************
; create plot of ENSEMBLE MEAN and SPREAD
;************************************************

    do it = 0,c_ttt-N_SKIPTIME, N_SKIPTIME

    print("Now drawing time is "+times(it))
; Set some basic resources

    if(it.lt.10)then
    ft_time = "FT00"+it
    else if (it.ge.10.and.it.lt.100)then
    ft_time   = "FT0"+it
    else if (it.ge.100)then
    ft_time   = "FT"+it
    end if 
    end if
    end if

    wks01 = gsn_open_wks(TYPE,OUT_DIRC + "/" + OUTNAME_PREFIX + TY_NAME + "-" + INIT(nnn) + "-mean-" + ft_time + "-" + times(it))
    wks02 = gsn_open_wks(TYPE,OUT_DIRC + "/" + OUTNAME_PREFIX + TY_NAME + "-" + INIT(nnn) + "-sprd-" + ft_time + "-" + times(it))

    res_title = True
    res_title@gsnLeftString       = ft_time + ", " + times(it)
    res_title@gsnRightString      = "Mem; Mean"
       
    res = res_basis
    res = res_title

    shade01_opts = True
    shade01_opts = res
    Config_qvaporflux_shade(shade01_opts)

    contour01_opts = True
    contour01_opts = res
    Config_rh_contour(contour01_opts)
       
    shade01_data   = dim_avg_n(dim_avg_n(h_diabatic_cyclind(:,it,:,:,:),3),0)
    contour01_data = dim_avg_n(dim_avg_n(vt_cyclind(:,it,:,:,:),3),0)
    plots          = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
    plots_contour  = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
    overlay(plots,plots_contour)
    draw(plots)
    frame(wks01)
  
    res_title@gsnRightString      = "Mem; Sprd"
    res = res_basis
    res = res_title

    shade02_opts = True
    shade02_opts = res
    Config_dbzSprd_shade(shade02_opts)

    dammy=(dim_avg_n(h_diabatic_cyclind(:,it,:,:,:),3))
    shade02_data   = dim_stddev_n(dammy,0)
    delete(dammy)
    plots          = gsn_csm_contour(wks02, shade02_data   ,shade02_opts)
    draw(plots)
    frame(wks02)

    end do ;;;it loop

  end if

  end do ; nnn loop

exit

end



