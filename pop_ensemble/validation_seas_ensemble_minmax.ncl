
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  begin
time=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
ens=(/"np","14","14.11","14.15","14.21","14.25","14.31","14.35","14.41","14.45","14.5","14.51","14.55","14.61","14.65","14.71","14.75","14.81","14.85","14.91","14.95","14.3","14.8","14.13","14.18","14.23","14.28","14.33","14.38","14.43","14.48","14.53","14.58","14.63","14.68","14.73","14.78","14.83","14.88","14.93","14.98"/)
pertname=(/ "EnsMin","EnsMax"/)
ntime = dimsizes(time)
nvars = dimsizes(vars)
nens = dimsizes(ens)
Reg  = (/"Southern","Pacific","Indian","Persian","unknow","Atlantic","Mediterranean","Baffin","North","Arctic","Hudson"/)
nReg = dimsizes(Reg)
pref  ="./validation_seas/validationtest-"
suf  ="-41cases.log "
y = new((/nvars,2,ntime,nReg/),"float")
e = new((/nvars,nens,ntime,nReg/),"float")
  do m = 0,ntime-1
  outmin = pref+time(m)+"-"+pertname(0)+suf
  outmax = pref+time(m)+"-"+pertname(1)+suf
  do n =0,nvars-1
  do k =0,nens-1
  cmd = "grep '"+vars(n)+": RMSZ score '  "+pref+time(m)+"-"+ens(k)+suf+" |awk '{print $6}'"
  e(n,k,m,:) = stringtofloat(systemfunc(cmd))
  end do
  y(n,0,m,:) = dim_min_n(e(n,:,m,:),0)
  y(n,1,m,:) = dim_max_n(e(n,:,m,:),0)
  
  
  end do
  end do
  print(e)
  asciiwrite(pref+"ens"+suf,y)

end 

  
