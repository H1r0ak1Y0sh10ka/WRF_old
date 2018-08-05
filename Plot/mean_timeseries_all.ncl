; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;

  scp_ver  = "v10"

  init_YYYY = "2016"
  init_M    = 1
  init_D    = 3
  init_H    = 0
  init_plus = "" ; ex. -p01deg

  para = (/ "spd"/)    ; spd, cape ,dcapedt,dspddt
  npara    = dimsizes(para)

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
; type = "eps"
 type = "png"

  plot_type  = 4 ;;;; 0 is max and min with mean and best track.
                 ;;;; 1 is all members' contours without best track.
                 ;;;; 2 is the ensemble number's plots by emphasis of each member.
                 ;;;; 3 is the ensemble number's plots by emphasis of each member.
                 ;;;; 4 is best member and worst member at any time with mean and best track.

  ibtracs_dir  = "/Volumes/HDD01/research/analysis/track/ibtracks/"
  ibtracs_data = "2016005N02187.ibtracs."
  ibtracs_ver  = "v03r10"

  ;track_dir    = "~/Desktop/track/"
  track_dir    = "/Volumes/HDD01/research/ncl/wrf/track/"
  track_ver    = "v25"

   case_name   = "PALI"

   if(init_M.lt.10)then
   init_MM   = "0"+init_M
   else if(init_M.ge.10.)then
   init_MM   = init_M
   end if
   end if

   if(init_D.lt.10)then
   init_DD   = "0"+init_D
   else if(init_D.ge.10.)then
   init_DD   = init_D
   end if
   end if

   if(init_H.lt.10)then
   init_HH   = "0"+init_H
   else if(init_H.ge.10.)then
   init_HH   = init_H
   end if
   end if

   init   =  init_YYYY+init_MM+init_DD+init_plus
   ninit  =  dimsizes(init)

   forecast_day  = 8
   forecast_int   = 1
   timestep   = forecast_day*(24/forecast_int)+1

   member = new(11,string)
   member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
   mmm    = dimsizes(member)

   data     = new((/ninit,mmm,timestep/),float)
   mspd     = new((/timestep/),float)
   bspd     = new((/timestep/),float)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;********************
; get ibtracs data
;********************

  f        = addfile(ibtracs_dir+ibtracs_data+ibtracs_ver+".nc","r")

  time = f->time_wmo
  ibtracs_spd  = (f->wind_wmo)*0.514444 
  ibtracs_date = ut_calendar(time, 0)
  ibtracs_ndate = dimsizes(ibtracs_date(:,0))

   ibtracs_startn = 0
   ibtracs_endn   = 0
 
  do in = 0, ibtracs_ndate-1,1
  
   if(ibtracs_date(in,0).eq.init_YYYY.and.ibtracs_date(in,1).eq.init_M.and.ibtracs_date(in,2).eq.init_D.and.ibtracs_date(in,3).eq.init_H)then
   ibtracs_startn = in
   end if

   if(ibtracs_date(in,0).eq.init_YYYY.and.ibtracs_date(in,1).eq.init_M.and.ibtracs_date(in,2).eq.(init_D+forecast_day).and.ibtracs_date(in,3).eq.init_H)then
   ibtracs_endn = in
   end if
   
  end do

   if(ibtracs_endn.eq.0)then
    ibtracs_endn = ibtracs_ndate-1
   end if
 
   if(ibtracs_startn.eq.0.and.(ibtracs_endn-ibtracs_startn+1).lt.forecast_day*4+1)then
   err = ((forecast_day*4+1)-(ibtracs_endn-ibtracs_startn))
   start_fcstn =(err-1)*6+ibtracs_startn
   end_fcstn   =start_fcstn+(ibtracs_endn-ibtracs_startn)*6
   else
   start_fcstn =0
   end_fcstn   =start_fcstn+(ibtracs_endn-ibtracs_startn)*6
   end if

   do in = ibtracs_startn,ibtracs_endn
   bspd(start_fcstn+(in-ibtracs_startn)*6) = ibtracs_spd(in)   
   end do 

  bspd(0:timestep-1)=linmsg(bspd(0:timestep-1),0)

  do nnn = 0,ninit-1 ; number of initial times
  do ii = 0,mmm-1    ; number of members 
  do ppp = 0,npara-1 ; parameter loop

     trackdata = track_dir+case_name+"_"+init(nnn)+"_"+member(ii)+"-"+para(ppp)+"_"+ track_ver+".csv"
     if(para.eq."dcapedt")then
     delete(trackdata)
     trackdata = track_dir+case_name+"_"+init(nnn)+"_"+member(ii)+"-cape_"+ track_ver+".csv"
     else if(para.eq."dspddt")then
     delete(trackdata)
     trackdata = track_dir+case_name+"_"+init(nnn)+"_"+member(ii)+"-spd_"+ track_ver+".csv"
     end if
     end if

