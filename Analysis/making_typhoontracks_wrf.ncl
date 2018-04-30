;********************************************************
; Making typhoon track data from wrfout files.
;********************************************************
;
; May 07, 2017/1st modified  
; Hiroaki YOSHIOKA (Kyoto University)
; 
; ===========================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "./Tools.ncl"
begin
;

;********** Part - Enter Constant, Directory, NAME and so on **********

  TY_NAME = "PALI"

  WRF_DIRC   = "/Volumes/RAID01/research/DATA/WRF/PALI-v2/"    ; WRF_DIRC = "/Volumes/Yoshi-HDD01"
  OUT_DIRC   = "/Volumes/HDD01/research/ncl/wrf/track/"+TY_NAME+"/"

  INIT  = (/"20160106"/)

  MEMBER = (/ "c00", "p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10" /)

 ;RULE = "01" ; 01 is  track of maximum relative voriticity on 850 hPa
  RULE = "02" ; 02 is  track of minimum sea level pressure

  S_DIS = 15 ; search grid number from the previous point 
  S_RAD = 10 ; parameter mean_radius grids and grids of edge

;********** Part - Calculate dimensions and Define directory from constant (do NOT change!!!) **********

  n_INIT   = dimsizes(INIT)
  n_MEMBER = dimsizes(MEMBER)
  makedir(OUT_DIRC)

;*************************************************************************************

  do nnn = 0,n_INIT-1 ; number of initial times

  dirw = WRF_DIRC + INIT(0) +"/"    ; input directory
  wrflist = systemfunc("basename " + dirw + MEMBER(0) + "/wrfout*")
  listnum = stringtointeger(systemfunc("ls -l " + dirw + MEMBER(0) + "/wrfout* | wc -l"))

  dtt = 0
  dirw = WRF_DIRC + INIT(nnn) +"/"    ; input directory
  filw = systemfunc("ls " + dirw + MEMBER(0) + "/wrfout*")   ; or WRF_*grb
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
   delete(sigma)

  n_timestep=0
  do iii = 0,listnum-1,1
  dtimes = wrf_user_getvar(f[iii],"times",-1)  ; get all times in the file
  n_times = count_unique_values(dtimes) ; number of times in the file 
  n_timestep=n_timestep+n_times
  end do ; iii loop

  times     = new(n_timestep,string) ;1 hourly data of 7days forecast
  outline01 = new(n_timestep,string)

   if(RULE.eq."01")then
   uu  = new ( (/nz,nlat,nlon/),"float")
   vv  = new ( (/nz,nlat,nlon/),"float")
   pp  = new ( (/nz,nlat,nlon/),"float")
   else if(RULE.eq."02")then
   slp  = new ( (/nlat,nlon/),"float")
   end if
   end if
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  stt  = 0

  para01 = new ( (/n_MEMBER,n_timestep,nlat,nlon/),"float")

  do ii = 0,n_MEMBER-1,1  ; number of MEMBERs 


;********************************************************
; Section : Reading all time steps from all wrfout files.
;********************************************************

  filw = systemfunc("ls " + dirw + MEMBER(ii) + "/wrfout*")   ; or WRF_*grb
  f    = addfiles (filw+".nc", "r")   ; note the "s" of addfile
  ListSetType (f, "join")

  if(ii.eq.0)then
  var1 = wrf_user_getvar(f[0],"HGT_M",0)
  lat1 = wrf_user_getvar(f[0],"XLAT",0)
  lon1 = wrf_user_getvar(f[0],"XLONG",0)
  var1@lat2d = lat1
  var1@lon2d = lon1
  dom_dims = dimsizes(var1)
  dom_rank = dimsizes(dom_dims)
  nx1 = dom_dims(dom_rank - 1) - 1
  ny1 = dom_dims(dom_rank - 2) - 1
  end if

