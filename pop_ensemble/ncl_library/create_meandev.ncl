load "$NCL_VALID_LIB_DIR/global.ncl"
load "$NCL_VALID_LIB_DIR/print.ncl"
load "$NCL_VALID_LIB_DIR/Zscore.ncl"
load "$NCL_VALID_LIB_DIR/vinterp.ncl"
load "$NCL_VALID_LIB_DIR/area_avg.ncl"

undef("create_meandev")
function create_meandev(filelist, ensemble_file, tag, compset, resolution, mach, tind, vinterp, verbose)
begin

  print((/"Creating mean and stddev only in fun: create_meandev ..."/))
; (1) Initial Setup
;     (1a) Open filelist and ensemble_file
  nfiles = dimsizes(filelist)
  f=addfiles(filelist,"r")

;     (1b) Store dimensions of input fields
  input_dims = getfiledimsizes(f[0])
  input_dim_names = getvardims(f[0])
  nlev = -1
  ncol = -1
  nlat = -1
  nlon = -1
  ilev = -1
  icol = -1
  ilat = -1
  ilon = -1
  print((/"Determining spatial dimensions..."/))
  do i=0,dimsizes(input_dims)-1
    if (input_dim_names(i).eq."z_t") then
      nlev = input_dims(i)
      ilev = i
    end if
    if (input_dim_names(i).eq."ncol") then
      ncol = input_dims(i)
      icol = i
    end if
    if (input_dim_names(i).eq."nlat") then
      nlat = input_dims(i)
      ilat = i
    end if
    if (input_dim_names(i).eq."nlon") then
      nlon = input_dims(i)
      ilon = i
    end if
  end do
  if (nlev.eq.-1) then
    print((/"ERROR: can not find nlev dimension in "+filelist(0)/))
    status_exit(1)
  end if
  if (((nlon.eq.-1).or.(nlat.eq.-1)).and.(ncol.eq.-1)) then
    print((/"ERROR: can not find ncol or nlat/nlon dimension in "+filelist(0)/))
    status_exit(1)
  end if
  if (ncol.ne.-1) then
    one_spatial_dim = True
  else
    one_spatial_dim = False
  end if
  plev = dble2flt(f[0]->z_t)

;     (1c) Make sure all files have same dimensions!
  if (one_spatial_dim) then
    print((/"Ensuring nlev and ncol match on all files..."/))
    do i=1,nfiles-1
      input_dims2 = getfiledimsizes(f[i])
      if ((input_dims2(ilev).ne.nlev).or.(input_dims2(icol).ne.ncol)) then
        print((/"ERROR: dimensions differ between "+filelist(0)+" and "+filelist(i)/))
        status_exit(1)
      end if
    end do
  else
    print((/"Ensuring nlev, nlat, and nlon match on all files..."/))
    do i=1,nfiles-1
      input_dims2 = getfiledimsizes(f[i])
      if ((input_dims2(ilev).ne.nlev).or.(input_dims2(ilon).ne.nlon).or.(input_dims2(ilat).ne.nlat)) then
        print((/"ERROR: dimensions differ between "+filelist(0)+" and "+filelist(i)/))
        status_exit(1)
      end if
    end do
  end if

;     (1d) Determine what variables will be output
  vNames = getfilevarnames(f[0])
  vInc2d = new(dimsizes(vNames), logical)
  vInc3d = new(dimsizes(vNames), logical)
  str_size = 0
  print((/"Determining which variables should be included in test..."/))
  if( isdefined("defvar")) then

    vInc2d(:) = False
    vInc3d(:) = False
    vardef= asciiread(defvar, -1, "string")
  
    do i=0, dimsizes(vardef)-1
        vind = ind(vNames .eq. vardef(i)) 
        ; want variables that are (time, ncol) or (time, lev, ncol)
        dsize = dimsizes(f[0]->$vNames(vind)$)
        ddsize = dimsizes(dsize)
  
        if (ddsize.eq.3) then
          vInc2d(vind) = ((dsize(1).eq.nlat).and.(dsize(2).eq.nlon))
        end if
        if (ddsize.eq.4) then
            vInc3d(vind) = ((dsize(1).eq.nlev).and.(dsize(2).eq.nlat).and.(dsize(3).eq.nlon))
        end if
        ;print((/vInc2d(vind),  vInc3d(vind)/))
        if (vInc2d(vind).or.vInc3d(vind)) then
          str_size = max((/str_size, dimsizes(stringtochar(vNames(vind)))/))
        end if
      delete(dsize)
      delete(ddsize)
    end do
  else

    do i=0, dimsizes(vNames)-1
      vInc2d(i) = False
      vInc3d(i) = False
      ; want variables that are (time, ncol) or (time, lev, ncol)
      dsize = dimsizes(f[0]->$vNames(i)$)
      ddsize = dimsizes(dsize)
      if (one_spatial_dim) then
        if (ddsize.eq.2) then
          vInc2d(i) = (dsize(1).eq.ncol)
        end if
        if (ddsize.eq.3) then
          vInc3d(i) = ((dsize(1).eq.nlev).and.(dsize(2).eq.ncol))
        end if
        if (vInc2d(i).or.vInc3d(i)) then
          str_size = max((/str_size, dimsizes(stringtochar(vNames(i)))/))
        end if
      else
        if (ddsize.eq.3) then
          vInc2d(i) = ((dsize(1).eq.nlat).and.(dsize(2).eq.nlon))
        end if
        if (ddsize.eq.4) then
          vInc3d(i) = ((dsize(1).eq.nlev).and.(dsize(2).eq.nlat).and.(dsize(3).eq.nlon))
        end if
        if (vInc2d(i).or.vInc3d(i)) then
          str_size = max((/str_size, dimsizes(stringtochar(vNames(i)))/))
        end if
      end if
      delete(dsize)
      delete(ddsize)
    end do
  end if

  var_name2d  = vNames(ind(vInc2d))
  nvars2d = num(vInc2d)  ; hyedit
  ;nvars2d = 1
  var_name3d  = vNames(ind(vInc3d))
  nvars3d = num(vInc3d) ; hyedit
  ;nvars3d = 1
  var_nameAll = vNames(ind(vInc2d.or.vInc3d))
  print((/"Done! Using "+nvars3d+" 3d vars and "+nvars2d+" 2d vars."/))
