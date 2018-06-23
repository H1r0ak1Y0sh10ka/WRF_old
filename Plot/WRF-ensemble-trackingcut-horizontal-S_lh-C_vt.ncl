; This file is Draw Configuration.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; 23/06/2018 - 1st released
;
; This script calcurate tangential wind and latent heat for horizontal structure.
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

;********** Part - Enter Constant, Directory, NAME and so on **********

  TY_NAME = "PALI"          ; case name

  WRF_DIRC   = "/Volumes/RAID01/research/DATA/WRF/PALI-v2/"    ; WRF_DIRC = "/Volumes/Yoshi-HDD01"
  TRACK_DIRC = "/Volumes/HDD01/research/ncl/wrf/track/"
  TRACK_VER  = "v25"
 ; OUT_DIRC   =  "/Volumes/HDD01/research/ncl/draw/S_inertialstability-C_vt/"+TY_NAME+"/"
  OUT_DIRC   =  "~/Dropbox/research/ncl/draw/S_lh-C_vt/"+TY_NAME+"/"

  OUTNAME_PREFIX = "WRF-trackingcut-horizontal-S_lh-C_vt-v1-"

  INIT = stringtointeger(systemfunc("read ifland; echo $ifland"));(/"20160103"/)     ; initial time/date
   
  MEMBER        = (/"c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
  SWITCH_MEAN   = (systemfunc("read ifland; echo $ifland")) ; ON is draw, OFF is not.

  N_SKIPTIME    = stringtointeger(systemfunc("read ifland; echo $ifland"))      ; number of skip time  

  N_GRIDS       = 51       ; number of grids
  ZLEVS         = 1000     ; meter

  TYPE = "png"  ;  TYPE = "eps"  ;  TYPE = "x11"

;********** Part - Calculate dimensions and Define directory from constant (do NOT change!!!) **********
 
  n_INIT   = dimsizes(INIT)
  n_MEMBER = dimsizes(MEMBER)
  ZLEVS!0  = "lev"
  makedir(OUT_DIRC)
  SWITCH_MEAN   = str_upper(SWITCH_MEAN)
  n_rgrids = floattointeger((N_GRIDS-1)*0.5)

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
    c_ilat  = new ( (/nlines/),"integer")
    c_ilon  = new ( (/nlines/),"integer")
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
    lh         = new ( (/nlat,nlon/),"float")

    vt_lev     = new ( (/nlat,nlon/),"float")

    if(mmm.eq.0)then
    vt_grid    = new ( (/n_MEMBER,n_timestep,N_GRIDS,N_GRIDS/),"float")
    lh_grid    = new ( (/n_MEMBER,n_timestep,N_GRIDS,N_GRIDS/),"float")
    end if

    c_ttt=0

      do iii =0,listnum-1,1
    
      print("Now reading file is "+filw(iii))

      timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
      n_times = count_unique_values(timesd) ; number of times in the file 

        do it = 0,n_times-1, N_SKIPTIME
        times(c_ttt) = timesd(it)                             ; get all times in the file
        zz(:,:,:)    = wrf_user_getvar(f[iii],"z",it)         ; z on mass points
        uu(:,:,:)    = wrf_user_getvar(f[iii],"ua",it)         ; u on mass points
        vv(:,:,:)    = wrf_user_getvar(f[iii],"va",it)         ; v on mass points
        dammy = f[iii]->LH
        lh(:,:)   = dammy(it,:,:)
        delete(dammy)

        vComps = calcWindComponents(uu,vv,lat,lon,c_lat(c_ttt),c_lon(c_ttt))
        vt_lev(:,:) = wrf_user_intrp3d(vComps[1],zz(:,:,:),"h", ZLEVS, 0., False)
        delete(vComps)

        if(c_ilat(c_ttt)-n_rgrids.gt.0.and.c_ilat(c_ttt)+n_rgrids.lt.nlat.and. \
           c_ilon(c_ttt)-n_rgrids.gt.0.and.c_ilon(c_ttt)+n_rgrids.lt.nlon)then
        vt_grid(mmm,c_ttt,:,:) = vt_lev(c_ilat(c_ttt)-n_rgrids:c_ilat(c_ttt)+n_rgrids,c_ilon(c_ttt)-n_rgrids:c_ilon(c_ttt)+n_rgrids)
        lh_grid(mmm,c_ttt,:,:) = lh(c_ilat(c_ttt)-n_rgrids:c_ilat(c_ttt)+n_rgrids,c_ilon(c_ttt)-n_rgrids:c_ilon(c_ttt)+n_rgrids)

        else
        vt_grid(mmm,c_ttt,:,:) = vt_lev@_FillValue
        lh_grid(mmm,c_ttt,:,:) = lh@_FillValue
        end if 
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
        res_basis@vpWidthF            = 0.80
        res_basis@vpHeightF           = 0.80

        X_LABEL = (fspan( (-1*(dx*0.001)*n_rgrids),((dx*0.001)*n_rgrids),((N_GRIDS-1)/5)+1) )
        Y_LABEL = (fspan( (-1*(dy*0.001)*n_rgrids),((dy*0.001)*n_rgrids),((N_GRIDS-1)/5)+1) )

        res_basis@tiXAxisString       = "DX(km)" 
        res_basis@tiXAxisFontHeightF  = 0.025                             ; default 
        res_basis@tmXBMode            = "Explicit"
        res_basis@tmXBValues          = ispan(0,N_GRIDS-1,5)
        res_basis@tmXBLabels          = X_LABEL
        res_basis@tmXBLabelFontHeightF= 0.03

        res_basis@tiYAxisString       = "DY(km)"
        res_basis@tiYAxisFontHeightF  = 0.025                             ; default 
        res_basis@tmYLMode            = "Explicit"
        res_basis@tmYLValues          = ispan(0,N_GRIDS-1,5)
        res_basis@tmYLLabels          = Y_LABEL
        res_basis@tmYLLabelFontHeightF= 0.03

        res = True
        res = res_basis
        res = res_title

        shade01_opts = True
        shade01_opts = res
        Config_lh_shade(shade01_opts)

        contour01_opts = True
        contour01_opts = res
        Config_vt_contour(contour01_opts)
        
        shade01_data   = lh_grid(mmm,c_ttt,:,:)
        contour01_data = vt_grid(mmm,c_ttt,:,:)
        plots          = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
        plots_contour  = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
        overlay(plots,plots_contour)

;********************************
; plot center point
;********************************
   polyres01                   = True
   polyres01@gsMarkerIndex     = 16          ; polymarker style
   polyres01@gsMarkerSizeF     = 15.         ; polymarker size
   polyres01@gsMarkerColor     = "black"

   mark01 = gsn_add_polymarker(wks01,plots,n_rgrids,n_rgrids,polyres01)

;********************************
; plot Radius
;********************************

  resc                  = True
  resc@gsLineColor      = "black"
  resc@gsLineThicknessF = 3.5

  do ii=0,n_rgrids,5
    circle_ll(wks01,plots,n_rgrids,n_rgrids,ii,resc)
  end do

        draw(plots)
        frame(wks01)

        c_ttt = c_ttt + N_SKIPTIME
  
        end do ;;;it loop
      end do ; iii loop

    delete(timesd)

    end do ; mmm loop

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
    Config_lh_shade(shade01_opts)

    contour01_opts = True
    contour01_opts = res
    Config_vt_contour(contour01_opts)

    shade01_data   = dim_avg_n(lh_grid(:,it,:,:),0)
    contour01_data = dim_avg_n(vt_grid(:,it,:,:),0)
    plots          = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
    plots_contour  = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
    overlay(plots,plots_contour)

;********************************
; plot center point
;********************************
   polyres01                   = True
   polyres01@gsMarkerIndex     = 16          ; polymarker style
   polyres01@gsMarkerSizeF     = 15.         ; polymarker size
   polyres01@gsMarkerColor     = "black"

   mark01 = gsn_add_polymarker(wks01,plots,n_rgrids,n_rgrids,polyres01)

;********************************
; plot Radius
;********************************

  resc                  = True
  resc@gsLineColor      = "black"
  resc@gsLineThicknessF = 3.5

  do ii=0,n_rgrids,5
    circle_ll(wks01,plots,n_rgrids,n_rgrids,ii,resc)
  end do

    draw(plots)
    frame(wks01)
  
    res_title@gsnRightString      = "Mem; Sprd"
    res = res_basis
    res = res_title

    shade02_opts = True
    shade02_opts = res
    Config_lhSprd_shade(shade02_opts)
    shade02_data   = dim_stddev_n(lh_grid(:,it,:,:),0)
    plots          = gsn_csm_contour(wks02, shade02_data   ,shade02_opts)

;********************************
; plot center point
;********************************
   polyres01                   = True
   polyres01@gsMarkerIndex     = 16          ; polymarker style
   polyres01@gsMarkerSizeF     = 15.         ; polymarker size
   polyres01@gsMarkerColor     = "black"

   mark01 = gsn_add_polymarker(wks02,plots,n_rgrids,n_rgrids,polyres01)

;********************************
; plot Radius
;********************************

  resc                  = True
  resc@gsLineColor      = "black"
  resc@gsLineThicknessF = 3.5

  do ii=0,n_rgrids,5
    circle_ll(wks02,plots,n_rgrids,n_rgrids,ii,resc)
  end do

    draw(plots)
    frame(wks02)

    end do ;;;it loop

  end if

  end do ; nnn loop

exit

end






