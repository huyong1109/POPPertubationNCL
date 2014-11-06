
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  begin
time="01"
vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
pert=(/"6", "8", "10","12", "14", "csi", "np", "tol.10", "tol.11", "tol.12", "tol.14", "tol.16"/)
root ="$WORK/NCOUT/rmsz/"
cntrfile=root+"perturb.T.h."+time+"-14-np.nc"
nvars = dimsizes(vars)
npert = dimsizes(pert)

  fin=addfile(cntrfile,"r")
  rmsz = fin->RMSZ
  do n =0,nvars-1
  x = rmsz(n,:)
  maxx = ceil(max(x))
  minx = floor(max(x))
  xy = fspan(0,3,npert)
  print("xy = ")
  print((/xy/))
  print("x = ")
  print((/x/))
  y = new(npert, "float")
  do k =0,npert-1
  cmd = "grep '"+vars(n)+": RMSZ score '  ./validation/validationtest-"+time+"-"+pert(k)+".log |awk '{print $6}'"
  y(k) = stringtofloat(systemfunc(cmd))
  end do
  print("y = ")
  print((/y/))

  wks = gsn_open_wks("X11","RMSZ-"+vars(n)+"-"+time)
  gsn_define_colormap(wks,"amwg")
  
  res = True
  res@gsnHistogramClassIntervals = fspan(minx,maxx,5)   ; explicitly set the histogram bins
  res@trYMaxF = 3.5                                 ; set the maximum Y-axis value
  res@trXMaxF = 10.                                 ; set the maximum Y-axis value
  res@tiMainString = "RMSZ "+vars(n)+" "+time                                 ; set the maximum Y-axis value
  res@tiXAxisString = "Root Mean Square Z-score "                                 ; set the maximum Y-axis value
  res@gsnHistogramBarWidthPercent = 100.            ; set the bar width to 100% of bin size
  res@gsFillColor = "gray70"                        ; color fill the bars gray 
  res@gsEdgeColor = res@gsFillColor                 ; set the bar edge to the same color as the bar itself
  res@gsnDraw = False                               ; do not draw the plot
  res@gsnFrame = False                              ; do not advance the frame
  res@tiXAxisOn = False                             ; turn off the X-axis title
  res@tiYAxisOn = False                             ; turn off the Y-axis title

  plot = gsn_histogram(wks,x,res)                   ; create the 1st histogram



  dum = new(npert,graphic)
  colors=ispan(1,npert*2-1,2)
  do k = 0,npert-1

  res2 = True                                       
  res2@gsMarkerIndex = k+1
  res2@gsMarkerColor = colors(k)
  res2@gsMarkerSizeF= 0.02
  res2@gsMarkerThicknessF= 5.

  dum(k) = gsn_add_polymarker(wks,plot,y(k),xy(k),res2)                 ; create the 2nd histogram
  end do

  ; You can't use gsnMaximize above to maximize plots in the frame,
  ; because you will be maximizing the individual plots, and not
  ; the two of them together.
  ;
  ; Instead, after the plots have been created, 
  ; maximize them with the maximize_output procedure.
  ;
  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = True          ; Necessary to control sizes
  lbres@vpWidthF           = 0.2      ; labelbar width
  lbres@vpHeightF          = 0.3      ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = colors ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.04          ; font height. default is small
  ;lbres@lbLabelJust = "CenterRight"
  lbres@lbLabelPosition = "Right"

  lbid = gsn_create_labelbar(wks,npert,pert,lbres)
  
  amres                  = True
  amres@amJust           = "TopRight"
  amres@amParallelPosF   =  0.5
  amres@amOrthogonalPosF = -0.5
  annoid = gsn_add_annotation(plot,lbid,amres)


  psres = True
  psres@gsnPaperOrientation = "portrait"
  maximize_output(wks,psres)
  delete(y)
  delete(dum)
  end do

  delete(xy)

  end