;  var_nameAll = array_append_record(var_name3d, var_name2d, 0)


;     (1e) Setup for output
  if (vinterp) then
    interp_type = new(1,"integer")
    plevs = get_interpolation_levels(interp_type) ; interp_type is intent(out)
  else 
    plevs = plev
  end if
  print((/"Setting up Output variables..."/))
  nlevs = dimsizes(plevs)

  ; (2) Form ensembles, each missing one member; compute RMSZs and global means
  ;     for each variable
  output_every = 2
  print((/"Forming ensemble..."/))
  indices=ispan(0,nfiles-1,1)
  if (one_spatial_dim) then
    npts2d = int2flt(ncol)
    output_dims2d = (/nfiles, ncol/)
    ensemble_dims2d = (/nfiles-1, ncol/)
    ensemble_stats2d = (/nvars2d, ncol/)
    avg2d = new((/nvars2d, ncol/), float)
    stddev2d = new((/nvars2d, ncol/), float)

    npts3d = int2flt(nlevs*ncol)
    output_dims3d = (/nfiles, nlevs, ncol/)
    ensemble_dims3d = (/nfiles-1, nlevs, ncol/)
    ensemble_stats3d = (/nvars3d, nlevs, ncol/)
    avg3d = new((/nvars3d, nlevs, ncol/), float)
    stddev3d = new((/nvars3d, nlevs, ncol/), float)
  else
    npts2d = int2flt(nlat*nlon)
    output_dims2d = (/nfiles, nlat, nlon/)
    ensemble_dims2d = (/nfiles-1, nlat, nlon/)
    ensemble_stats2d = (/nvars2d, nlat, nlon/)
    avg2d = new((/nvars2d, nlat, nlon/), float)
    stddev2d = new((/nvars2d, nlat, nlon/), float)

    npts3d = int2flt(nlevs*nlat*nlon)
    output_dims3d = (/nfiles, nlevs, nlat, nlon/)
    ensemble_dims3d = (/nfiles-1, nlevs, nlat, nlon/)
    ensemble_stats3d = (/nvars3d, nlevs, nlat, nlon/)
    avg3d = new((/nvars3d, nlevs, nlat, nlon/), float)
    stddev3d = new((/nvars3d, nlevs, nlat, nlon/), float)
  end if
  output3d = new(output_dims3d, float)
  ensemble3d = new(ensemble_dims3d, float)
  output2d = new(output_dims2d, float)
  ensemble2d = new(ensemble_dims2d, float)

  ens_avg3d = new(ensemble_stats3d, float)
  ens_stddev3d = new(ensemble_stats3d, float)
  ens_avg2d = new(ensemble_stats2d, float)
  ens_stddev2d = new(ensemble_stats2d, float)

  global_mean_lev_3d = new((/nvars3d, nfiles, nlev/), float)
  global_mean_3d = new((/nvars3d, nfiles/), float)
  global_mean_2d = new((/nvars2d, nfiles/), float)
  if (one_spatial_dim) then
    area_wgt = f[0]->TAREA/sum(f[0]->TAREA) ; Note: vector of length ncol
  else
    area_wgt = f[0]->TAREA   ; Note: vector of length nlat
  end if

;     (2a) 3D variables
  do v=0, nvars3d-1
    print((/"Collecting data for 3D variable "+(v+1)+" of "+nvars3d+" ("+var_name3d(v)+")"/))
    do n=0,nfiles-1
      ; Collect variable from each ensemble member into one array
      if (vinterp) then
        extrap = vinterp@extrap
        if (one_spatial_dim) then
          output3d(n,:,:)=vertical_interp(f[n], var_name3d(v), plevs, interp_type, extrap)
        else
          output3d(n,:,:,:)=vertical_interp(f[n], var_name3d(v), plevs, interp_type, extrap)
        end if
      else
        if (one_spatial_dim) then
          output3d(n,:,:) = f[n]->$var_name3d(v)$(tind,:,:)
        else
          output3d(n,:,:,:) = f[n]->$var_name3d(v)$(tind,:,:,:)
        end if
      end if
    end do ; n-loop

    ens_avg3d(v,:,:,:) = dim_avg_n(output3d,0)
    ens_stddev3d(v,:,:,:) = dim_stddev_n(output3d,0)

    ; end if ; Missing values in output

  end do ; v-loop (3D vars)

