; This file contains various functions relating to TC Analyis.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; //2018 - Released
;
; contains:ReadTrackDataCSV 
;

; ====================================================================================================


;undef ( "ReadTrackDataCSV" )
;function rectangular2polar (  \
;  path[*]           : string \
;)

;local None
;return( [/ v_rad, v_theta /] )
;begin


undef ( "rectangular2polar" )
function rectangular2polar (  \
  data[*][*][*]      : numeric, \
  N_RADIUS[*]        : numeric, \
  N_ANGLE[*]         : numeric,  \
  N_CenterLAT[*]     : numeric,  \
  N_CenterLON[*]     : numeric  \
)
local none
begin

nlat          = dimsizes(data(0,:,0))
nlon          = dimsizes(data(0,0,:))
nlevs         = dimsizes(data(:,0,0))

angle_phi     = new( (/N_ANGLE/),"float")
cylind_x      = new( (/N_RADIUS+1,N_ANGLE/),"float")  ;cylindrical coordinate
cylind_y      = new( (/N_RADIUS+1,N_ANGLE/),"float")  ;cylindrical coordinate
data_cyclind  = new( (/nlevs,N_RADIUS+1,N_ANGLE/),"float") 

angle_div_deg = 360.0/int2flt(N_ANGLE)
pi            = 4.0*atan(1.0) 

  do na = 0,N_ANGLE-1
  angle=angle_div_deg*int2flt(na)
  angle_phi(na)=pi*(angle/180.0)
  end do

    do nr = 0,N_RADIUS,1
      do na = 0,N_ANGLE-1

      cylind_x(nr,na)=N_CenterLON + nr*cos(angle_phi(na))
      cylind_y(nr,na)=N_CenterLAT + nr*sin(angle_phi(na))
  
      X1=floattointeger(cylind_x(nr,na))
      X2=X1+1
      Y1=floattointeger(cylind_y(nr,na))
      Y2=Y1+1
      DX=abs(cylind_x(nr,na)-X1)
      DY=abs(cylind_y(nr,na)-Y1)

      if(X1.ge.0.and.X1.le.(nlon-1).and.X2.ge.0.and.X2.le.(nlon-1).and.Y1.ge.0.and.Y1.le.(nlat-1).and.Y1.ge.0.and.Y2.le.(nlat-1))then
      data_cyclind(:,nr,na) = (1-DX)*( (1-DY)*data(:,Y1,X1) + DY*data(:,Y2,X1) )   \
                                        + DX*((1-DY)*data(:,Y1,X2) + DY*data(:,Y2,X2) )
      else
      data_cyclind(:,nr,na) = data@_FillValue
      end if
    
      end do ; na loop
    end do ; nr loop
    
data_cyclind@units = data@units
data_cyclind!2="radius" 
data_cyclind!3="theta" 
return( [/ data_cyclind /] )

end

undef ( "rectangular2polar_test" )
function rectangular2polar_test (  \
  data               : numeric, \
  N_RADIUS[*]        : numeric, \
  N_ANGLE[*]         : numeric,  \
  N_CenterLAT[*]     : numeric,  \
  N_CenterLON[*]     : numeric  \
)
local none
begin

if(dimsizes(getvardims(data)).eq.2)then
nlat          = dimsizes(data(:,0))
nlon          = dimsizes(data(0,:))
nlevs         = 1
ndata         = new ( (/nlevs,nlat,nlon/),"float")
ndata         = data
else if(dimsizes(getvardims(data)).eq.3)then
nlat          = dimsizes(data(0,:,0))
nlon          = dimsizes(data(0,0,:))
nlevs         = dimsizes(data(:,0,0))
ndata         = data
end if
end if

angle_phi     = new( (/N_ANGLE/),"float")
cylind_x      = new( (/N_RADIUS+1,N_ANGLE/),"float")  ;cylindrical coordinate
cylind_y      = new( (/N_RADIUS+1,N_ANGLE/),"float")  ;cylindrical coordinate
data_cyclind  = new( (/nlevs,N_RADIUS+1,N_ANGLE/),"float") 

angle_div_deg = 360.0/int2flt(N_ANGLE)
pi            = 4.0*atan(1.0) 

  do na = 0,N_ANGLE-1
  angle=angle_div_deg*int2flt(na)
  angle_phi(na)=pi*(angle/180.0)
  end do

    do nr = 0,N_RADIUS,1
      do na = 0,N_ANGLE-1

      cylind_x(nr,na)=N_CenterLON + nr*cos(angle_phi(na))
      cylind_y(nr,na)=N_CenterLAT + nr*sin(angle_phi(na))
  
      X1=floattointeger(cylind_x(nr,na))
      X2=X1+1
      Y1=floattointeger(cylind_y(nr,na))
      Y2=Y1+1
      DX=abs(cylind_x(nr,na)-X1)
      DY=abs(cylind_y(nr,na)-Y1)

      if(X1.ge.0.and.X1.le.(nlon-1).and.X2.ge.0.and.X2.le.(nlon-1).and.Y1.ge.0.and.Y1.le.(nlat-1).and.Y1.ge.0.and.Y2.le.(nlat-1))then
      data_cyclind(:,nr,na) = (1-DX)*( (1-DY)*ndata(:,Y1,X1) + DY*ndata(:,Y2,X1) )   \
                                        + DX*((1-DY)*ndata(:,Y1,X2) + DY*ndata(:,Y2,X2) )
      else
      data_cyclind(:,nr,na) = data@_FillValue
      end if
    
      end do ; na loop
    end do ; nr loop
    
data_cyclind@units = data@units
data_cyclind!2="radius" 
data_cyclind!3="theta" 
return( [/ data_cyclind /] )

end
