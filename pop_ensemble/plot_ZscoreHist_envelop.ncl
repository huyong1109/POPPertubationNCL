load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  pert1=(/ "Original","Proc=96 block=40x33", "Proc=96 block=20x16", "Proc=48","Proc=192","Proc=384","Tadvect*10","Convectdiff*10" /)
  ;pert2=(/ ".tol.10", ".tol.11", ".tol.12", ".tol.14", ".tol.16",".csi", ""/)
  pert2=(/ ".tol.10", ".tol.11", ".tol.12", ".tol.14", ".tol.16",".csi"/)
  pert3=(/ ".tol.10_5", ".tol.9_5", ".tol.9", ".convectdiff2",".convectdiff5"/)
  npert1 = dimsizes(pert1)
  npert2 = dimsizes(pert2)
  npert3 = dimsizes(pert3)
  npert = npert1+npert2+npert3
  nyear = 3
  year = ispan(1,nyear,1)
  nmon = 12
  mon = ispan(1,12,1)
  smon = sprinti("%0.2i", mon) ; string 
  vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
  nvar = dimsizes(vars)
  npdf = 40
  Tolpdf = 30
  

  plot = new(5,graphic)
  zpdf = new((/npert+2,36,5/),float)
  ;;; compute ensemble max and min
  tmpzpdf := asciiread("ZscoreHist_ENS.ascii",(/40,36,5,npdf/),"float")
  do i = 1, npdf-1
    tmpzpdf(:,:,:,i) = tmpzpdf(:,:,:,i)+tmpzpdf(:,:,:,i-1)
  end do
  zpdf(npert,:,:) = 100-dim_min_n(tmpzpdf(:,:,:,Tolpdf),0)
  zpdf(npert+1,:,:) = 100-dim_max_n(tmpzpdf(:,:,:,Tolpdf),0)

  ;;; read in layout and parameter cases
  tmpzpdf := asciiread("ZscoreHist_layout_param.ascii",(/npert1,nyear*nmon,nvar,npdf/),"float")
  do i = 1, npdf-1
    tmpzpdf(:,:,:,i) = tmpzpdf(:,:,:,i)+tmpzpdf(:,:,:,i-1)
  end do
  zpdf(0:npert1-1,:,:) = 100-tmpzpdf(:,:,:,Tolpdf)

  ;;; read in tolerence cases
  tmpzpdf := asciiread("ZscoreHist_tol.ascii",(/npert2+1,nyear*nmon,nvar,npdf/),"float")
  do i = 1, npdf-1
    tmpzpdf(:,:,:,i) = tmpzpdf(:,:,:,i)+tmpzpdf(:,:,:,i-1)
  end do
  zpdf(npert1:npert1+npert2-1,:,:) = 100-tmpzpdf(0:npert2-1,:,:,Tolpdf)


  ;;; read in extra tolerance cases
  tmpzpdf := asciiread("ZscoreHist_tol5_parm.ascii",(/npert3,nyear*nmon,nvar,npdf/),"float")
  do i = 1, npdf-1
    tmpzpdf(:,:,:,i) = tmpzpdf(:,:,:,i)+tmpzpdf(:,:,:,i-1)
  end do
  zpdf(npert1+npert2:npert-1,:,:) = 100-tmpzpdf(:,:,:,Tolpdf)
  
  zpdf!0 = "case"
  zpdf!1 = "time"
  zpdf!2 = "var"
  zpdf := zpdf(var|:,case|:,time|:)
  
  thick = new(npert+2,float)
  thick = 12.0
  thick(npert:npert+1) = 20.0
  pertname = array_append_record(pert1,pert2, 0)
  pertname := array_append_record(pertname,pert3, 0)
  pertname := array_append_record(pertname,(/"EnsMax","EnsMin"/), 0)

  do v = 0, nvar-1
    filename = "RSM-Zscore-PercentTol_"+Tolpdf+"-"+vars(v)
    wk_type = "png"
    wk_type@wkWidth = 2500
    wk_type@wkHeight = 2500
    wks   = gsn_open_wks (wk_type,filename);
    gsn_define_colormap(wks,"hlu_default")
    res                   = True                      ; plot mods desired
    ;res@gsnDraw = False
    ;res@gsnFrame = False
    res@xyYStyle = "Log"
    res@tiXAxisString     = "Month"
    res@tiYAxisString     = "Zscore Failure (%)"
    res@xyLineThicknesses = thick
    res@xyLineColors      = ispan(1,(npert+2),1)          ; change line color
    res@tiMainString      = vars(v)
    ;if (v .eq. 4) then
    res@pmLegendDisplayMode     = "Always"
    res@pmLegendSide     = "Right"
    res@pmLegendOrthogonalPosF     = -0.0
    res@pmLegendParallelPosF     = 0.6
    res@pmLegendWidthF     = 0.05
    res@pmLegendHeightF     = 0.40
    res@lgLabelFontHeightF     = 0.01

    res@xyExplicitLabels = pertname
    ;end if
    plot(v) = gsn_csm_xy(wks,ispan(1,36,1),zpdf(v,:,:),res)     ; create plot
    system("convert -trim "+filename+".png " +filename+".png")
  end do 
  ;resP = True
  ;resP@txString = var+" Zscore distribution  of case: "+case
  ;resP@txString = "Zscore Failure Percentage (%) of Open seas " 
  ;gsn_panel(wks,plot,(/3,2/),resP)
  ;system("convert -trim "+filename+".png " +filename+".png")
end
