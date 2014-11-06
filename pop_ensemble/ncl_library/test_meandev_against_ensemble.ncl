
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;************************************
begin
;************************************

    print("Test MEANDEV against emsemble")
    print("testfile  :"+testfile)
    print("cntrlfile :"+cntrlfile)
    testin  = addfile(testfile ,"r")
    cntrlin = addfile(cntrlfile,"r")
    var3d = cntrlin->var3d
    var2d = cntrlin->var2d
    do i = 0, dimsizes(var3d)-1
      varname = var3d(i)
      data  = testin->varname
      calc_Z(sum_sqr(calc_Z(data, avg3d, stddev3d(v,k,:), count3d, flag3d))  




    


    end
