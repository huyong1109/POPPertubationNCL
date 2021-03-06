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
  enssize = ispan(10,50,10) 
  nens = dimsizes(enssize) 
  randid = ispan(1,10,1)
  nrand = dimsizes(randid)
  npdf = 40
  Tolpdf = 30
  path="/glade/p/work/huyong/verify/EnsSize/"
  tmpzpdf = new((/5,10,10,nvar,npdf/),float)
  zpdf = new((/nvar,5,5/),float)


  do i = 0,nens-1 
  do j = 0,nrand-1
  	filename = path+"testcase."+enssize(i)+"."+randid(j)+".result"
  	print((/filename/))
	tmpzpdf(i,j,:,:,:) = asciiread(filename,(/10,nvar,npdf/),"float")*100
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
	q = reshape(tmpzpdf1(j,:,:,i),(/100/))
	qsort(q)
  	zpdf(i,j,0) = q(0)
  	zpdf(i,j,1) = q(24)
  	zpdf(i,j,2) = q(49)
  	zpdf(i,j,3) = q(74)
  	zpdf(i,j,4) = q(99)
  end do 
  end do 
	
  do  v = 0,nvar-1	
  	filename = "EnsSize_box_"+vars(v)
  	wk_type = "x11"
  	wk_type = "png"
  	wk_type@wkWidth = 2500
  	wk_type@wkHeight = 2500
  	wks   = gsn_open_wks (wk_type,filename);
  	res = True
  	
  	res                   = True                      ; plot mods desired
  	res@tiXAxisString     = "Ensemble size"
  	res@tiYAxisString     = "Z-score Failure (%)"
  	res@tiMainString      = vars(v)
    	res@trXMinF = 5
    	res@trXMaxF = 55
	lres = True
	lres@gsLineThicknessF = 8
	opti = True
	opti@boxWidth = 3
	opti@boxColors = "blue"
  	plot=boxplot(wks,ispan(10,50,10),zpdf(v,:,:),opti,res,lres)     ; create plot
	draw(wks)
	frame(wks)
	
  	system("convert -trim "+filename+".png " +filename+".png")
  end do 
end
