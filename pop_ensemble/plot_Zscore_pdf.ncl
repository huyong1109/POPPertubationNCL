load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
path = "/glade/p/work/huyong/NCOUT/3years_opensea/"
path1 = "/glade/scratch/huyong/archive/perturb.g40.T.year"
case1 = ""
case2 = ".convectdiff"

;;;; get dimension sizes
year=(/"1","2","3"/)
mon=sprinti("%0.2i",ispan(1,12,1))
;do iyear = 0,2
;do imon = 0,11

iyear = 0
imon = 0
filename1 = path+"perturb.T.h."+year(iyear)+"-"+mon(imon)+"-14-np-40cases.nc"
filecnt11 = path1+case1+"/ocn/hist/perturb.g40.T.year"+case1+".pop.h.000"+year(iyear)+"-"+mon(imon)+".nc"
filecnt12 = path1+case2+"/ocn/hist/perturb.g40.T.year"+case2+".pop.h.000"+year(iyear)+"-"+mon(imon)+".nc"
print((/filename1/))
print((/filecnt11/))
print((/filecnt12/))
fT1        = addfile (filename1, "r")
cntf11     = addfile (filecnt11, "r")
cntf12     = addfile (filecnt12, "r")

iyear = 2
imon = 11
filename2 = path+"perturb.T.h."+year(iyear)+"-"+mon(imon)+"-14-np-40cases.nc"
filecnt21 = path1+case1+"/ocn/hist/perturb.g40.T.year"+case1+".pop.h.000"+year(iyear)+"-"+mon(imon)+".nc"
filecnt22 = path1+case2+"/ocn/hist/perturb.g40.T.year"+case2+".pop.h.000"+year(iyear)+"-"+mon(imon)+".nc"
print((/filename2/))
print((/filecnt21/))
print((/filecnt22/))
fT2        = addfile (filename2, "r")
cntf21     = addfile (filecnt21, "r")
cntf22     = addfile (filecnt22, "r")

;lon2d = cntf11->ULONG
;lat2d = cntf11->ULAT
;RegLat = (/0,36,92,273,339/)
std2d1   = fT1->ens_stddev2d(0,:,:)
avg2d1   = fT1->ens_avg2d(0,:,:)
std2d2   = fT2->ens_stddev2d(0,:,:)
avg2d2   = fT2->ens_avg2d(0,:,:)

data = new((/384,320,4/),float)
data(:,:,0) =  cntf11->SSH(0,:,:)
data(:,:,1) =  cntf12->SSH(0,:,:)
data(:,:,2) =  cntf21->SSH(0,:,:)
data(:,:,3) =  cntf22->SSH(0,:,:)

; plot case - avg 
data(:,:,0)  = (data(:,:,0)-avg2d1)/where(std2d1 .le. 1.0e-8, data@_FillValue, std2d1)
data(:,:,1)  = (data(:,:,1)-avg2d1)/where(std2d1 .le. 1.0e-8, data@_FillValue, std2d1)
data(:,:,2)  = (data(:,:,2)-avg2d2)/where(std2d2 .le. 1.0e-8, data@_FillValue, std2d2)
data(:,:,3)  = (data(:,:,3)-avg2d2)/where(std2d2 .le. 1.0e-8, data@_FillValue, std2d2)
data(:,:,:)  = where(data(:,:,:) .le. -4.1, -4.1, data(:,:,:))
data(:,:,:)  = where(data(:,:,:) .ge. 4.1, 4.1, data(:,:,:))
print(num(.not. ismissing(data(:,:,0))))
print(num(.not. ismissing(data(:,:,1))))
print(num(.not. ismissing(data(:,:,2))))
print(num(.not. ismissing(data(:,:,3))))
;data = std2d

; plot Z-score
;data = (data-avg2d)/where(std2d .le. 1.0e-8, std2d@_FillValue, std2d)
;data = where(data .ge. 10, 10,data)
;data = where(data .le. -10, -10,data)

  filename = "pdf-SSH-Zscore-dist"
  wks   = gsn_open_wks ("x11",filename)
  res = True
  res@gsnDraw = False
  res@gsnFrame = False
;  gsn_define_colormap(wks, "BlRe")
  res@trXMinF = -4.0
  res@trXMaxF = 4.0
  res@trYMinF = 0
  res@trYMaxF = 8
  
  res@tiMainString      = "SSH Zscore Distribution"
  res@tiXAxisString     = "Zscore"         ; change line color
  res@tiYAxisString     = "Probability"         ; change line color
  res@pmLegendDisplayMode     = "Always"
  res@pmLegendSide     = "Right"
  res@pmLegendWidthF     = 0.3
  res@pmLegendHeightF     = 0.3
  res@lgPerimOn = False
  
  npdf = 100
  plot = new(4,graphic)
  casename = (/"Orig Mon 1", "Vect Mon 1", "Orig Mon 36", "Vect Mon 36"/)
  Colors = (/"Blue","Green","Red","navy"/)
  do i = 0,3
    xpdf = pdfx(data(:,:,i),npdf,False)
    ;print(xpdf@bin_center+" "+xpdf)
    res@xyDashPattern = i
    res@xyLineColors = Colors(i)
    res@xyLineThicknesses = 4
    res@pmLegendOrthogonalPosF     = -0.55
    res@pmLegendParallelPosF     = 0.8+i*0.05
    res@xyExplicitLabels = casename(i)
    plot(i)  = gsn_csm_xy (wks,xpdf@bin_center,xpdf,res)
    if (i .ne. 0) then
      overlay(plot(0),plot(i))
    end if
  end do 
  draw(plot(0))
  frame(wks)
  system("convert -trim "+filename+".png " +filename+".png")

end 

;mmax = 0.4
;wks   = gsn_open_wks ("X11","SSH_np-ENSavg_y"+year(iyear)+"_m"+mon(imon));
;
;    res                   = True                      ; plot mods desired
;    res@tiMainString      = ""        ; add title
;
;; note a similiar resource is xyLineThicknessF, which will effect all
;; the lines in the array.
;;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker
;
;    res@tiMainString     = "SSH Standard Deviation Year "+year(iyear)+" Month "+mon(imon)
;    res@pmLegendDisplayMode     = "Always"
;    res@cnFillOn             = True       ; turn on color fill
;    res@cnLineLabelsOn       = False      ; turns off contour line labels
;    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
;    res@cnLevelSelectionMode = "Manuallevels"
;    res@cnMinLevelValF = -mmax
;    ;res@cnMinLevelValF = 0
;    res@cnMaxLevelValF = mmax
;    res@cnLevelSpacingF = mmax/10
;    res@cnFillPalette = "BlWhRe"
;    ;res@cnFillPalette = "sunshine_9lev"
;    res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line
;
;
;    plot = gsn_csm_contour_map_ce(wks,data,res)     ; create plot
