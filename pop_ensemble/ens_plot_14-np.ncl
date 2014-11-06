load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
fT     = addfile ("./NCOUT/perturb.T.h.12-6.nc","r")
GMT    = fT->global_mean                                   ; get u data
ZST    = fT->RMSZ                                   ; get u data
XT     = (/"U", "V", "T", "S", "H"/)
XTL     = (/"UVEL", "VVEL", "TEMP", "SALT", "SSH"/)
;************************************************
; to plot multiple lines, you must put them into
; a mulidimensional array
;************************************************
dim   = dimsizes(GMT)
data  = new((/dim(1)/),float)

lat = asciiread("./filesuff.T.in", -1, "string")
lat@units = "10^(-x)"
printVarSummary(lat)

;************************************************
; plotting Global Mean
;************************************************
do i = 0, dim(0)-1

data(0,:) = GMT(i,:)
print(data)
;************************************************
; plotting parameters
;************************************************
wks   = gsn_open_wks ("png",XT(i)+"_global_mean_Year_UVTSH-6")                  ; open workstation

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

res@xyLineColors      = (/"blue","red"/)          ; change line color
res@tiXAxisString     = "Perturbation (10^(-x))"         ; change line color
res@tiYAxisString     = "Global Mean"         ; change line color
res@tiMainString     = XTL(i)         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.4
res@pmLegendParallelPosF     = 0.6
res@lgPerimOn     = False

res@pmLegendWidthF     = 0.10
res@pmLegendHeightF     = 0.10
res@lgLabelFontHeightF     = 0.02
res@tmYLFormat = "0*+^e"
res@tmYLMinorOn = False
res@tmYLPrecision = 4
res@xyExplicitLabels = (/"T Perturb"/)

plot  = gsn_csm_xy (wks,lat,data,res) ; create plot
end do

;************************************************
; plotting RMSZ
;************************************************

do i = 0, dim(0)-1

data(0,:) = ZST(i,:)
data(1,:) = ZSTS(i,:)
print(data)
;************************************************
; plotting parameters
;************************************************
wks   = gsn_open_wks ("png",XT(i)+"_RMSZ_Year_UVTSH-6")                  ; open workstation

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

res@xyLineColors      = (/"blue","red"/)          ; change line color
res@tiXAxisString     = "Perturbation (10^(-x))"         ; change line color
res@tiYAxisString     = "RMSZ"         ; change line color
res@tiMainString      = XTL(i)         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.4
res@pmLegendParallelPosF     = 0.6
res@lgPerimOn     = False

res@pmLegendWidthF     = 0.10
res@pmLegendHeightF     = 0.10
res@lgLabelFontHeightF     = 0.02
res@tmYLFormat = "0*+^e"
res@tmYLMinorOn = False
res@tmYLPrecision = 4
res@xyYStyle = "Log"
res@xyExplicitLabels = (/"T Perturb", "T-S Perturb"/)

plot  = gsn_csm_xy (wks,lat,data,res) ; create plot
end do

end 

