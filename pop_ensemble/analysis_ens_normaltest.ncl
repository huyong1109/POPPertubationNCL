;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This ncl script read values from ensemble files at
; a given point and plot their PDF 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
begin


  nyear = 3 
  nmon = 12
  nvar = 4
  nens =40 
  year = ispan(1,nyear,1)
  mon  = sprinti("%0.2i",ispan(1,nmon,1))
  append = "-14-np-40cases.nc"

  ; read in all ensemble files
  ensroot = "/glade/scratch/huyong/archive/"
  casename = "perturb.g40.T.year."
  id_str = asciiread("filesuff.T.in", -1, "string")
  infiles = new(nens,string)
  vars=(/"UVEL", "VVEL","TEMP","SALT"/)
  
;  x = new((/nyear*nmon,nvar,nens/),float)
;  do i = 0,nyear-1
;    do j = 0,nmon-1
;       k = i*nmon+j
;       do n=0,nens-1
;         suf = year(i)+"-"+mon(j)
;         infiles(n) = ensroot+casename+id_str(n)+"/ocn/hist/"+casename+id_str(n)+".pop.h.000"+suf+".nc"
;         print(infiles(n))
;         fens = addfile(infiles(n), "r")
;         do v = 0, nvar -1
;           ; get one point in the Pacific Ocean
;           x(k,v,n) = fens->$vars(v)$(0,0,100,200)
;         end do 
;       end do
;    end do 
;  end do 
;    printVarSummary(x)
;    asciiwrite("point.asc",x)
x = asciiread("point.asc",(/36,4,40/),"float")
;print(x)

      do v = 0, nvar-1
        filename = "pdf-"+vars(v)+"-200-200"                  ; open workstatio
        wks   = gsn_open_wks ("png",filename)
        res = True
        res@gsnDraw = False
        res@gsnFrame = False
        gsn_define_colormap(wks, "BlRe")
        res@trXMinF = -2
        res@trXMaxF = 2
        res@trYMinF = 0
        res@trYMaxF = 50
        res@tmXBStyle = "log"
        
        res@tiMainString     = vars(v)         ; change line color
        res@tiXAxisString     = "Z-score"         ; change line color
        res@tiYAxisString     = "Probability"         ; change line color
        ;res@xyLineThicknesses = (/4,2,2/)
        ;res@xyLineColors = (/"lightseagreen","SlateBlue","SlateBlue"/)
        ;res@xyMarkers      = (/3,2,1/)          ; change line color
        ;res@pmLegendDisplayMode     = "Always"
        ;res@pmLegendSide     = "Top"
        ;res@pmLegendWidthF     = 0.30
        ;res@pmLegendHeightF     = 0.15
        ;res@pmLegendOrthogonalPosF     = -0.40
        plot = new(nmon*nyear,graphic)
        do i = 0,nyear-1
        do j = 0,nmon-1
          k = i*nmon+j
          xpdf = pdfx((x(k,v,:)-avg(x(k,v,:)))/where(stddev(x(k,v,:)) .le. 1.0e-8,x@_FillValue, stddev(x(k,v,:))) ,9,False)
          print(xpdf)
          print("bin_center------>")
          print(xpdf@bin_center -xpdf@bin_center(2))
          res@xyLineColors = k*2
          res@xyDashPattern = k
          res@xyLineThicknesses = 3
          plot(k)  = gsn_csm_xy (wks,xpdf@bin_center,xpdf,res)
          if (k .ne. 0) then
            overlay(plot(0),plot(k))
          end if
        end do 
        end do  
        draw(plot(0))
        frame(wks)
        system("convert -trim "+filename+".png " +filename+".png")
      end do 
      


end 
