load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
;************************************************
; read in data
;************************************************
pert = (/10, 11,12,13,14/)
pertname = (/"year.tol.10","year.tol.11","year.tol.12","year","year.tol.14","year.csi"/)
npert = dimsizes(pert)
ptlim = new(npert, string)
do i = 0, npert-1
    ptlim(i) = "1.0e-"+pert(i)
end do 
print("pert")
print((/pert/))
print("pertname")
print((/pertname/))
linlabl = (/ "ChronGear + tolerance (1.0e-10)", "ChronGear + tolerance (1.0e-11)", "ChronGear + tolerance (1.0e-12)", "ChronGear + tolerance (1.0e-13)", "ChronGear + tolerance (1.0e-14)","P-CSI     + tolerance (1.0e-13)"/)
print("lines lable ")
print((/linlabl/))
path = "$WORK/NCOUT/rmse_tol16_opensea/"
pre = "rmse_TOL_"


;;;; get dimension sizes
filename = path+pre+pertname(0)+".nc"
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
nfiles = dimsizes(pertname)

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
    filename = path+pre+pertname(i)+".nc"
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

 asciiwrite("TEMP_tol_3year_RMSE.ascii",data(2,0,:,:))
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
wk_type = "x11"
wk_type@wkWidth = 2500
wk_type@wkHeight = 2500
wks   = gsn_open_wks (wk_type,XT(ivar)+"_"+funs(ifun))                  ; open workstation

res                   = True                      ; plot mods desired
res@tiMainString      = ""        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
;res@xyLineThicknesses = (/1.0,2.0/)               ; make 2nd lines thicker

colors = (/"black","RoyalBlue","darkslategray","hotpink","SlateBlue","firebrick"/)
res@xyLineThicknesses = (/14.0, 14.0,14.0,14.0,14.0,14.0/)               ; make 2nd lines thicker
;res@xyLineThicknesses = (/3.0, 1.0,1.0,1.0,3.0,3.0,3.0/)               ; make 2nd lines thicker
res@xyLineColors      = colors          ; change line color
res@xyDashPatterns      = ispan(1,2*nfiles,2)          ; change line color
res@xyMarkers      = ispan(1,nfiles+2,1)          ; change line color
res@xyMarkerSizeF      = 0.3
res@tiXAxisString     = "Simulation Months"         ; change line color
res@tiYAxisString     = funs(ifun)         ; change line color
;res@tiMainString     = XT(ivar)+" "+funs(ifun)+" TOLERANCE"         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.75
res@pmLegendParallelPosF     = 0.85
res@lgPerimOn     = False

res@pmLegendWidthF     = 0.10
res@pmLegendHeightF     = 0.15
res@lgLabelFontHeightF     = 0.014
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4
res@xyExplicitLabels = linlabl

plot  = gsn_csm_xy (wks,month,data( ivar,ifun,:,:),res) ; create plot
end do
end do

end 