;---Read in file as array of strings so we can parse each line
  lines  = asciiread(trackdata,-1,"string")
  nlines = dimsizes(lines)   ; First line is not a header
 ;  print(lines)
;---This file has quotes around everything, which we don't want.
  dq    = str_get_dq()
  lines = str_sub_str(lines,dq,"")   ; Replace quotes with empty string
;---First line is name of each field
  delim       = ","
  field_names = str_split(lines(0),delim)
  nfields     = dimsizes(field_names)
;---We're going to read the whole file as a 2D array of strings
  fields = new((/nfields,nlines/),string)
;---Remember that fields start at 1, not 0.
  do nf=0,nfields-1
    fields(nf,:) = str_get_field(lines,nf+1,delim)
    data(nnn,ii,:) = stringtofloat(fields(2,:))
  end do

delete(lines)
delete(fields)
  end do ;;; ppp loop
  end do ;;; ii loop

  if(para.eq."dcapedt")then
  nave = 7
  opt  = 0
  data = runave(center_finite_diff(data(nnn,:,:),1,False,0),nave,opt)
  else if(para.eq."dspddt")then
  nave = 7
  opt  = 0
  data = runave(center_finite_diff(data(nnn,:,:),1,False,0),nave,opt)
  else if(para.eq."spd")then
  gustfactor = 1.23
  data = data/gustfactor
  end if
  end if
  end if
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  p_opt = True
  p_opt@gsnDraw              = False              ; don't draw
  p_opt@gsnFrame             = False              ; don't advance frame
 ; p_opt@gsnMaximize          = True
  p_opt@vpWidthF             = 0.75
  p_opt@vpHeightF            = 0.4

  x_opt = True
  x_opt@tmXBMode = "Manual"
  x_opt@tmXBTickStartF  = 0
  x_opt@tmXBTickEndF    = timestep-1
  x_opt@tmXBTickSpacingF= 24
  x_opt@tmXBLabelFontHeightF = 0.02
  x_opt@trXMinF = 0
  x_opt@trXMaxF = timestep-1
  x = ispan(0,timestep-1,1)
  x@description	= "Forecast time (hour)"
  x_opt@tiXAxisFontHeightF = 0.02
  
  y_opt = True
  y_opt@tmYLLabelFontHeightF = 0.02
 
  outname = "./"+init(nnn)+"_mean_timeseries_"+para+"_"+ track_ver+"_"+scp_ver
  wks01 = gsn_open_wks(type,outname)

  res01 = True
