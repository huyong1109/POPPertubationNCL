
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  begin
time=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
pert=(/"6", "8", "10","12", "14", "csi", "np"/)
pertname=(/"pert.6", "pert.8", "pert.10","pert.12", "pert.14", "csi", "origin", "Ensemb min","Ensemb max"/)
ntime = dimsizes(time)
nvars = dimsizes(vars)
npert = dimsizes(pert)
Reg  = (/"Southern","Pacific","Indian","Persian","unknow","Atlantic","Mediterranean","Baffin","North","Arctic","Hudson"/)
nReg = dimsizes(Reg)
pref  ="./validation_seas/validationtest-"
suf  ="-41cases.log "
y = new((/nvars,npert+2,ntime,nReg/),"float")
  do m = 0,ntime-1
  do n =0,nvars-1
  do k =0,npert-1
  cmd = "grep '"+vars(n)+": RMSZ score '  "+pref+time(m)+"-"+pert(k)+suf+" |awk '{print $6}'"
  y(n,k,m,:) = stringtofloat(systemfunc(cmd))
  end do
  end do
  end do

  y(:,npert:npert+1,:,:) = asciiread(pref+"ens"+suf,(/nvars,2,ntime,nReg/),"float")
  ;;; special case for SSH

  print(y)
;************************************************
; plotting Global Mean
;************************************************
do i = 0, nvars-1

;************************************************
; plotting parameters
;************************************************
do iReg = 0,nReg -1
wks   = gsn_open_wks ("png",vars(i)+"-RMSZ-ensemble41-month-pert-"+Reg(iReg))                  ; open workstation
gsn_define_colormap(wks,"amwg")

res                   = True                      ; plot mods desired

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/4.0,4.0,4.0,4.0,4.0,4.0,4.0,8.0,8.0/)               ; make 2nd lines thicker

res@xyLineColors      = ispan(1,10*(npert+2),10)          ; change line color
res@xyMarkers      = ispan(1,npert+2,1)          ; change line color
res@xyMarkerSizeF      = 0.3
res@xyYStyle = "Log"
res@tiXAxisString     = "Month"         ; change line color
res@tiYAxisString     = "RMSZ"         ; change line color
res@tiMainString     = vars(i)+" "+Reg(iReg)         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.4
res@pmLegendParallelPosF     = 0.6
res@lgPerimOn     = False
res@xyDashPatterns = ispan(1,2*(npert+2),2)
res@pmLegendWidthF     = 0.10
res@pmLegendHeightF     = 0.40
res@lgLabelFontHeightF     = 0.02
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4
res@xyExplicitLabels = pertname

plot  = gsn_csm_xy (wks,ispan(1,12,1),y(i,:,:,iReg),res) ; create plot
end do
end do


  end

