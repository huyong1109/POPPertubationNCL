
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;************************************
begin
;************************************

    print("In errorhist.ncl ")
    print("testfile  :"+testfile)
    print("cntrlfile :"+cntrlfile)
    testin  = addfile(testfile ,"r")
    cntrlin = addfile(cntrlfile,"r")

    data1 = testin->$varname$
    data2 = cntrlin->$varname$
    tmpdata = data1-data2
    ;data = PopLatLon(tmpdata,"gx1v6","1x1d","bilin","da","100716") ; remap, to make error more fluent
    T = ndtooned(abs(tmpdata))
    printVarSummary(T)
    

    wks = gsn_open_wks("X11",outfile)      ; open a ps file
    res=True
    res@tiMainString         = outfile       ; turn on color fill
    res@trYLog = True

    plot = gsn_histogram(wks,T,res)     ; create plot


    end
