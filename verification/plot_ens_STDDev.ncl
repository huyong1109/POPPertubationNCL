load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  ;************************************************
  path = "$WORK/verify/"
  vars=(/"UVEL","VVEL","TEMP","SALT","VDC_T","VDC_S","SSH","IFRAC"/)
  nvar = dimsizes(vars)
  filecnt = "/glade/scratch/huyong/archive/gT62.g16.orig/ocn/hist/gT62.g16.orig.pop.h.0001-01.nc"
  print((/"Contrl file: "+filecnt/))

  cntf     = addfile (filecnt, "r")
  rmask =  cntf->REGION_MASK  
  print(dimsizes(rmask))
  print("num = "+num(rmask .ge. 1 .and. rmask .le. 6))
  tmp_lon =cntf->TLONG
  tmp_lat =cntf->TLAT
  dims = dimsizes(tmp_lon)
  dims(1) =dims(1) +1
  nlat = dims(0)
  nlon = dims(1)
  lon =new(dims,typeof(tmp_lon))
  lat =new(dims,typeof(tmp_lat))
  
  lat(:,1:nlon-1) = tmp_lat
  lon(:,1:nlon-1) = tmp_lon
  lon(:,0) = tmp_lon(:,nlon-2)
  lat(:,0) = tmp_lat(:,nlon-2)
  
  ;;; ensemble file
  testfile = path+"pop.40ens.global.nc"
  print((/"Filename :"+testfile/))
  fT      = addfile (testfile, "r")
  stdSST   = fT->ens_stddev3d(:,2,0,:,:)
  ;temp  =  cntf->TEMP(0,:,:,:)
  ;rmask_3D = conform(std,rmask,(/1,2/))
  ;;;; get dimension sizes
  
  mon  = (/1, 12, 24, 36/)
  imon   = sprinti("%0.2i",mon)
  nmon = dimsizes(mon)
  ;nmon  = dimsizes(mon)

  ;;; collect  data
  do i = 0, nmon-1
    ;;; mask out open seas 
    itime = mon(i) -1
    std2d = stdSST(itime,:,:)
    std2d = mask(std2d,rmask .ge. 1 .and. rmask .le. 6, True)
    T = std2d(1:nlat-1,:)
    T@lat2d = lat
    T@lon2d = lon
    outfile = "SST_STD_mon"+mon(i)
    print(outfile)
    wk_type = "x11"
    wk_type = "png"
    ;wk_type@wkWidth = 2500
    ;wk_type@wkHeight= 2500
    wks   = gsn_open_wks (wk_type,outfile)
    ;gsn_define_colormap(wks, "GMT_red2green")
    res=True
    gsn_define_colormap(wks, "sunshine_9lev")
    ;gsn_define_colormap(wks, "precip2_17lev")
    ;gsn_define_colormap(wks, "prcp_2")
    res@tiMainString         = "STD distribution of SST on the "+mon(i)+"th month"
  
    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@cnInfoLabelOn        = False      ; turns off contour info label
    res@gsnSpreadColors      = True       ; use full colormap
    ;res@cnLevelSelectionMode = "Manuallevels"
    ;res@cnMinLevelValF = -maxmin
    ;res@cnMaxLevelValF = maxmin
    ;res@cnMinLevelValF = -0.7
    ;res@cnMaxLevelValF = 0.7
    ;res@cnLevelSpacingF = 0.1
    res@cnLevelSelectionMode = "ExplicitLevels"
    ;res@cnLevels = (/0.0001,0.001,0.01,0.02,0.03,0.04, 0.05, 0.06,0.07,0.08, 0.09,0.1/)
    ;res@cnLevels = (/0.0001,0.001,0.005,0.01,0.02,0.04,0.06,0.08/)
    res@cnLevels = (/0.0001,0.001,0.005,0.01,0.02,0.04,0.08/)

  
    plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
    system("convert -trim "+outfile+".png " +outfile+".png")
        ;************************************
    
  end do 

end 

