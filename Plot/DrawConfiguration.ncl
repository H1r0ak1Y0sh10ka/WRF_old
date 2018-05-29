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
RES@lbTitleFontHeightF   = 0.025                             ; font height

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
RES@lbTitleFontHeightF   = 0.025                             ; font height

RES@cnFillPalette        = "precip2_17lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       2              ; set min contour level
RES@cnMaxLevelValF       =      22              ; set max contour level
RES@cnLevelSpacingF      =       2              ; set contour spacing

end

undef ( "Config_vr_shade" )
procedure Config_vr_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                             ; font height

RES@cnFillPalette        = "hotcold_18lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =      -20              ; set min contour level
RES@cnMaxLevelValF       =       20              ; set max contour level
RES@cnLevelSpacingF      =        4              ; set contour spacing

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

undef ( "Config_vrSprd_shade" )
procedure Config_vrSprd_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                            ; font height

RES@cnFillPalette        = "precip2_17lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       1              ; set min contour level
RES@cnMaxLevelValF       =      10              ; set max contour level
RES@cnLevelSpacingF      =       1              ; set contour spacing

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

undef ( "Config_vt_kyodo_contour" )
procedure Config_vt_kyodo_contour (  \
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

RES@cnLevelSelectionMode          = "ExplicitLevels"     ; set manual contour levels
RES@cnLevels                      = (/ 17., 33.,44.,54./)   ; set levels
RES@cnLineThicknessF              = 10
RES@cnLineLabelFontHeightF        = 0.025
end

undef ( "Config_vt_shade" )
procedure Config_vt_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                             ; font height

RES@cnFillPalette        = "hotcold_18lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =      -50              ; set min contour level
RES@cnMaxLevelValF       =       50              ; set max contour level
RES@cnLevelSpacingF      =       10              ; set contour spacing

end

undef ( "Config_vtSprd_shade" )
procedure Config_vtSprd_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                            ; font height

RES@cnFillPalette        = "precip2_17lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       1              ; set min contour level
RES@cnMaxLevelValF       =      10              ; set max contour level
RES@cnLevelSpacingF      =       1              ; set contour spacing

end

undef ( "Config_rv_shade" )
procedure Config_rv_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                             ; font height

RES@cnFillPalette        = "hotcold_18lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     -30           ; set min contour level
RES@cnMaxLevelValF       =      30           ; set max contour level
RES@cnLevelSpacingF      =       5          ; set contour spacing

end

undef ( "Config_rvSprd_shade" )
procedure Config_rvSprd_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                            ; font height

RES@cnFillPalette        = "precip2_17lev"
;RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
;RES@cnMinLevelValF       =       1              ; set min contour level
;RES@cnMaxLevelValF       =      10              ; set max contour level
;RES@cnLevelSpacingF      =       1              ; set contour spacing

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
RES@lbTitleFontHeightF   = 0.025                             ; font height

RES@cnFillPalette        = "WhiteBlueGreenYellowRed"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       0              ; set min contour level
RES@cnMaxLevelValF       =       10             ; set max contour level
RES@cnLevelSpacingF      =       1            ; set contour spacing

end

undef ( "Config_inertial_stability_shade" )
procedure Config_inertial_stability_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                             ; font height

RES@cnFillPalette        = "WhiteYellowOrangeRed"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       0              ; set min contour level
RES@cnMaxLevelValF       =       50             ; set max contour level
RES@cnLevelSpacingF      =       5            ; set contour spacing

end

undef ( "Config_inertial_stabilitySprd_shade" )
procedure Config_inertial_stabilitySprd_shade (  \
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
RES@lbTitleFontHeightF   = 0.025                            ; font height

RES@cnFillPalette        = "precip2_17lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =       5              ; set min contour level
RES@cnMaxLevelValF       =      55              ; set max contour level
RES@cnLevelSpacingF      =       5              ; set contour spacing

end

