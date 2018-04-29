
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "./radialAvg.ncl"
begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

;********** Part - Enter Constant, Directory, NAME and so on **********

   TY_NAME = "PALI"

   WORK = "/Volumes/RAID01"           ; WORK = "/Volumes/Yoshi-HDD01"

   INIT = (/"20160106"/)
   n_INIT = dimsizes(INIT)
   
   MEMBER = (/"c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)

   N_SKIPTIME = 12

   RADIUS_KM      = 200 ; kilometer
   N_RADIUS       = 25  ; number of grids
   N_ANGLE = 36  ; number
   DIS = 10000   ; meter

   ZTOP = 20000
   N_ZLEVS = 101

; We generate plots, but what kind do we prefer?
   TYPE = "png"  ;  TYPE = "eps"  ;  TYPE = "x11"

;********** Part - Calculate dimensions (do NOT change!!!) **********

   dirc = WORK+ "/research/DATA/WRF/PALI-v2/"
   n_MEMBER = dimsizes(MEMBER)
   zlevs = fspan(0,ZTOP,N_ZLEVS)
   zlevs!0 = "lev"

;*************************************************************************************

  do nnn = 0,n_INIT-1

  dirw = dirc + INIT(nnn) + "/???/"    ; input directory
  cccc = dirc + INIT(nnn) + "/c00/"    ; input directory

  wrflist = systemfunc("basename " + cccc +"wrfout*")
  listnum = stringtointeger(systemfunc("ls -l " + cccc +"wrfout* | wc -l"))

  do mmm = 0, n_MEMBER-1,1
     trackdata = "/Volumes/HDD01/research/ncl/wrf/track/PALI_"+INIT(nnn)+"_"+MEMBER(mmm)+"-track_v25.csv"
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

  filw = systemfunc("ls " + dirc + INIT(nnn) + "/" + MEMBER(mmm) + "/wrfout*")  ; or WRF_*grb
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
  uu      = new ( (/nz,nlat,nlon/),"float")
  vv      = new ( (/nz,nlat,nlon/),"float")
 ; ww      = new ( (/nz,nlat,nlon/),"float")
  zz      = new ( (/nz,nlat,nlon/),"float")
  pp      = new ( (/nz,nlat,nlon/),"float")
  tk      = new ( (/nz,nlat,nlon/),"float")

  div          = new ( (/nz,nlat,nlon/),"float")
  vt           = new ( (/nz,nlat,nlon/),"float")
  vr           = new ( (/nz,nlat,nlon/),"float")
  div_levs     = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")
  vt_levs      = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")
  vr_levs      = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")
  pp_levs      = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")
  tk_levs      = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")
  rho_levs     = new ( (/n_timestep,N_ZLEVS,nlat,nlon/),"float")

  rgas       = 287.058                        ; J/(kg-K) => m2/(s2 K)
  ;rho_levs  = p_3levs/(rgas*t_3levs)         ; density => kg/m3

    if(mmm.eq.0)then
;;;;;; ento zahyo junbi ;;;;;;;;

    angle_div_deg=360.0/int2flt(N_ANGLE)
    angle_phi=new ( (/N_ANGLE/),"float")
    pi = 4.0*atan(1.0) 

    angle_phi=new ( (/N_ANGLE/),"float")
    Cylind_x=new( (/N_RADIUS+1,N_ANGLE/),"float")  ;Cylindrical coordinate
    Cylind_y=new( (/N_RADIUS+1,N_ANGLE/),"float")  ;Cylindrical coordinate

    vt_cyclind     =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    vr_cyclind     =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    pp_cyclind     =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    ff_cyclind     =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    vg_cyclind     =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float") 
    rho_cyclind    =new( (/n_MEMBER,n_timestep,N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float")    
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
     times(c_ttt)     = timesd(it)                             ; get all times in the file
     uu(:,:,:)  = wrf_user_getvar(f[iii],"ua",it)        ; u averaged to mass points
     vv(:,:,:)  = wrf_user_getvar(f[iii],"va",it)        ; v averaged to mass points
     zz(:,:,:)  = wrf_user_getvar(f[iii],"z",it)         ; z on mass points
     pp(:,:,:)  = wrf_user_getvar(f[iii],"pressure",it)  ; pressure is our vertical coordinate
     tk(:,:,:)  = wrf_user_getvar(f[iii],"tk",it)        ; tk is our vertical coordinate

     vComps = calcWindComponents(uu(:,:,:),vv(:,:,:),lat,lon,c_lat(mmm,c_ttt),c_lon(mmm,c_ttt))
     vt(:,:,:) = vComps[1]
     vr(:,:,:) = vComps[0]
     delete(vComps)
     vt_levs(c_ttt,:,:,:)       = wrf_user_intrp3d(vt(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
     vr_levs(c_ttt,:,:,:)       = wrf_user_intrp3d(vr(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
     pp_levs(c_ttt,:,:,:)       = wrf_user_intrp3d(pp(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
     tk_levs(c_ttt,:,:,:)       = wrf_user_intrp3d(tk(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
     rho_levs(c_ttt,:,:,:)      = pp_levs(c_ttt,:,:,:)*100 /(rgas*tk_levs(c_ttt,:,:,:) )         ; density => kg/m3

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
      vt_cyclind(mmm,c_ttt,:,nr,na)  = (1-DX)*( (1-DY)*vt_levs(c_ttt,:,Y1,X1) + DY*vt_levs(c_ttt,:,Y2,X1) )   \
                                        + DX*((1-DY)*vt_levs(c_ttt,:,Y1,X2) + DY*vt_levs(c_ttt,:,Y2,X2) )
      vr_cyclind(mmm,c_ttt,:,nr,na)  = (1-DX)*( (1-DY)*vr_levs(c_ttt,:,Y1,X1) + DY*vr_levs(c_ttt,:,Y2,X1) )   \
                                        + DX*((1-DY)*vr_levs(c_ttt,:,Y1,X2) + DY*vr_levs(c_ttt,:,Y2,X2) )
      pp_cyclind(mmm,c_ttt,:,nr,na)  = (1-DX)*( (1-DY)*pp_levs(c_ttt,:,Y1,X1) + DY*pp_levs(c_ttt,:,Y2,X1) )   \
                                        + DX*((1-DY)*pp_levs(c_ttt,:,Y1,X2) + DY*pp_levs(c_ttt,:,Y2,X2) )
      rho_cyclind(mmm,c_ttt,:,nr,na) = (1-DX)*( (1-DY)*rho_levs(c_ttt,:,Y1,X1) + DY*rho_levs(c_ttt,:,Y2,X1) )   \
                                        + DX*((1-DY)*rho_levs(c_ttt,:,Y1,X2) + DY*rho_levs(c_ttt,:,Y2,X2) )
      ff_cyclind(mmm,c_ttt,:,nr,na)  = (1-DX)*( (1-DY)*ff(Y1,X1) + DY*ff(Y2,X1) )   \
                                        + DX*((1-DY)*ff(Y1,X2) + DY*ff(Y2,X2) )
    else
      vt_cyclind(mmm,c_ttt,:,nr,na)  = vt_cyclind@_FillValue
      vr_cyclind(mmm,c_ttt,:,nr,na)  = vr_cyclind@_FillValue
      pp_cyclind(mmm,c_ttt,:,nr,na)  = pp_cyclind@_FillValue
      rho_cyclind(mmm,c_ttt,:,nr,na) = rho_cyclind@_FillValue
      ff_cyclind(mmm,c_ttt,:,nr,na)  = ff_cyclind@_FillValue
    end if
    
    end do ; na loop
    end do ; nr loop

      dpdr =  new( (/N_ZLEVS,N_RADIUS+1,N_ANGLE/),"float")
      dpdr = (center_fINITe_diff_n (pp_cyclind(mmm,c_ttt,:,:,:),DIS,False,0,1))*100

    do nr=0,N_RADIUS,1
      RR = DIS*nr
    do na = 0, N_ANGLE-1
          vg_cyclind(mmm,c_ttt,:,nr,na)  =  0.5*( \
                                            -1*ff_cyclind(mmm,c_ttt,:,nr,na) *RR \
                                            +sqrt( (ff_cyclind(mmm,c_ttt,:,nr,na)*RR)^2 +(4*RR/rho_cyclind(mmm,c_ttt,:,nr,na))*dpdr(:,nr,na) )\
                                            ) 
    end do 
    end do 

  do iz = 0, N_ZLEVS-1,1
  do ir = 0, N_RADIUS,1
  do ia = 0, N_ANGLE-1
  if (isnan_ieee(vg_cyclind(mmm,c_ttt,iz,ir,ia))) then
   vg_cyclind(mmm,c_ttt,iz,ir,ia) =  default_fillvalue(TYPEof(vg_cyclind))
  end if
  end do
  end do
  end do
  


  print("Now drawing time is "+times(c_ttt))
;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(TYPE,"./WRF-typhoon30-vertical02-v1_PALI_"+INIT(nnn)+"_"+MEMBER(mmm)+"-trackingcut_"+times(c_ttt))

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
  ;shade01_opts@lbTitleString        = "Shaded,Tangential wind - Gradient wind(m/s)"

  shade01_opts@lbOrientation        = "vertical"
  shade01_opts@lbTitlePosition      = "Right"                           ; title location
  shade01_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade01_opts@lbTitleAngleF        = 90.                               ; title angle
  shade01_opts@lbTitleFontHeightF   = 0.015                              ; font height

  shade01_opts@cnFillPalette = "hotcold_18lev"
  shade01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade01_opts@cnMinLevelValF       =     -10              ; set min contour level
  shade01_opts@cnMaxLevelValF       =      10              ; set max contour level
  shade01_opts@cnLevelSpacingF      =       2              ; set contour spacing

  vg_d  = dim_avg_n(vg_cyclind(mmm,c_ttt,:,:,:),2)

  contour01_opts = True 
  contour01_opts = res

  contour01_opts@cnLineColor           = "green"   ; Set the line color
  ;contour01_opts@cnFillOn             =  True                   ; turn on color
  contour01_opts@cnInfoLabelOn         = False  
  ;contour01_opts@lbLabelAutoStride    =  True                   ; nice label bar labels
  ;contour01_opts@cnLinesOn            =  False                  ; no contour lines
  ;contour01_opts@lbTitleString        =  "Shaded,Tangential wind(m/s)"
  contour01_opts@cnLineThicknessF      =  12
  contour01_opts@gsnContourNegLineDashPattern  = 1 	; sets negative contours to dash pattern 1
  contour01_opts@cnLineLabelInterval           = 1             ; default = 2
  contour01_opts@cnLineLabelFontHeightF        = 0.025
  ;contour01_opts@cnInfoLabelSide               = "Right"
  ;contour01_opts@cnInfoLabelFontHeightF        = 0.02
  ;contour01_opts@cnInfoLabelAngleF             = 90

  contour01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  contour01_opts@cnMinLevelValF       =       5                ; set min contour level
  contour01_opts@cnMaxLevelValF       =      45                ; set max contour level
  contour01_opts@cnLevelSpacingF      =       5                ; set contour spacing

   vt_mean  = dim_avg_n(vt_cyclind(mmm,c_ttt,:,:,:),2) 

   plots         = gsn_csm_contour(wks01, (vt_mean-vg_d)  ,shade01_opts)
   plots_contour = gsn_csm_contour(wks01, vt_mean,contour01_opts)

  vector01_opts = True 
  vector01_opts = res

  vector01_opts@vcGlyphStyle           = "FillArrow"
  vector01_opts@vcFillArrowsOn           = True
  vector01_opts@vcFillArrowEdgeColor     = "black"
  vector01_opts@vcFillArrowEdgeColor     = "white"
  vector01_opts@vcLineArrowThicknessF    = 5
  vector01_opts@vcMinDistanceF           = 0.01
  vector01_opts@vcRefLengthF             = 0.06
  vector01_opts@vcRefMagnitudeF          = 7.5 
  vector01_opts@vcRefAnnoString1         = "10"
  vector01_opts@vcRefAnnoSide            = "Left"
  vector01_opts@vcRefAnnoString2On       = False
  vector01_opts@vcRefAnnoPerimOn         = False
  vector01_opts@vcRefAnnoOrthogonalPosF   =  -0.075
  vector01_opts@vcRefAnnoBackgroundColor  = "plum1"

   vr_dammy  = dim_avg_n(vr_cyclind(mmm,c_ttt,:,:,:),2)

   vr_mean  = new((/N_ZLEVS,N_RADIUS+1/),"float")  
   ww_dammy = new((/N_ZLEVS,N_RADIUS+1/),"float")  

   do nl01=0,N_ZLEVS-1,5
   do nl02=0,N_RADIUS,2
   vr_mean(nl01,nl02) = vr_dammy(nl01,nl02)
   ww_dammy(nl01,nl02)= 0
   end do
   end do

  plots_vector   = gsn_csm_vector(wks01, vr_mean, ww_dammy, vector01_opts) 
  vt_max_r = new(N_ZLEVS, "integer")
  do iz =0,N_ZLEVS-1
  vt_max_r(iz) = maxind (vt_mean(iz,:)) 
  end do

   plres = True
   plres@gsLineColor               = "black"   ; Set the line color.
   plres@gsLineThicknessF          = 14.0
   dum01 = gsn_add_polyline  (wks01, plots, vt_max_r, ispan(0,N_ZLEVS,1), plres)
   
   overlay(plots,plots_vector)
   overlay(plots,plots_contour)

draw(plots)
frame(wks01)  

     delete(vg_d)
     delete(res)

     c_ttt=c_ttt+ N_SKIPTIME
    end do ;;;it loop

  end do ; iii loop

  delete(timesd)


ave_time_sta = 12
ave_time_end = 60

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(TYPE,"./WRF-typhoon30-vertical02-v1_PALI_"+INIT(nnn)+"_"+MEMBER(mmm)+"-trackingcut_"+times(ave_time_sta)+"-"+times(ave_time_end))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@vpWidthF            = 0.60
  res@vpHeightF           = 0.60
  res@gsnLeftString       = ""

  ;if(c_ttt.lt.10)then
  ;res@gsnRightString   = "f00"+c_ttt
  ;else if (c_ttt.ge.10.and.c_ttt.lt.100)then
  ;res@gsnRightString   = "f0"+c_ttt
  ;else if (c_ttt.ge.100)then
  ;res@gsnRightString   = "f"+c_ttt
  ;end if 
  ;end if
  ;end if
  res@gsnRightString   = "f"+ave_time_sta+"-f"+ave_time_end

  X_LABEL = (fspan( 0,((DIS*0.001)*N_RADIUS),N_RADIUS+1))
  Y_LABEL =  zlevs*0.001 

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
  ;shade01_opts@lbTitleString        = "Shaded,Tangential wind - Gradient wind(m/s)"

  shade01_opts@lbOrientation        = "vertical"
  shade01_opts@lbTitlePosition      = "Right"                           ; title location
  shade01_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade01_opts@lbTitleAngleF        = 90.                               ; title angle
  shade01_opts@lbTitleFontHeightF   = 0.015                              ; font height

  shade01_opts@cnFillPalette = "hotcold_18lev"
  shade01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade01_opts@cnMinLevelValF       =     -10              ; set min contour level
  shade01_opts@cnMaxLevelValF       =      10              ; set max contour level
  shade01_opts@cnLevelSpacingF      =       2              ; set contour spacing

  contour01_opts = True 
  contour01_opts = res

  contour01_opts@cnLineColor           = "green"   ; Set the line color
  ;contour01_opts@cnFillOn             =  True                   ; turn on color
  contour01_opts@cnInfoLabelOn         = False  
  ;contour01_opts@lbLabelAutoStride    =  True                   ; nice label bar labels
  ;contour01_opts@cnLinesOn            =  False                  ; no contour lines
  ;contour01_opts@lbTitleString        =  "Shaded,Tangential wind(m/s)"
  contour01_opts@cnLineThicknessF      = 12
  contour01_opts@gsnContourNegLineDashPattern  = 1 	; sets negative contours to dash pattern 1
  contour01_opts@cnLineLabelInterval           = 1             ; default = 2
  contour01_opts@cnLineLabelFontHeightF        = 0.025
  ;contour01_opts@cnInfoLabelSide               = "Right"
  ;contour01_opts@cnInfoLabelFontHeightF        = 0.02
  ;contour01_opts@cnInfoLabelAngleF             = 90

  contour01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  contour01_opts@cnMinLevelValF       =       5                ; set min contour level
  contour01_opts@cnMaxLevelValF       =      45                ; set max contour level
  contour01_opts@cnLevelSpacingF      =       5                ; set contour spacing

   vg_dammy = dim_avg_n(vg_cyclind(mmm,:,:,:,:),3)
   vg_d     = dim_avg_n(vg_dammy(ave_time_sta:ave_time_end,:,:),0)
   vt_dammy = dim_avg_n(vt_cyclind(mmm,:,:,:,:),3) 
   vt_mean  = dim_avg_n(vt_dammy(ave_time_sta:ave_time_end,:,:),0)

   plots         = gsn_csm_contour(wks01, (vt_mean-vg_d)  ,shade01_opts)
   plots_contour = gsn_csm_contour(wks01, vt_mean,contour01_opts)

   vector01_opts = True 
  vector01_opts = res

  vector01_opts@vcGlyphStyle           = "FillArrow"
  vector01_opts@vcFillArrowsOn           = True
  vector01_opts@vcFillArrowEdgeColor     = "black"
  vector01_opts@vcFillArrowEdgeColor     = "white"
  vector01_opts@vcLineArrowThicknessF    = 5
  vector01_opts@vcMinDistanceF           = 0.01
  vector01_opts@vcRefLengthF             = 0.06
  vector01_opts@vcRefMagnitudeF          = 7.5 
  vector01_opts@vcRefAnnoString1         = "10"
  vector01_opts@vcRefAnnoSide            = "Left"
  vector01_opts@vcRefAnnoString2On       = False
  vector01_opts@vcRefAnnoPerimOn         = False
  vector01_opts@vcRefAnnoOrthogonalPosF   =  -0.075
  vector01_opts@vcRefAnnoBackgroundColor  = "plum1"

   vr_dammy01  = dim_avg_n(vr_cyclind(mmm,:,:,:,:),3)
   vr_dammy    = dim_avg_n(vr_dammy01(ave_time_sta:ave_time_end,:,:),0)

   vr_mean  = new((/N_ZLEVS,N_RADIUS+1/),"float")  
   ww_dammy = new((/N_ZLEVS,N_RADIUS+1/),"float")  

   do nl01=0,N_ZLEVS-1,5
   do nl02=0,N_RADIUS,2
   vr_mean(nl01,nl02) = vr_dammy(nl01,nl02)
   ww_dammy(nl01,nl02)= 0
   end do
   end do

  plots_vector   = gsn_csm_vector(wks01, vr_mean, ww_dammy, vector01_opts) 

   plres = True
   plres@gsLineColor               = "grey"   ; Set the line color.
   plres@gsLineThicknessF          = 14.0
  ; dum01 = gsn_add_polyline  (wks01, plots, vt_max_r, ispan(0,N_ZLEVS,1), plres)
   ;plot_dam   = gsn_csm_vector(wks01, vr_d,ww_d,vector01_opts) 
   
   overlay(plots,plots_vector)
   overlay(plots,plots_contour)

draw(plots)
frame(wks01)  
delete(res)
   
end do ; mmm loop



do it =0 ,c_ttt-1,N_SKIPTIME 

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks02 = gsn_open_wks(TYPE,"./WRF-typhoon30-vertical02-v1_PALI_"+INIT(nnn)+"_mean-trackingcut_"+times(it))
  wks03 = gsn_open_wks(TYPE,"./WRF-typhoon30-vertical02-v1_PALI_"+INIT(nnn)+"_sprd-trackingcut_"+times(it))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@vpWidthF            = 0.60
  res@vpHeightF           = 0.60
  res@gsnLeftString       = times(it)

  if(it.lt.10)then
  res@gsnRightString   = "f00"+it
  else if (it.ge.10.and.it.lt.100)then
  res@gsnRightString   = "f0"+it
  else if (it.ge.100)then
  res@gsnRightString   = "f"+it
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


  contour01_opts = True 
  contour01_opts = res

  contour01_opts@cnLineColor           = "green"   ; Set the line color
  ;contour01_opts@cnFillOn             =  True                   ; turn on color
  contour01_opts@cnInfoLabelOn         = False  
  ;contour01_opts@lbLabelAutoStride    =  True                   ; nice label bar labels
  ;contour01_opts@cnLinesOn            =  False                  ; no contour lines
  ;contour01_opts@lbTitleString        =  "Shaded,Tangential wind(m/s)"
  contour01_opts@cnLineThicknessF      =  12
  contour01_opts@gsnContourNegLineDashPattern  = 1 	; sets negative contours to dash pattern 1
  contour01_opts@cnLineLabelInterval           = 1             ; default = 2
  contour01_opts@cnLineLabelFontHeightF        = 0.025
  ;contour01_opts@cnInfoLabelSide               = "Right"
  ;contour01_opts@cnInfoLabelFontHeightF        = 0.02
  ;contour01_opts@cnInfoLabelAngleF             = 90

  contour01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  contour01_opts@cnMinLevelValF       =       5                ; set min contour level
  contour01_opts@cnMaxLevelValF       =      45                ; set max contour level
  contour01_opts@cnLevelSpacingF      =       5                ; set contour spacing

  dammy01  = dim_avg_n(vt_cyclind(:,it,:,:,:),3) 
  vt_mean  = dim_avg_n(dammy01,0)

  dammy01_2 = dim_avg_n(vg_cyclind(:,it,:,:,:),3)
  vg_mean   = dim_avg_n(dammy01_2(:,:,:),0)

  vector01_opts = True 
  vector01_opts = res

  vector01_opts@vcGlyphStyle           = "FillArrow"
  vector01_opts@vcFillArrowsOn           = True
  vector01_opts@vcFillArrowEdgeColor     = "black"
  vector01_opts@vcFillArrowEdgeColor     = "white"
  vector01_opts@vcLineArrowThicknessF    = 5
  vector01_opts@vcMinDistanceF           = 0.01
  vector01_opts@vcRefLengthF             = 0.06
  vector01_opts@vcRefMagnitudeF          = 7.5 
  vector01_opts@vcRefAnnoString1         = "10"
  vector01_opts@vcRefAnnoSide            = "Left"
  vector01_opts@vcRefAnnoString2On       = False
  vector01_opts@vcRefAnnoPerimOn         = False
  vector01_opts@vcRefAnnoOrthogonalPosF   =  -0.075
  vector01_opts@vcRefAnnoBackgroundColor  = "plum1"

  dammy   = dim_avg_n(vr_cyclind(:,it,:,:,:),3)
  dammy02 = dim_avg_n(dammy,0)

   vr_mean  = new((/N_ZLEVS,N_RADIUS+1/),"float")  
   ww_dammy = new((/N_ZLEVS,N_RADIUS+1/),"float")  

   do nl01=0,N_ZLEVS-1,5
   do nl02=0,N_RADIUS,2
   vr_mean(nl01,nl02) = dammy02(nl01,nl02)
   ww_dammy(nl01,nl02)= 0
   end do
   end do

  plots_mean    = gsn_csm_contour(wks02, (vt_mean-vg_mean)  ,shade01_opts)
  plots_contour = gsn_csm_contour(wks02, vt_mean,contour01_opts)
  plots_vector  = gsn_csm_vector(wks02, vr_mean, ww_dammy, vector01_opts) 
  
  overlay(plots_mean,plots_vector)
  overlay(plots_mean,plots_contour)

  
  shade02_opts = True 
  shade02_opts = res

  shade02_opts@cnFillOn             = True                   ; turn on color
  shade02_opts@lbLabelAutoStride    = True                   ; nice label bar labels
  shade02_opts@cnLinesOn            = False                  ; no contour lines
  ;shade02_opts@lbTitleString        = "Shaded,Tangential wind(m/s)"

  shade02_opts@lbOrientation        = "vertical"
  shade02_opts@lbTitlePosition      = "Right"                           ; title location
  shade02_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade02_opts@lbTitleAngleF        = 90.                               ; title angle
  shade02_opts@lbTitleFontHeightF   = 0.015                              ; font height

  shade02_opts@cnFillPalette = "prcp_1"
  shade02_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade02_opts@cnMinLevelValF       =    2                  ; set min contour level
  shade02_opts@cnMaxLevelValF       =   16                  ; set max contour level
  shade02_opts@cnLevelSpacingF      =    2                ; set contour spacing

  vg_sprd  = dim_stddev_n((dammy01-dammy),0)
  delete(dammy)

  plots_sprd    = gsn_csm_contour(wks03, vg_sprd  ,shade02_opts)

  vt_max_r = new(N_ZLEVS, "integer")
  do iz =0,N_ZLEVS-1
  vt_max_r(iz) = maxind (vt_mean(iz,:)) 
  end do

  plres = True
  plres@gsLineColor               = "grey"   ; Set the line color.
  plres@gsLineThicknessF          = 14.0
  dum01 = gsn_add_polyline  (wks03, plots_sprd, vt_max_r, ispan(0,N_ZLEVS,1), plres)


draw(plots_mean)
frame(wks02)  
  
draw(plots_sprd)
frame(wks03)  

delete(res)
end do ; it loop


end do ; nnn loop



exit

end



