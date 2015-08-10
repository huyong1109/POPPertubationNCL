load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;************************************************
begin
  ;************************************************
  ; read in data
 
  vars=(/"TEMP","SSH"/)
  nvar = dimsizes(vars)
  nens = 6
  ntest = 10
  nrand = 100
  npdf = 40
  Tolpdf = 30

  enssize = ispan(10,nens*10,10) 
  randid = ispan(1,nrand,1)
  ;path="/glade/p/work/huyong/verify/EnsSize/"
  path="/glade/scratch/huyong/verify/"
  tmpzpdf = new((/nens,nrand,ntest,nvar,npdf/),float)
  zpdf = new((/nvar,nens,5/),float)


  do i = 0,nens-1 
  do j = 0,nrand-1
  	filename = path+"testcase."+enssize(i)+"."+randid(j)+".result"
  	print((/filename/))
	tmpzpdf(i,j,:,:,:) = asciiread(filename,(/ntest,nvar,npdf/),"float")*100
  	;print((/tmpzpdf(i,j,:,:,:)/))
  end do 
  end do 
  do i = 1, npdf-1
    tmpzpdf(:,:,:,:,i) = tmpzpdf(:,:,:,:,i)+tmpzpdf(:,:,:,:,i-1)
  end do 
  print((/tmpzpdf(:,:,:,:,Tolpdf)/))
  
  ;tmpzpdf1= reshape(tmpzpdf(:,:,:,:,Tolpdf), (/5, 100,nvar/))
  tmpzpdf1 = 100 - tmpzpdf(:,:,:,:,Tolpdf)

  print((/tmpzpdf1/))
  do  i = 0, nvar-1
  do  j = 0, nens-1
  	zmean = avg(tmpzpdf1(j,:,:,i))
  	zstd = stddev(tmpzpdf1(j,:,:,i))
  	zpdf(i,j,0) = min(tmpzpdf1(j,:,:,i))
  	zpdf(i,j,1) = zmean - zstd
  	zpdf(i,j,2) = zmean
  	zpdf(i,j,3) = zmean+zstd
  	zpdf(i,j,4) = max(tmpzpdf1(j,:,:,i))
  end do 
  end do 
	
  do  v = 0,nvar-1	
  	filename = "EnsSize80_"+vars(v)
  	wk_type = "x11"
  	wk_type = "png"
  	wk_type@wkWidth = 2500
  	wk_type@wkHeight = 2500
  	wks   = gsn_open_wks (wk_type,filename);
  	res = True
  	
  	res                   = True                      ; plot mods desired
	res@gsnDraw	      = False
	res@gsnFrame	      = False
  	res@tiXAxisString     = "Ensemble size"
  	res@tiYAxisString     = "Z-score Failure (%)"
  	res@tiMainString      = vars(v)
    	res@trXMinF = 5
    	res@trXMaxF = 10*nens+5
	res@xyLineThicknessF = 10
	res@xyLineColor  = "blue"
	res@xyMarkLineModes  = "Markers"
	res@xyMarker  = 6
	res@xyMarkerColor  = "firebrick"
	res@xyMarkerSizeF= 0.02
	res@xyMarkerThicknessF= 30
	;res@xyDashPattern  = 2
    	res@trYMinF = 0.0
    	res@trYMaxF = 3.0
  	;plot=boxplot(wks,ispan(10,50,10),zpdf(0,:,:),False,res,False)     ; create plot
  	plot=gsn_csm_xy(wks,enssize,zpdf(v,:,2),res)     ; create plot
	
	lres = True
	lres@gsLineColor = "darkgreen"
	dum = new(nens,graphic)
	dum1 = dum
	dum2 = dum
	do i = 0, nens-1
		lres@gsLineThicknessF = 10
		lres@gsLineDashPattern = 16
		dum(i) = gsn_add_polyline(wks,plot,(/enssize(i),enssize(i)/),(/zpdf(v,i,1), zpdf(v,i,3)/), lres)
		lres@gsLineThicknessF = 30
		lres@gsLineDashPattern = 0
		dum1(i) = gsn_add_polyline(wks,plot,(/enssize(i)-2,enssize(i)+2/),(/zpdf(v,i,1), zpdf(v,i,1)/), lres)
		dum2(i) = gsn_add_polyline(wks,plot,(/enssize(i)-2,enssize(i)+2/),(/zpdf(v,i,3), zpdf(v,i,3)/), lres)
 		
	end do 
	draw(wks)
	frame(wks)
	
  	system("convert -trim "+filename+".png " +filename+".png")
  end do 
end
