
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;************************************
begin
;************************************

    print("In slice.ncl "+varname+" - " +direction+" - "+val)
    print("testfile  :"+testfile)
    print("cntrlfile :"+cntrlfile)
    testin  = addfile(testfile ,"r")
    cntrlin = addfile(cntrlfile,"r")

    data1 = testin->$varname$
    data2 = cntrlin->$varname$
    tmpdata = data1-data2
    ;data = PopLatLon(tmpdata,"gx1v6","1x1d","bilin","da","100716") ; remap, to make error more fluent
    data = tmpdata
    ;printVarSummary(data)
    dim = dimsizes(data)
    ndim = dimsizes(dim)
    print("ndim " + ndim)
    directlist = ((/"z_t", "lat", "lon"/))
    indirect = ind(directlist .eq. direction)+1
    print("ind "+indirect)
    ival = stringtoint(val)

    printVarSummary(ival)




    
    ;************************************
    
    if (indirect .eq. 1) then


        if (ndim .eq. 3 .and. ival .eq. 0) then  
            T=data(0,:,:)
            T@lon2d = cntrlin->ULAT
            T@lat2d = cntrlin->ULONG

        else if ((ndim .eq. 4)) .and. (ival .ge. 0) .and. (ival .lt. dim(indirect)) then  
            T=data(0,ival,:,:)
            T@lon2d = cntrlin->TLAT
            T@lat2d = cntrlin->TLONG

        else if ((ndim .eq. 4) .and. (ival .eq. -1) ) then  
            T=(dim_max_n(data(0,:,:,:), 0))

        else
            print((/varname+" in file:"+testfile+" do not have level "+direction+"("+ival+")"/))
            exit
        end if
        end if
        end if


    ;************************************
    else if (indirect .eq. 2) then

        if ((ndim .eq. 4)) .and. (ival .ge. 0) .and. (ival .lt. dim(indirect)) then  
            T=data(0,:,ival,:)

        else if ((ndim .eq. 4) .and. (ival .eq. -1) ) then  
            T=dim_max_n_Wrap(abs(data(0,:,:,:)), indirect)
        else 
            print((/varname+" in file:"+testfile+" do not have level "+direction+"("+ival+")"/))
            exit

        end if
        end if

    ;************************************
    else if (indirect .eq. 3) then

        if ((ndim .eq. 4)) .and. (ival .ge. 0) .and. (ival .lt. dim(indirect)) then  
            T=data(0,:,:,ival)

        else if ((ndim .eq. 4) .and. (ival .eq. -1) ) then  
            T=dim_max_n_Wrap(abs(data(0,:,:,:)), indirect)
        else 
            print((/varname+" in file:"+testfile+" do not have level "+direction+"("+ival+")"/))
            exit
        end if
        end if
    else
        print("Direction should be : z_t, lat, lon")
        exit

    end if 
    end if 
    end if 

    ;copy_VarMeta(data,T)   ; copy metadata from data1 to data
    maxT = max(T)
    minT = min(T)
    mmax = max((/abs(maxT), abs(minT)/))
    
    printVarSummary(T)
    print("maxT : "+maxT+"   minT : "+minT)

    wks = gsn_open_wks("X11",outfile)      ; open a ps file
    res=True
    res@tiMainString         = direction+"("+val+")  "+outfile       ; turn on color fill

    res@cnFillOn             = True       ; turn on color fill
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    ;res@cnLevelSelectionMode = "Manuallevels"
    ;res@cnMinLevelValF = -mmax
    ;res@cnMaxLevelValF = mmax
    ;res@cnLevelSpacingF = mmax/3.5
    res@cnFillPalette = "BlWhRe"
    res@gsnAddCyclic = True       ; add longitude cyclic point to avoid the white line

    ; resize map
    ;res@mpShapeMode = "FreeAspect"
    ;res@vpWidthF = 0.8
    ;res@vpWidthF = 0.4
    res@wkPaperSize = "B"
    res@gsnPaperOrientation = "landscape"
    res@gsnMaximize = True


    if (indirect .eq. 1) then

        plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
    else 
        plot = gsn_csm_contour(wks,T,res)     ; create plot
    end if



    end
