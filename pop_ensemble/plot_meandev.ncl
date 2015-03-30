load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
path = "$WORK/NCOUT/3years_opensea/"

;;;; get dimension sizes
year= (/"1","1","2","3"/)
mon=(/"01","12","12","12"/)
do iyear = 0,dimsizes(year)-1
  imon = iyear
  filename = path+"perturb.T.h."+year(iyear)+"-"+mon(imon)+"-14-np-40cases.nc"
  filecnt = "/glade/scratch/huyong/archive/perturb.g40.T.year.np/ocn/hist/perturb.g40.T.year.np.pop.h.0001-01-02.nc"
  print((/filename/))
  
  fT     = addfile (filename, "r")
  cntf     = addfile (filecnt, "r")
  lon2d = cntf->ULONG
  lat2d = cntf->ULAT
  ;RegLat = (/0,36,92,273,339/)
  data   = fT->ens_stddev2d(0,:,:)
  ;data   = fT->ens_stddev3d(3,0,:,:)
  rmask =  cntf->REGION_MASK
  data  = mask(data,rmask .ge. 1 .and. rmask .le. 6, True)
  ;data1    = data
  ;data  = 0
  ;data(RegLat(3):RegLat(4)-1,:)  =data1(RegLat(3):RegLat(4)-1,:)
  
  data@lon2d = lon2d
  data@lat2d = lat2d
  
  mmax = max(data)
  printMinMax(data,True)
  ;mmax = 0.4
  filename = "SSH_std_y"+year(iyear)+"_m"+mon(imon)
  wks   = gsn_open_wks ("png",filename);
  
  res                   = True                      ; plot mods desired
  res@tiMainString      = ""        ; add title
  
  ; note a similiar resource is xyLineThicknessF, which will effect all
  ; the lines in the array.
  ;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker
  
  res@tiMainString     = "SSH Standard Deviation Year "+year(iyear)+" Month "+mon(imon)
  res@pmLegendDisplayMode     = "Always"
  res@cnFillOn             = True       ; turn on color fill
  res@cnLineLabelsOn       = False      ; turns off contour line labels
  res@cnFillMode           = "RasterFill"      ; turns off contour line labels
  ;res@cnLevelSelectionMode = "Manuallevels"
  ;res@cnMinLevelValF = -mmax
  ;res@cnMinLevelValF = 0
  ;res@cnMaxLevelValF = mmax
  ;res@cnLevelSpacingF = mmax/10
  res@cnLevelSelectionMode = "Explicitlevels"
  ;res@cnLevels = 10^ispan(-8,-3,1)
  res@cnLevels = (/0.001,0.005,0.01,0.05,0.1,0.5,1/);,5,10,15,20/)
  res@cnFillPalette = "WhBlGrYeRe"
  ;res@cnFillPalette = "sunshine_9lev"
  res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line
  
  
  plot = gsn_csm_contour_map_ce(wks,data,res)     ; create plot
  system("convert -trim "+filename+".png " +filename+".png")
end do 

end 

