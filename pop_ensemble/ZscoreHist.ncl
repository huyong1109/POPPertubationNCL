load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;************************************************
begin
  ;************************************************
  ; read in data
  ;************************************************
  path = "/glade/p/work/huyong/NCOUT/3years_opensea/"
  path1 = "/glade/scratch/huyong/archive/perturb.g40.T.year"
  filepre = "/ocn/hist/perturb.g40.T.year"

  ;pert=(/ "",".P96b40x33", ".P96b20x16", ".P48",".P192",".P384",".tadvect",".convectdiff" /)
  ;pert=(/ ".tol.10", ".tol.11", ".tol.12", ".tol.14", ".tol.16",".csi", ""/)
  pert=(/ ".tol.10_5", ".tol.9_5", ".tol.9", ".convectdiff2",".convectdiff5"/)
  ;pertname=(/ "ChronGear + tolerance (1.0e-10)", "ChronGear + tolerance (1.0e-11)", "ChronGear + tolerance (1.0e-12)", "ChronGear + tolerance (1.0e-14)", "ChronGear + tolerance (1.0e-16)","P-CSI  + tolerance (1.0e-13)", "Default Configuration", "Ensemb min","Ensemb max"/)
  npert = dimsizes(pert)
  nyear = 3
  year = ispan(1,nyear,1)
  nmon = 12
  mon = ispan(1,12,1)
  smon = sprinti("%0.2i", mon) ; string 
  vars=(/"UVEL", "VVEL","TEMP","SALT","SSH"/)
  ;nvar = dimsizes(vars)
  nvar = 4
  npdf = 40

  ;case = ""
  Zpdf = new((/npert,36,5,npdf/),float)
  
  ;;; prepare mask and grid information
  case = pert(0)
  filecnt = path1+case+filepre+case+".pop.h.000"+year(0)+"-"+smon(0)+".nc"
  print("Prep file: "+(/filecnt/))
  cntf  = addfile (filecnt, "r")
  rmask =  cntf->REGION_MASK
  rmask_3D = conform(cntf->TEMP(0,:,:,:),rmask,(/1,2/))
  lon2d = cntf->ULONG
  lat2d = cntf->ULAT
  
  ;;; resource for pdfx
  pres = True
  pres@bin_min = 0
  pres@bin_max = 4.0

  do iyear = 0, 2
    do imon = 0,nmon-1
      
      indmon = 12*iyear + imon
      ;;; read in Ensemble file 
      filename = path+"perturb.T.h."+year(iyear)+"-"+smon(imon)+"-14-np-40cases.nc"
      print("Ensb file: "+(/filename/))
      fT        = addfile (filename, "r")
      std2d      = fT->ens_stddev2d(0,:,:)
      ensavg2d   = fT->ens_avg2d(0,:,:)
      std3d      = fT->ens_stddev3d(:,:,:,:)
      ensavg3d   = fT->ens_avg3d(:,:,:,:)
      
      ;;; mask open seas 
      std2d = mask(std2d,rmask .ge. 1 .and. rmask .le. 6, True)
      std3d = mask(std3d,rmask_3D .ge. 1 .and. rmask_3D .le. 6, True)

      do ncase = 0, npert-1
        case = pert(ncase)
      
        ;;;; read case history file
        filecnt = path1+case+filepre+case+".pop.h.000"+year(iyear)+"-"+smon(imon)+".nc"
        print("Test file: "+(/filecnt/))
        cntf      = addfile (filecnt, "r")
        
        ;;; read 2D variables
        print("Variable: SSH")
        data2d =  cntf->SSH(0,:,:)
        ;;; Pointwise Zscore
        data2d = abs((data2d-ensavg2d(:,:))/where(std2d(:,:) .le. 1.0e-12, std2d@_FillValue, std2d(:,:)))
        
        ;;; Probability Distribution Function
        zpdfx := dble2flt(pdfx(data2d,npdf,pres))
        print(zpdfx@bin_center + " " +zpdfx)
        Zpdf(ncase,indmon,4,:) = zpdfx

        ;;; read 3D variables
        do v = 0,nvar-1
          print("Variable: "+vars(v))
          data =  cntf->$vars(v)$(0,:,:,:)
          ;;; Zscore
          data = abs((data-ensavg3d(v,:,:,:))/where(std3d(v,:,:,:) .le. 1.0e-12, std3d@_FillValue, std3d(v,:,:,:)))
          zpdfx := dble2flt(pdfx(data,npdf,pres))
          print(zpdfx@bin_center + " " +zpdfx)
          Zpdf(ncase,indmon,v,:) = zpdfx
        end do
      end do 

    end do
  end do
  asciiwrite("ZscoreHist_tol5_parm.ascii",Zpdf)
end