; this controls the size and location of the second plot
  res01 = p_opt
  res01 = x_opt
  res01@xyDashPattern   = 0   

  res01@tmYLMode = "Manual"
  if(para.eq."spd")then
  res01@tmYLTickStartF  =  0.
  res01@tmYLTickEndF    = 50.
  res01@tmYLTickSpacingF= 10.
  res01@trYMinF = 0
  res01@trYMaxF = 50
  res01@tiYAxisString   = "Wind speed (ms~S~-1~N~)"
  else if(para.eq."dspddt")then
  res01@tmYLTickStartF  =  -2.0
  res01@tmYLTickEndF    =   2.0
  res01@tmYLTickSpacingF=   0.5
  res01@trYMinF = -2.0
  res01@trYMaxF =  2.0
  res01@tiYAxisString   = "Wind speed (ms~S~-1~N~hour~S~-1~N~)"
  else if(para.eq."cape")then
  res01@tmYLTickStartF  =     0.
  res01@tmYLTickEndF    =  3500.
  res01@tmYLTickSpacingF=   500.
  res01@trYMinF =    0
  res01@trYMaxF = 3500
  res01@tiYAxisString   = "CAPE (JK~S~-1~N~)"
  else if(para.eq."dcapedt")then
  res01@tmYLTickStartF  = -250.
  res01@tmYLTickEndF    =  250.
  res01@tmYLTickSpacingF=   50.
  res01@trYMinF = -250
  res01@trYMaxF =  250
  res01@tiYAxisString   = "CAPE (JK~S~-1~N~hour~S~-1~N~)"
  end if
  end if
  end if
  end if

  res01@tiYAxisFontHeightF = 0.02
  res01@tmYLLabelFontHeightF = 0.02

  mean=dim_avg_n_Wrap(data(nnn,:,:),0)

  ex_opts = True
  ex_opts = res01
  ex_opts@xyLineColor           = "black"
  ex_opts@xyLineThicknessF      = 5.0
  plots_mean = gsn_csm_xy(wks01,x,mean,ex_opts)

  me_opts = True
  me_opts = res01

 if(plot_type.eq.0)then ;******************************************************************************************************************************
  print("plot_type is 0.")

  b_opts = True
  b_opts = res01
  b_opts@xyLineColor           = "red"
  b_opts@xyLineThicknessF      = 5.0
  plots_best  = gsn_csm_xy(wks01,x,bspd,b_opts)

;*****************************************************   
; CALCULATE MIN & MAX
;***************************************************** 
  mnmx      = new ((/2,timestep/), float)
  mnmx(0,:) = dim_min_n(data(nnn,:,:),0)
  mnmx(1,:) = dim_max_n(data(nnn,:,:),0)

;*****************************************************   
; CALCULATE RSME & BEST MEMBER
;***************************************************** 
  rmse     = new((/mmm/),float)

  do im = 0, mmm-1,1
  rmse(im) = dim_rmsd(bspd(start_fcstn:end_fcstn),data(nnn,im,start_fcstn:end_fcstn))
  end do

  best_membern = minind(rmse)

  do ii = 0,mmm-1 ,1
  if(ii.eq.best_membern)then
  me_opts@xyLineColor           = "Blue"
  me_opts@xyLineThicknessF      = 5.0
  plots_member = gsn_csm_xy(wks01,x,data(0,ii,:),me_opts)
  overlay(plots_mean,plots_member)
    delete(plots_member)
  end if
  end do

  delete( me_opts@xyLineColor  )
  delete( me_opts@xyLineThicknessF   )

  me_opts@gsnXYFillColors          = "lightgray"
  me_opts@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
  me_opts@xyMonoLineColor    = False             ; want colored lines
  plots_member = gsn_csm_xy(wks01,x,mnmx(0:1,:),me_opts)
  overlay(plots_mean,plots_member)
  overlay(plots_mean,plots_best)

;----------------------------------------------------------------------
; Code for customizing a legend via simple_legend.
;----------------------------------------------------------------------

;---Create three resource lists required for simple_legend
  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position             = "Bottom"
  gres@YPosPercent          = 75.5      ; from the bottom
  gres@XPosPercent          =  2.5      ; move to the right side
  lineres@lgLineThicknesses = 5.0      ; line thicknesses
  lineres@lgDashIndexes = (/0,2,0,0,0/)                   ; line types
  lineres@LineLengthPercent = 9.       ; expressed as %, 0->100, length of line

