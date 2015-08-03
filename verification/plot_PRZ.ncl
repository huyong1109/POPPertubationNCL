load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  vars=(/"UVEL","VVEL","TEMP","SALT","VDC_T","VDC_S","SSH","IFRAC"/)
  pert= asciiread("testcases.name",-1, "string")
  print(pert)
  ;pertname=(/ "Orignal","P96b40x33", "P96b20x16", "P48","P192","P384","tol=5e-9", "tol=e-9","tol=5e-10", "tol=e-10", "tol=e-11", "tol=e-12", "tol=e-14", "tol=e-16","csi", "convectdiff x2","convectdiff x5","convectdiff x10","tadvect=lw_lim" /)
  pertname = pert
  colors = (/"yellow","purple4","pink4","blue4","red","forestgreen","paleturquoise2","peachpuff2","palegreen2","olivedrab3","orange3","palevioletred3","orchid4","orangered4", "cadetblue4","purple3","royalblue3","seagreen3","pink3", "darkslategray1"/) ;"deepskyblue","dodgerblue","darksalmon","darkseagreen","darkorchid","deeppink","firebrick",
  thicks = (/30,10,10,10,10,10,30,27,24,21,18,15,12,9,6,15,20,25,30,30/)
  npert = dimsizes(pert)
  ;;; pick out the cases you want to plot 

  caseid = ispan(0,npert-1,1) ; all cases
  casetitle = ""

  ;caseid = ispan(0,5,1) ; layout cases
  ;casetitle = "layout"

  ;caseid = array_append_record((/0/),ispan(6,13,1),0); different tolerance cases
  ;casetitle = "tol"

  ;caseid = array_append_record((/0/),ispan(15,18,1),0) ; different physical parameter cases
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
  print((/tmpzpdf(0:5,2:3,0,:)/))
  
  do i = 1, npdf-1
    tmpzpdf(:,:,:,i) = tmpzpdf(:,:,:,i)+tmpzpdf(:,:,:,i-1)
  end do 
  print((/tmpzpdf(0:5,2:4,0,npdf-1)/))
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
  print((/caseid/))
  print("nzpdfid = "+nzpdfid)

  zpdfid  = zpdf(:,ind(caseindex),:)
  printVarSummary(zpdfid)
  

  pertnameid  = pertname(ind(caseindex))
  colorid  = colors(ind(caseindex))
  thickid  = thicks(ind(caseindex))

  do v = 0, nvar-1
    filename = "PRZ-Zscore-PercentTol_"+Tolpdf+"-"+vars(v)+"-"+casetitle+"Y0-100"
    ;wk_type = "png"
    wk_type = "x11"
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
    ;print((/res@xyLineColors/))
    ;print((/res@xyLineThicknesses/))
    res                   = True                      ; plot mods desired
    ;res@gsnDraw = False
    ;res@gsnFrame = False
    ;res@xyYStyle = "Log"
    res@tiXAxisString     = "Month"
    res@tiYAxisString     = "Zscore Failure (%)"
    res@tiMainString      = vars(v)
    res@pmLegendDisplayMode     = "Always"
    res@pmLegendSide     = "Right"
    res@pmLegendOrthogonalPosF     = -0.0
    res@pmLegendParallelPosF     = 0.6
    res@pmLegendWidthF     = 0.05
    res@pmLegendHeightF     = 0.40
    res@lgLabelFontHeightF     = 0.01
    res@trXMinF = 1
    res@trXMaxF = 36
    res@trYMinF = 0
    res@trYMaxF = 100

    res@xyExplicitLabels = pertnameid
    ;end if
    plot=gsn_csm_xy(wks,ispan(1,36,1),zpdfid(v,:,:),res)     ; create plot
    system("convert -trim "+filename+".png " +filename+".png")
  end do
end
