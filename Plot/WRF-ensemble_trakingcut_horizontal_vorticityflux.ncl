
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;  a = addfile("~/model/ensemble-v2/20160106/c00/wrfout_d01_2016-01-10_00:00:00.nc","r")

;********** control part **********

  WORK = "/Volumes/Yoshi-HDD01"
  DATA = "/Volumes/Yoshi-HDD01"
  ;trackdata = "/Volumes/HDD01/reseach/ncl/wrf/track/PALI_"+init+"_"+member(mem)+"-track_v25.csv"
  ;dirc = " /Volumes/RAID01/research/DATA/WRF/PALI-v2/"
   dirc = DATA+ "/research/DATA/WRF/PALI-v2/"

  ;init = (/"20160106","20160106-p01deg","20160106-p02deg","20160106-p03deg","20160106-p04deg","20160106-p05deg","20160106-p06deg","20160106-p07deg","20160106-p08deg","20160106-p09deg","20160106-p10deg","20160106-p20deg"/)
  init = (/"20160106"/)
  n_init = dimsizes(init)
  ;member = (/"p01"/)
  member = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)
  n_member = dimsizes(member)
  ;n_member = 1

  n_skiptime = 1
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
   
     trackdata = WORK+"/research/ncl/wrf/track/PALI_"+init(nnn)+"_"+member(mmm)+"-track_v25.csv"
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
  delete([/sigma,dlon,dlat/])

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

  uu  = new ( (/nz,nlat,nlon/),"float")
  vv  = new ( (/nz,nlat,nlon/),"float")
  ww  = new ( (/nz,nlat,nlon/),"float")
  zz  = new ( (/nz,nlat,nlon/),"float")
  times = new ( (/n_timestep/),"string")

  ;p_3levs  = new ( (/3/),"float")
  ;p_3levs  = (/925.,850.,700./)
  ;p_3levs  = new ( (/3/),"float")
  zlevs  = (/1000./)
  n_zlevs = dimsizes(zlevs)

  u_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  v_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  w_levs  = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  rv_levs = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")
  div_levs = new ( (/n_timestep,n_zlevs,nlat,nlon/),"float")

  c_ttt=0

  do iii =0,listnum-1,1
  print("Now reading file is "+filw(iii))

  timesd = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(timesd) ; number of times in the file 

    do it = 0,n_times-1,n_skiptime 
     uu  = wrf_user_getvar(f[iii],"ua",it)        ; u averaged to mass points
     vv  = wrf_user_getvar(f[iii],"va",it)        ; v averaged to mass points
     ww  = wrf_user_getvar(f[iii],"wa",it)        ; w averaged to mass points
     zz  = wrf_user_getvar(f[iii],"z",it) ; pressure is our vertical coordinate
     times(c_ttt)     = timesd(it)  ; get all times in the file

     w_levs(c_ttt,0,:,:)   = wrf_user_intrp3d(ww(:,:,:),zz(:,:,:),"h", zlevs ,0.,False)
     u_levs(c_ttt,0,:,:)   = wrf_user_intrp3d(uu(:,:,:),zz(:,:,:),"h", zlevs ,0.,False)
     v_levs(c_ttt,0,:,:)   = wrf_user_intrp3d(vv(:,:,:),zz(:,:,:),"h", zlevs ,0.,False)
     rv_levs(c_ttt,0,:,:)  = uv2vr_cfd (u_levs(c_ttt,0,:,:) ,v_levs(c_ttt,0,:,:) ,lat,lon, 3) 
     div_levs(c_ttt,0,:,:) = uv2dv_cfd (u_levs(c_ttt,0,:,:) ,v_levs(c_ttt,0,:,:) ,lat,lon, 3)  

     c_ttt=c_ttt+n_skiptime 

     end do ;;;it loop


  end do ; iii loop

  divrv  = new ( (/c_ttt,n_zlevs,nlat,nlon/), "float")
  divrv_grid   = new ( (/c_ttt,n_zlevs,n_grid,n_grid/),"float")

  ;outline = new(c_ttt,string)

  X_LABEL = (fspan( (-1*(dx*0.001)*r_grid),((dx*0.001)*r_grid),((n_grid-1)/5)+1) )
  Y_LABEL = (fspan( (-1*(dy*0.001)*r_grid),((dy*0.001)*r_grid),((n_grid-1)/5)+1) )

  do it =0,c_ttt-1,1
  print("Now caliculate time is "+times(it))

  divrv = rv_levs*div_levs*(-1)
  divrv_grid (it,0,:,:)= divrv(it,0,c_ilat(mmm,it)-r_grid:c_ilat(mmm,it)+r_grid,c_ilon(mmm,it)-r_grid:c_ilon(mmm,it)+r_grid)

  print("Now drawing time is "+times(it))

;************************************************
; create plot
;************************************************

; Set some basic resources
  wks01 = gsn_open_wks(type,"./WRF-vorticityflux-horizontal-v1_PALI_"+init(nnn)+"_"+member(mmm)+"-trackingcut_"+times(it))

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@lbLabelBarOn        = True           ; turn off individual cb's
;  res@gsnLeftString   = "Contour:Mean, Shaded:Spread"


  if(it.lt.10)then
  res@gsnRightString   = "f00"+it+"/"+times(it)
  else if (it.ge.10.and.it.lt.100)then
  res@gsnRightString   = "f0"+it+"/"+times(it)
  else if (it.ge.100)then
  res@gsnRightString   = "f"+it+"/"+times(it)
  end if 
  end if
  end if

  res@gsnLeftString            = "Shade:"

  res@tmXBMode = "Explicit"
  res@tmXBValues = ispan(0,n_grid-1,5)
  res@tmXBLabels = X_LABEL
  res@tmYLMode = "Explicit"
  res@tmYLValues = ispan(0,n_grid-1,5)
  res@tmYLLabels = Y_LABEL
  res@tiXAxisString        = "DX(km)"  
  res@tiYAxisString        = "DY(km)" 

  gsn_define_colormap(wks01,"CBR_coldhot") ; choose a colormap 
  hadv_opts = True 
  hadv_opts = res
  hadv_opts@cnFillOn          = True                   ; turn on color
  hadv_opts@gsnSpreadColors   = True                   ; use full range of color map
  hadv_opts@lbLabelAutoStride = True                   ; nice label bar labels
  hadv_opts@cnLinesOn         = False                  ; no contour lines
  hadv_opts@cnInfoLabelOn     = False                  ; turn off cn info label

  hadv_opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  hadv_opts@cnMinLevelValF       =  -0.0000001                  ; set min contour level
  hadv_opts@cnMaxLevelValF       =   0.0000001                   ; set max contour level
  hadv_opts@cnCenterLevelValF    =   0 
  hadv_opts@cnLevelSpacingF      =   0.00000001                ; set contour spacing
  hadv_opts@lbTopMarginF = 0.15
  hadv_opts@lbBottomMarginF = 0.4
  hadv_opts@lbOrientation   = "vertical"
  ;rv_opts@lbTitleString = "Shaded,Tangentical wind(m/s)"
  hadv_opts@lbTitlePosition      = "Right"                           ; title location
  hadv_opts@lbTitleDirection     = "Across"                          ; letter angle
  hadv_opts@lbTitleAngleF        = 90.                               ; title angle
  hadv_opts@lbTitleFontHeightF   = 0.03                              ; font height

   plot = gsn_csm_contour(wks01, divrv_grid(it,0,:,:),hadv_opts) 

  draw(plot)
  frame(wks01)






  end do



  end do  ; mmm loop


  
  end do ; nnn loop
exit











end




