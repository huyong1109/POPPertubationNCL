load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
path = "$WORK/NCOUT/global_rmsz/"

;;;; get dimension sizes

mon=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
do imon = 0,11
filename = path+"perturb.T.h.mon"+mon(imon)+"-14-np-41cases.nc"
filecnt = "/glade/scratch/huyong/archive/perturb.g40.T.year.np/ocn/hist/perturb.g40.T.year.np.pop.h.0001-01-02.nc"
print((/filename/))

fT     = addfile (filename, "r")
cntf     = addfile (filecnt, "r")
lon2d = cntf->ULONG
lat2d = cntf->ULAT
;RegLat = (/0,36,92,273,339/)
data   = fT->ens_stddev2d(0,:,:)
;data1    = data
;data  = 0
;data(RegLat(3):RegLat(4)-1,:)  =data1(RegLat(3):RegLat(4)-1,:)

data@lon2d = lon2d
data@lat2d = lat2d

;mmax = max(data)
mmax = 0.4
wks   = gsn_open_wks ("X11","SSH_std_mon"+mon(imon));

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

res@tiMainString     = "SSH Standard Deviation Month"+mon(imon)
res@pmLegendDisplayMode     = "Always"
    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@cnLevelSelectionMode = "Manuallevels"
    res@cnMinLevelValF = -mmax
    res@cnMaxLevelValF = mmax
    res@cnLevelSpacingF = mmax/20.5
    res@cnFillPalette = "BlWhRe"
    res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line


plot = gsn_csm_contour_map_ce(wks,data,res)     ; create plot
end do 

end 

