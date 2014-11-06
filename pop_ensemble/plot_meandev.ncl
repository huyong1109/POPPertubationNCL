load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
path = "$WORK/NCOUT/"

;;;; get dimension sizes
filename = path+"meandev-pert14-np-m10.nc"
print((/filename/))
fT     = addfile (filename, "r")
data   = fT->ens_stddev2d(0,:,:)
data@lon2d = fT->ULONG
data@lat2d = fT->ULAT

mmax = max(data)
wks   = gsn_open_wks ("X11","SSH std");

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

res@tiMainString     = "SSH std"
res@pmLegendDisplayMode     = "Always"
    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@cnLevelSelectionMode = "Manuallevels"
    res@cnMinLevelValF = -mmax
    res@cnMaxLevelValF = mmax
    res@cnLevelSpacingF = mmax/3.5
    res@cnFillPalette = "BlWhRe"
    res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line


plot = gsn_csm_contour_map_ce(wks,data,res)     ; create plot

end 

