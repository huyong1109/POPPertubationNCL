
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;************************************
begin
;************************************

    print("In slice.ncl")
    print("testfile  :"+testfile)
    print("cntrlfile :"+cntrlfile)
    testin  = addfile(testfile ,"r")
    cntrlin = addfile(cntrlfile,"r")

    data1 = testin->$varname$
    data2 = cntrlin->$varname$
    tmpdata = data1-data2
    data = PopLatLon(tmpdata,"gx1v6","1x1d","bilin","da","100716")
    printVarSummary(data)
    dim = dimsizes(data)
    printVarSummary(dim)


    wks = gsn_open_wks("X11",outfile)      ; open a ps file
    res=True
    res@tiMainString         = direction+" "+outfile       ; turn on color fill

    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels

    
    ;************************************
    if (direction .eq. "z_t") then

        if (varname .eq. "SSH") then  
            T=data(0,:,:)
        else if ((.not. isdefined("val")) .or. (val .le. 0)) then  
            T=data(0,0,:,:)
        else
            print((/varname+" in file:"+testfile+" do not have level "+val/))
            exit
        end if
        end if
        T=dim_max_n_Wrap(abs(data(0,:,:,:)), 0)
        printVarSummary(T)
        ;printVarSummary(tmpT)

        maxT = max(T)
        minT = min(T)
        mmax = max((/abs(maxT), abs(minT)/))
    
        print("max : "+maxT+"   minT : "+minT)
        ;T@lat2d = lat
        ;T@lon2d = lon

        res@tiMainString         = "Hgt-max"+outfile       ; turn on color fill

        res@cnFillOn             = True       ; turn on color fill
        res@cnLineLabelsOn       = False      ; turns off contour line labels
        res@cnFillMode           = "RasterFill"      ; turns off contour line labels
        res@cnInfoLabelOn        = False      ; turns off contour info label
        res@gsnSpreadColors      = True       ; use full colormap
        res@cnLevelSelectionMode = "Manuallevels"
        res@cnMinLevelValF = -mmax
        res@cnMaxLevelValF = mmax
        res@cnLevelSpacingF = mmax/3.5

        plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot

    ;************************************
    else if (direction .eq. "lat") then
        print("Direction : "+direction)
        wks = gsn_open_wks("X11","lat"+outfile)      ; open a ps file
        gsn_define_colormap(wks,"gui_default") ; choose colormap
        res=True

        T=dim_max_n(abs(data(0,:,:,:)), 1)
        maxT = max(T)
        minT = min(T)
        mmax = max((/abs(maxT), abs(minT)/))
        ;T=where(ismissing(T), -mmax, T)
        print("max : "+maxT+"   minT : "+minT)
        ;T@lat2d = z_t
        ;T@lon2d = lon

        gsn_define_colormap(wks, "BlWhRe")
        res@tiMainString         = "Lat-max "+outfile       ; turn on color fill

        res@cnFillOn             = True       ; turn on color fill
        res@cnLineLabelsOn       = False      ; turns off contour line labels
        res@cnFillMode           = "RasterFill"      ; turns off contour line labels
        res@cnInfoLabelOn        = False      ; turns off contour info label
        res@gsnSpreadColors      = True       ; use full colormap
        ;res@tmXBLabels = T@lon2d
        res@trYReverse = True
        res@cnLevelSelectionMode = "Manuallevels"
        res@cnMinLevelValF = -mmax
        res@cnMaxLevelValF = mmax
        res@cnLevelSpacingF = mmax/3.5

        plot = gsn_csm_contour(wks,T,res)     ; create plot

    ;************************************
    else if (direction .eq. "lon") then
        res=True

        T=dim_max_n(abs(data(0,:,:,:)), 2)
        maxT = max(T)
        minT = min(T)
        mmax = max((/abs(maxT), abs(minT)/))
        ;T=where(ismissing(T), -mmax, T)
        print("max : "+maxT+"   minT : "+minT)
        ;T@lat2d = lat
        ;T@lon2d = z_t

        res@tiMainString         = "Lon-max "+outfile       ; turn on color fill

        res@cnFillOn             = True       ; turn on color fill
        res@cnLineLabelsOn       = False      ; turns off contour line labels
        res@cnFillMode           = "RasterFill"      ; turns off contour line labels
        res@cnInfoLabelOn        = False      ; turns off contour info label
        res@gsnSpreadColors      = True       ; use full colormap
        res@trYReverse = True
        res@cnLevelSelectionMode = "Manuallevels"
        res@cnMinLevelValF = -mmax
        res@cnMaxLevelValF = mmax
        res@cnLevelSpacingF = mmax/3.5

        plot = gsn_csm_contour(wks,T,res)     ; create plot
    else
        print("Direction should be : surf, z_t, lat, lon")
        exit

    end if 
    end if 
    end if 
    end if 

    end
