
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;  a = addfile("~/model/ensemble-v2/20160106/c00/wrfout_d01_2016-01-10_00:00:00.nc","r")

;********** control part **********
  plo=0 ; plot is 1, not is 0
  ;trackdata = "/Volumes/HDD01/reseach/ncl/wrf/track/PALI_"+init+"_"+member(mem)+"-track_v24.csv"
  dirc = " /Volumes/RAID01/research/DATA/WRF/PALI-v2/"
  ;dirc = " /Volumes/RAID01/research/DATA/WRF/RAwork2/"

  ;init = (/"20160106","20160106-p01deg","20160106-p02deg","20160106-p03deg","20160106-p04deg","20160106-p05deg","20160106-p06deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p10deg","20160106-p20deg"/)
  init = (/"20160106"/)
  ;init = (/"20161014-v2"/)
  n_init = dimsizes(init)

  member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
  ;member = (/ "c00"/)
  n_member = dimsizes(member)

  n_skiptime = 1

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
  c_ilat  = new ( (/nlines/),"integer")
  c_ilon  = new ( (/nlines/),"integer")
  c_lat  = new ( (/nlines/),"float")
  c_lon  = new ( (/nlines/),"float")

;---Remember that fields start at 1, not 0.
  do nf=0,nfields-1
    fields(nf,:) = str_get_field(lines,nf+1,delim)    
    c_ilat = stringtointeger(fields(2,:))
    c_lat  = stringtofloat(fields(4,:))
    c_ilon = stringtointeger(fields(3,:))
    c_lon  = stringtofloat(fields(5,:))
  end do
    end if

  c_ttt=0

  do ii = 0,listnum-1,1

  filw = systemfunc("ls " + dirc + init(nnn) + "/" + member(mmm) + "/" + wrflist(ii))   ; or WRF_*grb
  f    = addfile (filw+".nc", "r")   ; note the "s" of addfile
  print("Now data is "+filw+".")

  dlat = wrf_user_getvar(f,"lat",0)  ; get all times in the file
  dlon = wrf_user_getvar(f,"lon",0)  ; get all times in the file
  lat  = dlat(:,0)
  lon  = dlon(0,:)
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

  times = wrf_user_getvar(f,"times",-1)  ; get all times in the file
  n_times = count_unique_values(times) ; number of times in the file 

  slp  = new ( (/24,nlat,nlon/),"float")
  olr  = new ( (/24,nlat,nlon/),"float")
  ;mdbz = new ( (/24,nlat,nlon/),"float")
  if(c_ttt.eq.0)then
  prec = new ( (/193,nlat,nlon/),"float")
  dammy = new ( (/193,nlat,nlon/),"float")
  end if

  if(n_times.eq.1)then
  C_time=0
  slp(0,:,:) = wrf_user_getvar(f,"slp",C_time ); (ncl_join,Time,bottom_top,south_north,west_east)
  wrf_smooth_2d( slp, 4 ) ; smooth slp 
  olr(0,:,:)   = wrf_user_getvar(f,"OLR",C_time)        ; u averaged to mass points
  ;mdbz(0,:,:)   = wrf_user_getvar(f,"mdbz",C_time)        ; u averaged to mass points
  dammy(c_ttt,:,:)   = wrf_user_getvar(f,"RAINNC",C_time)        ; u averaged to mass points

  else
  C_time=-1
  slp = wrf_user_getvar(f,"slp",C_time); (ncl_join,Time,bottom_top,south_north,west_east)
  wrf_smooth_2d( slp, 4 ) ; smooth slp 
  olr = wrf_user_getvar(f,"OLR",C_time) ; U component of the wind at 10m
  ;mdbz   = wrf_user_getvar(f,"mdbz",C_time)        ; u averaged to mass points
  dammy(c_ttt:c_ttt+23,:,:)   = wrf_user_getvar(f,"RAINNC",C_time)        ; u averaged to mass points
  end if
 

  do itt = 0, n_times-1, n_skiptime

   if(c_ttt.eq.0.)then
     prec(c_ttt,:,:) = dammy(c_ttt,:,:)
   else
     prec(c_ttt,:,:) = dammy(c_ttt,:,:)- dammy(c_ttt-n_skiptime,:,:)
   end if

