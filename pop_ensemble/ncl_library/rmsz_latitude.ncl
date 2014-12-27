load "$NCL_VALID_LIB_DIR/Zscore.ncl"
load "$NCL_VALID_LIB_DIR/global.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("calculate_rmsz_score_lat")
function calculate_rmsz_score_lat(run_file, ensemble_file, var_name3d, var_name2d, tind, vinterp, FailTest, VarInEns, verbose)
begin

; (1) Initial setup
;     (1a) Open run_file and ensemble_file

  RegLat = (/0,36,92,273,339,384/)
  RegNum = dimsizes(RegLat)-1
  frun = addfile(run_file,"r")
  fens = addfile(ensemble_file,"r")

;     (1b) Store dimensions of input fields
  input_dims = getfiledimsizes(frun)
  input_dim_names = getvardims(frun)

  nlev = -1
  ncol = -1
  nlat = -1
  nlon = -1
  ilev = -1
  icol = -1
  ilat = -1
  ilon = -1

  do i=0,dimsizes(input_dims)-1
    if (input_dim_names(i).eq."z_t") then
      nlev = input_dims(i)
      ilev = i
      print(input_dim_names(i))
      print(input_dims(i))
      print(ilev)
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
    print("nlev"+nlev)
    print((/"ERROR: can not find nlev dimension in "+run_file/))
    status_exit(1)
  end if
  if (((nlon.eq.-1).or.(nlat.eq.-1)).and.(ncol.eq.-1)) then
    print((/"ERROR: can not find ncol or nlat/nlon dimension in "+run_file/))
    status_exit(1)
  end if
  if (ncol.ne.-1) then
    one_spatial_dim = True
  else
    one_spatial_dim = False
  end if
  plev = dble2flt(frun->z_t)

  nvars3d = dimsizes(var_name3d)
  nvars2d = dimsizes(var_name2d)

;     (1c) Setup for comparison
  if (vinterp) then
    interp_type = new(1,"integer")
    plevs = get_interpolation_levels(interp_type) ; interp_type is intent(out)
  else 
    plevs = plev
  end if
  nlevs = dimsizes(plevs)

