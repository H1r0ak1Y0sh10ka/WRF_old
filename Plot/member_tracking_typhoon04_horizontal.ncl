
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

   WORK = "/Volumes/RAID01"
   dirc = WORK+ "/research/DATA/WRF/PALI-v2/"
   TRACK_dir = "/Volumes/HDD01"

  plo=1 ; plot is 1, not is 0
  
  init = (/"20160106"/)
  n_init = dimsizes(init)

  member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
  n_member = dimsizes(member)

  n_skiptime = 6
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
  print(wrflist)

  do mmm = 0, n_member-1

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
 ; print("Now data is "+filw+".")

  dlat = wrf_user_getvar(f[0],"lat",0)  ; get all times in the file
  dlon = wrf_user_getvar(f[0],"lon",0)  ; get all times in the file
  lat  = dlat(:,0)
  lon  = dlon(0,:)
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

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

  times = new ( (/n_timestep/),"string")

  uu  = new ( (/n_timestep,39,nlat,nlon/),"float")
  vv  = new ( (/n_timestep,39,nlat,nlon/),"float")
  pp  = new ( (/n_timestep,39,nlat,nlon/),"float")

  slpd  = new ( (/n_timestep,nlat,nlon/),"float")
  u10d  = new ( (/n_timestep,nlat,nlon/),"float")
  v10d  = new ( (/n_timestep,nlat,nlon/),"float")

  u_3levs  = new ( (/n_timestep,3,nlat,nlon/),"float")
  v_3levs  = new ( (/n_timestep,3,nlat,nlon/),"float")
  rv_3levs = new ( (/n_timestep,3,nlat,nlon/),"float")
  p_3levs  = new ( (/3/),"float")
  p_3levs  = (/925.,850.,700./)

  slp_grid  = new ( (/n_timestep,n_grid,n_grid/),"float")
  u10_grid  = new ( (/n_timestep,n_grid,n_grid/),"float")
  v10_grid  = new ( (/n_timestep,n_grid,n_grid/),"float")
  rv_grid  = new ( (/n_timestep,n_grid,n_grid/),"float")
  
  c_ttt=0

  do iii =0,listnum-1,1
  print("Now reading file is "+filw(iii))

  timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(timesd) ; number of times in the file 

    do it = 0,n_times-1
     slpd(c_ttt,:,:)  = wrf_user_getvar(f[iii],"slp",it); (ncl_join,Time,bottom_top,south_north,west_east)
       wrf_smooth_2d( slpd, 4 ) ; smooth slp 
     u10d(c_ttt,:,:)  = wrf_user_getvar(f[iii],"U10",it) ; U component of the wind at 10m 
     v10d(c_ttt,:,:)  = wrf_user_getvar(f[iii],"V10",it) ; V component of the wind at 10m 
     uu(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"ua",it)        ; u averaged to mass points
     vv(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"va",it)        ; v averaged to mass points
     pp(c_ttt,:,:,:)  = wrf_user_getvar(f[iii],"pressure",it) ; pressure is our vertical coordinate
     times(c_ttt)     = timesd(it)  ; get all times in the file

      do iz = 0, dimsizes(p_3levs)-1,1

     u_3levs(c_ttt,iz,:,:)   = wrf_user_intrp3d(uu(c_ttt,:,:,:),pp(c_ttt,:,:,:),"h", p_3levs(iz) ,0.,False)
     v_3levs(c_ttt,iz,:,:)   = wrf_user_intrp3d(vv(c_ttt,:,:,:),pp(c_ttt,:,:,:),"h", p_3levs(iz) ,0.,False)
     wrf_smooth_2d(v_3levs(c_ttt,iz,:,:),100)
     wrf_smooth_2d(u_3levs(c_ttt,iz,:,:),100)
     rv_3levs(c_ttt,iz,:,:)  = uv2vr_cfd (u_3levs(c_ttt,iz,:,:) ,v_3levs(c_ttt,iz,:,:) ,lat,lon, 3) 

      end do 
   
   rv_grid(c_ttt,:,:)  = rv_3levs(c_ttt,1,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)
   u10_grid(c_ttt,:,:) = u10d(c_ttt,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)
   v10_grid(c_ttt,:,:) = v10d(c_ttt,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)
   slp_grid(c_ttt,:,:) = slpd(c_ttt,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(type,"typhoon04-tracking-horizontal-v1_PALI_"+init(nnn)+"_"+member(mmm)+"_"+times(c_ttt))
  
  res = True
  res@gsnDraw                  = False
  res@gsnFrame                 = False
  res@gsnLeftString            = "Contour:SLP(hPa), Vector:10m wind speed over 17(m/s)"
  res@gsnLeftStringFontHeightF = 0.015
  res@tiMainString        =  "Case:"+TY_NAME+", Member:"+member(mmm) \   ; use this for NCL V6.3.0 and earlier
                        +"~C~Initial time:"+times(0)+", Time:"+times(c_ttt)+"."
  res@tiMainFontHeightF        = 0.0175

  if(c_ttt.lt.10)then
  res@gsnRightString   = "f00"+c_ttt
  else if (c_ttt.ge.10.and.c_ttt.lt.100)then
  res@gsnRightString   = "f0"+c_ttt
  else if (c_ttt.ge.100)then
  res@gsnRightString   = "f"+c_ttt
  end if 
  end if
  end if

  X_LABEL = (fspan( (-1*(dx*0.001)*r_grid),((dx*0.001)*r_grid),((n_grid-1)/5)+1) )
  Y_LABEL = (fspan( (-1*(dy*0.001)*r_grid),((dy*0.001)*r_grid),((n_grid-1)/5)+1) )

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_grid-1,5)
  res@tmXBLabels = X_LABEL
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0,n_grid-1,5)
  res@tmYLLabels = Y_LABEL
  res@tiXAxisString        = "DX(km)"  
  res@tiYAxisString        = "DY(km)" 

      ; Plotting options for RV

      rv_opts = True
      rv_opts = res 
      rv_opts@cnFillOn = True ; color contours 
      rv_opts@gsnSpreadColors   = True                   ; use full range of color map
      rv_opts@lbLabelAutoStride = True                   ; nice label bar labels
      rv_opts@cnLinesOn         = False                  ; no contour lines

      gsn_define_colormap(wks01,"hotcolr_19lev") ; choose a colormap 
      ;rv_opts@cnInfoLabelOrthogonalPosF = 0.07 ; offset second label information 
      ;rv_opts@gsnContourLineThicknessesScale = 3.0
      rv_opts@cnInfoLabelOn       = False           ; turn off cn info label
      rv_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
      rv_opts@cnMinLevelValF       =  -0.0004                  ; set min contour level
      rv_opts@cnMaxLevelValF       =   0.0004                   ; set max contour level
      rv_opts@cnLevelSpacingF      =   0.0001                ; set contour spacing
      rv_opts@lbTopMarginF = 0.15
      rv_opts@lbBottomMarginF = 0.4
      rv_opts@lbOrientation   = "vertical"
      ;rv_opts@lbTitleString = "Shaded,Tangentical wind(m/s)"
      rv_opts@lbTitlePosition      = "Right"                           ; title location
      rv_opts@lbTitleDirection     = "Across"                          ; letter angle
      rv_opts@lbTitleAngleF        = 90.                               ; title angle
      rv_opts@lbTitleFontHeightF   = 0.03                              ; font height


      ; Plotting options for SLP 

       slp_opts = True
       slp_opts = res 
       slp_opts@cnFillOn = False ; color contours 
       slp_opts@cnLineColor = "Black"
       slp_opts@cnLevelSelectionMode = "ManualLevels"
       slp_opts@cnMaxLevelValF = 1100
       slp_opts@cnMinLevelValF = 900
       slp_opts@cnLevelSpacingF = 4

       slp_opts@cnLineLabelFontHeightF   = 0.025  
       slp_opts@cnLineLabelBackgroundColor = 0 
       slp_opts@gsnContourLineThicknessesScale = 8.0 
       slp_opts@gsnLeftString   = ""
       slp_opts@gsnRightString   = ""

       ; Plotting options for Wind Speed vector

        ws_opts = res
        ws_opts@vcMinMagnitudeF          =  17
        ws_opts@vcGlyphStyle           = "FillArrow"
        ws_opts@vcFillArrowsOn       = True
        ws_opts@vcFillArrowFillColor       = "green"
        ws_opts@vcFillArrowEdgeColor = "black"
        ws_opts@vcLineArrowThicknessF      = 5
        ws_opts@vcMinDistanceF             = 0.01
        ws_opts@vcRefLengthF               = 0.06
        ws_opts@vcRefAnnoOn               = True
        ws_opts@vcRefMagnitudeF           = 17 
        ws_opts@vcRefAnnoString1          = "17"
        ws_opts@vcRefAnnoSide             = "Left"
        ws_opts@vcRefAnnoString2On        = False
        ws_opts@vcRefAnnoPerimOn          = False
        ws_opts@vcRefAnnoOrthogonalPosF   =  -0.075
        ws_opts@vcRefAnnoBackgroundColor  = "plum1"
        ws_opts@vcVectorDrawOrder         = "PostDraw"
        ws_opts@gsnLeftString   = ""
        ws_opts@gsnRightString   = ""

        u10_draw  = new ( (/n_grid,n_grid/),"float")
        v10_draw  = new ( (/n_grid,n_grid/),"float")

        do nl01=0,n_grid-1,5
        do nl02=0,n_grid-1,5
        u10_draw(nl01,nl02)=u10_grid(c_ttt,nl01,nl02)
        v10_draw(nl01,nl02)=v10_grid(c_ttt,nl01,nl02)
        end do
        end do

      plot_rv     = gsn_csm_contour(wks01, rv_grid(c_ttt,:,:),rv_opts) 
      plot_slp    = gsn_csm_contour(wks01, slp_grid(c_ttt,:,:) ,slp_opts)      ; contour the variable
      plot_vector = gsn_csm_vector(wks01,u10_draw, v10_draw, ws_opts)

      overlay(plot_rv,plot_slp)
      overlay(plot_rv,plot_vector)

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
  annoid1 = gsn_add_annotation(plot_rv, txid1, amres)

  draw(plot_rv)
  frame(wks01)

     c_ttt=c_ttt+1

     end do ;;;it loop

  end do ; iii loop

  end do  ; mmm loop
  
  end do ; nnn loop

exit

end




