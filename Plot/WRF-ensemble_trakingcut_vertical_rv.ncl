
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;  a = addfile("~/model/ensemble-v2/20160106/c00/wrfout_d01_2016-01-10_00:00:00.nc","r")

;********** control part **********

   TY_NAME = "PALI"

   WRF_dir =  "/Volumes/RAID01"
   dirc = WRF_dir+ "/research/DATA/WRF/PALI-v2/"
   TRACK_dir = "/Volumes/HDD01"

  ;trackdata = "/Volumes/HDD01/reseach/ncl/wrf/track/PALI_"+init+"_"+member(mem)+"-track_v24.csv"
  dirc = " /Volumes/RAID01/research/DATA/WRF/PALI-v2/"
  ;dirc = " /Volumes/Yoshi-HDD01/research/DATA/WRF/PALI-v2/"

 ; init = (/"20160106","20160106-p01deg","20160106-p02deg","20160106-p03deg","20160106-p04deg","20160106-p05deg","20160106-p06deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p10deg","20160106-p20deg"/)
   init = (/"20160106"/)

  n_init = dimsizes(init)

  ;member = (/ "c00", "p10" /)
  member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
  n_member = dimsizes(member)

  n_skiptime = 12
  n_grid = 51
  r_grid = floattointeger((n_grid-1)*0.5)
  
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
 ; print(wrflist)



  do mmm = 0, n_member-1
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
 ; print("Now data is "+filw+".")

  dlat = wrf_user_getvar(f[0],"lat",0)  ; get all times in the file
  dlon = wrf_user_getvar(f[0],"lon",0)  ; get all times in the file
  lat  = dlat(:,0)
  lon  = dlon(0,:)
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)
  sigma= f[0]->ZNU(0,:)
  nz   = dimsizes(sigma)

  ;plevs = (/1000,990,980,965,950,930,900,870,850,800,750,700,600,500,400,200,150,100,70,50,30/)
  ;n_plevs = dimsizes(plevs)
  ;plevs!0 = "lev"

  zlevs = fspan(0,15000,76)
  n_zlevs = dimsizes(zlevs)
  zlevs!0 = "lev"

  dx = f[0]@DX
  dy = f[0]@DY
  n_timestep=0
  do iii = 0,listnum-1,1
  dtimes = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(dtimes) ; number of times in the file 
  n_timestep=n_timestep+n_times
  end do ; iii loop

  times = new ( (/n_timestep/),"string")
  uu  = new ( (/n_timestep,nz,nlat,nlon/),"float")
  vv  = new ( (/n_timestep,nz,nlat,nlon/),"float")
  zz  = new ( (/n_timestep,nz,nlat,nlon/),"float")
  pp  = new ( (/n_timestep,nz,nlat,nlon/),"float")
  rv  = new ( (/n_timestep,nz,nlat,nlon/),"float")
  rv_levs = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  if(mmm.eq.0)then
  rv_grid  = new ( (/n_member,n_timestep,n_zlevs,n_grid,n_grid/),"float")
  end if

  ff  = new ( (/nlat,nlon/),"float")
  ff(:,:)    = f[0]->F(0,:,:)

  c_ttt=0

  X_LABEL = (fspan( (-1*(dx*0.001)*r_grid),((dx*0.001)*r_grid),((n_grid-1)/5)+1) )

  do iii =0,listnum-1,1
  print("Now reading file is "+filw(iii))

  timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(timesd) ; number of times in the file 

    do it = 0,n_times-1,n_skiptime
     times(c_ttt)     = timesd(it)  ; get all times in the file
     uu(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"ua",it)        ; u averaged to mass points
     vv(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"va",it)        ; v averaged to mass points
     pp(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"pressure",it) ; pressure is our vertical coordinate
     zz(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"z",it)    ; z on mass points
     rv(c_ttt,:,:,:)  = uv2vr_cfd (uu(c_ttt,:,:,:) ,vv(c_ttt,:,:,:) ,lat,lon, 3) 


     rv_levs(c_ttt,:,:,:)   = wrf_user_intrp3d(rv(c_ttt,:,:,:),zz(c_ttt,:,:,:),"h", zlevs ,0.,False)
     rv_grid(mmm,c_ttt,:,:,:)   = rv_levs(c_ttt,:,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)
     rv_grid!1 = "lev"

 
