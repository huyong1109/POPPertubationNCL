load "$NCL_VALID_LIB_DIR/rmsz_latitude.ncl"
load "$NCL_VALID_LIB_DIR/area_avg.ncl"
load "$NCL_VALID_LIB_DIR/global.ncl"
load "$NCL_VALID_LIB_DIR/plot_rmsz.ncl"

begin
; (0) User-defined information used for determining ensemble name
;     Note that these are default values, but can be changed from the command
;     line
  if ((.not.isdefined("run_file")).or.(.not.isdefined("ens_file"))) then
    print((/"ERROR: you must specify both the ensemble file and the output file you want to compare to ensemble!"/))
    print((/"Proper usage:"/))
    print((/"$ ncl validation-test.ncl run_file=\"+str_get_dq()+"$FILENAME\"+str_get_dq()+" ens_file=\"+str_get_dq()+"$FILENAME\"+str_get_dq()/))
    status_exit(1)
;    run_file = "../single_run_data.BC5.ne30_g16/cesm1_3_testing/yellowstone.pgi-a03e-001.BC5.cam.h0.0001-01-01-00000.nc"
  end if
  
  if (.not.isdefined("monthly")) then
    monthly=False
  end if
  ; For monthly data sets, want to look at time index 0 not 1
  ; (Annual data puts initial condition in time index 0)
  if (monthly) then
    tind=0
  else
    tind=1
  end if

  ; Set verbose = True to increase amount of output
  if (.not.isdefined("verbose")) then
    verbose = False
  end if

  ; MNL: at this time, no ensembles are generated from interpolated data
  if (isdefined("vinterp")) then
    print((/"WARNING: ignoring your vinterp setting; at this time, we only run the validation test on the native vertical grid"/))
    delete(vinterp)
  end if
  vinterp = False

  ; MNL: at the moment, plotting doesn't work out-of-the-box
  if (.not.isdefined("make_plot")) then
    make_plot = False
  end if
  if (.not.isdefined("plot_type")) then
    plot_type = "X11"
  end if

; (1) Basic setup


;     (1c) get variable names from ensemble file
;          set UseAllVars = True to test every variable in ensemble file
;          otherwise set var3d and var2d in block below
  UseAllVars = True
;  UseAllVars = False
  fens = addfile(ens_file,"r")

  ; Check to see if ensemble contains global mean info
  HaveGlobalMeans = isfilevar(fens, "global_mean")

  var_name3d = fens->var3d
  var_name2d = fens->var2d
  tmpdims = dimsizes(var_name3d)
  nvars3d = tmpdims(0)
  tmpdims = dimsizes(var_name2d)
  nvars2d = tmpdims(0)
  if (UseAllVars) then
    var3d = new(nvars3d, string)
    var2d = new(nvars2d, string)
    do v=0, nvars3d-1
      var3d(v) = charactertostring(var_name3d(v,:))
    end do
    do v=0, nvars2d-1
      var2d(v) = charactertostring(var_name2d(v,:))
    end do
  else
    ; specify which variables to check against ensemble here
    ; (ignored if UseAllVars = True)
    var3d = (/"UVEL", "VVEL", "TEMP", "SALT"/)
    var2d = (/"SSH"/)
  end if
  nvars3d = dimsizes(var3d)
  nvars2d = dimsizes(var2d)
  vars = array_append_record(var3d,var2d,  0)
  max_z   = new(nvars3d+nvars2d, "float")
  min_avg = new(nvars3d+nvars2d, "float")
  max_avg = new(nvars3d+nvars2d, "float")

  delete(fens)
  delete(tmpdims)

  ; (2) Calculate RMSZ score and global area-weighted average
  print((/"Testing "+run_file/))
  print((/"(Testing against "+ens_file+")"/))
  if (vinterp) then
    print((/"Interpolating data to the 25 pressure levels used in AMWG diagnostics package..."/))
    if (vinterp@extrap) then
      print((/"... and extrapolating to values under the surface."/))
    else
      print((/"... but not extrapolating to values under the surface."/))
    end if
  else
    print((/"Comparing data on POP's native (hybrid) levels."/))
  end if
  ; FailTest(v)  = True => RMSZ > max(ensemble RMSZ)
  ; FailTest2(v) = True => Global Mean > max(ensemble global mean)
  ;                     or Global Mean < min(ensemble global mean)
  ; VarInEns(v)  = True => ensemble members vary at at least one point
  FailTest  = new(nvars3d+nvars2d,logical)
  FailTest2 = new(nvars3d+nvars2d,logical)
  VarInEns  = new(nvars3d+nvars2d,logical)
  FailTest  = False
  FailTest2 = False
  VarInEns  = True

  RMSZScore = calculate_rmsz_score_lat(run_file, ens_file, var3d, var2d, tind, vinterp, FailTest, VarInEns, verbose)
  if (HaveGlobalMeans) then
    GlobalMean = calculate_global_mean(run_file, ens_file, var3d, var2d, tind, vinterp, FailTest2, VarInEns, verbose)
  end if
  fens = addfile(ens_file,"r")
  if (make_plot) then
    plot_RMSZscores(RMSZScore, fens, vars, "yellowstone", "compiler", plot_type)
  end if

  ; (3) Output results of comparison
  v = 0 ; index in RMSZScore
  var_count = 0 ; number of variables tested


  do i=0, nvars3d-1
    if (VarInEns(v)) then
      v_in_f = ind(chartostring(fens->vars).eq.vars(v))
      if (verbose) then
        print((/var3d(i)+": RMSZ score = " + RMSZScore(v,:)/))
        print((/"----"/))
      end if
      var_count = var_count + 1

      max_z(v) = 1.
    else
      max_z(v) = 0.
    end if
    v = v+1
  end do

  do i=0, nvars2d-1
    if (VarInEns(v)) then
      v_in_f = ind(chartostring(fens->vars).eq.vars(v))
      if (verbose) then
        print((/var2d(i)+": RMSZ score = " + RMSZScore(v,:)/))
        print((/"----"/))
      end if
      max_z(v)   = 1.
      var_count = var_count + 1
    else
      max_z(v) = 0.
    end if
    v = v+1
  end do

end
