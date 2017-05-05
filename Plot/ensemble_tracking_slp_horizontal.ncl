
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

  plo=1 ; plot is 1, not is 0
  dirc = " /Volumes/RAID01/research/DATA/WRF/PALI-v2/"

  ;init = (/"20160106","20160106-p01deg","20160106-p02deg","20160106-p03deg","20160106-p04deg","20160106-p05deg","20160106-p06deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p10deg","20160106-p20deg"/)
   init = (/"20160106"/)
   n_init = dimsizes(init)

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
  print(wrflist)

  do mmm = 0, n_member-1
    if(plo.eq.1)then
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
    end if
  end do 

  c_ttt=0

  do ii = 0,listnum-1,1

  filw = systemfunc("ls " + dirc + init(nnn) + "/???/" + wrflist(ii))   ; or WRF_*grb
  f    = addfiles (filw+".nc", "r")   ; note the "s" of addfile
  ListSetType (f, "join")
  ;print("Now data is "+filw+".")

  dlat = wrf_user_getvar(f[0],"lat",0)  ; get all times in the file
  dlon = wrf_user_getvar(f[0],"lon",0)  ; get all times in the file
  lat  = dlat(:,0)
  lon  = dlon(0,:)
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

  times = wrf_user_getvar(f[0],"times",-1)  ; get all times in the file
  n_times = count_unique_values(times) ; number of times in the file 
  dx = f[0]@DX
  dy = f[0]@DY

  slpd      = new ( (/n_member,24,nlat,nlon/),"float")
  u10d  = new ( (/n_member,24,nlat,nlon/),"float")
  v10d  = new ( (/n_member,24,nlat,nlon/),"float")

  slp_grid  = new ( (/n_member,24,n_grid,n_grid/),"float")
  u10_grid  = new ( (/n_member,24,n_grid,n_grid/),"float")
  v10_grid  = new ( (/n_member,24,n_grid,n_grid/),"float")

  do itt=0,n_times-1,  n_skiptime
  print("Now time is "+times(itt)+".")

  do mmm=0,n_member-1,1
        print("Member is "+member(mmm))
        slpd(mmm,itt,:,:) = wrf_user_getvar(f[mmm],"slp",itt); (ncl_join,Time,bottom_top,south_north,west_east)
        u10d(mmm,itt,:,:)  = wrf_user_getvar(f[mmm],"U10",itt) ; U component of the wind at 10m 
        v10d(mmm,itt,:,:)  = wrf_user_getvar(f[mmm],"V10",itt) ; V component of the wind at 10m 


        if(c_ilat(mmm,c_ttt)-r_grid.gt.0.and.c_ilat(mmm,c_ttt)+r_grid.lt.nlat.and. \
           c_ilon(mmm,c_ttt)-r_grid.gt.0.and.c_ilon(mmm,c_ttt)+r_grid.lt.nlon)then
        u10_grid(mmm,itt,:,:) = u10d(mmm,itt,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)
        v10_grid(mmm,itt,:,:) = v10d(mmm,itt,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)
        slp_grid(mmm,itt,:,:) = slpd(mmm,itt,c_ilat(mmm,c_ttt)-r_grid:c_ilat(mmm,c_ttt)+r_grid,c_ilon(mmm,c_ttt)-r_grid:c_ilon(mmm,c_ttt)+r_grid)
        else
        u10_grid(mmm,itt,:,:) =u10d@_FillValue
        v10_grid(mmm,itt,:,:) =v10d@_FillValue
        slp_grid(mmm,itt,:,:) =slpd@_FillValue
        end if 
        print("Center is "+slp_grid(mmm,itt,r_grid,r_grid))


  end do ; mmm loop


  X_LABEL = (fspan( (-1*(dx*0.001)*r_grid),((dx*0.001)*r_grid),((n_grid-1)/5)+1) )
  Y_LABEL = (fspan( (-1*(dy*0.001)*r_grid),((dy*0.001)*r_grid),((n_grid-1)/5)+1) )

