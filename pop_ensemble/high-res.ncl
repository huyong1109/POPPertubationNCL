load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************
;************************************
begin
    pre ="/glade/scratch/huyong/archive/gT12_default_512/ocn/hist/"
    testfile1=pre+"gT12_default_512.pop.h.0001-01-05.nc"
    testfile2=pre+"ChronGear/gT12_default_512.pop.h.0001-01-05.nc"
    testin1  = addfile(testfile1 ,"r")
    testin2  = addfile(testfile2 ,"r")
    print("file :"+testfile1)
  
    u1 = testin1->UVEL(0,0,:,:)
    v1 = testin1->VVEL(0,0,:,:)
    u2 = testin2->UVEL(0,0,:,:)
    v2 = testin2->VVEL(0,0,:,:)

    ;************************************

    ;T=data(300:1700, 2200:3599)
    T= (u1-u2)*(u1-u2) + (v1-v2)*(v1-v2)
    ;T= sqrt((u1)*(u1) + (v1)*(v1))
    ;T=abs(testin1->TEMP(0,0,:,:)- testin2->TEMP(0,0,:,:))
    ;T=testin1->TEMP(0,0,:,:)
    
    T@lat2d = testin1->ULAT
    T@lon2d = testin1->ULONG
    ;T = where(T .eq. -1, 0, T)
    maxT = max(T)
    minT = min(T)
    print("max : "+maxT+"   minT : "+minT)

    ;gsn_define_colormap(wks, "BlAqGrYeOrRe")
    wks = gsn_open_wks("x11","high-res")      ; open a ps file
    res=True
    gsn_define_colormap(wks, "sunshine_9lev")
    ;res@tiMainString         = "SST"     ; turn on color fill

    res@cnFillOn             = True       ; turn on color fill
    res@cnLinesOn             = False      ; turns off contour line labels
    res@cnLineLabelsOn       = False      ; turns off contour line labels
    res@cnFillMode           = "RasterFill"      ; turns off contour line labels
    res@cnInfoLabelOn        = False      ; turns off contour info label
    res@cnLevelSelectionMode = "Explicitlevels"
    res@cnLevels = (/0.01, 0.1*ispan(1,10,1), 2, 10/)
    ;res@cnMinLevelValF = -0.6
    ;res@cnMaxLevelValF = 0.6
    ;res@cnLevelSpacingF = 0.4
    ;res@vpWidthF = 0.8
    ;res@vpHeightF = 0.4
    ;res@vpXF = 0.1
    ;res@vpYF = 0.6
    ;res@trXMinF = 0.1
    ;res@trXMaxF = 0.9
    ;res@trYMinF = 0.1
    ;res@trYMaxF = 0.4

    plot = gsn_csm_contour_map(wks,T,res)     ; create plot
    
        ;************************************
end
