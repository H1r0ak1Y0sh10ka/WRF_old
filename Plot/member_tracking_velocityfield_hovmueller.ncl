
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "/Volumes/Yoshi-HDD01/research/ncl/wrf/radialAvg.ncl"
begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

;********** control part **********

   TY_NAME = "PALI"

   WORK = "/Volumes/RAID01"
   dirc = WORK+ "/research/DATA/WRF/PALI-v2/"
   TRACK_dir = "/Volumes/HDD01"

   ;init = (/"20160106","20160106-p01deg","20160106-p02deg","20160106-p03deg","20160106-p04deg","20160106-p05deg"/)
   init = (/"20160106-p06deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p10deg"/)
   n_init = dimsizes(init)
   
   member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
   n_member = dimsizes(member)

   n_skiptime = 1

   radius_km      = 200 ; kilometer
   n_radius       = 25  ; number of grids
   n_angle_division = 36  ; number
   dis = 10000   ; meter
   Height = 2000 ;meter


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
     trackdata = TRACK_dir+"/research/ncl/wrf/track/PALI_"+init(nnn)+"_"+member(mmm)+"-track_v25.csv"
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

  n_zlevs = dimsizes(Height)

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

  vtheta_levs  = new ( (/n_timestep,nlat,nlon/),"float")

  c_ttt=0

  do iii =0,listnum-1,1
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

     vtheta_levs(c_ttt,:,:)   = wrf_user_intrp3d(vtheta(c_ttt,:,:,:),zz(c_ttt,:,:,:),"h", Height ,0.,False)

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

    w_cyclind=new( (/n_timestep,n_radius+1,n_angle_division/),"float") 
    vtheta_cyclind=new( (/n_timestep,n_radius+1,n_angle_division/),"float") 
    vr_cyclind=new( (/n_timestep,n_radius+1,n_angle_division/),"float") 

    do na = 0,n_angle_division-1
    Angle=angle_div_deg*int2flt(na)
    angle_phi(na)=pi*(Angle/180.0)
    end do

;;;;;;;;;;;;;;;;;;;;;;;;


    do it = 0,c_ttt-1,n_skiptime 

      print("Now calucrate time is "+times(it))
      print("LAT : "+c_lat(mmm,it)+", LON : "+c_lon(mmm,it))
      print("I_LAT : "+c_ilat(mmm,it)+", I_LON : "+c_ilon(mmm,it))


    if((c_ilat(mmm,it)-n_radius).ge.0.and.(c_ilat(mmm,it)+n_radius).le.nlat.and.\
        (c_ilon(mmm,it)-n_radius).ge.0.and.(c_ilon(mmm,it)+n_radius).le.nlon)then

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

         if(X1.ge.0.and.X1.le.nlon.and.X2.ge.0.and.X2.le.nlon.and. \
         Y1.ge.0.and.Y1.le.nlat.and.Y2.ge.0.and.Y2.le.nlat)then
         vtheta_cyclind(it,nr,na) = (1-DX)*( (1-DY)*vtheta_levs(it,Y1,X1) + DY*vtheta_levs(it,Y2,X1) )   \
                                    + DX*((1-DY)*vtheta_levs(it,Y1,X2) + DY*vtheta_levs(it,Y2,X2) )
         else
         vtheta_cyclind(it,nr,na) = vtheta_levs@_FillValue
         end if

         end do ; na loop
         end do ; nr loop

    else
     vtheta_cyclind(it,:,:) = vtheta_levs@_FillValue
    end if

    end do ; it loop


