load "$NCL_VALID_LIB_DIR/rmsz.ncl"
load "$NCL_VALID_LIB_DIR/area_avg.ncl"
load "$NCL_VALID_LIB_DIR/global.ncl"
load "$NCL_VALID_LIB_DIR/plot_rmsz.ncl"

begin

  ensroot = "$WORK/NCOUT/global_rmsz/perturb.T.h.mon"
  mon=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
  nmon = dimsizes(mon) 
  append = "-14-np-41cases.nc"
  ; (2) Calculate RMSZ score and global area-weighted average
  ens_file = ensroot+mon(0)+append
  print((/"(ens_file "+ens_file+")"/))
  fens = addfile(ens_file,"r")
  filecnt = "/glade/scratch/huyong/archive/perturb.g40.T.year.np/ocn/hist/perturb.g40.T.year.np.pop.h.0001-01-02.nc"
  frun = addfile(filecnt,"r")

  rmask =  frun->REGION_MASK


  var_name3d = fens->var3d
  var_name2d = fens->var2d
  
  vars3d = dimsizes(var_name3d)
  nvars3d = vars3d(0)
  vars2d = dimsizes(var_name2d)
  nvars2d = vars2d(0)
  print((/"nvars3d = "+nvars3d+" 2d = "+nvars2d/))

  Reg  = (/"Southern","Pacific","Indian","Atlantic","Persian","Mediterranean","Baffin","North","Arctic","Hudson"/)
  RegLat = (/1,2,3,6,4,7,8,9,10,11/)
  nreg = dimsizes(Reg)
  stdmin2d=new((/nvars2d,nreg,nmon/),float)
  stdavg2d=new((/nvars2d,nreg,nmon/),float)
  stdmax2d=new((/nvars2d,nreg,nmon/),float)
  stdmin3d=new((/nvars3d,nreg,nmon/),float)
  stdavg3d=new((/nvars3d,nreg,nmon/),float)
  stdmax3d=new((/nvars3d,nreg,nmon/),float)


  allvars3d = new(nvars3d, integer)
  allvars2d = new(nvars2d, integer)

  do imon = 0, nmon-1
    ens_file = ensroot+mon(imon)+append
    print((/"(ens_file "+ens_file+")"/))
    fens = addfile(ens_file,"r")
    
    ens_stddev3d=fens->ens_stddev3d(:,:,:,:)
    ens_stddev2d=fens->ens_stddev2d(:,:,:)

    ; (3) Compare to ensemble statistics
    
    
    do regn = 0, nreg-1
      
      rmask_3D = conform(ens_stddev3d(0,:,:,:),rmask,(/1,2/))
      ens_stddev2dtmp = mask(ens_stddev2d,rmask    .eq. RegLat(regn) , True)
      ens_stddev3dtmp = mask(ens_stddev3d,rmask_3D .eq. RegLat(regn) , True)
      print("mon "+mon(imon)+" regn "+Reg(regn))
      do v=0, nvars3d-1
         ens_v3 = ndtooned(ens_stddev3dtmp(v,:,:,:))
         stdmin3d(v,regn,imon) = min(ens_v3(ind(ens_v3 .ne. 0)))
         stdmax3d(v,regn,imon) = max(ens_v3(ind(ens_v3 .ne. 0)))
         stdavg3d(v,regn,imon) = avg(ens_v3(ind(ens_v3 .ne. 0)))
         delete(ens_v3)
          
         print(var_name3d(v,:)+"  min-std= "+stdmin3d(v,regn,imon))
         print(var_name3d(v,:)+"  max-std= "+stdmax3d(v,regn,imon))
         print(var_name3d(v,:)+"  avg-std= "+stdavg3d(v,regn,imon))
      end do
      do v=0, nvars2d-1
         ens_v2 = ndtooned(ens_stddev2dtmp)
         stdmin2d(v,regn,imon) = min(ens_v2(ind(ens_v2 .ne. 0)))
         stdmax2d(v,regn,imon) = max(ens_v2(ind(ens_v2 .ne. 0)))
         stdavg2d(v,regn,imon) = avg(ens_v2(ind(ens_v2 .ne. 0)))
         delete(ens_v2)

         print(var_name2d(v,:)+"  min-std= "+stdmin2d(v,regn,imon))
         print(var_name2d(v,:)+"  max-std= "+stdmax2d(v,regn,imon))
         print(var_name2d(v,:)+"  avg-std= "+stdavg2d(v,regn,imon))
      end do
    end do 
  end do 
;************************************************
do v=0, nvars3d-1
wks   = gsn_open_wks ("png",var_name3d(v,:)+"-stddev-ensemble41-Seas")                  ; open workstation
gsn_define_colormap(wks,"amwg")

res                   = True                      ; plot mods desired

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/8.0,8.0,8.0,8.0,4.0,4.0,4.0,4.0,4.0,4.0/)               ; make 2nd lines thicker

res@xyLineColors      = ispan(1,10*nreg,10)          ; change line color
res@xyMarkers      = ispan(1,nreg,1)          ; change line color
res@xyMarkerSizeF      = 0.3
res@xyYStyle = "Log"
res@tiXAxisString     = "Month"         ; change line color
res@tiYAxisString     = "Average Standard Deviation"         ; change line color
res@tiMainString     = "Avgerage STDDEV of " +var_name3d(v,:)         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.4
res@pmLegendParallelPosF     = 0.6
res@lgPerimOn     = False
res@xyDashPatterns = ispan(1,2*(nreg+2),2)
res@pmLegendWidthF     = 0.10
res@pmLegendHeightF     = 0.40
res@lgLabelFontHeightF     = 0.02
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4
res@xyExplicitLabels = Reg

plot  = gsn_csm_xy (wks,ispan(1,12,1),stdavg3d(v,:,:),res) ; create plot
end do

do v=0, nvars2d-1
wks   = gsn_open_wks ("png",var_name2d(v,:)+"-stddev-ensemble41-Seas")                  ; open workstation
gsn_define_colormap(wks,"amwg")

res                   = True                      ; plot mods desired

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.
res@xyLineThicknesses = (/8.0,8.0,8.0,8.0,4.0,4.0,4.0,4.0,4.0,4.0/)               ; make 2nd lines thicker

res@xyLineColors      = ispan(1,10*nreg,10)          ; change line color
res@xyMarkers      = ispan(1,nreg,1)          ; change line color
res@xyMarkerSizeF      = 0.3
res@xyYStyle = "Log"
res@tiXAxisString     = "Month"         ; change line color
res@tiYAxisString     = "Average Standard Deviation"         ; change line color
res@tiMainString     = "Avgerage STDDEV of " +var_name2d(v,:)         ; change line color
res@pmLegendDisplayMode     = "Always"
res@pmLegendSide     = "Right"
res@pmLegendOrthogonalPosF     = -0.4
res@pmLegendParallelPosF     = 0.6
res@lgPerimOn     = False
res@xyDashPatterns = ispan(1,2*(nreg+2),2)
res@pmLegendWidthF     = 0.10
res@pmLegendHeightF     = 0.40
res@lgLabelFontHeightF     = 0.02
;res@tmYLFormat = "0*+^e"
;res@tmYLMinorOn = False
;res@tmYLPrecision = 4
res@xyExplicitLabels = Reg

plot  = gsn_csm_xy (wks,ispan(1,12,1),stdavg2d(v,:,:),res) ; create plot
end do

end
