; This file contains various functions relating to TC Analyis.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; //2018 - Released
;
; contains:ReadTrackDataCSV 
;

; ====================================================================================================


undef ( "ReadTrackDataCSV" )
function rectangular2polar (  \
  path[*]           : string \
)

local None
return( [/ v_rad, v_theta /] )
begin


undef ( "rectangular2polar" )
function rectangular2polar (  \
  nlat[*]           : numeric, \
  nlon[*]           : numeric, \
  nangle[*]         : numeric, \
)
local None

begin

    do na = 0,N_ANGLE-1
    Angle=angle_div_deg*int2flt(na)
    angle_phi(na)=pi*(Angle/180.0)
    end do

    do nr = 0,N_RADIUS,1
    do na = 0,N_ANGLE-1

    Cylind_x(nr,na)=c_ilon(mmm,c_ttt)+ nr*cos(angle_phi(na))
    Cylind_y(nr,na)=c_ilat(mmm,c_ttt)+ nr*sin(angle_phi(na))
  
    X1=floattointeger(Cylind_x(nr,na))
    X2=X1+1
    Y1=floattointeger(Cylind_y(nr,na))
    Y2=Y1+1
    DX=abs(Cylind_x(nr,na)-X1)
    DY=abs(Cylind_y(nr,na)-Y1)

    if(X1.ge.0.and.X1.le.(nlon-1).and.X2.ge.0.and.X2.le.(nlon-1).and.Y1.ge.0.and.Y1.le.(nlat-1).and.Y1.ge.0.and.Y2.le.(nlat-1))then
      rho_cyclind(mmm,c_ttt,:,nr,na) = (1-DX)*( (1-DY)*rho_levs(c_ttt,:,Y1,X1) + DY*rho_levs(c_ttt,:,Y2,X1) )   \
                                        + DX*((1-DY)*rho_levs(c_ttt,:,Y1,X2) + DY*rho_levs(c_ttt,:,Y2,X2) )
    else
      rho_cyclind(mmm,c_ttt,:,nr,na) = rho_cyclind@_FillValue
    end if
    
    end do ; na loop
    end do ; nr loop

end