;     (2b) 2D variables
  do v=0, nvars2d-1
    print((/"Collecting data for variable "+var_name2d(v)/))
    print((/"2D variable "+(v+1)+" of "+nvars2d/))
    do n=0,nfiles-1
      ; Collect variable from each ensemble member into one array
      if (one_spatial_dim) then
        output2d(n,:)=f[n]->$var_name2d(v)$(tind,:)
      else
        output2d(n,:,:)=f[n]->$var_name2d(v)$(tind,:,:)
      end if
    end do ; n-loop

    ens_avg2d(v,:,:) = dim_avg_n(output2d,0)
    ens_stddev2d(v,:,:) = dim_stddev_n(output2d,0)
  end do ; v-loop (2D vars)

  ; (4) Output to netCDF

  system("rm -f "+ensemble_file)
  fout = addfile(ensemble_file,"c")

  setfileoption(fout,"DefineMode",True)
  fAtt = True
  fAtt@machine       = mach
  fAtt@resolution    = resolution
  fAtt@compset       = compset
  fAtt@tag           = tag
  fAtt@title         = "CAM validation means and std devs"
  fAtt@creation_date = systemfunc("date")
  fileattdef(fout, fAtt)

  if (one_spatial_dim) then
    dimNames = (/"ncol", "nlev","ens_size", "nvars", "nvars3d", "nvars2d", "str_size"/)
    dimSizes = (/ncol, nlevs, nfiles, nvars3d+nvars2d, nvars3d, nvars2d, str_size/)
    dimUnlim = (/False, False, False, False, False, False, False/)
  else
    dimNames = (/"nlat", "nlon", "nlev","ens_size", "nvars", "nvars3d", "nvars2d", "str_size"/)
    dimSizes = (/nlat, nlon, nlevs, nfiles, nvars3d+nvars2d, nvars3d, nvars2d, str_size/)
    dimUnlim = (/False, False, False, False, False, False, False, False/)
  end if
  filedimdef(fout, dimNames, dimSizes, dimUnlim)

  filevardef(fout, "lev", "float", (/"nlev"/))
  filevarattdef(fout, "lev", plevs)
  filevardef(fout, "TLONG", "float", (/ "nlat", "nlon"/))
  filevarattdef(fout, "TLONG", dble2flt(f[0]->TLONG))
  filevardef(fout, "TLAT", "float", (/ "nlat", "nlon"/))
  filevarattdef(fout, "TLAT", dble2flt(f[0]->TLAT))
  filevardef(fout, "vars", "character", (/"nvars", "str_size"/))
  filevardef(fout, "var3d", "character", (/"nvars3d", "str_size"/))
  filevardef(fout, "var2d", "character", (/"nvars2d", "str_size"/))

  var_names = (/"ens_avg3d", "ens_stddev3d"/)
  do i=0,dimsizes(var_names)-1
    if (one_spatial_dim) then
      filevardef(fout, var_names(i), "float", (/"nvars3d", "nlev", "ncol"/))
    else
      filevardef(fout, var_names(i), "float", (/"nvars3d", "nlev", "nlat", "nlon"/))
    end if
  end do
  delete(var_names)

  var_names = (/"ens_avg2d", "ens_stddev2d"/)
  do i=0,dimsizes(var_names)-1
    if (one_spatial_dim) then
      filevardef(fout, var_names(i), "float", (/"nvars2d", "ncol"/))
    else
      filevardef(fout, var_names(i), "float", (/"nvars2d", "nlat", "nlon"/))
    end if
  end do
  delete(var_names)


  setfileoption(fout, "DefineMode", False)
  fout->lev = (/plevs/)
  fout->TLONG = dble2flt(f[0]->TLONG)
  fout->TLAT = dble2flt(f[0]->TLAT)
  fout->ens_avg3d = ens_avg3d
  fout->ens_stddev3d = ens_stddev3d
  fout->ens_avg2d = ens_avg2d
  fout->ens_stddev2d = ens_stddev2d
  i = 0
  do v=0,nvars3d-1
    str_var = stringtochar(var_name3d(v))
    do k=0,dimsizes(str_var)-1
      fout->var3d(v,k) = (/str_var(k)/)
      fout->vars(i,k) = (/str_var(k)/)
    end do
    i = i+1
    delete(str_var)
  end do
  do v=0,nvars2d-1
    str_var = stringtochar(var_name2d(v))
    do k=0,dimsizes(str_var)-1
      fout->var2d(v,k) = (/str_var(k)/)
      fout->vars(i,k) = (/str_var(k)/)
    end do
    i = i+1
    delete(str_var)
  end do

  print((/"Successfully created "+ensemble_file+"!"/))
  return(0)
end
