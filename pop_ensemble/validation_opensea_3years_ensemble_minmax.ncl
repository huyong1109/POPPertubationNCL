
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  begin
year=(/"1","2","3"/)
time=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
ens=(/"np","14","14.11","14.15","14.21","14.25","14.31","14.35","14.41","14.45","14.5","14.51","14.55","14.61","14.65","14.71","14.75","14.81","14.85","14.91","14.95","14.3","14.8","14.13","14.18","14.23","14.28","14.33","14.38","14.43","14.48","14.53","14.58","14.63","14.68","14.73","14.78","14.83","14.88","14.93","14.98"/)
pertname=(/ "EnsMin","EnsMax"/)
nyear = dimsizes(year)
ntime = dimsizes(time)
nvars = dimsizes(vars)
nens = dimsizes(ens)
pref  ="./validation_opensea_3years/validationtest-"
suf  ="-41cases.log "
y = new((/nvars,2,nyear*ntime/),"float")
e = new((/nvars,nens,nyear*ntime/),"float")
  do i = 0,nyear-1
  do m = 0,ntime-1
  do n =0,nvars-1
  do k =0,nens-1
  cmd = "grep '"+vars(n)+": RMSZ score '  "+pref+year(i)+"-"+time(m)+"-"+ens(k)+suf+" |awk '{print $6}'"
  e(n,k,m+ntime*i) = stringtofloat(systemfunc(cmd))
  end do
  y(n,0,m+ntime*i) = dim_min_n(e(n,:,m+ntime*i),0)
  y(n,1,m+ntime*i) = dim_max_n(e(n,:,m+ntime*i),0)
  
  end do
  end do
  end do
  print(e(:,:,0))
  asciiwrite(pref+"ens"+suf,y)

end 

  
