load "$NCL_VALID_LIB_DIR/diff.ncl"
load "$NCL_VALID_LIB_DIR/diff_opensea.ncl"

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

  if (.not.isdefined("casename") .or. .not.isdefined("casename1")) then
    print((/"ERROR: you must specify the casename1 of the pop output files !"/))
    print((/"Proper usage:"/))
    print((/"$ ncl validation-test.ncl pop_out_pre=\"+str_get_dq()+"$CASENAME\"+str_get_dq()/))
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
  
  nfile = new(nfiles, string)
  ofile = new(nfiles, string)
  id_str = asciiread(defpert, -1, "string")
  do i=0,nfiles-1
    nfile(i) = pop_out_pre+"/"+"/ocn/hist/"+casename+id_str(i)+".nc"
    ofile(i) = pop_out_pre1+"/"+"/ocn/hist/"+casename1+id_str(i)+".nc"
  end do
  delete(nfile_ids)




  print((/"New files:"/))
  print((/"---------------"/))
  print((/nfile/))
  print((/"Orig files:"/))
  print((/"---------------"/))
  print((/ofile/))

  status = diff_opensea(nfile,ofile,  ensemble_file, tag, compset, res, mach, tind, verbose)
  delete(nfile)
  delete(ofile)
  end do
end
