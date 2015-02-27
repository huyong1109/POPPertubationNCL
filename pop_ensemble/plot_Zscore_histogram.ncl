load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  ;************************************************
  path = "/glade/p/work/huyong/NCOUT/3years_opensea/"
  path1 = "/glade/scratch/huyong/archive/perturb.g40.T.year"
  case = ".convectdiff"
  pert=(/ "",".P96b40x33", ".P96b20x16", ".P48",".P192",".P384",".tadvect",".convectdiff" /)
  ;case = ""
  do ncase = 0, dimsizes(pert)-1
  
    case = pert(ncase)
    
    ;;;; get dimension sizes
    year= (/1,1,2,3/)
    indmon=(/1,12,12,12/)
    mon = sprinti("%0.2i", indmon)
    ;do iyear = 0,2
    ;do imon = 0,11
    
    data := new((/60,384,320,4/),float)
  ; plot SSH  
    data := new((/384,320,4/),float)
    do i = 0, 3
      iyear = i
      imon = i
      filename = path+"perturb.T.h."+year(iyear)+"-"+mon(imon)+"-14-np-40cases.nc"
      filecnt = path1+case+"/ocn/hist/perturb.g40.T.year"+case+".pop.h.000"+year(iyear)+"-"+mon(imon)+".nc"
      print((/filename/))
      print((/filecnt/))
      fT        = addfile (filename, "r")
      cntf      = addfile (filecnt, "r")

      rmask =  cntf->REGION_MASK
      
      lon2d = cntf->ULONG
      lat2d = cntf->ULAT
      std      := fT->ens_stddev2d(0,:,:)
      ensavg   := fT->ens_avg2d(0,:,:)
      ;rmask_3D = conform(std,rmask,(/1,2/))
      ;ens_stddev2d = mask(ens_stddev2d,rmask .ge. 1 .and. rmask .le. 6, True)
      ;std = mask(std,rmask_3D .ge. 1 .and. rmask_3D .le. 6, True)
      
      data(:,:,i)  =  cntf->SSH(0,:,:)
      ;
      ;; plot case - avg 
      ;data  = abs(data-avg2d)
      
      ; plot Z-score
      data(:,:,i) = (data(:,:,i)-ensavg)/where(std .le. 1.0e-12, std@_FillValue, std)
      ;data = where(data .ge. 10, 10,data) ;data = where(data .le. -10, -10,data) data@lon2d = lon2d
      ;data@lat2d =  lat2d
      ;data@lon2d =  lon2d
    end do

    printVarSummary(data)
    printMinMax(data,True)
    
    plot = new(4,graphic)
    filename = "Hist-SSH-Zscore_opensea"+case                  ; open workstatio
    wks   = gsn_open_wks ("png",filename);

    res                   = True                      ; plot mods desired
    ;res@cnMinLevelValF = -mmax
    ;;res@cnMinLevelValF = 0
    ;res@cnMaxLevelValF = mmax
    ;res@cnLevelSpacingF = mmax/10
    res@gsnDraw = False
    res@gsnFrame = False

    res@tmXBLabelStride = 5
    res@gsnHistogramComputePercentages = True
    res@gsnHistogramComputePercentagesNoMissing  = True
    res@gsnHistogramBinIntervals = fspan(-4,4,41)
    ;res@trXMinF = -0.22
    ;res@trXMaxF = 0.22
    res@trYMinF = 0
    res@trYMaxF = 12000
    do i = 0,3
      imon = (year(i)-1)*12+indmon(i)
      res@tiXAxisString     = "Zscore"
      res@tiYAxisString     = "Points Count"         ; change line color
      res@tiMainString      = "Month "+imon
      plot(i) = gsn_histogram(wks,ndtooned(data(:,:,i)),res)     ; create plot
    end do
    resP = True
    ;resP@txString = var+" Zscore distribution  of case: "+case
    resP@txString = "SSH Zscore distribution (opensea) of case: "+case
    gsn_panel(wks,plot,(/2,2/),resP)
    system("convert -trim "+filename+".png " +filename+".png")
    

  end do
   ; do v = 0,3
   ; 
   ;   do i = 0, 3
   ;     iyear = i
   ;     imon = i
   ;     filename = path+"perturb.T.h."+year(iyear)+"-"+mon(imon)+"-14-np-40cases.nc"
   ;     filecnt = path1+case+"/ocn/hist/perturb.g40.T.year"+case+".pop.h.000"+year(iyear)+"-"+mon(imon)+".nc"
   ;     print((/filename/))
   ;     print((/filecnt/))
   ;     fT        = addfile (filename, "r")
   ;     cntf      = addfile (filecnt, "r")
   ;     vars      = fT->var3d
   ;     var = str_concat(vars(v,:))
   ;     print((/var/))
   ;     ;rmask =  cntf->REGION_MASK
   ;     
   ;     
   ;     lon2d = cntf->ULONG
   ;     lat2d = cntf->ULAT
   ;     std   := fT->ens_stddev3d(v,:,:,:)
   ;     ensavg   := fT->ens_avg3d(v,:,:,:)
   ;     ;rmask_3D = conform(std,rmask,(/1,2/))
   ;     ;ens_stddev2d = mask(ens_stddev2d,rmask .ge. 1 .and. rmask .le. 6, True)
   ;     ;std = mask(std,rmask_3D .ge. 1 .and. rmask_3D .le. 6, True)
   ;     
   ;     data(:,:,:,i)  =  cntf->$var$(0,:,:,:)
   ;     ;
   ;     ;; plot case - avg 
   ;     ;data  = abs(data-avg2d)
   ;     
   ;     ; plot Z-score
   ;     data(:,:,:,i) = (data(:,:,:,i)-ensavg)/where(std .le. 1.0e-12, std@_FillValue, std)
   ;     ;data = where(data .ge. 10, 10,data) ;data = where(data .le. -10, -10,data) data@lon2d = lon2d
   ;     ;data@lat2d =  lat2d
   ;     ;data@lon2d =  lon2d
   ;   end do

   ;   printVarSummary(data)
   ;   printMinMax(data,True)
   ;   
   ;   plot = new(4,graphic)
   ;   filename = "Hist-"+var+"-Zscore_opensea"+case                  ; open workstatio
   ;   wks   = gsn_open_wks ("png",filename);

   ;   res                   = True                      ; plot mods desired
   ;   ;res@cnMinLevelValF = -mmax
   ;   ;;res@cnMinLevelValF = 0
   ;   ;res@cnMaxLevelValF = mmax
   ;   ;res@cnLevelSpacingF = mmax/10
   ;   res@gsnDraw = False
   ;   res@gsnFrame = False

   ;   res@tmXBLabelStride = 5
   ;   res@gsnHistogramComputePercentages = True
   ;   res@gsnHistogramComputePercentagesNoMissing  = True
   ;   res@gsnHistogramBinIntervals = fspan(-4,4,41)
   ;   ;res@trXMinF = -0.22
   ;   ;res@trXMaxF = 0.22
   ;   res@trYMinF = 0
   ;   res@trYMaxF = 400000
   ;   do i = 0,3
   ;     imon = (year(i)-1)*12+indmon(i)
   ;     res@tiXAxisString     = "Zscore"
   ;     res@tiYAxisString     = "Points Count"         ; change line color
   ;     res@tiMainString     = "Month "+imon
   ;     plot(i) = gsn_histogram(wks,ndtooned(data(:,:,:,i)),res)     ; create plot
   ;   end do
   ;   resP = True
   ;   ;resP@txString = var+" Zscore distribution  of case: "+case
   ;   resP@txString = var+" Zscore distribution (opensea) of case: "+case
   ;   gsn_panel(wks,plot,(/2,2/),resP)
   ;   system("convert -trim "+filename+".png " +filename+".png")
   ; end do
end
