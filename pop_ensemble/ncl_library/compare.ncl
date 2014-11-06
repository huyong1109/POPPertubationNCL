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
    ;data = data1;
    data = data1-data2
    printVarSummary(data1)
    printVarSummary(data)
    copy_VarMeta(data1,data)   ; copy metadata from data1 to data
    printVarSummary(data)

    tmp_lon = cntrlin->TLONG
    tmp_lat = cntrlin->TLAT
    dims = dimsizes(tmp_lon)
    dims(1) =dims(1) +1
    nlat = dims(0)
    nlon = dims(1)
    lon =new(dims,typeof(tmp_lon))
    lat =new(dims,typeof(tmp_lat))

    lat(:,1:nlon-1) = tmp_lat
    lon(:,1:nlon-1) = tmp_lon
    lon(:,0) = tmp_lon(:,nlon-2)
    lat(:,0) = tmp_lat(:,nlon-2)



    ;************************************
    wks = gsn_open_wks("X11",outfile)      ; open a ps file
    gsn_define_colormap(wks,"gui_default") ; choose colormap
    res=True

    T=data(0,1:nlat-1,:)
    maxT = max(T)
    minT = min(T)
    print("max : "+maxT+"   minT : "+minT)
    T@lat2d = lat
    T@lon2d = lon

    gsn_define_colormap(wks, "BlWhRe")
    res@tiMainString         = outfile       ; turn on color fill

    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@cnInfoLabelOn        = False      ; turns off contour info label
    res@gsnSpreadColors      = True       ; use full colormap
    ;res@cnLevelSelectionMode = "Manuallevels"
    ;res@cnMinLevelValF = -0.6
    ;res@cnMaxLevelValF = 0.6
    ;res@cnLevelSpacingF = 0.4

    plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
    
        ;************************************
end
