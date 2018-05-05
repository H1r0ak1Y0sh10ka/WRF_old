; This file is Draw Configuration.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; 05/05/2018 - 1st released
;
; contains: makedir
;
; makedir
; Usage: makedir(PATH)
; PATH (string): PATH of directory to want to make now.
; e.g. makedir("~/HOGE/HOGEHOGE/HOGEHOGE")
; ====================================================================================================

undef ( "Config_dbz_shade" )
function Config_dbz_shade (  \
  RES[*]           : logical \
  )
local none
begin

opts = True 
opts = RES
opts@cnFillOn             = True                   ; turn on color
opts@lbLabelAutoStride    = True                   ; nice label bar labels
opts@cnLinesOn            = False                  ; no contour lines

opts@lbOrientation        = "vertical"
opts@lbTitlePosition      = "Right"                           ; title location
opts@lbTitleDirection     = "Across"                          ; letter angle
opts@lbTitleAngleF        = 90.                               ; title angle
opts@lbTitleFontHeightF   = 0.015                              ; font height

opts@cnFillPalette        = "prcp_1"
opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
opts@cnMinLevelValF       =       5              ; set min contour level
opts@cnMaxLevelValF       =      55              ; set max contour level
opts@cnLevelSpacingF      =       5              ; set contour spacing

return( [/ opts /] )

end

undef ( "Config_rh_contour" )
function Config_rh_contour (  \
  RES[*]           : logical \
  )
local none
begin

opts = True 
opts = RES

opts@cnLineColor           = "black"   ; Set the line color
opts@cnInfoLabelOn         = False
opts@cnLineThicknessF      =  12
opts@gsnContourNegLineDashPattern  = 1 	; sets negative contours to dash pattern 1
opts@cnLineLabelInterval           = 1             ; default = 2
opts@cnLineLabelFontHeightF        = 0.025

opts@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
opts@cnMinLevelValF       =      10                ; set min contour level
opts@cnMaxLevelValF       =      90                ; set max contour level
opts@cnLevelSpacingF      =      10                ; set contour spacing

return( [/ opts /] )

end