;---Attach legend to first plot
  textres@lgLabels     = (/"Best track","Ensemble mean("+decimalPlaces(dim_rmsd(bspd(start_fcstn:end_fcstn),mean(start_fcstn:end_fcstn)),2,True)+")","Ensemble members","Best member("+member(best_membern)+","+decimalPlaces(rmse(best_membern),2,True)+")"/)
  lineres@lgLineColors =  (/"red", "black", "lightgray","Blue"/)

  plot_legend = simple_legend(wks01,plots_mean,gres,lineres,textres)

  else if(plot_type.eq.1)then ;******************************************************************************************************************************
  print("plot_type is 1.")

  gsn_define_colormap(wks01,"CBR_set3")
  colors01 = ispan(1,12,1)

  do ii = 0,mmm-1,1
  me_opts@xyLineColor           = colors01(ii+1)
  me_opts@xyLineThicknessF      = 5.0
  plots_member = gsn_csm_xy(wks01,x,data(0,ii,:),me_opts)
  overlay(plots_mean,plots_member)
  delete(plots_member)
  end do

;----------------------------------------------------------------------
; Code for customizing a legend via simple_legend.
;----------------------------------------------------------------------

;---Create three resource lists required for simple_legend
  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position               = "Bottom"
  gres@YPosPercent            =  40.0      ; from the bottom
  gres@XPosPercent            =  2.5      ; move to the right side
  lineres@lgLineThicknesses   = 5.0       ; line thickness
  lineres@lgDashIndexes       = 0         ; line type
  lineres@LineLengthPercent = 9.        ; expressed as %, 0->100, length of line

;---Attach legend to first plot
  textres@lgLabels     = (/"Mean","M00","M01","M02","M03","M04","M05","M06","M07","M08","M09","M10"/)
  ;lineres@lgLineColors =  (/"black", colors01(0), colors01(1), colors01(2), colors01(3), colors01(4), colors01(5), colors01(6), colors01(7), colors01(8), colors01(9), colors01(10)/)
  lineres@lgLineColors = colors01(0:11)

  plot_legend = simple_legend(wks01,plots_mean,gres,lineres,textres)

else if(plot_type.eq.2)then ;******************************************************************************************************************************
  print("plot_type is 2.")

else if(plot_type.eq.3)then ;******************************************************************************************************************************
  print("plot_type is 3.")

  b_opts = True
  b_opts = res01

;*****************************************************   
; CALCULATE MIN & MAX
;***************************************************** 
  mnmx      = new ((/2,timestep/), float)
  mnmx(0,:) = dim_min_n(data(nnn,:,:),0)
  mnmx(1,:) = dim_max_n(data(nnn,:,:),0)

;*****************************************************   
; CALCULATE RSME & BEST MEMBER
;***************************************************** 

  do ii = 0,mmm-1 ,1
  if(ii.eq.9)then
  me_opts@xyLineColor           = "Blue"
  me_opts@xyLineThicknessF      = 5.0
  plots_member = gsn_csm_xy(wks01,x,data(0,ii,:),me_opts)
  print(dim_sum(data(0,ii,48:96)))
  print(dim_sum(data(0,ii,96:144)))

  overlay(plots_mean,plots_member)
    delete(plots_member)
  end if
  end do

  delete( me_opts@xyLineColor  )
  delete( me_opts@xyLineThicknessF   )

  me_opts@gsnXYFillColors          = "lightgray"
  me_opts@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
  me_opts@xyMonoLineColor    = False             ; want colored lines
  plots_member = gsn_csm_xy(wks01,x,mnmx(0:1,:),me_opts)
  overlay(plots_mean,plots_member)

;----------------------------------------------------------------------
; Code for customizing a legend via simple_legend.
;----------------------------------------------------------------------

;---Create three resource lists required for simple_legend
  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position             = "Bottom"
  gres@YPosPercent          =  5.5      ; from the bottom
  gres@XPosPercent          =  2.5      ; move to the right side
  lineres@lgLineThicknesses = 5.0      ; line thicknesses
  lineres@lgDashIndexes = (/0,2,0,0,0/)                   ; line types
  lineres@LineLengthPercent = 9.       ; expressed as %, 0->100, length of line

