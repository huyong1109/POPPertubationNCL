begin

  ensroot = "/glade/p/work/huyong/NCOUT/3years_opensea/perturb.T.h."
  nyear = 3 
  nmon = 12
  nvar =5
  nens =40 
  year = ispan(1,nyear,1)
  mon  = sprinti("%0.2i",ispan(1,nmon,1))
  append = "-14-np-40cases.nc"

  rmsz = new((/nyear*nmon,nvar,nens/),float)
  rmszpdf = new((/2,nyear*nmon,nvar/),float)
  do i = 0,nyear-1
    do j = 0,nmon-1
      ens_file = ensroot+year(i)+"-"+mon(j)+append
      print((/"(ens_file "+ens_file+")"/))
      fens = addfile(ens_file,"r")
      rmsz(i*nmon+j,:,:) = fens->RMSZ 
      vars = fens->vars
      
      ;pdf = pdfx(rmsz(i,j,v,:),5,False)
      rmszpdf(0,i*nmon+j,:) = dim_avg_n(rmsz(i*nmon+j,:,:),1)
      rmszpdf(1,i*nmon+j,:) = dim_stddev_n(rmsz(i*nmon+j,:,:),1) 
    end do 
  end do  
      printVarSummary(rmsz) 
      asciiwrite("ensemble_zscore.ascii",rmsz(:,:,:))
      plotdata = new((/3,nyear*nmon,nvar/),float)
      plotdata(0,:,:) = rmszpdf(0,:,:)
      plotdata(1,:,:) = rmszpdf(0,:,:) -rmszpdf(1,:,:)
      plotdata(2,:,:) = rmszpdf(0,:,:) +rmszpdf(1,:,:)
      do v = 0, nvar-1
      wks   = gsn_open_wks ("png","mean-std-"+vars(v,:))                  ; open workstation
      res = True
      res@tiMainString     = vars(v,:)         ; change line color
      res@tiXAxisString     = "Simulation Months"         ; change line color
      res@tiYAxisString     = "RMSZ"         ; change line color
      res@xyLineThicknesses = (/4,2,2/)
      res@xyLineColors = (/"lightseagreen","SlateBlue","SlateBlue"/)
      res@xyMarkers      = (/3,2,1/)          ; change line color
      res@pmLegendDisplayMode     = "Always"
      res@pmLegendSide     = "Top"
      res@pmLegendWidthF     = 0.30
      res@pmLegendHeightF     = 0.15
      res@pmLegendOrthogonalPosF     = -0.40

      res@xyExplicitLabels = (/"MEAN","MEAN+STD","MEAN-STD"/)
      
      ;res@trXMinF = 1
      ;res@trXMaxF = 36
      ;res@trYMinF = 0.5
      ;res@trYMaxF = 1.5
      plot  = gsn_csm_xy (wks,ispan(1,36,1),plotdata(:,:,v),res)
      end do 


end 