;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(type,"WRF-rv-vertical_km-v1_PALI_"+init(nnn)+"_"+member(mmm)+"-trakingcut_"+times(c_ttt))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnLeftString   = "Shade:RV"

  if(c_ttt.lt.10)then
  res@gsnRightString   = "f00"+c_ttt+"/"+times(c_ttt)
  else if (c_ttt.ge.10.and.c_ttt.lt.100)then
  res@gsnRightString   = "f0"+c_ttt+"/"+times(c_ttt)
  else if (c_ttt.ge.100)then
  res@gsnRightString   = "f"+c_ttt+"/"+times(c_ttt)
  end if 
  end if
  end if


  res@tiXAxisString   = "Radius(km)"  
  res@tmXBMode        = "Explicit"
  res@tmXBValues      = ispan(0,n_grid-1,5)
  res@tmXBLabels      = X_LABEL
  res@tmXBLabelFontHeightF = 0.020

  Y_LABEL =   zlevs *0.001 

  res@tiYAxisString        = "Height(km)"  
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0, n_zlevs-1,5)
  res@tmYLLabels = Y_LABEL(ispan(0,n_zlevs-1,5))
  res@tmYLLabelFontHeightF = 0.025

   gsn_define_colormap(wks01,"BlueDarkRed18") ; choose a colormap 
  
  shade_opts = True 
  shade_opts = res
  shade_opts@cnFillOn          = True                   ; turn on color
  shade_opts@gsnSpreadColors   = True                   ; use full range of color map
  shade_opts@lbLabelAutoStride = True                   ; nice label bar labels
  shade_opts@cnLinesOn         = False                  ; no contour lines

  shade_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade_opts@cnMinLevelValF       =  -0.0003                 ; set min contour level
  shade_opts@cnMaxLevelValF       =   0.0003                   ; set max contour level
  shade_opts@cnLevelSpacingF      =   0.00005                ; set contour spacing
  shade_opts@lbTopMarginF = 0.35
  shade_opts@lbBottomMarginF = 0.15

  shade_opts@tiMainString        =  "Case:"+TY_NAME+", Member:"+member(mmm) \   ; use this for NCL V6.3.0 and earlier

   ddd       = dim_avg_n(rv_grid(mmm,c_ttt,:,:,:),1)
   ddd!0 = "lev"
   ddd!1 = "west_east"

   plot_hadv = gsn_csm_contour(wks01, ddd ,shade_opts) 
   ;plot_hadv = gsn_csm_pres_hgt(wks01, rv_grid(c_ttt,:,20,:) ,shade_opts)
;
; Remove this text string, and create some new ones to add.
;
  txres                       = True
  amres                       = True
  txres@txBackgroundFillColor = "Black"
  txres@txFont                = "helvetica-bold"
  txres@txFontColor           = "white"
  txres@txFontHeightF         = 0.02
  txid1 = gsn_create_text(wks01, "LAT : "+decimalPlaces(c_lat(mmm,c_ttt),2,True)+", LON : "+decimalPlaces(c_lon(mmm,c_ttt),2,True), txres)

  amres@amParallelPosF   = -0.5    ; This is the right edge of the plot.
  amres@amOrthogonalPosF = -0.5    ; This is the bottom edge of the plot.
