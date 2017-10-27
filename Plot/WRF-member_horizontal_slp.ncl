
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;  a = addfile("~/model/ensemble-v2/20160106/c00/wrfout_d01_2016-01-10_00:00:00.nc","r")

  init = 20160912
 ; dirc = " /Volumes/HDD01/reseach/DATA/analysis/WRF/PALI/"
 ; dirc = " /Volumes/RAID01/research/DATA/WRF/PALI-v2/"
  dirc = " /Volumes/RAID01/research/DATA/WRF/MALAKAS/"
  dirw = dirc + init + "/???/"    ; input directory
  cccc = dirc + init + "/c00/"    ; input directory

  ;dirw = " ~/model/ensemble-v2/" + init + "/???/"    ; input directory
  ;cccc = " ~/model/ensemble-v2/" + init + "/c00/"    ; input directory

  wrflist = systemfunc("basename " + cccc +"wrfout*")
  listnum = stringtointeger(systemfunc("ls -l " + cccc +"wrfout* | wc -l"))
 ; numout  = stringtointeger(listnum)
  print(listnum)

  member = new(11,string)
  member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
 type = "eps"
; type = "png"

; Set some basic resources
  res = True
  res@NoHeaderFooter           = True            ; Switch headers and footers off

  mpres = True
  dttt = 0

   c_ilat  = new ( (/11,169/),"integer")
   c_ilon  = new ( (/11,169/),"integer")
   c_lat  = new ( (/11,169/),"float")
   c_lon  = new ( (/11,169/),"float")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do ii = 0,listnum-1;,5

  filw = systemfunc("ls " + dirw + wrflist(ii))   ; or WRF_*grb
  f    = addfiles (filw+".nc", "r")   ; note the "s" of addfile
  ListSetType (f, "join")
  print(filw)

  dlat = wrf_user_getvar(f[0],"lat",0)  ; get all times in the file
  dlon = wrf_user_getvar(f[0],"lon",0)  ; get all times in the file
  lat  = dlat(:,0)
  lon  = dlon(0,:)
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)
   land = f[0]->LANDMASK(0,:,:)

  slpd = wrf_user_getvar(f,"slp",-1)
          ;printVarSummary (slpd) ; (ncl_join,Time,bottom_top,south_north,west_east)
  wrf_smooth_2d( slpd, 4 ) ; smooth slp 
          ;printVarSummary (slpd) ; (ncl_join,Time,bottom_top,south_north,west_east)

 

  times = wrf_user_getvar(f[0],"times",-1)  ; get all times in the file
  ntimes = dimsizes(times) ; number of times in the file 

  plots = new ( 12, graphic )




  do it = 0,ntimes-1,1
    iplot = 0
 
    do mem = 0,10

    if(dttt.eq.0)then
     trackdata = "/Volumes/HDD01/reseach/ncl/wrf/track/MALAKAS_"+init+"_"+member(mem)+"-track_v21.csv"
    print(trackdata)
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
;---Remember that fields start at 1, not 0.
  do nf=0,nfields-1
    fields(nf,:) = str_get_field(lines,nf+1,delim)    
    c_ilat(mem,:) = stringtointeger(fields(2,:))
    c_lat(mem,:)  = stringtofloat(fields(4,:))
    c_ilon(mem,:) = stringtointeger(fields(3,:))
    c_lon(mem,:)  = stringtofloat(fields(5,:))
  end do
    end if

      wks01 = gsn_open_wks(type,"slp-v2_MALAKAS_"+init+"_"+member(mem)+"_"+times(it))
      gsn_define_colormap(wks01,"GMT_gray")  ; overwrite the .hluresfile color map

       if( mem .le. 10)then
       ;wrf_smooth_2d( slpd(mem,it,:,:), 3 ) ; smooth slp 
       slp   = slpd(mem,it,:,:)   ; average over all ensemble members
       mmm = iplot
       end if
       
       if( mem .eq. 11)then 
       ;wrf_smooth_2d( slpmean(it,:,:), 3 ) ; smooth slp 
       slp   = slpmean(it,:,:)   ; average over all ensemble members
      ; spd   = spdmean(it,:,:)   ; average over all ensemble members
       mmm = iplot - 1
       end if

      ;spd@description = "Wind Speed" 
      ;spd@units = "m/s" 

      ; Generate contours.

      ; Plotting options for SLP 

      slp_opts = res 
      slp_opts@gsnDraw             = False             ; Turn off draw.
      slp_opts@gsnFrame            = False
        slp_opts@tmXBMode        = "Manual"
        slp_opts@tmYLMode        = "Manual"
        slp_opts@tmXBLabelFontHeightF = 0.02
        slp_opts@tmYLLabelFontHeightF = 0.02

      slp_opts@cnFillOn = False ; color contours 
      slp_opts@cnLineColor = "Black" 
      ;slp_opts@cnHighLabelsOn = True 
      ;slp_opts@cnLowLabelsOn = True
      slp_opts@cnConstFLabelFontHeightF = 0.08
      slp_opts@cnLineLabelFontHeightF = 0.03

      slp_opts@ContourParameters = (/ 960., 1040., 4. /) 
      slp_opts@cnLineLabelBackgroundColor = -1 
      slp_opts@gsnContourLineThicknessesScale = 3.0 
      slp_opts@mpOceanFillColor       = "cyan"   ;5            ; array index in color map
      slp_opts@mpLandFillColor        = "darkgreen"   ;164          ; for land, ocean, and inland h20


;---Necessary for contours to be overlaid correctly on WRF projection
  slp_opts@tfDoNDCOverlay       = True
  slp_opts@gsnAddCyclic         = False
;---Set map resources based on projection on WRF output file
  slp_opts = wrf_map_resources(f[0],slp_opts)
;---Call plotting routine which draws contours over a map
  nl   = 0    ; bottomost level
  plot = gsn_csm_contour_map(wks01,slp,slp_opts)




      ;  pmres                  = True
      ;  pmres@gsMarkerIndex    = 16
      ;  pmres@gsMarkerSizeF    = 0.04
      ;  pmres@gsMarkerColor    = "deepskyblue"
      ;  print(c_lon(mem,dttt)+","+c_lat(mem,dttt))
       ; gsn_polymarker(wks01, plots(iplot), c_lon(mem,it), c_lat(mem,it), pmres)
      ;  plot_mark = gsn_add_polymarker(wks01, plots(iplot), c_lon(mem,dttt), c_lat(mem,dttt), pmres)
        

      ;  overlay(plot,lplot)
        draw(plot)
        frame(wks01)
        delete(wks01)
        iplot = iplot + 1
          end do

   dttt = dttt + 1
  ; Panel the WRF plots.
;    pnlres                            = True
;    pnlres@gsnMaximize             = True
;    pnlres@txString                   = t@description + "  (" + t@units + ")"
;    pnlres@gsnPanelYWhiteSpacePercent = 10       ; Add white space b/w plots.
;    pnlres@gsnPanelLabelBar           = True    ; Turn on common labelbar
;    pnlres@lbLabelAutoStride          = True    ; Spacing of lbar labels.
;    pnlres@lbBoxMinorExtentF          = 0.13

;   gsn_panel(wks01,(/plots/),(/3,4/),pnlres)
 ;  draw(plots)
;   delete(wks01)
  end do
 

  end do

end

