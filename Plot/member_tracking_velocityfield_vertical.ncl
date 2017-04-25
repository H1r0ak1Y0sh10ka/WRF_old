
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Volumes/HDD01/research/ncl/wrf/radialAvg.ncl"
begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

;********** control part **********

   WORK = "/Volumes/RAID01"
   dirc = WORK+ "/research/DATA/WRF/PALI-v2/"

   init = (/"20160106"/)
   n_init = dimsizes(init)
   
   member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
   n_member = dimsizes(member)

   n_skiptime = 6

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
  ww      = new ( (/n_timestep,nz,nlat,nlon/),"float")
  zz      = new ( (/n_timestep,nz,nlat,nlon/),"float")
  vtheta  = new ( (/n_timestep,nz,nlat,nlon/),"float")
  vr      = new ( (/n_timestep,nz,nlat,nlon/),"float")

  w_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  vtheta_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  vr_levs = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")

  c_ttt=0

  do iii =0,listnum-1,1
  print("Now reading file is "+filw(iii))

  timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(timesd) ; number of times in the file 

    do it = 0,n_times-1
     times(c_ttt)     = timesd(it)                             ; get all times in the file
     uu(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"ua",it)        ; u averaged to mass points
     vv(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"va",it)        ; v averaged to mass points
     ww(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"wa",it)        ; w averaged to mass points
     zz(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"z",it)         ; z on mass points

     vComps = calcWindComponents(uu(c_ttt,:,:,:),vv(c_ttt,:,:,:),lat,lon,c_lat(mmm,c_ttt),c_lon(mmm,c_ttt))
     vr(c_ttt,:,:,:) = vComps[0]
     vtheta(c_ttt,:,:,:) = vComps[1]
     delete(vComps)

     do iz = 0, n_zlevs-1,1
     w_levs(c_ttt,iz,:,:)        = wrf_user_intrp3d(ww(c_ttt,:,:,:),zz(c_ttt,:,:,:),"h", zlevs(iz) ,0.,False)
     vtheta_levs(c_ttt,iz,:,:)   = wrf_user_intrp3d(vtheta(c_ttt,:,:,:),zz(c_ttt,:,:,:),"h", zlevs(iz) ,0.,False)
     vr_levs(c_ttt,iz,:,:)       = wrf_user_intrp3d(vr(c_ttt,:,:,:),zz(c_ttt,:,:,:),"h", zlevs(iz) ,0.,False)
     end do  ;;; iz loop

     c_ttt=c_ttt+1

    end do ;;;it loop

  end do ; iii loop

  delete(timesd)
  delete(vr)
  delete(vtheta)

