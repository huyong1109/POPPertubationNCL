load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
fT     = addfile ("./NCOUT/perturb.T.h.12-6.nc","r")
fTS    = addfile ("./NCOUT/perturb.TS.h.12-6.nc","r")
fTM     = addfile ("./NCOUT/perturb.T.h.01-6.nc","r")
fTSM    = addfile ("./NCOUT/perturb.TS.h.01-6.nc","r")
GMT    = fT->global_mean                                   ; get u data
GMTS   = fTS->global_mean                                   ; get u data
GMTM    = fTM->global_mean                                   ; get u data
GMTSM   = fTSM->global_mean                                   ; get u data
ZST    = fT->RMSZ                                   ; get u data
ZSTS   = fTS->RMSZ                                   ; get u data
ZSTM    = fTM->RMSZ                                   ; get u data
ZSTSM   = fTSM->RMSZ                                   ; get u data
XT     = (/"U", "V", "T", "S", "H"/)
XTL     = (/"UVEL", "VVEL", "TEMP", "SALT", "SSH"/)
;************************************************
; to plot multiple lines, you must put them into
; a mulidimensional array
;************************************************
dim   = dimsizes(GMT)
data  = new((/4,dim(1)/),float)

lat = ispan(2, 14, 2)
lat@units = "10^(-x)"
printVarSummary(lat)

;************************************************
; plotting Global Mean
;************************************************
do i = 0, dim(0)-1

data(0,:) = GMT(i,:)
data(1,:) = GMTS(i,:)
data(2,:) = GMTM(i,:)
data(3,:) = GMTSM(i,:)
print(data)
;************************************************
; plotting parameters
;************************************************
wks   = gsn_open_wks ("X11",XT(i)+"_global_mean_YM_UVTSH")                  ; open workstation

res                   = True                      ; plot mods desired

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/2.0,2.0,1.0,1.0/)               ; make 2nd lines thicker
res@xyDashPatterns = (/0, 0, 5 ,5/)

res@xyLineColors      = (/"blue","red","blue","red"/)          ; change line color
res@tiXAxisString     = "Perturbation (10^(-x))"         ; change line color
res@tiYAxisString     = "Global Mean"         ; change line color
res@tiMainString     = XTL(i)+" -- Global Mean"         ; change line color
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
res@xyExplicitLabels = (/"T Year", "T-S Year", "T Month", "T-S Month"/)

plot  = gsn_csm_xy (wks,lat,data,res) ; create plot
end do

;************************************************
; plotting RMSZ
;************************************************

do i = 0, dim(0)-1

data(0,:) = ZST(i,:)
data(1,:) = ZSTS(i,:)
data(2,:) = ZSTM(i,:)
data(3,:) = ZSTSM(i,:)
print(data)
;************************************************
; plotting parameters
;************************************************
wks   = gsn_open_wks ("X11",XT(i)+"_RMSZ_YM_UVTSH")                  ; open workstation

res                   = True                      ; plot mods desired

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/2.0,2.0,1.0,1.0/)               ; make 2nd lines thicker
res@xyDashPatterns = (/0, 0, 5 ,5/)

res@xyLineColors      = (/"blue","red","blue","red"/)          ; change line color
res@tiXAxisString     = "Perturbation (10^(-x))"         ; change line color
res@tiYAxisString     = "RMSZ"         ; change line color
res@tiMainString     = XTL(i)+" -- RMSZ"         ; change line color
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
res@xyExplicitLabels = (/"T Year", "T-S Year", "T Month", "T-S Month"/)

plot  = gsn_csm_xy (wks,lat,data,res) ; create plot
end do

end 

