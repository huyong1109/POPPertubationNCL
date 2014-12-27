load "$NCL_VALID_LIB_DIR/rmsz.ncl"
load "$NCL_VALID_LIB_DIR/area_avg.ncl"
load "$NCL_VALID_LIB_DIR/global.ncl"
load "$NCL_VALID_LIB_DIR/plot_rmsz.ncl"

begin
; (0) User-defined information used for determining ensemble name
;     Note that these are default values, but can be changed from the command
;     line
  if (.not.isdefined("ens_file")) then
    print((/"ERROR: you must specify both the ensemble file and the output file you want to compare to ensemble!"/))
    print((/"Proper usage:"/))
    print((/"$ ncl validation-test.ncl "+"$FILENAME\"+str_get_dq()+" ens_file=\"+str_get_dq()+"$FILENAME\"+str_get_dq()/))
    status_exit(1)
;    run_file = "../single_run_data.BC5.ne30_g16/cesm1_3_testing/yellowstone.pgi-a03e-001.BC5.cam.h0.0001-01-01-00000.nc"
  end if
  
  ; For monthly data sets, want to look at time index 0 not 1
  ; (Annual data puts initial condition in time index 0)

  UseAllVars = True

  ; (2) Calculate RMSZ score and global area-weighted average
  print((/"(ens_file "+ens_file+")"/))
  fens = addfile(ens_file,"r")


  var_name3d = fens->var3d
  var_name2d = fens->var2d
  
  vars3d = dimsizes(var_name3d)
  nvars3d = vars3d(0)
  vars2d = dimsizes(var_name2d)
  nvars2d = vars2d(0)
  print((/"nvars3d = "+nvars3d+" 2d = "+nvars2d/))


  allvars3d = new(nvars3d, integer)
  allvars2d = new(nvars2d, integer)
  file_3d_dims = getfilevardimsizes(fens, "ens_avg3d")
  file_nvars3d = file_3d_dims(0)
  ens_stddev3d=fens->ens_stddev3d(:,:,:,:)
  file_2d_dims = getfilevardimsizes(fens, "ens_avg2d")
  ens_stddev2d=fens->ens_stddev2d(:,:,:)


  file_nvars2d = file_2d_dims(0)

  ; (3) Compare to ensemble statistics
  
  stdmin2d=new(nvars2d,float)
  stdavg2d=new(nvars2d,float)
  stdmax2d=new(nvars2d,float)
  stdmin3d=new(nvars3d,float)
  stdavg3d=new(nvars3d,float)
  stdmax3d=new(nvars3d,float)
  
  ;print(fens->ens_stddev3d(0,:,:,:))
  do v=0, nvars3d-1
     ens_v3 = ndtooned(ens_stddev3d(v,:,:,:))
     stdmin3d(v) = min(ens_v3(ind(ens_v3 .ne. 0)))
     stdmax3d(v) = max(ens_v3(ind(ens_v3 .ne. 0)))
     stdavg3d(v) = avg(ens_v3(ind(ens_v3 .ne. 0)))
      
     print(var_name3d(v,:)+"  min-std= "+stdmin3d(v))
     print(var_name3d(v,:)+"  max-std= "+stdmax3d(v))
     print(var_name3d(v,:)+"  avg-std= "+stdavg3d(v))
  end do
  do v=0, nvars2d-1
     ens_v2 = ndtooned(ens_stddev2d(v,:,:))
     stdmin2d(v) = min(ens_v2(ind(ens_v2 .ne. 0)))
     stdmax2d(v) = max(ens_v2(ind(ens_v2 .ne. 0)))
     stdavg2d(v) = avg(ens_v2(ind(ens_v2 .ne. 0)))
     print(var_name2d(v,:)+"  min-std= "+stdmin2d(v))
     print(var_name2d(v,:)+"  max-std= "+stdmax2d(v))
     print(var_name2d(v,:)+"  avg-std= "+stdavg2d(v))
  end do

end
