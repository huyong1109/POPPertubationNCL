load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************
;************************************
begin

    print("In compare.ncl")
    print("testfile  :"+testfile)
    print("cntrlfile :"+cntrlfile)
    testin  = addfile(testfile ,"r")
    cntrlin = addfile(cntrlfile,"r")

    data1 = testin->$varname$
    data2 = cntrlin->$varname$
    data = data1;-data2
    printVarSummary(data1)
    printVarSummary(data)
    copy_VarMeta(data1,data)   ; copy metadata from data1 to data
    printVarSummary(data)

    lon = cntrlin->TLONG
    lat = cntrlin->TLAT


    ;************************************
    wks = gsn_open_wks("X11",outfile)      ; open a ps file
    res=True

    T=data(0,:,:)    ; first time step
    maxT = max(T)
    minT = min(T)
    mmax = max((/abs(maxT),abs(minT)/))
    print("max : "+maxT+"   minT : "+minT)
    ;T@lat2d = lat    ; necessary for plotting
    ;T@lon2d = lon

    res@tiMainString         = outfile       ; turn on color fill

    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@cnLevelSelectionMode = "Manuallevels"
    res@cnMinLevelValF = -mmax
    res@cnMaxLevelValF = mmax
    res@cnLevelSpacingF = mmax/3.5
    res@cnLinesOn = False
    res@cnFillPalette = "BlWhRe"
    res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line

    plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
    
        ;************************************
end