; Set some basic resources
  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@NoHeaderFooter      = True            ; Switch headers and footers off
  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False       ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True        ; set True for native mapping

  res@tmXBLabelFontHeightF = 0.02
  res@tmYLLabelFontHeightF = 0.02


  res@gsnLeftStringFontHeightF = 0.02 
  res@gsnRightStringFontHeightF = 0.02 
  res@gsnLeftString   = times(itt)
  if(c_ttt.lt.10)then
  res@gsnRightString   = "f00"+c_ttt
  else if (c_ttt.ge.10.and.c_ttt.lt.100)then
  res@gsnRightString   = "f0"+c_ttt
  else if (c_ttt.ge.100)then
  res@gsnRightString   = "f"+c_ttt
  end if 
  end if
  end if

  wks01 = gsn_open_wks(type,"typhoon12-v2_PALI_"+init(nnn)+"_"+member(mmm)+"_"+times(itt))

  ; Generate contours.
     
  ; Plotting options for RV

      olr_opts = res 
      olr_opts@cnFillOn = True ; color contours 
      gsn_define_colormap(wks01,"MPL_Greys") ; choose a colormap 
      olr_opts@cnLevelSelectionMode  = "ManualLevels"   
      olr_opts@cnMinLevelValF        = 100
      olr_opts@cnMaxLevelValF        = 240
      olr_opts@cnLevelSpacingF       = 20
      olr_opts@cnLinesOn             = False            ; turn off contour lines
      olr_opts@lbLabelBarOn          = False
      olr_opts@cnLineLabelsOn       = False            ; turn off contour labels
      olr_opts@cnFillMode            = "RasterFill"

      ;rv_opts@cnInfoLabelOrthogonalPosF = 0.07 ; offset second label information 
      ;rv_opts@gsnContourLineThicknessesScale = 3.0
      olr_opts@cnInfoLabelOn       = False           ; turn off cn info label
      olr_opts@gsnLeftString   = ""
      olr_opts@gsnRightString   = ""
      olr_opts@tfDoNDCOverlay        = True            ; necessary for correct overlay on map

      olr_plot  = gsn_csm_contour_map(wks01,olr(itt,:,:),olr_opts)

      ; Plotting options for PREC

      prec_opts = res 
      prec_opts@cnFillOn = True ; color contours 
      prec_opts@cnLinesOn             = False            ; turn off contour lines
      prec_opts@cnLineLabelsOn       = False            ; turn off contour labels
     ; prec_opts@cnInfoLabelOn       = False           ; turn off cn info label
      prec_opts@cnFillMode            = "RasterFill"
      prec_opts@tmXBOn                  = False 
      prec_opts@tmYLOn                  = False
      prec_opts@tmYLLabelsOn            = False
      prec_opts@tmXBLabelsOn            = False

      cmap     := read_colormap_file("BlAqGrYeOrReVi200")
      cmap(0,:) = (/0,0,0,0/)    ; make first color fully transparent
      
      prec_opts@cnFillPalette        = cmap
      prec_opts@cnFillOpacityF       = 1.               ; .85 
      prec_opts@cnLevelSelectionMode  = "ManualLevels"   
      prec_opts@cnMinLevelValF        = 5
      prec_opts@cnMaxLevelValF        = 60
      prec_opts@cnLevelSpacingF       = 5
      prec_opts@tfDoNDCOverlay        = True            ; necessary for correct overlay on map

      prec_plot  = gsn_csm_contour(wks01,prec(c_ttt,:,:),prec_opts)

       overlay(olr_plot,prec_plot)
        draw(olr_plot)
        frame(wks01)
        delete(wks01)
       c_ttt=c_ttt+ n_skiptime


  end do




  end do





  end do
  end do

exit











end
