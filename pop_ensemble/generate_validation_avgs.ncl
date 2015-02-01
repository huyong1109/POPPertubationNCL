load "$NCL_VALID_LIB_DIR/create_meandev.ncl"
load "$NCL_VALID_LIB_DIR/create_meandev_opensea.ncl"
load "$NCL_VALID_LIB_DIR/create_ensemble.ncl"

begin

; (0) User-defined information used for naming ensemble
  if (.not.isdefined("ensemble_file")) then
    print((/"ERROR: you must specify the ensemble file to create with this script!"/))
    print((/"Proper usage:"/))
    print((/"$ ncl validation-test.ncl ensemble_file=\"+str_get_dq()+"$FILENAME\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("pop_out_pre")) then
    print((/"ERROR: you must specify the prefix path of the pop output files (usually at \$SCR/archive)!"/))
    print((/"Proper usage:"/))
    print((/"$ ncl validation-test.ncl pop_out_pre=\"+str_get_dq()+"$PREFIX\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("casename")) then
    print((/"ERROR: you must specify the casename of the pop output files !"/))
    print((/"Proper usage:"/))
    print((/"$ ncl validation-test.ncl pop_out_pre=\"+str_get_dq()+"$CASENAME\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("pop_out_suf")) then
    print((/"ERROR: you must specify the suffix of the pop output files (start with pop.h#)!"/))
    print((/"Proper usage:"/))
    print((/"$ ncl validation-test.ncl pop_out_suf=\"+str_get_dq()+"$SUFFIX\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("nfile_opts")) then
    print((/"ERROR: you must specify the number of files to use to build ensemble"/))
    print((/"$ ncl validation-test.ncl nfile_opts=\"+str_get_dq()+"$N\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("defpert")) then
    print((/"ERROR: you must specify the file describing perturbation file names "/))
    print((/"$ ncl validation-test.ncl defpert=\"+str_get_dq()+"$DEFPERT\"+str_get_dq()/))
    status_exit(1)
  end if



  if (.not.isdefined("tag")) then
    print((/"ERROR: you must specify a tag to use for metadata"/))
    print((/"$ ncl validation-test.ncl tag=\"+str_get_dq()+"$TAG\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("res")) then
    print((/"ERROR: you must specify a resolution for metadata"/))
    print((/"$ ncl validation-test.ncl res=\"+str_get_dq()+"$RES\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("compset")) then
    print((/"ERROR: you must specify a compset to use for metadata"/))
    print((/"$ ncl validation-test.ncl compset=\"+str_get_dq()+"$COMPSET\"+str_get_dq()/))
    status_exit(1)
  end if

  if (.not.isdefined("mach")) then
    print((/"ERROR: you must specify a machine name to use for metadata"/))
    print((/"$ ncl validation-test.ncl mach=\"+str_get_dq()+"$MACH\"+str_get_dq()/))
    status_exit(1)
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

  if (.not.isdefined("verbose")) then
    verbose=False
  end if


  if (isdefined("vinterp")) then
    print((/"WARNING: ignoring your vinterp setting; at this time, we only run the validation test on the native vertical grid."/))
    delete(vinterp)
  end if
  vinterp=False

  do ifile=0, dimsizes(nfile_opts)-1

; (1) Basic setup
;     (1a) (input files / output file)
   nfiles = nfile_opts(ifile) 
   nfile_ids = ispan(0,nfiles-1,1)
   
  ; If using less than 101 files, want to use 0 through (nfiles-1)/2
  ; and 51 through 51+(nfiles-1)/2. Using more than 101 files will assume
  ; you want to use 0 to nfiles-1.
  ;;;if (nfiles.lt.101) then
  ;;;  halfway = (nfiles-1)/2
  ;;;  nfile_ids(halfway+1:nfiles-1) = nfile_ids(halfway+1:nfiles-1)+(50-halfway)
  ;;;end if

  infiles = new(nfiles, string)
  id_str = asciiread(defpert, -1, "string")
  do i=0,nfiles-1
    infiles(i) = pop_out_pre+"/"+casename+"."+id_str(i)+"/ocn/hist/"+casename+"."+id_str(i)+"."+pop_out_suf
  end do
  delete(nfile_ids)




  print((/"Ensemble files:"/))
  print((/"---------------"/))
  print((/infiles/))

  ;;status = create_ensemble(infiles, ensemble_file, tag, compset, res, mach, tind, vinterp, verbose)
  status = create_meandev_opensea(infiles, ensemble_file, tag, compset, res, mach, tind, vinterp, verbose)
  delete(infiles)
  end do
end
