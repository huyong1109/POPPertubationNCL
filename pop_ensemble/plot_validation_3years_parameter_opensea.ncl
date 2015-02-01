
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  begin
year=(/"1","2","3"/)
time=sprinti("%0.2i",ispan(1,12,1))
;print(time)
vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
pert=(/ "year.tol.10", "year.tol.11", "year.tol.12", "year.tol.14", "year.tol.16","year.csi", "year"/)
pertname=(/ "ChronGear + tolerance (1.0e-10)", "ChronGear + tolerance (1.0e-11)", "ChronGear + tolerance (1.0e-12)", "ChronGear + tolerance (1.0e-14)", "ChronGear + tolerance (1.0e-16)","P-CSI  + tolerance (1.0e-13)", "Default Configuration", "Ensemb min","Ensemb max"/)
;pert=(/"year.tol.12", "year.tol.14", "year.tol.16","year.csi", "year"/)
;pertname=(/  "tol.12", "tol.14", "tol.16","csi", "origin", "Ensemb min","Ensemb max"/)

;pert=(/ "tol.14", "tol.16","csi", "np"/)
;pertname=(/ "tol.14", "tol.16","csi", "origin", "Ensemb min","Ensemb max"/)

nyear = dimsizes(year)
ntime = dimsizes(time)
nvars = dimsizes(vars)
npert = dimsizes(pert)
pref  ="./validation_opensea_3years/validationtest-"
suf  ="-41cases.log "
y = new((/nvars,npert+2,nyear*ntime/),"float")
  do i = 0,nyear-1
  do m = 0,ntime-1
  do n =0,nvars-1
  do k =0,npert-1
  cmd = "grep '"+vars(n)+": RMSZ score '  "+pref+year(i)+"-"+time(m)+"-"+pert(k)+suf+" |awk '{print $6}'"
  y(n,k,m+i*ntime) = stringtofloat(systemfunc(cmd))
  end do
  cmd = "grep '"+vars(n)+" (RMSZ): min '  "+pref+year(i)+"-"+time(m)+"-"+pert(0)+suf+" |awk '{print $6}'"
  y(n,npert,m+i*ntime) = stringtofloat(systemfunc(cmd))
  cmd = "grep '"+vars(n)+" (RMSZ): min '  "+pref+year(i)+"-"+time(m)+"-"+pert(0)+suf+" |awk '{print $12}'"
  y(n,npert+1,m+i*ntime) = stringtofloat(systemfunc(cmd))

  end do
  end do
  end do
  ;;; special case for SSH

  ;print(y)
;************************************************
; plotting Global Mean
;************************************************
do i = 0, nvars-1

;************************************************
; plotting parameters
;************************************************
wk_type = "x11"
wk_type@wkWidth = 2500
wk_type@wkHeight= 2500
filename = vars(i)+"-RMSZ-ens40-3y-tol-opensea"
wks   = gsn_open_wks (wk_type,filename)                  ; open workstation
gsn_define_colormap(wks,"amwg")

res                   = True                      ; plot mods desired

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
thick = new(npert,float)
thick = 14.0
res@xyLineThicknesses = thick
;res@xyLineThicknesses = (/ 16.0, 4.0,4.0,4.0,4.0,8.0,8.0/)               ; for success
res@xyLineColors = (/"black","RoyalBlue","darkslategray",\
             "SlateBlue","lightseagreen","firebrick","hotpink","navy","orange"/)
;res@xyLineColors      = ispan(1,10*(npert+2),10)          ; for tol.10, tol.11 cases
;res@xyLineColors      = ispan(21,10*(npert+4),10)          ; change line color
res@xyMarkers      = ispan(1,npert+2,1)          ; change line color
res@xyMarkerSizeF      = 0.3
res@xyYStyle = "Log"
res@tiXAxisString     = "Simulation Months"         ; change line color
res@tiYAxisString     = "RMSZ"         ; change line color
;res@tiMainString     = vars(i)         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Bottom"
res@pmLegendOrthogonalPosF     = -0.44
;res@pmLegendParallelPosF     = 0.86
res@lgPerimOn     = False
res@xyDashPatterns = ispan(1,2*(npert+2),2)
res@pmLegendWidthF     = 0.10
res@pmLegendHeightF     = 0.15
res@lgLabelFontHeightF     = 0.014
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4

res@xyExplicitLabels = pertname
res@gsnMaximize =True
res@gsnDraw = False
res@gsnFrame = False
res@trComputeYmin = True
res@trComputeYmax = True
res@trComputeXmin = True
res@trComputeXmax = True
res@trXminF = 1
res@trXmaxF = 36
res@trYminF = min(y(i,:,:))
print(min(y(i,:,:)))
res@trYmaxF = max(y(i,:,:))

plot  = gsn_csm_xy (wks,ispan(1,36,1),y(i,0:npert-1,:),res) ; create plot

gsres                   = True                        ; poly res
 gsres@tfPolyDrawOrder   = "Predraw"                   ; draw this first
 gsres@gsFillColor       = "gold"                 ; color chosen
 polyx = array_append_record(ispan(1,36,1),ispan(36,1,1),0)
  ;print(polyx)
 polyy = array_append_record(y(i,npert,:),y(i,npert+1,::-1),0)
  ;print(polyy)
 dummy = gsn_add_polygon (wks,plot,polyx,polyy,gsres)
draw(plot)
frame(wks)
delete(wks)
;system("convert -trim "+filename+".png " +filename+".png")
end do


  end

