load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  vars=(/"UVEL","VVEL","TEMP","SALT","VDC_T","VDC_S","SSH","IFRAC"/)
  pert= asciiread("testcases.name",-1, "string")
  print(pert)
  pertname=(/ "Orignal","P48","P192","P384","tol=5e-9", "tol=e-9","tol=5e-10", "tol=e-10", "tol=e-11", "tol=e-12", "tol=e-14","tol=e-15","tol=e-16", "cnvctdiff*2","cnvctdiff*5","cnvctdiff*10","advt=lw_lim" /)
  ;pertname = pert
  colors = (/"yellow","purple4","blue4","red4", "green","orange","seagreen3","dodgerblue",   "darkorchid", "darkslategrey", "red", "navy", "orangered4","orangered4","navy","red","dodgerblue"/) ;"deepskyblue","dodgerblue","darksalmon","darkseagreen","darkorchid","deeppink","firebrick",
  ;thicks = (/30,10,10,10,10,10,30,27,24,21,18,15,12,9,6,15,20,25,30,30/)
  ;thicks = new(17,"float")
  ;thicks = 20
  ;thicks(0) = 30
  ;thicks(1:3) = 15
  ;thicks(4:8) = 10
  npert = dimsizes(pert)
  ;;; pick out the cases you want to plot 

  ;caseid = ispan(0,npert-1,1) ; all cases
  ;casetitle = ""

  caseid = ispan(0,3,1) ; layout cases
  casetitle = "layout"

  ;caseid = array_append_record((/0/),ispan(4,12,1),0); different tolerance cases
  ;casetitle = "tol"

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
  	

  	zpdf = new((/6, nmon*nyear,nvar,npert/),float)

  	;;; read in layout and parameter cases
  	tmpzpdf1 := asciiread("testcases.result.10ens.openseas",(/nyear*nmon,nvar,npert,npdf/),"float")*100
  	tmpzpdf2 := asciiread("testcases.result.20ens.openseas",(/nyear*nmon,nvar,npert,npdf/),"float")*100
  	tmpzpdf3 := asciiread("testcases.result.30ens.openseas",(/nyear*nmon,nvar,npert,npdf/),"float")*100
  	tmpzpdf4 := asciiread("testcases.result.40ens.openseas",(/nyear*nmon,nvar,npert,npdf/),"float")*100
  	tmpzpdf5 := asciiread("testcases.result.50ens.openseas",(/nyear*nmon,nvar,npert,npdf/),"float")*100
  	tmpzpdf6 := asciiread("testcases.result.60ens.openseas",(/nyear*nmon,nvar,npert,npdf/),"float")*100
        do i = 0,35
		do j = 0, 7
			do k = 0, 16
			print(i+" " + j+ " " + " sum-zpdf1 "+ sum(tmpzpdf1(i,j,k,:)))
			print(i+" " + j+ " " + " sum-zpdf2 "+ sum(tmpzpdf2(i,j,k,:)))
			print(i+" " + j+ " " + " sum-zpdf3 "+ sum(tmpzpdf3(i,j,k,:)))
			print(i+" " + j+ " " + " sum-zpdf4 "+ sum(tmpzpdf4(i,j,k,:)))
			print(i+" " + j+ " " + " sum-zpdf5 "+ sum(tmpzpdf5(i,j,k,:)))
			print(i+" " + j+ " " + " sum-zpdf6 "+ sum(tmpzpdf6(i,j,k,:)))
end do 
end do 
end do 
  	
  	do i = 1, npdf-1
  	  tmpzpdf1(:,:,:,i) = tmpzpdf1(:,:,:,i)+tmpzpdf1(:,:,:,i-1)
  	  tmpzpdf2(:,:,:,i) = tmpzpdf2(:,:,:,i)+tmpzpdf2(:,:,:,i-1)
  	  tmpzpdf3(:,:,:,i) = tmpzpdf3(:,:,:,i)+tmpzpdf3(:,:,:,i-1)
  	  tmpzpdf4(:,:,:,i) = tmpzpdf4(:,:,:,i)+tmpzpdf4(:,:,:,i-1)
  	  tmpzpdf5(:,:,:,i) = tmpzpdf5(:,:,:,i)+tmpzpdf5(:,:,:,i-1)
  	  tmpzpdf6(:,:,:,i) = tmpzpdf6(:,:,:,i)+tmpzpdf6(:,:,:,i-1)
  	end do 
 
  	;print((/tmpzpdf(0:5,2:4,0,npdf-1)/))
  do i = 1, 4
  	Tolpdf = i*10-1
        print(i)
        print(Tolpdf)
  	
  	zpdf(0, :,:,0:npert-1) = 100-tmpzpdf1(:,:,0:npert-1,Tolpdf)
  	zpdf(1, :,:,0:npert-1) = 100-tmpzpdf2(:,:,0:npert-1,Tolpdf)
  	zpdf(2, :,:,0:npert-1) = 100-tmpzpdf3(:,:,0:npert-1,Tolpdf)
  	zpdf(3, :,:,0:npert-1) = 100-tmpzpdf4(:,:,0:npert-1,Tolpdf)
  	zpdf(4, :,:,0:npert-1) = 100-tmpzpdf5(:,:,0:npert-1,Tolpdf)
  	zpdf(5, :,:,0:npert-1) = 100-tmpzpdf6(:,:,0:npert-1,Tolpdf)
  	
  	zpdf!0 = "ens"
  	zpdf!1 = "time"
  	zpdf!2 = "var"
  	zpdf!3 = "case"
  	zpdfreorder = zpdf(var|:,case|:,time|:,ens|:)
 

  	filename = "EnsSize-PercentTol_"+Tolpdf
  	wk_type = "png"
  	wk_type = "x11"
  	wk_type@wkWidth = 2500
  	wk_type@wkHeight = 2500
  	wks   = gsn_open_wks (wk_type,filename);
  	res = True
  	
  	res@xyLineThicknesses = (/20, 20, 20,20,20, 20, 20,20/)
  	res@xyLineColors      = (/"green","orange","seagreen3","dodgerblue", "darkorchid", "darkslategrey", "red", "navy"/)
  	print((/res@xyLineColors/))
  	;print((/res@xyLineThicknesses/))
  	res                   = True                      ; plot mods desired
  	res@tiXAxisString     = "Ensemble size"
  	res@tiYAxisString     = "Zscore Failure (%)"
  	res@tiMainString      = "Percentage of Zscore greater than "+i
  	res@pmLegendDisplayMode     = "Always"
  	res@pmLegendSide     = "Right"
  	res@pmLegendOrthogonalPosF     = -0.0
  	res@pmLegendParallelPosF     = 0.6
  	res@pmLegendWidthF     = 0.06
  	res@pmLegendHeightF     = 0.4
  	res@lgLabelFontHeightF     = 0.02
  	res@trXMinF = 10
  	res@trXMaxF = 60
  	;res@trYMinF = 0
  	;res@trYMaxF = 100

  	res@xyExplicitLabels = vars
  	;end if
  	plot=gsn_csm_xy(wks,ispan(10,60,10),zpdfreorder(:,0,11,:),res)     ; create plot
  	system("convert -trim "+filename+".png " +filename+".png")
  end do 
end
