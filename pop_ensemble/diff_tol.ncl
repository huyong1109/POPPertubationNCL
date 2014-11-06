load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
pert = (/10,11,12,14,16/)
npert = dimsizes(pert)
ptlim = new(npert, string)
pertname = new(npert, string)
do i = 0, npert-1
    pertname(i) = pert(i)
    ptlim(i) = "1.0e-"+pert(i)
end do 
print((/pertname/))
print((/ptlim/))
suf = array_append_record("csi", pertname, 0)
linlabl = array_append_record("csi",ptlim, 0) 
print((/suf/))
print((/linlabl/))
path = "$WORK/NCOUT/rmse_tol/"
pre = "rmse_TOL_"


;;;; get dimension sizes
filename = path+pre+suf(0)+".nc"
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
nfiles = dimsizes(suf)

do i=0, dimsizes(vNames)-1
    if (getfilevartypes(fT,vNames(i)) .eq. "float") then
        vIncfloat(i) = True
    end if 
end do 
funs = vNames(ind(vIncfloat))
nfuns = dimsizes(funs)

print((/nvars, nfuns, nfiles, nmon/))

data = new((/nvars, nfuns, nfiles, nmon/), float)
do i = 0, nfiles -1
    ; for T files
    filename = path+pre+suf(i)+".nc"
    print(filename)
    fT     = addfile (filename, "r")

    data(:,0,i,:)    = fT->RMSE(:,:) ; get rmse
    data(:,1,i,:)    = fT->MAXE(:,:) ; get max error
    data(:,2,i,:)    = fT->COVC(:,:) ; get cross convariance
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
print((/XT(ivar)+"_"+funs(ifun)/))
wks   = gsn_open_wks ("X11",XT(ivar)+"_"+funs(ifun))                  ; open workstation

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

colors = (/"black","red","blue","green","pink","purple"/)
res@xyLineThicknesses = (/3.0, 3.0,3.0,3.0,3.0,3.0/)               ; make 2nd lines thicker
;res@xyLineThicknesses = (/3.0, 1.0,1.0,1.0,3.0,3.0,3.0/)               ; make 2nd lines thicker
res@xyLineColors      = colors          ; change line color
res@xyDashPatterns      = ispan(0,2*nfiles,2)          ; change line color
res@tiXAxisString     = "Simulation Months"         ; change line color
res@tiYAxisString     = funs(ifun)         ; change line color
res@tiMainString     = XT(ivar)+" "+funs(ifun)+" TOLERANCE"         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.8
res@pmLegendParallelPosF     = 0.80
res@lgPerimOn     = False

res@pmLegendWidthF     = 0.15
res@pmLegendHeightF     = 0.15
res@lgLabelFontHeightF     = 0.02
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4
res@xyExplicitLabels = linlabl

plot  = gsn_csm_xy (wks,month,data( ivar,ifun,:,:),res) ; create plot
end do
end do

end 

