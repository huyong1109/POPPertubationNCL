load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  vars=(/"UVEL","VVEL","TEMP","SALT","VDC_T","VDC_S","SSH","IFRAC"/)
  pert= asciiread("testcases.name",-1, "string")
  print(pert)
  pertname=(/ "original","cores = 48","cores = 192","cores = 384","tol=5e-9", "tol=e-9","tol=5e-10", "tol=e-10", "tol=e-11", "tol=e-12", "tol=e-14","tol=e-15","tol=e-16", "convect_diff*2","convect_diff*5","convectdiff*10","t_advect=lw_lim" /)
  ;pertname = pert
  colors = (/"yellow","purple4","blue4","red4", "green","orange", "dodgerblue","red","darkorchid", "darkslategrey","seagreen3", "navy", "orangered4","orangered4","navy","red","dodgerblue"/) ;"deepskyblue","dodgerblue","darksalmon","darkseagreen","darkorchid","deeppink","firebrick",
  ;thicks = (/30,10,10,10,10,10,30,27,24,21,18,15,12,9,6,15,20,25,30,30/)
  thicks = new(17,"float")
  thicks = 20
  thicks(0) = 30
  thicks(1:3) = 15
  thicks(4:8) = 10
  npert = dimsizes(pert)
  ;;; pick out the cases you want to plot 

  ;caseid = ispan(0,npert-1,1) ; all cases
  ;casetitle = ""

  ;caseid = ispan(0,3,1) ; layout cases
  ;casetitle = "layout"

  caseid = array_append_record((/0/),ispan(4,12,1),0); different tolerance cases
  casetitle = "tol"

  ;caseid = array_append_record((/0/),ispan(13,16,1),0) ; different physical parameter cases
  ;casetitle = "param"

  ;caseid = array_append_record((/0/),ispan(0,5,1),0)
  ;caseid := array_append_record(caseid,ispan(15,18,1),0) ; different physical parameter and layout cases
  ;casetitle = "layout-parameter"
  
  nyear = 3
  year = ispan(1,nyear,1)
  nmon = 12
  mon = ispan(1,12,1)
  smon = sprinti("%0.2i", mon) ; string 
  nvar = dimsizes(vars)
  npdf = 40
  Tolpdf = 30
  

  zpdf = new((/nmon*nyear,nvar,npert/),float)

  ;;; read in layout and parameter cases
  tmpzpdf := asciiread("testcase.result",(/nyear*nmon,nvar,npert,npdf/),"float")*100
  ;print((/tmpzpdf(0:5,2:3,0,:)/))
  tmpzpdf1 = tmpzpdf(:,:,:,:)
  pertname1 = pertname(:)
  colors1 = colors(:)
  do i = 4, 12
    tmpzpdf1(:,:,i,:) = tmpzpdf(:,:,16-i,:)
    pertname1(i) = pertname(16-i)
    colors1(i) = colors(16-i)
  end do 
  tmpzpdf(:,:,:,:) = tmpzpdf1(:,:,:,:)
  pertname(:) = pertname1(:)
  colors = colors1(:)
  
  do i = 1, npdf-1
    tmpzpdf(:,:,:,i) = tmpzpdf(:,:,:,i)+tmpzpdf(:,:,:,i-1)
  end do 
  ;print((/tmpzpdf(0:5,2:4,0,npdf-1)/))
  zpdf(:,:,0:npert-1) = 100-tmpzpdf(:,:,0:npert-1,Tolpdf)
  
  zpdf!0 = "time"
  zpdf!1 = "var"
  zpdf!2 = "case"
  zpdf := zpdf(var|:,case|:,time|:)
 

  ; get index of the wanted cases 
  caseindex = new((/npert/),logical,False)
  nzpdfid = dimsizes(caseid)

  do i = 0,nzpdfid-1
    caseindex(caseid(i)) = True
  end do 
  ;print((/caseid/))
  ;print("nzpdfid = "+nzpdfid)

  zpdfid  = zpdf(:,ind(caseindex),:)
  ;printVarSummary(zpdfid)
  

  pertnameid  = pertname(ind(caseindex))
  colorid  = colors(ind(caseindex))
  thickid  = thicks(ind(caseindex))

  do v = 0, nvar-1
    filename = "PRZ-Zscore-PercentTol_"+Tolpdf+"-"+vars(v)+"-"+casetitle+"Y0-100"
    wk_type = "x11"
    wk_type = "png"
    wk_type@wkWidth = 2500
    wk_type@wkHeight = 2500
    wks   = gsn_open_wks (wk_type,filename);
    ;gsn_define_colormap(wks,"hlu_default")

    ;;; for tolerence cases
    ;gsn_define_colormap(wks,"MPL_winter")
    ;gsn_define_colormap(wks,"precip_11lev")
    res = True
    
    res@xyLineThicknesses = thickid
    ;res@xyLineColors      = 128-14*ispan(1,nzpdfid,1)
    res@xyLineColors      = colorid
    print((/res@xyLineColors/))
    ;print((/res@xyLineThicknesses/))
    res                   = True                      ; plot mods desired
    ;res@gsnDraw = False
    ;res@gsnFrame = False
    ;res@xyYStyle = "Log"
    res@tiXAxisString     = "Month"
    res@tiYAxisString     = "Z-score Failure (%)"
    res@tiMainString      = vars(v)
    res@pmLegendDisplayMode     = "Always"
    res@pmLegendSide     = "Right"
    res@pmLegendOrthogonalPosF     = -0.00
    res@pmLegendParallelPosF     = 0.6
    res@pmLegendWidthF     = 0.05
    res@pmLegendHeightF     = 0.4
    res@lgLabelFontHeightF     = 0.0156
    res@trXMinF = 1
    res@trXMaxF = 36
    res@trYMinF = 0
    res@trYMaxF = 100
    ;res@tmXBMode 	= "Manual"
    ;res@tmXBTickStartF  = 3
    ;res@tmXBTickEndF    = 36
    ;res@tmXBTickSpacingF= 3
    res@tmXBMode 	= "Explicit"
    res@tmXBValues	= ispan(3,36,3)
    res@tmXBLabels	= ispan(3,36,3)

    res@xyExplicitLabels = pertnameid
    ;end if
    plot=gsn_csm_xy(wks,ispan(1,36,1),zpdfid(v,:,:),res)     ; create plot
    system("convert -trim "+filename+".png " +filename+".png")
  end do
end
