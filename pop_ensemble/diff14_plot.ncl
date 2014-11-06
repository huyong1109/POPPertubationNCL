load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
pert = (/91, 71, 51 , 41 ,21, 1/)
pertty = (/"T", "TS"/)
npert = dimsizes(pert)
ptlim = new(npert, float)
do i = 0, npert-1
    if ( pert(i) .eq. 0) then 
        ptlim(i) = 0.0
    else if( pert(i) .lt. 51)  then
        ptlim(i) = (pert(i) +9 )*0.1e-14
    else 
        ptlim(i) = -(pert(i) -41 )*0.1e-14
    end if
    end if

end do 
pertname = sprinti("%0.2i", pert)
ptlimname = sprintf("%2.1E", ptlim)
print((/pertname/))
print((/ptlim/))
suf = array_append_record("csi", pertname, 0)
linlabl = array_append_record("csi",ptlimname, 0) 
;linlabl = suf ;;;;; test for disorder
;suf = pertname
;linlabl = ptlimname
print((/suf/))
print((/linlabl/))
path = "$WORK/NCOUT/rmse_maxe/"
pre = new(2, string)
do i = 0,1
pre(i) = "rmse_"+pertty(i)+"14_"
end do 


;;;; get dimension sizes
filename = path+pre(0)+suf(0)+".nc"
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

data = new((/2, nvars, nfuns, nfiles, nmon/), float)
do ptty = 0,1
do i = 0, nfiles -1
    ; for T files
    filename = path+pre(ptty)+suf(i)+".nc"
    print(filename)
    fT     = addfile (filename, "r")

    data(ptty,:,0,i,:)    = fT->RMSE(:,:) ; get rmse
    data(ptty,:,1,i,:)    = fT->MAXE(:,:) ; get max error
    data(ptty,:,2,i,:)    = fT->COVC(:,:) ; get cross convariance
end do
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
do pttyp = 0, 1
do ifun = 0, nfuns-1
do ivar = 0, nvars-1
;************************************************
; plotting parameters
;************************************************
print(XT)
print(funs)
print((/XT(ivar)+"_"+funs(ifun)+"_"+pertty(pttyp)/))
wks   = gsn_open_wks ("X11",XT(ivar)+"_"+funs(ifun)+"_"+pertty(pttyp))                  ; open workstation

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

colors = (/"black","red","blue","green","pink","purple","gray"/)
res@xyLineThicknesses = (/3.0, 3.0,3.0,3.0,3.0,3.0,3.0/)               ; make 2nd lines thicker
;colors = (/"black", "red","blue","green","red","blue","green"/)
;res@xyLineThicknesses = (/3.0, 1.0,1.0,1.0,3.0,3.0,3.0/)               ; make 2nd lines thicker
res@xyLineColors      = colors          ; change line color
res@xyDashPatterns      = ispan(0,2*nfiles,2)          ; change line color
res@tiXAxisString     = "Simulation Months"         ; change line color
res@tiYAxisString     = funs(ifun)         ; change line color
res@tiMainString     = XT(ivar)+" "+funs(ifun)+" "+pertty(pttyp)+" pertubation"         ; change line color
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

plot  = gsn_csm_xy (wks,month,data(pttyp, ivar,ifun,:,:),res) ; create plot
end do
end do
end do

end 

