load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
path = "/glade/p/work/huyong/verify/"
path1 = "/glade/scratch/huyong/archive/gT62.g16."
pert=(/ "orig","core384","tol1.0e-10","tol1.0e-16","tol5.0e-9","cvtd100000.0","tadvct=lw_lim"/)
pertname=(/ "original","cores = 384","tol = 1.0e-10","tol = 1.0e-16","tol = 5.0e-9","tracer mixing coeff. for diffusion = 100000.0","tracer advection = lw_lim"/)
;case = ""
do ncase = 0,dimsizes(pert)-1
  case = pert(ncase)
  ;;;; get dimension sizes
  year="0001"
  mon="12"
  ;;; get ensemble file
  filename = path+"pop.40ens.openseas.nc"
  ;;; get test file
  filecnt = path1+case+"/ocn/hist/gT62.g16."+case+".pop.h."+year+"-"+mon+".nc"
  print((/filename/))
  print((/filecnt/))
  fT        = addfile (filename, "r")
  cntf      = addfile (filecnt, "r")
  
  
  lon2d = cntf->ULONG
  lat2d = cntf->ULAT
  stdSST   = fT->ens_stddev3d(11,2,0,:,:)
  avgSST   = fT->ens_avg3d(11,2,0,:,:)
  data  =  (/cntf->TEMP(0,0,:,:)/)  ;;; choose the first time slice and the first layer 
  rmask =  cntf->REGION_MASK
  std2d = mask(stdSST,rmask .ge. 1 .and. rmask .le. 6, True)

  ; calculate Z-score
  data = abs((data-avgSST)/where(std2d .le. 1.0e-12, std2d@_FillValue, std2d))
  data = smth9_Wrap(data,0.5,0.0,True)

  ;;; for POP figures 
  data@lat2d =  lat2d
  data@lon2d =  lon2d
  printMinMax(data,True)
  
  filename = "SST-Zscore_y"+year+"_m"+mon+case                  ; open workstatio
  
  wks   = gsn_open_wks ("x11",filename);
  wks   = gsn_open_wks ("png",filename);
  
  res                   = True                      ; plot mods desired
  
  res@tiMainString     = "Z-score of SST ("+pertname(ncase)+")"
  res@pmLegendDisplayMode     = "Always"
  res@cnFillOn             = True       ; turn on color fill
  res@cnLineLabelsOn       = False      ; turns off contour line labels
  res@cnFillMode           = "RasterFill"      ; turns off contour line labels
  res@cnFillPalette = "sunshine_9lev"
  res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line
  res@cnLevelSelectionMode = "Explicitlevels"
  ;res@cnLevels = (/0.0001,0.0005,0.001,0.005,0.01,0.05,0.1,0.5,1/)
  ;res@cnLevels = 10^ispan(-4,0,1)
  ;res@cnLevels = 0.1*2^ispan(0,6,1)  ; for original 
  ;res@cnLevels = fspan(1,3,3)
  res@cnLevels = (/1,2,3/)


  plot = gsn_csm_contour_map_ce(wks,data,res)     ; create plot
  system("convert -trim "+filename+".png " +filename+".png")
end do 

end