;********************************************************
; Section : Reading basis parameter from wrfout files.
;********************************************************

  ttt = 0

  do jj = 0,listnum-1 ; number of data file by one MEMBER
 
  print("Now file is "+filw(jj))

  timesd = wrf_user_getvar(f[jj],"times",-1)  ; get all times in the file
  if( jj.ne.listnum-1)then
  ntimes = dimsizes(timesd) ; number of times in the file 
  end if 
  if(jj.eq.listnum-1)then
  ntimes = 1
  end if
  
    do it = 0,ntimes-1

     times(ttt)     = timesd(it)  ; time
     if(RULE.eq."01")then
             pp  = wrf_user_getvar(f[jj],"pressure",it) ; pressure is our vertical coordinate
             uu  = wrf_user_getvar(f[jj],"ua",it)        ; u averaged to mass points
             vv  = wrf_user_getvar(f[jj],"va",it)        ; v averaged to mass points
             pressure = 850.   ; 850 hPa
             u850   = wrf_user_intrp3d(uu,pp,"h",pressure,0.,False)
             v850   = wrf_user_intrp3d(vv,pp,"h",pressure,0.,False)
             para01(ii,ttt,:,:)  = uv2vr_cfd (u850,v850,lat,lon, 3) 
             wrf_smooth_2d(para01(ii,ttt,:,:),100)

     else if(RULE.eq."02")then
             slp  = wrf_user_getvar(f[jj],"slp",it) ; pressure is our vertical coordinate
             para01(ii,ttt,:,:)  = slp
             wrf_smooth_2d(para01(ii,ttt,:,:),100)

     end if
     end if

     ttt = ttt +1
    end do ;;; it loop
   end do ;;; jj loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 timestep_num = new((/n_timestep/),integer)
 lat_num  = new((/n_timestep/),float)
 lon_num  = new((/n_timestep/),float)
 lat_deg  = new((/n_timestep/),float)
 lon_deg  = new((/n_timestep/),float)
 c_para   = new((/n_timestep/),float)

  outfile = (OUT_DIRC+"trackdata-v"+RULE+"_"+TY_NAME+"_"+INIT(nnn)+"_"+MEMBER(ii)+".csv")

ret = systemfunc("test -e "+outfile+"; echo $?")
if(ret .eq. 0) then
print("--> "+outfile+": exists: delete") ;-- do what you want to do
system("rm -f " + outfile)
else if(ret .eq.1) then
print("--> "+outfile+": doesn't exist: create")   ;-- create the desired directory
end if
end if

  CHECK_FLAG = 0

 do it = 0,ttt-1
 
  timestep_num(it) = it 

;********************************************************
; RULE 01 Section : Searching point of TC every time steps.
;********************************************************

  if(RULE.eq."01")then

  para_mean = new((/nlat,nlon/),float)

            do iy = 0,nlat-1
              do ix = 0,nlon-1
                    if(iy-S_RAD.ge.0.and.iy+S_RAD.le.nlat-1) then
                    if(ix-S_RAD.ge.0.and.ix+S_RAD.le.nlon-1) then
                    para_mean(iy,ix) = avg(para01(ii,it,iy-S_RAD:iy+S_RAD,ix-S_RAD:ix+S_RAD)) 
                    else
                    para_mean(iy,ix) =  default_fillvalue("float")
                    end if
                    else
                    para_mean(iy,ix) =  default_fillvalue("float")
                    end if
               end do
             end do
 

  if(it.gt.0.)then
             do iy = 0,nlat-1,1
              do ix = 0,nlon-1,1

                    iyy = abs(bi_lat - iy) 
                    ixx = abs(bi_lon - ix)

                    if(iyy.gt.S_DIS.or.ixx.gt.S_DIS)then
                    delete(para_mean(iy,ix))
                    para_mean(iy,ix) =  default_fillvalue("float")
                    end if 
               end do
             end do
  end if

       dims = dimsizes(para_mean)
       x1d  = ndtooned(para_mean)      ; convert 2D array to 1D for use in maxind
       inds = ind_resolve(maxind (x1d), dims)    ; convert 1D array back to 2D 
       ilat = inds(0,0)        ; select the latitude index where the X array is at its' maximum  
       ilon = inds(0,1)        ; select the longitude index where the X array is at its' maximum

     if (CHECK_FLAG.eq.0)then

             if(ilat.ge.S_RAD-1.and.ilat.le.nlat-S_RAD-1.and.ilon.ge.S_RAD-1.and.ilon.le.nlon-S_RAD-1)then

              lat_num(it) = ilat
              lon_num(it) = ilon
              lat_deg(it) = lat(ilat)   ; insert the latitude index into the lat coordinate variable
              lon_deg(it) = lon(ilon)   ; insert the longitude index into the lon coordinate variable
              c_para(it)  = para_mean(ilat,ilon)
     
              else

              lat_num(it) = ilat@_FillValue   ; insert the latitude index into the lat coordinate variable
              lon_num(it) = ilon@_FillValue   ; insert the longitude index into the lon coordinate variable
              lat_deg(it) = lat@_FillValue   ; insert the latitude index into the lat coordinate variable
              lon_deg(it) = lon@_FillValue   ; insert the longitude index into the lon coordinate variable

              c_para(it)  = para_mean@_FillValue
              CHECK_FLAG = 100

              end if

     else if (CHECK_FLAG.ne.0)then

       lat_num(it) = ilat@_FillValue   ; insert the latitude index into the lat coordinate variable
       lon_num(it) = ilon@_FillValue   ; insert the longitude index into the lon coordinate variable
       lat_deg(it) = lat@_FillValue   ; insert the latitude index into the lat coordinate variable
       lon_deg(it) = lon@_FillValue   ; insert the longitude index into the lon coordinate variable
       c_para(it)  = para_mean@_FillValue
       CHECK_FLAG = 100

     end if
     end if
     delete(para_mean)

