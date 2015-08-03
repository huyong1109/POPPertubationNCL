load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************
;************************************
begin
    
    path = "/glade/scratch/huyong/archive/"
    testcase  = (/"gT62.g16.tol5.0e-9","gT62.g16.tol1.0e-10", "gT62.g16.tol1.0e-11","gT62.g16.tol1.0e-12", "gT62.g16.orig", "gT62.g16.tol1.0e-14","gT62.g16.tol1.0e-15", "gT62.g16.tol1.0e-16"/)
    year = "0001"
    month = "12"
    print("In compare.ncl")
    
    ncase = dimsizes(testcase)
    do icase = 0, ncase-1
      testfile=path+testcase(icase)+"/ocn/hist/"+testcase(icase)+".pop.h."+year+"-"+month+".nc"
      varname = "SSH"
      print("testfile  :"+testfile)
      outfile="Surface-"+testcase(icase)+"-"+varname
      testin  = addfile(testfile ,"r")
  
      data = testin->$varname$
      printVarSummary(data)
  
      tmp_lon = testin->TLONG
      tmp_lat = testin->TLAT
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
      wks = gsn_open_wks("png",outfile)      ; open a ps file
      gsn_define_colormap(wks,"gui_default") ; choose colormap
      res=True
  
      T=data(0,1:nlat-1,:)
      maxT = max(T)
      minT = min(T)
      maxmin = max((/abs(maxT),abs(minT)/))
      print("max : "+maxT+"   minT : "+minT)
      T@lat2d = lat
      T@lon2d = lon
  
      ;gsn_define_colormap(wks, "cmp_haxby")
      gsn_define_colormap(wks, "GMT_red2green")
      ;gsn_define_colormap(wks, "BlWhRe")
      res@tiMainString         = outfile       ; turn on color fill
  
      res@cnFillOn             = True       ; turn on color fill
      res@cnLineLabelsOn       = False      ; turns off contour line labels
      res@cnFillMode           = "RasterFill"      ; turns off contour line labels
      res@cnInfoLabelOn        = False      ; turns off contour info label
      res@gsnSpreadColors      = True       ; use full colormap
      ;res@cnLevelSelectionMode = "Manuallevels"
      ;res@cnMinLevelValF = -maxmin
      ;res@cnMaxLevelValF = maxmin
      ;res@cnMinLevelValF = -0.7
      ;res@cnMaxLevelValF = 0.7
      ;res@cnLevelSpacingF = 0.1
      ;res@cnLevelSelectionMode = "ExplicitLevels"
      ;res@cnLevels = (/-0.7, -0.5, -0.3, -0.1, -0.05, -0.01, -0.001, 0.001, 0.01, 0.05, 0.1, 0.3, 0.5, 0.7/)

  
      plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
      system("convert -trim "+outfile+".png " +outfile+".png")
        ;************************************
    
  end do 
end
