load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  pert1=(/ "Original","Proc=96 block=40x33", "Proc=96 block=20x16", "Proc=48","Proc=192","Proc=384","Tadvect*10","Convectdiff*10" /)
  ;pert2=(/ ".tol.10", ".tol.11", ".tol.12", ".tol.14", ".tol.16",".csi", ""/)
  pert2=(/ ".tol.10", ".tol.11", ".tol.12", ".tol.14", ".tol.16",".csi"/)
  pert3=(/ ".tol.10_5", ".tol.9_5", ".tol.9", ".convectdiff2",".convectdiff5"/)

  pert=(/ "",".P96b40x33", ".P96b20x16", ".P48",".P192",".P384",".tol.9_5", ".tol.9",".tol.10_5", ".tol.10", ".tol.11", ".tol.12", ".tol.14", ".tol.16",".csi", ".convectdiff2",".convectdiff5",".convectdiff",".tadvect" /)

  npert1 = dimsizes(pert1)
  npert2 = dimsizes(pert2)
  npert3 = dimsizes(pert3)
  npert = npert1+npert2+npert3
  nyear = 3
  year = ispan(1,nyear,1)
  nmon = 12
  mon = ispan(1,12,1)
  smon = sprinti("%0.2i", mon) ; string 
  vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
  nvar = dimsizes(vars)
  npdf = 40
  zpdf = new((/npert,36,5,npdf/),float)

  ;;; read in layout and parameter cases
  tmpzpdf := asciiread("ZscoreHist_layout_param.ascii",(/npert1,nyear*nmon,nvar,npdf/),"float")
  zpdf(0:5,:,:,:) = tmpzpdf(0:npert1-3,:,:,:)
  zpdf(18,:,:,:) = tmpzpdf(npert1-2,:,:,:)
  zpdf(17,:,:,:) = tmpzpdf(npert1-1,:,:,:)
  ;;; read in tolerence cases
  tmpzpdf := asciiread("ZscoreHist_tol.ascii",(/npert2+1,nyear*nmon,nvar,npdf/),"float")
  zpdf(9:14,:,:,:) = tmpzpdf(0:npert2-1,:,:,:)
  ;;; read in extra tolerance cases
  tmpzpdf := asciiread("ZscoreHist_tol5_parm.ascii",(/npert3,nyear*nmon,nvar,npdf/),"float")
  zpdf(6:7,:,:,:) = tmpzpdf(1:2,:,:,:)
  zpdf(8,:,:,:) = tmpzpdf(0,:,:,:)
  zpdf(15:16,:,:,:) = tmpzpdf(3:4,:,:,:)
  
  zpdf!0 = "case"
  zpdf!1 = "time"
  zpdf!2 = "var"
  zpdf!3 = "pdf"
  zpdf := zpdf(var|:,case|:,time|:,pdf|:)

  asciiwrite("ZscoreHist_layout_tol_parm.ascii",zpdf)
end
  
