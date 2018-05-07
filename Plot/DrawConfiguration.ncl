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
procedure Config_dbz_shade (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnFillOn             = True                   ; turn on color
RES@lbLabelAutoStride    = True                   ; nice label bar labels
RES@cnLinesOn            = False                  ; no contour lines

RES@lbOrientation        = "vertical"
RES@lbTitlePosition      = "Right"                           ; title location
RES@lbTitleDirection     = "Across"                          ; letter angle
RES@lbTitleAngleF        = 90.                               ; title angle
RES@lbTitleFontHeightF   = 0.015                              ; font height

RES@cnFillPalette        = "prcp_1"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       5              ; set min contour level
RES@cnMaxLevelValF       =      55              ; set max contour level
RES@cnLevelSpacingF      =       5              ; set contour spacing

end

undef ( "Config_dbzSprd_shade" )
procedure Config_dbzSprd_shade (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnFillOn             = True                   ; turn on color
RES@lbLabelAutoStride    = True                   ; nice label bar labels
RES@cnLinesOn            = False                  ; no contour lines

RES@lbOrientation        = "vertical"
RES@lbTitlePosition      = "Right"                           ; title location
RES@lbTitleDirection     = "Across"                          ; letter angle
RES@lbTitleAngleF        = 90.                               ; title angle
RES@lbTitleFontHeightF   = 0.015                              ; font height

RES@cnFillPalette        = "precip2_17lev"
;RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
;RES@cnMinLevelValF       =       5              ; set min contour level
;RES@cnMaxLevelValF       =      55              ; set max contour level
;RES@cnLevelSpacingF      =       5              ; set contour spacing

end

undef ( "Config_rh_contour" )
procedure Config_rh_contour (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnLineColor                   = "black"                ; Set the line color
RES@cnInfoLabelOn                 = False
RES@cnLineThicknessF              =  12
RES@gsnContourNegLineDashPattern  = 1                      ; sets negative contours to dash pattern 1
RES@cnLineLabelInterval           = 1                      ; default = 2
RES@cnLineLabelFontHeightF        = 0.025

RES@cnLevelSelectionMode          = "ManualLevels"         ; set manual contour levels
RES@cnMinLevelValF                =      10                ; set min contour level
RES@cnMaxLevelValF                =      90                ; set max contour level
RES@cnLevelSpacingF               =      10                ; set contour spacing

end

undef ( "Config_vt_contour" )
procedure Config_vt_contour (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnLineColor                   = "black"                ; Set the line color
RES@cnInfoLabelOn                 = False
RES@cnLineThicknessF              =  12
RES@gsnContourNegLineDashPattern  = 1                      ; sets negative contours to dash pattern 1
RES@cnLineLabelInterval           = 1                      ; default = 2
RES@cnLineLabelFontHeightF        = 0.025

RES@cnLevelSelectionMode          = "ManualLevels"         ; set manual contour levels
RES@cnMinLevelValF                =       5                ; set min contour level
RES@cnMaxLevelValF                =      55                ; set max contour level
RES@cnLevelSpacingF               =       5                ; set contour spacing

end

undef ( "Config_h_diabatic_shade" )
procedure Config_h_diabatic_shade (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnFillOn             = True                   ; turn on color
RES@lbLabelAutoStride    = True                   ; nice label bar labels
RES@cnLinesOn            = False                  ; no contour lines

RES@lbOrientation        = "vertical"
RES@lbTitlePosition      = "Right"                           ; title location
RES@lbTitleDirection     = "Across"                          ; letter angle
RES@lbTitleAngleF        = 90.                               ; title angle
RES@lbTitleFontHeightF   = 0.015                              ; font height

RES@cnFillPalette        = "WhiteBlueGreenYellowRed"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       0              ; set min contour level
RES@cnMaxLevelValF       =       10             ; set max contour level
RES@cnLevelSpacingF      =       1            ; set contour spacing

end

