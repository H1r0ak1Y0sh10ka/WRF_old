
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Volumes/HDD01/research/ncl/wrf/radialAvg.ncl"
begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

;********** control part **********

   TY_NAME = "PALI"

   WORK = "/Volumes/RAID01"
  ; WORK = "/Volumes/Yoshi-HDD01"
   dirc = WORK+ "/research/DATA/WRF/PALI-v2/"

   ;init = (/"20160106"/)
   ;init = (/"20160106-p03deg","20160106-p06deg","20160106-p10deg","20160106-p04deg","20160106-p05deg","20160106-p02deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p01deg","20160106-p20deg"/)
   init = (/"20160103","20160106","20160106-p03deg","20160106-p06deg","20160106-p10deg","20160106-p04deg","20160106-p05deg","20160106-p02deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p01deg","20160106-p20deg"/)


   n_init = dimsizes(init)
   
   member = (/ "p01", "c00", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
   ;member = (/ "p09" /)
   n_member = dimsizes(member)
   
   n_skiptime = 12

   radius_km      = 200 ; kilometer
   n_radius       = 25  ; number of grids
   n_angle_division = 36  ; number
  ;angle_deltadeg = 45.0 ; degree 
   dis = 10000   ; meter
 
  z_top = 20000
  n_zlevs = 101
  zlevs = fspan(0,z_top,n_zlevs)
  zlevs!0 = "lev"

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

  do mmm = 0, n_member-1,1
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
  zz      = new ( (/nz,nlat,nlon/),"float")

  rv          = new ( (/nz,nlat,nlon/),"float")
  vt           = new ( (/nz,nlat,nlon/),"float")
  vr           = new ( (/nz,nlat,nlon/),"float")
  rv_levs     = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  vt_levs      = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  vr_levs      = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")

    if(mmm.eq.0)then
;;;;;; ento zahyo junbi ;;;;;;;;

    angle_div_deg=360.0/int2flt(n_angle_division)
    angle_phi=new ( (/n_angle_division/),"float")
    pi = 4.0*atan(1.0) 

    angle_phi=new ( (/n_angle_division/),"float")
    Cylind_x=new( (/n_radius+1,n_angle_division/),"float")  ;Cylindrical coordinate
    Cylind_y=new( (/n_radius+1,n_angle_division/),"float")  ;Cylindrical coordinate

    vt_cyclind     =new( (/n_member,n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 
    vr_cyclind     =new( (/n_member,n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 
    rv_cyclind     =new( (/n_member,n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 

    do na = 0,n_angle_division-1
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

    do it = 0,n_times-1, n_skiptime
     times(c_ttt)     = timesd(it)                             ; get all times in the file
     uu(:,:,:)  = wrf_user_getvar(f[iii],"ua",it)        ; u averaged to mass points
     vv(:,:,:)  = wrf_user_getvar(f[iii],"va",it)        ; v averaged to mass points
     zz(:,:,:)  = wrf_user_getvar(f[iii],"z",it)         ; z on mass points
     rv(:,:,:)  = uv2vr_cfd (uu(:,:,:) ,vv(:,:,:) ,lat,lon, 3)

     vComps = calcWindComponents(uu(:,:,:),vv(:,:,:),lat,lon,c_lat(mmm,c_ttt),c_lon(mmm,c_ttt))
     vt(:,:,:) = vComps[1]
     vr(:,:,:) = vComps[0]
     delete(vComps)
     vt_levs(c_ttt,:,:,:)       = wrf_user_intrp3d(vt(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
     vr_levs(c_ttt,:,:,:)       = wrf_user_intrp3d(vr(:,:,:),zz(:,:,:),"h", zlevs,0.,False)
     rv_levs(c_ttt,:,:,:)       = wrf_user_intrp3d(rv(:,:,:),zz(:,:,:),"h", zlevs,0.,False)

    do nr = 0,n_radius,1
    do na = 0,n_angle_division-1

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
      rv_cyclind(mmm,c_ttt,:,nr,na)  = (1-DX)*( (1-DY)*rv_levs(c_ttt,:,Y1,X1) + DY*rv_levs(c_ttt,:,Y2,X1) )   \
                                        + DX*((1-DY)*rv_levs(c_ttt,:,Y1,X2) + DY*rv_levs(c_ttt,:,Y2,X2) )
    else
      vt_cyclind(mmm,c_ttt,:,nr,na)  = vt_cyclind@_FillValue
      vr_cyclind(mmm,c_ttt,:,nr,na)  = vr_cyclind@_FillValue
      rv_cyclind(mmm,c_ttt,:,nr,na)  = rv_cyclind@_FillValue
    end if    
    end do ; na loop
    end do ; nr loop


  print("Now drawing time is "+times(c_ttt))
;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(type,"./WRF-typhoon31-vertical02-v1_PALI_"+init(nnn)+"_"+member(mmm)+"-trackingcut_"+times(c_ttt))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@vpWidthF             = 0.60
  res@vpHeightF            = 0.60
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

  X_LABEL = (fspan( 0,((dis*0.001)*n_radius),n_radius+1))
  Y_LABEL =  zlevs*0.001 

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_radius,5)
  res@tmXBLabels = tostring(ispan(0,n_radius,5)*10)

  res@tiYAxisString        = "Height(km)"  
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0,n_zlevs-1,10)
  res@tmYLLabels = Y_LABEL(ispan(0,n_zlevs-1,10))
  res@tmYLLabelFontHeightF = 0.02

  shade01_opts = True 
  shade01_opts = res
  shade01_opts@tiXAxisString        = "Radius from the centre (km)"  
 ; shade01_opts@tmXALabelFontHeightF = 0.02

  shade01_opts@cnFillOn             = True                   ; turn on color
  shade01_opts@lbLabelAutoStride    = True                   ; nice label bar labels
  shade01_opts@cnLinesOn            = False                  ; no contour lines
  ;shade01_opts@lbTitleString        = "Shaded,Tangential wind - Gradient wind(m/s)"

  shade01_opts@lbOrientation        = "vertical"
  shade01_opts@lbTitlePosition      = "Right"                           ; title location
  shade01_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade01_opts@lbTitleAngleF        = 90.                               ; title angle
  shade01_opts@lbTitleFontHeightF   = 0.015                              ; font height
  shade01_opts@lbTopMarginF = 0.35
  shade01_opts@lbBottomMarginF = 0.15


  shade01_opts@cnFillPalette = "hotcold_18lev"
  ;shade01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade01_opts@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;shade01_opts@cnMinLevelValF       =  -0.0005                 ; set min contour level
  ;shade01_opts@cnMaxLevelValF       =   0.0005                   ; set max contour level
  ;shade01_opts@cnLevelSpacingF      =   0.0001                ; set contour spacing
  shade01_opts@cnLevels    = (/ -5, -4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)   ; set levels
        ;            rv_cyclind     =new( (/n_member,n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 
  rv_d  = dim_avg_n(rv_cyclind(mmm,c_ttt,:,:,:),2)*10^4

  contour01_opts = True 
  contour01_opts = res
  contour01_opts@tiXAxisString         = "Radius from the centre (km)"  
  ;contour01_opts@tmXALabelFontHeightF = 0.02
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

   plots         = gsn_csm_contour(wks01, rv_d   , shade01_opts)
   plots_contour = gsn_csm_contour(wks01, vt_mean, contour01_opts)
   
   vt_max_r = new(n_zlevs, "integer")
   do iz =0,n_zlevs-1
   vt_max_r(iz) = maxind (vt_mean(iz,:)) 
   end do

   plres = True
   plres@gsLineColor               = "black"   ; Set the line color.
   plres@gsLineThicknessF          = 14.0
   dum01 = gsn_add_polyline  (wks01, plots, vt_max_r, ispan(0,n_zlevs,1), plres)
  
   overlay(plots,plots_contour)

draw(plots)
frame(wks01)  

     delete(rv_d)
     delete(vt_mean)
     delete(res)

     c_ttt=c_ttt+ n_skiptime
    end do ;;;it loop

  end do ; iii loop

  delete(timesd)
  

ave_time_sta = 12
ave_time_end = 60

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(type,"./WRF-typhoon31-vertical02-v1_PALI_"+init(nnn)+"_"+member(mmm)+"-trackingcut_"+times(ave_time_sta)+"-"+times(ave_time_end))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@vpWidthF             = 0.60
  res@vpHeightF            = 0.60
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


  X_LABEL = (fspan( 0,((dis*0.001)*n_radius),n_radius+1))
  Y_LABEL =  zlevs*0.001 

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_radius,5)
  res@tmXBLabels = tostring(ispan(0,n_radius,5)*10)

  res@tiYAxisString        = "Height(km)"  
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0,n_zlevs-1,10)
  res@tmYLLabels = Y_LABEL(ispan(0,n_zlevs-1,10))
  res@tmYLLabelFontHeightF = 0.02

  shade01_opts = True 
  shade01_opts = res
  shade01_opts@tiXAxisString        = "Radius from the centre (km)"  
 ; shade01_opts@tmXALabelFontHeightF = 0.02

  shade01_opts@cnFillOn             = True                   ; turn on color
  shade01_opts@lbLabelAutoStride    = True                   ; nice label bar labels
  shade01_opts@cnLinesOn            = False                  ; no contour lines
  ;shade01_opts@lbTitleString        = "Shaded,Tangential wind - Gradient wind(m/s)"

  ;shade01_opts@lbLabelBarOn         = False
  shade01_opts@cnInfoLabelOn         = False  

  shade01_opts@lbOrientation        = "vertical"
  shade01_opts@lbTitlePosition      = "Right"                           ; title location
  shade01_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade01_opts@lbTitleAngleF        = 90.                               ; title angle
  shade01_opts@lbTitleFontHeightF   = 0.015                              ; font height
  shade01_opts@lbTopMarginF = 0.35
  shade01_opts@lbBottomMarginF = 0.15

  shade01_opts@cnFillPalette = "hotcold_18lev"
  shade01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  ;shade01_opts@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;shade01_opts@cnMinLevelValF       =  -0.0005                 ; set min contour level
  ;shade01_opts@cnMaxLevelValF       =   0.0005                   ; set max contour level
  ;shade01_opts@cnLevelSpacingF      =   0.0001                ; set contour spacing
  shade01_opts@cnMinLevelValF       =  -5                 ; set min contour level
  shade01_opts@cnMaxLevelValF       =   5                   ; set max contour level
  shade01_opts@cnLevelSpacingF      =   1                ; set contour spacing
 
    ;shade01_opts@cnLevels    = (/ -5, -4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)   ; set levels
        
  rv_d  = dim_avg(rv_cyclind(mmm,:,:,:,:))*10000
  rv_mean02 =  dim_avg_n(rv_d(ave_time_sta:ave_time_end,:,:),0)

  contour01_opts = True 
  contour01_opts = res
  contour01_opts@tiXAxisString         = "Radius from the centre (km)"  
  ;contour01_opts@tmXALabelFontHeightF = 0.02
  contour01_opts@cnLineColor           = "green"   ; Set the line color

  ;contour01_opts@cnFillOn             =  True                   ; turn on color
  contour01_opts@cnInfoLabelOn         = False  
  ;contour01_opts@cnLineLabelsOn        = False
  ;contour01_opts@cnExplicitLabelBarLabelsOn = False

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

   vt_mean   =  dim_avg_n(vt_cyclind(mmm,:,:,:,:),3) 
   vt_mean02 =  dim_avg_n(vt_mean(ave_time_sta:ave_time_end,:,:),0)

   plots         = gsn_csm_contour(wks01, rv_mean02, shade01_opts)
   plots_contour = gsn_csm_contour(wks01, vt_mean02, contour01_opts)
   
   vt_max_r = new(n_zlevs, "integer")
   do iz =0,n_zlevs-1
   vt_max_r(iz) = maxind (vt_mean02(iz,:)) 
   end do

   plres = True
    plres@gsLineColor               = "black"   ; Set the line color.
   plres@gsLineThicknessF          = 14.0
   dum01 = gsn_add_polyline  (wks01, plots, vt_max_r, ispan(0,n_zlevs,1), plres)
  
   
   overlay(plots,plots_contour)

draw(plots)
frame(wks01)  

     delete(rv_d)
     delete(vt_mean)
end do ; mmm loop



do it =0 ,c_ttt-1,n_skiptime 

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks02 = gsn_open_wks(type,"./WRF-typhoon31-vertical02-v1_PALI_"+init(nnn)+"_mean-trackingcut_"+times(it))
  wks03 = gsn_open_wks(type,"./WRF-typhoon31-vertical02-v1_PALI_"+init(nnn)+"_sprd-trackingcut_"+times(it))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@vpWidthF             = 0.60
  res@vpHeightF            = 0.60
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

  X_LABEL = (fspan( 0,((dis*0.001)*n_radius),n_radius+1))
  Y_LABEL =  zlevs*0.001 

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_radius,5)
  res@tmXBLabels = tostring(ispan(0,n_radius,5)*10)

  res@tiYAxisString        = "Height(km)"  
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0,n_zlevs-1,10)
  res@tmYLLabels = Y_LABEL(ispan(0,n_zlevs-1,10))
  res@tmYLLabelFontHeightF = 0.02

  shade01_opts = True 
  shade01_opts = res
  shade01_opts@tiXAxisString        = "Radius from the centre (km)"  
 ; shade01_opts@tmXALabelFontHeightF = 0.02

  shade01_opts@cnFillOn             = True                   ; turn on color
  shade01_opts@lbLabelAutoStride    = True                   ; nice label bar labels
  shade01_opts@cnLinesOn            = False                  ; no contour lines
  ;shade01_opts@lbTitleString        = "Shaded,Tangential wind - Gradient wind(m/s)"

  shade01_opts@lbOrientation        = "vertical"
  shade01_opts@lbTitlePosition      = "Right"                           ; title location
  shade01_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade01_opts@lbTitleAngleF        = 90.                               ; title angle
  shade01_opts@lbTitleFontHeightF   = 0.015                              ; font height
  shade01_opts@lbTopMarginF = 0.35
  shade01_opts@lbBottomMarginF = 0.15


  shade01_opts@cnFillPalette = "hotcold_18lev"
  ;shade01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade01_opts@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;shade01_opts@cnMinLevelValF       =  -0.0005                 ; set min contour level
  ;shade01_opts@cnMaxLevelValF       =   0.0005                   ; set max contour level
  ;shade01_opts@cnLevelSpacingF      =   0.0001                ; set contour spacing
  shade01_opts@cnLevels    = (/ -5, -4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)   ; set levels

  contour01_opts = True 
  contour01_opts = res

  contour01_opts@cnLineColor           = "green"   ; Set the line color
  contour01_opts@cnInfoLabelOn         = False  
  contour01_opts@cnLineThicknessF      =  12
  contour01_opts@gsnContourNegLineDashPattern  = 1 	; sets negative contours to dash pattern 1
  contour01_opts@cnLineLabelInterval           = 1             ; default = 2
  contour01_opts@cnLineLabelFontHeightF        = 0.025

  contour01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  contour01_opts@cnMinLevelValF       =       5                ; set min contour level
  contour01_opts@cnMaxLevelValF       =      45                ; set max contour level
  contour01_opts@cnLevelSpacingF      =       5                ; set contour spacing

  dammy01  = dim_avg_n(rv_cyclind(:,it,:,:,:),3)*10000

  rv_mean  = dim_avg_n(dammy01,0)

  dammy01_2 = dim_avg_n(vt_cyclind(:,it,:,:,:),3)
  vt_mean   = dim_avg_n(dammy01_2(:,:,:),0)

   plots_mean    = gsn_csm_contour(wks02, rv_mean, shade01_opts)
   plots_contour = gsn_csm_contour(wks02, vt_mean, contour01_opts)
  
   overlay(plots_mean,plots_contour)

  shade02_opts = True 
  shade02_opts = res

  shade02_opts@cnFillOn             = True                   ; turn on color
  shade02_opts@lbLabelAutoStride    = True                   ; nice label bar labels
  shade02_opts@cnLinesOn            = False                  ; no contour lines
  ;shade02_opts@lbTitleString        = "Shaded,Tangential wind(m/s)"
  shade02_opts@tiXAxisString        = "Radius from the centre (km)"  

  shade02_opts@lbOrientation        = "vertical"
  shade02_opts@lbTitlePosition      = "Right"                           ; title location
  shade02_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade02_opts@lbTitleAngleF        = 90.                               ; title angle
  shade02_opts@lbTitleFontHeightF   = 0.015                              ; font height

  shade02_opts@cnFillPalette = "prcp_1"
  shade02_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade02_opts@cnMinLevelValF       =    1                  ; set min contour level
  shade02_opts@cnMaxLevelValF       =   10                  ; set max contour level
  shade02_opts@cnLevelSpacingF      =    1                ; set contour spacing

  rv_sprd       = dim_stddev_n(dammy01,0)
  plots_sprd    = gsn_csm_contour(wks03, rv_sprd  ,shade02_opts)


   vt_max_r = new(n_zlevs, "integer")
   do iz =0,n_zlevs-1
   vt_max_r(iz) = maxind (vt_mean(iz,:)) 
   end do

   plres = True
   plres@gsLineColor               = "black"   ; Set the line color.
   plres@gsLineThicknessF          = 14.0
   dum01 = gsn_add_polyline  (wks02, plots_mean, vt_max_r, ispan(0,n_zlevs,1), plres)
   dum02 = gsn_add_polyline  (wks03, plots_sprd, vt_max_r, ispan(0,n_zlevs,1), plres)

draw(plots_mean)
frame(wks02)  
  
draw(plots_sprd)
frame(wks03)  


end do ; it loop


end do ; nnn loop

exit

end




