load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  ;************************************************
  vars=(/"UVEL","VVEL","TEMP","SALT","VDC_T","VDC_S","SSH","IFRAC"/)
  perts= asciiread("testcases.name",-1, "string")
  print((/perts/))

  ;caseid = (/0, 3, 15, 16 /)
  ;pert=(/ "Orginal (Proc=96)","Proc=384","Convectdiff*10","Tadvect=lw_lim"/)
  ;fix = "param"

  caseid = (/0, 12, 7, 4 /)
  pert=(/ "Orginal (Tol=1.0e-13)","Tol=1.0e-16","Tol=1.0e-10","Tol=5.0e-9"/)
  fix = "tol"

  nperts = dimsizes(perts)
  npert = dimsizes(pert)
  nyear = 3
  year = ispan(1,nyear,1)
  nmon = 12
  mon = ispan(1,12,1)
  smon = sprinti("%0.2i", mon) ; string 
  nvar = dimsizes(vars)
  npdf = 40
  plot = new(4,graphic)
  zpdf = new((/npert,nmon*nyear,nvar,npdf/),float)
  tmpzpdf := asciiread("testcases.result.40ens.openseas",(/nmon*nyear,nvar,nperts,npdf/),"float")*100
  do i = 0, dimsizes(caseid) -1
    zpdf(i,:,:,:) = tmpzpdf(:,:, caseid(i),:)
    print("read in case"+ perts(caseid(i)))
  end do 
  ;zpdf(1,:,:,:) = tmpzpdf( 5, :,:,:)
  ;zpdf(2,:,:,:) = tmpzpdf( 17,:,:,:)
  ;zpdf(3,:,:,:) = tmpzpdf( 18,:,:,:)
  zpdf!0 = "case"
  zpdf!1 = "time"
  zpdf!2 = "var"
  zpdf!3 = "bin"
  zpdf := zpdf(case|:,var|:,bin|:,time|:)
  
  do i = 1, npdf-1
    zpdf(:,:,i,:) = zpdf(:,:,i,:)+zpdf(:,:,i-1,:)
  end do
  
  do v = 0, nvar-1
    filename = "RSM-"+vars(v)+"-"+fix
    wk_type = "png"
    wk_type@wkWidth = 2500
    wk_type@wkHeight = 2500
    wks   = gsn_open_wks (wk_type,filename);

    res                   = True                      ; plot mods desired
    res@lbOrientation = "vertical"
    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@cnMonoLevelFlag      = True
    res@cnLinesOn      = False
    
    res@cnLevelFlags         = "NoLine"
    res@gsnDraw = False
    res@gsnFrame = False
    res@cnLevelSelectionMode = "Explicitlevels"
    res@cnLevels = 10*ispan(0,9,1)

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
    resP@txString = "Zscore CDF (%) of " +vars(v)
    gsn_panel(wks,plot,(/2,2/),resP)
    system("convert -trim "+filename+".png " +filename+".png")
  
  end do 
end