;          dimsizes for comparing to the ensemble are same as the input, except
;          we remove the time dimension and set the number of levels to nlevs.
;          So instead of using (time, nlev, ncol), we use (nlevs, ncol)
  if (one_spatial_dim) then
    comparison_dims3d = (/nvars3d, nlevs, ncol/)
    comparison_dims2d = (/nvars2d, ncol/)
  else
    comparison_dims3d = (/nvars3d, nlevs, nlat, nlon/)
    comparison_dims2d = (/nvars2d, nlat, nlon/)
  end if

  comparison3d  = new(comparison_dims3d, float)
  comparison2d  = new(comparison_dims2d, float)

  allvars3d = new(nvars3d, integer)
  allvars2d = new(nvars2d, integer)
  file_3d_dims = getfilevardimsizes(fens, "ens_avg3d")
  file_nvars3d = file_3d_dims(0)
  file_2d_dims = getfilevardimsizes(fens, "ens_avg2d")
  file_nvars2d = file_2d_dims(0)

  ; (2) Vertically interpolate output
  if (vinterp) then
    extrap = vinterp@extrap
    do v=0,nvars3d-1
      v_in_f = ind(chartostring(fens->vars).eq.var_name3d(v))
      allvars3d(v) = v_in_f
      if (one_spatial_dim) then
        comparison3d(v,:,:)  = vertical_interp(frun, var_name3d(v), plevs, interp_type, extrap)
      else
        comparison3d(v,:,:,:)  = vertical_interp(frun, var_name3d(v), plevs, interp_type, extrap)
      end if
    end do
  else
    do v=0,nvars3d-1
      v_in_f = ind(chartostring(fens->vars).eq.var_name3d(v))
      allvars3d(v) = v_in_f
      if (isfilevar(frun, var_name3d(v))) then
        if (one_spatial_dim) then
          comparison3d(v,:,:)  = (/frun->$var_name3d(v)$(tind,:,:)/)
        else
          comparison3d(v,:,:,:)  = (/frun->$var_name3d(v)$(tind,:,:,:)/)
        end if
      else
        VarInEns(v) = False
        if (verbose) then
          print((/"WARNING: "+var_name3d(v)+" does not exist in file output"/))
        end if
      end if
    end do
  end if
  do v=0,nvars2d-1
    v_in_f = ind(chartostring(fens->vars).eq.var_name2d(v))-file_nvars3d
    allvars2d(v) = v_in_f
    if (isfilevar(frun, var_name2d(v))) then
      if (one_spatial_dim) then
        comparison2d(v,:)  = (/frun->$var_name2d(v)$(tind,:)/)
      else
        comparison2d(v,:,:)  = (/frun->$var_name2d(v)$(tind,:,:)/)
      end if
    else
      VarInEns(v+nvars3d) = False
      if (verbose) then
        print((/"WARNING: "+var_name2d(v)+" does not exist in file output"/))
      end if
    end if
  end do

  ; (3) Compare to ensemble statistics
  if (one_spatial_dim) then
    npts3d=int2flt(nlevs*ncol)
    ens_avg3d    = new((/nvars3d,nlevs,ncol/), float)
    ens_stddev3d = new((/nvars3d,nlevs,ncol/), float)
    ens_avg3d    = fens->ens_avg3d(allvars3d,:,:)
    ens_stddev3d = fens->ens_stddev3d(allvars3d,:,:)

    npts2d=int2flt(ncol)
    ens_avg2d    = new((/nvars2d,ncol/), float)
    ens_stddev2d = new((/nvars2d,ncol/), float)
    ens_avg2d    = fens->ens_avg2d(allvars2d,:)
    ens_stddev2d = fens->ens_stddev2d(allvars2d,:)
  else
    npts3d=int2flt(nlevs*nlat*nlon)
    ens_avg3d    = new((/nvars3d,nlevs,nlat, nlon/), float)
    ens_stddev3d = new((/nvars3d,nlevs,nlat, nlon/), float)
    ens_avg3d    = fens->ens_avg3d(allvars3d,:,:,:)
    ens_stddev3d = fens->ens_stddev3d(allvars3d,:,:,:)

    npts2d=int2flt(nlat*nlon)
    ens_avg2d    = new((/nvars2d,nlat, nlon/), float)
    ens_stddev2d = new((/nvars2d,nlat, nlon/), float)
    ens_avg2d    = fens->ens_avg2d(allvars2d,:,:)
    ens_stddev2d = fens->ens_stddev2d(allvars2d,:,:)
  end if
  
  RMSZscore2d=new((/nvars2d,RegNum/),float)
  RMSZscore3d=new((/nvars3d,RegNum/),float)

  do v=0, nvars3d-1
    RMSZscore3d(v,:) = 0.
    ; Cycle through levels for 3D data

    do regn = 0, RegNum -1
      count3d = 0
      ;print("lat = "+RegLat(regn)+" : "+(/RegLat(regn+1)-1/))
      npts3dReg = int2flt(nlevs*(RegLat(regn+1)-RegLat(regn))*nlon)
      do k=0,nlevs-1
        print("k  =" +k +" Zscore "+RMSZscore3d(v,regn))
        RMSZscore3d(v,regn) = RMSZscore3d(v,regn) + sum_sqr(calc_Z(comparison3d(v,k,RegLat(regn):RegLat(regn+1)-1,:), \
              ens_avg3d(v,k,RegLat(regn):RegLat(regn+1)-1,:), ens_stddev3d(v,k,RegLat(regn):RegLat(regn+1)-1,:), count3d, False))
      end do ; k (loop through vertical levels)
      if (npts3dReg.gt.count3d) then
        RMSZscore3d(v,regn) = sqrt(RMSZscore3d(v,regn) / (npts3dReg - count3d))
        print("npts3d = "+npts3dReg+"  count ="+count3d)
        
        v_in_f = ind(chartostring(fens->vars).eq.var_name3d(v))
        ;FailTest(v) = RMSZscore3d(v).gt.max(fens->RMSZ(v_in_f,:))
        else
        VarInEns(v) = False
        print("npts3d = "+npts3dReg+"  count ="+count3d)
      end if
      print(RMSZscore3d)
    end do 
  end do

  do v=0, nvars2d-1
    do regn = 0, RegNum -1
    count2d = 0
    print("lat = "+RegLat(regn)+" : "+(/RegLat(regn+1)-1/))
    RMSZscore2d(v,regn) = sum_sqr(calc_Z(comparison2d(v,RegLat(regn):RegLat(regn+1)-1,:), ens_avg2d(v,RegLat(regn):RegLat(regn+1)-1,:), \
                                   ens_stddev2d(v,RegLat(regn):RegLat(regn+1)-1,:), count2d, False))
    npts2dReg = int2flt((RegLat(regn+1)-RegLat(regn))*nlon)
    if (npts2dReg .gt.count2d) then
      RMSZscore2d(v,regn) = sqrt(RMSZscore2d(v,regn) / (npts2dReg - count2d))
      v_in_f = ind(chartostring(fens->vars).eq.var_name2d(v))
       ;print("npts2d = "+npts2dReg+"  count ="+count2d)
      ;FailTest(v+nvars3d) = RMSZscore2d(v).gt.max(fens->RMSZ(v_in_f,:))
    else
      VarInEns(v+nvars3d) = False
    end if
    end do 
      print(RMSZscore2d)
  end do
  print((/num(.not.VarInEns)+" ensemble variables either have no variance or are not included in test output."/))
  if (verbose) then
    if (num(.not.VarInEns).gt.0) then
      print((/"Not computing RMSZ for the following: "/))
      if (any(.not.VarInEns(0:nvars3d-1))) then
        print((/var_name3d(ind(.not.VarInEns(0:nvars3d-1)))/))
      end if
      if (any(.not.VarInEns(nvars3d:nvars3d+nvars2d-1))) then
        print((/var_name2d(ind(.not.VarInEns(nvars3d:nvars3d+nvars2d-1)))/))
      end if
      print((/"---"/))
    end if
  end if

  ; (4) Return Z-scores

  return(array_append_record(RMSZscore3d, RMSZscore2d,0))

end