;********************************************************
; RULE 02 Section : Searching point of TC every time steps.
;********************************************************

     else if(RULE.eq."02")then
   
     para_dam = new((/nlat,nlon/),float)
     para_dam = para01(ii,it,:,:)

  if(it.gt.0.)then
             do iy = 0,nlat-1,1
              do ix = 0,nlon-1,1

                    iyy = abs(bi_lat - iy) 
                    ixx = abs(bi_lon - ix)

                    if(iyy.gt.S_DIS.or.ixx.gt.S_DIS)then
                    delete(para_dam(iy,ix))
                    para_dam(iy,ix) =  default_fillvalue("float")
                    end if 
               end do
             end do
  end if

       dims = dimsizes(para_dam)
       x1d  = ndtooned(para_dam)      ; convert 2D array to 1D for use in maxind
       inds = ind_resolve(minind (x1d), dims)    ; convert 1D array back to 2D 
       ilat = inds(0,0)        ; select the latitude index where the X array is at its' minimum  
       ilon = inds(0,1)        ; select the longitude index where the X array is at its' minimum

     if (CHECK_FLAG.eq.0)then

             if(ilat.ge.S_RAD-1.and.ilat.le.nlat-S_RAD-1.and.ilon.ge.S_RAD-1.and.ilon.le.nlon-S_RAD-1)then

              lat_num(it) = ilat
              lon_num(it) = ilon
              lat_deg(it) = lat(ilat)   ; insert the latitude index into the lat coordinate variable
              lon_deg(it) = lon(ilon)   ; insert the longitude index into the lon coordinate variable
              c_para(it)  = para_dam(ilat,ilon)
     
              else

              lat_num(it) = ilat@_FillValue   ; insert the latitude index into the lat coordinate variable
              lon_num(it) = ilon@_FillValue   ; insert the longitude index into the lon coordinate variable
              lat_deg(it) = lat@_FillValue   ; insert the latitude index into the lat coordinate variable
              lon_deg(it) = lon@_FillValue   ; insert the longitude index into the lon coordinate variable

              c_para(it)  = para_dam@_FillValue
              CHECK_FLAG = 100

              end if

     else if (CHECK_FLAG.ne.0)then

       lat_num(it) = ilat@_FillValue   ; insert the latitude index into the lat coordinate variable
       lon_num(it) = ilon@_FillValue   ; insert the longitude index into the lon coordinate variable
       lat_deg(it) = lat@_FillValue   ; insert the latitude index into the lat coordinate variable
       lon_deg(it) = lon@_FillValue   ; insert the longitude index into the lon coordinate variable
       c_para(it)  = para_dam@_FillValue
       CHECK_FLAG = 100

     end if
     end if
     delete(para_dam)



     end if
     end if

       bi_lat = ilat
       bi_lon = ilon
 

 end do ; it loop
 delete(bi_lat)
 delete(bi_lon)


;********************************************************
;Section : Writing csv file.
;********************************************************

  dq = str_get_dq()                ; double quote character
 
   ;---Create dummy mixed data to write to CSV file
  if(RULE.eq."01")then
  fields = (/"Real time","Forecast time","nLat","nLon","Lat","Lon","RV850"/)
  else if(RULE.eq."02")then
  fields = (/"Real time","Forecast time","nLat","nLon","Lat","Lon","c_slp"/)
  end if
  end if

  fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated
  write_table(outfile, "w", header, "%s")   ; Write header to CSV file.
  a_list = [/times, timestep_num, lat_num, lon_num, lat_deg, lon_deg, c_para/]
  write_table (outfile, "a", a_list, "%s,%i,%f,%f,%f,%f,%f")

 end do ; ii loop

end do ;; nnn loop

exit
end



