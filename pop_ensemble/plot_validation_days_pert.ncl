
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  begin
time=(/"02","03","04","05","06","07","08","09","10","11","12","13","14","15"/)
vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
pert=(/"6", "8", "10","12", "14", "csi", "np"/)
pertname=(/"pert.6", "pert.8", "pert.10","pert.12", "pert.14", "csi", "origin", "Ensemb min","Ensemb max"/)
ntime = dimsizes(time)
nvars = dimsizes(vars)
npert = dimsizes(pert)
y = new((/nvars,npert+2,ntime/),"float")
  do m = 0,ntime-1
  do n =0,nvars-1
  do k =0,npert-1
  cmd = "grep '"+vars(n)+": RMSZ score '  ./validation/validationtest-day"+time(m)+"-"+pert(k)+".log |awk '{print $6}'"
  cmd = "grep '"+vars(n)+": RMSZ score '  ./validation/validationtest-day"+time(m)+"-"+pert(k)+".log |awk '{print $6}'"
  y(n,k,m) = stringtofloat(systemfunc(cmd))
  end do
  if(n .ne. nvars-1)  then
  cmd = "grep '"+vars(n)+" (RMSZ): min'  ./validation/validationtest-day"+time(m)+"-"+pert(0)+".log |awk '{print $6}'"
  y(n,npert,m) = stringtofloat(systemfunc(cmd))
  ;print((/y(n,npert,m)/))
  cmd = "grep '"+vars(n)+" (RMSZ): min'  ./validation/validationtest-day"+time(m)+"-"+pert(0)+".log |awk '{print $12}'"
  ;print(cmd)
  y(n,npert+1,m) = stringtofloat(systemfunc(cmd))
  ;print((/y(n,npert+1,m)/))
  else 
  cmd = "grep '"+vars(n)+": min'  ./validation/validationtest-day"+time(m)+"-"+pert(0)+".log |awk '{print $5}'"
  ;print(cmd)
  y(n,npert,m) = stringtofloat(systemfunc(cmd))
  ;print((/y(n,npert,m)/))
  cmd = "grep '"+vars(n)+": min'  ./validation/validationtest-day"+time(m)+"-"+pert(0)+".log |awk '{print $11}'"
  ;print(cmd)
  y(n,npert+1,m) = stringtofloat(systemfunc(cmd))
  ;print((/y(n,npert+1,m)/))
    end if
  end do
  end do

  ;;; special case for SSH

  print(y)
;************************************************
; plotting Global Mean
;************************************************
do i = 0, nvars-1

;************************************************
; plotting parameters
;************************************************
wks   = gsn_open_wks ("png",vars(i)+"-RMSZ-pert-15days")                  ; open workstation
gsn_define_colormap(wks,"amwg")

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/3.0,3.0,3.0,3.0,3.0,3.0,3.0,4.0,4.0/)               ; make 2nd lines thicker

res@xyLineColors      = ispan(1,20*(npert+2),20)          ; change line color
res@xyYStyle = "Log"
res@tiXAxisString     = "Days"         ; change line color
res@tiYAxisString     = "RMSZ Perturbation cases"         ; change line color
res@tiMainString     = vars(i)+" RMSZ"         ; change line color
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

plot  = gsn_csm_xy (wks,ispan(2,ntime+1,1),y(i,:,:),res) ; create plot
end do

  end

