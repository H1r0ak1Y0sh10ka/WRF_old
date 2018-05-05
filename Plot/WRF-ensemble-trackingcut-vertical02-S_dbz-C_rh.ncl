
; Example of using panels with WRF data

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
  OUT_DIRC   = "/Volumes/HDD01/research/ncl/draw/S_dbz-C_rh/"+TY_NAME+"/"

  INIT = (/"20160106"/)     ; initial time/date
   
  MEMBER = (/"c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)

  N_SKIPTIME     = 12       ; number of skip time  

  RADIUS_KM      = 200      ; kilometer
  N_RADIUS       = 25       ; number of grids
  N_ANGLE        = 36       ; number of angle
  DIS            = 10000    ; meter
  ZTOP           = 20000    ; meter
  N_ZLEVS        = 101      ; number of vertical

  TYPE = "png"  ;  TYPE = "eps"  ;  TYPE = "x11"

;********** Part - Calculate dimensions and Define directory from constant (do NOT change!!!) **********
 
  n_INIT   = dimsizes(INIT)
  n_MEMBER = dimsizes(MEMBER)
  zlevs    = fspan(0,ZTOP,N_ZLEVS)
  zlevs!0  = "lev"
  makedir(OUT_DIRC)

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
    if(mmm.eq.0)then
    c_ilat  = new ( (/n_MEMBER,nlines/),"integer")
    c_ilon  = new ( (/n_MEMBER,nlines/),"integer")
    c_lat  = new ( (/n_MEMBER,nlines/),"float")
    c_lon  = new ( (/n_MEMBER,nlines/),"float")
    end if

;---ReMEMBER that fields start at 1, not 0.
      do nf=0,nfields-1
      fields(nf,:) = str_get_field(lines,nf+1,delim)    
      c_ilat(mmm,:) = stringtointeger(fields(2,:))
      c_lat(mmm,:)  = stringtofloat(fields(4,:))
      c_ilon(mmm,:) = stringtointeger(fields(3,:))
      c_lon(mmm,:)  = stringtofloat(fields(5,:))
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
    dbz        = new ( (/nz,nlat,nlon/),"float")
    zz         = new ( (/nz,nlat,nlon/),"float")
    rh         = new ( (/nz,nlat,nlon/),"float")

    dbz_levs   = new ( (/N_ZLEVS,nlat,nlon/),"float")
    rh_levs    = new ( (/N_ZLEVS,nlat,nlon/),"float")
    dbz_cyclind= new ( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    rh_cyclind = new ( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 

    c_ttt=0

      do iii =0,listnum-1,1
    
      print("Now reading file is "+filw(iii))

      timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
      n_times = count_unique_values(timesd) ; number of times in the file 

        do it = 0,n_times-1, N_SKIPTIME
        times(c_ttt) = timesd(it)                             ; get all times in the file
        dbz(:,:,:)   = wrf_user_getvar(f[iii],"dbz",it)       ; dbz
        rh(:,:,:)    = wrf_user_getvar(f[iii],"rh",it)        ; rh
        zz(:,:,:)    = wrf_user_getvar(f[iii],"z",it)         ; z on mass points
      
        dbz_levs(:,:,:) = wrf_user_intrp3d(dbz(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
        rh_levs(:,:,:)  = wrf_user_intrp3d(rh(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
 
        dammy = rectangular2polar(dbz_levs(:,:,:),N_RADIUS,N_ANGLE,c_ilat(mmm,c_ttt),c_ilon(mmm,c_ttt))
        dbz_cyclind(mmm,c_ttt,:,:,:) = dammy[0]
        delete(dammy)
        dammy = rectangular2polar(rh_levs(:,:,:),N_RADIUS,N_ANGLE,c_ilat(mmm,c_ttt),c_ilon(mmm,c_ttt))
        rh_cyclind(mmm,c_ttt,:,:,:) = dammy[0]
        delete(dammy)

        print("Now drawing time is "+times(c_ttt))
;************************************************
; create plot
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

        wks01 = gsn_open_wks(TYPE,OUT_DIRC + "/WRF-trackingcut-vertical02-S_dbz-C_rh-v1-" + TY_NAME + "-" + INIT(nnn) + "-" + MEMBER(mmm) + "-" + ft_time + "-" + times(c_ttt))

        res = True
        res@gsnDraw             = False
        res@gsnFrame            = False
        res@gsnMaximize         = True
        res@vpWidthF            = 0.80
        res@vpHeightF           = 0.60
        res@gsnLeftString       = ft_time + ", " + times(c_ttt)
        res@gsnRightString      = "Mem; " + MEMBER(mmm)

       ;X_LABEL = (fspan( 0,((DIS*0.001)*N_RADIUS),N_RADIUS+1))
        Y_LABEL =  zlevs*0.001 

        res@tiXAxisString       = "Radius from the centre (km)"  
        res@tmXBMode            = "Explicit"
        res@tmXBValues          = ispan(0,N_RADIUS,5)
        res@tmXBLabels          = tostring(ispan(0,N_RADIUS,5)*10)
        res@tmXBLabelFontHeightF= 0.02

        res@tiYAxisString       = "Height(km)"  
        res@tmYLMode            = "Explicit"
        res@tmYLValues          = ispan(0,N_ZLEVS-1,10)
        res@tmYLLabels          = Y_LABEL(ispan(0,N_ZLEVS-1,10))
        res@tmYLLabelFontHeightF= 0.02

        dammy=Config_dbz_shade(res)
        shade01_opts = dammy[0]
        delete(dammy)

        dammy=Config_rh_contour(res)
        contour01_opts = dammy[0]
        delete(dammy)

        shade01_data  = dim_avg_n(dbz_cyclind(mmm,c_ttt,:,:,:),2)
        contour01_data = dim_avg_n(rh_cyclind(mmm,c_ttt,:,:,:),2)

        plots         = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
        plots_contour = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
        overlay(plots,plots_contour)
        draw(plots)
        frame(wks01)

        c_ttt = c_ttt + N_SKIPTIME
  
        end do ;;;it loop
      end do ; iii loop

    delete(timesd)
 
    end do ; mmm loop
  end do ; nnn loop



exit

end




