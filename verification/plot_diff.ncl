load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
path = "/glade/p/work/huyong/verify/"
path1 = "/glade/scratch/huyong/archive/gT62.g16."
pert=(/ "orig","","core384","tol1.0e-10",
;case = ""
do ncase = 0,dimsizes(pert)-1
case = pert(ncase)
;;;; get dimension sizes
year= (/"1","1","2","3"/)
mon=(/"01","12","12","12"/)
do iyear = 0,dimsizes(year)-1
  ;do imon = 0,11
  imon = iyear
  filename = path+"perturb.T.h."+year(iyear)+"-"+mon(imon)+"-14-np-40cases.nc"
  filecnt = path1+case+"/ocn/hist/perturb.g40.T.year"+case+".pop.h.000"+year(iyear)+"-"+mon(imon)+".nc"
  print((/filename/))
  print((/filecnt/))
  fT        = addfile (filename, "r")
  cntf      = addfile (filecnt, "r")
  
  
  lon2d = cntf->ULONG
  lat2d = cntf->ULAT
  std2d   = fT->ens_stddev2d(0,:,:)
  avg2d   = fT->ens_avg2d(0,:,:)
  data  =  cntf->SSH(0,:,:)
  rmask =  cntf->REGION_MASK
  ;rmask_3D = conform(std2d,rmask,(/1,2/))
  std2d = mask(std2d,rmask .ge. 1 .and. rmask .le. 6, True)
  ;
  ;; plot case - avg 
  ;data  = abs(data-avg2d)
  
  ; plot Z-score
  data = abs((data-avg2d)/where(std2d .le. 1.0e-12, std2d@_FillValue, std2d))
  data = smth9_Wrap(data,0.5,0.0,True)
  ;data = where(data .ge. 10, 10,data) ;data = where(data .le. -10, -10,data) data@lon2d = lon2d
  data@lat2d =  lat2d
  data@lon2d =  lon2d
  printMinMax(data,True)
  
  filename = "SSH-Zscore_y"+year(iyear)+"_m"+mon(imon)+case                  ; open workstatio
  
  wks   = gsn_open_wks ("png",filename);
  
  res                   = True                      ; plot mods desired
  
  res@tiMainString     = "SSH Zscore Year "+year(iyear)+" Month "+mon(imon)+" "+case
  res@pmLegendDisplayMode     = "Always"
  res@cnFillOn             = True       ; turn on color fill
  res@cnLineLabelsOn       = False      ; turns off contour line labels
  res@cnFillMode           = "RasterFill"      ; turns off contour line labels
  ;res@cnLevelSelectionMode = "Manuallevels"
  ;res@cnMinLevelValF = -mmax
  ;;res@cnMinLevelValF = 0
  ;res@cnMaxLevelValF = mmax
  ;res@cnLevelSpacingF = mmax/10
  ;res@cnFillPalette = "BlWhRe"
  res@cnFillPalette = "sunshine_9lev"
  res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line
  res@cnLevelSelectionMode = "Explicitlevels"
  ;res@cnLevels = (/0.0001,0.0005,0.001,0.005,0.01,0.05,0.1,0.5,1/)
  ;res@cnLevels = 10^ispan(-4,0,1)
  ;res@cnLevels = 0.1*2^ispan(0,6,1)  ; for original 
  ;res@cnLevels = fspan(1,3,3)
  res@cnLevels = (/1,3/)


  plot = gsn_csm_contour_map_ce(wks,data,res)     ; create plot
  system("convert -trim "+filename+".png " +filename+".png")
end do 
end do 

end