;************************************************
; create plot
;************************************************
; Set some basic resources
  wks01 = gsn_open_wks(type,"slp-tracking-v1_"+TY_NAME+"_"+init(nnn)+"_mean_"+times(itt))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnRightString   = " "
  res@gsnLeftString            = "Contour:SLP(hPa), Vector:10m wind speed over 17(m/s)"
  res@gsnLeftStringFontHeightF = 0.015
  res@tiMainString        =  "Case:"+TY_NAME+", Member:Mean" \   ; use this for NCL V6.3.0 and earlier
                        +"~C~Initial time:"+times(0)+", Time:"+times(itt)+"."
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

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_grid-1,5)
  res@tmXBLabels = X_LABEL
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0,n_grid-1,5)
  res@tmYLLabels = Y_LABEL
  res@tiXAxisString        = "DX(km)"  
  res@tiYAxisString        = "DY(km)" 

  mean_opts = True 
  mean_opts = res
  mean_opts@cnLevelSelectionMode = "ManualLevels"
  mean_opts@cnMaxLevelValF = 1100
  mean_opts@cnMinLevelValF = 900
  mean_opts@cnLevelSpacingF = 4
  ;mean_opts@cnConstFLabelFontHeightF = 1
  mean_opts@cnLineLabelFontHeightF   = 0.025  
  ;mean_opts@cnLineLabelBackgroundColor = 0 
  mean_opts@gsnContourLineThicknessesScale = 8.0 


  gsn_define_colormap(wks01,"prcp_1") ; choose a colormap 
  sprd_opts = True 
  sprd_opts = res
  sprd_opts@cnFillOn          = True                   ; turn on color
  sprd_opts@gsnSpreadColors   = True                   ; use full range of color map
  sprd_opts@lbLabelAutoStride = True                   ; nice label bar labels
  sprd_opts@cnLinesOn         = False                  ; no contour lines

  sprd_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  sprd_opts@cnMinLevelValF       =  2                   ; set min contour level
  sprd_opts@cnMaxLevelValF       =  20.0                   ; set max contour level
  ;sprd_opts@cnCenterLevelValF    =  0 
  sprd_opts@cnLevelSpacingF      =  2.                ; set contour spacing
  sprd_opts@lbTopMarginF = 0.15
  sprd_opts@lbBottomMarginF = 0.4
  sprd_opts@lbOrientation   = "vertical"
  sprd_opts@lbTitleString = "Shaded,Ensemble spread(hPa)"
  sprd_opts@lbTitlePosition      = "Right"                           ; title location
  sprd_opts@lbTitleDirection     = "Across"                          ; letter angle
  sprd_opts@lbTitleAngleF        = 90.                               ; title angle
  sprd_opts@lbTitleFontHeightF   = 0.02                              ; font height


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


  u10_mean  = new ( (/n_grid,n_grid/),"float")
  v10_mean  = new ( (/n_grid,n_grid/),"float")

;   u10_mean=(dim_avg_n_Wrap(u10_grid(:,itt,:,:),0))
;   v10_mean=(dim_avg_n_Wrap(v10_grid(:,itt,:,:),0))

   do nl01=0,n_grid-1,5
   do nl02=0,n_grid-1,5
   u10_mean(nl01,nl02)=(dim_avg_n_Wrap(u10_grid(:,itt,nl01,nl02),0))
   v10_mean(nl01,nl02)=(dim_avg_n_Wrap(v10_grid(:,itt,nl01,nl02),0))
   end do
   end do

   plot_mean = gsn_csm_contour(wks01,(dim_avg_n_Wrap(slp_grid(:,itt,:,:),0)) ,mean_opts)      ; contour the variable
   plot_sprd = gsn_csm_contour(wks01, dim_stddev_n_Wrap(slp_grid(:,itt,:,:), 0),sprd_opts) 
   plot_vector = gsn_csm_vector(wks01,u10_mean, v10_mean, ws_opts)


  overlay(plot_sprd,plot_mean)
  overlay(plot_sprd,plot_vector)
;
; Remove this text string, and create some new ones to add.
;
  txres                       = True
  amres                       = True
  txres@txBackgroundFillColor = "Black"
  txres@txFont                = "helvetica-bold"
  txres@txFontColor           = "white"
  txres@txFontHeightF         = 0.02

  MINSLP=(decimalPlaces( min(dim_avg_n_Wrap(slp_grid(:,itt,:,:),0)),2,True) )

  txid01 = gsn_create_text(wks01, "MIN_SLP : "+MINSLP+"hPa", txres)

  amres@amParallelPosF   = 0.5    ; This is the right edge of the plot.
  amres@amOrthogonalPosF = 0.5    ; This is the bottom edge of the plot.
;
; By default, the center of the string is what's placed at the position
; indicated by amParallelPosF and amOrthogonalPosF. You can use amJust
; to change this to any one of 9 positions: "CenterCenter" (default),
; "TopCenter", "TopRight", "CenterRight", "BottomRight", "BottomCenter",
; "BottomLeft", "CenterLeft", "TopLeft".
;
  amres@amJust           = "BottomRight"
  annoid01 = gsn_add_annotation(plot_sprd, txid01, amres)

  draw(plot_sprd)
  frame(wks01)

  c_ttt = c_ttt +   n_skiptime
  end do ; itt loop

  end do ; ii loop

  end do ; nnn loop

exit

end