;;;;;; ento zahyo junbi ;;;;;;;;

    angle_div_deg=360.0/int2flt(n_angle_division)
    angle_phi=new ( (/n_angle_division/),"float")
    pi = 4.0*atan(1.0) 

    angle_phi=new ( (/n_angle_division/),"float")
    Cylind_x=new( (/n_radius+1,n_angle_division/),"float")  ;Cylindrical coordinate
    Cylind_y=new( (/n_radius+1,n_angle_division/),"float")  ;Cylindrical coordinate

    w_cyclind=new( (/n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 
    vtheta_cyclind=new( (/n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 
    vr_cyclind=new( (/n_timestep,n_zlevs,n_radius+1,n_angle_division/),"float") 

    do na = 0,n_angle_division-1
    Angle=angle_div_deg*int2flt(na)
    angle_phi(na)=pi*(Angle/180.0)
    end do

;;;;;;;;;;;;;;;;;;;;;;;;


    do it = 0,c_ttt-1,n_skiptime 

      print("Now calucrate time is "+times(it))
      print("LAT : "+c_lat(mmm,it)+", LON : "+c_lon(mmm,it))
      print("I_LAT : "+c_ilat(mmm,it)+", I_LON : "+c_ilon(mmm,it))

    do nr = 0,n_radius,1
    do na = 0,n_angle_division-1

    Cylind_x(nr,na)=c_ilon(mmm,it)+ nr*cos(angle_phi(na))
    Cylind_y(nr,na)=c_ilat(mmm,it)+ nr*sin(angle_phi(na))
  
    X1=floattointeger(Cylind_x(nr,na))
    X2=X1+1
    Y1=floattointeger(Cylind_y(nr,na))
    Y2=Y1+1
    DX=abs(Cylind_x(nr,na)-X1)
    DY=abs(Cylind_y(nr,na)-Y1)

      w_cyclind(it,:,nr,na)      = (1-DX)*( (1-DY)*w_levs(it,:,Y1,X1) + DY*w_levs(it,:,Y2,X1) )   \
                                    + DX*((1-DY)*w_levs(it,:,Y1,X2) + DY*w_levs(it,:,Y2,X2) )
      vtheta_cyclind(it,:,nr,na) = (1-DX)*( (1-DY)*vtheta_levs(it,:,Y1,X1) + DY*vtheta_levs(it,:,Y2,X1) )   \
                                    + DX*((1-DY)*vtheta_levs(it,:,Y1,X2) + DY*vtheta_levs(it,:,Y2,X2) )
      vr_cyclind(it,:,nr,na)     = (1-DX)*( (1-DY)*vr_levs(it,:,Y1,X1) + DY*vr_levs(it,:,Y2,X1) )   \
                                    + DX*((1-DY)*vr_levs(it,:,Y1,X2) + DY*vr_levs(it,:,Y2,X2) )

    end do ; na loop
    end do ; nr loop

    print("Now drawing time is "+times(it))

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(type,"Velocityfield-tracking-vertical-v1_PALI_"+init(nnn)+"_"+member(mmm)+"-"+times(it))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@vpWidthF             = 0.60
  res@vpHeightF            = 0.35
  plots = new(2,graphic)

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

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_radius,5)
  res@tmXBLabels = tostring(ispan(0,n_radius,5)*10)
  res@tiYAxisString        = "Height (km)"  

  shade_opts = True 
  shade_opts = res
  shade_opts@cnFillOn          = True                   ; turn on color
  shade_opts@lbLabelAutoStride = True                   ; nice label bar labels
  shade_opts@cnLinesOn         = False                  ; no contour lines
  shade_opts@cnFillPalette = "hotcolr_19lev"

  shade_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade_opts@cnMinLevelValF       =   -100                  ; set min contour level
  shade_opts@cnMaxLevelValF       =    100                   ; set max contour level
  shade_opts@cnLevelSpacingF      =    20                ; set contour spacing
  ;shade_opts@lbTopMarginF = 0.65
  ;shade_opts@lbBottomMarginF = 0.9
  shade_opts@lbOrientation   = "vertical"
  shade_opts@lbTitleString = "Shaded,Vertical wind(cm/s)"
  shade_opts@lbTitlePosition      = "Right"                           ; title location
  shade_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade_opts@lbTitleAngleF        = 90.                               ; title angle
  shade_opts@lbTitleFontHeightF   = 0.015                              ; font height

  contour_opts = True 
  contour_opts = res
  contour_opts@cnFillOn          = False                   ; turn on color
  contour_opts@gsnLeftString   = "Contour,Radial wind(m/s)"

  contour_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  contour_opts@cnMinLevelValF       =   -20                  ; set min contour level
  contour_opts@cnMaxLevelValF       =    20                   ; set max contour level
  contour_opts@cnLevelSpacingF      =    5                ; set contour spacing
  contour_opts@cnLineThicknessF     =   4.0

   vr  = dim_avg_n(vr_cyclind(it,:,:,:),2)
   w   = 100*(dim_avg_n(w_cyclind(it,:,:,:),2))
   w!0 = "cm^-1"

   plots(0)   = gsn_csm_contour(wks01, w ,shade_opts)
   plot_dam   = gsn_csm_contour(wks01, vr,contour_opts) 
                                                
   overlay(plots(0),plot_dam)


  shade02_opts = True 
  shade02_opts = res
  shade02_opts@tiXAxisString        = "Radius from the centre (km)"  
  shade02_opts@cnFillOn          = True                   ; turn on color
  shade02_opts@lbLabelAutoStride = True                   ; nice label bar labels
  shade02_opts@cnLinesOn         = False                  ; no contour lines
  shade02_opts@lbTitleString = "Shaded,Tangential wind(cm/s)"

  shade02_opts@lbOrientation   = "vertical"
  shade02_opts@lbTitlePosition      = "Right"                           ; title location
  shade02_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade02_opts@lbTitleAngleF        = 90.                               ; title angle
  shade02_opts@lbTitleFontHeightF   = 0.015                              ; font height


  colors02 = (/(/ 81     ,163     ,204/),(/ 255,255,255/),\ 
           (/153, 15, 15/), (/178, 44, 44/), \
           (/204, 81, 81/), (/229, 126, 126/), \
           (/255, 178, 178/),(/153, 84, 15/), \
           (/178, 111, 44/), (/204, 142, 81/), \
           (/229, 177, 126/),(/255, 216, 178/), \
           (/107, 153, 15/), (/133, 178, 44/), \
           (/163, 204, 81/), (/195, 229, 126/), (/229, 255, 178/)/)/ 255.

  shade02_opts@cnFillPalette = colors02
  shade02_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade02_opts@cnMinLevelValF       =    0                  ; set min contour level
  shade02_opts@cnMaxLevelValF       =   60                   ; set max contour level
  shade02_opts@cnLevelSpacingF      =    5                ; set contour spacing

  vector02_opts = True 
  vector02_opts = res
  vector02_opts@gsnLeftString   = "Vector,Secondary circulation"

  vector02_opts@vcGlyphStyle           = "CurlyVector"
  vector02_opts@vcFillArrowsOn       = True
  vector02_opts@vcFillArrowEdgeColor = "black"
  vector02_opts@vcLineArrowThicknessF      = 3
  vector02_opts@vcMinDistanceF             = 0.01
  vector02_opts@vcRefLengthF               = 0.04
  vector02_opts@vcRefAnnoOn               = False
  vector02_opts@vcRefMagnitudeF           = 10 
  vector02_opts@vcRefAnnoString1          = "60"
  vector02_opts@vcRefAnnoSide             = "Left"
  vector02_opts@vcRefAnnoString2On        = False
  vector02_opts@vcRefAnnoPerimOn          = False

   vt  = dim_avg_n(vtheta_cyclind(it,:,:,:),2)
   plots(1)   = gsn_csm_contour(wks01, vt ,shade02_opts)
   plot_dam   = gsn_csm_vector(wks01, vr,w,vector02_opts) 
   overlay(plots(1),plot_dam)


;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  gsn_panel(wks01,plots,(/2,1/),resP)               ; now draw as one plot

  delete(vr)
  delete(vt)

    end do ; it loop

end do ; mmm loop
end do ; nnn loop

exit

end

