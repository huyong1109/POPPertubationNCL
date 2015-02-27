load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  ;************************************************
  path = "/glade/p/work/huyong/NCOUT/3years_opensea/"
  path1 = "/glade/scratch/huyong/archive/perturb.g40.T.year"
  ;pert=(/ "Original","Proc=96 block=40x33", "Proc=96 block=20x16", "Proc=48","Proc=192","Proc=384","Tadvect*10","Convectdiff*10" /)
  pert=(/ "CSI","Tol=1.0e-10","Proc=384","Convectdiff*10"/)
  npert = dimsizes(pert)
  nyear = 3
  year = ispan(1,nyear,1)
  nmon = 12
  mon = ispan(1,12,1)
  smon = sprinti("%0.2i", mon) ; string 
  vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
  nvar = dimsizes(vars)
  npdf = 40
  plot = new(4,graphic)
  zpdf = new((/4,36,5,npdf/),float)
  tmpzpdf := asciiread("ZscoreHist_tol.ascii",(/7,36,5,npdf/),"float")
  zpdf(0,:,:,:) = tmpzpdf(5,:,:,:)
  zpdf(1,:,:,:) = tmpzpdf(0,:,:,:)
  tmpzpdf := asciiread("ZscoreHist_layout_param.ascii",(/8,36,5,npdf/),"float")
  zpdf(2,:,:,:) = tmpzpdf(5,:,:,:)
  zpdf(3,:,:,:) = tmpzpdf(7,:,:,:)
  zpdf!0 = "case"
  zpdf!1 = "time"
  zpdf!2 = "var"
  zpdf!3 = "bin"
  zpdf := zpdf(case|:,var|:,bin|:,time|:)
  
  do i = 1, npdf-1
    zpdf(:,:,i,:) = zpdf(:,:,i,:)+zpdf(:,:,i-1,:)
  end do
  
  do v = 0, nvar-1
    filename = "Zscore_over_mon-csi-tol-layout-parm_"+vars(v)
    wk_type = "png"
    wk_type@wkWidth = 2500
    wk_type@wkHeight = 2500
    wks   = gsn_open_wks (wk_type,filename);

    res                   = True                      ; plot mods desired
    res@lbOrientation = "vertical"
    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@gsnDraw = False
    res@gsnFrame = False
    ;res@cnLevelSelectionMode = "Explicitlevels"
    ;res@cnLevels = 10^ispan(0,10,1)

    res@tmYLMode = "Explicit"
    res@tmYLValues = fspan(0,40,5)
    res@tmYLLabels = fspan(0,4.0,5)
    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(2,35,3)
    res@tmXBLabels = ispan(3,36,3)
    ;res@trXMinF = -0.22
    ;res@trXMaxF = 0.22
    ;res@trYMinF = 0
    ;res@trYMaxF = 12000
    do i = 0, npert-1
      res@tiXAxisString     = "Month"
      res@tiYAxisString     = "Zscore"
      res@tiMainString      = pert(i)
      plot(i) = gsn_csm_contour(wks,zpdf(i,v,:,:),res)     ; create plot
    end do
    resP = True
    ;resP@txString = var+" Zscore distribution  of case: "+case
    resP@txString = "Zscore CDF (%) of Open seas " +vars(v)
    gsn_panel(wks,plot,(/2,2/),resP)
    system("convert -trim "+filename+".png " +filename+".png")
  
  end do 
end
