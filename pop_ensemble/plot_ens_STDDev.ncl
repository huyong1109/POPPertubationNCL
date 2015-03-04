load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  ;************************************************
  path = "$WORK/NCOUT/3years_opensea/"
  vars = (/"UVEL", "VVEL","TEMP","SALT","SSH"/)
  nvar = dimsizes(vars)
  filecnt = "/glade/scratch/huyong/archive/perturb.g40.T.year.np/ocn/hist/perturb.g40.T.year.np.pop.h.0001-01-02.nc"
  print((/"Contrl file: "+filecnt/))
  
  cntf     = addfile (filecnt, "r")
  rmask =  cntf->REGION_MASK
  ;temp  =  cntf->TEMP(0,:,:,:)
  ;rmask_3D = conform(std,rmask,(/1,2/))
  ;;;; get dimension sizes
  
  year  = (/"1","2","3"/)
  nyear = dimsizes(year)
  mon   = sprinti("%0.2i",ispan(1,12,1))
  nmon  = dimsizes(mon)
 
  ;;; get min,mean,median,max deviation  
  dev = new((/nvar,4,nmon*nyear/),float)  
  filename = "Ensemble_Dev_MinMaxAvg_Openseas"
  asciifile = filename+".ascii"

  ;;; collect  data
  ;do iyear = 0, nyear-1
  ;do imon =  0, nmon-1
  ;  itime = iyear*nmon+imon
  ;  testfile = path+"perturb.T.h."+year(iyear)+"-"+mon(imon)+"-14-np-40cases.nc"
  ;  print((/"Filename :"+testfile/))
  ;  
  ;  fT      = addfile (testfile, "r")
  ;  std2d   = fT->ens_stddev2d(0,:,:)
  ;  std3d   = fT->ens_stddev3d(:,:,:,:)
  ;  ;;; mask out open seas
  ;  std2d = mask(std2d,rmask .ge. 1 .and. rmask .le. 6, True)
  ;  std3d = mask(std3d,rmask .ge. 1 .and. rmask .le. 6, True)
  ;  

  ;  do v = 0, nvar-2 
  ;  std := ndtooned(std3d(v,:,:,:))
  ;  std := std(ind(std .ne. 0))
  ;  dev(v,0,itime) = min(std)
  ;  dev(v,1,itime) = avg(std)
  ;  dev(v,2,itime) = dim_median(std)
  ;  dev(v,3,itime) = max(std)
  ;  end do

  ;  std := ndtooned(std2d(:,:))
  ;  std := std(ind(std .ne. 0))
  ;  dev(4,0,itime) = min(std2d)
  ;  dev(4,1,itime) = avg(std2d)
  ;  dev(4,2,itime) = dim_median(ndtooned(std2d))
  ;  dev(4,3,itime) = max(std2d)
  ;   
  ;  print((/"Mon "+itime+" "+dev(:,:,itime)/))
  ;end do 
  ;end do 
  ;asciiwrite(asciifile,dev)

  ;;; plot data
  dev  = asciiread(asciifile,(/nvar,4,nmon*nyear/),"float")
  wk_type = "png"
  wk_type@wkWidth = 2500
  wk_type@wkHeight= 2500
  wks   = gsn_open_wks (wk_type,filename)
  
  plot = new(nvar,graphic)
  res                   = True                      ; plot mods desired
  res@gsnDraw = False
  res@gsnFrame = False
  casename = (/"Dev Min","Dev avg","Dev Med","Dev max"/)
  ncase = dimsizes(casename)
  Colors = (/"Blue","Green","Red","navy"/)

  do v = 0,nvar-1
    res@xyYStyle = "Log"
    res@tiMainString      = vars(v)        ; add title
    res@xyDashPattern = ispan(1,ncase,1)
    res@xyLineColors = Colors
    res@xyLineThicknesses = new(ncase,float,8)
    if (v .eq. nvar-1) then
    res@pmLegendDisplayMode     = "Always"
    res@pmLegendSide     = "Right"
    ;res@pmLegendOrthogonalPosF     = -0.55
    ;res@pmLegendParallelPosF     = 0.8
    res@pmLegendWidthF     = 0.20
    res@pmLegendHeightF     = 0.15
    res@lgLabelFontHeightF     = 0.014
    res@xyExplicitLabels = casename
    end if
    plot(v)  = gsn_csm_xy (wks,ispan(1,36,1),dev(v,:,:),res)
  end do 
  resP = True
  resP@txString = "Ensemble Deviation "
  gsn_panel(wks,plot,(/3,2/),resP)
  system("convert -trim "+filename+".png " +filename+".png")

end 

