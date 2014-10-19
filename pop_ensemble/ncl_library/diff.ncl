
    undef("diff")
function diff(nfile, ofile, outfile, tag, compset, res, mach, tind, verbose)
    begin
    ; (1) Initial Setup
    ;     (1a) Open filelist and ensemble_file
    nfiles = dimsizes(nfile)
    if (dimsizes(ofile) .ne. nfiles)
        print("ERROR: number of newfiles and Oldfiles should be the same")
        status_exit(1)
    end if
    nf=addfiles(nfile,"r")
    of=addfiles(ofile,"r")

    ;     (1b) Store dimensions of input fields
    input_dims = getfiledimsizes(of[0])
    input_dim_names = getvardims(of[0])
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
    plev = dble2flt(of[0]->z_t)

    ;     (1c) Make sure all files have same dimensions!
    if (one_spatial_dim) then
    print((/"Ensuring nlev and ncol match on all files..."/))
    do i=1,nfiles-1
        input_dims2 = getfiledimsizes(nf[i])
        if ((input_dims2(ilev).ne.nlev).or.(input_dims2(icol).ne.ncol)) then
            print((/"ERROR: dimensions differ between "+nfile(0)+" and "+nfile(i)/))
            status_exit(1)
        end if
        input_dims2 = getfiledimsizes(of[i])
        if ((input_dims2(ilev).ne.nlev).or.(input_dims2(icol).ne.ncol)) then
            print((/"ERROR: dimensions differ between "+ofile(0)+" and "+ofile(i)/))
            status_exit(1)
        end if
    end do
    else
        print((/"Ensuring nlev, nlat, and nlon match on all files..."/))
        do i=1,nfiles-1
            input_dims2 = getfiledimsizes(nf[i])
            if ((input_dims2(ilev).ne.nlev).or.(input_dims2(ilon).ne.nlon).or.(input_dims2(ilat).ne.nlat)) then
                print((/"ERROR: dimensions differ between "+nfile(0)+" and "+nfile(i)/))
                status_exit(1)
            end if
            input_dims2 = getfiledimsizes(of[i])
            if ((input_dims2(ilev).ne.nlev).or.(input_dims2(ilon).ne.nlon).or.(input_dims2(ilat).ne.nlat)) then
                print((/"ERROR: dimensions differ between "+nfile(0)+" and "+ofile(i)/))
                status_exit(1)
            end if
        end do
    end if

    ;     (1d) Determine what variables will be output
    vNames = getfilevarnames(nf[0])
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
    dsize = dimsizes(nf[0]->$vNames(vind)$)
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
    plevs = plev
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
    Zscore3d=new((/nvars3d, nfiles/),float)
    output2d = new(output_dims2d, float)
    ensemble2d = new(ensemble_dims2d, float)
    Zscore2d=new((/nvars2d, nfiles/), float)

    ens_avg3d = new(ensemble_stats3d, float)
    ens_stddev3d = new(ensemble_stats3d, float)
    ens_avg2d = new(ensemble_stats2d, float)
    ens_stddev2d = new(ensemble_stats2d, float)

    rmse_3d = new((/nvars3d, nfiles/), float)
    rmse_2d = new((/nvars2d, nfiles/), float)
    maxe_3d = new((/nvars3d, nfiles/), float)
    maxe_2d = new((/nvars2d, nfiles/), float)
    covc_3d = new((/nvars3d, nfiles/), float)
    covc_2d = new((/nvars2d, nfiles/), float)
    if (one_spatial_dim) then
    area_wgt = f[0]->TAREA/sum(f[0]->TAREA) ; Note: vector of length ncol
    else
    area_wgtT = of[0]->TAREA   ; Note: vector of length nlat
    area_wgtU = of[0]->UAREA   ; Note: vector of length nlat
    end if

    ;     (2a) 3D variables
    do v=0, nvars3d-1
    print((/"Collecting data for 3D variable "+(v+1)+" of "+nvars3d+" ("+var_name3d(v)+")"/))
    do n=0,nfiles-1
    ; Collect variable from each ensemble member into one array
    ; print(f[n]->$var_name3d(v)&coordinates)
    array1 = nf[n]->$var_name3d(v)$(tind,:,:,:)
    array2 = of[n]->$var_name3d(v)$(tind,:,:,:)
    ;print(wgt_arearmse2(array1,array2, area_wgtT,0 ))
    rmse_3d(v,n) = avg(wgt_arearmse2(array1,array2, area_wgtT,0 ))
    maxe_3d(v,n) = max(abs(array1-array2))
    ;print(escorc(array1,array2) )
    covc_3d(v,n) = escorc(ndtooned(array1),ndtooned(array2))

    end do ; n-loop
    print((/var_name3d(v)+" rmse: "+rmse_3d(v,:)/))
    print((/var_name3d(v)+" maxe: "+maxe_3d(v,:)/))
    print((/var_name3d(v)+" covc: "+covc_3d(v,:)/))

    end do ; v-loop (3D vars)

    ;     (2b) 2D variables
    do v=0, nvars2d-1
    print((/"Collecting data for variable "+var_name2d(v)/))
    print((/"2D variable "+(v+1)+" of "+nvars2d/))
    do n=0,nfiles-1
    array2d1 = nf[n]->$var_name2d(v)$(tind,:,:)
    array2d2 = of[n]->$var_name2d(v)$(tind,:,:)
    rmse_2d(v,n) = wgt_arearmse2(array2d1,array2d2, area_wgtT,0)
    maxe_2d(v,n) = max(abs(array2d1-array2d2))
    covc_2d(v,n) = escorc(ndtooned(array2d1),ndtooned(array2d2))
    end do ; n-loop
    print((/var_name2d(v)+" rmse: "+rmse_2d(v,:)/))
    print((/var_name2d(v)+" maxe: "+maxe_2d(v,:)/))
    print((/var_name2d(v)+" covc: "+covc_2d(v,:)/))
    end do ; v-loop (2D vars)

    ; (4) Output to netCDF

    system("rm -f "+outfile)
    fout = addfile(outfile,"c")

    setfileoption(fout,"DefineMode",True)
    fAtt = True
    fAtt@machine       = mach
    fAtt@resolution    = res
    fAtt@compset       = compset
    fAtt@tag           = tag
    fAtt@title         = "POP validation rmsz and max error"
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout, fAtt)

    dimNames = (/"ens_size", "nvars", "nvars3d", "nvars2d", "str_size"/)
    dimSizes = (/ nfiles, nvars3d+nvars2d, nvars3d, nvars2d, str_size/)
    dimUnlim = (/False, False, False, False, False/)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

    filevardef(fout, "vars", "character", (/"nvars", "str_size"/))
    filevardef(fout, "var3d", "character", (/"nvars3d", "str_size"/))
    filevardef(fout, "var2d", "character", (/"nvars2d", "str_size"/))


    filevardef(fout, "RMSE", "float", (/"nvars", "ens_size"/))
    filevardef(fout, "MAXE", "float", (/"nvars", "ens_size"/))
    filevardef(fout, "COVC", "float", (/"nvars", "ens_size"/))

    setfileoption(fout, "DefineMode", False)
    fout->RMSE = (/array_append_record(rmse_3d,rmse_2d,0)/)
    fout->MAXE = (/array_append_record(maxe_3d,maxe_2d,0)/)
    fout->COVC = (/array_append_record(covc_3d,covc_2d,0)/)
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
