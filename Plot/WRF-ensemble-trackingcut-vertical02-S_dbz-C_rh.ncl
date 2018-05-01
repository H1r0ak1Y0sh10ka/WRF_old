
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "./radialAvg.ncl"
load "./Tools.ncl"
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

    dbz_levs   = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")
    rh_levs    = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")

    if(mmm.eq.0)then
;;;;;; ento zahyo junbi ;;;;;;;;

    angle_div_deg = 360.0/int2flt(N_ANGLE)
    angle_phi     = new ( (/N_ANGLE/),"float")
    pi            = 4.0*atan(1.0) 

    angle_phi=new ( (/N_ANGLE/),"float")
    Cylind_x=new( (/N_RADIUS+1,N_ANGLE/),"float")  ;Cylindrical coordinate
    Cylind_y=new( (/N_RADIUS+1,N_ANGLE/),"float")  ;Cylindrical coordinate

    dbz_cyclind     =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    rh_cyclind     =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 

      do na = 0,N_ANGLE-1
      Angle=angle_div_deg*int2flt(na)
      angle_phi(na)=pi*(Angle/180.0)
      end do
;;;;;;;;;;;;;;;;;;;;;;;;
    end if

    c_ttt=0

      do iii =0,listnum-1,1
    
      print("Now reading file is "+filw(iii))

      timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
      n_times = count_unique_values(timesd) ; number of times in the file 

        do it = 0,n_times-1, N_SKIPTIME
        times(c_ttt) = timesd(it)                             ; get all times in the file
        dbz(:,:,:)   = wrf_user_getvar(f[iii],"dbz",it)        ; dbz
        rh(:,:,:)    = wrf_user_getvar(f[iii],"rh",it)        ; rh
        zz(:,:,:)    = wrf_user_getvar(f[iii],"z",it)         ; z on mass points
      
        dbz_levs(c_ttt,:,:,:) = wrf_user_intrp3d(dbz(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
        rh_levs(c_ttt,:,:,:)  = wrf_user_intrp3d(rh(:,:,:),zz(:,:,:),"h", zlevs,0.,False)

          do nr = 0,N_RADIUS,1
            do na = 0,N_ANGLE-1

            Cylind_x(nr,na)=c_ilon(mmm,c_ttt)+ nr*cos(angle_phi(na))
            Cylind_y(nr,na)=c_ilat(mmm,c_ttt)+ nr*sin(angle_phi(na))
  
            X1=floattointeger(Cylind_x(nr,na))
            X2=X1+1
            Y1=floattointeger(Cylind_y(nr,na))
            Y2=Y1+1
            DX=abs(Cylind_x(nr,na)-X1)
            DY=abs(Cylind_y(nr,na)-Y1)

            if(X1.ge.0.and.X1.le.(nlon-1).and.X2.ge.0.and.X2.le.(nlon-1).and.Y1.ge.0.and.Y1.le.(nlat-1).and.Y1.ge.0.and.Y2.le.(nlat-1))then
            dbz_cyclind(mmm,c_ttt,:,nr,na)  = (1-DX)*( (1-DY)*dbz_levs(c_ttt,:,Y1,X1) + DY*dbz_levs(c_ttt,:,Y2,X1) )   \
                                          + DX*((1-DY)*dbz_levs(c_ttt,:,Y1,X2) + DY*dbz_levs(c_ttt,:,Y2,X2) )
            rh_cyclind(mmm,c_ttt,:,nr,na)   = (1-DX)*( (1-DY)*rh_levs(c_ttt,:,Y1,X1) + DY*rh_levs(c_ttt,:,Y2,X1) )   \
                                          + DX*((1-DY)*rh_levs(c_ttt,:,Y1,X2) + DY*rh_levs(c_ttt,:,Y2,X2) )
            else
            dbz_cyclind(mmm,c_ttt,:,nr,na) = dbz_cyclind@_FillValue
            rh_cyclind(mmm,c_ttt,:,nr,na)  = rh_cyclind@_FillValue
            end if
    
            end do ; na loop
          end do ; nr loop

  print("Now drawing time is "+times(c_ttt))
;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(TYPE,OUT_DIRC+"/WRF-S_dbz-C_rh-vertical02-v1_"+TY_NAME+"_"+INIT(nnn)+"_"+MEMBER(mmm)+"-trackingcut_"+times(c_ttt))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@vpWidthF            = 0.60
  res@vpHeightF           = 0.60
  res@gsnLeftString       = times(c_ttt)

  if(c_ttt.lt.10)then
  res@gsnRightString   = "f00"+c_ttt
  else if (c_ttt.ge.10.and.c_ttt.lt.100)then
  res@gsnRightString   = "f0"+c_ttt
  else if (c_ttt.ge.100)then
  res@gsnRightString   = "f"+c_ttt
  end if 
  end if
  end if

  X_LABEL = (fspan( 0,((DIS*0.001)*N_RADIUS),N_RADIUS+1))
  Y_LABEL =  zlevs*0.001 

  res@tiXAxisString        = "Radius from the centre (km)"  
  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,N_RADIUS,5)
  res@tmXBLabels = tostring(ispan(0,N_RADIUS,5)*10)

  res@tiYAxisString        = "Height(km)"  
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0,N_ZLEVS-1,10)
  res@tmYLLabels = Y_LABEL(ispan(0,N_ZLEVS-1,10))
  res@tmYLLabelFontHeightF = 0.02

  shade01_opts = True 
  shade01_opts = res

  shade01_opts@cnFillOn             = True                   ; turn on color
  shade01_opts@lbLabelAutoStride    = True                   ; nice label bar labels
  shade01_opts@cnLinesOn            = False                  ; no contour lines

  shade01_opts@lbOrientation        = "vertical"
  shade01_opts@lbTitlePosition      = "Right"                           ; title location
  shade01_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade01_opts@lbTitleAngleF        = 90.                               ; title angle
  shade01_opts@lbTitleFontHeightF   = 0.015                              ; font height

  shade01_opts@cnFillPalette         = "prcp_1"
  shade01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade01_opts@cnMinLevelValF       =       5              ; set min contour level
  shade01_opts@cnMaxLevelValF       =      55              ; set max contour level
  shade01_opts@cnLevelSpacingF      =       5              ; set contour spacing

  shade01_data  = dim_avg_n(dbz_cyclind(mmm,c_ttt,:,:,:),2)

  contour01_opts = True 
  contour01_opts = res

  contour01_opts@cnLineColor           = "green"   ; Set the line color
  contour01_opts@cnInfoLabelOn         = False  
  contour01_opts@cnLineThicknessF      =  12
  contour01_opts@gsnContourNegLineDashPattern  = 1 	; sets negative contours to dash pattern 1
  contour01_opts@cnLineLabelInterval           = 1             ; default = 2
  contour01_opts@cnLineLabelFontHeightF        = 0.025

  contour01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  contour01_opts@cnMinLevelValF       =      10                ; set min contour level
  contour01_opts@cnMaxLevelValF       =      90                ; set max contour level
  contour01_opts@cnLevelSpacingF      =      10                ; set contour spacing

   contour01_data = dim_avg_n(rh_cyclind(mmm,c_ttt,:,:,:),2) 

   plots         = gsn_csm_contour(wks01, shade01_data   ,shade01_opts)
   plots_contour = gsn_csm_contour(wks01, contour01_data ,contour01_opts)
   overlay(plots,plots_contour)


  draw(plots)
  frame(wks01)  

  c_ttt=c_ttt+ N_SKIPTIME
  
    end do ;;;it loop

  end do ; iii loop

  delete(timesd)


exit

   
end do ; mmm loop
end do ; nnn loop



exit

end




