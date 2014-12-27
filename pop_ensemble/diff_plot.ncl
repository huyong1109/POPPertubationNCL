load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
suf1 = array_append_record("csi", tostring(ispan(2,14,2)), 0)
suf2 = array_append_record((/"csi", "3"/), tostring(ispan(4,14,2)), 0)
label1 = array_append_record("csi", str_insert(tostring(ispan(2,14,2)),"1.0e-",0),0)
label2 = array_append_record("csi", str_insert(array_append_record("3",tostring(ispan(4,14,2)),0),"1.0e-",0),0)
print((/suf1/))
print((/suf2/))
path = "$WORK/NCOUT/rmse_maxe/"
pre1 = "rmse_T_"
pre2 = "rmse_TS_"

;;;; get dimension sizes
filename = path+pre1+suf1(0)+".nc"
print((/filename/))
fT     = addfile (filename, "r")
vardef = fT->vars
rmse   = fT->RMSE
XT     = tostring(fT->vars)
vNames = getfilevarnames(fT)
vIncfloat = new(dimsizes(vNames), logical)
vIncfloat(:) = False

dim = dimsizes(rmse)
nvars = dim(0)
nmon = dim(1)
nfiles = dimsizes(suf1)

do i=0, dimsizes(vNames)-1
    if (getfilevartypes(fT,vNames(i)) .eq. "float") then
        vIncfloat(i) = True
    end if 
end do 
funs = vNames(ind(vIncfloat))
nfuns = dimsizes(funs)

print((/nvars, nfuns, nfiles, nmon/))

data1 = new((/nvars, nfuns, nfiles, nmon/), float)
data2 = new((/nvars, nfuns, nfiles, nmon/), float)

do i = 0, nfiles -1
    ; for T files
    filename = path+pre1+suf1(i)+".nc"
    
    ;print(filename)
    fT     = addfile (filename, "r")

    data1(:,0,i,:)    = fT->RMSE(:,:) ; get rmse
    data1(:,1,i,:)    = fT->MAXE(:,:) ; get max error
    data1(:,2,i,:)    = fT->COVC(:,:) ; get cross convariance
    ; for TS files 
    filename = path+pre2+suf2(i)+".nc"
    fTS    = addfile (filename,"r")
    data2(:,0,i,:)    = fTS->RMSE(:,:) ; get rmse
    data2(:,1,i,:)    = fTS->MAXE(:,:) ; get max error
    data2(:,2,i,:)    = fTS->COVC(:,:) ; get cross convariance
end do
;print(data1)
;print(data2)

;************************************************
; to plot multiple lines, you must put them into
; a mulidimensional array
;************************************************

month = ispan(1, nmon, 1)
month@units = "month"
printVarSummary(month)

;************************************************
; plotting Global Mean
;************************************************
do ifun = 0, nfuns-1
do ivar = 0, nvars-1
;************************************************
; plotting parameters
;************************************************
print(XT)
print(funs)
print((/XT(ivar)+"_"+funs(ifun)+"_T"/))
wks   = gsn_open_wks ("png",XT(ivar)+"_"+funs(ifun)+"_T")                  ; open workstation

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

colors = (/"red","blue","orange","black","red","blue","orange","black"/)
res@xyLineThicknesses = (/3.0,3.0,1.0,3.0,1.0,3.0,1.0,3.0/)               ; make 2nd lines thicker
res@xyLineColors      = colors          ; change line color
res@xyDashPatterns      = ispan(0,nfiles,1)          ; change line color
res@tiXAxisString     = "Simulation Months"         ; change line color
res@tiYAxisString     = funs(ifun)         ; change line color
res@tiMainString     = XT(ivar)+" "+funs(ifun)+" T pertubation"         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.6
res@pmLegendParallelPosF     = 0.85
res@lgPerimOn     = False

res@pmLegendWidthF     = 0.15
res@pmLegendHeightF     = 0.15
res@lgLabelFontHeightF     = 0.02
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4
res@xyExplicitLabels = label1;str_insert(suf1,"1.0e-",0)

plot  = gsn_csm_xy (wks,month,data1(ivar,ifun,:,:),res) ; create plot
end do
end do

;************************************************
; plotting TS
;************************************************

do ifun = 0, nfuns-1
do ivar = 0, nvars-1
;************************************************
; plotting parameters
;************************************************
print(XT)
print(funs)
print((/XT(ivar)+"_"+funs(ifun)+"_TS"/))
wks   = gsn_open_wks ("png",XT(ivar)+"_"+funs(ifun)+"_TS")                  ; open workstation

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

colors = (/"red","blue","orange","black","red","blue","orange","black"/)
res@xyLineThicknesses = (/3.0,3.0,1.0,3.0,1.0,3.0,1.0,3.0/)               ; make 2nd lines thicker
res@xyLineColors      = colors          ; change line color
res@xyDashPatterns      = ispan(0,nfiles,1)          ; change line color
res@tiXAxisString     = "Simulation Months"         ; change line color
res@tiYAxisString     = funs(ifun)         ; change line color
res@tiMainString     = XT(ivar)+" "+funs(ifun)+" TS pertubation"         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.6
res@pmLegendParallelPosF     = 0.85
res@lgPerimOn     = False

res@pmLegendWidthF     = 0.15
res@pmLegendHeightF     = 0.15
res@lgLabelFontHeightF     = 0.02
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4
res@xyExplicitLabels = label2;str_insert(suf2,"1.0e-",0)

plot  = gsn_csm_xy (wks,month,data2(ivar,ifun,:,:),res) ; create plot
end do
end do

end 