;---Attach legend to first plot
  textres@lgLabels     = (/"Ensemble mean","Ensemble members","Best member"/)
  lineres@lgLineColors =  (/"black", "lightgray","Blue"/)

  plot_legend = simple_legend(wks01,plots_mean,gres,lineres,textres)

else if(plot_type.eq.4)then ;******************************************************************************************************************************
  print("plot_type is 4.")

  b_opts = True
  b_opts = res01
  b_opts@xyLineColor           = "red"
  b_opts@xyLineThicknessF      = 5.0
  plots_best  = gsn_csm_xy(wks01,x,bspd,b_opts)

;*****************************************************   
; CALCULATE MIN & MAX
;***************************************************** 
  mnmx      = new ((/2,timestep/), float)
  mnmx(0,:) = dim_min_n(data(nnn,:,:),0)
  mnmx(1,:) = dim_max_n(data(nnn,:,:),0)

;*****************************************************   
; CALCULATE RSME & BEST MEMBER
;***************************************************** 
  rmse     = new((/mmm/),float)
  EVA_STA  =  54
  EVA_END  = 132

  do im = 0, mmm-1,1
  rmse(im) = dim_rmsd(bspd(EVA_STA:EVA_END),data(nnn,im,EVA_STA:EVA_END))
  end do

  best_membern = minind(rmse)
  wrst_membern = 10;maxind(rmse)

  me_opts@xyLineColor           = "Blue"
  me_opts@xyLineThicknessF      = 5.0
  plots_member = gsn_csm_xy(wks01,x,data(0,best_membern,:),me_opts)
  overlay(plots_mean,plots_member)
  delete(plots_member)

  delete( me_opts@xyLineColor  )
  delete( me_opts@xyLineThicknessF   )

  me_opts@xyLineColor           = "green4"
  me_opts@xyLineThicknessF      = 5.0
  plots_member = gsn_csm_xy(wks01,x,data(0,wrst_membern,:),me_opts)
  overlay(plots_mean,plots_member)
  delete(plots_member)

  delete( me_opts@xyLineColor  )
  delete( me_opts@xyLineThicknessF   )

  me_opts@gsnXYFillColors          = "lightgray"
  me_opts@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
  me_opts@xyMonoLineColor    = False             ; want colored lines
  plots_member = gsn_csm_xy(wks01,x,mnmx(0:1,:),me_opts)
  overlay(plots_mean,plots_member)
  overlay(plots_mean,plots_best)

;----------------------------------------------------------------------
; Code for customizing a legend via simple_legend.
;----------------------------------------------------------------------

;---Create three resource lists required for simple_legend
  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position             = "Bottom"
  gres@YPosPercent          = 75.5      ; from the bottom
  gres@XPosPercent          =  2.5      ; move to the right side
  lineres@lgLineThicknesses = 5.0      ; line thicknesses
  lineres@lgDashIndexes = (/0,0,0,0,0/)                   ; line types
  lineres@LineLengthPercent = 9.       ; expressed as %, 0->100, length of line

;---Attach legend to first plot
  textres@lgLabels     = (/"Best track","Ensemble mean("+decimalPlaces(dim_rmsd(bspd(start_fcstn:end_fcstn),mean(start_fcstn:end_fcstn)),2,True)+")","Ensemble members","Best member("+member(best_membern)+","+decimalPlaces(rmse(best_membern),2,True)+")","Worst member("+member(wrst_membern)+","+decimalPlaces(rmse(wrst_membern),2,True)+")"/)
  lineres@lgLineColors =  (/"red", "black", "lightgray","Blue","green4"/)

  plot_legend = simple_legend(wks01,plots_mean,gres,lineres,textres)

end if    ;******************************************************************************************************************************
end if    ;******************************************************************************************************************************
end if   ;******************************************************************************************************************************
end if   ;******************************************************************************************************************************
end if   ;******************************************************************************************************************************

  draw(plots_mean)
  frame(wks01)

    fili = systemfunc("mogrify -trim +repage "+ outname + "." +type )

 end do ;;; nnn loop


exit
end