;
; By default, the center of the string is what's placed at the position
; indicated by amParallelPosF and amOrthogonalPosF. You can use amJust
; to change this to any one of 9 positions: "CenterCenter" (default),
; "TopCenter", "TopRight", "CenterRight", "BottomRight", "BottomCenter",
; "BottomLeft", "CenterLeft", "TopLeft".
;
  amres@amJust           = "TopLeft"
  annoid1 = gsn_add_annotation(plot_hadv, txid1, amres)

  draw(plot_hadv)
  frame(wks01)


     c_ttt=c_ttt+n_skiptime

     end do ;;;it loop


  end do ; iii loop

  end do  ; mmm loop


  do it = 0,c_ttt-n_skiptime,n_skiptime

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks02 = gsn_open_wks(type,"WRF-rv-vertical_km-v1_PALI_"+init(nnn)+"_mean-trakingcut_"+times(it))
  wks03 = gsn_open_wks(type,"WRF-rv-vertical_km-v1_PALI_"+init(nnn)+"_sprd-trakingcut_"+times(it))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnLeftString   = "Shade:RV"

  if(it.lt.10)then
  res@gsnRightString   = "f00"+it+"/"+times(it)
  else if (it.ge.10.and.it.lt.100)then
  res@gsnRightString   = "f0"+it+"/"+times(it)
  else if (it.ge.100)then
  res@gsnRightString   = "f"+it+"/"+times(it)
  end if 
  end if
  end if


  res@tiXAxisString   = "Radius(km)"  
  res@tmXBMode        = "Explicit"
  res@tmXBValues      = ispan(0,n_grid-1,5)
  res@tmXBLabels      = X_LABEL
  res@tmXBLabelFontHeightF = 0.020

  Y_LABEL =   zlevs *0.001 

  res@tiYAxisString        = "Height(km)"  
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0, n_zlevs-1,5)
  res@tmYLLabels = Y_LABEL(ispan(0,n_zlevs-1,5))
  res@tmYLLabelFontHeightF = 0.025

   gsn_define_colormap(wks02,"BlueDarkRed18") ; choose a colormap 
  
  shade_opts = True 
  shade_opts = res
  shade_opts@cnFillOn          = True                   ; turn on color
  shade_opts@gsnSpreadColors   = True                   ; use full range of color map
  shade_opts@lbLabelAutoStride = True                   ; nice label bar labels
  shade_opts@cnLinesOn         = False                  ; no contour lines

  shade_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade_opts@cnMinLevelValF       =  -0.0003                 ; set min contour level
  shade_opts@cnMaxLevelValF       =   0.0003                   ; set max contour level
  shade_opts@cnLevelSpacingF      =   0.00005                ; set contour spacing
  shade_opts@lbTopMarginF = 0.35
  shade_opts@lbBottomMarginF = 0.15
  shade_opts@tiMainString        =  "Case:"+TY_NAME+", Member:Mean" \   ; use this for NCL V6.3.0 and earlier


   mean       = dim_avg_n(rv_grid(:,it,:,:,:),0)
   ddd01       = dim_avg_n(mean(:,:,:),1)
   ddd01!0 = "lev"
   ddd01!1 = "west_east"

   plot_hadv = gsn_csm_contour(wks02, ddd01 ,shade_opts) 
   ;plot_hadv = gsn_csm_pres_hgt(wks01, rv_grid(it,:,20,:) ,shade_opts)

  draw(plot_hadv)
  frame(wks02)

  shade02_opts = True 
  shade02_opts = res

  gsn_define_colormap(wks03,"prcp_1") ; choose a colormap 

  shade02_opts@cnFillOn          = True                   ; turn on color
  shade02_opts@gsnSpreadColors   = True                   ; use full range of color map
  shade02_opts@lbLabelAutoStride = True                   ; nice label bar labels
  shade02_opts@cnLinesOn         = False                  ; no contour lines

  shade02_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  shade02_opts@cnMinLevelValF       =   0.00000001                 ; set min contour level
  shade02_opts@cnMaxLevelValF       =   0.0000001                   ; set max contour level
  shade02_opts@cnLevelSpacingF      =   0.00000001                ; set contour spacing
  shade02_opts@lbTopMarginF = 0.35
  shade02_opts@lbBottomMarginF = 0.15
  shade02_opts@tiMainString        =  "Case:"+TY_NAME+", Member:Sprd" \   ; use this for NCL V6.3.0 and earlier
  
   sprd       = dim_variance_n(rv_grid(:,it,:,:,:),0)
   ddd02       = dim_avg_n(sprd(:,:,:),1)
   ddd02!0 = "lev"
   ddd02!1 = "west_east"

   plot_sprd = gsn_csm_contour(wks03, ddd02 ,shade02_opts) 
   draw(plot_sprd)
   frame(wks03)


     end do ;;;it loop







  
  end do ; nnn loop
exit


end





