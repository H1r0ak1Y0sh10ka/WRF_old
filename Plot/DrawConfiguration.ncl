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

undef ( "Config_vr_vector" )
procedure Config_vr_vector (  \
  RES[*]           : logical \
  )
local none
begin

RES@vcGlyphStyle              = "FillArrow"
RES@vcFillArrowsOn            = True
;RES@vcFillArrowEdgeColor     = "black"
RES@vcFillArrowEdgeColor      = "white"
RES@vcLineArrowThicknessF     = 5
RES@vcFillArrowEdgeThicknessF = 8.0
RES@vcMinDistanceF            = 0.01

RES@vcRefLengthF             = 0.06
RES@vcRefMagnitudeF          = 5 
RES@vcRefAnnoString1         = "5"
RES@vcRefAnnoSide            = "Left"
RES@vcRefAnnoString2On       = False
RES@vcRefAnnoPerimOn         = False
RES@vcRefAnnoOrthogonalPosF   =  -0.075
RES@vcRefAnnoBackgroundColor  = "plum1"

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

undef ( "Config_rh_shade" )
procedure Config_rh_shade (  \
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

RES@cnFillPalette        = "GMT_drywet"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     50           ; set min contour level
RES@cnMaxLevelValF       =     90           ; set max contour level
RES@cnLevelSpacingF      =      5           ; set contour spacing

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

undef ( "Config_vt_contour_green" )
procedure Config_vt_contour_green (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnLineColor                   = "green"                ; Set the line color
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

;RES@cnFillPalette        = "hotcold_18lev"
RES@cnFillPalette        = "cmp_flux"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =      -20              ; set min contour level
RES@cnMaxLevelValF       =       20              ; set max contour level
RES@cnLevelSpacingF      =        4              ; set contour spacing

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


RES@cnFillPalette        = "cmp_flux"
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

undef ( "Config_ww_contour" )
procedure Config_ww_contour (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnLineColor                   = "black"                ; Set the line color
RES@cnInfoLabelOn                 = False
RES@cnLineThicknessF              =  10
RES@gsnContourNegLineDashPattern  = 1                      ; sets negative contours to dash pattern 1
RES@cnLineLabelInterval           = 1                      ; default = 2
RES@cnLineLabelFontHeightF        = 0.025

RES@cnLevelSelectionMode          = "ManualLevels"         ; set manual contour levels
RES@cnMinLevelValF                =       0                ; set min contour level
RES@cnMaxLevelValF                =     200                ; set max contour level
RES@cnLevelSpacingF               =      25                ; set contour spacing

end

undef ( "Config_percent_shade" )
procedure Config_percent_shade (  \
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
RES@cnMinLevelValF       =      10           ; set min contour level
RES@cnMaxLevelValF       =     100           ; set max contour level
RES@cnLevelSpacingF      =      10          ; set contour spacing

undef ( "Config_wwDiff_shade" )
procedure Config_wwDiff_shade (  \
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
;RES@cnFillOpacityF       = 0.75 
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     -50           ; set min contour level
RES@cnMaxLevelValF       =      50           ; set max contour level
RES@cnLevelSpacingF      =      10          ; set contour spacing

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

undef ( "Config_div_shade" )
procedure Config_div_shade (  \
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

RES@cnFillPalette        = "cmp_flux"
;RES@cnFillPalette        = "hotcold_18lev"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     -8           ; set min contour level
RES@cnMaxLevelValF       =      8           ; set max contour level
RES@cnLevelSpacingF      =      2          ; set contour spacing

end

undef ( "Config_divDiff_shade" )
procedure Config_divDiff_shade (  \
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
;RES@cnFillOpacityF       = 0.75 
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     -10           ; set min contour level
RES@cnMaxLevelValF       =      10           ; set max contour level
RES@cnLevelSpacingF      =       2          ; set contour spacing

end

undef ( "Config_divSprd_shade" )
procedure Config_divSprd_shade (  \
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
RES@cnMinLevelValF       =      1              ; set min contour level
RES@cnMaxLevelValF       =      10              ; set max contour level
RES@cnLevelSpacingF      =      1              ; set contour spacing

end

undef ( "Config_vtvgano_shade" )
procedure Config_vtvgano_shade (  \
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

RES@cnFillPalette        = "cmp_flux"
;RES@cnFillOpacityF       = 0.75 
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     -5           ; set min contour level
RES@cnMaxLevelValF       =      5           ; set max contour level
RES@cnLevelSpacingF      =      1          ; set contour spacing

end

undef ( "Config_vtvganoSprd_shade" )
procedure Config_vtvganoSprd_shade (  \
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
RES@cnMinLevelValF       =      0.5              ; set min contour level
RES@cnMaxLevelValF       =       5              ; set max contour level
RES@cnLevelSpacingF      =      0.5              ; set contour spacing

end

undef ( "Config_vtvganoDiff_shade" )
procedure Config_vtvganoDiff_shade (  \
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

RES@cnFillPalette        = "cmp_flux"
;RES@cnFillOpacityF       = 0.75 
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     -5           ; set min contour level
RES@cnMaxLevelValF       =      5           ; set max contour level
RES@cnLevelSpacingF      =      1          ; set contour spacing

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

undef ( "Config_h_diabatic_contour" )
procedure Config_h_diabatic_contour (  \
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
RES@cnMinLevelValF                =       0                ; set min contour level
RES@cnMaxLevelValF                =      10                ; set max contour level
RES@cnLevelSpacingF               =       1                ; set contour spacing

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


undef ( "Config_h_diabaticSprd_shade" )
procedure Config_h_diabaticSprd_shade (  \
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
RES@cnMinLevelValF       =      2             ; set min contour level
RES@cnMaxLevelValF       =      20              ; set max contour level
RES@cnLevelSpacingF      =      2              ; set contour spacing

end

undef ( "Config_lh_shade" )
procedure Config_lh_shade (  \
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
RES@cnMinLevelValF       =       50              ; set min contour level
RES@cnMaxLevelValF       =      550             ; set max contour level
RES@cnLevelSpacingF      =       50              ; set contour spacing

end

undef ( "Config_lhSprd_shade" )
procedure Config_lhSprd_shade (  \
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
RES@cnMinLevelValF       =      20              ; set min contour level
RES@cnMaxLevelValF       =     220              ; set max contour level
RES@cnLevelSpacingF      =      20              ; set contour spacing

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

undef ( "Config_cape_contour" )
procedure Config_cape_contour (  \
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
RES@cnMinLevelValF                =     500                ; set min contour level
RES@cnMaxLevelValF                =    4000                ; set max contour level
RES@cnLevelSpacingF               =     500                ; set contour spacing

end

undef ( "Config_cape_shade" )
procedure Config_cape_shade (  \
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
RES@cnMinLevelValF       =      500              ; set min contour level
RES@cnMaxLevelValF       =     4000             ; set max contour level
RES@cnLevelSpacingF      =      500              ; set contour spacing

end

undef ( "Config_capeSprd_shade" )
procedure Config_capeSprd_shade (  \
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
RES@cnMinLevelValF       =      100             ; set min contour level
RES@cnMaxLevelValF       =     1100              ; set max contour level
RES@cnLevelSpacingF      =      100              ; set contour spacing

end

undef ( "Config_capeDiff_shade" )
procedure Config_capeDiff_shade (  \
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
;RES@cnFillOpacityF       = 0.75 
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     -2800           ; set min contour level
RES@cnMaxLevelValF       =      2800           ; set max contour level
RES@cnLevelSpacingF      =       400          ; set contour spacing

end

undef ( "Config_qvaporflux_shade" )
procedure Config_qvaporflux_shade (  \
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

;RES@cnFillPalette        = "GMT_drywet"
RES@cnFillPalette        = "CBR_wet"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     0.0005           ; set min contour level
RES@cnMaxLevelValF       =     0.005          ; set max contour level
RES@cnLevelSpacingF      =     0.0005           ; set contour spacing

end

undef ( "Config_tgrad_shade" )
procedure Config_tgrad_shade (  \
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
RES@cnMinLevelValF       =     -3           ; set min contour level
RES@cnMaxLevelValF       =      3           ; set max contour level
RES@cnLevelSpacingF      =      0.5          ; set contour spacing

end

undef ( "Config_tgradSprd_shade" )
procedure Config_tgradSprd_shade (  \
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
RES@cnMinLevelValF       =       0.2             ; set min contour level
RES@cnMaxLevelValF       =       2.0             ; set max contour level
RES@cnLevelSpacingF      =       0.2              ; set contour spacing

end

undef ( "Config_olr_shade" )
procedure Config_olr_shade (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnFillOn             = True                   ; turn on color
RES@lbLabelAutoStride    = True                   ; nice label bar labels
RES@cnLinesOn            = False                  ; no contour lines
RES@cnFillMode           = "RasterFill"

RES@lbOrientation        = "vertical"
RES@lbTitlePosition      = "Right"                           ; title location
RES@lbTitleDirection     = "Across"                          ; letter angle
RES@lbTitleAngleF        = 90.                               ; title angle
RES@lbTitleFontHeightF   = 0.025                             ; font height

RES@cnFillPalette        = "MPL_Greys"
RES@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
RES@cnMinLevelValF       =     100           ; set min contour level
RES@cnMaxLevelValF       =     240           ; set max contour level
RES@cnLevelSpacingF      =      20          ; set contour spacing

end

undef ( "Config_prec_shade" )
procedure Config_prec_shade (  \
  RES[*]           : logical \
  )
local none
begin

RES@cnFillOn             = True                   ; turn on color
RES@lbLabelAutoStride    = True                   ; nice label bar labels
RES@cnLinesOn            = False                  ; no contour lines
RES@cnFillMode           = "RasterFill"

RES@lbOrientation        = "vertical"
RES@lbTitlePosition      = "Right"                           ; title location
RES@lbTitleDirection     = "Across"                          ; letter angle
RES@lbTitleAngleF        = 90.                               ; title angle
RES@lbTitleFontHeightF   = 0.025                             ; font height

cmap                    := read_colormap_file("BlAqGrYeOrReVi200")
cmap(0,:)                = (/0,0,0,0/)      ; make first color fully transparent
RES@cnFillPalette        = cmap
RES@cnFillOpacityF       = 1.               ; .85 
RES@cnLevelSelectionMode = "ManualLevels"   ; set manual contour levels
RES@cnMinLevelValF       =      5           ; set min contour level
RES@cnMaxLevelValF       =     60           ; set max contour level
RES@cnLevelSpacingF      =      5           ; set contour spacing

end