;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(type,"Velocityfield-tracking-hovmueller-v1_PALI_"+init(nnn)+"_"+member(mmm)+"_"+(Height*0.001)+"km")

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@vpWidthF             = 0.60
  res@vpHeightF            = 1.00

  res@tiMainString        =  "Case:"+TY_NAME+", Member:"+member(mmm) \   ; use this for NCL V6.3.0 and earlier
                        +"~C~Height:"+(Height*0.001)+"km, Initial time:"+times(0)
  res@tiMainFontHeightF  = 0.03
  
  plots = new(2,graphic)

  X_LABEL = (fspan( 0,((dis*0.001)*n_radius),n_radius+1))

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_radius,5)
  res@tmXBLabels = tostring(ispan(0,n_radius,5)*10)
  res@tiXAxisString        = "Radius from the centre (km)"  

  res@tiYAxisString        = "Forecast time(hour)"  
  ;res@tmYLMode = "Explicit"
  ;res@tmYLValues = ispan(0,c_ttt-1,24)
  ;res@tmYLLabels = tostring(ispan(0,n_radius,5)*10)
  res@tmYLMode = "Manual"
  res@tmYLTickStartF   = 0
  res@tmYLTickSpacingF = 24
  res@tmYLTickEndF     = c_ttt-1


  ;res@tmYRMode  = "Manual"
  ;res@tmYRFormat  = "f"
  ;res@tmYROn      = False
  ;restick = True
  ;restick@ttmFormat = "%D,%H"
  ;restick@ttmAxis = "YR"
  ;restick@ttmMajorStride = 24
  ;restick@ttmMinorStride  = 12

  ;dammy           = todouble(ispan(0,c_ttt-1,1))
  ;dammy@units     = "hours since 2016-01-06 00:00:00"
  ;dammy!0         = "Time"      ; name the dimension
  ;dammy@long_name ="Time"

  ;time_axis_labels(dammy,  res, restick)

  shade01_opts = True 
  shade01_opts = res

  shade01_opts@cnFillOn          = True                   ; turn on color
  shade01_opts@lbLabelAutoStride = True                   ; nice label bar labels
  shade01_opts@cnLinesOn         = False                  ; no contour lines
 
  colors01 = (/(/ 81,163,204/),(/255,255,255/),\ 
               (/153, 15, 15/),(/178, 44, 44/), \
               (/204, 81, 81/),(/229,126,126/), \
               (/255,178,178/),(/153, 84, 15/), \
               (/178,111, 44/),(/204,142, 81/), \
               (/229,177,126/),(/255,216,178/), \
               (/107,153, 15/),(/133,178, 44/), \
               (/163,204, 81/),(/195,229,126/), \
               (/229,255,178/)/)/ 255.

  shade01_opts@cnFillPalette = colors01
  shade01_opts@cnMissingValFillColor = "gray40"             ; can also use "transparent"
  shade01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade01_opts@cnMinLevelValF       =    0                  ; set min contour level
  shade01_opts@cnMaxLevelValF       =   60                   ; set max contour level
  shade01_opts@cnLevelSpacingF      =    5                ; set contour spacing

  shade01_opts@lbTopMarginF = 0.65
  shade01_opts@lbBottomMarginF = 0.9
  shade01_opts@lbOrientation   = "vertical"
  shade01_opts@lbTitleString = "Shaded,Tangentical wind(m/s)"
  shade01_opts@lbTitlePosition      = "Right"                           ; title location
  shade01_opts@lbTitleDirection     = "Across"                          ; letter angle
  shade01_opts@lbTitleAngleF        = 90.                               ; title angle
  shade01_opts@lbTitleFontHeightF   = 0.03                              ; font height

  ;contour01_opts = True 
  ;contour01_opts = res
  ;contour01_opts@cnFillOn          = False                   ; turn on color
  ;contour01_opts@gsnLeftString   = "Contour,Radial wind(m/s)"

  ;contour01_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  ;contour01_opts@cnMinLevelValF       =   -20                  ; set min contour level
  ;contour01_opts@cnMaxLevelValF       =    20                   ; set max contour level
  ;contour01_opts@cnLevelSpacingF      =    5                ; set contour spacing
  ;contour01_opts@cnLineThicknessF     =   4.0

   vt  = dim_avg_n(vtheta_cyclind(:,:,:),2)
   plots(0)   = gsn_csm_contour(wks01, vt ,shade01_opts)
                                                
  draw(plots(0))
  frame(wks01)

end do ; mmm loop
end do ; nnn loop

exit

end

